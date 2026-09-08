cc := gcc

SRC := src/main.c
BIN := bin/client

$(BIN):
	mkdir -p bin
	$(cc) $(SRC) -o $(BIN)

run: $(BIN)
	./$(BIN)

clean:
	$(RM) -r ./bin
