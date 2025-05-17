#define FAILURE_CODE 1

.extern puts
.extern printf
.extern fread
.extern fopen

.section .rodata
template_str:
	.string "%s"
open_mode:
	.string "r"
usage_str:
	.string "cat <file>"
	usage_str_len = . - usage_str

.section .text
.global main
main:
	pushq	%rbx
	cmpl	$2, %edi
	jne	.print_usage_exit

	movq	8(%rsi), %rdi
	leaq	open_mode(%rip), %rsi
	callq	fopen

	test	%eax, %eax
	je	.failed_to_open

	movq	%rax, %rbx

	subq	$1024, %rsp
	/* size_t fread(void *ptr, size_t size, size_t nmemb, FILE* stream); */
	movq	%rsp, %rdi
	movl	$1024, %esi
	movl	$1, %edx
	movq	%rbx, %rcx
	callq	fread

	leaq	template_str(%rip), %rdi
	movq	%rsp, %rsi
	xorl	%eax, %eax
	callq	printf

	addq	$1024, %rsp
	popq	%rbx

	xorl	%eax, %eax
	retq

.failed_to_open:
	xorl	%edi, %edi
	callq	perror
	
	movl	$FAILURE_CODE, %eax
	retq
.print_usage_exit:
	leaq	usage_str(%rip), %rdi
	callq	puts

	movl	$FAILURE_CODE, %eax
	retq

