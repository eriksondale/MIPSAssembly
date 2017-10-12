#There is no .data segment in this program. 
#This program was written by Dale Erikson for Project 1 for Dr. Tan (CS447 Pitt Fall 2017) 
.text 

clockSection: 
	li $t9, 0  # ensure input to GUI can be taken 

	addi $v0, $0, 30 #get time passed 
	syscall 
	
	li $a2, 1000 # sets $a2 to 1000 (to convert ms to s)
	j div64bit  # jumps to section that divides big number in $a0 and $a1 by $a2 
returnDiv:
	addi $v0, $v0, -14400    # takes result of division section and subtracts by 4 hours in seconds 
	add $a0, $0, $v0 
	li $a1, 43200       
	divu $a0, $a1 

	mfhi $s0             #left overseconds in the day 

	addi $s0, $s0, -4800

	li $t0, 3600       
	divu $s0, $t0         
	mflo $s0              #s0 = Hour

	mfhi $t1 
	li $t0, 60 
	div $t1, $t0 
	mflo $s1              #s1 = Minute
	mfhi $s2              #s2 = Second

	#Print the time
	
	add $t8, $0, $s0
	sll $t8, $t8, 8
	or $t8, $t8, $s1
	sll $t8, $t8, 8 
	or $t8, $t8, $s2 

	# delay program by .5s 
	li $v0, 32
	li $a0, 500
	syscall
	
	#jumps to other sections 
	
	beq $t9, 2, stopWatchStart
	beq $t9, 4, timerStart 
	j clockSection   # default jump to beginning of clock 
	

#Input: $a0 is smaller precision, $a1 is larger part of number, $a2 is 1000 

#Out: $v0 = answer, $v1 is remainder
div64bit: 
	li $v0, 0 # clears return registers 
	li $v1, 0 
	addi $t0, $0, 0xFFFF0000    # purposes for anding first 16 bits of register 
	loopBig:
		sll $v1, $v1, 16      #division 'algorithm' based on long division technique used by humans 
		and $t1, $t0, $a1
		srl $t1, $t1, 16 
		add $t1, $t1, $v1 
		sll $a1, $a1, 16 
		divu $t1, $a2 
		
		sll $v0, $v0, 1
		mflo $t6 # contains value to be added to answer 
		add $v0, $v0, $t6 
		
		
		mfhi $v1 
		bne $a1, $0, loopBig 
	
	loopSmall: #same as big loop, only for smaller 32-bit of 64bit number 
		sll $v1, $v1, 16
		and $t1, $t0, $a0
		srl $t1, $t1, 16 
		add $t1, $t1, $v1 
		sll $a0, $a0, 16 
		divu $t1, $a2 
		
		sll $v0, $v0, 1
		mflo $t6 # contains value to be added to answer 
		add $v0, $v0, $t6 
		
		mfhi $v1  
		
		bne $a0, $0, loopSmall
 	j returnDiv
stopWatchStart:       # section that clears time registers and resets graphics 
	li $s0, 0 
	li $s1, 0 
	li $s2, 0 
	j stopWatchReset 
stopWatchWait:         # Wait section for stop watch (no incrementing) 
	li $t9, 0    # sets $t9 to 0 to prepare for new user input 
	
	li $v0, 32 # delay .1s in order to have some time to accept input 
	li $a0, 100 
	syscall
	
	beq $t9, 1, clockSection    # branches for various new user input in GUI 
	beq $t9, 2, stopWatchReset 
	beq $t9, 4, timerStart 
	beq $t9, 256, stopWatchReset 
	beq $t9, 64, stopWatchGo  
	j stopWatchWait      # jumps back to wait section 
	
stopWatchGo:              # actually incrementing section of stop watch 
	li $t9, 0        # sets $t9 to 0 to prepare for new user input 
	addi $a1, $a1, 1      # increments seconds by one 
	
	add $a2, $0, $a1      # moves value of $a1 to $a2 
	li $t0, 60      # constant 60 
	div $a2, $t0   
	mfhi $s0 # seconds left over 
	mflo $a2            
	div $a2, $t0
	mfhi $s1 # minutes calculation
	mflo $a2
	div $a2, $t0
	mfhi $s2 # hours calculation
	mflo $a2
	
	li $v0, 32     # delays system for .9s 
	li $a0, 900
	syscall
	
	add $t8, $0, $s2    # Updates stop watch display 
	sll $t8, $t8, 8
	or $t8, $t8, $s1
	sll $t8, $t8, 8 
	or $t8, $t8, $s0 
	
	beq $t9, 1, clockSection  # braches for various user input in GUI 
	beq $t9, 2, stopWatchReset 
	beq $t9, 4, timerStart  
	beq $t9, 128, stopWatchWait 
	j stopWatchGo
	
stopWatchReset:        # reset section, clears GUI and $s time registers 
	li $a1, 0 
	li $t8, 0 
	j stopWatchWait 

timerStart:           # Start timer section 
	li $s0, 0     # resets $s time values and clock display 
	li $s1, 0 
	li $s2, 0 
	li $t8, 0  
	j timerReset 
timerWait:
	li $t9, 0   # ensures new user input can be done 
	
	li $v0, 32 # delay 1s in order to have some time to accept input 
	li $a0, 100 
	syscall
	
	beq $t9, 1, clockSection   # branch for different possible user inputs
	beq $t9, 2, stopWatchStart
	beq $t9, 4, timerReset 
	beq $t9, 8, addHour
	beq $t9, 16, addMinute
	beq $t9, 32, addSecond 
	beq $t9, 256, timerReset 
	beq $t9, 64, timerGo 
	j timerWait 
addMinHour:
	addi $s1, $0, 0
addHour:                   # Add hour button 
	add $s0, $s0, 1     #$s0 is hours 
	beq $s0, 24, over24
	sll $s3, $s0, 16 # Graphical Update of time
	sll $s4, $s1, 8
	or $s3, $s3, $s4
	or $s3, $s3, $s2
	add $t8, $0, $s3  
	j timerWait        # jumps to timer wait loop after hour is added to timer
over24: 
	add $s0, $0, $0 
	sll $s3, $s0, 16 # Graphical Update of time
	sll $s4, $s1, 8
	or $s3, $s3, $s4
	or $s3, $s3, $s2
	add $t8, $0, $s3  
	j timerWait        # jumps to timer wait loop after hour is added to timer 
addSecMinute:
	addi $s2, $0, 0     # When adding 1s to 59s, this is needed to increment min by 1 and set s back to 0 
addMinute: 
	beq $s1, 59, addMinHour
	addi $s1, $s1, 1   #$s1 is minutes 
	
	sll $s3, $s0, 16 # Graphical Update of time
	sll $s4, $s1, 8
	or $s3, $s3, $s4
	or $s3, $s3, $s2
	add $t8, $0, $s3 
	
	j timerWait
addSecond: 
	beq $s2, 59, addSecMinute
	addi $s2, $s2, 1   #$s2 is seconds 
	addi $t0, $0, 1 
	add $t8, $t8, $t0
	j timerWait
timerGo:
	li $t9, 0 # clears $t9 for future input 
	# Every second: 
	
	beq $s2, $0, adjustMinute  #If seconds is 0 go to adjustment 
countdown:                   # section where timer actually goes down 
	addi $s2, $s2, -1       # lowers second counter by 1 
	addi $t0, $0, -1 
	add $t8, $t8, $t0         # Updates graphics 
	
	li $v0, 32 # delay decreasing of seconds by .9s   
	li $a0, 900
	syscall
	
	beq $t9, 1, clockSection     # branching based on user input to GUI 
	beq $t9, 2, stopWatchStart
	beq $t9, 4, timerReset 
	beq $t9, 256, timerReset 
	beq $t9, 128, timerWait 
	j timerGo            # jumps to timer go! 
	
adjustMinute:           # adjust minute section 
	beq $s1, $0, adjustHour       # if minutes left == 0, need to pull from hour, jumps to adjusthour
	addi $s1, $s1, -1           # subtracts minute by 1 
	addi $s2, $0, 60            # sets second to 60 
	
	sll $s3, $s0, 16          #Graphical update of time 
	sll $s4, $s1, 8
	or $s3, $s3, $s4
	or $s3, $s3, $s2
	add $t8, $0, $s3 
	
	j countdown     # jumos back to countdown section 
	
adjustHour:  		# adjustHour section when timer needs to pull from hour section 
	beq $s0, $0, timerWait # If hours == 0 then time is up! moves to timer wait section 
	addi $s0, $s0, -1    # subtracts hour by 1 
	addi $s1, $s1, 59   # sets minute to 59
	addi $s2, $s2, 60   # sets second to 60 
	 
	sll $s3, $s0, 16  #Graphical update of time
	sll $s4, $s1, 8
	or $s3, $s3, $s4
	or $s3, $s3, $s2
	add $t8, $0, $s3 
	
	j countdown     # jumps back to countdown section 
timerReset: 
	li $s0, 0      # Resets $s register time and graphical time, jumps back to timer wait loop after 
	li $s1, 0
	li $s2, 0
	li $t8, 0 
	j timerWait

exitProgram:           # Exits program, not actually used 
	li $v0, 10
	syscall 