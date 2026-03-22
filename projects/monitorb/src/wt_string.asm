; 
; This Subroutine Writes Out A String Through RS232
;
WT_STRING: POP    DPH          ; Load DPTR with First Character
           POP    DPL
           CLR    A            ; Zero Offset
           MOVC   A,@A+DPTR    ; Get First Character in String
MEN_1:     JNB    TI,MEN_1     ; Wait until transmitter ready
           CLR    TI           ; Set Not Ready
           MOV    SBUF,A       ; Output Character
           INC    DPTR         ; Increment Data Pointer
           CLR    A            ; Zero Offset
           MOVC   A,@A+DPTR    ; Get Next Character
           CJNE   A,#ESC,MEN_1 ; Loop until read ESC
           MOV    A,#1
           JMP    @A+DPTR      ; Return After read ESC