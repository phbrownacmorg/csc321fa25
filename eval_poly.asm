%include "std321.inc"
extern ExitProcess

global start

section .text
start:
    ;; Read x
    read_int    [REL xmsg], xmsglen
    mov         [REL x], rax
    write_int   rax, [REL echomsg], echomsglen

    ;; Read deg
    read_int    [REL degmsg], deglen
    mov         [REL deg], rax
    write_int   rax, [REL echomsg], echomsglen

    ;; Read the coefficients, pushing them on the stack as we go
    mov         rcx, [REL deg]
    inc         rcx
    read_loop:
        push rcx
        read_int    [REL amsg], amsglen
        pop rcx
        push rax                        ;; Coefficient goes on the stack
        loop    read_loop

    ;; All coefficients are on the stack, with a[n] at the bottom (hanging
    ;; stack) and a[0] at the top

    ;; Am I going to have alignment issues here?

    mov     rcx, [REL deg]
    mov     rdx, [REL x]
    mov     r8,  [rsp]      ; a[n]
    mov     r9,  [rsp+8]    ; a[n-1]
    sub     rsp, 16         ; Only make half the normal shadow space, because
                            ; parameters 3 and 4 are already on the stack in their proper places
    call    eval_poly
    add     rsp, 16         ; Get rid of the half-shadow space

    ;; Need to pop all the a[i]'s off the stack
    mov     rcx, [REL deg]
    inc     rcx             ;; RCX now has the number of coefficients
    sal     rcx, 3          ;; RCX = RCX * 8
    add     rsp, rcx        ;; Removes all the coefficients from the stack

    write_int   rax, [REL evalmsg], evalmsglen 

;; Return code 0 for normal completion
mov   ECX, dword 0                             ; Produces 0 for the return code
call  ExitProcess

;; Function eval_poly:
;; First argument is the degree, second argument is X, third arg is a[n], fourth arg is a[n-1],
;;    and the rest of the coefficients are on the stack as a[n-2], a[n-1], ... a[1], a[0].
;; Evaluation is done by Horner's rule.
eval_poly:
    ParamsToShadow
    ;; Degree   [rsp+8], rcx
    ;; x        [rsp+16], rdx
    ;; a[n]     [rsp+24], r8
    ;; a[n-1]   [rsp+32], r9
    ;; a[n-2]   [rsp+40]
    ;; a[n-i]   [rsp+ 8*i + 24]  for 0 <= i <= Degree

    ;; rsp+8*i+24   r8

    ;; Degree is already in RCX
    inc         rcx
    lea         r8, [rsp+24] ;; Address of a[n]
    mov         rax, [r8]  ;; RAX := a[n]
    jmp         .loop_test

    .eval_loop:
        imul    rdx             ;; Blithely assume no overflow into RDX
        mov     rdx, [rsp+16]   ;; mul wiped RDX.  RDX := X
        add     r8, 8           ;; R8 := Address of a[i-1]
        add     rax, [r8]
    .loop_test:
        loop    .eval_loop
    ret

section .bss
x       resq    1
deg     resq    1   ;; Really better keep to deg <= 255

section .data
xmsg        db      "Please enter the value of x at which to evaluate: "
xmsglen     EQU     $-xmsg
degmsg      db      "Please enter the degree of the polynomial: "
deglen      EQU     $-degmsg
amsg        db      "Please enter the next coefficient, starting from a[0]: "
amsglen     EQU     $-amsg
echomsg     db      "The number read was: "
echomsglen  EQU     $-echomsg
evalmsg     db      "The polynomial evaluated to: "
evalmsglen  EQU     $-evalmsg
