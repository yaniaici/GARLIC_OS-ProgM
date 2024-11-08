	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"TEST.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"/Datos/testfile.txt\000"
	.align	2
.LC1:
	.ascii	"r\000"
	.align	2
.LC2:
	.ascii	"Error: No se pudo abrir el archivo %s para lectura."
	.ascii	"\012\000"
	.align	2
.LC3:
	.ascii	"Archivo %s abierto correctamente para lectura.\012\000"
	.align	2
.LC4:
	.ascii	"Se leyeron %u bytes del archivo.\012\000"
	.align	2
.LC5:
	.ascii	"Error: No se pudo cerrar el archivo %s.\012\000"
	.align	2
.LC6:
	.ascii	"Archivo %s cerrado correctamente.\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 144
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #148
	ldr	r3, .L8
	str	r3, [sp, #140]
	ldr	r1, .L8+4
	ldr	r0, [sp, #140]
	bl	GARLIC_fopen
	str	r0, [sp, #136]
	ldr	r3, [sp, #136]
	cmp	r3, #0
	bne	.L2
	ldr	r1, [sp, #140]
	ldr	r0, .L8+8
	bl	GARLIC_printf
	mov	r3, #1
	b	.L7
.L2:
	ldr	r1, [sp, #140]
	ldr	r0, .L8+12
	bl	GARLIC_printf
	b	.L4
.L5:
	ldr	r1, [sp, #132]
	ldr	r0, .L8+16
	bl	GARLIC_printf
.L4:
	add	r0, sp, #4
	ldr	r3, [sp, #136]
	mov	r2, #128
	mov	r1, #1
	bl	GARLIC_fread
	mov	r3, r0
	str	r3, [sp, #132]
	ldr	r3, [sp, #132]
	cmp	r3, #0
	bne	.L5
	ldr	r0, [sp, #136]
	bl	GARLIC_fclose
	mov	r3, r0
	cmp	r3, #0
	beq	.L6
	ldr	r1, [sp, #140]
	ldr	r0, .L8+20
	bl	GARLIC_printf
	mov	r3, #1
	b	.L7
.L6:
	ldr	r1, [sp, #140]
	ldr	r0, .L8+24
	bl	GARLIC_printf
	mov	r3, #0
.L7:
	mov	r0, r3
	add	sp, sp, #148
	@ sp needed
	ldr	pc, [sp], #4
.L9:
	.align	2
.L8:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.word	.LC6
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
