INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
    ;

Entry:
    di ; disable interrupts
    jp Start

REPT $150 - $104
    db 0
ENDR

SECTION "Code", ROM0

Start:
.frameWait:
    ld a, [rLY]
    cp 144
    jr c, .frameWait

    ; Write 0 into LCDC during V-Blank
    xor a
    ld [rLCDC], a

    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles

.copyFont:
    ; Copy byte from source into dest VRAM location, then increment (hli)
    ld a, [de]
    ld [hli], a

    ; Inc pos and dec count
    inc de
    dec bc

    ; Continue copying if count > 0
    ld a, b
    or c
    jr nz, .copyFont

    ld hl, $9800
    ld de, HelloWorld

.copyString:
    ; Copy string byte to hl and increment pos
    ld a, [de]
    ld [hli], a

    ; Check for null byte, otherwise continue copying
    inc de
    and a
    jr nz, .copyString

.Init
    ; Init display registers
    ; Palette
    ld a, %11100100
    ld [rBGP], a

    ; Scroll
    xor a
    ld [rSCY], a
    ld [rSCX], a

    ; Shut down sound
    ld [rNR52], a

    ; Turn screen on
    ld a, %10000001
    ld [rLCDC], a

.Infinite
    halt
    jr .Infinite



SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:


SECTION "Hello World", ROM0

HelloWorld:
    db "Hello World!", 0
