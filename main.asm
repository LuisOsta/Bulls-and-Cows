	
	.data
outputEnd: .asciiz "Goodbye. The Program has ended"
	
wordToGuess: .asciiz "duck"
	
startMessage: .asciiz "Welcome to Bulls and Cows! What difficulty would you like to play on? (4 is the hardest, 0 is easiest)"
errorMessage: .asciiz "Invalid input. Please try again"

transition: .asciiz " Excellent! The number of guesses you have is : "
guessLeft: .asciiz "The number of guesses you have left is: "
newline: .asciiz "\n"
.globl newline

loseMessage: .asciiz "Sorry! You weren't able to figure out the word. The word was :" 
winMessage: .asciiz "Congratulations! You were able to figure it out! The word, as you know, was "
quitQuestion: .asciiz "If you want to quit at any time, just type 'quit' when asked to guess a word"

guessRequest: .asciiz "Guess a four letter word!"
quitMessage: .asciiz "You opted out! That's okay. The word was "
	
bullString: .asciiz "The number of bulls is : "
cowString: .asciiz "The number of cows is : "
	
B: .word 0
C: .word 0

numGuess: .word 0
numGuessDifficulty: .word 25,20,15,10,5
currentGuess: .space  4
	
currentGuessArray: .space 5
wordToGuessArray: .space 5
	
	
	.text
	
main:	##########################We need to get inout Difficulty #####################################################
	
	
	la $t4, wordToGuess
	lb $s0,0($t4)			#the first character is in $t0
	lb $s1,1($t4)			#the second character is in $t1
	lb $s2,2($t4)			#the third character is in $t2
	lb $s3,3($t4)			#the fourth character is in $t3
	
	add $t0,$zero,$zero
	
	sb $s0,wordToGuessArray($t0)
	addi $t0,$t0,1
	sb $s1,wordToGuessArray($t0)
	addi $t0,$t0,1
	sb $s2,wordToGuessArray($t0)
	addi $t0,$t0,1
	sb $s3,wordToGuessArray($t0)
	
	
	
	
	
	li $v0, 4	 		#prep for string output
	la $a0, startMessage	 	#load the question into argument 0
	syscall 	 		#Ask the Question
		
	li $v0, 5 			#prep for user integer input in var 0
	syscall  			#Take in user value
	move $t0,$v0			#put desired difficulty in $t0
	
	li $t2,4
	sub $t2,$t0,$t2
	bgt $t2,$zero,Error
	
	li $t3,4
	add $t2,$t0,$t3
	blt $t2,$t3,Error
	
	
	
	li $v0, 4	 		#prep for string output
	la $a0, transition	 	#load the question into argument 0
	syscall 	 		#Ask the Question	
								
	sll $t0,$t0,2			# multiply the difficulty by 4
	la $t1, numGuessDifficulty	#put address of array in $t1
	add $t0,$t1,$t0			#Shift the adress by correct amount
	lw $t0,($t0)			#put guess value in $t0
	sw $t0,numGuess
	
	li $v0,1			#Prep for integer output
	la $a0 ($t0)			# Output the initial number of guesses 
	syscall	
	
	li $v0, 4       		 #Print two newlines
	la $a0, newline      		 
	syscall
	
	li $v0, 4       		 #Print two newlines
	la $a0, quitQuestion      		 
	syscall
	
	li $v0, 4       		 #Print two newlines
	la $a0, newline      		 
	syscall
	syscall

	
	
	j guessSection
Error:
	li $v0, 4	 		#prep for string output
	la $a0,	errorMessage	 	#load the question into argument 0
	syscall
	
	li $v0, 4       		# you can call it your way as well with addi 
	la $a0, newline      		 # load address of the string
	syscall
	syscall 
	j main
	

guessSection:
	lw $t0,B
	add $t0,$0,$0
	sw $t0,B
	
	lw $t0,C
	add $t0,$0,$0
	sw $t0,C
	
	
	lw $t0, numGuess
	beq $t0,$zero GameOver
	
	li $v0, 4	 		#prep for string output
	la $a0, guessRequest	 	#Ask the user for their guess
	syscall 
	

	la $a0, currentGuess		#load adress to store user guess
	li $a1,5			#allocate space for the user input
	
	li $v0, 8			#prep system for user input
	syscall	
	
	
	la $t4, currentGuess
	lb $s0,0($t4)			#the first character is in $t0
	lb $s1,1($t4)			#the second character is in $t1
	lb $s2,2($t4)			#the third character is in $t2
	lb $s3,3($t4)			#the fourth character is in $t3
	
	add $t0,$zero,$zero
	
	sb $s0,currentGuessArray($t0)
	addi $t0,$t0,1
	sb $s1,currentGuessArray($t0)
	addi $t0,$t0,1
	sb $s2,currentGuessArray($t0)
	addi $t0,$t0,1
	sb $s3,currentGuessArray($t0)
	
	
quitChecker: 
	li $t0,113
	bne $s0 ,$t0 bullsCounter
	li $t0,117
	bne $s1 ,$t0  bullsCounter
	li $t0,105
	bne $s2 ,$t0  bullsCounter
	li $t0,116
	bne $s3 ,$t0  bullsCounter
	
	li $v0, 4	 		#prep for string output
	la $a0, newline	 	#load the question into argument 0
	syscall 	 		#Ask the Question
	li $v0, 4	 		#prep for string output
	la $a0, quitMessage	 	#load the question into argument 0
	syscall 	 		#Ask the Question
	
	li $v0, 4	 		#prep for string output
	la $a0, wordToGuess	 	#load the question into argument 0
	syscall 	 		#Ask the Question
	
	j Exit
	
	
	
	
	
	
bullsCounter:
	lw $s3,B
	add $t0,$0,$0
	li $t4,4
bullLoop:	
	beq $t0,$t4 exitBullsCount
	lb $s1,currentGuessArray($t0)
	lb $s2,wordToGuessArray($t0)
	beq $s1,$s2 bullMatch
	addi $t0,$t0,1
	j bullLoop
	
bullMatch:
	addi $s3,$s3,1
	addi $t0,$t0,1
	j bullLoop
	
exitBullsCount:
	sw $s3,B
	
	beq $s3,$t4 win

cowsCounter:
	lw $s3,C
	add $s3,$0,$0
	add $t0,$0,$0
	add $t1,$0,$0
	li $t4,4
	
outerCowLoop:
	beq $t0,$t4,exitCowCount
	
	lb $s1,currentGuessArray($t0)
	lb $s2,wordToGuessArray($t1)
	beq $s1,$s2 cowMatch
	addi $t1,$t1,1
	beq $t1,$t4,outerInc
	j outerCowLoop
	

cowMatch:
	beq $t1,$t0,skip
	addi $s3,$s3,1
skip:	
	addi $t1,$t1,1
	beq $t1,$t4,outerInc
	j outerCowLoop
outerInc:
	add $t1,$0,$0
	addi $t0,$t0,1
	j outerCowLoop
	
exitCowCount:
	sw $s3,C
	add $s3,$0,$0
	add $t0,$0,$0
	add $t1,$0,$0
	
	
	

conclusion:
	li $v0, 4       		 #Print two newlines
	la $a0, newline      		 
	syscall
	syscall
	
	li $v0, 4	 		#prep for string output
	la $a0, bullString	 	#load the question into argument 0
	syscall 	 		#Ask the Question
	
	lw $t5,B
	li $v0,1
	move $a0,$t5
	syscall
	
	li $v0, 4       		 #Print two newlines
	la $a0, newline      		 
	syscall
	
	lw $t6,C
	
	li $v0, 4	 		#prep for string output
	la $a0, cowString	 	#load the question into argument 0
	syscall 	 		#Ask the Question
	
	
	li $v0,1
	move $a0,$t6
	syscall
	
	li $v0, 4       		 #Print  newlines
	la $a0, newline      		 
	syscall
	
	lw $t0, numGuess
	addi $t0,$t0,-1
	sw $t0 numGuess
	
	li $v0, 4	 		#prep for string output
	la $a0, guessLeft	 	#load the question into argument 0
	syscall 	 		#Ask the Question
	
	
	li $v0,1
	move $a0,$t0
	syscall
	
	li $v0, 4       		 #Print two newlines
	la $a0, newline      		 
	syscall
	
	
	j guessSection
	

win:	
	li $v0, 4       		 #Print two newlines
	la $a0, newline      		 
	syscall


	li $v0, 4	 		#prep for string output
	la $a0, winMessage	 	#load the question into argument 0
	syscall 	 		#Ask the Question
	
	li $v0, 4	 		#prep for string output
	la $a0, wordToGuess	 	#load the question into argument 0
	syscall 	 		#Ask the Question

	j Exit
	
	
GameOver:
	li $v0, 4	 		#prep for string output
	la $a0, loseMessage	 	#load the question into argument 0
	syscall 	 		#Ask the Question
	
	li $v0, 4	 		#prep for string output
	la $a0, wordToGuess	 	#load the question into argument 0
	syscall 	 		#Ask the Question
	
	
Exit:
	li, $v0, 4
	la, $a0, outputEnd # Denotes the output being run
	syscall
		
	li $v0, 10
	syscall