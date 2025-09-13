extern strdup
extern malloc
extern memset
extern free

SHASH_TABLE_CAPACITY: equ 0x2710

section .text

global default_hash_func
global shash_table_insert
global shash_table_find
global shash_table_init
global shash_table_clear

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
    mov r8,[rdi + 8] ;load the pointer to the function
    push rdi
    mov rdi,rsi
    call r8 ;call the hash function
    pop rdi
    mov r9,rdx ;save the 3rd argument
    mov rcx,[rdi + 16]
    xor rdx,rdx
    div rcx ;div rax/HASH_CAPACITY
    push rdx ;save reminder
    push rdi ;save hash_table pointer
    mov rdi,r9
    call strdup wrt ..plt
    pop rdi
    pop r8 ;get back index of key to insert
    mov r9, [rdi] ;store the table pointer
    lea r9,[r9 + r8*8]
    mov [r9], rax ;store the value at index
    mov rsp,rbp
    pop rbp
    ret

;rdi stores the pointer to the hash table, rsi the key to find
shash_table_find:
    push rbp
    mov rbp,rsp
    mov r8,[rdi + 8]
    push rdi
    mov rdi,rsi
    call r8 ;get hash value of key passed
    pop rdi
    xor rdx,rdx
    mov rcx,[rdi + 16] ;/get capacity of the hash table
    div rcx ;rdx stores the reminder of hash/capacity
    mov rax,[rdi] ;load the table pointer
    lea rax,[rax + rdx * 8]
    mov rax,[rax]
    pop rbp
    ret

shash_table_init:
    push rbp
    mov rbp,rsp
    cmp rdi,0x0
    je init_fail
    cmp rsi,0x0
    je  assign_default_func
    mov [rdi + 8], rsi
    jmp assign_capacity
assign_default_func:
    lea rax,[rel default_hash_func]
    mov qword [rdi + 8], rax
assign_capacity:
    cmp rdx,0x0
    je  assign_default_capacity
    mov [rdi + 16], rdx
    jmp allocate_mem
assign_default_capacity:
    mov qword [rdi + 16],SHASH_TABLE_CAPACITY
allocate_mem:
    push rdi
    mov rdi,[rdi + 16]
    shl rdi,0x3
    call malloc wrt ..plt
    cmp rax,0x0
    je init_fail
    pop rdi
    mov [rdi],rax
    mov qword [rdi + 24], 0x0
    mov rdx,[rdi + 16]
    shl rdx,0x3
    mov rdi,[rdi]
    xor rsi,rsi
    call memset wrt ..plt
    mov eax,0x1
    jmp end_shash_init
init_fail:
    mov eax,0x0
end_shash_init:
    mov rsp,rbp
    pop rbp
    ret

;function to free the memory used in the table and set everything else to 0
;only parameter is the table pointer 
shash_table_clear:
    push rbp
    mov rbp,rsp
    cmp rdi,0x0
    je end_shash_clear
    xor rax,rax
    mov r8,rdi
shash_loop:
    cmp rax,[r8 + 16]
    je loop_end
    mov rdi,[r8]
    lea rdi,[rdi + rax * 8]
    mov rdi,[rdi]
    inc rax
    cmp rdi,0x0
    je shash_loop
    push r8
    push rax
    call free wrt ..plt
    pop rax
    pop r8
    jmp shash_loop 

loop_end:
    mov qword [r8 + 8],0x0
    mov qword [r8 + 16],0x0
    mov qword [r8 + 24],0x0
    mov rdi,[r8]
    mov qword [r8],0x0
    call free wrt ..plt
end_shash_clear:
    pop rbp
    ret