#define SPEED_MAJOR_OS 1
#define SPEED_MINOR_OS 13


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
	ld	A, $FF
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
; end exit_msg

; delays enough for it to be safe to access the LCD memory
lcd_busy_safe:
	push	AF
	call _LCD_BUSY_QUICK
	pop	AF
	ret

#define SET_LCD_ROW(row) ld A, %80 + row \ call lcd_busy_safe \ out (lcdinstport), A
#define SET_LCD_COL

press_key_str:
	.db "Press any key...", 0

