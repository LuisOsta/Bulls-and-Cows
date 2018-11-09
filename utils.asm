	.text
.globl outputText

# The text to output will be on a0
outputText:
	#prints out input
	li, $v0, 4
	syscall
	#prints out a newline
	la, $a0, newline
	syscall
	jr $ra
	
winningSound:
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 50 #Load the pitch (0-127) into $a0
	li $a1,1000 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 56 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127)
	syscall
	jr $ra
	
LosingSound:
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 67 #Load the pitch (0-127) into $a0
	li $a1,1000 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 8 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127)
	syscall
	jr $ra
