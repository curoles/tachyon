.text
.align  4

.global _reset
.global _start

_reset:
    la  sp, :xpcrel36:stack_top
    nop
    jsr _start
    nop
    nop

.align  4
.global _exit
.type   _exit, %function

#define SYSCALL_EXIT 93
#define SYSCALL_TYPE_REG r31
#define SYSCALL_ARG0_REG r24

// from C call it like "_exit(n)" and simulator exit code will be n
_exit:
    li SYSCALL_TYPE_REG, SYSCALL_EXIT
    ecall
    nop
    nop
    nop
    nop; nop; nop; nop; nop; nop; nop; nop;
    nop; nop; nop; nop; nop; nop; nop; nop;
    nop; nop; nop; nop; nop; nop; nop; nop;
    nop; nop; nop; nop; nop; nop; nop; nop;
    nop; nop; nop; nop; nop; nop; nop; nop;
    nop; nop; nop; nop; nop; nop; nop; nop;
    nop; nop; nop; nop; nop; nop; nop; nop;
    nop; nop; nop; nop; nop; nop; nop; nop;
    nop; nop; nop; nop; nop; nop; nop; nop;
