; src/runtime/echo.asm

extern _socket_accept


section .text
  global _echo_runtime


;; @brief handle new connections, and echo each response back
;; @param rdi int - sockfd
_echo_runtime:

  ; TODO: create an epoll instance
  ; listen to:
  ; - incoming connections
  ; - messages sent by already connected clients

  ret

