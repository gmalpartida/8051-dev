;
; This Subroutine Causes a Pause for a Fraction of a Second
;
WAIT:   MOV    A,#10
WAIT1:  MOV    B,#0FFH
WAIT2:  DJNZ   B,WAIT2
        DEC    A
        JNZ    WAIT1
        RET