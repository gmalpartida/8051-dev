cseg
	CR equ 0dh
	LF equ 0ah
	TAB equ 09h

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

	mov dptr, #newline_str
	acall uart_tx_string_from_cseg
	mov dptr, #title_str
	acall uart_tx_string_from_cseg
	mov dptr, #newline_str
	acall uart_tx_string_from_cseg
	mov dptr, #newline_str
	acall uart_tx_string_from_cseg


command_prompt_loop:
	mov dptr, #command_prompt_str
	acall uart_tx_string_from_cseg

	acall get_command

	mov dptr, #help_str
	acall uart_tx_string_from_cseg
	jmp command_prompt_loop
	
	sjmp $	

show_help:
	
	ret

$include(serial.asm)
$include(menu.asm)

xseg
	uart_rx_buffer: ds 255

cseg at $


end


