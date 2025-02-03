@;==============================================================================
@;
@;	"garlic_itcm_mem.s":	código de rutinas de soporte a la carga de
@;							programas en memoria (version 2.0)
@;
@;==============================================================================

NUM_FRANJAS = 768
INI_MEM_PROC = 0x01002000

.section .dtcm,"wa",%progbits
	.align 2

	.global _gm_zocMem
_gm_zocMem:	.space NUM_FRANJAS			@; vector de ocupación de franjas mem de 32b.

_gm_zocalos:	.space 16

.global _gd_quo
_gd_quo: .word 0             @; Variable para el cociente (resultado de la división)

.global _gd_mod
_gd_mod: .word 0             @; Variable para el módulo (resultado de la división)

.section .itcm,"ax",%progbits

	.arm
	.align 2


	.global _gm_reubicar
	@; Rutina para interpretar y ajustar las referencias de tipo R_ARM_ABS32 en un archivo ELF.
	@; Parchea direcciones relativas a los segmentos de código y datos según las direcciones destino.
	@; 
	@; Parámetros:
	@; R0: Dirección del buffer del archivo ELF
	@; R1: Dirección inicial del segmento de código
	@; R2: Dirección destino del segmento de código
	@; R3: Dirección inicial del segmento de datos
	@; (pila): Dirección destino del segmento de datos
	@;
	@; Resultado:
	@; Actualiza las referencias reubicadas en memoria.

_gm_reubicar:
    push {r3-r12, lr}                @; Guardar registros y el enlace de retorno

    @; Obtener el desplazamiento de la tabla de secciones (e_shoff)
    ldr r4, [r0, #32]                @; Cargar e_shoff desde el ELF header
    add r4, r0                       @; R4 = dirección de la tabla de secciones

    @; Obtener el tamaño de cada entrada (e_shentsize) y el número de entradas (e_shnum)
    ldrh r5, [r0, #46]               @; Cargar e_shentsize
    ldrh r6, [r0, #48]               @; Cargar e_shnum (número de secciones)

    mov r12, #0                      @; Inicializar índice de secciones

@; ---- Iterar sobre las secciones ----
.LIterarSecciones:
    ldr r7, [r4, #4]                 @; Cargar sh_type (tipo de sección)
    cmp r7, #9                       @; ¿Es SHT_REL (sección de reubicación)?
    beq .LProcesarReubicacion        @; Si sí, procesar la sección de reubicación
    b .LProximaSeccion               @; Si no, pasar a la siguiente sección

@; ---- Procesar sección de reubicación ----
.LProcesarReubicacion:
    ldr r9, [r4, #16]                @; Cargar sh_offset (desplazamiento a la tabla de relocs)
    add r9, r0                       @; R9 = dirección de la tabla de relocs

    @; Guardar registros antes de calcular el número de entradas
    push {r0-r4}

    @; Obtener sh_size (tamaño de la sección) y sh_entsize (tamaño de cada entrada)
    ldr r0, [r4, #20]                @; Cargar sh_size
    ldr r1, [r4, #36]                @; Cargar sh_entsize
    ldr r2, =_gd_quo
    ldr r3, =_gd_mod
    mov r10, r1                      @; Guardar sh_entsize en R10
    bl _ga_divmod                    @; Dividir sh_size / sh_entsize
    ldr r8, [r2]                     @; R8 = número de entradas en la tabla de relocs

    @; Restaurar registros
    pop {r0-r4}

    mov r11, #0                      @; Inicializar índice de relocs

    @; Guardar registros antes de iterar sobre las relocs
    push {r4-r7}
    ldr r7, [sp, #60]                @; Dirección destino del segmento de datos desde la pila
    add r5, r9                       @; R5 = inicio de la tabla de relocs

@; ---- Iterar sobre los relocs ----
.LIterarRelocs:
    ldr r4, [r5, #4]                 @; Cargar r_info (información del reloc)
    and r4, #0xFF                    @; Extraer el tipo de reloc (bits bajos)
    cmp r4, #2                       @; ¿Es R_ARM_ABS32?
    bne .LProximoReloc               @; Si no, ignorar y pasar al siguiente

    @; Procesar R_ARM_ABS32
    ldr r4, [r5]                     @; Cargar r_offset (dirección a reubicar)
    sub r4, r1                       @; Restar la dirección inicial del segmento
    add r4, r2                       @; Sumar la dirección destino del segmento

    cmp r3, #0                       @; ¿Existe un segmento de datos?
    bne .LEsDatos                    @; Si sí, procesar como datos
    ldr r3, =0xFFFFFFFF              @; Si no, forzar valor máximo para evitar conflictos

.LEsDatos:
    ldr r6, [r4]                     @; Cargar el valor en la dirección reubicada
    cmp r6, r3                       @; Comparar con el inicio del segmento de datos

    sublo r6, r1                     @; Si es código: ajustar dirección relativa
    addlo r6, r2                     @; Sumar la dirección destino de código

    subhs r6, r3                     @; Si es datos: ajustar dirección relativa
    addhs r6, r7                     @; Sumar la dirección destino de datos

    str r6, [r4]                     @; Guardar el valor ajustado en memoria

@; ---- Procesar siguiente reloc ----
.LProximoReloc:
    add r5, r10                      @; Avanzar al siguiente reloc
    add r11, #1                      @; Incrementar índice de relocs
    cmp r11, r8                      @; ¿Procesamos todas las entradas?
    blo .LIterarRelocs               @; Si no, repetir

    @; Restaurar registros después de procesar los relocs
    pop {r4-r7}

@; ---- Pasar a la siguiente sección ----
.LProximaSeccion:
    add r4, r5                       @; Avanzar a la siguiente entrada en la tabla de secciones
    add r12, #1                      @; Incrementar el índice de secciones
    cmp r12, r6                      @; ¿Hemos procesado todas las secciones?
    blo .LIterarSecciones            @; Si no, repetir

    @; Restaurar registros y regresar
    pop {r3-r12, pc}

	

	.global _gm_reservarMem
	@; Rutina para reservar memoria consecutiva suficiente para un segmento de programa.
	@;Parámetros:
	@; R0: número del zócalo que reserva la memoria
	@; R1: tamaño en bytes que se necesita reservar
	@; R2: tipo de segmento (0 -> código, 1 -> datos)
	@;Resultado:
	@; R0: dirección inicial de la memoria reservada, o 0 si no es posible

_gm_reservarMem:
    push {r1-r8, lr}             @; Guardar registros y enlace de retorno en la pila

    mov r3, #0                   @; R3 = número de franjas necesarias
    mov r4, r1                   @; R4 = tamaño del segmento a reservar (en bytes)

@; ---- Calcular número de franjas necesarias ----
.LCalcularFranjas:
    sub r4, #32                  @; Restar 32 bytes (tamaño de una franja)
    add r3, #1                   @; Incrementar el número de franjas necesarias
    cmp r4, #0                   @; ¿Queda espacio por cubrir?
    bgt .LCalcularFranjas        @; Si sí, seguir calculando

@; ---- Buscar franjas libres consecutivas ----
    ldr r4, =_gm_zocMem          @; R4 apunta al inicio del vector de ocupación de memoria
    mov r5, #0                   @; R5 = índice actual en el vector (inicio)
    mov r6, #0                   @; R6 = contador de franjas libres consecutivas

.LBuscarFranjas:
    ldrb r7, [r4, r5]            @; Leer el estado de la franja actual (0 = libre)
    cmp r7, #0                   @; ¿La franja está libre?
    addeq r6, #1                 @; Si está libre, incrementar el contador
    movne r6, #0                 @; Si no está libre, reiniciar el contador
    cmp r6, #1                   @; ¿Es la primera franja libre de un bloque?
    moveq r8, r5                 @; Si sí, guardar el índice inicial del bloque en R8
    cmp r6, r3                   @; ¿Hemos encontrado suficientes franjas consecutivas?
    beq .LReservarFranjas        @; Si sí, pasar a reservar
    add r5, #1                   @; Avanzar al siguiente índice en el vector
    cmp r5, #NUM_FRANJAS         @; ¿Llegamos al final del vector?
    blt .LBuscarFranjas          @; Si no, seguir buscando
    b .LErrorReserva             @; Si no se encontró espacio, saltar al error

@; ---- Reservar las franjas necesarias ----
.LReservarFranjas:
    mov r5, #0                   @; R5 = contador de franjas reservadas
    add r4, r8                   @; R4 apunta a la posición inicial del bloque en el vector

.LMarcarFranjas:
    strb r0, [r4, r5]            @; Marcar la franja como ocupada por el zócalo en R0
    add r5, #1                   @; Incrementar el contador de franjas reservadas
    cmp r5, r3                   @; ¿Se han reservado todas las franjas necesarias?
    blt .LMarcarFranjas          @; Si no, continuar reservando

@; ---- Pintar representación gráfica de las franjas ----
    mov r1, r8                   @; R1 = índice inicial del bloque
    mov r3, r2                   @; R3 = tipo de segmento (0 -> código, 1 -> datos)
    mov r2, r6                   @; R2 = número total de franjas reservadas
    bl _gs_pintarFranjas         @; Llamar a la rutina para pintar las franjas

@; ---- Calcular dirección inicial de memoria reservada ----
    ldr r6, =INI_MEM_PROC        @; R6 = dirección base de la memoria de procesos
    add r5, r6, r8, lsl #5       @; R5 = dirección inicial del bloque reservado
    mov r0, r5                   @; R0 = dirección inicial a devolver
    b .LFin                      @; Saltar al final

@; ---- Manejar error: no se encontró espacio suficiente ----
.LErrorReserva:
    mov r0, #0                   @; Retornar 0 indicando error

@; ---- Restaurar registros y retornar ----
.LFin:
    pop {r1-r8, pc}              @; Restaurar registros y regresar

	
	.global _gm_liberarMem
	@; Rutina para liberar todas las franjas de memoria asignadas al proceso
	@; del zócalo indicado por parámetro; también se encargará de invocar a la
	@; rutina _gs_pintarFranjas(), para actualizar la representación gráfica
	@; de la ocupación de la memoria de procesos.
	@; Parámetros:
	@;   R0: el número de zócalo que libera la memoria

_gm_liberarMem:
	push {r1-r9, lr}            @; Guardar registros usados y LR en la pila

	ldr r1, =_gm_zocMem         @; R1 = Dirección base del vector de ocupación de franjas
	mov r2, #0                  @; R2 = Índice actual (contador de franjas)
	ldr r3, =NUM_FRANJAS        @; R3 = Número total de franjas disponibles
	mov r4, #0                  @; R4 = Valor para marcar franjas como libres (0)
	mov r5, #0                  @; R5 = Booleano para saber si un bloque ha comenzado
	mov r6, #0                  @; R6 = Número de franjas consecutivas a liberar
	mov r7, #0                  @; R7 = Índice inicial del bloque actual
	mov r8, #0                  @; R8 = Tipo de segmento (0 = código, 1 = datos)

@; Bucle principal: recorre todas las franjas
.LrecorrerFranjas:
	ldrb r9, [r1, r2]           @; R9 = Valor de la franja actual en _gm_zocMem
	cmp r9, r0                  @; ¿La franja pertenece al zócalo actual?
	bne .LfranjaNoPertenece     @; Si no pertenece, salta al siguiente paso

	@; La franja pertenece al zócalo, verificamos si es el inicio de un bloque
	cmp r5, #0
	bne .LcontinuarLiberacion   @; Si ya estamos dentro de un bloque, continuar liberando
	mov r5, #1                  @; Marcamos que estamos dentro de un bloque
	mov r7, r2                  @; Guardamos el índice inicial del bloque

.LcontinuarLiberacion:
	add r6, #1                  @; Incrementar el número de franjas consecutivas
	strb r4, [r1, r2]           @; Liberar la franja marcándola con 0
	b .LfinIteracion            @; Continuar con la siguiente franja

@; La franja no pertenece al zócalo actual
.LfranjaNoPertenece:
	cmp r5, #0
	beq .LfinIteracion          @; Si no estamos en un bloque, continuar iterando

	@; Si se termina un bloque, pintamos las franjas liberadas
	mov r5, #0                  @; Marcamos que ya no estamos en un bloque
	push {r0-r3}                @; Guardamos registros necesarios para pintar
	mov r0, #0                  @; R0 = Color para liberar (0)
	mov r1, r7                  @; R1 = Índice inicial del bloque
	mov r2, r6                  @; R2 = Número de franjas consecutivas
	cmp r8, #0
	mov r3, #1                  @; R3 = Tipo de segmento (1 = datos)
	bne .LsegmentoDatos
	mov r3, #0                  @; R3 = Tipo de segmento (0 = código)
	add r8, #1                  @; Cambiamos a datos si es el segundo bloque
.LsegmentoDatos:
	bl _gs_pintarFranjas        @; Llamamos a la función para actualizar la representación
	mov r6, #0                  @; Reiniciamos el contador de franjas consecutivas
	pop {r0-r3}                 @; Restauramos registros

@; Final de la iteración de franjas
.LfinIteracion:
	add r2, #1                  @; Avanzar al siguiente índice de franja
	cmp r2, r3                  @; ¿Hemos procesado todas las franjas?
	blt .LrecorrerFranjas       @; Si no, repetir

	@; Finalización de la rutina
	pop {r1-r9, pc}             @; Restaurar registros y regresar
	

.global _gm_rsiTIMER1
@; Rutina de Servicio de Interrupción (RSI) para actualizar la representación
@; de la pila y el estado de los procesos activos.

_gm_rsiTIMER1:
    push {r0-r12,lr}                 @; Guardar registros en la pila

    @; Llamada a la rutina para representar gráficamente la ocupación de las pilas
    bl _gs_representarPilas          @; Actualiza las pilas de todos los procesos activos

    @; ---- Representación del estado ----
    mov r0, #0x6200000               @; Base de memoria para la representación gráfica
    ldr r1, =0x134                   @; Offset para la posición de los colores
    add r0, r1                       @; Calculamos la dirección de inicio

    @; Proceso en estado RUN (en ejecución)
    mov r1, #178                     @; Color azul (R azul) para RUN
    ldr r2, =_gd_pidz                @; Dirección del PID del proceso en RUN
    ldr r2, [r2]                     @; Cargar el valor del zócalo RUN
    and r2, #0xF                     @; Máscara para quedarnos con el zócalo (0-15)
    mov r2, r2, lsl #6               @; Multiplicar por 64 para la posición gráfica
    strh r1, [r0, r2]                @; Pintar la posición del zócalo en RUN con el color azul

    @; ---- Representación de procesos en READY ----
    mov r1, #57                      @; Color blanco (Y blanca) para READY
    ldr r2, =_gd_qReady              @; Dirección de la cola de procesos READY
    ldr r3, =_gd_nReady              @; Dirección del número de procesos en READY
    ldr r3, [r3]                     @; Cargar el número de procesos READY
    mov r4, #0                       @; Contador para recorrer la cola
.LForProcRdy:
    cmp r3, #0                       @; ¿Quedan procesos en READY?
    beq .LfinRdy                     @; Si no quedan, salir del bucle
    ldrb r5, [r2, r4]                @; Cargar el zócalo del proceso en READY
    mov r5, r5, lsl #6               @; Multiplicar por 64 para la posición gráfica
    strh r1, [r0, r5]                @; Pintar el zócalo en READY con el color blanco
    add r4, #1                       @; Incrementar el índice de la cola
    sub r3, #1                       @; Decrementar el número de procesos en READY
    b .LForProcRdy                   @; Repetir para el siguiente proceso
.LfinRdy:

    @; ---- Representación de procesos en DELAY ----
    mov r1, #34                      @; Color blanco (B blanca) para DELAY
    ldr r2, =_gd_qDelay              @; Dirección de la cola de procesos en DELAY
    ldr r3, =_gd_nDelay              @; Dirección del número de procesos en DELAY
    ldr r3, [r3]                     @; Cargar el número de procesos en DELAY
    mov r4, #0                       @; Contador para recorrer la cola
.LForProcDly:
    cmp r3, #0                       @; ¿Quedan procesos en DELAY?
    beq .LfinDly                     @; Si no quedan, salir del bucle
    ldr r5, [r2, r4, lsl #2]         @; Cargar el zócalo del proceso en DELAY
    and r5, #0xFF000000              @; Aplicar máscara para obtener el zócalo
    mov r5, r5, lsr #18              @; Ajustar la posición gráfica
    strh r1, [r0, r5]                @; Pintar el zócalo en DELAY con el color blanco
    add r4, #1                       @; Incrementar el índice de la cola
    sub r3, #1                       @; Decrementar el número de procesos en DELAY
    b .LForProcDly                   @; Repetir para el siguiente proceso
.LfinDly:

    pop {r0-r12,pc}                  @; Restaurar registros y regresar
.end