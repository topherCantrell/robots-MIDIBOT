;===============================================
; Symbols in modified ROM
;===============================================
	.equ ORGINT0,0x8003
	.equ ORGTC0,0x800B
	.equ ORGINT1,0x8013
	.equ ORGTC1,0x801B
	.equ SERINT,0x1500
	.equ DOWNLOAD,0x1512
	.equ ISCHAR,0x1549
	.equ GETCHAR,0x154E
	.equ SNDCHAR,0x1556
	.equ AFTERINIT, 0x49
;===============================================

	.org    0x8050
	
	MOV     IE,#0	; Turn off the interrupt

	MOV   R0,#0x07 	; A+B enabled as ...
	MOV   R1,#0xC0	; ... outputs
	LCALL AYOUT	; Configure I/O ports

	MOV   R0,#0xFF	; Both wheels turning
	MOV   R1,#0x0E	; Port A
	LCALL AYOUT	; Start them moving!

	MOV	R0,#0xFF
	MOV	R1,#0x0F
	LCALL AYOUT

	Ljmp    0

;===============================================
; R0 = register
; R1 = value
; A,DPTR - Garbled
;
AYOUT:
	mov     dph,#0xFF       ; Set DPTR to latch
	mov     dpl,#0xFC       ; '
	mov     P1,R0           ; Register -> P1
	mov     a,#0x03         ; 11 -> Control
	movx    @DPTR,a         ; '
	mov     a,#0            ; 00 -> Control
	movx    @DPTR,a         ; '
	mov     P1,r1           ; Value -> P1
	mov     a,#0x1          ; 01 -> Control
	movx    @DPTR,a         ; '
	mov     a,#0            ; 00 -> Control
	movx    @DPTR,a         ; '
	ret

