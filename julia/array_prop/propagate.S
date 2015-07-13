	.text
Filename: array_prop.jl
Source line: 0
	pushq	%rbp
	movq	%rsp, %rbp
Source line: 28
	movsd	16(%rdi), %xmm1
	movsd	8(%rdi), %xmm2
	movq	(%rdi), %rax
Source line: 28
	stmxcsr	-12(%rbp)
	movl	-12(%rbp), %ecx
Source line: 29
	movl	%ecx, %edx
	orl	$32832, %edx            # imm = 0x8040
	movl	%edx, -8(%rbp)
	ldmxcsr	-8(%rbp)
Source line: 30
	movq	(%rsi), %rdx
	movabsq	$4607182418800017408, %rdi # imm = 0x3FF0000000000000
	movq	%rdi, (%rdx)
Source line: 31
	movq	(%rsi), %rdx
	movq	$0, 8(%rdx)
Source line: 32
	testq	%rax, %rax
	jle	L136
Source line: 33
	movq	(%rsi), %rdx
	movsd	(%rdx), %xmm3
	nop
L80:	mulsd	%xmm0, %xmm3
Source line: 34
	movsd	8(%rdx), %xmm4
Source line: 35
	movaps	%xmm1, %xmm5
	mulsd	%xmm3, %xmm5
	movaps	%xmm2, %xmm6
	mulsd	%xmm4, %xmm6
	addsd	%xmm5, %xmm6
Source line: 36
	mulsd	%xmm1, %xmm4
	mulsd	%xmm2, %xmm3
	subsd	%xmm3, %xmm4
Source line: 37
	movsd	%xmm6, 8(%rdx)
Source line: 38
	movsd	%xmm4, (%rdx)
	decq	%rax
Source line: 32
	movaps	%xmm4, %xmm3
Source line: 38
	jne	L80
Source line: 40
L136:	movl	%ecx, -4(%rbp)
	ldmxcsr	-4(%rbp)
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
	movabsq	$140728649809936, %rax  # imm = 0x7FFDF12E8010
	popq	%rbp
	retq
