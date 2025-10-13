ASEM51=/opt/asem51/asem

ASEM51_FLAGS=-i /opt/asem51/mcu -i inc/

SRC=src/demo.a51
TARGET=bin/demo

.PHONY: all build clean

all: build

build:
	$(ASEM51) $(ASEM51_FLAGS) $(SRC) $(TARGET).hex

clean:
	rm bin/*.*
