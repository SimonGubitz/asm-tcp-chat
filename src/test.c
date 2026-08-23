#include <stdio.h>
#include <netinet/in.h>
#include <linux/types.h>

int main() {

	struct sockaddr_in6 sock_in6;

	printf("struct sockaddr_in6 { /* %2.ld byte */\n", sizeof(sock_in6));
	printf("  unsigned short int  sin6_family;    /* %2.ld byte */\n", sizeof(sock_in6.sin6_family));
	printf("  __be16              sin6_port;      /* %2.ld byte */\n", sizeof(sock_in6.sin6_port));
	printf("  __be32              sin6_flowinfo;  /* %2.ld byte */\n", sizeof(sock_in6.sin6_flowinfo));
	printf("  struct in6_addr     sin6_addr;      /* %2.ld byte */\n", sizeof(sock_in6.sin6_addr));
	printf("  __u32               sin6_scope_id;  /* %2.ld byte */\n", sizeof(sock_in6.sin6_scope_id));
	printf("}\n\n");

	return 0;
}
