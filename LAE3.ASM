IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  lngth equ 3
  arr dw lngth dup(100h)

CODESEG
; Procedures here
;;; PROC findMinIdx
; Returns index of min value in unsigned word array
; @param siz - the size of the array
; @param ofs - the array's offset
; @var min - Current minimum value
; @returnTo ax
; @Overrides ax
;;;
siz equ [bp + 6]
ofs equ [bp + 4]
min equ [bp - 2]
proc findMinIdx
  push bp ; Params init
  mov bp,sp ; Params init
  sub sp,2 ; Allocate 2/2=1 local var
  
  push bx ; Save
  mov bx,ofs ; Address
  
  push dx ; Save
  mov dx,[bx] ; Move first item to min
  mov min,dx ; Move first item to min
  
  xor dx,dx ; dx for value
  
  ; @Override
  xor ax,ax ; Initial min index is 0 
  
  push cx ; Save
  
  mov cx,siz ; Loop siz times
  lp:
    mov dx,[bx] ; Move current array value to dx
    cmp dx,min ; current < min ?
    jb ifMin ; Yes = ifMin
    jmp next ; Continue loop
    
  ifMin:
    mov ax,bx ; ax = offset + index
    sub ax,ofs ; ax = offset + index - offset = index
  
  next:
    add bx,2 ; Increase bx to next value
    dec cx ; loop checks
    cmp cx,0 ; cx != 0 ?
    jne lp ; Re-run loop
  
  pop cx ; Load
  pop dx ; Load
  pop bx ; Load
  add sp,2 ; de-allocate local var
  pop bp ; Load
  ret 4 ; Two parameters
endp findMinIdx

start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  
  ; Initialize array with [15h, 69h, 09h]
  mov bx,offset arr
  mov [bx],15h
  add bx,2
  mov [bx],69h
  add bx,2
  mov [bx],09h
  
  xor bx,bx
  
  ; CALL findMinIdx
  push lngth      ; @param siz
  push offset arr ; @param ofs
  call findMinIdx

exit:
mov ax,4c00h
int 21h
END start
