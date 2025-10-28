%include "std321.inc"
extern ExitProcess

global start

;; Loads the number of coefficients into RCX
%macro LoadNumCoefficients  0
    mov     rcx, [REL deg]
    inc     rcx             ;; Number of coefficients is degree + 1
%endmacro

;; Copies a string from one place to another.
;; Arguments:
;; 1.  Address of source string (not REL)
;; 2.  Length of source string
;; 3.  Address of destination string
;; 4.  Offset into destination string (optional, default 0)
;; The number of bytes copied is not returned (it should be %2 anyway)
%macro strcpy   3-4         0
    ;; Push the registers used, so they can be restored later
    push    rdi
    push    rsi
    push    rcx
    ;; Load up the addresses
    lea     rsi, %1
    lea     rdi, %3
    add     rdi, %4
    mov     rcx, %2
    cld     ;; Forward!
    rep     movsb
    ;; Restore the registers
    pop     rcx
    pop     rsi
    pop     rdi
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
        push        rcx                     ;; Save RCX before messing with it
        dec         rcx
        sub         rcx, [REL deg]
        neg         rcx
        int_to_str  rcx, [REL amsg+aprelen]
        add         rax, aprelen            ;; RAX gets the combined length of the number and the pre-message
        strcpy      [REL apostmsg], apostlen, [REL amsg], rax
        add         rax, apostlen           ;; RAX now has the length of the prompt string
        read_int    [REL amsg], rax         ;; RAX gets the coefficient
        pop         rcx                     ;; Restore RCX before pushing the coefficient
        push        rax                     ;; Coefficient goes on the stack
        loop    .read_loop

    ;; All coefficients are on the stack, with a[n] at the bottom (hanging
    ;; stack) and a[0] at the top

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
apostmsg    db      "]: "
apostlen    EQU     $-apostmsg
amsg        db      "Please enter a value for a["
aprelen     EQU     $-amsg
numslot     db      0 DUP (MAX_INT_LENGTH + apostlen)
echomsg     db      "The number read was: "
echomsglen  EQU     $-echomsg
evalmsg     db      "The polynomial evaluated to: "
evalmsglen  EQU     $-evalmsg

section .bss
x       resq    1
deg     resq    1   ;; Really better keep to deg <= 255
;amsg    resb    MAX_STRING_LENGTH
;amsglen resq    1

