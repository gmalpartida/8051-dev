; retrieves the command entered
; --> uart_rx_buffer: contains command received
; <-- a: HELP_CMD, LS_CMD, PEEK_CMD or POKE_CMD if valid, otherwise INVALID_CMD
get_cmd:
	mov b, #INVALID_CMD
	mov dptr, #uart_rx_buffer
	acall uart_rx_string

	mov dptr, #uart_rx_buffer
skip_blanks_loop:
	movx a, @dptr 
	jnz skip_blanks_continue
	jmp exit_get_cmd
skip_blanks_continue:

	cjne a, #' ', check_cmd
	inc dptr
	jmp skip_blanks_loop

check_cmd:
	call check_dump_cmd
	cjne a, #DUMP_CMD, skip_dump_cmd
	mov b, #DUMP_CMD
	jmp exit_get_cmd

skip_dump_cmd:
	call check_help_cmd
	cjne a, #HELP_CMD, skip_help_cmd
	mov b, #HELP_CMD
	jmp exit_get_cmd

skip_help_cmd:
	call check_ls_cmd
	cjne a, #LS_CMD, skip_ls_cmd
	mov b, #LS_CMD
	jmp exit_get_cmd

skip_ls_cmd:
	call check_peek_cmd
	cjne a, #PEEK_CMD, skip_peek_cmd
	mov b, #PEEK_CMD
	jmp exit_get_cmd

skip_peek_cmd:
	call check_poke_cmd
	cjne a, #POKE_CMD, is_invalid_cmd_old
	mov b, #POKE_CMD
	jmp exit_get_cmd

is_invalid_cmd_old:
	mov b, #INVALID_CMD
exit_get_cmd:	
	mov a, b
	ret


; check if there any characters left in the line
; -->dptr: contains address of buffer to read
; <-- cy: set if there are characters left, otherwise clear
no_more_chars_till_eol:
	clr cy
	movx a, @dptr
	subb a, #' '
	jz no_more_chars_till_eol
	jc no_more_chars_till_eol
	setb cy
no_more_chars_till_eol_exit:
	ret

check_dump_cmd:
	mov b, #NEXT_CMD
	movx a, @dptr
	cjne a, #'d', check_dump_cmd_exit
	inc dptr
	movx a, @dptr
	cjne a, #'u', check_dump_cmd_error
	inc dptr
	movx a, @dptr
	cjne a, #'m', check_dump_cmd_error
	inc dptr
	movx a, @dptr
	cjne a, #'p', check_dump_cmd_error
	mov b, #DUMP_CMD
	jmp check_dump_cmd_exit
check_dump_cmd_error:
	mov b, #INVALID_CMD
check_dump_cmd_exit:
	mov a, b
	ret

check_help_cmd:	
	mov b, #NEXT_CMD
	movx a, @dptr
	cjne a, #'h', check_help_cmd_exit
	inc dptr
	movx a, @dptr
	cjne a, #'e', check_help_cmd_error
	inc dptr
	movx a, @dptr
	cjne a, #'l', check_help_cmd_error
	inc dptr
	movx a, @dptr
	cjne a, #'p', check_help_cmd_error
	mov b, #HELP_CMD
	jmp check_help_cmd_exit
check_help_cmd_error:
	mov b, #INVALID_CMD
check_help_cmd_exit:
	mov a, b
	ret

check_ls_cmd:
	mov b, #NEXT_CMD
	movx a, @dptr
	cjne a, #'l', check_ls_cmd_exit
	inc dptr
	movx a, @dptr
	cjne a, #'s', check_ls_cmd_error
	mov b, #LS_CMD
	jmp check_ls_cmd_exit
check_ls_cmd_error:
	mov b, #INVALID_CMD
check_ls_cmd_exit:
	mov a, b
	ret

check_peek_cmd:
	mov b, #NEXT_CMD
	movx a, @dptr
	cjne a, #'p', check_peek_cmd_exit
	inc dptr
	movx a, @dptr
	cjne a, #'e', check_peek_cmd_exit
	inc dptr
	movx a, @dptr
	cjne a, #'e', check_peek_cmd_error
	inc dptr
	movx a, @dptr
	cjne a, #'k', check_peek_cmd_error
	mov b, #PEEK_CMD
	jmp check_peek_cmd_exit

check_peek_cmd_error:
	mov b, #INVALID_CMD
check_peek_cmd_exit:
	mov a, b
	ret


check_poke_cmd:

	movx a, @dptr
	cjne a, #'o', check_poke_cmd_error
	inc dptr
	movx a, @dptr
	cjne a, #'k', check_poke_cmd_error
	inc dptr
	movx a, @dptr
	cjne a, #'e', check_poke_cmd_error
	mov b, #POKE_CMD
	jmp check_poke_cmd_exit

check_poke_cmd_error:
	mov b, #INVALID_CMD
check_poke_cmd_exit:
	mov a, b
	ret



	
