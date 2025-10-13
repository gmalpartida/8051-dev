; EXAMP01.ASM - Write Numbers to RAM
; Started 02/21/2021
; Use direct addressing.
; Write from 0x30 to 0x3F
$MOD51
$TITLE(EXAMP01.ASM)
$DATE(FEB-21-21)
$PAGEWIDTH(132)
$OBJECT(EXAMP01.HEX);
;
		ORG 0800H
;
		MOV A,#30H
		MOV 30H,A
;
		MOV A,#31H
		MOV 31H,A
;
		MOV A,#31H
		MOV 31H,A
;
		MOV A,#32H
		MOV 32H,A
;
		MOV A,#33H
		MOV 33H,A
;
		MOV A,#34H
		MOV 34H,A
;
		MOV A,#35H
		MOV 35H,A
;
		MOV A,#36H
		MOV 36H,A
;
		MOV A,#37H
		MOV 37H,A
;
		MOV A,#38H
		MOV 38H,A
;
		MOV A,#39H
		MOV 39H,A
;
		MOV A,#3AH
		MOV 3AH,A
;
		MOV A,#3BH
		MOV 3BH,A
;
		MOV A,#3CH
		MOV 3CH,A
;
		MOV A,#3DH
		MOV 3DH,A
;
		MOV A,#3EH
		MOV 3EH,A
;
		MOV A,#3FH
		MOV 3FH,A
;
; Jump back to the beginning.
		LJMP 0000H
		END