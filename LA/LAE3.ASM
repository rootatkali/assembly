IDEAL
MODEL small
STACK 100h

DATASEG

saiz equ 20
arr dw saiz dup(0)

CODESEG


siz equ [bp + 6]
ofs equ [bp + 4]
proc findMinIdx
	push bp
	mov bp, sp;Param
	push bx;save bx
	mov bx, ofs;bx = offset
	push cx;Save cx
	mov cx, siz;cx = size
	xor ax, ax;@OVERRIDE
	push dx;Save dx
	lp:;for(int i = size; i > 0; i++)
		mov dx, [bx + ax]
		cmp [bx], dx;arr[i] < tmp
		jae na
		mov ax, cx;tmp = i
		na:
	loop lp
	
	pop bx;restore registers
	pop cx
	pop dx
	ret 4;clear stack
endp findMinIdx

start:
mov ax, @data
mov dx, ax

push saiz
push offset arr
call findMinIdx

mov dx, ax;put ax in dx
mov ah, 9;print char mode
int 21h;interrupt

exit:
mov ax, 4c00h
int 21h
END start