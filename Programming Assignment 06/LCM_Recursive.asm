.include "./cs47_macro.asm"

.data
msg1: .asciiz "Enter a +ve number : "
msg2: .asciiz "Enter another +ve number : "
msg3: .asciiz "LCM of "
s_is: .asciiz "is"
s_and: .asciiz "and"
s_space: .asciiz " "
s_cr: .asciiz "\n"

.text
.globl main
main:
	print_str(msg1)
	read_int($s0)
	print_str(msg2)
	read_int($s1)
	
	move $v0, $zero
	move $a0, $s0
	move $a1, $s1
	move $a2, $s0
	move $a3, $s1
	jal  lcm_recursive
	move $s3, $v0
	
	print_str(msg3)
	print_reg_int($s0)
	print_str(s_space)
	print_str(s_and)
	print_str(s_space)
	print_reg_int($s1)
	print_str(s_space)
	print_str(s_is)
	print_str(s_space)
	print_reg_int($s3)
	print_str(s_cr)
	exit

#------------------------------------------------------------------------------
# Function: lcm_recursive 
# Argument:
#	$a0 : +ve integer number m
#       $a1 : +ve integer number n
#       $a2 : temporary LCM by incrementing m, initial is m
#       $a3 : temporary LCM by incrementing n, initial is n
# Returns
#	$v0 : lcm of m,n 
#
# Purpose: Implementing LCM function using recursive call.
# 
#------------------------------------------------------------------------------

# Worked with members of CS club (Khoi, Raymond).
lcm_recursive:
	# Stores frame
	subi $sp, $sp, 28 # Changing sp by 28
	sw $fp, 28($sp) # Storing frame pointer
	sw $ra, 24($sp) # Storing return address
	sw $a0, 20($sp) # Storing a0 - a3
	sw $a1, 16($sp)
	sw $a2, 12($sp)
	sw $a3, 8($sp)
	addi $fp, $sp, 28 # Move stack pointer
	
	# Body
	beq $a2, $a3, RETURN # $a2 = $a3, return
	bgt $a2, $a3, CASE_1 # $a2 > $a3, goto CASE_1
	blt $a2, $a3, CASE_2 # $a2 < $a3, goto CASE_2
	
# Recursive call
CALL:
	jal lcm_recursive
	j LCM_RESTORE
	
# $a2 > $a3
CASE_1: add $a3, $a3, $a1 # $a3 = $a3 + $a1
	j CALL
	
# $a2 < $a3
CASE_2: add $a2, $a2, $a0 # a2 = $a2 + $a0
	j CALL
	
# Returns value
RETURN:
	move $v0, $a2
	
# Restores frame
LCM_RESTORE:
	lw $fp, 28($sp)
	lw $ra, 24($sp)
	lw $a0, 20($sp)
	lw $a1, 16($sp)
	lw $a2, 12($sp)
	lw $a3, 8($sp)
	addi $sp, $sp, 28
	jr $ra
