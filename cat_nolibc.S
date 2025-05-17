.equ SYS_EXIT,		60
.equ SYS_WRITE,		1
.equ SYS_READ,		0

.equ STDOUT_FILENO,	1

.section .rodata
usage_str:
	.string "cat <file>\n"
	usage_str_len = . - usage_str

.section .text
.global _start
_start:
	/* test print the first command-line argument */
	movq	16(%rsp), %rsi
	xorl	%edx, %edx
.find_len:
	cmpb	$0, (%rsi, %rdx)
	je	.got_len
	incl	%edx
	jmp .find_len
.got_len:
	movl	$STDOUT_FILENO, %edi
	movl	$SYS_WRITE, %eax
	syscall
	/* write(fd, buff_ptr, buff_len) */
	movl	$SYS_WRITE, %eax
	movl	$STDOUT_FILENO, %edi
	leaq	usage_str(%rip), %rsi
	movl	$usage_str_len, %edx
	syscall

	/* exit(code) */
	movl	$SYS_EXIT, %eax
	xorl	%edi, %edi
	syscall
