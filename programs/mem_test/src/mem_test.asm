	max_rom_address_low equ 00h
	max_rom_address_high equ 80h
	max_ram_address_high equ 80h
	max_ram_address_low equ 00h

dseg at 30h
	dptr_high: ds 1
	dptr_low: ds 1

cseg

	ljmp main

	rept 5
		ljmp $
		ds 5
	endm

main:

	mov b, #00h

	mov r0, #00h
	mov r1, #00h
	acall copy_rom_to_ram

	;acall populate_ram

blink_loop:
	acall blink_led
	acall delay_1_sec

	jmp blink_loop

	jmp 0000h

copy_rom_to_ram:
	mov dptr_high, r1
	mov dptr_low, r0

copy_loop:
	mov dph, dptr_high
	mov dpl, dptr_low

	mov a, #00h
	movc a, @a + dptr
	movx @dptr, a

	inc dptr_low
	mov a, dptr_low
	cjne a, #max_rom_address_low, copy_loop

	inc dptr_high
	
	mov a, dptr_high

	cjne a, #max_rom_address_high, copy_loop

	mov b, #01h

	ret


blink_led:
	
    cpl p1.0
	cpl p1.1
	cpl p1.2
	cpl p1.3
	cpl p1.4
	cpl p1.5
	cpl p1.6
	cpl p1.7

exit_blink_led:
	ret


populate_ram:
	mov dptr_high, #00h
	mov dptr_low, #00h

	mov b, #00h

populate_loop:

	mov dph, dptr_high
	mov dpl, dptr_low

	mov a, #00h
	
	mov a, b
	movx @dptr, a
	inc b

	inc dptr_low
	mov a, dptr_low

	cjne a, #max_ram_address_low, populate_loop
	inc dptr_high
	mov a, dptr_high

	cjne a, #max_ram_address_high, populate_loop

	mov b, #02h

	ret

$include (delay.asm)

end

