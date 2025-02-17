;-----------------------------------------------------
; puts - write a character to the screen
; A. Aly
; Version 1.0
; 15th February 2024
;
; The `puts` utility function writes a character to the HD44780 LCD display.
;
;
; Last modified: XXX (AA)
;
; Known bugs: None
;
;-----------------------------------------------------

ORG 0

j start

clear_screen
	; Push return address and s1
	subi sp, sp, 8
	sw ra, 4[sp]
	sw s1, [sp]

	; Write the clear byte to the screen
	lb s1, CLEAR
	sb s1, [s3]
	;call puts

	; Pop return address and s1
	lw ra, 4[sp]
	lw s1, [sp]
	addi sp, sp, 8

	ret

start
	la sp, STACK
	la s1, STR              ; s1 is a pointer to the string
	la s2, CONTROL
	la s3, DATA_BUS
	call clear_screen
	;call print_string       ; call the print_string function

; Print a string.
; Params:
;		s1: Pointer to the string to be printed
print_string

	lb s0, [s1]         ; load the character to be printed into s0
	beqz s0, done       ; if the character is null, we are done
	addi s1, s1, 1      ; increment string pointer
	
	call puts           ; print the character
	j print_string    	; loop back to print the next character    


; Write a character to the screen
; Params:
;		s0: Character to be written

puts
	; /// Step 1 \\\

	addi sp, sp, -4
	sw ra, [sp]

	lbu t0, CONTROL					    ; read what is in the control already
	andi t0, t0, rs_off					; clear RS bit
	ori t0, t0, rw_on					; set RW bit
	sb t0, [s2]				            ; write back to control with correct bits set

loop
	; /// Step 2 \\\

	lbu t0, CONTROL					; read what is in the control already
	ori t0, t0, enable_on			; set E bit
	sb t0, [s2]						; write back to control with correct bits set

	; /// Step 2a \\\

	li a0, 10                        ; a0 == 1 means a 100 ns delay so a0 == 5 means 500 ns delay which is the min delay for the Enable pulse	
	call delay						
	
	; /// Step 3 \\\

	; Read LCD Status Byte (Busy Flag) -- this is bit 7 of the data bus
	; We put the value of this into t5

	lbu t0, DATA_BUS
	andi t5, t0, busy				; t5 = t0 & 0b1000_0000

	; /// Step 4 \\\

	; disable bit 2 of control
	lbu t0, CONTROL				; read what is in the control already
	andi t0, t0, enable_off		; clear E bit
	sb t0, [s2]			; write back to control with correct bits set
	
	; /// Step 5 \\\
	; for a 1200 ns delay, we need 12 iterations of the delay loop
	li a0, 14
	call delay

	; /// Step 6 \\\

	; If bit 7 of Status byte was high repeat from Step 2
	bnez t5, loop


	; /// Step 7 \\\
	; Carry out the write
	lbu t0, CONTROL
	andi t0, t0, rw_off
	ori t0, t0, rs_on
	sb t0, [s2]		; write back to control with correct bits set (t4 must be clear!)

	; /// Step 8 \\\
	; Now to output the data (character) to the data bus
	sb s0, [s3]

	; /// Step 9 \\\
	; Enable the bus
	lbu t0, CONTROL
	ori t0, t0, enable_on
	sb t0, [s2]

	; /// Step 9a \\\
	; Delay for 500 ns
	li a0, 10
	call delay		

	; /// Step 10 \\\
	; Disable the bus by setting E to 0
	lbu t0, CONTROL
	andi t0, t0, enable_off
	sb t0, [s2]						; write back to control with correct bits set

	lw ra, [sp]								; restore ra
	addi sp, sp, 4							; by popping from the stack		
	ret

done
    jal done

; -------------------------------------------------------------------------------
; we use a0 as our counter for the delay									 	
; an empty loop will iterate in 2 + 2 = 4 cycles (100 ns)						
; therefore, for a 1s delay, we need 40_000_000 / 4 = 10_000_000 iterations	    	
																				
delay																			
																				
	addi sp, sp, -4																
	sw ra, [sp]															        
																				
delay_loop																	    
	addi a0, a0, -1															    
	bnez a0, delay_loop															
																				
	lw ra, [sp]																	
	addi sp, sp, 4															    
																				
	ret																		    
; -------------------------------------------------------------------------------

; --------------------
;       SIGNALS
; --------------------
; | Data Bus = 8bits |
; --------------------
; |		 Control     |
; --------------------
; LCD R/W       : Bit 0
; LCD RS        : Bit 1
; LCD E         : Bit 2
; LCD Backlight : Bit 3

; Defining some constants for the control register. We always use AND to turn off bits and OR to turn on bits!
enable_on  EQU 0b0100
enable_off EQU 0b1011
rs_on      EQU 0b0010
rs_off     EQU 0b1101
rw_on      EQU 0b0001
rw_off     EQU 0b1110

; Defining LCD Status byte
busy EQU 0b1000_0000

STR DEFB "Hello World!\0"
ALIGN
CLEAR DEFB 0x01, 0 				; Clear screen
ALIGN

DATA_BUS EQU 0x0001_0100	
CONTROL  EQU 0x0001_0101	

STACK_END DEFS 100 				; Reserve 100 bytes for the stack and point to the end (this is a stack `size` of 25, since each `item` is a word...)
STACK