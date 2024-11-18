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
    mov rbx, 10
    push_loop:                      ; test push
        mov rdi, qword [pq]
        mov rsi, rbx
        call pq_push
        call pq_print
        dec rbx
        test rbx, rbx
        jnz push_loop
    mov rbx, 10
    pop_loop:                       ; test pop
        mov rdi, qword [pq]
        call pq_pop
        call pq_print
        dec rbx
        test rbx, rbx
        jnz pop_loop
    mov rdi, qword [pq]             ; delete
    call pq_delete
    mov qword [pq], 0
    mov rax, 60                     ; return 0
    xor rdi, rdi
    syscall

pq_init:
    ; return p->pq in rax
    mov rdi, PQ_SIZE
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

pq_push:
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
    dec edx                         ; edx-1 = real back index -> swim up
    test edx, edx
    jz push_finish                  ; if only 1 node then fin
    swim_up_loop:
        mov ecx, edx
        dec ecx
        shr ecx, 1                  ; ecx = par
        mov rax, qword [rdi+v]      ; p->v
        lea r8, [rax+(rcx*4)]
        mov r8d, dword [r8]         ; r8d = parent val
        lea r9, [rax+(rdx*4)]
        cmp dword [r9], r8d
        jg push_finish
        mov r10d, dword [r9]
        mov dword [r9], r8d
        lea r8, [rax+(rcx*4)]
        mov dword [r8], r10d
        mov edx, ecx                ; move to par
        test edx, edx
        jnz swim_up_loop
    push_finish:
    ret

pq_pop:
    ; rdi = pq*
    mov ecx, dword [rdi+back]
    test ecx, ecx
    jz pb_nothing                   ; ret if empty
    dec ecx
    mov dword [rdi+back], ecx
    test ecx, ecx
    jz pb_nothing                   ; ret if made empty
    mov rax, [rdi+v]                ; pop & swim down
    lea r8, [rax]
    mov edx, dword [r8]
    lea r9, [rax+(rcx*4)]           ; swap v[0] and v.back()
    xchg edx, dword [r9]
    mov dword [r8], edx
    xor rcx, rcx                    ; [0,rdi+back)
    swim_down_loop:
        mov r8d, ecx
        shl r8d, 1
        inc r8d                     ; lchild
        cmp r8d, dword [rdi+back]
        jge pb_nothing              ; no lchild = no rchild
        mov r9d, r8d
        inc r9d
        cmp r9d, dword [rdi+back]
        jge left_only
        lea r9, [rax+(r9*4)]        ; compare l/rchild
        mov r9d, dword [r9]
        cmp r9d, dword [rax+(r8*4)]
        jge left_only               ; jump if rchild >= lchild
        inc r8d
        left_only:                  ; r8d holds smaller of 2 children
            mov r10d, r8d
            lea r9, [rax+(r8*4)]    ; compare smaller child & par
            mov r9d, dword [r9]     ; r9 = smaller child, dword [rax+(rcx*4)] = parent
            cmp r9d, dword [rax+(rcx*4)]
            jge pb_nothing      
            lea r9, [rax+(rcx*4)]
            mov edx, dword [r9]
            lea r8, [rax+(r8*4)]
            xchg edx, dword [r8]
            mov dword [r9], edx
            mov ecx, r10d
        jmp swim_down_loop
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