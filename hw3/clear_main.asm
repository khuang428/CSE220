.data
hash_table:
.word 7
.word 7
.word s101, ams, cs, oh, kk, thx, yuo
.word CSE101, Applied_Mathematics, Computer_Science, OH, OK_thanks, thanks, you

# There are some extra strings here you can work with. Or add your own!
subtraction: .asciiz "subtraction"
s101: .asciiz "101"
sbu: .asciiz "sbu"
yuo: .asciiz "yuo"
u: .asciiz "u"
you: .asciiz "you"
wat: .asciiz "wat"
ams: .asciiz "ams"
help: .asciiz "help"
CSE101: .asciiz "CSE101"
bsu: .asciiz "bsu"
arrgghh: .asciiz "arrgghh"
calss: .asciiz "calss"
thx: .asciiz "thx"
Applied_Mathematics: .asciiz "Applied Mathematics"
hepl: .asciiz "hepl"
OK_thanks: .asciiz "OK thanks"
class: .asciiz "class"
can: .asciiz "can"
kk: .asciiz "kk"
gg: .asciiz "gg"
i: .asciiz "i"
I: .asciiz "I"
thanks: .asciiz "thanks"
usb: .asciiz "usb"
Universal_Serial_Bus: .asciiz "Universal Serial Bus" 
oh: .asciiz "oh"
OH: .asciiz "OH"
cs: .asciiz "cs"
Computer_Science: .asciiz "Computer Science"

.text
.globl main
main:
la $a0, hash_table
jal clear

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
	
li $v0, 10
syscall

.include "proj3.asm"
