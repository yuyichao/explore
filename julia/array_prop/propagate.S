	.text
Filename: array_prop.jl
Source line: 0
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$40, %rsp
	movsd	%xmm0, -64(%rbp)
	movq	%rdx, -56(%rbp)
Source line: 10
	movq	8(%rdi), %r15
	movsd	(%rdi), %xmm1
	movq	16(%rdi), %r8
	movq	(%rdx), %r12
	movq	24(%rdx), %rbx
	xorl	%r14d, %r14d
Source line: 10
	testq	%r8, %r8
	cmovnsq	%r8, %r14
	testq	%r14, %r14
	je	L141
Source line: 10
	movq	(%rsi), %rax
	movq	24(%rsi), %rcx
	xorl	%edx, %edx
	testq	%r8, %r8
	cmovnsq	%r8, %rdx
	leaq	8(%r12), %rsi
Source line: 10
	leaq	(,%rbx,8), %rdi
	addq	$8, %rax
	shlq	$3, %rcx
	nopw	%cs:(%rax,%rax)
Source line: 11
L112:	movsd	-8(%rax), %xmm0
	movsd	%xmm0, -8(%rsi)
Source line: 12
	movsd	(%rax), %xmm0
	movsd	%xmm0, (%rsi)
	addq	%rdi, %rsi
	addq	%rcx, %rax
	decq	%rdx
	jne	L112
L141:	movq	%r8, -72(%rbp)
	movabsq	$140737307336096, %r13  # imm = 0x7FFFF535DDA0
	movaps	%xmm1, %xmm0
Source line: 14
	movsd	%xmm0, -48(%rbp)
	callq	*%r13
	movsd	-48(%rbp), %xmm1
	ucomisd	%xmm1, %xmm1
	jp	L187
	ucomisd	%xmm0, %xmm0
	jp	L376
L187:	movsd	%xmm0, -80(%rbp)
Source line: 15
	addq	$6144, %r13             # imm = 0x1800
	movaps	%xmm1, %xmm0
	callq	*%r13
	movsd	-48(%rbp), %xmm1
	ucomisd	%xmm1, %xmm1
	jp	L226
	ucomisd	%xmm0, %xmm0
	jp	L406
Source line: 16
L226:	testq	%r15, %r15
	movsd	-64(%rbp), %xmm5
	movq	-72(%rbp), %rcx
	movsd	-80(%rbp), %xmm6
	jle	L357
	testq	%r14, %r14
	je	L357
	xorl	%eax, %eax
	testq	%rcx, %rcx
	cmovnsq	%rcx, %rax
	addq	$8, %r12
	shlq	$3, %rbx
	movl	$1, %ecx
L272:	movq	%r12, %rdx
	movq	%rax, %rsi
	nopw	%cs:(%rax,%rax)
Source line: 18
L288:	movsd	-8(%rdx), %xmm1
	movsd	(%rdx), %xmm2
Source line: 19
	mulsd	%xmm5, %xmm2
Source line: 20
	movaps	%xmm0, %xmm3
	mulsd	%xmm1, %xmm3
	movaps	%xmm6, %xmm4
	mulsd	%xmm2, %xmm4
	addsd	%xmm3, %xmm4
	movsd	%xmm4, (%rdx)
Source line: 21
	mulsd	%xmm0, %xmm2
	mulsd	%xmm6, %xmm1
	subsd	%xmm1, %xmm2
	movsd	%xmm2, -8(%rdx)
	addq	%rbx, %rdx
	decq	%rsi
	jne	L288
	cmpq	%r15, %rcx
Source line: 16
	leaq	1(%rcx), %rcx
	jne	L272
Source line: 24
L357:	movq	-56(%rbp), %rax
	addq	$40, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
Source line: 14
L376:	movabsq	$jl_domain_exception, %rax
	movq	(%rax), %rdi
	movabsq	$jl_throw_with_superfluous_argument, %rax
	movl	$14, %esi
	callq	*%rax
Source line: 15
L406:	movabsq	$jl_domain_exception, %rax
	movq	(%rax), %rdi
	movabsq	$jl_throw_with_superfluous_argument, %rax
	movl	$15, %esi
	callq	*%rax
	nopw	%cs:(%rax,%rax)
	pushq	%rbp
	movq	%rsp, %rbp
	movq	(%rsi), %rdi
	movq	8(%rsi), %rax
	movq	16(%rsi), %rdx
	movq	24(%rsi), %rcx
	movsd	(%rcx), %xmm0
	movabsq	$propagate, %rcx
	movq	%rax, %rsi
	callq	*%rcx
	popq	%rbp
	retq
