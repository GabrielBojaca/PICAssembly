
# Interrupción externa

```nasm
ORG 0x0
    goto Inicio
ORG 0x8
    goto ISR
Inicio
    bsf    INTCON2,6
    bcf    INTCON,1
    bsf    INTCON,4
    bsf    INTCON,7
Menu
*********************

*********************
ISR
    btfsc    INTCON,1
    goto    ISR_INT0
ISR_INT0
    bcf    INTCON,1
    bsf    LATD,0
    retfie
```

# Resets

Reset
- **MCLR** : Externo
- **POR**:
- **BOR**: Reinicio por voltaje critico 
- **WDT**: investigar el WDTPS
- **RESET**:
- **UP STACK** : call
- **DOWN STACK**: return

El posible saber cual fue la fuente de *RESET*, pues existe un bit que indica que ocurrió, para *POR BOR WDT RESET* el registro es **RCON**.

Para *UP STACK/DOWN* el registro *STACKCON*. 

# Modos de bajo consumo
 
Existen dos modos de bajo consumo; El modo de bajo consumo parcial y el modo de bajo consumo total.
- **Parcial**: *CPU* sin reloj y *perifericos* con reloj (Lo que les permite utiizar las interrupciones).
- **Total**: *CPU* y *perifericos* sin reloj.

Para entrar al modo bajo consumo se usa la instrucción **sleep**  Es posible salir del *sleep* usando los resets, como por ejemplo el perro guardian (El cual es un periferico, asi que solo sirve para modo de bajo consumo *parcial*) y las interrupcine.Para el modo de suspensión total es posible utilizar las fuentes de reset MCLR POR y BOR y los perifericso sin reloj. Los perifericos sin señal de reloj son las interrupciones INT 0,1,2 y la de teclado.

El bit IDLEN (OSSCON <7>) configura el tipo de suspension que se desea , para la suspension total *1* y para la suspension parcial *0*. 