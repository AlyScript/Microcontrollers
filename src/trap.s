ORG 0x00000200

INCLUDE puts.s

    csrrw sp, mscratch, sp               ; Save User SP, set Machine SP
    ;subi sp, sp, 12                     ; Push working registers
    ;sw, 

    csrr t0, mcause                      ; Get the cause of the trap
    andi t0, t0, 0xF                     ; Mask to make sure that we are in range
    la t1, trap_table                    ; Point to trap table
    slli t0, t0, 2                       ; Multiply by 4 to get the correct offset
    add t1, t0, t1                       ; Add the offset to the table
    lw t0, [t1]                          ; Load the address of the handler
    jalr t0                              ; Call the handler we need
    
    csrrw t0, MEPC, t0                   ; Find the trapping instruction
    addi t0, t0, 4                       ; Correct to a return address
    csrrw t0, MEPC, t0                   ; Swap back in

                                         ; Pop working registers
    csrrw sp, mscratch, sp               ; Save Machine SP, restore User SP
    mret                                 ; Return from trap


trap_table
    DEFW handle_instr_addr_misaligned    ; 0 - Instruction address misaligned
    DEFW handle_instr_access_fault       ; 1 - Instruction access fault
    DEFW handle_illegal_instr            ; 2 - Illegal instruction
    DEFW handle_breakpoint               ; 3 - Breakpoint
    DEFW handle_load_addr_misaligned     ; 4 - Load address misaligned
    DEFW handle_load_access_fault        ; 5 - Load access fault
    DEFW handle_store_addr_misaligned    ; 6 - Store address misaligned
    DEFW handle_store_access_fault       ; 7 - Store access fault
    DEFW handle_ecall_umode              ; 8 - Environment call from U-mode
    DEFW handle_ecall_smode              ; 9 - Environment call from S-mode
    DEFW handle_reserved                 ; 10 - Reserved
    DEFW handle_ecall_mmode              ; 11 - Environment call from M-mode
    DEFW handle_instr_page_fault         ; 12 - Instruction page fault
    DEFW handle_load_page_fault          ; 13 - Load page fault
    DEFW handle_reserved_future          ; 14 - Reserved for future standard use
    DEFW handle_store_page_fault         ; 15 - Store page fault

handle_instr_addr_misaligned:  
handle_instr_access_fault:     
handle_illegal_instr:          
handle_breakpoint:             
handle_load_addr_misaligned:   
handle_load_access_fault:      
handle_store_addr_misaligned:  
handle_store_access_fault:     
handle_ecall_umode:            
handle_ecall_smode:            
handle_reserved:              
handle_ecall_mmode:           
handle_instr_page_fault:      
handle_load_page_fault:       
handle_reserved_future:       
handle_store_page_fault:      