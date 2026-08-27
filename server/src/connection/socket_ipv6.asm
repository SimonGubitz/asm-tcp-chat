; src/connection/socket.asm
%include "linux64.inc"

MAX_BACKLOG equ 0x02
IPv6_ADDRLEN equ 0x1C

section .text
	global _fill_sockaddr_in6 ; for C testing access
  global _create_socket
  global _socket_connect
  global _socket_bind
  global _socket_listen
  global _socket_accept

;; @brief creates a unix/local socket
;; @clobbers rdi, rsi, rdx
;; @returns rax int - sockfd
_create_socket:
  ; https://man7.org/linux/man-pages/man7/unix.7.html

  ; call the socket function
  ; socket(AF_INET6, SOCK_STREAM, 0);
  mov rax, SYS_SOCKET
  mov rdi, AF_INET6
  mov rsi, SOCK_STREAM
  mov rdx, 0x0
  syscall

  ret


;; @brief wraps the bind syscall
;; @param rdi int - sockfd
;; @param rsi   * - addr
;; @param rdx int - port
;; @clobbers rcx, r9, r10
;; @returns rax int - negative errno
_socket_bind:
  xor rcx, rcx

  push rsi
  push rdi

  mov rdi, rsi
  mov rsi, rdx
  call _fill_sockaddr_in6

  ; int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
  mov rax, SYS_BIND
  pop rdi ; sockfd
  pop rsi ; sockaddr
  lea rsi, [rsi+0]
  mov rdx, IPv6_ADDRLEN
  syscall

  ret



;; @brief mark the socket as passive / as a listening socket
;; @param rdi sockfd
;; @return
_socket_listen:
  mov rax, SYS_LISTEN
  ; rdi is supplied
  mov rsi, MAX_BACKLOG
  syscall

  ret



;; @brief accept incoming connections
;; @returns rax int - new socket file descriptor
_socket_accept:
  ret



;; @brief closes the socket from the kernel
;; @param rdi int - sockfd
_socket_close:
  
  mov rdi, rax

  ret


;; @brief fills the sockaddr_in6 struct with
;; @param rdi   * - socket address
;; @param rsi int - port
_fill_sockaddr_in6:
	xor rcx, rcx

  ; source: /usr/include/linux/in6.h
  ; struct sockaddr_in6 {
  ;   unsigned short int  sin6_family;    /*  2 byte */    /* AF_INET6 */
  ;   __be16              sin6_port;      /*  2 byte */    /* Transport layer port # */
  ;   __be32              sin6_flowinfo;  /*  4 byte */    /* IPv6 flow information */
  ;   struct in6_addr     sin6_addr;      /* 16 byte */    /* IPv6 address */
  ;   __u32               sin6_scope_id;  /*  4 byte */    /* scope id (new in RFC2553) */
  ; };

  ; source: /usr/include/linux/in6.h
  ; struct in6_addr {
  ;   __u8    u6_addr8[16];
  ; };

  lea r10, [rdi+rcx]
  mov word [r10], AF_INET6    ; sin6_family
  add rcx, 0x2

  lea r10, [rdi+rcx]
  mov word [r10], si          ; sin6_port
  add rcx, 0x2

  lea r10, [rdi+rcx]
  mov dword [r10], 0x0        ; sin6_flowinfo -> default 0
  add rcx, 0x4

  push rcx

  ; for (int i = 0; i < 16; i++) {
  ;   u6_addr8[i] = 0;
  ; }
  mov r9, rcx  ; r9 = rcx
  mov rcx, 0x10
.fill_addr:
  test rcx, rcx             ; if ( rcx == 0 ) { break; }
  jz .done_fill_addr

  lea r10, [rdi+r9]
  mov word [r10], 0x0      ; sin6_addr.u6_addr[rcx] = 0
  dec rcx                   ; rcx--    <- move the loop along
  inc r9                    ; r9++    <- move the memory addr along

  jmp .fill_addr
.done_fill_addr:

  pop rcx
  add rcx, 0x10

  lea r10, [rdi+rcx]
  mov dword [r10], 0x0    ; sin6_scope_id

	ret

