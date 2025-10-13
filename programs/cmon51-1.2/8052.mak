#
# cmon51 8052.mak
#

CC = /opt/sdcc/bin/sdcc
LL = /opt/sdcc/bin/sdcc
PACK = /opt/sdcc/bin/packihx

OBJS= 8052.rel cmon51.rel d51.rel step.rel

8052.hex: $(OBJS)
	$(LL) --code-size 0x2000 --xram-loc 0x1f00 --xram-size 0x100 $(OBJS)
	$(PACK) 8052.ihx > 8052.hex

8052.rel: 8052.c 8052.mak
	$(CC) -c -DSFR_CODE_LOC=0x7ff8 -DXRAM_CODE_LOC=0x2000 8052.c

cmon51.rel: cmon51.c cmon51.h d51.h 8052.mak
	$(CC) -c cmon51.c

d51.rel: d51.c d51.h 8052.mak
	$(CC) -c d51.c

step.rel: step.c 8052.mak
	$(CC) -c step.c
