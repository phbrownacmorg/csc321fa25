%include "std321.inc"
extern ExitProcess

global start

section .text
start:

;; Return code 0 for normal completion
mov   ECX, dword 0                             ; Produces 0 for the return code
call  ExitProcess

section .data
message:
db      "Hello, world", 10