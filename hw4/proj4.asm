# CSE 220 Programming Project #4
# Name: Karen Huang
# Net ID: karhuang
# SBU ID: 111644515

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

load_board:
	addi $sp, $sp, -16
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, ($sp) 
	
	move $s0, $a0 #board
	move $s1, $a1 #filename
	move $a0, $s1
	li $a1, 0 #read only
	li $v0, 13
	syscall #attempt to read the file
	move $s2, $v0 #file descriptor
	beq $s2, -1, load_exit #file does not exist
	
	#get number of rows
	move $a0, $s2
	move $a1, $s0
	li $a2, 1
	li $v0, 14
	syscall
	lbu $t0, ($s0) #char to decimal
	addi $t0, $t0, -48
	sb $t0, ($s0)
	
	addi $s0, $s0, 1
	
	move $a0, $s2
	move $a1, $s0
	li $a2, 1
	li $v0, 14
	syscall
	lbu $t0, ($s0)
	beq $t0, '\n', load_column
	addi $t0, $t0, -48
	lbu $t1, -1($s0)
	li $t9, 10 #if 2 digits, first one would have been the tens digit
	mul $t1, $t1, $t9
	add $t1, $t1, $t0
	sb $t1, -1($s0)
	
	#skip the \n if 2 digit number
	li $a2, 1
	li $v0, 14
	syscall
	
	load_column:
	sb $0, ($s0)
	addi $s0, $s0, 3

	#get number of columns
	move $a0, $s2
	move $a1, $s0
	li $a2, 1
	li $v0, 14
	syscall
	lbu $t0, ($s0)
	addi $t0, $t0, -48
	sb $t0, ($s0)
	
	addi $s0, $s0, 1
	
	move $a0, $s2
	move $a1, $s0
	li $a2, 1
	li $v0, 14
	syscall
	lbu $t0, ($s0)
	beq $t0, '\n', load_loop_start
	addi $t0, $t0, -48
	lbu $t1, -1($s0)
	li $t9, 10
	mul $t1, $t1, $t9
	add $t1, $t1, $t0
	sb $t1, -1($s0)
	
	li $a2, 1
	li $v0, 14
	syscall
	
	load_loop_start:
	sb $0, ($s0)
	addi $s0, $s0, 3 
	li $t0, 0 #number of Xs
	li $t1, 0 #number of Os
	li $t2, 0 #number of invalid chars
	lbu $s3, -8($s0)
	
	load_loop: #goes until end of board
	beqz $s3, load_done
	move $a0, $s2
	move $a1, $s0
	li $a2, 1
	li $v0, 14
	syscall
	lbu $t9, ($s0)
	beq $t9, '\n', load_cont
	beq $t9, 'X', load_X
	beq $t9, 'O', load_O
	bne $t9, '.', load_inv
	
	addi $s0, $s0, 1 #next char
	j load_loop
	
	load_cont:
	addi $s3, $s3, -1
	j load_loop
	
	load_X:
	addi $t0, $t0, 1 #add to X count
	addi $s0, $s0, 1 #next char
	j load_loop
	
	load_O:
	addi $t1, $t1, 1 #add to O count
	addi $s0, $s0, 1 #next char
	j load_loop
	
	load_inv:
	li $t8, '.'
	sb $t8, ($s0) #replace invalid char
	addi $t2, $t2, 1 #add to inv char count
	addi $s0, $s0, 1 #next char
	j load_loop
	
	load_done:
	li $t3, 0
	sll $t0, $t0, 16
	add $t3, $t3, $t0
	sll $t1, $t1, 8
	add $t3, $t3, $t1
	add $t3, $t3, $t2
	move $v0, $t3
	
	load_exit:
	lw $s3, ($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	addi $sp, $sp, 16
    jr $ra

get_slot:
	addi $sp, $sp, -12
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s2, ($sp)

	move $s0, $a0 #board
	move $s1, $a1 #row
	move $s2, $a2 #col
	
	bltz $s1, get_inv
	bltz $s2, get_inv
	lw $t0, ($s0)
	bge $s1, $t0, get_inv
	lw $t0, 4($s0)
	bge $s2, $t0, get_inv
	
	mul $t1, $s1, $t0 #correct row placement
	add $t1, $t1, $s2 #correct column placement
	add $s0, $s0, $t1 
	addi $s0, $s0, 8 #board.slots[row][col]
	lbu $v0, ($s0)
	j get_exit
	
	get_inv:
	li $v0, -1
	
	get_exit:
	lw $s2, ($sp)
	lw $s1, 4($sp)
	lw $s0, 8($sp)
	addi $sp, $sp, 12
    jr $ra

set_slot:
	addi $sp, $sp, -16
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, ($sp) 
    
    move $s0, $a0 #board
	move $s1, $a1 #row
	move $s2, $a2 #col
	move $s3, $a3 #char
	
	bltz $s1, set_inv
	bltz $s2, set_inv
	lw $t0, ($s0)
	bge $s1, $t0, set_inv
	lw $t0, 4($s0)
	bge $s2, $t0, set_inv
    
    mul $t1, $s1, $t0 #correct row placement
	add $t1, $t1, $s2 #correct column placement
	add $s0, $s0, $t1 
	addi $s0, $s0, 8 #board.slots[row][col]
	sb $s3, ($s0)
	move $v0, $s3
	j set_exit
    
    set_inv:
	li $v0, -1
    
    set_exit:
    lw $s3, ($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	addi $sp, $sp, 16
    jr $ra

place_piece:
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, ($sp)
	
	move $s0, $a0 #board
	move $s1, $a1 #row
	move $s2, $a2 #col
	move $s3, $a3 #player
	
	bltz $s1, place_inv
	bltz $s2, place_inv
	lw $t0, ($s0)
	bge $s1, $t0, place_inv
	lw $t0, 4($s0)
	bge $s2, $t0, place_inv
	beq $s3, 'X', place
	beq $s3, 'O', place
	j place_inv
	
	place:
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot #checking whether board.slots[row][col] is a .
	bne $v0, '.', place_inv
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s3
	jal set_slot
	j place_exit
	
	place_inv:
	li $v0, -1
	
	place_exit:
	lw $s3, ($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
    jr $ra

game_status:
	move $t0, $a0 #board
	lw $t1, ($a0) #rows
	lw $t2, 4($a0) #cols
	mul $t1, $t1, $t2 #total things to go through
	addi $t0, $t0, 8 #place to start counting
	li $t8, 0 #Xs
	li $t9, 0 #Os
	
	status_loop:
	beqz $t1, status_done
	lbu $t2, ($t0)
	beq $t2, 'X', status_X
	beq $t2, 'O', status_O
	
	status_cont:
	addi $t1, $t1, -1
	addi $t0, $t0, 1
	j status_loop
	
	status_X:
	addi $t8, $t8, 1
	j status_cont
	
	status_O:
	addi $t9, $t9, 1
	j status_cont
	
	status_done:
	move $v0, $t8
	move $v1, $t9
    jr $ra

check_horizontal_capture:
	addi $sp, $sp, -24
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, ($sp)
	
	move $s0, $a0 #board
	move $s1, $a1 #row
	move $s2, $a2 #col
	move $s3, $a3 #player
	
	li $s4, 0 #pieces captured
	beq $s3, 'O', h_cap_player #check if player is O or X
	beq $s3, 'X', h_cap_player
	j h_cap_inv
	
	h_cap_player: #check if row col equals player (also checks if row/col valid)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot
	beq $v0, -1, h_cap_inv #invalid row/col
	bne $v0, $s3, h_cap_inv #not equal to player
	
	h_cap_1: #check [row][col-3]
	move $a0, $s0
	move $a1, $s1
	addi $t0, $s2, -3 #col-3
	move $a2, $t0
	jal get_slot
	bne $v0, $s3, h_cap_2
	
	move $a0, $s0
	move $a1, $s1
	addi $t0, $s2, -2 #col-2
	move $a2, $t0
	jal get_slot
	beq $v0, $s3, h_cap_2
	beq $v0, '.', h_cap_2
	
	move $a0, $s0
	move $a1, $s1
	addi $t0, $s2, -1 #col-1
	move $a2, $t0
	jal get_slot
	beq $v0, $s3, h_cap_2
	beq $v0, '.', h_cap_2
	
	#if both middle pieces are valid, change to . and add 2 to pieces captured
	move $a0, $s0
	move $a1, $s1
	addi $t0, $s2, -2 #col-2
	move $a2, $t0
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	move $a0, $s0
	move $a1, $s1
	addi $t0, $s2, -1 #col-1
	move $a2, $t0
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	addi $s4, $s4 ,2
	
	h_cap_2: #check [row][col+3]
	move $a0, $s0
	move $a1, $s1
	addi $t0, $s2, 3 #col+3
	move $a2, $t0
	jal get_slot
	bne $v0, $s3, h_cap_done

	move $a0, $s0
	move $a1, $s1
	addi $t0, $s2, 2 #col+2
	move $a2, $t0
	jal get_slot
	beq $v0, $s3, h_cap_done
	beq $v0, '.', h_cap_done
	
	move $a0, $s0
	move $a1, $s1
	addi $t0, $s2, 1 #col+1
	move $a2, $t0
	jal get_slot
	beq $v0, $s3, h_cap_done
	beq $v0, '.', h_cap_done
	
	#if both middle pieces are valid, change to . and add 2 to pieces captured
	move $a0, $s0
	move $a1, $s1
	addi $t0, $s2, 2 #col+2
	move $a2, $t0
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	move $a0, $s0
	move $a1, $s1
	addi $t0, $s2, 1 #col+1
	move $a2, $t0
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	addi $s4, $s4 ,2
	
	h_cap_done:
	move $v0, $s4
	j h_cap_exit
	
	h_cap_inv:
	li $v0, -1
	
	h_cap_exit:
	lw $s4, ($sp)
	lw $s3, 4($sp)
	lw $s2, 8($sp)
	lw $s1, 12($sp)
	lw $s0, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
    jr $ra

check_vertical_capture:
	addi $sp, $sp, -24
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, ($sp)
	
	move $s0, $a0 #board
	move $s1, $a1 #row
	move $s2, $a2 #col
	move $s3, $a3 #player
	
	li $s4, 0 #pieces captured
	beq $s3, 'O', v_cap_player #check if player is O or X
	beq $s3, 'X', v_cap_player
	j v_cap_inv
	
	v_cap_player: #check if row col equals player (also checks if row/col valid)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot
	beq $v0, -1, v_cap_inv #invalid row/col
	bne $v0, $s3, v_cap_inv #not equal to player
	
	v_cap_1: #check [row-3][col]
	move $a0, $s0
	addi $t0, $s1, -3 #row-3
	move $a1, $t0
	move $a2, $s2
	jal get_slot
	bne $v0, $s3, v_cap_2
	
	move $a0, $s0
	addi $t0, $s1, -2 #row-2
	move $a1, $t0
	move $a2, $s2
	jal get_slot
	beq $v0, $s3, v_cap_2
	beq $v0, '.', v_cap_2
	
	move $a0, $s0
	addi $t0, $s1, -1 #row-1
	move $a1, $t0
	move $a2, $s2
	jal get_slot
	beq $v0, $s3, v_cap_2
	beq $v0, '.', v_cap_2
	
	#if both middle pieces are valid, change to . and add 2 to pieces captured
	move $a0, $s0
	addi $t0, $s1, -2 #row-2
	move $a1, $t0
	move $a2, $s2
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	move $a0, $s0
	addi $t0, $s1, -1 #row-1
	move $a1, $t0
	move $a2, $s2
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	addi $s4, $s4 ,2
	
	v_cap_2: #check [row+3][col]
	move $a0, $s0
	addi $t0, $s1, 3 #row+3
	move $a1, $t0
	move $a2, $s2
	jal get_slot
	bne $v0, $s3, v_cap_done
	
	move $a0, $s0
	addi $t0, $s1, 2 #row+2
	move $a1, $t0
	move $a2, $s2
	jal get_slot
	beq $v0, $s3, v_cap_done
	beq $v0, '.', v_cap_done
	
	move $a0, $s0
	addi $t0, $s1, 1 #row+1
	move $a1, $t0
	move $a2, $s2
	jal get_slot
	beq $v0, $s3, v_cap_done
	beq $v0, '.', v_cap_done
	
	#if both middle pieces are valid, change to . and add 2 to pieces captured
	move $a0, $s0
	addi $t0, $s1, 2 #row+2
	move $a1, $t0
	move $a2, $s2
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	move $a0, $s0
	addi $t0, $s1, 1 #row+1
	move $a1, $t0
	move $a2, $s2
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	addi $s4, $s4 ,2
	
	v_cap_done:
	move $v0, $s4
	j v_cap_exit
	
	v_cap_inv:
	li $v0, -1
	
	v_cap_exit:
	lw $s4, ($sp)
	lw $s3, 4($sp)
	lw $s2, 8($sp)
	lw $s1, 12($sp)
	lw $s0, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
    jr $ra

check_diagonal_capture:
	addi $sp, $sp, -24
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, ($sp)
	
	move $s0, $a0 #board
	move $s1, $a1 #row
	move $s2, $a2 #col
	move $s3, $a3 #player
	
	li $s4, 0 #pieces captured
	beq $s3, 'O', d_cap_player #check if player is O or X
	beq $s3, 'X', d_cap_player
	j d_cap_inv
	
	d_cap_player: #check if row col equals player (also checks if row/col valid)
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot
	beq $v0, -1, d_cap_inv #invalid row/col
	bne $v0, $s3, d_cap_inv #not equal to player
	
	d_cap_1: #check [row-3][col-3]
	move $a0, $s0
	addi $t0, $s1, -3 #row-3
	move $a1, $t0
	addi $t0, $s2, -3 #col-3
	move $a2, $t0
	jal get_slot
	bne $v0, $s3, d_cap_2
	
	move $a0, $s0
	addi $t0, $s1, -2 #row-2
	move $a1, $t0
	addi $t0, $s2, -2 #col-2
	move $a2, $t0
	jal get_slot
	beq $v0, $s3, d_cap_2
	beq $v0, '.', d_cap_2
	
	move $a0, $s0
	addi $t0, $s1, -1 #row-1
	move $a1, $t0
	addi $t0, $s2, -1 #col-1
	move $a2, $t0
	jal get_slot
	beq $v0, $s3, d_cap_2
	beq $v0, '.', d_cap_2
	
	#if both middle pieces are valid, change to . and add 2 to pieces captured
	move $a0, $s0
	addi $t0, $s1, -2 #row-2
	move $a1, $t0
	addi $t0, $s2, -2 #col-2
	move $a2, $t0
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	move $a0, $s0
	addi $t0, $s1, -1 #row-1
	move $a1, $t0
	addi $t0, $s2, -1 #col-1
	move $a2, $t0
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	addi $s4, $s4 ,2
	
	d_cap_2: #check [row-3][col+3]
	move $a0, $s0
	addi $t0, $s1, -3 #row-3
	move $a1, $t0
	addi $t0, $s2, 3 #col+3
	move $a2, $t0
	jal get_slot
	bne $v0, $s3, d_cap_3
	
	move $a0, $s0
	addi $t0, $s1, -2 #row-2
	move $a1, $t0
	addi $t0, $s2, 2 #col+2
	move $a2, $t0
	jal get_slot
	beq $v0, $s3, d_cap_3
	beq $v0, '.', d_cap_3
	
	move $a0, $s0
	addi $t0, $s1, -1 #row-1
	move $a1, $t0
	addi $t0, $s2, 1 #col+1
	move $a2, $t0
	jal get_slot
	beq $v0, $s3, d_cap_3
	beq $v0, '.', d_cap_3
	
	#if both middle pieces are valid, change to . and add 2 to pieces captured
	move $a0, $s0
	addi $t0, $s1, -2 #row-2
	move $a1, $t0
	addi $t0, $s2, 2 #col+2
	move $a2, $t0
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	move $a0, $s0
	addi $t0, $s1, -1 #row-1
	move $a1, $t0
	addi $t0, $s2, 1 #col+1
	move $a2, $t0
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	addi $s4, $s4 ,2
	
	d_cap_3: #check [row+3][col-3]
	move $a0, $s0
	addi $t0, $s1, 3 #row+3
	move $a1, $t0
	addi $t0, $s2, -3 #col-3
	move $a2, $t0
	jal get_slot
	bne $v0, $s3, d_cap_4
	
	move $a0, $s0
	addi $t0, $s1, 2 #row+2
	move $a1, $t0
	addi $t0, $s2, -2 #col-2
	move $a2, $t0
	jal get_slot
	beq $v0, $s3, d_cap_4
	beq $v0, '.', d_cap_4
	
	move $a0, $s0
	addi $t0, $s1, 1 #row+1
	move $a1, $t0
	addi $t0, $s2, -1 #col-1
	move $a2, $t0
	jal get_slot
	beq $v0, $s3, d_cap_4
	beq $v0, '.', d_cap_4
	
	#if both middle pieces are valid, change to . and add 2 to pieces captured
	move $a0, $s0
	addi $t0, $s1, 2 #row+2
	move $a1, $t0
	addi $t0, $s2, -2 #col-2
	move $a2, $t0
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	move $a0, $s0
	addi $t0, $s1, 1 #row+1
	move $a1, $t0
	addi $t0, $s2, -1 #col-1
	move $a2, $t0
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	addi $s4, $s4 ,2
	
	d_cap_4: #check [row+3][col+3]
	move $a0, $s0
	addi $t0, $s1, 3 #row+3
	move $a1, $t0
	addi $t0, $s2, 3 #col+3
	move $a2, $t0
	jal get_slot
	bne $v0, $s3, d_cap_done
	
	move $a0, $s0
	addi $t0, $s1, 2 #row+2
	move $a1, $t0
	addi $t0, $s2, 2 #col+2
	move $a2, $t0
	jal get_slot
	beq $v0, $s3, d_cap_done
	beq $v0, '.', d_cap_done
	
	move $a0, $s0
	addi $t0, $s1, 1 #row+1
	move $a1, $t0
	addi $t0, $s2, 1 #col+1
	move $a2, $t0
	jal get_slot
	beq $v0, $s3, d_cap_done
	beq $v0, '.', d_cap_done
	
	#if both middle pieces are valid, change to . and add 2 to pieces captured
	move $a0, $s0
	addi $t0, $s1, 2 #row+2
	move $a1, $t0
	addi $t0, $s2, 2 #col+2
	move $a2, $t0
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	move $a0, $s0
	addi $t0, $s1, 1 #row+1
	move $a1, $t0
	addi $t0, $s2, 1 #col+1
	move $a2, $t0
	li $t0, '.'
	move $a3, $t0
	jal set_slot
	
	addi $s4, $s4 ,2
    
    d_cap_done:
	move $v0, $s4
	j d_cap_exit
	
	d_cap_inv:
	li $v0, -1
	
	d_cap_exit:
	lw $s4, ($sp)
	lw $s3, 4($sp)
	lw $s2, 8($sp)
	lw $s1, 12($sp)
	lw $s0, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
    jr $ra

check_horizontal_winner:
	addi $sp, $sp, -36
	sw $ra, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, ($sp)
	
	move $s0, $a0 #board
	move $s1, $a1 #player
	
	beq $s1, 'O', h_win_loop_start #check if player is O or X
	beq $s1, 'X', h_win_loop_start
	j h_win_inv
	
	h_win_loop_start:
	lw $s2, ($s0) #row
	lw $s3, 4($s0) #col
	li $s4, 0 #cur_row
	li $s5, 0 #cur_col
	
	h_win_loop:
	beq $s4, $s2, h_win_inv #went through all rows with no win
	li $s5, 0 #reset cur_col every row
	li $s6, 0 #number in a row
	move $s7, $s5 #temp_col
	
		h_win_inner:
		beq $s6, 5, h_win_done #win found
		beq $s7, $s3, h_win_cont #went through whole row

		move $a0, $s0
		move $a1, $s4
		move $a2, $s7
		jal get_slot
		bne $v0, $s1, h_inner_reset
		
		addi $s6, $s6, 1 #increase number in a row
		addi $s7, $s7, 1 #next col
		j h_inner_cont
		
		h_inner_reset: 
		li $s6, 0 #reset counter
		addi $s7, $s7, 1 #next col
		move $s5, $s7 #the leftmost col of a new possible win
		
		h_inner_cont:
		j h_win_inner
		
	h_win_cont:
	addi $s4, $s4, 1 #increase cur_row
	j h_win_loop
	
	h_win_done:
	move $v0, $s4
	move $v1, $s5
	j h_win_exit
	
	h_win_inv:
	li $v0, -1
	li $v1, -1
	
	h_win_exit:
	lw $s7, ($sp)
	lw $s6, 4($sp)
	lw $s5, 8($sp)
	lw $s4, 12($sp)
	lw $s3, 16($sp)
	lw $s2, 20($sp)
	lw $s1, 24($sp)
	lw $s0, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
    jr $ra

check_vertical_winner:
	addi $sp, $sp, -36
	sw $ra, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, ($sp)
	
	move $s0, $a0 #board
	move $s1, $a1 #player
	
	beq $s1, 'O', v_win_loop_start #check if player is O or X
	beq $s1, 'X', v_win_loop_start
	j v_win_inv
	
	v_win_loop_start:
	lw $s2, ($s0) #row
	lw $s3, 4($s0) #col
	li $s4, 0 #cur_row
	li $s5, 0 #cur_col
	
	v_win_loop:
	beq $s5, $s3, v_win_inv #went through all cols with no win
	li $s4, 0 #reset cur_row every col
	li $s6, 0 #number in a col
	move $s7, $s4 #temp_row
	
		v_win_inner:
		beq $s6, 5, v_win_done #win found
		beq $s7, $s2, v_win_cont #went through whole col

		move $a0, $s0
		move $a1, $s7
		move $a2, $s5
		jal get_slot
		bne $v0, $s1, v_inner_reset
		
		addi $s6, $s6, 1 #increase number in a col
		addi $s7, $s7, 1 #next row
		j v_inner_cont
		
		v_inner_reset: 
		li $s6, 0 #reset counter
		addi $s7, $s7, 1 #next row
		move $s4, $s7 #the topmost row of a new possible win
		
		v_inner_cont:
		j v_win_inner
		
	v_win_cont:
	addi $s5, $s5, 1 #increase cur_col
	j v_win_loop
	
	v_win_done:
	move $v0, $s4
	move $v1, $s5
	j v_win_exit
	
	v_win_inv:
	li $v0, -1
	li $v1, -1
	
	v_win_exit:
	lw $s7, ($sp)
	lw $s6, 4($sp)
	lw $s5, 8($sp)
	lw $s4, 12($sp)
	lw $s3, 16($sp)
	lw $s2, 20($sp)
	lw $s1, 24($sp)
	lw $s0, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
    jr $ra

check_sw_ne_diagonal_winner:
	addi $sp, $sp, -32
	sw $ra, 28($sp)
	sw $s0, 24($sp)
	sw $s1, 20($sp)
	sw $s2, 16($sp)
	sw $s3, 12($sp)
	sw $s4, 8($sp)
	sw $s5, 4($sp)
	sw $s6, ($sp)
	
	move $s0, $a0 #board
	move $s1, $a1 #player
	
	beq $s1, 'O', swne_win_col_start #check if player is O or X
	beq $s1, 'X', swne_win_col_start
	j swne_win_inv
	
	swne_win_col_start:
	lw $s2, 4($s0) #col
	addi $s2, $s2, -4 #end condition
	li $s3, 0 #col_cnt
	
	#one loop for going through row = row-1, col = 0 to col-4
	swne_win_col:
	beq $s3, $s2, swne_win_row_start #nothing found
	li $s4, 0 #consecutive
	lw $s5, ($s0)
	addi $s5, $s5, -1 #temp_row
	move $s6, $s3 #temp_col
	
		swne_col_inner:
		beq $s4, 5, swne_win_done #win found
		
		move $a0, $s0
		move $a1, $s5
		move $a2, $s6
		jal get_slot
		
		beq $v0, -1, swne_win_col_cont #went through whole col
		bne $v0, $s1, swne_col_inner_reset
		
		addi $s4, $s4, 1 #increase consecutive
		j swne_col_inner_cont
		
		swne_col_inner_reset: 
		li $s4, 0 #reset counter		
		
		swne_col_inner_cont:
		addi $s5, $s5, -1 #next row
		addi $s6, $s6, 1 #next col
		j swne_col_inner
		
	swne_win_col_cont:
	addi $s3, $s3, 1 #increase col_cnt
	j swne_win_col
	
	swne_win_row_start:
	lw $s2, ($s0) #row
	addi $s2, $s2, -1 #row_cnt
	li $s3, 4 #end condition
	
	#second loop for going through row = 0 to row-4 to col = 0
	swne_win_row:
	beq $s3, $s2, swne_win_inv #nothing found
	li $s4, 0 #consecutive
	move $s5, $s3 #temp_row
	li $s6, 0 #temp_col
	
		swne_row_inner:
		beq $s4, 5, swne_win_done #win found
		
		move $a0, $s0
		move $a1, $s5
		move $a2, $s6
		jal get_slot
		
		beq $v0, -1, swne_win_row_cont #went through whole row
		bne $v0, $s1, swne_row_inner_reset
		
		addi $s4, $s4, 1 #increase consecutive
		j swne_row_inner_cont
		
		swne_row_inner_reset: 
		li $s4, 0 #reset counter		
		
		swne_row_inner_cont:
		addi $s5, $s5, -1 #next row
		addi $s6, $s6, 1 #next col
		j swne_row_inner
		
	swne_win_row_cont:
	addi $s3, $s3, 1 #increase row_cnt
	j swne_win_row
	
	swne_win_done:
	addi $v0, $s5, 5
	addi $v1, $s6, -5
	j swne_win_exit
	
	swne_win_inv:
	li $v0, -1
	li $v1, -1
	
	swne_win_exit:
	lw $s6, ($sp)
	lw $s5, 4($sp)
	lw $s4, 8($sp)
	lw $s3, 12($sp)
	lw $s2, 16($sp)
	lw $s1, 20($sp)
	lw $s0, 24($sp)
	lw $ra, 28($sp)
	addi $sp, $sp, 32
    jr $ra

check_nw_se_diagonal_winner:
	addi $sp, $sp, -32
	sw $ra, 28($sp)
	sw $s0, 24($sp)
	sw $s1, 20($sp)
	sw $s2, 16($sp)
	sw $s3, 12($sp)
	sw $s4, 8($sp)
	sw $s5, 4($sp)
	sw $s6, ($sp)
	
	move $s0, $a0 #board
	move $s1, $a1 #player
	
	beq $s1, 'O', nwse_win_col_start #check if player is O or X
	beq $s1, 'X', nwse_win_col_start
	j nwse_win_inv
	
	nwse_win_col_start:
	lw $s2, 4($s0) #col
	addi $s2, $s2, -4 #end condition
	li $s3, 0 #col_cnt
	
	#one loop for going through row = 0, col = 0 to col-4
	nwse_win_col:
	beq $s3, $s2, nwse_win_row_start #nothing found
	li $s4, 0 #consecutive
	li $s5, 0 #temp_row
	move $s6, $s3 #temp_col
	
		nwse_col_inner:
		beq $s4, 5, nwse_win_done #win found
		
		move $a0, $s0
		move $a1, $s5
		move $a2, $s6
		jal get_slot
		
		beq $v0, -1, nwse_win_col_cont #went through whole col
		bne $v0, $s1, nwse_col_inner_reset
		
		addi $s4, $s4, 1 #increase consecutive
		j nwse_col_inner_cont
		
		nwse_col_inner_reset: 
		li $s4, 0 #reset counter		
		
		nwse_col_inner_cont:
		addi $s5, $s5, 1 #next row
		addi $s6, $s6, 1 #next col
		j nwse_col_inner
		
	nwse_win_col_cont:
	addi $s3, $s3, 1 #increase col_cnt
	j nwse_win_col
	
	nwse_win_row_start:
	lw $s2, ($s0) #row
	addi $s2, $s2, -4 #end condition
	li $s3, 0 #row_cnt
	
	#second loop for going through row = 0 to row-4 to col = 0
	nwse_win_row:
	beq $s3, $s2, nwse_win_inv #nothing found
	li $s4, 0 #consecutive
	move $s5, $s3 #temp_row
	li $s6, 0 #temp_col
	
		nwse_row_inner:
		beq $s4, 5, nwse_win_done #win found
		
		move $a0, $s0
		move $a1, $s5
		move $a2, $s6
		jal get_slot
		
		beq $v0, -1, nwse_win_row_cont #went through whole row
		bne $v0, $s1, nwse_row_inner_reset
		
		addi $s4, $s4, 1 #increase consecutive
		j nwse_row_inner_cont
		
		nwse_row_inner_reset: 
		li $s4, 0 #reset counter		
		
		nwse_row_inner_cont:
		addi $s5, $s5, 1 #next row
		addi $s6, $s6, 1 #next col
		j nwse_row_inner
		
	nwse_win_row_cont:
	addi $s3, $s3, 1 #increase row_cnt
	j nwse_win_row
	
	nwse_win_done:
	addi $v0, $s5, -5
	addi $v1, $s6, -5
	j nwse_win_exit
	
	nwse_win_inv:
	li $v0, -1
	li $v1, -1
	
	nwse_win_exit:
	lw $s6, ($sp)
	lw $s5, 4($sp)
	lw $s4, 8($sp)
	lw $s3, 12($sp)
	lw $s2, 16($sp)
	lw $s1, 20($sp)
	lw $s0, 24($sp)
	lw $ra, 28($sp)
	addi $sp, $sp, 32
    jr $ra

simulate_game:
	addi $sp, $sp, -36
	sw $ra, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, ($sp)
	
	move $s0, $a0 #board
	move $s1, $a1 #filename
	move $s2, $a2 #turns
	move $s3, $a3 #max turns
	
	#load board, if fail return 0,-1
	move $a0, $s0
	move $a1, $s1
	jal load_board
	bne $v0, -1, sim_start
	
	li $v0, 0
	li $v1, -1
	j sim_exit
	
	sim_start: #gameover if board is full or there is a winner
	li $t0, 0 #length counter for turns
	move $t1, $s2 #turns
	
	turn_len:
	lbu $t2, ($t1)
	beq $t2, '\n', turn_len_div
	addi $t0, $t0, 1 #increment length
	addi $t1, $t1, 1 #next char of turns
	j turn_len
	
	turn_len_div:
	li $t1, 5
	div $t0, $t1
	mflo $s1 #turns length
	
	li $s7, 0 #valid turns
	sim_loop:
	#s2 is the turns string
	beqz $s3, sim_no_winner #maximum turns played has been reached
	beqz $s1, sim_no_winner #attempted turns = turns length
	
	#extract the turn
	lbu $s4, ($s2) #player
	lbu $t0, 1($s2) #tens of row
	addi $t0, $t0, -48
	lbu $t1, 2($s2) #ones of row
	addi $t1, $t1, -48
	lbu $t2, 3($s2) #tens of col
	addi $t2, $t2, -48
	lbu $t3, 4($s2) #ones of col
	addi $t3, $t3, -48
	li $t4, 10
	mul $s5, $t0, $t4
	add $s5, $s5, $t1
	mul $s6, $t2, $t4
	add $s6, $s6, $t3
	#s5 is row, s6 is col
	
	move $a0, $s0
	move $a1, $s5
	move $a2, $s6
	move $a3, $s4
	jal place_piece
	
	beq $v0, -1, sim_loop_cont #placing failed
	
	#if successful, check the captures
	move $a0, $s0
	move $a1, $s5
	move $a2, $s6
	move $a3, $s4
	jal check_horizontal_capture
	
	move $a0, $s0
	move $a1, $s5
	move $a2, $s6
	move $a3, $s4
	jal check_vertical_capture
	
	move $a0, $s0
	move $a1, $s5
	move $a2, $s6
	move $a3, $s4
	jal check_diagonal_capture
	
	#check the winners
	move $a0, $s0
	move $a1, $s4
	jal check_horizontal_winner
	bne $v0, -1, sim_winner
	
	move $a0, $s0
	move $a1, $s4
	jal check_vertical_winner
	bne $v0, -1, sim_winner
	
	move $a0, $s0
	move $a1, $s4
	jal check_sw_ne_diagonal_winner
	bne $v0, -1, sim_winner
	
	move $a0, $s0
	move $a1, $s4
	jal check_nw_se_diagonal_winner
	bne $v0, -1, sim_winner
	
	sim_valid_loop_cont:
	addi $s3, $s3, -1
	addi $s7, $s7, 1 #turns and stuff
	
	sim_loop_cont:
	move $a0, $s0
	jal game_status
	add $t0, $v0, $v1 #total pieces on board
	lw $t1, ($s0) #row
	lw $t2, 4($s0) #col
	mul $t1, $t1, $t2
	beq $t0, $t1, sim_no_winner #full board
	addi $s2, $s2, 5 #next turn
	addi $s1, $s1, -1 #turns length down by one
	j sim_loop
	
	sim_winner:
	move $v0, $s4
	j sim_done
	
	sim_no_winner:
	li $v1, -1
	
	sim_done:
	move $v0, $s7
	
	sim_exit:
	
	lw $s7, ($sp)
	lw $s6, 4($sp)
	lw $s5, 8($sp)
	lw $s4, 12($sp)
	lw $s3, 16($sp)
	lw $s2, 20($sp)
	lw $s1, 24($sp)
	lw $s0, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
    jr $ra
