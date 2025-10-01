%include "std321.inc"
extern ExitProcess

SEED    EQU     001001011110110b
M       EQU     80000000h
A       EQU     343FDh
C       EQU     269EC3h

global start

section .text
start:
write_str   [REL startmsg], startmsglen

;; How many numbers should we generate?
read_int    [REL repsmsg], repsmsglen
;; Bet that the user didn't actually ask for more than 32 bits of repetitions
mov         [REL repetitions], eax

;; Verify the number was read (for testing only)
;; write_int   [REL repetitions], [REL repsmsg], repsmsglen

mov         eax, SEED
mov         ecx, [rel repetitions]





;; Return code 0 for normal completion
mov   ECX, dword 0                             ; Produces 0 for the return code
call  ExitProcess


section .bss
repetitions     resd    1
random          resd    1

section .data
startmsg    db      "This program implements a linear congruential generator", 10
startmsglen EQU     $-startmsg
repsmsg     db      "How many pseudo-random numbers would you like? "
repsmsglen  EQU     $-repsmsg
