	.data
outputEnd: .asciiz "Goodbye. The Program has ended"
	
wordToGuess: .asciiz "duck"
	
startMessage: .asciiz "Welcome to Bulls and Cows! What difficulty would you like to play on? (4 is the hardest, 0 is easiest)"
errorMessage: .asciiz "Invalid input. Please try again"

InputError: .asciiz "\nIt appears an invalid character was used.\n"
DupeError: .asciiz "\nSorry. You can't repeat characters.\n"

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
	
	############################################### INPUT VALIDATION ##########################################################
	#Ok, have to check two things, whether a-z or A-Z and if any dupes.  Can strtoupper during the checks.
	# A is 65, Z is 90, a is 97, z is 122
	# if (((a>=65)&&(a<=70)) || ((a>=97)&&(a<=122))
	
	#addi $t5, $zero, 48
	#blt $s0, $t5, UserInputError
	#addi $t5, $zero, 57
	#ble $s0, $t5, SecondCheck
	addi $t5, $zero, 65 # 65 is a
	blt $s0, $t5, UserInputError # branches is ASCII code is less than 65
	addi $t5, $zero, 90
	ble $s0, $t5, SecondCheck
	addi $t5, $zero, 97
	blt $s0, $t5, UserInputError # branches is ASCII code is less than 97
	addi $t5, $zero, 122
	ble $s0, $t5, FirstFix
	j UserInputError
FirstFix: # If the first character is lowercase, subtract 32 bits to make the character uppercase
	sub $s0, $s0, 32
SecondCheck: # This loop checks if the second character is within bounds 
	
	#addi $t5, $zero, 48
	#blt $s1, $t5, UserInputError
	#addi $t5, $zero, 57
	#ble $s1, $t5, ThirdCheck
	addi $t5, $zero, 65
	blt $s1, $t5, UserInputError
	addi $t5, $zero, 90
	ble $s1, $t5, ThirdCheck
	addi $t5, $zero, 97
	blt $s1, $t5, UserInputError
	addi $t5, $zero, 122
	ble $s1, $t5, SecondFix
	j UserInputError
SecondFix: # If the second character is lowercase, subtract 32 bits to make the character uppercase
	sub $s1, $s1, 32
ThirdCheck: # This loop checks if the third character is within bounds

	#addi $t5, $zero, 48
	#blt $s2, $t5, UserInputError
	#addi $t5, $zero, 57
	#ble $s2, $t5, FourthCheck
	addi $t5, $zero, 65
	blt $s2, $t5, UserInputError
	addi $t5, $zero, 90
	ble $s2, $t5, FourthCheck
	addi $t5, $zero, 97
	blt $s2, $t5, UserInputError
	addi $t5, $zero, 122
	ble $s2, $t5, ThirdFix
	j UserInputError
ThirdFix: # If the third character is lowercase, subtract 32 bits to make the character uppercase
	sub $s2, $s2, 32
FourthCheck: # This loop checks if the fourth character is within bounds

	#addi $t5, $zero, 48
	#blt $s3, $t5, UserInputError
	#addi $t5, $zero, 57
	#ble $s3, $t5, AfterCheck
	addi $t5, $zero, 65
	blt $s3, $t5, UserInputError
	addi $t5, $zero, 90
	ble $s3, $t5, AfterCheck
	addi $t5, $zero, 97
	blt $s3, $t5, UserInputError
	addi $t5, $zero, 122
	ble $s3, $t5, FourthFix
	j UserInputError
FourthFix: # If the fourth character is lowercase, subtract 32 bits to make the character uppercase
	sub $s3, $s3, 32
AfterCheck:
	# Need to check that there are no duplicate characters
	beq $s0, $s1, UserDupe # compare 1st to 2nd
	beq $s0, $s2, UserDupe # compare 1st to 3rd
	beq $s0, $s3, UserDupe # compare 1st to 4th
	beq $s1, $s2, UserDupe # compare 2nd to 3rd
	beq $s1, $s3, UserDupe # compare 2nd to 4th
	beq $s2, $s3, UserDupe # compare 3rd to 4th
	j next
	#end error checking
	############################################### END OF CHECK     ##########################################################
	
	# Display invlaid characters used 
	UserInputError:
	li $v0, 4
	la $t0, InputError
	add $a0, $t0, $zero
	syscall
	j guessSection
	
	# Display message about duplicates
	UserDupe:
	li $v0, 4
	la $t0, DupeError
	add $a0, $t0, $zero
	syscall
	j guessSection
	add $t0,$zero,$zero            # reset $t0
	
	next:
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
	
	#Plays the sound
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 67 #Load the pitch (0-127) into $a0
	li $a1,1000 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 8 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127)
	syscall

	li $v0, 4	 		#prep for string output
	la $a0, winMessage	 	#load the question into argument 0
	syscall 	 		#Ask the Question
	
	li $v0, 4	 		#prep for string output
	la $a0, wordToGuess	 	#load the question into argument 0
	syscall 	 		#Ask the Question

	j Exit
	
	
GameOver:
	#Plays the sound
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 50 #Load the pitch (0-127) into $a0
	li $a1,1000 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 56 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127)
	syscall
	
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
