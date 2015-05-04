%include "inc.asm"
%include "mem.asm"

[section .multiboot]
[global mboot]
mboot:
	dd	0x1BADB002			;; magic
	dd	0x00000003			;; flags
	dd	-(0x1BADB002 + 0x00000003)	;; checksum
	dd	0				;; header_addr
	dd	0				;; load_addr
	dd	0				;; load_end_addr
	dd	0				;; bss_end_addr
	dd	0				;; entry_addr
	dd	0				;; mode_type
	dd	0				;; width
	dd	0				;; height
	dd	0				;; depth

[section .inittext]
[global start]
[BITS 32]
start:
	; interrupts off
	cli

	; save multiboot pointer
	mov	[multibootsig - KZERO], eax
	or	ebx, 0x80000000
	mov	[multibootptr - KZERO], ebx

	mov	eax, cr4
	or	eax, 0x80|0x20|0x10		; PGE, PAE, PSE
	mov	cr4, eax

	mov	eax, initpml4 - KZERO
	mov	cr3, eax

	mov	ecx, 0xC0000080
	rdmsr
	or	eax, (1 << 11)|(1 << 8)|(1 << 0); NXE, LME, SCE
	wrmsr

	mov	eax, cr0
	or	eax, 0x80010000			; PG & WP
	mov	cr0, eax
	lgdt	[gdtptr64p - KZERO]
	jmp	0x08:_identity

[BITS 64]
_identity:
	mov	rax, _start64v
	jmp	rax

[section .text]
[extern main]
_start64v:
	lgdt	[DWORD gdtptr64v - KZERO]
	mov	ax, 0x10
	mov	ds, ax
	mov	ss, ax
	mov	es, ax
	mov	fs, ax
	mov	gs, ax

	mov	rax, 0
	push	rax
	popfq

	call	main
died:
	cli
	hlt
	jmp	died

[section .padata]
initpml4:	; Covers 256 TiB (Full 48-bit Virtual Address Space)
	dd	initpdp - KZERO + 3, 0	; Identity Map Low 4Mb
	times 0xA0*2-1	dq	0
	; Stacks at 0xFFFFA...
	dd	stackpdp - KZERO + 3, 0
	times 512-4-($-initpml4)/8	dq	0	; < dq until hit 512-4
	dd	initpml4 - KZERO + 3, 0
	dq	0
	dq	0
	dd	highpdp - KZERO + 3, 0	; Map Low 4Mb to kernel base

initpdp:	; Covers 512 GiB
	dd	initpd - KZERO + 3, 0
	times 511	dq	0

stackpdp:
	dd	stackpd - KZERO + 3, 0
	times 511	dq	0

highpdp:	; Covers 512 GiB
	times 510	dq	0
	dd	initpd - KZERO + 3, 0
	dq	0

initpd:		; Covers 1 GiB
	dd	0x000000 + 0x183,0	; Global, 2MiB
	dd	0x200000 + 0x183,0	; Global, 2MiB
	times 510	dq	0

stackpd:
	dd	kstackpt - KZERO + 3, 0
	times 511	dq	0

kstackpt:	; Covers 2 MiB
	; Initial stack - 64KiB
	dq	0
	%assign i 0
	%rep KSTACK-1
	dd	initkstack - KZERO + i*0x1000 + 0x103, 0
	%assign i i+1
	%endrep
	times 512-KSTACK	dq 0

initkstack:
	times 0x1000*(KSTACK-1)	db 0	; 8 Pages

[section .rodata]

;; multiboot structure pointer (physical address)
[section .data]
multibootptr:
	dd	0, 0xFFFFFFFF

multibootsig:
	dd	0

EXPORT gdt
	dd	0, 0
	; (KESEG) 64 bit long mode exec segment
	dd	0x00000000, 0x00209A00	; 0x08: 64-bit Code
	dd	0x00000000, 0x00009200	; 0x10: 64-bit Data
	; 32 bit data segment descriptor for 4 gigabytes (PL 0)
	dd	0x00000000, 0x0040FA00	; 0x18: 32-bit User Code
	; 32 bit exec segment descriptor for 4 gigabytes (PL 0)
	dd	0x00000000, 0x0040F200	; 0x20: User Data

gdtptr64p:
	dw	$-gdt-1
	dd	gdt - KZERO
	dd	0
gdtptr64v:
	dw	gdtptr64p-gdt-1
	dq	gdt

;; EXPORT task_switch
;; 	SAVE rbp, rbx, r12, r13, r14, r15
;; 	mov [rdi], rsp
;; 	mov rsp, [rsi]	; New RSP
;; 	mov cr3, rcx	; New CR3
;; 	; New FSBASE
;; 	mov rax, rdx
;; 	shr rdx, 32	; EDX = High
;; 	mov ecx, 0xC0000100	; FS Base
;; 	wrmsr
;; 	RESTORE rbp, rbx, r12, r13, r14, r15
;; 	ret
;; EXPORT thread_trampoline
;; 	pop rax	; 1. Pop thread root method off stack
;; 	mov rdi, rsp	; 2. Set RDI to the object to call
;; 	jmp rax	; 3. Jump to the thread root method, which should never return

; vim: ft=nasm

