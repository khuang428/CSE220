# Karen Huang
# karhuang
# 111644515

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
to_lowercase:
	move $t0,$a0
	li $t9, 0 #counter for chars changed
	to_lower_loop:
		lbu $t1,($t0) #get the char
		beqz $t1, tll_done #end of the string \0
		bltu $t1, 'A', tll_cont #checking if CAPS
		bgtu $t1, 'Z', tll_cont
		addi $t1, $t1, 32
		sb $t1,($t0)
		addi $t9, $t9, 1
	tll_cont:
		addi $t0, $t0, 1
		j to_lower_loop	
	tll_done:
		move $v0, $t9 #returning the number of chars changed
	jr $ra


strlen:
	move $t0,$a0
	li $t9, 0 #counter
	len_ctr_loop:
		lbu $t1,($t0) #get the char
		beqz $t1, lec_done #end of the string \0
		addi $t9, $t9, 1
		addi $t0, $t0, 1
		j len_ctr_loop	
	lec_done:
		move $v0, $t9 #returning the number of chars
    jr $ra
	

count_letters:
	move $t0,$a0
	li $t9, 0 #counter for letters
	ltr_ctr_loop:
		lbu $t1,($t0) #get the char :)
		beqz $t1, ltc_done #end of string \0
		bltu $t1, 'A', ltc_cont #not a letter
		bgtu $t1, 'Z', ltc_lower #might be lower?
		addi $t9, $t9, 1 #is a capital letter :o
	ltc_lower:
		bltu $t1, 'a', ltc_cont #not a letter
		bgtu $t1, 'z', ltc_cont
		addi $t9, $t9, 1 #is a lowercase letter :o
	ltc_cont:
		addi $t0, $t0, 1
		j ltr_ctr_loop
	ltc_done:
		move $v0, $t9
	jr $ra


encode_plaintext:
	addi $sp, $sp, -4 #storing $ra b/c strlen call
	sw $ra, ($sp)
	
	move $t2, $a2 #ab_text_length
	jal strlen #a0 is the same as this function's :o
	move $t3, $v0 #plaintext length
	li $t4, 5 #getting the length of encoded plaintext
	mul $t4, $t3, $t4
	addi $t4, $t4, 5
	#compare $t2 and $t4 to get whether $v1 will be 1(t2 >= t4) or 0(t2 < t4) 
	#3 cases: fully encodable, can encode end, can't encode shit
	
	li $v0, 0 #default values
	li $v1, 1
	bgeu $t2, $t4, encode 
	li $v1, 0 #if not successful(which it will not be if it didn't branch)
	bltu $t2, 5, enc_done #case 3
	
	encode:
		move $t0, $a0 #plaintext
		#$t3 is loop counter
		li $t9, 0 #how many characters were encoded
		addi $sp, $sp, -8
		sw $s0, 4($sp)
		sw $s1, ($sp)
		move $s0, $a1 #ab_text
		enc_loop:
			move $s1, $a3 #codes
			#if number chars - 5 < 5, gotta go put in the eom
			addi $t5, $t2, -5
			addi $t2, $t2, -5 #gotta keep track of them size changes
			bltu $t5, 5, enc_eom
			#else if hit the plaintext end, put in eom
			beqz $t3, enc_eom
			lbu $t4, ($t0)
			bltu $t4,'a',enc_symbol
			bgtu $t4, 'z', eil_done #char isn't any of the coded ones
			addi $t4, $t4, -97
			li $t8, 5 #gotta multiply by 5 for each code!!!
			mul $t4, $t4, $t8
			add $s1, $s1, $t4 #the start of the 5 character bacon code
			j enc_insert
		enc_symbol:
			beq $t4, ' ', space
			beq $t4, '!', exc_mark
			beq $t4, '\'', qt_mark
			beq $t4, ',', comma
			beq $t4, '.', period
			j eil_done #if the char isn't any of the code 
			space:
			addi $s1, $s1, 130
			j enc_insert
			exc_mark:
			addi $s1, $s1, 135
			j enc_insert
			qt_mark:
			addi $s1, $s1, 140
			j enc_insert
			comma:
			addi $s1, $s1, 145
			j enc_insert
			period:
			addi $s1, $s1, 150
			
		enc_insert:
			li $t8, 5
			ei_loop:
				beq $0, $t8, eil_done
				lbu $t4, ($s1) 
				sb $t4, ($s0) 
				addi $t8, $t8, -1 #decrease counter for bacon code insertion
				addi $s1, $s1, 1 #next char in that one bacon code
				addi $s0, $s0, 1 #next slot in ab_text
				j ei_loop
			eil_done:
			addi $t0, $t0, 1 #next plaintext char
			addi $t3, $t3, -1 #plaintext length counter
			addi $t9, $t9, 1
			j enc_loop
			
		enc_eom:
			move $v0, $t9 #putting the total letters bacon-ified into $v0
			li $t8, 5
			li $t7, 'B'
			eom_loop: #putting in them 5 Bs
				beq $0, $t8, eom_done
				sb $t7, ($s0)
				addi $t8, $t8, -1
				addi $s0, $s0, 1
				j eom_loop
			eom_done:
				lw $s1, ($sp)
				lw $s0, 4($sp)
				addi $sp, $sp, 8
		
	enc_done:
		lw $ra, ($sp) 
		addi $sp, $sp, 4
    jr $ra
	
	
encrypt: 
	lw $t0, ($sp)#get them bacon codes first
	addi $sp, $sp, -24 
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, ($sp)
	
	move $s0, $a1 #ciphertext
	move $s1, $a2 #start of ab_text(which will be changed after encode_plaintext
	move $s2, $a0 #plaintext
	move $s3, $t0 #now baconbois are SECURE 
	move $s4, $a3 #ab_text_length
	jal to_lowercase
	
	move $a0, $s2 #plaintext
	move $a1, $s1 #ab_text
	move $a2, $s4 #ab_text_length
	move $a3, $s3#bacon codes
	
	#call encode_plaintext with plaintext and ab_text and check v1 for success
	jal encode_plaintext #v1 will be the same thing for this boi
	bltu $s4, 5, encrypt_done #can't do shit!!!
	move $t1, $v0
	li $t2, 5
	mul $t1, $t1, $t2
	addi $t1, $t1 , 5 #num chars changed and counter for going through ab_text
	move $v0, $t1 #can move here because assume ciphertext can fit all of ab_text
	
	encrypt_loop:
		#t1 is the counter
		#s0 is the ciphertext
		#s1 is ab_text
		beqz $t1,encrypt_done
		lbu $t2, ($s0)
		lbu $t3, ($s1) 
		#first check if ciphertext has a letter
		bltu $t2, 'A', encrypt_cont #uppers
		bgtu $t2, 'Z', lower_check
		#check ab_text 2 cases(if a then lower if b then upper)
		beq $t3, 'B', ab_cont #already upper
		addi $t2, $t2, 32 #change to lower
		sb $t2, ($s0)
		j ab_cont
	lower_check: #lowers
		bltu $t2, 'a', encrypt_cont
		bgtu $t2, 'z', encrypt_cont
		#check ab_text 2 cases (if a then lower if b then upper)
		beq $t3, 'A', ab_cont #already lower
		addi $t2, $t2, -32 #change to lower
		sb $t2, ($s0)
	ab_cont: #DONE ONLY IF ciphertext HAD A LETTER!!!!
		addi $s1, $s1, 1 #next A or B :o 
		addi $t1, $t1, -1 #decrease that counter
	encrypt_cont:
		addi $s0, $s0, 1 #next char of the ciphertext to be converted
		j encrypt_loop
	encrypt_done:
	
	lw $s4, ($sp)
	lw $s3, 4($sp)
	lw $s2, 8($sp)	
	lw $s1, 12($sp)
	lw $s0, 16($sp)
	lw $ra, 20($sp) 
	addi $sp, $sp, 24
	jr $ra
	
	
decode_ciphertext:
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s2, ($sp)
	
	move $s0, $a0 #ciphertext
	move $s1, $a1 #ab_text
	move $s2, $a2 #ab_text_length
	
	move $a0, $s0
	jal count_letters #see how many letters are in ciphertext
	move $t0, $v0 #the number of letters in ciphertext
	bltu $s2, $t0, unfit #return -1 if ab_text won't fit
	
	li $t9, 0 #characters plopped in ab_text
	li $t0, 0 #A count
	li $t1, 0 #B count
	decode_loop:
		lbu $t2, ($s0) #ciphertext letter
		bltu $t2, 'A', decode_cont #uppers(B)
		bgtu $t2, 'Z', dec_lower
		
		addi $t1, $t1, 1 #adding to B count
		li $t8, 'B' #put in ab_text
		sb $t8, ($s1)
		j dec_char_check
	dec_lower:
		bltu $t2, 'a', decode_cont #lowers(A)
		bgtu $t2, 'z', decode_cont
		
		addi $t0, $t0, 1 #adding to A count
		li $t8, 'A' #put in ab_text
		sb $t8, ($s1)
	dec_char_check: #check for BBBBB if A and B counter sum equals 5(reset)
		addi $s1, $s1, 1 #next ab_text slot
		addi $t9, $t9, 1 #a char was decoded :)
		add $t8, $t0, $t1 #sum of A and B so far
		bne $t8, 5, decode_cont #if we didn't finish one bacon code, keep going
		beq $t1, 5, dec_eom #5 Bs!
		li $t0, 0 #count reset to check the next bacon code
		li $t1, 0 
		j decode_cont
	dec_eom: #the end of the bacons
		move $v0, $t9 #num chars decoded
		j decode_done
	decode_cont:
		addi $s0, $s0, 1 #next ciphertext letter
		j decode_loop
	unfit:
		li $v0, -1
	
	decode_done:
	
	lw $s2, ($sp)
	lw $s1, 4($sp)	
	lw $s0, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	
	
decrypt:
	lw $t0, ($sp)#bacon codes
	addi $sp, $sp, -24 
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, ($sp)
	
	move $s0, $a0 #ciphertext
	move $s1, $a1 #plaintext
	move $s2, $a2 #ab_text
	move $s3, $a3 #ab_text_length
	move $s4, $t0 #codes
	
	#calling decode_ciphertext
	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	move $a3, $s4
	jal decode_ciphertext
	beq $v0, -1, decrypt_done #if decode returns -1, so does this function
	move $t0, $v0
	addi $t0, $t0, -5
	li $t8, 5
	div $t0, $t8
	mflo $t0 #should be how many characters are in the plaintext
	move $v0, $t0 #number of chars in the message, excluding eom
	decrypt_loop:
		#t0 is the counter
		#s1 is the plaintext
		#s2 is ab_text
		beqz $t0, insert_null
		li $t1, 5 #counter for this inner loop
		li $t2, 0 #bacon code but a = 0 and b = 1 
		decr_char_loop: #gets the next 5 "bits" TODO CHECK THIS
			beqz $t1, decr_char_done
			addi $t1, $t1, -1
			lbu $t3, ($s2)
			beq $t3, 'A',decr_char_cont #0 will already be there by default
			li $t8, 1
			sllv $t8, $t8, $t1 #putting the bit in the right place
			or $t2, $t2, $t8
		decr_char_cont:
			addi $s2, $s2, 1 #next A/B in ab_text
			j decr_char_loop
		decr_char_done:
			#0-25 a-z, 26 space, 27 exclamation mark, 28 quotation mark, 29 comma, 30 period
			bgtu $t2, 25, decr_symbol
			addi $t2, $t2, 65
			j decrypt_cont
		decr_symbol:
			beq $t2, 27, ins_exc_mark
			beq $t2, 28, ins_qt_mark
			beq $t2, 29, ins_comma
			beq $t2, 30, ins_period
			
			#make the default ins_space
			li $t2, ' '
			j decrypt_cont
		ins_exc_mark:
			li $t2, '!'
			j decrypt_cont
		ins_qt_mark:
			li $t2, '\''
			j decrypt_cont
		ins_comma:
			li $t2, ','
			j decrypt_cont
		ins_period:
			li $t2, '.'
			
		decrypt_cont:
		sb $t2, ($s1) #put that goddamn character in
		addi $t0, $t0, -1 #decrease counter
		addi $s1, $s1, 1 #next slot in plaintext to plop in a decoded character
		j decrypt_loop
	insert_null:
		li $t8, 0
		sb $t8, ($s1)
	decrypt_done:
	
	lw $s4, ($sp)
	lw $s3, 4($sp)
	lw $s2, 8($sp)	
	lw $s1, 12($sp)
	lw $s0, 16($sp)
	lw $ra, 20($sp) 
	addi $sp, $sp, 24
	jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
