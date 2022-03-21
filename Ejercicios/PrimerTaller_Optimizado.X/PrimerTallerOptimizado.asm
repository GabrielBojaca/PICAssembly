include p18f4550.inc
    
aux1 equ 0h
aux2 equ 1h
aux3 equ 2h
aux4 equ 3h

Inicio

;----------Primer Ejercicio----------
    movlw   .7
    movwf   aux1
    addlw   .3
 
;----------Segundo Ejercicio----------
    movwf aux2	;Se emplea el valor W (10) para aux 2
    movlw   .8
    movwf   aux1
    addwf   aux2,w    
    
;----------Tercer Ejercicio----------
    movlw   .5
    movwf   aux1
    sublw   .9
    
    btfsc   STATUS,4
	negf WREG	;Comprobacion por complemento a 2 
 
;----------Cuarto Ejercicio----------
    movwf   aux2    ;Usamos el resultado anterior
    movlw   .6
    movwf   aux1
    subwf   aux2,w
    
    btfsc   STATUS,4
	negf WREG	;Comprobacion por complemento a 2 
    
;----------Quinto Ejercicio----------
    movlw   .12
    movwf   aux1
    comf    aux1
 
;----------Sexto Ejercicio----------
    incf    aux1
    
;----------Septimo Ejercicio----------
    movlw   .35
    movwf   aux1
    iorlw   .7
;----------Octavo Ejercicio----------
    movlw   .20
    movwf   aux1
    movlw   .56
    movwf   aux2
    iorwf   aux1,w  ;Optimizable, No guardar en W
;----------Noveno Ejercicio----------
    movlw   .62	;Optimizable
    movwf   aux1
    andlw   .15
;----------Decimo Ejercicio----------
    movlw   .100
    movwf   aux1
    movlw   .45
    movwf   aux2
    andwf   aux1,w
;----------Decimoprimero Ejercicio----------
    movlw   .120
    movwf   aux1
    xorlw   .1
;----------Decimosegundo Ejercicio----------
    movlw   .17
    movwf   aux1
    movlw   .90
    movwf   aux2
    xorwf   aux1,w
;----------Decimotercero Ejercicio----------   
    movlw   .25
    movwf   aux1
    movlw   .40
    movwf   aux2
    
    iorwf   aux1,w   ;Realizamos aux1 OR aux2
    movwf   aux4
    
    movlw   .103
    movwf   aux3    
    
    xorlw   0xD0    ;Realizamos aux3 XOR 0xD0
    andwf   aux4
    
    goto Inicio
 
end
    
