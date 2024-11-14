section .data
    INT_PERC    db      '%d', 0xA, 0
    UF_SIZE     equ     24

; struct uf {
    p           equ     0
    h           equ     8
    sz          equ     16
; };

section .bss
    u           resq    1

section .text
    global _start
    extern printf
    extern malloc
    extern free

_start:
    mov rdi, 10                     ; malloc
    call uf_init
    mov [u], qword rax

    

    mov rdi, qword [u]              ; free
    call delete
    mov [u], qword rax
    mov rax, 60                     ; return 0
    xor rdi, rdi
    syscall

uf_init:
    ; rdi = size, return = rax
    push rdi
    mov rdi, UF_SIZE
    call malloc
    mov rbx, rax                    ; rbx -> u
    pop rdi
    mov [rbx+sz], rdi               ; sz = size
    imul rdi, rdi, 4
    call malloc
    mov [rbx+p], rax                ; p = malloc(sizeof(int)*size)
    mov rdi, [rbx+sz]
    imul rdi, rdi, 4
    call malloc
    mov [rbx+h], rax                ; h = ...
    mov rcx, 0                      ; iota + memset
    mov rax, [rbx+p]                ; &u->p
    mov rdx, [rbx+h]
    uf_init_set:
        mov dword [rax], ecx
        mov dword [rdx], 1
        inc rcx
        add rax, 4
        add rdx, 4
        cmp [rbx+sz], rcx
        jne uf_init_set
    mov rax, rbx
    ret
    
delete:
    ; rdi = p->u
    push rbx
    mov rbx, rdi
    mov rdi, [rbx+p]
    call free
    mov rdi, [rbx+h]
    call free
    mov rdi, rbx
    call free
    pop rbx
    mov rax, 0
    ret

find:
    ; rdi = uf, rsi = val
    push rsi
    mov rax, [rdi+p]                ; rax = u->p
    lea rsi, [rax+(rsi*4)]          ; &p[x]
    mov esi, dword [rsi]
    mov eax, esi
    cmp esi, dword [rsp]
    je find_return
    call find
    find_return:
        pop rsi
        ret

join:
    ; rdi = uf, rsi = x, rdx = y
    call find                       ; cx/dx unchanged in find
    mov ecx, eax
    xchg rsi, rdx
    call find
    mov edx, eax                    ; cx = px, dx = py
    cmp ecx, edx
    je join_return
    mov r8, [rdi+h]                 ; p->h
    lea r9, [r8+(rcx*4)]
    mov r9d, dword [r9]
    lea r10, [r8+(rdx*4)]
    mov r10d, dword [r10]           ; r9 = h[px], r10 = h[py]
    cmp r9, r10
    jl join_right
    xor rax, rax
    test ecx, edx
    setz al                         ; if ecx = edx, ++height
    add r9d, eax
    lea r10, [r8+(rcx*4)]
    mov dword [r10], r9d
    mov r8, [rdi+p]                 ; fix par
    lea r9, [r8+(rdx*4)]
    mov dword [r9], ecx
    join_right:
    mov r8, [rdi+p]
    lea r9, [r8+(rcx*4)]
    mov dword [r9], edx
    join_return:
        ret

con:
    ; rdi = uf, rsi = x, rdx = y
    call find
    mov ecx, eax
    xchg rsi, rdx
    call find
    xor ecx, eax
    xor eax, eax
    test ecx, ecx
    setz al                         ; if !(ecx^eax), al = 1
    ret