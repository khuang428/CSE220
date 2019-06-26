.data
v0: .asciiz "v0: "
v1: .asciiz "v1: "

hash_table:
.word 7
.word 7
.word s101, ams, cs, oh, kk, thx, yuo
.word CSE101, Applied_Mathematics, Computer_Science, OH, OK_thanks, thanks, you

good_game: .asciiz "good game"
sillllllly: .asciiz "sillllllly"
hmm: .asciiz "hmm"
s220: .asciiz "220"
Computer_Science: .asciiz "Computer Science"
cs: .asciiz "cs"
I: .asciiz "I"
Stony_Brook_University: .asciiz "Stony Brook University"
i: .asciiz "i"
help: .asciiz "help"
what: .asciiz "what"
OK_thanks: .asciiz "OK thanks"
hmmmm: .asciiz "hmmmm"
u: .asciiz "u"
hepl: .asciiz "hepl"
CSE101: .asciiz "CSE101"
ams: .asciiz "ams"
thx: .asciiz "thx"
silly: .asciiz "silly"
yuo: .asciiz "yuo"
Boise_State_University: .asciiz "Boise State University"
subtraction: .asciiz "subtraction"
OH: .asciiz "OH"
sto: .asciiz "sto"
wat: .asciiz "wat"
sbu: .asciiz "sbu"
sub: .asciiz "sub"
MIPS: .asciiz "MIPS"
s101: .asciiz "101"
kk: .asciiz "kk"
Universal_Serial_Bus: .asciiz "Universal Serial Bus"
calss: .asciiz "calss"
bsu: .asciiz "bsu"
you: .asciiz "you"
can: .asciiz "can"
MIPSR10000: .asciiz "MIPSR10000"
oh: .asciiz "oh"
cna: .asciiz "cna"
class: .asciiz "class"
thanks: .asciiz "thanks"
gg: .asciiz "gg"
usb: .asciiz "usb"
Stony_Brook: .asciiz "Stony Brook"
argh: .asciiz "argh"
arrgghh: .asciiz "arrgghh"
Applied_Mathematics: .asciiz "Applied Mathematics"
CSE_220: .asciiz "CSE 220"


.text
.globl main
main:
la $a0, hash_table
la $a1, yuo
jal delete
move $t0, $v0
move $t1, $v1

la $a0, v0
li $v0, 4
syscall
li $v0, 1
move $a0, $t0
syscall
li $a0, '\n'
li $v0, 11
syscall

la $a0, v1
li $v0, 4
syscall
li $v0, 1
move $a0, $t1
syscall
li $a0, '\n'
li $v0, 11
syscall

# You should probably write code here to print the state of the hash table.
la $t1, hash_table
lw $a0, ($t1)
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
lw $a0, 4($t1)
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
li $t9, 0
addi $t1, $t1, 8
key_loop:
	beq $t9, 7, value
	lw $a0, ($t1)
	beqz $a0, skip_1
	bne $a0, 1, key_cont
	li $v0, 1
	syscall
	j skip_1
	key_cont:
	li $v0, 4
	syscall
	skip_1:
	li $a0, ','
	li $v0, 11
	syscall
	addi $t1, $t1, 4
	addi $t9, $t9, 1
	j key_loop
	
value:
	li $t9, 0
	li $a0, '\n'
	li $v0, 11
	syscall
value_loop:
	beq $t9, 7, quit
	lw $a0, ($t1)
	beqz $a0, skip_2
	bne $a0, 1, value_cont
	li $v0, 1
	syscall
	j skip_2
	value_cont:
	li $v0, 4
	syscall
	skip_2:
	li $a0, ','
	li $v0, 11
	syscall
	addi $t1, $t1, 4
	addi $t9, $t9, 1
	j value_loop
quit:


li $v0, 10
syscall

.include "proj3.asm"
