; --- UART Initialization (9600 Baud @ 11.0592 MHz) ---
UART_INIT:
    MOV TMOD, #20H          ; Timer 1, Mode 2 (8-bit auto-reload)
    MOV TH1, #0FDH          ; Reload value for 9600 baud
    MOV SCON, #50H          ; 8-bit UART, Receive enabled
    SETB TR1                ; Start Timer 1
    RET

; --- Polling Receive Single Character ---
UART_RX_CHAR:
    JNB RI, $               ; Wait for character
    MOV A, SBUF             ; Read from UART
    CLR RI                  ; Clear flag
    RET

; --- Polling Transmit Single Character ---
UART_TX_CHAR:
    JNB TI, $               ; Wait for previous transmit to finish
    CLR TI                  ; Clear flag
    MOV SBUF, A             ; Write to UART
    RET

; --- Receive ASCIIZ String into XRAM ---
; Input: DPTR points to the start of the XRAM buffer
UART_RX_STRING:
RX_STR_LOOP:
    ACALL UART_RX_CHAR      ; Get char in Acc
    
    ; Echo character back to sender
    ACALL UART_TX_CHAR
    
    ; Check for CR (0x0D) or LF (0x0A)
    CJNE A, #0DH, RX_STR_CHECK_LF
    SJMP RX_STR_TERMINATE
RX_STR_CHECK_LF:
    CJNE A, #0AH, RX_STR_STORE
    SJMP RX_STR_TERMINATE

RX_STR_STORE:
    MOVX @DPTR, A           ; Store char in External RAM
    INC DPTR                ; Advance buffer pointer
    SJMP RX_STR_LOOP        ; Continue receiving

RX_STR_TERMINATE:
    CLR A                   ; Use 0x00 for ASCIIZ
    MOVX @DPTR, A           ; Null terminate string in XRAM
    RET

; --- Transmit ASCIIZ String from CODE ---
; Input: DPTR points to string in CODE memory
UART_TX_STRING:
    CLR A
    MOVC A, @A+DPTR         ; Read from CODE memory
    JZ TX_STR_DONE          ; Stop at null (0x00)
    ACALL UART_TX_CHAR      ; Transmit char
    INC DPTR
    SJMP UART_TX_STRING
TX_STR_DONE:
    RET

