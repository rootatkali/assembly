IDEAL
MODEL small
STACK 100h

DATASEG

color dw 15
bgcolor equ 0
brushsize dw 20
mouse dw 0

CODESEG
include "utils\graphics.asm"
include "utils\UI.asm"

proc toolbar
	
	push 0
	push 0
	push 40
	push 40
	push 0
	call rect
	
	push 280
	push 160
	push 40
	push 40
	push 0
	call rect

	push 280
	push 0
	push 40
	push 40
	push 15
	call rect
	
	push 280
	push 40
	push 40
	push 40
	push 4
	call rect
	
	push 280
	push 80
	push 40
	push 40
	push 1
	call rect
	
	push 280
	push 120
	push 40
	push 40
	push 2
	call rect
	
	;E for erase button
	push 290
	push 170
	push 20
	push 20
	push 15
	call rect
	
	push 295
	push 174
	push 15
	push 4
	push bgcolor
	call rect
	
	push 295
	push 182
	push 15
	push 4
	push bgcolor
	call rect
	;----------------
	
	;C for Clear
	C:
	push 5
	push 5
	push 30
	push 30
	push 15
	call rect
	
	push 10
	push 10
	push 25
	push 20
	push bgcolor
	call rect
	
	push 0
	push 40
	push 41
	push 15
	call line
	
	push 40
	push 0
	push 1
	push 40
	push 15
	call rect
	ret
endp toolbar


proc clearScreen
push 0
push 0
push 320
push 200
push bgcolor
call rect

call initMouse

call toolbar

;-----------
ret
endp clearScreen

start:
mov ax, @data
mov ds, ax

call toGraphics

call clearScreen

notPressed:
	in al,64h ; get keyboard status
	cmp al,10b ; is data new
	je notPressed ; if not, try again
	in al,60h ; Get key from keyboard
	cmp al, 01h
	je bye
	
	call getMouseData
	
	cmp [mouse], 1
	jne alreadyThere
	mov [mouse], 0
	push ax
	mov ah, 1
	int 33h
	pop ax
	alreadyThere:

	
	cmp bx, 01h
	jne notPressed
	
	cmp [mouse], 0
	jne alreadyGone
	mov [mouse], 1
	push ax
	mov ah, 1
	int 33h
	pop ax
	alreadyGone:
		
	cmp cx, 40
	ja brush
	cmp dx, 40
	ja brush
	call clearScreen
	brush:
	
	cmp cx, 280
	jae switch	
	
	push cx
	dec dx
	push dx
	push [brushsize]
	push [color]
	call fill_circle
	call toolbar
	jmp notPressed
	
	jmp notbye
	bye:
	jmp exit
	notbye:

	
	clear:
	push 41
	push 0
	push 240
	push 200
	push bgcolor
	call rect
	
	jmp na
	switch:
	jmp realswitch
	na:
	
	push 0
	push 41
	push 41
	push 160
	push bgcolor
	call rect
		
	realswitch:
	
	cmp dx, 40
	ja next1
	mov [color], 15
	jmp notPressed

	next1:
	cmp dx, 80
	ja next2
	mov [color], 4
	jmp notPressed

	next2:
	cmp dx, 120
	ja next3
	mov [color], 1
	jmp notPressed

	next3:
	cmp dx, 160
	ja erase
	mov [color], 2
	jmp notPressed

	erase:
	mov [color], bgcolor
	jmp notPressed
	
jmp notPressed

exit:
call toText
mov ax, 4c00h
int 21h
END start