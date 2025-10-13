; MONITORA.ASM - Rev A Started 01/02/94
; MONITORB.ASM - Rev B Started 01/31/21 - Same as MONITORA
;
; 8031 System #6
;
; This program helps to develop a Monitor for the 8031 system.
; Runs at 9600 Baud
;
; Allows the reading and writing to internal RAM. (R and W functions).
; Allows you to read and write to ROM stuff. (O and M functions)
; It also displays SFRs. (S funtion)
; It writes 256 byte blocks of ROM. (B Function)
; It write all internal Ram (D Function)
; Allow Upload of HEX file for Monitor Program Devel (H Function)
; Do Checksum between load memory and HEX file (C Function)
; Do a Jump to 0800h to run other programs. (J Function)
; Allow Upload of HEX File for Running at 0800h Memory (E Function)
; Do Checksum between load memory and HEX file at 0800 Mem (K Function)
;
; Give a list of functions (Menu) (N Function)
;
;
BITRATE  equ    0FDH   ; For 9600 Baud Rate
ESC      equ    01BH
CKSUM    equ    010H
NEWPROG  equ   0800H
LF       EQU   10
CR       EQU   13
;
;
$MOD51
$TITLE(MONITORB.ASM)
$DATE(JAN-31-21)
$PAGEWIDTH(132)
$OBJECT(MONITORB.HEX)
;
; Setup Serial Stuff
;
        MOV    TMOD,#00100000b ; T1 Mode Auto Reload Mode
        MOV    TH1,#BITRATE
        MOV    TL1,#BITRATE
;
; Serial in Mode 1, Enable Serial reception, Set TI
;
        MOV    SCON,#01010010b
        SETB   TR1  ; Start Timer for Serial Port
;
MENU:   LCALL  WT_STRING
        DB     LF,CR
        DB     '8031 MONITOR Rev B by Frank Rudley',LF,CR
        DB     LF,LF,LF,LF
        DB     ESC
;
GETSEL: LCALL  WT_STRING
        DB     LF,'8031>'     ; Prompt
        DB     ESC
;
        LCALL  RD_CHAR
;
        ANL    A,#05FH      ; Upcase, Stip Parity
;
R_TEST: CJNE   A,#'R',W_TEST; If Not R, Then Repeat Menu
        AJMP   R_RUN        ; R, So Run Read Internal RAM
;
W_TEST: CJNE   A,#'W',O_TEST; If Not W, Then Repeat Menu
        AJMP   W_RUN        ; W, So Run Write Internal RAM
;
O_TEST: CJNE   A,#'O',M_TEST; If Not O, Then Repeat Menu
        AJMP   O_RUN        ; O, So Run Read ROM
;
M_TEST: CJNE   A,#'M',S_TEST; If Not M, Then Repeat Menu
        AJMP   M_RUN        ; M, So Run Write ROM
;
S_TEST: CJNE   A,#'S',B_TEST; If Not S, Then Repeat Menu
        AJMP   S_RUN        ; S, So Display SFRs
;
B_TEST: CJNE   A,#'B',D_TEST; If Not B, Then Repeat Menu
        AJMP   B_RUN        ; B, Display 256 byte Block of Rom
;
D_TEST: CJNE   A,#'D',H_TEST; If Not D, Then Repeat Menu
        AJMP   D_RUN        ; D, Display 128 byte Block of internal Ram
;
H_TEST: CJNE   A,#'H',C_TEST; If Not H, Then Repeat Menu
        AJMP   H_RUN        ; H, Allow Upload of Hex File
;
C_TEST: CJNE   A,#'C',J_TEST; If Not C, Then Repeat Menu
        AJMP   C_RUN        ; C, Then DO Checksum Verify
;
J_TEST: CJNE   A,#'J',E_TEST; If Not J, Then Repeat Menu
        AJMP   J_RUN        ; J, Then Jump to New Program at 0800h
;
E_TEST: CJNE   A,#'E',K_TEST; If Not E, Then Repeat Menu
        AJMP   E_RUN        ; E, Allow Upload of Hex File
;
K_TEST: CJNE   A,#'K',N_TEST; If Not K, Then Repeat Menu
        AJMP   K_RUN        ; K, Then DO Checksum Verify
;
N_TEST: CJNE   A,#'N',A_TEST; If Not N, Then Repeat Menu
        AJMP   N_RUN        ; N, Then List Menu
;
A_TEST: CJNE   A,#'A',X_TEST; If Not A, Then Repeat Menu
        AJMP   A_RUN        ; A, Then Read External RAM
;
X_TEST: CJNE   A,#'X',J_MENU; If Not X, Then Repeat Menu
        AJMP   X_RUN        ; X, Then Dump 256 byte block of Ext Ram
;
J_MENU: ACALL  WAIT         ; Wait then show menu
        LJMP   MENU
;
R_RUN:  ACALL  WT_STRING
        DB     '-RAM>'
        DB     ESC
        ACALL  READHEX
        MOV    R0,A
        MOV    A,#':'
        ACALL  WT_CHAR
        MOV    A,@R0
        ACALL  WRBYTE
        ACALL  LFCR
        LJMP   GETSEL
;
W_RUN:  ACALL  WT_STRING
        DB     '-RAM>'
        DB     ESC
        ACALL  READHEX
        MOV    R0,A
        MOV    A,#':'
        ACALL  WT_CHAR
        ACALL  READHEX
        MOV    @R0,A
        ACALL  LFCR
        LJMP   GETSEL
;
O_RUN:  ACALL  WT_STRING
        DB     '-ROM>'
        DB     ESC
        ACALL  READHEX
        MOV    DPH,A
        ACALL  READHEX
        MOV    DPL,A
        MOV    A,#':'
        ACALL  WT_CHAR
        CLR    A
        MOVC   A,@A+DPTR
        ACALL  WRBYTE
        ACALL  LFCR
        LJMP   GETSEL
; 
M_RUN:  ACALL  WT_STRING
        DB     '-ROM>'
        DB     ESC
        ACALL  READHEX
        MOV    DPH,A
        ACALL  READHEX
        MOV    DPL,A
        MOV    A,#':'
        ACALL  WT_CHAR
        ACALL  READHEX
        MOVX   @DPTR,A
        ACALL  WAIT     ; Wait for Burn in Time
        ACALL  LFCR
        LJMP   GETSEL
;
;
; Display P0
;
S_RUN:  ACALL  WT_STRING  ; Display SFR Routine
        DB     'SFRs',LF,LF,LF,CR
        DB     'P0   = '
        DB     ESC
        MOV    A,P0
        ACALL  WRBYTE
;
; Display P1
;
        ACALL  WT_STRING
        DB     '    P1   = '
        DB     ESC
        MOV    A,P1
        ACALL  WRBYTE
;
; Display P2
;
        ACALL  WT_STRING
        DB     '    P2   = '
        DB     ESC
        MOV    A,P2
        ACALL  WRBYTE
;
; Display P3
;
        ACALL  WT_STRING
        DB     '    P3   = '
        DB     ESC
        MOV    A,P3
        ACALL  WRBYTE
;
; Display TMOD
;
        ACALL  WT_STRING
        DB     LF,CR,'TMOD = '
        DB     ESC
        MOV    A,TMOD
        ACALL  WRBYTE
;
; Display TCON
;
        ACALL  WT_STRING
        DB     '    TCON = '
        DB     ESC
        MOV    A,TCON
        ACALL  WRBYTE
; 
; Display SCON
;
        ACALL  WT_STRING
        DB     '    SCON = '
        DB     ESC
        MOV    A,SCON
        ACALL  WRBYTE
;
; Display PSW
;
        ACALL  WT_STRING
        DB     '    PSW  = '
        DB     ESC
        MOV    A,PSW
        ACALL  WRBYTE
;
; Display PCON
;
        ACALL  WT_STRING
        DB     LF,CR,'PCON = '
        DB     ESC
        MOV    A,PCON
        ACALL  WRBYTE
;
; Display TH0
;
        ACALL  WT_STRING
        DB     '    TH0  = '
        DB     ESC
        MOV    A,TH0
        ACALL  WRBYTE
;
; Display TL0
;
        ACALL  WT_STRING
        DB     '    TL0  = '
        DB     ESC
        MOV    A,TL0
        ACALL  WRBYTE
;
; Display TH1
;
        ACALL  WT_STRING
        DB     '    TH1  = '
        DB     ESC
        MOV    A,TH1
        ACALL  WRBYTE
;
; Display TL1
;
        ACALL  WT_STRING
        DB     '    TL1  = '
        DB     ESC
        MOV    A,TL1
        ACALL  WRBYTE
        ACALL  LFCR
        LJMP   GETSEL
;
B_RUN:  ACALL  WT_STRING
        DB     '-A 256 Byte Block of Rom',LF,LF,CR
        DB     'Block>'
        DB     ESC
        ACALL  READHEX
        MOV    R1,A
        ACALL  WT_STRING
        DB     LF,CR,'      00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F',LF,LF,CR
        DB     ESC
        MOV    DPH,R1
        MOV    R0,#00H
B_2:    MOV    DPL,R0
        ACALL  LFCR
        MOV    A,DPH
        ACALL  WRBYTE
        MOV    A,DPL
        ACALL  WRBYTE
        MOV    A,#' '
        ACALL  WT_CHAR
        ACALL  WT_CHAR
B_1:    MOV    DPL,R0   
        CLR    A
        MOVC   A,@A+DPTR
        ACALL  WRBYTE
        MOV    A,#' '
        ACALL  WT_CHAR
        INC    R0
        MOV    A,R0
        ANL    A,#00FH
        CJNE   A,#000H,B_1
        CJNE   R0,#000H,B_2
        ACALL  LFCR
        LJMP   GETSEL
;
D_RUN:  ACALL  WT_STRING
        DB     '-A 128 Byte Block of Internal Ram',LF,LF,CR
        DB     LF,CR,'    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F',LF,LF,CR
        DB     ESC
        MOV    R0,#00H
D_2:    ACALL  LFCR
        MOV    A,R0
        ACALL  WRBYTE
        MOV    A,#' '
        ACALL  WT_CHAR
        ACALL  WT_CHAR
D_1:    MOV    A,@R0
        ACALL  WRBYTE
        MOV    A,#' '
        ACALL  WT_CHAR
        INC    R0
        MOV    A,R0
        ANL    A,#00FH
        CJNE   A,#000H,D_1
        CJNE   R0,#080H,D_2
        ACALL  LFCR
        LJMP   GETSEL
;  
H_RUN:  ACALL  WT_STRING
        DB     '-Upload Hex File',LF,CR
        DB     ESC
;
H_1:    ACALL  RD_CHAR
        CJNE   A,#':',H_X ; Exit if not a ":"
;
        ACALL  READHEX    ; Get Word Count
        MOV    R1,A       ; Load Word Count to R1
;
        ACALL  READHEX    ; Read Address and put into Data Pointer        
        ADD    A,#008H    ; Add offset in address
        MOV    DPH,A      ; Upper Byte
;
        ACALL  READHEX    ; Lower Byte
        MOV    DPL,A
;
        ACALL  READHEX    ; Read Record Type
        CJNE   A,#0,H_Y   ; Done and Exit
;
H_2:    ACALL  READHEX    ; Read Data
        MOVX   @DPTR,A    ; Burn ROM
        ACALL  WAIT       ; Wait for Burn Time
        INC    DPTR       ; Increment Data Pointer
        DJNZ   R1,H_2     ; Loop Till Out of Words
        ACALL  READHEX    ; Read Checksum but don't do anything with it
        ACALL  LFCR
        SJMP   H_1
;
; Done and Exit Read Last Byte
;
H_Y:    ACALL  READHEX
        ACALL  WT_STRING
        DB     LF,CR,'DONE LOAD!!',LF,CR
        DB     ESC
H_X:    ACALL  LFCR
        LJMP   GETSEL
;
C_RUN:  ACALL  WT_STRING
        DB     '-Upload Hex File For Ckecksum Check',LF,CR
        DB     ESC
        MOV    R3,#0      ; Initialize to Good Load Use R3 for Flag
;
C_1:    ACALL  RD_CHAR
        CJNE   A,#':',C_4 ; Exit if not a ":"
        MOV    R0,#000H   ; Clear Resister for Checksum
;
        ACALL  READHEX    ; Get Word Count
        MOV    R1,A       ; Load Word Count to R1
        MOV    R0,A       ; Initial Value for Checksum
;
        ACALL  READHEX    ; Read Address and put into Data Pointer        
        MOV    R2,A
        ADD    A,R0       ; Add Upper Address Byte to Checksum
        MOV    R0,A
        MOV    A,R2
        ADD    A,#008H    ; Add offset in address
        MOV    DPH,A      ; Upper Byte
;
        ACALL  READHEX    ; Lower Byte
        MOV    DPL,A
        ADD    A,R0       ; Add Lower Address Byte to Checksum
        MOV    R0,A
;
        ACALL  READHEX    ; Read Record Type
        CJNE   A,#0,C_Y   ; Done and Exit
;
C_2:    ACALL  READHEX    ; Read Data But Don't Do Anything With It
        CLR    A
        MOVC   A,@A+DPTR  ; Read ROM
        ADD    A,R0       ; Add for Checksum
        MOV    R0,A
        INC    DPTR       ; Increment Data Pointer
        DJNZ   R1,C_2     ; Loop Till Out of Words
;
; Write out if Checksum Good or Bad
;
        MOV    CKSUM,R0
        ACALL  READHEX     ; Read Checksum of Line
        CPL    A           ; Complement Checksum
        ADD    A,#1        ; Add 1
        CJNE   A,CKSUM,C_3 ; Jump if Bad Checksum        
        ACALL  WT_STRING   ; Write Good Checksum
        DB     LF,CR,' Good Checksum ',LF,CR
        DB     ESC
        SJMP   C_1
C_3:    ACALL  WT_STRING   ; Write Bad Checksum
        DB     LF,CR,' Bad Checksum ',LF,CR
        DB     ESC
        MOV    R3,#       1 ; Set Flag for Bad Load
        SJMP   C_1        ; Loop Back for Next Line
C_4:    SJMP   C_X
;
; Done and Exit Read Last Byte
;
C_Y:    ACALL  READHEX
        CJNE   R3,#0,C_Z
        ACALL  WT_STRING
        DB     LF,CR,'GOOD CHECKSUM DONE!! ',LF,CR
        DB     ESC
        SJMP   C_X
C_Z:    ACALL  WT_STRING
        DB     LF,CR,'BAD CHECKSUM DONE!! ',LF,CR
        DB     ESC
C_X:    ACALL  LFCR
        LJMP   GETSEL
;
J_RUN:  LJMP   NEWPROG
;
E_RUN:  ACALL  WT_STRING
        DB     '-Upload Hex File',LF,CR
        DB     ESC
;
E_1:    ACALL  RD_CHAR
        CJNE   A,#':',E_X ; Exit if not a ":"
;
        ACALL  READHEX    ; Get Word Count
        MOV    R1,A       ; Load Word Count to R1
;
        ACALL  READHEX    ; Read Address and put into Data Pointer        
        MOV    DPH,A      ; Upper Byte
;
        ACALL  READHEX    ; Lower Byte
        MOV    DPL,A
;
        ACALL  READHEX    ; Read Record Type
        CJNE   A,#0,E_Y   ; Done and Exit
;
E_2:    ACALL  READHEX    ; Read Data
        MOVX   @DPTR,A    ; Burn ROM
        ACALL  WAIT       ; Wait for Burn Time
        INC    DPTR       ; Increment Data Pointer
        DJNZ   R1,E_2     ; Loop Till Out of Words
        ACALL  READHEX    ; Read Checksum but don't do anything with it
        ACALL  LFCR
        SJMP   E_1
;
; Done and Exit Read Last Byte
;
E_Y:    ACALL  READHEX
        ACALL  WT_STRING
        DB     LF,CR,'DONE LOAD!! ',LF,CR
        DB     ESC
E_X:    ACALL  LFCR
        LJMP   GETSEL
;
K_RUN:  ACALL  WT_STRING
        DB     '-Upload Hex File For Ckecksum Check',LF,CR
        DB     ESC
        MOV    R3,#0      ; Initialize to Good Load Use R3 for Flag
;
K_1:    ACALL  RD_CHAR
        CJNE   A,#':',K_4 ; Exit if not a ":"
        MOV    R0,#000H   ; Clear Resister for Checksum
;
        ACALL  READHEX    ; Get Word Count
        MOV    R1,A       ; Load Word Count to R1
        MOV    R0,A       ; Initial Value for Checksum
;
        ACALL  READHEX    ; Read Address and put into Data Pointer        
        MOV    R2,A
        ADD    A,R0       ; Add Upper Address Byte to Checksum
        MOV    R0,A
        MOV    A,R2
        MOV    DPH,A      ; Upper Byte
;
        ACALL  READHEX    ; Lower Byte
        MOV    DPL,A
        ADD    A,R0       ; Add Lower Address Byte to Checksum
        MOV    R0,A
;
        ACALL  READHEX    ; Read Record Type
        CJNE   A,#0,K_Y   ; Done and Exit
;
K_2:    ACALL  READHEX    ; Read Data But Don't Do Anything With It
        CLR    A
        MOVC   A,@A+DPTR  ; Read ROM
        ADD    A,R0       ; Add for Checksum
        MOV    R0,A
        INC    DPTR       ; Increment Data Pointer
        DJNZ   R1,K_2     ; Loop Till Out of Words
;
; Write out if Checksum Good or Bad
;
        MOV    CKSUM,R0
        ACALL  READHEX     ; Read Checksum of Line
        CPL    A           ; Complement Checksum
        ADD    A,#1        ; Add 1
        CJNE   A,CKSUM,K_3 ; Jump if Bad Checksum        
        ACALL  WT_STRING   ; Write Good Checksum
        DB     LF,CR,' Good Checksum ',LF,CR
        DB     ESC
        SJMP   K_1
K_3:    ACALL  WT_STRING   ; Write Bad Checksum
        DB     LF,CR,' Bad Checksum ',LF,CR
        DB     ESC
        MOV    R3,#       1 ; Set Flag for Bad Load
        SJMP   K_1        ; Loop Back for Next Line
K_4:    SJMP   K_X
;
; Done and Exit Read Last Byte
;
K_Y:    ACALL  READHEX
        CJNE   R3,#0,K_Z
        ACALL  WT_STRING
        DB     LF,CR,'GOOD CHECKSUM DONE!!',LF,CR
        DB     ESC
        SJMP   K_X
K_Z:    ACALL  WT_STRING
        DB     LF,CR,'BAD CHECKSUM DONE!! ',LF,CR
        DB     ESC
K_X:    ACALL  LFCR
        LJMP   GETSEL
;
; List Out The Menu
;
N_RUN:  ACALL  WT_STRING
        DB     LF,CR,'R = Read Int RAM',LF,CR
        DB           'W = Write to Int RAM',LF,CR
        DB           'O = Read ROM',LF,CR
        DB           'M = Write ROM and Ext Ram',LF,CR
        DB           'S = Display SFRs',LF,CR
        DB           'B = 256 bytes of ROM',LF,CR
        DB           'D = 128 bytes of Int RAM',LF,CR
        DB           'H = Load HEX File for MONITOR Progs',LF,CR
        DB           'C = Verify Checksums MONITOR Progs',LF,CR
        DB           'J = Jump to run Progs',LF,CR
        DB           'E = Load HEX File for Progs',LF,CR
        DB           'K = Verify Checksums for Progs',LF,CR
        DB           'N = This Menu',LF,CR
        DB           'A = Read Ext RAM',LF,CR
        DB           'X = 256 bytes of Ext RAM',LF,CR
        DB     ESC
        LJMP   GETSEL
;
; Read External Ram Part
;
A_RUN:  ACALL  WT_STRING
        DB     '-EXRAM>'
        DB     ESC
        ACALL  READHEX
        MOV    DPH,A
        ACALL  READHEX
        MOV    DPL,A
        MOV    A,#':'
        ACALL  WT_CHAR
        CLR    A
        MOVX   A,@DPTR
        ACALL  WRBYTE
        ACALL  LFCR
        LJMP   GETSEL
;
; Dump 256 byte Block of Ext Ram
;
X_RUN:  ACALL  WT_STRING
        DB     '-A 256 Byte Block of Ext Ram',LF,LF,CR
        DB     'Block>'
        DB     ESC
        ACALL  READHEX
        MOV    R1,A
        ACALL  WT_STRING
        DB     LF,CR,'      00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F',LF,LF,CR
        DB     ESC
        MOV    DPH,R1
        MOV    R0,#00H
X_2:    MOV    DPL,R0
        ACALL  LFCR
        MOV    A,DPH
        ACALL  WRBYTE
        MOV    A,DPL
        ACALL  WRBYTE
        MOV    A,#' '
        ACALL  WT_CHAR
        ACALL  WT_CHAR
X_1:    MOV    DPL,R0   
        CLR    A
        MOVX   A,@DPTR
        ACALL  WRBYTE
        MOV    A,#' '
        ACALL  WT_CHAR
        INC    R0
        MOV    A,R0
        ANL    A,#00FH
        CJNE   A,#000H,X_1
        CJNE   R0,#000H,X_2
        ACALL  LFCR
        LJMP   GETSEL
;
$INCLUDE(WT_STRIN.ASM)
$INCLUDE(RD_CHAR.ASM)
$INCLUDE(WT_CHAR.ASM)
$INCLUDE(ASC2HEX.ASM)
$INCLUDE(HEX2ASC.ASM)
$INCLUDE(LFCR.ASM)
$INCLUDE(WAIT.ASM)
$INCLUDE(READHEX.ASM)
$INCLUDE(WRBYTE.ASM)
;
        END

 