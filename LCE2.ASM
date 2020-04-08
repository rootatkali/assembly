IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  press db 'ESC key pressed',10,13,'$'
  rel db 'ESC key released',10,13,'$'
  
  last db 0

CODESEG
; Procedures here


start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  ; REMEMBER: Print character on dl, not al!!!!!!!!!!
  
  waitForPress:
    ; Get status
    in al,64h
    cmp al,10b ; Is new?
    je waitForPress ; No - back up
    in al,60h ; Get key

    cmp al,81h
    je released
    in al,60h
    cmp al,01h
    je pressed
    
    jmp waitForPress
  
  pressed:
    mov dx,offset press
    mov ah,09h
    int 21h
    jmp waitForPress
  
  released:
    mov dx,offset rel
    mov ah,09h
    int 21h
    jmp waitForPress

exit:
mov ax,4c00h
int 21h
END start
