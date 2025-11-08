tune = $C000
tunebank = 14	
tilebank = 15

DUNGEON1 = 19



		device zxspectrum48


		org $5c50
begin
		di
		ld sp,StackSpace			; set stack
		jp startprog

StackSpaceEnd		ds 127
StackSpace		db 0

startprog:
		INCLUDE "macros.asm"
		INCLUDE "defines.asm"


		jp starthere
		org $7878
		jp interrupt

		; then we need to set a memory vector with $78
		; we will put it at $79, that means we will load I with $79

		org $7900
IM2Table
		; Fill the vector with $78
		DS 257,$78

InitIM2
		di
		ld a,$79		; points to the vector containing $7878 etc
		ld i,a
		IM 2
		ei
		ret

interrupt:
		di

		push af
		push bc
		push de
		push hl
		push ix
		push iy
		ex af,af'
		push af
		;SAVEBANKSMEM1
		
		;RESTOREBANKSMEM1
		pop af
		ex af,af'
		pop iy
		pop ix
		pop hl
		pop de
		pop bc
		pop af
		ei
		reti




					; this is out track to play

		INCLUDE "dma.asm"
		INCLUDE "graphics.asm"
		INCLUDE "variables.asm"
		INCLUDE "keyboard.asm"
		INCLUDE "ai.asm"
starthere:
		;call InitIM2

		; IM is now running so lets do some broder changes.


		;call teststuff

		;call PlotTile16
		ld a,GAMEBMPBANK
		call loadBMPFromBank

		call loadSprites

		call makeAllSpritesVisible
		
		;call updateCartSprite
		;call testCart
		call updateCartSprite

		;call movecart

		;call updateCartSprite
		
		;call updateP1Sprites
		;call updateP2Sprites
		;BREAK
		

				
loop:								; start loop
		
		call ReadKeyboard


		

		ld      a,(Keys+VK_A)           
		and     $ff
		call nz ,p1Down

		ld      a,(Keys+VK_Q)           
		and     $ff
		call nz ,p1Up

		ld      a,(Keys+VK_Z)           
		and     $ff
		call nz ,p1Fire

		ld      a,(Keys+VK_W)           
		and     $ff
		call nz ,p1GunUp

		ld      a,(Keys+VK_E)           
		and     $ff
		call nz ,p1GunDown



		ld      a,(Keys+VK_L)           
		and     $ff
		call nz ,p2Down

		ld      a,(Keys+VK_P)           
		and     $ff
		call nz ,p2Up

		ld      a,(Keys+VK_M)           
		and     $ff
		call nz ,p2Fire
		
		ld      a,(Keys+VK_O)           
		and     $ff
		call nz ,p2GunUp

		ld      a,(Keys+VK_K)           
		and     $ff
		call nz ,p2GunDown




		ld a,1
		inc a


		call movecart
		call aiMove
		call updateCartSprite
		call updateP1Sprites
		call updateP2Sprites
		call movep1Bullet
		call movep2Bullet
		halt
		
		ld hl ,p1LastGunMove
		inc (hl)
		ld a,(hl)
		cp 4 ; de sensitise gun movement 
		jr z, .resetP1GunMoveCounter
		jp .endProcessing

.resetP1GunMoveCounter
		
		ld a,0
		ld (hl),a
		call controlP2
		jp .endProcessing




.endProcessing
		jp loop 					; got back to loop



movecart
	ld a,(cartDirection)
	cp cartUP
	jr z, .cartUP
.cartDown
	call movecartdown
	jr .endmovecart
.cartUP
	call movecartup
.endmovecart	
	ret


movecartup
		ld hl,cartPos

		ld a,(hl)
		add a,48
		cp 0
		;jp z, .topOfScreen
		dec (hl)
		jr .endOfMoveCartUp
.topOfScreen
	;change direction
	ld hl, cartDirection
	ld a,cartDown
	ld (hl),a

.endOfMoveCartUp
	ret		


movecartdown
		ld hl,cartPos

		ld a,(hl)
		
		cp 200
		jp z, .bottomOfScreen
		inc (hl)
		jr .endOfMoveCartDown
.bottomOfScreen
	;change direction
	ld hl, cartDirection
	ld a,cartUP
	ld (hl),a

.endOfMoveCartDown
	ret		








p1Up
	ld hl,p1Pos
	ld a,(p1Pos)
	cp 32
	jp z, .topOfScreen
	dec (hl)
.topOfScreen
	ret



p1Down
	ld hl,p1Pos
	ld a,(p1Pos)
	cp 160
	jp z, .bottomOfScreen
	inc (hl)
.bottomOfScreen

	ret




p1Fire


	;check if bullet is available


	ld a, (p1BulletMoving)
	cp 1 ; alreadt on screen so ignore
	jr z, .endofp1Fire
	; set initial cordinates
	ld hl, p1BulletMoving
	ld a,1
	ld (hl),a

	//setDirection
	ld a,(p1GunPos)
	cp GUNUP
	jr z, .bulletup  

	cp GUNDOWN
	jr z, .bulletdown  


.bulleth 
	ld hl,bulletP1Direction
	ld a,bulletDirectionHorizontal
	ld (hl),a

	jr .setstart
.bulletup 
	ld hl,bulletP1Direction
	ld a,bulletDirectionUp
	ld (hl),a

	jr .setstart


.bulletdown 
	ld hl,bulletP1Direction
	ld a,bulletDirectionDown
	ld (hl),a



.setstart




	;set bullet start position
	ld a,(p1Pos)
	add a, 17 ; move to down
	ld hl,bulletP1pos
	ld (hl),a
	inc hl	; bullet ypos
	ld a,(p1Pos+1)
	add a, 22 ; move right
	ld (hl),a


	

	

.endofp1Fire

	ret





p1GunUp
	ld a,(p1LastGunMove)
	;BREAK
	cp 0
	jp nz, .endp1GunUp

	
	ld a,(p1GunPos)
	cp GUNHOR 
	jp z, .changegunup 
	;BREAK

	cp GUNDOWN
	jp z, .changeghor

	jr .endp1GunUp
.changegunup
	ld hl,p1GunPos
	ld a, GUNUP
	ld (hl),a


	ld d,p1BRSprite
	ld e,p1GunUpTileID 
	call updateSpriteWithTile


	jr .endp1GunUp
.changeghor
	ld hl,p1GunPos
	ld a, GUNHOR
	ld (hl),a

	ld d,p1BRSprite
	ld e,p1GunHorTileID 
	call updateSpriteWithTile


.endp1GunUp
	ret



p1GunDown
	ld a,(p1LastGunMove)
	cp 0
	jp nz, .endp1GunDown

	
	ld a,(p1GunPos)
	cp GUNHOR 
	jp z, .changegundown
	

	cp GUNUP
	jp z, .changeghor

	jr .endp1GunDown
.changegundown
	ld hl,p1GunPos
	ld a, GUNDOWN
	ld (hl),a

	;change sprite d = sprite to change , e - tile to change with 
	ld d,p1BRSprite
	ld e,p1GunDownTileID 
	call updateSpriteWithTile


	jr .endp1GunDown
.changeghor



	ld hl,p1GunPos
	ld a, GUNHOR
	ld (hl),a

	;change sprite d = sprite to change , e - tile to change with 
	ld d,p1BRSprite
	ld e,p1GunHorTileID 
	call updateSpriteWithTile



.endp1GunDown
	ret





p2Up
	ld hl,p2Pos
	ld a,(p2Pos)
	cp 32
	jp z, .topOfScreen
	dec (hl)
.topOfScreen
	ret



p2Down
	ld hl,p2Pos
	ld a,(p2Pos)
	cp 160
	jp z, .bottomOfScreen
	inc (hl)
.bottomOfScreen

	ret











p2Fire

	;check if bullet is available
	


	ld a, (p2BulletMoving)
	cp 1 ; alreadt on screen so ignore
	jr z, .endofp2Fire
	; set initial cordinates
	ld hl, p2BulletMoving
	ld a,1
	ld (hl),a

	//setDirection
	ld a,(p2GunPos)
	cp GUNUP
	jr z, .bulletup  

	cp GUNDOWN
	jr z, .bulletdown  


.bulleth 
	ld hl,bulletP2Direction
	ld a,bulletDirectionHorizontal
	ld (hl),a

	jr .setstart
.bulletup 
	ld hl,bulletP2Direction
	ld a,bulletDirectionUp
	ld (hl),a

	jr .setstart


.bulletdown 
	ld hl,bulletP2Direction
	ld a,bulletDirectionDown
	ld (hl),a



.setstart




	;set bullet start position
	ld a,(p2Pos)
	add a, 17 ; move to down
	ld hl,bulletP2pos
	ld (hl),a
	inc hl	; bullet ypos
	ld a,(p2Pos+1)
	add a, -22 ; move left
	ld (hl),a


	

	

.endofp2Fire

	ret







movep1Bullet

		ld a, (p1BulletMoving)
		cp 0
		jr z, .endOfMoveBullet
		
		ld hl,bulletP1pos+1

		ld a,(hl)
		
		cp 255
		jp z, .stopBullet
		cp 254
		jp z, .stopBullet

		cp 253
		jp z, .stopBullet

		cp 252
		jp z, .stopBullet

		inc (hl)
		inc (hl)
		inc (hl)
		inc (hl)
		
		;check if up direction

		ld a,(bulletP1Direction)
		cp bulletDirectionUp

		jp z, .bulletUp 
		cp bulletDirectionDown 
		jp z, .bulletDown 
		jr .bulletUpdate
.bulletUp
		ld hl,bulletP1pos
		ld a,(hl)
		cp 32
		jp z, .stopBullet
		dec (hl)
		jr .bulletUpdate

.bulletDown
		ld hl,bulletP1pos
		ld a,(hl)
		cp 192
		jp z, .stopBullet
		inc (hl)
		jr .bulletUpdate


		;check if downdir
.bulletUpdate


		call updateP1BulletSprite
		call checkP1bulletL2
		call checkP1bulletSprite

		jr .endOfMoveBullet
.stopBullet

	;change direction
	ld hl, p1BulletMoving
	ld a,0
	ld (hl),a
	;nedd to hide bullet too

	ld a, p1BulletSprite
	call hideSprite

.endOfMoveBullet
	ret		



movep2Bullet

		ld a, (p2BulletMoving)
		cp 0
		jr z, .endOfMoveBullet
		
		ld hl,bulletP2pos+1

		ld a,(hl)
		
		cp 32
		jp z, .stopBullet
		cp 33
		jp z, .stopBullet

		cp 34
		jp z, .stopBullet

		cp 35
		jp z, .stopBullet

		dec (hl)
		dec (hl)
		dec (hl)
		dec (hl)
		
		;check if up direction

		ld a,(bulletP2Direction)
		cp bulletDirectionUp

		jp z, .bulletUp 
		cp bulletDirectionDown 
		jp z, .bulletDown 
		jr .bulletUpdate
.bulletUp
		ld hl,bulletP2pos
		ld a,(hl)
		cp 32
		jp z, .stopBullet
		dec (hl)
		jr .bulletUpdate

.bulletDown
		ld hl,bulletP2pos
		ld a,(hl)
		cp 192
		jp z, .stopBullet
		inc (hl)
		jr .bulletUpdate


		;check if downdir
.bulletUpdate


		call updateP2BulletSprite

		jr .endOfMoveBullet
.stopBullet

	;change direction
	ld hl, p2BulletMoving
	ld a,0
	ld (hl),a
	;nedd to hide bullet too

	ld a, p2BulletSprite
	call hideSprite

.endOfMoveBullet
	ret		



p2GunUp
	ld a,(p1LastGunMove)
	;BREAK
	cp 0
	jp nz, .endp2GunUp

	
	ld a,(p2GunPos)
	cp GUNHOR 
	jp z, .changegunup 
	;BREAK

	cp GUNDOWN
	jp z, .changeghor

	jr .endp2GunUp
.changegunup
	ld hl,p2GunPos
	ld a, GUNUP
	ld (hl),a


	ld d,p2BLSprite
	ld e,p2GunUpTileID 
	call updateSpriteWithTile


	jr .endp2GunUp
.changeghor
	ld hl,p2GunPos
	ld a, GUNHOR
	ld (hl),a

	ld d,p2BLSprite
	ld e,p2GunHorTileID 
	call updateSpriteWithTile


.endp2GunUp
	ret



p2GunDown
	ld a,(p2LastGunMove)
	cp 0
	jp nz, .endp2GunDown

	
	ld a,(p2GunPos)
	cp GUNHOR 
	jp z, .changegundown
	

	cp GUNUP
	jp z, .changeghor

	jr .endp2GunDown
.changegundown
	ld hl,p2GunPos
	ld a, GUNDOWN
	ld (hl),a

	;change sprite d = sprite to change , e - tile to change with 
	ld d,p2BLSprite
	ld e,p2GunDownTileID 
	call updateSpriteWithTile


	jr .endp2GunDown
.changeghor



	ld hl,p2GunPos
	ld a, GUNHOR
	ld (hl),a

	;change sprite d = sprite to change , e - tile to change with 
	ld d,p2BLSprite
	ld e,p2GunHorTileID 
	call updateSpriteWithTile



.endp2GunDown
	ret







hideSprite
  push af
  
  ld bc, $303b
  out (c), a ; select sprite 
  ld bc, $57
  ld a, 0 ; xpos >>> 32 on boarder ->>
  out (c), a
  ld a, 0 ; ypos ? --- 32 upper ->>>
  out (c), a
  ld a, 0 ; 7-4 is palette offset, bit 3 is X mirror, bit 2 is Y mirror, bit 1 is rotate flag and bit 0 is X MSB. 
  ; 8 flip x 4 flipy 2 rotate 1 msb
  ld a,0
  out (c), a
  pop af
  ;or 128
;  ld a, 137 ; spite visible pattern 0 ??? ;;128 = 0
  out (c), a;


  ret

;hideMM:
;  ld a,(OldSpriteID)
;  push af
;  ;ld a,9
;  ld bc, $303b
;  out (c), a ; select sprite 3
;  ld bc, $57
;  ld a, (MMSpritePosition+1) ; xpos >>> 32 on boarder ->>
;  out (c), a
;  ld a, (MMSpritePosition+2) ; ypos ? --- 32 upper ->>>
;  out (c), a
;  ld a, 0 ; 7-4 is palette offset, bit 3 is X mirror, bit 2 is Y mirror, bit 1 is rotate flag and bit 0 is X MSB. 
;  ; 8 flip x 4 flipy 2 rotate 1 msb
;  ld a,(MMSpritePosition)
;  out (c), a
;  pop af
;  ;xor 128
;  ;ld a, 137 ; spite visible pattern 0 ??? ;;128 = 0
;  out (c), a;

 ; ret















endmarker db 0





	savesna "ydr.sna",begin	; this doest work

