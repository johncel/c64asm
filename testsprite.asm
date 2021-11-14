	processor	6502
	org	$1000
	
	lda #$80 ; location of sprite in memory... this is 2000, https://digitalerr0r.net/2011/03/31/commodore-64-programming-4-rendering-sprites/ explains
	sta $07f8
	lda #$01
	sta $d015
	lda #$80
	sta $d000
	sta $d001
    lda #$1
    sta $d01c
    lda #%1
    sta $d027

reset:
    lda 0
    sta $d000
    jmp loop

wait:
    lda #$ff
    cmp $d012
    bne wait

loop:
    lda $d000
    cmp 150
    beq reset
    inc $d000
    jmp wait

	jmp loop

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
