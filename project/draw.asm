;;; PROC drawPixel
; Draws a pixel to the screen.
; @param x   The x position
; @param y   The y position
; @param col The color.
;;;
x   equ [bp + 8]
y   equ [bp + 6]
col equ [bp + 4]
proc drawPixel
  push bp ; Save
  mov bp,sp ; Allocate 3 parameters
  
  push ax ; Save
  push bx ; Save
  push cx ; Save
  push dx ; Save
  
  mov bh,0h ; Monitor 0
  mov cx,x ; X coord
  mov dx,y ; Y coord
  mov ax,col ; Color
  mov ah,0Ch ; Draw pixel code
  int 10h ; BIOS Video Services
  
  pop dx ; Load
  pop cx ; Load
  pop bx ; Load
  pop ax ; Load
  
  pop bp ; Load
  ret 6 ; Unallocate 3 parameters
endp

;;; PROC drawLine
; Draws a horizontal line on the screen.
; @param x   The x coordinate of the line's starting point.
; @param y   The y coordinate of the line's starting point.
; @param len The length of the line, in pixels.
; @param col The color of the line.
;;;
x   equ [word ptr bp + 10] ; Solve Type Mismatch warnings
y   equ [bp + 8]
len equ [word ptr bp + 6] ; Solve Type Mismatch warnings
col equ [bp + 4]
proc drawLine
  push bp ; Save
  mov bp,sp ; Allocate 4 parameters
  push ax ; Save
  push bx ; Save
  push cx ; Save
  push dx ; Save
  
  lpDraw:
    push x ; X coord
    push y ; Y coord
    push col ; Color
    call drawPixel ; Draw a pixel
    inc x ; Next column
    
    ; Loop stopping check
    dec len ; len--
    cmp len,0 ; len = 0?
    jne lpDraw ; Continue loop
    
  fin:
    pop dx ; Load
    pop cx ; Load
    pop bx ; Load
    pop ax ; Load
    
    pop bp ; Load
    ret 8 ; Unallocate 4 variables
endp

;;; PROC drawSquare
; Draws a square on screen, using the drawLine procedure
; @param x   The x coord of the top left point
; @param y   The y coord of the top left point
; @param len Size of the rectangle
; @param col The color of the rectangle
;;;
x   equ [bp + 10]
y   equ [word ptr bp + 8]
len equ [bp + 6]
col equ [bp + 4]
proc drawSquare
  push bp
  mov bp,sp
  push cx ; save
  
  mov cx,len ; Draw len lines
  
  drawLoop:
    push x ; drawLine:x
    push y ; drawLine:y
    inc y ; Next line
    push len ; drawLine:len
    push col ; drawLine:col
    call drawLine ; Draw a line
    loop drawLoop
  
  pop cx ; load
  pop bp
  ret 8
endp
