.data 

inputString: .space 64     # 64 bytes of space max for string input 

.text    # written program 

la $t0 inputString # sets empty space in memory for string input 
add $a0, $0, $t0 
addi $a1, $0, 64 
addi $v0, $0, 8 
syscall 

add $t1, $0, $0   # ensure $t1 and $t3 are set to 0 
add $t3, $0, $0 
la $t2, 0($t0)   # moves base adress of string input to $t2 

funcLoop: 
	jal _strLength # jumps to _strLength function 
	j funcLoop # loops aroud 

_strLength: 
	lb $t4, 0($t2)   # loads value of address 
	sle $t1, $t4, 0   # If the value in the address pointer is == 0, this implies a null term and string is ended 
	beq $t1, 1, endProgram  # If $t4 is found to be == 0, we are done counting and we jump to the endProgram label 
	addi $t2, $t2, 1  # increments address by 1 byte
	addi $t3, $t3, 1 # increments the length counter by one 
	jr $ra  

endProgram: 
	addi $v0, $0, 1  # Prints answer 
	add $a0, $0, $t3 
	addi $a0, $a0, -1 # Subtracts 1 to account for the null terminator counter 
	syscall 
	
	addi $v0, $0, 10   # syscall to terminate program 
	syscall 
