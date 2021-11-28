;--------------------------------------------------------------------

;This routine sets or erases a point on the hires screen based
;on coordinates and drawmode determined before-hand.  you can change
;"screen" to wherever your hires screen is located.
;plotPoint works by first determining which 8x8 cell the point is
;located in and uses tables to figure that out.
;The in-cell offset is determined by just isolating the lowest 3 bits
;of each point (0-7).  The pixel masking uses tables, too.

;--------------------------------------------------------------------
    processor 6502
    org $950  ; 2384

    ; copy characters somewhere before we can not see them any longer 
    ; memcopy: $fb is lower from byte, $fc is upper from byte, $fd is lower to byte, $fe is upper to byte, $ff is number of bytes to copy
    ; clc
    ; lda #<$1c25
    ; sta $fb
    ; lda #>$1c25
    ; sta $fc
    ; lda #<$800
    ; sta $fd
    ; lda #>$800
    ; sta $fe
    ; lda #$ff
    ; sta $ff
    ; jsr memcopy
    ; lda #<$800
    ; sta $fb
    ; lda #>$800
    ; sta $fc
    ; lda #<$808
    ; sta $fd
    ; lda #>$808
    ; sta $fe
    ; lda #%10101010
    ; sta $ff
    ; jsr setmemory
    

    lda $d018
    ora #8
    sta $d018 
    ; POKE 53265,PEEK(53265)OR32
    lda $d011 
    ora #32
    sta $d011  ; set all of the bytes

    ; checker board
    ; jmp skipcheckerboard
    ;10 POKE 53272,PEEK(53272)OR8:POKE 53265,PEEK(53265)OR32
    ; 20 FORI=8192TO16191 STEP 8
    lda #<$2000
    sta $fb
    lda #>$2000
    sta $fc
checkerloop:
    ; 30 POKEI,240:POKEI+1,240:POKEI+2,240:POKEI+3,240
    lda #240
    ldy #0
    sta ($fb),Y
    iny
    sta ($fb),Y
    iny
    sta ($fb),Y
    iny
    sta ($fb),Y
    ; 40 POKEI+4,15:POKEI+5,15:POKEI+6,15:POKEI+7,15
    lda #15
    iny
    sta ($fb),Y
    iny
    sta ($fb),Y
    iny
    sta ($fb),Y
    iny
    sta ($fb),Y
; next logic
    ; 50 NEXT
    clc
    lda $fb
    adc #8
    sta $fb
    lda $fc
    adc #0
    sta $fc
    cmp #$40
    bne checkerloop
    clc
    lda $fb
    cmp $40
    beq past1
    jmp checkerloop

past1:
    ; 60 FORI=1024TO2034:POKEI,251:NEXT
    lda #<$400
    sta $fb
    lda #>$400
    sta $fc
    lda #<$7f2
    sta $fd
    lda #>$7f2
    sta $fe
    lda #251
    sta $ff
    jsr setmemory

    jsr clearbitmapscreen
    jsr clearscreen
    ; jmp sleep
skipcheckerboard:
    lda #1
    sta $903 ; skip count, move down 1 for every move right
    sta $905
spin:
    lda #1
    lda $903 ; load prev skip
    sta $906
    lda $905
    sta $903
    lda #1
    sta $901
    sta $902
    lda #0
    sta drawmode
    jsr plotloop

    lda #0
    sta charcounter
wordloop:
    ldx charcounter
    lda TEXT,X ; letter
    cmp #0
    beq wordend
    sta plotcharcode
    lda #10
    sta plotcharrow
    lda movingcol
    adc charcounter
    sta plotcharcol
    inc charcounter
    jsr plotchar 
    jmp wordloop
wordend:

    inc movingscroll
    lda movingscroll 
    cmp #8
    bne noset7
    lda #0
    sta movingscroll
    inc movingcol
    lda movingcol
    cmp #40
    bne wordfinal
    lda #5
    sta movingcol
noset7:
    sta $d016


wordfinal:

    lda $906
    sta $903 ; put back orig skip
    lda #1
    sta $901
    sta $902
    lda #1
    sta drawmode
    jsr plotloop
    jsr dowait
    lda $903
    sta $905 ; save last skip
    inc $903
    lda $903
    cmp #10
    beq resetskip
    jmp spin
resetskip
    lda #1
    sta $903
    jmp spin

dowait:
    lda #$ff
    cmp $d012
    bne dowait
    rts

plotchar:
    ; memcopy: $fb is lower from byte, $fc is upper from byte, $fd is lower to byte, $fe is upper to byte, $ff is number of bytes to copy
    clc
    ; lda #<$4000
    lda #<CHARS
    sta $fb
    ; lda #>$4000
    lda #>CHARS
    sta $fc

    ; add the char number times 8 bytes
    asl plotcharcode
    asl plotcharcode
    asl plotcharcode

    ; handle overflow
    lda $fc
    adc #0
    sta $fc
    ;;;;;;;;;;;;;

    lda $fb
    adc plotcharcode
    sta $fb
    lda $fc
    adc #0
    sta $fc
    
    asl plotcharrow
    ldx plotcharrow
    
    lda plotcharlines,X
    ; lda #<$2140
    sta $fd
    lda plotcharlines+1,X
    ; lda #>$2140
    sta $fe

    clc
    asl plotcharcol
    asl plotcharcol
    asl plotcharcol
    lda $fd
    adc plotcharcol
    sta $fd
    lda $fe
    adc #0
    sta $fe

    lda #8
    sta $ff
    jsr memcopy
    rts

sleep:
    ; debug
    ; stx $913
    ; jsr printbyte
    jmp sleep

setmemory: ; $fb is lower start byte, $fc is upper start byte, $fd is lower stop byte, $fe is upper stop byte, $ff is value to set
setmemoryloop:
    lda $ff
    ldy #0
    sta ($fb),Y
; next logic
    ; 50 NEXT
    clc
    lda $fb
    adc #1
    sta $fb
    lda $fc
    adc #0
    sta $fc
    clc
    cmp $fe
    bne setmemoryloop
    lda $fb
    cmp $fd
    beq setmemorypast
    jmp setmemoryloop

setmemorypast:
    rts


memcopy: ; $fb is lower from byte, $fc is upper from byte, $fd is lower to byte, $fe is upper to byte, $ff is number of bytes to copy
    ldy #255
    ldx #0
memcopyloop:
    iny
    lda ($fb),Y
    sta ($fd),Y
; next logic
    cpy $ff
    bne memcopyloop
    rts

plotloop:
    lda #0
    sta $904
plotloopinner:
    clc
    lda $901 ; just in case plotPoint messes with pointX,pointY -- remove this hack later for speed
    sta pointX
    lda #0
    sta pointX+1
    lda $902
    sta pointY
    jsr plotPoint
    lda $904 ; count of skip count
    cmp $903
    beq doincx
    inc $904
afterdoincx:
    inc $902
    lda $902
    cmp #200
    bne plotloopinner
    rts

doincx:
    inc $901
    lda #0
    sta $904 ; reset skip count
    jmp afterdoincx

clearscreen:
    ; clear the screen
    lda #$00
    ; sta $d016 ; reset horizontal scroll
    sta $d020 ; clear screen
    sta $d021
    tax
    ; lda #$20
    lda #%11110000
clearloop:
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    dex
    bne clearloop
    rts
    
clearbitmapscreen:
    lda #<$2000
    sta $fb
    lda #>$2000
    sta $fc
    lda #<$3f3f
    sta $fd
    lda #>$3f3f
    sta $fe
    lda #0
    sta $ff
    jsr setmemory
    ldx #0
    rts

printbyte:
    stx $910
    sta $911
    lda #$00 ; print to screen
    ldx $913 ;
    jsr $bdcd
    lda $911
    ldx $910
    rts


    ; org $4000
pointX =*                   ;0-319
    .word 100

pointY =*                   ;0-199
    .byte 100

drawmode =*                 ;0 = erase point, 1 =set point
    .byte 1

; screen = $2000              ;for example
screen = 8192              ;for example
dest = $fb



;--------------

plotPoint =*
    ; rts ;;;;;;;;;;;;;;;;;;;;;;;;;;; remove

    ;-------------------------
    ;calc Y-cell, divide by 8
    ;y/8 is y-cell table index
    ;-------------------------
    lda pointY
    lsr                         ;/ 2
    lsr                         ;/ 4
    lsr                         ;/ 8
    tay                         ;tbl_8,y index

    ;------------------------
    ;calc X-cell, divide by 8
    ;divide 2-byte pointX / 8
    ;------------------------
    ror pointX+1                ;rotate the high byte into carry flag
    lda pointX
    ror                         ;lo byte / 2 (rotate C into low byte)
    lsr                         ;lo byte / 4
    lsr                         ;lo byte / 8
    tax                         ;tbl_8,x index

    ;----------------------------------
    ;add x & y to calc cell point is in
    ;----------------------------------
    clc

    
    lda tbl_vbaseLo,y           ;table of screen row base addresses
    adc tbl_8Lo,x               ;+ (8 * Xcell)
    sta dest                    ;= cell address

    lda tbl_vbaseHi,y           ;do the high byte
    adc tbl_8Hi,x
    sta dest+1

    ;---------------------------------
    ;get in-cell offset to point (0-7)
    ;---------------------------------
    lda pointX                  ;get pointX offset from cell topleft
    and #%00000111              ;3 lowest bits = (0-7)
    tax                         ;put into index register

    lda pointY                  ;get pointY offset from cell topleft
    and #%00000111              ;3 lowest bits = (0-7)
    tay                         ;put into index register
    
    ;----------------------------------------------
    ;depending on drawmode, routine draws or erases
    ;----------------------------------------------

    lda drawmode                ;(0 = erase, 1 = set)
    beq erase                   ;if = 0 then branch to clear the point

    ;---------
    ;set point
    ;---------
    lda (dest),y                ;get row with point in it
    ora tbl_orbit,x             ;isolate and set the point
    sta (dest),y                ;write back to screen
    jmp past                    ;skip the erase-point section

    ;-----------
    ;erase point
    ;-----------
erase =*                    ;handled same way as setting a point
    lda (dest),y                ;just with opposite bit-mask
    and tbl_andbit,x            ;isolate and erase the point
    sta (dest),y                ;write back to screen
    
past =*
    rts

;----------------------------------------------------------------

tbl_vbaseLo =*
    .byte <(screen+(0*320)),<(screen+(1*320)),<(screen+(2*320)),<(screen+(3*320))
    .byte <(screen+(4*320)),<(screen+(5*320)),<(screen+(6*320)),<(screen+(7*320))
    .byte <(screen+(8*320)),<(screen+(9*320)),<(screen+(10*320)),<(screen+(11*320))
    .byte <(screen+(12*320)),<(screen+(13*320)),<(screen+(14*320)),<(screen+(15*320))
    .byte <(screen+(16*320)),<(screen+(17*320)),<(screen+(18*320)),<(screen+(19*320))
    .byte <(screen+(20*320)),<(screen+(21*320)),<(screen+(22*320)),<(screen+(23*320))
    .byte <(screen+(24*320))

tbl_vbaseHi =*
    .byte >(screen+(0*320)),>(screen+(1*320)),>(screen+(2*320)),>(screen+(3*320))
    .byte >(screen+(4*320)),>(screen+(5*320)),>(screen+(6*320)),>(screen+(7*320))
    .byte >(screen+(8*320)),>(screen+(9*320)),>(screen+(10*320)),>(screen+(11*320))
    .byte >(screen+(12*320)),>(screen+(13*320)),>(screen+(14*320)),>(screen+(15*320))
    .byte >(screen+(16*320)),>(screen+(17*320)),>(screen+(18*320)),>(screen+(19*320))
    .byte >(screen+(20*320)),>(screen+(21*320)),>(screen+(22*320)),>(screen+(23*320))
    .byte >(screen+(24*320))

tbl_8Lo =*
    .byte <(0*8),<(1*8),<(2*8),<(3*8),<(4*8),<(5*8),<(6*8),<(7*8),<(8*8),<(9*8)
    .byte <(10*8),<(11*8),<(12*8),<(13*8),<(14*8),<(15*8),<(16*8),<(17*8),<(18*8),<(19*8)
    .byte <(20*8),<(21*8),<(22*8),<(23*8),<(24*8),<(25*8),<(26*8),<(27*8),<(28*8),<(29*8)
    .byte <(30*8),<(31*8),<(32*8),<(33*8),<(34*8),<(35*8),<(36*8),<(37*8),<(38*8),<(39*8)

tbl_8Hi =*
    .byte >(0*8),>(1*8),>(2*8),>(3*8),>(4*8),>(5*8),>(6*8),>(7*8),>(8*8),>(9*8)
    .byte >(10*8),>(11*8),>(12*8),>(13*8),>(14*8),>(15*8),>(16*8),>(17*8),>(18*8),>(19*8)
    .byte >(20*8),>(21*8),>(22*8),>(23*8),>(24*8),>(25*8),>(26*8),>(27*8),>(28*8),>(29*8)
    .byte >(30*8),>(31*8),>(32*8),>(33*8),>(34*8),>(35*8),>(36*8),>(37*8),>(38*8),>(39*8)

tbl_orbit =*
    .byte %10000000
    .byte %01000000
    .byte %00100000
    .byte %00010000
    .byte %00001000
    .byte %00000100
    .byte %00000010
    .byte %00000001

tbl_andbit =*
    .byte %01111111
    .byte %10111111
    .byte %11011111
    .byte %11101111
    .byte %11110111
    .byte %11111011
    .byte %11111101
    .byte %11111110

plotcharcode .byte #0
plotcharrow .byte #0
plotcharcol .byte #0
charcounter .byte #0
movingcol .byte #1
movingscroll .byte #0
plotcharlines    .word $2000,$2140,$2280,$23c0,$2500,$2640,$2780,$28c0,$2a00,$2b40,$2c80,$2dc0,$2f00,$3040,$3180,$32c0,$3400,$3540,$3680,$37c0,$3900,$3a40,$3b80,$3cc0,$3e00
TEXT        .byte  32,8,1,16,16,25,32,8,1,12,12,15,23,5,5,14,32,0
; TEXT        .byte  32,1,2,3,4,5,6,7,8,9,10,11,12,24,25,26,27,28,29,30,31,32,33,34,35,36,0

;    org $4000
CHARS = *
    ;    INCBIN "c64-chars.bin"
        INCBIN "aeg_collection_06.64c"

