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
	
