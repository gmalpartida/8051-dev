do_help:
	call println
    mov dptr, #help_str
    call uart_tx_string
	ret

do_ls:
	call println
    mov dptr, #ls_str
    call uart_tx_string
	ret

do_peek:
	call println
	call skip_blanks
	call get_hex_address
	inc r0
	mov r7, a
	call get_hex_address
	mov r6, a

	mov dph, r7
	mov dpl, r6

	movx a, @dptr
	mov b, a
	swap a
	anl a, #0fh
	call bin2asc
	call uart_tx_char
	mov a, b
	anl a, #0fh
	call bin2asc
	call uart_tx_char
	call println
	ret

do_poke:
	call println
	call skip_blanks
	call get_hex_address
	inc r0
	mov r7, a
	call get_hex_address
	mov r6, a
	inc r0
	call skip_blanks
	call get_hex_address
	mov r5, a
	mov dph, r7
	mov dpl, r6
	mov a, r5
	movx @dptr, a 
	call println
	ret

do_dump:
	call println
	call skip_blanks
	call get_hex_address
	mov r7, a
	mov a, #TAB
	call uart_tx_char	
	call print_dump_header
	call println

	mov r6, #00h
	mov r5, #10h
do_dump_loop:
	call print_row_address
	call print_row_data
	call println
	mov a, r6
	add a, #10h
	mov r6, a
	djnz r5, do_dump_loop
	ret

print_row_data:
	mov dph, r7
	mov dpl, r6
	mov r4, #10h
print_row_data_loop:
	movx a, @dptr
	mov b, a
	swap a
	anl a, #0fh
	call bin2asc
	call uart_tx_char
	mov a, b
	anl a, #0fh
	call bin2asc
	call uart_tx_char
	mov a, #' '
	call uart_tx_char
	call uart_tx_char
	inc dptr
	djnz r4, print_row_data_loop
	ret
print_row_address:
	mov a, r7
	swap a
	anl a, #0fh
	call bin2asc
	call uart_tx_char
	mov a, r7
	anl a, #0fh
	call bin2asc
	call uart_tx_char
	mov a, r6
	swap a
	anl a, #0fh
	call bin2asc
	call uart_tx_char
	mov a, r6
	anl a, #0fh
	call bin2asc
	call uart_tx_char
	mov a, #' '
	call uart_tx_char
	call uart_tx_char
	call uart_tx_char
	call uart_tx_char
	ret

clear_screen:
	mov dptr, #clear_screen_seq
	call uart_tx_string
	ret

print_dump_header:
	mov r4, #0ffh
	mov r3, #10h
print_dump_header_loop:
	inc r4
	mov a, #'0'
	call uart_tx_char
	mov a, r4
	anl a, #0fh
	call bin2asc
	call uart_tx_char
	mov a, #' '
	call uart_tx_char
	mov a, #' '
	call uart_tx_char
	djnz r3, print_dump_header_loop

	ret

; fills a memory block with a specific byte
do_fill:
	call println	
	call skip_blanks
	call get_hex_address
	mov r6, a
	inc r0
	call get_hex_address
	mov r7, a
	inc r0
	call skip_blanks
	call get_hex_address
	mov r5, a
	inc r0
	call skip_blanks
	call get_hex_address
	mov r4, a
	
	call memset
	ret

; moves a memory block from one location to another
do_move:
	call println
	call skip_blanks
	call get_hex_address
	mov r6, a
	inc r0
	call get_hex_address
	mov r7, a
	inc r0
	call skip_blanks
	call get_hex_address
	mov r4, a
	inc r0
	call get_hex_address
	mov r5, a
	inc r0
	call skip_blanks
	call get_hex_address
	mov r3, a
	call memcpy

	ret

; jumps to a memory address in program memory
; --> r6, r7: memmory address in program memory
do_jump:
	call println
	call skip_blanks
	call get_hex_address
	mov r6, a
	inc r0
	call get_hex_address
	mov r7, a

	push 07h
	push 06h
	ret

	ret

do_sfr:
	mov r1, #0ffh
	mov r0, #00h
do_sfr_loop:
	mov a, @r0
	mov b, a
	swap a
	anl a, #0fh
	call bin2asc
	call uart_tx_char
	mov a, b
	anl a, #0fh
	call bin2asc
	call uart_tx_char
	mov a, #' '
	call uart_tx_char
	call uart_tx_char

	inc r0
	djnz r1, do_sfr_loop

	ret


