IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  

CODESEG
; Procedures here
;;; PROC draw
; Draws a pixel with the requested coords and color.
; @param x   x coordinate
; @param y   y coordinate
; @param col Color
; @returnTo NULL
;;;
x   equ [bp + 8]
y   equ [bp + 6]
col equ [bp + 4]
proc draw
  push bp
  mov bp,sp
  push ax
  push bx
  push cx
  push dx
  
  mov bh,0h
  mov cx,x
  mov dx,y
  mov al,col
  mov ah,0Ch
  int 10h
  
  pop dx
  pop cx
  pop bx
  pop ax
  pop bp
  ret 6
endp draw

start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  ; REMEMBER: Print character on dl, not al!!!!!!!!!!
  
  ; Graphics mode
  mov ax,13h
  int 10h
  
  mov cx,10
drawLine:
  push cx ; @param x
  push 40 ; @param y
  push 2 ; @param col
  call draw
  loop drawLine
  
  mov dx,10
drawSquare:
  mov cx,10
  inLoop: ; Each one draws a line
    push cx ; @param x
    push dx ; @param y
    push 4h ; @param call
    call draw
    loop inLoop
  dec dx
  cmp dx,0
  jne drawSquare ; Loop
  

exit:
mov ax,4c00h
int 21h
END start
