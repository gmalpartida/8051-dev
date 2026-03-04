cseg

VT102_ESC			equ		1bh
VT102_UP:			db		VT102_ESC, '[', 'A', VT102_ESC, 'O', 'A', 0
VT102_DOWN:			db		VT102_ESC, '[', 'B', VT102_ESC, 'O', 'B', 0
VT102_RIGHT:		db		VT102_ESC, '[', 'C', VT102_ESC, 'O', 'C', 0
VT102_LEFT:			db		VT102_ESC, '[', 'D', VT102_ESC, 'O', 'D', 0
VT102_CLEAR_SCREEN:	db		VT102_ESC, '[', 'H', VT102_ESC, '[', '2', 'J', 0
