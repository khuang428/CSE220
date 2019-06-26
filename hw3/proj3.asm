# Karen Huang
# karhuang
# 111644515

.text

strcmp:
	move $t0, $a0 #str1
	move $t1, $a1 #str2
	cmp_len1: #check if str1 is empty
		lbu $t2, ($t0)
		bnez $t2, cmp_len2
		li $t9, 0 #the length counter for str2
		clen1_loop:
			lbu $t3, ($t1)
			beqz $t3, clen1_done
			addi $t9, $t9, 1 #increment counter
			addi $t1, $t1, 1 #next char in str2
			j clen1_loop
		clen1_done:
			move $v0, $t9	
		j cmp_done
	cmp_len2: #check if str2 is empty
		lbu $t3, ($t1)
		bnez $t3, cmp_loop
		li $t9, 0 #the length counter for str1
		clen2_loop:
			lbu $t2, ($t0)
			beqz $t2, clen2_done
			addi $t9, $t9, 1 #increment counter
			addi $t0, $t0, 1 #next char in str1
			j clen2_loop
		clen2_done:
			move $v0, $t9
		j cmp_done
	cmp_loop:
		lbu $t2, ($t0) #char1
		lbu $t3, ($t1) #char2
		beqz $t2, cmp_exit1
		beqz $t3, cmp_exit2
		beq $t2, $t3, cmp_cont
		sub $v0, $t2, $t3
		j cmp_done
	cmp_cont:
		addi $t0, $t0, 1 #next char1
		addi $t1, $t1, 1 #next char2
		j cmp_loop
	cmp_exit1: #if str1 is shorter
		sub $v0, $0, $t3
		j cmp_done
	cmp_exit2: #if str2 is shorter
		move $v0, $t2
	cmp_done:
	jr $ra

find_string:
	addi $sp, $sp -20
	sw $ra, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, ($sp)
	
	move $s0, $a0 #target
	move $s1, $a1 #strings
	move $s2, $a2 #strings_length
	li $t0, 2
	li $s3, 0
	bge $s2, $t0, find_loop
	find_inv: #returns -1 if strings_length is less than 2 or can't find
		li $s3, -1 
		j find_done
	find_loop: #s3 is the counter
		move $a0, $s0
		move $a1, $s1
		jal strcmp
		move $t0, $v0 #the result for the strcmp
		beqz $t0, find_done #if found, we are done
		find_next_word: #get the next word in strings
			lbu $t0, ($s1)
			beqz $t0, find_cont #found the \0
			addi $s1, $s1, 1 #next char
			addi $s3, $s3, 1 #increment the counter
			j find_next_word
		find_cont:
			beq $s3, $s2, find_inv
			addi $s1, $s1, 1 #next word get
			addi $s3, $s3, 1 #increment the counter
			j find_loop
	find_done:
		move $v0, $s3
	
	lw $s3, ($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra

hash:
	lw $t0, ($a0) #hash table capacity
	move $t1, $a1 #the string to hash
	li $t9, 0 #used for the maths
	hash_loop: #adds up the values of the string
		lbu $t2, ($t1)
		beqz $t2, hash_done
		add $t9, $t9, $t2
		addi $t1, $t1, 1 #next char in the string
		j hash_loop
	hash_done:
		div $t9, $t0
		mfhi $v0
	jr $ra

clear:
	lw $t0, ($a0) #hash table capacity
	sw $0, 4($a0) #change the size to 0
	addi $t1, $a0, 8 #the keys
	li $t2, 4
	mul $t2, $t0, $t2 
	add $t2, $t2, $a0 
	addi $t2, $t2, 8 #the values(add 8, account for capacity and size)
	li $t9, 0 #ctr
	clear_loop:
		beq $t9, $t0, clear_done #done clearing keys and values when capacity is covered
		sw $0, ($t1) #set to 0
		sw $0, ($t2)
		addi $t1, $t1, 4 #next slots
		addi $t2, $t2, 4
		addi $t9, $t9, 1 #increment counter
		j clear_loop
	clear_done:
	
	jr $ra

get:
	addi $sp, $sp -28
	sw $ra, 24($sp)
	sw $s0, 20($sp)
	sw $s1, 16($sp)
	sw $s2, 12($sp)
	sw $s3, 8($sp)
	sw $s4, 4($sp)
	sw $s5, ($sp)

	move $s0, $a0 #hash_table
	move $s1, $a1 #target key
	li $s2, 0 #probes
	lw $s3, ($s0) #the capacity
	move $a0, $s0
	move $a1, $s1
	jal hash
	move $s4, $v0 #initial starting index
	get_loop:
		li $s5, 4
		mul $s5, $s5, $s4
		addi $s5, $s5, 8
		add $s5, $s5, $s0 #the location of the next key to check
		lw $s5, ($s5) #key to check
		beqz $s5, get_empty #end at empty slot
		beq $s2, $s3, get_over #end when checked all keys
		beq $s5, 1, get_cont #skip over available slots
		move $a0, $s1
		move $a1, $s5
		jal strcmp
		move $t0, $v0
		beqz $t0, get_found #key found :o
	get_cont:
		addi $s4, $s4, 1 #next index
		addi $s2, $s2, 1 #increment probes
		blt $s4, $s3, get_loop #wrap around when index equals capacity
		li $s4, 0
		j get_loop
	get_empty:
		li $v0, -1 #not found
		move $v1, $s2 #probes
		j get_done
	get_over:
		li $v0, -1 #not found
		addi $v1, $s3, -1 #capacity-1
		j get_done
	get_found:
		move $v0, $s4 #index
		move $v1, $s2 #probes
	get_done:	

	lw $s5, ($sp)
	lw $s4, 4($sp)
	lw $s3, 8($sp)
	lw $s2, 12($sp)
	lw $s1, 16($sp)
	lw $s0, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	jr $ra

put:
	addi $sp, $sp -24
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, ($sp)
	
	move $s0, $a0 #hash_table
	move $s1, $a1 #key
	move $s2, $a2 #value
	jal get
	move $t0, $v0 #if found or not
	beq $t0, -1, put_empty
	#if key is in the hash table, update value, return values are of get
	#t0 is the index to update the value
	li $t1, 4
	lw $t2, ($s0) #capacity
	mul $t1, $t1, $t2
	addi $t1, $t1, 8 #skip past capacity and size
	li $t2, 4
	mul $t2, $t2, $t0 
	add $t1, $t1, $t2 #index of value
	add $t1, $t1, $s0 #the place to insert the new value
	sw $s2, ($t1)
	j put_done
	put_empty: #try inserting the key/value pair
		#if not in, if size = capacity, return -1, -1
		lw $s3, ($s0) #capacity
		lw $s4, 4($s0) #size
		beq $s3, $s4, put_full
		move $a0, $s0
		move $a1, $s1
		jal hash
		move $t0, $v0 #starting index
		li $t9, 0 #probes
		put_insert_loop:
			li $t1, 4
			mul $t1, $t1, $t0 
			addi $t1, $t1, 8
			add $t1, $t1, $s0 #first key location
			lbu $t2, ($t1)
			beqz $t2, put_ins
			beq $t2, 1, put_ins #if equal to 0 or 1, plop it in
			addi $t0, $t0, 1 #increase index
			addi $t9, $t9, 1 #increase probes
			blt $t0, $s3, put_insert_loop
			#wrap around if index is equal to capacity
			li $t0, 0
			j put_insert_loop
		put_ins:
			sw $s1, ($t1) #insert value
			li $t3, 4
			mul $t3, $t3, $s3
			add $t1, $t1, $t3
			sw $s2, ($t1) #insert key
			addi $s4, $s4, 1 
			sw $s4, 4($s0) #increment size
			move $v0, $t0 #index 
			move $v1,$t9 #probes
			j put_done
	put_full:
		li $v0, -1
		li $v1, -1
	put_done:
	
	lw $s4, ($sp)
	lw $s3, 4($sp)
	lw $s2, 8($sp)
	lw $s1, 12($sp)
	lw $s0, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	jr $ra

delete:
	addi $sp, $sp -20
	sw $ra, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, ($sp)

	move $s0, $a0 #hash_table
	move $s1, $a1 #key
	lw $s2, 4($s0) #size
	beqz $s2, delete_empty
	jal get
	beq $v0, -1, delete_done #return get values
	#if found, remove in keys(set to 1) and values(set to 0), size -1
	move $s3, $v0 #index of key
	li $t0, 4
	mul $t0, $t0, $s3
	addi $t1, $t0, 8 
	add $t1, $t1, $s0 #where the key to change is
	li $t8, 1
	sw $t8, ($t1)
	lw $t9, ($s0) #capacity
	li $t2, 4
	mul $t2, $t2, $t9
	add $t1, $t1, $t2 #where the value to change is
	sw $0, ($t1)
	addi $s2, $s2, -1 #decrease size
	sw $s2, 4($s0)
	j delete_done
	delete_empty: #if size is 0, return -1, 0
		li $v0, -1
		li $v1, 0
	delete_done:

	lw $s3, ($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra

build_hash_table:
	addi $sp, $sp -36
	sw $ra, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, ($sp)
	
	jal clear
	move $s0, $a0 #hash_table
	move $s1, $a1 #strings
	move $s2, $a2 #strings_length
	move $s3, $a3 #filename
	li $s5, 0 #pairs inserted
	
	move $a0, $s3 
	li $a1, 0 #read only
	li $v0, 13
	syscall #attempt to read the file
	move $s4, $v0 #file descriptor
	beq $s4, -1, build_exit
	addi $sp, $sp, -80 #allocate 80 bytes on the stack
	build_start:
		move $s3, $sp
	build_key_loop: #loops until syscall 14 returns a 0
		move $a0, $s4
		move $a1, $s3
		li $a2, 1
		li $v0, 14
		syscall
		beqz $v0, build_done #returns 0, so end of file!
		lbu $t0, ($s3) #the current character
		beq $t0, ' ', build_key_done #key goes until the space
		addi $s3, $s3, 1 #next spot in the buffer
		j build_key_loop
	build_key_done:
		sb $0, ($s3) #\0 for the key
		move $a0, $sp
		move $a1, $s1
		move $a2, $s2
		jal find_string
		move $s6, $v0
		add $s6, $s6, $s1 #location of the string inside strings
		
	move $s3, $sp #go back to the start of the buffer
	build_value_loop:
		move $a0, $s4
		move $a1, $s3
		li $a2, 1
		li $v0, 14
		syscall
		beqz $v0, build_done #returns 0, so end of file!
		lbu $t0, ($s3) #the current character
		beq $t0, '\n', build_value_done #key goes until the \n
		addi $s3, $s3, 1 #next spot in the buffer
		j build_value_loop
	build_value_done:
		sb $0, ($s3) #need that \0 at the end
		move $a0, $sp
		move $a1, $s1
		move $a2, $s2
		jal find_string
		move $s7, $v0
		add $s7, $s7, $s1 #location of the string inside strings
	
	move $a0, $s0 #call put with newfound key and value
	move $a1, $s6
	move $a2, $s7
	jal put
	move $t0, $v0
	beq $t0, -1, build_done #if -1 from put, DON'T INCREMENT PAIRS VALUE and stop right there
	addi $s5, $s5, 1 #one more pair added
	j build_start
	
	build_done:
	addi $sp, $sp, 80 #deallocate 80 bytes on the stack
	move $a0, $s4
	li $v0, 16
	syscall #close the file
	
	move $v0, $s5
	
	build_exit:
	
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

autocorrect:
	lw $t0, ($sp) #strings_length
	lw $t1, 4($sp) #filename
	addi $sp, $sp -36
	sw $ra, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, ($sp)
	
	move $s0, $a0 #hash_table
	move $s1, $a1 #src
	move $s2, $a2 #dest
	move $s3, $a3 #strings(1 use)
	move $s4, $t0 #strings_length(1 use)
	move $s5, $t1 #filename(1 use)
	li $s6, 0  #the number of words changed
	
	move $a0, $s0 #hash_table
	move $a1, $s3 #strings
	move $a2, $s4 #strings_length
	move $a3, $s5 #filename
	jal build_hash_table
	
	ac_word:
		move $s7, $s2 #save the current dest
	ac_word_loop: #loop through src until delimiter ' ' '.' ',' '?' '!'
		lbu $s3, ($s1)
		beqz $s3, ac_done
		beq $s3, ' ', ac_replace
		beq $s3, '.', ac_replace
		beq $s3, ',', ac_replace
		beq $s3, '?', ac_replace
		beq $s3, '!', ac_replace
		sb $s3, ($s2)
		addi $s1, $s1, 1 #next char in src
		addi $s2, $s2, 1 #next space in dest
		j ac_word_loop
	
	ac_replace:
		move $s4, $s3 #store the delimiter
		sb $0, ($s2) #\0 for the get
	
		move $a0, $s0 #hash_table
		move $a1, $s7 #key
		jal get
	
		move $t0, $v0
		beq $t0, -1, ac_cont
		#t0 is the index
		li $t1, 4
		lw $t2, ($s0) #capacity
		mul $t2, $t1, $t2
		addi $t2, $t2, 8
		mul $t1, $t1, $t0
		add $t2, $t2, $t1 
		add $t2, $t2, $s0 #where the location of the value is
		lw $t2, ($t2)
		ac_replace_loop: #if found, replace starting with saved dest
			lbu $t3, ($t2)
			beqz $t3, ac_replace_done
			sb $t3, ($s7)
			addi $s7, $s7, 1 #next spot to put char
			addi $t2, $t2, 1 #next char
			j ac_replace_loop
		ac_replace_done:
			addi $s6, $s6, 1 #add to words replaced
			move $s2, $s7
	ac_cont:
		sb $s4, ($s2) #put the delimiter back in
		addi $s1, $s1, 1 #next char in src
		addi $s2, $s2, 1 #next space in dest
		j ac_word
	
	ac_done:
		#one last replace
		sb $0, ($s2)
		move $a0, $s0 #hash_table
		move $a1, $s7 #key
		jal get
	
		move $t0, $v0
		beq $t0, -1, ac_exit
		#t0 is the index
		li $t1, 4
		lw $t2, ($s0) #capacity
		mul $t2, $t1, $t2
		addi $t2, $t2, 8
		mul $t1, $t1, $t0
		add $t2, $t2, $t1 
		add $t2, $t2, $s0 #where the location of the value is
		lw $t2, ($t2)
		ac_replace_loop_last: #if found, replace starting with saved dest
			lbu $t3, ($t2)
			beqz $t3, ac_replace_done_last
			sb $t3, ($s7)
			addi $s7, $s7, 1 #next spot to put char
			addi $t2, $t2, 1 #next char
			j ac_replace_loop_last
		ac_replace_done_last:
			addi $s6, $s6, 1 #add to words replaced
			move $s2, $s7

	ac_exit:	
	sb $0, ($s2)
	move $v0, $s6
	
	
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

