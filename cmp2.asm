%include "std321.inc"
extern ExitProcess

global start

section .text
start:

;; Read one number and print it back
read_int    [REL prompt], promptlen
mov         [REL num1], rax
write_int   [REL num1], [REL label1], label1len

;; Read the second number aand print it back
read_int    [REL prompt], promptlen
mov         [REL num2], rax
write_int   rax, [REL label2], label2len

;; Compare the numbers
mov rax, [REL num1]
cmp rax, [REL num2]

;; If the first number is less, say so
    ;;; If the condition is *not* true, jump to the next case
    jge elif
    ;;; Body of the if clause 
    write_str [rel lessmsg], lesslen
    ;;; Jump to the endif (always)
    jmp endif

;; Elif the two numbers are equal, say so
elif:
    ;;; If the elif is *not* true, jump to the next case
    jne else
    ;;; Body of the elif clause 
    write_str [rel equmsg], equlen
    ;;; Jump to the endif (always)
    jmp endif

;; Else, the first number is greater.  Say so.
else:
    ;; Else => nothing to test => no jump away
    ;;; Body of the else clause 
    write_str [rel greatermsg], greaterlen
    ;; No need to jump to the end, because we're already there
endif:

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
lessmsg     db      "The first number is less than the second.", 10
lesslen     EQU     $-lessmsg
equmsg      db      "The numbers are equal.", 10
equlen      EQU     $-equmsg
greatermsg  db      "The first number is greater than the second.", 10
greaterlen  EQU     $-greatermsg