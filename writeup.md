## Dokumentasi yang digunakan selama proses pembuatan program

- `write(2)`
- [linux system call table for x86_64](https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl)
- [SystemV ABI - calling convention](https://gist.github.com/ammarfaizi2/d7090dd8d667834b51e341732100153e)

## fasm notes
- `usage_str` is part of [label](https://flatassembler.net/docs.php?article=manual#1.2.3):
> There are different ways to define labels. The simplest is to follow the name of label by the colon

- `usage_str_len` is part of [constant](https://flatassembler.net/docs.php?article=manual#1.2.3):
> Constant can be redefined many times, but in this case it is accessible only after it was defined, and is always equal to the value from last definition before the place where it's used.
