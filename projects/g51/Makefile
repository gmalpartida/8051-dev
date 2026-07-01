AS=/opt/asem51/asem
UCSIM=/opt/sdcc/bin/ucsim_51
VI=vim
DIS51=/opt/dis51/dis51
SOCAT=socat
MINICOM=minicom
SCREEN=screen
HEXDUMP=hexdump
OBJCOPY=/opt/sdcc/bin/sdobjcopy

TARGET=$(notdir $(CURDIR))

SRC_DIR=src
BIN_DIR=bin
CFG_DIR=cfg

MAIN_FILE=$(SRC_DIR)/main.asm
HEX_FILE=$(BIN_DIR)/$(TARGET).hex
DIS_FILE=$(BIN_DIR)/$(TARGET).dis
VPORT0=/tmp/ttyV0
VPORT1=/tmp/ttyV1
BIN_FILE=$(BIN_DIR)/$(TARGET).bin
UCSIM_FILE=$(CFG_DIR)/$(TARGET).ucsim

AS_FLAGS= -i inc -v 
UCSIM_FLAGS= -C $(UCSIM_FILE) -t 51 -s$(VPORT0) -X 11.0592 
SOCAT_FLAGS=-d -d PTY,link=$(VPORT0),raw,echo=0 PTY,link=$(VPORT1),raw,echo=0
MINICOM_FLAGS=-D $(VPORT1)
SCREEN_FLAGS= -S sim_uart
HEXDUMP_FLAGS = -C
OBJCOPY_FLAGS=-I ihex -O binary $(HEX_FILE)

.PHONY: all, build, clean, edit, dis, bridge, uart, screen, dump, bin, sim

all: build

build:
	$(AS) $(AS_FLAGS) $(MAIN_FILE) $(HEX_FILE)

sim: build
	$(UCSIM) $(UCSIM_FLAGS) $(HEX_FILE)

edit: 
	$(VI) $(MAIN_FILE)

dis: build
	$(DIS51) $(DIS51_FLAGS)	< $(HEX_FILE) > $(DIS_FILE)

bridge:
	$(SOCAT) $(SOCAT_FLAGS) 

uart: build
	$(MINICOM) $(MINICOM_FLAGS) 

screen:
	$(SCREEN) $(SCREEN_FLAGS) 

dump: bin
	$(HEXDUMP) $(HEXDUMP_FLAGS) $(BIN_FILE)

bin: build
	$(OBJCOPY) $(OBJCOPY_FLAGS) $(BIN_FILE)

clean:
	rm -rf $(BIN_DIR)/*


