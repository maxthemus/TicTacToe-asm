all: 
	nasm -f elf64 -g -o output.o main.s
	ld -o output output.o

clean: 
	rm *.o
	rm output

