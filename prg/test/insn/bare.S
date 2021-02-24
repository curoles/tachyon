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

// from C call it like "_exit(n)" and simulator exit code will be n
_exit:
    li r7, SYSCALL_EXIT
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
