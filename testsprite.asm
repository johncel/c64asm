	processor	6502
	org	$1000
	
	lda #$80 ; location of sprite in memory... this is 2000, https://digitalerr0r.net/2011/03/31/commodore-64-programming-4-rendering-sprites/ explains
	sta $07f8
	lda #$01
	sta $d015
	lda #$80
	sta $d000
	sta $d001

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
	incbin "sprite2.spr"
