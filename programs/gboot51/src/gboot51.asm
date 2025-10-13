cseg
	ljmp main

ie0_vector:
	ljmp $
	ds 5
tf0_vector:
	ljmp $
	ds 5
ie1_vector:
	ljmp $
	ds 5
tf1_vector:
	ljmp $
	ds 5
serial_vector:
	ljmp serial_isr
	ds 5

main:

	mov sp, #10h			; set sp above register bank 1
	mov r0, #00h			; set inbuf pointers to bottom of buffer
	mov r1, #00h
	setb psw.3				; signal source that inbuf is not full
	mov r0, #80h
	mov r1, #80h
	clr p3.2
	mov scon, #50h			; set serial port mode 1, enable receiver
	mov th1, #0bbh			; set th1 to 187d, 1208 bps
	orl pcon, #80h			; set smod to double baud rate
	mov tmod, #20h			; set timer 1 to auto-reload mode
	mov tcon, #40h			; start t1 to generate baud clock
	mov ie, #90h			; enable serial interrupt
loop:
	clr psw.3				; set pointers to inbuf and receive data
	mov a, r0 				; inbuf is empty when intop = inplace
	cjne a, 01h, read 		; r1 of bank 0 is direct address 01h
	mov r0, #00h			; buffer empty, reset pointers to bottom
	mov r1, #00h
	sjmp send 				; send character T
read:
	movx a, @r0 			; get character
	inc r0 					; point to next character
send:
	setb psw.3				; set pointers to outbuf and store data
	cjne r1, #00h, sd		; see if outbuf is full and loop if so
	sjmp loop 				; r1 rolls over from ffh to 00h if full
sd:
	movx @r1, a				; store T in outbuf
	inc r1
	cjne r1, #81h, loop		; initiate transmission if first T
	setb scon.1 			; start transmissio process for first T
	sjmp loop 				; continue


serial_isr:
	push psw				; save register bank status
	push acc				; save a
	jbc scon.0, rcve		; serve the received data first
	jbc scon.1, xmit		; transmit data as second priority
	sjmp go 				; should never get to this jump
rcve:
	clr psw.3				; select bank 0 pointers inbuf
	mov a, sbuf				; get received character
	movx @r1, a				; store character at top of inbuf
	inc r1 					; increment top address of inbuf
	cjne r1, #7eh, rok		; see if inbuf is almost full
	setb p3.2				; signal data source of full condition
	sjmp full
rok:
	clr p3.2				; remove full signal to source
full:
	jbc scon.1, xmit 		; see if transmit interrupt also occurred
	sjmp go 				; if not then return
xmit:
	setb psw.3 				; select bank 1 pointers to outbuf
	mov a, r0				; compare r0 and r1 for equality
	cjne a, 09h, mor		; internal ram address 09h = r1, bank 1
	mov r0, #80h			; reset both pointers to bottom of outbuf
	mov r1, #80h
	sjmp go 
mor:
	movx a, @r0 			; get next character to be transmitted
	mov sbuf, a				; begin transmission
	inc r0 					; point to next trasnmit character
go:
	pop acc 				; restore a and psw
	pop psw 
	reti

end




