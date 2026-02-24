cseg 

do_help:
	call println
	mov dptr, #help_table
do_help_loop:
	clr a
	movc a, @a + dptr		; high byte of command
	mov r7, a				
	mov a, #1
	movc a, @a + dptr		; low byte of command
	mov r6, a
	orl a, r7
	jz do_help_exit
	mov a, #TAB
	call uart_tx_char
	push dph				; save table pointer
	push dpl
	mov dph, r7				; get address of command
	mov dpl, r6
	call uart_tx_string		; send command to uart
	mov a, #TAB
	call uart_tx_char
	call uart_tx_char
	pop dpl
	pop dph
	inc dptr				; advance to command description
	inc dptr
	clr a
	movc a, @a + dptr
	mov r7, a
	mov a, #1
	movc a, @a + dptr
	mov r6, a
	push dph
	push dpl
	mov dph, r7
	mov dpl, r6
	call uart_tx_string
	call println
	pop dpl					; restore table pointer
	pop dph
	inc dptr				; advance to next record in table
	inc dptr
	jmp do_help_loop
do_help_exit:
	ret

do_ls:
	call println
	mov dptr, #app_table
do_ls_loop:
	clr a
	movc a, @a + dptr		; high byte of app_name
	mov r7, a				
	mov a, #1
	movc a, @a + dptr		; low byte of app_name
	mov r6, a
	orl a, r7
	jz do_ls_exit
	mov a, #TAB
	call uart_tx_char
	push dph				; save table pointer
	push dpl
	mov dph, r7				; get address of app_name
	mov dpl, r6
	call uart_tx_string		; send app_name to uart
	mov a, #TAB
	call uart_tx_char
	call uart_tx_char
	pop dpl
	pop dph
	inc dptr				; advance to app description
	inc dptr
	clr a
	movc a, @a + dptr
	mov r7, a
	mov a, #1
	movc a, @a + dptr
	mov r6, a
	push dph
	push dpl
	mov dph, r7
	mov dpl, r6
	call uart_tx_string
	call println
	pop dpl					; restore table pointer
	pop dph
	inc dptr				; advance to next record in table
	inc dptr
	inc dptr
	inc dptr
	jmp do_ls_loop
	
do_ls_exit:

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
do_goto:
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

do_iram:
	call println
	mov r1, #80h
	mov r0, #00h
	mov r2, #10h
do_iram_loop:
	push 02h
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
	pop 02h
	djnz r2, do_iram_continue
	call println
	mov r2, #10h
do_iram_continue:
	inc r0
	djnz r1, do_iram_loop
	call println
	ret


do_sfr:
	call println
	mov r1, #80h
	mov r0, #80h
	mov r2, #10h
do_sfr_loop:
	push 02h
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
	pop 02h
	djnz r2, do_sfr_continue
	call println
	mov r2, #10h
do_sfr_continue:
	inc r0
	djnz r1, do_sfr_loop
	call println
	ret

