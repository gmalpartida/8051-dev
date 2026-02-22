cseg

CR		equ 	0dh
LF		equ 	0ah
TAB		equ 	09h
NULL 	equ		00h 

title_str: 
	db TAB, TAB, TAB, "Copyright 2025 Gino Malpartida", CR, LF, 0
newline_str:	
	db CR, LF,0
command_prompt_str: 
	db "g51> ", 0

help_str: 
	db TAB, "Commands", CR, LF
	db TAB, "help:", TAB, "displays list of available commands.", CR, LF
	db TAB, "ls:", TAB, "displays available applications.", CR, LF
	db TAB, "peek:", TAB, "examine a single memory cell.", CR, LF
	db TAB, TAB, TAB, "ex. peek 1b2c", CR, LF
	db TAB, "poke:", TAB, "modify a single memory cell.", CR, LF
	db TAB, TAB, TAB, "ex. poke 1b2c 55", CR, LF
	db TAB, "dump:", TAB, "displays a 256 memory block.", CR, LF
	db TAB, TAB, TAB, "ex. dump 12", CR, LF
	db TAB, "clear:", TAB, "clear screen and homes the cursor.", CR, LF 
	db TAB, "reset:", TAB, "perform a soft-reset of the system.", CR, LF
	db TAB, "fill:", TAB, "initializes a memory block with a specific byte.", CR, LF
	db TAB, TAB, TAB, "ex. fill 1ab7 ff 1a", CR, LF
	db TAB, "move:", TAB, "copies a block of data from one memory location to another.", CR, LF
	db TAB, TAB, TAB, "ex. move 2d4f 83bd a5", CR, LF
	db TAB, "goto:", TAB, "jumps to a location in program memory to execute code.", CR, LF
	db TAB, TAB, TAB, "ex. goto 8ae3", CR, LF
	db TAB, "call:", TAB, "calls a subroutine to be executed.", CR, LF
	db TAB, TAB, TAB, "ex. call f43d", CR, LF
	db TAB, "iram:", TAB, "displays the contents of the internal memory area.", CR, LF, 0
	db TAB, "sfr:", TAB, "displays the special function registers.", CR, LF, 0

ls_str:		
	db TAB, "Application 1: description of application 1.", CR, LF 
	db TAB, "Application 2: description of application 2.", CR, LF
	db TAB, "Application 3: description of application 3.", CR, LF
	db TAB, "Application 4: description of application 4.", CR, LF
	db TAB, "Application 5: description of application 5.", CR, LF, 0

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
move_txt:
	db "move", 0
goto_txt:
	db "goto", 0
iram_txt:
	db "iram", 0
sfr_txt:
	db "sfr", 0

clear_screen_seq:	
	db	1BH, '[', 'H', 1BH, '[', '2', 'J', 0
msg_err:    
	db "Unknown Command", 0

a_short_text:
	db "The quick brown fox jumps over the lazy dog.", 0

mem_test_fail_msg:
	db "Memory test failed.", 0

mem_test_success_msg:
	db "Memory test succeeded.", 0
