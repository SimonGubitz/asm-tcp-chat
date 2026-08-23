ASM := nasm
ASMFLAGS = -f elf64 -g -F dwarf
LD := ld
LDFLAGS :=

BUILD_DIR := bin/build
OUTPUT_DIR := bin
SOURCE_DIR := src

SRC := $(SOURCE_DIR)/main.asm $(SOURCE_DIR)/connection/socket.asm
OBJS = $(SRC:$(SOURCE_DIR)/%.asm=$(BUILD_DIR)/%.o)
BIN := $(OUTPUT_DIR)/chat-server

PORT := 1234

.PHONY: run

$(BIN): $(OBJS)
	@echo "linking"
	mkdir -p $(@D)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.asm
	@echo "assembling + $(@D)"
	mkdir -p $(@D)
	$(ASM) $(ASMFLAGS) -o $@ $<

run: $(BIN)
	./$(BIN)

clean:
	$(RM) -r $(BUILD_DIR)
