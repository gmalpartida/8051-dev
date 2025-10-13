; EXAMP02A.ASM - Initialze the External Data Ram.
; Initialize all 64K of external data ram to a fixed value.
; Use the monitor program to write out a message.
; Started 06/06/2022
;
$MOD51
$TITLE(EXAMP02A.ASM)
$DATE(JUN-06-22)
$PAGEWIDTH(132)
$OBJECT(EXAMP02A.HEX);
;
VALUE    EQU   0AAH        ; The value to set all the external data ram.
ESC      EQU   01BH        ; Escape Character.
LF       EQU   10          ; Line Feed.
CR       EQU   13          ; Carrage Return.
WTSTRING EQU   077CH       ; This is where the subroutine is that writes characters.
;
         ORG   0800H       ; Set the ORG to 0x0800 to start in the user ROM.
;
         LCALL WTSTRING    ; Write Out a message.
		 DB    LF,CR,'Initialize the External Ram.',LF,CR 
         DB    ESC
;
         MOV   DPTR,#0000H ; Initially set the data pointer to 0x0000.
LABEL03: MOV   R1,DPH      ; Determine if the DPTR is 0xFFFF to exit the main loop.
         MOV   R2,DPL
         MOV   A,R1        ; This is logic to determine when the DPTR is 0xFFFF.
         ANL   A,R2        ; "A" will be 0xFF only if DPTR is 0xFFFF.
         CPL   A           ; "A" will be 0x00 if DPTR is 0xFFFF.
         JNZ   LABEL01     ; Jump if not completed setting all of the RAM.
         SJMP  LABEL02     ; Jump to the Monitor if completed setting all the RAM.
LABEL01: MOV   A,#VALUE    ; Set "A" to the VALUE to be placed in the ram.
         MOVX  @DPTR,A     ; Load the VALUE in "A" to the External Data Ram. 
         INC   DPTR        ; Increment the data pointer.
         SJMP  LABEL03     ; Go back to the beginning of the main loop.
                           ;
LABEL02: LJMP  0000H       ; Jump back to the beginning of the Monitor Program.
         END