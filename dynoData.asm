IDEAL
MODEL small
STACK 100h

DATASEG

CODESEG
include "utils/print.asm"

value equ [bp + 6]
loc equ [bp + 4]
proc makeVariable
	push bp
	mov bp, sp
	push ax
	push bx

	mov ax, value
	mov bx, loc
	mov [word ptr cs:bx], ax

	pop bx
	pop ax
	pop bp
	ret 4
endp makeVariable

;variable returned in stack
loc equ [bp + 4]
proc getVariable
	push bp
	mov bp, sp
	push ax
	push bx
	
	mov bx, loc
	mov ax, [word ptr cs:bx]
	mov loc, ax
	
	pop bx
	pop ax
	pop bp
	ret
endp getVariable

start:
mov ax, @data
mov ds, ax

var1:
push 23h
call makeVariable


push word var1
call getVariable
call printHex



exit:
mov ax, 4c00h
int 21h
END start