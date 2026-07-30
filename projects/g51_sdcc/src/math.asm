.include "math.inc"

.area CSEG (CODE)

rand_init:
	; get values at rand_seed address
	mov dptr, #rand_seed
	movx a, @dptr							; read high byte of rand_seed
	push a
	inc dptr
	movx a, @dptr							; read low byte of rand_seed
	push a
	; use values to form new addresses
	pop dpl
	pop dph
	movx a, @dptr							; read value at that address
	push a
	; use this value to form two new addresses
	push dph
	push dpl
	mov dph, a
	movx a, @dptr							; read high byte of new seed
	mov dptr, #rand_seed
	movx @dptr, a
	pop dpl
	pop dph
	pop dpl
	movx a, @dptr							; read low byte of new seed
	mov dptr, #(rand_seed + 1)
	movx @dptr, a
	ret

rand:

	ret

get_seed:
	mov dptr, #rand_seed
	movx a, @dptr
	mov b, a
	inc dptr
	movx a, @dptr
	ret

.area XSEG (XDATA)

rand_seed:		.ds		0x02
