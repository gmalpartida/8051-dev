AS=/opt/asem51/asem
FLASHER=minipro
HEXDUMP=hexdump
MINICOM=minicom
VI=vi
HEXBIN=/opt/asem51/hexbin
UCSIM=/opt/sdcc/bin/ucsim_51

ROM='AT28C16@DIP24'

INC=inc
SRC=src/mem_test.asm
TARGET=bin/mem_test
ASFLAGS= -iinc/ -v

.PHONY: all build flash dump uart clean edit bin sim

all: build

build:
	$(AS) $(ASFLAGS) $(SRC) $(TARGET).hex

flash: build
	$(FLASHER) -p $(ROM) -w $(TARGET).hex

dump: bin
	$(HEXDUMP) -C $(TARGET).bin

uart:
	sudo $(MINICOM) 8051

edit:
	$(VI) $(SRC)

bin: build
	$(HEXBIN) $(TARGET).hex $(TARGET).bin

sim: build
	$(UCSIM) $(TARGET).hex

clean:
	rm -f bin/*
