AS=/opt/asem51/asem
FLASHER=minipro
HEXDUMP=hexdump
MINICOM=minicom
VI=vi
HEXBIN=/opt/asem51/hexbin
UCSIM=/opt/sdcc/bin/ucsim_51

ROM='AT28C16@DIP24'

INC=inc
SRC=src/lcd_test.asm
TARGET=bin/lcd_test
ASFLAGS= -iinc/ -i../shared/inc/ -v
UCSIM_FLAGS = $(TARGET).hex

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
	$(UCSIM) $(UCSIM_FLAGS) 

clean:
	rm -f bin/*
