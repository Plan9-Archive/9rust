ARCH = amd64
LD = ld
NASM = nasm
QEMU = qemu-system-i386 -curses

OBJECTS = rust9front.o
ASMOBJECTS = $(wildcard *.asm)

all: $(BUILDDIR) rust9front.bin

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

rust9front.o: l.asm
	$(NASM) -f elf32 -Wall -o $@ $<

rust9front.bin: rust9front.o
	$(LD) -m elf_i386 -o $@ $^

debug: rust9front.bin
	$(QEMU) -s -S -kernel $<
