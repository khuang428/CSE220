.data
filename: .asciiz "C:/Users/Karen/Desktop/220hw/hw4/vert_win2.txt"
.align 2
board: .space 1000

.text
la $a0, board
la $a1, filename
jal load_board

la $a0, board
jal game_status

move $a0, $v0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

move $a0, $v1
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "proj4.asm"