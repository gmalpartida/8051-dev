;
; This Subroutine Does a Line-Feed Cariage Return
;
LFCR:   MOV    A,#00AH
        ACALL  WT_CHAR
        MOV    A,#00DH
        ACALL  WT_CHAR
        RET
