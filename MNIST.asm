IDEAL
MODEL small
STACK 100h

DATASEG

pixels dw 784 dup (1)
last db 0
weights dw 7840 dup (2)
digits dw 10 dup (0)

tutorialMessage db 'This is an MNIST database based AI to guess handwritten digits', 10, 'Simply scribble onto the left half of the screen with your mouse', 10, 'And press T to check what digit the computer thinks you wrote', 10, 'press C to clear your scribbles and ESC to exit the program', 10, 'Press any key to start the program...', 10, '$'

brushSize equ 9

CODESEG

include "utils/graphics.asm"
include "utils/print.asm"
include "utils/UI.asm"

proc tutorial
	push dx
	push ax
	
	call cls
	
	mov dx, offset tutorialMessage
	mov ah, 9
	int 21h
	
	xor ah, ah
	int 16h
	
	pop ax
	pop dx
	ret
endp tutorial

x equ [bp + 6]
y equ [bp + 4]
proc mnistPixel
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	mov cx, x
	add cx, brushSize
	cmp cx, 160
	ja crack
		push x
		push y
		push brushSize
		push 15
		call fill_circle
		
		mov bx, offset pixels
		
		mov cx, 6
		mov ax, x
		xor dx, dx
		div cx
		
		add bx, ax
		
		mov cx, 7
		mov ax, y
		xor dx, dx
		div cx
		mov cx, 28
		mul cx
		
		add bx, ax
		
		mov [word ptr bx], 0
	crack:
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4
endp mnistPixel
	
proc clearScreen
	
	push 0
	push 0
	push 320
	push 200
	push 0
	call rect
		
	push 160
	push 0
	push 1
	push 200
	push 15
	call rect
	
	push bx
	push cx
	
	mov bx, offset pixels
	mov cx, 784
	resetPixelArray:
		mov [word ptr bx], 1
		add bx, 2
	loop resetPixelArray
	
	pop cx
	pop bx	
	
	ret
endp clearScreen





proc show0
	
	push 180
	push 20
	push 120
	push 160
	push 15
	call rect
	
	push 200
	push 40
	push 80
	push 120
	push 0
	call rect
	
	ret
endp show0

proc show1
	
	push 200
	push 20
	push 80
	push 160
	push 15
	call rect
	
	push 200
	push 40
	push 30
	push 120
	push 0
	call rect
	
	push 250
	push 20
	push 30
	push 140
	push 0
	call rect
	
	ret
endp show1

proc show2
	
	push 180
	push 20
	push 120
	push 160
	push 15
	call rect

	push 180
	push 40
	push 100
	push 50
	push 0
	call rect	

	push 200
	push 110
	push 100
	push 50
	push 0
	call rect	
	
	ret
endp show2

proc show3
	
	push 180
	push 20
	push 120
	push 160
	push 15
	call rect
	
	push 180
	push 40
	push 100
	push 50
	push 0
	call rect
	
	push 180
	push 110
	push 100
	push 50
	push 0
	call rect
	
	push 180
	push 40
	push 100
	push 33
	push 0
	call rect
	
	ret
endp show3

proc show4
	
	push 180
	push 20
	push 120
	push 160
	push 15
	call rect
	
	push 200
	push 20
	push 60
	push 70
	push 0
	call rect
	
	push 180
	push 110
	push 80
	push 70
	push 0
	call rect
	
	push 280
	push 20
	push 20
	push 70
	push 0
	call rect
	
	push 280
	push 110
	push 20
	push 70
	push 0
	call rect
	
	ret
endp show4

proc show5
	
	push 180
	push 20
	push 120
	push 160
	push 15
	call rect

	push 200
	push 40
	push 100
	push 50
	push 0
	call rect	

	push 180
	push 110
	push 100
	push 50
	push 0
	call rect	
	
	
	
	ret
endp show5

proc show6
	
	push 180
	push 20
	push 120
	push 160
	push 15
	call rect

	push 200
	push 40
	push 100
	push 50
	push 0
	call rect	

	push 200
	push 110
	push 80
	push 50
	push 0
	call rect	
	
	ret
endp show6

proc show7
	
	push 180
	push 20
	push 120
	push 160
	push 15
	call rect
	
	push 180
	push 40
	push 100
	push 140
	push 0
	call rect
	
	ret
endp show7

proc show8
	
	push 180
	push 20
	push 120
	push 160
	push 15
	call rect

	push 200
	push 40
	push 80
	push 50
	push 0
	call rect	

	push 200
	push 110
	push 80
	push 50
	push 0
	call rect	
	
	ret
endp show8

proc show9
	
	push 180
	push 20
	push 120
	push 160
	push 15
	call rect

	push 200
	push 40
	push 80
	push 50
	push 0
	call rect	

	push 180
	push 110
	push 100
	push 50
	push 0
	call rect	
	
	ret
endp show9






digit equ [word ptr bp + 4]
proc showDigit
	push bp
	mov bp, sp
	
	cmp digit, 0
	jne not0
		call show0
	not0:

	cmp digit, 1
	jne not1
		call show1
	not1:

	cmp digit, 2
	jne not2
		call show2
	not2:

	cmp digit, 3
	jne not3
		call show3
	not3:

	cmp digit, 4
	jne not4
		call show4
	not4:

	cmp digit, 5
	jne not5
		call show5
	not5:

	cmp digit, 6
	jne not6
		call show6
	not6:

	cmp digit, 7
	jne not7
		call show7
	not7:

	cmp digit, 8
	jne not8
		call show8
	not8:

	cmp digit, 9
	jne not9
		call show9
	not9:
	
	pop bp
	ret 2
endp showDigit

proc runNet
	push ax
	push bx
	push cx
	push dx
	
	mov bx, offset digits
	mov cx, 10
	resetDigits:
		mov [word ptr bx], 0
		add bx, 2
	loop resetDigits
	
	xor bx, bx
	forEachDigit:
		push bx
		
		mov dx, bx
		mov cx, 784
		forEachPixel:
			cmp [word ptr offset pixels + bx], 0
			jbe notPainted
				push ax
				mov ax, [word ptr offset weights + bx]
				xchg bx, dx
				add [word ptr offset digits + bx], ax
				xchg bx, dx
				pop ax
			notPainted:
			add bx, 20
		loop forEachPixel
		
		
		
		pop bx
		add bx, 2
		cmp bx, 20
	jb forEachDigit
	
	jmp exit
	
	mov ax, 0
	mov cx, 10
	mov bx, offset digits
	mov dx, 5
	findMaxDigit:
		cmp [bx], ax
		jbe notBigger
			mov ax, [bx]
			mov dx, 10
			sub dx, cx
		notBigger:
		
		add bx, 2
	
	loop findMaxDigit
	
	push dx;elleged result of AI shit
	call showDigit
	
	pop dx
	pop cx
	pop bx
	pop ax
		ret
endp runNet

start:
mov ax, @data
mov ds, ax

push offset weights
push 7840
call printArrDec
xor ah, ah
int 16h
call tutorial

call toGraphics
call clearScreen
call initMouse

updateInput:
	call getMouseData
	and bx, 01b
	cmp bx, 1
	jne notClicked
		push cx
		push dx
		call mnistPixel
	notClicked:
	
	call keyboardData
	cmp dl, 0
	je updateInput
	
	cmp dl, [last]
	je updateInput
	mov [last], dl
	
	cmp dl, 1
	jne dontExit
		jmp exit
	dontExit:
	
	cmp dl, 2Eh
	jne dontClear
		call clearScreen
	dontClear:
	
	cmp dl, 14h
	jne dontTest
		call runNet
	dontTest:
	
jmp updateInput

exit:
call toText
call cls
push offset digits
push 10
call printArrDec
mov ax, 4c00h
int 21h
END start