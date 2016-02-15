	.text
	.file	"atomics.c"
	.globl	f
	.align	16, 0x90
	.type	f,@function
f:                                      # @f
	.cfi_startproc
# BB#0:
	pushq	%r14
.Ltmp0:
	.cfi_def_cfa_offset 16
	pushq	%rbx
.Ltmp1:
	.cfi_def_cfa_offset 24
	pushq	%rax
.Ltmp2:
	.cfi_def_cfa_offset 32
.Ltmp3:
	.cfi_offset %rbx, -24
.Ltmp4:
	.cfi_offset %r14, -16
	movq	a@GOTPCREL(%rip), %rbx
	movl	$0, (%rbx)
	callq	g@PLT
	callq	g@PLT
	xorl	%eax, %eax
	xchgl	%eax, (%rbx)
	callq	g@PLT
	movl	$0, (%rbx)
	callq	g@PLT
	movl	$0, (%rbx)
	callq	g@PLT
	movq	b@GOTPCREL(%rip), %r14
	movl	$1, (%r14)
	callq	g@PLT
	callq	g@PLT
	movl	(%rbx), %eax
	movl	%eax, (%r14)
	callq	g@PLT
	movl	(%rbx), %eax
	movl	%eax, (%r14)
	callq	g@PLT
	movl	(%rbx), %eax
	movl	%eax, (%r14)
	addq	$8, %rsp
	popq	%rbx
	popq	%r14
	jmp	g@PLT                   # TAILCALL
.Lfunc_end0:
	.size	f, .Lfunc_end0-f
	.cfi_endproc

	.type	a,@object               # @a
	.bss
	.globl	a
	.align	4
a:
	.long	0                       # 0x0
	.size	a, 4

	.type	b,@object               # @b
	.globl	b
	.align	4
b:
	.long	0                       # 0x0
	.size	b, 4


	.ident	"clang version 3.7.1 (tags/RELEASE_371/final)"
	.section	".note.GNU-stack","",@progbits
