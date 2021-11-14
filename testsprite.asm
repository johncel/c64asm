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

changepos:
    lda $d41b ; random x position
    sta $d000
    lda $d41b ; random y position
    sta $d001
    lda #0
    sta $900
    jmp wait

incxincy:
    inc $d000
    inc $d001
    jmp wait
incxdecy:
    inc $d000
    dec $d001
    jmp wait
decxincy:
    dec $d000
    inc $d001
    jmp wait
decxdecy:
    dec $d000
    dec $d001
    jmp wait


loop:
    ; lda $d000
    ; cmp 150
    ; beq reset
    ; inc $d000
    inc $900 ; counter for staying in same position
    lda $900
    cmp #50  ; wait between jumps
    beq changepos
    lda $d41b  ; random move left of right
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
    jmp wait

    
    ; inc $d000
    ; dec $d001
    ; jmp wait
	; jmp loop

wait:
    lda #$ff
    cmp $d012
    bne wait
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
