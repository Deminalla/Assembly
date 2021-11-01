.model small       
.stack 100h
.data  
        
myfile db  "duom.txt", 0      ;i picked the name myfile, 0 shows the end of the filename string, the txt file is in emu8086/MyBuild 
results db "rez.txt", 0       ;my second file 
read_buff db 100 dup (?)      ;this will help us read the file character by character
input_descriptor dw ?          ;its a number that helps identify the file its working with   
output_descriptor dw ?
help db "Si programa jusu faile parasyto teksto skaicius pavers zodiais$" ;if nothing is given or it only gets /? 
err db "Ivyko klaida$" ;literally any type of error

nr_zero db "nulis$"
nr_one db "vienas$"
nr_two db "du$"
nr_three db "trys$"
nr_four db "keturi$"
nr_five db "penki$"
nr_six db "sesi$"  ;fix the letters?  
nr_seven db "septyni$" 
nr_eight db "astuoni$" ;fix the letters?
nr_nine db "devyni$"
.code
strt:
mov ax,@data
mov ds, ax
  
call open_file    
call create_file

reading:
mov ah, 3Fh    ;this will read the 1st file  
mov bx, input_descriptor ;so it knkows which file to read
mov cx, 1      ;so it will read only 1 byte
mov dx, offset read_buff ;this will save that one element in that array for now
int 21h  

cmp ax, 0      ;if there's nothing left to read, end of file
je finish

mov si, dx
cmp [si], '9'
jbe is_it_a_number
jmp non_number

is_it_a_number:
cmp [si], '0' 
je zero
cmp [si], '1'
je one
cmp [si], '2'
je two
cmp [si], '3' 
je three
cmp [si], '4' 
je four
cmp [si], '5'
je five
cmp [si], '6'
je six
cmp [si], '7'
je seven
cmp [si], '8'
je eight
cmp [si], '9'
je nine 

non_number:
mov ah, 40h
mov bx, output_descriptor
mov cx, 1  ;STRING LENGTH.
mov dx, offset read_buff
int  21h  
jmp reading

zero:
mov ah, 40h
mov bx, output_descriptor
mov cx, 5  ;STRING LENGTH.
mov dx, offset nr_zero
int  21h 
jmp reading 

one:
mov ah, 40h
mov bx, output_descriptor
mov cx, 6  ;STRING LENGTH.
mov dx, offset nr_one
int  21h      
jmp reading

two:
mov ah, 40h
mov bx, output_descriptor
mov cx, 2  ;STRING LENGTH.
mov dx, offset nr_two
int  21h  
jmp reading

three:
mov ah, 40h
mov bx, output_descriptor
mov cx, 4  ;STRING LENGTH.
mov dx, offset nr_three
int  21h 
jmp reading

four:
mov ah, 40h
mov bx, output_descriptor
mov cx, 6  ;STRING LENGTH.
mov dx, offset nr_four
int  21h  
jmp reading

five:
mov ah, 40h
mov bx, output_descriptor
mov cx, 5  ;STRING LENGTH.
mov dx, offset nr_five
int  21h   
jmp reading

six:
mov ah, 40h
mov bx, output_descriptor
mov cx, 4  ;STRING LENGTH.
mov dx, offset nr_six
int  21h   
jmp reading       

seven:
mov ah, 40h
mov bx, output_descriptor
mov cx, 7  ;STRING LENGTH.
mov dx, offset nr_seven
int  21h   
jmp reading

eight:
mov ah, 40h
mov bx, output_descriptor
mov cx, 7  ;STRING LENGTH.
mov dx, offset nr_eight
int  21h 
jmp reading

nine:
mov ah, 40h
mov bx, output_descriptor
mov cx, 6  ;STRING LENGTH.
mov dx, offset nr_nine
int  21h 
jmp reading 

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

error:
mov ah, 9
mov dx, offset help ;should error/help messages be stdout or in the rez file???
int 21h 

finish: 
mov ah, 3Eh
mov bx, input_descriptor
int 21h

mov ah, 3Eh
mov bx, output_descriptor
int 21h

mov ax, 4Ch		
int 21h			
end strt    

;Visi parametrai programai turi buti paduodami komandine eilute, o ne prasant juos ivesti is klaviaturos. Pvz.: antra duom.txt rez.txt
;Jeigu programa paleista be parametru arba parametrai nekorektiski, reikia atspausdinti pagalbos pranesima toki pati, kaip paleidus programa su parametru /?.
;Programa turi apdoroti ivedimo isvedimo (ir kitokias) klaidas. Pvz, nustacius, kad nurodytas failas neegzistuoja - ji turi isvesti pagalbos pranesima ir baigti darba.
;Failu skaitymo ar rasymo buferio dydis turi buti nemazesnis uz 10 baitu.
;Failo dydis gali virsyti skaitymo ar rasymo buferio dydi.
;Panaudot funkcija. (call?????)       
