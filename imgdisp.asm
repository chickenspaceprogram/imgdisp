.nolist
#include "ti83plus.inc"
.list
.org    userMem - 2
.db     t2ByteTok, tAsmCmp

start:
	ld	(stack_base), SP
	call	init

stack_base:
	.dw	0

#include "utils.asm"

.end
