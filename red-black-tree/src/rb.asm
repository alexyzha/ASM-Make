section .data
    INT_PERC    db      '%d', 0xA, 0



section .bss



section .text
    global _start
    extern rand
    extern printf

_start:
    mov rdi, INT_PERC
    mov rsi, 7
    call printf

    mov rax, 60
    xor rdi, rdi
    syscall