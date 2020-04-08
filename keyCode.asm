IDEAL
MODEL small
STACK 100h
DATASEG

last db 0

CODESEG
include "utils\UI.asm"
include "utils\print.asm"

start:
	mov ax,@data
	mov ds,ax
	
waitForPress:
	call keyboardData
	cmp dl, 0
	je waitForPress
	
	cmp dl, 1
	je exit
	
	cmp dl, [last]
	je waitForPress
	mov [last], dl	
	
	xor dh, dh
	
	push dx
	call printHex
	
	mov dl, 10
	mov ah, 2
	int 21h
	
	jmp waitForPress
	

exit:
mov ax,4c00h
int 21h
END start
