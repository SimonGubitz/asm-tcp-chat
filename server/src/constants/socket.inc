; src/constants/socket.inc

; sys/socket.h
AF_INET   equ 0x02
AF_INET6  equ 0x0A

SOCK_STREAM     equ 0x1
SOCK_DGRAM      equ 0x2
SOCK_SEQPACKET  equ 0x5
SOCK_NONBLOCK   equ 0x800
SOCK_CLOEXEC    equ 0x80000

