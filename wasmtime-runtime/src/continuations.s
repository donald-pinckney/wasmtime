//
//  continuations.s
//  c-stack
//
//  Created by Donald Pinckney on 8/15/19.
//  Copyright © 2019 donaldpinckney. All rights reserved.
//dd


// extern void uthread_ctx_switch(uthread_ctx_t *prev, uthread_ctx_t *next);
// If NULL is passed in the `next` parameter, then uthread_ctx_switch will not switch to any context, and will only capture the current context
.globl _mark_stack_start
.globl _restore
.globl _control
.globl _cont_table
.globl _cont_id
.section __DATA,__data
    table_len: .byte 50
    .align 3
    rdx_scratch: .quad 0
    _cont_id: .quad 0
    _cont_table: .skip 400 // has to be the same as table_len * 8

.text
_mark_stack_start:
    retq



_restore:
    // Current registers:
    // rdi = continuation id
    // rsi = argument for continuation

    //  ******** Load the uthread_ctx_t from the _cont_table at index given by %rdi  ********
    movq _cont_table@GOTPCREL(%rip), %r12
    // movq _threads@GOTPCREL(%rip), %r13d
    movq (%r12, %rdi, 8), %r12

    // r12 = the pointer to the uthread_ctx_t

    //  ******** Move rsi (the argument value) to rax, this will become the argument to the restored continuation  ********
    movq %rsi, %rax

    //  ******** Restore all the registers OTHER THAN rax
    movq 16(%r12), %rsp
//    movq 32(%r12), %rax
    movq 40(%r12), %rbx
    movq 48(%r12), %rcx
    movq 56(%r12), %rdx
    movq 64(%r12), %rbp
    movq 72(%r12), %rsi
    movq 80(%r12), %rdi

    movq 24(%r12), %r12
    jmpq *%r12

    //  ******** Restore uthread_ctx_t, passing the argument rsi into rax  ********
    retq

// extern uint64_t control(handler_fn h);


_control:
    //  ******** Save rdx to scratch space so we can use rdx  ********
    movq rdx_scratch@GOTPCREL(%rip), %r12
    movq %rdx, (%r12)

    //  ******** Load the current continuation id into rdx,  ********
    // and increment it in memory
    movq _cont_id@GOTPCREL(%rip), %r12
    incq (%r12)
    movq (%r12), %rdx
    decq %rdx

    // TODO: check that %rdx < table_len, otherwise trap

    // ******** Index into the continuation table  ********
    // After this, r12 holds the pointer to the uthread_ctx_t
    movq _cont_table@GOTPCREL(%rip), %r12
    movq (%r12, %rdx, 8), %r12


    // ********  Save the current context into the context in the table   ********
    movq %rsp, 16(%r12)
    // We need to add 8 to the saved stack pointer so that we save the stack pointer from BEFORE the return address was pushed
    addq $8, 16(%r12) // POSSIBLE BUG: DOES THIS MESS UP FLAGS / CC REGISTER?
    movq %rax, 32(%r12)
    movq %rbx, 40(%r12)
    movq %rcx, 48(%r12)
    movq %rdx, %rcx // rcx now holds the continuation id
    // To save rdx we first need to load the original rdx that we saved in scratch memory
    // Note that we HAVE to do this AFTER saving rax
    movq rdx_scratch@GOTPCREL(%rip), %rax
    movq (%rax), %rdx
    movq %rdx, 56(%r12)
    movq %rbp, 64(%r12)
    movq %rsi, 72(%r12)
    movq %rdi, 80(%r12)
    // Save the return address (ip)
    movq (%rsp), %rax
    movq %rax, 24(%r12)


    movq %rcx, %rbx
    movq %rdi, %r13
    movq %rsi, %r14
    // At this point, the registers are:
    // rbx = continuation id
    // r12 = pointer to uthread_ctx_t
    // r13 = function pointer argument
    // r14 = env arg


    pushq    %rbp
    movq    %rsp, %rbp
    //  ******** Alloc a new stack space  ********
//    callq _continuation_alloc_stack

    movl $8388608, %edi
    callq _malloc

    //  ******** Set rsp to new stack ********
    movq %rax, %rsp
    addq $8388608, %rsp
    subq $8, %rsp

    //  ******** Jump to given function pointer with continuation id (rbx) as 1st arg, env (r14) as 2nd arg  ********
    movq %rbx, %rdi
    movq %r14, %rsi
    callq *%r13

    // If the invoked function ever returns (i.e. does not restore the continuation)
    // then we just kill the process.

    movq $0x2000001, %rax
    movq $0, %rdi
    syscall
    retq // not that this really matters


.end
