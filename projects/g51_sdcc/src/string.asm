.include "constants.inc"
.include "string.inc"

.area cseg (code)
; --- String Compare Utility ---
STRCMP:
    ; Compares RAM string at R0 with CODE string at DPTR
    ; Returns A=0 if match, A=1 if no match
STRCMP_LOOP:
    CLR A
    MOVC A, @A+DPTR     ; Get char from CODE
    MOV B, A            ; Store in B
    MOV A, @R0          ; Get char from RAM
    CJNE A, B, NO_MATCH ; Compare
    JZ MATCH            ; If both are 0, they match
    INC R0
    INC DPTR
    SJMP STRCMP_LOOP
MATCH:
    CLR A               ; Return 0
    RET
NO_MATCH:
    MOV A, #0x01         ; Return 1
    RET

strncmp:
				; counter
strncmp_loop:
    CLR A
    MOVC A, @A+DPTR     ; Get char from CODE
    MOV B, A            ; Store in B
    MOV A, @R0          ; Get char from RAM
    CJNE A, B, strncmp_no_match ; Compare
    INC R0
    INC DPTR
	djnz r2, strncmp_loop
    
strncmp_match:
    CLR A               ; Return 0
    RET
strncmp_no_match:
    MOV A, #0x01        ; Return 1
    RET

; finds character c in the first n bytes of a memory buffer in program memory
; --> r6,r7: address of memory buffer
; --> r5: 	character for which to search
; --> r4:	how many bytes at which to look
; <-- r6,r7: address at which character was found, otherwise NULL
; <-- c: clear if found, otherwise set
memchr_c:
	mov dph, r6
	mov dpl, r7
memchr_loop_c:
	clr a
	movc a, @a + dptr
	clr c
	subb a, r5
	jnz memchr_no_match_c
	djnz r4, memchr_loop_c
	sjmp memchr_match_c
memchr_no_match_c:
	mov r6, #0x00
	mov r7, #0x00
	setb c
	ret
memchr_match_c:
	mov r6, dph
	mov r7, dpl
	clr c
	ret

; finds character c in the first n bytes of a memory buffer in data memory
; --> r6,r7: address of memory buffer
; --> r5: 	character for which to search
; --> r4:	how many bytes at which to look
; <-- r6,r7: address at which character was found, otherwise NULL
memchr:
	mov dph, r6
	mov dpl, r7
memchr_loop:
	clr a
	movx a, @dptr
	jz memchr_match
	clr c
	subb a, r5
	jnz memchr_no_match
	djnz r4, memchr_loop
	sjmp memchr_match
memchr_no_match:
	mov r6, #0x00
	mov r7, #0x00
	ret
memchr_match:
	mov r6, dph
	mov r7, dpl
	ret

; compares the first n bytes of two blocks of memory, one of which is in program memory
; --> r6, r7: 	address of block of memory in program memory
; --> r4, r5: 	address of block of memory in data memory
; --> r3: 		how many bytes to compare
; <-- r7:		0 if equal, -1 if first block is less than second block, otherwise 1

memcmp_c:
	mov dph, r6
	mov dpl, r7
memcmp_loop_c:
	clr a
	movc a, @a + dptr 
	mov b, a
	inc dptr
	mov r6, dph
	mov r7, dpl
	mov dph, r4
	mov dpl, r5
	movx a, @dptr
	clr c
	subb a, b
	jnz memcmp_no_match_c
	djnz r3, memcmp_loop_c
	inc dptr
	mov r4, dph
	mov r5, dpl
	mov dph, r6
	mov dpl, r7
	sjmp memcmp_match_c
memcmp_no_match_c:
	jc memcmp_no_match_less_c
	mov r7, #0x01
	ret
memcmp_no_match_less_c:
	mov r7, #0xff
	ret
memcmp_match_c:
	mov r7, #0x00
	ret

; copies n bytes from one memory block to another, one of which resides in program memory
; --> r6, r7: address of source memory block in program memory
; --> r4, r5: address of destination memory block in data memory
; --> r3: 	  how many bytes to copy

memcpy_c:
memcpy_c_loop:
	mov dph, r6
	mov dpl, r7
	clr a
	movc a, @a + dptr
	mov b, a
	inc dptr
	mov r6, dph
	mov r7, dpl
	mov dph, r4 
	mov dpl, r5
	mov a, b
	movx @dptr, a
	inc dptr
	mov r4, dph
	mov r5, dpl
	djnz r3, memcpy_c_loop

	ret

; initializes a memory block with a specific byte
; --> r6, r7: address of memory block
; --> r5: length of memory block
; --> r4: byte to fill the block

memset:
	mov dph, r6
	mov dpl, r7
memset_loop:
	mov a, r4
	movx @dptr, a
	inc dptr
	djnz r5, memset_loop
	ret


; moves a memory block from one location to another
; --> r6, r7: address of source memory block
; --> r4, r5: address of destination memory block
; --> r3: how many bytes to move
memcpy:
	mov dph, r6
	mov dpl, r7
	movx a, @dptr
	inc dptr
	mov r6, dph
	mov r7, dpl
	mov dph, r4
	mov dpl, r5
	movx @dptr, a
	inc dptr
	mov r4, dph
	mov r5, dpl
	djnz r3, memcpy

	ret

