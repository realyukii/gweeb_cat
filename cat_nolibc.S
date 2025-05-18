.equ SYS_EXIT,		60
.equ SYS_WRITE,		1
.equ SYS_READ,		0
.equ SYS_OPEN,		2

.equ STDOUT_FILENO,	1
.equ O_RDONLY,		0
.equ BYTES_READ,	1024

.section .rodata
usage_str:
	.string "cat [files]\n"
	usage_str_len = . - usage_str
failed_open_str:
	.string "gagal membuka file: "
	failed_open_str_len = . - failed_open_str

.section .text
.global _start
_start:
	/* test argc: to check atleast we have one argument passed */
	movl	(%rsp), %r12d
	cmpl	$2, %r12d
	jge	.have_args
.use_stdin:
	/* if no argument, put stdin file descriptor instead of fd from opened file */
	xorl	%r12d, %r12d
	jmp	.skip_open
.have_args:
	/* counter for iterating through cmdline args */
	xorl	%ebx, %ebx
	
	/* open(str_path, flag, mode) */
	movq	16(%rsp), %rdi
	movl	$O_RDONLY, %esi
	xorl	%edx, %edx
	movl	$SYS_OPEN, %eax
	syscall

	/* check if file exists */
	cmpl	$0, %eax
	jl	.failed_open

	/* save open-file descriptor into register instead of stack */
	movl	%eax, %r12d
.skip_open:
	/* allocate buff */
	subq	$BYTES_READ, %rsp
	/* read the file contents */
.read_contents:
	/* read(fd, buff, count) */
	movl	%r12d, %edi
	movq	%rsp, %rsi
	movl	$BYTES_READ, %edx
	movl	$SYS_READ, %eax
	syscall

	/* total bytes readed from read */
	cmpl	$0, %eax
	je	.finish_reading

	/* write(fd, buff_ptr, buff_len) */
	movl	$STDOUT_FILENO, %edi
	movq	%rsp, %rsi
	movl	%eax, %edx
	movl	$SYS_WRITE, %eax
	syscall

	jmp	.read_contents
.finish_reading:

	addq	$BYTES_READ, %rsp
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
