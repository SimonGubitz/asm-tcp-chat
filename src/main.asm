; src/main.asm

; ./connection/socket.asm
extern _create_socket
extern _socket_connect
extern _socket_bind
extern _socket_listen
extern _socket_accept

SYS_WRITE equ 0x4
SYS_EXIT equ 0x1

STDOUT equ 0x1

section .bss
	socket_address resw 4 ; 16 bytes
	socket_address_len resw 1 ; 4 bytes

section .data
	errstr db "There has been an error.", 0xa
	errstrlen equ $ - errstr

	port dw 1234


section .text
	global _start

_start:
	; stack frame
	; push ebp
	; push mov ebp, esp ; <- error in this line


	; reserve space sizeof(sockaddr_un)
	; sub esp, 

	call _create_socket ; sockfd is in rax after
	cmp rax, -1
	je _handle_error

	mov rdi, rax ; rdi <- sockfd
	call _socket_connect
	cmp rax, 0
	je _handle_error


	call _socket_bind


	call _socket_listen


	call _socket_accept

	; prepare the params
	call _socket_listen
	cmp rax, 0
	je _handle_error

;; @brief prints the error message and exits the program
_handle_error:

	; switch jump table of error type

.case_EACCES:
.case_EAFNOSUPPORT:
.case_EINVAL:
.case_EMFILE:
.case_ENFILE:
.case_ENOBUFS:
.case_EPROTONOSUPPORT:
.case_default:

	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, errstr
	mov rdx, errstrlen
	syscall

	jmp _exit

;; @brief exits the program
_exit:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall

