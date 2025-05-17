.extern puts
.extern printf
.extern fread
.extern fopen

.section .rodata
template_str:
	.string "argv[1]: %s\n"
usage_str:
	.string "cat <file>"
	usage_str_len = . - usage_str

.section .text
.global main
main:
	cmpl	$2, %edi
	jne	.print_usage_exit

	leaq	template_str(%rip), %rdi
	movq	8(%rsi), %rsi
	xorl	%eax, %eax
	callq	printf

	xorl	%eax, %eax
	retq
.print_usage_exit:
	leaq	usage_str(%rip), %rdi
	callq	puts

	movl	$1, %eax
	retq

