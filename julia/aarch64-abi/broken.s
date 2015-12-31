	.text
	.file	"broken.ll"
	.globl	julia_g_23052
	.align	2
	.type	julia_g_23052,@function
julia_g_23052:                          // @julia_g_23052
	.cfi_startproc
// BB#0:                                // %top
	stp	x29, x30, [sp, #-16]!
	mov	 x29, sp
	sub	sp, sp, #80             // =80
.Ltmp0:
	.cfi_def_cfa w29, 16
.Ltmp1:
	.cfi_offset w30, -8
.Ltmp2:
	.cfi_offset w29, -16
	ldr	x8, [x1, #16]
	str	x8, [sp, #48]
	ldr	 q0, [x1]
	str	q0, [sp, #32]
	ldr	x8, [sp, #48]
	str	x8, [sp, #16]
	ldr	q0, [sp, #32]
	sub	x8, x29, #24            // =24
	str	 q0, [sp]
	blr	x0
	mov	 sp, x29
	ldp	x29, x30, [sp], #16
	ret
.Lfunc_end0:
	.size	julia_g_23052, .Lfunc_end0-julia_g_23052
	.cfi_endproc


	.section	".note.GNU-stack","",@progbits
