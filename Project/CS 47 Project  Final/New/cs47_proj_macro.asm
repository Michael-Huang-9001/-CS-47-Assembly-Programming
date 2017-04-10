# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

# regD (result) would be 0 or 1, regS would be the source number, regT would be the index
.macro extract_nth_bit($regD, $regS, $regT)
	addi	$t9, $zero, 0x1
	sllv	$t9, $t9, $regT
	and	$regD, $regS, $t9
	srlv	$regD, $regD, $regT
.end_macro

# D = result, S = index, T = register containing bit value, mask = temp reg
.macro insert_to_nth_bit ($regD, $regS, $regT, $maskReg)
	addi	$maskReg, $zero, 0x1
	sllv	$maskReg, $maskReg, $regS
	not	$maskReg, $maskReg
	and	$regD, $regD, $maskReg
	add	$maskReg, $zero, $regT
	sllv $maskReg, $maskReg, $regS
	or   $regD, $regD, $maskReg
.end_macro