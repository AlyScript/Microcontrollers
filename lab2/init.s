ORG 0

INCLUDE trap.s
INCLUDE puts.s

; ------------ Machine Mode Initialisation -----------------

init
    ; Set the stack pointer
    la sp, MSTACK
    csrw mscratch, sp

    ; Set the trap vector
    la t0, TRAP_VECTOR
    csrw mtvec, t0

    ; Clear MPP to set U-Mode
    li t0, MPP_BITMASK
    csrc mstatus, t0

    li t0, 0x00040000
    csrw mepc, t0

    mret

; Machine Stack
MSTACK_END DEFS 100 				; Reserve 100 bytes for the stack and point to the end (this is a stack `size` of 25, since each `item` is a word...)
MSTACK

TRAP_VECTOR EQU 0x00000200

; Use CSRC to clear MPP (i.e. for U-Mode)
; Use CSRS to set MPP (i.e. for M-Mode)
MPP_BITMASK   EQU 0x00001800