.model small       
.stack 100h
.data    

read_buff db 10 dup (?)     ;this will help us read the file character by 10 characters       
symbols dw 0                ;to check how many symbols we have to read in 10 element buffer or if its the end yet 
element dw ?

command_duom db 100 dup(0)  ;i think this might be the thing instead of myfile?
command_rez db 100 dup(0)
myfile db  "duom.txt", 0    ;i picked the name myfile, 0 shows the end of the filename string, the txt file is in emu8086/MyBuild 
results db "rez.txt", 0     ;my second file 
input_descriptor dw ?       ;its a number that helps identify the file its working with   
output_descriptor dw ? 
command_descriptor dw ? 

sos db "Si programa jusu .txt faile parasyto teksto skaicius pavers zodiais. Pvz, as12 bus asvienasdu$" ;if nothing is given or it only gets /? 
smth_wrong db "Ivyko klaida$" ;literally any type of error
new_line db  0dh, 0ah, '$'

nr_zero db "nulis$"
nr_one db "vienas$"
nr_two db "du$"
nr_three db "trys$"
nr_four db "keturi$"
nr_five db "penki$"
nr_six db "sesi$"      ;fix the letters?  
nr_seven db "septyni$" 
nr_eight db "astuoni$" ;fix the letters?
nr_nine db "devyni$"
.code
strt:    
mov ax,@data
mov ds, ax     

mov di, offset command_duom 
mov bp, offset command_rez
cmp byte ptr es:[80h], 0  ;no parameters were given
je get_help  
cmp es:[82h], '/?'
je get_help 
cmp es:[84h], 13 ;enter after 2 parameters  
call two_param

call open_file     
call create_file  

reading:       
mov ah, 3Fh              ;this will read the 1st file  
mov bx, input_descriptor ;so it knkows which file to read
mov cx, 10                ;so it will read 10 bytes
mov dx, offset read_buff ;this will save the elements in that array for now
int 21h
jc error          ;an error when trying to read the file  

mov symbols, ax
cmp symbols, 0         ;if there's nothing left to read, end of file
je finish  
mov si, dx 
call write_file
jmp reading

get_help:
mov ah, 9
mov dx, offset sos
int 21h
jmp finish

error:
mov ah, 9
mov dx, offset smth_wrong      ;for example 1st file duom,txt doesn't exist
int 21h 

finish: 
mov ah, 3Eh   ;close 1st file
mov bx, input_descriptor
int 21h

mov ah, 3Eh   ;close 2nd file
mov bx, output_descriptor
int 21h  

mov ax, 4Ch	  ;yep i wrote the finishing function in the middle :)	
int 21h

proc two_param
;add stuff later
mov dl, byte ptr es:[82h] 
mov [di], dl  ;command_duom 
mov, dl byte ptr es:[84h]
mov [bp], dl  ;command_rez
ret
endp two_param

proc open_file
mov ah, 3Dh    ;it means we will open a file 
mov al, 0      ;0 means it's just for reading the file and nothing else
mov dx, offset myfile ;dx is standard to use of reading
int 21h 
jc error       ;jump if carry flag is 1 (unsuccessful file opening??)
mov input_descriptor, ax ;so we know which file this is exactly
ret  
endp open_file ;should i swap places and make it open_file endp?

proc create_file
mov ah, 3Ch    ;create a new file for results
mov cx, 0      ;0 so it's only for reading
mov dx, offset results
int 21h 
mov output_descriptor, ax
ret
endp create_file 

proc write_file 
ciklas:  
jc error   ;unable to write anything, yep this is necessary
cmp byte ptr[si], '0'  
jne one 
mov ah, 40h
mov bx, output_descriptor
mov cx, 5  ;STRING LENGTH.
mov dx, offset nr_zero
int  21h 
jmp middle   

one:
cmp byte ptr[si], '1'
jne two  
mov ah, 40h
mov bx, output_descriptor
mov cx, 6  ;STRING LENGTH.
mov dx, offset nr_one
int  21h      
jmp middle

two:
cmp byte ptr[si], '2'
jne three   
mov ah, 40h
mov bx, output_descriptor
mov cx, 2  ;STRING LENGTH.
mov dx, offset nr_two
int  21h  
jmp middle 

three:
cmp byte ptr[si], '3' 
jne four 
mov ah, 40h
mov bx, output_descriptor 
mov cx, 4  ;STRING LENGTH.
mov dx, offset nr_three
int  21h 
jmp middle 

continue2: ;continue1 and continue2 is necessary because otherwise the jumps are out of range
jmp ciklas

four:
cmp byte ptr[si], '4'   
jne five  
mov ah, 40h
mov bx, output_descriptor
mov cx, 6  ;STRING LENGTH.
mov dx, offset nr_four
int  21h  
jmp middle  

five:
cmp byte ptr[si], '5'
jne six  
mov ah, 40h
mov bx, output_descriptor
mov cx, 5  ;STRING LENGTH.
mov dx, offset nr_five
int  21h    
middle:
jmp testing    

six:                 
cmp byte ptr[si], '6'
jne seven
mov ah, 40h
mov bx, output_descriptor
mov cx, 4  ;STRING LENGTH.
mov dx, offset nr_six
int  21h   
jmp testing    

seven:       
cmp byte ptr[si], '7'
jne eight  
mov ah, 40h
mov bx, output_descriptor
mov cx, 7  ;STRING LENGTH.
mov dx, offset nr_seven
int  21h   
jmp testing 

continue1:  ;otherwise its too big of a jump
jmp continue2 ;it doesnt goto ciklas otherwise for some reason  

eight:
cmp byte ptr[si], '8'
jne nine 
mov ah, 40h
mov bx, output_descriptor 
mov cx, 7  ;STRING LENGTH.
mov dx, offset nr_eight
int  21h 
jmp testing

nine:
cmp byte ptr[si], '9'
jne end_of_line 
mov ah, 40h
mov bx, output_descriptor 
mov cx, 6  ;STRING LENGTH.
mov dx, offset nr_nine
int  21h 
jmp testing

end_of_line:
cmp byte ptr[si], 13  ;0Dh after 13 always comes 10 as and end of line and new line kind of thing
jne non_number
mov ah, 40h
mov bx, output_descriptor
mov cx, 1  ;STRING LENGTH.
mov dx, offset new_line
int  21h 
jmp testing 

non_number:
cmp byte ptr[si], 10 ;jeigu ne 10 ir ne 13, tai jau tikrai kitoks simbolis 
je testing  
mov ax, [si]  
mov element, ax
mov ah, 40h
mov bx, output_descriptor
mov cx, 1  ;STRING LENGTH.
mov dx, offset element 
int  21h  

testing:
inc si   
dec symbols  
mov cx, symbols
cmp cx, 0
jne continue1 ;if its not 0 
ret   
endp write_file
			
end strt    

;Visi parametrai programai turi buti paduodami komandine eilute, o ne prasant juos ivesti is klaviaturos. Pvz.: antra duom.txt rez.txt  (antra cia mano asm failo pavadinimas)
;Jeigu programa paleista be parametru arba parametrai nekorektiski, reikia atspausdinti pagalbos pranesima toki pati, kaip paleidus programa su parametru /?.
;Programa turi apdoroti ivedimo isvedimo (ir kitokias) klaidas. Pvz, nustacius, kad nurodytas failas neegzistuoja - ji turi isvesti pagalbos pranesima ir baigti darba.
     
