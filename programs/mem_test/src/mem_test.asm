cseg

	ljmp main

	rept 5
		ljmp $
		ds 5
	endm

main:
	mov dph, #00h
	mov dpl, #00h
	mov a, #0ffh
	mov b, #'a'
	acall fill_xram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #80h
	acall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #90h
	acall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0a0h
	acall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0b0h
	acall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0c0h
	acall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0d0h
	acall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0e0h
	acall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0f0h
	acall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #80h
	mov r7, #00h
	acall verify_copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #90h
	acall verify_copy_text_from_rom_to_ram
	
	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0a0h
	acall verify_copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0b0h
	acall verify_copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0c0h
	acall verify_copy_text_from_rom_to_ram
	
	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0d0h
	acall verify_copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0e0h
	acall verify_copy_text_from_rom_to_ram
	
	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0f0h
	acall verify_copy_text_from_rom_to_ram

	jmp $

$include(mem_diag.asm)

