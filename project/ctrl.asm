;;; PROC textMode
; Clears the screen and turns on 16-color 80x25 text mode.
;;;
proc textMode
  push ax ; Save ax
  mov ax,0003h ; Code for text mode
  int 10h ; BIOS Video Services
  pop ax ; Load ax
  ret
endp

;;; graphicsMode
; Clears the screen and turns on 256-color 320x200 graphical mode.
;;;
proc graphicsMode
  push ax ; Save ax
  mov ax,0013h ; Code for graphics mode
  int 10h ; BIOS Video Services
  pop ax ; Load ax
  ret
endp

;;; PROC random
; Generates a pseudo-random number from 0 to 7,
; using the clock timer and the CODESEG memory segment.
; The [rand] global variable is used to mark the byte from memory to read.
; @returnTo AL
; @Overrides AX
;;;
proc random
  push bx ; Save
  push cx ; Save
  push dx ; Save
  
  mov bx,[rand] ; Get random place in code
  inc [rand] ; Next time - next byte from code
  
  xor ah,ah ; AH = 0, clock timer int.
  int 1Ah ; Gets clock timer. Result in CX:DX.
  mov al,dl ; Get lower 4 bits of timer to AL
  mov ah,[byte cs:bx] ; Get a byte from codeseg memory
  xor al,ah ; XOR'ing returns a better randomized number
  and ax,7 ; Result between 0 and 7
  
  pop dx ; Load
  pop cx ; Load
  pop bx ; Load
  ret
endp
