%include "std321.inc"
extern ExitProcess

NUMS_TO_PRINT EQU   20

global start

section .text
start:

write_str   [REL msg2], msg2len

;;; Read a number
read_int    [REL promptN], promptNlen
;;;mov         [REL num1], rax
write_int   rax, [REL msgN], msgNlen

;; 4,290,000,000 is read as 42,900,000,221
;; 4,294,967,294 is read as 42,949,673,161
;; 1,000,000,000 is read as 10,000,000,221
;; 100,000,000 is read correctly
;; 999,999,999 is read correctly
;; -999,999,999 is read as -10,000,000,211

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

write_str   [REL endmsg], endmsglen

;; Return code 0 for normal completion
mov   ECX, dword 0                             ; Produces 0 for the return code
call  ExitProcess

section .data
msg1        db      "Testing write_int", 10
msg1len     EQU     $-msg1
msg2        db      "Testing read_int", 10
msg2len     EQU     $-msg2
msgN        db      "Number: "
msgNlen     EQU     $-msgN
endmsg      db      "Testing complete.", 10
endmsglen   EQU     $-endmsg
promptN     db      "Please enter a number: "
promptNlen  EQU     $-promptN