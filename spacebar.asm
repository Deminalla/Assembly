;Parašykite programą, kuri atspausdina tarpų pozicijas įvestoje simbolių eilutėje;  Pvz.: įvedus asl A1p3i DI iiO turi atspausdinti 4 10 13
;Write a program that would print out the positions of spacebars in a string that the user input. For example, input asl A1p3i DI iiO would print 4 10 13
.MODEL small	;atminties modelis
.STACK 100h		;stack'o dydis
.DATA		;aprasom duomenu segmenta
buff db  100            ;kiek max simboliu galima ivesti, nusprendziau, kad 100
     db  ?              ;kiek pats naudotojas iveda simboliu, tai ?, nes kol kas neaisku ir pati programa paskui suskaiciuos
     db  100 dup(0)     ;dup yra simbolis, kuris kartojasi, pvz 100dup(0), tai 100 kartu bus 0    
new_line db  0dh, 0ah, '$'  ;cia tiesiog tuscia, galima paskui panaudot kaip ednl arba \n
array db 100 dup(0)     ;padariau masyva, išskiria duomenų segmente vietą 100 baitams, kurių visos reikšmės 0        
.CODE		;kodo segmentas
strt:
mov ax,@data	;ds registro inicializavimas    
mov ds,ax               ;sita komandų pora į registrą DS perkelia duomenų segmento pradžios paragrafo numerį.

mov ah, 0Ah             ;ivesti string su dx
mov dx, offset buff     ;tikrinam, kiek galim ivesti
int 21h   
mov si, offset buff + 1 ;si registrui priskiriu ivestu simboliu adresa
mov cl, [si]            ;cl = ivestu simboliu sk  
mov dl, 0               ;jis pradzioje kazkoks kitoks sk, tai neutralizuojam
 
testing:                ;tikrinam kiekviena ivesta zenkla
inc dl                  ;nustatom nariu pozicija    
inc si                  ;kad nuskaitytu ten, kur 100dup(0), o ne kur ?, cia tas pats kaip byte ptr [si] + 1
mov al, byte ptr [si]   ;al - priskiriu si-elinta (kazkelinta) simboli
cmp al, 20h             ;tarpas prilygsta 20 16-taineje sistemoje, galima rasyti ir ' ' cia butu char formatu tarpas
je tarpas               ;jump if equal
cmp dl, cl              ;ziurim ar visus simbolius patikrinom
jb testing              ;jump if its below/less than cl
jmp line                ;jeigu perziurejom visus simbolius, einam prie isvedinejimo

tarpas:
inc bx                 ;bx - tarpu sk, kad zinot kiek kartu paskui isvesti
mov di, offset array   ;di - masyvo adresas    
mov [di+bx], dl        ;i masyva idedam tarpo pozicija
cmp dl, cl
jb testing             ;griztam prie simboliu tikrinimo

line:
mov ah, 9                ;string output
mov dx, offset new_line  ;endl
int 21h 

skaitmenu_sk: 
mov ah, 2         
mov dl, 20h     ;output spacebar
int 21h         
inc di              
mov dl, [di]    ;dl'ui priskiriam kazkelinta masyvo elementa    
cmp dx, 9       
ja dvizenklis   ;jeigu daugiau uz 9, tai bus dvizenklis

add dx, 48      ;tokiu budu is decimal isves char, pagal ascii lentele ir bus teisingi nuo 0 iki 9
mov ah, 2       ;output tarpo pozicija dl
int 21h 
sub bl, 1      
cmp bl, 0       ;kad suktume ciklu tiek, kiek yra tarpu
jne skaitmenu_sk
jmp pabaiga

dvizenklis: 
mov ax, dx    ;kadangi dvizenklis, viskas tilps i ax 
mov dx, 0     ;viskas telpa i ax, tai dx=0
mov cx, 10     
div cx        ;, dalyba is 10, ax pirmas sk, dx - antras sk (liekana)  
push dx       ;liekana deti i stack, kad jo nepamest
mov dx, ax    ;dx=ax, nes mum reikes isvesti dl tai pirma skaitemi jam prilyginam
add dx, 48  
mov ah, 2
int 21h

pop dx        ;isimam liekana is stack 
add dx, 48    ;toliau tas pats kaip ir pries tai
mov ah, 2
int 21h   
sub bl, 1
cmp bl, 0
jne skaitmenu_sk

pabaiga:
mov ax, 4C00h   ;programos darbo pabaiga
int 21h
end strt
