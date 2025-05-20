#define BUFF_SZ 1024
#define CONCAT_STR_SZ 1024
#define ARGV1_POS 8

#define CONCAT_STR_POS 0
#define BUFF_POS CONCAT_STR_SZ

.extern puts
.extern fwrite
.extern sprintf
.extern fread
.extern fopen
.extern fclose
.extern perror
.extern stdout
.extern stdin

.section .rodata
failed_open_str:
	.string "tidak dapat membuka file %s"
open_mode:
	.string "r"

.section .text
.global main
main:
	/* store stdin or file's handle */
	pushq	%rbx
	/* store argv index (counter) */
	pushq	%rbp
	/* store argc */
	pushq	%r13
	/* store argv ptr */
	pushq	%r14
	/* re-align to 16-byte */
	/* store buffer from fread */
	/* store concate string */
	subq	$(8 + BUFF_SZ + CONCAT_STR_SZ), %rsp

	/* zeroes the argv index */
	xorl	%ebp, %ebp

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
	movq	ARGV1_POS(%r14, %rbp, 8), %rdi
	leaq	open_mode(%rip), %rsi
	callq	fopen

	movq	%rax, %rbx

	testl	%eax, %eax
	je	.failed_to_open

.skip_open:
	
.read_contents:
	/* size_t fread(void *ptr, size_t size, size_t nmemb, FILE* stream); */
	leaq	BUFF_POS(%rsp), %rdi
	movl	$1, %esi
	movl	$BUFF_SZ, %edx
	movq	%rbx, %rcx
	callq	fread

	testl	%eax, %eax
	je	.finish_reading

	/* size_t fwrite(void *ptr, size_t size, size_t nmemb, FILE* stream); */
	leaq	BUFF_POS(%rsp), %rdi
	movl	$1, %esi
	movl	%eax, %edx
	movq	stdout(%rip), %rcx
	callq	fwrite

	jmp	.read_contents
.finish_reading:
	/* handle scenario when only stdin is used */
	testl	%r13d, %r13d
	je	.exit

	testl	%ebx, %ebx
	je		.exit

	movq	%rbx, %rdi
	callq	fclose
	incl	%ebp
	cmpl	%r13d, %ebp
	jl	.have_argv1
.exit:
	addq	$(8 + BUFF_SZ + CONCAT_STR_SZ), %rsp
	popq	%r14
	popq	%r13
	popq	%rbp
	popq	%rbx

	xorl	%eax, %eax
	retq

.failed_to_open:
	/* caution: misalignment will cause program to crash inside sprintf
	* sprintf(char *str, const char *string, ...) */
	leaq	CONCAT_STR_POS(%rsp), %rdi
	leaq	failed_open_str(%rip), %rsi
	movq	ARGV1_POS(%r14, %rbp, 8), %rdx
	callq	sprintf

	leaq	CONCAT_STR_POS(%rsp), %rdi
	callq	perror

	jmp	.finish_reading

