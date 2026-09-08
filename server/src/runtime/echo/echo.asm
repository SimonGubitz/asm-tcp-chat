; src/runtime/echo.asm
%include "linux64.inc"
%include "epoll.inc"
%include "custom.inc"

%define MAX_CONNS   1
%define MAX_EVENTS  1

; ../connection/socket_ipv6.asm
extern _socket_accept

; ../error.asm
extern _handle_error

section .bss
  amnt_conns  resb 1

  listen_sock resq 1
  conn_sock   resq 1
  epoll_fd    resq 1

  epoll_event   resb EVENT_SIZE
  epoll_revent  resb EVENT_SIZE ; INFO: only a one element array, since its an echo server

  conn_addr_ptr resb 8


section .data

  teststr                 db "this is a test", 0xA, 0x0
  teststr_len             equ $ - teststr

  rejectstr               db "The maximum amounts of connections has already been reached.", 0xA, 0x0
  rejectstr_len           equ $ - rejectstr

  epoll_create_errstr     db "Failed to create epoll instance.", 0xA, 0x0
  epoll_create_errstrlen  equ $ - epoll_create_errstr

  epoll_ctl_errstr        db "Failed to configure epoll instance.", 0xA, 0x0
  epoll_ctl_errstrlen     equ $ - epoll_ctl_errstr

section .text
  global _echo_runtime
  global _construct_epoll_event ; for C testing


;; @brief handle new connections, and echo each response back
;; @param rdi int - sockfd
;; @clobbers r9, r8, rcx
_echo_runtime:

  mov [amnt_conns], 0
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

  mul rcx, EVENT_SIZE
  mov eax, dword [epoll_revent+rdx]   ; get the event
  add rdx, 4
  mov esi, dword [epoll_revent+rdx]   ; INFO: +4 to get to the union | dword/eax to get the fd

  cmp esi, listen_sock        ; if its the listen socket, new connections need to be accepted
  jne .accept_connection_done

  ; INFO:
  ;  int accept(int sockfd, struct sockaddr *_Nullable restrict addr, socklen_t *_Nullable restrict addrlen);
  ; int accept4(int sockfd, struct sockaddr *_Nullable restrict addr, socklen_t *_Nullable restrict addrlen, int flags);

  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, "test"
  mov rdx, 4
  syscall

  mov rax, SYS_ACCEPT
  mov rdi, [listen_sock]

  lea rsi, conn_addr_ptr
  mov rdx, NULL
  syscall


  ; INFO: check if the maximum amount of connections is reached already, and if so reject, maybe with a message
  cmp byte [amnt_conns], MAX_CONNS
  jne .add_socket_to_epoll

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
  call _construct_epoll_event
  mov r10, rdi

  mov rdi, [epoll_fd]
  mov rsi, EPOLL_CTL_ADD

  mov rdx, [conn_sock]

  mov rax, SYS_EPOLL_CTL
  syscall


.accept_connection_done:

  ; test which event type it is
  test eax, EPOLLIN
  ; jnz .read_msg

  ; accept
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
;; @clobbers rcx, rdx
_construct_epoll_event:
  xor rcx, rcx

  ; Definition: uint32_t events;
  mov edx, EPOLLIN
  or edx, EPOLLET
  mov dword [rdi+rcx], edx  ; epoll_event.events = EPOLLIN | EPOLLET;
  add rcx, 4

  mov rdx, [listen_sock]
  mov [rdi+rcx], rdx        ; epoll_events.data.fd = listen_sock;

  ret

