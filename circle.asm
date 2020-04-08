IDEAL
MODEL small
STACK 100h

DATASEG


CODESEG
include "utils\graphics.asm"
start:
mov ax, @data
mov ds, ax

call toGraphics

push 100
push 100
push 50
push 10
push 2
call draw_circle

xor ah, ah
int 16h

call toText

exit:
mov ax, 4c00h
int 21h
END start