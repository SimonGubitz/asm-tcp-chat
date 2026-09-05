; src/runtime/echo.asm
%include "linux64.inc"
%define MAX_EVENTS 1

; ../connection/socket_ipv6.asm
extern _socket_accept

; ../error.asm
extern _handle_error

section .bss
  listen_sock resq 1
  epoll_fd    resq 1

  epoll_event resb 12


section .data
  epoll_create_errstr db "Failed to create epoll instance.", 0xA, 0x0
  epoll_create_errstrlen equ $ - epoll_create_errstr

  epoll_ctl_errstr db "Failed to configure epoll instance.", 0xA, 0x0
  epoll_ctl_errstrlen equ $ - epoll_ctl_errstr

section .text
  global _echo_runtime
  global _construct_epoll_event ; for C testing


;; @brief handle new connections, and echo each response back
;; @param rdi int - sockfd
;; @clobbers r9, r8, rcx
_echo_runtime:

  lea r9, listen_sock
  mov [r9], rdi

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

  lea r9, epoll_fd
  mov [r9], rax

  ; INFO:
  ; int epoll_ctl(int epfd, int op, int fd, struct epoll_event *_Nullable event);
  ; ==> epoll_ctl(epollfd, EPOLL_CTL_ADD, listen_sock, &ev)

  ; TODO: construct a epoll_event
  lea rdi, epoll_event
  call _construct_epoll_event
  mov r10, rdi

  mov rdi, [r9]
  mov rsi, EPOLL_CTL_ADD
  lea r9, listen_sock
  mov rdx, [r9]

  mov rax, SYS_EPOLL_CTL
  syscall

  cmp rax, 0
  jl .err_epoll_ctl


  ; while loop:
; .loop:

  ; INFO:
  ; int   epoll_wait(int epfd, struct epoll_event events[n], int n, int timeout);
  ; int  epoll_pwait(int epfd, struct epoll_event events[n], int n, int timeout, const sigset_t *_Nullable sigmask);
  ; int epoll_pwait2(int epfd, struct epoll_event events[n], int n, const struct timespec *_Nullable timeout, const sigset_t *_Nullable sigmask);


  lea r9, epoll_fd
  mov rdi, [r9]

  lea rsi, epoll_event          ; point to `epoll_event`

  mov rdx, MAX_EVENTS   ; max events
  mov r10, 0x493E0      ; 5min timeout
  ; mov r10, 0x36EE80   ; 60min timeout

  mov rax, SYS_EPOLL_WAIT
  syscall
  ; rax holds the nfds

  ; accept

; .end_loop:

  ; INFO:
  ; int close(int fd);
  mov rax, SYS_CLOSE
  lea r9, epoll_fd
  mov rdi, [r9]
  syscall

  mov rax, SYS_CLOSE
  lea r9, listen_sock
  mov rdi, [r9]
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
;; @clobbers rcx
_construct_epoll_event:
  xor rcx, rcx

  ; Definition: uint32_t events;
  mov dword [rdi+rcx], EPOLLIN    ; epoll_event.events = EPOLLIN;
  add rcx, 4

  lea r8, listen_sock
  mov r10, [r8]
  mov [rdi+rcx], r10        ; epoll_events.data.fd = listen_sock;

  ret

