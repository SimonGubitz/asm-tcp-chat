; src/types/hash-map.asm
extern _malloc

struc hashmap
  .amount     resd 1
  .capacity   resd 1
  .elem_size  resd 1
  .arr_ptr    resq 1
endstruc


section .text
  global _create_hashmap
  global _hashmap_add
  global _hashmap_get
  global _hashmap_set
  global _hashmap_has

;; @brief creates an empty hashmap in memory
;; @param rdi ssize_t - amount of elements
;; @param rsi ssize_t - size per element
;; @clobbers rdx
;; @returns rax void * - pointer to the hashmap structure
_create_hashmap:

  ; reserve the space for the reqested elements * size of each element
  imul rdi, rsi
  mov rax, rdi
  call _malloc
  mov rdx, rax

  sub rdi, 0xC
  mov dword [rax + hashmap.amount], 0x0
  mov dword [rax + hashmap.capacity], rdi  ; capacity -> same when created
  mov dword [rax + hashmap.elem_size], rsi  ; size per element
  mov qword [rax + hashmap.], rdx

  ret


;; @brief adds an element with a key
;; @param rdi void* - pointer to the hashmap
;; @param rsi   int - key
;; @param rdx   any - value
_hashmap_add:

  ret


;; @brief get the element by the key
;; @param rdi void* - pointer to the hashmap
;; @param rsi   int - key
;; @returns rax - value
_hashmap_get:


  ret


;; @brief checks whether a value is present for a given key
_hashmap_has:

  ret
