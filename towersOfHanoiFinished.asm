.ORIG x3000

;caller main()
MAIN	
	LEA R0,towersOfHanoiPrompt	;Displays "Towers of Hanoi."
	PUTS 				;==========================

	LEA R0,numberOfDisks		;Displays "Number of disks," and displays the number on the screen.
	PUTS				;
	GETC				;
	OUT				;=================================================================

	LD R1,hex30			;This block of code is to get the hexidecimal for the ascii character
	NOT R1,R1			;entered.Lets say what's in R0 is x0033, this is ascii for 3 not hex.
	ADD R1,R1,#1			;So in order to get 0-9 I have to use hex30 as the base line for sub-
	ADD R0,R1,R0			;traction.I negate hex30, get two's complement of that and then add
	                   		;R0 and R1 together and put that into R0 to give me the hex I want. 
					;Then I clear out R1 for the following stuff.
					;Having the hex of this value is crucial later as I need it for the if,else in the recursive function.
					;==============================================================================================================================================
							
	LEA R1,instructionsPrompt	;I'm loading my "Instructions to move n disks... prompt into R1."
	AND R3,R3,#0			;I then I need to change the 22nd character to the value in R0.
	ADD R3,R3,#11			;In order to do this, I add 11 to R3 and R4 as number much higher
	AND R4,R4,#0			;than this can't be done given the bit restriction.
	ADD R4,R4,#11			;I add to R5 the result being 22. I then store the character that's
	ADD R5,R4,R3			;R0 which represents the number of disks into R1.The new
	ADD R1,R1,R5			;instructionsPropmt is then loaded into R0 and I display it.
	LD R2,botOfStack		;Ok,this line and the following are a little confusing as to what
	STR R0,R2,#0			;I'm doing. I'm loading the bottom of my stack x5000 into R2. I then 
	LD R5,hex30			;need to store whatever n number of disks is into this register.
	ADD R0,R0,R5			;The thing is, I also need to store n into R1 which contains at this point			
	STR R0,R1,#0			;the position in memory where the character is I want to change with what R0 is.
	LEA R0,instructionsPrompt	;		
	PUTS				;=============================================================================
					
numberOfDisks		.STRINGZ "How many disks (1-9)?"	;I have this label here because other wise
								;it'll be over 256 lines from the halt instruction
								;making this string label non functional.

;CALLER'S PORTION OF STACK BUILDING FROM MAIN()			
;ACTIVATION RECORD START BEING BUILT PAST THIS POINT.		
;=============================================================================================================		
	;I'm loading my pointers and arguments in the following registers.				
	LD R5,botOfStack		;R5 --> x5000
	LD R6,R6Pointer			;R6 --> x5000
	;arguments
	LD R1,startPost			;R1 = x0001	
	LD R2,endPost			;R2 = x0003
	LD R3,midPost			;R3 = x0002
	
	;Push midPost = 2 onto stack.				
	ADD R6,R6,#-1			;R6 --> x4FFF		
	STR R3,R6,#0			;x0002 put into x4FFF
					
	;Push endPost = 3 onto stack.
	ADD R6,R6,#-1			;R6 --> x4FFE
	STR R2,R6,#0			;x003 put into x4FFE

	;Push startPost = 1 onto stack.	
	ADD R6,R6,#-1			;R6 --> x4FFD
	STR R1,R6,#0			;x001 put into x4FFD

	;Push n = ? onto the stack.
	LDR R0,R5,#0			;Loading contents of R5 being n into R4
	ADD R6,R6,#-1			;At this point R6 --> x4FFC diskNum
	STR R0,R6,#0			;Storing contents of R0 being n into x4FFC
	JSR MOVE_DISK			;Now jump to moveDisk. The HALT here is 
	HALT				;Critical, base case won't work without this and calls to MOVE_DISK will always occur.
					;=====================================================================================



;CALLER'S PORTION OF STACK BUILDING COMPLETED MAIN()
;CALLEE'S PORTION OF STACK BUILDING. MOVE_DISK()
;==============================================================================================================
;Callee moveDisk(n,1,3,2)
MOVE_DISK
	
	;Pushing return address onto stack.
	ADD R6,R6,#-1			;R6 --> x4FFB
	STR R7,R6,#0			;Store R7 which contains return address at x4FFB
					;================================================
	
	LDR R3,R6,#4			;Here I'm loading loading the arguments from the activation record 
	LDR R2,R6,#3			;into the correct registers, an offset of 4 to R6 where R6 is currently
	LDR R1,R6,#2			;pointing to the return address gives me the midPost argument which is what
	LDR R0,R6,#1			;I want for R3. The other three registers follow the same pattern.
					;===========================================================================

	;R0 is diskNum		
	ADD R0,R0,#-1
	 
	;if adding -1 to my disk number gives results in a zero, that means diskNum is 1 and hence I go
	;to my base case being the smallest sub problem.
	BRz BASE_CASE

;if(diskNum > 1)	
NOT_BASE_CASE 
	
	ADD R0,R0,#1 			;Resetting R0 back to whatever it was previously because 
					;I had subtracted one from R0 to allow for branching.
		    			

;CALLER'S PORTION OF STACK BUILDING MOVE_DISK()
;Activation record being build for recursive call moveDisk(diskNum - 1,start,mid,end)
;For the first recursive caller moveDisk(diskNum - 1,start,mid,end) the slots in the stack
;for the arguments will contain different values.It was (n,1,3,2) = (diskNum,start,end,mid).
;now diskNum will be diskNum -1, start will be the same, but the value of midPost is in the 
;slot for the endPost argument.The value for the endPost is in the midPost slot of this activation recrod
;being built.
;==============================================================================================================
	ADD R6,R6,#-1			;R6 -->x4FFA	;Loading 3 into midPost arg
	STR R2,R6,#0			;Store in Stack
					;=============================================

	ADD R6,R6,#-1			;R6 -->x4FF9	;Loading 2 into endPost arg
	STR R3,R6,#0			;Store in stack
					;================================================

	ADD R6,R6,#-1			;R6 -->x4FF8	;Loading 1 into startPost arg
	STR R1,R6,#0			;Store in stack.
					;=============================================

					;Loading diskNum = 3 into R0
	ADD R6,R6,#-1			;R6 -->x4FF7
	ADD R0,R0,#-1			;Loading diskNum - 1 arg
	STR R0,R6,#0			;Store in stack.
					;================================================
	
	JSR MOVE_DISK	;Jump back to MOVE_DISK and do the callee portion having to due with the RA.
			;Everytime I use JSR it change the address of R7 which is important to how this works.
;=============================================================================================================	
	
	;Part 1
	;move disk string.	;I'm doing the same type of thing with the strings that I did in the base case.
	AND R0,R0,#0		;At this point, I've finished the printing for diskNum and this is for
	AND R1,R1,#0		;diskNum - 1.
	AND R2,R2,#0
	AND R3,R3,#0

	LEA R1,moveDisk	
	
	ADD R6,R6,#1	
	LDR R0,R6,#0
	
	LD R3,hex30
	ADD R0,R0,R3

	ADD R2,R2,#10	
	ADD R1,R1,R2

	STR R0,R1,#0
	LEA R0,moveDisk
	PUTS

	;Part 2
	;from post string.
	AND R0,R0,#0
	AND R1,R1,#0
	AND R2,R2,#0
	AND R3,R3,#0

	LEA R1,fromPost	
	
	ADD R6,R6,#1	
	LDR R0,R6,#0
	
	LD R3,hex30
	ADD R0,R0,R3

	ADD R2,R2,#10	
	ADD R1,R1,R2

	STR R0,R1,#0
	LEA R0,fromPost
	PUTS

	;Part 3
	;to post string.
	AND R0,R0,#0
	AND R1,R1,#0
	AND R2,R2,#0
	AND R3,R3,#0

	LEA R1,toPost	
	
	ADD R6,R6,#1	
	LDR R0,R6,#0

	LD R3,hex30
	ADD R0,R0,R3

	ADD R2,R2,#8	
	ADD R1,R1,R2

	STR R0,R1,#0
	LEA R0,toPost	
	PUTS
	
	ADD R6,R6,#-3	;Once again... due to the way I deal with the String the R6 pointer is screwed up.
			;I have to have it point back to what it originally was pointing at, which is always
			;the RA.
	
	LDR R3,R6,#4	;I'm loading what's in the midPost,endPost,startPost,and diskNum slots 
	LDR R2,R6,#3	;of the activation record into these registers.
	LDR R1,R6,#2	;
	LDR R0,R6,#1	;===================================================================================
			
	
	
	
	
;2nd CALLER'S PORTION OF STACK BUILDING MOVE_DISK().
;Activation record being built for moveDisk(diskNumber - 1,midPost,endPost,startPost)
;This recursive call follows the same sort of pattern as the first one except that
;the (diskNum,startPost,endPost,midPost) slots in the stack of the activation record will contain
;different values and it's based off of the very first activation record created.
;=============================================================================================================
	
	ADD R6,R6,#-1	;R6 --> at midPost arg slot.
	STR R1,R6,#0	;push startPost value here.
	
	ADD R6,R6,#-1	;R6 --> at endPost arg slot.
	STR R2,R6,#0	;push endPost value here.

	ADD R6,R6,#-1	;R6 --> at startPost slot.
	STR R3,R6,#0	;push midPost value here.

	ADD R6,R6,#-1	;R6 --> at diskNum slot.
	ADD R0,R0,#-1	;Decrement one from diskNum.
	STR R0,R6,#0	;push diskNum value here.
	
	JSR MOVE_DISK	;Again, go back to MOVE_DISK as that place does the callee portion of code.
;==============================================================================================================
	
	LDR R7,R6,#0	;This chunk is very important.I what R6 is pointing to into R7.
	ADD R6,R6,#1	;I pop the Ra off the stack.
	ADD R6,R6,#4	;I pop the arguments off the stack.
	RET		;I return to whatever is in R7.
	
;if(diskNum ==1)
BASE_CASE
			;Ok, how I created the string messages for the actual move disk commands
			;merits a little summary before I give the details for each section of each
			;part. I break the string "Move disk n, from post a, to post b," into three parts.
			;Each part I do the same process except when I add a certain number to change
			;the character I want, that changes based on the string,so for part 1 being
			;"Move disk n," n is the character I want to change which is 10 characters from
			;that string. This number may change for the different parts, but it's the same pattern. 
			;The process for the printing is.
			;1.Clear R0-R3
			;2.Load String into R1
			;3.Add 1 to R6 to give me the parameter I want to repace the character I want.
			;4.Load hex30 and add to parameter to give correct hex representation.
			;5.Add x number of character to a register, add to string.
			;6.store the character into this spot in memory for R1.3 for example would replace n.
			;7.Load the new string into R0 and display it!
	;Part 1
	;"Move disk 1"	"to post b."
	AND R0,R0,#0	;I'm clearing R0-R3 just to give a clean slate as these registers will be changing
	AND R1,R1,#0	;temporarily for printing out the move disk command strings which will be done in
	AND R2,R2,#0	;three parts, "Move disk n,from post a,to post b" where n,a,b will be changed via registers.
	AND R3,R3,#0	;=========================================================================================

			
	LEA R1,moveDisk	;I'm loading "Move disk n" from memory into R1
	
	ADD R6,R6,#1	;I add one to the R6 --> to give me the diskNum arg from the activation record
	LDR R0,R6,#0	;I need to replace the n character for this string.
			;==============================================================================

	LD R3,hex30	;I'm loading x0030 which represents zero so I can add this to R0 giving me the correct
	ADD R0,R0,R3	;hexidecimal representation for the number 3 for example.
			;=====================================================================================

	ADD R2,R2,#10	;I'm adding 10 to R2 because the 10th character n is what I need to replace.
	ADD R1,R1,R2	;I add R2 with R1 containing my String. This will replace the 10th slot of memory
			;which contains n with the character I want being the disk number.
			;=================================================================================

	STR R0,R1,#0	;I want to store the diskNumber arg at this position of R1, then
	LEA R0,moveDisk	;I finally load this changed string into R0 and display it.
	PUTS		;======================================================================================
	
	;Part 2
	;"from post a"
	AND R0,R0,#0
	AND R1,R1,#0	
	AND R2,R2,#0
	AND R3,R3,#0

	LEA R1,fromPost
		
	ADD R6,R6,#1
	LDR R0,R6,#0

	LD R3,hex30
	ADD R0,R0,R3

	ADD R2,R2,#10	
	ADD R1,R1,R2

	STR R0,R1,#0
	LEA R0,fromPost
	PUTS

	;Part 3
	;"to post b"
	AND R0,R0,#0
	AND R1,R1,#0
	AND R2,R2,#0
	AND R3,R3,#0

	LEA R1,toPost
		
	ADD R6,R6,#1	
	LDR R0,R6,#0

	LD R3,hex30
	ADD R0,R0,R3

	ADD R2,R2,#8	
	ADD R1,R1,R2

	STR R0,R1,#0
	LEA R0,toPost	
	PUTS
		
	ADD R6,R6,#-3	;Now because I added one for each string part to R6 it messed up where R6 was pointing
			;at, so I have to regain R6 pointing to the return address.
		
	LDR R7,R6,#0	;Loading what R6 is pointing to at this time which will be the return address into R7.
	ADD R6,R6,#1	;Pop off the RA and R6 is now pointing to diskNum slot in stack.
	ADD R6,R6,#4	;Pop off arguments which makes R6 point to the RA from the previous activation record
			;created.
			
	RET	      	;Return to whatever address is in R7.

	
;Labels/variables.
saveR7			.BLKW 1
hex30			.FILL x0030
startPost		.FILL 1	;variable startPost starts as 1
midPost			.FILL 2	;variable midPost starts as 2
endPost			.FILL 3 ;variable endPost starts as 3
R6Pointer		.FILL x5000 ;Address at bottom of stack to hold my R6 --> "--> means pointer."
botOfStack		.FILL x5000 ;Address at bottom of stack to hold my R5 -->
instructionsPrompt	.STRINGZ "\nInstructions to move n disks from post 1 to post 3: \n\n\n"
towersOfHanoiPrompt	.STRINGZ "-----Towers of Hanoi-----\n"
;numberOfDisks		.STRINGZ "How many disks (1-9)?"
moveDisk		.STRINGZ "Move disk n "
fromPost		.STRINGZ "from post a "
toPost			.STRINGZ "to post b \n"
notInBaseCaseSTR	.STRINGZ "I'm not in base case..."
			

;=========================================STACK PICTURE=======================================================
;												
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;					
						
;========================================================================================================================================
;					R6--> 		x4FF1|	x3051  	|RA		moveDisk(diskNum - 1,midPost,endPost,startPost)	;
;========================================================================================================================================
;					R6--> 		x4FF2|	1  	|diskNum - 1	moveDisk(diskNum,startPost,endPost,midPost)	;
;					R6--> 		x4FF3|	1  	|startPost							;
;					R6--> 		x4FF4|	3  	|endPost							;
;					R6--> 		x4FF5|	2  	|midPost							;
;========================================================================================================================================
;					R6--> 		x4FF6|	x3051  	|RA		moveDisk(diskNum - 1,startPost,midPost,endPost)	;     
;========================================================================================================================================
;					R6--> 		x4FF7|	2  	|diskNum - 1 	moveDisk(diskNum,startPost,endPost,midPost)	;
;					R6--> 		x4FF8|	1  	|startPost   	caller portion of stack.	     		;
;					R6--> 		x4FF9|	2  	|endPost							;
;                                       R6--> 		x4FFA| 	3 	|midPost							;
;======================================================================================================================================== 
;moveDisk(n,1,3,2) callee portion.	R6--> 		x4FFB| 	x303D 	|RA								;
;========================================================================================================================================								 		main's portion including
;	main() portion of  		R6--> 		x4FFC| 	3 	|diskNum  	
;	stack. "CALLER"			R6--> 		x4FFD| 	1 	|startPost  	
;					R6--> 		x4FFE| 	3 	|endPost	
;					R6--> 		x4FFF| 	2 	|midPost
;					R5-->R6--> 	x5000| 	3 	|n	
;					
;


			;End program.
			.END