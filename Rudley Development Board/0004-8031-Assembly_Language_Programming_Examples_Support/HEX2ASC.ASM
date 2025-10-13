;
; This Subroutine Converts Hex to ASCII
;
HEX2ASC:  ANL    A,#00FH
          CLR    CY
          MOV    B,A
          SUBB   A,#10
          MOV    A,B
          JB     CY,H2LT10
          ADD    A,#7
H2LT10:   ADD    A,#'0'
          RET
