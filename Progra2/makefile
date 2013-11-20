cli: cli.o
	ld -m elf_i386 -o cli cli.o

cli.o: cli.asm
	nasm -f elf -g -F stabs cli.asm -l cli.lst
