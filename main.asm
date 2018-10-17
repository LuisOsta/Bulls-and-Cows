	.data
test: .asciiz "Test Output"

#welcome, basic messages
welcomePrompt: .asciiz "We have chosen a 4 letter, word. Let the game begin!"

# user input prompts
guessPrompt: .asciiz "What will your guess be: "
giveupPrompt: .asciiz "Do you wish to give up or continue"

#utlity newline
newline: .asciiz "\n"
.globl newline

#End output
outputEnd: .asciiz "Goodbye. The program has ended."	

	.text
main:
	la $a0, welcomePrompt
	jal outputText
	
	Exit:
		li, $v0, 4
		la, $a0, outputEnd # Denotes the output being run
		syscall
		
		li $v0, 10
		syscall
