; src/main.asm
%include "linux64.inc"

; ./connection/socket.asm
extern _create_socket
extern _socket_connect
extern _socket_bind
extern _socket_listen
extern _socket_close

; ./runtime/echo.asm
extern _echo_runtime

section .bss
  socket_addr resb 16      ; 16 bytes

  errno_str resd 1
  errno_str_len resb 1

section .data
  gen_errstr db "There has been an error. ", 0x0
  gen_errstrlen equ $ - gen_errstr

  gen_errstr_suffix db "Error Code: ", 0x0
  gen_errstr_suffixlen equ $ - gen_errstr_suffix

  create_errstr db "Failed to create socket.", 0xA, 0x0
  create_errstrlen equ $ - create_errstr

  conn_errstr db "Failed to connect to socket.", 0xA, 0x0
  conn_errstrlen equ $ - conn_errstr

  bind_errstr db "Failed to bind to socket.", 0xA, 0x0
  bind_errstrlen equ $ - bind_errstr

  listen_errstr db "Failed to listen on socket.", 0xA
  listen_errstrlen equ $ - listen_errstr

  accept_errstr db "Failed to accept incoming connection.", 0xA, 0x0
  accept_errstrlen equ $ - accept_errstr

  runtime_errstr db "Unknown error during runtime.", 0xA, 0x0
  runtime_errstrlen equ $ - runtime_errstr

  ; port dw %env("PORT", 1234)


section .text
  global _start

_start:
  ; stack frame
  ; push ebp
  ; push mov ebp, esp ; <- error in this line

  ; reserve space: sizeof(sockaddr_un)
  ; sub esp, 

  call _create_socket  ; sockfd is in rax after
  cmp rax, 0          ; if sockfd == -1
  jl .err_create_socket

  mov rdi, rax            ; rdi <- sockfd
  mov rsi, socket_addr
  ; mov rdx, port
  mov rdx, 1234
  call _socket_bind
  test rax, rax
  jnz .err_socket_bind

  call _socket_listen
  test rax, rax
  jnz .err_socket_listen

  ; TODO: enter the runtime here
  push rdi        ; save the sockfd
  call _echo_runtime

  pop rdi
  call _socket_close

  jmp _exit_success

.err_create_socket:
  mov rsi, create_errstr
  mov rdx, create_errstrlen
  jmp _handle_error

.err_socket_connect:
  mov rsi, conn_errstr
  mov rdx, conn_errstrlen
  jmp _handle_error

.err_socket_bind:
  mov rsi, bind_errstr
  mov rdx, bind_errstrlen
  jmp _handle_error

.err_socket_listen:
  mov rsi, listen_errstr
  mov rdx, listen_errstrlen
  jmp _handle_error

.err_socket_accept:
  mov rsi, accept_errstr
  mov rdx, accept_errstrlen
  jmp _handle_error

.err_runtime:
  mov rsi, runtime_errstr
  mov rdx, runtime_errstrlen
  jmp _handle_error


  ret

;; @brief prints the error message and exits the program
;; @param rsi string  - error message string
_handle_error:

  push rdx
  push rsi

  mov rax, SYS_WRITE
  mov rdi, STDERR
  mov rsi, gen_errstr
  mov rdx, gen_errstrlen
  syscall ; stdout: "There has been an Error."

  mov rax, SYS_WRITE
  mov rdi, STDERR
  pop rsi
  pop rdx
  syscall ; std: "Failed to ..."

  jmp _exit_failure

;; @brief exits the program with error code 0
_exit_success:
  xor rdi, rdi
  jmp _exit

;; @brief exits the program with error code 1
_exit_failure:
  mov rdi, 1
  jmp _exit

;; @brief exits the program with the supplied error code
;; @param rdi error code
_exit:
  mov rax, SYS_EXIT
  syscall

