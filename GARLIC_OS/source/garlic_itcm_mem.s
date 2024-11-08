@;==============================================================================
@;
@;	"garlic_itcm_mem.s":	c�digo de rutinas de soporte a la carga de
@;							programas en memoria (versi�n 1.0)
@;
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2

	.global _gm_reubicar
	@; Rutina para interpretar los 'relocs' de un fichero ELF y ajustar las
	@; direcciones de memoria correspondientes a las referencias de tipo
	@; R_ARM_ABS32, restando la direcci�n de inicio de segmento y sumando
	@; la direcci�n de destino en la memoria;
	@; Par�metros:
	@; R0: direcci�n inicial del buffer de fichero (char *fileBuf)
	@; R1: direcci�n de inicio de segmento (unsigned int pAddr)
	@; R2: direcci�n de destino en la memoria (unsigned int *dest)
	@; Resultado:
	@; Cambio de las direcciones de memoria que se tienen que ajustar

_gm_reubicar:
    push {r4-r12, lr}              @; Guardar registros que se usar�n
    
    @; Obtener valores del encabezado ELF
    ldr r4, [r0, #32]              @; r4 = e_shoff (desplazamiento de la tabla de secciones)
    ldrh r5, [r0, #46]             @; r5 = tama�o de cada entrada de la secci�n
    ldrh r6, [r0, #48]             @; r6 = e_shnum (n�mero de secciones)

    mov r7, #0                     @; Inicializar el �ndice de secciones
    
.LoopSecciones:
    mul r8, r7, r5                 @; r8 = �ndice * tama�o de entrada de la secci�n
    add r8, r8, r4                 @; r8 = direcci�n de la secci�n actual
    add r7, r7, #1                 @; Incrementar el �ndice de secciones
    cmp r7, r6                     @; Comparar con el n�mero total de secciones
    bgt .Fin                       @; Si hemos procesado todas las secciones, salir

    @; Cargar el tipo de la secci�n (sh_type) para verificar si es una secci�n de reubicaci�n (SHT_REL)
    add r9, r8, #4                 @; r9 = r8 + 4 (posici�n del sh_type)
    ldr r9, [r0, r9]               @; r9 = sh_type de la secci�n
    cmp r9, #9                     @; Comparar si es SHT_REL (secci�n de reubicaci�n)
    bne .LoopSecciones             @; Si no es, pasar a la siguiente secci�n
    
    @; Obtener el tama�o de la secci�n de reubicaci�n y su desplazamiento en el fichero
    add r10, r8, #20               @; r10 = r8 + 20 (posici�n del sh_size)
    ldr r10, [r0, r10]             @; r10 = sh_size (tama�o de la secci�n)
    lsr r10, r10, #3               @; Dividir entre 8 para obtener el n�mero de entradas de reubicaci�n
    add r11, r8, #16               @; r11 = r8 + 16 (posici�n del sh_offset)
    ldr r11, [r0, r11]             @; r11 = sh_offset (desplazamiento de la secci�n)

    mov r9, #0                     @; Inicializar el �ndice de reubicaciones

.LoopReubicaciones:
    @; Calcular la direcci�n de cada entrada de reubicaci�n en funci�n del �ndice
    add r8, r11, r9, lsl #3        @; r8 = sh_offset + �ndice * 8
    add r9, r9, #1                 @; Incrementar el �ndice de reubicaciones
    cmp r9, r10                    @; Comparar con el n�mero total de reubicaciones
    bgt .LoopSecciones             @; Si hemos procesado todas, pasar a la siguiente secci�n
    
    @; Cargar el tipo de reubicaci�n (r_info) y verificar si es del tipo R_ARM_ABS32
    add r12, r8, #4                @; r12 = r8 + 4 (posici�n de r_info)
    ldrb r12, [r0, r12]            @; r12 = r_info (tipo de reubicaci�n)
    cmp r12, #2                    @; Comparar si es R_ARM_ABS32
    bne .LoopReubicaciones         @; Si no es, pasar a la siguiente reubicaci�n
    
    @; Cargar el offset de la reubicaci�n (r_offset), que es la direcci�n a ajustar
    ldr r12, [r0, r8]              @; r12 = r_offset
    
    @; Ajustar la direcci�n de memoria reubicada
    sub r12, r12, r1               @; r12 = r_offset - direcci�n de inicio de segmento
    add r12, r12, r2               @; r12 = r12 + direcci�n de destino
    
    @; Ajustar el contenido de la direcci�n de memoria referenciada por la reubicaci�n
    ldr r8, [r12]                  @; Cargar el valor en la direcci�n calculada
    sub r8, r8, r1                 @; Ajustar direcci�n restando la base del segmento
    add r8, r8, r2                 @; Sumar la direcci�n de destino
    str r8, [r12]                  @; Guardar el valor ajustado en la direcci�n calculada
    
    b .LoopReubicaciones           @; Repetir para la siguiente reubicaci�n
    
.Fin:
    pop {r4-r12, pc}               @; Restaurar registros y regresar
.end
