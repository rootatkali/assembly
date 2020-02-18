IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  lngth equ 3
  arr dw lngth dup(100h)

CODESEG
; Procedures here
;;; PROC swap
; Swaps between two values in word array
; @param ofs  - the array's offset
; @param idx1 - The first index
; @param idx2 - The second index
; @returnTo NULL
;;;
ofs equ [bp + 8]
idx1 equ [bp + 6]
idx2 equ [bp + 4]
proc swap
  push bp
  mov bp,sp
  
  push ax ; Save
  push bx ; Save
  mov bx,ofs ; Load arr to bx
  add bx,idx1 ; Get first index to ax
  mov ax,[bx] ; ax = arr[idx1]
  sub bx,idx1 ; Return bx to prev
  
  push dx ; Save
  add bx,idx2 ; Get second index to bx
  mov dx,[bx] ; dx = arr[idx2]
  sub bx,idx2 ; Return bx to prev
  
  add bx,idx2 ; Get to second index
  mov [bx],ax ; idx2 = idx1
  sub bx,idx2
  add bx,idx1
  mov [bx],dx ; idx1 = idx2
  
  pop dx
  pop bx
  pop ax
  pop bp
  ret 6 ; 6/2 = 3 params
endp swap

start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; CODE HERE
  ; REMEMBER: Print character on dl, not al!!!!!!!!!!
  mov bx,offset arr
  mov [bx],6969h
  add bx,2
  mov [bx],9696h
  
  ; CALL swap
  push offset arr ; @param ofs
  push 0 ;          @param idx1
  push 2 ;          @param idx2
  call swap

exit:
mov ax,4c00h
int 21h
END start
