cseg at 00h

reset_ivt:
	ljmp main_mem_test



main_mem_test:

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #80h
	lcall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #90h
	lcall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0a0h
	lcall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0b0h
	lcall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0c0h
	lcall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0d0h
	lcall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0e0h
	lcall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0f0h
	lcall copy_text_from_rom_to_ram

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #80h
	mov r7, #00h
	lcall verify_text_from_rom_to_ram	

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #90h
	lcall verify_text_from_rom_to_ram	

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0a0h
	lcall verify_text_from_rom_to_ram	

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0b0h
	lcall verify_text_from_rom_to_ram	

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0c0h
	lcall verify_text_from_rom_to_ram	

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0d0h
	lcall verify_text_from_rom_to_ram	

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0e0h
	lcall verify_text_from_rom_to_ram	

	mov dptr, #a_short_text
	mov r0, #00h
	mov r1, #0f0h
	lcall verify_text_from_rom_to_ram	

	sjmp $

$include(mem_diag.asm)

	end


