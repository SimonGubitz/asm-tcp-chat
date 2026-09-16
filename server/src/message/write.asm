; src/message/write.asm
%include "custom.inc"     ; enable default abs
%include "linux64.inc"


section .bss
  ; INFO:
  ; struct iovec {
  ;   void   *iov_base;  /* Starting address */
  ;   size_t  iov_len;   /* Size of the memory pointed to by iov_base. */
  ; };
  ; sizeof(ssize_t) = 16
  iovec resb 32

section .data
  send_buf db "You said: ", 0x0
  send_buflen equ $ - send_buf

section .text
  global _write_message

;; @brief sends a message to one client
;; @param rax void * - pointer to the buffer
;; @param rdi size_t - size of the buffer
;; @param rsi   flag - MSG_FLAG_.*
;; @param rdx    int - connected sockfd
_write_message:

  ; construct the `iovec`
  lea r9, send_buf
  mov [iovec], r9
  mov [iovec+8], send_buflen

  mov [iovec+16], rax
  mov [iovec+24], rdi


  ; INFO:
  ; ssize_t writev(int fd, const struct iovec *iov, int iovcnt);
  mov rax, SYS_WRITEV
  mov rdi, rdx
  lea rsi, iovec
  mov rdx, 0x2        ; 2 buffers
  syscall

  mov rax, SYS_WRITE
  ; rdi still exists
  mov rsi, send_buf
  mov rdx, send_buflen
  syscall


  ret

