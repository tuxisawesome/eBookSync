	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
	.section	.text._csx_chunk_name,"ax",@progbits
	.globl	_csx_chunk_name                 ; -- Begin function csx_chunk_name
	.type	_csx_chunk_name,@function
_csx_chunk_name:                        ; @csx_chunk_name
; %bb.0:
	call	__frameset0
	ld	iy, (ix + 6)
	ld	e, (ix + 9)
	ld	b, 4
	ld	c, 48
	ld	d, 55
	ld	(iy), 67
	ld	(iy + 1), 83
	ld	a, e
	call	__bshru
	ld	l, a
	ld	a, e
	cp	a, -96
	jr	c, .LBB0_2
; %bb.1:
	ld	h, c
	ld	a, l
	add	a, d
	jr	.LBB0_3
	.local	.LBB0_2
.LBB0_2:
	ld	h, c
	ld	a, l
	add	a, c
	.local	.LBB0_3
.LBB0_3:
	ld	c, a
	ld	l, (ix + 12)
	ld	(iy + 2), c
	ld	d, 15
	ld	a, e
	and	a, d
	ld	e, a
	cp	a, 10
	jr	c, .LBB0_5
; %bb.4:
	ld	c, 55
	ld	a, e
	add	a, c
	ld	e, a
	ld	c, h
	jr	.LBB0_6
	.local	.LBB0_5
.LBB0_5:
	ld	c, h
	ld	a, e
	add	a, c
	ld	e, a
	.local	.LBB0_6
.LBB0_6:
	ld	(iy + 3), e
	ld	a, l
	call	__bshru
	ld	e, a
	ld	a, l
	cp	a, -96
	jr	c, .LBB0_8
; %bb.7:
	ld	h, 55
	ld	a, e
	add	a, h
	ld	e, a
	jr	.LBB0_9
	.local	.LBB0_8
.LBB0_8:
	ld	a, e
	add	a, c
	ld	e, a
	ld	h, 55
	.local	.LBB0_9
.LBB0_9:
	ld	(iy + 4), e
	ld	a, l
	and	a, d
	ld	l, a
	cp	a, 10
	jr	c, .LBB0_11
; %bb.10:
	ld	a, l
	add	a, h
	jr	.LBB0_12
	.local	.LBB0_11
.LBB0_11:
	ld	a, l
	add	a, c
	.local	.LBB0_12
.LBB0_12:
	ld	l, a
	ld	(iy + 5), l
	ld	(iy + 6), 0
	pop	ix
	ret
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_csx_chunk_name, .Lfunc_end0-_csx_chunk_name
                                        ; -- End function
	.section	.text._csx_open,"ax",@progbits
	.globl	_csx_open                       ; -- Begin function csx_open
	.type	_csx_open,@function
_csx_open:                              ; @csx_open
; %bb.0:
	ld	hl, -27
	call	__frameset
	ld	hl, (ix + 6)
	ld	a, (ix + 9)
	ld	(hl), 0
	push	hl
	pop	iy
	inc	iy
	ld	bc, 281
	lea	de, iy + 0
	push	hl
	pop	iy
	ldir
	ld	(iy), a
	or	a, a
	sbc	hl, hl
	push	hl
	ld	l, a
	push	hl
	call	_map_chunk
	push	hl
	pop	bc
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, bc
	jp	z, .LBB1_7
; %bb.1:
	ld	hl, _.str
	ld	de, 4
	push	de
	push	hl
	ld	(ix - 3), bc
	push	bc
	call	_memcmp
	pop	de
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	nz, .LBB1_7
; %bb.2:
	ld	de, (ix - 3)
	push	de
	pop	iy
	ld	a, (iy + 5)
	cp	a, 32
	jp	nz, .LBB1_7
; %bb.3:
	push	de
	pop	iy
	ld	c, (iy + 6)
	ld	b, 0
	ld	a, (iy + 7)
	ld	h, b
	ld	l, a
	ld	h, l
	ld	l, b
	ld	(ix - 5), c
	ld	(ix - 4), b
	add.sis	hl, bc
	ld.sis	bc, 320
	or	a, a
	sbc.sis	hl, bc
	jr	nz, .LBB1_7
; %bb.4:
	push	de
	pop	iy
	ld	e, (iy + 8)
	ld	c, (ix - 5)
	ld	b, (ix - 4)
	ld	d, b
	ld	a, (iy + 9)
	ld	h, b
	ld	l, a
	ld	h, l
	ld	l, b
	add.sis	hl, de
	ld.sis	de, 16
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB1_7
; %bb.5:
	ld	iy, (ix - 3)
	ld	a, (iy + 4)
	lea	de, iy + 0
	ld	iy, (ix + 6)
	ld	(iy + 2), a
	push	de
	pop	iy
	ld	l, (iy + 12)
	ld	(ix - 8), l                     ; 1-byte Folded Spill
	ld	iy, (ix + 6)
	ld	(iy + 1), l
	push	de
	pop	iy
	ld	e, (iy + 10)
	ld	d, b
	ld	l, (iy + 11)
	ex	de, hl
	ld	iyl, e
	ex	de, hl
	ld	h, b
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	ld	h, l
	ld	l, b
	add.sis	hl, de
	ld	(ix - 13), l
	ld	(ix - 12), h
	ld	iy, (ix + 6)
	ld	(iy + 4), l
	ld	(iy + 5), h
	ld	(ix - 11), a                    ; 1-byte Folded Spill
	ld	l, -5
	add	a, l
	ld	l, a
	cp	a, -4
	jr	c, .LBB1_7
; %bb.6:
	ld	l, -65
	ld	a, (ix - 8)
	add	a, l
	ld	l, a
	cp	a, -64
	jr	nc, .LBB1_9
	.local	.LBB1_7
.LBB1_7:
	xor	a, a
	.local	.LBB1_8
.LBB1_8:                                ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB1_9
.LBB1_9:
	or	a, a
	sbc	hl, hl
	ld	(ix - 8), hl
	inc	hl
	ld	(ix - 18), hl
	ld	(ix - 21), hl
	dec.sis	hl
	ld	(ix - 15), l
	ld	(ix - 14), h
	ld	bc, 32
	.local	.LBB1_10
.LBB1_10:                               ; =>This Inner Loop Header: Depth=1
	ld	iy, (ix - 3)
	ld	de, (ix - 8)
	add	iy, de
	ex	de, hl
	push	bc
	pop	de
	or	a, a
	sbc	hl, bc
	jr	z, .LBB1_12
; %bb.11:                               ;   in Loop: Header=BB1_10 Depth=1
	ld	c, (ix - 5)
	ld	b, (ix - 4)
	ld	c, (iy + 16)
	ld	a, (iy + 17)
	ld	h, b
	ld	l, a
	ex	de, hl
	ld	iyh, e
	ex	de, hl
	ld	iyl, b
	ld	(ix - 5), c
	ld	(ix - 4), b
	add.sis	iy, bc
	ld	hl, (ix + 6)
	ld	bc, (ix - 8)
	add	hl, bc
	ld	bc, 250
	add	hl, bc
	push	de
	ld	e, iyl
	ld	d, iyh
	ld	(hl), e
	inc	hl
	ld	(hl), d
	pop	de
	ld	hl, (ix - 8)
	ld	bc, 2
	add	hl, bc
	ld	(ix - 8), hl
	push	de
	pop	bc
	jr	.LBB1_10
	.local	.LBB1_12
.LBB1_12:
	ld	de, 0
	ld	e, (ix - 11)                    ; 1-byte Folded Reload
	ld	bc, 212
	ld	hl, (ix + 6)
	add	hl, bc
	ld	(ix - 11), hl
	lea	bc, iy + 16
	ld	a, 16
	.local	.LBB1_13
.LBB1_13:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB1_15
; %bb.14:                               ;   in Loop: Header=BB1_13 Depth=1
	ld	(ix - 24), de
	push	bc
	pop	iy
	ld	(ix - 8), iy
	ld	c, (iy)
	ld	l, (ix - 5)
	ld	h, (ix - 4)
	ld	b, h
	ld	l, (iy + 1)
	ld	e, (ix - 5)
	ld	d, (ix - 4)
                                        ; kill: def $d killed $d killed $de def $de
	ld	e, l
	ld	h, e
	ld	e, (ix - 5)
	ld	d, (ix - 4)
	ld	l, d
	add.sis	hl, bc
	ld	iy, (ix - 11)
	ld	(iy - 10), l
	ld	(iy - 9), h
	ld	iy, (ix - 8)
	ld	l, (iy + 2)
	ld	de, 0
	push	de
	pop	bc
	ld	e, l
	ld	(ix - 27), de
	ld	e, (iy + 3)
	push	bc
	pop	hl
	ld	l, e
	ld	c, 8
	call	__ishl
	ld	de, (ix - 27)
	add	hl, de
	ld	(ix - 27), hl
	ld	iy, (ix - 8)
	ld	e, (iy + 4)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	c, a
	call	__ishl
	push	hl
	pop	bc
	ld	hl, (ix - 27)
	add	hl, bc
	ld	iy, (ix - 11)
	ld	(iy - 8), hl
	ld	iy, (ix - 8)
	ld	c, (iy + 6)
	ld	l, (ix - 5)
	ld	h, (ix - 4)
	ld	b, h
	ld	iy, (ix - 8)
	ld	l, (iy + 7)
	ld	e, (ix - 5)
	ld	d, (ix - 4)
                                        ; kill: def $d killed $d killed $de def $de
	ld	e, l
	ld	iyh, e
	ld	l, (ix - 5)
	ld	h, (ix - 4)
	ex	de, hl
	ld	iyl, d
	ex	de, hl
	add.sis	iy, bc
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 27), l
	ld	(ix - 26), h
	ld	iy, (ix - 11)
	ld	(iy - 4), l
	ld	(iy - 3), h
	ld	iy, (ix - 8)
	ld	c, (iy + 8)
	ld	l, (ix - 5)
	ld	h, (ix - 4)
	ld	b, h
	ld	iy, (ix - 8)
	ld	l, (iy + 9)
	ld	e, (ix - 5)
	ld	d, (ix - 4)
                                        ; kill: def $d killed $d killed $de def $de
	ld	e, l
	ld	h, e
	ld	e, (ix - 5)
	ld	d, (ix - 4)
	ld	l, d
	add.sis	hl, bc
	ld	iy, (ix - 11)
	ld	(iy - 2), l
	ld	(iy - 1), h
	ld	e, (ix - 15)
	ld	d, (ix - 14)
	ld	(iy), e
	ld	(iy + 1), d
	ld	c, (ix - 27)
	ld	b, (ix - 26)
	ld	iy, (ix - 8)
	call	__smulu
	ld	de, (ix - 24)
	ld	c, (ix - 15)
	ld	b, (ix - 14)
	add.sis	hl, bc
	lea	iy, iy + 12
	lea	bc, iy + 0
	ld	iy, (ix - 11)
	lea	iy, iy + 12
	ld	(ix - 11), iy
	dec	de
	ld	(ix - 15), l
	ld	(ix - 14), h
	jp	.LBB1_13
	.local	.LBB1_15
.LBB1_15:
	ld	l, (ix - 15)
	ld	h, (ix - 14)
	ld	e, (ix - 13)
	ld	d, (ix - 12)
	or	a, a
	sbc.sis	hl, de
	ld	a, 0
	jp	nz, .LBB1_8
; %bb.16:
	ld	de, (ix + 6)
	push	bc
	pop	hl
	push	de
	pop	iy
	ld	bc, 198
	add	iy, bc
	ld	(iy), hl
	ld	hl, (ix - 3)
	push	de
	pop	iy
	ld	(iy + 6), hl
	lea	iy, iy + 9
	.local	.LBB1_17
.LBB1_17:                               ; =>This Inner Loop Header: Depth=1
	ld	(ix - 3), iy
	ld	iy, (ix + 6)
	ld	a, (iy + 1)
	ld	de, 0
	ld	e, a
	ld	bc, (ix - 18)
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	bit	0, a
	jp	nz, .LBB1_8
; %bb.18:                               ;   in Loop: Header=BB1_17 Depth=1
	ld	hl, (ix - 21)
	push	hl
	ld	l, (ix + 9)
	push	hl
	ld	(ix - 5), a                     ; 1-byte Folded Spill
	ld	(ix - 18), bc
	call	_map_chunk
	ld	a, (ix - 5)                     ; 1-byte Folded Reload
	pop	de
	pop	de
	ld	iy, (ix - 3)
	ld	(iy), hl
	ld	de, (ix - 18)
	inc	de
	ld	(ix - 18), de
	ld	de, (ix - 21)
	inc	e
	ld	(ix - 21), de
	lea	iy, iy + 3
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	nz, .LBB1_17
	jp	.LBB1_8
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_csx_open, .Lfunc_end1-_csx_open
                                        ; -- End function
	.section	.text._map_chunk,"ax",@progbits
	.type	_map_chunk,@function            ; -- Begin function map_chunk
_map_chunk:                             ; @map_chunk
; %bb.0:
	ld	hl, -15
	call	__frameset
	ld	a, (ix + 6)
	ld	l, (ix + 9)
	ld	de, 0
	ld	(ix - 12), de
	lea	de, ix - 9
	ld	(ix - 15), de
                                        ; kill: def $l killed $l def $uhl
	push	hl
	ld	l, a
	push	hl
	push	de
	call	_csx_chunk_name
	pop	hl
	pop	hl
	pop	hl
	ld	hl, _.str.6.30
	push	hl
	ld	hl, (ix - 15)
	push	hl
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB2_2
; %bb.1:
	push	de
	ld	(ix - 15), de
	call	_ti_GetDataPtr
	ld	(ix - 12), hl
	pop	hl
	ld	hl, (ix - 15)
	push	hl
	call	_ti_Close
	pop	hl
	.local	.LBB2_2
.LBB2_2:
	ld	hl, (ix - 12)
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end2
.Lfunc_end2:
	.size	_map_chunk, .Lfunc_end2-_map_chunk
                                        ; -- End function
	.section	.text._csx_delete,"ax",@progbits
	.globl	_csx_delete                     ; -- Begin function csx_delete
	.type	_csx_delete,@function
_csx_delete:                            ; @csx_delete
; %bb.0:
	ld	hl, -18
	call	__frameset
	ld	a, (ix + 6)
	ld	l, 0
	lea	de, ix - 9
	ld	(ix - 12), de
	ld	e, a
	.local	.LBB3_1
.LBB3_1:                                ; =>This Inner Loop Header: Depth=1
	ld	a, l
	cp	a, 64
	jr	z, .LBB3_4
; %bb.2:                                ;   in Loop: Header=BB3_1 Depth=1
	push	hl
	push	de
	ld	bc, (ix - 12)
	push	bc
	ld	(ix - 15), hl
	ld	(ix - 18), de
	call	_csx_chunk_name
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 12)
	push	hl
	call	_ti_Delete
	pop	de
	ld	de, (ix - 18)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	hl, (ix - 15)
	jr	z, .LBB3_4
; %bb.3:                                ;   in Loop: Header=BB3_1 Depth=1
	inc	l
	jr	.LBB3_1
	.local	.LBB3_4
.LBB3_4:
	ld	a, l
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end3
.Lfunc_end3:
	.size	_csx_delete, .Lfunc_end3-_csx_delete
                                        ; -- End function
	.section	.text._csx_band,"ax",@progbits
	.globl	_csx_band                       ; -- Begin function csx_band
	.type	_csx_band,@function
_csx_band:                              ; @csx_band
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	iy, (ix + 6)
	ld	bc, (ix + 9)
	or	a, a
	sbc	hl, hl
	ld	(ix - 3), hl
	ld	de, (iy + 4)
	ld	l, c
	ld	h, b
	sbc.sis	hl, de
	jp	nc, .LBB4_3
; %bb.1:
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	de, 198
	add	iy, de
	ld	iy, (iy)
	ld	bc, 5
	call	__imulu
	ex	de, hl
	add	iy, de
	lea	de, iy + 0
	ld	a, (iy)
	ld	iy, (ix + 6)
	ld	l, (iy + 1)
	cp	a, l
	jr	nc, .LBB4_3
; %bb.2:
	ld	bc, 0
	ld	c, a
	push	de
	pop	iy
	ld	(ix - 6), iy
	ld	e, (iy + 3)
	ld	d, b
	ld	a, (iy + 4)
	ld	iyh, d
	ld	iyl, a
	ld	a, 8
	ld	iyh, iyl
	ld	iyl, d
	add.sis	iy, de
	ld	hl, (ix + 12)
	push	de
	ld	e, iyl
	ld	d, iyh
	ld	(hl), e
	inc	hl
	ld	(hl), d
	pop	de
	push	bc
	pop	hl
	ld	bc, 3
	call	__imulu
	ex	de, hl
	ld	iy, (ix + 6)
	add	iy, de
	ld	hl, (iy + 6)
	ld	(ix - 3), hl
	ld	iy, (ix - 6)
	ld	l, (iy + 1)
	ld	bc, 0
	push	bc
	pop	de
	ld	e, l
	ld	l, (iy + 2)
	ld	c, l
	push	bc
	pop	hl
	ld	c, a
	call	__ishl
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 3)
	add	hl, de
	ld	(ix - 3), hl
	.local	.LBB4_3
.LBB4_3:
	ld	hl, (ix - 3)
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end4
.Lfunc_end4:
	.size	_csx_band, .Lfunc_end4-_csx_band
                                        ; -- End function
	.section	.text._input_reset,"ax",@progbits
	.globl	_input_reset                    ; -- Begin function input_reset
	.type	_input_reset,@function
_input_reset:                           ; @input_reset
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	hl, -720878
	ld	(ix - 3), hl
	call	_kb_Scan
	ld	bc, 1
	ld	de, 8
	.local	.LBB5_1
.LBB5_1:                                ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB5_3
; %bb.2:                                ;   in Loop: Header=BB5_1 Depth=1
	ld	iy, (ix - 3)
	ld	l, (iy)
	ld	h, (iy + 1)
	lea	de, iy + 0
	ld	a, l
	ld	iy, _current
	add	iy, bc
	ld	(iy), a
	inc	bc
	push	de
	pop	iy
	ld	de, 8
	lea	iy, iy + 2
	ld	(ix - 3), iy
	jr	.LBB5_1
	.local	.LBB5_3
.LBB5_3:
	ld	de, (_current)
	ld	bc, (_current+3)
	ld	iy, _current
	lea	hl, iy + 6
	ld	hl, (hl)
	ld	(ix - 3), hl
	ld	(_previous), de
	ld	(_previous+3), bc
	ld	iy, _previous
	lea	hl, iy + 6
	ld	de, (ix - 3)
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld.sis	hl, 0
	ld	iy, _repeat_key
	ld	(iy), l
	ld	(iy + 1), h
	or	a, a
	sbc	hl, hl
	ld	(_repeat_frames), hl
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_input_reset, .Lfunc_end5-_input_reset
                                        ; -- End function
	.section	.text._input_scan,"ax",@progbits
	.globl	_input_scan                     ; -- Begin function input_scan
	.type	_input_scan,@function
_input_scan:                            ; @input_scan
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	iy, _current
	ld	hl, -720878
	ld	(ix - 3), hl
	ld	de, (_current)
	ld	bc, (_current+3)
	lea	hl, iy + 6
	ld	hl, (hl)
	ld	(ix - 6), hl
	ld	(_previous), de
	ld	(_previous+3), bc
	ld	iy, _previous
	lea	hl, iy + 6
	ld	de, (ix - 6)
	ld	(hl), e
	inc	hl
	ld	(hl), d
	call	_kb_Scan
	ld	bc, 1
	ld	de, 8
	.local	.LBB6_1
.LBB6_1:                                ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB6_3
; %bb.2:                                ;   in Loop: Header=BB6_1 Depth=1
	ld	iy, (ix - 3)
	ld	l, (iy)
	ld	h, (iy + 1)
	lea	de, iy + 0
	ld	a, l
	ld	iy, _current
	add	iy, bc
	ld	(iy), a
	inc	bc
	push	de
	pop	iy
	ld	de, 8
	lea	iy, iy + 2
	ld	(ix - 3), iy
	jr	.LBB6_1
	.local	.LBB6_3
.LBB6_3:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_input_scan, .Lfunc_end6-_input_scan
                                        ; -- End function
	.section	.text._input_down,"ax",@progbits
	.globl	_input_down                     ; -- Begin function input_down
	.type	_input_down,@function
_input_down:                            ; @input_down
; %bb.0:
	call	__frameset0
	ld	de, (ix + 6)
	ld	iy, _current
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	c, 8
	call	__ishru
	push	hl
	pop	bc
	add	iy, bc
	ld	a, (iy)
	ld	l, e
	and	a, l
	ld	l, a
	or	a, a
	jr	nz, .LBB7_2
; %bb.1:
	ld	a, 0
	jr	.LBB7_3
	.local	.LBB7_2
.LBB7_2:
	ld	a, -1
	.local	.LBB7_3
.LBB7_3:
	pop	ix
	ret
	.local	.Lfunc_end7
.Lfunc_end7:
	.size	_input_down, .Lfunc_end7-_input_down
                                        ; -- End function
	.section	.text._input_pressed,"ax",@progbits
	.globl	_input_pressed                  ; -- Begin function input_pressed
	.type	_input_pressed,@function
_input_pressed:                         ; @input_pressed
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	de, (ix + 6)
	ld	iy, _current
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	c, 8
	call	__ishru
	push	hl
	pop	bc
	ld	(ix - 3), bc
	add	iy, bc
	ld	a, (iy)
	ld	l, e
	ld	h, d
	ld.sis	bc, 255
	call	__sand
	ld	e, l
	and	a, e
	ld	e, a
	or	a, a
	jr	nz, .LBB8_2
; %bb.1:
	xor	a, a
	jp	.LBB8_5
	.local	.LBB8_2
.LBB8_2:
	ld	iy, _previous
	ld	de, (ix - 3)
	add	iy, de
	ld	a, (iy)
                                        ; kill: def $l killed $l killed $hl
	and	a, l
	ld	l, a
	or	a, a
	jr	z, .LBB8_4
; %bb.3:
	ld	a, 0
	jr	.LBB8_5
	.local	.LBB8_4
.LBB8_4:
	ld	a, -1
	.local	.LBB8_5
.LBB8_5:
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end8
.Lfunc_end8:
	.size	_input_pressed, .Lfunc_end8-_input_pressed
                                        ; -- End function
	.section	.text._input_repeat,"ax",@progbits
	.globl	_input_repeat                   ; -- Begin function input_repeat
	.type	_input_repeat,@function
_input_repeat:                          ; @input_repeat
; %bb.0:
	call	__frameset0
	ld	de, (ix + 6)
	ld	iy, _current
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	c, 8
	call	__ishru
	push	hl
	pop	bc
	add	iy, bc
	ld	a, (iy)
	ld	iy, _repeat_key
	and	a, e
	ld	c, a
	ld	hl, (iy)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	jr	nz, .LBB9_4
; %bb.1:
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB9_3
; %bb.2:
	ld.sis	hl, 0
	ld	(iy), l
	ld	(iy + 1), h
	or	a, a
	sbc	hl, hl
	ld	(_repeat_frames), hl
	.local	.LBB9_3
.LBB9_3:
	ld	l, 0
	jr	.LBB9_8
	.local	.LBB9_4
.LBB9_4:
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB9_7
; %bb.5:
	ld	de, (_repeat_frames)
	push	de
	pop	hl
	inc	hl
	ld	(_repeat_frames), hl
	ld	bc, 14
	or	a, a
	sbc	hl, bc
	ld	l, b
	jr	c, .LBB9_8
; %bb.6:
	ld	l, 1
	ld	a, e
	and	a, l
	ld	l, a
	jr	.LBB9_8
	.local	.LBB9_7
.LBB9_7:
	ld	l, 1
	ld	(iy), e
	ld	(iy + 1), d
	ld	de, 0
	ld	(_repeat_frames), de
	.local	.LBB9_8
.LBB9_8:
	ld	a, l
	pop	ix
	ret
	.local	.Lfunc_end9
.Lfunc_end9:
	.size	_input_repeat, .Lfunc_end9-_input_repeat
                                        ; -- End function
	.section	.text._input_held_frames,"ax",@progbits
	.globl	_input_held_frames              ; -- Begin function input_held_frames
	.type	_input_held_frames,@function
_input_held_frames:                     ; @input_held_frames
; %bb.0:
	ld	hl, (_repeat_frames)
	ret
	.local	.Lfunc_end10
.Lfunc_end10:
	.size	_input_held_frames, .Lfunc_end10-_input_held_frames
                                        ; -- End function
	.section	.text._input_idle,"ax",@progbits
	.globl	_input_idle                     ; -- Begin function input_idle
	.type	_input_idle,@function
_input_idle:                            ; @input_idle
; %bb.0:
	ld	bc, 1
	ld	iy, 8
	.local	.LBB11_1
.LBB11_1:                               ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	de
	push	de
	pop	hl
	lea	bc, iy + 0
	or	a, a
	sbc	hl, bc
	jr	z, .LBB11_3
; %bb.2:                                ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, _current
	add	hl, de
	push	de
	pop	bc
	inc	bc
	ld	a, (hl)
	or	a, a
	jr	z, .LBB11_1
	.local	.LBB11_3
.LBB11_3:
	ex	de, hl
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	ret
	.local	.Lfunc_end11
.Lfunc_end11:
	.size	_input_idle, .Lfunc_end11-_input_idle
                                        ; -- End function
	.section	.text._lib_open,"ax",@progbits
	.globl	_lib_open                       ; -- Begin function lib_open
	.type	_lib_open,@function
_lib_open:                              ; @lib_open
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	hl, _strip_count
	ld	iy, _book_count
	ld	de, _.str.5.29
	ld	bc, 0
	ld	(_index_data), bc
	ld	(hl), c
	inc	hl
	ld	(hl), b
	ld	(iy), c
	ld	(iy + 1), b
	ld	hl, _.str.6.30
	push	hl
	push	de
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jp	z, .LBB12_5
; %bb.1:
	push	de
	ld	(ix - 6), de
	call	_ti_GetDataPtr
	ld	(ix - 3), hl
	pop	hl
	ld	hl, (ix - 6)
	push	hl
	call	_ti_Close
	pop	hl
	ld	hl, (ix - 3)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB12_5
; %bb.2:
	ld	hl, 5
	push	hl
	ld	hl, _.str.5.29
	push	hl
	ld	hl, (ix - 3)
	push	hl
	call	_memcmp
	pop	de
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB12_5
; %bb.3:
	ld	iy, (ix - 3)
	ld	a, (iy + 5)
	cp	a, 1
	ld	a, 0
	jr	nz, .LBB12_6
; %bb.4:
	ld	a, 1
	ld	iy, (ix - 3)
	ld	(_index_data), iy
	ld	e, (iy + 6)
	ld	d, 0
	ld	c, (iy + 7)
	ld	h, d
	ld	l, c
	ld	h, l
	ld	l, d
	add.sis	hl, de
	ld	iy, _book_count
	ld	(iy), l
	ld	(iy + 1), h
	ld	iy, (ix - 3)
	ld	e, (iy + 8)
	ld	c, (iy + 9)
	ld	h, d
	ld	l, c
	ld	h, l
	ld	l, d
	add.sis	hl, de
	ld	iy, _strip_count
	ld	(iy), l
	ld	(iy + 1), h
	jr	.LBB12_6
	.local	.LBB12_5
.LBB12_5:
	xor	a, a
	.local	.LBB12_6
.LBB12_6:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end12
.Lfunc_end12:
	.size	_lib_open, .Lfunc_end12-_lib_open
                                        ; -- End function
	.section	.text._lib_book_count,"ax",@progbits
	.globl	_lib_book_count                 ; -- Begin function lib_book_count
	.type	_lib_book_count,@function
_lib_book_count:                        ; @lib_book_count
; %bb.0:
	ld	hl, _book_count
	ld	hl, (hl)
                                        ; kill: def $hl killed $hl killed $uhl
	ret
	.local	.Lfunc_end13
.Lfunc_end13:
	.size	_lib_book_count, .Lfunc_end13-_lib_book_count
                                        ; -- End function
	.section	.text._lib_strip_count,"ax",@progbits
	.globl	_lib_strip_count                ; -- Begin function lib_strip_count
	.type	_lib_strip_count,@function
_lib_strip_count:                       ; @lib_strip_count
; %bb.0:
	ld	hl, _strip_count
	ld	hl, (hl)
                                        ; kill: def $hl killed $hl killed $uhl
	ret
	.local	.Lfunc_end14
.Lfunc_end14:
	.size	_lib_strip_count, .Lfunc_end14-_lib_strip_count
                                        ; -- End function
	.section	.text._lib_get_book,"ax",@progbits
	.globl	_lib_get_book                   ; -- Begin function lib_get_book
	.type	_lib_get_book,@function
_lib_get_book:                          ; @lib_get_book
; %bb.0:
	call	__frameset0
	ld	de, (ix + 6)
	ld	bc, 6
	ld	iy, (_index_data)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	call	__imulu
	ex	de, hl
	add	iy, de
	ld	e, (iy + 12)
	ld	d, b
	ld	a, (iy + 13)
	lea	bc, iy + 0
	ld	h, d
	ld	l, a
	ld	h, l
	ld	l, d
	add.sis	hl, de
	ld	iy, (ix + 9)
	ld	(iy), l
	ld	(iy + 1), h
	push	bc
	pop	iy
	ld	e, (iy + 14)
	ld	a, (iy + 15)
	ld	h, d
	ld	l, a
	ld	h, l
	ld	l, d
	add.sis	hl, de
	ld	iy, (ix + 9)
	ld	(iy + 2), l
	ld	(iy + 3), h
	push	bc
	pop	iy
	ld	e, (iy + 16)
	ld	a, (iy + 17)
	ld	h, d
	ld	l, a
	ld	h, l
	ld	l, d
	add.sis	hl, de
	ld	iy, (ix + 9)
	ld	(iy + 4), l
	ld	(iy + 5), h
	pop	ix
	ret
	.local	.Lfunc_end15
.Lfunc_end15:
	.size	_lib_get_book, .Lfunc_end15-_lib_get_book
                                        ; -- End function
	.section	.text._lib_get_strip,"ax",@progbits
	.globl	_lib_get_strip                  ; -- Begin function lib_get_strip
	.type	_lib_get_strip,@function
_lib_get_strip:                         ; @lib_get_strip
; %bb.0:
	ld	hl, -10
	call	__frameset
	ld	hl, _book_count
	ld	iy, (_index_data)
	ld	bc, (hl)
	ld	de, 0
	push	de
	pop	hl
	ld	l, c
	ld	h, b
	ld	bc, 6
	call	__imulu
	push	hl
	pop	bc
	add	iy, bc
	push	de
	pop	hl
	ld	bc, (ix + 6)
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	hl
	pop	bc
	add	iy, bc
	ld	a, (iy + 12)
	ld	hl, (ix + 9)
	ld	(hl), a
	ld	a, (iy + 13)
	lea	hl, iy + 0
	ld	iy, (ix + 9)
	ld	(iy + 1), a
	push	hl
	pop	iy
	ld	(ix - 7), iy
	ld	e, (iy + 14)
	ld	a, (iy + 15)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	c, 8
	call	__ishl
	add	hl, de
	ld	(ix - 10), hl
	ld	iy, (ix - 7)
	ld	a, (iy + 16)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	c, 16
	call	__ishl
	ex	de, hl
	ld	hl, (ix - 10)
	add	hl, de
	ld	iy, (ix + 9)
	ld	(iy + 2), hl
	ld	iy, (ix - 7)
	ld	a, (iy + 17)
	lea	hl, iy + 0
	ld	iy, (ix + 9)
	ld	(iy + 5), a
	push	hl
	pop	iy
	ld	a, (iy + 18)
	ld	h, 0
	ld	(ix - 4), h
	ld	de, (ix - 6)
	ld	d, h
	ld	e, a
	ld	(ix - 10), de
	ld	de, 0
	ld	d, e
	ld	iy, (ix - 7)
	ld	a, (iy + 19)
	ld	(ix - 3), h
	ld	bc, (ix - 5)
	ld	b, h
	ld	c, a
	ld	a, d
	ld	l, 8
	call	__lshl
	push	bc
	pop	hl
	ld	e, a
	ld	bc, (ix - 10)
	ld	a, d
	call	__ladd
	ld	(ix - 10), hl
	ld	iy, (ix - 7)
	ld	a, (iy + 20)
	ld	h, 0
	ld	(ix - 2), h
	ld	bc, (ix - 4)
	ld	b, h
	ld	c, a
	ld	a, d
	ld	l, 16
	call	__lshl
	ld	hl, (ix - 10)
	call	__ladd
	ld	(ix - 10), hl
	ld	a, (iy + 21)
	ld	h, 0
	ld	(ix - 1), h
	ld	bc, (ix - 3)
	ld	b, h
	ld	c, a
	ld	l, 24
	ld	a, d
	call	__lshl
	ld	hl, (ix - 10)
	call	__ladd
	ld	iy, (ix + 9)
	ld	(iy + 6), hl
	ld	(iy + 9), e
	ld	iy, (ix - 7)
	ld	a, (iy + 22)
	ld	hl, 0
	push	hl
	pop	de
	ld	e, a
	ld	(ix - 10), de
	ld	a, (iy + 23)
	ld	l, a
	push	hl
	pop	de
	ld	c, 8
	call	__ishl
	ld	bc, (ix - 10)
	add	hl, bc
	ld	(ix - 10), hl
	ld	iy, (ix - 7)
	ld	a, (iy + 24)
	ld	e, a
	ex	de, hl
	ld	c, 16
	call	__ishl
	ex	de, hl
	ld	hl, (ix - 10)
	add	hl, de
	ld	iy, (ix + 9)
	ld	(iy + 10), hl
	ld	iy, (ix - 7)
	ld	a, (iy + 25)
	lea	hl, iy + 0
	ld	iy, (ix + 9)
	ld	(iy + 13), a
	ld	d, 0
	push	hl
	pop	iy
	ld	e, (iy + 26)
	ld	a, (iy + 27)
	ld	h, d
	ld	l, a
	ld	h, l
	ld	l, d
	add.sis	hl, de
	ld	iy, (ix + 9)
	ld	(iy + 14), l
	ld	(iy + 15), h
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end16
.Lfunc_end16:
	.size	_lib_get_strip, .Lfunc_end16-_lib_get_strip
                                        ; -- End function
	.section	.text._lib_book_read_count,"ax",@progbits
	.globl	_lib_book_read_count            ; -- Begin function lib_book_read_count
	.type	_lib_book_read_count,@function
_lib_book_read_count:                   ; @lib_book_read_count
; %bb.0:
	ld	hl, -8
	call	__frameset
	ld	iy, (ix + 6)
	ld	bc, _book_count
	ld.sis	de, 0
	ld	hl, (iy + 4)
	ld	(ix - 6), hl
	ld	iyl, e
	ld	iyh, d
	ld	hl, (_index_data)
	ld	(ix - 3), hl
	push	bc
	pop	hl
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 6
	call	__imulu
	ex	de, hl
	ld	hl, (ix - 3)
	add	hl, de
	ld	(ix - 3), hl
	ld	c, iyl
	ld	b, iyh
	.local	.LBB17_1
.LBB17_1:                               ; =>This Inner Loop Header: Depth=1
	ld	hl, (ix - 6)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	jr	z, .LBB17_3
; %bb.2:                                ;   in Loop: Header=BB17_1 Depth=1
	push	iy
	ex	(sp), hl
	ld	(ix - 8), l
	ld	(ix - 7), h
	pop	hl
	ld	iy, (ix + 6)
	ld	de, (iy + 2)
	ld	iyl, c
	ld	iyh, b
	add.sis	iy, de
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, (ix - 3)
	add	iy, de
	ld	a, (iy + 17)
	push	hl
	ld	l, (ix - 8)
	ld	h, (ix - 7)
	ex	(sp), hl
	pop	iy
	ld	l, 1
	and	a, l
	ld	e, a
	ld	d, 0
	add.sis	iy, de
	inc.sis	bc
	jp	.LBB17_1
	.local	.LBB17_3
.LBB17_3:
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end17
.Lfunc_end17:
	.size	_lib_book_read_count, .Lfunc_end17-_lib_book_read_count
                                        ; -- End function
	.section	.text._lib_save_strip,"ax",@progbits
	.globl	_lib_save_strip                 ; -- Begin function lib_save_strip
	.type	_lib_save_strip,@function
_lib_save_strip:                        ; @lib_save_strip
; %bb.0:
	ld	hl, -15
	call	__frameset
	ld	hl, _.str.5.29
	ld	de, _.str.2.4
	xor	a, a
	ld	(ix - 12), a
	push	de
	push	hl
	call	_ti_Open
	ld	iyl, a
	pop	hl
	pop	hl
	or	a, a
	jp	z, .LBB18_8
; %bb.1:
	ld	hl, _book_count
	ld	bc, 6
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	call	__imulu
	push	hl
	pop	bc
	or	a, a
	sbc	hl, hl
	ld	de, (ix + 6)
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	ld	de, 17
	add	hl, de
	ld	(ix - 15), iy
	push	iy
	ld	de, 0
	push	de
	push	hl
	call	_ti_Seek
	pop	de
	pop	de
	pop	de
	ld	de, -1
	or	a, a
	sbc	hl, de
	jr	nz, .LBB18_3
; %bb.2:
	ld	hl, (ix - 15)
	push	hl
	call	_ti_Close
	pop	hl
	jp	.LBB18_8
	.local	.LBB18_3
.LBB18_3:
	ld	iy, (ix + 9)
	ld	a, (iy + 5)
	ld	(ix - 9), a
	ld	de, (iy + 6)
	ld	h, (iy + 9)
	ld	a, e
	ld	(ix - 8), a
	ld	a, d
	ld	(ix - 7), a
	ld	l, 16
	push	de
	pop	bc
	ld	a, h
	call	__lshru
	ld	a, c
	ld	(ix - 6), a
	ld	l, 24
	push	de
	pop	bc
	ld	a, h
	call	__lshru
	ld	a, c
	ld	(ix - 5), a
	ld	hl, (iy + 10)
	ld	a, l
	ld	(ix - 4), a
	ld	a, h
	ld	(ix - 3), a
	ld	c, 16
	call	__ishru
	ld	a, l
	ld	(ix - 2), a
	ld	a, (iy + 13)
	ld	(ix - 1), a
	ld	hl, (ix - 15)
	push	hl
	ld	hl, 1
	push	hl
	ld	hl, 9
	push	hl
	pea	ix - 9
	call	_ti_Write
	ld	(ix - 12), hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 15)
	push	hl
	ld	hl, 1
	push	hl
	call	_ti_SetArchiveStatus
	ex	de, hl
	pop	hl
	pop	hl
	ld	hl, (ix - 12)
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	ld	a, -1
	ld	c, a
	jr	z, .LBB18_5
; %bb.4:
	ld	c, b
	.local	.LBB18_5
.LBB18_5:
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB18_7
; %bb.6:
	ld	a, b
	.local	.LBB18_7
.LBB18_7:
	and	a, c
	ld	l, a
	ld	(ix - 12), l
	ld	hl, (ix - 15)
	push	hl
	call	_ti_Close
	pop	hl
	call	_lib_open
	.local	.LBB18_8
.LBB18_8:
	ld	a, (ix - 12)                    ; 1-byte Folded Reload
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end18
.Lfunc_end18:
	.size	_lib_save_strip, .Lfunc_end18-_lib_save_strip
                                        ; -- End function
	.section	.text._lib_title,"ax",@progbits
	.globl	_lib_title                      ; -- Begin function lib_title
	.type	_lib_title,@function
_lib_title:                             ; @lib_title
; %bb.0:
	ld	hl, -5
	call	__frameset
	ld	bc, (ix + 6)
	ld	de, 0
	sbc.sis	hl, hl
	adc.sis	hl, bc
	jp	z, .LBB19_4
; %bb.1:
	ld	hl, (_index_data)
	push	hl
	pop	iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB19_4
; %bb.2:
	ld	de, 0
	ld	e, c
	ld	d, b
	add	iy, de
	ld	e, (iy)
	ld	d, 0
	ld	a, (iy + 1)
	ld	h, d
	ld	l, a
	ld	h, l
	ld	l, d
	add.sis	hl, de
	ld	(ix - 3), iy
	ld	a, (iy + 2)
	ld	de, 0
	push	de
	pop	iy
	ld	(ix - 5), l
	ld	(ix - 4), h
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	bc, 3
	add	iy, bc
	dec	c
	lea	hl, iy + 0
	call	__ishru
	ld	e, a
	push	de
	pop	bc
	call	__imulu
	ld	de, -1201
	add	hl, de
	inc	de
	or	a, a
	sbc	hl, de
	ld	de, 0
	jr	c, .LBB19_4
; %bb.3:
	ld	hl, _title_scratch
	ld	iy, (ix - 3)
	pea	iy + 5
	push	hl
	ld	(ix - 3), a                     ; 1-byte Folded Spill
	call	_zx0_Decompress
	ld	de, _title_scratch
	pop	hl
	pop	hl
	ld	l, (ix - 5)
	ld	h, (ix - 4)
	ld	iy, (ix + 9)
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix + 12)
	ld	a, (ix - 3)
	ld	(hl), a
	.local	.LBB19_4
.LBB19_4:
	ex	de, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end19
.Lfunc_end19:
	.size	_lib_title, .Lfunc_end19-_lib_title
                                        ; -- End function
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	ld	hl, -8
	call	__frameset
	call	_gfx_Begin
	ld	hl, 1
	push	hl
	call	_gfx_SetDraw
	pop	hl
	call	_ui_set_chrome_palette
	call	_input_reset
	call	_render_init
	or	a, a
	jr	nz, .LBB20_2
; %bb.1:
	ld	hl, _.str.1.6
	push	hl
	ld	hl, _.str.5
	push	hl
	call	_ui_message
	pop	hl
	pop	hl
	call	_gfx_End
	ld	hl, 1
	jp	.LBB20_12
	.local	.LBB20_2
.LBB20_2:
	call	_lib_open
	.local	.LBB20_3
.LBB20_3:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB20_4 Depth 2
                                        ;       Child Loop BB20_7 Depth 3
	ld.sis	hl, 0
	ld	(ix - 3), l
	ld	(ix - 2), h
	.local	.LBB20_4
.LBB20_4:                               ;   Parent Loop BB20_3 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB20_7 Depth 3
	pea	ix - 3
	call	_ui_book_menu
	ex	de, hl
	pop	hl
	push	de
	pop	hl
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	jr	z, .LBB20_11
; %bb.5:                                ;   in Loop: Header=BB20_4 Depth=2
	ex	de, hl
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	z, .LBB20_9
; %bb.6:                                ; %.preheader
                                        ;   in Loop: Header=BB20_4 Depth=2
	ld	hl, (ix - 3)
	ld	(ix - 8), hl
	.local	.LBB20_7
.LBB20_7:                               ;   Parent Loop BB20_3 Depth=1
                                        ;     Parent Loop BB20_4 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	pea	ix - 5
	push	hl
	call	_ui_strip_menu
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB20_4
; %bb.8:                                ;   in Loop: Header=BB20_7 Depth=3
	ld	hl, (ix - 5)
	push	hl
	call	_viewer_run
	pop	hl
	call	_ui_set_chrome_palette
	ld	hl, (ix - 8)
	jr	.LBB20_7
	.local	.LBB20_9
.LBB20_9:                               ;   in Loop: Header=BB20_3 Depth=1
	call	_render_free
	call	_ui_sync_screen
	call	_lib_open
	call	_render_init
	or	a, a
	jr	nz, .LBB20_3
; %bb.10:
	ld	hl, _.str.1.6
	push	hl
	ld	hl, _.str.5
	push	hl
	call	_ui_message
	pop	hl
	pop	hl
	.local	.LBB20_11
.LBB20_11:                              ; %.loopexit
	call	_render_free
	call	_gfx_End
	or	a, a
	sbc	hl, hl
	.local	.LBB20_12
.LBB20_12:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end20
.Lfunc_end20:
	.size	_main, .Lfunc_end20-_main
                                        ; -- End function
	.section	.text._render_init,"ax",@progbits
	.globl	_render_init                    ; -- Begin function render_init
	.type	_render_init,@function
_render_init:                           ; @render_init
; %bb.0:
	ld	hl, -9
	call	__frameset
	ld	bc, 256
	ld	hl, _expand
	ld	(ix - 9), hl
	ld	de, 0
	ld	a, 4
	ld	(ix - 3), de
	ld	(ix - 6), de
	.local	.LBB21_1
.LBB21_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB21_3
; %bb.2:                                ;   in Loop: Header=BB21_1 Depth=1
	push	de
	pop	hl
	ld	c, a
	call	__ishru
	push	hl
	pop	iy
	ld	hl, (ix - 3)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 3840
	call	__sand
	ld	c, iyl
	ld	b, iyh
	call	__sor
	ld	bc, 256
	ld	iy, (ix - 9)
	ld	(iy), l
	ld	(iy + 1), h
	inc	de
	ld	hl, (ix - 3)
	add	hl, bc
	ld	(ix - 3), hl
	lea	iy, iy + 2
	ld	(ix - 9), iy
	jp	.LBB21_1
	.local	.LBB21_3
.LBB21_3:
	xor	a, a
	ld	(_cache_slots), a
	.local	.LBB21_4
.LBB21_4:                               ; =>This Inner Loop Header: Depth=1
	ld	de, 36
	ld	hl, (ix - 6)
	or	a, a
	sbc	hl, de
	jr	z, .LBB21_7
; %bb.5:                                ;   in Loop: Header=BB21_4 Depth=1
	ld	(ix - 3), a                     ; 1-byte Folded Spill
	ld	hl, 5120
	push	hl
	call	_malloc
	ex	de, hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB21_10
; %bb.6:                                ;   in Loop: Header=BB21_4 Depth=1
	ld	hl, _cache_data
	ld	bc, (ix - 6)
	add	hl, bc
	ld	(hl), de
	ld	a, (ix - 3)                     ; 1-byte Folded Reload
	ld	e, a
	inc	e
	inc	a
	ld	(_cache_slots), a
	push	bc
	pop	hl
	ld	bc, 3
	add	hl, bc
	ld	(ix - 6), hl
	ld	a, e
	jr	.LBB21_4
	.local	.LBB21_7
.LBB21_7:
	ld	a, 12
	.local	.LBB21_8
.LBB21_8:                               ; %.thread
	ld	(ix - 3), a
	call	_render_reset
	ld	a, (ix - 3)                     ; 1-byte Folded Reload
	.local	.LBB21_9
.LBB21_9:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB21_10
.LBB21_10:
	ld	a, (ix - 3)                     ; 1-byte Folded Reload
	cp	a, 2
	jr	nc, .LBB21_8
; %bb.11:
	call	_render_free
	xor	a, a
	jr	.LBB21_9
	.local	.Lfunc_end21
.Lfunc_end21:
	.size	_render_init, .Lfunc_end21-_render_init
                                        ; -- End function
	.section	.text._render_free,"ax",@progbits
	.globl	_render_free                    ; -- Begin function render_free
	.type	_render_free,@function
_render_free:                           ; @render_free
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	iy, _cache_data
	ld	a, (_cache_slots)
	ld	de, 0
	ld	e, a
	.local	.LBB22_1
.LBB22_1:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB22_3
; %bb.2:                                ;   in Loop: Header=BB22_1 Depth=1
	ld	hl, (iy)
	push	hl
	ld	(ix - 3), iy
	ld	(ix - 6), de
	call	_free
	ld	de, (ix - 6)
	ld	iy, (ix - 3)
	pop	hl
	lea	iy, iy + 3
	dec	de
	jr	.LBB22_1
	.local	.LBB22_3
.LBB22_3:
	xor	a, a
	ld	(_cache_slots), a
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end22
.Lfunc_end22:
	.size	_render_free, .Lfunc_end22-_render_free
                                        ; -- End function
	.section	.text._render_reset,"ax",@progbits
	.globl	_render_reset                   ; -- Begin function render_reset
	.type	_render_reset,@function
_render_reset:                          ; @render_reset
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	hl, _cache_used
	ld	(ix - 6), hl
	ld	hl, _cache_band
	ld	(ix - 3), hl
	ld	a, (_cache_slots)
	ld	bc, 0
	ld	c, a
	.local	.LBB23_1
.LBB23_1:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB23_3
; %bb.2:                                ;   in Loop: Header=BB23_1 Depth=1
	ld.sis	hl, -1
	ld	iy, (ix - 3)
	ld	(iy), l
	ld	(iy + 1), h
	ld	de, (ix - 6)
	inc.sis	hl
	push	de
	pop	iy
	ld	(iy), l
	ld	(iy + 1), h
	ld	iy, (ix - 3)
	lea	iy, iy + 2
	ld	(ix - 3), iy
	push	de
	pop	iy
	lea	iy, iy + 2
	ld	(ix - 6), iy
	dec	bc
	jr	.LBB23_1
	.local	.LBB23_3
.LBB23_3:
	ld	hl, _cache_clock
	ld.sis	de, 0
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end23
.Lfunc_end23:
	.size	_render_reset, .Lfunc_end23-_render_reset
                                        ; -- End function
	.section	.text._render_band,"ax",@progbits
	.globl	_render_band                    ; -- Begin function render_band
	.type	_render_band,@function
_render_band:                           ; @render_band
; %bb.0:
	ld	hl, -25
	call	__frameset
	ld	a, 1
	ld	(ix - 13), a
	ld	hl, _cache_band
	ld	de, _cache_data-3
	ld	(ix - 9), de
	ld	de, _cache_used-2
	ld	(ix - 12), de
	ld	de, _cache_used+2
	ld	(ix - 6), de
	ld	iyl, 0
	ld	a, (_cache_slots)
	ld	de, 0
	ld	e, a
	inc	de
	ld	(ix - 16), hl
	.local	.LBB24_1
.LBB24_1:                               ; =>This Inner Loop Header: Depth=1
	ld	hl, (ix - 12)
	ld	(ix - 19), hl
	ld	bc, (ix - 9)
	dec	de
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB24_4
; %bb.2:                                ;   in Loop: Header=BB24_1 Depth=1
	ld	iy, (ix - 19)
	lea	hl, iy + 2
	push	bc
	pop	iy
	ld	(ix - 12), hl
	ld	(ix - 25), iy
	lea	hl, iy + 3
	ld	(ix - 9), hl
	ld	iy, (ix - 16)
	lea	hl, iy + 2
	ld	(ix - 22), hl
	ld	hl, (iy)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	bc, (ix + 9)
	or	a, a
	sbc.sis	hl, bc
	ld	iyl, 0
	ld	hl, (ix - 22)
	ld	(ix - 16), hl
	jp	nz, .LBB24_1
; %bb.3:
	ld	hl, _cache_clock
	push	hl
	pop	iy
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	iy, (ix - 19)
	ld	(iy + 2), l
	ld	(iy + 3), h
	ld	iy, (ix - 25)
	ld	bc, (iy + 3)
	jp	.LBB24_14
	.local	.LBB24_4
.LBB24_4:
	push	af
	ld	a, iyl
	ld	(ix - 9), a                     ; 1-byte Folded Spill
	pop	af
	cp	a, 2
	jr	nc, .LBB24_6
; %bb.5:
	ld	a, 1
	.local	.LBB24_6
.LBB24_6:
	ld	iy, 0
	lea	de, iy + 0
	ld	e, a
	dec	de
	ld	bc, (ix + 9)
	.local	.LBB24_7
.LBB24_7:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB24_11
; %bb.8:                                ;   in Loop: Header=BB24_7 Depth=1
	ld	hl, (ix - 6)
	ld	hl, (hl)
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	ld	iyl, a
	add	iy, iy
	lea	bc, iy + 0
	ld	iy, _cache_used
	add	iy, bc
	ld	bc, (iy)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	ld	l, (ix - 13)                    ; 1-byte Folded Reload
	ld	c, l
	jr	c, .LBB24_10
; %bb.9:                                ;   in Loop: Header=BB24_7 Depth=1
	ld	c, a
	.local	.LBB24_10
.LBB24_10:                              ;   in Loop: Header=BB24_7 Depth=1
	ld	iy, (ix - 6)
	lea	iy, iy + 2
	ld	(ix - 6), iy
	inc	l
	ld	(ix - 13), l
	dec	de
	ld	(ix - 9), c                     ; 1-byte Folded Spill
	ld	bc, (ix + 9)
	ld	iy, 0
	jp	.LBB24_7
	.local	.LBB24_11
.LBB24_11:
	pea	ix - 3
	push	bc
	ld	hl, (ix + 6)
	push	hl
	ld	(ix - 6), iy
	call	_csx_band
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 6)
	ld	l, (ix - 9)                     ; 1-byte Folded Reload
	ld	(ix - 6), hl
	sbc	hl, hl
	adc	hl, de
	ld	bc, 0
	ld.sis	iy, -1
	jr	z, .LBB24_13
; %bb.12:
	ld	bc, 3
	ld	hl, (ix - 6)
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _cache_data
	add	hl, bc
	ld	(ix - 9), hl
	ld	bc, (hl)
	push	de
	push	bc
	call	_zx0_Decompress
	pop	hl
	pop	hl
	ld	hl, _cache_clock
	ld	de, (hl)
	inc.sis	de
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	hl, (ix - 6)
	add	hl, hl
	push	hl
	pop	bc
	ld	hl, _cache_used
	add	hl, bc
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	hl, (ix - 9)
	ld	bc, (hl)
	ld	hl, (ix + 9)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	.local	.LBB24_13
.LBB24_13:
	ld	hl, (ix - 6)
	add	hl, hl
	ex	de, hl
	ld	hl, _cache_band
	add	hl, de
	push	de
	ld	e, iyl
	ld	d, iyh
	ld	(hl), e
	inc	hl
	ld	(hl), d
	pop	de
	.local	.LBB24_14
.LBB24_14:
	push	bc
	pop	hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end24
.Lfunc_end24:
	.size	_render_band, .Lfunc_end24-_render_band
                                        ; -- End function
	.section	.text._render_set_palette,"ax",@progbits
	.globl	_render_set_palette             ; -- Begin function render_set_palette
	.type	_render_set_palette,@function
_render_set_palette:                    ; @render_set_palette
; %bb.0:
	call	__frameset0
	ld	de, 0
	ld	bc, 32
	.local	.LBB25_1
.LBB25_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB25_3
; %bb.2:                                ;   in Loop: Header=BB25_1 Depth=1
	ld	hl, (ix + 6)
	add	hl, de
	push	bc
	pop	iy
	ld	bc, 250
	add	hl, bc
	lea	bc, iy + 0
	ld	iy, (hl)
	ld	hl, -1900032
	add	hl, de
	push	de
	ld	e, iyl
	ld	d, iyh
	ld	(hl), e
	inc	hl
	ld	(hl), d
	pop	de
	ex	de, hl
	ld	de, 2
	add	hl, de
	ex	de, hl
	jr	.LBB25_1
	.local	.LBB25_3
.LBB25_3:
	pop	ix
	ret
	.local	.Lfunc_end25
.Lfunc_end25:
	.size	_render_set_palette, .Lfunc_end25-_render_set_palette
                                        ; -- End function
	.section	.text._render_view,"ax",@progbits
	.globl	_render_view                    ; -- Begin function render_view
	.type	_render_view,@function
_render_view:                           ; @render_view
; %bb.0:
	ld	hl, -65
	call	__frameset
	ld	iy, (ix + 6)
	ld	a, (ix + 9)
	ld.sis	de, 320
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 12
	call	__imulu
	push	hl
	pop	bc
	add	iy, bc
	ld	bc, 202
	ld	(ix - 9), iy
	add	iy, bc
	ld	(ix - 18), iy
	ld	bc, (iy)
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
                                        ; kill: def $a killed $a
	sbc	a, a
	ex.sis	de, hl
	or	a, a
	sbc.sis	hl, bc
	ld	e, h
                                        ; kill: def $l killed $l killed $hl
	srl	e
	rr	l
	bit	0, a
	jr	nz, .LBB26_2
; %bb.1:
	ld.sis	hl, 0
	jp	.LBB26_3
	.local	.LBB26_2
.LBB26_2:
                                        ; kill: def $l killed $l def $hl
	ld	h, e
	.local	.LBB26_3
.LBB26_3:
	ld	(ix - 15), l
	ld	(ix - 14), h
	or	a, a
	sbc	hl, hl
	bit	0, a
	jr	nz, .LBB26_5
; %bb.4:
	ld	hl, (ix + 12)
	.local	.LBB26_5
.LBB26_5:
	ld	(ix - 3), hl
	ld	hl, 248
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, (ix - 3)
	ld	bc, 320
	call	__idivu
	ld	(ix - 6), hl
	ld	hl, (ix - 3)
	ld	de, 319
	add	hl, de
	call	__idivu
	ld	de, 208
	ld	iy, (ix - 9)
	add	iy, de
	ld	de, (iy)
	ld	bc, 0
	ld	c, e
	ld	b, d
	ld	(ix - 12), hl
	or	a, a
	sbc	hl, bc
	jp	c, .LBB26_7
; %bb.6:
	dec.sis	de
                                        ; kill: def $de killed $de killed $ude def $ude
	ld	(ix - 12), de
	.local	.LBB26_7
.LBB26_7:
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	l, (ix - 15)
	ld	h, (ix - 14)
	ld	e, l
	ld	d, h
	ld	(ix - 21), de
	ld	c, 5
	ld	de, (ix + 15)
	push	de
	pop	hl
	call	__ishru
	ld	(ix - 30), hl
	ex	de, hl
	ld	de, 239
	add	hl, de
	call	__ishru
	ld	(ix - 15), hl
	ld	bc, 65535
	call	__iand
	ld	de, 210
	ld	iy, (ix - 9)
	add	iy, de
	ld	de, (iy)
	ld	bc, 0
	ld	c, e
	ld	b, d
	or	a, a
	sbc	hl, bc
	jp	c, .LBB26_9
; %bb.8:
	dec.sis	de
                                        ; kill: def $de killed $de killed $ude def $ude
	ld	(ix - 15), de
	.local	.LBB26_9
.LBB26_9:
	ld	hl, (ix - 21)
	ld	de, (ix - 3)
	or	a, a
	sbc	hl, de
	ld	(ix - 21), hl
	ld	de, (ix - 6)
	.local	.LBB26_10
.LBB26_10:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB26_22 Depth 2
                                        ;       Child Loop BB26_34 Depth 3
                                        ;         Child Loop BB26_39 Depth 4
	ld	hl, (ix - 12)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, de
	jp	c, .LBB26_43
; %bb.11:                               ;   in Loop: Header=BB26_10 Depth=1
	ld	iy, 0
	lea	bc, iy + 0
	ld	(ix - 6), de
	ld	c, e
	ld	b, d
	ld	hl, (ix - 18)
	ld	hl, (hl)
	lea	de, iy + 0
	ld	e, l
	ld	d, h
	ld	(ix - 27), bc
	push	bc
	pop	hl
	ld	bc, -320
	call	__imulu
	push	hl
	pop	iy
	add	iy, de
	lea	hl, iy + 0
	ld	de, 320
	or	a, a
	sbc	hl, de
	jr	c, .LBB26_13
; %bb.12:                               ;   in Loop: Header=BB26_10 Depth=1
	ld	iy, 320
	.local	.LBB26_13
.LBB26_13:                              ;   in Loop: Header=BB26_10 Depth=1
	ld	(ix - 24), iy
	inc	iy
	lea	hl, iy + 0
	call	__ishru_1
	ld	(ix - 33), hl
	ld	hl, (ix - 27)
	ld	bc, 320
	call	__imulu
	ex	de, hl
	or	a, a
	ld	hl, (ix - 3)
	sbc	hl, de
	ld	bc, 0
	jr	c, .LBB26_15
; %bb.14:                               ;   in Loop: Header=BB26_10 Depth=1
	push	hl
	pop	bc
	.local	.LBB26_15
.LBB26_15:                              ;   in Loop: Header=BB26_10 Depth=1
	ld	iy, (ix - 21)
	add	iy, de
	lea	hl, iy + 0
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB26_17
; %bb.16:                               ;   in Loop: Header=BB26_10 Depth=1
	ld	iy, 0
	.local	.LBB26_17
.LBB26_17:                              ;   in Loop: Header=BB26_10 Depth=1
	ld	hl, (ix - 24)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	(ix - 24), bc
	or	a, a
	sbc.sis	hl, bc
	lea	de, iy + 0
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	bc, 0
	ld	c, iyl
	ld	b, iyh
	ld	hl, 320
	ld	(ix - 36), de
	or	a, a
	sbc	hl, de
	push	hl
	pop	de
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB26_19
; %bb.18:                               ;   in Loop: Header=BB26_10 Depth=1
	ld	e, iyl
	ld	d, iyh
	.local	.LBB26_19
.LBB26_19:                              ;   in Loop: Header=BB26_10 Depth=1
	ld	(ix - 27), de
	sbc.sis	hl, hl
	adc.sis	hl, de
	ld	de, (ix - 6)
	jr	nz, .LBB26_21
	.local	.LBB26_20
.LBB26_20:                              ; %.loopexit6
                                        ;   in Loop: Header=BB26_10 Depth=1
	inc.sis	de
	jp	.LBB26_10
	.local	.LBB26_21
.LBB26_21:                              ;   in Loop: Header=BB26_10 Depth=1
	ld	iy, (ix - 24)
	lea	hl, iy + 0
	call	__ishru_1
	ld	bc, 32767
	call	__iand
	ld	(ix - 48), hl
	lea	hl, iy + 0
	ld	bc, 1
	call	__iand
	ld	(ix - 51), hl
	ld	hl, (ix - 27)
                                        ; kill: def $hl killed $hl killed $uhl
	dec.sis	hl
	ld	(ix - 53), l
	ld	(ix - 52), h
	ld	hl, (ix - 30)
	ld	c, l
	ld	b, h
	.local	.LBB26_22
.LBB26_22:                              ;   Parent Loop BB26_10 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB26_34 Depth 3
                                        ;         Child Loop BB26_39 Depth 4
	ld	hl, (ix - 15)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	jp	c, .LBB26_20
; %bb.23:                               ;   in Loop: Header=BB26_22 Depth=2
	ld	(ix - 24), c
	ld	(ix - 23), b
	ld	bc, (ix - 9)
	push	bc
	pop	hl
	ld	de, 212
	add	hl, de
	ld	iy, (hl)
	push	bc
	pop	hl
	ld	de, 210
	add	hl, de
	ld	hl, (hl)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	bc, (ix - 6)
                                        ; kill: def $bc killed $bc killed $ubc
	call	__smulu
	ex.sis	de, hl
	ld	c, (ix - 24)
	ld	b, (ix - 23)
	add.sis	iy, bc
	add.sis	iy, de
	push	iy
	ld	hl, (ix + 6)
	push	hl
	call	_render_band
	ex	de, hl
	pop	hl
	pop	hl
	ld	(ix - 39), de
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB26_25
	.local	.LBB26_24
.LBB26_24:                              ; %.loopexit
                                        ;   in Loop: Header=BB26_22 Depth=2
	ld	c, (ix - 24)
	ld	b, (ix - 23)
	inc.sis	bc
	ld	de, (ix - 6)
	jp	.LBB26_22
	.local	.LBB26_25
.LBB26_25:                              ;   in Loop: Header=BB26_22 Depth=2
	or	a, a
	sbc	hl, hl
	ld	e, (ix - 24)
	ld	d, (ix - 23)
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	hl
	pop	bc
	ld	hl, (ix - 9)
	ld	de, 204
	add	hl, de
	ld	hl, (hl)
	or	a, a
	sbc	hl, bc
	push	hl
	pop	iy
	ld	de, 32
	or	a, a
	sbc	hl, de
	jr	c, .LBB26_27
; %bb.26:                               ;   in Loop: Header=BB26_22 Depth=2
	ld	iy, 32
	.local	.LBB26_27
.LBB26_27:                              ;   in Loop: Header=BB26_22 Depth=2
	ld	(ix - 42), iy
	or	a, a
	ld	hl, (ix + 15)
	sbc	hl, bc
	ld	iy, 0
	jr	c, .LBB26_29
; %bb.28:                               ;   in Loop: Header=BB26_22 Depth=2
	push	hl
	pop	iy
	.local	.LBB26_29
.LBB26_29:                              ;   in Loop: Header=BB26_22 Depth=2
	push	bc
	pop	hl
	ld	bc, (ix + 15)
	or	a, a
	sbc	hl, bc
	push	hl
	pop	de
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB26_31
; %bb.30:                               ;   in Loop: Header=BB26_22 Depth=2
	ld	de, 0
	.local	.LBB26_31
.LBB26_31:                              ;   in Loop: Header=BB26_22 Depth=2
	lea	hl, iy + 0
	ld	bc, 255
	call	__iand
	ld	(ix - 59), hl
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	ld	bc, (ix - 42)
	ld	a, c
	sub	a, l
	ld	iyl, a
	ld	bc, 0
	ld	c, iyl
	ld	hl, 240
	ld	(ix - 56), de
	or	a, a
	sbc	hl, de
	push	hl
	pop	de
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB26_33
; %bb.32:                               ;   in Loop: Header=BB26_22 Depth=2
	ld	e, iyl
	.local	.LBB26_33
.LBB26_33:                              ;   in Loop: Header=BB26_22 Depth=2
	ld	bc, (ix - 48)
	ld	hl, (ix - 39)
	add	hl, bc
	ld	(ix - 39), hl
	or	a, a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	de, 0
	.local	.LBB26_34
.LBB26_34:                              ;   Parent Loop BB26_10 Depth=1
                                        ;     Parent Loop BB26_22 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB26_39 Depth 4
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB26_24
; %bb.35:                               ;   in Loop: Header=BB26_34 Depth=3
	ld	(ix - 62), bc
	push	de
	pop	hl
	ld	bc, (ix - 59)
	add	hl, bc
	ld	bc, (ix - 33)
	call	__imulu
	ld	(ix - 45), hl
	ld	iy, (-1900524)
	push	de
	pop	hl
	ld	bc, (ix - 56)
	add	hl, bc
	ld	bc, 320
	call	__imulu
	push	hl
	pop	bc
	add	iy, bc
	ld	bc, (ix - 36)
	add	iy, bc
	ld	(ix - 42), iy
	ld	iy, (ix - 39)
	ld	bc, (ix - 45)
	add	iy, bc
	ld	hl, (ix - 51)
	bit	0, l
	ld	(ix - 65), de
	jp	nz, .LBB26_37
; %bb.36:                               ;   in Loop: Header=BB26_34 Depth=3
	ld	(ix - 45), iy
	ld	hl, (ix - 27)
                                        ; kill: def $hl killed $hl killed $uhl
	jr	.LBB26_39
	.local	.LBB26_37
.LBB26_37:                              ;   in Loop: Header=BB26_34 Depth=3
	ld	a, (iy)
	inc	iy
	ld	(ix - 45), iy
	ld	l, 15
	and	a, l
	ld	l, a
	ld	iy, (ix - 42)
	ld	(iy), l
	inc	iy
	ld	(ix - 42), iy
	ld	l, (ix - 53)
	ld	h, (ix - 52)
	jr	.LBB26_39
	.local	.LBB26_38
.LBB26_38:                              ;   in Loop: Header=BB26_39 Depth=4
	ld	hl, (ix - 45)
	ld	a, (hl)
	inc	hl
	ld	(ix - 45), hl
	or	a, a
	sbc	hl, hl
	ld	l, a
	add	hl, hl
	push	hl
	pop	bc
	ld	hl, _expand
	add	hl, bc
	ld	hl, (hl)
	ld	iy, (ix - 42)
	ld	(iy), l
	ld	(iy + 1), h
	lea	iy, iy + 2
	ld	(ix - 42), iy
	ld.sis	bc, -2
	ex.sis	de, hl
	add.sis	hl, bc
	.local	.LBB26_39
.LBB26_39:                              ;   Parent Loop BB26_10 Depth=1
                                        ;     Parent Loop BB26_22 Depth=2
                                        ;       Parent Loop BB26_34 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	ld	e, l
	ld	d, h
	ld.sis	bc, 2
	or	a, a
	sbc.sis	hl, bc
	jr	nc, .LBB26_38
; %bb.40:                               ;   in Loop: Header=BB26_34 Depth=3
	sbc.sis	hl, hl
	adc.sis	hl, de
	jr	z, .LBB26_42
; %bb.41:                               ;   in Loop: Header=BB26_34 Depth=3
	ld	hl, (ix - 45)
	ld	a, (hl)
	ld	b, 4
	call	__bshru
	ld	hl, (ix - 42)
	ld	(hl), a
	.local	.LBB26_42
.LBB26_42:                              ;   in Loop: Header=BB26_34 Depth=3
	ld	de, (ix - 65)
	inc	de
	ld	bc, (ix - 62)
	jp	.LBB26_34
	.local	.LBB26_43
.LBB26_43:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end26
.Lfunc_end26:
	.size	_render_view, .Lfunc_end26-_render_view
                                        ; -- End function
	.section	.text._ui_set_chrome_palette,"ax",@progbits
	.globl	_ui_set_chrome_palette          ; -- Begin function ui_set_chrome_palette
	.type	_ui_set_chrome_palette,@function
_ui_set_chrome_palette:                 ; @ui_set_chrome_palette
; %bb.0:
	ld	iy, -1899536
	ld	hl, -1899534
	ld	de, -1899528
	ld.sis	bc, 32767
	ld	(iy), c
	ld	(iy + 1), b
	ld.sis	bc, 3171
	ld	(hl), c
	inc	hl
	ld	(hl), b
	ld.sis	hl, 5497
	ld	iy, -1899532
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 19026
	ld	iy, -1899530
	ld	(iy), l
	ld	(iy + 1), h
	ex	de, hl
	ld.sis	de, 25471
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	hl, 24
	push	hl
	push	hl
	ld	hl, 248
	push	hl
	push	hl
	push	hl
	ld	hl, 240
	push	hl
	call	_set_ramp
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 48
	push	hl
	ld	hl, 16
	push	hl
	ld	hl, 255
	push	hl
	ld	hl, 218
	push	hl
	ld	hl, 198
	push	hl
	ld	hl, 244
	push	hl
	call	_set_ramp
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ret
	.local	.Lfunc_end27
.Lfunc_end27:
	.size	_ui_set_chrome_palette, .Lfunc_end27-_ui_set_chrome_palette
                                        ; -- End function
	.section	.text._set_ramp,"ax",@progbits
	.type	_set_ramp,@function             ; -- Begin function set_ramp
_set_ramp:                              ; @set_ramp
; %bb.0:
	ld	hl, -26
	call	__frameset
	ld	a, (ix + 6)
	ld	(ix - 5), a
	ld	c, (ix + 9)
	ld	l, (ix + 18)
	ld	a, (ix + 21)
	ld	iy, 4
	ld	d, iyh
	ld	e, l
	ld	b, d
	ld	l, e
	ld	h, d
	ld	(ix - 9), c
	ld	(ix - 8), b
	or	a, a
	sbc.sis	hl, bc
	ld	(ix - 18), l
	ld	(ix - 17), h
	ld	c, (ix + 12)
	ld	b, d
	ld.sis	hl, 24
	ld	(ix - 11), c
	ld	(ix - 10), b
	or	a, a
	sbc.sis	hl, bc
	ld	(ix - 20), l
	ld	(ix - 19), h
	ld	h, d
	ld	l, a
	ld	(ix - 7), e
	ld	(ix - 6), d
	ld	c, (ix + 15)
	ld	b, d
	ld	(ix - 13), c
	ld	(ix - 12), b
	or	a, a
	sbc.sis	hl, bc
	ld	(ix - 22), l
	ld	(ix - 21), h
	ld.sis	bc, 0
	ld	(ix - 4), c
	ld	(ix - 3), b
	ld	(ix - 2), c
	ld	(ix - 1), b
	.local	.LBB28_1
.LBB28_1:                               ; =>This Inner Loop Header: Depth=1
	lea	hl, iy + 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB28_3
; %bb.2:                                ;   in Loop: Header=BB28_1 Depth=1
	ld	l, c
	ld	h, b
	ld	(ix - 24), l
	ld	(ix - 23), h
	ld.sis	bc, 3
	call	__sdivs
	ld	(ix - 16), iy
	ld	e, (ix - 9)
	ld	d, (ix - 8)
	ld	a, l
	add	a, e
	ld	iyl, a
	ld	l, (ix - 4)
	ld	h, (ix - 3)
	call	__sdivs
	ld	e, (ix - 11)
	ld	d, (ix - 10)
	ld	a, l
	add	a, e
	ld	l, a
	ld	(ix - 26), l
	ld	l, (ix - 2)
	ld	h, (ix - 1)
	call	__sdivs
	ld	e, (ix - 13)
	ld	d, (ix - 12)
	ld	a, l
	add	a, e
	ld	l, a
	ld	(ix - 25), l
	ld	a, iyl
	ld	b, c
	call	__bshru
	push	hl
	ld	l, (ix - 7)
	ld	h, (ix - 6)
	ex	(sp), hl
	pop	iy
	ld	iyl, a
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	c, 10
	call	__sshl
	ex.sis	de, hl
	ld	a, (ix - 26)                    ; 1-byte Folded Reload
	call	__bshru
	ld	l, a
	ex	de, hl
	ld	d, iyh
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add.sis	hl, de
	ld	a, (ix - 25)                    ; 1-byte Folded Reload
	call	__bshru
	ld	c, a
	push	iy
	ex	(sp), hl
	ld	(ix - 7), l
	ld	(ix - 6), h
	pop	hl
	ld	b, iyh
	add.sis	hl, bc
	ld	iy, 0
	ld	a, (ix - 5)                     ; 1-byte Folded Reload
	ld	iyl, a
	add	iy, iy
	lea	bc, iy + 0
	ld	iy, -1900032
	add	iy, bc
	ld	(iy), l
	ld	(iy + 1), h
	inc	a
	ld	(ix - 5), a
	ld	e, (ix - 18)
	ld	d, (ix - 17)
	ld	l, (ix - 24)
	ld	h, (ix - 23)
	add.sis	hl, de
	ld	c, l
	ld	b, h
	ld	e, (ix - 20)
	ld	d, (ix - 19)
	ld	l, (ix - 4)
	ld	h, (ix - 3)
	add.sis	hl, de
	ld	(ix - 4), l
	ld	(ix - 3), h
	ld	e, (ix - 22)
	ld	d, (ix - 21)
	ld	l, (ix - 2)
	ld	h, (ix - 1)
	add.sis	hl, de
	ld	(ix - 2), l
	ld	(ix - 1), h
	ld	iy, (ix - 16)
	dec	iy
	jp	.LBB28_1
	.local	.LBB28_3
.LBB28_3:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end28
.Lfunc_end28:
	.size	_set_ramp, .Lfunc_end28-_set_ramp
                                        ; -- End function
	.section	.text._ui_header,"ax",@progbits
	.globl	_ui_header                      ; -- Begin function ui_header
	.type	_ui_header,@function
_ui_header:                             ; @ui_header
; %bb.0:
	call	__frameset0
	ld	hl, 250
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 18
	push	hl
	ld	hl, 320
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_gfx_FillRectangle_NoClip
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 248
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 250
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	hl, 5
	push	hl
	inc	hl
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_gfx_PrintStringXY
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end29
.Lfunc_end29:
	.size	_ui_header, .Lfunc_end29-_ui_header
                                        ; -- End function
	.section	.text._ui_footer,"ax",@progbits
	.globl	_ui_footer                      ; -- Begin function ui_footer
	.type	_ui_footer,@function
_ui_footer:                             ; @ui_footer
; %bb.0:
	call	__frameset0
	ld	hl, 251
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 16
	push	hl
	ld	hl, 320
	push	hl
	ld	hl, 224
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_FillRectangle_NoClip
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 248
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 251
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	hl, 228
	push	hl
	ld	hl, 6
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_gfx_PrintStringXY
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end30
.Lfunc_end30:
	.size	_ui_footer, .Lfunc_end30-_ui_footer
                                        ; -- End function
	.section	.text._ui_draw_title,"ax",@progbits
	.globl	_ui_draw_title                  ; -- Begin function ui_draw_title
	.type	_ui_draw_title,@function
_ui_draw_title:                         ; @ui_draw_title
; %bb.0:
	ld	hl, -27
	call	__frameset
	ld	hl, (ix + 6)
	pea	ix - 4
	pea	ix - 3
	push	hl
	call	_lib_title
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	ld	(ix - 10), de
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB31_2
	.local	.LBB31_1
.LBB31_1:                               ; %.loopexit5
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB31_2
.LBB31_2:
	ld	a, (ix + 15)
	ld	bc, 3
	ld	de, (ix - 3)
	ld	iy, 0
	ld	iyl, e
	ld	iyh, d
	lea	hl, iy + 0
	add	hl, bc
	dec	c
	call	__ishru
	ld	(ix - 20), hl
	ld	bc, (ix + 9)
	add	iy, bc
	ld.sis	hl, 320
	or	a, a
	sbc.sis	hl, bc
	ld	(ix - 7), l
	ld	(ix - 6), h
	ld	bc, 321
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB31_4
; %bb.3:
	ld	l, e
	ld	h, d
	ld	(ix - 7), l
	ld	(ix - 6), h
	.local	.LBB31_4
.LBB31_4:
	bit	0, a
	jr	nz, .LBB31_6
; %bb.5:
	ld	a, -16
	jr	.LBB31_7
	.local	.LBB31_6
.LBB31_6:
	ld	a, -12
	.local	.LBB31_7
.LBB31_7:
	ld	(ix - 21), a
	ld	iy, 0
	ld	a, (ix - 4)
	or	a, a
	sbc	hl, hl
	push	hl
	pop	de
	ld	e, a
	ld	c, (ix - 7)
	ld	b, (ix - 6)
	ld	l, c
	ld	h, b
	ld	(ix - 13), hl
	ld	hl, (ix + 12)
	ld	bc, 320
	call	__imulu
	push	hl
	pop	bc
	ld	hl, (ix + 9)
	add	hl, bc
	ld	bc, 240
	ld	(ix - 7), hl
	.local	.LBB31_8
.LBB31_8:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB31_12 Depth 2
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jp	z, .LBB31_1
; %bb.9:                                ;   in Loop: Header=BB31_8 Depth=1
	ld	(ix - 16), de
	lea	hl, iy + 0
	ld	de, (ix + 12)
	add	hl, de
	or	a, a
	sbc	hl, bc
	jr	c, .LBB31_11
	.local	.LBB31_10
.LBB31_10:                              ; %.loopexit
                                        ;   in Loop: Header=BB31_8 Depth=1
	inc	iy
	ld	hl, (ix - 7)
	ld	de, 320
	add	hl, de
	ld	(ix - 7), hl
	ld	de, (ix - 16)
	ld	bc, 240
	jr	.LBB31_8
	.local	.LBB31_11
.LBB31_11:                              ;   in Loop: Header=BB31_8 Depth=1
	lea	hl, iy + 0
	ld	bc, (ix - 20)
	call	__imulu
	ex	de, hl
	ld	hl, (ix - 10)
	add	hl, de
	ld	(ix - 24), hl
	ld	hl, (-1900524)
	ld	de, (ix - 7)
	add	hl, de
	ld	(ix - 27), hl
	xor	a, a
	ld	(ix - 17), a                    ; 1-byte Folded Spill
	ld	de, 0
	.local	.LBB31_12
.LBB31_12:                              ;   Parent Loop BB31_8 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	de
	pop	hl
	ld	bc, (ix - 13)
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB31_10
; %bb.13:                               ;   in Loop: Header=BB31_12 Depth=2
	push	de
	pop	hl
	ld	c, 2
	call	__ishru
	push	hl
	pop	bc
	ld	hl, (ix - 24)
	add	hl, bc
	ld	c, -1
	ld	a, (ix - 17)
	xor	a, c
	ld	c, a
	ld	b, 6
	ld	a, c
	and	a, b
	ld	b, a
	ld	a, (hl)
	call	__bshru
	ld	l, 3
	and	a, l
	ld	l, a
	or	a, a
	jr	z, .LBB31_15
; %bb.14:                               ;   in Loop: Header=BB31_12 Depth=2
	ld	c, (ix - 21)
	ld	a, l
	add	a, c
	ld	c, a
	ld	hl, (ix - 27)
	add	hl, de
	ld	(hl), c
	.local	.LBB31_15
.LBB31_15:                              ;   in Loop: Header=BB31_12 Depth=2
	inc	de
	ld	l, 2
	ld	c, (ix - 17)
	ld	a, c
	add	a, l
	ld	c, a
	ld	(ix - 17), c
	jr	.LBB31_12
	.local	.Lfunc_end31
.Lfunc_end31:
	.size	_ui_draw_title, .Lfunc_end31-_ui_draw_title
                                        ; -- End function
	.section	.text._ui_message,"ax",@progbits
	.globl	_ui_message                     ; -- Begin function ui_message
	.type	_ui_message,@function
_ui_message:                            ; @ui_message
; %bb.0:
	call	__frameset0
	ld	hl, 248
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, 249
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 248
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	hl, 100
	push	hl
	ld	hl, 10
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_gfx_PrintStringXY
	ld	de, (ix + 9)
	pop	hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB32_2
; %bb.1:
	ld	hl, 118
	push	hl
	ld	hl, 10
	push	hl
	push	de
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB32_2
.LBB32_2:
	call	_gfx_SwapDraw
	call	_input_reset
	.local	.LBB32_3
.LBB32_3:                               ; =>This Inner Loop Header: Depth=1
	call	_input_scan
	call	_input_idle
	bit	0, a
	jr	z, .LBB32_3
	.local	.LBB32_4
.LBB32_4:                               ; %.preheader1
                                        ; =>This Inner Loop Header: Depth=1
	call	_input_scan
	call	_input_idle
	bit	0, a
	jr	nz, .LBB32_4
	.local	.LBB32_5
.LBB32_5:                               ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	call	_input_scan
	call	_input_idle
	bit	0, a
	jr	z, .LBB32_5
; %bb.6:
	pop	ix
	ret
	.local	.Lfunc_end32
.Lfunc_end32:
	.size	_ui_message, .Lfunc_end32-_ui_message
                                        ; -- End function
	.section	.text._ui_book_menu,"ax",@progbits
	.globl	_ui_book_menu                   ; -- Begin function ui_book_menu
	.type	_ui_book_menu,@function
_ui_book_menu:                          ; @ui_book_menu
; %bb.0:
	ld	hl, -62
	call	__frameset
	ld	iy, (ix + 6)
	ld.sis	bc, 0
	lea	de, ix - 7
	lea	hl, ix - 31
	ld	(ix - 49), hl
	lea	hl, ix - 37
	ld	(ix - 55), hl
	ld	hl, _book_count
	ld	hl, (hl)
	ld	(ix - 7), l
	ld	(ix - 6), h
	ld	hl, (iy)
	ld	(ix - 5), l
	ld	(ix - 4), h
	ld	(ix - 3), c
	ld	(ix - 2), b
	or	a, a
	sbc	hl, hl
	push	hl
	ld	(ix - 43), de
	push	de
	call	_list_move
	pop	hl
	pop	hl
	.local	.LBB33_1
.LBB33_1:                               ; %.loopexit3
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB33_8 Depth 2
                                        ;     Child Loop BB33_15 Depth 2
	ld	hl, 248
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, _.str.17
	push	hl
	call	_ui_header
	pop	hl
	ld	bc, (ix - 7)
	sbc.sis	hl, hl
	adc.sis	hl, bc
	jr	nz, .LBB33_3
; %bb.2:                                ;   in Loop: Header=BB33_1 Depth=1
	ld	hl, 251
	push	hl
	ld	(ix - 40), bc
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 248
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	hl, 90
	push	hl
	ld	hl, 10
	push	hl
	ld	hl, _.str.1.18
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 108
	push	hl
	ld	hl, 10
	push	hl
	ld	hl, _.str.2.19
	push	hl
	call	_gfx_PrintStringXY
	ld	bc, (ix - 40)
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB33_3
.LBB33_3:                               ;   in Loop: Header=BB33_1 Depth=1
	ld	hl, (ix - 3)
	ld	(ix - 58), hl
	ld	e, l
	ld	d, h
	ld	hl, (ix - 5)
	ld	(ix - 46), hl
	or	a, a
	ld	l, c
	ld	h, b
	sbc.sis	hl, de
	ld.sis	bc, 0
	jr	c, .LBB33_5
; %bb.4:                                ;   in Loop: Header=BB33_1 Depth=1
	ld	c, l
	ld	b, h
	.local	.LBB33_5
.LBB33_5:                               ;   in Loop: Header=BB33_1 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	pop	iy
	ld	l, e
	ld	h, d
	ld	(ix - 40), hl
	ld	hl, (ix - 46)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	(ix - 46), iy
	ld	l, c
	ld	h, b
	ld.sis	de, 10
	sbc.sis	hl, de
	jr	c, .LBB33_7
; %bb.6:                                ;   in Loop: Header=BB33_1 Depth=1
	ld.sis	bc, 10
	.local	.LBB33_7
.LBB33_7:                               ;   in Loop: Header=BB33_1 Depth=1
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	bc, 20
	call	__imulu
	push	hl
	pop	iy
	ld	hl, (ix - 46)
	ld	de, (ix - 40)
	or	a, a
	sbc	hl, de
	ld	(ix - 46), hl
	ld.sis	hl, 0
	ld	c, l
	ld	b, h
	or	a, a
	sbc	hl, hl
	ld	(ix - 40), hl
	.local	.LBB33_8
.LBB33_8:                               ;   Parent Loop BB33_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	ld	de, (ix - 40)
	or	a, a
	sbc	hl, de
	jp	z, .LBB33_14
; %bb.9:                                ;   in Loop: Header=BB33_8 Depth=2
	ld	(ix - 61), iy
	push	bc
	ld	hl, (ix - 43)
	push	hl
	ld	(ix - 52), bc
	call	_draw_row_background
	pop	hl
	pop	hl
	ld	hl, (ix - 58)
                                        ; kill: def $hl killed $hl killed $uhl def $uhl
	ld	de, (ix - 52)
	add.sis	hl, de
	ld	de, (ix - 55)
	push	de
	push	hl
	call	_lib_get_book
	pop	hl
	pop	hl
	ld	de, (ix - 37)
	ld	iy, (ix - 40)
	ld	bc, 24
	add	iy, bc
	ld	hl, (ix - 46)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, -1
	jr	z, .LBB33_11
; %bb.10:                               ;   in Loop: Header=BB33_8 Depth=2
	ld	a, 0
	.local	.LBB33_11
.LBB33_11:                              ;   in Loop: Header=BB33_8 Depth=2
	ld	(ix - 62), a
	ld	l, a
	push	hl
	push	iy
	ld	hl, 10
	push	hl
	push	de
	call	_ui_draw_title
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 55)
	push	hl
	call	_lib_book_read_count
	pop	de
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, (ix - 33)
	ld	bc, 0
	ld	c, l
	ld	b, h
	push	bc
	push	de
	ld	hl, _.str.3
	push	hl
	ld	hl, (ix - 49)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 251
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	bit	0, (ix - 62)                    ; 1-byte Folded Reload
	ld	a, -4
	ld	l, a
	jr	nz, .LBB33_13
; %bb.12:                               ;   in Loop: Header=BB33_8 Depth=2
	ld	a, -8
	ld	l, a
	.local	.LBB33_13
.LBB33_13:                              ;   in Loop: Header=BB33_8 Depth=2
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	hl, (ix - 49)
	push	hl
	call	_strlen
	pop	de
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	hl, 312
	or	a, a
	sbc	hl, de
	ld	iy, (ix - 40)
	ld	de, 28
	add	iy, de
	push	iy
	push	hl
	ld	hl, (ix - 49)
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	de, 20
	ld	iy, (ix - 40)
	add	iy, de
	ld	hl, (ix - 46)
	dec	hl
	ld	(ix - 46), hl
	ld	bc, (ix - 52)
	inc.sis	bc
	ld	(ix - 40), iy
	ld	iy, (ix - 61)
	jp	.LBB33_8
	.local	.LBB33_14
.LBB33_14:                              ;   in Loop: Header=BB33_1 Depth=1
	ld	hl, (ix - 43)
	push	hl
	call	_draw_scrollbar
	pop	hl
	ld	hl, _.str.4
	push	hl
	call	_ui_footer
	pop	hl
	call	_gfx_SwapDraw
	.local	.LBB33_15
.LBB33_15:                              ;   Parent Loop BB33_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	call	_input_scan
	ld	hl, (ix - 43)
	push	hl
	call	_list_navigate
	ld	e, a
	pop	hl
	ld	a, (_current+6)
	ld	c, a
	ld	h, 1
	ld	a, c
	and	a, h
	ld	l, a
	bit	0, l
	jr	z, .LBB33_18
; %bb.16:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB33_15 Depth=2
	ld	a, (_previous+6)
	and	a, h
	ld	l, a
	bit	0, l
	jr	nz, .LBB33_18
; %bb.17:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB33_15 Depth=2
	ld	hl, (ix - 7)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jr	nz, .LBB33_25
	.local	.LBB33_18
.LBB33_18:                              ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB33_15 Depth=2
	ld	a, (_current+1)
	bit	5, a
	jr	z, .LBB33_20
; %bb.19:                               ; %input_pressed.exit1
                                        ;   in Loop: Header=BB33_15 Depth=2
	ld	a, (_previous+1)
	bit	5, a
	jr	z, .LBB33_23
	.local	.LBB33_20
.LBB33_20:                              ; %input_pressed.exit1.thread
                                        ;   in Loop: Header=BB33_15 Depth=2
	bit	6, c
	jr	z, .LBB33_22
; %bb.21:                               ; %input_pressed.exit2
                                        ;   in Loop: Header=BB33_15 Depth=2
	ld	a, (_previous+6)
	bit	6, a
	jr	z, .LBB33_24
	.local	.LBB33_22
.LBB33_22:                              ; %input_pressed.exit2.thread
                                        ;   in Loop: Header=BB33_15 Depth=2
	bit	0, e
	jr	z, .LBB33_15
	jp	.LBB33_1
	.local	.LBB33_23
.LBB33_23:
	ld	hl, 2
	jr	.LBB33_26
	.local	.LBB33_24
.LBB33_24:
	ld	hl, 1
	jr	.LBB33_26
	.local	.LBB33_25
.LBB33_25:
	ld	hl, (ix - 5)
	ld	iy, (ix + 6)
	ld	(iy), l
	ld	(iy + 1), h
	or	a, a
	sbc	hl, hl
	.local	.LBB33_26
.LBB33_26:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end33
.Lfunc_end33:
	.size	_ui_book_menu, .Lfunc_end33-_ui_book_menu
                                        ; -- End function
	.section	.text._list_move,"ax",@progbits
	.type	_list_move,@function            ; -- Begin function list_move
_list_move:                             ; @list_move
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	iy, (ix + 6)
	ld	bc, (iy)
	sbc.sis	hl, hl
	adc.sis	hl, bc
	jp	z, .LBB34_10
; %bb.1:
	ld	de, (ix + 9)
	ld	hl, (iy + 2)
	ld	iy, 0
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	add	iy, de
	ld	de, 1
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	lea	hl, iy + 0
	jp	p, .LBB34_3
; %bb.2:
	or	a, a
	sbc	hl, hl
	.local	.LBB34_3
.LBB34_3:
	ld	de, 0
	ld	e, c
	ld	d, b
	push	hl
	pop	bc
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	push	bc
	pop	hl
	call	pe, __setflag
	jp	m, .LBB34_5
; %bb.4:
	dec	de
	ex	de, hl
	.local	.LBB34_5
.LBB34_5:
	ld	iy, (ix + 6)
	ld	(iy + 2), l
	ld	(iy + 3), h
	ld	(ix - 3), hl
	ld	bc, 65535
	call	__iand
	push	hl
	pop	bc
	ld	hl, (iy + 4)
	ld	de, 0
	ld	e, l
	ld	d, h
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, .LBB34_7
; %bb.6:
	ld	hl, (ix - 3)
	jr	.LBB34_9
	.local	.LBB34_7
.LBB34_7:
	ex	de, hl
	ld	de, 10
	add	hl, de
	ex	de, hl
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	c, .LBB34_10
; %bb.8:
	ld.sis	de, -9
	ld	hl, (ix - 3)
	add.sis	hl, de
	.local	.LBB34_9
.LBB34_9:
	ld	(iy + 4), l
	ld	(iy + 5), h
	.local	.LBB34_10
.LBB34_10:
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end34
.Lfunc_end34:
	.size	_list_move, .Lfunc_end34-_list_move
                                        ; -- End function
	.section	.text._draw_row_background,"ax",@progbits
	.type	_draw_row_background,@function  ; -- Begin function draw_row_background
_draw_row_background:                   ; @draw_row_background
; %bb.0:
	call	__frameset0
	ld	iy, (ix + 6)
	ld	bc, (ix + 9)
	ld	de, 0
	ld	iy, (iy + 4)
	push	de
	pop	hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	e, c
	ld	d, b
	add	hl, de
	ld	iy, (ix + 6)
	ld	bc, (iy + 2)
	ld	de, 0
	ld	e, c
	ld	d, b
	or	a, a
	sbc	hl, de
	jr	z, .LBB35_2
; %bb.1:
	ld	l, -8
	jr	.LBB35_3
	.local	.LBB35_2
.LBB35_2:
	ld	l, -4
	.local	.LBB35_3
.LBB35_3:
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	l, 20
	ld	de, (ix + 9)
	ld	h, e
	mlt	hl
	ld	e, 22
	ld	a, l
	add	a, e
	ld	l, a
	ld	de, 20
	push	de
	ld	de, 320
	push	de
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_FillRectangle_NoClip
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end35
.Lfunc_end35:
	.size	_draw_row_background, .Lfunc_end35-_draw_row_background
                                        ; -- End function
	.section	.text._draw_scrollbar,"ax",@progbits
	.type	_draw_scrollbar,@function       ; -- Begin function draw_scrollbar
_draw_scrollbar:                        ; @draw_scrollbar
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	hl, (ix + 6)
	ld	iy, (hl)
	ld.sis	de, 11
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, de
	jp	c, .LBB36_4
; %bb.1:
	ld.sis	hl, 2000
	ld	de, 0
	push	de
	pop	bc
	ld	c, iyl
	ld	b, iyh
	ld	(ix - 3), bc
	call	__sdivu
                                        ; kill: def $hl killed $hl def $uhl
	ld.sis	bc, 9
	push	hl
	pop	iy
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	jr	nc, .LBB36_3
; %bb.2:
	ld.sis	iy, 8
	.local	.LBB36_3
.LBB36_3:
	ld	(ix - 6), iy
	ld	e, iyl
	ld	d, iyh
	ld	hl, 200
	or	a, a
	sbc	hl, de
	ld	iy, (ix + 6)
	ld	bc, (iy + 4)
	ld	e, c
	ld	d, b
	push	de
	pop	bc
	call	__imulu
	ld	de, -10
	ld	iy, (ix - 3)
	add	iy, de
	lea	bc, iy + 0
	call	__idivu
	ld	(ix - 3), hl
	ld	hl, 251
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	l, 22
	ld	de, (ix - 3)
	ld	a, e
	add	a, l
	ld	l, a
	ld	de, (ix - 6)
	push	de
	ld	de, 3
	push	de
	push	hl
	ld	hl, 316
	push	hl
	call	_gfx_FillRectangle_NoClip
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB36_4
.LBB36_4:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end36
.Lfunc_end36:
	.size	_draw_scrollbar, .Lfunc_end36-_draw_scrollbar
                                        ; -- End function
	.section	.text._list_navigate,"ax",@progbits
	.type	_list_navigate,@function        ; -- Begin function list_navigate
_list_navigate:                         ; @list_navigate
; %bb.0:
	call	__frameset0
	ld	hl, 1800
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB37_2
; %bb.1:
	scf
	sbc	hl, hl
	jr	.LBB37_8
	.local	.LBB37_2
.LBB37_2:
	ld	hl, 1793
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB37_4
; %bb.3:
	ld	hl, 1
	jr	.LBB37_8
	.local	.LBB37_4
.LBB37_4:
	ld	hl, 1794
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB37_6
; %bb.5:
	ld	hl, -10
	jr	.LBB37_8
	.local	.LBB37_6
.LBB37_6:
	ld	hl, 1796
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB37_10
; %bb.7:
	ld	hl, 10
	.local	.LBB37_8
.LBB37_8:
	ld	de, (ix + 6)
	push	hl
	push	de
	call	_list_move
	ld	a, 1
	pop	hl
	pop	hl
	.local	.LBB37_9
.LBB37_9:
	pop	ix
	ret
	.local	.LBB37_10
.LBB37_10:
	xor	a, a
	jr	.LBB37_9
	.local	.Lfunc_end37
.Lfunc_end37:
	.size	_list_navigate, .Lfunc_end37-_list_navigate
                                        ; -- End function
	.section	.text._ui_strip_menu,"ax",@progbits
	.globl	_ui_strip_menu                  ; -- Begin function ui_strip_menu
	.type	_ui_strip_menu,@function
_ui_strip_menu:                         ; @ui_strip_menu
; %bb.0:
	ld	hl, -84
	call	__frameset
	ld	hl, (ix + 6)
	lea	de, ix - 13
	ld	(ix - 59), de
	lea	de, ix - 37
	ld	(ix - 68), de
	pea	ix - 7
	push	hl
	call	_lib_get_book
	pop	hl
	pop	hl
	ld	bc, (ix - 3)
	ld	(ix - 13), c
	ld	(ix - 12), b
	ld.sis	hl, 0
	ld	(ix - 11), l
	ld	(ix - 10), h
	ld	(ix - 9), l
	ld	(ix - 8), h
	ld	hl, (ix - 5)
	ld	(ix - 82), hl
                                        ; kill: def $hl killed $hl killed $uhl
	ld	(ix - 84), l
	ld	(ix - 83), h
	ld	e, 1
	.local	.LBB38_1
.LBB38_1:                               ; %input_pressed.exit1
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB38_7 Depth 2
	bit	0, e
	jp	z, .LBB38_17
; %bb.2:                                ;   in Loop: Header=BB38_1 Depth=1
	ld	hl, 248
	push	hl
	ld	(ix - 56), bc
	call	_gfx_FillScreen
	pop	hl
	ld	hl, _.str.5.22
	push	hl
	call	_ui_header
	pop	hl
	ld	bc, (ix - 9)
	ld	hl, (ix - 11)
	ld	(ix - 65), hl
	ld	de, 0
	or	a, a
	ld	hl, (ix - 56)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	(ix - 62), bc
	sbc.sis	hl, bc
	ld.sis	iy, 0
	jr	c, .LBB38_4
; %bb.3:                                ;   in Loop: Header=BB38_1 Depth=1
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	.local	.LBB38_4
.LBB38_4:                               ;   in Loop: Header=BB38_1 Depth=1
	push	de
	pop	bc
	ld	hl, (ix - 62)
	ld	c, l
	ld	b, h
	ld	(ix - 56), bc
	push	de
	pop	hl
	ld	bc, (ix - 65)
	ld	l, c
	ld	h, b
	ld	(ix - 65), hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	bc, 10
	or	a, a
	sbc.sis	hl, bc
	jr	c, .LBB38_6
; %bb.5:                                ;   in Loop: Header=BB38_1 Depth=1
	ld.sis	iy, 10
	.local	.LBB38_6
.LBB38_6:                               ;   in Loop: Header=BB38_1 Depth=1
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	bc, 20
	call	__imulu
	push	hl
	pop	iy
	ld	hl, (ix - 65)
	ld	de, (ix - 56)
	or	a, a
	sbc	hl, de
	ld	(ix - 56), hl
	ld	hl, (ix - 82)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	de, (ix - 62)
	add.sis	hl, de
	ld	(ix - 79), l
	ld	(ix - 78), h
	ld.sis	hl, 0
	ld	c, l
	ld	b, h
	or	a, a
	sbc	hl, hl
	push	hl
	pop	de
	ld	(ix - 65), hl
	.local	.LBB38_7
.LBB38_7:                               ;   Parent Loop BB38_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	ld	(ix - 62), de
	or	a, a
	sbc	hl, de
	jp	z, .LBB38_16
; %bb.8:                                ;   in Loop: Header=BB38_7 Depth=2
	ld	(ix - 77), iy
	push	bc
	ld	hl, (ix - 59)
	push	hl
	ld	(ix - 74), bc
	call	_draw_row_background
	pop	hl
	pop	hl
	ld	l, (ix - 79)
	ld	h, (ix - 78)
                                        ; kill: def $hl killed $hl def $uhl
	ld	de, (ix - 74)
	add.sis	hl, de
	pea	ix - 53
	push	hl
	call	_lib_get_strip
	pop	hl
	pop	hl
	ld	hl, (ix - 65)
	ld	bc, 20
	call	__imulu
	ld	(ix - 71), hl
	ld	hl, (ix - 56)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, -4
	ld	l, a
	jr	z, .LBB38_10
; %bb.9:                                ;   in Loop: Header=BB38_7 Depth=2
	ld	a, -8
	ld	l, a
	.local	.LBB38_10
.LBB38_10:                              ;   in Loop: Header=BB38_7 Depth=2
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	a, (ix - 48)
	ld	l, 1
	and	a, l
	ld	l, a
	bit	0, l
	jr	nz, .LBB38_12
; %bb.11:                               ;   in Loop: Header=BB38_7 Depth=2
	ld	iy, (ix - 62)
	lea	hl, iy + 0
	ld	de, 28
	add	hl, de
	ld	(ix - 71), hl
	jr	.LBB38_13
	.local	.LBB38_12
.LBB38_12:                              ;   in Loop: Header=BB38_7 Depth=2
	ld	hl, 250
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 28
	ex	de, hl
	ld	hl, (ix - 71)
	add	hl, de
	ld	(ix - 71), hl
	ld	hl, (ix - 62)
	add	hl, de
	push	hl
	ld	hl, 2
	push	hl
	ld	hl, _.str.6
	push	hl
	call	_gfx_PrintStringXY
	ld	iy, (ix - 62)
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB38_13
.LBB38_13:                              ;   in Loop: Header=BB38_7 Depth=2
	ld	de, (ix - 39)
	ld	bc, 24
	add	iy, bc
	ld	hl, (ix - 56)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	hl, -1
	jr	z, .LBB38_15
; %bb.14:                               ;   in Loop: Header=BB38_7 Depth=2
	ld	hl, 0
	.local	.LBB38_15
.LBB38_15:                              ;   in Loop: Header=BB38_7 Depth=2
	push	hl
	push	iy
	ld	hl, 18
	push	hl
	push	de
	call	_ui_draw_title
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 51)
	ld	c, 10
	call	__ishru
	push	hl
	ld	hl, _.str.7
	push	hl
	ld	hl, (ix - 68)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 251
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, (ix - 68)
	push	hl
	call	_strlen
	pop	de
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	hl, 312
	or	a, a
	sbc	hl, de
	ld	de, (ix - 71)
	push	de
	push	hl
	ld	hl, (ix - 68)
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 65)
	inc	hl
	ld	(ix - 65), hl
	ld	hl, (ix - 62)
	ld	de, 20
	add	hl, de
	ld	de, (ix - 56)
	dec	de
	ld	(ix - 56), de
	ld	bc, (ix - 74)
	inc.sis	bc
	ex	de, hl
	ld	iy, (ix - 77)
	jp	.LBB38_7
	.local	.LBB38_16
.LBB38_16:                              ;   in Loop: Header=BB38_1 Depth=1
	ld	hl, (ix - 59)
	push	hl
	call	_draw_scrollbar
	pop	hl
	ld	hl, _.str.8
	push	hl
	call	_ui_footer
	pop	hl
	call	_gfx_SwapDraw
	.local	.LBB38_17
.LBB38_17:                              ;   in Loop: Header=BB38_1 Depth=1
	call	_input_scan
	ld	hl, (ix - 59)
	push	hl
	call	_list_navigate
	ld	e, a
	pop	hl
	ld	a, (_current+6)
	ld	d, a
	ld	h, 1
	ld	a, d
	and	a, h
	ld	l, a
	bit	0, l
	jr	nz, .LBB38_19
; %bb.18:                               ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB38_1 Depth=1
	ld	bc, (ix - 13)
	jr	.LBB38_22
	.local	.LBB38_19
.LBB38_19:                              ; %input_pressed.exit
                                        ;   in Loop: Header=BB38_1 Depth=1
	ld	a, (_previous+6)
	and	a, h
	ld	c, a
	ld	hl, (ix - 13)
	bit	0, c
	jr	nz, .LBB38_21
; %bb.20:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB38_1 Depth=1
	push	hl
	pop	bc
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jr	nz, .LBB38_25
	jr	.LBB38_22
	.local	.LBB38_21
.LBB38_21:                              ;   in Loop: Header=BB38_1 Depth=1
	push	hl
	pop	bc
	.local	.LBB38_22
.LBB38_22:                              ;   in Loop: Header=BB38_1 Depth=1
	bit	6, d
	jp	z, .LBB38_1
; %bb.23:                               ;   in Loop: Header=BB38_1 Depth=1
	ld	a, (_previous+6)
	bit	6, a
	jp	nz, .LBB38_1
; %bb.24:
	ld	hl, 1
	jr	.LBB38_26
	.local	.LBB38_25
.LBB38_25:
	ld	hl, (ix - 11)
	ld	e, (ix - 84)
	ld	d, (ix - 83)
	add.sis	hl, de
	ld	iy, (ix + 9)
	ld	(iy), l
	ld	(iy + 1), h
	or	a, a
	sbc	hl, hl
	.local	.LBB38_26
.LBB38_26:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end38
.Lfunc_end38:
	.size	_ui_strip_menu, .Lfunc_end38-_ui_strip_menu
                                        ; -- End function
	.section	.text._ui_sync_screen,"ax",@progbits
	.globl	_ui_sync_screen                 ; -- Begin function ui_sync_screen
	.type	_ui_sync_screen,@function
_ui_sync_screen:                        ; @ui_sync_screen
; %bb.0:
	xor	a, a
	ld	de, _sync_state
	ld	hl, _.str.9
	ld	bc, 12
	ld	(_sync_chunks_received), a
	ldir
	call	_input_reset
	call	_sync_draw
	ld	hl, _sync_progress
	push	hl
	call	_proto_run
	pop	hl
	bit	0, a
	jr	nz, .LBB39_2
; %bb.1:
	ld	hl, _.str.10
	ld	de, _.str.11
	push	de
	push	hl
	call	_ui_message
	pop	hl
	pop	hl
	.local	.LBB39_2
.LBB39_2:
	jp	_ui_set_chrome_palette
	.local	.Lfunc_end39
.Lfunc_end39:
	.size	_ui_sync_screen, .Lfunc_end39-_ui_sync_screen
                                        ; -- End function
	.section	.text._sync_draw,"ax",@progbits
	.type	_sync_draw,@function            ; -- Begin function sync_draw
_sync_draw:                             ; @sync_draw
; %bb.0:
	ld	hl, -43
	call	__frameset
	lea	hl, ix - 40
	ld	(ix - 43), hl
	ld	hl, 248
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, _.str.12
	push	hl
	call	_ui_header
	pop	hl
	ld	hl, 249
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 248
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	hl, 70
	push	hl
	ld	hl, 10
	push	hl
	ld	hl, _sync_state
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_sync_chunks_received)
	or	a, a
	sbc	hl, hl
	ld	l, a
	push	hl
	ld	hl, _.str.13
	push	hl
	ld	hl, (ix - 43)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 251
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 92
	push	hl
	ld	hl, 10
	push	hl
	ld	hl, (ix - 43)
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, _.str.14
	push	hl
	call	_ui_footer
	pop	hl
	call	_gfx_SwapDraw
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end40
.Lfunc_end40:
	.size	_sync_draw, .Lfunc_end40-_sync_draw
                                        ; -- End function
	.section	.text._sync_progress,"ax",@progbits
	.type	_sync_progress,@function        ; -- Begin function sync_progress
_sync_progress:                         ; @sync_progress
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	hl, (ix + 6)
	ld	de, _sync_state
	push	hl
	push	de
	call	_strcmp
	ex	de, hl
	pop	hl
	pop	hl
	ld	(ix - 3), de
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB41_2
; %bb.1:
	ld	hl, 32
	ld	de, _.str.15
	ld	bc, (ix + 6)
	push	bc
	push	de
	push	hl
	ld	hl, _sync_state
	push	hl
	call	_snprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB41_2
.LBB41_2:
	ld	hl, _.str.4.28
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_strcmp
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB41_4
; %bb.3:
	ld	hl, _sync_chunks_received
	inc	(hl)
	jr	.LBB41_5
	.local	.LBB41_4
.LBB41_4:
	ld	hl, (ix - 3)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB41_6
	.local	.LBB41_5
.LBB41_5:
	call	_sync_draw
	.local	.LBB41_6
.LBB41_6:                               ; %input_pressed.exit
	call	_input_scan
	ld	a, (_current+6)
	ld	l, a
	ld	a, (_previous+6)
	bit	6, a
	ld	a, -1
	ld	c, 0
	ld	e, a
	jr	nz, .LBB41_8
; %bb.7:                                ; %input_pressed.exit
	ld	e, c
	.local	.LBB41_8
.LBB41_8:                               ; %input_pressed.exit
	bit	6, l
	jr	z, .LBB41_10
; %bb.9:                                ; %input_pressed.exit
	ld	a, c
	.local	.LBB41_10
.LBB41_10:                              ; %input_pressed.exit
	or	a, e
	ld	l, a
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end41
.Lfunc_end41:
	.size	_sync_progress, .Lfunc_end41-_sync_progress
                                        ; -- End function
	.section	.text._proto_run,"ax",@progbits
	.globl	_proto_run                      ; -- Begin function proto_run
	.type	_proto_run,@function
_proto_run:                             ; @proto_run
; %bb.0:
	ld	hl, -53
	call	__frameset
	or	a, a
	sbc	hl, hl
	xor	a, a
	ld	iy, _handle_event
	ld	de, _descriptors
	ld	bc, 36106
	ld	(_host_device), hl
	ld	(_endpoint_out), hl
	ld	(_endpoint_in), hl
	ld	(_configured), a
	ld	(_finished), a
	ld	(_header_posted), a
	ld	(_header_ready), a
	ld	(_link_lost), a
	push	bc
	push	de
	push	hl
	push	iy
	call	_usb_Init
	pop	de
	pop	de
	pop	de
	pop	de
	ld	(ix - 25), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	nz, .LBB42_93
; %bb.1:
	lea	hl, ix - 17
	ld	(ix - 28), hl
	.local	.LBB42_2
.LBB42_2:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB42_65 Depth 2
                                        ;     Child Loop BB42_42 Depth 2
                                        ;     Child Loop BB42_55 Depth 2
                                        ;     Child Loop BB42_23 Depth 2
	ld	a, (_finished)
	bit	0, a
	jp	nz, .LBB42_93
; %bb.3:                                ;   in Loop: Header=BB42_2 Depth=1
	call	_usb_HandleEvents
	ld	a, (_link_lost)
	bit	0, a
	jr	z, .LBB42_5
; %bb.4:                                ;   in Loop: Header=BB42_2 Depth=1
	xor	a, a
	ld	(_link_lost), a
	ld	(_configured), a
	ld	(_header_posted), a
	ld	(_header_ready), a
	ld	bc, 0
	jr	.LBB42_10
	.local	.LBB42_5
.LBB42_5:                               ;   in Loop: Header=BB42_2 Depth=1
	ld	a, (_configured)
	bit	0, a
	ld	bc, 0
	jr	z, .LBB42_10
; %bb.6:                                ;   in Loop: Header=BB42_2 Depth=1
	ld	a, (_header_posted)
	bit	0, a
	jr	nz, .LBB42_10
; %bb.7:                                ;   in Loop: Header=BB42_2 Depth=1
	ld	a, (_header_ready)
	bit	0, a
	jr	nz, .LBB42_10
; %bb.8:                                ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, (_endpoint_out)
	ld	de, 0
	push	de
	ld	de, _request_arrived
	push	de
	ld	de, 8
	push	de
	ld	de, _request_header
	push	de
	push	hl
	call	_usb_ScheduleTransfer
	ld	bc, 0
	pop	de
	pop	de
	pop	de
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB42_10
; %bb.9:                                ;   in Loop: Header=BB42_2 Depth=1
	ld	a, 1
	ld	(_header_posted), a
	.local	.LBB42_10
.LBB42_10:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	a, (_header_ready)
	bit	0, a
	jp	z, .LBB42_16
; %bb.11:                               ;   in Loop: Header=BB42_2 Depth=1
	xor	a, a
	ld	(_header_ready), a
	ld	a, (_request_header)
	ld	l, a
	ld	(ix - 31), hl
	ld	a, (_request_header+1)
	ld	l, a
	ld	(ix - 34), hl
	ld	a, (_request_header+2)
	ld	l, a
	ld	(ix - 37), hl
	ld	a, (_request_header+3)
	ld	l, a
	ld	(ix - 43), hl
	ld	a, (_request_header+4)
	ld	d, 0
	ld	l, d
	ld	(ix - 22), l
	ld	iy, (ix - 24)
	ex	de, hl
	ld	iyh, e
	ex	de, hl
	ld	iyl, a
	ld	d, c
	ld	a, (_request_header+5)
	ld	(ix - 21), l
	ld	bc, (ix - 23)
	ld	b, l
	ld	c, a
	ld	a, d
	ld	l, 8
	call	__lshl
	push	bc
	pop	hl
	ld	e, a
	lea	bc, iy + 0
	ld	a, d
	call	__ladd
	push	hl
	pop	iy
	ld	a, (_request_header+6)
	ld	l, 0
	ld	(ix - 20), l
	ld	bc, (ix - 22)
	ld	b, l
	ld	c, a
	ld	a, d
	ld	l, 16
	call	__lshl
	lea	hl, iy + 0
	call	__ladd
	push	hl
	pop	iy
	ld	a, (_request_header+7)
	ld	l, 0
	ld	(ix - 19), l
	ld	bc, (ix - 21)
	ld	b, l
	ld	c, a
	ld	(ix - 40), d                    ; 1-byte Folded Spill
	ld	a, d
	ld	l, 24
	call	__lshl
	lea	hl, iy + 0
	call	__ladd
	push	hl
	pop	iy
	ld	c, e
	ld	hl, (ix - 31)
	ld	a, l
	dec	a
	cp	a, 8
	jr	c, .LBB42_20
; %bb.12:                               ;   in Loop: Header=BB42_2 Depth=1
	push	bc
	push	iy
	call	_drain
	pop	hl
	pop	hl
	ld	hl, 1
	push	hl
	ld	hl, (ix - 34)
	push	hl
	ld	hl, (ix - 31)
	.local	.LBB42_13
.LBB42_13:                              ;   in Loop: Header=BB42_2 Depth=1
	push	hl
	call	_reply
	pop	hl
	.local	.LBB42_14
.LBB42_14:                              ;   in Loop: Header=BB42_2 Depth=1
	pop	hl
	pop	hl
	bit	0, a
	ld	bc, 0
	jr	nz, .LBB42_16
	.local	.LBB42_15
.LBB42_15:                              ; %.loopexit
                                        ;   in Loop: Header=BB42_2 Depth=1
	xor	a, a
	ld	(_configured), a
	.local	.LBB42_16
.LBB42_16:                              ; %.loopexit10
                                        ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, (ix + 6)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB42_2
; %bb.17:                               ;   in Loop: Header=BB42_2 Depth=1
	ld	a, (_configured)
	bit	0, a
	ld	hl, _.str.31
	jr	nz, .LBB42_19
; %bb.18:                               ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, _.str.1.32
	.local	.LBB42_19
.LBB42_19:                              ;   in Loop: Header=BB42_2 Depth=1
	push	bc
	push	bc
	push	bc
	push	hl
	ld	hl, (ix + 6)
	call	__indcallhl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	jp	nz, .LBB42_2
	jp	.LBB42_93
	.local	.LBB42_20
.LBB42_20:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	de, 0
	ld	e, a
	ld	hl, JTI42_0
	add	hl, de
	add	hl, de
	add	hl, de
	ld	hl, (hl)
	jp	(hl)
	.local	.LBB42_21
.LBB42_21:                              ;   in Loop: Header=BB42_2 Depth=1
	push	bc
	push	iy
	call	_drain
	pop	hl
	pop	hl
	ld	hl, _strip_count
	ld	de, (hl)
	xor	a, a
	ld	(ix - 18), a
	ld	hl, (ix - 20)
	ld	h, d
	ld	(ix - 31), de
	ld	l, e
	ld	e, (ix - 40)                    ; 1-byte Folded Reload
	ld	bc, 14
	call	__lmulu
	ld	bc, 2
	call	__ladd
                                        ; kill: def $e killed $e def $ude
	push	de
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, (ix - 34)
	push	hl
	ld	hl, 2
	push	hl
	call	_send_header
	ld	bc, 0
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	jp	z, .LBB42_15
; %bb.22:                               ;   in Loop: Header=BB42_2 Depth=1
	ld	iy, (ix - 31)
	ld	a, iyl
	ld	(_stream), a
	ld	a, iyh
	ld	(_stream+1), a
	ld	hl, 2
	ld	(ix - 34), hl
	ld.sis	hl, 0
	ld	e, l
	ld	d, h
	.local	.LBB42_23
.LBB42_23:                              ;   Parent Loop BB42_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 37), de
	or	a, a
	sbc.sis	hl, de
	jp	z, .LBB42_52
; %bb.24:                               ;   in Loop: Header=BB42_23 Depth=2
	ld	bc, (ix - 34)
	push	bc
	pop	hl
	ld	de, -499
	add	hl, de
	ld	de, -513
	or	a, a
	sbc	hl, de
	jr	nc, .LBB42_26
; %bb.25:                               ;   in Loop: Header=BB42_23 Depth=2
	push	bc
	ld	hl, _stream
	push	hl
	call	_write_exact
	ld	bc, 0
	pop	hl
	pop	hl
	bit	0, a
	ld	hl, 0
	ld	(ix - 34), hl
	ld	de, (ix - 31)
	ld	hl, (ix - 37)
	jp	z, .LBB42_15
	jr	.LBB42_27
	.local	.LBB42_26
.LBB42_26:                              ;   in Loop: Header=BB42_23 Depth=2
	ld	(ix - 34), bc
	ld	de, (ix - 31)
	ld	hl, (ix - 37)
	.local	.LBB42_27
.LBB42_27:                              ;   in Loop: Header=BB42_23 Depth=2
	pea	ix - 17
	push	hl
	call	_lib_get_strip
	pop	hl
	pop	hl
	ld	iy, _stream
	ld	de, (ix - 34)
	add	iy, de
	ld	a, (ix - 17)
	ld	(iy), a
	ld	a, (ix - 16)
	ld	(iy + 1), a
	ld	hl, (ix - 15)
	ld	a, l
	ld	(iy + 2), a
	ld	a, h
	ld	(iy + 3), a
	ld	a, 16
	ld	c, a
	call	__ishru
	ld	a, l
	ld	(iy + 4), a
	ld	a, (ix - 12)
	ld	(iy + 5), a
	ld	de, (ix - 11)
	ld	h, (ix - 8)
	ld	a, e
	ld	(iy + 6), a
	ld	a, d
	ld	(iy + 7), a
	push	de
	pop	bc
	ld	a, h
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 8), a
	push	de
	pop	bc
	ld	a, h
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	(iy + 9), a
	ld	hl, (ix - 7)
	ld	a, l
	ld	(iy + 10), a
	ld	a, h
	ld	(iy + 11), a
	ld	c, 16
	call	__ishru
	ld	bc, 0
	ld	a, l
	ld	(iy + 12), a
	ld	a, (ix - 4)
	ld	(iy + 13), a
	ld	hl, (ix - 34)
	ld	de, 14
	add	hl, de
	ld	(ix - 34), hl
	ld	de, (ix - 37)
	inc.sis	de
	ld	iy, (ix - 31)
	jp	.LBB42_23
	.local	.LBB42_28
.LBB42_28:                              ;   in Loop: Header=BB42_2 Depth=1
	push	bc
	push	iy
	call	_drain
	pop	hl
	pop	hl
	ld	hl, _.str.6.30
	push	hl
	ld	hl, _.str.5.29
	push	hl
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jp	nz, .LBB42_41
; %bb.29:                               ;   in Loop: Header=BB42_2 Depth=1
	or	a, a
	sbc	hl, hl
	ex	de, hl
	push	de
	sbc	hl, hl
	push	hl
	push	de
	ld	hl, (ix - 34)
	push	hl
	ld	hl, 5
	push	hl
	call	_send_header
	ld	bc, 0
	pop	hl
	pop	hl
	jp	.LBB42_39
	.local	.LBB42_30
.LBB42_30:                              ;   in Loop: Header=BB42_2 Depth=1
	lea	hl, iy + 0
	ld	e, c
	ld	(ix - 31), bc
	ld	bc, -16385
	ld	a, c
	call	__ladd
	inc	bc
	call	__lcmpu
	jp	nc, .LBB42_46
; %bb.31:                               ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, (ix - 31)
	push	hl
	push	iy
	call	_drain
	pop	hl
	pop	hl
	ld	hl, 2
	jp	.LBB42_48
	.local	.LBB42_32
.LBB42_32:                              ;   in Loop: Header=BB42_2 Depth=1
	push	bc
	push	iy
	call	_drain
	pop	hl
	pop	hl
	ld	hl, (ix - 37)
	push	hl
	call	_csx_delete
	pop	hl
	ld	(ix - 17), a
	or	a, a
	ld.sis	hl, 5
                                        ; kill: def $hl killed $hl def $uhl
	jp	z, .LBB42_34
; %bb.33:                               ;   in Loop: Header=BB42_2 Depth=1
	ld.sis	hl, 0
                                        ; kill: def $hl killed $hl def $uhl
	.local	.LBB42_34
.LBB42_34:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	de, 0
	push	de
	inc	de
	push	de
	push	hl
	ld	hl, (ix - 34)
	push	hl
	ld	hl, 4
	push	hl
	call	_send_header
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	jp	z, .LBB42_92
; %bb.35:                               ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, 1
	push	hl
	pea	ix - 17
	call	_write_exact
	jp	.LBB42_14
	.local	.LBB42_36
.LBB42_36:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, 65535
	ld	e, 0
	ld	(ix - 31), bc
	lea	bc, iy + 0
	ld	(ix - 40), iy
	ld	iy, (ix - 31)
	ld	a, iyl
	call	__lcmpu
	jp	nc, .LBB42_50
; %bb.37:                               ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, (ix - 31)
	push	hl
	ld	hl, (ix - 40)
	push	hl
	call	_drain
	pop	hl
	pop	hl
	ld	hl, 2
	jp	.LBB42_88
	.local	.LBB42_38
.LBB42_38:                              ;   in Loop: Header=BB42_2 Depth=1
	push	bc
	push	iy
	call	_drain
	pop	hl
	pop	hl
	ld	a, 1
	ld	(_finished), a
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, (ix - 34)
	push	hl
	ld	hl, 8
	push	hl
	call	_reply
	ld	bc, 0
	.local	.LBB42_39
.LBB42_39:                              ;   in Loop: Header=BB42_2 Depth=1
	pop	hl
	.local	.LBB42_40
.LBB42_40:                              ;   in Loop: Header=BB42_2 Depth=1
	pop	hl
	pop	hl
	bit	0, a
	jp	z, .LBB42_15
	jp	.LBB42_16
	.local	.LBB42_41
.LBB42_41:                              ;   in Loop: Header=BB42_2 Depth=1
	push	de
	ld	(ix - 37), de
	call	_ti_GetSize
	ld	(ix - 31), l
	ld	(ix - 30), h
	pop	hl
	ld	hl, (ix - 37)
	push	hl
	call	_ti_GetDataPtr
	ld	(ix - 40), hl
	pop	hl
	ld	hl, (ix - 37)
	push	hl
	call	_ti_Close
	pop	hl
	or	a, a
	sbc	hl, hl
	ld	e, (ix - 31)
	ld	d, (ix - 30)
	ld	l, e
	ld	h, d
	ld	de, 0
	push	de
	push	hl
	push	de
	ld	hl, (ix - 34)
	push	hl
	ld	hl, 5
	push	hl
	call	_send_header
	ld	e, (ix - 31)
	ld	d, (ix - 30)
	ld	bc, 0
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	jp	z, .LBB42_15
	.local	.LBB42_42
.LBB42_42:                              ; %.preheader9
                                        ;   Parent Loop BB42_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	sbc.sis	hl, hl
	adc.sis	hl, de
	jp	z, .LBB42_16
; %bb.43:                               ;   in Loop: Header=BB42_42 Depth=2
	ld	l, e
	ld	h, d
	ld	c, e
	ld	b, d
	ld.sis	de, 512
	or	a, a
	sbc.sis	hl, de
	ld	(ix - 31), c
	ld	(ix - 30), b
	jr	c, .LBB42_45
; %bb.44:                               ;   in Loop: Header=BB42_42 Depth=2
	ld.sis	hl, 512
	ld	c, l
	ld	b, h
	.local	.LBB42_45
.LBB42_45:                              ;   in Loop: Header=BB42_42 Depth=2
	ld	(ix - 37), c
	ld	(ix - 36), b
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 34), hl
	push	hl
	ld	hl, (ix - 40)
	push	hl
	ld	hl, _stream
	push	hl
	call	_memcpy
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 34)
	push	hl
	ld	hl, _stream
	push	hl
	call	_write_exact
	pop	hl
	pop	hl
	ld	de, (ix - 34)
	ld	hl, (ix - 40)
	add	hl, de
	ld	(ix - 40), hl
	ld	l, (ix - 31)
	ld	h, (ix - 30)
	ld	e, (ix - 37)
	ld	d, (ix - 36)
	or	a, a
	sbc.sis	hl, de
	ex.sis	de, hl
	bit	0, a
	ld	bc, 0
	jr	nz, .LBB42_42
	jp	.LBB42_15
	.local	.LBB42_46
.LBB42_46:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	(ix - 40), iy
	ld	hl, (ix - 43)
	push	hl
	ld	hl, (ix - 37)
	push	hl
	ld	hl, (ix - 28)
	push	hl
	call	_csx_chunk_name
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 28)
	push	hl
	call	_ti_Delete
	pop	hl
	ld	hl, _.str.3.27
	push	hl
	ld	hl, (ix - 28)
	push	hl
	call	_ti_Open
	ld	c, a
	pop	hl
	pop	hl
	or	a, a
	jr	nz, .LBB42_54
; %bb.47:                               ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, (ix - 31)
	push	hl
	ld	hl, (ix - 40)
	push	hl
	call	_drain
	pop	hl
	pop	hl
	ld	hl, 4
	.local	.LBB42_48
.LBB42_48:                              ;   in Loop: Header=BB42_2 Depth=1
	push	hl
	ld	hl, (ix - 34)
	push	hl
	.local	.LBB42_49
.LBB42_49:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, 3
	jp	.LBB42_13
	.local	.LBB42_50
.LBB42_50:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, _.str.5.29
	push	hl
	call	_ti_Delete
	pop	hl
	ld	hl, _.str.3.27
	push	hl
	ld	hl, _.str.5.29
	push	hl
	call	_ti_Open
	ld	c, a
	pop	hl
	pop	hl
	or	a, a
	jp	nz, .LBB42_64
; %bb.51:                               ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, (ix - 31)
	push	hl
	ld	hl, (ix - 40)
	push	hl
	call	_drain
	pop	hl
	pop	hl
	ld	hl, 4
	jp	.LBB42_88
	.local	.LBB42_52
.LBB42_52:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	de, (ix - 34)
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB42_16
; %bb.53:                               ;   in Loop: Header=BB42_2 Depth=1
	push	de
	ld	hl, _stream
	push	hl
	call	_write_exact
	ld	bc, 0
	jp	.LBB42_40
	.local	.LBB42_54
.LBB42_54:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	a, 1
	ld	(ix - 46), a                    ; 1-byte Folded Spill
	ld	iy, (ix - 40)
	ld	de, (ix - 31)
	ld	(ix - 49), bc
	.local	.LBB42_55
.LBB42_55:                              ; %.preheader
                                        ;   Parent Loop BB42_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	call	__lcmpzero
	jp	z, .LBB42_74
; %bb.56:                               ;   in Loop: Header=BB42_55 Depth=2
	lea	hl, iy + 0
	ld	(ix - 31), de
                                        ; kill: def $e killed $e killed $ude
	ld	bc, 512
	xor	a, a
	call	__lcmpu
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	inc	a
	bit	0, a
	lea	de, iy + 0
	jr	nz, .LBB42_58
; %bb.57:                               ;   in Loop: Header=BB42_55 Depth=2
	ld	hl, 512
	ex	de, hl
	.local	.LBB42_58
.LBB42_58:                              ;   in Loop: Header=BB42_55 Depth=2
	ld	(ix - 40), iy
	bit	0, a
	ld	hl, (ix - 31)
	ld	a, l
	jr	nz, .LBB42_60
; %bb.59:                               ;   in Loop: Header=BB42_55 Depth=2
	xor	a, a
	.local	.LBB42_60
.LBB42_60:                              ;   in Loop: Header=BB42_55 Depth=2
	ld	(ix - 53), a
	push	de
	ld	(ix - 52), de
	call	_read_exact
	pop	hl
	bit	0, a
	jp	z, .LBB42_89
; %bb.61:                               ;   in Loop: Header=BB42_55 Depth=2
	ld	hl, (ix - 49)
	push	hl
	ld	hl, 1
	push	hl
	ld	hl, (ix - 52)
	push	hl
	ld	hl, _stream
	push	hl
	call	_ti_Write
	pop	de
	pop	de
	pop	de
	pop	de
	ld	de, 1
	or	a, a
	sbc	hl, de
	ld	a, -1
	jr	z, .LBB42_63
; %bb.62:                               ;   in Loop: Header=BB42_55 Depth=2
	ld	a, 0
	.local	.LBB42_63
.LBB42_63:                              ;   in Loop: Header=BB42_55 Depth=2
	ld	l, (ix - 46)
	and	a, l
	ld	l, a
	ld	(ix - 46), l
	ld	hl, (ix - 40)
	ld	de, (ix - 31)
                                        ; kill: def $e killed $e killed $ude
	ld	bc, (ix - 52)
	ld	a, (ix - 53)                    ; 1-byte Folded Reload
	call	__lsub
	push	hl
	pop	iy
                                        ; kill: def $e killed $e def $ude
	ld	bc, (ix - 49)
	jp	.LBB42_55
	.local	.LBB42_64
.LBB42_64:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	a, 1
	ld	(ix - 43), a                    ; 1-byte Folded Spill
	ld	iy, (ix - 40)
	ld	de, (ix - 31)
	ld	(ix - 37), bc
	.local	.LBB42_65
.LBB42_65:                              ; %.preheader12
                                        ;   Parent Loop BB42_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	call	__lcmpzero
	jp	z, .LBB42_83
; %bb.66:                               ;   in Loop: Header=BB42_65 Depth=2
	lea	hl, iy + 0
	ld	(ix - 31), de
                                        ; kill: def $e killed $e killed $ude
	ld	bc, 512
	xor	a, a
	call	__lcmpu
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	inc	a
	bit	0, a
	lea	de, iy + 0
	jr	nz, .LBB42_68
; %bb.67:                               ;   in Loop: Header=BB42_65 Depth=2
	ld	hl, 512
	ex	de, hl
	.local	.LBB42_68
.LBB42_68:                              ;   in Loop: Header=BB42_65 Depth=2
	ld	(ix - 40), iy
	bit	0, a
	ld	hl, (ix - 31)
	ld	a, l
	jr	nz, .LBB42_70
; %bb.69:                               ;   in Loop: Header=BB42_65 Depth=2
	xor	a, a
	.local	.LBB42_70
.LBB42_70:                              ;   in Loop: Header=BB42_65 Depth=2
	ld	(ix - 49), a
	push	de
	ld	(ix - 46), de
	call	_read_exact
	pop	hl
	bit	0, a
	jp	z, .LBB42_90
; %bb.71:                               ;   in Loop: Header=BB42_65 Depth=2
	ld	hl, (ix - 37)
	push	hl
	ld	hl, 1
	push	hl
	ld	hl, (ix - 46)
	push	hl
	ld	hl, _stream
	push	hl
	call	_ti_Write
	pop	de
	pop	de
	pop	de
	pop	de
	ld	de, 1
	or	a, a
	sbc	hl, de
	ld	a, -1
	jr	z, .LBB42_73
; %bb.72:                               ;   in Loop: Header=BB42_65 Depth=2
	ld	a, 0
	.local	.LBB42_73
.LBB42_73:                              ;   in Loop: Header=BB42_65 Depth=2
	ld	l, (ix - 43)
	and	a, l
	ld	l, a
	ld	(ix - 43), l
	ld	hl, (ix - 40)
	ld	de, (ix - 31)
                                        ; kill: def $e killed $e killed $ude
	ld	bc, (ix - 46)
	ld	a, (ix - 49)                    ; 1-byte Folded Reload
	call	__lsub
	push	hl
	pop	iy
                                        ; kill: def $e killed $e def $ude
	ld	bc, (ix - 37)
	jp	.LBB42_65
	.local	.LBB42_74
.LBB42_74:                              ;   in Loop: Header=BB42_2 Depth=1
	bit	0, (ix - 46)                    ; 1-byte Folded Reload
	ld	a, 0
	jr	z, .LBB42_78
; %bb.75:                               ;   in Loop: Header=BB42_2 Depth=1
	push	bc
	ld	hl, 1
	push	hl
	call	_ti_SetArchiveStatus
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, -1
	jr	nz, .LBB42_77
; %bb.76:                               ;   in Loop: Header=BB42_2 Depth=1
	ld	a, 0
	.local	.LBB42_77
.LBB42_77:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	bc, (ix - 49)
	.local	.LBB42_78
.LBB42_78:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	(ix - 31), a
	push	bc
	call	_ti_Close
	pop	hl
	bit	0, (ix - 31)                    ; 1-byte Folded Reload
	ld	hl, (ix - 28)
	push	hl
	call	z, _ti_Delete
	pop	hl
	ld	hl, (ix + 6)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB42_80
; %bb.79:                               ;   in Loop: Header=BB42_2 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, (ix - 43)
	push	hl
	ld	hl, (ix - 37)
	push	hl
	ld	hl, _.str.4.28
	push	hl
	ld	hl, (ix + 6)
	call	__indcallhl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB42_80
.LBB42_80:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	l, (ix - 46)                    ; 1-byte Folded Reload
	ld	c, 15
	call	__sshl
	add.sis	hl, hl
	sbc.sis	hl, hl
	ld.sis	de, 4
	add.sis	hl, de
	bit	0, (ix - 31)                    ; 1-byte Folded Reload
	ld.sis	de, 0
                                        ; kill: def $de killed $de def $ude
	ld	bc, (ix - 34)
	jr	nz, .LBB42_82
; %bb.81:                               ;   in Loop: Header=BB42_2 Depth=1
	ld	e, l
	ld	d, h
	.local	.LBB42_82
.LBB42_82:                              ;   in Loop: Header=BB42_2 Depth=1
	push	de
	push	bc
	jp	.LBB42_49
	.local	.LBB42_83
.LBB42_83:                              ;   in Loop: Header=BB42_2 Depth=1
	bit	0, (ix - 43)                    ; 1-byte Folded Reload
	ld	hl, 4
	jp	z, .LBB42_87
; %bb.84:                               ;   in Loop: Header=BB42_2 Depth=1
	push	bc
	ld	hl, 1
	push	hl
	call	_ti_SetArchiveStatus
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld.sis	hl, 1
                                        ; kill: def $hl killed $hl def $uhl
	jp	z, .LBB42_86
; %bb.85:                               ;   in Loop: Header=BB42_2 Depth=1
	ld.sis	hl, 0
                                        ; kill: def $hl killed $hl def $uhl
	.local	.LBB42_86
.LBB42_86:                              ;   in Loop: Header=BB42_2 Depth=1
	add	hl, hl
	add	hl, hl
                                        ; kill: def $hl killed $hl def $uhl
	ld	bc, (ix - 37)
	.local	.LBB42_87
.LBB42_87:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	(ix - 31), hl
	push	bc
	call	_ti_Close
	pop	hl
	call	_lib_open
	ld	hl, (ix - 31)
	.local	.LBB42_88
.LBB42_88:                              ;   in Loop: Header=BB42_2 Depth=1
	push	hl
	ld	hl, (ix - 34)
	push	hl
	ld	hl, 6
	jp	.LBB42_13
	.local	.LBB42_89
.LBB42_89:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, (ix - 49)
	push	hl
	call	_ti_Close
	pop	hl
	ld	hl, (ix - 28)
	jr	.LBB42_91
	.local	.LBB42_90
.LBB42_90:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	hl, (ix - 37)
	push	hl
	call	_ti_Close
	pop	hl
	ld	hl, _.str.5.29
	.local	.LBB42_91
.LBB42_91:                              ; %.loopexit
                                        ;   in Loop: Header=BB42_2 Depth=1
	push	hl
	call	_ti_Delete
	pop	hl
	.local	.LBB42_92
.LBB42_92:                              ;   in Loop: Header=BB42_2 Depth=1
	ld	bc, 0
	jp	.LBB42_15
	.local	.LBB42_93
.LBB42_93:
	call	_usb_Cleanup
	ld	hl, (ix - 25)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, -1
	jr	z, .LBB42_95
; %bb.94:
	ld	a, 0
	.local	.LBB42_95
.LBB42_95:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB42_96
.LBB42_96:
	push	bc
	push	iy
	call	_drain
	pop	hl
	pop	hl
	call	_archive_free
	.local	.Lfunc_end42
.Lfunc_end42:
	.size	_proto_run, .Lfunc_end42-_proto_run
	.section	.rodata._proto_run,"a",@progbits
JTI42_0:
	d24	.LBB42_96
	d24	.LBB42_21
	d24	.LBB42_30
	d24	.LBB42_32
	d24	.LBB42_28
	d24	.LBB42_36
	d24	.LBB42_96
	d24	.LBB42_38
                                        ; -- End function
	.section	.text._handle_event,"ax",@progbits
	.type	_handle_event,@function         ; -- Begin function handle_event
_handle_event:                          ; @handle_event
; %bb.0:
	ld	hl, -9
	call	__frameset
	ld	de, (ix + 6)
	or	a, a
	sbc	hl, hl
	ld	(ix - 3), hl
	dec	de
	ld	bc, 12
	push	de
	pop	hl
	sbc	hl, bc
	jr	c, .LBB43_2
	.local	.LBB43_1
.LBB43_1:
	ld	hl, (ix - 3)
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB43_2
.LBB43_2:
	ld	c, 1
	ld	hl, JTI43_0
	add	hl, de
	add	hl, de
	add	hl, de
	ld	hl, (hl)
	jp	(hl)
	.local	.LBB43_3
.LBB43_3:
	xor	a, a
	ld	(_configured), a
	ld	a, c
	ld	(_link_lost), a
	jr	.LBB43_1
	.local	.LBB43_4
.LBB43_4:
	ld	hl, (ix + 9)
	ld	a, (hl)
	ld	(ix - 6), a
	ld	hl, 8
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_usb_FindDevice
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB43_1
; %bb.5:
	ld	b, 5
	ld	l, 3
	ld	c, (ix - 6)                     ; 1-byte Folded Reload
	ld	a, c
	call	__bshru
	and	a, l
	ld	l, a
	ld	a, c
	cp	a, 0
	call	pe, __setflag
	jp	p, .LBB43_18
; %bb.6:
	ld	a, l
	or	a, a
	jp	nz, .LBB43_18
; %bb.7:
	ld	hl, (ix + 9)
	push	hl
	pop	iy
	ld	a, (iy + 1)
	cp	a, 6
	jr	nz, .LBB43_1
; %bb.8:
	ld	(ix - 6), de
	ld.sis	bc, -256
	ld	iy, (ix + 9)
	ld	hl, (iy + 2)
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sand
	ld.sis	de, 3840
	or	a, a
	sbc.sis	hl, de
	jp	nz, .LBB43_1
; %bb.9:
	ld	de, (iy + 6)
	ld.sis	bc, 57
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	jr	c, .LBB43_11
; %bb.10:
	ld.sis	de, 57
	.local	.LBB43_11
.LBB43_11:
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix - 9), hl
	push	hl
	ld	hl, _bos_descriptor
	jp	.LBB43_25
	.local	.LBB43_12
.LBB43_12:
	ld	hl, 8
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_usb_FindDevice
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	ld	(_host_device), de
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB43_1
; %bb.13:
	ld	hl, 1
	push	hl
	push	de
	call	_usb_GetDeviceEndpoint
	pop	de
	pop	de
	ld	(_endpoint_out), hl
	ld	hl, (_host_device)
	ld	de, 130
	push	de
	push	hl
	call	_usb_GetDeviceEndpoint
	ex	de, hl
	pop	hl
	pop	hl
	ld	(_endpoint_in), de
	ld	hl, (_endpoint_out)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, -1
	ld	b, 0
	ld	c, a
	jr	nz, .LBB43_15
; %bb.14:
	ld	c, b
	.local	.LBB43_15
.LBB43_15:
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB43_17
; %bb.16:
	ld	a, b
	.local	.LBB43_17
.LBB43_17:
	and	a, c
	ld	l, a
	ld	e, 1
	ld	a, l
	and	a, e
	ld	l, a
	ld	(_configured), a
	jp	.LBB43_1
	.local	.LBB43_18
.LBB43_18:
	ld	a, c
	cp	a, 0
	call	pe, __setflag
	jp	p, .LBB43_1
; %bb.19:
	ld	a, l
	cp	a, 2
	jp	nz, .LBB43_1
; %bb.20:
	ld	hl, (ix + 9)
	push	hl
	pop	iy
	lea	bc, iy + 0
	ld	a, (iy + 1)
	cp	a, 34
	jp	nz, .LBB43_1
; %bb.21:
	ld	(ix - 6), de
	push	bc
	pop	iy
	ld	hl, (iy + 4)
	ld.sis	de, 7
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, de
	jp	nz, .LBB43_1
; %bb.22:
	push	bc
	pop	iy
	ld	de, (iy + 6)
	ld.sis	bc, 46
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	jr	c, .LBB43_24
; %bb.23:
	ld.sis	de, 46
	.local	.LBB43_24
.LBB43_24:
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix - 9), hl
	push	hl
	ld	hl, _msos_descriptor
	.local	.LBB43_25
.LBB43_25:
	push	hl
	ld	hl, _setup_buffer
	push	hl
	call	_memcpy
	pop	hl
	pop	hl
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, (ix - 6)
	push	hl
	call	_usb_GetDeviceEndpoint
	pop	de
	pop	de
	ld	de, 0
	push	de
	push	de
	ld	de, (ix - 9)
	push	de
	ld	de, _setup_buffer
	push	de
	push	hl
	call	_usb_ScheduleTransfer
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	iy, 1
	ld	(ix - 3), iy
	jp	.LBB43_1
	.local	.Lfunc_end43
.Lfunc_end43:
	.size	_handle_event, .Lfunc_end43-_handle_event
	.section	.rodata._handle_event,"a",@progbits
JTI43_0:
	d24	.LBB43_3
	d24	.LBB43_1
	d24	.LBB43_3
	d24	.LBB43_1
	d24	.LBB43_1
	d24	.LBB43_1
	d24	.LBB43_1
	d24	.LBB43_3
	d24	.LBB43_1
	d24	.LBB43_1
	d24	.LBB43_4
	d24	.LBB43_12
                                        ; -- End function
	.section	.text._request_arrived,"ax",@progbits
	.type	_request_arrived,@function      ; -- Begin function request_arrived
_request_arrived:                       ; @request_arrived
; %bb.0:
	call	__frameset0
	ld	bc, (ix + 9)
	xor	a, a
	ld	iy, 0
	ld	(_header_posted), a
	sbc	hl, hl
	adc	hl, bc
	jr	nz, .LBB44_3
; %bb.1:
	ld	hl, (ix + 12)
	ld	de, 8
	or	a, a
	sbc	hl, de
	jr	nz, .LBB44_3
; %bb.2:
	ld	hl, _header_ready
	jr	.LBB44_5
	.local	.LBB44_3
.LBB44_3:
	ld	l, -126
	ld	a, c
	and	a, l
	ld	l, a
	or	a, a
	jr	z, .LBB44_6
; %bb.4:
	ld	hl, _link_lost
	.local	.LBB44_5
.LBB44_5:
	ld	(hl), 1
	.local	.LBB44_6
.LBB44_6:
	lea	hl, iy + 0
	pop	ix
	ret
	.local	.Lfunc_end44
.Lfunc_end44:
	.size	_request_arrived, .Lfunc_end44-_request_arrived
                                        ; -- End function
	.section	.text._drain,"ax",@progbits
	.type	_drain,@function                ; -- Begin function drain
_drain:                                 ; @drain
; %bb.0:
	ld	hl, -8
	call	__frameset
	ld	hl, (ix + 6)
	ld	e, (ix + 9)
	ld	bc, 512
	ld	d, c
	.local	.LBB45_1
.LBB45_1:                               ; =>This Inner Loop Header: Depth=1
	call	__lcmpzero
	jp	z, .LBB45_7
; %bb.2:                                ;   in Loop: Header=BB45_1 Depth=1
	ld	(ix - 1), e                     ; 1-byte Folded Spill
	ld	a, d
	call	__lcmpu
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	inc	a
	bit	0, a
	push	hl
	pop	iy
	jr	nz, .LBB45_4
; %bb.3:                                ;   in Loop: Header=BB45_1 Depth=1
	push	bc
	pop	iy
	.local	.LBB45_4
.LBB45_4:                               ;   in Loop: Header=BB45_1 Depth=1
	ld	(ix - 4), hl
	bit	0, a
	ld	a, (ix - 1)                     ; 1-byte Folded Reload
	jr	nz, .LBB45_6
; %bb.5:                                ;   in Loop: Header=BB45_1 Depth=1
	ld	a, d
	.local	.LBB45_6
.LBB45_6:                               ;   in Loop: Header=BB45_1 Depth=1
	ld	(ix - 5), a
	push	iy
	ld	(ix - 8), iy
	call	_read_exact
	ld	d, a
	pop	hl
	ld	hl, (ix - 4)
	ld	e, (ix - 1)                     ; 1-byte Folded Reload
	ld	bc, (ix - 8)
	ld	a, (ix - 5)                     ; 1-byte Folded Reload
	call	__lsub
	bit	0, d
	ld	d, 0
	ld	bc, 512
	jp	nz, .LBB45_1
	.local	.LBB45_7
.LBB45_7:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end45
.Lfunc_end45:
	.size	_drain, .Lfunc_end45-_drain
                                        ; -- End function
	.section	.text._archive_free,"ax",@progbits
	.type	_archive_free,@function         ; -- Begin function archive_free
_archive_free:                          ; @archive_free
; %bb.0:
	.local	.LBB46_1
.LBB46_1:                               ; =>This Inner Loop Header: Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	call	_ti_ArchiveHasRoom
	pop	hl
	jr	.LBB46_1
	.local	.Lfunc_end46
.Lfunc_end46:
	.size	_archive_free, .Lfunc_end46-_archive_free
                                        ; -- End function
	.section	.text._send_header,"ax",@progbits
	.type	_send_header,@function          ; -- Begin function send_header
_send_header:                           ; @send_header
; %bb.0:
	ld	hl, -8
	call	__frameset
	ld	l, (ix + 6)
	ld	h, (ix + 9)
	ld	e, (ix + 12)
	ld	bc, (ix + 15)
	ld	a, (ix + 18)
	ld	iy, 8
	ld	(ix - 8), l
	ld	(ix - 7), h
	ld	(ix - 6), e
	ld	(ix - 5), 0
	ld	l, c
	ld	(ix - 4), l
	ld	l, b
	ld	(ix - 3), l
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(ix - 2), a
	ld	(ix - 1), 0
	push	iy
	pea	ix - 8
	call	_write_exact
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end47
.Lfunc_end47:
	.size	_send_header, .Lfunc_end47-_send_header
                                        ; -- End function
	.section	.text._write_exact,"ax",@progbits
	.type	_write_exact,@function          ; -- Begin function write_exact
_write_exact:                           ; @write_exact
; %bb.0:
	ld	hl, -9
	call	__frameset
	ld	iy, (ix + 6)
	ld	de, (ix + 9)
	.local	.LBB48_1
.LBB48_1:                               ; =>This Inner Loop Header: Depth=1
	ld	bc, 0
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB48_6
; %bb.2:                                ;   in Loop: Header=BB48_1 Depth=1
	ld	(ix - 3), bc
	ld	hl, (_endpoint_in)
	pea	ix - 3
	ld	bc, 10
	push	bc
	ld	(ix - 6), de
	push	de
	ld	(ix - 9), iy
	push	iy
	push	hl
	call	_usb_Transfer
	pop	de
	pop	de
	pop	de
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB48_5
; %bb.3:                                ;   in Loop: Header=BB48_1 Depth=1
	ld	de, (ix - 3)
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB48_5
; %bb.4:                                ;   in Loop: Header=BB48_1 Depth=1
	ld	iy, (ix - 9)
	add	iy, de
	ld	hl, (ix - 6)
	or	a, a
	sbc	hl, de
	ex	de, hl
	jr	.LBB48_1
	.local	.LBB48_5
.LBB48_5:
	ld	de, (ix - 6)
	.local	.LBB48_6
.LBB48_6:                               ; %.loopexit
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB48_8
; %bb.7:                                ; %.loopexit
	ld	a, 0
	jr	.LBB48_9
	.local	.LBB48_8
.LBB48_8:
	ld	a, -1
	.local	.LBB48_9
.LBB48_9:                               ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end48
.Lfunc_end48:
	.size	_write_exact, .Lfunc_end48-_write_exact
                                        ; -- End function
	.section	.text._reply,"ax",@progbits
	.type	_reply,@function                ; -- Begin function reply
_reply:                                 ; @reply
; %bb.0:
	call	__frameset0
	ld	a, (ix + 6)
	ld	l, (ix + 9)
	ld	de, (ix + 12)
	ld	bc, 0
	push	bc
	push	bc
	push	de
                                        ; kill: def $l killed $l def $uhl
	push	hl
	ld	l, a
	push	hl
	call	_send_header
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end49
.Lfunc_end49:
	.size	_reply, .Lfunc_end49-_reply
                                        ; -- End function
	.section	.text._read_exact,"ax",@progbits
	.type	_read_exact,@function           ; -- Begin function read_exact
_read_exact:                            ; @read_exact
; %bb.0:
	ld	hl, -9
	call	__frameset
	ld	de, (ix + 6)
	ld	iy, 0
	ld	hl, _stream
	ld	(ix - 6), hl
	.local	.LBB50_1
.LBB50_1:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB50_8
; %bb.2:                                ;   in Loop: Header=BB50_1 Depth=1
	push	de
	pop	hl
	ld	bc, 512
	or	a, a
	sbc	hl, bc
	ld	(ix - 9), de
	ex	de, hl
	jr	c, .LBB50_4
; %bb.3:                                ;   in Loop: Header=BB50_1 Depth=1
	ld	hl, 512
	.local	.LBB50_4
.LBB50_4:                               ;   in Loop: Header=BB50_1 Depth=1
	ld	(ix - 3), iy
	ld	de, (_endpoint_out)
	pea	ix - 3
	ld	bc, 10
	push	bc
	push	hl
	ld	hl, (ix - 6)
	push	hl
	push	de
	call	_usb_Transfer
	pop	de
	pop	de
	pop	de
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB50_7
; %bb.5:                                ;   in Loop: Header=BB50_1 Depth=1
	ld	de, (ix - 3)
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB50_7
; %bb.6:                                ;   in Loop: Header=BB50_1 Depth=1
	ld	hl, (ix - 6)
	add	hl, de
	ld	(ix - 6), hl
	ld	hl, (ix - 9)
	or	a, a
	sbc	hl, de
	ex	de, hl
	ld	bc, 0
	push	bc
	pop	iy
	jr	.LBB50_1
	.local	.LBB50_7
.LBB50_7:
	ld	de, (ix - 9)
	.local	.LBB50_8
.LBB50_8:                               ; %.loopexit
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB50_10
; %bb.9:                                ; %.loopexit
	ld	a, 0
	jr	.LBB50_11
	.local	.LBB50_10
.LBB50_10:
	ld	a, -1
	.local	.LBB50_11
.LBB50_11:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end50
.Lfunc_end50:
	.size	_read_exact, .Lfunc_end50-_read_exact
                                        ; -- End function
	.section	.text._viewer_run,"ax",@progbits
	.globl	_viewer_run                     ; -- Begin function viewer_run
	.type	_viewer_run,@function
_viewer_run:                            ; @viewer_run
; %bb.0:
	ld	hl, -381
	call	__frameset
	ld	de, -341
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (ix + 6)
	lea	de, ix - 47
	push	ix
	ld	bc, -344
	add	ix, bc
	ld	(ix + 0), iy
	pop	ix
	lea	bc, iy + 12
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 92
	ld	(iy + 0), bc
	ld	bc, -381
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	push	de
	push	hl
	call	_lib_get_strip
	pop	hl
	pop	hl
	ld	a, (ix - 47)
	ld	l, a
	push	hl
	ld	de, -348
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_csx_open
	pop	hl
	pop	hl
	ld	de, -359
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	bit	0, a
	jp	z, .LBB51_70
; %bb.1:
	ld	de, -344
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	lea	hl, iy + 2
	ld	de, -358
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	call	_render_reset
	ld	de, -348
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_render_set_palette
	pop	hl
	call	_ui_set_chrome_palette
	ld	de, -344
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	push	ix
	ld	de, -348
	add	ix, de
	ld	hl, (ix + 0)
	pop	ix
	ld	(iy + 2), hl
	ld	a, (ix - 34)
	ld	(iy + 5), a
	or	a, a
	sbc	hl, hl
	ld	(iy + 6), hl
	ld	hl, (ix - 37)
	ld	(iy + 9), hl
	ld	l, (iy + 14)
	cp	a, l
	jr	c, .LBB51_3
; %bb.2:
	ld	(iy + 5), 0
	.local	.LBB51_3
.LBB51_3:
	lea	hl, ix - 31
	ld	de, -362
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, -358
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_clamp
	pop	hl
	ld	a, (ix - 42)
	ld	de, -378
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a
	call	_input_reset
	ld	de, -378
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)
	ld	de, -345
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	l, 1
	ld	bc, 60
	.local	.LBB51_4
.LBB51_4:                               ; %input_pressed.exit7
                                        ; =>This Inner Loop Header: Depth=1
	ld	de, -354
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	bit	0, l
	ld	hl, 0
	ld	a, l
	dec	de
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	ld	(iy + 0), a
	jp	z, .LBB51_16
; %bb.5:                                ;   in Loop: Header=BB51_4 Depth=1
	ld	de, -344
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	a, (iy + 5)
	ld	hl, (iy + 6)
	ld	de, (iy + 9)
	ld	bc, -351
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	push	de
	push	hl
	ld	de, -365
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	l, a
	push	hl
	ld	de, -348
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_render_view
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	de, -354
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB51_15
; %bb.6:                                ;   in Loop: Header=BB51_4 Depth=1
	ld	de, -344
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	iy, (iy + 2)
	ld	de, 202
	add	iy, de
	or	a, a
	sbc	hl, hl
	push	ix
	ld	de, -365
	add	ix, de
	ld	l, (ix + 0)                     ; 1-byte Folded Reload
	pop	ix
	push	ix
	ld	de, -371
	add	ix, de
	ld	(ix + 0), hl
	pop	ix
	ld	bc, 12
	call	__imulu
	ex	de, hl
	ld	bc, -368
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), iy
	add	iy, de
	ld	de, -374
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	iy, (iy + 2)
	lea	hl, iy + 0
	ld	de, 241
	or	a, a
	sbc	hl, de
	ld	hl, 240
	push	ix
	ld	de, -365
	push	af
	add	ix, de
	pop	af
	ld	(ix + 0), hl
	pop	ix
	ld	hl, 0
	jr	c, .LBB51_10
; %bb.7:                                ;   in Loop: Header=BB51_4 Depth=1
	lea	hl, iy + 0
	ld	de, -240
	add	hl, de
	push	ix
	ld	de, -377
	add	ix, de
	ld	(ix + 0), hl
	pop	ix
	ld	hl, 57600
	lea	bc, iy + 0
	call	__idivu
	push	hl
	pop	bc
	ld	de, 11
	or	a, a
	sbc	hl, de
	jr	nc, .LBB51_9
; %bb.8:                                ;   in Loop: Header=BB51_4 Depth=1
	ld	hl, 10
	push	hl
	pop	bc
	.local	.LBB51_9
.LBB51_9:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	hl, 240
	ld	de, -365
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	or	a, a
	sbc	hl, bc
	ld	de, -355
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	ld	e, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 95
	ld	bc, (iy + 0)
	call	__lmulu
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 121
	ld	bc, (iy + 0)
	call	__ldivu
	.local	.LBB51_10
.LBB51_10:                              ;   in Loop: Header=BB51_4 Depth=1
	ld	de, -377
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	hl, 251
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 240
	push	hl
	ld	hl, 4
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 316
	push	hl
	call	_gfx_FillRectangle_NoClip
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 250
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	de, -365
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, 4
	push	hl
	ld	de, -377
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, 316
	push	hl
	call	_gfx_FillRectangle_NoClip
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	de, -374
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	hl, (hl)
	ld	de, -365
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, -368
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	hl, (iy)
	push	ix
	ld	de, -374
	add	ix, de
	ld	(ix + 0), hl
	pop	ix
	push	ix
	ld	de, -371
	add	ix, de
	ld	hl, (ix + 0)
	pop	ix
	ld	bc, 12
	call	__imulu
	ex	de, hl
	add	iy, de
	ld	iy, (iy + 2)
	lea	hl, iy + 0
	ld	de, 241
	or	a, a
	sbc	hl, de
	ld	hl, 100
	jr	c, .LBB51_12
; %bb.11:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	de, -240
	add	iy, de
	push	ix
	ld	de, -351
	add	ix, de
	ld	hl, (ix + 0)
	pop	ix
	push	ix
	ld	bc, -355
	add	ix, bc
	ld	d, (ix + 0)                     ; 1-byte Folded Reload
	pop	ix
	ld	e, d
	ld	bc, 100
	xor	a, a
	call	__lmulu
	lea	bc, iy + 0
	ld	a, d
	call	__ldivu
	.local	.LBB51_12
.LBB51_12:                              ;   in Loop: Header=BB51_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	iy, 0
	lea	hl, iy + 0
	push	ix
	ld	de, -365
	add	ix, de
	ld	iy, (ix + 0)
	pop	ix
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	de, 10
	push	de
	pop	bc
	call	__imulu
	ld	bc, 0
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 118
	ld	de, (ix + 0)
	pop	ix
	ld	c, e
	ld	b, d
	call	__idivu
	ld	bc, 10
	call	__iremu
	push	ix
	ld	bc, -368
	add	ix, bc
	ld	(ix + 0), hl
	pop	ix
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	c, e
	ld	b, d
	call	__sdivu
	ld	bc, 0
	ld	c, l
	ld	b, h
	ld	de, -345
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	bit	0, (iy + 0)                     ; 1-byte Folded Reload
	ld	hl, _.str.3.37
	jr	nz, .LBB51_14
; %bb.13:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	hl, _.str.4.38
	.local	.LBB51_14
.LBB51_14:                              ;   in Loop: Header=BB51_4 Depth=1
	push	hl
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -368
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	push	bc
	ld	hl, _.str.2.39
	push	hl
	ld	de, -362
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 248
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	de, -362
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_strlen
	pop	de
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, 8
	add	hl, de
	ld	de, 14
	push	de
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_gfx_FillRectangle_NoClip
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 249
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 248
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	hl, 3
	push	hl
	inc	hl
	push	hl
	ld	de, -362
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB51_15
.LBB51_15:                              ;   in Loop: Header=BB51_4 Depth=1
	call	_gfx_SwapDraw
	.local	.LBB51_16
.LBB51_16:                              ;   in Loop: Header=BB51_4 Depth=1
	call	_input_scan
	ld	de, (_repeat_frames)
	push	de
	pop	hl
	ld	bc, 10
	or	a, a
	sbc	hl, bc
	ld	bc, 14
	jr	nc, .LBB51_18
; %bb.17:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	bc, 6
	.local	.LBB51_18
.LBB51_18:                              ;   in Loop: Header=BB51_4 Depth=1
	ex	de, hl
	ld	de, 24
	or	a, a
	sbc	hl, de
	ld	hl, 26
	jr	nc, .LBB51_20
; %bb.19:                               ;   in Loop: Header=BB51_4 Depth=1
	push	bc
	pop	hl
	.local	.LBB51_20
.LBB51_20:                              ;   in Loop: Header=BB51_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	hl, 1793
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB51_22
; %bb.21:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	jr	.LBB51_24
	.local	.LBB51_22
.LBB51_22:                              ;   in Loop: Header=BB51_4 Depth=1
	ld	hl, 1800
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jp	z, .LBB51_37
; %bb.23:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	call	__ineg
	.local	.LBB51_24
.LBB51_24:                              ;   in Loop: Header=BB51_4 Depth=1
	push	hl
	or	a, a
	sbc	hl, hl
	.local	.LBB51_25
.LBB51_25:                              ;   in Loop: Header=BB51_4 Depth=1
	push	hl
	ld	de, -358
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_pan
	pop	hl
	pop	hl
	pop	hl
	ld	a, 1
	ld	c, a
	.local	.LBB51_26
.LBB51_26:                              ;   in Loop: Header=BB51_4 Depth=1
	ld	a, (_current+6)
	ld	h, a
	bit	1, h
	jr	z, .LBB51_29
; %bb.27:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB51_4 Depth=1
	ld	a, (_previous+6)
	bit	1, a
	jr	nz, .LBB51_29
; %bb.28:                               ;   in Loop: Header=BB51_4 Depth=1
	push	ix
	ld	de, -344
	add	ix, de
	ld	iy, (ix + 0)
	pop	ix
	ld	e, (iy + 5)
	ld	d, e
	inc	d
	jp	.LBB51_43
	.local	.LBB51_29
.LBB51_29:                              ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB51_4 Depth=1
	bit	2, h
	jr	z, .LBB51_33
; %bb.30:                               ; %input_pressed.exit4
                                        ;   in Loop: Header=BB51_4 Depth=1
	ld	a, (_previous+6)
	bit	2, a
	jr	nz, .LBB51_33
; %bb.31:                               ;   in Loop: Header=BB51_4 Depth=1
	push	ix
	ld	de, -344
	add	ix, de
	ld	iy, (ix + 0)
	pop	ix
	ld	e, (iy + 5)
	ld	a, e
	or	a, a
	ld	a, 1
	ld	c, a
	jp	z, .LBB51_50
; %bb.32:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	d, e
	jp	.LBB51_42
	.local	.LBB51_33
.LBB51_33:                              ; %input_pressed.exit4.thread
                                        ;   in Loop: Header=BB51_4 Depth=1
	ld	a, (_current+1)
	bit	6, a
	jp	z, .LBB51_50
; %bb.34:                               ; %input_pressed.exit5
                                        ;   in Loop: Header=BB51_4 Depth=1
	ld	a, (_previous+1)
	bit	6, a
	jp	nz, .LBB51_50
; %bb.35:                               ;   in Loop: Header=BB51_4 Depth=1
	push	ix
	ld	de, -344
	add	ix, de
	ld	iy, (ix + 0)
	pop	ix
	ld	e, (iy + 5)
	ld	a, e
	or	a, a
	jr	z, .LBB51_41
; %bb.36:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	d, 0
	jr	.LBB51_43
	.local	.LBB51_37
.LBB51_37:                              ;   in Loop: Header=BB51_4 Depth=1
	ld	hl, 1796
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB51_39
; %bb.38:                               ;   in Loop: Header=BB51_4 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	jp	.LBB51_25
	.local	.LBB51_39
.LBB51_39:                              ;   in Loop: Header=BB51_4 Depth=1
	ld	hl, 1794
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	ld	a, 0
	ld	c, a
	jp	z, .LBB51_26
; %bb.40:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	call	__ineg
	ld	de, 0
	push	de
	jp	.LBB51_25
	.local	.LBB51_41
.LBB51_41:                              ;   in Loop: Header=BB51_4 Depth=1
	push	ix
	ld	bc, -344
	add	ix, bc
	ld	iy, (ix + 0)
	pop	ix
	ld	d, (iy + 14)
	.local	.LBB51_42
.LBB51_42:                              ;   in Loop: Header=BB51_4 Depth=1
	dec	d
	.local	.LBB51_43
.LBB51_43:                              ;   in Loop: Header=BB51_4 Depth=1
	push	ix
	ld	bc, -344
	add	ix, bc
	ld	iy, (ix + 0)
	pop	ix
	ld	iy, (iy + 2)
	push	ix
	ld	bc, -365
	add	ix, bc
	ld	(ix + 0), iy
	pop	ix
	ld	l, (iy + 2)
	ld	a, d
	cp	a, l
	ld	a, 1
	ld	c, a
	jp	nc, .LBB51_50
; %bb.44:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	a, e
	cp	a, d
	ld	a, 1
	ld	c, a
	jp	z, .LBB51_50
; %bb.45:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	bc, -351
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), h                     ; 1-byte Folded Spill
	or	a, a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, d
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 115
	ld	(iy + 0), bc
	ld	l, e
	ld	bc, 202
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 109
	ld	iy, (ix + 0)
	pop	ix
	add	iy, bc
	push	ix
	ld	bc, -365
	add	ix, bc
	ld	(ix + 0), iy
	pop	ix
	ld	bc, 12
	call	__imulu
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 109
	ld	iy, (ix + 0)
	pop	ix
	add	iy, bc
	ld	hl, (iy)
	ld	bc, -368
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -371
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	ld	bc, 12
	call	__imulu
	push	hl
	pop	bc
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 109
	ld	hl, (iy + 0)
	add	hl, bc
	ld	hl, (hl)
	ld	bc, -371
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -344
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	ld	hl, (iy + 6)
	ld	bc, 160
	add	hl, bc
	push	ix
	ld	bc, -374
	add	ix, bc
	ld	(ix + 0), hl
	pop	ix
	ld	hl, (iy + 9)
	ld	bc, 120
	add	hl, bc
	push	ix
	ld	bc, -365
	add	ix, bc
	ld	(ix + 0), hl
	pop	ix
	xor	a, a
	ld	(iy + 0), a
	ld	hl, (iy - 2)
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 115
	ld	bc, (ix + 0)
	pop	ix
	ld	h, b
	ld	l, c
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 115
	ld	(ix + 0), bc
	pop	ix
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 118
	ld	hl, (ix + 0)
	pop	ix
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 99
	ld	a, (ix + 0)                     ; 1-byte Folded Reload
	pop	ix
	ld	e, a
	call	__lmulu
	ld	c, 0
	ld	(iy + 1), c
	push	ix
	ld	bc, -344
	add	ix, bc
	ld	iy, (ix + 0)
	pop	ix
	ld	iy, (iy - 1)
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 112
	ld	bc, (ix + 0)
	pop	ix
	ld	iyh, b
	ld	iyl, c
	lea	bc, iy + 0
	call	__ldivu
	push	ix
	ld	bc, -377
	add	ix, bc
	ld	(ix + 0), hl
	pop	ix
	ld	bc, -374
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), e                         ; 1-byte Folded Spill
	push	ix
	ld	bc, -365
	add	ix, bc
	ld	hl, (ix + 0)
	pop	ix
	ld	e, a
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 115
	ld	bc, (ix + 0)
	pop	ix
	call	__lmulu
	lea	bc, iy + 0
	call	__ldivu
	ld	bc, -365
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -368
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	bc, -344
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	ld	(iy + 5), d
	ld	hl, 160
	ld	e, h
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 121
	ld	bc, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 118
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lcmpu
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	inc	a
	ld	de, -160
	push	bc
	pop	hl
	add	hl, de
	bit	0, a
	jr	nz, .LBB51_47
; %bb.46:                               ;   in Loop: Header=BB51_4 Depth=1
	or	a, a
	sbc	hl, hl
	.local	.LBB51_47
.LBB51_47:                              ;   in Loop: Header=BB51_4 Depth=1
	push	ix
	ld	de, -344
	add	ix, de
	ld	iy, (ix + 0)
	pop	ix
	ld	(iy + 6), hl
	ld	hl, 120
	ld	e, h
	push	ix
	ld	bc, -365
	add	ix, bc
	ld	iy, (ix + 0)
	pop	ix
	lea	bc, iy + 0
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 112
	ld	a, (ix + 0)                     ; 1-byte Folded Reload
	pop	ix
	call	__lcmpu
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	inc	a
	ld	de, -120
	add	iy, de
	bit	0, a
	lea	hl, iy + 0
	jr	nz, .LBB51_49
; %bb.48:                               ;   in Loop: Header=BB51_4 Depth=1
	or	a, a
	sbc	hl, hl
	.local	.LBB51_49
.LBB51_49:                              ;   in Loop: Header=BB51_4 Depth=1
	push	ix
	ld	de, -344
	add	ix, de
	ld	iy, (ix + 0)
	pop	ix
	ld	(iy + 9), hl
	ld	de, -358
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_clamp
	pop	hl
	ld	a, 1
	ld	c, a
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	h, (iy + 0)                     ; 1-byte Folded Reload
	.local	.LBB51_50
.LBB51_50:                              ; %set_layer.exit
                                        ;   in Loop: Header=BB51_4 Depth=1
	ld	a, (_current+1)
	ld	l, a
	ld	a, (_previous+1)
	cp	a, 0
	call	pe, __setflag
	ld	e, -1
	jp	p, .LBB51_52
; %bb.51:                               ; %set_layer.exit
                                        ;   in Loop: Header=BB51_4 Depth=1
	ld	e, 0
	.local	.LBB51_52
.LBB51_52:                              ; %set_layer.exit
                                        ;   in Loop: Header=BB51_4 Depth=1
	ld	a, l
	cp	a, 0
	call	pe, __setflag
	ld	a, -1
	jp	m, .LBB51_54
; %bb.53:                               ; %set_layer.exit
                                        ;   in Loop: Header=BB51_4 Depth=1
	ld	a, 0
	.local	.LBB51_54
.LBB51_54:                              ; %set_layer.exit
                                        ;   in Loop: Header=BB51_4 Depth=1
	and	a, e
	ld	d, a
	ld	l, 1
	ld	a, d
	and	a, l
	ld	l, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 89
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	ld	a, e
	xor	a, l
	ld	e, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 89
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	bit	0, e
	jp	nz, .LBB51_58
; %bb.55:                               ;   in Loop: Header=BB51_4 Depth=1
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 112
	ld	(iy + 0), d                     ; 1-byte Folded Spill
	ld	de, -365
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), c                     ; 1-byte Folded Spill
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), h                     ; 1-byte Folded Spill
	ld	de, -344
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	hl, (iy + 2)
	push	ix
	ld	de, -371
	add	ix, de
	ld	(ix + 0), hl
	pop	ix
	ld	a, (iy + 5)
	or	a, a
	sbc	hl, hl
	ld	l, a
	push	ix
	ld	de, -377
	add	ix, de
	ld	(ix + 0), hl
	pop	ix
	ld	hl, (iy + 9)
	ld	bc, -355
	lea	iy, ix + 0
	add	iy, bc
	ld	d, (iy + 0)                     ; 1-byte Folded Reload
	ld	e, d
	ld	bc, 100
	xor	a, a
	call	__lmulu
	ld	bc, 24000
	call	__ladd
	push	hl
	pop	iy
	ld	bc, -374
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), e                         ; 1-byte Folded Spill
	push	ix
	ld	bc, -377
	add	ix, bc
	ld	hl, (ix + 0)
	pop	ix
	ld	bc, 12
	call	__imulu
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 115
	ld	hl, (ix + 0)
	pop	ix
	add	hl, bc
	ld	bc, 204
	add	hl, bc
	ld	hl, (hl)
	ld	e, d
	ld	bc, 95
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	lea	hl, iy + 0
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 118
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	call	__lcmpu
	jr	c, .LBB51_57
; %bb.56:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	a, 1
	ld	de, -345
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	.local	.LBB51_57
.LBB51_57:                              ;   in Loop: Header=BB51_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	h, (iy + 0)                     ; 1-byte Folded Reload
	ld	de, -365
	lea	iy, ix + 0
	add	iy, de
	ld	c, (iy + 0)                     ; 1-byte Folded Reload
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 112
	ld	d, (iy + 0)                     ; 1-byte Folded Reload
	.local	.LBB51_58
.LBB51_58:                              ;   in Loop: Header=BB51_4 Depth=1
	bit	0, c
	ld	l, 1
	ld	bc, 60
	jr	nz, .LBB51_64
; %bb.59:                               ;   in Loop: Header=BB51_4 Depth=1
	bit	0, d
	jr	nz, .LBB51_64
; %bb.60:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	a, h
	ld	de, -354
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	h, a
	ld	l, 0
	ld	bc, 0
	jr	z, .LBB51_64
; %bb.61:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	bc, -354
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	dec	de
	push	de
	pop	bc
	sbc	hl, hl
	adc	hl, de
	ld	l, -1
	jr	z, .LBB51_63
; %bb.62:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	l, 0
	.local	.LBB51_63
.LBB51_63:                              ;   in Loop: Header=BB51_4 Depth=1
	ld	h, a
	.local	.LBB51_64
.LBB51_64:                              ;   in Loop: Header=BB51_4 Depth=1
	bit	6, h
	jp	z, .LBB51_4
; %bb.65:                               ;   in Loop: Header=BB51_4 Depth=1
	ld	a, (_previous+6)
	bit	6, a
	jp	nz, .LBB51_4
; %bb.66:
	ld	de, -344
	lea	hl, ix + 0
	push	af
	add	hl, de
	pop	af
	ld	iy, (hl)
	ld	hl, (iy + 9)
	ld	(ix - 37), hl
	ld	a, (iy + 5)
	ld	(ix - 34), a
	dec	de
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	bit	0, (iy + 0)                     ; 1-byte Folded Reload
	jr	z, .LBB51_71
; %bb.67:
	ld	l, 1
	ld	de, -378
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)
	and	a, l
	ld	l, a
	bit	0, l
	jr	nz, .LBB51_69
; %bb.68:
	or	a, a
	sbc	hl, hl
	push	hl
	call	_time
	pop	bc
	ld	(ix - 41), hl
	ld	(ix - 38), e
	.local	.LBB51_69
.LBB51_69:
	ld	l, 1
	ld	de, -378
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)
	or	a, l
	jr	.LBB51_72
	.local	.LBB51_70
.LBB51_70:
	ld	hl, _.str.35
	ld	de, _.str.1.36
	push	de
	push	hl
	call	_ui_message
	pop	hl
	pop	hl
	jr	.LBB51_73
	.local	.LBB51_71
.LBB51_71:
	ld	de, -378
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)
	ld	l, d
	and	a, l
	.local	.LBB51_72
.LBB51_72:
	ld	l, a
	ld	(ix - 42), l
	ld	de, -381
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_lib_save_strip
	pop	hl
	pop	hl
	call	_render_reset
	.local	.LBB51_73
.LBB51_73:
	ld	de, -359
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end51
.Lfunc_end51:
	.size	_viewer_run, .Lfunc_end51-_viewer_run
                                        ; -- End function
	.section	.text._clamp,"ax",@progbits
	.type	_clamp,@function                ; -- Begin function clamp
_clamp:                                 ; @clamp
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	iy, (ix + 6)
	lea	hl, iy + 0
	ld	hl, (hl)
	ld	a, (iy + 3)
	push	hl
	pop	iy
	ld	de, 0
	push	de
	pop	hl
	ld	l, a
	ld	bc, 12
	call	__imulu
	push	hl
	pop	bc
	add	iy, bc
	ld	bc, 202
	lea	hl, iy + 0
	add	hl, bc
	ld	bc, (hl)
	push	de
	pop	hl
	ld	l, c
	ld	h, b
	or	a, a
	ld	bc, 320
	sbc	hl, bc
	push	de
	pop	bc
	jr	c, .LBB52_2
; %bb.1:
	push	hl
	pop	bc
	.local	.LBB52_2
.LBB52_2:
	ld	(ix - 3), bc
	ld	bc, 204
	add	iy, bc
	ld	hl, (iy)
	or	a, a
	ld	bc, 240
	sbc	hl, bc
	jr	c, .LBB52_4
; %bb.3:
	ex	de, hl
	.local	.LBB52_4
.LBB52_4:
	ld	(ix - 6), de
	ld	iy, (ix + 6)
	ld	bc, (iy + 4)
	ld	de, (ix - 3)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB52_6
; %bb.5:
	ld	(iy + 4), de
	.local	.LBB52_6
.LBB52_6:
	ld	bc, (iy + 7)
	ld	de, (ix - 6)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB52_8
; %bb.7:
	ld	(iy + 7), de
	.local	.LBB52_8
.LBB52_8:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end52
.Lfunc_end52:
	.size	_clamp, .Lfunc_end52-_clamp
                                        ; -- End function
	.section	.text._pan,"ax",@progbits
	.type	_pan,@function                  ; -- Begin function pan
_pan:                                   ; @pan
; %bb.0:
	ld	hl, -9
	call	__frameset
	ld	iy, (ix + 6)
	lea	hl, iy + 0
	ld	hl, (hl)
	ld	a, (iy + 3)
	push	hl
	pop	iy
	ld	de, 0
	ld	e, a
	ld	bc, 12
	push	de
	pop	hl
	call	__imulu
	push	hl
	pop	bc
	add	iy, bc
	ld	bc, 202
	lea	hl, iy + 0
	add	hl, bc
	ld	hl, (hl)
	ld	e, l
	ld	d, h
	or	a, a
	ex	de, hl
	ld	de, 320
	sbc	hl, de
	ld	de, 0
	ld	(ix - 3), de
	jr	c, .LBB53_2
; %bb.1:
	ex	de, hl
	.local	.LBB53_2
.LBB53_2:
	ld	(ix - 9), de
	ld	de, (ix + 9)
	ld	bc, 204
	add	iy, bc
	ld	hl, (iy)
	or	a, a
	ld	bc, 240
	sbc	hl, bc
	ld	bc, 0
	jr	c, .LBB53_4
; %bb.3:
	push	hl
	pop	bc
	.local	.LBB53_4
.LBB53_4:
	ld	(ix - 6), bc
	ld	bc, 0
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB53_7
; %bb.5:
	push	de
	pop	hl
	call	__ineg
	push	hl
	pop	bc
	ld	iy, (ix + 6)
	ld	hl, (iy + 4)
	push	hl
	pop	iy
	add	iy, de
	or	a, a
	sbc	hl, bc
	ld	hl, 0
	jr	c, .LBB53_10
; %bb.6:
	lea	hl, iy + 0
	jr	.LBB53_10
	.local	.LBB53_7
.LBB53_7:
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB53_11
; %bb.8:
	ld	iy, (ix + 6)
	ld	iy, (iy + 4)
	add	iy, de
	lea	hl, iy + 0
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	lea	hl, iy + 0
	jr	c, .LBB53_10
; %bb.9:
	ex	de, hl
	.local	.LBB53_10
.LBB53_10:
	ld	iy, (ix + 6)
	ld	(iy + 4), hl
	.local	.LBB53_11
.LBB53_11:
	ld	bc, (ix + 12)
	push	bc
	pop	hl
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB53_15
; %bb.12:
	push	bc
	pop	hl
	call	__ineg
	ex	de, hl
	ld	iy, (ix + 6)
	ld	hl, (iy + 7)
	push	hl
	pop	iy
	add	iy, bc
	or	a, a
	sbc	hl, de
	jr	c, .LBB53_14
; %bb.13:
	ld	(ix - 3), iy
	.local	.LBB53_14
.LBB53_14:
	ld	iy, (ix + 6)
	ld	hl, (ix - 3)
	jr	.LBB53_19
	.local	.LBB53_15
.LBB53_15:
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB53_20
; %bb.16:
	ld	iy, (ix + 6)
	ld	iy, (iy + 7)
	add	iy, bc
	lea	hl, iy + 0
	ld	de, (ix - 6)
	or	a, a
	sbc	hl, de
	lea	hl, iy + 0
	jr	c, .LBB53_18
; %bb.17:
	ex	de, hl
	.local	.LBB53_18
.LBB53_18:
	ld	iy, (ix + 6)
	.local	.LBB53_19
.LBB53_19:
	ld	(iy + 7), hl
	.local	.LBB53_20
.LBB53_20:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end53
.Lfunc_end53:
	.size	_pan, .Lfunc_end53-_pan
                                        ; -- End function
	.section	.rodata._.str,"a",@progbits
	.balign	1
	.local	_.str
_.str:
	.asciz	"CSX1"

	.section	.bss._current,"aw",@nobits
	.balign	1
	.local	_current
_current:
	.zero	8

	.section	.bss._previous,"aw",@nobits
	.balign	1
	.local	_previous
_previous:
	.zero	8

	.section	.bss._repeat_key,"aw",@nobits
	.balign	2
	.local	_repeat_key
_repeat_key:
	.zero	2

	.section	.bss._repeat_frames,"aw",@nobits
	.balign	1
	.local	_repeat_frames
_repeat_frames:
	.zero	3

	.section	.bss._index_data,"aw",@nobits
	.balign	1
	.local	_index_data
_index_data:
	.zero	3

	.section	.bss._strip_count,"aw",@nobits
	.balign	2
	.local	_strip_count
_strip_count:
	.zero	2

	.section	.bss._book_count,"aw",@nobits
	.balign	2
	.local	_book_count
_book_count:
	.zero	2

	.section	.rodata._.str.2.4,"a",@progbits
	.balign	1
	.local	_.str.2.4
_.str.2.4:
	.asciz	"r+"

	.section	.bss._title_scratch,"aw",@nobits
	.balign	1
	.local	_title_scratch
_title_scratch:
	.zero	1200

	.section	.rodata._.str.5,"a",@progbits
	.balign	1
	.local	_.str.5
_.str.5:
	.asciz	"Not enough free memory."

	.section	.rodata._.str.1.6,"a",@progbits
	.balign	1
	.local	_.str.1.6
_.str.1.6:
	.asciz	"Archive or delete some files."

	.section	.bss._expand,"aw",@nobits
	.balign	2
	.local	_expand
_expand:
	.zero	512

	.section	.bss._cache_slots,"aw",@nobits
	.balign	1
	.local	_cache_slots
_cache_slots:
	.zero	1

	.section	.bss._cache_data,"aw",@nobits
	.balign	1
	.local	_cache_data
_cache_data:
	.zero	36

	.section	.bss._cache_band,"aw",@nobits
	.balign	2
	.local	_cache_band
_cache_band:
	.zero	24

	.section	.bss._cache_used,"aw",@nobits
	.balign	2
	.local	_cache_used
_cache_used:
	.zero	24

	.section	.bss._cache_clock,"aw",@nobits
	.balign	2
	.local	_cache_clock
_cache_clock:
	.zero	2

	.section	.rodata._.str.17,"a",@progbits
	.balign	1
	.local	_.str.17
_.str.17:
	.asciz	"Books"

	.section	.rodata._.str.1.18,"a",@progbits
	.balign	1
	.local	_.str.1.18
_.str.1.18:
	.asciz	"No comics yet."

	.section	.rodata._.str.2.19,"a",@progbits
	.balign	1
	.local	_.str.2.19
_.str.2.19:
	.asciz	"Press 2nd to sync from a computer."

	.section	.rodata._.str.3,"a",@progbits
	.balign	1
	.local	_.str.3
_.str.3:
	.asciz	"%u/%u"

	.section	.rodata._.str.4,"a",@progbits
	.balign	1
	.local	_.str.4
_.str.4:
	.asciz	"enter open   2nd sync   clear quit"

	.section	.rodata._.str.5.22,"a",@progbits
	.balign	1
	.local	_.str.5.22
_.str.5.22:
	.asciz	"Strips"

	.section	.rodata._.str.6,"a",@progbits
	.balign	1
	.local	_.str.6
_.str.6:
	.asciz	"*"

	.section	.rodata._.str.7,"a",@progbits
	.balign	1
	.local	_.str.7
_.str.7:
	.asciz	"%uK"

	.section	.rodata._.str.8,"a",@progbits
	.balign	1
	.local	_.str.8
_.str.8:
	.asciz	"enter read   clear back"

	.section	.bss._sync_chunks_received,"aw",@nobits
	.balign	1
	.local	_sync_chunks_received
_sync_chunks_received:
	.zero	1

	.section	.bss._sync_state,"aw",@nobits
	.balign	1
	.local	_sync_state
_sync_state:
	.zero	32

	.section	.rodata._.str.9,"a",@progbits
	.balign	1
	.local	_.str.9
_.str.9:
	.asciz	"Starting..."

	.section	.rodata._.str.10,"a",@progbits
	.balign	1
	.local	_.str.10
_.str.10:
	.asciz	"Could not take over USB."

	.section	.rodata._.str.11,"a",@progbits
	.balign	1
	.local	_.str.11
_.str.11:
	.asciz	"Unplug the cable and retry."

	.section	.rodata._.str.12,"a",@progbits
	.balign	1
	.local	_.str.12
_.str.12:
	.asciz	"Sync"

	.section	.rodata._.str.13,"a",@progbits
	.balign	1
	.local	_.str.13
_.str.13:
	.asciz	"%u chunks received"

	.section	.rodata._.str.14,"a",@progbits
	.balign	1
	.local	_.str.14
_.str.14:
	.asciz	"clear  stop syncing"

	.section	.rodata._.str.15,"a",@progbits
	.balign	1
	.local	_.str.15
_.str.15:
	.asciz	"%s"

	.section	.bss._host_device,"aw",@nobits
	.balign	1
	.local	_host_device
_host_device:
	.zero	3

	.section	.bss._endpoint_out,"aw",@nobits
	.balign	1
	.local	_endpoint_out
_endpoint_out:
	.zero	3

	.section	.bss._endpoint_in,"aw",@nobits
	.balign	1
	.local	_endpoint_in
_endpoint_in:
	.zero	3

	.section	.bss._configured,"aw",@nobits
	.balign	1
	.local	_configured
_configured:
	.zero	1

	.section	.bss._finished,"aw",@nobits
	.balign	1
	.local	_finished
_finished:
	.zero	1

	.section	.bss._header_posted,"aw",@nobits
	.balign	1
	.local	_header_posted
_header_posted:
	.zero	1

	.section	.bss._header_ready,"aw",@nobits
	.balign	1
	.local	_header_ready
_header_ready:
	.zero	1

	.section	.bss._link_lost,"aw",@nobits
	.balign	1
	.local	_link_lost
_link_lost:
	.zero	1

	.section	.rodata._descriptors,"a",@progbits
	.balign	1
	.local	_descriptors
_descriptors:
	d24	_device_descriptor
	d24	_configurations
	d24	_langids
	db	2                               ; 0x2
	d24	_strings

	.section	.bss._request_header,"aw",@nobits
	.balign	1
	.local	_request_header
_request_header:
	.zero	8

	.section	.rodata._.str.31,"a",@progbits
	.balign	1
	.local	_.str.31
_.str.31:
	.asciz	"Connected"

	.section	.rodata._.str.1.32,"a",@progbits
	.balign	1
	.local	_.str.1.32
_.str.1.32:
	.asciz	"Waiting for computer"

	.section	.bss._setup_buffer,"aw",@nobits
	.balign	1
	.local	_setup_buffer
_setup_buffer:
	.zero	64

	.section	.rodata._bos_descriptor,"a",@progbits
	.balign	1
	.local	_bos_descriptor
_bos_descriptor:
	.asciz	"\005\0179\000\002\030\020\005\0008\266\b4\251\t\240G\213\375\240v\210\025\266e\000\001!\000\034\020\005\000\337`\335\330\211E\307L\234\322e\235\236d\212\237\000\000\003\006.\000\042"

	.section	.rodata._msos_descriptor,"a",@progbits
	.balign	1
	.local	_msos_descriptor
_msos_descriptor:
	.ascii	"\n\000\000\000\000\000\003\006.\000\b\000\001\000\000\000$\000\b\000\002\000\000\000\034\000\024\000\003\000WINUSB"
	.zero	10

	.section	.rodata._device_descriptor,"a",@progbits
	.balign	2
	.local	_device_descriptor
_device_descriptor:
	db	18                              ; 0x12
	db	1                               ; 0x1
	dw	528                             ; 0x210
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	64                              ; 0x40
	dw	4617                            ; 0x1209
	dw	1                               ; 0x1
	dw	256                             ; 0x100
	db	1                               ; 0x1
	db	2                               ; 0x2
	db	0                               ; 0x0
	db	1                               ; 0x1

	.section	.rodata._configurations,"a",@progbits
	.balign	1
	.local	_configurations
_configurations:
	d24	_configuration

	.section	.rodata._langids,"a",@progbits
	.balign	1
	.local	_langids
_langids:
	.ascii	"\004\003\t\004"

	.section	.rodata._strings,"a",@progbits
	.balign	1
	.local	_strings
_strings:
	d24	_string_manufacturer
	d24	_string_product

	.section	.rodata._configuration,"a",@progbits
	.balign	1
	.local	_configuration
_configuration:
	.asciz	"\t\002 \000\001\001\000\200}\t\004\000\000\002\377\000\000\000\007\005\001\002@\000\000\007\005\202\002@\000"

	.section	.rodata._string_manufacturer,"a",@progbits
	.balign	1
	.local	_string_manufacturer
_string_manufacturer:
	.asciz	"\022\003e\000B\000o\000o\000k\000S\000y\000n"

	.section	.rodata._string_product,"a",@progbits
	.balign	1
	.local	_string_product
_string_product:
	.asciz	"\034\003C\000o\000m\000i\000c\000 \000R\000e\000a\000d\000e\000r\000 "

	.section	.bss._stream,"aw",@nobits
	.balign	1
	.local	_stream
_stream:
	.zero	512

	.section	.rodata._.str.3.27,"a",@progbits
	.balign	1
	.local	_.str.3.27
_.str.3.27:
	.asciz	"w"

	.section	.rodata._.str.4.28,"a",@progbits
	.balign	1
	.local	_.str.4.28
_.str.4.28:
	.asciz	"Receiving"

	.section	.rodata._.str.5.29,"a",@progbits
	.balign	1
	.local	_.str.5.29
_.str.5.29:
	.asciz	"CSLIB"

	.section	.rodata._.str.6.30,"a",@progbits
	.balign	1
	.local	_.str.6.30
_.str.6.30:
	.asciz	"r"

	.section	.rodata._.str.35,"a",@progbits
	.balign	1
	.local	_.str.35
_.str.35:
	.asciz	"Cannot open this strip."

	.section	.rodata._.str.1.36,"a",@progbits
	.balign	1
	.local	_.str.1.36
_.str.1.36:
	.asciz	"Re-sync it from the computer."

	.section	.rodata._.str.2.39,"a",@progbits
	.balign	1
	.local	_.str.2.39
_.str.2.39:
	.asciz	"%u.%ux %u%%%s"

	.section	.rodata._.str.3.37,"a",@progbits
	.balign	1
	.local	_.str.3.37
_.str.3.37:
	.asciz	" read"

	.section	.rodata._.str.4.38,"a",@progbits
	.balign	1
	.local	_.str.4.38
_.str.4.38:
	.zero	1

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	__sdivs
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_llvm.usub.sat.i24
	.extern	__ldivu
	.extern	_ti_GetSize
	.extern	__iremu
	.extern	_llvm.lifetime.end.p0
	.extern	_memcpy
	.extern	_llvm.umin.i32
	.extern	__ishru
	.extern	__sdivu
	.extern	_llvm.umax.i24
	.extern	__Unwind_SjLj_Unregister
	.extern	__sor
	.extern	_gfx_FillScreen
	.extern	_llvm.usub.sat.i16
	.extern	_gfx_FillRectangle_NoClip
	.extern	__bshru
	.extern	_kb_Scan
	.extern	_usb_Init
	.extern	_gfx_PrintStringXY
	.extern	__ineg
	.extern	_ti_ArchiveHasRoom
	.extern	_llvm.umax.i8
	.extern	_gfx_SetColor
	.extern	_llvm.memset.p0.i24
	.extern	_llvm.memcpy.p0.p0.i24
	.extern	_gfx_End
	.extern	__lsub
	.extern	_time
	.extern	__lcmpzero
	.extern	_malloc
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.frameaddress.p0
	.extern	__lshl
	.extern	__sand
	.extern	_llvm.stackrestore.p0
	.extern	_ti_Open
	.extern	_snprintf
	.extern	_sprintf
	.extern	__lcmpu
	.extern	_gfx_SetTextFGColor
	.extern	_zx0_Decompress
	.extern	_ti_Seek
	.extern	_gfx_Begin
	.extern	_strcmp
	.extern	__ladd
	.extern	__idivu
	.extern	_usb_Cleanup
	.extern	_llvm.umin.i24
	.extern	_usb_HandleEvents
	.extern	__ishru_1
	.extern	__indcallhl
	.extern	_gfx_SetTextBGColor
	.extern	_gfx_SwapDraw
	.extern	_ti_SetArchiveStatus
	.extern	_llvm.eh.sjlj.lsda
	.extern	_llvm.smax.i24
	.extern	_usb_GetDeviceEndpoint
	.extern	_free
	.extern	_strlen
	.extern	_ti_Delete
	.extern	__frameset
	.extern	_usb_FindDevice
	.extern	__iand
	.extern	__imulu
	.extern	_llvm.umax.i16
	.extern	__setflag
	.extern	_usb_ScheduleTransfer
	.extern	_llvm.eh.sjlj.callsite
	.extern	_ti_GetDataPtr
	.extern	_ti_Write
	.extern	_llvm.stacksave.p0
	.extern	_ti_Close
	.extern	_llvm.lifetime.start.p0
	.extern	_memcmp
	.extern	__lmulu
	.extern	__frameset0
	.extern	__Unwind_SjLj_Register
	.extern	_llvm.umin.i16
	.extern	__lshru
	.extern	__sshl
	.extern	__smulu
	.extern	_gfx_SetDraw
	.extern	__ishl
	.extern	_usb_Transfer
