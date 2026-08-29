; src/constants/linux64.inc

SYS_WRITE   equ 0x01
SYS_EXIT    equ 0x3C
SYS_SOCKET  equ 0x29
SYS_BIND    equ 0x31
SYS_CONNECT equ 0x2A
SYS_LISTEN  equ 0x32
SYS_CLOSE   equ 0x03

STDOUT equ 0x1
STDERR equ 0x2

; sys/socket.h
AF_INET   equ 0x02
AF_INET6  equ 0x0A

SOCK_STREAM     equ 0x1
SOCK_DGRAM      equ 0x2
SOCK_SEQPACKET  equ 0x5

