%include "std321.inc"
extern ExitProcess

global start

section .text
start:

;;; Read the first number
read_int    [REL prompt], promptlen
mov         [REL num1], rax
write_int   [REL num1], [REL label1], label1len

;;; Read the second number
read_int    [REL prompt], promptlen
mov         [REL num2], rax
write_int   rax, [REL label2], label2len

;; Do the addition.
mov         rax, [REL num1]
add         rax, [REL num2]
write_int   rax, [REL sumlabel], sumlabellen

;; Return code 0 for normal completion
mov   ECX, dword 0                             ; Produces 0 for the return code
call  ExitProcess

section .bss
num1    resq    1
num2    resq    2

section .data
prompt      db      "Please enter an integer: ", 10
promptlen   EQU     $-prompt
label1      db      "The first number is: "
label1len   EQU     $-label1
label2      db      "The second number is: "
label2len   EQU     $-label2
sumlabel    db      "The sum of the numbers is: "
sumlabellen EQU     $-sumlabel
