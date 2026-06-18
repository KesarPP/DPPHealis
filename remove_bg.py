from PIL import Image

def remove_white_bg(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    data = img.getdata()

    new_data = []
    for item in data:
        # Check if pixel is white or close to white
        # item is (R, G, B, A)
        if item[0] > 240 and item[1] > 240 and item[2] > 240:
            # Change white to transparent
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)

    img.putdata(new_data)
    img.save(output_path, "PNG")

if __name__ == "__main__":
    remove_white_bg(
        "C:/users/thora/.gemini/antigravity-ide/brain/738ac016-1195-4944-9492-6a3fddcd0f3e/white_bg_trophy_1781516832161.png",
        "c:/healis_work/DPPHealis/assets/images/custom_trophy.png"
    )
