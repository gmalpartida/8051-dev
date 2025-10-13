	; BOOT-51 Customization Header
	; ============================
	; generated with CUSTOMIZ V1.1

	STARTADDR CODE 0	;start address of bootstrap program
	USERPROGS CODE 08000H	;start address of user programs

	; Baudrate Generation
	; -------------------
	; system clock frequency:  11.0592 MHz
	; baudrate generator:      timer 1
	; nominal baudrate:        1200.0 Baud
	; required accuracy:       1.00 %
	;
	; resulting baudrate:      1200.0 Baud

	INTEL8051  EQU 0
	RELOAD     EQU 0E8H
	SMOD       EQU 0

	TIMEBASE   EQU 02CDH
	CHARTIME   EQU 010AH
