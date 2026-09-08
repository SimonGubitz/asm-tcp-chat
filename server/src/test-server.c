#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <linux/in6.h>
#include <sys/epoll.h>
#include <unistd.h>

#define MAX_BACKLOG 2
#define MAX_EVENTS 1

int echo_runtime(int listen_sock);

int main() {

  int sockfd = socket(AF_INET6, SOCK_STREAM, 0);
  if (sockfd < 0) {
    printf("failed to create socket: %s\n", strerror(sockfd));
    return 1;
  }

  printf("%d is 1234 in network order.\n", htons(1234));

  struct sockaddr_in6 addr = {
    .sin6_family = AF_INET6,
    .sin6_port = ntohs(1234),
    .sin6_flowinfo = 0,
    .sin6_addr = ntohl(0),
    .sin6_scope_id = 0,
  };

  int errno = bind(sockfd, (const struct sockaddr*) &addr, sizeof(addr));
  if (errno == -1) {
    printf("failed to bind address. Error: %s\n", strerror(errno));
    return 1;
  }

  if (listen(sockfd, MAX_BACKLOG) == -1) {
    printf("failed to mark socket listening.\n");
    return 1;
  }

  if (echo_runtime(sockfd) == 1) {
    return 1;
  }
}

int echo_runtime(int listen_sock) {

  int epfd = epoll_create1(0);
  if (epfd < 0) {
    printf("failed to create epoll instance. Err: %s\n", strerror(epfd));
    return 1;
  }

  // configure epoll
  struct epoll_event ev;
  ev.events = EPOLLIN | EPOLLET;
  ev.data.fd = listen_sock;
  if (epoll_ctl(epfd, EPOLL_CTL_ADD, listen_sock, &ev)) {
    printf("failed to configure epoll instance.\n");
    return 1;
  }

  while (1) {

    struct epoll_event rev[MAX_EVENTS];
    int n_events = epoll_wait(epfd, rev, MAX_EVENTS, 0x493E0); // 5min timeout

    printf("hello from the loop. Got %d events.\n", n_events);
  }

  return 0;
}
