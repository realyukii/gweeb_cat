format ELF64 executable

SYS_EXIT=60
SYS_READ=1

_start:
	mov	eax, SYS_EXIT
	xor	edi, edi
	syscall
