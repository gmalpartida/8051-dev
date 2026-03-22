;
; This Subroutine Reads a Hex Byte and Puts it in A
;
READHEX:
        ACALL  RD_CHAR
        ACALL  ASC2HEX
        SWAP   A
        MOV    R2,A
        ACALL  RD_CHAR
        ACALL  ASC2HEX
        ORL    A,R2
        RET

