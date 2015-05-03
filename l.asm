[section .text]

extern _edata
extern _end

%define edata _edata
%define end _end

_protected:
  cli ; [CL]ear [I]nterrupts
  mov EAX, _gdtptr32 wrt .text
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  jmp far 0x6:(_warp64-KZERO)
  nop

_multibootheader:
 dl 0x1BADB002                 ;; magic
 dl 0x00010003                 ;; flags
 dl -(0x1BADB002 + 0x00010003) ;; checksum
 dl _multibootheader-KZERO     ;; header_addr
 dl _protected-KZERO           ;; load_addr
 dl [_edata-KZERO]                ;; load_end_addr
 dl [_end-KZERO]                  ;; bss_end_addr
 dl _multibootentry            ;; entry_addr
 dl 0                          ;; mode_type
 dl 0                          ;; width
 dl 0                          ;; height
 dl 0                          ;; depth

_multibootentry:
  mov si, [_etext-KZERO]
  mov di, si
  add di, [BY2PG-1]
  add di, ![BY2PG-1]
  sub cx, di
  add si, cx
  add di, cx
  std
  rep
    movsb
  cld
  mov [multiboot_ptr - KZERO], ebx
	mov ax, [_protected - KZERO]
  jmp [ax]

;; multiboot structure pointer (physical address)
multibootptr:
	dd 0, 0xFFFFFFFF

s_multiboot_signature:
	dd 0

_gdt:
	dd 0, 0
	; (KESEG) 64 bit long mode exec segment
	dd 0x00000000, 0x00209A00	; 0x08: 64-bit Code
	dd 0x00000000, 0x00009200	; 0x10: 64-bit Data
	; 32 bit data segment descriptor for 4 gigabytes (PL 0)
	dd 0x00000000, 0x0040FA00	; 0x18: 32-bit User Code
	; 32 bit exec segment descriptor for 4 gigabytes (PL 0)
	dd 0x00000000, 0x0040F200	; 0x20: User Data

_gdtptr64p:
	dw	$-_gdt-1
	dd	_gdt-KZERO

_gdtptr64v:
	dw	_gdtptr64p-_gdt-1
	dq	_gdt

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
