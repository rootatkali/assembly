; MOODLE TASK 1
; AUTHOR - ROTEM MOSES
; DATE - 11 MARCH 2020

; General explanation:
; Proc reads a key from port 60h, after getting status from port 64h.
; Proc prints an according message, and stops when ESC is released.

IDEAL
MODEL small
STACK 100h
DATASEG
    msgA db 'A pressed',10,13,'$' ; A key is pressed
    msgD db 'D pressed',10,13,'$' ; D key is pressed
    msgS db 'S pressed',10,13,'$' ; S key is pressed
    msgW db 'W pressed',10,13,'$' ; W key is pressed
    
    msgAR db 'A released',10,13,'$' ; A key is released
    msgDR db 'D released',10,13,'$' ; D key is released
    msgSR db 'S released',10,13,'$' ; S key is released
    msgWR db 'W released',10,13,'$' ; W key is released
    
    msgE db 'ESC pressed, terminating...',10,13,'$' ; ESC pressed
    msgRL db 'Key released',10,13,'$'
    
    last db 0 ; Last key pressed

CODESEG

;;; wasd
; Runs a loop to accept user input of the WASD characters.
; Terminates on ESC press.
; @Overrides NULL.
;;;
proc wasd
  push bp
  push ax
  push dx
  
  ;BIOS
  waitForData: ; Wait for key press
    ; Status
    in al,64h
    cmp al,10b
    je waitForData
    in al,60h ; Key
    
    cmp [last],al ; Last key
    je waitForData
    
    mov [last],al
    
    cmp al,1Eh ; scan code for A
    je a ; A pressed?
    
    cmp al,9Eh
    je ar
    
    cmp al,20h ;scan code for D
    je d ; D pressed?
    
    cmp al,0A0h
    je dr
    
    cmp al,1Fh ; scan code for S
    je s ; S pressed?
    
    cmp al,9Fh
    je sr
    
    cmp al,11h ; scan code for W
    je w ; W pressed?
    
    cmp al,91h
    je wr
    
    cmp al,81h ; scan code for ESC
    je e ; ESC pressed?
    
    jmp waitfordata ; loop until termination
  
  
  a: ; when A is pressed
    mov dx,offset msgA; Print string msgA
    mov ah,09h
    int 21h
    jmp waitfordata ; return to the wait loop

  d: ; when D is pressed
    mov dx,offset msgD; Print string msgD
    mov ah,09h
    int 21h
    jmp waitfordata ; return to the wait loop

  s: ; when S is pressed
    mov dx,offset msgS; Print string msgS
    mov ah,09h
    int 21h
    jmp waitfordata ; return to the wait loop

  w: ; when D is pressed
    mov dx,offset msgW; Print string msgW
    mov ah,09h
    int 21h
    jmp waitfordata ; return to the wait loop

  ar: ; when A is released
    mov dx,offset msgAR; Print string msgAR
    mov ah,09h
    int 21h
    jmp waitfordata ; return to the wait loop

  dr: ; when D is released
    mov dx,offset msgDR; Print string msgDR
    mov ah,09h
    int 21h
    jmp waitfordata ; return to the wait loop

  sr: ; when S is released
    mov dx,offset msgSR; Print string msgSR
    mov ah,09h
    int 21h
    jmp waitfordata ; return to the wait loop

  wr: ; when W is released
    mov dx,offset msgWR; Print string msgWR
    mov ah,09h
    int 21h
    jmp waitfordata ; return to the wait loop

  e: ; when ESC is pressed
    mov dx,offset msgE; Print string msgE
    mov ah,09h
    int 21h
    pop dx
    pop ax
    pop bp
    ret
endp

start:
  mov ax,@data
  mov ds,ax
  xor ax,ax
  
  ; CODE HERE
  call wasd

exit:
  mov ax,4c00h
  int 21h
END start