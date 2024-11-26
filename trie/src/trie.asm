section .data
    INT_PERC    db      '%d', 0xA, 0
    STR_PERC    db      '%s', 0xA, 0
    INSTR       db      'IXXXXXXXXXXXXXXX', 0
    OUTSTR      db      'OXXXXXXXXXXXXXXX', 0

; struct trie {
    children    equ     0
    value       equ     8
    NODE_SZ     equ     16
    CHILD_SZ    equ     208
; }

section .bss
    root        resq    1

section .text
    global _start
    extern malloc
    extern memset
    extern free
    extern printf

_start:
    mov rax, 60
    xor rdi, rdi
    syscall

clear:
    ; rdi = root
    push rdi                                        ; stack align
    push rbx
    push r12
    test rdi, rdi
    jz clear_done
    mov r12, rdi
    xor rbx, rbx
    clear_loop:
        mov rdi, qword [r12+children]
        mov rdi, qword [rdi+(rbx*8)]
        test rdi, rdi
        jz clear_enum_empty
        call clear
        clear_enum_empty:
        inc rbx
        cmp rbx, 26
        jne clear_loop
    mov rdi, [r12+children]                         ; free child array
    call free
    mov rdi, r12                                    ; free node
    call free
    clear_done:
    pop r12
    pop rbx
    pop rdi
    ret

make_node:
    ; return rax = p->node
    sub rsp, 8
    mov rdi, NODE_SZ
    call malloc
    mov qword [rsp], rax
    mov rdi, CHILD_SZ
    call malloc
    mov rcx, qword [rsp]                            ; [rsp] = node*
    mov qword [rcx+children], rax
    mov dword [rcx+value], 0                        ; default val = 0
    mov rdi, qword [rcx+children]                   ; zero children ptrs
    xor rsi, rsi
    mov rdx, CHILD_SZ
    call memset
    mov rax, qword [rsp]                            ; return node*
    add rsp, 8
    ret

find:
    ; rdi = p->str
    ; rsi = len
    xor rax, rax
    mov rcx, qword [root]
    test rcx, rcx
    jz find_done
    xor r9, r9
    find_loop:
        mov rdx, qword [rcx+children]               ; rdx = node->arr
        xor r8, r8
        mov r8b, byte [rdi+r9] 
        mov rcx, qword [rdx+(r8*8)]
        test rcx, rcx
        jz find_done
        inc r9
        cmp r9, rsi
        jne find_loop
    mov eax, dword [rcx+value]
    find_done: 
    ret

insert:
    ; rdi = p->str
    ; rsi = len
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r14, rdi
    mov r15, rsi
    mov rbx, qword [root]
    xor r13, r13
    insert_loop:
        mov r12, qword [rbx+children]
        xor r8, r8
        mov r8b, byte [r14+r13]

        ; FIN ITER TRIE


    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret