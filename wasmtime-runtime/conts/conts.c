#include <stdlib.h>
#include <string.h>

typedef struct uthread_ctx_t {
    uint64_t table[11];
    
    /*
     By convention, table stores the following in order:
        void *stack;
        int stackSize;

        void *sp;
        void *ip;

        uint64_t rbx;
        uint64_t rbp;
        uint64_t r12;
        uint64_t r13;
        uint64_t r14;
        uint64_t r15;

        uint64_t is_alloced;
     */

} uthread_ctx_t;

#define CONT_TABLE_SIZE 100001
#define STACK_SIZE 1024 // 1024, 2^23, 8388608, 1048576
#define STACK_TABLE_SIZE 100001

extern uthread_ctx_t *cont_table[CONT_TABLE_SIZE];
extern uint64_t current_stack_top;

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

    current_stack_top = 0;

    for (int i = 0; i < CONT_TABLE_SIZE; i++) {
        cont_table[i] = (uthread_ctx_t *)malloc(sizeof(uthread_ctx_t));
        cont_table[i]->table[10] = 0;
        // cont_table[i]->table[0] = alloc_stack();
        
        free_cont_id_list[i] = (uint64_t)i;
    }
    // printf("(1)\n");

    free_cont_id_list_top = 0;

    // printf("mallocing %d bytes\n", STACK_SIZE * STACK_TABLE_SIZE);
    stacks_area = (char *)malloc16(STACK_SIZE * STACK_TABLE_SIZE);

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


uint64_t continuation_copy(uint64_t kid, void *vmctx) {
    uthread_ctx_t *k = cont_table[kid];
    if(k->table[0] == 0 || k->table[10] == 0) {
        abort(); // Can not copy the root continuation, and can not copy deallocated continuation.
    }

    void *stack_top = (void *)k->table[0];
    void *rsp = (void *)k->table[2]; // copy from here
    uint64_t rsp_offset = (uint64_t)stack_top - (uint64_t)rsp;
    size_t bytes_to_copy = (size_t)rsp_offset + 8; // with this length

    uint64_t rbp_rsp_offset = k->table[5] - (uint64_t)rsp;


    uint64_t new_kid = alloc_cont_id();
    void *new_stack_top = (void *)alloc_stack();
    uint64_t new_rsp = (uint64_t)new_stack_top - rsp_offset;
    uint64_t new_rbp = new_rsp + rbp_rsp_offset;

    uthread_ctx_t *new_k = cont_table[new_kid];
    new_k->table[0] = (uint64_t)new_stack_top; // I think???
    new_k->table[1] = k->table[1];
    new_k->table[2] = (uint64_t)new_stack_top - rsp_offset;
    new_k->table[3] = k->table[3];
    new_k->table[4] = k->table[4];
    new_k->table[5] = new_rbp; // rbp, change to be offset from rsp???
    new_k->table[6] = k->table[6];
    new_k->table[7] = k->table[7];
    new_k->table[8] = k->table[8];
    new_k->table[9] = k->table[9];
    new_k->table[10] = k->table[10];

    memcpy((void *)new_k->table[2], rsp, bytes_to_copy);
    // new_k->table


    return new_kid;
} 