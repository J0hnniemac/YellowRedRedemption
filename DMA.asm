;--------------------------------
; hl = source
; de = destination
; bc = length
;--------------------------------
TransferDMA
	ld (DMASource),hl
	ld (DMADest),de
	ld (DMALength),bc
	ld hl,DMACode
	ld b,DMACode_Len
	ld c,Z80_DMA_PORT_DATAGEAR
	otir
	ret

DMACode
		db DMA_RESET				;R6=RESET DMA
		db DMA_RESET_PORT_A_TIMING		;R6-RESET PORT A Timing
	        db DMA_RESET_PORT_B_TIMING		;R6-SET PORT B Timing same as PORT A
	        db %01111101				;R0-Transfer mode, A -> B, write adress + block length
DMASource	dw 0					;R0-Port A, Start address				(source address)
DMALength	dw 0					;R0-Block length					(length in bytes)
	        db %01010100				;R1-write A time byte, increment, to memory, bitmask
	        db %00000001				;R1-Cycle length port A
	        db %01010000				;R2-write A time byte, increment, to memory, bitmask
	        db %00000001				;R2-Cycle length port B
		db %10101101 				;R4-Continuous mode  (use this for block tansfer), write dest adress
DMADest	        dw 0					;R4-Dest address					(destination address)
		db %10000010				;R5-Restart on end of block, RDY active LOW
		db DMA_LOAD				;R6-Load
		db DMA_ENABLE				;R6-Enable DMA
DMACode_Len	equ $-DMACode
;--------------------------------
; hl = source
; bc = length
; set port to write to with TBBLUE_REGISTER_SELECT
; prior to call
;--------------------------------
TransferDMAPort
	ld (DMASourceP),hl
	ld (DMALengthP),bc
	ld hl,DMACodeP
	ld b,DMACode_LenP
	ld c,Z80_DMA_PORT_DATAGEAR
	otir
	ret

DMACodeP
		db DMA_RESET				;R6=RESET DMA
		db DMA_RESET_PORT_A_TIMING		;R6-RESET PORT A Timing
	        db DMA_RESET_PORT_B_TIMING		;R6-SET PORT B Timing same as PORT A
	        db %01111101				;R0-Transfer mode, A -> B, write adress + block length
DMASourceP	dw 0					;R0-Port A, Start address				(source address)
DMALengthP	dw 0					;R0-Block length					(length in bytes)
	        db %01010100				;R1-read A time byte, increment, to memory, bitmask
	        db %00000010				;R1-Cycle length port A
	        db %01101000				;R2-write A time byte, increment, to memory, bitmask
	        db %00000010				;R2-Cycle length port B
		db %10101101 				;R4-Continuous mode  (use this for block tansfer), write dest adress
		dw $253b				;R4-Dest address					(destination address)
		db %10000010				;R5-Restart on end of block, RDY active LOW
		db DMA_LOAD				;R6-Load
		db DMA_ENABLE				;R6-Enable DMA
DMACode_LenP	equ $-DMACodeP
;--------------------------------
; hl = source
; bc = length
;--------------------------------
TransferDMASprite
	ld (DMASourceS),hl
	ld (DMALengthS),bc
	ld hl,DMACodeS
	ld b,DMACode_LenS
	ld c,Z80_DMA_PORT_DATAGEAR
	otir
	ret

DMACodeS
		db DMA_RESET				;R6=RESET DMA
		db DMA_RESET_PORT_A_TIMING		;R6-RESET PORT A Timing
	        db DMA_RESET_PORT_B_TIMING		;R6-SET PORT B Timing same as PORT A
	        db %01111101				;R0-Transfer mode, A -> B, write adress + block length
DMASourceS	dw 0					;R0-Port A, Start address				(source address)
DMALengthS	dw 0					;R0-Block length					(length in bytes)
	        db %01010100				;R1-read A time byte, increment, to memory, bitmask
	        db %00000010				;R1-Cycle length port A
	        db %01101000				;R2-write A time byte, increment, to memory, bitmask
	        db %00000010				;R2-Cycle length port B
		db %10101101 				;R4-Continuous mode  (use this for block tansfer), write dest adress
		dw SPRITE_INFO_PORT			;R4-Dest address					(destination address)
		db %10000010				;R5-Restart on end of block, RDY active LOW
		db DMA_LOAD				;R6-Load
		db DMA_ENABLE				;R6-Enable DMA
DMACode_LenS	equ $-DMACodeS
