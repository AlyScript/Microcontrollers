ORG 0x00040000

la sp, STACK

; Machine Stack
STACK_END DEFS 100 				; Reserve 100 bytes for the stack and point to the end (this is a stack `size` of 25, since each `item` is a word...)
STACK