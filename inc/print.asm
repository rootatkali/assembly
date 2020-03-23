;;; PROC print
; Prints a string value to the console.
; @param string The offset of the string to print.
;;;
string equ [bp + 4]
proc print
  push bp
  mov bp,sp
  
  push ax
  push dx
  
  mov dx,string
  mov ah,09h
  int 21h
  
  pop dx
  pop ax
  
  pop bp
  ret 2
endp

;;; PROC printNum
; Prints a 16-bit number in its hexacademical form.
; @param num The number to print
; @var copy Copy of number.
;;;
num  equ [bp + 4]
copy equ [bp - 2]
proc printNum
  push bp
  mov bp,sp
  sub sp,2
  
  push ax
  push bx
  push dx
  mov bx,num
  mov copy,bx
  
  ; Print First digit
  shr bx,12
  cmp bx,09h
  jbe prntDig1
  add bx,7
  prntDig1:
  mov dl,bl
  add dl,30h
  mov ah,02h
  int 21h
  
  ; Print second digit
  mov bx,copy
  and bx,0F00h ; Isolate second digit
  shr bx,8
  cmp bx,09h
  jbe prntDig2
  add bx,7
  prntDig2:
  mov dl,bl
  add dl,30h
  mov ah,02h
  int 21h
  
  ; Print third digit
  mov bx,copy
  and bx,00F0h; Isolate third digit
  shr bx,4
  cmp bx,09h
  jbe prntDig3
  add bx,7
  prntDig3:
  mov dl,bl
  add dl,30h
  mov ah,02h
  int 21h
  
  ; Print fourth digit
  mov bx,copy
  and bx,000Fh
  cmp bx,09h
  jbe prntDig4
  add bx,7
  prntDig4:
  mov dl,bl
  add dl,30h
  mov ah,02h
  int 21h
  
  pop dx
  pop bx
  pop ax
  
  add sp,2
  pop bp
  ret 2
endp
