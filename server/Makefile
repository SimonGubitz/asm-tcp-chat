UNAME_S := $(shell uname -s)	# Linux, Darwin

ASM := nasm
ASMFLAGS = -i ./src/constants/ -f elf64 -g -F dwarf
LD := ld
LDFLAGS :=

BUILD_DIR := bin/build
OUTPUT_DIR := bin
SOURCE_DIR := src

SRC := $(SOURCE_DIR)/main.asm $(SOURCE_DIR)/error.asm $(SOURCE_DIR)/connection/socket_ipv6.asm $(SOURCE_DIR)/runtime/echo.asm
OBJS = $(SRC:$(SOURCE_DIR)/%.asm=$(BUILD_DIR)/%.o)
BIN := $(OUTPUT_DIR)/chat-server

PORT := 1234

.PHONY: run debug

$(BIN): $(OBJS)
	mkdir -p $(@D)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.asm
	mkdir -p $(@D)
	$(ASM) $(ASMFLAGS) -o $@ $<

clean-build: clean build
clean-run: clean run

build: $(BIN)

run: $(BIN)
	./$(BIN)

run-test: clean build
	# gcc -no-pie $(OBJS) -o bin/test && ./bin/test
	gcc -no-pie src/test.c bin/build/connection/socket_ipv6.o bin/build/error.o bin/build/runtime/echo.o -o bin/test && ./bin/test
	

clean:
	$(RM) -r $(OUTPUT_DIR)/**

