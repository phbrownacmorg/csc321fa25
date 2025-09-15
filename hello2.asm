STD_OUTPUT_HANDLE   EQU -11

extern ExitProcess
extern GetStdHandle                             ; Import external symbols
extern WriteFile  

global start

section .text
start:

;; Get the standard output handle
sub     rsp, 32                 ; Make space on the system stack
mov     rcx, STD_OUTPUT_HANDLE  ; Put the function argument into RCX
call    GetStdHandle
mov     [REL StdOutHandle], rax ; Put the returned handle into StdOutHandle
add     rsp, 32                 ; Get rid of the extra space on the system stack

sub     rsp, 8                  ; Make space for a local variable on the stack
sub     rsp, (32 + 8 + 8)       ; Shadow space, leaving room for the fifth 
                                ; parameter and 8 more bytes for 16-byte alignment.
mov     rcx, rax                ; RCX := handle
mov     rdx, message            ; RDX := address of string
mov     r8, 13                  ; Length of string in bytes
lea     r9, [rsp + 48]          ; Address of local variable in which to write
                                ; the number of bytes
mov     qword [rsp + 32], 0     ; Fifth parameter is NULL 
call    WriteFile               ; Output can be redirected to a file using >
add     rsp, 48                 ; Get rid of stack space
add     rsp, 8                  ; Remove the space for the local variable

;; Return code 0 for normal completion
mov   ECX, dword 0                             ; Produces 0 for the return code
call  ExitProcess

section .data
message:
db      "Hello, world", 10

StdOutHandle    dq  0