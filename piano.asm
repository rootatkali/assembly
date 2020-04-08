; author: Roy Nevo Michrowski
; 12/3/2020
;
;this program is a 4-key piano emulator
;4 white rectangles apear on the screen
;each time you press A, W, S or D a different note plays and a rectangle darkens accordingly
;Esc exits the program and releasing a key stops the note from playing

IDEAL
MODEL small
STACK 100h
DATASEG

	soundConst1 equ 0012h
	soundConst2 equ 34DCh
	ESCpress db 'ESC key pressed, terminating program...',10,13,'$' ; termination message

	last db 0 ; default value the check if key press\release is new

CODESEG

proc toText ; set console mode to text, 
	push ax ; save ax
	; BIOS settings for text mode interrupt
	mov ah, 0
	mov al, 2
	int 10h ; BIOS interrupt
	pop ax ; restore ax
	ret
endp toText

proc toGraphics ; set console mode to graphics
	push ax ; save ax
	; BIOS settings for graphic mode interrupt
	mov ax, 13h
	int 10h ; BIOS interrupt
	pop ax ; restore ax
	ret
endp toGraphics

x equ [bp + 8] ; x parameter
y equ [bp + 6] ; y parameter
col equ [bp + 4] ; color parameter
proc pixel
	;save registers
	push bp
	mov bp, sp ; set bp to current stack to access parameters via bp, even after pushes and pops. see lines 40 - 42
	push ax
	push bx
	push cx
	push dx
	
	xor bh, bh ; bh = 0
	mov cx, x ; cx = x
	mov dx, y ; dx = y
	mov al, col ; al = col
	mov ah, 0Ch ; BIOS interrupt setting to paint pixel
	int 10h ; BIOS interrupt
	
	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6 ; restore stack before parameters
endp pixel

x equ [bp + 10] ; x parameter
y equ [bp + 8] ; y parameter 
len equ [bp + 6] ; line length parameter
col equ [bp + 4] ; line color parameter
proc line
	; save registers
	push bp
	mov bp, sp ; set bp as current sp to access parameters via bp, even after pushes and pops. see lines 68 - 71
	push ax
	push bx
	push cx
	push dx
	
	mov cx, len ; set loop counter as line length
	mov ax, x ; set initial pixel x as line x
	lin:
		push ax ; give x parameter
		push y ; give y parameter
		push col ; give color parameter
		call pixel ; paint pixel
		inc ax ; increment x for next pixel, by that painting line
	loop lin ; loop line length, painting pixel by pixel the line

	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 8 ; restore stack before parameters
endp line

x equ [bp + 12] ; x parameter
y equ [bp + 10] ; y parameter
wid equ [bp + 8] ; rectangle width parameter
hi equ [bp + 6] ; rectangle height parameter
col equ [bp + 4] ; rectangle color parameter
proc rect
	; save registers
	push bp
	mov bp, sp ; set bp as currest sp to access parameters on stack via bp even after pushes and pops. see lines 100 - 104
	push ax
	push bx
	push cx
	push dx
	
	mov cx, hi ; set loop counter as rectangle height
	mov bx, y ; set initial line y as rectangle y
	column:
		push x ; give x paramter
		push bx ; give y parameter
		push wid ; give line length parameter
		push col ; give color parameter
		call line ; paint line
		inc bx ; increment line y
	loop column ; looping through rectangle lines line by line drawing the rectangle

	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 10 ; restore stack before parameters
endp rect

proc drawPiano
	
	; background color - white
	push 0 ; x is 0
	push 0 ; y is 0
	push 320 ; width is 320 - screen width
	push 200 ; height is 200 - screen height
	push 15 ; color is white
	call rect ; draw rect
	
	push cx ; save cx
	push ax ; save ax
	mov cx, 3
	mov ax, 80 ; first separation line x, 320 / 4 = 80
	;rect process is used instead of line since line makes horizontal line not vertical
	separate:
		push ax ; ax is line x
		push 0 ; y
		push 1 ; width
		push 200 ; height
		push 0 ; color is black
		call rect ; paint vertical black line to separate keys
		add ax, 80 ; add 80 to x for next line
	loop separate
	pop ax ; restore ax
	pop cx ; restore cx
	
	ret
endp drawPiano

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

call toGraphics
call drawPiano

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
	push 0 ; x is 0
	push 0 ; y is 0
	push 80 ; width is 79, so you dont override separation line
	push 200 ; height is 200
	push 7 ; color is light gray
	call rect

	keyA:
	
	cmp al, 11h ; is key W pressed
	jne keyW ; if not don't make sound
	call activateSpeaker ; turn speaker on
	push 200 ; play sound at 200 Hz
	call makeSound ; call pitch set
	push 81 ; x is 81, so you dont override separation line
	push 0 ; y is 0
	push 79 ; width is 79, so you dont override separation line
	push 200 ; height is 200
	push 7 ; color is light gray
	call rect

	keyW:
	
	cmp al, 1Fh ; is key S pressed
	jne keyS ; if not don't play sound
	call activateSpeaker ; turn speaker on
	push 300 ; play sound at 300 Hz
	call makeSound ; call pitch set
	push 161 ; x is 161, so you dont override separation line
	push 0 ; y is 0
	push 79 ; width is 79, so you dont override separation line
	push 200 ; height is 200
	push 7 ; color is light gray
	call rect
	keyS:
		
	cmp al, 20h ; is key D pressed
	jne keyD ; if not don't play sound
	call activateSpeaker ; turn speaker off
	push 400 ; play sound at 400 Hz
	call makeSound ; call pitch set
	push 241 ; x is 241, so you dont override separation line
	push 0 ; y is 0
	push 79 ; width is 79, up to end of screen
	push 200 ; height is 200
	push 7 ; color is light gray
	call rect
	keyD:
	
	cmp al, 9Eh ; is A released
	jne relA ; if not don't turn off
	call deactivateSpeaker ; turn speaker off
	push 0 ; x is 0
	push 0 ; y is 0
	push 80 ; width is 79, so you dont override separation line
	push 200 ; height is 200
	push 15 ; color is white
	call rect
	relA:
	
	cmp al, 91h ; is W released
	jne relW ; if not don't turn off
	call deactivateSpeaker ; turn speaker off
	push 81 ; x is 81, so you dont override separation line
	push 0 ; y is 0
	push 79 ; width is 79, so you dont override separation line
	push 200 ; height is 200
	push 15 ; color is white
	call rect
	relW:
	
	cmp al, 9Fh ; is S released
	jne relS ; if not don't turn off
	call deactivateSpeaker ; turn speaker off
	push 161 ; x is 161, so you dont override separation line
	push 0 ; y is 0
	push 79 ; width is 79, so you dont override separation line
	push 200 ; height is 200
	push 15 ; color is white
	call rect
	relS:
	
	cmp al, 0A0h ; is D released
	jne relD ; if not don't turn off
	call deactivateSpeaker ; turn speaker off
	push 241 ; x is 241, so you dont override separation line
	push 0 ; y is 0
	push 79 ; width is 79, up to end of screen
	push 200 ; height is 200
	push 15 ; color is white
	call rect
	relD:
	
	jmp waitForPress ; go back to listen for key

exit:
call toText
mov ax,4c00h
int 21h
END start
