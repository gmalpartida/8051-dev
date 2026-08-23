.include "conio.inc"
.include "constants.inc"
.include "ascii.inc"
.include "bios.inc"

.area CSEG (CODE)

println:
	mov a, #CR
	lcall sys_putc
	mov a, #LF
	lcall sys_putc
	ret

; prints tab(s)
printtab:
	mov a, #TAB
	lcall sys_putc
	ret

; prints space(s)
printspc:
	mov a, #SPC
	lcall sys_putc
	ret

print_hex_nibble:
	lcall nibble2ahex
	lcall sys_putc
	ret

print_hex_byte:
	lcall byte2ahex
	xch a, b							; print high nibble first
	lcall sys_putc
	xch a, b
	lcall sys_putc						; print low nibble
	ret

print_hex_word:
	push a								; save low byte
	xch a, b							; print high byte first
	lcall print_hex_byte
	pop a								; retreive low byte
	lcall print_hex_byte				; print low byte
	ret

read_hex_nibble:
	lcall sys_getc
	lcall ahex2nibble	
	ret

read_hex_byte:
	lcall read_hex_nibble			; read high nibble into a
	push a							; save high nibble for later use
	lcall read_hex_nibble			; read low nibble into a
	pop 0xf0						; retrieve high nibble
	xch a, b						; process high nibble first
	swap a							
	orl a, b						; merge both nibbles into a
	ret

read_hex_word:
	lcall read_hex_byte
	push a
	lcall read_hex_byte
	pop 0xf0

	ret





