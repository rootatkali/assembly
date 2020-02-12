IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  lngth equ 10
  arr db lngth dup(0)

CODESEG
; Procedures here

siz equ [bp + 6];Param size
ofs equ [bp + 4];Param offset
proc writeArr
  push bp
  mov bp,sp;Param
  push bx;Save bx
  mov bx, ofs;bx=arr[0]
  push cx;Save cx
  mov cx, siz;loop <siz> times
  push dx;Save dx
  xor dx,dx;dx = 0
  
  lp:
    inc dx
    mov [bx],dl;dx for word arr
    inc bx;add bx, 2 for word arr
    loop lp
  
  fin:
  pop dx;restore registers
  pop cx
  pop bx
  pop bp
  ret 4;clean stack
endp writeArr

start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  ; REMEMBER: Print character on dl, not al!!!!!!!!!!
  push lngth;give length of array as Param
  push offset arr;give address of array as Param
  call writeArr;call function

exit:
mov ax,4c00h
int 21h
END start
