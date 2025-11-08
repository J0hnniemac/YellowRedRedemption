;player 2 ai


; if player 1 is above you by more than 5 then start to move up 
; if he has fired a bullet then change direction
; if player 1 is below you by more than 5 then start to down up 



controlP2
	
	ld hl,p1Pos
	ld a,(hl)
	add a,22 
	ld hl,p2Pos
	ld b,(hl)


	sub b 

	
	jp c,.p1isabove 


	ld hl,p2Pos
	ld a,(hl)
	add a,22 
	ld hl,p1Pos
	ld b,(hl)


	sub b 

	
	jp c,.p1isbellow 






	
	jp .endcontrolP2
.p1isabove
; add some randomness
	;call p2Up
	ld a,aiMOVEDIRUP
	ld (aiMoveDirection),a

	
	jp .endcontrolP2

.p1isbellow 

	; add some randomness
	ld a,aiMOVEDIRDOWN
	ld (aiMoveDirection),a
	;call p2Down
	
	jp .endcontrolP2




.endcontrolP2


	call random

	and %00000001

	cp 1 

	jp z, .nochanges
	ld a,aiMOVEDIRSTOP
	ld (aiMoveDirection),a


	call random

	and %0000001

	cp 1 

	jp z, .nochanges



	call p2Fire

.nochanges	

	ret



aiMove 
	ld a,(aiMoveDirection)
	cp aiMOVEDIRUP
	jp z, .moveup 

	ld a,(aiMoveDirection)
	cp aiMOVEDIRDOWN
	jp z, .movedown

	jp .aiMoveEnd

.moveup 
	call p2Up

	jp .aiMoveEnd
.movedown 
	call p2Down

.aiMoveEnd
	ret 




;-----> Generate a random number
; output a=answer 0<=a<=255
; all registers are preserved except: af
random:
        push    hl
        push    de
        ld      hl,(randData)
        ld      a,r
        ld      d,a
        ld      e,(hl)
        add     hl,de
        add     a,l
        xor     h
        ld      (randData),hl
        pop     de
        pop     hl
        ret




