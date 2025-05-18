#define FAILURE_CODE 1

.extern puts
.extern fwrite
.extern fread
.extern fopen
.extern perror
.extern stdout
.extern stdin

.section .rodata
open_mode:
	.string "r"
usage_str:
	.string "cat [files]"
	usage_str_len = . - usage_str

.section .text
.global main
main:
	pushq	%rbx

	cmpl	$2, %edi
	je	.have_args1

.use_stdin:
	movq	stdin(%rip), %rbx
	jmp	.skip_open

.have_args1:
	movq	8(%rsi), %rdi
	leaq	open_mode(%rip), %rsi
	callq	fopen

	test	%eax, %eax
	je	.failed_to_open

	movq	%rax, %rbx

.skip_open:

	subq	$1024, %rsp
	
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

	addq	$1024, %rsp
	popq	%rbx

	xorl	%eax, %eax
	retq

.failed_to_open:
	xorl	%edi, %edi
	callq	perror

	popq	%rbx
	
	movl	$FAILURE_CODE, %eax
	retq

