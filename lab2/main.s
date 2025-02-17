ORG 0

<INCLUDE print.s>

la sp, STACK
la a1, STR
call print

STR DEFB "Hello World!\0"
ALIGN

STACK_END DEFS 100 				; Reserve 100 bytes for the stack and point to the end (this is a stack `size` of 25, since each `item` is a word...)
STACK