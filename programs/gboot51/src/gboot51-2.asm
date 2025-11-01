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
	inc dptr
	acall do_process_peek_cmd
	jmp command_prompt_loop
process_poke_cmd:
	cjne a, #POKE_CMD, process_invalid_cmd
	acall do_process_poke_cmd
	jmp command_prompt_loop
process_invalid_cmd:
	jmp command_prompt_loop

	jmp $

do_process_ls_cmd:
	mov dptr, #ls_str
	acall uart_tx_string_from_cseg

	ret

do_process_peek_cmd:
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
	jz exit_parse_mem_address
	movx a, @dptr
	acall ascii2bin
	sjmp parse_mem_address
exit_parse_mem_address:
	ret

; convert an ascci hex charactor into its binary value
; --> a: ascii hex character to be converted
; <-- a: binary representation of ascii character
ascii2bin:
	cjne a, #'a', is_b
	jmp is_letter
is_b:
	cjne a, #'b', is_c
	jmp is_letter
is_c:
	cjne a, #'c', is_d
	jmp is_letter
is_d:
	cjne a, #'d', is_e
	jmp is_letter
is_e:
	cjne a, #'e', is_f
	jmp is_letter
is_f:
	cjne a, #'f', is_0
	jmp is_letter
is_letter:
	add a, #07h
	jmp exit_ascii2bin
is_0:
	cjne a, #'0', is_1
	jmp exit_ascii2bin
is_1:
	cjne a, #'1', is_2
	jmp exit_ascii2bin
is_2:
	cjne a, #'2', is_3
	jmp exit_ascii2bin
is_3:
	cjne a, #'3', is_4
	jmp exit_ascii2bin
is_4:
	cjne a, #'4', is_5
	jmp exit_ascii2bin
is_5:
	cjne a, #'5', is_6
	jmp exit_ascii2bin
is_6:
	cjne a, #'6', is_7
	jmp exit_ascii2bin
is_7:
	cjne a, #'7', is_8
	jmp exit_ascii2bin
is_8:	
	cjne a, #'8', is_9
	jmp exit_ascii2bin
is_9:
	cjne a, #'9', ascii2bin_error
	jmp exit_ascii2bin
ascii2bin_error:
	mov a, #0ffh
exit_ascii2bin:
	anl a, #0fh
	inc dptr
	ret

$include(constants.inc)
$include(boot51.inc)
$include(serial.inc)
$include(menu.inc)
$include(mem_diag.asm)

xseg at 0000h
	uart_rx_buffer: ds 255

end


