IDEAL
MODEL small
STACK 100h

DATASEG

pipesOnScreenTimes2 equ 8

birdsize dw 15
birdx dw 50
birdy dw 100
birdyvel dw 0
last db 0
pipes dw pipesOnScreenTimes2 dup (?)
pipeIndex dw 0
pipeSpace dw 0

;TEMP
pipex dw 100
l dw 150
;\TEMP

pipeSpacing equ 1000
gameSpeed equ -1
gravity equ 1
halfPipeThickness equ 20
minGap equ 80
jumpSpeed equ -10
pipeFrequency equ 200
ScreenWidth equ 320


CODESEG
include "utils\graphics.asm"
include "utils\UI.asm"

proc drawBird
	push [birdx]
	push [birdy]
	push [birdsize]
	push 14
	call circle
	ret
endp drawBird

proc newPipe
	push dx
	push bx
	mov dx, offset pipes
	mov bx, dx
	add bx, [pipeIndex]
	mov [bx], ScreenWidth
	mov [bx + 2], 150;random lower pipe
	add [pipeIndex], 4
	cmp pipeIndex, pipesOnScreenTimes2
	jb inLoop
	mov [pipeIndex], 0
	inLoop:
	pop bx
	pop dx
	ret
endp newPipe
	

proc updateBird
	push ax
	push [birdx]
	push [birdy]
	push [birdsize]
	push 0
	call circle
	add [birdyvel], gravity
	mov ax, [birdyvel]
	add [birdy], ax
	cmp [birdy], 200
	jb notongroud
	
	mov [birdy], 200
	mov ax, [birdsize]
	sub [birdy], ax
	notongroud:
	
	mov ax, [birdsize]
	cmp [birdy], ax
	ja nothigh
	mov ax, [birdsize]
	mov [birdy], ax
	mov [birdyvel], 0
	nothigh:
	call drawBird
	pop ax
	ret
endp updateBird

proc updatePipes
	push cx
	xor cx, cx
	eachPipe:
		push cx
		call updatePipe
		add cx, 2
		cmp cx, pipesOnScreenTimes2
	jb eachPipe
	pop cx
	ret
endp updatePipes

index equ bp + 4
proc updatePipe
	push bp
	mov bp, sp
	push [index]
	push [index + 2]
	push 0
	call drawPipe
	add [index], gameSpeed
	push [index]
	push [index + 2]
	push 2
	call drawPipe
	pop bp
	ret 2
endp updatePipe
	
	
x equ [bp + 8]
lowerPipe equ [bp + 6]
color equ [bp + 4]
proc drawPipe
	push bp
	mov bp, sp
	push ax
	push cx
	
	mov ax, x
	sub ax, halfPipeThickness
	push ax
	
	mov ax, halfPipeThickness
	shl ax, 1
	mov cx, ax
	
	mov ax, lowerPipe
	push ax
	push cx
	
	mov cx, 200
	sub cx, lowerPipe
	push cx
	push color
	call rect
	
	mov ax, x
	sub ax, halfPipeThickness
	push ax
	
	push 0
	
	mov ax, halfPipeThickness
	shl ax, 1
	push ax
	
	mov cx, lowerPipe
	sub cx, minGap
	sub cx, 5;random number
	push cx
	
	push color
	call rect
	pop cx
	pop ax
	pop bp
	ret 4
endp drawPipe
	
	
start:
mov ax, @data
mov ds, ax

call toGraphics
call drawBird


waitForSpace:
	cmp [pipeSpace], 0
		ja pipeNotFarEnough
			call newPipe
			mov [pipeSpace], pipeSpacing
		pipeNotFarEnough:
	dec [pipeSpace]
	call updateBird
	call updatePipes
	
	in al, 64h
	cmp al, 01b
	je waitForSpace
	in al, 60h
	cmp al, [last]
	je waitForSpace
	mov [last], al
	cmp al, 39h
	jne dontJump
	mov [birdyvel], jumpSpeed
	dontJump:
	cmp al, 01h
	jne dontExit
	jmp exit
	dontExit:
	jmp waitForSpace	
	
exit:
call toText
mov ax, 4c00h
int 21h
END start
