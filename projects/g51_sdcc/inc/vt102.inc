VT102_ESC			.equ		0x1b

.globl	VT102_CLEAR_SCREEN

; draws a line from the current position to a destination
; --> r7: row of end of line
; --> r6: col of end of line
.globl vt102_line_to
