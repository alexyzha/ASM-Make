section .data
; FILE
    OUTFILE     db      'outfile.txt', 0
    INFILE      db      'infile.txt', 0
    FILE_RD     db      'r', 0

; PRINT
    SPC_PRNT    db      0x20, 0
    NLN_PRNT    db      0xA, 0
    STR_PERC    db      '%s', 0xA, 0
    INT_PERC    db      '%d', 0xA, 0
    INT_PNNL    db      '%d', 0
    INT_SPC     db      '%d', 0x20, 0
    FLT_PERC    db      '%f', 0xA, 0

; DIRS
    DIR         dd      4, -1, -4, 1
    UP          dd      0, 1, 2, 3
    RIGHT       dd      3, 7, 11, 15
    DOWN        dd      12, 13, 14, 15
    LEFT        dd      0, 4, 8, 12
    BASE        dq      UP, RIGHT, DOWN, LEFT

; BOT BASE + CONSTS
    MAX_P2      equ     15
    NUM_TPL     equ     17
    ALPHA       equ     25
    ADIV        equ     1000
    BOUND1      equ     9999
    BOUND2      equ     999
    BOUND3      equ     99
    BOUND4      equ     9
    MASK_ON     equ     0x80000000
    MASK_OFF    equ     0x7fffffff

section .bss
    tuple       resq    17
    config      resq    17
    board       resd    16              ; game board (shared with bot)
    bot_ast     resd    16              ; bot afterstate
    gam_ast     resd    16              ; game afterstate
    templn      resd    4               ; vector subsitute
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

    mov rbx, 0                          ; seed board
    mov rcx, 2
    LOOP:
        mov dword [board+(rbx*4)], ecx
        inc rbx
        cmp rbx, 16
        jne LOOP

    mov rdi, board                      ; setw(x) test SPECIFIC FOR THIS SCENARIO
    call print_board

    mov rdi, board                      ; mov up
    mov rsi, 0
    call sim_move
    mov rdi, INT_PERC
    mov rsi, rax
    call printf
    mov rdi, board
    call print_board

    mov rdi, board                      ; mov right
    mov rsi, 1
    call sim_move
    mov rdi, INT_PERC
    mov rsi, rax
    call printf
    mov rdi, board
    call print_board

    mov rdi, board                      ; mov down
    mov rsi, 2
    call sim_move
    mov rdi, INT_PERC
    mov rsi, rax
    call printf
    mov rdi, board
    call print_board

    mov rdi, board                      ; mov left
    mov rsi, 3
    call sim_move
    mov rdi, INT_PERC
    mov rsi, rax
    call printf
    mov rdi, board
    call print_board

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
    sub rsp, 8                          ; piss ass windows
    push rbx
    push r12
    xor rbx, rbx
    mov r12, rdi
    mov rdi, NLN_PRNT
    call printf
    mov rdi, r12
    print_all:
        sub rsp, 8                      ; who doesn't love stack alignment
        push rdi
        mov r12d, dword [rdi+(rbx*4)]
        cmp r12d, BOUND4
        jg print_sp3
        mov rdi, SPC_PRNT
        call printf
        print_sp3:
            cmp r12d, BOUND3
            jg print_sp2
            mov rdi, SPC_PRNT
            call printf
        print_sp2:
            cmp r12d, BOUND2
            jg print_sp1
            mov rdi, SPC_PRNT
            call printf
        print_sp1:
            cmp r12d, BOUND1
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
            add rsp, 8
            inc rbx
            cmp rbx, 16
            jne print_all
    mov rdi, NLN_PRNT
    call printf
    pop r12
    pop rbx
    add rsp, 8
    ret

v_ofstate:
    ; rdi = board, rsi = delta? 1/0
    ; xmm0 = delta
    ; returns xmm0 = avg v score from all tpl
    push rbx
    sub rsp, 8
    mov rbx, ALPHA                      ; wah wah cant load from register
    mov qword [rsp], rbx                ; wah wah i need to load from memoy
    fild qword [rsp]                    ; wah wah
    mov rbx, ADIV
    mov qword [rsp], rbx
    fild qword [rsp]
    fdivp
    fstp qword [rsp]
    movsd xmm2, qword [rsp]
    mulsd xmm0, xmm2
    add rsp, 8                          ; if it works it works ig
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
            jz key_done
            bsr rbx, rbx                ; log2
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

sim_move:
    ; rdi = dest, rsi = dir
    ; return rax = score
    push rbx
    push r12
    xor rax, rax
    xor rbx, rbx
    sim_move_outer:
        push rdi                        ; this sucks
        push rsi
        push rax
        mov rdi, templn
        xor rsi, rsi
        mov rdx, 16
        call memset
        pop rax
        pop rsi
        pop rdi
        xor r8, r8                      ; vec back
        xor r12, r12
        sim_move_inner:
            mov rcx, qword [BASE+(rsi*8)]     ; base[action]
            mov ecx, dword [rcx+(rbx*4)]      ; base[action][i]
            mov edx, dword [DIR+(rsi*4)]      ; dir[action]
            imul edx, r12d                    ; j*dir[action]
            add ecx, edx                      ; corr cur ind in line
            mov edx, dword [board+(rcx*4)]    ; edx = board[index]
            test edx, edx
            jz sim_move_inner_next
            test r8, r8                       ; nothing to combine
            jz sim_move_pb_normal
            dec r8
            mov r9d, dword [templn+(r8*4)]
            inc r8
            cmp r9d, edx                      ; combine if eq 
            jne sim_move_pb_normal
            dec r8
            shl edx, 1                        ; merge tile
            add eax, edx                      ; add score
            or edx, MASK_ON                   ; mask 0x80...
            sim_move_pb_normal:
                mov dword [templn+(r8*4)], edx
                inc r8
            sim_move_inner_next:              ; next row/col
                inc r12
                cmp r12, 4
                jne sim_move_inner
        xor r12, r12
        sim_move_inner_pln:
            mov rcx, qword [BASE+(rsi*8)]
            mov ecx, dword [rcx+(rbx*4)]      ; base[action][i]
            mov edx, dword [DIR+(rsi*4)]
            imul edx, r12d
            add ecx, edx                      ; ecx = index
            mov dword [rdi+(rcx*4)], 0
            cmp r12, r8
            jge sim_move_inner_pln_done
            mov edx, dword [templn+(r12*4)]   ; edx = line[j]
            and edx, MASK_OFF
            mov dword [rdi+(rcx*4)], edx      ; afterstate[index] = line[j] if j < line.size()
            sim_move_inner_pln_done:
                inc r12
                cmp r12, 4
                jne sim_move_inner_pln
        inc rbx
        cmp rbx, 4
        jne sim_move_outer
    pop r12
    pop rbx
    ret


