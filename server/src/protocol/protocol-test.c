#include <assert.h>
#include <stdint.h>
#include <stdio.h>

extern int _is_protocol(char *x);
extern char *_get_protocol_version();

typedef int8_t b8;
#define false 0
#define true 1

b8 test_is_protocol() {

  b8 ret = false;

  char test_arr[] = {0x99, 0x61, 0x73, 0x6D, 0x63, 0x68, 0x61, 0x74, 0x0A};
  char test_dupe_arr[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

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

int main() {

  printf("testing...\n");
  printf("version: %s\n", _get_protocol_version());

  if (test_is_protocol() != true) {
    printf("failed test `test_is_protocol`.\n");
  } else {
    printf("succeeded test `test_is_protocol`.\n");
  }

  return 0;
}
