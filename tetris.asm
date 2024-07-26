#####################################################################
# CSCB58 Summer 2024 Assembly Final Project - UTSC
# Student1: Name, Student Number, UTorID, official email
# Student2: Name, Student Number, UTorID, official email
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed) 
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved features have been implemented?
# (See the assignment handout for the list of features)
# Easy Features:
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# ... (add more if necessary)
# Hard Features:
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# ... (add more if necessary)
# How to play:
# (Include any instructions)
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

##############################################################################

.data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
   
# the address of the top left corner of the playing field
PLAYSTART:
	.word 0x100084AC


# for each shape array, the first element is the number of pixels to be coloured
# the second is the hex code color
# then the rest are the pixels to be coloured offset from PLAYSTART, the top
# left corner of the play area (not including borders)
ISHAPE:
	.word 4, 0x00ffff, 0, 4, 8, 12



##############################################################################
# Mutable Data
##############################################################################

Board: .word 0:200

# posX and posY is position of the top left corner of the current block
# posX and posY is relative to PLAYSTART
posX: .word 12
posY: .word 0

##############################################################################
# Code
##############################################################################

	.text
	.globl main

	# Run the Tetris game.
main:
    # Initialize the game
	la    $t0, Board          # Load base address of the array into $t0
   	li    $t1, 200           # Load the size of the array into $t1
   	li    $t2, 0              # Initialize index to 0

	j build_view
	
init_loop:
    	beq   $t2, $t1, init_end       # If index equals size, exit loop
    	sll   $t3, $t2, 2         # Multiply index by 4 (size of word) to get offset
    	add   $t4, $t0, $t3       # Calculate address of array element
    	sw    $zero, 0($t4)       # Store 0 at the calculated address
    	addi  $t2, $t2, 4         # Increment index
    	j     init_loop                # Jump to the beginning of the loop

init_end:
	j build_view
	
build_view:
	# 1a. Check if key has been pressed
	# 1b. Check which key has been pressed
	# 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	li $s7, 0x0000ff        # $s7 = blue
	li $s6, 0x17161A	 # $s6 = dark grey
	li $s5, 0x454545	 # $s5 = light grey
	li $s4, 0x00ffff	 # $s5 = light blue
		
	lw $s0, ADDR_DSPL       # $t0 = base address for display
	addi $s0, $s0, 1064	 # move to the location of board
	addi $s1, $zero, 12     # number of col
	addi $s2, $zero, 22	 # number of rows
	
#	addi $sp, $sp, -4
#	sw $s0, ($sp)
#	sw $s1, ($sp)
#	addi $sp, $sp, -4
#	sw $s3, ($sp)
#	jal Draw_Row
	
	# draws the left edge of border
	
	addi $sp, $sp, -12
	sw $s0, 8($sp)
	sw $s2, 4($sp)
	sw $s7, ($sp)
	jal Draw_Col
	
	addi $s0, $s0,44
	
	# draws the right edge of border
	
	addi $sp, $sp, -12
	sw $s0, 8($sp)
	sw $s2, 4($sp)
	sw $s7, ($sp)
	jal Draw_Col
	
	# draws the bottom edge of border
	
	addi $s0, $s0, 2644
	
	addi $sp, $sp, -12
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s7, ($sp)
	jal Draw_Row
	
	j game_loop

game_loop:
	#Draws Board
	# Draw ISHAPE for now
	la $a0, ISHAPE
	la $a1, posX
	lw $a1, 0($a1)
	la $a2, posY
	lw $a2, 0($a2)

	jal Add_Shape
	
	
	# prepare to draw board
	lw $s0, ADDR_DSPL       # $s0 = base address for display
	addi $s0, $s0, 1064
	addi $s1, $zero, 10
	addi $s2, $zero, 20
	la $s3, Board
	
	addi $sp, $sp, -16
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	jal Draw_Board
	
	la $a0, ISHAPE
	jal Lower_shape
    
    	 

    	
    	j game_loop
	
#Functions

Lower_shape:	
	# $t0 is the shape array
	# $a0 must be set to the shape array
	move $t0, $a0
	
	# Sleep
	li   $a0, 1000           # Load the number of miliseconds to sleep into $a0
    	li   $v0, 32          # Syscall number for sleep (32)
    	syscall               # Make the syscall to sleep
	
	# Move the shape from Board
	# we can reuse the Add_shape function, just set the color to 0
	

	
	# $t1 = shapes colour
	lw $t1, 4($t0)

	# store 0 in replacement of it
	sw $zero, 4($t0)
	
	# arguments for Add_shape, $a0 already stores shape array
	move $a0, $t0
	la $a1, posX
	lw $a1, 0($a1)
	la $a2, posY
	lw $a2, 0($a2)
	
	# save our arguments 
	# store RA
	
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	
	# store the colour
	sw $t1, 0($sp)
	
	
	jal Add_Shape
	lw $t1, 0($sp)
	lw $ra, 4($sp)
	move $t0, $a0
	
	addi $sp, $sp, 8
	
	# set the original colour back
	sw $t1, 4($t0)
	
	
	# add 4 to posY
	la $t0, posY
	lw $t1, 0($t0)
	addi $t1, $t1, 4
	sw $t1, 0($t0)
	
	jr $ra
	
Add_Shape:

	# must set $a0 to the address of the shape array
	# must set $a1 to posX
	# must set $a2 to posY
	
	# This method adds a shape's data to the Board array
	# shape arrays are stored as 
	# [n, c, i for i in range(n)]
	# [pixels in shape, color, points to be drawn for i in range(pixels)]
	# t2 = number of pixels in shape
	# t3 = color of shape
	
	la $s3, Board
	la $t0, PLAYSTART # load location of where the top left of playfield is
	move $t1, $a0 # load the shape array
	
	# load the number of pixels and color
	lw $t2, 0($t1) 
	addi $t1, $t1, 4
	lw $t3, 0($t1) 
	addi $t1, $t1, 4
	
	j add_to_grid
	add_to_grid:
		beqz $t2, finished_adding
		subi $t2, $t2, 1
		
		# get value of ISHAPE[i], the pixel to be added to the grid
		lw $t4, 0($t1)
		# increment array
		addi $t1, $t1, 4
		
		
		# calculate offset due to posY
		addi $t5, $zero, 10
		mult $t5, $a2
		mflo $t5
		
		# calculate offset due to posX
		add $t5, $t5, $a1
		
		# add the color to the Board using calculated offset
		# then restore the Board to its starting address
		add $t4, $t4, $t5
		add $s3, $s3, $t4
		sw $t3, 0($s3)
		la $s3, Board
		
		j add_to_grid
		
	finished_adding:
		jr $ra
	
	
	
	
	
	
Draw_Board:
	# s0 = draw location, s1 = colums, s2 = rows, s3 = pointer of index 0 for board array
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	
	# colors
	li $s7, 0x0000ff        # $s7 = blue
	li $s6, 0x17161A	 # $s6 = dark grey
	li $s5, 0x454545	 # $s5 = light grey
	
	#loops rows
	# t2 is row index
	addi $t2, $zero, 0
	li $t4, 0
	Board_Row: 
		beq $t2, $s2, Board_End_Row
		# flip t4, increment t2, shift s0 down one row, 
		xori $t4, $t4, 1
		addi $t2, $t2, 1
		addi $s0, $s0, 128
		addi $t0, $s0, 0 # set t0 to s0 (s0 is the start location of the row)
		
		# t0 will be the location to draw
		
		# t1 is index for col
		addi $t1, $zero, 0
		Board_Col:
			lw $t5, ($s3) #loads the value of array at current pos (Board[t2][t1])
			beq $t1, $s1, Board_Row	# if end of the row, move to the next row
			#increment t1 by 1
			addi $t1, $t1, 1
			#shift by one unit of display to the right
			addi $t0, $t0, 4
			# check if Board[t2][t1] is empty
			beqz $t5, Empty_Space
			# draw the color of Board[t2][t1]
			sw $t5, ($t0)
			j Board_Col_End
			Empty_Space:
			#if t4 = 1 draw Dark grey , else draw light grey
			beqz $t4 Light_Gray_Square
			sw $s6, ($t0)
			j Board_Col_End
			Light_Gray_Square: sw $s5, ($t0)
			
		Board_Col_End: 
			# shifts pointer to next element of array
			addi $s3, $s3, 4
			# flip t4
			xori $t4, $t4, 1
			j Board_Col

	Board_End_Row: jr $ra



	Draw_Row:
		# t3 = color, t1 = length, t0 = starting position
		lw $t3, 0($sp)
		lw $t1, 4($sp)
		lw $t0, 8($sp)
		addi $sp, $sp, 12
		Loop_Row:
		beqz $t1, End_Row 
		sw $t3, ($t0)
		addi $t0, $t0, 4
		subi $t1, $t1, 1
		j Loop_Row
		End_Row: jr $ra
	Draw_Col:
		# t3 = color, t1 = length, t0 = starting position
		lw $t3, 0($sp)
		lw $t1, 4($sp)
		lw $t0, 8($sp)
		addi $sp, $sp, 12
		Loop_Col:
		beqz $t1, End_Col
		sw $t3, ($t0)
		addi $t0, $t0, 128
		subi $t1, $t1, 1
		j Loop_Col
		End_Col: jr $ra
