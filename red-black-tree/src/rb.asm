section .data
    INT_PERC    db      '%d', 0xA, 0

    ; struct node {
        parent      equ     0
        left        equ     8
        right       equ     16
        val         equ     24
        color       equ     28
        NSIZE       equ     32
    ; };

section .bss
    node        resb        NSIZE


section .text
    global _start
    extern rand
    extern printf

_start:
    mov rdi, INT_PERC
    mov rsi, 7
    call printf

    lea rax, [node+parent]
    mov qword [rax], 0

    lea rax, [node+val]
    mov dword [rax], 0

    mov rax, 60
    xor rdi, rdi
    syscall