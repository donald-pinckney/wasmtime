#include <setjmp.h>
#include <stdio.h>

jmp_buf buf;

int main(void) {
  int r = setjmp(buf);
  printf("r = %d\n", r);
  longjmp(buf, 42);
  return 0;
}

