CONF=pc64

ARCH = amd64
RUSTC = rustc
CC = gcc
LD = ld
AS = nasm
OBJCOPY = objcopy
QEMU = qemu-system-x86_64

LDFLAGS = --gc-sections -z max-page-size=0x1000 -T $(CONF).ld
RUSTFLAGS = -C soft-float -g -O --target=$(CONF).json

OBJ= \
	$(CONF).o \
	l.o\

LIBCORE = libcore.rlib

all: 9$(CONF)

9$(CONF): $(OBJ)
	$(LD) $(LDFLAGS) -o $@.tmp $(OBJ) $(LIBCORE)
	$(OBJCOPY) --strip-debug -F elf32-i386 $@.tmp $@
	$(OBJCOPY) --only-keep-debug $@.tmp $@.sym
	rm -f $@.tmp

debug: 9$(CONF)
	$(QEMU) -s -S -kernel $< -serial stdio

$(CONF).o: $(CONF).rs $(LIBCORE)
	$(RUSTC) $(RUSTFLAGS) -o $@ --emit=obj $< --extern core=$(LIBCORE)

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

%.o: %.asm
	$(AS) -f elf64 -Wall -o $@ $< $(ASFLAGS)

libcore.rlib: libcore/lib.rs
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link $<

clean:
	rm -f 9$(CONF) *.sym *.d *.rlib *.o *.bin

