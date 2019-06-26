.data
filename: .asciiz "C:/Users/Karen/Desktop/220hw/hw4/sw_ne_diag_win6.txt"
.align 2
board: .space 1000
player: .byte 'X'

.text
la $a0, board
la $a1, filename
jal load_board

la $a0, board
lbu $a1, player
jal check_sw_ne_diagonal_winner

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

li $v0, 10
syscall

.include "proj4.asm"