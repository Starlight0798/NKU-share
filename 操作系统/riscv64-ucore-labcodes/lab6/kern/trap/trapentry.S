#include <riscv.h>

    .altmacro
    .align 2
    .macro SAVE_ALL
    LOCAL _restore_kernel_sp
    LOCAL _save_context

    # If coming from userspace, preserve the user stack pointer and load
    # the kernel stack pointer. If we came from the kernel, sscratch
    # will contain 0, and we should continue on the current stack.
    csrrw sp, sscratch, sp
    bnez sp, _save_context

_restore_kernel_sp:
    csrr sp, sscratch
_save_context:
    addi sp, sp, -36 * REGBYTES
    # save x registers
    STORE x0, 0*REGBYTES(sp)
    STORE x1, 1*REGBYTES(sp)
    STORE x3, 3*REGBYTES(sp)
    STORE x4, 4*REGBYTES(sp)
    STORE x5, 5*REGBYTES(sp)
    STORE x6, 6*REGBYTES(sp)
    STORE x7, 7*REGBYTES(sp)
    STORE x8, 8*REGBYTES(sp)
    STORE x9, 9*REGBYTES(sp)
    STORE x10, 10*REGBYTES(sp)
    STORE x11, 11*REGBYTES(sp)
    STORE x12, 12*REGBYTES(sp)
    STORE x13, 13*REGBYTES(sp)
    STORE x14, 14*REGBYTES(sp)
    STORE x15, 15*REGBYTES(sp)
    STORE x16, 16*REGBYTES(sp)
    STORE x17, 17*REGBYTES(sp)
    STORE x18, 18*REGBYTES(sp)
    STORE x19, 19*REGBYTES(sp)
    STORE x20, 20*REGBYTES(sp)
    STORE x21, 21*REGBYTES(sp)
    STORE x22, 22*REGBYTES(sp)
    STORE x23, 23*REGBYTES(sp)
    STORE x24, 24*REGBYTES(sp)
    STORE x25, 25*REGBYTES(sp)
    STORE x26, 26*REGBYTES(sp)
    STORE x27, 27*REGBYTES(sp)
    STORE x28, 28*REGBYTES(sp)
    STORE x29, 29*REGBYTES(sp)
    STORE x30, 30*REGBYTES(sp)
    STORE x31, 31*REGBYTES(sp)

    # get sr, epc, tval, cause
    # Set sscratch register to 0, so that if a recursive exception
    # occurs, the exception vector knows it came from the kernel
    csrrw s0, sscratch, x0
    csrr s1, sstatus
    csrr s2, sepc
    csrr s3, 0x143
    csrr s4, scause

    STORE s0, 2*REGBYTES(sp)
    STORE s1, 32*REGBYTES(sp)
    STORE s2, 33*REGBYTES(sp)
    STORE s3, 34*REGBYTES(sp)
    STORE s4, 35*REGBYTES(sp)
    .endm

    .macro RESTORE_ALL
    LOCAL _save_kernel_sp
    LOCAL _restore_context

    LOAD s1, 32*REGBYTES(sp)
    LOAD s2, 33*REGBYTES(sp)

    andi s0, s1, SSTATUS_SPP
    bnez s0, _restore_context

_save_kernel_sp:
    # Save unwound kernel stack pointer in sscratch
    addi s0, sp, 36 * REGBYTES
    csrw sscratch, s0
_restore_context:
    csrw sstatus, s1
    csrw sepc, s2

    # restore x registers
    LOAD x1, 1*REGBYTES(sp)
    LOAD x3, 3*REGBYTES(sp)
    LOAD x4, 4*REGBYTES(sp)
    LOAD x5, 5*REGBYTES(sp)
    LOAD x6, 6*REGBYTES(sp)
    LOAD x7, 7*REGBYTES(sp)
    LOAD x8, 8*REGBYTES(sp)
    LOAD x9, 9*REGBYTES(sp)
    LOAD x10, 10*REGBYTES(sp)
    LOAD x11, 11*REGBYTES(sp)
    LOAD x12, 12*REGBYTES(sp)
    LOAD x13, 13*REGBYTES(sp)
    LOAD x14, 14*REGBYTES(sp)
    LOAD x15, 15*REGBYTES(sp)
    LOAD x16, 16*REGBYTES(sp)
    LOAD x17, 17*REGBYTES(sp)
    LOAD x18, 18*REGBYTES(sp)
    LOAD x19, 19*REGBYTES(sp)
    LOAD x20, 20*REGBYTES(sp)
    LOAD x21, 21*REGBYTES(sp)
    LOAD x22, 22*REGBYTES(sp)
    LOAD x23, 23*REGBYTES(sp)
    LOAD x24, 24*REGBYTES(sp)
    LOAD x25, 25*REGBYTES(sp)
    LOAD x26, 26*REGBYTES(sp)
    LOAD x27, 27*REGBYTES(sp)
    LOAD x28, 28*REGBYTES(sp)
    LOAD x29, 29*REGBYTES(sp)
    LOAD x30, 30*REGBYTES(sp)
    LOAD x31, 31*REGBYTES(sp)
    # restore sp last
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL

    move  a0, sp
    jal trap
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    # return from supervisor call
    sret
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
    j __trapret

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
    STORE s1, 35*REGBYTES(a1)
    LOAD s1, 34*REGBYTES(a0)
    STORE s1, 34*REGBYTES(a1)
    LOAD s1, 33*REGBYTES(a0)
    STORE s1, 33*REGBYTES(a1)
    LOAD s1, 32*REGBYTES(a0)
    STORE s1, 32*REGBYTES(a1)
    LOAD s1, 31*REGBYTES(a0)
    STORE s1, 31*REGBYTES(a1)
    LOAD s1, 30*REGBYTES(a0)
    STORE s1, 30*REGBYTES(a1)
    LOAD s1, 29*REGBYTES(a0)
    STORE s1, 29*REGBYTES(a1)
    LOAD s1, 28*REGBYTES(a0)
    STORE s1, 28*REGBYTES(a1)
    LOAD s1, 27*REGBYTES(a0)
    STORE s1, 27*REGBYTES(a1)
    LOAD s1, 26*REGBYTES(a0)
    STORE s1, 26*REGBYTES(a1)
    LOAD s1, 25*REGBYTES(a0)
    STORE s1, 25*REGBYTES(a1)
    LOAD s1, 24*REGBYTES(a0)
    STORE s1, 24*REGBYTES(a1)
    LOAD s1, 23*REGBYTES(a0)
    STORE s1, 23*REGBYTES(a1)
    LOAD s1, 22*REGBYTES(a0)
    STORE s1, 22*REGBYTES(a1)
    LOAD s1, 21*REGBYTES(a0)
    STORE s1, 21*REGBYTES(a1)
    LOAD s1, 20*REGBYTES(a0)
    STORE s1, 20*REGBYTES(a1)
    LOAD s1, 19*REGBYTES(a0)
    STORE s1, 19*REGBYTES(a1)
    LOAD s1, 18*REGBYTES(a0)
    STORE s1, 18*REGBYTES(a1)
    LOAD s1, 17*REGBYTES(a0)
    STORE s1, 17*REGBYTES(a1)
    LOAD s1, 16*REGBYTES(a0)
    STORE s1, 16*REGBYTES(a1)
    LOAD s1, 15*REGBYTES(a0)
    STORE s1, 15*REGBYTES(a1)
    LOAD s1, 14*REGBYTES(a0)
    STORE s1, 14*REGBYTES(a1)
    LOAD s1, 13*REGBYTES(a0)
    STORE s1, 13*REGBYTES(a1)
    LOAD s1, 12*REGBYTES(a0)
    STORE s1, 12*REGBYTES(a1)
    LOAD s1, 11*REGBYTES(a0)
    STORE s1, 11*REGBYTES(a1)
    LOAD s1, 10*REGBYTES(a0)
    STORE s1, 10*REGBYTES(a1)
    LOAD s1, 9*REGBYTES(a0)
    STORE s1, 9*REGBYTES(a1)
    LOAD s1, 8*REGBYTES(a0)
    STORE s1, 8*REGBYTES(a1)
    LOAD s1, 7*REGBYTES(a0)
    STORE s1, 7*REGBYTES(a1)
    LOAD s1, 6*REGBYTES(a0)
    STORE s1, 6*REGBYTES(a1)
    LOAD s1, 5*REGBYTES(a0)
    STORE s1, 5*REGBYTES(a1)
    LOAD s1, 4*REGBYTES(a0)
    STORE s1, 4*REGBYTES(a1)
    LOAD s1, 3*REGBYTES(a0)
    STORE s1, 3*REGBYTES(a1)
    LOAD s1, 2*REGBYTES(a0)
    STORE s1, 2*REGBYTES(a1)
    LOAD s1, 1*REGBYTES(a0)
    STORE s1, 1*REGBYTES(a1)
    LOAD s1, 0*REGBYTES(a0)
    STORE s1, 0*REGBYTES(a1)

    // acutually adjust sp
    move sp, a1
    j __trapret