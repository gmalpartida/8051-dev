cseg at 00h

reset_ivt:
	ljmp mem_test

main:

	mov dptr, #mem_test

	mov r0, #00h
	mov r1, #80h

copy_loop:
	movc a, @a + dptr
	mov r2, dpl
	mov r3, dph

	mov dpl, r0
	mov dph, r1

	movx @dptr, a
	inc dptr
	mov r0, dpl
	mov r1, dph

	mov dpl, r2
	mov dph, r3
	inc dptr

	

	ljmp mem_test

halt:
	jmp $

mem_test:

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

	cjne r7, #08h, verify_error

verify_success:
	mov p1, #0aah
	call delay_1_sec

	jmp verify_success
	ret

verify_error:
	mov p1, #0f0h
	call delay_1_sec
	jmp verify_error

	ret

$include(mem_diag.asm)
$include(delay.asm)

end_of_program:
	end


