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
	call nibble2asc
	call uart_tx_char
	mov a, b
	anl a, #0fh
	call nibble2asc
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
	call nibble2asc
	call uart_tx_char
	mov a, b
	anl a, #0fh
	call nibble2asc
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
	call nibble2asc
	call uart_tx_char
	mov a, r7
	anl a, #0fh
	call nibble2asc
	call uart_tx_char
	mov a, r6
	swap a
	anl a, #0fh
	call nibble2asc
	call uart_tx_char
	mov a, r6
	anl a, #0fh
	call nibble2asc
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
	call nibble2asc
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

; copies a memory block from one location to another
do_copy:
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
	mov a, p0
	call uart_tx_char
	call println
	mov a, pcon
	call uart_tx_char
	call println
	mov a, tcon
	call uart_tx_char
	call println
	mov a, tmod
	ret


do_sfr:
	call println

	mov dptr, #p0_txt
	mov a, p0
	call print_sfr_reg
	mov r7, #1
	call printtab
	mov dptr, #p1_txt

	mov a, p1
	call print_sfr_reg
	mov dptr, #p2_txt
	mov r7, #1
	call printtab

	mov a, p2
	call print_sfr_reg
	mov r7, #1
	call printtab

	mov dptr, #p3_txt
	mov a, p3
	call print_sfr_reg
	mov r7, #1
	call printtab

	call println

	mov dptr, #pcon_txt
	mov a, pcon
	call print_sfr_reg
	mov r7, #1
	call printtab
	
	mov dptr, #psw_txt
	mov a, psw
	call print_sfr_reg
	mov r7, #1
	call printtab

	mov dptr, #ip_txt
	mov a, ip
	call print_sfr_reg
	mov r7, #1
	call printtab

	mov dptr, #ie_txt
	mov a, ie
	call print_sfr_reg
	mov r7, #1
	call printtab
	call println

	mov dptr, #tcon_txt
	mov a, tcon
	call print_sfr_reg
	mov r7, #1
	call printtab
	mov dptr, #tmod_txt
	mov a, tmod
	call print_sfr_reg
	mov r7, #1
	call printtab
	mov dptr, #tl0_txt
	mov a, tl0
	call print_sfr_reg
	mov r7, #1
	call printtab
	mov dptr, #tl1_txt
	mov a, tl1
	call print_sfr_reg
	mov r7, #1
	call printtab
	mov dptr, #th0_txt
	mov a, th0
	call print_sfr_reg
	mov r7, #1
	call printtab
	mov dptr, #th1_txt
	mov a, th1
	call print_sfr_reg
	call println

	mov dptr, #scon_txt
	mov a, scon
	call print_sfr_reg
	mov r7, #1
	call printtab
	mov dptr, #sbuf_txt
	mov a, sbuf
	call print_sfr_reg
	call println

	mov dptr, #acc_txt
	call print_sfr_reg
	mov r7, #1
	call printtab
	mov dptr, #b_txt
	mov a, b
	call print_sfr_reg
	call println

	call println
	ret

; prints the contents of an sfr register
; --> dptr: address of register name
; --> a: contents of register
; <-- none
print_sfr_reg:
	push 0e0h					; save contents of a register
	call uart_tx_string
	mov a, #TAB
	call uart_tx_char
	pop 0e0h
	call hex2asc
	push 0e0h
	mov a, b
	call uart_tx_char
	pop 0e0h
	call uart_tx_char
	
	ret
