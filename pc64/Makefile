CONF=pc64

ARCH = amd64
RUSTC = rustc
CC = gcc
LD = ld
AS = nasm
OBJCOPY = objcopy
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

all: 9$(CONF)

9$(CONF): $(OBJ)
	$(LD) $(LDFLAGS) -o $@.tmp $(OBJ)
	$(OBJCOPY) $@.tmp -F elf32-i386 $@
	rm -f $@.tmp

debug: 9$(CONF)
	$(QEMU) -s -S -kernel $<

$(CONF).o: $(CONF).rs $(LIBCORE)
	$(RUSTC) $(RUSTFLAGS) -o $@ --emit=obj,dep-info $< --extern core=$(LIBCORE)

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

%.o: %.asm
	$(AS) -f elf64 -Wall -o $@ $< $(ASFLAGS)

libcore.rlib: libcore/lib.rs
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link,dep-info $<

clean:
	rm -f *.d *.rlib *.o *.bin

