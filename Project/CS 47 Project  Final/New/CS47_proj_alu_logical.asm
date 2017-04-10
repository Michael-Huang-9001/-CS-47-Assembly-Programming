.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	subi	$sp, $sp, 24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	li	$t0, '+'
	li	$t1, '-'
	li	$t2, '*'
	li	$t3, '/'
	
	beq	$a2, $t0, addition
	beq	$a2, $t1, subtraction
	beq	$a2, $t2, multiplication
	beq	$a2, $t3, division
	
	j	au_logical_end
	
addition:
	jal	add_logical
	j	au_logical_end

subtraction:
	jal	sub_logical
	j	au_logical_end

multiplication:
	jal	mul_signed
	j	au_logical_end

division:
	jal	div_signed
	j	au_logical_end

au_logical_end:
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr	$ra
	
add_logical:
	subi	$sp, $sp, 24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	or	$a2, $zero, $zero	# Set a2 as 0
	# addi	$a2, $a2, 0x00000000	# Set a2 as 0x00000000 or addition mode
	jal	add_sub_logical
	j	au_logical_end

sub_logical:
	subi	$sp, $sp, 24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	or	$a2, $zero, $zero	# Set a2 as 0
	addi	$a2, $a2, 0xFFFFFFFF	# Set a2 as 0xFFFFFFFF or subtraction mode
	jal	add_sub_logical
	j	au_logical_end
	
add_sub_logical:
	subi	$sp, $sp, 40
	sw	$fp, 40($sp)
	sw	$ra, 36($sp)
	sw	$a0, 32($sp)
	sw	$a1, 28($sp)
	sw	$a2, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 40
	
	or	$t0, $zero, $zero # i, or index
	or	$t1, $zero, $zero # S, or the result of the operation
	or	$t2, $zero, $zero # Set as 0, will use for C
	extract_nth_bit($t2, $a2, $zero) # C = a2[0]
	beq	$a2, 0x00000000, add_sub_logical_loop
	not	$a1, $a1	# Invert second number a1 for subtraction
	# beq	$a2, 0xFFFFFFFF, add_sub_logical_loop
	
add_sub_logical_loop:
	beq	$t0, 0x20, add_sub_logical_end	# If index == 32, end
	extract_nth_bit($t3, $a0, $t0) # t3 = Y, Y = a0[i]
	extract_nth_bit($t4, $a1, $t0) # t4 = B, B = a1[i]
	xor	$s4, $t3, $t4	# xor the two bits
	xor	$s5, $t2, $s4	# xor the result of the xor and the carry bit
	and	$s6, $t3, $t4	# and the results the initial 2 bits
	and	$s7, $t2, $s4	# Then and the results of the and operation and the carry bit
	or	$t2, $s6, $s7	# Or the and operations.
	insert_to_nth_bit($v0, $t0, $s5, $t9)	# Insert full bit addition into v0[i]
	addi	$t0, $t0, 0x1	# Increment index
	j	add_sub_logical_loop
	
add_sub_logical_end:
	move	$v1, $t2	# Move carry bit into v1 for twos_complement_64bit
	
	lw	$fp, 40($sp)
	lw	$ra, 36($sp)
	lw	$a0, 32($sp)
	lw	$a1, 28($sp)
	lw	$a2, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 40
	jr	$ra
	
twos_complement:
	subi	$sp, $sp, 20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1, 8($sp)
	addi	$fp, $sp, 20
	
	not	$a0, $a0	# Invert a0
	or	$a1, $zero, $zero	# Set a1 as 0
	or	$a1, 0x1	# Set a1 as 1 (redundant)
	jal	add_logical	# add_logical will add a0 + 1, which will get the twos compliment of a0
	
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 20
	jr	$ra
	
twos_complement_if_neg:
	subi	$sp, $sp, 16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi	$fp, $sp, 16
	
	move	$v0, $a0	# Copy a0 into v0, assume a0 is positive
	bgt	$a0, $zero, twos_complement_if_neg_end	# If a0 > 0, do not twos compliment, otherwise keep going below.
	jal	twos_complement	# v0 will contain a0's twos compliment

twos_complement_if_neg_end:
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra
	
twos_complement_64bit:
	subi	$sp, $sp, 36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$a2, 20($sp)
	sw	$s4, 16($sp)
	sw	$s5, 12($sp)
	sw	$s6, 8($sp)
	addi	$fp, $sp, 36
	
	not	$a0, $a0	# Invert a0, or lo
	not	$a1, $a1	# Invert a1, or hi
	move	$s4, $a1	# Holds a copy of a1

	or	$a1, $zero, 0x1
	jal	add_logical	# Result in v0 is the twos compliment of lo
	
	move	$s5, $v0	# s5 = twos compliment of lo
	move	$s6, $v1	# s6 = carry bit
	
	move	$a0, $s4	# Move the inverted hi into a0 for adding
	move	$a1, $s6	# Move previous carry bit into a1 for adding to a0
	jal	add_logical	# Result in v0 is the a1 + carry bit of twos compliment of lo
	
	move	$v1, $v0	# v1 = twos compliment of hi
	move	$v0, $s5	# v0 = twos compliment of lo
	
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$a2, 20($sp)
	lw	$s4, 16($sp)
	lw	$s5, 12($sp)
	lw	$s6, 8($sp)
	addi	$sp, $sp, 36
	jr	$ra
	
bit_replicator:
	subi	$sp, $sp, 16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi 	$fp, $sp, 16
	
	or	$v0, $a0, 0x00000000	# Load v0 as 0x00000000
	beq	$a0, $zero, bit_replicator_end	# If a0 = 0, end it, if not, keep going below
	li	$v0, 0xFFFFFFFF
	
bit_replicator_end:
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi 	$sp, $sp, 16
	jr	$ra

mul_unsigned:
	subi	$sp, $sp, 40
	sw	$fp, 40($sp)
	sw	$ra, 36($sp)
	sw	$a0, 32($sp)
	sw	$a1, 28($sp)
	sw	$a2, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 40
	
	or	$t5, $zero, $zero	# Use t5 as index
	or	$t6, $zero, $zero	# Use t6 as H
	move	$s4, $a0	# Make copy of MPLR, or L
	move	$s5, $a1	# Make copy of MCND, or M
	or	$s6, $zero, $zero	# Use s6 as R
	or	$s7, $zero, $zero	# Use s7 as X
	
mul_unsigned_loop:
	beq	$t5, 0x20, mul_unsigned_end
	
	extract_nth_bit($a0, $s4, $zero)	# Extract 0th bit of L and put into replicator
	jal	bit_replicator	# v0 is the 32 replication of the 0th bit of L
	move	$s6, $v0	# R = 32{L[0]}}
	and	$s7, $s5, $s6	# X = M & R
	move	$a0, $t6	# Move H into a0 for adding
	move	$a1, $s7	# Move X into a1 for adding
	jal	add_logical	# v0 is the result of H + X
	move	$t6, $v0	# H = H + X
	srl	$s4, $s4, 0x1	# L = L >> 1
	
	extract_nth_bit($t7, $t6, $zero)	# Use t7 to hold H[0]
	
	li	$t8, 0x1F
	insert_to_nth_bit ($s4, $t8, $t7, $t9)	# L[31] = H[0]
	srl	$t6, $t6, 0x1	# H = H >> 1
	
	addi	$t5, $t5, 0x1	# Increment counter
	j	mul_unsigned_loop
	
mul_unsigned_end:
	move	$v0, $s4
	move	$v1, $t6
	
	lw	$fp, 40($sp)
	lw	$ra, 36($sp)
	lw	$a0, 32($sp)
	lw	$a1, 28($sp)
	lw	$a2, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 40
	jr	$ra
	
mul_signed:
	subi	$sp, $sp, 44
	sw	$fp, 44($sp)
	sw	$ra, 40($sp)
	sw	$a0, 36($sp)
	sw	$a1, 32($sp)
	sw	$a2, 28($sp)
	sw	$a3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 44
	
	move	$s4, $a0	# s4 = copy of a0, or N1
	move	$a2, $a0	# Extra copy of a0
	move	$s5, $a1	# s5 = copy of a1, or N2
	move	$a3, $a1	# Extra copy of a1
	
	jal	twos_complement_if_neg
	move	$s4, $v0	# Store twos_complement_if_neg of a0
	move	$a0, $s5	# Now do the same for a1, or N2
	jal	twos_complement_if_neg
	move	$s5, $v0	# Store twos_complement_if_neg of a1
	
	move	$a0, $s4	# Move s4 into a0 for mul_unsigned
	move	$a1, $s5	# Move s5 into a1 for mul_unsigned
	jal	mul_unsigned
	
	move	$s4, $v0	# s4 = lo of result
	move	$s5, $v1	# s5 = hi of result
	
	li	$t8, 0x1F
	extract_nth_bit($s6, $a2, $t8)	# 
	extract_nth_bit($s7, $a3, $t8)
	
	xor	$t9, $s6, $s7	# Sign = XOR of $a0[31] and $a1[31]
	beq	$t9, $zero, mul_signed_end	# If signed bit is 0, go to end, if not, continue below.
	
	move	$a0, $s4
	move	$a1, $s5
	jal	twos_complement_64bit
	
	
mul_signed_end:
	lw	$fp, 44($sp)
	lw	$ra, 40($sp)
	lw	$a0, 36($sp)
	lw	$a1, 32($sp)
	lw	$a2, 28($sp)
	lw	$a3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 44
	jr	$ra

div_unsigned:
	subi	$sp, $sp, 40
	sw	$fp, 40($sp)
	sw	$ra, 36($sp)
	sw	$a0, 32($sp)
	sw	$a1, 28($sp)
	sw	$a2, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 40
	
	or	$t5, $zero, $zero	# Use t5 as index
	or	$t6, $zero, $zero	# Use t6 as R
	move	$s4, $a0	# Make copy of DVND, or Q
	move	$s5, $a1	# Make copy of DVSR, or D
	or	$s6, $zero, $zero	# Use s6 as S
	or	$s7, $zero, $zero	# Use s7 as a spare
	
	
div_unsigned_loop:
	beq	$t5, 0x20, div_unsigned_end
	
	sll	$t6, $t6, 0x1	# R = R << 1
	li	$t8, 0x1F
	extract_nth_bit($s7, $s4, $t8)	# Extract 31th bit of Q and save it into s7
	insert_to_nth_bit ($t6, $zero, $s7, $t9)	# R[0] = Q[31]
	sll	$s4, $s4, 0x1	# Q = Q << 1
	move	$a0, $t6	# Move R into a0 for subtraction
	move	$a1, $s5	# Move D into a1 for subtraction
	jal	sub_logical	# v0 is the result of R - D
	move	$s6, $v0	# S = R - D
	
	bltz	$s6, div_unsigned_loop_end	# If S < 0, restart loop, otherwise continue below.
	move	$t6, $s6	# R = S
	li	$t8, 0x1
	insert_to_nth_bit($s4, $zero, $t8, $t9)	# Q[0] = 1
	
div_unsigned_loop_end:
	addi	$t5, $t5, 0x1
	j	div_unsigned_loop
	
div_unsigned_end:
	move	$v0, $s4
	move	$v1, $t6
	
	lw	$fp, 40($sp)
	lw	$ra, 36($sp)
	lw	$a0, 32($sp)
	lw	$a1, 28($sp)
	lw	$a2, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 40
	jr	$ra
	
div_signed:
	subi	$sp, $sp, 60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw	$a2, 44($sp)
	sw	$a3, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw	$s3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 60
	
	move	$s4, $a0	# s4 = copy of a0, or N1
	move	$a2, $a0	# Extra copy of a0
	move	$s5, $a1	# s5 = copy of a1, or N2
	move	$a3, $a1	# Extra copy of a0
	
	jal	twos_complement_if_neg
	move	$s4, $v0	# Store twos_complement_if_neg of a0
	move	$a0, $s5	# Now do the same for a1, or N2
	jal	twos_complement_if_neg
	move	$s5, $v0	# Store twos_complement_if_neg of a1
	
	move	$a0, $s4	# Move s4 into a0 for div_unsigned
	move	$a1, $s5	# Move s5 into a1 for div_unsigned
	jal	div_unsigned
	
	move	$s4, $v0	# s4 = Q
	move	$s5, $v1	# s5 = R
	
determine_sign_of_Q:
	li	$t8, 0x1F
	extract_nth_bit($s6, $a2, $t8)	# Extract the 31st bit of a0 into s6
	extract_nth_bit($s7, $a3, $t8)	# Extract the 31st bit of a1 into s7
	
	xor	$s0, $s6, $s7	# Sign of R = XOR of a0[31] and a1[31]
	move	$s1, $s4	# Make a copy of Q just in case twos_complement is not needed.
	beq	$s0, $zero, determine_sign_of_R	# If signed bit is 0, go determine the sign or R, if not, continue below.
	
	move	$a0, $s1	# Move Q to a0 for twos_complement
	jal	twos_complement
	move	$s1, $v0	# Move twos_complement of Q into s1 for temporary storage
	
determine_sign_of_R:
	li	$t8, 0x1F
	extract_nth_bit($s0, $a2, $t8)	# Extract the 31st bit of a0 into s0
	move	$s2, $s5	# Make a copy of R just in case twos_complement is not needed.
	beq	$s0, $zero, div_signed_end	# If signed bit is 0, go to end, if not, continue below.
	
	move	$a0, $s5	# Move R to a0 for twos_complement
	jal	twos_complement
	move	$s2, $v0

div_signed_end:
	move	$v0, $s1
	move	$v1, $s2
	
	lw	$fp, 60($sp)
	lw	$ra, 56($sp)
	lw	$a0, 52($sp)
	lw	$a1, 48($sp)
	lw	$a2, 44($sp)
	lw	$a3, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 60
	jr	$ra
