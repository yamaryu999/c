import cv2
import numpy as np
import os

def order_points(pts):
    # initialzie a list of coordinates that will be ordered
    # such that the first entry in the list is the top-left,
    # the second entry is the top-right, the third is the
    # bottom-right, and the fourth is the bottom-left
    rect = np.zeros((4, 2), dtype = "float32")
    # the top-left point will have the smallest sum, whereas
    # the bottom-right point will have the largest sum
    s = pts.sum(axis = 1)
    rect[0] = pts[np.argmin(s)]
    rect[2] = pts[np.argmax(s)]
    # now, compute the difference between the points, the
    # top-right point will have the smallest difference,
    # whereas the bottom-left will have the largest difference
    diff = np.diff(pts, axis = 1)
    rect[1] = pts[np.argmin(diff)]
    rect[3] = pts[np.argmax(diff)]
    # return the ordered coordinates
    return rect

def four_point_transform(image, pts):
    # obtain a consistent order of the points and unpack them
    # individually
    rect = order_points(pts)
    (tl, tr, br, bl) = rect
    # compute the width of the new image, which will be the
    # maximum distance between bottom-right and bottom-left
    # x-coordiates or the top-right and top-left x-coordinates
    widthA = np.sqrt(((br[0] - bl[0]) ** 2) + ((br[1] - bl[1]) ** 2))
    widthB = np.sqrt(((tr[0] - tl[0]) ** 2) + ((tr[1] - tl[1]) ** 2))
    maxWidth = max(int(widthA), int(widthB))
    # compute the height of the new image, which will be the
    # maximum distance between the top-right and bottom-right
    # y-coordinates or the top-left and bottom-left y-coordinates
    heightA = np.sqrt(((tr[0] - br[0]) ** 2) + ((tr[1] - br[1]) ** 2))
    heightB = np.sqrt(((tl[0] - bl[0]) ** 2) + ((tl[1] - bl[1]) ** 2))
    maxHeight = max(int(heightA), int(heightB))
    # now that we have the dimensions of the new image, construct
    # the set of destination points to obtain a "birds eye view",
    # (i.e. top-down view) of the image, again specifying points
    # in the top-left, top-right, bottom-right, and bottom-left
    # order
    dst = np.array([
        [0, 0],
        [maxWidth - 1, 0],
        [maxWidth - 1, maxHeight - 1],
        [0, maxHeight - 1]], dtype = "float32")
    # compute the perspective transform matrix and then apply it
    M = cv2.getPerspectiveTransform(rect, dst)
    warped = cv2.warpPerspective(image, M, (maxWidth, maxHeight))
    # return the warped image
    return warped

def extract_logo(card_img):
    # Extract center logo from cropped card
    # Assume logo is in center, ~75% of height
    h, w = card_img.shape[:2]
    crop_size = int(h * 0.75)
    
    # Precise center
    cx, cy = w // 2, h // 2
    
    x1 = max(0, cx - crop_size // 2)
    y1 = max(0, cy - crop_size // 2)
    x2 = min(w, cx + crop_size // 2)
    y2 = min(h, cy + crop_size // 2)
    
    return card_img[y1:y2, x1:x2]

def main():
    input_path = "m83678334870_1.jpg"
    output_dir = "midas_card_demo/assets"
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # 1. Load Image
    image = cv2.imread(input_path)
    if image is None:
        print("Failed to load image")
        return

    # 2. Preprocessing
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    
    # 3. Edge Detection
    edged = cv2.Canny(blurred, 50, 200)
    
    # 4. Find Contours
    cnts, _ = cv2.findContours(edged.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    print(f"Found {len(cnts)} contours")
    
    card_contours = []
    
    for c in cnts:
        # Approximate the contour
        peri = cv2.arcLength(c, True)
        approx = cv2.approxPolyDP(c, 0.02 * peri, True)
        
        # Filter for rectangles with sufficient area
        if len(approx) == 4 and cv2.contourArea(c) > 50000: # Adjust threshold as needed
            card_contours.append(approx.reshape(4, 2))
            
    print(f"Detected {len(card_contours)} card candidates")
    
    if len(card_contours) != 4:
        print("Warning: Did not detect exactly 4 cards. Using largest 4.")
        card_contours = sorted(card_contours, key=lambda c: cv2.contourArea(c), reverse=True)[:4]

    # 5. Sort Contours (TL, TR, BL, BR)
    # Sort by Y first (Top row vs Bottom row)
    # Get centers
    centers = []
    for c in card_contours:
        M = cv2.moments(c)
        cX = int(M["m10"] / M["m00"])
        cY = int(M["m01"] / M["m00"])
        centers.append((cY, cX, c))
        
    centers.sort(key=lambda x: x[0]) # Sort by Y
    
    # Split into top 2 and bottom 2
    top_row = sorted(centers[:2], key=lambda x: x[1]) # Sort by X
    bottom_row = sorted(centers[2:], key=lambda x: x[1]) # Sort by X
    
    sorted_contours = [x[2] for x in top_row + bottom_row]
    
    card_names = ["yoga", "mikuni", "jennifer", "senzaki"]
    
    # 6. Transform and Save
    for i, contour in enumerate(sorted_contours):
        warped = four_point_transform(image, contour)
        
        # Save Card
        card_filename = f"card_{card_names[i]}.jpg"
        cv2.imwrite(os.path.join(output_dir, card_filename), warped)
        print(f"Saved {card_filename}")
        
        # Extract and Save Logo
        logo = extract_logo(warped)
        logo_filename = f"logo_{card_names[i]}.jpg"
        cv2.imwrite(os.path.join(output_dir, logo_filename), logo)
        print(f"Saved {logo_filename}")

if __name__ == "__main__":
    main()
