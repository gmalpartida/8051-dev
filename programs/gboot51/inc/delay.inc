delay_1_sec:
	mov r2, #0064h
delay2:
	mov r4, #0064h
delay3:
	mov r3, #0028h
wait:
	djnz r3, wait	 
	djnz r4, delay3
	djnz r2, delay2  
	ret
