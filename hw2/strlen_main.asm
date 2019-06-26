.data
str: .asciiz "m i ps"

.text
.globl main
main:
la $a0, str
jal strlen

move $a0, $v0
li $v0, 1
syscall

li $v0, 10
syscall

.include "proj2.asm"
