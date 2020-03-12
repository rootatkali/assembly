; MOODLE TASK 4
; AUTHOR - ROTEM MOSES
; DATE - 11 MARCH 2020

; General explanation:
; Proc drawLine draws a horiontal line.
; Proc drawRect calls drawLine to draw a filled rectangle.
; Proc playSound accepts a tone parameter and plays it through the speaker.
; Proc stopSpeaker stops the speaker.
; Four rects are drawn on the screen, representing each key.
; Port 64h listens for new key. Each [WASD] key press plays a different sound, and changes the 
; fitting rectangle's color using an overlay.
; Each release calls stopSpeaker and redraws the original rectangle.
; A release of the ESC key terminates.

IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  last db 0 ; Last key pressed

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

;;; PROC playSound
; Opens the speaker unit and plays a sound.
; @param tone The tone to play.
;;;
tone equ [bp + 4]
proc playSound
  push bp
  mov bp,sp
  push ax
  
  ; Start speaker
  in al,61h
  or al,11b
  out 61h,al
  
  ; Get speaker access
  mov al,0B6h
  out 43h,al
  
  ; Send sound to speaker
  mov ax,tone
  out 42h,al ; Send first byte
  shr ax,8 ; Equal in result to "mov al,ah" but quicker
  out 42h,al ; Send second byte
  
  pop ax
  pop bp
  ret 2
endp

;;; PROC stopSpeaker
; Stops the speaker.
;;;
proc stopSpeaker
  push ax
  in al,61h ; Get speaker status
  and al,11111100b ; Set last two bits to 0
  out 61h,al ; Update status
  pop ax
  ret
endp

; Sounds set values
wSound equ 0A97h ; 1193180 / 440 -> hex
aSound equ 0974h ; 1193180 / 493 -> hex
sSound equ 08E9h ; 1193180 / 523 -> hex
dSound equ 07F0h ; 1193180 / 587 -> hex

; Rectangle width, height, coords and colors
wdth equ 50
hght equ 100
yAll equ 50 ; Y point of all rects
; x point of each rectangle
xW equ 24
xA equ 98
xS equ 172
xD equ 246
; active and passive colors:
active equ 8 ; Gray
passive equ 15 ; White

start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  
  ; Go to graphic mode.
  mov ax,13h
  int 10h
  
initRects:
  ; Draw w's rectangle
  push xW
  push yAll
  push wdth
  push hght
  push passive
  call drawRect
  
  ; Draw a's rectangle
  push xA
  push yAll
  push wdth
  push hght
  push passive
  call drawRect
  
  ; Draw s's rectangle
  push xS
  push yAll
  push wdth
  push hght
  push passive
  call drawRect
  
  ; Draw d's rectangle
  push xD
  push yAll
  push wdth
  push hght
  push passive
  call drawRect

waitForData: ; Wait for key press
  ; Status
  in al,64h
  cmp al,10b
  je waitForData
  in al,60h ; Key
  
  cmp [last],al ; Last key
  je waitForData
  
  mov [last],al
  
  cmp al,1Eh ; scan code for A
  je a ; A pressed?
  
  cmp al,20h ;scan code for D
  je d ; D pressed?
  
  cmp al,1Fh ; scan code for S
  je sJmp ; S pressed?
  
  cmp al,11h ; scan code for W
  je wJmp ; W pressed?
  
  cmp al,9Eh ; Scan code for A release
  je arJmp
  
  cmp al,0A0h ; Scan code for D release
  je drJmp
  
  cmp al,9Fh ; Scan code for S release
  je srJmp
  
  cmp al,91h ; Scan code for W release
  je wrJmp
  
  cmp al,81h ; scan code for ESC
  je eJmp ; ESC pressed?
  
  jmp waitfordata ; loop until termination


a: ; when A is pressed
  ; Draw over a's rectangle with the active color
  push xA
  push yAll
  push wdth
  push hght
  push active
  call drawRect
  
  push aSound ; tone
  call playSound
  
  jmp waitfordata ; return to the wait loop

; Fix out of range jumps:
sJmp:
  jmp s
wJmp:
  jmp w
arJmp:
  jmp ar
drJmp:
  jmp dr
srJmp:
  jmp sr
wrJmp:
  jmp wr
eJmp:
  jmp e

d: ; when D is pressed
  ; Draw over d's rectangle with the active color
  push xD
  push yAll
  push wdth
  push hght
  push active
  call drawRect
  
  push dSound ; tone
  call playSound
  
  jmp waitfordata ; return to the wait loop

s: ; when S is pressed
  ; Draw over s's rectangle with the active color
  push xS
  push yAll
  push wdth
  push hght
  push active
  call drawRect
  
  push sSound ; tone
  call playSound
  
  jmp waitfordata ; return to the wait loop

w: ; when W is pressed
  ; Draw over w's rectangle with the active color
  push xW
  push yAll
  push wdth
  push hght
  push active
  call drawRect
  
  push wSound ; tone
  call playSound
  
  jmp waitfordata ; return to the wait loop
  

ar: ; when A is released
  ; Draw a's rectangle with passive color
  push xA
  push yAll
  push wdth
  push hght
  push passive
  call drawRect
  
  call stopSpeaker
  
  jmp waitfordata ; return to the wait loop

dr: ; when D is released
  ; Draw d's rectangle with passive color
  push xD
  push yAll
  push wdth
  push hght
  push passive
  call drawRect
  
  call stopSpeaker
  
  jmp waitfordata ; return to the wait loop

sr: ; when S is released
  ; Draw s's rectangle with passive color
  push xS
  push yAll
  push wdth
  push hght
  push passive
  call drawRect
  
  call stopSpeaker
  
  jmp waitfordata ; return to the wait loop

wr: ; when W is released
  ; Draw a's rectangle with passive color
  push xW
  push yAll
  push wdth
  push hght
  push passive
  call drawRect
  
  call stopSpeaker
  
  jmp waitfordata ; return to the wait loop

e: ; when ESC is pressed  
  call stopSpeaker

exit:
mov ax,4c00h
int 21h
END start
