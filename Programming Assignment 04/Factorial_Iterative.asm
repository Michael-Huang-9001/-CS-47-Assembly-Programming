.include "./cs47_macro.asm"

.data
msg1: .asciiz "Enter a number ? "
msg2: .asciiz "Factorial of the number is "
charCR: .asciiz "\n"

.text
.globl main
main:	print_str(msg1)
	read_int($t0)
	
# Write body of the iterative
# factorial program here
# Store the factorial result into
# register $s0
	
	li $s0, 1	# factorial result
	li $t1, 1	# counter for the number of loops
	LOOP:
	mul $s0, $s0, $t1	# s0 = s0 * t1
	addi $t1, $t1, 1	# t1 = t1 + 1
	ble $t1, $t0, LOOP	# go back to loop if t1 is less than t0
	
	
	
	print_str(msg2)
	print_reg_int($s0)
	print_str(charCR)
	
	exit
	
