
$nomod51
; External RAM (XRAM) Buffer Configuration
BUFFER_XRAM EQU 0000H       ; Buffer location in External RAM

ORG 0000H
    LJMP START

ORG 0030H
START:
    MOV SP, #70H            ; Initialize Stack Pointer
    ACALL UART_INIT         ; Configure UART for polling

MAIN_LOOP:
	mov dptr, #cmd_prompt
	acall uart_tx_string
    ACALL GET_COMMAND_XRAM  ; Wait for input string into XRAM
    ACALL PROCESS_COMMAND   ; Compare input with known commands
    SJMP MAIN_LOOP

; --- Command Processor ---
PROCESS_COMMAND:
    ; Check for "help"
    MOV DPTR, #CMD_HELP
    ACALL STR_COMPARE_XRAM
    JZ DO_HELP

    ; Check for "ls"
    MOV DPTR, #CMD_LS
    ACALL STR_COMPARE_XRAM
    JZ DO_LS
    RET

DO_HELP:
    MOV DPTR, #MSG_HELP
    ACALL UART_TX_STRING
    RET

DO_LS:
    MOV DPTR, #MSG_LS
    ACALL UART_TX_STRING
    RET

; --- Buffer Input Logic (XRAM with ASCIIZ Conversion) ---
GET_COMMAND_XRAM:
    MOV DPTR, #BUFFER_XRAM  ; Initialize DPTR to start of XRAM buffer
GET_CHAR_LOOP:
    ACALL UART_RX_CHAR      ; Polling receive (returns char in A)
    
    ; ASCIIZ Conversion: Replace CR (0DH) or LF (0AH) with 0x00
    CJNE A, #0DH, CHECK_LF  ; If CR, jump to terminate
    SJMP TERM_STRING
CHECK_LF:
    CJNE A, #0AH, STORE_CHAR ; If LF, jump to terminate
    SJMP TERM_STRING

STORE_CHAR:
    MOVX @DPTR, A           ; Store character in External RAM
    ACALL UART_TX_CHAR      ; Echo character back to terminal
    INC DPTR                ; Move to next buffer position
    SJMP GET_CHAR_LOOP

TERM_STRING:
    CLR A                   ; Use 0x00
    MOVX @DPTR, A           ; Terminate the string in XRAM
    RET

; --- String Comparison Routine (XRAM vs CODE) ---
; Compares XRAM string at BUFFER_XRAM with CODE string at DPTR.
; Returns Acc=0 on success.
STR_COMPARE_XRAM:
    MOV R0, DPL             ; Save CODE pointer in R0/R1
    MOV R1, DPH
    MOV R2, #00H            ; R2 used as byte index offset
COMP_LOOP:
    ; Fetch character from CODE (ROM)
    MOV DPL, R0
    MOV DPH, R1
    MOV A, R2
    MOVC A, @A+DPTR
    MOV R3, A               ; Store CODE char in R3

    ; Fetch character from XRAM
    MOV DPTR, #BUFFER_XRAM
    MOV A, R2
    ; Note: MOVX @A+DPTR is not standard; we must manually add offset
    PUSH ACC
    MOV A, DPL
    ADD A, R2
    MOV DPL, A
    MOV A, DPH
    ADDC A, #00H
    MOV DPH, A
    POP ACC
    MOVX A, @DPTR
    
    CJNE A, 03H, COMP_FAIL  ; Compare CODE (R3) vs XRAM (A)
    JZ COMP_WIN             ; Both are 00H, strings match
    INC R2                  ; Increment offset
    SJMP COMP_LOOP

COMP_FAIL:
    MOV A, #0FFH
    RET
COMP_WIN:
    CLR A
    RET

; --- Data Constants ---
CMD_HELP: DB 'help', 0
CMD_LS:   DB 'ls', 0
MSG_HELP: DB 0DH, 0AH, 'Commands: ls, help', 0DH, 0AH, 0
MSG_LS:   DB 0DH, 0AH, 'Files: MAIN.ASM, UART.INC', 0DH, 0AH, 0
cmd_prompt: DB 'g51> ', 0

$INCLUDE (8051.mcu)         ; ASEM-51 specific MCU definition
$INCLUDE (uart.inc)         ; Include UART support functions

end

