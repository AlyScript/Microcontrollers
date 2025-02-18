ORG 0


; ------------ Machine Mode Initialisation -----------------

init
    ; Clear MPP to set U-Mode
    li t0, MPP_BITMASK
    csrc MSTATUS, t0
    
    ; Set the trap vector
    la t0, MHANDLER
    csrw MTVEC, t0
    
    ; Copy `machine` SP for use in handler
    csrw MSCRATCH, sp

    ; Change SP to user stack
    ; ---- Where do we get the location of the user stack though? ----
    ; This won`t work because we define stack in main.s
    ; Should we define it here?
    ; Can`t this just be omitted as we are jumping to main.s anyway?
    ;la sp, STACK

    ; Set MEPC to the start of our user program
    la ra, MAIN_START
    csrw MEPC, ra

    mret

; Machine Stack
MSTACK_END DEFS 100 				; Reserve 100 bytes for the stack and point to the end (this is a stack `size` of 25, since each `item` is a word...)
MSTACK

MHANDLER EQU 0x0000_0200

; Use CSRC to clear MPP (i.e. for U-Mode)
; Use CSRS to set MPP (i.e. for M-Mode)
MPP_BITMASK   EQU 0x0000_1800

; Main program start address
MAIN_START EQU 0x0004_0000