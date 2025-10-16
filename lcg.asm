%include "std321.inc"
extern ExitProcess

global start

section .text
start:
write_str   [REL startmsg], startmsglen

;; How many numbers should we generate?
read_int    [REL repsmsg], repsmsglen
;; Bet that the user didn't actually ask for more than 2 ** 32 repetitions
mov         ecx, eax

;; Verify the number was read (for testing only)
;; write_int   ecx, [REL repsmsg], repsmsglen

mov         rax, [REL SEED]
mov         rdx, [REL A]
mov         r8, [REL C]
mov         r9, [REL M]

startloop:
    push        rcx                 ;; Push the loop counter
    mov         rcx, rax            ;; Seed value to RCX
    sub         rsp, 32             ;; Create shadow space
    call        lcg
    add         rsp, 32             ;; Dump shadow space
    ;; Seed in RAX, A in RDX, C in R8, M in r9

    ;; Push the volatile registers
    push        r9
    push        r8
    push        rdx
    push        rax
    write_int   rax, [REL outmsg], outmsglen
    ;; Restore the volatile registers
    pop         rax
    pop         rdx
    pop         r8
    pop         r9
    ;; Pull the count back
    pop         rcx

    loop        startloop


;; Return code 0 for normal completion
mov   ECX, dword 0                             ; Produces 0 for the return code
call  ExitProcess


;; Arguments: seed (RCX), A (RDX), C (R8), M (R9)

lcg:
    ;; Entry code
    ;; Arguments to shadow space (not strictly necessary here, but...)
    ParamsToShadow
    ;; Establish stack frame, if needed.  (In this case, it isn't.)
    ;; Space for local variables, if needed.  (In this case, they aren't.)
    ;; Push any non-volatile registers we use.  (We don't.)

    ;; Body code
    mov     rax, rcx    ;; Seed to RAX
    mul     rdx         ;; Multiply.  Result fits in RAX.  RDX := 0.
    add     rax, r8     ;; RAX += C
    div     r9          ;; RAX /= M, RDX = RAX % M

    ;; Exit code
    mov     rax, rdx    ;; Return value into RAX
    ;; Pop any non-volatile registers.  (None in this case.)
    ;; Get rid of the stack frame, if there was one.  (In this case, there wasn't.)
    ;; Restore the parameter that got changed.  None of the others were changed.
    mov     rdx, [rsp+16]
    ret

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
repsmsg     db      "How many pseudo-random numbers would you like? "
repsmsglen  EQU     $-repsmsg
outmsg      db      "Number: "
outmsglen   EQU     $-outmsg
