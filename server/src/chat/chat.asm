; src/chat/chat.asm


struc chat
  chatid    resq 1
  max_users resw 1
  user_amnt resw 1
  user_map  resq 2
endstruc

section .bss
  


section .text
  global _create_chats


;; @brief reserves the memory
;;
;; @param rdi int - count of
;;
;; @returns rax void * - pointer to the start of the chats
;; @returns rdi    int - length of the 
_create_chats:

  ret


;; @brief destroys/frees the memory of a chat
;;
;; @param rdi int - the unique chat id
_destroy_chat_by_id:
  ret
