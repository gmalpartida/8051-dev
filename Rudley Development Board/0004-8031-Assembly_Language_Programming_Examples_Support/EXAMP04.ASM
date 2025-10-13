; EXAMP04.ASM - Demonstrate a "if" statement.
; Started 06/06/2022
; Vary a 8-bit value from 0x00 to 0xFF and compare.
; Use the Monitor Program to write out a message.
;
$MOD51
$TITLE(EXAMP04.ASM)
$DATE(JUN-06-22)
$PAGEWIDTH(132)
$OBJECT(EXAMP04.HEX);
;
VALUE    EQU   080H             ; Compare to this Value.
ESC      EQU   01BH             ; Escape Character.
LF       EQU   10               ; Line Feed.
CR       EQU   13               ; Carrage Return.
WTSTRING EQU   077CH            ; Location of subroutine that writes characters.
;
         ORG   0800H            ; Set the ORG to 0x0800 to start in the user ROM.
		 MOV   R4,#00000H       ; Initialize and set R4 to zero.
L01:     CJNE  R4,#VALUE,NEQUAL ; If not equal then write out "not equal".
		 LCALL WTSTRING         ; If equal, then write out "equal".
                                ; Write out "equal".
		 DB    LF,CR,'The Value is Equal.'
         DB    ESC
         SJMP  L02              ; Jump to end to loop around.
NEQUAL:  LCALL WTSTRING         ; If not equal, then write out "not equal".
                                ; Write out "not equal".
		 DB    LF,CR,'The Value is Not Equal.'
         DB    ESC
L02:     INC   R4               ; Increment R4.
		 SJMP  L01              ; Jump back to the beginning of the loop.    
         END