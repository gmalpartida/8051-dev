.module blink_led

;.area INTV (ABS)

;.org	0x0000

RESET:
	ljmp main

.ds 0x08
;.org 	0x000b
	ljmp timer_isr

;.area CSEG (ABS, CODE)

;.org 0x0090
.ds 0x20

main:

	setb ea				; enable interrupts
	setb et0			; enable T0 interrupt
	setb pt0			; set T0 to high priority level
	mov a, tmod
	mov a, #0x01
	mov tmod, a

	mov th0, #0x4c		; set up for 50ms timeout
	mov tl0, #0x00

	mov a, #20
	setb TR0			; turn timer on

	sjmp .

timer_isr:
	
	mov TH0, #0x4c
  	mov TL0, #0x00
	
	clr tf0

	dec a				; wait for 20 timeouts, 1 second 
	jnz exit_isr

    cpl p1.0
	cpl p1.1
	cpl p1.2
	cpl p1.3
	cpl p1.4
	cpl p1.5
	cpl p1.6
	cpl p1.7

	mov a, #20
exit_isr:
	reti


