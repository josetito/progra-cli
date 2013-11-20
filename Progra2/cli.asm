; tarea programada aquitectura de computadores
; Command-line Interface
;Josue Salas Barrantes 
;Jose Arguedas Castillo


;Esto es para hacer el código más legible
sys_exit        equ     1
sys_read        equ     3
sys_write       equ     4
sys_open        equ     5
stdin           equ     0
stdout          equ     1
sys_unlink 		equ	 	10
sys_rename 		equ		38
sys_link		equ		9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SECTION .BSS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;|		Buffers para guardar toda la instruccion, argumentos por aparte , lo que dice 		 |
;|		un archivo, y las lineas (en caso de la instruccion comparar)						 |
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .bss


	lenConfirmacion		equ		2		; para confirmar si se desea realizar una accion [s/n]
	buffConfirmacion	resb	lenConfirmacion

	lenArg	equ 	200				;un tamaño de 300 para guardar todo el argumento, pensado en que sean los nombres de 2 archivos y sea mas largo
	bufferArg   resb lenArg
	
	;b	resb 1
	
	lenArg2	equ	50		; calculando que un archivo puede tener un nombre largo	
	bufferArg2	resb	lenArg2
	
	lenArg1   equ 11	;calculando la cantidad de letras de una instruccion, mas uno mas para  guardar el enter	 
	bufferArg1	resb lenArg1
	
	lenArg3	equ	50		; calculando que un archivo puede tener un nombre largo
	bufferArg3	resb	lenArg3

	lenArg4   equ 12	;no es muy grande, lo mas que puede almacenar es el --forzado
	bufferArg4	resb lenArg4

	fileBufLen	equ		1500		
	fileBuf		resb	fileBufLen
	
	lenFile1	equ		1500
	File1		resb lenFile1

	lenFile2	equ		1500
	File2		resb lenFile2

; en caso de usar la instruccion comparar se guardara cada linea en estos dos buffers
	linea1		resb	400	
	linea2		resb	400	

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SECTION . DATA;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



section .data

msjprompt:                db                "cliff y tito:>>"; El prompt utilizado
lenprompt:                equ                $-msjprompt



msgEnter	db "",10
lenEnter	equ	$-msgEnter
; ESTOS 6 PARA ABAJO SON PARA IR COMPARANDO CON EL PRIMER ARGUMENTO RECIBIDO
msgMostar	db "mostrar "
msgBorrar	db "borrar "
msgRenombrar	db"renombrar "
msgCompara	db "comparar "
msgCopiar	db "copiar "
msgSalir	db "salir"
;PARA LA INSTRUCCION DE COMPARAR, CUANDO TERMINA
msgFinArchivos	db"--Se acabo uno,o ambos archivos, se dejara de comparar--",10
lenFinArchivos	equ	$-msgFinArchivos

;ESTOS PARA COMPARAR CON LAS INSTRUCCIONES AYUDA Y FORZADO
msgForzado	db	"--forzado",10
msgAyuda	db	"--ayuda",0
;MENSAJE DE CONFIRMACION PARA LAS INSTRUCCIONES QUE LO NECESITA
msgConfirmacion		db " Se desea proceder con la accion solicitada? [s/n] : "
lenConfirmacionMsg	equ		$-msgConfirmacion

;Archivos de ayuda con la ruta, estan adentro de la carpeta Ayuda
copiarAyuda:  	db 		"Ayuda/copiar.ayuda.txt",0
renombrarAyuda:	db		"Ayuda/renombrar.ayuda.txt",0
borrarAyuda:	db		"Ayuda/borrar.ayuda.txt",0
compararAyuda:	db		"Ayuda/comparar.ayuda.txt",0
mostrarAyuda: 	db	 	"Ayuda/mostrar.ayuda.txt",0
; MENAJE DE ERROR, CUANDO NO SE ENCUENTRA UNA INSTRUCCION DADA
msgError 	db "No se encontro la instruccion"
lenError	equ	$-msgError
; MENSAJE QUE SE MUESTRA CUANDO NO SE ENCUENTRA UN ARCHIVO
msgErrorNoArchivo 	db "Ocurrio un error a la hora de abrir el archivo "
lenErrorNoArchivo	equ	$-msgErrorNoArchivo

;UNA "C" SE USA PARA CUANDO SE COMPARA DOS LINEAS, SI SON DIFERENTES SERIA 1c1 ese "c" es este mensaje
c			db "c"
clen		equ $-c


; SE USA PARA GUARDAR EL RESULTADO DE LA INSTRUCCION COMPARAR  Ejemplo 1c1
resultado		dd 00
lenresulado		equ	$-resultado

;mensaje de logrado
msgListo:	db " El proceso deseado se logro satisfactoriamente",10
lenListo:	equ	$-msgListo


section .text
        global _start
        
        
_start:

prompt: ; ciclo que imprime el ">>" para recibir argumentos
        mov     ecx, msjprompt 
        mov     edx, lenprompt
        call    DisplayText
			
		mov ecx,bufferArg	; recibir los argumentos
		mov edx, lenArg
		call ReadText
		mov ecx,0; contador
		jmp .verificarArg1	
		
.verificarArg1:
		mov esi,0
	    mov al,byte[bufferArg+ecx]		; guarda la letra del comando, con el contador se sabe cual es
	    mov byte[bufferArg1+ecx],al; mueve a un buffer la primera letra en el byte correspondiente
	    cmp byte[bufferArg+ecx]," "; verifica si hay un espacio
	    je .verificarArg2	; si es asi deberia estar el primer comando listo, la instruccion
		cmp byte[bufferArg+ecx],10	;compara si hay un enter o sea solo seria un comando, solo sirve con salir
	    je  verificarTipoArg1		; si es asi verifica el unico comando
	    inc ecx							; incrementa el contador
	   jmp .verificarArg1		; vuelve al proceso
	   
.verificarArg2: ; guarda el segundo argumento el el bufferArg2
	mov edi,0	; para verificar el --ayuda mas adelante
	inc ecx		; incrementa el contador de lineas para que siga el segundo argumento, habia quedado en el espacio vacio
	mov al,byte[bufferArg+ecx]	; al contiene el byte de una letra del segundo argumento
	mov byte[bufferArg2+esi],al	; la guarda en el buffer para el segundo argumento
	cmp byte[bufferArg+ecx]," "	; compara si hay un espacio vacio
	je	.verificarArg3			; si es asi significaria que existe un 3er argumento, entonces salta guardarlo
	cmp byte[bufferArg+ecx],10	; compara si hay un enter
	je verificarTipoArg1		;si hay un enter salta a ver que tipo de instruccion se dio
	inc esi						;incrementa la posicion donde va la letra del bufferArg2
	jmp .verificarArg2			; vuelve al ciclo a verificar otra letra
	
.verificarArg3:					;guarda el 3er arguemtento en el buffer correspondiente bufferArg3
	inc ecx						; incrementa el contador de la instruccion para asi caer en el 3er parametro
	mov al,byte[bufferArg+ecx]	;guarda el la letra correspondiente del 3er argumento
	cmp al," "					; la compara con un espacio vacio
	je .reiniciarCont			; si es asi reinicia un contador para verificar el 4to argumento que seria despues del " "(espacio vacio)
	cmp byte[bufferArg+ecx],10	;compara si un enter	
	je verificarTipoArg1		; si es asi va a ver que tipo de instruccion se paso
	mov byte[bufferArg3+edi],al	;guarda el 3er argumento en un buffer que solo va a contener ese argumento
	mov byte[bufferArg3+edi+1],0; va guardando un 0 siempre adelante, esto para cuando llegue al final exista un null de mas por si es el nombre de un archivo, se necesita ese null
	inc edi						; incrementa la letra del bufferArg3
	jmp .verificarArg3			;vuelve al ciclo
	
.reiniciarCont:	
	mov edi,0	; reinicia un contador para poder usarlo al verificar el argumeto4
	jmp .verificarArg4	; salta a verificar el argumento 4
.verificarArg4:		;guardar el argumento 4 en un buffer por aparte bufferArg4
	inc ecx			; incrementa el contador de la instruccion para asi caer en el 4to parametro
	mov al,byte[bufferArg+ecx]; guarda la letra de el 4 argumento
	mov byte[bufferArg4+edi],al; la guarda en el bufferArg4, que solo contiene el 4to argumento
	cmp al,10					; compara, si hay un enter
	je verificarTipoArg1		; si es asi salta a ver que tipo de instruccion es
	inc edi							; incrementa la letra del bufferArg4
	jmp .verificarArg4				;vuelve al ciclo
	
verificarTipoArg1:				; verifica el comando, lo que se hace es comparar la primera letra de la instruccion
								;y de ahi va a verificar cada instruccion por aparte dependiendo de cual se escoge
								; si es comparar o copiar que usan la misma letra inicial,se compara primero con copiar 
								; despues con comparar
								
								
	cmp ecx,0	; si solo se dio enter		
	je prompt	; salte de una vez al error
	mov byte [bufferArg2+esi],0 ; guarda un 0(null) al final del 2do argumento en caso de que sea el nombre de un archivo es importante
	mov ecx,1						; contador en 1 para despues compara cada comando 1 por 1
	cmp byte[bufferArg1],"s"	; si es "s" solo podria ser salir, se verifica eso
	je verificarSalir				
	cmp byte[bufferArg1],"m"	; si es "m" solo seria mostrar entonces se verifica eso
	je verificarMostrar
	cmp byte[bufferArg1],"b"	; si es "b" solo seria borrar entonces se verifica eso
	je verificarBorrar
	cmp byte[bufferArg1],"r" 	;si es  "r" solo seria renombrar entonces se verifica eso 
	je verificarRenombrar
	cmp byte[bufferArg1],"c"	; si es  "c" podria ser  copiar o comparar entonces se verifican los dos, primero copiar
	je verificarCopiar
	jmp Error						; si no es ninguno va al mensaje de error

verificarSalir:				; verifica si se escribio salir
	mov al,byte[msgSalir+ecx]	
	cmp byte[bufferArg1+ecx],al	; va comparando el primer parametro con el msgSalir = "salir" asi  se sabe si se escribio eso
	jne Error		; si no es asi salte a mensaje de error
	cmp ecx,4			; compara contador con 4 , la cantidad de letras de salir despue de la "s"
	je fin				; se escribio salir.... salga, salte a fin
	inc ecx
	jmp verificarSalir;vuelve al ciclo comparando otra letra

verificarMostrar:	; cuenta las letras de mostrar, las compara con un msg que dice "mostrar"
	mov al,byte[msgMostar+ecx]
	cmp byte[bufferArg1+ecx],al	
	jne Error	; si un byte no cooncuerda da error
	cmp ecx,7	; si llego a 7 significa que si sirve
	je .ayudaMostrar		; salta a ayuda
	inc ecx	;si no aumenta el contador de bytes, cambia de letra
	jmp verificarMostrar	; y vuelve al ciclo
	
.ayudaMostrar:; verificar si el segundo argumento es --ayuda
	mov al,byte[msgAyuda+edi]	 
	cmp byte[bufferArg2+edi],al	; compara letra con letra
	jne .mostrarArchivo	; si no son iguales se va a ver si es un archivo
	inc edi					;incrementa el contador del buffer para guardar el segundo argumento
	cmp edi,8	; compara con  --ayuda
	jne .ayudaMostrar		; vuelve 
	
	mov ebx,mostrarAyuda	; abre el archivo de ayuda, se define su nombre en la .data como mostrarAyuda
	mov ecx,0
	call Open		; subrutina que abre el archivo
		
	jmp leerArchivo	; lo lee e imprime 



.mostrarArchivo:			
	mov		ebx,bufferArg2	; mostrar el archivo que se escogio pasando como argumento el nombre
	mov		ecx, 0		
	call Open	; se abre el archivo 
	jmp leerArchivo		; y lo lee e imprime



verificarBorrar:
	mov al,byte[msgBorrar+ecx]	
	cmp byte[bufferArg1+ecx],al	; va comparando el primer parametro con el msgBorrar = "borrar" asi  se sabe si se escribio eso
	jne Error		; si no es asi salte a mensaje de error
	cmp ecx,6			; compara contador con 4 , la cantidad de letras de borrar
	je .pordonde			; se escribio salir.... salga, salte a fin
	inc ecx
	jmp verificarBorrar
	
.pordonde:; aqui se sabe si es una llamada al --ayuda o si es --forzado
	mov esi,0	
	mov edi,0
	cmp byte[bufferArg3],0	; compara el 3er argumento con vacio
	je .ayudaBorrar			; si es asi verifica si lo que dice es --ayuda
	jmp .forzado			; else: va ver si dice --forzado
	
.ayudaBorrar:
	mov al,byte[msgAyuda+edi]; mensaje que dice --ayuda
	cmp byte[bufferArg2+edi],al	; compara letra con letra, con el argumento 2.... bufferArg2
	jne .confirmarBorrarArchivo	; si no son iguales se va a ver si es un archivo
	inc edi					;incrementa el contador del buffer para guardar el segundo argumento
	cmp edi,8	; compara con  --ayuda
	jne .ayudaBorrar		; vuelve 
	mov ebx,borrarAyuda	; abre el archivo de ayuda, se define su nombre en la .data como mostrarAyuda
	mov ecx,0
	call Open		; subrutina que abre el archivo
	jmp leerArchivo

.forzado:		; ve  si dice forzado, ya se sabe que existe un 3er argumento, entonces si no dice el va a error 
	cmp esi,9		; compara el indice de letras con 10 
	je  .borrarArchivo	; si llego a 10 significa que dice lo mismo
	mov al,byte[msgForzado+esi]	; 
	cmp byte[bufferArg3+esi],al; compara el 3er argumento con el msgForzado: "--forzado",10
	jne Error	; si no son iguales vaya a error
	inc esi	; incrementa el indice de letras
	jmp .forzado	; vuelve al ciclo con la otra letra
	
		
.confirmarBorrarArchivo:
	call Confirmacion; llama al mensaje de confirmacion
	dec eax ; eliminar el enter, se desea validaar, que si se pone "s" borre pero si se pone "sasdasd" no lo haga
	cmp eax,1; si la respuesta es mas larga de 1 digito da error
	jne Error 	
	cmp byte[buffConfirmacion],"s"; si dice "S"
	je .borrarArchivo	; salta a borrar el archivo
	jmp prompt; si dice "n" vuelve al prompt
	
.borrarArchivo:	;borrar e archivo
		mov ebx, bufferArg2	; mueve al ebx el nombre del archivo
		call Remove			; se llama a remove que lo elimina
		jmp .testiarBorrado	; y revisa si se borro correctamente
.testiarBorrado:
		test eax, eax
		js ErrorNoArchivo	;si no existe el archivo lanza un mensaje de Error
		call CleanBssData	; limpia todos los buffers
		jmp Listo			; vuelve al prompt
	
verificarRenombrar:	; verifica si dice renombrar el primer argumento
	mov al,byte[bufferArg1+ecx]	
	cmp al,byte[msgRenombrar+ecx]; compara el argumento1 con el msgRenombrar: renombrar
	jne Error			; si no es igual va a error
	inc ecx				; incrementa el indice que marca la letra
	cmp ecx,10			; lo compara con 10 
	je .pordonde		; si es asi, ya se sabe que dice renombrar, entonces salta a ver que tipo de instrucciones le siguen
	jmp verificarRenombrar; vuelve al ciclo
	
.pordonde:
	cmp byte[bufferArg2],0	; ver si existe segundo argumento
	je Error; si no da error
	cmp byte[bufferArg3],0	; ve si hay 3r argumento
	je .ayudaRenombrar		; si no es asi va a verificar si se llamo a --ayuda
	cmp byte[bufferArg4],0	; ve si hay 4to argumento
	je .cambiarNombreConfirmacion;si no hay entonces no se estaria llamando --forzado por lo que salta a confirmar la accion
	jmp .forzarRenombrar	;si no se cumple nada , salta a revisar que diga --forzado

.ayudaRenombrar:; verifica si hay un --ayuda en vez de algun nombre de archivo
	mov esi,0	
	mov al,byte[msgAyuda+edi]	
	cmp al,byte[bufferArg2+edi]	; compara el el argumento2 con el msgAyuda = "--ayuda",10
	jne Error		; si no son iguales va a error
	inc edi			; incrementa el indice de letra
	cmp edi,8		; lo compara,con 8 la cantidad de --ayuda,10
	jne .ayudaRenombrar; si no son iguales vuelve al ciclo
	
	;ESTO SUCEDE SI SE CUMPLE EL CICLO(que diga --ayuda)
	mov ebx,renombrarAyuda; abre el archivo de ayuda, se define su nombre en la .data como renombrarAyuda
	mov ecx,0		;read only
	call Open		; subrutina que abre el archivo
	jmp leerArchivo	; salta a la ruta que lee e imprime una archivo 
	
.forzarRenombrar:		; ve si dice verificado el 4to argumento
	mov al,byte[msgForzado+edi]	
	cmp al,byte[bufferArg4+edi]; va comparando el 4to argumento con el msgForzado:"--forzado",10
	jne Error	; si no son iguales va a error
	cmp edi,9	; lo compara con 9 la cantidad de digitos,
	je .cambiarNombre; si es asi, se llego al final con exito
	inc edi			;aumenta el indice de letras
		jmp .forzarRenombrar; vuelve al ciclo


.cambiarNombreConfirmacion:	; confirmar que se desea cambiar el nombre
	call Confirmacion	; llama al confirmacion
	dec eax				;borra el enter de la respuesta
	cmp eax,1			; compara con 1
	jne Error			; si no es 1 digito da error	
	cmp byte[buffConfirmacion],"s"; compara con "s" 
	jne prompt				; si no es asi va al prompt
	jmp .cambiarNombre		; si es se procede a cambiar el nombre del archivo
.cambiarNombre:	
	mov ebx,bufferArg2	;nombre del archivo
	mov ecx,bufferArg3	; nuevo nombre del archivo
	call Rename			; llama a la funcion que renombra con esos 2 parametros de arriba
	cmp eax,0			; compara el eax, 0 si no es 0 significa que hubo error al hacer el proceso de renombrado
	je Listo			; si son iguales vuelve al prompt
	jmp ErrorNoArchivo	; si no le avisa al usario que algo paso, que el archivo no existe
	
verificarCopiar:				; verificar si se escribio la instruccion copiar
	mov al,byte[msgCopiar+ecx]	;
	cmp byte[bufferArg1+ecx],al	; compara el argumento1  con el msgCopiar: "copiar "
	jne verificarComparar; si no son iguales verifica comparar que es el otro que empieza con "c"
	cmp ecx,6			; compara el indice de letras con 6
	je .pordonde		; si es asi significa que si dice copiar y se va a ver que tipo de argumentos le dan
	inc ecx				; incrementa el indice de letras
	jmp verificarCopiar; vuelve al ciclo
	
.pordonde:
	cmp byte[bufferArg2],0	; ver si existe segundo argumento
	je Error				;si no existe va a error
	cmp byte[bufferArg3],0	; ver si existe 3er argumento 
	je .ayudaCopiar			; si no es asi verifica si dice --ayuda 
	cmp byte[bufferArg4],0	; ver si existe 4to argumento
	je .copiarConfirmacion	; si no existe va a preguntar si se desea continuar con la accion
	jmp .forzarCopiar		;salte a ver si dice forzado, ya que el 4to argumento no es vacio y solo contiene el --forzado opcionalmente
	
.ayudaCopiar:		;ver si dice --ayuda
	mov esi,0	
	mov al,byte[msgAyuda+edi]
	cmp al,byte[bufferArg2+edi]; compara el argumento2 con msgAyuda: "--ayuda",10
	jne Error				; si no son iguales va a error
	inc edi					;incrementa el indice de letras
	cmp edi,8				; compara el indice de letras con 8 la cantidad de digitos de --ayuda,10 
	jne .ayudaCopiar		;si no es 8 vuelve al ciclo
	mov ebx,copiarAyuda; abre el archivo de ayuda, se define su nombre en la .data como renombrarAyuda
	mov ecx,0		;SOLO lectura
	call Open		; subrutina que abre el archivo
	jmp leerArchivo	; lee e imprime el mensaje
		
.forzarCopiar: ; verifica si el 4to argumento dice  --forzado
	mov al,byte[msgForzado+edi]
	cmp al,byte[bufferArg4+edi]	; compara el cuarto argumento con el msgForzado:--forzado,10
	jne Error		; si no es asi da error
	cmp edi,9		; compara el indice de letras con 9 que es la cantidad de digitos de msgForzado
	je .copiar		; si es asi se llego al final, entonces se copia el archivo
	inc edi			; incrementa el indice de letras
	jmp .forzarCopiar	; vuelve al ciclo

.copiarConfirmacion:	; confirmar si se desea copiar
	call Confirmacion	; llama a la subrutina que pregunta si se desea continuar con la accion, la respuesta se guarda en el eax
	dec eax			; borra el enter de la respuesta
	cmp eax,1	; compara con 1 o sea que sea un digito nada mas
	jne Error	; si no es asi da error
	cmp byte[buffConfirmacion],"s"	;comparara si dice "s"
	jne prompt					;si no dice "s" entonces vuelve al prompt
	jmp .copiar				; si dice "s" entonces salta a el proceso que copia el archivo
.copiar:
	mov ebx,bufferArg2	; guarda el nombre del archivo
	mov ecx,bufferArg3	; y el nombre del archivo nuevo, el copiado
	call Copy			; llama a la subrutina que copia archivos
	cmp eax,0			; si el eax da 0 ,todo ocurrio bien, si no entonces no existia el archivo	
	je Listo			;si es 0  vuelve al prompt
	jmp ErrorNoArchivo	; si  no da un mensaje al usuario de que no existe tal archivo
	
	
	
verificarComparar:	; verificar si dice comparar la instruccion(primer argumento)
	mov al,byte[msgCompara+ecx]
	cmp al,byte[bufferArg1+ecx]	; compara el primer argumento, con el msgComparar: "comparar "
	jne Error			; si no son iguales da error	
	cmp ecx,8			;compara el indice de letras con 8, la cantidad de digitos del msgComparar
	je .pordonde		; si es asi va a ver que tipo de argumentos siguen despues de el
	inc ecx				; incrementaa el indice de digitos	
	jmp verificarComparar	; vuelve al ciclo con el siguiente digito 

.pordonde:
	cmp byte[bufferArg2],0	; ver si existe segundo argumento
	je Error				;si no existe da error
	cmp byte[bufferArg3],0	; ver si existe 3er argumento
	je .ayudaComparar		; si no existe va a ver si el segundo dice --ayuda
	cmp byte[bufferArg4],0	; ver si existe 4to argumento
	je .compararConfirmacion; si no existe va a confirmar la accion
	jmp Error				; si no se cumple nada da error

.ayudaComparar:			;ver si dice --ayuda el segundo argumento
	mov esi,0
	mov al,byte[msgAyuda+edi]
	cmp al,byte[bufferArg2+edi]	; compara el 2do argumento con msgAyuda: "--ayuda",10
	jne Error	; si no son iguales da error
	inc edi			; incrementa el indice de letras
	cmp edi,8			;compara si es 8 o sea la cantidad de digitos del msgAyuda
	jne .ayudaComparar	;si no es asi vuelve al ciclo
	mov ebx,compararAyuda; abre el archivo de ayuda, se define su nombre en la .data como compararaAyuda
	mov ecx,0		; solo lectura
	call Open		; subrutina que abre el archivo
	jmp leerArchivo	; lee e imprime el archivo

.compararConfirmacion:	; confirmar que se desea continuar con la accion
	call Confirmacion	; subrutina que pregunta si se desea continuar, el largo de su respuesta queda en el eax
	dec eax	;borra el enter 
	cmp eax,1; compara el largo de la respuesta con 1 
	jne Error; si no es asi da error
	cmp byte[buffConfirmacion],"s"; compara la respuesta con "s"
	jne prompt	; si no es asi vuelve al prompt
	jmp .AbrirArchivos	; si es "s" salta a abrir ambos archivo 
	

	
.AbrirArchivos:
	mov ebx,bufferArg2 ; nombre del primer archivo
	mov ecx,0	; solo lectura
	call Open	; llama a la funcion que lo abre
	cmp eax, -4096 ; Existe?
	ja ErrorNoArchivo	; si no da erro
	mov		ebx, eax			; lo lee 
	mov		ecx, File1			; y lo guarda en el file1
	mov		edx, lenFile1
	mov		eax, sys_read
	int 	80h			
	
	mov ebx,bufferArg3	; nombre del segundo archivo
	mov ecx,0			;solo lectura
	call Open			;subrutrina que abre el archivo
	cmp eax, -4096 ; Existe?
	ja Error	; si no da error
	mov		ebx, eax			; lo lee 
	mov		ecx, File2		; lo guarda en el File2
	mov		edx, lenFile2
	mov		eax, sys_read	
	int 	80h	
	mov eax,1	;contador de lineas
	mov ebx,0	;indice de bytes file1
	mov ecx,0	;indice de bytes file2
	mov esi,0	
	mov edi,0	; indice de bytes de linea1 y linea2
	jmp .ciclo

.ciclo:			;ciclo que guarda la filas en un buffer, linea1
	mov dh,byte[File1+ebx]
	mov byte[linea1+edi],dh	; mueve a la linea1 lo que hay en el File1(		primer archivo)
	cmp byte[linea1+edi],0	; compara el byte de la linea1 con 0, o sea si se llego al final del archivo
	je .finArchivos			; si es asi imprime que se termino un archivo
	cmp byte[linea1+edi],10	; compara el byte de la linea1 con 10, un enter
	je .reset	; si es asi deja de guardar porque ahi termina esa linea
	inc ebx; incrementa el indice de bytes del archivo1 completo
	inc edi	; incrementa el indice de bytes de la linea1
	jmp .ciclo; vuelve al ciclo
.reset:
	mov edi,0	; reinicia el indice de bytes de la linea1 para usarlo en la linea2
	jmp .ciclo2	; salta al ciclo2 que hace lo mismo del ciclo pero con el segundo archivo
		
.ciclo2:
	mov dl,byte[File2+ecx]	
	mov byte[linea2+edi],dl	; guarda en la linea2 lo que hay en el archivo2
	cmp byte[linea2+edi],0	; compara si hay un 0 en la linea 2 significa que el archivo termino
	je .finArchivos	; si es asi sale a un proceso que envia un mensaje que el archivo termino 
	cmp byte[linea2+edi],10	; compara el byte con 10 , enter
	je .comparar			;si sucede va a comparar linea1 y linea2 byte por byte
	inc ecx					; incrementa el indice de bytes del archivo2
	inc edi					;incrementa el 	indice de bytes de la linea2
	jmp .ciclo2				;vuelve al ciclo
	
.comparar:

	mov dl,byte[linea1+esi]; 
	mov dh,byte[linea2+esi]	
	cmp dl,dh				; compara linea1 con linea2 , byte por byte
	jne	.imprimir			; si no son iguales , salte a imprimir que imprime que existe diferencia
	cmp dl,10				; compara el byte actual de linea1 con 10 o sea enter
	je .buena				; si es asi salte a buena
	cmp dh,10				; compara el byte actual de linea2 con 10 o sea ente
	je .buena				; si es asi salte a buena
	inc esi					;incremena el indice de bytes de linea1 y linea2
	jmp .comparar			; vuelve al ciclo con el siguiente byte	
	

.imprimir:	; imprimir la la linea en la que hay diferencia
	; GUARDA LOS REGISTROS QUE SIRVEN DE CONTADORES DE LINEAS Y POSICIONES EN LOS ARCHIVOS
	push esi
	push eax
	push ebx
	push ecx
	call ImprimirNumero	; llama a imprimir numero, que imprime lo que este en el eax,
    mov ecx,linea1	; imprime lo que dice la linea1 que es diferente a la linea2
    mov edx,200
    call DisplayText
    mov ecx,linea2	; imprime lo que dice la linea2 que es diferente a la linea1
    mov edx,200
    call DisplayText
    ;Limpia registros
    xor eax,eax	
    xor ebx,ebx
    xor ecx,ecx
    xor esi,esi
    ; SACA LOS CONTADORES DE LINEAS Y POSICIONES EN LOS ARCHIVOS
    pop ecx
    pop ebx
    pop eax	
    pop esi
	jmp .fciclo; salta al final del ciclo

.buena:
	cmp dh,10; compara el byte de la linea1,con un enter 
	jne .imprimir; si no es asi imprime
	cmp dl,10	; compara el byte de la linea2 con un enter
	jne .imprimir; si no es asi lo imprime
	jmp .fciclo	; salta al final del ciclo
	
.fciclo:
	inc ecx	;incrementa el indice de bytes del archivo2
	inc ebx; incrementa el indice de bytes de archivo1
	inc eax	; incrementa la linea actual
	;LOS GUARDA EN LA PILA
	push ecx	
	push eax
	push ebx
	;LIMPIA LINEA1 Y LINEA2
	xor eax,eax	
   	mov     edi, linea1
	mov     ecx, 200
    rep     stosb
   	mov     edi, linea2
	mov     ecx, 200
    rep    	 stosb
    ;LOS SACA DE LA PILA
    pop ebx
	pop eax
    pop ecx
    ; contadores de lineas desde 0 
    mov edi,0
  	mov esi,0
;	vuelve al ciclo
    jmp .ciclo

.finArchivos: ; si un archivo llega al final, lo imprime
	mov ecx,msgFinArchivos
	mov edx,lenFinArchivos
	call DisplayText
	jmp prompt	; vuelve al prompt

	
	
	
	
Listo:	; imprime que se logro bien el proceso deseado
		mov ecx,msgListo
		mov edx,lenListo
		call DisplayText
		mov ebx,lenArg
		mov ecx,ebx
		call CleanBssData
		jmp prompt
	

ErrorNoArchivo:		; mensaje de error pero de que no exise el archivo dado
	mov ecx,msgErrorNoArchivo	; imprime mensaje de error
	mov edx,lenErrorNoArchivo
	call DisplayText
	mov ecx,msgEnter
	mov edx,lenEnter
	call DisplayText
	mov ebx,lenArg	; mueve el largo de toda la instruccion 
	mov ecx,ebx			; lo mueve al ecx
	call CleanBssData	; llama subrutina para limpiar los buffers
	jmp prompt	; vuelve al prompt
Error:
	mov ecx,msgError	; imprime mensaje de error
	mov edx,lenError
	call DisplayText
	mov ecx,msgEnter
	mov edx,lenEnter
	call DisplayText
	mov ebx,lenArg	; mueve el largo del argumento
	mov ecx,ebx			; lo mueve al contador
	call CleanBssData	; llama subrrutina que limpia buffers
    jmp prompt


leerArchivo:	; leer e imprimir archivo

	cmp eax, -4096 ; Existe?
	ja ErrorNoArchivo
	mov		ebx, eax			; lo lee 
	mov		ecx, fileBuf		;lo guarda en el buffer del archivo
	mov		edx, fileBufLen
	mov		eax, sys_read	
	int 	80h					
	
	mov ecx,fileBuf		; lo imprime
	mov edx,fileBufLen
	call DisplayText	
	call CleanBssData; subrutina que limpia los buffers de la .bss
	jmp prompt		 ; y vuelve al prompt


fin:  			; fin, cierra el programa
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
    
Confirmacion:		; imprime mensaje de confirmacion, y pide la respuesta, 
;	la respuesta queda en el buffer
;	en el eax queda el largo de la respuesta
	mov ecx,msgConfirmacion
	mov edx,lenConfirmacionMsg
	call DisplayText
	mov ecx,buffConfirmacion
	mov edx,lenConfirmacion
	call ReadText
	ret

 

; lee algo de la entrada estándar.debe "setearse" lo siguiente:
; ecx: el puntero al buffer donde se almacenará
; edx: el largo del mensaje a leer
ReadText:
    mov     ebx, stdin
    mov     eax, sys_read
    int     80H
    ret
    

; abre un archivo
;en el ebx, tiene que estar el nombre del archivo
;en el ecx tiene que venir el tipo de lectura	
;retorna el filedescriptor en el eax
Open:
	mov eax,sys_open
	int 80H
	ret 

;renombra un archivo
;ebx :nombre del archivo
;ecx: nuevo nombre del archivo
;retorna en el eax un 0 si fue exitoso el cambio de nombre, un -1 si hubo error
Rename:
	mov eax,sys_rename
	int 80h
	ret
	

;copiar un archivo
;ebx :nombre del archivo
;ecx: nuevo nombre del archivo
;retorna en el eax un 0 si fue exitoso el cambio de nombre, un -1 si hubo error	
Copy:
	mov eax,sys_link
	int 80h
	ret
;elimina un archivo 
;ebx : nombre del archivo 
;retorna en el eax un 0 si fue exitoso el cambio de nombre, un -1 si hubo error	
Remove:
	mov eax, sys_unlink
	int 80h
	ret
	
;subrutina que limpia todos los buffer que se utilizan
; usa la instruccion rep stosb
;edi, buffer 
;ecx: largo del buffer
CleanBssData:
	xor eax,eax
	mov 	edi,buffConfirmacion
	mov 	ecx,lenConfirmacion
	rep		stosb
	mov 	edi,bufferArg1
	mov 	ecx,lenArg1
	rep		stosb	
	mov     edi, bufferArg
	mov     ecx, lenArg
    rep     stosb
	mov     edi, bufferArg2
	mov     ecx, lenArg2
    rep     stosb
	mov     edi, bufferArg3
	mov     ecx, lenArg3
    rep     stosb
   	mov     edi, bufferArg4
	mov     ecx, lenArg4
    rep     stosb
    mov     edi, fileBuf
	mov     ecx, fileBufLen
    rep     stosb
    ret
; imprimir numero
;imprime un numero, lo pasa a ascii
; el numero tiene que estar guardado en el eax
; modifica los registros eax,ebx,ecx,edx,esi,edi
ImprimirNumero:
	mov 	ecx,10			;
	xor	bx,bx			;limpiar registro para usalrlo como contador de digitos de 16bits

.division:
	xor	edx,edx 	; limpia el registro edx
	div	ecx		;efectua la division
	push 	dx		; guarda en la pila el digito
	inc 	bx		; contador+1
	test 	eax, eax	; fin del ciclo?
	jnz	.division	; si no es 0, el ciclo continua

acomoda_digitos:
	mov 	edx,resultado		; edx apunta al buffer<resultado>
	mov 	cx,bx			; contador se copia

.siguente_digito:
	pop ax				; saca de la pila 16 bits
	or al,30h			; convierte a ascii
	mov [edx],byte al		; escibo en direccion apuntada por edx -> resultado
	inc edx				; para escribir bien la siguiente vez
	loop .siguente_digito		

.imprime_numero:
	push 	bx		;guardamos el contador
	mov	ecx,resultado
	xor	edx,edx
	pop	dx		;cantidad de digitos
	inc	dx	; mostrar "c"
	call 	DisplayText	
	
	mov esi,ecx
	mov edi,edx
	
	mov ecx,c	; imprime una "c"
	mov edx,clen
	
	call 	DisplayText	
	
	mov ecx,esi	; imprime el numero de nuevo
	mov edx,edi
	call DisplayText
	xor ecx,ecx
	xor edx,edx
	mov ecx,msgEnter ; imprime un enter
	mov edx,lenEnter
	call DisplayText
	
	ret	; retorna, no devuelve nada importante, lo importante es lo que imprimio
