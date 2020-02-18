IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  msg db 'Hello World$'

CODESEG
; Procedures here

start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  ; REMEMBER: Print character on dl, not al!!!!!!!!!!
  xor bx,bx ; bx = 0
  mov ah,02h ; int.code move carriage
  mov dh,11 ; line = 12
  mov dl,34 ; column = 35
  int 10h ; Interrupt - Move carriage
  
  ; Load message
  push seg msg
  pop ds
  mov dx,offset msg
  ; Interrupt - Print String
  mov ah,9h
  int 21h

exit:
mov ax,4c00h
int 21h
END start
