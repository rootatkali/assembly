; author: Roy Nevo Michrowski
; This program is a painting program, based on the mouse and keyboard
; When pressed a circle will be drawn near the mouse location in chosen color and size
; The size and color are chosen by the keyboard, from sizes 2px - 20px, color indices 0 - 9
; The program uses a libraries i created for graphics, mouse and keyboard input, and console handling

IDEAL
MODEL small
STACK 100h

DATASEG

color dw 15
siz dw 1
manual db "press 'c' to clear screen, ESC to exit program", 10, "1 - 0, brush sizes, 0 is 10 px", 10, "Q - P keys for colors, NOT MATCHING KEY TO COLOR", 10, "press any key to launch$"

CODESEG

include "utils\print.asm" ; console handling library
include "utils\UI.asm" ; User Input library
include "utils\Graphics.asm" ; Graphics library

start:
mov ax, @data
mov ds, ax

call cls ; clear console for program manual message

mov dx, offset manual ; set message as program manual
mov ah, 9 ; set print mode as string
int 21h ; interrupt print

xor ah, ah ; ah = 0
int 16h ; wait for any keyboard input


call toGraphics ; move to graphics mode
call initMouse ; init mouse on screen


waitForPress:
	in al, 64h ; get keyboard status
	cmp al, 10b ; is keyboard online
	je waitForPress ; if not check again until it is
	in al, 60h ; get key from keyboard
	
	cmp al, 01h ; was ESC pressed
	je exit1 ; if so exit program
	
	cmp al, 2Eh ; was C pressed
	jne notclear ; if not dont clear screen
	; black rect on all screen, clear screen
	push 0
	push 0
	push 320
	push 200
	push 0
	call rect
	;mov mouse because of DOSBOX bug, doesn't delete graphics under mouse
	call initMouse
	; clear screen again, to cover rect protected by mouse
	push 0
	push 0
	push 320
	push 200
	push 0
	call rect	
	call initMouse
	notclear:

		; middle jump for return to loop at end of program
	jmp press1 ; ignore when not jumped to press
	press:
	jmp waitForPress ; middle jump to loop waitForPress
	press1: ; skip label

	;middle jump for exit
	jmp onexit ; skip when not jumped to directly
	exit1:
	jmp exit ; middle jump to exit
	onexit:
		
		; is key between 1 - 0 pressed
	cmp al, 2h ; is key above or equal to 1 pressed
	jb notbrush ; if not don't set brush size
	cmp al, 0Bh ; is key below or equal to 0 pressed
	ja notbrush ; if not don't set brush size
	mov [byte ptr siz], al ; set brush size to key pressed
	dec [siz] ; to math key index to actual value - key 1(2h) should be 1
	shl [siz], 1 ; multiply by two for bigger brush size
	notbrush:

		; is key between Q - O pressed
	cmp al, 10h ; is key above or equal to Q pressed
	jb notcolor ; if not don't set brush color
	cmp al, 18h ; is key below or equal to P pressed
	ja notcolor ; if not don't set brush color
	mov [byte ptr color], al ; set color as key index
	sub [byte ptr color], 16 ; map key index to colors 0 - 8
	notcolor:
	
	cmp al, 19h ; is key P pressed
	jne notwhite ; if not don't set color as white
	mov [color], 15 ; set color as white
	notwhite:
	
	call getMouseData ; get mouse data, pressed\not, coordinates, from library UI
	
	
	cmp bx, 01b ; was left key pressed
	jne press ; if not don't paint
	sub dx, [siz] ; move paint location so mouse doesn't overlap fixing DOS bug that mouse leaves mark
	sub cx, [siz] ; move paint location so mouse doesn't overlap fixing DOS bug that mouse leaves mark
	push cx ; x = cx
	push dx ; y = dx
	push [siz] ; radius = brushsize
	push [color] ; color = color
	call fill_circle ; paint circle
	
	jmp press ; back to loop 

exit:
call toText ; exit graphics mode
mov ax, 4c00h
int 21h
END start

