
	CR equ 0dh

cseg
	ljmp main
; space reserved for vector table
ie0_vector:
	ljmp $
	ds 5
tf0_vector:
	ljmp $
	ds 5
ie1_vector:
	ljmp $
	ds 5
tf1_vector:
	ljmp $
	ds 5
serial_vector:
	ljmp $
	ds 5

main:
	acall uart_init_baud_gen

loop_echo:

	acall uart_rx_char
 	mov sbuf, a
	acall uart_tx_char

  	sjmp loop_echo ; jump back to the beginning of the loop

; initializes timer 1 as standard uart baud rate generator
; <-- timer 1: 9600bps, mode 2, 8-bit auto-reload
; <-- serial port: mode 1, 8-bit
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
; --> dptr: location of string that was received
uart_rx_string:
loop_rx_string:
	acall uart_rx_char

	cjne a, #CR, loop_rx_string

	ret

; transmits character via serial port
; --> a: character to be sent
uart_tx_char:
	jnb ti, $
	clr ti

	ret
end


