IDEAL
MODEL small
STACK 100h

DATASEG

arr dw 10, 0, 50, 8901

CODESEG
include "utils\print.asm"

start:
mov ax, @data
mov ds, ax

push offset arr
push 4
call printArrHex
call cls

exit:
mov ax, 4c00h
int 21h
END start