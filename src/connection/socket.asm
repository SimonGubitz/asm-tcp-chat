; src/connection/socket.asm

SYS_SOCKET equ 0x167
SYS_BIND equ 0x169
SYS_CONNECT equ 0x16A
SYS_LISTEN equ 0x16B

; sys/socket.h
AF_UNIX equ 0x1

SOCK_STREAM equ 0x
SOCK_DGRAM equ 0x2
SOCK_SEQPACKET equ 0x5


; Relevant Errors (errno.h, errno-base.h)
EACCES equ 0x0D ; errno-base.h
EAFNOSUPPORT equ 0x61 ; errno.h
EINVAL equ 0x16 ; errno-base.h
EMFILE equ 0x17 ; errno-base.h
ENFILE equ 0x18 ; errno-base.h
ENOBUFS equ 0x69 ; errno.h
EPROTONOSUPPORT equ 0x5D; errno.h

section .text
	global _create_socket
	global _socket_connect
	global _socket_bind
	global _socket_listen
	global _socket_accept

;; @brief creates a unix/local socket
;; @clobbers rdi, rsi, rdx
;; @returns rax sockfd
_create_socket:
	; https://man7.org/linux/man-pages/man7/unix.7.html

	; call the socket function
	; socket(AF_UNIX, SOCK_STREAM, 0)
	mov rax, SYS_SOCKET
	mov rdi, AF_UNIX
	mov rsi, SOCK_STREAM
	mov rdx, 0
	syscall

	ret



;; @brief 
;; @param rdi sockfd
_socket_connect:
	; https://manpages.opensuse.org/Tumbleweed/man-pages/sa_family_t.3type.en.html#sa_family_t
	; struct sockaddr_un {
	; 	 sa_family_t sun_family;               /* AF_UNIX */
	; 	 char        sun_path[108];            /* Pathname */
	; };
	

	mov rax, SYS_CONNECT
	; rdi sockfd
	; mov rsi, addr
	mov rdx, 16
	syscall


	ret


;; @brief 
_socket_bind:

	ret


;; @brief mark the socket as passive / as a listening socket
;; @param rdi sockfd
;; @return
_socket_listen:
	mov rax, SYS_LISTEN
	ret



;; @brief accept incoming
_socket_accept:
	ret
