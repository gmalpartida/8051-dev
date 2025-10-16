; retrieves the command entered
; --> uart_rx_buffer: contains command received
; <-- a: HELP_CMD, LS_CMD, PEEK_CMD or POKE_CMD if valid, otherwise INVALID_CMD
get_cmd:
	mov b, #00h
	mov dptr, #uart_rx_buffer
	acall uart_rx_string

	mov dptr, #uart_rx_buffer
skip_blanks_loop:
	movx a, @dptr 
	jz exit_get_cmd
	cjne a, #' ', is_help_cmd
	inc dptr
	jmp skip_blanks_loop

is_help_cmd:	
	movx a, @dptr
	cjne a, #'h', is_ls_cmd
	inc dptr
	movx a, @dptr
	cjne a, #'e', is_invalid_cmd
	inc dptr
	movx a, @dptr
	cjne a, #'l', is_invalid_cmd
	inc dptr
	movx a, @dptr
	cjne a, #'p', is_invalid_cmd
	mov b, #HELP_CMD
	jmp exit_get_cmd
is_ls_cmd:
	movx a, @dptr
	cjne a, #'l', is_peek_cmd
	inc dptr
	movx a, @dptr
	cjne a, #'s', is_invalid_cmd
	mov b, #LS_CMD
	jmp exit_get_cmd
is_peek_cmd:
	movx a, @dptr
	cjne a, #'p', is_invalid_cmd
	inc dptr
	movx a, @dptr
	cjne a, #'e', is_poke_cmd
	inc dptr
	movx a, @dptr
	cjne a, #'e', is_invalid_cmd
	inc dptr
	movx a, @dptr
	cjne a, #'k', is_invalid_cmd
	mov b, #PEEK_CMD
	jmp exit_get_cmd
is_poke_cmd:
	movx a, @dptr
	cjne a, #'o', is_invalid_cmd
	inc dptr
	movx a, @dptr
	cjne a, #'k', is_invalid_cmd
	inc dptr
	movx a, @dptr
	cjne a, #'e', is_invalid_cmd
	mov b, #POKE_CMD
	jmp exit_get_cmd
is_invalid_cmd:
	mov b, #INVALID_CMD
exit_get_cmd:	
	mov a, b
	ret

; skips blanks in front of buffer
; --> dptr: contains address of buffer to read
; <-- dptr: points at the first non-blank character in buffer
skip_blanks:
	movx a, @dptr
	cjne a, #' ', exit_skip_blanks
	inc dptr
	jmp skip_blanks
exit_skip_blanks:
	ret

