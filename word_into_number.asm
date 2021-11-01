.model small       
.stack 100h
.data    

read_buff db 10 dup (?)     ;this will help us read the file character by 10 characters    
;position dw 0              ;so we know in which part of the 10 element buffer we are in
;full dw 0                  ;to check how many symbols we have to read in 10 element buffer or if its the end yet        
myfile db  "duom.txt", 0    ;i picked the name myfile, 0 shows the end of the filename string, the txt file is in emu8086/MyBuild 
results db "rez.txt", 0     ;my second file 
input_descriptor dw ?       ;its a number that helps identify the file its working with   
output_descriptor dw ?
help db "Si programa jusu .txt faile parasyto teksto skaicius pavers zodiais. Pvz, as12 bus asvienasdu$" ;if nothing is given or it only gets /? 
smth_wrong db "Ivyko klaida$" ;literally any type of error

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

call open_file    ;unidentified open_file, bruh 
call create_file  ;unidentified create_file, bruh

reading:       
mov ah, 3Fh              ;this will read the 1st file  
mov bx, input_descriptor ;so it knkows which file to read
mov cx, 1                ;so it will read only 1 byte
mov dx, offset read_buff ;this will save that one element in that array for now
int 21h
jc error          ;an error when trying to read the file  

cmp ax, 0         ;if there's nothing left to read, end of file
je finish  
call write_file
jmp reading

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
mov si, dx
mov ah, 40h
mov bx, output_descriptor 
jc error   ;unable to write anything? is this necessary?
cmp byte ptr[si], '0'  
jne one 
mov cx, 5  ;STRING LENGTH.
mov dx, offset nr_zero
int  21h 
ret   

one:
cmp byte ptr[si], '1'
jne two 
mov cx, 6  ;STRING LENGTH.
mov dx, offset nr_one
int  21h      
ret

two:
cmp byte ptr[si], '2'
jne three 
mov cx, 2  ;STRING LENGTH.
mov dx, offset nr_two
int  21h  
ret 

three:
cmp byte ptr[si], '3' 
jne four  
mov cx, 4  ;STRING LENGTH.
mov dx, offset nr_three
int  21h 
ret 

four:
cmp byte ptr[si], '4'   
jne five
mov cx, 6  ;STRING LENGTH.
mov dx, offset nr_four
int  21h  
ret  

five:
cmp byte ptr[si], '5'
jne six
mov cx, 5  ;STRING LENGTH.
mov dx, offset nr_five
int  21h   
ret 

six:                 
cmp byte ptr[si], '6'
jne seven
mov cx, 4  ;STRING LENGTH.
mov dx, offset nr_six
int  21h   
ret 

seven:       
cmp byte ptr[si], '7'
jne eight
mov cx, 7  ;STRING LENGTH.
mov dx, offset nr_seven
int  21h   
ret   

eight:
cmp byte ptr[si], '8'
jne nine  
mov cx, 7  ;STRING LENGTH.
mov dx, offset nr_eight
int  21h 
ret

nine:
cmp byte ptr[si], '9'
jne non_number  
mov cx, 6  ;STRING LENGTH.
mov dx, offset nr_nine
int  21h 
jmp reading
ret

non_number:
mov cx, 1  ;STRING LENGTH.
mov dx, offset read_buff
int  21h  
ret    
endp write_file
			
end strt    

;Visi parametrai programai turi buti paduodami komandine eilute, o ne prasant juos ivesti is klaviaturos. Pvz.: antra duom.txt rez.txt  (antra cia mano asm failo pavadinimas)
;Jeigu programa paleista be parametru arba parametrai nekorektiski, reikia atspausdinti pagalbos pranesima toki pati, kaip paleidus programa su parametru /?.
;Programa turi apdoroti ivedimo isvedimo (ir kitokias) klaidas. Pvz, nustacius, kad nurodytas failas neegzistuoja - ji turi isvesti pagalbos pranesima ir baigti darba.
;Failu skaitymo ar rasymo buferio dydis turi buti nemazesnis uz 10 baitu.
;Failo dydis gali virsyti skaitymo ar rasymo buferio dydi.
;Panaudot funkcija. (call i think)      
