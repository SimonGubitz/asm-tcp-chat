# An Assembly TCP-Chat Server

Targetting the Linux x86-64 ELF64 ABI.
This is a TCP server running with IPv6 Connections.

## Architecture

### `main`

- owns memory / objects
- orchestrate functions

### `src/connection`

- Socket syscalls
- address construction

### `src/runtime`

- handle the connected sockets
- interface with `epoll`
- provide both [`direct`](./src/runtime/direct.asm) and [`group`](./src/runtime/group.asm) chats.


## Goals

- [ ] Fully functional IPv6 sockets
- [ ] Echo server
- [ ] Direct message
- [ ] Group chats
- [ ] Chat history

## TODO

### Critical

- [ ] Nothing

### Ideas

- [x] %env() directive to supply the port



## Sources

[Dartmouth Socketprogramming](https://www.cs.dartmouth.edu/~campbell/cs50/socketprogramming.html)

[Félix Cloutier x86 Reference Manual](https://felixcloutier.com/x86/)

[Man Pages](https://man7.org/)

