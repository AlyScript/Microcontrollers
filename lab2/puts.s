ORG 0

start


	la sp, STACK
	la s2, STR              ; s2 is a pointer to the string
	

print_loop

	lb s0, [s2]        ; load the character to be printed into s0
	beqz s0, done           ; if the character is null, we are done
	addi s2, s2, 1      ; increment string pointer
	
	call puts           ; print the character
	j print_loop        


; Write a character to the screen
; Params:
;		s0: Character to be written

puts
	; /// Step 1 \\\

	addi sp, sp, -4
	sw ra, [sp]

	lw t0, CONTROL					; read what is in the control already
	li t1, 0b1101					; to set RS to 0 (this might be the wrong way round, I am using little endian)
	li t2, 0b0001 					; to set R/W to 1 (also might be the wrong way round)
	and t0, t1, t0					; set RS  to 0 
	or t0, t2, t0					; set R/W to 1
	li t4, 0
	sw t0, CONTROL, t4				; write back to control with correct bits set (t3 must be clear!)

loop
	; /// Step 2 \\\

	lw t0, CONTROL					; read what is in the control already
	li t3, 0b1100					; to set E to 1 (and turn backlight on)
	or t0, t3, t0					; set E to 1
	li t4, 0
	sw t0, CONTROL, t4				; write back to control with correct bits set (t4 must be clear!)

	; /// Step 2a \\\

	li t6, 10                        ; t6 == 1 means a 100 ns delay so t6 == 5 means 500 ns delay which is the min delay for the Enable pulse	
	call delay						
	
	; /// Step 3 \\\

	; Read LCD Status Byte (Busy Flag) -- this is bit 7 of the data bus
	; We put the value of this into t5

	lw t0, DATA_BUS
	li t5, 0b1000_0000				
	and t5, t0, t5

	; /// Step 4 \\\

	; disable bit 2 of control
	lw t0, CONTROL
	li t2, 0b1011					; to set E to 0
	and t0, t2, t0
	li t4, 0
	sw t0, CONTROL, t4				; write back to control with correct bits set (t4 must be clear!)
	
	; /// Step 5 \\\
	; for a 1200 ns delay, we need 12 iterations of the delay loop
	li t6, 30
	call delay

	; /// Step 6 \\\

	; If bit 7 of Status byte was high repeat from Step 2
	bnez t5, loop


	; /// Step 7 \\\
	; Carry out the write
	lw t0, CONTROL
	li t1, 0b1110				; to set R/W to 0	
	li t2, 0b0010               ; to set RS to 1 

	and t0, t0, t1				; for RW
	or t0, t0, t2				; for RS
	li t4, 0
	sw t0, CONTROL, t4			; write back to control with correct bits set (t4 must be clear!)

	; /// Step 8 \\\
	; Now to output the data (character) to the data bus
	li t4, 0
	sw s0, DATA_BUS, t4

	; /// Step 9 \\\
	; Enable the bus
	lw t0, CONTROL
	li t1, 0b0100 
 	or t0, t0, t1
	li t4, 0
	sw t0, CONTROL, t4

	; /// Step 9a \\\
	; Delay for 500 ns
	li t6, 10
	call delay		

	; /// Step 10 \\\
	; Disable the bus by setting E to 0
	lw t0, CONTROL
	li t1, 0b1011 
	and t0, t0, t1
	li t4, 0
	sw t0, CONTROL, t4

	lw ra, [sp]
	addi sp, sp, 4
	ret

; we use t6 as our counter for the delay
; an empty loop will iterate in 2 + 2 = 4 cycles (100 ns)
; therefore, for a 1s delay, we need 40_000_000 / 4 = 10_000_000 iterations

delay

	addi sp, sp, -4
	sw ra, [sp]
delay_loop
	addi t6, t6, -1
	bnez t6, delay_loop

	lw ra, [sp]
	addi sp, sp, 4

	ret

done
    jal done

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

STR DEFB "Hello World!\0"
ALIGN
DATA_BUS DEFW 0x0001_0100	
CONTROL  DEFW 0x0001_0101	
;ALIGN							; Align the stack to 4 bytes (this is probably not necessary since we are already aligned?)
STACK_END DEFS 100 				; Reserve 100 bytes for the stack and point to the end (this is a stack `size` of 25, since each `item` is a word...)
STACK