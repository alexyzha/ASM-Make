section .data
    INT_PERC    db      '%d', 0xA, 0
    INTWO_PR    db      '%d', 0x20 , '%d', 0xA, 0
    STR_PERC    db      '%s', 0xA, 0
    DIVIDER     db      '#========================#', 0
    EMPTYLN     db      0x20, 0
    NULL        db      'NULL', 0x20, 0
    NODE_SIZE   equ     24

; struct node {
    left        equ     0
    right       equ     8
    val         equ     16
    height      equ     20
; };

section .bss
    ROOT        resq    1

section .text
    global _start
    extern rand
    extern srand
    extern printf
    extern malloc
    extern free

_start:
    mov rdi, 0x0a55face
    call srand
    mov qword [ROOT], 0         ; nullptr
    mov rbx, 100000
    call print_line
    insert_test_loop:           ; in
        ; call rand
        ; xor rdx, rdx
        ; mov rcx, 0x7fffffff
        ; div rcx
        ; push rdx
        ; mov rdi, INT_PERC
        ; mov esi, edx
        ; call printf
        ; pop rdx
        mov esi, ebx
        mov rdi, qword [ROOT]
        call avl_insert
        mov qword [ROOT], rax
        ; mov rdi, qword [ROOT]
        ; call print_bfs
        ; call print_line
        dec rbx
        test rbx, rbx
        jnz insert_test_loop
    mov rbx, 100000
    call print_line
    delete_test_loop:           ; delete
        mov esi, ebx
        mov rdi, qword [ROOT]
        call avl_delete
        mov qword [ROOT], rax
        dec rbx
        test rbx, rbx
        jnz delete_test_loop
    mov rdi, qword [ROOT]
    call delete_tree
    mov rax, 60                 ; return 0
    xor rdi, rdi
    syscall

print_line:
    mov rdi, STR_PERC
    mov rsi, DIVIDER
    call printf
    ret

print_node:
    ; rdi = node
    push rdi
    push rsi
    push rbx
    mov rbx, rdi
    mov rdi, INT_PERC
    mov rsi, qword [rbx+left]
    call printf
    mov rdi, INT_PERC
    mov rsi, qword [rbx+right]
    call printf
    mov rdi, INT_PERC
    mov esi, dword [rbx+val]
    call printf
    mov rdi, INT_PERC
    mov esi, dword [rbx+height]
    call printf
    mov rdi, STR_PERC
    mov rsi, EMPTYLN
    call printf
    pop rbx
    pop rsi
    pop rdi
    ret

print_bfs:
    ; rdi = node
    push rbx
    push rdi
    mov rdi, 120                ; 15*8
    call malloc                 ; rax = array
    mov rbx, rax
    mov rcx, 0
    print_set_loop:             ; arr[15] = {0}
        mov qword [rax], 0
        add rax, 8
        inc rcx
        cmp rcx, 15
        jne print_set_loop
    pop rdi
    mov qword [rbx], rdi
    mov rcx, 0
    print_bfs_loop:
        lea rdx, [rbx+(rcx*8)]  ; arr[i]
        mov rdx, qword [rdx]    ; rdx = p->node
        test rdx, rdx
        jz print_add_end
        mov r8, rcx
        shl r8, 1
        inc r8
        lea r8, [rbx+(r8*8)]
        mov rax, qword [rdx+left]
        mov qword [r8], rax
        add r8, 8
        mov rax, qword [rdx+right]
        mov qword [r8], rax
        print_add_end:
            inc rcx
            cmp rcx, 7
            jne print_bfs_loop
    mov rcx, 0
    lea rdx, [rbx+(rcx*8)]
    actual_print_loop:
        mov rax, qword [rdx]
        test rax, rax           ; nullptr
        jz print_null
        push rdx
        push rcx
        push rdi
        mov rdi, INTWO_PR
        mov esi, dword [rax+val]
        mov edx, dword [rax+height]
        call printf
        pop rdi
        pop rcx
        pop rdx
        jmp actual_print_end
        print_null:
            push rdx
            push rcx
            push rdi
            mov rdi, STR_PERC
            mov rsi, NULL
            call printf
            pop rdi
            pop rcx
            pop rdx
        actual_print_end:
            add rdx, 8
            inc rcx
            cmp rcx, 15
            jne actual_print_loop
    pop rbx
    ret

new_node:
    ; val in rdi, p->node in rax
    push rdi
    mov rdi, NODE_SIZE
    call malloc
    pop rdi
    mov qword [rax+left], 0
    mov qword [rax+right], 0
    mov dword [rax+val], edi
    mov dword [rax+height], 1
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
        cmp dword [rdi+val], esi
        je avl_find_return
        jg avl_find_g
        mov rdi, qword [rdi+right]      ; less rdi < rcx = go right
        jmp avl_find_loop
        avl_find_g:
            mov rdi, qword [rdi+left]
            jmp avl_find_loop
    avl_find_return:
        mov rax, rdi
        pop rdi
        ret

left_rotate:
    ; rdi = node = x
    push rbx
    mov rcx, qword [rdi+right]          ; rcx -> y
    mov rdx, qword [rcx+left]           ; rdx -> t (y->left)
    mov qword [rcx+left], rdi           ; y->left = x
    mov qword [rdi+right], rdx          ; x->right = t
    push rcx
    mov rbx, rcx
    call fix_height
    xchg rdi, rbx
    call fix_height
    xchg rdi, rbx
    pop rax                             ; return y
    pop rbx
    ret

right_rotate:
    ; rdi = node = x
    push rbx
    mov rcx, qword [rdi+left]           ; rcx -> y
    mov rdx, qword [rcx+right]          ; rdx -> t (y->right)
    mov qword [rcx+right], rdi          ; y->right = x
    mov qword [rdi+left], rdx           ; x->left = t
    push rcx
    mov rbx, rcx
    call fix_height
    xchg rdi, rbx
    call fix_height
    xchg rdi, rbx
    pop rax
    pop rbx
    ret

get_balance:
    ; rdi = node
    xor rcx, rcx
    xor rdx, rdx
    test rdi, rdi
    jz get_balance_return
    mov r8, qword [rdi+right]          ; rcx = right->height
    test r8, r8                        ; if !right
    jz balance_left_height
    mov ecx, dword [r8+height]
    balance_left_height:
        mov r8, qword [rdi+left]
        test r8, r8
        jz get_balance_return
        mov edx, dword [r8+height]
    get_balance_return:
        mov eax, ecx
        sub eax, edx                   ; return height right - left
        ret

fix_height:
    ; rdi = node
    xor rcx, rcx
    xor rax, rax
    test rdi, rdi
    jz fix_height_return
    mov r8, qword [rdi+right]          ; rcx = right->height
    test r8, r8                        ; if !right
    jz get_left_height
    mov ecx, dword [r8+height]
    get_left_height:
        mov r8, qword [rdi+left]
        test r8, r8
        jz fix_height_final
        mov eax, dword [r8+height]
    fix_height_final:
        cmp ecx, eax
        cmova eax, ecx                 ; mov ecx to eax if ecx > eax
        inc eax
        mov dword [rdi+height], eax
    fix_height_return:
        ret

avl_insert:
    ; rdi = cur node
    ; rsi = i
    push rsi
    test rdi, rdi
    jnz avl_insert_no_create
    mov rdi, rsi
    call new_node                       ; rax = new node
    mov rdi, rax                        ; cur* = new node()
    avl_insert_no_create:
        mov rsi, qword [rsp]
        cmp dword [rdi+val], esi        ; if i < cur->val, cur->left = insert(cur->left)
        je avl_insert_return
        jg avl_insert_g
        push rdi                        ; cur->right = insert(cur->right)
        mov rdi, qword [rdi+right]
        call avl_insert
        pop rdi
        mov qword [rdi+right], rax
        jmp avl_insert_balance
        avl_insert_g:
            push rdi
            mov rdi, qword [rdi+left]
            call avl_insert
            pop rdi
            mov qword [rdi+left], rax
    avl_insert_balance:
        call fix_height
        call get_balance
        mov ecx, eax
        xor rdx, rdx
        cdq
        xor eax, edx
        sub eax, edx
        cmp eax, 1
        jle avl_insert_return       ; no primary rotation
        avl_insert_pri:
        cmp ecx, 0                  ; bal < 0 = r else l
        jg avl_insert_pri_g
        call right_rotate
        jmp avl_insert_done
        avl_insert_pri_g:
            call left_rotate
        avl_insert_done:            ; rax = new cur
            mov rdi, rax
    avl_insert_return:
        mov rax, rdi
        pop rsi
        ret

avl_delete:
    ; rdi = cur
    ; rsi = val
    push rsi
    test rdi, rdi
    jz avl_delete_return
    cmp dword [rdi+val], esi            ; compare & go
    jne avl_delete_path
    mov rax, qword [rdi+left]           ; r&l = 2c
    test rax, rax
    jz avl_delete_less_cld              ; if(!l) 
    or rax, qword [rdi+right]
    cmp rax, qword [rdi+left]           ; r|l == l, r = nptr
    je avl_delete_less_cld
        mov rax, qword [rdi+right]
        successor_loop:
            mov rcx, qword [rax+left]
            test rcx, rcx
            cmovnz rax, rcx
            jnz successor_loop
        mov ecx, dword [rdi+val]
        xchg ecx, dword [rax+val]
        xchg ecx, dword [rdi+val]       ; after swap
        push rdi
        mov rdi, qword [rdi+right]
        call avl_delete
        pop rdi
        mov qword [rdi+right], rax      ; cur->r = delete(cur->r)
        jmp avl_delete_path
    avl_delete_less_cld:
        mov rax, qword [rdi+left]
        test rax, rax
        jnz avl_delete_less_cld_free
        mov rax, qword [rdi+right]
        avl_delete_less_cld_free:
            push rax                    ; rdi = node still
            call free
            pop rax
            mov rdi, rax
            jmp avl_delete_return
    avl_delete_path:
        cmp dword [rdi+val], esi
        jg avl_delete_g
        push rdi
        mov rdi, qword [rdi+right]
        call avl_delete
        pop rdi
        mov qword [rdi+right], rax
        jmp avl_delete_balance
        avl_delete_g:
            push rdi
            mov rdi, qword [rdi+left]
            call avl_delete
            pop rdi
            mov qword [rdi+left], rax
    avl_delete_balance:
        call fix_height
        call get_balance
        mov ecx, eax
        xor rdx, rdx
        cdq
        xor eax, edx
        sub eax, edx
        cmp eax, 1
        jle avl_delete_return       ; no primary rotation
        avl_delete_pri:
        cmp ecx, 0                  ; bal < 0 = r else l
        jg avl_delete_pri_g
        call right_rotate
        jmp avl_delete_done
        avl_delete_pri_g:
            call left_rotate
        avl_delete_done:            ; rax = new cur
            mov rdi, rax
    avl_delete_return:
        mov rax, rdi
        pop rsi
        ret