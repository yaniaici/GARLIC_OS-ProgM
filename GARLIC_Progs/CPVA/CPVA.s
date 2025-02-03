	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"CPVA.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"Simulaci\303\263n de posici\303\263n y velocidad:\012"
	.ascii	"\000"
	.align	2
.LC1:
	.ascii	"Tiempo total: %d segundos\012\000"
	.align	2
.LC2:
	.ascii	"Tiempo: %d segundos\012\000"
	.align	2
.LC3:
	.ascii	"  Velocidad: %d unidades/segundo\012\000"
	.align	2
.LC4:
	.ascii	"  Posici\303\263n: %d unidades\012\000"
	.align	2
.LC5:
	.ascii	"C\303\241lculos completados.\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 40
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #44
	str	r0, [sp, #4]
	mov	r3, #0
	str	r3, [sp, #32]
	mov	r3, #10
	str	r3, [sp, #28]
	ldr	r3, .L5
	str	r3, [sp, #24]
	ldr	r3, [sp, #24]
	ldr	r2, .L5+4
	smull	r1, r2, r3, r2
	asr	r2, r2, #6
	asr	r3, r3, #31
	sub	r3, r2, r3
	str	r3, [sp, #20]
	ldr	r0, .L5+8
	bl	GARLIC_printf
	ldr	r1, [sp, #20]
	ldr	r0, .L5+12
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [sp, #36]
	b	.L2
.L3:
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #36]
	mul	r2, r3, r2
	ldr	r3, [sp, #32]
	add	r3, r2, r3
	str	r3, [sp, #16]
	ldr	r3, [sp, #32]
	ldr	r2, [sp, #36]
	mul	r2, r3, r2
	ldr	r3, [sp, #28]
	ldr	r1, [sp, #36]
	mul	r3, r1, r3
	ldr	r1, [sp, #36]
	mul	r3, r1, r3
	lsr	r1, r3, #31
	add	r3, r1, r3
	asr	r3, r3, #1
	add	r3, r2, r3
	str	r3, [sp, #12]
	ldr	r1, [sp, #36]
	ldr	r0, .L5+16
	bl	GARLIC_printf
	ldr	r1, [sp, #16]
	ldr	r0, .L5+20
	bl	GARLIC_printf
	ldr	r1, [sp, #12]
	ldr	r0, .L5+24
	bl	GARLIC_printf
	ldr	r3, [sp, #36]
	add	r3, r3, #1
	str	r3, [sp, #36]
.L2:
	ldr	r2, [sp, #36]
	ldr	r3, [sp, #20]
	cmp	r2, r3
	ble	.L3
	ldr	r0, .L5+28
	bl	GARLIC_printf
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #44
	@ sp needed
	ldr	pc, [sp], #4
.L6:
	.align	2
.L5:
	.word	5000
	.word	274877907
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
