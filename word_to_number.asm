.model small
.stack 100h
.data
	
read_buff db 10 dup (?)       ;this will help us read the file by 10 characters       
symbols dw 0                  ;to check how many symbols we have to read in a 10 element buffer or if its the end yet 
element dw ? 				  ;what character it is if not a digit
	
myfile db 100 dup(0)          ;1st file for reading
results db 100 dup(0)         ;2nd file for writing

input_descriptor dw ?         ;descripto is a number that helps identify the file its working with, so it doesn't confuse it with other stuff 
output_descriptor dw ? 
	
sos db "Programa jusu .txt faile parasyto teksto skaicius pavers zodiais. Pvz, as123 bus asvienasdutrys$" ;if gets /? or the parameters are incorrect
read_wrong db "Nepavyko perskaityti failo$" 
open_wrong db "Nepavyko atidaryti failo$" 
create_wrong db "Nepavyko sukurti failo$"
write_wrong db "Nepavyko rasyti i faila$"
new_line db  0dh, 0ah, '$'

nr_zero db "nulis$"
nr_one db "vienas$"
nr_two db "du$"
nr_three db "trys$"
nr_four db "keturi$"
nr_five db "penki$"
nr_six db "sesi$"       
nr_seven db "septyni$" 
nr_eight db "astuoni$" 
nr_nine db "devyni$"
.code
mov ax, @data
mov ds, ax

mov bx, 82h 
mov si, offset myfile 
mov di, offset results  
cmp byte ptr es:[80h], 0  ;no parameters were given, this shows length of command line string, so if its mycode then 6?
je get_help
cmp es:[82h], '?/'        ;/? but reads it in reverse
je get_help  

call file_name 	
call open_file     
call create_file 
	
reading:      
mov ah, 3Fh               ;read a file  
mov bx, input_descriptor  ;so it knkows which file to read
mov cx, 10                ;read 10 bytes
mov dx, offset read_buff  ;save the elements in that array for now
int 21h
jc error_read             ;an error when trying to read the file  

mov symbols, ax     ;how many symbols we found out of 10
cmp symbols, 0      ;if there's nothing left to read, end of file
je close_files    
mov si, dx          ;get the adress of read_buff
call write_file
jmp reading         ;after checking 10 or less symbols, repeat

get_help:
mov ah, 9
mov dx, offset sos  ;save our souls :D
int 21h
jmp finish

proc file_name  
duom_file: 
cmp byte ptr es:[bx], 13   ;if its enter we go back
je get_help
cmp byte ptr es:[bx], 20h  ;when its a space, that means afterwards comes rez.txt so we end this
je rez_file
mov dl, byte ptr es:[bx] 
mov [si], dl               ;fill in myfile 1 by 1 untill we get the whole name
inc bx
inc si
jmp duom_file 
rez_file:
inc bx     
cmp byte ptr es:[bx], 13 
je go_back
mov dl, byte ptr es:[bx] 
mov [di], dl  
inc di
jmp rez_file
go_back:
ret 
endp file_name

error_open:
mov ah, 9
mov dx, offset open_wrong    ;for example 1st file duom.txt doesn't exist
int 21h 
jmp finish   
error_read:
mov ah, 9
mov dx, offset read_wrong    
int 21h 
jmp finish   
error_create:
mov ah, 9
mov dx, offset create_wrong   
int 21h 
jmp finish   

close_files:
mov ah, 3Eh   ;close 1st file
mov bx, input_descriptor
int 21h
mov ah, 3Eh   ;close 2nd file
mov bx, output_descriptor
int 21h 
finish:
mov ah, 4Ch
int 21h
jmp the_end

proc open_file
mov ah, 3Dh               ;it means we will open a file 
mov al, 0                 ;0 means it's just for reading the file and nothing else
mov dx, offset myfile     ;dx is standard to use of reading
int 21h 
jc error_open             ;jump if carry flag is 1 (unsuccessful file opening??)
mov input_descriptor, ax  ;so we know which file this is exactly
ret  
endp open_file 

proc create_file
mov ah, 3Ch               ;create a new file for results
mov cx, 0     			  ;0 so it's only for reading
mov dx, offset results
int 21h 
jc error_create
mov output_descriptor, ax
ret
endp create_file

error_write:
mov ah, 9
mov dx, offset write_wrong    
int 21h 
jmp finish   

proc write_file 
cycle:  
jc error_write   
cmp byte ptr[si], '0'   
jne one 
mov ah, 40h
mov bx, output_descriptor
mov cx, 5    ;lenght of characters to print
mov dx, offset nr_zero
int  21h 
jmp testing   

one:
cmp byte ptr[si], '1'
jne two  
mov ah, 40h
mov bx, output_descriptor
mov cx, 6    ;lenght of characters to print
mov dx, offset nr_one
int  21h      
jmp testing

two:
cmp byte ptr[si], '2'
jne three   
mov ah, 40h
mov bx, output_descriptor
mov cx, 2  
mov dx, offset nr_two
int  21h  
jmp testing 

three:
cmp byte ptr[si], '3' 
jne four 
mov ah, 40h
mov bx, output_descriptor 
mov cx, 4  
mov dx, offset nr_three
int  21h 
jmp testing 

four:
cmp byte ptr[si], '4'   
jne five  
mov ah, 40h
mov bx, output_descriptor
mov cx, 6 
mov dx, offset nr_four
int  21h  
jmp testing  

five:
cmp byte ptr[si], '5'
jne six  
mov ah, 40h
mov bx, output_descriptor
mov cx, 5  
mov dx, offset nr_five
int  21h    
jmp testing    

six:                 
cmp byte ptr[si], '6'
jne seven
mov ah, 40h
mov bx, output_descriptor
mov cx, 4  
mov dx, offset nr_six
int  21h   
jmp testing    

seven:       
cmp byte ptr[si], '7'
jne eight  
mov ah, 40h
mov bx, output_descriptor
mov cx, 7  
mov dx, offset nr_seven
int  21h   
jmp testing 

continue:  
jmp cycle  ;otherwise its too big of a jump, out of range

eight:
cmp byte ptr[si], '8'
jne nine 
mov ah, 40h
mov bx, output_descriptor 
mov cx, 7  
mov dx, offset nr_eight
int  21h 
jmp testing

nine:
cmp byte ptr[si], '9'
jne end_of_line 
mov ah, 40h
mov bx, output_descriptor 
mov cx, 6  
mov dx, offset nr_nine
int  21h 
jmp testing

end_of_line:
cmp byte ptr[si], 13   ;0Dh after 13 always comes 10 as end of line and newline kind of thing so we do newline and ignore 10 later
jne non_number
mov ah, 40h
mov bx, output_descriptor
mov cx, 1  
mov dx, offset new_line
int  21h 
jmp testing 

non_number:
cmp byte ptr[si], 10   ;ignore 10 because its a combo of 13 and 10 meaning newline
je testing  
mov ax, [si]  
mov element, ax
mov ah, 40h
mov bx, output_descriptor
mov cx, 1  
mov dx, offset element 
int  21h  

testing:
inc si   
dec symbols  
mov cx, symbols
cmp cx, 0
jne continue 
ret   
endp write_file

the_end:	
END
