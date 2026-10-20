; src/constants/linux64.inc

LF equ 0x0A

SYS_READ            equ 0x000
SYS_WRITE           equ 0x001
SYS_WRITEV          equ 0x014
SYS_EXIT            equ 0x03C
SYS_SOCKET          equ 0x029
SYS_CONNECT         equ 0x02A
SYS_BIND            equ 0x031
SYS_LISTEN          equ 0x032
SYS_CLOSE           equ 0x003
SYS_ACCEPT          equ 0x02B
SYS_MMAP            equ 0x009
SYS_MUNMAP          equ 0x00B
SYS_BRK             equ 0x00C
SYS_SIGNALFD        equ 0x11A
SYS_SIGNALFD4       equ 0x121
SYS_RT_SIGPROCMASK  equ 0x00E


SYS_EPOLL_CREATE  equ 0x0D5
SYS_EPOLL_CREATE1 equ 0x123
SYS_EPOLL_WAIT    equ 0x0E8
SYS_EPOLL_CTL     equ 0x0E9

STDOUT equ 0x1
STDERR equ 0x2

SIGNAL_MASK_SIZE equ 0x08
