



init_t1_as_baud_generator:
	mov scon, #50h			; set serial port mode 1, enable receiver
	mov th1, #0bbh			; set th1 = 187d, 1200 bps
	orl pcon, #80h			; set smod = 1, double baud rate
	mov tmod, #20h			; set timer 1 to auto-reload mode
	mov tcon, #40h			; start t1 to generate baud clock
	mov ie, #90h			; enable serial interrupt
	ret
