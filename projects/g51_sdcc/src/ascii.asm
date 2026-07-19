.include "ascii.inc"

.area CSEG (CODE)

; Function: asc2bin
; Input:  Accumulator (A) = ASCII character ('0'-'9', 'A'-'F')
; Output: Accumulator (A) = Binary value (00h-0Fh)
; Uses:   R0 (temporary storage)

asc2nibble:
    MOV R2, A         	; Store original character in R2
    CLR C             	; Clear carry for subtraction
    SUBB A, #0x30      	; Subtract 30h to handle '0'-'9'
    
    ; Check if result is > 9 (indicating it was likely 'A'-'F')
    MOV R1, A         	; Temporary copy of intermediate result
    CLR C
    SUBB A, #0x0A      	; Subtract 10 (0Ah)
    JNC IS_ALPHA      	; If no borrow (A >= 10), it's 'A'-'F'
    
    ; It's a digit '0'-'9'
    MOV A, R1         	; Restore the '0'-'9' result
    RET

IS_ALPHA:
    ; It's a letter 'A'-'F'
    MOV A, R2         	; Start again with original ASCII char
	anl a, #0b11011111	; convert to uppercase
    SUBB A, #0x37      	; Subtract 37h to get binary 10-15
    RET

; converts a binary value to an ascii character
; --> a: binary value to be converted
; <-- a: ascii character 
nibble2asc:
	clr c
	mov r2, a
	subb a, #0x0a
	jc nibble2asc_is_digit
	mov a, r2
	add a, #0x37
	orl a, #0b00100000	; convert to lowercase
	ret
nibble2asc_is_digit:
	mov a, r2
	add a, #0x30
	ret

; converts a hex value to ascii
; --> a: hex value
; <-- b: ascii equivalent of upper nibble
; <-- a: ascii equivalent of lower nibble
hex2asc:
	mov r7, a
	swap a
	anl a, #0x0f
	lcall nibble2asc
	mov b, a
	mov a, r7
	anl a, #0x0f
	lcall nibble2asc
	ret


