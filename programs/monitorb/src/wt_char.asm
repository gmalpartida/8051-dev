;
; This Subroutine Writes out a Character
;
WT_CHAR:  JNB    TI,WT_CHAR
          CLR    TI
          MOV    SBUF,A
          RET
		 
