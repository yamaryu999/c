import cv2
import numpy as np
import os

def extract_precise_logo(image_path, output_path):
    if not os.path.exists(image_path):
        print(f"File not found: {image_path}")
        return None

    img = cv2.imread(image_path)
    if img is None:
        print(f"Failed to load image: {image_path}")
        return None

    output = img.copy()
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Blur to reduce noise
    gray = cv2.medianBlur(gray, 5)
    
    rows = gray.shape[0]
    
    # HoughCircles parameters need tuning based on image size
    # param1: Canny high threshold (low is half)
    # param2: accumulator threshold (lower = more circles)
    # minRadius: min circle size
    # maxRadius: max circle size
    
    # Card is roughly 1000px wide? 
    # Logo is roughly 70-80% of height.
    h, w = img.shape[:2]
    min_r = int(h * 0.25)
    max_r = int(h * 0.45) # Radius is half height, so 0.45 * 2 = 0.9 diameter
    
    circles = cv2.HoughCircles(gray, cv2.HOUGH_GRADIENT, 1, rows / 8,
                               param1=100, param2=30,
                               minRadius=min_r, maxRadius=max_r)

    best_circle = None
    
    if circles is not None:
        circles = np.uint16(np.around(circles))
        
        # Find circle closest to center
        center_x, center_y = w // 2, h // 2
        min_dist = float('inf')
        
        for i in circles[0, :]:
            cx, cy, r = i[0], i[1], i[2]
            dist = np.sqrt((cx - center_x)**2 + (cy - center_y)**2)
            
            # Prefer larger circles if distances are similar
            # Heuristic score: distance - radius*0.1 (bonus for size)
            score = dist - r * 0.1
            
            if score < min_dist:
                min_dist = score
                best_circle = (cx, cy, r)

    if best_circle:
        cx, cy, r = best_circle
        print(f"Found logo circle: center=({cx}, {cy}), radius={r}")
        
        # Crop Square
        # Add a tiny margin? No, user wants *only* the logo.
        # But a square crop is needed for rotation.
        crop_r = r
        
        x1 = int(max(0, cx - crop_r))
        y1 = int(max(0, cy - crop_r))
        x2 = int(min(w, cx + crop_r))
        y2 = int(min(h, cy + crop_r))
        
        # Ensure square
        w_crop = x2 - x1
        h_crop = y2 - y1
        min_dim = min(w_crop, h_crop)
        
        # Center the square crop on the circle center
        x1 = int(cx - min_dim // 2)
        y1 = int(cy - min_dim // 2)
        x2 = x1 + min_dim
        y2 = y1 + min_dim
        
        crop_img = img[y1:y2, x1:x2]
        cv2.imwrite(output_path, crop_img)
        print(f"Saved precise logo to {output_path}")
        
        # Return diameter ratio relative to card height
        diameter = r * 2
        return diameter / h
    else:
        print(f"No circle found in {image_path}")
        # Fallback: crop center 75%
        crop_size = int(h * 0.75)
        cx, cy = w // 2, h // 2
        x1 = cx - crop_size // 2
        y1 = cy - crop_size // 2
        crop_img = img[y1:y1+crop_size, x1:x1+crop_size]
        cv2.imwrite(output_path, crop_img)
        print("Fallback crop used")
def extract_logo_by_threshold(image_path, output_path):
    if not os.path.exists(image_path):
        print(f"File not found: {image_path}")
        return None

    img = cv2.imread(image_path)
    if img is None:
        print(f"Failed to load image: {image_path}")
        return None

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Yoga card is dark BG, bright logo.
    # Apply threshold to Isolate bright features.
    # Use Otsu's binarization
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    _, thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    
    # Find contours
    cnts, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    if not cnts:
        print("No contours found")
        return None
        
    # Find the largest contour near the center
    h, w = img.shape[:2]
    center_x, center_y = w // 2, h // 2
    
    best_cnt = None
    min_dist_score = float('inf')
    
    for c in cnts:
        area = cv2.contourArea(c)
        if area < 1000: continue # Skip noise
        
        M = cv2.moments(c)
        if M["m00"] == 0: continue
        cX = int(M["m10"] / M["m00"])
        cY = int(M["m01"] / M["m00"])
        
        dist = np.sqrt((cX - center_x)**2 + (cY - center_y)**2)
        
        # We want large area and close to center
        # Score = distance / sqrt(area) ? 
        # Simple heuristic: distance weighted by inverse area priority?
        # Actually usually the logo is the biggest thing in the center.
        
        score = dist - (area / 1000) # Give bonus to huge areas
        
        if score < min_dist_score:
            min_dist_score = score
            best_cnt = c
            
    if best_cnt is not None:
        (x, y), radius = cv2.minEnclosingCircle(best_cnt)
        center = (int(x), int(y))
        radius = int(radius)
        
        # Sanity check: If radius is > half of image width, it's likely the whole card
        if radius > w * 0.45:
             print(f"Detected radius {radius} too large for image width {w}. Trying second best?")
             # For now, just clamp it to a reasonable max, e.g. 40% of height
             radius = int(h * 0.4)
             print(f"Clamped radius to {radius}")
        
        print(f"Found contour circle: center={center}, radius={radius}")
        
        # Crop Square
        crop_r = radius
        
        # Initial bounds based on radius
        x1_raw = center[0] - crop_r
        y1_raw = center[1] - crop_r
        x2_raw = center[0] + crop_r
        y2_raw = center[1] + crop_r
        
        # Width/Height of the crop box
        box_w = x2_raw - x1_raw
        box_h = y2_raw - y1_raw
        
        # We need a square.
        dim = min(box_w, box_h)
        
        # Re-center
        x1 = int(center[0] - dim // 2)
        y1 = int(center[1] - dim // 2)
        x2 = x1 + dim
        y2 = y1 + dim
        
        # Final Clamp to image boundaries
        # If the square goes out of bounds, we have to shrink it or accept non-square?
        # Typically we shift it?
        
        if x1 < 0: 
            x2 -= x1 # shift right? No, keep centered?
            x1 = 0
            
        if y1 < 0:
            y1 = 0
            
        if x2 > w:
            x2 = w
            
        if y2 > h:
            y2 = h
            
        # If clamping made it non-square, force square by taking min dimension again
        final_w = x2 - x1
        final_h = y2 - y1
        final_dim = min(final_w, final_h)
        
        x2 = x1 + final_dim
        y2 = y1 + final_dim
        
        if final_dim <= 0:
             print("Invalid crop dimensions")
             return None

        crop_img = img[y1:y2, x1:x2]
        
        if crop_img.size == 0:
             print("Empty crop image")
             return None
             
        cv2.imwrite(output_path, crop_img)
        print(f"Saved precise logo (threshold) to {output_path}")
        
        return (final_dim) / h
    
    return None

def main():
    asset_dir = "midas_card_demo/assets"
    
    # Process Mikuni (Keep existing Hough method for now, or use threshold if needed, but Yoga was the complaint)
    # Mikuni is purple/green, Hough worked OK? User specifically mentioned "2nd image" (Yoga).
    ratio_mikuni = extract_precise_logo(
        os.path.join(asset_dir, "card_mikuni_v2.jpg"),
        os.path.join(asset_dir, "logo_mikuni_precise.jpg")
    )
    
    # Process Yoga with new Threshold method
    ratio_yoga = extract_logo_by_threshold(
        os.path.join(asset_dir, "card_yoga_v2.jpg"),
        os.path.join(asset_dir, "logo_yoga_precise.jpg")
    )
    
    print("\n--- RATIOS FOR FLUTTER ---")
    if ratio_mikuni: print(f"Mikuni Ratio: {ratio_mikuni:.3f}")
    if ratio_yoga: print(f"Yoga Ratio: {ratio_yoga:.3f}")

if __name__ == "__main__":
    main()
