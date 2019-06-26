.data
filename: .asciiz "C:/Users/Karen/Desktop/220hw/hw4/generic_board1.txt"
.align 2
board: .space 1000
r: .word 1
c: .word 9
player: .word 'q'

.text
la $a0, board
la $a1, filename
jal load_board

la $a0, board
lw $a1, r
lw $a2, c
lbu $a3, player
jal place_piece
# code here to print any return value(s) and the updated state
# of the game board, if appropriate
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

li $v0, 10
syscall

.include "proj4.asm"
