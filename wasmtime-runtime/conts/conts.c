#include <stdlib.h>

typedef struct uthread_ctx_t {
    uint64_t table[11];
    
    /*
     By convention, table stores the following in order:
        void *stack;
        int stackSize;

        void *sp;
        void *ip;

        uint64_t rax;
        uint64_t rbx;
        uint64_t rcx;
        uint64_t rdx;
        uint64_t rbp;
        uint64_t rsi;
        uint64_t rdi;
     */

} uthread_ctx_t;

extern uthread_ctx_t *cont_table[50];

void init_table(void) {
    for (int i = 0; i < 50; i++) {
        cont_table[i] = malloc(sizeof(uthread_ctx_t));
    }
}