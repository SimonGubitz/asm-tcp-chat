; src/message/read.asm
%include "linux64.inc"
%include "message.inc"

extern _handle_error


%define buflen 1024
section .bss
  buf resb buflen

section .data
  teststr     db "Client said: ", 0xA, 0x0
  teststr_len equ $ - teststr

section .text
  global _read_message


;; @brief reads, encrypts and formats the message
;; @param rdi int - connected socket
;; @returns rax void * - pointer to the buffer
;; @returns rdi size_t - size of the buffer
;; @returns rsi   flag - whether it is a EOF (0) or normal message (1)
_read_message:

  ; INFO: ssize_t read(int fd, void buf[count], size_t count);
  mov rax, SYS_READ
  lea rsi, buf
  mov rdx, buflen
  syscall

  xor rsi, rsi    ; set return to 0

  ; check if its an EOF
  cmp rax, 0
  je .handle_eof

  cmp rax, buflen
  jg .handle_too_long

  jmp .handle_message     ; base case

.handle_eof:
  or rsi, MSG_FLAG_EOF

.handle_too_long:
  or rsi, MSG_FLAG_TOO_LONG


.handle_message:

  lea rax, buf
  mov rdi, buflen
  ; rsi is set already

  ret
