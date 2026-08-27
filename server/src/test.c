#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netinet/in.h>
#include <linux/types.h>

// asm functions
extern int _create_socket();
extern int _socket_bind(int sockfd, struct sockaddr_in6* sockaddr, int port);
extern void _fill_sockaddr_in6(struct sockaddr_in6* sockaddr, int port);


void print_constants() {
	printf("AF_INET: %d\n", AF_INET);
	printf("AF_INET6: %d\n\n", AF_INET6);
	printf("SOCK_STREAM: %d\n", SOCK_STREAM);
	printf("SOCK_DGRAM: %d\n", SOCK_DGRAM);
}

void print_sockaddr_in6_sizes() {
  struct sockaddr_in6 sock_in6;

  printf("struct sockaddr_in6 { /* %2.ld byte */\n", sizeof(sock_in6));
  printf("  unsigned short int  sin6_family;    /* %2.ld byte */\n", sizeof(sock_in6.sin6_family));
  printf("  __be16              sin6_port;      /* %2.ld byte */\n", sizeof(sock_in6.sin6_port));
  printf("  __be32              sin6_flowinfo;  /* %2.ld byte */\n", sizeof(sock_in6.sin6_flowinfo));
  printf("  struct in6_addr     sin6_addr;      /* %2.ld byte */\n", sizeof(sock_in6.sin6_addr));
  printf("  __u32               sin6_scope_id;  /* %2.ld byte */\n", sizeof(sock_in6.sin6_scope_id));
  printf("}\n\n");
}

int test_socket_create() {
	
	int sockfd = _create_socket();
	if (sockfd < 0) {
		printf("failed to create a socket: %d\n", sockfd);
		printf("Error description: %s\n", strerror(sockfd*-1));
		exit(1);
	}

	return sockfd;
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

void test_socket_bind(int sockfd) {

  struct sockaddr_in6 sock_in6;

	int bind_err = _socket_bind(sockfd, &sock_in6, 1234);
	if (bind_err != 0) {
		printf("encountered error: %d\n", bind_err*-1);
		return;
	}

}

int main() {

	// print_constants();

  // print_sockaddr_in6_sizes();
  // test_fill_sockaddr_in6();
	// int sockfd = socket(AF_INET6, SOCK_STREAM, 0);
	// if (sockfd < 0) {
	// 	printf("failed to create a socket: %d\n", sockfd);
	// 	printf("Error description: %s\n", strerror(sockfd*-1));
	// 	exit(1);
	// }

	int sockfd = test_socket_create();
	test_socket_bind(sockfd);

  return 0;
}
