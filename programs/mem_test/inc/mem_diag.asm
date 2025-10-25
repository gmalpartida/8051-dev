; verifies that location in rom and ram contain same text until a null character is found
; --> dptr: starting address in rom
; --> r0/r1: starting address in ram ( low byte/ high byte )

verify_copy_text_from_rom_to_ram:
verify_text_from_rom_to_ram_loop:
	clr a
	movc a, @a + dptr
	jz verify_text_from_rom_to_ram_exit
	mov b, a
	mov r2, dpl
	mov r3, dph
	mov dpl, r0
	mov dph, r1
	movx a, @dptr
	cjne a, b, verify_text_from_rom_to_ram_error
	inc dptr
	mov r0, dpl
	mov r1, dph
	mov dpl, r2
	mov dph, r3
	inc dptr
	sjmp verify_text_from_rom_to_ram_loop

verify_text_from_rom_to_ram_error:
	mov r7, #00h

verify_text_from_rom_to_ram_exit:
	inc r7	
	ret


; copies a section of text from rom to ram until a null character is found
; --> dptr: starting address of text in rom
; ->r0/r1: destination address low/high byte of text in ram
copy_text_from_rom_to_ram:
	clr a
	movc a, @a + dptr
	jz copy_text_from_rom_to_ram_exit
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
	sjmp copy_text_from_rom_to_ram

copy_text_from_rom_to_ram_exit:

	ret


; fills a portion of external ram with a value
; --> dptr: starting address in xram to be filled
; --> a: count of bytes to fill in xram
; --> b: value to be used to fill xram

fill_xram:
	mov r0, a
fill_xram_loop:
	mov a, b
	movx @dptr, a
	inc dptr
	djnz r0, fill_xram_loop

	ret

; copies a portion of rom to ram
; --> dptr: starting rom address
; --> a: count of bytes to copy
copy_rom_to_ram:
	mov r2, a
copy_rom_to_ram_loop:
	clr a
	movc a, @a + dptr
	movx @dptr, a
	
	inc dptr
	djnz r2, copy_rom_to_ram_loop

	ret

CR equ 0dh
LF equ 0ah

a_short_text:
db	"BRING BACK A NEW SELF", CR, LF
db	"A silent cathedral, a moon-drenched lake, a snatch of song.", CR, LF
db	"A reverent half hour before the Venus de Milo or the Mona Lisa.", CR, LF
db	"An ancient town hall, a gleaming ghost-haunted palace.", CR, LF
db	"A fountain, a gable, a gateway.", CR, LF
db	"Can one rub elbows with beauty without absorbing some slight shadow of it?", CR, LF
db	"One must come home a different person--fresh, vivid, eager.", 0



end

