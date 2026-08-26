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
	ld	hl, _.str.8.45
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
	ld	hl, -6
	call	__frameset
	ld	a, (_continuous)
	bit	0, a
	call	z, _kb_Scan
	ld	hl, 1
	ld	(ix - 3), hl
	ld	hl, -720878
	ld	(ix - 6), hl
	ld	de, 8
	.local	.LBB5_1
.LBB5_1:                                ; =>This Inner Loop Header: Depth=1
	ld	hl, (ix - 3)
	push	de
	pop	bc
	or	a, a
	sbc	hl, de
	jr	z, .LBB5_3
; %bb.2:                                ;   in Loop: Header=BB5_1 Depth=1
	ld	hl, (ix - 6)
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	a, l
	ld	iy, _current
	ld	de, (ix - 3)
	add	iy, de
	ld	(iy), a
	inc	de
	ld	(ix - 3), de
	ld	iy, (ix - 6)
	lea	iy, iy + 2
	ld	(ix - 6), iy
	push	bc
	pop	de
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
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_input_reset, .Lfunc_end5-_input_reset
                                        ; -- End function
	.section	.text._input_begin_continuous,"ax",@progbits
	.globl	_input_begin_continuous         ; -- Begin function input_begin_continuous
	.type	_input_begin_continuous,@function
_input_begin_continuous:                ; @input_begin_continuous
; %bb.0:
	ld	e, 3
	ld	l, 1
	ld	a, (-720896)
	or	a, e
	ld	e, a
	ld	(-720896), a
	ld	a, l
	ld	(_continuous), a
	ret
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_input_begin_continuous, .Lfunc_end6-_input_begin_continuous
                                        ; -- End function
	.section	.text._input_end_continuous,"ax",@progbits
	.globl	_input_end_continuous           ; -- Begin function input_end_continuous
	.type	_input_end_continuous,@function
_input_end_continuous:                  ; @input_end_continuous
; %bb.0:
	xor	a, a
	ld	l, -4
	ld	(_continuous), a
	ld	a, (-720896)
	and	a, l
	ld	l, a
	ld	(-720896), a
	ret
	.local	.Lfunc_end7
.Lfunc_end7:
	.size	_input_end_continuous, .Lfunc_end7-_input_end_continuous
                                        ; -- End function
	.section	.text._input_scan,"ax",@progbits
	.globl	_input_scan                     ; -- Begin function input_scan
	.type	_input_scan,@function
_input_scan:                            ; @input_scan
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	iy, _current
	ld	de, (_current)
	ld	bc, (_current+3)
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
	ld	a, (_continuous)
	bit	0, a
	call	z, _kb_Scan
	ld	de, 1
	ld	iy, -720878
	ld	bc, 8
	.local	.LBB8_1
.LBB8_1:                                ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB8_3
; %bb.2:                                ;   in Loop: Header=BB8_1 Depth=1
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	a, l
	lea	hl, iy + 0
	ld	iy, _current
	add	iy, de
	ld	(iy), a
	push	hl
	pop	iy
	inc	de
	lea	iy, iy + 2
	jr	.LBB8_1
	.local	.LBB8_3
.LBB8_3:
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end8
.Lfunc_end8:
	.size	_input_scan, .Lfunc_end8-_input_scan
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
	jr	nz, .LBB9_2
; %bb.1:
	ld	a, 0
	jr	.LBB9_3
	.local	.LBB9_2
.LBB9_2:
	ld	a, -1
	.local	.LBB9_3
.LBB9_3:
	pop	ix
	ret
	.local	.Lfunc_end9
.Lfunc_end9:
	.size	_input_down, .Lfunc_end9-_input_down
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
	jr	nz, .LBB10_2
; %bb.1:
	xor	a, a
	jp	.LBB10_5
	.local	.LBB10_2
.LBB10_2:
	ld	iy, _previous
	ld	de, (ix - 3)
	add	iy, de
	ld	a, (iy)
                                        ; kill: def $l killed $l killed $hl
	and	a, l
	ld	l, a
	or	a, a
	jr	z, .LBB10_4
; %bb.3:
	ld	a, 0
	jr	.LBB10_5
	.local	.LBB10_4
.LBB10_4:
	ld	a, -1
	.local	.LBB10_5
.LBB10_5:
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end10
.Lfunc_end10:
	.size	_input_pressed, .Lfunc_end10-_input_pressed
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
	jr	nz, .LBB11_4
; %bb.1:
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB11_3
; %bb.2:
	ld.sis	hl, 0
	ld	(iy), l
	ld	(iy + 1), h
	or	a, a
	sbc	hl, hl
	ld	(_repeat_frames), hl
	.local	.LBB11_3
.LBB11_3:
	ld	l, 0
	jr	.LBB11_8
	.local	.LBB11_4
.LBB11_4:
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB11_7
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
	jr	c, .LBB11_8
; %bb.6:
	ld	l, 1
	ld	a, e
	and	a, l
	ld	l, a
	jr	.LBB11_8
	.local	.LBB11_7
.LBB11_7:
	ld	l, 1
	ld	(iy), e
	ld	(iy + 1), d
	ld	de, 0
	ld	(_repeat_frames), de
	.local	.LBB11_8
.LBB11_8:
	ld	a, l
	pop	ix
	ret
	.local	.Lfunc_end11
.Lfunc_end11:
	.size	_input_repeat, .Lfunc_end11-_input_repeat
                                        ; -- End function
	.section	.text._input_held_frames,"ax",@progbits
	.globl	_input_held_frames              ; -- Begin function input_held_frames
	.type	_input_held_frames,@function
_input_held_frames:                     ; @input_held_frames
; %bb.0:
	ld	hl, (_repeat_frames)
	ret
	.local	.Lfunc_end12
.Lfunc_end12:
	.size	_input_held_frames, .Lfunc_end12-_input_held_frames
                                        ; -- End function
	.section	.text._input_idle,"ax",@progbits
	.globl	_input_idle                     ; -- Begin function input_idle
	.type	_input_idle,@function
_input_idle:                            ; @input_idle
; %bb.0:
	ld	bc, 1
	ld	iy, 8
	.local	.LBB13_1
.LBB13_1:                               ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	de
	push	de
	pop	hl
	lea	bc, iy + 0
	or	a, a
	sbc	hl, bc
	jr	z, .LBB13_3
; %bb.2:                                ;   in Loop: Header=BB13_1 Depth=1
	ld	hl, _current
	add	hl, de
	push	de
	pop	bc
	inc	bc
	ld	a, (hl)
	or	a, a
	jr	z, .LBB13_1
	.local	.LBB13_3
.LBB13_3:
	ex	de, hl
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	ret
	.local	.Lfunc_end13
.Lfunc_end13:
	.size	_input_idle, .Lfunc_end13-_input_idle
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
	ld	de, _.str.7.44
	ld	bc, 0
	ld	(_index_data), bc
	ld	(hl), c
	inc	hl
	ld	(hl), b
	ld	(iy), c
	ld	(iy + 1), b
	ld	hl, _.str.8.45
	push	hl
	push	de
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jp	z, .LBB14_5
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
	jr	z, .LBB14_5
; %bb.2:
	ld	hl, 5
	push	hl
	ld	hl, _.str.7.44
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
	jr	nz, .LBB14_5
; %bb.3:
	ld	iy, (ix - 3)
	ld	a, (iy + 5)
	cp	a, 1
	ld	a, 0
	jr	nz, .LBB14_6
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
	jr	.LBB14_6
	.local	.LBB14_5
.LBB14_5:
	xor	a, a
	.local	.LBB14_6
.LBB14_6:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end14
.Lfunc_end14:
	.size	_lib_open, .Lfunc_end14-_lib_open
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
	.local	.Lfunc_end15
.Lfunc_end15:
	.size	_lib_book_count, .Lfunc_end15-_lib_book_count
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
	.local	.Lfunc_end16
.Lfunc_end16:
	.size	_lib_strip_count, .Lfunc_end16-_lib_strip_count
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
	.local	.Lfunc_end17
.Lfunc_end17:
	.size	_lib_get_book, .Lfunc_end17-_lib_get_book
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
	.local	.Lfunc_end18
.Lfunc_end18:
	.size	_lib_get_strip, .Lfunc_end18-_lib_get_strip
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
	.local	.LBB19_1
.LBB19_1:                               ; =>This Inner Loop Header: Depth=1
	ld	hl, (ix - 6)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	jr	z, .LBB19_3
; %bb.2:                                ;   in Loop: Header=BB19_1 Depth=1
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
	jp	.LBB19_1
	.local	.LBB19_3
.LBB19_3:
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end19
.Lfunc_end19:
	.size	_lib_book_read_count, .Lfunc_end19-_lib_book_read_count
                                        ; -- End function
	.section	.text._lib_save_strip,"ax",@progbits
	.globl	_lib_save_strip                 ; -- Begin function lib_save_strip
	.type	_lib_save_strip,@function
_lib_save_strip:                        ; @lib_save_strip
; %bb.0:
	ld	hl, -15
	call	__frameset
	ld	hl, _.str.7.44
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
	jp	z, .LBB20_8
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
	jr	nz, .LBB20_3
; %bb.2:
	ld	hl, (ix - 15)
	push	hl
	call	_ti_Close
	pop	hl
	jp	.LBB20_8
	.local	.LBB20_3
.LBB20_3:
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
	jr	z, .LBB20_5
; %bb.4:
	ld	c, b
	.local	.LBB20_5
.LBB20_5:
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB20_7
; %bb.6:
	ld	a, b
	.local	.LBB20_7
.LBB20_7:
	and	a, c
	ld	l, a
	ld	(ix - 12), l
	ld	hl, (ix - 15)
	push	hl
	call	_ti_Close
	pop	hl
	call	_lib_open
	.local	.LBB20_8
.LBB20_8:
	ld	a, (ix - 12)                    ; 1-byte Folded Reload
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end20
.Lfunc_end20:
	.size	_lib_save_strip, .Lfunc_end20-_lib_save_strip
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
	jp	z, .LBB21_4
; %bb.1:
	ld	hl, (_index_data)
	push	hl
	pop	iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB21_4
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
	jr	c, .LBB21_4
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
	.local	.LBB21_4
.LBB21_4:
	ex	de, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end21
.Lfunc_end21:
	.size	_lib_title, .Lfunc_end21-_lib_title
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
	jr	nz, .LBB22_2
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
	jp	.LBB22_14
	.local	.LBB22_2
.LBB22_2:
	call	_lib_open
	.local	.LBB22_3
.LBB22_3:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB22_4 Depth 2
                                        ;       Child Loop BB22_6 Depth 3
	ld.sis	hl, 0
	ld	(ix - 3), l
	ld	(ix - 2), h
	.local	.LBB22_4
.LBB22_4:                               ;   Parent Loop BB22_3 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB22_6 Depth 3
	pea	ix - 3
	call	_ui_book_menu
	push	hl
	pop	bc
	pop	hl
	sbc	hl, hl
	adc	hl, bc
	jr	nz, .LBB22_8
; %bb.5:                                ; %.preheader
                                        ;   in Loop: Header=BB22_4 Depth=2
	ld	hl, (ix - 3)
	ld	(ix - 8), hl
	.local	.LBB22_6
.LBB22_6:                               ;   Parent Loop BB22_3 Depth=1
                                        ;     Parent Loop BB22_4 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	pea	ix - 5
	push	hl
	call	_ui_strip_menu
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB22_4
; %bb.7:                                ;   in Loop: Header=BB22_6 Depth=3
	ld	hl, (ix - 5)
	push	hl
	call	_viewer_run
	pop	hl
	call	_ui_set_chrome_palette
	ld	hl, (ix - 8)
	jr	.LBB22_6
	.local	.LBB22_8
.LBB22_8:                               ;   in Loop: Header=BB22_3 Depth=1
	push	bc
	pop	hl
	ld	de, 1
	or	a, a
	sbc	hl, de
	jr	z, .LBB22_13
; %bb.9:                                ;   in Loop: Header=BB22_3 Depth=1
	ld	(ix - 8), bc
	call	_render_free
	ld	hl, (ix - 8)
	ld	de, 3
	or	a, a
	sbc	hl, de
	ld	hl, -1
	jr	z, .LBB22_11
; %bb.10:                               ;   in Loop: Header=BB22_3 Depth=1
	ld	hl, 0
	.local	.LBB22_11
.LBB22_11:                              ;   in Loop: Header=BB22_3 Depth=1
	push	hl
	call	_ui_sync_run
	pop	hl
	call	_lib_open
	call	_render_init
	or	a, a
	jr	nz, .LBB22_3
; %bb.12:
	ld	hl, _.str.1.6
	push	hl
	ld	hl, _.str.5
	push	hl
	call	_ui_message
	pop	hl
	pop	hl
	.local	.LBB22_13
.LBB22_13:                              ; %.loopexit
	call	_render_free
	call	_gfx_End
	or	a, a
	sbc	hl, hl
	.local	.LBB22_14
.LBB22_14:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end22
.Lfunc_end22:
	.size	_main, .Lfunc_end22-_main
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
	.local	.LBB23_1
.LBB23_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB23_3
; %bb.2:                                ;   in Loop: Header=BB23_1 Depth=1
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
	jp	.LBB23_1
	.local	.LBB23_3
.LBB23_3:
	xor	a, a
	ld	(_cache_slots), a
	.local	.LBB23_4
.LBB23_4:                               ; =>This Inner Loop Header: Depth=1
	ld	de, 36
	ld	hl, (ix - 6)
	or	a, a
	sbc	hl, de
	jr	z, .LBB23_7
; %bb.5:                                ;   in Loop: Header=BB23_4 Depth=1
	ld	(ix - 3), a                     ; 1-byte Folded Spill
	ld	hl, 5120
	push	hl
	call	_malloc
	ex	de, hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB23_10
; %bb.6:                                ;   in Loop: Header=BB23_4 Depth=1
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
	jr	.LBB23_4
	.local	.LBB23_7
.LBB23_7:
	ld	a, 12
	.local	.LBB23_8
.LBB23_8:                               ; %.thread
	ld	(ix - 3), a
	call	_render_reset
	ld	a, (ix - 3)                     ; 1-byte Folded Reload
	.local	.LBB23_9
.LBB23_9:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB23_10
.LBB23_10:
	ld	a, (ix - 3)                     ; 1-byte Folded Reload
	cp	a, 2
	jr	nc, .LBB23_8
; %bb.11:
	call	_render_free
	xor	a, a
	jr	.LBB23_9
	.local	.Lfunc_end23
.Lfunc_end23:
	.size	_render_init, .Lfunc_end23-_render_init
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
	.local	.LBB24_1
.LBB24_1:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB24_3
; %bb.2:                                ;   in Loop: Header=BB24_1 Depth=1
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
	jr	.LBB24_1
	.local	.LBB24_3
.LBB24_3:
	xor	a, a
	ld	(_cache_slots), a
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end24
.Lfunc_end24:
	.size	_render_free, .Lfunc_end24-_render_free
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
	.local	.LBB25_1
.LBB25_1:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB25_3
; %bb.2:                                ;   in Loop: Header=BB25_1 Depth=1
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
	jr	.LBB25_1
	.local	.LBB25_3
.LBB25_3:
	ld	hl, _cache_clock
	ld.sis	de, 0
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end25
.Lfunc_end25:
	.size	_render_reset, .Lfunc_end25-_render_reset
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
	.local	.LBB26_1
.LBB26_1:                               ; =>This Inner Loop Header: Depth=1
	ld	hl, (ix - 12)
	ld	(ix - 19), hl
	ld	bc, (ix - 9)
	dec	de
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB26_4
; %bb.2:                                ;   in Loop: Header=BB26_1 Depth=1
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
	jp	nz, .LBB26_1
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
	jp	.LBB26_14
	.local	.LBB26_4
.LBB26_4:
	push	af
	ld	a, iyl
	ld	(ix - 9), a                     ; 1-byte Folded Spill
	pop	af
	cp	a, 2
	jr	nc, .LBB26_6
; %bb.5:
	ld	a, 1
	.local	.LBB26_6
.LBB26_6:
	ld	iy, 0
	lea	de, iy + 0
	ld	e, a
	dec	de
	ld	bc, (ix + 9)
	.local	.LBB26_7
.LBB26_7:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB26_11
; %bb.8:                                ;   in Loop: Header=BB26_7 Depth=1
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
	jr	c, .LBB26_10
; %bb.9:                                ;   in Loop: Header=BB26_7 Depth=1
	ld	c, a
	.local	.LBB26_10
.LBB26_10:                              ;   in Loop: Header=BB26_7 Depth=1
	ld	iy, (ix - 6)
	lea	iy, iy + 2
	ld	(ix - 6), iy
	inc	l
	ld	(ix - 13), l
	dec	de
	ld	(ix - 9), c                     ; 1-byte Folded Spill
	ld	bc, (ix + 9)
	ld	iy, 0
	jp	.LBB26_7
	.local	.LBB26_11
.LBB26_11:
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
	jr	z, .LBB26_13
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
	.local	.LBB26_13
.LBB26_13:
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
	.local	.LBB26_14
.LBB26_14:
	push	bc
	pop	hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end26
.Lfunc_end26:
	.size	_render_band, .Lfunc_end26-_render_band
                                        ; -- End function
	.section	.text._render_set_palette,"ax",@progbits
	.globl	_render_set_palette             ; -- Begin function render_set_palette
	.type	_render_set_palette,@function
_render_set_palette:                    ; @render_set_palette
; %bb.0:
	call	__frameset0
	ld	de, 0
	ld	bc, 32
	.local	.LBB27_1
.LBB27_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB27_3
; %bb.2:                                ;   in Loop: Header=BB27_1 Depth=1
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
	jr	.LBB27_1
	.local	.LBB27_3
.LBB27_3:
	pop	ix
	ret
	.local	.Lfunc_end27
.Lfunc_end27:
	.size	_render_set_palette, .Lfunc_end27-_render_set_palette
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
	jr	nz, .LBB28_2
; %bb.1:
	ld.sis	hl, 0
	jp	.LBB28_3
	.local	.LBB28_2
.LBB28_2:
                                        ; kill: def $l killed $l def $hl
	ld	h, e
	.local	.LBB28_3
.LBB28_3:
	ld	(ix - 15), l
	ld	(ix - 14), h
	or	a, a
	sbc	hl, hl
	bit	0, a
	jr	nz, .LBB28_5
; %bb.4:
	ld	hl, (ix + 12)
	.local	.LBB28_5
.LBB28_5:
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
	jp	c, .LBB28_7
; %bb.6:
	dec.sis	de
                                        ; kill: def $de killed $de killed $ude def $ude
	ld	(ix - 12), de
	.local	.LBB28_7
.LBB28_7:
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
	jp	c, .LBB28_9
; %bb.8:
	dec.sis	de
                                        ; kill: def $de killed $de killed $ude def $ude
	ld	(ix - 15), de
	.local	.LBB28_9
.LBB28_9:
	ld	hl, (ix - 21)
	ld	de, (ix - 3)
	or	a, a
	sbc	hl, de
	ld	(ix - 21), hl
	ld	de, (ix - 6)
	.local	.LBB28_10
.LBB28_10:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB28_22 Depth 2
                                        ;       Child Loop BB28_34 Depth 3
                                        ;         Child Loop BB28_39 Depth 4
	ld	hl, (ix - 12)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, de
	jp	c, .LBB28_43
; %bb.11:                               ;   in Loop: Header=BB28_10 Depth=1
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
	jr	c, .LBB28_13
; %bb.12:                               ;   in Loop: Header=BB28_10 Depth=1
	ld	iy, 320
	.local	.LBB28_13
.LBB28_13:                              ;   in Loop: Header=BB28_10 Depth=1
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
	jr	c, .LBB28_15
; %bb.14:                               ;   in Loop: Header=BB28_10 Depth=1
	push	hl
	pop	bc
	.local	.LBB28_15
.LBB28_15:                              ;   in Loop: Header=BB28_10 Depth=1
	ld	iy, (ix - 21)
	add	iy, de
	lea	hl, iy + 0
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB28_17
; %bb.16:                               ;   in Loop: Header=BB28_10 Depth=1
	ld	iy, 0
	.local	.LBB28_17
.LBB28_17:                              ;   in Loop: Header=BB28_10 Depth=1
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
	jp	m, .LBB28_19
; %bb.18:                               ;   in Loop: Header=BB28_10 Depth=1
	ld	e, iyl
	ld	d, iyh
	.local	.LBB28_19
.LBB28_19:                              ;   in Loop: Header=BB28_10 Depth=1
	ld	(ix - 27), de
	sbc.sis	hl, hl
	adc.sis	hl, de
	ld	de, (ix - 6)
	jr	nz, .LBB28_21
	.local	.LBB28_20
.LBB28_20:                              ; %.loopexit6
                                        ;   in Loop: Header=BB28_10 Depth=1
	inc.sis	de
	jp	.LBB28_10
	.local	.LBB28_21
.LBB28_21:                              ;   in Loop: Header=BB28_10 Depth=1
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
	.local	.LBB28_22
.LBB28_22:                              ;   Parent Loop BB28_10 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB28_34 Depth 3
                                        ;         Child Loop BB28_39 Depth 4
	ld	hl, (ix - 15)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	jp	c, .LBB28_20
; %bb.23:                               ;   in Loop: Header=BB28_22 Depth=2
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
	jr	nz, .LBB28_25
	.local	.LBB28_24
.LBB28_24:                              ; %.loopexit
                                        ;   in Loop: Header=BB28_22 Depth=2
	ld	c, (ix - 24)
	ld	b, (ix - 23)
	inc.sis	bc
	ld	de, (ix - 6)
	jp	.LBB28_22
	.local	.LBB28_25
.LBB28_25:                              ;   in Loop: Header=BB28_22 Depth=2
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
	jr	c, .LBB28_27
; %bb.26:                               ;   in Loop: Header=BB28_22 Depth=2
	ld	iy, 32
	.local	.LBB28_27
.LBB28_27:                              ;   in Loop: Header=BB28_22 Depth=2
	ld	(ix - 42), iy
	or	a, a
	ld	hl, (ix + 15)
	sbc	hl, bc
	ld	iy, 0
	jr	c, .LBB28_29
; %bb.28:                               ;   in Loop: Header=BB28_22 Depth=2
	push	hl
	pop	iy
	.local	.LBB28_29
.LBB28_29:                              ;   in Loop: Header=BB28_22 Depth=2
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
	jp	p, .LBB28_31
; %bb.30:                               ;   in Loop: Header=BB28_22 Depth=2
	ld	de, 0
	.local	.LBB28_31
.LBB28_31:                              ;   in Loop: Header=BB28_22 Depth=2
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
	jp	m, .LBB28_33
; %bb.32:                               ;   in Loop: Header=BB28_22 Depth=2
	ld	e, iyl
	.local	.LBB28_33
.LBB28_33:                              ;   in Loop: Header=BB28_22 Depth=2
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
	.local	.LBB28_34
.LBB28_34:                              ;   Parent Loop BB28_10 Depth=1
                                        ;     Parent Loop BB28_22 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB28_39 Depth 4
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB28_24
; %bb.35:                               ;   in Loop: Header=BB28_34 Depth=3
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
	jp	nz, .LBB28_37
; %bb.36:                               ;   in Loop: Header=BB28_34 Depth=3
	ld	(ix - 45), iy
	ld	hl, (ix - 27)
                                        ; kill: def $hl killed $hl killed $uhl
	jr	.LBB28_39
	.local	.LBB28_37
.LBB28_37:                              ;   in Loop: Header=BB28_34 Depth=3
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
	jr	.LBB28_39
	.local	.LBB28_38
.LBB28_38:                              ;   in Loop: Header=BB28_39 Depth=4
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
	.local	.LBB28_39
.LBB28_39:                              ;   Parent Loop BB28_10 Depth=1
                                        ;     Parent Loop BB28_22 Depth=2
                                        ;       Parent Loop BB28_34 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	ld	e, l
	ld	d, h
	ld.sis	bc, 2
	or	a, a
	sbc.sis	hl, bc
	jr	nc, .LBB28_38
; %bb.40:                               ;   in Loop: Header=BB28_34 Depth=3
	sbc.sis	hl, hl
	adc.sis	hl, de
	jr	z, .LBB28_42
; %bb.41:                               ;   in Loop: Header=BB28_34 Depth=3
	ld	hl, (ix - 45)
	ld	a, (hl)
	ld	b, 4
	call	__bshru
	ld	hl, (ix - 42)
	ld	(hl), a
	.local	.LBB28_42
.LBB28_42:                              ;   in Loop: Header=BB28_34 Depth=3
	ld	de, (ix - 65)
	inc	de
	ld	bc, (ix - 62)
	jp	.LBB28_34
	.local	.LBB28_43
.LBB28_43:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end28
.Lfunc_end28:
	.size	_render_view, .Lfunc_end28-_render_view
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
	.local	.Lfunc_end29
.Lfunc_end29:
	.size	_ui_set_chrome_palette, .Lfunc_end29-_ui_set_chrome_palette
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
	.local	.LBB30_1
.LBB30_1:                               ; =>This Inner Loop Header: Depth=1
	lea	hl, iy + 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB30_3
; %bb.2:                                ;   in Loop: Header=BB30_1 Depth=1
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
	jp	.LBB30_1
	.local	.LBB30_3
.LBB30_3:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end30
.Lfunc_end30:
	.size	_set_ramp, .Lfunc_end30-_set_ramp
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
	.local	.Lfunc_end31
.Lfunc_end31:
	.size	_ui_header, .Lfunc_end31-_ui_header
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
	.local	.Lfunc_end32
.Lfunc_end32:
	.size	_ui_footer, .Lfunc_end32-_ui_footer
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
	jr	nz, .LBB33_2
	.local	.LBB33_1
.LBB33_1:                               ; %.loopexit5
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB33_2
.LBB33_2:
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
	jp	p, .LBB33_4
; %bb.3:
	ld	l, e
	ld	h, d
	ld	(ix - 7), l
	ld	(ix - 6), h
	.local	.LBB33_4
.LBB33_4:
	bit	0, a
	jr	nz, .LBB33_6
; %bb.5:
	ld	a, -16
	jr	.LBB33_7
	.local	.LBB33_6
.LBB33_6:
	ld	a, -12
	.local	.LBB33_7
.LBB33_7:
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
	.local	.LBB33_8
.LBB33_8:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB33_12 Depth 2
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jp	z, .LBB33_1
; %bb.9:                                ;   in Loop: Header=BB33_8 Depth=1
	ld	(ix - 16), de
	lea	hl, iy + 0
	ld	de, (ix + 12)
	add	hl, de
	or	a, a
	sbc	hl, bc
	jr	c, .LBB33_11
	.local	.LBB33_10
.LBB33_10:                              ; %.loopexit
                                        ;   in Loop: Header=BB33_8 Depth=1
	inc	iy
	ld	hl, (ix - 7)
	ld	de, 320
	add	hl, de
	ld	(ix - 7), hl
	ld	de, (ix - 16)
	ld	bc, 240
	jr	.LBB33_8
	.local	.LBB33_11
.LBB33_11:                              ;   in Loop: Header=BB33_8 Depth=1
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
	.local	.LBB33_12
.LBB33_12:                              ;   Parent Loop BB33_8 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	de
	pop	hl
	ld	bc, (ix - 13)
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB33_10
; %bb.13:                               ;   in Loop: Header=BB33_12 Depth=2
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
	jr	z, .LBB33_15
; %bb.14:                               ;   in Loop: Header=BB33_12 Depth=2
	ld	c, (ix - 21)
	ld	a, l
	add	a, c
	ld	c, a
	ld	hl, (ix - 27)
	add	hl, de
	ld	(hl), c
	.local	.LBB33_15
.LBB33_15:                              ;   in Loop: Header=BB33_12 Depth=2
	inc	de
	ld	l, 2
	ld	c, (ix - 17)
	ld	a, c
	add	a, l
	ld	c, a
	ld	(ix - 17), c
	jr	.LBB33_12
	.local	.Lfunc_end33
.Lfunc_end33:
	.size	_ui_draw_title, .Lfunc_end33-_ui_draw_title
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
	jr	z, .LBB34_2
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
	.local	.LBB34_2
.LBB34_2:
	call	_gfx_SwapDraw
	call	_input_reset
	.local	.LBB34_3
.LBB34_3:                               ; =>This Inner Loop Header: Depth=1
	call	_input_scan
	call	_input_idle
	bit	0, a
	jr	z, .LBB34_3
	.local	.LBB34_4
.LBB34_4:                               ; %.preheader1
                                        ; =>This Inner Loop Header: Depth=1
	call	_input_scan
	call	_input_idle
	bit	0, a
	jr	nz, .LBB34_4
	.local	.LBB34_5
.LBB34_5:                               ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	call	_input_scan
	call	_input_idle
	bit	0, a
	jr	z, .LBB34_5
; %bb.6:
	pop	ix
	ret
	.local	.Lfunc_end34
.Lfunc_end34:
	.size	_ui_message, .Lfunc_end34-_ui_message
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
	ld	(ix - 52), hl
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
	ld	(ix - 46), de
	push	de
	call	_list_move
	pop	hl
	pop	hl
	.local	.LBB35_1
.LBB35_1:                               ; %.loopexit5
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB35_8 Depth 2
                                        ;     Child Loop BB35_15 Depth 2
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
	jr	nz, .LBB35_3
; %bb.2:                                ;   in Loop: Header=BB35_1 Depth=1
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
	.local	.LBB35_3
.LBB35_3:                               ;   in Loop: Header=BB35_1 Depth=1
	ld	hl, (ix - 3)
	ld	(ix - 58), hl
	ld	e, l
	ld	d, h
	ld	hl, (ix - 5)
	ld	(ix - 43), hl
	or	a, a
	ld	l, c
	ld	h, b
	sbc.sis	hl, de
	ld.sis	bc, 0
	jr	c, .LBB35_5
; %bb.4:                                ;   in Loop: Header=BB35_1 Depth=1
	ld	c, l
	ld	b, h
	.local	.LBB35_5
.LBB35_5:                               ;   in Loop: Header=BB35_1 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	pop	iy
	ld	l, e
	ld	h, d
	ld	(ix - 40), hl
	ld	hl, (ix - 43)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	(ix - 43), iy
	ld	l, c
	ld	h, b
	ld.sis	de, 10
	sbc.sis	hl, de
	jr	c, .LBB35_7
; %bb.6:                                ;   in Loop: Header=BB35_1 Depth=1
	ld.sis	bc, 10
	.local	.LBB35_7
.LBB35_7:                               ;   in Loop: Header=BB35_1 Depth=1
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	bc, 20
	call	__imulu
	push	hl
	pop	iy
	ld	hl, (ix - 43)
	ld	de, (ix - 40)
	or	a, a
	sbc	hl, de
	ld	(ix - 49), hl
	ld.sis	hl, 0
                                        ; kill: def $hl killed $hl def $uhl
	ld	(ix - 43), hl
	or	a, a
	sbc	hl, hl
	ld	(ix - 40), hl
	ld	de, (ix - 46)
	.local	.LBB35_8
.LBB35_8:                               ;   Parent Loop BB35_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	ld	bc, (ix - 40)
	or	a, a
	sbc	hl, bc
	jp	z, .LBB35_14
; %bb.9:                                ;   in Loop: Header=BB35_8 Depth=2
	ld	(ix - 61), iy
	ld	hl, (ix - 43)
	push	hl
	push	de
	call	_draw_row_background
	pop	hl
	pop	hl
	ld	hl, (ix - 58)
                                        ; kill: def $hl killed $hl killed $uhl def $uhl
	ld	de, (ix - 43)
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
	ld	hl, (ix - 49)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, -1
	jr	z, .LBB35_11
; %bb.10:                               ;   in Loop: Header=BB35_8 Depth=2
	ld	a, 0
	.local	.LBB35_11
.LBB35_11:                              ;   in Loop: Header=BB35_8 Depth=2
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
	ld	hl, (ix - 52)
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
	jr	nz, .LBB35_13
; %bb.12:                               ;   in Loop: Header=BB35_8 Depth=2
	ld	a, -8
	ld	l, a
	.local	.LBB35_13
.LBB35_13:                              ;   in Loop: Header=BB35_8 Depth=2
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	hl, (ix - 52)
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
	ld	hl, (ix - 52)
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	de, 20
	ld	iy, (ix - 40)
	add	iy, de
	ld	hl, (ix - 49)
	dec	hl
	ld	(ix - 49), hl
	ld	hl, (ix - 43)
	inc.sis	hl
	ld	(ix - 43), hl
	ld	(ix - 40), iy
	ld	de, (ix - 46)
	ld	iy, (ix - 61)
	jp	.LBB35_8
	.local	.LBB35_14
.LBB35_14:                              ;   in Loop: Header=BB35_1 Depth=1
	push	de
	call	_draw_scrollbar
	pop	hl
	ld	hl, _.str.4
	push	hl
	call	_ui_footer
	pop	hl
	call	_gfx_SwapDraw
	.local	.LBB35_15
.LBB35_15:                              ;   Parent Loop BB35_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	call	_input_scan
	ld	hl, (ix - 46)
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
	jr	z, .LBB35_18
; %bb.16:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB35_15 Depth=2
	ld	a, (_previous+6)
	and	a, h
	ld	l, a
	bit	0, l
	jr	nz, .LBB35_18
; %bb.17:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB35_15 Depth=2
	ld	hl, (ix - 7)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jr	nz, .LBB35_27
	.local	.LBB35_18
.LBB35_18:                              ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB35_15 Depth=2
	ld	a, (_current+1)
	bit	5, a
	jr	z, .LBB35_20
; %bb.19:                               ; %input_pressed.exit1
                                        ;   in Loop: Header=BB35_15 Depth=2
	ld	a, (_previous+1)
	bit	5, a
	jr	z, .LBB35_25
	.local	.LBB35_20
.LBB35_20:                              ; %input_pressed.exit1.thread
                                        ;   in Loop: Header=BB35_15 Depth=2
	ld	a, (_current+2)
	ld	h, a
	ld	a, (_previous+2)
	ld	l, a
	ld	a, h
	cp	a, 0
	call	pe, __setflag
	jp	p, .LBB35_22
; %bb.21:                               ; %input_pressed.exit1.thread
                                        ;   in Loop: Header=BB35_15 Depth=2
	ld	a, l
	cp	a, 0
	call	pe, __setflag
	jp	p, .LBB35_26
	.local	.LBB35_22
.LBB35_22:                              ; %input_pressed.exit2.thread
                                        ;   in Loop: Header=BB35_15 Depth=2
	bit	6, c
	jr	z, .LBB35_24
; %bb.23:                               ; %input_pressed.exit3
                                        ;   in Loop: Header=BB35_15 Depth=2
	ld	a, (_previous+6)
	bit	6, a
	jr	z, .LBB35_28
	.local	.LBB35_24
.LBB35_24:                              ; %input_pressed.exit3.thread
                                        ;   in Loop: Header=BB35_15 Depth=2
	bit	0, e
	jr	z, .LBB35_15
	jp	.LBB35_1
	.local	.LBB35_25
.LBB35_25:
	ld	hl, 2
	jr	.LBB35_29
	.local	.LBB35_26
.LBB35_26:
	ld	hl, 3
	jr	.LBB35_29
	.local	.LBB35_27
.LBB35_27:
	ld	hl, (ix - 5)
	ld	iy, (ix + 6)
	ld	(iy), l
	ld	(iy + 1), h
	or	a, a
	sbc	hl, hl
	jr	.LBB35_29
	.local	.LBB35_28
.LBB35_28:
	ld	hl, 1
	.local	.LBB35_29
.LBB35_29:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end35
.Lfunc_end35:
	.size	_ui_book_menu, .Lfunc_end35-_ui_book_menu
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
	jp	z, .LBB36_10
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
	jp	p, .LBB36_3
; %bb.2:
	or	a, a
	sbc	hl, hl
	.local	.LBB36_3
.LBB36_3:
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
	jp	m, .LBB36_5
; %bb.4:
	dec	de
	ex	de, hl
	.local	.LBB36_5
.LBB36_5:
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
	jr	nc, .LBB36_7
; %bb.6:
	ld	hl, (ix - 3)
	jr	.LBB36_9
	.local	.LBB36_7
.LBB36_7:
	ex	de, hl
	ld	de, 10
	add	hl, de
	ex	de, hl
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	c, .LBB36_10
; %bb.8:
	ld.sis	de, -9
	ld	hl, (ix - 3)
	add.sis	hl, de
	.local	.LBB36_9
.LBB36_9:
	ld	(iy + 4), l
	ld	(iy + 5), h
	.local	.LBB36_10
.LBB36_10:
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end36
.Lfunc_end36:
	.size	_list_move, .Lfunc_end36-_list_move
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
	jr	z, .LBB37_2
; %bb.1:
	ld	l, -8
	jr	.LBB37_3
	.local	.LBB37_2
.LBB37_2:
	ld	l, -4
	.local	.LBB37_3
.LBB37_3:
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
	.local	.Lfunc_end37
.Lfunc_end37:
	.size	_draw_row_background, .Lfunc_end37-_draw_row_background
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
	jp	c, .LBB38_4
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
	jr	nc, .LBB38_3
; %bb.2:
	ld.sis	iy, 8
	.local	.LBB38_3
.LBB38_3:
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
	.local	.LBB38_4
.LBB38_4:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end38
.Lfunc_end38:
	.size	_draw_scrollbar, .Lfunc_end38-_draw_scrollbar
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
	jr	z, .LBB39_2
; %bb.1:
	scf
	sbc	hl, hl
	jr	.LBB39_8
	.local	.LBB39_2
.LBB39_2:
	ld	hl, 1793
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB39_4
; %bb.3:
	ld	hl, 1
	jr	.LBB39_8
	.local	.LBB39_4
.LBB39_4:
	ld	hl, 1794
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB39_6
; %bb.5:
	ld	hl, -10
	jr	.LBB39_8
	.local	.LBB39_6
.LBB39_6:
	ld	hl, 1796
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB39_10
; %bb.7:
	ld	hl, 10
	.local	.LBB39_8
.LBB39_8:
	ld	de, (ix + 6)
	push	hl
	push	de
	call	_list_move
	ld	a, 1
	pop	hl
	pop	hl
	.local	.LBB39_9
.LBB39_9:
	pop	ix
	ret
	.local	.LBB39_10
.LBB39_10:
	xor	a, a
	jr	.LBB39_9
	.local	.Lfunc_end39
.Lfunc_end39:
	.size	_list_navigate, .Lfunc_end39-_list_navigate
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
	.local	.LBB40_1
.LBB40_1:                               ; %input_pressed.exit1
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB40_7 Depth 2
	bit	0, e
	jp	z, .LBB40_17
; %bb.2:                                ;   in Loop: Header=BB40_1 Depth=1
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
	jr	c, .LBB40_4
; %bb.3:                                ;   in Loop: Header=BB40_1 Depth=1
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	.local	.LBB40_4
.LBB40_4:                               ;   in Loop: Header=BB40_1 Depth=1
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
	jr	c, .LBB40_6
; %bb.5:                                ;   in Loop: Header=BB40_1 Depth=1
	ld.sis	iy, 10
	.local	.LBB40_6
.LBB40_6:                               ;   in Loop: Header=BB40_1 Depth=1
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
	.local	.LBB40_7
.LBB40_7:                               ;   Parent Loop BB40_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	ld	(ix - 62), de
	or	a, a
	sbc	hl, de
	jp	z, .LBB40_16
; %bb.8:                                ;   in Loop: Header=BB40_7 Depth=2
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
	jr	z, .LBB40_10
; %bb.9:                                ;   in Loop: Header=BB40_7 Depth=2
	ld	a, -8
	ld	l, a
	.local	.LBB40_10
.LBB40_10:                              ;   in Loop: Header=BB40_7 Depth=2
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	a, (ix - 48)
	ld	l, 1
	and	a, l
	ld	l, a
	bit	0, l
	jr	nz, .LBB40_12
; %bb.11:                               ;   in Loop: Header=BB40_7 Depth=2
	ld	iy, (ix - 62)
	lea	hl, iy + 0
	ld	de, 28
	add	hl, de
	ld	(ix - 71), hl
	jr	.LBB40_13
	.local	.LBB40_12
.LBB40_12:                              ;   in Loop: Header=BB40_7 Depth=2
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
	.local	.LBB40_13
.LBB40_13:                              ;   in Loop: Header=BB40_7 Depth=2
	ld	de, (ix - 39)
	ld	bc, 24
	add	iy, bc
	ld	hl, (ix - 56)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	hl, -1
	jr	z, .LBB40_15
; %bb.14:                               ;   in Loop: Header=BB40_7 Depth=2
	ld	hl, 0
	.local	.LBB40_15
.LBB40_15:                              ;   in Loop: Header=BB40_7 Depth=2
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
	jp	.LBB40_7
	.local	.LBB40_16
.LBB40_16:                              ;   in Loop: Header=BB40_1 Depth=1
	ld	hl, (ix - 59)
	push	hl
	call	_draw_scrollbar
	pop	hl
	ld	hl, _.str.8
	push	hl
	call	_ui_footer
	pop	hl
	call	_gfx_SwapDraw
	.local	.LBB40_17
.LBB40_17:                              ;   in Loop: Header=BB40_1 Depth=1
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
	jr	nz, .LBB40_19
; %bb.18:                               ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB40_1 Depth=1
	ld	bc, (ix - 13)
	jr	.LBB40_22
	.local	.LBB40_19
.LBB40_19:                              ; %input_pressed.exit
                                        ;   in Loop: Header=BB40_1 Depth=1
	ld	a, (_previous+6)
	and	a, h
	ld	c, a
	ld	hl, (ix - 13)
	bit	0, c
	jr	nz, .LBB40_21
; %bb.20:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB40_1 Depth=1
	push	hl
	pop	bc
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jr	nz, .LBB40_25
	jr	.LBB40_22
	.local	.LBB40_21
.LBB40_21:                              ;   in Loop: Header=BB40_1 Depth=1
	push	hl
	pop	bc
	.local	.LBB40_22
.LBB40_22:                              ;   in Loop: Header=BB40_1 Depth=1
	bit	6, d
	jp	z, .LBB40_1
; %bb.23:                               ;   in Loop: Header=BB40_1 Depth=1
	ld	a, (_previous+6)
	bit	6, a
	jp	nz, .LBB40_1
; %bb.24:
	ld	hl, 1
	jr	.LBB40_26
	.local	.LBB40_25
.LBB40_25:
	ld	hl, (ix - 11)
	ld	e, (ix - 84)
	ld	d, (ix - 83)
	add.sis	hl, de
	ld	iy, (ix + 9)
	ld	(iy), l
	ld	(iy + 1), h
	or	a, a
	sbc	hl, hl
	.local	.LBB40_26
.LBB40_26:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end40
.Lfunc_end40:
	.size	_ui_strip_menu, .Lfunc_end40-_ui_strip_menu
                                        ; -- End function
	.section	.text._ui_sync_screen,"ax",@progbits
	.globl	_ui_sync_screen                 ; -- Begin function ui_sync_screen
	.type	_ui_sync_screen,@function
_ui_sync_screen:                        ; @ui_sync_screen
; %bb.0:
	or	a, a
	sbc	hl, hl
	push	hl
	call	_ui_sync_run
	pop	hl
	ret
	.local	.Lfunc_end41
.Lfunc_end41:
	.size	_ui_sync_screen, .Lfunc_end41-_ui_sync_screen
                                        ; -- End function
	.section	.text._ui_sync_run,"ax",@progbits
	.globl	_ui_sync_run                    ; -- Begin function ui_sync_run
	.type	_ui_sync_run,@function
_ui_sync_run:                           ; @ui_sync_run
; %bb.0:
	ld	hl, -1
	call	__frameset
	ld	a, (ix + 6)
	ld	iyl, 0
	ld	de, _sync_state
	ld	bc, 12
	ld	l, 1
	and	a, l
	ld	iyh, a
	ld	(_sync_echo_mode), a
	ld	a, iyl
	ld	(_sync_chunks_received), a
	ld	hl, _.str.9
	ldir
	call	_input_reset
	call	_gfx_End
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	call	_sync_draw
	ld	a, (-720896)
	ld	l, 3
	or	a, l
	ld	l, a
	ld	(-720896), a
	ld	a, 1
	ld	(_continuous), a
	ld	l, (ix + 6)
	push	hl
	ld	hl, _sync_progress
	push	hl
	call	_proto_run
	ld	(ix - 1), a                     ; 1-byte Folded Spill
	pop	hl
	pop	hl
	xor	a, a
	ld	(_continuous), a
	ld	a, (-720896)
	ld	l, -4
	and	a, l
	ld	l, a
	ld	(-720896), a
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	call	_gfx_Begin
	ld	hl, 1
	push	hl
	call	_gfx_SetDraw
	pop	hl
	call	_ui_set_chrome_palette
	bit	0, (ix - 1)                     ; 1-byte Folded Reload
	jr	nz, .LBB42_2
; %bb.1:
	ld	hl, _.str.10
	ld	de, _.str.11
	push	de
	push	hl
	call	_ui_message
	pop	hl
	pop	hl
	.local	.LBB42_2
.LBB42_2:
	inc	sp
	pop	ix
	ret
	.local	.Lfunc_end42
.Lfunc_end42:
	.size	_ui_sync_run, .Lfunc_end42-_ui_sync_run
                                        ; -- End function
	.section	.text._sync_draw,"ax",@progbits
	.type	_sync_draw,@function            ; -- Begin function sync_draw
_sync_draw:                             ; @sync_draw
; %bb.0:
	ld	hl, -43
	call	__frameset
	lea	hl, ix - 40
	ld	(ix - 43), hl
	ld	a, (_sync_echo_mode)
	bit	0, a
	jr	nz, .LBB43_2
; %bb.1:
	ld	hl, _.str.13
	jr	.LBB43_3
	.local	.LBB43_2
.LBB43_2:
	ld	hl, _.str.12
	.local	.LBB43_3
.LBB43_3:
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_sync_line
	pop	hl
	pop	hl
	ld	hl, _sync_state
	push	hl
	ld	hl, 2
	push	hl
	call	_sync_line
	pop	hl
	pop	hl
	ld	a, (_sync_chunks_received)
	or	a, a
	sbc	hl, hl
	ld	l, a
	push	hl
	ld	hl, _.str.14
	push	hl
	ld	hl, (ix - 43)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 43)
	push	hl
	ld	hl, 3
	push	hl
	call	_sync_line
	pop	hl
	pop	hl
	ld	hl, _requests_handled
	ld	hl, (hl)
	ld	bc, 0
	push	bc
	pop	de
	ld	e, l
	ld	d, h
	ld	a, (_last_command)
	ld	c, a
	push	bc
	pop	iy
	ld	hl, _receive_errors
	ld	hl, (hl)
	ld	bc, 0
	ld	c, l
	ld	b, h
	push	bc
	push	iy
	push	de
	ld	hl, _.str.15
	push	hl
	ld	hl, (ix - 43)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 43)
	push	hl
	ld	hl, 5
	push	hl
	call	_sync_line
	pop	hl
	pop	hl
	ld	hl, (_open_error)
	ld	bc, 255
	call	__iand
	ld	de, (_loop_count)
	push	de
	push	hl
	ld	hl, _.str.16
	push	hl
	ld	hl, (ix - 43)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 43)
	push	hl
	ld	hl, 6
	push	hl
	call	_sync_line
	pop	hl
	pop	hl
	ld	hl, _.str.17.25
	push	hl
	ld	hl, 8
	push	hl
	call	_sync_line
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end43
.Lfunc_end43:
	.size	_sync_draw, .Lfunc_end43-_sync_draw
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
	jr	z, .LBB44_2
; %bb.1:
	ld	hl, 32
	ld	de, _.str.18
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
	.local	.LBB44_2
.LBB44_2:
	ld	hl, _.str.6.43
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_strcmp
	ex	de, hl
	pop	hl
	pop	hl
	ld	hl, (ix - 3)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB44_4
; %bb.3:
	ld	a, 0
	jr	.LBB44_5
	.local	.LBB44_4
.LBB44_4:
	ld	a, -1
	.local	.LBB44_5
.LBB44_5:
	ld	iy, _requests_handled
	ld	c, 1
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB44_7
; %bb.6:
	ld	hl, _sync_chunks_received
	inc	(hl)
	ld	a, c
	.local	.LBB44_7
.LBB44_7:
	ld	de, (iy)
	ld	iy, _sync_progress.drawn_requests
	ld	bc, (iy)
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	jr	z, .LBB44_9
; %bb.8:
	ld	(iy), e
	ld	(iy + 1), d
	ld	a, 1
	.local	.LBB44_9
.LBB44_9:
	ld	hl, (_loop_count)
	ld	bc, 2047
	call	__iand
	bit	0, a
	jr	nz, .LBB44_11
; %bb.10:
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB44_12
	.local	.LBB44_11
.LBB44_11:
	ld	hl, 3
	push	hl
	call	_proto_mark
	pop	hl
	call	_sync_draw
	.local	.LBB44_12
.LBB44_12:                              ; %input_pressed.exit
	call	_input_scan
	ld	a, (_current+6)
	ld	l, a
	ld	a, (_previous+6)
	bit	6, a
	ld	a, -1
	ld	c, 0
	ld	e, a
	jr	nz, .LBB44_14
; %bb.13:                               ; %input_pressed.exit
	ld	e, c
	.local	.LBB44_14
.LBB44_14:                              ; %input_pressed.exit
	bit	6, l
	jr	z, .LBB44_16
; %bb.15:                               ; %input_pressed.exit
	ld	a, c
	.local	.LBB44_16
.LBB44_16:                              ; %input_pressed.exit
	or	a, e
	ld	l, a
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end44
.Lfunc_end44:
	.size	_sync_progress, .Lfunc_end44-_sync_progress
                                        ; -- End function
	.section	.text._sync_line,"ax",@progbits
	.type	_sync_line,@function            ; -- Begin function sync_line
_sync_line:                             ; @sync_line
; %bb.0:
	ld	hl, -30
	call	__frameset
	ld	a, (ix + 6)
	ld	de, 0
	lea	iy, ix - 27
	ld	bc, 26
	ld	(ix - 30), iy
	.local	.LBB45_1
.LBB45_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB45_6
; %bb.2:                                ;   in Loop: Header=BB45_1 Depth=1
	ld	c, a
	ld	hl, (ix + 9)
	add	hl, de
	ld	l, (hl)
	ld	a, l
	or	a, a
	jr	z, .LBB45_4
; %bb.3:                                ;   in Loop: Header=BB45_1 Depth=1
	ld	iy, (ix - 30)
	add	iy, de
	ld	(iy), l
	ld	iy, (ix - 30)
	inc	de
	ld	a, c
	ld	bc, 26
	jr	.LBB45_1
	.local	.LBB45_4
.LBB45_4:
	ld	a, c
	ld	bc, 26
	jr	.LBB45_6
	.local	.LBB45_5
.LBB45_5:                               ;   in Loop: Header=BB45_6 Depth=1
	lea	hl, iy + 0
	add	hl, de
	inc	de
	ld	(hl), 32
	.local	.LBB45_6
.LBB45_6:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB45_5
; %bb.7:
	ld	(ix - 1), 0
	or	a, a
	sbc	hl, hl
	push	hl
	ld	l, a
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, (ix - 30)
	push	hl
	call	_os_PutStrFull
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end45
.Lfunc_end45:
	.size	_sync_line, .Lfunc_end45-_sync_line
                                        ; -- End function
	.section	.text._proto_requests,"ax",@progbits
	.globl	_proto_requests                 ; -- Begin function proto_requests
	.type	_proto_requests,@function
_proto_requests:                        ; @proto_requests
; %bb.0:
	ld	hl, _requests_handled
	ld	hl, (hl)
                                        ; kill: def $hl killed $hl killed $uhl
	ret
	.local	.Lfunc_end46
.Lfunc_end46:
	.size	_proto_requests, .Lfunc_end46-_proto_requests
                                        ; -- End function
	.section	.text._proto_last_command,"ax",@progbits
	.globl	_proto_last_command             ; -- Begin function proto_last_command
	.type	_proto_last_command,@function
_proto_last_command:                    ; @proto_last_command
; %bb.0:
	ld	a, (_last_command)
	ret
	.local	.Lfunc_end47
.Lfunc_end47:
	.size	_proto_last_command, .Lfunc_end47-_proto_last_command
                                        ; -- End function
	.section	.text._proto_errors,"ax",@progbits
	.globl	_proto_errors                   ; -- Begin function proto_errors
	.type	_proto_errors,@function
_proto_errors:                          ; @proto_errors
; %bb.0:
	ld	hl, _receive_errors
	ld	hl, (hl)
                                        ; kill: def $hl killed $hl killed $uhl
	ret
	.local	.Lfunc_end48
.Lfunc_end48:
	.size	_proto_errors, .Lfunc_end48-_proto_errors
                                        ; -- End function
	.section	.text._proto_schedule_error,"ax",@progbits
	.globl	_proto_schedule_error           ; -- Begin function proto_schedule_error
	.type	_proto_schedule_error,@function
_proto_schedule_error:                  ; @proto_schedule_error
; %bb.0:
	ld	a, (_open_error)
	ret
	.local	.Lfunc_end49
.Lfunc_end49:
	.size	_proto_schedule_error, .Lfunc_end49-_proto_schedule_error
                                        ; -- End function
	.section	.text._proto_loops,"ax",@progbits
	.globl	_proto_loops                    ; -- Begin function proto_loops
	.type	_proto_loops,@function
_proto_loops:                           ; @proto_loops
; %bb.0:
	ld	hl, (_loop_count)
	ret
	.local	.Lfunc_end50
.Lfunc_end50:
	.size	_proto_loops, .Lfunc_end50-_proto_loops
                                        ; -- End function
	.section	.text._proto_mark,"ax",@progbits
	.globl	_proto_mark                     ; -- Begin function proto_mark
	.type	_proto_mark,@function
_proto_mark:                            ; @proto_mark
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	a, (ix + 6)
	cp	a, 4
	jr	c, .LBB51_2
	.local	.LBB51_1
.LBB51_1:                               ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB51_2
.LBB51_2:
	ld	hl, _proto_mark.colours
	ld	de, -2882972
	ld	(ix - 3), de
	ld	bc, 0
	ld	iy, 0
	ld	iyl, a
	add	iy, iy
	lea	de, iy + 0
	add	hl, de
	ld	hl, (hl)
	ld	(ix - 6), hl
	ld	de, 12
	push	bc
	pop	iy
	.local	.LBB51_3
.LBB51_3:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB51_5 Depth 2
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jr	z, .LBB51_1
; %bb.4:                                ;   in Loop: Header=BB51_3 Depth=1
	ld	de, 24
	.local	.LBB51_5
.LBB51_5:                               ;   Parent Loop BB51_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB51_7
; %bb.6:                                ;   in Loop: Header=BB51_5 Depth=2
	ld	hl, (ix - 3)
	add	hl, bc
	lea	de, iy + 0
	ld	iy, (ix - 6)
	push	de
	ld	e, iyl
	ld	d, iyh
	ld	(hl), e
	inc	hl
	ld	(hl), d
	pop	de
	push	de
	pop	iy
	ld	de, 24
	push	bc
	pop	hl
	ld	bc, 2
	add	hl, bc
	push	hl
	pop	bc
	jr	.LBB51_5
	.local	.LBB51_7
.LBB51_7:                               ;   in Loop: Header=BB51_3 Depth=1
	inc	iy
	ld	hl, (ix - 3)
	ld	de, 640
	add	hl, de
	ld	(ix - 3), hl
	ld	bc, 0
	ld	de, 12
	jr	.LBB51_3
	.local	.Lfunc_end51
.Lfunc_end51:
	.size	_proto_mark, .Lfunc_end51-_proto_mark
                                        ; -- End function
	.section	.text._proto_run,"ax",@progbits
	.globl	_proto_run                      ; -- Begin function proto_run
	.type	_proto_run,@function
_proto_run:                             ; @proto_run
; %bb.0:
	ld	hl, -53
	call	__frameset
	ld	bc, (ix + 6)
	ld.sis	de, 0
	ld	hl, _requests_handled
	xor	a, a
	ld	iy, 0
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	(_last_command), a
	ld	hl, _receive_errors
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	(_open_error), iy
	ld	(_loop_count), iy
	ld	(_finished), a
	ld	(_serial_open), a
	ld	(_open_pending), a
	ld	(_header_filled), a
	ld	(_active_progress), bc
	call	_srl_GetCDCStandardDescriptors
	ld	de, 36106
	push	de
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, _handle_event
	push	hl
	call	_usb_Init
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	(ix - 25), de
	sbc	hl, hl
	adc	hl, de
	jp	nz, .LBB52_109
; %bb.1:
	lea	hl, ix - 17
	ld	(ix - 28), hl
	ld	de, 0
	.local	.LBB52_2
.LBB52_2:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB52_81 Depth 2
                                        ;     Child Loop BB52_56 Depth 2
                                        ;     Child Loop BB52_71 Depth 2
                                        ;     Child Loop BB52_39 Depth 2
	ld	a, (_finished)
	bit	0, a
	jp	nz, .LBB52_108
; %bb.3:                                ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, (_loop_count)
	inc	hl
	ld	(_loop_count), hl
	push	de
	call	_proto_mark
	pop	hl
	call	_usb_HandleEvents
	ld	a, (_open_pending)
	ld	e, a
	ld	a, (_serial_open)
	ld	l, a
	bit	0, e
	jr	z, .LBB52_10
; %bb.4:                                ;   in Loop: Header=BB52_2 Depth=1
	bit	0, l
	ld	de, 1
	jr	nz, .LBB52_10
; %bb.5:                                ;   in Loop: Header=BB52_2 Depth=1
	push	de
	call	_proto_mark
	pop	hl
	xor	a, a
	ld	(_open_pending), a
	ld	hl, 8
	push	hl
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
	jr	nz, .LBB52_7
; %bb.6:                                ; %._crit_edge
                                        ;   in Loop: Header=BB52_2 Depth=1
	ld	a, (_serial_open)
	ld	l, a
	jr	.LBB52_10
	.local	.LBB52_7
.LBB52_7:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, 115200
	push	hl
	ld	hl, 255
	push	hl
	ld	hl, 512
	push	hl
	ld	hl, _serial_buffer
	push	hl
	push	de
	ld	hl, _serial
	push	hl
	call	_srl_Open
	pop	de
	pop	de
	pop	de
	pop	de
	pop	de
	pop	de
	ld	(_open_error), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	l, 1
	jr	z, .LBB52_9
; %bb.8:                                ;   in Loop: Header=BB52_2 Depth=1
	ld	l, 0
	.local	.LBB52_9
.LBB52_9:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	a, l
	ld	(_serial_open), a
	.local	.LBB52_10
.LBB52_10:                              ;   in Loop: Header=BB52_2 Depth=1
	bit	0, (ix + 9)
	jr	z, .LBB52_14
; %bb.11:                               ;   in Loop: Header=BB52_2 Depth=1
	bit	0, l
	jp	z, .LBB52_21
; %bb.12:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, 512
	push	hl
	ld	hl, _stream
	push	hl
	ld	hl, _serial
	push	hl
	call	_srl_Read
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	push	de
	pop	hl
	ld	bc, 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB52_18
; %bb.13:                               ;   in Loop: Header=BB52_2 Depth=1
	xor	a, a
	ld	(_serial_open), a
	ld	iy, _receive_errors
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	jp	.LBB52_21
	.local	.LBB52_14
.LBB52_14:                              ;   in Loop: Header=BB52_2 Depth=1
	ld	a, (_header_filled)
	ld	e, a
	bit	0, l
	jp	z, .LBB52_25
; %bb.15:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	a, e
	cp	a, 8
	jp	nc, .LBB52_25
; %bb.16:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	bc, 0
	ld	c, e
	ld	iy, _request_header
	add	iy, bc
	ld	hl, 8
	or	a, a
	sbc	hl, bc
	push	hl
	push	iy
	ld	hl, _serial
	push	hl
	call	_srl_Read
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	push	de
	pop	hl
	ld	bc, 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB52_24
; %bb.17:                               ;   in Loop: Header=BB52_2 Depth=1
	xor	a, a
	ld	(_serial_open), a
	ld	iy, _receive_errors
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	a, (_header_filled)
	ld	e, a
	jr	.LBB52_25
	.local	.LBB52_18
.LBB52_18:                              ;   in Loop: Header=BB52_2 Depth=1
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB52_21
; %bb.19:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	iy, _requests_handled
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	a, (_stream)
	ld	(_last_command), a
	push	de
	ld	hl, _stream
	push	hl
	call	_write_exact
	pop	hl
	pop	hl
	bit	0, a
	jr	nz, .LBB52_21
; %bb.20:                               ;   in Loop: Header=BB52_2 Depth=1
	xor	a, a
	ld	(_serial_open), a
	.local	.LBB52_21
.LBB52_21:                              ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, 2
	push	hl
	call	_proto_mark
	pop	hl
	ld	hl, (ix + 6)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	de, 0
	jp	z, .LBB52_2
; %bb.22:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.40
	jp	nz, .LBB52_35
; %bb.23:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, _.str.1.41
	jp	.LBB52_35
	.local	.LBB52_24
.LBB52_24:                              ;   in Loop: Header=BB52_2 Depth=1
	ld	a, (_header_filled)
	ld	l, e
	add	a, l
	ld	e, a
	ld	(_header_filled), a
	.local	.LBB52_25
.LBB52_25:                              ;   in Loop: Header=BB52_2 Depth=1
	ld	a, e
	cp	a, 8
	jp	nz, .LBB52_32
; %bb.26:                               ;   in Loop: Header=BB52_2 Depth=1
	xor	a, a
	ld	(_header_filled), a
	ld	a, (_request_header)
	ld	e, a
	ld	(ix - 31), de
	ld	a, (_request_header+1)
	ld	l, a
	ld	(ix - 34), hl
	ld	a, (_request_header+2)
	ld	l, a
	ld	(ix - 37), hl
	ld	a, (_request_header+3)
	ld	l, a
	ld	(ix - 43), hl
	ld	iy, _requests_handled
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	a, e
	ld	(_last_command), a
	ld	a, (_request_header+4)
	ld	d, 0
	ld	e, d
	ld	(ix - 22), e
	ld	iy, (ix - 24)
	ld	iyh, e
	ld	iyl, a
	ld	hl, 0
	ld	d, l
	ld	a, (_request_header+5)
	ld	(ix - 21), e
	ld	bc, (ix - 23)
	ld	b, e
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
	jr	c, .LBB52_36
; %bb.27:                               ;   in Loop: Header=BB52_2 Depth=1
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
	.local	.LBB52_28
.LBB52_28:                              ;   in Loop: Header=BB52_2 Depth=1
	push	hl
	call	_reply
	.local	.LBB52_29
.LBB52_29:                              ;   in Loop: Header=BB52_2 Depth=1
	pop	hl
	.local	.LBB52_30
.LBB52_30:                              ;   in Loop: Header=BB52_2 Depth=1
	pop	hl
	pop	hl
	bit	0, a
	jr	nz, .LBB52_32
	.local	.LBB52_31
.LBB52_31:                              ; %.loopexit
                                        ;   in Loop: Header=BB52_2 Depth=1
	xor	a, a
	ld	(_serial_open), a
	.local	.LBB52_32
.LBB52_32:                              ; %.loopexit14
                                        ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, 2
	push	hl
	call	_proto_mark
	pop	hl
	ld	hl, (ix + 6)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	de, 0
	jp	z, .LBB52_2
; %bb.33:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.2.46
	jr	nz, .LBB52_35
; %bb.34:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, _.str.3.47
	.local	.LBB52_35
.LBB52_35:                              ;   in Loop: Header=BB52_2 Depth=1
	push	de
	push	de
	push	de
	push	hl
	ld	hl, (ix + 6)
	call	__indcallhl
	ld	de, 0
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	jp	nz, .LBB52_2
	jp	.LBB52_108
	.local	.LBB52_36
.LBB52_36:                              ;   in Loop: Header=BB52_2 Depth=1
	ld	de, 0
	ld	e, a
	ld	hl, JTI52_0
	add	hl, de
	add	hl, de
	add	hl, de
	ld	hl, (hl)
	jp	(hl)
	.local	.LBB52_37
.LBB52_37:                              ;   in Loop: Header=BB52_2 Depth=1
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
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	jp	z, .LBB52_31
; %bb.38:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	de, (ix - 31)
	ld	a, e
	ld	(_stream), a
	ld	a, d
	ld	(_stream+1), a
	ld	hl, 2
	push	hl
	pop	iy
	ld.sis	hl, 0
	ld	c, l
	ld	b, h
	.local	.LBB52_39
.LBB52_39:                              ;   Parent Loop BB52_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	jp	z, .LBB52_67
; %bb.40:                               ;   in Loop: Header=BB52_39 Depth=2
	lea	hl, iy + 0
	ld	de, -499
	add	hl, de
	ld	de, -513
	or	a, a
	sbc	hl, de
	ld	(ix - 34), bc
	jr	nc, .LBB52_42
; %bb.41:                               ;   in Loop: Header=BB52_39 Depth=2
	push	iy
	ld	hl, _stream
	push	hl
	call	_write_exact
	ld	bc, (ix - 34)
	pop	hl
	pop	hl
	bit	0, a
	ld	hl, 0
	ex	de, hl
	ld	hl, (ix - 31)
	jp	z, .LBB52_31
	jr	.LBB52_43
	.local	.LBB52_42
.LBB52_42:                              ;   in Loop: Header=BB52_39 Depth=2
	lea	de, iy + 0
	ld	hl, (ix - 31)
	.local	.LBB52_43
.LBB52_43:                              ;   in Loop: Header=BB52_39 Depth=2
	ld	(ix - 37), de
	pea	ix - 17
	push	bc
	call	_lib_get_strip
	pop	hl
	pop	hl
	ld	iy, _stream
	ld	de, (ix - 37)
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
	ld	bc, (ix - 34)
	ld	a, l
	ld	(iy + 12), a
	ld	a, (ix - 4)
	ld	(iy + 13), a
	ld	iy, (ix - 37)
	ld	de, 14
	add	iy, de
	inc.sis	bc
	ld	de, (ix - 31)
	jp	.LBB52_39
	.local	.LBB52_44
.LBB52_44:                              ;   in Loop: Header=BB52_2 Depth=1
	push	bc
	push	iy
	call	_drain
	pop	hl
	pop	hl
	ld	hl, _.str.8.45
	push	hl
	ld	hl, _.str.7.44
	push	hl
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jp	nz, .LBB52_55
; %bb.45:                               ;   in Loop: Header=BB52_2 Depth=1
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
	pop	hl
	pop	hl
	jp	.LBB52_29
	.local	.LBB52_46
.LBB52_46:                              ;   in Loop: Header=BB52_2 Depth=1
	lea	hl, iy + 0
	ld	e, c
	ld	(ix - 31), bc
	ld	bc, -16385
	ld	a, c
	call	__ladd
	inc	bc
	call	__lcmpu
	jp	nc, .LBB52_61
; %bb.47:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, (ix - 31)
	push	hl
	push	iy
	call	_drain
	pop	hl
	pop	hl
	ld	hl, 2
	jp	.LBB52_63
	.local	.LBB52_48
.LBB52_48:                              ;   in Loop: Header=BB52_2 Depth=1
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
	jp	z, .LBB52_50
; %bb.49:                               ;   in Loop: Header=BB52_2 Depth=1
	ld.sis	hl, 0
                                        ; kill: def $hl killed $hl def $uhl
	.local	.LBB52_50
.LBB52_50:                              ;   in Loop: Header=BB52_2 Depth=1
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
	jp	z, .LBB52_31
; %bb.51:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, 1
	push	hl
	pea	ix - 17
	jp	.LBB52_69
	.local	.LBB52_52
.LBB52_52:                              ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, 65535
	ld	e, 0
	ld	(ix - 31), bc
	lea	bc, iy + 0
	ld	(ix - 40), iy
	ld	iy, (ix - 31)
	ld	a, iyl
	call	__lcmpu
	jp	nc, .LBB52_65
; %bb.53:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, (ix - 31)
	push	hl
	ld	hl, (ix - 40)
	push	hl
	call	_drain
	pop	hl
	pop	hl
	ld	hl, 2
	jp	.LBB52_104
	.local	.LBB52_54
.LBB52_54:                              ;   in Loop: Header=BB52_2 Depth=1
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
	jp	.LBB52_28
	.local	.LBB52_55
.LBB52_55:                              ;   in Loop: Header=BB52_2 Depth=1
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
	ld	c, (ix - 31)
	ld	b, (ix - 30)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB52_56
.LBB52_56:                              ;   Parent Loop BB52_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	bit	0, a
	jp	z, .LBB52_31
; %bb.57:                               ; %.preheader13
                                        ;   in Loop: Header=BB52_56 Depth=2
	sbc.sis	hl, hl
	adc.sis	hl, bc
	jp	z, .LBB52_32
; %bb.58:                               ;   in Loop: Header=BB52_56 Depth=2
	ld	l, c
	ld	h, b
	ld.sis	de, 512
	or	a, a
	sbc.sis	hl, de
	ld	(ix - 31), c
	ld	(ix - 30), b
	jr	c, .LBB52_60
; %bb.59:                               ;   in Loop: Header=BB52_56 Depth=2
	ld.sis	bc, 512
	.local	.LBB52_60
.LBB52_60:                              ;   in Loop: Header=BB52_56 Depth=2
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
	ld	c, l
	ld	b, h
	jr	.LBB52_56
	.local	.LBB52_61
.LBB52_61:                              ;   in Loop: Header=BB52_2 Depth=1
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
	ld	hl, _.str.5.42
	push	hl
	ld	hl, (ix - 28)
	push	hl
	call	_ti_Open
	ld	c, a
	pop	hl
	pop	hl
	or	a, a
	jr	nz, .LBB52_70
; %bb.62:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, (ix - 31)
	push	hl
	ld	hl, (ix - 40)
	push	hl
	call	_drain
	pop	hl
	pop	hl
	ld	hl, 4
	.local	.LBB52_63
.LBB52_63:                              ;   in Loop: Header=BB52_2 Depth=1
	push	hl
	ld	hl, (ix - 34)
	push	hl
	.local	.LBB52_64
.LBB52_64:                              ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, 3
	jp	.LBB52_28
	.local	.LBB52_65
.LBB52_65:                              ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, _.str.7.44
	push	hl
	call	_ti_Delete
	pop	hl
	ld	hl, _.str.5.42
	push	hl
	ld	hl, _.str.7.44
	push	hl
	call	_ti_Open
	ld	c, a
	pop	hl
	pop	hl
	or	a, a
	jp	nz, .LBB52_80
; %bb.66:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, (ix - 31)
	push	hl
	ld	hl, (ix - 40)
	push	hl
	call	_drain
	pop	hl
	pop	hl
	ld	hl, 4
	jp	.LBB52_104
	.local	.LBB52_67
.LBB52_67:                              ;   in Loop: Header=BB52_2 Depth=1
	lea	de, iy + 0
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB52_32
; %bb.68:                               ;   in Loop: Header=BB52_2 Depth=1
	push	de
	ld	hl, _stream
	push	hl
	.local	.LBB52_69
.LBB52_69:                              ;   in Loop: Header=BB52_2 Depth=1
	call	_write_exact
	jp	.LBB52_30
	.local	.LBB52_70
.LBB52_70:                              ;   in Loop: Header=BB52_2 Depth=1
	ld	a, 1
	ld	(ix - 46), a                    ; 1-byte Folded Spill
	ld	iy, (ix - 40)
	ld	de, (ix - 31)
	ld	(ix - 49), bc
	.local	.LBB52_71
.LBB52_71:                              ; %.preheader
                                        ;   Parent Loop BB52_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	call	__lcmpzero
	jp	z, .LBB52_90
; %bb.72:                               ;   in Loop: Header=BB52_71 Depth=2
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
	jr	nz, .LBB52_74
; %bb.73:                               ;   in Loop: Header=BB52_71 Depth=2
	ld	hl, 512
	ex	de, hl
	.local	.LBB52_74
.LBB52_74:                              ;   in Loop: Header=BB52_71 Depth=2
	ld	(ix - 40), iy
	bit	0, a
	ld	hl, (ix - 31)
	ld	a, l
	jr	nz, .LBB52_76
; %bb.75:                               ;   in Loop: Header=BB52_71 Depth=2
	xor	a, a
	.local	.LBB52_76
.LBB52_76:                              ;   in Loop: Header=BB52_71 Depth=2
	ld	(ix - 53), a
	push	de
	ld	(ix - 52), de
	call	_read_exact
	pop	hl
	bit	0, a
	jp	z, .LBB52_105
; %bb.77:                               ;   in Loop: Header=BB52_71 Depth=2
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
	jr	z, .LBB52_79
; %bb.78:                               ;   in Loop: Header=BB52_71 Depth=2
	ld	a, 0
	.local	.LBB52_79
.LBB52_79:                              ;   in Loop: Header=BB52_71 Depth=2
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
	jp	.LBB52_71
	.local	.LBB52_80
.LBB52_80:                              ;   in Loop: Header=BB52_2 Depth=1
	ld	a, 1
	ld	(ix - 43), a                    ; 1-byte Folded Spill
	ld	iy, (ix - 40)
	ld	de, (ix - 31)
	ld	(ix - 37), bc
	.local	.LBB52_81
.LBB52_81:                              ; %.preheader16
                                        ;   Parent Loop BB52_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	call	__lcmpzero
	jp	z, .LBB52_99
; %bb.82:                               ;   in Loop: Header=BB52_81 Depth=2
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
	jr	nz, .LBB52_84
; %bb.83:                               ;   in Loop: Header=BB52_81 Depth=2
	ld	hl, 512
	ex	de, hl
	.local	.LBB52_84
.LBB52_84:                              ;   in Loop: Header=BB52_81 Depth=2
	ld	(ix - 40), iy
	bit	0, a
	ld	hl, (ix - 31)
	ld	a, l
	jr	nz, .LBB52_86
; %bb.85:                               ;   in Loop: Header=BB52_81 Depth=2
	xor	a, a
	.local	.LBB52_86
.LBB52_86:                              ;   in Loop: Header=BB52_81 Depth=2
	ld	(ix - 49), a
	push	de
	ld	(ix - 46), de
	call	_read_exact
	pop	hl
	bit	0, a
	jp	z, .LBB52_106
; %bb.87:                               ;   in Loop: Header=BB52_81 Depth=2
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
	jr	z, .LBB52_89
; %bb.88:                               ;   in Loop: Header=BB52_81 Depth=2
	ld	a, 0
	.local	.LBB52_89
.LBB52_89:                              ;   in Loop: Header=BB52_81 Depth=2
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
	jp	.LBB52_81
	.local	.LBB52_90
.LBB52_90:                              ;   in Loop: Header=BB52_2 Depth=1
	bit	0, (ix - 46)                    ; 1-byte Folded Reload
	ld	a, 0
	jr	z, .LBB52_94
; %bb.91:                               ;   in Loop: Header=BB52_2 Depth=1
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
	jr	nz, .LBB52_93
; %bb.92:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	a, 0
	.local	.LBB52_93
.LBB52_93:                              ;   in Loop: Header=BB52_2 Depth=1
	ld	bc, (ix - 49)
	.local	.LBB52_94
.LBB52_94:                              ;   in Loop: Header=BB52_2 Depth=1
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
	jr	z, .LBB52_96
; %bb.95:                               ;   in Loop: Header=BB52_2 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, (ix - 43)
	push	hl
	ld	hl, (ix - 37)
	push	hl
	ld	hl, _.str.6.43
	push	hl
	ld	hl, (ix + 6)
	call	__indcallhl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB52_96
.LBB52_96:                              ;   in Loop: Header=BB52_2 Depth=1
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
	jr	nz, .LBB52_98
; %bb.97:                               ;   in Loop: Header=BB52_2 Depth=1
	ld	e, l
	ld	d, h
	.local	.LBB52_98
.LBB52_98:                              ;   in Loop: Header=BB52_2 Depth=1
	push	de
	push	bc
	jp	.LBB52_64
	.local	.LBB52_99
.LBB52_99:                              ;   in Loop: Header=BB52_2 Depth=1
	bit	0, (ix - 43)                    ; 1-byte Folded Reload
	ld	hl, 4
	jp	z, .LBB52_103
; %bb.100:                              ;   in Loop: Header=BB52_2 Depth=1
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
	jp	z, .LBB52_102
; %bb.101:                              ;   in Loop: Header=BB52_2 Depth=1
	ld.sis	hl, 0
                                        ; kill: def $hl killed $hl def $uhl
	.local	.LBB52_102
.LBB52_102:                             ;   in Loop: Header=BB52_2 Depth=1
	add	hl, hl
	add	hl, hl
                                        ; kill: def $hl killed $hl def $uhl
	ld	bc, (ix - 37)
	.local	.LBB52_103
.LBB52_103:                             ;   in Loop: Header=BB52_2 Depth=1
	ld	(ix - 31), hl
	push	bc
	call	_ti_Close
	pop	hl
	call	_lib_open
	ld	hl, (ix - 31)
	.local	.LBB52_104
.LBB52_104:                             ;   in Loop: Header=BB52_2 Depth=1
	push	hl
	ld	hl, (ix - 34)
	push	hl
	ld	hl, 6
	jp	.LBB52_28
	.local	.LBB52_105
.LBB52_105:                             ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, (ix - 49)
	push	hl
	call	_ti_Close
	pop	hl
	ld	hl, (ix - 28)
	jr	.LBB52_107
	.local	.LBB52_106
.LBB52_106:                             ;   in Loop: Header=BB52_2 Depth=1
	ld	hl, (ix - 37)
	push	hl
	call	_ti_Close
	pop	hl
	ld	hl, _.str.7.44
	.local	.LBB52_107
.LBB52_107:                             ; %.loopexit
                                        ;   in Loop: Header=BB52_2 Depth=1
	push	hl
	call	_ti_Delete
	pop	hl
	jp	.LBB52_31
	.local	.LBB52_108
.LBB52_108:
	or	a, a
	sbc	hl, hl
	ld	(_active_progress), hl
	.local	.LBB52_109
.LBB52_109:
	call	_usb_Cleanup
	ld	hl, (ix - 25)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, -1
	jr	z, .LBB52_111
; %bb.110:
	ld	a, 0
	.local	.LBB52_111
.LBB52_111:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB52_112
.LBB52_112:
	push	bc
	push	iy
	call	_drain
	pop	hl
	pop	hl
	call	_archive_free
	.local	.Lfunc_end52
.Lfunc_end52:
	.size	_proto_run, .Lfunc_end52-_proto_run
	.section	.rodata._proto_run,"a",@progbits
JTI52_0:
	d24	.LBB52_112
	d24	.LBB52_37
	d24	.LBB52_46
	d24	.LBB52_48
	d24	.LBB52_44
	d24	.LBB52_52
	d24	.LBB52_112
	d24	.LBB52_54
                                        ; -- End function
	.section	.text._handle_event,"ax",@progbits
	.type	_handle_event,@function         ; -- Begin function handle_event
_handle_event:                          ; @handle_event
; %bb.0:
	call	__frameset0
	ld	bc, (ix + 6)
	ld	hl, (ix + 9)
	ld	de, (ix + 12)
	push	de
	push	hl
	push	bc
	call	_srl_UsbEventCallback
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB53_5
; %bb.1:
	ld	bc, 1
	ld	iy, (ix + 6)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jr	z, .LBB53_4
; %bb.2:
	ld	bc, 3
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jr	z, .LBB53_4
; %bb.3:
	ld	bc, 8
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB53_6
	.local	.LBB53_4
.LBB53_4:
	xor	a, a
	ld	(_serial_open), a
	ld	(_header_filled), a
	.local	.LBB53_5
.LBB53_5:
	ex	de, hl
	pop	ix
	ret
	.local	.LBB53_6
.LBB53_6:
	ld	bc, 12
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB53_5
; %bb.7:
	ld	a, 1
	ld	(_open_pending), a
	jr	.LBB53_5
	.local	.Lfunc_end53
.Lfunc_end53:
	.size	_handle_event, .Lfunc_end53-_handle_event
                                        ; -- End function
	.section	.text._write_exact,"ax",@progbits
	.type	_write_exact,@function          ; -- Begin function write_exact
_write_exact:                           ; @write_exact
; %bb.0:
	ld	hl, -9
	call	__frameset
	ld	hl, (ix + 6)
	ld	(ix - 3), hl
	ld	de, (ix + 9)
	.local	.LBB54_1
.LBB54_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	bc
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB54_7
; %bb.2:                                ;   in Loop: Header=BB54_1 Depth=1
	ld	(ix - 6), bc
	call	_usb_HandleEvents
	ld	bc, (ix - 6)
	ld	a, (_serial_open)
	bit	0, a
	jr	z, .LBB54_7
; %bb.3:                                ;   in Loop: Header=BB54_1 Depth=1
	push	bc
	ld	hl, (ix - 3)
	push	hl
	ld	hl, _serial
	push	hl
	call	_srl_Write
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	push	de
	pop	hl
	ld	bc, 0
	or	a, a
	sbc	hl, bc
	ld	bc, (ix - 6)
	call	pe, __setflag
	jp	m, .LBB54_7
; %bb.4:                                ;   in Loop: Header=BB54_1 Depth=1
	ld	hl, (ix - 3)
	add	hl, de
	ld	(ix - 3), hl
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	ex	de, hl
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB54_1
; %bb.5:                                ;   in Loop: Header=BB54_1 Depth=1
	ld	hl, (_active_progress)
	push	hl
	pop	bc
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB54_1
; %bb.6:                                ;   in Loop: Header=BB54_1 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	push	hl
	ld	hl, _.str.4.48
	push	hl
	ld	(ix - 9), de
	push	bc
	pop	hl
	call	__indcallhl
	ld	de, (ix - 9)
	ld	bc, (ix - 6)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	jp	nz, .LBB54_1
	.local	.LBB54_7
.LBB54_7:
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB54_9
; %bb.8:
	ld	a, 0
	jr	.LBB54_10
	.local	.LBB54_9
.LBB54_9:
	ld	a, -1
	.local	.LBB54_10
.LBB54_10:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end54
.Lfunc_end54:
	.size	_write_exact, .Lfunc_end54-_write_exact
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
	.local	.LBB55_1
.LBB55_1:                               ; =>This Inner Loop Header: Depth=1
	call	__lcmpzero
	jp	z, .LBB55_7
; %bb.2:                                ;   in Loop: Header=BB55_1 Depth=1
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
	jr	nz, .LBB55_4
; %bb.3:                                ;   in Loop: Header=BB55_1 Depth=1
	push	bc
	pop	iy
	.local	.LBB55_4
.LBB55_4:                               ;   in Loop: Header=BB55_1 Depth=1
	ld	(ix - 4), hl
	bit	0, a
	ld	a, (ix - 1)                     ; 1-byte Folded Reload
	jr	nz, .LBB55_6
; %bb.5:                                ;   in Loop: Header=BB55_1 Depth=1
	ld	a, d
	.local	.LBB55_6
.LBB55_6:                               ;   in Loop: Header=BB55_1 Depth=1
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
	jp	nz, .LBB55_1
	.local	.LBB55_7
.LBB55_7:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end55
.Lfunc_end55:
	.size	_drain, .Lfunc_end55-_drain
                                        ; -- End function
	.section	.text._archive_free,"ax",@progbits
	.type	_archive_free,@function         ; -- Begin function archive_free
_archive_free:                          ; @archive_free
; %bb.0:
	.local	.LBB56_1
.LBB56_1:                               ; =>This Inner Loop Header: Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	call	_ti_ArchiveHasRoom
	pop	hl
	jr	.LBB56_1
	.local	.Lfunc_end56
.Lfunc_end56:
	.size	_archive_free, .Lfunc_end56-_archive_free
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
	.local	.Lfunc_end57
.Lfunc_end57:
	.size	_send_header, .Lfunc_end57-_send_header
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
	.local	.Lfunc_end58
.Lfunc_end58:
	.size	_reply, .Lfunc_end58-_reply
                                        ; -- End function
	.section	.text._read_exact,"ax",@progbits
	.type	_read_exact,@function           ; -- Begin function read_exact
_read_exact:                            ; @read_exact
; %bb.0:
	ld	hl, -9
	call	__frameset
	ld	de, (ix + 6)
	ld	hl, _stream
	ld	(ix - 3), hl
	.local	.LBB59_1
.LBB59_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	bc
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB59_7
; %bb.2:                                ;   in Loop: Header=BB59_1 Depth=1
	ld	(ix - 6), bc
	call	_usb_HandleEvents
	ld	bc, (ix - 6)
	ld	a, (_serial_open)
	bit	0, a
	jr	z, .LBB59_7
; %bb.3:                                ;   in Loop: Header=BB59_1 Depth=1
	push	bc
	ld	hl, (ix - 3)
	push	hl
	ld	hl, _serial
	push	hl
	call	_srl_Read
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	push	de
	pop	hl
	ld	bc, 0
	or	a, a
	sbc	hl, bc
	ld	bc, (ix - 6)
	call	pe, __setflag
	jp	m, .LBB59_7
; %bb.4:                                ;   in Loop: Header=BB59_1 Depth=1
	ld	hl, (ix - 3)
	add	hl, de
	ld	(ix - 3), hl
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	ex	de, hl
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB59_1
; %bb.5:                                ;   in Loop: Header=BB59_1 Depth=1
	ld	hl, (_active_progress)
	push	hl
	pop	bc
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB59_1
; %bb.6:                                ;   in Loop: Header=BB59_1 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	push	hl
	ld	hl, _.str.4.48
	push	hl
	ld	(ix - 9), de
	push	bc
	pop	hl
	call	__indcallhl
	ld	de, (ix - 9)
	ld	bc, (ix - 6)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	jp	nz, .LBB59_1
	.local	.LBB59_7
.LBB59_7:
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB59_9
; %bb.8:
	ld	a, 0
	jr	.LBB59_10
	.local	.LBB59_9
.LBB59_9:
	ld	a, -1
	.local	.LBB59_10
.LBB59_10:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end59
.Lfunc_end59:
	.size	_read_exact, .Lfunc_end59-_read_exact
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
	jp	z, .LBB60_70
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
	jr	c, .LBB60_3
; %bb.2:
	ld	(iy + 5), 0
	.local	.LBB60_3
.LBB60_3:
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
	.local	.LBB60_4
.LBB60_4:                               ; %input_pressed.exit7
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
	jp	z, .LBB60_16
; %bb.5:                                ;   in Loop: Header=BB60_4 Depth=1
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
	jp	z, .LBB60_15
; %bb.6:                                ;   in Loop: Header=BB60_4 Depth=1
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
	jr	c, .LBB60_10
; %bb.7:                                ;   in Loop: Header=BB60_4 Depth=1
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
	jr	nc, .LBB60_9
; %bb.8:                                ;   in Loop: Header=BB60_4 Depth=1
	ld	hl, 10
	push	hl
	pop	bc
	.local	.LBB60_9
.LBB60_9:                               ;   in Loop: Header=BB60_4 Depth=1
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
	.local	.LBB60_10
.LBB60_10:                              ;   in Loop: Header=BB60_4 Depth=1
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
	jr	c, .LBB60_12
; %bb.11:                               ;   in Loop: Header=BB60_4 Depth=1
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
	.local	.LBB60_12
.LBB60_12:                              ;   in Loop: Header=BB60_4 Depth=1
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
	ld	hl, _.str.3.53
	jr	nz, .LBB60_14
; %bb.13:                               ;   in Loop: Header=BB60_4 Depth=1
	ld	hl, _.str.4.54
	.local	.LBB60_14
.LBB60_14:                              ;   in Loop: Header=BB60_4 Depth=1
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
	ld	hl, _.str.2.55
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
	.local	.LBB60_15
.LBB60_15:                              ;   in Loop: Header=BB60_4 Depth=1
	call	_gfx_SwapDraw
	.local	.LBB60_16
.LBB60_16:                              ;   in Loop: Header=BB60_4 Depth=1
	call	_input_scan
	ld	de, (_repeat_frames)
	push	de
	pop	hl
	ld	bc, 10
	or	a, a
	sbc	hl, bc
	ld	bc, 14
	jr	nc, .LBB60_18
; %bb.17:                               ;   in Loop: Header=BB60_4 Depth=1
	ld	bc, 6
	.local	.LBB60_18
.LBB60_18:                              ;   in Loop: Header=BB60_4 Depth=1
	ex	de, hl
	ld	de, 24
	or	a, a
	sbc	hl, de
	ld	hl, 26
	jr	nc, .LBB60_20
; %bb.19:                               ;   in Loop: Header=BB60_4 Depth=1
	push	bc
	pop	hl
	.local	.LBB60_20
.LBB60_20:                              ;   in Loop: Header=BB60_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	hl, 1793
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB60_22
; %bb.21:                               ;   in Loop: Header=BB60_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	jr	.LBB60_24
	.local	.LBB60_22
.LBB60_22:                              ;   in Loop: Header=BB60_4 Depth=1
	ld	hl, 1800
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jp	z, .LBB60_37
; %bb.23:                               ;   in Loop: Header=BB60_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	call	__ineg
	.local	.LBB60_24
.LBB60_24:                              ;   in Loop: Header=BB60_4 Depth=1
	push	hl
	or	a, a
	sbc	hl, hl
	.local	.LBB60_25
.LBB60_25:                              ;   in Loop: Header=BB60_4 Depth=1
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
	.local	.LBB60_26
.LBB60_26:                              ;   in Loop: Header=BB60_4 Depth=1
	ld	a, (_current+6)
	ld	h, a
	bit	1, h
	jr	z, .LBB60_29
; %bb.27:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB60_4 Depth=1
	ld	a, (_previous+6)
	bit	1, a
	jr	nz, .LBB60_29
; %bb.28:                               ;   in Loop: Header=BB60_4 Depth=1
	push	ix
	ld	de, -344
	add	ix, de
	ld	iy, (ix + 0)
	pop	ix
	ld	e, (iy + 5)
	ld	d, e
	inc	d
	jp	.LBB60_43
	.local	.LBB60_29
.LBB60_29:                              ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB60_4 Depth=1
	bit	2, h
	jr	z, .LBB60_33
; %bb.30:                               ; %input_pressed.exit4
                                        ;   in Loop: Header=BB60_4 Depth=1
	ld	a, (_previous+6)
	bit	2, a
	jr	nz, .LBB60_33
; %bb.31:                               ;   in Loop: Header=BB60_4 Depth=1
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
	jp	z, .LBB60_50
; %bb.32:                               ;   in Loop: Header=BB60_4 Depth=1
	ld	d, e
	jp	.LBB60_42
	.local	.LBB60_33
.LBB60_33:                              ; %input_pressed.exit4.thread
                                        ;   in Loop: Header=BB60_4 Depth=1
	ld	a, (_current+1)
	bit	6, a
	jp	z, .LBB60_50
; %bb.34:                               ; %input_pressed.exit5
                                        ;   in Loop: Header=BB60_4 Depth=1
	ld	a, (_previous+1)
	bit	6, a
	jp	nz, .LBB60_50
; %bb.35:                               ;   in Loop: Header=BB60_4 Depth=1
	push	ix
	ld	de, -344
	add	ix, de
	ld	iy, (ix + 0)
	pop	ix
	ld	e, (iy + 5)
	ld	a, e
	or	a, a
	jr	z, .LBB60_41
; %bb.36:                               ;   in Loop: Header=BB60_4 Depth=1
	ld	d, 0
	jr	.LBB60_43
	.local	.LBB60_37
.LBB60_37:                              ;   in Loop: Header=BB60_4 Depth=1
	ld	hl, 1796
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB60_39
; %bb.38:                               ;   in Loop: Header=BB60_4 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	jp	.LBB60_25
	.local	.LBB60_39
.LBB60_39:                              ;   in Loop: Header=BB60_4 Depth=1
	ld	hl, 1794
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	ld	a, 0
	ld	c, a
	jp	z, .LBB60_26
; %bb.40:                               ;   in Loop: Header=BB60_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	call	__ineg
	ld	de, 0
	push	de
	jp	.LBB60_25
	.local	.LBB60_41
.LBB60_41:                              ;   in Loop: Header=BB60_4 Depth=1
	push	ix
	ld	bc, -344
	add	ix, bc
	ld	iy, (ix + 0)
	pop	ix
	ld	d, (iy + 14)
	.local	.LBB60_42
.LBB60_42:                              ;   in Loop: Header=BB60_4 Depth=1
	dec	d
	.local	.LBB60_43
.LBB60_43:                              ;   in Loop: Header=BB60_4 Depth=1
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
	jp	nc, .LBB60_50
; %bb.44:                               ;   in Loop: Header=BB60_4 Depth=1
	ld	a, e
	cp	a, d
	ld	a, 1
	ld	c, a
	jp	z, .LBB60_50
; %bb.45:                               ;   in Loop: Header=BB60_4 Depth=1
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
	jr	nz, .LBB60_47
; %bb.46:                               ;   in Loop: Header=BB60_4 Depth=1
	or	a, a
	sbc	hl, hl
	.local	.LBB60_47
.LBB60_47:                              ;   in Loop: Header=BB60_4 Depth=1
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
	jr	nz, .LBB60_49
; %bb.48:                               ;   in Loop: Header=BB60_4 Depth=1
	or	a, a
	sbc	hl, hl
	.local	.LBB60_49
.LBB60_49:                              ;   in Loop: Header=BB60_4 Depth=1
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
	.local	.LBB60_50
.LBB60_50:                              ; %set_layer.exit
                                        ;   in Loop: Header=BB60_4 Depth=1
	ld	a, (_current+1)
	ld	l, a
	ld	a, (_previous+1)
	cp	a, 0
	call	pe, __setflag
	ld	e, -1
	jp	p, .LBB60_52
; %bb.51:                               ; %set_layer.exit
                                        ;   in Loop: Header=BB60_4 Depth=1
	ld	e, 0
	.local	.LBB60_52
.LBB60_52:                              ; %set_layer.exit
                                        ;   in Loop: Header=BB60_4 Depth=1
	ld	a, l
	cp	a, 0
	call	pe, __setflag
	ld	a, -1
	jp	m, .LBB60_54
; %bb.53:                               ; %set_layer.exit
                                        ;   in Loop: Header=BB60_4 Depth=1
	ld	a, 0
	.local	.LBB60_54
.LBB60_54:                              ; %set_layer.exit
                                        ;   in Loop: Header=BB60_4 Depth=1
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
	jp	nz, .LBB60_58
; %bb.55:                               ;   in Loop: Header=BB60_4 Depth=1
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
	jr	c, .LBB60_57
; %bb.56:                               ;   in Loop: Header=BB60_4 Depth=1
	ld	a, 1
	ld	de, -345
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	.local	.LBB60_57
.LBB60_57:                              ;   in Loop: Header=BB60_4 Depth=1
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
	.local	.LBB60_58
.LBB60_58:                              ;   in Loop: Header=BB60_4 Depth=1
	bit	0, c
	ld	l, 1
	ld	bc, 60
	jr	nz, .LBB60_64
; %bb.59:                               ;   in Loop: Header=BB60_4 Depth=1
	bit	0, d
	jr	nz, .LBB60_64
; %bb.60:                               ;   in Loop: Header=BB60_4 Depth=1
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
	jr	z, .LBB60_64
; %bb.61:                               ;   in Loop: Header=BB60_4 Depth=1
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
	jr	z, .LBB60_63
; %bb.62:                               ;   in Loop: Header=BB60_4 Depth=1
	ld	l, 0
	.local	.LBB60_63
.LBB60_63:                              ;   in Loop: Header=BB60_4 Depth=1
	ld	h, a
	.local	.LBB60_64
.LBB60_64:                              ;   in Loop: Header=BB60_4 Depth=1
	bit	6, h
	jp	z, .LBB60_4
; %bb.65:                               ;   in Loop: Header=BB60_4 Depth=1
	ld	a, (_previous+6)
	bit	6, a
	jp	nz, .LBB60_4
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
	jr	z, .LBB60_71
; %bb.67:
	ld	l, 1
	ld	de, -378
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)
	and	a, l
	ld	l, a
	bit	0, l
	jr	nz, .LBB60_69
; %bb.68:
	or	a, a
	sbc	hl, hl
	push	hl
	call	_time
	pop	bc
	ld	(ix - 41), hl
	ld	(ix - 38), e
	.local	.LBB60_69
.LBB60_69:
	ld	l, 1
	ld	de, -378
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)
	or	a, l
	jr	.LBB60_72
	.local	.LBB60_70
.LBB60_70:
	ld	hl, _.str.51
	ld	de, _.str.1.52
	push	de
	push	hl
	call	_ui_message
	pop	hl
	pop	hl
	jr	.LBB60_73
	.local	.LBB60_71
.LBB60_71:
	ld	de, -378
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)
	ld	l, d
	and	a, l
	.local	.LBB60_72
.LBB60_72:
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
	.local	.LBB60_73
.LBB60_73:
	ld	de, -359
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end60
.Lfunc_end60:
	.size	_viewer_run, .Lfunc_end60-_viewer_run
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
	jr	c, .LBB61_2
; %bb.1:
	push	hl
	pop	bc
	.local	.LBB61_2
.LBB61_2:
	ld	(ix - 3), bc
	ld	bc, 204
	add	iy, bc
	ld	hl, (iy)
	or	a, a
	ld	bc, 240
	sbc	hl, bc
	jr	c, .LBB61_4
; %bb.3:
	ex	de, hl
	.local	.LBB61_4
.LBB61_4:
	ld	(ix - 6), de
	ld	iy, (ix + 6)
	ld	bc, (iy + 4)
	ld	de, (ix - 3)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB61_6
; %bb.5:
	ld	(iy + 4), de
	.local	.LBB61_6
.LBB61_6:
	ld	bc, (iy + 7)
	ld	de, (ix - 6)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB61_8
; %bb.7:
	ld	(iy + 7), de
	.local	.LBB61_8
.LBB61_8:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end61
.Lfunc_end61:
	.size	_clamp, .Lfunc_end61-_clamp
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
	jr	c, .LBB62_2
; %bb.1:
	ex	de, hl
	.local	.LBB62_2
.LBB62_2:
	ld	(ix - 9), de
	ld	de, (ix + 9)
	ld	bc, 204
	add	iy, bc
	ld	hl, (iy)
	or	a, a
	ld	bc, 240
	sbc	hl, bc
	ld	bc, 0
	jr	c, .LBB62_4
; %bb.3:
	push	hl
	pop	bc
	.local	.LBB62_4
.LBB62_4:
	ld	(ix - 6), bc
	ld	bc, 0
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB62_7
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
	jr	c, .LBB62_10
; %bb.6:
	lea	hl, iy + 0
	jr	.LBB62_10
	.local	.LBB62_7
.LBB62_7:
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB62_11
; %bb.8:
	ld	iy, (ix + 6)
	ld	iy, (iy + 4)
	add	iy, de
	lea	hl, iy + 0
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	lea	hl, iy + 0
	jr	c, .LBB62_10
; %bb.9:
	ex	de, hl
	.local	.LBB62_10
.LBB62_10:
	ld	iy, (ix + 6)
	ld	(iy + 4), hl
	.local	.LBB62_11
.LBB62_11:
	ld	bc, (ix + 12)
	push	bc
	pop	hl
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB62_15
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
	jr	c, .LBB62_14
; %bb.13:
	ld	(ix - 3), iy
	.local	.LBB62_14
.LBB62_14:
	ld	iy, (ix + 6)
	ld	hl, (ix - 3)
	jr	.LBB62_19
	.local	.LBB62_15
.LBB62_15:
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB62_20
; %bb.16:
	ld	iy, (ix + 6)
	ld	iy, (iy + 7)
	add	iy, bc
	lea	hl, iy + 0
	ld	de, (ix - 6)
	or	a, a
	sbc	hl, de
	lea	hl, iy + 0
	jr	c, .LBB62_18
; %bb.17:
	ex	de, hl
	.local	.LBB62_18
.LBB62_18:
	ld	iy, (ix + 6)
	.local	.LBB62_19
.LBB62_19:
	ld	(iy + 7), hl
	.local	.LBB62_20
.LBB62_20:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end62
.Lfunc_end62:
	.size	_pan, .Lfunc_end62-_pan
                                        ; -- End function
	.section	.rodata._.str,"a",@progbits
	.balign	1
	.local	_.str
_.str:
	.asciz	"CSX1"

	.section	.bss._continuous,"aw",@nobits
	.balign	1
	.local	_continuous
_continuous:
	.zero	1

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
	.asciz	"enter open  2nd sync  alpha echo  clear quit"

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

	.section	.bss._sync_echo_mode,"aw",@nobits
	.balign	1
	.local	_sync_echo_mode
_sync_echo_mode:
	.zero	1

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
	.asciz	"eBookSync - ECHO TEST"

	.section	.rodata._.str.13,"a",@progbits
	.balign	1
	.local	_.str.13
_.str.13:
	.asciz	"eBookSync"

	.section	.rodata._.str.14,"a",@progbits
	.balign	1
	.local	_.str.14
_.str.14:
	.asciz	"%u chunks received"

	.section	.rodata._.str.15,"a",@progbits
	.balign	1
	.local	_.str.15
_.str.15:
	.asciz	"req %u cmd %u err %u"

	.section	.rodata._.str.16,"a",@progbits
	.balign	1
	.local	_.str.16
_.str.16:
	.asciz	"sch %u loops %u"

	.section	.rodata._.str.17.25,"a",@progbits
	.balign	1
	.local	_.str.17.25
_.str.17.25:
	.asciz	"[clear] stop syncing"

	.section	.rodata._.str.18,"a",@progbits
	.balign	1
	.local	_.str.18
_.str.18:
	.asciz	"%s"

	.section	.bss._sync_progress.drawn_requests,"aw",@nobits
	.balign	2
	.local	_sync_progress.drawn_requests
_sync_progress.drawn_requests:
	.zero	2

	.section	.bss._requests_handled,"aw",@nobits
	.balign	2
	.local	_requests_handled
_requests_handled:
	.zero	2

	.section	.bss._last_command,"aw",@nobits
	.balign	1
	.local	_last_command
_last_command:
	.zero	1

	.section	.bss._receive_errors,"aw",@nobits
	.balign	2
	.local	_receive_errors
_receive_errors:
	.zero	2

	.section	.bss._open_error,"aw",@nobits
	.balign	1
	.local	_open_error
_open_error:
	.zero	3

	.section	.bss._loop_count,"aw",@nobits
	.balign	1
	.local	_loop_count
_loop_count:
	.zero	3

	.section	.rodata._proto_mark.colours,"a",@progbits
	.balign	2
	.local	_proto_mark.colours
_proto_mark.colours:
	dw	63488                           ; 0xf800
	dw	65504                           ; 0xffe0
	dw	2016                            ; 0x7e0
	dw	31                              ; 0x1f

	.section	.bss._finished,"aw",@nobits
	.balign	1
	.local	_finished
_finished:
	.zero	1

	.section	.bss._serial_open,"aw",@nobits
	.balign	1
	.local	_serial_open
_serial_open:
	.zero	1

	.section	.bss._open_pending,"aw",@nobits
	.balign	1
	.local	_open_pending
_open_pending:
	.zero	1

	.section	.bss._header_filled,"aw",@nobits
	.balign	1
	.local	_header_filled
_header_filled:
	.zero	1

	.section	.bss._active_progress,"aw",@nobits
	.balign	1
	.local	_active_progress
_active_progress:
	.zero	3

	.section	.bss._serial,"aw",@nobits
	.balign	1
	.local	_serial
_serial:
	.zero	58

	.section	.bss._serial_buffer,"aw",@nobits
	.balign	1
	.local	_serial_buffer
_serial_buffer:
	.zero	512

	.section	.bss._stream,"aw",@nobits
	.balign	1
	.local	_stream
_stream:
	.zero	512

	.section	.rodata._.str.40,"a",@progbits
	.balign	1
	.local	_.str.40
_.str.40:
	.asciz	"Echo: connected"

	.section	.rodata._.str.1.41,"a",@progbits
	.balign	1
	.local	_.str.1.41
_.str.1.41:
	.asciz	"Echo: waiting"

	.section	.bss._request_header,"aw",@nobits
	.balign	1
	.local	_request_header
_request_header:
	.zero	8

	.section	.rodata._.str.2.46,"a",@progbits
	.balign	1
	.local	_.str.2.46
_.str.2.46:
	.asciz	"Connected"

	.section	.rodata._.str.3.47,"a",@progbits
	.balign	1
	.local	_.str.3.47
_.str.3.47:
	.asciz	"Waiting for computer"

	.section	.rodata._.str.4.48,"a",@progbits
	.balign	1
	.local	_.str.4.48
_.str.4.48:
	.asciz	"Syncing"

	.section	.rodata._.str.5.42,"a",@progbits
	.balign	1
	.local	_.str.5.42
_.str.5.42:
	.asciz	"w"

	.section	.rodata._.str.6.43,"a",@progbits
	.balign	1
	.local	_.str.6.43
_.str.6.43:
	.asciz	"Receiving"

	.section	.rodata._.str.7.44,"a",@progbits
	.balign	1
	.local	_.str.7.44
_.str.7.44:
	.asciz	"CSLIB"

	.section	.rodata._.str.8.45,"a",@progbits
	.balign	1
	.local	_.str.8.45
_.str.8.45:
	.asciz	"r"

	.section	.rodata._.str.51,"a",@progbits
	.balign	1
	.local	_.str.51
_.str.51:
	.asciz	"Cannot open this strip."

	.section	.rodata._.str.1.52,"a",@progbits
	.balign	1
	.local	_.str.1.52
_.str.1.52:
	.asciz	"Re-sync it from the computer."

	.section	.rodata._.str.2.55,"a",@progbits
	.balign	1
	.local	_.str.2.55
_.str.2.55:
	.asciz	"%u.%ux %u%%%s"

	.section	.rodata._.str.3.53,"a",@progbits
	.balign	1
	.local	_.str.3.53
_.str.3.53:
	.asciz	" read"

	.section	.rodata._.str.4.54,"a",@progbits
	.balign	1
	.local	_.str.4.54
_.str.4.54:
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
	.extern	__ldivu
	.extern	_llvm.lifetime.end.p0
	.extern	_srl_Write
	.extern	__ishru
	.extern	__Unwind_SjLj_Unregister
	.extern	__sor
	.extern	_llvm.usub.sat.i16
	.extern	_kb_Scan
	.extern	_usb_Init
	.extern	_llvm.umax.i8
	.extern	__ineg
	.extern	__lsub
	.extern	__lcmpzero
	.extern	_malloc
	.extern	_os_PutStrFull
	.extern	_ti_Open
	.extern	_snprintf
	.extern	_zx0_Decompress
	.extern	_srl_GetCDCStandardDescriptors
	.extern	_ti_Seek
	.extern	__ladd
	.extern	_llvm.umin.i24
	.extern	__idivu
	.extern	_usb_Cleanup
	.extern	_usb_HandleEvents
	.extern	__indcallhl
	.extern	_ti_SetArchiveStatus
	.extern	_llvm.eh.sjlj.lsda
	.extern	_free
	.extern	_ti_Delete
	.extern	_usb_FindDevice
	.extern	__iand
	.extern	_llvm.umax.i16
	.extern	__setflag
	.extern	_os_ClrLCD
	.extern	_llvm.stacksave.p0
	.extern	_ti_Close
	.extern	_llvm.lifetime.start.p0
	.extern	_memcmp
	.extern	_llvm.umin.i16
	.extern	__lshru
	.extern	_srl_Read
	.extern	_os_HomeUp
	.extern	__sdivs
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_llvm.usub.sat.i24
	.extern	_ti_GetSize
	.extern	__iremu
	.extern	_os_SetCursorPos
	.extern	_memcpy
	.extern	_llvm.umin.i32
	.extern	__sdivu
	.extern	_llvm.umax.i24
	.extern	_gfx_FillScreen
	.extern	_gfx_FillRectangle_NoClip
	.extern	__bshru
	.extern	_gfx_PrintStringXY
	.extern	_ti_ArchiveHasRoom
	.extern	_llvm.memset.p0.i24
	.extern	_gfx_SetColor
	.extern	_llvm.memcpy.p0.p0.i24
	.extern	_gfx_End
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_time
	.extern	_srl_Open
	.extern	_llvm.frameaddress.p0
	.extern	_os_DrawStatusBar
	.extern	__lshl
	.extern	__sand
	.extern	_llvm.stackrestore.p0
	.extern	_sprintf
	.extern	__lcmpu
	.extern	_gfx_SetTextFGColor
	.extern	_gfx_Begin
	.extern	_strcmp
	.extern	_llvm.smax.i24
	.extern	__ishru_1
	.extern	_gfx_SetTextBGColor
	.extern	_gfx_SwapDraw
	.extern	_strlen
	.extern	__frameset
	.extern	_srl_UsbEventCallback
	.extern	__imulu
	.extern	_llvm.eh.sjlj.callsite
	.extern	_ti_GetDataPtr
	.extern	_ti_Write
	.extern	__lmulu
	.extern	__frameset0
	.extern	__Unwind_SjLj_Register
	.extern	__sshl
	.extern	__smulu
	.extern	_gfx_SetDraw
	.extern	__ishl
