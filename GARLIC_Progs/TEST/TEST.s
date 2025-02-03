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
	.ascii	"-- Programa OPEN -  PID (%d) --\012\000"
	.align	2
.LC1:
	.ascii	"r\000"
	.align	2
.LC2:
	.ascii	"file0\000"
	.align	2
.LC3:
	.ascii	"-- Open called --\012\000"
	.align	2
.LC4:
	.ascii	"-- Not found --\012\000"
	.align	2
.LC5:
	.ascii	"-- File opened: %x --\012\000"
	.align	2
.LC6:
	.ascii	"\012=== Contenido del archivo ===\012\000"
	.align	2
.LC7:
	.ascii	"%s\000"
	.align	2
.LC8:
	.ascii	"\012=== Fin del archivo ===\012\000"
	.align	2
.LC9:
	.ascii	"-- Close called --\012\000"
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
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	cmp	r3, #0
	bge	.L2
	mov	r3, #0
	str	r3, [sp, #4]
	b	.L3
.L2:
	ldr	r3, [sp, #4]
	cmp	r3, #3
	ble	.L3
	mov	r3, #3
	str	r3, [sp, #4]
.L3:
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L9
	bl	GARLIC_printf
	ldr	r1, .L9+4
	ldr	r0, .L9+8
	bl	GARLIC_fopen
	str	r0, [sp, #140]
	ldr	r0, .L9+12
	bl	GARLIC_printf
	ldr	r3, [sp, #140]
	cmp	r3, #0
	bne	.L4
	ldr	r0, .L9+16
	bl	GARLIC_printf
	mov	r3, #0
	b	.L8
.L4:
	ldr	r1, [sp, #140]
	ldr	r0, .L9+20
	bl	GARLIC_printf
	ldr	r0, .L9+24
	bl	GARLIC_printf
	b	.L6
.L7:
	add	r2, sp, #8
	ldr	r3, [sp, #136]
	add	r3, r2, r3
	mov	r2, #0
	strb	r2, [r3]
	add	r3, sp, #8
	mov	r1, r3
	ldr	r0, .L9+28
	bl	GARLIC_printf
.L6:
	add	r0, sp, #8
	ldr	r3, [sp, #140]
	mov	r2, #127
	mov	r1, #1
	bl	GARLIC_fread
	str	r0, [sp, #136]
	ldr	r3, [sp, #136]
	cmp	r3, #0
	bgt	.L7
	ldr	r0, .L9+32
	bl	GARLIC_printf
	ldr	r0, [sp, #140]
	bl	GARLIC_fclose
	ldr	r0, .L9+36
	bl	GARLIC_printf
	mov	r3, #0
.L8:
	mov	r0, r3
	add	sp, sp, #148
	@ sp needed
	ldr	pc, [sp], #4
.L10:
	.align	2
.L9:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.word	.LC6
	.word	.LC7
	.word	.LC8
	.word	.LC9
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
