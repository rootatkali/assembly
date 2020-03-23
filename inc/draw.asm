;;; PROC drawPixel
; Draws a pixel to the screen
; @param x   The x position
; @param y   The y position
; @param col The color.
;;;
x   equ [bp + 8]
y   equ [bp + 6]
col equ [bp + 4]
proc drawPixel
  push bp
  mov bp,sp
  
  push ax
  push bx
  push cx
  push dx
  
  mov bh,0h ; Monitor 0
  mov cx,x ; X coord
  mov dx,y ; Y coord
  mov ax,col ; Color
  mov ah,0Ch ; Draw pixel code
  int 10h ; Graphic mode BIOS control
  
  pop dx
  pop cx
  pop bx
  pop ax
  
  pop bp
  ret 6
endp

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
  
  lpDraw:
    push x ; X coord
    push y ; Y coord
    push col ; Color
    call drawPixel ; Draw a pixel
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
; @param wd  Width (horizontal) of the rectangle
; @param ht  Height (vertical) of the rectangle
; @param col The color of the rectangle
;;;
x   equ [bp + 12]
y   equ [bp + 10]
wd  equ [bp + 8]
ht  equ [bp + 6]
col equ [bp + 4]
proc drawRect
  push bp
  mov bp,sp
  push cx ; save
  
  mov cx,ht ; Draw ht lines
  
  drawLoop:
    push x ; drawLine:x
    push y ; drawLine:y
    inc y ; Next line
    push wd ; drawLine:len
    push col ; drawLine:col
    call drawLine ; Draw a line
    loop drawLoop
  
  pop cx ; load
  pop bp
  ret 10
endp
