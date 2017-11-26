;===============================================
; Symbols in modified ROM
;===============================================
; RAM Usage
	.equ	STCF,0x56
	.equ	SNGFLG,0x55
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
	.equ	TICKCNT,0x6C
	.equ	ISRS0,0x40
	.equ	ISRS1,0x41
	.equ	ISRS2,0x42
	.equ	ISRS3,0x43
	.equ	ISRS4,0x44
	.equ	ISRS5,0x45
	.equ	ISRS6,0x46
	.equ	ISRS7,0x47
	.equ	ISRS8,0x48
	.equ	ISRS9,0x49
	.equ	ISRS10,0x4A
	.equ	ISRS11,0x4B
	.equ	GTIMEL,0x4C
	.equ	GTIMEH,0x4D
; Code entry
	.equ 	ORGINT0,0x8003
	.equ 	ORGTC0,0x800B
	.equ 	ORGINT1,0x8013
	.equ 	ORGTC1,0x801B
	.equ 	SERINT,0x1500
	.equ 	DOWNLOAD,0x1512
	.equ 	ISCHAR,0x1549
	.equ 	GETCHAR,0x154E
	.equ 	SNDCHAR,0x1556
	.equ 	AFTERINIT, 0x49
	.equ 	PROCESS_VOICE,0x2046
	.equ 	FETCH_TST,0x20A2
	.equ 	PLAY_NOTE,0x20B3
	.equ 	MUSIC_INIT,0x20D5
	.equ 	ISR,0x20F5
	.equ 	AYOUT,0x2150
	.equ 	NOTE_TABLE,0x2200
	.equ 	ALBUM_00,0x2300
;===============================================