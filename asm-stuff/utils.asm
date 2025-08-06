#define SPEED_MAJOR_OS 1
#define SPEED_MINOR_OS 13

#define GETKEY	res IndicOnly, (IY + IndicFlags) \ bcall(_GetKey)
#define PRINTLN	bcall(_PutS) \ bcall(_NewLine)
#define CLEAR	push HL \ bcall(_ClrScrn) \ bcall(_HomeUp) \ pop HL \ ld BC, 0 \ ld (CurCol), BC

; Initializes a bunch of things
; Sets HL to a pointer to the image data (after the magic number)
init:
; avoid Done message
	res	DonePrgm, (IY + DoneFlags)

	bcall(_GetCSC) ; ensuring that the keyboard scancode is reset
	bcall(_GetCSC) ; ensuring that the keyboard scancode is reset
	CLEAR

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
	call	load_default_appvar
; start of magic checks
	ld	A, (HL)
	cp	$69
	jr	NZ, print_bad_magic
	inc	HL

	ld	A, (HL)
	cp	$6d
	jr	NZ, print_bad_magic
	inc	HL

	ld	A, (HL)
	cp	$67
	jr	NZ, print_bad_magic
	inc	HL

	ld	A, (HL)
	cp	$64
	jr	NZ, print_bad_magic
	inc	HL

; version check
	ld	A, (HL)
	cp	$00
	jr	NZ, print_bad_magic
	inc	HL
	ret

; end init


exit_on_keypress:
	push	AF
	push	HL
	bcall(_GetCSC)
	cp	0
	jr	NZ, exit_msg_ok
	pop	HL
	pop	AF
	ret

exit_msg_ok:
	ld	HL, ok_msg

; Displays a message and exits
; 
; stack_base must be initialized to point to the base of the stack
; Inputs:
; HL - pointer to the null-terminated message
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


load_default_appvar:
	ld	HL, appvar_name
	rst	rMov9ToOP1

; presumes var name and type is in OP1
; clears all registers
; loads pointer to the start of var into HL
; does not check its size. if its size is bad, that's a skill issue
; sets NC if successful, C on failure
load_var:
	bcall(_ChkFindSym)
	jr	C, print_no_appvar ; error if no appvar

	ld	A, 0
	cp	B ; check if B == 0
	jr	NZ, print_archived ; error if archived

	; var in ram, get the ptr to it
	ex	DE, HL
	ret

; archived, exiting
print_archived:
	ld	HL, err_archived_msg
	jr	exit_msg

print_no_appvar:
	ld	HL, err_no_var
	jr	exit_msg

print_bad_magic:
	ld	HL, err_bad_magic
	jr	exit_msg

err_bad_magic:
	.db "Err: bad AppVar", 0

err_no_var:
	.db "Err: no AppVar", 0

err_archived_msg:
	.db "Err: archived", 0

ok_msg:
	.db "IMGDISP exit OK", 0

appvar_name:
	.db AppVarObj, "IMGDISP1"

press_key_str:
	.db "Press any key...", 0

magic_nums:
	.db $69, $6D, $67, $64

