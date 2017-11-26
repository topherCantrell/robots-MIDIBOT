;==================================================
; Motor Driver
;
; The motors are controlled through the sound chips
; output ports. That means the ISR is the only place
; that can modify the motor status. These routines
; manipulate RAM_MOTOR_STATUS and signal the ISR
; to make the change next tick.
;==================================================

;==================================================
; MOTORDRV.ASM
	.equ	RAM_MOTOR_STATUS,0x65
	.equ	RAM_MOTOR_ISR,0x66
;==================================================

; Format of motor status
; 7  6  5  4  3  2  1  0
; LE LD LS -  -  RE RD RS

; a=MOTOR_LEFT_STATUS()
; MOTOR_RIGHT_STATUS()
; MOTOR_LEFT (-----SDE) (R0)
; MOTOR_RIGHT(-----SDE) (R0)
; MOTOR(SDE--SDE) (R0 - status format)
; MOTOR_WAIT()

	.org	0x8050

MOTOR_INIT:
	mov	RAM_MOTOR_STATUS,#0
	acall	MOTOR_COMMAND
	acall	MOTOR_WAIT
	ret

MOTOR_LEFT_STATUS:
	mov	a,RAM_MOTOR_STATUS
	rr	a
	rr	a
	rr	a
	rr	a
	anl	a,#0x7
	ret

MOTOR_RIGHT_STATUS:
	mov	a,RAM_MOTOR_STATUS
	anl	a,#0x7
	ret

MOTOR_LEFT:
	mov	a,RAM_MOTOR_STATUS
	anl	a,#0x0F
	rl	a
	rl	a
	rl	a
	rl	a
	orl	a,r0
	mov	RAM_MOTOR_STATUS,a
	acall	MOTOR_COMMAND
	;mov	RAM_MOTOR_ISR,#0xFF	; Tell ISR to do this
	ret

MOTOR_RIGHT:
	mov	a,RAM_MOTOR_STATUS
	anl	a,#0xF0
	orl	a,r0
	mov	RAM_MOTOR_STATUS,a
	acall	MOTOR_COMMAND
	;mov	RAM_MOTOR_ISR,#0xFF	; Tell ISR to do this
	ret

MOTOR:
	mov	RAM_MOTOR_STATUS,a
	acall	MOTOR_COMMAND
	;mov	RAM_MOTOR_ISR,#0xFF	; Tell ISR to do this
	ret

MOTOR_WAIT:
	mov	a,RAM_MOTOR_ISR
	clr	c
	subb	a,#0
	jnz	MOTOR_WAIT
	ret

;========================================================
; Testing hard-wired motors
;========================================================
MOTOR_COMMAND:
	mov	r0,dpl
	mov	r1,dph
	mov	dpl,#0xFF
	mov	dph,#0xFC

	; Hard-wired port FFFC
	; 7  6  5  4  3  2  1  0
	; RS RD *  RE LS LD LE -

	; Manipulate right wheel
	mov	r2,#0
	mov	a,RAM_MOTOR_STATUS
	rr	a
	rr	a
	rr	a
	rr	a
	anl	a,#0xE
	orl	a,r2
	mov	r2,a

	; Manipulate left wheel
	mov	a,RAM_MOTOR_STATUS
	rl	a
	rl	a
	rl	a
	rl	a
	anl	a,#0xC0
	orl	a,r2
	mov	r2,a
	mov	a,RAM_MOTOR_STATUS
	anl	a,#2
	rl	a
	rl	a
	rl	a
	rl	a
	orl	a,r2

	movx	@DPTR,a	

	mov	dpl,r0
	mov	dph,r1

	; Schedule interrupt service here
	;mov	RAM_MOTOR_ISR,#0xFF	; Tell ISR to do this

	ret
	

