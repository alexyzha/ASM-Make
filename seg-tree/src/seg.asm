section .data
    INT_PERC    db      '%d', 0xA, 0
    SEG_SIZE    equ     16

; struct seg {

; };

section .bss
    seg         resq    1

section .text
    global _start
    extern printf
    extern malloc
    extern free

_start:
    mov rax, 60
    xor rdi, rdi
    syscall