.include "vt102.inc"

.area cseg (CODE)

; draws a line from the current position to a destination
; --> r7: row of end of line
; --> r6: col of end of line
vt102_line_to:
	

	ret

VT102_UP:			.db		VT102_ESC, '[', 'A', 0
VT102_DOWN:			.db		VT102_ESC, '[', 'B', 0
VT102_RIGHT:		.db		VT102_ESC, '[', 'C', 0
VT102_LEFT:			.db		VT102_ESC, '[', 'D', 0
VT102_CLEAR_SCREEN:	.db		VT102_ESC, '[', 'H', VT102_ESC, '[', '2', 'J', 0
