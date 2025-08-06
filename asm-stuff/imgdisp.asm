.nolist
#include "ti83plus.inc"
.list
.org    userMem - 2
.db     t2ByteTok, tAsmCmp

start:
	ld	(stack_base), SP
	call	init

mainloop:
	call display_img
	call exit_on_keypress
	jr	mainloop


#include "disp_routines.asm"
#include "utils.asm"

stack_base:
	.dw	0

.end
