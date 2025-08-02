#define MIN_MAJOR_OS_VER 1
#define MIN_MINOR_OS_VER 13


os_err_str:
	.db "ERR: Old OS", 0

init:
; avoid Done message
	res	DonePrgm, (IY + DoneFlags)

; check OS version
	bcall(_GetBaseVer)
	sub	MIN_MAJOR_OS_VER
	jp	M, end_chk_osver
	jr	NZ, end_chk_osver

	ld	A, B
	sub	MIN_MINOR_OS_VER
end_chk_osver:
; print err string and exit if needed
	ld	HL, os_err_str
	jp	M, exit_msg ; os version too old, exit

	ret

; Displays a message and exits
; 
; stack_base must be initialized to point to the base of the stack
; Inputs:
; HL - pointer to the null-terminated message

; jp to this routine, don't call it
exit_msg:
	push	HL
	bcall(_ClrScrn)
	bcall(_HomeUp)
	pop	HL

	; initialize flags
	ld	BC, 0
	ld	(CurCol), BC

	; print err str
	bcall(_PutS)
	bcall(_NewLine)

	; printing press-key str
	ld	HL, press_key_str
	bcall(_PutS)
	bcall(_NewLine)

	; blocking on getkey
	res	IndicOnly, (IY + IndicFlags)
	bcall(_GetKey)
exit:
	ld	SP, (stack_base)
	ret

press_key_str:
	.db "Press any key...", 0

