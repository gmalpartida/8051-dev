#
# cmon51 at89c51rd2.mak
#

CC = sdcc
LL = sdcc
PACK = packihx
at89c51rd2_CODELOC = 0xd800

OBJS= at89c51rd2.rel cmon51.rel d51.rel step.rel

at89c51rd2.hex: $(OBJS)
	$(LL) --code-loc $(at89c51rd2_CODELOC) --code-size 0x2000 --xram-loc 0x600 --xram-size 0x100 $(OBJS)
	$(PACK) at89c51rd2.ihx > at89c51rd2.hex

at89c51rd2.rel: at89c51rd2.c at89c51rd2.mak
	$(CC) -DMONITOR_LOC=$(at89c51rd2_CODELOC) -c at89c51rd2.c

cmon51.rel: cmon51.c cmon51.h d51.h at89c51rd2.mak
	$(CC) -c cmon51.c

d51.rel: d51.c d51.h at89c51rd2.mak
	$(CC) -c d51.c

step.rel: step.c at89c51rd2.mak
	$(CC) -c step.c
