ASM := nasm
ASMFLAGS := 
LD := ld
LDFLAGS := 

SRC := src/main.asm
OBJ := bin/main.o
BIN := bin/chat-server

PORT := 1234


$(BIN): $(OBJ)
	$(LD) $(LDFLAGS)

run: $(BIN)
	./$(BIN)

test:
	nc localhost $(PORT)

