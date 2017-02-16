# Scott's Conjecture

.data
p1: .asciiz "Enter h: "
p2: .asciiz "Enter w: "
bc: .asciiz "Bounces = "
ur: .asciiz "Final corner = UR"
lr: .asciiz "Final corner = LR"
ll: .asciiz "Final corner = LL"

.text
li $v0,4
la $a0,p1
syscall
li $v0,5
syscall
move $t0,$v0 # gcd param h
move $t3,$v0 # save h

li $v0,4
la $a0,p2
syscall
li $v0,5
syscall
move $t1,$v0 # gcd param w

gcd: move $t2,$t0
move $t0,$t1
div $t2,$t1
mfhi $t1
bnez $t1,gcd

div $s0,$t3,$t0 # m = h / gcd(h,w)
div $s1,$v0,$t0 # n = w / gcd(h,w)

li $v0,4
la $a0,bc
syscall

add $a0,$s0,$s1 # add m + n
subi $a0,$a0,2 # subtract 2

li $v0,1
syscall

li $v0,10
syscall