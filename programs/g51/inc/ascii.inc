cseg
; Function: asc2bin
; Input:  Accumulator (A) = ASCII character ('0'-'9', 'A'-'F')
; Output: Accumulator (A) = Binary value (00h-0Fh)
; Uses:   R0 (temporary storage)

asc2bin:
    MOV R2, A         	; Store original character in R2
    CLR C             	; Clear carry for subtraction
    SUBB A, #30H      	; Subtract 30h to handle '0'-'9'
    
    ; Check if result is > 9 (indicating it was likely 'A'-'F')
    MOV R1, A         	; Temporary copy of intermediate result
    CLR C
    SUBB A, #0AH      	; Subtract 10 (0Ah)
    JNC IS_ALPHA      	; If no borrow (A >= 10), it's 'A'-'F'
    
    ; It's a digit '0'-'9'
    MOV A, R1         	; Restore the '0'-'9' result
    RET

IS_ALPHA:
    ; It's a letter 'A'-'F'
    MOV A, R2         	; Start again with original ASCII char
	anl a, #11011111b	; convert to uppercase
    SUBB A, #37H      	; Subtract 37h to get binary 10-15
    RET

; converts a binary value to an ascii character
; --> a: binary value to be converted
; <-- a: ascii character 
bin2asc:
	clr c
	mov r2, a
	subb a, #0ah
	jc bin2asc_is_digit
	mov a, r2
	add a, #37h
	orl a, #00100000b	; convert to lowercase
	ret
bin2asc_is_digit:
	mov a, r2
	add a, #30h
	ret




