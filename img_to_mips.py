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

    # Only supports 32 x 16 images
    if img.shape != (16, 32, 3):
        raise Exception("Image dimension must be 32 x 16!")
    
    vec = []

    height, width, _ = img.shape
    for y in range(height):
        for x in range(width):
            vec.append(img[y, x].tolist())

    return vec

def generate_small_img_code(vec):
    """ 
    Generate code to display 256 x 128 image on 512 x 256 screen.

    Vertical gap = 64
    Horizontal gap = 128

    Top blank space = 64 * 128 = 8192 pixels = 32768 increase in memory address
    First row space = 128 pixels = 512 increase in memory address
    Every 256 pixels space = 128 * 2 pixels = 256 pixels = 1024 increase in memory address
    
    Before displaying, add 128 pixels of blank space

     --------------------------------------------------------------
    |                  -----  8192 pixels  -----                   |
    |             ------------------------------------             |
    |            |                                    |            | 
    |            |                                    |            |  
    |            |                                    |            |  
    |            |                                    |            |  
    | 128 pixels |                                    | 128 pixels | 
    |            |                                    |            |  
    |            |                                    |            |  
    |            |                                    |            |  
    |            |                                    |            |  
    |            |                                    |            |
    |             ------------------------------------             |
    |                  -----  8192 pixels  -----                   |
     --------------------------------------------------------------
    
    """

    code = "ANIMATION:\n"
    code += "\tla $t0, ADDR_DSPL\n"
    code += "\taddi $t0, $t0, 32768\n"
    code += "\taddi $t0, $t0, 512\n"
    code += "\tlw $t0, 0($t0)\n\n"

    row_count = 0

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

        row_count += 1

        # Every 256 pixels
        if row_count == 256:
            # to next address
            code += "\taddi $t0, $t0, 1024\n"
        else:
            # to next address
            code += "\taddi $t0, $t0, 4\n"

    code += "\tjr $ra\n\n"

    return code

def generate_low_res_img_code(vec):
    """ 
    Display a 32 x 16 image
    """
    
    code = "ANIMATION:\n"

    code += "\taddi $sp, $sp, -4\n"
    code += "\tsw $ra, 0($sp)\n"

    x = 0
    y = 0

    for pixel in vec:

        converted_x = str(x * 4)
        converted_y = str(y * 4)

        # load x to $a0
        code += "\tli $a0, " + converted_x + "\n"

        # load y to $a1
        code += "\tli $a1, " + converted_y + "\n"
        
        # list color to hex color
        r = hex(pixel[0]).lstrip("0x")
        g = hex(pixel[1]).lstrip("0x")
        b = hex(pixel[2]).lstrip("0x")
        color = "0x" + r + g + b
        
        # load color into $a2
        code += "\tli $a2, " + color + "\n"

        # call draw square
        code += "\tjal DRAW_SQUARE\n"

        x += 1

        # Every 32 pixels
        if x == 32:
            # to next address
            x = 0
            y += 1

    code += "\tlw $ra, 0($sp)\n"
    code += "\taddi $sp, $sp, 4\n"
    code += "\tjr $ra"
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
    code = generate_low_res_img_code(vec)
    save_code(code)
    
    






