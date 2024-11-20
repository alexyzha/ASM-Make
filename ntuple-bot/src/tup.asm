section .data
    OUTFILE     db      'outfile.txt', 0
    INFILE      db      'infile.txt', 0
    STR_PERC    db      '%s', 0xA, 0
    INT_PERC    db      '%d', 0xA, 0
    INT_SPC     db      '%d', 0x20, 0
    FLT_PERC    db      '%f', 0xA, 0
    FILE_RD     db      'r', 0
    MAX_P2      equ     15
    NUM_TPL     equ     17
    ALPHA       equ     25
    ADIV        equ     1000

section .bss
    tuple       resq    17
    config      resq    17
    board       resd    16
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
    mov rdi, tuple
    call init_tuples

    mov rdi, INFILE
    mov rsi, config
    call init_config

    mov rdi, config
    call print_config

    mov rdi, tuple
    call delete_tuples

    mov rdi, config
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