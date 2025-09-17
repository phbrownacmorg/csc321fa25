%include "std321.inc"
extern ExitProcess

global start

section .text
start:

sub     rsp, 32         ; Make space on the stack
mov     rcx, message    ; Put the address of the message in RCX
mov     rdx, 13         ; Put the length (in bytes) in RDX
call    std321_write_str_fn
add     rsp, 32         ; Get rid of the stack space

;; Return code 0 for normal completion
mov   ECX, dword 0                             ; Produces 0 for the return code
call  ExitProcess

section .data
message:
db      "Hello, world", 10