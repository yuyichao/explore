	.text
	.syntax unified
	.eabi_attribute	67, "2.09"	@ Tag_conformance
	.cpu	cortex-a8
	.eabi_attribute	6, 10	@ Tag_CPU_arch
	.eabi_attribute	7, 65	@ Tag_CPU_arch_profile
	.eabi_attribute	8, 1	@ Tag_ARM_ISA_use
	.eabi_attribute	9, 2	@ Tag_THUMB_ISA_use
	.fpu	neon
	.eabi_attribute	15, 1	@ Tag_ABI_PCS_RW_data
	.eabi_attribute	16, 1	@ Tag_ABI_PCS_RO_data
	.eabi_attribute	17, 2	@ Tag_ABI_PCS_GOT_use
	.eabi_attribute	20, 1	@ Tag_ABI_FP_denormal
	.eabi_attribute	21, 1	@ Tag_ABI_FP_exceptions
	.eabi_attribute	23, 3	@ Tag_ABI_FP_number_model
	.eabi_attribute	34, 1	@ Tag_CPU_unaligned_access
	.eabi_attribute	24, 1	@ Tag_ABI_align_needed
	.eabi_attribute	25, 1	@ Tag_ABI_align_preserved
	.eabi_attribute	28, 1	@ Tag_ABI_VFP_args
	.eabi_attribute	38, 1	@ Tag_ABI_FP_16bit_format
	.eabi_attribute	18, 4	@ Tag_ABI_PCS_wchar_t
	.eabi_attribute	26, 2	@ Tag_ABI_enum_size
	.eabi_attribute	14, 0	@ Tag_ABI_PCS_R9_use
	.eabi_attribute	68, 1	@ Tag_Virtualization_use
	.file	"atomics.c"
	.globl	f
	.align	2
	.type	f,%function
f:                                      @ @f
	.fnstart
@ BB#0:
	.save	{r4, r5, r6, r10, r11, lr}
	push	{r4, r5, r6, r10, r11, lr}
	.setfp	r11, sp, #16
	add	r11, sp, #16
	ldr	r0, .LCPI0_0
	mov	r6, #0
	ldr	r1, .LCPI0_1
.LPC0_0:
	add	r0, pc, r0
	ldr	r2, .LCPI0_2
	ldr	r4, [r1, r0]
	ldr	r5, [r2, r0]
	str	r6, [r4]
	bl	g(PLT)
	bl	g(PLT)
	dmb	ish
	str	r6, [r4]
	dmb	ish
	bl	g(PLT)
	dmb	ish
	str	r6, [r4]
	bl	g(PLT)
	str	r6, [r4]
	bl	g(PLT)
	mov	r0, #1
	str	r0, [r5]
	bl	g(PLT)
	bl	g(PLT)
	ldr	r0, [r4]
	dmb	ish
	str	r0, [r5]
	bl	g(PLT)
	ldr	r0, [r4]
	dmb	ish
	str	r0, [r5]
	bl	g(PLT)
	ldr	r0, [r4]
	str	r0, [r5]
	pop	{r4, r5, r6, r10, r11, lr}
	b	g(PLT)
	.align	2
@ BB#1:
.LCPI0_0:
	.long	_GLOBAL_OFFSET_TABLE_-(.LPC0_0+8)
.LCPI0_1:
	.long	a(GOT)
.LCPI0_2:
	.long	b(GOT)
.Lfunc_end0:
	.size	f, .Lfunc_end0-f
	.cantunwind
	.fnend

	.type	a,%object               @ @a
	.bss
	.globl	a
	.align	2
a:
	.long	0                       @ 0x0
	.size	a, 4

	.type	b,%object               @ @b
	.globl	b
	.align	2
b:
	.long	0                       @ 0x0
	.size	b, 4


	.ident	"clang version 3.7.1 (tags/RELEASE_371/final)"
	.section	".note.GNU-stack","",%progbits
