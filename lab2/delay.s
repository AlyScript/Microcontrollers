;-----------------------------------------------------
; delay - Software delay loop
; Arguments:
;   a0: Number of iterations for the delay
;-----------------------------------------------------
delay
	addi sp, sp, -4
	sw ra, [sp]

delay_loop
	addi a0, a0, -1
	bnez a0, delay_loop

	lw ra, [sp]
	addi sp, sp, 4
	ret