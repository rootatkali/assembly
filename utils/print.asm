; all labels and variables' names are jumbled so user doesn't need to reserve words for library

IDEAL
MODEL small
STACK 100h

DATASEG

nfieh db 5 dup (10)
cnsie db 10, 13, '$'
enahse db ', $'
nsnage db 0

CODESEG

proc cls
	push ax ; save ax
	mov ax, 0003h ; set BIOS interrupt as clear console
	int 10h ; BIOS interrupt
	pop ax ; restore ax
	ret
endp cls


num equ bp + 4 ; number to print in Hexadecimal base
proc printHex
	; save registers
	push bp
	mov bp, sp
	push ax
	push dx
	
	cmp [word ptr num], 0
	jne notZero
		mov dl, '0'
		mov ah, 2
		int 21h
		jmp numIsZero
	notZero:
	
	mov [nsnage], 0 ; pointer to when number starts and not zeros
	
	mov ax, [word ptr num] ; ax = number
	and ax, 0F000h ; only 4 highest bits
	shr ax, 12 ; move to beginning, to get digit
	cmp ax, 0 ; if its zero
	je sneix ; if not print
	mov [nsnage], 1 ; started printing, pointer is positive
	cmp ax, 10 ; is digit above or equal to 10
	jb esbi ; if not print as a digit
	add ax, 7 ; if yes increment by 7 to match characters
	esbi: ; jumbled label
	mov dl, al ; dl = al
	add dl, '0' ; from number to char
	mov ah, 2h ; print mode is character
	int 21h ; interrupt print
	sneix: ; jumbled label
	
	
	mov ax, [word ptr num] ; ax = number
	and ax, 0F00h ; only 4 second highest bits
	shr ax, 8 ; move to beginning, to get digit
	cmp ax, 0 ; if its zero
	jne enslgx1 ; if not print
	cmp [nsnage], 0 ; if zero and not started to print yet
	je sneix1 ; if so number hasn't started and don't print this 0
	enslgx1: ; label jumbled
	mov [nsnage], 1 ; started printing, pointer is positive
	cmp ax, 10 ; is digit above or equal to 10
	jb esbi1 ; if not print as a digit
	add ax, 7 ; if yes increment by 7 to match characters
	esbi1: ; jumbled label
	mov dl, al ; dl = al
	add dl, '0' ; from number to char
	mov ah, 2h ; print mode is character
	int 21h ; interrupt print
	sneix1: ; jumbled label
	
	mov ax, [word ptr num] ; ax = number
	and ax, 0F0h ; only 4 second lowest bits
	shr ax, 4 ; move to beginning, to get digit
	cmp ax, 0 ; if its zero
	jne enslgx2 ; if not print
	cmp [nsnage], 0 ; if zero and not started to print yet
	je sneix2 ; if so number hasn't started and don't print this 0
	enslgx2: ; label jumbled
	mov [nsnage], 1 ; started printing, pointer is positive
	cmp ax, 10 ; is digit above or equal to 10
	jb esbi2 ; if not print as a digit
	add ax, 7 ; if yes increment by 7 to match characters
	esbi2: ; jumbled label
	mov dl, al ; dl = al
	add dl, '0' ; from number to char
	mov ah, 2h ; print mode is character
	int 21h ; interrupt print
	sneix2: ; jumbled label
	
	push [num] ; save number
		mov ax, [word ptr num] ; ax = number
		and ax, 0Fh ; only 4 lowest bits
		cmp ax, 0 ; if its zero
		jne enslgx3 ; if not print
		cmp [nsnage], 0 ; if zero and not started to print yet
		je sneix3 ; if so number hasn't started and don't print this 0
		enslgx3: ; label jumbled
		mov [nsnage], 1 ; started printing, pointer is positive
		cmp ax, 10 ; is digit above or equal to 10
		jb esbi3 ; if not print as a digit
		add ax, 7 ; if yes increment by 7 to match characters
		esbi3: ; jumbled label
		mov dl, al ; dl = al
		add dl, '0' ; from number to char
		mov ah, 2h ; print mode is character
		int 21h ; interrupt print
	sneix3: ; jumbled label
	pop [num] ; restore number
	
	numIsZero:
	
	; restore registers
	pop dx
	pop ax
	pop bp
	ret 2 ; restore stack
endp printHex

num equ [word ptr bp + 4] ; number to print
proc printDec
	; save registers
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	cmp num, 0
	jne notZero2
		mov dl, '0'
		mov ah, 2
		int 21h
		jmp numIsZero2
	notZero2:
	
	mov cx, 5 ; cx = 5
	mov bx, offset nfieh ; bx = array location to store digits
	ensca: ; jumbled label
		mov [byte ptr bx], 10 ; reset digit array to invalid digit
		inc bx ; next digit
	loop ensca ; go through digits
		
	mov bx, offset nfieh
	mov ax, num  ; ax = number
	mov cx, 5
	ensunxe: ; jumbled label
		push cx
		
		xor dx, dx
		mov cx, 10 ; cl = 10
		div cx ; divide ax by 10, next digit
		mov [bx], dl ; mov remainder of division (the digit) to next cell in array
		
		inc bx ; next cell
		pop cx
	loop ensunxe ; if so number is done exit loop
	
	
	mov bx, offset nfieh ; bx = 5
	add bx, 5
	mov cx, 5
	mov [nsnage], 0
	uefj :
		dec bx ; bx -= 1
		mov dl, [bx] ; dl = digits[bx]
		cmp dl, 10 ; is dl 10
		jae nxeow ; if above or equal not a part of number don't print
		cmp [nsnage], 0
		ja naqk
		cmp dl, 0
		je nxeow
		naqk:
		inc [nsnage]
		add dl, '0' ; transform nubmer to char
		mov ah, 2 ; print mode char
		int 21h ; interrupt print
		nxeow: ; jumbled label
	loop uefj ; if above zero keep going
	
	numIsZero2:
	
	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2 ; restore stack
endp printDec	

num equ [word ptr bp + 4]
proc printBin
	push bp
	mov bp, sp
	push ax
	push cx
	push dx

	cmp num, 0
	jne notZero1
		mov dl, '0'
		mov ah, 2
		int 21h
		jmp numIsZero1
	notZero1:

	mov ax, num
	mov cx, 16
	
	iencd:
		push ax
		
		and ax, 8000h
		cmp ax, 8000h
		je vdfj
		mov dl, '0'
		jmp nrjslrivn
		vdfj:
		mov dl, '1'
		nrjslrivn:
		mov ah, 2
		int 21h
		
		pop ax
		shl ax, 1
	loop iencd
	
	numIsZero1:
	
	pop dx
	pop cx
	pop ax
	pop bp
	ret 2
endp printBin
	
arroff equ [bp + 6]
arrlen equ [bp + 4]
proc printArrDec
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	mov bx, arroff
	mov ah, 2
	
	mov dl, '['
	int 21h
	
	mov cx, arrlen
	xor dx, dx
	jemsfjeesje:
		push [bx]
		call printDec
		
		add bx, 2
		inc dx
		cmp dx, arrlen
		je ieseseij
		push dx
		mov dx, offset enahse
		mov ah, 9h
		int 21h
		mov ah, 2
		pop dx
		ieseseij:
	loop jemsfjeesje
	mov dl, ']'
	mov ah, 2
	int 21h
		
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4
endp printArrDec
	
	
	
arroff equ [bp + 6]
arrlen equ [bp + 4]
proc printArrHex
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	mov bx, arroff
	mov ah, 2
	
	mov dl, '['
	int 21h
	mov cx, arrlen
	xor dx, dx
	ienxdc:
		push [bx]
		call printHex
		
		add bx, 2
		inc dx
		cmp dx, arrlen
		je iesrvmsb
		push dx
		mov dx, offset enahse
		mov ah, 9h
		int 21h
		mov ah, 2
		pop dx
		iesrvmsb:
	loop ienxdc
	mov dl, ']'
	mov ah, 2
	int 21h
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4
endp printArrHex
	
	
	
arroff equ [bp + 6]
arrlen equ [bp + 4]
proc printArrBin
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	
	mov ah, 2
	mov dl, '['
	int 21h
	
	mov bx, arroff
	mov dx, 0
	mov cx, arrlen
	
	ienxlide:
		push [bx]
		call printBin
		
		add bx, 2
		inc dx
		
		cmp dx, arrlen
		je ienxleic
		push dx
		mov dx, offset enahse
		mov ah, 9
		int 21h
		mov ah, 2
		pop dx
		ienxleic:
	loop ienxlide
	
	mov dl, ']'
	mov ah, 2
	int 21h
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4
endp printArrBin
