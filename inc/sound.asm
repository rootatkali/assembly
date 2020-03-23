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
