```assembly
IDEAL
MODEL small
STACK 100h
DATASEG
; Vars here

CODESEG
; Procs here

start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  ; Code here
  

exit:
mov ax,4C00h
int 21h
END start
```
