# call with `gdb -x debug.gdb´
shell make clean-build

file ./bin/chat-server

tui enable
b _start
r
