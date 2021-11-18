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
    sta $fb
    inx
    lda SRCLINES,X
    sta $fc
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
    sta ($fb),Y
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
    ; cmp #10  ; wait between jumps
    cmp #254  ; wait between jumps
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
    and #%11
    cmp #%11
    beq incxincy
    and #%01
    cmp #%01
    beq decxdecy
    and #%10
    cmp #%10
    beq incxdecy
    ; and #%00
    ; cmp #%00
    jmp decxincy
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

incxincy:
    inc $d000,X
    inc $d001,X
    jmp randommovenextafter
incxdecy:
    inc $d000,X
    dec $d001,X
    jmp randommovenextafter
decxincy:
    dec $d000,X
    inc $d001,X
    jmp randommovenextafter
decxdecy:
    dec $d000,X
    dec $d001,X
    jmp randommovenextafter

    
    ; inc $d000
    ; dec $d001
    ; jmp wait
	; jmp loop

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
callrnd:
    lda #0
    jsr $E09A
    lda $64
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
    sta $d020
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
