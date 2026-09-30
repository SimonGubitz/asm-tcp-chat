; src/runtime/echo/action.asm
%include "custom.inc"
%include "linux64.inc"
%include "protocol.inc"

; ../../protocol/protocol.asm
extern _is_protocol
extern _read_protocol_action

; ../../chat/write-message.asm
extern _write_message

; ../../types/hashmap.asm
extern _hashmap_get

; ../../error.asm
extern _handle_error

section .data
  handle_text_str db "Handling text, `opt-out`.", 0xA, 0x0
  handle_text_str_len equ $ - handle_text_str

  unknown_errstr db "Unknown or unsupported action for the echo runtime declared in the `action` field of the protocol header.", 0x0
  unknown_errstr_len equ $ - unknown_errstr

section .text
  global _handle_echo_actions

;; @brief reads the action and responds appropriately
;; @param rdi void * - pointer to the frame buffer
;; @param rsi size_t - size of the frame buffer
;; @param rdx    int - counterpart sockfd
;; @param r9     int - pointer to the chat struct
_handle_echo_actions:

  push rsi
  push rdi

  ; rdi holds the pointer already
  call _is_protocol
  cmp rax, TRUE
  je .handle_protocol

  pop rdi
  pop rsi

.handle_text:

  ; rdi is set -> is it??
  ; rsi is set
  ; rdx is set
  mov r9, rdx           ; the socket stored in the hashmap
  call _write_message

  jmp .echo_done

.handle_protocol:
  call _read_protocol_action

  cmp rax, PROT_MSG_AUTH
  je .handle_echo_auth

  cmp rax, PROT_MSG_CHAT
  je .handle_prot_chat

  mov rsi, unknown_errstr
  mov rdx, unknown_errstr_len
  jmp _handle_error


.handle_echo_auth:
  ; TODO:
  ; read out the username contained in the `message` field
  ; save it in a hashmap with the userid or socket fd

  jmp .echo_done


.handle_prot_chat:


  call _write_message

  jmp .echo_done


.handle_echo_other:


.echo_done:

  ret

