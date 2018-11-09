	.data
buffer: .space 1024
filename: .asciiz "dictionary.txt"
wordNumber: .word 100

	.text
main:
	jal getRandomInt
	move $t0, $v0 #the random word(row r)
	move $t1, $t0#the words leading up to the word(row r -1)
	
	sub $t1, $t1, 1
	
	mul $t0,$t0, 4 #(multiplies it by the word length)
	mul $t1, $t1, 4 # as above
	
	li $v0, 1
	la $a0, ($t0)
	syscall
	
 	jal openFile
  	move $s6, $v0      # save the file descriptor 
	move $a0, $s6	#moves the file descriptor
	move $a2, $t0 #moves the word byte start
	
	jal pickRandomWord
 
	la $a0, buffer
	li $v0, 4
	syscall
	
	la $t0, buffer
	Exit:
	  ###############################################################
  		# Close the file 
		li   $v0, 16       # system call for close file
  		move $a0, $s6      # file descriptor to close
 		syscall            # close file
 		
		li $v0, 10
		syscall

pickRandomWord:
	###############################################################
  	# Read from file just opened
  	li   $v0, 14       # system call to read from file
  	move $a0, $s6      # file descriptor 
  	la   $a1, buffer   # address of buffer from which to write
  	#la   $a2, 372      # buffer length in a2
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
  	
getRandomInt:
	lw $a1, wordNumber
    	li $v0, 42   #random
    	syscall
   	
   	move $v0, $a0
   	jr $ra