; src/error.asm
%include "linux64.inc"

section .data
  gen_errstr db "There has been an error. ", 0x0
  gen_errstrlen equ $ - gen_errstr


section .text
  global _handle_error
  global _exit_failure
  global _exit_success

;; @brief prints the error message and exits the program
;; @param rsi string - error message string
;; @param rdx    int - length of the error string | -1 for no custom message
_handle_error:

  push rdx
  push rsi

  mov rax, SYS_WRITE
  mov rdi, STDERR
  mov rsi, gen_errstr
  mov rdx, gen_errstrlen
  syscall ; stdout: "There has been an Error."


  pop rsi
  pop rdx

  cmp rdx, -0x1     ; if no custom message is provided
  je _exit_failure

  mov rax, SYS_WRITE
  mov rdi, STDERR
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
