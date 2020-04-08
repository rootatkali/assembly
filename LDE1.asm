IDEAL
MODEL small
STACK 100h

DATASEG

soundConst1 equ 0012h
soundConst2 equ 34DCh
msg db "Esc pressed, terminating program...$", 10, 13
last db 0

CODESEG

proc toText
	push ax
	mov ah, 0
	mov al, 2
	int 10h
	pop ax
	ret
endp toText

proc toGraphics
	push ax
	mov ax, 13h
	int 10h
	pop ax
	ret
endp toGraphics

x equ [bp + 8]
y equ [bp + 6]
col equ [bp + 4]
proc pixel
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	xor bh, bh
	mov cx, x
	mov dx, y
	mov al, col
	mov ah, 0Ch
	int 10h
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
endp pixel

x equ [bp + 10]
y equ [bp + 8]
len equ [bp + 6]
col equ [bp + 4]
proc line
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	mov cx, len
	mov ax, x
	lin:
		push ax
		push y
		push col
		call pixel
		inc ax
	loop lin

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 8
endp line

x equ [bp + 12]
y equ [bp + 10]
wid equ [bp + 8]
hi equ [bp + 6]
col equ [bp + 4]
proc rect
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	mov cx, hi
	mov bx, y
	column:
		push x
		push bx
		push wid
		push col
		call line
		inc bx
	loop column

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 10
endp rect

proc clearPiano
	push cx
	push ax
	push 0
	push 0
	push 320
	push 200
	push 15
	call rect
	
	mov cx, 5
	mov ax, 53
	separate:
		push ax
		push 0
		push 1
		push 200
		push 0
		call rect
		add ax, 53
	loop separate
	push 40
	push 0
	push 26
	push 100
	push 0
	call rect
	
	push 93
	push 0
	push 26
	push 100
	push 0
	call rect
	
	push 199
	push 0
	push 26
	push 100
	push 0
	call rect
	
	push 252
	push 0
	push 26
	push 100
	push 0
	call rect


	pop ax
	pop cx
	ret
endp clearPiano

;turn speaker "on"
proc activateSpeaker
	push ax
	in al, 61h
	or al, 00000011b
	out 61h, al
	pop ax
	ret
endp activateSpeaker


proc deactivateSpeaker
	push ax
	in al, 61h
	and al, 11111100b
	out 61h, al
	pop ax
	ret
endp deactivateSpeaker

pitch equ [bp + 4]
proc makeSound
	push bp
	mov bp, sp
	push ax
	push cx
	push dx
	mov al, 0B6h
	out 43h, al 
	mov al, 98h
	out 42h, al ; Sending lower byte
	mov al, 0Ah
	out 42h, al ; Sending upper byte 
	mov ax, soundConst2
	mov dx, soundConst1
	mov cx, pitch
	div cx
	out 42h, al
	xchg al, ah
	out 42h, al

	pop dx
	pop cx
	pop ax
	pop bp
	ret 2
endp makeSound

start:
mov ax, @data
mov ds, ax 

call toGraphics
call clearPiano

call activateSpeaker
waitForPress:
    ; Get status
    in al,64h
    cmp al,10b ; Is new?
    je waitForPress ; No - back up
    in al,60h ; Get key
	
	cmp al,2h
    je jmp1
	
	cmp al,3
    je jmp2
	
	cmp al,4
    je jmp3
	
	cmp al,5
    je jmp4

	cmp al,6
    je jmp5

	cmp al,7
    je jmp6

	cmp al,8
    je jmp7

	cmp al,9
    je jmp8

	cmp al,10
    je jmp9

	cmp al, 11
    je jmp0
	
	cmp al, 01h
	je jmpescape
	
	call deactivateSpeaker
	jmp waitForPress

jmp1:
	jmp key1

jmp2:
	jmp key2

jmp3:
	jmp key3

jmp4:
	jmp key4

jmp5:
	jmp key5

jmp6:
	jmp key6

jmp7:
	jmp key7

jmp8:
	jmp key8

jmp9:
	jmp key9
	
jmp0:
	jmp key0

jmpescape:
	jmp escape
	
	
key1:
	call activateSpeaker
	push 262
	call makeSound

	push 0
	push 0
	push 40
	push 100
	push 7
	call rect

	push 0
	push 100
	push 53
	push 100
	push 7
	call rect


	jmp waitForPress

key2:
	push 277
	call makeSound
	call activateSpeaker
	
		push 40
	push 0
	push 26
	push 100
	push 8
	call rect
	
	jmp waitForPress
	
key3:
	push 294
	call makeSound
	call activateSpeaker
	
	push 66
	push 0
	push 27
	push 100
	push 7
	call rect

	push 54
	push 100
	push 52
	push 100
	push 7
	call rect
	jmp waitForPress
	
key4:
	push 311
	call makeSound
	call activateSpeaker
	
	push 93
	push 0
	push 26
	push 100
	push 8
	call rect
	
	jmp waitForPress
	
key5:
	push 330
	call makeSound
	call activateSpeaker
	
	push 119
	push 0
	push 40
	push 100
	push 7
	call rect

	push 107
	push 100
	push 52
	push 100
	push 7
	call rect
	
	
	
	
	
	jmp waitForPress

key0:
	push 440
	call makeSound
	call activateSpeaker
	
	push 278
	push 0
	push 40
	push 100
	push 7
	call rect

	push 266
	push 100
	push 53
	push 100
	push 7
	call rect
	
	jmp waitForPress

key6:
	push 349
	call makeSound
	call activateSpeaker
	
	push 160
	push 0
	push 40
	push 100
	push 7
	call rect

	push 160
	push 100
	push 52
	push 100
	push 7
	call rect
	
	jmp waitForPress

key7:
	push 370
	call makeSound
	call activateSpeaker
	
	push 199
	push 0
	push 26
	push 100
	push 8
	call rect
	
	jmp waitForPress

key8:
	push 392
	call makeSound
	call activateSpeaker
	
	push 225
	push 0
	push 27
	push 100
	push 7
	call rect

	push 213
	push 100
	push 52
	push 100
	push 7
	call rect
	
	jmp waitForPress

key9:
	push 415
	call makeSound
	call activateSpeaker
	
	push 252
	push 0
	push 26
	push 100
	push 8
	call rect
	
	jmp waitForPress
	







	cmp al,82h
    je releaseJmp1
	
	cmp al,83h
    je releaseJmp2
	
	cmp al,84h
    je releaseJmp3
	
	cmp al,85h
    je releaseJmp4

	cmp al,86h
    je releaseJmp5

	cmp al,87h
    je releaseJmp6

	cmp al,88h
    je releaseJmp7

	cmp al,89h
    je releaseJmp8

	cmp al,90h
    je releaseJmp9

	cmp al, 91h
    je releaseJmp0
		
	call deactivateSpeaker
	jmp waitForPress

releaseJmp1:
	jmp releaseKey1

releaseJmp2:
	jmp releaseKey2

releaseJmp3:
	jmp releaseKey3

releaseJmp4:
	jmp releaseKey4

releaseJmp5:
	jmp releaseKey5

releaseJmp6:
	jmp releaseKey6

releaseJmp7:
	jmp releaseKey7

releaseJmp8:
	jmp releaseKey8

releaseJmp9:
	jmp releaseKey9
	
releaseJmp0:
	jmp releaseKey0
	
releaseKey1:
	call activateSpeaker
	push 262
	call makeSound

	push 0
	push 0
	push 40
	push 100
	push 15
	call rect

	push 0
	push 100
	push 53
	push 100
	push 15
	call rect


	jmp waitForPress

releaseKey2:
	push 277
	call makeSound
	call activateSpeaker
	
		push 40
	push 0
	push 26
	push 100
	push 0
	call rect
	
	jmp waitForPress
	
releaseKey3:
	push 294
	call makeSound
	call activateSpeaker
	
	push 66
	push 0
	push 27
	push 100
	push 15
	call rect

	push 54
	push 100
	push 52
	push 100
	push 15
	call rect
	jmp waitForPress
	
releaseKey4:
	push 311
	call makeSound
	call activateSpeaker
	
	push 93
	push 0
	push 26
	push 100
	push 0
	call rect
	
	jmp waitForPress
	
releaseKey5:
	push 330
	call makeSound
	call activateSpeaker
	
	push 119
	push 0
	push 40
	push 100
	push 15
	call rect

	push 107
	push 100
	push 52
	push 100
	push 15
	call rect
	
	
	
	
	
	jmp waitForPress

releaseKey0:
	push 440
	call makeSound
	call activateSpeaker
	
	push 278
	push 0
	push 40
	push 100
	push 15
	call rect

	push 266
	push 100
	push 53
	push 100
	push 15
	call rect
	
	jmp waitForPress

releaseKey6:
	push 349
	call makeSound
	call activateSpeaker
	
	push 160
	push 0
	push 40
	push 100
	push 15
	call rect

	push 160
	push 100
	push 52
	push 100
	push 15
	call rect
	
	jmp waitForPress

releaseKey7:
	push 370
	call makeSound
	call activateSpeaker
	
	push 199
	push 0
	push 26
	push 100
	push 0
	call rect
	
	jmp waitForPress

releaseKey8:
	push 392
	call makeSound
	call activateSpeaker
	
	push 225
	push 0
	push 27
	push 100
	push 15
	call rect

	push 213
	push 100
	push 52
	push 100
	push 15
	call rect
	
	jmp waitForPress

releaseKey9:
	push 415
	call makeSound
	call activateSpeaker
	
	push 252
	push 0
	push 26
	push 100
	push 0
	call rect
	
	jmp waitForPress
	
escape:	
	mov dx, offset msg
	mov ah, 09h
	int 21h

call deactivateSpeaker

call toText

exit:
mov ax, 4c00h
int 21h
END start