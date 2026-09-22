; src/malloc/malloc.asm
%include "linux64.inc"

extern _handle_error

section .data
  brk_malloc_errstr db "There has been an error in malloc type brk.", 0xA, 0x0
  brk_malloc_errstr_len equ $ - brk_malloc_errstr

  mmap_malloc_errstr db "There has been an error in malloc type mmap.", 0xA, 0x0
  mmap_malloc_errstr_len equ $ - mmap_malloc_errstr

section .text
  global _malloc


;; @brief a custom malloc implementation
;; @param rdi ssize_t - size in bytes
;; @returns void * - pointer to the new space
_malloc:

  cmp rdi, 512
  jge .malloc_mmap
  jl .malloc_sbrk

.malloc_mmap:

  ; INFO:
  ; void *mmap(void addr[length], size_t length, int prot, int flags, int fd, off_t offset);

  syscall

  cmp rax, 0
  jge .success

.handle_error_mmap:
  mov rsi, mmap_malloc_errstr
  mov rdx, mmap_malloc_errstr_len
  call _handle_error

.malloc_sbrk:

  ; INFO:
  ; int brk(void *addr);
  mov rax, SYS_SBRK
  add rdi, $            ; add the current position
  syscall

  cmp rax, 0
  je .success

.handle_error_brk:
  mov rsi, brk_malloc_errstr
  mov rdx, brk_malloc_errstr_len
  call _handle_error


.success:
  ret
