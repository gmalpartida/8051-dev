AS=/opt/asem51/asem
FLASHER=minipro
HEXDUMP=hexdump
MINICOM=minicom
VI=vi
HEXBIN=/opt/asem51/hexbin
UCSIM=/opt/sdcc/bin/ucsim_51

ROM='UPD27C256A@DIP28'

INC=inc
SRC=src/monitorb.asm
TARGET=bin/monitorb
ASFLAGS= -i -v
MINICOM_FLAGS=-D /dev/ttyUSB0 -b 9600

.PHONY: all build link pack flash dump uart clean edit bin sim

all: build

build:
	$(AS) $(ASFLAGS) $(SRC) $(TARGET).hex

flash: build
	$(FLASHER) -p $(ROM) -w $(TARGET).hex

dump: bin
	$(HEXDUMP) -C $(TARGET).bin

uart:
	sudo $(MINICOM) $(MINICOM_FLAGS)

edit:
	$(VI) $(SRC)

bin: build
	$(HEXBIN) $(TARGET).hex

sim: build
	$(UCSIM) $(TARGET).hex

clean:
	rm -f bin/*
