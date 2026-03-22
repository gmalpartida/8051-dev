delay_1_sec:
	mov r2, #0x64
delay2:
	mov r4, #0x64
delay3:
	mov r3, #0x28
wait:
	djnz r3, wait	 
	djnz r4, delay3
	djnz r2, delay2  
	ret
