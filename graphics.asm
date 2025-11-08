;graphics.asm
loadBMPFromBank
	;a = startBank
	push hl 
	push de 
	push bc
	

	push af
	SAVEBANKSMEM
	pop af 
	add a,a  ; bank
    	NEXTREG_A BANK_TO_C000
    	inc a
    	NEXTREG_A BANK_TO_E000
	push af  

    	ld a,3
	ld bc, $123b
	out (c), a
	

	ld hl,$C000
	ld de,$0000
	ld bc,$4000
	;ldir 
	call TransferDMA


	pop af
	inc a
    	NEXTREG_A BANK_TO_C000
    	inc a
    	NEXTREG_A BANK_TO_E000
	push af  

    	ld a,3+64
	ld bc, $123b
	out (c), a
	

	ld hl,$C000
	ld de,$0000
	ld bc,$4000
	;ldir 
	call TransferDMA


	pop af
	inc a
    	NEXTREG_A BANK_TO_C000
    	inc a
    	NEXTREG_A BANK_TO_E000
   	ld a,3+64+64
	ld bc, $123b
	out (c), a
	

	ld hl,$C000
	ld de,$0000
	ld bc,$4000
	;ldir 
	call TransferDMA
	

	RESTOREBANKSMEM
	pop bc 
	pop de 
	pop hl

	ret



loadSprites
	
	SAVEBANKSMEM

	ld a, SPRITEBANK
	add a,a //multiply by 2
    	NEXTREG_A BANK_TO_C000
    	inc a
    	NEXTREG_A BANK_TO_E000
    	
	ld hl, $C000     
	ld a, 0     

.loadanother
 	ld      bc, $303B
	out     (c),a
	push    af
	ld      de, 256
	ld      bc, SPRITE_INFO_PORT
                
.UpLoadSprite        
	 
        outi            ; port=(hl), hl++, b--
        inc b       ; 4 = 20

        dec     de
        ld      a,d
        or      e               
        jr      nz, .UpLoadSprite

        pop     af
        inc     a
        cp      64
        jr      nz,.loadanother
	


        RESTOREBANKSMEM
       

	ret


;p1GunUpTileID = 3
;p1GunHorTileID = 19
;p1GunDownTileID = 23
;--------------------------------
; hl = source
; bc = length
;--------------------------------
;TransferDMASprite
;de d = destination sprite, e = source tile 



updateSpriteWithTile
	SAVEBANKSMEM

	ld a, SPRITEBANK
	add a,a //multiply by 2
    	NEXTREG_A BANK_TO_C000
    	inc a
    	NEXTREG_A BANK_TO_E000
    	;BREAK
	ld hl, $C000     

	ld a,e

	or h
	ld h,a
	;hl = source tile 

	ld a,d ; sprite 
	

	ld      bc, $303B
	out     (c),a ; sprite selected 

	ld bc,256
	call TransferDMASprite




	RESTOREBANKSMEM

	ret

updateSpriteWithTilex
	SAVEBANKSMEM

	ld a, SPRITEBANK
	add a,a //multiply by 2
    	NEXTREG_A BANK_TO_C000
    	inc a
    	NEXTREG_A BANK_TO_E000
    	;BREAK
	ld hl, $C000     

	ld a,3

	or h
	ld h,a
	;hl = source tile 

	ld a,p1BRSprite ; sprite 
	

	ld      bc, $303B
	out     (c),a
	
	ld      de, 256
	ld      bc, SPRITE_INFO_PORT
                
.UpLoadSpritex        
	 
        outi            ; port=(hl), hl++, b--
        inc b       ; 4 = 20

        dec     de
        ld      a,d
        or      e               
        jr      nz, .UpLoadSpritex





	RESTOREBANKSMEM

	ret

drawWagonSprite




	



	ret







makeAllSpritesVisible
 
  ld bc, $243b
  ld a, 21
  out (c), a

  ;OUT 0x253B, 1; REM All sprites visible
  ld bc, $253b
  ld a, 1
  out (c), a

  ret


makeAllSpritesInVisible

 
  ld bc, $243b
  ld a, 21
  out (c), a

  ;OUT 0x253B, 1; REM All sprites visible
  ld bc, $253b
  ld a, 0
  out (c), a

  ret




;de = x,y a, sprite, h = rotation
;position start at top left 32,32
showspriteL2
  ;BREAK
  push af 
  ld l,0 ; default sprite <255
  ld a,d
  add 24
  jp nc, .addOK

  ld a,d
  sub 232
  
  ld d,a
  ld l,1 ;set flag !!!
  
  jr .adjustedX2


.addOK
  ld a,d
  add a,24  
  ld d,a 

  ;
.adjustedX2


  ld a,e
  add a,24  
  ld e,a 

  pop af
  push af
    
  ld bc, $303b
  
  out (c), a ; select sprite
  ld bc, $57
  ;  ld a, d; xpos >>> 

  out (c), d ; xpos

    ;ld a,e 
    

    ;ld a, e ; ypos ? --- 32 upper ->>>
  out (c), e ; ypos
    ;pop af
  ld a, l ; 7-4 is palette offset, bit 3 is X mirror, bit 2 is Y mirror, bit 1 is rotate flag and bit 0 is X MSB. 
    ; 8 flip x 4 flipy 2 rotate 1 msb
  ;add a,h
  out (c), a
  pop af
  or 128
    ;ld a, 137 ; spite visible pattern 0 ??? ;;128 = 0
  out (c), a

  
  ret 





testCart:
  
  ld a,cartTLSprite
  push af
  ld bc, $303b
  out (c), a ; select sprite 
  ld bc, $57
  ld a, (cartTLPos) ; xpos >>> 32 on boarder ->>
  out (c), a
  ld a, 0 ; ypos ? --- 32 upper ->>>
  out (c), a
  ld a, 0 ; 7-4 is palette offset, bit 3 is X mirror, bit 2 is Y mirror, bit 1 is rotate flag and bit 0 is X MSB. 
  ;ld a, MMRIGHT
  ld e, a
  ld a, (cartTLPos+1)
  add a,e 

  ; 8 flip x 4 flipy 2 rotate 1 msb
  out (c), a
  pop af
  xor 128
  ;ld a, 137 ; spite visible pattern 0 ??? ;;128 = 0
  out (c), a

  
  ret   





updateP1Sprites


		ld de,(p1Pos)

		ld a, p1TLSprite
		call showspriteL2



		ld de,(p1Pos)
		ld a,16
		add e
		ld e,a

		ld a, p1BLSprite
		call showspriteL2


		ld de,(p1Pos)
		ld a,16
		add d
		ld d,a
		ld a,16
		add e
		ld e,a

		ld a, p1BRSprite
		call showspriteL2


	ret



updateP1BulletSprite

		ld de,(bulletP1pos)

		ld a, p1BulletSprite 
		
		call showspriteL2

	ret
updateP2BulletSprite

		ld de,(bulletP2pos)

		ld a, p2BulletSprite 
		
		call showspriteL2

	ret

updateP2SpritesRIP



		ld de,(p2Pos)

		ld a, p2TRSprite
;		call showspriteL2



		ld de,(p2Pos)
		ld a,16
		add d
		ld d,a

		ld a, p2TRRSprite ;p2TRRSprite
		call showspriteL2





		ld de,(p2Pos)
		ld a,16
		add e
		ld e,a

		ld a, p2BRSprite
		call showspriteL2


		ld de,(p2Pos)
		ld a,-16
		add d
		ld d,a
		ld a,16
		add e
		ld e,a

		ld a, p2BLSprite
		call showspriteL2


	ret


updateP2Sprites


		ld de,(p2Pos)

		ld a, p2TRSprite
		call showspriteL2



		ld de,(p2Pos)
		ld a,16
		add d
		ld d,a

		ld a, p2TRRSprite ;p2TRRSprite
		call showspriteL2





		ld de,(p2Pos)
		ld a,16
		add e
		ld e,a

		ld a, p2BRSprite
		call showspriteL2


		ld de,(p2Pos)
		ld a,-16
		add d
		ld d,a
		ld a,16
		add e
		ld e,a

		ld a, p2BLSprite
		call showspriteL2


	ret



updateCartSprite

		;de = x,y a, sprite, h = rotation
;position start at top left 32,32


		;TL
		ld de,(cartPos)
		ld a, cartTLSprite
		call showspriteL2



		;TR
		ld de,(cartPos)
		ld a,16
		add a,d 
		ld d,a
		ld a, cartTRSprite
		call showspriteL2
		

		;ML
		ld de,(cartPos)
		ld a,16 
		add a,e 
		ld e,a
		ld a, cartMLSprite
		call showspriteL2
		
		;MR
		ld de,(cartPos)
		ld a,16
		add a,e 
		ld e,a

		ld a,16 
		add a,d 
		ld d,a


		ld a, cartMRSprite
		call showspriteL2


		;BL
		ld de,(cartPos)
		ld a,16+16 
		add a,e 
		ld e,a
		ld a, cartBLSprite
		call showspriteL2


		;BR
		ld de,(cartPos)
		ld a,16+16 
		add a,e 
		ld e,a

		ld a,16
		add a,d 
		ld d,a

		ld a, cartBRSprite
		call showspriteL2



	ret





checkP1bulletSprite


	ld a,(p2Pos+1); p2 xpos
	add a, 14 ; >> ; 
	ld b,a ; b = xstart of collision box  
	ld a,(bulletP1pos+1) ; xpos

	sub b 

	jp nc, .checkYBottom
	; bullet reachs player then value returned will be negative
	jp .endcheckP1bulletSprite
.checkYBottom
	;yBottom

	ld a,(bulletP1pos); y xpos
	ld b,a ; b = xstart of collision box  
	ld a,(p2Pos) ; xpos
	add a, 31; >> ; 

	sub b 
	jp nc, .checkYTop
	; bullet reachs player then value returned will be negative
	jp .endcheckP1bulletSprite


.checkYTop

	ld a,(bulletP1pos); p2 
	ld b,a ; b = bullet  
	ld a,(p2Pos) ; pw

	sub b 
	jp c, .p2Hit
	; bullet reachs player then value returned will be negative
	jp .endcheckP1bulletSprite


.p2Hit

	call removeP1Bullet
	;do dead routine
	call p2Dead
	

.endcheckP1bulletSprite
	ret 


checkP1bulletL2

	ld  d,a ; d = ypos
	ld a,(bulletP1pos)
	sub 8
   	and %11000000
   	rra
   	rra
   	rra
   	rra
   	rra
   	rra
   	ld b,a ; L3 bank
 
	; is it top middle or bottom 


	ld a,(bulletP1pos)
	sub 8
 	and %00111111


	ld h,$C0

	or h
	ld h,a 
	ld a,(bulletP1pos+1)

	ld l,a



	SAVEBANKSMEM

	ld a,9
	add a,b
	add a,a
	NEXTREG_A BANK_TO_C000
	inc a 
	NEXTREG_A BANK_TO_E000
	
	dec hl
	dec hl
	dec hl
	dec hl

	ld a,(hl)
	cp 0
	jp z, .skipBreak
	
	ld (hl),0
	inc hl
	ld (hl),0
	inc hl
	ld (hl),0
	inc hl
	ld (hl),0
	;BREAK
	;NOP
	;BREAK
	;NOP
	call removeP1Bullet

	
.skipBreak

	RESTOREBANKSMEM


	ret

removeP1Bullet
	ld hl, p1BulletMoving
	ld a,0
	ld (hl),a
	;nedd to hide bullet too

	ld a, p1BulletSprite
	call hideSprite


	ret


checkScreenVal

	SAVEBANKSMEM
	ld a,9
	add a,a
	NEXTREG_A BANK_TO_C000
	inc a 
	NEXTREG_A BANK_TO_E000





	NEXTREG_A BANK_TO_E000
	

	RESTOREBANKSMEM



p2Dead

;	p2TRSprite = 1
;p2BRSprite = 17
;p2BLSprite = 16
;	8;
	;24,0

	;;p2BulletSprite
	ld d,p2TRSprite
	ld e,8 
	call updateSpriteWithTile


	ld d,p2BRSprite
	ld e,24 
	call updateSpriteWithTile
 

	ld d,p2BLSprite
	ld e,0 
	call updateSpriteWithTile

	ld d,p2TRRSprite
	ld e,9 
	call updateSpriteWithTile


	 

	call p2rip

	ret




resetP2Sprite
	ld d,p2TRSprite
	ld e,1
	call updateSpriteWithTile


	ld d,p2BRSprite
	ld e,17
	call updateSpriteWithTile
 

	ld d,p2BLSprite
	ld e,16
	call updateSpriteWithTile

	ld d,p2TRRSprite
	ld e,0 
	call updateSpriteWithTile



	ret


p2rip 

	call delay

	call resetP2Sprite
	ld a,p2TRSprite
	call hideSprite


	ld a,p2TRRSprite
	call hideSprite



	ld d,p2BLSprite
	ld e,10
	call updateSpriteWithTile

	

 

	ld d,p2BRSprite
	ld e,11
	call updateSpriteWithTile



	call delay 

	call moveRIP

	call resetP2Sprite

	ret


moveRIP




.moveup
		ld hl,p2Pos
		dec (hl)
		ld a,(hl)

		cp 230
		jp z, .endMoveRIP		

		call updateP2SpritesRIP
		halt

		jp .moveup
.endMoveRIP

	ret






delay
	LD BC, $0002            ;Loads BC with hex 1000
.Outer
	LD DE, $FFFF            ;Loads DE with hex 1000
.Inner
	DEC DE                  ;Decrements DE
	LD A, D                 ;Copies D into A
	OR E                    ;Bitwise OR of E with A (now, A = D | E)
	JP NZ, .Inner            ;Jumps back to Inner: label if A is not zero
	DEC BC                  ;Decrements BC
	LD A, B                 ;Copies B into A
	OR C                    ;Bitwise OR of C with A (now, A = B | C)
	JP NZ, .Outer            ;Jumps back to Outer: label if A is not zero
	RET                     ;Return from call to this subroutine

