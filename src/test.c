#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <linux/types.h>


void print_sizes() {
  struct sockaddr_in6 sock_in6;

  printf("struct sockaddr_in6 { /* %2.ld byte */\n", sizeof(sock_in6));
  printf("  unsigned short int  sin6_family;    /* %2.ld byte */\n", sizeof(sock_in6.sin6_family));
  printf("  __be16              sin6_port;      /* %2.ld byte */\n", sizeof(sock_in6.sin6_port));
  printf("  __be32              sin6_flowinfo;  /* %2.ld byte */\n", sizeof(sock_in6.sin6_flowinfo));
  printf("  struct in6_addr     sin6_addr;      /* %2.ld byte */\n", sizeof(sock_in6.sin6_addr));
  printf("  __u32               sin6_scope_id;  /* %2.ld byte */\n", sizeof(sock_in6.sin6_scope_id));
  printf("}\n\n");
}

extern void _fill_sockaddr_in6(struct sockaddr_in6* sockaddr);

void debug_bind_syscall() {

  int sockfd = socket(AF_INET6, SOCK_STREAM, 0);
  if (sockfd < 0) {
    printf("error while creating socket\n");
    return;
  }

  struct sockaddr_in6 sock_in6;
  _fill_sockaddr_in6(&sock_in6);

  printf("family: %d\n", sock_in6.sin6_family);
  printf("port: %d\n", sock_in6.sin6_port);
  printf("flowinfo: %d\n", sock_in6.sin6_flowinfo);
  printf("addr: %d\n", ntohl(sock_in6.sin6_addr.u6_addr8));
  printf("scope id: %d\n", sock_in6.sin6_scope_id);

}


int main() {

  // print_sizes();
  debug_bind_syscall();

  return 0;
}
