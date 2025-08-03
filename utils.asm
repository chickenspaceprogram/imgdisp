#define SPEED_MAJOR_OS 1
#define SPEED_MINOR_OS 13

#define GETKEY	res IndicOnly, (IY + IndicFlags) \ bcall(_GetKey)
#define PRINTLN	bcall(_PutS) \ bcall(_NewLine)
#define CLEAR	push HL \ bcall(_ClrScrn) \ bcall(_HomeUp) \ pop HL \ ld BC, 0 \ ld (CurCol), BC

init:
; avoid Done message
	res	DonePrgm, (IY + DoneFlags)

; check OS version
	bcall(_GetBaseVer)
	sub	SPEED_MAJOR_OS
	jp	M, no_set_speed
	jr	NZ, set_speed

	ld	A, B
	sub	SPEED_MINOR_OS
	jp	M, no_set_speed

set_speed:
	ld	A, $01
	bcall(_SetExSpeed)

no_set_speed:
	ret
; end init

; Displays a message and exits
; 
; stack_base must be initialized to point to the base of the stack
; Inputs:
; HL - pointer to the null-terminated message

; jp to this routine, don't call it
exit_msg:
	CLEAR

	; print err str
	PRINTLN

	; printing press-key str
	ld	HL, press_key_str
	PRINTLN

	; blocking on getkey
	GETKEY
exit:
	ld	SP, (stack_base)
	ret
; end exit
; end exit_msg



press_key_str:
	.db "Press any key...", 0

