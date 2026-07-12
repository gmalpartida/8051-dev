.include "uart.inc"
.include "constants.inc"

.area CSEG (CODE)

uart_init:
    anl tmod, #0x0f                 ; Clear Timer 1 mode bits
    orl tmod, #0x20                 ; Set Timer 1 to Mode 2 (8-bit auto-reload)
    
    mov th1, #0xff                  ; 57600 bps at 11.0592 MHz
    
    orl pcon, #0x80                 ; Set SMOD to 1 (Doubles the baud rate generation)
    
    mov scon, #0x50                 ; Mode 1 (8-bit UART), ENABLE receiver (REN=1)
    setb tr1                        ; Start Timer 1
    
    ;setb ti                         ; set transmitter 'ready'

	mov a, #0x00
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
	clr ti
	mov sbuf, a
wait_for_tx_done:
	jnb ti, wait_for_tx_done
	clr ti
	ret

uart_tx_asciz:
	clr a
	movc a, @a + dptr
	jz uart_tx_asciz_exit
	acall uart_tx_char
	inc dptr
	sjmp uart_tx_asciz
uart_tx_asciz_exit:
	ret

uart_rx_asciz:
	acall uart_rx_char
	mov b, a									; make copy of it, next statements destroy char in a
	jz uart_rx_asciz_exit						; if NULL then exit
	xrl a, #CR
	jz uart_rx_asciz_exit						; if CR then exit
	mov a, b									; restore copy of char
	xrl a, #LF
	jz uart_rx_asciz_exit						; if LF then exit
	mov a, b
uart_rx_asciz_process_char:
	movx @dptr, a								; not NULL, CR or LF, keep it
	inc dptr
	acall uart_tx_char							; echo char
	sjmp uart_rx_asciz
uart_rx_asciz_exit:
	mov a, #0x00								; the last character must be NULL
	movx @dptr, a
	ret

uart_rx_asciz2:
    ; 1. Protect the start boundary using the stack
    push dpl                     ; Push low byte of start address
    push dph                     ; Push high byte of start address

uart_rx_loop:
    acall uart_rx_char           ; Get char into Acc
    mov r0, a                    ; Save received character to temp R0

    ; Check for CR
    clr c
    subb a, #CR
    jz rx_terminate

    ; Check for LF
    mov a, r0
    clr c
    subb a, #LF
    jz rx_terminate

    ; Check for BS (0x08)
    mov a, r0
    clr c
    subb a, #BS
    jz rx_backspace

    ; Check for DEL (0x7F)
    mov a, r0
    clr c
    subb a, #DEL
    jz rx_backspace

    ; --- Normal Character Processing ---
    mov a, r0
    movx @dptr, a                ; Store in RAM buffer
    inc dptr                     ; Move buffer pointer forward
    
    mov a, r0                    ; Echo char back to terminal
    acall uart_tx_char          
    sjmp uart_rx_loop

rx_backspace:
    ; --- Underflow Check ---
    
    ; 1. Check High Byte
    mov r0, sp                   ; R0 points to top of stack (saved DPH)
    mov a, @r0                   ; A = saved DPH
    clr c
    subb a, dph                  ; Compare saved DPH with current DPH
    jnz do_backspace             ; If difference != 0, they don't match -> safe to delete

    ; 2. Check Low Byte
    mov a, sp
    dec a                        ; Target SP - 1 (saved DPL)
    mov r0, a                    ; R0 points to saved DPL
    mov a, @r0                   ; A = saved DPL
    clr c
    subb a, dpl                  ; Compare saved DPL with current DPL
    jnz do_backspace             ; If difference != 0, they don't match -> safe to delete

    ; If both match exactly, buffer is empty. Ignore backspace.
    sjmp uart_rx_loop

do_backspace:
    ; Decrement the 16-bit DPTR (8051 has no DEC DPTR, must do manually)
    mov a, dpl
    dec a
    mov dpl, a
    cjne a, #0xFF, skip_dph_dec  ; If low byte rolled over from 00 to FF
    dec dph                      ; Decrement the high byte
skip_dph_dec:

    ; Visual erasure on user terminal (BS, Space, BS)
    mov a, #BS
    acall uart_tx_char
    mov a, #SPC
    acall uart_tx_char
    mov a, #BS
    acall uart_tx_char
    sjmp uart_rx_loop

rx_terminate:
    ; Terminate string with NULL
    mov a, #NULL
    movx @dptr, a
    
    ; Echo a newline to terminal
    mov a, #CR
    acall uart_tx_char
    mov a, #LF
    acall uart_tx_char

    ; 3. Clean up stack before exit
    pop dph                      ; Discard saved high byte
    pop dpl                      ; Discard saved low byte
    ret

uart_rx_isr:
	push a
	push b
	push psw
	push dpl
	push dph
	mov a, r0
	push a
	jnb ri, uart_rx_isr_exit
	jbc ti, uart_rx_isr_exit
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
	pop a
	mov r0, a
	pop dph
	pop dpl
	pop psw
	pop b
	pop a
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
	
.area _XSEG (REL, CON, XDATA)
uart_rx_buffer::			.blkb		0x0100
uart_rx_buffer_head::	.blkb		0x01
uart_rx_buffer_tail::	.blkb		0x01



