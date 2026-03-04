cseg

CR			equ 	0dh
LF			equ 	0ah
TAB			equ 	09h
NULL 		equ		00h 
BS 			equ		08h
SPC			equ		20h

title_str: 
	db TAB, TAB, TAB, "Copyright 2025 Gino Malpartida", CR, LF, 0
newline_str:	
	db CR, LF,0
command_prompt_str: 
	db "g51> ", 0

commands:
	help_cmd:			db	"help:", 0
	help_cmd_descr:		db	"displays list of available commands.", 0
	ls_cmd:				db	"ls:", 0
	ls_cmd_descr:		db	"displays available applications.", 0
	peek_cmd:			db	"peek:", 0
	peek_cmd_descr:		db	"examine a single memory cell.", CR, LF, TAB, TAB, TAB, "ex. peek 1b2c", 0
	poke_cmd:			db	"poke:", 0
	poke_cmd_descr:		db	"modify a single memory cell.", CR, LF, TAB, TAB, TAB, "ex. poke 1b2c 55", 0
	dump_cmd:			db	"dump:", 0
	dump_cmd_descr:		db	"displays a 256 memory block.", CR, LF, TAB, TAB, TAB, "ex. dump 12", 0
	clear_cmd:			db	"clear:", 0
	clear_cmd_descr:	db	"clear screen and homes the cursor.", 0
	reset_cmd:			db	"reset:", 0
	reset_cmd_descr:	db	"perform a soft-reset of the system.", 0
	fill_cmd:			db	"fill:", 0
	fill_cmd_descr:		db	"initializes a memory block with a specific byte.", CR, LF, TAB, TAB, TAB, "ex. fill 1ab7 ff 1a", 0
	copy_cmd:			db	"copy:", 0
	copy_cmd_descr:		db	"copies a block of data from one memory location to another.", CR, LF, TAB, TAB, TAB, "ex. copy 2d4f 83bd a5", 0
	goto_cmd:			db	"goto:", 0
	goto_cmd_descr:		db	"jumps to a location in program memory to execute code.", CR, LF, TAB, TAB, TAB, "ex. goto 8ae3", 0
	call_cmd:			db	"call:", 0
	call_cmd_descr:		db	"calls a subroutine to be executed.", CR, LF, TAB, TAB, TAB, "ex. call f43d", 0
	iram_cmd:			db	"iram:", 0
	iram_cmd_descr:		db	"displays the contents of the internal memory area.", 0
	sfr_cmd:			db	"sfr:", 0
	sfr_cmd_descr:		db	"displays the special function registers.", 0

help_table:
	dw	help_cmd, help_cmd_descr
	dw	ls_cmd, ls_cmd_descr
	dw	peek_cmd, peek_cmd_descr
	dw	poke_cmd, poke_cmd_descr
	dw	dump_cmd, dump_cmd_descr
	dw	clear_cmd, clear_cmd_descr
	dw	reset_cmd, reset_cmd_descr
	dw	fill_cmd, fill_cmd_descr
	dw	copy_cmd, copy_cmd_descr
	dw	goto_cmd, goto_cmd_descr
	dw	call_cmd, call_cmd_descr
	dw	iram_cmd, iram_cmd_descr
	dw	sfr_cmd, sfr_cmd_descr
	dw	0, 0	

help_txt:	
	db	"help", 0
ls_txt:		
	db	"ls", 0
peek_txt:	
	db	"peek", 0
poke_txt:	
	db	"poke", 0
dump_txt:	
	db	"dump", 0
clear_txt:	
	db	"clear", 0
reset_txt:
	db "reset", 0
fill_txt:
	db "fill", 0
copy_txt:
	db "copy", 0
goto_txt:
	db "goto", 0
iram_txt:
	db "iram", 0
sfr_txt:
	db "sfr", 0
write_txt:
	db "write", 0

msg_err:    
	db "Unknown Command", 0

a_short_text:
	db "The quick brown fox jumps over the lazy dog.", 0

mem_test_fail_msg:
	db "Memory test failed.", 0

mem_test_success_msg:
	db "Memory test succeeded.", 0

lcd_app_name:
	db "lcd", 0

lcd_app_descr:
	db "Allows testing of the lcd screen in P1, P3", 0

pwm_app_name:
	db "pwm", 0

pwm_app_descr:
	db "Allows testing of the pwm application.", 0

app_table:
	dw lcd_app_name, lcd_app_descr, lcd_app
	dw pwm_app_name, pwm_app_descr, pwm_app
	dw 0, 0, 0									; end of table

p0_txt: 	db "P0", 0
sp_txt: 	db "SP", 0
pcon_txt:	db "PCON", 0
tcon_txt:	db "TCON", 0
tmod_txt:	db "TMOD", 0
tl0_txt:	db "TL0", 0
tl1_txt:	db "TL1", 0
th0_txt:	db "TH0", 0
th1_txt:	db "TH1", 0
p1_txt:		db "P1", 0
scon_txt:	db "SCON", 0
sbuf_txt:	db "SBUF", 0
p2_txt:		db "P2", 0
ie_txt:		db "IE", 0
p3_txt:		db "P3", 0
ip_txt:		db "IP", 0
psw_txt:	db "PSW", 0
acc_txt:	db "ACC", 0
b_txt:		db "B", 0

