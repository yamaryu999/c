from PIL import Image
import os

def extract_logos():
    asset_dir = "midas_card_demo/assets"
    cards = ["card_yoga.jpg", "card_mikuni.jpg", "card_jennifer.jpg", "card_senzaki.jpg"]
    
    for card_file in cards:
        path = os.path.join(asset_dir, card_file)
        if not os.path.exists(path):
            print(f"Skipping {card_file}, not found.")
            continue
            
        try:
            img = Image.open(path)
            width, height = img.size
            
            # The logo is roughly in the center right??
            # Looking at the full image:
            # The circle is centered horizontally about 50-60% across?
            # Wait, the cards in the image:
            # Yoga (Top Left): Circle is centered.
            # Mikuni (Top Right): Circle is centered.
            # Actually, let's look at the Aspect Ratio 1.586. 
            # In a credit card, the main graphical element is usually offset or central.
            # In the reference image, the big circle is quite central, slightly to the right maybe?
            
            # Let's assume center for now and crop a square based on height.
            # The card height is h. The circle diameter is roughly 70-80% of h.
            
            crop_size = int(height * 0.75)
            left = (width - crop_size) // 2
            top = (height - crop_size) // 2
            right = left + crop_size
            bottom = top + crop_size
            
            # Fine tuning based on typical composition
            # Often the circle is optically centered.
            # I'll stick to geometric center for now.
            
            box = (left, top, right, bottom)
            print(f"Cropping logo from {card_file} with {box}")
            
            logo = img.crop(box)
            
            logo_name = card_file.replace("card_", "logo_")
            logo.save(os.path.join(asset_dir, logo_name), quality=95)
            print(f"Saved {logo_name}")
            
        except Exception as e:
            print(f"Error processing {card_file}: {e}")

if __name__ == "__main__":
    extract_logos()
