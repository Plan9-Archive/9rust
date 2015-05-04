CONF=pc64

ARCH = amd64
RUSTC = rustc
CC = gcc
LD = ld
AS = nasm
QEMU = qemu-system-i386 -curses

LDFLAGS = --gc-sections -T $(CONF).ld
RUSTFLAGS = -C soft-float -O --target=$(CONF).json

OBJ= \
	$(CONF).o \
	l.o\

RUSTFILES= \
	macros.rs \
	unwind.rs \
	main.rs \

LIBCORE = libcore.rlib

all: $(BUILDDIR) rust9front.bin

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

rust9front.o: l.asm
	$(AS) -f elf32 -Wall -o $@ $<

rust9front.bin: $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $(OBJ)

debug: rust9front.bin
	$(QEMU) -s -S -kernel $<

$(CONF).o: $(CONF).rs $(LIBCORE)
	$(RUSTC) $(RUSTFLAGS) -o $@ --emit=obj,dep-info $< --extern core=$(LIBCORE)

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

%.o: %.asm
	$(AS) -Wall -o $@ $< $(ASFLAGS)

libcore.rlib: libcore/lib.rs
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link,dep-info $<

clean:
	rm -f *.d *.rlib *.o *.bin

