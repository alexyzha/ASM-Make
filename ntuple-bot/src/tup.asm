section .data
    OUTFILE     db      'outfile.txt', 0
    INFILE      db      'infile.txt', 0
    SPC_PRNT    db      0x20, 0
    NLN_PRNT    db      0xA, 0
    STR_PERC    db      '%s', 0xA, 0
    INT_PERC    db      '%d', 0xA, 0
    INT_PNNL    db      '%d', 0
    INT_SPC     db      '%d', 0x20, 0
    FLT_PERC    db      '%f', 0xA, 0
    FILE_RD     db      'r', 0
    MAX_P2      equ     15
    NUM_TPL     equ     17
    ALPHA       equ     25
    ADIV        equ     1000
    BOUND1      equ     999
    BOUND2      equ     99
    BOUND3      equ     9

section .bss
    tuple       resq    17
    config      resq    17
    board       resd    16              ; game board (shared with bot)
    bot_ast     resd    16              ; bot afterstate
    gam_ast     resd    16              ; game afterstate
    fileh       resq    1

section .text
    global _start
    extern fopen
    extern fscanf
    extern fclose
    extern printf
    extern malloc
    extern memset
    extern free
    extern rand

_start:
    finit                               ; :|
    mov rdi, tuple                      ; init tuple
    call init_tuples
    mov rdi, INFILE                     ; init tpl config
    mov rsi, config
    call init_config

    mov rdi, board
    mov rsi, 0
    mov rdx, 64
    call memset

    mov rbx, 0
    mov rcx, 8192
    LOOP:
        mov dword [board+(rbx*4)], ecx
        inc rbx
        cmp rbx, 17
        jne LOOP


    mov rdi, board                      ; setw(x) test SPECIFIC FOR THIS SCENARIO
    call print_board


    sub rsp, 8
    fld1
    fld1
    faddp
    fstp qword [rsp]
    movsd xmm0, qword [rsp]
    add rsp, 8
    mov rbx, 0
    mov rcx, 15
    imul rcx, rcx
    imul rcx, rcx
    dec rcx
    LOOP2:
        mov rax, qword [tuple+(rbx*8)]
        movsd qword [rax+(rcx*8)], xmm0
        inc rbx
        cmp rbx, 17
        jne LOOP2
    mov rdi, board
    mov rsi, 1
    movsd xmm3, xmm0
    call v_ofstate                      ; HOLY SHIT VSTATE WORKS 1ST TRY LESGO
    mov rdi, FLT_PERC                   ; withupdate works
    call printf

    mov rdi, board                      ; noupdate works too
    mov rsi, 0
    movsd xmm0, xmm3
    call v_ofstate
    mov rdi, FLT_PERC
    call printf

    mov rdi, tuple                      ; clean tuple
    call delete_tuples
    mov rdi, config                     ; clean tpl config
    call delete_config
    mov rax, 60
    xor rdi, rdi
    syscall

init_tuples:
    ; rdi = tpl
    push rbx
    mov rbx, NUM_TPL
    init_tpl_loop:
        dec rbx
        push rdi
        mov rdi, MAX_P2
        imul rdi, rdi
        imul rdi, rdi                   ; rdi^4
        shl rdi, 3                      ; rdi^4 * 8
        call malloc
        mov rdi, qword [rsp]
        mov qword [rdi+(rbx*8)], rax
        mov rdi, rax                    ; memset(a,0,sizeof(a))
        mov rsi, 0
        mov rdx, MAX_P2
        imul rdx, rdx
        imul rdx, rdx
        shl rdx, 3
        call memset
        pop rdi
        test rbx, rbx
        jnz init_tpl_loop    
    pop rbx
    ret

delete_tuples:
    ; rdi = tpl
    push rbx
    mov rbx, NUM_TPL
    delete_tpl_loop:
        dec rbx
        push rdi
        mov rdi, qword [rdi+(rbx)*8]
        call free
        pop rdi
        test rbx, rbx
        jnz delete_tpl_loop
    pop rbx
    ret

init_config:
    ; rdi = infile, rsi = config
    push rsi
    mov rsi, FILE_RD
    call fopen
    pop rsi
    test rax, rax
    jz init_config_ret
    mov qword [fileh], rax
    push rbx
    push r12
    push r13
    mov r13, rsi
    mov rbx, NUM_TPL
    init_cfg_loop:
        dec rbx
        mov rdi, 32
        call malloc
        mov qword [r13+(rbx*8)], rax ; make cfg arr
        mov r12, 0
        cfg_tpl_loop:
            mov rdi, qword [fileh]
            mov rsi, INT_SPC
            mov rdx, qword [r13+(rbx*8)]
            lea rdx, qword [rdx+(r12*8)]
            call fscanf
            inc r12
            cmp r12, 3
            jne cfg_tpl_loop
        mov rdi, qword [fileh]
        mov rsi, INT_PERC
        mov rdx, qword [r13+(rbx*8)]
        lea rdx, qword [rdx+(r12*8)]
        call fscanf        
        test rbx, rbx
        jnz init_cfg_loop
    mov rdi, qword [fileh]              ; close file
    call fclose
    mov qword [fileh], 0
    pop r13
    pop r12
    pop rbx
    init_config_ret:
        ret

print_config:
    ; rdi = config
    push rbx
    push r12
    mov rbx, NUM_TPL
    print_cfg_loop:
        dec rbx
        mov r12, 0
        pcfg_tpl_loop:
            push rdi
            mov rsi, [rdi+(rbx*8)]
            mov rsi, qword [rsi+(r12*8)]
            mov rdi, INT_SPC
            call printf
            pop rdi
            inc r12
            cmp r12, 3
            jne pcfg_tpl_loop
        push rdi
        mov rsi, [rdi+(rbx*8)]
        mov rsi, qword [rsi+(r12*8)]
        mov rdi, INT_PERC
        call printf
        pop rdi
        test rbx, rbx
        jnz print_cfg_loop
    pop r12
    pop rbx
    ret

delete_config:
    ; rdi = cfg
    push rbx
    mov rbx, NUM_TPL
    delete_cfg_loop:
        dec rbx
        push rdi
        mov rdi, qword [rdi+(rbx*8)]
        test rdi, rdi
        jz skip_del_cfg
        call free
        skip_del_cfg:
        pop rdi
        test rbx, rbx
        jnz delete_cfg_loop
    pop rbx
    ret

print_board:
    ; rdi = board
    push rbx
    push r12
    xor rbx, rbx
    mov r12, rdi
    mov rdi, NLN_PRNT
    call printf
    mov rdi, r12
    print_all:
        push rdi
        mov r12d, dword [rdi+(rbx*4)]
        cmp r12d, 9
        jg print_sp3
        mov rdi, SPC_PRNT
        call printf
        print_sp3:
            cmp r12d, 99
            jg print_sp2
            mov rdi, SPC_PRNT
            call printf
        print_sp2:
            cmp r12d, 999
            jg print_sp1
            mov rdi, SPC_PRNT
            call printf
        print_sp1:
            cmp r12d, 9999
            jg print_num
            mov rdi, SPC_PRNT
            call printf
        print_num:
            mov rdi, INT_PNNL
            mov esi, r12d
            call printf
        mov rax, rbx                    ; check if end of row
        inc rax
        mov rcx, 4
        div rcx
        test rdx, rdx
        jnz same_row                    ; i%4 != 0
        mov rdi, NLN_PRNT
        call printf
        same_row:
            pop rdi
            inc rbx
            cmp rbx, 16
            jne print_all
    mov rdi, NLN_PRNT
    call printf
    pop r12
    pop rbx
    ret

v_ofstate:
    ; rdi = board, rsi = delta? 1/0
    ; xmm0 = avg v score from all tpl
    push rbx
    movsd xmm1, xmm0                    ; xmm1 = delta*alpha 
    pxor xmm0, xmm0                     ; accumulator
    mov rcx, NUM_TPL
    v_tuples:
        dec rcx
        mov rdx, 4                      ; get key(state,tpl)
        xor rax, rax
        mov r8, qword [config+(rcx*8)]  ; p->cfg[i]
        v_keygen:
            dec rdx
            mov rbx, qword [r8+(rdx*8)] ; config num
            mov ebx, dword [rdi+(rbx*4)]; get board val
            test rbx, rbx
            bsr rbx, rbx                ; log2
            jmp key_done
            key_zero:
                xor rbx, rbx
            key_done:                   ; rbx = log2(board[config[i][j]])
            imul rax, rax, 15
            add rax, rbx
            test rdx, rdx
            jnz v_keygen
        mov r8, qword [tuple+(rcx*8)]
        test rsi, rsi                   ; + 0.0 == skip, may del
        jz no_update
        movsd xmm2, qword [r8+(rax*8)]
        addsd xmm2, xmm1
        movsd qword [r8+(rax*8)], xmm2
        no_update:
        addsd xmm0, qword [r8+(rax*8)]  ; += tuple[i][key]
        test rcx, rcx
        jnz v_tuples
    sub rsp, 8
    mov rbx, NUM_TPL
    mov qword [rsp], rbx
    fild qword [rsp]
    fstp qword [rsp]
    movsd xmm1, qword [rsp]
    add rsp, 8
    divsd xmm0, xmm1                    ; average
    pop rbx
    ret