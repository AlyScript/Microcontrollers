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

_write
	; /// Step 1 \\\
	lw t0, CONTROL					; read what is in the control already
	li t1, 0b1011 					; to set RS to 0
	li t2, 0b1000					; to set R/W to 1 
	and t0, t1, t0					; set RS  to 0
	or t0, t2, t0					; set R/W to 1
        sw CONTROL t0, t3				; write back to control with correct bits set 



; Data Bus is 8 bits

; 		 Control
; --------------------
; LCD R/W      : Bit 0
; LCD RS       : Bit 1
; LCD E        : Bit 2
; LCD Backlight: Bit 3
	
