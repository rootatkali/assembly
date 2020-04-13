;;; PROC getIndex
; Returns the index of (x,y) in array to BX.
; @param x
; @param y
; @returnTo BX
; @Overrides BX
;;;
x equ [bp + 6]
y equ [bp + 4]
proc getIndex
  push bp ; Save
  mov bp,sp ; Place for variables
  
  xor bx,bx ; OVERRIDE
  mov bx,y ; bx = y
  shl bx,3 ; bx = 8y
  add bx,x ; bx = 8y + x
  
  pop bp ; Load
  ret 4 ; Unallocate 2 variables
endp

;;; PROC initBoard
; Initializes the mines and board arrays.
; In [mines] - A random number is generated for every cell. If the number is zero (0), the array
;              cell will have the code 1 (there is a mine). Else, it will have the code 0 (no mine).
; In [board] - The entire array is initialized to code 0 - No player interaction.
;;;
proc initBoard
    push ax ; Save value
    push bx ; Save value
    push cx ; Save value
    push dx ; Save value
    
    ; Initializing the board array
    mov bx,offset board ; Go to board
    mov cx,64 ; Loop counter
  
  boardLoop: ; Loop for board array
    mov [byte ptr bx],0 ; Reset position
    inc bx ; Next place
    loop boardLoop ; Loop for array
  
    ; Initializing the mines array
    mov bx,offset mines ; Go to mines
    mov cx,64 ; Loop counter
  
  minesLoop: ; Loop pt,1
    call random ; Get random number between 0 and 7
    cmp al,0 ; Is 0? Yes - mine
    jne noMine ; No - no mine
  
  yesMine: ; Place mine
    mov [byte ptr bx],1 ; Code for mine
    jmp loopEnd ; Continue loop
  
  noMine: ; Don't place mine
    mov [byte ptr bx],0 ; Code for no mine
    jmp loopEnd ; Continue loop
  
  loopEnd: ; End of mines loop
    inc bx ; Next place in array
    loop minesLoop ; Loop until completion.
  
    pop dx ; Load
    pop cx ; Load
    pop bx ; Load
    pop ax ; Load
    ret
endp

;;; PROC drawBox
; Draws a single box.
; Index of box in [board] = x * 8 + y where x and y are in the range [0~7]
; @param x The x position of the box in the board [0~7]
; @param y The y position of the box in the board [0~7]
;;;
x equ [bp + 6]
y equ [bp + 4]
proc drawBox
  push bp ; Save
  mov bp,sp ; Allocate space for parameters
  
  push ax ; Save value
  push bx ; Save value
  push cx ; Save value
  push dx ; Save value
  
  push x ; X pos
  push y ; Y pos
  call getIndex ; bx = 8y+x
  add bx,offset board ; In board
  
  mov al,[bx] ; Board array
  xor ah,ah ; ax = al
  
  mov bx,offset colors ; Get color from code
  add bx,ax ; Game code = index of color
  mov dl,[bx] ; Get color
  
  mov ax,x ; Get x to ax
  mov ah,25 ; AH = 25, AL = x
  mul ah ; AX = AL*AH
  add ax,1 ; Move one pixel to the right
  push ax ; drawSquare:x
  
  mov ax,y ; Get y to ax
  mov ah,25 ; AH = 25, AL = y
  mul ah ; AX = AL*AH
  add ax,1 ; move one pixel downwards
  push ax ; drawSquare:y
  
  push 23 ; drawSquare:len
  xor dh,dh ; DX = DL
  push dx ; drawSquare:col
  call drawSquare
  
  pop dx ; Load
  pop cx ; Load
  pop bx ; Load
  pop ax ; Load
  
  pop bp ; Load
  ret 4 ; Unallocate 2 parameters
endp

;;; PROC drawBoard
; Draws the board to the screen.
;;;
proc drawBoard
    push ax ; Save
    push bx ; Save
    push cx ; Save
    push dx ; Save
    
    mov cx,63 ; Loop counter
  
  dLoop: ; DrawLOOP
    mov ax,cx ; Get index in array
    and ax,7 ; ax = ax mod 8
    push ax ; drawBox:x
    
    mov ax,cx ; Get index in array
    shr ax,3 ; ax = ax / 8
    push ax ; drawBox:y

    call drawBox ; draw single box
    
    dec cx ; Next index
    cmp cx,0 ; Is 0?
    jge dLoop ; Loop until completion
  
    pop dx ; Load
    pop cx ; Load
    pop bx ; Load
    pop ax ; Load
    ret
endp

;;; PROC checkMines
; Checks the amount of mines next to position (x, y) and saves the amount to [board].
; @param x The row of the box in the game.
; @param y The column of the box in the game.
;;;
x equ [word ptr bp + 6] ; Solve Type Override warnings
y equ [word ptr bp + 4] ; Solve Type Override warnings
proc checkMines
    push bp ; Save
    mov bp,sp ; Allocate 2 parameters
    
    push ax ; Save
    push bx ; Save
    push cx ; Save
    push dx ; Save
    
    xor cl,cl ; CL will keep track of the friends.
    
  checkWallTop:
    ; Check for top wall
    cmp y,0 ; First row?
    je checkWallBottom ; Yes - no friend above
    
    ; Check for friend one row above
    dec y ; Get prevoius row
    
    push x ; X position
    push y ; Y position
    call getIndex ; BX = 8y+x
    add bx,offset mines
    add cl,[byte ptr bx] ; CL += [0|1]
    
    inc y ; Go back to this row
    
  checkWallBottom:
    ; Check for bottom wall
    cmp y,7 ; Bottom row?
    je checkWallLeft ; Yes - no friend below
    
    ; Check for friend below
    inc y ; Get next row
    
    push x ; X position
    push y ; Y position
    call getIndex ; BX = 8y+x
    add bx,offset mines
    add cl,[byte ptr bx] ; CL += [0|1]
    
    dec y ; Go back to this row
    
  checkWallLeft:
    ; Check for left wall
    cmp x,0 ; Left column?
    je checkWallRight
    
    ; Check for friend in left
    dec x ; Get prevoius column
    
    push x ; X position
    push y ; Y position
    call getIndex ; BX = 8y+x
    add bx,offset mines
    add cl,[byte ptr bx] ; CL += [0|1]
    
    inc x ; Go back to this column
  
  checkWallRight:
    ; Check for right wall
    cmp x,7 ; Right column?
    je finish
    
    ; Check for friend in right
    inc x ; Get next row
    
    push x ; X position
    push y ; Y position
    call getIndex ; BX = 8y+x
    add bx,offset mines
    add cl,[byte ptr bx] ; CL += [0|1]
    
    dec x ; Go back to this column
  
  finish:
    ; Move bx.pointer to boards[8y+x]
    push x
    push y
    call getIndex
    add bx,offset board
    
    inc cl ; Add 1 to get correct game code
    mov [byte ptr bx],cl ; Store game code in board.
    
    pop dx ; Load
    pop cx ; Load
    pop bx ; Load
    pop ax ; Load
    
    pop bp ; Load
    ret 4
endp

;;; PROC checkWin
; Checks the [board] array for victory.
; @returnTo AL - 1 if won, otherwise 0.
; @Overrides AX
;;;
proc checkWin
  push bx ; Save
  push cx ; Save
  xor ax,ax ; OVERRIDE
  mov bx,offset board ; Get board array
  mov cx,64 ; Loop counter
  
  checkVictoryLoop: ; Loop for array
    cmp [byte ptr bx],0 ; If there is an undiscovered plot
    je finCheckWin ; Then leave
    inc bx ; Next place in array
    loop checkVictoryLoop ; Loop until completion
  
  mov al,1 ; If loop completed, al = 1
  
  finCheckWin: ; End of proc
    pop cx ; Load
    pop bx ; Load
    ret
endp
