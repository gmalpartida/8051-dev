cseg at 00h
	ljmp main
; space reserved for vector table
ie0_vector:
	ljmp $
	ds 5
tf0_vector:
	ljmp $
	ds 5
ie1_vector:
	ljmp $
	ds 5
tf1_vector:
	ljmp $
	ds 5
serial_vector:
	ljmp $
	ds 5

main:
	acall uart_init_baud_gen

	mov dptr, #newline_str
	acall uart_tx_string_from_cseg
	mov dptr, #g51_logo
	acall uart_tx_string_from_cseg
	mov dptr, #title_str
	acall uart_tx_string_from_cseg
	mov dptr, #newline_str
	acall uart_tx_string_from_cseg

command_prompt_loop:
	mov dptr, #command_prompt_str
	acall uart_tx_string_from_cseg
	
	mov dptr, #uart_rx_buffer
	acall uart_rx_string

	; help command
	mov dptr, #uart_rx_buffer
	call skip_blanks
	jz command_prompt_loop
	mov r1, dph
	mov r0, dpl
	mov dptr, #help_txt
	call cmd_cmp
	jz do_help_cmd
	jmp is_ls_cmd
do_help_cmd:
	call process_help_cmd
	jmp command_prompt_loop
	; ls command
is_ls_cmd:
	mov dptr, #uart_rx_buffer
	call skip_blanks
	jz command_prompt_loop
	mov r1, dph
	mov r0, dpl
	mov dptr, #ls_txt
	call cmd_cmp
	jz do_ls_cmd
	jmp is_peek_cmd
do_ls_cmd:
	call process_ls_cmd
	jmp command_prompt_loop
	; peek command
is_peek_cmd:
	mov dptr, #uart_rx_buffer
	call skip_blanks
	jz command_prompt_loop
	mov r1, dph
	mov r0, dpl
	mov dptr, #peek_txt
	call cmd_cmp
	jz do_peek_cmd
	jmp is_poke_cmd
do_peek_cmd:
	call process_peek_cmd
	jmp command_prompt_loop
	; poke command
is_poke_cmd:
	mov dptr, #uart_rx_buffer
	call skip_blanks
	jz command_prompt_loop
	mov r1, dph
	mov r0, dpl
	mov dptr, #poke_txt
	call cmd_cmp
	jz do_poke_cmd
	jmp is_dump_cmd
do_poke_cmd:
	call process_poke_cmd
	jmp command_prompt_loop
	; dump command
is_dump_cmd:
	mov dptr, #uart_rx_buffer
	call skip_blanks
	jnz cont_dump_cmd
	jmp command_prompt_loop
cont_dump_cmd:
	mov r1, dph
	mov r0, dpl
	mov dptr, #dump_txt
	call cmd_cmp
	jz do_dump_cmd
	jmp is_clear_cmd
do_dump_cmd:
	call process_dump_cmd
	jmp command_prompt_loop
	; clear command
is_clear_cmd:
	mov dptr, #uart_rx_buffer
	call skip_blanks
	jnz cont_clear_cmd
	jmp command_prompt_loop
cont_clear_cmd:
	mov r1, dph
	mov r0, dpl
	mov dptr, #clear_txt
	call cmd_cmp
	jz do_clear_cmd
	jmp goto_invalid_cmd
do_clear_cmd:
	call process_clear_cmd
	jmp command_prompt_loop
	; invalid command
goto_invalid_cmd:
	call process_invalid_cmd
	jmp command_prompt_loop

halt:
	jmp halt

process_help_cmd:
	mov dpl, r0
	mov dph, r1
	call skip_blanks
	movx a, @dptr
	jnz help_cmd_error
	mov dptr, #help_str
	acall uart_tx_string_from_cseg
	ret

help_cmd_error:
	call process_invalid_cmd
	ret

process_ls_cmd:
	mov dpl, r0
	mov dph, r1
	call skip_blanks
	movx a, @dptr
	jnz ls_cmd_error
	mov dptr, #ls_str
	acall uart_tx_string_from_cseg
	ret

ls_cmd_error:
	call process_invalid_cmd
	ret

process_peek_cmd:
	mov dpl, r0
	mov dph, r1
	call skip_blanks
	jz peek_cmd_error

	call addrtoi

	mov dph, b
	mov dpl, a

	movx a, @dptr
	call itoa
	; backup hex characters
	mov r4, a
	mov r5, b

	mov b, r5
	
	mov a, b

	call uart_tx_char

	mov a, r4
	
	call uart_tx_char
	call println

	ret
peek_cmd_error:
	call process_invalid_cmd
	ret

process_poke_cmd:

	push 02h		; push r2
	mov dpl, r0
	mov dph, r1
	call skip_blanks
	jz poke_cmd_error

	; retrieve address
	call addrtoi

	; save address
	;mov r7, b
	;mov r6, a
	push 0f0h		; push b
	push 0e0h		; push a

	call skip_blanks
	jz poke_cmd_error
	; retrieve value
	movx a, @dptr
	call hexchartoi
	swap a
	push 0e0h
	inc dptr
	movx a, @dptr
	call hexchartoi
	pop 0f0h
	orl a, b
	mov r2, a

	; restore a and b
	pop 0e0h
	pop 0f0h
	mov dph, b
	mov dpl, a
	
	; restore a
	mov a, r2
	movx @dptr, a

	pop 02h		; pop r2
	ret

poke_cmd_error:
	pop 02h
	call process_invalid_cmd
	ret

process_dump_cmd:

	push 02h		; push r2
	mov dpl, r0
	mov dph, r1
	call skip_blanks
	jz dump_cmd_error

	; retrieve address
	call addrtoi
	push 0f0h		; push b
	push 0e0h		; push a

	call skip_blanks
	jnz dump_cmd_error

	pop 0e0h
	pop 0f0h
	mov dph, b
	mov dpl, a
	call dump_mem
	
	pop 02h		; pop r2
	jmp command_prompt_loop

dump_cmd_error:
	pop 02h
	call process_invalid_cmd
	ret

process_clear_cmd:
	mov dptr, #clear_screen_seq
	call uart_tx_string_from_cseg

	ret

process_invalid_cmd:
	mov dptr, #uart_rx_buffer
	acall uart_tx_string
	mov a, #'?'
	call uart_tx_char
	mov a, #CR
	call uart_tx_char
	mov a, #LF
	call uart_tx_char

	ret

; prints from 1 to 255 spaces
; --> a: how many spaces to print
; <-- none
printspc:
	push 00h				; push r0
	mov r0, a
printspc_loop:
	mov a, #' '
	call uart_tx_char
	djnz r0, printspc_loop
	pop 00h					; pop r0
	ret

; display the contents of a 256-byte block of memory
; --> dptr: starting address of the block of memory
; <-- none

dump_mem:
	push 00h				; push r0
	push 01h				; push r1
	push 02h				; push r2
	; display column headers
	mov r0, #10h			; column counter
	mov r1, #00h			; header to print
	mov r2, #10h			; row counter
	mov a, #06h
	call printspc
dump_mem_header_loop:
	mov a, r1
	call itoa
	push 0e0h				; push a
	mov a, b
	call uart_tx_char
	pop 0e0h				; pop a
	call uart_tx_char
	mov a, #02h
	call printspc

	inc r1
	djnz r0, dump_mem_header_loop
	call println
	; for 16 rows
	;	display row header, followed by 16 bytes of memory
	mov r0, #10h			; 16 columns
	push dph
	push dpl
dump_mem_row_loop:
	mov a, dph
	call itoa
	push 0e0h
	mov a, b
	call uart_tx_char
	pop 0e0h
	call uart_tx_char
	mov a, dpl
	call itoa
	push 0e0h
	mov a, b
	call uart_tx_char
	pop 0e0h
	call uart_tx_char
	mov a, #02h
	call printspc
	mov r0, #10h	
dump_mem_col_loop:
	movx a, @dptr
	call itoa
	push 0e0h
	mov a, b
	call uart_tx_char
	pop 0e0h
	call uart_tx_char
	mov a, #02h
	call printspc
	inc dptr
	djnz r0, dump_mem_col_loop

	call println
	djnz r2, dump_mem_row_loop
	pop dpl
	pop dph

	pop 02h				; pop r2
	pop 01h				; pop r1
	pop 00h				; pop r0
	ret



; converts an ascii character to its binary value
; --> a: contains the ascii character to convert
; <-- a: contains the binary value, if successful
; <-- carry cleared if successful, otherwise set
hexchartoi:
	clr c
	mov b, a
	subb a, #'a'
	jc not_a_letter
	mov a, b
	clr c
	subb a, #'g'
	jnc not_a_letter
	mov a, b
	clr c
	subb a, #87
	clr c
	jmp hexchartoi_exit
not_a_letter:
	mov a, b
	clr c
	subb a, #'0'
	jc not_a_digit
	mov a, b
	clr c
	subb a, #':'
	jnc not_a_digit
	mov a, b
	clr c
	subb a, #48
	clr c
	jmp hexchartoi_exit
not_a_digit:
	setb c
hexchartoi_exit:
	ret

; converts a 4-bit binary value into its hex ascii representation
; convert 0-9 to '0'-'9'
; convert a-f to 'a'-'f'

; --> a: contains a 4-bit binary value to be converted
; <-- a: contains hex ascii representation
itochar:
	; save a in r7
	;mov r7, a
	push 0e0h				; push a to stack
	clr c
	subb a, #10
	;mov a, r7
	pop 0e0h				; pop a from stack
	jc itochar_is_digit
	add a, #39
itochar_is_digit:
	add a, #48
	jmp itochar_exit
itochar_exit:
	ret


; converts a 4-character hex string to an integer address
; --> dptr contains the address of the hex string
; <-- a: low byte of address
; <-- b: high byte of address
addrtoi:
	; swith to bank 1
	clr psw.4
	setb psw.3

	movx a, @dptr
	call hexchartoi
	jc addrtoi_error
	mov r7, a
	
	inc dptr
	movx a, @dptr
	call hexchartoi
	jc addrtoi_error
	mov r6, a

	inc dptr
	movx a, @dptr
	call hexchartoi
	jc addrtoi_error
	mov r5, a

	inc dptr
	movx a, @dptr
	call hexchartoi
	jc addrtoi_error
	mov r4, a

	mov a, r7
	swap a
	orl a, r6
	mov b, a

	mov a, r5
	swap a
	orl a, r4

	; advance dptr, so it is at the next character to be processed
	inc dptr
	; swith to bank 0
	clr psw.4
	clr psw.3

	jmp addrtoi_exit

addrtoi_error:
	setb c
	ret
addrtoi_exit:
	; switch to bank 0
	clr psw.4
	clr psw.3

	clr c
	ret

; converts an 8-bit value to a hex-character string
; --> a: 8-bit value to be converted
; <-- a: low hex char
; <-- b: high hex char
itoa:
	push 06h
	mov r6, a			; backup a
	anl a, #0f0h		; clear lower nibble
	swap a
	call itochar
	mov b, a
	mov a, r6
	anl a, #0fh			; clear higher nibble
	call itochar
	pop 06h
	ret


; determines if the start of a string entered by the user matches a valid command
; --> dptr: address of command
; --> r1, r0: address of string to compare
; <-- a: 0 if matched, otherwise 1
cmd_cmp:
	mov a, #00
	movc a, @a + dptr		; copy next character of command into a
	jz cmd_cmp_equal		; all characters matched
	mov r2, dpl				; save copy of dptr
	mov r3, dph
	mov dph, r1				; retrieve address of next char in user string
	mov dpl, r0
	mov r4, a				; save copy of a
	movx a, @dptr			; read next character of user string
	mov b, a				; copy character to b
	mov a, r4				; restore character for first string into a
	clr c					; clear carry flag before subb
	subb a, b				; compare the two characters
	jnz cmd_cmp_not_equal	; characters not equal, exit
	inc dptr				; inc address of user string
	mov r0, dpl				; back it up
	mov r1, dph
	mov dpl, r2
	mov dph, r3
	inc dptr
	jmp cmd_cmp

cmd_cmp_not_equal:
	mov a, #1
	jmp cmd_cmp_exit
cmd_cmp_equal:
	mov a, #0					; otherwise end of string, exit
cmd_cmp_exit:
	ret

println:
	mov a, #CR
	call uart_tx_char
	mov a, #LF
	call uart_tx_char
	ret

; skips blanks in front of buffer
; --> dptr: contains address of buffer to read
; <-- dptr: points at the first non-blank character in buffer
skip_blanks:
	movx a, @dptr
	jz exit_skip_blanks
	cjne a, #' ', exit_skip_blanks
	inc dptr
	jmp skip_blanks

exit_skip_blanks:
	ret

$include(constants.inc)
$include(boot51.inc)
$include(serial.inc)
$include(mem_diag.asm)
$include(g51-logo.inc)

xseg at 0000h
	uart_rx_buffer: ds 256
	asc_2_bin_buffer: ds 4
	tmp_word_var: ds 2	
end


