%include "std321.inc"
extern ExitProcess

NUMS_TO_PRINT EQU   15

global start

section .text
start:

write_str   [REL msg1], msg1len


mov   rcx, NUMS_TO_PRINT
numloop:
    ;; Positive
    mov         rax, NUMS_TO_PRINT
    sub         rax, rcx
    push        rcx
    write_int   rax, [REL msgN], msgNlen
    pop         rcx

    ;; Negative
    mov         rax, -NUMS_TO_PRINT
    add         rax, rcx
    push        rcx
    write_int   rax, [REL msgN], msgNlen
    pop         rcx

    ;; Big
    mov         rax, 100000000h
    sub         rax, rcx
    push        rcx
    write_int   rax, [REL msgN], msgNlen
    pop         rcx



    loop        numloop

;; Return code 0 for normal completion
mov   ECX, dword 0                             ; Produces 0 for the return code
call  ExitProcess

section .data
msg1        db      "Testing write_int", 10
msg1len     EQU     $-msg1
msgN        db      "Number: "
msgNlen     EQU     $-msgN
