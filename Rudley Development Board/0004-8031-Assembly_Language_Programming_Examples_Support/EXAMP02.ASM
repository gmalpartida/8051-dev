; EXAMP02.ASM - Initialze the External Data Ram.
; Initialize all 64K of external data ram to a fixed value.
; Started 06/04/2022
;
$MOD51
$TITLE(EXAMP02.ASM)
$DATE(JUN-04-22)
$PAGEWIDTH(132)
$OBJECT(EXAMP02.HEX);
;
VALUE    EQU  0AAH        ; The value to set all the external data ram.
;
         ORG  0800H       ; The user external rom starts at 0x0800.
;
         MOV  DPTR,#0000H ; Initially set the data pointer to 0x0000.
LABEL03: MOV  R1,DPH      ; Determine if the DPTR is 0xFFFF to exit the main loop.
         MOV  R2,DPL
         MOV  A,R1        ; This is some logic to determine when the DPTR is 0xFFFF.
         ANL  A,R2        ; "A" will be 0xFF only if DPTR is 0xFFFF.
         CPL  A           ; "A" will be 0x00 if DPTR is 0xFFFF.
         JNZ  LABEL01     ; Jump if not completed setting all of the RAM.
         SJMP LABEL02     ; Jump to the Monitor if completed setting all the RAM.
LABEL01: MOV  A,#VALUE    ; Set "A" to the VALUE to be placed in the ram.
         MOVX @DPTR,A     ; Load the VALUE in "A" to the External Data Ram. 
         INC  DPTR        ; Increment the data pointer.
         SJMP LABEL03     ; Go back to the beginning of the main loop.
                          ;
                          ; Jump back to the beginning of the Monitor Program.
LABEL02: LJMP 0000H
         END