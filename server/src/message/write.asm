; src/message/write.asm
%include "custom.inc"     ; enable default abs
%include "linux64.inc"
%include "message.inc"

section .bss
  ; INFO:
  ; struct iovec {
  ;   void   *iov_base;  /* Starting address */
  ;   size_t  iov_len;   /* Size of the memory pointed to by iov_base. */
  ; };
  ; sizeof(ssize_t) = 16
  iovec resb 32

section .data
  send_buf          db "------> You said: ", 0x0
  send_buflen       equ $ - send_buf

  too_long_msg      db "The message you sent was too long. Please reduce the size.", 0xA, 0x0
  too_long_msg_len  equ $ - too_long_msg

section .text
  global _write_message

;; @brief sends a message to one client
;; @assumption
;; @param rax void * - pointer to the buffer
;; @param rdi size_t - size of the buffer
;; @param rsi   flag - MSG_FLAG_.*
;; @param rdx    int - connected sockfd
_write_message:

  test rsi, MSG_FLAG_DISCONNECT
  jne _warn_msg_too_long

_respond:
  ; construct the `iovec`
  lea r9, send_buf
  mov qword [iovec], r9
  mov qword [iovec+8], send_buflen

  mov qword [iovec+16], rax
  mov qword [iovec+24], rdi

  ; INFO:
  ; ssize_t writev(int fd, const struct iovec *iov, int iovcnt);
  mov rax, SYS_WRITEV
  mov rdi, rdx
  lea rsi, iovec
  mov rdx, 0x2        ; 2 buffers
  syscall

  jmp _return

_warn_msg_too_long:
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, too_long_msg
  mov rdx, too_long_msg_len
  syscall

_return:
  ret

