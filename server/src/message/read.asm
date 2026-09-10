; src/message/read.asm
%include "linux64.inc"

extern _handle_error


section .bss
  buf resb 1024

section .data
  buflen dw 1024

  teststr     db "Client said: ", 0xA, 0x0
  teststr_len equ $ - teststr

section .text
  global _read_message


;; @brief reads, encrypts and formats the message
;; @param rdi int - connected socket
;; @returns rax
_read_message:

  ; INFO: ssize_t read(int fd, void buf[count], size_t count);
  mov rax, SYS_READ
  lea rsi, buf
  mov rdx, buflen
  syscall

  push rax; actual length of the message

  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, teststr
  mov rdx, teststr_len
  syscall


  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, buf
  pop rdx
  syscall

  ret
