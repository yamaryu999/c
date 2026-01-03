from PIL import Image
import os

def crop_image():
    input_path = "m83678334870_1.jpg"
    output_dir = "midas_card_demo/assets"
    
    if not os.path.exists(input_path):
        print(f"Error: {input_path} not found.")
        return

    try:
        img = Image.open(input_path)
        width, height = img.size
        print(f"Original image size: {width}x{height}")

        # The image has 2x2 cards with some whitespace.
        # I'll use relative coordinates to guess the crop boxes.
        # Based on visual inspection of the grid:
        
        # Center point
        cx = width // 2
        cy = height // 2
        
        # Margins (approximate)
        margin_x = int(width * 0.05)
        margin_y = int(height * 0.15) # Top/bottom white space seems larger
        
        # Card dimensions (approx)
        # width ~ 45%, height ~ 35% of total
        card_w = int(width * 0.42)
        card_h = int(height * 0.3)
        
        # Crop Boxes (left, top, right, bottom)
        
        # 1. Yoga (Top-Left)
        # Adjusting to center the card in the quadrant
        yoga_box = (
            int(width * 0.05),          # left
            int(height * 0.16),         # top
            int(width * 0.05 + card_w), # right
            int(height * 0.16 + card_h) # bottom
        )
        
        # 2. Mikuni (Top-Right)
        mikuni_box = (
             int(width * 0.52), 
             int(height * 0.16),
             int(width * 0.52 + card_w),
             int(height * 0.16 + card_h)
        )
        
        # 3. Jennifer (Bottom-Left)
        jennifer_box = (
            int(width * 0.05),
            int(height * 0.53),
            int(width * 0.05 + card_w),
            int(height * 0.53 + card_h)
        )
        
        # 4. Senzaki (Bottom-Right)
        senzaki_box = (
            int(width * 0.52),
            int(height * 0.53),
            int(width * 0.52 + card_w),
            int(height * 0.53 + card_h)
        )

        crops = [
            ("card_yoga.jpg", yoga_box),
            ("card_mikuni.jpg", mikuni_box),
            ("card_jennifer.jpg", jennifer_box),
            ("card_senzaki.jpg", senzaki_box),
        ]

        for name, box in crops:
            print(f"Cropping {name} with box {box}")
            cropped = img.crop(box)
            cropped.save(f"{output_dir}/{name}", quality=95)
            print(f"Saved {name}")

    except Exception as e:
        print(f"Failed to process image: {e}")

if __name__ == "__main__":
    crop_image()
