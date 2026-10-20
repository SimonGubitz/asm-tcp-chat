; src/runtime/echo.asm
%include "custom.inc"
%include "linux64.inc"
%include "epoll.inc"
%include "message.inc"
%include "signals.inc"

%define MAX_CONNS   1
%define MAX_EVENTS  1

%define MAX_AMNT_CHATS  1
%define BASE_AMNT_CHATS 1

; ./action.asm
extern _handle_echo_actions

; ../../chat/chat.asm
extern _create_chats

; ../../chat/read-message.asm
extern _read_message

; ../../connection/socket_ipv6.asm
extern _socket_accept
extern _socket_close

; ../../error.asm
extern _handle_error

section .bss
  amnt_conns    resb 1

  listen_sock   resq 1
  addr_ptr      resb 8
  addr_len      resb 4

  conn_sock     resq 1

  epoll_fd      resd 1
  epoll_event   resb 2 * EVENT_SIZE
  epoll_revent  resb EVENT_SIZE ; INFO: only a one element array, since its an echo server

  signalfd      resd 1

  sig_mask      resb sig_mask_size
  sig_mask_size equ  128

  sig_info      resb signalfd_siginfo_size


  chat          resq 2


section .data
  ; tests
  teststr                 db "received an input", LF, 0x0
  teststr_len             equ $ - teststr


  ; General outputs
  accept_connstr          db "Handling new connection. Welcome.", LF, 0x0
  accept_connstr_len      equ $ - accept_connstr

  rejectstr               db "The maximum amounts of connections has already been reached.", LF, 0x0
  rejectstr_len           equ $ - rejectstr

  shutdown_msg            db "Gracefully shutting down...", LF, 0x0
  shutdown_msg_len        equ $ - shutdown_msg

  goodbyestr              db "Goodbye, closing connection.", LF, 0x0
  goodbyestr_len          equ $ - goodbyestr

  ; Error Strings
  fail_accept_errstr      db "Failed to accept socket.", LF, 0x0
  fail_accept_errstr_len  equ $ - fail_accept_errstr

  epoll_create_errstr     db "Failed to create epoll instance.", LF, 0x0
  epoll_create_errstrlen  equ $ - epoll_create_errstr

  sigblock_errstr         db "Failed to set `sigprocmask`.", LF, 0x0
  sigblock_errstrlen      equ $ - sigblock_errstr

  signalfd_errstr         db "Failed to get a signal file descriptor.", LF, 0x0
  signalfd_errstrlen      equ $ - signalfd_errstr

  read_signal_errstr      db "Failed to read the signal.", LF, 0x0
  read_signal_errstrlen   equ $ - read_signal_errstr

  epoll_ctl_errstr        db "Failed to configure epoll instance.", LF, 0x0
  epoll_ctl_errstrlen     equ $ - epoll_ctl_errstr

section .text
  global _echo_runtime
  global _construct_epoll_event ; global for C testing


;; @brief handle new connections, and echo each response back
;; @assumption sockfd is a valid socket, that has been bound to an address and is in LISTEN state
;; @param rdi int - sockfd
;; @clobbers r10, rcx
_echo_runtime:

  mov byte [amnt_conns], 0
  mov [listen_sock], rdi

  ; create an epoll instance
  ; listen to:
  ; - incoming connections
  ; - messages sent by already connected clients
  ; - SIGINT to gracefully shut down

  ; TODO:
  ; create the chats in memory
  mov rdi, BASE_AMNT_CHATS
  call _create_chats

  mov [chat], rax


  ; INFO:
  ; int epoll_create(int size);
  ; int epoll_create1(int flags);
  mov rax, SYS_EPOLL_CREATE1
  mov rdi, 0x0
  syscall
  cmp rax, 0
  jl .err_epoll_create

  mov [epoll_fd], rax



  ; 1. Add the listen socket

  ; INFO:
  ; int epoll_ctl(int epfd, int op, int fd, struct epoll_event *_Nullable event);
  ; ==> epoll_ctl(epollfd, EPOLL_CTL_ADD, listen_sock, &ev)

  lea rdi, epoll_event
  mov rdx, [listen_sock]
  call _construct_epoll_event
  mov r10, rdi

  mov rdi, [epoll_fd]
  mov rsi, EPOLL_CTL_ADD
  mov rdx, [listen_sock]

  mov rax, SYS_EPOLL_CTL
  syscall

  cmp rax, 0
  jl .err_epoll_ctl




  ; 2. Add the signal handler
.sigemptyset:         ; sigemptyset(&mask);
  xor rdi, rdi
  mov [sig_mask], rdi
  mov [sig_mask+64], rdi

.sigaddset:           ; sigaddset(&mask, SIGINT);
  xor rdi, rdi
  or rdi, SIGINT
  mov [sig_mask], rdi


  ; block the default behavior
  ; INFO:
  ; rt_sigprocmask(int how, sigset_t *set, sigset_t *oset, size_t sigsetsize)
  ; C: sigprocmask(SIG_BLOCK, &mask, NULL)
  mov rax, SYS_RT_SIGPROCMASK
  mov rdi, SIG_BLOCK
  lea rsi, sig_mask
  mov rdx, NULL     ; no old set
  mov r10, SIGNAL_MASK_SIZE
  syscall

  cmp rax, -1
  je .err_sigblock


  ; INFO:
  ; int signalfd(int fd, const sigset_t *mask, int flags); -> SYS_SIGNALFD4
  ; int signalfd(int fd, *mask, ssize_t mask_size);
  mov rax, SYS_SIGNALFD
  mov rdi, -1           ; -1 to create a new fd
  lea rsi, sig_mask
  mov rdx, SIGNAL_MASK_SIZE
  syscall
  mov [signalfd], rax

  cmp rax, 0
  jl .err_signalfd

  ; INFO:
  ; int epoll_ctl(int epfd, int op, int fd, struct epoll_event *_Nullable event);
  ; ==> epoll_ctl(epollfd, EPOLL_CTL_ADD, , &ev)
  lea rdi, epoll_event
  mov rdx, [signalfd]
  call _construct_epoll_event
  mov r10, rdi

  mov rdi, [epoll_fd]
  mov rsi, EPOLL_CTL_ADD
  mov rdx, [signalfd]

  mov rax, SYS_EPOLL_CTL
  syscall

  cmp rax, 0
  jl .err_epoll_ctl

.runtime_loop:
  ; INFO:
  ; int   epoll_wait(int epfd, struct epoll_event events[n], int n, int timeout);
  ; int  epoll_pwait(int epfd, struct epoll_event events[n], int n, int timeout, const sigset_t *_Nullable sigmask);
  ; int epoll_pwait2(int epfd, struct epoll_event events[n], int n, const struct timespec *_Nullable timeout, const sigset_t *_Nullable sigmask);

  mov rdi, [epoll_fd]

  lea rsi, epoll_revent ; r(eturn)event
  mov rdx, MAX_EVENTS   ; max events
  mov r10, 0x493E0      ; 5min timeout
  mov rax, SYS_EPOLL_WAIT
  syscall
  ; rax holds the nfds <- number of events


  push rax
  ; test print
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, teststr
  mov rdx, teststr_len
  syscall
  pop rax


  ; iterate the events
  ; for (rcx = 0; rcx < nfds; rcx++) {}
  xor rcx, rcx
  mov r10, rax  ; r10 hold the nfds -> amount of file descriptor events
.event_iterate:
  cmp rcx, r10
  jge .end_event_iterate

  mov rax, rcx
  ; mul rcx, 12
  mov rax, 0

  mov rdx, rax
  mov eax, dword [epoll_revent+rdx]   ; get the event
  add rdx, 4  ; <- rdx holds undefined data
  mov esi, dword [epoll_revent+rdx]   ; INFO: +4 to get to the union | dword/eax to get the fd

  cmp esi, [signalfd]
  jne .handle_signals_done

.handle_signals:

  ; read into the `sig_info`
  ; INFO:
  ; int read();
  mov rax, SYS_READ
  mov rdi, [signalfd]
  lea rsi, sig_info
  mov rdx, signalfd_siginfo_size
  syscall

  cmp rax, signalfd_siginfo_size
  jne .err_read_signal

  ; check which signal it is
  mov edi, [sig_info + signalfd_siginfo.ssi_signo]
  cmp dword edi, SIGINT
  je .handle_sigint

  ; cmp [sig_info + signalfd_siginfo.ssi_signo], SIGQUIT
  ; je .handle_sigquit

  jmp .handle_signals_done

.handle_sigint:

  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, shutdown_msg
  mov rdx, shutdown_msg_len
  syscall

  jmp .end_runtime_loop

;.handle_sigquit:

.handle_signals_done:

  cmp esi, [listen_sock]
  jne .accept_connection_done         ; if its the listen socket, new connections need to be accepted


.accept_connection:

  ; INFO:
  ;  int accept(int sockfd, struct sockaddr *_Nullable restrict addr, socklen_t *_Nullable restrict addrlen);
  ; int accept4(int sockfd, struct sockaddr *_Nullable restrict addr, socklen_t *_Nullable restrict addrlen, int flags);
  mov rax, SYS_ACCEPT
  mov rdi, [listen_sock]
  lea rsi, addr_ptr
  lea rdx, addr_len
  syscall

  cmp rax, 0
  mov rsi, fail_accept_errstr
  mov rdx, fail_accept_errstr_len
  jl _handle_error      ; if (return < 0 ) { _handle_error(-0x1) }

  add byte [amnt_conns], 1


  ; check if the maximum amount of connections is reached already, and if so reject, maybe with a message
  cmp byte [amnt_conns], MAX_CONNS
  jle .add_socket_to_epoll


.reject_connection:

  mov rdi, rax  ; conn_sock
  push rdi

  mov rax, SYS_WRITE
  mov rsi, rejectstr
  mov rdx, rejectstr_len
  syscall


  pop rdi
  call _socket_close

  jmp .runtime_loop


.add_socket_to_epoll:

  push rax
  push rdi

  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, accept_connstr
  mov rdx, accept_connstr_len
  syscall

  pop rdi
  pop rax


  ; 2. add the socket fd  to the epoll instance
  mov [conn_sock], rax

  ; INFO:
  ; int epoll_ctl(int epfd, int op, int fd, struct epoll_event *_Nullable event);
  ; ==> epoll_ctl(epollfd, EPOLL_CTL_ADD, listen_sock, &ev)

  ; reuse the epoll_event
  lea rdi, epoll_event
  mov rdx, [conn_sock]
  call _construct_epoll_event
  mov r10, rdi

  mov rdi, [epoll_fd]
  mov rsi, EPOLL_CTL_ADD

  mov rdx, [conn_sock]

  mov rax, SYS_EPOLL_CTL
  syscall

  cmp rax, 0
  je .runtime_loop

  mov rsi, epoll_ctl_errstr
  mov rdx, epoll_ctl_errstrlen
  jmp _handle_error

.accept_connection_done:

  mov rdi, [conn_sock]
  call _read_message

  test rsi, MSG_FLAG_EOF
  jne .close_connection

  ; TODO: implement
  ; test rsi, MSG_FLAG_TOO_LONG
  ; jne .msg_too_long

  test rsi, MSG_FLAG_DISCONNECT
  jne .close_connection

  mov rsi, rdi
  mov rdi, rax
  mov rdx, [conn_sock]
  mov r9, chat
  call _handle_echo_actions

  jmp .event_iterate


.close_connection:

  ; say goodbye
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, goodbyestr
  mov rdx, goodbyestr_len
  syscall

  ; remove from epoll
  mov rax, SYS_EPOLL_CTL
  mov rdi, [epoll_fd]
  mov rsi, EPOLL_CTL_DEL
  mov rdx, [listen_sock]
  mov r10, NULL
  syscall


  jmp .end_runtime_loop


.end_event_iterate:

  jmp .runtime_loop
.end_runtime_loop:

  ; Clean up the epoll instance
  mov rax, SYS_EPOLL_CTL
  mov rdi, [epoll_fd]
  mov rsi, EPOLL_CTL_DEL
  mov rdx, [listen_sock]
  mov r10, NULL
  syscall


  ; Close the connection socket
  ; INFO:
  ; int close(int fd);
  mov rax, SYS_CLOSE
  mov rdi, [epoll_fd]
  syscall

  ; Close the listening socket
  ; mov rax, SYS_CLOSE
  ; mov rdi, [listen_sock]
  ; syscall

  ret

.err_sigblock:
  mov rsi, sigblock_errstr
  mov rdx, sigblock_errstrlen
  jmp _handle_error

.err_signalfd:
  mov rsi, signalfd_errstr
  mov rdx, signalfd_errstrlen
  jmp _handle_error

.err_read_signal:
  mov rsi, read_signal_errstr
  mov rdx, read_signal_errstrlen
  jmp _handle_error

.err_epoll_create:
  mov rsi, epoll_create_errstr
  mov rdx, epoll_create_errstrlen
  jmp _handle_error

.err_epoll_ctl:
  mov rsi, epoll_ctl_errstr
  mov rdx, epoll_ctl_errstrlen
  jmp _handle_error


;; @brief constructs the `epoll_event` struct
;; @param rdi struct epoll_event * - pointer to the epoll_event
;; @param rdx                  int - socket file descriptor
;; @clobbers rcx, rdx
_construct_epoll_event:
  xor rcx, rcx

  push rdx
  ; Definition: uint32_t events;
  mov edx, EPOLLIN
  or edx, EPOLLET
  mov dword [rdi+rcx], edx  ; epoll_event.events = EPOLLIN | EPOLLET;
  add rcx, 4

  pop rdx
  mov [rdi+rcx], rdx        ; epoll_events.data.fd = listen_sock;

  ret

