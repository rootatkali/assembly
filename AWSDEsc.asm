; author: Roy Nevo Michrowski
; 12/3/2020
;
;this program listens to the keyboard for the release or press of the keys A, W, S, D and Esc
;if it recognizes a press\release of A, W, S, D		it prints an appropriate message:
;[key] - the key pressed\released "[key] key pressed\released"
;if the Esc key is pressed the program terminates

IDEAL
MODEL small
STACK 100h
DATASEG
  ; VARIABLES HERE
  ESCpress db 'ESC key pressed, terminating program...',10,13,'$' ; termination message

  Apress db 'A key pressed',10,13,'$' ;A pressed message
  Arel db 'A key released',10,13,'$' ;A released message

  Wpress db 'W key pressed',10,13,'$' ;W pressed message
  Wrel db 'W key released',10,13,'$' ;W released message

  Spress db 'S key pressed',10,13,'$' ;S pressed message
  Srel db 'S key released',10,13,'$' ;S released message

  Dpress db 'D key pressed',10,13,'$' ;D pressed message
  Drel db 'D key released',10,13,'$' ;D released message
  
  last db 0 ; default value the check if key press\release is new

CODESEG

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
    jmp exit ; terminate program
	EscP:
    
	cmp al, 1Eh ; is key A pressed
	jne keyA ; if not don't print
	mov dx, offset Apress ; set message to A pressed
	mov ah, 09h ; set print mode to string
	int 21h ; interrupt print
	keyA:
	
	cmp al, 9Eh ; is key A released
	jne relA ; if not don't print
	mov dx, offset Arel ; set message to A released
	mov ah, 09h ; set print mode to string
	int 21h ; interrupt print
	relA:
	
	cmp al, 11h ; is key W pressed
	jne keyW ; if not don't print
	mov dx, offset Wpress ; set print message to W pressed
	mov ah, 09h ; set print mode to string
	int 21h ; interrupt print
	keyW:
	
	cmp al, 91h ; is key W released
	jne relW ; if not don't print
	mov dx, offset Wrel ; set print message to W released
	mov ah, 09h ; set print mode as string
	int 21h ; interrupt print
	relW:
	
	cmp al, 1Fh ; is key S pressed
	jne keyS ; if not don't print
	mov dx, offset Spress ; set print message to S pressed
	mov ah, 09h ; set print mode as string
	int 21h ; interrupt print
	keyS:
	
	cmp al, 9Fh ; is key S release
	jne relS ; if not don't print
	mov dx, offset Srel ; set print message as S released
	mov ah, 09h ; set print mode as string
	int 21h ; interrupt print
	relS:
	
	cmp al, 20h ; is key D pressed
	jne keyD ; if not don't print
	mov dx, offset Dpress ; set print message as D pressed
	mov ah, 09h ; set print mode as string
	int 21h ; interrupt print
	keyD:
	
	cmp al, 0A0h ; is key D released
	jne relD ; if not don't print
	mov dx, offset Drel ; set print message as D released
	mov ah, 09h ; set print mode as string
	int 21h ; inetrrupt print
	relD:
	
    jmp waitForPress ; go back to listen for key

exit:
mov ax,4c00h
int 21h
END start
