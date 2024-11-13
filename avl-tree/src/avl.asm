section .data
    INT_PERC    db      '%d', 0xA, 0
    NODE_SIZE   equ     24

;   struct node {
        left        equ     0
        right       equ     8
        val         equ     16
        height      equ     20
;   };

section .bss
    ROOT        resq    1

section .text
    global _start
    extern rand
    extern printf
    extern malloc
    extern free

_start:

    mov rdi, 7
    call new_node
    mov [ROOT], qword rax       ; p->p->node
    
    lea rcx, [rax+val]
    mov rdi, INT_PERC
    mov rsi, [rcx]              ; rcx = &node->val | *rcx = &node->val
    call printf

    mov rdi, 10
    call new_node
    mov rcx, qword [ROOT]       ; rcx = node*
    mov [rcx+right], rax

    mov rdi, qword [ROOT]
    call get_balance
    mov rdi, INT_PERC
    mov rsi, rax
    call printf

    mov rdi, qword [ROOT]
    call delete_tree

    mov rax, 60
    xor rdi, rdi
    syscall

new_node:
    ; val in rdi, p->node in rax
    push rdi
    mov rdi, NODE_SIZE
    call malloc
    pop rdi
    lea rcx, [rax+left]
    mov qword [rcx], 0
    lea rcx, [rax+right]
    mov qword [rcx], 0
    lea rcx, [rax+val]
    mov dword [rcx], edi
    lea rcx, [rax+height]
    mov dword [rcx], 1
    ret

delete_tree:
    ; p->root in rdi
    test rdi, rdi
    jz delete_tree_return
    push rdi
    mov rdi, qword [rdi+left]
    call delete_tree
    mov rdi, [rsp]
    mov rdi, qword [rdi+right]
    call delete_tree
    pop rdi
    call free
    delete_tree_return:
        ret

avl_find:   
    ; rdi = root, rsi = target
    push rdi
    avl_find_loop:
        test rdi, rdi
        jz avl_find_return              ; break if !node
        mov rcx, [rdi+val] 
        cmp rsi, rcx
        je avl_find_return
        jg avl_find_g
        mov rdi, [rdi+right]            ; less rdi < rcx = go right
        jmp avl_find_loop
        avl_find_g:
            mov rdi, [rdi+left]
            jmp avl_find_loop
    avl_find_return:
        mov rax, rdi
        pop rdi
        ret

left_rotate:
    ; rdi = node = x
    lea rcx, [rdi+right]                ; rcx -> y
    lea rdx, [rcx+left]                 ; rdx -> t (y->left)
    mov [rcx+left], rdi                 ; y->left = x
    mov [rdi+right], rdx                ; x->right = t
    push rcx
    ; call fix_height(x)
    ; call fix_height(y)
    pop rax                             ; return y
    ret

right_rotate:
    ; rdi = node = x
    lea rcx, [rdi+left]                 ; rcx -> y
    lea rdx, [rcx+right]                ; rdx -> t (y->right)
    mov [rcx+right], rdi                ; y->right = x
    mov [rdi+left], rdx                 ; x->left = t
    push rcx
    ; call fix_height(x)
    ; call fix_height(y)
    pop rax
    ret

get_balance:
    ; rdi = node
    mov rcx, 0
    mov rdx, 0
    test rdi, rdi
    jz get_balance_return
    mov r8, [rdi+right]                ; rcx = right->height
    test r8, r8                        ; if !right
    jz balance_left_height
    mov rcx, [r8+height]
    balance_left_height:
        mov r8, [rdi+left]
        test r8, r8
        jz get_balance_return
        mov rdx, [r8+height]
    get_balance_return:
        mov rax, rcx
        sub rax, rdx                   ; return height right - left
        ret

fix_height:
    ; rdi = node
    mov rcx, 0
    mov rax, 0
    test rdi, rdi
    jz fix_height_return
    mov r8, [rdi+right]                ; rcx = right->height
    test r8, r8                        ; if !right
    jz get_left_height
    mov rcx, [r8+height]
    get_left_height:
        mov r8, [rdi+left]
        test r8, r8
        jz fix_height_return
        mov rax, [r8+height]
    fix_height_return:
        cmp rcx, rax
        cmovl rax, rcx                 ; mov rcx to rax if rcx > rax
        ret