; EXAMP03D.ASM - P1 - Binary Counter - More Delay - Nested Loops
; Started 06/06/2022
; Uses led_driver_00 connected to the P1 port.
; This will illuminate the eight LEDs to show the binary counter.
; A nested countdown timers are used to add some delay between each count.
;
$MOD51
$TITLE(EXAMP03D.ASM)
$DATE(JUN-06-22)
$PAGEWIDTH(132)
$OBJECT(EXAMP03D.HEX);
;
CDTIM1   EQU  0FFH        ; Countdown Timer 1 Initial Value for delay. 
                          ; 0xFF is the maximum value.
CDTIM2   EQU  080H        ; Countdown Timer 2 Initial Value for delay.
                          ; 0xFF is the maximum value.
;
         ORG  0800H       ; The user external rom starts at 0x0800.
		 MOV  R1,#CDTIM1  ; Initialize the 1st countdown timer.
		 MOV  R2,#CDTIM2  ; Initialize the 2nd countdown timer.
         MOV  R3,#000H    ; Initialize R3 to zero.            
SETP1:   MOV  P1,R3       ; Set P1 to R3.
NZERO1:  DJNZ R1,NZERO1   ; Countdown the 1st timer until zero.
         MOV  R1,#CDTIM1  ; Initialize the 1st countdown timer.
         DJNZ R2,NZERO1   ; Countdown the 2nd timer until zero.
         MOV  R2,#CDTIM2  ; Initialize the 2nd countdown timer.	 	 
         INC  R3          ; Increment the binary counter in R3.
	     SJMP SETP1	      ; Repeat the loop.
         END