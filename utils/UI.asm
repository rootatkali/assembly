IDEAL
MODEL small
STACK 100h

DATASEG


CODESEG

; OVERRIDE: dx
proc keyboardData
	push ax
    in al,64h ; get keyboard status
    cmp al, 01b ; is data new
	je laevn ; if not don't give key
	in al, 60h ; get keyboard key
	mov dl, al ; dl = al
	jmp anec ; if got data dont set dl as 0
	laevn: ; jumbled label so user has labeling freedom
	xor dl, dl ; dl = 0 meaning keyboard offline
	anec: ; jumbled label
	pop ax ; restore ax
	xor dh, dh
	ret
endp keyboardData

proc initMouse
	push ax ; save ax
		xor ax, ax ; ax = 0 
		int 33h ; mouse interrupt to create mouse
		mov ax, 1 ; ax = 1
		int 33h ; mouse interrupt to make it apear
	pop ax ; restore ax
	ret
endp initMouse

 ; OVERRIDE: bx, cx, dx
 ; mouse data is returned in bx
 ; bx = 0: nothing clicked
 ; bx = 1: left clicked
 ; bx = 2: right clicked
 ; bx = 3: both clicked
 ; mouse data in cx: x coordinate on DOSBOX screen
 ; mouse data in dx: y coordinate on DOSBOX screen
proc getMouseData
	push ax ; save ax
	mov ax, 3 ; ax = 3
	int 33h ; mouse interrupt to get mouse data
	shr cx, 1 ; divide cx by 2 to fit dosbox coordinates
	pop ax ; restore ax
	ret
endp getMouseData