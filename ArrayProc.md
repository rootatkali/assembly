# Array procedure accepting 2 params (size, offset)

```assembly
siz equ [bp + 6] ; Size of array
ofs equ [bp + 4] ; Offset of array
proc NAME
  push bp
  mov bp,sp
  
  push bx
  mov bx,ofs ; Move offset to bx
  
  push cx
  mov cx,siz ; Loop $siz times
  lp:
    ; ...
    add bx,2 ; for WORD arrays
    ; OR
    inc bx ; for BYTE arrays
    loop lp
  
  pop cx
  pop bx
  pop bp
  ret 4
endp NAME
```
