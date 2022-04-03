# Manejo puertos IO

El microcontrolador PIC18F4550 cuenta con **34 pines I/O** y  **13 pines análogos** . Soporta oscilador interno, externo y con cristal de cuarzo (Permitiendo utilizar un **PLL**). Cuenta con protocoles **RS232, SPI, I2C, Paralelo y USB 2.0**. Cuenta con **3 Temporizadores de 16 bits** y 1 de 8 bits con 2 canales PWM

El oscilador interno tiene un valor por defecto de 1MHz, con 8 posibles valores (Máximo **8 MHz** y minimo **31 kHz**).

Existen 5 puertos, el puerto **A** (simbolizado como RAx), el puerto **B**, así sucesivamente hasta el puerto **E**.

| Puerto |                Estado                 |
| --------- | ----------------------------------- |
| A          | 7 pines puerto incompleto  |
| B         | 8 pines, puerto completo    |
| C         | 7 pines, puerto incompleto |
| D         | 8 pines, puerto completo    |
| E         | 4 pines, puerto incompleto |

Los puertos son configurables, pueden empezar con funciones especiales como **MCLRE** o **LVP**. 
- El pin **RB5** es **LVP**
- Pin **RE3** es **MCLRE**
- Pin **RA6** se puede usar cuando se usa el **oscilador interno**.
- Los 5 pines RB0-RB4 inician siendo entrada analogas.
- Los pines RC4 y RC5 tienen funciones usb, para desactivar el USB se coloca en 0 el bit 3 del registro **UCON**.
- Los 4 pines de RA0 al RA3, los 5 de RB0 a RB4 y los pines RE0 al RE2 son entradas analógicas, se liberan escribiendo el valor de 15 al registro **ADCON1** (Ya no tendria sentido PBADEN = OFF).

```nasm
CONFIG LVP = OFF ;Habilida RB5
CONFIG MCLRE = OFF ;Habilita RE3
CONFIG FOSC = INTOSC_ECIO ;Habilita RA6
CONFIG PBADEN = OFF; Desactiva la entrada analoga de RB0-RB4
```

## Configuración y uso de puertos

Existe un conjunto de 3 registros por puerto, los cuales se utilizan para la configuración, uso y lectura de los pines. De los 34 pines, solo 31 se pueden usar como salida. 
- **TRISx**: Configura si es entrada o salida, **Todos los TRISx empiezan en 1 despues de un reset**.
    - 0 = salida
    - 1 = entrada
- **LATx**: Establece el valor de la salida, **Empiezan indeterminados despues de un reset**.
- **PORx**: Nos permite leer el estado actual del pin, especificamente para entradas. 


### Mascara de entrada
Cuando queremos consultar el valor de un registro usualmente leemos el registro PORTx. Sin embargo, los bits del registro PORTx tambien cuentan con la informació de las salidas, por lo que el valor obtenido al consultar el registro se ve contaminado con el valor de las salidas. Para esto podemos utilziar una **Mascara de entrada** la cual nos permite leer la información relevante del registro PORTx.

```nasm
Inicio
    movlw b'01110001'
    movwf TRISD
    bsf LATD,7
Menu
    movf PORTD,w
    andlw b'01110001' ;Mascara de entrada
```

La mascara de entrada '01110001' realiza una operación **and** con el valor de PORTD y almacena el resultado en **w**. Obsevese que al usar **and** el resultado obtenido solo tendra el cuenta los valores del registro cuya máscara sea *1*. 

### Mascara de salida
Si queremos aplicar un valor de salida a un registro debemos seleccionar adecuadametne que valor aplicarle. Si no tenemos en cuenta el estado actual del puerto de salida, estariamos sobrescribiendo valores en el registro, dañando la finalidad del programa. Para esto utilizamos una mascara de salida.
```nasm
Inicio
    clrf TRISD ;Todos son salidas
    bsf LATD,7 ;Encendemos el bit RD7
    movlw .6 ;Cargamos el valor '00000110'
    movwf aux1
Menu
    movf PORTD,w ;Leemos el estado de salida del puerto ('10000000')
    andlw b'11110000' ;Aplicamos una mascara de entrada, despreciando los primeros 4 bits
    iorwf aux1,w    ;Inyectamos el dato que queremos sin borrar RD7 ('1000000' -> '10000110')
    movwf LATD    ;Cargamos el valor final en LATD
```

### Ejemplos de lectura - escritura de puertos 

Consultar si RB0 está en 0
```nasm
btfss    PORTB,0    ;If RB0=1, skip
goto    Subrutuna1
```
Consultar si RC0 está en 1
```nasm
btfc    PORTC,0
goto    Subrutina1
```
Leer todo el puerto D y guardar en una variable
```nasm
movf PORTD,W
movwf miVar
```