################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       4
# - Unit height in pixels:      4
# - Display width in pixels:    512
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
# - Unit number on row:		128
# - Unit nubmer on column: 	64
##############################################################################
# $s0- the x coordinate of the paddle
# $s1- the y coofinate of the paddle
# $s2- the x coordinate of the ball
# $s3- the y coofinate of the ball
# $s4- dx of the ball
# $s5- dy of the ball

    .data
COLOR: 
	.word 0xcccccc # Grey
	.word 0xf0a7ac # pink
	.word 0xd0e0e3 # light grey
	.word 0x88e904 # light green
	.word 0xd0e0e3 
	.word 0xf0a7ac
	.word 0xfff68f # color of paddle
	.word 0xffffff
	.word 0x000000

##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
# Initialize the game
 
# DRAW_LINE_IN_ROWS use to initialize the top row walls
# Data of the top wall rows: 4 UNIT high
	jal DRAW_UPPER_WALL
 
# Preperation for drawing the LEFT and RIGHT column walls
	li $t0, 0
	li $t1, 64
	la $a0, ADDR_DSPL	
	lw $a0, 0($a0)	#$a0 stores the first piexl address
	li $t7, 0

# $t5 + 1 indicate how many columns wall to draw	
	li $t4, 0
	li $t5, 3

    	jal DRAW_SIDE_WALLS
	
# DRAW the brick in the middle
SETUP_DRAW_BRICK:
	# Set $t9 to the location of the first y-coordinate of the bricks
	addi $t9, $0, 16 
	
	li $a0, 12		# x coordinate of the first line brick
	addi $a1, $t9, 0	# y coordinate of the first line brick
	la $a2, COLOR		
	lw $a2, 4($a2)		# color of the first brick
	
	jal DRAW_BRICK
	
	addi $t9, $t9, 2	# Draw the next line
	
	li $a0, 12	 	# x coordinate second
	addi $a1, $t9, 0	# y coordinate
	la $a2, COLOR	 	# color of the brick
	lw $a2, 8($a2)
	
	jal DRAW_BRICK
	
	addi $t9, $t9, 2
	
	li $a0, 12		# x coordinate third
	addi $a1, $t9, 0	# y coordinate
	la $a2, COLOR		# color of the brick
	lw $a2, 12($a2)
	
	jal DRAW_BRICK
	
	addi $t9, $t9, 2

	li $a0, 12		# x coordinate of the fourth
	addi $a1, $t9, 0	# y coordinate	fourth
	la $a2, COLOR		# color of the brick
	lw $a2, 16($a2)
	jal DRAW_BRICK
	
	addi $t9, $t9, 2
	
	li $a0, 12		# x coordinate fifth
	addi $a1, $t9, 0	# y coordinate fifth
	la $a2, COLOR		# color of the brick
	lw $a2, 20($a2)
	
	jal DRAW_BRICK

INIT_PADDLE:
	li $s0, 56	# x-coordinate of the paddle
	li $s1, 63	# y-coodinate of the paddle
	jal DRAW_PADDLE
	
INIT_BALL:
	li $s2, 64
	li $s3, 60
	
	li $a0, 0
	li $a1, 0
	add $a0, $a0, $s2
	add $a1, $a1, $s3
	jal DRAW_BALL
	li $s2, 64
	li $s3, 60
	
	j game_loop	


# DRAW_PADDLE()
# DRAW a 16 x 1 paddle
DRAW_PADDLE:
	la $t1, COLOR
	lw $t1, 24($t1)	# $t1, color black

	la $t0, ADDR_DSPL
	lw $t0, 0($t0)	
	
	li $t5, 0	# $t5, Inner loop of Draw Row
	li $t6, 15	# $t6 + 1 indicate the lenght of the paddle
	
	# set t2, t3 to x, y location of paddle
	addi $t2, $s0, 0
	addi $t3, $s1, 0
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t0, $t0, $t2
	add $t0, $t0, $t3
DRAW_PADDLE_LOOP:
	slt $t7, $t5, $t6 # $t7 store the result for $t0 < $t1
	beq $t7, $0, END_DRAW_PADDLE
		# LOOP BODY
		sw $t1, 0($t0)	# put color to the address
		addi $t0, $t0, 4 # go to the next unit
	addi $t5, $t5, 1 # i = i + 1
	j DRAW_PADDLE_LOOP
END_DRAW_PADDLE:
	jr $ra	
	

# DELETE_PADDLE()
# Delete a 16 x 1 paddle by painting it black
DELETE_PADDLE:
	la $t1, COLOR
	lw $t1, 32($t1)	# $t1, color black

	la $t0, ADDR_DSPL
	lw $t0, 0($t0)	
	
	li $t5, 0	# $t5, Inner loop of Draw Row
	li $t6, 15	# $t6 + 1 indicate the lenght of the paddle
	
	# set t2, t3 to x, y location of paddle
	addi $t2, $s0, 0
	addi $t3, $s1, 0
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t0, $t0, $t2
	add $t0, $t0, $t3
DELETE_PADDLE_LOOP:
	slt $t7, $t5, $t6 # $t7 store the result for $t0 < $t1
	beq $t7, $0, END_DELETE_PADDLE
		# LOOP BODY
		sw $t1, 0($t0)	# put color to the address
		addi $t0, $t0, 4 # go to the next unit
	addi $t5, $t5, 1 # i = i + 1
	j DELETE_PADDLE_LOOP
END_DELETE_PADDLE:
	jr $ra	


# DRAW_BALL(x, y)
# Draws a 1 x 1 ball with white color		
DRAW_BALL:
	la $t1, COLOR
	lw $t1, 28($t1)
	
	la $t0, ADDR_DSPL
	lw $t0, 0($t0)	
	
	
	sll $t2, $a0, 2
	sll $t3, $a1, 9
	add $t0, $t0, $t2
	add $t0, $t0, $t3
	
	sw $t1, 0($t0) 	
	jr $ra
		

# DELETE_BALL(x, y)
# Deletes a ball by painting it black			
DELETE_BALL:
	la $t1, COLOR
	lw $t1, 32($t1)
	
	la $t0, ADDR_DSPL
	lw $t0, 0($t0)	
	
	
	sll $t2, $a0, 2
	sll $t3, $a1, 9
	add $t0, $t0, $t2
	add $t0, $t0, $t3
	
	sw $t1, 0($t0) 
		
	jr $ra		

																
# DRAW_UPPER_WALL()
# Draws 4 rows of gray lines as upper wall
DRAW_UPPER_WALL:
	la $t7, ADDR_DSPL	
	lw $t7, 0($t7)	#$a0 stores the first piexl address
	
	li $t0, 0   # Track which unit are we right now, i
	li $t1, 128 # Unit count of the row 
	la $s0, COLOR
	lw $s0, 0($s0) # s0 stores the grey color which indicates the wall color. 
	
	li $t4, 0 # Write 5 row
	li $t5, 3 # Track the outer loop j
DRAW_LINE_IN_ROW:
	slt $t3, $t0, $t1 # $t3 store the result for $t0 < $t1
	beq $t3, $0, END_DRAW_ROW_LINE # If draw done return to the END_DRAW_ROW_LINE
		# LOOP BODY
		sw $s0, 0($t7)	# put grey on the address
		addi $t7, $t7, 4 # go to the next unit
	addi $t0, $t0, 1 # i = i + 1
	b DRAW_LINE_IN_ROW
END_DRAW_ROW_LINE:
	li $t0, 0   # Track which unit are we right now, i	
	slt $t6, $t4, $t5
	beq $t6, $0, END_DRAW_UPPER_WALL	
		addi $t4, $t4, 1
		j DRAW_LINE_IN_ROW	
END_DRAW_UPPER_WALL: 
	jr $ra										

			
# DRAW_SIDE_WALLS()
# Draws two walls on the left and right side of screen												
DRAW_SIDE_WALLS:
DRAW_LINE_IN_LEFT_AND_RIGHT_COLUMN:
	slt $t3, $t0, $t1 # $t3 store the result for $t0 < $t1
	beq $t3, $0, END_DRAW_LEFT_AND_RIGHT_COLUMN # If draw done return to the END_DRAW_ROW_LINE
		# LOOP BODY
		sw $s0, 0($a0)	# put grey on the address
		sw $s0, 496($a0)
		addi $a0, $a0, 512 # go to the next unit
	addi $t0, $t0, 1 # i = i + 1
	b DRAW_LINE_IN_LEFT_AND_RIGHT_COLUMN
	
END_DRAW_LEFT_AND_RIGHT_COLUMN:
	la $a0, ADDR_DSPL	
	lw $a0, 0($a0)	#$a0 stores the second piexl address
	addi $t7, $t7, 1
	sll $t8, $t7 2
	add $a0, $a0, $t8
	li $t0, 0
	slt $t6, $t4, $t5
	beq $t6, $0, END_DRAW_SIDE_WALLS
		addi $t4, $t4, 1
		j DRAW_LINE_IN_LEFT_AND_RIGHT_COLUMN
END_DRAW_SIDE_WALLS:
	jr $ra
	
	
# DRAW_BRICK(x of top left corner, y of top left corner, color)
# Draws a line of bricks using the give color
DRAW_BRICK:
	la $t0, ADDR_DSPL # $t0 is the first address of the brick
	lw $t0, 0($t0)	
	sll $a0, $a0, 2
	sll $a1, $a1, 9
	add $t0, $t0, $a0
	add $t0, $t0, $a1
		li $t3, 0	#$t3, Outer loop of Draw Row i
	li $t4, 1	#$t4, The termination of Outer draw row brick
	
	li $t5, 0	# $t5, Inner loop of Draw Row
	li $t6, 104	# $t6, the termination of inner draw	
DRAW_LINE_BRICK:
	slt $t7, $t5, $t6 # $t3 store the result for $t0 < $t1
	beq $t7, $0, END_DRAW_LINE_BRICK # If draw done return to the END_DRAW_ROW_LINE
		# LOOP BODY
		sw $a2, 0($t0)	# put color to the address
		addi $t0, $t0, 4 # go to the next unit
	addi $t5, $t5, 1 # i = i + 1
	b DRAW_LINE_BRICK
END_DRAW_LINE_BRICK:
	addi $t0, $t0, 96
	li $t5, 0
	slt $t8, $t3, $t4
	beq $t8, $0, END_DRAW_BRICK
		addi $t3, $t3, 1
		j DRAW_LINE_BRICK
END_DRAW_BRICK:		
	jr $ra
	
# MOVE_PADDLE_LEFT()
# Moves paddle left one pixel
MOVE_PADDLE_LEFT:
	addi $sp, $sp, -4
	sw $ra, 0($sp)	
	
	jal DELETE_PADDLE
	
	addi $s0, $s0, -1
	jal DRAW_PADDLE
	
END_MOVE_PADDLE_LEFT:
	lw $ra, 0($sp)
	addi $sp, $sp, 4 
	jr $ra
	
# MOVE_PADDLE_RIGHT()
# Moves paddle right one pixel
MOVE_PADDLE_RIGHT:
	addi $sp, $sp, -4
	sw $ra, 0($sp)	
	
	jal DELETE_PADDLE
	
	addi $s0, $s0, 1
	jal DRAW_PADDLE
	
END_MOVE_PADDLE_RIGHT:
	lw $ra, 0($sp)
	addi $sp, $sp, 4 
	jr $ra

	
game_loop:
# 1a. Check if key has been pressed
# 1b. Check which key has been pressed
# 2a. Check for collisions
# 2b. Update locations (paddle, ball)
# 3. Draw the screen
# 4. Sleep
# 5. Go back to 1
	
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
	lw $t8, 0($t0)                  # Load first word from keyboard
	beq $t8, 1, on_keyboard_input   # If first word 1, key is pressed
	b game_loop


on_keyboard_input:                  	# A key is pressed
	lw $a0, 4($t0)                  # Load second word from keyboard
	
	beq $a0, 0x71, END    		# IF q pressed, END
	
IF_A_PRESSED:
	bne $a0, 0x61, IF_D_PRESSED     # IF a didn't get pressed, go to next IF
	jal MOVE_PADDLE_LEFT

IF_D_PRESSED:
	bne $a0, 0x64, IF_NO_CHANGE 	# IF d didn't get pressed, go to next section
	jal MOVE_PADDLE_RIGHT

IF_NO_CHANGE:
	b game_loop
 
END:	
	li $v0, 10			# Quit gracefully
	syscall
