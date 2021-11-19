	processor	6502
	; org	$1000 ; 4096
	org	$0950 ; 2384

    jsr clearscreen
    jsr initsprites
    jsr playmusic
	

    lda #$ff  ; maximum frequency value
    sta $d40e ; voice 3 frequency low byte
    sta $d40f ; voice 3 frequency high byte
    lda #$80  ; noise waveform, gate bit off
    sta $d412 ; voice 3 control register

    lda #$1
    sta $900

    ; clear random number list offsets
    lda #0
    sta RNUMSOFFSETL
    sta RNUMSOFFSETH

reset:
    lda 0
    sta $d000
    jmp loop

playmusic:
    lda #$00
    tax
    tay
    jsr $1000
    sei
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda #$01
    sta $d01a
    lda #$1b
    ldx #$08
    ldy #$14
    sta $d011
    stx $d016
    sty $d014
    lda #<irq
    ldx #>irq
    ldy #$7e
    sta $0314
    stx $0315
    sty $d012
    lda $dc0d
    lda $dd0d
    asl $d019
    cli
    rts
irq:
    jsr $1006
    asl $d019
    jmp $ea81


changepos:
    jsr clearscreen
    jsr initsprites
    ldx #$0
changeposnext:
    ; lda $d41b ; random x position
    ; sta $d000,X
    ; lda $d41b ; random y position
    ; sta $d001,X
    ldy #50
    sty $906
    ldy #180
    sty $907
    jsr randomnumber
    sta $d000,X
    ldy #50
    sty $906
    ldy #180
    sty $907
    jsr randomnumber
    sta $d001,X
    inx 
    inx 
    stx $901
    lda $901
    cmp #$10 ; number of sprites x2
    bne changeposnext
    lda #0
    sta $900

    ; move word happy halloween
    ; lda $d41b ; y position
    ldy #1
    sty $906
    ldy #50 ; there are 25 rows, we need double  since SRCLINES are words
    sty $907
    jsr randomnumber
    lsr
    asl ; we need an even number
    ; lda #34
    ; debug
    ; sta $913
    ; jsr printbyte
    ;;;;;;;;;;
    tax
    stx $904 ; save the row indicator
    lda SRCLINES,X
    sta $fd
    inx
    lda SRCLINES,X
    sta $fe
    ; lda $d41b ; x position
    ; ldy #1
    ; sty $906
    ; ldy #30
    ; sty $907
    ; jsr randomnumber
    lda #1
    tay
    ldx #0
wordloop:
    lda TEXT,X ; letter
    cmp #0
    beq wordend
    sta ($fd),Y
    iny
    inx
    jmp wordloop
wordend:
    jmp wait


changeposjmp:
    jmp changepos

loop:
    ; lda $d000
    ; cmp 150
    ; beq reset
    ; inc $d000
    inc $900 ; counter for staying in same position
    lda $900
    cmp #85  ; wait between jumps
    ; cmp #254  ; wait between jumps
    ; cmp JUMPDELAY ; wait between jumps
    beq changeposjmp
    ; random movements
    ldx #$0
    ; ldy #$0
randommovenext:
    ; lda $d41b  ; random move left of right
    ; jmp incxincy
    ldy #0
    sty $906
    ldy #254
    sty $907
    jsr randomnumber
    sta $fb 
    lsr
    asl ; shift right then left to see if number was even or odd
    cmp $fb
    beq incx
    jmp decx 
randomy:
    ; inc $d000,X ; everything travels right on average
    clc
    ldy #0
    sty $906
    ldy #254
    sty $907
    jsr randomnumber
    sta $fb 
    lsr
    asl ; shift right then left to see if number was even or odd
    cmp $fb
    beq incy
    jmp decy 
randommovenextafter:
    inx 
    inx 
    ; iny
    ; sty RNUM
    stx $901
    lda $901
    cmp #$10 ; number of sprites x2
    bne randommovenext
    jmp wait

incx:
    inc $d000,X
    clc
    jmp randomy
decx:
    dec $d000,X
    clc
    jmp randomy
incy:
    inc $d001,X
    clc
    jmp randommovenextafter
decy:
    dec $d001,X
    clc
    jmp randommovenextafter

printbyte:
    stx $910
    sta $911
    lda #$00 ; print to screen
    ldx $913 ;
    jsr $bdcd
    lda $911
    ldx $910
    rts

randomnumber:
    stx $902
    sty $903
    ; lda #$00 ; print to screen
    ; ldx $d41b ; 
    ; jsr $bdcd
    lda $d41b ; if sid waveform has data, let's use it, then we beebop
    cmp #$0
    beq callrnd
    lda $d41b ; if sid waveform has data, let's use it, then we beebop
    cmp #$ff
    beq callrnd
    jmp randomnumberend

rnumsreset:
    lda #0
    sta RNUMSOFFSETH
    sta RNUMSOFFSETL
    jmp callrndgetvalue
rnumsincoffseth:
    lda #0
    sta RNUMSOFFSETL
    lda RNUMSOFFSETH
    cmp #3 ; we can only get to 0x3ff
    beq rnumsreset
    adc #1
    sta RNUMSOFFSETH
    jmp callrndgetvalue
callrnd:
    ; lda #0
    ; jsr $E09A
    ; lda $64
    lda RNUMSOFFSETL
    cmp #255
    beq rnumsincoffseth
    adc #1
    sta RNUMSOFFSETL
callrndgetvalue:
    ; compute the random number address by adding our offset to the random number address
    ; debug
    ; lda RNUMSOFFSETH
    ; sta $913
    ; jsr printbyte
    ;;;;;;;;;;
    clc				; clear carry
	lda RNUMSOFFSETL
	; lda #0
	adc #$0  ; RNUMS1024 is at exactly $2100
	sta $fd			; store sum of LSBs
	lda RNUMSOFFSETH
	; lda #0
	adc #$21			; add the MSBs using carry from
	sta $fe
    ldy #0
    ; debug
    ; lda $fe
    ; sta $913
    ; jsr printbyte
    ;;;;;;;;;;
    lda ($fd),Y ; finally get the number from the list
    

randomnumberend:
    ; 906 is L 907 is R
    sta $908 ; save off the random number that is in the accumulator
;    jmp skipcompareremoveme
    lda $907 ; put the R in the accumulator
    sbc $906 ; subtract L
    adc #1
    ; sta $913
    ; jsr printbyte
    sta $909 ; hold onto the max value
    lda $908 ; put the random number back
    cmp $909  ; compare to U-L+1
    bcs callrnd   ; branch if value > U-L+1
;skipcompareremoveme:
    adc $906 ; add L
    ldx $902
    ldy $903
    rts

wait:
    ; jmp dowait ; skip scroll
    ; scroll 1 pixel right
    inc $905
    lda $905
    cmp #7
    beq set7
    sta $d016
    jmp dowait
set7:
    lda #0
    sta $d016
    sta $905
    ldx $904 ; load the row indicator
    ; inx ;end of the line
    lda SRCLINES,X
    sta $fb
    inx
    lda SRCLINES,X
    sta $fc
    ldy #38
set7loop:
    lda ($fb),Y
    iny
    sta ($fb),Y
    cpy #1
    beq doneset7
    dey
    dey
    jmp set7loop
doneset7:
    
    
dowait:
    cmp $d012
    bne dowait
    lda #$ff
    jmp loop

clearscreen:
    ; clear the screen
    lda #$00
    sta $d016 ; reset horizontal scroll
    sta $905
    sta $d020 ; clear screen
    sta $d021
    tax
    lda #$20
clearloop:   
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    dex
    bne clearloop
    rts

initsprites:
	lda #$80 ; location of sprite in memory... this is 2000, https://digitalerr0r.net/2011/03/31/commodore-64-programming-4-rendering-sprites/ explains
	sta $07f8
	sta $07f9 ; 2 sprites are on
	sta $07fa ; 3 sprites are on
	sta $07fb ; 4 sprites are on
	sta $07fc ; 5
	sta $07fd ; 6 sprites are on
	sta $07fe ; 7 sprites are on
	sta $07ff ; 8 sprites are on
	lda #%11111111 ; 8 sprites on
	sta $d015
	lda #$80
	sta $d000
	sta $d001
	sta $d002
	sta $d003
	sta $d004
	sta $d005
	sta $d006
	sta $d007
    lda #%11111111 ; 8 sprites in multi color mode
    sta $d01c
    lda #%1
    sta $d027 ; color modes
    lda #%1
    sta $d028
    lda #%1
    sta $d029
    lda #%1
    sta $d02a
    lda #%1
    sta $d02b
    lda #%1
    sta $d02c
    lda #%1
    sta $d02d
    lda #%1
    sta $d02e
    rts

    org $1000-$7e
    INCBIN "jeff_donald.sid"

	org $2000
	; incbin "sprite2.spr"
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00101010,%00000000
    .byte %00000000,%10101010,%00000000
    .byte %00000000,%10101010,%00000000
    .byte %00000000,%10101010,%00000000
    .byte %00000000,%10101010,%00000000
    .byte %00000010,%10101010,%10000000
    .byte %00000010,%10101010,%10000000
    .byte %00000010,%01010110,%10000000
    .byte %00000010,%01110101,%01000000
    .byte %00000010,%01010111,%01000000
    .byte %00000010,%10100101,%01100000
    .byte %00000010,%10101010,%10100000
    .byte %00001010,%10101010,%10100000
    .byte %00001001,%10101010,%01101000
    .byte %00001010,%01111101,%10101000
    .byte %00101010,%10010110,%10101010
    .byte %00101010,%10101010,%10101010
    .byte %10101010,%10101010,%10101010
    .byte %00001000,%10100010,%00001010

SUBTMP1     .word $902
SUBTMP2     .word $903
ROWPTR      .word $904
SCROLLPTR   .word $905
RNUMMIN     .word $906
RNUMMAX     .word $907
RNUMTMP     .word $908
RNUMTMP2     .word $909
PRINTBYTETMP .word $910
PRINTBYTETMP2 .word $911
PRINTBYTEVALUE .word $913
RNUM        .word $d41b
; RNUM        .word $2500
; RNUM        .word $dc08
SRCLINES    .word $0400, $0428, $0450, $0478, $04A0, $04C8, $04F0, $0518, $0540, $0568, $0590, $05B8, $05E0, $0608, $0630, $0658, $0680, $06A8, $06D0, $06F8, $0720, $0748, $770, $798, $7C0
TEXT        .byte  8,1,16,16,25,32,8,1,12,12,15,23,5,5,14,0
JUMPDELAY   .byte #100
RNUMSOFFSETL .word $914
RNUMSOFFSETH .word $915
reslo       .word $fd
reshi       .word $fe
	org $2100
    ; RNUMS1024 is forced to be at 2100 since I can not figure out how to get the lsb from the RNUMS1024 address programmatically
RNUMS1024        .byte 141,105,240,0,246,99,143,145,139,105,13,153,159,217,194,200,197,88,145,168,247,154,133,91,120,227,1,104,152,214,135,35,133,151,144,236,152,196,134,17,83,63,233,231,209,25,235,26,29,140,69,16,105,184,197,111,71,192,205,113,25,124,166,145,187,116,49,128,117,59,49,97,226,30,30,49,48,229,49,229,84,189,53,161,190,65,246,221,86,245,72,125,89,254,30,0,159,157,51,184,187,77,215,245,145,31,76,212,33,52,18,27,21,224,180,122,203,235,78,228,155,141,201,126,19,56,68,230
                .byte 110,191,230,35,1,204,129,18,137,135,233,219,238,71,188,238,106,160,112,192,93,138,232,27,107,78,149,200,203,194,163,149,187,113,49,146,243,94,179,202,104,117,155,207,212,123,118,243,253,87,101,240,103,216,246,235,14,82,224,228,179,22,198,173,2,94,251,20,155,71,110,118,100,6,23,191,73,7,146,64,97,237,65,94,249,112,56,225,123,149,95,240,54,1,145,241,77,230,10,92,120,186,221,6,230,249,61,114,114,13,31,53,123,215,24,81,225,1,213,90,76,129,230,144,7,38,84,200
                .byte 75,60,29,62,143,87,93,183,90,119,51,215,49,24,231,23,92,208,226,204,73,1,166,46,151,10,213,135,51,238,219,76,129,86,43,54,19,19,82,96,103,123,151,101,116,77,103,36,165,133,223,131,169,184,192,43,175,163,175,169,94,66,155,34,99,99,126,163,218,210,100,207,133,129,52,177,23,193,185,55,134,100,161,137,39,60,252,111,158,139,224,41,206,157,63,116,52,81,36,221,52,159,5,248,71,104,95,113,38,155,49,153,74,247,77,253,8,187,241,163,40,66,3,252,89,254,12,250
                .byte 81,45,156,182,43,17,87,245,137,75,48,144,219,51,249,189,212,31,188,125,253,60,80,236,123,179,181,125,212,148,0,208,96,113,26,30,251,205,141,160,67,188,108,180,108,47,146,74,55,168,233,252,61,55,21,64,81,49,30,237,151,249,130,180,165,176,98,61,120,91,173,6,133,185,214,138,144,246,66,82,1,44,25,4,145,208,235,86,124,68,64,214,52,135,148,14,96,111,238,36,183,201,180,89,77,16,105,221,211,24,229,60,149,140,73,60,234,188,222,98,109,128,248,5,79,39,122,131
                .byte 199,190,201,56,131,242,32,42,89,103,107,251,223,225,244,237,181,238,61,220,62,96,95,12,175,198,178,108,36,6,8,10,103,189,131,83,232,216,75,224,120,152,218,111,228,87,76,26,18,94,151,39,151,219,125,29,5,156,232,160,163,67,218,99,232,212,33,165,31,89,53,253,141,21,154,4,178,234,204,61,196,70,19,244,86,51,57,59,183,229,84,154,156,6,92,227,89,226,113,189,222,87,90,174,11,9,133,227,206,106,144,118,152,75,28,163,138,225,245,139,45,216,130,129,48,174,29,103
                .byte 227,190,20,181,23,173,4,44,234,251,108,45,23,78,236,215,253,142,180,98,184,236,189,188,104,205,175,128,223,31,196,90,125,177,12,206,17,20,230,128,73,108,187,44,52,187,246,158,127,153,67,203,216,26,7,239,41,233,245,34,21,18,91,15,154,25,22,130,197,166,135,251,145,205,95,133,75,149,2,65,57,159,207,114,1,172,69,31,80,197,149,241,145,67,115,65,242,163,205,216,100,208,230,156,241,212,185,219,71,230,97,136,246,53,30,188,44,93,153,189,95,9,96,132,118,115,205,65
                .byte 116,123,109,7,12,161,106,49,3,160,54,64,17,199,173,37,124,83,33,175,164,189,185,150,22,82,154,239,203,197,98,136,107,244,181,54,187,159,241,50,74,173,79,51,57,185,29,139,125,163,202,248,123,27,4,110,201,200,198,188,23,5,195,245,172,157,28,48,48,97,198,45,130,161,42,93,0,7,141,146,222,185,134,158,196,101,86,105,208,93,121,209,204,33,57,200,10,5,44,247,128,52,114,232,102,214,29,56,29,128,160,219,45,9,41,246,90,247,162,223,253,51,118,16,109,48,114,130
                .byte 212,41,114,0,153,95,245,65,174,169,228,17,54,202,137,20,113,86,143,214,135,123,176,99,88,164,84,149,28,97,192,141,138,12,40,248,141,2,207,197,42,142,154,26,199,208,106,87,104,210,234,60,64,38,214,46,196,35,161,192,5,163,79,9,29,102,203,207,88,226,155,78,155,3,165,160,248,110,123,185,159,40,3,207,218,5,179,230,97,79,243,177,156,13,1,140,81,1,39,153,59,236,90,112,145,83,92,171,52,157,103,69,105,15,47,102,97,201,63,27,58,208,201,35,79,161,64,185
