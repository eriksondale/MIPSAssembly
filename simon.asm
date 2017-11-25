# Written by Dale Erikson for Dr. Tan Project 2 CS0447 Fall 2017 
.data

notes: .space 100    # allocating 100 bytes for notes, i.e. 100 notes max to play before error 

.text

#set input and gui vars to 0   
li $t8, 0   
li $t9, 0

startGame: 

# Waiting for user to press start.....

bne $t9, 16, startGame

# Calls start sound 
li $t8, 16 


# Ensures input and gui vars are set to 0 
li $t8, 0   
li $t9, 0


# Continuing on with game 
contGame: 
	la $t0, notes # Sets $t0 to address 1 byte before start      
	addi $t0, $t0, -1 
	addi $sp, $sp, -8   # Saving $t0, $t1 for function call 
	sw $t0, 4($sp)
	sw $t1, 0($sp) 
	jal playSequence # Calling playSequence function 
	addi $sp, $sp, 8   # Returning $t0, $t1 from stack 
	lw $t0, -4($sp)
	lw $t1 -8($sp) 
	
	la $t0, notes     # Sets $t0 to address 1 byte before start of notes 
	addi $t0, $t0, -1 
	addi $sp, $sp, -8     # Saving $t0, $t1 for function call
	sw $t0, 4($sp)
	sw $t1, 0($sp)  
	jal userPlay   # Calling userPlay function
	addi $sp, $sp, 8      # returning values from the stack 
	lw $t0, -4($sp)
	lw $t1 -8($sp) 
	
	
	j contGame     # Loops these processes until user loses....(inevitable) 
getRandomNum: 	# returns a random number between 1-4 to $v0, no argument needed  

	li $v0, 30     # Call for system time 
	syscall 
	add $t0, $0, $a0 
	
	li $v0, 40   # Set seed
	li $a0, 0   # Set ID to 0 
	add $a1, $0, $t0  # Sets seed to be based on time 
	syscall 
	
	li $v0, 42 # Randon num syscall 
	li $a0, 0 # Set ID 
	li $a1, 4 # Set upper range 
	syscall 
	addi $v0, $v0, 1 
	add $v0, $0, $a0
	
	jr $ra 

playSequence: # plays current sequence of notes and adds one more note 
	addi $sp, $sp, -4   # need to save $ra in stack 
	sw $ra, 0($sp) 
	
	addi $t0, $t0, 1 # increases address pointer 
	lb $t1, 0($t0)   # loads note from current addresss
	beq $t1, 1, blue   # goes to button submethod depending on input 
	beq $t1, 2, yellow
	beq $t1, 4, green
	beq $t1, 8, red
	j endOfList    # jumps to endOfList if byte loaded == 0 (no note present) 
	blue: 
		li $t8, 1 # plays blue note
		li $t8, 0 
		j cont
	yellow: 
		li $t8, 2  # plays yellow note  
		li $t8, 0 
		j cont
	green: 
		li $t8, 4 # plays green note 
		li $t8, 0 
		j cont
	red: 
		li $t8, 8 # plays red note 
		li $t8, 0 
		j cont 
	
	endOfList:    # process to add new note to game 
	addi $sp $sp, -8   # saving values for function call
	sw $t0, 4($sp)
	sw $t1, 0($sp) 
	jal getRandomNum   # calls random number gen and places in $v0 
	addi $sp $sp, 8   # returns values after function call from stack 
	lw $t0, -4($sp)
	lw $t1, -8($sp) 
	
	add $t2, $0, $v0  #s0 is result from random # gen 
	li $t3, 1 
	sllv $t3, $t3, $t2    #t2 maps random num to values for GUI and such 
	
	
	add $t8, $0, $t3  # plays new color 
	li $t8, 0 
	
	sb $t3, 0($t0)  # stores new color thing in array 
	
	j doneCount    # after new note is added, we reach bottom of recursive method 
	cont:     # method calls itself if there are still more notes to play 
		jal playSequence 
	
	doneCount: 
	lw $ra, 0($sp)     # return for method 
	addi $sp, $sp, 4 
	jr $ra
userPlay:    # start of user play section 
	addi $sp, $sp, -4   # need to save $ra 
	sw $ra, 0($sp)  
	li $t9, 0 
	
	add $t0, $t0, 1   # increases address pointer by 1 
	lb $t1, 0($t0)
	beq $t1, 0, doneUser     #if loaded byte is == 0, user as played all notes 
	waitUser: 
		beq $t9, 0, waitUser   # waiting for user input 
		add $t8, $0, $t9       
		li $t8, 0               
		beq $t9, $t1, contUserPlay  # if user plays right now, allow user to continue playing 
		bne $t9, $t1, endGame   # if user plays wrong note, end game 
	contUserPlay:
	  jal userPlay  # method calls itself 
	
	doneUser:      # user done playing, reached bottom of recursive method 
	lw $ra, 0($sp) 
	addi $sp, $sp, 4 
	jr $ra
endGame: 	  # process to end game 
	li $t8, 15     # play end game sound
	
	li $t9, 0   # ensure values are set to 0 for next game 
	li $t8, 0  
	
	la $a0, notes      # setting up clearMemSpace function and calling it 
	li $a1, 0
	jal clearMemSpace  
	
	j startGame 
clearMemSpace:		# Function to clear memory space used in previous game....
	addi $sp, $sp, -4   
	sw $ra, 0($sp) 
	
	li $t5, 0 
	sb $t5, 0($a0)   # Writing zero into current addresss 
	
	addi $a0, $a0, 1   
	addi $a1, $a1, 1 
	beq $a1, 100, doneClear 
	contClear:                # continue clearing.....
		jal clearMemSpace 
	doneClear:               # done clearing....return......
		lw $ra, 0($sp) 
		addi $sp, $sp, 4 
		jr $ra 