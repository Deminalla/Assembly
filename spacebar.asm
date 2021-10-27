;Write a program that would print out the positions of spacebars in a string that the user input. For example, input asl A1p3i DI iiO would print 4 10 13
.MODEL small	;memory model
.STACK 100h		;stack size
.DATA		;data segment
buff db  100            ;the maximum amount of symbols we can input
     db  ?              ;how many symbols the user decided to enter, so ? because we don't know early on and the computer will count it itself later
     db  100 dup(0)     ;dup (duplicate) so 100dup(0) would be 100 times 0, this part also saves our inputs (it will end with 13 because enter)   
new_line db  0dh, 0ah, '$'  ;empty, we can use it as \n or andl
array db 100 dup(0)     ;the array saves 100 bytes of space which all are 0 for now       
.CODE		;code segment
strt:
mov ax,@data	;ds register initialization  
mov ds,ax               ;this command moves the DS the beginning of the paragraph's number to DS 

mov ah, 0Ah             ;input string with dx
mov dx, offset buff     ;let's check the limit of how much we can input
int 21h   
mov si, offset buff + 1 ;si = address of input symbols
mov cl, [si]            ;cl = amount of input symbols  
mov dl, 0               ;we will use dl later for smth else, so we neutralize it after the string input
 
testing:                ;check every single symbol
inc dl                  ;get the positions of the symbols    
inc si                  ;we need it to read from this part: 100dup(0) and not ?, inc si = byte ptr [si] + 1
mov al, byte ptr [si]   ;al = si th (n-th) element
cmp al, 20h             ;spacebar = 20h, 20h = ' ' which would be in char format instead of hex 
je spacebar             ;jump if equal
cmp dl, cl              ;check if we compared and analysed all the symbols 
jb testing              ;jump if its below/less than cl
jmp line                ;if we checked all symbols we can end this cycle

spacebar:
inc bx                 ;bx - amount of spacebars, so we know how may positions we need to output
mov di, offset array   ;di - address of the array   
mov [di+bx], dl        ;put the position of the spacebar into the array
cmp dl, cl
jb testing             ;continue checking other symbols

line:
mov ah, 9                ;string output
mov dx, offset new_line  ;this shows from where to start scanning, $ at the end of new_line shows where to stop
int 21h 

digit_amount: 
mov ah, 2         
mov dl, 20h     ;output spacebar 
int 21h         
inc di              
mov dl, [di]    ;dl = di th array element   
cmp dx, 9       
ja 2digits      ;if it's more than 9, it has 2 digits

add dx, 48      ;all of this is in char format so we find where the decimals are in char 
mov ah, 2       ;dl outputs the spacebar positions
int 21h 
sub bl, 1      
cmp bl, 0       ;we spin the cycle until there are no more spacebar positions left
jne digit_amount
jmp pabaiga

2digits: 
mov ax, dx    ;since it has only 2 digits, it will all fit into ax 
mov dx, 0     ;since its all in, we need to make dx=0
mov cx, 10     
div cx        ;dicide cx/10, ax = 1st digit, dx = 2nd digit (leftover)  
push dx       ;put the 2nd digit into stack so we don't lose it 
mov dx, ax    ;dx=ax, because we output with dl 
add dx, 48  
mov ah, 2
int 21h

pop dx        ;get the 2nd digit out of stack 
add dx, 48    
mov ah, 2
int 21h   
sub bl, 1
cmp bl, 0
jne digit_amount

pabaiga:
mov ax, 4C00h   ;the end of the program
int 21h
end strt
