import argparse
import cv2
import os


parser = argparse.ArgumentParser(
                    prog = 'img_to_mips',
                    description = 'Convert an image to MIPS code')
parser.add_argument('path', 
                    type = str,
                    help = "Path to the target image file")
                    
def read_img_vector():
    img = cv2.imread(args.path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # Only supports 512 x 256 images
    if img.shape != (256, 512, 3):
        raise Exception("Image dimension must be 512 x 256!")
    
    vec = []

    height, width, _ = img.shape
    for y in range(height):
        for x in range(width):
            vec.append(img[y, x].tolist())

    return vec

def generate_code(vec):
    code = "ANIMATION:\n"
    code += "\tla $t0, ADDR_DSPL\n"
    code += "\tlw $t0, 0($t0)\n\n"

    for pixel in vec:
        # list color to hex color
        r = hex(pixel[0]).lstrip("0x")
        g = hex(pixel[1]).lstrip("0x")
        b = hex(pixel[2]).lstrip("0x")
        color = "0x" + r + g + b
        
        # load color into $t1
        code += "\tli $t1, " + color + "\n"

        # save color to $t0 (address of display)
        code += "\tsw $t1, 0($t0)\n" 

        # to next address
        code += "\taddi $t0, $t0, 4\n"

    code += "\tjr $ra\n\n"

    return code

def save_code(code):
    img_path = args.path
    save_path = img_path.split('.')[0] + '.txt'
    with open(save_path, 'w') as f:
    # Write the string to the file
        f.write(code)

if __name__ == "__main__":
    args = parser.parse_args()
    vec = read_img_vector()
    code = generate_code(vec)
    save_code(code)
    
    






