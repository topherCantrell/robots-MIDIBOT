;     Music functions

;===============================================
; PROCESS_VOICE(R1)	; R1 = voice descriptor
; FETCH_TST(TSTOR0:1)
; PLAY_NOTE(R0,R1)	; R0=note, R1=voice
; MUSIC_INIT()
;===============================================

;===============================================
; Internal Memory Usage
; MUSIC.ASM
	.equ	STCF,0x50
	.equ	SNGFLG,0x55
	.equ	TICKCNT,0x6C
	.equ	TSTOR0,0x51
	.equ	TSTOR1,0x52
	.equ	TSTOR2,0x53
	.equ	TSTOR3,0x54
	.equ	V1DEL,0x60
	.equ	V1MSB,0x61
	.equ	V1LSB,0x62
	.equ	V1VN,0x63
	.equ	V2DEL,0x64
	.equ	V2MSB,0x65
	.equ	V2LSB,0x66
	.equ	V2VN,0x67
	.equ	V3DEL,0x68
	.equ	V3MSB,0x69
	.equ	V3LSB,0x6A
	.equ	V3VN,0x6B
;===============================================

TEST_ISR:

	mov	a,SNGFLG
	cjne	a,#0xFF,IS01

	dec	TICKCNT
	mov	a,TICKCNT
	cjne	a,#0,IS01

	mov	r1,#0x60
	acall	PROCESS_VOICE
	mov	r1,#0x64
	acall	PROCESS_VOICE
	mov	r1,#0x68
	acall	PROCESS_VOICE
	mov	TICKCNT,#7

IS01:
	reti

;===============================================
; Descriptor points to voice data
; 0      1    2    3
; Delay  MSB  LSB  VoiceNumber
; 
; When delay reaches 0, a new delay and note are loaded into the 
; descriptor.
;
; If the note number is 0xFF, the note is transparent -- the
; voice is left "running" for the delay.
;
; If the delay is 0, a special command follows. Here is the complete
; format for special commands
; 00 00 rr vv	; Set a specific register to a specific value
; 00 03 vv	; Set the staccato factor
; 00 ??		; End the song
;===============================================
; R1 = pointer to descriptor
; A,R0,R1,R2,R5,R6,R7,DPTR - Garbled
PROCESS_VOICE:

	dec	@r1		; Decrement the delay
	mov	a,@r1		; Get the delay
	cjne	a,#0,PV02	; Jump if not time for a new note
; Load new note
	; Copy the descriptor info into temp space
	mov	TSTOR3,r1	; Pointer
	inc	r1		; Next
	mov	TSTOR0,@r1	; MSB
	inc	r1		; Next
	mov	TSTOR1,@r1	; LSB
	inc	r1		; Next
	mov	TSTOR2,@r1	; Voice
PVLD:	mov	r1,TSTOR3	; Restore pointer
	acall	FETCH_TST	; Get next byte of song
	cjne	a,#0,PV10	; Jump if normal note
; Handle special event
	acall	FETCH_TST	; Get second byte
	cjne	a,#0,PV12	; Jump if not a register command
; Handle register command
	acall	FETCH_TST	; Get register number
	mov	r0,a		; Into parameter
	acall	FETCH_TST	; Get value
	mov	r1,a		; Into parameter
	acall	AYOUT		; Set the register
	ajmp	PVLD		; Process next
PV12:	cjne	a,#3,PV13	; Jump if not a staccato spec
; Set staccato factor
	acall	FETCH_TST	; Get new staccato factor
	mov	STCF,a		; Into memory
	ajmp	PVLD		; Process next
PV13:	
; Turn off song flag
	mov	SNGFLG,#0	; Flag ISR
	ajmp	PV03		; Music is stopped now
PV02:
; Test for staccato
	cjne	a,STCF,PV03 	; Do nothing (but decrement count)
	inc	r1		; Point to voice number
	inc	r1		; '
	inc	r1		; '
	mov	a,@r1		; Get voice number
	rl	a		; *2 = register number
	mov	r0,a		; Into parameter
	mov	r1,#0		; Silence value
	acall	AYOUT		; Set fine
	inc	r0		; Point to coarse
	acall	AYOUT		; Set coarse
	ajmp	PV03		; Done
; Load a normal note
PV10:	mov	@r1,a		; Store new delay
	mov	r1,TSTOR2	; Voice number
	acall	FETCH_TST	; Get note number
	cjne	a,#0xFF,PV11	; "Transparent" note
	ajmp	PV04		; Leave voice alone
PV11:	mov	r0,a		; Note number to parameter
	acall	PLAY_NOTE	; Start the note
; Copy new PTR to descriptor
PV04:	mov	r1,TSTOR3	; Descriptor
	inc	r1		; Point to MSB
	mov	@r1,TSTOR0	; Copy MSB back
	inc	r1		; Point to LSB
	mov	@r1,TSTOR1	; Copy LSB back
PV03:	ret			; Done
;===============================================
; ++TSTOR0:1
; A,DPTR - Garbled
FETCH_TST:
	mov	dpl,TSTOR1	; Set ...
	mov	dph,TSTOR0	; ... DPTR
	mov	a,TSTOR1	; LSB
	cjne	a,#0xFF,fb01	; Going to carry?
	inc	TSTOR0		; Carry into the MSB
fb01:	inc	TSTOR1		; Bump the LSB
	movx	a,@DPTR		; Get value
	ret			; Done
;===============================================
; R0 contains the note-number
; R1 contains the voice-number
; A,R0,R1,R5,R6,R7,DPTR - Garbled
;
PLAY_NOTE:
	mov	dph,#0x90	; Base of note table
	mov	a,r0		; Note number ...
	rl	a		; ... * 2 ...
	ANL	A,#0xFE		; Mask off lower bit
	mov	dpl,a		; ... is table offset.
	movx	a,@DPTR		; Get first byte
	mov	r5,a		; R5 = first byte
	inc	dpl		; Next in table
	movx	a,@DPTR		; Get second byte
	mov	r6,a		; R6 = second byte
	MOV	A,R1		; Hold onto ...
	MOV	R7,A		; ... register base
	RL	A
	MOV	R0,a		; Register = FINE
	MOV	A,R5		; Get fine ...
	MOV	R1,A		; ... value into R1
	LCALL	AYOUT		; Set FINE
	MOV	A,R7		; Register base ...
	RL	A
	MOV	R0,a		; ... into R0
	INC	R0		; Register = COARSE
	MOV	A,R6		; Get coarse ...
	MOV	R1,A		; ... value into R1
	LCALL	AYOUT		; Set COARSE
	RET			; Done
;===============================================
; A,R0,R1,DPTR - Garbled
;
MUSIC_INIT:
	MOV   R0,#0x07	; Enable tones only
	MOV   R1,#0xF8
	LCALL AYOUT
	MOV   R0,#0x08	; Volume A
	MOV   R1,#0x08
	LCALL AYOUT
	MOV   R0,#0x09	; Volume B
	MOV   R1,#0x08
	LCALL AYOUT
	MOV   R0,#0x0A	; Volume C
	MOV   R1,#0x08
	LCALL AYOUT
	ret

;===============================================
;===============================================
	.org	0x9000
; Note table must be located at 0x??00
	; 96 notes defined (0=silence)
	.db	0x00,0x00,0x9C,0x0C
	.db	0xE7,0x0B,0x3C,0x0B
	.db	0x9B,0x0A,0x02,0x0A
	.db	0x73,0x09,0xEB,0x08
	.db	0x6B,0x08,0xF2,0x07
	.db	0x80,0x07,0x14,0x07
	.db	0xAE,0x06,0x4E,0x06
	.db	0xF4,0x05,0x9E,0x05
	.db	0x4D,0x05,0x01,0x05
	.db	0xB9,0x04,0x75,0x04
	.db	0x35,0x04,0xF9,0x03
	.db	0xC0,0x03,0x8A,0x03
	.db	0x57,0x03,0x27,0x03
	.db	0xFA,0x02,0xCF,0x02
	.db	0xA7,0x02,0x84,0x02
	.db	0x5D,0x02,0x3B,0x02
	.db	0x1B,0x02,0xFC,0x01
	.db	0xE0,0x01,0xC5,0x01
	.db	0xAC,0x01,0x94,0x01
	.db	0x7D,0x01,0x68,0x01
	.db	0x53,0x01,0x40,0x01
	.db	0x2E,0x01,0x1D,0x01
	.db	0x0D,0x01,0xFE,0x00
	.db	0xF0,0x00,0xE2,0x00
	.db	0xD6,0x00,0xCA,0x00
	.db	0xBE,0x00,0xB4,0x00
	.db	0xAA,0x00,0xA0,0x00
	.db	0x97,0x00,0x8F,0x00
	.db	0x87,0x00,0x7F,0x00
	.db	0x78,0x00,0x71,0x00
	.db	0x6B,0x00,0x65,0x00
	.db	0x5F,0x00,0x5A,0x00
	.db	0x55,0x00,0x50,0x00
	.db	0x4C,0x00,0x47,0x00
	.db	0x43,0x00,0x40,0x00
	.db	0x3C,0x00,0x39,0x00
	.db	0x35,0x00,0x32,0x00
	.db	0x30,0x00,0x2D,0x00
	.db	0x2A,0x00,0x28,0x00
	.db	0x26,0x00,0x24,0x00
	.db	0x22,0x00,0x20,0x00
	.db	0x1E,0x00,0x1C,0x00
	.db	0x1B,0x00,0x19,0x00
	.db	0x18,0x00,0x16,0x00
	.db	0x15,0x00,0x14,0x00
	.db	0x13,0x00,0x12,0x00
	.db	0x11,0x00,0x10,0x00
	.db	0x0F,0x00,0x0D,0x00
