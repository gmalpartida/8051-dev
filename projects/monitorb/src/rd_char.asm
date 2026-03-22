;
; This Subroutine Reads a Character and Echos it back.
;
RD_CHAR:  JNB    RI,RD_CHAR
          CLR    RI
          MOV    A,SBUF
          ANL    A,#07FH
          ACALL  WT_CHAR
          RET

