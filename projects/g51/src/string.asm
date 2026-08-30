.include "constants.inc"
.include "string.inc"

.area CSEG (CODE)

; compares two null terminated strings
; --> dptr		string in cseg
; --> R7:R6		string in xseg
; <-- C			set if equal, otherwise clear
strcmp:
strcmp_loop:
	clr a
	movc a, @a + dptr				; read char
	mov b, a						; save char read
	push dpl						; backup address of code segment string
	push dph
	mov dph, R7						; load address of xseg string
	mov dpl, R6
	movx a, @dptr					; read char
	xrl a, b						; evaluate to zero if equal
	jnz strcmp_no_match				; not zero so no match
	mov a, b						; check if b is also zero
	jz strcmp_match					; both null char so match, exit
	inc dptr						; increment R7:R6 pointer
	mov R7, dph						; save in registers
	mov R6, dpl
	pop dph							; restore code segment string
	pop dpl
	inc dptr						; increment pointer
	sjmp strcmp_loop				; check next character
strcmp_no_match:
	clr c
    sjmp strcmp_cleanup
strcmp_match:
	setb c
strcmp_cleanup:
	pop dph
	pop dpl
	ret

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

; compares first n bytes of two memory blocks.
; source memory block is in program memory.
; dest memory block is in data memory.
; --> dptr:		address of source memory block in program memory
; --> r7:r6:	address of destination memory block in xdata memory
; --> r5:r4:	how many bytes to copy
memcmp:
	mov a, r4
	orl a, r5
	jz memcmp_exit
	movx a, @dptr
	xch a, b
	inc dptr
	push dpl
	push dph
	mov dph, r7
	mov dpl, r6
	movx a, @dptr
	inc dptr
	mov r7, dph
	mov r6, dpl
	pop dph
	pop dpl
	cjne a, b, memcmp_no_match
	dec r4
	cjne r4, #0xff, memcmp_skip_dec_r5 
	dec r5
memcmp_skip_dec_r5:
	sjmp memcmp_c
memcmp_no_match:
	setb c
	ret
memcmp_exit:
	clr c
	ret

; compares first n bytes of two memory blocks.
; source memory block is in program memory.
; dest memory block is in data memory.
; --> dptr:		address of source memory block in program memory
; --> r7:r6:	address of destination memory block in xdata memory
; --> r5:r4:	how many bytes to copy
memcmp_c:
	mov a, r4
	orl a, r5
	jz memcmp_c_exit
	clr a
	movc a, @a + dptr
	xch a, b
	inc dptr
	push dpl
	push dph
	mov dph, r7
	mov dpl, r6
	movx a, @dptr
	inc dptr
	mov r7, dph
	mov r6, dpl
	pop dph
	pop dpl
	cjne a, b, memcmp_c_no_match
	dec r4
	cjne r4, #0xff, memcmp_c_skip_dec_r5 
	dec r5
memcmp_c_skip_dec_r5:
	sjmp memcmp_c
memcmp_c_no_match:
	setb c
	ret
memcmp_c_exit:
	clr c
	ret

; moves a memory block from one location in program memory to a location in xdata memory
; --> dptr:		address of source memory block in program memory
; --> r7:r6:	address of destination memory block in xdata memory
; --> r5:r4:	how many bytes to copy
memcpy_c:
	mov a, r4
	orl a, r5
	jz memcpy_c_exit
	clr a
	movc a, @a + dptr
	inc dptr
	push dpl
	push dph
	mov dph, r7
	mov dpl, r6
	movx @dptr, a
	inc dptr
	mov r7, dph
	mov r6, dpl
	pop dph
	pop dpl
	
	dec r4
	cjne r4, #0xff, memcpy_c_skip_dec_r5 
	dec r5
memcpy_c_skip_dec_r5:
	sjmp memcpy
memcpy_c_exit:
	ret

; initializes a memory block with a specific byte
; --> dptr: address of memory block
; --> r7:r6: length of memory block
; --> r5: byte to fill the block
memset:
	mov a, r6					; check for length = 0
	orl a, r7
	jz memset_exit				; both r6 and r7 are zero, exit

	mov a, r5
	movx @dptr, a				; copy next char
	inc dptr
	
	dec r6
	cjne r6, #0xff, memset_skip_dec_r7
	dec r7
memset_skip_dec_r7:
	sjmp memset

memset_exit:
	ret

; moves a memory block from one location to another
; --> dptr:		address of source memory block
; --> r7:r6:	address of destination memory block
; --> r5:r4:	how many bytes to copy
memcpy:
	mov a, r4
	orl a, r5
	jz memcpy_exit

	movx a, @dptr
	inc dptr
	push dpl
	push dph
	mov dph, r7
	mov dpl, r6
	movx @dptr, a
	inc dptr
	mov r7, dph
	mov r6, dpl
	pop dph
	pop dpl
	
	dec r4
	cjne r4, #0xff, memcpy_skip_dec_r5 
	dec r5
memcpy_skip_dec_r5:
	sjmp memcpy
memcpy_exit:
	ret

