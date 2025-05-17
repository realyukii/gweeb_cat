#define FAILURE_CODE 1

.extern puts
.extern printf
.extern fread
.extern fopen
.extern perror
.extern memset
.extern stdout

.section .rodata
open_mode:
	.string "r"
usage_str:
	.string "cat <file>"
	usage_str_len = . - usage_str

.section .text
.global main
main:
	pushq	%rbx
	pushq	%r12

	cmpl	$2, %edi
	jne	.print_usage_exit

	movq	8(%rsi), %rdi
	leaq	open_mode(%rip), %rsi
	callq	fopen

	test	%eax, %eax
	je	.failed_to_open

	movq	%rax, %rbx

	subq	$1024, %rsp
	
.read_contents:
	movq	%rsp, %rdi
	movl	$0, %esi
	movl	$1024, %edx
	callq	memset

	/* size_t fread(void *ptr, size_t size, size_t nmemb, FILE* stream); */
	movq	%rsp, %rdi
	movl	$1024, %esi
	movl	$1, %edx
	movq	%rbx, %rcx
	callq	fread

	movl	%eax, %r12d

	/* size_t fwrite(void *ptr, size_t size, size_t nmemb, FILE* stream); */
	movq	%rsp, %rdi
	movl	$1024, %esi
	movl	$1, %edx
	movq	stdout(%rip), %rcx
	callq	fwrite

	cmpl	$0, %r12d
	jne	.read_contents

	addq	$1024, %rsp
	popq	%r12
	popq	%rbx

	xorl	%eax, %eax
	retq

.failed_to_open:
	xorl	%edi, %edi
	callq	perror

	popq	%r12
	popq	%rbx
	
	movl	$FAILURE_CODE, %eax
	retq
.print_usage_exit:
	leaq	usage_str(%rip), %rdi
	callq	puts

	popq	%r12
	popq	%rbx

	movl	$FAILURE_CODE, %eax
	retq

