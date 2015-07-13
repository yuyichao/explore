	.text
Filename: array_prop.jl
Source line: 0
	pushq	%rbp
	movq	%rsp, %rbp
Source line: 10
	movsd	16(%rdi), %xmm1
	movsd	8(%rdi), %xmm2
	movq	(%rdi), %rax
Source line: 10
	movq	(%rsi), %rcx
	movabsq	$4607182418800017408, %rdx # imm = 0x3FF0000000000000
	movq	%rdx, (%rcx)
Source line: 11
	movq	(%rsi), %rcx
	movq	$0, 8(%rcx)
Source line: 12
	testq	%rax, %rax
	jle	L120
Source line: 13
	movq	(%rsi), %rcx
	movsd	(%rcx), %xmm3
	nopl	(%rax,%rax)
L64:	movsd	8(%rcx), %xmm4
Source line: 14
	mulsd	%xmm0, %xmm4
Source line: 15
	movaps	%xmm1, %xmm5
	mulsd	%xmm3, %xmm5
	movaps	%xmm2, %xmm6
	mulsd	%xmm4, %xmm6
	addsd	%xmm5, %xmm6
Source line: 16
	mulsd	%xmm1, %xmm4
	mulsd	%xmm2, %xmm3
	subsd	%xmm3, %xmm4
Source line: 17
	movsd	%xmm6, 8(%rcx)
Source line: 18
	movsd	%xmm4, (%rcx)
	decq	%rax
Source line: 12
	movaps	%xmm4, %xmm3
Source line: 18
	jne	L64
L120:	movabsq	$140728649809936, %rax  # imm = 0x7FFDF12E8010
	popq	%rbp
	retq
	nopw	%cs:(%rax,%rax)
	pushq	%rbp
	movq	%rsp, %rbp
	movq	(%rsi), %rdi
	movq	8(%rsi), %rax
	movq	16(%rsi), %rcx
	movsd	(%rcx), %xmm0
	movabsq	$propagate, %rcx
	movq	%rax, %rsi
	callq	*%rcx
	popq	%rbp
	retq
