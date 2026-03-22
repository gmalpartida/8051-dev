.module rom_test

.area INTV (ABS)

.org 0x0000

main:
	ljmp add0
.org 0x0001
add0:
	ljmp 	add1
.org 0x0002
add1:
	ljmp	add2
.org 0x0004
add2:	
	ljmp 	add3
.org 0x0008
add3:
	ljmp 	add4
.org 0x0010
add4:
	ljmp	add5
.org 0x0020
add5:	
	ljmp 	add6
.org 0x0040
add6:
	ljmp 	add7
.org 0x0080
add7:	
	ljmp 	add8
.org 0x0100
add8:
	ljmp 	add9
.org 0x0200
add9:
	ljmp	add10
.org 0x0400
add10:	
	ljmp 	add11
.org 0x0800
add11:
	ljmp 	add12
.org 0x1000
add12:
	ljmp 	add13
.org 0x2000
add13:
	ljmp 	add14
.org 0x4000
add14:
	ljmp 	add14

