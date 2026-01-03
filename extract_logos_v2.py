from PIL import Image
import os

def extract_logos_v2():
    asset_dir = "midas_card_demo/assets"
    # Mapping filename to output logo name
    cards = [
        ("card_mikuni_v2.jpg", "logo_mikuni_v2.jpg"),
        ("card_yoga_v2.jpg", "logo_yoga_v2.jpg"),
    ]
    
    for card_file, logo_file in cards:
        path = os.path.join(asset_dir, card_file)
        if not os.path.exists(path):
            print(f"Skipping {card_file}, not found.")
            continue
            
        try:
            img = Image.open(path)
            width, height = img.size
            print(f"Processing {card_file}: {width}x{height}")
            
            # Since these are single card images, the logo is roughly in the center.
            # Visual check of previous cards: Logo diameter is ~70-75% of height?
            # Let's use 75% of height as a safe bet for the square crop.
            
            crop_size = int(height * 0.75)
            
            cx = width // 2
            cy = height // 2
            
            left = cx - crop_size // 2
            top = cy - crop_size // 2
            right = left + crop_size
            bottom = top + crop_size
            
            # Clamp to bounds
            left = max(0, left)
            top = max(0, top)
            right = min(width, right)
            bottom = min(height, bottom)
            
            box = (left, top, right, bottom)
            print(f"Cropping logo with {box}")
            
            logo = img.crop(box)
            logo.save(os.path.join(asset_dir, logo_file), quality=95)
            print(f"Saved {logo_file}")
            
        except Exception as e:
            print(f"Error processing {card_file}: {e}")

if __name__ == "__main__":
    extract_logos_v2()
