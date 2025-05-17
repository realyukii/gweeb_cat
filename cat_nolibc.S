.equ SYS_EXIT,		60
.equ SYS_WRITE,		1
.equ SYS_READ,		0
.equ SYS_OPEN,		2

.equ STDOUT_FILENO,	1
.equ O_RDONLY,		0

.section .rodata
usage_str:
	.string "cat <file>\n"
	usage_str_len = . - usage_str
failed_open_str:
	.string "gagal membuka file.\n"
	failed_open_str_len = . - failed_open_str

.section .text
.global _start
_start:
	movq	(%rsp), %rax
	cmpl	$2, %eax
	je	.have_arg1
.print_usage_exit:
	/* write(fd, buff_ptr, buff_len) */
	movl	$SYS_WRITE, %eax
	movl	$STDOUT_FILENO, %edi
	leaq	usage_str(%rip), %rsi
	movl	$usage_str_len, %edx
	syscall

	/* exit(code) */
	movl	$SYS_EXIT, %eax
	movl	$1, %edi
	syscall
.have_arg1:
	/* open(str_path, flag, mode) */
	movq	16(%rsp), %rdi
	movl	$O_RDONLY, %esi
	xorl	%edx, %edx
	movl	$SYS_OPEN, %eax
	syscall

	/* check if file exists */
	cmpl	$0, %eax
	jl	.failed_open

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

.failed_open:
	/* write(fd, buff_ptr, buff_len) */
	movl	$SYS_WRITE, %eax
	movl	$STDOUT_FILENO, %edi
	leaq	failed_open_str(%rip), %rsi
	movl	$failed_open_str_len, %edx
	syscall
	
	/* exit(code) */
	movl	$SYS_EXIT, %eax
	movl	$1, %edi
	syscall
