section .data
    INT_PERC    db      '%d', 0xA, 0
    BIT_SIZE    equ     16

; struct bit {
    c           equ     0
    sz          equ     8
; };

section .bss
    b           resq    1

section .text
    global _start
    extern printf
    extern malloc
    extern free

_start:
    mov rdi, 100                    ; init small size
    call bit_init
    mov qword [b], rax
    mov r12, 25                     ; ins !([25:75]%5)
    test_loop:
        mov rdi, qword [b]
        mov rsi, r12
        mov rdx, 1
        call bit_update
        add r12, 5
        cmp r12, 75
        jle test_loop
    mov rdi, qword [b]              ; exp 11
    mov rsi, 25
    mov rdx, 75
    call bit_range
    mov rdi, INT_PERC
    mov rsi, rax
    call printf
    mov rdi, qword [b]              ; exp 6
    mov rsi, 50
    mov rdx, 75
    call bit_range
    mov rdi, INT_PERC
    mov rsi, rax
    call printf
    mov rdi, qword [b]              ; free memoy
    call bit_delete
    mov qword [b], rax
    mov rax, 60                     ; return 0
    xor rdi, rdi
    syscall

bit_init:
    ; rdi = n
    push rdi
    mov rdi, BIT_SIZE
    call malloc
    mov rdi, [rsp]
    mov dword [rax+sz], edi
    mov rbx, rax                    ; rbx = bit* = ret
    inc rdi
    imul rdi, rdi, 4
    call malloc
    mov qword [rbx+c], rax
    mov rdi, [rsp]
    inc rdi
    bit_init_loop:
        mov dword [rax], 0
        add rax, 4
        dec rdi
        test rdi, rdi
        jnz bit_init_loop
    pop rdi
    mov rax, rbx
    ret

bit_delete:
    ; rdi = bit*
    push rbx
    mov rbx, rdi
    mov rdi, qword [rbx+c]
    call free
    mov rdi, rbx
    call free
    pop rbx
    mov rax, 0
    ret

bit_update:
    ; rdi = bit*, rsi = i, rdx = d
    inc rsi
    mov r8d, dword [rdi+sz]
    bit_update_loop:
        mov rax, qword [rdi+c]
        lea rax, [rax+(rsi*4)]
        mov ecx, dword [rax]
        add ecx, edx
        mov dword [rax], ecx
        mov rcx, 0
        sub rcx, rsi                ; rcx = -i
        and rcx, rsi                ; -i&i
        add rsi, rcx
        cmp rsi, r8
        jle bit_update_loop
    ret

bit_query:
    ; rdi = bit*, rsi = i
    inc rsi
    mov rax, 0
    bit_query_loop:
        mov rdx, qword[rdi+c]
        lea rdx, [rdx+(rsi*4)]
        add eax, dword [rdx]        ; ret += c[i]
        mov rcx, 0
        sub rcx, rsi
        and rcx, rsi                ; -i&i
        sub rsi, rcx
        cmp rsi, 0
        jg bit_query_loop
    ret

bit_range:
    ; rdi = bit*, rsi = l, rdx = h
    push rdx
    dec rsi
    call bit_query                  ; [0,l-1]
    pop rsi
    mov rbx, rax
    call bit_query                  ; [0,r]
    sub rax, rbx
    ret