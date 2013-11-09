; tarea programada aquitectura de computadores
; Juego Puntos
;Josue Salas Barrantes , 2013114529



;Esto es para hacer el código más legible
sys_exit        equ     1
sys_read        equ     3
sys_write       equ     4
sys_open        equ     5
stdin           equ     0
stdout          equ     1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SECTION .BSS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss

lenArg	equ 	30
bufferArg   resb lenArg


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SECTION . DATA;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
msjprompt:                db                "cliff y tito:>>"
lenprompt:                equ                $-msjprompt


section .text
        global _start
        
        
_start:


prompt: ; ciclo que imprime el ">>" para recibir argumentos
        mov     ecx, msjprompt 
        mov     edx, lenprompt
        call    DisplayText
        mov ecx,bufferArg	; recibir los argumentos
        mov edx, bufferArg
        call ReadText	
        jmp prompt      	; vuelve el ciclo  
                



        ;para abrir un archivo
        ;mov ebx, nombre.txt
        ;mov ecx, 0
        ;mov eax,sys_open
        ;int 80h        


fin:  
    mov     eax, sys_exit
    xor     ebx, ebx
    int     80H  

    
    
;rutinas intermedias...

; desplega algo en la salida estándar. debe "setearse" lo siguiente:
; ecx: el puntero al mensaje a desplegar
; edx: el largo del mensaje a desplegar
; modifica los registros eax y ebx.
DisplayText:
    mov     eax, sys_write
    mov     ebx, stdout
    int     80H 
    ret

; lee algo de la entrada estándar.debe "setearse" lo siguiente:
; ecx: el puntero al buffer donde se almacenará
; edx: el largo del mensaje a leer
ReadText:
    mov     ebx, stdin
    mov     eax, sys_read
    int     80H
    ret
