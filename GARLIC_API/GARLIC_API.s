@;==============================================================================
@;
@;	"GARLIC_API.s":	implementaci�n de funciones del API del sistema operativo
@;					GARLIC 1.0 (descripci�n de funciones en "GARLIC_API.h")
@;
@;==============================================================================

.text
	.arm
	.align 2

	.global GARLIC_pid
GARLIC_pid:
	push {r4, lr}
	mov r4, #0				@; vector base de rutinas API de GARLIC
	mov lr, pc				@; guardar direcci�n de retorno
	ldr pc, [r4]			@; llamada indirecta a rutina 0x00
	pop {r4, pc}

	.global GARLIC_random
GARLIC_random:
	push {r4, lr}
	mov r4, #0
	mov lr, pc
	ldr pc, [r4, #4]		@; llamada indirecta a rutina 0x01
	pop {r4, pc}

	.global GARLIC_divmod
GARLIC_divmod:
	push {r4, lr}
	mov r4, #0
	mov lr, pc
	ldr pc, [r4, #8]		@; llamada indirecta a rutina 0x02
	pop {r4, pc}

	.global GARLIC_divmodL
GARLIC_divmodL:
	push {r4, lr}
	mov r4, #0
	mov lr, pc
	ldr pc, [r4, #12]		@; llamada indirecta a rutina 0x03
	pop {r4, pc}

	.global GARLIC_printf
GARLIC_printf:
	push {r4, lr}
	mov r4, #0
	mov lr, pc
	ldr pc, [r4, #16]		@; llamada indirecta a rutina 0x04
	pop {r4, pc}

	.global GARLIC_fopen
GARLIC_fopen:
	push {r4, lr}
	mov r4, #0
	mov lr, pc
	ldr pc, [r4, #20]		@; llamada indirecta a rutina 0x05
	pop {r4, pc}

	.global GARLIC_fclose
GARLIC_fclose:
	push {r4, lr}
	mov r4, #0
	mov lr, pc
	ldr pc, [r4, #24]		@; llamada indirecta a rutina 0x06
	pop {r4, pc}

	.global GARLIC_fread
GARLIC_fread:
	push {r4, lr}
	mov r4, #0
	mov lr, pc
	ldr pc, [r4, #28]		@; llamada indirecta a rutina 0x07
	pop {r4, pc}
	
    @; Nueva funci�n GARLIC_setChar para definir caracteres personalizados
	.global GARLIC_setChar
GARLIC_setChar:
	push {r4, lr}
	mov r4, #0
	mov lr, pc
	ldr pc, [r4, #32]		@; llamada indirecta a rutina 0x08
	pop {r4, pc}
.end
