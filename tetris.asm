#####################################################################
# CSCB58 Summer 2024 Assembly Final Project - UTSC
# Student1: Orion Chen, 1009972638, chenorio, orion.chen@mail.utoronto.ca
# Student2: Andy Liang, 1009847551, lianga34, andyyy.liang@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 
# - Unit height in pixels: 8 
# - Display width in pixels: 256 
# - Display height in pixels: 256 
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved features have been implemented?
# (See the assignment handout for the list of features)
# Easy Features:
# 1. Gravity
# 2. Gravity increases over the number of rows completed
# 3. Each Tetrimino is a different color
# 4. Save Feature for pieces
# ... (add more if necessary)
# Hard Features:
# 1. Full set of Tetriminos
# 2. Tetris Theme Song
# ... (add more if necessary)
# How to play:
# A and D to move the tetromino
# S to move the tetromino downwards
# Q to quit the game
# C to save the current piece / to swap it back out
# Everything else is normal tetris
# Link to video demonstration for final submission:
# - https://youtu.be/KQDbwbupPn0
#
# Are you OK with us sharing the video with people outside course staff?
# - yes
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
# then the rest are the pixels to be coloured offset from the center
# IMPORTANT: Draw each shape starting from the center
# posX will take care of centering it, as its set to 12 (center) by default
tempArray: .word 0:200
pieceArray: .word 0:7
curPiece: .word 4, 0x00ffff, 0, 4, 8, -4
savedPiece: .word 4, 0, 0, -4, 4, 40
rLSHAPE:
	.word 4, 0x0000ff, 0, 4, 8, -40
lLSHAPE:
	.word 4, 0xff7f00, 0, 4, 8, 40
TSHAPE:
	.word 4, 0x800080, 0, -4, 4, 40
rZSHAPE:
	.word 4, 0xff0000, 0, 4, 36, 40
lZSHAPE:
	.word 4, 0x00ff00, 0, -4, 40, 44
SqSHAPE:
	.word 4, 0xffff00, 0, 4, 40, 44
ISHAPE:
	.word 4, 0x00ffff, 0, 4, 8, -4



##############################################################################
# Mutable Data
##############################################################################

songLen: .word  288

tetris_theme: .word 64, 59, 60, 62, 60, 59, 57, 57, 60, 64, 62, 60, 59, 60, 62, 64, 60, 57, 57,
                     62, 65, 69, 67, 65, 64, 60, 64, 62, 60, 59, 60, 62, 64, 60, 57, 57,
                     64, 59, 60, 62, 60, 59, 57, 57, 60, 64, 62, 60, 59, 60, 62, 64, 60, 57, 57,
                     62, 65, 69, 67, 65, 64, 60, 64, 62, 60, 59, 60, 62, 64, 60, 57, 57

tetris_durations: .word 4, 2, 2, 4, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 4, 4, 4,
                         4, 4, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4,
                         4, 4, 2, 2, 2, 2, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 4, 4, 4,
                         4, 4, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4

# doesn't matter since sync notes don't work well
tetris_sync: .word 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1,
                     0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1,
                     1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1,
                     0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1


Board: .word 0:200
savedBoard: .word 0:200

# posX and posY is position of the top left corner of the current block
# posX and posY is relative to PLAYSTART
savedPosX: .word 8
savedPosY: .word 8
posX: .word 16
posY: .word 4
savedUsed: .word 0
rowsCleared: .word 0

speed: .word 20
songSpeed: .word 16
songCount: .word 0
noteCount: .word 0
frameCount: .word 0
keyboardBuffer: .word 

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
	
	la $s0, TSHAPE
	la $s1, SqSHAPE
	la $s2, lLSHAPE
	la $s3, rLSHAPE
	la $s4, lZSHAPE
	la $s5, rZSHAPE
	la $s6, ISHAPE
	
	la $t3, pieceArray
	sw $s0, ($t3)
	sw $s1, 4($t3)
	sw $s2, 8($t3)
	sw $s3, 12($t3)
	sw $s4, 16($t3)
	sw $s5, 20($t3)
	sw $s6, 24($t3)
	
	#set cur piece to a random piece
	
	jal new_piece

	j build_view
	
build_view:
	# 1a. Check if key has been pressed
	# 1b. Check which key has been pressed
	# 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	li $s7, 0x0000ff        # $s7 = blue
	li $s3, 0xffffff        # $s3 = white
	li $s6, 0x17161A	 # $s6 = dark grey
	li $s5, 0x454545	 # $s5 = light grey
	li $s4, 0x00ffff	 # $s5 = light blue
		
	lw $s0, ADDR_DSPL       # $t0 = base address for display
	addi $s0, $s0, 1064	 # move to the location of board
	addi $s1, $zero, 12     # number of col
	addi $s2, $zero, 22	 # number of rows
	
	# draws the left edge of border
	
	addi $sp, $sp, -12
	sw $s0, 8($sp)
	sw $s2, 4($sp)
	sw $s3, ($sp)
	jal Draw_Col
	
	addi $s0, $s0,44
	
	# draws the right edge of border
	
	addi $sp, $sp, -12
	sw $s0, 8($sp)
	sw $s2, 4($sp)
	sw $s3, ($sp)
	jal Draw_Col
	
	# draws the bottom edge of border
	
	addi $s0, $s0, 2644
	
	addi $sp, $sp, -12
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s3, ($sp)
	jal Draw_Row
	
	lw $s0, ADDR_DSPL       # $t0 = base address for display
	addi $s0, $s0, 1112	 # move to the location of board
	addi $s1, $zero, 6     # number of col
	addi $s2, $zero, 7
	
	addi $sp, $sp, -12
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s3, ($sp)
	jal Draw_Row
	
	addi $s0, $s0, 20
	
	addi $sp, $sp, -12
	sw $s0, 8($sp)
	sw $s2, 4($sp)
	sw $s3, ($sp)
	jal Draw_Col
	
	addi $s0, $s0, 748
	
	addi $sp, $sp, -12
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s3, ($sp)
	jal Draw_Row
	
	j game_loop

# THE MAIN FUNCTION responsible for repainting the game and movement
game_loop:
	
	# must put which shape to draw in $a0
	la $a0, curPiece
	jal Draw_screen
	
	# should be 60 fps
	# Sleep
	li   $a0, 16          # Load the number of miliseconds to sleep into $a0
    	li   $v0, 32          # Syscall number for sleep (32)
    	syscall               # Make the syscall to sleep
	
	# READ A/D INPUT HRE

	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
        lw $t8, 0($t0)                  # Load first word from keyboard
        beq $t8, 1, keyboard_input      # If first word 1, key is pressed
        
        # makes pieces drop at a cetain speed (easy feature 2)
        
        la $t0, frameCount
        lw $t1, 0($t0)
        la $t0, speed
        lw $t2, 0($t0)
        
        la $t3, rowsCleared
        lw $t3, 0($t3)
        
        div $t4, $t3, 1
        sub $t2, $t2, $t4
        bge $t2, 5, valid_speed
        li $t2, 5
        valid_speed:
        bge $t2, $t1, End_Drop
        Drop:
        	# lower the piece by one
        	# must put which shape to draw in $a1
		la $a1, curPiece
		jal Lower_shape
		# reset frame count in $t1
		li $t1, 0
		
	End_Drop: 
		# inc frame Count by one
		addi $t1, $t1, 1
		la $t0, frameCount
        	sw $t1, 0($t0)
        
        #--------------------------------------------
        # Code to play song
        #--------------------------------------------
        
        la $t0, songSpeed
        lw $t0, 0($t0)
        la $t1, songCount
        lw $t1, 0($t1)
        # plays note based on song speed
        bne $t1, $t0, inc_song_count
        # index of current note
        la $t4, noteCount
        lw $t5, 0($t4)
	# load the note, duration and sync
        la $s0, tetris_theme
        la $s1, tetris_durations
        la $s2, tetris_sync
        # load the current note
        add $s0, $s0, $t5
       	add $s1, $s1, $t5
       	add $s2, $s2, $t5
       	lw $s0, 0($s0)
       	lw $s1, 0($s1)
       	lw $s2, 0($s2)
       	
       	# a0 = note, a1 = duration, a2 = instrument (0-8 is piano idk the difference), a3 = volume, 
       	move $a0, $s0
       	move $a1, $s1
       	li $a2, 2
       	li $a3, 64
       	# a1 takes in milliseconds => multiply by 250 milliseconds per unit of duration 
       	mul $a1, $a1, 250
       	# this doesn't really do anything as sync note doesn't work well so I made it only use the syscall
       	# for async notes
       	beqz $s2, sync_note
       	li $v0, 31
       	j play_note
       	sync_note: li $v0, 31
       	play_note: syscall
       	# if reach the end of the song reset to beginning
       	la $t6, songLen
        lw $t6, 0($t6)
        bne $t5, $t6, no_reset_song
        li $t5, -4
        no_reset_song:
        # shift to next note and reset the songCount
        addi $t5, $t5, 4
        sw $t5, 0($t4)
        la $t5, songCount
        sw $zero, 0($t5)
        j end_note
        inc_song_count:
        	# increment the song count
        	addi $t1, $t1, 1
        	la $t3, songCount
        	sw $t1, 0($t3)
        end_note:
        
        
	
    	j game_loop
    	

# returns A % B
mod:
	lw $s0, 4($sp) # A
	lw $s1, 0($sp) # B
	addi $sp, $sp, 8

	div $s2, $s0, $s1
	mul $s1, $s1, $s2
	sub $s0, $s0, $s1

	addi $sp, $sp, -4
	sw $s0, 0($sp)

	jr $ra

save_piece:
	la $t0, savedUsed
	lw $t1, 0($t0)
	bnez $t1, ret
	li $t2, 1
	sw $t2, 0($t0)
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, curPiece
	jal Remove_shape
	
	li $t0, 16
	li $t1, 4
	la $a1, posX
	sw $t0, 0($a1)
	la $a2, posY
	sw $t1, 0($a2)
	
	jal swap_cur_piece
	
	la $t0, curPiece
	lw $t1, 4($t0)
	
	beqz $t1, no_saved_piece
	
	la $a0, curPiece
	jal Remove_shape_saved
	
	j end_saved_piece
	
	
	no_saved_piece:
	# sets the savedPiece to the curPiece
	
	jal new_piece
	
	end_saved_piece:
	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	j ret

clear_line:
	la $s0, rowsCleared
	lw $s1, 0($s0)
	addi $s1, $s1, 1
	sw $s1, 0($s0)
	la $s0, Board
	lw $s1, 0($sp) # start of row to clear
	addi $sp, $sp, 4
	# t2 holds the # of coloured squares, it initially starts at 0 which
	# causes this function to run
	
	j loop_delete
	loop_delete:
		beq $s0, $s1 , end_delete
		subi $s1, $s1, 4
		lw $s2, 0($s1)
		sw $s2, 40($s1)

		# go to next square in board
		
		j loop_delete

	end_delete:
		j ret

check_for_full_rows:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $a0, $zero, 800
	addi $a1, $zero, 40
	addi $a2, $zero, 10
	la $t0, Board
	move $t5, $t0
	move $t1, $zero # for loop counter
	move $t2, $zero # number of cells in the current row that are coloured
	j loop_row

	check_row:

		# if t
		bne $a2, $t2, no_clear_line
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		jal clear_line
		no_clear_line:
		move $t2, $zero
		move $t5, $t0
		beq $a0, $t1, End_Check_Full_Rows # if we have looped to the end of the board then go back
		j loop_row


	loop_row:
		lw $t3, 0($t0) # the colour of Board[i][j]
		beqz $t3, empty_square
		
		# increment number of coloured squares in current row
		addi $t2, $t2, 1
		empty_square:
		addi $t1, $t1, 4 # update for loop
		addi $t0, $t0, 4 # move the array 


		

		# check if we looped to the end of the row
		# just need to see if counter % 40 == 0, which if it is,
		# then we have started a new row
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		addi $sp, $sp, -4
		sw $a1, 0($sp)

		jal mod

		lw $t4, 0($sp)
		addi $sp, $sp, 4
		beqz $t4, check_row

		# otherwise restart the loop
		j loop_row
   	
    	End_Check_Full_Rows:
    		lw $ra, 0($sp)
    		addi $sp, $sp, 4
    		j ret

# function to set the cur piece to the piece that is addressed in $t0
set_cur_piece:
	la $t1, curPiece
	# loops through each element in the piece array and copies it from ($t0) to curPiece
	li $t2, 0
	li $t3, 6
	set_loop:
		beq $t2, $t3, end_set_loop
		lw $t4, 0($t0)
		sw $t4, 0($t1)
		addi $t0, $t0, 4
		addi $t1, $t1, 4
		addi $t2, $t2, 1
		j set_loop
	end_set_loop: jr $ra

swap_cur_piece:
	la $t1, curPiece
	la $t5, savedPiece
	# loops through each element in the piece array and copies it from ($t0) to curPiece
	li $t2, 0
	li $t3, 6
	swap_loop:
		beq $t2, $t3, end_swap_loop
		lw $t4, 0($t5)
		lw $t6, 0($t1)
		sw $t4, 0($t1)
		sw $t6, 0($t5)
		addi $t1, $t1, 4
		addi $t5, $t5, 4
		addi $t2, $t2, 1
		j swap_loop
	end_swap_loop: jr $ra

#Functions
new_piece:
	# random number between 0-6 inclusive
	li $v0, 42
	li $a0, 0
	li $a1, 7
	syscall
	# get the piece at index $a0
	mul $a0, $a0, 4
	la $t0, pieceArray
	add $t0, $t0, $a0
	lw $t0, 0($t0)
	
	# store our $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	# set curPiece to random Piece
	jal set_cur_piece
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
keyboard_input:                     # A key is pressed
	lw $a0, 4($t0)                  # Load second word from keyboard
	beq $a0, 0x61, respond_to_a     # Check if the key q was pressed
	beq $a0, 0x64, respond_to_d
	beq $a0, 0x77, respond_to_w
	beq $a0, 0x71, respond_to_q
	beq $a0, 0x73, respond_to_s
	beq $a0, 0x63, respond_to_c
	j game_loop

# Remove a shape's data from Board, it just calls Add_shape
# except the colour is set to 0, so it acts as removing it
Remove_shape:
	# takes $a0 as the shape array
	
	# $t1 = shapes colour
	lw $t1, 4($a0)

	# store 0 in replacement of it
	sw $zero, 4($a0)
	
	# arguments for Add_shape, $a0  stores shape array
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
	
	addi $sp, $sp, 8
	
	# set the original colour back
	sw $t1, 4($a0)
	jr $ra
	
# Remove a shape's data from Board, it just calls Add_shape
# except the colour is set to 0, so it acts as removing it
Remove_shape_saved:
	# takes $a0 as the shape array
	
	# $t1 = shapes colour

	lw $t1, 4($a0)

	# store 0 in replacement of it
	sw $zero, 4($a0)
	
	# arguments for Add_shape, $a0  stores shape array
	la $a1, savedPosX
	lw $a1, 0($a1)
	la $a2, savedPosY
	lw $a2, 0($a2)
	
	# save our arguments 
	# store RA
	
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	
	# store the colour
	sw $t1, 0($sp)
	
	
	jal Add_Shape_Saved
	lw $t1, 0($sp)
	lw $ra, 4($sp)
	
	addi $sp, $sp, 8
	
	# set the original colour back
	sw $t1, 4($a0)
	jr $ra

# this function removes the current shape from the board
# and updates the piece to rotate 90 degrees clockwise
# the new shape is repainted

rotate:
	# takes in $a0 which is the piece array 
	# store our $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# store our $a0
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	jal Remove_shape

	# load our $a0 back
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	
	la $s7, tempArray
	
	li $t0, 0
	lw $t1, 0($a0)
	add $t2, $a0, 8
	# loop through each unit of the piece
	Rotate_Loop:
		beq $t0, $t1, End_Rotate_Loop
		lw $s0, 0($t2)
		
		sw $s0, 0($s7)
		addi $s7, $s7, 4
		
		li $t5, -36
		li $t6, 36
		# there are two cases that mess up the rotate since the div doesn't does mod weirdly (-36 mod 10 = -6 and not 4)
		beq $t5, $s0, edge_case_1
		beq $t6, $s0, edge_case_2
			# divides the value by 10 to get the offset y and offset x
			li $s1, 10
			div $s0, $s1
			mfhi $s2 # x coordinate relative to pivot point
			mflo $s3 # y coordinate relative to pivot point	
			# x = -y and y = x will rotate it clockwise 90 degrees
			sub $s3, $zero, $s3
			# readd
			mul $s4, $s2, 10
			add $s4 , $s4, $s3
			j Rotate_Inc
		edge_case_1:
			li $s4, 44
			j Rotate_Inc
		edge_case_2:
			li $s4, -44
			j Rotate_Inc
		Rotate_Inc:
			sw $s4, 0($t2)
			addi $t2, $t2, 4
			addi $t0, $t0, 1
			j Rotate_Loop
		
		
	End_Rotate_Loop: 
	
	jal Check_Rotate_Collision
	beqz $v0, Rotate_Piece_End
	lw $t0, 0($a0)
	la $s1, tempArray
	add $t2, $a0, 8
	Reset_Rotate_Loop:
		beqz $t0, Rotate_Piece_End
		lw $s0, 0($s1)
		sw $s0, 0($t2)
		addi $t2, $t2, 4
		addi $s1, $s1, 4
		subi $t0, $t0, 1
		j Reset_Rotate_Loop
	
	Rotate_Piece_End:
	# load our $ra to go back to game_loop
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

Check_Rotate_Collision:

	la $s0, curPiece
	lw $s1, 0($s0)
	addi $s2, $s0, 8
	
	li $s7, 0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal Get_Position
	move $s3, $v0


	Loop_Piece_Rotate:
		beqz $s1, Loop_Piece_Rotate_End
		
		lw $s4, 0($s2)
		add $s5, $s3, $s4

	
		addi $sp, $sp, -4
		sw $s5, 0($sp)
		addi $sp, $sp, -4
		sw $s3, 0($sp)
		jal Check_Wall_Collision
		or $s7, $s7, $v0
		
		addi $sp, $sp, -4
		sw $s5, 0($sp)
		jal Check_Board_Collision
		or $s7, $s7, $v0
		
		addi $sp, $sp, -4
		sw $s5, 0($sp)
		jal Check_Floor_Collision
		or $s7, $s7, $v0
		
		bnez $s7, Loop_Piece_Rotate_End
		subi $s1, $s1, 1
		addi $s2, $s2, 4
		j Loop_Piece_Rotate
		
	Loop_Piece_Rotate_End: add $v0, $zero, $s7
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j ret

# this function removes the current shape from the board
# and updates posX, then it jumps to the game_loop where
# the new shape is repainted
move_horizontally:
	# $a0 is the shape array
	# a1 = -4/4 is the horizontal offset which is decided by the keystroke a/d 
	
	# store our $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# store our $a0
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	# store our $a1
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	
	jal Remove_shape
	
	# load our $a1 back
	lw $a1, 0($sp)
	addi $sp, $sp, 4
	
	# load our $a0 back
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	
	
	la $t0, posX
	lw $t1, 0($t0)
	# store the new updated posX
	add $t1, $t1, $a1
	sw $t1, 0($t0)
	
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	
	jal Check_Horizontal_Collision
	beqz $v0, Move_Horizontal_End
	
	la $t0, posX
	lw $t1, 0($t0)
	# store the new updated posX
	sub $t1, $t1, $a1
	sw $t1, 0($t0)
	
	Move_Horizontal_End:
	# load our $ra to go back to game_loop
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

Check_Horizontal_Collision:
	lw $s6, 0($sp)
	addi $sp, $sp, 4

	la $s0, curPiece
	lw $s1, 0($s0)
	addi $s2, $s0, 8
	li $s7, 0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal Get_Position
	move $s3, $v0

	Loop_Piece_Horrizontal:
		beqz $s1, Loop_Piece_Horrizontal_End
		lw $s4, 0($s2)
		add $s5, $s3, $s4
		
		addi $sp, $sp, -4
		sw $s5, 0($sp)
		sub $t8, $s5, $s6
		addi $sp, $sp, -4
		sw $t8, 0($sp)
		
		jal Check_Wall_Collision
		or $s7, $s7, $v0
		addi $sp, $sp, -4
		sw $s5, 0($sp)
		jal Check_Board_Collision
		or $s7, $s7, $v0
		bnez $s7, Loop_Piece_Horrizontal_End
		subi $s1, $s1, 1
		addi $s2, $s2, 4
		j Loop_Piece_Horrizontal
		
	Loop_Piece_Horrizontal_End: add $v0, $zero, $s7
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j ret

respond_to_a:
	la $a0, curPiece  
	addi $a1, $zero, -4
	j move_horizontally

respond_to_d:
	la $a0, curPiece 
	addi $a1, $zero, 4
	j move_horizontally
respond_to_w:
	la $a0, curPiece 
	j rotate
	
respond_to_q:
	li $v0, 10
	syscall
	
respond_to_s:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a1, curPiece
	jal Lower_shape
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	# drop the shape onto the board
	
respond_to_c:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal save_piece
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
# this function calls Add_Shape and Draw_board together
Draw_screen:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	#Draws Board
	la $a0, savedPiece
	la $a1, savedPosX
	lw $a1, 0($a1)
	la $a2, savedPosY
	lw $a2, 0($a2)

	jal Add_Shape_Saved
	
	#Draws Board
	la $a0, curPiece
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
	
	addi $sp, $sp, -20
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $zero, 16($sp)
	
	jal Draw_Board
	
	# prepare to draw saved board
	lw $s0, ADDR_DSPL       # $s0 = base address for display
	addi $s0, $s0, 1108
	addi $s1, $zero, 5
	addi $s2, $zero, 5
	la $s3, savedBoard
	
	addi $sp, $sp, -20
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	li $s4, 20
	sw $s4, 16($sp)
	
	jal Draw_Board
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# this function will remove the current shape from the board
# and increment the posY by 4 to shift it down
Lower_shape:	
	# $a1 must be set to the shape array
	
	
	# Move the shape from Board
	# we first have to remove it and then change posY
	move $a0, $a1

	# save our $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal Remove_shape
	
	# add 4 to posY
	la $t0, posY
	lw $t1, 0($t0)
	addi $t1, $t1, 4
	sw $t1, 0($t0)
	
	
	jal Check_Drop_Collision
	
	
	
	beqz $v0, End_Lower_Piece
	
	# subtract 4 to posY
	la $t0, posY
	lw $t1, 0($t0)
	subi $t1, $t1, 4
	sw $t1, 0($t0)
	
	# add shape back to Board
	la $a0, curPiece
	la $a1, posX
	lw $a1, 0($a1)
	la $a2, posY
	lw $a2, 0($a2)
	
	jal Add_Shape
	
	li $t0, 16
	li $t1, 4
	la $a1, posX
	sw $t0, 0($a1)
	la $a2, posY
	sw $t1, 0($a2)
	li $t1, 0
	la $a1, savedUsed
	sw $t1, 0($a1)
	jal new_piece
	
	jal check_for_full_rows
	
	jal Check_Spawn_Collision
	beqz $v0, End_Lower_Piece
	j respond_to_q
	
	End_Lower_Piece:
	
	# get our $ra back
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	
	
	jr $ra

Check_Wall_Collision:
	#previous position
	lw $t0, 0($sp)
	# new position
	lw $t1, 4($sp)
	addi $sp, $sp, 8
	div $t2, $t0, 40
	div $t3, $t1, 40
	li $v0, 0
	beq $t2, $t3, ret
	sub $t4, $t1, $t0
	bgez $t4, Not_Negative_Wall_Collision
	sub $t4, $zero, $t4
	Not_Negative_Wall_Collision:
	bge $t4, 20, ret
	li $v0, 1
	j ret

Check_Floor_Collision:
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	div $t1, $t0, 40
	li $v0, 1
	bge $t1, 20, ret
	li $v0, 0
	j ret

Check_Board_Collision:
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	
	
	
	la $t1, Board
	add $t1, $t1, $t0
	
	
	
	lw $t2, 0($t1)
	li $v0, 0
	beqz $t2, ret
	li $v0, 1
	j ret

Check_Drop_Collision:
	la $s0, curPiece
	lw $s1, 0($s0)
	addi $s2, $s0, 8
	li $s7, 0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal Get_Position
	move $s3, $v0

	Loop_Piece:
		beqz $s1, Loop_Piece_End
		lw $s4, 0($s2)
		add $s5, $s3, $s4
		addi $sp, $sp, -4
		sw $s5, 0($sp)
		jal Check_Floor_Collision
		or $s7, $s7, $v0
		addi $sp, $sp, -4
		sw $s5, 0($sp)
		jal Check_Board_Collision
		or $s7, $s7, $v0
		bnez $s7, Loop_Piece_End
		subi $s1, $s1, 1
		addi $s2, $s2, 4
		j Loop_Piece
		
	Loop_Piece_End: add $v0, $zero, $s7
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j ret

Check_Spawn_Collision:
	la $s0, curPiece
	lw $s1, 0($s0)
	addi $s2, $s0, 8
	li $s7, 0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal Get_Position
	move $s3, $v0

	Loop_Spawn_Piece:
		beqz $s1, Loop_Spawn_Piece_End
		lw $s4, 0($s2)
		add $s5, $s3, $s4
		
		addi $sp, $sp, -4
		sw $s5, 0($sp)
		jal Check_Board_Collision
		or $s7, $s7, $v0
		
		bnez $s7, Loop_Spawn_Piece_End
		subi $s1, $s1, 1
		addi $s2, $s2, 4
		j Loop_Spawn_Piece
	Loop_Spawn_Piece_End: add $v0, $zero, $s7
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j ret
	
	

Get_Position:

	
	la $t0, posY
	lw $t1, 0($t0)
	la $t0, posX
	lw $t2, 0($t0)
	mul $t1, $t1, 10
	add $t1, $t1, $t2

	move $v0, $t1
	j ret


ret: jr $ra
# this function adds the current shape coordinates with respect to its
# posY and posX into Board to prepare it for drawing
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

Add_Shape_Saved:
	# must set $a1 to posX
	# must set $a2 to posY
	
	# This method adds a shape's data to the Board array
	# shape arrays are stored as 
	# [n, c, i for i in range(n)]
	# [pixels in shape, color, points to be drawn for i in range(pixels)]
	# t2 = number of pixels in shape
	# t3 = color of shape
	
	la $s3, savedBoard
	la $t0, PLAYSTART # load location of where the top left of playfield is
	move $t1, $a0
	
	# load the number of pixels and color
	lw $t2, 0($t1) 
	addi $t1, $t1, 4
	lw $t3, 0($t1) 
	addi $t1, $t1, 4
	
	j add_to_grid_saved
	add_to_grid_saved:
		beqz $t2, finished_adding_saved
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
		la $s3, savedBoard
		
		j add_to_grid_saved
		
	finished_adding_saved:
		jr $ra

	
# this functiond draws the board according to hex values in Board

Draw_Board:
	# s0 = draw location, s1 = columns, s2 = rows, s3 = pointer of index 0 for board array
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp) 
	lw $s3, 12($sp)
	lw $s7, 16($sp)
	addi $sp, $sp, 20
	li $t4, 2
	
	div $s1, $t4
	mfhi $s4
	xor $s4, $s4, 1
	
	# colors

	li $s6, 0x17161A	 # $s6 = dark grey
	li $s5, 0x454545	 # $s5 = light grey
	
	#loops rows
	# t2 is row index
	addi $t2, $zero, 0
	li $t4, 0
	Board_Row: 
		beq $t2, $s2, Board_End_Row
		# flip t4, increment t2, shift s0 down one row, 
		xor $t4, $t4, $s4
		addi $t2, $t2, 1
		addi $s0, $s0, 128
		addi $t0, $s0, 0 # set t0 to s0 (s0 is the start location of the row)
		
		# t0 will be the location to draw
		
		# t1 is index for col
		addi $t1, $zero, 0
		Board_Col:
			lw $t5, ($s3) #loads the value of array at current pos (Board[t2][t1])
			beq $t1, $s1, Board_Row_End	# if end of the row, move to the next row
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
		Board_Row_End:
			add $s3, $s3, $s7
			j Board_Row
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
