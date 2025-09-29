%include "std321.inc"
extern ExitProcess

global start

section .text
start:
write_str   [REL startmsg], startmsglen

;; Return code 0 for normal completion
mov   ECX, dword 0                             ; Produces 0 for the return code
call  ExitProcess

section .data
startmsg    db      "This program illustrates a chaotic function", 10
startmsglen EQU     $-startmsg