# Ensamblador
Ensamblador es un lenguaje basado en abreviaturas. Toma cada instrucción y mediante el uso de Mnemónico (Palabra que representa un codigo de operación) las representa en un lenguaje compresible por el ser humano. 
## Ejemplo:

```
aux1 equ 0h  ;Creamos una variable en la posicion de memoria 0h 
clrf aux1  ;Limpiamos la memoria en 0h
```

El mnémonico clrf acompañado de aux1 corresponde a la instrucción:

 ```
 0110101000000000
 ```

Cuyos primeros 7 bits corresponden a la instrucciòn de limpiar
El bit 8 correponde al banco de acceso
Los ultimos 8  bits corresponden a la posicion de memoria 0h

## Organización de un codigo en ensamblador

El codigo deberia estar organizado en:

1. Inclusión de librerías y definición de simbolos
2. Directivas de configuración
    - Configuración de parametros internos del microcontrolador.
3. Definición de variables
    - Definición de posiciones de memoria para las variables.
    - Todas las posiciones de memoria tienen 8 bits
    - Se especifican en hexadecimal `0h 1h 9h 0xa 0xE00h`
    - No existen los tipos de variable.
4. Instrucciones en ensamblador
    - Programa.

## Conjuntos de instrucciones 

El PIC18F4550 consta con un conjunto de **75 instrucciones** las cuales se organizan segun los siguientes criterios:

- Según la operación que realizan.
- Según el modo de direccionamiento.
- Según el espacio que ocupan en memoria. 
- Según el tiempo que tardan en ejecutarse.

Existe un conjunto de operaciones especiales (Set extendido de operaciones), el cual consta de 8 instrucciones.

70 instrucciones del set estandar de instrucciones ocupan **16 bits o 2 Bytes**, las demás ocupan **32 bits o 4 Bytes** (Por ejemplo GOTO y MOVFF usan 4 Bytes)

## Nomenclatura de las instrucciones

### Operando literal
El uso del operando literal 'l' indica que se està trabajando con una constante.
El uso de **w** significa que el resultado irá al registro **w**

 `movlw` -> `mov`**l**`w` 
#### Ejemplos:
```
movlw .5
movlw ' @' 
movlw 0x25 
movlw b' 11001010' 
movlw o'167' 
lfsr aux1 
```

## Ciclo de bus

Para la ejecución de un instrucción normalmente se necesitan 4 ciclos de reloj. Microchip usa la arquitectura **Harvard** con un set de instrucciones **RISC**.

Un **ciclo de bus** son **4 ciclos de reloj**.

### Operaciones de un ciclo de bus

Toda operacion aritmética, logíca, de movimiento o de control donde un operando sea **WREG**, siempre y cuando no sea una operacion de salto, utilizarà un solo ciclo de bus para su ejecución.
```
nop 
movlw 
negf 
movf
```

### Operaciones de dos ciclos de bus

Si la operacion maneja dos operandos, o su unico operando es mayor a 8 bits la operacion durará 2 ciclos de bus. Las operaciones de **salto incondicional** tambien necesitarán 2 ciclos de bus para ser ejecutadas.

```
movff  
lfsr
call
goto
```

### Tres ciclos de bus o menos...

El salto condicional puede variar sus ciclos de bus, ya que debe comprobar si la condicion de salto de cumple, debe calcular a que posicion debe caer el contador de programa y finalmente debe desplazarse a la instrucción destino. Si debe saltar una unica instrucción de 2 Bytes, utilizará 3 ciclos de reloj.

#### Ejemplo 1 o 2 ciclos de bus

Si se cumple la condición z, deberá saltar calculando un salto relativo (Necesita saber cuantas lineas debe saltar para llegar a **Menu**), usando 2 ciclos de bus. Caso contrario, usará solo 1. 
```
bz Menu  ;Salta si el bit z es 1
clrf
************
Menu
```
    Un salto relativo no puede superar 128 posiciones.

#### Ejemplo 1,2 o 3 ciclos de bus

La operaciòn decrementa la variable aux1, y salta si el resultado del decremento dió 0.
`decfsz aux1,f`
Si no se cumple la condicíon, no genera salto, y se ejecutará en un unico ciclo de bus (Pues solo hace un decremento).
Si el decremento da 0, saltará la instrucción inmediatamente siguiente. **Los ciclos necesarios para saltarla dependerán del tamaño de la instruccíon que debe saltar** Si es de 2 Bytes debe saltarla en 2 ciclos de bus. Usando 3 ciclos de bus para completar la operacíon *decfsz*. 

## Modo de direccionamiento

La interacciòn entre *ROM RAM y CPU* varia de acuerdo a la instrucción que utilizamos, si utilizamos o no la RAM, el registro u otros registros. De acuerdo a esto, existen 6 modos de direccionamiento:

### Modo inherente
Cuando la instrucción no tiene operandos, por lo tanto no se utiliza ninguna variable. **Solo usan un ciclo de bus**

```
nop     0000 0000 0000 0000
clrwdt  0000 0000 0000 0100
sleep   0000 0000 0000 0011
reset   0000 0000 1111 1111
daw     0000 0000 0000 0111
```

### Modo inmediato
Cuando se usan constantes, la constante está en la misma instrucción
```
movlw .7	;0000 1110 kkkk kkkk
            ;0000 1110 0000 0111
movlb 0xC	;0000 0001 0000 kkkk
            ;0000 0001 0000 1100
```
### Modo directo

Cuando se utilizan variables o registros, por lo que debe especificarse la posición de memoria. 
```
aux1 equ 2h
***************
    movwf aux1    ;0110 111a ffff ffff 
                  ;0110 1110 0000 0010
```
### Modo relativo

Cuando se modifican el **PC** dependiendo del **STATUS** (Instruacciones de salto)

Si se cumple una condicion se realiza un salto, modificando el contador de programa (PC).

    El contador de programa siempre debe ser modificado con numeros pares

```
(0x02) bc Siguiente ;1110 0010 nnnn nnnn 
                    ;1110 0010 0000 0010
*************
Siguiente
(0x08) clrf aux1
```

### Modo extendido

Cuando se salta a cualquier etiqueta de codigo, instrucciones que necesitan 32bits 

```
call Retardo ;1110 110s kkkk kkkk
              ;1111 kkkk kkkk kkkk 
; Usando la posicion de retardo divido en 2
                  ;1110 1100 1111 1010
                  ;1111 0000 0000 0000
(Retardo 0x1F4)
```

### Modo indirecto

Usando apuntadores **FSRx** (0,1,2)

```
aux1 equ 4h
***************
Menu
    lfsr 0,aux1 ;1110 1110 00ff kkkk
                    ;1111 0000 kkkk kkkk
    ;Usando aux1
                ;1110 1110 0000 0000
                ;1111 0000 0000 0010
    incf INDF0,f ;Incrementar INDF0, sin apuntar a aux1 necesariamente. **Apuntador**
```

## Inclusióon de librerias

`include P18f4550.inc`

Se pueden incluir librerias administrando adecuadamente la ubicacion de las instrucciones en esta libreria

## Directivas de configuración

Parametros internos del microcontrolador, como el perro guardian, protección contra escritura/lectura, etc.

```
config FOSC=INTOSC_EC
config WDT=OFF
config MCLRE=OFF
```
    
## Declaración de variables

Todas las variables son de 8 bits con codificacion de signo segun la instrucción utlizada

```nasm
Var1 equ 0h
Var2 equ 1h
Var3 equ 9h
Var4 equ 0xA
Var5 equ 0x7FF
```

Las priemras 96 posiciones de la RAM son el Access Bank

## Instrucciones

Las instrucciones siguen una estructura ordenada, la cual sigue la siguiente forma:


| Etiquetas   |    Mnemónicos      | Operandos  | Comentarios |
|:----------:|:-------------:|:-------------:|:------:|

### Ejemplo:

```
Inicio  ;Etiqueta
    clrf TRISD ; Mnemonico, Operando, comentario
```

## Modificación del PC

Un programa avanza de forma lineal, sumando +2 al PC y +4 segun el tamaño de la instruacción

```assembly
Menu
    clrf TRISD  (0x04)
    clrf LATD   (0x06)
    movlw .5    (0x08)
    movwf aux1  (0x0A)
    movff aux1, aux2 (0x0C) ;Ocupa 4 posiciones
    nop         (0x10)
```

## Etiquetas

Una etiqueta es un nombre que le colocamos a una posicion de memoria para facilitar la programacion.

```assembly
Menu
    clrf TRISD  (0x04)
Menu2
    clrf LATD   (0x06)
Menu3
    movlw .5    (0x08)
```

## Saltos

Un salto es una modificacion al PC

```assembly
Inicio
    goto Menu  ;goto (0x04)
********************
Menu
    clrf aux (0x40)
```

### Saltos incondicionales

Salto con *goto* a cualquier etiqueta especificada bajo ninguna condicion.

### Saltos condicionales relativos

Saltos que se realizan si se cumple una condicion, este salto será una suma de un valor de 8 bits al PC, por lo que el salto debe estar entre -128 y 127. 

```nasm
Menu
    movf aux1,w   ;Carga el valor de aux1 en w
    subwf aux2,w    ;Resta aux2 a w
    bz Iguales      ;Si z = 0 (Son iguales) salga a Iguales
**********************

Iguales
```


### Saltos condicionales skip

Salta una única instrucción.

```nasm
Menu
    btfss PORTC,0   ;Si RCO==1 => PC salta una instrucción 
    goto Encender   ;Si RCO!=1 => No realiza ningún salto
    incf aux1,f
****************
Encender
    bsf LATD,1
```
### Salto a subrutinas

Al usar la instrucción *call* el microcontrolador guarda la posicion en memoria (Stack) de la siguiente instrucción *(0x08)*, luego realiza el salto a Retardo *(0x42)* , cuando llega a la instrucción *return* *(0x56)* retorna a la posicion *(0x08)*.

```nasm
Menu
    call Retardo (0x04)
    decf aux1   (0x08)
*******************
Retardo
    movlw .5 (0x42)
******************
    return (0x56)

```
### Saltos computados

Modifican directamente el contador del programa
```nasm
addwf PCL,f ;Sumar a PC + W
```
## Sentencias 

### If
La preguntas más comunes para implementar un if pueden ser:

- Bit = 0 o 1
- Valor de 8 bits = 0
- Valor de 8 bits igual a otro valor de 8 bits
- Valor de 8 bits mayor a otro.
- Una operacion en la *ALU* generó acarreo?

#### Preguntando un bit

*btfss* Si  se cumple la condicion RCO == 1 (Bit numero 0 del puerto C) ignora *goto Siguiente* , ignorando lo que esté entre *nop* y Siguiente.
*btfsc* RCO == 0

```nasm
Menu
    *******************
    btfss PORTC,0   ;RCO==1?
    goto Siguiente
    nop
    *******************
Siguiente
```

#### Preguntando si un valor es 0

```nasm
Menu
    *******************
    tstfsz var1 ;var1==0? Si se cumple, se salta el goto
    goto Siguiente
    nop
    *******************
Siguiente
```

#### Son iguales

```nasm
Menu
    *******************
    movf var1,w 
    cpfsesq var2    ;var1==var2? Si se cumple se ignora el goto
    goto Siguiente
    nop
    *******************
Siguiente
```

### Es mayor o menor

```nasm
Menu
    *******************
    movf var1,w 
    cpfsgt var2    ;var1>var2? Si se cumple se ignora el goto
    goto Siguiente
    nop
    *******************
Siguiente
```

### Se generó acarreo
```nasm
Menu
    *******************
    movf var1,w 
    addwf var2,w
    bc HayAcarreo   ;C==1?
    *******************
HayAcarreo
    *******************
```
### IF-ELSE

********************

### SWITCH

```nasm
Sentencia_SWITCH
    movlw A
    cpfseq opc
    goto PreguntarB
    goto CasoA
PreguntarB
    movlw B
    cpfseq  opc
    goto PreguntarC
    goto CasoB
PreguntarC
```

### While 

```nasm
CicloWhile
    btfss PORTB,0 ;RBO==1?
    goto FinCiclo
    ***************
    gotoCicloWhile
FinCiclo
```

### FOR

```nasm
InicioCicloFor
    clrf contador
CicloFor
    movlw .5    ;Comparamos si es menor que 5
    cpfslt  contador    ;Si es menor que 5 no ha terminado ;Skip if f<w
    goto FinCiclo
    ***************
    incf contador,f
    gotoCicloFor
FinCiclo
    ***************
```
## Tablas de constante

Puede ser necesario almacenar valores constantes en la memoria, ya sea para ser usados para calculos o para ser mostrados en un display, serie de leds, etc.
Para esto crearemos una rutina llamada *Tabla* la cual tendrá una variable llamada *index*, con esta variable entraremos a la tabla, calcularemos la posicion donde el *PC* debe caer para retornarnos el valor que deseamos. 
Para retornar el valor que deseamos usaremos la instrucción **RETLW** la cual cargará en el registro **W** el valor que deseemos y ejecutará una operacion semejante a **RETURN**, retornando así a la posicion donde estabamos con el dato que deseabamos en el registro *W*

Cada vez que ejecutamos una operación se ejecuta una suma a **PC** de la siguiente manera **PC<-PC+2**. Si ejecutamos la instrucción <code>addwf PCL,f</code> estaremos realizando la instrucción **PC<-PC+2+W**

### Llamando una tabla de constantes
```assembly
indice equ 0h
Menu
    ***************
    rlncf indice,w ;Multiplicamos el indice X2 y guardamos a W
    call Tabla
Tabla
(0XA0)  addwf PCL,f ;Sumamos a PCL el valor W
(0XA2)  retlw 'H'
(0XA4)  retlw 'o'
(0XA6)  retlw 'l'
(0XA8)  retlw 'a'
```

Tenga en cuenta que si el indice es 0, la operación **addwf PCL,f** Pasará inmediatamente a la siguiente instruccion (**retlw 'H'**), por lo que puede entenderse que el index empieza desde 0.

### Restricción 

Tenga en cuenta que W se multiplica por 2, y que la suma PCL+W está limitada por el tamaño del Byte, por lo tanto hay que evitar acarreos. para esto se usa la instrucción **ORG**, nn es cualquier conjunto de 128 espacios de memoria (01 -> los primeros 128).
```nasm
ORG 0xnnFE
Tabla
    addwf PCL,f
    retlw 'H'
```

## Tablas en RAM 
Usando apuntadores (FSR0,FSR1,FSR2) se puede usar de forma dinámica toda la memoria RAM, haciendo referencia al primer dato de la tabla.
```nasm
Tabla equ 6h
******************
Menu
    lfsr 0,Tabla ;La posicion 0x6 ahora será 'Tabla'
```
Cuando ya se está referenciado tenemos 5 formas de acceder a la tabla

```nasm
INDF    ;Acceder a la posición dejando el apuntador intacto
POSTINC ;Acceder a la posicion y LUEGO e incrementar 1 al apuntador
POSTDEC ; Acceder a la posicion y LUEGO decrementa 1 al apuntador
PREINC  ; ANTES de acceder incrementa la posicion y luego accede (accederia a 0x7)
PLUSW   ; Antes de acceder incremente en W la posicion y luego accede (0x6 + W)
```

### Llenando la tabla 

```nasm
Tabla equ 6h
*******************
LlenarTabla
    ifsr 0,Tabla
    movlw 'H'
    movwf POSTINC0
    movlw 'o'
    movwf POSTINC
    ******************
    return
```

### Leyendo la tabla

```nasm
Menu
    ****************
    movf indice,w
    call LeerTabla
    movwf LATD
    ****************
LeerTabla
    lfsr    0,Tabla
    movf PLUSW0,w
    return
```
