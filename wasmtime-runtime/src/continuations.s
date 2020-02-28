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
//.globl _cont_id
.section __DATA,__data
    // table_len: .byte 5000
    .align 3
    rdx_scratch: .quad 0
    _cont_id: .quad 0
    _cont_table: .skip 800008 // has to be the same as 8 * CONT_TABLE_SIZE in conts.c

.text
_mark_stack_start:
    retq



// pub fn control(fn_ptr: *mut u64, arg: u64, vm: *mut u64) -> u64;
_control:
    // Arguments: 
    //   1. rdi = fn_ptr
    //   2. rsi = arg
    //   3. rdx = vm context ptr


    // We can use the following registers freely, since they were already saved appropriately by the caller, and are not arguments (that we care about):
    // rax, rcx, r8, r9, r10, r11

    // ******** Get a new (free) continuation id ************
    // Not sure that I need to save %rax
    // Definitely want to save rdi and rsi
    pushq %rdi
    pushq %rsi
    pushq %rdx
    call _alloc_cont_id
    popq %rdx
    popq %rsi
    popq %rdi

    // rax has the new continuation id

    // ******** Index into the continuation table  ********
    // After this, r11 holds the pointer to the uthread_ctx_t
    movq _cont_table@GOTPCREL(%rip), %r11
    movq (%r11, %rax, 8), %r11

    // CURRENT REGISTERS:
    // rbx, rbp, r12, r13, r14, r15 = need to be saved
    // rax = continuation ID
    // r11 = uthread_ctx_t struct pointer
    // rdi = fn_ptr
    // rsi = arg
    // rdx = vm context ptr
    // rcx, r8, r9, r10 = scratch

    // ********  Save the current context into the context in the table   ********
    movq %rsp, 16(%r11)
    // We need to add 8 to the saved stack pointer so that we save the stack pointer from BEFORE the return address was pushed
    addq $8, 16(%r11) // POSSIBLE BUG: DOES THIS MESS UP FLAGS / CC REGISTER?
    movq %rax, 32(%r11)
    movq %rbx, 40(%r11)
    movq %rcx, 48(%r11)
    movq %rdx, 56(%r11)
    movq %rbp, 64(%r11)
    movq %rsi, 72(%r11)
    movq %rdi, 80(%r11)
    // TODO: SAVE MORE REGISTERS!!! e.g. r12, r13, r14, r15
    // Save the return address (ip)
    movq (%rsp), %rcx
    movq %rcx, 24(%r11)




    // ********  Allocate a new stack   ********
    // First we need to rearrange some registers

    // CURRENT REGISTERS:
    // rax = continuation ID
    // r11 = uthread_ctx_t struct pointer
    // rdi = fn_ptr
    // rsi = arg
    // rdx = vm context ptr
    // r12, r13, r14, r15, rbp, rbx, rcx, r8, r9, r10 = scratch

    movq %rax, %rbx
    movq %r11, %r12
    movq %rdi, %r13
    movq %rsi, %r14
    movq %rdx, %r15

    // CURRENT REGISTERS:
    // rbx = continuation ID
    // r12 = uthread_ctx_t struct pointer
    // r13 = fn_ptr
    // r14 = arg
    // r15 = vm context ptr
    // rbp, rax, rcx, r8, r9, r10, r11, rdi, rsi, rdx = scratch

    pushq    %rbp
    movq    %rsp, %rbp
    callq _alloc_stack
    movq %rax, %rsp
    movq %rax, 0(%r12)

    // CURRENT REGISTERS:
    // rbx = continuation ID
    // r12 = uthread_ctx_t struct pointer
    // r13 = fn_ptr
    // r14 = arg
    // r15 = vm context ptr
    // rsp = new stack
    // rbp, rax, rcx, r8, r9, r10, r11, rdi, rsi, rdx = scratch


    //  ******** Jump to given function pointer with vm context ptr (56(%r12), old rdx) as 1st arg,
    // continuation id (rbx) as 2nd arg, env (r14) as 3rd arg  ********

    // We need to move the vm context ptr to rdi
    // We need to move the continuation id to rsi
    // We need to move the arg to rdx

    movq %r15, %rdi
    movq %rbx, %rsi
    movq %r14, %rdx

    // CURRENT REGISTERS / ARGUMENTS:
    //   1. rdi = vm context ptr
    //   2. rsi = continuation ID
    //   3. rdx = arg

    // all else is scratch now

    callq *%r13


    // If the invoked function ever returns (i.e. does not restore the continuation)
    // then we just kill the process.

    movq $0x2000001, %rax
    movq $0, %rdi
    syscall
    retq // not that this really matters


// pub fn restore(k: u64, val: u64, vm: *mut u64);
_restore:
    // Arguments:
    //   1. rdi = continuation id (k)
    //   2. rsi = argument for continuation (val)
    //   3. rdx = vm context

    // First, we MARK the given continuation id as free, but this does NOT wipe away the stuff stored in the table
    pushq %rdi
    pushq %rsi
    pushq %rdx
    call _dealloc_cont_id
    popq %rdx
    popq %rsi
    popq %rdi

    //  ******** Load the uthread_ctx_t from the _cont_table at index given by %rdi  ********
    movq _cont_table@GOTPCREL(%rip), %r12
    movq (%r12, %rdi, 8), %r12

    // r12 = the pointer to the uthread_ctx_t

    // ********* Free the current stack ***********
    //pushq    %rbp
    //movq    %rsp, %rbp

    //movq %rsp, %rdi

    pushq %rdi
    pushq %rsi
    pushq %rdx
    movq %rsp, %rdi
    subq $24, %rdi
    callq _dealloc_stack
    popq %rdx
    popq %rsi
    popq %rdi

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


    // Restore the rip, and jump to it
    movq 24(%r12), %r12
    jmpq *%r12

    //  ******** Restore uthread_ctx_t, passing the argument rsi into rax  ********
    retq





.end
