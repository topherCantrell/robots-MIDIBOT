;     Various board functions

;===============================================
; A=GET_AYREG()
; SET_AYREG(R0,A)	R0=address,A=value
; A=GET_SWITCHES()
; A=GET_LAMP()
; SET_LAMP(A)
; PRINT_MESSAGE(R0,R1)	R0=MSB,R1=LSB
; PRINT_HEXBYTE(A)
; PRINT_NIBBLE(A)
;===============================================

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

;===============================================
; Internal Memory Usage
; SYSTEM.ASM
	.equ	RAM_FFFC,0x67
	.equ	RAM_ATOMIC,0x68
	.equ	RAM_ISR_COUNTM,0x60
	.equ	RAM_ISR_COUNTL,0x61
	.equ	RAM_ISR_1,0x62
;===============================================

	.org	0x8050

;===============================================
;===============================================

INTERRUPT_SERVICE_ROUTINE:

	mov	RAM_ISR_1,a	; Preserve the ACC

	mov	a,RAM_ATOMIC	; Is someone in the middle ...
	clr	c	; Does INTERRUPT PUSH THE FLAGS?
	subb	a,#0	; ... of I/O?
	jnz	ISR_01	; YES: Do none here

	; Process MUSIC	and other needing I/O

ISR_01:

	; General counter
	
	inc	RAM_ISR_COUNTL
	mov	a,RAM_ISR_COUNTL
	clr	c
	subb	a,#0
	jnz	ISR_02
	inc	RAM_ISR_COUNTM
ISR_02:

	; Counts on task descriptors

	mov	a,RAM_ISR_1	; Restore the ACC
	RETI

;===============================================
;===============================================

GET_AYREG:
	mov	dph,#0xFF	; Set DPTR to latch
	mov	dpl,#0xFC	; '
	MOV	RAM_ATOMIC,#0xFF; Tell ISR we are using the I/O lines
	mov	P1,R0		; Register address
	mov	a,RAM_FFFC	; Current latch value
	orl	a,#0x03		; Set AY controls to 11
	movx	@DPTR,a		; Tell AY to latch
	anl	a,#0xFC		; Set AY controls to 00
	movx	@DPTR,a		; Disable the AY bus
	mov	P1,#0xFF	; Latch for input
	orl	a,#0x01		; Set AY controls to 01
	movx	@DPTR,a		; AY now bus-ing value
	nop			; Give the bus a second
	movx	a,@DPTR		; Read the bus
	mov	r1,a		; Hold it
	mov	a,RAM_ATOMIC	; Turned off value
	movx	@DPTR,a		; AY turned off
	mov	a,r1		; Return in A
	MOV	RAM_ATOMIC,#0	; We are done with the AY
	ret

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
	mov     a,#0		; 00 -> Control
	movx    @DPTR,a		; '
	ret

;===============================================
;===============================================
SET_AYREG:
	mov	dph,#0xFF	; Set DPTR to latch
	mov	dpl,#0xFC	; '
	mov	r1,a		; Hold A for a bit
	MOV	RAM_ATOMIC,#0xFF; Tell ISR we are using the I/O lines
	mov	P1,R0		; AY register
	mov	a,RAM_FFFC	; Current latch value
	orl	a,#0x03		; Set AY controls to 11
	movx	@DPTR,a		; AY now latching the register
	anl	a,#0xFC		; Set AY controls to 00
	movx	@DPTR,a		; Free the bus
	mov	P1,r1		; Value
	orl	a,#0x2		; Set AY controls to 10
	movx	@DPTR,a		; Latch the value
	mov	a,RAM_FFFC	; Current latch value
	movx	@DPTR,a		; Disable the AY bus
	MOV	RAM_ATOMIC,#0	; Done with IO
	ret

;===============================================
;===============================================

GET_SWITCHES:
	mov	dph,#0xff
	mov	dpl,#0xfc
	movx	a,@DPTR
	cpl	a
	rr	a
	rr	a
	rr	a
	rr	a
	ret

;===============================================
;===============================================

GET_LAMP:
	mov	a,RAM_FFFC
	anl	a,#0xDF
	rr	a
	rr	a
	rr	a
	rr	a
	rr	a
	ret	

;===============================================
;===============================================

SET_LAMP:
	mov	r6,a
	mov	a,RAM_FFFC
	anl	a,#0xDF
	mov	RAM_FFFC,a
	mov	a,r6
	mov	dph,#0xff
	mov	dpl,#0xfc
	anl	a,#1
	rl	a
	rl	a
	rl	a
	rl	a
	rl	a
	orl	a,RAM_FFFC
	mov	RAM_FFFC,a
	movx	@DPTR,a
	ret

;===============================================
;===============================================

PRINT_MESSAGE:
	mov	dph,r0	; Message ...
	mov	dpl,r1	; ... pointer
PM_02:	movx	a,@DPTR	; Get next character
	clr	c	; Prepare compare
	subb	a,#0	; End of string?
	jz	PM_DONE	; YES: Out of here
	lcall	SNDCHAR	; NO: Send it out the serial port
	inc	dpl	; Next character
	mov	a,dpl	; Did we ...
	clr	c	; ... overflow ...
	subb	a,#0 	; ... into MSB
	jnz	PM_01	; NO: Keep MSB
	inc	dph	; YES: Bump MSB
PM_01:	ljmp	PM_02	; More characters.
PM_DONE:
	ret

;===============================================
;===============================================

PRINT_HEXBYTE:
	mov	r6,a
	rr	a
	rr	a
	rr	a
	rr	a
	acall	PRINT_NIBBLE
	mov	a,r6
	anl	a,#0x0F
	acall	PRINT_NIBBLE
	ret

;===============================================
;===============================================

PRINT_NIBBLE:
	mov	r0,a
	clr	c
	subb	a,#0xA
	jc	PRINT_02
	add	a,#'A'
	lcall	SNDCHAR
	ret
PRINT_02:
	mov	a,r0
	add	a,#'0'
	lcall	SNDCHAR
	ret
