	.text
	.file	"atomics.c"
	.globl	f
	.align	2
	.type	f,@function
f:                                      // @f
// BB#0:
	stp	x20, x19, [sp, #-32]!
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16            // =16
	adrp	x19, :got:a
	ldr	x19, [x19, :got_lo12:a]
	str	 wzr, [x19]
	bl	g
	bl	g
	stlr	wzr, [x19]
	bl	g
	stlr	wzr, [x19]
	bl	g
	str	 wzr, [x19]
	bl	g
	adrp	x20, :got:b
	ldr	x20, [x20, :got_lo12:b]
	orr	w8, wzr, #0x1
	str	 w8, [x20]
	bl	g
	bl	g
	ldar	w8, [x19]
	str	 w8, [x20]
	bl	g
	ldar	w8, [x19]
	str	 w8, [x20]
	bl	g
	ldr	 w8, [x19]
	str	 w8, [x20]
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	b	g
.Lfunc_end0:
	.size	f, .Lfunc_end0-f

	.type	a,@object               // @a
	.bss
	.globl	a
	.align	2
a:
	.word	0                       // 0x0
	.size	a, 4

	.type	b,@object               // @b
	.globl	b
	.align	2
b:
	.word	0                       // 0x0
	.size	b, 4


	.ident	"clang version 3.7.1 (tags/RELEASE_371/final)"
	.section	".note.GNU-stack","",@progbits
