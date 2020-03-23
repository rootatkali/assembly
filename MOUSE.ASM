IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  color db 0Fh ; Default color to white

CODESEG
; Procedures here
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


start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  
  ; Go to graphic mode
  mov ax,13h ; Graphic mode interrupt code
  int 10h ; BIOS Video Services

drawRects:
  ; Draw first rectangle: red
  push 0 ; x
  push 0 ; y
  push 40 ; wd
  push 40 ; ht
  push 4h ; Color red
  call drawRect ; Draw 40x40 red rectangle at (0,0)
  
  push 0 ; x
  push 40 ; y
  push 40 ; wd
  push 40 ; ht
  push 2h ; Color green
  call drawRect ; Draw 40x40 green rectangle at (0,40)
  
  push 0 ; x
  push 80 ; y
  push 40 ; wd
  push 40 ; ht
  push 1h ; Color blue
  call drawRect ; Draw 40x40 blue rectangle at (0,80)
  
  push 0 ; x
  push 120 ; y
  push 40 ; wd
  push 40 ; ht
  push 0h ; Color black
  call drawRect ; Draw 40x40 black rectangle at (0,120) (not a must, just for consistency)
  
  push 0 ; x
  push 160 ; y
  push 40 ; wd
  push 40 ; ht
  push 0Fh ; Color white
  call drawRect ; Draw 40x40 white rectangle at (0,160)
  
mouseControl:
  xor ax,ax ; ax = 0 (Reset mouse interrupt code)
  int 33h ; Mouse function call
  
  mov ax,1h ; Show mouse button
  int 33h ; Mouse control
  
mouseLoop:
  ; Check for key input
  in al,64h ; Get keyboard status
  cmp al,10b ; New key?
  je next
  in al,60h
  cmp al,81h ; ESC key
  je exit
  
next:
  ; Get mouse position
  mov ax,03h ; Get mouse status 
  int 33h ; Mouse control
  cmp bx,01h ; Is left button pressed?
  jne mouseLoop ; No - loop again
  
  shr cx,1 ; Divide by 2 to get actual coords
  
  ; Check if mouse is in left side
  cmp cx,40 ; x < 40?
  jbe setColor
  
  dec dx ; Draw above mouse
  push cx ; x
  push dx ; y
  push [word ptr color] ; col
  call drawPixel ; Draw above mouse
  inc dx ; Return to previous value
  jmp mouseLoop

setColor:
;  push cx
;  call printNum
  mov ah,0Dh ; Read pixel color
  mov bh,00h ; First monitor
  mov cx,2
  mov dx,dx
  int 10h ; BIOS Video Services
  mov [color],al
  jmp mouseLoop

exit:
mov ax,4c00h
int 21h
END start
