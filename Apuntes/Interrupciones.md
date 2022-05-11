
# Interrupción externa

Toda interrupción debe ser implementada mediante una serie de pasos:
1. Configurar el periférico o los periféricos.
2. Seleccionar la prioridad si se requiere.
3. Asegurarse que la bandera empiece en cero.
4. Habilitar individualmente la interrupción.
5. Habilitar el grupo de interrupciones si se requiere.
6. Habilitar globalmente las interrupciones.

Los PIC18 tienen 2 niveles de prioridad, por lo tanto va a tener dos vectores de interrupción. Cuando se tienen multiples fuentes de interrupción, se hace importante poder diferenciar cual es el origen especifico de la interrupción, para que sea atendida oportunamente. Este algoritmo de detección de fuente de interrupción se llama algoritmo de "polling", en el se analizan los bits de bandera de cada interrupción, buscando encontrar cual fué la que ocurrió, para ejecutar su respectiva subrutina. Una vez se ingresa en la rutina de la interrupción, se debe borrar la bandera de interrupción e implementar el código ISR correspondiente. Al final de las interrupciones se debe retornar al punto del programa donde estaba el codigo.

1. Ubicar el vector de interrupción correspondiente según prioridad.
2. Implementar un algoritmo de "polling".
3. Borrar la bandera de interrupción.
4. Implementar el código de la IST como tal. 
5. Retornar de la interrupción según la sintaxis del lenguaje usado. 

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