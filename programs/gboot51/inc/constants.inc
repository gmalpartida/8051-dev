CR equ 0dh
LF equ 0ah
TAB equ 09h

INVALID_CMD	equ 00h
HELP_CMD	equ 01h
LS_CMD		equ 02h
PEEK_CMD	equ 04h
POKE_CMD	equ 08h

title_str: 	db "GBOOT51 v.1.0", CR, LF
		db "Copyright 2025 Gino Malpartida", CR, LF, 0
newline_str:	db CR, LF,0
command_prompt_str: db "gboot51>", 0

help_str: db TAB, "Commands", CR, LF
	  db TAB, "help: shows this help.", CR, LF
	  db TAB, "ls: list available applications.", CR, LF
	  db TAB, "peek: allows to view memory.", CR, LF
	  db TAB, "poke: allows to modify memory.", CR, LF, 0 

ls_str:		db TAB, "Application 1: description of application 1.", CR, LF 
	  	db TAB, "Application 2: description of application 2.", CR, LF
	  	db TAB, "Application 3: description of application 3.", CR, LF
	  	db TAB, "Application 4: description of application 4.", CR, LF
	  	db TAB, "Application 5: description of application 5.", CR, LF, 0

help_cmd_txt: 		db "process help command.", CR, LF, 0
ls_cmd_txt: 		db "process ls command.", CR, LF, 0
peek_cmd_txt:		db "process peek command.", CR, LF, 0
poke_cmd_txt:		db "process poke command.", CR, LF, 0
invalid_cmd_txt: 	db "invalid command.", CR, LF, 0

