# Makefile
all: diskimage bootloader stdlib kernel

clean:
	# -- Cleaning output files --
	@rm out/bootloader out/kernel out/*.img out/*.o


# Recipes
diskimage:
	# -- Initial system.img --
	@if [ ! -d "out" ]; then mkdir out; fi
	dd if=/dev/zero of=out/system.img bs=512 count=2880 status=noxfer

bootloader:
	# -- Bootloader insertion --
	nasm src/asm/bootloader.asm -o out/bootloader;
	dd if=out/bootloader of=out/system.img bs=512 count=1 conv=notrunc status=noxfer

kernel: pit
	# -- Source Compilation --
	bcc -ansi -c -o out/kernel.o src/c/kernel.c
	nasm -f as86 src/asm/kernel.asm -o out/kernel_asm.o
	nasm -f as86 src/asm/interrupt.asm -o out/lib_interrupt.o
	ld86 -o out/kernel -d out/*.o out/std/*.o
	dd if=out/kernel of=out/system.img bs=512 conv=notrunc seek=1 status=noxfer
	# ------------ Compiled kernel stat ------------
	# Max Kernel Size : 8192 bytes (16 sectors, 1 sector = 512 bytes)
	@stat --printf="Kernel Size : %s bytes\n" out/kernel
	# ----------------------------------------------

stdlib:
	# -- Standard library --
	@if [ ! -d "out/std" ]; then mkdir out/std; fi
	bcc -ansi -c -o out/std/std_opr.o src/c/std_opr.c
	bcc -ansi -c -o out/std/std_lib.o src/c/std_lib.c

run:
	sudo bochs -f src/config/if2230.config

build-run: all shell multi run

shell:
	bcc -ansi -c -o out/other/shell.o src/c/shell.c
	bcc -ansi -c -o out/other/string.o src/c/string.c
	nasm -f as86 src/asm/interrupt.asm -o out/lib_interrupt.o
	ld86 -o out/shell -d out/other/shell.o out/lib_interrupt.o out/other/string.o
	cd out; ./tc_gen S

multi:
	bcc -ansi -c -o out/other/string.o src/c/string.c
	nasm -f as86 src/asm/interrupt.asm -o out/lib_interrupt.o
	bcc -ansi -c -o out/other/s1.o src/c/s1.c
	ld86 -o out/s1 -d out/other/s1.o out/lib_interrupt.o out/other/string.o
	bcc -ansi -c -o out/other/s2.o src/c/s2.c
	ld86 -o out/s2 -d out/other/s2.o out/lib_interrupt.o out/other/string.o
	bcc -ansi -c -o out/other/s3.o src/c/s3.c
	ld86 -o out/s3 -d out/other/s3.o out/lib_interrupt.o out/other/string.o
	cd out; ./tc_gen M

pit:
	nasm -f as86 src/asm/pit.asm -o out/lib_pit.o
