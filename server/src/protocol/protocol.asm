; src/protocol/protocol.asm
%include "custom.inc"
%include "linux64.inc"
%include "protocol.inc"

section .bss
  version_string resb 16  ; "xx.xxx.xxxx"

section .data
  tmp_version_string db "0.0.1", 0x0


section .text
  global _is_protocol
  global _get_protocol_version
  global _read_protocol_action

;; @brief checks if the message is of the current protocol
;; @param rdi char* - pointer to the frame buffer
;; @returns rax bool - whether the first bytes indicate the protocol
_is_protocol:

  mov rsi, rdi
  mov rdi, PROT_MAGIC_BYTES
  mov rcx, 0x8                ; check the first 8 bytes

  repe cmpsb
  jne .set_protocol_false
  jmp .set_protocol_true

.set_protocol_false:
  mov rax, FALSE
  jmp .return

.set_protocol_true:
  mov rax, TRUE

.return:
  ret


;; @brief returns the protocol version
;;
;; @return rax char* - pointer to a null terminated string
_get_protocol_version:

  mov rax, tmp_version_string
  mov [version_string], rax
  lea rax, [version_string]

  ret


;; @brief helper function to read the action
;; @param rdi void * - pointer to the start of the entire frame
;; @returns rax - the message type
MESSAGE_TYPE_OFFSET equ 0x0D
_read_protocol_action:

  xor rax, rax
  mov al, byte [rdi + MESSAGE_TYPE_OFFSET]

  ret

