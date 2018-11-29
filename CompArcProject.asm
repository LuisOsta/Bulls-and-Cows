	
	.data
	
outputEnd: .asciiz "Goodbye. The Program has ended."
	
wordToGuess: .asciiz "duck"
	
startMessage1: .asciiz "Welcome to Bulls and Cows!"
startMessage2: "What difficulty would you like to play on? (4 is the hardest, 0 is easiest): "
errorMessage: .asciiz "Invalid input. Please try again."

transition: .asciiz "Excellent! The number of guesses you have is: "
guessLeft: .asciiz "The number of guesses you have left is: "
newline: .asciiz "\n"
.globl newline

loseMessage: .asciiz "Sorry! You weren't able to figure out the word. The word was: " 
winMessage: .asciiz "Congratulations! You were able to figure it out! The word, as you know, was "
quitQuestion: .asciiz "If you want to quit at any time, just type 'quit' when asked to guess a word."
timeMessge: .asciiz "\nYou spent at total of "
seconds: .asciiz " seconds"

guessRequest: .asciiz "Guess a four letter word! "
quitMessage: .asciiz "You opted out! That's okay. The word was: "
	
bullString: .asciiz "The number of bulls is: "
cowString: .asciiz "The number of cows is: "
	
Bull: .word 0
Cow: .word 0

numGuess: .word 0
numGuessDifficulty: .word 25,20,15,10,5
currentGuess: .space  5
	
correctWordArray: .space 5
currentGuessArray: .space 5




InputError: .asciiz "\nIt appears an invalid character was used.\n"
DupeError: .asciiz "\nSorry. You can't repeat characters.\n"
	
	.text
	
main:	
	######################  Initialize The Target Word in Memory as Word Array ###################################
	
	# Here we store the random target word in memory as a byte array so that individual characters may be easily 
	# accessed. 
	
	la $t4, wordToGuess		
	lb $s0,0($t4)			#the first character is in $t0
	lb $s1,1($t4)			#the second character is in $t1
	lb $s2,2($t4)			#the third character is in $t2
	lb $s3,3($t4)			#the fourth character is in $t3
	
	add $t0,$zero,$zero		# reset $t0
	
	sb $s0,correctWordArray($t0)	#put character values in wordToGuess Byte Array
	addi $t0,$t0,1
	sb $s1,correctWordArray($t0)
	addi $t0,$t0,1
	sb $s2,correctWordArray($t0)
	addi $t0,$t0,1
	sb $s3,correctWordArray($t0)
	
########################## Game Setup Get  #####################################################	
	
	# In this section we have introductory messages, get the users desired level of difficulty, 
	# inform the user how how many guesses they have, and inform them that they have the option
	# to quit at anytime.
	
	
	li $v0, 4	 		# prep for string output
	la $a0, startMessage1	 	
	syscall 	 		# Welcome to bulls and cows
	
	li $v0, 4       		# Print newline 
	la $a0, newline      		 
	syscall
	
	li $v0, 4	 		# prep for string output
	la $a0, startMessage2	 	
	syscall 	 		# Ask the user for their desired difficulty
	
	
	
	
		
	li $v0, 5 			# prep for user integer input
	syscall  			# let user enter difficulty
	move $t0,$v0			# put desired difficulty level in $t0 so we can verify it
	
	li $t2,4			# These next 6 lines check that the user entered an 
	sub $t2,$t0,$t2			# integer in the correct range [0,4]
	bgt $t2,$zero,invalidDifficulty
	
	li $t3,4
	add $t2,$t0,$t3
	blt $t2,$t3,invalidDifficulty	# If incorrect input we move to invaldDifficulty section
	
	
	j validDifficulty		# If difficulty is valid we skip the invalidDiffiuclty label
	
invalidDifficulty:

	li $v0, 4	 		#prep for string output
	la $a0,	errorMessage	 	#load the question into argument 0
	syscall
	
	li $v0, 4       		# you can call it your way as well with addi 
	la $a0, newline      		# load address of the string
	syscall
	syscall 
	j main
	
validDifficulty:

	li $v0, 4       		 #Print newline 
	la $a0, newline      		 
	syscall
	
	li $v0, 4	 		# Begin message displaying how many guesses the user starts with
	la $a0, transition	 		
	syscall 	 			
								
	sll $t0,$t0,2			# multiply the difficulty by 4 for word alignment
	la $t1, numGuessDifficulty	# put base address of numGuessDifficulty in $t1
	add $t0,$t1,$t0			# shift the address by correct amount to get proper difficulty
	lw $t0,($t0)			# load the proper number of guesses into $t0
	sw $t0,numGuess			# save the number of guesses in $t0
	
	li $v0,1			# Prep for integer output
	la $a0 ($t0)			# Output the initial number of guesses 
	syscall	
	
	li $v0, 4       		 #Print newline 
	la $a0, newline      		 
	syscall
	
	li $v0, 4       		 #Remind the user that they can quit at any point
	la $a0, quitQuestion      		 
	syscall
	
	li $v0, 4       		 #Print newline
	la $a0, newline      		 
	syscall
	syscall
	
	jal setTimer
	
################################## Get User Guess #######################################

	# In this section, we reset previous bull and cow numbers, see if the user has any guesses left
	# ask the user for their new guess of the target word, save it into memory, 
	#check to see if the quit, handle the case they quit
guessSection:
			
	lw $t0,Bull			# reset number of bulls to 0
	add $t0,$0,$0
	sw $t0,Bull
	
	
	
	lw $t0,Cow			# reset number of cows to 0
	add $t0,$0,$0
	sw $t0,Cow
	
	
	lw $t0, numGuess		# Check to see if the user has guesses left
	beq $t0,$zero lossHandler 	# if the user is out of guesses, branch to gameOver handler
	
					# if NOT we need a new guess
					
	li $v0, 4	 		
	la $a0, guessRequest	 	# Ask the user for their next guess
	syscall 
	

	la $a0, currentGuess		# We want to store the user guess in the label currentGuess
	li $a1, 5			# allocate space for the user guess (4 characters)
	 				# (for some reason 5 spaces is needed for 4 characters)
	
	li $v0, 8			# prep system for user string input
	syscall	
	
					# Load the bytes in to registers to cross reference with target word
	la $t4, currentGuess
	lb $s0,0($t4)			#the first character is in $s0
	lb $s1,1($t4)			#the second character is in $s1
	lb $s2,2($t4)			#the third character is in $s2
	lb $s3,3($t4)			#the fourth character is in $s3
	
	add $t0,$zero,$zero		# reset $t0
	
############################################### INPUT VALIDATION ##########################################################
	#Ok, have to check two things, whether a-z or A-Z and if any dupes.  Can strtoupper during the checks.
	# A is 65, Z is 90, a is 97, z is 122
	# if (((a>=65)&&(a<=70)) || ((a>=97)&&(a<=122))
	
	
	addi $t5, $zero, 65 
	blt $s0, $t5, UserInputError 	# branches is ASCII code is less than 65. guess[0] < ASCII(A)
	addi $t5, $zero, 90
	ble $s0, $t5, FirstFix	     	# IF ASCII[A]<=guess[0]<=ASCII[Z] we need to lowercase our letter
	addi $t5, $zero, 97
	blt $s0, $t5, UserInputError	# branches is ASCII code is less than 97 but greater than 90 (Not a valid char)
	addi $t5, $zero, 122
	ble $s0, $t5, SecondCheck  	# If lowercase, we branch to check the second letter
	j UserInputError
	
FirstFix: 	
					# If the first character is uppercase, add 32 to make the character lowercase
	add $s0, $s0, 32 
SecondCheck: 				# This loop checks if the second character is within bounds 
	
	
	addi $t5, $zero, 65	     	# branches is ASCII code is less than 65. guess[1] < ASCII(A)
	blt $s1, $t5, UserInputError 
	addi $t5, $zero, 90	     	# IF ASCII[A]<=guess[1]<=ASCII[Z] we need to lowercase our letter
	ble $s1, $t5, SecondFix
	addi $t5, $zero, 97	     	# branches is ASCII code is less than 97 but greater than 90 (Not a valid char)
	blt $s1, $t5, UserInputError
	addi $t5, $zero, 122		# If lowercase, we branch to check the second letter
	ble $s1, $t5, ThirdCheck
	j UserInputError
SecondFix: 				# If the second character is uppercase, add 32 to make the character lowercase
	add $s1, $s1, 32
	
ThirdCheck: 				# This loop checks if the third character is within bounds

	addi $t5, $zero, 65	   	# branches is ASCII code is less than 65. guess[2] < ASCII(A)
	blt $s2, $t5, UserInputError
	addi $t5, $zero, 90		# IF ASCII[A]<=guess[2]<=ASCII[Z] we need to lowercase our letter
	ble $s2, $t5, ThirdFix
	addi $t5, $zero, 97	   	 # branches is ASCII code is less than 97 but greater than 90 (Not a valid char)
	blt $s2, $t5, UserInputError
	addi $t5, $zero, 122		# If lowercase, we branch to check the second letter
	ble $s2, $t5, FourthCheck
	j UserInputError
	
ThirdFix: 				# If the third character is uppercase, add 32 to make the character lowercase
	add $s2, $s2, 32
	
FourthCheck: 				# This loop checks if the fourth character is within bounds
	
	addi $t5, $zero, 65		# branches is ASCII code is less than 65. guess[3] < ASCII(A)
	blt $s3, $t5, UserInputError
	addi $t5, $zero, 90		# IF ASCII[A]<=guess[3]<=ASCII[Z] we need to lowercase our letter
	ble $s3, $t5,FourthFix
	addi $t5, $zero, 97         	# branches is ASCII code is less than 97 but greater than 90 (Not a valid char)
	blt $s3, $t5, UserInputError
	addi $t5, $zero, 122		# If lowercase, we branch to check the second letter
	ble $s3, $t5, AfterCheck
	j UserInputError
	
FourthFix: 				# If the third character is uppercase, add 32 to make the character lowercase
	add  $s3, $s3, 32
	
	
	
	
AfterCheck:
	# Need to check that there are no duplicate characters
	beq $s0, $s1, UserDupe 	# compare 1st to 2nd
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
	
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 30 #Load the pitch (0-127) into $a0
	li $a1, 500 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 58 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127
	syscall
	j guessSection
	
	# Display message about duplicates
UserDupe:
	li $v0, 4
	la $t0, DupeError
	add $a0, $t0, $zero
	syscall
	
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 30 #Load the pitch (0-127) into $a0
	li $a1, 500 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 58 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127
	syscall
	
	j guessSection
	add $t0,$zero,$zero            # reset $t0
	add $t1,$zero,$zero  
	add $t2,$zero,$zero   
	add $t3,$zero,$zero   
	add $t4,$zero,$zero        
	
next:
	sb $s0,currentGuessArray($t0)	# our values are good! Save them into memory!
	addi $t0,$t0,1			# I figured we might want them for something
	sb $s1,currentGuessArray($t0)
	addi $t0,$t0,1
	sb $s2,currentGuessArray($t0)
	addi $t0,$t0,1
	sb $s3,currentGuessArray($t0)
							
										
													
###################################################### Quit Check ##############################################################		
quitChecker: 
	li $t0, 113 #q			# Individually checks each byte in the guessed word to see if they
	bne $s0,$t0,bullsCounter	# match the word 'quit'. If there is a single mismatch it branches to 
	li $t0,117 #u			# continue the game
	bne $s1,$t0,bullsCounter
	li $t0,105 #i
	bne $s2 ,$t0, bullsCounter
	li $t0,116 #t
	bne $s3 ,$t0,bullsCounter
	
	# If we are here the program didn't branch so the user wants to quit
	
	li $v0, 4	 		
	la $a0, newline	 		# print newline (readabilty)
	syscall 	 		
	
	li $v0, 4	 		# print quitMessage
	la $a0, quitMessage	 	
	syscall 	 		
	
	li $v0, 4	 		# display correct word
	la $a0, wordToGuess	 	
	syscall 
	
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 66 #Load the pitch (0-127) into $a0
	li $a1, 1000 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 47 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127
	syscall
	
	li $v0, 32 #31 is the system code for sleep
	li $a0, 500 #Load the pitch (0-127) into $a0
	syscall	 		
	
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 67 #Load the pitch (0-127) into $a0
	li $a1, 1000 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 47 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127
	syscall
	
	li $v0, 32 #31 is the system code for sleep
	li $a0, 500 #Load the pitch (0-127) into $a0
	syscall	 
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 62 #Load the pitch (0-127) into $a0
	li $a1, 1000 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 47 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127
	syscall
	
		 		
	
	
		 			
	
	
	j Exit				# Game over so end program
	
######################################## Calculate Bulls and Handle Win ###########################################
	
	# If we are here then the user didn't quit! Let's count bulls. If we get 4 bulls at any time then 
	# the user won and we congratulate them and display the winning word
	
bullsCounter:
	lw $s3,Bull
	add $t0,$0,$0
	li $t4,4
	
bullLoop:				# loop that will go through the Arrays representing both the target word and user guess
	beq $t0,$t4 exitBullsCount	# If there is a match, handle it with the Match label
	lb $s1,correctWordArray($t0)	# if not look at the next two charcaters and if those are outside the array we are done
	lb $s2,currentGuessArray($t0)
	beq $s1,$s2 bullMatch
	addi $t0,$t0,1			# update byte array index
	j bullLoop	
	
bullMatch:				
	addi $s3,$s3,1			# if a match update the bull counter $s3
	addi $t0,$t0,1			# next index
	j bullLoop			# back to the loop
	
exitBullsCount:				

	sw $s3,Bull			# save the bull count in memory address of Bull
	beq $s3,$t4 winHandler		# if they got four bulls go to winHandler


################################### Cow Counter #######################################

	# Now that we calculate the bulls we need to find the number of cows. This is a lil harder since we need 
	# to NOT count the cases where the indicies match
	
cowCounter:
				
	add $s3,$0,$0			# reset $s3 to 0 (will use it as cow counter as we did with bulls)
	add $t0,$0,$0			# reset $t0 (outer loop index)
	add $t1,$0,$0			# reset $t1 (inner loop index)
	li $t4,4			# load length of our array into $t4. We use this to determine when to stop 
					# iterating through our arrays
	
outerCowLoop:				# outerCowLoop is our outer for loop. We check each byte in the GuessWord
					# array with the correctWord

	beq $t0,$t4,exitCowCount	# Are we at the end of currentGuessArray? If so we exit
	
	lb $s1,currentGuessArray($t0)		# load in values of each array
	lb $s2,correctWordArray($t1)
	
	beq $s1,$s2 cowMatch		# if the two charcters match go to the cowMatch label
	addi $t1,$t1,1			# increment inner loop
	beq $t1,$t4,outerIncrement	# is the inner loop done?
	j outerCowLoop			
	

cowMatch:				# we have a match!

	beq $t1,$t0,skipCow		# if the indicies match then this is actually a bull, not a cow. skip adding it!
	addi $s3,$s3,1			# if not, this is a cow! increment cow counter
	
skipCow:	
	addi $t1,$t1,1			# increment inner loop
	beq $t1,$t4,outerIncrement	# if the inner loop is done, jump to OuterIncrement
	j outerCowLoop
	
outerIncrement:				# inner loop needs a reset and we need to increment the outer loop
	add $t1,$0,$0
	addi $t0,$t0,1
	j outerCowLoop			# jump back into main loop
	
	
exitCowCount:
	sw $s3,Cow			# save the number of cows
	
	add $s3,$0,$0			# reset the registers
	add $t0,$0,$0
	add $t1,$0,$0
	

############################################### Conclusion ######################################
	
	#In this section we print the number of bulls and cows, handle winning, 
	# transitioning to the next guess, and losing the game
	
	# Display bulls and cows for the most recent guess
	
	li $v0, 4       		# Print newline (for readability)
	la $a0, newline      		 
	syscall
	
	
	li $v0, 4	 		# print string precursor to number of bulls
	la $a0, bullString	 	
	syscall 	 		
	
	lw $t5,Bull			# print number of bulls
	li $v0,1
	move $a0,$t5
	syscall
	
	li $v0, 4       		# Print newline
	la $a0, newline      		 
	syscall
	
	lw $t6,Cow
	
	li $v0, 4	 		# print string precursor to number of cows
	la $a0, cowString	
	syscall 	
	
	
	li $v0,1			# print number of cows
	move $a0,$t6
	syscall
	
	li $v0, 4       		# Print  newline
	la $a0, newline      		 
	syscall
	
	
	# We need to tell the user the number of guesses they have left!
	
	lw $t0, numGuess		# decrement the number of guesses and store it
	addi $t0,$t0,-1
	sw $t0 numGuess
	
	lw $t0, numGuess		# Check to see if the user has guesses left
	beq $t0,$zero,lossHandler 	# if the user is out of guesses, branch to gameOver handler
	
	
	li $v0, 4	 		# display string precursor to number of guesses left
	la $a0, guessLeft	 	
	syscall 	 		
	
	
	li $v0,1			# display number of guesses remaining
	move $a0,$t0
	syscall
	
	li $v0, 4       		 # Print newline
	la $a0, newline      		 
	syscall
	
	
	j guessSection			# If we are here, there are still guesses left, and the game must continue
	

	# Handle the user winning!
	
winHandler:	
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 66 #Load the pitch (0-127) into $a0
	li $a1, 1000 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 0 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127
	syscall
	
	li $v0, 32 #31 is the system code for sleep
	li $a0, 1000 #Load the pitch (0-127) into $a0
	syscall	 		
	
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 70 #Load the pitch (0-127) into $a0
	li $a1, 1000 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 0 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127
	syscall
	
	li $v0, 32 #31 is the system code for sleep
	li $a0, 1000 #Load the pitch (0-127) into $a0
	syscall	 
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 73 #Load the pitch (0-127) into $a0
	li $a1, 1000 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 0 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127
	syscall
	
	li $v0, 4       		# Print newline (for readability)
	la $a0, newline      		 
	syscall

	li $v0, 4	 		# print win string
	la $a0, winMessage	 	
	syscall 	 		
	
	
	jal getTime 			#gets time spent
	
	
	li $v0, 4 			#prints the time spent
	la $a0, timeMessge
	syscall
	li $v0, 4
	move $a0, $s6
	syscall
	li $v0, 4
	la $a0, seconds
	syscall
	
	li $v0, 4	 		# show them the word they got right
	la $a0, wordToGuess	 	
	syscall 	 
	
	li $v0, 4       		# Print newline (for readability)
	la $a0, newline      		 
	syscall
				

	j Exit				# Game over
	
	# We need to handle the case the user lost!
	
lossHandler:
	
	#Plays the sound
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 30 #Load the pitch (0-127) into $a0
	li $a1, 1000 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 58 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127
	syscall
	#Plays the sound
	#Plays the sound
	li $v0, 32 #31 is the system code for sleep
	li $a0, 1000 #Load the pitch (0-127) into $a0
	syscall
	
	#Plays the sound
	li $v0, 31 #31 is the system code for playing sounds
	li $a0, 25 #Load the pitch (0-127) into $a0
	li $a1, 1000 #Loads the duration of the sound (in milliseconds) into $a1
	li $a2, 58 # Loads the instrument into $a2 (Table at : http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html )
	li $a3, 127 # Loads the volume into $a3 (0-127
	syscall

	#Plays the sound
	
	

	li $v0, 4	 		# print loss message
	la $a0, loseMessage	 	
	syscall 	 	
	
	
	li $v0, 4	 		# display correct word
	la $a0, wordToGuess	 	
	syscall 	 		
	
	li $v0, 4       		#Print newline
	la $a0, newline      		 
	syscall
	
	j Exit

#Starts the timer for the length of the game
#Stores the time i  $s7
setTimer:
	li $v0, 30
	syscall
	move $s7, $a0
	jr $ra	

#Stores the current elapsed time in seconds in $s6
getTime:
	li $v0, 30
	syscall
	move $s6, $a0
	sub $s6, $s6, $s7
	jr $ra
	
################################################   Exit    ####################################################
	
Exit:
	li $v0, 4       		#Print newline
	la $a0, newline      		 
	syscall


	li, $v0, 4
	la, $a0, outputEnd   		# Denotes the output being run
	syscall
	
	
		
	li $v0, 10
	syscall
