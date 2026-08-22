; connection/socket.asm
extern _create_socket

SYS_WRITE equ 0x0
SYS_EXIT equ 0x0

STDOUT equ 0x1

section .bss

section .data
	errstr db "There has been an error.", 0xa
	errstrlen equ $ - errstr


section .text
	global _start

_start:
	; stack frame
	push ebp
	push mov ebp, esp


	; reserve space sizeof(sockaddr_un)
	; sub esp, 

	call _create_socket ; sockfd is in rax after


	mov rdi, rax ; rdi <- sockfd
	call _socket_connect

	; prepare the params
	call _socket_listen
	cmp rax, 0
	je _handle_error

_handle_error:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, errstr
	mov rdx, errstrlen
	syscall
	jmp _exit

;; @brief
;; @param
_exit:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall

