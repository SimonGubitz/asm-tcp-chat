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

start-test-server:
	nc -v6 -kl ::1 1735 | od -An -tx1 -v
