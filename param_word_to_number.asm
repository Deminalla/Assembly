.model small       
.stack 100h
.data    

read_buff db 10 dup (?)            
symbols dw 0                  
element dw ?                  

myfile db 100 dup(0)          
results db 100 dup(0)         

input_descriptor dw ?          
output_descriptor dw ?  

sos db "Programa jusu .txt faile parasyto teksto skaicius pavers zodiais. Pvz, as123 bus asvienasdutrys$" 
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
mov ax,@data
mov ds, ax     

mov bx, 82h 
mov si, offset myfile
mov di, offset results  

cmp byte ptr es:[80h], 0  
je get_help
cmp es:[82h], '?/' ;/?
je get_help 
call file_name   

call open_file     
call create_file  

reading:      
mov ah, 3Fh               
mov bx, input_descriptor 
mov cx, 10                
mov dx, offset read_buff  
int 21h
jc error_read             

mov symbols, ax     ;kiek skaityti simboliu is 10  
cmp symbols, 0      
je close_files    
mov si, dx          ;si read_buff adresas
call write_file
jmp reading         

get_help:
mov ah, 9
mov dx, offset sos  
int 21h
jmp finish

close_files:
mov ah, 3Eh   
mov bx, input_descriptor
int 21h
mov ah, 3Eh   
mov bx, output_descriptor
int 21h 
jmp finish

error_open:
mov ah, 9
mov dx, offset open_wrong    
int 21h 
jmp close_files
error_read:
mov ah, 9
mov dx, offset read_wrong    
int 21h 
jmp close_files
error_create:
mov ah, 9
mov dx, offset create_wrong   
int 21h 
jmp close_files
error_write:
mov ah, 9
mov dx, offset write_wrong    
int 21h 

proc file_name  
duom_file: 
cmp byte ptr es:[bx], 13   ;bx prasideda nuo 82h
je get_help
cmp byte ptr es:[bx], 20h 
je rez_file
mov dl, byte ptr es:[bx] 
mov [si], dl               ;si - myfile adresas
inc bx
inc si
jmp duom_file 
rez_file:
inc bx     
cmp byte ptr es:[bx], 13 
je go_back
mov dl, byte ptr es:[bx] 
mov [di], dl               ;di results
inc di
jmp rez_file
go_back:
ret 
endp file_name


proc open_file
mov ah, 3Dh     
mov al, 0      
mov dx, offset myfile 
int 21h 
jc error_open    
mov input_descriptor, ax 
ret  
endp open_file 

proc create_file
mov ah, 3Ch   
mov cx, 0      
mov dx, offset results
int 21h 
jc error_create
mov output_descriptor, ax
ret
endp create_file 

proc write_file 
cycle:  
jc error_write   
cmp byte ptr[si], '0'   
jne one 
mov ah, 40h
mov bx, output_descriptor
mov cx, 5  
mov dx, offset nr_zero
int  21h 
jmp testing   

one:
cmp byte ptr[si], '1'
jne two  
mov ah, 40h
mov bx, output_descriptor
mov cx, 6  
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

continue2:
jmp cycle

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

continue1:  
jmp continue2 

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
cmp byte ptr[si], 13      ;end of line
jne non_number
mov ah, 40h
mov bx, output_descriptor
mov cx, 1  
mov dx, offset new_line
int  21h 
jmp testing 

non_number:
cmp byte ptr[si], 10    
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
jne continue1 
ret   
endp write_file	

finish:  
mov ax, 4Ch	  
int 21h		
END    
