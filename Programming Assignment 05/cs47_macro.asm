#<------------------ MACRO DEFINITIONS ---------------------->#
        # Macro : print_str
        # Usage: print_str(<address of the string>)
        .macro print_str($arg)
	li	$v0, 4     # System call code for print_str  
	la	$a0, $arg   # Address of the string to print
	syscall            # Print the string        
	.end_macro
	
	# Macro : read_int
	# Usage: read_int(<register of the int>)
	.macro read_int($reg)
	li	$v0, 5 # System call code for read_int
	syscall		# Print the int
	move	$reg, $v0 # Save the read integer to the specified register
	.end_macro
	
	
	# Macro : print_int
        # Usage: print_int(<val>)
        .macro print_int($arg)
	li 	$v0, 1     # System call code for print_int
	li	$a0, $arg  # Integer to print
	syscall            # Print the integer
	.end_macro
	
	# Macro : print_reg_int
	# Usage: print_reg_int(<register of the int>)
	.macro print_reg_int($reg)
	li	$v0, 1	# System call code for print_int
	move	$a0, $reg	# Register of the integer to print
	syscall		# Print the integer in the register
	.end_macro
	
	# Macro : swap_hi_lo
	# Usage: swap_hi_lo(<temp register 1>, <temp register 2>)
	.macro swap_hi_lo($temp1, $temp2)
	mfhi	$temp1 # Move Hi into $temp1
	mflo	$temp2 # Move Lo into $temp2
	mthi	$temp2 # Move $temp2 into Hi
	mtlo	$temp1 # Move $temp1 into Lo
	.end_macro
	
	# Macro : print_hi_lo
	# Usage: print_hi_lo(<argument 1>, <argument2>, <argument3>, <argument4>)
	.macro print_hi_lo($strHi, $strEqual, $strComma, $strLo)
	
	print_str($strHi) # Prints "Hi"
	print_str($strEqual) # Prints " = "
	
	mfhi	$t1	# Move Hi into $t1
	print_reg_int($t1) # Prints the int in $t1
	
	print_str($strComma) # Prints ","
	print_str($strLo) # Prints "Lo"
	print_str($strEqual) # Prints " = "
	
	mflo	$t2	# Move Lo into $t2
	print_reg_int($t2) # Prints the int in $t2
	.end_macro
	
	# Macro : lwi(<register>, <higher bits of word immediate>, <lower bits of word immediate>)
	.macro lwi($reg, $ui, $li)
	lui 	$reg, $ui # Loads $ui into the higher bits of $reg
	ori	$reg, $reg, $li # Loads $li into the lower bits of $reg
	.end_macro
	
	# Macro : push(<register>)
	.macro push($reg)
	sw $reg, 0x0($sp) # Stores data in $reg into the stack pointer's location
	subi $sp, $sp, 4 # Move the stack pointer after storing data, sp = sp - 4
	.end_macro
	
	# Macro : pull(<register>)
	.macro pop($reg)
	addi $sp, $sp, 4 # Move the stack pointer before popping
	lw $reg, 0x0($sp) # Stores data in the stack pointer's location into $reg
	.end_macro
	
	# Macro : exit
        # Usage: exit
        .macro exit
	li 	$v0, 10 
	syscall
	.end_macro
