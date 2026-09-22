; src/constants/protocol.inc

PROT_MAGIC_BYTES db 0x99, 0x61, 0x73, 0x6D, 0x63, 0x68, 0x61, 0x74, 0x0A

; CLIENT DEFINITIONS
PROT_MSG_AUTH       equ 0x01
PROT_MSG_CHAT       equ 0x02
PROT_MSG_COMMAND    equ 0x04
PROT_MSG_REQ_HIST   equ 0x08
; PROT_MSG_           equ 0x10
; PROT_MSG_           equ 0x20
; PROT_MSG_           equ 0x40
PROT_MSG_DISCONNECT equ 0x80


; SERVER DEFINITIONS
PROT_SRV_AUTH     equ 0x01
PROT_SRV_COMMAND  equ 0x02
PROT

