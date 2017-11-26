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

	mov     r0,#0
	mov     r1,#0
	acall   AYOUT

	mov     r0,#1
	mov     r1,#0
	acall   AYOUT

	mov     r0,#2
	mov     r1,#0
	acall   AYOUT

	mov     r0,#3
	mov     r1,#0
	acall   AYOUT

	mov     r0,#4
	mov     r1,#0
	acall   AYOUT

	mov     r0,#5
	mov     r1,#0
	acall   AYOUT

	mov     r0,#6
	mov     r1,#255
	acall   AYOUT

	mov     r0,#7
	mov     r1,#7
	acall   AYOUT

	mov     r0,#8
	mov     r1,#16
	acall   AYOUT
	
	mov     r0,#9
	mov     r1,#16
	acall   AYOUT

	mov     r0,#10
	mov     r1,#16
	acall   AYOUT

	MOV     r0,#11
	mov     r1,#0
	acall   AYOUT

	mov     r0,#12
	mov     r1,#56
	acall   AYOUT

	mov     r0,#13
	mov     r1,#0
	acall   AYOUT

	ljmp    0


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

