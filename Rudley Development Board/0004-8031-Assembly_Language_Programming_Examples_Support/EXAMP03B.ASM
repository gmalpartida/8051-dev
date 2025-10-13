; EXAMP03B.ASM - P1 - Binary Counter - Double Delay
; Started 06/06/2022
; Uses led_driver_00 connected to the P1 port.
; This will illuminate the eight LEDs to show the binary counter.
; A two countdown timers are used to add additional delay between each count.
;
$MOD51
$TITLE(EXAMP03B.ASM)
$DATE(JUN-06-22)
$PAGEWIDTH(132)
$OBJECT(EXAMP03B.HEX);
;
CDTIM1   EQU  0FFH        ; Countdown Timer 1 Initial Value for delay. 
                          ; 0xFF is the maximum value.
         ORG  0800H       ; The user external rom starts at 0x0800.
         MOV  R1,#000H    ; Initialize R1 to zero.            
LABEL1:  MOV  P1,R1       ; Set P1 to R1.     
         MOV  A,#CDTIM1   ; Initilize the 1st countdown timer.
LABEL2:  JZ   LABEL3      ; If A is zero then jump to the 2nd counter.
         DEC  A		      ; Decrement the 1st countdown timer. 
         SJMP LABEL2      ; Loop to continue decrementing the 1st timer.
LABEL3:  MOV  A,#CDTIM1   ; Initilize the 2nd countdown timer.
LABEL5:  JZ   LABEL4      ; If A is zero then incement the binary counter R1.
         DEC  A		      ; Decrement the 2nd countdown timer. 
         SJMP LABEL5      ; Loop to continue decrementing the 2nd timer.
LABEL4:  INC  R1          ; Increment the binary counter in R1.
         SJMP LABEL1	  ; Repeat the loop.	 
         END