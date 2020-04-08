; author: Roy Nevo Michrowski
; 12/3/2020
;
;this program listens to the keyboard for the release or press of the keys A, W, S, D and Esc
;if it recognizes a press of A, W, S, D		it plays a sound of different pitches for each key
;if it recognizes a release of any key, it turns the speaker off by that stopping the sound
;if the Esc key is pressed the program terminates

IDEAL
MODEL small
STACK 100h
DATASEG

	soundConst1 equ 0012h
	soundConst2 equ 34DCh
	ESCpress db 'ESC key pressed, terminating program...',10,13,'$' ; termination message

	last db 0 ; default value the check if key press\release is new

CODESEG

proc activateSpeaker
	push ax ; save ax
	; set of commands to turn speaker on
	in al, 61h
	or al, 00000011b
	out 61h, al
	pop ax ; restore ax
	ret
endp activateSpeaker


proc deactivateSpeaker
	push ax ; save ax
	;set of commands to turn speaker off
	in al, 61h
	and al, 11111100b
	out 61h, al
	pop ax ; restore ax
	ret
endp deactivateSpeaker

pitch equ [bp + 4] ; sound frequency parameter
proc makeSound
	; save registers
	push bp
	mov bp, sp ; set bp as current stack to access parameter via bp without concern to other pushes and pops, see line 43
	push ax
	push cx
	push dx
	
	; set of commands to enable pitch set
	mov al, 0B6h
	out 43h, al 
	mov ax, soundConst2 ; set of constant for 32bit div
	mov dx, soundConst1
	mov cx, pitch ; set cx to divider AKA frequency
	div cx ; divide dx:ax by cx, save result in ax, we don't need the remainder
	out 42h, al ; send lower byte
	xchg al, ah ; switch lower and upper
	out 42h, al ; send upper byte
	
	;restore registers
	pop dx
	pop cx
	pop ax
	pop bp
	ret 2 ; restore stack before parameters
endp makeSound


start:
  mov ax,@data
  mov ds,ax
  xor ax,ax ; ax = 0
  
  waitForPress:
    in al,64h ; get keyboard status
    cmp al,10b ; is data new
    je waitForPress ; if not, try again
    in al,60h ; Get key from keyboard
	
	cmp al, [last] ; is key different from last time
	je waitForPress ; if so don't do anything and wait for change
	
	mov [last], al ; if new then last key pressed is the key pressed currently
	
    cmp al,01h ; is key Esc
    jne ESCp ; if not don't terminate
    mov dx,offset ESCpress ; set message to termination message
    mov ah,09h ; set print mode to string
    int 21h ; interrupt print
	call deactivateSpeaker ; turn speaker off
    jmp exit ; terminate program
	EscP:
    
	cmp al, 1Eh ; is key A pressed
	jne keyA ; if not don't make sound
	call activateSpeaker ; turn speaker on
	push 100 ; play sound at 100 Hz
	call makeSound ; call pitch set
	keyA:
	
	cmp al, 11h ; is key W pressed
	jne keyW ; if not don't make sound
	call activateSpeaker ; turn speaker on
	push 200 ; play sound at 200 Hz
	call makeSound ; call pitch set
	keyW:
	
	cmp al, 1Fh ; is key S pressed
	jne keyS ; if not don't play sound
	call activateSpeaker ; turn speaker on
	push 300 ; play sound at 300 Hz
	call makeSound ; call pitch set
	keyS:
		
	cmp al, 20h ; is key D pressed
	jne keyD ; if not don't play sound
	call activateSpeaker ; turn speaker off
	push 400 ; play sound at 400 Hz
	call makeSound ; call pitch set
	keyD:
	
	cmp al, 80h ; is any key released
	jna release ; if not don't turn off
	call deactivateSpeaker ; turn speaker off
	release:
	
    jmp waitForPress ; go back to listen for key

exit:
mov ax,4c00h
int 21h
END start
