; src/runtime/echo.asm
%include "linux64.inc"

extern _socket_accept


section .text
  global _echo_runtime


;; @brief handle new connections, and echo each response back
;; @param rdi int - sockfd
_echo_runtime:

  ; create an epoll instance
  ; listen to:
  ; - incoming connections
  ; - messages sent by already connected clients


  ; int epoll_create(int size);
  ; int epoll_create1(int flags);
  mov rax, SYS_EPOLL_CREATE
  xor rdi, rdi
  syscall
  ; rax holds the epoll_fd

  sub rsp, 4 ; create space for the epoll_fd on the stack
  push rax
  mov rdi, rax  ; copy epfd into rdi

  ; int epoll_ctl(int epfd, int op, int fd, struct epoll_event *_Nullable event);
  mov rax, SYS_EPOLL_CTL
  mov rdx, EPOLL_CTL_ADD
  ; TODO: mov rsi
  mov r10, EPOLLIN
  syscall


  ; while loop:
.loop:
  xor rdi, rdi

  ; int   epoll_wait(int epfd, struct epoll_event events[n], int n, int timeout);
  ; int  epoll_pwait(int epfd, struct epoll_event events[n], int n, int timeout, const sigset_t *_Nullable sigmask);
  ; int epoll_pwait2(int epfd, struct epoll_event events[n], int n, const struct timespec *_Nullable timeout, const sigset_t *_Nullable sigmask);
  mov rax, SYS_EPOLL_WAIT
  or rdi, EPOLLIN
  syscall
  ; rax holds the nfds

  ; accept

.end_loop:

  ; TODO: close the epoll_fd and the connected socket
  mov rax, SYS_CLOSE
  pop rdi
  syscall


  ret

