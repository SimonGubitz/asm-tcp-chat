; src/chat/chat.asm
%include "custom.inc"

; ../error.asm
extern _handle_error

struc chat
  .chatid       resd 1
  .max_users    resw 1
  .user_amnt    resw 1
  .user_name_map_ptr    resq 1
  .user_socket_map_ptr  resq 1
endstruc

section .bss
  tmp_echo_chat resb chat_size

section .data
  chats_errstr db "This is a temporary solution, and more than 1 chat are not supported yet.", 0xA, 0x0
  chats_errstr_len equ $ - chats_errstr

section .text
  global _create_chats


;; @brief reserves memory and 
;; @param rdi int - amount of chats to be created
;; @returns rax void * - pointer to the start of the chats
;; @returns rdi    int - length of the chat struct
_create_chats:

  cmp rdi, 0x2
  jge .too_many_chats

  mov [tmp_echo_chat + chat.chatid], 0 ; TODO: unique identifier
  mov [tmp_echo_chat + chat.max_users], 1
  mov [tmp_echo_chat + chat.user_amnt], 0 ; default 0
  mov [tmp_echo_chat + chat.user_name_map_ptr], 0
  mov [tmp_echo_chat + chat.user_socket_map_ptr], 0

  jmp .create_chats_done

; TODO: remove this and replace it with actual malloc
.too_many_chats:

  mov rsi, chats_errstr
  mov rdx, chats_errstr_len
  call _handle_error

.create_chats_done:
  ret


;; @brief destroys/frees the memory of a chat
;;
;; @param rdi int - the unique chat id
_destroy_chat_by_id:
  ret
