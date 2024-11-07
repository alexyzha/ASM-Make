section .data


section .bss


section .text
    global _start:
    extern fscanf
    extern fopen
    extern fclose

_start:
    mov rax, 60
    xor rdi, rdi
    ret