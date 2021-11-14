 processor 6502
 org $1000

; inc $d021


loop:   inc $d020 ; increment BG color
        lda #$7f  ; check for space pressed
        sta $dc00 
        lda $dc01
        and #$10
        bne loop
