.equ SYS_EXIT,		60
.equ SYS_WRITE,		1
.equ SYS_READ,		0
.equ SYS_OPEN,		2
.equ SYS_CLOSE,		3

.equ STDOUT_FILENO,	1
.equ O_RDONLY,		0
.equ BYTES_READ,	1024
.equ ARGC_POS,		BYTES_READ
.equ ARGV1_POS,		BYTES_READ+16

.section .rodata
failed_open_str:
	.string "gagal membuka file: "
	failed_open_str_len = . - failed_open_str
new_line:
	.ascii "\n"

.section .text
.global _start
_start:
	/* store argc */
	pushq	%r13
	/* store fd */
	pushq	%r12
	/* store argv index */
	pushq	%rbx

	/* allocate buff */
	subq	$BYTES_READ, %rsp
	/* test argc: to check atleast we have one argument passed */
	movl	ARGC_POS(%rsp), %r13d

	/* decrement argc to fit iterate_argv's evaluation */
	decl	%r13d

	cmpl	$1, %r13d
	jge	.have_args
.use_stdin:
	/* if no argument, put stdin file descriptor instead of fd from opened file */
	xorl	%r12d, %r12d
	jmp	.skip_open
.have_args:
	/* counter for iterating through cmdline args */
	xorl	%ebx, %ebx
.iterate_argv:

	/* open(str_path, flag, mode) */
	movq	ARGV1_POS(%rsp, %rbx, 8), %rdi
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
	cmpl	$0, %r13d
	je	.exit

	movl	$SYS_CLOSE, %eax
	movl	%r12d, %edi
	syscall

	incl	%ebx
	cmpl	%r13d, %ebx
	jl	.iterate_argv

.exit:
	addq	$BYTES_READ, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
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

	/* write(fd, buff_ptr, buff_len) */
	xorl	%edx, %edx
	movq	ARGV1_POS(%rsp, %rbx, 8), %rax
.find_len:
	cmpb	$0, (%rax, %rdx)
	je	.got_len
	incl	%edx
	jmp	.find_len
.got_len:
	movl	$SYS_WRITE, %eax
	movl	$STDOUT_FILENO, %edi
	movq	ARGV1_POS(%rsp, %rbx, 8), %rsi
	syscall

	/* write(fd, buff_ptr, buff_len) */
	movl	$SYS_WRITE, %eax
	movl	$STDOUT_FILENO, %edi
	leaq	new_line(%rip), %rsi
	movl	$1, %edx
	syscall

	jmp .finish_reading
