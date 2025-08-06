
safe_lcd_busy:
	in	A, ($02)
	and	$02
	jr	Z, safe_lcd_busy
	ret

#define LCD_ROW(num) $80 + num
#define LCD_COL(num) $20 + num

; Awful routine that does one "display-cycle"; displaying the entire image
; HL is kept constant, all other registers are destroyed
display_img:
	di
	call safe_lcd_busy
	ld	A, $07
	out	($10), A

	ld	B, 7
	push	HL
	ld	C, $80
imgs_loop:
	; saving B, C
	push	BC

	ld	B, 64
	
row_loop:
	; setting row to current
	call	safe_lcd_busy
	ld	A, C
	out	($10), A
	inc	C
	
	; setting col 0
	call	safe_lcd_busy
	ld	A, $20
	out	($10), A
			
	; save reg B
	ld	D, B

	ld	B, 12 ; 12 cols
col_loop:
	call safe_lcd_busy
	ld	A, (HL)
	inc	HL
	out	($11), A
	djnz	col_loop
	
	; load reg b
	ld	B, D
	djnz	row_loop
		
	pop	BC
	djnz	imgs_loop

	pop	HL

	call safe_lcd_busy
	ld	A, $05
	out	($10), A

	ei
	ret


