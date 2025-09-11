%include "std321.inc"
extern ExitProcess

global start

section .text
start:

sub     rsp, 32
mov     rcx, message
mov     rdx, 13
call    std321_write_str_fn
add     rsp, 32

;; Return code 0 for normal completion
mov   ECX, dword 0                             ; Produces 0 for the return code
call  ExitProcess

section .data
message:
db      "Hello, world", 10