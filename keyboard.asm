;keyboard
;utils

;Stolen from Mike Dailly
; ******************************************************************************
; Function: Scan the whole keyboard
; ******************************************************************************
ReadKeyboard:
        push hl
        push de
        push bc
        ld c,0
        ld  b,39
        ld  hl,Keys
        xor a
_lp1       
        ld  (hl),a
        inc hl
        djnz    _lp1


        ld  ix,Keys
        ld  bc,$fefe    ;Caps,Z,X,C,V
        ld  hl,RawKeys
_ReadAllKeys:   in  a,(c)
        ld  (hl),a
        inc hl      
        
        ld  d,5
        ld  e,$ff
_DoAll:     srl a
        jr  c,_notset
        ld  (ix+0),e
_notset:    inc ix
        dec d
        jr  nz,_DoAll

        ld  a,b
        sla a
        jr  nc,ExitKeyRead
        or  1
        ld  b,a
        jp  _ReadAllKeys
ExitKeyRead:
        pop bc
        pop de
        pop hl

        ret


; half row 1
VK_CAPS     equ $00
VK_Z        equ $01
VK_X        equ $02
VK_C        equ $03
VK_V        equ $04
; half row 2
VK_A        equ $05
VK_S        equ $06
VK_D        equ $07
VK_F        equ $08
VK_G        equ $09
; half row 3
VK_Q        equ $0A
VK_W        equ $0B
VK_E        equ $0C
VK_R        equ $0D
VK_T        equ $0E
; half row 4
VK_1        equ $0F
VK_2        equ $10
VK_3        equ $11
VK_4        equ $12
VK_5        equ $13

; half row 5
VK_0        equ $14
VK_9        equ $15
VK_8        equ $16
VK_7        equ $17
VK_6        equ $18
; half row 6
VK_P        equ $19
VK_O        equ $1A
VK_I        equ $1B
VK_U        equ $1C
VK_Y        equ $1D

; half row 7
VK_ENTER    equ $1E
VK_L        equ $1F
VK_K        equ $20
VK_J        equ $21
VK_H        equ $22
; half row 8
VK_SPACE    equ $23
VK_SYM      equ $24
VK_M        equ $25
VK_N        equ $26
VK_B        equ $27

        display "KEYS = ",/D,$
Keys:       ds  40
RawKeys     ds  8
