%include "std321.inc"
extern ExitProcess

global start

;; Loads the number of coefficients into RCX
%macro LoadNumCoefficients  0
    mov     rcx, [REL deg]
    inc     rcx             ;; Number of coefficients is degree + 1
%endmacro


;; Arguments:
;;  1.  Address of string that precedes the integer (before_string)
;;  2.  Length of before_string
;;  3.  Address of string that comes after the integer (after_string)
;;  4.  Length of after_string
;;  5.  Integer to insert
;;  6.  Address of space where I can store the result string
;;  The length of the result string is returned in RAX.
%macro  plug_int_into_str   6
    ;; Save the non-volatile registers
    push    rsi
    push    rdi

    ;; FIX ME!
    ;; Possibilities: 1.  Push all the parameters on the stack as qwords
    ;;                      and dump that space at the end.  Heavyweight but will work.
    ;;                2.  Try to save and restore the changed registers after each part,
    ;;                      in case those changed registers had parameters.  But then
    ;;                      where do I save the end (or size) of the string?
    
    ;; Save the volatile register (that might contain a parameter)
    push    rcx

    ;; Copy the before_string into the result
    xor     rdi, rdi    ;; Zero out the top half of RDI
    mov     rcx, %2
    mov     esi, %1
    mov     edi, %6
    cld
    rep     movsb



    ;; Write the number into the result
    int_to_str  %5, rdi
    ;; RDI is non-volatile, so int_to_string left it unchanged
    add     rdi, rax  ;; Add the number of bytes in the number to RDI

    ;; Copy the after_string into the result
    ;; RDI already has its address
    mov     rcx, %4
    mov     esi, %3
    cld
    rep     movsb

    ;; Put the final number of bytes into RAX
    mov     rax, rdi
    sub     rax, %6

    ;; Pop the non-volatile registers
    pop     rdi
    pop     rsi
%endmacro

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
    LoadNumCoefficients
    .read_loop:
        push rcx
        plug_int_into_str   [REL apremsg], aprelen, [REL apostmsg], apostlen, rcx, [REL amsg]
        read_int    [REL amsg], rax
        pop rcx
        push rax                        ;; Coefficient goes on the stack
        loop    .read_loop

    ;; All coefficients are on the stack, with a[n] at the bottom (hanging
    ;; stack) and a[0] at the top

    ;; Am I going to have alignment issues here?

    mov     rcx, [REL deg]
    mov     rdx, [REL x]
    mov     r8,  STACK(0)   ; a[n]
    mov     r9,  STACK(8)   ; a[n-1]
    sub     rsp, 16         ; Only make half the normal shadow space, because
                            ; parameters 3 and 4 are already on the stack in their proper places
    call    eval_poly
    add     rsp, 16         ; Get rid of the half-shadow space

    ;; Need to pop all the a[i]'s off the stack
    LoadNumCoefficients     ;; RCX now has the number of coefficients
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
    %define     Deg STACK(8)
    %define     X   STACK(16)
    %define     A_n STACK(24)
    ;; a[n-1]   STACK(32), r9
    ;; a[n-2]   STACK(40)
    ;; a[n-i]   STACK(8*i + 24)  for 0 <= i <= Degree

    ;; rsp+8*i+24   r8
    %define     Addr_A_i    r8
    %define     A_i         [r8]

    ;; Degree is already in RCX
    inc         rcx
    lea         Addr_A_i, A_n
    mov         rax, A_i
    jmp         .loop_test

    .eval_loop:
        imul    rdx             ;; RAX = RAX * X
        mov     rdx, X          ;; mul wiped RDX.  RDX := X
        add     Addr_A_i, 8     ;; R8 := Address of a[i-1]
        add     rax, A_i
    .loop_test:
        loop    .eval_loop

    ;; Remove function-local macros
    %undef  Deg
    %undef  X
    %undef  A_n
    %undef  Addr_A_i
    %undef  A_i
    ret

section .data
xmsg        db      "Please enter the value of x at which to evaluate: "
xmsglen     EQU     $-xmsg
degmsg      db      "Please enter the degree of the polynomial: "
deglen      EQU     $-degmsg
apremsg     db      "Please enter a value for a["
aprelen     EQU     $-apremsg
apostmsg    db      "]: "
apostlen    EQU     $-apostmsg
echomsg     db      "The number read was: "
echomsglen  EQU     $-echomsg
evalmsg     db      "The polynomial evaluated to: "
evalmsglen  EQU     $-evalmsg

section .bss
x       resq    1
deg     resq    1   ;; Really better keep to deg <= 255
amsg    resb    aprelen + apostlen + MAX_INT_LENGTH

