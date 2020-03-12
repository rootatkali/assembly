; MOODLE TASK 2
; AUTHOR - ROTEM MOSES
; DATE - 11 MARCH 2020

; General explanation:
; The proc drawLine draws a horiontal line.
; The proc drawRect calls drawLine to draw a filled rectangle.

IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  

CODESEG
; Procedures here
;;; PROC drawLine
; Draws a horizontal line on the screen.
; @param x   The x coordinate of the line's starting point.
; @param y   The y coordinate of the line's starting point.
; @param len The length of the line, in pixels.
; @param col The color of the line.
;;;
x   equ [bp + 10]
y   equ [bp + 8]
len equ [bp + 6]
col equ [bp + 4]
proc drawLine
  push bp
  mov bp,sp
  push ax  ; Save
  push bx  ; Save
  push cx  ; Save
  push dx  ; Save
  
  ; BL will be the loop counter
  mov bx,len
  xor bh,bh
  lpDraw:
    mov bh,0h ; For single pixel
    mov cx,x ; X coord
    mov dx,y ; Y coord
    mov ax,col ; Color in al
    mov ah,0Ch ; For pixel
    int 10h ; Draw
    inc x ; Next column
    
    ; Loop stopping check
    dec len 
    cmp len,0
    jne lpDraw
    
  fin:
    pop dx ; Load
    pop cx ; Load
    pop bx ; Load
    pop ax ; Load
    pop bp
    ret 8
endp

;;; PROC drawRect
; Draws a rectangle on screen, using the drawLine procedure
; @param x   The x coord of the top left point
; @param y   The y coord of the top left point
; @param w   Width (horizontal) of the rectangle
; @param h   Height (vertical) of the rectangle
; @param col The color of the rectangle
;;;
x   equ [bp + 12]
y   equ [bp + 10]
w   equ [bp + 8]
h   equ [bp + 6]
col equ [bp + 4]
proc drawRect
  push bp
  mov bp,sp
  push cx ; save
  
  mov cx,h ; Draw h lines
  
  drawLoop:
    push x ; drawLine:x
    push y ; drawLine:y
    inc y ; Next line
    push w ; drawLine:len
    push col ; drawLine:col
    call drawLine ; Draw a line
    loop drawLoop
  
  pop cx ; load
  pop bp
  ret 10
endp

start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  
  ; Enter graphics mode
  mov ax,13h
  int 10h
  
  ; CALL drawRect
  push 10 ; x
  push 10 ; y
  push 300 ; w
  push 180 ; h
  push 4 ; col
  call drawRect

exit:
mov ax,4c00h
int 21h
END start
