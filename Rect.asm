; author: Roy Nevo Michrowski
; 12/3/2020
;
;this program includes full functions with no register loss to:
; -  color pixels in certain colors
; -  draw lines in certain x, y, length and color
; -  draw rectangles in certain x, y, width, height and color
; -  graphic mode to text mode and vise versa
;
;pixel draw saves all registers and then uses the registers to use the BIOS interrupt for pixel, restores registers and returns
;line calls pixel multiple times each time increments the x parameter
;rect calls line multiple times each time increments the y parameter

IDEAL
MODEL small
STACK 100h
DATASEG


CODESEG

proc toText ; set console mode to text, 
	push ax ; save ax
	; BIOS settings for text mode interrupt
	mov ah, 0
	mov al, 2
	int 10h ; BIOS interrupt
	pop ax ; restore ax
	ret
endp toText

proc toGraphics ; set console mode to graphics
	push ax ; save ax
	; BIOS settings for graphic mode interrupt
	mov ax, 13h
	int 10h ; BIOS interrupt
	pop ax ; restore ax
	ret
endp toGraphics

x equ [bp + 8] ; x parameter
y equ [bp + 6] ; y parameter
col equ [bp + 4] ; color parameter
proc pixel
	;save registers
	push bp
	mov bp, sp ; set bp to current stack to access parameters via bp, even after pushes and pops. see lines 40 - 42
	push ax
	push bx
	push cx
	push dx
	
	xor bh, bh ; bh = 0
	mov cx, x ; cx = x
	mov dx, y ; dx = y
	mov al, col ; al = col
	mov ah, 0Ch ; BIOS interrupt setting to paint pixel
	int 10h ; BIOS interrupt
	
	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6 ; restore stack before parameters
endp pixel

x equ [bp + 10] ; x parameter
y equ [bp + 8] ; y parameter 
len equ [bp + 6] ; line length parameter
col equ [bp + 4] ; line color parameter
proc line
	; save registers
	push bp
	mov bp, sp ; set bp as current sp to access parameters via bp, even after pushes and pops. see lines 68 - 71
	push ax
	push bx
	push cx
	push dx
	
	mov cx, len ; set loop counter as line length
	mov ax, x ; set initial pixel x as line x
	lin:
		push ax ; give x parameter
		push y ; give y parameter
		push col ; give color parameter
		call pixel ; paint pixel
		inc ax ; increment x for next pixel, by that painting line
	loop lin ; loop line length, painting pixel by pixel the line

	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 8 ; restore stack before parameters
endp line

x equ [bp + 12] ; x parameter
y equ [bp + 10] ; y parameter
wid equ [bp + 8] ; rectangle width parameter
hi equ [bp + 6] ; rectangle height parameter
col equ [bp + 4] ; rectangle color parameter
proc rect
	; save registers
	push bp
	mov bp, sp ; set bp as currest sp to access parameters on stack via bp even after pushes and pops. see lines 100 - 104
	push ax
	push bx
	push cx
	push dx
	
	mov cx, hi ; set loop counter as rectangle height
	mov bx, y ; set initial line y as rectangle y
	column:
		push x ; give x paramter
		push bx ; give y parameter
		push wid ; give line length parameter
		push col ; give color parameter
		call line ; paint line
		inc bx ; increment line y
	loop column ; looping through rectangle lines line by line drawing the rectangle

	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 10 ; restore stack before parameters
endp rect

start:
mov ax, @data
mov ds, ax

call toGraphics ; graphic mode

push 20  ; rectangle x at 20
push 20  ; rectangle y at 20
push 50  ; rectangle width = 50
push 150 ; rectangle height = 150
push 4   ; rectangle color is red
call rect ; paint rectangle

push 90  ; rectangle x at 90
push 20  ; rectangle y at 20
push 50  ; rectangle width = 50
push 150 ; rectangle height = 150
push 2   ; rectangle color is green
call rect ; paint rectangle

push 160  ; rectangle x at 160
push 20   ; rectangle y at 20
push 50   ; rectangle width = 50
push 150  ; rectangle height = 150
push 6    ; rectangle color is orange
call rect  ; paint rectangle

mov ah, 01h ; wait for key press
int 21h

call toText ; text mode


exit:
mov ax, 4C00h
int 21h
END start 















