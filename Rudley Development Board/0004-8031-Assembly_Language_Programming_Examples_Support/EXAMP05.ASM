; EXAMP05.ASM - Initialze the Internal Scratch-Pad Ram from 0x30 to 0x7F
; Started 06/04/2022
;
$MOD51
$TITLE(EXAMP05.ASM)
$DATE(JUN-07-22)
$PAGEWIDTH(132)
$OBJECT(EXAMP05.HEX);
;
VALUE    EQU  000H              ; This is the value to set the ram to.
ASTART   EQU  030H              ; This is the start address.
AEND     EQU  07FH              ; This is the end address. 
;
         ORG  0800H             ; Set the ORG to 0x0800 to start in the user ROM.
;
         MOV  R1,#ASTART        ; Set "R1" to the start address.
         MOV  A,#VALUE          ; Set "A" to the VALUE.
L01:     MOV  @R1,A             ; Load the VALUE to the address.
		 CJNE R1,#AEND,L02      ; IF R1 .NOT..EQUAL. AEND Jump to Inctrement R1.
		 SJMP L03               ; ELSE Jump to End.
L02:	 INC  R1                ; Increment R1.
         SJMP L01               ; Jump around to main loop.
L03:     LJMP 0000H             ; Jump back to the Monitor Rom.
         END
