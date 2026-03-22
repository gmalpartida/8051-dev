;
; This Subroutine Writes a BYTE 
;
WRBYTE: MOV    R2,A
        SWAP   A
        ACALL  HEX2ASC
        ACALL  WT_CHAR
        MOV    A,R2
        ACALL  HEX2ASC
        ACALL  WT_CHAR
        RET

