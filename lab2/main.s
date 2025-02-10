ORG 0

include puts.s

STR DEFB 0x48, 0x45, 0x4C, 0x4C, 0x4F, 0x20, 0x57, 0x4F, 0x52, 0x4C, 0x44, 0x21, 0x00  ; ASCII values for "HELLO WORLD!"

li s1, 0x00             ; s1 is the index of the string. This increases by 1 each time a character is printed
la s2, STR              ; s2 is a pointer to the string
print_loop
    lbu s0, [s2]        ; load the character to be printed into s0
    beqz done           ; if the character is null, we are done
    addi s2, s2, 1      ; increment string pointer
    call puts           ; print the character
    j print_loop        
    
done:
    ret    