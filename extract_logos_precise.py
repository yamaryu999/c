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
        return 0.75

def main():
    asset_dir = "midas_card_demo/assets"
    
    # Process Mikuni
    ratio_mikuni = extract_precise_logo(
        os.path.join(asset_dir, "card_mikuni_v2.jpg"),
        os.path.join(asset_dir, "logo_mikuni_precise.jpg")
    )
    
    # Process Yoga
    ratio_yoga = extract_precise_logo(
        os.path.join(asset_dir, "card_yoga_v2.jpg"),
        os.path.join(asset_dir, "logo_yoga_precise.jpg")
    )
    
    print("\n--- RATIOS FOR FLUTTER ---")
    if ratio_mikuni: print(f"Mikuni Ratio: {ratio_mikuni:.3f}")
    if ratio_yoga: print(f"Yoga Ratio: {ratio_yoga:.3f}")

if __name__ == "__main__":
    main()
