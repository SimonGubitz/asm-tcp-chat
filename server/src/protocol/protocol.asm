; src/protocol/protocol.asm
%include "custom.inc"
%include "protocol.inc"

section .bss
  version_string resb 16  ; "xx.xxx.xxxx"

section .data
  tmp_version_string db "0.0.1", 0x0


section .text
  global _is_protocol
  global _get_protocol_version

;; @brief checks if the message is of the current protocol
;; @param rdi char* - pointer to the byte array
;; @returns rax bool - whether the first bytes indicate the protocol
_is_protocol:

  mov rsi, rdi
  mov rdi, PROT_MAGIC_BYTES
  mov rcx, 0x8                ; check the first 8 bytes

  repe cmpsb
  jne .set_protocol_false
  jmp .set_protocol_true

.set_protocol_false:
  mov rax, 0x0
  jmp .return

.set_protocol_true:
  mov rax, 0x1

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


;; @brief
;; @param
;; @returns rax -
_read_:
  ret

