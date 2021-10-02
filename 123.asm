.MODEL small			;atminties modelis
.STACK 100h				;stack'o dydis
.DATA					;duomenu segmentas
buff        db  100        ;kiek max simboliu galima ivesti, nusprendziau, kad 100
            db  ?          ;kiek pats naudotojas iveda simboliu, tai ?, nes kol kas neaisku ir pati programa paskui suskaiciuos
            db  100 dup(?) ;paskui 100 -> 13 nes baigsime string su enter ir jis yra 13, dup yra simbolis, kuris kartojasi, pvz 100dup(0), tai 100 kartu bus 0    
new_line db  0dh, 0ah, '$' ;cia tiesiog tuscia, galima paskui panaudot kaip ednl arba \n
array db 100 dup(0)     ;100 vietu ir visi yra 0         
.CODE					;kodo segmentas
strt:
mov ax,@data			;ds registro inicializavimas
mov ds,ax 

mov ah, 0Ah             ;ivesti string su dx
mov dx, offset buff     ;tikrinam, kiek galim ivesti
int 21h   
       
mov dl, 0               ;jis pradzioje kazkoks kitoks sk, tai neutralizuojam
mov si, offset buff + 1 ;si priskiriam ivestu simboliu adresa
mov cl, [si]            ;cl = simboliu sk  
 
testing:                ;tikrinam kiekviena ivesta zenkla
inc dl                  ;nustatom nariu pozicija 
inc si                  ;daryt pries byte ptr, nes kitaip prades nuo kazkokio -1-elinto cimbolio
mov al, byte ptr [si]   ;al - priskiriam si-elinta (kazkelinta) simboli
cmp al, 20h             ;tarpas prilygsta 20 16-taineje sistemoje
je tarpas               ;jump if equal
cmp dl, cl              ;ziurim ar visus simbolius patikrinom
jb testing              ;jump if its below/less than cl
jmp save        ;jeigu perziurejom visus simbolius, einam prie isvedinejimo

tarpas:
push dx          ;i stack idedam tarpo pozicija 
inc bl           ;bl++, kad zinot kiek kartu paskui isvesti
cmp dl, cl
jb testing       ;griztam prie simboliu tikrinimo

save:
mov cx, bx

gettingready: 
mov si, offset array    
pop dx
mov [si+bx], dl
dec bx
cmp bx, 0
ja gettingready

mov bx, cx
mov ah, 9               ;string output
mov dx, offset new_line  
int 21h 

skaitmenu_sk: 
mov ah, 2         ;output spacebar
mov dl, 20h  
int 21h      
inc si               
mov dl, [si]         
cmp dx, 9  
ja dvizenklis  ;jeigu daugiau uz 9, tai bus dvizenklis
;jeigu vienazenklis, tai tsg eis toliau i apacia 
add dx, 48     ;tokiu budu is decimal isves char, pagal ascii lentele ir bus teisingi nuo 0 iki 9
mov ah, 2      ;output dl
int 21h 
sub bl, 1      
cmp bl, 0   ;kad suktume ciklu tiek, kiek yra tarpu
jne skaitmenu_sk
jmp pabaiga

dvizenklis: 
mov ax, dx  ;kadangi dvizenklis, viskas tilps i ax 
mov dx, 0   ;viskas telpa i ax, tai dx=0
mov cx, 10  ;dalinsim is 10, kad gautume liekana 
div cx      ;ax pirmas sk, dx - antras sk (liekana)  
push dx     ;liekana deti i stack
mov dx, ax  ;dx=ax, nes mum reikes isvesti dl tai pirma skaitemi jam prilyginam
add dx, 48  
mov ah, 2
int 21h

pop dx      ;isimam liekan is stack 
add dx, 48 
mov ah, 2
int 21h   
sub bl, 1
cmp bl, 0
jne skaitmenu_sk
;nereikia cia jau jump i pabaiga, nes tsg eis i apacia
pabaiga:
mov ax, 4C00h				;programos darbo pabaiga
int 21h
end strt