IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  msg db 'ESC key pressed$'

CODESEG
; Procedures here


start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  ; REMEMBER: Print character on dl, not al!!!!!!!!!!
  
getData:
    in al,64h ; Get status
    cmp al,10b ; Is new?
    je getData ; No - get data
    in al,60h ; Find key scan code
	cmp al, 01h
	je exit
	push ax
	shr al, 4
	add al, '0'
	mov dl, al
    mov ah,2h ; set print string interrupt
    int 21h ; interrupt - print
	pop ax
	add al, '0'
	mov dl, al
	mov ah, 2h
	int 21h
jmp getData
    

exit:
mov ax,4c00h
int 21h
END start
