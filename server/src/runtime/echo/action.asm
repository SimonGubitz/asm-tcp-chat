; src/runtime/echo/action.asm


; ../../message/write.asm
extern _write_message

section .text
  global _handle_echo_actions

;; @brief reads the action and responds appropriately
;; @param rax void * - pointer to the buffer
;; @param rdi size_t - size of the buffer
;; @param rsi   flag - MSG_FLAG_.*
;; @param rdx    int - connected sockfd
_handle_echo_actions:

  ret


;; @brief handles the `PROT_MSG_AUTH` message type
_handle_echo:

  ; TODO:
  ; read out the username contained in the `message` field
  ; save it in a hashmap with the userid or socket fd

  ret

