ASEM=/opt/asem51/asem
MINICOM=minicom
VI=vi
HEXDUMP=hexdump
HEXBIN=/opt/asem51/hexbin
UCSIM_51=/opt/sdcc/bin/ucsim_51

SRC=src/gboot51-2.asm
TARGET=bin/gboot51-2

ASEM_FLAGS= -i inc -v
MINICOM_FLAGS= 8051
OBJCOPY_FLAGS= -C
HEXDUMP_FLAGS=-C 
HEXBIN_FLAGS=--fill=ff --length=8000
UCSIM_51_FLAGS= -S uart=0,port=10000,raw $(TARGET).hex

.PHONY: all, build, clean, uart, edit, dump, bin, sim

all: build

build:
	$(ASEM) $(ASEM_FLAGS) $(SRC) $(TARGET).hex

uart:
	sudo $(MINICOM) $(MINICOM_FLAGS) 

edit:
	$(VI) $(SRC)

dump: bin
	$(HEXDUMP) $(HEXDUMP_FLAGS) $(TARGET).bin

bin: build
	$(HEXBIN) $(HEXBIN_FLAGS) $(TARGET).hex $(TARGET).bin

sim: build
	$(UCSIM_51) $(UCSIM_51_FLAGS)

clean:
	rm -f bin/*
