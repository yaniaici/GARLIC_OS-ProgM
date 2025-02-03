@;==============================================================================
@;
@;	"garlic_itcm_graf.s":	c�digo de rutinas de soporte a la gesti�n de
@;							ventanas gr�ficas (version 1.0)
@;
@;==============================================================================

NVENT	= 4					@; n�mero de ventanas totales
PPART	= 2					@; n�mero de ventanas horizontales
							@; (particiones de pantalla)
L2_PPART = 1				@; log base 2 de PPART

VCOLS	= 32				@; columnas y filas de cualquier ventana
VFILS	= 24
PCOLS	= VCOLS * PPART		@; n�mero de columnas totales (en pantalla)
PFILS	= VFILS * PPART		@; n�mero de filas totales (en pantalla)

WBUFS_LEN = 36				@; longitud de cada buffer de ventana (32+4)

.section .itcm,"ax",%progbits

	.arm
	.align 2


	.global _gg_escribirLinea
	@; Rutina para escribir toda una l�nea de caracteres almacenada en el
	@; buffer de la ventana especificada.
	@; Par�metros:
	@;   R0: ventana a actualizar (int v)
	@;   R1: fila actual (int f)
	@;   R2: n�mero de caracteres a escribir (int n)
_gg_escribirLinea:
    push {r3-r8, lr}               @; Guardamos registros de trabajo y lr en la pila

    @; Calculamos el desplazamiento inicial de la ventana en la memoria.
    push {r0}                      @; Guardamos el n�mero de ventana
    bl _gg_posicionVentana         @; Llamamos a la funci�n para calcular la posici�n base de la ventana
    mov r3, r0                     @; Movemos la direcci�n calculada a R3
    pop {r0}                       @; Restauramos el n�mero de ventana a R0

    @; Calculamos el desplazamiento para la fila actual.
    mov r5, #PCOLS                 @; Cargamos el n�mero de columnas totales en pantalla
    mul r4, r1, r5                 @; Multiplicamos por la fila actual (R1 * PCOLS)
    mov r4, r4, lsl #1             @; Desplazamos a la izquierda para convertir a bytes (cada baldosa son 2 bytes)
    add r3, r4                     @; Sumamos el desplazamiento a la direcci�n base de la ventana

    @; Cargamos el buffer de la ventana (pChars) desde _gd_wbfs.
    ldr r4, =_gd_wbfs              @; Cargamos la direcci�n del buffer de ventanas
    mov r6, #WBUFS_LEN             @; Cargamos el tama�o de un buffer de ventana
    mul r5, r0, r6                 @; Multiplicamos por el n�mero de ventana para encontrar el buffer correspondiente
    add r4, r5                     @; Sumamos el desplazamiento para obtener el inicio del buffer de la ventana
    add r4, #4                     @; Ajustamos el puntero para saltar el encabezado del buffer y apuntar a pChars

    @; Inicializamos el contador de caracteres.
    mov r5, #0                     @; R5 ser� el contador del bucle
    cmp r2, r5                     @; Comparamos si hay caracteres que escribir
    beq .fi_while                  @; Si no hay caracteres, salimos del bucle

.while_charLeft:
    @; Escribimos los caracteres uno por uno.
    ldrb r6, [r4]                  @; Cargamos el car�cter de pChars (1 byte)
    sub r6, #32                    @; Convertimos el valor ASCII a c�digo de baldosa (elimina el offset)
    strh r6, [r3]                  @; Guardamos el valor en la posici�n correcta de la memoria (2 bytes)
    add r5, #1                     @; Incrementamos el contador de caracteres
    add r4, #1                     @; Movemos el puntero pChars al siguiente car�cter
    add r3, #2                     @; Movemos el puntero de la fila al siguiente par de bytes (cada baldosa son 2 bytes)
    cmp r2, r5                     @; Comprobamos si hemos escrito todos los caracteres
    bne .while_charLeft            @; Si no hemos terminado, continuamos el bucle

.fi_while:
    pop {r3-r8, pc}                @; Restauramos los registros y regresamos de la rutina


	.global _gg_desplazar
	@; Rutina para desplazar una posici�n hacia arriba todas las filas de la
	@; ventana (v), y borrar el contenido de la �ltima fila.
	@; Par�metros:
	@;   R0: ventana a desplazar (int v)
_gg_desplazar:
    push {r1-r12, lr}         @; Guardar registros usados
	
	@; Calculamos el desplazamiento inicial de la ventana en la memoria.
    push {r0}                 @; Guardar el valor de la ventana (v)
    bl _gg_posicionVentana    @; Llamar a la funci�n para obtener la posici�n de la ventana
    mov r1, r0                @; Guardar la posici�n base de la ventana en r1
    pop {r0}                  @; Recuperar el valor de la ventana (v)
    
    mov r3, #PCOLS            @; N�mero de columnas por ventana
    mov r2, #1                @; Contador de filas, empieza en la segunda fila (fila 1)
    mov r4, #0                @; Contador de columnas
    mov r11, #0               @; Offset para puntero de fila
    mov r12, #0               @; Baldosa vac�a (valor 0)

@; Bucle principal para desplazar todas las filas hacia arriba
desplazar_lineas:
    mov r4, #0                @; Reiniciar el contador de columnas para la nueva fila
    mov r11, #0               @; Reiniciar el offset de fila
    sub r5, r2, #1            @; Obtener la fila anterior (r5 = fila actual - 1)
    mul r6, r5, r3            @; Calcular el desplazamiento para la fila anterior
    mov r6, r6, lsl #1        @; Multiplicar por 2 porque cada baldosa ocupa 2 bytes
    mul r7, r2, r3            @; Calcular el desplazamiento para la fila actual
    mov r7, r7, lsl #1        @; Multiplicar por 2 (2 bytes por baldosa)
    add r6, r1                @; r6 = puntero a la fila anterior
    add r7, r1                @; r7 = puntero a la fila actual

@; Bucle interno para copiar cada columna de la fila actual a la fila anterior
copiar_linea:
    cmp r4, #VCOLS            @; Comparar el contador de columnas con el n�mero total de columnas
    bhs final_linea           @; Si r4 >= VCOLS, salimos del bucle de la fila
    ldrh r8, [r7, r11]        @; Cargar el valor de la fila actual en r8
    strh r8, [r6, r11]        @; Guardar el valor de r8 en la fila anterior
    strh r12, [r7, r11]       @; Guardar una baldosa vac�a en la fila actual
    add r4, #1                @; Incrementar el contador de columnas
    add r11, #2               @; Incrementar el offset de fila (2 bytes por baldosa)
    b copiar_linea            @; Volver al inicio del bucle para procesar la siguiente columna

@; Final de la fila actual, pasar a la siguiente fila
final_linea:
    add r2, #1                @; Incrementar el contador de filas
    cmp r2, #VFILS            @; Comparar con el n�mero total de filas
    bls desplazar_lineas      @; Si r2 <= VFILS, continuar con la siguiente fila

@; Final de la rutina
final_desplazar:
    pop {r1-r12, pc}          @; Restaurar registros y regresar


	.global _gg_posicionVentana
	@; Par�metros:
	@;   R0 -> n�mero de ventana (int v)
	@; Retorno:
	@;   R0 -> Direcci�n de la posici�n 0,0 de la ventana en el mapa
_gg_posicionVentana:
    push {r1-r5, lr}               @; Guardamos registros de trabajo y lr en la pila

    @; Calculamos (v % PPART) y (v / PPART).
    and r1, r0, #L2_PPART          @; R1 = v % PPART (usamos L2_PPART para calcular el m�dulo de forma eficiente)
    mov r2, r0, lsr #L2_PPART      @; R2 = v / PPART (desplazamiento l�gico derecho)

    @; Calculamos el desplazamiento en el mapa para la ventana.
    mov r3, #PCOLS * VFILS         @; Cargamos PCOLS * VFILS (n�mero de columnas totales * filas por ventana)
    mov r5, #VCOLS                 @; Cargamos el n�mero de columnas por ventana
    mul r4, r2, r3                 @; R4 = (v / PPART) * PCOLS * VFILS
    mla r2, r1, r5, r4             @; R2 = (v / PPART) * PCOLS * VFILS + (v % PPART) * VCOLS
    mov r2, r2, lsl #1             @; Desplazamos a la izquierda para convertir el desplazamiento a bytes (cada baldosa son 2 bytes)

    @; Obtenemos la direcci�n base del mapa de memoria (bg2map).
    ldr r1, =bg2map                @; Cargamos la direcci�n del puntero al mapa de memoria
    ldr r1, [r1]                   @; Cargamos la direcci�n base del mapa
    add r0, r1, r2                 @; R0 = direcci�n base + desplazamiento calculado
	
    pop {r1-r5, pc}                @; Restauramos los registros y regresamos de la funci�n

	@; Nueva funci�n GARLIC_setChar para definir caracteres personalizados
	.global _ga_setChar
_ga_setChar:
    push {r4-r6, lr}           @; Guardar registros de trabajo y lr en la pila
    
    mov r4, r0                 @; r4 = n (n�mero de car�cter entre 128 y 255)
    mov r5, r1                 @; r5 = buffer (puntero a la matriz 8x8)
    
    @; Verificar si el n�mero de car�cter est� en el rango 128-255
    cmp r4, #128             
    blt .fin_setChar           @; Si n < 128, salir (no v�lido)
    cmp r4, #255
    bgt .fin_setChar           @; Si n > 255, salir (no v�lido)
    
    @; Calcular la direcci�n base para almacenar el car�cter
    ldr r6, =0x06012000        @; Ajusta la direcci�n base seg�n el mapa de memoria
    sub r4, #128               @; Restar 128 para indexar en el mapa de caracteres personalizados
    mov r4, r4, lsl #6         @; Multiplicar por 64 (8x8 bytes = 64 bytes por car�cter)
    add r6, r4                 @; r6 apunta al inicio del �rea de almacenamiento de este car�cter
    
    @; Llamar a _gs_copiaMem para copiar el buffer de 64 bytes a VRAM
    mov r0, r5                 @; Direcci�n fuente (buffer)
    mov r1, r6                 @; Direcci�n destino (VRAM)
    mov r2, #64                @; N�mero de bytes a copiar
    bl _gs_copiaMem            @; Llamada a la funci�n de copia de memoria
    
.fin_setChar:
    pop {r4-r6, pc}            @; Restaurar registros y regresar

.end