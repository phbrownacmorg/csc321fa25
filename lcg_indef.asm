%include "std321.inc"
extern ExitProcess

global start



section .text
start:
write_str   [REL startmsg], startmsglen

mov         rax, [REL SEED]

startloop:
    mul         qword [REL A]       ;; result fits in RAX, RDX := 0
    add         rax, [REL C]
    div         qword [REL M]       ;; modulus is in RDX
    push        rdx                 ;; save the random value on the stack    
    write_int   rdx, [REL outmsg], outmsglen
    read_str    [REL repmsg], repmsglen, [REL response]
    pop         rax                 ;; Restore the random value to RAX

    ;; Compare the first character of the response to 'Y'
    mov         dl, [REL response]
    and         dl, 11011111b  ;; Make it case-insensitive
    cmp         dl, 'Y'
    jz          startloop  ;; Jump back if response started with 'Y'


;; Return code 0 for normal completion
mov   ECX, dword 0                             ; Produces 0 for the return code
call  ExitProcess

section .bss
response    RESB    MAX_STRING_LENGTH+2

section .data
;; Constants
SEED    dq     001001011110110b
;; Constants from Visual C++
;; Results in bits 16-30
M       dq     80000000h
A       dq     343FDh
C       dq     269EC3h

startmsg    db      "This program implements a linear congruential generator", 10
startmsglen EQU     $-startmsg
repmsg      db      "Generate another? (Y/N) "
repmsglen   EQU     $-repmsg
outmsg      db      "Number: "
outmsglen   EQU     $-outmsg
