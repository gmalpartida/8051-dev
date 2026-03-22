AS=/opt/sdcc/bin/sdas8051
LD=/opt/sdcc/bin/sdld
PACKIHX=/opt/sdcc/bin/packihx
FLASHER=minipro
HEXDUMP=hexdump
MINICOM=minicom
VI=vi
MAKEBIN=/opt/sdcc/bin/makebin
UCSIM=/opt/sdcc/bin/ucsim_51

ROM='AT28C16@DIP24'

INC=inc
SRC=src/rom_test.asm
TARGET=bin/rom_test
ASFLAGS= -los -I$(INC) $(TARGET).rel

.PHONY: all build link pack flash dump uart clean edit bin sim

all: pack

build:
	$(AS) $(ASFLAGS) $(SRC)

link: build
	$(LD) -i $(TARGET)

pack: link
	$(PACKIHX) $(TARGET).ihx > $(TARGET).hex

flash: pack
	$(FLASHER) -p $(ROM) -w $(TARGET).hex

dump: bin
	$(HEXDUMP) -C $(TARGET).bin

uart:
	sudo $(MINICOM) 8051

edit:
	$(VI) $(SRC)

bin: pack
	$(MAKEBIN) $(TARGET).hex $(TARGET).bin

sim: pack
	$(UCSIM) $(TARGET).hex

clean:
	rm -f bin/*
