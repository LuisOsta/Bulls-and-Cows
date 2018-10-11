	.data
test: .asciiz "Test Output"
.globl test

#utlity newline
newline: .asciiz "\n"
.globl newline

#End output
outputEnd: .asciiz "Goodbye. The program has ended."	

	.text
main:
	
	
	Exit:
		li, $v0, 4
		la, $a0, outputEnd # Denotes the output being run
		syscall
		
		li $v0, 10
		syscall
