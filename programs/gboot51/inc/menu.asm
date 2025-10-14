INVALID_CMD	equ 00h
HELP_CMD	equ 01h
LS_CMD		equ 02h
PEEK_CMD	equ 04h
POKE_CMD	equ 08h


title_str: 	db "GBOOT51 v.1.0", CR, LF
		db "Copyright 2025 Gino Malpartida", CR, LF, 0
newline_str:	db CR, LF,0
command_prompt_str: db "gboot51>", 0

help_str: db TAB, "Commands", CR, LF
	  db TAB, "help: shows this help.", CR, LF
	  db TAB, "Application 1: description of application 1.", CR, LF 
	  db TAB, "Application 2: description of application 2.", CR, LF
	  db TAB, "Application 3: description of application 3.", CR, LF
	  db TAB, "Application 4: description of application 4.", CR, LF
	  db TAB, "Application 5: description of application 5.", CR, LF, 0

get_command:

	mov dptr, #uart_rx_buffer
	acall uart_rx_string
	acall is_help_cmd
	jz process_help_cmd
	
	
process_help_cmd:
	
	ret

is_help_cmd:

	mov dptr, #uart_rx_buffer
	movx a, @dptr
	cjne a, #'h', not_help_cmd
	inc dptr
	movx a, @dptr
	cjne a, #'e', not_help_cmd
	inc dptr
	movx a, @dptr
	cjne a, #'l', not_help_cmd
	inc dptr
	movx a, @dptr
	cjne a, #'p', not_help_cmd
	mov a, #HELP_CMD

not_help_cmd:
	mov a, INVALID_CMD

exit_is_help_cmd:
	
	ret



