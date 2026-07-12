.include "conio.inc"
.include "constants.inc"
.include "ascii.inc"
.include "uart.inc"

.area cseg (CODE)

get_hex_address:
	mov a, @r0
	lcall asc2nibble
	inc r0
	mov b, a
	mov a, @r0
	lcall asc2nibble
	swap a
	anl a, #0xf0
	orl a, b
	swap a
	ret

skip_blanks:
	movx a, @dptr
	jz skip_blanks_exit
	cjne a, #' ', skip_blanks_exit
	inc dptr
	sjmp skip_blanks
skip_blanks_exit:
	ret

println:
	mov a, #CR
	lcall uart_tx_char
	mov a, #LF
	lcall uart_tx_char
	ret

; prints tab(s)
printtab:
	mov a, #TAB
	lcall uart_tx_char
	ret

; prints space(s)
printspc:
	mov a, #' '
	lcall uart_tx_char
	ret

