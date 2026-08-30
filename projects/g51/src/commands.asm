.include "commands.inc"
.include "conio.inc"
.include "bios.inc"
.include "ascii.inc"
.include "string.inc"
.include "vt102.inc"
.include "constants.inc"
.include "cmd_line_parser.inc"
.include "bios.inc"
.include "uart.inc"
.include "math.inc"
.include "sfr.inc"
.include "cmd_dispatch.inc"

.area CSEG (CODE)

do_help:
	lcall println

	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_help_err

	lcall cmd_dispatch_print_table

	sjmp do_help_exit

do_help_err:
	lcall do_invalid

	lcall println
do_help_exit:

	ret

do_ls:
	lcall println
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_ls_err
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
	lcall sys_putc
	push dph				; save table pointer
	push dpl
	mov dph, r7				; get address of app_name
	mov dpl, r6
	lcall sys_puts		; send app_name to uart
	mov a, #TAB
	lcall sys_putc
	lcall sys_putc
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
	lcall sys_puts
	lcall println
	pop dpl					; restore table pointer
	pop dph
	inc dptr				; advance to next record in table
	inc dptr
	inc dptr
	inc dptr
	sjmp do_ls_loop
do_ls_err:
	lcall do_invalid
do_ls_exit:
	ret

do_reset:
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_reset_err
	lcall sys_reset
do_reset_err:
	lcall do_invalid
	ret

do_peek:
	lcall println

	mov dptr, #mem_type
	lcall cmd_line_parser_next_token
	
	mov r7, #>mem_type
	mov r6, #<mem_type
	mov dptr, #xram_str
	lcall strcmp
	jc do_peek_xram_lbl
	
	mov r7, #>mem_type
	mov r6, #<mem_type
	mov dptr, #iram_str
	lcall strcmp
	jc do_peek_iram_lbl

	mov r7, #>mem_type
	mov r6, #<mem_type
	mov dptr, #rom_str
	lcall strcmp
	jc do_peek_rom_lbl

	mov r7, #>mem_type
	mov r6, #<mem_type
	mov dptr, #sfr_str
	lcall strcmp
	jc do_peek_sfr_lbl

	sjmp do_peek_err

do_peek_xram_lbl:
	lcall do_peek_xram
	jnc do_peek_err
	sjmp do_peek_exit

do_peek_iram_lbl:
	lcall do_iram
	sjmp do_peek_exit

do_peek_rom_lbl:
	lcall do_peek_rom
	jnc do_peek_err
	sjmp do_peek_exit

do_peek_sfr_lbl:
	lcall do_sfr
	sjmp do_peek_exit

do_peek_err:
	lcall do_invalid	
do_peek_exit:
	lcall println
	ret

do_peek_rom:
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	xch a, b
	jz dpr_err
	mov dptr, #hex_word
	lcall ahex2word							; address in b:a
	push a									; save in stack because
	push 0xf0								; cmd_line_parser_next_token use the registers
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token		; get length
	xch a, b
	cjne a, #0x00, dpr_len_provided
	mov b, #0x01
	mov a, #0x00
	sjmp dpr_len_read
dpr_len_provided:
	mov dptr, #hex_word
	lcall ahex2word							; length in b:a
dpr_len_read:
	mov r3, b
	mov r2, a
	lcall printtab
	mov a, #0x10
	lcall do_print_header_block
	lcall println
	mov r4, #0x10

	pop 0x07
	pop 0x06
do_peek_rom_loop:
	mov a, r2
	orl a, r3
	jz do_peek_rom_exit

	mov dph, r7
	mov dpl, r6
	clr a
	movc a, @a + dptr							; read char
	push a
	cjne r4, #0x10, dpxl_next_rom_byte
	mov b, dph
	mov a, dpl
	lcall print_hex_word
	lcall printtab
dpxl_next_rom_byte:
	inc dptr
	mov r7, dph
	mov r6, dpl
	pop a
	lcall print_hex_byte
	djnz r4, dpxl_rom_spc
	lcall println
	mov r4, #0x10
	sjmp dpxl_rom_cont
dpxl_rom_spc:
	lcall printspc
	lcall printspc
dpxl_rom_cont:
	dec r2
	cjne r2, #0xff, do_peek_rom_loop
	dec r3
	sjmp do_peek_rom_loop
dpr_err:
	clr c
	ret
do_peek_rom_exit:
	setb c
	ret

do_peek_xram:
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	xch a, b
	jz dpx_err
	mov dptr, #hex_word
	lcall ahex2word							; address in b:a
	push a
	push 0xf0
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token		; get length
	xch a, b
	cjne a, #0x00, len_provided
	mov b, #0x01
	mov a, #0x00
	sjmp dpx_len_read

len_provided:
	mov dptr, #hex_word
	lcall ahex2word							; length in b:a
dpx_len_read:
	mov r2, a
	mov r3, b
	lcall printtab
	mov a, #0x10
	lcall do_print_header_block
	lcall println
	mov r4, #0x10
	pop 0x07
	pop 0x06
do_peek_xram_loop:
	mov a, r2
	orl a, r3
	jz do_peek_xram_exit

	mov dph, r7
	mov dpl, r6
	movx a, @dptr							; read char
	push a
	cjne r4, #0x10, dpxl_next_byte
	mov b, dph
	mov a, dpl
	lcall print_hex_word
	lcall printtab
dpxl_next_byte:
	inc dptr
	mov r7, dph
	mov r6, dpl
	pop a
	lcall print_hex_byte
	djnz r4, dpxl_spc
	lcall println
	mov r4, #0x10
	sjmp dpxl_cont
dpxl_spc:
	lcall printspc
	lcall printspc
dpxl_cont:
	dec r2
	cjne r2, #0xff, do_peek_xram_loop
	dec r3
	sjmp do_peek_xram_loop
dpx_err:
	clr c
	ret
do_peek_xram_exit:
	setb c
	ret


do_poke:
	lcall println

	mov dptr, #mem_type
	lcall cmd_line_parser_next_token
	
	mov r7, #>mem_type
	mov r6, #<mem_type
	mov dptr, #xram_str
	lcall strcmp
	jc do_poke_xram_lbl
	
	mov r7, #>mem_type
	mov r6, #<mem_type
	mov dptr, #iram_str
	lcall strcmp
	jc do_poke_iram_lbl

	mov r7, #>mem_type
	mov r6, #<mem_type
	mov dptr, #sfr_str
	lcall strcmp
	jc do_poke_sfr_lbl

	sjmp do_poke_err

do_poke_xram_lbl:
	lcall do_poke_xram
	sjmp do_poke_exit
do_poke_iram_lbl:
	lcall do_poke_iram
	sjmp do_poke_exit
do_poke_sfr_lbl:
	lcall do_poke_sfr
	sjmp do_poke_exit
do_poke_err:
	lcall do_invalid
	ret
do_poke_exit:
	ret

do_poke_xram:
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token	; read xram address
	mov dptr, #hex_word
	lcall ahex2word						; address in b:a
	push a								; push low byte to stack
	push 0xf0							; push high byte to stack
do_poke_xram_loop:
	mov dptr, #hex_byte
	lcall cmd_line_parser_next_token
	xch a, b
	jz do_poke_xram_exit
	mov dptr, #hex_byte
	lcall ahex2byte						; byte in a
	pop dph
	pop dpl
	movx @dptr, a
	inc dptr
	push dpl
	push dph
	sjmp do_poke_xram_loop
do_poke_xram_exit:
	pop a								; cleanup stack
	pop a
	ret

do_poke_iram:
	mov dptr, #hex_byte
	lcall cmd_line_parser_next_token	; read iram address
	mov dptr, #hex_byte
	lcall ahex2byte						; address in a
	push a								; will use r0 as pointer into iram
do_poke_iram_loop:
	mov dptr, #hex_byte					; read each value
	lcall cmd_line_parser_next_token	
	xch a, b							; exit if token length = 0
	jz do_poke_iram_exit
	mov dptr, #hex_byte
	lcall ahex2byte						; convert to binary
	pop 0x00							; write value to iram
	mov @r0, a
	mov a, r0
	inc a
	push a
	sjmp do_poke_iram_loop

do_poke_iram_exit:
	pop a
	ret

do_poke_sfr:
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token

	mov dptr, #hex_byte
	lcall cmd_line_parser_next_token
	mov dptr, #hex_byte
	lcall ahex2byte								; return value in a

	mov dptr, #cmd_line_input_temp
	lcall write_sfr
	jnc do_poke_sfr_err
	ret

do_poke_sfr_err:
	lcall do_invalid

	ret

; fills a memory block with a specific byte
do_fill:
	lcall println
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token			; read address
	mov dptr, #hex_word
	lcall ahex2word								; address in b:a
	push 0xf0									; push b = high byte of address
	push a										; push a = low byte of address

	mov dptr, #hex_word
	lcall cmd_line_parser_next_token			; read length
	mov dptr, #hex_word
	lcall ahex2word
	push 0xf0									; push b = high byte of length
	push a										; push a = low byte of length

	mov dptr, #hex_byte
	lcall cmd_line_parser_next_token			; read fill char
	mov dptr, #hex_byte
	movx a, @dptr
	xch a, b
	inc dptr
	movx a, @dptr
	lcall asc2byte
	push a										; push a = fill char

	mov dptr, #cmd_line_input_temp				; check for trailing garbage
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_fill_err
	
	pop 0x05									; pop fill char into R5
	
	pop 0x06									; pop low byte of length
	pop 0x07									; pop high byte of length

	pop dpl										; pop low byte of address
	pop dph										; pop high byte of address

	lcall memset
	sjmp do_fill_exit
do_fill_err:
	pop a										; cleanup stack if error
	pop a
	pop a
	pop a
	pop a
	lcall do_invalid
do_fill_exit:
	ret

; copies a memory block from one location to another
do_copy:
	lcall println

	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	mov dptr, #hex_word
	lcall ahex2word
	push 0xf0
	push a

	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	mov dptr, #hex_word
	lcall ahex2word
	push 0xf0
	push a

	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_copy_err

	mov dptr, #hex_word
	lcall ahex2word
	mov R5, b
	mov R4, a
	pop 0x06
	pop 0x07
	pop dpl
	pop dph

	lcall memcpy
	sjmp do_copy_exit
do_copy_err:
	lcall do_invalid
do_copy_exit:
	ret

; jumps to a memory address in program memory
do_goto:
	lcall println
	mov dptr, #hex_word
	lcall cmd_line_parser_next_token
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_goto_err
	mov dptr, #hex_word
	lcall ahex2word

	push a
	push 0xf0
	ret
	
	sjmp do_goto_exit

do_goto_err:
	lcall do_invalid
do_goto_exit:
	ret

do_iram:
	lcall println
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_iram_err

	mov r7, #0x01
	lcall printtab
	mov a, #0x10
	lcall do_print_header_block
	lcall println
	mov r7, #0x08				; how many rows
	mov r0, #0x00				; starting address
do_iram_row_loop:
	mov r6, #0x10				; how many columns
	mov a, r0
	mov b, a
	swap a
	anl a, #0x0f
	lcall nibble2ahex
	lcall sys_putc
	mov a, b
	anl a, #0x0f
	lcall nibble2ahex
	lcall sys_putc
	push 0x07
	mov r7, #0x01
	lcall printtab
	pop 0x07
do_iram_col_loop:
	mov a, @r0
	mov b, a
	swap a
	anl a, #0x0f
	lcall nibble2ahex
	lcall sys_putc
	mov a, b
	anl a, #0x0f
	lcall nibble2ahex
	lcall sys_putc
	mov a, #SPC
	lcall sys_putc
	lcall sys_putc
	inc r0
	djnz r6, do_iram_col_loop
	lcall println
	djnz r7, do_iram_row_loop
	sjmp do_iram_exit
do_iram_err:
	lcall do_invalid
do_iram_exit:
	ret

do_sfr:
	lcall println
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_sfr_err
	lcall print_sfr_table
	sjmp do_sfr_exit
do_sfr_err:
	lcall do_invalid
do_sfr_exit:
	ret

do_clear:
	mov dptr, #cmd_line_input_temp
	lcall cmd_line_parser_next_token
	xch a, b
	jnz do_clear_err
	lcall sys_clrscrn
	sjmp do_clear_exit
do_clear_err:
	lcall do_invalid
do_clear_exit:
	ret

do_invalid:
	lcall println
    mov dptr, #msg_err
    lcall sys_puts
	lcall println
	ret

do_load:
	lcall println
	mov dptr, #hex_word							; read address
	lcall cmd_line_parser_next_token
	xch a, b
	jnz dl_got_address
	ljmp dl_err
dl_got_address:
	mov dptr, #cmd_line_input_temp				; check for any unneeded input
	lcall cmd_line_parser_next_token
	xch a, b
	jz dl_no_more_params
	ljmp dl_err
dl_no_more_params:
	mov dptr, #hex_word							; contains the address
	lcall read_hex_byte
	inc dptr
	push dpl
	push dph
	mov dptr, #ihex_address
	movx @dptr, a
	pop dph
	pop dpl
	lcall read_hex_byte
	mov dptr, #(ihex_address+1)					; ihex_address contains address where to load hex file
	movx @dptr, a

dl_loop:
	lcall sys_getc
	cjne a, #':', dl_loop			; discard any character before ':'
	mov dptr, #ihex_checksum
	mov a, #0x00
	movx @dptr, a
dl_record_length:					; read 2 ascii characters
	lcall get_hex_byte
	mov dptr, #ihex_record_length	; save to ihex_byte_count
	movx @dptr, a
	lcall dl_add_to_checksum
dl_address:							; read 4 ascii characters
	lcall get_hex_byte
	lcall dl_add_to_checksum
	lcall get_hex_byte
	lcall dl_add_to_checksum
dl_record_type:						
	lcall get_hex_byte
	lcall dl_add_to_checksum
	mov dptr, #ihex_record_type
	movx @dptr, a

	mov dptr, #ihex_record_length
	movx a, @dptr
	mov R7, a
	jz dl_checksum
dl_payload_loop:					; read 2 ascii characters on each iteration
	lcall get_hex_byte
	push a							; save data byte
	mov dptr, #ihex_address
	movx a, @dptr					; read high byte of destination address
	push a
	inc dptr
	movx a, @dptr					; read low byte of destination address
	mov dpl, a
	pop dph							; dptr points to destination address
	pop a							; restore data from stack
	movx @dptr, a					; write data to destination address
	lcall dl_add_to_checksum
	inc dptr
	push dpl
	push dph
	mov dptr, #ihex_address
	pop a
	movx @dptr, a
	inc dptr
	pop a
	movx @dptr, a
	djnz R7, dl_payload_loop
dl_checksum:						; read 2 ascii characters
	lcall get_hex_byte
	lcall dl_add_to_checksum
	mov dptr, #ihex_checksum
	movx a, @dptr
	lcall dl_print_marker
dl_check_eof:
	lcall printspc
	mov dptr, #ihex_record_type
	movx a, @dptr
	jnz dl_exit
	ljmp dl_loop
dl_err:
	lcall do_invalid
dl_exit:
	lcall println
	ret
	
dl_print_marker:
	jnz dl_error_marker			; a contains the total checksum
	mov a, #'.'
	lcall sys_putc
	sjmp dl_print_marker_exit
dl_error_marker:
	mov a, #'x'
	lcall sys_putc
dl_print_marker_exit:
	ret

dl_add_to_checksum:
	push a
	push 0xf0
	push dpl
	push dph
	mov b, a
	mov dptr, #ihex_checksum
	movx a, @dptr
	add a, b
	movx @dptr, a
	pop dph
	pop dpl
	pop 0xf0
	pop a

	ret

do_print_header_block:
	mov r0, a
	mov r1, #0x00
dphb_loop:
	mov a, r1
	lcall byte2ahex
	xch a, b
	lcall sys_putc
	xch a, b
	lcall sys_putc
	lcall printspc
	lcall printspc
	inc r1
	djnz r0, dphb_loop

	ret

do_test:
	
	mov r0, #0x05
do_test_loop:
	lcall println

	lcall get_hex_word

	push 0xf0
	push a

	lcall print_hex_word

	lcall printspc
	mov a, #'+'
	lcall sys_putc
	lcall printspc

	lcall get_hex_word

	push 0xf0
	push a
	lcall print_hex_word

	pop a
	pop 0xf0

	pop dpl
	pop dph

	lcall add16

	push a
	push 0xf0

	lcall printspc
	mov a, #'='
	lcall sys_putc
	lcall printspc
	pop 0xf0
	pop a

	lcall print_hex_word

	lcall println
	djnz r0, do_test_loop
	ret

.area XSEG (XDATA)

mem_type:				.ds			0x10
hex_word:				.ds			0x10
hex_byte:				.ds			0x10
cmd_line_input_temp:	.ds			0x10
ihex_record_length:		.ds			0x01
ihex_address:			.ds			0x02
ihex_checksum:			.ds			0x01
ihex_record_type:		.ds			0x01

