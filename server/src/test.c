#include <arpa/inet.h>
#include <linux/types.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#include <sys/epoll.h>

// asm functions
extern int _create_socket();
extern int _socket_bind(int sockfd, struct sockaddr_in6 *sockaddr, int port);
extern int _socket_listen(int sockfd);
extern int _socket_close(int sockfd);
extern void _fill_sockaddr_in6(struct sockaddr_in6 *sockaddr, int port);
extern void _construct_epoll_event(struct epoll_event* ev);

void print_constants() {
  printf("AF_INET: %d\n", AF_INET);
  printf("AF_INET6: %d\n\n", AF_INET6);
  printf("SOCK_STREAM: %d\n", SOCK_STREAM);
  printf("SOCK_DGRAM: %d\n", SOCK_DGRAM);
}

void print_sockaddr_in6_sizes() {
  struct sockaddr_in6 sock_in6;

  printf("struct sockaddr_in6 { /* %2.ld byte */\n", sizeof(sock_in6));
  printf("  unsigned short int  sin6_family;    /* %2.ld byte */\n",
         sizeof(sock_in6.sin6_family));
  printf("  __be16              sin6_port;      /* %2.ld byte */\n",
         sizeof(sock_in6.sin6_port));
  printf("  __be32              sin6_flowinfo;  /* %2.ld byte */\n",
         sizeof(sock_in6.sin6_flowinfo));
  printf("  struct in6_addr     sin6_addr;      /* %2.ld byte */\n",
         sizeof(sock_in6.sin6_addr));
  printf("  __u32               sin6_scope_id;  /* %2.ld byte */\n",
         sizeof(sock_in6.sin6_scope_id));
  printf("}\n\n");
}

int test_socket_create() {

  int sockfd = _create_socket();
  if (sockfd < 0) {
    printf("failed to create a socket: %d\n", sockfd);
    printf("Error description: %s\n", strerror(sockfd * -1));
    exit(1);
  }

  return sockfd;
}

void test_socket_bind(int sockfd) {

  struct sockaddr_in6 sock_in6;

  int bind_err = _socket_bind(sockfd, &sock_in6, 1234);
  if (bind_err != 0) {
    printf("encountered error: %d\n", bind_err * -1);
    return;
  }

  printf("family: %d\n", sock_in6.sin6_family);
  printf("port: %d\n", sock_in6.sin6_port);
  printf("flowinfo: %d\n", sock_in6.sin6_flowinfo);

  char buf[28];
  inet_ntop(AF_INET6, &sock_in6.sin6_addr, buf, sizeof(buf));
  printf("addr: %s\n", buf);
  printf("scope id: %d\n", sock_in6.sin6_scope_id);
}

void test_socket_listen(int sockfd) {
  int errno = _socket_listen(sockfd);
  if (errno != 0) {
    printf("failed to set socket into listening state: %d\n", errno);
    printf("Error description: %s\n", strerror(errno * -1));
    exit(1);
  }

  int val;
  socklen_t len = sizeof(val);
  if (getsockopt(sockfd, SOL_SOCKET, SO_ACCEPTCONN, &val, &len) == -1)
    printf("fd %d is not a socket\n", sockfd);
  else if (val)
    printf("fd %d is a listening socket\n", sockfd);
  else
    printf("fd %d is a non-listening socket\n", sockfd);
}

void test_socket_close(int sockfd) {
  int errno = _socket_close(sockfd);
  if (errno != 0) {
    printf("failed to close socket: %d\n", errno);
    printf("Error description: %s\n", strerror(errno * -1));
    exit(1);
  }
}

void test_fill_sockaddr_in6() {

  // ./asm-generic/errno.h:81:#define	EAFNOSUPPORT	97	/* Address family not supported by protocol */
  int sockfd = socket(AF_INET6, SOCK_STREAM, 0);
  if (sockfd < 0) {
    printf("error while creating socket\n");
    return;
  }
  struct sockaddr_in6 sock_in6;
  printf("address of the socket: %p\n", &sock_in6);

  _fill_sockaddr_in6(&sock_in6, 1234);

  printf("family: %d\n", sock_in6.sin6_family);
  printf("port: %d\n", sock_in6.sin6_port);
  printf("flowinfo: %d\n", sock_in6.sin6_flowinfo);

  char buf[28];
  inet_ntop(AF_INET6, &sock_in6.sin6_addr, buf, sizeof(buf));
  printf("addr: %s\n", buf);
  printf("scope id: %d\n", sock_in6.sin6_scope_id);
}

void fuzzy_test_chat() {
  // TODO: implement this
}

void print_epoll_constants() {

  printf("op:\n");
  printf("EPOLL_CTL_ADD equ 0x%0*X\n",    2, EPOLL_CTL_ADD);
  printf("EPOLL_CTL_MOD equ 0x%0*X\n",    2, EPOLL_CTL_MOD);
  printf("EPOLL_CTL_DEL equ 0x%0*X\n\n",  2, EPOLL_CTL_DEL);

  printf("events:\n");
  printf("EPOLLIN equ 0x%0*X\n",    2, EPOLLIN);
  printf("EPOLLOUT equ 0x%0*X\n",   2, EPOLLOUT);
  printf("EPOLLRDHUP equ 0x%0*X\n", 2, EPOLLRDHUP);
  printf("EPOLLPRI equ 0x%0*X\n",   2, EPOLLPRI);
  printf("EPOLLERR equ 0x%0*X\n",   2, EPOLLERR);
  printf("EPOLLHUP equ 0x%0*X\n\n", 2, EPOLLHUP);

  printf("input flags:\n");
  printf("EPOLLET equ 0x%0*X\n",        2, EPOLLET);
  printf("EPOLLONESHOT equ 0x%0*X\n",   2, EPOLLONESHOT);
  printf("EPOLLWAKEUP equ 0x%0*X\n",    2, EPOLLWAKEUP);
  printf("EPOLLEXCLUSIVE equ 0x%0*X\n", 2, EPOLLEXCLUSIVE);

  /*
    typedef union epoll_data
    {
      void *ptr;
      int fd;
      uint32_t u32;
      uint64_t u64;
    } epoll_data_t;

    struct epoll_event
    {
      uint32_t events;    / Epoll events /
      epoll_data_t data;  / User data variable /
    } __EPOLL_PACKED;
  */
  struct epoll_event ev; 
  printf("\nsizeof epoll_event: %2ld\n", sizeof(ev));
}

void test_construct_epoll_event() {

  struct epoll_event ev;
  _construct_epoll_event(&ev);

  printf("events: %d\n", ev.events);
  printf("data (ptr): %p\n", ev.data.ptr);
  printf("data  (fd): %d\n", ev.data.fd);
  printf("data (u32): %d\n", ev.data.u32);
  printf("data (u64): %ld\n", ev.data.u64);
}

int main() {

  int sockfd = test_socket_create();
  test_socket_bind(sockfd);
  // test_fill_sockaddr_in6();
  // test_construct_epoll_event();

  return 0;
}

