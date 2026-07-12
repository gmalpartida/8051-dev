.include "uart.inc"
.include "constants.inc"
.include "conio.inc"
.include "commands.inc"
.include "string.inc"
.include "logo.inc"

.area vectors
    ljmp main
ie0_isr:
	reti
	.blkb	0x07
tf0_isr:
	reti
	.blkb	0x07
ie1_isr:
	reti
	.blkb	0x07
tf1_isr:
	reti
	.blkb	0x07
ser_isr:
	ljmp uart_rx_isr

.area cseg
main:
    mov sp, 0h2f					; Initialize Stack
    lcall uart_init					; Setup UART

	setb es							; enable serial interrupt
	setb ea							; enable global interrupt

	lcall clear_screen

	mov dptr, #g51_logo
	lcall uart_tx_asciz

	lcall println

	mov dptr, #title_str
	lcall uart_tx_asciz
	lcall println

cmd_prompt:

    mov dptr, #command_prompt_str
    lcall uart_tx_asciz
    
	mov dptr, #cmd_line_buffer
	lcall uart_rx_asciz

	lcall println
	sjmp cmd_prompt
stop:
	sjmp stop

    ; --- COMMAND PARSER ---
    ; Check for "help"
check_help:
    mov dptr, #cmd_line_buffer
	lcall skip_blanks
    MOV DPTR, #help_txt
	mov r2, #4
    lcall strncmp
	cjne a, #0, check_ls
    lcall do_help
	sjmp cmd_prompt

    ; Check for "ls"
check_ls:
    mov dptr, #cmd_line_buffer
	lcall skip_blanks
    mov dptr, #ls_txt
	mov r2, #2
    lcall strncmp
	cjne a, #0, check_peek
    lcall do_ls
	sjmp cmd_prompt

check_peek:
	mov dptr, #cmd_line_buffer
	lcall skip_blanks
	mov dptr, #peek_txt
	mov r2, #4
	lcall strncmp
	cjne a, #0, check_poke
	lcall do_peek
	sjmp cmd_prompt

check_poke:
	mov dptr, #cmd_line_buffer
	lcall skip_blanks
	mov dptr, #poke_txt
	mov r2, #4
	lcall strncmp
	cjne a, #0, check_dump
	lcall do_poke
	ljmp cmd_prompt

check_dump:
	mov dptr, #cmd_line_buffer
	lcall skip_blanks
	mov dptr, #dump_txt
	mov r2, #4
	lcall strncmp
	cjne a, #0, check_reset
	lcall do_dump
	ljmp cmd_prompt

check_reset:
	mov dptr, #cmd_line_buffer
	lcall skip_blanks
	mov dptr, #reset_txt
	mov r2, #5
	lcall strncmp
	cjne a, #0, check_clear
	ljmp main	

check_clear:
	mov dptr, #cmd_line_buffer
	lcall skip_blanks
	mov dptr, #clear_txt
	lcall strncmp
	cjne a, #0, check_fill
	lcall clear_screen
	ljmp cmd_prompt

check_fill:
	mov dptr, #cmd_line_buffer
	lcall skip_blanks
	mov dptr, #fill_txt
	mov r2, #4
	lcall strncmp
	cjne a, #0, check_copy
	lcall do_fill
	ljmp cmd_prompt

check_copy:
	mov dptr, #cmd_line_buffer
	lcall skip_blanks
	mov dptr, #copy_txt
	mov r2, #4
	lcall strncmp
	cjne a, #0, check_goto
	lcall do_copy
	ljmp cmd_prompt

check_goto:
	mov dptr, #cmd_line_buffer
	lcall skip_blanks
	mov dptr, #goto_txt
	mov r2, #4
	lcall strncmp
	cjne a, #0, check_iram
	lcall do_goto
	ljmp cmd_prompt

check_iram:
	mov dptr, #cmd_line_buffer
	lcall skip_blanks
	mov dptr, #iram_txt
	mov r2, #4
	lcall strncmp
	cjne a, #0, check_sfr
	lcall do_iram
	ljmp cmd_prompt

check_sfr:
	mov dptr, #cmd_line_buffer
	lcall skip_blanks
	mov dptr, #sfr_txt
	mov r2, #3
	lcall strncmp
	cjne a, #0, check_write
	lcall do_sfr
	ljmp cmd_prompt

check_write:
	mov dptr, #cmd_line_buffer
	lcall skip_blanks
	mov dptr, #write_txt
	mov r2, #5
	lcall strncmp
	cjne a, #0, unknown
	lcall do_write
	ljmp cmd_prompt
	
    ; Unknown command
unknown:
	lcall println
	mov dptr, #cmd_line_buffer
	mov a, @r0
	jz unknown_cmd_prompt
    mov dptr, #msg_err
    lcall uart_tx_asciz
	lcall println
unknown_cmd_prompt:
    ljmp cmd_prompt

halt:
	sjmp halt

.area _XSEG (REL, CON, XDATA)
cmd_line_buffer::			.blkb		0x0100



