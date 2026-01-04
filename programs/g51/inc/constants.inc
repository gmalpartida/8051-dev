
title_str: db TAB, TAB, TAB, "Copyright 2025 Gino Malpartida", CR, LF, 0
newline_str:	db CR, LF,0
command_prompt_str: db "g51>", 0

help_str: db TAB, "Commands", CR, LF
	  db TAB, "help: shows this help.", CR, LF
	  db TAB, "ls: list available applications.", CR, LF
	  db TAB, "peek: allows to view memory.", CR, LF
	  db TAB, "poke: allows to modify memory.", CR, LF
	  db TAB, "dump: displays a 256 memory block.", CR, LF
	  db TAB, "clear: clear screen and homes the cursor.", CR, LF, 0

ls_str:		db TAB, "Application 1: description of application 1.", CR, LF 
	  	db TAB, "Application 2: description of application 2.", CR, LF
	  	db TAB, "Application 3: description of application 3.", CR, LF
	  	db TAB, "Application 4: description of application 4.", CR, LF
	  	db TAB, "Application 5: description of application 5.", CR, LF, 0

help_txt:	db	"help", 0
ls_txt:		db	"ls", 0
peek_txt:	db	"peek", 0
poke_txt:	db	"poke", 0
dump_txt:	db	"dump", 0
clear_txt:	db	"clear", 0

clear_screen_seq:	db	1BH, '[', 'H', 1BH, '[', '2', 'J', 0

