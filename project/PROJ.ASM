IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  rand dw 0 ; This variable is used in the pseudo-random number generator.
  
  include "info.asm" ; info.asm has a string containing the instructions for the game - msgInfo.
  include "win.asm" ; win.asm has the text for the winner screen - msgWin
  include "lose.asm" ; lose.asm has the text for the loser screen - msgLose
  
  ; Define messages for color legend
  msgLegend1 db 'Color - Mines$'
  msgLegend2 db 'Blue - 1$'
  msgLegend3 db 'Green - 2$'
  msgLegend4 db 'Yellow - 3$'
  msgLegend5 db 'Megenta - 4$'
  msgLegend6 db 'Red - FLAG$'
  
  colors db 08,07,01,02,14,05,04 ; Color codes for square drawing (codes taken from [board]:
  ; Code | Color
  ;    0 | Dark Gray 08
  ;    1 | Light Gray 07
  ;    2 | Blue 01
  ;    3 | Green 02
  ;    4 | Yellow 14
  ;    5 | Magenta 05
  ;    6 | Red 04
  
  lngth equ 64 ; Length for arrays
  mines db lngth dup(0) ; Array for keeping note of mines
  board db lngth dup(0) ; Array for user board interaction
  
  flags db 0 ; Flags counter, used to avoid winning by placing a flag in every spot

CODESEG
; Procedure includes here
include "draw.asm"
; draw.asm contains general procedures related to graphics:
; drawPixel(x, y, col) - Draws a single pixel
; drawLine(x, y, len, col) - Draws a horizontal line
; drawSquare(x, y, len, col) - Draws a square

include "ctrl.asm"
; ctrl.asm contains general procedures as well as a pseudo-random number generator:
; textMode() - Clears the screen and goes to textual mode
; graphicsMode() - Clears the screen and goes to graphical mode
; random() - Returns a pseudo-random number in the range [0-7] to AL.

include "game.asm"
; game.asm contains procedures relating to the game behaviour:
; getIndex(x, y) - Returns to BX the index in arrays of a point (x, y).
; initBoard() - Initializes the [mines] and the [board] arrays for the start of the game.
; drawBox(x, y) - Draws a single box in position (x, y) on the board. Helper procedure.
; drawBoard() - Draws the board between (0, 0) and (199, 199).
; checkMines(x, y) - Checks the amount of mines in location (x, y). Overrides spot in [board].
; checkWin() - Scans [board] for victory. Returns 1 to AL 

start: ; Program head
  mov ax,@data ; Load data to AX
  mov ds,ax ; Load to DS
  xor ax,ax ; Reset AX

  call textMode ; Clear screen
  mov dx,offset msgInfo ; Info and instructions message - info.asm
  mov ah,09h ; Print string code
  int 21h ; DOS Function Dispatcher

keyInputStart: ; Wait for input of keys: ESC/ENTER
  mov ah,01h ; Get KB status
  int 16h ; BIOS Keyboard Services
  jz keyInputStart ; If no new key - continue waiting
  
  xor ah,ah ; ah = 0 Code for get key from buffer
  int 16h ; BIOS Keyboard Services
  
  cmp ah,1Ch ; Key = ENTER?
  je gameInit ; Yes - initialize game
  
  cmp ah,01h ; Key = ESC?
  jne keyInputStart ; No - Continue waiting for key
  jmp exit ; Yes - Terminate program

gameInit: ; Game initialization
  ; Basic initialization
  call graphicsMode ; Go to graphical mode
  call initBoard ; Initialize board arrays
  
  ; The following code sequence moves the cursor to the right part of the screen,
  ; and prints a line of text. This is achieved using interrupts 10-2 and 21-9.
  ; Note: In graphics mode, the text area is 40x25 instead of 80x25.
  mov ah,02h ; Code for mov cursor
  xor bh,bh ; BH = 0 Monitor No. 1
  mov dl,26 ; Row 27
  mov dh,3 ; Column 4
  int 10h ; BIOS Video Services
  
  mov ah,09h ; Print string
  mov dx,offset msgLegend1 ; Load string
  int 21h ; DOS Function Dispatcher
  
  mov ah,02h ; Code for mov cursor
  xor bh,bh ; BH = 0 Monitor No. 1
  mov dl,26 ; Row 27
  mov dh,4 ; Column 5
  int 10h ; BIOS Video Services
  
  mov ah,09h ; Print string
  mov dx,offset msgLegend2 ; Load string
  int 21h ; DOS Function Dispatcher
  
  mov ah,02h ; Code for mov cursor
  xor bh,bh ; BH = 0 Monitor No. 1
  mov dl,26 ; Row 27
  mov dh,5 ; Column 6
  int 10h ; BIOS Video Services
  
  mov ah,09h ; Print string
  mov dx,offset msgLegend3 ; Load string
  int 21h ; DOS Function Dispatcher
  
  mov ah,02h ; Code for mov cursor
  xor bh,bh ; BH = 0 Monitor No. 1
  mov dl,26 ; Row 27
  mov dh,6 ; Column 7
  int 10h ; BIOS Video Services
  
  mov ah,09h ; Print string
  mov dx,offset msgLegend4 ; Load string
  int 21h ; DOS Function Dispatcher
  
  mov ah,02h ; Code for mov cursor
  xor bh,bh ; BH = 0 Monitor No. 1
  mov dl,26 ; Row 27
  mov dh,7 ; Column 8
  int 10h ; BIOS Video Services
  
  mov ah,09h ; Print string
  mov dx,offset msgLegend5 ; Load string
  int 21h ; DOS Function Dispatcher
  
  mov ah,02h ; Code for mov cursor
  xor bh,bh ; BH = 0 Monitor No. 1
  mov dl,26 ; Row 27
  mov dh,8 ; Column 9
  int 10h ; BIOS Video Services
  
  mov ah,09h ; Print string
  mov dx,offset msgLegend6 ; Load string
  int 21h ; DOS Function Dispatcher
  
  ; Get amount of available flags = amount of mines
  mov bx,offset mines ; Load [mines] to bx
  mov cx,64 ; Loop counter 64

flagsLoop: ; Loop for every place in mines array
  cmp [byte ptr bx],1 ; Is mine?
  jne flagsLoopAfter ; No - continue
  inc [flags] ; Yes - increase flags counter

flagsLoopAfter: ; Continuation of loop
  inc bx ; Next place in array
  loop flagsLoop ; Loop until completion
  
  inc [flags] ; Solve a problem in the game code

  ; Turn on mouse
  xor ax,ax ; ax = 0 Reset mouse function call
  int 33h ; Mouse Function Services
  mov ax,1 ; Show mouse function call - Mouse has to be shown before it is hidden
  int 33h ; Mouse Function Services
  
  ; Initialize registers
  xor ax,ax ; Reset register
  xor bx,bx ; Reset register
  xor cx,cx ; Reset register
  xor dx,dx ; Reset register

mainGameLoop:
  ; Turn off mouse
  mov ax,02h ; Hide mouse function call
  int 33h ; Mouse Function Services
  
  ; Draw board
  call drawBoard ; Draw the board on the screen
  
  ; Turn on mouse
  mov ax,01h ; Show mouse function call
  int 33h ; Mouse Function Services
  
  ; Check for victory
  call checkWin ; @game.asm
  cmp al,1 ; Did player win?
  jne mouseKbLoop ; No - wait for mouse or keyboard input
  
  ; Code for victory
  call textMode ; Go to text mode
  mov dx,offset msgWin ; Winner message - win.asm
  mov ah,09h ; Code for printing String
  int 21h ; DOS Function Dispatcher
  jmp keyInputStart ; Wait for key input
  
mouseKbLoop: ; Wait for either mouse or keyboard input
  ; Check for keys - ESC and I
  mov ah,01h ; Read KB status
  int 16h ; BIOS Keyboard Services
  jz mouseKbNext ; No input - Skip keyboard
  
  xor ah,ah ; ah = 0 Read key from buffer
  int 16h ; BIOS Keyboard Services
  
  cmp ah,17h ; 'I' key scan code
  jne kbLoopEsc ; Not 'I'? Check ESC
  jmp start ; Yes 'I' - Restart program - show information screen

kbLoopEsc: ; Check ESC
  cmp ah,01h ; ESC key scan code
  ; The purpose of these two lines is to avoid a Relative Jump Out Of Range error.
  jne mouseKbNext ; No special key pressed.
  jmp exit ; Terminate

mouseKbNext: ; Check mouse
  ; Get mouse status
  mov ax,03h ; Get mouse status function call
  int 33h ; Mouse Function Services
  shr cx,1 ; Divide x position by 2 to fit graphic mode width (320).
  
  ; Check for Left Click
  cmp bx,01b ; Left button clicked
  je leftClick ; Go to left click code
  
  ; Check for Right Click
  cmp bx,10b ; Right button clicked
  je rightClick ; Go to right click code
  
  jmp mouseKbLoop ; If nothing happened, wait for more input
  
leftClick: ; Left click code
  cmp cx,200 ; Is mouse inside board?
  jb testForMine ; Yes - test for mine in spot
  jmp mainGameLoop ; No - more input

testForMine:
  ; Normalize x position (0-199:cx) to x coordinate (0-7)
  mov ax,cx ; Division always from AX
  mov cl,25 ; Divide word by byte
  div cl ; Result in al
  mov cl,al ; Save result
  xor ch,ch ; Solve type mismatch
  
  ; Normalize y position (0-199:dx) to y coordinate (0-7)
  mov ax,dx ; Division from AX
  mov dl,25 ; Divide word by byte
  div dl ; Result in al
  mov dl,al ; Save result
  xor dh,dh ; Solve type mismatch
  
  push cx ; normalized x position
  push dx ; normalized y position
  call getIndex ; Turn (x, y) to 8y+x
  add bx,offset mines ; Enter array
  
  cmp [byte ptr bx],1 ; Is mine? Yes - Lose
  jne tryOpen ; No - Try to open box
  
  ; Code for loss
  call textMode ; Go to text mode
  mov dx,offset msgLose ; Loser message - lose.asm
  mov ah,09h ; Code for printing String
  int 21h ; DOS Function Dispatcher
  jmp keyInputStart ; Wait for key input

tryOpen:
  sub bx,offset mines ; Get only index
  add bx,offset board ; Enter array
  
  cmp [byte ptr bx],0 ; Is untouched?
  je open ; Yes - open box
  jmp mainGameLoop ; No - Continue in game

open:
  push cx ; x
  push dx ; y
  call checkMines ; Calculate the amount of mines adjacent and store in array
  
  jmp mainGameLoop ; Continue in game

rightClick:
  ; RC: Normalize position
  cmp cx,200 ; Is mouse inside board?
  jb flagTest ; Yes - test for mine in spot
  jmp mainGameLoop ; No - more input
  
flagTest:
  ; Normalize x position (0-199:cx) to x coordinate (0-7)
  mov ax,cx ; Division always from AX
  mov cl,25 ; Divide word by byte
  div cl ; Result in al
  mov cl,al ; Save result
  xor ch,ch ; Solve type mismatch
  
  ; Normalize y position (0-199:dx) to y coordinate (0-7)
  mov ax,dx ; Division from AX
  mov dl,25 ; Divide word by byte
  div dl ; Result in al
  mov dl,al ; Save result
  xor dh,dh ; Solve type mismatch
  
  ; RC: Check for flags left
  cmp [flags],0 ; Any flags remaining?
  jne markFlag ; Yes - Add or remove flag
  jmp mainGameLoop ; No - Continue in game
  
markFlag:
  ; RC: Toggle flag
  push cx ; x
  push dx ; y
  call getIndex ; Find index in array
  add bx,offset board ; Enter array
  
  ; Move mouse away before comparison
  mov ax,04h ; Set mouse position function call
  mov cx,639 ; X position
  mov dx,199 ; Y position
  int 33h ; Mouse Function Services
  
  cmp [byte ptr bx],0 ; Is untouched?
  je addFlag ; Put flag
  cmp [byte ptr bx],6 ; If flag?
  je remFlag ; Remove flag
  jmp mainGameLoop ; Otherwise continue in game
  
addFlag: ; Place flag
  mov [byte ptr bx],6 ; Code for flag
  dec [flags] ; Take one flag from the system
  jmp mainGameLoop ; Continue in game

remFlag: ; Delete flag
  mov [byte ptr bx],0 ; Code for untouched
  inc [flags] ; Put back one flag in the registry
  jmp mainGameLoop ; Continue in game

exit: ; Game termination code
  call textMode ; Go back to text mode
  mov ax,4C00h ; Flush memory and terminate with exit code 0
  int 21h ; DOS Function Dispatcher

END start
