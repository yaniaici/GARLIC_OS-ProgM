	.arch armv5te
	.fpu softvfp
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"LABE.c"
	.text
	.global	chars
	.bss
	.align	2
	.type	chars, %object
	.size	chars, 112
chars:
	.space	112
	.global	lab
	.align	2
	.type	lab, %object
	.size	lab, 512
lab:
	.space	512
	.global	nchars
	.align	2
	.type	nchars, %object
	.size	nchars, 4
nchars:
	.space	4
	.global	labx
	.align	2
	.type	labx, %object
	.size	labx, 4
labx:
	.space	4
	.global	laby
	.align	2
	.type	laby, %object
	.size	laby, 4
laby:
	.space	4
	.global	points
	.align	2
	.type	points, %object
	.size	points, 4
points:
	.space	4
	.text
	.align	2
	.global	init_lab
	.syntax unified
	.arm
	.type	init_lab, %function
init_lab:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #36
	mov	r3, #0
	str	r3, [sp, #24]
	b	.L2
.L3:
	ldr	r2, .L18
	ldr	r3, [sp, #24]
	add	r3, r2, r3
	mov	r2, #98
	strb	r2, [r3]
	ldr	r3, .L18+4
	ldr	r3, [r3]
	sub	r3, r3, #1
	ldr	r2, .L18
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #24]
	add	r3, r2, r3
	mov	r2, #98
	strb	r2, [r3]
	ldr	r0, [sp, #24]
	mov	r3, #0
	mov	r2, #95
	mov	r1, #4
	bl	GARLIC_printchar
	ldr	r0, [sp, #24]
	ldr	r3, .L18+4
	ldr	r3, [r3]
	add	r3, r3, #3
	mov	r1, r3
	mov	r3, #0
	mov	r2, #95
	bl	GARLIC_printchar
	ldr	r3, [sp, #24]
	add	r3, r3, #1
	str	r3, [sp, #24]
.L2:
	ldr	r3, .L18+8
	ldr	r3, [r3]
	ldr	r2, [sp, #24]
	cmp	r2, r3
	bcc	.L3
	mov	r3, #1
	str	r3, [sp, #28]
	b	.L4
.L5:
	ldr	r2, .L18
	ldr	r3, [sp, #28]
	mov	r1, #98
	strb	r1, [r2, r3, lsl #5]
	ldr	r3, .L18+8
	ldr	r3, [r3]
	sub	r3, r3, #1
	ldr	r1, .L18
	ldr	r2, [sp, #28]
	lsl	r2, r2, #5
	add	r2, r1, r2
	add	r3, r2, r3
	mov	r2, #98
	strb	r2, [r3]
	ldr	r3, [sp, #28]
	add	r3, r3, #4
	mov	r1, r3
	mov	r3, #0
	mov	r2, #95
	mov	r0, #0
	bl	GARLIC_printchar
	ldr	r3, .L18+8
	ldr	r3, [r3]
	sub	r3, r3, #1
	mov	r0, r3
	ldr	r3, [sp, #28]
	add	r3, r3, #4
	mov	r1, r3
	mov	r3, #0
	mov	r2, #95
	bl	GARLIC_printchar
	ldr	r3, [sp, #28]
	add	r3, r3, #1
	str	r3, [sp, #28]
.L4:
	ldr	r3, .L18+4
	ldr	r3, [r3]
	sub	r3, r3, #1
	ldr	r2, [sp, #28]
	cmp	r2, r3
	bcc	.L5
	mov	r3, #1
	str	r3, [sp, #28]
	b	.L6
.L9:
	mov	r3, #1
	str	r3, [sp, #24]
	b	.L7
.L8:
	ldr	r2, .L18
	ldr	r3, [sp, #28]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #24]
	add	r3, r2, r3
	mov	r2, #102
	strb	r2, [r3]
	ldr	r3, [sp, #24]
	add	r3, r3, #1
	str	r3, [sp, #24]
.L7:
	ldr	r3, .L18+8
	ldr	r3, [r3]
	sub	r3, r3, #1
	ldr	r2, [sp, #24]
	cmp	r2, r3
	bcc	.L8
	ldr	r3, [sp, #28]
	add	r3, r3, #1
	str	r3, [sp, #28]
.L6:
	ldr	r3, .L18+4
	ldr	r3, [r3]
	sub	r3, r3, #1
	ldr	r2, [sp, #28]
	cmp	r2, r3
	bcc	.L9
	ldr	r3, .L18+8
	ldr	r2, [r3]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r2, r3, #2
	add	r3, r3, r2
	sub	r3, r3, #50
	ldr	r2, .L18+4
	ldr	r2, [r2]
	sub	r2, r2, #2
	mul	r3, r2, r3
	ldr	r2, .L18+12
	umull	r1, r3, r2, r3
	lsr	r3, r3, #5
	str	r3, [sp, #20]
	ldr	r2, .L18+16
	ldr	r3, [sp, #20]
	str	r3, [r2]
	mov	r3, #0
	str	r3, [sp, #28]
	b	.L11
.L12:
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	ldr	r3, .L18+8
	ldr	r1, [r3]
	add	r3, sp, #4
	add	r2, sp, #8
	bl	GARLIC_divmod
	ldr	r3, [sp, #4]
	str	r3, [sp, #16]
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	ldr	r3, .L18+4
	ldr	r1, [r3]
	add	r3, sp, #4
	add	r2, sp, #8
	bl	GARLIC_divmod
	ldr	r3, [sp, #4]
	str	r3, [sp, #12]
	ldr	r2, .L18
	ldr	r3, [sp, #12]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #16]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #98
	beq	.L11
	ldr	r0, [sp, #16]
	ldr	r3, [sp, #12]
	add	r3, r3, #4
	mov	r1, r3
	mov	r3, #0
	mov	r2, #95
	bl	GARLIC_printchar
	ldr	r2, .L18
	ldr	r3, [sp, #12]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #16]
	add	r3, r2, r3
	mov	r2, #98
	strb	r2, [r3]
	ldr	r3, [sp, #28]
	add	r3, r3, #1
	str	r3, [sp, #28]
.L11:
	ldr	r2, [sp, #28]
	ldr	r3, [sp, #20]
	cmp	r2, r3
	bcc	.L12
	mov	r3, #0
	str	r3, [sp, #28]
	b	.L14
.L15:
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	ldr	r3, .L18+8
	ldr	r1, [r3]
	add	r3, sp, #4
	add	r2, sp, #8
	bl	GARLIC_divmod
	ldr	r3, [sp, #4]
	str	r3, [sp, #16]
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	ldr	r3, .L18+4
	ldr	r1, [r3]
	add	r3, sp, #4
	add	r2, sp, #8
	bl	GARLIC_divmod
	ldr	r3, [sp, #4]
	str	r3, [sp, #12]
	ldr	r2, .L18
	ldr	r3, [sp, #12]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #16]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #102
	bne	.L14
	ldr	r0, [sp, #16]
	ldr	r3, [sp, #12]
	add	r3, r3, #4
	mov	r1, r3
	mov	r3, #0
	mov	r2, #14
	bl	GARLIC_printchar
	ldr	r2, .L18
	ldr	r3, [sp, #12]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #16]
	add	r3, r2, r3
	mov	r2, #112
	strb	r2, [r3]
	ldr	r3, [sp, #28]
	add	r3, r3, #1
	str	r3, [sp, #28]
.L14:
	ldr	r2, [sp, #28]
	ldr	r3, [sp, #20]
	cmp	r2, r3
	bcc	.L15
	mov	r3, #0
	str	r3, [sp, #28]
	b	.L16
.L17:
	ldr	r2, [sp, #28]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	lsl	r3, r3, #1
	mov	ip, r3
	ldr	r1, .L18+20
	ldr	r2, [sp, #28]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	ldrb	r1, [r3]	@ zero_extendqisi2
	ldr	r0, .L18+20
	ldr	r2, [sp, #28]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r0, r3
	add	r3, r3, #12
	ldr	r3, [r3]
	mov	r2, r1
	mov	r1, #22
	mov	r0, ip
	bl	GARLIC_printchar
	ldr	r2, [sp, #28]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	lsl	r3, r3, #1
	add	r3, r3, #1
	mov	r0, r3
	ldr	r1, .L18+20
	ldr	r2, [sp, #28]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #12
	ldr	r3, [r3]
	mov	r2, #26
	mov	r1, #22
	bl	GARLIC_printchar
	ldr	r2, [sp, #28]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	lsl	r3, r3, #1
	add	r3, r3, #3
	mov	r0, r3
	ldr	r1, .L18+20
	ldr	r2, [sp, #28]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #12
	ldr	r3, [r3]
	mov	r2, #16
	mov	r1, #22
	bl	GARLIC_printchar
	ldr	r3, [sp, #28]
	add	r3, r3, #1
	str	r3, [sp, #28]
.L16:
	ldr	r3, .L18+24
	ldr	r3, [r3]
	ldr	r2, [sp, #28]
	cmp	r2, r3
	bcc	.L17
	nop
	nop
	add	sp, sp, #36
	@ sp needed
	ldr	pc, [sp], #4
.L19:
	.align	2
.L18:
	.word	lab
	.word	laby
	.word	labx
	.word	1374389535
	.word	points
	.word	chars
	.word	nchars
	.size	init_lab, .-init_lab
	.align	2
	.global	init_chars
	.syntax unified
	.arm
	.type	init_chars, %function
init_chars:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #28
	mov	r3, #0
	str	r3, [sp, #20]
	b	.L22
.L25:
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	ldr	r3, .L26
	ldr	r1, [r3]
	add	r3, sp, #4
	add	r2, sp, #8
	bl	GARLIC_divmod
	ldr	r3, [sp, #4]
	str	r3, [sp, #16]
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	ldr	r3, .L26+4
	ldr	r1, [r3]
	add	r3, sp, #4
	add	r2, sp, #8
	bl	GARLIC_divmod
	ldr	r3, [sp, #4]
	str	r3, [sp, #12]
	ldr	r2, .L26+8
	ldr	r3, [sp, #12]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #16]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #102
	bne	.L22
	ldr	r1, .L26+12
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	ldrb	r1, [r3]	@ zero_extendqisi2
	ldr	r2, .L26+8
	ldr	r3, [sp, #12]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #16]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
	ldr	r1, .L26+12
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #4
	ldr	r2, [sp, #16]
	str	r2, [r3]
	ldr	r1, .L26+12
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #8
	ldr	r2, [sp, #12]
	str	r2, [r3]
	ldr	r0, [sp, #16]
	ldr	r3, [sp, #12]
	add	r3, r3, #4
	mov	lr, r3
	ldr	r1, .L26+12
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	ldrb	r1, [r3]	@ zero_extendqisi2
	ldr	ip, .L26+12
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, ip, r3
	add	r3, r3, #12
	ldr	r3, [r3]
	mov	r2, r1
	mov	r1, lr
	bl	GARLIC_printchar
	ldr	r3, .L26
	ldr	r3, [r3]
	lsr	r3, r3, #1
	ldr	r2, [sp, #16]
	cmp	r2, r3
	bcs	.L23
	ldr	r1, .L26+12
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #20
	mov	r2, #1
	str	r2, [r3]
	b	.L24
.L23:
	ldr	r1, .L26+12
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #20
	mvn	r2, #0
	str	r2, [r3]
.L24:
	ldr	r1, .L26+12
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #24
	mov	r2, #0
	str	r2, [r3]
	ldr	r3, [sp, #20]
	add	r3, r3, #1
	str	r3, [sp, #20]
.L22:
	ldr	r3, .L26+16
	ldr	r3, [r3]
	ldr	r2, [sp, #20]
	cmp	r2, r3
	bcc	.L25
	nop
	nop
	add	sp, sp, #28
	@ sp needed
	ldr	pc, [sp], #4
.L27:
	.align	2
.L26:
	.word	labx
	.word	laby
	.word	lab
	.word	chars
	.word	nchars
	.size	init_chars, .-init_chars
	.align	2
	.global	init_puppets
	.syntax unified
	.arm
	.type	init_puppets, %function
init_puppets:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	sp, sp, #8
	mov	r3, #0
	str	r3, [sp, #4]
	b	.L29
.L30:
	ldr	r3, [sp, #4]
	and	r3, r3, #255
	add	r3, r3, #33
	and	r0, r3, #255
	ldr	r1, .L31
	ldr	r2, [sp, #4]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	mov	r2, r0
	strb	r2, [r3]
	ldr	r1, [sp, #4]
	ldr	r0, .L31
	ldr	r2, [sp, #4]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r0, r3
	add	r3, r3, #12
	str	r1, [r3]
	ldr	r1, .L31
	ldr	r2, [sp, #4]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #16
	mov	r2, #0
	str	r2, [r3]
	ldr	r3, [sp, #4]
	add	r3, r3, #1
	str	r3, [sp, #4]
.L29:
	ldr	r2, [sp, #4]
	ldr	r3, .L31+4
	ldr	r3, [r3]
	cmp	r2, r3
	bcc	.L30
	nop
	nop
	add	sp, sp, #8
	@ sp needed
	bx	lr
.L32:
	.align	2
.L31:
	.word	chars
	.word	nchars
	.size	init_puppets, .-init_puppets
	.align	2
	.global	update_score
	.syntax unified
	.arm
	.type	update_score, %function
update_score:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #28
	str	r0, [sp, #4]
	ldr	r1, .L37
	ldr	r2, [sp, #4]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #16
	ldr	r3, [r3]
	str	r3, [sp, #20]
	ldr	r3, [sp, #20]
	cmp	r3, #9
	bls	.L34
	add	r3, sp, #12
	add	r2, sp, #16
	mov	r1, #10
	ldr	r0, [sp, #20]
	bl	GARLIC_divmod
	ldr	r2, [sp, #4]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	lsl	r3, r3, #1
	add	r3, r3, #2
	mov	ip, r3
	ldr	r3, [sp, #16]
	and	r3, r3, #255
	add	r3, r3, #16
	and	r1, r3, #255
	ldr	r0, .L37
	ldr	r2, [sp, #4]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r0, r3
	add	r3, r3, #12
	ldr	r3, [r3]
	mov	r2, r1
	mov	r1, #22
	mov	r0, ip
	bl	GARLIC_printchar
	ldr	r2, [sp, #4]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	lsl	r3, r3, #1
	add	r3, r3, #3
	mov	ip, r3
	ldr	r3, [sp, #12]
	and	r3, r3, #255
	add	r3, r3, #16
	and	r1, r3, #255
	ldr	r0, .L37
	ldr	r2, [sp, #4]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r0, r3
	add	r3, r3, #12
	ldr	r3, [r3]
	mov	r2, r1
	mov	r1, #22
	mov	r0, ip
	bl	GARLIC_printchar
	b	.L36
.L34:
	ldr	r2, [sp, #4]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	lsl	r3, r3, #1
	add	r3, r3, #3
	mov	ip, r3
	ldr	r3, [sp, #20]
	and	r3, r3, #255
	add	r3, r3, #16
	and	r1, r3, #255
	ldr	r0, .L37
	ldr	r2, [sp, #4]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r0, r3
	add	r3, r3, #12
	ldr	r3, [r3]
	mov	r2, r1
	mov	r1, #22
	mov	r0, ip
	bl	GARLIC_printchar
.L36:
	nop
	add	sp, sp, #28
	@ sp needed
	ldr	pc, [sp], #4
.L38:
	.align	2
.L37:
	.word	chars
	.size	update_score, .-update_score
	.align	2
	.global	mov_chars
	.syntax unified
	.arm
	.type	mov_chars, %function
mov_chars:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #28
	mov	r3, #0
	str	r3, [sp, #16]
	mov	r3, #0
	str	r3, [sp, #20]
	b	.L40
.L53:
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #4
	ldr	r1, [r3]
	ldr	r0, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r0, r3
	add	r3, r3, #20
	ldr	r3, [r3]
	add	r3, r1, r3
	str	r3, [sp, #12]
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #8
	ldr	r1, [r3]
	ldr	r0, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r0, r3
	add	r3, r3, #24
	ldr	r3, [r3]
	add	r3, r1, r3
	str	r3, [sp, #8]
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	mov	r3, sp
	add	r2, sp, #4
	mov	r1, #4
	bl	GARLIC_divmod
	ldr	r3, [sp]
	cmp	r3, #3
	beq	.L41
	ldr	r2, .L55+4
	ldr	r3, [sp, #8]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #12]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #98
	bne	.L42
.L41:
	mov	r3, #0
	str	r3, [sp, #16]
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	mov	r3, sp
	add	r2, sp, #4
	mov	r1, #4
	bl	GARLIC_divmod
.L49:
	ldr	r2, [sp]
	ldr	r3, .L55+8
	cmp	r2, #3
	bhi	.L43
	ldr	pc, [r3, r2, lsl #2]
.Lrtx45:
	nop
	.section	.rodata
	.align	2
.L45:
	.word	.L48
	.word	.L47
	.word	.L46
	.word	.L44
	.text
	.p2align 2
.L48:
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #20
	mov	r2, #1
	str	r2, [r3]
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #24
	mov	r2, #0
	str	r2, [r3]
	b	.L43
.L47:
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #20
	mov	r2, #0
	str	r2, [r3]
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #24
	mov	r2, #1
	str	r2, [r3]
	b	.L43
.L46:
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #20
	mvn	r2, #0
	str	r2, [r3]
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #24
	mov	r2, #0
	str	r2, [r3]
	b	.L43
.L44:
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #20
	mov	r2, #0
	str	r2, [r3]
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #24
	mvn	r2, #0
	str	r2, [r3]
	nop
.L43:
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #4
	ldr	r1, [r3]
	ldr	r0, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r0, r3
	add	r3, r3, #20
	ldr	r3, [r3]
	add	r3, r1, r3
	str	r3, [sp, #12]
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #8
	ldr	r1, [r3]
	ldr	r0, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r0, r3
	add	r3, r3, #24
	ldr	r3, [r3]
	add	r3, r1, r3
	str	r3, [sp, #8]
	ldr	r3, [sp]
	add	r3, r3, #1
	and	r3, r3, #3
	str	r3, [sp]
	ldr	r3, [sp, #16]
	add	r3, r3, #1
	str	r3, [sp, #16]
	ldr	r3, [sp, #16]
	cmp	r3, #3
	bhi	.L42
	ldr	r2, .L55+4
	ldr	r3, [sp, #8]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #12]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #98
	beq	.L49
.L42:
	ldr	r2, .L55+4
	ldr	r3, [sp, #8]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #12]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #112
	beq	.L50
	ldr	r2, .L55+4
	ldr	r3, [sp, #8]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #12]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #102
	bne	.L51
.L50:
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #4
	ldr	r3, [r3]
	mov	r0, r3
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #8
	ldr	r3, [r3]
	add	r3, r3, #4
	mov	r1, r3
	mov	r3, #0
	mov	r2, #0
	bl	GARLIC_printchar
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #8
	ldr	r1, [r3]
	ldr	r0, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r0, r3
	add	r3, r3, #4
	ldr	r3, [r3]
	ldr	r0, .L55+4
	lsl	r2, r1, #5
	add	r2, r0, r2
	add	r3, r2, r3
	mov	r2, #102
	strb	r2, [r3]
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #4
	ldr	r2, [sp, #12]
	str	r2, [r3]
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #8
	ldr	r2, [sp, #8]
	str	r2, [r3]
	ldr	r2, .L55+4
	ldr	r3, [sp, #8]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #12]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #112
	bne	.L52
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #16
	ldr	r3, [r3]
	add	r1, r3, #1
	ldr	r0, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r0, r3
	add	r3, r3, #16
	str	r1, [r3]
	ldr	r0, [sp, #20]
	bl	update_score
	ldr	r3, .L55+12
	ldr	r3, [r3]
	sub	r3, r3, #1
	ldr	r2, .L55+12
	str	r3, [r2]
.L52:
	ldr	r2, .L55+4
	ldr	r3, [sp, #8]
	lsl	r3, r3, #5
	add	r2, r2, r3
	ldr	r3, [sp, #12]
	add	r3, r2, r3
	mov	r2, #98
	strb	r2, [r3]
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #4
	ldr	r3, [r3]
	mov	ip, r3
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	add	r3, r3, #8
	ldr	r3, [r3]
	add	r3, r3, #4
	mov	lr, r3
	ldr	r1, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r1, r3
	ldrb	r1, [r3]	@ zero_extendqisi2
	ldr	r0, .L55
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r0, r3
	add	r3, r3, #12
	ldr	r3, [r3]
	mov	r2, r1
	mov	r1, lr
	mov	r0, ip
	bl	GARLIC_printchar
.L51:
	ldr	r3, [sp, #20]
	add	r3, r3, #1
	str	r3, [sp, #20]
.L40:
	ldr	r3, .L55+16
	ldr	r3, [r3]
	ldr	r2, [sp, #20]
	cmp	r2, r3
	bcc	.L53
	nop
	nop
	add	sp, sp, #28
	@ sp needed
	ldr	pc, [sp], #4
.L56:
	.align	2
.L55:
	.word	chars
	.word	lab
	.word	.L45
	.word	points
	.word	nchars
	.size	mov_chars, .-mov_chars
	.section	.rodata
	.align	2
.LC1:
	.ascii	"-- Programa LABE  -  PID %2(%d) %0--\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #12
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	cmp	r3, #0
	bge	.L58
	mov	r3, #0
	str	r3, [sp, #4]
.L58:
	ldr	r3, [sp, #4]
	cmp	r3, #3
	ble	.L59
	mov	r3, #3
	str	r3, [sp, #4]
.L59:
	bl	GARLIC_clear
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L62
	bl	GARLIC_printf
	ldr	r3, [sp, #4]
	add	r3, r3, #1
	mov	r2, r3
	ldr	r3, .L62+4
	str	r2, [r3]
	ldr	r3, .L62+4
	ldr	r3, [r3]
	lsl	r3, r3, #3
	ldr	r2, .L62+8
	str	r3, [r2]
	ldr	r3, .L62+12
	mov	r2, #16
	str	r2, [r3]
	bl	init_puppets
	bl	init_lab
	bl	init_chars
.L60:
	bl	mov_chars
	mov	r0, #0
	bl	GARLIC_delay
	ldr	r3, .L62+16
	ldr	r3, [r3]
	cmp	r3, #0
	bne	.L60
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #12
	@ sp needed
	ldr	pc, [sp], #4
.L63:
	.align	2
.L62:
	.word	.LC1
	.word	nchars
	.word	labx
	.word	laby
	.word	points
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 65) 14.2.0"
