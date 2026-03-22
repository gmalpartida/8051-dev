;
; This Subroutine converts Hex to ASCII
;
ASC2HEX: CLR    CY
         SUBB   A,#'0'
         MOV    B,A
         SUBB   A,#10
         JB     CY,A2LT10
         MOV    A,B
         SUBB   A,#7
         MOV    B,A
A2LT10:  MOV    A,B
         RET

