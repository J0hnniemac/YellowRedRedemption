;memory pageing
mem1 	db 0
mem2 	db 0
mb1 	db 0
mb2 	db 0

L2MEM1 = 9 ; need to change this to be done in code 

L2MEM2 = 11	




cartPos db $90,$76

cartTLPos db $20,$76
cartTRPos db $20,$86
cartMLPos db $30,$76
cartMRPos db $30,$86
cartBLPos db $40,$76
cartBRPos db $40,$86


p1Pos	db $60,$20
p2Pos	db $60,$E0

aiMOVEDIRUP = 1
aiMOVEDIRDOWN = 2
aiMOVEDIRSTOP = 0

aiMoveDirection db 0 ; 0 - still 1- up 2 -down	
randData db $09,$87

bulletP1pos db $00,$00	
bulletP2pos db $00,$00	

bulletP1Direction db 0	
bulletP2Direction db 0

p1BulletMoving db 0
p1GunPos db 0 ; 0;1;2
p1LastGunMove db 0

p2BulletMoving db 0
p2GunPos db 0 ; 0;1;2
p2LastGunMove db 0


GUNHOR = 0
GUNUP = 1
GUNDOWN = 2


bulletDirectionHorizontal = 0
bulletDirectionUp = 1
bulletDirectionDown = 2
p1BulletSprite = 22

p2BulletSprite = 25



cartTLSprite = 4
cartTRSprite = 5
cartMLSprite = 20
cartMRSprite = 21
cartBLSprite = 6
cartBRSprite = 7

p1TLSprite = 2
p1BLSprite = 18
p1BRSprite = 19

p1GunUpTileID = 3
p1GunHorTileID = 19
p1GunDownTileID = 23

p2GunUpTileID = 29
p2GunHorTileID = 16
p2GunDownTileID = 28




p2TRRSprite = 0
p2TRSprite = 1
p2BRSprite = 17
p2BLSprite = 16


p2TLShotSprite = 8
p2BLShotSprite = 24
p2TRShotSprite = 9

cartUP = 0
cartDown = 1
cartDirection db cartUP ; up




dummyEOF db 0
