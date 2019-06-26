# Karen Huang
# karhuang
# 111644515

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
addr_arg2: .word 0
addr_arg3: .word 0
addr_arg4: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"

# Put your additional .data declarations here

# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beq $a0, 0, zero_args
    beq $a0, 1, one_arg
    beq $a0, 2, two_args
    beq $a0, 3, three_args
    beq $a0, 4, four_args
five_args:
    lw $t0, 16($a1)
    sw $t0, addr_arg4
four_args:
    lw $t0, 12($a1)
    sw $t0, addr_arg3
three_args:
    lw $t0, 8($a1)
    sw $t0, addr_arg2
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here

zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory
    
start_coding_here:
    # Start the assignment by writing your code here
    lw $t0, addr_arg0
    lbu $t1, ($t0) #first char of arg0
    lbu $t2, 1($t0) #second char of arg0
    bne $t2, '\0', inv_op #check so things like "2G" won't work
    beq $t1, '2', part_2
    beq $t1, 'S', part_3
    beq $t1, 'D', part_4
    beq $t1, 'L', part_5
    beq $t1, 'A', part_6
    
inv_op:
    la $a0, invalid_operation_error
    li $v0, 4
    syscall
    j exit
    
part_2:
	lw $t0, num_args
	bne $t0, 2, inv_args 
	#loop through the string and convert it to a number
	li $t0, 0 #end condition
	li $t1, 8 #counter
	lw $s0, addr_arg1 #get the string
	p2_val_chk:
		beq $t0, $t1, p2_vc_done 
		lbu $t2,($s0) #get the char
		
		bltu $t2, '0', inv_args #check for numbers
		bgtu $t2, '9', p2_vc_letter
		addi $t2, $t2, -48 #convert from ascii value to actual value
		j p2_val_insert
		
	p2_vc_letter:	
		bltu $t2, 'A', inv_args #check for letters
		bgtu $t2, 'F', inv_args
		addi $t2, $t2, -55 #convert to actual value
		
	p2_val_insert:
		li $t4, 4 #4 binary digits to 1 hex digit
		
		addi, $t1, $t1, -1 #decrease counter(need to be here for the shift to work properly)
		
		mul $t3, $t1, $t4 #the number of bits to shift
		sllv $t2, $t2, $t3 #shift over to correct spot
		or $s1, $s1, $t2 #combine the converted char with the rest of the number
	
		addi, $s0, $s0, 1 #next char
		j p2_val_chk
	p2_vc_done:	
		
		move $a0, $s1
		li $v0, 1
		syscall
		li $a0, '\n'
    	li $v0, 11
    	syscall
    	
    j exit
    
part_3:
	lw $t0, num_args
	bne $t0, 2, inv_args
	#loop through the string and convert it to a number
	li $t0, 0 #end condition
	li $t1, 8 #counter
	lw $s0, addr_arg1 #get the string
	p3_val_chk:
		beq $t0, $t1, p3_vc_done 
		lbu $t2,($s0) #get the char
		
		bltu $t2, '0', inv_args #check for numbers
		bgtu $t2, '9', p3_vc_letter
		addi $t2, $t2, -48 #convert from ascii value to actual value
		j p3_val_insert
		
	p3_vc_letter:	
		bltu $t2, 'A', inv_args #check for letters
		bgtu $t2, 'F', inv_args
		addi $t2, $t2, -55 #convert to actual value
		
	p3_val_insert:
		li $t4, 4 #4 binary digits to 1 hex digit
		
		addi, $t1, $t1, -1 #decrease counter(need to be here for the shift to work properly)

		mul $t3, $t1, $t4 #the number of bits to shift
		sllv $t2, $t2, $t3 #shift over to correct spot
		or $s1, $s1, $t2 #combine the converted char with the rest of the number
	
		addi $s0, $s0, 1 #next char
		j p3_val_chk
		
	p3_vc_done:
		#special cases +0 and -0
		li $t5, -2147483648
		beq $s1, 0, p3_pos_zero
		beq $s1, $t5, p3_neg_zero
		
		srl $t9, $s1, 31 #testing most significant bit
		bne $t9, 1, p3_vi_cont 
		xori $s1, $s1, 10000000000000000000000000000000 #change most significant bit to 0
		not $s1, $s1 #invert all the bits
		addi $s1, $s1, 1 #add 1 because of sign magnitude

		
	p3_vi_cont:
		move $a0, $s1
		li $v0, 1
		syscall
		li $a0, '\n'
    	li $v0, 11
    	syscall
		j exit
		
	p3_pos_zero:
		li $a0, '+'
		li $v0, 11
		syscall
		li $a0, 0
		li $v0, 1
		syscall
		li $a0, '\n'
    	li $v0, 11
    	syscall
		j exit
		
	p3_neg_zero:
		li $a0, '-'
		li $v0, 11
		syscall
		li $a0, 0
		li $v0, 1
		syscall
		li $a0, '\n'
    	li $v0, 11
    	syscall
		j exit	
    
part_4:
	lw $t0, num_args
	bne $t0, 2, inv_args
	#loop through the string and convert it to a sum of the numbers
	li $t0, 0 #end condition
	li $t1, 8 #counter
	lw $s0, addr_arg1 #get the string
	p4_val_chk:
		beq $t0, $t1, p4_vc_done
		lbu $t2, ($s0) #get the char

		bgtu $t2, 'z', inv_args #check for lowercase letters
		bltu $t2, 'a', p4_vc_zero
		addi $t2, $t2, -97 #changing letter to a number value(power of 2)
		jal p4_pow_2
		addu $s2, $s2, $s1
		j p4_vc_cont
		
	p4_vc_zero:
		bne $t2, '0', inv_args #check if equal to 0
		
	p4_vc_cont:	
		addi, $t1, $t1, -1 #decrease counter
		addi, $s0, $s0, 1 #next char
		j p4_val_chk

	p4_vc_done:
		move $a0, $s2
		li $v0, 1
		syscall
		li $a0, '\n'
    	li $v0, 11
    	syscall
	
	j exit
	
	#helper boi for the POWER
	p4_pow_2:
		#t0 is still the end condition
		#t2 is the power of 2 needed
		li $s1, 1 #intial value
		li $t3, 2 #for raising to power of 2 
		p4_pow_loop:
			beq $t0, $t2, p4_pl_done
			mul $s1, $s1, $t3
			addi $t2, $t2, -1 #-1 to the power
			j p4_pow_loop
		p4_pl_done:
			jr $ra
    
part_5:
	lw $t0, num_args
	bne $t0, 2, inv_args
	#check string validity 0-9
	li $t0, 0 #end condition
	li $t1, 8 #counter
	lw $s0, addr_arg1 #get the string
	p5_val_chk:
		beq $t0, $t1, p5_vc_done
		lbu $t2, ($s0) #get the char
		bltu $t2, '0', inv_args
		bgtu $t2, '9', inv_args
		addi $t2, $t2, -48 #convert from ascii value to actual value
		
		#getting the actual number
		li $t9, 10
		mul $s1, $s1, $t9
		add $s1, $s1, $t2
		
		addi, $t1, $t1, -1 #decrease counter
		addi, $s0, $s0, 1 #next char
		j p5_val_chk
		
    p5_vc_done:
    
    #checks bit by bit and prints if it is 1
    #s1 is the value being looped through
    li $t0, 0 #loopyboi counter
    li $t1, 26 #end condition
    li $t9, 1 #bit checker haha
    p5_print_loop:
    	beq $t0, $t1, p5_pl_done
    	and $t2, $s1, $t9 #get the least significant bit
    	beq $t2, $t9, p5_print_char #if there's a 1 then we good bois we do da print bois
    	
    p5_pl_cont:
    	addi $t0, $t0, 1 #increment the counter
    	srl $s1, $s1, 1 #get next bit to check
    	j p5_print_loop
    			
    p5_pl_done:
    	li $a0, '\n'
    	li $v0, 11
    	syscall
    j exit
    
    #helper
    p5_print_char:
    	addi $t8, $t0, 97 #get the ascii value for corresponding char
    	move $a0, $t8 
    	li $v0, 11
    	syscall
    	j p5_pl_cont 
    
part_6:
	lw $t0, num_args
	bne $t0, 5, inv_args
	#count all values anyway because that's how I want to do it
	li $t0, 0 #end condition
	li $t1, 8 #counter
	lw $s0, addr_arg1 #get the string
	#s1 upper
	#s2 lower
	#s3 digits
	p6_val_ctr:
		beq $t0, $t1, p6_vc_done
		lbu $t2, ($s0) #get the char
		bltu $t2, '0', p6_val_cont
		bgtu $t2, '9', p6_up_ctr
		addi $s3, $s3, 1
		j p6_val_cont
			
	p6_up_ctr:
		bltu $t2, 'A', p6_val_cont
		bgtu $t2, 'Z', p6_low_ctr
		addi $s1, $s1, 1
		j p6_val_cont
		
	p6_low_ctr:
		bltu $t2, 'a', p6_val_cont
		bgtu $t2, 'z', p6_val_cont
		addi $s2, $s2, 1
	
	p6_val_cont:
		addi, $t1, $t1, -1 #decrease counter
		addi, $s0, $s0, 1 #next char
		j p6_val_ctr
		
	p6_vc_done:	
	
		#smiting values if N
		lw $t7, addr_arg2 #count of upper
		lbu $t7, ($t7)
		beq $t7, 'Y', p6_lc
		li $s1, 0
	
	p6_lc:
		lw $t8, addr_arg3 #count of lower
		lbu $t8, ($t8)
		beq $t8, 'Y', p6_dc
		li $s2, 0

	p6_dc:
		lw $t9, addr_arg4 #count of digits
		lbu $t9, ($t9)
		beq $t9, 'Y', p6_combine
		li $s3,0
		
	p6_combine:
		or $s4, $0, $s3
		sll $s2, $s2, 4
		or $s4, $s4, $s2
		sll $s1, $s1, 8
		or $s4, $s4, $s1

		move $a0, $s4
		li $v0, 35
		syscall
		li $a0, '\n'
    	li $v0, 11
    	syscall
		 
    j exit
    
inv_args:
	la $a0, invalid_args_error
	li $v0, 4
    syscall
    
exit:
    li $a0, '\n'
    li $v0, 11
    syscall
    li $v0, 10
    syscall
