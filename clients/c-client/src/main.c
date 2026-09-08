#include <stdio.h>
#include <sys/socket.h>
#include <linux/in6.h>


int main() {
  printf("hello world\n");

  // 1. create a socket
  int sockfd = socket(AF_INET6, SOCK_STREAM, 0);
  if (sockfd < 0) {
    perror("failed to create socket.\n");
  }

  // 2. connect
  struct sockaddr_in6 addr;
  if (connect(sockfd, (const struct sockaddr *) &addr, sizeof(addr)) == -1) {
    perror("failed to connect\n");
  }

  for (;;) {


  }

  return 0;
}
