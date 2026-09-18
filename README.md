# An Assembly TCP-Chat Server

An event-driven TCP server written entirely in x86-64 assembly using Linux syscalls.
The project explores low-level networking by implementing IPv6 sockets, an epoll-based event loop, modular runtimes, and a custom messaging protocol without relying on libc.

> This project is primarily a learning exercise in systems programming, with an emphasis on understanding Linux networking, event-driven architectures, and protocol design from first principles.


<!-- [!](./assets/demo-video.mp4) Showing a tmux screen with the server running on the left with maybe some logs and on the right vertically stacked two panes acting as separate peers chatting -->

## How to run?

***How to run the server***

Natively:
```
cd server
make run
```

Cross-Platform:
```
docker compose up
```

The server currently runs on port `1735`.


***How to run the client***

Currently the [clients](./client/) are NOT worked on, but using `nc` is possible.

```
nc -6 ::1 1735
```


## Architecture

### `main`

The `_start` entry-point initializes the listening socket, binds it to an IPv6 address and puts it into `LISTEN` state.
After the setup, the `runtime` takes over the orchestration and event-loop of the server, by listening to events on the socket, and accepting/responding dynamically.

### [`runtime`](./server/src/runtime/)

There are different runtimes like a single-user [echo](./server/src/runtime/echo/), peer-to-peer [direct message](./server/src/runtime/direct/) and a [group chat](./server/src/runtime/group/).
These runtimes manage the epoll instance and orchestrate the response or write to other users.


## Design

Read more about the protocol design [here](./server/src/protocol/README.md).

### Why `epoll`?

Using `epoll` allows for an event driven architecture, and thus allows for performance and efficiency gains.
In conjunction with the [custom protocol](./server/src/protocol/README.md) the benchmarks can be seen [here](./benchmarks.md).

### Why `IPv6`?

I have never used IPv6 and wanted to try it.

## Current Features

- x86-64 assembly (NASM)
- Direct Linux syscalls / no `libc` reliance
- IPv6 networking
- `epoll` event loop
- modular runtime architecture
- gather writes using writev()
- C test client

## Goals / Roadmap

- [x] Fully functional IPv6 sockets
- [x] epoll
- [x] Echo server
- [ ] Custom protocol with chat-metadata
- [ ] Direct message
- [ ] Group chats
- [ ] Chat history

## TODO

### Critical

- [ ] Nothing

### Future

- [x] Handle EOFs with a proper disconnect
- [ ] dynamically choose runtimes
- [ ] dynamic response based on protocol support

### Ideas

- [ ] %env() directive to supply the port dynamically
- [ ] dockerized server



## Sources

[Dartmouth Socketprogramming](https://www.cs.dartmouth.edu/~campbell/cs50/socketprogramming.html)

[Félix Cloutier x86 Reference Manual](https://felixcloutier.com/x86/)

[Man Pages](https://man7.org/)

