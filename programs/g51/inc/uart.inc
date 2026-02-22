; UART Library for 8051 (Polling Method)
; Includes: uart_init, uart_rx_char, uart_rx_string, uart_tx_char, uart_tx_string
cseg

UART_INIT:
    MOV TMOD, #20H      ; Timer 1, Mode 2 (8-bit auto-reload)
    MOV TH1, #0FDH      ; 9600 baud at 11.0592 MHz
    MOV SCON, #50H      ; Mode 1 (8-bit UART), Enable Receiver (REN=1)
    SETB TR1            ; Start Timer 1
	mov dptr, #UART_RX_BUFFER_CUR
	mov a, #00h
	movx @dptr, a
    RET

UART_TX_CHAR:
	MOV SBUF, A             ; Load character into buffer
TX_WAIT:
    JNB TI, TX_WAIT     ; Wait for transmission to complete
    CLR TI              ; Clear flag for next char
    RET

UART_TX_STRING:
    ; Sends null-terminated string from DPTR
    CLR A
    MOVC A, @A+DPTR     ; Get char from code memory
    JZ TX_STR_DONE      ; If 0, end of string
    ACALL UART_TX_CHAR  ; Transmit char
    INC DPTR            ; Next char
    SJMP UART_TX_STRING
TX_STR_DONE:
    RET

UART_RX_CHAR:
    JNB RI, UART_RX_CHAR ; Wait for character
    MOV A, SBUF         ; Read from buffer
    CLR RI              ; Clear flag
    RET

UART_RX_STRING:
    ; Receives string into RAM at R0. Terminates on CR (0x0D) or LF (0x0A).
    ; Replaces terminator with 0x00 (ASCIIZ).
RX_LOOP:
    ACALL UART_RX_CHAR  ; Get char
    ACALL UART_TX_CHAR  ; Echo char back to Minicom (optional but helpful)
    CJNE A, #0DH, CHK_LF ; Is it CR?
    SJMP STR_TERM       ; Yes, terminate
CHK_LF:
    CJNE A, #0AH, SAVE_CHAR ; Is it LF?
    SJMP STR_TERM       ; Yes, terminate
SAVE_CHAR:
    MOV @R0, A          ; Store char in RAM
    INC R0
    SJMP RX_LOOP
STR_TERM:
    MOV @R0, #00H       ; Add Null Terminator (ASCIIZ)
    RET

xseg
UART_RX_BUFFER_CUR:	ds 01H
UART_RX_BUFFER: ds 100h				; 256-byte buffer


