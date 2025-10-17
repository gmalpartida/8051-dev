cseg at 00h
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

cseg at 0200h
$include(constants.inc)

cseg at 0030h

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

	
	acall get_cmd

	cjne a, #HELP_CMD, process_ls_cmd
	mov dptr, #help_str
	acall uart_tx_string_from_cseg
	jmp command_prompt_loop
process_ls_cmd:
	cjne a, #LS_CMD, process_peek_cmd	
	acall do_process_ls_cmd
	jmp command_prompt_loop
	
process_peek_cmd:
	cjne a, #PEEK_CMD, process_poke_cmd
	acall do_process_peek_cmd
	jmp command_prompt_loop
process_poke_cmd:
	cjne a, #POKE_CMD, process_invalid_cmd
	acall do_process_poke_cmd
	jmp command_prompt_loop
process_invalid_cmd:
	jmp command_prompt_loop
show_help:
	
	jmp $

do_process_ls_cmd:
	mov dptr, #ls_str
	acall uart_tx_string_from_cseg

	ret

do_process_peek_cmd:
	;mov dptr, #peek_cmd_txt
	;acall uart_tx_string_from_cseg
	mov dptr, #uart_rx_buffer
	acall parse_mem_address

	ret

do_process_poke_cmd:
	mov dptr, #poke_cmd_txt
	acall uart_tx_string_from_cseg
	ret

fill_xmem:
	clr a
fill_xmem_loop:
	movx @dptr, a
	inc dptr
	inc a
	cjne a, #00h, fill_xmem_loop
	ret

parse_mem_address:
	movx a, @dptr
	jz exit_parse_mem_address
	acall skip_blanks
	movx a, @dptr
	
parse_mem_address_loop:
	

exit_parse_mem_address:
	ret

$include(boot51.inc)
$include(serial.inc)
$include(menu.inc)

xseg at 0000h
	uart_rx_buffer: ds 255

end


