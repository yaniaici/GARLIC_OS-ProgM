@;==============================================================================
@;
@;	"garlic_itcm_mem.s":	código de rutinas de soporte a la carga de
@;							programas en memoria (versión 1.0)
@;
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2

	.global _gm_reubicar
	@; Rutina para interpretar los 'relocs' de un fichero ELF y ajustar las
	@; direcciones de memoria correspondientes a las referencias de tipo
	@; R_ARM_ABS32, restando la dirección de inicio de segmento y sumando
	@; la dirección de destino en la memoria;
	@; Parámetros:
	@; R0: dirección inicial del buffer de fichero (char *fileBuf)
	@; R1: dirección de inicio de segmento (unsigned int pAddr)
	@; R2: dirección de destino en la memoria (unsigned int *dest)
	@; Resultado:
	@; Cambio de las direcciones de memoria que se tienen que ajustar

_gm_reubicar:
    push {r4-r12, lr}              @; Guardar registros que se usarán
    
    @; Obtener valores del encabezado ELF
    ldr r4, [r0, #32]              @; r4 = e_shoff (desplazamiento de la tabla de secciones)
    ldrh r5, [r0, #46]             @; r5 = tamaño de cada entrada de la sección
    ldrh r6, [r0, #48]             @; r6 = e_shnum (número de secciones)

    mov r7, #0                     @; Inicializar el índice de secciones
    
.LoopSecciones:
    mul r8, r7, r5                 @; r8 = índice * tamaño de entrada de la sección
    add r8, r8, r4                 @; r8 = dirección de la sección actual
    add r7, r7, #1                 @; Incrementar el índice de secciones
    cmp r7, r6                     @; Comparar con el número total de secciones
    bgt .Fin                       @; Si hemos procesado todas las secciones, salir

    @; Cargar el tipo de la sección (sh_type) para verificar si es una sección de reubicación (SHT_REL)
    add r9, r8, #4                 @; r9 = r8 + 4 (posición del sh_type)
    ldr r9, [r0, r9]               @; r9 = sh_type de la sección
    cmp r9, #9                     @; Comparar si es SHT_REL (sección de reubicación)
    bne .LoopSecciones             @; Si no es, pasar a la siguiente sección
    
    @; Obtener el tamaño de la sección de reubicación y su desplazamiento en el fichero
    add r10, r8, #20               @; r10 = r8 + 20 (posición del sh_size)
    ldr r10, [r0, r10]             @; r10 = sh_size (tamaño de la sección)
    lsr r10, r10, #3               @; Dividir entre 8 para obtener el número de entradas de reubicación
    add r11, r8, #16               @; r11 = r8 + 16 (posición del sh_offset)
    ldr r11, [r0, r11]             @; r11 = sh_offset (desplazamiento de la sección)

    mov r9, #0                     @; Inicializar el índice de reubicaciones

.LoopReubicaciones:
    @; Calcular la dirección de cada entrada de reubicación en función del índice
    add r8, r11, r9, lsl #3        @; r8 = sh_offset + índice * 8
    add r9, r9, #1                 @; Incrementar el índice de reubicaciones
    cmp r9, r10                    @; Comparar con el número total de reubicaciones
    bgt .LoopSecciones             @; Si hemos procesado todas, pasar a la siguiente sección
    
    @; Cargar el tipo de reubicación (r_info) y verificar si es del tipo R_ARM_ABS32
    add r12, r8, #4                @; r12 = r8 + 4 (posición de r_info)
    ldrb r12, [r0, r12]            @; r12 = r_info (tipo de reubicación)
    cmp r12, #2                    @; Comparar si es R_ARM_ABS32
    bne .LoopReubicaciones         @; Si no es, pasar a la siguiente reubicación
    
    @; Cargar el offset de la reubicación (r_offset), que es la dirección a ajustar
    ldr r12, [r0, r8]              @; r12 = r_offset
    
    @; Ajustar la dirección de memoria reubicada
    sub r12, r12, r1               @; r12 = r_offset - dirección de inicio de segmento
    add r12, r12, r2               @; r12 = r12 + dirección de destino
    
    @; Ajustar el contenido de la dirección de memoria referenciada por la reubicación
    ldr r8, [r12]                  @; Cargar el valor en la dirección calculada
    sub r8, r8, r1                 @; Ajustar dirección restando la base del segmento
    add r8, r8, r2                 @; Sumar la dirección de destino
    str r8, [r12]                  @; Guardar el valor ajustado en la dirección calculada
    
    b .LoopReubicaciones           @; Repetir para la siguiente reubicación
    
.Fin:
    pop {r4-r12, pc}               @; Restaurar registros y regresar
.end
