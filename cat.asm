format ELF64 executable

SYS_EXIT=60
SYS_READ=0
SYS_WRITE=1

STDOUT_FILENO=1

_start:
	; write(fd, buff_ptr, buff_len)
	mov	eax, SYS_WRITE
	mov	edi, STDOUT_FILENO
	mov	esi, usage_str
	mov	edx, usage_str_len
	syscall

	; exit(code)
	mov	eax, SYS_EXIT
	xor	edi, edi
	syscall

usage_str:
db "cat <file>", 0xa, 0x0
usage_str_len = $-usage_str
