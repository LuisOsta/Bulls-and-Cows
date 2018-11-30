	.data
buffer: .space 1024
filename: .asciiz "dictionary.txt"
wordNumber: .word 100
word: .asciiz "xxxx"
test: .asciiz "test"
	.text
getWord:
	addi $sp, $sp, -4
	sw $ra, 0($sp) # stores $ra (location of original pointer)

	jal getRandomInts
	move $s0, $v0 #the random word(row r) multiplied by 4
	move $s1, $v1#the words leading up to the word(row r -1) multiplied by 4; used for the substring
	
	################################################
	#OPENS THE DICTIONARY FILE
 	jal openFile
  	move $s6, $v0      # save the file descriptor
 	
 	################################################
 	li $v0, 1
 	move $a0, $s6
 	syscall
 	
 	###############################################
 	#LOADS THE BUFFER WITH ALL WORDS LEADING UP(INCLUSIVE) WORD: AND THEN RETURNS THE SUBSTRINGED RESULT
	move $a0, $s6	#moves the file descriptor
	move $a2, $s0 #moves the word byte start
	jal pickRandomWord #the buffer holds the string
	
	move $a0, $s1
	sub $a1, $s0, $s1
	jal substringBuffer # v0, v1, v2, v3, ..v_n contain the letters of the word(for our case it will always be 4  letters)
	
	###############################################################
  	# Close the file & Return Value
	li   $v0, 16       # system call for close file
  	move $a0, $s6      # file descriptor to close
 	syscall            # close file
 	
 	la $v0, word
 	lw $ra, 0($sp) #restore ra (from previous call)
	addi $sp, $sp, 4
	
 	jr $ra
substringBuffer: #receives the starting index in #a0, and final index in $a1, returns the substringed version of the buffer
	li $t1, 0 #counter
	
	move $t2, $a1 # the word length(equal to 4 in our case)
	sub $t2, $t2,2
	
	
	la $t3, buffer
	addu $t4, $t3, $a0  # BUFFER POINTER sets t4 to the base string value  assumes x is in $a0
	
	Loop:
		beq $t1, $t2, LoopExit
	
		#lb $v0,($t4)      # read the 1st character
		lb $t0, ($t4) #loads the character in the buffer
		sb $t0, word($t1) #appends it to the corresponding index of the word
		
		addu $t4, $t4, 1 #adds the counter to the buffer pointer
		addi $t1, $t1, 1 #adds 1 to the counter
		j Loop
	LoopExit:
		
		jr $ra
	
pickRandomWord:
	###############################################################
  	# Read from file just opened
  	li   $v0, 14       # system call to read from file
  	move $a0, $s6      # file descriptor 
  	la   $a1, buffer   # address of buffer from which to write
  	syscall
  	
openFile:
	###############################################################
  	# Open (for writing) a file that does not exist
  	li   $v0, 13       # system call for open file
  	la   $a0, filename     # output file name
  	li   $a1, 0        # Open for writing (flags are 0: read, 1: write)
  	li   $a2, 0        # mode is ignored
  	
  	syscall            # open a file (file descriptor returned in $v0)
  	jr $ra      	# returns the file descriptor
  	
getRandomInts:
	lw $a1, wordNumber
    	li $v0, 42   #random
    	syscall 	
   	sub $v1, $a0, 1
   	move $v0, $a0
   	
   	mul $v0,$v0, 6 #(multiplies it by the word length)
	mul $v1, $v1, 6 # as above
   	jr $ra

.globl getWord
