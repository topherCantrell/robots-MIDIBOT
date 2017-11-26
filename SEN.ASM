        .org     0x8050

; TEST PULSE

        mov     r0,#1
        acall   SENSE

; STORE RESULTS

        mov     dph,#0x80
        mov     dpl,#0x00
        mov     a,TH1
        movx    @DPTR,a
        mov     dpl,#1
        mov     a,TL1
        movx    @DPTR,a

        ljmp    0

;==============================================================
; SENSE
; R0 = Detection Profile Number
; T1 contains the time to detection or FFFF if no detection.

SENSE:
; Initialize the Timers/Counters
        mov     TMOD,#0x11      ; 16 bit timers on TC0 and TC1
        anl     TCON,#0xAF      ; Turn both timers OFF
; Copy the waveform parameters from the constant table
        mov     a,r0            ; Profile number
        rl      a               ; *2
        rl      a               ; *4
        rl      a               ; *8
        mov     dph,#0x81       ; Table start
        mov     dpl,a           ; LSB
        movx    a,@DPTR         ; Load WIDTH
        mov     r2,a            ; ...
        inc     dpl             ; ...
        movx    a,@DPTR         ; ...
        mov     r3,a            ; ...
        inc     dpl             ; ...
        movx    a,@DPTR         ; Load RING
        mov     r4,a            ; ...
        inc     dpl             ; ...
        movx    a,@DPTR         ; ...
        mov     r5,a            ; ...
        inc     dpl             ; ...
        movx    a,@DPTR         ; Load WINDOW
        mov     r6,a            ; ...
        inc     dpl             ; ...
        movx    a,@DPTR         ; ...
        mov     r7,a            ; ...
        inc     dpl             ; ...
        movx    a,@DPTR         ; Load ADJUST
        mov     r0,a            ; ...
        inc     dpl             ; ...
        movx    a,@DPTR         ; ...
        mov     r1,a            ; ...
; Initialize the IO pointer
        mov     dph,#0xFF       ; Set DPTR to ...
        mov     dpl,#0xFC       ; ... the IO port.

; Send the transmitter pulse
        mov     TH0,r2          ; Load the ...
        mov     TL0,r3          ; ... count interval.
        clr     TCON.5          ; Reset overflow flag
        mov     a,#0x80         ; Connected to upper bit
        movx    @DPTR,a         ; Enable the Tx
        setb    TCON.4          ; Start the counter
        mov     a,#0            ; Reset value    
        jnb     TCON.5,*        ; Wait for the couter to overflow
        movx    @DPTR,a         ; Turn the transmitter off
        clr     TCON.4          ; Turn the timer off

; Wait for the Ring to end
        mov     TH0,r4          ; Load the ...
        mov     TL0,r5          ; ... count interval.
        clr     TCON.5          ; Reset the overflow flag
        setb    TCON.4          ; Start the counter
        jnb     TCON.5,*        ; Wait for the counter to overflow
        clr     TCON.4          ; Turn the timer off

; Now handle the return
        mov     TH1,#0          ; Clear the detection ...
        mov     TL1,#0          ; ... timer.
        mov     TH0,r6          ; Load the ...
        mov     TL0,r7          ; ... count interval.
        clr     TCON.5          ; Reset the overflow flag
        setb    TCON.4          ; Start the counter
        setb    TCON.6          ; Start the detection timer
DET002: movx    a,@DPTR         ; Get the sensor bit
        jnb     ACC.4,DET001    ; Detection made ... out
        jnb     TCON.5,DET002   ; If window is still active, loop
        ; Window expired -- retrun FFFF
        clr     TCON.6          ; Turn the timers ...
        clr     TCON.4          ; ...off
        mov     TH1,#0xFF       ; Set the value to ...
        mov     TL1,#0xFF       ; ... FFFF (no detection)
        ret
        ; Detection found in window -- return interval
DET001: clr     TCON.6          ; Turn the timers ... 
        clr     TCON.4          ; ... off
        mov     a,r1            ; Add ring delay ...
        add     a,TL1           ; ...
        mov     TL1,a           ; ...
        mov     a,r0            ; ...
        addc    a,TH1           ; ...
        mov     TH1,a           ; ... to return value
        ret

;--------------------------------------------------------------
; Detection Profiles. Eight bytes define the detection profile
; for a sensor pulse. Two byte values as follows:
; WIDTH  = length of tranmitted pulse in uS
; RING   = delay before detection in uS
; WINDOW = detection window in uS
; ADJUST = RING (Not 2s complement)

        .org    0x8100

; Reliable from 6 inches to 12+ inches
; PW=50uS, RING=6inches, WINDOW = 12 inches, ADJUST=6inches
PUL1:   .db     0xFF,0xCE,  0xFC,0xAE,  0xF8,0xF8, 0x03,0x52

; Close range -- from 1 inches to 6 inches
; PW=1uS, RING=1inch, WINDOW=6inches, ADJUST=1inch
PUL2:   .db     0xFF,0xFF, 0xFF,0x6A, 0xFC,0x7C, 0x00,0x00


