.include "commands.inc"
.include "conio.inc"
.include "uart.inc"
.include "ascii.inc"
.include "string.inc"
.include "vt102.inc"
.include "constants.inc"

.area cseg (CODE)

do_help:
	lcall println
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
	lcall uart_tx_char
	push dph				; save table pointer
	push dpl
	mov dph, r7				; get address of command
	mov dpl, r6
	lcall uart_tx_asciz; send command to uart
	mov a, #TAB
	lcall uart_tx_char
	lcall uart_tx_char
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
	lcall uart_tx_asciz
	lcall println
	pop dpl					; restore table pointer
	pop dph
	inc dptr				; advance to next record in table
	inc dptr
	sjmp do_help_loop
do_help_exit:
	ret

do_ls:
	lcall println
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
	lcall uart_tx_char
	push dph				; save table pointer
	push dpl
	mov dph, r7				; get address of app_name
	mov dpl, r6
	lcall uart_tx_asciz		; send app_name to uart
	mov a, #TAB
	lcall uart_tx_char
	lcall uart_tx_char
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
	lcall uart_tx_asciz
	lcall println
	pop dpl					; restore table pointer
	pop dph
	inc dptr				; advance to next record in table
	inc dptr
	inc dptr
	inc dptr
	sjmp do_ls_loop
	
do_ls_exit:
	ret

do_peek:
	lcall println
	lcall skip_blanks
	lcall get_hex_address
	inc r0
	mov r7, a
	lcall get_hex_address
	mov r6, a

	mov dph, r7
	mov dpl, r6

	movx a, @dptr
	mov b, a
	swap a
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	mov a, b
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	lcall println
	ret

do_poke:
	lcall println
	lcall skip_blanks
	lcall get_hex_address
	inc r0
	mov r7, a
	lcall get_hex_address
	mov r6, a
	inc r0
	lcall skip_blanks
	lcall get_hex_address
	mov r5, a
	mov dph, r7
	mov dpl, r6
	mov a, r5
	movx @dptr, a 
	lcall println
	ret

do_dump:
	lcall println
	lcall skip_blanks
	lcall get_hex_address
	mov r7, a
	mov a, #TAB
	lcall uart_tx_char	
	acall print_dump_header
	lcall println

	mov r6, #0x00
	mov r5, #0x10
do_dump_loop:
	acall print_row_address
	acall print_row_data
	lcall println
	mov a, r6
	add a, #0x10
	mov r6, a
	djnz r5, do_dump_loop
	ret

print_row_data:
	mov dph, r7
	mov dpl, r6
	mov r4, #0x10
print_row_data_loop:
	movx a, @dptr
	mov b, a
	swap a
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	mov a, b
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	mov a, #' '
	lcall uart_tx_char
	lcall uart_tx_char
	inc dptr
	djnz r4, print_row_data_loop
	ret

print_row_address:
	mov a, r7
	swap a
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	mov a, r7
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	mov a, r6
	swap a
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	mov a, r6
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	mov a, #' '
	lcall uart_tx_char
	lcall uart_tx_char
	lcall uart_tx_char
	lcall uart_tx_char
	ret

clear_screen:
	mov dptr, #VT102_CLEAR_SCREEN
	lcall uart_tx_asciz
	ret

print_dump_header:
	mov r4, #0xff
	mov r3, #0x10
print_dump_header_loop:
	inc r4
	mov a, #'0'
	lcall uart_tx_char
	mov a, r4
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	mov a, #' '
	lcall uart_tx_char
	mov a, #' '
	lcall uart_tx_char
	djnz r3, print_dump_header_loop

	ret

; fills a memory block with a specific byte
do_fill:
	lcall println	
	lcall skip_blanks
	lcall get_hex_address
	mov r6, a
	inc r0
	lcall get_hex_address
	mov r7, a
	inc r0
	lcall skip_blanks
	lcall get_hex_address
	mov r5, a
	inc r0
	lcall skip_blanks
	lcall get_hex_address
	mov r4, a
	
	lcall memset
	ret

; copies a memory block from one location to another
do_copy:
	lcall println
	lcall skip_blanks
	lcall get_hex_address
	mov r6, a
	inc r0
	lcall get_hex_address
	mov r7, a
	inc r0
	lcall skip_blanks
	lcall get_hex_address
	mov r4, a
	inc r0
	lcall get_hex_address
	mov r5, a
	inc r0
	lcall skip_blanks
	lcall get_hex_address
	mov r3, a
	lcall memcpy
	ret

; jumps to a memory address in program memory
; --> r6, r7: memmory address in program memory
do_goto:
	lcall println
	lcall skip_blanks
	lcall get_hex_address
	mov r6, a
	inc r0
	lcall get_hex_address
	mov r7, a

	push 0x07
	push 0x06
	ret

	ret

do_iram:
	lcall println
	mov r7, #0x01
	lcall printtab
	acall print_dump_header
	lcall println
	mov r7, #0x08				; how many rows
	mov r0, #0x00				; starting address
do_iram_row_loop:
	mov r6, #0x10				; how many columns
	mov a, r0
	mov b, a
	swap a
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	mov a, b
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	push 0x07
	mov r7, #0x01
	lcall printtab
	pop 0x07
do_iram_col_loop:
	mov a, @r0
	mov b, a
	swap a
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	mov a, b
	anl a, #0x0f
	lcall nibble2asc
	lcall uart_tx_char
	mov a, #SPC
	lcall uart_tx_char
	lcall uart_tx_char
	inc r0
	djnz r6, do_iram_col_loop
	lcall println
	djnz r7, do_iram_row_loop
	ret

do_sfr:
	lcall println

	mov dptr, #p0_txt
	mov a, p0
	acall print_sfr_reg
	mov r7, #1
	lcall printtab
	mov dptr, #p1_txt

	mov a, p1
	acall print_sfr_reg
	mov dptr, #p2_txt
	mov r7, #1
	lcall printtab

	mov a, p2
	acall print_sfr_reg
	mov r7, #1
	lcall printtab

	mov dptr, #p3_txt
	mov a, p3
	acall print_sfr_reg
	mov r7, #1
	lcall printtab

	lcall println

	mov dptr, #pcon_txt
	mov a, pcon
	acall print_sfr_reg
	mov r7, #1
	lcall printtab
	
	mov dptr, #psw_txt
	mov a, psw
	acall print_sfr_reg
	mov r7, #1
	lcall printtab

	mov dptr, #ip_txt
	mov a, ip
	acall print_sfr_reg
	mov r7, #1
	lcall printtab

	mov dptr, #ie_txt
	mov a, ie
	acall print_sfr_reg
	mov r7, #1
	lcall printtab
	lcall println

	mov dptr, #tcon_txt
	mov a, tcon
	acall print_sfr_reg
	mov r7, #1
	lcall printtab
	mov dptr, #tmod_txt
	mov a, tmod
	acall print_sfr_reg
	mov r7, #1
	lcall printtab
	mov dptr, #tl0_txt
	mov a, tl0
	acall print_sfr_reg
	mov r7, #1
	lcall printtab
	mov dptr, #tl1_txt
	mov a, tl1
	acall print_sfr_reg
	mov r7, #1
	lcall printtab
	mov dptr, #th0_txt
	mov a, th0
	acall print_sfr_reg
	mov r7, #1
	lcall printtab
	mov dptr, #th1_txt
	mov a, th1
	acall print_sfr_reg
	lcall println

	mov dptr, #scon_txt
	mov a, scon
	acall print_sfr_reg
	mov r7, #1
	lcall printtab
	mov dptr, #sbuf_txt
	mov a, sbuf
	acall print_sfr_reg
	lcall println

	mov dptr, #acc_txt
	acall print_sfr_reg
	mov r7, #1
	lcall printtab
	mov dptr, #b_txt
	mov a, b
	acall print_sfr_reg
	lcall println

	lcall println
	ret

; prints the contents of an sfr register
; --> dptr: address of register name
; --> a: contents of register
; <-- none
print_sfr_reg:
	push 0xe0					; save contents of a register
	lcall uart_tx_asciz
	mov a, #TAB
	lcall uart_tx_char
	pop 0xe0
	lcall hex2asc
	push 0xe0
	mov a, b
	lcall uart_tx_char
	pop 0xe0
	lcall uart_tx_char
	
	ret

do_write:
	lcall println
	lcall skip_blanks
	mov a, @r0
	cjne a, #'p', do_write_error
	inc r0
	mov a, @r0
	inc r0
	cjne a, #'0', do_write_not_0
	lcall skip_blanks
	lcall get_hex_address
	mov p0, a
	sjmp do_write_exit
do_write_not_0:
	cjne a, #'1', do_write_not_1
	lcall skip_blanks
	lcall get_hex_address
	mov p1, a
	sjmp do_write_exit
do_write_not_1:
	cjne a, #'2', do_write_not_2
	lcall skip_blanks
	lcall get_hex_address
	mov p2, a
	sjmp do_write_exit
do_write_not_2:
	cjne a, #'3', do_write_not_3
	lcall skip_blanks
	lcall get_hex_address
	mov p3, a
	sjmp do_write_exit
do_write_not_3:
	cjne a, #'c', do_write_not_pcon
	inc r0
	mov a, @r0
	cjne a, #'o', do_write_error
	inc r0
	mov a, @r0
	cjne a, #'n', do_write_error
	inc r0
	lcall skip_blanks
	lcall get_hex_address
	mov pcon, a
	sjmp do_write_exit
do_write_not_pcon:
do_write_error:
	setb c
	ret
do_write_exit:
	clr c
	ret

