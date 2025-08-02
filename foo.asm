#define MIN_MAJOR_VER 1
#define MIN_MINOR_VER 12

.nolist
#include "ti83plus.inc"
.list
.org userMem - 2
.db t2ByteTok, tAsmCmp
start:
	bcall	(_HomeUp)
	ld	HL, 0
	ld	(CurCol), HL
	ld	HL, avid_ok
	bcall	(_PutS)
	bcall	(_NewLine)
	ret
	call	avid_print_ok
	jp	P, avid_os_ok

	ld	HL, 0
	ld	(CurCol), HL
	ld	HL, avid_err_old_os

	bcall	(_PutS)
	bcall	(_NewLine)
	jr	prints
avid_os_ok:
	ld	HL, 0
	ld	(CurCol), HL
	ld	HL, avid_ok

prints:
	bcall	(_PutS)
	bcall	(_NewLine)
	ret
	



; if initialization is successful, the sign flag is negative
; if initialization fails; the sign flag is nonnegative
avid_init:
	bcall	(_GetBaseVer)
	sub	MIN_MAJOR_VER
	ret

	ret	M	; too small maj ver
	ret	NZ	; big enough maj ver

	ld	A, B
	sub	MIN_MINOR_VER
	ret

avid_print_ok:
	ld	HL, avid_ok
	bcall	(_PutS)
	bcall	(_NewLine)
	ret

avid_print_err:
	ld	HL, avid_err_old_os
	bcall	(_PutS)
	bcall	(_NewLine)
	ret

avid_err_old_os:
	.db "err: OS is old",0
avid_ok:
	.db "your OS is fine",0



.end

