section .data
    SHA_IN      db      'lmao', 0
    INT_PERC    db      '%d', 0xA, 0
    FLT_PERC    db      '%f', 0xA, 0
    HEX_PERC    db      '%02x', 0xA, 0
    STR_PERC    db      '%s', 0xA, 0
    TST_INCL    db      'IIIIIIIIIIIIIIII', 0
    TST_EXCL    db      'OOOOOOOOOOOOOOOO', 0
    TST_LEN     equ     16
    BYTE_MAX    equ     256
    BYTE_RNG    equ     94
    BYTE_OFS    equ     32

section .bss
    SHA_OUT     resb    32

section .text
    global _start
    extern rand
    extern SHA256
    extern printf
    extern srand

_start:
    mov rdi, 0x0a55f001
    call srand

    mov rdi, SHA_IN
    mov rsi, 4
    mov rdx, SHA_OUT
    call SHA256

    lea rbx, [SHA_OUT]
    mov r12, 32

    LOOP:
        mov rdi, HEX_PERC
        movzx rsi, byte [rbx]
        ; call printf
        inc rbx
        dec r12
        test r12, r12
        jnz LOOP

    lea rbx, [TST_INCL+1]
    lea r12, TST_LEN-1    
    LOOP2:
        call rand
        mov rcx, BYTE_RNG
        div rcx
        add rdx, BYTE_OFS
        mov [rbx], rdx
        inc rbx
        dec r12
        test r12, r12
        jnz LOOP2

    mov rdi, STR_PERC
    mov rsi, TST_INCL
    call printf 

    mov rax, 60
    xor rdi, rdi
    syscall