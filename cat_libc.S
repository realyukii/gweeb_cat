#define FAILURE_CODE 1

.extern puts
.extern printf
.extern fread
.extern fopen

.section .rodata
open_mode:
	.string "r"
usage_str:
	.string "cat <file>"
	usage_str_len = . - usage_str

.section .text
.global main
main:
	cmpl	$2, %edi
	jne	.print_usage_exit

	movq	8(%rsi), %rdi
	leaq	open_mode(%rip), %rsi
	callq	fopen

	test	%eax, %eax
	je	.failed_to_open

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

