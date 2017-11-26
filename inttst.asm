;===============================================
; Symbols in modified ROM
;===============================================
	.equ ORGINT0,   0x8003
	.equ ORGTC0,    0x800B
	.equ ORGINT1,   0x8013
	.equ ORGTC1,    0x801B
	.equ SERINT,    0x1500
	.equ DOWNLOAD,  0x1512
	.equ ISCHAR,    0x1549
	.equ GETCHAR,   0x154E
	.equ SNDCHAR,   0x1556
	.equ AFTERINIT, 0x49
; Best I can tell, RAM 0x60-0x7F is not being used
; by the monitor. Co-existent programs can use that
; space.
;===============================================

	.org	ORGINT0		; Interrupt 0 Mirror
	ajmp	HANDLER		; Vector out to ISR

	.org	0x8050

; Establish interrupt handler and clear count

ESTAB:
	mov	0x60,dph	; Hold DPTR
	mov	0x61,dpl	; ' 

	mov	dph,#0x80	; Interrupt counter at ...
	mov	dpl,#0x40	; ... 0x8040,0x8041 (LSB,MSB)
	mov	a,#0		; Clear counter
	movx	@DPTR,a		; '
	mov	dpl,#0x41	; '
	movx	@DPTR,a		; '
	mov	dph,0x60	; Restore DPTR
	mov	dpl,0x61	; '

	ORL	IE,#0x01	; Enable Interrupt 0

	ljmp	AFTERINIT	; Return to monitor (after init)

;===============================================
; Interrupt Service Routine
;===============================================

HANDLER:
	mov	0x60,dph	; Hold registers we will be using
	mov	0x61,dpl	; '
	mov	0x62,a		; '

	mov	dph,#0x80	; Set DPTR to counter LSB
	mov	dpl,#0x40	; '
	movx	a,@DPTR		; Get LSB
	inc	a		; increment count
	movx	@DPTR,a		; store it back
	clr	c		; no borrow
	subb	a,#0		; Did it overflow?
	jnz	hand01		; No  : move on
	mov	dpl,#0x41	; Yes : set DPTR to MSB
	movx	a,@DPTR		; Get MSB
	inc	a		; Bump MSB
	movx	@DPTR,a		; Store it back

hand01:	
	mov	dph,0x60	; Restore registers
	mov	dpl,0x61	; '
	mov	a,0x62		; '
	reti			; Done
