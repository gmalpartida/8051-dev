
AS=/opt/asem51/asem
UCSIM=/opt/sdcc/bin/ucsim_51
VI=vim
DIS51=/opt/dis51/dis51
SOCAT=socat
MINICOM=minicom
SCREEN=screen

TARGET=$(notdir $(CURDIR))

SRC_DIR=src
BIN_DIR=bin

MAIN_FILE=$(SRC_DIR)/main.asm
HEX_FILE=$(BIN_DIR)/$(TARGET).hex
DIS_FILE=$(BIN_DIR)/$(TARGET).dis
VPORT0=/tmp/ttyV0
VPORT1=/tmp/ttyV1

AS_FLAGS= -i inc -i /opt/asem51/mcu -v 
UCSIM_FLAGS= -s $(VPORT0) -X 11.0592 
SOCAT_FLAGS=-d -d PTY,link=$(VPORT0),raw,echo=0 PTY,link=$(VPORT1),raw,echo=0
MINICOM_FLAGS=-D $(VPORT1)
SCREEN_FLAGS= -S sim_uart

.PHONY: all, build, clean, edit, dis, bridge, uart

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

uart:
	$(MINICOM) $(MINICOM_FLAGS) 

screen:
	$(SCREEN) $(SCREEN_FLAGS)
clean:
	rm -rf $(BIN_DIR)/*


