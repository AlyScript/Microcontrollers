ORG 0

lights

; S0
LI t0, 0b0001_0001
SB t0, addr, t1
LI t2, 10_000_000
CALL delay

; S1 
LI t0, 0b0001_0011
SB t0, addr, t1
LI t2, 10_000_000
CALL delay

; S2
LI t0, 0b0001_0100
SB t0, addr, t1
LI t2, 30_000_000
CALL delay

; S3
LI t0, 0b0001_0010
SB t0, addr, t1
LI t2, 10_000_000
CALL delay

; S4
LI t0, 0b0001_0001
SB t0, addr, t1
LI t2, 10_000_000
CALL delay

; S5
LI t0, 0b0011_0001
SB t0, addr, t1
LI t2, 10_000_000
CALL delay

; S6
LI t0, 0b0100_0001
SB t0, addr, t1
LI t2, 10_000_000
CALL delay

; S7
LI t0, 0b0010_0001
SB t0, addr, t1
LI t2, 10_000_000
CALL delay

JAL lights

; we use t2 as our counter for the delay
; an empty loop will iterate in 2 + 2 = 4 cycles (100 ns)
; therefore, for a 1s delay, we need 40_000_000 / 4 = 10_000_000 iterations
delay
	addi t2, t2, -1
	bnez t2, delay		
	ret

addr equ 0x00010000
