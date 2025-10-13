#
# cmon51 p89v51rd2.mak
#

CC = sdcc
LL = sdcc
PACK = packihx
P89V51RD2_CODELOC = 0xe000

OBJS= p89v51rd2.rel cmon51.rel d51.rel step.rel

p89v51rd2.hex: $(OBJS)
	$(LL) --code-loc $(P89V51RD2_CODELOC) --code-size 0x2000 --xram-loc 0x200 --xram-size 0x100 $(OBJS)
	$(PACK) p89v51rd2.ihx > p89v51rd2.hex

p89v51rd2.rel: p89v51rd2.c p89v51rd2.mak
	$(CC) -DMONITOR_LOC=$(P89V51RD2_CODELOC) -c p89v51rd2.c

cmon51.rel: cmon51.c cmon51.h d51.h p89v51rd2.mak
	$(CC) -c cmon51.c

d51.rel: d51.c d51.h p89v51rd2.mak
	$(CC) -c d51.c

step.rel: step.c p89v51rd2.mak
	$(CC) -c step.c
