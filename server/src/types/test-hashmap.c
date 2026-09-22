#include <assert.h>
#include <stddef.h>
#include <stdio.h>

extern void *_create_hashmap(ssize_t size, ssize_t elem_size);
extern void _add_hashmap(void *hashmap, int key, int element);
extern int _get_hashmap(void *hashmap, int key);
extern void _set_hashmap(void *hashmap, int key, int element);
extern void _has_hashmap(void *hashmap, int key);

struct xyz {
  ssize_t size;
  ssize_t cap;
  ssize_t element_size;

  int elements[];
};
typedef struct xyz HashMap;

int main() {

  printf("Testing Hashmap...\n");

  void *hashmap = _create_hashmap(8, sizeof(int));

  int key = 1;
  int want = 123;
  _add_hashmap(hashmap, key, want);
  int have = _get_hashmap(hashmap, key);

  assert(have == want);

  return 0;
}
