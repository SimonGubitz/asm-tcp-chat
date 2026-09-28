#include <assert.h>
#include <stdint.h>
#include <stdio.h>

extern int _is_protocol(char *);
extern char *_get_protocol_version();
extern char _read_message_type(char *);

typedef int8_t b8;
#define false 0
#define true 1

b8 test_is_protocol() {

  b8 ret = false;

  char test_arr[] = { 0x99, 0x61, 0x73, 0x6D, 0x63, 0x68, 0x61, 0x74, 0x0A };
  char test_dupe_arr[] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };

  int is_prot = _is_protocol(test_arr);
  if (is_prot != true) {
    return false; // failed the test
  }

  is_prot = _is_protocol(test_dupe_arr);
  if (is_prot != false) {
    return false; // failed the test
  }

  return true;
}

b8 test_read_message_type() {

  char want_message_type = 0x89;
  char test_protocol[] = { 0x99, 0x61, 0x73, 0x6D, 0x63, 0x68, 0x61, 0x74, 0x0A, /* version start */ 0x00, 0x00, 0x00, 0x00, /* message type start */ want_message_type, /* Padding 3 byte */ 0x00, 0x00, 0x00 };

  char have_message_type = _read_message_type(test_protocol);
  if (have_message_type != want_message_type) {
    printf("expected %d, got %d\n", want_message_type, have_message_type);
    return false;
  }

  return true;
}

void test_func(b8 res, char* name) {
  if (res != true) {
    printf("\nfailed test `%s`\n\n", name);
  } else {
    printf("succeeded test `%s`\n", name);
  }
}

int main() {

  printf("testing...\n");
  printf("version: %s\n", _get_protocol_version());

  test_func(test_is_protocol(), "test_is_protocol");
  test_func(test_read_message_type(), "test_read_message_type");
  test_func(false, "this should fail");

  return 0;
}
