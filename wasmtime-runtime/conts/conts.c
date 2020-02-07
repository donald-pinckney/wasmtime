#include <stdlib.h>
// #include <stdio.h>

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

#define CONT_TABLE_SIZE 100001
#define STACK_SIZE 256 // 2^23, 8388608
#define STACK_TABLE_SIZE 100001

extern uthread_ctx_t *cont_table[CONT_TABLE_SIZE];

uint64_t free_cont_id_list[CONT_TABLE_SIZE];
uint64_t free_cont_id_list_top = 0; // From this index we will alloc the next cont_id


// from: https://stackoverflow.com/questions/227897/how-to-allocate-aligned-memory-only-using-the-standard-library
void *malloc16(size_t size) {
    void *mem = malloc(size+15);
    void *ptr = (void *)(((uint64_t)mem+15) & ~ (uint64_t)0x0F);
    return ptr;
}

char *stacks_area = NULL;

uint64_t free_stack_id_list[STACK_TABLE_SIZE];
uint64_t free_stack_id_list_top = 0; // From this index we will alloc the next stack id


void init_table(void) {
    // printf("Starting init table\n");

    for (int i = 0; i < CONT_TABLE_SIZE; i++) {
        cont_table[i] = malloc(sizeof(uthread_ctx_t));
        // cont_table[i]->table[0] = alloc_stack();
        
        free_cont_id_list[i] = (uint64_t)i;
    }
    // printf("(1)\n");

    free_cont_id_list_top = 0;

    stacks_area = malloc16(STACK_SIZE * STACK_TABLE_SIZE);
    // printf("(2)\n");
    for (int i = 0; i < STACK_TABLE_SIZE; i++) {        
        free_stack_id_list[i] = (uint64_t)i;
    }
    // printf("(3)\n");
}


uint64_t alloc_cont_id() {
    if(free_cont_id_list_top == CONT_TABLE_SIZE) {
        // printf("Error: out of continuations to allocate.\n");
        abort();
    } else {
        uint64_t id = free_cont_id_list[free_cont_id_list_top++];
        // printf("alloc cont: %llu\n", id);
        return id;
    }
    
}

void dealloc_cont_id(uint64_t id) {
    // printf("dealloc cont: %llu\n", id);
    free_cont_id_list[--free_cont_id_list_top] = id;
}


uint64_t alloc_stack() {
    if(free_stack_id_list_top == STACK_TABLE_SIZE) {
        // printf("Error: out of stacks to allocate.\n");
        abort();
    } else {
        uint64_t id = free_stack_id_list[free_stack_id_list_top++];
        uint64_t stack_base = (uint64_t)((void *)stacks_area) + STACK_SIZE * id;
        uint64_t stack_top = (stack_base + STACK_SIZE) - 16;
        // printf("alloc stack: id: %llu, base: %p, top: %p\n", id, stack_base, stack_top);
        return stack_top;
    }


    // uint64_t stack_base = (uint64_t)malloc16(STACK_SIZE);
    // uint64_t stack_top = (stack_base + STACK_SIZE) - 16;
    // printf("alloc stack: base: %llu, top: %llu\n", stack_base, stack_top);
    // return stack_top;
}

// Note that sp is anywhere in the stack, not necessarily the base pointer or top of stack pointer.
void dealloc_stack(void *sp) {
    uint64_t id = ((uint64_t)sp - (uint64_t)((void *)stacks_area)) / STACK_SIZE;

    // printf("dealloc stack: id: %llu, rsp: %p\n", id, (uint64_t)sp);

    free_stack_id_list[--free_stack_id_list_top] = id;
}