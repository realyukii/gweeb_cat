.equ SYS_EXIT,		60
.equ SYS_WRITE,		1
.equ SYS_READ,		0
.equ SYS_OPEN,		2
.equ SYS_CLOSE,		3

.equ STDOUT_FILENO,	1
.equ O_RDONLY,		0
.equ BYTES_READ,	1024 + 8
.equ SAVED_RGSTR,	3 * 8
.equ ARGC_POS,		BYTES_READ + SAVED_RGSTR
.equ ARGV1_POS,		ARGC_POS + 16

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
	pushq	%rbp
	/* store fd */
	pushq	%r12
	/* store argv index */
	pushq	%rbx

	/* allocate buff + re-alignment */
	subq	$(BYTES_READ), %rsp
	/* test argc: to check atleast we have one argument passed */
	movl	ARGC_POS(%rsp), %ebp

	/* ignore argv[0] and start index from 1 */
	decl	%ebp

	cmpl	$1, %ebp
	jge		.have_args
.use_stdin:
	/* if no argument, put stdin file descriptor instead of fd from opened file */
	xorl	%r12d, %r12d
	jmp		.skip_open
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
	testl	%eax, %eax
	jl		.failed_open

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
	testl	%eax, %eax
	je	.finish_reading

	/* write(fd, buff_ptr, buff_len) */
	movl	$STDOUT_FILENO, %edi
	movq	%rsp, %rsi
	movl	%eax, %edx
	movl	$SYS_WRITE, %eax
	syscall

	jmp	.read_contents
.finish_reading:
	/* immediately exit if using stdin */
	testl	%ebp, %ebp
	je		.exit

	movl	$SYS_CLOSE, %eax
	movl	%r12d, %edi
	syscall
.skip_close:
	incl	%ebx
	cmpl	%ebp, %ebx
	jl	.iterate_argv

.exit:
	addq	$BYTES_READ, %rsp
	popq	%rbx
	popq	%r12
	popq	%rbp
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
	je		.got_len
	incl	%edx
	jmp		.find_len
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

	jmp .skip_close
