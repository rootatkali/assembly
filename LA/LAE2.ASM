IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  lngth equ 10
  arr dw lngth dup(3)

CODESEG
; Procedures here

;;;
; Returns sum of array
; @param siz - the size of the array
; @param ofs - the array's offset
; @returnTo ax
; @Overrides ax
;;;
siz equ [bp + 6]
ofs equ [bp + 4]
proc sumArr
  push bp ; Params init
  mov bp,sp ; Params init
  xor ax,ax ; @OVERRIDE
  push bx ; Save
  push cx ; Save
  
  mov bx,ofs ; Address
  
  mov cx,siz ; Loop siz times
  lp:
    add ax,[bx] ; access arr
    add bx,2 ; Increase by word
    loop lp
  
  fin:
  pop cx ; Load (R.26)
  pop bx ; Load (R.25)
  pop bp ; Load (R.22)
  ret 4 ; Returns stack to 2*[2 params]
endp sumArr

start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  ; REMEMBER: Print character on dl, not al!!!!!!!!!!
  
  push lngth ; @param size
  push offset arr ; @param ofs
  call sumArr

exit:
mov ax,4c00h
int 21h
END start
