; MOODLE TASK 3
; AUTHOR - ROTEM MOSES
; DATE - 11 MARCH 2020

; General explanation:
; Proc playSound accepts a tone parameter and plays it through the speaker.
; Proc stopSpeaker stops the speaker.
; Port 64h listens for new key. Each [WASD] key press plays a different sound. Each release calls
; stopSpeaker. A release of the ESC key terminates.

IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  
  ; KEY PRESSES AND RELEASES
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
; Procedures here

;;; PROC playSound
; Opens the speaker unit and plays a sound.
; @param tone The tone to play.
;;;
tone equ [bp + 4]
proc playSound
  push bp
  mov bp,sp
  push ax
  
  ; Start speaker
  in al,61h
  or al,11b
  out 61h,al
  
  ; Get speaker access
  mov al,0B6h
  out 43h,al
  
  ; Send sound to speaker
  mov ax,tone
  out 42h,al ; Send first byte
  shr ax,8 ; Equal in result to "mov al,ah" but quicker
  out 42h,al ; Send second byte
  
  pop ax
  pop bp
  ret 2
endp

;;; PROC stopSpeaker
; Stops the speaker.
;;;
proc stopSpeaker
  push ax
  in al,61h ; Get speaker status
  and al,11111100b ; Set last two bits to 0
  out 61h,al ; Update status
  pop ax
  ret
endp

; Sounds set values
wSound equ 0A97h ; 1193180 / 440 -> hex
aSound equ 0974h ; 1193180 / 493 -> hex
sSound equ 08E9h ; 1193180 / 523 -> hex
dSound equ 07F0h ; 1193180 / 587 -> hex

start:
  mov ax,@data
  mov ds,ax
  xor ax,ax

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
  
  cmp al,20h ;scan code for D
  je d ; D pressed?
  
  cmp al,1Fh ; scan code for S
  je s ; S pressed?
  
  cmp al,11h ; scan code for W
  je w ; W pressed?
  
  cmp al,9Eh ; Scan code for A release
  je ar
  
  cmp al,0A0h ; Scan code for D release
  je dr
  
  cmp al,9Fh ; Scan code for S release
  je srJmp
  
  cmp al,91h ; Scan code for W release
  je wrJmp
  
  cmp al,81h ; scan code for ESC
  je eJmp ; ESC pressed?
  
  jmp waitfordata ; loop until termination


a: ; when A is pressed
  mov dx,offset msgA; Print string msgA
  mov ah,09h
  int 21h
  
  push aSound ; tone
  call playSound
  
  jmp waitfordata ; return to the wait loop

d: ; when D is pressed
  mov dx,offset msgD; Print string msgD
  mov ah,09h
  int 21h
  
  push dSound ; tone
  call playSound
  
  jmp waitfordata ; return to the wait loop

s: ; when S is pressed
  mov dx,offset msgS; Print string msgS
  mov ah,09h
  int 21h
  
  push sSound ; tone
  call playSound
  
  jmp waitfordata ; return to the wait loop

w: ; when D is pressed
  mov dx,offset msgW; Print string msgW
  mov ah,09h
  int 21h
  
  push wSound ; tone
  call playSound
  
  jmp waitfordata ; return to the wait loop
  
; Fix out of range jumps:
srJmp:
  jmp sr
wrJmp:
  jmp wr
eJmp:
  jmp e

ar: ; when A is released
  mov dx,offset msgAR; Print string msgAR
  mov ah,09h
  int 21h
  
  call stopSpeaker
  
  jmp waitfordata ; return to the wait loop

dr: ; when D is released
  mov dx,offset msgDR; Print string msgDR
  mov ah,09h
  int 21h
  
  call stopSpeaker
  
  jmp waitfordata ; return to the wait loop

sr: ; when S is released
  mov dx,offset msgSR; Print string msgSR
  mov ah,09h
  int 21h
  
  call stopSpeaker
  
  jmp waitfordata ; return to the wait loop

wr: ; when W is released
  mov dx,offset msgWR; Print string msgWR
  mov ah,09h
  int 21h
  
  call stopSpeaker
  
  jmp waitfordata ; return to the wait loop

e: ; when ESC is pressed
  mov dx,offset msgE; Print string msgE
  mov ah,09h
  int 21h
  
  call stopSpeaker

exit:
mov ax,4c00h
int 21h
END start
