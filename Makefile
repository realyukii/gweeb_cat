all: build/cat_libc build/cat_nolibc

build/cat_libc: cat_libc.S
	gcc $^ -o $@

build/cat_nolibc: build/cat_nolibc.o
	ld $^ -o $@

build/cat_nolibc.o: cat_nolibc.S
	as $^ -o $@