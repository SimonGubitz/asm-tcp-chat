; src/chat/write-message.asm../protocol/protocol.asm
%include "custom.inc"     ; enable default abs
%include "linux64.inc"
%include "message.inc"

struc iovec
  .iov_base resq 1
  .iov_len  resq 1
endstruc

section .bss
  iovec_bufs resb 3 * iovec_size

section .data
  send_buf          db "------> You said: ", 0x0
  send_buflen       equ $ - send_buf

  newline           db LF
  newline_len       equ $ - newline

section .text
  global _write_message

;; @brief sends a message to one client
;; @assumption
;; @param rdi void * - pointer to the buffer
;; @param rsi size_t - size of the buffer
;; @param rdx   flag - MSG_FLAG_.*
;; @param r9     int - connected sockfd
_write_message:

  ; construct the `iovec`
  lea r10, send_buf
  mov qword [iovec_bufs + iovec.iov_base], r10
  mov qword [iovec_bufs + iovec.iov_len], send_buflen

  mov qword [iovec_bufs + iovec_size + iovec.iov_base], rdi
  mov qword [iovec_bufs + iovec_size + iovec.iov_len], rsi

  ; INFO:
  ; ssize_t writev(int fd, const struct iovec *iov, int iovcnt);
  mov rax, SYS_WRITEV
  mov rdi, r9
  lea rsi, iovec_bufs
  mov rdx, 0x2        ; 2 buffers
  syscall

  jmp _return

_return:

  ret

