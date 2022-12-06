################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Eric Xue, 1007655636
# Student 2: Xiling Zhao, 1007834532
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
# $s1- Store the total breaks time
# $s2- the x coordinate of the ball
# $s3- the y coofinate of the ball
# $s4- the x direction of the ball (1 = left, -1 = right)
# $s5- the y direction of the ball (1 = down, -1 = up)
# $s6 - ball counter Using to adjust the speed of the ball. 
# $s7 - Store the GameState
##############################################################################
# Stack
# 0		(the speed of the ball)
# -4	(the lives that user have)


    .data
COLOR: 
	.word 0x8c92ac # Color of the Wall- 	Dark Grey
	.word 0xcaa9ed # Color of 1st brick- 	pink 
	.word 0xd0e0e3 # color of 2th brick- 	light grey 
	.word 0x88e904 # Color of 3rd brick-	light green 
	.word 0xb2ffff # Color of 4th brick-	light blue
	.word 0x9722a2 # color of 5th brick-	green and grey
	.word 0xfff68f # color of paddle-		Bright yello
	.word 0xffffff # Color of Ball-			white
	.word 0x000000 # Color of backGroud-	black
	.word 0x6fa8e1 # First break color- 	Blue
	.word 0xdd5fa9 # Second break color -	Pink
	.word 0x9722a2 # Third break color - 	purple
	.word 0xFF0000 # Lives remaining - 		Grey-blue

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
##############################################################################################################################
# Initialize the game

###############################################################
## Set Up Walls

# Initial the state to start
	li $s7, 1 
# Initial the lives of player
	# li $s8, 3
# Initial the number of breaks
	li $s1, 0
# Initialize the speed rate of the ball
	li $t0, 1
	addi $sp, $sp, -4	#
	sw $t0, 0($sp)

	
	

# DRAW_LINE_IN_ROWS use to initialize the top row walls
# Data of the top wall rows: 4 UNIT high
	jal DRAW_UPPER_WALL

# Initialize the lives user have
	li $t0, 3
	sw $t0, 4($sp)

	addi $a0, $t0, 0

	la $a1, COLOR
	lw $a1, 48($a1)

	jal DRAW_LIVES_DISPLAY
 
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

############################################################### 


############################################################### 
# Set Up Brick	
# DRAW the brick in the middle
SETUP_DRAW_BRICK:
	# Set $t9 to the location of the first y-coordinate of the bricks
	addi $t9, $0, 16 
	
	li $a0, 12		# x coordinate of the first line brick
	addi $a1, $t9, 0	# y coordinate of the first line brick
	la $a2, COLOR		
	lw $a2, 4($a2)		# color of the first brick
	
	jal SETUP_ONE_BRICKS
	
	addi $t9, $t9, 2	# Draw the next line
	
	li $a0, 12	 	# x coordinate second
	addi $a1, $t9, 0	# y coordinate
	la $a2, COLOR	 	# color of the brick
	lw $a2, 8($a2)
	
	jal SETUP_ONE_BRICKS
	
	addi $t9, $t9, 2
	
	li $a0, 12		# x coordinate third
	addi $a1, $t9, 0	# y coordinate
	la $a2, COLOR		# color of the brick
	lw $a2, 12($a2)
	
	jal SETUP_ONE_BRICKS
	
	addi $t9, $t9, 2

	li $a0, 12		# x coordinate of the fourth
	addi $a1, $t9, 0	# y coordinate	fourth
	la $a2, COLOR		# color of the brick
	lw $a2, 16($a2)
	jal SETUP_ONE_BRICKS
	
	addi $t9, $t9, 2
	
	li $a0, 12		# x coordinate fifth
	addi $a1, $t9, 0	# y coordinate fifth
	la $a2, COLOR		# color of the brick
	lw $a2, 20($a2)
	
	jal SETUP_ONE_BRICKS


############################################################### 

###############################################################
# Randomly make a Unbreakable brick
	li $v0, 42
	li $a1, 7
	syscall

	li $t0, 0
	add $t0, $t0, $a0 	# $a0 stores the random int from 0 to 7
	sll $t0, $t0, 3		# $t0 stands how many x coordinate to move
	addi $t0, $t0, 12 	# $t0 now is the coordinate of brick to draw

	li $v0, 42
	li $a1, 4
	syscall

	li $t1, 0
	add $t1, $t1, $a0 	# $a0 stores the random int from 0 to 7
	sll $t1, $t1, 1		# $t0 stands how many x coordinate to move
	addi $t1, $t1, 16 	# $t0 now is the coordinate of brick to draw

	li $a0, 0
	li $a1, 0

	addi $a0, $t0, 0
	addi $a1, $t1, 0

	la $a2, COLOR
	lw $a2, 0($a2)

	jal DRAW_BRICK_WITH_COLOR

###############################################################
# Debug purpose
	# addi $a0, $a0, 8

	# la $a2, COLOR
	# lw $a2, 0($a2)

	# jal DRAW_BRICK_WITH_COLOR

	# addi $a0, $a0, 16

	# la $a2, COLOR
	# lw $a2, 0($a2)

	# jal DRAW_BRICK_WITH_COLOR

	# addi $a0, $a0, 24

	# la $a2, COLOR
	# lw $a2, 0($a2)

	# jal DRAW_BRICK_WITH_COLOR

	# addi $a1, $a1, 8

	# la $a2, COLOR
	# lw $a2, 0($a2)

	# jal DRAW_BRICK_WITH_COLOR

	
	# li $a0, 12		# x coordinate of the first line brick
	# la $a2, COLOR		
	# lw $a2, 0($a2)		# color of the first brick
	
	# jal SETUP_ONE_BRICKS

###############################################################


###############################################################

jal INIT_PADDLE
jal INIT_BALL
j game_loop

############################################################### 
# Set Up Paddle
INIT_PADDLE:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $s0, 56	# x-coordinate of the paddle
	# li $s1, 63	# y-coodinate of the paddle
	jal DRAW_PADDLE

	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra
############################################################### 

############################################################### 
# Set Up Ball
INIT_BALL:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $s2, 64
	li $s3, 60
	li $s4, 1
	li $s5, 1 #modified
	li $s6, 0

	jal DRAW_BALL
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
############################################################### 

##############################################################################################################################






##############################################################################################################################
# Function
##############################################################################################################################

############################################################### 
### Paddle Related
# DRAW_PADDLE()
# DRAW a 16 x 1 paddle
DRAW_PADDLE:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t1, COLOR
	lw $t1, 24($t1)	# $t1, color black

	la $t0, ADDR_DSPL
	lw $t0, 0($t0)	
	
	li $t5, 0	# $t5, Inner loop of Draw Row
	li $t6, 15	# $t6 + 1 indicate the lenght of the paddle
	
	# set t2, t3 to x, y location of paddle
	addi $t2, $s0, 0
	# addi $t3, $s1, 0
	li $t3, 63
	
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
	lw $ra, 0($sp)
	addi $sp, $sp, 4

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
	# addi $t3, $s1, 0
	li $t3, 63
	
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


# MOVE_PADDLE_LEFT()
# Moves paddle left one pixel
MOVE_PADDLE_LEFT:
	addi $sp, $sp, -16	#
	sw $ra, 12($sp)	
	sw $t0, 8($sp)
	sw $t1, 4($sp)
	sw $t2, 0($sp)
	
	li $t0, 0  	# to store the boolean value
	li $t1, 0
	li $t2, 3	# check the boundary
	
	addi $t1, $s0, -1
	slt $t0, $t2, $t1
	beq $t0, $0, END_MOVE_PADDLE_LEFT
	
	jal DELETE_PADDLE
	
	addi $s0, $s0, -1 
	jal DRAW_PADDLE
	
END_MOVE_PADDLE_LEFT:
	lw $t2, 0($sp)	
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	
# MOVE_PADDLE_RIGHT()
# Moves paddle right one pixel
MOVE_PADDLE_RIGHT:
	addi $sp, $sp, -16	#
	sw $ra, 12($sp)	
	sw $t0, 8($sp)
	sw $t1, 4($sp)
	sw $t2, 0($sp)
	
	li $t0, 0  	# to store the boolean value
	li $t1, 0
	li $t2, 110	# check the boundary
	
	addi $t1, $s0, 1
	slt $t0, $t1, $t2
	beq $t0, $0, END_MOVE_PADDLE_RIGHT
	
	jal DELETE_PADDLE
	
	addi $s0, $s0, 1
	jal DRAW_PADDLE
	
END_MOVE_PADDLE_RIGHT:
	lw $t2, 0($sp)	
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra

############################################################### 

############################################################### 
## Ball Related

# DRAW_BALL()
# Draws a 1 x 1 ball with white color		
DRAW_BALL:
	
	la $t1, COLOR
	lw $t1, 28($t1)
	
	la $t0, ADDR_DSPL
	lw $t0, 0($t0)	
	
	
	sll $t2, $s2, 2
	sll $t3, $s3, 9
	add $t0, $t0, $t2
	add $t0, $t0, $t3
	
	sw $t1, 0($t0) 	


	jr $ra
		

# DELETE_BALL()
# Deletes a ball by painting it black			
DELETE_BALL:
	# addi $sp, $sp, -4	#
	# sw $ra, 0($sp)	

	la $t1, COLOR
	lw $t1, 32($t1)
	
	la $t0, ADDR_DSPL
	lw $t0, 0($t0)	
	
	sll $t2, $s2, 2
	sll $t3, $s3, 9
	add $t0, $t0, $t2
	add $t0, $t0, $t3
	
	sw $t1, 0($t0) 
	
	# lw $ra, 0($sp)
	# addi $sp, $sp, 4 

	jr $ra


# MOVE_BALL()
# Moves ball once based on its direction
MOVE_BALL:
	addi $sp, $sp, -4	#
	sw $ra, 0($sp)	


	jal DELETE_BALL
	
	
	add $s2, $s2, $s4	# add x direction to x coordinate
	add $s3, $s3, $s5	# add y direction to y coordinate
	jal DRAW_BALL
	
END_MOVE_BALL:
	lw $ra, 0($sp)
	addi $sp, $sp, 4 
	jr $ra
############################################################### 

############################################################### 
## Wall Related


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
############################################################### 




############################################################### 
## Brick Related

# SETUP_ONE_BRICKS(x of top left corner, y of top left corner, color)
# Draws a line of bricks using the give color
SETUP_ONE_BRICKS:
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
	beq $t8, $0, END_SETUP_ONE_BRICKS
		addi $t3, $t3, 1
		j DRAW_LINE_BRICK
END_SETUP_ONE_BRICKS:		
	jr $ra

############################################################### 

###############################################################
# DRAW_LIVES_DISPLAY($a0)
# $a0 stores how many to draw lives left for user
# $a1 stores the color to draw here 
DRAW_LIVES_DISPLAY:
	la $t0, ADDR_DSPL
	lw $t0, 0($t0)

	li $t1, 4
	li $t2, 2

	sll $t1, $t1, 2
	sll $t2, $t2, 9
	add $t0, $t0, $t1
	add $t0, $t0, $t2

	li $t3, 0
	li $t4, 3

	li $t5, 0

	
DRAW_LIVES_DISPLAY_INNER_LOOP:
	slt $t6, $t3, $t4
	beq $t6, $0, DRAW_LIVES_DISPLAY_OUTTER_LOOP
		sw $a1, 0($t0)
		addi $t0, $t0, 4
	addi $t3, $t3, 1
	
	j DRAW_LIVES_DISPLAY_INNER_LOOP

DRAW_LIVES_DISPLAY_OUTTER_LOOP:
	li $t3, 0
	slt $t8, $t5, $a0
	beq $t8, $0, END_DRAW_LIVES_DISPLAY
		addi $t5, $t5, 1
		j DRAW_LIVES_DISPLAY_INNER_LOOP

END_DRAW_LIVES_DISPLAY:
	jr $ra



###############################################################
	
	
###############################################################
## Collision Check	

# CHECK_BALL_COLLISION()
# Checks the collision of ball and change its direction (will be reflected in the next screen update)
CHECK_BALL_COLLISION:
	la $t0, ADDR_DSPL
	lw $t0, 0($t0)	
	
	addi $sp, $sp, -4	#
	sw $ra, 0($sp)

	
CHECK_TOP:
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t4, $t0, 0
	
	addi $t3, $t3, -1
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t4, $t4, $t2
	add $t4, $t4, $t3		# $t4 is the pixel address above ball
	lw $t4, 0($t4)			# $t4 is the color of pixel above ball
	
	la $t5, COLOR
	lw $t5, 0($t5)

	beq $t4, 0x000000, CHECK_BOTTOM		# If top is empty (black), check bottom
	beq $t4, $t5, CHECK_WALL_CORNOR_TOP_LEFT

# Collide on Brick on top

# Check the right of the Collision to see if it is the corner case
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t6, $t0, 0
	
	addi $t2, $t2, -1
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t6, $t6, $t2
	add $t6, $t6, $t3		# $t4 is the pixel address above ball
	lw $t6, 0($t6)			# $t4 is the color of pixel left ball

	li $a0, 0
	li $a1, 0

	addi $a0, $s2, 0
	addi $a1, $s3, -1

	bne $t6, 0x000000, COLLIDE_BRICK_INVERSE_X_Y

	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t6, $t0, 0
	
	addi $t2, $t2, 1
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t6, $t6, $t2
	add $t6, $t6, $t3		# $t4 is the pixel address above ball
	lw $t6, 0($t6)			# $t4 is the color of pixel left ball

	li $a0, 0
	li $a1, 0

	addi $a0, $s2, 0
	addi $a1, $s3,-1

	bne $t6, 0x000000, COLLIDE_BRICK_INVERSE_X_Y
###############################################################

# Normal case, just the top collide with the brick

	mul $s5, $s5, -1

	li $a0, 0
	li $a1, 0

	add $a0, $a0, $s2
	add $a1, $a1, $s3
	addi $a1, $a1, -1	# Top Pixel of the ball

	la $t5, COLOR
	lw $t5, 36($t5)
	beq $t4, $t5,SECOND_BREAK

	la $t5, COLOR
	lw $t5, 40($t5)
	beq $t4, $t5,THIRD_BREAK

	la $t5, COLOR
	lw $t5, 44($t5)
	beq $t4, $t5,FINAL_BREAK

# First Break
	la $a2, COLOR
	lw $a2, 36($a2)
	
	jal DRAW_BRICK_WITH_COLOR
	
	
	j END_CHECK_COLLISION
	
	
CHECK_BOTTOM:
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t4, $t0, 0
	
	addi $t3, $t3, 1
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t4, $t4, $t2
	add $t4, $t4, $t3		# $t4 is the pixel address below ball
	lw $t4, 0($t4)			# $t4 is the color of pixel below ball
	
	la $t5, COLOR
	lw $t5, 0($t5)
	
	beq $t4, 0x000000, CHECK_LEFT			# If bottom is empty (black), check left
	beq $t4, $t5, COLLIDE_WALL_INV_Y	# If bottom touch the unbreakable
	beq $t4, 0xfff68f, COLLIDE_PADDLE

	# Check the right of the Collision to see if it is the corner case
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t6, $t0, 0
	
	addi $t2, $t2, -1
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t6, $t6, $t2
	add $t6, $t6, $t3		# $t4 is the pixel address above ball
	lw $t6, 0($t6)			# $t4 is the color of pixel left ball

	li $a0, 0
	li $a1, 0

	addi $a0, $s2, 0
	addi $a1, $s3, 1
	
	bne $t6, 0x000000, COLLIDE_BRICK_INVERSE_X_Y

	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t6, $t0, 0
	
	addi $t2, $t2, 1
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t6, $t6, $t2
	add $t6, $t6, $t3		# $t4 is the pixel address above ball
	lw $t6, 0($t6)			# $t4 is the color of pixel left ball

	li $a0, 0
	li $a1, 0

	addi $a0, $s2, 0
	addi $a1, $s3, 1

	bne $t6, 0x000000, COLLIDE_BRICK_INVERSE_X_Y

###############################################################

# Normal case, just the bottom collide with the brick

	# Collide on Brick
	mul $s5, $s5, -1

	li $a0, 0
	li $a1, 0

	add $a0, $a0, $s2
	add $a1, $a1, $s3
	addi $a1, $a1, 1	# Buttom Pixel of the ball

	la $t5, COLOR
	lw $t5, 36($t5)
	beq $t4, $t5,SECOND_BREAK

	la $t5, COLOR
	lw $t5, 40($t5)
	beq $t4, $t5,THIRD_BREAK

	la $t5, COLOR
	lw $t5, 44($t5)
	beq $t4, $t5,FINAL_BREAK

# First Break
	la $a2, COLOR
	lw $a2, 36($a2)
	
	jal DRAW_BRICK_WITH_COLOR
	
	j END_CHECK_COLLISION
	
	
CHECK_LEFT:
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t4, $t0, 0

	addi $t2, $t2, -1
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t4, $t4, $t2
	add $t4, $t4, $t3		# $t4 is the pixel address to the left of ball
	lw $t4, 0($t4)			# $t4 is the color of pixel to the left of ball
	
	la $t5, COLOR
	lw $t5, 0($t5)

	beq $t4, 0x000000, CHECK_RIGHT	# If left is empty (black), check right
	beq $t4, $t5, COLLIDE_WALL_INV_X
	beq $t4, 0xfff68f, END_WITH_LOOSE # In this case, the ball is on the left of the paddle, Game END
	
	
	
	# Collide on Brick
	mul $s4, $s4, -1

	li $a0, 0
	li $a1, 0

	add $a0, $a0, $s2
	add $a1, $a1, $s3
	addi $a0, $a0, -1	# Left Pixel of the ball

	la $t5, COLOR
	lw $t5, 36($t5)
	beq $t4, $t5,SECOND_BREAK

	la $t5, COLOR
	lw $t5, 40($t5)
	beq $t4, $t5,THIRD_BREAK

	la $t5, COLOR
	lw $t5, 44($t5)
	beq $t4, $t5,FINAL_BREAK

# First Break
	la $a2, COLOR
	lw $a2, 36($a2)
	
	jal DRAW_BRICK_WITH_COLOR
	
	
	j END_CHECK_COLLISION
	
	
	
CHECK_RIGHT:
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t4, $t0, 0

	addi $t2, $t2, 1
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t4, $t4, $t2
	add $t4, $t4, $t3			# $t4 is the pixel address to the right of ball
	lw $t4, 0($t4)				# $t4 is the color of pixel to the right of ball
	
	la $t5, COLOR
	lw $t5, 0($t5)

	beq $t4, 0x000000,	CHECK_TOP_LEFT	# If right is empty (black), end
	beq $t4, $t5, COLLIDE_WALL_INV_X
	
	# Collide on Brick
	mul $s4, $s4, -1
	
	li $a0, 0
	li $a1, 0

	add $a0, $a0, $s2
	add $a1, $a1, $s3
	addi $a0, $a0, 1	# Right Pixel of the ball

	la $t5, COLOR
	lw $t5, 36($t5)
	beq $t4, $t5,SECOND_BREAK

	la $t5, COLOR
	lw $t5, 40($t5)
	beq $t4, $t5,THIRD_BREAK

	la $t5, COLOR
	lw $t5, 44($t5)
	beq $t4, $t5,FINAL_BREAK

# First Break
	la $a2, COLOR
	lw $a2, 36($a2)
	
	jal DRAW_BRICK_WITH_COLOR
	
	
	j END_CHECK_COLLISION


CHECK_TOP_LEFT:
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t4, $t0, 0
	
	addi $t2, $t2, -1 	# move one pixel on left
	addi $t3, $t3, -1	# move one pixel on top
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t4, $t4, $t2
	add $t4, $t4, $t3			# $t4 is the pixel address to the top_left of the ball
	lw $t4, 0($t4)				# $t4 is the color of pixel to the top_left of ball

	beq $t4, 0x000000, CHECK_TOP_RIGHT	# If right is empty (black), end

	la $t5, COLOR
	lw $t5, 0($t5)
	beq $t4, $t5, COLLIDE_WALL_INV_X_Y
	
	# Collide on Brick
	mul $s4, $s4, -1
	mul $s5, $s5, -1
	
	li $a0, 0
	li $a1, 0

	add $a0, $a0, $s2
	add $a1, $a1, $s3
	addi $a0, $a0, -1	# Right Pixel of the ball
	addi $a1, $a1, -1

	la $t5, COLOR
	lw $t5, 36($t5)
	beq $t4, $t5,SECOND_BREAK

	la $t5, COLOR
	lw $t5, 40($t5)
	beq $t4, $t5,THIRD_BREAK

	la $t5, COLOR
	lw $t5, 44($t5)
	beq $t4, $t5,FINAL_BREAK

	# First Break
	la $a2, COLOR
	lw $a2, 36($a2) #modified
	
	jal DRAW_BRICK_WITH_COLOR
	
	
	j END_CHECK_COLLISION


CHECK_TOP_RIGHT:
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t4, $t0, 0

	addi $t2, $t2, 1 	# move one pixel on right
	addi $t3, $t3, -1	# move one pixel to top
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t4, $t4, $t2
	add $t4, $t4, $t3			# $t4 is the pixel address to the top_left of the ball
	lw $t4, 0($t4)				# $t4 is the color of pixel to the top_left of ball

	beq $t4, 0x000000, CHECK_BOTTOM_LEFT	# If right is empty (black), end


	la $t5, COLOR
	lw $t5, 0($t5)
	beq $t4, $t5, COLLIDE_WALL_INV_X_Y

	# Collide on Brick
	mul $s4, $s4, 1
	mul $s5, $s5, -1
	
	li $a0, 0
	li $a1, 0

	add $a0, $a0, $s2
	add $a1, $a1, $s3
	addi $a0, $a0, 1	# Right Pixel of the ball
	addi $a1, $a1, -1

	la $t5, COLOR
	lw $t5, 36($t5)
	beq $t4, $t5,SECOND_BREAK

	la $t5, COLOR
	lw $t5, 40($t5)
	beq $t4, $t5,THIRD_BREAK

	la $t5, COLOR
	lw $t5, 44($t5)
	beq $t4, $t5,FINAL_BREAK

	# First Break
	la $a2, COLOR
	lw $a2, 36($a2) # modified
	
	jal DRAW_BRICK_WITH_COLOR
	
	
	j END_CHECK_COLLISION

CHECK_BOTTOM_LEFT:
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t4, $t0, 0

	addi $t2, $t2, -1 	# move one pixel on left
	addi $t3, $t3, 1	# move one pixel to buttom
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t4, $t4, $t2
	add $t4, $t4, $t3			# $t4 is the pixel address to the top_left of the ball
	lw $t4, 0($t4)				# $t4 is the color of pixel to the top_left of ball

	beq $t4, 0x000000, CHECK_BOTTOM_RIGHT	# If right is empty (black), end
	beq $t4, 0xfff68f, COLLIDE_PADDLE_INV_X_Y  # If bottom is paddle, then switch

	la $t5, COLOR
	lw $t5, 0($t5)
	beq $t4, $t5, COLLIDE_WALL_INV_X_Y

	# Collide on Brick
	mul $s4, $s4, -1
	mul $s5, $s5, -1
	
	li $a0, 0
	li $a1, 0

	add $a0, $a0, $s2
	add $a1, $a1, $s3
	addi $a0, $a0, -1	# Right Pixel of the ball
	addi $a1, $a1, 1

	la $t5, COLOR
	lw $t5, 36($t5)
	beq $t4, $t5,SECOND_BREAK

	la $t5, COLOR
	lw $t5, 40($t5)
	beq $t4, $t5,THIRD_BREAK

	la $t5, COLOR
	lw $t5, 44($t5)
	beq $t4, $t5,FINAL_BREAK

	# First Break
	la $a2, COLOR
	lw $a2, 36($a2)	# modified
	
	jal DRAW_BRICK_WITH_COLOR
	
	
	j END_CHECK_COLLISION


CHECK_BOTTOM_RIGHT:
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t4, $t0, 0

	addi $t2, $t2, 1 	# move one pixel to right
	addi $t3, $t3, 1	# move one pixel to bottom

	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t4, $t4, $t2
	add $t4, $t4, $t3			# $t4 is the pixel address to the top_left of the ball
	lw $t4, 0($t4)				# $t4 is the color of pixel to the top_left of ball

	beq $t4, 0x000000, END_CHECK_COLLISION	# If right is empty (black), end
	beq $t4, 0xfff68f, COLLIDE_PADDLE_INV_X_Y  # If bottom is paddle, then switch

	la $t5, COLOR
	lw $t5, 0($t5)
	beq $t4, $t5, COLLIDE_WALL_INV_X_Y

	# Collide on Brick
	mul $s4, $s4, -1
	mul $s5, $s5, -1
	
	li $a0, 0
	li $a1, 0

	add $a0, $a0, $s2
	add $a1, $a1, $s3
	addi $a0, $a0, 1	# Right Pixel of the ball
	addi $a1, $a1, 1

	la $t5, COLOR
	lw $t5, 36($t5)
	beq $t4, $t5,SECOND_BREAK

	la $t5, COLOR
	lw $t5, 40($t5)
	beq $t4, $t5,THIRD_BREAK

	la $t5, COLOR
	lw $t5, 44($t5)
	beq $t4, $t5,FINAL_BREAK

	# First Break
	la $a2, COLOR
	lw $a2, 36($a2)	#modified
	
	jal DRAW_BRICK_WITH_COLOR
	
	
	j END_CHECK_COLLISION


###############################################################

# CHECK_PADDLE_CORNOR_BUTTOM_LEFT:
# 	addi $t2, $s2, 0
# 	addi $t3, $s3, 0
# 	addi $t4, $t0, 0

# 	addi $t2, $t2, 1
# 	addi $t3, $t3, 1

# 	sll $t2, $t2, 2
# 	sll $t3, $t3, 9
# 	add $t4, $t4, $t2
# 	add $t4, $t4, $t3		# $t4 is the pixel address to the left of ball
# 	lw $t4, 0($t4)			# $t4 is the color of pixel to the left of ball
	
# 	beq $t4, 0x000000, CHECK_PADDLE_CORNOR_BUTTOM_RIGHT	# Check is it in the cornor case of top right
# 	beq $t4, 0xfff68f, COLLIDE_PADDLE_INV_X_Y

# 	j END_CHECK_COLLISION


# CHECK_PADDLE_CORNOR_BUTTOM_RIGHT:
# 	addi $t2, $s2, 0
# 	addi $t3, $s3, 0
# 	addi $t4, $t0, 0

# 	addi $t2, $t2, -1
# 	addi $t3, $t3, 1

# 	sll $t2, $t2, 2
# 	sll $t3, $t3, 9
# 	add $t4, $t4, $t2
# 	add $t4, $t4, $t3		# $t4 is the pixel address to the left of ball
# 	lw $t4, 0($t4)			# $t4 is the color of pixel to the left of ball
	
# 	beq $t4, 0x000000, 	CHECK_TOP_LEFT# Check is it in the cornor case of top right
# 	beq $t4, 0xfff68f, COLLIDE_PADDLE_INV_X_Y

# 	j END_CHECK_COLLISION


CHECK_WALL_CORNOR_TOP_LEFT:
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t4, $t0, 0

	addi $t2, $t2, -1
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t4, $t4, $t2
	add $t4, $t4, $t3		# $t4 is the pixel address to the left of ball
	lw $t4, 0($t4)			# $t4 is the color of pixel to the left of ball
	
	la $t5, COLOR
	lw $t5, 0($t5)

	beq $t4, 0x000000, CHECK_WALL_CORNOR_TOP_RIGHT	# Check is it in the cornor case of top right
	beq $t4, $t5, COLLIDE_WALL_INV_X_Y

	j END_CHECK_COLLISION


CHECK_WALL_CORNOR_TOP_RIGHT:
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t4, $t0, 0

	addi $t2, $t2, 1	# the right pixel of the ball
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t4, $t4, $t2
	add $t4, $t4, $t3		# $t4 is the pixel address to the left of ball
	lw $t4, 0($t4)			# $t4 is the color of pixel to the left of ball
	
	la $t5, COLOR
	lw $t5, 0($t5)

	beq $t4, 0x000000, COLLIDE_WALL_INV_Y
	beq $t4, $t5, COLLIDE_WALL_INV_X_Y

	j END_CHECK_COLLISION


###############################################################
# Bound Related
COLLIDE_WALL_INV_Y:
	mul $s5, $s5, -1
	li $v0, 31
	li $a0, 72
	li $a1, 500
	li $a2, 32
	li $a3, 60
	syscall
	j END_CHECK_COLLISION

COLLIDE_WALL_INV_X:
	mul $s4, $s4, -1
	li $v0, 31
	li $a0, 72
	li $a1, 500
	li $a2, 32
	li $a3, 60
	syscall
	j END_CHECK_COLLISION

COLLIDE_WALL_INV_X_Y:
	mul $s4, $s4, -1
	mul $s5, $s5, -1

	li $v0, 31
	li $a0, 72
	li $a1, 500
	li $a2, 32
	li $a3, 60
	syscall
	
	j END_CHECK_COLLISION

COLLIDE_PADDLE:
# there will be a special case, when ball collide on the paddle but on the left/right it is the wall, then it will 
# cross inside the wall
	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t4, $t0, 0

	addi $t2, $t2, 1	# the right pixel of the ball
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t4, $t4, $t2
	add $t4, $t4, $t3		# $t4 is the pixel address to the left of ball
	lw $t4, 0($t4)			# $t4 is the color of pixel to the left of ball
	
	la $t5, COLOR
	lw $t5, 0($t5)

	beq $t4, $t5, COLLIDE_PADDLE_INV_X_Y

	addi $t2, $s2, 0
	addi $t3, $s3, 0
	addi $t4, $t0, 0

	addi $t2, $t2, -1	# the left pixel of the ball
	
	sll $t2, $t2, 2
	sll $t3, $t3, 9
	add $t4, $t4, $t2
	add $t4, $t4, $t3		# $t4 is the pixel address to the left of ball
	lw $t4, 0($t4)			# $t4 is the color of pixel to the left of ball
	
	la $t5, COLOR
	lw $t5, 0($t5)

	beq $t4, $t5, COLLIDE_PADDLE_INV_X_Y
#####################
	mul $s5, $s5, -1

	li $v0, 31
	li $a0, 61
	li $a1, 500
	li $a2, 24
	li $a3, 50
	syscall
	
	j END_CHECK_COLLISION

COLLIDE_PADDLE_INV_X_Y:
	mul $s5, $s5, -1
	mul $s4, $s4, -1

	li $v0, 31
	li $a0, 61
	li $a1, 500
	li $a2, 24
	li $a3, 50
	syscall
	
	j END_CHECK_COLLISION



# Special case of the COLLIDE, collide on the corner of the brick, inverse x,y direction and draw brick based 
# on corresponding time of collision
COLLIDE_BRICK_INVERSE_X_Y:
	mul $s4, $s4, -1
	mul $s5, $s5, -1

	la $t5, COLOR
	lw $t5, 36($t5)
	beq $t6, $t5,SECOND_BREAK

	la $t5, COLOR
	lw $t5, 40($t5)
	beq $t6, $t5,THIRD_BREAK

	la $t5, COLOR
	lw $t5, 44($t5)
	beq $t6, $t5,FINAL_BREAK

# First Break
	la $a2, COLOR
	lw $a2, 36($a2)
	
	jal DRAW_BRICK_WITH_COLOR
	j END_CHECK_COLLISION

###############################################################
# Break brick related

# SECOND_BREAK($a0, $a1), $a0, $a1 is the x, y coordinate of the collision, they are passed by CHECK_RELATED
# It will pass the 40 offset from the COLOR
SECOND_BREAK:
	la $a2, COLOR
	lw $a2, 40($a2)
	
	jal DRAW_BRICK_WITH_COLOR
	
	j END_CHECK_COLLISION


THIRD_BREAK:
	la $a2, COLOR
	lw $a2, 44($a2)
	
	jal DRAW_BRICK_WITH_COLOR
	
	j END_CHECK_COLLISION


FINAL_BREAK:
	li $a2, 0x000000
	# Add 1 more break number 
	addi $s1, $s1, 1

	lw $t0, 4($sp)

	li $t2, 2	# Set the minimum of the ball

	slt $t1, $t0, $t2
	beq $t1, 1, END_FINAL_BREAK	

	addi $t0, $t0, -1
	sw $t0, 4($sp)

	jal DRAW_BRICK_WITH_COLOR
	j END_CHECK_COLLISION

	
END_FINAL_BREAK:
	# If the speed of ball reach to the minimum, Then we go to the special case and load the
	# highest value for the ball. 
	li $t0, 1
	sw $t0, 4($sp)
	jal DRAW_BRICK_WITH_COLOR
	
	j END_CHECK_COLLISION


###############################################################

END_CHECK_COLLISION:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

###############################################################







###############################################################
DRAW_BRICK_WITH_COLOR:

# GET_HIT_BRICK_ADDRESS($a0, $a1) This will set the $t0, $t1 to the start address of the brick 
# $a0, $a1 stores the x, y coordinate of the collision
GET_HIT_BRICK_ADDRESS:
	addi $sp, $sp, -8	#
	sw $ra, 4($sp)
	# sw $t0, 16($sp)
	# sw $t1, 12($sp)
	# sw $t2, 8($sp)
	# sw $t3, 4($sp)
	sw $t0, 0($sp)
	
	li $t0, 0 # $t0 stores ($a0 - 12 //8)
	#li $t1, 0 # $t1 stores ($a1 - 8 // 2)
	
	addi $a0, $a0, -12
	li $t0, 8
	div $a0, $t0
	mflo $a0
	
	addi $a1, $a1, -8
	li $t0, 2
	div $a1, $t0
	mflo $a1
	
	sll $a0, $a0, 3	# $a0= $a0 x 8
	addi $a0, $a0, 12
	
	sll $a1, $a1, 1, # $t1 = $t1 x 2
	addi $a1, $a1, 8
	
	jal DRAW_BRICK

	lw $t0,  0($sp)
	# lw $t3, 4($sp)
	# lw $t2, 8($sp)
	# lw $t1, 12($sp)
	# lw $t0, 16($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra



# DRAW_BRICK($a0, $a1, $a2) DRAW brick in the given x,y coordinate with color
# ($a0, $a1) x,y coordinate of the brick, $a2, color of the brick
DRAW_BRICK:

	la $t7, ADDR_DSPL 
	lw $t7, 0($t7)	# $t7 is the offset of the first brick pixel
	sll $t0, $a0, 2
	sll $t1, $a1, 9
	add $t7, $t7, $t0
	add $t7, $t7, $t1
	
	# la $t8, COLOR
	# lw $t8, 32($t8) 
	
	li $t2, 0	
	li $t3, 8	# Draw 8 times which is width of brick
	
	li $t5, 0
	li $t6, 1	# Draw 2 times which is height of brick

DRAW_BRICK_INNER_LOOP:
	slt $t4, $t2, $t3
	beq $t4, $0, DRAW_BRICK_OUTER_LOOP
		sw $a2, 0($t7)
		addi $t7, $t7, 4
	addi $t2, $t2, 1
	j DRAW_BRICK_INNER_LOOP

DRAW_BRICK_OUTER_LOOP:
	li $t2, 0
	addi $t7, $t7, 480
	slt $t9, $t5, $t6
	beq $t9, $0, END_DRAW_BRICK_OUTER_LOOP
		addi $t5, $t5, 1
		j DRAW_BRICK_INNER_LOOP
	

END_DRAW_BRICK_OUTER_LOOP:
	jr $ra	


###############################################################






##############################################################################################################################		
# Game Loop
##############################################################################################################################	
game_loop:
# 1a. Check if key has been pressed
# 1b. Check which key has been pressed
# 2a. Check for collisions
# 2b. Update locations (paddle, ball)
# 3. Draw the screen
# 4. Sleep
# 5. Go back to 1
	
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
	# la $t0, ADDR_KBRD               # $t0 = base address for keyboard
	lw $t8, 0($t0)                  # Load first word from keyboard
	beq $t8, 1, on_keyboard_input   # If first word 1, key is pressed
	
	
	addi $s6, $s6, 1

	li $t7, 0

	# addi $sp, $sp, -4	#
	lw $t7, 0($sp)
	# addi $sp, $sp, 4
	# bne $s6, $t7, AFTER_MOVE_BALL 	#adjust the speed of the ball,  move the ball every 5 iterations modified
	bne $s6, $t7, AFTER_MOVE_BALL
	
	jal MOVE_BALL
	
	li $a0, 0
	li $a1, 0
	li $a2, 0x000000
	jal ANIMATION
	
	
	
############################
# cheat program, comment the next line for stop cheating
	 jal CHEAT_FOLLOW

############################
	# IF ball touching bottom of screen, end game
	li $t7, 64
	slt $t9, $s3, $t7
	beq $t9, $0, CHECK_LOOSE 

############################
	# All bricks are Breaked, YOU WIN!
	# one unbreakable brick
	beq $s1, 64, END_WITH_WIN	
############################
	# Recheck the Collision
	jal CHECK_BALL_COLLISION
	li $s6, 0
############################
	
AFTER_MOVE_BALL:
	li $v0, 32
	li $a0, 1	# Adjust the speed of ball
	syscall

	b game_loop


on_keyboard_input:                  	# A key is pressed
	lw $a0, 4($t0)                  # Load second word from keyboard
	
	beq $a0, 0x71, END_WITH_LOOSE   		# IF q pressed, END
	
IF_A_PRESSED:
	bne $a0, 0x61, IF_D_PRESSED     # IF a didn't get pressed, go to next IF
	jal MOVE_PADDLE_LEFT


IF_D_PRESSED:
#	bne $a0, 0x64, OTHER_KEY	# IF d didn't get pressed, go to next section
	bne $a0, 0x64,IF_P_PRESSED
	jal MOVE_PADDLE_RIGHT

##############################################################################################################################
# Debug Purpose on Ball
##############################################################################################################################
# IF_I_PRESSED:
# 	bne $a0, 0x69, IF_J_PRESSED	# IF I didn't get pressed, go to next section
# 	addi $sp, $sp, -8	#
# 	sw $s4, 4($sp)
# 	sw $s5, 0($sp)

# 	li $s4, 0
# 	li $s5, -1
# 	jal MOVE_BALL
# 	jal CHECK_BALL_COLLISION
	
	
# 	lw $s5, 0($sp)
# 	sw $s4, 4($sp)
# 	addi $sp, $sp, 8


# IF_J_PRESSED:
# 	bne $a0, 0x6A, IF_K_PRESSED	# IF J didn't get pressed, go to next section
# 	addi $sp, $sp, -8	#
# 	sw $s4, 4($sp)
# 	sw $s5, 0($sp)

# 	li $s4, -1
# 	li $s5, 0
# 	jal MOVE_BALL
# 	jal CHECK_BALL_COLLISION
	
# 	lw $s5, 0($sp)
# 	sw $s4, 4($sp)
# 	addi $sp, $sp, 8

# IF_K_PRESSED:
# 	bne $a0, 0x6B, IF_L_PRESSED	# IF K didn't get pressed, go to next section
# 	addi $sp, $sp, -8	#
# 	sw $s4, 4($sp)
# 	sw $s5, 0($sp)

# 	li $s5, 1
# 	li $s4, 0
# 	jal MOVE_BALL
# 	jal CHECK_BALL_COLLISION
	
# 	lw $s5, 0($sp)
# 	sw $s4, 4($sp)
# 	addi $sp, $sp, 8

# IF_L_PRESSED:
# 	bne $a0, 0x6C, IF_P_PRESSED	# IF L didn't get pressed, go to next section
# 	addi $sp, $sp, -8	#
# 	sw $s4, 4($sp)
# 	sw $s5, 0($sp)


# 	li $s5, 0
# 	li $s4, 1
# 	jal MOVE_BALL
# 	jal CHECK_BALL_COLLISION
	
# 	lw $s5, 0($sp)
# 	sw $s4, 4($sp)
# 	addi $sp, $sp, 8
##############################################################################################################################


IF_P_PRESSED:
	bne $a0, 0x70, OTHER_KEY
		mul $s7, $s7, -1


OTHER_KEY:
	beq $s7, -1, PAUSE_STATE
		b game_loop

PAUSE_STATE:
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
	lw $t8, 0($t0)                  # Load first word from keyboard
	beq $t8, 1, on_keyboard_input   # If first word 1, key is pressed
	j PAUSE_STATE

CHECK_LOOSE:
	lw $t0, 4($sp)
	addi $t0, $t0, -1

	slt $t1,$t0, $0
	beq $t1, 1, END_WITH_LOOSE
	sw $t0, 4($sp)
	addi $a0, $t0, 1
	la $a1, COLOR
	lw $a1, 0($a1)

	jal DRAW_LIVES_DISPLAY

	lw $t0, 4($sp)

	addi $a0, $t0, 0
	la $a1, COLOR
	lw $a1, 48($a1)

	jal DRAW_LIVES_DISPLAY

	lw $t0, 4($sp)

	jal DELETE_BALL

	jal INIT_BALL		# Set the ball coordinate to the beginning

	jal DELETE_PADDLE 	

	jal INIT_PADDLE
	
	mul $s7, $s7, -1	# Pause the game

	j PAUSE_STATE


END_WITH_LOOSE:	
	li $a0, 0
	la $a1, COLOR
	lw $a1, 0($a1)

	jal DRAW_LIVES_DISPLAY

	li $v0, 10			# Quit gracefully
	syscall


END_WITH_WIN:
	li $v0, 31
	li $a0, 61
	li $a1, 50000
	li $a2, 4
	li $a3, 60
	syscall


	li $v0, 10
	syscall




##############################################################################################################################
# Debug Purpose
##############################################################################################################################
# cheat program, Debug purpose
 CHEAT_FOLLOW:
	li $t5, 0
	li $t4, 0
	addi $t4, $s2, -1
	slt $t5, $t4, $s0  # $t5, 1 ball on the left of paddle, 0 ball on the right
	beq $t5, $0, CHEAT_MOVE_RIGHT

		addi $sp, $sp, -4	#
		sw $ra, 0($sp)	
		jal MOVE_PADDLE_LEFT
		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra


CHEAT_MOVE_RIGHT:
	addi $sp, $sp, -4	#
	sw $ra, 0($sp)	
	jal MOVE_PADDLE_RIGHT
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
##############################################################################################################################
# Animation 
##############################################################################################################################
# DRAW_SQUARE(x, y, color)
# DRAW a 16 x 16 square
DRAW_SQUARE:
	la $t0, ADDR_DSPL 
	lw $t0, 0($t0)
	
	sll $t3, $a0, 2
	sll $t4, $a1, 9
	add $t0, $t0, $t3
	add $t0, $t0, $t4 # $t0 = memory address of left pixel
	
	li $t1, 0	# $t1 = i = outer loop counter
	li $t6, 4	# $t6 + 1 = square length
	li $t2, 0	# reset $t2 = j = inner loop counter

DRAW_SQUARE_OUTER_LOOP:
	beq $t1, $t6, END_DRAW_SQUARE
	
DRAW_SQUARE_INNER_LOOP:
	beq $t2, $t6, END_DRAW_SQUARE_INNER_LOOP
		sw $a2, 0($t0)	# put color to the address
		addi $t0, $t0, 4 # go to the next unit
	addi $t2, $t2, 1 # j = j + 1
	j DRAW_SQUARE_INNER_LOOP
END_DRAW_SQUARE_INNER_LOOP:
	li $t2, 0	# reset $t2 = j = inner loop counter
	
	la $t0, ADDR_DSPL 
	lw $t0, 0($t0)
	addi $a1, $a1, 1
	sll $t3, $a0, 2
	sll $t4, $a1, 9
	add $t0, $t0, $t3
	add $t0, $t0, $t4 # $t0 = memory address of left pixel of current row
	
	addi $t1, $t1, 1 # i += 1
	j DRAW_SQUARE_OUTER_LOOP
	
END_DRAW_SQUARE:
	jr $ra	
	
ANIMATION:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $a0, 0
	li $a1, 0
	li $a2, 0xd6d48a
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 0
	li $a2, 0x8f8f47
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 0
	li $a2, 0xbcbf7c
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 0
	li $a2, 0xf6f5bd
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 0
	li $a2, 0xd8ceaa
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 0
	li $a2, 0xcbb88d
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 0
	li $a2, 0xfbe197
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 0
	li $a2, 0xddc16e
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 0
	li $a2, 0xe5c884
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 0
	li $a2, 0xffe9b8
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 0
	li $a2, 0xdfd3b9
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 0
	li $a2, 0xcfcbc2
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 0
	li $a2, 0xfcf7fe
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 0
	li $a2, 0xfaf2ff
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 0
	li $a2, 0xfceaf8
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 0
	li $a2, 0xebdbdb
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 0
	li $a2, 0xc9c8a9
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 0
	li $a2, 0xd5cf9b
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 0
	li $a2, 0xc5a568
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 0
	li $a2, 0xedcb8b
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 0
	li $a2, 0xe0cd92
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 0
	li $a2, 0xf5ebb0
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 0
	li $a2, 0xf3e3a5
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 0
	li $a2, 0xd3c086
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 0
	li $a2, 0xdcc496
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 0
	li $a2, 0xf4dbbc
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 0
	li $a2, 0xb49a8d
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 0
	li $a2, 0x988d93
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 0
	li $a2, 0xccdbfc
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 0
	li $a2, 0x9eb5d7
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 0
	li $a2, 0xb0b9ca
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 0
	li $a2, 0x8f9299
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 4
	li $a2, 0xeee2bc
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 4
	li $a2, 0xe1d7b4
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 4
	li $a2, 0xbdb797
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 4
	li $a2, 0xc9c1ac
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 4
	li $a2, 0xfeede5
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 4
	li $a2, 0xfee8da
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 4
	li $a2, 0xfbe0b5
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 4
	li $a2, 0xffe8b1
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 4
	li $a2, 0xf3dcaa
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 4
	li $a2, 0xe9d6b5
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 4
	li $a2, 0xc5bdb2
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 4
	li $a2, 0xedebee
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 4
	li $a2, 0xeaeaf2
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 4
	li $a2, 0xe7e4ef
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 4
	li $a2, 0xf3e7f3
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 4
	li $a2, 0xf7edee
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 4
	li $a2, 0xe8e7d2
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 4
	li $a2, 0xb9b58f
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 4
	li $a2, 0xdec99a
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 4
	li $a2, 0xeed7a5
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 4
	li $a2, 0xf8ebbf
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 4
	li $a2, 0xd4cba0
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 4
	li $a2, 0xb1a679
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 4
	li $a2, 0xcbbe94
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 4
	li $a2, 0xccbd9e
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 4
	li $a2, 0xa49484
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 4
	li $a2, 0x716161
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 4
	li $a2, 0x968e9d
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 4
	li $a2, 0xc4cdea
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 4
	li $a2, 0x5c6a87
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 4
	li $a2, 0x515561
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 4
	li $a2, 0xa5a6aa
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 8
	li $a2, 0xefd0f2
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 8
	li $a2, 0xffe6ff
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 8
	li $a2, 0xbb9eca
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 8
	li $a2, 0xad91c1
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 8
	li $a2, 0xf8dcff
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 8
	li $a2, 0xffe6ff
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 8
	li $a2, 0xd5bacd
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 8
	li $a2, 0xdac1c4
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 8
	li $a2, 0xe2d1c7
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 8
	li $a2, 0xf9f0e9
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 8
	li $a2, 0xdedded
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 8
	li $a2, 0xdfe4fa
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 8
	li $a2, 0xf0f8ff
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 8
	li $a2, 0xe8eff7
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 8
	li $a2, 0xf9fbff
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 8
	li $a2, 0xf0f1f6
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 8
	li $a2, 0xe9e9e7
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 8
	li $a2, 0xeef0e3
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 8
	li $a2, 0xf4f5e3
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 8
	li $a2, 0xfefde9
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 8
	li $a2, 0xcecbbc
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 8
	li $a2, 0x9f9b8f
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 8
	li $a2, 0x928e83
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 8
	li $a2, 0xcacac2
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 8
	li $a2, 0xf0f1f3
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 8
	li $a2, 0xe6eaf5
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 8
	li $a2, 0xc5c7de
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 8
	li $a2, 0xc2c2de
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 8
	li $a2, 0xbab8d0
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 8
	li $a2, 0x8a8798
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 8
	li $a2, 0x8d888c
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 8
	li $a2, 0xaeaaa7
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 12
	li $a2, 0xbf95dd
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 12
	li $a2, 0xd5abf5
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 12
	li $a2, 0xc39ceb
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 12
	li $a2, 0xc09aed
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 12
	li $a2, 0xba99ea
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 12
	li $a2, 0xbda1eb
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 12
	li $a2, 0xab93cd
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 12
	li $a2, 0x9787ae
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 12
	li $a2, 0xc0b9c9
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 12
	li $a2, 0xdad9e9
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 12
	li $a2, 0xc9cdf2
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 12
	li $a2, 0xc2caee
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 12
	li $a2, 0xdae6f6
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 12
	li $a2, 0xc3d0d6
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 12
	li $a2, 0xd9e1ec
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 12
	li $a2, 0xd6dce8
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 12
	li $a2, 0xc3c5d2
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 12
	li $a2, 0xcdd1dc
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 12
	li $a2, 0xf7ffff
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 12
	li $a2, 0xe7f3f3
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 12
	li $a2, 0xd1d6d2
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 12
	li $a2, 0xc5c9ca
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 12
	li $a2, 0xbdc5d0
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 12
	li $a2, 0xe8f8ff
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 12
	li $a2, 0xf0ffff
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 12
	li $a2, 0xeaffff
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 12
	li $a2, 0xbdd1f4
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 12
	li $a2, 0xc9d7f4
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 12
	li $a2, 0xd4d4e0
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 12
	li $a2, 0xc5bcbf
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 12
	li $a2, 0xc8bebd
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 12
	li $a2, 0x887e7d
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 16
	li $a2, 0xb387d2
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 16
	li $a2, 0xa97fcb
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 16
	li $a2, 0xae83d5
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 16
	li $a2, 0xbf99ee
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 16
	li $a2, 0xa887de
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 16
	li $a2, 0xb19aec
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 16
	li $a2, 0xb3a7ef
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 16
	li $a2, 0x9693cc
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 16
	li $a2, 0xb1b7db
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 16
	li $a2, 0xafb8d7
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 16
	li $a2, 0xacb3e1
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 16
	li $a2, 0xcad2f9
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 16
	li $a2, 0xb2bbcc
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 16
	li $a2, 0xb8c3c9
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 16
	li $a2, 0xccd6e0
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 16
	li $a2, 0xc9cee1
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 16
	li $a2, 0xb5b4d3
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 16
	li $a2, 0xb3b4d3
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 16
	li $a2, 0xd6e1f5
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 16
	li $a2, 0xf5ffff
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 16
	li $a2, 0xe0e7df
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 16
	li $a2, 0xc5d2cb
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 16
	li $a2, 0xaec9da
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 16
	li $a2, 0xc1e4ff
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 16
	li $a2, 0xdcfeff
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 16
	li $a2, 0xd4f7ff
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 16
	li $a2, 0xb8e1ff
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 16
	li $a2, 0xd5f7ff
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 16
	li $a2, 0xf7fff9
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 16
	li $a2, 0xc4c1b2
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 16
	li $a2, 0xab9f9f
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 16
	li $a2, 0x74636b
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 20
	li $a2, 0xffe0ff
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 20
	li $a2, 0xf2cbff
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 20
	li $a2, 0xc49dd6
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 20
	li $a2, 0xaf8ccc
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 20
	li $a2, 0xac92db
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 20
	li $a2, 0xaa9ce7
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 20
	li $a2, 0x9e9ddf
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 20
	li $a2, 0x8d96cd
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 20
	li $a2, 0xa3b2dd
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 20
	li $a2, 0x9caad1
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 20
	li $a2, 0xb2b6e3
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 20
	li $a2, 0xc8caf0
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 20
	li $a2, 0xc3c5d4
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 20
	li $a2, 0xc8c9ce
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 20
	li $a2, 0xcccfd8
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 20
	li $a2, 0xc8cbdc
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 20
	li $a2, 0xb2b3d2
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 20
	li $a2, 0xb5b9dc
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 20
	li $a2, 0x96a1bd
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 20
	li $a2, 0xf4ffff
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 20
	li $a2, 0xdde6e3
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 20
	li $a2, 0xc3d3d3
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 20
	li $a2, 0xb9dbf6
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 20
	li $a2, 0xbfebff
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 20
	li $a2, 0xb5dcff
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 20
	li $a2, 0xadd7fd
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 20
	li $a2, 0xb3e5fe
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 20
	li $a2, 0xb2dbe1
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 20
	li $a2, 0xe0ecde
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 20
	li $a2, 0xf4eed6
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 20
	li $a2, 0xcbbaaa
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 20
	li $a2, 0x695244
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 24
	li $a2, 0xfee1e6
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 24
	li $a2, 0xfff4f9
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 24
	li $a2, 0xedd0d5
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 24
	li $a2, 0xb198ab
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 24
	li $a2, 0xa493bd
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 24
	li $a2, 0xa6a2d4
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 24
	li $a2, 0xa9b7de
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 24
	li $a2, 0x9eb5d7
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 24
	li $a2, 0xaec4e9
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 24
	li $a2, 0xa4b2d7
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 24
	li $a2, 0xcacaec
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 24
	li $a2, 0xccc4dc
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 24
	li $a2, 0xeadde7
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 24
	li $a2, 0xe7d8dd
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 24
	li $a2, 0xdcd1d5
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 24
	li $a2, 0xdcd6e0
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 24
	li $a2, 0xd3d8ec
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 24
	li $a2, 0xb5c1d9
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 24
	li $a2, 0xaab9d0
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 24
	li $a2, 0xbecbde
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 24
	li $a2, 0xebf5ff
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 24
	li $a2, 0xdcebfe
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 24
	li $a2, 0xbddaff
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 24
	li $a2, 0xbae0ff
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 24
	li $a2, 0xb2dafd
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 24
	li $a2, 0xafd8f4
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 24
	li $a2, 0xc3f0ff
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 24
	li $a2, 0xb8d8e3
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 24
	li $a2, 0xb1b3ae
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 24
	li $a2, 0xd9c9b0
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 24
	li $a2, 0xd5bc86
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 24
	li $a2, 0x846725
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 28
	li $a2, 0xf3d6c4
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 28
	li $a2, 0xffe9d4
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 28
	li $a2, 0xfde2cd
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 28
	li $a2, 0xbfa8a2
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 28
	li $a2, 0xa395ae
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 28
	li $a2, 0xb7b6d8
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 28
	li $a2, 0xbdcfe7
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 28
	li $a2, 0x7892a9
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 28
	li $a2, 0x9bb2d4
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 28
	li $a2, 0xa9b6d8
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 28
	li $a2, 0xccc8e1
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 28
	li $a2, 0xaa99ab
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 28
	li $a2, 0xa38a90
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 28
	li $a2, 0xfee4e5
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 28
	li $a2, 0xf4dfde
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 28
	li $a2, 0xb9adaf
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 28
	li $a2, 0xacabb9
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 28
	li $a2, 0xccd3e6
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 28
	li $a2, 0xb1bcd2
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 28
	li $a2, 0xc7cfe6
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 28
	li $a2, 0xe7e9ff
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 28
	li $a2, 0xcbd0e6
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 28
	li $a2, 0xaab8d3
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 28
	li $a2, 0xa5bfda
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 28
	li $a2, 0xb1d5ef
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 28
	li $a2, 0xb5def4
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 28
	li $a2, 0xa6c9df
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 28
	li $a2, 0xc5d9e4
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 28
	li $a2, 0xc2bdb7
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 28
	li $a2, 0xcbb699
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 28
	li $a2, 0xd0b57e
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 28
	li $a2, 0xad8e4b
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 32
	li $a2, 0xffefda
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 32
	li $a2, 0xf9d5bd
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 32
	li $a2, 0xffe1c8
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 32
	li $a2, 0xc8aba3
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 32
	li $a2, 0xe7d4ea
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 32
	li $a2, 0xeae4ff
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 32
	li $a2, 0xb0bfd6
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 32
	li $a2, 0xa2b8cf
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 32
	li $a2, 0x7f8fb0
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 32
	li $a2, 0xb6bcdc
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 32
	li $a2, 0xccc0d8
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 32
	li $a2, 0xd3bbc9
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 32
	li $a2, 0xe3c3c6
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 32
	li $a2, 0xffefea
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 32
	li $a2, 0xffe8e0
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 32
	li $a2, 0xd3bbb9
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 32
	li $a2, 0xab9ba8
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 32
	li $a2, 0xd4cae2
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 32
	li $a2, 0x9f9fbb
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 32
	li $a2, 0xb5b5d1
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 32
	li $a2, 0xe1d7f0
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 32
	li $a2, 0xd5c7d4
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 32
	li $a2, 0xc9bcb3
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 32
	li $a2, 0x888981
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 32
	li $a2, 0x809caa
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 32
	li $a2, 0xb1d3ee
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 32
	li $a2, 0xd5e9ff
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 32
	li $a2, 0xccd0d9
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 32
	li $a2, 0xb4a890
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 32
	li $a2, 0xc7b08e
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 32
	li $a2, 0xe0c5b0
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 32
	li $a2, 0xa98d7f
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 36
	li $a2, 0xedbaa7
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 36
	li $a2, 0xfdcdb9
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 36
	li $a2, 0xffdecd
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 36
	li $a2, 0xbc9995
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 36
	li $a2, 0xf5ddf3
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 36
	li $a2, 0xd8cfee
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 36
	li $a2, 0xa3aac4
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 36
	li $a2, 0xafbfd6
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 36
	li $a2, 0x8a95b1
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 36
	li $a2, 0xa8a9c5
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 36
	li $a2, 0xdfcfe9
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 36
	li $a2, 0xffe6f7
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 36
	li $a2, 0xffe5e6
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 36
	li $a2, 0xfad9d2
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 36
	li $a2, 0xffece1
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 36
	li $a2, 0xffe8e4
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 36
	li $a2, 0xedd6e6
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 36
	li $a2, 0xcebfd4
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 36
	li $a2, 0xbfb7cc
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 36
	li $a2, 0xc1baca
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 36
	li $a2, 0xc0b0bb
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 36
	li $a2, 0xe5cdcd
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 36
	li $a2, 0xe0c0b1
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 36
	li $a2, 0xa28e85
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 36
	li $a2, 0xafb8c9
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 36
	li $a2, 0xc3d5eb
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 36
	li $a2, 0xc1c4cb
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 36
	li $a2, 0xc2b8ac
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 36
	li $a2, 0xd3bf9a
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 36
	li $a2, 0xecd2af
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 36
	li $a2, 0xe3c7bb
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 36
	li $a2, 0xc2a6a5
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 40
	li $a2, 0xe09c91
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 40
	li $a2, 0xffcfc6
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 40
	li $a2, 0xfdc3c1
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 40
	li $a2, 0xcb9ea5
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 40
	li $a2, 0xfcdcf3
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 40
	li $a2, 0xc1b0d0
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 40
	li $a2, 0xa9a8c7
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 40
	li $a2, 0xcad0ea
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 40
	li $a2, 0xdce1f5
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 40
	li $a2, 0xc4c2d7
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 40
	li $a2, 0xc6b5d5
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 40
	li $a2, 0xe7cfe7
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 40
	li $a2, 0xfff7fa
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 40
	li $a2, 0xceb6ac
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 40
	li $a2, 0xd0bcb3
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 40
	li $a2, 0xfff2f2
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 40
	li $a2, 0xc2b1c1
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 40
	li $a2, 0xc9bdcb
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 40
	li $a2, 0xe3d9d8
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 40
	li $a2, 0xd3c9bd
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 40
	li $a2, 0xb4a995
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 40
	li $a2, 0xcbb5a7
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 40
	li $a2, 0xdfb6be
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 40
	li $a2, 0xebc3dd
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 40
	li $a2, 0xd4c5e6
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 40
	li $a2, 0xd2ccd6
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 40
	li $a2, 0xd4c59e
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 40
	li $a2, 0xe2cc92
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 40
	li $a2, 0xf5d8ac
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 40
	li $a2, 0xfff9d6
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 40
	li $a2, 0xffebd0
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 40
	li $a2, 0xc9a690
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 44
	li $a2, 0xf1a49c
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 44
	li $a2, 0xe09995
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 44
	li $a2, 0xce9196
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 44
	li $a2, 0xe2b4c1
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 44
	li $a2, 0xe0c0d7
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 44
	li $a2, 0xcfbdd7
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 44
	li $a2, 0xd2cce8
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 44
	li $a2, 0xdbd9ef
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 44
	li $a2, 0xe9e7f2
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 44
	li $a2, 0xe0dae8
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 44
	li $a2, 0x9d8ead
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 44
	li $a2, 0x76627e
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 44
	li $a2, 0xd7c4c8
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 44
	li $a2, 0xffefe7
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 44
	li $a2, 0xedded9
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 44
	li $a2, 0xb6abaf
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 44
	li $a2, 0xb2afc4
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 44
	li $a2, 0xc7c4d7
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 44
	li $a2, 0xc9c4be
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 44
	li $a2, 0xbab5a1
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 44
	li $a2, 0xaaa58f
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 44
	li $a2, 0x9d8f84
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 44
	li $a2, 0xdab8c8
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 44
	li $a2, 0xffd9f4
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 44
	li $a2, 0xedcde2
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 44
	li $a2, 0xe8cac0
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 44
	li $a2, 0xe4c082
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 44
	li $a2, 0xefc978
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 44
	li $a2, 0xf9d395
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 44
	li $a2, 0xffefbe
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 44
	li $a2, 0xffe3bb
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 44
	li $a2, 0xc99772
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 48
	li $a2, 0xffb5aa
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 48
	li $a2, 0xd4918b
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 48
	li $a2, 0xcb979b
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 48
	li $a2, 0xcfa9b6
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 48
	li $a2, 0xdfc8dc
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 48
	li $a2, 0xede0f4
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 48
	li $a2, 0xaba2b3
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 48
	li $a2, 0xd7d1db
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 48
	li $a2, 0xe7e2df
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 48
	li $a2, 0xe0d7dc
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 48
	li $a2, 0xcebfdc
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 48
	li $a2, 0xb09fbf
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 48
	li $a2, 0x8e818a
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 48
	li $a2, 0x978c8a
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 48
	li $a2, 0xbdb3b1
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 48
	li $a2, 0xb8b6c1
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 48
	li $a2, 0xcbd8fb
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 48
	li $a2, 0xacbbdc
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 48
	li $a2, 0xc4c9cc
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 48
	li $a2, 0xc7cac3
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 48
	li $a2, 0xa5aab0
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 48
	li $a2, 0x8a8d96
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 48
	li $a2, 0xeee3eb
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 48
	li $a2, 0xf2d8d7
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 48
	li $a2, 0xe0b7a3
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 48
	li $a2, 0xefbc91
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 48
	li $a2, 0xdaa15e
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 48
	li $a2, 0xeab160
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 48
	li $a2, 0xffd27d
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 48
	li $a2, 0xe6b569
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 48
	li $a2, 0xe09f69
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 48
	li $a2, 0xc0774c
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 52
	li $a2, 0xfdbab4
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 52
	li $a2, 0xdda1a1
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 52
	li $a2, 0xddb4bc
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 52
	li $a2, 0xf2d7e6
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 52
	li $a2, 0xbbadc6
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 52
	li $a2, 0xa29aaf
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 52
	li $a2, 0xaaa3ab
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 52
	li $a2, 0x9e9694
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 52
	li $a2, 0xaca299
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 52
	li $a2, 0xc4b6b6
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 52
	li $a2, 0xe5d6ed
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 52
	li $a2, 0xfff8ff
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 52
	li $a2, 0xeae0eb
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 52
	li $a2, 0xebe2e3
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 52
	li $a2, 0xfdf3f1
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 52
	li $a2, 0xfefbff
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 52
	li $a2, 0xd6dcfe
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 52
	li $a2, 0xa8b1d2
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 52
	li $a2, 0xe2e5ec
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 52
	li $a2, 0xdddddf
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 52
	li $a2, 0xb2b5c6
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 52
	li $a2, 0xa2a4b9
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 52
	li $a2, 0xedebf9
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 52
	li $a2, 0xecdad8
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 52
	li $a2, 0xd2a68b
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 52
	li $a2, 0xeab080
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 52
	li $a2, 0xe2a668
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 52
	li $a2, 0xf9c177
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 52
	li $a2, 0xffda87
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 52
	li $a2, 0xf2c479
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 52
	li $a2, 0xdfa273
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 52
	li $a2, 0xaf6d4b
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 56
	li $a2, 0xf1b9c2
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 56
	li $a2, 0xcc9ea8
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 56
	li $a2, 0xf5dae9
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 56
	li $a2, 0xdcd0e6
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 56
	li $a2, 0x938fb4
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 56
	li $a2, 0x8686a2
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 56
	li $a2, 0x636162
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 56
	li $a2, 0xbab4a8
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 56
	li $a2, 0xe7dad1
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 56
	li $a2, 0xdfcfcf
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 56
	li $a2, 0xcdbccc
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 56
	li $a2, 0xf1e4f6
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 56
	li $a2, 0xfff9ff
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 56
	li $a2, 0xfffbff
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 56
	li $a2, 0xfffcf6
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 56
	li $a2, 0xfff8f5
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 56
	li $a2, 0xf0dce8
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 56
	li $a2, 0xd6c1d2
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 56
	li $a2, 0xe5d3df
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 56
	li $a2, 0xcbbec7
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 56
	li $a2, 0xcabecc
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 56
	li $a2, 0xcbc2d7
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 56
	li $a2, 0xcec6eb
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 56
	li $a2, 0xcebbd7
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 56
	li $a2, 0xcca3a1
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 56
	li $a2, 0xdcaa8f
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 56
	li $a2, 0xd9b180
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 56
	li $a2, 0xe1be86
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 56
	li $a2, 0xd7b784
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 56
	li $a2, 0xf0d3ab
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 56
	li $a2, 0xb79b85
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 56
	li $a2, 0x73574b
	jal DRAW_SQUARE
	li $a0, 0
	li $a1, 60
	li $a2, 0xffdbe9
	jal DRAW_SQUARE
	li $a0, 4
	li $a1, 60
	li $a2, 0xffe2f1
	jal DRAW_SQUARE
	li $a0, 8
	li $a1, 60
	li $a2, 0xd2bfd2
	jal DRAW_SQUARE
	li $a0, 12
	li $a1, 60
	li $a2, 0xdedaf3
	jal DRAW_SQUARE
	li $a0, 16
	li $a1, 60
	li $a2, 0xa1a2ce
	jal DRAW_SQUARE
	li $a0, 20
	li $a1, 60
	li $a2, 0x727797
	jal DRAW_SQUARE
	li $a0, 24
	li $a1, 60
	li $a2, 0x5e5f5a
	jal DRAW_SQUARE
	li $a0, 28
	li $a1, 60
	li $a2, 0xded9c6
	jal DRAW_SQUARE
	li $a0, 32
	li $a1, 60
	li $a2, 0xfceee5
	jal DRAW_SQUARE
	li $a0, 36
	li $a1, 60
	li $a2, 0xe3d1d1
	jal DRAW_SQUARE
	li $a0, 40
	li $a1, 60
	li $a2, 0xdacad5
	jal DRAW_SQUARE
	li $a0, 44
	li $a1, 60
	li $a2, 0xfff5ff
	jal DRAW_SQUARE
	li $a0, 48
	li $a1, 60
	li $a2, 0xfff6ff
	jal DRAW_SQUARE
	li $a0, 52
	li $a1, 60
	li $a2, 0xfff8fe
	jal DRAW_SQUARE
	li $a0, 56
	li $a1, 60
	li $a2, 0xfff1ea
	jal DRAW_SQUARE
	li $a0, 60
	li $a1, 60
	li $a2, 0xf5ded8
	jal DRAW_SQUARE
	li $a0, 64
	li $a1, 60
	li $a2, 0xe4c1c5
	jal DRAW_SQUARE
	li $a0, 68
	li $a1, 60
	li $a2, 0xf5d1db
	jal DRAW_SQUARE
	li $a0, 72
	li $a1, 60
	li $a2, 0xefd3e1
	jal DRAW_SQUARE
	li $a0, 76
	li $a1, 60
	li $a2, 0xe4d0dc
	jal DRAW_SQUARE
	li $a0, 80
	li $a1, 60
	li $a2, 0xf2dee9
	jal DRAW_SQUARE
	li $a0, 84
	li $a1, 60
	li $a2, 0xf3e4f9
	jal DRAW_SQUARE
	li $a0, 88
	li $a1, 60
	li $a2, 0xcec5f4
	jal DRAW_SQUARE
	li $a0, 92
	li $a1, 60
	li $a2, 0xbba9d3
	jal DRAW_SQUARE
	li $a0, 96
	li $a1, 60
	li $a2, 0xedc5ce
	jal DRAW_SQUARE
	li $a0, 100
	li $a1, 60
	li $a2, 0xffd9c6
	jal DRAW_SQUARE
	li $a0, 104
	li $a1, 60
	li $a2, 0xfcdcb5
	jal DRAW_SQUARE
	li $a0, 108
	li $a1, 60
	li $a2, 0xffe7b7
	jal DRAW_SQUARE
	li $a0, 112
	li $a1, 60
	li $a2, 0xf1d7b4
	jal DRAW_SQUARE
	li $a0, 116
	li $a1, 60
	li $a2, 0xffedd4
	jal DRAW_SQUARE
	li $a0, 120
	li $a1, 60
	li $a2, 0x80716a
	jal DRAW_SQUARE
	li $a0, 124
	li $a1, 60
	li $a2, 0x524847
	jal DRAW_SQUARE
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra