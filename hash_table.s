extern strdup

section .text

global default_hash_func

default_hash_func:
    push rbp
    mov rbp,rsp
    xor rax,rax
    cmp rdi,0x0
    je end_hash_func
    mov rax,0x1505
    xor r8,r8
    xor r9,r9
hash_func_loop:
    mov r8b,[rdi + r9]
    cmp r8b,0x0
    je end_hash_func
    mov r10,rax
    shl rax,0x5
    add rax,r10
    add rax,r8
    inc r9
    jmp hash_func_loop
end_hash_func:
    pop rbp
    ret


shash_table_insert:
    push rbp
    mov rbp,rsp
    mov r8,[rdi + 8]
    push rdi
    mov rdi,rsi
    call r8
    pop rdi
    push rdx ;save the 3rd argument
    mov r8,[rdi + 24]
    div r8 ;div rax/HASH_CAPACITY
    push rdx ;save reminder
    call strdup wrt .. plt
    