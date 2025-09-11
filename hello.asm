global start

section .text
start:
mov     rax, 0x02000004
mov     rdi, 1
mov     rsi, message
mov     rdx, 12
syscall
mov     rax, 0x02000001
xor     rdi, rdi            ; Quick way to zero out rdi
syscall                     ; Exit

section .data
message:
db      "Hello, world", 10