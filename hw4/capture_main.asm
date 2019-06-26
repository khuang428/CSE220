.data
filename: .asciiz "C:/Users/Karen/Desktop/220hw/hw4/diag_capture3.txt"
.align 2
board: .space 1000
r: .word 4
c: .word 6
player: .byte 'O'

.text
la $a0, board
la $a1, filename
jal load_board

la $a0, board
lw $a1, r
lw $a2, c
lbu $a3, player
jal check_diagonal_capture

move $a0, $v0
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

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "proj4.asm"