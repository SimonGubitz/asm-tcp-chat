#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <linux/in6.h>
#include <unistd.h>

#define PROT_MSG_AUTH 0x1
#define PROT_MSG_CHAT 0x2

int encode_and_send_default_message(int sockfd, char* msg, ssize_t msg_len);

int main() {

  printf("hello world\n");

  // 1. create a socket
  int sockfd = socket(AF_INET6, SOCK_STREAM, 0);
  if (sockfd < 0) {
    perror("failed to create socket.");
    return 1;
  }

  // 2. connect
  struct sockaddr_in6 addr = {
    .sin6_family = AF_INET6,
    .sin6_port = ntohs(1735),
    .sin6_flowinfo = 0,
    .sin6_addr = ntohl(0),
    .sin6_scope_id = 0,
  };

  if (connect(sockfd, (const struct sockaddr *) &addr, sizeof(addr)) == -1) {
    perror("failed to connect");
    return 1;
  }

  for (;;) {

    // 1004, as per the protocol spec
    char buf[1004];

    // read in user input
    printf("Enter a message: ");
    if (!fgets(buf, sizeof buf, stdin)) {
      perror("failed to read user inputs");
    }
    buf[strcspn(buf, "\r\n")] = 0;

    size_t buf_len = strlen(buf);
    printf("You said: `%s` with a length of %ld\n", buf, buf_len);
    if (encode_and_send_default_message(sockfd, buf, buf_len) == -1) {
      perror("failed to send message");
      return 1;
    }

  }

  return 0;
}

int encode_and_send_default_message(int sockfd, char* msg, ssize_t msg_len) {

  printf("message length: %ld\n", msg_len);

  // protocol signature
  //                        A     S     M     C     H     A     T
  char buf[1024];
  memset(buf, 0, sizeof buf); // zero all the memory

  char signature[] = {0x99, 0x61, 0x73, 0x6D, 0x63, 0x68, 0x61, 0x74};
  memcpy(buf, signature, sizeof signature);


  // write the version: 0.0.1
  buf[9]  = 0;  // major
  buf[10] = 0;  // minor

  uint16_t patch_version = 1;
  memcpy(&buf[11], &patch_version, sizeof patch_version);

  // write the action
  buf[13] = PROT_MSG_CHAT;

  // 2 byte - message length
  if (msg_len < 0 || msg_len > UINT16_MAX) {
    perror("message length beyond limits");
    return -1;
  }
  uint16_t len = msg_len;
  memcpy(&buf[17], &len, sizeof len);

  // message
  memcpy(&buf, msg, msg_len);

  ssize_t write_len = 20 + msg_len;
  int n = send(sockfd, buf, write_len, 0);
  if (n < 0) {
    perror("failed to write to socket");
    return -1;
  }

  printf("Having sent %d bytes.\n", n);

  return 0;
}
