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
	subq	$56, %rsp
	movsd	%xmm0, -64(%rbp)
	movq	%rdx, -56(%rbp)
Source line: 10
	movq	8(%rdi), %r15
	movsd	(%rdi), %xmm2
	movq	16(%rdi), %rax
	movq	%rax, -80(%rbp)
	movq	(%rdx), %r12
	movq	24(%rdx), %r13
	movq	32(%rdx), %rbx
	xorl	%ecx, %ecx
Source line: 10
	testq	%rax, %rax
	cmovnsq	%rax, %rcx
	movq	%rcx, -88(%rbp)
	testq	%rcx, %rcx
	je	L161
Source line: 10
	movq	(%rsi), %rax
	movq	24(%rsi), %rcx
	xorl	%edx, %edx
	movq	-80(%rbp), %rsi
	testq	%rsi, %rsi
	cmovnsq	%rsi, %rdx
	leaq	16(%r12), %rsi
Source line: 10
	movq	%r13, %rdi
	shlq	$4, %rdi
	addq	$16, %rax
	shlq	$4, %rcx
	nop
Source line: 11
L112:	movsd	-16(%rax), %xmm0
	movsd	-8(%rax), %xmm1
	movsd	%xmm1, -8(%rsi)
	movsd	%xmm0, -16(%rsi)
Source line: 12
	movsd	(%rax), %xmm0
	movsd	8(%rax), %xmm1
	movsd	%xmm1, 8(%rsi)
	movsd	%xmm0, (%rsi)
	addq	%rdi, %rsi
	addq	%rcx, %rax
	decq	%rdx
	jne	L112
L161:	movabsq	$140737307336096, %r14  # imm = 0x7FFFF535DDA0
	movaps	%xmm2, %xmm0
Source line: 14
	movsd	%xmm0, -48(%rbp)
	callq	*%r14
	movsd	-48(%rbp), %xmm1
	ucomisd	%xmm1, %xmm1
	jp	L203
	ucomisd	%xmm0, %xmm0
	jp	L586
L203:	movsd	%xmm0, -72(%rbp)
Source line: 15
	addq	$6144, %r14             # imm = 0x1800
	movaps	%xmm1, %xmm0
	callq	*%r14
	movsd	-48(%rbp), %xmm1
	ucomisd	%xmm1, %xmm1
	jp	L242
	ucomisd	%xmm0, %xmm0
	jp	L616
Source line: 16
L242:	incq	%r15
	cmpq	$2, %r15
	movsd	-64(%rbp), %xmm11
	movsd	-72(%rbp), %xmm12
	jl	L567
	cmpq	$0, -88(%rbp)
	je	L567
Source line: 14
	movd	%xmm12, %rax
	testq	%rax, %rax
	xorps	%xmm8, %xmm8
	jns	L307
	movabsq	$140737352761360, %rax  # imm = 0x7FFFF7EB0010
	movsd	(%rax), %xmm8
L307:	addq	$16, %r12
Source line: 16
	imulq	%r13, %rbx
	shlq	$4, %rbx
	shlq	$4, %r13
	xorl	%eax, %eax
	movq	-80(%rbp), %rcx
	testq	%rcx, %rcx
	cmovnsq	%rcx, %rax
	movl	$2, %ecx
	nopw	%cs:(%rax,%rax)
L352:	movq	%rax, %rdx
	movq	%r12, %rsi
	nopw	%cs:(%rax,%rax)
Source line: 18
L368:	movsd	-16(%rsi), %xmm2
	movsd	-8(%rsi), %xmm9
	movsd	(%rsi), %xmm3
Source line: 19
	mulsd	%xmm11, %xmm3
	movsd	8(%rsi), %xmm4
	mulsd	%xmm11, %xmm4
Source line: 20
	movaps	%xmm0, %xmm10
	mulsd	%xmm2, %xmm10
	movaps	%xmm0, %xmm7
	mulsd	%xmm9, %xmm7
	movaps	%xmm8, %xmm1
	mulsd	%xmm3, %xmm1
	movaps	%xmm12, %xmm5
	mulsd	%xmm4, %xmm5
	subsd	%xmm5, %xmm1
	movaps	%xmm8, %xmm5
	mulsd	%xmm4, %xmm5
	movaps	%xmm12, %xmm6
	mulsd	%xmm3, %xmm6
	addsd	%xmm5, %xmm6
	addsd	%xmm10, %xmm1
	addsd	%xmm7, %xmm6
	movsd	%xmm6, 8(%rbx,%rsi)
	movsd	%xmm1, (%rbx,%rsi)
Source line: 21
	mulsd	%xmm0, %xmm3
	mulsd	%xmm0, %xmm4
	movaps	%xmm8, %xmm1
	mulsd	%xmm2, %xmm1
	movaps	%xmm12, %xmm5
	mulsd	%xmm9, %xmm5
	subsd	%xmm5, %xmm1
	mulsd	%xmm8, %xmm9
	mulsd	%xmm12, %xmm2
	addsd	%xmm9, %xmm2
	addsd	%xmm3, %xmm1
	addsd	%xmm4, %xmm2
	movsd	%xmm2, -8(%rbx,%rsi)
	movsd	%xmm1, -16(%rbx,%rsi)
	addq	%r13, %rsi
	decq	%rdx
	jne	L368
	addq	%rbx, %r12
	cmpq	%r15, %rcx
Source line: 16
	leaq	1(%rcx), %rcx
	jne	L352
Source line: 24
L567:	movq	-56(%rbp), %rax
	addq	$56, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
Source line: 14
L586:	movabsq	$jl_domain_exception, %rax
	movq	(%rax), %rdi
	movabsq	$jl_throw_with_superfluous_argument, %rax
	movl	$14, %esi
	callq	*%rax
Source line: 15
L616:	movabsq	$jl_domain_exception, %rax
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
