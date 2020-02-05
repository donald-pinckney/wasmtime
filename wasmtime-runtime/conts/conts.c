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

#define CONT_TABLE_SIZE 5000

extern uthread_ctx_t *cont_table[CONT_TABLE_SIZE];

uint64_t free_list[CONT_TABLE_SIZE];
uint64_t free_top = 0; // From this index we will alloc the next cont_id

void init_table(void) {
    for (int i = 0; i < CONT_TABLE_SIZE; i++) {
        cont_table[i] = malloc(sizeof(uthread_ctx_t));
        free_list[i] = (uint64_t)i;
    }
    free_top = 0;
}


uint64_t alloc_cont_id() {
    if(free_top == CONT_TABLE_SIZE) {
        abort();
    } else {
        return free_list[free_top++];
    }
    
}

void dealloc_cont_id(uint64_t id) {
    free_list[--free_top] = id;
}

// from: https://stackoverflow.com/questions/227897/how-to-allocate-aligned-memory-only-using-the-standard-library
void *malloc16(size_t size) {
    void *mem = malloc(size+15);
    void *ptr = (void *)(((uint64_t)mem+15) & ~ (uint64_t)0x0F);
    return ptr;
}