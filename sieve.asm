; Midterm Programming Test for CSCI 2525 - Assembly Language & Computer Organization
; Written by Justin Shapiro

TITLE sieve.asm
; Best viewed in Notepad++

INCLUDE Irvine32.inc ;[This program uses Delay, Clrscr, Crlf, Gotoxy, ReadInt, SetTextColor, WaitMsg, WriteChar, WriteDec, and WriteString]

.code

	main PROC
	;*****************************************************************************************
	;Description - directs user to the appropriate point in the program based on their choice 
	;			   and performs basic error checking
	;Recieves - user input stored in eax
	;Returns - user input stored eax
	;*****************************************************************************************
		.data 
			badInput   BYTE "Invalid selection. Please try again.", 0   ; ASCII character array needed to tell the user that they have made a 
																		; bad selection
		.code
			mov eax, 0													; clear all registers used in the program as a preliminary, assiduous step
			mov ebx, 0																		
			mov ecx, 0
			mov edx, 0
			mov esi, 0
			mov edi, 0
			
			Menu: call menuPrint										; call menuPrint PROC to display the menu
				  call ReadInt											; provide user an interface to enter their selection. Input recieved in eax
																		; direct user to their specified location if their input is valid
				  cmp eax, 1
					je SieveStart
				  cmp eax, 2
					je DivisorStart
				  cmp eax, 3
					je Quit
				  jmp InputFalse										; direct user to appropriate procedure based on eax = 1, 2 or 3 only.
				  InputFalse: 											; -> all other input recieved will be processed under the InputFalse label
							  call Crlf

							  mov eax, 12								; set console output to red
							  call SetTextColor

							  mov ecx, 40								; center by writing 40 spaces to the console
							  Spce: mov al, ' '
								    call WriteChar
							  loop Spce
							  
																		; Prompt: "Invalid selection.Please try again."
							  mov edx, OFFSET badInput
							  call WriteString

							  mov ecx, 2								; stylish ellipsis animation
							  dotAnimation: mov eax, 300				; -> eax recieves value in milliseconds to pause the program
									        call Delay					; ->-> Irvine32 procedure Delay is used to produce ellipsis animation
									        mov al, '.'
									        call WriteChar
							  loop dotAnimation

							  mov eax, 300
							  call Delay

							  call Clrscr

							  jmp Menu									; jump back to Menu label to give the user another change to give valid input

				  SieveStart: call sieveOfEratosthenes					; Option 1: Run Sieve of Eratosthenes
							  jmp Menu									; -> Once finished, print the menu again by jumping to Menu label

				  DivisorStart: call Divisors							; Option 2: Calculate the Divisors and Prime Divistors of a Number
								jmp Menu								; -> Once finished, print the menu again by jumping to Menu label

				  Quit: 												; Option 3: Quit
	exit																; -> exit is encountered before main ENDP to properly end the program
    main ENDP
	
	menuPrint PROC
	;**********************************************************************************
	;Description - displays a menu that promps the user to select one of three options
	;Recieves - nothing
	;Returns - user input stored eax
	;**********************************************************************************
		.data
			selection    BYTE "Selection: ", 0							; needed to prompt the user to enter a selection based on menu presented
														
			menuHeader1  BYTE "    _________                                                              _________   ", 0 ; stylish menu of 
						 BYTE "   (_,.....,_)                                                            (_,.....,_)  ", 0 ; Roman columns
						 BYTE "     |||||||          ________ _        __     ___    _    ___    _         |||||||    ", 0
						 BYTE "     |||||||         |        | \       ) |    \  |  | |  |   |  |          |||||||    ", 0 ; since Eratosthenes was
						 BYTE "     |||||||         |  |\/|  |  |  (__   |  |\ \ |  | |  |   |  |          |||||||    ", 0 ; alive in the days of the
						 BYTE "     |||||||         |  |  |  |  |     )  |  | \ \|  | |  |   |  |          |||||||    ", 0 ; pre-Julian Roman era, the
						 BYTE "     |||||||         |  |  |  |  |  (___  |  |  \    | |   \_/   |          |||||||    ", 0 ; theme of the program is 
						 BYTE "     |||||||         |  |__|  |_/       )_|  |___\   |__\       /__         |||||||    ", 0 ; around 300 BC
						 BYTE "     |||||||                                                                |||||||    ", 0
						 BYTE "     |||||||     1) Run the Sieve of Eratosthenes                           |||||||    ", 0
						 BYTE "    ,_______,                                                              ,_______,   ", 0
						 BYTE "      )   (      2) Calculate the Divisors and Prime Divisors of a Number    )   (     ", 0
						 BYTE "    ,      `                                                               ,      `    ", 0
						 BYTE "  _/_________\_  3) Quit                                                 _/_________\_ ", 0
						 BYTE " |_____________|                                                        |_____________|", 0
			
			
		.code
			mov eax, white												; set console output to white
			call setTextColor
			
			mov ecx, 5													; print 5 line breaks
			Crlf1: call Crlf
			loop Crlf1
			
			mov ecx, 15											
			mov bl, 0													; [Algorithm #1]: Efficient multi-ASCII-character-array console output
			MenuHeader: push ecx										; -> the following algorithm is used to print the large menu design:
							mov ecx, 15									; -> 1. set ecx to the number of arrays containing the design, set bl to be 0
							Spce: mov al, ' '							; -> 2. inside a loop, move the memory address of the first element of the
								  call WriteChar						; ->    first array of the design into edx
							loop Spce									; -> 3. move the length of the first array into al. Each array MUST be the same
						pop ecx											; ->    size for this to work
						mov edx, OFFSET menuHeader1						; -> 4. multiply ax (ah=0) by b1 (array number, starting from zero) to obtain
						mov eax, 0										; ->    the distance from the first array element to print an array. Add to edx
						mov al, LENGTHOF menuHeader1					; ->    to obtain the correct memory address of the print location
						mul bl											; -> 5. call Irvine32 procedure WriteString to print to console
						add edx, eax
						call WriteString
						call Crlf
						inc bl
			loop MenuHeader
			
			mov ecx, 50													; center next character-array on console window by printing 50 spaces
			Spce8: mov al, ' '
				   call WriteChar
			loop Spce8
			
																		; Prompt: "Selection:""
			mov edx, OFFSET selection
			call WriteString
	ret		
	menuPrint ENDP

	sieveOfEratosthenes PROC
	;*****************************************************************************************
	;Description - implements the Sieve of Eratosthenes algorithm that finds all the prime 
	;			   numbers between 2 and 100. Prints these numbers to the console window
	;Recieves - user input stored in eax
	;Returns - binary array of true/false prime number locations in edi
	;*****************************************************************************************
		.data
			n = 100														; constant defining n, the upper limit of numbers to check as prime
			i 			  BYTE 2										; memory variable that will hold i [2-100], the prime to test
			j 			  WORD 0										; memory variable that will hold j, the location in the binary array	
																		; -> that will represent composite numbers when decremented by 1
			primesPrompt  BYTE "The primes up to 100 are: ", 0			; ASCII character array that is need to identify location of found primes
																		; -> on terminal window
			arr           BYTE n DUP(0)									; array of binary digits where decremented index represents prime (0) or 
																		; -> composite (1) number. This represents int arr[n] == {0}
			beenRun       BYTE 0										; memory variable used to more efficiently guide the program to use use this 
																		; -> procedure's result
			bypassWaitMsg BYTE 0										; memory variable that makes it so output from this procedure is not printed
																		; -> when it is not explicitly called by the user

		.code
			cmp eax, 1													; Logic used to more effiencently use the result of this procedure throughout
				je clr_bypassWaitMsg									; -> the rest of the program:
			cmp beenRun, 1												; ->->  ~if user explicitly called this procedure (eax = 1) ALWAYS run with
				je Bypass												; ->->-> 	bypassWaitMsg set at 0
			cmp eax, 2													; ->->  ~if user did not explicitly call this procedure, but the procedure
				je set_bypassWaitMsg									; ->->-> 	they called requires arr to be filled, set bypassWaitMsg to
																		; ->->->    1 to prevent this procedure from printing to console while still
			clr_bypassWaitMsg: mov bypassWaitMsg, 0						; ->->->    having been run. If beenRun = 1, arr is already filled so this
																		; ->->->    procedure will not run at all
			SieveBegin: call printSieveTitle							; call printSieveTitle to print a stylish console window introducing the procedure
			            mov edx, OFFSET primesPrompt
						call WriteString

						mov eax, yellow									; set console output to yellow
						call setTextColor
					
			SieveBegin2:mov edi, OFFSET arr								; mov the memory location of the first element of arr to edi
						
						For_L1: 										; For_L1 label representing for (int i = 2; i < n; i++)
								cmp i, n								; check condition for loop repeat: i < n
									jnl Check_Prime						
								
								mov ax, 0								
								
								mov al, i								; set condition j = i * i anticipating For_L2
								mul i
								mov j, ax
								For_L2: 								; For_L2 label representing for(int j = i*i; j <= n; j+=i)
										cmp j, n						; -> "j <= n" used instead of "j < n" provided by Ms. Yoha to make prime
											jnle End_For_L1				; ->-> identification exclusive up to 100. Whether prime check should have been
										      						    ; ->-> inclusive or exclusive up to 100 was not specified to matter
										mov eax, 0
										mov ax, j
										mov ecx, 1
										mov esi, edi
										
										add esi, eax					; add current value of j to esi to obtain correct offset location
										dec esi							; decrement esi (arr[j - 1]) to obtain correct location to insert a 1
										mov[esi], cl					; arr[j - 1] = 1
																		
										mov bh, 0						
										mov ah, 0
										
										mov al, i						; perform postcondition for For_L2 loop representing j+=i
										mov bx, ax
										add j, bx
								jmp For_L2
						End_For_L1: inc i								; perform postcondition for For_L1 loop representing i++
									jmp For_L1
						
						printPrime: 									; if arr[i - 1] == 0, print i to screen. i will be prime.
									mov eax, 0
									mov al, i
									cmp al, n							; do not print to screen if i has exceeded n
										jg End_Sieve
										
									call WriteDec
									mov al, ','
									call WriteChar
									mov al, ' '
									call WriteChar
									
									inc i								; perform postcondition for For_L1 loop representing i++
									jmp L3
						jmp For_L1

						Check_Prime: 									; check if arr[i] == 0
									 mov i, 2
									 L3: mov esi, edi
										 mov ebx, 0
										 
										 mov bl, i
										 dec bl							; given the provided algorithm, a[i - 1] is prime. i itself will be a prime 
										 add esi, ebx					; -> number at a[i - 1]
										 mov al, [esi] 
										 
										 cmp al, 0
											 je printPrime
											 
										inc i							; perform postcondition for For_L1 loop representing i++
									 jmp L3

			End_Sieve: mov al, 08										; ASCII control character for backspace
					   call WriteChar
					   call WriteChar
					   mov al, 00										; ASCII control character for null character. Use this overwrite the last comma printed
					   call WriteChar	
						
					   mov eax, lightGray								; set console output to yellow						
					   call SetTextColor
					   
					   call Crlf
					   call Crlf
					   
					   mov ecx, 40										; center prompt produced by Irvine32 function WaitMsg to center by
					   Spce: mov al, ' '								; -> printing 40 spaces
				             call WriteChar
					   loop Spce
					   
					   mov edi, OFFSET arr								; be sure edi contains the approriate offset of arr before returning it
					   
					   mov beenRun, 1									; beenRun can now be set to 1 since this procedure has run at least once up 
																		; -> to this point
					   cmp bypassWaitMsg, 1								; if bypassWaitMsg was set from preconditions defined above, skip the call
							je skipWaitMsg								; -> to WaitMsg
							
					   call WaitMsg
					   
					   skipWaitMsg: call Clrscr
									jmp exitProc
					   
			Bypass:	cmp eax, 1											; if eax = 1 was true before the Sieve of Eratosthenes algorithm excecuted,
						je SieveBegin									; -> jump back up to the start of the algorithm to run like normal
						
			set_bypassWaitMsg: cmp beenRun, 1							; eax = 2 must have been true at the beginning of this procedure to jump to 
									je exitProc							; -> this label. In that case, if beenRun is already set, do not run 
																		; -> the procedure
							   
							   mov bypassWaitMsg, 1						; if eax = 2 was passed to this procedure by beenRun was not set, run the 
							   jmp SieveBegin2							; -> procedure without displaying its output to the console window
							   
	exitProc: ret
	sieveOfEratosthenes ENDP
	
	printSieveTitle PROC
		.data
			welcome1   BYTE "                                                                                                      .---.  ", 0
					   BYTE "                                                                                                     /  .  \ ", 0
					   BYTE "                                                                                                    |\_/|   |", 0
					   BYTE "                                                                                                    |   |  /|", 0
					   BYTE "  .-------------------------------------------------------------------------------------------------------' |", 0
					   BYTE " /  .-.                                                                                                     |", 0
					   BYTE "|  /   \                                 _     ___                             _                            |", 0
					   BYTE "| |\_.  |     ()                        | |   / (_)                           | |                           |", 0
					   BYTE "|\|  | /|     /\ .   _        _     __  | |   \__   ,_    __, _|_  __   , _|_ | |     _   _  _    _   ,     |", 0
					   BYTE "| `---' |    /  \|  |/  |  |_|/    /  \_|/    /    /  |  /  |  |  /  \_/ \_|  |/ \   |/  / |/ |  |/  / \_   |", 0
					   BYTE "|       |   /(__/|_/|__/ \/  |__/  \__/ |__/  \___/   |_/\_/|_/|_/\__/  \/ |_/|   |_/|__/  |  |_/|__/ \/    |", 0
					   BYTE "|       |                               |\                                                                  |", 0
					   BYTE "|       |                               |/                                                                 / ", 0
					   BYTE "|       |-------------------------------------------------------------------------------------------------'  ", 0   
					   BYTE " \     /                                                                                                     ", 0      
					   BYTE "  `---'                                                                                                      ", 0    
			algorithm1 BYTE "      Algorithm used:             ", 0		; [Algorithm #2]: Ms. Yoha's algorithm, but modified slightly.
					   BYTE "for (int i = 0; i < n; i++)       ", 0
					   BYTE "   for (int j = i*i; j <= n; j+=i)", 0 	; j <= n was added to make prime identification exclusive up to 100
					   BYTE "       arr[j - 1] = 1;            ", 0
					   BYTE 'cout << arr[i - 1] << ", ";       ', 0		; location at arr[i - 1] turns out to be 0, whether j <= n or j <n is used
                       
		.code
			call Clrscr
			
			mov eax, yellow												; set console output to yellow	
			call SetTextColor
			
			mov ecx, 16
			mov bl, 0
			Welcome: push ecx											; [Algorithm #1]: print many lines using a loop as defined before
						 mov ecx, 6										; indent printed stylish title by 6 spaces
						 Spce: mov al, ' '
							   call WriteChar
						 loop Spce
					 pop ecx
					 
					 mov edx, OFFSET welcome1				
					 mov eax, 0
					 mov al, LENGTHOF welcome1
					 mul bl
					 
					 add edx, eax
					 call WriteString
					 call Crlf
					 inc bl
			loop Welcome
			
			mov eax, cyan												; set console output to cyan
			call SetTextColor
			
			mov ecx, 5
			mov bl, 0
			Algorithm: push ecx											; [Algorithm #1] is used to print the algorithm used to find prime numbers
						 mov ecx, 40
						 Spce2: mov al, ' '
							    call WriteChar
						 loop Spce2
					   pop ecx
					   
					   mov edx, OFFSET algorithm1
					   mov eax, 0
					   mov al, LENGTHOF algorithm1
					   mul bl
					   
					   add edx, eax
					   call WriteString
					   call Crlf
					   inc bl
			loop Algorithm
			
			call Crlf
		
			mov eax, lightGray											; set console output to lightGrey [default]	
			call SetTextColor
			
			call Crlf
			call Crlf
	
	ret
	printSieveTitle ENDP
	
	Divisors PROC
		.data 
			userNum         BYTE ?										; memory variable that stores value of n that user entered
			count			BYTE ?										; memory variable is used to keep track of iterations checking for divisors
			pDivisorCount   BYTE 0										; memory variable used to keep track of how many prime divisors where found
			PrimeDivisors   BYTE 100 DUP(0)								; array that stores found prime divisors for later printing in new column
			
			enterNumPrompt1 BYTE "Enter a number n such that n is less than or equal to 100: ", 0
			enterNumPrompt2 BYTE "n = ", 0
			badInputDiv     BYTE "Number must be no greater than |100|. Please try again.", 0
			zeroInputDiv	BYTE "Too large to display: 0 has infinitely many divisors", 0
			oneInputDiv		BYTE "1 can only be divided by itself. Therefore, its only Divisor is 1, with no Prime Divisors", 0
			outputHeader1   BYTE "n", 0
			outputHeader2   BYTE "Divisors", 0
			outputHeader3	BYTE "Prime Divisors", 0
			outputHeader4   BYTE "====================================================================", 0
		
		.code
			call Clrscr
			call sieveOfEratosthenes
			
			mov eax, white												; set console output to white
			call SetTextColor
			
			getUserNum: mov edx, OFFSET enterNumPrompt1					; Prompt: "Enter a number n such that n is less than or equal to 100: "
						call WriteString
			
						call Crlf
						call Crlf
			
						mov edx, OFFSET enterNumPrompt2					; Prompt: "n = "
						call WriteString
			
						call ReadInt									; retrieve user input and store in eax
						checkNum: jo badNum								; if user has entered a number greater than 32-bits go to badNum label
								  cmp eax, 100
									jg badNum							; if user has entered a number greater than 100, go to badNum label
								  cmp eax, 1
									je exceptions						; if user has entered 1, jump to exceptions label
								  cmp eax, 0
									je exceptions						; if user has entered 0, jump to exceptions label
								  jl take_absolute					    ; if user has entered a number less than 0, still find the primes of the 
																		; -> absolute value of that number
								  doneChecking: mov userNum, al		    ; after error checking, move validated number into userNum
											    jmp printHeaders
						
			badNum: call Crlf											; code under this label performs the error checking of user input

					mov eax, 12											; set console output to lightRed
					call SetTextColor

					mov ecx, 25											; center next prompt by printing 35 spaces
					Spce: mov al, ' '
						  call WriteChar
					loop Spce
											
					mov edx, OFFSET badInputDiv							; Prompt: "Invalid selection. Please try again..."
					call WriteString
					
					mov ecx, 2											; stylish ellipsis animation
					dotAnimation: mov eax, 300							; -> eax recieves value in milliseconds to pause the program
								  call Delay							; ->-> Irvine32 procedure Delay is used to produce ellipsis animation
								  mov al, '.'
								  call WriteChar
					loop dotAnimation

					mov eax, 300
					call Delay

					mov eax, white										; set console output to lightRed
					call SetTextColor

					call Clrscr
					
					jo clearOF											; clear OF if there was overflow so user can try again
					clearOF: mov cl, 1
							 neg cl
					
					jmp getUserNum	

			exceptions: call Crlf
						push eax
							mov eax, yellow								; set console output to yellow
							call SetTextColor
						pop eax
						
						cmp eax, 0
							je zeroInput
						cmp eax, 1
							je oneInput
						
						zeroInput: mov ecx, 35							; center next prompt by printing 50 spaces
								   Spce0: mov al, ' '
								          call WriteChar
								   loop Spce0
								   
								   mov edx, OFFSET zeroInputDiv			; Prompt: "Too large to display: 0 has infinitely many divisors""
								   call WriteString
								   jmp done_printing
								   
						oneInput: mov ecx, 15							; center next prompt by printing 50 spaces
								  Spce8: mov al, ' '
								         call WriteChar
								  loop Spce8
								  
								  mov edx, OFFSET oneInputDiv			; Prompt:  "1 can only be divided by itself. Therefore, its only Divisor is 1,
								  call WriteString						; ->  with no Prime Divisors""
								  jmp done_printing
						
						
						done_printing: mov eax, white					; set console output to white
									   call SetTextColor
					
						jmp exitFindDivisors
						
			take_absolute: neg eax										; if number was negative, take absolute value and recheck number
						   jmp checkNum
			
			printHeaders: call Crlf
						  call Crlf
			
						  mov edx, OFFSET outputHeader1					; Prompt: "n"
						  call WriteString
						  mov ecx, 5 
						  Spce1: mov al, ' '
							   call WriteChar 
						  loop Spce1
						
						  mov edx, OFFSET outputHeader2					; Prompt: "Divisors"
						  call WriteString
						  mov ecx, 35
						  Spce2: mov al, ' '
						  	     call WriteChar 
						  loop Spce2
						
						  mov edx, OFFSET outputHeader3					; Prompt: "Prime Divisors"
						  call WriteString
						  call Crlf
						
						  mov edx, OFFSET outputHeader4					; Prompt: "================================================================="
						  call WriteString
						  call Crlf
			
			mov dh, 7													; set dh to 7 to represent cursor position at row 7 for Gotoxy
			mov count, 2												; set count to 2, as divisors under 2 won't be checked
			mov pDivisorCount, 0										; set pDivisorCount to 0, as initially no primes wiill be found
			jmp FindDivisors
			
			adjust_ecx1: mov ecx, 3										; aligns columns if 100 is the userNum
						 jmp Spce3
			adjust_ecx2: mov ecx, 5										; aligns columns if userNum is under 10
						 jmp Spce3
						
			FindDivisors: mov eax, white								; set console output to white
						  call SetTextColor
						  
						  mov eax, 0
						  
						  mov al, userNum	 
						  call WriteDec     						    ; print current n value
						  
						  cmp userNum, 100								; align columns appropriatly
							je adjust_ecx1
						  cmp userNum, 10
							jl adjust_ecx2
								
						  mov ecx, 4	 								; print three spaces to get in position for Divisors column output
						  Spce3: mov al, ' '
								 call WriteChar 
						  loop Spce3
						  
						  mov eax, lightGreen							; set console output to lightGreen
						  call SetTextColor
						  
						  mov esi, OFFSET PrimeDivisors
						  DivisorLoop: mov eax, 0
									   mov al, userNum
									   div count						; divide n by count (starting at 2 and ending at n). If no remainder, ah = 0
									   
									   cmp ah, 0
									       jne endDivisorLoop			; if n mod count != 0, count does not divide n
										   
									   mov al, count
									   call WriteDec					; print count since it divides n
									   
									   cmp al, userNum
											je getPrimeDivisor			; skips last comma
									
									   mov al, ','						; write comman, anticipating next divisor
									   call WriteChar
									   mov al, ' '
									   call WriteChar	
									   
									   getPrimeDivisor: mov eax, 0
														mov al, count
														
														push edi
															add edi, eax	; check if count is a prime divisor by checking the count'th position of arr
															dec edi
															mov dl, [edi]
														pop edi
														
														cmp dl, 0			; if arr[count - 1] == 0, count is a prime divisor
															je savePrimeDivisors
															
									   endDivisorLoop:  mov eax, 0
														mov al, count
														
														cmp al, userNum		; if userNum is the same as count, print the prime divisors that were saved
														   je printPrimeDivisors
														   
													   inc count
						  jmp DivisorLoop
						  savePrimeDivisors: mov eax, 0						; save the prime divisor for later printing
											 mov al, count
											 mov [esi], al					
											 inc esi
											 inc pDivisorCount
											 jmp endDivisorLoop
											 
						  printPrimeDivisors: mov eax, yellow				; set console output to yellow
											  call SetTextColor
											  
											  mov esi, OFFSET PrimeDivisors
											  mov cl, pDivisorCount
											  mov dl, 49					; set dl to 49 to align prime divisors column evenly using Gotoxy
											  print: call Gotoxy
											  
													 mov al, [esi]
													 call WriteDec
													 
													 mov al, ','
													 call WriteChar
										             mov al, ' '
										             call WriteChar
													 
													 inc esi
													 add dl, 3				; needed to account for printed number, comma, and space
											  loop print
											  
											  mov al, 08					; remove comma after last number using ASCII control characters
											  call WriteChar
											  call WriteChar
					                          mov al, 00		
											  call WriteChar
											  
						  cmp userNum, 2
							je exitFindDivisors
							
						  dec userNum
						  mov count, 2
						  mov pDivisorCount, 0
						  inc dh
						  
						  call Crlf
						  
						  jmp FindDivisors
						  
			exitFindDivisors: call Crlf
						      call Crlf
							  
							  mov eax, white								; set console output to yellow
							  call SetTextColor
							  
							  call WaitMsg
							  call Clrscr
		ret
		Divisors ENDP
											  
											  
END main