IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  lngth equ 10
  arr db lngth dup(0)

CODESEG
; Procedures here

siz equ [bp + 6]
ofs equ [bp + 4]
proc writeArr
  push bp
  mov bp,sp
  push bx
  mov bx,ofs
  push cx
  
  mov cx,siz
  push dx
  xor dx,dx
  
  lp:
    inc dx
    mov [bx],dl
    inc bx
    loop lp
  
  fin:
  pop dx
  pop cx
  pop bx
  pop bp
  ret 4
endp writeArr

start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  ; REMEMBER: Print character on dl, not al!!!!!!!!!!
  push lngth
  push offset arr
  call writeArr

exit:
mov ax,4c00h
int 21h
END start
