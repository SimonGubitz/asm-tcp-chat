; src/runtime/echo.asm
%include "linux64.inc"
%include "epoll.inc"
%include "message.inc"
%include "custom.inc"

%define MAX_CONNS   1
%define MAX_EVENTS  1

; ../../message/read.asm
extern _read_message

; ../../message/write.asm
extern _write_message

; ../../connection/socket_ipv6.asm
extern _socket_accept

; ../../error.asm
extern _handle_error

section .bss
  amnt_conns    resb 1

  listen_sock   resq 1
  conn_sock     resq 1
  epoll_fd      resq 1

  epoll_event   resb EVENT_SIZE
  epoll_revent  resb EVENT_SIZE ; INFO: only a one element array, since its an echo server

  conn_addr     resb 16

  addr_ptr      resb 8
  addr_len      resb 4


section .data

  goodbyestr              db "Goodbye, closing connection.", 0xA, 0x0
  goodbyestr_len          equ $ - goodbyestr

  teststr                 db "received an input", 0xA, 0x0
  teststr_len             equ $ - teststr

  rejectstr               db "The maximum amounts of connections has already been reached.", 0xA, 0x0
  rejectstr_len           equ $ - rejectstr

  fail_accept_errstr      db "Failed to accept socket.", 0xA, 0x0
  fail_accept_errstr_len  equ $ - fail_accept_errstr

  epoll_create_errstr     db "Failed to create epoll instance.", 0xA, 0x0
  epoll_create_errstrlen  equ $ - epoll_create_errstr

  epoll_ctl_errstr        db "Failed to configure epoll instance.", 0xA, 0x0
  epoll_ctl_errstrlen     equ $ - epoll_ctl_errstr

section .text
  global _echo_runtime
  global _construct_epoll_event ; for C testing


;; @brief handle new connections, and echo each response back
;; @assumption sockfd is a valid socket, that has been bound to an address and is in LISTEN state
;; @param rdi int - sockfd
<<<<<<< HEAD
;; @clobbers rcx
=======
;; @clobbers r10, rcx
>>>>>>> 6eb563bfb24f3369edad2e4ac4cd0c4b787c1595
_echo_runtime:

  mov byte [amnt_conns], 0
  mov [listen_sock], rdi

  ; create an epoll instance
  ; listen to:
  ; - incoming connections
  ; - messages sent by already connected clients


  ; INFO:
  ; int epoll_create(int size);
  ; int epoll_create1(int flags);
  mov rax, SYS_EPOLL_CREATE1
  mov rdi, 0x0
  syscall
  cmp rax, 0
  jl .err_epoll_create

  mov [epoll_fd], rax

  ; INFO:
  ; int epoll_ctl(int epfd, int op, int fd, struct epoll_event *_Nullable event);
  ; ==> epoll_ctl(epollfd, EPOLL_CTL_ADD, listen_sock, &ev)

  ; TODO: construct a epoll_event
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


.runtime_loop:

  ; INFO:
  ; int   epoll_wait(int epfd, struct epoll_event events[n], int n, int timeout);
  ; int  epoll_pwait(int epfd, struct epoll_event events[n], int n, int timeout, const sigset_t *_Nullable sigmask);
  ; int epoll_pwait2(int epfd, struct epoll_event events[n], int n, const struct timespec *_Nullable timeout, const sigset_t *_Nullable sigmask);

  mov rdi, [epoll_fd]

  lea rsi, epoll_revent ; r(eturn)event
  mov rdx, MAX_EVENTS   ; max events
  mov r10, 0x493E0      ; 5min timeout
  ; mov r10, 0x36EE80   ; 60min timeout
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
  mov rsi, rejectstr
  mov rdx, rejectstr_len
  mov rax, SYS_WRITE
  syscall


  mov rax, SYS_CLOSE
  mov rdi, [conn_sock]
  syscall

  jmp .event_iterate


.add_socket_to_epoll:
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
  je .runtime_loop       ; INFO: jump to event_iterate

  mov rsi, epoll_ctl_errstr
  mov rdx, epoll_ctl_errstrlen
  jmp _handle_error

.accept_connection_done:

  ; TODO: test which event type it is
  ; test eax, EPOLLIN
  ; jnz .read_msg

  mov rdi, [conn_sock]
  call _read_message

  ; if its EOF
  test rsi, MSG_FLAG_EOF
  jne .close_connection

  test rsi, MSG_FLAG_DISCONNECT
  jne .close_connection

  mov rdx, [conn_sock]
  call _write_message
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

  ; INFO:
  ; int close(int fd);
  mov rax, SYS_CLOSE
  mov rdi, [epoll_fd]
  syscall

  mov rax, SYS_CLOSE
  mov rdi, [listen_sock]
  syscall

  ret

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

