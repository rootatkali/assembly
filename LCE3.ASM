IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  msgA db 'A Pressed$'
  msgW db 'W Pressed$'
  msgS db 'S Pressed$'
  msgD db 'D Pressed$'
  msgE db 'ESC Pressed, terminating.$'
  nLne db 10,13,'$'

CODESEG
; Procedures here


start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  ; REMEMBER: Print character on dl, not al!!!!!!!!!!
  waitForPress:
    mov ah,1
    int 16h
    jz waitForPress
    
    mov ah,0
    int 16h
    cmp al,'a'
    je a
    cmp al,'w'
    je w
    cmp al,'s'
    je s
    cmp al,'d'
    je d
    cmp ah,1h ; ESC pressed?
    je e
  
  a:
    mov dx,offset msgA
    mov ah,09h
    int 21h
    mov dx,offset nLne
    mov ah,09h
    int 21h
    jmp waitForPress
  
  d:
    mov dx,offset msgD
    mov ah,09h
    int 21h
    mov dx,offset nLne
    mov ah,09h
    int 21h
    jmp waitForPress
  
  w:
    mov dx,offset msgW
    mov ah,09h
    int 21h
    mov dx,offset nLne
    mov ah,09h
    int 21h
    jmp waitForPress
  
  s:
    mov dx,offset msgS
    mov ah,09h
    int 21h
    mov dx,offset nLne
    mov ah,09h
    int 21h
    jmp waitForPress
  
  e:
    mov dx,offset msgE
    mov ah,09h
    int 21h
    jmp exit
  
exit:
mov ax,4c00h
int 21h
END start
