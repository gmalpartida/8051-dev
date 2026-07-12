cseg at 0000h

rst_isr:
    ljmp main
ie0_isr:
	reti
	ds	07h
tf0_isr:
	reti
	ds	07h
ie1_isr:
	reti
	ds	07h
tf1_isr:
	reti
	ds	07h
ser_isr:
	ljmp uart_rx_isr

main:
    mov sp, 02fh					; Initialize Stack
    lcall uart_init					; Setup UART

	setb es							; enable serial interrupt
	setb ea							; enable global interrupt

cmd_prompt:

    mov dptr, #cmd_prompt_str
    lcall uart_tx_asciz

	mov dptr, #cmd_line_buffer
	lcall uart_rx_asciz

	mov dptr, #cmd_line_buffer
	lcall uart_tx_asciz_xram

	lcall println
	sjmp cmd_prompt

halt:
	sjmp halt

println:
	mov a, #0ah
	lcall uart_tx_char
	mov a, #0dh
	lcall uart_tx_char
	ret

uart_init:
    anl tmod, #0fh                 ; Clear Timer 1 mode bits
    orl tmod, #20h                 ; Set Timer 1 to Mode 2 (8-bit auto-reload)
    
    mov th1, #0ffh                  ; 57600 bps at 11.0592 MHz
    
    orl pcon, #80h                 ; Set SMOD to 1 (Doubles the baud rate generation)
    
    mov scon, #50h                 ; Mode 1 (8-bit UART), ENABLE receiver (REN=1)
    setb tr1                        ; Start Timer 1
    
    ;setb ti                         ; set transmitter 'ready'

	mov a, #00h
	mov dptr, #uart_rx_buffer_head
	movx @dptr, a
	mov dptr,#uart_rx_buffer_tail
	movx @dptr, a

    ret

;uart_rx_char:
;	jnb ri, uart_rx_char			; wait for character to arrive
;	clr ri							; clear receiveer
;	mov a, sbuf						; get character
;	ret

uart_rx_char:
	; if buffer is not empty, process char
	mov dptr, #uart_rx_buffer_head
	movx a, @dptr
	mov b, a
uart_rx_wait_loop:
	mov dptr, #uart_rx_buffer_tail
	movx a, @dptr
	cjne a, b, uart_rx_process_char
	sjmp uart_rx_wait_loop					; otherwise loop back and wait for char
uart_rx_process_char:
	; process char, store in a
	mov dptr, #uart_rx_buffer
	mov a, b							; restore buffer head
	add a, dpl							; add head to buffer
	jnc uart_rx_char_skip_dph
	inc dph
uart_rx_char_skip_dph:
	mov dpl, a							; dptr contains address of char at buffer + head
	movx a, @dptr						; retrieve character from buffer
	push acc							; save char
	; advance buffer head
	mov a, b							; b still contains buffer head
	inc a
	mov dptr, #uart_rx_buffer_head
	movx @dptr, a		
	pop acc							; restore retrieved char
	ret

uart_tx_char:
	jnb ti, uart_tx_char
	clr ti
	mov sbuf, a
	ret

uart_tx_asciz:
	mov a, 00h	
	movc a, @a + dptr
	jz uart_tx_asciz_exit
	acall uart_tx_char
	inc dptr
	sjmp uart_tx_asciz
uart_tx_asciz_exit:
	ret

uart_tx_asciz_xram:
	movx a, @dptr
	jz uart_tx_asciz_xram_exit
	acall uart_tx_char
	inc dptr
	sjmp uart_tx_asciz_xram
uart_tx_asciz_xram_exit:
	ret

uart_rx_asciz:
	acall uart_rx_char
	mov b, a									; make copy of it, next statements destroy char in a
	jz uart_rx_asciz_exit						; if NULL then exit
	xrl a, #0ah
	jz uart_rx_asciz_exit						; if CR then exit
	mov a, b									; restore copy of char
	xrl a, #0dh
	jz uart_rx_asciz_exit						; if LF then exit
	mov a, b
uart_rx_asciz_process_char:
	movx @dptr, a								; not NULL, CR or LF, keep it
	inc dptr
	acall uart_tx_char							; echo char
	sjmp uart_rx_asciz
uart_rx_asciz_exit:
	mov a, #00h								; the last character must be NULL
	movx @dptr, a
	ret

uart_rx_isr:
	push acc
	push b
	push psw
	push dpl
	push dph
	mov a, r0
	push acc
	jb ri, uart_rx_handler
	;jbc ti, uart_rx_isr_exit
	sjmp uart_rx_isr_exit
uart_rx_handler:
	clr ri
	mov a, sbuf							; retrieve received character
	;mov sbuf, a
	mov b, a							; save it for later
	mov dptr, #uart_rx_buffer_tail
	movx a, @dptr						; get tail position
	mov r0, a							; save buffer tail value
	inc a								; increment current buffer tail value
	movx @dptr, a						; save it back
	mov dptr, #uart_rx_buffer			; get address of rx buffer
	mov a, r0							; restore buffer tail value
	add a, dpl								; add buffer tail value to buffer address
	jnc uart_rx_isr_skip_dph
	inc dph
uart_rx_isr_skip_dph:
	mov dpl, a
	mov a, b							; restore character received
	movx @dptr, a						; copy character to buffer
uart_rx_isr_exit:
	pop acc
	mov r0, a
	pop dph
	pop dpl
	pop psw
	pop b
	pop acc
	reti

return_uart_rx_buffer:
	mov dptr, #uart_rx_buffer
	ret

uart_rx_buffer_size:
	mov dptr, #uart_rx_buffer_tail
	movx a, @dptr
	mov b, a
	mov dptr, #uart_rx_buffer_head
	movx a, @dptr
	clr c
	subb a, b
	ret
	
cmd_prompt_str:			db		"uart test> ", 0

xseg
uart_rx_buffer:			ds		0100h
uart_rx_buffer_head:	ds		01h
uart_rx_buffer_tail:	ds		01h
cmd_line_buffer:		ds		0100h

	end

