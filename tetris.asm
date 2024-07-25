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

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################

	.text
	.globl main

	# Run the Tetris game.
main:
    # Initialize the game

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	li $s7, 0x0000ff        # $s7 = blue
	li $s6, 0x17161A	 # $s6 = dark grey
	li $s5, 0x454545	 # $s5 = light grey
		
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
	
	addi $sp, $sp, -4
	sw $s0, ($sp)
	addi $sp, $sp, -4
	sw $s2, ($sp)
	addi $sp, $sp, -4
	sw $s7, ($sp)
	jal Draw_Col
	
	addi $s0, $s0,44
	
	# draws the right edge of border
	
	addi $sp, $sp, -4
	sw $s0, ($sp)
	addi $sp, $sp, -4
	sw $s2, ($sp)
	addi $sp, $sp, -4
	sw $s7, ($sp)
	jal Draw_Col
	
	# draws the bottom edge of border
	
	addi $s0, $s0, 2644
	
	addi $sp, $sp, -4
	sw $s0, ($sp)
	addi $sp, $sp, -4
	sw $s1, ($sp)
	addi $sp, $sp, -4
	sw $s7, ($sp)
	jal Draw_Row
	
	# draws checkerboard pattern
	
	lw $s0, ADDR_DSPL       # $s0 = base address for display
	addi $s0, $s0, 1064
	addi $s1, $zero, 10
	addi $s2, $zero, 20
	
	addi $t2, $zero, 0
	li $t4, 0
	BG_Row: 
		beq $t2, $s2, BG_End_Row
		xori $t4, $t4, 1
		addi $t2, $t2, 1
		addi $s0, $s0, 128
		addi $t0, $s0, 0
		
		
		addi $t1, $zero, 0
		BG_Col:
			beq $t1, $s1, BG_Row
			addi $t1, $t1, 1
			addi $t0, $t0, 4
			beqz $t4 Light_Gray_Square
			xori $t4, $t4, 1
			sw $s6, ($t0)
			j BG_Col
			Light_Gray_Square: sw $s5, ($t0)
			xori $t4, $t4, 1
			j BG_Col
	BG_End_Row:
	# 4. Sleep

    #5. Go back to 1
    b game_loop
	Draw_Row:
		# t3 = color, t1 = length, t0 = starting position
		lw $t3, ($sp)
		addi $sp, $sp, 4
		lw $t1, ($sp)
		addi $sp, $sp, 4
		lw $t0, ($sp)
		addi $sp, $sp, 4
		
		Loop_Row:
		beqz $t1, End_Row 
		sw $t3, ($t0)
		addi $t0, $t0, 4
		subi $t1, $t1, 1
		j Loop_Row
		End_Row: jr $ra
	Draw_Col:
		# t3 = color, t1 = length, t0 = starting position
		lw $t3, ($sp)
		addi $sp, $sp, 4
		lw $t1, ($sp)
		addi $sp, $sp, 4
		lw $t0, ($sp)
		addi $sp, $sp, 4
		Loop_Col:
		beqz $t1, End_Col
		sw $t3, ($t0)
		addi $t0, $t0, 128
		subi $t1, $t1, 1
		j Loop_Col
		End_Col: jr $ra