section .data
    SHA_IN      db      'lmao', 0
    INT_PERC    db      '%d', 0xA, 0
    FLT_PERC    db      '%f', 0xA, 0
    HEX_PERC    db      '%02x', 0xA, 0
    STR_PERC    db      '%s', 0xA, 0
    TST_INCL    db      'IIIIIIIIIIIIIIII', 0
    TST_EXCL    db      'IIIIIIIIIIIIIIII', 0
    DIV_LN      db      '#======================#', 0
    PRINT_CP    db      'Collision %%: %f', 0xA, 0
    PRINT_CC    db      'Collisions: %d/%d', 0xA, 0
    TST_LEN     equ     16
    BYTE_MAX    equ     256
    BYTE_RNG    equ     94
    BYTE_OFS    equ     32      ; for readable strs
    HASH_ADD    equ     14      ; additional hash functions
    LL_SIZE     equ     64      ; ll = int64_t
    BIT_NUM     equ     1600000 ; 16 bits/item
    ITEM_CT     equ     100000

section .bss
    SHA_OUT     resb    32
    FILTER      resq    50000

section .text
    global _start
    extern rand
    extern SHA256
    extern printf
    extern srand

_start:
    finit                       ; init x87
    mov rdi, 0x0a55f001
    call srand                  ; seed
    call zero_filter            ; init filter
    mov rbx, ITEM_CT            ; insert all I-prefix str
    insert_loop:
        mov rdi, TST_INCL
        call gen_str
        mov rsi, 16
        mov rdx, 0
        call filter_insert
        dec rbx
        test rbx, rbx
        jnz insert_loop
    mov rbx, ITEM_CT            ; test all O-prefix str
    mov r12, 0                  ; false positive counter
    test_loop:
        mov rdi, TST_EXCL
        call gen_str
        mov rsi, 16
        mov rdx, 0
        call filter_count
        add r12, rax
        dec rbx
        test rbx, rbx
        jnz test_loop
    call print_div
    mov rdi, PRINT_CC           ; print fraction
    mov rsi, r12
    mov rdx, ITEM_CT
    call printf                 
    sub rsp, 8                  ; print percentage
    mov [rsp], r12
    fild qword [rsp]
    mov rcx, ITEM_CT
    mov [rsp], rcx
    fild qword [rsp]
    fdivp
    mov rcx, 100
    mov [rsp], rcx
    fild qword [rsp]
    fmulp
    fstp qword [rsp]
    movsd xmm0, qword [rsp]
    add rsp, 8
    mov rdi, PRINT_CP           ; float in xmm0
    call printf
    call print_div
    mov rax, 60                 ; return 0
    xor rdi, rdi
    syscall

print_div:
    push rdi
    push rsi
    add rsp, 8
    mov rdi, STR_PERC
    mov rsi, DIV_LN
    call printf
    sub rsp, 8
    pop rsi
    pop rdi
    ret

gen_str:
    ; rdi = TST_INCL/EXCL
    push rdi
    push rbx
    push r12
    lea rbx, [rdi+1]
    lea r12, TST_LEN-1
    gen_str_loop:
        call rand
        mov rcx, BYTE_MAX       ; rdx = rand() % 256
        xor rdx, rdx
        div rcx
        mov [rbx], dl
        inc rbx
        dec r12
        test r12, r12
        jnz gen_str_loop
    pop r12
    pop rbx
    pop rdi
    ret

zero_filter:
    lea rax, [FILTER]
    mov rcx, 50000
    zero_loop:
        mov qword [rax], 0
        add rax, 8
        dec rcx
        test rcx, rcx
        jnz zero_loop
    ret

murmur3:
    ; rdi = u8* str
    ; rsi = u32 len
    ; rdx = u32 seed
    push rdi
    push rsi
    mov r8, rdx                 ; r8 = h
    mov r11, rsi
    shr r11, 2
    murmur3_chunks:
        mov eax, dword [rdi]    ; eax = k
        mov ecx, 0xcc9e2d51 
        mul ecx                 ; murmur xorshift
        mov r9d, eax
        shl eax, 15
        shr r9d, 17
        or eax, r9d
        xor r8d, eax
        mov r9d, r8d
        shl r8d, 13
        shr r9d, 19
        or r8d, r9d
        mov eax, r8d
        mov ecx, 5
        mul ecx
        add eax, 0xe6546b64
        mov r8d, eax
        add rdi, 4              ; loop
        dec r11                 
        test r11, r11
        jnz murmur3_chunks
    mov eax, 0
    mov r11, rsi
    and r11, 3
    lea rdi, [rdi+r11-1]
    test r11, r11
    jz murmur3_end              ; skip if no leftover
    murmur3_leftovers:
        mov al, byte [rdi]
        shl eax, 8
        dec rdi
        dec r11
        test r11, r11
        jnz murmur3_leftovers
    murmur3_end:
    mov ecx, 0xcc9e2d51 
    mul ecx
    mov r9d, eax
    shl eax, 15
    shr r9d, 17
    or eax, r9d
    mov ecx, 0x1b873593
    mul ecx         
    xor eax, r8d                ; accumulate in rax
    xor eax, esi
    mov r9d, eax
    shr r9d, 16
    xor eax, r9d
    mov ecx, 0x85ebca6b 
    mul ecx
    mov r9d, eax
    shr r9d, 13
    xor eax, r9d
    mov ecx, 0xc2b2ae35 
    mul ecx
    mov r9d, eax
    shr r9d, 16
    xor eax, r9d                ; final 32b hash in eax
    pop rsi
    pop rdi
    ret

filter_insert:
    ; rdi = str
    ; rsi = len
    push rdi
    push rsi
    call murmur3
    xor rdx, rdx
    mov ecx, BIT_NUM
    div ecx
    mov eax, edx                ; edx = eax%3200000
    push rax                    ; align stack
    mov rdx, SHA_OUT
    call SHA256
    pop rax                     ; restore stack & rax
    pop rsi
    pop rdi
    mov r8d, eax
    mov eax, dword [SHA_OUT]
    mov ecx, BIT_NUM
    xor rdx, rdx
    div ecx
    mov r9d, edx                ; edx = SHA_OUT%3200000
    mov eax, r8d                ; insert hash 1          
    mov ecx, LL_SIZE
    xor rdx, rdx                ; 0 rdx
    div ecx                     ; ax = ax/64, dx = ax%64
    lea rax, [FILTER+(eax*8)]
    mov r10, 1
    mov ecx, edx
    shl r10, cl
    or [rax], r10
    mov eax, r9d                ; insert hash 2
    mov ecx, LL_SIZE
    xor rdx, rdx
    div ecx
    lea rax, [FILTER+(eax*8)]
    mov r10, 1
    mov ecx, edx
    shl r10, cl
    or [rax], r10
    mov r11, 0                  ; run hash gauntlet
    insert_nhash:   
        mov eax, r9d
        mul r11
        add eax, r8d
        mov ecx, BIT_NUM
        xor rdx, rdx
        div ecx                 ; keep hash within bloom filter      
        mov eax, edx
        mov ecx, LL_SIZE
        xor rdx, rdx
        div ecx                 ; div 64
        lea rax, [FILTER+(eax*8)]
        mov r10, 1
        mov ecx, edx
        shl r10, cl
        or [rax], r10
        inc r11                 ; loop
        cmp r11, HASH_ADD
        jne insert_nhash
    ret

filter_count:
    ; rdi = str
    ; rsi = len
    push rdi
    push rsi
    call murmur3
    mov ecx, BIT_NUM
    xor rdx, rdx
    div ecx
    mov eax, edx
    push rax
    mov rdx, SHA_OUT
    call SHA256
    pop rax
    pop rsi
    pop rdi
    mov r8d, eax
    mov eax, dword [SHA_OUT]
    mov ecx, BIT_NUM
    xor rdx, rdx
    div ecx
    mov r9d, edx
    mov eax, r8d                ; check hash 1
    mov ecx, LL_SIZE
    xor rdx, rdx
    div ecx
    lea rax, [FILTER+(eax*8)]
    mov r10, 1
    mov ecx, edx
    shl r10, cl
    test [rax], r10             ; | check presence of bit
    jz count_0
    mov eax, r9d                ; check hash 2
    mov ecx, LL_SIZE
    xor rdx, rdx
    div ecx
    lea rax, [FILTER+(eax*8)]
    mov r10, 1
    mov ecx, edx
    shl r10, cl
    test [rax], r10
    jz count_0
    mov r11, 0                  ; run hash gauntlet
    check_nhash:
        mov eax, r9d
        mul r11d
        add eax, r8d
        mov ecx, BIT_NUM
        xor rdx, rdx
        div ecx
        mov eax, edx
        mov ecx, LL_SIZE
        xor rdx, rdx
        div ecx
        lea rax, [FILTER+(eax*8)]
        mov r10, 1
        mov ecx, edx            ; shift uses cl
        shl r10, cl
        test [rax], r10
        jz count_0              ; | check all nhashes
        inc r11
        cmp r11, HASH_ADD
        jne check_nhash
    ; flow here
    mov rax, 1
    ret
    ; jump here
    count_0:
    mov rax, 0
    ret
