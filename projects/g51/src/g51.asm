cseg at 0000h
    ljmp main

cseg at 0030h
main:
    mov sp, #60h        ; Initialize Stack
    call uart_init     ; Setup UART

	call clear_screen

	mov dptr, #g51_logo
	call uart_tx_string

	call println

	mov dptr, #title_str
	call uart_tx_string
	call println

cmd_prompt:

    mov dptr, #command_prompt_str
    call uart_tx_string
    
    ; Setup Buffer for input (starting at RAM 30H)
    mov r0, #30H
    call uart_rx_string
    
    ; --- COMMAND PARSER ---
    ; Check for "help"
check_help:
    MOV R0, #30H
	call skip_blanks
    MOV DPTR, #help_txt
	mov r2, #4
    call strncmp
	cjne a, #0, check_ls
    call do_help
	jmp cmd_prompt

    ; Check for "ls"
check_ls:
    mov r0, #30H
	call skip_blanks
    mov dptr, #ls_txt
	mov r2, #2
    call strncmp
	cjne a, #0, check_peek
    call do_ls
	jmp cmd_prompt

check_peek:
	mov r0, #30h
	call skip_blanks
	mov dptr, #peek_txt
	mov r2, #4
	call strncmp
	cjne a, #0, check_poke
	call do_peek
	jmp cmd_prompt

check_poke:
	mov r0, #30h
	call skip_blanks
	mov dptr, #poke_txt
	mov r2, #4
	call strncmp
	cjne a, #0, check_dump
	call do_poke
	jmp cmd_prompt

check_dump:
	mov r0, #30h
	call skip_blanks
	mov dptr, #dump_txt
	mov r2, #4
	call strncmp
	cjne a, #0, check_reset
	call do_dump
	jmp cmd_prompt

check_reset:
	mov r0, #30h
	call skip_blanks
	mov dptr, #reset_txt
	mov r2, #5
	call strncmp
	cjne a, #0, check_clear
	jmp main	

check_clear:
	mov r0, #30h
	call skip_blanks
	mov dptr, #clear_txt
	call strcmp
	cjne a, #0, check_fill
	call clear_screen
	jmp cmd_prompt

check_fill:
	mov r0, #30h
	call skip_blanks
	mov dptr, #fill_txt
	mov r2, #4
	call strncmp
	cjne a, #0, check_copy
	call do_fill
	jmp cmd_prompt

check_copy:
	mov r0, #30h
	call skip_blanks
	mov dptr, #copy_txt
	mov r2, #4
	call strncmp
	cjne a, #0, check_goto
	call do_copy
	jmp cmd_prompt

check_goto:
	mov r0, #30h
	call skip_blanks
	mov dptr, #goto_txt
	mov r2, #4
	call strncmp
	cjne a, #0, check_iram
	call do_goto
	jmp cmd_prompt

check_iram:
	mov r0, #30h
	call skip_blanks
	mov dptr, #iram_txt
	mov r2, #4
	call strncmp
	cjne a, #0, check_sfr
	call do_iram
	jmp cmd_prompt

check_sfr:
	mov r0, #30h
	call skip_blanks
	mov dptr, #sfr_txt
	mov r2, #3
	call strncmp
	cjne a, #0, check_write
	call do_sfr
	jmp cmd_prompt

check_write:
	mov r0, #30h
	call skip_blanks
	mov dptr, #write_txt
	mov r2, #5
	call strncmp
	cjne a, #0, unknown
	call do_write
	jmp cmd_prompt
	
    ; Unknown command
unknown:
	call println
	mov r0, #30h
	mov a, @r0
	jz unknown_cmd_prompt
    mov dptr, #msg_err
    call uart_tx_string
	call println
unknown_cmd_prompt:
    jmp cmd_prompt

halt:
	jmp halt

get_hex_address:
	mov a, @r0
	call asc2nibble
	inc r0
	mov b, a
	mov a, @r0
	call asc2nibble
	swap a
	anl a, #0f0h
	orl a, b
	swap a
	ret

skip_blanks:
	mov a, @r0
	jz skip_blanks_exit
	cjne a, #' ', skip_blanks_exit
	inc r0
	jmp skip_blanks

skip_blanks_exit:
	ret

println:
	mov dptr, #newline_str
	call uart_tx_string
	ret

; prints tab(s)
; --> r7: how many tabs to print
printtab:
	mov a, #TAB

	call uart_tx_char
	djnz r7, printtab
	ret

; prints space(s)
; --> r7: how many spaces to print
printspc:
	mov a, #' '
	call uart_tx_char
	djnz r7, printspc
	ret

; performs a memory test, copying a text from program memory into several locations in data memory.
; then they are verified.
; --> none
; <-- none
mem_test:
	mov r6, #high(a_short_text)
	mov r7, #low(a_short_text)
	mov r4, #10h
	mov r5, #00h
	mov r3, #44
	call memcpy_c
	
	mov r6, #high(a_short_text)
	mov r7, #low(a_short_text)
	mov r4, #10h
	mov r5, #00h
	mov r3, #44
	call memcmp_c
	
	cjne r7, #00h, mem_test_fail
	mov dptr, #mem_test_success_msg
	call uart_tx_string

mem_test_fail:
	mov dptr, #mem_test_fail_msg
	call uart_tx_string
	ret


$INCLUDE (constants.inc)
$INCLUDE (uart.inc)
$INCLUDE (g51-logo.inc)
$include (string.inc)
$include (ascii.inc)
$include (commands.inc)
$include (vt102.inc)
$include (apps.inc)
$include (cmd_dispatch.inc)
end

