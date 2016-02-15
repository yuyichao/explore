	.text
	.file	"atomics.c"
	.globl	f
	.align	16, 0x90
	.type	f,@function
f:                                      # @f
# BB#0:
	pushl	%ebx
	pushl	%edi
	pushl	%esi
	calll	.L0$pb
.L0$pb:
	popl	%ebx
.Ltmp0:
	addl	$_GLOBAL_OFFSET_TABLE_+(.Ltmp0-.L0$pb), %ebx
	movl	a@GOT(%ebx), %esi
	movl	$0, (%esi)
	calll	g@PLT
	calll	g@PLT
	xorl	%eax, %eax
	xchgl	%eax, (%esi)
	calll	g@PLT
	movl	$0, (%esi)
	calll	g@PLT
	movl	$0, (%esi)
	calll	g@PLT
	movl	b@GOT(%ebx), %edi
	movl	$1, (%edi)
	calll	g@PLT
	calll	g@PLT
	movl	(%esi), %eax
	movl	%eax, (%edi)
	calll	g@PLT
	movl	(%esi), %eax
	movl	%eax, (%edi)
	calll	g@PLT
	movl	(%esi), %eax
	movl	%eax, (%edi)
	calll	g@PLT
	popl	%esi
	popl	%edi
	popl	%ebx
	retl
.Lfunc_end0:
	.size	f, .Lfunc_end0-f

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
