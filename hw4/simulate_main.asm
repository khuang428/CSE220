.data
filename: .asciiz "C:/Users/Karen/Desktop/220hw/hw4/empty10x12.txt"
turns: .asciiz "X0207O0712X0211O0611X0506O0812X0108O0101X1107O0400X1010O0305X0304O0302X0203O0505X1006O0306X0708O0412"
num_turns: .word 20
.align 2
board: .space 1000


.text
la $a0, board
la $a1, filename
la $a2, turns
lw $a3, num_turns
jal simulate_game

move $t0, $v0
move $t1, $v1

move $a0, $t0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

move $a0, $t1
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

la $t0, board
lw $t1, ($t0)
lw $t2, 4($t0)

addi $t0, $t0, 8
row:
beqz $t1, print
move $t3, $t2
	column:
	beqz $t3, row_cont
	lbu $t9, ($t0)
	
	move $a0, $t9
	li $v0, 11
	syscall
	
	addi $t0, $t0, 1
	addi $t3, $t3, -1
	j column
row_cont:
li $a0, '\n'
li $v0, 11
syscall
addi $t1, $t1, -1
j row	
	
print:

li $v0, 10
syscall

.include "proj4.asm"