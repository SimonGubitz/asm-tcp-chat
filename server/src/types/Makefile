OUT_DIR := ../../bin/tests/

test-hashmap:
  mkdir -p $(OUT_DIR)
  nasm -f elf64 -g -F dwarf -o hashmap.o hashmap.asm
  gcc -o $(OUT_DIR)test-hashmap test-hashmap.c hashmap.o
  ./$(OUT_DIR)test-hashmap

