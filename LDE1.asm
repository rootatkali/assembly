%define soundConst 1193180;constant to divide for sound

IDEAL
MODEL small
STACK 100h

DATASEG


CODESEG

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
	mov ax, soundConst
	div ax, pitch
	out 42h, al
	xchg al, ah
	out 42h, al
	pop ax
	pop bp
	ret 2
endp makeSound

start:
mov ax, @data
mov ds, ax 
	
call activateSpeaker
push 220
call makeSound
  getData:
    in al,64h ; Get status
    cmp al,10b ; Is new?
    je getData ; No - get data
    in al,60h ; Find key scan code
    cmp al,01h ; is escape key?
    jne getData
    mov dx,offset msg ; set message
    mov ah,09h ; set print string interrupt
    int 21h ; interrupt - print
call deactivateSpeaker
	
exit:
mov ax, 4c00h
int 21h
END start