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
	db TAB, "help: displays list of available commands.", CR, LF
	db TAB, "ls: displays available applications.", CR, LF
	db TAB, "peek: examine a single memory cell.", CR, LF
	db TAB, TAB, "ex. peek 1b2c", CR, LF
	db TAB, "poke: modify a single memory cell.", CR, LF
	db TAB, TAB, "ex. poke 1b2c 55", CR, LF
	db TAB, "dump: displays a 256 memory block.", CR, LF
	db TAB, TAB, "ex. dump 12", CR, LF
	db TAB, "clear: clear screen and homes the cursor.", CR, LF 
	db TAB, "reset: perform a soft-reset of the system.", CR, LF
	db TAB, "fill: initializes a memory block with a specific byte.", CR, LF
	db TAB, TAB, "ex. fill 1ab7 ff 1a", CR, LF
	db TAB, "move: copies a block of data from one memory location to another.", CR, LF
	db TAB, TAB, "ex. move 2d4f 83bd a5", CR, LF
	db TAB, "jump: jumps to a location in program memory to execute code.", CR, LF
	db TAB, TAB, "ex. jump 8ae3", CR, LF
	db TAB, "sfr: displays the contents of the sfr memory area.", CR, LF, 0

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
jump_txt:
	db "jump", 0
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
