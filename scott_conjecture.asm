# Scott's Conjecture

.data
p1: .asciiz "Enter h: "
p2: .asciiz "Enter w: "
bc: .asciiz "Bounces = "
ur: .asciiz "\nFinal corner = Upper Right"
lr: .asciiz "\nFinal corner = Lower Right"
ll: .asciiz "\nFinal corner = Lower Left"

.text

li $v0,4
la $a0,p2
syscall
li $v0,5
syscall
move $t1,$v0 # gcd param w

li $v0,4
la $a0,p1
syscall
li $v0,5
syscall
move $t0,$v0 # gcd param h
move $t3,$v0 # save h

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

#****************
# isPrime(h)
# isprime(w)
# test cases

# Register Usage:
# $s2 = isprime(h)
# $s3 = isprime(2)
# $t4 = temp for AND
#****************

#isPrime(h)
	move	$a0,	$t3	#pass h to isPrime(m)
	jal	isPrime
	move 	$s2,	$v0	#move result into s2
	
#isPrime(w)
	move	$a0,	$t1	#pass w to isPrime(m)
	jal	isPrime
	move 	$s3,	$v0	#move result into s3

#Test Cases
	beq	$t3,	2	__w2		#not lower right, if w is 2
	and	$t4,	$s2, 	$s3		#lower right, if both h and 2 are prime
	beq	$t3, 	1,	lowerRight
__w2:	
	beq	$s2,	1,	upperRight	#upper right, if h is prime
	beq	$s3,	1,	lowerLeft	#lower left, if w is prime
	j	__end

lowerLeft:
	li 	$v0,	4		#prints "Final corner = LL"
	la	$a0,	ll		#prints ll
	syscall			#execute
	j	__end
upperRight:
	li 	$v0,	4		#prints "Final corner = UR"
	la	$a0,	ur		#prints ur
	syscall			#execute
	j	__end
lowerRight:
	li 	$v0,	4		#prints "Final corner = LR"
	la	$a0,	lr		#prints lr
	syscall			#execute
	j	__end
__end:
	li 	$v0,	10
	syscall

#****************
# isPrime(m)
# Tests to see whether input m is a prime number.
#
# Input:
#	value stored at $a0
# Output:
#	value stored at $v0
#
# Register Usage:
# $t0 = m
# $t1 = temp from mult or div
# $t2 = counter i
# $t3 = counter i + 2
# $t4 = divisor temp
# $v0 = return value: 0 or 1
#****************
isPrime:
	move	$t0,	$a0		#move argument to s0
	
	##backup $ra
	sub 	$sp,	$sp,	4	#move stack pointer
	sw 	$ra,	0($sp)		#save $ra to the stack + 0
	
	##test for basic cases
	beq	$t0,	1,	isFals	#return false if m = 1
	beq	$t0,	2,	isTrue	#return true if m = 2
	beq	$t0,	3,	isTrue	#return true if m = 3
	
	##m mod 2 test
	add	$t4,	$zero,	2	#divisor 2
	div	$t0,	$t4		#divide m by 2
	mfhi	$t1			#store remainder in $t1
	beq	$t1,	$zero,	isFals	#return false if m mod 2 = 0
	
	##m mod 3 test
	add	$t4,	$zero,	3	#divisor 3
	div	$t0,	$t4		#divide m by 3
	mfhi	$t1
	beq	$t1,	$zero,	isFals	#return false if m mod 3 = 0
	
	##set up loop
	add	$t2,	$zero,	5	#i = 5
	mult	$t0,	$t0		#i * i = $t1
	mflo	$t1
primeLoop:
	bgt	$t1,	$t0,	isTrue	#return true if i*i > m
	
	##m mod i test
	div	$t0,	$t2		#divide m by i
	mfhi	$t1
	beq	$t1,	$zero,	isFals	#return false if n mod i = 0
	
	##m mod (i+2) test
	add	$t3,	$t2,	2	#i+2
	div	$t0,	$t3		#divide m by (i+2)
	mfhi	$t1
	beq	$t1,	$zero,	isFals	#return false if n mod (i+2) = 0 
	
	#increment and iterate loop
	add	$t2,	$t2,	6	#i = i+6
	mult	$t0,	$t0		#i*i = $t1
	mflo	$t1
	j 	primeLoop
isFals:
	add	$v0, 	$zero,	0
	j	primeReturn
isTrue:
	add	$v0,	$zero,	1
	j	primeReturn
primeReturn:
	##restores $ra to register and returns to caller
  	lw	$ra,	0($sp)		#load $ra from stack + 0
  	add	$sp,	$sp,	4	#move stack pointer
	jr 	$ra
