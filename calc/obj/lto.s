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
	ld	hl, _.str.2.47
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
	xor	a, a
	jr	.LBB11_9
	.local	.LBB11_4
.LBB11_4:
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB11_8
; %bb.5:
	ld	de, (_repeat_frames)
	push	de
	pop	hl
	inc	hl
	ld	(_repeat_frames), hl
	ld	bc, 18
	or	a, a
	sbc	hl, bc
	ld	a, b
	jr	c, .LBB11_9
; %bb.6:
	ld	l, 3
	ld	a, e
	add	a, l
	ld	e, a
	ld	a, e
	and	a, l
	ld	l, a
	or	a, a
	jr	z, .LBB11_10
; %bb.7:
	ld	a, 0
	jr	.LBB11_9
	.local	.LBB11_8
.LBB11_8:
	ld	a, 1
	ld	(iy), e
	ld	(iy + 1), d
	or	a, a
	sbc	hl, hl
	ld	(_repeat_frames), hl
	.local	.LBB11_9
.LBB11_9:
	pop	ix
	ret
	.local	.LBB11_10
.LBB11_10:
	ld	a, -1
	jr	.LBB11_9
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
	ld	de, _.str.1.46
	ld	bc, 0
	ld	(_index_data), bc
	ld	(hl), c
	inc	hl
	ld	(hl), b
	ld	(iy), c
	ld	(iy + 1), b
	ld	hl, _.str.2.47
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
	ld	hl, _.str.1.46
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
	cp	a, 2
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
	.section	.text._lib_id,"ax",@progbits
	.globl	_lib_id                         ; -- Begin function lib_id
	.type	_lib_id,@function
_lib_id:                                ; @lib_id
; %bb.0:
	ld	de, 0
	ld	bc, (_index_data)
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB15_2
; %bb.1:
	push	bc
	pop	iy
	lea	de, iy + 12
	.local	.LBB15_2
.LBB15_2:
	ex	de, hl
	ret
	.local	.Lfunc_end15
.Lfunc_end15:
	.size	_lib_id, .Lfunc_end15-_lib_id
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
	.local	.Lfunc_end16
.Lfunc_end16:
	.size	_lib_book_count, .Lfunc_end16-_lib_book_count
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
	.local	.Lfunc_end17
.Lfunc_end17:
	.size	_lib_strip_count, .Lfunc_end17-_lib_strip_count
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
	ld	e, (iy + 28)
	ld	d, b
	ld	a, (iy + 29)
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
	ld	e, (iy + 30)
	ld	a, (iy + 31)
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
	ld	e, (iy + 32)
	ld	a, (iy + 33)
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
	.local	.Lfunc_end18
.Lfunc_end18:
	.size	_lib_get_book, .Lfunc_end18-_lib_get_book
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
	ld	a, (iy + 28)
	ld	hl, (ix + 9)
	ld	(hl), a
	ld	a, (iy + 29)
	lea	hl, iy + 0
	ld	iy, (ix + 9)
	ld	(iy + 1), a
	push	hl
	pop	iy
	ld	(ix - 7), iy
	ld	e, (iy + 30)
	ld	a, (iy + 31)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	c, 8
	call	__ishl
	add	hl, de
	ld	(ix - 10), hl
	ld	iy, (ix - 7)
	ld	a, (iy + 32)
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
	ld	a, (iy + 33)
	lea	hl, iy + 0
	ld	iy, (ix + 9)
	ld	(iy + 5), a
	push	hl
	pop	iy
	ld	a, (iy + 34)
	ld	h, 0
	ld	(ix - 4), h
	ld	de, (ix - 6)
	ld	d, h
	ld	e, a
	ld	(ix - 10), de
	ld	de, 0
	ld	d, e
	ld	iy, (ix - 7)
	ld	a, (iy + 35)
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
	ld	a, (iy + 36)
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
	ld	a, (iy + 37)
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
	ld	a, (iy + 38)
	ld	hl, 0
	push	hl
	pop	de
	ld	e, a
	ld	(ix - 10), de
	ld	a, (iy + 39)
	ld	l, a
	push	hl
	pop	de
	ld	c, 8
	call	__ishl
	ld	bc, (ix - 10)
	add	hl, bc
	ld	(ix - 10), hl
	ld	iy, (ix - 7)
	ld	a, (iy + 40)
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
	ld	a, (iy + 41)
	lea	hl, iy + 0
	ld	iy, (ix + 9)
	ld	(iy + 13), a
	ld	d, 0
	push	hl
	pop	iy
	ld	e, (iy + 42)
	ld	a, (iy + 43)
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
	.local	.Lfunc_end19
.Lfunc_end19:
	.size	_lib_get_strip, .Lfunc_end19-_lib_get_strip
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
	.local	.LBB20_1
.LBB20_1:                               ; =>This Inner Loop Header: Depth=1
	ld	hl, (ix - 6)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	jr	z, .LBB20_3
; %bb.2:                                ;   in Loop: Header=BB20_1 Depth=1
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
	ld	a, (iy + 33)
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
	jp	.LBB20_1
	.local	.LBB20_3
.LBB20_3:
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end20
.Lfunc_end20:
	.size	_lib_book_read_count, .Lfunc_end20-_lib_book_read_count
                                        ; -- End function
	.section	.text._lib_save_strip,"ax",@progbits
	.globl	_lib_save_strip                 ; -- Begin function lib_save_strip
	.type	_lib_save_strip,@function
_lib_save_strip:                        ; @lib_save_strip
; %bb.0:
	ld	hl, -15
	call	__frameset
	ld	hl, _.str.1.46
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
	jp	z, .LBB21_8
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
	ld	de, 33
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
	jr	nz, .LBB21_3
; %bb.2:
	ld	hl, (ix - 15)
	push	hl
	call	_ti_Close
	pop	hl
	jp	.LBB21_8
	.local	.LBB21_3
.LBB21_3:
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
	jr	z, .LBB21_5
; %bb.4:
	ld	c, b
	.local	.LBB21_5
.LBB21_5:
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB21_7
; %bb.6:
	ld	a, b
	.local	.LBB21_7
.LBB21_7:
	and	a, c
	ld	l, a
	ld	(ix - 12), l
	ld	hl, (ix - 15)
	push	hl
	call	_ti_Close
	pop	hl
	call	_lib_open
	.local	.LBB21_8
.LBB21_8:
	ld	a, (ix - 12)                    ; 1-byte Folded Reload
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end21
.Lfunc_end21:
	.size	_lib_save_strip, .Lfunc_end21-_lib_save_strip
                                        ; -- End function
	.section	.text._lib_set_book_read,"ax",@progbits
	.globl	_lib_set_book_read              ; -- Begin function lib_set_book_read
	.type	_lib_set_book_read,@function
_lib_set_book_read:                     ; @lib_set_book_read
; %bb.0:
	ld	hl, -19
	call	__frameset
	ld	hl, _.str.1.46
	ld	de, _.str.2.4
	push	de
	push	hl
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jr	nz, .LBB22_2
; %bb.1:
	xor	a, a
	jp	.LBB22_18
	.local	.LBB22_2
.LBB22_2:
	ld	c, (ix + 9)
	bit	0, c
	ld	(ix - 8), de
	jr	z, .LBB22_4
; %bb.3:
	or	a, a
	sbc	hl, hl
	push	hl
	call	_time
	push	hl
	pop	iy
	ld	h, e
	pop	de
	ld	a, iyh
	ld	(ix - 12), a
	ld	l, 16
	lea	bc, iy + 0
	ld	a, h
	call	__lshru
	push	bc
	pop	de
	ld	l, 24
	lea	bc, iy + 0
	ld	a, h
	call	__lshru
	push	af
	ld	a, iyl
	ld	(ix - 13), a                    ; 1-byte Folded Spill
	pop	af
	ld	(ix - 14), e                    ; 1-byte Folded Spill
	ld	de, 0
	ld	(ix - 15), c                    ; 1-byte Folded Spill
	ld	c, (ix + 9)
	jr	.LBB22_5
	.local	.LBB22_4
.LBB22_4:
	xor	a, a
	ld	(ix - 12), a                    ; 1-byte Folded Spill
	ld	(ix - 14), a                    ; 1-byte Folded Spill
	ld	(ix - 13), a                    ; 1-byte Folded Spill
	ld	(ix - 15), a                    ; 1-byte Folded Spill
	ld	iy, 0
	lea	de, iy + 0
	.local	.LBB22_5
.LBB22_5:
	ld	iy, (ix + 6)
	ld	a, 1
	ld	(ix - 11), a
	ld	l, a
	ld	a, c
	and	a, l
	ld	l, a
	ld	(ix - 16), l
	push	de
	pop	bc
	.local	.LBB22_6
.LBB22_6:                               ; =>This Inner Loop Header: Depth=1
	ld	hl, (iy + 4)
	push	de
	pop	iy
	ld	e, l
	ld	d, h
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	push	bc
	pop	de
	jp	nc, .LBB22_13
; %bb.7:                                ;   in Loop: Header=BB22_6 Depth=1
	bit	0, (ix - 11)                    ; 1-byte Folded Reload
	ld	bc, (ix - 8)
	jp	z, .LBB22_14
; %bb.8:                                ;   in Loop: Header=BB22_6 Depth=1
	ld	hl, _book_count
	ld	hl, (hl)
	ld	(ix - 11), hl
	ld	hl, (ix - 11)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	lea	hl, iy + 0
	ld	bc, 6
	call	__imulu
	ld	bc, 0
	ld	(ix - 11), hl
	ex	de, hl
	ld	iy, (ix + 6)
	ld	iy, (iy + 2)
	push	bc
	pop	de
	ld	e, iyl
	ld	d, iyh
	ld	(ix - 19), hl
	add	hl, de
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	hl, (ix - 11)
	add	hl, de
	ld	de, 33
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 8)
	push	hl
	push	bc
	push	de
	call	_ti_Seek
	pop	de
	pop	de
	pop	de
	ld	de, -1
	or	a, a
	sbc	hl, de
	jr	z, .LBB22_12
; %bb.9:                                ;   in Loop: Header=BB22_6 Depth=1
	ld	a, (ix - 16)
	ld	(ix - 5), a
	ld	a, (ix - 13)
	ld	(ix - 4), a
	ld	a, (ix - 12)
	ld	(ix - 3), a
	ld	a, (ix - 14)
	ld	(ix - 2), a
	ld	a, (ix - 15)
	ld	(ix - 1), a
	ld	hl, (ix - 8)
	push	hl
	ld	hl, 1
	push	hl
	ld	hl, 5
	push	hl
	pea	ix - 5
	call	_ti_Write
	pop	de
	pop	de
	pop	de
	pop	de
	ld	de, 1
	or	a, a
	sbc	hl, de
	ld	a, -1
	ld	(ix - 11), a                    ; 1-byte Folded Spill
	ld	a, d
	jr	z, .LBB22_11
; %bb.10:                               ;   in Loop: Header=BB22_6 Depth=1
	ld	(ix - 11), a                    ; 1-byte Folded Spill
	.local	.LBB22_11
.LBB22_11:                              ;   in Loop: Header=BB22_6 Depth=1
	ld	bc, (ix - 19)
	inc	bc
	ld	iy, 0
	lea	de, iy + 0
	ld	iy, (ix + 6)
	jp	.LBB22_6
	.local	.LBB22_12
.LBB22_12:
	xor	a, a
	ld	(ix - 11), a                    ; 1-byte Folded Spill
	.local	.LBB22_13
.LBB22_13:
	ld	bc, (ix - 8)
	.local	.LBB22_14
.LBB22_14:
	push	bc
	ld	hl, 1
	push	hl
	call	_ti_SetArchiveStatus
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB22_16
; %bb.15:
	ld	a, 0
	jr	.LBB22_17
	.local	.LBB22_16
.LBB22_16:
	ld	a, -1
	.local	.LBB22_17
.LBB22_17:
	ld	l, (ix - 11)
	and	a, l
	ld	l, a
	ld	(ix - 11), l
	ld	hl, (ix - 8)
	push	hl
	call	_ti_Close
	pop	hl
	call	_lib_open
	ld	a, (ix - 11)                    ; 1-byte Folded Reload
	.local	.LBB22_18
.LBB22_18:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end22
.Lfunc_end22:
	.size	_lib_set_book_read, .Lfunc_end22-_lib_set_book_read
                                        ; -- End function
	.section	.text._lib_reset,"ax",@progbits
	.globl	_lib_reset                      ; -- Begin function lib_reset
	.type	_lib_reset,@function
_lib_reset:                             ; @lib_reset
; %bb.0:
	ld	hl, -22
	call	__frameset
	ld	hl, _strip_count
	ld.sis	de, 0
	ld	(ix - 19), e
	ld	(ix - 18), d
	ld	c, e
	ld	b, d
	.local	.LBB23_1
.LBB23_1:                               ; =>This Inner Loop Header: Depth=1
	ld	de, (hl)
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
	jr	nc, .LBB23_5
; %bb.2:                                ;   in Loop: Header=BB23_1 Depth=1
	pea	ix - 17
	ld	(ix - 22), bc
	push	bc
	call	_lib_get_strip
	pop	hl
	pop	hl
	ld	a, (ix - 17)
	ld	l, a
	push	hl
	call	_csx_delete
	pop	hl
	or	a, a
	ld.sis	de, 1
	jr	nz, .LBB23_4
; %bb.3:                                ;   in Loop: Header=BB23_1 Depth=1
	ld.sis	de, 0
	.local	.LBB23_4
.LBB23_4:                               ;   in Loop: Header=BB23_1 Depth=1
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	add.sis	hl, de
	ld	(ix - 19), l
	ld	(ix - 18), h
	ld	bc, (ix - 22)
	inc.sis	bc
	ld	hl, _strip_count
	jr	.LBB23_1
	.local	.LBB23_5
.LBB23_5:
	ld	hl, _.str.1.46
	push	hl
	call	_ti_Delete
	pop	hl
	or	a, a
	sbc	hl, hl
	ld	(_index_data), hl
	ex.sis	de, hl
	ld	hl, _book_count
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	hl, _strip_count
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end23
.Lfunc_end23:
	.size	_lib_reset, .Lfunc_end23-_lib_reset
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
	jp	z, .LBB24_4
; %bb.1:
	ld	hl, (_index_data)
	push	hl
	pop	iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB24_4
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
	jr	c, .LBB24_4
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
	.local	.LBB24_4
.LBB24_4:
	ex	de, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end24
.Lfunc_end24:
	.size	_lib_title, .Lfunc_end24-_lib_title
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
	ld	hl, _gc_after
	push	hl
	ld	hl, _gc_before
	push	hl
	call	_ti_SetGCBehavior
	pop	hl
	pop	hl
	call	_render_init
	or	a, a
	jr	nz, .LBB25_2
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
	jp	.LBB25_16
	.local	.LBB25_2
.LBB25_2:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB25_3 Depth 2
                                        ;       Child Loop BB25_4 Depth 3
                                        ;         Child Loop BB25_8 Depth 4
	call	_lib_open
	.local	.LBB25_3
.LBB25_3:                               ;   Parent Loop BB25_2 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB25_4 Depth 3
                                        ;         Child Loop BB25_8 Depth 4
	ld.sis	hl, 0
	ld	(ix - 3), l
	ld	(ix - 2), h
	.local	.LBB25_4
.LBB25_4:                               ;   Parent Loop BB25_2 Depth=1
                                        ;     Parent Loop BB25_3 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB25_8 Depth 4
	pea	ix - 3
	call	_ui_book_menu
	push	hl
	pop	bc
	pop	hl
	push	bc
	pop	hl
	ld	de, 1
	or	a, a
	sbc	hl, de
	jp	z, .LBB25_15
; %bb.5:                                ;   in Loop: Header=BB25_4 Depth=3
	push	bc
	pop	hl
	ld	de, 4
	or	a, a
	sbc	hl, de
	jr	z, .LBB25_13
; %bb.6:                                ;   in Loop: Header=BB25_4 Depth=3
	ld	l, 6
	ld	a, c
	and	a, l
	ld	l, a
	cp	a, 2
	jr	z, .LBB25_10
; %bb.7:                                ; %.preheader
                                        ;   in Loop: Header=BB25_4 Depth=3
	ld	hl, (ix - 3)
	ld	(ix - 8), hl
	.local	.LBB25_8
.LBB25_8:                               ;   Parent Loop BB25_2 Depth=1
                                        ;     Parent Loop BB25_3 Depth=2
                                        ;       Parent Loop BB25_4 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	pea	ix - 5
	push	hl
	call	_ui_strip_menu
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB25_4
; %bb.9:                                ;   in Loop: Header=BB25_8 Depth=4
	ld	hl, (ix - 5)
	push	hl
	call	_viewer_run
	pop	hl
	call	_ui_set_chrome_palette
	ld	hl, (ix - 8)
	jr	.LBB25_8
	.local	.LBB25_10
.LBB25_10:                              ;   in Loop: Header=BB25_3 Depth=2
	ld	(ix - 8), bc
	call	_render_free
	ld	hl, (ix - 8)
	ld	de, 3
	or	a, a
	sbc	hl, de
	ld	hl, -1
	jr	z, .LBB25_12
; %bb.11:                               ;   in Loop: Header=BB25_3 Depth=2
	ld	hl, 0
	.local	.LBB25_12
.LBB25_12:                              ;   in Loop: Header=BB25_3 Depth=2
	push	hl
	call	_ui_sync_run
	pop	hl
	call	_lib_open
	call	_render_init
	or	a, a
	jp	nz, .LBB25_3
	jr	.LBB25_14
	.local	.LBB25_13
.LBB25_13:                              ;   in Loop: Header=BB25_2 Depth=1
	call	_ui_setup_screen
	jp	.LBB25_2
	.local	.LBB25_14
.LBB25_14:
	ld	hl, _.str.1.6
	push	hl
	ld	hl, _.str.5
	push	hl
	call	_ui_message
	pop	hl
	pop	hl
	.local	.LBB25_15
.LBB25_15:                              ; %.loopexit
	call	_render_free
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_ti_SetGCBehavior
	pop	hl
	pop	hl
	call	_gfx_End
	or	a, a
	sbc	hl, hl
	.local	.LBB25_16
.LBB25_16:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end25
.Lfunc_end25:
	.size	_main, .Lfunc_end25-_main
                                        ; -- End function
	.section	.text._gc_before,"ax",@progbits
	.type	_gc_before,@function            ; -- Begin function gc_before
_gc_before:                             ; @gc_before
; %bb.0:
	jp	_gfx_End
	.local	.Lfunc_end26
.Lfunc_end26:
	.size	_gc_before, .Lfunc_end26-_gc_before
                                        ; -- End function
	.section	.text._gc_after,"ax",@progbits
	.type	_gc_after,@function             ; -- Begin function gc_after
_gc_after:                              ; @gc_after
; %bb.0:
	call	_gfx_Begin
	ld	hl, 1
	push	hl
	call	_gfx_SetDraw
	pop	hl
	call	_ui_set_chrome_palette
	jp	_lib_open
	.local	.Lfunc_end27
.Lfunc_end27:
	.size	_gc_after, .Lfunc_end27-_gc_after
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
	.local	.LBB28_1
.LBB28_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB28_3
; %bb.2:                                ;   in Loop: Header=BB28_1 Depth=1
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
	jp	.LBB28_1
	.local	.LBB28_3
.LBB28_3:
	xor	a, a
	ld	(_cache_slots), a
	.local	.LBB28_4
.LBB28_4:                               ; =>This Inner Loop Header: Depth=1
	ld	de, 36
	ld	hl, (ix - 6)
	or	a, a
	sbc	hl, de
	jr	z, .LBB28_7
; %bb.5:                                ;   in Loop: Header=BB28_4 Depth=1
	ld	(ix - 3), a                     ; 1-byte Folded Spill
	ld	hl, 5120
	push	hl
	call	_malloc
	ex	de, hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB28_10
; %bb.6:                                ;   in Loop: Header=BB28_4 Depth=1
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
	jr	.LBB28_4
	.local	.LBB28_7
.LBB28_7:
	ld	a, 12
	.local	.LBB28_8
.LBB28_8:                               ; %.thread
	ld	(ix - 3), a
	call	_render_reset
	ld	a, (ix - 3)                     ; 1-byte Folded Reload
	.local	.LBB28_9
.LBB28_9:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB28_10
.LBB28_10:
	ld	a, (ix - 3)                     ; 1-byte Folded Reload
	cp	a, 2
	jr	nc, .LBB28_8
; %bb.11:
	call	_render_free
	xor	a, a
	jr	.LBB28_9
	.local	.Lfunc_end28
.Lfunc_end28:
	.size	_render_init, .Lfunc_end28-_render_init
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
	.local	.LBB29_1
.LBB29_1:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB29_3
; %bb.2:                                ;   in Loop: Header=BB29_1 Depth=1
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
	jr	.LBB29_1
	.local	.LBB29_3
.LBB29_3:
	xor	a, a
	ld	(_cache_slots), a
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end29
.Lfunc_end29:
	.size	_render_free, .Lfunc_end29-_render_free
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
	.local	.LBB30_1
.LBB30_1:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB30_3
; %bb.2:                                ;   in Loop: Header=BB30_1 Depth=1
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
	jr	.LBB30_1
	.local	.LBB30_3
.LBB30_3:
	ld	hl, _cache_clock
	ld.sis	de, 0
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end30
.Lfunc_end30:
	.size	_render_reset, .Lfunc_end30-_render_reset
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
	.local	.LBB31_1
.LBB31_1:                               ; =>This Inner Loop Header: Depth=1
	ld	hl, (ix - 12)
	ld	(ix - 19), hl
	ld	bc, (ix - 9)
	dec	de
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB31_4
; %bb.2:                                ;   in Loop: Header=BB31_1 Depth=1
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
	jp	nz, .LBB31_1
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
	jp	.LBB31_14
	.local	.LBB31_4
.LBB31_4:
	push	af
	ld	a, iyl
	ld	(ix - 9), a                     ; 1-byte Folded Spill
	pop	af
	cp	a, 2
	jr	nc, .LBB31_6
; %bb.5:
	ld	a, 1
	.local	.LBB31_6
.LBB31_6:
	ld	iy, 0
	lea	de, iy + 0
	ld	e, a
	dec	de
	ld	bc, (ix + 9)
	.local	.LBB31_7
.LBB31_7:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB31_11
; %bb.8:                                ;   in Loop: Header=BB31_7 Depth=1
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
	jr	c, .LBB31_10
; %bb.9:                                ;   in Loop: Header=BB31_7 Depth=1
	ld	c, a
	.local	.LBB31_10
.LBB31_10:                              ;   in Loop: Header=BB31_7 Depth=1
	ld	iy, (ix - 6)
	lea	iy, iy + 2
	ld	(ix - 6), iy
	inc	l
	ld	(ix - 13), l
	dec	de
	ld	(ix - 9), c                     ; 1-byte Folded Spill
	ld	bc, (ix + 9)
	ld	iy, 0
	jp	.LBB31_7
	.local	.LBB31_11
.LBB31_11:
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
	jr	z, .LBB31_13
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
	.local	.LBB31_13
.LBB31_13:
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
	.local	.LBB31_14
.LBB31_14:
	push	bc
	pop	hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end31
.Lfunc_end31:
	.size	_render_band, .Lfunc_end31-_render_band
                                        ; -- End function
	.section	.text._render_set_palette,"ax",@progbits
	.globl	_render_set_palette             ; -- Begin function render_set_palette
	.type	_render_set_palette,@function
_render_set_palette:                    ; @render_set_palette
; %bb.0:
	call	__frameset0
	ld	de, 0
	ld	bc, 32
	.local	.LBB32_1
.LBB32_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB32_3
; %bb.2:                                ;   in Loop: Header=BB32_1 Depth=1
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
	jr	.LBB32_1
	.local	.LBB32_3
.LBB32_3:
	pop	ix
	ret
	.local	.Lfunc_end32
.Lfunc_end32:
	.size	_render_set_palette, .Lfunc_end32-_render_set_palette
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
	jr	nz, .LBB33_2
; %bb.1:
	ld.sis	hl, 0
	jp	.LBB33_3
	.local	.LBB33_2
.LBB33_2:
                                        ; kill: def $l killed $l def $hl
	ld	h, e
	.local	.LBB33_3
.LBB33_3:
	ld	(ix - 15), l
	ld	(ix - 14), h
	or	a, a
	sbc	hl, hl
	bit	0, a
	jr	nz, .LBB33_5
; %bb.4:
	ld	hl, (ix + 12)
	.local	.LBB33_5
.LBB33_5:
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
	jp	c, .LBB33_7
; %bb.6:
	dec.sis	de
                                        ; kill: def $de killed $de killed $ude def $ude
	ld	(ix - 12), de
	.local	.LBB33_7
.LBB33_7:
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
	jp	c, .LBB33_9
; %bb.8:
	dec.sis	de
                                        ; kill: def $de killed $de killed $ude def $ude
	ld	(ix - 15), de
	.local	.LBB33_9
.LBB33_9:
	ld	hl, (ix - 21)
	ld	de, (ix - 3)
	or	a, a
	sbc	hl, de
	ld	(ix - 21), hl
	ld	de, (ix - 6)
	.local	.LBB33_10
.LBB33_10:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB33_22 Depth 2
                                        ;       Child Loop BB33_34 Depth 3
                                        ;         Child Loop BB33_39 Depth 4
	ld	hl, (ix - 12)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, de
	jp	c, .LBB33_43
; %bb.11:                               ;   in Loop: Header=BB33_10 Depth=1
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
	jr	c, .LBB33_13
; %bb.12:                               ;   in Loop: Header=BB33_10 Depth=1
	ld	iy, 320
	.local	.LBB33_13
.LBB33_13:                              ;   in Loop: Header=BB33_10 Depth=1
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
	jr	c, .LBB33_15
; %bb.14:                               ;   in Loop: Header=BB33_10 Depth=1
	push	hl
	pop	bc
	.local	.LBB33_15
.LBB33_15:                              ;   in Loop: Header=BB33_10 Depth=1
	ld	iy, (ix - 21)
	add	iy, de
	lea	hl, iy + 0
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB33_17
; %bb.16:                               ;   in Loop: Header=BB33_10 Depth=1
	ld	iy, 0
	.local	.LBB33_17
.LBB33_17:                              ;   in Loop: Header=BB33_10 Depth=1
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
	jp	m, .LBB33_19
; %bb.18:                               ;   in Loop: Header=BB33_10 Depth=1
	ld	e, iyl
	ld	d, iyh
	.local	.LBB33_19
.LBB33_19:                              ;   in Loop: Header=BB33_10 Depth=1
	ld	(ix - 27), de
	sbc.sis	hl, hl
	adc.sis	hl, de
	ld	de, (ix - 6)
	jr	nz, .LBB33_21
	.local	.LBB33_20
.LBB33_20:                              ; %.loopexit6
                                        ;   in Loop: Header=BB33_10 Depth=1
	inc.sis	de
	jp	.LBB33_10
	.local	.LBB33_21
.LBB33_21:                              ;   in Loop: Header=BB33_10 Depth=1
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
	.local	.LBB33_22
.LBB33_22:                              ;   Parent Loop BB33_10 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB33_34 Depth 3
                                        ;         Child Loop BB33_39 Depth 4
	ld	hl, (ix - 15)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	jp	c, .LBB33_20
; %bb.23:                               ;   in Loop: Header=BB33_22 Depth=2
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
	jr	nz, .LBB33_25
	.local	.LBB33_24
.LBB33_24:                              ; %.loopexit
                                        ;   in Loop: Header=BB33_22 Depth=2
	ld	c, (ix - 24)
	ld	b, (ix - 23)
	inc.sis	bc
	ld	de, (ix - 6)
	jp	.LBB33_22
	.local	.LBB33_25
.LBB33_25:                              ;   in Loop: Header=BB33_22 Depth=2
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
	jr	c, .LBB33_27
; %bb.26:                               ;   in Loop: Header=BB33_22 Depth=2
	ld	iy, 32
	.local	.LBB33_27
.LBB33_27:                              ;   in Loop: Header=BB33_22 Depth=2
	ld	(ix - 42), iy
	or	a, a
	ld	hl, (ix + 15)
	sbc	hl, bc
	ld	iy, 0
	jr	c, .LBB33_29
; %bb.28:                               ;   in Loop: Header=BB33_22 Depth=2
	push	hl
	pop	iy
	.local	.LBB33_29
.LBB33_29:                              ;   in Loop: Header=BB33_22 Depth=2
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
	jp	p, .LBB33_31
; %bb.30:                               ;   in Loop: Header=BB33_22 Depth=2
	ld	de, 0
	.local	.LBB33_31
.LBB33_31:                              ;   in Loop: Header=BB33_22 Depth=2
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
	jp	m, .LBB33_33
; %bb.32:                               ;   in Loop: Header=BB33_22 Depth=2
	ld	e, iyl
	.local	.LBB33_33
.LBB33_33:                              ;   in Loop: Header=BB33_22 Depth=2
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
	.local	.LBB33_34
.LBB33_34:                              ;   Parent Loop BB33_10 Depth=1
                                        ;     Parent Loop BB33_22 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB33_39 Depth 4
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB33_24
; %bb.35:                               ;   in Loop: Header=BB33_34 Depth=3
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
	jp	nz, .LBB33_37
; %bb.36:                               ;   in Loop: Header=BB33_34 Depth=3
	ld	(ix - 45), iy
	ld	hl, (ix - 27)
                                        ; kill: def $hl killed $hl killed $uhl
	jr	.LBB33_39
	.local	.LBB33_37
.LBB33_37:                              ;   in Loop: Header=BB33_34 Depth=3
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
	jr	.LBB33_39
	.local	.LBB33_38
.LBB33_38:                              ;   in Loop: Header=BB33_39 Depth=4
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
	.local	.LBB33_39
.LBB33_39:                              ;   Parent Loop BB33_10 Depth=1
                                        ;     Parent Loop BB33_22 Depth=2
                                        ;       Parent Loop BB33_34 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	ld	e, l
	ld	d, h
	ld.sis	bc, 2
	or	a, a
	sbc.sis	hl, bc
	jr	nc, .LBB33_38
; %bb.40:                               ;   in Loop: Header=BB33_34 Depth=3
	sbc.sis	hl, hl
	adc.sis	hl, de
	jr	z, .LBB33_42
; %bb.41:                               ;   in Loop: Header=BB33_34 Depth=3
	ld	hl, (ix - 45)
	ld	a, (hl)
	ld	b, 4
	call	__bshru
	ld	hl, (ix - 42)
	ld	(hl), a
	.local	.LBB33_42
.LBB33_42:                              ;   in Loop: Header=BB33_34 Depth=3
	ld	de, (ix - 65)
	inc	de
	ld	bc, (ix - 62)
	jp	.LBB33_34
	.local	.LBB33_43
.LBB33_43:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end33
.Lfunc_end33:
	.size	_render_view, .Lfunc_end33-_render_view
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
	.local	.Lfunc_end34
.Lfunc_end34:
	.size	_ui_set_chrome_palette, .Lfunc_end34-_ui_set_chrome_palette
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
	.local	.LBB35_1
.LBB35_1:                               ; =>This Inner Loop Header: Depth=1
	lea	hl, iy + 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB35_3
; %bb.2:                                ;   in Loop: Header=BB35_1 Depth=1
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
	jp	.LBB35_1
	.local	.LBB35_3
.LBB35_3:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end35
.Lfunc_end35:
	.size	_set_ramp, .Lfunc_end35-_set_ramp
                                        ; -- End function
	.section	.text._ui_present,"ax",@progbits
	.globl	_ui_present                     ; -- Begin function ui_present
	.type	_ui_present,@function
_ui_present:                            ; @ui_present
; %bb.0:
	call	__frameset0
	call	_gfx_SwapDraw
	call	_gfx_Wait
	bit	0, (ix + 6)
	jr	z, .LBB36_2
; %bb.1:
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_Blit
	pop	hl
	.local	.LBB36_2
.LBB36_2:
	pop	ix
	ret
	.local	.Lfunc_end36
.Lfunc_end36:
	.size	_ui_present, .Lfunc_end36-_ui_present
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
	.local	.Lfunc_end37
.Lfunc_end37:
	.size	_ui_header, .Lfunc_end37-_ui_header
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
	.local	.Lfunc_end38
.Lfunc_end38:
	.size	_ui_footer, .Lfunc_end38-_ui_footer
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
	jr	nz, .LBB39_2
	.local	.LBB39_1
.LBB39_1:                               ; %.loopexit5
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB39_2
.LBB39_2:
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
	jp	p, .LBB39_4
; %bb.3:
	ld	l, e
	ld	h, d
	ld	(ix - 7), l
	ld	(ix - 6), h
	.local	.LBB39_4
.LBB39_4:
	bit	0, a
	jr	nz, .LBB39_6
; %bb.5:
	ld	a, -16
	jr	.LBB39_7
	.local	.LBB39_6
.LBB39_6:
	ld	a, -12
	.local	.LBB39_7
.LBB39_7:
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
	.local	.LBB39_8
.LBB39_8:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB39_12 Depth 2
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jp	z, .LBB39_1
; %bb.9:                                ;   in Loop: Header=BB39_8 Depth=1
	ld	(ix - 16), de
	lea	hl, iy + 0
	ld	de, (ix + 12)
	add	hl, de
	or	a, a
	sbc	hl, bc
	jr	c, .LBB39_11
	.local	.LBB39_10
.LBB39_10:                              ; %.loopexit
                                        ;   in Loop: Header=BB39_8 Depth=1
	inc	iy
	ld	hl, (ix - 7)
	ld	de, 320
	add	hl, de
	ld	(ix - 7), hl
	ld	de, (ix - 16)
	ld	bc, 240
	jr	.LBB39_8
	.local	.LBB39_11
.LBB39_11:                              ;   in Loop: Header=BB39_8 Depth=1
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
	.local	.LBB39_12
.LBB39_12:                              ;   Parent Loop BB39_8 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	de
	pop	hl
	ld	bc, (ix - 13)
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB39_10
; %bb.13:                               ;   in Loop: Header=BB39_12 Depth=2
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
	jr	z, .LBB39_15
; %bb.14:                               ;   in Loop: Header=BB39_12 Depth=2
	ld	c, (ix - 21)
	ld	a, l
	add	a, c
	ld	c, a
	ld	hl, (ix - 27)
	add	hl, de
	ld	(hl), c
	.local	.LBB39_15
.LBB39_15:                              ;   in Loop: Header=BB39_12 Depth=2
	inc	de
	ld	l, 2
	ld	c, (ix - 17)
	ld	a, c
	add	a, l
	ld	c, a
	ld	(ix - 17), c
	jr	.LBB39_12
	.local	.Lfunc_end39
.Lfunc_end39:
	.size	_ui_draw_title, .Lfunc_end39-_ui_draw_title
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
	jr	z, .LBB40_2
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
	.local	.LBB40_2
.LBB40_2:
	call	_gfx_SwapDraw
	call	_input_reset
	.local	.LBB40_3
.LBB40_3:                               ; =>This Inner Loop Header: Depth=1
	call	_input_scan
	call	_input_idle
	bit	0, a
	jr	z, .LBB40_3
	.local	.LBB40_4
.LBB40_4:                               ; %.preheader1
                                        ; =>This Inner Loop Header: Depth=1
	call	_input_scan
	call	_input_idle
	bit	0, a
	jr	nz, .LBB40_4
	.local	.LBB40_5
.LBB40_5:                               ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	call	_input_scan
	call	_input_idle
	bit	0, a
	jr	z, .LBB40_5
; %bb.6:
	pop	ix
	ret
	.local	.Lfunc_end40
.Lfunc_end40:
	.size	_ui_message, .Lfunc_end40-_ui_message
                                        ; -- End function
	.section	.text._ui_confirm,"ax",@progbits
	.globl	_ui_confirm                     ; -- Begin function ui_confirm
	.type	_ui_confirm,@function
_ui_confirm:                            ; @ui_confirm
; %bb.0:
	call	__frameset0
	ld	hl, 248
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, _.str.15
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
	ld	hl, 90
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
	jr	z, .LBB41_2
; %bb.1:
	ld	hl, 108
	push	hl
	ld	hl, 10
	push	hl
	push	de
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB41_2
.LBB41_2:
	ld	hl, _.str.1.16
	push	hl
	call	_ui_footer
	pop	hl
	call	_input_reset
	ld	hl, 1
	.local	.LBB41_3
.LBB41_3:                               ; %input_pressed.exit1
                                        ; =>This Inner Loop Header: Depth=1
	push	hl
	call	_ui_present
	pop	hl
	call	_input_scan
	ld	a, (_current+1)
	bit	5, a
	jr	z, .LBB41_5
; %bb.4:                                ; %input_pressed.exit
                                        ;   in Loop: Header=BB41_3 Depth=1
	ld	a, (_previous+1)
	bit	5, a
	jr	z, .LBB41_8
	.local	.LBB41_5
.LBB41_5:                               ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB41_3 Depth=1
	ld	a, (_current+6)
	bit	6, a
	ld	hl, 0
	jr	z, .LBB41_3
; %bb.6:                                ;   in Loop: Header=BB41_3 Depth=1
	ld	a, (_previous+6)
	bit	6, a
	jr	nz, .LBB41_3
; %bb.7:
	xor	a, a
	jr	.LBB41_9
	.local	.LBB41_8
.LBB41_8:
	ld	a, 1
	.local	.LBB41_9
.LBB41_9:
	pop	ix
	ret
	.local	.Lfunc_end41
.Lfunc_end41:
	.size	_ui_confirm, .Lfunc_end41-_ui_confirm
                                        ; -- End function
	.section	.text._ui_book_menu,"ax",@progbits
	.globl	_ui_book_menu                   ; -- Begin function ui_book_menu
	.type	_ui_book_menu,@function
_ui_book_menu:                          ; @ui_book_menu
; %bb.0:
	ld	hl, -63
	call	__frameset
	ld	iy, (ix + 6)
	ld.sis	bc, 0
	lea	de, ix - 7
	lea	hl, ix - 31
	ld	(ix - 49), hl
	lea	hl, ix - 37
	ld	(ix - 52), hl
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
	ld	b, 1
	.local	.LBB42_1
.LBB42_1:                               ; %input_pressed.exit6
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB42_9 Depth 2
	bit	0, b
	jp	z, .LBB42_16
; %bb.2:                                ;   in Loop: Header=BB42_1 Depth=1
	ld	(ix - 56), b                    ; 1-byte Folded Spill
	ld	hl, 248
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, _.str.2.19
	push	hl
	call	_ui_header
	pop	hl
	ld	bc, (ix - 7)
	sbc.sis	hl, hl
	adc.sis	hl, bc
	jr	nz, .LBB42_4
; %bb.3:                                ;   in Loop: Header=BB42_1 Depth=1
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
	ld	hl, _.str.3
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 108
	push	hl
	ld	hl, 10
	push	hl
	ld	hl, _.str.4
	push	hl
	call	_gfx_PrintStringXY
	ld	bc, (ix - 40)
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB42_4
.LBB42_4:                               ;   in Loop: Header=BB42_1 Depth=1
	ld	hl, (ix - 3)
	ld	(ix - 59), hl
	ld	e, l
	ld	d, h
	ld	hl, (ix - 5)
	ld	(ix - 46), hl
	or	a, a
	ld	l, c
	ld	h, b
	sbc.sis	hl, de
	ld.sis	bc, 0
	jr	c, .LBB42_6
; %bb.5:                                ;   in Loop: Header=BB42_1 Depth=1
	ld	c, l
	ld	b, h
	.local	.LBB42_6
.LBB42_6:                               ;   in Loop: Header=BB42_1 Depth=1
	ld	iy, 0
	lea	hl, iy + 0
	ld	l, e
	ld	h, d
	ld	(ix - 40), hl
	ld	hl, (ix - 46)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	l, c
	ld	h, b
	ld.sis	de, 10
	or	a, a
	sbc.sis	hl, de
	jr	c, .LBB42_8
; %bb.7:                                ;   in Loop: Header=BB42_1 Depth=1
	ld.sis	bc, 10
	.local	.LBB42_8
.LBB42_8:                               ;   in Loop: Header=BB42_1 Depth=1
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	bc, 20
	call	__imulu
	ex	de, hl
	lea	hl, iy + 0
	ld	bc, (ix - 40)
	or	a, a
	sbc	hl, bc
	push	hl
	pop	iy
	ld.sis	hl, 0
                                        ; kill: def $hl killed $hl def $uhl
	ld	(ix - 46), hl
	or	a, a
	sbc	hl, hl
	ld	(ix - 40), hl
	.local	.LBB42_9
.LBB42_9:                               ;   Parent Loop BB42_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	de
	pop	hl
	ld	bc, (ix - 40)
	or	a, a
	sbc	hl, bc
	jp	z, .LBB42_15
; %bb.10:                               ;   in Loop: Header=BB42_9 Depth=2
	ld	(ix - 62), de
	ld	hl, (ix - 46)
	push	hl
	ld	hl, (ix - 43)
	push	hl
	ld	(ix - 55), iy
	call	_draw_row_background
	pop	hl
	pop	hl
	ld	hl, (ix - 59)
                                        ; kill: def $hl killed $hl killed $uhl def $uhl
	ld	de, (ix - 46)
	add.sis	hl, de
	ld	de, (ix - 52)
	push	de
	push	hl
	call	_lib_get_book
	pop	hl
	pop	hl
	ld	de, (ix - 37)
	ld	iy, (ix - 40)
	ld	bc, 24
	add	iy, bc
	ld	hl, (ix - 55)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, -1
	jr	z, .LBB42_12
; %bb.11:                               ;   in Loop: Header=BB42_9 Depth=2
	ld	a, 0
	.local	.LBB42_12
.LBB42_12:                              ;   in Loop: Header=BB42_9 Depth=2
	ld	(ix - 63), a
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
	ld	hl, (ix - 52)
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
	ld	hl, _.str.5.20
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
	bit	0, (ix - 63)                    ; 1-byte Folded Reload
	ld	a, -4
	ld	l, a
	jr	nz, .LBB42_14
; %bb.13:                               ;   in Loop: Header=BB42_9 Depth=2
	ld	a, -8
	ld	l, a
	.local	.LBB42_14
.LBB42_14:                              ;   in Loop: Header=BB42_9 Depth=2
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
	ld	hl, (ix - 40)
	add	hl, de
	ex	de, hl
	ld	iy, (ix - 55)
	dec	iy
	ld	hl, (ix - 46)
	inc.sis	hl
	ld	(ix - 46), hl
	ld	(ix - 40), de
	ld	de, (ix - 62)
	jp	.LBB42_9
	.local	.LBB42_15
.LBB42_15:                              ;   in Loop: Header=BB42_1 Depth=1
	ld	hl, (ix - 43)
	push	hl
	call	_draw_scrollbar
	pop	hl
	ld	hl, _.str.6
	push	hl
	call	_ui_footer
	pop	hl
	ld	b, (ix - 56)                    ; 1-byte Folded Reload
	.local	.LBB42_16
.LBB42_16:                              ;   in Loop: Header=BB42_1 Depth=1
	ld	l, b
	push	hl
	call	_ui_present
	pop	hl
	call	_input_scan
	ld	hl, (ix - 43)
	push	hl
	call	_list_navigate
	ld	b, a
	pop	hl
	ld	a, (_current+6)
	ld	l, 1
	ld	(ix - 40), a                    ; 1-byte Folded Spill
	and	a, l
	ld	l, a
	bit	0, l
	jr	nz, .LBB42_19
; %bb.17:                               ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB42_1 Depth=1
	ld	hl, (ix - 7)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	d, -1
	jr	nz, .LBB42_24
; %bb.18:                               ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB42_1 Depth=1
	ld	d, 0
	jr	.LBB42_24
	.local	.LBB42_19
.LBB42_19:                              ; %input_pressed.exit
                                        ;   in Loop: Header=BB42_1 Depth=1
	ld	e, b
	ld	a, (_previous+6)
	ld	bc, (ix - 7)
	sbc.sis	hl, hl
	adc.sis	hl, bc
	ld	d, -1
	jr	nz, .LBB42_21
; %bb.20:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB42_1 Depth=1
	ld	d, 0
	.local	.LBB42_21
.LBB42_21:                              ; %input_pressed.exit
                                        ;   in Loop: Header=BB42_1 Depth=1
	ld	l, 1
	and	a, l
	ld	l, a
	bit	0, l
	jr	nz, .LBB42_23
; %bb.22:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB42_1 Depth=1
	sbc.sis	hl, hl
	adc.sis	hl, bc
	ld	b, e
	jp	nz, .LBB42_43
	jr	.LBB42_24
	.local	.LBB42_23
.LBB42_23:                              ;   in Loop: Header=BB42_1 Depth=1
	ld	b, e
	.local	.LBB42_24
.LBB42_24:                              ;   in Loop: Header=BB42_1 Depth=1
	ld	a, (_current+1)
	ld	l, a
	bit	5, l
	jr	z, .LBB42_26
; %bb.25:                               ; %input_pressed.exit2
                                        ;   in Loop: Header=BB42_1 Depth=1
	ld	a, (_previous+1)
	bit	5, a
	jp	z, .LBB42_41
	.local	.LBB42_26
.LBB42_26:                              ; %input_pressed.exit2.thread
                                        ;   in Loop: Header=BB42_1 Depth=1
	ld	a, (_current+2)
	ld	c, a
	ld	a, (_previous+2)
	ld	e, a
	ld	a, c
	cp	a, 0
	call	pe, __setflag
	jp	p, .LBB42_28
; %bb.27:                               ; %input_pressed.exit2.thread
                                        ;   in Loop: Header=BB42_1 Depth=1
	ld	a, e
	cp	a, 0
	call	pe, __setflag
	jp	p, .LBB42_42
	.local	.LBB42_28
.LBB42_28:                              ; %input_pressed.exit3.thread
                                        ;   in Loop: Header=BB42_1 Depth=1
	bit	6, l
	jr	z, .LBB42_30
; %bb.29:                               ; %input_pressed.exit4
                                        ;   in Loop: Header=BB42_1 Depth=1
	ld	a, (_previous+1)
	bit	6, a
	jp	z, .LBB42_44
	.local	.LBB42_30
.LBB42_30:                              ; %input_pressed.exit4.thread
                                        ;   in Loop: Header=BB42_1 Depth=1
	ld	a, l
	cp	a, 0
	call	pe, __setflag
	jp	p, .LBB42_37
; %bb.31:                               ; %input_pressed.exit5
                                        ;   in Loop: Header=BB42_1 Depth=1
	ld	a, (_previous+1)
	cp	a, 0
	call	pe, __setflag
	jp	m, .LBB42_37
; %bb.32:                               ; %input_pressed.exit5
                                        ;   in Loop: Header=BB42_1 Depth=1
	bit	0, d
	jr	z, .LBB42_37
; %bb.33:                               ;   in Loop: Header=BB42_1 Depth=1
	ld	hl, (ix - 5)
	ld	de, (ix - 52)
	push	de
	push	hl
	ld	(ix - 56), b                    ; 1-byte Folded Spill
	call	_lib_get_book
	ld	b, (ix - 56)                    ; 1-byte Folded Reload
	pop	hl
	pop	hl
	ld	de, (ix - 33)
	sbc.sis	hl, hl
	adc.sis	hl, de
	ld	l, (ix - 40)                    ; 1-byte Folded Reload
	jr	z, .LBB42_38
; %bb.34:                               ;   in Loop: Header=BB42_1 Depth=1
	ld	hl, (ix - 52)
	push	hl
	ld	(ix - 40), de
	call	_lib_book_read_count
	pop	de
	ld	de, (ix - 40)
	or	a, a
	sbc.sis	hl, de
	ld	hl, -1
	jr	nz, .LBB42_36
; %bb.35:                               ;   in Loop: Header=BB42_1 Depth=1
	ld	hl, 0
	.local	.LBB42_36
.LBB42_36:                              ;   in Loop: Header=BB42_1 Depth=1
	push	hl
	ld	hl, (ix - 52)
	push	hl
	call	_lib_set_book_read
	pop	hl
	pop	hl
	ld	a, (_current+6)
	ld	l, a
	ld	b, 1
	jr	.LBB42_38
	.local	.LBB42_37
.LBB42_37:                              ;   in Loop: Header=BB42_1 Depth=1
	ld	l, (ix - 40)                    ; 1-byte Folded Reload
	.local	.LBB42_38
.LBB42_38:                              ; %input_pressed.exit5.thread
                                        ;   in Loop: Header=BB42_1 Depth=1
	bit	6, l
	jp	z, .LBB42_1
; %bb.39:                               ;   in Loop: Header=BB42_1 Depth=1
	ld	a, (_previous+6)
	bit	6, a
	jp	nz, .LBB42_1
; %bb.40:
	ld	hl, 1
	jr	.LBB42_46
	.local	.LBB42_41
.LBB42_41:
	ld	hl, 2
	jr	.LBB42_46
	.local	.LBB42_42
.LBB42_42:
	ld	hl, 3
	jr	.LBB42_46
	.local	.LBB42_43
.LBB42_43:
	or	a, a
	sbc	hl, hl
	jr	.LBB42_45
	.local	.LBB42_44
.LBB42_44:
	ld	hl, 4
	.local	.LBB42_45
.LBB42_45:
	ld	de, (ix - 5)
	ld	iy, (ix + 6)
	ld	(iy), e
	ld	(iy + 1), d
	.local	.LBB42_46
.LBB42_46:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end42
.Lfunc_end42:
	.size	_ui_book_menu, .Lfunc_end42-_ui_book_menu
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
	jp	z, .LBB43_10
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
	jp	p, .LBB43_3
; %bb.2:
	or	a, a
	sbc	hl, hl
	.local	.LBB43_3
.LBB43_3:
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
	jp	m, .LBB43_5
; %bb.4:
	dec	de
	ex	de, hl
	.local	.LBB43_5
.LBB43_5:
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
	jr	nc, .LBB43_7
; %bb.6:
	ld	hl, (ix - 3)
	jr	.LBB43_9
	.local	.LBB43_7
.LBB43_7:
	ex	de, hl
	ld	de, 10
	add	hl, de
	ex	de, hl
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	c, .LBB43_10
; %bb.8:
	ld.sis	de, -9
	ld	hl, (ix - 3)
	add.sis	hl, de
	.local	.LBB43_9
.LBB43_9:
	ld	(iy + 4), l
	ld	(iy + 5), h
	.local	.LBB43_10
.LBB43_10:
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end43
.Lfunc_end43:
	.size	_list_move, .Lfunc_end43-_list_move
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
	jr	z, .LBB44_2
; %bb.1:
	ld	l, -8
	jr	.LBB44_3
	.local	.LBB44_2
.LBB44_2:
	ld	l, -4
	.local	.LBB44_3
.LBB44_3:
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
	.local	.Lfunc_end44
.Lfunc_end44:
	.size	_draw_row_background, .Lfunc_end44-_draw_row_background
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
	jp	c, .LBB45_4
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
	jr	nc, .LBB45_3
; %bb.2:
	ld.sis	iy, 8
	.local	.LBB45_3
.LBB45_3:
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
	.local	.LBB45_4
.LBB45_4:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end45
.Lfunc_end45:
	.size	_draw_scrollbar, .Lfunc_end45-_draw_scrollbar
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
	jr	z, .LBB46_2
; %bb.1:
	scf
	sbc	hl, hl
	jr	.LBB46_8
	.local	.LBB46_2
.LBB46_2:
	ld	hl, 1793
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB46_4
; %bb.3:
	ld	hl, 1
	jr	.LBB46_8
	.local	.LBB46_4
.LBB46_4:
	ld	hl, 1794
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB46_6
; %bb.5:
	ld	hl, -10
	jr	.LBB46_8
	.local	.LBB46_6
.LBB46_6:
	ld	hl, 1796
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB46_10
; %bb.7:
	ld	hl, 10
	.local	.LBB46_8
.LBB46_8:
	ld	de, (ix + 6)
	push	hl
	push	de
	call	_list_move
	ld	a, 1
	pop	hl
	pop	hl
	.local	.LBB46_9
.LBB46_9:
	pop	ix
	ret
	.local	.LBB46_10
.LBB46_10:
	xor	a, a
	jr	.LBB46_9
	.local	.Lfunc_end46
.Lfunc_end46:
	.size	_list_navigate, .Lfunc_end46-_list_navigate
                                        ; -- End function
	.section	.text._ui_strip_menu,"ax",@progbits
	.globl	_ui_strip_menu                  ; -- Begin function ui_strip_menu
	.type	_ui_strip_menu,@function
_ui_strip_menu:                         ; @ui_strip_menu
; %bb.0:
	ld	hl, -86
	call	__frameset
	ld	hl, (ix + 6)
	lea	de, ix - 7
	lea	bc, ix - 13
	ld	(ix - 59), bc
	lea	bc, ix - 37
	ld	(ix - 68), bc
	lea	bc, ix - 53
	ld	(ix - 83), bc
	ld	(ix - 86), de
	push	de
	push	hl
	call	_lib_get_book
	pop	hl
	pop	hl
	ld	hl, (ix - 3)
	ld	(ix - 56), hl
	ld	(ix - 13), l
	ld	(ix - 12), h
	ld.sis	hl, 0
	ld	(ix - 11), l
	ld	(ix - 10), h
	ld	(ix - 9), l
	ld	(ix - 8), h
	ld	d, 1
	.local	.LBB47_1
.LBB47_1:                               ; %input_pressed.exit2
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB47_7 Depth 2
	bit	0, d
	jp	z, .LBB47_17
; %bb.2:                                ;   in Loop: Header=BB47_1 Depth=1
	ld	(ix - 75), d                    ; 1-byte Folded Spill
	ld	hl, 248
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, _.str.7
	push	hl
	call	_ui_header
	pop	hl
	ld	bc, (ix - 9)
	ld	iy, (ix - 11)
	or	a, a
	ld	hl, (ix - 56)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	(ix - 62), bc
	sbc.sis	hl, bc
	ld.sis	bc, 0
	jr	c, .LBB47_4
; %bb.3:                                ;   in Loop: Header=BB47_1 Depth=1
	ld	c, l
	ld	b, h
	.local	.LBB47_4
.LBB47_4:                               ;   in Loop: Header=BB47_1 Depth=1
	ld	de, 0
	ld	hl, (ix - 62)
	ld	e, l
	ld	d, h
	ld	(ix - 56), de
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 71), hl
	ld	hl, (ix - 5)
	ld	(ix - 65), hl
	ld	l, c
	ld	h, b
	ld.sis	de, 10
	sbc.sis	hl, de
	jr	c, .LBB47_6
; %bb.5:                                ;   in Loop: Header=BB47_1 Depth=1
	ld.sis	bc, 10
	.local	.LBB47_6
.LBB47_6:                               ;   in Loop: Header=BB47_1 Depth=1
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	bc, 20
	call	__imulu
	push	hl
	pop	iy
	ld	hl, (ix - 71)
	ld	de, (ix - 56)
	or	a, a
	sbc	hl, de
	ld	(ix - 56), hl
	ld	hl, (ix - 62)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	de, (ix - 65)
	add.sis	hl, de
	ld	(ix - 80), l
	ld	(ix - 79), h
	ld.sis	hl, 0
	ld	c, l
	ld	b, h
	or	a, a
	sbc	hl, hl
	push	hl
	pop	de
	ld	(ix - 65), hl
	.local	.LBB47_7
.LBB47_7:                               ;   Parent Loop BB47_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	ld	(ix - 62), de
	or	a, a
	sbc	hl, de
	jp	z, .LBB47_16
; %bb.8:                                ;   in Loop: Header=BB47_7 Depth=2
	ld	(ix - 78), iy
	push	bc
	ld	hl, (ix - 59)
	push	hl
	ld	(ix - 74), bc
	call	_draw_row_background
	pop	hl
	pop	hl
	ld	l, (ix - 80)
	ld	h, (ix - 79)
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
	jr	z, .LBB47_10
; %bb.9:                                ;   in Loop: Header=BB47_7 Depth=2
	ld	a, -8
	ld	l, a
	.local	.LBB47_10
.LBB47_10:                              ;   in Loop: Header=BB47_7 Depth=2
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	a, (ix - 48)
	ld	l, 1
	and	a, l
	ld	l, a
	bit	0, l
	jr	nz, .LBB47_12
; %bb.11:                               ;   in Loop: Header=BB47_7 Depth=2
	ld	iy, (ix - 62)
	lea	hl, iy + 0
	ld	de, 28
	add	hl, de
	ld	(ix - 71), hl
	jr	.LBB47_13
	.local	.LBB47_12
.LBB47_12:                              ;   in Loop: Header=BB47_7 Depth=2
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
	ld	hl, _.str.8
	push	hl
	call	_gfx_PrintStringXY
	ld	iy, (ix - 62)
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB47_13
.LBB47_13:                              ;   in Loop: Header=BB47_7 Depth=2
	ld	de, (ix - 39)
	ld	bc, 24
	add	iy, bc
	ld	hl, (ix - 56)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	hl, -1
	jr	z, .LBB47_15
; %bb.14:                               ;   in Loop: Header=BB47_7 Depth=2
	ld	hl, 0
	.local	.LBB47_15
.LBB47_15:                              ;   in Loop: Header=BB47_7 Depth=2
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
	ld	hl, _.str.9
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
	ld	iy, (ix - 78)
	jp	.LBB47_7
	.local	.LBB47_16
.LBB47_16:                              ;   in Loop: Header=BB47_1 Depth=1
	ld	hl, (ix - 59)
	push	hl
	call	_draw_scrollbar
	pop	hl
	ld	hl, _.str.10
	push	hl
	call	_ui_footer
	pop	hl
	ld	d, (ix - 75)                    ; 1-byte Folded Reload
	.local	.LBB47_17
.LBB47_17:                              ;   in Loop: Header=BB47_1 Depth=1
	ld	l, d
	push	hl
	call	_ui_present
	pop	hl
	call	_input_scan
	ld	hl, (ix - 59)
	push	hl
	call	_list_navigate
	ld	d, a
	pop	hl
	ld	a, (_current+6)
	ld	e, a
	ld	l, 1
	ld	a, e
	and	a, l
	ld	l, a
	bit	0, l
	jr	nz, .LBB47_20
; %bb.18:                               ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB47_1 Depth=1
	ld	hl, (ix - 13)
	ld	(ix - 56), hl
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	c, -1
	jr	nz, .LBB47_24
; %bb.19:                               ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB47_1 Depth=1
	ld	c, 0
	jr	.LBB47_24
	.local	.LBB47_20
.LBB47_20:                              ; %input_pressed.exit
                                        ;   in Loop: Header=BB47_1 Depth=1
	ld	a, (_previous+6)
	ld	hl, (ix - 13)
	ld	(ix - 56), hl
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	c, -1
	jr	nz, .LBB47_22
; %bb.21:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB47_1 Depth=1
	ld	c, 0
	.local	.LBB47_22
.LBB47_22:                              ; %input_pressed.exit
                                        ;   in Loop: Header=BB47_1 Depth=1
	ld	l, 1
	and	a, l
	ld	l, a
	bit	0, l
	jr	nz, .LBB47_24
; %bb.23:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB47_1 Depth=1
	ld	hl, (ix - 56)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jp	nz, .LBB47_33
	.local	.LBB47_24
.LBB47_24:                              ;   in Loop: Header=BB47_1 Depth=1
	ld	a, (_current+1)
	cp	a, 0
	call	pe, __setflag
	jp	p, .LBB47_30
; %bb.25:                               ; %input_pressed.exit1
                                        ;   in Loop: Header=BB47_1 Depth=1
	ld	a, (_previous+1)
	cp	a, 0
	call	pe, __setflag
	jp	m, .LBB47_30
; %bb.26:                               ; %input_pressed.exit1
                                        ;   in Loop: Header=BB47_1 Depth=1
	bit	0, c
	jr	z, .LBB47_30
; %bb.27:                               ;   in Loop: Header=BB47_1 Depth=1
	ld	de, (ix - 5)
	ld	iy, (ix - 11)
	add.sis	iy, de
	ld	hl, (ix - 83)
	push	hl
	ld	(ix - 62), iy
	push	iy
	call	_lib_get_strip
	pop	hl
	pop	hl
	ld	l, (ix - 48)
	ld	a, 1
	ld	c, a
	ld	a, l
	xor	a, c
	ld	e, a
	ld	(ix - 48), e
	ld	a, l
	and	a, c
	ld	l, a
	bit	0, l
	jr	nz, .LBB47_29
; %bb.28:                               ;   in Loop: Header=BB47_1 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	call	_time
	pop	bc
	ld	(ix - 47), hl
	ld	(ix - 44), e
	.local	.LBB47_29
.LBB47_29:                              ;   in Loop: Header=BB47_1 Depth=1
	ld	hl, (ix - 83)
	push	hl
	ld	hl, (ix - 62)
	push	hl
	call	_lib_save_strip
	pop	hl
	pop	hl
	ld	hl, (ix - 86)
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_lib_get_book
	pop	hl
	pop	hl
	ld	a, (_current+6)
	ld	e, a
	ld	d, 1
	.local	.LBB47_30
.LBB47_30:                              ; %input_pressed.exit1.thread
                                        ;   in Loop: Header=BB47_1 Depth=1
	bit	6, e
	jp	z, .LBB47_1
; %bb.31:                               ;   in Loop: Header=BB47_1 Depth=1
	ld	a, (_previous+6)
	bit	6, a
	jp	nz, .LBB47_1
; %bb.32:
	ld	hl, 1
	jr	.LBB47_34
	.local	.LBB47_33
.LBB47_33:
	ld	de, (ix - 5)
	ld	hl, (ix - 11)
	add.sis	hl, de
	ld	iy, (ix + 9)
	ld	(iy), l
	ld	(iy + 1), h
	or	a, a
	sbc	hl, hl
	.local	.LBB47_34
.LBB47_34:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end47
.Lfunc_end47:
	.size	_ui_strip_menu, .Lfunc_end47-_ui_strip_menu
                                        ; -- End function
	.section	.text._ui_about_screen,"ax",@progbits
	.globl	_ui_about_screen                ; -- Begin function ui_about_screen
	.type	_ui_about_screen,@function
_ui_about_screen:                       ; @ui_about_screen
; %bb.0:
	ld	hl, -13
	call	__frameset
	call	_input_reset
	ld	e, 1
	or	a, a
	sbc	hl, hl
	ld	(ix - 3), hl
	.local	.LBB48_1
.LBB48_1:                               ; %input_pressed.exit
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB48_7 Depth 2
	bit	0, e
	jp	z, .LBB48_10
; %bb.2:                                ;   in Loop: Header=BB48_1 Depth=1
	ld	(ix - 7), e                     ; 1-byte Folded Spill
	ld	hl, 248
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, _.str.11
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
	ld	bc, (ix - 3)
	push	bc
	pop	hl
	ld	de, 50
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	push	bc
	pop	hl
	jp	p, .LBB48_4
; %bb.3:                                ;   in Loop: Header=BB48_1 Depth=1
	ld	hl, 49
	.local	.LBB48_4
.LBB48_4:                               ;   in Loop: Header=BB48_1 Depth=1
	ld	de, (ix - 3)
	or	a, a
	sbc	hl, de
	push	hl
	pop	de
	ld	bc, 11
	or	a, a
	sbc	hl, bc
	jr	c, .LBB48_6
; %bb.5:                                ;   in Loop: Header=BB48_1 Depth=1
	ld	de, 11
	.local	.LBB48_6
.LBB48_6:                               ;   in Loop: Header=BB48_1 Depth=1
	ex	de, hl
	ld	bc, 18
	call	__imulu
	ld	(ix - 6), hl
	ld	hl, (ix - 3)
	ld	bc, 3
	call	__imulu
	ex	de, hl
	ld	iy, _about_text
	add	iy, de
	ld	de, 0
	.local	.LBB48_7
.LBB48_7:                               ;   Parent Loop BB48_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	hl, (ix - 6)
	or	a, a
	sbc	hl, de
	jr	z, .LBB48_9
; %bb.8:                                ;   in Loop: Header=BB48_7 Depth=2
	ld	(ix - 10), iy
	ld	bc, (iy)
	ex	de, hl
	ld	(ix - 13), hl
	ld	de, 22
	add	hl, de
	push	hl
	ld	hl, 8
	push	hl
	push	bc
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	de, 18
	ld	hl, (ix - 13)
	add	hl, de
	ld	iy, (ix - 10)
	lea	iy, iy + 3
	ex	de, hl
	jr	.LBB48_7
	.local	.LBB48_9
.LBB48_9:                               ;   in Loop: Header=BB48_1 Depth=1
	ld	hl, 251
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, (ix - 3)
	ld	bc, 154
	call	__imulu
	ld	bc, 38
	call	__idivs
	ld	e, 22
	ld	a, l
	add	a, e
	ld	l, a
	ld	de, 44
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
	ld	hl, _.str.12
	push	hl
	call	_ui_footer
	pop	hl
	ld	e, (ix - 7)                     ; 1-byte Folded Reload
	.local	.LBB48_10
.LBB48_10:                              ;   in Loop: Header=BB48_1 Depth=1
	ld	l, e
	push	hl
	call	_ui_present
	pop	hl
	call	_input_scan
	ld	hl, 1800
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB48_13
; %bb.11:                               ;   in Loop: Header=BB48_1 Depth=1
	ld	hl, (ix - 3)
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB48_13
; %bb.12:                               ;   in Loop: Header=BB48_1 Depth=1
	ld	hl, (ix - 3)
	dec	hl
	jr	.LBB48_16
	.local	.LBB48_13
.LBB48_13:                              ;   in Loop: Header=BB48_1 Depth=1
	ld	hl, 1793
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB48_17
; %bb.14:                               ;   in Loop: Header=BB48_1 Depth=1
	ld	hl, (ix - 3)
	ld	de, 38
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB48_17
; %bb.15:                               ;   in Loop: Header=BB48_1 Depth=1
	ld	hl, (ix - 3)
	inc	hl
	.local	.LBB48_16
.LBB48_16:                              ;   in Loop: Header=BB48_1 Depth=1
	ld	(ix - 3), hl
	ld	a, 1
	jr	.LBB48_26
	.local	.LBB48_17
.LBB48_17:                              ;   in Loop: Header=BB48_1 Depth=1
	ld	hl, 1794
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB48_21
; %bb.18:                               ;   in Loop: Header=BB48_1 Depth=1
	ld	hl, (ix - 3)
	push	hl
	pop	iy
	ld	de, -11
	add	iy, de
	ld	de, 12
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB48_20
; %bb.19:                               ;   in Loop: Header=BB48_1 Depth=1
	ld	iy, 0
	.local	.LBB48_20
.LBB48_20:                              ;   in Loop: Header=BB48_1 Depth=1
	ld	a, 1
	ld	e, a
	ld	(ix - 3), iy
	jr	.LBB48_27
	.local	.LBB48_21
.LBB48_21:                              ;   in Loop: Header=BB48_1 Depth=1
	ld	hl, 1796
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB48_25
; %bb.22:                               ;   in Loop: Header=BB48_1 Depth=1
	ld	bc, (ix - 3)
	push	bc
	pop	hl
	ld	de, 27
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	push	bc
	pop	hl
	jp	m, .LBB48_24
; %bb.23:                               ;   in Loop: Header=BB48_1 Depth=1
	ld	hl, 27
	.local	.LBB48_24
.LBB48_24:                              ;   in Loop: Header=BB48_1 Depth=1
	ld	de, 11
	add	hl, de
	ld	a, 1
	ld	e, a
	ld	(ix - 3), hl
	jr	.LBB48_27
	.local	.LBB48_25
.LBB48_25:                              ;   in Loop: Header=BB48_1 Depth=1
	xor	a, a
	.local	.LBB48_26
.LBB48_26:                              ;   in Loop: Header=BB48_1 Depth=1
	ld	e, a
	.local	.LBB48_27
.LBB48_27:                              ;   in Loop: Header=BB48_1 Depth=1
	ld	a, (_current+6)
	bit	6, a
	jp	z, .LBB48_1
; %bb.28:                               ;   in Loop: Header=BB48_1 Depth=1
	ld	a, (_previous+6)
	bit	6, a
	jp	nz, .LBB48_1
; %bb.29:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end48
.Lfunc_end48:
	.size	_ui_about_screen, .Lfunc_end48-_ui_about_screen
                                        ; -- End function
	.section	.text._ui_setup_screen,"ax",@progbits
	.globl	_ui_setup_screen                ; -- Begin function ui_setup_screen
	.type	_ui_setup_screen,@function
_ui_setup_screen:                       ; @ui_setup_screen
; %bb.0:
	ld	hl, -107
	call	__frameset
	lea	hl, ix - 40
	ld	(ix - 94), hl
	lea	hl, ix - 81
	ld	(ix - 91), hl
	call	_input_reset
	ld	h, 1
	xor	a, a
	ld	(ix - 82), a                    ; 1-byte Folded Spill
	.local	.LBB49_1
.LBB49_1:                               ; %input_pressed.exit4
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB49_3 Depth 2
                                        ;     Child Loop BB49_6 Depth 2
	bit	0, h
	jp	z, .LBB49_13
; %bb.2:                                ;   in Loop: Header=BB49_1 Depth=1
	ld	(ix - 95), h                    ; 1-byte Folded Spill
	ld	hl, 248
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, _.str.14
	push	hl
	call	_ui_header
	pop	hl
	ld	hl, 251
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 248
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	hl, _book_count
	ld	de, (hl)
	ld.sis	hl, 0
	ld	(ix - 85), l
	ld	(ix - 84), h
	ld	c, l
	ld	b, h
	.local	.LBB49_3
.LBB49_3:                               ;   Parent Loop BB49_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	jr	z, .LBB49_5
; %bb.4:                                ;   in Loop: Header=BB49_3 Depth=2
	ld	hl, (ix - 91)
	push	hl
	push	bc
	ld	(ix - 88), de
	ld	(ix - 98), bc
	call	_lib_get_book
	pop	hl
	pop	hl
	ld	hl, (ix - 91)
	push	hl
	call	_lib_book_read_count
	ld	bc, (ix - 98)
	pop	de
	ld	e, (ix - 85)
	ld	d, (ix - 84)
	add.sis	hl, de
	ld	de, (ix - 88)
	inc.sis	bc
	ld	(ix - 85), l
	ld	(ix - 84), h
	jr	.LBB49_3
	.local	.LBB49_5
.LBB49_5:                               ;   in Loop: Header=BB49_1 Depth=1
	ld	bc, 0
	push	bc
	pop	iy
	ld	iyl, e
	ld	iyh, d
	ld	hl, _strip_count
	ld	de, (hl)
	push	bc
	pop	hl
	ld	c, e
	ld	b, d
	ex	de, hl
	ld	l, (ix - 85)
	ld	h, (ix - 84)
	ld	e, l
	ld	d, h
	push	de
	push	bc
	push	iy
	ld	hl, _.str.15.25
	push	hl
	ld	hl, (ix - 94)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 30
	push	hl
	ld	hl, 10
	push	hl
	ld	hl, (ix - 94)
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 82)                    ; 1-byte Folded Reload
	ld	bc, 20
	call	__imulu
	ld	(ix - 98), hl
	ld	hl, _ui_setup_screen.entries
	ld	(ix - 85), hl
	or	a, a
	sbc	hl, hl
	ld	a, 66
	ld	c, a
	.local	.LBB49_6
.LBB49_6:                               ;   Parent Loop BB49_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	bc
	pop	iy
	push	hl
	pop	bc
	ld	de, 40
	or	a, a
	sbc	hl, de
	jp	z, .LBB49_10
; %bb.7:                                ;   in Loop: Header=BB49_6 Depth=2
	push	bc
	pop	hl
	ld	de, 70
	add	hl, de
	ld	(ix - 104), hl
	ld	hl, (ix - 98)
	ld	(ix - 101), bc
	or	a, a
	sbc	hl, bc
	ld	a, -4
	ld	l, a
	ld	(ix - 88), iy
	jr	z, .LBB49_9
; %bb.8:                                ;   in Loop: Header=BB49_6 Depth=2
	ld	a, -8
	ld	l, a
	.local	.LBB49_9
.LBB49_9:                               ;   in Loop: Header=BB49_6 Depth=2
	ld	(ix - 107), hl
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 20
	push	hl
	ld	hl, 320
	push	hl
	ld	hl, (ix - 88)
	push	hl
	or	a, a
	sbc	hl, hl
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
	ld	hl, (ix - 107)
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	hl, (ix - 85)
	ld	bc, (hl)
	ld	de, (ix - 104)
	push	de
	ld	de, 16
	push	de
	push	bc
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	l, 20
	ld	iy, (ix - 88)
	ld	a, iyl
	add	a, l
	ld	iyl, a
	lea	bc, iy + 0
	ld	hl, (ix - 101)
	ld	de, 20
	add	hl, de
	ld	iy, (ix - 85)
	lea	iy, iy + 3
	ld	(ix - 85), iy
	jp	.LBB49_6
	.local	.LBB49_10
.LBB49_10:                              ;   in Loop: Header=BB49_1 Depth=1
	ld	hl, 251
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 248
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	ld	a, (ix - 82)                    ; 1-byte Folded Reload
	or	a, a
	jr	nz, .LBB49_12
; %bb.11:                               ;   in Loop: Header=BB49_1 Depth=1
	ld	hl, 140
	push	hl
	ld	hl, 10
	push	hl
	ld	hl, _.str.16
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 158
	push	hl
	ld	hl, 10
	push	hl
	ld	hl, _.str.17
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 176
	push	hl
	ld	hl, 10
	push	hl
	ld	hl, _.str.18
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB49_12
.LBB49_12:                              ;   in Loop: Header=BB49_1 Depth=1
	ld	hl, _.str.19
	push	hl
	call	_ui_footer
	pop	hl
	ld	h, (ix - 95)                    ; 1-byte Folded Reload
	.local	.LBB49_13
.LBB49_13:                              ;   in Loop: Header=BB49_1 Depth=1
	ld	l, h
	push	hl
	call	_ui_present
	pop	hl
	call	_input_scan
	ld	hl, 1800
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB49_15
; %bb.14:                               ;   in Loop: Header=BB49_1 Depth=1
	ld	a, (ix - 82)                    ; 1-byte Folded Reload
	or	a, a
	ld	a, 1
	ld	h, a
	ld	a, 0
	jr	nz, .LBB49_19
	.local	.LBB49_15
.LBB49_15:                              ;   in Loop: Header=BB49_1 Depth=1
	ld	hl, 1793
	push	hl
	call	_input_repeat
	ld	l, a
	pop	de
	ld	a, (ix - 82)                    ; 1-byte Folded Reload
	or	a, a
	ld	e, -1
	jr	z, .LBB49_17
; %bb.16:                               ;   in Loop: Header=BB49_1 Depth=1
	ld	e, 0
	.local	.LBB49_17
.LBB49_17:                              ;   in Loop: Header=BB49_1 Depth=1
	ld	a, l
	and	a, e
	ld	h, a
	bit	0, h
	ld	a, 1
	jr	nz, .LBB49_19
; %bb.18:                               ;   in Loop: Header=BB49_1 Depth=1
	ld	a, (ix - 82)                    ; 1-byte Folded Reload
	.local	.LBB49_19
.LBB49_19:                              ;   in Loop: Header=BB49_1 Depth=1
	ld	(ix - 82), a                    ; 1-byte Folded Spill
	ld	a, (_current+6)
	ld	l, a
	ld	c, 1
	ld	a, l
	and	a, c
	ld	e, a
	bit	0, e
	jr	z, .LBB49_26
; %bb.20:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB49_1 Depth=1
	ld	a, (_previous+6)
	and	a, c
	ld	e, a
	bit	0, e
	jr	nz, .LBB49_26
; %bb.21:                               ;   in Loop: Header=BB49_1 Depth=1
	ld	a, (ix - 82)                    ; 1-byte Folded Reload
	or	a, a
	jr	nz, .LBB49_24
; %bb.22:                               ;   in Loop: Header=BB49_1 Depth=1
	ld	hl, _.str.21
	push	hl
	ld	hl, _.str.20
	push	hl
	call	_ui_confirm
	pop	hl
	pop	hl
	bit	0, a
	jr	z, .LBB49_25
; %bb.23:                               ;   in Loop: Header=BB49_1 Depth=1
	call	_lib_reset
	ld	de, 0
	ld	e, l
	ld	d, h
	push	de
	ld	hl, _.str.22
	push	hl
	ld	hl, (ix - 91)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	ld	hl, _.str.23
	push	hl
	ld	hl, (ix - 91)
	push	hl
	call	_ui_message
	pop	hl
	pop	hl
	jr	.LBB49_25
	.local	.LBB49_24
.LBB49_24:                              ;   in Loop: Header=BB49_1 Depth=1
	call	_ui_about_screen
	.local	.LBB49_25
.LBB49_25:                              ;   in Loop: Header=BB49_1 Depth=1
	call	_input_reset
	ld	a, (_current+6)
	ld	l, a
	ld	a, 1
	ld	h, a
	.local	.LBB49_26
.LBB49_26:                              ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB49_1 Depth=1
	bit	6, l
	jp	z, .LBB49_1
; %bb.27:                               ;   in Loop: Header=BB49_1 Depth=1
	ld	a, (_previous+6)
	bit	6, a
	jp	nz, .LBB49_1
; %bb.28:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end49
.Lfunc_end49:
	.size	_ui_setup_screen, .Lfunc_end49-_ui_setup_screen
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
	.local	.Lfunc_end50
.Lfunc_end50:
	.size	_ui_sync_screen, .Lfunc_end50-_ui_sync_screen
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
	ld	hl, _.str.24
	ldir
	call	_input_reset
	call	_gfx_End
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	call	_sync_draw
	ld	l, (ix + 6)
	push	hl
	ld	hl, _sync_progress
	push	hl
	call	_proto_run
	ld	(ix - 1), a                     ; 1-byte Folded Spill
	pop	hl
	pop	hl
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
	jr	nz, .LBB51_2
; %bb.1:
	ld	hl, _.str.25
	ld	de, _.str.26
	push	de
	push	hl
	call	_ui_message
	pop	hl
	pop	hl
	.local	.LBB51_2
.LBB51_2:
	inc	sp
	pop	ix
	ret
	.local	.Lfunc_end51
.Lfunc_end51:
	.size	_ui_sync_run, .Lfunc_end51-_ui_sync_run
                                        ; -- End function
	.section	.text._sync_draw,"ax",@progbits
	.type	_sync_draw,@function            ; -- Begin function sync_draw
_sync_draw:                             ; @sync_draw
; %bb.0:
	ld	hl, -43
	call	__frameset
	lea	hl, ix - 40
	ld	a, (_sync_echo_mode)
	bit	0, a
	ld	(ix - 43), hl
	jr	nz, .LBB52_2
; %bb.1:
	ld	hl, _.str.27
	jr	.LBB52_3
	.local	.LBB52_2
.LBB52_2:
	ld	hl, _.str.66
	.local	.LBB52_3
.LBB52_3:
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
	ld	de, 0
	ld	e, a
	ld	hl, (_bytes_moved)
	ld	c, 10
	call	__ishru
	push	hl
	push	de
	ld	hl, _.str.67
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
	ld	hl, _link_errors
	ld	hl, (hl)
	ld	bc, 0
	ld	c, l
	ld	b, h
	push	bc
	push	iy
	push	de
	ld	hl, _.str.68
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
	ld	hl, _.str.69
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
	ld	a, (_gc_count)
	ld	l, a
	or	a, a
	jr	z, .LBB52_5
; %bb.4:
	ld	de, _.str.70
	ld	bc, 0
	ld	c, l
	push	bc
	push	de
	ld	hl, (ix - 43)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 43)
	push	hl
	ld	hl, 4
	push	hl
	call	_sync_line
	pop	hl
	pop	hl
	.local	.LBB52_5
.LBB52_5:
	ld	a, (_library_state)
	cp	a, 2
	jr	z, .LBB52_7
; %bb.6:
	ld	hl, _.str.4.87
	jr	.LBB52_8
	.local	.LBB52_7
.LBB52_7:
	ld	hl, _.str.71
	.local	.LBB52_8
.LBB52_8:
	push	hl
	ld	hl, 7
	push	hl
	call	_sync_line
	pop	hl
	pop	hl
	ld	hl, _.str.72
	push	hl
	ld	hl, 8
	push	hl
	call	_sync_line
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end52
.Lfunc_end52:
	.size	_sync_draw, .Lfunc_end52-_sync_draw
                                        ; -- End function
	.section	.text._sync_progress,"ax",@progbits
	.type	_sync_progress,@function        ; -- Begin function sync_progress
_sync_progress:                         ; @sync_progress
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	iy, _requests_handled
	ld	hl, _sync_progress.drawn_requests
	ld	iy, (iy)
	push	hl
	pop	bc
	ld	de, (hl)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 3), de
	or	a, a
	sbc.sis	hl, de
	jr	z, .LBB53_2
; %bb.1:
	push	bc
	pop	hl
	push	de
	ld	e, iyl
	ld	d, iyh
	ld	(hl), e
	inc	hl
	ld	(hl), d
	pop	de
	ld	a, iyl
	ld	(_sync_chunks_received), a
	.local	.LBB53_2
.LBB53_2:
	ld	bc, (_loop_count)
	ld	de, (_sync_progress.drawn_at)
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	ld	de, 4096
	or	a, a
	sbc	hl, de
	jr	c, .LBB53_4
; %bb.3:
	ld	(_sync_progress.drawn_at), bc
	jr	.LBB53_5
	.local	.LBB53_4
.LBB53_4:
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	de, (ix - 3)
	or	a, a
	sbc.sis	hl, de
	jr	z, .LBB53_6
	.local	.LBB53_5
.LBB53_5:
	ld	hl, (ix + 6)
	ld	de, 32
	ld	bc, _.str.73
	push	hl
	push	bc
	push	de
	ld	hl, _sync_state
	push	hl
	call	_snprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	call	_sync_draw
	.local	.LBB53_6
.LBB53_6:
	ld	hl, _sync_progress.poll
	inc	(hl)
	ld	a, (hl)
	cp	a, 32
	jr	nc, .LBB53_8
; %bb.7:
	ld	l, 1
	jr	.LBB53_17
	.local	.LBB53_8
.LBB53_8:
	xor	a, a
	ld	(_sync_progress.poll), a
	call	_input_scan
	ld	a, (_current+1)
	cp	a, 0
	call	pe, __setflag
	jp	p, .LBB53_12
; %bb.9:                                ; %input_pressed.exit
	ld	a, (_previous+1)
	ld	e, a
	ld	a, (_library_state)
	ld	l, a
	ld	a, e
	cp	a, 0
	call	pe, __setflag
	jp	m, .LBB53_12
; %bb.10:                               ; %input_pressed.exit
	ld	a, l
	cp	a, 2
	jr	nz, .LBB53_12
; %bb.11:
	call	_lib_reset
	ld	de, _sync_state
	ld	hl, _.str.74
	ld	bc, 21
	ldir
	call	_sync_draw
	.local	.LBB53_12
.LBB53_12:                              ; %input_pressed.exit.thread
	ld	a, (_current+6)
	ld	l, a
	ld	a, (_previous+6)
	bit	6, a
	ld	a, -1
	ld	c, 0
	ld	e, a
	jr	nz, .LBB53_14
; %bb.13:                               ; %input_pressed.exit.thread
	ld	e, c
	.local	.LBB53_14
.LBB53_14:                              ; %input_pressed.exit.thread
	bit	6, l
	jr	z, .LBB53_16
; %bb.15:                               ; %input_pressed.exit.thread
	ld	a, c
	.local	.LBB53_16
.LBB53_16:                              ; %input_pressed.exit.thread
	or	a, e
	ld	l, a
	.local	.LBB53_17
.LBB53_17:
	ld	a, l
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end53
.Lfunc_end53:
	.size	_sync_progress, .Lfunc_end53-_sync_progress
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
	.local	.LBB54_1
.LBB54_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB54_6
; %bb.2:                                ;   in Loop: Header=BB54_1 Depth=1
	ld	c, a
	ld	hl, (ix + 9)
	add	hl, de
	ld	l, (hl)
	ld	a, l
	or	a, a
	jr	z, .LBB54_4
; %bb.3:                                ;   in Loop: Header=BB54_1 Depth=1
	ld	iy, (ix - 30)
	add	iy, de
	ld	(iy), l
	ld	iy, (ix - 30)
	inc	de
	ld	a, c
	ld	bc, 26
	jr	.LBB54_1
	.local	.LBB54_4
.LBB54_4:
	ld	a, c
	ld	bc, 26
	jr	.LBB54_6
	.local	.LBB54_5
.LBB54_5:                               ;   in Loop: Header=BB54_6 Depth=1
	lea	hl, iy + 0
	add	hl, de
	inc	de
	ld	(hl), 32
	.local	.LBB54_6
.LBB54_6:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB54_5
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
	.local	.Lfunc_end54
.Lfunc_end54:
	.size	_sync_line, .Lfunc_end54-_sync_line
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
	.local	.Lfunc_end55
.Lfunc_end55:
	.size	_proto_requests, .Lfunc_end55-_proto_requests
                                        ; -- End function
	.section	.text._proto_last_command,"ax",@progbits
	.globl	_proto_last_command             ; -- Begin function proto_last_command
	.type	_proto_last_command,@function
_proto_last_command:                    ; @proto_last_command
; %bb.0:
	ld	a, (_last_command)
	ret
	.local	.Lfunc_end56
.Lfunc_end56:
	.size	_proto_last_command, .Lfunc_end56-_proto_last_command
                                        ; -- End function
	.section	.text._proto_errors,"ax",@progbits
	.globl	_proto_errors                   ; -- Begin function proto_errors
	.type	_proto_errors,@function
_proto_errors:                          ; @proto_errors
; %bb.0:
	ld	hl, _link_errors
	ld	hl, (hl)
                                        ; kill: def $hl killed $hl killed $uhl
	ret
	.local	.Lfunc_end57
.Lfunc_end57:
	.size	_proto_errors, .Lfunc_end57-_proto_errors
                                        ; -- End function
	.section	.text._proto_open_error,"ax",@progbits
	.globl	_proto_open_error               ; -- Begin function proto_open_error
	.type	_proto_open_error,@function
_proto_open_error:                      ; @proto_open_error
; %bb.0:
	ld	a, (_open_error)
	ret
	.local	.Lfunc_end58
.Lfunc_end58:
	.size	_proto_open_error, .Lfunc_end58-_proto_open_error
                                        ; -- End function
	.section	.text._proto_loops,"ax",@progbits
	.globl	_proto_loops                    ; -- Begin function proto_loops
	.type	_proto_loops,@function
_proto_loops:                           ; @proto_loops
; %bb.0:
	ld	hl, (_loop_count)
	ret
	.local	.Lfunc_end59
.Lfunc_end59:
	.size	_proto_loops, .Lfunc_end59-_proto_loops
                                        ; -- End function
	.section	.text._proto_bytes,"ax",@progbits
	.globl	_proto_bytes                    ; -- Begin function proto_bytes
	.type	_proto_bytes,@function
_proto_bytes:                           ; @proto_bytes
; %bb.0:
	ld	hl, (_bytes_moved)
	ret
	.local	.Lfunc_end60
.Lfunc_end60:
	.size	_proto_bytes, .Lfunc_end60-_proto_bytes
                                        ; -- End function
	.section	.text._proto_library_state,"ax",@progbits
	.globl	_proto_library_state            ; -- Begin function proto_library_state
	.type	_proto_library_state,@function
_proto_library_state:                   ; @proto_library_state
; %bb.0:
	ld	a, (_library_state)
	ret
	.local	.Lfunc_end61
.Lfunc_end61:
	.size	_proto_library_state, .Lfunc_end61-_proto_library_state
                                        ; -- End function
	.section	.text._proto_collections,"ax",@progbits
	.globl	_proto_collections              ; -- Begin function proto_collections
	.type	_proto_collections,@function
_proto_collections:                     ; @proto_collections
; %bb.0:
	ld	a, (_gc_count)
	ret
	.local	.Lfunc_end62
.Lfunc_end62:
	.size	_proto_collections, .Lfunc_end62-_proto_collections
                                        ; -- End function
	.section	.text._proto_run,"ax",@progbits
	.globl	_proto_run                      ; -- Begin function proto_run
	.type	_proto_run,@function
_proto_run:                             ; @proto_run
; %bb.0:
	ld	hl, -19
	call	__frameset
	ld	iyl, 0
	ld	de, 0
	ld	b, d
	ld	hl, _requests_handled
	ld	a, iyl
	ld	(_serial_open), a
	ld	(_open_error), de
	ld	a, b
	ld	(_finished), a
	ld	(ix - 9), c
	ld	(ix - 8), b
	ld	(_closing), a
	ld	(_link_state), de
	ld	a, iyl
	ld	(_header_have), a
	ld.sis	bc, 0
	ld	(hl), c
	inc	hl
	ld	(hl), b
	ld	(_last_command), a
	ld	hl, _link_errors
	ld	(hl), c
	inc	hl
	ld	(hl), b
	ld	(_loop_count), de
	ld	(_bytes_moved), de
	ld	(_library_state), a
	ld	iy, -3145600
	call	_os_ArcChk
	ld	hl, (-3135915)
	ld	(_cached_archive_free), hl
	or	a, a
	sbc	hl, hl
	ld	(_cached_index), hl
	ld	hl, _cached_index_size
	ld.sis	de, 0
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	hl, _.str.2.47
	push	hl
	ld	hl, _.str.1.46
	push	hl
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB63_2
; %bb.1:
	push	de
	ld	(ix - 7), de
	call	_ti_GetSize
	pop	de
	ld	iy, _cached_index_size
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 7)
	push	hl
	call	_ti_GetDataPtr
	pop	de
	ld	(_cached_index), hl
	ld	hl, (ix - 7)
	push	hl
	call	_ti_Close
	pop	hl
	.local	.LBB63_2
.LBB63_2:
	xor	a, a
	ld	(_gc_count), a
	ld	hl, _gc_after.49
	push	hl
	ld	hl, _gc_before.48
	push	hl
	call	_ti_SetGCBehavior
	pop	hl
	pop	hl
	ld	hl, 16384
	push	hl
	call	_malloc
	pop	de
	ld	(_payload), hl
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
	pop	de
	pop	de
	pop	de
	pop	de
	ld	(ix - 7), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	nz, .LBB63_46
; %bb.3:
	ld	iy, _reply_body_sent
	lea	hl, iy + 3
	ld	(ix - 12), hl
	.local	.LBB63_4
.LBB63_4:                               ; =>This Inner Loop Header: Depth=1
	ld	a, (_finished)
	bit	0, a
	jp	nz, .LBB63_46
; %bb.5:                                ;   in Loop: Header=BB63_4 Depth=1
	ld	hl, (_loop_count)
	inc	hl
	ld	(_loop_count), hl
	call	_usb_HandleEvents
	ld	a, (_serial_open)
	bit	0, a
	jr	z, .LBB63_9
; %bb.6:                                ;   in Loop: Header=BB63_4 Depth=1
	bit	0, (ix + 9)
	jp	z, .LBB63_15
; %bb.7:                                ;   in Loop: Header=BB63_4 Depth=1
	ld	hl, 256
	push	hl
	ld	hl, _discard_scratch
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
	jp	p, .LBB63_20
	.local	.LBB63_8
.LBB63_8:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	iy, _link_errors
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	xor	a, a
	ld	(_serial_open), a
	sbc	hl, hl
	ld	(_link_state), hl
	ld	(_header_have), a
	.local	.LBB63_9
.LBB63_9:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	hl, (ix + 6)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB63_4
; %bb.10:                               ;   in Loop: Header=BB63_4 Depth=1
	bit	0, (ix + 9)
	ld	hl, _.str.75
	jr	nz, .LBB63_14
; %bb.11:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.4.76
	jr	z, .LBB63_14
; %bb.12:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	de, (_link_state)
	dec	de
	push	de
	pop	hl
	ld	bc, 3
	or	a, a
	sbc	hl, bc
	ld	hl, _.str.8.77
	jr	nc, .LBB63_14
; %bb.13:                               ;   in Loop: Header=BB63_4 Depth=1
	ex	de, hl
	call	__imulu
	ex	de, hl
	ld	hl, _switch.table.proto_run
	add	hl, de
	ld	hl, (hl)
	.local	.LBB63_14
.LBB63_14:                              ;   in Loop: Header=BB63_4 Depth=1
	ld	de, 0
	push	de
	push	de
	push	de
	push	hl
	ld	hl, (ix + 6)
	call	__indcallhl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	jp	nz, .LBB63_4
	jp	.LBB63_46
	.local	.LBB63_15
.LBB63_15:                              ;   in Loop: Header=BB63_4 Depth=1
	ld	de, (_link_state)
	ld	hl, JTI63_0
	add	hl, de
	add	hl, de
	add	hl, de
	ld	hl, (hl)
	ld	de, 0
	ld	iy, _payload_have
	lea	bc, iy + 3
	jp	(hl)
	.local	.LBB63_16
.LBB63_16:                              ;   in Loop: Header=BB63_4 Depth=1
	ld	(ix - 13), e                    ; 1-byte Folded Spill
	ld	a, (_header_have)
	ld	de, 0
	ld	e, a
	ld	iy, _header
	add	iy, de
	ld	hl, 8
	or	a, a
	sbc	hl, de
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
	jp	m, .LBB63_8
; %bb.17:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	a, (_header_have)
	ld	l, e
	add	a, l
	ld	l, a
	ld	(_header_have), a
	cp	a, 8
	jp	c, .LBB63_9
; %bb.18:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	d, 0
	ld	a, d
	ld	(_header_have), a
	ld	a, (_header)
	ld	(_command), a
	ld	a, (_header+1)
	ld	(_sequence), a
	ld	a, (_header+2)
	ld	e, (ix - 9)
	ld	d, (ix - 8)
	ld	e, a
	ld	(ix - 9), e
	ld	(ix - 8), d
	ld	a, (_header+3)
	ld	l, a
	ld	h, d
	ld	h, l
	ld	l, d
	add.sis	hl, de
	ld	iy, _argument
	ld	(iy), l
	ld	(iy + 1), h
	ld	a, (_header+4)
	ld	(ix - 4), d
	ld	iy, (ix - 6)
	ld	iyh, d
	ld	iyl, a
	ld	a, (_header+5)
	ld	(ix - 3), d
	ld	bc, (ix - 5)
	ld	b, d
	ld	c, a
	ld	d, (ix - 13)                    ; 1-byte Folded Reload
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
	ld	a, (_header+6)
	ld	l, (ix - 9)
	ld	h, (ix - 8)
	ld	(ix - 2), h
	ld	bc, (ix - 4)
	ld	b, h
	ld	c, a
	ld	a, d
	ld	l, 16
	call	__lshl
	lea	hl, iy + 0
	call	__ladd
	push	hl
	pop	iy
	ld	a, (_header+7)
	ld	l, (ix - 9)
	ld	h, (ix - 8)
	ld	(ix - 1), h
	ld	bc, (ix - 3)
	ld	b, h
	ld	c, a
	ld	a, d
	ld	d, 0
	ld	l, 24
	call	__lshl
	lea	hl, iy + 0
	call	__ladd
	ld	(_payload_want), hl
	ld	a, e
	ld	(_payload_want+3), a
	ld	bc, 0
	ld	(_payload_have), bc
	ld	a, d
	ld	(_payload_have+3), a
	call	__lcmpzero
	jp	nz, .LBB63_41
; %bb.19:                               ;   in Loop: Header=BB63_4 Depth=1
	call	_execute
	jp	.LBB63_9
	.local	.LBB63_20
.LBB63_20:                              ;   in Loop: Header=BB63_4 Depth=1
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB63_9
; %bb.21:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	iy, _requests_handled
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	a, (_discard_scratch)
	ld	(_last_command), a
	push	de
	ld	hl, _discard_scratch
	push	hl
	ld	hl, _serial
	push	hl
	call	_srl_Write
	pop	de
	pop	de
	pop	de
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB63_8
	jp	.LBB63_9
	.local	.LBB63_22
.LBB63_22:                              ;   in Loop: Header=BB63_4 Depth=1
	ld	(ix - 16), bc
	ld	(ix - 13), e                    ; 1-byte Folded Spill
	ld	hl, (_payload_want)
	ld	a, (_payload_want+3)
	ld	e, a
	ld	bc, (_payload_have)
	ld	a, (_payload_have+3)
	call	__lsub
	ld	bc, 256
	xor	a, a
	call	__lcmpu
	jr	c, .LBB63_24
; %bb.23:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	hl, 256
	.local	.LBB63_24
.LBB63_24:                              ;   in Loop: Header=BB63_4 Depth=1
	push	hl
	ld	hl, _discard_scratch
	push	hl
	ld	hl, _serial
	push	hl
	call	_srl_Read
	push	hl
	pop	bc
	pop	hl
	pop	hl
	pop	hl
	push	bc
	pop	hl
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB63_8
; %bb.25:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	hl, (_payload_have)
	ld	iy, (ix - 16)
	ld	e, (iy)
	ld	a, (ix - 13)                    ; 1-byte Folded Reload
	call	__ladd
	ld	(_payload_have), hl
	ld	a, e
	ld	(_payload_have+3), a
	ld	bc, (_payload_want)
	ld	a, (_payload_want+3)
	call	__lcmpu
	jp	c, .LBB63_9
; %bb.26:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	iy, _requests_handled
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	a, (_command)
	ld	(_last_command), a
	or	a, a
	sbc	hl, hl
	push	hl
	ld	de, 0
	push	de
	push	hl
	ld	hl, 2
	push	hl
	call	_answer
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	jp	.LBB63_9
	.local	.LBB63_27
.LBB63_27:                              ;   in Loop: Header=BB63_4 Depth=1
	ld	a, (_reply_header_sent)
	cp	a, 8
	jp	nc, .LBB63_34
; %bb.28:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	de, 0
	ld	e, a
	ld	iy, _reply_header
	add	iy, de
	ld	hl, 8
	or	a, a
	sbc	hl, de
	push	hl
	push	iy
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
	call	pe, __setflag
	jp	m, .LBB63_8
; %bb.29:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	a, (_reply_header_sent)
	ld	l, e
	add	a, l
	ld	l, a
	ld	(_reply_header_sent), a
	jp	.LBB63_9
	.local	.LBB63_30
.LBB63_30:                              ;   in Loop: Header=BB63_4 Depth=1
	ld	(ix - 16), bc
	ld	(ix - 13), e                    ; 1-byte Folded Spill
	ld	hl, (_payload_want)
	ld	a, (_payload_want+3)
	ld	e, a
	ld	bc, (_payload_have)
	ld	a, (_payload_have+3)
	ld	(ix - 19), bc
	call	__lsub
	ld	bc, 2048
	xor	a, a
	call	__lcmpu
	jr	c, .LBB63_32
; %bb.31:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	hl, 2048
	.local	.LBB63_32
.LBB63_32:                              ;   in Loop: Header=BB63_4 Depth=1
	ld	iy, (_payload)
	ld	de, (ix - 19)
	add	iy, de
	push	hl
	push	iy
	ld	hl, _serial
	push	hl
	call	_srl_Read
	push	hl
	pop	bc
	pop	hl
	pop	hl
	pop	hl
	push	bc
	pop	hl
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB63_8
; %bb.33:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	hl, (_payload_have)
	ld	iy, (ix - 16)
	ld	e, (iy)
	ld	a, (ix - 13)                    ; 1-byte Folded Reload
	call	__ladd
	ld	(_payload_have), hl
	ld	a, e
	ld	(_payload_have+3), a
	ld	iy, (_bytes_moved)
	add	iy, bc
	ld	(_bytes_moved), iy
	ld	bc, (_payload_want)
	ld	a, (_payload_want+3)
	call	__lcmpu
	call	nc, _execute
	jp	.LBB63_9
	.local	.LBB63_34
.LBB63_34:                              ;   in Loop: Header=BB63_4 Depth=1
	ld	(ix - 13), e                    ; 1-byte Folded Spill
	ld	iy, (_reply_body_sent)
	ld	a, (_reply_body_sent+3)
	ld	d, a
	ld	bc, (_reply_body_len)
	ld	a, (_reply_body_len+3)
	lea	hl, iy + 0
	ld	e, d
	call	__lcmpu
	jr	nc, .LBB63_39
; %bb.35:                               ;   in Loop: Header=BB63_4 Depth=1
	push	bc
	pop	hl
	ld	e, a
	ld	(ix - 16), iy
	lea	bc, iy + 0
	ld	a, d
	call	__lsub
	ld	bc, 2048
	xor	a, a
	call	__lcmpu
	jr	c, .LBB63_37
; %bb.36:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	hl, 2048
	.local	.LBB63_37
.LBB63_37:                              ;   in Loop: Header=BB63_4 Depth=1
	ld	iy, (_reply_body)
	ld	de, (ix - 16)
	add	iy, de
	push	hl
	push	iy
	ld	hl, _serial
	push	hl
	call	_srl_Write
	push	hl
	pop	bc
	pop	hl
	pop	hl
	pop	hl
	push	bc
	pop	hl
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB63_8
; %bb.38:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	hl, (_reply_body_sent)
	ld	iy, (ix - 12)
	ld	e, (iy)
	ld	a, (ix - 13)                    ; 1-byte Folded Reload
	call	__ladd
	ld	a, e
	ld	(_reply_body_sent), hl
	ld	(_reply_body_sent+3), a
	ld	hl, (_bytes_moved)
	add	hl, bc
	ld	(_bytes_moved), hl
	jp	.LBB63_9
	.local	.LBB63_39
.LBB63_39:                              ;   in Loop: Header=BB63_4 Depth=1
	or	a, a
	sbc	hl, hl
	ld	(_link_state), hl
	ld	a, (_closing)
	bit	0, a
	jp	z, .LBB63_9
; %bb.40:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	a, 1
	ld	(_finished), a
	jp	.LBB63_9
	.local	.LBB63_41
.LBB63_41:                              ;   in Loop: Header=BB63_4 Depth=1
	ld	iy, (_payload)
	ld	bc, 16385
	ld	a, d
	call	__lcmpu
	jr	nc, .LBB63_44
; %bb.42:                               ;   in Loop: Header=BB63_4 Depth=1
	lea	hl, iy + 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB63_44
; %bb.43:                               ;   in Loop: Header=BB63_4 Depth=1
	ld	hl, 1
	jr	.LBB63_45
	.local	.LBB63_44
.LBB63_44:                              ;   in Loop: Header=BB63_4 Depth=1
	ld	hl, 2
	.local	.LBB63_45
.LBB63_45:                              ;   in Loop: Header=BB63_4 Depth=1
	ld	(_link_state), hl
	jp	.LBB63_9
	.local	.LBB63_46
.LBB63_46:                              ; %.loopexit
	call	_usb_Cleanup
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_ti_SetGCBehavior
	pop	hl
	pop	hl
	ld	hl, (_payload)
	push	hl
	call	_free
	pop	hl
	or	a, a
	sbc	hl, hl
	ld	(_payload), hl
	ld	hl, (ix - 7)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB63_48
; %bb.47:                               ; %.loopexit
	ld	a, 0
	jr	.LBB63_49
	.local	.LBB63_48
.LBB63_48:
	ld	a, -1
	.local	.LBB63_49
.LBB63_49:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end63
.Lfunc_end63:
	.size	_proto_run, .Lfunc_end63-_proto_run
	.section	.rodata._proto_run,"a",@progbits
JTI63_0:
	d24	.LBB63_16
	d24	.LBB63_30
	d24	.LBB63_22
	d24	.LBB63_27
                                        ; -- End function
	.section	.text._gc_before.48,"ax",@progbits
	.type	_gc_before.48,@function         ; -- Begin function gc_before.48
_gc_before.48:                          ; @gc_before.48
; %bb.0:
	ld	hl, -17
	call	__frameset
	ld	hl, _gc_count
	inc	(hl)
	ld	a, (_serial_open)
	bit	0, a
	jp	z, .LBB64_6
; %bb.1:
	or	a, a
	sbc	hl, hl
	ld	(ix - 11), hl
	ld	hl, 8
	ld	(ix - 14), hl
	lea	iy, ix - 8
	ld	(ix - 8), -2
	ld	a, (_sequence)
	ld	(ix - 7), a
	ld	(ix - 17), iy
	lea	hl, iy + 2
	ld	(ix - 6), 0
	push	hl
	pop	de
	inc	de
	ld	bc, 5
	ldir
	ld	bc, 4096
	.local	.LBB64_2
.LBB64_2:                               ; =>This Inner Loop Header: Depth=1
	ld	hl, (ix - 11)
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB64_6
; %bb.3:                                ;   in Loop: Header=BB64_2 Depth=1
	ld	hl, (ix - 14)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB64_6
; %bb.4:                                ;   in Loop: Header=BB64_2 Depth=1
	call	_usb_HandleEvents
	ld	hl, (ix - 14)
	push	hl
	ld	hl, (ix - 17)
	push	hl
	ld	hl, _serial
	push	hl
	call	_srl_Write
	ld	bc, 4096
	pop	de
	pop	de
	pop	de
	push	hl
	pop	iy
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB64_6
; %bb.5:                                ;   in Loop: Header=BB64_2 Depth=1
	ld	hl, (ix - 14)
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	ld	(ix - 14), hl
	ld	hl, (ix - 17)
	add	hl, de
	ld	(ix - 17), hl
	ld	hl, (ix - 11)
	inc	hl
	ld	(ix - 11), hl
	jr	.LBB64_2
	.local	.LBB64_6
.LBB64_6:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end64
.Lfunc_end64:
	.size	_gc_before.48, .Lfunc_end64-_gc_before.48
                                        ; -- End function
	.section	.text._gc_after.49,"ax",@progbits
	.type	_gc_after.49,@function          ; -- Begin function gc_after.49
_gc_after.49:                           ; @gc_after.49
; %bb.0:
	ld	hl, -3
	call	__frameset
	call	_lib_open
	or	a, a
	sbc	hl, hl
	ld	(_cached_index), hl
	ld	iy, _cached_index_size
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, _.str.2.47
	push	hl
	ld	hl, _.str.1.46
	push	hl
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB65_2
; %bb.1:
	push	de
	ld	(ix - 3), de
	call	_ti_GetSize
	pop	de
	ld	iy, _cached_index_size
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 3)
	push	hl
	call	_ti_GetDataPtr
	pop	de
	ld	(_cached_index), hl
	ld	hl, (ix - 3)
	push	hl
	call	_ti_Close
	pop	hl
	.local	.LBB65_2
.LBB65_2:
	ld	iy, -3145600
	call	_os_ArcChk
	ld	hl, (-3135915)
	ld	(_cached_archive_free), hl
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end65
.Lfunc_end65:
	.size	_gc_after.49, .Lfunc_end65-_gc_after.49
                                        ; -- End function
	.section	.text._handle_event,"ax",@progbits
	.type	_handle_event,@function         ; -- Begin function handle_event
_handle_event:                          ; @handle_event
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	bc, (ix + 6)
	ld	hl, (ix + 9)
	ld	de, (ix + 12)
	push	de
	push	hl
	push	bc
	call	_srl_UsbEventCallback
	push	hl
	pop	bc
	pop	hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, bc
	jr	nz, .LBB66_5
; %bb.1:
	ld	de, 1
	ld	iy, (ix + 6)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jr	z, .LBB66_4
; %bb.2:
	ld	de, 3
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jr	z, .LBB66_4
; %bb.3:
	ld	de, 8
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jr	nz, .LBB66_6
	.local	.LBB66_4
.LBB66_4:
	or	a, a
	sbc	hl, hl
	xor	a, a
	ld	(_serial_open), a
	ld	(_link_state), hl
	ld	(_header_have), a
	.local	.LBB66_5
.LBB66_5:
	push	bc
	pop	hl
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB66_6
.LBB66_6:
	ld	(ix - 3), bc
	ld	bc, 12
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	ld	bc, (ix - 3)
	jr	nz, .LBB66_5
; %bb.7:
	ld	a, (_serial_open)
	bit	0, a
	jr	nz, .LBB66_5
; %bb.8:
	push	de
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_usb_FindDevice
	ld	bc, (ix - 3)
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB66_5
; %bb.9:
	ld	iy, _serial_buffer
	ld	bc, 2048
	ld	hl, 9600
	push	hl
	ld	hl, 255
	push	hl
	push	bc
	push	iy
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
	jr	z, .LBB66_11
; %bb.10:
	ld	a, 0
	jr	.LBB66_12
	.local	.LBB66_11
.LBB66_11:
	ld	a, 1
	.local	.LBB66_12
.LBB66_12:
	ld	(_serial_open), a
	ld	bc, (ix - 3)
	jr	.LBB66_5
	.local	.Lfunc_end66
.Lfunc_end66:
	.size	_handle_event, .Lfunc_end66-_handle_event
                                        ; -- End function
	.section	.text._execute,"ax",@progbits
	.type	_execute,@function              ; -- Begin function execute
_execute:                               ; @execute
; %bb.0:
	ld	hl, -36
	call	__frameset
	ld	hl, _requests_handled
	ld	bc, 0
	ld	iy, 1
	ld	de, (hl)
	inc.sis	de
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	a, (_command)
	ld	(_last_command), a
	dec	a
	or	a, a
	sbc	hl, hl
	cp	a, 9
	jr	c, .LBB67_6
; %bb.1:
	push	hl
	push	bc
	.local	.LBB67_2
.LBB67_2:
	or	a, a
	sbc	hl, hl
	.local	.LBB67_3
.LBB67_3:
	push	hl
	.local	.LBB67_4
.LBB67_4:
	push	iy
	.local	.LBB67_5
.LBB67_5:
	call	_answer
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB67_6
.LBB67_6:
	ld	bc, _reply_small
	push	hl
	pop	iy
	lea	de, iy + 0
	ld	e, a
	ld	hl, JTI67_0
	add	hl, de
	add	hl, de
	add	hl, de
	ld	hl, (hl)
	jp	(hl)
	.local	.LBB67_7
.LBB67_7:
	ld	e, 0
	ld	c, 1
	ld	d, 64
	ld	hl, (_index_data)
	push	hl
	pop	iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB67_43
; %bb.8:
	ld	hl, 15
	ld	bc, (_payload_want)
	ld	a, (_payload_want+3)
	call	__lcmpu
	jp	nc, .LBB67_36
; %bb.9:
	ld	hl, 16
	ld	de, (_payload)
	push	hl
	push	de
	pea	iy + 12
	call	_memcmp
	pop	de
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB67_41
; %bb.10:
	ld	a, 0
	jp	.LBB67_42
	.local	.LBB67_11
.LBB67_11:
	ld	bc, _cached_index_size
	ld	de, (_cached_index)
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB67_20
; %bb.12:
	push	bc
	pop	hl
	ld	bc, (hl)
	sbc.sis	hl, hl
	adc.sis	hl, bc
	jr	z, .LBB67_20
; %bb.13:
	lea	hl, iy + 0
	ld	l, c
	ld	h, b
	push	iy
	jp	.LBB67_28
	.local	.LBB67_14
.LBB67_14:
	ld	hl, _argument
	lea	bc, ix - 17
	ld	(ix - 21), bc
	ld	hl, (hl)
	ld	e, h
	push	de
	push	hl
	push	bc
	call	_csx_chunk_name
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (_payload_want)
	ld	a, (_payload_want+3)
	ld	e, a
	push	de
	push	hl
	ld	hl, (ix - 21)
	push	hl
	call	_store
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	ld.sis	de, 0
	jr	nz, .LBB67_16
; %bb.15:
	ld.sis	de, 3
	.local	.LBB67_16
.LBB67_16:
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	jp	.LBB67_30
	.local	.LBB67_17
.LBB67_17:
	ld	a, (_argument)
	ld	l, a
	push	hl
	call	_csx_delete
	pop	hl
	ld	(_reply_small), a
	or	a, a
	jp	z, .LBB67_31
; %bb.18:
	or	a, a
	sbc	hl, hl
	ld.sis	de, 0
	push	de
	pop	iy
	jp	.LBB67_32
	.local	.LBB67_19
.LBB67_19:
	ld	a, 1
	ld	(_closing), a
	.local	.LBB67_20
.LBB67_20:
	push	iy
	or	a, a
	sbc	hl, hl
	push	hl
	jp	.LBB67_2
	.local	.LBB67_21
.LBB67_21:
	ld.sis	hl, 0
	ld	(ix - 21), hl
	ld	hl, _strip_count
	ld	bc, 14
	lea	de, iy + 0
	ld	iy, (hl)
	xor	a, a
	ld	(ix - 18), a
	ld	hl, (ix - 20)
	ex	de, hl
	ld	d, iyh
	ld	e, iyl
	ex	de, hl
	call	__lmulu
	ld	bc, 2
	call	__ladd
	push	hl
	pop	bc
                                        ; kill: def $e killed $e def $ude
	ld	(ix - 27), de
	ld	hl, (_payload)
	ld	(ix - 24), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB67_23
; %bb.22:
	ld.sis	de, 1171
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, de
	jp	c, .LBB67_37
	.local	.LBB67_23
.LBB67_23:
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	push	hl
	ld	hl, 4
	jp	.LBB67_35
	.local	.LBB67_24
.LBB67_24:
	ld	bc, _.str.1.46
	ld	hl, (_payload_want)
	ld	a, (_payload_want+3)
	ld	e, a
	push	de
	push	hl
	push	bc
	call	_store
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	jp	z, .LBB67_33
; %bb.25:
	call	_lib_open
	or	a, a
	sbc	hl, hl
	ld	(_cached_index), hl
	ld	de, _cached_index_size
	push	de
	pop	iy
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, _.str.2.47
	push	hl
	ld	hl, _.str.1.46
	push	hl
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	ld	bc, 0
	push	bc
	pop	hl
	jp	z, .LBB67_34
; %bb.26:
	push	de
	ld	(ix - 21), de
	call	_ti_GetSize
	pop	de
	ld	iy, _cached_index_size
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 21)
	push	hl
	call	_ti_GetDataPtr
	pop	de
	ld	(_cached_index), hl
	ld	hl, (ix - 21)
	push	hl
	call	_ti_Close
	ld	bc, 0
	pop	hl
	push	bc
	pop	hl
	jr	.LBB67_34
	.local	.LBB67_27
.LBB67_27:
	ld	hl, (_cached_archive_free)
	ld	a, l
	ld	(_reply_small), a
	ld	a, h
	ld	(_reply_small+1), a
	push	bc
	pop	de
	ld	c, 16
	call	__ishru
	ld	a, l
	ld	(_reply_small+2), a
	push	iy
	ld	hl, 3
	.local	.LBB67_28
.LBB67_28:
	push	hl
	push	de
	jp	.LBB67_4
	.local	.LBB67_29
.LBB67_29:
	call	_lib_reset
	xor	a, a
	ld	(_library_state), a
	ld	de, 0
	ld	(_cached_index), de
	ld	iy, _cached_index_size
	ld	(iy), e
	ld	(iy + 1), d
	ld	a, l
	ld	(_reply_small), a
	ld	a, h
	ld	(_reply_small+1), a
	push	de
	ld	hl, 2
	push	hl
	ld	hl, _reply_small
	.local	.LBB67_30
.LBB67_30:
	push	hl
	push	de
	jp	.LBB67_5
	.local	.LBB67_31
.LBB67_31:
	ld.sis	iy, 5
	or	a, a
	sbc	hl, hl
	.local	.LBB67_32
.LBB67_32:
	ld	bc, _reply_small
	ld	de, 1
	push	hl
	push	de
	push	bc
	jp	.LBB67_4
	.local	.LBB67_33
.LBB67_33:
	ld	hl, 4
	ld	bc, 0
	.local	.LBB67_34
.LBB67_34:
	ld	de, 0
	push	de
	push	bc
	push	de
	.local	.LBB67_35
.LBB67_35:
	push	hl
	jp	.LBB67_5
	.local	.LBB67_36
.LBB67_36:
	ld	e, 2
	ld	c, 1
	jp	.LBB67_43
	.local	.LBB67_37
.LBB67_37:
	ld	(ix - 33), bc
	ld	a, iyl
	ld	de, (ix - 24)
	push	de
	pop	hl
	ld	(hl), a
	ld	a, iyh
	lea	bc, iy + 0
	push	de
	pop	iy
	ld	(iy + 1), a
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	bc, 14
	call	__imulu
	push	hl
	pop	bc
	ld	de, 0
	.local	.LBB67_38
.LBB67_38:                              ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB67_40
; %bb.39:                               ;   in Loop: Header=BB67_38 Depth=1
	pea	ix - 17
	ld	hl, (ix - 21)
	push	hl
	ld	(ix - 30), de
	ld	(ix - 36), bc
	call	_lib_get_strip
	pop	hl
	pop	hl
	ld	iy, (ix - 24)
	ld	de, (ix - 30)
	add	iy, de
	ld	a, (ix - 17)
	ld	(iy + 2), a
	ld	a, (ix - 16)
	ld	(iy + 3), a
	ld	hl, (ix - 15)
	ld	a, l
	ld	(iy + 4), a
	ld	a, h
	ld	(iy + 5), a
	ld	a, 16
	ld	c, a
	call	__ishru
	ld	a, l
	ld	(iy + 6), a
	ld	a, (ix - 12)
	ld	(iy + 7), a
	ld	de, (ix - 11)
	ld	h, (ix - 8)
	ld	a, e
	ld	(iy + 8), a
	ld	a, d
	ld	(iy + 9), a
	push	de
	pop	bc
	ld	a, h
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 10), a
	push	de
	pop	bc
	ld	a, h
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	(iy + 11), a
	ld	hl, (ix - 7)
	ld	a, l
	ld	(iy + 12), a
	ld	a, h
	ld	(iy + 13), a
	ld	c, 16
	call	__ishru
	ld	bc, (ix - 36)
	ld	a, l
	ld	(iy + 14), a
	ld	a, (ix - 4)
	ld	(iy + 15), a
	ld	hl, (ix - 21)
	inc.sis	hl
	ld	(ix - 21), hl
	ld	hl, (ix - 30)
	ld	de, 14
	add	hl, de
	ex	de, hl
	jp	.LBB67_38
	.local	.LBB67_40
.LBB67_40:
	ld	hl, (ix - 27)
	push	hl
	ld	hl, (ix - 33)
	push	hl
	ld	hl, (ix - 24)
	push	hl
	or	a, a
	sbc	hl, hl
	jp	.LBB67_35
	.local	.LBB67_41
.LBB67_41:
	ld	a, -1
	.local	.LBB67_42
.LBB67_42:
	ld	d, 64
	ld	c, 1
	ld	l, 2
	add	a, l
	ld	e, a
	.local	.LBB67_43
.LBB67_43:
	ld	a, e
	ld	(_library_state), a
	ld	a, c
	ld	(_reply_small), a
	ld	hl, (_cached_archive_free)
	ld	a, l
	ld	(_reply_small+1), a
	ld	a, h
	ld	(_reply_small+2), a
	ld	c, 16
	call	__ishru
	ld	a, l
	ld	(_reply_small+3), a
	ld	a, d
	ld	(_reply_small+4), a
	ld	(_reply_small+5), a
	ld	a, e
	ld	(_reply_small+6), a
	ld	iy, 0
	push	iy
	ld	hl, 7
	push	hl
	ld	hl, _reply_small
	jp	.LBB67_3
	.local	.Lfunc_end67
.Lfunc_end67:
	.size	_execute, .Lfunc_end67-_execute
	.section	.rodata._execute,"a",@progbits
JTI67_0:
	d24	.LBB67_7
	d24	.LBB67_21
	d24	.LBB67_14
	d24	.LBB67_17
	d24	.LBB67_11
	d24	.LBB67_24
	d24	.LBB67_27
	d24	.LBB67_19
	d24	.LBB67_29
                                        ; -- End function
	.section	.text._answer,"ax",@progbits
	.type	_answer,@function               ; -- Begin function answer
_answer:                                ; @answer
; %bb.0:
	call	__frameset0
	ld	l, (ix + 6)
	ld	bc, (ix + 9)
	ld	iy, (ix + 12)
	ld	e, 0
	ld	a, (_command)
	ld	(_reply_header), a
	ld	a, (_sequence)
	ld	(_reply_header+1), a
	ld	a, l
	ld	(_reply_header+2), a
	ld	a, e
	ld	(_reply_header+3), a
	ld	a, iyl
	ld	(_reply_header+4), a
	ld	a, iyh
	ld	(_reply_header+5), a
	ld	a, e
	ld	(_reply_header+6), a
	ld	(_reply_header+7), a
	ld	(_reply_header_sent), a
	ld	(_reply_body), bc
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB68_2
; %bb.1:
	ld	a, 0
	jr	.LBB68_3
	.local	.LBB68_2
.LBB68_2:
	ld	a, -1
	.local	.LBB68_3
.LBB68_3:
	ld	bc, 0
	bit	0, a
	push	bc
	pop	hl
	jr	nz, .LBB68_5
; %bb.4:
	lea	hl, iy + 0
	.local	.LBB68_5
.LBB68_5:
	ld	iy, 3
	bit	0, a
	ld	a, e
	jr	nz, .LBB68_7
; %bb.6:
	ld	a, (ix + 15)
	.local	.LBB68_7
.LBB68_7:
	ld	(_reply_body_len), hl
	ld	(_reply_body_len+3), a
	ld	(_reply_body_sent), bc
	ld	a, e
	ld	(_reply_body_sent+3), a
	ld	(_link_state), iy
	pop	ix
	ret
	.local	.Lfunc_end68
.Lfunc_end68:
	.size	_answer, .Lfunc_end68-_answer
                                        ; -- End function
	.section	.text._store,"ax",@progbits
	.type	_store,@function                ; -- Begin function store
_store:                                 ; @store
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	hl, (ix + 6)
	push	hl
	call	_ti_Delete
	pop	hl
	ld	hl, _.str.3.81
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_ti_Open
	ld	c, a
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB69_6
; %bb.1:
	ld	iy, (ix + 9)
	ld	hl, 1
	ld	de, (_payload)
	ld	(ix - 3), bc
	push	bc
	push	hl
	push	iy
	push	de
	call	_ti_Write
	pop	de
	pop	de
	pop	de
	pop	de
	ld	de, 1
	or	a, a
	sbc	hl, de
	jr	nz, .LBB69_4
; %bb.2:
	ld	hl, (ix - 3)
	push	hl
	push	de
	call	_ti_SetArchiveStatus
	ld	(ix - 6), hl
	pop	hl
	pop	hl
	ld	hl, (ix - 3)
	push	hl
	call	_ti_Close
	pop	hl
	ld	hl, (ix - 6)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB69_5
; %bb.3:
	ld	a, 1
	jr	.LBB69_7
	.local	.LBB69_4
.LBB69_4:
	ld	hl, (ix - 3)
	push	hl
	call	_ti_Close
	pop	hl
	.local	.LBB69_5
.LBB69_5:
	ld	hl, (ix + 6)
	push	hl
	call	_ti_Delete
	pop	hl
	.local	.LBB69_6
.LBB69_6:
	xor	a, a
	.local	.LBB69_7
.LBB69_7:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end69
.Lfunc_end69:
	.size	_store, .Lfunc_end69-_store
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
	jp	z, .LBB70_70
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
	jr	c, .LBB70_3
; %bb.2:
	ld	(iy + 5), 0
	.local	.LBB70_3
.LBB70_3:
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
	.local	.LBB70_4
.LBB70_4:                               ; %input_pressed.exit7
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
	jp	z, .LBB70_16
; %bb.5:                                ;   in Loop: Header=BB70_4 Depth=1
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
	jp	z, .LBB70_15
; %bb.6:                                ;   in Loop: Header=BB70_4 Depth=1
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
	jr	c, .LBB70_10
; %bb.7:                                ;   in Loop: Header=BB70_4 Depth=1
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
	jr	nc, .LBB70_9
; %bb.8:                                ;   in Loop: Header=BB70_4 Depth=1
	ld	hl, 10
	push	hl
	pop	bc
	.local	.LBB70_9
.LBB70_9:                               ;   in Loop: Header=BB70_4 Depth=1
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
	.local	.LBB70_10
.LBB70_10:                              ;   in Loop: Header=BB70_4 Depth=1
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
	jr	c, .LBB70_12
; %bb.11:                               ;   in Loop: Header=BB70_4 Depth=1
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
	.local	.LBB70_12
.LBB70_12:                              ;   in Loop: Header=BB70_4 Depth=1
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
	ld	hl, _.str.3.86
	jr	nz, .LBB70_14
; %bb.13:                               ;   in Loop: Header=BB70_4 Depth=1
	ld	hl, _.str.4.87
	.local	.LBB70_14
.LBB70_14:                              ;   in Loop: Header=BB70_4 Depth=1
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
	ld	hl, _.str.2.88
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
	.local	.LBB70_15
.LBB70_15:                              ;   in Loop: Header=BB70_4 Depth=1
	call	_gfx_SwapDraw
	.local	.LBB70_16
.LBB70_16:                              ;   in Loop: Header=BB70_4 Depth=1
	call	_input_scan
	ld	de, (_repeat_frames)
	push	de
	pop	hl
	ld	bc, 10
	or	a, a
	sbc	hl, bc
	ld	bc, 14
	jr	nc, .LBB70_18
; %bb.17:                               ;   in Loop: Header=BB70_4 Depth=1
	ld	bc, 6
	.local	.LBB70_18
.LBB70_18:                              ;   in Loop: Header=BB70_4 Depth=1
	ex	de, hl
	ld	de, 24
	or	a, a
	sbc	hl, de
	ld	hl, 26
	jr	nc, .LBB70_20
; %bb.19:                               ;   in Loop: Header=BB70_4 Depth=1
	push	bc
	pop	hl
	.local	.LBB70_20
.LBB70_20:                              ;   in Loop: Header=BB70_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	hl, 1793
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB70_22
; %bb.21:                               ;   in Loop: Header=BB70_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	jr	.LBB70_24
	.local	.LBB70_22
.LBB70_22:                              ;   in Loop: Header=BB70_4 Depth=1
	ld	hl, 1800
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jp	z, .LBB70_37
; %bb.23:                               ;   in Loop: Header=BB70_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	call	__ineg
	.local	.LBB70_24
.LBB70_24:                              ;   in Loop: Header=BB70_4 Depth=1
	push	hl
	or	a, a
	sbc	hl, hl
	.local	.LBB70_25
.LBB70_25:                              ;   in Loop: Header=BB70_4 Depth=1
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
	.local	.LBB70_26
.LBB70_26:                              ;   in Loop: Header=BB70_4 Depth=1
	ld	a, (_current+6)
	ld	h, a
	bit	1, h
	jr	z, .LBB70_29
; %bb.27:                               ; %input_pressed.exit
                                        ;   in Loop: Header=BB70_4 Depth=1
	ld	a, (_previous+6)
	bit	1, a
	jr	nz, .LBB70_29
; %bb.28:                               ;   in Loop: Header=BB70_4 Depth=1
	push	ix
	ld	de, -344
	add	ix, de
	ld	iy, (ix + 0)
	pop	ix
	ld	e, (iy + 5)
	ld	d, e
	inc	d
	jp	.LBB70_43
	.local	.LBB70_29
.LBB70_29:                              ; %input_pressed.exit.thread
                                        ;   in Loop: Header=BB70_4 Depth=1
	bit	2, h
	jr	z, .LBB70_33
; %bb.30:                               ; %input_pressed.exit4
                                        ;   in Loop: Header=BB70_4 Depth=1
	ld	a, (_previous+6)
	bit	2, a
	jr	nz, .LBB70_33
; %bb.31:                               ;   in Loop: Header=BB70_4 Depth=1
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
	jp	z, .LBB70_50
; %bb.32:                               ;   in Loop: Header=BB70_4 Depth=1
	ld	d, e
	jp	.LBB70_42
	.local	.LBB70_33
.LBB70_33:                              ; %input_pressed.exit4.thread
                                        ;   in Loop: Header=BB70_4 Depth=1
	ld	a, (_current+1)
	bit	6, a
	jp	z, .LBB70_50
; %bb.34:                               ; %input_pressed.exit5
                                        ;   in Loop: Header=BB70_4 Depth=1
	ld	a, (_previous+1)
	bit	6, a
	jp	nz, .LBB70_50
; %bb.35:                               ;   in Loop: Header=BB70_4 Depth=1
	push	ix
	ld	de, -344
	add	ix, de
	ld	iy, (ix + 0)
	pop	ix
	ld	e, (iy + 5)
	ld	a, e
	or	a, a
	jr	z, .LBB70_41
; %bb.36:                               ;   in Loop: Header=BB70_4 Depth=1
	ld	d, 0
	jr	.LBB70_43
	.local	.LBB70_37
.LBB70_37:                              ;   in Loop: Header=BB70_4 Depth=1
	ld	hl, 1796
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	jr	z, .LBB70_39
; %bb.38:                               ;   in Loop: Header=BB70_4 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	jp	.LBB70_25
	.local	.LBB70_39
.LBB70_39:                              ;   in Loop: Header=BB70_4 Depth=1
	ld	hl, 1794
	push	hl
	call	_input_repeat
	pop	hl
	bit	0, a
	ld	a, 0
	ld	c, a
	jp	z, .LBB70_26
; %bb.40:                               ;   in Loop: Header=BB70_4 Depth=1
	ld	de, -351
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	call	__ineg
	ld	de, 0
	push	de
	jp	.LBB70_25
	.local	.LBB70_41
.LBB70_41:                              ;   in Loop: Header=BB70_4 Depth=1
	push	ix
	ld	bc, -344
	add	ix, bc
	ld	iy, (ix + 0)
	pop	ix
	ld	d, (iy + 14)
	.local	.LBB70_42
.LBB70_42:                              ;   in Loop: Header=BB70_4 Depth=1
	dec	d
	.local	.LBB70_43
.LBB70_43:                              ;   in Loop: Header=BB70_4 Depth=1
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
	jp	nc, .LBB70_50
; %bb.44:                               ;   in Loop: Header=BB70_4 Depth=1
	ld	a, e
	cp	a, d
	ld	a, 1
	ld	c, a
	jp	z, .LBB70_50
; %bb.45:                               ;   in Loop: Header=BB70_4 Depth=1
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
	jr	nz, .LBB70_47
; %bb.46:                               ;   in Loop: Header=BB70_4 Depth=1
	or	a, a
	sbc	hl, hl
	.local	.LBB70_47
.LBB70_47:                              ;   in Loop: Header=BB70_4 Depth=1
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
	jr	nz, .LBB70_49
; %bb.48:                               ;   in Loop: Header=BB70_4 Depth=1
	or	a, a
	sbc	hl, hl
	.local	.LBB70_49
.LBB70_49:                              ;   in Loop: Header=BB70_4 Depth=1
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
	.local	.LBB70_50
.LBB70_50:                              ; %set_layer.exit
                                        ;   in Loop: Header=BB70_4 Depth=1
	ld	a, (_current+1)
	ld	l, a
	ld	a, (_previous+1)
	cp	a, 0
	call	pe, __setflag
	ld	e, -1
	jp	p, .LBB70_52
; %bb.51:                               ; %set_layer.exit
                                        ;   in Loop: Header=BB70_4 Depth=1
	ld	e, 0
	.local	.LBB70_52
.LBB70_52:                              ; %set_layer.exit
                                        ;   in Loop: Header=BB70_4 Depth=1
	ld	a, l
	cp	a, 0
	call	pe, __setflag
	ld	a, -1
	jp	m, .LBB70_54
; %bb.53:                               ; %set_layer.exit
                                        ;   in Loop: Header=BB70_4 Depth=1
	ld	a, 0
	.local	.LBB70_54
.LBB70_54:                              ; %set_layer.exit
                                        ;   in Loop: Header=BB70_4 Depth=1
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
	jp	nz, .LBB70_58
; %bb.55:                               ;   in Loop: Header=BB70_4 Depth=1
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
	jr	c, .LBB70_57
; %bb.56:                               ;   in Loop: Header=BB70_4 Depth=1
	ld	a, 1
	ld	de, -345
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	.local	.LBB70_57
.LBB70_57:                              ;   in Loop: Header=BB70_4 Depth=1
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
	.local	.LBB70_58
.LBB70_58:                              ;   in Loop: Header=BB70_4 Depth=1
	bit	0, c
	ld	l, 1
	ld	bc, 60
	jr	nz, .LBB70_64
; %bb.59:                               ;   in Loop: Header=BB70_4 Depth=1
	bit	0, d
	jr	nz, .LBB70_64
; %bb.60:                               ;   in Loop: Header=BB70_4 Depth=1
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
	jr	z, .LBB70_64
; %bb.61:                               ;   in Loop: Header=BB70_4 Depth=1
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
	jr	z, .LBB70_63
; %bb.62:                               ;   in Loop: Header=BB70_4 Depth=1
	ld	l, 0
	.local	.LBB70_63
.LBB70_63:                              ;   in Loop: Header=BB70_4 Depth=1
	ld	h, a
	.local	.LBB70_64
.LBB70_64:                              ;   in Loop: Header=BB70_4 Depth=1
	bit	6, h
	jp	z, .LBB70_4
; %bb.65:                               ;   in Loop: Header=BB70_4 Depth=1
	ld	a, (_previous+6)
	bit	6, a
	jp	nz, .LBB70_4
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
	jr	z, .LBB70_71
; %bb.67:
	ld	l, 1
	ld	de, -378
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)
	and	a, l
	ld	l, a
	bit	0, l
	jr	nz, .LBB70_69
; %bb.68:
	or	a, a
	sbc	hl, hl
	push	hl
	call	_time
	pop	bc
	ld	(ix - 41), hl
	ld	(ix - 38), e
	.local	.LBB70_69
.LBB70_69:
	ld	l, 1
	ld	de, -378
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)
	or	a, l
	jr	.LBB70_72
	.local	.LBB70_70
.LBB70_70:
	ld	hl, _.str.84
	ld	de, _.str.1.85
	push	de
	push	hl
	call	_ui_message
	pop	hl
	pop	hl
	jr	.LBB70_73
	.local	.LBB70_71
.LBB70_71:
	ld	de, -378
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)
	ld	l, d
	and	a, l
	.local	.LBB70_72
.LBB70_72:
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
	.local	.LBB70_73
.LBB70_73:
	ld	de, -359
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end70
.Lfunc_end70:
	.size	_viewer_run, .Lfunc_end70-_viewer_run
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
	jr	c, .LBB71_2
; %bb.1:
	push	hl
	pop	bc
	.local	.LBB71_2
.LBB71_2:
	ld	(ix - 3), bc
	ld	bc, 204
	add	iy, bc
	ld	hl, (iy)
	or	a, a
	ld	bc, 240
	sbc	hl, bc
	jr	c, .LBB71_4
; %bb.3:
	ex	de, hl
	.local	.LBB71_4
.LBB71_4:
	ld	(ix - 6), de
	ld	iy, (ix + 6)
	ld	bc, (iy + 4)
	ld	de, (ix - 3)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB71_6
; %bb.5:
	ld	(iy + 4), de
	.local	.LBB71_6
.LBB71_6:
	ld	bc, (iy + 7)
	ld	de, (ix - 6)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB71_8
; %bb.7:
	ld	(iy + 7), de
	.local	.LBB71_8
.LBB71_8:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end71
.Lfunc_end71:
	.size	_clamp, .Lfunc_end71-_clamp
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
	jr	c, .LBB72_2
; %bb.1:
	ex	de, hl
	.local	.LBB72_2
.LBB72_2:
	ld	(ix - 9), de
	ld	de, (ix + 9)
	ld	bc, 204
	add	iy, bc
	ld	hl, (iy)
	or	a, a
	ld	bc, 240
	sbc	hl, bc
	ld	bc, 0
	jr	c, .LBB72_4
; %bb.3:
	push	hl
	pop	bc
	.local	.LBB72_4
.LBB72_4:
	ld	(ix - 6), bc
	ld	bc, 0
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB72_7
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
	jr	c, .LBB72_10
; %bb.6:
	lea	hl, iy + 0
	jr	.LBB72_10
	.local	.LBB72_7
.LBB72_7:
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB72_11
; %bb.8:
	ld	iy, (ix + 6)
	ld	iy, (iy + 4)
	add	iy, de
	lea	hl, iy + 0
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	lea	hl, iy + 0
	jr	c, .LBB72_10
; %bb.9:
	ex	de, hl
	.local	.LBB72_10
.LBB72_10:
	ld	iy, (ix + 6)
	ld	(iy + 4), hl
	.local	.LBB72_11
.LBB72_11:
	ld	bc, (ix + 12)
	push	bc
	pop	hl
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB72_15
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
	jr	c, .LBB72_14
; %bb.13:
	ld	(ix - 3), iy
	.local	.LBB72_14
.LBB72_14:
	ld	iy, (ix + 6)
	ld	hl, (ix - 3)
	jr	.LBB72_19
	.local	.LBB72_15
.LBB72_15:
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB72_20
; %bb.16:
	ld	iy, (ix + 6)
	ld	iy, (iy + 7)
	add	iy, bc
	lea	hl, iy + 0
	ld	de, (ix - 6)
	or	a, a
	sbc	hl, de
	lea	hl, iy + 0
	jr	c, .LBB72_18
; %bb.17:
	ex	de, hl
	.local	.LBB72_18
.LBB72_18:
	ld	iy, (ix + 6)
	.local	.LBB72_19
.LBB72_19:
	ld	(iy + 7), hl
	.local	.LBB72_20
.LBB72_20:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end72
.Lfunc_end72:
	.size	_pan, .Lfunc_end72-_pan
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

	.section	.rodata._.str.15,"a",@progbits
	.balign	1
	.local	_.str.15
_.str.15:
	.asciz	"Are you sure?"

	.section	.rodata._.str.1.16,"a",@progbits
	.balign	1
	.local	_.str.1.16
_.str.1.16:
	.asciz	"2nd  yes          clear  no"

	.section	.rodata._.str.2.19,"a",@progbits
	.balign	1
	.local	_.str.2.19
_.str.2.19:
	.asciz	"Books"

	.section	.rodata._.str.3,"a",@progbits
	.balign	1
	.local	_.str.3
_.str.3:
	.asciz	"No comics yet."

	.section	.rodata._.str.4,"a",@progbits
	.balign	1
	.local	_.str.4
_.str.4:
	.asciz	"Press 2nd to sync from a computer."

	.section	.rodata._.str.5.20,"a",@progbits
	.balign	1
	.local	_.str.5.20
_.str.5.20:
	.asciz	"%u/%u"

	.section	.rodata._.str.6,"a",@progbits
	.balign	1
	.local	_.str.6
_.str.6:
	.asciz	"enter open  2nd sync  del read  mode setup"

	.section	.rodata._.str.7,"a",@progbits
	.balign	1
	.local	_.str.7
_.str.7:
	.asciz	"Strips"

	.section	.rodata._.str.8,"a",@progbits
	.balign	1
	.local	_.str.8
_.str.8:
	.asciz	"*"

	.section	.rodata._.str.9,"a",@progbits
	.balign	1
	.local	_.str.9
_.str.9:
	.asciz	"%uK"

	.section	.rodata._.str.10,"a",@progbits
	.balign	1
	.local	_.str.10
_.str.10:
	.asciz	"enter read   del mark   clear back"

	.section	.rodata._.str.11,"a",@progbits
	.balign	1
	.local	_.str.11
_.str.11:
	.asciz	"About"

	.section	.rodata._about_text,"a",@progbits
	.balign	1
	.local	_about_text
_about_text:
	d24	_.str.27
	d24	_.str.4.87
	d24	_.str.29
	d24	_.str.4.87
	d24	_.str.30
	d24	_.str.31
	d24	_.str.32
	d24	_.str.33
	d24	_.str.34
	d24	_.str.4.87
	d24	_.str.35
	d24	_.str.4.87
	d24	_.str.36
	d24	_.str.37
	d24	_.str.38
	d24	_.str.39
	d24	_.str.40
	d24	_.str.41
	d24	_.str.4.87
	d24	_.str.42
	d24	_.str.43
	d24	_.str.44
	d24	_.str.45
	d24	_.str.4.87
	d24	_.str.46
	d24	_.str.4.87
	d24	_.str.47
	d24	_.str.48
	d24	_.str.49
	d24	_.str.50
	d24	_.str.51
	d24	_.str.52
	d24	_.str.4.87
	d24	_.str.53
	d24	_.str.54
	d24	_.str.55
	d24	_.str.56
	d24	_.str.57
	d24	_.str.58
	d24	_.str.4.87
	d24	_.str.59
	d24	_.str.4.87
	d24	_.str.60
	d24	_.str.61
	d24	_.str.62
	d24	_.str.63
	d24	_.str.4.87
	d24	_.str.64
	d24	_.str.65

	.section	.rodata._.str.12,"a",@progbits
	.balign	1
	.local	_.str.12
_.str.12:
	.asciz	"up/down  scroll        clear  back"

	.section	.rodata._ui_setup_screen.entries,"a",@progbits
	.balign	1
	.local	_ui_setup_screen.entries
_ui_setup_screen.entries:
	d24	_.str.13
	d24	_.str.11

	.section	.rodata._.str.13,"a",@progbits
	.balign	1
	.local	_.str.13
_.str.13:
	.asciz	"Erase the library"

	.section	.rodata._.str.14,"a",@progbits
	.balign	1
	.local	_.str.14
_.str.14:
	.asciz	"Settings"

	.section	.rodata._.str.15.25,"a",@progbits
	.balign	1
	.local	_.str.15.25
_.str.15.25:
	.asciz	"%u books, %u strips, %u read"

	.section	.rodata._.str.16,"a",@progbits
	.balign	1
	.local	_.str.16
_.str.16:
	.asciz	"Deletes every comic on this"

	.section	.rodata._.str.17,"a",@progbits
	.balign	1
	.local	_.str.17
_.str.17:
	.asciz	"calculator. The computer keeps"

	.section	.rodata._.str.18,"a",@progbits
	.balign	1
	.local	_.str.18
_.str.18:
	.asciz	"its copies."

	.section	.rodata._.str.19,"a",@progbits
	.balign	1
	.local	_.str.19
_.str.19:
	.asciz	"enter  choose          clear  back"

	.section	.rodata._.str.20,"a",@progbits
	.balign	1
	.local	_.str.20
_.str.20:
	.asciz	"Erase every comic on this"

	.section	.rodata._.str.21,"a",@progbits
	.balign	1
	.local	_.str.21
_.str.21:
	.asciz	"calculator?"

	.section	.rodata._.str.22,"a",@progbits
	.balign	1
	.local	_.str.22
_.str.22:
	.asciz	"Removed %u strip(s)."

	.section	.rodata._.str.23,"a",@progbits
	.balign	1
	.local	_.str.23
_.str.23:
	.asciz	"Sync again to refill it."

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

	.section	.rodata._.str.24,"a",@progbits
	.balign	1
	.local	_.str.24
_.str.24:
	.asciz	"Starting..."

	.section	.rodata._.str.25,"a",@progbits
	.balign	1
	.local	_.str.25
_.str.25:
	.asciz	"Could not take over USB."

	.section	.rodata._.str.26,"a",@progbits
	.balign	1
	.local	_.str.26
_.str.26:
	.asciz	"Unplug the cable and retry."

	.section	.rodata._.str.27,"a",@progbits
	.balign	1
	.local	_.str.27
_.str.27:
	.asciz	"eBookSync"

	.section	.rodata._.str.29,"a",@progbits
	.balign	1
	.local	_.str.29
_.str.29:
	.asciz	"A comic reader for the TI-84 Plus CE."

	.section	.rodata._.str.30,"a",@progbits
	.balign	1
	.local	_.str.30
_.str.30:
	.asciz	"Comics are converted on a computer into"

	.section	.rodata._.str.31,"a",@progbits
	.balign	1
	.local	_.str.31
_.str.31:
	.asciz	"a format a 48MHz eZ80 can draw, and sent"

	.section	.rodata._.str.32,"a",@progbits
	.balign	1
	.local	_.str.32
_.str.32:
	.asciz	"over a USB serial link. This program"

	.section	.rodata._.str.33,"a",@progbits
	.balign	1
	.local	_.str.33
_.str.33:
	.asciz	"lists what arrived, shows it, and"

	.section	.rodata._.str.34,"a",@progbits
	.balign	1
	.local	_.str.34
_.str.34:
	.asciz	"remembers where you got to."

	.section	.rodata._.str.35,"a",@progbits
	.balign	1
	.local	_.str.35
_.str.35:
	.asciz	"HOW IT WORKS"

	.section	.rodata._.str.36,"a",@progbits
	.balign	1
	.local	_.str.36
_.str.36:
	.asciz	"Each strip is stored at two zoom levels,"

	.section	.rodata._.str.37,"a",@progbits
	.balign	1
	.local	_.str.37
_.str.37:
	.asciz	"16 colours, 4 bits per pixel, cut into"

	.section	.rodata._.str.38,"a",@progbits
	.balign	1
	.local	_.str.38
_.str.38:
	.asciz	"32-row bands and compressed with ZX0."

	.section	.rodata._.str.39,"a",@progbits
	.balign	1
	.local	_.str.39
_.str.39:
	.asciz	"Only the bands on screen are unpacked,"

	.section	.rodata._.str.40,"a",@progbits
	.balign	1
	.local	_.str.40
_.str.40:
	.asciz	"so a 400KB comic is read from flash a"

	.section	.rodata._.str.41,"a",@progbits
	.balign	1
	.local	_.str.41
_.str.41:
	.asciz	"few kilobytes at a time."

	.section	.rodata._.str.42,"a",@progbits
	.balign	1
	.local	_.str.42
_.str.42:
	.asciz	"Titles are pictures, not text. The"

	.section	.rodata._.str.43,"a",@progbits
	.balign	1
	.local	_.str.43
_.str.43:
	.asciz	"calculator has no Chinese font, so the"

	.section	.rodata._.str.44,"a",@progbits
	.balign	1
	.local	_.str.44
_.str.44:
	.asciz	"computer draws each title once and sends"

	.section	.rodata._.str.45,"a",@progbits
	.balign	1
	.local	_.str.45
_.str.45:
	.asciz	"the pixels."

	.section	.rodata._.str.46,"a",@progbits
	.balign	1
	.local	_.str.46
_.str.46:
	.asciz	"KEYS"

	.section	.rodata._.str.47,"a",@progbits
	.balign	1
	.local	_.str.47
_.str.47:
	.asciz	"  Book list"

	.section	.rodata._.str.48,"a",@progbits
	.balign	1
	.local	_.str.48
_.str.48:
	.asciz	"    enter   open a book"

	.section	.rodata._.str.49,"a",@progbits
	.balign	1
	.local	_.str.49
_.str.49:
	.asciz	"    del     mark a book read"

	.section	.rodata._.str.50,"a",@progbits
	.balign	1
	.local	_.str.50
_.str.50:
	.asciz	"    2nd     sync with a computer"

	.section	.rodata._.str.51,"a",@progbits
	.balign	1
	.local	_.str.51
_.str.51:
	.asciz	"    mode    settings"

	.section	.rodata._.str.52,"a",@progbits
	.balign	1
	.local	_.str.52
_.str.52:
	.asciz	"    clear   quit"

	.section	.rodata._.str.53,"a",@progbits
	.balign	1
	.local	_.str.53
_.str.53:
	.asciz	"  Reading"

	.section	.rodata._.str.54,"a",@progbits
	.balign	1
	.local	_.str.54
_.str.54:
	.asciz	"    arrows  pan, hold to speed up"

	.section	.rodata._.str.55,"a",@progbits
	.balign	1
	.local	_.str.55
_.str.55:
	.asciz	"    + -     zoom"

	.section	.rodata._.str.56,"a",@progbits
	.balign	1
	.local	_.str.56
_.str.56:
	.asciz	"    mode    fit width / full zoom"

	.section	.rodata._.str.57,"a",@progbits
	.balign	1
	.local	_.str.57
_.str.57:
	.asciz	"    del     mark read"

	.section	.rodata._.str.58,"a",@progbits
	.balign	1
	.local	_.str.58
_.str.58:
	.asciz	"    clear   back"

	.section	.rodata._.str.59,"a",@progbits
	.balign	1
	.local	_.str.59
_.str.59:
	.asciz	"CREDITS"

	.section	.rodata._.str.60,"a",@progbits
	.balign	1
	.local	_.str.60
_.str.60:
	.asciz	"ZX0 compression by Einar Saukas."

	.section	.rodata._.str.61,"a",@progbits
	.balign	1
	.local	_.str.61
_.str.61:
	.asciz	"Built with the CE C/C++ toolchain."

	.section	.rodata._.str.62,"a",@progbits
	.balign	1
	.local	_.str.62
_.str.62:
	.asciz	"srldrvce and usbdrvce by the CE"

	.section	.rodata._.str.63,"a",@progbits
	.balign	1
	.local	_.str.63
_.str.63:
	.asciz	"Programming team."

	.section	.rodata._.str.64,"a",@progbits
	.balign	1
	.local	_.str.64
_.str.64:
	.asciz	"Edit about.txt in the repository to"

	.section	.rodata._.str.65,"a",@progbits
	.balign	1
	.local	_.str.65
_.str.65:
	.asciz	"change this page."

	.section	.rodata._.str.66,"a",@progbits
	.balign	1
	.local	_.str.66
_.str.66:
	.asciz	"eBookSync - ECHO TEST"

	.section	.rodata._.str.67,"a",@progbits
	.balign	1
	.local	_.str.67
_.str.67:
	.asciz	"%u done, %uK moved"

	.section	.rodata._.str.68,"a",@progbits
	.balign	1
	.local	_.str.68
_.str.68:
	.asciz	"req %u cmd %u err %u"

	.section	.rodata._.str.69,"a",@progbits
	.balign	1
	.local	_.str.69
_.str.69:
	.asciz	"open %u loops %u"

	.section	.rodata._.str.70,"a",@progbits
	.balign	1
	.local	_.str.70
_.str.70:
	.asciz	"defragmented %u time(s)"

	.section	.rodata._.str.71,"a",@progbits
	.balign	1
	.local	_.str.71
_.str.71:
	.asciz	"Different library! del=erase"

	.section	.rodata._.str.72,"a",@progbits
	.balign	1
	.local	_.str.72
_.str.72:
	.asciz	"[clear] stop syncing"

	.section	.bss._sync_progress.poll,"aw",@nobits
	.balign	1
	.local	_sync_progress.poll
_sync_progress.poll:
	.zero	1

	.section	.bss._sync_progress.drawn_at,"aw",@nobits
	.balign	1
	.local	_sync_progress.drawn_at
_sync_progress.drawn_at:
	.zero	3

	.section	.bss._sync_progress.drawn_requests,"aw",@nobits
	.balign	2
	.local	_sync_progress.drawn_requests
_sync_progress.drawn_requests:
	.zero	2

	.section	.rodata._.str.73,"a",@progbits
	.balign	1
	.local	_.str.73
_.str.73:
	.asciz	"%s"

	.section	.rodata._.str.74,"a",@progbits
	.balign	1
	.local	_.str.74
_.str.74:
	.asciz	"Erased -- sync again"

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

	.section	.bss._link_errors,"aw",@nobits
	.balign	2
	.local	_link_errors
_link_errors:
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

	.section	.bss._bytes_moved,"aw",@nobits
	.balign	1
	.local	_bytes_moved
_bytes_moved:
	.zero	3

	.section	.bss._library_state,"aw",@nobits
	.balign	1
	.local	_library_state
_library_state:
	.zero	1

	.section	.bss._gc_count,"aw",@nobits
	.balign	1
	.local	_gc_count
_gc_count:
	.zero	1

	.section	.bss._serial_open,"aw",@nobits
	.balign	1
	.local	_serial_open
_serial_open:
	.zero	1

	.section	.bss._finished,"aw",@nobits
	.balign	1
	.local	_finished
_finished:
	.zero	1

	.section	.bss._closing,"aw",@nobits
	.balign	1
	.local	_closing
_closing:
	.zero	1

	.section	.bss._link_state,"aw",@nobits
	.balign	1
	.local	_link_state
_link_state:
	.zero	3

	.section	.bss._header_have,"aw",@nobits
	.balign	1
	.local	_header_have
_header_have:
	.zero	1

	.section	.bss._payload,"aw",@nobits
	.balign	1
	.local	_payload
_payload:
	.zero	3

	.section	.bss._serial,"aw",@nobits
	.balign	1
	.local	_serial
_serial:
	.zero	58

	.section	.bss._discard_scratch,"aw",@nobits
	.balign	1
	.local	_discard_scratch
_discard_scratch:
	.zero	256

	.section	.rodata._.str.75,"a",@progbits
	.balign	1
	.local	_.str.75
_.str.75:
	.asciz	"Echo"

	.section	.bss._cached_archive_free,"aw",@nobits
	.balign	1
	.local	_cached_archive_free
_cached_archive_free:
	.zero	3

	.section	.bss._cached_index,"aw",@nobits
	.balign	1
	.local	_cached_index
_cached_index:
	.zero	3

	.section	.bss._cached_index_size,"aw",@nobits
	.balign	2
	.local	_cached_index_size
_cached_index_size:
	.zero	2

	.section	.rodata._.str.1.46,"a",@progbits
	.balign	1
	.local	_.str.1.46
_.str.1.46:
	.asciz	"CSLIB"

	.section	.rodata._.str.2.47,"a",@progbits
	.balign	1
	.local	_.str.2.47
_.str.2.47:
	.asciz	"r"

	.section	.bss._sequence,"aw",@nobits
	.balign	1
	.local	_sequence
_sequence:
	.zero	1

	.section	.bss._serial_buffer,"aw",@nobits
	.balign	1
	.local	_serial_buffer
_serial_buffer:
	.zero	2048

	.section	.bss._header,"aw",@nobits
	.balign	1
	.local	_header
_header:
	.zero	8

	.section	.bss._command,"aw",@nobits
	.balign	1
	.local	_command
_command:
	.zero	1

	.section	.bss._argument,"aw",@nobits
	.balign	2
	.local	_argument
_argument:
	.zero	2

	.section	.bss._payload_want,"aw",@nobits
	.balign	1
	.local	_payload_want
_payload_want:
	.zero	4

	.section	.bss._payload_have,"aw",@nobits
	.balign	1
	.local	_payload_have
_payload_have:
	.zero	4

	.section	.bss._reply_header_sent,"aw",@nobits
	.balign	1
	.local	_reply_header_sent
_reply_header_sent:
	.zero	1

	.section	.bss._reply_header,"aw",@nobits
	.balign	1
	.local	_reply_header
_reply_header:
	.zero	8

	.section	.bss._reply_body_sent,"aw",@nobits
	.balign	1
	.local	_reply_body_sent
_reply_body_sent:
	.zero	4

	.section	.bss._reply_body_len,"aw",@nobits
	.balign	1
	.local	_reply_body_len
_reply_body_len:
	.zero	4

	.section	.bss._reply_body,"aw",@nobits
	.balign	1
	.local	_reply_body
_reply_body:
	.zero	3

	.section	.bss._reply_small,"aw",@nobits
	.balign	1
	.local	_reply_small
_reply_small:
	.zero	16

	.section	.rodata._.str.3.81,"a",@progbits
	.balign	1
	.local	_.str.3.81
_.str.3.81:
	.asciz	"w"

	.section	.rodata._.str.4.76,"a",@progbits
	.balign	1
	.local	_.str.4.76
_.str.4.76:
	.asciz	"Waiting for computer"

	.section	.rodata._.str.5.78,"a",@progbits
	.balign	1
	.local	_.str.5.78
_.str.5.78:
	.asciz	"Receiving"

	.section	.rodata._.str.6.79,"a",@progbits
	.balign	1
	.local	_.str.6.79
_.str.6.79:
	.asciz	"Skipping"

	.section	.rodata._.str.7.80,"a",@progbits
	.balign	1
	.local	_.str.7.80
_.str.7.80:
	.asciz	"Replying"

	.section	.rodata._.str.8.77,"a",@progbits
	.balign	1
	.local	_.str.8.77
_.str.8.77:
	.asciz	"Connected"

	.section	.rodata._switch.table.proto_run,"a",@progbits
	.balign	1
	.local	_switch.table.proto_run
_switch.table.proto_run:
	d24	_.str.5.78
	d24	_.str.6.79
	d24	_.str.7.80

	.section	.rodata._.str.84,"a",@progbits
	.balign	1
	.local	_.str.84
_.str.84:
	.asciz	"Cannot open this strip."

	.section	.rodata._.str.1.85,"a",@progbits
	.balign	1
	.local	_.str.1.85
_.str.1.85:
	.asciz	"Re-sync it from the computer."

	.section	.rodata._.str.2.88,"a",@progbits
	.balign	1
	.local	_.str.2.88
_.str.2.88:
	.asciz	"%u.%ux %u%%%s"

	.section	.rodata._.str.3.86,"a",@progbits
	.balign	1
	.local	_.str.3.86
_.str.3.86:
	.asciz	" read"

	.section	.rodata._.str.4.87,"a",@progbits
	.balign	1
	.local	_.str.4.87
_.str.4.87:
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
	.extern	_llvm.smin.i24
	.extern	_llvm.lifetime.end.p0
	.extern	_srl_Write
	.extern	__ishru
	.extern	__Unwind_SjLj_Unregister
	.extern	__sor
	.extern	_llvm.usub.sat.i16
	.extern	__idivs
	.extern	_kb_Scan
	.extern	_usb_Init
	.extern	_llvm.memset.p0.i64
	.extern	_llvm.umax.i8
	.extern	__ineg
	.extern	_gfx_Wait
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
	.extern	_ti_SetGCBehavior
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
	.extern	_memcmp
	.extern	_llvm.lifetime.start.p0
	.extern	_llvm.umin.i16
	.extern	__lshru
	.extern	_gfx_Blit
	.extern	_srl_Read
	.extern	_os_HomeUp
	.extern	__sdivs
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_llvm.usub.sat.i24
	.extern	_ti_GetSize
	.extern	__iremu
	.extern	_os_SetCursorPos
	.extern	_llvm.umin.i32
	.extern	__sdivu
	.extern	_llvm.umax.i24
	.extern	_gfx_FillScreen
	.extern	_gfx_FillRectangle_NoClip
	.extern	__bshru
	.extern	_gfx_PrintStringXY
	.extern	_gfx_SetColor
	.extern	_llvm.memcpy.p0.p0.i24
	.extern	_gfx_End
	.extern	_llvm.memset.p0.i24
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
	.extern	_os_ArcChk
	.extern	__frameset0
	.extern	__Unwind_SjLj_Register
	.extern	__sshl
	.extern	__smulu
	.extern	_gfx_SetDraw
	.extern	__ishl
