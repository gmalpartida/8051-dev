#include <8051.h>
 
// Add two 8-bit numbers

char var1 = 5;
char var2 = 6;
char var3 = 7;

void main(void)
{
	while (1)
	{
        var3 = var1 + var2;
        __asm
        WTSTRING   .equ    0x077C  ; Subroutine in Monitor Program that writes a string.
		WTBYTE     .equ    0x07ED  ; Subroutine in Monitor Program that write a Byte.
        ESC        .equ    0x1B    ; Escape.
        LF         .equ    10      ; Line Feed.
        CR         .equ    13      ; Carriage Return.
		                           ; Write-out operations performed.
                                   ; Write-out var1.
		LCALL      WTSTRING
        .db        LF,CR
        .ascii     /var1 = /
        .db        ESC
        MOV        A,_var1
        LCALL      WTBYTE
                                   ; Write-out var2.
		LCALL      WTSTRING
        .db        LF,CR
        .ascii     /var2 = /
        .db        ESC
        MOV        A,_var2
        LCALL      WTBYTE
		                           ; Write-out var3.
		LCALL      WTSTRING
        .db        LF,CR
        .ascii     /var3 = /
        .db        ESC
        MOV        A,_var3
        LCALL      WTBYTE
				                   ; Write-out space.
		LCALL      WTSTRING
        .db        LF,CR
        .db        ESC
		__endasm;
	}
}
 