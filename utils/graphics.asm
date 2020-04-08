; author: Roy Nevo Michrowski
; graphics library for assembly DOSBOX
; functionality:
; exit and enter graphic mode
; draw pixels, horizontal lines, rectangles and circles
IDEAL
MODEL small
STACK 100h

DATASEG

uqns dw ? ; jumbled name so that when library is used the variable won't override names for other variables in software
iapen dw ? ; jumbled name so that when library is used the variable won't override names for other variables in software

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


x equ [word ptr bp + 8] ; x coordinate of pixel
y equ [word ptr bp + 6] ; y coordinate of pixel
col equ [byte ptr bp + 4] ; color of pixel
proc pixel
	; save registers
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	cmp x, 0
	jb outOfBounds
	cmp x, 320
	ja outOfBounds
	cmp y, 0
	jb outOfBounds
	cmp y, 200
	ja outOfBounds
	
	xor bh, bh ; bh = 0
	mov cx, x ; cx = x
	mov dx, y ; dx = y
	mov al, col ; al = col
	mov ah, 0Ch ; BIOS interrupt setting to paint pixel
	int 10h ; BIOS interrupt
	
	outOfBounds:
	
	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6 ; restore stack
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
	push cx
	
	mov cx, len ; set loop counter as line length
	mov ax, x ; set initial pixel x as line x
	alisne: ; jumbled label so user can use any label
		push ax ; give x parameter
		push y ; give y parameter
		push col ; give color parameter
		call pixel ; paint pixel
		inc ax ; increment x for next pixel, by that painting line
	loop alisne ; loop line length, painting pixel by pixel the line

	; restore registers
	pop cx
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
	push bx
	push cx
	
	mov cx, hi ; set loop counter as rectangle height
	mov bx, y ; set initial line y as rectangle y
	enais: ; jumbled label so user doesn't have labeling issue
		push x ; give x paramter
		push bx ; give y parameter
		push wid ; give line length parameter
		push col ; give color parameter
		call line ; paint line
		inc bx ; increment line y
	loop enais ; looping through rectangle lines line by line drawing the rectangle

	; restore registers
	pop cx
	pop bx
	pop bp
	ret 10 ; restore stack before parameters
endp rect

x1 equ [bp + 10] ; x of first dot
y1 equ [bp + 8] ; y of first dot
x2 equ [bp + 6] ; x of second dot
y2 equ [bp + 4] ; y of second dot
proc squaredistance
	; save registers
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	
	; calculate xdifference between dots squared
	mov ax, x1 ; ax = x1
	sub ax, x2 ; ax = x1 - x2
	mov cx, ax ; cx = ax
	mul cx ; ax = ax * cx = (x1 - x2)^2 = x distance squared
	
	; calculate ydifference between dots squared
	mov bx, y1 ; bx = y1
	sub bx, y2 ; bx = y1 - y2
	mov cx, bx ; cx = bx
	xchg ax, bx ; switch ax and bx
	mul cx ; ax(AKA bx) = ax * cx = (y1 - y2) ^ 2 = ydifference squared
	
	mov dx, ax ; dx = ydiff ^ 2
	add dx, bx ; dx = ydiff ^ 2 + xdiff ^ 2
	
	; dx is the distance because of the pythagorean theorem:
	; c^2 = a^2 + b^2
	; c is distance, a and b are x and y distance
	
	; restore registers
	pop cx
	pop bx
	pop ax
	pop bp
	ret 8 ; restore stack
endp squaredistance

x equ [bp + 10] ; x coordinate of circle center
y equ [bp + 8] ; y coordinate of circle center
rad equ [bp + 6] ; circle radius
col equ [bp + 4] ; circle colour
proc fill_circle
	; save registers
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	
	mov ax, rad ; ax = radius
	mov cx, ax ; cx = ax
	mul cx ; ax = ax * cx = ax ^ 2
	mov [uqns], ax ; set max distance squared from center as radius squared
	
	mov cx, rad ; cx = radius
	shl cx, 1 ; cx *= 2 --> קוטר
	
	mov ax, x ; ax = x
	sub ax, rad ; ax -= radius, start from corner of bounding square
	
	mov bx, y ; bx = y
	sub bx, rad ; bx -= radius, start from corner of bounding square
	
	
	dksnalg: ; jumbled label to not take instead of user using library
		push cx ; save counter for y loop
		mov ax, x ; reset ax to beginning
		sub ax, rad
		
		mov cx, rad ; set cx as counter
		shl cx, 1 ; mult by two to go over all circle
		kenlsb: ; jumbled label 
		
			push x ; center coordinates
			push y
			push ax ; point in question coordinates
			push bx
			call squaredistance ; dx = square distance between center and dot in question
			
			cmp dx, [uqns] ; is distance small enough to be in circle
			ja einglse ; if not don't draw pixel
				push ax ; x of pixel 
				push bx ; y of pixel 
				push col ; color of pixel
				call pixel ; draw pixel in circle
			einglse: ; jumbled label
			
			inc ax ; next x
		loop kenlsb ; go through the whole x range
		inc bx ; next y
		pop cx ; restore counter for y loop
	loop dksnalg ; go through all rows possible
	
	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 8 ; restore stack
endp fill_circle

x equ [bp + 12] ; x coordinate of circle center
y equ [bp + 10] ; y coordinate of circle center
rad equ [bp + 8] ; circle radius
outline equ [bp + 6]
col equ [bp + 4] ; circle colour
proc draw_circle
	; save registers
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx

	mov cx, outline
	shr cx, 1
	add cx, rad
	
	mov ax, cx
	mul cx
	mov [uqns], ax
	
	push ax
	sub cx, outline
	mov ax, cx
	mul cx
	mov [iapen], ax
	pop ax

	mov cx, outline
	shl cx, 1
	add cx, rad
		
	mov bx, y
	sub bx, cx
	
	shl cx, 1
	
	dksnalg1: ; jumbled label to not take instead of user using library
		push cx ; save counter for y loop
		mov ax, x ; reset ax to beginning
		mov cx, outline
		shr cx, 1
		add cx, rad
		sub ax, cx
		
		mov cx, outline ; set cx as counter
		shr cx, 1
		add cx, rad
		shl cx, 1 ; mult by two to go over all circle
		kenlsb1: ; jumbled label 
		
			push x ; center coordinates
			push y
			push ax ; point in question coordinates
			push bx
			call squaredistance ; dx = square distance between center and dot in question
			
			cmp dx, [uqns] ; is distance small enough to be in circle
			ja einglse1 ; if not don't draw pixel
			cmp dx, [iapen]
			jb einglse1
				push ax ; x of pixel 
				push bx ; y of pixel 
				push col ; color of pixel
				call pixel ; draw pixel in circle
			einglse1: ; jumbled label
			
			inc ax ; next x
		loop kenlsb1 ; go through the whole x range
		inc bx ; next y
		pop cx ; restore counter for y loop
	loop dksnalg1 ; go through all rows possible			
			
	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 10 ; restore stack
endp draw_circle
