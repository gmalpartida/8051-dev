.module nop_test

.area INTV (ABS)


RESET:
	ljmp main

.area CSEG (ABS, CODE)

main:
	nop
	sjmp	main




