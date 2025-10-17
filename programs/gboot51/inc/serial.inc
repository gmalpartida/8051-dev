
; initializes timer 1 as standard uart baud rate generator
; <-- timer 1: , mode 2, 8-bit auto-reload
; <-- serial port: mode 1, 8-bit, 9600 bps
uart_init_baud_gen:
	mov tmod, #20h
	mov th1, #0fdh
	setb tr1

	mov scon, #50h

	ret

; receives a character from serial port
; <-- a: character received
uart_rx_char:
	jnb ri, $
	clr ri
	mov a, sbuf
	ret

; receives a string from the serial port
; <-- dptr: location of string that was received
uart_rx_string:
loop_rx_string:
	acall uart_rx_char
	movx @dptr, a
	cjne a, #CR, uart_rx_string_is_lf
	mov a, #00h
	movx @dptr, a
	inc dptr
	jmp loop_rx_string
uart_rx_string_is_lf:
	cjne a, #LF, uart_rx_string_not_lf
	mov a, #00h
	movx @dptr, a
	jmp exit_uart_rx_string
uart_rx_string_not_lf:
	inc dptr
	jmp loop_rx_string
exit_uart_rx_string:
	ret

; transmits character via serial port
; --> a: character to be transmitted
uart_tx_char:
	mov sbuf, a
	jnb ti, $
	clr ti
	ret

; transmits a string via serial port
; --> dptr: location of string to be transmitted
uart_tx_string:
	movx a, @dptr
	jz exit_uart_tx_string
	acall uart_tx_char
	inc dptr
	jmp uart_tx_string

exit_uart_tx_string:
	ret

; transmits a string via serial port
; --> dptr: location of string to be transmitted
uart_tx_string_from_cseg:
	clr a
	movc a, @a + dptr
	jz exit_uart_tx_string_from_cseg
	acall uart_tx_char
	inc dptr
	jmp uart_tx_string_from_cseg

exit_uart_tx_string_from_cseg:
	ret


