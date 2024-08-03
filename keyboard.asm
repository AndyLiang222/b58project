 ##############################################################################
# Example: Keyboard Input
#
# This file demonstrates how to read the keyboard to check if the keyboard
# key q was pressed.
##############################################################################
    .data
ADDR_KBRD:
    .word 0xffff0000
speed: .word 20
songSpeed: .word 1
songCount: .word 0
noteCount: .word 0
songLen: .word  288
tetris_theme: .word 64, 59, 60, 62, 60, 59, 57, 57, 60, 64, 62, 60, 59, 60, 62, 64, 60, 57, 57,
                     62, 66, 69, 67, 66, 64, 60, 64, 62, 60, 59, 60, 62, 64, 60, 57, 57,
                     64, 59, 60, 62, 60, 59, 57, 57, 60, 64, 62, 60, 59, 60, 62, 64, 60, 57, 57,
                     62, 66, 69, 67, 66, 64, 60, 64, 62, 60, 59, 60, 62, 64, 60, 57, 57

tetris_durations: .word 4, 2, 2, 4, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 4, 4, 4,
                         4, 4, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4,
                         4, 4, 2, 2, 2, 2, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 4, 4, 4,
                         4, 4, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4

tetris_sync: .word 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1,
                     0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1,
                     1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1,
                     0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1
    .text
	.globl main

main:
	
	 la $t0, songSpeed
        lw $t0, 0($t0)
        la $t1, songCount
        lw $t1, 0($t1)
        #
        bne $t1, $t0, inc_song_count
        
        la $t4, noteCount
        lw $t5, 0($t4)

        la $s0, tetris_theme
        la $s1, tetris_durations
        la $s2, tetris_sync
        add $s0, $s0, $t5
       	add $s1, $s1, $t5
       	add $s2, $s2, $t5
       	lw $s0, 0($s0)
       	lw $s1, 0($s1)
       	lw $s2, 0($s2)
       	
       	move $a0, $s0
       	move $a1, $s1
       	li $a2, 1
       	li $a3, 64 
       	mul $a1, $a1, 200
       	beqz $s2, sync_note
       	li $v0, 31
       	j play_note
       	sync_note: li $v0, 31
       	play_note: syscall
        
        la $t6, songLen
        lw $t6, 0($t6)
        bne $t5, $t6, no_reset_song
        li $t5, -4
        no_reset_song:
        addi $t5, $t5, 4
        sw $t5, 0($t4)
        la $t5, songCount
        sw $zero, 0($t5)
        j end_note
        inc_song_count:
        	addi $t1, $t1, 1
        	la $t3, songCount
        	sw $t1, 0($t3)
        end_note:
        
        
        
        # should be 60 fps
	# Sleep
	li   $a0, 200          # Load the number of miliseconds to sleep into $a0
    	li   $v0, 32          # Syscall number for sleep (32)
    	syscall
        
        
    b main

keyboard_input:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed

    li $v0, 1                       # ask system to print $a0
    syscall

    b main

respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall
