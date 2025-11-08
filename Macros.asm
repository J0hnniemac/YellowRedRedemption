       	MACRO SetAY
              ld bc,TURBO_SOUND_CONTROL
              or %11111100
              out (c), a
       	ENDM


;-----------------------------------
;------ Generic helper macros ------
;-----------------------------------
;-----------
;   hl = origin x/y
;   de = end x/y
;----------
	MACRO SetLayer2Clip
	        ld a,CLIP_WINDOW_REGISTER
	        ld bc,TBBLUE_REGISTER_SELECT
	        out (c),a
	        inc b
	        out (c),h
	        out (c),d
	        out (c),l
	        out (c),e
        ENDM
;-----------
;   hl = origin x/y
;   de = end x/y
;----------
	MACRO SetLoResClip
	        ld a,CLIP_LORES_REGISTER
	        ld bc,TBBLUE_REGISTER_SELECT
	        out (c),a
	        inc b
	        out (c),h
	        out (c),d
	        out (c),l
	        out (c),e

        ENDM
;-----------
;   hl = origin x/y
;   de = end x/y
;----------
	MACRO SetSpriteClip
	        ld a,CLIP_SPRITE_REGISTER
	        ld bc,TBBLUE_REGISTER_SELECT
	        out (c),a
	        inc b
	        out (c),h
	        out (c),d
	        out (c),l
	        out (c),e
        ENDM
;------------
	MACRO SetNormal
		xor a
		NEXTREG_A TURBO_CONTROL_REGISTER
	ENDM

	MACRO Set7mhz
		ld a,%01
		NEXTREG_A TURBO_CONTROL_REGISTER
	ENDM

	MACRO Set14mhz
		ld a,%10
		NEXTREG_A TURBO_CONTROL_REGISTER
	ENDM

	MACRO Set28mhz				; not implemented currently
		ld a,%11
		NEXTREG_A TURBO_CONTROL_REGISTER
	ENDM

;---------------------
; set active sprite number
; destroys BC
;---------------------
	MACRO SelectSprite_A
		ld bc,SPRITE_STATUS_SLOT_SELECT
		out (c),a
	ENDM

	MACRO SelectSprite_H
		ld bc,SPRITE_STATUS_SLOT_SELECT
		out (c),h
	ENDM

	; a = sprite to turn off
	MACRO TurnSpriteOff
		push bc
		ld bc,SPRITE_STATUS_SLOT_SELECT
		out (c),a	; select sprite
		xor a
		ld bc,$0057
		out (c),a:out (c),a:out (c),a:out (c),a
		pop bc
	ENDM

	MACRO SetLayer2XOffset
		NEXTREG_A LAYER2_XOFFSET_REGISTER
	ENDM

	MACRO SetLayer2YOffset
		NEXTREG_A LAYER2_YOFFSET_REGISTER
	ENDM

	MACRO SetLowResXOffset
		NEXTREG_A LORES_XOFFSET_REGISTER
	ENDM

	MACRO SetLowResYOffset
		NEXTREG_A LORES_YOFFSET_REGISTER
	ENDM

	MACRO ClearULA
		ld hl,ZX_SCREEN
		ld de,ZX_SCREEN + 1
		ld bc,$1800
		ld (hl),l
		call TransferDMA
	ENDM

	MACRO ClearLORES
		ld hl,LORES_MEM_1
		ld de,LORES_MEM_1 + 1
		ld bc,$1800
		ld (hl),l
		call TransferDMA

		ld hl,LORES_MEM_2
		ld de,LORES_MEM_2
		ld bc,$1800
		ld (hl),l
		call TransferDMA
	ENDM


	MACRO ClearAttributes_A
        	ld hl,ZX_ATTRIB
        	ld de,ZX_ATTRIB + 1
		ld bc,$2ff
		ld (hl),a
		call TransferDMA
	ENDM

	MACRO SetBorder
		out (254),a
	ENDM

	MACRO SetLoResBorder
	    NEXTREG_nn PALETTE_INDEX_REGISTER, 128
	    NEXTREG_A PALETTE_VALUE_REGISTER
	ENDM

	MACRO Layer2Off
	        ld bc, LAYER2_ACCESS_PORT
	        xor a
	        out (c),a
        ENDM

	MACRO Force50hz
		ld a,PERIPHERAL_1_REGISTER
	        ld bc,TBBLUE_REGISTER_SELECT
	        out (c),a
	        inc b
		in a,(c):res 2,a:out (c),a
	ENDM

;-----------------------------------
;------  ED Enhanced Opcodes  ------
;-----------------------------------
; Set Next hardware register using A
	MACRO NEXTREG_A register
	dw $92ED
	db register
	ENDM
; Set Next hardware register using an immediate value
	MACRO NEXTREG_nn register, value
	dw $91ED
	db register
	db value
	ENDM

; As LDI, if byte == A then skips byte. HL=Source, DE=Dest, BC=Count, A=Mask
	MACRO LDIX: dw $A4ED:ENDM
; As LDIR, if byte == A then Skips byte
	MACRO LDIRX: dw $B4ED: ENDM

	
; as LDD, except DE++ and if byte == A then skips byte.
	MACRO LDDX: dw $ACED: ENDM
; as LDDR, except DE++ and if byte == A then skips byte.
	MACRO LDDRX: dw $BCED: ENDM
; As LDIRX but instead of HL <= HL +1... L (2 downto 0) = E then get byte (hl) and if !=A ld (de),a then always inc de loop bc
	MACRO LDPIRX: dw $B7ED: ENDM
; as LDIR but 24 bit source pointer HLA' takes high 16 bits as address
	MACRO LDIRSCALE: dw $B6ED: ENDM				; not implemented
; DE = Y/X, returns HL as address in screen data
	MACRO pixelad: dw $94ED: ENDM
; Moves HL down one line in ULA
	MACRO pixeldn: dw $93ED: ENDM
; DE = Y/X, returns correct bit pattern for pixel in A
	MACRO setae: dw $95ED: ENDM
; D*E = DE
	MACRO MUL_DE:dw $30ED: ENDM
; HL+A = HL
	MACRO ADD_HL_A: dw $31ED: ENDM
; DE+A = DE
	MACRO ADD_DE_A: dw $32ED: ENDM
; BC+A = BC
	MACRO ADD_BC_A: dw $33ED: ENDM
; HL = HL+$XXXX
	MACRO ADD_HL_nnnn data: dw $34ED: dw data: ENDM
; DE = DE+$XXXX
	MACRO ADD_DE_nnnn data: dw $35ED: dw data: ENDM
; BC = BC+$XXXX
	MACRO ADD_BC_nnnn data: dw $36ED: dw data: ENDM
; Swap A bits 7-4 with A bits 3-0
	MACRO SWAPNIB:dw $23ED: ENDM
; Mirror bits of A, bit 0 goes to bit 7, 7 to 0 etc.
	MACRO MIRROR_A: dw $24ED: ENDM
; Mirror bits of DE, bit 0 goes to bit 15, 15 to 0 etc.
	MACRO MIRROR_DE: dw $26ED: ENDM
; Push 16 bit immediate value onto the stack
	MACRO PUSH_nnnn data: dw $8AED: dw data: ENDM
; ANDs A with $XX, sets flags but doesn't store the result in A
	MACRO TEST_nn data: dw $27ED: dw data: ENDM

;----------------CSpect Macros
; Trigger break (use -brk in command line)
	MACRO BREAK: 	db $DD,01: ENDM
; Exit CSPect (use -exit in command line)
	MACRO EXIT: 	dw $00DD: ENDM


;AUDIO STUFF

	MACRO	PLAY_AFX_FRAME
	ld a, AY_SFX
	SetAY
	call AFXFRAME
	ENDM


	MACRO	PLAY_TRACK
        ld a,(MusicOn)
        dec a
        jr nz,.noMusic
	ld a, AY_MUSIC1
	SetAY
	call PT3Play
.noMusic
	ENDM

SFX_PLAYER_JUMP EQU 0
SFX_BANANA_PICK	EQU 1
SFX_SHIPPA_PICK EQU 2
SFX_CONVEY_RUMB	EQU 3
SFX_CANNON_RUMB EQU 4
SFX_CANNON_FIRE	EQU 5
SFX_LASERS_CRAC	EQU 6
SFX_DOOR_OPEN EQU 7	
SFX_BLANK EQU 9	


	MACRO 	PLAY_SFX_PLAYER_JUMP  
		push af	
		exx
		ld a,AY_SFX
		SetAY
		ld a,SFX_PLAYER_JUMP
		call AFXPLAY
		exx
		pop af
	ENDM



	MACRO 	PLAY_SFX_BANANA_PICK
		push af 
		exx
		ld a,AY_SFX
		SetAY
		ld a,SFX_BANANA_PICK
		call AFXPLAY
		exx
		pop af
	ENDM

	MACRO	PLAY_SFX_LASERS_CRAC
		push ix 
		push af 
		exx
		ld a,AY_SFX
		SetAY
		ld a,SFX_LASERS_CRAC
		call AFXPLAY
		exx
		pop af
		pop ix 
	ENDM
	MACRO	PLAY_SFX_CANNON_RUMB 
		push ix
		push af 
		exx
		ld a,AY_SFX
		SetAY
		ld a,SFX_CANNON_RUMB
		call AFXPLAY
		exx
		pop af
		pop ix 
	ENDM
	MACRO 	PLAY_SFX_DOOR_OPEN
		push af 
		exx
		ld a,AY_SFX
		SetAY
		ld a,SFX_DOOR_OPEN
		call AFXPLAY
		exx
		pop af
	ENDM

	MACRO	PLAY_SFX_BLANK 
		push ix
		push af 
		exx
		ld a,AY_SFX
		SetAY
		ld a,SFX_BLANK
		call AFXPLAY
		ld a,AY_SFX
		SetAY
		ld a,SFX_BLANK
		call AFXPLAY
		ld a,AY_SFX
		SetAY
		ld a,SFX_BLANK
		call AFXPLAY
		exx
		pop af
		pop ix 
	ENDM

	


	MACRO SAVEBANKS
	

	ld bc, $243b
        ld a, $56
        out (c),a 
        ld bc, $253b
        in a,(c)
        push af ; save a

        ld bc, $243b
        ld a, $57
        out (c),a 
        ld bc, $253b
        in a,(c)
        push af ; save a

        ENDM
        MACRO RESTOREBANKS
        pop af
        NEXTREG_A BANK_TO_E000

        pop af        ;ld a,0
        NEXTREG_A BANK_TO_C000
        ENDM





	MACRO SAVEMUSICBANKS
	ld bc, $243b
        ld a, $56
        out (c),a 
        ld bc, $253b
        in a,(c)
        
        ld (mb1),a

        ld bc, $243b
        ld a, $57
        out (c),a 
        ld bc, $253b
        in a,(c)
        
        ld (mb2),a

        ENDM

        MACRO RESTOREMUSICBANKS
        ld a ,(mb2)
        NEXTREG_A BANK_TO_E000
        ld a ,(mb1)
        NEXTREG_A BANK_TO_C000
        ENDM



	MACRO SAVEBANKSMEM
	push bc 
	push af


	ld bc, $243b
        ld a, $56
        out (c),a 
        ld bc, $253b
        in a,(c)
        
        ld (mem1),a

        ld bc, $243b
        ld a, $57
        out (c),a 
        ld bc, $253b
        in a,(c)
        
        ld (mem2),a

        pop af 
        pop bc 


        ENDM

        MACRO RESTOREBANKSMEM
        push af

        ld a ,(mem2)
        NEXTREG_A BANK_TO_E000
        ld a ,(mem1)
        NEXTREG_A BANK_TO_C000
        pop af 


        ENDM

