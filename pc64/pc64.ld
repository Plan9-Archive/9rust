OUTPUT_FORMAT(elf64-x86-64)
ENTRY(start)

KZERO = 0xffffffff80000000;

SECTIONS {
	. = 0x100000;
	. += SIZEOF_HEADERS;

	.init : AT(ADDR(.init)) {
		KEEP( *(.multiboot) )
		*(.inittext)
	}

	. += KZERO;

	.text ALIGN(0x1000) : AT(ADDR(.text) - KZERO) {
		*(.text .text.*)
	}

	etext = .;

	/* read-only data, page aligned to allow use of the no-execute feature */
	.rodata ALIGN(0x1000) : AT(ADDR(.rodata) - KZERO) {
		*(.rodata .rodata.*)
	}
	
	/* Read-write data, page aligned for the .padata section */
	.data ALIGN(0x1000) : AT(ADDR(.data) - KZERO) {
		*(.padata)
		*(.data)
		*(.data.*)
	}

	edata = .;
	
	/* Zero-initialised data */
	.bss : AT(ADDR(.bss) - KZERO) {
		*(.bss .bss.*)
	}
	
	end = .;
	
	/DISCARD/ : {
		*(.note .note.*)
	}
}

