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
    
    mov rdi, bot_ast
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
    mov rbx, 0
    mov rcx, 4
    LOOP2:
        mov dword [board+(rbx*4)], ecx
        add rbx, 2
        cmp rbx, 16
        jne LOOP2

    mov rdi, board                      ; setw(x) test SPECIFIC FOR THIS SCENARIO
    call print_board

    mov rdi, board
    call can_place
    mov rdi, INT_PERC
    mov rsi, rax
    call printf

    mov rdi, board
    call choose_action
    mov rdi, board
    mov rsi, rax
    call sim_move
    mov rdi, board
    call print_board

    mov rdi, board
    call can_place
    mov rdi, INT_PERC
    mov rsi, rax
    call printf

    xor rbx, rbx
    LOOP_TUAH:
        mov rdi, board
        mov rsi, 1
        call make_tile
        mov rdi, board
        call print_board
        inc rbx
        cmp rbx, 8
        jne LOOP_TUAH

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

copy_board:
    ; rdi = src, rsi = dst
    xor rcx, rcx
    copy_board_loop:
        mov edx, dword [rdi+(rcx*4)]
        mov dword [rsi+(rcx*4)], edx
        inc rcx
        cmp rcx, 16
        jne copy_board_loop
    ret

board_equal:
    ; rdi = 1, rsi = 2
    xor rcx, rcx
    xor rax, rax
    board_equal_loop:
        mov edx, dword [rdi+(rcx*4)]
        cmp edx, dword [rsi+(rcx*4)]
        jne board_equal_done
        inc rcx
        cmp rcx, 16
        jne board_equal_loop
    inc rax
    board_equal_done:
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
    ; sim_move = game_move, set dest to board
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
            mov rcx, qword [BASE+(rsi*8)]       ; base[action]
            mov ecx, dword [rcx+(rbx*4)]        ; base[action][i]
            mov edx, dword [DIR+(rsi*4)]        ; dir[action]
            imul edx, r12d                      ; j*dir[action]
            add ecx, edx                        ; corr cur ind in line
            mov edx, dword [board+(rcx*4)]      ; edx = board[index]
            test edx, edx
            jz sim_move_inner_next
            test r8, r8                         ; nothing to combine
            jz sim_move_pb_normal
            dec r8
            mov r9d, dword [templn+(r8*4)]
            inc r8
            cmp r9d, edx                        ; combine if eq 
            jne sim_move_pb_normal
            dec r8
            shl edx, 1                          ; merge tile
            add eax, edx                        ; add score
            or edx, MASK_ON                     ; mask 0x80...
            sim_move_pb_normal:
                mov dword [templn+(r8*4)], edx
                inc r8
            sim_move_inner_next:                ; next row/col
                inc r12
                cmp r12, 4
                jne sim_move_inner
        xor r12, r12
        sim_move_inner_pln:
            mov rcx, qword [BASE+(rsi*8)]
            mov ecx, dword [rcx+(rbx*4)]        ; base[action][i]
            mov edx, dword [DIR+(rsi*4)]
            imul edx, r12d
            add ecx, edx                        ; ecx = index
            mov dword [rdi+(rcx*4)], 0
            cmp r12, r8
            jge sim_move_inner_pln_done
            mov edx, dword [templn+(r12*4)]     ; edx = line[j]
            and edx, MASK_OFF
            mov dword [rdi+(rcx*4)], edx        ; afterstate[index] = line[j] if j < line.size()
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

evaluate:
    ; rdi = state, rsi = action
    ; sim_move preserves rdi/rsi
    ; return eval val in xmm0
    push rdi                            ; need stack align + also for sim move
    mov rdi, bot_ast                    ; rsi = action
    call sim_move
    pop rsi                             ; rsi = board, rdi = bot_ast
    mov r8, rax
    sub rsp, 8                          ; i cant wait for the day where i learn a better alternative to whatever tf this is
    mov rcx, -2
    mov qword [rsp], rcx
    fild qword [rsp]
    fstp qword [rsp]
    movsd xmm0, qword [rsp]
    add rsp, 8
    call board_equal
    test rax, rax
    jnz evaluate_done                    ; no move = illegal
    sub rsp, 8
    mov qword [rsp], r8                 ; r8 = sim_move score
    fild qword [rsp]
    fstp qword [rsp]
    xor rsi, rsi                        ; rdi = bot_ast, rsi = 0 (no train)
    call v_ofstate
    movsd xmm1, qword [rsp]
    add rsp, 8
    addsd xmm0, xmm1                    ; return xmm0
    evaluate_done:
        ret

choose_action:
    ; rdi = state
    push rbx
    push r12
    mov r12, rdi
    xor rbx, rbx
    sub rsp, 24                         ; +[action][best score]- both qword
    mov rax, -1
    mov qword [rsp+8], rax
    mov qword [rsp], rax
    fild qword [rsp]
    fstp qword [rsp]                    ; -40 stack -8 fxn = aligned
    choose_action_enum:
        mov rdi, r12
        mov rsi, rbx
        call evaluate
        comisd xmm0, qword [rsp]
        jbe choose_action_enum_lower
        movsd qword [rsp], xmm0
        mov qword [rsp+8], rbx
        choose_action_enum_lower:
            inc rbx
            cmp rbx, 4
            jne choose_action_enum
    mov rax, qword [rsp+8]
    add rsp, 24
    pop r12
    pop rbx
    ret

can_place:
    ; rdi = state
    xor rcx, rcx
    mov rax, 1
    can_place_iter:
        mov edx, dword [rdi+(rcx*4)]
        test edx, edx
        jz can_place_done
        inc rcx
        cmp rcx, 16
        jne can_place_iter
    xor rax, rax
    can_place_done:
        ret

rand_tile:
    sub rsp, 8
    call rand
    add rsp, 8
    mov rcx, 10
    div rcx
    mov rax, 2
    test rdx, rdx
    jnz rand_tile_done
    shl rax, 1
    rand_tile_done:
        ret

make_tile:
    ; rdi = state, rsi = ct
    ; return void
    push rbx
    push r12                            ; stack maln need -8 more
    mov rbx, rdi                        ; rbx = rdi, r12 = rsi
    mov r12, rsi
    make_tile_iter:
        mov rdi, rbx
        call can_place
        test rax, rax
        jz make_tile_done               ; can't place any more
        sub rsp, 8
        make_tile_find:
            call rand
            mov rcx, 16
            div rcx                     ; rdx = rax%rcx
            mov ecx, dword [rbx+(rdx*4)]
            test ecx, ecx
            jnz make_tile_find          ; val exists
        mov qword [rsp], rdx            ; rdx = index = rand%16
        call rand_tile
        mov rdx, qword [rsp]
        mov dword [rbx+(rdx*4)], eax    ; set val in board
        add rsp, 8
        dec r12
        test r12, r12
        jnz make_tile_iter
    make_tile_done:
        pop r12
        pop rbx
        ret