IDEAL
MODEL small
STACK 100h

DATASEG

	soundConst1 equ 0012h
	soundConst2 equ 34DCh


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