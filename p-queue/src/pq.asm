section .data
    INT_PERC    db      '%d', 0xA, 0
    INT_PNNL    db      '%d', 0x20, 0
    NEWLINE     db      0xA, 0
    PQ_SIZE     equ     16

; struct pq {
    v           equ     0
    back        equ     8
    sz          equ     12
; };

section .bss
    pq          resq    1

section .text
    global _start
    extern printf
    extern malloc
    extern free

_start:
    call pq_init
    mov qword [pq], rax
    mov rbx, 0
    push_loop:                      ; test push
        mov rdi, qword [pq]
        mov rsi, rbx
        call push_back
        call pq_print
        inc rbx
        cmp rbx, 10
        jne push_loop
    mov rbx, 10
    pop_loop:                       ; test pop
        mov rdi, qword [pq]
        call pop_back
        call pq_print
        dec rbx
        test rbx, rbx
        jnz pop_loop
    mov rdi, qword [pq]            ; delete
    call pq_delete
    mov qword [pq], 0
    mov rax, 60                     ; return 0
    xor rdi, rdi
    syscall

pq_init:
    ; return p->pq in rax
    mov rdi, pq_SIZE
    call malloc
    push rax
    mov rdi, 4
    call malloc
    mov rcx, rax
    pop rax
    mov qword [rax+v], rcx
    mov dword [rax+back], 0
    mov dword [rax+sz], 1
    ret

pq_delete:
    ; rdi = pq*
    push rdi
    mov rdi, qword [rdi+v]
    call free
    pop rdi
    call free
    ret

push_back:
    ; rdi = pq*, rsi = val
    mov eax, dword [rdi+back]
    cmp eax, dword [rdi+sz]
    jne pb_no_rsz                   ; rsz = sz*2 @ full
    push rdi
    push rsi
    mov edi, dword [rdi+sz]
    imul edi, edi, 8
    call malloc
    pop rsi
    pop rdi
    xchg qword [rdi+v], rax         ; swap rax, pq->v ; rax = old
    push rax
    mov rcx, qword [rdi+v]          ; rcx = p->new arr
    mov edx, dword [rdi+sz]
    rsz_loop:
        mov r8d, dword [rax]
        mov dword [rcx], r8d
        add rax, 4
        add rcx, 4
        dec edx
        test edx, edx
        jnz rsz_loop
    pop rax
    mov ecx, dword [rdi+sz]         ; update size
    imul ecx, ecx, 2
    mov dword [rdi+sz], ecx
    push rdi
    push rsi
    mov rdi, rax                    ; rax = old arr
    call free
    pop rsi
    pop rdi
    pb_no_rsz:
        mov rcx, qword [rdi+v]
        mov edx, dword [rdi+back]
        lea rcx, [rcx+(rdx*4)]
        mov dword [rcx], esi
        inc edx
        mov dword [rdi+back], edx
    ret

pop_back:
    ; rdi = pq*
    mov ecx, dword [rdi+back]
    test ecx, ecx
    jz pb_nothing
    dec ecx
    mov dword [rdi+back], ecx
    pb_nothing:
        ret

pq_print:
    ; rdi = pq*
    push rbx
    push r12
    push rdi
    mov rbx, qword [rdi+v]
    mov r12, 0
    mov r13d, dword [rdi+back]
    test r13, r13
    jz print_nothing
    print_loop:
        mov rdi, INT_PNNL
        mov esi, dword [rbx]
        call printf
        add rbx, 4
        inc r12
        cmp r12, r13
        jne print_loop
    print_nothing:
        mov rdi, NEWLINE
        call printf
        pop rdi
        pop r12
        pop rbx
        ret