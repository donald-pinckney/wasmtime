//
//  switch.s
//  c-stack
//
//  Created by Donald Pinckney on 8/14/19.
//  Copyright © 2019 donaldpinckney. All rights reserved.
//


// extern void uthread_ctx_switch(uthread_ctx_t *prev, uthread_ctx_t *next);
// If NULL is passed in the `next` parameter, then uthread_ctx_switch will not switch to any context, and will only capture the current context
.globl _uthread_ctx_switch
.text
_uthread_ctx_switch:
    // Save the current context
    movq %rsp, 16(%rdi)
    // We need to add 8 to the saved stack pointer so that we save the stack pointer from BEFORE the return address was pushed
    addq $8, 16(%rdi) // POSSIBLE BUG: DOES THIS MESS UP FLAGS / CC REGISTER?
    movq %rax, 32(%rdi)
    movq %rbx, 40(%rdi)
    movq %rcx, 48(%rdi)
    movq %rdx, 56(%rdi)
    movq %rbp, 64(%rdi)
    movq %rsi, 72(%rdi)
    movq %rdi, 80(%rdi)
    // Save the return address (ip)
    movq (%rsp), %r12
    movq %r12, 24(%rdi)


    // If next is NULL, just return, don't switch context
    testq %rsi, %rsi // POSSIBLE BUG: THIS MESSES UP FLAGS / CC REGISTER?
    je .L_NO_SWITCH

    // Otherwise, switch context
    movq 16(%rsi), %rsp
    movq 32(%rsi), %rax
    movq 40(%rsi), %rbx
    movq 48(%rsi), %rcx
    movq 56(%rsi), %rdx
    movq 64(%rsi), %rbp
    movq 80(%rsi), %rdi
    movq 24(%rsi), %r12 // We need to move jump target to r12 first, because we are about to blow away rsi
    movq 72(%rsi), %rsi
    jmpq *%r12

    .L_NO_SWITCH:
        retq
.end
