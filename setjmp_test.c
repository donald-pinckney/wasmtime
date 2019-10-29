#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>

int main() {
    int r = setjmp(0);
    printf("%d\n", r);
    return 0;
}
