cseg

uart_init:
    mov tmod, #20h      ; timer 1, mode 2 (8-bit auto-reload)
    mov th1, #0fdh      ; 9600 baud at 11.0592 mhz
    mov scon, #50h      ; mode 1 (8-bit uart), enable receiver (ren=1)
    setb tr1            ; start timer 1
	mov dptr, #uart_rx_buffer_cur
	mov a, #00h
	movx @dptr, a
    ret

uart_tx_char:
	mov sbuf, a             ; load character into buffer
tx_wait:
    jnb ti, tx_wait     ; wait for transmission to complete
    clr ti              ; clear flag for next char
    ret

uart_tx_string:
    ; sends null-terminated string from dptr
    clr a
    movc a, @a+dptr     ; get char from code memory
    jz tx_str_done      ; if 0, end of string
    acall uart_tx_char  ; transmit char
    inc dptr            ; next char
    sjmp uart_tx_string
tx_str_done:
    ret

uart_rx_char:
    jnb ri, uart_rx_char ; wait for character
    mov a, sbuf         ; read from buffer
    clr ri              ; clear flag
    ret

uart_rx_string:
    ; receives string into ram at r0. terminates on cr (0x0d) or lf (0x0a).
    ; replaces terminator with 0x00 (asciiz).
rx_loop:
    lcall uart_rx_char  ; get char
    lcall uart_tx_char  ; echo char back to minicom (optional but helpful)
    cjne a, #0dh, chk_lf ; is it cr?
    sjmp str_term       ; yes, terminate
chk_lf:
    cjne a, #0ah, save_char ; is it lf?
    sjmp str_term       ; yes, terminate
save_char:
	cjne a, #BS, confirm_save
	dec r0
	mov a, #SPC
	lcall uart_tx_char
	mov a, #BS
	lcall uart_tx_char
	sjmp rx_loop
confirm_save:
    mov @r0, a          ; store char in ram
    inc r0
    sjmp rx_loop
str_term:
    mov @r0, #00h       ; add null terminator (asciiz)
    ret

xseg
uart_rx_buffer_cur:		ds 01h
uart_rx_buffer:			ds 100h				; 256-byte buffer


