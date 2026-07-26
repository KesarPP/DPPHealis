from PIL import Image

def remove_black_background(img_path, out_path, tolerance=25):
    img = Image.open(img_path).convert("RGBA")
    data = img.getdata()
    
    new_data = []
    for item in data:
        # If it's near black, make it transparent
        if item[0] < tolerance and item[1] < tolerance and item[2] < tolerance:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)
            
    img.putdata(new_data)
    img.save(out_path, "PNG")

remove_black_background("assets/images/todays_analysis.jpg", "assets/images/todays_analysis.png", tolerance=35)
