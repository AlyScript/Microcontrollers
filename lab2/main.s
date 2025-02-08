ORG 0

DATA_BUS EQU 0x0001_0100
CONTROL  EQU 0x0001_0101

; Write a character to the screen
; Params:
;		s0: Character to be written
;		s1: Data Bus
;		s2: Control Address 
;		s3: 
 
lbu s1, DATA_BUS
lbu s2, CONTROL

puts
	; /// Step 1 \\\

	lw t0, CONTROL					; read what is in the control already
	li t1, 0b1101					; to set RS to 0 (this might be the wrong way round, I am using Big endian)
	li t2, 0b0100					; to set R/W to 1 an(also might be the wrong way round)
	and t0, t1, t0					; set RS  to 0 
	or t0, t2, t0					; set R/W to 1
	sw CONTROL t0, t4				; write back to control with correct bits set (t3 must be clear!)

loop
	; /// Step 2 \\\

	lw t0, CONTROL					; read what is in the control already
	li t3, 0b0010					; to set E to 1
	or t0, t3, t0					; set E to 1
	sw CONTROL t0, t4				; write back to control with correct bits set (t3 must be clear!)

	; /// Step 2a \\\

	li t7, 5                        ; t7 == 1 means a 100 ns delay so t7 == 5 means 500 ns delay which is the min delay for the Enable pulse	
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
	and t1, t2, t1
	sw CONTROL t1, t4				; write back to control with correct bits set (t4 must be clear!)
	
	; /// Step 5 \\\
	; for a 1200 ns delay, we need 12 iterations of the delay loop
	li t7, 12
	call delay

	; /// Step 6 \\\

	; If bit 7 of Status byte was high repeat from Step 2
	bnez t5, loop

	jal write

; /// Step 7 \\\
; Carry out the write
write
	lw t0 CONTROL
	li t1, 0b1110				; to set R/W to 0
	li t2, 0b0010               ; to set RS to 1

	and t1, t0, t1				; for RW
	or t1, t1, t2				; for RS
	sw CONTROL t1, t4			; write back to control with correct bits set (t4 must be clear!)

	; /// Step 8 \\\
	; Now to output the data to the data bus
	sb s0, DATA_BUS, t4

	; /// Step 9 \\\
	; Enable the bus
	lw t0, CONTROL
	li t1, 0b0100
 	or t1, t0, t1
	sw CONTROL t1, t4

	; /// Step 9a \\\
	; Delay for 500 ns
	li t7, 5
	call delay		

	; /// Step 10 \\\
	; Disable the bus
	lw t0, CONTROL
	li t1, 0b1011
	and t1, t0, t1
	sw CONTROL t1, t4

; we use t7 as our counter for the delay
; an empty loop will iterate in 2 + 2 = 4 cycles (100 ns)
; therefore, for a 1s delay, we need 40_000_000 / 4 = 10_000_000 iterations

delay
	addi t7, t7, -1
	bnez t7, delay
	ret

; --------------------
;       SIGNALS
; --------------------
; | Data Bus = 8bits |
; --------------------
; |		 Control     |
; --------------------
; LCD R/W      : Bit 0
; LCD RS       : Bit 1
; LCD E        : Bit 2
; LCD Backlight: Bit 3
