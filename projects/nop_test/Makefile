CC=/opt/sdcc/bin/sdas8051
LD=/opt/sdcc/bin/sdld
PACKIHX=/opt/sdcc/bin/packihx
FLASHER=minipro
HEXDUMP=hexdump
MINICOM=minicom
MAKEBIN=makebin
ROM='AT28C16@DIP24'

INC=inc
SRC=src/nop_test.asm
TARGET=bin/nop_test
CFLAGS= -los -I$(INC) $(TARGET).rel

.PHONY: all, rel, ihx, hex, bin, flash, dump, uart, nop, clean

all: bin

rel:
	$(CC) $(CFLAGS) $(SRC)

ihx: rel
	$(LD) -i $(TARGET).rel

hex: ihx
	$(PACKIHX) $(TARGET).ihx > $(TARGET).hex

bin: hex
	$(MAKEBIN) -s 32768 $(TARGET).hex $(TARGET).bin

flash:
	$(FLASHER) -p $(ROM) -w $(TARGET).bin

dump:
	$(HEXDUMP) -C $(TARGET).bin

uart:
	sudo $(MINICOM) 8051

nop:
	dd if=/dev/zero of=bin/32k_nop.bin bs=1K count=32

clean:
	rm -f bin/*
