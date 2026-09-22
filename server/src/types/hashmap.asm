; src/types/hash-map.asm
extern _malloc

section .bss


section .data


section .text
  global _create_hashmap
  global _add_hashmap
  global _get_hashmap
  global _set_hashmap
  global _has_hashmap

;; @brief reserves space for the hashmap
;; @param rdi ssize_t - amount of elements
;; @param rsi ssize_t - size per element
;; @returns rax void * - pointer to the hashmap structure
_create_hashmap:

  ; reserve the requested space + 12 bytes
  add rdi, 0xC
  call _malloc

  ; TODO: potentially initilize the memory with `memcpy` and zero everything, so that the `_has_hashmap` can compare

  sub rdi, 0xC
  mov dword [rax], rdi    ; total size
  mov dword [rax+4], rdi  ; capacity -> same when created
  mov dword [rax+8], rsi  ; size per element

  ret


;; @brief adds an element with a key
;; @param rdi void* - pointer to the hashmap
;; @param rsi   int - key
;; @param rdx   any - value
_add_hashmap:

  ret


;; @brief get the element by the key
;; @param rdi void* - pointer to the hashmap
;; @param rsi   int - key
;; @returns rax - value
_get_hashmap:


  ret


;; @brief
