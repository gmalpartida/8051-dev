; EXAMP04B.ASM - Demonstrate a "if" statement.
; Started 06/07/2022
; Use the Monitor Program to write out a message.
; Write out the Value.
; Write out messages if less ot greater than.
;
$MOD51
$TITLE(EXAMP04B.ASM)
$DATE(JUN-07-22)
$PAGEWIDTH(132)
$OBJECT(EXAMP04B.HEX);
;
VALUE    EQU   080H             ; Compare to this Value.
ESC      EQU   01BH             ; Escape Character.
LF       EQU   10               ; Line Feed.
CR       EQU   13               ; Carrage Return
WTSTRING EQU   077CH            ; Location of subroutine that writes characters.
WRBYTE   EQU   07EDH            ; Location of subroutine that writes a Value.
;
         ORG   0800H            ; Set the ORG to 0x0800 to start in the user ROM.
		 MOV   R4,#00000H
L01:     CJNE  R4,#VALUE,NEQUAL ; IF Not Equal to the VALUE THEN Jump to NEQUAL.
		 LCALL WTSTRING         ; ELSE
		 DB    LF,CR,'EQUAL='   ; Write out the VALUE is EQUAL.
         DB    ESC
         MOV   A,R4             ; Move the variable R4 to "A".
         LCALL WRBYTE         ; Write out the variable when "equal".
         SJMP  L02              ; Jump to end to loop around.
NEQUAL:  JC    L03              ; IF R4 is Greater THEN VALUE.
		 LCALL WTSTRING         ; Write out "GREATER THAN"
		 DB    LF,CR,'GREATER THAN='
         DB    ESC
		 SJMP  L04              ; Jump around.
L03:	 LCALL WTSTRING         ; ELSE
                                ; Write out "LESS THAN"
		 DB    LF,CR,'LESS THAN='  
         DB    ESC	 
L04:     MOV   A,R4             ; Move the variable R4 to "A".
         LCALL WRBYTE           ; Write out the variable when "not equal".
L02:     INC   R4               ; Increment R4.
		 SJMP  L01              ; Jump back to the beginning of the loop.
         END