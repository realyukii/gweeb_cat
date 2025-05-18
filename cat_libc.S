#define BUFF_SZ 1024
#define ARGV1_POS 8

.extern puts
.extern fwrite
.extern sprintf
.extern fread
.extern fopen
.extern perror
.extern stdout
.extern stdin

.section .rodata
failed_open_str:
	.string "tidak dapat membuka file %s"
open_mode:
	.string "r"
usage_str:
	.string "cat [files]"
	usage_str_len = . - usage_str

.section .text
.global main
main:
	/* store stdin or file's handle */
	pushq	%rbx
	/* store argv index (counter) */
	pushq	%r12
	/* store argc */
	pushq	%r13
	/* store argv ptr */
	pushq	%r14
	/* store buffer from fread */
	subq	$BUFF_SZ, %rsp

	/* zeroes the argv index */
	xorl	%r12d, %r12d

	movq	%rsi, %r14
	movl	%edi, %r13d
	/* ignore argv[0] and start index from 1 */
	decl	%r13d
	cmpl	$1, %r13d
	jge	.have_argv1

.use_stdin:
	movq	stdin(%rip), %rbx
	jmp	.skip_open

.have_argv1:
	movq	ARGV1_POS(%r14, %r12, 8), %rdi
	leaq	open_mode(%rip), %rsi
	callq	fopen

	test	%eax, %eax
	je	.failed_to_open

	movq	%rax, %rbx

.skip_open:
	
.read_contents:
	/* size_t fread(void *ptr, size_t size, size_t nmemb, FILE* stream); */
	movq	%rsp, %rdi
	movl	$1, %esi
	movl	$1024, %edx
	movq	%rbx, %rcx
	callq	fread

	cmpl	$0, %eax
	je	.finish_reading

	/* size_t fwrite(void *ptr, size_t size, size_t nmemb, FILE* stream); */
	movq	%rsp, %rdi
	movl	$1, %esi
	movl	%eax, %edx
	movq	stdout(%rip), %rcx
	callq	fwrite

	jmp	.read_contents
.finish_reading:
	/* handle scenario when only stdin is used */
	cmpl	$0, %r13d
	je	.exit

	incl	%r12d
	cmpl	%r13d, %r12d
	jl	.have_argv1
.exit:
	addq	$1024, %rsp
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rbx

	xorl	%eax, %eax
	retq

.failed_to_open:
	/* misalignment will cause program to crash inside sprintf */
	subq	$1032, %rsp
	/* sprintf(char *str, const char *string, ...) */
	movq	%rsp, %rdi
	leaq	failed_open_str(%rip), %rsi
	movq	ARGV1_POS(%r14, %r12, 8), %rdx
	callq sprintf

	movq	%rsp, %rdi
	callq	perror

	addq	$1032, %rsp

	jmp	.finish_reading

