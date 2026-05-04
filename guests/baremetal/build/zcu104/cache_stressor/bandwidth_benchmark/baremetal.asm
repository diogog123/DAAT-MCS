
/media/diogo/linux_rootfs_2/PhD_osyx/performance_profiling/guests/baremetal/build/zcu104/cache_stressor/bandwidth_benchmark/baremetal.elf:     file format elf64-littleaarch64


Disassembly of section .start:

0000000000000000 <_start>:
.extern plat_mpu_num_regs

.section .start, "ax"
.global _start
_start:
    mrs x0, MPIDR_EL1
   0:	d53800a0 	mrs	x0, mpidr_el1
    and x0, x0, MPIDR_CPU_MASK
   4:	92401c00 	and	x0, x0, #0xff
     * Check current exception level. If in:
     *     - el0 or el3, stop
     *     - el1, proceed
     *     - el2, jump to el1
     */
    mrs x1, currentEL
   8:	d5384241 	mrs	x1, currentel
    lsr x1, x1, 2
   c:	d342fc21 	lsr	x1, x1, #2
    cmp x1, 0
  10:	f100003f 	cmp	x1, #0x0
    b.eq .
  14:	54000000 	b.eq	14 <_start+0x14>  // b.none
    cmp x1, 3
  18:	f1000c3f 	cmp	x1, #0x3
    b.eq .
  1c:	54000000 	b.eq	1c <_start+0x1c>  // b.none
    cmp x1, 1
  20:	f100043f 	cmp	x1, #0x1
    b.eq _enter_el1
  24:	540001e0 	b.eq	60 <_enter_el1>  // b.none
    mrs x1, mpidr_el1
  28:	d53800a1 	mrs	x1, mpidr_el1
    msr vmpidr_el2, x1
  2c:	d51c00a1 	msr	vmpidr_el2, x1
    mov x1, 0
  30:	d2800001 	mov	x1, #0x0                   	// #0
#ifndef MPU
    // VTCR_EL2.MSA bit enables VMSA in Armv8-R which is RES1 in Armv8-A
    orr x1, x1, (1 << 31) 
  34:	b2610021 	orr	x1, x1, #0x80000000
#endif
    msr vtcr_el2, x1
  38:	d51c2141 	msr	vtcr_el2, x1
    #error "No generic timer frequency source defined"
#endif
    msr cntfrq_el0, x2
#endif  /* defined(MPU) */

    adr x1, _exception_vector
  3c:	1000fe21 	adr	x1, 2000 <_exception_vector>
    msr	VBAR_EL2, x1
  40:	d51cc001 	msr	vbar_el2, x1
    mov x1, SPSR_EL1t | SPSR_F | SPSR_I | SPSR_A | SPSR_D
  44:	d2807881 	mov	x1, #0x3c4                 	// #964
    msr spsr_el2, x1
  48:	d51c4001 	msr	spsr_el2, x1
    mov x1, HCR_RW_BIT
  4c:	d2b00001 	mov	x1, #0x80000000            	// #2147483648
    msr hcr_el2, x1
  50:	d51c1101 	msr	hcr_el2, x1
    adr x1, _enter_el1
  54:	10000061 	adr	x1, 60 <_enter_el1>
    msr elr_el2, x1
  58:	d51c4021 	msr	elr_el2, x1
    eret
  5c:	d69f03e0 	eret

0000000000000060 <_enter_el1>:

_enter_el1:
    adr x1, _exception_vector
  60:	1000fd01 	adr	x1, 2000 <_exception_vector>
    msr	VBAR_EL1, x1
  64:	d518c001 	msr	vbar_el1, x1

    ldr x1, =MAIR_EL1_DFLT
  68:	58000541 	ldr	x1, 110 <clear+0x18>
    msr	MAIR_EL1, x1
  6c:	d518a201 	msr	mair_el1, x1

    // Enable floating point
    mov x1, #(3 << 20)
  70:	d2a00601 	mov	x1, #0x300000              	// #3145728
    msr CPACR_EL1, x1
  74:	d5181041 	msr	cpacr_el1, x1
    ldr x1, =(SCTLR_RES1 | SCTLR_C | SCTLR_I | SCTLR_M)
    msr sctlr_el1, x1

#else 

    ldr x1, =0x0000000000802510
  78:	58000501 	ldr	x1, 118 <clear+0x20>
    msr TCR_EL1, x1
  7c:	d5182041 	msr	tcr_el1, x1

    adr x1, root_page_table
  80:	100b7c01 	adr	x1, 17000 <root_page_table>
    msr TTBR0_EL1, x1
  84:	d5182001 	msr	ttbr0_el1, x1

    //TODO: invalidate caches, bp, .. ?

    tlbi	vmalle1
  88:	d508871f 	tlbi	vmalle1
	dsb	nsh
  8c:	d503379f 	dsb	nsh
	isb
  90:	d5033fdf 	isb

    ldr x1, =(SCTLR_RES1 | SCTLR_M | SCTLR_C | SCTLR_I)
  94:	58000461 	ldr	x1, 120 <clear+0x28>
    msr SCTLR_EL1, x1
  98:	d5181001 	msr	sctlr_el1, x1

    tlbi	vmalle1
  9c:	d508871f 	tlbi	vmalle1
	dsb	nsh
  a0:	d503379f 	dsb	nsh
	isb
  a4:	d5033fdf 	isb
#endif

    cbnz x0, 1f
  a8:	b50000e0 	cbnz	x0, c4 <_enter_el1+0x64>

    ldr x16, =__bss_start 
  ac:	580003f0 	ldr	x16, 128 <clear+0x30>
    ldr x17, =__bss_end   
  b0:	58000411 	ldr	x17, 130 <clear+0x38>
    bl  clear
  b4:	94000011 	bl	f8 <clear>
    .align 3
wait_flag:
    .dword 0x0
    .popsection

    adr x1, wait_flag
  b8:	10088dc1 	adr	x1, 11270 <wait_flag>
    mov x2, #1
  bc:	d2800022 	mov	x2, #0x1                   	// #1
    str x2, [x1]
  c0:	f9000022 	str	x2, [x1]

1:
    adr x1, wait_flag
  c4:	10088d61 	adr	x1, 11270 <wait_flag>
    ldr x2, [x1]
  c8:	f9400022 	ldr	x2, [x1]
    cbz x2, 1b
  cc:	b4ffffc2 	cbz	x2, c4 <_enter_el1+0x64>

    mov x3, #SPSel_SP							
  d0:	d2800023 	mov	x3, #0x1                   	// #1
	msr SPSEL, x3	
  d4:	d5184203 	msr	spsel, x3

    ldr x1, =_stack_base
  d8:	58000301 	ldr	x1, 138 <clear+0x40>
    ldr x2, =STACK_SIZE
  dc:	58000322 	ldr	x2, 140 <clear+0x48>
    add x1, x1, x2
  e0:	8b020021 	add	x1, x1, x2
#ifndef SINGLE_CORE
    madd x1, x0, x2, x1
  e4:	9b020401 	madd	x1, x0, x2, x1
#endif
    mov sp, x1
  e8:	9100003f 	mov	sp, x1
   
    //TODO: other c runtime init (ctors, etc...)

    b _init
  ec:	14000266 	b	a84 <_init>
    b _exit
  f0:	14000254 	b	a40 <_exit>

00000000000000f4 <psci_wake_up>:

.global psci_wake_up
psci_wake_up:
    b .
  f4:	14000000 	b	f4 <psci_wake_up>

00000000000000f8 <clear>:

 .func clear
clear:
2:
	cmp	x16, x17			
  f8:	eb11021f 	cmp	x16, x17
	b.ge 1f				
  fc:	5400006a 	b.ge	108 <clear+0x10>  // b.tcont
	str	xzr, [x16], #8	
 100:	f800861f 	str	xzr, [x16], #8
	b	2b				
 104:	17fffffd 	b	f8 <clear>
1:
	ret
 108:	d65f03c0 	ret
 10c:	00000000 	udf	#0
 110:	0004ff00 	.word	0x0004ff00
 114:	00000000 	.word	0x00000000
 118:	00802510 	.word	0x00802510
 11c:	00000000 	.word	0x00000000
 120:	30c51835 	.word	0x30c51835
 124:	00000000 	.word	0x00000000
 128:	00100000 	.word	0x00100000
 12c:	00000000 	.word	0x00000000
 130:	00400478 	.word	0x00400478
 134:	00000000 	.word	0x00000000
 138:	00400480 	.word	0x00400480
 13c:	00000000 	.word	0x00000000
 140:	00001000 	.word	0x00001000
 144:	00000000 	.word	0x00000000

Disassembly of section .text:

0000000000000800 <irq_set_handler>:

irq_handler_t irq_handlers[IRQ_NUM];

void irq_set_handler(unsigned id, irq_handler_t handler)
{
    if (id < IRQ_NUM) {
     800:	710ffc1f 	cmp	w0, #0x3ff
     804:	54000088 	b.hi	814 <irq_set_handler+0x14>  // b.pmore
        irq_handlers[id] = handler;
     808:	90000802 	adrp	x2, 100000 <irq_handlers>
     80c:	91000042 	add	x2, x2, #0x0
     810:	f8205841 	str	x1, [x2, w0, uxtw #3]
    }
}
     814:	d65f03c0 	ret
     818:	d503201f 	nop
     81c:	d503201f 	nop

0000000000000820 <irq_handle>:

void irq_handle(unsigned id)
{
     820:	2a0003e1 	mov	w1, w0
    if (id < IRQ_NUM && irq_handlers[id] != NULL) {
     824:	710ffc1f 	cmp	w0, #0x3ff
     828:	540000e8 	b.hi	844 <irq_handle+0x24>  // b.pmore
     82c:	90000802 	adrp	x2, 100000 <irq_handlers>
     830:	91000042 	add	x2, x2, #0x0
     834:	f8615841 	ldr	x1, [x2, w1, uxtw #3]
     838:	b4000061 	cbz	x1, 844 <irq_handle+0x24>
        irq_handlers[id](id);
     83c:	aa0103f0 	mov	x16, x1
     840:	d61f0200 	br	x16
    }
}
     844:	d65f03c0 	ret
     848:	d503201f 	nop
     84c:	d503201f 	nop

0000000000000850 <irq_clear_ipi>:

__attribute__((weak)) void irq_clear_ipi(void)
{
    // Default implementation, doing nothing
    // Each architecture should rewrite and override this function if need
}
     850:	d65f03c0 	ret
	...

0000000000000860 <_read>:
#include <cpu.h>
#include <fences.h>
#include <wfi.h>

int _read(int file, char* ptr, int len)
{
     860:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
     864:	910003fd 	mov	x29, sp
     868:	f90013f5 	str	x21, [sp, #32]
     86c:	2a0203f5 	mov	w21, w2
    int i;
    for (i = 0; i < len; ++i) {
     870:	7100005f 	cmp	w2, #0x0
     874:	5400014d 	b.le	89c <_read+0x3c>
     878:	a90153f3 	stp	x19, x20, [sp, #16]
     87c:	aa0103f3 	mov	x19, x1
     880:	8b22c034 	add	x20, x1, w2, sxtw
     884:	d503201f 	nop
        ptr[i] = uart_getchar();
     888:	94000342 	bl	1590 <uart_getchar>
     88c:	38001660 	strb	w0, [x19], #1
    for (i = 0; i < len; ++i) {
     890:	eb14027f 	cmp	x19, x20
     894:	54ffffa1 	b.ne	888 <_read+0x28>  // b.any
     898:	a94153f3 	ldp	x19, x20, [sp, #16]
    }

    return len;
}
     89c:	2a1503e0 	mov	w0, w21
     8a0:	f94013f5 	ldr	x21, [sp, #32]
     8a4:	a8c37bfd 	ldp	x29, x30, [sp], #48
     8a8:	d65f03c0 	ret
     8ac:	d503201f 	nop

00000000000008b0 <_write>:

int _write(int file, char* ptr, int len)
{
     8b0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
     8b4:	910003fd 	mov	x29, sp
     8b8:	a90153f3 	stp	x19, x20, [sp, #16]
     8bc:	8b22c034 	add	x20, x1, w2, sxtw
     8c0:	f90013f5 	str	x21, [sp, #32]
     8c4:	2a0203f5 	mov	w21, w2
    int i;
    for (i = 0; i < len; ++i) {
     8c8:	7100005f 	cmp	w2, #0x0
     8cc:	5400022d 	b.le	910 <_write+0x60>
     8d0:	aa0103f3 	mov	x19, x1
     8d4:	14000005 	b	8e8 <_write+0x38>
     8d8:	91000673 	add	x19, x19, #0x1
        if (ptr[i] == '\n') {
            uart_putc('\r');
        }
        uart_putc(ptr[i]);
     8dc:	94000329 	bl	1580 <uart_putc>
    for (i = 0; i < len; ++i) {
     8e0:	eb14027f 	cmp	x19, x20
     8e4:	54000160 	b.eq	910 <_write+0x60>  // b.none
        if (ptr[i] == '\n') {
     8e8:	39400260 	ldrb	w0, [x19]
     8ec:	7100281f 	cmp	w0, #0xa
     8f0:	54ffff41 	b.ne	8d8 <_write+0x28>  // b.any
            uart_putc('\r');
     8f4:	528001a0 	mov	w0, #0xd                   	// #13
     8f8:	94000322 	bl	1580 <uart_putc>
        uart_putc(ptr[i]);
     8fc:	39400260 	ldrb	w0, [x19]
    for (i = 0; i < len; ++i) {
     900:	91000673 	add	x19, x19, #0x1
        uart_putc(ptr[i]);
     904:	9400031f 	bl	1580 <uart_putc>
    for (i = 0; i < len; ++i) {
     908:	eb14027f 	cmp	x19, x20
     90c:	54fffee1 	b.ne	8e8 <_write+0x38>  // b.any
    }

    return len;
}
     910:	a94153f3 	ldp	x19, x20, [sp, #16]
     914:	2a1503e0 	mov	w0, w21
     918:	f94013f5 	ldr	x21, [sp, #32]
     91c:	a8c37bfd 	ldp	x29, x30, [sp], #48
     920:	d65f03c0 	ret

0000000000000924 <_write_r>:

ssize_t _write_r(struct _reent* r, int file, const void* ptr, size_t len)
{
    if (ptr == NULL) {
     924:	b4000402 	cbz	x2, 9a4 <_write_r+0x80>
{
     928:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
     92c:	910003fd 	mov	x29, sp
     930:	f90013f5 	str	x21, [sp, #32]
     934:	aa0303f5 	mov	x21, x3
    for (i = 0; i < len; ++i) {
     938:	7100007f 	cmp	w3, #0x0
     93c:	540002cd 	b.le	994 <_write_r+0x70>
     940:	51000460 	sub	w0, w3, #0x1
     944:	a90153f3 	stp	x19, x20, [sp, #16]
     948:	91000454 	add	x20, x2, #0x1
     94c:	aa0203f3 	mov	x19, x2
     950:	8b000294 	add	x20, x20, x0
     954:	14000005 	b	968 <_write_r+0x44>
     958:	91000673 	add	x19, x19, #0x1
        uart_putc(ptr[i]);
     95c:	94000309 	bl	1580 <uart_putc>
    for (i = 0; i < len; ++i) {
     960:	eb14027f 	cmp	x19, x20
     964:	54000160 	b.eq	990 <_write_r+0x6c>  // b.none
        if (ptr[i] == '\n') {
     968:	39400260 	ldrb	w0, [x19]
     96c:	7100281f 	cmp	w0, #0xa
     970:	54ffff41 	b.ne	958 <_write_r+0x34>  // b.any
            uart_putc('\r');
     974:	528001a0 	mov	w0, #0xd                   	// #13
     978:	94000302 	bl	1580 <uart_putc>
        uart_putc(ptr[i]);
     97c:	39400260 	ldrb	w0, [x19]
    for (i = 0; i < len; ++i) {
     980:	91000673 	add	x19, x19, #0x1
        uart_putc(ptr[i]);
     984:	940002ff 	bl	1580 <uart_putc>
    for (i = 0; i < len; ++i) {
     988:	eb14027f 	cmp	x19, x20
     98c:	54fffee1 	b.ne	968 <_write_r+0x44>  // b.any
     990:	a94153f3 	ldp	x19, x20, [sp, #16]
            r->_errno = EINVAL; // Set thread-local errno
        }
        return -1;
    }

    return _write(file, ptr, len);
     994:	93407ea0 	sxtw	x0, w21
}
     998:	f94013f5 	ldr	x21, [sp, #32]
     99c:	a8c37bfd 	ldp	x29, x30, [sp], #48
     9a0:	d65f03c0 	ret
        if (r) {
     9a4:	b4000060 	cbz	x0, 9b0 <_write_r+0x8c>
            r->_errno = EINVAL; // Set thread-local errno
     9a8:	528002c1 	mov	w1, #0x16                  	// #22
     9ac:	b9000001 	str	w1, [x0]
        return -1;
     9b0:	92800000 	mov	x0, #0xffffffffffffffff    	// #-1
}
     9b4:	d65f03c0 	ret
     9b8:	d503201f 	nop
     9bc:	d503201f 	nop

00000000000009c0 <_lseek>:

int _lseek(int file, int ptr, int dir)
{
     9c0:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
     9c4:	910003fd 	mov	x29, sp
    errno = ESPIPE;
     9c8:	9400084e 	bl	2b00 <__errno>
     9cc:	aa0003e1 	mov	x1, x0
     9d0:	528003a2 	mov	w2, #0x1d                  	// #29
    return -1;
}
     9d4:	12800000 	mov	w0, #0xffffffff            	// #-1
    errno = ESPIPE;
     9d8:	b9000022 	str	w2, [x1]
}
     9dc:	a8c17bfd 	ldp	x29, x30, [sp], #16
     9e0:	d65f03c0 	ret

00000000000009e4 <_close>:

int _close(int file)
{
    return -1;
}
     9e4:	12800000 	mov	w0, #0xffffffff            	// #-1
     9e8:	d65f03c0 	ret
     9ec:	d503201f 	nop

00000000000009f0 <_fstat>:

int _fstat(int file, struct stat* st)
{
    st->st_mode = S_IFCHR;
     9f0:	52840002 	mov	w2, #0x2000                	// #8192
    return 0;
}
     9f4:	52800000 	mov	w0, #0x0                   	// #0
    st->st_mode = S_IFCHR;
     9f8:	b9000422 	str	w2, [x1, #4]
}
     9fc:	d65f03c0 	ret

0000000000000a00 <_isatty>:

int _isatty(int fd)
{
     a00:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
     a04:	910003fd 	mov	x29, sp
    errno = ENOTTY;
     a08:	9400083e 	bl	2b00 <__errno>
     a0c:	aa0003e1 	mov	x1, x0
     a10:	52800322 	mov	w2, #0x19                  	// #25
    return 0;
}
     a14:	52800000 	mov	w0, #0x0                   	// #0
    errno = ENOTTY;
     a18:	b9000022 	str	w2, [x1]
}
     a1c:	a8c17bfd 	ldp	x29, x30, [sp], #16
     a20:	d65f03c0 	ret

0000000000000a24 <_sbrk>:

void* _sbrk(int increment)
{
    extern char _heap_base;
    static char* heap_end = &_heap_base;
    char* current_heap_end = heap_end;
     a24:	b0000082 	adrp	x2, 11000 <JIS_action_table>
{
     a28:	2a0003e1 	mov	w1, w0
    char* current_heap_end = heap_end;
     a2c:	f9412840 	ldr	x0, [x2, #592]
    heap_end += increment;
     a30:	8b21c001 	add	x1, x0, w1, sxtw
     a34:	f9012841 	str	x1, [x2, #592]
    return current_heap_end;
}
     a38:	d65f03c0 	ret
     a3c:	d503201f 	nop

0000000000000a40 <_exit>:
    DMB(ishld);
}

static inline void fence_ord()
{
    DMB(ish);
     a40:	d5033bbf 	dmb	ish
     a44:	d503201f 	nop
#ifndef WFI_H
#define WFI_H

static inline void wfi()
{
    asm volatile("wfi\n\t" ::: "memory");
     a48:	d503207f 	wfi

void _exit(int return_value)
{
    fence_ord();
    while (1) {
     a4c:	17ffffff 	b	a48 <_exit+0x8>

0000000000000a50 <_getpid>:
}

int _getpid(void)
{
    return 1;
}
     a50:	52800020 	mov	w0, #0x1                   	// #1
     a54:	d65f03c0 	ret
     a58:	d503201f 	nop
     a5c:	d503201f 	nop

0000000000000a60 <_kill>:

int _kill(int pid, int sig)
{
     a60:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
     a64:	910003fd 	mov	x29, sp
    errno = EINVAL;
     a68:	94000826 	bl	2b00 <__errno>
     a6c:	aa0003e1 	mov	x1, x0
     a70:	528002c2 	mov	w2, #0x16                  	// #22
    return -1;
}
     a74:	12800000 	mov	w0, #0xffffffff            	// #-1
    errno = EINVAL;
     a78:	b9000022 	str	w2, [x1]
}
     a7c:	a8c17bfd 	ldp	x29, x30, [sp], #16
     a80:	d65f03c0 	ret

0000000000000a84 <_init>:

static bool init_done = false;
static spinlock_t init_lock = SPINLOCK_INITVAL;

__attribute__((weak)) void _init()
{
     a84:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
static inline void spin_lock(spinlock_t* lock)
{
    uint32_t const ONE = 1;
    spinlock_t tmp;

    asm volatile("1:\n\t"
     a88:	d0000800 	adrp	x0, 102000 <init_lock>
     a8c:	52800021 	mov	w1, #0x1                   	// #1
     a90:	910003fd 	mov	x29, sp
     a94:	f9000bf3 	str	x19, [sp, #16]
     a98:	91000013 	add	x19, x0, #0x0
     a9c:	885ffe62 	ldaxr	w2, [x19]
     aa0:	35ffffe2 	cbnz	w2, a9c <_init+0x18>
     aa4:	88027e61 	stxr	w2, w1, [x19]
     aa8:	35ffffa2 	cbnz	w2, a9c <_init+0x18>
    spin_lock(&init_lock);
    if (!init_done) {
     aac:	39401260 	ldrb	w0, [x19, #4]
     ab0:	b9002fe2 	str	w2, [sp, #44]
     ab4:	360000a0 	tbz	w0, #0, ac8 <_init+0x44>
                 "cbnz %w0, 1b \n\t" : "=&r"(tmp), "+Q"(*lock) : "r"(ONE));
}

static inline void spin_unlock(spinlock_t* lock)
{
    asm volatile("stlr wzr, %0\n\t" ::"Q"(*lock));
     ab8:	889ffe7f 	stlr	wzr, [x19]
        init_done = true;
        uart_init();
    }
    spin_unlock(&init_lock);

    arch_init();
     abc:	94000325 	bl	1750 <arch_init>

    int ret = main();
     ac0:	9400049c 	bl	1d30 <main>
    _exit(ret);
     ac4:	97ffffdf 	bl	a40 <_exit>
        init_done = true;
     ac8:	39001261 	strb	w1, [x19, #4]
        uart_init();
     acc:	940002a1 	bl	1550 <uart_init>
     ad0:	17fffffa 	b	ab8 <_init+0x34>
	...

0000000000000ae0 <virtio_console_mmio_init>:

    return ret;
}

bool virtio_console_mmio_init(struct virtio_console* console)
{
     ae0:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    if (console->mmio->MagicValue != VIRTIO_MAGIC_VALUE) {
     ae4:	528d2ec2 	mov	w2, #0x6976                	// #26998
     ae8:	72ae8e42 	movk	w2, #0x7472, lsl #16
{
     aec:	910003fd 	mov	x29, sp
    if (console->mmio->MagicValue != VIRTIO_MAGIC_VALUE) {
     af0:	f9404001 	ldr	x1, [x0, #128]
     af4:	b9400023 	ldr	w3, [x1]
     af8:	6b02007f 	cmp	w3, w2
     afc:	54000b61 	b.ne	c68 <virtio_console_mmio_init+0x188>  // b.any
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register magic value mismatch\n");
        return false;
    }

    if (console->mmio->Version != VIRTIO_VERSION_NO_LEGACY) {
     b00:	b9400422 	ldr	w2, [x1, #4]
     b04:	7100085f 	cmp	w2, #0x2
     b08:	54000a21 	b.ne	c4c <virtio_console_mmio_init+0x16c>  // b.any
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register version mismatch\n");
        return false;
    }

    if (console->mmio->DeviceID != console->device_id) {
     b0c:	79435002 	ldrh	w2, [x0, #424]
     b10:	b9400823 	ldr	w3, [x1, #8]
     b14:	6b02007f 	cmp	w3, w2
     b18:	54000e21 	b.ne	cdc <virtio_console_mmio_init+0x1fc>  // b.any
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register device ID mismatch\n");
        return false;
    }

    console->mmio->Status = RESET;
     b1c:	b900703f 	str	wzr, [x1, #112]
    console->mmio->Status |= ACKNOWLEDGE;
     b20:	b9407022 	ldr	w2, [x1, #112]
     b24:	32000042 	orr	w2, w2, #0x1
     b28:	b9007022 	str	w2, [x1, #112]
    console->mmio->Status |= DRIVER;
     b2c:	b9407022 	ldr	w2, [x1, #112]
     b30:	321f0042 	orr	w2, w2, #0x2
     b34:	b9007022 	str	w2, [x1, #112]

    if (console->mmio->Status != (RESET | ACKNOWLEDGE | DRIVER)) {
     b38:	b9407022 	ldr	w2, [x1, #112]
     b3c:	71000c5f 	cmp	w2, #0x3
     b40:	54000c01 	b.ne	cc0 <virtio_console_mmio_init+0x1e0>  // b.any
        console->mmio->DeviceFeaturesSel = i;
        console->mmio->DriverFeaturesSel = i;
        uint64_t acked_features =
            console->mmio->DeviceFeatures & (VIRTIO_CONSOLE_FEATURES >> (i * 32));
        console->mmio->DriverFeatures = acked_features;
        console->negotiated_feature_bits |= (acked_features << (i * 32));
     b44:	f940d805 	ldr	x5, [x0, #432]
        console->mmio->DeviceFeaturesSel = i;
     b48:	b900143f 	str	wzr, [x1, #20]
        console->mmio->DriverFeaturesSel = i;
     b4c:	b900243f 	str	wzr, [x1, #36]
        console->mmio->DeviceFeaturesSel = i;
     b50:	52800023 	mov	w3, #0x1                   	// #1
    }

    if (console->negotiated_feature_bits != VIRTIO_CONSOLE_FEATURES) {
     b54:	d2c00064 	mov	x4, #0x300000000           	// #12884901888
            console->mmio->DeviceFeatures & (VIRTIO_CONSOLE_FEATURES >> (i * 32));
     b58:	b9401022 	ldr	w2, [x1, #16]
        console->mmio->DriverFeatures = acked_features;
     b5c:	b900203f 	str	wzr, [x1, #32]
        console->mmio->DeviceFeaturesSel = i;
     b60:	b9001423 	str	w3, [x1, #20]
        console->mmio->DriverFeaturesSel = i;
     b64:	b9002423 	str	w3, [x1, #36]
            console->mmio->DeviceFeatures & (VIRTIO_CONSOLE_FEATURES >> (i * 32));
     b68:	b9401022 	ldr	w2, [x1, #16]
     b6c:	12000442 	and	w2, w2, #0x3
        console->mmio->DriverFeatures = acked_features;
     b70:	b9002022 	str	w2, [x1, #32]
        console->negotiated_feature_bits |= (acked_features << (i * 32));
     b74:	aa0280a2 	orr	x2, x5, x2, lsl #32
     b78:	f900d802 	str	x2, [x0, #432]
    if (console->negotiated_feature_bits != VIRTIO_CONSOLE_FEATURES) {
     b7c:	eb04005f 	cmp	x2, x4
     b80:	54000821 	b.ne	c84 <virtio_console_mmio_init+0x1a4>  // b.any
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register feature mismatch\n");
        return false;
    }

    console->config_space.cols = console->mmio->Config & 0xFFFF;
     b84:	b9410024 	ldr	w4, [x1, #256]
     b88:	aa0003e2 	mov	x2, x0
    console->config_space.rows = (console->mmio->Config >> 16) & 0xFFFF;
     b8c:	b9410025 	ldr	w5, [x1, #256]
        console->mmio->Status |= FAILED;
        printf("VirtIO MMIO register status mismatch\n");
        return false;
    }

    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++) {
     b90:	52800006 	mov	w6, #0x0                   	// #0
        *((volatile uint32_t*)((uintptr_t)&console->mmio->Config + 0x4));
     b94:	b9410427 	ldr	w7, [x1, #260]
    console->config_space.max_nr_ports =
     b98:	b9008c07 	str	w7, [x0, #140]
    console->config_space.cols = console->mmio->Config & 0xFFFF;
     b9c:	79011004 	strh	w4, [x0, #136]
    console->config_space.rows = (console->mmio->Config >> 16) & 0xFFFF;
     ba0:	53107ca5 	lsr	w5, w5, #16
        *((volatile uint32_t*)((uintptr_t)&console->mmio->Config + 0x8));
     ba4:	b9410827 	ldr	w7, [x1, #264]
    console->mmio->Status |= FEATURES_OK;
     ba8:	b9407024 	ldr	w4, [x1, #112]
    console->config_space.rows = (console->mmio->Config >> 16) & 0xFFFF;
     bac:	79011405 	strh	w5, [x0, #138]
    console->config_space.emerg_wr =
     bb0:	b9009007 	str	w7, [x0, #144]
    console->mmio->Status |= FEATURES_OK;
     bb4:	321d0080 	orr	w0, w4, #0x8
     bb8:	b9007020 	str	w0, [x1, #112]
    if (console->mmio->Status != (RESET | ACKNOWLEDGE | DRIVER | FEATURES_OK)) {
     bbc:	b9407020 	ldr	w0, [x1, #112]
     bc0:	71002c1f 	cmp	w0, #0xb
     bc4:	540007e1 	b.ne	cc0 <virtio_console_mmio_init+0x1e0>  // b.any
        console->mmio->QueueSel = vq_id;
     bc8:	b9003026 	str	w6, [x1, #48]
        if (console->mmio->QueueReady != 0) {
     bcc:	b9404420 	ldr	w0, [x1, #68]
     bd0:	350002a0 	cbnz	w0, c24 <virtio_console_mmio_init+0x144>
            console->mmio->Status |= FAILED;
            printf("VirtIO MMIO register queue ready mismatch\n");
            return false;
        }

        int queue_num_max = console->mmio->QueueNumMax;
     bd4:	b9403420 	ldr	w0, [x1, #52]

        if (queue_num_max == 0) {
     bd8:	34000900 	cbz	w0, cf8 <virtio_console_mmio_init+0x218>

        console->mmio->QueueDescLow = (uint32_t)((uint64_t)console->vqs[vq_id].desc & 0xFFFFFFFF);
        console->mmio->QueueDescHigh =
            (uint32_t)(((uint64_t)console->vqs[vq_id].desc >> 32) & 0xFFFFFFFF);
        console->mmio->QueueDriverLow =
            (uint32_t)((uint64_t)console->vqs[vq_id].avail & 0xFFFFFFFF);
     bdc:	a9401440 	ldp	x0, x5, [x2]
    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++) {
     be0:	91010042 	add	x2, x2, #0x40
        console->mmio->QueueDriverHigh =
            (uint32_t)(((uint64_t)console->vqs[vq_id].avail >> 32) & 0xFFFFFFFF);
        console->mmio->QueueDeviceLow = (uint32_t)((uint64_t)console->vqs[vq_id].used & 0xFFFFFFFF);
     be4:	f85d0044 	ldur	x4, [x2, #-48]
        console->mmio->QueueDescLow = (uint32_t)((uint64_t)console->vqs[vq_id].desc & 0xFFFFFFFF);
     be8:	b9008020 	str	w0, [x1, #128]
            (uint32_t)(((uint64_t)console->vqs[vq_id].desc >> 32) & 0xFFFFFFFF);
     bec:	d360fc00 	lsr	x0, x0, #32
        console->mmio->QueueDescHigh =
     bf0:	b9008420 	str	w0, [x1, #132]
        console->mmio->QueueDriverLow =
     bf4:	b9009025 	str	w5, [x1, #144]
            (uint32_t)(((uint64_t)console->vqs[vq_id].avail >> 32) & 0xFFFFFFFF);
     bf8:	d360fca0 	lsr	x0, x5, #32
        console->mmio->QueueDriverHigh =
     bfc:	b9009420 	str	w0, [x1, #148]
        console->mmio->QueueDeviceHigh =
            (uint32_t)(((uint64_t)console->vqs[vq_id].used >> 32) & 0xFFFFFFFF);
     c00:	d360fc80 	lsr	x0, x4, #32
        console->mmio->QueueDeviceLow = (uint32_t)((uint64_t)console->vqs[vq_id].used & 0xFFFFFFFF);
     c04:	b900a024 	str	w4, [x1, #160]
        console->mmio->QueueDeviceHigh =
     c08:	b900a420 	str	w0, [x1, #164]

        console->mmio->QueueReady = 1;
     c0c:	b9004423 	str	w3, [x1, #68]
    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++) {
     c10:	35000486 	cbnz	w6, ca0 <virtio_console_mmio_init+0x1c0>
     c14:	52800026 	mov	w6, #0x1                   	// #1
        console->mmio->QueueSel = vq_id;
     c18:	b9003026 	str	w6, [x1, #48]
        if (console->mmio->QueueReady != 0) {
     c1c:	b9404420 	ldr	w0, [x1, #68]
     c20:	34fffda0 	cbz	w0, bd4 <virtio_console_mmio_init+0xf4>
            console->mmio->Status |= FAILED;
     c24:	b9407022 	ldr	w2, [x1, #112]
            printf("VirtIO MMIO register queue ready mismatch\n");
     c28:	90000080 	adrp	x0, 10000 <__env_lock>
     c2c:	91148000 	add	x0, x0, #0x520
            console->mmio->Status |= FAILED;
     c30:	32190042 	orr	w2, w2, #0x80
     c34:	b9007022 	str	w2, [x1, #112]
            printf("VirtIO MMIO register queue ready mismatch\n");
     c38:	9400084e 	bl	2d70 <puts>
            return false;
     c3c:	d503201f 	nop
        return false;
     c40:	52800000 	mov	w0, #0x0                   	// #0
        printf("VirtIO MMIO register status mismatch\n");
        return false;
    }

    return true;
}
     c44:	a8c17bfd 	ldp	x29, x30, [sp], #16
     c48:	d65f03c0 	ret
        console->mmio->Status |= FAILED;
     c4c:	b9407022 	ldr	w2, [x1, #112]
        printf("VirtIO MMIO register version mismatch\n");
     c50:	90000080 	adrp	x0, 10000 <__env_lock>
     c54:	91120000 	add	x0, x0, #0x480
        console->mmio->Status |= FAILED;
     c58:	32190042 	orr	w2, w2, #0x80
     c5c:	b9007022 	str	w2, [x1, #112]
        printf("VirtIO MMIO register version mismatch\n");
     c60:	94000844 	bl	2d70 <puts>
        return false;
     c64:	17fffff7 	b	c40 <virtio_console_mmio_init+0x160>
        console->mmio->Status |= FAILED;
     c68:	b9407022 	ldr	w2, [x1, #112]
        printf("VirtIO MMIO register magic value mismatch\n");
     c6c:	90000080 	adrp	x0, 10000 <__env_lock>
     c70:	91114000 	add	x0, x0, #0x450
        console->mmio->Status |= FAILED;
     c74:	32190042 	orr	w2, w2, #0x80
     c78:	b9007022 	str	w2, [x1, #112]
        printf("VirtIO MMIO register magic value mismatch\n");
     c7c:	9400083d 	bl	2d70 <puts>
        return false;
     c80:	17fffff0 	b	c40 <virtio_console_mmio_init+0x160>
        console->mmio->Status |= FAILED;
     c84:	b9407022 	ldr	w2, [x1, #112]
        printf("VirtIO MMIO register feature mismatch\n");
     c88:	90000080 	adrp	x0, 10000 <__env_lock>
     c8c:	9113e000 	add	x0, x0, #0x4f8
        console->mmio->Status |= FAILED;
     c90:	32190042 	orr	w2, w2, #0x80
     c94:	b9007022 	str	w2, [x1, #112]
        printf("VirtIO MMIO register feature mismatch\n");
     c98:	94000836 	bl	2d70 <puts>
        return false;
     c9c:	17ffffe9 	b	c40 <virtio_console_mmio_init+0x160>
    console->mmio->Status |= DRIVER_OK;
     ca0:	b9407022 	ldr	w2, [x1, #112]
    return true;
     ca4:	52800020 	mov	w0, #0x1                   	// #1
    console->mmio->Status |= DRIVER_OK;
     ca8:	321e0042 	orr	w2, w2, #0x4
     cac:	b9007022 	str	w2, [x1, #112]
    if (console->mmio->Status != (RESET | ACKNOWLEDGE | DRIVER | FEATURES_OK | DRIVER_OK)) {
     cb0:	b9407022 	ldr	w2, [x1, #112]
     cb4:	71003c5f 	cmp	w2, #0xf
     cb8:	54fffc60 	b.eq	c44 <virtio_console_mmio_init+0x164>  // b.none
     cbc:	d503201f 	nop
        console->mmio->Status |= FAILED;
     cc0:	b9407022 	ldr	w2, [x1, #112]
        printf("VirtIO MMIO register status mismatch\n");
     cc4:	90000080 	adrp	x0, 10000 <__env_lock>
     cc8:	91134000 	add	x0, x0, #0x4d0
        console->mmio->Status |= FAILED;
     ccc:	32190042 	orr	w2, w2, #0x80
     cd0:	b9007022 	str	w2, [x1, #112]
        printf("VirtIO MMIO register status mismatch\n");
     cd4:	94000827 	bl	2d70 <puts>
        return false;
     cd8:	17ffffda 	b	c40 <virtio_console_mmio_init+0x160>
        console->mmio->Status |= FAILED;
     cdc:	b9407022 	ldr	w2, [x1, #112]
        printf("VirtIO MMIO register device ID mismatch\n");
     ce0:	90000080 	adrp	x0, 10000 <__env_lock>
     ce4:	9112a000 	add	x0, x0, #0x4a8
        console->mmio->Status |= FAILED;
     ce8:	32190042 	orr	w2, w2, #0x80
     cec:	b9007022 	str	w2, [x1, #112]
        printf("VirtIO MMIO register device ID mismatch\n");
     cf0:	94000820 	bl	2d70 <puts>
        return false;
     cf4:	17ffffd3 	b	c40 <virtio_console_mmio_init+0x160>
            console->mmio->Status |= FAILED;
     cf8:	b9407022 	ldr	w2, [x1, #112]
            printf("VirtIO MMIO register queue number max mismatch\n");
     cfc:	90000080 	adrp	x0, 10000 <__env_lock>
     d00:	91154000 	add	x0, x0, #0x550
            console->mmio->Status |= FAILED;
     d04:	32190042 	orr	w2, w2, #0x80
     d08:	b9007022 	str	w2, [x1, #112]
            printf("VirtIO MMIO register queue number max mismatch\n");
     d0c:	94000819 	bl	2d70 <puts>
            return false;
     d10:	17ffffcc 	b	c40 <virtio_console_mmio_init+0x160>

0000000000000d14 <virtio_console_init>:
{
     d14:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
     d18:	aa0103e3 	mov	x3, x1
 * @param vq_base_addr Base address of the virtqueue
 */
static inline void virtq_init(struct virtq* vq, uint16_t queue_index, char* vq_base_addr)
{
    /* Initialize the descriptor ring */
    vq->desc = (volatile struct virtq_desc*)VIRTQ_DESC_ADDR(vq_base_addr);
     d1c:	52800024 	mov	w4, #0x1                   	// #1
     d20:	910003fd 	mov	x29, sp
     d24:	f9000bf3 	str	x19, [sp, #16]
     d28:	aa0003f3 	mov	x19, x0
    console->device_id = VIRTIO_CONSOLE_DEVICE_ID;
     d2c:	52800060 	mov	w0, #0x3                   	// #3
    console->rx_lock = SPINLOCK_INITVAL;
     d30:	b901a27f 	str	wzr, [x19, #416]
     d34:	f9000261 	str	x1, [x19]
    console->mmio = (volatile struct virtio_mmio_reg*)mmio_base;
     d38:	f9004262 	str	x2, [x19, #128]
    console->rx_buffer[0] = '\0';
     d3c:	3902527f 	strb	wzr, [x19, #148]
    console->rx_buffer_pos = 0;
     d40:	f900ce7f 	str	xzr, [x19, #408]
    console->tx_lock = SPINLOCK_INITVAL;
     d44:	b901a67f 	str	wzr, [x19, #420]
    console->device_id = VIRTIO_CONSOLE_DEVICE_ID;
     d48:	79035260 	strh	w0, [x19, #424]
    console->negotiated_feature_bits = 0;
     d4c:	f900da7f 	str	xzr, [x19, #432]
    console->ready = false;
     d50:	3906e27f 	strb	wzr, [x19, #440]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     d54:	d503201f 	nop
        vq->desc[i].addr = 0;
     d58:	f900007f 	str	xzr, [x3]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     d5c:	11000482 	add	w2, w4, #0x1
        vq->desc[i].len = 0;
     d60:	b900087f 	str	wzr, [x3, #8]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     d64:	91004063 	add	x3, x3, #0x10
        vq->desc[i].flags = 0;
     d68:	781fc07f 	sturh	wzr, [x3, #-4]
        vq->desc[i].next = i + 1;
     d6c:	781fe064 	sturh	w4, [x3, #-2]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     d70:	12003c44 	and	w4, w2, #0xffff
     d74:	7110049f 	cmp	w4, #0x401
     d78:	54ffff01 	b.ne	d58 <virtio_console_init+0x44>  // b.any
    }
    vq->desc[VIRTQ_SIZE - 1].next = 0;
     d7c:	91401024 	add	x4, x1, #0x4, lsl #12
    vq->desc_next_free = 0;
     d80:	52a08000 	mov	w0, #0x4000000             	// #67108864

    /* Initialize the available ring */
    vq->avail = (volatile struct virtq_avail*)VIRTQ_AVAIL_ADDR(vq_base_addr);
    vq->avail->flags = 0;
    vq->avail->idx = 0;
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     d84:	52800002 	mov	w2, #0x0                   	// #0
    vq->desc[VIRTQ_SIZE - 1].next = 0;
     d88:	781fe09f 	sturh	wzr, [x4, #-2]
    vq->avail = (volatile struct virtq_avail*)VIRTQ_AVAIL_ADDR(vq_base_addr);
     d8c:	f9000664 	str	x4, [x19, #8]
    vq->desc_next_free = 0;
     d90:	b801a260 	stur	w0, [x19, #26]
    vq->avail->flags = 0;
     d94:	7900009f 	strh	wzr, [x4]
    vq->avail->idx = 0;
     d98:	7900049f 	strh	wzr, [x4, #2]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     d9c:	d503201f 	nop
        vq->avail->ring[i] = 0;
     da0:	8b22c483 	add	x3, x4, w2, sxtw #1
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     da4:	11000442 	add	w2, w2, #0x1
        vq->avail->ring[i] = 0;
     da8:	7900087f 	strh	wzr, [x3, #4]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     dac:	7110005f 	cmp	w2, #0x400
     db0:	54ffff81 	b.ne	da0 <virtio_console_init+0x8c>  // b.any
    }
    vq->avail_last_idx = 0;

    /* Initialize the used ring */
    vq->used = (volatile struct virtq_used*)VIRTQ_USED_ADDR(vq_base_addr);
     db4:	91401420 	add	x0, x1, #0x5, lsl #12
     db8:	f9000a60 	str	x0, [x19, #16]
    vq->avail_last_idx = 0;
     dbc:	79003e7f 	strh	wzr, [x19, #30]
    vq->used->flags = 0;
    vq->used->idx = 0;
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     dc0:	52800003 	mov	w3, #0x0                   	// #0
    vq->used->flags = 0;
     dc4:	7900001f 	strh	wzr, [x0]
    vq->used->idx = 0;
     dc8:	7900041f 	strh	wzr, [x0, #2]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     dcc:	d503201f 	nop
        vq->used->ring[i].id = 0;
     dd0:	8b23cc22 	add	x2, x1, w3, sxtw #3
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     dd4:	11000463 	add	w3, w3, #0x1
        vq->used->ring[i].id = 0;
     dd8:	91401042 	add	x2, x2, #0x4, lsl #12
     ddc:	b910045f 	str	wzr, [x2, #4100]
        vq->used->ring[i].len = 0;
     de0:	b910085f 	str	wzr, [x2, #4104]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     de4:	7110007f 	cmp	w3, #0x400
     de8:	54ffff41 	b.ne	dd0 <virtio_console_init+0xbc>  // b.any
 * @param size Length of the memory to allocate
 */
static inline void virtio_memory_pool_init(struct virtio_memory_pool* pool, char* base,
    unsigned long size)
{
    pool->base = base;
     dec:	9100a267 	add	x7, x19, #0x28
    vq->last_used_idx = 0;

    vq->queue_index = queue_index;

    /* Initialize the memory pool */
    virtio_memory_pool_init(&vq->pool, (char*)VIRTQ_MEMORY_POOL_ADDR(vq_base_addr),
     df0:	91402022 	add	x2, x1, #0x8, lsl #12
    vq->queue_index = queue_index;
     df4:	7900327f 	strh	wzr, [x19, #24]
    pool->size = size;
     df8:	d2a00023 	mov	x3, #0x10000               	// #65536
    vq->last_used_idx = 0;
     dfc:	7900427f 	strh	wzr, [x19, #32]
    pool->offset = 0;

    /* Mark all memory as free */
    for (unsigned long i = 0; i < size; i++) {
     e00:	d2800020 	mov	x0, #0x1                   	// #1
    pool->base = base;
     e04:	f9001662 	str	x2, [x19, #40]
    pool->offset = 0;
     e08:	a900fce3 	stp	x3, xzr, [x7, #8]
        pool->base[i] = 0;
     e0c:	3900005f 	strb	wzr, [x2]
     e10:	f94000e2 	ldr	x2, [x7]
     e14:	3820685f 	strb	wzr, [x2, x0]
    for (unsigned long i = 0; i < size; i++) {
     e18:	91000400 	add	x0, x0, #0x1
     e1c:	f140401f 	cmp	x0, #0x10, lsl #12
     e20:	54ffff81 	b.ne	e10 <virtio_console_init+0xfc>  // b.any
    virtq_init(&console->vqs[VIRTIO_CONSOLE_TX_VQ_IDX], VIRTIO_CONSOLE_TX_VQ_IDX,
     e24:	91406020 	add	x0, x1, #0x18, lsl #12
    vq->desc = (volatile struct virtq_desc*)VIRTQ_DESC_ADDR(vq_base_addr);
     e28:	52800023 	mov	w3, #0x1                   	// #1
     e2c:	aa0003e2 	mov	x2, x0
     e30:	f9002260 	str	x0, [x19, #64]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     e34:	d503201f 	nop
        vq->desc[i].addr = 0;
     e38:	f900005f 	str	xzr, [x2]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     e3c:	11000464 	add	w4, w3, #0x1
        vq->desc[i].len = 0;
     e40:	b900085f 	str	wzr, [x2, #8]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     e44:	91004042 	add	x2, x2, #0x10
        vq->desc[i].flags = 0;
     e48:	781fc05f 	sturh	wzr, [x2, #-4]
        vq->desc[i].next = i + 1;
     e4c:	781fe043 	sturh	w3, [x2, #-2]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     e50:	12003c83 	and	w3, w4, #0xffff
     e54:	7110047f 	cmp	w3, #0x401
     e58:	54ffff01 	b.ne	e38 <virtio_console_init+0x124>  // b.any
    vq->desc[VIRTQ_SIZE - 1].next = 0;
     e5c:	91407024 	add	x4, x1, #0x1c, lsl #12
    vq->avail = (volatile struct virtq_avail*)VIRTQ_AVAIL_ADDR(vq_base_addr);
     e60:	91010260 	add	x0, x19, #0x40
    vq->desc_next_free = 0;
     e64:	52a08003 	mov	w3, #0x4000000             	// #67108864
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     e68:	52800002 	mov	w2, #0x0                   	// #0
    vq->desc[VIRTQ_SIZE - 1].next = 0;
     e6c:	781fe09f 	sturh	wzr, [x4, #-2]
    vq->desc_next_free = 0;
     e70:	b805a263 	stur	w3, [x19, #90]
    vq->avail = (volatile struct virtq_avail*)VIRTQ_AVAIL_ADDR(vq_base_addr);
     e74:	f9000404 	str	x4, [x0, #8]
    vq->avail->flags = 0;
     e78:	7900009f 	strh	wzr, [x4]
    vq->avail->idx = 0;
     e7c:	7900049f 	strh	wzr, [x4, #2]
        vq->avail->ring[i] = 0;
     e80:	8b22c483 	add	x3, x4, w2, sxtw #1
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     e84:	11000442 	add	w2, w2, #0x1
        vq->avail->ring[i] = 0;
     e88:	7900087f 	strh	wzr, [x3, #4]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     e8c:	7110005f 	cmp	w2, #0x400
     e90:	54ffff81 	b.ne	e80 <virtio_console_init+0x16c>  // b.any
    vq->used = (volatile struct virtq_used*)VIRTQ_USED_ADDR(vq_base_addr);
     e94:	91407422 	add	x2, x1, #0x1d, lsl #12
     e98:	f9000802 	str	x2, [x0, #16]
    vq->avail_last_idx = 0;
     e9c:	79003c1f 	strh	wzr, [x0, #30]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     ea0:	52800003 	mov	w3, #0x0                   	// #0
    vq->used->flags = 0;
     ea4:	7900005f 	strh	wzr, [x2]
    vq->used->idx = 0;
     ea8:	7900045f 	strh	wzr, [x2, #2]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     eac:	d503201f 	nop
        vq->used->ring[i].id = 0;
     eb0:	8b23cc22 	add	x2, x1, w3, sxtw #3
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     eb4:	11000463 	add	w3, w3, #0x1
        vq->used->ring[i].id = 0;
     eb8:	91407042 	add	x2, x2, #0x1c, lsl #12
     ebc:	b910045f 	str	wzr, [x2, #4100]
        vq->used->ring[i].len = 0;
     ec0:	b910085f 	str	wzr, [x2, #4104]
    for (int i = 0; i < VIRTQ_SIZE; i++) {
     ec4:	7110007f 	cmp	w3, #0x400
     ec8:	54ffff41 	b.ne	eb0 <virtio_console_init+0x19c>  // b.any
    pool->base = base;
     ecc:	9101a262 	add	x2, x19, #0x68
    virtio_memory_pool_init(&vq->pool, (char*)VIRTQ_MEMORY_POOL_ADDR(vq_base_addr),
     ed0:	91408021 	add	x1, x1, #0x20, lsl #12
    vq->queue_index = queue_index;
     ed4:	52800023 	mov	w3, #0x1                   	// #1
     ed8:	79003003 	strh	w3, [x0, #24]
    vq->last_used_idx = 0;
     edc:	7900401f 	strh	wzr, [x0, #32]
    pool->size = size;
     ee0:	d2a00023 	mov	x3, #0x10000               	// #65536
    pool->base = base;
     ee4:	f9003661 	str	x1, [x19, #104]
    for (unsigned long i = 0; i < size; i++) {
     ee8:	d2800020 	mov	x0, #0x1                   	// #1
    pool->offset = 0;
     eec:	a900fc43 	stp	x3, xzr, [x2, #8]
        pool->base[i] = 0;
     ef0:	3900003f 	strb	wzr, [x1]
    for (unsigned long i = 0; i < size; i++) {
     ef4:	d503201f 	nop
        pool->base[i] = 0;
     ef8:	f9400041 	ldr	x1, [x2]
     efc:	3820683f 	strb	wzr, [x1, x0]
    for (unsigned long i = 0; i < size; i++) {
     f00:	91000400 	add	x0, x0, #0x1
     f04:	f140401f 	cmp	x0, #0x10, lsl #12
     f08:	54ffff81 	b.ne	ef8 <virtio_console_init+0x1e4>  // b.any
 * @param vq VirtIO virtqueue
 * @return true if there are free slots, false otherwise
 */
static inline bool virtq_has_free_slots(struct virtq* vq)
{
    return vq->desc_num_free != 0;
     f0c:	79403a65 	ldrh	w5, [x19, #28]
    while (virtq_has_free_slots(&console->vqs[VIRTIO_CONSOLE_RX_VQ_IDX])) {
     f10:	34000445 	cbz	w5, f98 <virtio_console_init+0x284>
    return &vq->desc[id % VIRTQ_SIZE];
     f14:	f940026a 	ldr	x10, [x19]
 * @param len Length of the I/O buffer buffer
 */
static inline void virtq_desc_init(volatile struct virtq_desc* desc, uint64_t addr, uint32_t len)
{
    desc->addr = addr;
    desc->len = len;
     f18:	5280080c 	mov	w12, #0x40                  	// #64
 */
static inline char* virtio_memory_pool_alloc(struct virtio_memory_pool* pool,
    unsigned long alloc_size)
{
    /** Check if the requested allocation size is larger than the pool size */
    if (alloc_size > pool->size) {
     f1c:	f94004eb 	ldr	x11, [x7, #8]
    uint16_t idx = vq->desc_next_free;
     f20:	79403666 	ldrh	w6, [x19, #26]
     f24:	d503201f 	nop
    return &vq->desc[id % VIRTQ_SIZE];
     f28:	d37c24c9 	ubfiz	x9, x6, #4, #10
     f2c:	2a0603ed 	mov	w13, w6
     f30:	8b090144 	add	x4, x10, x9
    vq->desc_num_free--;
     f34:	510004a5 	sub	w5, w5, #0x1
     f38:	12003ca5 	and	w5, w5, #0xffff
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
     f3c:	79401c86 	ldrh	w6, [x4, #14]
    vq->desc_num_free--;
     f40:	79003a65 	strh	w5, [x19, #28]
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
     f44:	12003cc6 	and	w6, w6, #0xffff
     f48:	79003666 	strh	w6, [x19, #26]
     f4c:	f100fd7f 	cmp	x11, #0x3f
     f50:	540001e9 	b.ls	f8c <virtio_console_init+0x278>  // b.plast
        return NULL;
    }

    /** Check if there is enough space from the current offset to the end of the pool */
    if (pool->offset + alloc_size <= pool->size) {
     f54:	f94008e3 	ldr	x3, [x7, #16]
     f58:	91010062 	add	x2, x3, #0x40
     f5c:	eb02017f 	cmp	x11, x2
     f60:	54000623 	b.cc	1024 <virtio_console_init+0x310>  // b.lo, b.ul, b.last
        /* Get the pointer to the possible allocated memory */
        char* ptr = pool->base + pool->offset;
     f64:	f94000e8 	ldr	x8, [x7]

        /* Check if the memory is already allocated */
        for (unsigned long i = 0; i < alloc_size; i++) {
     f68:	8b030103 	add	x3, x8, x3
     f6c:	8b020108 	add	x8, x8, x2
     f70:	aa0303e1 	mov	x1, x3
     f74:	14000003 	b	f80 <virtio_console_init+0x26c>
     f78:	eb01011f 	cmp	x8, x1
     f7c:	540001c0 	b.eq	fb4 <virtio_console_init+0x2a0>  // b.none
            if (pool->base[pool->offset + i] != 0) {
     f80:	39400020 	ldrb	w0, [x1]
        for (unsigned long i = 0; i < alloc_size; i++) {
     f84:	91000421 	add	x1, x1, #0x1
            if (pool->base[pool->offset + i] != 0) {
     f88:	34ffff80 	cbz	w0, f78 <virtio_console_init+0x264>
            printf("Failed to allocate memory for I/O buffer\n");
     f8c:	90000080 	adrp	x0, 10000 <__env_lock>
     f90:	91160000 	add	x0, x0, #0x580
     f94:	94000777 	bl	2d70 <puts>
    ret = virtio_console_mmio_init(console);
     f98:	aa1303e0 	mov	x0, x19
     f9c:	97fffed1 	bl	ae0 <virtio_console_mmio_init>
    console->ready = true;
     fa0:	52800021 	mov	w1, #0x1                   	// #1
     fa4:	3906e261 	strb	w1, [x19, #440]
}
     fa8:	f9400bf3 	ldr	x19, [sp, #16]
     fac:	a8c27bfd 	ldp	x29, x30, [sp], #32
     fb0:	d65f03c0 	ret
                return NULL;
            }
        }

        /* Increment the offset for the next allocation */
        pool->offset += alloc_size;
     fb4:	f90008e2 	str	x2, [x7, #16]
        if (io_buffer == NULL) {
     fb8:	b4fffea3 	cbz	x3, f8c <virtio_console_init+0x278>
    desc->addr = addr;
     fbc:	f8296943 	str	x3, [x10, x9]
 * @param vq VirtIO virtqueue
 * @param id Descriptor index
 */
static inline void virtq_add_avail_buf(struct virtq* vq, uint16_t id)
{
    vq->avail->ring[vq->avail->idx % VIRTQ_SIZE] = id;
     fc0:	f9400661 	ldr	x1, [x19, #8]
    desc->len = len;
     fc4:	b900088c 	str	w12, [x4, #8]
    desc->flags = 0;
     fc8:	7900189f 	strh	wzr, [x4, #12]
    desc->next = 0;
     fcc:	79001c9f 	strh	wzr, [x4, #14]
    desc->flags |= VIRTQ_DESC_F_WRITE;
     fd0:	79401880 	ldrh	w0, [x4, #12]
     fd4:	12003c00 	and	w0, w0, #0xffff
     fd8:	321f0000 	orr	w0, w0, #0x2
     fdc:	79001880 	strh	w0, [x4, #12]
    vq->avail->ring[vq->avail->idx % VIRTQ_SIZE] = id;
     fe0:	79400420 	ldrh	w0, [x1, #2]
     fe4:	d37f2400 	ubfiz	x0, x0, #1, #10
     fe8:	8b000020 	add	x0, x1, x0
     fec:	7900080d 	strh	w13, [x0, #4]
    vq->avail->idx++;
     ff0:	79400420 	ldrh	w0, [x1, #2]
     ff4:	12003c00 	and	w0, w0, #0xffff
     ff8:	11000400 	add	w0, w0, #0x1
     ffc:	12003c00 	and	w0, w0, #0xffff
    1000:	79000420 	strh	w0, [x1, #2]
    while (virtq_has_free_slots(&console->vqs[VIRTIO_CONSOLE_RX_VQ_IDX])) {
    1004:	35fff925 	cbnz	w5, f28 <virtio_console_init+0x214>
    ret = virtio_console_mmio_init(console);
    1008:	aa1303e0 	mov	x0, x19
    100c:	97fffeb5 	bl	ae0 <virtio_console_mmio_init>
    console->ready = true;
    1010:	52800021 	mov	w1, #0x1                   	// #1
    1014:	3906e261 	strb	w1, [x19, #440]
}
    1018:	f9400bf3 	ldr	x19, [sp, #16]
    101c:	a8c27bfd 	ldp	x29, x30, [sp], #32
    1020:	d65f03c0 	ret
        /* Return the pointer to the allocated memory */
        return ptr;
    }

    /** If we reached the end of the pool, wrap around (circular buffer behavior) */
    if (alloc_size <= pool->offset) {
    1024:	f100fc7f 	cmp	x3, #0x3f
    1028:	54fffb29 	b.ls	f8c <virtio_console_init+0x278>  // b.plast
        /* Get the pointer to the possible allocated memory */
        char* ptr = pool->base;
    102c:	f94000e3 	ldr	x3, [x7]

        /* Check if the memory is already allocated */
        for (unsigned long i = 0; i < alloc_size; i++) {
    1030:	d2800002 	mov	x2, #0x0                   	// #0
    1034:	14000003 	b	1040 <virtio_console_init+0x32c>
    1038:	f101005f 	cmp	x2, #0x40
    103c:	54fffbc0 	b.eq	fb4 <virtio_console_init+0x2a0>  // b.none
            if (pool->base[i] != 0) {
    1040:	38626860 	ldrb	w0, [x3, x2]
        for (unsigned long i = 0; i < alloc_size; i++) {
    1044:	91000442 	add	x2, x2, #0x1
            if (pool->base[i] != 0) {
    1048:	34ffff80 	cbz	w0, 1038 <virtio_console_init+0x324>
    104c:	17ffffd0 	b	f8c <virtio_console_init+0x278>

0000000000001050 <virtio_console_transmit>:
{
    return console->rx_buffer_pos > 1;
}

void virtio_console_transmit(struct virtio_console* console, char* const data)
{
    1050:	a9b97bfd 	stp	x29, x30, [sp, #-112]!
    1054:	910003fd 	mov	x29, sp
    1058:	a90153f3 	stp	x19, x20, [sp, #16]
    105c:	aa0003f3 	mov	x19, x0
    int data_len = strlen(data);
    1060:	aa0103e0 	mov	x0, x1
{
    1064:	a90363f7 	stp	x23, x24, [sp, #48]
    1068:	aa0103f7 	mov	x23, x1
    int data_len = strlen(data);
    106c:	94000655 	bl	29c0 <strlen>

    if (!console->ready) {
    1070:	3946e262 	ldrb	w2, [x19, #440]
    1074:	36000d62 	tbz	w2, #0, 1220 <virtio_console_transmit+0x1d0>
        printf("VirtIO console device is not ready\n");
        return;
    }

    if (data == NULL || data_len == 0) {
    1078:	aa0003f4 	mov	x20, x0
    107c:	34000ae0 	cbz	w0, 11d8 <virtio_console_transmit+0x188>
    asm volatile("1:\n\t"
    1080:	52800020 	mov	w0, #0x1                   	// #1
    1084:	a9025bf5 	stp	x21, x22, [sp, #32]
        printf("No data to transmit\n");
        return;
    }

    spin_lock(&console->tx_lock);
    1088:	91069275 	add	x21, x19, #0x1a4
    108c:	a9046bf9 	stp	x25, x26, [sp, #64]
    1090:	f9002bfb 	str	x27, [sp, #80]
    1094:	885ffea1 	ldaxr	w1, [x21]
    1098:	35ffffe1 	cbnz	w1, 1094 <virtio_console_transmit+0x44>
    109c:	88017ea0 	stxr	w1, w0, [x21]
    10a0:	35ffffa1 	cbnz	w1, 1094 <virtio_console_transmit+0x44>
    return vq->desc_num_free != 0;
    10a4:	7940ba62 	ldrh	w2, [x19, #92]
    10a8:	91010278 	add	x24, x19, #0x40
    10ac:	b9006fe1 	str	w1, [sp, #108]
    assert(virtq_has_free_slots(vq));
    10b0:	34000c42 	cbz	w2, 1238 <virtio_console_transmit+0x1e8>
    uint16_t idx = vq->desc_next_free;
    10b4:	79403719 	ldrh	w25, [x24, #26]
    vq->desc_num_free--;
    10b8:	51000442 	sub	w2, w2, #0x1
    return &vq->desc[id % VIRTQ_SIZE];
    10bc:	f940227b 	ldr	x27, [x19, #64]
    if (alloc_size > pool->size) {
    10c0:	9101a260 	add	x0, x19, #0x68
    10c4:	d37c273a 	ubfiz	x26, x25, #4, #10

    /* Get the descriptor */
    volatile struct virtq_desc* desc = virtq_get_desc_by_id(vq, desc_id);

    /* Allocate memory for the I/O buffer from the memory pool */
    char* const io_buffer = virtio_memory_pool_alloc(&vq->pool, data_len);
    10c8:	93407e84 	sxtw	x4, w20
    10cc:	8b1a0376 	add	x22, x27, x26
    10d0:	f9400401 	ldr	x1, [x0, #8]
    vq->desc_next_free = virtq_get_desc_by_id(vq, idx)->next;
    10d4:	79401ec3 	ldrh	w3, [x22, #14]
    10d8:	79003703 	strh	w3, [x24, #26]
    vq->desc_num_free--;
    10dc:	79003b02 	strh	w2, [x24, #28]
    10e0:	eb34c03f 	cmp	x1, w20, sxtw
    10e4:	540001e3 	b.cc	1120 <virtio_console_transmit+0xd0>  // b.lo, b.ul, b.last
    if (pool->offset + alloc_size <= pool->size) {
    10e8:	f9400802 	ldr	x2, [x0, #16]
    10ec:	8b020086 	add	x6, x4, x2
    10f0:	eb06003f 	cmp	x1, x6
    10f4:	540007e3 	b.cc	11f0 <virtio_console_transmit+0x1a0>  // b.lo, b.ul, b.last
        for (unsigned long i = 0; i < alloc_size; i++) {
    10f8:	f9403665 	ldr	x5, [x19, #104]
    10fc:	8b0200a5 	add	x5, x5, x2
    1100:	8b050084 	add	x4, x4, x5
    1104:	aa0503e2 	mov	x2, x5
    1108:	14000004 	b	1118 <virtio_console_transmit+0xc8>
    110c:	91000442 	add	x2, x2, #0x1
    1110:	eb02009f 	cmp	x4, x2
    1114:	540001e0 	b.eq	1150 <virtio_console_transmit+0x100>  // b.none
            if (pool->base[pool->offset + i] != 0) {
    1118:	39400043 	ldrb	w3, [x2]
    111c:	34ffff83 	cbz	w3, 110c <virtio_console_transmit+0xbc>
    if (io_buffer == NULL) {
        printf("Failed to allocate memory for I/O buffer\n");
    1120:	f0000060 	adrp	x0, 10000 <__env_lock>
    1124:	91160000 	add	x0, x0, #0x580
    1128:	94000712 	bl	2d70 <puts>
    asm volatile("stlr wzr, %0\n\t" ::"Q"(*lock));
    112c:	889ffebf 	stlr	wzr, [x21]

    /* Notify the backend device */
    virtio_mmio_queue_notify(console->mmio, vq->queue_index);

    spin_unlock(&console->tx_lock);
}
    1130:	a94153f3 	ldp	x19, x20, [sp, #16]
    1134:	a9425bf5 	ldp	x21, x22, [sp, #32]
    1138:	a94363f7 	ldp	x23, x24, [sp, #48]
    113c:	a9446bf9 	ldp	x25, x26, [sp, #64]
    1140:	f9402bfb 	ldr	x27, [sp, #80]
    1144:	a8c77bfd 	ldp	x29, x30, [sp], #112
    1148:	d65f03c0 	ret
    114c:	aa0403e6 	mov	x6, x4

        /* Reset the offset */
        pool->offset = 0;

        /* Increment the offset for the next allocation */
        pool->offset += alloc_size;
    1150:	f9000806 	str	x6, [x0, #16]
    if (io_buffer == NULL) {
    1154:	b4fffe65 	cbz	x5, 1120 <virtio_console_transmit+0xd0>
    strcpy(io_buffer, data);
    1158:	aa1703e1 	mov	x1, x23
    115c:	aa0503e0 	mov	x0, x5
    1160:	940005a8 	bl	2800 <strcpy>
    desc->addr = addr;
    1164:	f83a6b60 	str	x0, [x27, x26]
    vq->avail->ring[vq->avail->idx % VIRTQ_SIZE] = id;
    1168:	f9400701 	ldr	x1, [x24, #8]
    desc->flags &= ~VIRTQ_DESC_F_WRITE;
    116c:	529fffa3 	mov	w3, #0xfffd                	// #65533
    virtio_mmio_queue_notify(console->mmio, vq->queue_index);
    1170:	f9404262 	ldr	x2, [x19, #128]
    desc->len = len;
    1174:	b9000ad4 	str	w20, [x22, #8]
    desc->flags = 0;
    1178:	79001adf 	strh	wzr, [x22, #12]
    desc->next = 0;
    117c:	79001edf 	strh	wzr, [x22, #14]
    desc->flags &= ~VIRTQ_DESC_F_WRITE;
    1180:	79401ac0 	ldrh	w0, [x22, #12]
    1184:	0a030000 	and	w0, w0, w3
    1188:	79001ac0 	strh	w0, [x22, #12]
    118c:	79403303 	ldrh	w3, [x24, #24]
    vq->avail->ring[vq->avail->idx % VIRTQ_SIZE] = id;
    1190:	79400420 	ldrh	w0, [x1, #2]
    1194:	d37f2400 	ubfiz	x0, x0, #1, #10
    1198:	8b000020 	add	x0, x1, x0
    119c:	79000819 	strh	w25, [x0, #4]
    vq->avail->idx++;
    11a0:	79400420 	ldrh	w0, [x1, #2]
    11a4:	12003c00 	and	w0, w0, #0xffff
    11a8:	11000400 	add	w0, w0, #0x1
    11ac:	12003c00 	and	w0, w0, #0xffff
    11b0:	79000420 	strh	w0, [x1, #2]
    uint32_t Config; // offset 0x100
} __attribute__((__packed__, aligned(0x1000)));

static inline void virtio_mmio_queue_notify(volatile struct virtio_mmio_reg* mmio, uint32_t queue_id)
{
    mmio->QueueNotify = queue_id;
    11b4:	b9005043 	str	w3, [x2, #80]
    11b8:	889ffebf 	stlr	wzr, [x21]
}
    11bc:	a94153f3 	ldp	x19, x20, [sp, #16]
    11c0:	a9425bf5 	ldp	x21, x22, [sp, #32]
    11c4:	a94363f7 	ldp	x23, x24, [sp, #48]
    11c8:	a9446bf9 	ldp	x25, x26, [sp, #64]
    11cc:	f9402bfb 	ldr	x27, [sp, #80]
    11d0:	a8c77bfd 	ldp	x29, x30, [sp], #112
    11d4:	d65f03c0 	ret
    11d8:	a94153f3 	ldp	x19, x20, [sp, #16]
        printf("No data to transmit\n");
    11dc:	f0000060 	adrp	x0, 10000 <__env_lock>
}
    11e0:	a94363f7 	ldp	x23, x24, [sp, #48]
        printf("No data to transmit\n");
    11e4:	91176000 	add	x0, x0, #0x5d8
}
    11e8:	a8c77bfd 	ldp	x29, x30, [sp], #112
        printf("No data to transmit\n");
    11ec:	140006e1 	b	2d70 <puts>
    if (alloc_size <= pool->offset) {
    11f0:	eb02009f 	cmp	x4, x2
    11f4:	54fff968 	b.hi	1120 <virtio_console_transmit+0xd0>  // b.pmore
        char* ptr = pool->base;
    11f8:	f9403665 	ldr	x5, [x19, #104]
        for (unsigned long i = 0; i < alloc_size; i++) {
    11fc:	aa0503e2 	mov	x2, x5
    1200:	8b050081 	add	x1, x4, x5
    1204:	14000004 	b	1214 <virtio_console_transmit+0x1c4>
    1208:	91000442 	add	x2, x2, #0x1
    120c:	eb01005f 	cmp	x2, x1
    1210:	54fff9e0 	b.eq	114c <virtio_console_transmit+0xfc>  // b.none
            if (pool->base[i] != 0) {
    1214:	39400043 	ldrb	w3, [x2]
    1218:	34ffff83 	cbz	w3, 1208 <virtio_console_transmit+0x1b8>
    121c:	17ffffc1 	b	1120 <virtio_console_transmit+0xd0>
}
    1220:	a94153f3 	ldp	x19, x20, [sp, #16]
        printf("VirtIO console device is not ready\n");
    1224:	f0000060 	adrp	x0, 10000 <__env_lock>
}
    1228:	a94363f7 	ldp	x23, x24, [sp, #48]
        printf("VirtIO console device is not ready\n");
    122c:	9116c000 	add	x0, x0, #0x5b0
}
    1230:	a8c77bfd 	ldp	x29, x30, [sp], #112
        printf("No data to transmit\n");
    1234:	140006cf 	b	2d70 <puts>
    assert(virtq_has_free_slots(vq));
    1238:	f0000063 	adrp	x3, 10000 <__env_lock>
    123c:	f0000062 	adrp	x2, 10000 <__env_lock>
    1240:	f0000060 	adrp	x0, 10000 <__env_lock>
    1244:	9117c063 	add	x3, x3, #0x5f0
    1248:	911ca042 	add	x2, x2, #0x728
    124c:	91184000 	add	x0, x0, #0x610
    1250:	528017c1 	mov	w1, #0xbe                  	// #190
    1254:	9400062f 	bl	2b10 <__assert_func>
    1258:	d503201f 	nop
    125c:	d503201f 	nop

0000000000001260 <virtio_console_receive>:

bool virtio_console_receive(struct virtio_console* console)
{
    uint32_t interrupt_status = 0;

    if (!console->ready) {
    1260:	3946e001 	ldrb	w1, [x0, #440]
    1264:	360000a1 	tbz	w1, #0, 1278 <virtio_console_receive+0x18>
        return false;
    }

    /* Read and acknowledge interrupts */
    interrupt_status = console->mmio->InterruptStatus;
    1268:	f9404002 	ldr	x2, [x0, #128]
    126c:	b9406041 	ldr	w1, [x2, #96]
    console->mmio->InterruptACK = interrupt_status;
    1270:	b9006441 	str	w1, [x2, #100]

    if (interrupt_status & VIRTIO_MMIO_INT_CONFIG) {
    1274:	36080061 	tbz	w1, #1, 1280 <virtio_console_receive+0x20>
        return false;
    1278:	52800000 	mov	w0, #0x0                   	// #0
        return false;
    }

    /* Return true if there are receive buffers available */
    return virtio_console_rx_has_buffers(console);
}
    127c:	d65f03c0 	ret
{
    1280:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    spin_lock(&console->rx_lock);
    1284:	91068008 	add	x8, x0, #0x1a0
    asm volatile("1:\n\t"
    1288:	52800021 	mov	w1, #0x1                   	// #1
{
    128c:	910003fd 	mov	x29, sp
    1290:	885ffd02 	ldaxr	w2, [x8]
    1294:	35ffffe2 	cbnz	w2, 1290 <virtio_console_receive+0x30>
    1298:	88027d01 	stxr	w2, w1, [x8]
    129c:	35ffffa2 	cbnz	w2, 1290 <virtio_console_receive+0x30>
    12a0:	b90017e2 	str	w2, [sp, #20]
    console->rx_buffer[0] = '\0';
    12a4:	3902501f 	strb	wzr, [x0, #148]
    console->rx_buffer_pos = 0;
    12a8:	f900cc1f 	str	xzr, [x0, #408]
    asm volatile("stlr wzr, %0\n\t" ::"Q"(*lock));
    12ac:	889ffd1f 	stlr	wzr, [x8]
    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++) {
    12b0:	aa0003e1 	mov	x1, x0
    12b4:	52800009 	mov	w9, #0x0                   	// #0
    return vq->used->idx != vq->last_used_idx;
    12b8:	f9400823 	ldr	x3, [x1, #16]
    12bc:	79404022 	ldrh	w2, [x1, #32]
    12c0:	79400464 	ldrh	w4, [x3, #2]
        if (!virtq_used_has_buf(vq)) {
    12c4:	6b24205f 	cmp	w2, w4, uxth
    12c8:	54000b80 	b.eq	1438 <virtio_console_receive+0x1d8>  // b.none
    12cc:	79400464 	ldrh	w4, [x3, #2]
    asm volatile("1:\n\t"
    12d0:	5280002a 	mov	w10, #0x1                   	// #1
    12d4:	528007cc 	mov	w12, #0x3e                  	// #62
            console->rx_buffer[i] = data[i];
    12d8:	d280128b 	mov	x11, #0x94                  	// #148
        while (virtq_used_has_buf(vq)) {
    12dc:	6b24205f 	cmp	w2, w4, uxth
    12e0:	54000ac0 	b.eq	1438 <virtio_console_receive+0x1d8>  // b.none
    12e4:	d503201f 	nop
    12e8:	79400464 	ldrh	w4, [x3, #2]
    return vq->avail->ring[vq->avail_last_idx++ % VIRTQ_SIZE];
}

static inline uint16_t virtq_get_used_buf_id(struct virtq* vq)
{
    assert(virtq_used_has_buf(vq));
    12ec:	6b24205f 	cmp	w2, w4, uxth
    12f0:	54000d80 	b.eq	14a0 <virtio_console_receive+0x240>  // b.none
    return vq->used->ring[vq->last_used_idx++ % VIRTQ_SIZE].id;
    12f4:	d37d2445 	ubfiz	x5, x2, #3, #10
    assert(vq->desc_num_free < VIRTQ_SIZE);
    12f8:	79403824 	ldrh	w4, [x1, #28]
    return vq->used->ring[vq->last_used_idx++ % VIRTQ_SIZE].id;
    12fc:	8b050063 	add	x3, x3, x5
    1300:	11000442 	add	w2, w2, #0x1
    return &vq->desc[id % VIRTQ_SIZE];
    1304:	f9400025 	ldr	x5, [x1]
    return vq->used->ring[vq->last_used_idx++ % VIRTQ_SIZE].id;
    1308:	79004022 	strh	w2, [x1, #32]
    130c:	b9400463 	ldr	w3, [x3, #4]
    1310:	12003c62 	and	w2, w3, #0xffff
    return &vq->desc[id % VIRTQ_SIZE];
    1314:	d37c2463 	ubfiz	x3, x3, #4, #10
    1318:	8b0300a6 	add	x6, x5, x3
    assert(vq->desc_num_free < VIRTQ_SIZE);
    131c:	710ffc9f 	cmp	w4, #0x3ff
    1320:	54000d28 	b.hi	14c4 <virtio_console_receive+0x264>  // b.pmore
    virtq_get_desc_by_id(vq, id)->next = vq->desc_next_free;
    1324:	79403427 	ldrh	w7, [x1, #26]
    vq->desc_num_free++;
    1328:	11000484 	add	w4, w4, #0x1
    virtq_get_desc_by_id(vq, id)->next = vq->desc_next_free;
    132c:	79001cc7 	strh	w7, [x6, #14]
    vq->desc_next_free = id;
    1330:	79003422 	strh	w2, [x1, #26]
    vq->desc_num_free++;
    1334:	79003824 	strh	w4, [x1, #28]
            if (vq_id == VIRTIO_CONSOLE_RX_VQ_IDX) {
    1338:	34000229 	cbz	w9, 137c <virtio_console_receive+0x11c>
            if (!virtio_memory_pool_free(&vq->pool, (char*)desc->addr, desc->len)) {
    133c:	f86368a5 	ldr	x5, [x5, x3]
 */
static inline bool virtio_memory_pool_free(struct virtio_memory_pool* pool, char* ptr,
    unsigned long size)
{
    /** Check if the pointer is within the pool */
    if (ptr < pool->base || ptr >= pool->base + pool->size) {
    1340:	f9401422 	ldr	x2, [x1, #40]
    1344:	b94008c4 	ldr	w4, [x6, #8]
    1348:	eb0200bf 	cmp	x5, x2
    134c:	540000e3 	b.cc	1368 <virtio_console_receive+0x108>  // b.lo, b.ul, b.last
    1350:	f9401826 	ldr	x6, [x1, #48]
    1354:	2a0403e4 	mov	w4, w4
    1358:	8b060043 	add	x3, x2, x6
        return false;
    }

    /** Check if the size is within the pool */
    if (size > pool->size) {
    135c:	eb0300bf 	cmp	x5, x3
    1360:	fa463082 	ccmp	x4, x6, #0x2, cc	// cc = lo, ul, last
    1364:	54000449 	b.ls	13ec <virtio_console_receive+0x18c>  // b.plast
                printf("Failed to free memory from the memory pool\n");
    1368:	f0000060 	adrp	x0, 10000 <__env_lock>
    136c:	911b2000 	add	x0, x0, #0x6c8
    1370:	94000680 	bl	2d70 <puts>
        return false;
    1374:	52800000 	mov	w0, #0x0                   	// #0
    1378:	14000048 	b	1498 <virtio_console_receive+0x238>
                char* msg = (char*)desc->addr;
    137c:	f86368a2 	ldr	x2, [x5, x3]
    1380:	885ffd04 	ldaxr	w4, [x8]
    1384:	35ffffe4 	cbnz	w4, 1380 <virtio_console_receive+0x120>
    1388:	88047d0a 	stxr	w4, w10, [x8]
    138c:	35ffffa4 	cbnz	w4, 1380 <virtio_console_receive+0x120>
    if (console->rx_buffer_pos >= VIRTIO_CONSOLE_RX_CONSOLE_SIZE - VIRTIO_CONSOLE_RX_BUFFER_SIZE) {
    1390:	f940cc0e 	ldr	x14, [x0, #408]
    1394:	b9001be4 	str	w4, [sp, #24]
    1398:	f102fddf 	cmp	x14, #0xbf
    139c:	54000588 	b.hi	144c <virtio_console_receive+0x1ec>  // b.pmore
        for (int i = console->rx_buffer_pos; i < VIRTIO_CONSOLE_RX_BUFFER_SIZE - 1 &&
    13a0:	7100f9df 	cmp	w14, #0x3e
    13a4:	540001cc 	b.gt	13dc <virtio_console_receive+0x17c>
    13a8:	4b0e0187 	sub	w7, w12, w14
            console->rx_buffer[i] = data[i];
    13ac:	cb02016d 	sub	x13, x11, x2
    13b0:	8b0200e7 	add	x7, x7, x2
    13b4:	910005c4 	add	x4, x14, #0x1
    13b8:	8b0400e7 	add	x7, x7, x4
    13bc:	8b0d000d 	add	x13, x0, x13
    13c0:	8b0e0042 	add	x2, x2, x14
    13c4:	d503201f 	nop
    13c8:	39400044 	ldrb	w4, [x2]
    13cc:	382269a4 	strb	w4, [x13, x2]
        for (int i = console->rx_buffer_pos; i < VIRTIO_CONSOLE_RX_BUFFER_SIZE - 1 &&
    13d0:	91000442 	add	x2, x2, #0x1
    13d4:	eb07005f 	cmp	x2, x7
    13d8:	54ffff81 	b.ne	13c8 <virtio_console_receive+0x168>  // b.any
        console->rx_buffer_pos += VIRTIO_CONSOLE_RX_BUFFER_SIZE - 1;
    13dc:	9100fdce 	add	x14, x14, #0x3f
    13e0:	f900cc0e 	str	x14, [x0, #408]
    asm volatile("stlr wzr, %0\n\t" ::"Q"(*lock));
    13e4:	889ffd1f 	stlr	wzr, [x8]
    return success;
    13e8:	17ffffd5 	b	133c <virtio_console_receive+0xdc>
        return false;
    }

    /** Calculate the offset */
    unsigned long offset = ptr - pool->base;
    13ec:	cb0200a3 	sub	x3, x5, x2

    /** Check if the offset is within the pool */
    if (offset < 0 || offset >= pool->size) {
    13f0:	eb0300df 	cmp	x6, x3
    13f4:	54fffba9 	b.ls	1368 <virtio_console_receive+0x108>  // b.plast
        return false;
    }

    /** Free the memory */
    for (unsigned long i = 0; i < size; i++) {
    13f8:	b4000164 	cbz	x4, 1424 <virtio_console_receive+0x1c4>
        pool->base[offset + i] = 0;
    13fc:	390000bf 	strb	wzr, [x5]
    for (unsigned long i = 0; i < size; i++) {
    1400:	91000462 	add	x2, x3, #0x1
    1404:	8b030083 	add	x3, x4, x3
    1408:	f100049f 	cmp	x4, #0x1
    140c:	540000c0 	b.eq	1424 <virtio_console_receive+0x1c4>  // b.none
        pool->base[offset + i] = 0;
    1410:	f9401424 	ldr	x4, [x1, #40]
    1414:	3822689f 	strb	wzr, [x4, x2]
    for (unsigned long i = 0; i < size; i++) {
    1418:	91000442 	add	x2, x2, #0x1
    141c:	eb02007f 	cmp	x3, x2
    1420:	54ffff81 	b.ne	1410 <virtio_console_receive+0x1b0>  // b.any
    return vq->used->idx != vq->last_used_idx;
    1424:	f9400823 	ldr	x3, [x1, #16]
    1428:	79404022 	ldrh	w2, [x1, #32]
    142c:	79400464 	ldrh	w4, [x3, #2]
        while (virtq_used_has_buf(vq)) {
    1430:	6b24205f 	cmp	w2, w4, uxth
    1434:	54fff5a1 	b.ne	12e8 <virtio_console_receive+0x88>  // b.any
    for (int vq_id = 0; vq_id < VIRTIO_CONSOLE_NUM_VQS; vq_id++) {
    1438:	91010021 	add	x1, x1, #0x40
    143c:	52800022 	mov	w2, #0x1                   	// #1
    1440:	350000c9 	cbnz	w9, 1458 <virtio_console_receive+0x1f8>
    1444:	2a0203e9 	mov	w9, w2
    1448:	17ffff9c 	b	12b8 <virtio_console_receive+0x58>
    144c:	889ffd1f 	stlr	wzr, [x8]
        return false;
    1450:	52800000 	mov	w0, #0x0                   	// #0
    1454:	14000011 	b	1498 <virtio_console_receive+0x238>
    asm volatile("1:\n\t"
    1458:	91068001 	add	x1, x0, #0x1a0
    145c:	885ffc23 	ldaxr	w3, [x1]
    1460:	35ffffe3 	cbnz	w3, 145c <virtio_console_receive+0x1fc>
    1464:	88037c22 	stxr	w3, w2, [x1]
    1468:	35ffffa3 	cbnz	w3, 145c <virtio_console_receive+0x1fc>
    if (console->rx_buffer_pos < VIRTIO_CONSOLE_RX_CONSOLE_SIZE - 1) {
    146c:	f940cc01 	ldr	x1, [x0, #408]
    1470:	b9001fe3 	str	w3, [sp, #28]
    1474:	f103f83f 	cmp	x1, #0xfe
    1478:	54fffea8 	b.hi	144c <virtio_console_receive+0x1ec>  // b.pmore
        console->rx_buffer[console->rx_buffer_pos] = '\0';
    147c:	8b010002 	add	x2, x0, x1
        console->rx_buffer_pos++;
    1480:	91000421 	add	x1, x1, #0x1
        console->rx_buffer[console->rx_buffer_pos] = '\0';
    1484:	3902505f 	strb	wzr, [x2, #148]
        console->rx_buffer_pos++;
    1488:	f900cc01 	str	x1, [x0, #408]
    asm volatile("stlr wzr, %0\n\t" ::"Q"(*lock));
    148c:	889ffd1f 	stlr	wzr, [x8]
    return console->rx_buffer_pos > 1;
    1490:	f100043f 	cmp	x1, #0x1
    1494:	1a9f97e0 	cset	w0, hi	// hi = pmore
}
    1498:	a8c27bfd 	ldp	x29, x30, [sp], #32
    149c:	d65f03c0 	ret
    assert(virtq_used_has_buf(vq));
    14a0:	f0000062 	adrp	x2, 10000 <__env_lock>
    14a4:	911ca042 	add	x2, x2, #0x728
    14a8:	f0000063 	adrp	x3, 10000 <__env_lock>
    14ac:	f0000060 	adrp	x0, 10000 <__env_lock>
    14b0:	91006042 	add	x2, x2, #0x18
    14b4:	911a4063 	add	x3, x3, #0x690
    14b8:	91184000 	add	x0, x0, #0x610
    14bc:	52802aa1 	mov	w1, #0x155                 	// #341
    14c0:	94000594 	bl	2b10 <__assert_func>
    assert(vq->desc_num_free < VIRTQ_SIZE);
    14c4:	f0000062 	adrp	x2, 10000 <__env_lock>
    14c8:	911ca042 	add	x2, x2, #0x728
    14cc:	f0000063 	adrp	x3, 10000 <__env_lock>
    14d0:	f0000060 	adrp	x0, 10000 <__env_lock>
    14d4:	9100c042 	add	x2, x2, #0x30
    14d8:	911aa063 	add	x3, x3, #0x6a8
    14dc:	91184000 	add	x0, x0, #0x610
    14e0:	52801981 	mov	w1, #0xcc                  	// #204
    14e4:	9400058b 	bl	2b10 <__assert_func>
    14e8:	d503201f 	nop
    14ec:	d503201f 	nop

00000000000014f0 <virtio_console_rx_get_buffer>:

char* virtio_console_rx_get_buffer(struct virtio_console* console)
{
    return console->rx_buffer;
}
    14f0:	91025000 	add	x0, x0, #0x94
    14f4:	d65f03c0 	ret
    14f8:	d503201f 	nop
    14fc:	d503201f 	nop

0000000000001500 <virtio_console_rx_print_buffer>:

void virtio_console_rx_print_buffer(struct virtio_console* console)
{
    1500:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    asm volatile("1:\n\t"
    1504:	52800021 	mov	w1, #0x1                   	// #1
    1508:	910003fd 	mov	x29, sp
    150c:	f9000bf3 	str	x19, [sp, #16]
    spin_lock(&console->rx_lock);
    1510:	91068013 	add	x19, x0, #0x1a0
    1514:	885ffe62 	ldaxr	w2, [x19]
    1518:	35ffffe2 	cbnz	w2, 1514 <virtio_console_rx_print_buffer+0x14>
    151c:	88027e61 	stxr	w2, w1, [x19]
    1520:	35ffffa2 	cbnz	w2, 1514 <virtio_console_rx_print_buffer+0x14>
    printf("Received message on the VirtIO console: %s\n", console->rx_buffer);
    1524:	f0000063 	adrp	x3, 10000 <__env_lock>
    1528:	91025001 	add	x1, x0, #0x94
    152c:	911be060 	add	x0, x3, #0x6f8
    1530:	b9002fe2 	str	w2, [sp, #44]
    1534:	940005b3 	bl	2c00 <printf>
    asm volatile("stlr wzr, %0\n\t" ::"Q"(*lock));
    1538:	889ffe7f 	stlr	wzr, [x19]
    spin_unlock(&console->rx_lock);
}
    153c:	f9400bf3 	ldr	x19, [sp, #16]
    1540:	a8c37bfd 	ldp	x29, x30, [sp], #48
    1544:	d65f03c0 	ret
	...

0000000000001550 <uart_init>:
#include <zynq_uart.h>

Xil_Uart* uart = (void*)UART_ADDR;

void uart_init(void)
{
    1550:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    1554:	910003fd 	mov	x29, sp
    1558:	f9000bf3 	str	x19, [sp, #16]
    xil_uart_init(uart);
    155c:	90000093 	adrp	x19, 11000 <JIS_action_table>
    1560:	f9412e60 	ldr	x0, [x19, #600]
    1564:	94000023 	bl	15f0 <xil_uart_init>
    xil_uart_enable(uart);
    1568:	f9412e60 	ldr	x0, [x19, #600]

    return;
}
    156c:	f9400bf3 	ldr	x19, [sp, #16]
    1570:	a8c27bfd 	ldp	x29, x30, [sp], #32
    xil_uart_enable(uart);
    1574:	14000037 	b	1650 <xil_uart_enable>
    1578:	d503201f 	nop
    157c:	d503201f 	nop

0000000000001580 <uart_putc>:

void uart_putc(char c)
{
    xil_uart_putc(uart, c);
    1580:	90000082 	adrp	x2, 11000 <JIS_action_table>
    1584:	2a0003e1 	mov	w1, w0
    1588:	f9412c40 	ldr	x0, [x2, #600]
    158c:	1400004d 	b	16c0 <xil_uart_putc>

0000000000001590 <uart_getchar>:
}

char uart_getchar(void)
{
    1590:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    return xil_uart_getc(uart);
    1594:	90000080 	adrp	x0, 11000 <JIS_action_table>
{
    1598:	910003fd 	mov	x29, sp
    return xil_uart_getc(uart);
    159c:	f9412c00 	ldr	x0, [x0, #600]
    15a0:	94000041 	bl	16a4 <xil_uart_getc>
}
    15a4:	a8c17bfd 	ldp	x29, x30, [sp], #16
    15a8:	d65f03c0 	ret
    15ac:	d503201f 	nop

00000000000015b0 <uart_enable_rxirq>:

void uart_enable_rxirq()
{
    xil_uart_enable_irq(uart, UART_ISR_EN_RTRIG);
    15b0:	90000080 	adrp	x0, 11000 <JIS_action_table>
    15b4:	52800021 	mov	w1, #0x1                   	// #1
    15b8:	f9412c00 	ldr	x0, [x0, #600]
    15bc:	14000055 	b	1710 <xil_uart_enable_irq>

00000000000015c0 <uart_clear_rxirq>:
}

void uart_clear_rxirq()
{
    15c0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    15c4:	910003fd 	mov	x29, sp
    15c8:	f9000bf3 	str	x19, [sp, #16]
    xil_uart_clear_rxbuf(uart);
    15cc:	90000093 	adrp	x19, 11000 <JIS_action_table>
    15d0:	f9412e60 	ldr	x0, [x19, #600]
    15d4:	94000057 	bl	1730 <xil_uart_clear_rxbuf>
    xil_uart_clear_irq(uart, 0xFFFFFFFF);
    15d8:	f9412e60 	ldr	x0, [x19, #600]
    15dc:	12800001 	mov	w1, #0xffffffff            	// #-1
}
    15e0:	f9400bf3 	ldr	x19, [sp, #16]
    15e4:	a8c27bfd 	ldp	x29, x30, [sp], #32
    xil_uart_clear_irq(uart, 0xFFFFFFFF);
    15e8:	1400004f 	b	1724 <xil_uart_clear_irq>
    15ec:	00000000 	udf	#0

00000000000015f0 <xil_uart_init>:
 */

#include <zynq_uart.h>

bool xil_uart_init(Xil_Uart* uart)
{
    15f0:	aa0003e1 	mov	x1, x0
    bdiv = UART_BDIV_115200;
    cd_calc = UART_CD_115200;

    /** Configure the Baud Rate */
    /* Disable the Rx and Tx path */
    uart->control = (UART_CONTROL_RXDIS | UART_CONTROL_TXDIS);
    15f4:	52800504 	mov	w4, #0x28                  	// #40
    /* Write the calculated CD value */
    uart->br_gen = cd_calc;
    15f8:	528011e0 	mov	w0, #0x8f                  	// #143
    /* Write the calculated BDIV value */
    uart->br_div = bdiv;
    15fc:	528000a3 	mov	w3, #0x5                   	// #5
    /* Reset Tx and Rx paths */
    uart->control = (UART_CONTROL_TXRES | UART_CONTROL_RXRES);
    1600:	52800066 	mov	w6, #0x3                   	// #3
    /* Enable the Rx and Tx path */
    uart->control = (UART_CONTROL_TXEN | UART_CONTROL_RXEN);
    1604:	52800285 	mov	w5, #0x14                  	// #20
    uart->control = (UART_CONTROL_RXDIS | UART_CONTROL_TXDIS);
    1608:	b9000024 	str	w4, [x1]
    uart->rx_fifo_trig = UART_RX_TRIGGER_LVL;
    160c:	52800022 	mov	w2, #0x1                   	// #1
    uart->br_gen = cd_calc;
    1610:	b9001820 	str	w0, [x1, #24]
    uart->isr_status = 0xFFFFFFFF;
    1614:	12800004 	mov	w4, #0xffffffff            	// #-1
    uart->br_div = bdiv;
    1618:	b9003423 	str	w3, [x1, #52]
}
    161c:	2a0203e0 	mov	w0, w2
    uart->control = (UART_CONTROL_TXRES | UART_CONTROL_RXRES);
    1620:	b9000026 	str	w6, [x1]
    uart->control |= (UART_CONTROL_STPBRK | UART_CONTROL_RXRES | UART_CONTROL_TXRES);
    1624:	52802063 	mov	w3, #0x103                 	// #259
    uart->control = (UART_CONTROL_TXEN | UART_CONTROL_RXEN);
    1628:	b9000025 	str	w5, [x1]
    uart->rx_fifo_trig = UART_RX_TRIGGER_LVL;
    162c:	b9002022 	str	w2, [x1, #32]
    uart->rx_timeout = UART_RX_TIMEOUT_DIS;
    1630:	b9001c3f 	str	wzr, [x1, #28]
    uart->isr_status = 0xFFFFFFFF;
    1634:	b9001424 	str	w4, [x1, #20]
    uart->isr_en = UART_ISR_EN_RTRIG;
    1638:	b9000822 	str	w2, [x1, #8]
    uart->control |= (UART_CONTROL_STPBRK | UART_CONTROL_RXRES | UART_CONTROL_TXRES);
    163c:	b9400022 	ldr	w2, [x1]
    1640:	2a030042 	orr	w2, w2, w3
    1644:	b9000022 	str	w2, [x1]
}
    1648:	d65f03c0 	ret
    164c:	d503201f 	nop

0000000000001650 <xil_uart_enable>:
    uint32_t ctrl_reg = uart->control;
    1650:	b9400002 	ldr	w2, [x0]
    uart->control = ctrl_reg;
    1654:	528022e1 	mov	w1, #0x117                 	// #279
    1658:	b9000001 	str	w1, [x0]
}
    165c:	d65f03c0 	ret

0000000000001660 <xil_uart_disable>:
    uint32_t ctrl_reg = uart->control;
    1660:	b9400002 	ldr	w2, [x0]
    uart->control = ctrl_reg;
    1664:	52802501 	mov	w1, #0x128                 	// #296
    1668:	b9000001 	str	w1, [x0]
}
    166c:	d65f03c0 	ret

0000000000001670 <xil_uart_set_baud_rate>:
{
    1670:	aa0003e1 	mov	x1, x0
    uart->control = (UART_CONTROL_RXDIS | UART_CONTROL_TXDIS);
    1674:	52800506 	mov	w6, #0x28                  	// #40
    uart->br_gen = cd_calc;
    1678:	528011e5 	mov	w5, #0x8f                  	// #143
    uart->br_div = bdiv;
    167c:	528000a4 	mov	w4, #0x5                   	// #5
    uart->control = (UART_CONTROL_TXRES | UART_CONTROL_RXRES);
    1680:	52800063 	mov	w3, #0x3                   	// #3
    uart->control = (UART_CONTROL_TXEN | UART_CONTROL_RXEN);
    1684:	52800282 	mov	w2, #0x14                  	// #20
    uart->control = (UART_CONTROL_RXDIS | UART_CONTROL_TXDIS);
    1688:	b9000026 	str	w6, [x1]

    return true;
}
    168c:	52800020 	mov	w0, #0x1                   	// #1
    uart->br_gen = cd_calc;
    1690:	b9001825 	str	w5, [x1, #24]
    uart->br_div = bdiv;
    1694:	b9003424 	str	w4, [x1, #52]
    uart->control = (UART_CONTROL_TXRES | UART_CONTROL_RXRES);
    1698:	b9000023 	str	w3, [x1]
    uart->control = (UART_CONTROL_TXEN | UART_CONTROL_RXEN);
    169c:	b9000022 	str	w2, [x1]
}
    16a0:	d65f03c0 	ret

00000000000016a4 <xil_uart_getc>:

uint32_t xil_uart_getc(Xil_Uart* uart)
{
    16a4:	d503201f 	nop
    uint32_t data = 0;

    // Chose one of the following: (Trigger Level or Not Empty)
    /* Wait until RxFIFO is filled up to the trigger level */
    while (!uart->ch_status & UART_CH_STATUS_RTRIG)
    16a8:	b9402c01 	ldr	w1, [x0, #44]
    16ac:	34ffffe1 	cbz	w1, 16a8 <xil_uart_getc+0x4>
        ;
    /* Wait until RxFIFO is not empty */
    // while(!uart->ch_status & UART_CH_STATUS_REMPTY);

    data = uart->tx_rx_fifo;
    16b0:	b9403000 	ldr	w0, [x0, #48]

    return data;
}
    16b4:	d65f03c0 	ret
    16b8:	d503201f 	nop
    16bc:	d503201f 	nop

00000000000016c0 <xil_uart_putc>:

void xil_uart_putc(Xil_Uart* uart, int8_t c)
{
    16c0:	13001c21 	sxtb	w1, w1
    /* Wait until txFIFO is not full */
    while (uart->ch_status & UART_CH_STATUS_TFUL)
    16c4:	d503201f 	nop
    16c8:	b9402c02 	ldr	w2, [x0, #44]
    16cc:	3727ffe2 	tbnz	w2, #4, 16c8 <xil_uart_putc+0x8>
        ;

    uart->tx_rx_fifo = c;
    16d0:	b9003001 	str	w1, [x0, #48]
}
    16d4:	d65f03c0 	ret
    16d8:	d503201f 	nop
    16dc:	d503201f 	nop

00000000000016e0 <xil_uart_puts>:

void xil_uart_puts(Xil_Uart* uart, const char* s)
{
    while (*s) {
    16e0:	39400022 	ldrb	w2, [x1]
    16e4:	34000102 	cbz	w2, 1704 <xil_uart_puts+0x24>
        xil_uart_putc(uart, *s++);
    16e8:	91000421 	add	x1, x1, #0x1
    16ec:	13001c43 	sxtb	w3, w2
    while (uart->ch_status & UART_CH_STATUS_TFUL)
    16f0:	b9402c02 	ldr	w2, [x0, #44]
    16f4:	3727ffe2 	tbnz	w2, #4, 16f0 <xil_uart_puts+0x10>
    uart->tx_rx_fifo = c;
    16f8:	b9003003 	str	w3, [x0, #48]
    while (*s) {
    16fc:	39400022 	ldrb	w2, [x1]
    1700:	35ffff42 	cbnz	w2, 16e8 <xil_uart_puts+0x8>
    }
}
    1704:	d65f03c0 	ret
    1708:	d503201f 	nop
    170c:	d503201f 	nop

0000000000001710 <xil_uart_enable_irq>:

void xil_uart_enable_irq(Xil_Uart* uart, uint32_t irq)
{
    uart->isr_en = irq;
    1710:	b9000801 	str	w1, [x0, #8]
    uart->isr_mask |= irq;
    1714:	b9401002 	ldr	w2, [x0, #16]
    1718:	2a010041 	orr	w1, w2, w1
    171c:	b9001001 	str	w1, [x0, #16]
}
    1720:	d65f03c0 	ret

0000000000001724 <xil_uart_clear_irq>:

void xil_uart_clear_irq(Xil_Uart* uart, uint32_t irq)
{
    uart->isr_status = irq;
    1724:	b9001401 	str	w1, [x0, #20]
}
    1728:	d65f03c0 	ret
    172c:	d503201f 	nop

0000000000001730 <xil_uart_clear_rxbuf>:

void xil_uart_clear_rxbuf(Xil_Uart* uart)
{
    while (uart->ch_status & UART_CH_STATUS_RTRIG) {
    1730:	b9402c01 	ldr	w1, [x0, #44]
    1734:	360000c1 	tbz	w1, #0, 174c <xil_uart_clear_rxbuf+0x1c>
    while (!uart->ch_status & UART_CH_STATUS_RTRIG)
    1738:	b9402c01 	ldr	w1, [x0, #44]
    173c:	34ffffe1 	cbz	w1, 1738 <xil_uart_clear_rxbuf+0x8>
    data = uart->tx_rx_fifo;
    1740:	b9403001 	ldr	w1, [x0, #48]
    while (uart->ch_status & UART_CH_STATUS_RTRIG) {
    1744:	b9402c01 	ldr	w1, [x0, #44]
    1748:	3707ff81 	tbnz	w1, #0, 1738 <xil_uart_clear_rxbuf+0x8>
        (void)xil_uart_getc(uart);
    }
}
    174c:	d65f03c0 	ret

0000000000001750 <arch_init>:
#include <sysregs.h>

void _start();

__attribute__((weak)) void arch_init()
{
    1750:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    1754:	910003fd 	mov	x29, sp
    1758:	a90153f3 	stp	x19, x20, [sp, #16]
SYSREG_GEN_ACCESSORS(clidr_el1);
SYSREG_GEN_ACCESSORS(csselr_el1);
SYSREG_GEN_ACCESSORS(ccsidr_el1);
SYSREG_GEN_ACCESSORS(ccsidr2_el1);
SYSREG_GEN_ACCESSORS(ctr_el0);
SYSREG_GEN_ACCESSORS(mpidr_el1);
    175c:	d53800b3 	mrs	x19, mpidr_el1
    unsigned long cpuid = get_cpuid();
    gic_init();
    1760:	940000bd 	bl	1a54 <gic_init>
#include <sysregs.h>

static inline unsigned long get_cpuid()
{
    unsigned long cpuid = sysreg_mpidr_el1_read();
    return cpuid & MPIDR_CPU_MASK;
    1764:	92401e73 	and	x19, x19, #0xff
SYSREG_GEN_ACCESSORS(ttbr0_el1);
SYSREG_GEN_ACCESSORS(mair_el1);
SYSREG_GEN_ACCESSORS(cptr_el1);
SYSREG_GEN_ACCESSORS(id_aa64mmfr0_el1);
SYSREG_GEN_ACCESSORS(tpidr_el1);
SYSREG_GEN_ACCESSORS(cntfrq_el0);
    1768:	d53be001 	mrs	x1, cntfrq_el0
    TIMER_FREQ = timer_get_freq();
    176c:	b0000800 	adrp	x0, 102000 <init_lock>
    1770:	f9000401 	str	x1, [x0, #8]
SYSREG_GEN_ACCESSORS(cntv_ctl_el0);
    1774:	d53be320 	mrs	x0, cntv_ctl_el0
static inline void timer_int_en(bool en)
{
    if (en) {
        sysreg_cntv_ctl_el0_write(sysreg_cntv_ctl_el0_read() & ~CNTV_CTL_IMASK);
    } else {
        sysreg_cntv_ctl_el0_write(sysreg_cntv_ctl_el0_read() | CNTV_CTL_IMASK);
    1778:	b27f0000 	orr	x0, x0, #0x2
    177c:	d51be320 	msr	cntv_ctl_el0, x0
    timer_int_en(false);

#if !(defined(SINGLE_CORE) || defined(NO_FIRMWARE))
    if (cpuid == 0) {
    1780:	b50001d3 	cbnz	x19, 17b8 <arch_init+0x68>
    1784:	f0fffff4 	adrp	x20, 0 <_start>
    1788:	91000294 	add	x20, x20, #0x0
    178c:	f90013f5 	str	x21, [sp, #32]
    1790:	d2800035 	mov	x21, #0x1                   	// #1
        size_t i = 0;
        int ret = PSCI_E_SUCCESS;
        do {
            if (i == cpuid) {
    1794:	f100027f 	cmp	x19, #0x0
                continue;
            }
            ret = psci_cpu_on(i, (uintptr_t)_start, 0);
    1798:	aa1403e1 	mov	x1, x20
    179c:	9a951273 	csel	x19, x19, x21, ne	// ne = any
    17a0:	d2800002 	mov	x2, #0x0                   	// #0
    17a4:	aa1303e0 	mov	x0, x19
        } while (i++, ret == PSCI_E_SUCCESS);
    17a8:	91000673 	add	x19, x19, #0x1
            ret = psci_cpu_on(i, (uintptr_t)_start, 0);
    17ac:	94000021 	bl	1830 <psci_cpu_on>
        } while (i++, ret == PSCI_E_SUCCESS);
    17b0:	34ffff20 	cbz	w0, 1794 <arch_init+0x44>
    17b4:	f94013f5 	ldr	x21, [sp, #32]
    asm volatile("at s12e1w, %0" ::"r"(vaddr));
}

static inline void arm_unmask_irq()
{
    asm volatile("MSR   DAIFClr, #2\n\t");
    17b8:	d50342ff 	msr	daifclr, #0x2
    }
#endif
    arm_unmask_irq();
}
    17bc:	a94153f3 	ldp	x19, x20, [sp, #16]
    17c0:	a8c37bfd 	ldp	x29, x30, [sp], #48
    17c4:	d65f03c0 	ret
	...

00000000000017d0 <smc_call>:
    register unsigned long r0 asm("r0") = x0;
    register unsigned long r1 asm("r1") = x1;
    register unsigned long r2 asm("r2") = x2;
    register unsigned long r3 asm("r3") = x3;

    asm volatile(XSTR(PSCI_CONDUIT) " #0\n" : "=r"(r0) : "r"(r0), "r"(r1), "r"(r2) : "r3");
    17d0:	d4000003 	smc	#0x0

    return r0;
}
    17d4:	d65f03c0 	ret
    17d8:	d503201f 	nop
    17dc:	d503201f 	nop

00000000000017e0 <psci_version>:
    register unsigned long r0 asm("r0") = x0;
    17e0:	d2b08000 	mov	x0, #0x84000000            	// #2214592512
    register unsigned long r1 asm("r1") = x1;
    17e4:	d2800001 	mov	x1, #0x0                   	// #0
    register unsigned long r2 asm("r2") = x2;
    17e8:	d2800002 	mov	x2, #0x0                   	// #0
    asm volatile(XSTR(PSCI_CONDUIT) " #0\n" : "=r"(r0) : "r"(r0), "r"(r1), "r"(r2) : "r3");
    17ec:	d4000003 	smc	#0x0
--------------------------------- */

int32_t psci_version(void)
{
    return smc_call(PSCI_VERSION, 0, 0, 0);
}
    17f0:	d65f03c0 	ret

00000000000017f4 <psci_cpu_suspend>:

int32_t psci_cpu_suspend(uint32_t power_state, uintptr_t entrypoint, unsigned long context_id)
{
    17f4:	2a0003e3 	mov	w3, w0
    register unsigned long r0 asm("r0") = x0;
    17f8:	d2800020 	mov	x0, #0x1                   	// #1
{
    17fc:	aa0103e2 	mov	x2, x1
    register unsigned long r0 asm("r0") = x0;
    1800:	f2b88000 	movk	x0, #0xc400, lsl #16
    register unsigned long r1 asm("r1") = x1;
    1804:	2a0303e1 	mov	w1, w3
    asm volatile(XSTR(PSCI_CONDUIT) " #0\n" : "=r"(r0) : "r"(r0), "r"(r1), "r"(r2) : "r3");
    1808:	d4000003 	smc	#0x0
    return smc_call(PSCI_CPU_SUSPEND, power_state, entrypoint, context_id);
}
    180c:	d65f03c0 	ret

0000000000001810 <psci_cpu_off>:
    register unsigned long r0 asm("r0") = x0;
    1810:	d2800040 	mov	x0, #0x2                   	// #2
    register unsigned long r1 asm("r1") = x1;
    1814:	d2800001 	mov	x1, #0x0                   	// #0
    register unsigned long r0 asm("r0") = x0;
    1818:	f2b08000 	movk	x0, #0x8400, lsl #16
    register unsigned long r2 asm("r2") = x2;
    181c:	d2800002 	mov	x2, #0x0                   	// #0
    asm volatile(XSTR(PSCI_CONDUIT) " #0\n" : "=r"(r0) : "r"(r0), "r"(r1), "r"(r2) : "r3");
    1820:	d4000003 	smc	#0x0

int32_t psci_cpu_off(void)
{
    return smc_call(PSCI_CPU_OFF, 0, 0, 0);
}
    1824:	d65f03c0 	ret
    1828:	d503201f 	nop
    182c:	d503201f 	nop

0000000000001830 <psci_cpu_on>:

int32_t psci_cpu_on(unsigned long target_cpu, uintptr_t entrypoint, unsigned long context_id)
{
    1830:	aa0003e3 	mov	x3, x0
    register unsigned long r0 asm("r0") = x0;
    1834:	d2800060 	mov	x0, #0x3                   	// #3
{
    1838:	aa0103e2 	mov	x2, x1
    register unsigned long r0 asm("r0") = x0;
    183c:	f2b88000 	movk	x0, #0xc400, lsl #16
    register unsigned long r1 asm("r1") = x1;
    1840:	aa0303e1 	mov	x1, x3
    asm volatile(XSTR(PSCI_CONDUIT) " #0\n" : "=r"(r0) : "r"(r0), "r"(r1), "r"(r2) : "r3");
    1844:	d4000003 	smc	#0x0
    return smc_call(PSCI_CPU_ON, target_cpu, entrypoint, context_id);
}
    1848:	d65f03c0 	ret
    184c:	d503201f 	nop

0000000000001850 <psci_affinity_info>:

int32_t psci_affinity_info(unsigned long target_affinity, uint32_t lowest_affinity_level)
{
    1850:	aa0003e3 	mov	x3, x0
    register unsigned long r0 asm("r0") = x0;
    1854:	d2800080 	mov	x0, #0x4                   	// #4
{
    1858:	2a0103e2 	mov	w2, w1
    register unsigned long r0 asm("r0") = x0;
    185c:	f2b88000 	movk	x0, #0xc400, lsl #16
    register unsigned long r1 asm("r1") = x1;
    1860:	aa0303e1 	mov	x1, x3
    asm volatile(XSTR(PSCI_CONDUIT) " #0\n" : "=r"(r0) : "r"(r0), "r"(r1), "r"(r2) : "r3");
    1864:	d4000003 	smc	#0x0
    return smc_call(PSCI_AFFINITY_INFO, target_affinity, lowest_affinity_level, 0);
}
    1868:	d65f03c0 	ret
    186c:	00000000 	udf	#0

0000000000001870 <irq_enable>:
#ifndef GIC_VERSION
#error "GIC_VERSION not defined for this platform"
#endif

void irq_enable(unsigned id)
{
    1870:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    gic_set_enable(id, true);
    1874:	52800021 	mov	w1, #0x1                   	// #1
{
    1878:	910003fd 	mov	x29, sp
    187c:	f9000bf3 	str	x19, [sp, #16]
    gic_set_enable(id, true);
    1880:	2a0003f3 	mov	w19, w0
    1884:	aa1303e0 	mov	x0, x19
    1888:	9400007e 	bl	1a80 <gic_set_enable>
    if (GIC_VERSION == GICV2) {
        gic_set_trgt(id, gic_get_trgt(id) | (1 << get_cpuid()));
    188c:	aa1303e0 	mov	x0, x19
    1890:	940000b8 	bl	1b70 <gic_get_trgt>
    1894:	12001c02 	and	w2, w0, #0xff
SYSREG_GEN_ACCESSORS(mpidr_el1);
    1898:	d53800a3 	mrs	x3, mpidr_el1
    189c:	aa1303e0 	mov	x0, x19
    18a0:	52800021 	mov	w1, #0x1                   	// #1
    } else {
        gic_set_route(id, get_cpuid());
    }
}
    18a4:	f9400bf3 	ldr	x19, [sp, #16]
        gic_set_trgt(id, gic_get_trgt(id) | (1 << get_cpuid()));
    18a8:	1ac32021 	lsl	w1, w1, w3
}
    18ac:	a8c27bfd 	ldp	x29, x30, [sp], #32
        gic_set_trgt(id, gic_get_trgt(id) | (1 << get_cpuid()));
    18b0:	2a010041 	orr	w1, w2, w1
    18b4:	14000093 	b	1b00 <gic_set_trgt>
    18b8:	d503201f 	nop
    18bc:	d503201f 	nop

00000000000018c0 <irq_set_prio>:

void irq_set_prio(unsigned id, unsigned prio)
{
    gic_set_prio(id, (uint8_t)prio);
    18c0:	2a0003e0 	mov	w0, w0
    18c4:	140000c0 	b	1bc4 <gic_set_prio>
    18c8:	d503201f 	nop
    18cc:	d503201f 	nop

00000000000018d0 <irq_send_ipi>:
}

void irq_send_ipi(unsigned long target_cpu_mask)
{
    18d0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    18d4:	910003fd 	mov	x29, sp
    18d8:	a90153f3 	stp	x19, x20, [sp, #16]
    18dc:	aa0003f4 	mov	x20, x0
    18e0:	d2800013 	mov	x19, #0x0                   	// #0
    18e4:	14000004 	b	18f4 <irq_send_ipi+0x24>
    for (int i = 0; i < sizeof(target_cpu_mask) * 8; i++) {
    18e8:	91000673 	add	x19, x19, #0x1
    18ec:	f101027f 	cmp	x19, #0x40
    18f0:	54000120 	b.eq	1914 <irq_send_ipi+0x44>  // b.none
        if (target_cpu_mask & (1ull << i)) {
    18f4:	9ad32681 	lsr	x1, x20, x19
    18f8:	3607ff81 	tbz	w1, #0, 18e8 <irq_send_ipi+0x18>
            gic_send_sgi(i, IPI_IRQ_ID);
    18fc:	aa1303e0 	mov	x0, x19
    1900:	d2800001 	mov	x1, #0x0                   	// #0
    for (int i = 0; i < sizeof(target_cpu_mask) * 8; i++) {
    1904:	91000673 	add	x19, x19, #0x1
            gic_send_sgi(i, IPI_IRQ_ID);
    1908:	940000a6 	bl	1ba0 <gic_send_sgi>
    for (int i = 0; i < sizeof(target_cpu_mask) * 8; i++) {
    190c:	f101027f 	cmp	x19, #0x40
    1910:	54ffff21 	b.ne	18f4 <irq_send_ipi+0x24>  // b.any
        }
    }
}
    1914:	a94153f3 	ldp	x19, x20, [sp, #16]
    1918:	a8c27bfd 	ldp	x29, x30, [sp], #32
    191c:	d65f03c0 	ret

0000000000001920 <gicc_init>:
    for (int i = 0; i < GIC_NUM_INT_REGS(GIC_CPU_PRIV); i++) {
        /**
         * Make sure all private interrupts are not enabled, non pending,
         * non active.
         */
        gicd->ICENABLER[i] = -1;
    1920:	90000081 	adrp	x1, 11000 <JIS_action_table>
    1924:	91098022 	add	x2, x1, #0x260
    1928:	12800000 	mov	w0, #0xffffffff            	// #-1
    192c:	f9413021 	ldr	x1, [x1, #608]

    for (int i = 0; i < GIC_NUM_PRIO_REGS(GIC_CPU_PRIV); i++) {
        gicd->IPRIORITYR[i] = -1;
    }

    gicc->PMR = -1;
    1930:	f9400442 	ldr	x2, [x2, #8]
        gicd->ICENABLER[i] = -1;
    1934:	b9018020 	str	w0, [x1, #384]
        gicd->ICPENDR[i] = -1;
    1938:	b9028020 	str	w0, [x1, #640]
        gicd->ICACTIVER[i] = -1;
    193c:	b9038020 	str	w0, [x1, #896]
        gicd->CPENDSGIR[i] = -1;
    1940:	b90f1020 	str	w0, [x1, #3856]
    1944:	b90f1420 	str	w0, [x1, #3860]
    1948:	b90f1820 	str	w0, [x1, #3864]
    194c:	b90f1c20 	str	w0, [x1, #3868]
        gicd->IPRIORITYR[i] = -1;
    1950:	b9040020 	str	w0, [x1, #1024]
    1954:	b9040420 	str	w0, [x1, #1028]
    1958:	b9040820 	str	w0, [x1, #1032]
    195c:	b9040c20 	str	w0, [x1, #1036]
    1960:	b9041020 	str	w0, [x1, #1040]
    1964:	b9041420 	str	w0, [x1, #1044]
    1968:	b9041820 	str	w0, [x1, #1048]
    196c:	b9041c20 	str	w0, [x1, #1052]
        gicd->IPRIORITYR[i] = -1;
    1970:	b9040020 	str	w0, [x1, #1024]
    1974:	b9040420 	str	w0, [x1, #1028]
    1978:	b9040820 	str	w0, [x1, #1032]
    197c:	b9040c20 	str	w0, [x1, #1036]
    1980:	b9041020 	str	w0, [x1, #1040]
    1984:	b9041420 	str	w0, [x1, #1044]
    1988:	b9041820 	str	w0, [x1, #1048]
    198c:	b9041c20 	str	w0, [x1, #1052]
    gicc->PMR = -1;
    1990:	b9000440 	str	w0, [x2, #4]
    gicc->CTLR |= GICC_CTLR_EN_BIT;
    1994:	b9400040 	ldr	w0, [x2]
    1998:	32000000 	orr	w0, w0, #0x1
    199c:	b9000040 	str	w0, [x2]
}
    19a0:	d65f03c0 	ret

00000000000019a4 <gicd_init>:
    return ((gicd->TYPER &
    19a4:	90000080 	adrp	x0, 11000 <JIS_action_table>
    19a8:	f9413000 	ldr	x0, [x0, #608]
    19ac:	b9400404 	ldr	w4, [x0, #4]
    19b0:	12001084 	and	w4, w4, #0x1f
    19b4:	11000485 	add	w5, w4, #0x1
    19b8:	aa0503e4 	mov	x4, x5
void gicd_init()
{
    size_t int_num = gic_num_int();

    /* Bring distributor to known state */
    for (int i = GIC_NUM_PRIVINT_REGS; i < GIC_NUM_INT_REGS(int_num); i++) {
    19bc:	f10004bf 	cmp	x5, #0x1
    19c0:	54000160 	b.eq	19ec <gicd_init+0x48>  // b.none
    19c4:	52800021 	mov	w1, #0x1                   	// #1
        /**
         * Make sure all interrupts are not enabled, non pending,
         * non active.
         */
        gicd->ICENABLER[i] = -1;
    19c8:	12800003 	mov	w3, #0xffffffff            	// #-1
    19cc:	d503201f 	nop
    19d0:	8b21c802 	add	x2, x0, w1, sxtw #2
    for (int i = GIC_NUM_PRIVINT_REGS; i < GIC_NUM_INT_REGS(int_num); i++) {
    19d4:	11000421 	add	w1, w1, #0x1
        gicd->ICENABLER[i] = -1;
    19d8:	b9018043 	str	w3, [x2, #384]
        gicd->ICPENDR[i] = -1;
    19dc:	b9028043 	str	w3, [x2, #640]
        gicd->ICACTIVER[i] = -1;
    19e0:	b9038043 	str	w3, [x2, #896]
    for (int i = GIC_NUM_PRIVINT_REGS; i < GIC_NUM_INT_REGS(int_num); i++) {
    19e4:	6b01009f 	cmp	w4, w1
    19e8:	54ffff41 	b.ne	19d0 <gicd_init+0x2c>  // b.any
    19ec:	531d70a2 	lsl	w2, w5, #3
    }

    /* All interrupts have lowest priority possible by default */
    for (int i = 0; i < GIC_NUM_PRIO_REGS(int_num); i++) {
    19f0:	52800001 	mov	w1, #0x0                   	// #0
        gicd->IPRIORITYR[i] = -1;
    19f4:	12800004 	mov	w4, #0xffffffff            	// #-1
    19f8:	8b21c803 	add	x3, x0, w1, sxtw #2
    for (int i = 0; i < GIC_NUM_PRIO_REGS(int_num); i++) {
    19fc:	11000421 	add	w1, w1, #0x1
        gicd->IPRIORITYR[i] = -1;
    1a00:	b9040064 	str	w4, [x3, #1024]
    for (int i = 0; i < GIC_NUM_PRIO_REGS(int_num); i++) {
    1a04:	6b02003f 	cmp	w1, w2
    1a08:	54ffff81 	b.ne	19f8 <gicd_init+0x54>  // b.any
    }

    /* No CPU targets for any interrupt by default */
    for (int i = 0; i < GIC_NUM_TARGET_REGS(int_num); i++) {
    1a0c:	52800001 	mov	w1, #0x0                   	// #0
        gicd->ITARGETSR[i] = 0;
    1a10:	8b21c803 	add	x3, x0, w1, sxtw #2
    for (int i = 0; i < GIC_NUM_TARGET_REGS(int_num); i++) {
    1a14:	11000421 	add	w1, w1, #0x1
        gicd->ITARGETSR[i] = 0;
    1a18:	b908007f 	str	wzr, [x3, #2048]
    for (int i = 0; i < GIC_NUM_TARGET_REGS(int_num); i++) {
    1a1c:	6b02003f 	cmp	w1, w2
    1a20:	54ffff81 	b.ne	1a10 <gicd_init+0x6c>  // b.any
    1a24:	531f78a3 	lsl	w3, w5, #1
    }

    /* No CPU targets for any interrupt by default */
    for (int i = 0; i < GIC_NUM_CONFIG_REGS(int_num); i++) {
    1a28:	52800001 	mov	w1, #0x0                   	// #0
        gicd->ICFGR[i] = 0xAAAAAAAA;
    1a2c:	3201f3e4 	mov	w4, #0xaaaaaaaa            	// #-1431655766
    1a30:	8b21c802 	add	x2, x0, w1, sxtw #2
    for (int i = 0; i < GIC_NUM_CONFIG_REGS(int_num); i++) {
    1a34:	11000421 	add	w1, w1, #0x1
        gicd->ICFGR[i] = 0xAAAAAAAA;
    1a38:	b90c0044 	str	w4, [x2, #3072]
    for (int i = 0; i < GIC_NUM_CONFIG_REGS(int_num); i++) {
    1a3c:	6b03003f 	cmp	w1, w3
    1a40:	54ffff81 	b.ne	1a30 <gicd_init+0x8c>  // b.any
    }

    /* No need to setup gicd->NSACR as all interrupts are  setup to group 1 */

    /* Enable distributor */
    gicd->CTLR |= GICD_CTLR_EN_BIT;
    1a44:	b9400001 	ldr	w1, [x0]
    1a48:	32000021 	orr	w1, w1, #0x1
    1a4c:	b9000001 	str	w1, [x0]
}
    1a50:	d65f03c0 	ret

0000000000001a54 <gic_init>:
    1a54:	d53800a0 	mrs	x0, mpidr_el1

void gic_init()
{
    if (get_cpuid() == 0) {
    1a58:	72001c1f 	tst	w0, #0xff
    1a5c:	54000040 	b.eq	1a64 <gic_init+0x10>  // b.none
        gicd_init();
    }
    gicc_init();
    1a60:	17ffffb0 	b	1920 <gicc_init>
{
    1a64:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    1a68:	910003fd 	mov	x29, sp
        gicd_init();
    1a6c:	97ffffce 	bl	19a4 <gicd_init>
}
    1a70:	a8c17bfd 	ldp	x29, x30, [sp], #16
    gicc_init();
    1a74:	17ffffab 	b	1920 <gicc_init>
    1a78:	d503201f 	nop
    1a7c:	d503201f 	nop

0000000000001a80 <gic_set_enable>:
    asm volatile("1:\n\t"
    1a80:	b0000802 	adrp	x2, 102000 <init_lock>

void gic_set_enable(unsigned long int_id, bool en)
{
    1a84:	d10043ff 	sub	sp, sp, #0x10
    1a88:	12001c21 	and	w1, w1, #0xff
    unsigned long reg_ind = int_id / (sizeof(uint32_t) * 8);
    1a8c:	d345fc03 	lsr	x3, x0, #5
    1a90:	91004046 	add	x6, x2, #0x10
    1a94:	52800024 	mov	w4, #0x1                   	// #1
    1a98:	885ffcc5 	ldaxr	w5, [x6]
    1a9c:	35ffffe5 	cbnz	w5, 1a98 <gic_set_enable+0x18>
    1aa0:	88057cc4 	stxr	w5, w4, [x6]
    1aa4:	35ffffa5 	cbnz	w5, 1a98 <gic_set_enable+0x18>
    unsigned long bit = (1UL << int_id % (sizeof(uint32_t) * 8));
    1aa8:	12001000 	and	w0, w0, #0x1f
    1aac:	b9000fe5 	str	w5, [sp, #12]
    1ab0:	d2800024 	mov	x4, #0x1                   	// #1
    1ab4:	9ac02080 	lsl	x0, x4, x0

    spin_lock(&gicd_lock);

    if (en) {
    1ab8:	36000121 	tbz	w1, #0, 1adc <gic_set_enable+0x5c>
        gicd->ISENABLER[reg_ind] = bit;
    1abc:	90000081 	adrp	x1, 11000 <JIS_action_table>
    asm volatile("stlr wzr, %0\n\t" ::"Q"(*lock));
    1ac0:	91004042 	add	x2, x2, #0x10
    1ac4:	f9413021 	ldr	x1, [x1, #608]
    1ac8:	8b030823 	add	x3, x1, x3, lsl #2
    1acc:	b9010060 	str	w0, [x3, #256]
    1ad0:	889ffc5f 	stlr	wzr, [x2]
    } else {
        gicd->ICENABLER[reg_ind] = bit;
    }

    spin_unlock(&gicd_lock);
}
    1ad4:	910043ff 	add	sp, sp, #0x10
    1ad8:	d65f03c0 	ret
        gicd->ICENABLER[reg_ind] = bit;
    1adc:	90000081 	adrp	x1, 11000 <JIS_action_table>
    1ae0:	91004042 	add	x2, x2, #0x10
    1ae4:	f9413021 	ldr	x1, [x1, #608]
    1ae8:	8b030823 	add	x3, x1, x3, lsl #2
    1aec:	b9018060 	str	w0, [x3, #384]
    1af0:	889ffc5f 	stlr	wzr, [x2]
}
    1af4:	910043ff 	add	sp, sp, #0x10
    1af8:	d65f03c0 	ret
    1afc:	d503201f 	nop

0000000000001b00 <gic_set_trgt>:

void gic_set_trgt(unsigned long int_id, uint8_t trgt)
{
    1b00:	d10043ff 	sub	sp, sp, #0x10
    unsigned long reg_ind = (int_id * GIC_TARGET_BITS) / (sizeof(uint32_t) * 8);
    1b04:	d37df002 	lsl	x2, x0, #3
    asm volatile("1:\n\t"
    1b08:	b0000803 	adrp	x3, 102000 <init_lock>
{
    1b0c:	12001c21 	and	w1, w1, #0xff
    1b10:	52800024 	mov	w4, #0x1                   	// #1
    unsigned long off = (int_id * GIC_TARGET_BITS) % (sizeof(uint32_t) * 8);
    1b14:	d37d0400 	ubfiz	x0, x0, #3, #2
    1b18:	91004065 	add	x5, x3, #0x10
    1b1c:	885ffca6 	ldaxr	w6, [x5]
    1b20:	35ffffe6 	cbnz	w6, 1b1c <gic_set_trgt+0x1c>
    1b24:	88067ca4 	stxr	w6, w4, [x5]
    1b28:	35ffffa6 	cbnz	w6, 1b1c <gic_set_trgt+0x1c>
    uint32_t mask = ((1U << GIC_TARGET_BITS) - 1) << off;

    spin_lock(&gicd_lock);

    gicd->ITARGETSR[reg_ind] = (gicd->ITARGETSR[reg_ind] & ~mask) | ((trgt << off) & mask);
    1b2c:	90000083 	adrp	x3, 11000 <JIS_action_table>
    unsigned long reg_ind = (int_id * GIC_TARGET_BITS) / (sizeof(uint32_t) * 8);
    1b30:	d345fc42 	lsr	x2, x2, #5
    gicd->ITARGETSR[reg_ind] = (gicd->ITARGETSR[reg_ind] & ~mask) | ((trgt << off) & mask);
    1b34:	1ac02021 	lsl	w1, w1, w0
    1b38:	b9000fe6 	str	w6, [sp, #12]
    1b3c:	f9413064 	ldr	x4, [x3, #608]
    uint32_t mask = ((1U << GIC_TARGET_BITS) - 1) << off;
    1b40:	52801fe3 	mov	w3, #0xff                  	// #255
    1b44:	1ac02063 	lsl	w3, w3, w0
    1b48:	8b020880 	add	x0, x4, x2, lsl #2
    gicd->ITARGETSR[reg_ind] = (gicd->ITARGETSR[reg_ind] & ~mask) | ((trgt << off) & mask);
    1b4c:	b9480002 	ldr	w2, [x0, #2048]
    1b50:	4a020021 	eor	w1, w1, w2
    1b54:	0a030021 	and	w1, w1, w3
    1b58:	4a020021 	eor	w1, w1, w2
    1b5c:	b9080001 	str	w1, [x0, #2048]
    asm volatile("stlr wzr, %0\n\t" ::"Q"(*lock));
    1b60:	889ffcbf 	stlr	wzr, [x5]

    spin_unlock(&gicd_lock);
}
    1b64:	910043ff 	add	sp, sp, #0x10
    1b68:	d65f03c0 	ret
    1b6c:	d503201f 	nop

0000000000001b70 <gic_get_trgt>:
{
    unsigned long reg_ind = (int_id * GIC_TARGET_BITS) / (sizeof(uint32_t) * 8);
    unsigned long off = (int_id * GIC_TARGET_BITS) % (sizeof(uint32_t) * 8);
    uint32_t mask = ((1U << GIC_TARGET_BITS) - 1) << off;

    return (gicd->ITARGETSR[reg_ind] & mask) >> off;
    1b70:	90000082 	adrp	x2, 11000 <JIS_action_table>
    1b74:	927ee803 	and	x3, x0, #0x1ffffffffffffffc
    unsigned long off = (int_id * GIC_TARGET_BITS) % (sizeof(uint32_t) * 8);
    1b78:	d37d0400 	ubfiz	x0, x0, #3, #2
    uint32_t mask = ((1U << GIC_TARGET_BITS) - 1) << off;
    1b7c:	52801fe1 	mov	w1, #0xff                  	// #255
    return (gicd->ITARGETSR[reg_ind] & mask) >> off;
    1b80:	f9413042 	ldr	x2, [x2, #608]
    uint32_t mask = ((1U << GIC_TARGET_BITS) - 1) << off;
    1b84:	1ac02021 	lsl	w1, w1, w0
    return (gicd->ITARGETSR[reg_ind] & mask) >> off;
    1b88:	8b030042 	add	x2, x2, x3
    1b8c:	b9480042 	ldr	w2, [x2, #2048]
    1b90:	0a020021 	and	w1, w1, w2
}
    1b94:	1ac02420 	lsr	w0, w1, w0
    1b98:	d65f03c0 	ret
    1b9c:	d503201f 	nop

0000000000001ba0 <gic_send_sgi>:

void gic_send_sgi(unsigned long cpu_target, unsigned long sgi_num)
{
    gicd->SGIR =
    1ba0:	90000083 	adrp	x3, 11000 <JIS_action_table>
        (1UL << (GICD_SGIR_CPUTRGLST_OFF + cpu_target)) | (sgi_num & GICD_SGIR_SGIINTID_MSK);
    1ba4:	11004002 	add	w2, w0, #0x10
    1ba8:	12000c21 	and	w1, w1, #0xf
    1bac:	d2800020 	mov	x0, #0x1                   	// #1
    gicd->SGIR =
    1bb0:	f9413063 	ldr	x3, [x3, #608]
        (1UL << (GICD_SGIR_CPUTRGLST_OFF + cpu_target)) | (sgi_num & GICD_SGIR_SGIINTID_MSK);
    1bb4:	9ac22000 	lsl	x0, x0, x2
    1bb8:	2a000021 	orr	w1, w1, w0
    gicd->SGIR =
    1bbc:	b90f0061 	str	w1, [x3, #3840]
}
    1bc0:	d65f03c0 	ret

0000000000001bc4 <gic_set_prio>:

void gic_set_prio(unsigned long int_id, uint8_t prio)
{
    1bc4:	d10043ff 	sub	sp, sp, #0x10
    unsigned long reg_ind = (int_id * GIC_PRIO_BITS) / (sizeof(uint32_t) * 8);
    1bc8:	d37df002 	lsl	x2, x0, #3
    asm volatile("1:\n\t"
    1bcc:	b0000803 	adrp	x3, 102000 <init_lock>
{
    1bd0:	12001c21 	and	w1, w1, #0xff
    1bd4:	52800024 	mov	w4, #0x1                   	// #1
    unsigned long off = (int_id * GIC_PRIO_BITS) % (sizeof(uint32_t) * 8);
    1bd8:	d37d0400 	ubfiz	x0, x0, #3, #2
    1bdc:	91004065 	add	x5, x3, #0x10
    1be0:	885ffca6 	ldaxr	w6, [x5]
    1be4:	35ffffe6 	cbnz	w6, 1be0 <gic_set_prio+0x1c>
    1be8:	88067ca4 	stxr	w6, w4, [x5]
    1bec:	35ffffa6 	cbnz	w6, 1be0 <gic_set_prio+0x1c>
    unsigned long mask = ((1 << GIC_PRIO_BITS) - 1) << off;

    spin_lock(&gicd_lock);

    gicd->IPRIORITYR[reg_ind] = (gicd->IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
    1bf0:	90000083 	adrp	x3, 11000 <JIS_action_table>
    unsigned long reg_ind = (int_id * GIC_PRIO_BITS) / (sizeof(uint32_t) * 8);
    1bf4:	d345fc42 	lsr	x2, x2, #5
    gicd->IPRIORITYR[reg_ind] = (gicd->IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
    1bf8:	1ac02021 	lsl	w1, w1, w0
    1bfc:	b9000fe6 	str	w6, [sp, #12]
    1c00:	f9413064 	ldr	x4, [x3, #608]
    unsigned long mask = ((1 << GIC_PRIO_BITS) - 1) << off;
    1c04:	52801fe3 	mov	w3, #0xff                  	// #255
    1c08:	1ac02063 	lsl	w3, w3, w0
    1c0c:	8b020880 	add	x0, x4, x2, lsl #2
    gicd->IPRIORITYR[reg_ind] = (gicd->IPRIORITYR[reg_ind] & ~mask) | ((prio << off) & mask);
    1c10:	b9440002 	ldr	w2, [x0, #1024]
    1c14:	4a020021 	eor	w1, w1, w2
    1c18:	0a030021 	and	w1, w1, w3
    1c1c:	4a020021 	eor	w1, w1, w2
    1c20:	b9040001 	str	w1, [x0, #1024]
    asm volatile("stlr wzr, %0\n\t" ::"Q"(*lock));
    1c24:	889ffcbf 	stlr	wzr, [x5]

    spin_unlock(&gicd_lock);
}
    1c28:	910043ff 	add	sp, sp, #0x10
    1c2c:	d65f03c0 	ret

0000000000001c30 <gic_is_pending>:
bool gic_is_pending(unsigned long int_id)
{
    unsigned long reg_ind = int_id / (sizeof(uint32_t) * 8);
    unsigned long off = int_id % (sizeof(uint32_t) * 8);

    return ((1U << off) & gicd->ISPENDR[reg_ind]) != 0;
    1c30:	90000081 	adrp	x1, 11000 <JIS_action_table>
    1c34:	f9413022 	ldr	x2, [x1, #608]
    unsigned long reg_ind = int_id / (sizeof(uint32_t) * 8);
    1c38:	d345fc01 	lsr	x1, x0, #5
    return ((1U << off) & gicd->ISPENDR[reg_ind]) != 0;
    1c3c:	8b010841 	add	x1, x2, x1, lsl #2
    1c40:	b9420021 	ldr	w1, [x1, #512]
    1c44:	1ac02420 	lsr	w0, w1, w0
}
    1c48:	12000000 	and	w0, w0, #0x1
    1c4c:	d65f03c0 	ret

0000000000001c50 <gic_set_pending>:

void gic_set_pending(unsigned long int_id, bool pending)
{
    unsigned long reg_ind = int_id / (sizeof(uint32_t) * 8);
    unsigned long mask = 1U << int_id % (sizeof(uint32_t) * 8);
    1c50:	52800024 	mov	w4, #0x1                   	// #1
    unsigned long reg_ind = int_id / (sizeof(uint32_t) * 8);
    1c54:	d345fc03 	lsr	x3, x0, #5
    asm volatile("1:\n\t"
    1c58:	b0000802 	adrp	x2, 102000 <init_lock>
{
    1c5c:	d10043ff 	sub	sp, sp, #0x10
    1c60:	12001c21 	and	w1, w1, #0xff
    1c64:	91004046 	add	x6, x2, #0x10
    unsigned long mask = 1U << int_id % (sizeof(uint32_t) * 8);
    1c68:	1ac02080 	lsl	w0, w4, w0
    1c6c:	885ffcc5 	ldaxr	w5, [x6]
    1c70:	35ffffe5 	cbnz	w5, 1c6c <gic_set_pending+0x1c>
    1c74:	88057cc4 	stxr	w5, w4, [x6]
    1c78:	35ffffa5 	cbnz	w5, 1c6c <gic_set_pending+0x1c>
    1c7c:	b9000fe5 	str	w5, [sp, #12]

    spin_lock(&gicd_lock);

    if (pending) {
    1c80:	36000121 	tbz	w1, #0, 1ca4 <gic_set_pending+0x54>
        gicd->ISPENDR[reg_ind] = mask;
    1c84:	90000081 	adrp	x1, 11000 <JIS_action_table>
    asm volatile("stlr wzr, %0\n\t" ::"Q"(*lock));
    1c88:	91004042 	add	x2, x2, #0x10
    1c8c:	f9413021 	ldr	x1, [x1, #608]
    1c90:	8b030823 	add	x3, x1, x3, lsl #2
    1c94:	b9020060 	str	w0, [x3, #512]
    1c98:	889ffc5f 	stlr	wzr, [x2]
    } else {
        gicd->ICPENDR[reg_ind] = mask;
    }

    spin_unlock(&gicd_lock);
}
    1c9c:	910043ff 	add	sp, sp, #0x10
    1ca0:	d65f03c0 	ret
        gicd->ICPENDR[reg_ind] = mask;
    1ca4:	90000081 	adrp	x1, 11000 <JIS_action_table>
    1ca8:	91004042 	add	x2, x2, #0x10
    1cac:	f9413021 	ldr	x1, [x1, #608]
    1cb0:	8b030823 	add	x3, x1, x3, lsl #2
    1cb4:	b9028060 	str	w0, [x3, #640]
    1cb8:	889ffc5f 	stlr	wzr, [x2]
}
    1cbc:	910043ff 	add	sp, sp, #0x10
    1cc0:	d65f03c0 	ret

0000000000001cc4 <gic_is_active>:
bool gic_is_active(unsigned long int_id)
{
    unsigned long reg_ind = int_id / (sizeof(uint32_t) * 8);
    unsigned long off = int_id % (sizeof(uint32_t) * 8);

    return ((1U << off) & gicd->ISACTIVER[reg_ind]) != 0;
    1cc4:	90000081 	adrp	x1, 11000 <JIS_action_table>
    1cc8:	f9413022 	ldr	x2, [x1, #608]
    unsigned long reg_ind = int_id / (sizeof(uint32_t) * 8);
    1ccc:	d345fc01 	lsr	x1, x0, #5
    return ((1U << off) & gicd->ISACTIVER[reg_ind]) != 0;
    1cd0:	8b010841 	add	x1, x2, x1, lsl #2
    1cd4:	b9430021 	ldr	w1, [x1, #768]
    1cd8:	1ac02420 	lsr	w0, w1, w0
}
    1cdc:	12000000 	and	w0, w0, #0x1
    1ce0:	d65f03c0 	ret

0000000000001ce4 <gic_handle>:

void gic_handle()
{
    1ce4:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    1ce8:	910003fd 	mov	x29, sp
    1cec:	a90153f3 	stp	x19, x20, [sp, #16]
    unsigned long ack = gicc->IAR;
    1cf0:	90000093 	adrp	x19, 11000 <JIS_action_table>
    1cf4:	91098273 	add	x19, x19, #0x260
    1cf8:	f9400660 	ldr	x0, [x19, #8]
    1cfc:	b9400c14 	ldr	w20, [x0, #12]
    unsigned long id = ack & GICC_IAR_ID_MSK;
    1d00:	12002680 	and	w0, w20, #0x3ff
    unsigned long src = (ack & GICC_IAR_CPU_MSK) >> GICC_IAR_CPU_OFF;

    if (id >= 1022) {
    1d04:	710ff41f 	cmp	w0, #0x3fd
    1d08:	54000088 	b.hi	1d18 <gic_handle+0x34>  // b.pmore
        return;
    }

    irq_handle(id);
    1d0c:	97fffac5 	bl	820 <irq_handle>

    gicc->EOIR = ack;
    1d10:	f9400660 	ldr	x0, [x19, #8]
    1d14:	b9001014 	str	w20, [x0, #16]
}
    1d18:	a94153f3 	ldp	x19, x20, [sp, #16]
    1d1c:	a8c27bfd 	ldp	x29, x30, [sp], #32
    1d20:	d65f03c0 	ret
	...

0000000000001d30 <main>:
    asm volatile("DC IVAC, %0" : : "r"(addr));
}
#endif

void main(void)
{
    1d30:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
    asm volatile("1:\n\t"
    1d34:	f0000fe0 	adrp	x0, 200000 <cpu_ticket_lock>
    1d38:	52800021 	mov	w1, #0x1                   	// #1
    1d3c:	910003fd 	mov	x29, sp
    1d40:	a90153f3 	stp	x19, x20, [sp, #16]
    1d44:	91000013 	add	x19, x0, #0x0
    1d48:	885ffe62 	ldaxr	w2, [x19]
    1d4c:	35ffffe2 	cbnz	w2, 1d48 <main+0x18>
    1d50:	88027e61 	stxr	w2, w1, [x19]
    1d54:	35ffffa2 	cbnz	w2, 1d48 <main+0x18>
    1d58:	b9005be2 	str	w2, [sp, #88]
    static volatile size_t buf_index_ticket = 0;
    size_t buf_index;

    spin_lock(&cpu_ticket_lock);
    buf_index = buf_index_ticket;
    1d5c:	f9400674 	ldr	x20, [x19, #8]
    buf_index_ticket += 1;
    1d60:	f9400660 	ldr	x0, [x19, #8]
    1d64:	91000400 	add	x0, x0, #0x1
    1d68:	f9000660 	str	x0, [x19, #8]
    asm volatile("stlr wzr, %0\n\t" ::"Q"(*lock));
    1d6c:	889ffe7f 	stlr	wzr, [x19]
    spin_unlock(&cpu_ticket_lock);

    if (buf_index >= NUM_CPUS) {
    1d70:	f1000a9f 	cmp	x20, #0x2
    1d74:	54000ba8 	b.hi	1ee8 <main+0x1b8>  // b.pmore

    const size_t bufid = buf_index;
    const size_t range = CPU_INTERF_BUF_SIZE / sizeof(uint64_t);
    const size_t stride = CACHE_LINE_SIZE / sizeof(uint64_t);
    const size_t base = 0;
    const uint64_t sample_period_ticks = TIME_MS(SAMPLE_PERIOD_MS);
    1d78:	b0000801 	adrp	x1, 102000 <init_lock>
    1d7c:	d290d405 	mov	x5, #0x86a0                	// #34464
    1d80:	f2a00025 	movk	x5, #0x1, lsl #16
    1d84:	d2884804 	mov	x4, #0x4240                	// #16960
    1d88:	f9400427 	ldr	x7, [x1, #8]
    1d8c:	f2a001e4 	movk	x4, #0xf, lsl #16
    register uint64_t r0 asm("x0") = SMCC32_FID_VND_HYP_SRVC | hc_id;
    1d90:	d2800060 	mov	x0, #0x3                   	// #3
    register uint64_t r1 asm("x1") = arg1;
    1d94:	d2800001 	mov	x1, #0x0                   	// #0
    register uint64_t r0 asm("x0") = SMCC32_FID_VND_HYP_SRVC | hc_id;
    1d98:	f2b0c000 	movk	x0, #0x8600, lsl #16
    register uint64_t r2 asm("x2") = arg2;
    1d9c:	d2800002 	mov	x2, #0x0                   	// #0
    const uint64_t sample_period_ticks = TIME_MS(SAMPLE_PERIOD_MS);
    1da0:	9b057ce7 	mul	x7, x7, x5
    register uint64_t r3 asm("x3") = arg3;
    1da4:	d2800003 	mov	x3, #0x0                   	// #0
    1da8:	a9025bf5 	stp	x21, x22, [sp, #32]
    1dac:	a90363f7 	stp	x23, x24, [sp, #48]
    const uint64_t sample_period_ticks = TIME_MS(SAMPLE_PERIOD_MS);
    1db0:	9ac408e7 	udiv	x7, x7, x4
    asm volatile("hvc   #0\n"
    1db4:	f90023f9 	str	x25, [sp, #64]
    1db8:	d4000002 	hvc	#0x0
            asm volatile("dsb sy" : : : "memory");
#endif
            elapsed_ticks = timer_get() - sample_start;
        } while (elapsed_ticks < sample_period_ticks);

        accesses_per_sample[bufid][sample_index] = accesses_in_current_sample;
    1dbc:	8b14068a 	add	x10, x20, x20, lsl #1
                cpu_interf_buf[bufid][i] = i;
    1dc0:	d2955544 	mov	x4, #0xaaaa                	// #43690
    1dc4:	f00017e2 	adrp	x2, 300000 <cpu_interf_buf>
    1dc8:	d37ffa95 	lsl	x21, x20, #1
        accesses_per_sample[bufid][sample_index] = accesses_in_current_sample;
    1dcc:	8b0a0e8a 	add	x10, x20, x10, lsl #3
                cpu_interf_buf[bufid][i] = i;
    1dd0:	9b047e84 	mul	x4, x20, x4
        accesses_per_sample[bufid][sample_index] = accesses_in_current_sample;
    1dd4:	9100426c 	add	x12, x19, #0x10
        sample_elapsed_ticks[bufid][sample_index] = elapsed_ticks;
    1dd8:	9125c26b 	add	x11, x19, #0x970
        accesses_per_sample[bufid][sample_index] = accesses_in_current_sample;
    1ddc:	d37ef54a 	lsl	x10, x10, #2
    1de0:	91000042 	add	x2, x2, #0x0
            for (size_t i = base; i < (base + range); i += stride) {
    1de4:	d2955605 	mov	x5, #0xaab0                	// #43696
            accesses_in_current_sample += accesses_per_pass;
    1de8:	d282aac8 	mov	x8, #0x1556                	// #5462
SYSREG_GEN_ACCESSORS(cntvct_el0);
    1dec:	d53be049 	mrs	x9, cntvct_el0
        uint64_t accesses_in_current_sample = 0;
    1df0:	d2800006 	mov	x6, #0x0                   	// #0
            for (size_t i = base; i < (base + range); i += stride) {
    1df4:	d2800000 	mov	x0, #0x0                   	// #0
                cpu_interf_buf[bufid][i] = i;
    1df8:	8b000081 	add	x1, x4, x0
    1dfc:	f8217840 	str	x0, [x2, x1, lsl #3]
            for (size_t i = base; i < (base + range); i += stride) {
    1e00:	91002000 	add	x0, x0, #0x8
    1e04:	eb05001f 	cmp	x0, x5
    1e08:	54ffff81 	b.ne	1df8 <main+0xc8>  // b.any
            accesses_in_current_sample += accesses_per_pass;
    1e0c:	8b0800c6 	add	x6, x6, x8
    1e10:	d53be040 	mrs	x0, cntvct_el0
            elapsed_ticks = timer_get() - sample_start;
    1e14:	cb090000 	sub	x0, x0, x9
        } while (elapsed_ticks < sample_period_ticks);
    1e18:	eb0000ff 	cmp	x7, x0
    1e1c:	54fffec8 	b.hi	1df4 <main+0xc4>  // b.pmore
        accesses_per_sample[bufid][sample_index] = accesses_in_current_sample;
    1e20:	8b030141 	add	x1, x10, x3
    for (size_t sample_index = 0; sample_index < SAMPLE_COUNT; sample_index++) {
    1e24:	91000463 	add	x3, x3, #0x1
        accesses_per_sample[bufid][sample_index] = accesses_in_current_sample;
    1e28:	f8217986 	str	x6, [x12, x1, lsl #3]
        sample_elapsed_ticks[bufid][sample_index] = elapsed_ticks;
    1e2c:	f8217960 	str	x0, [x11, x1, lsl #3]
    for (size_t sample_index = 0; sample_index < SAMPLE_COUNT; sample_index++) {
    1e30:	f101907f 	cmp	x3, #0x64
    1e34:	54fffdc1 	b.ne	1dec <main+0xbc>  // b.any
    asm volatile("1:\n\t"
    1e38:	90001016 	adrp	x22, 201000 <sample_elapsed_ticks+0x690>
    1e3c:	910402d6 	add	x22, x22, #0x100
    1e40:	910742c1 	add	x1, x22, #0x1d0
    1e44:	52800020 	mov	w0, #0x1                   	// #1
    1e48:	885ffc24 	ldaxr	w4, [x1]
    1e4c:	35ffffe4 	cbnz	w4, 1e48 <main+0x118>
    1e50:	88047c20 	stxr	w4, w0, [x1]
    1e54:	35ffffa4 	cbnz	w4, 1e48 <main+0x118>

    spin_lock(&print_lock);
    printf("cpu%zu memory bandwidth samples (%us total, %ums interval)\n",
           bufid, BENCHMARK_DURATION_S, SAMPLE_PERIOD_MS);
    for (size_t i = 0; i < SAMPLE_COUNT; i++) {
        uint64_t accesses = accesses_per_sample[bufid][i];
    1e58:	8b1402b5 	add	x21, x21, x20
    printf("cpu%zu memory bandwidth samples (%us total, %ums interval)\n",
    1e5c:	aa1403e1 	mov	x1, x20
        uint64_t accesses = accesses_per_sample[bufid][i];
    1e60:	91004279 	add	x25, x19, #0x10
    printf("cpu%zu memory bandwidth samples (%us total, %ums interval)\n",
    1e64:	f0000060 	adrp	x0, 10000 <__env_lock>
        uint64_t accesses = accesses_per_sample[bufid][i];
    1e68:	8b150e94 	add	x20, x20, x21, lsl #3
    1e6c:	b0000818 	adrp	x24, 102000 <init_lock>
    1e70:	f0000077 	adrp	x23, 10000 <__env_lock>
    printf("cpu%zu memory bandwidth samples (%us total, %ums interval)\n",
    1e74:	911dc000 	add	x0, x0, #0x770
        uint64_t bytes = accesses * sizeof(uint64_t);
        uint64_t elapsed_ticks = sample_elapsed_ticks[bufid][i];
    1e78:	9125c273 	add	x19, x19, #0x970
    1e7c:	91002318 	add	x24, x24, #0x8
        uint64_t accesses = accesses_per_sample[bufid][i];
    1e80:	d37ef694 	lsl	x20, x20, #2
    1e84:	911ec2f7 	add	x23, x23, #0x7b0
    printf("cpu%zu memory bandwidth samples (%us total, %ums interval)\n",
    1e88:	52800142 	mov	w2, #0xa                   	// #10
    for (size_t i = 0; i < SAMPLE_COUNT; i++) {
    1e8c:	d2800015 	mov	x21, #0x0                   	// #0
    1e90:	b9005fe4 	str	w4, [sp, #92]
    printf("cpu%zu memory bandwidth samples (%us total, %ums interval)\n",
    1e94:	9400035b 	bl	2c00 <printf>
        uint64_t accesses = accesses_per_sample[bufid][i];
    1e98:	8b150283 	add	x3, x20, x21
        uint64_t bytes_per_second = (elapsed_ticks != 0)
            ? ((bytes * TIMER_FREQ) / elapsed_ticks)
            : 0;
        uint64_t mib_per_second = bytes_per_second / (1024ull * 1024ull);

        printf("sample[%02zu] accesses=%llu bytes=%llu bw=%llu MiB/s\n", i,
    1e9c:	aa1503e1 	mov	x1, x21
    1ea0:	aa1703e0 	mov	x0, x23
        uint64_t accesses = accesses_per_sample[bufid][i];
    1ea4:	910006b5 	add	x21, x21, #0x1
    1ea8:	f8637b22 	ldr	x2, [x25, x3, lsl #3]
        uint64_t elapsed_ticks = sample_elapsed_ticks[bufid][i];
    1eac:	f8637a64 	ldr	x4, [x19, x3, lsl #3]
        uint64_t bytes = accesses * sizeof(uint64_t);
    1eb0:	d37df045 	lsl	x5, x2, #3
        printf("sample[%02zu] accesses=%llu bytes=%llu bw=%llu MiB/s\n", i,
    1eb4:	aa0503e3 	mov	x3, x5
            : 0;
    1eb8:	b40000a4 	cbz	x4, 1ecc <main+0x19c>
            ? ((bytes * TIMER_FREQ) / elapsed_ticks)
    1ebc:	f9400306 	ldr	x6, [x24]
    1ec0:	9b067ca5 	mul	x5, x5, x6
            : 0;
    1ec4:	9ac408a4 	udiv	x4, x5, x4
        uint64_t mib_per_second = bytes_per_second / (1024ull * 1024ull);
    1ec8:	d354fc84 	lsr	x4, x4, #20
        printf("sample[%02zu] accesses=%llu bytes=%llu bw=%llu MiB/s\n", i,
    1ecc:	9400034d 	bl	2c00 <printf>
    for (size_t i = 0; i < SAMPLE_COUNT; i++) {
    1ed0:	f10192bf 	cmp	x21, #0x64
    1ed4:	54fffe21 	b.ne	1e98 <main+0x168>  // b.any
    asm volatile("stlr wzr, %0\n\t" ::"Q"(*lock));
    1ed8:	910742c0 	add	x0, x22, #0x1d0
    1edc:	889ffc1f 	stlr	wzr, [x0]
    1ee0:	d503207f 	wfi
    1ee4:	17ffffff 	b	1ee0 <main+0x1b0>
    1ee8:	d503207f 	wfi
    1eec:	d503207f 	wfi
    1ef0:	17fffffe 	b	1ee8 <main+0x1b8>
	...

0000000000002000 <_exception_vector>:
/* 
 * EL1 with SP0
 */  
.balign ENTRY_SIZE
curr_el_sp0_sync:        
    b	.
    2000:	14000000 	b	2000 <_exception_vector>
    2004:	d503201f 	nop
    2008:	d503201f 	nop
    200c:	d503201f 	nop
    2010:	d503201f 	nop
    2014:	d503201f 	nop
    2018:	d503201f 	nop
    201c:	d503201f 	nop
    2020:	d503201f 	nop
    2024:	d503201f 	nop
    2028:	d503201f 	nop
    202c:	d503201f 	nop
    2030:	d503201f 	nop
    2034:	d503201f 	nop
    2038:	d503201f 	nop
    203c:	d503201f 	nop
    2040:	d503201f 	nop
    2044:	d503201f 	nop
    2048:	d503201f 	nop
    204c:	d503201f 	nop
    2050:	d503201f 	nop
    2054:	d503201f 	nop
    2058:	d503201f 	nop
    205c:	d503201f 	nop
    2060:	d503201f 	nop
    2064:	d503201f 	nop
    2068:	d503201f 	nop
    206c:	d503201f 	nop
    2070:	d503201f 	nop
    2074:	d503201f 	nop
    2078:	d503201f 	nop
    207c:	d503201f 	nop

0000000000002080 <curr_el_sp0_irq>:
.balign ENTRY_SIZE
curr_el_sp0_irq:  
    b   .
    2080:	14000000 	b	2080 <curr_el_sp0_irq>
    2084:	d503201f 	nop
    2088:	d503201f 	nop
    208c:	d503201f 	nop
    2090:	d503201f 	nop
    2094:	d503201f 	nop
    2098:	d503201f 	nop
    209c:	d503201f 	nop
    20a0:	d503201f 	nop
    20a4:	d503201f 	nop
    20a8:	d503201f 	nop
    20ac:	d503201f 	nop
    20b0:	d503201f 	nop
    20b4:	d503201f 	nop
    20b8:	d503201f 	nop
    20bc:	d503201f 	nop
    20c0:	d503201f 	nop
    20c4:	d503201f 	nop
    20c8:	d503201f 	nop
    20cc:	d503201f 	nop
    20d0:	d503201f 	nop
    20d4:	d503201f 	nop
    20d8:	d503201f 	nop
    20dc:	d503201f 	nop
    20e0:	d503201f 	nop
    20e4:	d503201f 	nop
    20e8:	d503201f 	nop
    20ec:	d503201f 	nop
    20f0:	d503201f 	nop
    20f4:	d503201f 	nop
    20f8:	d503201f 	nop
    20fc:	d503201f 	nop

0000000000002100 <curr_el_sp0_fiq>:
.balign ENTRY_SIZE
curr_el_sp0_fiq:         
    b	.
    2100:	14000000 	b	2100 <curr_el_sp0_fiq>
    2104:	d503201f 	nop
    2108:	d503201f 	nop
    210c:	d503201f 	nop
    2110:	d503201f 	nop
    2114:	d503201f 	nop
    2118:	d503201f 	nop
    211c:	d503201f 	nop
    2120:	d503201f 	nop
    2124:	d503201f 	nop
    2128:	d503201f 	nop
    212c:	d503201f 	nop
    2130:	d503201f 	nop
    2134:	d503201f 	nop
    2138:	d503201f 	nop
    213c:	d503201f 	nop
    2140:	d503201f 	nop
    2144:	d503201f 	nop
    2148:	d503201f 	nop
    214c:	d503201f 	nop
    2150:	d503201f 	nop
    2154:	d503201f 	nop
    2158:	d503201f 	nop
    215c:	d503201f 	nop
    2160:	d503201f 	nop
    2164:	d503201f 	nop
    2168:	d503201f 	nop
    216c:	d503201f 	nop
    2170:	d503201f 	nop
    2174:	d503201f 	nop
    2178:	d503201f 	nop
    217c:	d503201f 	nop

0000000000002180 <curr_el_sp0_serror>:
.balign ENTRY_SIZE
curr_el_sp0_serror:      
    b	.
    2180:	14000000 	b	2180 <curr_el_sp0_serror>
    2184:	d503201f 	nop
    2188:	d503201f 	nop
    218c:	d503201f 	nop
    2190:	d503201f 	nop
    2194:	d503201f 	nop
    2198:	d503201f 	nop
    219c:	d503201f 	nop
    21a0:	d503201f 	nop
    21a4:	d503201f 	nop
    21a8:	d503201f 	nop
    21ac:	d503201f 	nop
    21b0:	d503201f 	nop
    21b4:	d503201f 	nop
    21b8:	d503201f 	nop
    21bc:	d503201f 	nop
    21c0:	d503201f 	nop
    21c4:	d503201f 	nop
    21c8:	d503201f 	nop
    21cc:	d503201f 	nop
    21d0:	d503201f 	nop
    21d4:	d503201f 	nop
    21d8:	d503201f 	nop
    21dc:	d503201f 	nop
    21e0:	d503201f 	nop
    21e4:	d503201f 	nop
    21e8:	d503201f 	nop
    21ec:	d503201f 	nop
    21f0:	d503201f 	nop
    21f4:	d503201f 	nop
    21f8:	d503201f 	nop
    21fc:	d503201f 	nop

0000000000002200 <curr_el_spx_sync>:
/* 
 * EL1 with SPx
 */  
.balign ENTRY_SIZE  
curr_el_spx_sync:        
    b	.
    2200:	14000000 	b	2200 <curr_el_spx_sync>
    2204:	d503201f 	nop
    2208:	d503201f 	nop
    220c:	d503201f 	nop
    2210:	d503201f 	nop
    2214:	d503201f 	nop
    2218:	d503201f 	nop
    221c:	d503201f 	nop
    2220:	d503201f 	nop
    2224:	d503201f 	nop
    2228:	d503201f 	nop
    222c:	d503201f 	nop
    2230:	d503201f 	nop
    2234:	d503201f 	nop
    2238:	d503201f 	nop
    223c:	d503201f 	nop
    2240:	d503201f 	nop
    2244:	d503201f 	nop
    2248:	d503201f 	nop
    224c:	d503201f 	nop
    2250:	d503201f 	nop
    2254:	d503201f 	nop
    2258:	d503201f 	nop
    225c:	d503201f 	nop
    2260:	d503201f 	nop
    2264:	d503201f 	nop
    2268:	d503201f 	nop
    226c:	d503201f 	nop
    2270:	d503201f 	nop
    2274:	d503201f 	nop
    2278:	d503201f 	nop
    227c:	d503201f 	nop

0000000000002280 <curr_el_spx_irq>:
.balign ENTRY_SIZE
curr_el_spx_irq:       
    SAVE_REGS
    2280:	d102c3ff 	sub	sp, sp, #0xb0
    2284:	a90007e0 	stp	x0, x1, [sp]
    2288:	a9010fe2 	stp	x2, x3, [sp, #16]
    228c:	a90217e4 	stp	x4, x5, [sp, #32]
    2290:	a9031fe6 	stp	x6, x7, [sp, #48]
    2294:	a90427e8 	stp	x8, x9, [sp, #64]
    2298:	a9052fea 	stp	x10, x11, [sp, #80]
    229c:	a90637ec 	stp	x12, x13, [sp, #96]
    22a0:	a9073fee 	stp	x14, x15, [sp, #112]
    22a4:	a90847f0 	stp	x16, x17, [sp, #128]
    22a8:	a9094ff2 	stp	x18, x19, [sp, #144]
    22ac:	a90a7bfd 	stp	x29, x30, [sp, #160]
    bl	gic_handle
    22b0:	97fffe8d 	bl	1ce4 <gic_handle>
    RESTORE_REGS
    22b4:	a94007e0 	ldp	x0, x1, [sp]
    22b8:	a9410fe2 	ldp	x2, x3, [sp, #16]
    22bc:	a94217e4 	ldp	x4, x5, [sp, #32]
    22c0:	a9431fe6 	ldp	x6, x7, [sp, #48]
    22c4:	a94427e8 	ldp	x8, x9, [sp, #64]
    22c8:	a9452fea 	ldp	x10, x11, [sp, #80]
    22cc:	a94637ec 	ldp	x12, x13, [sp, #96]
    22d0:	a9473fee 	ldp	x14, x15, [sp, #112]
    22d4:	a94847f0 	ldp	x16, x17, [sp, #128]
    22d8:	a9494ff2 	ldp	x18, x19, [sp, #144]
    22dc:	a94a7bfd 	ldp	x29, x30, [sp, #160]
    22e0:	9102c3ff 	add	sp, sp, #0xb0
    eret
    22e4:	d69f03e0 	eret
    22e8:	d503201f 	nop
    22ec:	d503201f 	nop
    22f0:	d503201f 	nop
    22f4:	d503201f 	nop
    22f8:	d503201f 	nop
    22fc:	d503201f 	nop

0000000000002300 <curr_el_spx_fiq>:
.balign ENTRY_SIZE
curr_el_spx_fiq:         
    SAVE_REGS
    2300:	d102c3ff 	sub	sp, sp, #0xb0
    2304:	a90007e0 	stp	x0, x1, [sp]
    2308:	a9010fe2 	stp	x2, x3, [sp, #16]
    230c:	a90217e4 	stp	x4, x5, [sp, #32]
    2310:	a9031fe6 	stp	x6, x7, [sp, #48]
    2314:	a90427e8 	stp	x8, x9, [sp, #64]
    2318:	a9052fea 	stp	x10, x11, [sp, #80]
    231c:	a90637ec 	stp	x12, x13, [sp, #96]
    2320:	a9073fee 	stp	x14, x15, [sp, #112]
    2324:	a90847f0 	stp	x16, x17, [sp, #128]
    2328:	a9094ff2 	stp	x18, x19, [sp, #144]
    232c:	a90a7bfd 	stp	x29, x30, [sp, #160]
    bl	gic_handle
    2330:	97fffe6d 	bl	1ce4 <gic_handle>
    RESTORE_REGS
    2334:	a94007e0 	ldp	x0, x1, [sp]
    2338:	a9410fe2 	ldp	x2, x3, [sp, #16]
    233c:	a94217e4 	ldp	x4, x5, [sp, #32]
    2340:	a9431fe6 	ldp	x6, x7, [sp, #48]
    2344:	a94427e8 	ldp	x8, x9, [sp, #64]
    2348:	a9452fea 	ldp	x10, x11, [sp, #80]
    234c:	a94637ec 	ldp	x12, x13, [sp, #96]
    2350:	a9473fee 	ldp	x14, x15, [sp, #112]
    2354:	a94847f0 	ldp	x16, x17, [sp, #128]
    2358:	a9494ff2 	ldp	x18, x19, [sp, #144]
    235c:	a94a7bfd 	ldp	x29, x30, [sp, #160]
    2360:	9102c3ff 	add	sp, sp, #0xb0
    eret
    2364:	d69f03e0 	eret
    2368:	d503201f 	nop
    236c:	d503201f 	nop
    2370:	d503201f 	nop
    2374:	d503201f 	nop
    2378:	d503201f 	nop
    237c:	d503201f 	nop

0000000000002380 <curr_el_spx_serror>:
.balign ENTRY_SIZE
curr_el_spx_serror:      
    b	.         
    2380:	14000000 	b	2380 <curr_el_spx_serror>
    2384:	d503201f 	nop
    2388:	d503201f 	nop
    238c:	d503201f 	nop
    2390:	d503201f 	nop
    2394:	d503201f 	nop
    2398:	d503201f 	nop
    239c:	d503201f 	nop
    23a0:	d503201f 	nop
    23a4:	d503201f 	nop
    23a8:	d503201f 	nop
    23ac:	d503201f 	nop
    23b0:	d503201f 	nop
    23b4:	d503201f 	nop
    23b8:	d503201f 	nop
    23bc:	d503201f 	nop
    23c0:	d503201f 	nop
    23c4:	d503201f 	nop
    23c8:	d503201f 	nop
    23cc:	d503201f 	nop
    23d0:	d503201f 	nop
    23d4:	d503201f 	nop
    23d8:	d503201f 	nop
    23dc:	d503201f 	nop
    23e0:	d503201f 	nop
    23e4:	d503201f 	nop
    23e8:	d503201f 	nop
    23ec:	d503201f 	nop
    23f0:	d503201f 	nop
    23f4:	d503201f 	nop
    23f8:	d503201f 	nop
    23fc:	d503201f 	nop

0000000000002400 <lower_el_aarch64_sync>:
 * Lower EL using AArch64
 */  

.balign ENTRY_SIZE
lower_el_aarch64_sync:
    b .
    2400:	14000000 	b	2400 <lower_el_aarch64_sync>
    2404:	d503201f 	nop
    2408:	d503201f 	nop
    240c:	d503201f 	nop
    2410:	d503201f 	nop
    2414:	d503201f 	nop
    2418:	d503201f 	nop
    241c:	d503201f 	nop
    2420:	d503201f 	nop
    2424:	d503201f 	nop
    2428:	d503201f 	nop
    242c:	d503201f 	nop
    2430:	d503201f 	nop
    2434:	d503201f 	nop
    2438:	d503201f 	nop
    243c:	d503201f 	nop
    2440:	d503201f 	nop
    2444:	d503201f 	nop
    2448:	d503201f 	nop
    244c:	d503201f 	nop
    2450:	d503201f 	nop
    2454:	d503201f 	nop
    2458:	d503201f 	nop
    245c:	d503201f 	nop
    2460:	d503201f 	nop
    2464:	d503201f 	nop
    2468:	d503201f 	nop
    246c:	d503201f 	nop
    2470:	d503201f 	nop
    2474:	d503201f 	nop
    2478:	d503201f 	nop
    247c:	d503201f 	nop

0000000000002480 <lower_el_aarch64_irq>:
.balign ENTRY_SIZE
lower_el_aarch64_irq:    
    b .
    2480:	14000000 	b	2480 <lower_el_aarch64_irq>
    2484:	d503201f 	nop
    2488:	d503201f 	nop
    248c:	d503201f 	nop
    2490:	d503201f 	nop
    2494:	d503201f 	nop
    2498:	d503201f 	nop
    249c:	d503201f 	nop
    24a0:	d503201f 	nop
    24a4:	d503201f 	nop
    24a8:	d503201f 	nop
    24ac:	d503201f 	nop
    24b0:	d503201f 	nop
    24b4:	d503201f 	nop
    24b8:	d503201f 	nop
    24bc:	d503201f 	nop
    24c0:	d503201f 	nop
    24c4:	d503201f 	nop
    24c8:	d503201f 	nop
    24cc:	d503201f 	nop
    24d0:	d503201f 	nop
    24d4:	d503201f 	nop
    24d8:	d503201f 	nop
    24dc:	d503201f 	nop
    24e0:	d503201f 	nop
    24e4:	d503201f 	nop
    24e8:	d503201f 	nop
    24ec:	d503201f 	nop
    24f0:	d503201f 	nop
    24f4:	d503201f 	nop
    24f8:	d503201f 	nop
    24fc:	d503201f 	nop

0000000000002500 <lower_el_aarch64_fiq>:
.balign ENTRY_SIZE
lower_el_aarch64_fiq:    
    b	.
    2500:	14000000 	b	2500 <lower_el_aarch64_fiq>
    2504:	d503201f 	nop
    2508:	d503201f 	nop
    250c:	d503201f 	nop
    2510:	d503201f 	nop
    2514:	d503201f 	nop
    2518:	d503201f 	nop
    251c:	d503201f 	nop
    2520:	d503201f 	nop
    2524:	d503201f 	nop
    2528:	d503201f 	nop
    252c:	d503201f 	nop
    2530:	d503201f 	nop
    2534:	d503201f 	nop
    2538:	d503201f 	nop
    253c:	d503201f 	nop
    2540:	d503201f 	nop
    2544:	d503201f 	nop
    2548:	d503201f 	nop
    254c:	d503201f 	nop
    2550:	d503201f 	nop
    2554:	d503201f 	nop
    2558:	d503201f 	nop
    255c:	d503201f 	nop
    2560:	d503201f 	nop
    2564:	d503201f 	nop
    2568:	d503201f 	nop
    256c:	d503201f 	nop
    2570:	d503201f 	nop
    2574:	d503201f 	nop
    2578:	d503201f 	nop
    257c:	d503201f 	nop

0000000000002580 <lower_el_aarch64_serror>:
.balign ENTRY_SIZE
lower_el_aarch64_serror: 
    b	.          
    2580:	14000000 	b	2580 <lower_el_aarch64_serror>
    2584:	d503201f 	nop
    2588:	d503201f 	nop
    258c:	d503201f 	nop
    2590:	d503201f 	nop
    2594:	d503201f 	nop
    2598:	d503201f 	nop
    259c:	d503201f 	nop
    25a0:	d503201f 	nop
    25a4:	d503201f 	nop
    25a8:	d503201f 	nop
    25ac:	d503201f 	nop
    25b0:	d503201f 	nop
    25b4:	d503201f 	nop
    25b8:	d503201f 	nop
    25bc:	d503201f 	nop
    25c0:	d503201f 	nop
    25c4:	d503201f 	nop
    25c8:	d503201f 	nop
    25cc:	d503201f 	nop
    25d0:	d503201f 	nop
    25d4:	d503201f 	nop
    25d8:	d503201f 	nop
    25dc:	d503201f 	nop
    25e0:	d503201f 	nop
    25e4:	d503201f 	nop
    25e8:	d503201f 	nop
    25ec:	d503201f 	nop
    25f0:	d503201f 	nop
    25f4:	d503201f 	nop
    25f8:	d503201f 	nop
    25fc:	d503201f 	nop

0000000000002600 <lower_el_aarch32_sync>:
/* 
 * Lower EL using AArch32
 */  
.balign ENTRY_SIZE   
lower_el_aarch32_sync:   
    b	.
    2600:	14000000 	b	2600 <lower_el_aarch32_sync>
    2604:	d503201f 	nop
    2608:	d503201f 	nop
    260c:	d503201f 	nop
    2610:	d503201f 	nop
    2614:	d503201f 	nop
    2618:	d503201f 	nop
    261c:	d503201f 	nop
    2620:	d503201f 	nop
    2624:	d503201f 	nop
    2628:	d503201f 	nop
    262c:	d503201f 	nop
    2630:	d503201f 	nop
    2634:	d503201f 	nop
    2638:	d503201f 	nop
    263c:	d503201f 	nop
    2640:	d503201f 	nop
    2644:	d503201f 	nop
    2648:	d503201f 	nop
    264c:	d503201f 	nop
    2650:	d503201f 	nop
    2654:	d503201f 	nop
    2658:	d503201f 	nop
    265c:	d503201f 	nop
    2660:	d503201f 	nop
    2664:	d503201f 	nop
    2668:	d503201f 	nop
    266c:	d503201f 	nop
    2670:	d503201f 	nop
    2674:	d503201f 	nop
    2678:	d503201f 	nop
    267c:	d503201f 	nop

0000000000002680 <lower_el_aarch32_irq>:
.balign ENTRY_SIZE
lower_el_aarch32_irq:    
    b	.
    2680:	14000000 	b	2680 <lower_el_aarch32_irq>
    2684:	d503201f 	nop
    2688:	d503201f 	nop
    268c:	d503201f 	nop
    2690:	d503201f 	nop
    2694:	d503201f 	nop
    2698:	d503201f 	nop
    269c:	d503201f 	nop
    26a0:	d503201f 	nop
    26a4:	d503201f 	nop
    26a8:	d503201f 	nop
    26ac:	d503201f 	nop
    26b0:	d503201f 	nop
    26b4:	d503201f 	nop
    26b8:	d503201f 	nop
    26bc:	d503201f 	nop
    26c0:	d503201f 	nop
    26c4:	d503201f 	nop
    26c8:	d503201f 	nop
    26cc:	d503201f 	nop
    26d0:	d503201f 	nop
    26d4:	d503201f 	nop
    26d8:	d503201f 	nop
    26dc:	d503201f 	nop
    26e0:	d503201f 	nop
    26e4:	d503201f 	nop
    26e8:	d503201f 	nop
    26ec:	d503201f 	nop
    26f0:	d503201f 	nop
    26f4:	d503201f 	nop
    26f8:	d503201f 	nop
    26fc:	d503201f 	nop

0000000000002700 <lower_el_aarch32_fiq>:
.balign ENTRY_SIZE
lower_el_aarch32_fiq:    
    b	.
    2700:	14000000 	b	2700 <lower_el_aarch32_fiq>
    2704:	d503201f 	nop
    2708:	d503201f 	nop
    270c:	d503201f 	nop
    2710:	d503201f 	nop
    2714:	d503201f 	nop
    2718:	d503201f 	nop
    271c:	d503201f 	nop
    2720:	d503201f 	nop
    2724:	d503201f 	nop
    2728:	d503201f 	nop
    272c:	d503201f 	nop
    2730:	d503201f 	nop
    2734:	d503201f 	nop
    2738:	d503201f 	nop
    273c:	d503201f 	nop
    2740:	d503201f 	nop
    2744:	d503201f 	nop
    2748:	d503201f 	nop
    274c:	d503201f 	nop
    2750:	d503201f 	nop
    2754:	d503201f 	nop
    2758:	d503201f 	nop
    275c:	d503201f 	nop
    2760:	d503201f 	nop
    2764:	d503201f 	nop
    2768:	d503201f 	nop
    276c:	d503201f 	nop
    2770:	d503201f 	nop
    2774:	d503201f 	nop
    2778:	d503201f 	nop
    277c:	d503201f 	nop

0000000000002780 <lower_el_aarch32_serror>:
.balign ENTRY_SIZE
lower_el_aarch32_serror: 
    b	.
    2780:	14000000 	b	2780 <lower_el_aarch32_serror>
    2784:	d503201f 	nop
    2788:	d503201f 	nop
    278c:	d503201f 	nop
    2790:	d503201f 	nop
    2794:	d503201f 	nop
    2798:	d503201f 	nop
    279c:	d503201f 	nop
    27a0:	d503201f 	nop
    27a4:	d503201f 	nop
    27a8:	d503201f 	nop
    27ac:	d503201f 	nop
    27b0:	d503201f 	nop
    27b4:	d503201f 	nop
    27b8:	d503201f 	nop
    27bc:	d503201f 	nop
    27c0:	d503201f 	nop
    27c4:	d503201f 	nop
    27c8:	d503201f 	nop
    27cc:	d503201f 	nop
    27d0:	d503201f 	nop
    27d4:	d503201f 	nop
    27d8:	d503201f 	nop
    27dc:	d503201f 	nop
    27e0:	d503201f 	nop
    27e4:	d503201f 	nop
    27e8:	d503201f 	nop
    27ec:	d503201f 	nop
    27f0:	d503201f 	nop
    27f4:	d503201f 	nop
    27f8:	d503201f 	nop
    27fc:	d503201f 	nop

0000000000002800 <strcpy>:
    2800:	92402c29 	and	x9, x1, #0xfff
    2804:	b200c3ec 	mov	x12, #0x101010101010101     	// #72340172838076673
    2808:	92400c31 	and	x17, x1, #0xf
    280c:	f13fc13f 	cmp	x9, #0xff0
    2810:	cb1103e8 	neg	x8, x17
    2814:	540008cc 	b.gt	292c <strcpy+0x12c>
    2818:	a9401424 	ldp	x4, x5, [x1]
    281c:	cb0c0088 	sub	x8, x4, x12
    2820:	b200d889 	orr	x9, x4, #0x7f7f7f7f7f7f7f7f
    2824:	ea290106 	bics	x6, x8, x9
    2828:	540001c1 	b.ne	2860 <strcpy+0x60>  // b.any
    282c:	cb0c00aa 	sub	x10, x5, x12
    2830:	b200d8ab 	orr	x11, x5, #0x7f7f7f7f7f7f7f7f
    2834:	ea2b0147 	bics	x7, x10, x11
    2838:	54000440 	b.eq	28c0 <strcpy+0xc0>  // b.none
    283c:	dac00ce7 	rev	x7, x7
    2840:	dac010ef 	clz	x15, x7
    2844:	d2800709 	mov	x9, #0x38                  	// #56
    2848:	8b4f0c03 	add	x3, x0, x15, lsr #3
    284c:	cb0f012f 	sub	x15, x9, x15
    2850:	9acf20a5 	lsl	x5, x5, x15
    2854:	f8001065 	stur	x5, [x3, #1]
    2858:	f9000004 	str	x4, [x0]
    285c:	d65f03c0 	ret
    2860:	dac00cc6 	rev	x6, x6
    2864:	dac010cf 	clz	x15, x6
    2868:	8b4f0c03 	add	x3, x0, x15, lsr #3
    286c:	f10061e9 	subs	x9, x15, #0x18
    2870:	540000ab 	b.lt	2884 <strcpy+0x84>  // b.tstop
    2874:	9ac92485 	lsr	x5, x4, x9
    2878:	b81fd065 	stur	w5, [x3, #-3]
    287c:	b9000004 	str	w4, [x0]
    2880:	d65f03c0 	ret
    2884:	b400004f 	cbz	x15, 288c <strcpy+0x8c>
    2888:	79000004 	strh	w4, [x0]
    288c:	3900007f 	strb	wzr, [x3]
    2890:	d65f03c0 	ret
    2894:	d503201f 	nop
    2898:	d503201f 	nop
    289c:	d503201f 	nop
    28a0:	d503201f 	nop
    28a4:	d503201f 	nop
    28a8:	d503201f 	nop
    28ac:	d503201f 	nop
    28b0:	d503201f 	nop
    28b4:	d503201f 	nop
    28b8:	d503201f 	nop
    28bc:	d503201f 	nop
    28c0:	d1004231 	sub	x17, x17, #0x10
    28c4:	a9001404 	stp	x4, x5, [x0]
    28c8:	cb110022 	sub	x2, x1, x17
    28cc:	cb110003 	sub	x3, x0, x17
    28d0:	14000002 	b	28d8 <strcpy+0xd8>
    28d4:	a8811464 	stp	x4, x5, [x3], #16
    28d8:	a8c11444 	ldp	x4, x5, [x2], #16
    28dc:	cb0c0088 	sub	x8, x4, x12
    28e0:	b200d889 	orr	x9, x4, #0x7f7f7f7f7f7f7f7f
    28e4:	cb0c00aa 	sub	x10, x5, x12
    28e8:	b200d8ab 	orr	x11, x5, #0x7f7f7f7f7f7f7f7f
    28ec:	8a290106 	bic	x6, x8, x9
    28f0:	ea2b0147 	bics	x7, x10, x11
    28f4:	fa4008c0 	ccmp	x6, #0x0, #0x0, eq	// eq = none
    28f8:	54fffee0 	b.eq	28d4 <strcpy+0xd4>  // b.none
    28fc:	f10000df 	cmp	x6, #0x0
    2900:	9a8710c6 	csel	x6, x6, x7, ne	// ne = any
    2904:	dac00cc6 	rev	x6, x6
    2908:	dac010cf 	clz	x15, x6
    290c:	910121e8 	add	x8, x15, #0x48
    2910:	910021ef 	add	x15, x15, #0x8
    2914:	9a8811ef 	csel	x15, x15, x8, ne	// ne = any
    2918:	8b4f0c42 	add	x2, x2, x15, lsr #3
    291c:	8b4f0c63 	add	x3, x3, x15, lsr #3
    2920:	a97e1444 	ldp	x4, x5, [x2, #-32]
    2924:	a93f1464 	stp	x4, x5, [x3, #-16]
    2928:	d65f03c0 	ret
    292c:	927cec22 	and	x2, x1, #0xfffffffffffffff0
    2930:	a9401444 	ldp	x4, x5, [x2]
    2934:	d37df108 	lsl	x8, x8, #3
    2938:	f2400a3f 	tst	x17, #0x7
    293c:	da9f03e9 	csetm	x9, ne	// ne = any
    2940:	9ac82529 	lsr	x9, x9, x8
    2944:	aa090084 	orr	x4, x4, x9
    2948:	aa0900ae 	orr	x14, x5, x9
    294c:	f100223f 	cmp	x17, #0x8
    2950:	da9fb084 	csinv	x4, x4, xzr, lt	// lt = tstop
    2954:	9a8eb0a5 	csel	x5, x5, x14, lt	// lt = tstop
    2958:	cb0c0088 	sub	x8, x4, x12
    295c:	b200d889 	orr	x9, x4, #0x7f7f7f7f7f7f7f7f
    2960:	cb0c00aa 	sub	x10, x5, x12
    2964:	b200d8ab 	orr	x11, x5, #0x7f7f7f7f7f7f7f7f
    2968:	8a290106 	bic	x6, x8, x9
    296c:	ea2b0147 	bics	x7, x10, x11
    2970:	fa4008c0 	ccmp	x6, #0x0, #0x0, eq	// eq = none
    2974:	54fff520 	b.eq	2818 <strcpy+0x18>  // b.none
    2978:	d37df228 	lsl	x8, x17, #3
    297c:	cb110fe9 	neg	x9, x17, lsl #3
    2980:	9ac8248d 	lsr	x13, x4, x8
    2984:	9ac920ab 	lsl	x11, x5, x9
    2988:	9ac824a5 	lsr	x5, x5, x8
    298c:	aa0d016b 	orr	x11, x11, x13
    2990:	f100223f 	cmp	x17, #0x8
    2994:	9a85b164 	csel	x4, x11, x5, lt	// lt = tstop
    2998:	cb0c0088 	sub	x8, x4, x12
    299c:	b200d889 	orr	x9, x4, #0x7f7f7f7f7f7f7f7f
    29a0:	cb0c00aa 	sub	x10, x5, x12
    29a4:	b200d8ab 	orr	x11, x5, #0x7f7f7f7f7f7f7f7f
    29a8:	8a290106 	bic	x6, x8, x9
    29ac:	b5fff5a6 	cbnz	x6, 2860 <strcpy+0x60>
    29b0:	8a2b0147 	bic	x7, x10, x11
    29b4:	17ffffa2 	b	283c <strcpy+0x3c>
	...

00000000000029c0 <strlen>:
    29c0:	92402c04 	and	x4, x0, #0xfff
    29c4:	b200c3e8 	mov	x8, #0x101010101010101     	// #72340172838076673
    29c8:	f13fc09f 	cmp	x4, #0xff0
    29cc:	5400082c 	b.gt	2ad0 <strlen+0x110>
    29d0:	a9400c02 	ldp	x2, x3, [x0]
    29d4:	cb080044 	sub	x4, x2, x8
    29d8:	b200d845 	orr	x5, x2, #0x7f7f7f7f7f7f7f7f
    29dc:	cb080066 	sub	x6, x3, x8
    29e0:	b200d867 	orr	x7, x3, #0x7f7f7f7f7f7f7f7f
    29e4:	ea250084 	bics	x4, x4, x5
    29e8:	8a2700c5 	bic	x5, x6, x7
    29ec:	fa4008a0 	ccmp	x5, #0x0, #0x0, eq	// eq = none
    29f0:	54000100 	b.eq	2a10 <strlen+0x50>  // b.none
    29f4:	9a853084 	csel	x4, x4, x5, cc	// cc = lo, ul, last
    29f8:	d2800100 	mov	x0, #0x8                   	// #8
    29fc:	dac00c84 	rev	x4, x4
    2a00:	dac01084 	clz	x4, x4
    2a04:	9a8033e0 	csel	x0, xzr, x0, cc	// cc = lo, ul, last
    2a08:	8b440c00 	add	x0, x0, x4, lsr #3
    2a0c:	d65f03c0 	ret
    2a10:	927cec01 	and	x1, x0, #0xfffffffffffffff0
    2a14:	d1004021 	sub	x1, x1, #0x10
    2a18:	a9c20c22 	ldp	x2, x3, [x1, #32]!
    2a1c:	cb080044 	sub	x4, x2, x8
    2a20:	cb080066 	sub	x6, x3, x8
    2a24:	aa060085 	orr	x5, x4, x6
    2a28:	ea081cbf 	tst	x5, x8, lsl #7
    2a2c:	54000101 	b.ne	2a4c <strlen+0x8c>  // b.any
    2a30:	a9410c22 	ldp	x2, x3, [x1, #16]
    2a34:	cb080044 	sub	x4, x2, x8
    2a38:	cb080066 	sub	x6, x3, x8
    2a3c:	aa060085 	orr	x5, x4, x6
    2a40:	ea081cbf 	tst	x5, x8, lsl #7
    2a44:	54fffea0 	b.eq	2a18 <strlen+0x58>  // b.none
    2a48:	91004021 	add	x1, x1, #0x10
    2a4c:	b200d845 	orr	x5, x2, #0x7f7f7f7f7f7f7f7f
    2a50:	b200d867 	orr	x7, x3, #0x7f7f7f7f7f7f7f7f
    2a54:	ea250084 	bics	x4, x4, x5
    2a58:	8a2700c5 	bic	x5, x6, x7
    2a5c:	fa4008a0 	ccmp	x5, #0x0, #0x0, eq	// eq = none
    2a60:	54000120 	b.eq	2a84 <strlen+0xc4>  // b.none
    2a64:	9a853084 	csel	x4, x4, x5, cc	// cc = lo, ul, last
    2a68:	cb000020 	sub	x0, x1, x0
    2a6c:	dac00c84 	rev	x4, x4
    2a70:	91002005 	add	x5, x0, #0x8
    2a74:	dac01084 	clz	x4, x4
    2a78:	9a853000 	csel	x0, x0, x5, cc	// cc = lo, ul, last
    2a7c:	8b440c00 	add	x0, x0, x4, lsr #3
    2a80:	d65f03c0 	ret
    2a84:	a9c10c22 	ldp	x2, x3, [x1, #16]!
    2a88:	cb080044 	sub	x4, x2, x8
    2a8c:	b200d845 	orr	x5, x2, #0x7f7f7f7f7f7f7f7f
    2a90:	cb080066 	sub	x6, x3, x8
    2a94:	b200d867 	orr	x7, x3, #0x7f7f7f7f7f7f7f7f
    2a98:	ea250084 	bics	x4, x4, x5
    2a9c:	8a2700c5 	bic	x5, x6, x7
    2aa0:	fa4008a0 	ccmp	x5, #0x0, #0x0, eq	// eq = none
    2aa4:	54fffe01 	b.ne	2a64 <strlen+0xa4>  // b.any
    2aa8:	a9c10c22 	ldp	x2, x3, [x1, #16]!
    2aac:	cb080044 	sub	x4, x2, x8
    2ab0:	b200d845 	orr	x5, x2, #0x7f7f7f7f7f7f7f7f
    2ab4:	cb080066 	sub	x6, x3, x8
    2ab8:	b200d867 	orr	x7, x3, #0x7f7f7f7f7f7f7f7f
    2abc:	ea250084 	bics	x4, x4, x5
    2ac0:	8a2700c5 	bic	x5, x6, x7
    2ac4:	fa4008a0 	ccmp	x5, #0x0, #0x0, eq	// eq = none
    2ac8:	54fffde0 	b.eq	2a84 <strlen+0xc4>  // b.none
    2acc:	17ffffe6 	b	2a64 <strlen+0xa4>
    2ad0:	927cec01 	and	x1, x0, #0xfffffffffffffff0
    2ad4:	a9400c22 	ldp	x2, x3, [x1]
    2ad8:	d37df004 	lsl	x4, x0, #3
    2adc:	92800007 	mov	x7, #0xffffffffffffffff    	// #-1
    2ae0:	9ac420e4 	lsl	x4, x7, x4
    2ae4:	b201c084 	orr	x4, x4, #0x8080808080808080
    2ae8:	aa240042 	orn	x2, x2, x4
    2aec:	aa240065 	orn	x5, x3, x4
    2af0:	f27d001f 	tst	x0, #0x8
    2af4:	9a870042 	csel	x2, x2, x7, eq	// eq = none
    2af8:	9a850063 	csel	x3, x3, x5, eq	// eq = none
    2afc:	17ffffc8 	b	2a1c <strlen+0x5c>

0000000000002b00 <__errno>:
    2b00:	f0000060 	adrp	x0, 11000 <JIS_action_table>
    2b04:	f9413c00 	ldr	x0, [x0, #632]
    2b08:	d65f03c0 	ret
    2b0c:	00000000 	udf	#0

0000000000002b10 <__assert_func>:
    2b10:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    2b14:	f0000064 	adrp	x4, 11000 <JIS_action_table>
    2b18:	aa0303e5 	mov	x5, x3
    2b1c:	910003fd 	mov	x29, sp
    2b20:	f9413c87 	ldr	x7, [x4, #632]
    2b24:	aa0003e3 	mov	x3, x0
    2b28:	aa0203e6 	mov	x6, x2
    2b2c:	2a0103e4 	mov	w4, w1
    2b30:	aa0503e2 	mov	x2, x5
    2b34:	d0000065 	adrp	x5, 10000 <__env_lock>
    2b38:	f9400ce0 	ldr	x0, [x7, #24]
    2b3c:	911fa0a5 	add	x5, x5, #0x7e8
    2b40:	b40000a6 	cbz	x6, 2b54 <__assert_func+0x44>
    2b44:	d0000061 	adrp	x1, 10000 <__env_lock>
    2b48:	911fe021 	add	x1, x1, #0x7f8
    2b4c:	940001d9 	bl	32b0 <fiprintf>
    2b50:	94001a50 	bl	9490 <abort>
    2b54:	d0000065 	adrp	x5, 10000 <__env_lock>
    2b58:	911820a5 	add	x5, x5, #0x608
    2b5c:	aa0503e6 	mov	x6, x5
    2b60:	17fffff9 	b	2b44 <__assert_func+0x34>
	...

0000000000002b70 <__assert>:
    2b70:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    2b74:	aa0203e3 	mov	x3, x2
    2b78:	d2800002 	mov	x2, #0x0                   	// #0
    2b7c:	910003fd 	mov	x29, sp
    2b80:	97ffffe4 	bl	2b10 <__assert_func>
	...

0000000000002b90 <_printf_r>:
    2b90:	a9b07bfd 	stp	x29, x30, [sp, #-256]!
    2b94:	128005e9 	mov	w9, #0xffffffd0            	// #-48
    2b98:	12800fe8 	mov	w8, #0xffffff80            	// #-128
    2b9c:	910003fd 	mov	x29, sp
    2ba0:	910343ea 	add	x10, sp, #0xd0
    2ba4:	910403eb 	add	x11, sp, #0x100
    2ba8:	a9032feb 	stp	x11, x11, [sp, #48]
    2bac:	f90023ea 	str	x10, [sp, #64]
    2bb0:	290923e9 	stp	w9, w8, [sp, #72]
    2bb4:	3d8017e0 	str	q0, [sp, #80]
    2bb8:	ad41c3e0 	ldp	q0, q16, [sp, #48]
    2bbc:	3d801be1 	str	q1, [sp, #96]
    2bc0:	3d801fe2 	str	q2, [sp, #112]
    2bc4:	3d8023e3 	str	q3, [sp, #128]
    2bc8:	3d8027e4 	str	q4, [sp, #144]
    2bcc:	3d802be5 	str	q5, [sp, #160]
    2bd0:	3d802fe6 	str	q6, [sp, #176]
    2bd4:	3d8033e7 	str	q7, [sp, #192]
    2bd8:	a90d0fe2 	stp	x2, x3, [sp, #208]
    2bdc:	aa0103e2 	mov	x2, x1
    2be0:	910043e3 	add	x3, sp, #0x10
    2be4:	a90e17e4 	stp	x4, x5, [sp, #224]
    2be8:	a90f1fe6 	stp	x6, x7, [sp, #240]
    2bec:	ad00c3e0 	stp	q0, q16, [sp, #16]
    2bf0:	f9400801 	ldr	x1, [x0, #16]
    2bf4:	94000377 	bl	39d0 <_vfprintf_r>
    2bf8:	a8d07bfd 	ldp	x29, x30, [sp], #256
    2bfc:	d65f03c0 	ret

0000000000002c00 <printf>:
    2c00:	a9af7bfd 	stp	x29, x30, [sp, #-272]!
    2c04:	128006eb 	mov	w11, #0xffffffc8            	// #-56
    2c08:	12800fea 	mov	w10, #0xffffff80            	// #-128
    2c0c:	910003fd 	mov	x29, sp
    2c10:	910343ec 	add	x12, sp, #0xd0
    2c14:	910443e8 	add	x8, sp, #0x110
    2c18:	f0000069 	adrp	x9, 11000 <JIS_action_table>
    2c1c:	a90323e8 	stp	x8, x8, [sp, #48]
    2c20:	aa0003e8 	mov	x8, x0
    2c24:	f90023ec 	str	x12, [sp, #64]
    2c28:	29092beb 	stp	w11, w10, [sp, #72]
    2c2c:	f9413d20 	ldr	x0, [x9, #632]
    2c30:	3d8017e0 	str	q0, [sp, #80]
    2c34:	ad41c3e0 	ldp	q0, q16, [sp, #48]
    2c38:	3d801be1 	str	q1, [sp, #96]
    2c3c:	3d801fe2 	str	q2, [sp, #112]
    2c40:	3d8023e3 	str	q3, [sp, #128]
    2c44:	3d8027e4 	str	q4, [sp, #144]
    2c48:	3d802be5 	str	q5, [sp, #160]
    2c4c:	3d802fe6 	str	q6, [sp, #176]
    2c50:	3d8033e7 	str	q7, [sp, #192]
    2c54:	a90d8be1 	stp	x1, x2, [sp, #216]
    2c58:	aa0803e2 	mov	x2, x8
    2c5c:	a90e93e3 	stp	x3, x4, [sp, #232]
    2c60:	910043e3 	add	x3, sp, #0x10
    2c64:	a90f9be5 	stp	x5, x6, [sp, #248]
    2c68:	f90087e7 	str	x7, [sp, #264]
    2c6c:	ad00c3e0 	stp	q0, q16, [sp, #16]
    2c70:	f9400801 	ldr	x1, [x0, #16]
    2c74:	94000357 	bl	39d0 <_vfprintf_r>
    2c78:	a8d17bfd 	ldp	x29, x30, [sp], #272
    2c7c:	d65f03c0 	ret

0000000000002c80 <_puts_r>:
    2c80:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
    2c84:	910003fd 	mov	x29, sp
    2c88:	a90153f3 	stp	x19, x20, [sp, #16]
    2c8c:	aa0003f4 	mov	x20, x0
    2c90:	aa0103f3 	mov	x19, x1
    2c94:	aa0103e0 	mov	x0, x1
    2c98:	97ffff4a 	bl	29c0 <strlen>
    2c9c:	f9402682 	ldr	x2, [x20, #72]
    2ca0:	91000404 	add	x4, x0, #0x1
    2ca4:	910103e6 	add	x6, sp, #0x40
    2ca8:	d0000061 	adrp	x1, 10000 <__env_lock>
    2cac:	d2800023 	mov	x3, #0x1                   	// #1
    2cb0:	9120a021 	add	x1, x1, #0x828
    2cb4:	52800045 	mov	w5, #0x2                   	// #2
    2cb8:	f90017e6 	str	x6, [sp, #40]
    2cbc:	b90033e5 	str	w5, [sp, #48]
    2cc0:	a903cfe4 	stp	x4, x19, [sp, #56]
    2cc4:	a90487e0 	stp	x0, x1, [sp, #72]
    2cc8:	f9002fe3 	str	x3, [sp, #88]
    2ccc:	f9400a93 	ldr	x19, [x20, #16]
    2cd0:	b4000482 	cbz	x2, 2d60 <_puts_r+0xe0>
    2cd4:	b940b261 	ldr	w1, [x19, #176]
    2cd8:	79c02260 	ldrsh	w0, [x19, #16]
    2cdc:	37000041 	tbnz	w1, #0, 2ce4 <_puts_r+0x64>
    2ce0:	36480380 	tbz	w0, #9, 2d50 <_puts_r+0xd0>
    2ce4:	376800c0 	tbnz	w0, #13, 2cfc <_puts_r+0x7c>
    2ce8:	b940b261 	ldr	w1, [x19, #176]
    2cec:	32130000 	orr	w0, w0, #0x2000
    2cf0:	79002260 	strh	w0, [x19, #16]
    2cf4:	12127820 	and	w0, w1, #0xffffdfff
    2cf8:	b900b260 	str	w0, [x19, #176]
    2cfc:	aa1403e0 	mov	x0, x20
    2d00:	aa1303e1 	mov	x1, x19
    2d04:	9100a3e2 	add	x2, sp, #0x28
    2d08:	940001d6 	bl	3460 <__sfvwrite_r>
    2d0c:	b940b261 	ldr	w1, [x19, #176]
    2d10:	7100001f 	cmp	w0, #0x0
    2d14:	52800154 	mov	w20, #0xa                   	// #10
    2d18:	5a9f0294 	csinv	w20, w20, wzr, eq	// eq = none
    2d1c:	37000061 	tbnz	w1, #0, 2d28 <_puts_r+0xa8>
    2d20:	79402260 	ldrh	w0, [x19, #16]
    2d24:	364800a0 	tbz	w0, #9, 2d38 <_puts_r+0xb8>
    2d28:	2a1403e0 	mov	w0, w20
    2d2c:	a94153f3 	ldp	x19, x20, [sp, #16]
    2d30:	a8c67bfd 	ldp	x29, x30, [sp], #96
    2d34:	d65f03c0 	ret
    2d38:	f9405260 	ldr	x0, [x19, #160]
    2d3c:	94001a4d 	bl	9670 <__retarget_lock_release_recursive>
    2d40:	2a1403e0 	mov	w0, w20
    2d44:	a94153f3 	ldp	x19, x20, [sp, #16]
    2d48:	a8c67bfd 	ldp	x29, x30, [sp], #96
    2d4c:	d65f03c0 	ret
    2d50:	f9405260 	ldr	x0, [x19, #160]
    2d54:	94001a37 	bl	9630 <__retarget_lock_acquire_recursive>
    2d58:	79c02260 	ldrsh	w0, [x19, #16]
    2d5c:	17ffffe2 	b	2ce4 <_puts_r+0x64>
    2d60:	aa1403e0 	mov	x0, x20
    2d64:	940000fb 	bl	3150 <__sinit>
    2d68:	17ffffdb 	b	2cd4 <_puts_r+0x54>
    2d6c:	00000000 	udf	#0

0000000000002d70 <puts>:
    2d70:	f0000062 	adrp	x2, 11000 <JIS_action_table>
    2d74:	aa0003e1 	mov	x1, x0
    2d78:	f9413c40 	ldr	x0, [x2, #632]
    2d7c:	17ffffc1 	b	2c80 <_puts_r>

0000000000002d80 <stdio_exit_handler>:
    2d80:	f0000062 	adrp	x2, 11000 <JIS_action_table>
    2d84:	90000041 	adrp	x1, a000 <_setlocale_r+0xa0>
    2d88:	910f6042 	add	x2, x2, #0x3d8
    2d8c:	910dc021 	add	x1, x1, #0x370
    2d90:	f0000060 	adrp	x0, 11000 <JIS_action_table>
    2d94:	910a0000 	add	x0, x0, #0x280
    2d98:	140002e6 	b	3930 <_fwalk_sglue>
    2d9c:	00000000 	udf	#0

0000000000002da0 <cleanup_stdio>:
    2da0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    2da4:	b0001fe2 	adrp	x2, 3ff000 <cpu_interf_buf+0xff000>
    2da8:	913fc042 	add	x2, x2, #0xff0
    2dac:	910003fd 	mov	x29, sp
    2db0:	f9400401 	ldr	x1, [x0, #8]
    2db4:	f9000bf3 	str	x19, [sp, #16]
    2db8:	aa0003f3 	mov	x19, x0
    2dbc:	eb02003f 	cmp	x1, x2
    2dc0:	54000040 	b.eq	2dc8 <cleanup_stdio+0x28>  // b.none
    2dc4:	94001d6b 	bl	a370 <_fclose_r>
    2dc8:	f9400a61 	ldr	x1, [x19, #16]
    2dcc:	d0001fe0 	adrp	x0, 400000 <__sf+0x10>
    2dd0:	9102a000 	add	x0, x0, #0xa8
    2dd4:	eb00003f 	cmp	x1, x0
    2dd8:	54000060 	b.eq	2de4 <cleanup_stdio+0x44>  // b.none
    2ddc:	aa1303e0 	mov	x0, x19
    2de0:	94001d64 	bl	a370 <_fclose_r>
    2de4:	f9400e61 	ldr	x1, [x19, #24]
    2de8:	d0001fe0 	adrp	x0, 400000 <__sf+0x10>
    2dec:	91058000 	add	x0, x0, #0x160
    2df0:	eb00003f 	cmp	x1, x0
    2df4:	540000a0 	b.eq	2e08 <cleanup_stdio+0x68>  // b.none
    2df8:	aa1303e0 	mov	x0, x19
    2dfc:	f9400bf3 	ldr	x19, [sp, #16]
    2e00:	a8c27bfd 	ldp	x29, x30, [sp], #32
    2e04:	14001d5b 	b	a370 <_fclose_r>
    2e08:	f9400bf3 	ldr	x19, [sp, #16]
    2e0c:	a8c27bfd 	ldp	x29, x30, [sp], #32
    2e10:	d65f03c0 	ret
	...

0000000000002e20 <__fp_lock>:
    2e20:	b940b020 	ldr	w0, [x1, #176]
    2e24:	37000060 	tbnz	w0, #0, 2e30 <__fp_lock+0x10>
    2e28:	79402020 	ldrh	w0, [x1, #16]
    2e2c:	36480060 	tbz	w0, #9, 2e38 <__fp_lock+0x18>
    2e30:	52800000 	mov	w0, #0x0                   	// #0
    2e34:	d65f03c0 	ret
    2e38:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    2e3c:	910003fd 	mov	x29, sp
    2e40:	f9405020 	ldr	x0, [x1, #160]
    2e44:	940019fb 	bl	9630 <__retarget_lock_acquire_recursive>
    2e48:	52800000 	mov	w0, #0x0                   	// #0
    2e4c:	a8c17bfd 	ldp	x29, x30, [sp], #16
    2e50:	d65f03c0 	ret
	...

0000000000002e60 <__fp_unlock>:
    2e60:	b940b020 	ldr	w0, [x1, #176]
    2e64:	37000060 	tbnz	w0, #0, 2e70 <__fp_unlock+0x10>
    2e68:	79402020 	ldrh	w0, [x1, #16]
    2e6c:	36480060 	tbz	w0, #9, 2e78 <__fp_unlock+0x18>
    2e70:	52800000 	mov	w0, #0x0                   	// #0
    2e74:	d65f03c0 	ret
    2e78:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    2e7c:	910003fd 	mov	x29, sp
    2e80:	f9405020 	ldr	x0, [x1, #160]
    2e84:	940019fb 	bl	9670 <__retarget_lock_release_recursive>
    2e88:	52800000 	mov	w0, #0x0                   	// #0
    2e8c:	a8c17bfd 	ldp	x29, x30, [sp], #16
    2e90:	d65f03c0 	ret
	...

0000000000002ea0 <global_stdio_init.part.0>:
    2ea0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
    2ea4:	b0001fe0 	adrp	x0, 3ff000 <cpu_interf_buf+0xff000>
    2ea8:	90000003 	adrp	x3, 2000 <_exception_vector>
    2eac:	910003fd 	mov	x29, sp
    2eb0:	91360063 	add	x3, x3, #0xd80
    2eb4:	a90153f3 	stp	x19, x20, [sp, #16]
    2eb8:	913fc013 	add	x19, x0, #0xff0
    2ebc:	d0001fe5 	adrp	x5, 400000 <__sf+0x10>
    2ec0:	52800084 	mov	w4, #0x4                   	// #4
    2ec4:	d2800102 	mov	x2, #0x8                   	// #8
    2ec8:	52800001 	mov	w1, #0x0                   	// #0
    2ecc:	a9025bf5 	stp	x21, x22, [sp, #32]
    2ed0:	b0000014 	adrp	x20, 3000 <__sfp>
    2ed4:	b0000016 	adrp	x22, 3000 <__sfp>
    2ed8:	f9001bf7 	str	x23, [sp, #48]
    2edc:	910e42d6 	add	x22, x22, #0x390
    2ee0:	f9010ca3 	str	x3, [x5, #536]
    2ee4:	91114294 	add	x20, x20, #0x450
    2ee8:	f907f81f 	str	xzr, [x0, #4080]
    2eec:	d0001fe0 	adrp	x0, 400000 <__sf+0x10>
    2ef0:	91026000 	add	x0, x0, #0x98
    2ef4:	f900067f 	str	xzr, [x19, #8]
    2ef8:	b9001264 	str	w4, [x19, #16]
    2efc:	b0000015 	adrp	x21, 3000 <__sfp>
    2f00:	f9000e7f 	str	xzr, [x19, #24]
    2f04:	911002b5 	add	x21, x21, #0x400
    2f08:	b900227f 	str	wzr, [x19, #32]
    2f0c:	b0000017 	adrp	x23, 3000 <__sfp>
    2f10:	b9002a7f 	str	wzr, [x19, #40]
    2f14:	910cc2f7 	add	x23, x23, #0x330
    2f18:	b900b27f 	str	wzr, [x19, #176]
    2f1c:	94001ef9 	bl	ab00 <memset>
    2f20:	d0001fe0 	adrp	x0, 400000 <__sf+0x10>
    2f24:	91024000 	add	x0, x0, #0x90
    2f28:	a9035e73 	stp	x19, x23, [x19, #48]
    2f2c:	a9045676 	stp	x22, x21, [x19, #64]
    2f30:	f9002a74 	str	x20, [x19, #80]
    2f34:	940019af 	bl	95f0 <__retarget_lock_init_recursive>
    2f38:	52800123 	mov	w3, #0x9                   	// #9
    2f3c:	d2800102 	mov	x2, #0x8                   	// #8
    2f40:	72a00023 	movk	w3, #0x1, lsl #16
    2f44:	52800001 	mov	w1, #0x0                   	// #0
    2f48:	d0001fe0 	adrp	x0, 400000 <__sf+0x10>
    2f4c:	91054000 	add	x0, x0, #0x150
    2f50:	f9005e7f 	str	xzr, [x19, #184]
    2f54:	f900627f 	str	xzr, [x19, #192]
    2f58:	b900ca63 	str	w3, [x19, #200]
    2f5c:	f9006a7f 	str	xzr, [x19, #208]
    2f60:	b900da7f 	str	wzr, [x19, #216]
    2f64:	b900e27f 	str	wzr, [x19, #224]
    2f68:	b9016a7f 	str	wzr, [x19, #360]
    2f6c:	94001ee5 	bl	ab00 <memset>
    2f70:	d0001fe1 	adrp	x1, 400000 <__sf+0x10>
    2f74:	9102a021 	add	x1, x1, #0xa8
    2f78:	d0001fe0 	adrp	x0, 400000 <__sf+0x10>
    2f7c:	91052000 	add	x0, x0, #0x148
    2f80:	a90ede61 	stp	x1, x23, [x19, #232]
    2f84:	a90fd676 	stp	x22, x21, [x19, #248]
    2f88:	f9008674 	str	x20, [x19, #264]
    2f8c:	94001999 	bl	95f0 <__retarget_lock_init_recursive>
    2f90:	52800243 	mov	w3, #0x12                  	// #18
    2f94:	d2800102 	mov	x2, #0x8                   	// #8
    2f98:	72a00043 	movk	w3, #0x2, lsl #16
    2f9c:	52800001 	mov	w1, #0x0                   	// #0
    2fa0:	d0001fe0 	adrp	x0, 400000 <__sf+0x10>
    2fa4:	91082000 	add	x0, x0, #0x208
    2fa8:	f900ba7f 	str	xzr, [x19, #368]
    2fac:	f900be7f 	str	xzr, [x19, #376]
    2fb0:	b9018263 	str	w3, [x19, #384]
    2fb4:	f900c67f 	str	xzr, [x19, #392]
    2fb8:	b901927f 	str	wzr, [x19, #400]
    2fbc:	b9019a7f 	str	wzr, [x19, #408]
    2fc0:	b902227f 	str	wzr, [x19, #544]
    2fc4:	94001ecf 	bl	ab00 <memset>
    2fc8:	d0001fe1 	adrp	x1, 400000 <__sf+0x10>
    2fcc:	91058021 	add	x1, x1, #0x160
    2fd0:	a91a5e61 	stp	x1, x23, [x19, #416]
    2fd4:	d0001fe0 	adrp	x0, 400000 <__sf+0x10>
    2fd8:	91080000 	add	x0, x0, #0x200
    2fdc:	a91b5676 	stp	x22, x21, [x19, #432]
    2fe0:	f900e274 	str	x20, [x19, #448]
    2fe4:	a94153f3 	ldp	x19, x20, [sp, #16]
    2fe8:	a9425bf5 	ldp	x21, x22, [sp, #32]
    2fec:	f9401bf7 	ldr	x23, [sp, #48]
    2ff0:	a8c47bfd 	ldp	x29, x30, [sp], #64
    2ff4:	1400197f 	b	95f0 <__retarget_lock_init_recursive>
	...

0000000000003000 <__sfp>:
    3000:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
    3004:	910003fd 	mov	x29, sp
    3008:	a9025bf5 	stp	x21, x22, [sp, #32]
    300c:	b0001ff5 	adrp	x21, 400000 <__sf+0x10>
    3010:	910a62b5 	add	x21, x21, #0x298
    3014:	aa0003f6 	mov	x22, x0
    3018:	aa1503e0 	mov	x0, x21
    301c:	a90153f3 	stp	x19, x20, [sp, #16]
    3020:	f9001bf7 	str	x23, [sp, #48]
    3024:	94001983 	bl	9630 <__retarget_lock_acquire_recursive>
    3028:	b0001fe0 	adrp	x0, 400000 <__sf+0x10>
    302c:	f9410c00 	ldr	x0, [x0, #536]
    3030:	b40007a0 	cbz	x0, 3124 <__sfp+0x124>
    3034:	d0000074 	adrp	x20, 11000 <JIS_action_table>
    3038:	910f6294 	add	x20, x20, #0x3d8
    303c:	52801717 	mov	w23, #0xb8                  	// #184
    3040:	b9400a82 	ldr	w2, [x20, #8]
    3044:	f9400a93 	ldr	x19, [x20, #16]
    3048:	7100005f 	cmp	w2, #0x0
    304c:	5400044d 	b.le	30d4 <__sfp+0xd4>
    3050:	9bb74c42 	umaddl	x2, w2, w23, x19
    3054:	14000004 	b	3064 <__sfp+0x64>
    3058:	9102e273 	add	x19, x19, #0xb8
    305c:	eb02027f 	cmp	x19, x2
    3060:	540003a0 	b.eq	30d4 <__sfp+0xd4>  // b.none
    3064:	79c02261 	ldrsh	w1, [x19, #16]
    3068:	35ffff81 	cbnz	w1, 3058 <__sfp+0x58>
    306c:	129fffc0 	mov	w0, #0xffff0001            	// #-65535
    3070:	b9001260 	str	w0, [x19, #16]
    3074:	b900b27f 	str	wzr, [x19, #176]
    3078:	91028260 	add	x0, x19, #0xa0
    307c:	9400195d 	bl	95f0 <__retarget_lock_init_recursive>
    3080:	aa1503e0 	mov	x0, x21
    3084:	9400197b 	bl	9670 <__retarget_lock_release_recursive>
    3088:	f900027f 	str	xzr, [x19]
    308c:	9102a260 	add	x0, x19, #0xa8
    3090:	f900067f 	str	xzr, [x19, #8]
    3094:	d2800102 	mov	x2, #0x8                   	// #8
    3098:	f9000e7f 	str	xzr, [x19, #24]
    309c:	52800001 	mov	w1, #0x0                   	// #0
    30a0:	b900227f 	str	wzr, [x19, #32]
    30a4:	b9002a7f 	str	wzr, [x19, #40]
    30a8:	94001e96 	bl	ab00 <memset>
    30ac:	f9002e7f 	str	xzr, [x19, #88]
    30b0:	b900627f 	str	wzr, [x19, #96]
    30b4:	f9003e7f 	str	xzr, [x19, #120]
    30b8:	b900827f 	str	wzr, [x19, #128]
    30bc:	a9425bf5 	ldp	x21, x22, [sp, #32]
    30c0:	aa1303e0 	mov	x0, x19
    30c4:	a94153f3 	ldp	x19, x20, [sp, #16]
    30c8:	f9401bf7 	ldr	x23, [sp, #48]
    30cc:	a8c47bfd 	ldp	x29, x30, [sp], #64
    30d0:	d65f03c0 	ret
    30d4:	f9400293 	ldr	x19, [x20]
    30d8:	b4000073 	cbz	x19, 30e4 <__sfp+0xe4>
    30dc:	aa1303f4 	mov	x20, x19
    30e0:	17ffffd8 	b	3040 <__sfp+0x40>
    30e4:	aa1603e0 	mov	x0, x22
    30e8:	d2805f01 	mov	x1, #0x2f8                 	// #760
    30ec:	940016dd 	bl	8c60 <_malloc_r>
    30f0:	aa0003f3 	mov	x19, x0
    30f4:	b40001c0 	cbz	x0, 312c <__sfp+0x12c>
    30f8:	91006000 	add	x0, x0, #0x18
    30fc:	52800081 	mov	w1, #0x4                   	// #4
    3100:	f900027f 	str	xzr, [x19]
    3104:	d2805c02 	mov	x2, #0x2e0                 	// #736
    3108:	b9000a61 	str	w1, [x19, #8]
    310c:	52800001 	mov	w1, #0x0                   	// #0
    3110:	f9000a60 	str	x0, [x19, #16]
    3114:	94001e7b 	bl	ab00 <memset>
    3118:	f9000293 	str	x19, [x20]
    311c:	aa1303f4 	mov	x20, x19
    3120:	17ffffc8 	b	3040 <__sfp+0x40>
    3124:	97ffff5f 	bl	2ea0 <global_stdio_init.part.0>
    3128:	17ffffc3 	b	3034 <__sfp+0x34>
    312c:	f900029f 	str	xzr, [x20]
    3130:	aa1503e0 	mov	x0, x21
    3134:	9400194f 	bl	9670 <__retarget_lock_release_recursive>
    3138:	52800180 	mov	w0, #0xc                   	// #12
    313c:	b90002c0 	str	w0, [x22]
    3140:	17ffffdf 	b	30bc <__sfp+0xbc>
	...

0000000000003150 <__sinit>:
    3150:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    3154:	910003fd 	mov	x29, sp
    3158:	a90153f3 	stp	x19, x20, [sp, #16]
    315c:	aa0003f4 	mov	x20, x0
    3160:	b0001ff3 	adrp	x19, 400000 <__sf+0x10>
    3164:	910a6273 	add	x19, x19, #0x298
    3168:	aa1303e0 	mov	x0, x19
    316c:	94001931 	bl	9630 <__retarget_lock_acquire_recursive>
    3170:	f9402680 	ldr	x0, [x20, #72]
    3174:	b50000e0 	cbnz	x0, 3190 <__sinit+0x40>
    3178:	b0001fe1 	adrp	x1, 400000 <__sf+0x10>
    317c:	f0ffffe0 	adrp	x0, 2000 <_exception_vector>
    3180:	91368000 	add	x0, x0, #0xda0
    3184:	f9002680 	str	x0, [x20, #72]
    3188:	f9410c20 	ldr	x0, [x1, #536]
    318c:	b40000a0 	cbz	x0, 31a0 <__sinit+0x50>
    3190:	aa1303e0 	mov	x0, x19
    3194:	a94153f3 	ldp	x19, x20, [sp, #16]
    3198:	a8c27bfd 	ldp	x29, x30, [sp], #32
    319c:	14001935 	b	9670 <__retarget_lock_release_recursive>
    31a0:	97ffff40 	bl	2ea0 <global_stdio_init.part.0>
    31a4:	aa1303e0 	mov	x0, x19
    31a8:	a94153f3 	ldp	x19, x20, [sp, #16]
    31ac:	a8c27bfd 	ldp	x29, x30, [sp], #32
    31b0:	14001930 	b	9670 <__retarget_lock_release_recursive>
	...

00000000000031c0 <__sfp_lock_acquire>:
    31c0:	b0001fe0 	adrp	x0, 400000 <__sf+0x10>
    31c4:	910a6000 	add	x0, x0, #0x298
    31c8:	1400191a 	b	9630 <__retarget_lock_acquire_recursive>
    31cc:	00000000 	udf	#0

00000000000031d0 <__sfp_lock_release>:
    31d0:	b0001fe0 	adrp	x0, 400000 <__sf+0x10>
    31d4:	910a6000 	add	x0, x0, #0x298
    31d8:	14001926 	b	9670 <__retarget_lock_release_recursive>
    31dc:	00000000 	udf	#0

00000000000031e0 <__fp_lock_all>:
    31e0:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    31e4:	b0001fe0 	adrp	x0, 400000 <__sf+0x10>
    31e8:	910a6000 	add	x0, x0, #0x298
    31ec:	910003fd 	mov	x29, sp
    31f0:	94001910 	bl	9630 <__retarget_lock_acquire_recursive>
    31f4:	a8c17bfd 	ldp	x29, x30, [sp], #16
    31f8:	d0000062 	adrp	x2, 11000 <JIS_action_table>
    31fc:	f0ffffe1 	adrp	x1, 2000 <_exception_vector>
    3200:	910f6042 	add	x2, x2, #0x3d8
    3204:	91388021 	add	x1, x1, #0xe20
    3208:	d2800000 	mov	x0, #0x0                   	// #0
    320c:	140001c9 	b	3930 <_fwalk_sglue>

0000000000003210 <__fp_unlock_all>:
    3210:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    3214:	d0000062 	adrp	x2, 11000 <JIS_action_table>
    3218:	f0ffffe1 	adrp	x1, 2000 <_exception_vector>
    321c:	910003fd 	mov	x29, sp
    3220:	910f6042 	add	x2, x2, #0x3d8
    3224:	91398021 	add	x1, x1, #0xe60
    3228:	d2800000 	mov	x0, #0x0                   	// #0
    322c:	940001c1 	bl	3930 <_fwalk_sglue>
    3230:	a8c17bfd 	ldp	x29, x30, [sp], #16
    3234:	b0001fe0 	adrp	x0, 400000 <__sf+0x10>
    3238:	910a6000 	add	x0, x0, #0x298
    323c:	1400190d 	b	9670 <__retarget_lock_release_recursive>

0000000000003240 <_fiprintf_r>:
    3240:	a9b07bfd 	stp	x29, x30, [sp, #-256]!
    3244:	128004e9 	mov	w9, #0xffffffd8            	// #-40
    3248:	12800fe8 	mov	w8, #0xffffff80            	// #-128
    324c:	910003fd 	mov	x29, sp
    3250:	910343ea 	add	x10, sp, #0xd0
    3254:	910403eb 	add	x11, sp, #0x100
    3258:	a9032feb 	stp	x11, x11, [sp, #48]
    325c:	f90023ea 	str	x10, [sp, #64]
    3260:	290923e9 	stp	w9, w8, [sp, #72]
    3264:	3d8017e0 	str	q0, [sp, #80]
    3268:	ad41c3e0 	ldp	q0, q16, [sp, #48]
    326c:	3d801be1 	str	q1, [sp, #96]
    3270:	3d801fe2 	str	q2, [sp, #112]
    3274:	ad00c3e0 	stp	q0, q16, [sp, #16]
    3278:	3d8023e3 	str	q3, [sp, #128]
    327c:	3d8027e4 	str	q4, [sp, #144]
    3280:	3d802be5 	str	q5, [sp, #160]
    3284:	3d802fe6 	str	q6, [sp, #176]
    3288:	3d8033e7 	str	q7, [sp, #192]
    328c:	a90d93e3 	stp	x3, x4, [sp, #216]
    3290:	910043e3 	add	x3, sp, #0x10
    3294:	a90e9be5 	stp	x5, x6, [sp, #232]
    3298:	f9007fe7 	str	x7, [sp, #248]
    329c:	94000f21 	bl	6f20 <_vfiprintf_r>
    32a0:	a8d07bfd 	ldp	x29, x30, [sp], #256
    32a4:	d65f03c0 	ret
	...

00000000000032b0 <fiprintf>:
    32b0:	a9b07bfd 	stp	x29, x30, [sp, #-256]!
    32b4:	128005eb 	mov	w11, #0xffffffd0            	// #-48
    32b8:	12800fea 	mov	w10, #0xffffff80            	// #-128
    32bc:	910003fd 	mov	x29, sp
    32c0:	910403ec 	add	x12, sp, #0x100
    32c4:	910343e8 	add	x8, sp, #0xd0
    32c8:	d0000069 	adrp	x9, 11000 <JIS_action_table>
    32cc:	a90333ec 	stp	x12, x12, [sp, #48]
    32d0:	f90023e8 	str	x8, [sp, #64]
    32d4:	aa0103e8 	mov	x8, x1
    32d8:	29092beb 	stp	w11, w10, [sp, #72]
    32dc:	aa0003e1 	mov	x1, x0
    32e0:	f9413d20 	ldr	x0, [x9, #632]
    32e4:	3d8017e0 	str	q0, [sp, #80]
    32e8:	ad41c3e0 	ldp	q0, q16, [sp, #48]
    32ec:	3d801be1 	str	q1, [sp, #96]
    32f0:	3d801fe2 	str	q2, [sp, #112]
    32f4:	ad00c3e0 	stp	q0, q16, [sp, #16]
    32f8:	3d8023e3 	str	q3, [sp, #128]
    32fc:	3d8027e4 	str	q4, [sp, #144]
    3300:	3d802be5 	str	q5, [sp, #160]
    3304:	3d802fe6 	str	q6, [sp, #176]
    3308:	3d8033e7 	str	q7, [sp, #192]
    330c:	a90d0fe2 	stp	x2, x3, [sp, #208]
    3310:	910043e3 	add	x3, sp, #0x10
    3314:	aa0803e2 	mov	x2, x8
    3318:	a90e17e4 	stp	x4, x5, [sp, #224]
    331c:	a90f1fe6 	stp	x6, x7, [sp, #240]
    3320:	94000f00 	bl	6f20 <_vfiprintf_r>
    3324:	a8d07bfd 	ldp	x29, x30, [sp], #256
    3328:	d65f03c0 	ret
    332c:	00000000 	udf	#0

0000000000003330 <__sread>:
    3330:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    3334:	93407c63 	sxtw	x3, w3
    3338:	910003fd 	mov	x29, sp
    333c:	f9000bf3 	str	x19, [sp, #16]
    3340:	aa0103f3 	mov	x19, x1
    3344:	79c02421 	ldrsh	w1, [x1, #18]
    3348:	940029b2 	bl	da10 <_read_r>
    334c:	b7f800e0 	tbnz	x0, #63, 3368 <__sread+0x38>
    3350:	f9404a61 	ldr	x1, [x19, #144]
    3354:	8b000021 	add	x1, x1, x0
    3358:	f9004a61 	str	x1, [x19, #144]
    335c:	f9400bf3 	ldr	x19, [sp, #16]
    3360:	a8c27bfd 	ldp	x29, x30, [sp], #32
    3364:	d65f03c0 	ret
    3368:	79402261 	ldrh	w1, [x19, #16]
    336c:	12137821 	and	w1, w1, #0xffffefff
    3370:	79002261 	strh	w1, [x19, #16]
    3374:	f9400bf3 	ldr	x19, [sp, #16]
    3378:	a8c27bfd 	ldp	x29, x30, [sp], #32
    337c:	d65f03c0 	ret

0000000000003380 <__seofread>:
    3380:	52800000 	mov	w0, #0x0                   	// #0
    3384:	d65f03c0 	ret
	...

0000000000003390 <__swrite>:
    3390:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    3394:	910003fd 	mov	x29, sp
    3398:	79c02024 	ldrsh	w4, [x1, #16]
    339c:	a90153f3 	stp	x19, x20, [sp, #16]
    33a0:	aa0103f3 	mov	x19, x1
    33a4:	aa0003f4 	mov	x20, x0
    33a8:	a9025bf5 	stp	x21, x22, [sp, #32]
    33ac:	aa0203f5 	mov	x21, x2
    33b0:	2a0303f6 	mov	w22, w3
    33b4:	37400184 	tbnz	w4, #8, 33e4 <__swrite+0x54>
    33b8:	79c02661 	ldrsh	w1, [x19, #18]
    33bc:	12137884 	and	w4, w4, #0xffffefff
    33c0:	79002264 	strh	w4, [x19, #16]
    33c4:	93407ec3 	sxtw	x3, w22
    33c8:	aa1503e2 	mov	x2, x21
    33cc:	aa1403e0 	mov	x0, x20
    33d0:	97fff555 	bl	924 <_write_r>
    33d4:	a94153f3 	ldp	x19, x20, [sp, #16]
    33d8:	a9425bf5 	ldp	x21, x22, [sp, #32]
    33dc:	a8c37bfd 	ldp	x29, x30, [sp], #48
    33e0:	d65f03c0 	ret
    33e4:	79c02421 	ldrsh	w1, [x1, #18]
    33e8:	52800043 	mov	w3, #0x2                   	// #2
    33ec:	d2800002 	mov	x2, #0x0                   	// #0
    33f0:	94002970 	bl	d9b0 <_lseek_r>
    33f4:	79c02264 	ldrsh	w4, [x19, #16]
    33f8:	17fffff0 	b	33b8 <__swrite+0x28>
    33fc:	00000000 	udf	#0

0000000000003400 <__sseek>:
    3400:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    3404:	910003fd 	mov	x29, sp
    3408:	f9000bf3 	str	x19, [sp, #16]
    340c:	aa0103f3 	mov	x19, x1
    3410:	79c02421 	ldrsh	w1, [x1, #18]
    3414:	94002967 	bl	d9b0 <_lseek_r>
    3418:	79c02261 	ldrsh	w1, [x19, #16]
    341c:	b100041f 	cmn	x0, #0x1
    3420:	540000e0 	b.eq	343c <__sseek+0x3c>  // b.none
    3424:	32140021 	orr	w1, w1, #0x1000
    3428:	79002261 	strh	w1, [x19, #16]
    342c:	f9004a60 	str	x0, [x19, #144]
    3430:	f9400bf3 	ldr	x19, [sp, #16]
    3434:	a8c27bfd 	ldp	x29, x30, [sp], #32
    3438:	d65f03c0 	ret
    343c:	12137821 	and	w1, w1, #0xffffefff
    3440:	79002261 	strh	w1, [x19, #16]
    3444:	f9400bf3 	ldr	x19, [sp, #16]
    3448:	a8c27bfd 	ldp	x29, x30, [sp], #32
    344c:	d65f03c0 	ret

0000000000003450 <__sclose>:
    3450:	79c02421 	ldrsh	w1, [x1, #18]
    3454:	1400230b 	b	c080 <_close_r>
	...

0000000000003460 <__sfvwrite_r>:
    3460:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
    3464:	910003fd 	mov	x29, sp
    3468:	a9025bf5 	stp	x21, x22, [sp, #32]
    346c:	aa0003f5 	mov	x21, x0
    3470:	f9400840 	ldr	x0, [x2, #16]
    3474:	b4000ac0 	cbz	x0, 35cc <__sfvwrite_r+0x16c>
    3478:	79c02025 	ldrsh	w5, [x1, #16]
    347c:	a90153f3 	stp	x19, x20, [sp, #16]
    3480:	aa0103f3 	mov	x19, x1
    3484:	a90573fb 	stp	x27, x28, [sp, #80]
    3488:	aa0203fb 	mov	x27, x2
    348c:	36180a85 	tbz	w5, #3, 35dc <__sfvwrite_r+0x17c>
    3490:	f9400c20 	ldr	x0, [x1, #24]
    3494:	b4000a40 	cbz	x0, 35dc <__sfvwrite_r+0x17c>
    3498:	a90363f7 	stp	x23, x24, [sp, #48]
    349c:	f9400374 	ldr	x20, [x27]
    34a0:	360803e5 	tbz	w5, #1, 351c <__sfvwrite_r+0xbc>
    34a4:	f9401a61 	ldr	x1, [x19, #48]
    34a8:	d2800017 	mov	x23, #0x0                   	// #0
    34ac:	f9402264 	ldr	x4, [x19, #64]
    34b0:	d2800016 	mov	x22, #0x0                   	// #0
    34b4:	b27653f8 	mov	x24, #0x7ffffc00            	// #2147482624
    34b8:	eb1802df 	cmp	x22, x24
    34bc:	aa1703e2 	mov	x2, x23
    34c0:	9a9892c3 	csel	x3, x22, x24, ls	// ls = plast
    34c4:	aa1503e0 	mov	x0, x21
    34c8:	b4000256 	cbz	x22, 3510 <__sfvwrite_r+0xb0>
    34cc:	d63f0080 	blr	x4
    34d0:	7100001f 	cmp	w0, #0x0
    34d4:	5400216d 	b.le	3900 <__sfvwrite_r+0x4a0>
    34d8:	f9400b61 	ldr	x1, [x27, #16]
    34dc:	93407c00 	sxtw	x0, w0
    34e0:	8b0002f7 	add	x23, x23, x0
    34e4:	cb0002d6 	sub	x22, x22, x0
    34e8:	cb000020 	sub	x0, x1, x0
    34ec:	f9000b60 	str	x0, [x27, #16]
    34f0:	b40020c0 	cbz	x0, 3908 <__sfvwrite_r+0x4a8>
    34f4:	eb1802df 	cmp	x22, x24
    34f8:	aa1703e2 	mov	x2, x23
    34fc:	f9401a61 	ldr	x1, [x19, #48]
    3500:	9a9892c3 	csel	x3, x22, x24, ls	// ls = plast
    3504:	f9402264 	ldr	x4, [x19, #64]
    3508:	aa1503e0 	mov	x0, x21
    350c:	b5fffe16 	cbnz	x22, 34cc <__sfvwrite_r+0x6c>
    3510:	a9405a97 	ldp	x23, x22, [x20]
    3514:	91004294 	add	x20, x20, #0x10
    3518:	17ffffe8 	b	34b8 <__sfvwrite_r+0x58>
    351c:	a9046bf9 	stp	x25, x26, [sp, #64]
    3520:	36000a65 	tbz	w5, #0, 366c <__sfvwrite_r+0x20c>
    3524:	52800018 	mov	w24, #0x0                   	// #0
    3528:	52800000 	mov	w0, #0x0                   	// #0
    352c:	d280001a 	mov	x26, #0x0                   	// #0
    3530:	d2800019 	mov	x25, #0x0                   	// #0
    3534:	d503201f 	nop
    3538:	b40007f9 	cbz	x25, 3634 <__sfvwrite_r+0x1d4>
    353c:	34000860 	cbz	w0, 3648 <__sfvwrite_r+0x1e8>
    3540:	f9400260 	ldr	x0, [x19]
    3544:	93407f17 	sxtw	x23, w24
    3548:	f9400e61 	ldr	x1, [x19, #24]
    354c:	eb1902ff 	cmp	x23, x25
    3550:	b9400e76 	ldr	w22, [x19, #12]
    3554:	9a9992f7 	csel	x23, x23, x25, ls	// ls = plast
    3558:	b9402263 	ldr	w3, [x19, #32]
    355c:	eb01001f 	cmp	x0, x1
    3560:	0b160076 	add	w22, w3, w22
    3564:	7a5682e4 	ccmp	w23, w22, #0x4, hi	// hi = pmore
    3568:	540019ac 	b.gt	389c <__sfvwrite_r+0x43c>
    356c:	6b17007f 	cmp	w3, w23
    3570:	540017ec 	b.gt	386c <__sfvwrite_r+0x40c>
    3574:	f9401a61 	ldr	x1, [x19, #48]
    3578:	aa1a03e2 	mov	x2, x26
    357c:	f9402264 	ldr	x4, [x19, #64]
    3580:	aa1503e0 	mov	x0, x21
    3584:	d63f0080 	blr	x4
    3588:	2a0003f6 	mov	w22, w0
    358c:	7100001f 	cmp	w0, #0x0
    3590:	540003cd 	b.le	3608 <__sfvwrite_r+0x1a8>
    3594:	6b160318 	subs	w24, w24, w22
    3598:	52800020 	mov	w0, #0x1                   	// #1
    359c:	540002e0 	b.eq	35f8 <__sfvwrite_r+0x198>  // b.none
    35a0:	f9400b61 	ldr	x1, [x27, #16]
    35a4:	93407ed6 	sxtw	x22, w22
    35a8:	8b16035a 	add	x26, x26, x22
    35ac:	cb160339 	sub	x25, x25, x22
    35b0:	cb160021 	sub	x1, x1, x22
    35b4:	f9000b61 	str	x1, [x27, #16]
    35b8:	b5fffc01 	cbnz	x1, 3538 <__sfvwrite_r+0xd8>
    35bc:	a94153f3 	ldp	x19, x20, [sp, #16]
    35c0:	a94363f7 	ldp	x23, x24, [sp, #48]
    35c4:	a9446bf9 	ldp	x25, x26, [sp, #64]
    35c8:	a94573fb 	ldp	x27, x28, [sp, #80]
    35cc:	52800000 	mov	w0, #0x0                   	// #0
    35d0:	a9425bf5 	ldp	x21, x22, [sp, #32]
    35d4:	a8c67bfd 	ldp	x29, x30, [sp], #96
    35d8:	d65f03c0 	ret
    35dc:	aa1303e1 	mov	x1, x19
    35e0:	aa1503e0 	mov	x0, x21
    35e4:	94001bef 	bl	a5a0 <__swsetup_r>
    35e8:	350001a0 	cbnz	w0, 361c <__sfvwrite_r+0x1bc>
    35ec:	79c02265 	ldrsh	w5, [x19, #16]
    35f0:	a90363f7 	stp	x23, x24, [sp, #48]
    35f4:	17ffffaa 	b	349c <__sfvwrite_r+0x3c>
    35f8:	aa1303e1 	mov	x1, x19
    35fc:	aa1503e0 	mov	x0, x21
    3600:	94002364 	bl	c390 <_fflush_r>
    3604:	34fffce0 	cbz	w0, 35a0 <__sfvwrite_r+0x140>
    3608:	a9446bf9 	ldp	x25, x26, [sp, #64]
    360c:	79c02260 	ldrsh	w0, [x19, #16]
    3610:	a94363f7 	ldp	x23, x24, [sp, #48]
    3614:	321a0000 	orr	w0, w0, #0x40
    3618:	79002260 	strh	w0, [x19, #16]
    361c:	a94153f3 	ldp	x19, x20, [sp, #16]
    3620:	12800000 	mov	w0, #0xffffffff            	// #-1
    3624:	a9425bf5 	ldp	x21, x22, [sp, #32]
    3628:	a94573fb 	ldp	x27, x28, [sp, #80]
    362c:	a8c67bfd 	ldp	x29, x30, [sp], #96
    3630:	d65f03c0 	ret
    3634:	f9400699 	ldr	x25, [x20, #8]
    3638:	aa1403e0 	mov	x0, x20
    363c:	91004294 	add	x20, x20, #0x10
    3640:	b4ffffb9 	cbz	x25, 3634 <__sfvwrite_r+0x1d4>
    3644:	f940001a 	ldr	x26, [x0]
    3648:	aa1903e2 	mov	x2, x25
    364c:	aa1a03e0 	mov	x0, x26
    3650:	52800141 	mov	w1, #0xa                   	// #10
    3654:	94001b9b 	bl	a4c0 <memchr>
    3658:	91000418 	add	x24, x0, #0x1
    365c:	f100001f 	cmp	x0, #0x0
    3660:	cb1a0318 	sub	x24, x24, x26
    3664:	1a991718 	csinc	w24, w24, w25, ne	// ne = any
    3668:	17ffffb6 	b	3540 <__sfvwrite_r+0xe0>
    366c:	f9400264 	ldr	x4, [x19]
    3670:	d280001c 	mov	x28, #0x0                   	// #0
    3674:	b9400e61 	ldr	w1, [x19, #12]
    3678:	d280001a 	mov	x26, #0x0                   	// #0
    367c:	d503201f 	nop
    3680:	aa0403e0 	mov	x0, x4
    3684:	2a0103f8 	mov	w24, w1
    3688:	b40003fa 	cbz	x26, 3704 <__sfvwrite_r+0x2a4>
    368c:	36480425 	tbz	w5, #9, 3710 <__sfvwrite_r+0x2b0>
    3690:	93407c37 	sxtw	x23, w1
    3694:	eb1a02ff 	cmp	x23, x26
    3698:	540008c9 	b.ls	37b0 <__sfvwrite_r+0x350>  // b.plast
    369c:	93407f41 	sxtw	x1, w26
    36a0:	aa0103f9 	mov	x25, x1
    36a4:	aa0403e0 	mov	x0, x4
    36a8:	aa0103f7 	mov	x23, x1
    36ac:	2a1a03f8 	mov	w24, w26
    36b0:	aa1c03e1 	mov	x1, x28
    36b4:	aa1703e2 	mov	x2, x23
    36b8:	94001ce2 	bl	aa40 <memmove>
    36bc:	f9400264 	ldr	x4, [x19]
    36c0:	b9400e61 	ldr	w1, [x19, #12]
    36c4:	8b170084 	add	x4, x4, x23
    36c8:	f9000264 	str	x4, [x19]
    36cc:	4b180021 	sub	w1, w1, w24
    36d0:	b9000e61 	str	w1, [x19, #12]
    36d4:	f9400b60 	ldr	x0, [x27, #16]
    36d8:	8b19039c 	add	x28, x28, x25
    36dc:	cb19035a 	sub	x26, x26, x25
    36e0:	cb190000 	sub	x0, x0, x25
    36e4:	f9000b60 	str	x0, [x27, #16]
    36e8:	b4fff6a0 	cbz	x0, 35bc <__sfvwrite_r+0x15c>
    36ec:	f9400264 	ldr	x4, [x19]
    36f0:	b9400e61 	ldr	w1, [x19, #12]
    36f4:	79c02265 	ldrsh	w5, [x19, #16]
    36f8:	aa0403e0 	mov	x0, x4
    36fc:	2a0103f8 	mov	w24, w1
    3700:	b5fffc7a 	cbnz	x26, 368c <__sfvwrite_r+0x22c>
    3704:	a9406a9c 	ldp	x28, x26, [x20]
    3708:	91004294 	add	x20, x20, #0x10
    370c:	17ffffdd 	b	3680 <__sfvwrite_r+0x220>
    3710:	f9400e60 	ldr	x0, [x19, #24]
    3714:	eb04001f 	cmp	x0, x4
    3718:	54000243 	b.cc	3760 <__sfvwrite_r+0x300>  // b.lo, b.ul, b.last
    371c:	b9402265 	ldr	w5, [x19, #32]
    3720:	eb25c35f 	cmp	x26, w5, sxtw
    3724:	540001e3 	b.cc	3760 <__sfvwrite_r+0x300>  // b.lo, b.ul, b.last
    3728:	b2407be0 	mov	x0, #0x7fffffff            	// #2147483647
    372c:	eb00035f 	cmp	x26, x0
    3730:	9a809343 	csel	x3, x26, x0, ls	// ls = plast
    3734:	aa1c03e2 	mov	x2, x28
    3738:	f9401a61 	ldr	x1, [x19, #48]
    373c:	aa1503e0 	mov	x0, x21
    3740:	1ac50c63 	sdiv	w3, w3, w5
    3744:	f9402264 	ldr	x4, [x19, #64]
    3748:	1b057c63 	mul	w3, w3, w5
    374c:	d63f0080 	blr	x4
    3750:	7100001f 	cmp	w0, #0x0
    3754:	54fff5ad 	b.le	3608 <__sfvwrite_r+0x1a8>
    3758:	93407c19 	sxtw	x25, w0
    375c:	17ffffde 	b	36d4 <__sfvwrite_r+0x274>
    3760:	93407c23 	sxtw	x3, w1
    3764:	aa0403e0 	mov	x0, x4
    3768:	eb1a007f 	cmp	x3, x26
    376c:	aa1c03e1 	mov	x1, x28
    3770:	9a9a9078 	csel	x24, x3, x26, ls	// ls = plast
    3774:	93407f19 	sxtw	x25, w24
    3778:	aa1903e2 	mov	x2, x25
    377c:	94001cb1 	bl	aa40 <memmove>
    3780:	f9400264 	ldr	x4, [x19]
    3784:	b9400e61 	ldr	w1, [x19, #12]
    3788:	8b190084 	add	x4, x4, x25
    378c:	f9000264 	str	x4, [x19]
    3790:	4b180021 	sub	w1, w1, w24
    3794:	b9000e61 	str	w1, [x19, #12]
    3798:	35fff9e1 	cbnz	w1, 36d4 <__sfvwrite_r+0x274>
    379c:	aa1303e1 	mov	x1, x19
    37a0:	aa1503e0 	mov	x0, x21
    37a4:	940022fb 	bl	c390 <_fflush_r>
    37a8:	34fff960 	cbz	w0, 36d4 <__sfvwrite_r+0x274>
    37ac:	17ffff97 	b	3608 <__sfvwrite_r+0x1a8>
    37b0:	93407f59 	sxtw	x25, w26
    37b4:	52809001 	mov	w1, #0x480                 	// #1152
    37b8:	6a0100bf 	tst	w5, w1
    37bc:	54fff7a0 	b.eq	36b0 <__sfvwrite_r+0x250>  // b.none
    37c0:	b9402266 	ldr	w6, [x19, #32]
    37c4:	f9400e61 	ldr	x1, [x19, #24]
    37c8:	0b0604c6 	add	w6, w6, w6, lsl #1
    37cc:	cb010099 	sub	x25, x4, x1
    37d0:	0b467cc6 	add	w6, w6, w6, lsr #31
    37d4:	93407f36 	sxtw	x22, w25
    37d8:	13017cd7 	asr	w23, w6, #1
    37dc:	910006c0 	add	x0, x22, #0x1
    37e0:	8b1a0000 	add	x0, x0, x26
    37e4:	93407ee2 	sxtw	x2, w23
    37e8:	eb00005f 	cmp	x2, x0
    37ec:	54000082 	b.cs	37fc <__sfvwrite_r+0x39c>  // b.hs, b.nlast
    37f0:	11000726 	add	w6, w25, #0x1
    37f4:	0b1a00d7 	add	w23, w6, w26
    37f8:	93407ee2 	sxtw	x2, w23
    37fc:	36500685 	tbz	w5, #10, 38cc <__sfvwrite_r+0x46c>
    3800:	aa0203e1 	mov	x1, x2
    3804:	aa1503e0 	mov	x0, x21
    3808:	94001516 	bl	8c60 <_malloc_r>
    380c:	aa0003f8 	mov	x24, x0
    3810:	b4000840 	cbz	x0, 3918 <__sfvwrite_r+0x4b8>
    3814:	f9400e61 	ldr	x1, [x19, #24]
    3818:	aa1603e2 	mov	x2, x22
    381c:	94001c29 	bl	a8c0 <memcpy>
    3820:	79402260 	ldrh	w0, [x19, #16]
    3824:	12809001 	mov	w1, #0xfffffb7f            	// #-1153
    3828:	0a010000 	and	w0, w0, w1
    382c:	32190000 	orr	w0, w0, #0x80
    3830:	79002260 	strh	w0, [x19, #16]
    3834:	8b160300 	add	x0, x24, x22
    3838:	4b1902e4 	sub	w4, w23, w25
    383c:	93407f59 	sxtw	x25, w26
    3840:	f9000260 	str	x0, [x19]
    3844:	b9000e64 	str	w4, [x19, #12]
    3848:	aa1903e1 	mov	x1, x25
    384c:	f9000e78 	str	x24, [x19, #24]
    3850:	aa0003e4 	mov	x4, x0
    3854:	b9002277 	str	w23, [x19, #32]
    3858:	2a1a03f8 	mov	w24, w26
    385c:	eb1a033f 	cmp	x25, x26
    3860:	54fff208 	b.hi	36a0 <__sfvwrite_r+0x240>  // b.pmore
    3864:	aa1903f7 	mov	x23, x25
    3868:	17ffff92 	b	36b0 <__sfvwrite_r+0x250>
    386c:	93407efc 	sxtw	x28, w23
    3870:	aa1a03e1 	mov	x1, x26
    3874:	aa1c03e2 	mov	x2, x28
    3878:	94001c72 	bl	aa40 <memmove>
    387c:	f9400260 	ldr	x0, [x19]
    3880:	2a1703f6 	mov	w22, w23
    3884:	b9400e61 	ldr	w1, [x19, #12]
    3888:	8b1c0000 	add	x0, x0, x28
    388c:	f9000260 	str	x0, [x19]
    3890:	4b170021 	sub	w1, w1, w23
    3894:	b9000e61 	str	w1, [x19, #12]
    3898:	17ffff3f 	b	3594 <__sfvwrite_r+0x134>
    389c:	93407ed7 	sxtw	x23, w22
    38a0:	aa1a03e1 	mov	x1, x26
    38a4:	aa1703e2 	mov	x2, x23
    38a8:	94001c66 	bl	aa40 <memmove>
    38ac:	f9400262 	ldr	x2, [x19]
    38b0:	aa1303e1 	mov	x1, x19
    38b4:	aa1503e0 	mov	x0, x21
    38b8:	8b170042 	add	x2, x2, x23
    38bc:	f9000262 	str	x2, [x19]
    38c0:	940022b4 	bl	c390 <_fflush_r>
    38c4:	34ffe680 	cbz	w0, 3594 <__sfvwrite_r+0x134>
    38c8:	17ffff50 	b	3608 <__sfvwrite_r+0x1a8>
    38cc:	aa1503e0 	mov	x0, x21
    38d0:	94002368 	bl	c670 <_realloc_r>
    38d4:	aa0003f8 	mov	x24, x0
    38d8:	b5fffae0 	cbnz	x0, 3834 <__sfvwrite_r+0x3d4>
    38dc:	f9400e61 	ldr	x1, [x19, #24]
    38e0:	aa1503e0 	mov	x0, x21
    38e4:	94002507 	bl	cd00 <_free_r>
    38e8:	79c02260 	ldrsh	w0, [x19, #16]
    38ec:	52800181 	mov	w1, #0xc                   	// #12
    38f0:	a9446bf9 	ldp	x25, x26, [sp, #64]
    38f4:	12187800 	and	w0, w0, #0xffffff7f
    38f8:	b90002a1 	str	w1, [x21]
    38fc:	17ffff45 	b	3610 <__sfvwrite_r+0x1b0>
    3900:	79c02260 	ldrsh	w0, [x19, #16]
    3904:	17ffff43 	b	3610 <__sfvwrite_r+0x1b0>
    3908:	a94153f3 	ldp	x19, x20, [sp, #16]
    390c:	a94363f7 	ldp	x23, x24, [sp, #48]
    3910:	a94573fb 	ldp	x27, x28, [sp, #80]
    3914:	17ffff2e 	b	35cc <__sfvwrite_r+0x16c>
    3918:	a9446bf9 	ldp	x25, x26, [sp, #64]
    391c:	52800181 	mov	w1, #0xc                   	// #12
    3920:	79c02260 	ldrsh	w0, [x19, #16]
    3924:	b90002a1 	str	w1, [x21]
    3928:	17ffff3a 	b	3610 <__sfvwrite_r+0x1b0>
    392c:	00000000 	udf	#0

0000000000003930 <_fwalk_sglue>:
    3930:	a9bb7bfd 	stp	x29, x30, [sp, #-80]!
    3934:	910003fd 	mov	x29, sp
    3938:	a9025bf5 	stp	x21, x22, [sp, #32]
    393c:	aa0203f6 	mov	x22, x2
    3940:	52800015 	mov	w21, #0x0                   	// #0
    3944:	a90363f7 	stp	x23, x24, [sp, #48]
    3948:	aa0003f7 	mov	x23, x0
    394c:	aa0103f8 	mov	x24, x1
    3950:	a90153f3 	stp	x19, x20, [sp, #16]
    3954:	f90023f9 	str	x25, [sp, #64]
    3958:	52801719 	mov	w25, #0xb8                  	// #184
    395c:	d503201f 	nop
    3960:	b9400ad4 	ldr	w20, [x22, #8]
    3964:	f9400ad3 	ldr	x19, [x22, #16]
    3968:	7100029f 	cmp	w20, #0x0
    396c:	5400020d 	b.le	39ac <_fwalk_sglue+0x7c>
    3970:	9bb94e94 	umaddl	x20, w20, w25, x19
    3974:	d503201f 	nop
    3978:	79402263 	ldrh	w3, [x19, #16]
    397c:	7100047f 	cmp	w3, #0x1
    3980:	54000109 	b.ls	39a0 <_fwalk_sglue+0x70>  // b.plast
    3984:	79c02663 	ldrsh	w3, [x19, #18]
    3988:	aa1303e1 	mov	x1, x19
    398c:	aa1703e0 	mov	x0, x23
    3990:	3100047f 	cmn	w3, #0x1
    3994:	54000060 	b.eq	39a0 <_fwalk_sglue+0x70>  // b.none
    3998:	d63f0300 	blr	x24
    399c:	2a0002b5 	orr	w21, w21, w0
    39a0:	9102e273 	add	x19, x19, #0xb8
    39a4:	eb13029f 	cmp	x20, x19
    39a8:	54fffe81 	b.ne	3978 <_fwalk_sglue+0x48>  // b.any
    39ac:	f94002d6 	ldr	x22, [x22]
    39b0:	b5fffd96 	cbnz	x22, 3960 <_fwalk_sglue+0x30>
    39b4:	a94153f3 	ldp	x19, x20, [sp, #16]
    39b8:	2a1503e0 	mov	w0, w21
    39bc:	a9425bf5 	ldp	x21, x22, [sp, #32]
    39c0:	a94363f7 	ldp	x23, x24, [sp, #48]
    39c4:	f94023f9 	ldr	x25, [sp, #64]
    39c8:	a8c57bfd 	ldp	x29, x30, [sp], #80
    39cc:	d65f03c0 	ret

00000000000039d0 <_vfprintf_r>:
    39d0:	d10a03ff 	sub	sp, sp, #0x280
    39d4:	a9007bfd 	stp	x29, x30, [sp]
    39d8:	910003fd 	mov	x29, sp
    39dc:	a9025bf5 	stp	x21, x22, [sp, #32]
    39e0:	aa0103f5 	mov	x21, x1
    39e4:	f9400061 	ldr	x1, [x3]
    39e8:	f90043e1 	str	x1, [sp, #128]
    39ec:	f9400461 	ldr	x1, [x3, #8]
    39f0:	f90057e1 	str	x1, [sp, #168]
    39f4:	f9400861 	ldr	x1, [x3, #16]
    39f8:	f90087e1 	str	x1, [sp, #264]
    39fc:	b9401861 	ldr	w1, [x3, #24]
    3a00:	b9007fe1 	str	w1, [sp, #124]
    3a04:	b9401c61 	ldr	w1, [x3, #28]
    3a08:	a90153f3 	stp	x19, x20, [sp, #16]
    3a0c:	aa0303f4 	mov	x20, x3
    3a10:	aa0003f3 	mov	x19, x0
    3a14:	f9003be2 	str	x2, [sp, #112]
    3a18:	b900efe1 	str	w1, [sp, #236]
    3a1c:	94001a4d 	bl	a350 <_localeconv_r>
    3a20:	f9400000 	ldr	x0, [x0]
    3a24:	f9005fe0 	str	x0, [sp, #184]
    3a28:	97fffbe6 	bl	29c0 <strlen>
    3a2c:	f9005be0 	str	x0, [sp, #176]
    3a30:	d2800102 	mov	x2, #0x8                   	// #8
    3a34:	9105a3e0 	add	x0, sp, #0x168
    3a38:	52800001 	mov	w1, #0x0                   	// #0
    3a3c:	94001c31 	bl	ab00 <memset>
    3a40:	f9403be9 	ldr	x9, [sp, #112]
    3a44:	b4000073 	cbz	x19, 3a50 <_vfprintf_r+0x80>
    3a48:	f9402660 	ldr	x0, [x19, #72]
    3a4c:	b400c7c0 	cbz	x0, 5344 <_vfprintf_r+0x1974>
    3a50:	b940b2a1 	ldr	w1, [x21, #176]
    3a54:	79c022a0 	ldrsh	w0, [x21, #16]
    3a58:	37000041 	tbnz	w1, #0, 3a60 <_vfprintf_r+0x90>
    3a5c:	3648a3a0 	tbz	w0, #9, 4ed0 <_vfprintf_r+0x1500>
    3a60:	376800c0 	tbnz	w0, #13, 3a78 <_vfprintf_r+0xa8>
    3a64:	b940b2a1 	ldr	w1, [x21, #176]
    3a68:	32130000 	orr	w0, w0, #0x2000
    3a6c:	790022a0 	strh	w0, [x21, #16]
    3a70:	12127821 	and	w1, w1, #0xffffdfff
    3a74:	b900b2a1 	str	w1, [x21, #176]
    3a78:	361805e0 	tbz	w0, #3, 3b34 <_vfprintf_r+0x164>
    3a7c:	f9400ea1 	ldr	x1, [x21, #24]
    3a80:	b40005a1 	cbz	x1, 3b34 <_vfprintf_r+0x164>
    3a84:	52800341 	mov	w1, #0x1a                  	// #26
    3a88:	0a010001 	and	w1, w0, w1
    3a8c:	7100283f 	cmp	w1, #0xa
    3a90:	54000680 	b.eq	3b60 <_vfprintf_r+0x190>  // b.none
    3a94:	910803f6 	add	x22, sp, #0x200
    3a98:	6d0627e8 	stp	d8, d9, [sp, #96]
    3a9c:	2f00e408 	movi	d8, #0x0
    3aa0:	d0000074 	adrp	x20, 11000 <JIS_action_table>
    3aa4:	91340294 	add	x20, x20, #0xd00
    3aa8:	a9046bf9 	stp	x25, x26, [sp, #64]
    3aac:	aa0903f9 	mov	x25, x9
    3ab0:	b0000060 	adrp	x0, 10000 <__env_lock>
    3ab4:	a90573fb 	stp	x27, x28, [sp, #80]
    3ab8:	aa1603fc 	mov	x28, x22
    3abc:	91223000 	add	x0, x0, #0x88c
    3ac0:	a90363f7 	stp	x23, x24, [sp, #48]
    3ac4:	b90073ff 	str	wzr, [sp, #112]
    3ac8:	f90047e0 	str	x0, [sp, #136]
    3acc:	b9009fff 	str	wzr, [sp, #156]
    3ad0:	f90063ff 	str	xzr, [sp, #192]
    3ad4:	b900ebff 	str	wzr, [sp, #232]
    3ad8:	a90f7fff 	stp	xzr, xzr, [sp, #240]
    3adc:	f90083ff 	str	xzr, [sp, #256]
    3ae0:	f900c3f6 	str	x22, [sp, #384]
    3ae4:	b9018bff 	str	wzr, [sp, #392]
    3ae8:	f900cbff 	str	xzr, [sp, #400]
    3aec:	aa1903fa 	mov	x26, x25
    3af0:	f9407697 	ldr	x23, [x20, #232]
    3af4:	94001a07 	bl	a310 <__locale_mb_cur_max>
    3af8:	9105a3e4 	add	x4, sp, #0x168
    3afc:	93407c03 	sxtw	x3, w0
    3b00:	aa1a03e2 	mov	x2, x26
    3b04:	910573e1 	add	x1, sp, #0x15c
    3b08:	aa1303e0 	mov	x0, x19
    3b0c:	d63f02e0 	blr	x23
    3b10:	7100001f 	cmp	w0, #0x0
    3b14:	340005a0 	cbz	w0, 3bc8 <_vfprintf_r+0x1f8>
    3b18:	540004ab 	b.lt	3bac <_vfprintf_r+0x1dc>  // b.tstop
    3b1c:	b9415fe1 	ldr	w1, [sp, #348]
    3b20:	7100943f 	cmp	w1, #0x25
    3b24:	54003860 	b.eq	4230 <_vfprintf_r+0x860>  // b.none
    3b28:	93407c00 	sxtw	x0, w0
    3b2c:	8b00035a 	add	x26, x26, x0
    3b30:	17fffff0 	b	3af0 <_vfprintf_r+0x120>
    3b34:	aa1503e1 	mov	x1, x21
    3b38:	aa1303e0 	mov	x0, x19
    3b3c:	f9003be9 	str	x9, [sp, #112]
    3b40:	94001a98 	bl	a5a0 <__swsetup_r>
    3b44:	350152c0 	cbnz	w0, 659c <_vfprintf_r+0x2bcc>
    3b48:	79c022a0 	ldrsh	w0, [x21, #16]
    3b4c:	52800341 	mov	w1, #0x1a                  	// #26
    3b50:	f9403be9 	ldr	x9, [sp, #112]
    3b54:	0a010001 	and	w1, w0, w1
    3b58:	7100283f 	cmp	w1, #0xa
    3b5c:	54fff9c1 	b.ne	3a94 <_vfprintf_r+0xc4>  // b.any
    3b60:	79c026a1 	ldrsh	w1, [x21, #18]
    3b64:	37fff981 	tbnz	w1, #31, 3a94 <_vfprintf_r+0xc4>
    3b68:	b940b2a1 	ldr	w1, [x21, #176]
    3b6c:	37000041 	tbnz	w1, #0, 3b74 <_vfprintf_r+0x1a4>
    3b70:	364915e0 	tbz	w0, #9, 5e2c <_vfprintf_r+0x245c>
    3b74:	ad400680 	ldp	q0, q1, [x20]
    3b78:	aa1503e1 	mov	x1, x21
    3b7c:	910483e3 	add	x3, sp, #0x120
    3b80:	aa0903e2 	mov	x2, x9
    3b84:	aa1303e0 	mov	x0, x19
    3b88:	ad0907e0 	stp	q0, q1, [sp, #288]
    3b8c:	94000c6d 	bl	6d40 <__sbprintf>
    3b90:	b90073e0 	str	w0, [sp, #112]
    3b94:	a9407bfd 	ldp	x29, x30, [sp]
    3b98:	a94153f3 	ldp	x19, x20, [sp, #16]
    3b9c:	a9425bf5 	ldp	x21, x22, [sp, #32]
    3ba0:	b94073e0 	ldr	w0, [sp, #112]
    3ba4:	910a03ff 	add	sp, sp, #0x280
    3ba8:	d65f03c0 	ret
    3bac:	9105a3e0 	add	x0, sp, #0x168
    3bb0:	d2800102 	mov	x2, #0x8                   	// #8
    3bb4:	52800001 	mov	w1, #0x0                   	// #0
    3bb8:	94001bd2 	bl	ab00 <memset>
    3bbc:	d2800020 	mov	x0, #0x1                   	// #1
    3bc0:	8b00035a 	add	x26, x26, x0
    3bc4:	17ffffcb 	b	3af0 <_vfprintf_r+0x120>
    3bc8:	2a0003f7 	mov	w23, w0
    3bcc:	cb190340 	sub	x0, x26, x25
    3bd0:	2a0003fb 	mov	w27, w0
    3bd4:	3400de80 	cbz	w0, 57a4 <_vfprintf_r+0x1dd4>
    3bd8:	f940cbe2 	ldr	x2, [sp, #400]
    3bdc:	93407f61 	sxtw	x1, w27
    3be0:	b9418be0 	ldr	w0, [sp, #392]
    3be4:	8b010042 	add	x2, x2, x1
    3be8:	a9000799 	stp	x25, x1, [x28]
    3bec:	11000400 	add	w0, w0, #0x1
    3bf0:	b9018be0 	str	w0, [sp, #392]
    3bf4:	9100439c 	add	x28, x28, #0x10
    3bf8:	f900cbe2 	str	x2, [sp, #400]
    3bfc:	71001c1f 	cmp	w0, #0x7
    3c00:	540044ac 	b.gt	4494 <_vfprintf_r+0xac4>
    3c04:	b94073e0 	ldr	w0, [sp, #112]
    3c08:	0b1b0000 	add	w0, w0, w27
    3c0c:	b90073e0 	str	w0, [sp, #112]
    3c10:	3400dcb7 	cbz	w23, 57a4 <_vfprintf_r+0x1dd4>
    3c14:	39400748 	ldrb	w8, [x26, #1]
    3c18:	91000759 	add	x25, x26, #0x1
    3c1c:	12800007 	mov	w7, #0xffffffff            	// #-1
    3c20:	5280000b 	mov	w11, #0x0                   	// #0
    3c24:	52800009 	mov	w9, #0x0                   	// #0
    3c28:	2a0b03f8 	mov	w24, w11
    3c2c:	2a0903f7 	mov	w23, w9
    3c30:	2a0703fa 	mov	w26, w7
    3c34:	39053fff 	strb	wzr, [sp, #335]
    3c38:	91000739 	add	x25, x25, #0x1
    3c3c:	51008100 	sub	w0, w8, #0x20
    3c40:	7101681f 	cmp	w0, #0x5a
    3c44:	540000c8 	b.hi	3c5c <_vfprintf_r+0x28c>  // b.pmore
    3c48:	f94047e1 	ldr	x1, [sp, #136]
    3c4c:	78605820 	ldrh	w0, [x1, w0, uxtw #1]
    3c50:	10000061 	adr	x1, 3c5c <_vfprintf_r+0x28c>
    3c54:	8b20a820 	add	x0, x1, w0, sxth #2
    3c58:	d61f0000 	br	x0
    3c5c:	2a1703e9 	mov	w9, w23
    3c60:	2a1803eb 	mov	w11, w24
    3c64:	3400da08 	cbz	w8, 57a4 <_vfprintf_r+0x1dd4>
    3c68:	52800023 	mov	w3, #0x1                   	// #1
    3c6c:	910663f8 	add	x24, sp, #0x198
    3c70:	2a0303fb 	mov	w27, w3
    3c74:	52800001 	mov	w1, #0x0                   	// #0
    3c78:	d2800017 	mov	x23, #0x0                   	// #0
    3c7c:	52800007 	mov	w7, #0x0                   	// #0
    3c80:	b90093ff 	str	wzr, [sp, #144]
    3c84:	b9009bff 	str	wzr, [sp, #152]
    3c88:	b900a3ff 	str	wzr, [sp, #160]
    3c8c:	39053fff 	strb	wzr, [sp, #335]
    3c90:	390663e8 	strb	w8, [sp, #408]
    3c94:	d503201f 	nop
    3c98:	721f0132 	ands	w18, w9, #0x2
    3c9c:	11000862 	add	w2, w3, #0x2
    3ca0:	f940cbe0 	ldr	x0, [sp, #400]
    3ca4:	1a831043 	csel	w3, w2, w3, ne	// ne = any
    3ca8:	5280108e 	mov	w14, #0x84                  	// #132
    3cac:	6a0e013a 	ands	w26, w9, w14
    3cb0:	54000081 	b.ne	3cc0 <_vfprintf_r+0x2f0>  // b.any
    3cb4:	4b030164 	sub	w4, w11, w3
    3cb8:	7100009f 	cmp	w4, #0x0
    3cbc:	54001a6c 	b.gt	4008 <_vfprintf_r+0x638>
    3cc0:	340001a1 	cbz	w1, 3cf4 <_vfprintf_r+0x324>
    3cc4:	b9418be1 	ldr	w1, [sp, #392]
    3cc8:	91053fe2 	add	x2, sp, #0x14f
    3ccc:	91000400 	add	x0, x0, #0x1
    3cd0:	f9000382 	str	x2, [x28]
    3cd4:	11000421 	add	w1, w1, #0x1
    3cd8:	d2800022 	mov	x2, #0x1                   	// #1
    3cdc:	f9000782 	str	x2, [x28, #8]
    3ce0:	9100439c 	add	x28, x28, #0x10
    3ce4:	b9018be1 	str	w1, [sp, #392]
    3ce8:	f900cbe0 	str	x0, [sp, #400]
    3cec:	71001c3f 	cmp	w1, #0x7
    3cf0:	54003e0c 	b.gt	44b0 <_vfprintf_r+0xae0>
    3cf4:	340001b2 	cbz	w18, 3d28 <_vfprintf_r+0x358>
    3cf8:	b9418be1 	ldr	w1, [sp, #392]
    3cfc:	910543e2 	add	x2, sp, #0x150
    3d00:	91000800 	add	x0, x0, #0x2
    3d04:	f9000382 	str	x2, [x28]
    3d08:	11000421 	add	w1, w1, #0x1
    3d0c:	d2800042 	mov	x2, #0x2                   	// #2
    3d10:	f9000782 	str	x2, [x28, #8]
    3d14:	9100439c 	add	x28, x28, #0x10
    3d18:	b9018be1 	str	w1, [sp, #392]
    3d1c:	f900cbe0 	str	x0, [sp, #400]
    3d20:	71001c3f 	cmp	w1, #0x7
    3d24:	5400718c 	b.gt	4b54 <_vfprintf_r+0x1184>
    3d28:	7102035f 	cmp	w26, #0x80
    3d2c:	540028c0 	b.eq	4244 <_vfprintf_r+0x874>  // b.none
    3d30:	4b1b00fa 	sub	w26, w7, w27
    3d34:	7100035f 	cmp	w26, #0x0
    3d38:	540004cc 	b.gt	3dd0 <_vfprintf_r+0x400>
    3d3c:	37400de9 	tbnz	w9, #8, 3ef8 <_vfprintf_r+0x528>
    3d40:	b9418be1 	ldr	w1, [sp, #392]
    3d44:	93407f6c 	sxtw	x12, w27
    3d48:	8b0c0000 	add	x0, x0, x12
    3d4c:	a9003398 	stp	x24, x12, [x28]
    3d50:	11000421 	add	w1, w1, #0x1
    3d54:	b9018be1 	str	w1, [sp, #392]
    3d58:	f900cbe0 	str	x0, [sp, #400]
    3d5c:	71001c3f 	cmp	w1, #0x7
    3d60:	5400220c 	b.gt	41a0 <_vfprintf_r+0x7d0>
    3d64:	9100439c 	add	x28, x28, #0x10
    3d68:	36100089 	tbz	w9, #2, 3d78 <_vfprintf_r+0x3a8>
    3d6c:	4b03017a 	sub	w26, w11, w3
    3d70:	7100035f 	cmp	w26, #0x0
    3d74:	5400714c 	b.gt	4b9c <_vfprintf_r+0x11cc>
    3d78:	b94073e1 	ldr	w1, [sp, #112]
    3d7c:	6b03017f 	cmp	w11, w3
    3d80:	1a83a163 	csel	w3, w11, w3, ge	// ge = tcont
    3d84:	0b030021 	add	w1, w1, w3
    3d88:	b90073e1 	str	w1, [sp, #112]
    3d8c:	b5002fc0 	cbnz	x0, 4384 <_vfprintf_r+0x9b4>
    3d90:	b9018bff 	str	wzr, [sp, #392]
    3d94:	b4000097 	cbz	x23, 3da4 <_vfprintf_r+0x3d4>
    3d98:	aa1703e1 	mov	x1, x23
    3d9c:	aa1303e0 	mov	x0, x19
    3da0:	940023d8 	bl	cd00 <_free_r>
    3da4:	aa1603fc 	mov	x28, x22
    3da8:	17ffff51 	b	3aec <_vfprintf_r+0x11c>
    3dac:	5100c100 	sub	w0, w8, #0x30
    3db0:	52800018 	mov	w24, #0x0                   	// #0
    3db4:	38401728 	ldrb	w8, [x25], #1
    3db8:	0b180b0b 	add	w11, w24, w24, lsl #2
    3dbc:	0b0b0418 	add	w24, w0, w11, lsl #1
    3dc0:	5100c100 	sub	w0, w8, #0x30
    3dc4:	7100241f 	cmp	w0, #0x9
    3dc8:	54ffff69 	b.ls	3db4 <_vfprintf_r+0x3e4>  // b.plast
    3dcc:	17ffff9c 	b	3c3c <_vfprintf_r+0x26c>
    3dd0:	b0000064 	adrp	x4, 10000 <__env_lock>
    3dd4:	b9418be1 	ldr	w1, [sp, #392]
    3dd8:	91254084 	add	x4, x4, #0x950
    3ddc:	7100435f 	cmp	w26, #0x10
    3de0:	5400058d 	b.le	3e90 <_vfprintf_r+0x4c0>
    3de4:	aa1c03e2 	mov	x2, x28
    3de8:	d280020d 	mov	x13, #0x10                  	// #16
    3dec:	aa1903fc 	mov	x28, x25
    3df0:	aa0403f9 	mov	x25, x4
    3df4:	b900cbe9 	str	w9, [sp, #200]
    3df8:	b900d3e8 	str	w8, [sp, #208]
    3dfc:	f9006ff8 	str	x24, [sp, #216]
    3e00:	2a1a03f8 	mov	w24, w26
    3e04:	2a0303fa 	mov	w26, w3
    3e08:	b900e3eb 	str	w11, [sp, #224]
    3e0c:	14000004 	b	3e1c <_vfprintf_r+0x44c>
    3e10:	51004318 	sub	w24, w24, #0x10
    3e14:	7100431f 	cmp	w24, #0x10
    3e18:	540002ad 	b.le	3e6c <_vfprintf_r+0x49c>
    3e1c:	91004000 	add	x0, x0, #0x10
    3e20:	11000421 	add	w1, w1, #0x1
    3e24:	a9003459 	stp	x25, x13, [x2]
    3e28:	91004042 	add	x2, x2, #0x10
    3e2c:	b9018be1 	str	w1, [sp, #392]
    3e30:	f900cbe0 	str	x0, [sp, #400]
    3e34:	71001c3f 	cmp	w1, #0x7
    3e38:	54fffecd 	b.le	3e10 <_vfprintf_r+0x440>
    3e3c:	910603e2 	add	x2, sp, #0x180
    3e40:	aa1503e1 	mov	x1, x21
    3e44:	aa1303e0 	mov	x0, x19
    3e48:	94000c2e 	bl	6f00 <__sprint_r>
    3e4c:	35001ce0 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    3e50:	51004318 	sub	w24, w24, #0x10
    3e54:	b9418be1 	ldr	w1, [sp, #392]
    3e58:	f940cbe0 	ldr	x0, [sp, #400]
    3e5c:	aa1603e2 	mov	x2, x22
    3e60:	d280020d 	mov	x13, #0x10                  	// #16
    3e64:	7100431f 	cmp	w24, #0x10
    3e68:	54fffdac 	b.gt	3e1c <_vfprintf_r+0x44c>
    3e6c:	2a1a03e3 	mov	w3, w26
    3e70:	b940cbe9 	ldr	w9, [sp, #200]
    3e74:	2a1803fa 	mov	w26, w24
    3e78:	b940d3e8 	ldr	w8, [sp, #208]
    3e7c:	f9406ff8 	ldr	x24, [sp, #216]
    3e80:	aa1903e4 	mov	x4, x25
    3e84:	b940e3eb 	ldr	w11, [sp, #224]
    3e88:	aa1c03f9 	mov	x25, x28
    3e8c:	aa0203fc 	mov	x28, x2
    3e90:	93407f47 	sxtw	x7, w26
    3e94:	11000421 	add	w1, w1, #0x1
    3e98:	8b070000 	add	x0, x0, x7
    3e9c:	a9001f84 	stp	x4, x7, [x28]
    3ea0:	9100439c 	add	x28, x28, #0x10
    3ea4:	b9018be1 	str	w1, [sp, #392]
    3ea8:	f900cbe0 	str	x0, [sp, #400]
    3eac:	71001c3f 	cmp	w1, #0x7
    3eb0:	54fff46d 	b.le	3d3c <_vfprintf_r+0x36c>
    3eb4:	910603e2 	add	x2, sp, #0x180
    3eb8:	aa1503e1 	mov	x1, x21
    3ebc:	aa1303e0 	mov	x0, x19
    3ec0:	b900cbe9 	str	w9, [sp, #200]
    3ec4:	b900d3e8 	str	w8, [sp, #208]
    3ec8:	b900dbeb 	str	w11, [sp, #216]
    3ecc:	b900e3e3 	str	w3, [sp, #224]
    3ed0:	94000c0c 	bl	6f00 <__sprint_r>
    3ed4:	350018a0 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    3ed8:	b940cbe9 	ldr	w9, [sp, #200]
    3edc:	aa1603fc 	mov	x28, x22
    3ee0:	f940cbe0 	ldr	x0, [sp, #400]
    3ee4:	b940d3e8 	ldr	w8, [sp, #208]
    3ee8:	b940dbeb 	ldr	w11, [sp, #216]
    3eec:	b940e3e3 	ldr	w3, [sp, #224]
    3ef0:	3647f289 	tbz	w9, #8, 3d40 <_vfprintf_r+0x370>
    3ef4:	d503201f 	nop
    3ef8:	7101951f 	cmp	w8, #0x65
    3efc:	5400252d 	b.le	43a0 <_vfprintf_r+0x9d0>
    3f00:	1e602108 	fcmp	d8, #0.0
    3f04:	54001001 	b.ne	4104 <_vfprintf_r+0x734>  // b.any
    3f08:	b9418be1 	ldr	w1, [sp, #392]
    3f0c:	91000400 	add	x0, x0, #0x1
    3f10:	b0000062 	adrp	x2, 10000 <__env_lock>
    3f14:	d2800024 	mov	x4, #0x1                   	// #1
    3f18:	91222042 	add	x2, x2, #0x888
    3f1c:	11000421 	add	w1, w1, #0x1
    3f20:	a9001382 	stp	x2, x4, [x28]
    3f24:	9100439c 	add	x28, x28, #0x10
    3f28:	b9018be1 	str	w1, [sp, #392]
    3f2c:	f900cbe0 	str	x0, [sp, #400]
    3f30:	71001c3f 	cmp	w1, #0x7
    3f34:	5400ac4c 	b.gt	54bc <_vfprintf_r+0x1aec>
    3f38:	b9409fe2 	ldr	w2, [sp, #156]
    3f3c:	b9415be1 	ldr	w1, [sp, #344]
    3f40:	6b02003f 	cmp	w1, w2
    3f44:	54007d2a 	b.ge	4ee8 <_vfprintf_r+0x1518>  // b.tcont
    3f48:	a94b13e2 	ldp	x2, x4, [sp, #176]
    3f4c:	a9000b84 	stp	x4, x2, [x28]
    3f50:	b9418be1 	ldr	w1, [sp, #392]
    3f54:	9100439c 	add	x28, x28, #0x10
    3f58:	11000421 	add	w1, w1, #0x1
    3f5c:	b9018be1 	str	w1, [sp, #392]
    3f60:	8b020000 	add	x0, x0, x2
    3f64:	f900cbe0 	str	x0, [sp, #400]
    3f68:	71001c3f 	cmp	w1, #0x7
    3f6c:	54008a8c 	b.gt	50bc <_vfprintf_r+0x16ec>
    3f70:	b9409fe1 	ldr	w1, [sp, #156]
    3f74:	5100043a 	sub	w26, w1, #0x1
    3f78:	7100035f 	cmp	w26, #0x0
    3f7c:	54ffef6d 	b.le	3d68 <_vfprintf_r+0x398>
    3f80:	b0000064 	adrp	x4, 10000 <__env_lock>
    3f84:	b9418be1 	ldr	w1, [sp, #392]
    3f88:	91254084 	add	x4, x4, #0x950
    3f8c:	7100435f 	cmp	w26, #0x10
    3f90:	5400b7ad 	b.le	5684 <_vfprintf_r+0x1cb4>
    3f94:	aa1c03e2 	mov	x2, x28
    3f98:	2a1a03f8 	mov	w24, w26
    3f9c:	aa1903fc 	mov	x28, x25
    3fa0:	2a0303fa 	mov	w26, w3
    3fa4:	aa0403f9 	mov	x25, x4
    3fa8:	d280021b 	mov	x27, #0x10                  	// #16
    3fac:	b90093e9 	str	w9, [sp, #144]
    3fb0:	b9009beb 	str	w11, [sp, #152]
    3fb4:	14000004 	b	3fc4 <_vfprintf_r+0x5f4>
    3fb8:	51004318 	sub	w24, w24, #0x10
    3fbc:	7100431f 	cmp	w24, #0x10
    3fc0:	5400b54d 	b.le	5668 <_vfprintf_r+0x1c98>
    3fc4:	91004000 	add	x0, x0, #0x10
    3fc8:	11000421 	add	w1, w1, #0x1
    3fcc:	a9006c59 	stp	x25, x27, [x2]
    3fd0:	91004042 	add	x2, x2, #0x10
    3fd4:	b9018be1 	str	w1, [sp, #392]
    3fd8:	f900cbe0 	str	x0, [sp, #400]
    3fdc:	71001c3f 	cmp	w1, #0x7
    3fe0:	54fffecd 	b.le	3fb8 <_vfprintf_r+0x5e8>
    3fe4:	910603e2 	add	x2, sp, #0x180
    3fe8:	aa1503e1 	mov	x1, x21
    3fec:	aa1303e0 	mov	x0, x19
    3ff0:	94000bc4 	bl	6f00 <__sprint_r>
    3ff4:	35000fa0 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    3ff8:	f940cbe0 	ldr	x0, [sp, #400]
    3ffc:	aa1603e2 	mov	x2, x22
    4000:	b9418be1 	ldr	w1, [sp, #392]
    4004:	17ffffed 	b	3fb8 <_vfprintf_r+0x5e8>
    4008:	9000006d 	adrp	x13, 10000 <__env_lock>
    400c:	b9418be1 	ldr	w1, [sp, #392]
    4010:	912581ad 	add	x13, x13, #0x960
    4014:	7100409f 	cmp	w4, #0x10
    4018:	5400060d 	b.le	40d8 <_vfprintf_r+0x708>
    401c:	aa1c03e2 	mov	x2, x28
    4020:	d280020f 	mov	x15, #0x10                  	// #16
    4024:	aa1903fc 	mov	x28, x25
    4028:	aa0d03f9 	mov	x25, x13
    402c:	b900cbf2 	str	w18, [sp, #200]
    4030:	b900d3e9 	str	w9, [sp, #208]
    4034:	b900dbe8 	str	w8, [sp, #216]
    4038:	f90073f8 	str	x24, [sp, #224]
    403c:	2a0403f8 	mov	w24, w4
    4040:	b90113eb 	str	w11, [sp, #272]
    4044:	b9011be7 	str	w7, [sp, #280]
    4048:	b9011fe3 	str	w3, [sp, #284]
    404c:	14000004 	b	405c <_vfprintf_r+0x68c>
    4050:	51004318 	sub	w24, w24, #0x10
    4054:	7100431f 	cmp	w24, #0x10
    4058:	540002ad 	b.le	40ac <_vfprintf_r+0x6dc>
    405c:	91004000 	add	x0, x0, #0x10
    4060:	11000421 	add	w1, w1, #0x1
    4064:	a9003c59 	stp	x25, x15, [x2]
    4068:	91004042 	add	x2, x2, #0x10
    406c:	b9018be1 	str	w1, [sp, #392]
    4070:	f900cbe0 	str	x0, [sp, #400]
    4074:	71001c3f 	cmp	w1, #0x7
    4078:	54fffecd 	b.le	4050 <_vfprintf_r+0x680>
    407c:	910603e2 	add	x2, sp, #0x180
    4080:	aa1503e1 	mov	x1, x21
    4084:	aa1303e0 	mov	x0, x19
    4088:	94000b9e 	bl	6f00 <__sprint_r>
    408c:	35000ae0 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    4090:	51004318 	sub	w24, w24, #0x10
    4094:	b9418be1 	ldr	w1, [sp, #392]
    4098:	f940cbe0 	ldr	x0, [sp, #400]
    409c:	aa1603e2 	mov	x2, x22
    40a0:	d280020f 	mov	x15, #0x10                  	// #16
    40a4:	7100431f 	cmp	w24, #0x10
    40a8:	54fffdac 	b.gt	405c <_vfprintf_r+0x68c>
    40ac:	2a1803e4 	mov	w4, w24
    40b0:	b940cbf2 	ldr	w18, [sp, #200]
    40b4:	f94073f8 	ldr	x24, [sp, #224]
    40b8:	aa1903ed 	mov	x13, x25
    40bc:	b940d3e9 	ldr	w9, [sp, #208]
    40c0:	aa1c03f9 	mov	x25, x28
    40c4:	b940dbe8 	ldr	w8, [sp, #216]
    40c8:	aa0203fc 	mov	x28, x2
    40cc:	b94113eb 	ldr	w11, [sp, #272]
    40d0:	b9411be7 	ldr	w7, [sp, #280]
    40d4:	b9411fe3 	ldr	w3, [sp, #284]
    40d8:	93407c84 	sxtw	x4, w4
    40dc:	11000421 	add	w1, w1, #0x1
    40e0:	8b040000 	add	x0, x0, x4
    40e4:	a900138d 	stp	x13, x4, [x28]
    40e8:	b9018be1 	str	w1, [sp, #392]
    40ec:	f900cbe0 	str	x0, [sp, #400]
    40f0:	71001c3f 	cmp	w1, #0x7
    40f4:	54008fec 	b.gt	52f0 <_vfprintf_r+0x1920>
    40f8:	39453fe1 	ldrb	w1, [sp, #335]
    40fc:	9100439c 	add	x28, x28, #0x10
    4100:	17fffef0 	b	3cc0 <_vfprintf_r+0x2f0>
    4104:	b9415be2 	ldr	w2, [sp, #344]
    4108:	7100005f 	cmp	w2, #0x0
    410c:	54005d4c 	b.gt	4cb4 <_vfprintf_r+0x12e4>
    4110:	b9418be1 	ldr	w1, [sp, #392]
    4114:	91000400 	add	x0, x0, #0x1
    4118:	90000064 	adrp	x4, 10000 <__env_lock>
    411c:	d2800027 	mov	x7, #0x1                   	// #1
    4120:	91222084 	add	x4, x4, #0x888
    4124:	11000421 	add	w1, w1, #0x1
    4128:	a9001f84 	stp	x4, x7, [x28]
    412c:	9100439c 	add	x28, x28, #0x10
    4130:	b9018be1 	str	w1, [sp, #392]
    4134:	f900cbe0 	str	x0, [sp, #400]
    4138:	71001c3f 	cmp	w1, #0x7
    413c:	5401094c 	b.gt	6264 <_vfprintf_r+0x2894>
    4140:	b9409fe1 	ldr	w1, [sp, #156]
    4144:	2a020021 	orr	w1, w1, w2
    4148:	3400d441 	cbz	w1, 5bd0 <_vfprintf_r+0x2200>
    414c:	a94b17e4 	ldp	x4, x5, [sp, #176]
    4150:	a9001385 	stp	x5, x4, [x28]
    4154:	b9418be1 	ldr	w1, [sp, #392]
    4158:	91004386 	add	x6, x28, #0x10
    415c:	11000421 	add	w1, w1, #0x1
    4160:	b9018be1 	str	w1, [sp, #392]
    4164:	8b000080 	add	x0, x4, x0
    4168:	f900cbe0 	str	x0, [sp, #400]
    416c:	71001c3f 	cmp	w1, #0x7
    4170:	5400d46c 	b.gt	5bfc <_vfprintf_r+0x222c>
    4174:	37f91882 	tbnz	w2, #31, 6484 <_vfprintf_r+0x2ab4>
    4178:	b9809fe2 	ldrsw	x2, [sp, #156]
    417c:	11000421 	add	w1, w1, #0x1
    4180:	a90008d8 	stp	x24, x2, [x6]
    4184:	910040dc 	add	x28, x6, #0x10
    4188:	8b000040 	add	x0, x2, x0
    418c:	b9018be1 	str	w1, [sp, #392]
    4190:	f900cbe0 	str	x0, [sp, #400]
    4194:	71001c3f 	cmp	w1, #0x7
    4198:	54ffde8d 	b.le	3d68 <_vfprintf_r+0x398>
    419c:	d503201f 	nop
    41a0:	910603e2 	add	x2, sp, #0x180
    41a4:	aa1503e1 	mov	x1, x21
    41a8:	aa1303e0 	mov	x0, x19
    41ac:	b90093e9 	str	w9, [sp, #144]
    41b0:	b9009beb 	str	w11, [sp, #152]
    41b4:	b900a3e3 	str	w3, [sp, #160]
    41b8:	94000b52 	bl	6f00 <__sprint_r>
    41bc:	35000160 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    41c0:	f940cbe0 	ldr	x0, [sp, #400]
    41c4:	aa1603fc 	mov	x28, x22
    41c8:	b94093e9 	ldr	w9, [sp, #144]
    41cc:	b9409beb 	ldr	w11, [sp, #152]
    41d0:	b940a3e3 	ldr	w3, [sp, #160]
    41d4:	17fffee5 	b	3d68 <_vfprintf_r+0x398>
    41d8:	39400328 	ldrb	w8, [x25]
    41dc:	321c02f7 	orr	w23, w23, #0x10
    41e0:	17fffe96 	b	3c38 <_vfprintf_r+0x268>
    41e4:	f9404bf7 	ldr	x23, [sp, #144]
    41e8:	b4000097 	cbz	x23, 41f8 <_vfprintf_r+0x828>
    41ec:	aa1703e1 	mov	x1, x23
    41f0:	aa1303e0 	mov	x0, x19
    41f4:	940022c3 	bl	cd00 <_free_r>
    41f8:	79c022a0 	ldrsh	w0, [x21, #16]
    41fc:	b940b2a1 	ldr	w1, [x21, #176]
    4200:	36001801 	tbz	w1, #0, 4500 <_vfprintf_r+0xb30>
    4204:	a94363f7 	ldp	x23, x24, [sp, #48]
    4208:	a9446bf9 	ldp	x25, x26, [sp, #64]
    420c:	a94573fb 	ldp	x27, x28, [sp, #80]
    4210:	6d4627e8 	ldp	d8, d9, [sp, #96]
    4214:	37311d00 	tbnz	w0, #6, 65b4 <_vfprintf_r+0x2be4>
    4218:	a9407bfd 	ldp	x29, x30, [sp]
    421c:	a94153f3 	ldp	x19, x20, [sp, #16]
    4220:	a9425bf5 	ldp	x21, x22, [sp, #32]
    4224:	b94073e0 	ldr	w0, [sp, #112]
    4228:	910a03ff 	add	sp, sp, #0x280
    422c:	d65f03c0 	ret
    4230:	2a0003f7 	mov	w23, w0
    4234:	cb190340 	sub	x0, x26, x25
    4238:	2a0003fb 	mov	w27, w0
    423c:	34ffcec0 	cbz	w0, 3c14 <_vfprintf_r+0x244>
    4240:	17fffe66 	b	3bd8 <_vfprintf_r+0x208>
    4244:	4b03017a 	sub	w26, w11, w3
    4248:	7100035f 	cmp	w26, #0x0
    424c:	54ffd72d 	b.le	3d30 <_vfprintf_r+0x360>
    4250:	90000064 	adrp	x4, 10000 <__env_lock>
    4254:	b9418be1 	ldr	w1, [sp, #392]
    4258:	91254084 	add	x4, x4, #0x950
    425c:	7100435f 	cmp	w26, #0x10
    4260:	540005cd 	b.le	4318 <_vfprintf_r+0x948>
    4264:	aa1c03e2 	mov	x2, x28
    4268:	d280020e 	mov	x14, #0x10                  	// #16
    426c:	aa1903fc 	mov	x28, x25
    4270:	aa0403f9 	mov	x25, x4
    4274:	b900cbe9 	str	w9, [sp, #200]
    4278:	b900d3e8 	str	w8, [sp, #208]
    427c:	f9006ff8 	str	x24, [sp, #216]
    4280:	2a1a03f8 	mov	w24, w26
    4284:	2a0303fa 	mov	w26, w3
    4288:	b900e3eb 	str	w11, [sp, #224]
    428c:	b90113e7 	str	w7, [sp, #272]
    4290:	14000004 	b	42a0 <_vfprintf_r+0x8d0>
    4294:	51004318 	sub	w24, w24, #0x10
    4298:	7100431f 	cmp	w24, #0x10
    429c:	540002ad 	b.le	42f0 <_vfprintf_r+0x920>
    42a0:	91004000 	add	x0, x0, #0x10
    42a4:	11000421 	add	w1, w1, #0x1
    42a8:	a9003859 	stp	x25, x14, [x2]
    42ac:	91004042 	add	x2, x2, #0x10
    42b0:	b9018be1 	str	w1, [sp, #392]
    42b4:	f900cbe0 	str	x0, [sp, #400]
    42b8:	71001c3f 	cmp	w1, #0x7
    42bc:	54fffecd 	b.le	4294 <_vfprintf_r+0x8c4>
    42c0:	910603e2 	add	x2, sp, #0x180
    42c4:	aa1503e1 	mov	x1, x21
    42c8:	aa1303e0 	mov	x0, x19
    42cc:	94000b0d 	bl	6f00 <__sprint_r>
    42d0:	35fff8c0 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    42d4:	51004318 	sub	w24, w24, #0x10
    42d8:	b9418be1 	ldr	w1, [sp, #392]
    42dc:	f940cbe0 	ldr	x0, [sp, #400]
    42e0:	aa1603e2 	mov	x2, x22
    42e4:	d280020e 	mov	x14, #0x10                  	// #16
    42e8:	7100431f 	cmp	w24, #0x10
    42ec:	54fffdac 	b.gt	42a0 <_vfprintf_r+0x8d0>
    42f0:	2a1a03e3 	mov	w3, w26
    42f4:	b940cbe9 	ldr	w9, [sp, #200]
    42f8:	2a1803fa 	mov	w26, w24
    42fc:	b940d3e8 	ldr	w8, [sp, #208]
    4300:	f9406ff8 	ldr	x24, [sp, #216]
    4304:	aa1903e4 	mov	x4, x25
    4308:	b940e3eb 	ldr	w11, [sp, #224]
    430c:	aa1c03f9 	mov	x25, x28
    4310:	b94113e7 	ldr	w7, [sp, #272]
    4314:	aa0203fc 	mov	x28, x2
    4318:	93407f4d 	sxtw	x13, w26
    431c:	11000421 	add	w1, w1, #0x1
    4320:	8b0d0000 	add	x0, x0, x13
    4324:	a9003784 	stp	x4, x13, [x28]
    4328:	9100439c 	add	x28, x28, #0x10
    432c:	b9018be1 	str	w1, [sp, #392]
    4330:	f900cbe0 	str	x0, [sp, #400]
    4334:	71001c3f 	cmp	w1, #0x7
    4338:	54ffcfcd 	b.le	3d30 <_vfprintf_r+0x360>
    433c:	910603e2 	add	x2, sp, #0x180
    4340:	aa1503e1 	mov	x1, x21
    4344:	aa1303e0 	mov	x0, x19
    4348:	b900cbe9 	str	w9, [sp, #200]
    434c:	b900d3e8 	str	w8, [sp, #208]
    4350:	b900dbeb 	str	w11, [sp, #216]
    4354:	b900e3e7 	str	w7, [sp, #224]
    4358:	b90113e3 	str	w3, [sp, #272]
    435c:	94000ae9 	bl	6f00 <__sprint_r>
    4360:	35fff440 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    4364:	f940cbe0 	ldr	x0, [sp, #400]
    4368:	aa1603fc 	mov	x28, x22
    436c:	b940cbe9 	ldr	w9, [sp, #200]
    4370:	b940d3e8 	ldr	w8, [sp, #208]
    4374:	b940dbeb 	ldr	w11, [sp, #216]
    4378:	b940e3e7 	ldr	w7, [sp, #224]
    437c:	b94113e3 	ldr	w3, [sp, #272]
    4380:	17fffe6c 	b	3d30 <_vfprintf_r+0x360>
    4384:	910603e2 	add	x2, sp, #0x180
    4388:	aa1503e1 	mov	x1, x21
    438c:	aa1303e0 	mov	x0, x19
    4390:	94000adc 	bl	6f00 <__sprint_r>
    4394:	34ffcfe0 	cbz	w0, 3d90 <_vfprintf_r+0x3c0>
    4398:	b5fff2b7 	cbnz	x23, 41ec <_vfprintf_r+0x81c>
    439c:	17ffff97 	b	41f8 <_vfprintf_r+0x828>
    43a0:	b9418be1 	ldr	w1, [sp, #392]
    43a4:	91000400 	add	x0, x0, #0x1
    43a8:	b9409fe2 	ldr	w2, [sp, #156]
    43ac:	91004387 	add	x7, x28, #0x10
    43b0:	11000421 	add	w1, w1, #0x1
    43b4:	7100045f 	cmp	w2, #0x1
    43b8:	540010cd 	b.le	45d0 <_vfprintf_r+0xc00>
    43bc:	d2800022 	mov	x2, #0x1                   	// #1
    43c0:	a9000b98 	stp	x24, x2, [x28]
    43c4:	b9018be1 	str	w1, [sp, #392]
    43c8:	f900cbe0 	str	x0, [sp, #400]
    43cc:	71001c3f 	cmp	w1, #0x7
    43d0:	540053cc 	b.gt	4e48 <_vfprintf_r+0x1478>
    43d4:	a94b13e2 	ldp	x2, x4, [sp, #176]
    43d8:	11000421 	add	w1, w1, #0x1
    43dc:	a90008e4 	stp	x4, x2, [x7]
    43e0:	910040e7 	add	x7, x7, #0x10
    43e4:	b9018be1 	str	w1, [sp, #392]
    43e8:	8b020000 	add	x0, x0, x2
    43ec:	f900cbe0 	str	x0, [sp, #400]
    43f0:	71001c3f 	cmp	w1, #0x7
    43f4:	5400548c 	b.gt	4e84 <_vfprintf_r+0x14b4>
    43f8:	1e602108 	fcmp	d8, #0.0
    43fc:	b9409fe2 	ldr	w2, [sp, #156]
    4400:	5100045a 	sub	w26, w2, #0x1
    4404:	54001120 	b.eq	4628 <_vfprintf_r+0xc58>  // b.none
    4408:	93407f5a 	sxtw	x26, w26
    440c:	11000421 	add	w1, w1, #0x1
    4410:	8b1a0000 	add	x0, x0, x26
    4414:	b9018be1 	str	w1, [sp, #392]
    4418:	f900cbe0 	str	x0, [sp, #400]
    441c:	91000705 	add	x5, x24, #0x1
    4420:	f90000e5 	str	x5, [x7]
    4424:	f90004fa 	str	x26, [x7, #8]
    4428:	71001c3f 	cmp	w1, #0x7
    442c:	540062ac 	b.gt	5080 <_vfprintf_r+0x16b0>
    4430:	910040e7 	add	x7, x7, #0x10
    4434:	b980ebe2 	ldrsw	x2, [sp, #232]
    4438:	11000421 	add	w1, w1, #0x1
    443c:	910583e4 	add	x4, sp, #0x160
    4440:	a90008e4 	stp	x4, x2, [x7]
    4444:	8b000040 	add	x0, x2, x0
    4448:	b9018be1 	str	w1, [sp, #392]
    444c:	910040fc 	add	x28, x7, #0x10
    4450:	f900cbe0 	str	x0, [sp, #400]
    4454:	71001c3f 	cmp	w1, #0x7
    4458:	54ffc88d 	b.le	3d68 <_vfprintf_r+0x398>
    445c:	910603e2 	add	x2, sp, #0x180
    4460:	aa1503e1 	mov	x1, x21
    4464:	aa1303e0 	mov	x0, x19
    4468:	b90093e9 	str	w9, [sp, #144]
    446c:	b9009beb 	str	w11, [sp, #152]
    4470:	b900a3e3 	str	w3, [sp, #160]
    4474:	94000aa3 	bl	6f00 <__sprint_r>
    4478:	35ffeb80 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    447c:	f940cbe0 	ldr	x0, [sp, #400]
    4480:	aa1603fc 	mov	x28, x22
    4484:	b94093e9 	ldr	w9, [sp, #144]
    4488:	b9409beb 	ldr	w11, [sp, #152]
    448c:	b940a3e3 	ldr	w3, [sp, #160]
    4490:	17fffe36 	b	3d68 <_vfprintf_r+0x398>
    4494:	910603e2 	add	x2, sp, #0x180
    4498:	aa1503e1 	mov	x1, x21
    449c:	aa1303e0 	mov	x0, x19
    44a0:	94000a98 	bl	6f00 <__sprint_r>
    44a4:	35ffeaa0 	cbnz	w0, 41f8 <_vfprintf_r+0x828>
    44a8:	aa1603fc 	mov	x28, x22
    44ac:	17fffdd6 	b	3c04 <_vfprintf_r+0x234>
    44b0:	910603e2 	add	x2, sp, #0x180
    44b4:	aa1503e1 	mov	x1, x21
    44b8:	aa1303e0 	mov	x0, x19
    44bc:	b900cbf2 	str	w18, [sp, #200]
    44c0:	b900d3e9 	str	w9, [sp, #208]
    44c4:	b900dbe8 	str	w8, [sp, #216]
    44c8:	b900e3eb 	str	w11, [sp, #224]
    44cc:	b90113e7 	str	w7, [sp, #272]
    44d0:	b9011be3 	str	w3, [sp, #280]
    44d4:	94000a8b 	bl	6f00 <__sprint_r>
    44d8:	35ffe880 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    44dc:	f940cbe0 	ldr	x0, [sp, #400]
    44e0:	aa1603fc 	mov	x28, x22
    44e4:	b940cbf2 	ldr	w18, [sp, #200]
    44e8:	b940d3e9 	ldr	w9, [sp, #208]
    44ec:	b940dbe8 	ldr	w8, [sp, #216]
    44f0:	b940e3eb 	ldr	w11, [sp, #224]
    44f4:	b94113e7 	ldr	w7, [sp, #272]
    44f8:	b9411be3 	ldr	w3, [sp, #280]
    44fc:	17fffdfe 	b	3cf4 <_vfprintf_r+0x324>
    4500:	374fe820 	tbnz	w0, #9, 4204 <_vfprintf_r+0x834>
    4504:	f94052a0 	ldr	x0, [x21, #160]
    4508:	9400145a 	bl	9670 <__retarget_lock_release_recursive>
    450c:	79c022a0 	ldrsh	w0, [x21, #16]
    4510:	17ffff3d 	b	4204 <_vfprintf_r+0x834>
    4514:	b940efe0 	ldr	w0, [sp, #236]
    4518:	2a1703e9 	mov	w9, w23
    451c:	2a1803eb 	mov	w11, w24
    4520:	2a1a03e7 	mov	w7, w26
    4524:	36184e69 	tbz	w9, #3, 4ef0 <_vfprintf_r+0x1520>
    4528:	37f8e3a0 	tbnz	w0, #31, 619c <_vfprintf_r+0x27cc>
    452c:	f94043e0 	ldr	x0, [sp, #128]
    4530:	91003c00 	add	x0, x0, #0xf
    4534:	927cec00 	and	x0, x0, #0xfffffffffffffff0
    4538:	91004001 	add	x1, x0, #0x10
    453c:	f90043e1 	str	x1, [sp, #128]
    4540:	3dc00000 	ldr	q0, [x0]
    4544:	b90093e9 	str	w9, [sp, #144]
    4548:	b9009be8 	str	w8, [sp, #152]
    454c:	b900a3eb 	str	w11, [sp, #160]
    4550:	b900cbe7 	str	w7, [sp, #200]
    4554:	94002eb3 	bl	10020 <__trunctfdf2>
    4558:	b94093e9 	ldr	w9, [sp, #144]
    455c:	1e604008 	fmov	d8, d0
    4560:	b9409be8 	ldr	w8, [sp, #152]
    4564:	b940a3eb 	ldr	w11, [sp, #160]
    4568:	b940cbe7 	ldr	w7, [sp, #200]
    456c:	1e60c100 	fabs	d0, d8
    4570:	92f00200 	mov	x0, #0x7fefffffffffffff    	// #9218868437227405311
    4574:	9e670001 	fmov	d1, x0
    4578:	1e612000 	fcmp	d0, d1
    457c:	54006f6d 	b.le	5368 <_vfprintf_r+0x1998>
    4580:	1e602118 	fcmpe	d8, #0.0
    4584:	5400db84 	b.mi	60f4 <_vfprintf_r+0x2724>  // b.first
    4588:	39453fe1 	ldrb	w1, [sp, #335]
    458c:	90000060 	adrp	x0, 10000 <__env_lock>
    4590:	90000065 	adrp	x5, 10000 <__env_lock>
    4594:	7101211f 	cmp	w8, #0x48
    4598:	9120e000 	add	x0, x0, #0x838
    459c:	9120c0a5 	add	x5, x5, #0x830
    45a0:	b90093ff 	str	wzr, [sp, #144]
    45a4:	52800063 	mov	w3, #0x3                   	// #3
    45a8:	b9009bff 	str	wzr, [sp, #152]
    45ac:	12187929 	and	w9, w9, #0xffffff7f
    45b0:	b900a3ff 	str	wzr, [sp, #160]
    45b4:	9a80b0b8 	csel	x24, x5, x0, lt	// lt = tstop
    45b8:	2a0303fb 	mov	w27, w3
    45bc:	d2800017 	mov	x23, #0x0                   	// #0
    45c0:	52800007 	mov	w7, #0x0                   	// #0
    45c4:	34ffb6a1 	cbz	w1, 3c98 <_vfprintf_r+0x2c8>
    45c8:	11000463 	add	w3, w3, #0x1
    45cc:	17fffdb3 	b	3c98 <_vfprintf_r+0x2c8>
    45d0:	3707ef69 	tbnz	w9, #0, 43bc <_vfprintf_r+0x9ec>
    45d4:	d2800022 	mov	x2, #0x1                   	// #1
    45d8:	a9000b98 	stp	x24, x2, [x28]
    45dc:	b9018be1 	str	w1, [sp, #392]
    45e0:	f900cbe0 	str	x0, [sp, #400]
    45e4:	71001c3f 	cmp	w1, #0x7
    45e8:	54fff26d 	b.le	4434 <_vfprintf_r+0xa64>
    45ec:	910603e2 	add	x2, sp, #0x180
    45f0:	aa1503e1 	mov	x1, x21
    45f4:	aa1303e0 	mov	x0, x19
    45f8:	b90093e9 	str	w9, [sp, #144]
    45fc:	b9009beb 	str	w11, [sp, #152]
    4600:	b900a3e3 	str	w3, [sp, #160]
    4604:	94000a3f 	bl	6f00 <__sprint_r>
    4608:	35ffdf00 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    460c:	f940cbe0 	ldr	x0, [sp, #400]
    4610:	aa1603e7 	mov	x7, x22
    4614:	b94093e9 	ldr	w9, [sp, #144]
    4618:	b9409beb 	ldr	w11, [sp, #152]
    461c:	b940a3e3 	ldr	w3, [sp, #160]
    4620:	b9418be1 	ldr	w1, [sp, #392]
    4624:	17ffff84 	b	4434 <_vfprintf_r+0xa64>
    4628:	b9409fe2 	ldr	w2, [sp, #156]
    462c:	7100045f 	cmp	w2, #0x1
    4630:	54fff02d 	b.le	4434 <_vfprintf_r+0xa64>
    4634:	90000064 	adrp	x4, 10000 <__env_lock>
    4638:	91254084 	add	x4, x4, #0x950
    463c:	7100445f 	cmp	w2, #0x11
    4640:	540050ed 	b.le	505c <_vfprintf_r+0x168c>
    4644:	2a1a03f8 	mov	w24, w26
    4648:	2a0b03fc 	mov	w28, w11
    464c:	aa1903fa 	mov	x26, x25
    4650:	d280021b 	mov	x27, #0x10                  	// #16
    4654:	aa0403f9 	mov	x25, x4
    4658:	b90093e9 	str	w9, [sp, #144]
    465c:	b9009be3 	str	w3, [sp, #152]
    4660:	14000004 	b	4670 <_vfprintf_r+0xca0>
    4664:	51004318 	sub	w24, w24, #0x10
    4668:	7100431f 	cmp	w24, #0x10
    466c:	54004ecd 	b.le	5044 <_vfprintf_r+0x1674>
    4670:	91004000 	add	x0, x0, #0x10
    4674:	11000421 	add	w1, w1, #0x1
    4678:	a9006cf9 	stp	x25, x27, [x7]
    467c:	910040e7 	add	x7, x7, #0x10
    4680:	b9018be1 	str	w1, [sp, #392]
    4684:	f900cbe0 	str	x0, [sp, #400]
    4688:	71001c3f 	cmp	w1, #0x7
    468c:	54fffecd 	b.le	4664 <_vfprintf_r+0xc94>
    4690:	910603e2 	add	x2, sp, #0x180
    4694:	aa1503e1 	mov	x1, x21
    4698:	aa1303e0 	mov	x0, x19
    469c:	94000a19 	bl	6f00 <__sprint_r>
    46a0:	35ffda40 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    46a4:	f940cbe0 	ldr	x0, [sp, #400]
    46a8:	aa1603e7 	mov	x7, x22
    46ac:	b9418be1 	ldr	w1, [sp, #392]
    46b0:	17ffffed 	b	4664 <_vfprintf_r+0xc94>
    46b4:	2a1703e9 	mov	w9, w23
    46b8:	2a1803eb 	mov	w11, w24
    46bc:	71010d1f 	cmp	w8, #0x43
    46c0:	540056a0 	b.eq	5194 <_vfprintf_r+0x17c4>  // b.none
    46c4:	37205689 	tbnz	w9, #4, 5194 <_vfprintf_r+0x17c4>
    46c8:	b9407fe0 	ldr	w0, [sp, #124]
    46cc:	37f8dfc0 	tbnz	w0, #31, 62c4 <_vfprintf_r+0x28f4>
    46d0:	f94043e0 	ldr	x0, [sp, #128]
    46d4:	91002c01 	add	x1, x0, #0xb
    46d8:	927df021 	and	x1, x1, #0xfffffffffffffff8
    46dc:	f90043e1 	str	x1, [sp, #128]
    46e0:	b9400000 	ldr	w0, [x0]
    46e4:	52800023 	mov	w3, #0x1                   	// #1
    46e8:	910663f7 	add	x23, sp, #0x198
    46ec:	2a0303fb 	mov	w27, w3
    46f0:	390663e0 	strb	w0, [sp, #408]
    46f4:	aa1703f8 	mov	x24, x23
    46f8:	52800001 	mov	w1, #0x0                   	// #0
    46fc:	d2800017 	mov	x23, #0x0                   	// #0
    4700:	52800007 	mov	w7, #0x0                   	// #0
    4704:	b90093ff 	str	wzr, [sp, #144]
    4708:	b9009bff 	str	wzr, [sp, #152]
    470c:	b900a3ff 	str	wzr, [sp, #160]
    4710:	39053fff 	strb	wzr, [sp, #335]
    4714:	17fffd61 	b	3c98 <_vfprintf_r+0x2c8>
    4718:	b9407fe0 	ldr	w0, [sp, #124]
    471c:	2a1703e9 	mov	w9, w23
    4720:	2a1803eb 	mov	w11, w24
    4724:	2a1a03e7 	mov	w7, w26
    4728:	37f84540 	tbnz	w0, #31, 4fd0 <_vfprintf_r+0x1600>
    472c:	f94043e0 	ldr	x0, [sp, #128]
    4730:	91003c01 	add	x1, x0, #0xf
    4734:	927df021 	and	x1, x1, #0xfffffffffffffff8
    4738:	f90043e1 	str	x1, [sp, #128]
    473c:	f9400018 	ldr	x24, [x0]
    4740:	39053fff 	strb	wzr, [sp, #335]
    4744:	b4008038 	cbz	x24, 5748 <_vfprintf_r+0x1d78>
    4748:	71014d1f 	cmp	w8, #0x53
    474c:	54006d40 	b.eq	54f4 <_vfprintf_r+0x1b24>  // b.none
    4750:	121c0120 	and	w0, w9, #0x10
    4754:	b90093e0 	str	w0, [sp, #144]
    4758:	37206ce9 	tbnz	w9, #4, 54f4 <_vfprintf_r+0x1b24>
    475c:	310004ff 	cmn	w7, #0x1
    4760:	5400ae00 	b.eq	5d20 <_vfprintf_r+0x2350>  // b.none
    4764:	93407ce2 	sxtw	x2, w7
    4768:	aa1803e0 	mov	x0, x24
    476c:	52800001 	mov	w1, #0x0                   	// #0
    4770:	b9009be7 	str	w7, [sp, #152]
    4774:	b900a3e9 	str	w9, [sp, #160]
    4778:	b900cbeb 	str	w11, [sp, #200]
    477c:	94001751 	bl	a4c0 <memchr>
    4780:	b9409be7 	ldr	w7, [sp, #152]
    4784:	aa0003f7 	mov	x23, x0
    4788:	b940a3e9 	ldr	w9, [sp, #160]
    478c:	b940cbeb 	ldr	w11, [sp, #200]
    4790:	b400ffa0 	cbz	x0, 6784 <_vfprintf_r+0x2db4>
    4794:	39453fe1 	ldrb	w1, [sp, #335]
    4798:	cb180003 	sub	x3, x0, x24
    479c:	b9009bff 	str	wzr, [sp, #152]
    47a0:	7100007f 	cmp	w3, #0x0
    47a4:	b900a3ff 	str	wzr, [sp, #160]
    47a8:	2a0303fb 	mov	w27, w3
    47ac:	52800007 	mov	w7, #0x0                   	// #0
    47b0:	1a9fa063 	csel	w3, w3, wzr, ge	// ge = tcont
    47b4:	d2800017 	mov	x23, #0x0                   	// #0
    47b8:	52800e68 	mov	w8, #0x73                  	// #115
    47bc:	34ffa6e1 	cbz	w1, 3c98 <_vfprintf_r+0x2c8>
    47c0:	17ffff82 	b	45c8 <_vfprintf_r+0xbf8>
    47c4:	4b1803f8 	neg	w24, w24
    47c8:	f90043e0 	str	x0, [sp, #128]
    47cc:	39400328 	ldrb	w8, [x25]
    47d0:	321e02f7 	orr	w23, w23, #0x4
    47d4:	17fffd19 	b	3c38 <_vfprintf_r+0x268>
    47d8:	aa1903e1 	mov	x1, x25
    47dc:	38401428 	ldrb	w8, [x1], #1
    47e0:	7100a91f 	cmp	w8, #0x2a
    47e4:	54012100 	b.eq	6c04 <_vfprintf_r+0x3234>  // b.none
    47e8:	5100c100 	sub	w0, w8, #0x30
    47ec:	aa0103f9 	mov	x25, x1
    47f0:	5280001a 	mov	w26, #0x0                   	// #0
    47f4:	7100241f 	cmp	w0, #0x9
    47f8:	54ffa228 	b.hi	3c3c <_vfprintf_r+0x26c>  // b.pmore
    47fc:	d503201f 	nop
    4800:	38401728 	ldrb	w8, [x25], #1
    4804:	0b1a0b47 	add	w7, w26, w26, lsl #2
    4808:	0b07041a 	add	w26, w0, w7, lsl #1
    480c:	5100c100 	sub	w0, w8, #0x30
    4810:	7100241f 	cmp	w0, #0x9
    4814:	54ffff69 	b.ls	4800 <_vfprintf_r+0xe30>  // b.plast
    4818:	17fffd09 	b	3c3c <_vfprintf_r+0x26c>
    481c:	52800560 	mov	w0, #0x2b                  	// #43
    4820:	39400328 	ldrb	w8, [x25]
    4824:	39053fe0 	strb	w0, [sp, #335]
    4828:	17fffd04 	b	3c38 <_vfprintf_r+0x268>
    482c:	b9407fe0 	ldr	w0, [sp, #124]
    4830:	37f83f80 	tbnz	w0, #31, 5020 <_vfprintf_r+0x1650>
    4834:	f94043e0 	ldr	x0, [sp, #128]
    4838:	91002c00 	add	x0, x0, #0xb
    483c:	927df000 	and	x0, x0, #0xfffffffffffffff8
    4840:	f94043e1 	ldr	x1, [sp, #128]
    4844:	b9400038 	ldr	w24, [x1]
    4848:	37fffbf8 	tbnz	w24, #31, 47c4 <_vfprintf_r+0xdf4>
    484c:	39400328 	ldrb	w8, [x25]
    4850:	f90043e0 	str	x0, [sp, #128]
    4854:	17fffcf9 	b	3c38 <_vfprintf_r+0x268>
    4858:	aa1303e0 	mov	x0, x19
    485c:	940016bd 	bl	a350 <_localeconv_r>
    4860:	f9400400 	ldr	x0, [x0, #8]
    4864:	f9007be0 	str	x0, [sp, #240]
    4868:	97fff856 	bl	29c0 <strlen>
    486c:	aa0003e1 	mov	x1, x0
    4870:	aa0103fb 	mov	x27, x1
    4874:	aa1303e0 	mov	x0, x19
    4878:	f90083e1 	str	x1, [sp, #256]
    487c:	940016b5 	bl	a350 <_localeconv_r>
    4880:	f9400800 	ldr	x0, [x0, #16]
    4884:	f9007fe0 	str	x0, [sp, #248]
    4888:	f100037f 	cmp	x27, #0x0
    488c:	fa401804 	ccmp	x0, #0x0, #0x4, ne	// ne = any
    4890:	540036c0 	b.eq	4f68 <_vfprintf_r+0x1598>  // b.none
    4894:	39400001 	ldrb	w1, [x0]
    4898:	321602e0 	orr	w0, w23, #0x400
    489c:	39400328 	ldrb	w8, [x25]
    48a0:	7100003f 	cmp	w1, #0x0
    48a4:	1a971017 	csel	w23, w0, w23, ne	// ne = any
    48a8:	17fffce4 	b	3c38 <_vfprintf_r+0x268>
    48ac:	39400328 	ldrb	w8, [x25]
    48b0:	320002f7 	orr	w23, w23, #0x1
    48b4:	17fffce1 	b	3c38 <_vfprintf_r+0x268>
    48b8:	39453fe0 	ldrb	w0, [sp, #335]
    48bc:	39400328 	ldrb	w8, [x25]
    48c0:	35ff9bc0 	cbnz	w0, 3c38 <_vfprintf_r+0x268>
    48c4:	52800400 	mov	w0, #0x20                  	// #32
    48c8:	39053fe0 	strb	w0, [sp, #335]
    48cc:	17fffcdb 	b	3c38 <_vfprintf_r+0x268>
    48d0:	2a1803eb 	mov	w11, w24
    48d4:	2a1a03e7 	mov	w7, w26
    48d8:	321c02e9 	orr	w9, w23, #0x10
    48dc:	b9407fe0 	ldr	w0, [sp, #124]
    48e0:	37280049 	tbnz	w9, #5, 48e8 <_vfprintf_r+0xf18>
    48e4:	362035e9 	tbz	w9, #4, 4fa0 <_vfprintf_r+0x15d0>
    48e8:	37f84dc0 	tbnz	w0, #31, 52a0 <_vfprintf_r+0x18d0>
    48ec:	f94043e0 	ldr	x0, [sp, #128]
    48f0:	91003c01 	add	x1, x0, #0xf
    48f4:	927df021 	and	x1, x1, #0xfffffffffffffff8
    48f8:	f90043e1 	str	x1, [sp, #128]
    48fc:	f9400000 	ldr	x0, [x0]
    4900:	1215793a 	and	w26, w9, #0xfffffbff
    4904:	52800001 	mov	w1, #0x0                   	// #0
    4908:	52800002 	mov	w2, #0x0                   	// #0
    490c:	39053fe2 	strb	w2, [sp, #335]
    4910:	310004ff 	cmn	w7, #0x1
    4914:	54000de0 	b.eq	4ad0 <_vfprintf_r+0x1100>  // b.none
    4918:	f100001f 	cmp	x0, #0x0
    491c:	12187b49 	and	w9, w26, #0xffffff7f
    4920:	7a4008e0 	ccmp	w7, #0x0, #0x0, eq	// eq = none
    4924:	54000d41 	b.ne	4acc <_vfprintf_r+0x10fc>  // b.any
    4928:	35000c41 	cbnz	w1, 4ab0 <_vfprintf_r+0x10e0>
    492c:	1200035b 	and	w27, w26, #0x1
    4930:	36001bda 	tbz	w26, #0, 4ca8 <_vfprintf_r+0x12d8>
    4934:	9107eff8 	add	x24, sp, #0x1fb
    4938:	52800600 	mov	w0, #0x30                  	// #48
    493c:	52800007 	mov	w7, #0x0                   	// #0
    4940:	3907efe0 	strb	w0, [sp, #507]
    4944:	d503201f 	nop
    4948:	39453fe1 	ldrb	w1, [sp, #335]
    494c:	6b1b00ff 	cmp	w7, w27
    4950:	b90093ff 	str	wzr, [sp, #144]
    4954:	1a9ba0e3 	csel	w3, w7, w27, ge	// ge = tcont
    4958:	b9009bff 	str	wzr, [sp, #152]
    495c:	d2800017 	mov	x23, #0x0                   	// #0
    4960:	b900a3ff 	str	wzr, [sp, #160]
    4964:	34ff99a1 	cbz	w1, 3c98 <_vfprintf_r+0x2c8>
    4968:	17ffff18 	b	45c8 <_vfprintf_r+0xbf8>
    496c:	39400328 	ldrb	w8, [x25]
    4970:	321d02f7 	orr	w23, w23, #0x8
    4974:	17fffcb1 	b	3c38 <_vfprintf_r+0x268>
    4978:	2a1a03e7 	mov	w7, w26
    497c:	2a1803eb 	mov	w11, w24
    4980:	321c02fa 	orr	w26, w23, #0x10
    4984:	b9407fe0 	ldr	w0, [sp, #124]
    4988:	3728005a 	tbnz	w26, #5, 4990 <_vfprintf_r+0xfc0>
    498c:	36202c1a 	tbz	w26, #4, 4f0c <_vfprintf_r+0x153c>
    4990:	37f849c0 	tbnz	w0, #31, 52c8 <_vfprintf_r+0x18f8>
    4994:	f94043e0 	ldr	x0, [sp, #128]
    4998:	91003c01 	add	x1, x0, #0xf
    499c:	927df021 	and	x1, x1, #0xfffffffffffffff8
    49a0:	f90043e1 	str	x1, [sp, #128]
    49a4:	f9400000 	ldr	x0, [x0]
    49a8:	52800021 	mov	w1, #0x1                   	// #1
    49ac:	17ffffd7 	b	4908 <_vfprintf_r+0xf38>
    49b0:	39400328 	ldrb	w8, [x25]
    49b4:	7101b11f 	cmp	w8, #0x6c
    49b8:	540039e0 	b.eq	50f4 <_vfprintf_r+0x1724>  // b.none
    49bc:	321c02f7 	orr	w23, w23, #0x10
    49c0:	17fffc9e 	b	3c38 <_vfprintf_r+0x268>
    49c4:	39400328 	ldrb	w8, [x25]
    49c8:	7101a11f 	cmp	w8, #0x68
    49cc:	540039c0 	b.eq	5104 <_vfprintf_r+0x1734>  // b.none
    49d0:	321a02f7 	orr	w23, w23, #0x40
    49d4:	17fffc99 	b	3c38 <_vfprintf_r+0x268>
    49d8:	39400328 	ldrb	w8, [x25]
    49dc:	321b02f7 	orr	w23, w23, #0x20
    49e0:	17fffc96 	b	3c38 <_vfprintf_r+0x268>
    49e4:	b9407fe0 	ldr	w0, [sp, #124]
    49e8:	2a1703e9 	mov	w9, w23
    49ec:	2a1803eb 	mov	w11, w24
    49f0:	2a1a03e7 	mov	w7, w26
    49f4:	37f83020 	tbnz	w0, #31, 4ff8 <_vfprintf_r+0x1628>
    49f8:	f94043e0 	ldr	x0, [sp, #128]
    49fc:	91003c01 	add	x1, x0, #0xf
    4a00:	927df021 	and	x1, x1, #0xfffffffffffffff8
    4a04:	f90043e1 	str	x1, [sp, #128]
    4a08:	f9400000 	ldr	x0, [x0]
    4a0c:	528f0602 	mov	w2, #0x7830                	// #30768
    4a10:	90000063 	adrp	x3, 10000 <__env_lock>
    4a14:	321f013a 	orr	w26, w9, #0x2
    4a18:	91214063 	add	x3, x3, #0x850
    4a1c:	52800041 	mov	w1, #0x2                   	// #2
    4a20:	52800f08 	mov	w8, #0x78                  	// #120
    4a24:	f90063e3 	str	x3, [sp, #192]
    4a28:	7902a3e2 	strh	w2, [sp, #336]
    4a2c:	17ffffb7 	b	4908 <_vfprintf_r+0xf38>
    4a30:	b9407fe0 	ldr	w0, [sp, #124]
    4a34:	2a1703e9 	mov	w9, w23
    4a38:	362829c9 	tbz	w9, #5, 4f70 <_vfprintf_r+0x15a0>
    4a3c:	37f86a00 	tbnz	w0, #31, 577c <_vfprintf_r+0x1dac>
    4a40:	f94043e0 	ldr	x0, [sp, #128]
    4a44:	91003c01 	add	x1, x0, #0xf
    4a48:	927df021 	and	x1, x1, #0xfffffffffffffff8
    4a4c:	f90043e1 	str	x1, [sp, #128]
    4a50:	f9400000 	ldr	x0, [x0]
    4a54:	b98073e1 	ldrsw	x1, [sp, #112]
    4a58:	f9000001 	str	x1, [x0]
    4a5c:	17fffc24 	b	3aec <_vfprintf_r+0x11c>
    4a60:	2a1803eb 	mov	w11, w24
    4a64:	2a1a03e7 	mov	w7, w26
    4a68:	321c02e9 	orr	w9, w23, #0x10
    4a6c:	b9407fe0 	ldr	w0, [sp, #124]
    4a70:	37280049 	tbnz	w9, #5, 4a78 <_vfprintf_r+0x10a8>
    4a74:	362025e9 	tbz	w9, #4, 4f30 <_vfprintf_r+0x1560>
    4a78:	37f84000 	tbnz	w0, #31, 5278 <_vfprintf_r+0x18a8>
    4a7c:	f94043e0 	ldr	x0, [sp, #128]
    4a80:	91003c01 	add	x1, x0, #0xf
    4a84:	927df021 	and	x1, x1, #0xfffffffffffffff8
    4a88:	f90043e1 	str	x1, [sp, #128]
    4a8c:	f9400001 	ldr	x1, [x0]
    4a90:	aa0103e0 	mov	x0, x1
    4a94:	b7f82601 	tbnz	x1, #63, 4f54 <_vfprintf_r+0x1584>
    4a98:	310004ff 	cmn	w7, #0x1
    4a9c:	54000f40 	b.eq	4c84 <_vfprintf_r+0x12b4>  // b.none
    4aa0:	710000ff 	cmp	w7, #0x0
    4aa4:	12187929 	and	w9, w9, #0xffffff7f
    4aa8:	fa400800 	ccmp	x0, #0x0, #0x0, eq	// eq = none
    4aac:	54000ec1 	b.ne	4c84 <_vfprintf_r+0x12b4>  // b.any
    4ab0:	9107f3f8 	add	x24, sp, #0x1fc
    4ab4:	52800007 	mov	w7, #0x0                   	// #0
    4ab8:	5280001b 	mov	w27, #0x0                   	// #0
    4abc:	17ffffa3 	b	4948 <_vfprintf_r+0xf78>
    4ac0:	39400328 	ldrb	w8, [x25]
    4ac4:	321902f7 	orr	w23, w23, #0x80
    4ac8:	17fffc5c 	b	3c38 <_vfprintf_r+0x268>
    4acc:	2a0903fa 	mov	w26, w9
    4ad0:	7100043f 	cmp	w1, #0x1
    4ad4:	54000da0 	b.eq	4c88 <_vfprintf_r+0x12b8>  // b.none
    4ad8:	9107f3ec 	add	x12, sp, #0x1fc
    4adc:	aa0c03f8 	mov	x24, x12
    4ae0:	7100083f 	cmp	w1, #0x2
    4ae4:	54000161 	b.ne	4b10 <_vfprintf_r+0x1140>  // b.any
    4ae8:	f94063e2 	ldr	x2, [sp, #192]
    4aec:	d503201f 	nop
    4af0:	92400c01 	and	x1, x0, #0xf
    4af4:	d344fc00 	lsr	x0, x0, #4
    4af8:	38616841 	ldrb	w1, [x2, x1]
    4afc:	381fff01 	strb	w1, [x24, #-1]!
    4b00:	b5ffff80 	cbnz	x0, 4af0 <_vfprintf_r+0x1120>
    4b04:	4b18019b 	sub	w27, w12, w24
    4b08:	2a1a03e9 	mov	w9, w26
    4b0c:	17ffff8f 	b	4948 <_vfprintf_r+0xf78>
    4b10:	12000801 	and	w1, w0, #0x7
    4b14:	aa1803e2 	mov	x2, x24
    4b18:	1100c021 	add	w1, w1, #0x30
    4b1c:	381fff01 	strb	w1, [x24, #-1]!
    4b20:	d343fc00 	lsr	x0, x0, #3
    4b24:	b5ffff60 	cbnz	x0, 4b10 <_vfprintf_r+0x1140>
    4b28:	7100c03f 	cmp	w1, #0x30
    4b2c:	1a9f07e0 	cset	w0, ne	// ne = any
    4b30:	6a00035f 	tst	w26, w0
    4b34:	54fffe80 	b.eq	4b04 <_vfprintf_r+0x1134>  // b.none
    4b38:	d1000842 	sub	x2, x2, #0x2
    4b3c:	52800600 	mov	w0, #0x30                  	// #48
    4b40:	2a1a03e9 	mov	w9, w26
    4b44:	4b02019b 	sub	w27, w12, w2
    4b48:	381ff300 	sturb	w0, [x24, #-1]
    4b4c:	aa0203f8 	mov	x24, x2
    4b50:	17ffff7e 	b	4948 <_vfprintf_r+0xf78>
    4b54:	910603e2 	add	x2, sp, #0x180
    4b58:	aa1503e1 	mov	x1, x21
    4b5c:	aa1303e0 	mov	x0, x19
    4b60:	b900cbe9 	str	w9, [sp, #200]
    4b64:	b900d3e8 	str	w8, [sp, #208]
    4b68:	b900dbeb 	str	w11, [sp, #216]
    4b6c:	b900e3e7 	str	w7, [sp, #224]
    4b70:	b90113e3 	str	w3, [sp, #272]
    4b74:	940008e3 	bl	6f00 <__sprint_r>
    4b78:	35ffb380 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    4b7c:	f940cbe0 	ldr	x0, [sp, #400]
    4b80:	aa1603fc 	mov	x28, x22
    4b84:	b940cbe9 	ldr	w9, [sp, #200]
    4b88:	b940d3e8 	ldr	w8, [sp, #208]
    4b8c:	b940dbeb 	ldr	w11, [sp, #216]
    4b90:	b940e3e7 	ldr	w7, [sp, #224]
    4b94:	b94113e3 	ldr	w3, [sp, #272]
    4b98:	17fffc64 	b	3d28 <_vfprintf_r+0x358>
    4b9c:	9000006d 	adrp	x13, 10000 <__env_lock>
    4ba0:	b9418be1 	ldr	w1, [sp, #392]
    4ba4:	912581ad 	add	x13, x13, #0x960
    4ba8:	7100435f 	cmp	w26, #0x10
    4bac:	5400046d 	b.le	4c38 <_vfprintf_r+0x1268>
    4bb0:	2a1a03f8 	mov	w24, w26
    4bb4:	d280021b 	mov	x27, #0x10                  	// #16
    4bb8:	aa1903fa 	mov	x26, x25
    4bbc:	aa0d03f9 	mov	x25, x13
    4bc0:	b90093eb 	str	w11, [sp, #144]
    4bc4:	b9009be3 	str	w3, [sp, #152]
    4bc8:	14000004 	b	4bd8 <_vfprintf_r+0x1208>
    4bcc:	51004318 	sub	w24, w24, #0x10
    4bd0:	7100431f 	cmp	w24, #0x10
    4bd4:	5400028d 	b.le	4c24 <_vfprintf_r+0x1254>
    4bd8:	91004000 	add	x0, x0, #0x10
    4bdc:	11000421 	add	w1, w1, #0x1
    4be0:	a9006f99 	stp	x25, x27, [x28]
    4be4:	9100439c 	add	x28, x28, #0x10
    4be8:	b9018be1 	str	w1, [sp, #392]
    4bec:	f900cbe0 	str	x0, [sp, #400]
    4bf0:	71001c3f 	cmp	w1, #0x7
    4bf4:	54fffecd 	b.le	4bcc <_vfprintf_r+0x11fc>
    4bf8:	910603e2 	add	x2, sp, #0x180
    4bfc:	aa1503e1 	mov	x1, x21
    4c00:	aa1303e0 	mov	x0, x19
    4c04:	940008bf 	bl	6f00 <__sprint_r>
    4c08:	35ffaf00 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    4c0c:	51004318 	sub	w24, w24, #0x10
    4c10:	b9418be1 	ldr	w1, [sp, #392]
    4c14:	f940cbe0 	ldr	x0, [sp, #400]
    4c18:	aa1603fc 	mov	x28, x22
    4c1c:	7100431f 	cmp	w24, #0x10
    4c20:	54fffdcc 	b.gt	4bd8 <_vfprintf_r+0x1208>
    4c24:	b94093eb 	ldr	w11, [sp, #144]
    4c28:	aa1903ed 	mov	x13, x25
    4c2c:	b9409be3 	ldr	w3, [sp, #152]
    4c30:	aa1a03f9 	mov	x25, x26
    4c34:	2a1803fa 	mov	w26, w24
    4c38:	93407f5a 	sxtw	x26, w26
    4c3c:	11000421 	add	w1, w1, #0x1
    4c40:	8b1a0000 	add	x0, x0, x26
    4c44:	a9006b8d 	stp	x13, x26, [x28]
    4c48:	b9018be1 	str	w1, [sp, #392]
    4c4c:	f900cbe0 	str	x0, [sp, #400]
    4c50:	71001c3f 	cmp	w1, #0x7
    4c54:	54ff892d 	b.le	3d78 <_vfprintf_r+0x3a8>
    4c58:	910603e2 	add	x2, sp, #0x180
    4c5c:	aa1503e1 	mov	x1, x21
    4c60:	aa1303e0 	mov	x0, x19
    4c64:	b90093eb 	str	w11, [sp, #144]
    4c68:	b9009be3 	str	w3, [sp, #152]
    4c6c:	940008a5 	bl	6f00 <__sprint_r>
    4c70:	35ffabc0 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    4c74:	f940cbe0 	ldr	x0, [sp, #400]
    4c78:	b94093eb 	ldr	w11, [sp, #144]
    4c7c:	b9409be3 	ldr	w3, [sp, #152]
    4c80:	17fffc3e 	b	3d78 <_vfprintf_r+0x3a8>
    4c84:	2a0903fa 	mov	w26, w9
    4c88:	f100241f 	cmp	x0, #0x9
    4c8c:	54005108 	b.hi	56ac <_vfprintf_r+0x1cdc>  // b.pmore
    4c90:	1100c000 	add	w0, w0, #0x30
    4c94:	2a1a03e9 	mov	w9, w26
    4c98:	9107eff8 	add	x24, sp, #0x1fb
    4c9c:	5280003b 	mov	w27, #0x1                   	// #1
    4ca0:	3907efe0 	strb	w0, [sp, #507]
    4ca4:	17ffff29 	b	4948 <_vfprintf_r+0xf78>
    4ca8:	9107f3f8 	add	x24, sp, #0x1fc
    4cac:	52800007 	mov	w7, #0x0                   	// #0
    4cb0:	17ffff26 	b	4948 <_vfprintf_r+0xf78>
    4cb4:	b9409fe1 	ldr	w1, [sp, #156]
    4cb8:	b94093e2 	ldr	w2, [sp, #144]
    4cbc:	6b01005f 	cmp	w2, w1
    4cc0:	8b21c304 	add	x4, x24, w1, sxtw
    4cc4:	1a81d05b 	csel	w27, w2, w1, le
    4cc8:	f90067e4 	str	x4, [sp, #200]
    4ccc:	7100037f 	cmp	w27, #0x0
    4cd0:	5400016d 	b.le	4cfc <_vfprintf_r+0x132c>
    4cd4:	b9418be1 	ldr	w1, [sp, #392]
    4cd8:	93407f62 	sxtw	x2, w27
    4cdc:	8b020000 	add	x0, x0, x2
    4ce0:	a9000b98 	stp	x24, x2, [x28]
    4ce4:	11000421 	add	w1, w1, #0x1
    4ce8:	b9018be1 	str	w1, [sp, #392]
    4cec:	9100439c 	add	x28, x28, #0x10
    4cf0:	f900cbe0 	str	x0, [sp, #400]
    4cf4:	71001c3f 	cmp	w1, #0x7
    4cf8:	5400b32c 	b.gt	635c <_vfprintf_r+0x298c>
    4cfc:	7100037f 	cmp	w27, #0x0
    4d00:	b94093e1 	ldr	w1, [sp, #144]
    4d04:	1a9fa364 	csel	w4, w27, wzr, ge	// ge = tcont
    4d08:	4b04003b 	sub	w27, w1, w4
    4d0c:	7100037f 	cmp	w27, #0x0
    4d10:	5400554c 	b.gt	57b8 <_vfprintf_r+0x1de8>
    4d14:	b94093e1 	ldr	w1, [sp, #144]
    4d18:	8b21c318 	add	x24, x24, w1, sxtw
    4d1c:	37508be9 	tbnz	w9, #10, 5e98 <_vfprintf_r+0x24c8>
    4d20:	b9409fe1 	ldr	w1, [sp, #156]
    4d24:	b9415bfa 	ldr	w26, [sp, #344]
    4d28:	6b01035f 	cmp	w26, w1
    4d2c:	5400004b 	b.lt	4d34 <_vfprintf_r+0x1364>  // b.tstop
    4d30:	36007869 	tbz	w9, #0, 5c3c <_vfprintf_r+0x226c>
    4d34:	a94b13e2 	ldp	x2, x4, [sp, #176]
    4d38:	a9000b84 	stp	x4, x2, [x28]
    4d3c:	b9418be1 	ldr	w1, [sp, #392]
    4d40:	9100439c 	add	x28, x28, #0x10
    4d44:	11000421 	add	w1, w1, #0x1
    4d48:	b9018be1 	str	w1, [sp, #392]
    4d4c:	8b020000 	add	x0, x0, x2
    4d50:	f900cbe0 	str	x0, [sp, #400]
    4d54:	71001c3f 	cmp	w1, #0x7
    4d58:	5400b32c 	b.gt	63bc <_vfprintf_r+0x29ec>
    4d5c:	b9409fe1 	ldr	w1, [sp, #156]
    4d60:	4b1a003a 	sub	w26, w1, w26
    4d64:	f94067e1 	ldr	x1, [sp, #200]
    4d68:	cb18003b 	sub	x27, x1, x24
    4d6c:	6b1b035f 	cmp	w26, w27
    4d70:	1a9bb35b 	csel	w27, w26, w27, lt	// lt = tstop
    4d74:	7100037f 	cmp	w27, #0x0
    4d78:	5400016d 	b.le	4da4 <_vfprintf_r+0x13d4>
    4d7c:	b9418be1 	ldr	w1, [sp, #392]
    4d80:	93407f62 	sxtw	x2, w27
    4d84:	8b020000 	add	x0, x0, x2
    4d88:	a9000b98 	stp	x24, x2, [x28]
    4d8c:	11000421 	add	w1, w1, #0x1
    4d90:	b9018be1 	str	w1, [sp, #392]
    4d94:	9100439c 	add	x28, x28, #0x10
    4d98:	f900cbe0 	str	x0, [sp, #400]
    4d9c:	71001c3f 	cmp	w1, #0x7
    4da0:	5400b52c 	b.gt	6444 <_vfprintf_r+0x2a74>
    4da4:	7100037f 	cmp	w27, #0x0
    4da8:	1a9fa37b 	csel	w27, w27, wzr, ge	// ge = tcont
    4dac:	4b1b035a 	sub	w26, w26, w27
    4db0:	7100035f 	cmp	w26, #0x0
    4db4:	54ff7dad 	b.le	3d68 <_vfprintf_r+0x398>
    4db8:	90000064 	adrp	x4, 10000 <__env_lock>
    4dbc:	b9418be1 	ldr	w1, [sp, #392]
    4dc0:	91254084 	add	x4, x4, #0x950
    4dc4:	7100435f 	cmp	w26, #0x10
    4dc8:	540045ed 	b.le	5684 <_vfprintf_r+0x1cb4>
    4dcc:	2a1a03e5 	mov	w5, w26
    4dd0:	aa1c03e2 	mov	x2, x28
    4dd4:	aa1703fa 	mov	x26, x23
    4dd8:	aa1903fc 	mov	x28, x25
    4ddc:	aa0403f8 	mov	x24, x4
    4de0:	2a0303f9 	mov	w25, w3
    4de4:	2a0503f7 	mov	w23, w5
    4de8:	d280021b 	mov	x27, #0x10                  	// #16
    4dec:	b90093e9 	str	w9, [sp, #144]
    4df0:	b9009beb 	str	w11, [sp, #152]
    4df4:	14000004 	b	4e04 <_vfprintf_r+0x1434>
    4df8:	510042f7 	sub	w23, w23, #0x10
    4dfc:	710042ff 	cmp	w23, #0x10
    4e00:	5400acad 	b.le	6394 <_vfprintf_r+0x29c4>
    4e04:	91004000 	add	x0, x0, #0x10
    4e08:	11000421 	add	w1, w1, #0x1
    4e0c:	a9006c58 	stp	x24, x27, [x2]
    4e10:	91004042 	add	x2, x2, #0x10
    4e14:	b9018be1 	str	w1, [sp, #392]
    4e18:	f900cbe0 	str	x0, [sp, #400]
    4e1c:	71001c3f 	cmp	w1, #0x7
    4e20:	54fffecd 	b.le	4df8 <_vfprintf_r+0x1428>
    4e24:	910603e2 	add	x2, sp, #0x180
    4e28:	aa1503e1 	mov	x1, x21
    4e2c:	aa1303e0 	mov	x0, x19
    4e30:	94000834 	bl	6f00 <__sprint_r>
    4e34:	3500e0c0 	cbnz	w0, 6a4c <_vfprintf_r+0x307c>
    4e38:	f940cbe0 	ldr	x0, [sp, #400]
    4e3c:	aa1603e2 	mov	x2, x22
    4e40:	b9418be1 	ldr	w1, [sp, #392]
    4e44:	17ffffed 	b	4df8 <_vfprintf_r+0x1428>
    4e48:	910603e2 	add	x2, sp, #0x180
    4e4c:	aa1503e1 	mov	x1, x21
    4e50:	aa1303e0 	mov	x0, x19
    4e54:	b90093e9 	str	w9, [sp, #144]
    4e58:	b9009beb 	str	w11, [sp, #152]
    4e5c:	b900a3e3 	str	w3, [sp, #160]
    4e60:	94000828 	bl	6f00 <__sprint_r>
    4e64:	35ff9c20 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    4e68:	f940cbe0 	ldr	x0, [sp, #400]
    4e6c:	aa1603e7 	mov	x7, x22
    4e70:	b94093e9 	ldr	w9, [sp, #144]
    4e74:	b9409beb 	ldr	w11, [sp, #152]
    4e78:	b940a3e3 	ldr	w3, [sp, #160]
    4e7c:	b9418be1 	ldr	w1, [sp, #392]
    4e80:	17fffd55 	b	43d4 <_vfprintf_r+0xa04>
    4e84:	910603e2 	add	x2, sp, #0x180
    4e88:	aa1503e1 	mov	x1, x21
    4e8c:	aa1303e0 	mov	x0, x19
    4e90:	b90093e9 	str	w9, [sp, #144]
    4e94:	b9009beb 	str	w11, [sp, #152]
    4e98:	b900a3e3 	str	w3, [sp, #160]
    4e9c:	94000819 	bl	6f00 <__sprint_r>
    4ea0:	35ff9a40 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    4ea4:	1e602108 	fcmp	d8, #0.0
    4ea8:	b9409fe2 	ldr	w2, [sp, #156]
    4eac:	f940cbe0 	ldr	x0, [sp, #400]
    4eb0:	aa1603e7 	mov	x7, x22
    4eb4:	b94093e9 	ldr	w9, [sp, #144]
    4eb8:	5100045a 	sub	w26, w2, #0x1
    4ebc:	b9409beb 	ldr	w11, [sp, #152]
    4ec0:	b940a3e3 	ldr	w3, [sp, #160]
    4ec4:	b9418be1 	ldr	w1, [sp, #392]
    4ec8:	54ffbb00 	b.eq	4628 <_vfprintf_r+0xc58>  // b.none
    4ecc:	17fffd4f 	b	4408 <_vfprintf_r+0xa38>
    4ed0:	f94052a0 	ldr	x0, [x21, #160]
    4ed4:	f9003be9 	str	x9, [sp, #112]
    4ed8:	940011d6 	bl	9630 <__retarget_lock_acquire_recursive>
    4edc:	f9403be9 	ldr	x9, [sp, #112]
    4ee0:	79c022a0 	ldrsh	w0, [x21, #16]
    4ee4:	17fffadf 	b	3a60 <_vfprintf_r+0x90>
    4ee8:	36077409 	tbz	w9, #0, 3d68 <_vfprintf_r+0x398>
    4eec:	17fffc17 	b	3f48 <_vfprintf_r+0x578>
    4ef0:	37f88ec0 	tbnz	w0, #31, 60c8 <_vfprintf_r+0x26f8>
    4ef4:	f94043e0 	ldr	x0, [sp, #128]
    4ef8:	91003c01 	add	x1, x0, #0xf
    4efc:	fd400008 	ldr	d8, [x0]
    4f00:	927df021 	and	x1, x1, #0xfffffffffffffff8
    4f04:	f90043e1 	str	x1, [sp, #128]
    4f08:	17fffd99 	b	456c <_vfprintf_r+0xb9c>
    4f0c:	3630507a 	tbz	w26, #6, 5918 <_vfprintf_r+0x1f48>
    4f10:	37f87740 	tbnz	w0, #31, 5df8 <_vfprintf_r+0x2428>
    4f14:	f94043e0 	ldr	x0, [sp, #128]
    4f18:	91002c01 	add	x1, x0, #0xb
    4f1c:	927df021 	and	x1, x1, #0xfffffffffffffff8
    4f20:	f90043e1 	str	x1, [sp, #128]
    4f24:	79400000 	ldrh	w0, [x0]
    4f28:	52800021 	mov	w1, #0x1                   	// #1
    4f2c:	17fffe77 	b	4908 <_vfprintf_r+0xf38>
    4f30:	36304ce9 	tbz	w9, #6, 58cc <_vfprintf_r+0x1efc>
    4f34:	37f87380 	tbnz	w0, #31, 5da4 <_vfprintf_r+0x23d4>
    4f38:	f94043e0 	ldr	x0, [sp, #128]
    4f3c:	91002c01 	add	x1, x0, #0xb
    4f40:	927df021 	and	x1, x1, #0xfffffffffffffff8
    4f44:	f90043e1 	str	x1, [sp, #128]
    4f48:	79800000 	ldrsh	x0, [x0]
    4f4c:	aa0003e1 	mov	x1, x0
    4f50:	b6ffda41 	tbz	x1, #63, 4a98 <_vfprintf_r+0x10c8>
    4f54:	cb0003e0 	neg	x0, x0
    4f58:	2a0903fa 	mov	w26, w9
    4f5c:	528005a2 	mov	w2, #0x2d                  	// #45
    4f60:	52800021 	mov	w1, #0x1                   	// #1
    4f64:	17fffe6a 	b	490c <_vfprintf_r+0xf3c>
    4f68:	39400328 	ldrb	w8, [x25]
    4f6c:	17fffb33 	b	3c38 <_vfprintf_r+0x268>
    4f70:	3727d669 	tbnz	w9, #4, 4a3c <_vfprintf_r+0x106c>
    4f74:	37306729 	tbnz	w9, #6, 5c58 <_vfprintf_r+0x2288>
    4f78:	3648bf49 	tbz	w9, #9, 6760 <_vfprintf_r+0x2d90>
    4f7c:	37f8d860 	tbnz	w0, #31, 6a88 <_vfprintf_r+0x30b8>
    4f80:	f94043e0 	ldr	x0, [sp, #128]
    4f84:	91003c01 	add	x1, x0, #0xf
    4f88:	927df021 	and	x1, x1, #0xfffffffffffffff8
    4f8c:	f90043e1 	str	x1, [sp, #128]
    4f90:	f9400000 	ldr	x0, [x0]
    4f94:	3941c3e1 	ldrb	w1, [sp, #112]
    4f98:	39000001 	strb	w1, [x0]
    4f9c:	17fffad4 	b	3aec <_vfprintf_r+0x11c>
    4fa0:	36304869 	tbz	w9, #6, 58ac <_vfprintf_r+0x1edc>
    4fa4:	37f86ea0 	tbnz	w0, #31, 5d78 <_vfprintf_r+0x23a8>
    4fa8:	f94043e0 	ldr	x0, [sp, #128]
    4fac:	91002c01 	add	x1, x0, #0xb
    4fb0:	927df021 	and	x1, x1, #0xfffffffffffffff8
    4fb4:	79400000 	ldrh	w0, [x0]
    4fb8:	f90043e1 	str	x1, [sp, #128]
    4fbc:	17fffe51 	b	4900 <_vfprintf_r+0xf30>
    4fc0:	2a1703e9 	mov	w9, w23
    4fc4:	2a1803eb 	mov	w11, w24
    4fc8:	2a1a03e7 	mov	w7, w26
    4fcc:	17fffea8 	b	4a6c <_vfprintf_r+0x109c>
    4fd0:	b9407fe0 	ldr	w0, [sp, #124]
    4fd4:	11002001 	add	w1, w0, #0x8
    4fd8:	7100003f 	cmp	w1, #0x0
    4fdc:	54009a0d 	b.le	631c <_vfprintf_r+0x294c>
    4fe0:	f94043e0 	ldr	x0, [sp, #128]
    4fe4:	b9007fe1 	str	w1, [sp, #124]
    4fe8:	91003c02 	add	x2, x0, #0xf
    4fec:	927df041 	and	x1, x2, #0xfffffffffffffff8
    4ff0:	f90043e1 	str	x1, [sp, #128]
    4ff4:	17fffdd2 	b	473c <_vfprintf_r+0xd6c>
    4ff8:	b9407fe0 	ldr	w0, [sp, #124]
    4ffc:	11002001 	add	w1, w0, #0x8
    5000:	7100003f 	cmp	w1, #0x0
    5004:	5400982d 	b.le	6308 <_vfprintf_r+0x2938>
    5008:	f94043e0 	ldr	x0, [sp, #128]
    500c:	b9007fe1 	str	w1, [sp, #124]
    5010:	91003c02 	add	x2, x0, #0xf
    5014:	927df041 	and	x1, x2, #0xfffffffffffffff8
    5018:	f90043e1 	str	x1, [sp, #128]
    501c:	17fffe7b 	b	4a08 <_vfprintf_r+0x1038>
    5020:	b9407fe0 	ldr	w0, [sp, #124]
    5024:	11002001 	add	w1, w0, #0x8
    5028:	7100003f 	cmp	w1, #0x0
    502c:	5400960d 	b.le	62ec <_vfprintf_r+0x291c>
    5030:	f94043e0 	ldr	x0, [sp, #128]
    5034:	b9007fe1 	str	w1, [sp, #124]
    5038:	91002c00 	add	x0, x0, #0xb
    503c:	927df000 	and	x0, x0, #0xfffffffffffffff8
    5040:	17fffe00 	b	4840 <_vfprintf_r+0xe70>
    5044:	b94093e9 	ldr	w9, [sp, #144]
    5048:	aa1903e4 	mov	x4, x25
    504c:	b9409be3 	ldr	w3, [sp, #152]
    5050:	aa1a03f9 	mov	x25, x26
    5054:	2a1c03eb 	mov	w11, w28
    5058:	2a1803fa 	mov	w26, w24
    505c:	93407f5a 	sxtw	x26, w26
    5060:	11000421 	add	w1, w1, #0x1
    5064:	8b1a0000 	add	x0, x0, x26
    5068:	b9018be1 	str	w1, [sp, #392]
    506c:	f900cbe0 	str	x0, [sp, #400]
    5070:	f90000e4 	str	x4, [x7]
    5074:	f90004fa 	str	x26, [x7, #8]
    5078:	71001c3f 	cmp	w1, #0x7
    507c:	54ff9dad 	b.le	4430 <_vfprintf_r+0xa60>
    5080:	910603e2 	add	x2, sp, #0x180
    5084:	aa1503e1 	mov	x1, x21
    5088:	aa1303e0 	mov	x0, x19
    508c:	b90093e9 	str	w9, [sp, #144]
    5090:	b9009beb 	str	w11, [sp, #152]
    5094:	b900a3e3 	str	w3, [sp, #160]
    5098:	9400079a 	bl	6f00 <__sprint_r>
    509c:	35ff8a60 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    50a0:	f940cbe0 	ldr	x0, [sp, #400]
    50a4:	aa1603e7 	mov	x7, x22
    50a8:	b94093e9 	ldr	w9, [sp, #144]
    50ac:	b9409beb 	ldr	w11, [sp, #152]
    50b0:	b940a3e3 	ldr	w3, [sp, #160]
    50b4:	b9418be1 	ldr	w1, [sp, #392]
    50b8:	17fffcdf 	b	4434 <_vfprintf_r+0xa64>
    50bc:	910603e2 	add	x2, sp, #0x180
    50c0:	aa1503e1 	mov	x1, x21
    50c4:	aa1303e0 	mov	x0, x19
    50c8:	b90093e9 	str	w9, [sp, #144]
    50cc:	b9009beb 	str	w11, [sp, #152]
    50d0:	b900a3e3 	str	w3, [sp, #160]
    50d4:	9400078b 	bl	6f00 <__sprint_r>
    50d8:	35ff8880 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    50dc:	f940cbe0 	ldr	x0, [sp, #400]
    50e0:	aa1603fc 	mov	x28, x22
    50e4:	b94093e9 	ldr	w9, [sp, #144]
    50e8:	b9409beb 	ldr	w11, [sp, #152]
    50ec:	b940a3e3 	ldr	w3, [sp, #160]
    50f0:	17fffba0 	b	3f70 <_vfprintf_r+0x5a0>
    50f4:	39400728 	ldrb	w8, [x25, #1]
    50f8:	321b02f7 	orr	w23, w23, #0x20
    50fc:	91000739 	add	x25, x25, #0x1
    5100:	17ffface 	b	3c38 <_vfprintf_r+0x268>
    5104:	39400728 	ldrb	w8, [x25, #1]
    5108:	321702f7 	orr	w23, w23, #0x200
    510c:	91000739 	add	x25, x25, #0x1
    5110:	17fffaca 	b	3c38 <_vfprintf_r+0x268>
    5114:	2a1a03e7 	mov	w7, w26
    5118:	2a1803eb 	mov	w11, w24
    511c:	2a1703fa 	mov	w26, w23
    5120:	17fffe19 	b	4984 <_vfprintf_r+0xfb4>
    5124:	2a1703e9 	mov	w9, w23
    5128:	2a1803eb 	mov	w11, w24
    512c:	2a1a03e7 	mov	w7, w26
    5130:	f0000040 	adrp	x0, 10000 <__env_lock>
    5134:	9121a000 	add	x0, x0, #0x868
    5138:	f90063e0 	str	x0, [sp, #192]
    513c:	b9407fe0 	ldr	w0, [sp, #124]
    5140:	372806e9 	tbnz	w9, #5, 521c <_vfprintf_r+0x184c>
    5144:	372006c9 	tbnz	w9, #4, 521c <_vfprintf_r+0x184c>
    5148:	36303849 	tbz	w9, #6, 5850 <_vfprintf_r+0x1e80>
    514c:	37f86400 	tbnz	w0, #31, 5dcc <_vfprintf_r+0x23fc>
    5150:	f94043e0 	ldr	x0, [sp, #128]
    5154:	91002c01 	add	x1, x0, #0xb
    5158:	927df021 	and	x1, x1, #0xfffffffffffffff8
    515c:	79400000 	ldrh	w0, [x0]
    5160:	f90043e1 	str	x1, [sp, #128]
    5164:	14000034 	b	5234 <_vfprintf_r+0x1864>
    5168:	f0000040 	adrp	x0, 10000 <__env_lock>
    516c:	2a1703e9 	mov	w9, w23
    5170:	91214000 	add	x0, x0, #0x850
    5174:	2a1803eb 	mov	w11, w24
    5178:	2a1a03e7 	mov	w7, w26
    517c:	f90063e0 	str	x0, [sp, #192]
    5180:	17ffffef 	b	513c <_vfprintf_r+0x176c>
    5184:	2a1703e9 	mov	w9, w23
    5188:	2a1803eb 	mov	w11, w24
    518c:	2a1a03e7 	mov	w7, w26
    5190:	17fffdd3 	b	48dc <_vfprintf_r+0xf0c>
    5194:	9105e3e0 	add	x0, sp, #0x178
    5198:	d2800102 	mov	x2, #0x8                   	// #8
    519c:	52800001 	mov	w1, #0x0                   	// #0
    51a0:	b90093e9 	str	w9, [sp, #144]
    51a4:	b9009be8 	str	w8, [sp, #152]
    51a8:	b900a3eb 	str	w11, [sp, #160]
    51ac:	94001655 	bl	ab00 <memset>
    51b0:	b9407fe0 	ldr	w0, [sp, #124]
    51b4:	b94093e9 	ldr	w9, [sp, #144]
    51b8:	b9409be8 	ldr	w8, [sp, #152]
    51bc:	b940a3eb 	ldr	w11, [sp, #160]
    51c0:	37f83620 	tbnz	w0, #31, 5884 <_vfprintf_r+0x1eb4>
    51c4:	f94043e0 	ldr	x0, [sp, #128]
    51c8:	91002c01 	add	x1, x0, #0xb
    51cc:	927df021 	and	x1, x1, #0xfffffffffffffff8
    51d0:	f90043e1 	str	x1, [sp, #128]
    51d4:	b9400002 	ldr	w2, [x0]
    51d8:	910663f7 	add	x23, sp, #0x198
    51dc:	9105e3e3 	add	x3, sp, #0x178
    51e0:	aa1703e1 	mov	x1, x23
    51e4:	aa1303e0 	mov	x0, x19
    51e8:	b90093e9 	str	w9, [sp, #144]
    51ec:	b9009be8 	str	w8, [sp, #152]
    51f0:	b900a3eb 	str	w11, [sp, #160]
    51f4:	940010af 	bl	94b0 <_wcrtomb_r>
    51f8:	b94093e9 	ldr	w9, [sp, #144]
    51fc:	2a0003fb 	mov	w27, w0
    5200:	b9409be8 	ldr	w8, [sp, #152]
    5204:	3100041f 	cmn	w0, #0x1
    5208:	b940a3eb 	ldr	w11, [sp, #160]
    520c:	5400caa0 	b.eq	6b60 <_vfprintf_r+0x3190>  // b.none
    5210:	7100001f 	cmp	w0, #0x0
    5214:	1a9fa003 	csel	w3, w0, wzr, ge	// ge = tcont
    5218:	17fffd37 	b	46f4 <_vfprintf_r+0xd24>
    521c:	37f801a0 	tbnz	w0, #31, 5250 <_vfprintf_r+0x1880>
    5220:	f94043e0 	ldr	x0, [sp, #128]
    5224:	91003c01 	add	x1, x0, #0xf
    5228:	927df021 	and	x1, x1, #0xfffffffffffffff8
    522c:	f90043e1 	str	x1, [sp, #128]
    5230:	f9400000 	ldr	x0, [x0]
    5234:	f100001f 	cmp	x0, #0x0
    5238:	1a9f07e1 	cset	w1, ne	// ne = any
    523c:	6a01013f 	tst	w9, w1
    5240:	540008a1 	b.ne	5354 <_vfprintf_r+0x1984>  // b.any
    5244:	1215793a 	and	w26, w9, #0xfffffbff
    5248:	52800041 	mov	w1, #0x2                   	// #2
    524c:	17fffdaf 	b	4908 <_vfprintf_r+0xf38>
    5250:	b9407fe0 	ldr	w0, [sp, #124]
    5254:	11002001 	add	w1, w0, #0x8
    5258:	7100003f 	cmp	w1, #0x0
    525c:	540034ad 	b.le	58f0 <_vfprintf_r+0x1f20>
    5260:	f94043e0 	ldr	x0, [sp, #128]
    5264:	b9007fe1 	str	w1, [sp, #124]
    5268:	91003c02 	add	x2, x0, #0xf
    526c:	927df041 	and	x1, x2, #0xfffffffffffffff8
    5270:	f90043e1 	str	x1, [sp, #128]
    5274:	17ffffef 	b	5230 <_vfprintf_r+0x1860>
    5278:	b9407fe0 	ldr	w0, [sp, #124]
    527c:	11002001 	add	w1, w0, #0x8
    5280:	7100003f 	cmp	w1, #0x0
    5284:	5400340d 	b.le	5904 <_vfprintf_r+0x1f34>
    5288:	f94043e0 	ldr	x0, [sp, #128]
    528c:	b9007fe1 	str	w1, [sp, #124]
    5290:	91003c02 	add	x2, x0, #0xf
    5294:	927df041 	and	x1, x2, #0xfffffffffffffff8
    5298:	f90043e1 	str	x1, [sp, #128]
    529c:	17fffdfc 	b	4a8c <_vfprintf_r+0x10bc>
    52a0:	b9407fe0 	ldr	w0, [sp, #124]
    52a4:	11002001 	add	w1, w0, #0x8
    52a8:	7100003f 	cmp	w1, #0x0
    52ac:	54002e2d 	b.le	5870 <_vfprintf_r+0x1ea0>
    52b0:	f94043e0 	ldr	x0, [sp, #128]
    52b4:	b9007fe1 	str	w1, [sp, #124]
    52b8:	91003c02 	add	x2, x0, #0xf
    52bc:	927df041 	and	x1, x2, #0xfffffffffffffff8
    52c0:	f90043e1 	str	x1, [sp, #128]
    52c4:	17fffd8e 	b	48fc <_vfprintf_r+0xf2c>
    52c8:	b9407fe0 	ldr	w0, [sp, #124]
    52cc:	11002001 	add	w1, w0, #0x8
    52d0:	7100003f 	cmp	w1, #0x0
    52d4:	5400334d 	b.le	593c <_vfprintf_r+0x1f6c>
    52d8:	f94043e0 	ldr	x0, [sp, #128]
    52dc:	b9007fe1 	str	w1, [sp, #124]
    52e0:	91003c02 	add	x2, x0, #0xf
    52e4:	927df041 	and	x1, x2, #0xfffffffffffffff8
    52e8:	f90043e1 	str	x1, [sp, #128]
    52ec:	17fffdae 	b	49a4 <_vfprintf_r+0xfd4>
    52f0:	910603e2 	add	x2, sp, #0x180
    52f4:	aa1503e1 	mov	x1, x21
    52f8:	aa1303e0 	mov	x0, x19
    52fc:	b900cbf2 	str	w18, [sp, #200]
    5300:	b900d3e9 	str	w9, [sp, #208]
    5304:	b900dbe8 	str	w8, [sp, #216]
    5308:	b900e3eb 	str	w11, [sp, #224]
    530c:	b90113e7 	str	w7, [sp, #272]
    5310:	b9011be3 	str	w3, [sp, #280]
    5314:	940006fb 	bl	6f00 <__sprint_r>
    5318:	35ff7680 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    531c:	f940cbe0 	ldr	x0, [sp, #400]
    5320:	aa1603fc 	mov	x28, x22
    5324:	39453fe1 	ldrb	w1, [sp, #335]
    5328:	b940cbf2 	ldr	w18, [sp, #200]
    532c:	b940d3e9 	ldr	w9, [sp, #208]
    5330:	b940dbe8 	ldr	w8, [sp, #216]
    5334:	b940e3eb 	ldr	w11, [sp, #224]
    5338:	b94113e7 	ldr	w7, [sp, #272]
    533c:	b9411be3 	ldr	w3, [sp, #280]
    5340:	17fffa60 	b	3cc0 <_vfprintf_r+0x2f0>
    5344:	aa1303e0 	mov	x0, x19
    5348:	97fff782 	bl	3150 <__sinit>
    534c:	f9403be9 	ldr	x9, [sp, #112]
    5350:	17fff9c0 	b	3a50 <_vfprintf_r+0x80>
    5354:	52800601 	mov	w1, #0x30                  	// #48
    5358:	321f0129 	orr	w9, w9, #0x2
    535c:	390543e1 	strb	w1, [sp, #336]
    5360:	390547e8 	strb	w8, [sp, #337]
    5364:	17ffffb8 	b	5244 <_vfprintf_r+0x1874>
    5368:	1e682100 	fcmp	d8, d8
    536c:	5400a3c6 	b.vs	67e4 <_vfprintf_r+0x2e14>
    5370:	121a791b 	and	w27, w8, #0xffffffdf
    5374:	7101077f 	cmp	w27, #0x41
    5378:	54002ec1 	b.ne	5950 <_vfprintf_r+0x1f80>  // b.any
    537c:	52800b01 	mov	w1, #0x58                  	// #88
    5380:	7101851f 	cmp	w8, #0x61
    5384:	52800f00 	mov	w0, #0x78                  	// #120
    5388:	1a810000 	csel	w0, w0, w1, eq	// eq = none
    538c:	52800601 	mov	w1, #0x30                  	// #48
    5390:	390543e1 	strb	w1, [sp, #336]
    5394:	390547e0 	strb	w0, [sp, #337]
    5398:	910663f8 	add	x24, sp, #0x198
    539c:	d2800017 	mov	x23, #0x0                   	// #0
    53a0:	71018cff 	cmp	w7, #0x63
    53a4:	540054ec 	b.gt	5e40 <_vfprintf_r+0x2470>
    53a8:	9e660101 	fmov	x1, d8
    53ac:	1e614100 	fneg	d0, d8
    53b0:	528005a2 	mov	w2, #0x2d                  	// #45
    53b4:	910563e0 	add	x0, sp, #0x158
    53b8:	b90093e9 	str	w9, [sp, #144]
    53bc:	29132fe8 	stp	w8, w11, [sp, #152]
    53c0:	d360fc21 	lsr	x1, x1, #32
    53c4:	b900a3e7 	str	w7, [sp, #160]
    53c8:	7100003f 	cmp	w1, #0x0
    53cc:	1a9fb041 	csel	w1, w2, wzr, lt	// lt = tstop
    53d0:	b900cbe1 	str	w1, [sp, #200]
    53d4:	1e68bc00 	fcsel	d0, d0, d8, lt	// lt = tstop
    53d8:	94001c86 	bl	c5f0 <frexp>
    53dc:	1e681001 	fmov	d1, #1.250000000000000000e-01
    53e0:	b94093e9 	ldr	w9, [sp, #144]
    53e4:	29532fe8 	ldp	w8, w11, [sp, #152]
    53e8:	1e610801 	fmul	d1, d0, d1
    53ec:	b940a3e7 	ldr	w7, [sp, #160]
    53f0:	1e602028 	fcmp	d1, #0.0
    53f4:	54005160 	b.eq	5e20 <_vfprintf_r+0x2450>  // b.none
    53f8:	2a0703e3 	mov	w3, w7
    53fc:	7101851f 	cmp	w8, #0x61
    5400:	91000463 	add	x3, x3, #0x1
    5404:	f0000040 	adrp	x0, 10000 <__env_lock>
    5408:	f0000042 	adrp	x2, 10000 <__env_lock>
    540c:	9121a000 	add	x0, x0, #0x868
    5410:	91214042 	add	x2, x2, #0x850
    5414:	8b030303 	add	x3, x24, x3
    5418:	9a800042 	csel	x2, x2, x0, eq	// eq = none
    541c:	1e661002 	fmov	d2, #1.600000000000000000e+01
    5420:	aa1803e0 	mov	x0, x24
    5424:	14000003 	b	5430 <_vfprintf_r+0x1a60>
    5428:	1e602028 	fcmp	d1, #0.0
    542c:	5400a6c0 	b.eq	6904 <_vfprintf_r+0x2f34>  // b.none
    5430:	1e620821 	fmul	d1, d1, d2
    5434:	aa0003ec 	mov	x12, x0
    5438:	1e780021 	fcvtzs	w1, d1
    543c:	1e620020 	scvtf	d0, w1
    5440:	3861c844 	ldrb	w4, [x2, w1, sxtw]
    5444:	38001404 	strb	w4, [x0], #1
    5448:	1e603821 	fsub	d1, d1, d0
    544c:	eb00007f 	cmp	x3, x0
    5450:	54fffec1 	b.ne	5428 <_vfprintf_r+0x1a58>  // b.any
    5454:	12800003 	mov	w3, #0xffffffff            	// #-1
    5458:	1e6c1000 	fmov	d0, #5.000000000000000000e-01
    545c:	1e602030 	fcmpe	d1, d0
    5460:	540092cc 	b.gt	66b8 <_vfprintf_r+0x2ce8>
    5464:	1e602020 	fcmp	d1, d0
    5468:	54000041 	b.ne	5470 <_vfprintf_r+0x1aa0>  // b.any
    546c:	37009261 	tbnz	w1, #0, 66b8 <_vfprintf_r+0x2ce8>
    5470:	11000461 	add	w1, w3, #0x1
    5474:	52800602 	mov	w2, #0x30                  	// #48
    5478:	8b21c001 	add	x1, x0, w1, sxtw
    547c:	37f89443 	tbnz	w3, #31, 6704 <_vfprintf_r+0x2d34>
    5480:	38001402 	strb	w2, [x0], #1
    5484:	eb00003f 	cmp	x1, x0
    5488:	54ffffc1 	b.ne	5480 <_vfprintf_r+0x1ab0>  // b.any
    548c:	b9415be0 	ldr	w0, [sp, #344]
    5490:	b90093e0 	str	w0, [sp, #144]
    5494:	4b180020 	sub	w0, w1, w24
    5498:	b9009fe0 	str	w0, [sp, #156]
    549c:	b94093e0 	ldr	w0, [sp, #144]
    54a0:	11003d01 	add	w1, w8, #0xf
    54a4:	321f0129 	orr	w9, w9, #0x2
    54a8:	12001c21 	and	w1, w1, #0xff
    54ac:	51000400 	sub	w0, w0, #0x1
    54b0:	52800022 	mov	w2, #0x1                   	// #1
    54b4:	b9015be0 	str	w0, [sp, #344]
    54b8:	14000166 	b	5a50 <_vfprintf_r+0x2080>
    54bc:	910603e2 	add	x2, sp, #0x180
    54c0:	aa1503e1 	mov	x1, x21
    54c4:	aa1303e0 	mov	x0, x19
    54c8:	b90093e9 	str	w9, [sp, #144]
    54cc:	b9009beb 	str	w11, [sp, #152]
    54d0:	b900a3e3 	str	w3, [sp, #160]
    54d4:	9400068b 	bl	6f00 <__sprint_r>
    54d8:	35ff6880 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    54dc:	f940cbe0 	ldr	x0, [sp, #400]
    54e0:	aa1603fc 	mov	x28, x22
    54e4:	b94093e9 	ldr	w9, [sp, #144]
    54e8:	b9409beb 	ldr	w11, [sp, #152]
    54ec:	b940a3e3 	ldr	w3, [sp, #160]
    54f0:	17fffa92 	b	3f38 <_vfprintf_r+0x568>
    54f4:	9105c3e0 	add	x0, sp, #0x170
    54f8:	d2800102 	mov	x2, #0x8                   	// #8
    54fc:	52800001 	mov	w1, #0x0                   	// #0
    5500:	b90093e9 	str	w9, [sp, #144]
    5504:	b9009be8 	str	w8, [sp, #152]
    5508:	b900a3eb 	str	w11, [sp, #160]
    550c:	b900cbe7 	str	w7, [sp, #200]
    5510:	f900bff8 	str	x24, [sp, #376]
    5514:	9400157b 	bl	ab00 <memset>
    5518:	b940cbe7 	ldr	w7, [sp, #200]
    551c:	b94093e9 	ldr	w9, [sp, #144]
    5520:	b9409be8 	ldr	w8, [sp, #152]
    5524:	b940a3eb 	ldr	w11, [sp, #160]
    5528:	310004ff 	cmn	w7, #0x1
    552c:	54005ec0 	b.eq	6104 <_vfprintf_r+0x2734>  // b.none
    5530:	aa1903e0 	mov	x0, x25
    5534:	5280001b 	mov	w27, #0x0                   	// #0
    5538:	aa1503f9 	mov	x25, x21
    553c:	2a0703fa 	mov	w26, w7
    5540:	2a1b03f5 	mov	w21, w27
    5544:	d2800017 	mov	x23, #0x0                   	// #0
    5548:	aa0003fb 	mov	x27, x0
    554c:	b90093e9 	str	w9, [sp, #144]
    5550:	b9009be8 	str	w8, [sp, #152]
    5554:	b900a3eb 	str	w11, [sp, #160]
    5558:	1400000d 	b	558c <_vfprintf_r+0x1bbc>
    555c:	9105c3e3 	add	x3, sp, #0x170
    5560:	910663e1 	add	x1, sp, #0x198
    5564:	aa1303e0 	mov	x0, x19
    5568:	94000fd2 	bl	94b0 <_wcrtomb_r>
    556c:	3100041f 	cmn	w0, #0x1
    5570:	54008ee0 	b.eq	674c <_vfprintf_r+0x2d7c>  // b.none
    5574:	0b0002a0 	add	w0, w21, w0
    5578:	6b1a001f 	cmp	w0, w26
    557c:	540000ec 	b.gt	5598 <_vfprintf_r+0x1bc8>
    5580:	910012f7 	add	x23, x23, #0x4
    5584:	5400a1a0 	b.eq	69b8 <_vfprintf_r+0x2fe8>  // b.none
    5588:	2a0003f5 	mov	w21, w0
    558c:	f940bfe0 	ldr	x0, [sp, #376]
    5590:	b8776802 	ldr	w2, [x0, x23]
    5594:	35fffe42 	cbnz	w2, 555c <_vfprintf_r+0x1b8c>
    5598:	aa1b03e0 	mov	x0, x27
    559c:	b94093e9 	ldr	w9, [sp, #144]
    55a0:	b9409be8 	ldr	w8, [sp, #152]
    55a4:	2a1503fb 	mov	w27, w21
    55a8:	b940a3eb 	ldr	w11, [sp, #160]
    55ac:	aa1903f5 	mov	x21, x25
    55b0:	aa0003f9 	mov	x25, x0
    55b4:	3400677b 	cbz	w27, 62a0 <_vfprintf_r+0x28d0>
    55b8:	71018f7f 	cmp	w27, #0x63
    55bc:	54007ead 	b.le	6590 <_vfprintf_r+0x2bc0>
    55c0:	11000761 	add	w1, w27, #0x1
    55c4:	aa1303e0 	mov	x0, x19
    55c8:	b90093e9 	str	w9, [sp, #144]
    55cc:	93407c21 	sxtw	x1, w1
    55d0:	b9009be8 	str	w8, [sp, #152]
    55d4:	b900a3eb 	str	w11, [sp, #160]
    55d8:	94000da2 	bl	8c60 <_malloc_r>
    55dc:	b94093e9 	ldr	w9, [sp, #144]
    55e0:	aa0003f8 	mov	x24, x0
    55e4:	b9409be8 	ldr	w8, [sp, #152]
    55e8:	b940a3eb 	ldr	w11, [sp, #160]
    55ec:	b400aba0 	cbz	x0, 6b60 <_vfprintf_r+0x3190>
    55f0:	aa0003f7 	mov	x23, x0
    55f4:	93407f7a 	sxtw	x26, w27
    55f8:	d2800102 	mov	x2, #0x8                   	// #8
    55fc:	52800001 	mov	w1, #0x0                   	// #0
    5600:	9105c3e0 	add	x0, sp, #0x170
    5604:	b90093e9 	str	w9, [sp, #144]
    5608:	b9009be8 	str	w8, [sp, #152]
    560c:	b900a3eb 	str	w11, [sp, #160]
    5610:	9400153c 	bl	ab00 <memset>
    5614:	9105c3e4 	add	x4, sp, #0x170
    5618:	aa1a03e3 	mov	x3, x26
    561c:	9105e3e2 	add	x2, sp, #0x178
    5620:	aa1803e1 	mov	x1, x24
    5624:	aa1303e0 	mov	x0, x19
    5628:	940015b6 	bl	ad00 <_wcsrtombs_r>
    562c:	b94093e9 	ldr	w9, [sp, #144]
    5630:	eb00035f 	cmp	x26, x0
    5634:	b9409be8 	ldr	w8, [sp, #152]
    5638:	b940a3eb 	ldr	w11, [sp, #160]
    563c:	5400b4c1 	b.ne	6cd4 <_vfprintf_r+0x3304>  // b.any
    5640:	383bcb1f 	strb	wzr, [x24, w27, sxtw]
    5644:	7100037f 	cmp	w27, #0x0
    5648:	b90093ff 	str	wzr, [sp, #144]
    564c:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
    5650:	39453fe1 	ldrb	w1, [sp, #335]
    5654:	52800007 	mov	w7, #0x0                   	// #0
    5658:	b9009bff 	str	wzr, [sp, #152]
    565c:	b900a3ff 	str	wzr, [sp, #160]
    5660:	34ff31c1 	cbz	w1, 3c98 <_vfprintf_r+0x2c8>
    5664:	17fffbd9 	b	45c8 <_vfprintf_r+0xbf8>
    5668:	b94093e9 	ldr	w9, [sp, #144]
    566c:	2a1a03e3 	mov	w3, w26
    5670:	b9409beb 	ldr	w11, [sp, #152]
    5674:	aa1903e4 	mov	x4, x25
    5678:	2a1803fa 	mov	w26, w24
    567c:	aa1c03f9 	mov	x25, x28
    5680:	aa0203fc 	mov	x28, x2
    5684:	93407f5a 	sxtw	x26, w26
    5688:	11000421 	add	w1, w1, #0x1
    568c:	8b1a0000 	add	x0, x0, x26
    5690:	b9018be1 	str	w1, [sp, #392]
    5694:	f900cbe0 	str	x0, [sp, #400]
    5698:	a9006b84 	stp	x4, x26, [x28]
    569c:	71001c3f 	cmp	w1, #0x7
    56a0:	54ff580c 	b.gt	41a0 <_vfprintf_r+0x7d0>
    56a4:	9100439c 	add	x28, x28, #0x10
    56a8:	17fff9b0 	b	3d68 <_vfprintf_r+0x398>
    56ac:	12160343 	and	w3, w26, #0x400
    56b0:	9107f3ec 	add	x12, sp, #0x1fc
    56b4:	b202e7fb 	mov	x27, #0xcccccccccccccccc    	// #-3689348814741910324
    56b8:	aa1903e4 	mov	x4, x25
    56bc:	aa0c03e2 	mov	x2, x12
    56c0:	aa1303f9 	mov	x25, x19
    56c4:	52800005 	mov	w5, #0x0                   	// #0
    56c8:	2a0303f3 	mov	w19, w3
    56cc:	f29999bb 	movk	x27, #0xcccd
    56d0:	aa1503e3 	mov	x3, x21
    56d4:	f9407ff5 	ldr	x21, [sp, #248]
    56d8:	14000007 	b	56f4 <_vfprintf_r+0x1d24>
    56dc:	9bdb7c17 	umulh	x23, x0, x27
    56e0:	d343fef7 	lsr	x23, x23, #3
    56e4:	f100241f 	cmp	x0, #0x9
    56e8:	54000249 	b.ls	5730 <_vfprintf_r+0x1d60>  // b.plast
    56ec:	aa1703e0 	mov	x0, x23
    56f0:	aa1803e2 	mov	x2, x24
    56f4:	9bdb7c17 	umulh	x23, x0, x27
    56f8:	110004a5 	add	w5, w5, #0x1
    56fc:	d1000458 	sub	x24, x2, #0x1
    5700:	d343fef7 	lsr	x23, x23, #3
    5704:	8b170ae1 	add	x1, x23, x23, lsl #2
    5708:	cb010401 	sub	x1, x0, x1, lsl #1
    570c:	1100c021 	add	w1, w1, #0x30
    5710:	381ff041 	sturb	w1, [x2, #-1]
    5714:	34fffe53 	cbz	w19, 56dc <_vfprintf_r+0x1d0c>
    5718:	394002a1 	ldrb	w1, [x21]
    571c:	7103fc3f 	cmp	w1, #0xff
    5720:	7a451020 	ccmp	w1, w5, #0x0, ne	// ne = any
    5724:	54fffdc1 	b.ne	56dc <_vfprintf_r+0x1d0c>  // b.any
    5728:	f100241f 	cmp	x0, #0x9
    572c:	54006668 	b.hi	63f8 <_vfprintf_r+0x2a28>  // b.pmore
    5730:	aa1903f3 	mov	x19, x25
    5734:	aa0403f9 	mov	x25, x4
    5738:	b9009fe5 	str	w5, [sp, #156]
    573c:	f9007ff5 	str	x21, [sp, #248]
    5740:	aa0303f5 	mov	x21, x3
    5744:	17fffcf0 	b	4b04 <_vfprintf_r+0x1134>
    5748:	710018ff 	cmp	w7, #0x6
    574c:	528000c3 	mov	w3, #0x6                   	// #6
    5750:	1a8390e3 	csel	w3, w7, w3, ls	// ls = plast
    5754:	f0000045 	adrp	x5, 10000 <__env_lock>
    5758:	2a0303fb 	mov	w27, w3
    575c:	912200b8 	add	x24, x5, #0x880
    5760:	d2800017 	mov	x23, #0x0                   	// #0
    5764:	52800001 	mov	w1, #0x0                   	// #0
    5768:	52800007 	mov	w7, #0x0                   	// #0
    576c:	b90093ff 	str	wzr, [sp, #144]
    5770:	b9009bff 	str	wzr, [sp, #152]
    5774:	b900a3ff 	str	wzr, [sp, #160]
    5778:	17fff948 	b	3c98 <_vfprintf_r+0x2c8>
    577c:	b9407fe0 	ldr	w0, [sp, #124]
    5780:	11002001 	add	w1, w0, #0x8
    5784:	7100003f 	cmp	w1, #0x0
    5788:	540027ad 	b.le	5c7c <_vfprintf_r+0x22ac>
    578c:	f94043e0 	ldr	x0, [sp, #128]
    5790:	b9007fe1 	str	w1, [sp, #124]
    5794:	91003c02 	add	x2, x0, #0xf
    5798:	927df041 	and	x1, x2, #0xfffffffffffffff8
    579c:	f90043e1 	str	x1, [sp, #128]
    57a0:	17fffcac 	b	4a50 <_vfprintf_r+0x1080>
    57a4:	f940cbe0 	ldr	x0, [sp, #400]
    57a8:	b5002b00 	cbnz	x0, 5d08 <_vfprintf_r+0x2338>
    57ac:	79c022a0 	ldrsh	w0, [x21, #16]
    57b0:	b9018bff 	str	wzr, [sp, #392]
    57b4:	17fffa92 	b	41fc <_vfprintf_r+0x82c>
    57b8:	f0000044 	adrp	x4, 10000 <__env_lock>
    57bc:	b9418be1 	ldr	w1, [sp, #392]
    57c0:	91254084 	add	x4, x4, #0x950
    57c4:	7100437f 	cmp	w27, #0x10
    57c8:	54001d6d 	b.le	5b74 <_vfprintf_r+0x21a4>
    57cc:	2a1b03e5 	mov	w5, w27
    57d0:	aa1c03e2 	mov	x2, x28
    57d4:	aa1703fb 	mov	x27, x23
    57d8:	aa1903fc 	mov	x28, x25
    57dc:	2a0903fa 	mov	w26, w9
    57e0:	2a0303f9 	mov	w25, w3
    57e4:	2a0503f7 	mov	w23, w5
    57e8:	d2800208 	mov	x8, #0x10                  	// #16
    57ec:	f9006bf8 	str	x24, [sp, #208]
    57f0:	aa0403f8 	mov	x24, x4
    57f4:	b900dbeb 	str	w11, [sp, #216]
    57f8:	14000004 	b	5808 <_vfprintf_r+0x1e38>
    57fc:	510042f7 	sub	w23, w23, #0x10
    5800:	710042ff 	cmp	w23, #0x10
    5804:	54001a4d 	b.le	5b4c <_vfprintf_r+0x217c>
    5808:	91004000 	add	x0, x0, #0x10
    580c:	11000421 	add	w1, w1, #0x1
    5810:	a9002058 	stp	x24, x8, [x2]
    5814:	91004042 	add	x2, x2, #0x10
    5818:	b9018be1 	str	w1, [sp, #392]
    581c:	f900cbe0 	str	x0, [sp, #400]
    5820:	71001c3f 	cmp	w1, #0x7
    5824:	54fffecd 	b.le	57fc <_vfprintf_r+0x1e2c>
    5828:	910603e2 	add	x2, sp, #0x180
    582c:	aa1503e1 	mov	x1, x21
    5830:	aa1303e0 	mov	x0, x19
    5834:	940005b3 	bl	6f00 <__sprint_r>
    5838:	35007840 	cbnz	w0, 6740 <_vfprintf_r+0x2d70>
    583c:	f940cbe0 	ldr	x0, [sp, #400]
    5840:	aa1603e2 	mov	x2, x22
    5844:	b9418be1 	ldr	w1, [sp, #392]
    5848:	d2800208 	mov	x8, #0x10                  	// #16
    584c:	17ffffec 	b	57fc <_vfprintf_r+0x1e2c>
    5850:	36482309 	tbz	w9, #9, 5cb0 <_vfprintf_r+0x22e0>
    5854:	37f887c0 	tbnz	w0, #31, 694c <_vfprintf_r+0x2f7c>
    5858:	f94043e0 	ldr	x0, [sp, #128]
    585c:	91002c01 	add	x1, x0, #0xb
    5860:	927df021 	and	x1, x1, #0xfffffffffffffff8
    5864:	39400000 	ldrb	w0, [x0]
    5868:	f90043e1 	str	x1, [sp, #128]
    586c:	17fffe72 	b	5234 <_vfprintf_r+0x1864>
    5870:	f94057e2 	ldr	x2, [sp, #168]
    5874:	b9407fe0 	ldr	w0, [sp, #124]
    5878:	b9007fe1 	str	w1, [sp, #124]
    587c:	8b20c040 	add	x0, x2, w0, sxtw
    5880:	17fffc1f 	b	48fc <_vfprintf_r+0xf2c>
    5884:	b9407fe0 	ldr	w0, [sp, #124]
    5888:	11002001 	add	w1, w0, #0x8
    588c:	7100003f 	cmp	w1, #0x0
    5890:	540026ad 	b.le	5d64 <_vfprintf_r+0x2394>
    5894:	f94043e0 	ldr	x0, [sp, #128]
    5898:	b9007fe1 	str	w1, [sp, #124]
    589c:	91002c02 	add	x2, x0, #0xb
    58a0:	927df041 	and	x1, x2, #0xfffffffffffffff8
    58a4:	f90043e1 	str	x1, [sp, #128]
    58a8:	17fffe4b 	b	51d4 <_vfprintf_r+0x1804>
    58ac:	36482109 	tbz	w9, #9, 5ccc <_vfprintf_r+0x22fc>
    58b0:	37f87ce0 	tbnz	w0, #31, 684c <_vfprintf_r+0x2e7c>
    58b4:	f94043e0 	ldr	x0, [sp, #128]
    58b8:	91002c01 	add	x1, x0, #0xb
    58bc:	927df021 	and	x1, x1, #0xfffffffffffffff8
    58c0:	39400000 	ldrb	w0, [x0]
    58c4:	f90043e1 	str	x1, [sp, #128]
    58c8:	17fffc0e 	b	4900 <_vfprintf_r+0xf30>
    58cc:	364820e9 	tbz	w9, #9, 5ce8 <_vfprintf_r+0x2318>
    58d0:	37f88c40 	tbnz	w0, #31, 6a58 <_vfprintf_r+0x3088>
    58d4:	f94043e0 	ldr	x0, [sp, #128]
    58d8:	91002c01 	add	x1, x0, #0xb
    58dc:	927df021 	and	x1, x1, #0xfffffffffffffff8
    58e0:	f90043e1 	str	x1, [sp, #128]
    58e4:	39800000 	ldrsb	x0, [x0]
    58e8:	aa0003e1 	mov	x1, x0
    58ec:	17fffc6a 	b	4a94 <_vfprintf_r+0x10c4>
    58f0:	f94057e2 	ldr	x2, [sp, #168]
    58f4:	b9407fe0 	ldr	w0, [sp, #124]
    58f8:	b9007fe1 	str	w1, [sp, #124]
    58fc:	8b20c040 	add	x0, x2, w0, sxtw
    5900:	17fffe4c 	b	5230 <_vfprintf_r+0x1860>
    5904:	f94057e2 	ldr	x2, [sp, #168]
    5908:	b9407fe0 	ldr	w0, [sp, #124]
    590c:	b9007fe1 	str	w1, [sp, #124]
    5910:	8b20c040 	add	x0, x2, w0, sxtw
    5914:	17fffc5e 	b	4a8c <_vfprintf_r+0x10bc>
    5918:	36481bda 	tbz	w26, #9, 5c90 <_vfprintf_r+0x22c0>
    591c:	37f885c0 	tbnz	w0, #31, 69d4 <_vfprintf_r+0x3004>
    5920:	f94043e0 	ldr	x0, [sp, #128]
    5924:	91002c01 	add	x1, x0, #0xb
    5928:	927df021 	and	x1, x1, #0xfffffffffffffff8
    592c:	f90043e1 	str	x1, [sp, #128]
    5930:	39400000 	ldrb	w0, [x0]
    5934:	52800021 	mov	w1, #0x1                   	// #1
    5938:	17fffbf4 	b	4908 <_vfprintf_r+0xf38>
    593c:	f94057e2 	ldr	x2, [sp, #168]
    5940:	b9407fe0 	ldr	w0, [sp, #124]
    5944:	b9007fe1 	str	w1, [sp, #124]
    5948:	8b20c040 	add	x0, x2, w0, sxtw
    594c:	17fffc16 	b	49a4 <_vfprintf_r+0xfd4>
    5950:	310004ff 	cmn	w7, #0x1
    5954:	54002920 	b.eq	5e78 <_vfprintf_r+0x24a8>  // b.none
    5958:	71011f7f 	cmp	w27, #0x47
    595c:	7a4008e0 	ccmp	w7, #0x0, #0x0, eq	// eq = none
    5960:	1a9f14e7 	csinc	w7, w7, wzr, ne	// ne = any
    5964:	9e660100 	fmov	x0, d8
    5968:	32180137 	orr	w23, w9, #0x100
    596c:	d360fc00 	lsr	x0, x0, #32
    5970:	37f87d00 	tbnz	w0, #31, 6910 <_vfprintf_r+0x2f40>
    5974:	1e604109 	fmov	d9, d8
    5978:	b900cbff 	str	wzr, [sp, #200]
    597c:	71011b7f 	cmp	w27, #0x46
    5980:	54004240 	b.eq	61c8 <_vfprintf_r+0x27f8>  // b.none
    5984:	7101177f 	cmp	w27, #0x45
    5988:	54005c81 	b.ne	6518 <_vfprintf_r+0x2b48>  // b.any
    598c:	1e604120 	fmov	d0, d9
    5990:	110004e0 	add	w0, w7, #0x1
    5994:	2a0003fa 	mov	w26, w0
    5998:	2a0003e2 	mov	w2, w0
    599c:	9105e3e5 	add	x5, sp, #0x178
    59a0:	9105c3e4 	add	x4, sp, #0x170
    59a4:	910563e3 	add	x3, sp, #0x158
    59a8:	aa1303e0 	mov	x0, x19
    59ac:	52800041 	mov	w1, #0x2                   	// #2
    59b0:	b90093e7 	str	w7, [sp, #144]
    59b4:	29136be9 	stp	w9, w26, [sp, #152]
    59b8:	b900a3e8 	str	w8, [sp, #160]
    59bc:	b900d3eb 	str	w11, [sp, #208]
    59c0:	9400154c 	bl	aef0 <_dtoa_r>
    59c4:	1e602128 	fcmp	d9, #0.0
    59c8:	b94093e7 	ldr	w7, [sp, #144]
    59cc:	b9409be9 	ldr	w9, [sp, #152]
    59d0:	aa0003f8 	mov	x24, x0
    59d4:	b940a3e8 	ldr	w8, [sp, #160]
    59d8:	8b3ac002 	add	x2, x0, w26, sxtw
    59dc:	b940d3eb 	ldr	w11, [sp, #208]
    59e0:	540088c0 	b.eq	6af8 <_vfprintf_r+0x3128>  // b.none
    59e4:	f940bfe0 	ldr	x0, [sp, #376]
    59e8:	eb02001f 	cmp	x0, x2
    59ec:	54000122 	b.cs	5a10 <_vfprintf_r+0x2040>  // b.hs, b.nlast
    59f0:	52800603 	mov	w3, #0x30                  	// #48
    59f4:	d503201f 	nop
    59f8:	91000401 	add	x1, x0, #0x1
    59fc:	f900bfe1 	str	x1, [sp, #376]
    5a00:	39000003 	strb	w3, [x0]
    5a04:	f940bfe0 	ldr	x0, [sp, #376]
    5a08:	eb02001f 	cmp	x0, x2
    5a0c:	54ffff63 	b.cc	59f8 <_vfprintf_r+0x2028>  // b.lo, b.ul, b.last
    5a10:	b9415be1 	ldr	w1, [sp, #344]
    5a14:	cb180000 	sub	x0, x0, x24
    5a18:	b90093e1 	str	w1, [sp, #144]
    5a1c:	b9009fe0 	str	w0, [sp, #156]
    5a20:	71011f7f 	cmp	w27, #0x47
    5a24:	54009521 	b.ne	6cc8 <_vfprintf_r+0x32f8>  // b.any
    5a28:	b94093e1 	ldr	w1, [sp, #144]
    5a2c:	6b07003f 	cmp	w1, w7
    5a30:	3a43d821 	ccmn	w1, #0x3, #0x1, le
    5a34:	540038aa 	b.ge	6148 <_vfprintf_r+0x2778>  // b.tcont
    5a38:	51000908 	sub	w8, w8, #0x2
    5a3c:	51000420 	sub	w0, w1, #0x1
    5a40:	12001d01 	and	w1, w8, #0xff
    5a44:	52800002 	mov	w2, #0x0                   	// #0
    5a48:	d2800017 	mov	x23, #0x0                   	// #0
    5a4c:	b9015be0 	str	w0, [sp, #344]
    5a50:	390583e1 	strb	w1, [sp, #352]
    5a54:	52800561 	mov	w1, #0x2b                  	// #43
    5a58:	36f800a0 	tbz	w0, #31, 5a6c <_vfprintf_r+0x209c>
    5a5c:	b94093e1 	ldr	w1, [sp, #144]
    5a60:	52800020 	mov	w0, #0x1                   	// #1
    5a64:	4b010000 	sub	w0, w0, w1
    5a68:	528005a1 	mov	w1, #0x2d                  	// #45
    5a6c:	390587e1 	strb	w1, [sp, #353]
    5a70:	7100241f 	cmp	w0, #0x9
    5a74:	54005b2d 	b.le	65d8 <_vfprintf_r+0x2c08>
    5a78:	9105ffec 	add	x12, sp, #0x17f
    5a7c:	529999ad 	mov	w13, #0xcccd                	// #52429
    5a80:	aa0c03e4 	mov	x4, x12
    5a84:	72b9998d 	movk	w13, #0xcccc, lsl #16
    5a88:	9bad7c02 	umull	x2, w0, w13
    5a8c:	aa0403e3 	mov	x3, x4
    5a90:	2a0003e5 	mov	w5, w0
    5a94:	d1000484 	sub	x4, x4, #0x1
    5a98:	d363fc42 	lsr	x2, x2, #35
    5a9c:	0b020841 	add	w1, w2, w2, lsl #2
    5aa0:	4b010401 	sub	w1, w0, w1, lsl #1
    5aa4:	2a0203e0 	mov	w0, w2
    5aa8:	1100c021 	add	w1, w1, #0x30
    5aac:	381ff061 	sturb	w1, [x3, #-1]
    5ab0:	71018cbf 	cmp	w5, #0x63
    5ab4:	54fffeac 	b.gt	5a88 <_vfprintf_r+0x20b8>
    5ab8:	1100c040 	add	w0, w2, #0x30
    5abc:	381ff080 	sturb	w0, [x4, #-1]
    5ac0:	d1000860 	sub	x0, x3, #0x2
    5ac4:	eb0c001f 	cmp	x0, x12
    5ac8:	54008da2 	b.cs	6c7c <_vfprintf_r+0x32ac>  // b.hs, b.nlast
    5acc:	91058be1 	add	x1, sp, #0x162
    5ad0:	38401402 	ldrb	w2, [x0], #1
    5ad4:	38001422 	strb	w2, [x1], #1
    5ad8:	eb0c001f 	cmp	x0, x12
    5adc:	54ffffa1 	b.ne	5ad0 <_vfprintf_r+0x2100>  // b.any
    5ae0:	910607e0 	add	x0, sp, #0x181
    5ae4:	91058be2 	add	x2, sp, #0x162
    5ae8:	cb030000 	sub	x0, x0, x3
    5aec:	910583e1 	add	x1, sp, #0x160
    5af0:	8b000040 	add	x0, x2, x0
    5af4:	4b010000 	sub	w0, w0, w1
    5af8:	b900ebe0 	str	w0, [sp, #232]
    5afc:	b9409fe0 	ldr	w0, [sp, #156]
    5b00:	b940ebe1 	ldr	w1, [sp, #232]
    5b04:	0b00003b 	add	w27, w1, w0
    5b08:	7100041f 	cmp	w0, #0x1
    5b0c:	5400606d 	b.le	6718 <_vfprintf_r+0x2d48>
    5b10:	b940b3e0 	ldr	w0, [sp, #176]
    5b14:	0b00037b 	add	w27, w27, w0
    5b18:	1215792a 	and	w10, w9, #0xfffffbff
    5b1c:	7100037f 	cmp	w27, #0x0
    5b20:	32180149 	orr	w9, w10, #0x100
    5b24:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
    5b28:	b90093ff 	str	wzr, [sp, #144]
    5b2c:	b9009bff 	str	wzr, [sp, #152]
    5b30:	b900a3ff 	str	wzr, [sp, #160]
    5b34:	b940cbe0 	ldr	w0, [sp, #200]
    5b38:	35001a40 	cbnz	w0, 5e80 <_vfprintf_r+0x24b0>
    5b3c:	39453fe1 	ldrb	w1, [sp, #335]
    5b40:	52800007 	mov	w7, #0x0                   	// #0
    5b44:	34ff0aa1 	cbz	w1, 3c98 <_vfprintf_r+0x2c8>
    5b48:	17fffaa0 	b	45c8 <_vfprintf_r+0xbf8>
    5b4c:	2a1703e5 	mov	w5, w23
    5b50:	aa1803e4 	mov	x4, x24
    5b54:	f9406bf8 	ldr	x24, [sp, #208]
    5b58:	2a1903e3 	mov	w3, w25
    5b5c:	b940dbeb 	ldr	w11, [sp, #216]
    5b60:	aa1b03f7 	mov	x23, x27
    5b64:	aa1c03f9 	mov	x25, x28
    5b68:	2a1a03e9 	mov	w9, w26
    5b6c:	aa0203fc 	mov	x28, x2
    5b70:	2a0503fb 	mov	w27, w5
    5b74:	93407f67 	sxtw	x7, w27
    5b78:	11000421 	add	w1, w1, #0x1
    5b7c:	8b070000 	add	x0, x0, x7
    5b80:	a9001f84 	stp	x4, x7, [x28]
    5b84:	9100439c 	add	x28, x28, #0x10
    5b88:	b9018be1 	str	w1, [sp, #392]
    5b8c:	f900cbe0 	str	x0, [sp, #400]
    5b90:	71001c3f 	cmp	w1, #0x7
    5b94:	54ff8c0d 	b.le	4d14 <_vfprintf_r+0x1344>
    5b98:	910603e2 	add	x2, sp, #0x180
    5b9c:	aa1503e1 	mov	x1, x21
    5ba0:	aa1303e0 	mov	x0, x19
    5ba4:	b900d3e9 	str	w9, [sp, #208]
    5ba8:	b900dbeb 	str	w11, [sp, #216]
    5bac:	b900e3e3 	str	w3, [sp, #224]
    5bb0:	940004d4 	bl	6f00 <__sprint_r>
    5bb4:	35ff31a0 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    5bb8:	f940cbe0 	ldr	x0, [sp, #400]
    5bbc:	aa1603fc 	mov	x28, x22
    5bc0:	b940d3e9 	ldr	w9, [sp, #208]
    5bc4:	b940dbeb 	ldr	w11, [sp, #216]
    5bc8:	b940e3e3 	ldr	w3, [sp, #224]
    5bcc:	17fffc52 	b	4d14 <_vfprintf_r+0x1344>
    5bd0:	36070cc9 	tbz	w9, #0, 3d68 <_vfprintf_r+0x398>
    5bd4:	a94b13e2 	ldp	x2, x4, [sp, #176]
    5bd8:	a9000b84 	stp	x4, x2, [x28]
    5bdc:	b9418be1 	ldr	w1, [sp, #392]
    5be0:	91004386 	add	x6, x28, #0x10
    5be4:	11000421 	add	w1, w1, #0x1
    5be8:	b9018be1 	str	w1, [sp, #392]
    5bec:	8b000040 	add	x0, x2, x0
    5bf0:	f900cbe0 	str	x0, [sp, #400]
    5bf4:	71001c3f 	cmp	w1, #0x7
    5bf8:	54ff2c0d 	b.le	4178 <_vfprintf_r+0x7a8>
    5bfc:	910603e2 	add	x2, sp, #0x180
    5c00:	aa1503e1 	mov	x1, x21
    5c04:	aa1303e0 	mov	x0, x19
    5c08:	b90093e9 	str	w9, [sp, #144]
    5c0c:	b9009beb 	str	w11, [sp, #152]
    5c10:	b900a3e3 	str	w3, [sp, #160]
    5c14:	940004bb 	bl	6f00 <__sprint_r>
    5c18:	35ff2e80 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    5c1c:	f940cbe0 	ldr	x0, [sp, #400]
    5c20:	aa1603e6 	mov	x6, x22
    5c24:	b94093e9 	ldr	w9, [sp, #144]
    5c28:	b9409beb 	ldr	w11, [sp, #152]
    5c2c:	b940a3e3 	ldr	w3, [sp, #160]
    5c30:	b9415be2 	ldr	w2, [sp, #344]
    5c34:	b9418be1 	ldr	w1, [sp, #392]
    5c38:	17fff94f 	b	4174 <_vfprintf_r+0x7a4>
    5c3c:	b9409fe1 	ldr	w1, [sp, #156]
    5c40:	4b1a003a 	sub	w26, w1, w26
    5c44:	f94067e1 	ldr	x1, [sp, #200]
    5c48:	cb18003b 	sub	x27, x1, x24
    5c4c:	6b1b035f 	cmp	w26, w27
    5c50:	1a9bb35b 	csel	w27, w26, w27, lt	// lt = tstop
    5c54:	17fffc54 	b	4da4 <_vfprintf_r+0x13d4>
    5c58:	37f86e60 	tbnz	w0, #31, 6a24 <_vfprintf_r+0x3054>
    5c5c:	f94043e0 	ldr	x0, [sp, #128]
    5c60:	91003c01 	add	x1, x0, #0xf
    5c64:	927df021 	and	x1, x1, #0xfffffffffffffff8
    5c68:	f90043e1 	str	x1, [sp, #128]
    5c6c:	f9400000 	ldr	x0, [x0]
    5c70:	7940e3e1 	ldrh	w1, [sp, #112]
    5c74:	79000001 	strh	w1, [x0]
    5c78:	17fff79d 	b	3aec <_vfprintf_r+0x11c>
    5c7c:	f94057e2 	ldr	x2, [sp, #168]
    5c80:	b9407fe0 	ldr	w0, [sp, #124]
    5c84:	b9007fe1 	str	w1, [sp, #124]
    5c88:	8b20c040 	add	x0, x2, w0, sxtw
    5c8c:	17fffb71 	b	4a50 <_vfprintf_r+0x1080>
    5c90:	37f85960 	tbnz	w0, #31, 67bc <_vfprintf_r+0x2dec>
    5c94:	f94043e0 	ldr	x0, [sp, #128]
    5c98:	91002c01 	add	x1, x0, #0xb
    5c9c:	927df021 	and	x1, x1, #0xfffffffffffffff8
    5ca0:	f90043e1 	str	x1, [sp, #128]
    5ca4:	b9400000 	ldr	w0, [x0]
    5ca8:	52800021 	mov	w1, #0x1                   	// #1
    5cac:	17fffb17 	b	4908 <_vfprintf_r+0xf38>
    5cb0:	37f86380 	tbnz	w0, #31, 6920 <_vfprintf_r+0x2f50>
    5cb4:	f94043e0 	ldr	x0, [sp, #128]
    5cb8:	91002c01 	add	x1, x0, #0xb
    5cbc:	927df021 	and	x1, x1, #0xfffffffffffffff8
    5cc0:	b9400000 	ldr	w0, [x0]
    5cc4:	f90043e1 	str	x1, [sp, #128]
    5cc8:	17fffd5b 	b	5234 <_vfprintf_r+0x1864>
    5ccc:	37f859e0 	tbnz	w0, #31, 6808 <_vfprintf_r+0x2e38>
    5cd0:	f94043e0 	ldr	x0, [sp, #128]
    5cd4:	91002c01 	add	x1, x0, #0xb
    5cd8:	927df021 	and	x1, x1, #0xfffffffffffffff8
    5cdc:	b9400000 	ldr	w0, [x0]
    5ce0:	f90043e1 	str	x1, [sp, #128]
    5ce4:	17fffb07 	b	4900 <_vfprintf_r+0xf30>
    5ce8:	37f868a0 	tbnz	w0, #31, 69fc <_vfprintf_r+0x302c>
    5cec:	f94043e0 	ldr	x0, [sp, #128]
    5cf0:	91002c01 	add	x1, x0, #0xb
    5cf4:	927df021 	and	x1, x1, #0xfffffffffffffff8
    5cf8:	f90043e1 	str	x1, [sp, #128]
    5cfc:	b9800000 	ldrsw	x0, [x0]
    5d00:	aa0003e1 	mov	x1, x0
    5d04:	17fffb64 	b	4a94 <_vfprintf_r+0x10c4>
    5d08:	aa1303e0 	mov	x0, x19
    5d0c:	910603e2 	add	x2, sp, #0x180
    5d10:	aa1503e1 	mov	x1, x21
    5d14:	9400047b 	bl	6f00 <__sprint_r>
    5d18:	34ffd4a0 	cbz	w0, 57ac <_vfprintf_r+0x1ddc>
    5d1c:	17fff937 	b	41f8 <_vfprintf_r+0x828>
    5d20:	aa1803e0 	mov	x0, x24
    5d24:	b900cbe9 	str	w9, [sp, #200]
    5d28:	b900d3eb 	str	w11, [sp, #208]
    5d2c:	97fff325 	bl	29c0 <strlen>
    5d30:	39453fe1 	ldrb	w1, [sp, #335]
    5d34:	7100001f 	cmp	w0, #0x0
    5d38:	b9009bff 	str	wzr, [sp, #152]
    5d3c:	2a0003fb 	mov	w27, w0
    5d40:	b900a3ff 	str	wzr, [sp, #160]
    5d44:	1a9fa003 	csel	w3, w0, wzr, ge	// ge = tcont
    5d48:	b940cbe9 	ldr	w9, [sp, #200]
    5d4c:	d2800017 	mov	x23, #0x0                   	// #0
    5d50:	b940d3eb 	ldr	w11, [sp, #208]
    5d54:	52800007 	mov	w7, #0x0                   	// #0
    5d58:	52800e68 	mov	w8, #0x73                  	// #115
    5d5c:	34fef9e1 	cbz	w1, 3c98 <_vfprintf_r+0x2c8>
    5d60:	17fffa1a 	b	45c8 <_vfprintf_r+0xbf8>
    5d64:	f94057e2 	ldr	x2, [sp, #168]
    5d68:	b9407fe0 	ldr	w0, [sp, #124]
    5d6c:	b9007fe1 	str	w1, [sp, #124]
    5d70:	8b20c040 	add	x0, x2, w0, sxtw
    5d74:	17fffd18 	b	51d4 <_vfprintf_r+0x1804>
    5d78:	b9407fe0 	ldr	w0, [sp, #124]
    5d7c:	11002001 	add	w1, w0, #0x8
    5d80:	7100003f 	cmp	w1, #0x0
    5d84:	54005fad 	b.le	6978 <_vfprintf_r+0x2fa8>
    5d88:	f94043e0 	ldr	x0, [sp, #128]
    5d8c:	b9007fe1 	str	w1, [sp, #124]
    5d90:	91002c02 	add	x2, x0, #0xb
    5d94:	927df041 	and	x1, x2, #0xfffffffffffffff8
    5d98:	79400000 	ldrh	w0, [x0]
    5d9c:	f90043e1 	str	x1, [sp, #128]
    5da0:	17fffad8 	b	4900 <_vfprintf_r+0xf30>
    5da4:	b9407fe0 	ldr	w0, [sp, #124]
    5da8:	11002001 	add	w1, w0, #0x8
    5dac:	7100003f 	cmp	w1, #0x0
    5db0:	54004fcd 	b.le	67a8 <_vfprintf_r+0x2dd8>
    5db4:	f94043e0 	ldr	x0, [sp, #128]
    5db8:	b9007fe1 	str	w1, [sp, #124]
    5dbc:	91002c02 	add	x2, x0, #0xb
    5dc0:	927df041 	and	x1, x2, #0xfffffffffffffff8
    5dc4:	f90043e1 	str	x1, [sp, #128]
    5dc8:	17fffc60 	b	4f48 <_vfprintf_r+0x1578>
    5dcc:	b9407fe0 	ldr	w0, [sp, #124]
    5dd0:	11002001 	add	w1, w0, #0x8
    5dd4:	7100003f 	cmp	w1, #0x0
    5dd8:	540052ed 	b.le	6834 <_vfprintf_r+0x2e64>
    5ddc:	f94043e0 	ldr	x0, [sp, #128]
    5de0:	b9007fe1 	str	w1, [sp, #124]
    5de4:	91002c02 	add	x2, x0, #0xb
    5de8:	927df041 	and	x1, x2, #0xfffffffffffffff8
    5dec:	79400000 	ldrh	w0, [x0]
    5df0:	f90043e1 	str	x1, [sp, #128]
    5df4:	17fffd10 	b	5234 <_vfprintf_r+0x1864>
    5df8:	b9407fe0 	ldr	w0, [sp, #124]
    5dfc:	11002001 	add	w1, w0, #0x8
    5e00:	7100003f 	cmp	w1, #0x0
    5e04:	54005c6d 	b.le	6990 <_vfprintf_r+0x2fc0>
    5e08:	f94043e0 	ldr	x0, [sp, #128]
    5e0c:	b9007fe1 	str	w1, [sp, #124]
    5e10:	91002c02 	add	x2, x0, #0xb
    5e14:	927df041 	and	x1, x2, #0xfffffffffffffff8
    5e18:	f90043e1 	str	x1, [sp, #128]
    5e1c:	17fffc42 	b	4f24 <_vfprintf_r+0x1554>
    5e20:	52800020 	mov	w0, #0x1                   	// #1
    5e24:	b9015be0 	str	w0, [sp, #344]
    5e28:	17fffd74 	b	53f8 <_vfprintf_r+0x1a28>
    5e2c:	f94052a0 	ldr	x0, [x21, #160]
    5e30:	f9003be9 	str	x9, [sp, #112]
    5e34:	94000e0f 	bl	9670 <__retarget_lock_release_recursive>
    5e38:	f9403be9 	ldr	x9, [sp, #112]
    5e3c:	17fff74e 	b	3b74 <_vfprintf_r+0x1a4>
    5e40:	110004e1 	add	w1, w7, #0x1
    5e44:	aa1303e0 	mov	x0, x19
    5e48:	b90093e7 	str	w7, [sp, #144]
    5e4c:	93407c21 	sxtw	x1, w1
    5e50:	291323e9 	stp	w9, w8, [sp, #152]
    5e54:	b900a3eb 	str	w11, [sp, #160]
    5e58:	94000b82 	bl	8c60 <_malloc_r>
    5e5c:	b94093e7 	ldr	w7, [sp, #144]
    5e60:	aa0003f8 	mov	x24, x0
    5e64:	295323e9 	ldp	w9, w8, [sp, #152]
    5e68:	b940a3eb 	ldr	w11, [sp, #160]
    5e6c:	b40067a0 	cbz	x0, 6b60 <_vfprintf_r+0x3190>
    5e70:	aa0003f7 	mov	x23, x0
    5e74:	17fffd4d 	b	53a8 <_vfprintf_r+0x19d8>
    5e78:	528000c7 	mov	w7, #0x6                   	// #6
    5e7c:	17fffeba 	b	5964 <_vfprintf_r+0x1f94>
    5e80:	528005a0 	mov	w0, #0x2d                  	// #45
    5e84:	11000463 	add	w3, w3, #0x1
    5e88:	528005a1 	mov	w1, #0x2d                  	// #45
    5e8c:	52800007 	mov	w7, #0x0                   	// #0
    5e90:	39053fe0 	strb	w0, [sp, #335]
    5e94:	17fff781 	b	3c98 <_vfprintf_r+0x2c8>
    5e98:	b940a3e2 	ldr	w2, [sp, #160]
    5e9c:	b9409be1 	ldr	w1, [sp, #152]
    5ea0:	7100005f 	cmp	w2, #0x0
    5ea4:	7a40d820 	ccmp	w1, #0x0, #0x0, le
    5ea8:	540007ad 	b.le	5f9c <_vfprintf_r+0x25cc>
    5eac:	aa1c03e1 	mov	x1, x28
    5eb0:	f9008bf9 	str	x25, [sp, #272]
    5eb4:	f9407ff9 	ldr	x25, [sp, #248]
    5eb8:	f0000044 	adrp	x4, 10000 <__env_lock>
    5ebc:	f94083fc 	ldr	x28, [sp, #256]
    5ec0:	91254084 	add	x4, x4, #0x950
    5ec4:	f9004bf7 	str	x23, [sp, #144]
    5ec8:	2a0203f7 	mov	w23, w2
    5ecc:	d280021b 	mov	x27, #0x10                  	// #16
    5ed0:	b900d3e9 	str	w9, [sp, #208]
    5ed4:	b900dbeb 	str	w11, [sp, #216]
    5ed8:	b900e3e3 	str	w3, [sp, #224]
    5edc:	d503201f 	nop
    5ee0:	34000677 	cbz	w23, 5fac <_vfprintf_r+0x25dc>
    5ee4:	510006f7 	sub	w23, w23, #0x1
    5ee8:	b9418be2 	ldr	w2, [sp, #392]
    5eec:	8b1c0000 	add	x0, x0, x28
    5ef0:	f9407be3 	ldr	x3, [sp, #240]
    5ef4:	11000442 	add	w2, w2, #0x1
    5ef8:	a9007023 	stp	x3, x28, [x1]
    5efc:	91004021 	add	x1, x1, #0x10
    5f00:	b9018be2 	str	w2, [sp, #392]
    5f04:	f900cbe0 	str	x0, [sp, #400]
    5f08:	71001c5f 	cmp	w2, #0x7
    5f0c:	5400098c 	b.gt	603c <_vfprintf_r+0x266c>
    5f10:	f94067e3 	ldr	x3, [sp, #200]
    5f14:	39400322 	ldrb	w2, [x25]
    5f18:	cb180063 	sub	x3, x3, x24
    5f1c:	6b03005f 	cmp	w2, w3
    5f20:	1a83b05a 	csel	w26, w2, w3, lt	// lt = tstop
    5f24:	7100035f 	cmp	w26, #0x0
    5f28:	5400018d 	b.le	5f58 <_vfprintf_r+0x2588>
    5f2c:	b9418be2 	ldr	w2, [sp, #392]
    5f30:	93407f49 	sxtw	x9, w26
    5f34:	8b090000 	add	x0, x0, x9
    5f38:	a9002438 	stp	x24, x9, [x1]
    5f3c:	11000442 	add	w2, w2, #0x1
    5f40:	b9018be2 	str	w2, [sp, #392]
    5f44:	f900cbe0 	str	x0, [sp, #400]
    5f48:	71001c5f 	cmp	w2, #0x7
    5f4c:	54000a8c 	b.gt	609c <_vfprintf_r+0x26cc>
    5f50:	39400322 	ldrb	w2, [x25]
    5f54:	91004021 	add	x1, x1, #0x10
    5f58:	7100035f 	cmp	w26, #0x0
    5f5c:	1a9fa343 	csel	w3, w26, wzr, ge	// ge = tcont
    5f60:	4b03005a 	sub	w26, w2, w3
    5f64:	7100035f 	cmp	w26, #0x0
    5f68:	540002cc 	b.gt	5fc0 <_vfprintf_r+0x25f0>
    5f6c:	b9409be3 	ldr	w3, [sp, #152]
    5f70:	8b220318 	add	x24, x24, w2, uxtb
    5f74:	7100007f 	cmp	w3, #0x0
    5f78:	7a40dae0 	ccmp	w23, #0x0, #0x0, le
    5f7c:	54fffb2c 	b.gt	5ee0 <_vfprintf_r+0x2510>
    5f80:	f9404bf7 	ldr	x23, [sp, #144]
    5f84:	f9007ff9 	str	x25, [sp, #248]
    5f88:	f9408bf9 	ldr	x25, [sp, #272]
    5f8c:	aa0103fc 	mov	x28, x1
    5f90:	b940d3e9 	ldr	w9, [sp, #208]
    5f94:	b940dbeb 	ldr	w11, [sp, #216]
    5f98:	b940e3e3 	ldr	w3, [sp, #224]
    5f9c:	f94067e1 	ldr	x1, [sp, #200]
    5fa0:	eb01031f 	cmp	x24, x1
    5fa4:	9a819318 	csel	x24, x24, x1, ls	// ls = plast
    5fa8:	17fffb5e 	b	4d20 <_vfprintf_r+0x1350>
    5fac:	b9409be2 	ldr	w2, [sp, #152]
    5fb0:	d1000739 	sub	x25, x25, #0x1
    5fb4:	51000442 	sub	w2, w2, #0x1
    5fb8:	b9009be2 	str	w2, [sp, #152]
    5fbc:	17ffffcb 	b	5ee8 <_vfprintf_r+0x2518>
    5fc0:	f0000049 	adrp	x9, 10000 <__env_lock>
    5fc4:	b9418be2 	ldr	w2, [sp, #392]
    5fc8:	91254129 	add	x9, x9, #0x950
    5fcc:	7100435f 	cmp	w26, #0x10
    5fd0:	5400050d 	b.le	6070 <_vfprintf_r+0x26a0>
    5fd4:	b900a3f7 	str	w23, [sp, #160]
    5fd8:	2a1a03f7 	mov	w23, w26
    5fdc:	aa0403fa 	mov	x26, x4
    5fe0:	14000004 	b	5ff0 <_vfprintf_r+0x2620>
    5fe4:	510042f7 	sub	w23, w23, #0x10
    5fe8:	710042ff 	cmp	w23, #0x10
    5fec:	540003cd 	b.le	6064 <_vfprintf_r+0x2694>
    5ff0:	91004000 	add	x0, x0, #0x10
    5ff4:	11000442 	add	w2, w2, #0x1
    5ff8:	a9006c24 	stp	x4, x27, [x1]
    5ffc:	91004021 	add	x1, x1, #0x10
    6000:	b9018be2 	str	w2, [sp, #392]
    6004:	f900cbe0 	str	x0, [sp, #400]
    6008:	71001c5f 	cmp	w2, #0x7
    600c:	54fffecd 	b.le	5fe4 <_vfprintf_r+0x2614>
    6010:	910603e2 	add	x2, sp, #0x180
    6014:	aa1503e1 	mov	x1, x21
    6018:	aa1303e0 	mov	x0, x19
    601c:	940003b9 	bl	6f00 <__sprint_r>
    6020:	35ff0e20 	cbnz	w0, 41e4 <_vfprintf_r+0x814>
    6024:	f940cbe0 	ldr	x0, [sp, #400]
    6028:	d0000043 	adrp	x3, 10000 <__env_lock>
    602c:	b9418be2 	ldr	w2, [sp, #392]
    6030:	aa1603e1 	mov	x1, x22
    6034:	91254064 	add	x4, x3, #0x950
    6038:	17ffffeb 	b	5fe4 <_vfprintf_r+0x2614>
    603c:	910603e2 	add	x2, sp, #0x180
    6040:	aa1503e1 	mov	x1, x21
    6044:	aa1303e0 	mov	x0, x19
    6048:	940003ae 	bl	6f00 <__sprint_r>
    604c:	35ff0cc0 	cbnz	w0, 41e4 <_vfprintf_r+0x814>
    6050:	f940cbe0 	ldr	x0, [sp, #400]
    6054:	d0000042 	adrp	x2, 10000 <__env_lock>
    6058:	aa1603e1 	mov	x1, x22
    605c:	91254044 	add	x4, x2, #0x950
    6060:	17ffffac 	b	5f10 <_vfprintf_r+0x2540>
    6064:	aa1a03e9 	mov	x9, x26
    6068:	2a1703fa 	mov	w26, w23
    606c:	b940a3f7 	ldr	w23, [sp, #160]
    6070:	93407f43 	sxtw	x3, w26
    6074:	11000442 	add	w2, w2, #0x1
    6078:	8b030000 	add	x0, x0, x3
    607c:	a9000c29 	stp	x9, x3, [x1]
    6080:	b9018be2 	str	w2, [sp, #392]
    6084:	f900cbe0 	str	x0, [sp, #400]
    6088:	71001c5f 	cmp	w2, #0x7
    608c:	5400152c 	b.gt	6330 <_vfprintf_r+0x2960>
    6090:	39400322 	ldrb	w2, [x25]
    6094:	91004021 	add	x1, x1, #0x10
    6098:	17ffffb5 	b	5f6c <_vfprintf_r+0x259c>
    609c:	910603e2 	add	x2, sp, #0x180
    60a0:	aa1503e1 	mov	x1, x21
    60a4:	aa1303e0 	mov	x0, x19
    60a8:	94000396 	bl	6f00 <__sprint_r>
    60ac:	35ff09c0 	cbnz	w0, 41e4 <_vfprintf_r+0x814>
    60b0:	f940cbe0 	ldr	x0, [sp, #400]
    60b4:	d0000043 	adrp	x3, 10000 <__env_lock>
    60b8:	39400322 	ldrb	w2, [x25]
    60bc:	aa1603e1 	mov	x1, x22
    60c0:	91254064 	add	x4, x3, #0x950
    60c4:	17ffffa5 	b	5f58 <_vfprintf_r+0x2588>
    60c8:	b940efe0 	ldr	w0, [sp, #236]
    60cc:	11004001 	add	w1, w0, #0x10
    60d0:	7100003f 	cmp	w1, #0x0
    60d4:	54002e6d 	b.le	66a0 <_vfprintf_r+0x2cd0>
    60d8:	f94043e0 	ldr	x0, [sp, #128]
    60dc:	b900efe1 	str	w1, [sp, #236]
    60e0:	91003c02 	add	x2, x0, #0xf
    60e4:	fd400008 	ldr	d8, [x0]
    60e8:	927df041 	and	x1, x2, #0xfffffffffffffff8
    60ec:	f90043e1 	str	x1, [sp, #128]
    60f0:	17fff91f 	b	456c <_vfprintf_r+0xb9c>
    60f4:	528005a0 	mov	w0, #0x2d                  	// #45
    60f8:	528005a1 	mov	w1, #0x2d                  	// #45
    60fc:	39053fe0 	strb	w0, [sp, #335]
    6100:	17fff923 	b	458c <_vfprintf_r+0xbbc>
    6104:	9105c3e4 	add	x4, sp, #0x170
    6108:	9105e3e2 	add	x2, sp, #0x178
    610c:	aa1303e0 	mov	x0, x19
    6110:	d2800003 	mov	x3, #0x0                   	// #0
    6114:	d2800001 	mov	x1, #0x0                   	// #0
    6118:	b90093e9 	str	w9, [sp, #144]
    611c:	b9009be8 	str	w8, [sp, #152]
    6120:	b900a3eb 	str	w11, [sp, #160]
    6124:	940012f7 	bl	ad00 <_wcsrtombs_r>
    6128:	b94093e9 	ldr	w9, [sp, #144]
    612c:	2a0003fb 	mov	w27, w0
    6130:	b9409be8 	ldr	w8, [sp, #152]
    6134:	3100041f 	cmn	w0, #0x1
    6138:	b940a3eb 	ldr	w11, [sp, #160]
    613c:	54005120 	b.eq	6b60 <_vfprintf_r+0x3190>  // b.none
    6140:	f900bff8 	str	x24, [sp, #376]
    6144:	17fffd1c 	b	55b4 <_vfprintf_r+0x1be4>
    6148:	b94093e1 	ldr	w1, [sp, #144]
    614c:	b9409fe2 	ldr	w2, [sp, #156]
    6150:	6b02003f 	cmp	w1, w2
    6154:	540020ab 	b.lt	6568 <_vfprintf_r+0x2b98>  // b.tstop
    6158:	b94093e0 	ldr	w0, [sp, #144]
    615c:	f240013f 	tst	x9, #0x1
    6160:	b940b3e1 	ldr	w1, [sp, #176]
    6164:	0b01000c 	add	w12, w0, w1
    6168:	1a80119b 	csel	w27, w12, w0, ne	// ne = any
    616c:	36500089 	tbz	w9, #10, 617c <_vfprintf_r+0x27ac>
    6170:	b94093e0 	ldr	w0, [sp, #144]
    6174:	7100001f 	cmp	w0, #0x0
    6178:	5400380c 	b.gt	6878 <_vfprintf_r+0x2ea8>
    617c:	7100037f 	cmp	w27, #0x0
    6180:	52800ce8 	mov	w8, #0x67                  	// #103
    6184:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
    6188:	2a1703e9 	mov	w9, w23
    618c:	d2800017 	mov	x23, #0x0                   	// #0
    6190:	b9009bff 	str	wzr, [sp, #152]
    6194:	b900a3ff 	str	wzr, [sp, #160]
    6198:	17fffe67 	b	5b34 <_vfprintf_r+0x2164>
    619c:	b940efe0 	ldr	w0, [sp, #236]
    61a0:	11004001 	add	w1, w0, #0x10
    61a4:	7100003f 	cmp	w1, #0x0
    61a8:	5400272d 	b.le	668c <_vfprintf_r+0x2cbc>
    61ac:	f94043e0 	ldr	x0, [sp, #128]
    61b0:	b900efe1 	str	w1, [sp, #236]
    61b4:	91003c00 	add	x0, x0, #0xf
    61b8:	927cec00 	and	x0, x0, #0xfffffffffffffff0
    61bc:	91004001 	add	x1, x0, #0x10
    61c0:	f90043e1 	str	x1, [sp, #128]
    61c4:	17fff8df 	b	4540 <_vfprintf_r+0xb70>
    61c8:	1e604120 	fmov	d0, d9
    61cc:	2a0703e2 	mov	w2, w7
    61d0:	9105e3e5 	add	x5, sp, #0x178
    61d4:	9105c3e4 	add	x4, sp, #0x170
    61d8:	910563e3 	add	x3, sp, #0x158
    61dc:	aa1303e0 	mov	x0, x19
    61e0:	52800061 	mov	w1, #0x3                   	// #3
    61e4:	b90093e7 	str	w7, [sp, #144]
    61e8:	291323e9 	stp	w9, w8, [sp, #152]
    61ec:	b900a3eb 	str	w11, [sp, #160]
    61f0:	94001340 	bl	aef0 <_dtoa_r>
    61f4:	aa0003f8 	mov	x24, x0
    61f8:	39400000 	ldrb	w0, [x0]
    61fc:	2f00e400 	movi	d0, #0x0
    6200:	b94093e7 	ldr	w7, [sp, #144]
    6204:	7100c01f 	cmp	w0, #0x30
    6208:	b940a3eb 	ldr	w11, [sp, #160]
    620c:	295323e9 	ldp	w9, w8, [sp, #152]
    6210:	1e600524 	fccmp	d9, d0, #0x4, eq	// eq = none
    6214:	54004e61 	b.ne	6be0 <_vfprintf_r+0x3210>  // b.any
    6218:	b9415be0 	ldr	w0, [sp, #344]
    621c:	1e602128 	fcmp	d9, #0.0
    6220:	93407ce1 	sxtw	x1, w7
    6224:	8b20c020 	add	x0, x1, w0, sxtw
    6228:	540042c1 	b.ne	6a80 <_vfprintf_r+0x30b0>  // b.any
    622c:	b9415be1 	ldr	w1, [sp, #344]
    6230:	b9009fe0 	str	w0, [sp, #156]
    6234:	12000120 	and	w0, w9, #0x1
    6238:	b90093e1 	str	w1, [sp, #144]
    623c:	2a070000 	orr	w0, w0, w7
    6240:	7100003f 	cmp	w1, #0x0
    6244:	54004b8d 	b.le	6bb4 <_vfprintf_r+0x31e4>
    6248:	35003ae0 	cbnz	w0, 69a4 <_vfprintf_r+0x2fd4>
    624c:	b94093fb 	ldr	w27, [sp, #144]
    6250:	52800cc8 	mov	w8, #0x66                  	// #102
    6254:	37503149 	tbnz	w9, #10, 687c <_vfprintf_r+0x2eac>
    6258:	7100037f 	cmp	w27, #0x0
    625c:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
    6260:	17ffffca 	b	6188 <_vfprintf_r+0x27b8>
    6264:	910603e2 	add	x2, sp, #0x180
    6268:	aa1503e1 	mov	x1, x21
    626c:	aa1303e0 	mov	x0, x19
    6270:	b90093e9 	str	w9, [sp, #144]
    6274:	b9009beb 	str	w11, [sp, #152]
    6278:	b900a3e3 	str	w3, [sp, #160]
    627c:	94000321 	bl	6f00 <__sprint_r>
    6280:	35fefb40 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    6284:	f940cbe0 	ldr	x0, [sp, #400]
    6288:	aa1603fc 	mov	x28, x22
    628c:	b94093e9 	ldr	w9, [sp, #144]
    6290:	b9409beb 	ldr	w11, [sp, #152]
    6294:	b940a3e3 	ldr	w3, [sp, #160]
    6298:	b9415be2 	ldr	w2, [sp, #344]
    629c:	17fff7a9 	b	4140 <_vfprintf_r+0x770>
    62a0:	39453fe1 	ldrb	w1, [sp, #335]
    62a4:	52800003 	mov	w3, #0x0                   	// #0
    62a8:	b90093ff 	str	wzr, [sp, #144]
    62ac:	52800007 	mov	w7, #0x0                   	// #0
    62b0:	b9009bff 	str	wzr, [sp, #152]
    62b4:	d2800017 	mov	x23, #0x0                   	// #0
    62b8:	b900a3ff 	str	wzr, [sp, #160]
    62bc:	34fecee1 	cbz	w1, 3c98 <_vfprintf_r+0x2c8>
    62c0:	17fff8c2 	b	45c8 <_vfprintf_r+0xbf8>
    62c4:	b9407fe0 	ldr	w0, [sp, #124]
    62c8:	11002001 	add	w1, w0, #0x8
    62cc:	7100003f 	cmp	w1, #0x0
    62d0:	540022ed 	b.le	672c <_vfprintf_r+0x2d5c>
    62d4:	f94043e0 	ldr	x0, [sp, #128]
    62d8:	b9007fe1 	str	w1, [sp, #124]
    62dc:	91002c02 	add	x2, x0, #0xb
    62e0:	927df041 	and	x1, x2, #0xfffffffffffffff8
    62e4:	f90043e1 	str	x1, [sp, #128]
    62e8:	17fff8fe 	b	46e0 <_vfprintf_r+0xd10>
    62ec:	f94057e2 	ldr	x2, [sp, #168]
    62f0:	b9407fe0 	ldr	w0, [sp, #124]
    62f4:	b9007fe1 	str	w1, [sp, #124]
    62f8:	8b20c042 	add	x2, x2, w0, sxtw
    62fc:	f94043e0 	ldr	x0, [sp, #128]
    6300:	f90043e2 	str	x2, [sp, #128]
    6304:	17fff94f 	b	4840 <_vfprintf_r+0xe70>
    6308:	f94057e2 	ldr	x2, [sp, #168]
    630c:	b9407fe0 	ldr	w0, [sp, #124]
    6310:	b9007fe1 	str	w1, [sp, #124]
    6314:	8b20c040 	add	x0, x2, w0, sxtw
    6318:	17fff9bc 	b	4a08 <_vfprintf_r+0x1038>
    631c:	f94057e2 	ldr	x2, [sp, #168]
    6320:	b9407fe0 	ldr	w0, [sp, #124]
    6324:	b9007fe1 	str	w1, [sp, #124]
    6328:	8b20c040 	add	x0, x2, w0, sxtw
    632c:	17fff904 	b	473c <_vfprintf_r+0xd6c>
    6330:	910603e2 	add	x2, sp, #0x180
    6334:	aa1503e1 	mov	x1, x21
    6338:	aa1303e0 	mov	x0, x19
    633c:	940002f1 	bl	6f00 <__sprint_r>
    6340:	35fef520 	cbnz	w0, 41e4 <_vfprintf_r+0x814>
    6344:	f940cbe0 	ldr	x0, [sp, #400]
    6348:	d0000043 	adrp	x3, 10000 <__env_lock>
    634c:	39400322 	ldrb	w2, [x25]
    6350:	aa1603e1 	mov	x1, x22
    6354:	91254064 	add	x4, x3, #0x950
    6358:	17ffff05 	b	5f6c <_vfprintf_r+0x259c>
    635c:	910603e2 	add	x2, sp, #0x180
    6360:	aa1503e1 	mov	x1, x21
    6364:	aa1303e0 	mov	x0, x19
    6368:	b900d3e9 	str	w9, [sp, #208]
    636c:	b900dbeb 	str	w11, [sp, #216]
    6370:	b900e3e3 	str	w3, [sp, #224]
    6374:	940002e3 	bl	6f00 <__sprint_r>
    6378:	35fef380 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    637c:	f940cbe0 	ldr	x0, [sp, #400]
    6380:	aa1603fc 	mov	x28, x22
    6384:	b940d3e9 	ldr	w9, [sp, #208]
    6388:	b940dbeb 	ldr	w11, [sp, #216]
    638c:	b940e3e3 	ldr	w3, [sp, #224]
    6390:	17fffa5b 	b	4cfc <_vfprintf_r+0x132c>
    6394:	2a1703e5 	mov	w5, w23
    6398:	2a1903e3 	mov	w3, w25
    639c:	aa1a03f7 	mov	x23, x26
    63a0:	aa1c03f9 	mov	x25, x28
    63a4:	b94093e9 	ldr	w9, [sp, #144]
    63a8:	aa0203fc 	mov	x28, x2
    63ac:	b9409beb 	ldr	w11, [sp, #152]
    63b0:	aa1803e4 	mov	x4, x24
    63b4:	2a0503fa 	mov	w26, w5
    63b8:	17fffcb3 	b	5684 <_vfprintf_r+0x1cb4>
    63bc:	910603e2 	add	x2, sp, #0x180
    63c0:	aa1503e1 	mov	x1, x21
    63c4:	aa1303e0 	mov	x0, x19
    63c8:	b90093e9 	str	w9, [sp, #144]
    63cc:	b9009beb 	str	w11, [sp, #152]
    63d0:	b900a3e3 	str	w3, [sp, #160]
    63d4:	940002cb 	bl	6f00 <__sprint_r>
    63d8:	35fef080 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    63dc:	f940cbe0 	ldr	x0, [sp, #400]
    63e0:	aa1603fc 	mov	x28, x22
    63e4:	b94093e9 	ldr	w9, [sp, #144]
    63e8:	b9409beb 	ldr	w11, [sp, #152]
    63ec:	b940a3e3 	ldr	w3, [sp, #160]
    63f0:	b9415bfa 	ldr	w26, [sp, #344]
    63f4:	17fffa5a 	b	4d5c <_vfprintf_r+0x138c>
    63f8:	f9407be1 	ldr	x1, [sp, #240]
    63fc:	b90093e8 	str	w8, [sp, #144]
    6400:	f94083e0 	ldr	x0, [sp, #256]
    6404:	29131feb 	stp	w11, w7, [sp, #152]
    6408:	f90053e3 	str	x3, [sp, #160]
    640c:	cb000318 	sub	x24, x24, x0
    6410:	aa0003e2 	mov	x2, x0
    6414:	aa1803e0 	mov	x0, x24
    6418:	a90cb3e4 	stp	x4, x12, [sp, #200]
    641c:	94001bed 	bl	d3d0 <strncpy>
    6420:	394006a0 	ldrb	w0, [x21, #1]
    6424:	52800005 	mov	w5, #0x0                   	// #0
    6428:	f94053e3 	ldr	x3, [sp, #160]
    642c:	7100001f 	cmp	w0, #0x0
    6430:	a94cb3e4 	ldp	x4, x12, [sp, #200]
    6434:	9a9506b5 	cinc	x21, x21, ne	// ne = any
    6438:	b94093e8 	ldr	w8, [sp, #144]
    643c:	29531feb 	ldp	w11, w7, [sp, #152]
    6440:	17fffcab 	b	56ec <_vfprintf_r+0x1d1c>
    6444:	910603e2 	add	x2, sp, #0x180
    6448:	aa1503e1 	mov	x1, x21
    644c:	aa1303e0 	mov	x0, x19
    6450:	b90093e9 	str	w9, [sp, #144]
    6454:	b9009beb 	str	w11, [sp, #152]
    6458:	b900a3e3 	str	w3, [sp, #160]
    645c:	940002a9 	bl	6f00 <__sprint_r>
    6460:	35feec40 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    6464:	295307eb 	ldp	w11, w1, [sp, #152]
    6468:	aa1603fc 	mov	x28, x22
    646c:	b9415bfa 	ldr	w26, [sp, #344]
    6470:	f940cbe0 	ldr	x0, [sp, #400]
    6474:	4b1a003a 	sub	w26, w1, w26
    6478:	b94093e9 	ldr	w9, [sp, #144]
    647c:	b940a3e3 	ldr	w3, [sp, #160]
    6480:	17fffa49 	b	4da4 <_vfprintf_r+0x13d4>
    6484:	d0000044 	adrp	x4, 10000 <__env_lock>
    6488:	4b0203fa 	neg	w26, w2
    648c:	91254084 	add	x4, x4, #0x950
    6490:	3100405f 	cmn	w2, #0x10
    6494:	54000cca 	b.ge	662c <_vfprintf_r+0x2c5c>  // b.tcont
    6498:	aa1903e2 	mov	x2, x25
    649c:	2a0903fc 	mov	w28, w9
    64a0:	aa1703f9 	mov	x25, x23
    64a4:	d280021b 	mov	x27, #0x10                  	// #16
    64a8:	aa1503f7 	mov	x23, x21
    64ac:	2a1a03f5 	mov	w21, w26
    64b0:	aa0203fa 	mov	x26, x2
    64b4:	f9004bf8 	str	x24, [sp, #144]
    64b8:	aa0403f8 	mov	x24, x4
    64bc:	b9009beb 	str	w11, [sp, #152]
    64c0:	b900a3e3 	str	w3, [sp, #160]
    64c4:	14000004 	b	64d4 <_vfprintf_r+0x2b04>
    64c8:	510042b5 	sub	w21, w21, #0x10
    64cc:	710042bf 	cmp	w21, #0x10
    64d0:	540009ad 	b.le	6604 <_vfprintf_r+0x2c34>
    64d4:	91004000 	add	x0, x0, #0x10
    64d8:	11000421 	add	w1, w1, #0x1
    64dc:	a9006cd8 	stp	x24, x27, [x6]
    64e0:	910040c6 	add	x6, x6, #0x10
    64e4:	b9018be1 	str	w1, [sp, #392]
    64e8:	f900cbe0 	str	x0, [sp, #400]
    64ec:	71001c3f 	cmp	w1, #0x7
    64f0:	54fffecd 	b.le	64c8 <_vfprintf_r+0x2af8>
    64f4:	910603e2 	add	x2, sp, #0x180
    64f8:	aa1703e1 	mov	x1, x23
    64fc:	aa1303e0 	mov	x0, x19
    6500:	94000280 	bl	6f00 <__sprint_r>
    6504:	35002f20 	cbnz	w0, 6ae8 <_vfprintf_r+0x3118>
    6508:	f940cbe0 	ldr	x0, [sp, #400]
    650c:	aa1603e6 	mov	x6, x22
    6510:	b9418be1 	ldr	w1, [sp, #392]
    6514:	17ffffed 	b	64c8 <_vfprintf_r+0x2af8>
    6518:	1e604120 	fmov	d0, d9
    651c:	2a0703e2 	mov	w2, w7
    6520:	9105e3e5 	add	x5, sp, #0x178
    6524:	9105c3e4 	add	x4, sp, #0x170
    6528:	910563e3 	add	x3, sp, #0x158
    652c:	aa1303e0 	mov	x0, x19
    6530:	52800041 	mov	w1, #0x2                   	// #2
    6534:	b90093e7 	str	w7, [sp, #144]
    6538:	291323e9 	stp	w9, w8, [sp, #152]
    653c:	b900a3eb 	str	w11, [sp, #160]
    6540:	9400126c 	bl	aef0 <_dtoa_r>
    6544:	295323e9 	ldp	w9, w8, [sp, #152]
    6548:	aa0003f8 	mov	x24, x0
    654c:	b94093e7 	ldr	w7, [sp, #144]
    6550:	b940a3eb 	ldr	w11, [sp, #160]
    6554:	36000369 	tbz	w9, #0, 65c0 <_vfprintf_r+0x2bf0>
    6558:	1e602128 	fcmp	d9, #0.0
    655c:	54003860 	b.eq	6c68 <_vfprintf_r+0x3298>  // b.none
    6560:	8b27c302 	add	x2, x24, w7, sxtw
    6564:	17fffd20 	b	59e4 <_vfprintf_r+0x2014>
    6568:	b940b3e1 	ldr	w1, [sp, #176]
    656c:	52800ce8 	mov	w8, #0x67                  	// #103
    6570:	0b00003b 	add	w27, w1, w0
    6574:	b94093e0 	ldr	w0, [sp, #144]
    6578:	7100001f 	cmp	w0, #0x0
    657c:	54ffe6cc 	b.gt	6254 <_vfprintf_r+0x2884>
    6580:	4b00036c 	sub	w12, w27, w0
    6584:	3100059b 	adds	w27, w12, #0x1
    6588:	1a9f5363 	csel	w3, w27, wzr, pl	// pl = nfrst
    658c:	17fffeff 	b	6188 <_vfprintf_r+0x27b8>
    6590:	910663f8 	add	x24, sp, #0x198
    6594:	d2800017 	mov	x23, #0x0                   	// #0
    6598:	17fffc17 	b	55f4 <_vfprintf_r+0x1c24>
    659c:	b940b2a0 	ldr	w0, [x21, #176]
    65a0:	370000a0 	tbnz	w0, #0, 65b4 <_vfprintf_r+0x2be4>
    65a4:	794022a0 	ldrh	w0, [x21, #16]
    65a8:	37480060 	tbnz	w0, #9, 65b4 <_vfprintf_r+0x2be4>
    65ac:	f94052a0 	ldr	x0, [x21, #160]
    65b0:	94000c30 	bl	9670 <__retarget_lock_release_recursive>
    65b4:	12800000 	mov	w0, #0xffffffff            	// #-1
    65b8:	b90073e0 	str	w0, [sp, #112]
    65bc:	17fff717 	b	4218 <_vfprintf_r+0x848>
    65c0:	f940bfe0 	ldr	x0, [sp, #376]
    65c4:	b9415be1 	ldr	w1, [sp, #344]
    65c8:	cb180000 	sub	x0, x0, x24
    65cc:	b90093e1 	str	w1, [sp, #144]
    65d0:	b9009fe0 	str	w0, [sp, #156]
    65d4:	17fffd15 	b	5a28 <_vfprintf_r+0x2058>
    65d8:	91058be1 	add	x1, sp, #0x162
    65dc:	35000082 	cbnz	w2, 65ec <_vfprintf_r+0x2c1c>
    65e0:	91058fe1 	add	x1, sp, #0x163
    65e4:	52800602 	mov	w2, #0x30                  	// #48
    65e8:	39058be2 	strb	w2, [sp, #354]
    65ec:	1100c000 	add	w0, w0, #0x30
    65f0:	38001420 	strb	w0, [x1], #1
    65f4:	910583e2 	add	x2, sp, #0x160
    65f8:	4b020020 	sub	w0, w1, w2
    65fc:	b900ebe0 	str	w0, [sp, #232]
    6600:	17fffd3f 	b	5afc <_vfprintf_r+0x212c>
    6604:	aa1a03e2 	mov	x2, x26
    6608:	aa1803e4 	mov	x4, x24
    660c:	f9404bf8 	ldr	x24, [sp, #144]
    6610:	2a1503fa 	mov	w26, w21
    6614:	b9409beb 	ldr	w11, [sp, #152]
    6618:	aa1703f5 	mov	x21, x23
    661c:	b940a3e3 	ldr	w3, [sp, #160]
    6620:	aa1903f7 	mov	x23, x25
    6624:	2a1c03e9 	mov	w9, w28
    6628:	aa0203f9 	mov	x25, x2
    662c:	93407f5a 	sxtw	x26, w26
    6630:	11000421 	add	w1, w1, #0x1
    6634:	8b1a0000 	add	x0, x0, x26
    6638:	a90068c4 	stp	x4, x26, [x6]
    663c:	910040c6 	add	x6, x6, #0x10
    6640:	b9018be1 	str	w1, [sp, #392]
    6644:	f900cbe0 	str	x0, [sp, #400]
    6648:	71001c3f 	cmp	w1, #0x7
    664c:	54fed96d 	b.le	4178 <_vfprintf_r+0x7a8>
    6650:	910603e2 	add	x2, sp, #0x180
    6654:	aa1503e1 	mov	x1, x21
    6658:	aa1303e0 	mov	x0, x19
    665c:	b90093e9 	str	w9, [sp, #144]
    6660:	b9009beb 	str	w11, [sp, #152]
    6664:	b900a3e3 	str	w3, [sp, #160]
    6668:	94000226 	bl	6f00 <__sprint_r>
    666c:	35fedbe0 	cbnz	w0, 41e8 <_vfprintf_r+0x818>
    6670:	f940cbe0 	ldr	x0, [sp, #400]
    6674:	aa1603e6 	mov	x6, x22
    6678:	b94093e9 	ldr	w9, [sp, #144]
    667c:	b9409beb 	ldr	w11, [sp, #152]
    6680:	b940a3e3 	ldr	w3, [sp, #160]
    6684:	b9418be1 	ldr	w1, [sp, #392]
    6688:	17fff6bc 	b	4178 <_vfprintf_r+0x7a8>
    668c:	f94087e2 	ldr	x2, [sp, #264]
    6690:	b940efe0 	ldr	w0, [sp, #236]
    6694:	b900efe1 	str	w1, [sp, #236]
    6698:	8b20c040 	add	x0, x2, w0, sxtw
    669c:	17fff7a9 	b	4540 <_vfprintf_r+0xb70>
    66a0:	f94087e2 	ldr	x2, [sp, #264]
    66a4:	b940efe0 	ldr	w0, [sp, #236]
    66a8:	b900efe1 	str	w1, [sp, #236]
    66ac:	8b20c040 	add	x0, x2, w0, sxtw
    66b0:	fd400008 	ldr	d8, [x0]
    66b4:	17fff7ae 	b	456c <_vfprintf_r+0xb9c>
    66b8:	f900bfec 	str	x12, [sp, #376]
    66bc:	aa0003e1 	mov	x1, x0
    66c0:	39403c44 	ldrb	w4, [x2, #15]
    66c4:	385ff003 	ldurb	w3, [x0, #-1]
    66c8:	6b04007f 	cmp	w3, w4
    66cc:	54000121 	b.ne	66f0 <_vfprintf_r+0x2d20>  // b.any
    66d0:	52800607 	mov	w7, #0x30                  	// #48
    66d4:	381ff027 	sturb	w7, [x1, #-1]
    66d8:	f940bfe1 	ldr	x1, [sp, #376]
    66dc:	d1000423 	sub	x3, x1, #0x1
    66e0:	f900bfe3 	str	x3, [sp, #376]
    66e4:	385ff023 	ldurb	w3, [x1, #-1]
    66e8:	6b04007f 	cmp	w3, w4
    66ec:	54ffff40 	b.eq	66d4 <_vfprintf_r+0x2d04>  // b.none
    66f0:	11000464 	add	w4, w3, #0x1
    66f4:	12001c84 	and	w4, w4, #0xff
    66f8:	7100e47f 	cmp	w3, #0x39
    66fc:	54000120 	b.eq	6720 <_vfprintf_r+0x2d50>  // b.none
    6700:	381ff024 	sturb	w4, [x1, #-1]
    6704:	b9415be1 	ldr	w1, [sp, #344]
    6708:	4b180000 	sub	w0, w0, w24
    670c:	b90093e1 	str	w1, [sp, #144]
    6710:	b9009fe0 	str	w0, [sp, #156]
    6714:	17fffb62 	b	549c <_vfprintf_r+0x1acc>
    6718:	3607a009 	tbz	w9, #0, 5b18 <_vfprintf_r+0x2148>
    671c:	17fffcfd 	b	5b10 <_vfprintf_r+0x2140>
    6720:	39402844 	ldrb	w4, [x2, #10]
    6724:	381ff024 	sturb	w4, [x1, #-1]
    6728:	17fffff7 	b	6704 <_vfprintf_r+0x2d34>
    672c:	f94057e2 	ldr	x2, [sp, #168]
    6730:	b9407fe0 	ldr	w0, [sp, #124]
    6734:	b9007fe1 	str	w1, [sp, #124]
    6738:	8b20c040 	add	x0, x2, w0, sxtw
    673c:	17fff7e9 	b	46e0 <_vfprintf_r+0xd10>
    6740:	aa1b03f7 	mov	x23, x27
    6744:	b5fed557 	cbnz	x23, 41ec <_vfprintf_r+0x81c>
    6748:	17fff6ac 	b	41f8 <_vfprintf_r+0x828>
    674c:	79c02320 	ldrsh	w0, [x25, #16]
    6750:	aa1903f5 	mov	x21, x25
    6754:	321a0000 	orr	w0, w0, #0x40
    6758:	79002320 	strh	w0, [x25, #16]
    675c:	17fff6a8 	b	41fc <_vfprintf_r+0x82c>
    6760:	37f81a80 	tbnz	w0, #31, 6ab0 <_vfprintf_r+0x30e0>
    6764:	f94043e0 	ldr	x0, [sp, #128]
    6768:	91003c01 	add	x1, x0, #0xf
    676c:	927df021 	and	x1, x1, #0xfffffffffffffff8
    6770:	f90043e1 	str	x1, [sp, #128]
    6774:	f9400000 	ldr	x0, [x0]
    6778:	b94073e1 	ldr	w1, [sp, #112]
    677c:	b9000001 	str	w1, [x0]
    6780:	17fff4db 	b	3aec <_vfprintf_r+0x11c>
    6784:	39453fe1 	ldrb	w1, [sp, #335]
    6788:	2a0703e3 	mov	w3, w7
    678c:	b9009bff 	str	wzr, [sp, #152]
    6790:	2a0703fb 	mov	w27, w7
    6794:	b900a3ff 	str	wzr, [sp, #160]
    6798:	52800007 	mov	w7, #0x0                   	// #0
    679c:	52800e68 	mov	w8, #0x73                  	// #115
    67a0:	34fea7c1 	cbz	w1, 3c98 <_vfprintf_r+0x2c8>
    67a4:	17fff789 	b	45c8 <_vfprintf_r+0xbf8>
    67a8:	f94057e2 	ldr	x2, [sp, #168]
    67ac:	b9407fe0 	ldr	w0, [sp, #124]
    67b0:	b9007fe1 	str	w1, [sp, #124]
    67b4:	8b20c040 	add	x0, x2, w0, sxtw
    67b8:	17fff9e4 	b	4f48 <_vfprintf_r+0x1578>
    67bc:	b9407fe0 	ldr	w0, [sp, #124]
    67c0:	11002001 	add	w1, w0, #0x8
    67c4:	7100003f 	cmp	w1, #0x0
    67c8:	5400246d 	b.le	6c54 <_vfprintf_r+0x3284>
    67cc:	f94043e0 	ldr	x0, [sp, #128]
    67d0:	b9007fe1 	str	w1, [sp, #124]
    67d4:	91002c02 	add	x2, x0, #0xb
    67d8:	927df041 	and	x1, x2, #0xfffffffffffffff8
    67dc:	f90043e1 	str	x1, [sp, #128]
    67e0:	17fffd31 	b	5ca4 <_vfprintf_r+0x22d4>
    67e4:	9e660100 	fmov	x0, d8
    67e8:	b7f81780 	tbnz	x0, #63, 6ad8 <_vfprintf_r+0x3108>
    67ec:	39453fe1 	ldrb	w1, [sp, #335]
    67f0:	d0000040 	adrp	x0, 10000 <__env_lock>
    67f4:	d0000045 	adrp	x5, 10000 <__env_lock>
    67f8:	7101211f 	cmp	w8, #0x48
    67fc:	91212000 	add	x0, x0, #0x848
    6800:	912100a5 	add	x5, x5, #0x840
    6804:	17fff767 	b	45a0 <_vfprintf_r+0xbd0>
    6808:	b9407fe0 	ldr	w0, [sp, #124]
    680c:	11002001 	add	w1, w0, #0x8
    6810:	7100003f 	cmp	w1, #0x0
    6814:	5400190d 	b.le	6b34 <_vfprintf_r+0x3164>
    6818:	f94043e0 	ldr	x0, [sp, #128]
    681c:	b9007fe1 	str	w1, [sp, #124]
    6820:	91002c02 	add	x2, x0, #0xb
    6824:	927df041 	and	x1, x2, #0xfffffffffffffff8
    6828:	b9400000 	ldr	w0, [x0]
    682c:	f90043e1 	str	x1, [sp, #128]
    6830:	17fff834 	b	4900 <_vfprintf_r+0xf30>
    6834:	f94057e2 	ldr	x2, [sp, #168]
    6838:	b9407fe0 	ldr	w0, [sp, #124]
    683c:	b9007fe1 	str	w1, [sp, #124]
    6840:	8b20c040 	add	x0, x2, w0, sxtw
    6844:	79400000 	ldrh	w0, [x0]
    6848:	17fffa7b 	b	5234 <_vfprintf_r+0x1864>
    684c:	b9407fe0 	ldr	w0, [sp, #124]
    6850:	11002001 	add	w1, w0, #0x8
    6854:	7100003f 	cmp	w1, #0x0
    6858:	54001f2d 	b.le	6c3c <_vfprintf_r+0x326c>
    685c:	f94043e0 	ldr	x0, [sp, #128]
    6860:	b9007fe1 	str	w1, [sp, #124]
    6864:	91002c02 	add	x2, x0, #0xb
    6868:	927df041 	and	x1, x2, #0xfffffffffffffff8
    686c:	39400000 	ldrb	w0, [x0]
    6870:	f90043e1 	str	x1, [sp, #128]
    6874:	17fff823 	b	4900 <_vfprintf_r+0xf30>
    6878:	52800ce8 	mov	w8, #0x67                  	// #103
    687c:	f9407fe2 	ldr	x2, [sp, #248]
    6880:	39400040 	ldrb	w0, [x2]
    6884:	7103fc1f 	cmp	w0, #0xff
    6888:	540021a0 	b.eq	6cbc <_vfprintf_r+0x32ec>  // b.none
    688c:	b94093e1 	ldr	w1, [sp, #144]
    6890:	52800004 	mov	w4, #0x0                   	// #0
    6894:	52800003 	mov	w3, #0x0                   	// #0
    6898:	14000005 	b	68ac <_vfprintf_r+0x2edc>
    689c:	11000463 	add	w3, w3, #0x1
    68a0:	91000442 	add	x2, x2, #0x1
    68a4:	7103fc1f 	cmp	w0, #0xff
    68a8:	54000120 	b.eq	68cc <_vfprintf_r+0x2efc>  // b.none
    68ac:	6b01001f 	cmp	w0, w1
    68b0:	540000ea 	b.ge	68cc <_vfprintf_r+0x2efc>  // b.tcont
    68b4:	4b000021 	sub	w1, w1, w0
    68b8:	39400440 	ldrb	w0, [x2, #1]
    68bc:	35ffff00 	cbnz	w0, 689c <_vfprintf_r+0x2ecc>
    68c0:	39400040 	ldrb	w0, [x2]
    68c4:	11000484 	add	w4, w4, #0x1
    68c8:	17fffff7 	b	68a4 <_vfprintf_r+0x2ed4>
    68cc:	b90093e1 	str	w1, [sp, #144]
    68d0:	b9009be3 	str	w3, [sp, #152]
    68d4:	b900a3e4 	str	w4, [sp, #160]
    68d8:	f9007fe2 	str	x2, [sp, #248]
    68dc:	b940a3e1 	ldr	w1, [sp, #160]
    68e0:	2a1703e9 	mov	w9, w23
    68e4:	b9409be0 	ldr	w0, [sp, #152]
    68e8:	d2800017 	mov	x23, #0x0                   	// #0
    68ec:	0b010000 	add	w0, w0, w1
    68f0:	b94103e1 	ldr	w1, [sp, #256]
    68f4:	1b016c1b 	madd	w27, w0, w1, w27
    68f8:	7100037f 	cmp	w27, #0x0
    68fc:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
    6900:	17fffc8d 	b	5b34 <_vfprintf_r+0x2164>
    6904:	0b1800e3 	add	w3, w7, w24
    6908:	4b000063 	sub	w3, w3, w0
    690c:	17fffad3 	b	5458 <_vfprintf_r+0x1a88>
    6910:	528005a0 	mov	w0, #0x2d                  	// #45
    6914:	1e614109 	fneg	d9, d8
    6918:	b900cbe0 	str	w0, [sp, #200]
    691c:	17fffc18 	b	597c <_vfprintf_r+0x1fac>
    6920:	b9407fe0 	ldr	w0, [sp, #124]
    6924:	11002001 	add	w1, w0, #0x8
    6928:	7100003f 	cmp	w1, #0x0
    692c:	540012cd 	b.le	6b84 <_vfprintf_r+0x31b4>
    6930:	f94043e0 	ldr	x0, [sp, #128]
    6934:	b9007fe1 	str	w1, [sp, #124]
    6938:	91002c02 	add	x2, x0, #0xb
    693c:	927df041 	and	x1, x2, #0xfffffffffffffff8
    6940:	b9400000 	ldr	w0, [x0]
    6944:	f90043e1 	str	x1, [sp, #128]
    6948:	17fffa3b 	b	5234 <_vfprintf_r+0x1864>
    694c:	b9407fe0 	ldr	w0, [sp, #124]
    6950:	11002001 	add	w1, w0, #0x8
    6954:	7100003f 	cmp	w1, #0x0
    6958:	5400122d 	b.le	6b9c <_vfprintf_r+0x31cc>
    695c:	f94043e0 	ldr	x0, [sp, #128]
    6960:	b9007fe1 	str	w1, [sp, #124]
    6964:	91002c02 	add	x2, x0, #0xb
    6968:	927df041 	and	x1, x2, #0xfffffffffffffff8
    696c:	39400000 	ldrb	w0, [x0]
    6970:	f90043e1 	str	x1, [sp, #128]
    6974:	17fffa30 	b	5234 <_vfprintf_r+0x1864>
    6978:	f94057e2 	ldr	x2, [sp, #168]
    697c:	b9407fe0 	ldr	w0, [sp, #124]
    6980:	b9007fe1 	str	w1, [sp, #124]
    6984:	8b20c040 	add	x0, x2, w0, sxtw
    6988:	79400000 	ldrh	w0, [x0]
    698c:	17fff7dd 	b	4900 <_vfprintf_r+0xf30>
    6990:	f94057e2 	ldr	x2, [sp, #168]
    6994:	b9407fe0 	ldr	w0, [sp, #124]
    6998:	b9007fe1 	str	w1, [sp, #124]
    699c:	8b20c040 	add	x0, x2, w0, sxtw
    69a0:	17fff961 	b	4f24 <_vfprintf_r+0x1554>
    69a4:	b940b3e0 	ldr	w0, [sp, #176]
    69a8:	52800cc8 	mov	w8, #0x66                  	// #102
    69ac:	0b00002c 	add	w12, w1, w0
    69b0:	0b07019b 	add	w27, w12, w7
    69b4:	17fffe28 	b	6254 <_vfprintf_r+0x2884>
    69b8:	aa1903f5 	mov	x21, x25
    69bc:	b94093e9 	ldr	w9, [sp, #144]
    69c0:	aa1b03f9 	mov	x25, x27
    69c4:	b9409be8 	ldr	w8, [sp, #152]
    69c8:	b940a3eb 	ldr	w11, [sp, #160]
    69cc:	2a1a03fb 	mov	w27, w26
    69d0:	17fffaf9 	b	55b4 <_vfprintf_r+0x1be4>
    69d4:	b9407fe0 	ldr	w0, [sp, #124]
    69d8:	11002001 	add	w1, w0, #0x8
    69dc:	7100003f 	cmp	w1, #0x0
    69e0:	54000b6d 	b.le	6b4c <_vfprintf_r+0x317c>
    69e4:	f94043e0 	ldr	x0, [sp, #128]
    69e8:	b9007fe1 	str	w1, [sp, #124]
    69ec:	91002c02 	add	x2, x0, #0xb
    69f0:	927df041 	and	x1, x2, #0xfffffffffffffff8
    69f4:	f90043e1 	str	x1, [sp, #128]
    69f8:	17fffbce 	b	5930 <_vfprintf_r+0x1f60>
    69fc:	b9407fe0 	ldr	w0, [sp, #124]
    6a00:	11002001 	add	w1, w0, #0x8
    6a04:	7100003f 	cmp	w1, #0x0
    6a08:	5400082d 	b.le	6b0c <_vfprintf_r+0x313c>
    6a0c:	f94043e0 	ldr	x0, [sp, #128]
    6a10:	b9007fe1 	str	w1, [sp, #124]
    6a14:	91002c02 	add	x2, x0, #0xb
    6a18:	927df041 	and	x1, x2, #0xfffffffffffffff8
    6a1c:	f90043e1 	str	x1, [sp, #128]
    6a20:	17fffcb7 	b	5cfc <_vfprintf_r+0x232c>
    6a24:	b9407fe0 	ldr	w0, [sp, #124]
    6a28:	11002001 	add	w1, w0, #0x8
    6a2c:	7100003f 	cmp	w1, #0x0
    6a30:	540012cd 	b.le	6c88 <_vfprintf_r+0x32b8>
    6a34:	f94043e0 	ldr	x0, [sp, #128]
    6a38:	b9007fe1 	str	w1, [sp, #124]
    6a3c:	91003c02 	add	x2, x0, #0xf
    6a40:	927df041 	and	x1, x2, #0xfffffffffffffff8
    6a44:	f90043e1 	str	x1, [sp, #128]
    6a48:	17fffc89 	b	5c6c <_vfprintf_r+0x229c>
    6a4c:	aa1a03f7 	mov	x23, x26
    6a50:	b5febcf7 	cbnz	x23, 41ec <_vfprintf_r+0x81c>
    6a54:	17fff5e9 	b	41f8 <_vfprintf_r+0x828>
    6a58:	b9407fe0 	ldr	w0, [sp, #124]
    6a5c:	11002001 	add	w1, w0, #0x8
    6a60:	7100003f 	cmp	w1, #0x0
    6a64:	54000c6d 	b.le	6bf0 <_vfprintf_r+0x3220>
    6a68:	f94043e0 	ldr	x0, [sp, #128]
    6a6c:	b9007fe1 	str	w1, [sp, #124]
    6a70:	91002c02 	add	x2, x0, #0xb
    6a74:	927df041 	and	x1, x2, #0xfffffffffffffff8
    6a78:	f90043e1 	str	x1, [sp, #128]
    6a7c:	17fffb9a 	b	58e4 <_vfprintf_r+0x1f14>
    6a80:	8b000302 	add	x2, x24, x0
    6a84:	17fffbd8 	b	59e4 <_vfprintf_r+0x2014>
    6a88:	b9407fe0 	ldr	w0, [sp, #124]
    6a8c:	11002001 	add	w1, w0, #0x8
    6a90:	7100003f 	cmp	w1, #0x0
    6a94:	5400046d 	b.le	6b20 <_vfprintf_r+0x3150>
    6a98:	f94043e0 	ldr	x0, [sp, #128]
    6a9c:	b9007fe1 	str	w1, [sp, #124]
    6aa0:	91003c02 	add	x2, x0, #0xf
    6aa4:	927df041 	and	x1, x2, #0xfffffffffffffff8
    6aa8:	f90043e1 	str	x1, [sp, #128]
    6aac:	17fff939 	b	4f90 <_vfprintf_r+0x15c0>
    6ab0:	b9407fe0 	ldr	w0, [sp, #124]
    6ab4:	11002001 	add	w1, w0, #0x8
    6ab8:	7100003f 	cmp	w1, #0x0
    6abc:	540005ad 	b.le	6b70 <_vfprintf_r+0x31a0>
    6ac0:	f94043e0 	ldr	x0, [sp, #128]
    6ac4:	b9007fe1 	str	w1, [sp, #124]
    6ac8:	91003c02 	add	x2, x0, #0xf
    6acc:	927df041 	and	x1, x2, #0xfffffffffffffff8
    6ad0:	f90043e1 	str	x1, [sp, #128]
    6ad4:	17ffff28 	b	6774 <_vfprintf_r+0x2da4>
    6ad8:	528005a0 	mov	w0, #0x2d                  	// #45
    6adc:	528005a1 	mov	w1, #0x2d                  	// #45
    6ae0:	39053fe0 	strb	w0, [sp, #335]
    6ae4:	17ffff43 	b	67f0 <_vfprintf_r+0x2e20>
    6ae8:	aa1703f5 	mov	x21, x23
    6aec:	aa1903f7 	mov	x23, x25
    6af0:	b5feb7f7 	cbnz	x23, 41ec <_vfprintf_r+0x81c>
    6af4:	17fff5c1 	b	41f8 <_vfprintf_r+0x828>
    6af8:	b9415be0 	ldr	w0, [sp, #344]
    6afc:	b90093e0 	str	w0, [sp, #144]
    6b00:	b94093e0 	ldr	w0, [sp, #144]
    6b04:	51000400 	sub	w0, w0, #0x1
    6b08:	17fffbce 	b	5a40 <_vfprintf_r+0x2070>
    6b0c:	f94057e2 	ldr	x2, [sp, #168]
    6b10:	b9407fe0 	ldr	w0, [sp, #124]
    6b14:	b9007fe1 	str	w1, [sp, #124]
    6b18:	8b20c040 	add	x0, x2, w0, sxtw
    6b1c:	17fffc78 	b	5cfc <_vfprintf_r+0x232c>
    6b20:	f94057e2 	ldr	x2, [sp, #168]
    6b24:	b9407fe0 	ldr	w0, [sp, #124]
    6b28:	b9007fe1 	str	w1, [sp, #124]
    6b2c:	8b20c040 	add	x0, x2, w0, sxtw
    6b30:	17fff918 	b	4f90 <_vfprintf_r+0x15c0>
    6b34:	f94057e2 	ldr	x2, [sp, #168]
    6b38:	b9407fe0 	ldr	w0, [sp, #124]
    6b3c:	b9007fe1 	str	w1, [sp, #124]
    6b40:	8b20c040 	add	x0, x2, w0, sxtw
    6b44:	b9400000 	ldr	w0, [x0]
    6b48:	17fff76e 	b	4900 <_vfprintf_r+0xf30>
    6b4c:	f94057e2 	ldr	x2, [sp, #168]
    6b50:	b9407fe0 	ldr	w0, [sp, #124]
    6b54:	b9007fe1 	str	w1, [sp, #124]
    6b58:	8b20c040 	add	x0, x2, w0, sxtw
    6b5c:	17fffb75 	b	5930 <_vfprintf_r+0x1f60>
    6b60:	79c022a0 	ldrsh	w0, [x21, #16]
    6b64:	321a0000 	orr	w0, w0, #0x40
    6b68:	790022a0 	strh	w0, [x21, #16]
    6b6c:	17fff5a4 	b	41fc <_vfprintf_r+0x82c>
    6b70:	f94057e2 	ldr	x2, [sp, #168]
    6b74:	b9407fe0 	ldr	w0, [sp, #124]
    6b78:	b9007fe1 	str	w1, [sp, #124]
    6b7c:	8b20c040 	add	x0, x2, w0, sxtw
    6b80:	17fffefd 	b	6774 <_vfprintf_r+0x2da4>
    6b84:	f94057e2 	ldr	x2, [sp, #168]
    6b88:	b9407fe0 	ldr	w0, [sp, #124]
    6b8c:	b9007fe1 	str	w1, [sp, #124]
    6b90:	8b20c040 	add	x0, x2, w0, sxtw
    6b94:	b9400000 	ldr	w0, [x0]
    6b98:	17fff9a7 	b	5234 <_vfprintf_r+0x1864>
    6b9c:	f94057e2 	ldr	x2, [sp, #168]
    6ba0:	b9407fe0 	ldr	w0, [sp, #124]
    6ba4:	b9007fe1 	str	w1, [sp, #124]
    6ba8:	8b20c040 	add	x0, x2, w0, sxtw
    6bac:	39400000 	ldrb	w0, [x0]
    6bb0:	17fff9a1 	b	5234 <_vfprintf_r+0x1864>
    6bb4:	350000a0 	cbnz	w0, 6bc8 <_vfprintf_r+0x31f8>
    6bb8:	52800023 	mov	w3, #0x1                   	// #1
    6bbc:	52800cc8 	mov	w8, #0x66                  	// #102
    6bc0:	2a0303fb 	mov	w27, w3
    6bc4:	17fffd71 	b	6188 <_vfprintf_r+0x27b8>
    6bc8:	b940b3e0 	ldr	w0, [sp, #176]
    6bcc:	52800cc8 	mov	w8, #0x66                  	// #102
    6bd0:	1100040c 	add	w12, w0, #0x1
    6bd4:	2b07019b 	adds	w27, w12, w7
    6bd8:	1a9f5363 	csel	w3, w27, wzr, pl	// pl = nfrst
    6bdc:	17fffd6b 	b	6188 <_vfprintf_r+0x27b8>
    6be0:	52800020 	mov	w0, #0x1                   	// #1
    6be4:	4b070000 	sub	w0, w0, w7
    6be8:	b9015be0 	str	w0, [sp, #344]
    6bec:	17fffd8c 	b	621c <_vfprintf_r+0x284c>
    6bf0:	f94057e2 	ldr	x2, [sp, #168]
    6bf4:	b9407fe0 	ldr	w0, [sp, #124]
    6bf8:	b9007fe1 	str	w1, [sp, #124]
    6bfc:	8b20c040 	add	x0, x2, w0, sxtw
    6c00:	17fffb39 	b	58e4 <_vfprintf_r+0x1f14>
    6c04:	b9407fe2 	ldr	w2, [sp, #124]
    6c08:	37f804a2 	tbnz	w2, #31, 6c9c <_vfprintf_r+0x32cc>
    6c0c:	f94043e0 	ldr	x0, [sp, #128]
    6c10:	91002c00 	add	x0, x0, #0xb
    6c14:	927df000 	and	x0, x0, #0xfffffffffffffff8
    6c18:	f94043e3 	ldr	x3, [sp, #128]
    6c1c:	b9007fe2 	str	w2, [sp, #124]
    6c20:	39400728 	ldrb	w8, [x25, #1]
    6c24:	aa0103f9 	mov	x25, x1
    6c28:	f90043e0 	str	x0, [sp, #128]
    6c2c:	b9400067 	ldr	w7, [x3]
    6c30:	710000ff 	cmp	w7, #0x0
    6c34:	5a9fa0fa 	csinv	w26, w7, wzr, ge	// ge = tcont
    6c38:	17fff400 	b	3c38 <_vfprintf_r+0x268>
    6c3c:	f94057e2 	ldr	x2, [sp, #168]
    6c40:	b9407fe0 	ldr	w0, [sp, #124]
    6c44:	b9007fe1 	str	w1, [sp, #124]
    6c48:	8b20c040 	add	x0, x2, w0, sxtw
    6c4c:	39400000 	ldrb	w0, [x0]
    6c50:	17fff72c 	b	4900 <_vfprintf_r+0xf30>
    6c54:	f94057e2 	ldr	x2, [sp, #168]
    6c58:	b9407fe0 	ldr	w0, [sp, #124]
    6c5c:	b9007fe1 	str	w1, [sp, #124]
    6c60:	8b20c040 	add	x0, x2, w0, sxtw
    6c64:	17fffc10 	b	5ca4 <_vfprintf_r+0x22d4>
    6c68:	b9415be0 	ldr	w0, [sp, #344]
    6c6c:	b90093e0 	str	w0, [sp, #144]
    6c70:	93407ce0 	sxtw	x0, w7
    6c74:	b9009fe7 	str	w7, [sp, #156]
    6c78:	17fffb6c 	b	5a28 <_vfprintf_r+0x2058>
    6c7c:	52800040 	mov	w0, #0x2                   	// #2
    6c80:	b900ebe0 	str	w0, [sp, #232]
    6c84:	17fffb9e 	b	5afc <_vfprintf_r+0x212c>
    6c88:	f94057e2 	ldr	x2, [sp, #168]
    6c8c:	b9407fe0 	ldr	w0, [sp, #124]
    6c90:	b9007fe1 	str	w1, [sp, #124]
    6c94:	8b20c040 	add	x0, x2, w0, sxtw
    6c98:	17fffbf5 	b	5c6c <_vfprintf_r+0x229c>
    6c9c:	b9407fe0 	ldr	w0, [sp, #124]
    6ca0:	11002002 	add	w2, w0, #0x8
    6ca4:	f94043e0 	ldr	x0, [sp, #128]
    6ca8:	7100005f 	cmp	w2, #0x0
    6cac:	540001ed 	b.le	6ce8 <_vfprintf_r+0x3318>
    6cb0:	91002c00 	add	x0, x0, #0xb
    6cb4:	927df000 	and	x0, x0, #0xfffffffffffffff8
    6cb8:	17ffffd8 	b	6c18 <_vfprintf_r+0x3248>
    6cbc:	b9009bff 	str	wzr, [sp, #152]
    6cc0:	b900a3ff 	str	wzr, [sp, #160]
    6cc4:	17ffff06 	b	68dc <_vfprintf_r+0x2f0c>
    6cc8:	71011b7f 	cmp	w27, #0x46
    6ccc:	54ffab40 	b.eq	6234 <_vfprintf_r+0x2864>  // b.none
    6cd0:	17ffff8c 	b	6b00 <_vfprintf_r+0x3130>
    6cd4:	794022a0 	ldrh	w0, [x21, #16]
    6cd8:	321a0000 	orr	w0, w0, #0x40
    6cdc:	790022a0 	strh	w0, [x21, #16]
    6ce0:	b5fea877 	cbnz	x23, 41ec <_vfprintf_r+0x81c>
    6ce4:	17fff545 	b	41f8 <_vfprintf_r+0x828>
    6ce8:	f94057e4 	ldr	x4, [sp, #168]
    6cec:	b9407fe3 	ldr	w3, [sp, #124]
    6cf0:	8b23c083 	add	x3, x4, w3, sxtw
    6cf4:	f90043e3 	str	x3, [sp, #128]
    6cf8:	17ffffc8 	b	6c18 <_vfprintf_r+0x3248>
    6cfc:	00000000 	udf	#0

0000000000006d00 <vfprintf>:
    6d00:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    6d04:	f0000044 	adrp	x4, 11000 <JIS_action_table>
    6d08:	aa0003e3 	mov	x3, x0
    6d0c:	910003fd 	mov	x29, sp
    6d10:	ad400440 	ldp	q0, q1, [x2]
    6d14:	aa0103e2 	mov	x2, x1
    6d18:	f9413c80 	ldr	x0, [x4, #632]
    6d1c:	aa0303e1 	mov	x1, x3
    6d20:	910043e3 	add	x3, sp, #0x10
    6d24:	ad0087e0 	stp	q0, q1, [sp, #16]
    6d28:	97fff32a 	bl	39d0 <_vfprintf_r>
    6d2c:	a8c37bfd 	ldp	x29, x30, [sp], #48
    6d30:	d65f03c0 	ret
	...

0000000000006d40 <__sbprintf>:
    6d40:	d11443ff 	sub	sp, sp, #0x510
    6d44:	a9007bfd 	stp	x29, x30, [sp]
    6d48:	910003fd 	mov	x29, sp
    6d4c:	a90153f3 	stp	x19, x20, [sp, #16]
    6d50:	aa0103f3 	mov	x19, x1
    6d54:	79402021 	ldrh	w1, [x1, #16]
    6d58:	aa0303f4 	mov	x20, x3
    6d5c:	910443e3 	add	x3, sp, #0x110
    6d60:	f9401a66 	ldr	x6, [x19, #48]
    6d64:	121e7821 	and	w1, w1, #0xfffffffd
    6d68:	f9402265 	ldr	x5, [x19, #64]
    6d6c:	a9025bf5 	stp	x21, x22, [sp, #32]
    6d70:	79402667 	ldrh	w7, [x19, #18]
    6d74:	b940b264 	ldr	w4, [x19, #176]
    6d78:	aa0203f6 	mov	x22, x2
    6d7c:	52808002 	mov	w2, #0x400                 	// #1024
    6d80:	aa0003f5 	mov	x21, x0
    6d84:	9103e3e0 	add	x0, sp, #0xf8
    6d88:	f9002fe3 	str	x3, [sp, #88]
    6d8c:	b90067e2 	str	w2, [sp, #100]
    6d90:	7900d3e1 	strh	w1, [sp, #104]
    6d94:	7900d7e7 	strh	w7, [sp, #106]
    6d98:	f9003be3 	str	x3, [sp, #112]
    6d9c:	b9007be2 	str	w2, [sp, #120]
    6da0:	b90083ff 	str	wzr, [sp, #128]
    6da4:	f90047e6 	str	x6, [sp, #136]
    6da8:	f9004fe5 	str	x5, [sp, #152]
    6dac:	b9010be4 	str	w4, [sp, #264]
    6db0:	94000a10 	bl	95f0 <__retarget_lock_init_recursive>
    6db4:	ad400680 	ldp	q0, q1, [x20]
    6db8:	aa1603e2 	mov	x2, x22
    6dbc:	9100c3e3 	add	x3, sp, #0x30
    6dc0:	aa1503e0 	mov	x0, x21
    6dc4:	910163e1 	add	x1, sp, #0x58
    6dc8:	ad0187e0 	stp	q0, q1, [sp, #48]
    6dcc:	97fff301 	bl	39d0 <_vfprintf_r>
    6dd0:	2a0003f4 	mov	w20, w0
    6dd4:	37f800c0 	tbnz	w0, #31, 6dec <__sbprintf+0xac>
    6dd8:	910163e1 	add	x1, sp, #0x58
    6ddc:	aa1503e0 	mov	x0, x21
    6de0:	9400156c 	bl	c390 <_fflush_r>
    6de4:	7100001f 	cmp	w0, #0x0
    6de8:	5a9f0294 	csinv	w20, w20, wzr, eq	// eq = none
    6dec:	7940d3e0 	ldrh	w0, [sp, #104]
    6df0:	36300080 	tbz	w0, #6, 6e00 <__sbprintf+0xc0>
    6df4:	79402260 	ldrh	w0, [x19, #16]
    6df8:	321a0000 	orr	w0, w0, #0x40
    6dfc:	79002260 	strh	w0, [x19, #16]
    6e00:	f9407fe0 	ldr	x0, [sp, #248]
    6e04:	94000a03 	bl	9610 <__retarget_lock_close_recursive>
    6e08:	a9407bfd 	ldp	x29, x30, [sp]
    6e0c:	2a1403e0 	mov	w0, w20
    6e10:	a94153f3 	ldp	x19, x20, [sp, #16]
    6e14:	a9425bf5 	ldp	x21, x22, [sp, #32]
    6e18:	911443ff 	add	sp, sp, #0x510
    6e1c:	d65f03c0 	ret

0000000000006e20 <__sprint_r.part.0>:
    6e20:	a9bb7bfd 	stp	x29, x30, [sp, #-80]!
    6e24:	910003fd 	mov	x29, sp
    6e28:	b940b023 	ldr	w3, [x1, #176]
    6e2c:	a90363f7 	stp	x23, x24, [sp, #48]
    6e30:	aa0203f8 	mov	x24, x2
    6e34:	36680563 	tbz	w3, #13, 6ee0 <__sprint_r.part.0+0xc0>
    6e38:	a9025bf5 	stp	x21, x22, [sp, #32]
    6e3c:	aa0003f5 	mov	x21, x0
    6e40:	f9400840 	ldr	x0, [x2, #16]
    6e44:	a90153f3 	stp	x19, x20, [sp, #16]
    6e48:	aa0103f4 	mov	x20, x1
    6e4c:	a9046bf9 	stp	x25, x26, [sp, #64]
    6e50:	f940005a 	ldr	x26, [x2]
    6e54:	b40003c0 	cbz	x0, 6ecc <__sprint_r.part.0+0xac>
    6e58:	a9406756 	ldp	x22, x25, [x26]
    6e5c:	d342ff39 	lsr	x25, x25, #2
    6e60:	2a1903f7 	mov	w23, w25
    6e64:	7100033f 	cmp	w25, #0x0
    6e68:	540002ad 	b.le	6ebc <__sprint_r.part.0+0x9c>
    6e6c:	d2800013 	mov	x19, #0x0                   	// #0
    6e70:	14000003 	b	6e7c <__sprint_r.part.0+0x5c>
    6e74:	6b1302ff 	cmp	w23, w19
    6e78:	5400020d 	b.le	6eb8 <__sprint_r.part.0+0x98>
    6e7c:	b8737ac1 	ldr	w1, [x22, x19, lsl #2]
    6e80:	aa1403e2 	mov	x2, x20
    6e84:	aa1503e0 	mov	x0, x21
    6e88:	91000673 	add	x19, x19, #0x1
    6e8c:	94001bed 	bl	de40 <_fputwc_r>
    6e90:	3100041f 	cmn	w0, #0x1
    6e94:	54ffff01 	b.ne	6e74 <__sprint_r.part.0+0x54>  // b.any
    6e98:	a94153f3 	ldp	x19, x20, [sp, #16]
    6e9c:	a9425bf5 	ldp	x21, x22, [sp, #32]
    6ea0:	a9446bf9 	ldp	x25, x26, [sp, #64]
    6ea4:	b9000b1f 	str	wzr, [x24, #8]
    6ea8:	f9000b1f 	str	xzr, [x24, #16]
    6eac:	a94363f7 	ldp	x23, x24, [sp, #48]
    6eb0:	a8c57bfd 	ldp	x29, x30, [sp], #80
    6eb4:	d65f03c0 	ret
    6eb8:	f9400b00 	ldr	x0, [x24, #16]
    6ebc:	cb39c800 	sub	x0, x0, w25, sxtw #2
    6ec0:	f9000b00 	str	x0, [x24, #16]
    6ec4:	9100435a 	add	x26, x26, #0x10
    6ec8:	b5fffc80 	cbnz	x0, 6e58 <__sprint_r.part.0+0x38>
    6ecc:	a94153f3 	ldp	x19, x20, [sp, #16]
    6ed0:	52800000 	mov	w0, #0x0                   	// #0
    6ed4:	a9425bf5 	ldp	x21, x22, [sp, #32]
    6ed8:	a9446bf9 	ldp	x25, x26, [sp, #64]
    6edc:	17fffff2 	b	6ea4 <__sprint_r.part.0+0x84>
    6ee0:	97fff160 	bl	3460 <__sfvwrite_r>
    6ee4:	b9000b1f 	str	wzr, [x24, #8]
    6ee8:	f9000b1f 	str	xzr, [x24, #16]
    6eec:	a94363f7 	ldp	x23, x24, [sp, #48]
    6ef0:	a8c57bfd 	ldp	x29, x30, [sp], #80
    6ef4:	d65f03c0 	ret
	...

0000000000006f00 <__sprint_r>:
    6f00:	f9400844 	ldr	x4, [x2, #16]
    6f04:	b4000044 	cbz	x4, 6f0c <__sprint_r+0xc>
    6f08:	17ffffc6 	b	6e20 <__sprint_r.part.0>
    6f0c:	52800000 	mov	w0, #0x0                   	// #0
    6f10:	b900085f 	str	wzr, [x2, #8]
    6f14:	d65f03c0 	ret
	...

0000000000006f20 <_vfiprintf_r>:
    6f20:	d10843ff 	sub	sp, sp, #0x210
    6f24:	a9007bfd 	stp	x29, x30, [sp]
    6f28:	910003fd 	mov	x29, sp
    6f2c:	a90153f3 	stp	x19, x20, [sp, #16]
    6f30:	aa0003f3 	mov	x19, x0
    6f34:	aa0303f4 	mov	x20, x3
    6f38:	a90363f7 	stp	x23, x24, [sp, #48]
    6f3c:	a9400078 	ldp	x24, x0, [x3]
    6f40:	a9025bf5 	stp	x21, x22, [sp, #32]
    6f44:	aa0103f6 	mov	x22, x1
    6f48:	b9401861 	ldr	w1, [x3, #24]
    6f4c:	a9046bf9 	stp	x25, x26, [sp, #64]
    6f50:	aa0203fa 	mov	x26, x2
    6f54:	d2800102 	mov	x2, #0x8                   	// #8
    6f58:	b90067e1 	str	w1, [sp, #100]
    6f5c:	52800001 	mov	w1, #0x0                   	// #0
    6f60:	f9003fe0 	str	x0, [sp, #120]
    6f64:	9103e3e0 	add	x0, sp, #0xf8
    6f68:	94000ee6 	bl	ab00 <memset>
    6f6c:	b4000073 	cbz	x19, 6f78 <_vfiprintf_r+0x58>
    6f70:	f9402660 	ldr	x0, [x19, #72]
    6f74:	b4009ba0 	cbz	x0, 82e8 <_vfiprintf_r+0x13c8>
    6f78:	b940b2c1 	ldr	w1, [x22, #176]
    6f7c:	79c022c0 	ldrsh	w0, [x22, #16]
    6f80:	37000041 	tbnz	w1, #0, 6f88 <_vfiprintf_r+0x68>
    6f84:	364877a0 	tbz	w0, #9, 7e78 <_vfiprintf_r+0xf58>
    6f88:	376800c0 	tbnz	w0, #13, 6fa0 <_vfiprintf_r+0x80>
    6f8c:	b940b2c1 	ldr	w1, [x22, #176]
    6f90:	32130000 	orr	w0, w0, #0x2000
    6f94:	790022c0 	strh	w0, [x22, #16]
    6f98:	12127821 	and	w1, w1, #0xffffdfff
    6f9c:	b900b2c1 	str	w1, [x22, #176]
    6fa0:	36180520 	tbz	w0, #3, 7044 <_vfiprintf_r+0x124>
    6fa4:	f9400ec1 	ldr	x1, [x22, #24]
    6fa8:	b40004e1 	cbz	x1, 7044 <_vfiprintf_r+0x124>
    6fac:	52800341 	mov	w1, #0x1a                  	// #26
    6fb0:	0a010001 	and	w1, w0, w1
    6fb4:	7100283f 	cmp	w1, #0xa
    6fb8:	54000580 	b.eq	7068 <_vfiprintf_r+0x148>  // b.none
    6fbc:	910643f7 	add	x23, sp, #0x190
    6fc0:	f0000055 	adrp	x21, 11000 <JIS_action_table>
    6fc4:	913402b5 	add	x21, x21, #0xd00
    6fc8:	a90573fb 	stp	x27, x28, [sp, #80]
    6fcc:	aa1703fb 	mov	x27, x23
    6fd0:	d0000040 	adrp	x0, 10000 <__env_lock>
    6fd4:	9125c000 	add	x0, x0, #0x970
    6fd8:	b90063ff 	str	wzr, [sp, #96]
    6fdc:	f9003be0 	str	x0, [sp, #112]
    6fe0:	f90043ff 	str	xzr, [sp, #128]
    6fe4:	a909ffff 	stp	xzr, xzr, [sp, #152]
    6fe8:	f90057ff 	str	xzr, [sp, #168]
    6fec:	f9008bf7 	str	x23, [sp, #272]
    6ff0:	b9011bff 	str	wzr, [sp, #280]
    6ff4:	f90093ff 	str	xzr, [sp, #288]
    6ff8:	aa1a03fc 	mov	x28, x26
    6ffc:	d503201f 	nop
    7000:	f94076b4 	ldr	x20, [x21, #232]
    7004:	94000cc3 	bl	a310 <__locale_mb_cur_max>
    7008:	9103e3e4 	add	x4, sp, #0xf8
    700c:	93407c03 	sxtw	x3, w0
    7010:	aa1c03e2 	mov	x2, x28
    7014:	9103d3e1 	add	x1, sp, #0xf4
    7018:	aa1303e0 	mov	x0, x19
    701c:	d63f0280 	blr	x20
    7020:	7100001f 	cmp	w0, #0x0
    7024:	340005a0 	cbz	w0, 70d8 <_vfiprintf_r+0x1b8>
    7028:	540004ab 	b.lt	70bc <_vfiprintf_r+0x19c>  // b.tstop
    702c:	b940f7e1 	ldr	w1, [sp, #244]
    7030:	7100943f 	cmp	w1, #0x25
    7034:	54001be0 	b.eq	73b0 <_vfiprintf_r+0x490>  // b.none
    7038:	93407c00 	sxtw	x0, w0
    703c:	8b00039c 	add	x28, x28, x0
    7040:	17fffff0 	b	7000 <_vfiprintf_r+0xe0>
    7044:	aa1603e1 	mov	x1, x22
    7048:	aa1303e0 	mov	x0, x19
    704c:	94000d55 	bl	a5a0 <__swsetup_r>
    7050:	3500b960 	cbnz	w0, 877c <_vfiprintf_r+0x185c>
    7054:	79c022c0 	ldrsh	w0, [x22, #16]
    7058:	52800341 	mov	w1, #0x1a                  	// #26
    705c:	0a010001 	and	w1, w0, w1
    7060:	7100283f 	cmp	w1, #0xa
    7064:	54fffac1 	b.ne	6fbc <_vfiprintf_r+0x9c>  // b.any
    7068:	79c026c1 	ldrsh	w1, [x22, #18]
    706c:	37fffa81 	tbnz	w1, #31, 6fbc <_vfiprintf_r+0x9c>
    7070:	b940b2c1 	ldr	w1, [x22, #176]
    7074:	37000041 	tbnz	w1, #0, 707c <_vfiprintf_r+0x15c>
    7078:	3648ae40 	tbz	w0, #9, 8640 <_vfiprintf_r+0x1720>
    707c:	ad400680 	ldp	q0, q1, [x20]
    7080:	aa1a03e2 	mov	x2, x26
    7084:	aa1603e1 	mov	x1, x22
    7088:	910303e3 	add	x3, sp, #0xc0
    708c:	aa1303e0 	mov	x0, x19
    7090:	ad0607e0 	stp	q0, q1, [sp, #192]
    7094:	940006bb 	bl	8b80 <__sbprintf>
    7098:	b90063e0 	str	w0, [sp, #96]
    709c:	a9407bfd 	ldp	x29, x30, [sp]
    70a0:	a94153f3 	ldp	x19, x20, [sp, #16]
    70a4:	a9425bf5 	ldp	x21, x22, [sp, #32]
    70a8:	a94363f7 	ldp	x23, x24, [sp, #48]
    70ac:	a9446bf9 	ldp	x25, x26, [sp, #64]
    70b0:	b94063e0 	ldr	w0, [sp, #96]
    70b4:	910843ff 	add	sp, sp, #0x210
    70b8:	d65f03c0 	ret
    70bc:	9103e3e0 	add	x0, sp, #0xf8
    70c0:	d2800102 	mov	x2, #0x8                   	// #8
    70c4:	52800001 	mov	w1, #0x0                   	// #0
    70c8:	94000e8e 	bl	ab00 <memset>
    70cc:	d2800020 	mov	x0, #0x1                   	// #1
    70d0:	8b00039c 	add	x28, x28, x0
    70d4:	17ffffcb 	b	7000 <_vfiprintf_r+0xe0>
    70d8:	2a0003f4 	mov	w20, w0
    70dc:	cb1a0380 	sub	x0, x28, x26
    70e0:	2a0003f9 	mov	w25, w0
    70e4:	34009280 	cbz	w0, 8334 <_vfiprintf_r+0x1414>
    70e8:	f94093e2 	ldr	x2, [sp, #288]
    70ec:	93407f21 	sxtw	x1, w25
    70f0:	b9411be0 	ldr	w0, [sp, #280]
    70f4:	8b020022 	add	x2, x1, x2
    70f8:	a900077a 	stp	x26, x1, [x27]
    70fc:	11000400 	add	w0, w0, #0x1
    7100:	b9011be0 	str	w0, [sp, #280]
    7104:	9100437b 	add	x27, x27, #0x10
    7108:	f90093e2 	str	x2, [sp, #288]
    710c:	71001c1f 	cmp	w0, #0x7
    7110:	5400010d 	b.le	7130 <_vfiprintf_r+0x210>
    7114:	b40066e2 	cbz	x2, 7df0 <_vfiprintf_r+0xed0>
    7118:	910443e2 	add	x2, sp, #0x110
    711c:	aa1603e1 	mov	x1, x22
    7120:	aa1303e0 	mov	x0, x19
    7124:	97ffff3f 	bl	6e20 <__sprint_r.part.0>
    7128:	35000420 	cbnz	w0, 71ac <_vfiprintf_r+0x28c>
    712c:	aa1703fb 	mov	x27, x23
    7130:	b94063e0 	ldr	w0, [sp, #96]
    7134:	0b190000 	add	w0, w0, w25
    7138:	b90063e0 	str	w0, [sp, #96]
    713c:	34008fd4 	cbz	w20, 8334 <_vfiprintf_r+0x1414>
    7140:	39400780 	ldrb	w0, [x28, #1]
    7144:	9100079a 	add	x26, x28, #0x1
    7148:	12800003 	mov	w3, #0xffffffff            	// #-1
    714c:	52800008 	mov	w8, #0x0                   	// #0
    7150:	2a0303fc 	mov	w28, w3
    7154:	2a0803f9 	mov	w25, w8
    7158:	52800014 	mov	w20, #0x0                   	// #0
    715c:	3903bfff 	strb	wzr, [sp, #239]
    7160:	9100075a 	add	x26, x26, #0x1
    7164:	51008001 	sub	w1, w0, #0x20
    7168:	7101683f 	cmp	w1, #0x5a
    716c:	540003a8 	b.hi	71e0 <_vfiprintf_r+0x2c0>  // b.pmore
    7170:	f9403be2 	ldr	x2, [sp, #112]
    7174:	78615841 	ldrh	w1, [x2, w1, uxtw #1]
    7178:	10000062 	adr	x2, 7184 <_vfiprintf_r+0x264>
    717c:	8b21a841 	add	x1, x2, w1, sxth #2
    7180:	d61f0020 	br	x1
    7184:	910443e2 	add	x2, sp, #0x110
    7188:	aa1603e1 	mov	x1, x22
    718c:	aa1303e0 	mov	x0, x19
    7190:	97ffff24 	bl	6e20 <__sprint_r.part.0>
    7194:	34000e60 	cbz	w0, 7360 <_vfiprintf_r+0x440>
    7198:	f94037e0 	ldr	x0, [sp, #104]
    719c:	b4000080 	cbz	x0, 71ac <_vfiprintf_r+0x28c>
    71a0:	f94037e1 	ldr	x1, [sp, #104]
    71a4:	aa1303e0 	mov	x0, x19
    71a8:	940016d6 	bl	cd00 <_free_r>
    71ac:	79c022c0 	ldrsh	w0, [x22, #16]
    71b0:	b940b2c1 	ldr	w1, [x22, #176]
    71b4:	36003c01 	tbz	w1, #0, 7934 <_vfiprintf_r+0xa14>
    71b8:	a94573fb 	ldp	x27, x28, [sp, #80]
    71bc:	3730aec0 	tbnz	w0, #6, 8794 <_vfiprintf_r+0x1874>
    71c0:	a9407bfd 	ldp	x29, x30, [sp]
    71c4:	a94153f3 	ldp	x19, x20, [sp, #16]
    71c8:	a9425bf5 	ldp	x21, x22, [sp, #32]
    71cc:	a94363f7 	ldp	x23, x24, [sp, #48]
    71d0:	a9446bf9 	ldp	x25, x26, [sp, #64]
    71d4:	b94063e0 	ldr	w0, [sp, #96]
    71d8:	910843ff 	add	sp, sp, #0x210
    71dc:	d65f03c0 	ret
    71e0:	2a1903e8 	mov	w8, w25
    71e4:	34008a80 	cbz	w0, 8334 <_vfiprintf_r+0x1414>
    71e8:	52800024 	mov	w4, #0x1                   	// #1
    71ec:	9104a3fc 	add	x28, sp, #0x128
    71f0:	2a0403f9 	mov	w25, w4
    71f4:	3903bfff 	strb	wzr, [sp, #239]
    71f8:	3904a3e0 	strb	w0, [sp, #296]
    71fc:	52800003 	mov	w3, #0x0                   	// #0
    7200:	f90037ff 	str	xzr, [sp, #104]
    7204:	d503201f 	nop
    7208:	b9411be1 	ldr	w1, [sp, #280]
    720c:	11000880 	add	w0, w4, #0x2
    7210:	721f028e 	ands	w14, w20, #0x2
    7214:	5280108c 	mov	w12, #0x84                  	// #132
    7218:	11000422 	add	w2, w1, #0x1
    721c:	1a841004 	csel	w4, w0, w4, ne	// ne = any
    7220:	f94093e0 	ldr	x0, [sp, #288]
    7224:	6a0c028c 	ands	w12, w20, w12
    7228:	2a0203eb 	mov	w11, w2
    722c:	54000081 	b.ne	723c <_vfiprintf_r+0x31c>  // b.any
    7230:	4b04010a 	sub	w10, w8, w4
    7234:	7100015f 	cmp	w10, #0x0
    7238:	5400254c 	b.gt	76e0 <_vfiprintf_r+0x7c0>
    723c:	3943bfe2 	ldrb	w2, [sp, #239]
    7240:	340001a2 	cbz	w2, 7274 <_vfiprintf_r+0x354>
    7244:	9103bfe1 	add	x1, sp, #0xef
    7248:	91000400 	add	x0, x0, #0x1
    724c:	f9000361 	str	x1, [x27]
    7250:	d2800021 	mov	x1, #0x1                   	// #1
    7254:	f9000761 	str	x1, [x27, #8]
    7258:	b9011beb 	str	w11, [sp, #280]
    725c:	f90093e0 	str	x0, [sp, #288]
    7260:	71001d7f 	cmp	w11, #0x7
    7264:	5400200c 	b.gt	7664 <_vfiprintf_r+0x744>
    7268:	2a0b03e1 	mov	w1, w11
    726c:	9100437b 	add	x27, x27, #0x10
    7270:	1100056b 	add	w11, w11, #0x1
    7274:	3400032e 	cbz	w14, 72d8 <_vfiprintf_r+0x3b8>
    7278:	91000800 	add	x0, x0, #0x2
    727c:	9103c3e2 	add	x2, sp, #0xf0
    7280:	d2800041 	mov	x1, #0x2                   	// #2
    7284:	a9000762 	stp	x2, x1, [x27]
    7288:	b9011beb 	str	w11, [sp, #280]
    728c:	f90093e0 	str	x0, [sp, #288]
    7290:	71001d7f 	cmp	w11, #0x7
    7294:	540021ed 	b.le	76d0 <_vfiprintf_r+0x7b0>
    7298:	b4005b80 	cbz	x0, 7e08 <_vfiprintf_r+0xee8>
    729c:	910443e2 	add	x2, sp, #0x110
    72a0:	aa1603e1 	mov	x1, x22
    72a4:	aa1303e0 	mov	x0, x19
    72a8:	b9008be4 	str	w4, [sp, #136]
    72ac:	b90093e8 	str	w8, [sp, #144]
    72b0:	29160fec 	stp	w12, w3, [sp, #176]
    72b4:	97fffedb 	bl	6e20 <__sprint_r.part.0>
    72b8:	35fff700 	cbnz	w0, 7198 <_vfiprintf_r+0x278>
    72bc:	b9411be1 	ldr	w1, [sp, #280]
    72c0:	aa1703fb 	mov	x27, x23
    72c4:	f94093e0 	ldr	x0, [sp, #288]
    72c8:	1100042b 	add	w11, w1, #0x1
    72cc:	b9408be4 	ldr	w4, [sp, #136]
    72d0:	b94093e8 	ldr	w8, [sp, #144]
    72d4:	29560fec 	ldp	w12, w3, [sp, #176]
    72d8:	7102019f 	cmp	w12, #0x80
    72dc:	54000860 	b.eq	73e8 <_vfiprintf_r+0x4c8>  // b.none
    72e0:	4b190063 	sub	w3, w3, w25
    72e4:	7100007f 	cmp	w3, #0x0
    72e8:	5400124c 	b.gt	7530 <_vfiprintf_r+0x610>
    72ec:	93407f29 	sxtw	x9, w25
    72f0:	a900277c 	stp	x28, x9, [x27]
    72f4:	8b000120 	add	x0, x9, x0
    72f8:	b9011beb 	str	w11, [sp, #280]
    72fc:	f90093e0 	str	x0, [sp, #288]
    7300:	71001d7f 	cmp	w11, #0x7
    7304:	540006ed 	b.le	73e0 <_vfiprintf_r+0x4c0>
    7308:	b4002780 	cbz	x0, 77f8 <_vfiprintf_r+0x8d8>
    730c:	910443e2 	add	x2, sp, #0x110
    7310:	aa1603e1 	mov	x1, x22
    7314:	aa1303e0 	mov	x0, x19
    7318:	b9008be4 	str	w4, [sp, #136]
    731c:	b900b3e8 	str	w8, [sp, #176]
    7320:	97fffec0 	bl	6e20 <__sprint_r.part.0>
    7324:	35fff3a0 	cbnz	w0, 7198 <_vfiprintf_r+0x278>
    7328:	f94093e0 	ldr	x0, [sp, #288]
    732c:	aa1703fb 	mov	x27, x23
    7330:	b9408be4 	ldr	w4, [sp, #136]
    7334:	b940b3e8 	ldr	w8, [sp, #176]
    7338:	36100094 	tbz	w20, #2, 7348 <_vfiprintf_r+0x428>
    733c:	4b040114 	sub	w20, w8, w4
    7340:	7100029f 	cmp	w20, #0x0
    7344:	5400266c 	b.gt	7810 <_vfiprintf_r+0x8f0>
    7348:	b94063e1 	ldr	w1, [sp, #96]
    734c:	6b04011f 	cmp	w8, w4
    7350:	1a84a104 	csel	w4, w8, w4, ge	// ge = tcont
    7354:	0b040021 	add	w1, w1, w4
    7358:	b90063e1 	str	w1, [sp, #96]
    735c:	b5fff140 	cbnz	x0, 7184 <_vfiprintf_r+0x264>
    7360:	f94037e0 	ldr	x0, [sp, #104]
    7364:	b9011bff 	str	wzr, [sp, #280]
    7368:	b4000080 	cbz	x0, 7378 <_vfiprintf_r+0x458>
    736c:	aa0003e1 	mov	x1, x0
    7370:	aa1303e0 	mov	x0, x19
    7374:	94001663 	bl	cd00 <_free_r>
    7378:	aa1703fb 	mov	x27, x23
    737c:	17ffff1f 	b	6ff8 <_vfiprintf_r+0xd8>
    7380:	5100c001 	sub	w1, w0, #0x30
    7384:	52800019 	mov	w25, #0x0                   	// #0
    7388:	38401740 	ldrb	w0, [x26], #1
    738c:	0b190b28 	add	w8, w25, w25, lsl #2
    7390:	0b080439 	add	w25, w1, w8, lsl #1
    7394:	5100c001 	sub	w1, w0, #0x30
    7398:	7100243f 	cmp	w1, #0x9
    739c:	54ffff69 	b.ls	7388 <_vfiprintf_r+0x468>  // b.plast
    73a0:	17ffff71 	b	7164 <_vfiprintf_r+0x244>
    73a4:	39400340 	ldrb	w0, [x26]
    73a8:	321c0294 	orr	w20, w20, #0x10
    73ac:	17ffff6d 	b	7160 <_vfiprintf_r+0x240>
    73b0:	2a0003f4 	mov	w20, w0
    73b4:	cb1a0380 	sub	x0, x28, x26
    73b8:	2a0003f9 	mov	w25, w0
    73bc:	34ffec20 	cbz	w0, 7140 <_vfiprintf_r+0x220>
    73c0:	17ffff4a 	b	70e8 <_vfiprintf_r+0x1c8>
    73c4:	aa1703fb 	mov	x27, x23
    73c8:	93407f20 	sxtw	x0, w25
    73cc:	52800021 	mov	w1, #0x1                   	// #1
    73d0:	b9011be1 	str	w1, [sp, #280]
    73d4:	f90093e0 	str	x0, [sp, #288]
    73d8:	a91903fc 	stp	x28, x0, [sp, #400]
    73dc:	d503201f 	nop
    73e0:	9100437b 	add	x27, x27, #0x10
    73e4:	17ffffd5 	b	7338 <_vfiprintf_r+0x418>
    73e8:	4b04010c 	sub	w12, w8, w4
    73ec:	7100019f 	cmp	w12, #0x0
    73f0:	54fff78d 	b.le	72e0 <_vfiprintf_r+0x3c0>
    73f4:	7100419f 	cmp	w12, #0x10
    73f8:	54009bad 	b.le	876c <_vfiprintf_r+0x184c>
    73fc:	aa1a03e2 	mov	x2, x26
    7400:	b000004a 	adrp	x10, 10000 <__env_lock>
    7404:	9128c14a 	add	x10, x10, #0xa30
    7408:	2a1903fa 	mov	w26, w25
    740c:	d280020b 	mov	x11, #0x10                  	// #16
    7410:	2a0303f9 	mov	w25, w3
    7414:	aa1b03e3 	mov	x3, x27
    7418:	aa0203fb 	mov	x27, x2
    741c:	f90047f8 	str	x24, [sp, #136]
    7420:	aa0a03f8 	mov	x24, x10
    7424:	b90093f4 	str	w20, [sp, #144]
    7428:	2a0c03f4 	mov	w20, w12
    742c:	291623e4 	stp	w4, w8, [sp, #176]
    7430:	14000007 	b	744c <_vfiprintf_r+0x52c>
    7434:	1100082d 	add	w13, w1, #0x2
    7438:	91004063 	add	x3, x3, #0x10
    743c:	2a0203e1 	mov	w1, w2
    7440:	51004294 	sub	w20, w20, #0x10
    7444:	7100429f 	cmp	w20, #0x10
    7448:	540002cd 	b.le	74a0 <_vfiprintf_r+0x580>
    744c:	91004000 	add	x0, x0, #0x10
    7450:	11000422 	add	w2, w1, #0x1
    7454:	a9002c78 	stp	x24, x11, [x3]
    7458:	b9011be2 	str	w2, [sp, #280]
    745c:	f90093e0 	str	x0, [sp, #288]
    7460:	71001c5f 	cmp	w2, #0x7
    7464:	54fffe8d 	b.le	7434 <_vfiprintf_r+0x514>
    7468:	b4004aa0 	cbz	x0, 7dbc <_vfiprintf_r+0xe9c>
    746c:	910443e2 	add	x2, sp, #0x110
    7470:	aa1603e1 	mov	x1, x22
    7474:	aa1303e0 	mov	x0, x19
    7478:	97fffe6a 	bl	6e20 <__sprint_r.part.0>
    747c:	35ffe8e0 	cbnz	w0, 7198 <_vfiprintf_r+0x278>
    7480:	b9411be1 	ldr	w1, [sp, #280]
    7484:	51004294 	sub	w20, w20, #0x10
    7488:	f94093e0 	ldr	x0, [sp, #288]
    748c:	aa1703e3 	mov	x3, x23
    7490:	1100042d 	add	w13, w1, #0x1
    7494:	d280020b 	mov	x11, #0x10                  	// #16
    7498:	7100429f 	cmp	w20, #0x10
    749c:	54fffd8c 	b.gt	744c <_vfiprintf_r+0x52c>
    74a0:	aa1b03e1 	mov	x1, x27
    74a4:	2a1403ec 	mov	w12, w20
    74a8:	aa1803ea 	mov	x10, x24
    74ac:	b94093f4 	ldr	w20, [sp, #144]
    74b0:	f94047f8 	ldr	x24, [sp, #136]
    74b4:	aa0303fb 	mov	x27, x3
    74b8:	295623e4 	ldp	w4, w8, [sp, #176]
    74bc:	2a1903e3 	mov	w3, w25
    74c0:	2a1a03f9 	mov	w25, w26
    74c4:	aa0103fa 	mov	x26, x1
    74c8:	93407d81 	sxtw	x1, w12
    74cc:	a900076a 	stp	x10, x1, [x27]
    74d0:	8b010000 	add	x0, x0, x1
    74d4:	b9011bed 	str	w13, [sp, #280]
    74d8:	f90093e0 	str	x0, [sp, #288]
    74dc:	71001dbf 	cmp	w13, #0x7
    74e0:	54004d4d 	b.le	7e88 <_vfiprintf_r+0xf68>
    74e4:	b4007f20 	cbz	x0, 84c8 <_vfiprintf_r+0x15a8>
    74e8:	910443e2 	add	x2, sp, #0x110
    74ec:	aa1603e1 	mov	x1, x22
    74f0:	aa1303e0 	mov	x0, x19
    74f4:	b9008be4 	str	w4, [sp, #136]
    74f8:	b90093e3 	str	w3, [sp, #144]
    74fc:	b900b3e8 	str	w8, [sp, #176]
    7500:	97fffe48 	bl	6e20 <__sprint_r.part.0>
    7504:	35ffe4a0 	cbnz	w0, 7198 <_vfiprintf_r+0x278>
    7508:	b94093e3 	ldr	w3, [sp, #144]
    750c:	aa1703fb 	mov	x27, x23
    7510:	b9411be1 	ldr	w1, [sp, #280]
    7514:	4b190063 	sub	w3, w3, w25
    7518:	b9408be4 	ldr	w4, [sp, #136]
    751c:	f94093e0 	ldr	x0, [sp, #288]
    7520:	1100042b 	add	w11, w1, #0x1
    7524:	b940b3e8 	ldr	w8, [sp, #176]
    7528:	7100007f 	cmp	w3, #0x0
    752c:	54ffee0d 	b.le	72ec <_vfiprintf_r+0x3cc>
    7530:	b000004a 	adrp	x10, 10000 <__env_lock>
    7534:	9128c14a 	add	x10, x10, #0xa30
    7538:	7100407f 	cmp	w3, #0x10
    753c:	5400060d 	b.le	75fc <_vfiprintf_r+0x6dc>
    7540:	d280020c 	mov	x12, #0x10                  	// #16
    7544:	f90047f8 	str	x24, [sp, #136]
    7548:	aa0a03f8 	mov	x24, x10
    754c:	b90093f4 	str	w20, [sp, #144]
    7550:	2a0303f4 	mov	w20, w3
    7554:	b900b3e4 	str	w4, [sp, #176]
    7558:	aa1b03e4 	mov	x4, x27
    755c:	aa1a03fb 	mov	x27, x26
    7560:	2a1903fa 	mov	w26, w25
    7564:	2a0803f9 	mov	w25, w8
    7568:	14000007 	b	7584 <_vfiprintf_r+0x664>
    756c:	1100082b 	add	w11, w1, #0x2
    7570:	91004084 	add	x4, x4, #0x10
    7574:	2a0203e1 	mov	w1, w2
    7578:	51004294 	sub	w20, w20, #0x10
    757c:	7100429f 	cmp	w20, #0x10
    7580:	540002cd 	b.le	75d8 <_vfiprintf_r+0x6b8>
    7584:	91004000 	add	x0, x0, #0x10
    7588:	11000422 	add	w2, w1, #0x1
    758c:	a9003098 	stp	x24, x12, [x4]
    7590:	b9011be2 	str	w2, [sp, #280]
    7594:	f90093e0 	str	x0, [sp, #288]
    7598:	71001c5f 	cmp	w2, #0x7
    759c:	54fffe8d 	b.le	756c <_vfiprintf_r+0x64c>
    75a0:	b40005a0 	cbz	x0, 7654 <_vfiprintf_r+0x734>
    75a4:	910443e2 	add	x2, sp, #0x110
    75a8:	aa1603e1 	mov	x1, x22
    75ac:	aa1303e0 	mov	x0, x19
    75b0:	97fffe1c 	bl	6e20 <__sprint_r.part.0>
    75b4:	35ffdf20 	cbnz	w0, 7198 <_vfiprintf_r+0x278>
    75b8:	b9411be1 	ldr	w1, [sp, #280]
    75bc:	51004294 	sub	w20, w20, #0x10
    75c0:	f94093e0 	ldr	x0, [sp, #288]
    75c4:	aa1703e4 	mov	x4, x23
    75c8:	1100042b 	add	w11, w1, #0x1
    75cc:	d280020c 	mov	x12, #0x10                  	// #16
    75d0:	7100429f 	cmp	w20, #0x10
    75d4:	54fffd8c 	b.gt	7584 <_vfiprintf_r+0x664>
    75d8:	2a1903e8 	mov	w8, w25
    75dc:	2a1403e3 	mov	w3, w20
    75e0:	2a1a03f9 	mov	w25, w26
    75e4:	aa1803ea 	mov	x10, x24
    75e8:	f94047f8 	ldr	x24, [sp, #136]
    75ec:	aa1b03fa 	mov	x26, x27
    75f0:	b94093f4 	ldr	w20, [sp, #144]
    75f4:	aa0403fb 	mov	x27, x4
    75f8:	b940b3e4 	ldr	w4, [sp, #176]
    75fc:	93407c63 	sxtw	x3, w3
    7600:	a9000f6a 	stp	x10, x3, [x27]
    7604:	8b030000 	add	x0, x0, x3
    7608:	b9011beb 	str	w11, [sp, #280]
    760c:	f90093e0 	str	x0, [sp, #288]
    7610:	71001d7f 	cmp	w11, #0x7
    7614:	540018ad 	b.le	7928 <_vfiprintf_r+0xa08>
    7618:	b4ffed60 	cbz	x0, 73c4 <_vfiprintf_r+0x4a4>
    761c:	910443e2 	add	x2, sp, #0x110
    7620:	aa1603e1 	mov	x1, x22
    7624:	aa1303e0 	mov	x0, x19
    7628:	b9008be4 	str	w4, [sp, #136]
    762c:	b900b3e8 	str	w8, [sp, #176]
    7630:	97fffdfc 	bl	6e20 <__sprint_r.part.0>
    7634:	35ffdb20 	cbnz	w0, 7198 <_vfiprintf_r+0x278>
    7638:	b9411beb 	ldr	w11, [sp, #280]
    763c:	aa1703fb 	mov	x27, x23
    7640:	f94093e0 	ldr	x0, [sp, #288]
    7644:	1100056b 	add	w11, w11, #0x1
    7648:	b9408be4 	ldr	w4, [sp, #136]
    764c:	b940b3e8 	ldr	w8, [sp, #176]
    7650:	17ffff27 	b	72ec <_vfiprintf_r+0x3cc>
    7654:	aa1703e4 	mov	x4, x23
    7658:	5280002b 	mov	w11, #0x1                   	// #1
    765c:	52800001 	mov	w1, #0x0                   	// #0
    7660:	17ffffc6 	b	7578 <_vfiprintf_r+0x658>
    7664:	b4000260 	cbz	x0, 76b0 <_vfiprintf_r+0x790>
    7668:	910443e2 	add	x2, sp, #0x110
    766c:	aa1603e1 	mov	x1, x22
    7670:	aa1303e0 	mov	x0, x19
    7674:	b9008be4 	str	w4, [sp, #136]
    7678:	b90093ec 	str	w12, [sp, #144]
    767c:	291623ee 	stp	w14, w8, [sp, #176]
    7680:	b900bbe3 	str	w3, [sp, #184]
    7684:	97fffde7 	bl	6e20 <__sprint_r.part.0>
    7688:	35ffd880 	cbnz	w0, 7198 <_vfiprintf_r+0x278>
    768c:	b9411be1 	ldr	w1, [sp, #280]
    7690:	aa1703fb 	mov	x27, x23
    7694:	f94093e0 	ldr	x0, [sp, #288]
    7698:	1100042b 	add	w11, w1, #0x1
    769c:	b9408be4 	ldr	w4, [sp, #136]
    76a0:	b94093ec 	ldr	w12, [sp, #144]
    76a4:	295623ee 	ldp	w14, w8, [sp, #176]
    76a8:	b940bbe3 	ldr	w3, [sp, #184]
    76ac:	17fffef2 	b	7274 <_vfiprintf_r+0x354>
    76b0:	3400426e 	cbz	w14, 7efc <_vfiprintf_r+0xfdc>
    76b4:	9103c3e0 	add	x0, sp, #0xf0
    76b8:	d2800041 	mov	x1, #0x2                   	// #2
    76bc:	aa1703fb 	mov	x27, x23
    76c0:	a91907e0 	stp	x0, x1, [sp, #400]
    76c4:	aa0103e0 	mov	x0, x1
    76c8:	5280002b 	mov	w11, #0x1                   	// #1
    76cc:	d503201f 	nop
    76d0:	2a0b03e1 	mov	w1, w11
    76d4:	9100437b 	add	x27, x27, #0x10
    76d8:	1100056b 	add	w11, w11, #0x1
    76dc:	17fffeff 	b	72d8 <_vfiprintf_r+0x3b8>
    76e0:	7100415f 	cmp	w10, #0x10
    76e4:	540081ed 	b.le	8720 <_vfiprintf_r+0x1800>
    76e8:	b000004b 	adrp	x11, 10000 <__env_lock>
    76ec:	9129016b 	add	x11, x11, #0xa40
    76f0:	291633e4 	stp	w4, w12, [sp, #176]
    76f4:	aa1a03e4 	mov	x4, x26
    76f8:	d280020d 	mov	x13, #0x10                  	// #16
    76fc:	2a1903fa 	mov	w26, w25
    7700:	2a0303f9 	mov	w25, w3
    7704:	aa1b03e3 	mov	x3, x27
    7708:	aa0403fb 	mov	x27, x4
    770c:	f90047f8 	str	x24, [sp, #136]
    7710:	aa0b03f8 	mov	x24, x11
    7714:	b90093ee 	str	w14, [sp, #144]
    7718:	291723f4 	stp	w20, w8, [sp, #184]
    771c:	2a0a03f4 	mov	w20, w10
    7720:	14000008 	b	7740 <_vfiprintf_r+0x820>
    7724:	1100082f 	add	w15, w1, #0x2
    7728:	91004063 	add	x3, x3, #0x10
    772c:	2a0203e1 	mov	w1, w2
    7730:	51004294 	sub	w20, w20, #0x10
    7734:	7100429f 	cmp	w20, #0x10
    7738:	540002cd 	b.le	7790 <_vfiprintf_r+0x870>
    773c:	11000422 	add	w2, w1, #0x1
    7740:	91004000 	add	x0, x0, #0x10
    7744:	a9003478 	stp	x24, x13, [x3]
    7748:	b9011be2 	str	w2, [sp, #280]
    774c:	f90093e0 	str	x0, [sp, #288]
    7750:	71001c5f 	cmp	w2, #0x7
    7754:	54fffe8d 	b.le	7724 <_vfiprintf_r+0x804>
    7758:	b4000480 	cbz	x0, 77e8 <_vfiprintf_r+0x8c8>
    775c:	910443e2 	add	x2, sp, #0x110
    7760:	aa1603e1 	mov	x1, x22
    7764:	aa1303e0 	mov	x0, x19
    7768:	97fffdae 	bl	6e20 <__sprint_r.part.0>
    776c:	35ffd160 	cbnz	w0, 7198 <_vfiprintf_r+0x278>
    7770:	b9411be1 	ldr	w1, [sp, #280]
    7774:	51004294 	sub	w20, w20, #0x10
    7778:	f94093e0 	ldr	x0, [sp, #288]
    777c:	aa1703e3 	mov	x3, x23
    7780:	1100042f 	add	w15, w1, #0x1
    7784:	d280020d 	mov	x13, #0x10                  	// #16
    7788:	7100429f 	cmp	w20, #0x10
    778c:	54fffd8c 	b.gt	773c <_vfiprintf_r+0x81c>
    7790:	aa1b03e1 	mov	x1, x27
    7794:	2a1403ea 	mov	w10, w20
    7798:	aa1803eb 	mov	x11, x24
    779c:	b94093ee 	ldr	w14, [sp, #144]
    77a0:	f94047f8 	ldr	x24, [sp, #136]
    77a4:	aa0303fb 	mov	x27, x3
    77a8:	295633e4 	ldp	w4, w12, [sp, #176]
    77ac:	2a1903e3 	mov	w3, w25
    77b0:	295723f4 	ldp	w20, w8, [sp, #184]
    77b4:	2a1a03f9 	mov	w25, w26
    77b8:	aa0103fa 	mov	x26, x1
    77bc:	93407d4a 	sxtw	x10, w10
    77c0:	a9002b6b 	stp	x11, x10, [x27]
    77c4:	8b0a0000 	add	x0, x0, x10
    77c8:	b9011bef 	str	w15, [sp, #280]
    77cc:	f90093e0 	str	x0, [sp, #288]
    77d0:	71001dff 	cmp	w15, #0x7
    77d4:	540032cc 	b.gt	7e2c <_vfiprintf_r+0xf0c>
    77d8:	9100437b 	add	x27, x27, #0x10
    77dc:	110005eb 	add	w11, w15, #0x1
    77e0:	2a0f03e1 	mov	w1, w15
    77e4:	17fffe96 	b	723c <_vfiprintf_r+0x31c>
    77e8:	aa1703e3 	mov	x3, x23
    77ec:	52800001 	mov	w1, #0x0                   	// #0
    77f0:	5280002f 	mov	w15, #0x1                   	// #1
    77f4:	17ffffcf 	b	7730 <_vfiprintf_r+0x810>
    77f8:	b9011bff 	str	wzr, [sp, #280]
    77fc:	361008b4 	tbz	w20, #2, 7910 <_vfiprintf_r+0x9f0>
    7800:	4b040114 	sub	w20, w8, w4
    7804:	7100029f 	cmp	w20, #0x0
    7808:	5400084d 	b.le	7910 <_vfiprintf_r+0x9f0>
    780c:	aa1703fb 	mov	x27, x23
    7810:	b9411be2 	ldr	w2, [sp, #280]
    7814:	7100429f 	cmp	w20, #0x10
    7818:	540078cd 	b.le	8730 <_vfiprintf_r+0x1810>
    781c:	b000004b 	adrp	x11, 10000 <__env_lock>
    7820:	9129016b 	add	x11, x11, #0xa40
    7824:	2a0403fc 	mov	w28, w4
    7828:	d2800219 	mov	x25, #0x10                  	// #16
    782c:	f90047f8 	str	x24, [sp, #136]
    7830:	aa0b03f8 	mov	x24, x11
    7834:	b900b3e8 	str	w8, [sp, #176]
    7838:	14000007 	b	7854 <_vfiprintf_r+0x934>
    783c:	11000846 	add	w6, w2, #0x2
    7840:	9100437b 	add	x27, x27, #0x10
    7844:	2a0103e2 	mov	w2, w1
    7848:	51004294 	sub	w20, w20, #0x10
    784c:	7100429f 	cmp	w20, #0x10
    7850:	540002ad 	b.le	78a4 <_vfiprintf_r+0x984>
    7854:	91004000 	add	x0, x0, #0x10
    7858:	11000441 	add	w1, w2, #0x1
    785c:	a9006778 	stp	x24, x25, [x27]
    7860:	b9011be1 	str	w1, [sp, #280]
    7864:	f90093e0 	str	x0, [sp, #288]
    7868:	71001c3f 	cmp	w1, #0x7
    786c:	54fffe8d 	b.le	783c <_vfiprintf_r+0x91c>
    7870:	b4000480 	cbz	x0, 7900 <_vfiprintf_r+0x9e0>
    7874:	910443e2 	add	x2, sp, #0x110
    7878:	aa1603e1 	mov	x1, x22
    787c:	aa1303e0 	mov	x0, x19
    7880:	97fffd68 	bl	6e20 <__sprint_r.part.0>
    7884:	35ffc8a0 	cbnz	w0, 7198 <_vfiprintf_r+0x278>
    7888:	b9411be2 	ldr	w2, [sp, #280]
    788c:	51004294 	sub	w20, w20, #0x10
    7890:	f94093e0 	ldr	x0, [sp, #288]
    7894:	aa1703fb 	mov	x27, x23
    7898:	11000446 	add	w6, w2, #0x1
    789c:	7100429f 	cmp	w20, #0x10
    78a0:	54fffdac 	b.gt	7854 <_vfiprintf_r+0x934>
    78a4:	aa1803eb 	mov	x11, x24
    78a8:	b940b3e8 	ldr	w8, [sp, #176]
    78ac:	f94047f8 	ldr	x24, [sp, #136]
    78b0:	2a1c03e4 	mov	w4, w28
    78b4:	93407e83 	sxtw	x3, w20
    78b8:	a9000f6b 	stp	x11, x3, [x27]
    78bc:	8b030000 	add	x0, x0, x3
    78c0:	b9011be6 	str	w6, [sp, #280]
    78c4:	f90093e0 	str	x0, [sp, #288]
    78c8:	71001cdf 	cmp	w6, #0x7
    78cc:	54ffd3ed 	b.le	7348 <_vfiprintf_r+0x428>
    78d0:	b4000200 	cbz	x0, 7910 <_vfiprintf_r+0x9f0>
    78d4:	910443e2 	add	x2, sp, #0x110
    78d8:	aa1603e1 	mov	x1, x22
    78dc:	aa1303e0 	mov	x0, x19
    78e0:	b9008be4 	str	w4, [sp, #136]
    78e4:	b900b3e8 	str	w8, [sp, #176]
    78e8:	97fffd4e 	bl	6e20 <__sprint_r.part.0>
    78ec:	35ffc560 	cbnz	w0, 7198 <_vfiprintf_r+0x278>
    78f0:	f94093e0 	ldr	x0, [sp, #288]
    78f4:	b9408be4 	ldr	w4, [sp, #136]
    78f8:	b940b3e8 	ldr	w8, [sp, #176]
    78fc:	17fffe93 	b	7348 <_vfiprintf_r+0x428>
    7900:	aa1703fb 	mov	x27, x23
    7904:	52800026 	mov	w6, #0x1                   	// #1
    7908:	52800002 	mov	w2, #0x0                   	// #0
    790c:	17ffffcf 	b	7848 <_vfiprintf_r+0x928>
    7910:	b94063e0 	ldr	w0, [sp, #96]
    7914:	6b04011f 	cmp	w8, w4
    7918:	1a84a104 	csel	w4, w8, w4, ge	// ge = tcont
    791c:	0b040000 	add	w0, w0, w4
    7920:	b90063e0 	str	w0, [sp, #96]
    7924:	17fffe8f 	b	7360 <_vfiprintf_r+0x440>
    7928:	9100437b 	add	x27, x27, #0x10
    792c:	1100056b 	add	w11, w11, #0x1
    7930:	17fffe6f 	b	72ec <_vfiprintf_r+0x3cc>
    7934:	374fc420 	tbnz	w0, #9, 71b8 <_vfiprintf_r+0x298>
    7938:	f94052c0 	ldr	x0, [x22, #160]
    793c:	9400074d 	bl	9670 <__retarget_lock_release_recursive>
    7940:	79c022c0 	ldrsh	w0, [x22, #16]
    7944:	17fffe1d 	b	71b8 <_vfiprintf_r+0x298>
    7948:	b94067e1 	ldr	w1, [sp, #100]
    794c:	2a1903e8 	mov	w8, w25
    7950:	2a1c03e3 	mov	w3, w28
    7954:	37f82f21 	tbnz	w1, #31, 7f38 <_vfiprintf_r+0x1018>
    7958:	91003f01 	add	x1, x24, #0xf
    795c:	927df021 	and	x1, x1, #0xfffffffffffffff8
    7960:	f90047e1 	str	x1, [sp, #136]
    7964:	f940031c 	ldr	x28, [x24]
    7968:	3903bfff 	strb	wzr, [sp, #239]
    796c:	b4004d5c 	cbz	x28, 8314 <_vfiprintf_r+0x13f4>
    7970:	71014c1f 	cmp	w0, #0x53
    7974:	54003e20 	b.eq	8138 <_vfiprintf_r+0x1218>  // b.none
    7978:	37203e14 	tbnz	w20, #4, 8138 <_vfiprintf_r+0x1218>
    797c:	3100047f 	cmn	w3, #0x1
    7980:	54006ba0 	b.eq	86f4 <_vfiprintf_r+0x17d4>  // b.none
    7984:	93407c62 	sxtw	x2, w3
    7988:	aa1c03e0 	mov	x0, x28
    798c:	52800001 	mov	w1, #0x0                   	// #0
    7990:	b90093e8 	str	w8, [sp, #144]
    7994:	b900b3e3 	str	w3, [sp, #176]
    7998:	94000aca 	bl	a4c0 <memchr>
    799c:	f90037e0 	str	x0, [sp, #104]
    79a0:	b94093e8 	ldr	w8, [sp, #144]
    79a4:	b940b3e3 	ldr	w3, [sp, #176]
    79a8:	b4006520 	cbz	x0, 864c <_vfiprintf_r+0x172c>
    79ac:	cb1c0004 	sub	x4, x0, x28
    79b0:	52800003 	mov	w3, #0x0                   	// #0
    79b4:	7100009f 	cmp	w4, #0x0
    79b8:	2a0403f9 	mov	w25, w4
    79bc:	f94047f8 	ldr	x24, [sp, #136]
    79c0:	1a9fa084 	csel	w4, w4, wzr, ge	// ge = tcont
    79c4:	f90037ff 	str	xzr, [sp, #104]
    79c8:	14000081 	b	7bcc <_vfiprintf_r+0xcac>
    79cc:	2a1903e8 	mov	w8, w25
    79d0:	71010c1f 	cmp	w0, #0x43
    79d4:	54000040 	b.eq	79dc <_vfiprintf_r+0xabc>  // b.none
    79d8:	36202d54 	tbz	w20, #4, 7f80 <_vfiprintf_r+0x1060>
    79dc:	910423e0 	add	x0, sp, #0x108
    79e0:	d2800102 	mov	x2, #0x8                   	// #8
    79e4:	52800001 	mov	w1, #0x0                   	// #0
    79e8:	b9006be8 	str	w8, [sp, #104]
    79ec:	94000c45 	bl	ab00 <memset>
    79f0:	294ca3e0 	ldp	w0, w8, [sp, #100]
    79f4:	37f850e0 	tbnz	w0, #31, 8410 <_vfiprintf_r+0x14f0>
    79f8:	91002f01 	add	x1, x24, #0xb
    79fc:	aa1803e0 	mov	x0, x24
    7a00:	927df038 	and	x24, x1, #0xfffffffffffffff8
    7a04:	b9400002 	ldr	w2, [x0]
    7a08:	9104a3fc 	add	x28, sp, #0x128
    7a0c:	910423e3 	add	x3, sp, #0x108
    7a10:	aa1c03e1 	mov	x1, x28
    7a14:	aa1303e0 	mov	x0, x19
    7a18:	b9006be8 	str	w8, [sp, #104]
    7a1c:	940006a5 	bl	94b0 <_wcrtomb_r>
    7a20:	2a0003f9 	mov	w25, w0
    7a24:	b9406be8 	ldr	w8, [sp, #104]
    7a28:	3100041f 	cmn	w0, #0x1
    7a2c:	540082e0 	b.eq	8a88 <_vfiprintf_r+0x1b68>  // b.none
    7a30:	7100001f 	cmp	w0, #0x0
    7a34:	3903bfff 	strb	wzr, [sp, #239]
    7a38:	1a9fa004 	csel	w4, w0, wzr, ge	// ge = tcont
    7a3c:	17fffdf0 	b	71fc <_vfiprintf_r+0x2dc>
    7a40:	4b1903f9 	neg	w25, w25
    7a44:	aa0003f8 	mov	x24, x0
    7a48:	39400340 	ldrb	w0, [x26]
    7a4c:	321e0294 	orr	w20, w20, #0x4
    7a50:	17fffdc4 	b	7160 <_vfiprintf_r+0x240>
    7a54:	52800560 	mov	w0, #0x2b                  	// #43
    7a58:	3903bfe0 	strb	w0, [sp, #239]
    7a5c:	39400340 	ldrb	w0, [x26]
    7a60:	17fffdc0 	b	7160 <_vfiprintf_r+0x240>
    7a64:	39400340 	ldrb	w0, [x26]
    7a68:	32190294 	orr	w20, w20, #0x80
    7a6c:	17fffdbd 	b	7160 <_vfiprintf_r+0x240>
    7a70:	aa1a03e2 	mov	x2, x26
    7a74:	38401440 	ldrb	w0, [x2], #1
    7a78:	7100a81f 	cmp	w0, #0x2a
    7a7c:	54007b00 	b.eq	89dc <_vfiprintf_r+0x1abc>  // b.none
    7a80:	5100c001 	sub	w1, w0, #0x30
    7a84:	aa0203fa 	mov	x26, x2
    7a88:	5280001c 	mov	w28, #0x0                   	// #0
    7a8c:	7100243f 	cmp	w1, #0x9
    7a90:	54ffb6a8 	b.hi	7164 <_vfiprintf_r+0x244>  // b.pmore
    7a94:	d503201f 	nop
    7a98:	38401740 	ldrb	w0, [x26], #1
    7a9c:	0b1c0b83 	add	w3, w28, w28, lsl #2
    7aa0:	0b03043c 	add	w28, w1, w3, lsl #1
    7aa4:	5100c001 	sub	w1, w0, #0x30
    7aa8:	7100243f 	cmp	w1, #0x9
    7aac:	54ffff69 	b.ls	7a98 <_vfiprintf_r+0xb78>  // b.plast
    7ab0:	17fffdad 	b	7164 <_vfiprintf_r+0x244>
    7ab4:	b94067e0 	ldr	w0, [sp, #100]
    7ab8:	37f82300 	tbnz	w0, #31, 7f18 <_vfiprintf_r+0xff8>
    7abc:	91002f00 	add	x0, x24, #0xb
    7ac0:	927df000 	and	x0, x0, #0xfffffffffffffff8
    7ac4:	b9400319 	ldr	w25, [x24]
    7ac8:	37fffbd9 	tbnz	w25, #31, 7a40 <_vfiprintf_r+0xb20>
    7acc:	aa0003f8 	mov	x24, x0
    7ad0:	39400340 	ldrb	w0, [x26]
    7ad4:	17fffda3 	b	7160 <_vfiprintf_r+0x240>
    7ad8:	aa1303e0 	mov	x0, x19
    7adc:	94000a1d 	bl	a350 <_localeconv_r>
    7ae0:	f9400400 	ldr	x0, [x0, #8]
    7ae4:	f90057e0 	str	x0, [sp, #168]
    7ae8:	97ffebb6 	bl	29c0 <strlen>
    7aec:	aa0003e1 	mov	x1, x0
    7af0:	aa1303e0 	mov	x0, x19
    7af4:	f9004fe1 	str	x1, [sp, #152]
    7af8:	94000a16 	bl	a350 <_localeconv_r>
    7afc:	f9404fe1 	ldr	x1, [sp, #152]
    7b00:	f9400800 	ldr	x0, [x0, #16]
    7b04:	f90053e0 	str	x0, [sp, #160]
    7b08:	f100003f 	cmp	x1, #0x0
    7b0c:	fa401804 	ccmp	x0, #0x0, #0x4, ne	// ne = any
    7b10:	54001c40 	b.eq	7e98 <_vfiprintf_r+0xf78>  // b.none
    7b14:	39400000 	ldrb	w0, [x0]
    7b18:	32160281 	orr	w1, w20, #0x400
    7b1c:	7100001f 	cmp	w0, #0x0
    7b20:	39400340 	ldrb	w0, [x26]
    7b24:	1a941034 	csel	w20, w1, w20, ne	// ne = any
    7b28:	17fffd8e 	b	7160 <_vfiprintf_r+0x240>
    7b2c:	39400340 	ldrb	w0, [x26]
    7b30:	32000294 	orr	w20, w20, #0x1
    7b34:	17fffd8b 	b	7160 <_vfiprintf_r+0x240>
    7b38:	3943bfe1 	ldrb	w1, [sp, #239]
    7b3c:	39400340 	ldrb	w0, [x26]
    7b40:	35ffb101 	cbnz	w1, 7160 <_vfiprintf_r+0x240>
    7b44:	52800401 	mov	w1, #0x20                  	// #32
    7b48:	3903bfe1 	strb	w1, [sp, #239]
    7b4c:	17fffd85 	b	7160 <_vfiprintf_r+0x240>
    7b50:	2a1903e8 	mov	w8, w25
    7b54:	2a1c03e3 	mov	w3, w28
    7b58:	321c0294 	orr	w20, w20, #0x10
    7b5c:	b94067e0 	ldr	w0, [sp, #100]
    7b60:	37280054 	tbnz	w20, #5, 7b68 <_vfiprintf_r+0xc48>
    7b64:	36201af4 	tbz	w20, #4, 7ec0 <_vfiprintf_r+0xfa0>
    7b68:	37f82cc0 	tbnz	w0, #31, 8100 <_vfiprintf_r+0x11e0>
    7b6c:	91003f01 	add	x1, x24, #0xf
    7b70:	aa1803e0 	mov	x0, x24
    7b74:	927df038 	and	x24, x1, #0xfffffffffffffff8
    7b78:	f9400001 	ldr	x1, [x0]
    7b7c:	12157a84 	and	w4, w20, #0xfffffbff
    7b80:	52800000 	mov	w0, #0x0                   	// #0
    7b84:	52800002 	mov	w2, #0x0                   	// #0
    7b88:	3903bfe2 	strb	w2, [sp, #239]
    7b8c:	3100047f 	cmn	w3, #0x1
    7b90:	54000d40 	b.eq	7d38 <_vfiprintf_r+0xe18>  // b.none
    7b94:	f100003f 	cmp	x1, #0x0
    7b98:	12187894 	and	w20, w4, #0xffffff7f
    7b9c:	7a400860 	ccmp	w3, #0x0, #0x0, eq	// eq = none
    7ba0:	54000ca1 	b.ne	7d34 <_vfiprintf_r+0xe14>  // b.any
    7ba4:	350005c0 	cbnz	w0, 7c5c <_vfiprintf_r+0xd3c>
    7ba8:	12000099 	and	w25, w4, #0x1
    7bac:	36001284 	tbz	w4, #0, 7dfc <_vfiprintf_r+0xedc>
    7bb0:	91062ffc 	add	x28, sp, #0x18b
    7bb4:	52800600 	mov	w0, #0x30                  	// #48
    7bb8:	52800003 	mov	w3, #0x0                   	// #0
    7bbc:	39062fe0 	strb	w0, [sp, #395]
    7bc0:	6b03033f 	cmp	w25, w3
    7bc4:	f90037ff 	str	xzr, [sp, #104]
    7bc8:	1a83a324 	csel	w4, w25, w3, ge	// ge = tcont
    7bcc:	3943bfe0 	ldrb	w0, [sp, #239]
    7bd0:	7100001f 	cmp	w0, #0x0
    7bd4:	1a840484 	cinc	w4, w4, ne	// ne = any
    7bd8:	17fffd8c 	b	7208 <_vfiprintf_r+0x2e8>
    7bdc:	2a1903e8 	mov	w8, w25
    7be0:	2a1c03e3 	mov	w3, w28
    7be4:	321c0284 	orr	w4, w20, #0x10
    7be8:	b94067e0 	ldr	w0, [sp, #100]
    7bec:	37280044 	tbnz	w4, #5, 7bf4 <_vfiprintf_r+0xcd4>
    7bf0:	36201584 	tbz	w4, #4, 7ea0 <_vfiprintf_r+0xf80>
    7bf4:	37f82740 	tbnz	w0, #31, 80dc <_vfiprintf_r+0x11bc>
    7bf8:	91003f01 	add	x1, x24, #0xf
    7bfc:	aa1803e0 	mov	x0, x24
    7c00:	927df038 	and	x24, x1, #0xfffffffffffffff8
    7c04:	f9400001 	ldr	x1, [x0]
    7c08:	52800020 	mov	w0, #0x1                   	// #1
    7c0c:	17ffffde 	b	7b84 <_vfiprintf_r+0xc64>
    7c10:	2a1903e8 	mov	w8, w25
    7c14:	2a1c03e3 	mov	w3, w28
    7c18:	321c0294 	orr	w20, w20, #0x10
    7c1c:	b94067e0 	ldr	w0, [sp, #100]
    7c20:	37280054 	tbnz	w20, #5, 7c28 <_vfiprintf_r+0xd08>
    7c24:	362015d4 	tbz	w20, #4, 7edc <_vfiprintf_r+0xfbc>
    7c28:	37f82480 	tbnz	w0, #31, 80b8 <_vfiprintf_r+0x1198>
    7c2c:	91003f01 	add	x1, x24, #0xf
    7c30:	aa1803e0 	mov	x0, x24
    7c34:	927df038 	and	x24, x1, #0xfffffffffffffff8
    7c38:	f9400000 	ldr	x0, [x0]
    7c3c:	aa0003e1 	mov	x1, x0
    7c40:	b7f80ec0 	tbnz	x0, #63, 7e18 <_vfiprintf_r+0xef8>
    7c44:	3100047f 	cmn	w3, #0x1
    7c48:	54000c20 	b.eq	7dcc <_vfiprintf_r+0xeac>  // b.none
    7c4c:	f100003f 	cmp	x1, #0x0
    7c50:	12187a94 	and	w20, w20, #0xffffff7f
    7c54:	7a400860 	ccmp	w3, #0x0, #0x0, eq	// eq = none
    7c58:	54000ba1 	b.ne	7dcc <_vfiprintf_r+0xeac>  // b.any
    7c5c:	910633fc 	add	x28, sp, #0x18c
    7c60:	52800003 	mov	w3, #0x0                   	// #0
    7c64:	52800019 	mov	w25, #0x0                   	// #0
    7c68:	17ffffd6 	b	7bc0 <_vfiprintf_r+0xca0>
    7c6c:	b94067e0 	ldr	w0, [sp, #100]
    7c70:	37280194 	tbnz	w20, #5, 7ca0 <_vfiprintf_r+0xd80>
    7c74:	37200174 	tbnz	w20, #4, 7ca0 <_vfiprintf_r+0xd80>
    7c78:	37304314 	tbnz	w20, #6, 84d8 <_vfiprintf_r+0x15b8>
    7c7c:	36486194 	tbz	w20, #9, 88ac <_vfiprintf_r+0x198c>
    7c80:	37f869c0 	tbnz	w0, #31, 89b8 <_vfiprintf_r+0x1a98>
    7c84:	91003f01 	add	x1, x24, #0xf
    7c88:	aa1803e0 	mov	x0, x24
    7c8c:	927df038 	and	x24, x1, #0xfffffffffffffff8
    7c90:	f9400000 	ldr	x0, [x0]
    7c94:	394183e1 	ldrb	w1, [sp, #96]
    7c98:	39000001 	strb	w1, [x0]
    7c9c:	17fffcd7 	b	6ff8 <_vfiprintf_r+0xd8>
    7ca0:	37f81880 	tbnz	w0, #31, 7fb0 <_vfiprintf_r+0x1090>
    7ca4:	91003f01 	add	x1, x24, #0xf
    7ca8:	aa1803e0 	mov	x0, x24
    7cac:	927df038 	and	x24, x1, #0xfffffffffffffff8
    7cb0:	f9400000 	ldr	x0, [x0]
    7cb4:	b98063e1 	ldrsw	x1, [sp, #96]
    7cb8:	f9000001 	str	x1, [x0]
    7cbc:	17fffccf 	b	6ff8 <_vfiprintf_r+0xd8>
    7cc0:	39400340 	ldrb	w0, [x26]
    7cc4:	7101b01f 	cmp	w0, #0x6c
    7cc8:	54003160 	b.eq	82f4 <_vfiprintf_r+0x13d4>  // b.none
    7ccc:	321c0294 	orr	w20, w20, #0x10
    7cd0:	17fffd24 	b	7160 <_vfiprintf_r+0x240>
    7cd4:	39400340 	ldrb	w0, [x26]
    7cd8:	7101a01f 	cmp	w0, #0x68
    7cdc:	54003140 	b.eq	8304 <_vfiprintf_r+0x13e4>  // b.none
    7ce0:	321a0294 	orr	w20, w20, #0x40
    7ce4:	17fffd1f 	b	7160 <_vfiprintf_r+0x240>
    7ce8:	39400340 	ldrb	w0, [x26]
    7cec:	321b0294 	orr	w20, w20, #0x20
    7cf0:	17fffd1c 	b	7160 <_vfiprintf_r+0x240>
    7cf4:	b94067e0 	ldr	w0, [sp, #100]
    7cf8:	2a1903e8 	mov	w8, w25
    7cfc:	2a1c03e3 	mov	w3, w28
    7d00:	37f812e0 	tbnz	w0, #31, 7f5c <_vfiprintf_r+0x103c>
    7d04:	91003f01 	add	x1, x24, #0xf
    7d08:	aa1803e0 	mov	x0, x24
    7d0c:	927df038 	and	x24, x1, #0xfffffffffffffff8
    7d10:	f9400001 	ldr	x1, [x0]
    7d14:	528f0600 	mov	w0, #0x7830                	// #30768
    7d18:	b0000042 	adrp	x2, 10000 <__env_lock>
    7d1c:	321f0284 	orr	w4, w20, #0x2
    7d20:	91214042 	add	x2, x2, #0x850
    7d24:	f90043e2 	str	x2, [sp, #128]
    7d28:	7901e3e0 	strh	w0, [sp, #240]
    7d2c:	52800040 	mov	w0, #0x2                   	// #2
    7d30:	17ffff95 	b	7b84 <_vfiprintf_r+0xc64>
    7d34:	2a1403e4 	mov	w4, w20
    7d38:	7100041f 	cmp	w0, #0x1
    7d3c:	540004a0 	b.eq	7dd0 <_vfiprintf_r+0xeb0>  // b.none
    7d40:	910633f9 	add	x25, sp, #0x18c
    7d44:	aa1903fc 	mov	x28, x25
    7d48:	7100081f 	cmp	w0, #0x2
    7d4c:	54000161 	b.ne	7d78 <_vfiprintf_r+0xe58>  // b.any
    7d50:	f94043e2 	ldr	x2, [sp, #128]
    7d54:	d503201f 	nop
    7d58:	92400c20 	and	x0, x1, #0xf
    7d5c:	d344fc21 	lsr	x1, x1, #4
    7d60:	38606840 	ldrb	w0, [x2, x0]
    7d64:	381fff80 	strb	w0, [x28, #-1]!
    7d68:	b5ffff81 	cbnz	x1, 7d58 <_vfiprintf_r+0xe38>
    7d6c:	4b1c0339 	sub	w25, w25, w28
    7d70:	2a0403f4 	mov	w20, w4
    7d74:	17ffff93 	b	7bc0 <_vfiprintf_r+0xca0>
    7d78:	12000820 	and	w0, w1, #0x7
    7d7c:	aa1c03e2 	mov	x2, x28
    7d80:	1100c000 	add	w0, w0, #0x30
    7d84:	381fff80 	strb	w0, [x28, #-1]!
    7d88:	d343fc21 	lsr	x1, x1, #3
    7d8c:	b5ffff61 	cbnz	x1, 7d78 <_vfiprintf_r+0xe58>
    7d90:	7100c01f 	cmp	w0, #0x30
    7d94:	1a9f07e0 	cset	w0, ne	// ne = any
    7d98:	6a00009f 	tst	w4, w0
    7d9c:	54fffe80 	b.eq	7d6c <_vfiprintf_r+0xe4c>  // b.none
    7da0:	d1000842 	sub	x2, x2, #0x2
    7da4:	52800600 	mov	w0, #0x30                  	// #48
    7da8:	2a0403f4 	mov	w20, w4
    7dac:	4b020339 	sub	w25, w25, w2
    7db0:	381ff380 	sturb	w0, [x28, #-1]
    7db4:	aa0203fc 	mov	x28, x2
    7db8:	17ffff82 	b	7bc0 <_vfiprintf_r+0xca0>
    7dbc:	aa1703e3 	mov	x3, x23
    7dc0:	5280002d 	mov	w13, #0x1                   	// #1
    7dc4:	52800001 	mov	w1, #0x0                   	// #0
    7dc8:	17fffd9e 	b	7440 <_vfiprintf_r+0x520>
    7dcc:	2a1403e4 	mov	w4, w20
    7dd0:	f100243f 	cmp	x1, #0x9
    7dd4:	54002368 	b.hi	8240 <_vfiprintf_r+0x1320>  // b.pmore
    7dd8:	1100c021 	add	w1, w1, #0x30
    7ddc:	2a0403f4 	mov	w20, w4
    7de0:	91062ffc 	add	x28, sp, #0x18b
    7de4:	52800039 	mov	w25, #0x1                   	// #1
    7de8:	39062fe1 	strb	w1, [sp, #395]
    7dec:	17ffff75 	b	7bc0 <_vfiprintf_r+0xca0>
    7df0:	aa1703fb 	mov	x27, x23
    7df4:	b9011bff 	str	wzr, [sp, #280]
    7df8:	17fffcce 	b	7130 <_vfiprintf_r+0x210>
    7dfc:	910633fc 	add	x28, sp, #0x18c
    7e00:	52800003 	mov	w3, #0x0                   	// #0
    7e04:	17ffff6f 	b	7bc0 <_vfiprintf_r+0xca0>
    7e08:	aa1703fb 	mov	x27, x23
    7e0c:	5280002b 	mov	w11, #0x1                   	// #1
    7e10:	52800001 	mov	w1, #0x0                   	// #0
    7e14:	17fffd31 	b	72d8 <_vfiprintf_r+0x3b8>
    7e18:	cb0103e1 	neg	x1, x1
    7e1c:	2a1403e4 	mov	w4, w20
    7e20:	528005a2 	mov	w2, #0x2d                  	// #45
    7e24:	52800020 	mov	w0, #0x1                   	// #1
    7e28:	17ffff58 	b	7b88 <_vfiprintf_r+0xc68>
    7e2c:	b4000d40 	cbz	x0, 7fd4 <_vfiprintf_r+0x10b4>
    7e30:	910443e2 	add	x2, sp, #0x110
    7e34:	aa1603e1 	mov	x1, x22
    7e38:	aa1303e0 	mov	x0, x19
    7e3c:	b9008be4 	str	w4, [sp, #136]
    7e40:	b90093ec 	str	w12, [sp, #144]
    7e44:	291623ee 	stp	w14, w8, [sp, #176]
    7e48:	b900bbe3 	str	w3, [sp, #184]
    7e4c:	97fffbf5 	bl	6e20 <__sprint_r.part.0>
    7e50:	35ff9a40 	cbnz	w0, 7198 <_vfiprintf_r+0x278>
    7e54:	b9411be1 	ldr	w1, [sp, #280]
    7e58:	aa1703fb 	mov	x27, x23
    7e5c:	f94093e0 	ldr	x0, [sp, #288]
    7e60:	1100042b 	add	w11, w1, #0x1
    7e64:	b9408be4 	ldr	w4, [sp, #136]
    7e68:	b94093ec 	ldr	w12, [sp, #144]
    7e6c:	295623ee 	ldp	w14, w8, [sp, #176]
    7e70:	b940bbe3 	ldr	w3, [sp, #184]
    7e74:	17fffcf2 	b	723c <_vfiprintf_r+0x31c>
    7e78:	f94052c0 	ldr	x0, [x22, #160]
    7e7c:	940005ed 	bl	9630 <__retarget_lock_acquire_recursive>
    7e80:	79c022c0 	ldrsh	w0, [x22, #16]
    7e84:	17fffc41 	b	6f88 <_vfiprintf_r+0x68>
    7e88:	9100437b 	add	x27, x27, #0x10
    7e8c:	110005ab 	add	w11, w13, #0x1
    7e90:	2a0d03e1 	mov	w1, w13
    7e94:	17fffd13 	b	72e0 <_vfiprintf_r+0x3c0>
    7e98:	39400340 	ldrb	w0, [x26]
    7e9c:	17fffcb1 	b	7160 <_vfiprintf_r+0x240>
    7ea0:	36302544 	tbz	w4, #6, 8348 <_vfiprintf_r+0x1428>
    7ea4:	37f83640 	tbnz	w0, #31, 856c <_vfiprintf_r+0x164c>
    7ea8:	91002f01 	add	x1, x24, #0xb
    7eac:	aa1803e0 	mov	x0, x24
    7eb0:	927df038 	and	x24, x1, #0xfffffffffffffff8
    7eb4:	79400001 	ldrh	w1, [x0]
    7eb8:	52800020 	mov	w0, #0x1                   	// #1
    7ebc:	17ffff32 	b	7b84 <_vfiprintf_r+0xc64>
    7ec0:	36302554 	tbz	w20, #6, 8368 <_vfiprintf_r+0x1448>
    7ec4:	37f83960 	tbnz	w0, #31, 85f0 <_vfiprintf_r+0x16d0>
    7ec8:	aa1803e0 	mov	x0, x24
    7ecc:	91002f01 	add	x1, x24, #0xb
    7ed0:	927df038 	and	x24, x1, #0xfffffffffffffff8
    7ed4:	79400001 	ldrh	w1, [x0]
    7ed8:	17ffff29 	b	7b7c <_vfiprintf_r+0xc5c>
    7edc:	36302814 	tbz	w20, #6, 83dc <_vfiprintf_r+0x14bc>
    7ee0:	37f83760 	tbnz	w0, #31, 85cc <_vfiprintf_r+0x16ac>
    7ee4:	91002f01 	add	x1, x24, #0xb
    7ee8:	aa1803e0 	mov	x0, x24
    7eec:	927df038 	and	x24, x1, #0xfffffffffffffff8
    7ef0:	79800001 	ldrsh	x1, [x0]
    7ef4:	aa0103e0 	mov	x0, x1
    7ef8:	17ffff52 	b	7c40 <_vfiprintf_r+0xd20>
    7efc:	aa1703fb 	mov	x27, x23
    7f00:	52800001 	mov	w1, #0x0                   	// #0
    7f04:	5280002b 	mov	w11, #0x1                   	// #1
    7f08:	17fffcf4 	b	72d8 <_vfiprintf_r+0x3b8>
    7f0c:	2a1903e8 	mov	w8, w25
    7f10:	2a1c03e3 	mov	w3, w28
    7f14:	17ffff42 	b	7c1c <_vfiprintf_r+0xcfc>
    7f18:	b94067e0 	ldr	w0, [sp, #100]
    7f1c:	11002001 	add	w1, w0, #0x8
    7f20:	7100003f 	cmp	w1, #0x0
    7f24:	54002b6d 	b.le	8490 <_vfiprintf_r+0x1570>
    7f28:	91002f00 	add	x0, x24, #0xb
    7f2c:	b90067e1 	str	w1, [sp, #100]
    7f30:	927df000 	and	x0, x0, #0xfffffffffffffff8
    7f34:	17fffee4 	b	7ac4 <_vfiprintf_r+0xba4>
    7f38:	b94067e1 	ldr	w1, [sp, #100]
    7f3c:	11002021 	add	w1, w1, #0x8
    7f40:	7100003f 	cmp	w1, #0x0
    7f44:	54002b4d 	b.le	84ac <_vfiprintf_r+0x158c>
    7f48:	91003f02 	add	x2, x24, #0xf
    7f4c:	b90067e1 	str	w1, [sp, #100]
    7f50:	927df041 	and	x1, x2, #0xfffffffffffffff8
    7f54:	f90047e1 	str	x1, [sp, #136]
    7f58:	17fffe83 	b	7964 <_vfiprintf_r+0xa44>
    7f5c:	b94067e0 	ldr	w0, [sp, #100]
    7f60:	11002001 	add	w1, w0, #0x8
    7f64:	7100003f 	cmp	w1, #0x0
    7f68:	540028ad 	b.le	847c <_vfiprintf_r+0x155c>
    7f6c:	91003f02 	add	x2, x24, #0xf
    7f70:	aa1803e0 	mov	x0, x24
    7f74:	927df058 	and	x24, x2, #0xfffffffffffffff8
    7f78:	b90067e1 	str	w1, [sp, #100]
    7f7c:	17ffff65 	b	7d10 <_vfiprintf_r+0xdf0>
    7f80:	b94067e0 	ldr	w0, [sp, #100]
    7f84:	37f836e0 	tbnz	w0, #31, 8660 <_vfiprintf_r+0x1740>
    7f88:	91002f01 	add	x1, x24, #0xb
    7f8c:	aa1803e0 	mov	x0, x24
    7f90:	927df038 	and	x24, x1, #0xfffffffffffffff8
    7f94:	b9400000 	ldr	w0, [x0]
    7f98:	52800024 	mov	w4, #0x1                   	// #1
    7f9c:	9104a3fc 	add	x28, sp, #0x128
    7fa0:	2a0403f9 	mov	w25, w4
    7fa4:	3903bfff 	strb	wzr, [sp, #239]
    7fa8:	3904a3e0 	strb	w0, [sp, #296]
    7fac:	17fffc94 	b	71fc <_vfiprintf_r+0x2dc>
    7fb0:	b94067e0 	ldr	w0, [sp, #100]
    7fb4:	11002001 	add	w1, w0, #0x8
    7fb8:	7100003f 	cmp	w1, #0x0
    7fbc:	5400392d 	b.le	86e0 <_vfiprintf_r+0x17c0>
    7fc0:	91003f02 	add	x2, x24, #0xf
    7fc4:	aa1803e0 	mov	x0, x24
    7fc8:	927df058 	and	x24, x2, #0xfffffffffffffff8
    7fcc:	b90067e1 	str	w1, [sp, #100]
    7fd0:	17ffff38 	b	7cb0 <_vfiprintf_r+0xd90>
    7fd4:	3943bfe1 	ldrb	w1, [sp, #239]
    7fd8:	340029e1 	cbz	w1, 8514 <_vfiprintf_r+0x15f4>
    7fdc:	d2800020 	mov	x0, #0x1                   	// #1
    7fe0:	9103bfe1 	add	x1, sp, #0xef
    7fe4:	aa1703fb 	mov	x27, x23
    7fe8:	2a0003eb 	mov	w11, w0
    7fec:	a91903e1 	stp	x1, x0, [sp, #400]
    7ff0:	17fffc9e 	b	7268 <_vfiprintf_r+0x348>
    7ff4:	2a1903e8 	mov	w8, w25
    7ff8:	2a1c03e3 	mov	w3, w28
    7ffc:	b0000041 	adrp	x1, 10000 <__env_lock>
    8000:	9121a021 	add	x1, x1, #0x868
    8004:	f90043e1 	str	x1, [sp, #128]
    8008:	b94067e1 	ldr	w1, [sp, #100]
    800c:	372802d4 	tbnz	w20, #5, 8064 <_vfiprintf_r+0x1144>
    8010:	372002b4 	tbnz	w20, #4, 8064 <_vfiprintf_r+0x1144>
    8014:	36301c34 	tbz	w20, #6, 8398 <_vfiprintf_r+0x1478>
    8018:	37f82bc1 	tbnz	w1, #31, 8590 <_vfiprintf_r+0x1670>
    801c:	aa1803e1 	mov	x1, x24
    8020:	91002f02 	add	x2, x24, #0xb
    8024:	927df058 	and	x24, x2, #0xfffffffffffffff8
    8028:	79400021 	ldrh	w1, [x1]
    802c:	14000013 	b	8078 <_vfiprintf_r+0x1158>
    8030:	2a1903e8 	mov	w8, w25
    8034:	2a1c03e3 	mov	w3, w28
    8038:	2a1403e4 	mov	w4, w20
    803c:	17fffeeb 	b	7be8 <_vfiprintf_r+0xcc8>
    8040:	90000041 	adrp	x1, 10000 <__env_lock>
    8044:	2a1903e8 	mov	w8, w25
    8048:	91214021 	add	x1, x1, #0x850
    804c:	2a1c03e3 	mov	w3, w28
    8050:	f90043e1 	str	x1, [sp, #128]
    8054:	17ffffed 	b	8008 <_vfiprintf_r+0x10e8>
    8058:	2a1903e8 	mov	w8, w25
    805c:	2a1c03e3 	mov	w3, w28
    8060:	17fffebf 	b	7b5c <_vfiprintf_r+0xc3c>
    8064:	37f80181 	tbnz	w1, #31, 8094 <_vfiprintf_r+0x1174>
    8068:	91003f02 	add	x2, x24, #0xf
    806c:	aa1803e1 	mov	x1, x24
    8070:	927df058 	and	x24, x2, #0xfffffffffffffff8
    8074:	f9400021 	ldr	x1, [x1]
    8078:	f100003f 	cmp	x1, #0x0
    807c:	1a9f07e2 	cset	w2, ne	// ne = any
    8080:	6a02029f 	tst	w20, w2
    8084:	54000501 	b.ne	8124 <_vfiprintf_r+0x1204>  // b.any
    8088:	12157a84 	and	w4, w20, #0xfffffbff
    808c:	52800040 	mov	w0, #0x2                   	// #2
    8090:	17fffebd 	b	7b84 <_vfiprintf_r+0xc64>
    8094:	b94067e1 	ldr	w1, [sp, #100]
    8098:	11002022 	add	w2, w1, #0x8
    809c:	7100005f 	cmp	w2, #0x0
    80a0:	5400172d 	b.le	8384 <_vfiprintf_r+0x1464>
    80a4:	91003f04 	add	x4, x24, #0xf
    80a8:	aa1803e1 	mov	x1, x24
    80ac:	927df098 	and	x24, x4, #0xfffffffffffffff8
    80b0:	b90067e2 	str	w2, [sp, #100]
    80b4:	17fffff0 	b	8074 <_vfiprintf_r+0x1154>
    80b8:	b94067e0 	ldr	w0, [sp, #100]
    80bc:	11002001 	add	w1, w0, #0x8
    80c0:	7100003f 	cmp	w1, #0x0
    80c4:	5400182d 	b.le	83c8 <_vfiprintf_r+0x14a8>
    80c8:	91003f02 	add	x2, x24, #0xf
    80cc:	aa1803e0 	mov	x0, x24
    80d0:	927df058 	and	x24, x2, #0xfffffffffffffff8
    80d4:	b90067e1 	str	w1, [sp, #100]
    80d8:	17fffed8 	b	7c38 <_vfiprintf_r+0xd18>
    80dc:	b94067e0 	ldr	w0, [sp, #100]
    80e0:	11002001 	add	w1, w0, #0x8
    80e4:	7100003f 	cmp	w1, #0x0
    80e8:	540018ad 	b.le	83fc <_vfiprintf_r+0x14dc>
    80ec:	91003f02 	add	x2, x24, #0xf
    80f0:	aa1803e0 	mov	x0, x24
    80f4:	927df058 	and	x24, x2, #0xfffffffffffffff8
    80f8:	b90067e1 	str	w1, [sp, #100]
    80fc:	17fffec2 	b	7c04 <_vfiprintf_r+0xce4>
    8100:	b94067e0 	ldr	w0, [sp, #100]
    8104:	11002001 	add	w1, w0, #0x8
    8108:	7100003f 	cmp	w1, #0x0
    810c:	5400154d 	b.le	83b4 <_vfiprintf_r+0x1494>
    8110:	91003f02 	add	x2, x24, #0xf
    8114:	aa1803e0 	mov	x0, x24
    8118:	927df058 	and	x24, x2, #0xfffffffffffffff8
    811c:	b90067e1 	str	w1, [sp, #100]
    8120:	17fffe96 	b	7b78 <_vfiprintf_r+0xc58>
    8124:	321f0294 	orr	w20, w20, #0x2
    8128:	3903c7e0 	strb	w0, [sp, #241]
    812c:	52800600 	mov	w0, #0x30                  	// #48
    8130:	3903c3e0 	strb	w0, [sp, #240]
    8134:	17ffffd5 	b	8088 <_vfiprintf_r+0x1168>
    8138:	910403e0 	add	x0, sp, #0x100
    813c:	d2800102 	mov	x2, #0x8                   	// #8
    8140:	52800001 	mov	w1, #0x0                   	// #0
    8144:	b9006be8 	str	w8, [sp, #104]
    8148:	b900b3e3 	str	w3, [sp, #176]
    814c:	f90087fc 	str	x28, [sp, #264]
    8150:	94000a6c 	bl	ab00 <memset>
    8154:	b940b3e3 	ldr	w3, [sp, #176]
    8158:	b9406be8 	ldr	w8, [sp, #104]
    815c:	3100047f 	cmn	w3, #0x1
    8160:	540016a0 	b.eq	8434 <_vfiprintf_r+0x1514>  // b.none
    8164:	aa1603e0 	mov	x0, x22
    8168:	d2800018 	mov	x24, #0x0                   	// #0
    816c:	52800019 	mov	w25, #0x0                   	// #0
    8170:	aa1803f6 	mov	x22, x24
    8174:	2a1903f8 	mov	w24, w25
    8178:	aa0003f9 	mov	x25, x0
    817c:	b9006bf4 	str	w20, [sp, #104]
    8180:	2a0303f4 	mov	w20, w3
    8184:	b900b3e8 	str	w8, [sp, #176]
    8188:	1400000d 	b	81bc <_vfiprintf_r+0x129c>
    818c:	910403e3 	add	x3, sp, #0x100
    8190:	9104a3e1 	add	x1, sp, #0x128
    8194:	aa1303e0 	mov	x0, x19
    8198:	940004c6 	bl	94b0 <_wcrtomb_r>
    819c:	3100041f 	cmn	w0, #0x1
    81a0:	54003560 	b.eq	884c <_vfiprintf_r+0x192c>  // b.none
    81a4:	0b000300 	add	w0, w24, w0
    81a8:	6b14001f 	cmp	w0, w20
    81ac:	540000ec 	b.gt	81c8 <_vfiprintf_r+0x12a8>
    81b0:	910012d6 	add	x22, x22, #0x4
    81b4:	54003420 	b.eq	8838 <_vfiprintf_r+0x1918>  // b.none
    81b8:	2a0003f8 	mov	w24, w0
    81bc:	f94087e0 	ldr	x0, [sp, #264]
    81c0:	b8766802 	ldr	w2, [x0, x22]
    81c4:	35fffe42 	cbnz	w2, 818c <_vfiprintf_r+0x126c>
    81c8:	b9406bf4 	ldr	w20, [sp, #104]
    81cc:	aa1903f6 	mov	x22, x25
    81d0:	b940b3e8 	ldr	w8, [sp, #176]
    81d4:	2a1803f9 	mov	w25, w24
    81d8:	34001499 	cbz	w25, 8468 <_vfiprintf_r+0x1548>
    81dc:	71018f3f 	cmp	w25, #0x63
    81e0:	540021cc 	b.gt	8618 <_vfiprintf_r+0x16f8>
    81e4:	9104a3fc 	add	x28, sp, #0x128
    81e8:	f90037ff 	str	xzr, [sp, #104]
    81ec:	93407f38 	sxtw	x24, w25
    81f0:	d2800102 	mov	x2, #0x8                   	// #8
    81f4:	52800001 	mov	w1, #0x0                   	// #0
    81f8:	910403e0 	add	x0, sp, #0x100
    81fc:	b900b3e8 	str	w8, [sp, #176]
    8200:	94000a40 	bl	ab00 <memset>
    8204:	910403e4 	add	x4, sp, #0x100
    8208:	aa1803e3 	mov	x3, x24
    820c:	910423e2 	add	x2, sp, #0x108
    8210:	aa1c03e1 	mov	x1, x28
    8214:	aa1303e0 	mov	x0, x19
    8218:	94000aba 	bl	ad00 <_wcsrtombs_r>
    821c:	b940b3e8 	ldr	w8, [sp, #176]
    8220:	eb00031f 	cmp	x24, x0
    8224:	54004841 	b.ne	8b2c <_vfiprintf_r+0x1c0c>  // b.any
    8228:	7100033f 	cmp	w25, #0x0
    822c:	52800003 	mov	w3, #0x0                   	// #0
    8230:	f94047f8 	ldr	x24, [sp, #136]
    8234:	1a9fa324 	csel	w4, w25, wzr, ge	// ge = tcont
    8238:	3839cb9f 	strb	wzr, [x28, w25, sxtw]
    823c:	17fffe64 	b	7bcc <_vfiprintf_r+0xcac>
    8240:	910633f9 	add	x25, sp, #0x18c
    8244:	1216008a 	and	w10, w4, #0x400
    8248:	b202e7e6 	mov	x6, #0xcccccccccccccccc    	// #-3689348814741910324
    824c:	aa1903e2 	mov	x2, x25
    8250:	aa1a03e5 	mov	x5, x26
    8254:	aa1903e7 	mov	x7, x25
    8258:	aa1603fa 	mov	x26, x22
    825c:	aa1303f9 	mov	x25, x19
    8260:	f94053f6 	ldr	x22, [sp, #160]
    8264:	2a0a03f3 	mov	w19, w10
    8268:	5280000b 	mov	w11, #0x0                   	// #0
    826c:	f29999a6 	movk	x6, #0xcccd
    8270:	14000007 	b	828c <_vfiprintf_r+0x136c>
    8274:	9bc67c34 	umulh	x20, x1, x6
    8278:	d343fe94 	lsr	x20, x20, #3
    827c:	f100243f 	cmp	x1, #0x9
    8280:	54000249 	b.ls	82c8 <_vfiprintf_r+0x13a8>  // b.plast
    8284:	aa1403e1 	mov	x1, x20
    8288:	aa1c03e2 	mov	x2, x28
    828c:	9bc67c34 	umulh	x20, x1, x6
    8290:	1100056b 	add	w11, w11, #0x1
    8294:	d100045c 	sub	x28, x2, #0x1
    8298:	d343fe94 	lsr	x20, x20, #3
    829c:	8b140a80 	add	x0, x20, x20, lsl #2
    82a0:	cb000420 	sub	x0, x1, x0, lsl #1
    82a4:	1100c000 	add	w0, w0, #0x30
    82a8:	381ff040 	sturb	w0, [x2, #-1]
    82ac:	34fffe53 	cbz	w19, 8274 <_vfiprintf_r+0x1354>
    82b0:	394002c0 	ldrb	w0, [x22]
    82b4:	7103fc1f 	cmp	w0, #0xff
    82b8:	7a4b1000 	ccmp	w0, w11, #0x0, ne	// ne = any
    82bc:	54fffdc1 	b.ne	8274 <_vfiprintf_r+0x1354>  // b.any
    82c0:	f100243f 	cmp	x1, #0x9
    82c4:	54001e08 	b.hi	8684 <_vfiprintf_r+0x1764>  // b.pmore
    82c8:	aa1903f3 	mov	x19, x25
    82cc:	aa0703f9 	mov	x25, x7
    82d0:	4b1c0339 	sub	w25, w25, w28
    82d4:	2a0403f4 	mov	w20, w4
    82d8:	f90053f6 	str	x22, [sp, #160]
    82dc:	aa1a03f6 	mov	x22, x26
    82e0:	aa0503fa 	mov	x26, x5
    82e4:	17fffe37 	b	7bc0 <_vfiprintf_r+0xca0>
    82e8:	aa1303e0 	mov	x0, x19
    82ec:	97ffeb99 	bl	3150 <__sinit>
    82f0:	17fffb22 	b	6f78 <_vfiprintf_r+0x58>
    82f4:	39400740 	ldrb	w0, [x26, #1]
    82f8:	321b0294 	orr	w20, w20, #0x20
    82fc:	9100075a 	add	x26, x26, #0x1
    8300:	17fffb98 	b	7160 <_vfiprintf_r+0x240>
    8304:	39400740 	ldrb	w0, [x26, #1]
    8308:	32170294 	orr	w20, w20, #0x200
    830c:	9100075a 	add	x26, x26, #0x1
    8310:	17fffb94 	b	7160 <_vfiprintf_r+0x240>
    8314:	7100187f 	cmp	w3, #0x6
    8318:	528000c9 	mov	w9, #0x6                   	// #6
    831c:	1a899079 	csel	w25, w3, w9, ls	// ls = plast
    8320:	90000047 	adrp	x7, 10000 <__env_lock>
    8324:	f94047f8 	ldr	x24, [sp, #136]
    8328:	2a1903e4 	mov	w4, w25
    832c:	912200fc 	add	x28, x7, #0x880
    8330:	17fffbb3 	b	71fc <_vfiprintf_r+0x2dc>
    8334:	f94093e0 	ldr	x0, [sp, #288]
    8338:	b5002040 	cbnz	x0, 8740 <_vfiprintf_r+0x1820>
    833c:	79c022c0 	ldrsh	w0, [x22, #16]
    8340:	b9011bff 	str	wzr, [sp, #280]
    8344:	17fffb9b 	b	71b0 <_vfiprintf_r+0x290>
    8348:	36481044 	tbz	w4, #9, 8550 <_vfiprintf_r+0x1630>
    834c:	37f82500 	tbnz	w0, #31, 87ec <_vfiprintf_r+0x18cc>
    8350:	91002f01 	add	x1, x24, #0xb
    8354:	aa1803e0 	mov	x0, x24
    8358:	927df038 	and	x24, x1, #0xfffffffffffffff8
    835c:	39400001 	ldrb	w1, [x0]
    8360:	52800020 	mov	w0, #0x1                   	// #1
    8364:	17fffe08 	b	7b84 <_vfiprintf_r+0xc64>
    8368:	36480dd4 	tbz	w20, #9, 8520 <_vfiprintf_r+0x1600>
    836c:	37f82520 	tbnz	w0, #31, 8810 <_vfiprintf_r+0x18f0>
    8370:	aa1803e0 	mov	x0, x24
    8374:	91002f01 	add	x1, x24, #0xb
    8378:	927df038 	and	x24, x1, #0xfffffffffffffff8
    837c:	39400001 	ldrb	w1, [x0]
    8380:	17fffdff 	b	7b7c <_vfiprintf_r+0xc5c>
    8384:	f9403fe4 	ldr	x4, [sp, #120]
    8388:	b94067e1 	ldr	w1, [sp, #100]
    838c:	b90067e2 	str	w2, [sp, #100]
    8390:	8b21c081 	add	x1, x4, w1, sxtw
    8394:	17ffff38 	b	8074 <_vfiprintf_r+0x1154>
    8398:	36480d14 	tbz	w20, #9, 8538 <_vfiprintf_r+0x1618>
    839c:	37f82021 	tbnz	w1, #31, 87a0 <_vfiprintf_r+0x1880>
    83a0:	aa1803e1 	mov	x1, x24
    83a4:	91002f02 	add	x2, x24, #0xb
    83a8:	927df058 	and	x24, x2, #0xfffffffffffffff8
    83ac:	39400021 	ldrb	w1, [x1]
    83b0:	17ffff32 	b	8078 <_vfiprintf_r+0x1158>
    83b4:	f9403fe2 	ldr	x2, [sp, #120]
    83b8:	b94067e0 	ldr	w0, [sp, #100]
    83bc:	b90067e1 	str	w1, [sp, #100]
    83c0:	8b20c040 	add	x0, x2, w0, sxtw
    83c4:	17fffded 	b	7b78 <_vfiprintf_r+0xc58>
    83c8:	f9403fe2 	ldr	x2, [sp, #120]
    83cc:	b94067e0 	ldr	w0, [sp, #100]
    83d0:	b90067e1 	str	w1, [sp, #100]
    83d4:	8b20c040 	add	x0, x2, w0, sxtw
    83d8:	17fffe18 	b	7c38 <_vfiprintf_r+0xd18>
    83dc:	364808f4 	tbz	w20, #9, 84f8 <_vfiprintf_r+0x15d8>
    83e0:	37f82760 	tbnz	w0, #31, 88cc <_vfiprintf_r+0x19ac>
    83e4:	91002f01 	add	x1, x24, #0xb
    83e8:	aa1803e0 	mov	x0, x24
    83ec:	927df038 	and	x24, x1, #0xfffffffffffffff8
    83f0:	39800001 	ldrsb	x1, [x0]
    83f4:	aa0103e0 	mov	x0, x1
    83f8:	17fffe12 	b	7c40 <_vfiprintf_r+0xd20>
    83fc:	f9403fe2 	ldr	x2, [sp, #120]
    8400:	b94067e0 	ldr	w0, [sp, #100]
    8404:	b90067e1 	str	w1, [sp, #100]
    8408:	8b20c040 	add	x0, x2, w0, sxtw
    840c:	17fffdfe 	b	7c04 <_vfiprintf_r+0xce4>
    8410:	b94067e0 	ldr	w0, [sp, #100]
    8414:	11002001 	add	w1, w0, #0x8
    8418:	7100003f 	cmp	w1, #0x0
    841c:	54000ced 	b.le	85b8 <_vfiprintf_r+0x1698>
    8420:	91002f02 	add	x2, x24, #0xb
    8424:	aa1803e0 	mov	x0, x24
    8428:	927df058 	and	x24, x2, #0xfffffffffffffff8
    842c:	b90067e1 	str	w1, [sp, #100]
    8430:	17fffd75 	b	7a04 <_vfiprintf_r+0xae4>
    8434:	910403e4 	add	x4, sp, #0x100
    8438:	910423e2 	add	x2, sp, #0x108
    843c:	aa1303e0 	mov	x0, x19
    8440:	d2800003 	mov	x3, #0x0                   	// #0
    8444:	d2800001 	mov	x1, #0x0                   	// #0
    8448:	b9006be8 	str	w8, [sp, #104]
    844c:	94000a2d 	bl	ad00 <_wcsrtombs_r>
    8450:	2a0003f9 	mov	w25, w0
    8454:	b9406be8 	ldr	w8, [sp, #104]
    8458:	3100041f 	cmn	w0, #0x1
    845c:	54003160 	b.eq	8a88 <_vfiprintf_r+0x1b68>  // b.none
    8460:	f90087fc 	str	x28, [sp, #264]
    8464:	17ffff5d 	b	81d8 <_vfiprintf_r+0x12b8>
    8468:	f94047f8 	ldr	x24, [sp, #136]
    846c:	52800004 	mov	w4, #0x0                   	// #0
    8470:	52800003 	mov	w3, #0x0                   	// #0
    8474:	f90037ff 	str	xzr, [sp, #104]
    8478:	17fffdd5 	b	7bcc <_vfiprintf_r+0xcac>
    847c:	f9403fe2 	ldr	x2, [sp, #120]
    8480:	b94067e0 	ldr	w0, [sp, #100]
    8484:	b90067e1 	str	w1, [sp, #100]
    8488:	8b20c040 	add	x0, x2, w0, sxtw
    848c:	17fffe21 	b	7d10 <_vfiprintf_r+0xdf0>
    8490:	f9403fe2 	ldr	x2, [sp, #120]
    8494:	b94067e0 	ldr	w0, [sp, #100]
    8498:	b90067e1 	str	w1, [sp, #100]
    849c:	8b20c042 	add	x2, x2, w0, sxtw
    84a0:	aa1803e0 	mov	x0, x24
    84a4:	aa0203f8 	mov	x24, x2
    84a8:	17fffd87 	b	7ac4 <_vfiprintf_r+0xba4>
    84ac:	f9403fe4 	ldr	x4, [sp, #120]
    84b0:	f90047f8 	str	x24, [sp, #136]
    84b4:	b94067e2 	ldr	w2, [sp, #100]
    84b8:	b90067e1 	str	w1, [sp, #100]
    84bc:	8b22c082 	add	x2, x4, w2, sxtw
    84c0:	aa0203f8 	mov	x24, x2
    84c4:	17fffd28 	b	7964 <_vfiprintf_r+0xa44>
    84c8:	aa1703fb 	mov	x27, x23
    84cc:	5280002b 	mov	w11, #0x1                   	// #1
    84d0:	52800001 	mov	w1, #0x0                   	// #0
    84d4:	17fffb83 	b	72e0 <_vfiprintf_r+0x3c0>
    84d8:	37f81780 	tbnz	w0, #31, 87c8 <_vfiprintf_r+0x18a8>
    84dc:	91003f01 	add	x1, x24, #0xf
    84e0:	aa1803e0 	mov	x0, x24
    84e4:	927df038 	and	x24, x1, #0xfffffffffffffff8
    84e8:	f9400000 	ldr	x0, [x0]
    84ec:	7940c3e1 	ldrh	w1, [sp, #96]
    84f0:	79000001 	strh	w1, [x0]
    84f4:	17fffac1 	b	6ff8 <_vfiprintf_r+0xd8>
    84f8:	37f81fc0 	tbnz	w0, #31, 88f0 <_vfiprintf_r+0x19d0>
    84fc:	91002f01 	add	x1, x24, #0xb
    8500:	aa1803e0 	mov	x0, x24
    8504:	927df038 	and	x24, x1, #0xfffffffffffffff8
    8508:	b9800001 	ldrsw	x1, [x0]
    850c:	aa0103e0 	mov	x0, x1
    8510:	17fffdcc 	b	7c40 <_vfiprintf_r+0xd20>
    8514:	aa1703fb 	mov	x27, x23
    8518:	5280002b 	mov	w11, #0x1                   	// #1
    851c:	17fffb56 	b	7274 <_vfiprintf_r+0x354>
    8520:	37f81b20 	tbnz	w0, #31, 8884 <_vfiprintf_r+0x1964>
    8524:	aa1803e0 	mov	x0, x24
    8528:	91002f01 	add	x1, x24, #0xb
    852c:	927df038 	and	x24, x1, #0xfffffffffffffff8
    8530:	b9400001 	ldr	w1, [x0]
    8534:	17fffd92 	b	7b7c <_vfiprintf_r+0xc5c>
    8538:	37f81ee1 	tbnz	w1, #31, 8914 <_vfiprintf_r+0x19f4>
    853c:	aa1803e1 	mov	x1, x24
    8540:	91002f02 	add	x2, x24, #0xb
    8544:	927df058 	and	x24, x2, #0xfffffffffffffff8
    8548:	b9400021 	ldr	w1, [x1]
    854c:	17fffecb 	b	8078 <_vfiprintf_r+0x1158>
    8550:	37f81880 	tbnz	w0, #31, 8860 <_vfiprintf_r+0x1940>
    8554:	91002f01 	add	x1, x24, #0xb
    8558:	aa1803e0 	mov	x0, x24
    855c:	927df038 	and	x24, x1, #0xfffffffffffffff8
    8560:	b9400001 	ldr	w1, [x0]
    8564:	52800020 	mov	w0, #0x1                   	// #1
    8568:	17fffd87 	b	7b84 <_vfiprintf_r+0xc64>
    856c:	b94067e0 	ldr	w0, [sp, #100]
    8570:	11002001 	add	w1, w0, #0x8
    8574:	7100003f 	cmp	w1, #0x0
    8578:	54001ecd 	b.le	8950 <_vfiprintf_r+0x1a30>
    857c:	91002f02 	add	x2, x24, #0xb
    8580:	aa1803e0 	mov	x0, x24
    8584:	927df058 	and	x24, x2, #0xfffffffffffffff8
    8588:	b90067e1 	str	w1, [sp, #100]
    858c:	17fffe4a 	b	7eb4 <_vfiprintf_r+0xf94>
    8590:	b94067e1 	ldr	w1, [sp, #100]
    8594:	11002022 	add	w2, w1, #0x8
    8598:	7100005f 	cmp	w2, #0x0
    859c:	54001f0d 	b.le	897c <_vfiprintf_r+0x1a5c>
    85a0:	aa1803e1 	mov	x1, x24
    85a4:	91002f04 	add	x4, x24, #0xb
    85a8:	927df098 	and	x24, x4, #0xfffffffffffffff8
    85ac:	b90067e2 	str	w2, [sp, #100]
    85b0:	79400021 	ldrh	w1, [x1]
    85b4:	17fffeb1 	b	8078 <_vfiprintf_r+0x1158>
    85b8:	f9403fe2 	ldr	x2, [sp, #120]
    85bc:	b94067e0 	ldr	w0, [sp, #100]
    85c0:	b90067e1 	str	w1, [sp, #100]
    85c4:	8b20c040 	add	x0, x2, w0, sxtw
    85c8:	17fffd0f 	b	7a04 <_vfiprintf_r+0xae4>
    85cc:	b94067e0 	ldr	w0, [sp, #100]
    85d0:	11002001 	add	w1, w0, #0x8
    85d4:	7100003f 	cmp	w1, #0x0
    85d8:	54001b2d 	b.le	893c <_vfiprintf_r+0x1a1c>
    85dc:	91002f02 	add	x2, x24, #0xb
    85e0:	aa1803e0 	mov	x0, x24
    85e4:	927df058 	and	x24, x2, #0xfffffffffffffff8
    85e8:	b90067e1 	str	w1, [sp, #100]
    85ec:	17fffe41 	b	7ef0 <_vfiprintf_r+0xfd0>
    85f0:	b94067e0 	ldr	w0, [sp, #100]
    85f4:	11002001 	add	w1, w0, #0x8
    85f8:	7100003f 	cmp	w1, #0x0
    85fc:	54001b4d 	b.le	8964 <_vfiprintf_r+0x1a44>
    8600:	aa1803e0 	mov	x0, x24
    8604:	91002f02 	add	x2, x24, #0xb
    8608:	927df058 	and	x24, x2, #0xfffffffffffffff8
    860c:	b90067e1 	str	w1, [sp, #100]
    8610:	79400001 	ldrh	w1, [x0]
    8614:	17fffd5a 	b	7b7c <_vfiprintf_r+0xc5c>
    8618:	11000721 	add	w1, w25, #0x1
    861c:	aa1303e0 	mov	x0, x19
    8620:	b9006be8 	str	w8, [sp, #104]
    8624:	93407c21 	sxtw	x1, w1
    8628:	9400018e 	bl	8c60 <_malloc_r>
    862c:	b9406be8 	ldr	w8, [sp, #104]
    8630:	aa0003fc 	mov	x28, x0
    8634:	b40022a0 	cbz	x0, 8a88 <_vfiprintf_r+0x1b68>
    8638:	f90037e0 	str	x0, [sp, #104]
    863c:	17fffeec 	b	81ec <_vfiprintf_r+0x12cc>
    8640:	f94052c0 	ldr	x0, [x22, #160]
    8644:	9400040b 	bl	9670 <__retarget_lock_release_recursive>
    8648:	17fffa8d 	b	707c <_vfiprintf_r+0x15c>
    864c:	f94047f8 	ldr	x24, [sp, #136]
    8650:	2a0303e4 	mov	w4, w3
    8654:	2a0303f9 	mov	w25, w3
    8658:	52800003 	mov	w3, #0x0                   	// #0
    865c:	17fffd5c 	b	7bcc <_vfiprintf_r+0xcac>
    8660:	b94067e0 	ldr	w0, [sp, #100]
    8664:	11002001 	add	w1, w0, #0x8
    8668:	7100003f 	cmp	w1, #0x0
    866c:	5400076d 	b.le	8758 <_vfiprintf_r+0x1838>
    8670:	91002f02 	add	x2, x24, #0xb
    8674:	aa1803e0 	mov	x0, x24
    8678:	927df058 	and	x24, x2, #0xfffffffffffffff8
    867c:	b90067e1 	str	w1, [sp, #100]
    8680:	17fffe45 	b	7f94 <_vfiprintf_r+0x1074>
    8684:	f9404fe0 	ldr	x0, [sp, #152]
    8688:	b9006be4 	str	w4, [sp, #104]
    868c:	f94057e1 	ldr	x1, [sp, #168]
    8690:	cb00039c 	sub	x28, x28, x0
    8694:	aa0003e2 	mov	x2, x0
    8698:	aa1c03e0 	mov	x0, x28
    869c:	b9008be8 	str	w8, [sp, #136]
    86a0:	f9004be5 	str	x5, [sp, #144]
    86a4:	f90053e7 	str	x7, [sp, #160]
    86a8:	b900b3e3 	str	w3, [sp, #176]
    86ac:	94001349 	bl	d3d0 <strncpy>
    86b0:	394006c0 	ldrb	w0, [x22, #1]
    86b4:	b202e7e6 	mov	x6, #0xcccccccccccccccc    	// #-3689348814741910324
    86b8:	f9404be5 	ldr	x5, [sp, #144]
    86bc:	7100001f 	cmp	w0, #0x0
    86c0:	f94053e7 	ldr	x7, [sp, #160]
    86c4:	9a9606d6 	cinc	x22, x22, ne	// ne = any
    86c8:	b9406be4 	ldr	w4, [sp, #104]
    86cc:	5280000b 	mov	w11, #0x0                   	// #0
    86d0:	b9408be8 	ldr	w8, [sp, #136]
    86d4:	f29999a6 	movk	x6, #0xcccd
    86d8:	b940b3e3 	ldr	w3, [sp, #176]
    86dc:	17fffeea 	b	8284 <_vfiprintf_r+0x1364>
    86e0:	f9403fe2 	ldr	x2, [sp, #120]
    86e4:	b94067e0 	ldr	w0, [sp, #100]
    86e8:	b90067e1 	str	w1, [sp, #100]
    86ec:	8b20c040 	add	x0, x2, w0, sxtw
    86f0:	17fffd70 	b	7cb0 <_vfiprintf_r+0xd90>
    86f4:	aa1c03e0 	mov	x0, x28
    86f8:	b900b3e8 	str	w8, [sp, #176]
    86fc:	97ffe8b1 	bl	29c0 <strlen>
    8700:	7100001f 	cmp	w0, #0x0
    8704:	f94047f8 	ldr	x24, [sp, #136]
    8708:	2a0003f9 	mov	w25, w0
    870c:	b940b3e8 	ldr	w8, [sp, #176]
    8710:	1a9fa004 	csel	w4, w0, wzr, ge	// ge = tcont
    8714:	52800003 	mov	w3, #0x0                   	// #0
    8718:	f90037ff 	str	xzr, [sp, #104]
    871c:	17fffd2c 	b	7bcc <_vfiprintf_r+0xcac>
    8720:	9000004b 	adrp	x11, 10000 <__env_lock>
    8724:	2a0203ef 	mov	w15, w2
    8728:	9129016b 	add	x11, x11, #0xa40
    872c:	17fffc24 	b	77bc <_vfiprintf_r+0x89c>
    8730:	9000004b 	adrp	x11, 10000 <__env_lock>
    8734:	11000446 	add	w6, w2, #0x1
    8738:	9129016b 	add	x11, x11, #0xa40
    873c:	17fffc5e 	b	78b4 <_vfiprintf_r+0x994>
    8740:	aa1303e0 	mov	x0, x19
    8744:	910443e2 	add	x2, sp, #0x110
    8748:	aa1603e1 	mov	x1, x22
    874c:	97fff9b5 	bl	6e20 <__sprint_r.part.0>
    8750:	34ffdf60 	cbz	w0, 833c <_vfiprintf_r+0x141c>
    8754:	17fffa96 	b	71ac <_vfiprintf_r+0x28c>
    8758:	f9403fe2 	ldr	x2, [sp, #120]
    875c:	b94067e0 	ldr	w0, [sp, #100]
    8760:	b90067e1 	str	w1, [sp, #100]
    8764:	8b20c040 	add	x0, x2, w0, sxtw
    8768:	17fffe0b 	b	7f94 <_vfiprintf_r+0x1074>
    876c:	9000004a 	adrp	x10, 10000 <__env_lock>
    8770:	2a0b03ed 	mov	w13, w11
    8774:	9128c14a 	add	x10, x10, #0xa30
    8778:	17fffb54 	b	74c8 <_vfiprintf_r+0x5a8>
    877c:	b940b2c0 	ldr	w0, [x22, #176]
    8780:	370000a0 	tbnz	w0, #0, 8794 <_vfiprintf_r+0x1874>
    8784:	794022c0 	ldrh	w0, [x22, #16]
    8788:	37480060 	tbnz	w0, #9, 8794 <_vfiprintf_r+0x1874>
    878c:	f94052c0 	ldr	x0, [x22, #160]
    8790:	940003b8 	bl	9670 <__retarget_lock_release_recursive>
    8794:	12800000 	mov	w0, #0xffffffff            	// #-1
    8798:	b90063e0 	str	w0, [sp, #96]
    879c:	17fffa89 	b	71c0 <_vfiprintf_r+0x2a0>
    87a0:	b94067e1 	ldr	w1, [sp, #100]
    87a4:	11002022 	add	w2, w1, #0x8
    87a8:	7100005f 	cmp	w2, #0x0
    87ac:	540014cd 	b.le	8a44 <_vfiprintf_r+0x1b24>
    87b0:	aa1803e1 	mov	x1, x24
    87b4:	91002f04 	add	x4, x24, #0xb
    87b8:	927df098 	and	x24, x4, #0xfffffffffffffff8
    87bc:	b90067e2 	str	w2, [sp, #100]
    87c0:	39400021 	ldrb	w1, [x1]
    87c4:	17fffe2d 	b	8078 <_vfiprintf_r+0x1158>
    87c8:	b94067e0 	ldr	w0, [sp, #100]
    87cc:	11002001 	add	w1, w0, #0x8
    87d0:	7100003f 	cmp	w1, #0x0
    87d4:	5400144d 	b.le	8a5c <_vfiprintf_r+0x1b3c>
    87d8:	91003f02 	add	x2, x24, #0xf
    87dc:	aa1803e0 	mov	x0, x24
    87e0:	927df058 	and	x24, x2, #0xfffffffffffffff8
    87e4:	b90067e1 	str	w1, [sp, #100]
    87e8:	17ffff40 	b	84e8 <_vfiprintf_r+0x15c8>
    87ec:	b94067e0 	ldr	w0, [sp, #100]
    87f0:	11002001 	add	w1, w0, #0x8
    87f4:	7100003f 	cmp	w1, #0x0
    87f8:	5400150d 	b.le	8a98 <_vfiprintf_r+0x1b78>
    87fc:	91002f02 	add	x2, x24, #0xb
    8800:	aa1803e0 	mov	x0, x24
    8804:	927df058 	and	x24, x2, #0xfffffffffffffff8
    8808:	b90067e1 	str	w1, [sp, #100]
    880c:	17fffed4 	b	835c <_vfiprintf_r+0x143c>
    8810:	b94067e0 	ldr	w0, [sp, #100]
    8814:	11002001 	add	w1, w0, #0x8
    8818:	7100003f 	cmp	w1, #0x0
    881c:	540015cd 	b.le	8ad4 <_vfiprintf_r+0x1bb4>
    8820:	aa1803e0 	mov	x0, x24
    8824:	91002f02 	add	x2, x24, #0xb
    8828:	927df058 	and	x24, x2, #0xfffffffffffffff8
    882c:	b90067e1 	str	w1, [sp, #100]
    8830:	39400001 	ldrb	w1, [x0]
    8834:	17fffcd2 	b	7b7c <_vfiprintf_r+0xc5c>
    8838:	aa1903f6 	mov	x22, x25
    883c:	b940b3e8 	ldr	w8, [sp, #176]
    8840:	2a1403f9 	mov	w25, w20
    8844:	b9406bf4 	ldr	w20, [sp, #104]
    8848:	17fffe64 	b	81d8 <_vfiprintf_r+0x12b8>
    884c:	79c02320 	ldrsh	w0, [x25, #16]
    8850:	aa1903f6 	mov	x22, x25
    8854:	321a0000 	orr	w0, w0, #0x40
    8858:	79002320 	strh	w0, [x25, #16]
    885c:	17fffa55 	b	71b0 <_vfiprintf_r+0x290>
    8860:	b94067e0 	ldr	w0, [sp, #100]
    8864:	11002001 	add	w1, w0, #0x8
    8868:	7100003f 	cmp	w1, #0x0
    886c:	5400120d 	b.le	8aac <_vfiprintf_r+0x1b8c>
    8870:	91002f02 	add	x2, x24, #0xb
    8874:	aa1803e0 	mov	x0, x24
    8878:	927df058 	and	x24, x2, #0xfffffffffffffff8
    887c:	b90067e1 	str	w1, [sp, #100]
    8880:	17ffff38 	b	8560 <_vfiprintf_r+0x1640>
    8884:	b94067e0 	ldr	w0, [sp, #100]
    8888:	11002001 	add	w1, w0, #0x8
    888c:	7100003f 	cmp	w1, #0x0
    8890:	5400138d 	b.le	8b00 <_vfiprintf_r+0x1be0>
    8894:	aa1803e0 	mov	x0, x24
    8898:	91002f02 	add	x2, x24, #0xb
    889c:	927df058 	and	x24, x2, #0xfffffffffffffff8
    88a0:	b90067e1 	str	w1, [sp, #100]
    88a4:	b9400001 	ldr	w1, [x0]
    88a8:	17fffcb5 	b	7b7c <_vfiprintf_r+0xc5c>
    88ac:	37f80740 	tbnz	w0, #31, 8994 <_vfiprintf_r+0x1a74>
    88b0:	91003f01 	add	x1, x24, #0xf
    88b4:	aa1803e0 	mov	x0, x24
    88b8:	927df038 	and	x24, x1, #0xfffffffffffffff8
    88bc:	f9400000 	ldr	x0, [x0]
    88c0:	b94063e1 	ldr	w1, [sp, #96]
    88c4:	b9000001 	str	w1, [x0]
    88c8:	17fff9cc 	b	6ff8 <_vfiprintf_r+0xd8>
    88cc:	b94067e0 	ldr	w0, [sp, #100]
    88d0:	11002001 	add	w1, w0, #0x8
    88d4:	7100003f 	cmp	w1, #0x0
    88d8:	540010ad 	b.le	8aec <_vfiprintf_r+0x1bcc>
    88dc:	91002f02 	add	x2, x24, #0xb
    88e0:	aa1803e0 	mov	x0, x24
    88e4:	927df058 	and	x24, x2, #0xfffffffffffffff8
    88e8:	b90067e1 	str	w1, [sp, #100]
    88ec:	17fffec1 	b	83f0 <_vfiprintf_r+0x14d0>
    88f0:	b94067e0 	ldr	w0, [sp, #100]
    88f4:	11002001 	add	w1, w0, #0x8
    88f8:	7100003f 	cmp	w1, #0x0
    88fc:	54000e2d 	b.le	8ac0 <_vfiprintf_r+0x1ba0>
    8900:	91002f02 	add	x2, x24, #0xb
    8904:	aa1803e0 	mov	x0, x24
    8908:	927df058 	and	x24, x2, #0xfffffffffffffff8
    890c:	b90067e1 	str	w1, [sp, #100]
    8910:	17fffefe 	b	8508 <_vfiprintf_r+0x15e8>
    8914:	b94067e1 	ldr	w1, [sp, #100]
    8918:	11002022 	add	w2, w1, #0x8
    891c:	7100005f 	cmp	w2, #0x0
    8920:	54000a8d 	b.le	8a70 <_vfiprintf_r+0x1b50>
    8924:	aa1803e1 	mov	x1, x24
    8928:	91002f04 	add	x4, x24, #0xb
    892c:	927df098 	and	x24, x4, #0xfffffffffffffff8
    8930:	b90067e2 	str	w2, [sp, #100]
    8934:	b9400021 	ldr	w1, [x1]
    8938:	17fffdd0 	b	8078 <_vfiprintf_r+0x1158>
    893c:	f9403fe2 	ldr	x2, [sp, #120]
    8940:	b94067e0 	ldr	w0, [sp, #100]
    8944:	b90067e1 	str	w1, [sp, #100]
    8948:	8b20c040 	add	x0, x2, w0, sxtw
    894c:	17fffd69 	b	7ef0 <_vfiprintf_r+0xfd0>
    8950:	f9403fe2 	ldr	x2, [sp, #120]
    8954:	b94067e0 	ldr	w0, [sp, #100]
    8958:	b90067e1 	str	w1, [sp, #100]
    895c:	8b20c040 	add	x0, x2, w0, sxtw
    8960:	17fffd55 	b	7eb4 <_vfiprintf_r+0xf94>
    8964:	f9403fe2 	ldr	x2, [sp, #120]
    8968:	b94067e0 	ldr	w0, [sp, #100]
    896c:	b90067e1 	str	w1, [sp, #100]
    8970:	8b20c040 	add	x0, x2, w0, sxtw
    8974:	79400001 	ldrh	w1, [x0]
    8978:	17fffc81 	b	7b7c <_vfiprintf_r+0xc5c>
    897c:	f9403fe4 	ldr	x4, [sp, #120]
    8980:	b94067e1 	ldr	w1, [sp, #100]
    8984:	b90067e2 	str	w2, [sp, #100]
    8988:	8b21c081 	add	x1, x4, w1, sxtw
    898c:	79400021 	ldrh	w1, [x1]
    8990:	17fffdba 	b	8078 <_vfiprintf_r+0x1158>
    8994:	b94067e0 	ldr	w0, [sp, #100]
    8998:	11002001 	add	w1, w0, #0x8
    899c:	7100003f 	cmp	w1, #0x0
    89a0:	54000bcd 	b.le	8b18 <_vfiprintf_r+0x1bf8>
    89a4:	91003f02 	add	x2, x24, #0xf
    89a8:	aa1803e0 	mov	x0, x24
    89ac:	927df058 	and	x24, x2, #0xfffffffffffffff8
    89b0:	b90067e1 	str	w1, [sp, #100]
    89b4:	17ffffc2 	b	88bc <_vfiprintf_r+0x199c>
    89b8:	b94067e0 	ldr	w0, [sp, #100]
    89bc:	11002001 	add	w1, w0, #0x8
    89c0:	7100003f 	cmp	w1, #0x0
    89c4:	5400024d 	b.le	8a0c <_vfiprintf_r+0x1aec>
    89c8:	91003f02 	add	x2, x24, #0xf
    89cc:	aa1803e0 	mov	x0, x24
    89d0:	927df058 	and	x24, x2, #0xfffffffffffffff8
    89d4:	b90067e1 	str	w1, [sp, #100]
    89d8:	17fffcae 	b	7c90 <_vfiprintf_r+0xd70>
    89dc:	b94067e0 	ldr	w0, [sp, #100]
    89e0:	37f80200 	tbnz	w0, #31, 8a20 <_vfiprintf_r+0x1b00>
    89e4:	91002f01 	add	x1, x24, #0xb
    89e8:	927df021 	and	x1, x1, #0xfffffffffffffff8
    89ec:	b9400303 	ldr	w3, [x24]
    89f0:	aa0103f8 	mov	x24, x1
    89f4:	b90067e0 	str	w0, [sp, #100]
    89f8:	7100007f 	cmp	w3, #0x0
    89fc:	39400740 	ldrb	w0, [x26, #1]
    8a00:	5a9fa07c 	csinv	w28, w3, wzr, ge	// ge = tcont
    8a04:	aa0203fa 	mov	x26, x2
    8a08:	17fff9d6 	b	7160 <_vfiprintf_r+0x240>
    8a0c:	f9403fe2 	ldr	x2, [sp, #120]
    8a10:	b94067e0 	ldr	w0, [sp, #100]
    8a14:	b90067e1 	str	w1, [sp, #100]
    8a18:	8b20c040 	add	x0, x2, w0, sxtw
    8a1c:	17fffc9d 	b	7c90 <_vfiprintf_r+0xd70>
    8a20:	b94067e0 	ldr	w0, [sp, #100]
    8a24:	11002000 	add	w0, w0, #0x8
    8a28:	7100001f 	cmp	w0, #0x0
    8a2c:	54fffdcc 	b.gt	89e4 <_vfiprintf_r+0x1ac4>
    8a30:	f9403fe4 	ldr	x4, [sp, #120]
    8a34:	aa1803e1 	mov	x1, x24
    8a38:	b94067e3 	ldr	w3, [sp, #100]
    8a3c:	8b23c098 	add	x24, x4, w3, sxtw
    8a40:	17ffffeb 	b	89ec <_vfiprintf_r+0x1acc>
    8a44:	f9403fe4 	ldr	x4, [sp, #120]
    8a48:	b94067e1 	ldr	w1, [sp, #100]
    8a4c:	b90067e2 	str	w2, [sp, #100]
    8a50:	8b21c081 	add	x1, x4, w1, sxtw
    8a54:	39400021 	ldrb	w1, [x1]
    8a58:	17fffd88 	b	8078 <_vfiprintf_r+0x1158>
    8a5c:	f9403fe2 	ldr	x2, [sp, #120]
    8a60:	b94067e0 	ldr	w0, [sp, #100]
    8a64:	b90067e1 	str	w1, [sp, #100]
    8a68:	8b20c040 	add	x0, x2, w0, sxtw
    8a6c:	17fffe9f 	b	84e8 <_vfiprintf_r+0x15c8>
    8a70:	f9403fe4 	ldr	x4, [sp, #120]
    8a74:	b94067e1 	ldr	w1, [sp, #100]
    8a78:	b90067e2 	str	w2, [sp, #100]
    8a7c:	8b21c081 	add	x1, x4, w1, sxtw
    8a80:	b9400021 	ldr	w1, [x1]
    8a84:	17fffd7d 	b	8078 <_vfiprintf_r+0x1158>
    8a88:	79c022c0 	ldrsh	w0, [x22, #16]
    8a8c:	321a0000 	orr	w0, w0, #0x40
    8a90:	790022c0 	strh	w0, [x22, #16]
    8a94:	17fff9c7 	b	71b0 <_vfiprintf_r+0x290>
    8a98:	f9403fe2 	ldr	x2, [sp, #120]
    8a9c:	b94067e0 	ldr	w0, [sp, #100]
    8aa0:	b90067e1 	str	w1, [sp, #100]
    8aa4:	8b20c040 	add	x0, x2, w0, sxtw
    8aa8:	17fffe2d 	b	835c <_vfiprintf_r+0x143c>
    8aac:	f9403fe2 	ldr	x2, [sp, #120]
    8ab0:	b94067e0 	ldr	w0, [sp, #100]
    8ab4:	b90067e1 	str	w1, [sp, #100]
    8ab8:	8b20c040 	add	x0, x2, w0, sxtw
    8abc:	17fffea9 	b	8560 <_vfiprintf_r+0x1640>
    8ac0:	f9403fe2 	ldr	x2, [sp, #120]
    8ac4:	b94067e0 	ldr	w0, [sp, #100]
    8ac8:	b90067e1 	str	w1, [sp, #100]
    8acc:	8b20c040 	add	x0, x2, w0, sxtw
    8ad0:	17fffe8e 	b	8508 <_vfiprintf_r+0x15e8>
    8ad4:	f9403fe2 	ldr	x2, [sp, #120]
    8ad8:	b94067e0 	ldr	w0, [sp, #100]
    8adc:	b90067e1 	str	w1, [sp, #100]
    8ae0:	8b20c040 	add	x0, x2, w0, sxtw
    8ae4:	39400001 	ldrb	w1, [x0]
    8ae8:	17fffc25 	b	7b7c <_vfiprintf_r+0xc5c>
    8aec:	f9403fe2 	ldr	x2, [sp, #120]
    8af0:	b94067e0 	ldr	w0, [sp, #100]
    8af4:	b90067e1 	str	w1, [sp, #100]
    8af8:	8b20c040 	add	x0, x2, w0, sxtw
    8afc:	17fffe3d 	b	83f0 <_vfiprintf_r+0x14d0>
    8b00:	f9403fe2 	ldr	x2, [sp, #120]
    8b04:	b94067e0 	ldr	w0, [sp, #100]
    8b08:	b90067e1 	str	w1, [sp, #100]
    8b0c:	8b20c040 	add	x0, x2, w0, sxtw
    8b10:	b9400001 	ldr	w1, [x0]
    8b14:	17fffc1a 	b	7b7c <_vfiprintf_r+0xc5c>
    8b18:	f9403fe2 	ldr	x2, [sp, #120]
    8b1c:	b94067e0 	ldr	w0, [sp, #100]
    8b20:	b90067e1 	str	w1, [sp, #100]
    8b24:	8b20c040 	add	x0, x2, w0, sxtw
    8b28:	17ffff65 	b	88bc <_vfiprintf_r+0x199c>
    8b2c:	794022c0 	ldrh	w0, [x22, #16]
    8b30:	321a0000 	orr	w0, w0, #0x40
    8b34:	790022c0 	strh	w0, [x22, #16]
    8b38:	17fff998 	b	7198 <_vfiprintf_r+0x278>
    8b3c:	00000000 	udf	#0

0000000000008b40 <vfiprintf>:
    8b40:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    8b44:	b0000044 	adrp	x4, 11000 <JIS_action_table>
    8b48:	aa0003e3 	mov	x3, x0
    8b4c:	910003fd 	mov	x29, sp
    8b50:	ad400440 	ldp	q0, q1, [x2]
    8b54:	aa0103e2 	mov	x2, x1
    8b58:	f9413c80 	ldr	x0, [x4, #632]
    8b5c:	aa0303e1 	mov	x1, x3
    8b60:	910043e3 	add	x3, sp, #0x10
    8b64:	ad0087e0 	stp	q0, q1, [sp, #16]
    8b68:	97fff8ee 	bl	6f20 <_vfiprintf_r>
    8b6c:	a8c37bfd 	ldp	x29, x30, [sp], #48
    8b70:	d65f03c0 	ret
	...

0000000000008b80 <__sbprintf>:
    8b80:	d11443ff 	sub	sp, sp, #0x510
    8b84:	a9007bfd 	stp	x29, x30, [sp]
    8b88:	910003fd 	mov	x29, sp
    8b8c:	a90153f3 	stp	x19, x20, [sp, #16]
    8b90:	aa0103f3 	mov	x19, x1
    8b94:	79402021 	ldrh	w1, [x1, #16]
    8b98:	aa0303f4 	mov	x20, x3
    8b9c:	910443e3 	add	x3, sp, #0x110
    8ba0:	f9401a66 	ldr	x6, [x19, #48]
    8ba4:	121e7821 	and	w1, w1, #0xfffffffd
    8ba8:	f9402265 	ldr	x5, [x19, #64]
    8bac:	a9025bf5 	stp	x21, x22, [sp, #32]
    8bb0:	79402667 	ldrh	w7, [x19, #18]
    8bb4:	b940b264 	ldr	w4, [x19, #176]
    8bb8:	aa0203f6 	mov	x22, x2
    8bbc:	52808002 	mov	w2, #0x400                 	// #1024
    8bc0:	aa0003f5 	mov	x21, x0
    8bc4:	9103e3e0 	add	x0, sp, #0xf8
    8bc8:	f9002fe3 	str	x3, [sp, #88]
    8bcc:	b90067e2 	str	w2, [sp, #100]
    8bd0:	7900d3e1 	strh	w1, [sp, #104]
    8bd4:	7900d7e7 	strh	w7, [sp, #106]
    8bd8:	f9003be3 	str	x3, [sp, #112]
    8bdc:	b9007be2 	str	w2, [sp, #120]
    8be0:	b90083ff 	str	wzr, [sp, #128]
    8be4:	f90047e6 	str	x6, [sp, #136]
    8be8:	f9004fe5 	str	x5, [sp, #152]
    8bec:	b9010be4 	str	w4, [sp, #264]
    8bf0:	94000280 	bl	95f0 <__retarget_lock_init_recursive>
    8bf4:	ad400680 	ldp	q0, q1, [x20]
    8bf8:	aa1603e2 	mov	x2, x22
    8bfc:	9100c3e3 	add	x3, sp, #0x30
    8c00:	aa1503e0 	mov	x0, x21
    8c04:	910163e1 	add	x1, sp, #0x58
    8c08:	ad0187e0 	stp	q0, q1, [sp, #48]
    8c0c:	97fff8c5 	bl	6f20 <_vfiprintf_r>
    8c10:	2a0003f4 	mov	w20, w0
    8c14:	37f800c0 	tbnz	w0, #31, 8c2c <__sbprintf+0xac>
    8c18:	910163e1 	add	x1, sp, #0x58
    8c1c:	aa1503e0 	mov	x0, x21
    8c20:	94000ddc 	bl	c390 <_fflush_r>
    8c24:	7100001f 	cmp	w0, #0x0
    8c28:	5a9f0294 	csinv	w20, w20, wzr, eq	// eq = none
    8c2c:	7940d3e0 	ldrh	w0, [sp, #104]
    8c30:	36300080 	tbz	w0, #6, 8c40 <__sbprintf+0xc0>
    8c34:	79402260 	ldrh	w0, [x19, #16]
    8c38:	321a0000 	orr	w0, w0, #0x40
    8c3c:	79002260 	strh	w0, [x19, #16]
    8c40:	f9407fe0 	ldr	x0, [sp, #248]
    8c44:	94000273 	bl	9610 <__retarget_lock_close_recursive>
    8c48:	a9407bfd 	ldp	x29, x30, [sp]
    8c4c:	2a1403e0 	mov	w0, w20
    8c50:	a94153f3 	ldp	x19, x20, [sp, #16]
    8c54:	a9425bf5 	ldp	x21, x22, [sp, #32]
    8c58:	911443ff 	add	sp, sp, #0x510
    8c5c:	d65f03c0 	ret

0000000000008c60 <_malloc_r>:
    8c60:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
    8c64:	910003fd 	mov	x29, sp
    8c68:	a90153f3 	stp	x19, x20, [sp, #16]
    8c6c:	91005c33 	add	x19, x1, #0x17
    8c70:	a9025bf5 	stp	x21, x22, [sp, #32]
    8c74:	aa0003f5 	mov	x21, x0
    8c78:	a9046bf9 	stp	x25, x26, [sp, #64]
    8c7c:	f100ba7f 	cmp	x19, #0x2e
    8c80:	54000cc8 	b.hi	8e18 <_malloc_r+0x1b8>  // b.pmore
    8c84:	f100803f 	cmp	x1, #0x20
    8c88:	54001928 	b.hi	8fac <_malloc_r+0x34c>  // b.pmore
    8c8c:	94000815 	bl	ace0 <__malloc_lock>
    8c90:	d2800413 	mov	x19, #0x20                  	// #32
    8c94:	d2800a01 	mov	x1, #0x50                  	// #80
    8c98:	52800080 	mov	w0, #0x4                   	// #4
    8c9c:	b0000054 	adrp	x20, 11000 <JIS_action_table>
    8ca0:	91100294 	add	x20, x20, #0x400
    8ca4:	8b010281 	add	x1, x20, x1
    8ca8:	11000800 	add	w0, w0, #0x2
    8cac:	d1004021 	sub	x1, x1, #0x10
    8cb0:	f9400c22 	ldr	x2, [x1, #24]
    8cb4:	eb01005f 	cmp	x2, x1
    8cb8:	54001d61 	b.ne	9064 <_malloc_r+0x404>  // b.any
    8cbc:	f9401285 	ldr	x5, [x20, #32]
    8cc0:	b0000047 	adrp	x7, 11000 <JIS_action_table>
    8cc4:	911040e7 	add	x7, x7, #0x410
    8cc8:	eb0700bf 	cmp	x5, x7
    8ccc:	54000f80 	b.eq	8ebc <_malloc_r+0x25c>  // b.none
    8cd0:	f94004a1 	ldr	x1, [x5, #8]
    8cd4:	927ef421 	and	x1, x1, #0xfffffffffffffffc
    8cd8:	cb130022 	sub	x2, x1, x19
    8cdc:	f1007c5f 	cmp	x2, #0x1f
    8ce0:	540028cc 	b.gt	91f8 <_malloc_r+0x598>
    8ce4:	a9021e87 	stp	x7, x7, [x20, #32]
    8ce8:	b6f81722 	tbz	x2, #63, 8fcc <_malloc_r+0x36c>
    8cec:	f9400686 	ldr	x6, [x20, #8]
    8cf0:	f107fc3f 	cmp	x1, #0x1ff
    8cf4:	54001fc8 	b.hi	90ec <_malloc_r+0x48c>  // b.pmore
    8cf8:	d343fc22 	lsr	x2, x1, #3
    8cfc:	d2800023 	mov	x3, #0x1                   	// #1
    8d00:	11000441 	add	w1, w2, #0x1
    8d04:	13027c42 	asr	w2, w2, #2
    8d08:	531f7821 	lsl	w1, w1, #1
    8d0c:	9ac22062 	lsl	x2, x3, x2
    8d10:	aa0200c6 	orr	x6, x6, x2
    8d14:	8b21ce81 	add	x1, x20, w1, sxtw #3
    8d18:	f85f0422 	ldr	x2, [x1], #-16
    8d1c:	f9000686 	str	x6, [x20, #8]
    8d20:	a90104a2 	stp	x2, x1, [x5, #16]
    8d24:	f9000825 	str	x5, [x1, #16]
    8d28:	f9000c45 	str	x5, [x2, #24]
    8d2c:	13027c01 	asr	w1, w0, #2
    8d30:	d2800024 	mov	x4, #0x1                   	// #1
    8d34:	9ac12084 	lsl	x4, x4, x1
    8d38:	eb06009f 	cmp	x4, x6
    8d3c:	54000cc8 	b.hi	8ed4 <_malloc_r+0x274>  // b.pmore
    8d40:	ea06009f 	tst	x4, x6
    8d44:	540000e1 	b.ne	8d60 <_malloc_r+0x100>  // b.any
    8d48:	121e7400 	and	w0, w0, #0xfffffffc
    8d4c:	d503201f 	nop
    8d50:	d37ff884 	lsl	x4, x4, #1
    8d54:	11001000 	add	w0, w0, #0x4
    8d58:	ea06009f 	tst	x4, x6
    8d5c:	54ffffa0 	b.eq	8d50 <_malloc_r+0xf0>  // b.none
    8d60:	928001ea 	mov	x10, #0xfffffffffffffff0    	// #-16
    8d64:	11000408 	add	w8, w0, #0x1
    8d68:	2a0003e9 	mov	w9, w0
    8d6c:	531f7908 	lsl	w8, w8, #1
    8d70:	8b28cd48 	add	x8, x10, w8, sxtw #3
    8d74:	8b080288 	add	x8, x20, x8
    8d78:	aa0803e5 	mov	x5, x8
    8d7c:	f9400ca1 	ldr	x1, [x5, #24]
    8d80:	14000009 	b	8da4 <_malloc_r+0x144>
    8d84:	f9400422 	ldr	x2, [x1, #8]
    8d88:	aa0103e6 	mov	x6, x1
    8d8c:	f9400c21 	ldr	x1, [x1, #24]
    8d90:	927ef442 	and	x2, x2, #0xfffffffffffffffc
    8d94:	cb130043 	sub	x3, x2, x19
    8d98:	f1007c7f 	cmp	x3, #0x1f
    8d9c:	54001f0c 	b.gt	917c <_malloc_r+0x51c>
    8da0:	b6f820c3 	tbz	x3, #63, 91b8 <_malloc_r+0x558>
    8da4:	eb0100bf 	cmp	x5, x1
    8da8:	54fffee1 	b.ne	8d84 <_malloc_r+0x124>  // b.any
    8dac:	7100f93f 	cmp	w9, #0x3e
    8db0:	5400252d 	b.le	9254 <_malloc_r+0x5f4>
    8db4:	910040a5 	add	x5, x5, #0x10
    8db8:	11000529 	add	w9, w9, #0x1
    8dbc:	f240053f 	tst	x9, #0x3
    8dc0:	54fffde1 	b.ne	8d7c <_malloc_r+0x11c>  // b.any
    8dc4:	14000005 	b	8dd8 <_malloc_r+0x178>
    8dc8:	f85f0501 	ldr	x1, [x8], #-16
    8dcc:	51000400 	sub	w0, w0, #0x1
    8dd0:	eb08003f 	cmp	x1, x8
    8dd4:	54003561 	b.ne	9480 <_malloc_r+0x820>  // b.any
    8dd8:	f240041f 	tst	x0, #0x3
    8ddc:	54ffff61 	b.ne	8dc8 <_malloc_r+0x168>  // b.any
    8de0:	f9400680 	ldr	x0, [x20, #8]
    8de4:	8a240000 	bic	x0, x0, x4
    8de8:	f9000680 	str	x0, [x20, #8]
    8dec:	d37ff884 	lsl	x4, x4, #1
    8df0:	d1000481 	sub	x1, x4, #0x1
    8df4:	eb00003f 	cmp	x1, x0
    8df8:	54000083 	b.cc	8e08 <_malloc_r+0x1a8>  // b.lo, b.ul, b.last
    8dfc:	14000036 	b	8ed4 <_malloc_r+0x274>
    8e00:	d37ff884 	lsl	x4, x4, #1
    8e04:	11001129 	add	w9, w9, #0x4
    8e08:	ea00009f 	tst	x4, x0
    8e0c:	54ffffa0 	b.eq	8e00 <_malloc_r+0x1a0>  // b.none
    8e10:	2a0903e0 	mov	w0, w9
    8e14:	17ffffd4 	b	8d64 <_malloc_r+0x104>
    8e18:	927cee73 	and	x19, x19, #0xfffffffffffffff0
    8e1c:	b2407be2 	mov	x2, #0x7fffffff            	// #2147483647
    8e20:	eb02027f 	cmp	x19, x2
    8e24:	fa539022 	ccmp	x1, x19, #0x2, ls	// ls = plast
    8e28:	54000c28 	b.hi	8fac <_malloc_r+0x34c>  // b.pmore
    8e2c:	940007ad 	bl	ace0 <__malloc_lock>
    8e30:	f107de7f 	cmp	x19, #0x1f7
    8e34:	54001d89 	b.ls	91e4 <_malloc_r+0x584>  // b.plast
    8e38:	d349fe61 	lsr	x1, x19, #9
    8e3c:	b4000c01 	cbz	x1, 8fbc <_malloc_r+0x35c>
    8e40:	f100103f 	cmp	x1, #0x4
    8e44:	54001888 	b.hi	9154 <_malloc_r+0x4f4>  // b.pmore
    8e48:	d346fe61 	lsr	x1, x19, #6
    8e4c:	1100e420 	add	w0, w1, #0x39
    8e50:	1100e026 	add	w6, w1, #0x38
    8e54:	531f7805 	lsl	w5, w0, #1
    8e58:	937d7ca5 	sbfiz	x5, x5, #3, #32
    8e5c:	b0000054 	adrp	x20, 11000 <JIS_action_table>
    8e60:	91100294 	add	x20, x20, #0x400
    8e64:	8b050285 	add	x5, x20, x5
    8e68:	d10040a5 	sub	x5, x5, #0x10
    8e6c:	f9400ca2 	ldr	x2, [x5, #24]
    8e70:	eb0200bf 	cmp	x5, x2
    8e74:	540000e1 	b.ne	8e90 <_malloc_r+0x230>  // b.any
    8e78:	17ffff91 	b	8cbc <_malloc_r+0x5c>
    8e7c:	f9400c44 	ldr	x4, [x2, #24]
    8e80:	b6f81163 	tbz	x3, #63, 90ac <_malloc_r+0x44c>
    8e84:	aa0403e2 	mov	x2, x4
    8e88:	eb0400bf 	cmp	x5, x4
    8e8c:	54fff180 	b.eq	8cbc <_malloc_r+0x5c>  // b.none
    8e90:	f9400441 	ldr	x1, [x2, #8]
    8e94:	927ef421 	and	x1, x1, #0xfffffffffffffffc
    8e98:	cb130023 	sub	x3, x1, x19
    8e9c:	f1007c7f 	cmp	x3, #0x1f
    8ea0:	54fffeed 	b.le	8e7c <_malloc_r+0x21c>
    8ea4:	f9401285 	ldr	x5, [x20, #32]
    8ea8:	b0000047 	adrp	x7, 11000 <JIS_action_table>
    8eac:	911040e7 	add	x7, x7, #0x410
    8eb0:	2a0603e0 	mov	w0, w6
    8eb4:	eb0700bf 	cmp	x5, x7
    8eb8:	54fff0c1 	b.ne	8cd0 <_malloc_r+0x70>  // b.any
    8ebc:	f9400686 	ldr	x6, [x20, #8]
    8ec0:	13027c01 	asr	w1, w0, #2
    8ec4:	d2800024 	mov	x4, #0x1                   	// #1
    8ec8:	9ac12084 	lsl	x4, x4, x1
    8ecc:	eb06009f 	cmp	x4, x6
    8ed0:	54fff389 	b.ls	8d40 <_malloc_r+0xe0>  // b.plast
    8ed4:	f9400a9a 	ldr	x26, [x20, #16]
    8ed8:	a90363f7 	stp	x23, x24, [sp, #48]
    8edc:	f9400741 	ldr	x1, [x26, #8]
    8ee0:	927ef437 	and	x23, x1, #0xfffffffffffffffc
    8ee4:	cb1302e0 	sub	x0, x23, x19
    8ee8:	f1007c1f 	cmp	x0, #0x1f
    8eec:	fa53c2e0 	ccmp	x23, x19, #0x0, gt
    8ef0:	540009a2 	b.cs	9024 <_malloc_r+0x3c4>  // b.hs, b.nlast
    8ef4:	90001fc1 	adrp	x1, 400000 <__sf+0x10>
    8ef8:	a90573fb 	stp	x27, x28, [sp, #80]
    8efc:	b000005c 	adrp	x28, 11000 <JIS_action_table>
    8f00:	f9412c21 	ldr	x1, [x1, #600]
    8f04:	d28203e3 	mov	x3, #0x101f                	// #4127
    8f08:	f941fb82 	ldr	x2, [x28, #1008]
    8f0c:	8b010261 	add	x1, x19, x1
    8f10:	8b030036 	add	x22, x1, x3
    8f14:	91008021 	add	x1, x1, #0x20
    8f18:	b100045f 	cmn	x2, #0x1
    8f1c:	9274ced6 	and	x22, x22, #0xfffffffffffff000
    8f20:	9a8112d6 	csel	x22, x22, x1, ne	// ne = any
    8f24:	aa1503e0 	mov	x0, x21
    8f28:	aa1603e1 	mov	x1, x22
    8f2c:	8b17035b 	add	x27, x26, x23
    8f30:	94001508 	bl	e350 <_sbrk_r>
    8f34:	aa0003f8 	mov	x24, x0
    8f38:	b100041f 	cmn	x0, #0x1
    8f3c:	54000660 	b.eq	9008 <_malloc_r+0x3a8>  // b.none
    8f40:	eb00037f 	cmp	x27, x0
    8f44:	540005e8 	b.hi	9000 <_malloc_r+0x3a0>  // b.pmore
    8f48:	90001fd9 	adrp	x25, 400000 <__sf+0x10>
    8f4c:	b9422323 	ldr	w3, [x25, #544]
    8f50:	0b160063 	add	w3, w3, w22
    8f54:	b9022323 	str	w3, [x25, #544]
    8f58:	2a0303e0 	mov	w0, w3
    8f5c:	540018a1 	b.ne	9270 <_malloc_r+0x610>  // b.any
    8f60:	f2402f1f 	tst	x24, #0xfff
    8f64:	54001861 	b.ne	9270 <_malloc_r+0x610>  // b.any
    8f68:	f9400a98 	ldr	x24, [x20, #16]
    8f6c:	8b1602f6 	add	x22, x23, x22
    8f70:	b24002d6 	orr	x22, x22, #0x1
    8f74:	f9000716 	str	x22, [x24, #8]
    8f78:	90001fc0 	adrp	x0, 400000 <__sf+0x10>
    8f7c:	93407c63 	sxtw	x3, w3
    8f80:	f9412801 	ldr	x1, [x0, #592]
    8f84:	eb01007f 	cmp	x3, x1
    8f88:	54000049 	b.ls	8f90 <_malloc_r+0x330>  // b.plast
    8f8c:	f9012803 	str	x3, [x0, #592]
    8f90:	90001fc0 	adrp	x0, 400000 <__sf+0x10>
    8f94:	f9412401 	ldr	x1, [x0, #584]
    8f98:	eb01007f 	cmp	x3, x1
    8f9c:	54000049 	b.ls	8fa4 <_malloc_r+0x344>  // b.plast
    8fa0:	f9012403 	str	x3, [x0, #584]
    8fa4:	aa1803fa 	mov	x26, x24
    8fa8:	1400001a 	b	9010 <_malloc_r+0x3b0>
    8fac:	52800180 	mov	w0, #0xc                   	// #12
    8fb0:	d280001a 	mov	x26, #0x0                   	// #0
    8fb4:	b90002a0 	str	w0, [x21]
    8fb8:	1400000c 	b	8fe8 <_malloc_r+0x388>
    8fbc:	d2808005 	mov	x5, #0x400                 	// #1024
    8fc0:	52800800 	mov	w0, #0x40                  	// #64
    8fc4:	528007e6 	mov	w6, #0x3f                  	// #63
    8fc8:	17ffffa5 	b	8e5c <_malloc_r+0x1fc>
    8fcc:	8b0100a1 	add	x1, x5, x1
    8fd0:	aa1503e0 	mov	x0, x21
    8fd4:	910040ba 	add	x26, x5, #0x10
    8fd8:	f9400422 	ldr	x2, [x1, #8]
    8fdc:	b2400042 	orr	x2, x2, #0x1
    8fe0:	f9000422 	str	x2, [x1, #8]
    8fe4:	94000743 	bl	acf0 <__malloc_unlock>
    8fe8:	a94153f3 	ldp	x19, x20, [sp, #16]
    8fec:	aa1a03e0 	mov	x0, x26
    8ff0:	a9425bf5 	ldp	x21, x22, [sp, #32]
    8ff4:	a9446bf9 	ldp	x25, x26, [sp, #64]
    8ff8:	a8c67bfd 	ldp	x29, x30, [sp], #96
    8ffc:	d65f03c0 	ret
    9000:	eb14035f 	cmp	x26, x20
    9004:	540012e0 	b.eq	9260 <_malloc_r+0x600>  // b.none
    9008:	f9400a9a 	ldr	x26, [x20, #16]
    900c:	f9400756 	ldr	x22, [x26, #8]
    9010:	927ef6c0 	and	x0, x22, #0xfffffffffffffffc
    9014:	eb130000 	subs	x0, x0, x19
    9018:	fa5f2804 	ccmp	x0, #0x1f, #0x4, cs	// cs = hs, nlast
    901c:	54001bad 	b.le	9390 <_malloc_r+0x730>
    9020:	a94573fb 	ldp	x27, x28, [sp, #80]
    9024:	8b130343 	add	x3, x26, x19
    9028:	b2400261 	orr	x1, x19, #0x1
    902c:	f9000741 	str	x1, [x26, #8]
    9030:	f9000a83 	str	x3, [x20, #16]
    9034:	b2400000 	orr	x0, x0, #0x1
    9038:	f9000460 	str	x0, [x3, #8]
    903c:	9100435a 	add	x26, x26, #0x10
    9040:	aa1503e0 	mov	x0, x21
    9044:	9400072b 	bl	acf0 <__malloc_unlock>
    9048:	a94153f3 	ldp	x19, x20, [sp, #16]
    904c:	aa1a03e0 	mov	x0, x26
    9050:	a9425bf5 	ldp	x21, x22, [sp, #32]
    9054:	a94363f7 	ldp	x23, x24, [sp, #48]
    9058:	a9446bf9 	ldp	x25, x26, [sp, #64]
    905c:	a8c67bfd 	ldp	x29, x30, [sp], #96
    9060:	d65f03c0 	ret
    9064:	a9409041 	ldp	x1, x4, [x2, #8]
    9068:	9100405a 	add	x26, x2, #0x10
    906c:	f9400c43 	ldr	x3, [x2, #24]
    9070:	aa1503e0 	mov	x0, x21
    9074:	927ef421 	and	x1, x1, #0xfffffffffffffffc
    9078:	8b010041 	add	x1, x2, x1
    907c:	f9400422 	ldr	x2, [x1, #8]
    9080:	f9000c83 	str	x3, [x4, #24]
    9084:	f9000864 	str	x4, [x3, #16]
    9088:	b2400042 	orr	x2, x2, #0x1
    908c:	f9000422 	str	x2, [x1, #8]
    9090:	94000718 	bl	acf0 <__malloc_unlock>
    9094:	a94153f3 	ldp	x19, x20, [sp, #16]
    9098:	aa1a03e0 	mov	x0, x26
    909c:	a9425bf5 	ldp	x21, x22, [sp, #32]
    90a0:	a9446bf9 	ldp	x25, x26, [sp, #64]
    90a4:	a8c67bfd 	ldp	x29, x30, [sp], #96
    90a8:	d65f03c0 	ret
    90ac:	8b010041 	add	x1, x2, x1
    90b0:	9100405a 	add	x26, x2, #0x10
    90b4:	f9400843 	ldr	x3, [x2, #16]
    90b8:	aa1503e0 	mov	x0, x21
    90bc:	f9400422 	ldr	x2, [x1, #8]
    90c0:	f9000c64 	str	x4, [x3, #24]
    90c4:	b2400042 	orr	x2, x2, #0x1
    90c8:	f9000883 	str	x3, [x4, #16]
    90cc:	f9000422 	str	x2, [x1, #8]
    90d0:	94000708 	bl	acf0 <__malloc_unlock>
    90d4:	a94153f3 	ldp	x19, x20, [sp, #16]
    90d8:	aa1a03e0 	mov	x0, x26
    90dc:	a9425bf5 	ldp	x21, x22, [sp, #32]
    90e0:	a9446bf9 	ldp	x25, x26, [sp, #64]
    90e4:	a8c67bfd 	ldp	x29, x30, [sp], #96
    90e8:	d65f03c0 	ret
    90ec:	d349fc22 	lsr	x2, x1, #9
    90f0:	f127fc3f 	cmp	x1, #0x9ff
    90f4:	540009a9 	b.ls	9228 <_malloc_r+0x5c8>  // b.plast
    90f8:	f100505f 	cmp	x2, #0x14
    90fc:	54001568 	b.hi	93a8 <_malloc_r+0x748>  // b.pmore
    9100:	11017044 	add	w4, w2, #0x5c
    9104:	11016c43 	add	w3, w2, #0x5b
    9108:	531f7884 	lsl	w4, w4, #1
    910c:	937d7c84 	sbfiz	x4, x4, #3, #32
    9110:	8b040284 	add	x4, x20, x4
    9114:	f85f0482 	ldr	x2, [x4], #-16
    9118:	eb02009f 	cmp	x4, x2
    911c:	540000a1 	b.ne	9130 <_malloc_r+0x4d0>  // b.any
    9120:	1400008a 	b	9348 <_malloc_r+0x6e8>
    9124:	f9400842 	ldr	x2, [x2, #16]
    9128:	eb02009f 	cmp	x4, x2
    912c:	540000a0 	b.eq	9140 <_malloc_r+0x4e0>  // b.none
    9130:	f9400443 	ldr	x3, [x2, #8]
    9134:	927ef463 	and	x3, x3, #0xfffffffffffffffc
    9138:	eb01007f 	cmp	x3, x1
    913c:	54ffff48 	b.hi	9124 <_malloc_r+0x4c4>  // b.pmore
    9140:	f9400c44 	ldr	x4, [x2, #24]
    9144:	a90110a2 	stp	x2, x4, [x5, #16]
    9148:	f9000885 	str	x5, [x4, #16]
    914c:	f9000c45 	str	x5, [x2, #24]
    9150:	17fffef7 	b	8d2c <_malloc_r+0xcc>
    9154:	f100503f 	cmp	x1, #0x14
    9158:	54000749 	b.ls	9240 <_malloc_r+0x5e0>  // b.plast
    915c:	f101503f 	cmp	x1, #0x54
    9160:	54001348 	b.hi	93c8 <_malloc_r+0x768>  // b.pmore
    9164:	d34cfe61 	lsr	x1, x19, #12
    9168:	1101bc20 	add	w0, w1, #0x6f
    916c:	1101b826 	add	w6, w1, #0x6e
    9170:	531f7805 	lsl	w5, w0, #1
    9174:	937d7ca5 	sbfiz	x5, x5, #3, #32
    9178:	17ffff39 	b	8e5c <_malloc_r+0x1fc>
    917c:	f94008c5 	ldr	x5, [x6, #16]
    9180:	b2400260 	orr	x0, x19, #0x1
    9184:	f90004c0 	str	x0, [x6, #8]
    9188:	8b1300c4 	add	x4, x6, x19
    918c:	b2400068 	orr	x8, x3, #0x1
    9190:	910040da 	add	x26, x6, #0x10
    9194:	f9000ca1 	str	x1, [x5, #24]
    9198:	aa1503e0 	mov	x0, x21
    919c:	f9000825 	str	x5, [x1, #16]
    91a0:	a9021284 	stp	x4, x4, [x20, #32]
    91a4:	a9009c88 	stp	x8, x7, [x4, #8]
    91a8:	f9000c87 	str	x7, [x4, #24]
    91ac:	f82268c3 	str	x3, [x6, x2]
    91b0:	940006d0 	bl	acf0 <__malloc_unlock>
    91b4:	17ffff8d 	b	8fe8 <_malloc_r+0x388>
    91b8:	8b0200c2 	add	x2, x6, x2
    91bc:	aa0603fa 	mov	x26, x6
    91c0:	aa1503e0 	mov	x0, x21
    91c4:	f9400443 	ldr	x3, [x2, #8]
    91c8:	f8410f44 	ldr	x4, [x26, #16]!
    91cc:	b2400063 	orr	x3, x3, #0x1
    91d0:	f9000443 	str	x3, [x2, #8]
    91d4:	f9000c81 	str	x1, [x4, #24]
    91d8:	f9000824 	str	x4, [x1, #16]
    91dc:	940006c5 	bl	acf0 <__malloc_unlock>
    91e0:	17ffff82 	b	8fe8 <_malloc_r+0x388>
    91e4:	d343fe60 	lsr	x0, x19, #3
    91e8:	11000401 	add	w1, w0, #0x1
    91ec:	531f7821 	lsl	w1, w1, #1
    91f0:	937d7c21 	sbfiz	x1, x1, #3, #32
    91f4:	17fffeaa 	b	8c9c <_malloc_r+0x3c>
    91f8:	8b1300a3 	add	x3, x5, x19
    91fc:	b2400273 	orr	x19, x19, #0x1
    9200:	f90004b3 	str	x19, [x5, #8]
    9204:	b2400044 	orr	x4, x2, #0x1
    9208:	a9020e83 	stp	x3, x3, [x20, #32]
    920c:	aa1503e0 	mov	x0, x21
    9210:	910040ba 	add	x26, x5, #0x10
    9214:	a9009c64 	stp	x4, x7, [x3, #8]
    9218:	f9000c67 	str	x7, [x3, #24]
    921c:	f82168a2 	str	x2, [x5, x1]
    9220:	940006b4 	bl	acf0 <__malloc_unlock>
    9224:	17ffff71 	b	8fe8 <_malloc_r+0x388>
    9228:	d346fc22 	lsr	x2, x1, #6
    922c:	1100e444 	add	w4, w2, #0x39
    9230:	1100e043 	add	w3, w2, #0x38
    9234:	531f7884 	lsl	w4, w4, #1
    9238:	937d7c84 	sbfiz	x4, x4, #3, #32
    923c:	17ffffb5 	b	9110 <_malloc_r+0x4b0>
    9240:	11017020 	add	w0, w1, #0x5c
    9244:	11016c26 	add	w6, w1, #0x5b
    9248:	531f7805 	lsl	w5, w0, #1
    924c:	937d7ca5 	sbfiz	x5, x5, #3, #32
    9250:	17ffff03 	b	8e5c <_malloc_r+0x1fc>
    9254:	11000529 	add	w9, w9, #0x1
    9258:	910080a5 	add	x5, x5, #0x20
    925c:	17fffed7 	b	8db8 <_malloc_r+0x158>
    9260:	f0001fb9 	adrp	x25, 400000 <__sf+0x10>
    9264:	b9422320 	ldr	w0, [x25, #544]
    9268:	0b160000 	add	w0, w0, w22
    926c:	b9022320 	str	w0, [x25, #544]
    9270:	f941fb81 	ldr	x1, [x28, #1008]
    9274:	b100043f 	cmn	x1, #0x1
    9278:	54000b80 	b.eq	93e8 <_malloc_r+0x788>  // b.none
    927c:	cb1b031b 	sub	x27, x24, x27
    9280:	0b1b0000 	add	w0, w0, w27
    9284:	b9022320 	str	w0, [x25, #544]
    9288:	f2400f1c 	ands	x28, x24, #0xf
    928c:	540006a0 	b.eq	9360 <_malloc_r+0x700>  // b.none
    9290:	cb1c0318 	sub	x24, x24, x28
    9294:	d282021b 	mov	x27, #0x1010                	// #4112
    9298:	91004318 	add	x24, x24, #0x10
    929c:	cb1c037b 	sub	x27, x27, x28
    92a0:	8b160316 	add	x22, x24, x22
    92a4:	aa1503e0 	mov	x0, x21
    92a8:	cb16037b 	sub	x27, x27, x22
    92ac:	92402f7b 	and	x27, x27, #0xfff
    92b0:	aa1b03e1 	mov	x1, x27
    92b4:	94001427 	bl	e350 <_sbrk_r>
    92b8:	b100041f 	cmn	x0, #0x1
    92bc:	54000ba0 	b.eq	9430 <_malloc_r+0x7d0>  // b.none
    92c0:	cb180000 	sub	x0, x0, x24
    92c4:	2a1b03e3 	mov	w3, w27
    92c8:	8b1b0016 	add	x22, x0, x27
    92cc:	b9422320 	ldr	w0, [x25, #544]
    92d0:	b24002d6 	orr	x22, x22, #0x1
    92d4:	f9000a98 	str	x24, [x20, #16]
    92d8:	0b000063 	add	w3, w3, w0
    92dc:	b9022323 	str	w3, [x25, #544]
    92e0:	f9000716 	str	x22, [x24, #8]
    92e4:	eb14035f 	cmp	x26, x20
    92e8:	54ffe480 	b.eq	8f78 <_malloc_r+0x318>  // b.none
    92ec:	f1007eff 	cmp	x23, #0x1f
    92f0:	540004c9 	b.ls	9388 <_malloc_r+0x728>  // b.plast
    92f4:	f9400740 	ldr	x0, [x26, #8]
    92f8:	f0000022 	adrp	x2, 10000 <__env_lock>
    92fc:	d10062e1 	sub	x1, x23, #0x18
    9300:	3dc29440 	ldr	q0, [x2, #2640]
    9304:	927cec21 	and	x1, x1, #0xfffffffffffffff0
    9308:	8b010342 	add	x2, x26, x1
    930c:	92400000 	and	x0, x0, #0x1
    9310:	aa010000 	orr	x0, x0, x1
    9314:	f9000740 	str	x0, [x26, #8]
    9318:	3c808040 	stur	q0, [x2, #8]
    931c:	f1007c3f 	cmp	x1, #0x1f
    9320:	54000068 	b.hi	932c <_malloc_r+0x6cc>  // b.pmore
    9324:	f9400716 	ldr	x22, [x24, #8]
    9328:	17ffff14 	b	8f78 <_malloc_r+0x318>
    932c:	91004341 	add	x1, x26, #0x10
    9330:	aa1503e0 	mov	x0, x21
    9334:	94000e73 	bl	cd00 <_free_r>
    9338:	f9400a98 	ldr	x24, [x20, #16]
    933c:	b9422323 	ldr	w3, [x25, #544]
    9340:	f9400716 	ldr	x22, [x24, #8]
    9344:	17ffff0d 	b	8f78 <_malloc_r+0x318>
    9348:	13027c63 	asr	w3, w3, #2
    934c:	d2800021 	mov	x1, #0x1                   	// #1
    9350:	9ac32021 	lsl	x1, x1, x3
    9354:	aa0100c6 	orr	x6, x6, x1
    9358:	f9000686 	str	x6, [x20, #8]
    935c:	17ffff7a 	b	9144 <_malloc_r+0x4e4>
    9360:	8b16031b 	add	x27, x24, x22
    9364:	aa1503e0 	mov	x0, x21
    9368:	cb1b03fb 	neg	x27, x27
    936c:	92402f7b 	and	x27, x27, #0xfff
    9370:	aa1b03e1 	mov	x1, x27
    9374:	940013f7 	bl	e350 <_sbrk_r>
    9378:	52800003 	mov	w3, #0x0                   	// #0
    937c:	b100041f 	cmn	x0, #0x1
    9380:	54fffa01 	b.ne	92c0 <_malloc_r+0x660>  // b.any
    9384:	17ffffd2 	b	92cc <_malloc_r+0x66c>
    9388:	d2800020 	mov	x0, #0x1                   	// #1
    938c:	f9000700 	str	x0, [x24, #8]
    9390:	aa1503e0 	mov	x0, x21
    9394:	d280001a 	mov	x26, #0x0                   	// #0
    9398:	94000656 	bl	acf0 <__malloc_unlock>
    939c:	a94363f7 	ldp	x23, x24, [sp, #48]
    93a0:	a94573fb 	ldp	x27, x28, [sp, #80]
    93a4:	17ffff11 	b	8fe8 <_malloc_r+0x388>
    93a8:	f101505f 	cmp	x2, #0x54
    93ac:	54000228 	b.hi	93f0 <_malloc_r+0x790>  // b.pmore
    93b0:	d34cfc22 	lsr	x2, x1, #12
    93b4:	1101bc44 	add	w4, w2, #0x6f
    93b8:	1101b843 	add	w3, w2, #0x6e
    93bc:	531f7884 	lsl	w4, w4, #1
    93c0:	937d7c84 	sbfiz	x4, x4, #3, #32
    93c4:	17ffff53 	b	9110 <_malloc_r+0x4b0>
    93c8:	f105503f 	cmp	x1, #0x154
    93cc:	54000228 	b.hi	9410 <_malloc_r+0x7b0>  // b.pmore
    93d0:	d34ffe61 	lsr	x1, x19, #15
    93d4:	1101e020 	add	w0, w1, #0x78
    93d8:	1101dc26 	add	w6, w1, #0x77
    93dc:	531f7805 	lsl	w5, w0, #1
    93e0:	937d7ca5 	sbfiz	x5, x5, #3, #32
    93e4:	17fffe9e 	b	8e5c <_malloc_r+0x1fc>
    93e8:	f901fb98 	str	x24, [x28, #1008]
    93ec:	17ffffa7 	b	9288 <_malloc_r+0x628>
    93f0:	f105505f 	cmp	x2, #0x154
    93f4:	54000288 	b.hi	9444 <_malloc_r+0x7e4>  // b.pmore
    93f8:	d34ffc22 	lsr	x2, x1, #15
    93fc:	1101e044 	add	w4, w2, #0x78
    9400:	1101dc43 	add	w3, w2, #0x77
    9404:	531f7884 	lsl	w4, w4, #1
    9408:	937d7c84 	sbfiz	x4, x4, #3, #32
    940c:	17ffff41 	b	9110 <_malloc_r+0x4b0>
    9410:	f115503f 	cmp	x1, #0x554
    9414:	54000288 	b.hi	9464 <_malloc_r+0x804>  // b.pmore
    9418:	d352fe61 	lsr	x1, x19, #18
    941c:	1101f420 	add	w0, w1, #0x7d
    9420:	1101f026 	add	w6, w1, #0x7c
    9424:	531f7805 	lsl	w5, w0, #1
    9428:	937d7ca5 	sbfiz	x5, x5, #3, #32
    942c:	17fffe8c 	b	8e5c <_malloc_r+0x1fc>
    9430:	d100439c 	sub	x28, x28, #0x10
    9434:	52800003 	mov	w3, #0x0                   	// #0
    9438:	8b1c02d6 	add	x22, x22, x28
    943c:	cb1802d6 	sub	x22, x22, x24
    9440:	17ffffa3 	b	92cc <_malloc_r+0x66c>
    9444:	f115505f 	cmp	x2, #0x554
    9448:	54000168 	b.hi	9474 <_malloc_r+0x814>  // b.pmore
    944c:	d352fc22 	lsr	x2, x1, #18
    9450:	1101f444 	add	w4, w2, #0x7d
    9454:	1101f043 	add	w3, w2, #0x7c
    9458:	531f7884 	lsl	w4, w4, #1
    945c:	937d7c84 	sbfiz	x4, x4, #3, #32
    9460:	17ffff2c 	b	9110 <_malloc_r+0x4b0>
    9464:	d280fe05 	mov	x5, #0x7f0                 	// #2032
    9468:	52800fe0 	mov	w0, #0x7f                  	// #127
    946c:	52800fc6 	mov	w6, #0x7e                  	// #126
    9470:	17fffe7b 	b	8e5c <_malloc_r+0x1fc>
    9474:	d280fe04 	mov	x4, #0x7f0                 	// #2032
    9478:	52800fc3 	mov	w3, #0x7e                  	// #126
    947c:	17ffff25 	b	9110 <_malloc_r+0x4b0>
    9480:	f9400680 	ldr	x0, [x20, #8]
    9484:	17fffe5a 	b	8dec <_malloc_r+0x18c>
	...

0000000000009490 <abort>:
    9490:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    9494:	528000c0 	mov	w0, #0x6                   	// #6
    9498:	910003fd 	mov	x29, sp
    949c:	94001099 	bl	d700 <raise>
    94a0:	52800020 	mov	w0, #0x1                   	// #1
    94a4:	97ffdd67 	bl	a40 <_exit>
	...

00000000000094b0 <_wcrtomb_r>:
    94b0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    94b4:	9104f004 	add	x4, x0, #0x13c
    94b8:	910003fd 	mov	x29, sp
    94bc:	a90153f3 	stp	x19, x20, [sp, #16]
    94c0:	aa0303f3 	mov	x19, x3
    94c4:	f100027f 	cmp	x19, #0x0
    94c8:	90000043 	adrp	x3, 11000 <JIS_action_table>
    94cc:	9a930093 	csel	x19, x4, x19, eq	// eq = none
    94d0:	aa0003f4 	mov	x20, x0
    94d4:	f946f064 	ldr	x4, [x3, #3552]
    94d8:	aa1303e3 	mov	x3, x19
    94dc:	b4000121 	cbz	x1, 9500 <_wcrtomb_r+0x50>
    94e0:	d63f0080 	blr	x4
    94e4:	2a0003e1 	mov	w1, w0
    94e8:	93407c20 	sxtw	x0, w1
    94ec:	3100043f 	cmn	w1, #0x1
    94f0:	54000160 	b.eq	951c <_wcrtomb_r+0x6c>  // b.none
    94f4:	a94153f3 	ldp	x19, x20, [sp, #16]
    94f8:	a8c37bfd 	ldp	x29, x30, [sp], #48
    94fc:	d65f03c0 	ret
    9500:	910083e1 	add	x1, sp, #0x20
    9504:	52800002 	mov	w2, #0x0                   	// #0
    9508:	d63f0080 	blr	x4
    950c:	2a0003e1 	mov	w1, w0
    9510:	93407c20 	sxtw	x0, w1
    9514:	3100043f 	cmn	w1, #0x1
    9518:	54fffee1 	b.ne	94f4 <_wcrtomb_r+0x44>  // b.any
    951c:	b900027f 	str	wzr, [x19]
    9520:	52801141 	mov	w1, #0x8a                  	// #138
    9524:	b9000281 	str	w1, [x20]
    9528:	92800000 	mov	x0, #0xffffffffffffffff    	// #-1
    952c:	a94153f3 	ldp	x19, x20, [sp, #16]
    9530:	a8c37bfd 	ldp	x29, x30, [sp], #48
    9534:	d65f03c0 	ret
	...

0000000000009540 <wcrtomb>:
    9540:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    9544:	90000044 	adrp	x4, 11000 <JIS_action_table>
    9548:	90000043 	adrp	x3, 11000 <JIS_action_table>
    954c:	910003fd 	mov	x29, sp
    9550:	a90153f3 	stp	x19, x20, [sp, #16]
    9554:	f100005f 	cmp	x2, #0x0
    9558:	f9413c94 	ldr	x20, [x4, #632]
    955c:	9104f284 	add	x4, x20, #0x13c
    9560:	9a820093 	csel	x19, x4, x2, eq	// eq = none
    9564:	f946f064 	ldr	x4, [x3, #3552]
    9568:	b40001a0 	cbz	x0, 959c <wcrtomb+0x5c>
    956c:	2a0103e2 	mov	w2, w1
    9570:	aa0003e1 	mov	x1, x0
    9574:	aa1303e3 	mov	x3, x19
    9578:	aa1403e0 	mov	x0, x20
    957c:	d63f0080 	blr	x4
    9580:	2a0003e1 	mov	w1, w0
    9584:	93407c20 	sxtw	x0, w1
    9588:	3100043f 	cmn	w1, #0x1
    958c:	540001a0 	b.eq	95c0 <wcrtomb+0x80>  // b.none
    9590:	a94153f3 	ldp	x19, x20, [sp, #16]
    9594:	a8c37bfd 	ldp	x29, x30, [sp], #48
    9598:	d65f03c0 	ret
    959c:	910083e1 	add	x1, sp, #0x20
    95a0:	aa1303e3 	mov	x3, x19
    95a4:	aa1403e0 	mov	x0, x20
    95a8:	52800002 	mov	w2, #0x0                   	// #0
    95ac:	d63f0080 	blr	x4
    95b0:	2a0003e1 	mov	w1, w0
    95b4:	93407c20 	sxtw	x0, w1
    95b8:	3100043f 	cmn	w1, #0x1
    95bc:	54fffea1 	b.ne	9590 <wcrtomb+0x50>  // b.any
    95c0:	b900027f 	str	wzr, [x19]
    95c4:	52801141 	mov	w1, #0x8a                  	// #138
    95c8:	b9000281 	str	w1, [x20]
    95cc:	92800000 	mov	x0, #0xffffffffffffffff    	// #-1
    95d0:	a94153f3 	ldp	x19, x20, [sp, #16]
    95d4:	a8c37bfd 	ldp	x29, x30, [sp], #48
    95d8:	d65f03c0 	ret
    95dc:	00000000 	udf	#0

00000000000095e0 <__retarget_lock_init>:
    95e0:	d65f03c0 	ret
	...

00000000000095f0 <__retarget_lock_init_recursive>:
    95f0:	d65f03c0 	ret
	...

0000000000009600 <__retarget_lock_close>:
    9600:	d65f03c0 	ret
	...

0000000000009610 <__retarget_lock_close_recursive>:
    9610:	d65f03c0 	ret
	...

0000000000009620 <__retarget_lock_acquire>:
    9620:	d65f03c0 	ret
	...

0000000000009630 <__retarget_lock_acquire_recursive>:
    9630:	d65f03c0 	ret
	...

0000000000009640 <__retarget_lock_try_acquire>:
    9640:	52800020 	mov	w0, #0x1                   	// #1
    9644:	d65f03c0 	ret
	...

0000000000009650 <__retarget_lock_try_acquire_recursive>:
    9650:	52800020 	mov	w0, #0x1                   	// #1
    9654:	d65f03c0 	ret
	...

0000000000009660 <__retarget_lock_release>:
    9660:	d65f03c0 	ret
	...

0000000000009670 <__retarget_lock_release_recursive>:
    9670:	d65f03c0 	ret
	...

0000000000009680 <currentlocale>:
    9680:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
    9684:	910003fd 	mov	x29, sp
    9688:	a90153f3 	stp	x19, x20, [sp, #16]
    968c:	90000054 	adrp	x20, 11000 <JIS_action_table>
    9690:	91340294 	add	x20, x20, #0xd00
    9694:	a9025bf5 	stp	x21, x22, [sp, #32]
    9698:	90000055 	adrp	x21, 11000 <JIS_action_table>
    969c:	913502b5 	add	x21, x21, #0xd40
    96a0:	f9001bf7 	str	x23, [sp, #48]
    96a4:	90000057 	adrp	x23, 11000 <JIS_action_table>
    96a8:	913042f7 	add	x23, x23, #0xc10
    96ac:	90000056 	adrp	x22, 11000 <JIS_action_table>
    96b0:	aa1503f3 	mov	x19, x21
    96b4:	913482c1 	add	x1, x22, #0xd20
    96b8:	91038294 	add	x20, x20, #0xe0
    96bc:	913482d6 	add	x22, x22, #0xd20
    96c0:	aa1703e0 	mov	x0, x23
    96c4:	97ffe44f 	bl	2800 <strcpy>
    96c8:	aa1303e1 	mov	x1, x19
    96cc:	aa1603e0 	mov	x0, x22
    96d0:	91008273 	add	x19, x19, #0x20
    96d4:	940010eb 	bl	da80 <strcmp>
    96d8:	35000120 	cbnz	w0, 96fc <currentlocale+0x7c>
    96dc:	eb14027f 	cmp	x19, x20
    96e0:	54ffff41 	b.ne	96c8 <currentlocale+0x48>  // b.any
    96e4:	a94153f3 	ldp	x19, x20, [sp, #16]
    96e8:	aa1703e0 	mov	x0, x23
    96ec:	a9425bf5 	ldp	x21, x22, [sp, #32]
    96f0:	f9401bf7 	ldr	x23, [sp, #48]
    96f4:	a8c47bfd 	ldp	x29, x30, [sp], #64
    96f8:	d65f03c0 	ret
    96fc:	f0000033 	adrp	x19, 10000 <__env_lock>
    9700:	91298273 	add	x19, x19, #0xa60
    9704:	d503201f 	nop
    9708:	aa1303e1 	mov	x1, x19
    970c:	aa1703e0 	mov	x0, x23
    9710:	94001558 	bl	ec70 <strcat>
    9714:	aa1503e1 	mov	x1, x21
    9718:	aa1703e0 	mov	x0, x23
    971c:	910082b5 	add	x21, x21, #0x20
    9720:	94001554 	bl	ec70 <strcat>
    9724:	eb1402bf 	cmp	x21, x20
    9728:	54ffff01 	b.ne	9708 <currentlocale+0x88>  // b.any
    972c:	a94153f3 	ldp	x19, x20, [sp, #16]
    9730:	aa1703e0 	mov	x0, x23
    9734:	a9425bf5 	ldp	x21, x22, [sp, #32]
    9738:	f9401bf7 	ldr	x23, [sp, #48]
    973c:	a8c47bfd 	ldp	x29, x30, [sp], #64
    9740:	d65f03c0 	ret
	...

0000000000009750 <__loadlocale>:
    9750:	a9b67bfd 	stp	x29, x30, [sp, #-160]!
    9754:	910003fd 	mov	x29, sp
    9758:	a90153f3 	stp	x19, x20, [sp, #16]
    975c:	937b7c34 	sbfiz	x20, x1, #5, #32
    9760:	8b140014 	add	x20, x0, x20
    9764:	aa0203f3 	mov	x19, x2
    9768:	a9025bf5 	stp	x21, x22, [sp, #32]
    976c:	aa0003f6 	mov	x22, x0
    9770:	aa0203e0 	mov	x0, x2
    9774:	a90363f7 	stp	x23, x24, [sp, #48]
    9778:	2a0103f7 	mov	w23, w1
    977c:	aa1403e1 	mov	x1, x20
    9780:	940010c0 	bl	da80 <strcmp>
    9784:	350000e0 	cbnz	w0, 97a0 <__loadlocale+0x50>
    9788:	a9425bf5 	ldp	x21, x22, [sp, #32]
    978c:	aa1403e0 	mov	x0, x20
    9790:	a94153f3 	ldp	x19, x20, [sp, #16]
    9794:	a94363f7 	ldp	x23, x24, [sp, #48]
    9798:	a8ca7bfd 	ldp	x29, x30, [sp], #160
    979c:	d65f03c0 	ret
    97a0:	aa1303e0 	mov	x0, x19
    97a4:	f0000021 	adrp	x1, 10000 <__env_lock>
    97a8:	f0000035 	adrp	x21, 10000 <__env_lock>
    97ac:	9129a021 	add	x1, x1, #0xa68
    97b0:	9129c2b5 	add	x21, x21, #0xa70
    97b4:	940010b3 	bl	da80 <strcmp>
    97b8:	34000ca0 	cbz	w0, 994c <__loadlocale+0x1fc>
    97bc:	aa1503e1 	mov	x1, x21
    97c0:	aa1303e0 	mov	x0, x19
    97c4:	940010af 	bl	da80 <strcmp>
    97c8:	34000b40 	cbz	w0, 9930 <__loadlocale+0x1e0>
    97cc:	39400260 	ldrb	w0, [x19]
    97d0:	71010c1f 	cmp	w0, #0x43
    97d4:	54000ca0 	b.eq	9968 <__loadlocale+0x218>  // b.none
    97d8:	51018400 	sub	w0, w0, #0x61
    97dc:	12001c00 	and	w0, w0, #0xff
    97e0:	7100641f 	cmp	w0, #0x19
    97e4:	54000a28 	b.hi	9928 <__loadlocale+0x1d8>  // b.pmore
    97e8:	39400660 	ldrb	w0, [x19, #1]
    97ec:	51018400 	sub	w0, w0, #0x61
    97f0:	12001c00 	and	w0, w0, #0xff
    97f4:	7100641f 	cmp	w0, #0x19
    97f8:	54000988 	b.hi	9928 <__loadlocale+0x1d8>  // b.pmore
    97fc:	39400a60 	ldrb	w0, [x19, #2]
    9800:	91000a78 	add	x24, x19, #0x2
    9804:	51018401 	sub	w1, w0, #0x61
    9808:	12001c21 	and	w1, w1, #0xff
    980c:	7100643f 	cmp	w1, #0x19
    9810:	54000068 	b.hi	981c <__loadlocale+0xcc>  // b.pmore
    9814:	39400e60 	ldrb	w0, [x19, #3]
    9818:	91000e78 	add	x24, x19, #0x3
    981c:	71017c1f 	cmp	w0, #0x5f
    9820:	54000cc0 	b.eq	99b8 <__loadlocale+0x268>  // b.none
    9824:	7100b81f 	cmp	w0, #0x2e
    9828:	54002e40 	b.eq	9df0 <__loadlocale+0x6a0>  // b.none
    982c:	528017e1 	mov	w1, #0xbf                  	// #191
    9830:	6a01001f 	tst	w0, w1
    9834:	540007a1 	b.ne	9928 <__loadlocale+0x1d8>  // b.any
    9838:	910203f5 	add	x21, sp, #0x80
    983c:	f0000021 	adrp	x1, 10000 <__env_lock>
    9840:	aa1503e0 	mov	x0, x21
    9844:	912a0021 	add	x1, x1, #0xa80
    9848:	a9046bf9 	stp	x25, x26, [sp, #64]
    984c:	97ffe3ed 	bl	2800 <strcpy>
    9850:	39400300 	ldrb	w0, [x24]
    9854:	7101001f 	cmp	w0, #0x40
    9858:	54002d20 	b.eq	9dfc <__loadlocale+0x6ac>  // b.none
    985c:	52800018 	mov	w24, #0x0                   	// #0
    9860:	52800019 	mov	w25, #0x0                   	// #0
    9864:	5280001a 	mov	w26, #0x0                   	// #0
    9868:	394203e1 	ldrb	w1, [sp, #128]
    986c:	51010421 	sub	w1, w1, #0x41
    9870:	7100d03f 	cmp	w1, #0x34
    9874:	54000748 	b.hi	995c <__loadlocale+0x20c>  // b.pmore
    9878:	f0000020 	adrp	x0, 10000 <__env_lock>
    987c:	912e0000 	add	x0, x0, #0xb80
    9880:	a90573fb 	stp	x27, x28, [sp, #80]
    9884:	78615800 	ldrh	w0, [x0, w1, uxtw #1]
    9888:	10000061 	adr	x1, 9894 <__loadlocale+0x144>
    988c:	8b20a820 	add	x0, x1, w0, sxth #2
    9890:	d61f0000 	br	x0
    9894:	394207e0 	ldrb	w0, [sp, #129]
    9898:	121a7800 	and	w0, w0, #0xffffffdf
    989c:	12001c00 	and	w0, w0, #0xff
    98a0:	7101401f 	cmp	w0, #0x50
    98a4:	540003e1 	b.ne	9920 <__loadlocale+0x1d0>  // b.any
    98a8:	d2800042 	mov	x2, #0x2                   	// #2
    98ac:	aa1503e0 	mov	x0, x21
    98b0:	f0000021 	adrp	x1, 10000 <__env_lock>
    98b4:	912c4021 	add	x1, x1, #0xb10
    98b8:	94000ec6 	bl	d3d0 <strncpy>
    98bc:	9101e3e1 	add	x1, sp, #0x78
    98c0:	91020be0 	add	x0, sp, #0x82
    98c4:	52800142 	mov	w2, #0xa                   	// #10
    98c8:	94000e46 	bl	d1e0 <strtol>
    98cc:	f9403fe1 	ldr	x1, [sp, #120]
    98d0:	39400021 	ldrb	w1, [x1]
    98d4:	35000261 	cbnz	w1, 9920 <__loadlocale+0x1d0>
    98d8:	f10e901f 	cmp	x0, #0x3a4
    98dc:	54001e20 	b.eq	9ca0 <__loadlocale+0x550>  // b.none
    98e0:	54002dac 	b.gt	9e94 <__loadlocale+0x744>
    98e4:	f10d881f 	cmp	x0, #0x362
    98e8:	54002d0c 	b.gt	9e88 <__loadlocale+0x738>
    98ec:	f10d441f 	cmp	x0, #0x351
    98f0:	54002c0c 	b.gt	9e70 <__loadlocale+0x720>
    98f4:	f106d41f 	cmp	x0, #0x1b5
    98f8:	54000d80 	b.eq	9aa8 <__loadlocale+0x358>  // b.none
    98fc:	d10b4000 	sub	x0, x0, #0x2d0
    9900:	f100dc1f 	cmp	x0, #0x37
    9904:	540000e8 	b.hi	9920 <__loadlocale+0x1d0>  // b.pmore
    9908:	d2800021 	mov	x1, #0x1                   	// #1
    990c:	f2a00041 	movk	x1, #0x2, lsl #16
    9910:	f2e01001 	movk	x1, #0x80, lsl #48
    9914:	9ac02420 	lsr	x0, x1, x0
    9918:	37000c80 	tbnz	w0, #0, 9aa8 <__loadlocale+0x358>
    991c:	d503201f 	nop
    9920:	a9446bf9 	ldp	x25, x26, [sp, #64]
    9924:	a94573fb 	ldp	x27, x28, [sp, #80]
    9928:	d2800014 	mov	x20, #0x0                   	// #0
    992c:	17ffff97 	b	9788 <__loadlocale+0x38>
    9930:	910203f5 	add	x21, sp, #0x80
    9934:	f0000021 	adrp	x1, 10000 <__env_lock>
    9938:	aa1503e0 	mov	x0, x21
    993c:	9129e021 	add	x1, x1, #0xa78
    9940:	a9046bf9 	stp	x25, x26, [sp, #64]
    9944:	97ffe3af 	bl	2800 <strcpy>
    9948:	17ffffc5 	b	985c <__loadlocale+0x10c>
    994c:	aa1503e1 	mov	x1, x21
    9950:	aa1303e0 	mov	x0, x19
    9954:	97ffe3ab 	bl	2800 <strcpy>
    9958:	17ffff99 	b	97bc <__loadlocale+0x6c>
    995c:	a9446bf9 	ldp	x25, x26, [sp, #64]
    9960:	d2800014 	mov	x20, #0x0                   	// #0
    9964:	17ffff89 	b	9788 <__loadlocale+0x38>
    9968:	39400660 	ldrb	w0, [x19, #1]
    996c:	5100b400 	sub	w0, w0, #0x2d
    9970:	12001c00 	and	w0, w0, #0xff
    9974:	7100041f 	cmp	w0, #0x1
    9978:	54fffd88 	b.hi	9928 <__loadlocale+0x1d8>  // b.pmore
    997c:	91000a78 	add	x24, x19, #0x2
    9980:	a9046bf9 	stp	x25, x26, [sp, #64]
    9984:	910203f5 	add	x21, sp, #0x80
    9988:	aa1803e1 	mov	x1, x24
    998c:	aa1503e0 	mov	x0, x21
    9990:	97ffe39c 	bl	2800 <strcpy>
    9994:	aa1503e0 	mov	x0, x21
    9998:	52800801 	mov	w1, #0x40                  	// #64
    999c:	94000adb 	bl	c508 <strchr>
    99a0:	b4000040 	cbz	x0, 99a8 <__loadlocale+0x258>
    99a4:	3900001f 	strb	wzr, [x0]
    99a8:	aa1503e0 	mov	x0, x21
    99ac:	97ffe405 	bl	29c0 <strlen>
    99b0:	8b000318 	add	x24, x24, x0
    99b4:	17ffffa7 	b	9850 <__loadlocale+0x100>
    99b8:	39400700 	ldrb	w0, [x24, #1]
    99bc:	51010400 	sub	w0, w0, #0x41
    99c0:	12001c00 	and	w0, w0, #0xff
    99c4:	7100641f 	cmp	w0, #0x19
    99c8:	54fffb08 	b.hi	9928 <__loadlocale+0x1d8>  // b.pmore
    99cc:	39400b00 	ldrb	w0, [x24, #2]
    99d0:	51010400 	sub	w0, w0, #0x41
    99d4:	12001c00 	and	w0, w0, #0xff
    99d8:	7100641f 	cmp	w0, #0x19
    99dc:	54fffa68 	b.hi	9928 <__loadlocale+0x1d8>  // b.pmore
    99e0:	39400f00 	ldrb	w0, [x24, #3]
    99e4:	91000f18 	add	x24, x24, #0x3
    99e8:	17ffff8f 	b	9824 <__loadlocale+0xd4>
    99ec:	f000003b 	adrp	x27, 10000 <__env_lock>
    99f0:	912ae37b 	add	x27, x27, #0xab8
    99f4:	aa1b03e1 	mov	x1, x27
    99f8:	aa1503e0 	mov	x0, x21
    99fc:	94001481 	bl	ec00 <strcasecmp>
    9a00:	340000c0 	cbz	w0, 9a18 <__loadlocale+0x2c8>
    9a04:	f0000021 	adrp	x1, 10000 <__env_lock>
    9a08:	aa1503e0 	mov	x0, x21
    9a0c:	912b0021 	add	x1, x1, #0xac0
    9a10:	9400147c 	bl	ec00 <strcasecmp>
    9a14:	35fff860 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9a18:	aa1b03e1 	mov	x1, x27
    9a1c:	aa1503e0 	mov	x0, x21
    9a20:	97ffe378 	bl	2800 <strcpy>
    9a24:	b000003b 	adrp	x27, e000 <__utf8_wctomb>
    9a28:	b0000022 	adrp	x2, e000 <__utf8_wctomb>
    9a2c:	9115837b 	add	x27, x27, #0x560
    9a30:	91000042 	add	x2, x2, #0x0
    9a34:	528000dc 	mov	w28, #0x6                   	// #6
    9a38:	71000aff 	cmp	w23, #0x2
    9a3c:	54001ac0 	b.eq	9d94 <__loadlocale+0x644>  // b.none
    9a40:	71001aff 	cmp	w23, #0x6
    9a44:	54000081 	b.ne	9a54 <__loadlocale+0x304>  // b.any
    9a48:	aa1503e1 	mov	x1, x21
    9a4c:	91060ac0 	add	x0, x22, #0x182
    9a50:	97ffe36c 	bl	2800 <strcpy>
    9a54:	aa1303e1 	mov	x1, x19
    9a58:	aa1403e0 	mov	x0, x20
    9a5c:	97ffe369 	bl	2800 <strcpy>
    9a60:	aa0003f4 	mov	x20, x0
    9a64:	a9425bf5 	ldp	x21, x22, [sp, #32]
    9a68:	aa1403e0 	mov	x0, x20
    9a6c:	a94153f3 	ldp	x19, x20, [sp, #16]
    9a70:	a94363f7 	ldp	x23, x24, [sp, #48]
    9a74:	a9446bf9 	ldp	x25, x26, [sp, #64]
    9a78:	a94573fb 	ldp	x27, x28, [sp, #80]
    9a7c:	a8ca7bfd 	ldp	x29, x30, [sp], #160
    9a80:	d65f03c0 	ret
    9a84:	f0000021 	adrp	x1, 10000 <__env_lock>
    9a88:	aa1503e0 	mov	x0, x21
    9a8c:	912d6021 	add	x1, x1, #0xb58
    9a90:	9400145c 	bl	ec00 <strcasecmp>
    9a94:	35fff460 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9a98:	f0000021 	adrp	x1, 10000 <__env_lock>
    9a9c:	aa1503e0 	mov	x0, x21
    9aa0:	912d8021 	add	x1, x1, #0xb60
    9aa4:	97ffe357 	bl	2800 <strcpy>
    9aa8:	b000003b 	adrp	x27, e000 <__utf8_wctomb>
    9aac:	90000022 	adrp	x2, d000 <_strtol_l.part.0+0x20>
    9ab0:	9114437b 	add	x27, x27, #0x510
    9ab4:	913f0042 	add	x2, x2, #0xfc0
    9ab8:	5280003c 	mov	w28, #0x1                   	// #1
    9abc:	17ffffdf 	b	9a38 <__loadlocale+0x2e8>
    9ac0:	f0000021 	adrp	x1, 10000 <__env_lock>
    9ac4:	aa1503e0 	mov	x0, x21
    9ac8:	912c6021 	add	x1, x1, #0xb18
    9acc:	d2800082 	mov	x2, #0x4                   	// #4
    9ad0:	94000dd8 	bl	d230 <strncasecmp>
    9ad4:	35fff260 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9ad8:	394213e0 	ldrb	w0, [sp, #132]
    9adc:	394217e1 	ldrb	w1, [sp, #133]
    9ae0:	7100b41f 	cmp	w0, #0x2d
    9ae4:	1a800020 	csel	w0, w1, w0, eq	// eq = none
    9ae8:	121a7800 	and	w0, w0, #0xffffffdf
    9aec:	12001c00 	and	w0, w0, #0xff
    9af0:	7101481f 	cmp	w0, #0x52
    9af4:	54001dc0 	b.eq	9eac <__loadlocale+0x75c>  // b.none
    9af8:	7101541f 	cmp	w0, #0x55
    9afc:	54001e20 	b.eq	9ec0 <__loadlocale+0x770>  // b.none
    9b00:	7101501f 	cmp	w0, #0x54
    9b04:	54fff0e1 	b.ne	9920 <__loadlocale+0x1d0>  // b.any
    9b08:	aa1503e0 	mov	x0, x21
    9b0c:	f0000021 	adrp	x1, 10000 <__env_lock>
    9b10:	912cc021 	add	x1, x1, #0xb30
    9b14:	97ffe33b 	bl	2800 <strcpy>
    9b18:	17ffffe4 	b	9aa8 <__loadlocale+0x358>
    9b1c:	f000003b 	adrp	x27, 10000 <__env_lock>
    9b20:	912b237b 	add	x27, x27, #0xac8
    9b24:	aa1b03e1 	mov	x1, x27
    9b28:	aa1503e0 	mov	x0, x21
    9b2c:	94001435 	bl	ec00 <strcasecmp>
    9b30:	35ffef80 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9b34:	aa1b03e1 	mov	x1, x27
    9b38:	aa1503e0 	mov	x0, x21
    9b3c:	97ffe331 	bl	2800 <strcpy>
    9b40:	b000003b 	adrp	x27, e000 <__utf8_wctomb>
    9b44:	b0000022 	adrp	x2, e000 <__utf8_wctomb>
    9b48:	9128837b 	add	x27, x27, #0xa20
    9b4c:	9108c042 	add	x2, x2, #0x230
    9b50:	5280011c 	mov	w28, #0x8                   	// #8
    9b54:	17ffffb9 	b	9a38 <__loadlocale+0x2e8>
    9b58:	f0000021 	adrp	x1, 10000 <__env_lock>
    9b5c:	aa1503e0 	mov	x0, x21
    9b60:	912bc021 	add	x1, x1, #0xaf0
    9b64:	d2800062 	mov	x2, #0x3                   	// #3
    9b68:	94000db2 	bl	d230 <strncasecmp>
    9b6c:	35ffeda0 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9b70:	39420fe0 	ldrb	w0, [sp, #131]
    9b74:	f0000021 	adrp	x1, 10000 <__env_lock>
    9b78:	d2800082 	mov	x2, #0x4                   	// #4
    9b7c:	912be021 	add	x1, x1, #0xaf8
    9b80:	7100b41f 	cmp	w0, #0x2d
    9b84:	910283e0 	add	x0, sp, #0xa0
    9b88:	9a80141b 	cinc	x27, x0, eq	// eq = none
    9b8c:	d100777b 	sub	x27, x27, #0x1d
    9b90:	aa1b03e0 	mov	x0, x27
    9b94:	94000da7 	bl	d230 <strncasecmp>
    9b98:	35ffec40 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9b9c:	39401360 	ldrb	w0, [x27, #4]
    9ba0:	9101e3e1 	add	x1, sp, #0x78
    9ba4:	52800142 	mov	w2, #0xa                   	// #10
    9ba8:	7100b41f 	cmp	w0, #0x2d
    9bac:	9a9b1760 	cinc	x0, x27, eq	// eq = none
    9bb0:	91001000 	add	x0, x0, #0x4
    9bb4:	94000d8b 	bl	d1e0 <strtol>
    9bb8:	aa0003fb 	mov	x27, x0
    9bbc:	d1000400 	sub	x0, x0, #0x1
    9bc0:	f1003c1f 	cmp	x0, #0xf
    9bc4:	fa4c9b64 	ccmp	x27, #0xc, #0x4, ls	// ls = plast
    9bc8:	54ffeac0 	b.eq	9920 <__loadlocale+0x1d0>  // b.none
    9bcc:	f9403fe0 	ldr	x0, [sp, #120]
    9bd0:	39400000 	ldrb	w0, [x0]
    9bd4:	35ffea60 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9bd8:	aa1503e0 	mov	x0, x21
    9bdc:	f0000021 	adrp	x1, 10000 <__env_lock>
    9be0:	912c0021 	add	x1, x1, #0xb00
    9be4:	97ffe307 	bl	2800 <strcpy>
    9be8:	910227e2 	add	x2, sp, #0x89
    9bec:	f1002b7f 	cmp	x27, #0xa
    9bf0:	5400008d 	b.le	9c00 <__loadlocale+0x4b0>
    9bf4:	91022be2 	add	x2, sp, #0x8a
    9bf8:	52800620 	mov	w0, #0x31                  	// #49
    9bfc:	390227e0 	strb	w0, [sp, #137]
    9c00:	b203e7e1 	mov	x1, #0x6666666666666666    	// #7378697629483820646
    9c04:	3900045f 	strb	wzr, [x2, #1]
    9c08:	f28ccce1 	movk	x1, #0x6667
    9c0c:	9b417f61 	smulh	x1, x27, x1
    9c10:	9342fc21 	asr	x1, x1, #2
    9c14:	cb9bfc21 	sub	x1, x1, x27, asr #63
    9c18:	8b010821 	add	x1, x1, x1, lsl #2
    9c1c:	cb010760 	sub	x0, x27, x1, lsl #1
    9c20:	1100c000 	add	w0, w0, #0x30
    9c24:	39000040 	strb	w0, [x2]
    9c28:	17ffffa0 	b	9aa8 <__loadlocale+0x358>
    9c2c:	f0000021 	adrp	x1, 10000 <__env_lock>
    9c30:	aa1503e0 	mov	x0, x21
    9c34:	912da021 	add	x1, x1, #0xb68
    9c38:	d2800062 	mov	x2, #0x3                   	// #3
    9c3c:	94000d7d 	bl	d230 <strncasecmp>
    9c40:	35ffe700 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9c44:	39420fe0 	ldrb	w0, [sp, #131]
    9c48:	f0000021 	adrp	x1, 10000 <__env_lock>
    9c4c:	912dc021 	add	x1, x1, #0xb70
    9c50:	7100b41f 	cmp	w0, #0x2d
    9c54:	910283e0 	add	x0, sp, #0xa0
    9c58:	9a801400 	cinc	x0, x0, eq	// eq = none
    9c5c:	d1007400 	sub	x0, x0, #0x1d
    9c60:	94000f88 	bl	da80 <strcmp>
    9c64:	35ffe5e0 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9c68:	aa1503e0 	mov	x0, x21
    9c6c:	f0000021 	adrp	x1, 10000 <__env_lock>
    9c70:	912de021 	add	x1, x1, #0xb78
    9c74:	97ffe2e3 	bl	2800 <strcpy>
    9c78:	17ffff8c 	b	9aa8 <__loadlocale+0x358>
    9c7c:	f000003b 	adrp	x27, 10000 <__env_lock>
    9c80:	912ba37b 	add	x27, x27, #0xae8
    9c84:	aa1b03e1 	mov	x1, x27
    9c88:	aa1503e0 	mov	x0, x21
    9c8c:	940013dd 	bl	ec00 <strcasecmp>
    9c90:	35ffe480 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9c94:	aa1b03e1 	mov	x1, x27
    9c98:	aa1503e0 	mov	x0, x21
    9c9c:	97ffe2d9 	bl	2800 <strcpy>
    9ca0:	b000003b 	adrp	x27, e000 <__utf8_wctomb>
    9ca4:	b0000022 	adrp	x2, e000 <__utf8_wctomb>
    9ca8:	9120837b 	add	x27, x27, #0x820
    9cac:	9103c042 	add	x2, x2, #0xf0
    9cb0:	5280005c 	mov	w28, #0x2                   	// #2
    9cb4:	17ffff61 	b	9a38 <__loadlocale+0x2e8>
    9cb8:	f0000021 	adrp	x1, 10000 <__env_lock>
    9cbc:	aa1503e0 	mov	x0, x21
    9cc0:	912ce021 	add	x1, x1, #0xb38
    9cc4:	d2800102 	mov	x2, #0x8                   	// #8
    9cc8:	94000d5a 	bl	d230 <strncasecmp>
    9ccc:	35ffe2a0 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9cd0:	394223e0 	ldrb	w0, [sp, #136]
    9cd4:	f0000021 	adrp	x1, 10000 <__env_lock>
    9cd8:	912d2021 	add	x1, x1, #0xb48
    9cdc:	7100b41f 	cmp	w0, #0x2d
    9ce0:	910283e0 	add	x0, sp, #0xa0
    9ce4:	9a801400 	cinc	x0, x0, eq	// eq = none
    9ce8:	d1006000 	sub	x0, x0, #0x18
    9cec:	940013c5 	bl	ec00 <strcasecmp>
    9cf0:	35ffe180 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9cf4:	aa1503e0 	mov	x0, x21
    9cf8:	f0000021 	adrp	x1, 10000 <__env_lock>
    9cfc:	912d4021 	add	x1, x1, #0xb50
    9d00:	97ffe2c0 	bl	2800 <strcpy>
    9d04:	17ffff69 	b	9aa8 <__loadlocale+0x358>
    9d08:	f0000021 	adrp	x1, 10000 <__env_lock>
    9d0c:	aa1503e0 	mov	x0, x21
    9d10:	912b4021 	add	x1, x1, #0xad0
    9d14:	d2800062 	mov	x2, #0x3                   	// #3
    9d18:	94000d46 	bl	d230 <strncasecmp>
    9d1c:	35ffe020 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9d20:	39420fe0 	ldrb	w0, [sp, #131]
    9d24:	f0000021 	adrp	x1, 10000 <__env_lock>
    9d28:	912b6021 	add	x1, x1, #0xad8
    9d2c:	7100b41f 	cmp	w0, #0x2d
    9d30:	910283e0 	add	x0, sp, #0xa0
    9d34:	9a801400 	cinc	x0, x0, eq	// eq = none
    9d38:	d1007400 	sub	x0, x0, #0x1d
    9d3c:	940013b1 	bl	ec00 <strcasecmp>
    9d40:	35ffdf00 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9d44:	aa1503e0 	mov	x0, x21
    9d48:	f0000021 	adrp	x1, 10000 <__env_lock>
    9d4c:	912b8021 	add	x1, x1, #0xae0
    9d50:	97ffe2ac 	bl	2800 <strcpy>
    9d54:	b000003b 	adrp	x27, e000 <__utf8_wctomb>
    9d58:	b0000022 	adrp	x2, e000 <__utf8_wctomb>
    9d5c:	9123c37b 	add	x27, x27, #0x8f0
    9d60:	91060042 	add	x2, x2, #0x180
    9d64:	5280007c 	mov	w28, #0x3                   	// #3
    9d68:	17ffff34 	b	9a38 <__loadlocale+0x2e8>
    9d6c:	f000003b 	adrp	x27, 10000 <__env_lock>
    9d70:	9129e37b 	add	x27, x27, #0xa78
    9d74:	aa1b03e1 	mov	x1, x27
    9d78:	aa1503e0 	mov	x0, x21
    9d7c:	940013a1 	bl	ec00 <strcasecmp>
    9d80:	35ffdd00 	cbnz	w0, 9920 <__loadlocale+0x1d0>
    9d84:	aa1b03e1 	mov	x1, x27
    9d88:	aa1503e0 	mov	x0, x21
    9d8c:	97ffe29d 	bl	2800 <strcpy>
    9d90:	17ffff46 	b	9aa8 <__loadlocale+0x358>
    9d94:	aa1503e1 	mov	x1, x21
    9d98:	91058ac0 	add	x0, x22, #0x162
    9d9c:	f90037e2 	str	x2, [sp, #104]
    9da0:	97ffe298 	bl	2800 <strcpy>
    9da4:	f94037e2 	ldr	x2, [sp, #104]
    9da8:	a90e6ec2 	stp	x2, x27, [x22, #224]
    9dac:	aa1503e1 	mov	x1, x21
    9db0:	390582dc 	strb	w28, [x22, #352]
    9db4:	aa1603e0 	mov	x0, x22
    9db8:	940008ae 	bl	c070 <__set_ctype>
    9dbc:	35000138 	cbnz	w24, 9de0 <__loadlocale+0x690>
    9dc0:	7100079f 	cmp	w28, #0x1
    9dc4:	52000339 	eor	w25, w25, #0x1
    9dc8:	1a9fd7e0 	cset	w0, gt
    9dcc:	6a00033f 	tst	w25, w0
    9dd0:	54000080 	b.eq	9de0 <__loadlocale+0x690>  // b.none
    9dd4:	394203e0 	ldrb	w0, [sp, #128]
    9dd8:	7101541f 	cmp	w0, #0x55
    9ddc:	1a9f07f8 	cset	w24, ne	// ne = any
    9de0:	7100035f 	cmp	w26, #0x0
    9de4:	5a9f0318 	csinv	w24, w24, wzr, eq	// eq = none
    9de8:	b900f2d8 	str	w24, [x22, #240]
    9dec:	17ffff1a 	b	9a54 <__loadlocale+0x304>
    9df0:	91000718 	add	x24, x24, #0x1
    9df4:	a9046bf9 	stp	x25, x26, [sp, #64]
    9df8:	17fffee3 	b	9984 <__loadlocale+0x234>
    9dfc:	a90573fb 	stp	x27, x28, [sp, #80]
    9e00:	9100071b 	add	x27, x24, #0x1
    9e04:	aa1b03e0 	mov	x0, x27
    9e08:	f0000021 	adrp	x1, 10000 <__env_lock>
    9e0c:	52800018 	mov	w24, #0x0                   	// #0
    9e10:	912a4021 	add	x1, x1, #0xa90
    9e14:	5280003a 	mov	w26, #0x1                   	// #1
    9e18:	94000f1a 	bl	da80 <strcmp>
    9e1c:	2a0003f9 	mov	w25, w0
    9e20:	35000060 	cbnz	w0, 9e2c <__loadlocale+0x6dc>
    9e24:	a94573fb 	ldp	x27, x28, [sp, #80]
    9e28:	17fffe90 	b	9868 <__loadlocale+0x118>
    9e2c:	aa1b03e0 	mov	x0, x27
    9e30:	f0000021 	adrp	x1, 10000 <__env_lock>
    9e34:	5280001a 	mov	w26, #0x0                   	// #0
    9e38:	912a8021 	add	x1, x1, #0xaa0
    9e3c:	52800039 	mov	w25, #0x1                   	// #1
    9e40:	94000f10 	bl	da80 <strcmp>
    9e44:	2a0003f8 	mov	w24, w0
    9e48:	34fffee0 	cbz	w0, 9e24 <__loadlocale+0x6d4>
    9e4c:	aa1b03e0 	mov	x0, x27
    9e50:	f0000021 	adrp	x1, 10000 <__env_lock>
    9e54:	912ac021 	add	x1, x1, #0xab0
    9e58:	94000f0a 	bl	da80 <strcmp>
    9e5c:	7100001f 	cmp	w0, #0x0
    9e60:	52800019 	mov	w25, #0x0                   	// #0
    9e64:	a94573fb 	ldp	x27, x28, [sp, #80]
    9e68:	1a9f17f8 	cset	w24, eq	// eq = none
    9e6c:	17fffe7f 	b	9868 <__loadlocale+0x118>
    9e70:	d10d4800 	sub	x0, x0, #0x352
    9e74:	d28234a1 	mov	x1, #0x11a5                	// #4517
    9e78:	f2a00021 	movk	x1, #0x1, lsl #16
    9e7c:	9ac02420 	lsr	x0, x1, x0
    9e80:	3607d500 	tbz	w0, #0, 9920 <__loadlocale+0x1d0>
    9e84:	17ffff09 	b	9aa8 <__loadlocale+0x358>
    9e88:	f10da81f 	cmp	x0, #0x36a
    9e8c:	54ffd4a1 	b.ne	9920 <__loadlocale+0x1d0>  // b.any
    9e90:	17ffff06 	b	9aa8 <__loadlocale+0x358>
    9e94:	f111941f 	cmp	x0, #0x465
    9e98:	54ffe080 	b.eq	9aa8 <__loadlocale+0x358>  // b.none
    9e9c:	d1138800 	sub	x0, x0, #0x4e2
    9ea0:	f100201f 	cmp	x0, #0x8
    9ea4:	54ffd3e8 	b.hi	9920 <__loadlocale+0x1d0>  // b.pmore
    9ea8:	17ffff00 	b	9aa8 <__loadlocale+0x358>
    9eac:	aa1503e0 	mov	x0, x21
    9eb0:	f0000021 	adrp	x1, 10000 <__env_lock>
    9eb4:	912c8021 	add	x1, x1, #0xb20
    9eb8:	97ffe252 	bl	2800 <strcpy>
    9ebc:	17fffefb 	b	9aa8 <__loadlocale+0x358>
    9ec0:	aa1503e0 	mov	x0, x21
    9ec4:	f0000021 	adrp	x1, 10000 <__env_lock>
    9ec8:	912ca021 	add	x1, x1, #0xb28
    9ecc:	97ffe24d 	bl	2800 <strcpy>
    9ed0:	17fffef6 	b	9aa8 <__loadlocale+0x358>
	...

0000000000009ee0 <__get_locale_env>:
    9ee0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    9ee4:	910003fd 	mov	x29, sp
    9ee8:	a90153f3 	stp	x19, x20, [sp, #16]
    9eec:	2a0103f4 	mov	w20, w1
    9ef0:	aa0003f3 	mov	x19, x0
    9ef4:	f0000021 	adrp	x1, 10000 <__env_lock>
    9ef8:	912fc021 	add	x1, x1, #0xbf0
    9efc:	94000d2d 	bl	d3b0 <_getenv_r>
    9f00:	b4000060 	cbz	x0, 9f0c <__get_locale_env+0x2c>
    9f04:	39400001 	ldrb	w1, [x0]
    9f08:	35000241 	cbnz	w1, 9f50 <__get_locale_env+0x70>
    9f0c:	f0000021 	adrp	x1, 10000 <__env_lock>
    9f10:	91384021 	add	x1, x1, #0xe10
    9f14:	aa1303e0 	mov	x0, x19
    9f18:	f874d821 	ldr	x1, [x1, w20, sxtw #3]
    9f1c:	94000d25 	bl	d3b0 <_getenv_r>
    9f20:	b4000060 	cbz	x0, 9f2c <__get_locale_env+0x4c>
    9f24:	39400001 	ldrb	w1, [x0]
    9f28:	35000141 	cbnz	w1, 9f50 <__get_locale_env+0x70>
    9f2c:	f0000021 	adrp	x1, 10000 <__env_lock>
    9f30:	aa1303e0 	mov	x0, x19
    9f34:	912fe021 	add	x1, x1, #0xbf8
    9f38:	94000d1e 	bl	d3b0 <_getenv_r>
    9f3c:	b4000060 	cbz	x0, 9f48 <__get_locale_env+0x68>
    9f40:	39400001 	ldrb	w1, [x0]
    9f44:	35000061 	cbnz	w1, 9f50 <__get_locale_env+0x70>
    9f48:	90000040 	adrp	x0, 11000 <JIS_action_table>
    9f4c:	913ac000 	add	x0, x0, #0xeb0
    9f50:	a94153f3 	ldp	x19, x20, [sp, #16]
    9f54:	a8c27bfd 	ldp	x29, x30, [sp], #32
    9f58:	d65f03c0 	ret
    9f5c:	00000000 	udf	#0

0000000000009f60 <_setlocale_r>:
    9f60:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
    9f64:	910003fd 	mov	x29, sp
    9f68:	a90153f3 	stp	x19, x20, [sp, #16]
    9f6c:	a9025bf5 	stp	x21, x22, [sp, #32]
    9f70:	a90363f7 	stp	x23, x24, [sp, #48]
    9f74:	aa0003f8 	mov	x24, x0
    9f78:	7100183f 	cmp	w1, #0x6
    9f7c:	54000c28 	b.hi	a100 <_setlocale_r+0x1a0>  // b.pmore
    9f80:	a9046bf9 	stp	x25, x26, [sp, #64]
    9f84:	aa0203f9 	mov	x25, x2
    9f88:	f9002bfb 	str	x27, [sp, #80]
    9f8c:	2a0103fb 	mov	w27, w1
    9f90:	b4001142 	cbz	x2, a1b8 <_setlocale_r+0x258>
    9f94:	f0001fb7 	adrp	x23, 400000 <__sf+0x10>
    9f98:	90000055 	adrp	x21, 11000 <JIS_action_table>
    9f9c:	910e82f7 	add	x23, x23, #0x3a0
    9fa0:	913482b5 	add	x21, x21, #0xd20
    9fa4:	f0001fb6 	adrp	x22, 400000 <__sf+0x10>
    9fa8:	910e02d6 	add	x22, x22, #0x380
    9fac:	aa1703f3 	mov	x19, x23
    9fb0:	aa1503f4 	mov	x20, x21
    9fb4:	910382da 	add	x26, x22, #0xe0
    9fb8:	aa1403e1 	mov	x1, x20
    9fbc:	aa1303e0 	mov	x0, x19
    9fc0:	91008273 	add	x19, x19, #0x20
    9fc4:	97ffe20f 	bl	2800 <strcpy>
    9fc8:	91008294 	add	x20, x20, #0x20
    9fcc:	eb1a027f 	cmp	x19, x26
    9fd0:	54ffff41 	b.ne	9fb8 <_setlocale_r+0x58>  // b.any
    9fd4:	39400320 	ldrb	w0, [x25]
    9fd8:	350005e0 	cbnz	w0, a094 <_setlocale_r+0x134>
    9fdc:	350010fb 	cbnz	w27, a1f8 <_setlocale_r+0x298>
    9fe0:	aa1703f6 	mov	x22, x23
    9fe4:	52800033 	mov	w19, #0x1                   	// #1
    9fe8:	2a1303e1 	mov	w1, w19
    9fec:	aa1803e0 	mov	x0, x24
    9ff0:	97ffffbc 	bl	9ee0 <__get_locale_env>
    9ff4:	aa0003f4 	mov	x20, x0
    9ff8:	11000673 	add	w19, w19, #0x1
    9ffc:	97ffe271 	bl	29c0 <strlen>
    a000:	aa0003e2 	mov	x2, x0
    a004:	aa1403e1 	mov	x1, x20
    a008:	aa1603e0 	mov	x0, x22
    a00c:	f1007c5f 	cmp	x2, #0x1f
    a010:	54000748 	b.hi	a0f8 <_setlocale_r+0x198>  // b.pmore
    a014:	910082d6 	add	x22, x22, #0x20
    a018:	97ffe1fa 	bl	2800 <strcpy>
    a01c:	71001e7f 	cmp	w19, #0x7
    a020:	54fffe41 	b.ne	9fe8 <_setlocale_r+0x88>  // b.any
    a024:	d0001fba 	adrp	x26, 400000 <__sf+0x10>
    a028:	910b035a 	add	x26, x26, #0x2c0
    a02c:	f0000039 	adrp	x25, 11000 <JIS_action_table>
    a030:	aa1a03f6 	mov	x22, x26
    a034:	aa1703f4 	mov	x20, x23
    a038:	91340339 	add	x25, x25, #0xd00
    a03c:	52800033 	mov	w19, #0x1                   	// #1
    a040:	aa1503e1 	mov	x1, x21
    a044:	aa1603e0 	mov	x0, x22
    a048:	97ffe1ee 	bl	2800 <strcpy>
    a04c:	aa1403e2 	mov	x2, x20
    a050:	2a1303e1 	mov	w1, w19
    a054:	aa1903e0 	mov	x0, x25
    a058:	97fffdbe 	bl	9750 <__loadlocale>
    a05c:	b4000e80 	cbz	x0, a22c <_setlocale_r+0x2cc>
    a060:	11000673 	add	w19, w19, #0x1
    a064:	910082d6 	add	x22, x22, #0x20
    a068:	910082b5 	add	x21, x21, #0x20
    a06c:	91008294 	add	x20, x20, #0x20
    a070:	71001e7f 	cmp	w19, #0x7
    a074:	54fffe61 	b.ne	a040 <_setlocale_r+0xe0>  // b.any
    a078:	a94153f3 	ldp	x19, x20, [sp, #16]
    a07c:	a9425bf5 	ldp	x21, x22, [sp, #32]
    a080:	a94363f7 	ldp	x23, x24, [sp, #48]
    a084:	a9446bf9 	ldp	x25, x26, [sp, #64]
    a088:	f9402bfb 	ldr	x27, [sp, #80]
    a08c:	a8c67bfd 	ldp	x29, x30, [sp], #96
    a090:	17fffd7c 	b	9680 <currentlocale>
    a094:	340003fb 	cbz	w27, a110 <_setlocale_r+0x1b0>
    a098:	aa1903e0 	mov	x0, x25
    a09c:	97ffe249 	bl	29c0 <strlen>
    a0a0:	f1007c1f 	cmp	x0, #0x1f
    a0a4:	540002a8 	b.hi	a0f8 <_setlocale_r+0x198>  // b.pmore
    a0a8:	937b7f60 	sbfiz	x0, x27, #5, #32
    a0ac:	aa1903e1 	mov	x1, x25
    a0b0:	8b0002d6 	add	x22, x22, x0
    a0b4:	aa1603e0 	mov	x0, x22
    a0b8:	97ffe1d2 	bl	2800 <strcpy>
    a0bc:	2a1b03e1 	mov	w1, w27
    a0c0:	aa1603e2 	mov	x2, x22
    a0c4:	f0000020 	adrp	x0, 11000 <JIS_action_table>
    a0c8:	91340000 	add	x0, x0, #0xd00
    a0cc:	97fffda1 	bl	9750 <__loadlocale>
    a0d0:	aa0003f3 	mov	x19, x0
    a0d4:	97fffd6b 	bl	9680 <currentlocale>
    a0d8:	a9446bf9 	ldp	x25, x26, [sp, #64]
    a0dc:	f9402bfb 	ldr	x27, [sp, #80]
    a0e0:	aa1303e0 	mov	x0, x19
    a0e4:	a94153f3 	ldp	x19, x20, [sp, #16]
    a0e8:	a9425bf5 	ldp	x21, x22, [sp, #32]
    a0ec:	a94363f7 	ldp	x23, x24, [sp, #48]
    a0f0:	a8c67bfd 	ldp	x29, x30, [sp], #96
    a0f4:	d65f03c0 	ret
    a0f8:	a9446bf9 	ldp	x25, x26, [sp, #64]
    a0fc:	f9402bfb 	ldr	x27, [sp, #80]
    a100:	528002d5 	mov	w21, #0x16                  	// #22
    a104:	d2800013 	mov	x19, #0x0                   	// #0
    a108:	b9000315 	str	w21, [x24]
    a10c:	17fffff5 	b	a0e0 <_setlocale_r+0x180>
    a110:	aa1903e0 	mov	x0, x25
    a114:	528005e1 	mov	w1, #0x2f                  	// #47
    a118:	940008fc 	bl	c508 <strchr>
    a11c:	aa0003f3 	mov	x19, x0
    a120:	b5000060 	cbnz	x0, a12c <_setlocale_r+0x1cc>
    a124:	1400006d 	b	a2d8 <_setlocale_r+0x378>
    a128:	91000673 	add	x19, x19, #0x1
    a12c:	39400660 	ldrb	w0, [x19, #1]
    a130:	7100bc1f 	cmp	w0, #0x2f
    a134:	54ffffa0 	b.eq	a128 <_setlocale_r+0x1c8>  // b.none
    a138:	34fffe00 	cbz	w0, a0f8 <_setlocale_r+0x198>
    a13c:	aa1703fa 	mov	x26, x23
    a140:	52800034 	mov	w20, #0x1                   	// #1
    a144:	cb190262 	sub	x2, x19, x25
    a148:	71007c5f 	cmp	w2, #0x1f
    a14c:	54fffd6c 	b.gt	a0f8 <_setlocale_r+0x198>
    a150:	11000442 	add	w2, w2, #0x1
    a154:	aa1903e1 	mov	x1, x25
    a158:	aa1a03e0 	mov	x0, x26
    a15c:	11000694 	add	w20, w20, #0x1
    a160:	93407c42 	sxtw	x2, w2
    a164:	94000a8f 	bl	cba0 <strlcpy>
    a168:	39400261 	ldrb	w1, [x19]
    a16c:	7100bc3f 	cmp	w1, #0x2f
    a170:	540000a1 	b.ne	a184 <_setlocale_r+0x224>  // b.any
    a174:	d503201f 	nop
    a178:	38401e61 	ldrb	w1, [x19, #1]!
    a17c:	7100bc3f 	cmp	w1, #0x2f
    a180:	54ffffc0 	b.eq	a178 <_setlocale_r+0x218>  // b.none
    a184:	34000921 	cbz	w1, a2a8 <_setlocale_r+0x348>
    a188:	aa1303e3 	mov	x3, x19
    a18c:	d503201f 	nop
    a190:	38401c61 	ldrb	w1, [x3, #1]!
    a194:	7100bc3f 	cmp	w1, #0x2f
    a198:	7a401824 	ccmp	w1, #0x0, #0x4, ne	// ne = any
    a19c:	54ffffa1 	b.ne	a190 <_setlocale_r+0x230>  // b.any
    a1a0:	9100835a 	add	x26, x26, #0x20
    a1a4:	71001e9f 	cmp	w20, #0x7
    a1a8:	54fff3e0 	b.eq	a024 <_setlocale_r+0xc4>  // b.none
    a1ac:	aa1303f9 	mov	x25, x19
    a1b0:	aa0303f3 	mov	x19, x3
    a1b4:	17ffffe4 	b	a144 <_setlocale_r+0x1e4>
    a1b8:	937b7c20 	sbfiz	x0, x1, #5, #32
    a1bc:	f0000021 	adrp	x1, 11000 <JIS_action_table>
    a1c0:	91340021 	add	x1, x1, #0xd00
    a1c4:	7100037f 	cmp	w27, #0x0
    a1c8:	8b010000 	add	x0, x0, x1
    a1cc:	f0000033 	adrp	x19, 11000 <JIS_action_table>
    a1d0:	91304273 	add	x19, x19, #0xc10
    a1d4:	9a800273 	csel	x19, x19, x0, eq	// eq = none
    a1d8:	a9425bf5 	ldp	x21, x22, [sp, #32]
    a1dc:	aa1303e0 	mov	x0, x19
    a1e0:	a94153f3 	ldp	x19, x20, [sp, #16]
    a1e4:	a94363f7 	ldp	x23, x24, [sp, #48]
    a1e8:	a9446bf9 	ldp	x25, x26, [sp, #64]
    a1ec:	f9402bfb 	ldr	x27, [sp, #80]
    a1f0:	a8c67bfd 	ldp	x29, x30, [sp], #96
    a1f4:	d65f03c0 	ret
    a1f8:	2a1b03e1 	mov	w1, w27
    a1fc:	aa1803e0 	mov	x0, x24
    a200:	97ffff38 	bl	9ee0 <__get_locale_env>
    a204:	aa0003f3 	mov	x19, x0
    a208:	97ffe1ee 	bl	29c0 <strlen>
    a20c:	f1007c1f 	cmp	x0, #0x1f
    a210:	54fff748 	b.hi	a0f8 <_setlocale_r+0x198>  // b.pmore
    a214:	937b7f60 	sbfiz	x0, x27, #5, #32
    a218:	aa1303e1 	mov	x1, x19
    a21c:	8b0002d6 	add	x22, x22, x0
    a220:	aa1603e0 	mov	x0, x22
    a224:	97ffe177 	bl	2800 <strcpy>
    a228:	17ffffa5 	b	a0bc <_setlocale_r+0x15c>
    a22c:	d0000020 	adrp	x0, 10000 <__env_lock>
    a230:	b9400315 	ldr	w21, [x24]
    a234:	9129c016 	add	x22, x0, #0xa70
    a238:	52800034 	mov	w20, #0x1                   	// #1
    a23c:	6b14027f 	cmp	w19, w20
    a240:	540000e1 	b.ne	a25c <_setlocale_r+0x2fc>  // b.any
    a244:	14000016 	b	a29c <_setlocale_r+0x33c>
    a248:	11000694 	add	w20, w20, #0x1
    a24c:	910082f7 	add	x23, x23, #0x20
    a250:	9100835a 	add	x26, x26, #0x20
    a254:	6b13029f 	cmp	w20, w19
    a258:	54000220 	b.eq	a29c <_setlocale_r+0x33c>  // b.none
    a25c:	aa1a03e1 	mov	x1, x26
    a260:	aa1703e0 	mov	x0, x23
    a264:	97ffe167 	bl	2800 <strcpy>
    a268:	aa1703e2 	mov	x2, x23
    a26c:	2a1403e1 	mov	w1, w20
    a270:	aa1903e0 	mov	x0, x25
    a274:	97fffd37 	bl	9750 <__loadlocale>
    a278:	b5fffe80 	cbnz	x0, a248 <_setlocale_r+0x2e8>
    a27c:	aa1603e1 	mov	x1, x22
    a280:	aa1703e0 	mov	x0, x23
    a284:	97ffe15f 	bl	2800 <strcpy>
    a288:	aa1703e2 	mov	x2, x23
    a28c:	2a1403e1 	mov	w1, w20
    a290:	aa1903e0 	mov	x0, x25
    a294:	97fffd2f 	bl	9750 <__loadlocale>
    a298:	17ffffec 	b	a248 <_setlocale_r+0x2e8>
    a29c:	a9446bf9 	ldp	x25, x26, [sp, #64]
    a2a0:	f9402bfb 	ldr	x27, [sp, #80]
    a2a4:	17ffff98 	b	a104 <_setlocale_r+0x1a4>
    a2a8:	71001e9f 	cmp	w20, #0x7
    a2ac:	54ffebc0 	b.eq	a024 <_setlocale_r+0xc4>  // b.none
    a2b0:	937b7e80 	sbfiz	x0, x20, #5, #32
    a2b4:	8b0002d6 	add	x22, x22, x0
    a2b8:	d10082c1 	sub	x1, x22, #0x20
    a2bc:	aa1603e0 	mov	x0, x22
    a2c0:	11000694 	add	w20, w20, #0x1
    a2c4:	97ffe14f 	bl	2800 <strcpy>
    a2c8:	910082d6 	add	x22, x22, #0x20
    a2cc:	71001e9f 	cmp	w20, #0x7
    a2d0:	54ffff41 	b.ne	a2b8 <_setlocale_r+0x358>  // b.any
    a2d4:	17ffff54 	b	a024 <_setlocale_r+0xc4>
    a2d8:	aa1903e0 	mov	x0, x25
    a2dc:	97ffe1b9 	bl	29c0 <strlen>
    a2e0:	f1007c1f 	cmp	x0, #0x1f
    a2e4:	54fff0a8 	b.hi	a0f8 <_setlocale_r+0x198>  // b.pmore
    a2e8:	aa1703f3 	mov	x19, x23
    a2ec:	d503201f 	nop
    a2f0:	aa1303e0 	mov	x0, x19
    a2f4:	aa1903e1 	mov	x1, x25
    a2f8:	91008273 	add	x19, x19, #0x20
    a2fc:	97ffe141 	bl	2800 <strcpy>
    a300:	eb1a027f 	cmp	x19, x26
    a304:	54ffff61 	b.ne	a2f0 <_setlocale_r+0x390>  // b.any
    a308:	17ffff47 	b	a024 <_setlocale_r+0xc4>
    a30c:	00000000 	udf	#0

000000000000a310 <__locale_mb_cur_max>:
    a310:	f0000020 	adrp	x0, 11000 <JIS_action_table>
    a314:	39798000 	ldrb	w0, [x0, #3680]
    a318:	d65f03c0 	ret
    a31c:	00000000 	udf	#0

000000000000a320 <setlocale>:
    a320:	f0000023 	adrp	x3, 11000 <JIS_action_table>
    a324:	aa0103e2 	mov	x2, x1
    a328:	2a0003e1 	mov	w1, w0
    a32c:	f9413c60 	ldr	x0, [x3, #632]
    a330:	17ffff0c 	b	9f60 <_setlocale_r>
	...

000000000000a340 <__localeconv_l>:
    a340:	91040000 	add	x0, x0, #0x100
    a344:	d65f03c0 	ret
	...

000000000000a350 <_localeconv_r>:
    a350:	f0000020 	adrp	x0, 11000 <JIS_action_table>
    a354:	91380000 	add	x0, x0, #0xe00
    a358:	d65f03c0 	ret
    a35c:	00000000 	udf	#0

000000000000a360 <localeconv>:
    a360:	f0000020 	adrp	x0, 11000 <JIS_action_table>
    a364:	91380000 	add	x0, x0, #0xe00
    a368:	d65f03c0 	ret
    a36c:	00000000 	udf	#0

000000000000a370 <_fclose_r>:
    a370:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    a374:	910003fd 	mov	x29, sp
    a378:	f90013f5 	str	x21, [sp, #32]
    a37c:	b4000661 	cbz	x1, a448 <_fclose_r+0xd8>
    a380:	a90153f3 	stp	x19, x20, [sp, #16]
    a384:	aa0103f3 	mov	x19, x1
    a388:	aa0003f4 	mov	x20, x0
    a38c:	b4000060 	cbz	x0, a398 <_fclose_r+0x28>
    a390:	f9402401 	ldr	x1, [x0, #72]
    a394:	b4000641 	cbz	x1, a45c <_fclose_r+0xec>
    a398:	b940b260 	ldr	w0, [x19, #176]
    a39c:	79c02261 	ldrsh	w1, [x19, #16]
    a3a0:	37000500 	tbnz	w0, #0, a440 <_fclose_r+0xd0>
    a3a4:	36480601 	tbz	w1, #9, a464 <_fclose_r+0xf4>
    a3a8:	aa1303e1 	mov	x1, x19
    a3ac:	aa1403e0 	mov	x0, x20
    a3b0:	94000774 	bl	c180 <__sflush_r>
    a3b4:	2a0003f5 	mov	w21, w0
    a3b8:	f9402a62 	ldr	x2, [x19, #80]
    a3bc:	b40000c2 	cbz	x2, a3d4 <_fclose_r+0x64>
    a3c0:	f9401a61 	ldr	x1, [x19, #48]
    a3c4:	aa1403e0 	mov	x0, x20
    a3c8:	d63f0040 	blr	x2
    a3cc:	7100001f 	cmp	w0, #0x0
    a3d0:	5a9fa2b5 	csinv	w21, w21, wzr, ge	// ge = tcont
    a3d4:	79402260 	ldrh	w0, [x19, #16]
    a3d8:	37380620 	tbnz	w0, #7, a49c <_fclose_r+0x12c>
    a3dc:	f9402e61 	ldr	x1, [x19, #88]
    a3e0:	b40000e1 	cbz	x1, a3fc <_fclose_r+0x8c>
    a3e4:	9101d260 	add	x0, x19, #0x74
    a3e8:	eb00003f 	cmp	x1, x0
    a3ec:	54000060 	b.eq	a3f8 <_fclose_r+0x88>  // b.none
    a3f0:	aa1403e0 	mov	x0, x20
    a3f4:	94000a43 	bl	cd00 <_free_r>
    a3f8:	f9002e7f 	str	xzr, [x19, #88]
    a3fc:	f9403e61 	ldr	x1, [x19, #120]
    a400:	b4000081 	cbz	x1, a410 <_fclose_r+0xa0>
    a404:	aa1403e0 	mov	x0, x20
    a408:	94000a3e 	bl	cd00 <_free_r>
    a40c:	f9003e7f 	str	xzr, [x19, #120]
    a410:	97ffe36c 	bl	31c0 <__sfp_lock_acquire>
    a414:	7900227f 	strh	wzr, [x19, #16]
    a418:	b940b260 	ldr	w0, [x19, #176]
    a41c:	360003a0 	tbz	w0, #0, a490 <_fclose_r+0x120>
    a420:	f9405260 	ldr	x0, [x19, #160]
    a424:	97fffc7b 	bl	9610 <__retarget_lock_close_recursive>
    a428:	97ffe36a 	bl	31d0 <__sfp_lock_release>
    a42c:	a94153f3 	ldp	x19, x20, [sp, #16]
    a430:	2a1503e0 	mov	w0, w21
    a434:	f94013f5 	ldr	x21, [sp, #32]
    a438:	a8c37bfd 	ldp	x29, x30, [sp], #48
    a43c:	d65f03c0 	ret
    a440:	35fffb41 	cbnz	w1, a3a8 <_fclose_r+0x38>
    a444:	a94153f3 	ldp	x19, x20, [sp, #16]
    a448:	52800015 	mov	w21, #0x0                   	// #0
    a44c:	2a1503e0 	mov	w0, w21
    a450:	f94013f5 	ldr	x21, [sp, #32]
    a454:	a8c37bfd 	ldp	x29, x30, [sp], #48
    a458:	d65f03c0 	ret
    a45c:	97ffe33d 	bl	3150 <__sinit>
    a460:	17ffffce 	b	a398 <_fclose_r+0x28>
    a464:	f9405260 	ldr	x0, [x19, #160]
    a468:	97fffc72 	bl	9630 <__retarget_lock_acquire_recursive>
    a46c:	79c02260 	ldrsh	w0, [x19, #16]
    a470:	35fff9c0 	cbnz	w0, a3a8 <_fclose_r+0x38>
    a474:	b940b260 	ldr	w0, [x19, #176]
    a478:	3707fe60 	tbnz	w0, #0, a444 <_fclose_r+0xd4>
    a47c:	f9405260 	ldr	x0, [x19, #160]
    a480:	52800015 	mov	w21, #0x0                   	// #0
    a484:	97fffc7b 	bl	9670 <__retarget_lock_release_recursive>
    a488:	a94153f3 	ldp	x19, x20, [sp, #16]
    a48c:	17fffff0 	b	a44c <_fclose_r+0xdc>
    a490:	f9405260 	ldr	x0, [x19, #160]
    a494:	97fffc77 	bl	9670 <__retarget_lock_release_recursive>
    a498:	17ffffe2 	b	a420 <_fclose_r+0xb0>
    a49c:	f9400e61 	ldr	x1, [x19, #24]
    a4a0:	aa1403e0 	mov	x0, x20
    a4a4:	94000a17 	bl	cd00 <_free_r>
    a4a8:	17ffffcd 	b	a3dc <_fclose_r+0x6c>
    a4ac:	00000000 	udf	#0

000000000000a4b0 <fclose>:
    a4b0:	f0000022 	adrp	x2, 11000 <JIS_action_table>
    a4b4:	aa0003e1 	mov	x1, x0
    a4b8:	f9413c40 	ldr	x0, [x2, #632]
    a4bc:	17ffffad 	b	a370 <_fclose_r>

000000000000a4c0 <memchr>:
    a4c0:	b4000682 	cbz	x2, a590 <memchr+0xd0>
    a4c4:	52808025 	mov	w5, #0x401                 	// #1025
    a4c8:	72a80205 	movk	w5, #0x4010, lsl #16
    a4cc:	4e010c20 	dup	v0.16b, w1
    a4d0:	927be803 	and	x3, x0, #0xffffffffffffffe0
    a4d4:	4e040ca5 	dup	v5.4s, w5
    a4d8:	f2401009 	ands	x9, x0, #0x1f
    a4dc:	9240104a 	and	x10, x2, #0x1f
    a4e0:	54000200 	b.eq	a520 <memchr+0x60>  // b.none
    a4e4:	4cdfa061 	ld1	{v1.16b, v2.16b}, [x3], #32
    a4e8:	d1008124 	sub	x4, x9, #0x20
    a4ec:	ab040042 	adds	x2, x2, x4
    a4f0:	6e208c23 	cmeq	v3.16b, v1.16b, v0.16b
    a4f4:	6e208c44 	cmeq	v4.16b, v2.16b, v0.16b
    a4f8:	4e251c63 	and	v3.16b, v3.16b, v5.16b
    a4fc:	4e251c84 	and	v4.16b, v4.16b, v5.16b
    a500:	4e24bc66 	addp	v6.16b, v3.16b, v4.16b
    a504:	4e26bcc6 	addp	v6.16b, v6.16b, v6.16b
    a508:	4e083cc6 	mov	x6, v6.d[0]
    a50c:	d37ff924 	lsl	x4, x9, #1
    a510:	9ac424c6 	lsr	x6, x6, x4
    a514:	9ac420c6 	lsl	x6, x6, x4
    a518:	54000229 	b.ls	a55c <memchr+0x9c>  // b.plast
    a51c:	b50002c6 	cbnz	x6, a574 <memchr+0xb4>
    a520:	4cdfa061 	ld1	{v1.16b, v2.16b}, [x3], #32
    a524:	f1008042 	subs	x2, x2, #0x20
    a528:	6e208c23 	cmeq	v3.16b, v1.16b, v0.16b
    a52c:	6e208c44 	cmeq	v4.16b, v2.16b, v0.16b
    a530:	540000a9 	b.ls	a544 <memchr+0x84>  // b.plast
    a534:	4ea41c66 	orr	v6.16b, v3.16b, v4.16b
    a538:	4ee6bcc6 	addp	v6.2d, v6.2d, v6.2d
    a53c:	4e083cc6 	mov	x6, v6.d[0]
    a540:	b4ffff06 	cbz	x6, a520 <memchr+0x60>
    a544:	4e251c63 	and	v3.16b, v3.16b, v5.16b
    a548:	4e251c84 	and	v4.16b, v4.16b, v5.16b
    a54c:	4e24bc66 	addp	v6.16b, v3.16b, v4.16b
    a550:	4e26bcc6 	addp	v6.16b, v6.16b, v6.16b
    a554:	4e083cc6 	mov	x6, v6.d[0]
    a558:	540000e8 	b.hi	a574 <memchr+0xb4>  // b.pmore
    a55c:	8b090144 	add	x4, x10, x9
    a560:	92401084 	and	x4, x4, #0x1f
    a564:	d1008084 	sub	x4, x4, #0x20
    a568:	cb0407e4 	neg	x4, x4, lsl #1
    a56c:	9ac420c6 	lsl	x6, x6, x4
    a570:	9ac424c6 	lsr	x6, x6, x4
    a574:	dac000c6 	rbit	x6, x6
    a578:	d1008063 	sub	x3, x3, #0x20
    a57c:	f10000df 	cmp	x6, #0x0
    a580:	dac010c6 	clz	x6, x6
    a584:	8b460460 	add	x0, x3, x6, lsr #1
    a588:	9a8003e0 	csel	x0, xzr, x0, eq	// eq = none
    a58c:	d65f03c0 	ret
    a590:	d2800000 	mov	x0, #0x0                   	// #0
    a594:	d65f03c0 	ret
	...

000000000000a5a0 <__swsetup_r>:
    a5a0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    a5a4:	f0000022 	adrp	x2, 11000 <JIS_action_table>
    a5a8:	910003fd 	mov	x29, sp
    a5ac:	a90153f3 	stp	x19, x20, [sp, #16]
    a5b0:	aa0003f4 	mov	x20, x0
    a5b4:	aa0103f3 	mov	x19, x1
    a5b8:	f9413c40 	ldr	x0, [x2, #632]
    a5bc:	b4000060 	cbz	x0, a5c8 <__swsetup_r+0x28>
    a5c0:	f9402401 	ldr	x1, [x0, #72]
    a5c4:	b4000761 	cbz	x1, a6b0 <__swsetup_r+0x110>
    a5c8:	79c02262 	ldrsh	w2, [x19, #16]
    a5cc:	36180462 	tbz	w2, #3, a658 <__swsetup_r+0xb8>
    a5d0:	f9400e61 	ldr	x1, [x19, #24]
    a5d4:	b40002c1 	cbz	x1, a62c <__swsetup_r+0x8c>
    a5d8:	36000142 	tbz	w2, #0, a600 <__swsetup_r+0x60>
    a5dc:	b9402260 	ldr	w0, [x19, #32]
    a5e0:	b9000e7f 	str	wzr, [x19, #12]
    a5e4:	4b0003e0 	neg	w0, w0
    a5e8:	b9002a60 	str	w0, [x19, #40]
    a5ec:	52800000 	mov	w0, #0x0                   	// #0
    a5f0:	b4000141 	cbz	x1, a618 <__swsetup_r+0x78>
    a5f4:	a94153f3 	ldp	x19, x20, [sp, #16]
    a5f8:	a8c27bfd 	ldp	x29, x30, [sp], #32
    a5fc:	d65f03c0 	ret
    a600:	52800000 	mov	w0, #0x0                   	// #0
    a604:	37080042 	tbnz	w2, #1, a60c <__swsetup_r+0x6c>
    a608:	b9402260 	ldr	w0, [x19, #32]
    a60c:	b9000e60 	str	w0, [x19, #12]
    a610:	52800000 	mov	w0, #0x0                   	// #0
    a614:	b5ffff01 	cbnz	x1, a5f4 <__swsetup_r+0x54>
    a618:	363ffee2 	tbz	w2, #7, a5f4 <__swsetup_r+0x54>
    a61c:	321a0042 	orr	w2, w2, #0x40
    a620:	12800000 	mov	w0, #0xffffffff            	// #-1
    a624:	79002262 	strh	w2, [x19, #16]
    a628:	17fffff3 	b	a5f4 <__swsetup_r+0x54>
    a62c:	52805000 	mov	w0, #0x280                 	// #640
    a630:	0a000040 	and	w0, w2, w0
    a634:	7108001f 	cmp	w0, #0x200
    a638:	54fffd00 	b.eq	a5d8 <__swsetup_r+0x38>  // b.none
    a63c:	aa1303e1 	mov	x1, x19
    a640:	aa1403e0 	mov	x0, x20
    a644:	94000023 	bl	a6d0 <__smakebuf_r>
    a648:	79c02262 	ldrsh	w2, [x19, #16]
    a64c:	f9400e61 	ldr	x1, [x19, #24]
    a650:	3607fd82 	tbz	w2, #0, a600 <__swsetup_r+0x60>
    a654:	17ffffe2 	b	a5dc <__swsetup_r+0x3c>
    a658:	36200302 	tbz	w2, #4, a6b8 <__swsetup_r+0x118>
    a65c:	371000c2 	tbnz	w2, #2, a674 <__swsetup_r+0xd4>
    a660:	f9400e61 	ldr	x1, [x19, #24]
    a664:	321d0042 	orr	w2, w2, #0x8
    a668:	79002262 	strh	w2, [x19, #16]
    a66c:	b5fffb61 	cbnz	x1, a5d8 <__swsetup_r+0x38>
    a670:	17ffffef 	b	a62c <__swsetup_r+0x8c>
    a674:	f9402e61 	ldr	x1, [x19, #88]
    a678:	b4000101 	cbz	x1, a698 <__swsetup_r+0xf8>
    a67c:	9101d260 	add	x0, x19, #0x74
    a680:	eb00003f 	cmp	x1, x0
    a684:	54000080 	b.eq	a694 <__swsetup_r+0xf4>  // b.none
    a688:	aa1403e0 	mov	x0, x20
    a68c:	9400099d 	bl	cd00 <_free_r>
    a690:	79c02262 	ldrsh	w2, [x19, #16]
    a694:	f9002e7f 	str	xzr, [x19, #88]
    a698:	f9400e61 	ldr	x1, [x19, #24]
    a69c:	12800480 	mov	w0, #0xffffffdb            	// #-37
    a6a0:	0a000042 	and	w2, w2, w0
    a6a4:	f9000261 	str	x1, [x19]
    a6a8:	b9000a7f 	str	wzr, [x19, #8]
    a6ac:	17ffffee 	b	a664 <__swsetup_r+0xc4>
    a6b0:	97ffe2a8 	bl	3150 <__sinit>
    a6b4:	17ffffc5 	b	a5c8 <__swsetup_r+0x28>
    a6b8:	52800120 	mov	w0, #0x9                   	// #9
    a6bc:	321a0042 	orr	w2, w2, #0x40
    a6c0:	b9000280 	str	w0, [x20]
    a6c4:	17ffffd7 	b	a620 <__swsetup_r+0x80>
	...

000000000000a6d0 <__smakebuf_r>:
    a6d0:	a9b57bfd 	stp	x29, x30, [sp, #-176]!
    a6d4:	910003fd 	mov	x29, sp
    a6d8:	79c02022 	ldrsh	w2, [x1, #16]
    a6dc:	a90153f3 	stp	x19, x20, [sp, #16]
    a6e0:	aa0103f3 	mov	x19, x1
    a6e4:	36080122 	tbz	w2, #1, a708 <__smakebuf_r+0x38>
    a6e8:	9101dc20 	add	x0, x1, #0x77
    a6ec:	52800021 	mov	w1, #0x1                   	// #1
    a6f0:	f9000260 	str	x0, [x19]
    a6f4:	f9000e60 	str	x0, [x19, #24]
    a6f8:	b9002261 	str	w1, [x19, #32]
    a6fc:	a94153f3 	ldp	x19, x20, [sp, #16]
    a700:	a8cb7bfd 	ldp	x29, x30, [sp], #176
    a704:	d65f03c0 	ret
    a708:	79c02421 	ldrsh	w1, [x1, #18]
    a70c:	aa0003f4 	mov	x20, x0
    a710:	a9025bf5 	stp	x21, x22, [sp, #32]
    a714:	f9001bf7 	str	x23, [sp, #48]
    a718:	37f80381 	tbnz	w1, #31, a788 <__smakebuf_r+0xb8>
    a71c:	910123e2 	add	x2, sp, #0x48
    a720:	94000b50 	bl	d460 <_fstat_r>
    a724:	37f80300 	tbnz	w0, #31, a784 <__smakebuf_r+0xb4>
    a728:	b9404fe0 	ldr	w0, [sp, #76]
    a72c:	d2808016 	mov	x22, #0x400                 	// #1024
    a730:	52810015 	mov	w21, #0x800                 	// #2048
    a734:	aa1603e1 	mov	x1, x22
    a738:	12140c00 	and	w0, w0, #0xf000
    a73c:	7140081f 	cmp	w0, #0x2, lsl #12
    a740:	aa1403e0 	mov	x0, x20
    a744:	1a9f17f7 	cset	w23, eq	// eq = none
    a748:	97fff946 	bl	8c60 <_malloc_r>
    a74c:	b5000320 	cbnz	x0, a7b0 <__smakebuf_r+0xe0>
    a750:	79c02260 	ldrsh	w0, [x19, #16]
    a754:	37480560 	tbnz	w0, #9, a800 <__smakebuf_r+0x130>
    a758:	121e7400 	and	w0, w0, #0xfffffffc
    a75c:	9101de61 	add	x1, x19, #0x77
    a760:	a9425bf5 	ldp	x21, x22, [sp, #32]
    a764:	321f0000 	orr	w0, w0, #0x2
    a768:	f9401bf7 	ldr	x23, [sp, #48]
    a76c:	52800022 	mov	w2, #0x1                   	// #1
    a770:	f9000261 	str	x1, [x19]
    a774:	79002260 	strh	w0, [x19, #16]
    a778:	f9000e61 	str	x1, [x19, #24]
    a77c:	b9002262 	str	w2, [x19, #32]
    a780:	17ffffdf 	b	a6fc <__smakebuf_r+0x2c>
    a784:	79c02262 	ldrsh	w2, [x19, #16]
    a788:	f279005f 	tst	x2, #0x80
    a78c:	d2800800 	mov	x0, #0x40                  	// #64
    a790:	d2808016 	mov	x22, #0x400                 	// #1024
    a794:	9a8002d6 	csel	x22, x22, x0, eq	// eq = none
    a798:	aa1603e1 	mov	x1, x22
    a79c:	aa1403e0 	mov	x0, x20
    a7a0:	52800017 	mov	w23, #0x0                   	// #0
    a7a4:	52800015 	mov	w21, #0x0                   	// #0
    a7a8:	97fff92e 	bl	8c60 <_malloc_r>
    a7ac:	b4fffd20 	cbz	x0, a750 <__smakebuf_r+0x80>
    a7b0:	79c02262 	ldrsh	w2, [x19, #16]
    a7b4:	f9000260 	str	x0, [x19]
    a7b8:	32190042 	orr	w2, w2, #0x80
    a7bc:	79002262 	strh	w2, [x19, #16]
    a7c0:	f9000e60 	str	x0, [x19, #24]
    a7c4:	b9002276 	str	w22, [x19, #32]
    a7c8:	35000117 	cbnz	w23, a7e8 <__smakebuf_r+0x118>
    a7cc:	2a150042 	orr	w2, w2, w21
    a7d0:	79002262 	strh	w2, [x19, #16]
    a7d4:	a94153f3 	ldp	x19, x20, [sp, #16]
    a7d8:	a9425bf5 	ldp	x21, x22, [sp, #32]
    a7dc:	f9401bf7 	ldr	x23, [sp, #48]
    a7e0:	a8cb7bfd 	ldp	x29, x30, [sp], #176
    a7e4:	d65f03c0 	ret
    a7e8:	79c02661 	ldrsh	w1, [x19, #18]
    a7ec:	aa1403e0 	mov	x0, x20
    a7f0:	94000c5c 	bl	d960 <_isatty_r>
    a7f4:	350000c0 	cbnz	w0, a80c <__smakebuf_r+0x13c>
    a7f8:	79c02262 	ldrsh	w2, [x19, #16]
    a7fc:	17fffff4 	b	a7cc <__smakebuf_r+0xfc>
    a800:	a9425bf5 	ldp	x21, x22, [sp, #32]
    a804:	f9401bf7 	ldr	x23, [sp, #48]
    a808:	17ffffbd 	b	a6fc <__smakebuf_r+0x2c>
    a80c:	79402262 	ldrh	w2, [x19, #16]
    a810:	121e7442 	and	w2, w2, #0xfffffffc
    a814:	32000042 	orr	w2, w2, #0x1
    a818:	13003c42 	sxth	w2, w2
    a81c:	17ffffec 	b	a7cc <__smakebuf_r+0xfc>

000000000000a820 <__swhatbuf_r>:
    a820:	a9b67bfd 	stp	x29, x30, [sp, #-160]!
    a824:	910003fd 	mov	x29, sp
    a828:	a90153f3 	stp	x19, x20, [sp, #16]
    a82c:	aa0103f3 	mov	x19, x1
    a830:	79c02421 	ldrsh	w1, [x1, #18]
    a834:	f90013f5 	str	x21, [sp, #32]
    a838:	aa0203f4 	mov	x20, x2
    a83c:	aa0303f5 	mov	x21, x3
    a840:	37f80201 	tbnz	w1, #31, a880 <__swhatbuf_r+0x60>
    a844:	9100e3e2 	add	x2, sp, #0x38
    a848:	94000b06 	bl	d460 <_fstat_r>
    a84c:	37f801a0 	tbnz	w0, #31, a880 <__swhatbuf_r+0x60>
    a850:	b9403fe2 	ldr	w2, [sp, #60]
    a854:	d2808001 	mov	x1, #0x400                 	// #1024
    a858:	52810000 	mov	w0, #0x800                 	// #2048
    a85c:	12140c42 	and	w2, w2, #0xf000
    a860:	7140085f 	cmp	w2, #0x2, lsl #12
    a864:	1a9f17e2 	cset	w2, eq	// eq = none
    a868:	b90002a2 	str	w2, [x21]
    a86c:	f94013f5 	ldr	x21, [sp, #32]
    a870:	f9000281 	str	x1, [x20]
    a874:	a94153f3 	ldp	x19, x20, [sp, #16]
    a878:	a8ca7bfd 	ldp	x29, x30, [sp], #160
    a87c:	d65f03c0 	ret
    a880:	79402264 	ldrh	w4, [x19, #16]
    a884:	52800002 	mov	w2, #0x0                   	// #0
    a888:	b90002a2 	str	w2, [x21]
    a88c:	d2808003 	mov	x3, #0x400                 	// #1024
    a890:	f94013f5 	ldr	x21, [sp, #32]
    a894:	f279009f 	tst	x4, #0x80
    a898:	d2800801 	mov	x1, #0x40                  	// #64
    a89c:	9a831021 	csel	x1, x1, x3, ne	// ne = any
    a8a0:	f9000281 	str	x1, [x20]
    a8a4:	52800000 	mov	w0, #0x0                   	// #0
    a8a8:	a94153f3 	ldp	x19, x20, [sp, #16]
    a8ac:	a8ca7bfd 	ldp	x29, x30, [sp], #160
    a8b0:	d65f03c0 	ret
	...

000000000000a8c0 <memcpy>:
    a8c0:	f9800020 	prfm	pldl1keep, [x1]
    a8c4:	8b020024 	add	x4, x1, x2
    a8c8:	8b020005 	add	x5, x0, x2
    a8cc:	f100405f 	cmp	x2, #0x10
    a8d0:	54000209 	b.ls	a910 <memcpy+0x50>  // b.plast
    a8d4:	f101805f 	cmp	x2, #0x60
    a8d8:	54000648 	b.hi	a9a0 <memcpy+0xe0>  // b.pmore
    a8dc:	d1000449 	sub	x9, x2, #0x1
    a8e0:	a9401c26 	ldp	x6, x7, [x1]
    a8e4:	37300469 	tbnz	w9, #6, a970 <memcpy+0xb0>
    a8e8:	a97f348c 	ldp	x12, x13, [x4, #-16]
    a8ec:	362800a9 	tbz	w9, #5, a900 <memcpy+0x40>
    a8f0:	a9412428 	ldp	x8, x9, [x1, #16]
    a8f4:	a97e2c8a 	ldp	x10, x11, [x4, #-32]
    a8f8:	a9012408 	stp	x8, x9, [x0, #16]
    a8fc:	a93e2caa 	stp	x10, x11, [x5, #-32]
    a900:	a9001c06 	stp	x6, x7, [x0]
    a904:	a93f34ac 	stp	x12, x13, [x5, #-16]
    a908:	d65f03c0 	ret
    a90c:	d503201f 	nop
    a910:	f100205f 	cmp	x2, #0x8
    a914:	540000e3 	b.cc	a930 <memcpy+0x70>  // b.lo, b.ul, b.last
    a918:	f9400026 	ldr	x6, [x1]
    a91c:	f85f8087 	ldur	x7, [x4, #-8]
    a920:	f9000006 	str	x6, [x0]
    a924:	f81f80a7 	stur	x7, [x5, #-8]
    a928:	d65f03c0 	ret
    a92c:	d503201f 	nop
    a930:	361000c2 	tbz	w2, #2, a948 <memcpy+0x88>
    a934:	b9400026 	ldr	w6, [x1]
    a938:	b85fc087 	ldur	w7, [x4, #-4]
    a93c:	b9000006 	str	w6, [x0]
    a940:	b81fc0a7 	stur	w7, [x5, #-4]
    a944:	d65f03c0 	ret
    a948:	b4000102 	cbz	x2, a968 <memcpy+0xa8>
    a94c:	d341fc49 	lsr	x9, x2, #1
    a950:	39400026 	ldrb	w6, [x1]
    a954:	385ff087 	ldurb	w7, [x4, #-1]
    a958:	38696828 	ldrb	w8, [x1, x9]
    a95c:	39000006 	strb	w6, [x0]
    a960:	38296808 	strb	w8, [x0, x9]
    a964:	381ff0a7 	sturb	w7, [x5, #-1]
    a968:	d65f03c0 	ret
    a96c:	d503201f 	nop
    a970:	a9412428 	ldp	x8, x9, [x1, #16]
    a974:	a9422c2a 	ldp	x10, x11, [x1, #32]
    a978:	a943342c 	ldp	x12, x13, [x1, #48]
    a97c:	a97e0881 	ldp	x1, x2, [x4, #-32]
    a980:	a97f0c84 	ldp	x4, x3, [x4, #-16]
    a984:	a9001c06 	stp	x6, x7, [x0]
    a988:	a9012408 	stp	x8, x9, [x0, #16]
    a98c:	a9022c0a 	stp	x10, x11, [x0, #32]
    a990:	a903340c 	stp	x12, x13, [x0, #48]
    a994:	a93e08a1 	stp	x1, x2, [x5, #-32]
    a998:	a93f0ca4 	stp	x4, x3, [x5, #-16]
    a99c:	d65f03c0 	ret
    a9a0:	92400c09 	and	x9, x0, #0xf
    a9a4:	927cec03 	and	x3, x0, #0xfffffffffffffff0
    a9a8:	a940342c 	ldp	x12, x13, [x1]
    a9ac:	cb090021 	sub	x1, x1, x9
    a9b0:	8b090042 	add	x2, x2, x9
    a9b4:	a9411c26 	ldp	x6, x7, [x1, #16]
    a9b8:	a900340c 	stp	x12, x13, [x0]
    a9bc:	a9422428 	ldp	x8, x9, [x1, #32]
    a9c0:	a9432c2a 	ldp	x10, x11, [x1, #48]
    a9c4:	a9c4342c 	ldp	x12, x13, [x1, #64]!
    a9c8:	f1024042 	subs	x2, x2, #0x90
    a9cc:	54000169 	b.ls	a9f8 <memcpy+0x138>  // b.plast
    a9d0:	a9011c66 	stp	x6, x7, [x3, #16]
    a9d4:	a9411c26 	ldp	x6, x7, [x1, #16]
    a9d8:	a9022468 	stp	x8, x9, [x3, #32]
    a9dc:	a9422428 	ldp	x8, x9, [x1, #32]
    a9e0:	a9032c6a 	stp	x10, x11, [x3, #48]
    a9e4:	a9432c2a 	ldp	x10, x11, [x1, #48]
    a9e8:	a984346c 	stp	x12, x13, [x3, #64]!
    a9ec:	a9c4342c 	ldp	x12, x13, [x1, #64]!
    a9f0:	f1010042 	subs	x2, x2, #0x40
    a9f4:	54fffee8 	b.hi	a9d0 <memcpy+0x110>  // b.pmore
    a9f8:	a97c0881 	ldp	x1, x2, [x4, #-64]
    a9fc:	a9011c66 	stp	x6, x7, [x3, #16]
    aa00:	a97d1c86 	ldp	x6, x7, [x4, #-48]
    aa04:	a9022468 	stp	x8, x9, [x3, #32]
    aa08:	a97e2488 	ldp	x8, x9, [x4, #-32]
    aa0c:	a9032c6a 	stp	x10, x11, [x3, #48]
    aa10:	a97f2c8a 	ldp	x10, x11, [x4, #-16]
    aa14:	a904346c 	stp	x12, x13, [x3, #64]
    aa18:	a93c08a1 	stp	x1, x2, [x5, #-64]
    aa1c:	a93d1ca6 	stp	x6, x7, [x5, #-48]
    aa20:	a93e24a8 	stp	x8, x9, [x5, #-32]
    aa24:	a93f2caa 	stp	x10, x11, [x5, #-16]
    aa28:	d65f03c0 	ret
	...

000000000000aa40 <memmove>:
    aa40:	cb010005 	sub	x5, x0, x1
    aa44:	f101805f 	cmp	x2, #0x60
    aa48:	fa4280a2 	ccmp	x5, x2, #0x2, hi	// hi = pmore
    aa4c:	54fff3a2 	b.cs	a8c0 <memcpy>  // b.hs, b.nlast
    aa50:	b40004c5 	cbz	x5, aae8 <memmove+0xa8>
    aa54:	8b020004 	add	x4, x0, x2
    aa58:	8b020023 	add	x3, x1, x2
    aa5c:	92400c85 	and	x5, x4, #0xf
    aa60:	a97f346c 	ldp	x12, x13, [x3, #-16]
    aa64:	cb050063 	sub	x3, x3, x5
    aa68:	cb050042 	sub	x2, x2, x5
    aa6c:	a97f1c66 	ldp	x6, x7, [x3, #-16]
    aa70:	a93f348c 	stp	x12, x13, [x4, #-16]
    aa74:	a97e2468 	ldp	x8, x9, [x3, #-32]
    aa78:	a97d2c6a 	ldp	x10, x11, [x3, #-48]
    aa7c:	a9fc346c 	ldp	x12, x13, [x3, #-64]!
    aa80:	cb050084 	sub	x4, x4, x5
    aa84:	f1020042 	subs	x2, x2, #0x80
    aa88:	54000189 	b.ls	aab8 <memmove+0x78>  // b.plast
    aa8c:	d503201f 	nop
    aa90:	a93f1c86 	stp	x6, x7, [x4, #-16]
    aa94:	a97f1c66 	ldp	x6, x7, [x3, #-16]
    aa98:	a93e2488 	stp	x8, x9, [x4, #-32]
    aa9c:	a97e2468 	ldp	x8, x9, [x3, #-32]
    aaa0:	a93d2c8a 	stp	x10, x11, [x4, #-48]
    aaa4:	a97d2c6a 	ldp	x10, x11, [x3, #-48]
    aaa8:	a9bc348c 	stp	x12, x13, [x4, #-64]!
    aaac:	a9fc346c 	ldp	x12, x13, [x3, #-64]!
    aab0:	f1010042 	subs	x2, x2, #0x40
    aab4:	54fffee8 	b.hi	aa90 <memmove+0x50>  // b.pmore
    aab8:	a9431422 	ldp	x2, x5, [x1, #48]
    aabc:	a93f1c86 	stp	x6, x7, [x4, #-16]
    aac0:	a9421c26 	ldp	x6, x7, [x1, #32]
    aac4:	a93e2488 	stp	x8, x9, [x4, #-32]
    aac8:	a9412428 	ldp	x8, x9, [x1, #16]
    aacc:	a93d2c8a 	stp	x10, x11, [x4, #-48]
    aad0:	a9402c2a 	ldp	x10, x11, [x1]
    aad4:	a93c348c 	stp	x12, x13, [x4, #-64]
    aad8:	a9031402 	stp	x2, x5, [x0, #48]
    aadc:	a9021c06 	stp	x6, x7, [x0, #32]
    aae0:	a9012408 	stp	x8, x9, [x0, #16]
    aae4:	a9002c0a 	stp	x10, x11, [x0]
    aae8:	d65f03c0 	ret
	...

000000000000ab00 <memset>:
    ab00:	4e010c20 	dup	v0.16b, w1
    ab04:	8b020004 	add	x4, x0, x2
    ab08:	f101805f 	cmp	x2, #0x60
    ab0c:	540003c8 	b.hi	ab84 <memset+0x84>  // b.pmore
    ab10:	f100405f 	cmp	x2, #0x10
    ab14:	54000202 	b.cs	ab54 <memset+0x54>  // b.hs, b.nlast
    ab18:	4e083c01 	mov	x1, v0.d[0]
    ab1c:	361800a2 	tbz	w2, #3, ab30 <memset+0x30>
    ab20:	f9000001 	str	x1, [x0]
    ab24:	f81f8081 	stur	x1, [x4, #-8]
    ab28:	d65f03c0 	ret
    ab2c:	d503201f 	nop
    ab30:	36100082 	tbz	w2, #2, ab40 <memset+0x40>
    ab34:	b9000001 	str	w1, [x0]
    ab38:	b81fc081 	stur	w1, [x4, #-4]
    ab3c:	d65f03c0 	ret
    ab40:	b4000082 	cbz	x2, ab50 <memset+0x50>
    ab44:	39000001 	strb	w1, [x0]
    ab48:	36080042 	tbz	w2, #1, ab50 <memset+0x50>
    ab4c:	781fe081 	sturh	w1, [x4, #-2]
    ab50:	d65f03c0 	ret
    ab54:	3d800000 	str	q0, [x0]
    ab58:	373000c2 	tbnz	w2, #6, ab70 <memset+0x70>
    ab5c:	3c9f0080 	stur	q0, [x4, #-16]
    ab60:	36280062 	tbz	w2, #5, ab6c <memset+0x6c>
    ab64:	3d800400 	str	q0, [x0, #16]
    ab68:	3c9e0080 	stur	q0, [x4, #-32]
    ab6c:	d65f03c0 	ret
    ab70:	3d800400 	str	q0, [x0, #16]
    ab74:	ad010000 	stp	q0, q0, [x0, #32]
    ab78:	ad3f0080 	stp	q0, q0, [x4, #-32]
    ab7c:	d65f03c0 	ret
    ab80:	d503201f 	nop
    ab84:	12001c21 	and	w1, w1, #0xff
    ab88:	927cec03 	and	x3, x0, #0xfffffffffffffff0
    ab8c:	3d800000 	str	q0, [x0]
    ab90:	f104005f 	cmp	x2, #0x100
    ab94:	7a402820 	ccmp	w1, #0x0, #0x0, cs	// cs = hs, nlast
    ab98:	54000180 	b.eq	abc8 <memset+0xc8>  // b.none
    ab9c:	cb030082 	sub	x2, x4, x3
    aba0:	d1004063 	sub	x3, x3, #0x10
    aba4:	d1014042 	sub	x2, x2, #0x50
    aba8:	ad010060 	stp	q0, q0, [x3, #32]
    abac:	ad820060 	stp	q0, q0, [x3, #64]!
    abb0:	f1010042 	subs	x2, x2, #0x40
    abb4:	54ffffa8 	b.hi	aba8 <memset+0xa8>  // b.pmore
    abb8:	ad3e0080 	stp	q0, q0, [x4, #-64]
    abbc:	ad3f0080 	stp	q0, q0, [x4, #-32]
    abc0:	d65f03c0 	ret
    abc4:	d503201f 	nop
    abc8:	d53b00e5 	mrs	x5, dczid_el0
    abcc:	3727fe85 	tbnz	w5, #4, ab9c <memset+0x9c>
    abd0:	12000ca5 	and	w5, w5, #0xf
    abd4:	710010bf 	cmp	w5, #0x4
    abd8:	54000281 	b.ne	ac28 <memset+0x128>  // b.any
    abdc:	3d800460 	str	q0, [x3, #16]
    abe0:	ad010060 	stp	q0, q0, [x3, #32]
    abe4:	927ae463 	and	x3, x3, #0xffffffffffffffc0
    abe8:	ad020060 	stp	q0, q0, [x3, #64]
    abec:	ad030060 	stp	q0, q0, [x3, #96]
    abf0:	cb030082 	sub	x2, x4, x3
    abf4:	d1040042 	sub	x2, x2, #0x100
    abf8:	91020063 	add	x3, x3, #0x80
    abfc:	d503201f 	nop
    ac00:	d50b7423 	dc	zva, x3
    ac04:	91010063 	add	x3, x3, #0x40
    ac08:	f1010042 	subs	x2, x2, #0x40
    ac0c:	54ffffa8 	b.hi	ac00 <memset+0x100>  // b.pmore
    ac10:	ad000060 	stp	q0, q0, [x3]
    ac14:	ad010060 	stp	q0, q0, [x3, #32]
    ac18:	ad3e0080 	stp	q0, q0, [x4, #-64]
    ac1c:	ad3f0080 	stp	q0, q0, [x4, #-32]
    ac20:	d65f03c0 	ret
    ac24:	d503201f 	nop
    ac28:	710014bf 	cmp	w5, #0x5
    ac2c:	54000241 	b.ne	ac74 <memset+0x174>  // b.any
    ac30:	3d800460 	str	q0, [x3, #16]
    ac34:	ad010060 	stp	q0, q0, [x3, #32]
    ac38:	ad020060 	stp	q0, q0, [x3, #64]
    ac3c:	ad030060 	stp	q0, q0, [x3, #96]
    ac40:	9279e063 	and	x3, x3, #0xffffffffffffff80
    ac44:	cb030082 	sub	x2, x4, x3
    ac48:	d1040042 	sub	x2, x2, #0x100
    ac4c:	91020063 	add	x3, x3, #0x80
    ac50:	d50b7423 	dc	zva, x3
    ac54:	91020063 	add	x3, x3, #0x80
    ac58:	f1020042 	subs	x2, x2, #0x80
    ac5c:	54ffffa8 	b.hi	ac50 <memset+0x150>  // b.pmore
    ac60:	ad3c0080 	stp	q0, q0, [x4, #-128]
    ac64:	ad3d0080 	stp	q0, q0, [x4, #-96]
    ac68:	ad3e0080 	stp	q0, q0, [x4, #-64]
    ac6c:	ad3f0080 	stp	q0, q0, [x4, #-32]
    ac70:	d65f03c0 	ret
    ac74:	52800086 	mov	w6, #0x4                   	// #4
    ac78:	1ac520c7 	lsl	w7, w6, w5
    ac7c:	910100e5 	add	x5, x7, #0x40
    ac80:	eb05005f 	cmp	x2, x5
    ac84:	54fff8c3 	b.cc	ab9c <memset+0x9c>  // b.lo, b.ul, b.last
    ac88:	d10004e6 	sub	x6, x7, #0x1
    ac8c:	8b070065 	add	x5, x3, x7
    ac90:	91004063 	add	x3, x3, #0x10
    ac94:	eb0300a2 	subs	x2, x5, x3
    ac98:	8a2600a5 	bic	x5, x5, x6
    ac9c:	540000a0 	b.eq	acb0 <memset+0x1b0>  // b.none
    aca0:	ac820060 	stp	q0, q0, [x3], #64
    aca4:	ad3f0060 	stp	q0, q0, [x3, #-32]
    aca8:	f1010042 	subs	x2, x2, #0x40
    acac:	54ffffa8 	b.hi	aca0 <memset+0x1a0>  // b.pmore
    acb0:	aa0503e3 	mov	x3, x5
    acb4:	cb050082 	sub	x2, x4, x5
    acb8:	eb070042 	subs	x2, x2, x7
    acbc:	540000a3 	b.cc	acd0 <memset+0x1d0>  // b.lo, b.ul, b.last
    acc0:	d50b7423 	dc	zva, x3
    acc4:	8b070063 	add	x3, x3, x7
    acc8:	eb070042 	subs	x2, x2, x7
    accc:	54ffffa2 	b.cs	acc0 <memset+0x1c0>  // b.hs, b.nlast
    acd0:	8b070042 	add	x2, x2, x7
    acd4:	d1008063 	sub	x3, x3, #0x20
    acd8:	17ffffb6 	b	abb0 <memset+0xb0>
    acdc:	00000000 	udf	#0

000000000000ace0 <__malloc_lock>:
    ace0:	d0001fa0 	adrp	x0, 400000 <__sf+0x10>
    ace4:	910a0000 	add	x0, x0, #0x280
    ace8:	17fffa52 	b	9630 <__retarget_lock_acquire_recursive>
    acec:	00000000 	udf	#0

000000000000acf0 <__malloc_unlock>:
    acf0:	d0001fa0 	adrp	x0, 400000 <__sf+0x10>
    acf4:	910a0000 	add	x0, x0, #0x280
    acf8:	17fffa5e 	b	9670 <__retarget_lock_release_recursive>
    acfc:	00000000 	udf	#0

000000000000ad00 <_wcsrtombs_r>:
    ad00:	aa0403e5 	mov	x5, x4
    ad04:	aa0303e4 	mov	x4, x3
    ad08:	92800003 	mov	x3, #0xffffffffffffffff    	// #-1
    ad0c:	140014a5 	b	ffa0 <_wcsnrtombs_r>

000000000000ad10 <wcsrtombs>:
    ad10:	f0000026 	adrp	x6, 11000 <JIS_action_table>
    ad14:	aa0003e4 	mov	x4, x0
    ad18:	aa0103e5 	mov	x5, x1
    ad1c:	aa0403e1 	mov	x1, x4
    ad20:	f9413cc0 	ldr	x0, [x6, #632]
    ad24:	aa0203e4 	mov	x4, x2
    ad28:	aa0503e2 	mov	x2, x5
    ad2c:	aa0303e5 	mov	x5, x3
    ad30:	92800003 	mov	x3, #0xffffffffffffffff    	// #-1
    ad34:	1400149b 	b	ffa0 <_wcsnrtombs_r>
	...

000000000000ad40 <quorem>:
    ad40:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
    ad44:	910003fd 	mov	x29, sp
    ad48:	a90153f3 	stp	x19, x20, [sp, #16]
    ad4c:	b9401434 	ldr	w20, [x1, #20]
    ad50:	a90363f7 	stp	x23, x24, [sp, #48]
    ad54:	aa0003f8 	mov	x24, x0
    ad58:	b9401400 	ldr	w0, [x0, #20]
    ad5c:	6b14001f 	cmp	w0, w20
    ad60:	54000b8b 	b.lt	aed0 <quorem+0x190>  // b.tstop
    ad64:	51000694 	sub	w20, w20, #0x1
    ad68:	91006033 	add	x19, x1, #0x18
    ad6c:	91006317 	add	x23, x24, #0x18
    ad70:	a9025bf5 	stp	x21, x22, [sp, #32]
    ad74:	93407e8a 	sxtw	x10, w20
    ad78:	937e7e80 	sbfiz	x0, x20, #2, #32
    ad7c:	8b000276 	add	x22, x19, x0
    ad80:	8b0002eb 	add	x11, x23, x0
    ad84:	b86a7a62 	ldr	w2, [x19, x10, lsl #2]
    ad88:	b86a7ae3 	ldr	w3, [x23, x10, lsl #2]
    ad8c:	11000442 	add	w2, w2, #0x1
    ad90:	1ac20875 	udiv	w21, w3, w2
    ad94:	6b02007f 	cmp	w3, w2
    ad98:	540004c3 	b.cc	ae30 <quorem+0xf0>  // b.lo, b.ul, b.last
    ad9c:	aa1303e7 	mov	x7, x19
    ada0:	aa1703e6 	mov	x6, x23
    ada4:	52800009 	mov	w9, #0x0                   	// #0
    ada8:	52800008 	mov	w8, #0x0                   	// #0
    adac:	d503201f 	nop
    adb0:	b84044e3 	ldr	w3, [x7], #4
    adb4:	b94000c4 	ldr	w4, [x6]
    adb8:	12003c65 	and	w5, w3, #0xffff
    adbc:	53107c63 	lsr	w3, w3, #16
    adc0:	12003c82 	and	w2, w4, #0xffff
    adc4:	1b1524a5 	madd	w5, w5, w21, w9
    adc8:	53107ca9 	lsr	w9, w5, #16
    adcc:	4b252042 	sub	w2, w2, w5, uxth
    add0:	0b080042 	add	w2, w2, w8
    add4:	1b152463 	madd	w3, w3, w21, w9
    add8:	13107c40 	asr	w0, w2, #16
    addc:	4b232000 	sub	w0, w0, w3, uxth
    ade0:	53107c69 	lsr	w9, w3, #16
    ade4:	0b444003 	add	w3, w0, w4, lsr #16
    ade8:	33103c62 	bfi	w2, w3, #16, #16
    adec:	b80044c2 	str	w2, [x6], #4
    adf0:	13107c68 	asr	w8, w3, #16
    adf4:	eb0702df 	cmp	x22, x7
    adf8:	54fffdc2 	b.cs	adb0 <quorem+0x70>  // b.hs, b.nlast
    adfc:	b86a7ae0 	ldr	w0, [x23, x10, lsl #2]
    ae00:	35000180 	cbnz	w0, ae30 <quorem+0xf0>
    ae04:	d1001160 	sub	x0, x11, #0x4
    ae08:	eb0002ff 	cmp	x23, x0
    ae0c:	540000a3 	b.cc	ae20 <quorem+0xe0>  // b.lo, b.ul, b.last
    ae10:	14000007 	b	ae2c <quorem+0xec>
    ae14:	51000694 	sub	w20, w20, #0x1
    ae18:	eb0002ff 	cmp	x23, x0
    ae1c:	54000082 	b.cs	ae2c <quorem+0xec>  // b.hs, b.nlast
    ae20:	b9400002 	ldr	w2, [x0]
    ae24:	d1001000 	sub	x0, x0, #0x4
    ae28:	34ffff62 	cbz	w2, ae14 <quorem+0xd4>
    ae2c:	b9001714 	str	w20, [x24, #20]
    ae30:	aa1803e0 	mov	x0, x24
    ae34:	94001203 	bl	f640 <__mcmp>
    ae38:	37f80400 	tbnz	w0, #31, aeb8 <quorem+0x178>
    ae3c:	aa1703e0 	mov	x0, x23
    ae40:	52800004 	mov	w4, #0x0                   	// #0
    ae44:	d503201f 	nop
    ae48:	b8404663 	ldr	w3, [x19], #4
    ae4c:	b9400002 	ldr	w2, [x0]
    ae50:	12003c41 	and	w1, w2, #0xffff
    ae54:	4b232021 	sub	w1, w1, w3, uxth
    ae58:	0b040021 	add	w1, w1, w4
    ae5c:	13107c24 	asr	w4, w1, #16
    ae60:	4b434083 	sub	w3, w4, w3, lsr #16
    ae64:	0b424062 	add	w2, w3, w2, lsr #16
    ae68:	33103c41 	bfi	w1, w2, #16, #16
    ae6c:	b8004401 	str	w1, [x0], #4
    ae70:	13107c44 	asr	w4, w2, #16
    ae74:	eb1302df 	cmp	x22, x19
    ae78:	54fffe82 	b.cs	ae48 <quorem+0x108>  // b.hs, b.nlast
    ae7c:	b874dae1 	ldr	w1, [x23, w20, sxtw #2]
    ae80:	8b34cae0 	add	x0, x23, w20, sxtw #2
    ae84:	35000181 	cbnz	w1, aeb4 <quorem+0x174>
    ae88:	d1001000 	sub	x0, x0, #0x4
    ae8c:	eb0002ff 	cmp	x23, x0
    ae90:	540000a3 	b.cc	aea4 <quorem+0x164>  // b.lo, b.ul, b.last
    ae94:	14000007 	b	aeb0 <quorem+0x170>
    ae98:	51000694 	sub	w20, w20, #0x1
    ae9c:	eb0002ff 	cmp	x23, x0
    aea0:	54000082 	b.cs	aeb0 <quorem+0x170>  // b.hs, b.nlast
    aea4:	b9400001 	ldr	w1, [x0]
    aea8:	d1001000 	sub	x0, x0, #0x4
    aeac:	34ffff61 	cbz	w1, ae98 <quorem+0x158>
    aeb0:	b9001714 	str	w20, [x24, #20]
    aeb4:	110006b5 	add	w21, w21, #0x1
    aeb8:	a94153f3 	ldp	x19, x20, [sp, #16]
    aebc:	2a1503e0 	mov	w0, w21
    aec0:	a9425bf5 	ldp	x21, x22, [sp, #32]
    aec4:	a94363f7 	ldp	x23, x24, [sp, #48]
    aec8:	a8c47bfd 	ldp	x29, x30, [sp], #64
    aecc:	d65f03c0 	ret
    aed0:	a94153f3 	ldp	x19, x20, [sp, #16]
    aed4:	52800000 	mov	w0, #0x0                   	// #0
    aed8:	a94363f7 	ldp	x23, x24, [sp, #48]
    aedc:	a8c47bfd 	ldp	x29, x30, [sp], #64
    aee0:	d65f03c0 	ret
	...

000000000000aef0 <_dtoa_r>:
    aef0:	a9b47bfd 	stp	x29, x30, [sp, #-192]!
    aef4:	910003fd 	mov	x29, sp
    aef8:	f9402806 	ldr	x6, [x0, #80]
    aefc:	a90153f3 	stp	x19, x20, [sp, #16]
    af00:	aa0003f3 	mov	x19, x0
    af04:	a9025bf5 	stp	x21, x22, [sp, #32]
    af08:	aa0403f4 	mov	x20, x4
    af0c:	2a0103f5 	mov	w21, w1
    af10:	a90363f7 	stp	x23, x24, [sp, #48]
    af14:	aa0503f8 	mov	x24, x5
    af18:	a9046bf9 	stp	x25, x26, [sp, #64]
    af1c:	9e66001a 	fmov	x26, d0
    af20:	a90573fb 	stp	x27, x28, [sp, #80]
    af24:	2a0203fb 	mov	w27, w2
    af28:	f9003fe3 	str	x3, [sp, #120]
    af2c:	6d0627e8 	stp	d8, d9, [sp, #96]
    af30:	1e604008 	fmov	d8, d0
    af34:	b4000106 	cbz	x6, af54 <_dtoa_r+0x64>
    af38:	b9405803 	ldr	w3, [x0, #88]
    af3c:	52800022 	mov	w2, #0x1                   	// #1
    af40:	aa0603e1 	mov	x1, x6
    af44:	1ac32042 	lsl	w2, w2, w3
    af48:	290108c3 	stp	w3, w2, [x6, #8]
    af4c:	94000f8d 	bl	ed80 <_Bfree>
    af50:	f9002a7f 	str	xzr, [x19, #80]
    af54:	9e660100 	fmov	x0, d8
    af58:	1e604109 	fmov	d9, d8
    af5c:	52800001 	mov	w1, #0x0                   	// #0
    af60:	d360fc00 	lsr	x0, x0, #32
    af64:	2a0003f6 	mov	w22, w0
    af68:	36f800a0 	tbz	w0, #31, af7c <_dtoa_r+0x8c>
    af6c:	12007816 	and	w22, w0, #0x7fffffff
    af70:	52800021 	mov	w1, #0x1                   	// #1
    af74:	b3607eda 	bfi	x26, x22, #32, #32
    af78:	9e670349 	fmov	d9, x26
    af7c:	120c2ac2 	and	w2, w22, #0x7ff00000
    af80:	b9000281 	str	w1, [x20]
    af84:	52affe00 	mov	w0, #0x7ff00000            	// #2146435072
    af88:	6b00005f 	cmp	w2, w0
    af8c:	54001e20 	b.eq	b350 <_dtoa_r+0x460>  // b.none
    af90:	1e602128 	fcmp	d9, #0.0
    af94:	54000261 	b.ne	afe0 <_dtoa_r+0xf0>  // b.any
    af98:	f9403fe1 	ldr	x1, [sp, #120]
    af9c:	52800020 	mov	w0, #0x1                   	// #1
    afa0:	b9000020 	str	w0, [x1]
    afa4:	b4000098 	cbz	x24, afb4 <_dtoa_r+0xc4>
    afa8:	d0000020 	adrp	x0, 10000 <__env_lock>
    afac:	91222400 	add	x0, x0, #0x889
    afb0:	f9000300 	str	x0, [x24]
    afb4:	d0000035 	adrp	x21, 10000 <__env_lock>
    afb8:	912222b5 	add	x21, x21, #0x888
    afbc:	a94153f3 	ldp	x19, x20, [sp, #16]
    afc0:	aa1503e0 	mov	x0, x21
    afc4:	a9425bf5 	ldp	x21, x22, [sp, #32]
    afc8:	a94363f7 	ldp	x23, x24, [sp, #48]
    afcc:	a9446bf9 	ldp	x25, x26, [sp, #64]
    afd0:	a94573fb 	ldp	x27, x28, [sp, #80]
    afd4:	6d4627e8 	ldp	d8, d9, [sp, #96]
    afd8:	a8cc7bfd 	ldp	x29, x30, [sp], #192
    afdc:	d65f03c0 	ret
    afe0:	1e604120 	fmov	d0, d9
    afe4:	9102e3e2 	add	x2, sp, #0xb8
    afe8:	9102f3e1 	add	x1, sp, #0xbc
    afec:	aa1303e0 	mov	x0, x19
    aff0:	94001298 	bl	fa50 <__d2b>
    aff4:	aa0003f4 	mov	x20, x0
    aff8:	53147ec0 	lsr	w0, w22, #20
    affc:	35001c40 	cbnz	w0, b384 <_dtoa_r+0x494>
    b000:	295707e3 	ldp	w3, w1, [sp, #184]
    b004:	9e660100 	fmov	x0, d8
    b008:	0b010061 	add	w1, w3, w1
    b00c:	1110c822 	add	w2, w1, #0x432
    b010:	7100805f 	cmp	w2, #0x20
    b014:	5400210d 	b.le	b434 <_dtoa_r+0x544>
    b018:	11104825 	add	w5, w1, #0x412
    b01c:	52800804 	mov	w4, #0x40                  	// #64
    b020:	4b020082 	sub	w2, w4, w2
    b024:	1ac52400 	lsr	w0, w0, w5
    b028:	1ac222d6 	lsl	w22, w22, w2
    b02c:	2a0002c0 	orr	w0, w22, w0
    b030:	1e630000 	ucvtf	d0, w0
    b034:	51000420 	sub	w0, w1, #0x1
    b038:	52800021 	mov	w1, #0x1                   	// #1
    b03c:	b900a7e1 	str	w1, [sp, #164]
    b040:	52bfc204 	mov	w4, #0xfe100000            	// #-32505856
    b044:	9e660002 	fmov	x2, d0
    b048:	d360fc41 	lsr	x1, x2, #32
    b04c:	0b040021 	add	w1, w1, w4
    b050:	b3607c22 	bfi	x2, x1, #32, #32
    b054:	9e670042 	fmov	d2, x2
    b058:	1e6f1001 	fmov	d1, #1.500000000000000000e+00
    b05c:	b0000021 	adrp	x1, 10000 <__env_lock>
    b060:	1e620003 	scvtf	d3, w0
    b064:	1e613841 	fsub	d1, d2, d1
    b068:	fd476c24 	ldr	d4, [x1, #3800]
    b06c:	b0000021 	adrp	x1, 10000 <__env_lock>
    b070:	fd477020 	ldr	d0, [x1, #3808]
    b074:	b0000021 	adrp	x1, 10000 <__env_lock>
    b078:	1f440020 	fmadd	d0, d1, d4, d0
    b07c:	fd477422 	ldr	d2, [x1, #3816]
    b080:	1f420060 	fmadd	d0, d3, d2, d0
    b084:	1e602018 	fcmpe	d0, #0.0
    b088:	1e780005 	fcvtzs	w5, d0
    b08c:	54001ca4 	b.mi	b420 <_dtoa_r+0x530>  // b.first
    b090:	4b000060 	sub	w0, w3, w0
    b094:	51000406 	sub	w6, w0, #0x1
    b098:	710058bf 	cmp	w5, #0x16
    b09c:	54001928 	b.hi	b3c0 <_dtoa_r+0x4d0>  // b.pmore
    b0a0:	d0000022 	adrp	x2, 11000 <JIS_action_table>
    b0a4:	9105c044 	add	x4, x2, #0x170
    b0a8:	fc65d880 	ldr	d0, [x4, w5, sxtw #3]
    b0ac:	1e692010 	fcmpe	d0, d9
    b0b0:	54001c8c 	b.gt	b440 <_dtoa_r+0x550>
    b0b4:	b9009bff 	str	wzr, [sp, #152]
    b0b8:	52800007 	mov	w7, #0x0                   	// #0
    b0bc:	7100001f 	cmp	w0, #0x0
    b0c0:	5400008c 	b.gt	b0d0 <_dtoa_r+0x1e0>
    b0c4:	52800027 	mov	w7, #0x1                   	// #1
    b0c8:	4b0000e7 	sub	w7, w7, w0
    b0cc:	52800006 	mov	w6, #0x0                   	// #0
    b0d0:	b90083e5 	str	w5, [sp, #128]
    b0d4:	0b0500c6 	add	w6, w6, w5
    b0d8:	5280001c 	mov	w28, #0x0                   	// #0
    b0dc:	710026bf 	cmp	w21, #0x9
    b0e0:	54001868 	b.hi	b3ec <_dtoa_r+0x4fc>  // b.pmore
    b0e4:	710016bf 	cmp	w21, #0x5
    b0e8:	54001b2d 	b.le	b44c <_dtoa_r+0x55c>
    b0ec:	510012b5 	sub	w21, w21, #0x4
    b0f0:	52800019 	mov	w25, #0x0                   	// #0
    b0f4:	71000ebf 	cmp	w21, #0x3
    b0f8:	540060e0 	b.eq	bd14 <_dtoa_r+0xe24>  // b.none
    b0fc:	5400570d 	b.le	bbdc <_dtoa_r+0xcec>
    b100:	710012bf 	cmp	w21, #0x4
    b104:	54003e60 	b.eq	b8d0 <_dtoa_r+0x9e0>  // b.none
    b108:	52800020 	mov	w0, #0x1                   	// #1
    b10c:	528000b5 	mov	w21, #0x5                   	// #5
    b110:	b9008be0 	str	w0, [sp, #136]
    b114:	b94083e0 	ldr	w0, [sp, #128]
    b118:	0b000360 	add	w0, w27, w0
    b11c:	b900abe0 	str	w0, [sp, #168]
    b120:	11000416 	add	w22, w0, #0x1
    b124:	710002df 	cmp	w22, #0x0
    b128:	1a9fc6c0 	csinc	w0, w22, wzr, gt
    b12c:	93407c04 	sxtw	x4, w0
    b130:	71007c1f 	cmp	w0, #0x1f
    b134:	5400168d 	b.le	b404 <_dtoa_r+0x514>
    b138:	52800023 	mov	w3, #0x1                   	// #1
    b13c:	52800082 	mov	w2, #0x4                   	// #4
    b140:	531f7842 	lsl	w2, w2, #1
    b144:	2a0303e1 	mov	w1, w3
    b148:	11000463 	add	w3, w3, #0x1
    b14c:	93407c40 	sxtw	x0, w2
    b150:	91007000 	add	x0, x0, #0x1c
    b154:	eb04001f 	cmp	x0, x4
    b158:	54ffff49 	b.ls	b140 <_dtoa_r+0x250>  // b.plast
    b15c:	b9005a61 	str	w1, [x19, #88]
    b160:	aa1303e0 	mov	x0, x19
    b164:	291197e7 	stp	w7, w5, [sp, #140]
    b168:	b900a3e6 	str	w6, [sp, #160]
    b16c:	94000ee1 	bl	ecf0 <_Balloc>
    b170:	295197e7 	ldp	w7, w5, [sp, #140]
    b174:	aa0003f7 	mov	x23, x0
    b178:	b940a3e6 	ldr	w6, [sp, #160]
    b17c:	b4007680 	cbz	x0, c04c <_dtoa_r+0x115c>
    b180:	71003adf 	cmp	w22, #0xe
    b184:	f9002a77 	str	x23, [x19, #80]
    b188:	1a9f87e0 	cset	w0, ls	// ls = plast
    b18c:	2a1603e3 	mov	w3, w22
    b190:	6a190000 	ands	w0, w0, w25
    b194:	54000b20 	b.eq	b2f8 <_dtoa_r+0x408>  // b.none
    b198:	b94083e1 	ldr	w1, [sp, #128]
    b19c:	7100003f 	cmp	w1, #0x0
    b1a0:	5400194d 	b.le	b4c8 <_dtoa_r+0x5d8>
    b1a4:	2a0103e0 	mov	w0, w1
    b1a8:	d0000022 	adrp	x2, 11000 <JIS_action_table>
    b1ac:	aa0003e1 	mov	x1, x0
    b1b0:	9105c044 	add	x4, x2, #0x170
    b1b4:	92400c21 	and	x1, x1, #0xf
    b1b8:	2a0003e2 	mov	w2, w0
    b1bc:	13047c00 	asr	w0, w0, #4
    b1c0:	fc617880 	ldr	d0, [x4, x1, lsl #3]
    b1c4:	aa0203e1 	mov	x1, x2
    b1c8:	36404701 	tbz	w1, #8, baa8 <_dtoa_r+0xbb8>
    b1cc:	d0000021 	adrp	x1, 11000 <JIS_action_table>
    b1d0:	12000c00 	and	w0, w0, #0xf
    b1d4:	52800062 	mov	w2, #0x3                   	// #3
    b1d8:	fd40b021 	ldr	d1, [x1, #352]
    b1dc:	1e611921 	fdiv	d1, d9, d1
    b1e0:	34000160 	cbz	w0, b20c <_dtoa_r+0x31c>
    b1e4:	d0000021 	adrp	x1, 11000 <JIS_action_table>
    b1e8:	91050021 	add	x1, x1, #0x140
    b1ec:	d503201f 	nop
    b1f0:	36000080 	tbz	w0, #0, b200 <_dtoa_r+0x310>
    b1f4:	fd400022 	ldr	d2, [x1]
    b1f8:	11000442 	add	w2, w2, #0x1
    b1fc:	1e620800 	fmul	d0, d0, d2
    b200:	13017c00 	asr	w0, w0, #1
    b204:	91002021 	add	x1, x1, #0x8
    b208:	35ffff40 	cbnz	w0, b1f0 <_dtoa_r+0x300>
    b20c:	1e601821 	fdiv	d1, d1, d0
    b210:	b9409be0 	ldr	w0, [sp, #152]
    b214:	34000080 	cbz	w0, b224 <_dtoa_r+0x334>
    b218:	1e6e1000 	fmov	d0, #1.000000000000000000e+00
    b21c:	1e602030 	fcmpe	d1, d0
    b220:	540057e4 	b.mi	bd1c <_dtoa_r+0xe2c>  // b.first
    b224:	1e620042 	scvtf	d2, w2
    b228:	1e639000 	fmov	d0, #7.000000000000000000e+00
    b22c:	52bf9802 	mov	w2, #0xfcc00000            	// #-54525952
    b230:	1f410040 	fmadd	d0, d2, d1, d0
    b234:	9e660000 	fmov	x0, d0
    b238:	d360fc01 	lsr	x1, x0, #32
    b23c:	0b020021 	add	w1, w1, w2
    b240:	b3607c20 	bfi	x0, x1, #32, #32
    b244:	340012f6 	cbz	w22, b4a0 <_dtoa_r+0x5b0>
    b248:	b94083fa 	ldr	w26, [sp, #128]
    b24c:	2a1603e8 	mov	w8, w22
    b250:	1e780021 	fcvtzs	w1, d1
    b254:	9e670002 	fmov	d2, x0
    b258:	d0000022 	adrp	x2, 11000 <JIS_action_table>
    b25c:	51000509 	sub	w9, w8, #0x1
    b260:	9105c044 	add	x4, x2, #0x170
    b264:	910006e2 	add	x2, x23, #0x1
    b268:	1e620020 	scvtf	d0, w1
    b26c:	1100c020 	add	w0, w1, #0x30
    b270:	b9408be1 	ldr	w1, [sp, #136]
    b274:	12001c00 	and	w0, w0, #0xff
    b278:	fc69d883 	ldr	d3, [x4, w9, sxtw #3]
    b27c:	1e603821 	fsub	d1, d1, d0
    b280:	340015a1 	cbz	w1, b534 <_dtoa_r+0x644>
    b284:	1e6c1000 	fmov	d0, #5.000000000000000000e-01
    b288:	390002e0 	strb	w0, [x23]
    b28c:	1e631800 	fdiv	d0, d0, d3
    b290:	1e623800 	fsub	d0, d0, d2
    b294:	1e612010 	fcmpe	d0, d1
    b298:	540045ac 	b.gt	bb4c <_dtoa_r+0xc5c>
    b29c:	aa0203e0 	mov	x0, x2
    b2a0:	1e6e1004 	fmov	d4, #1.000000000000000000e+00
    b2a4:	52800022 	mov	w2, #0x1                   	// #1
    b2a8:	1e649003 	fmov	d3, #1.000000000000000000e+01
    b2ac:	4b000042 	sub	w2, w2, w0
    b2b0:	1400000a 	b	b2d8 <_dtoa_r+0x3e8>
    b2b4:	1e630821 	fmul	d1, d1, d3
    b2b8:	1e630800 	fmul	d0, d0, d3
    b2bc:	1e780021 	fcvtzs	w1, d1
    b2c0:	1e620022 	scvtf	d2, w1
    b2c4:	1100c021 	add	w1, w1, #0x30
    b2c8:	38001401 	strb	w1, [x0], #1
    b2cc:	1e623821 	fsub	d1, d1, d2
    b2d0:	1e602030 	fcmpe	d1, d0
    b2d4:	54006064 	b.mi	bee0 <_dtoa_r+0xff0>  // b.first
    b2d8:	1e613882 	fsub	d2, d4, d1
    b2dc:	1e602050 	fcmpe	d2, d0
    b2e0:	54003ee4 	b.mi	babc <_dtoa_r+0xbcc>  // b.first
    b2e4:	0b000041 	add	w1, w2, w0
    b2e8:	6b08003f 	cmp	w1, w8
    b2ec:	54fffe4b 	b.lt	b2b4 <_dtoa_r+0x3c4>  // b.tstop
    b2f0:	9e66013a 	fmov	x26, d9
    b2f4:	d503201f 	nop
    b2f8:	b940bfe0 	ldr	w0, [sp, #188]
    b2fc:	d0000022 	adrp	x2, 11000 <JIS_action_table>
    b300:	b94083e1 	ldr	w1, [sp, #128]
    b304:	9105c044 	add	x4, x2, #0x170
    b308:	7100001f 	cmp	w0, #0x0
    b30c:	7a4ea820 	ccmp	w1, #0xe, #0x0, ge	// ge = tcont
    b310:	54002c2d 	b.le	b894 <_dtoa_r+0x9a4>
    b314:	b9408be1 	ldr	w1, [sp, #136]
    b318:	34001481 	cbz	w1, b5a8 <_dtoa_r+0x6b8>
    b31c:	710006bf 	cmp	w21, #0x1
    b320:	5400522d 	b.le	bd64 <_dtoa_r+0xe74>
    b324:	510006c3 	sub	w3, w22, #0x1
    b328:	6b03039f 	cmp	w28, w3
    b32c:	5400422b 	b.lt	bb70 <_dtoa_r+0xc80>  // b.tstop
    b330:	4b1600e0 	sub	w0, w7, w22
    b334:	b9008fe0 	str	w0, [sp, #140]
    b338:	4b030383 	sub	w3, w28, w3
    b33c:	37f84296 	tbnz	w22, #31, bb8c <_dtoa_r+0xc9c>
    b340:	0b1600c6 	add	w6, w6, w22
    b344:	b9008fe7 	str	w7, [sp, #140]
    b348:	0b0702c7 	add	w7, w22, w7
    b34c:	14000210 	b	bb8c <_dtoa_r+0xc9c>
    b350:	f9403fe1 	ldr	x1, [sp, #120]
    b354:	5284e1e0 	mov	w0, #0x270f                	// #9999
    b358:	b9000020 	str	w0, [x1]
    b35c:	9e660120 	fmov	x0, d9
    b360:	f240cc1f 	tst	x0, #0xfffffffffffff
    b364:	54000201 	b.ne	b3a4 <_dtoa_r+0x4b4>  // b.any
    b368:	b0000035 	adrp	x21, 10000 <__env_lock>
    b36c:	b40050d8 	cbz	x24, bd84 <_dtoa_r+0xe94>
    b370:	b0000020 	adrp	x0, 10000 <__env_lock>
    b374:	913922b5 	add	x21, x21, #0xe48
    b378:	91394000 	add	x0, x0, #0xe50
    b37c:	f9000300 	str	x0, [x24]
    b380:	17ffff0f 	b	afbc <_dtoa_r+0xcc>
    b384:	9e660122 	fmov	x2, d9
    b388:	b940bbe3 	ldr	w3, [sp, #184]
    b38c:	510ffc00 	sub	w0, w0, #0x3ff
    b390:	b900a7ff 	str	wzr, [sp, #164]
    b394:	d360cc41 	ubfx	x1, x2, #32, #20
    b398:	320c2421 	orr	w1, w1, #0x3ff00000
    b39c:	b3607c22 	bfi	x2, x1, #32, #32
    b3a0:	17ffff2d 	b	b054 <_dtoa_r+0x164>
    b3a4:	b0000035 	adrp	x21, 10000 <__env_lock>
    b3a8:	b4004f38 	cbz	x24, bd8c <_dtoa_r+0xe9c>
    b3ac:	b0000020 	adrp	x0, 10000 <__env_lock>
    b3b0:	913962b5 	add	x21, x21, #0xe58
    b3b4:	91396c00 	add	x0, x0, #0xe5b
    b3b8:	f9000300 	str	x0, [x24]
    b3bc:	17ffff00 	b	afbc <_dtoa_r+0xcc>
    b3c0:	52800021 	mov	w1, #0x1                   	// #1
    b3c4:	b9009be1 	str	w1, [sp, #152]
    b3c8:	52800007 	mov	w7, #0x0                   	// #0
    b3cc:	37f80226 	tbnz	w6, #31, b410 <_dtoa_r+0x520>
    b3d0:	36ffe805 	tbz	w5, #31, b0d0 <_dtoa_r+0x1e0>
    b3d4:	b90083e5 	str	w5, [sp, #128]
    b3d8:	4b0500e7 	sub	w7, w7, w5
    b3dc:	4b0503fc 	neg	w28, w5
    b3e0:	52800005 	mov	w5, #0x0                   	// #0
    b3e4:	710026bf 	cmp	w21, #0x9
    b3e8:	54ffe7e9 	b.ls	b0e4 <_dtoa_r+0x1f4>  // b.plast
    b3ec:	52800039 	mov	w25, #0x1                   	// #1
    b3f0:	52800015 	mov	w21, #0x0                   	// #0
    b3f4:	12800016 	mov	w22, #0xffffffff            	// #-1
    b3f8:	5280001b 	mov	w27, #0x0                   	// #0
    b3fc:	b9008bf9 	str	w25, [sp, #136]
    b400:	b900abf6 	str	w22, [sp, #168]
    b404:	52800001 	mov	w1, #0x0                   	// #0
    b408:	b9005a7f 	str	wzr, [x19, #88]
    b40c:	17ffff55 	b	b160 <_dtoa_r+0x270>
    b410:	52800027 	mov	w7, #0x1                   	// #1
    b414:	52800006 	mov	w6, #0x0                   	// #0
    b418:	4b0000e7 	sub	w7, w7, w0
    b41c:	17ffffed 	b	b3d0 <_dtoa_r+0x4e0>
    b420:	1e6200a1 	scvtf	d1, w5
    b424:	1e602020 	fcmp	d1, d0
    b428:	1a9f07e1 	cset	w1, ne	// ne = any
    b42c:	4b0100a5 	sub	w5, w5, w1
    b430:	17ffff18 	b	b090 <_dtoa_r+0x1a0>
    b434:	4b0203e2 	neg	w2, w2
    b438:	1ac22000 	lsl	w0, w0, w2
    b43c:	17fffefd 	b	b030 <_dtoa_r+0x140>
    b440:	510004a5 	sub	w5, w5, #0x1
    b444:	b9009bff 	str	wzr, [sp, #152]
    b448:	17ffffe0 	b	b3c8 <_dtoa_r+0x4d8>
    b44c:	52800039 	mov	w25, #0x1                   	// #1
    b450:	71000ebf 	cmp	w21, #0x3
    b454:	54004600 	b.eq	bd14 <_dtoa_r+0xe24>  // b.none
    b458:	54ffe54c 	b.gt	b100 <_dtoa_r+0x210>
    b45c:	b9008bff 	str	wzr, [sp, #136]
    b460:	71000abf 	cmp	w21, #0x2
    b464:	54005d01 	b.ne	c004 <_dtoa_r+0x1114>  // b.any
    b468:	7100037f 	cmp	w27, #0x0
    b46c:	5400238d 	b.le	b8dc <_dtoa_r+0x9ec>
    b470:	2a1b03f6 	mov	w22, w27
    b474:	2a1b03e0 	mov	w0, w27
    b478:	b900abfb 	str	w27, [sp, #168]
    b47c:	17ffff2c 	b	b12c <_dtoa_r+0x23c>
    b480:	1e620042 	scvtf	d2, w2
    b484:	1e639000 	fmov	d0, #7.000000000000000000e+00
    b488:	52bf9802 	mov	w2, #0xfcc00000            	// #-54525952
    b48c:	1f410040 	fmadd	d0, d2, d1, d0
    b490:	9e660000 	fmov	x0, d0
    b494:	d360fc01 	lsr	x1, x0, #32
    b498:	0b020021 	add	w1, w1, w2
    b49c:	b3607c20 	bfi	x0, x1, #32, #32
    b4a0:	1e629002 	fmov	d2, #5.000000000000000000e+00
    b4a4:	9e670000 	fmov	d0, x0
    b4a8:	1e623821 	fsub	d1, d1, d2
    b4ac:	1e602030 	fcmpe	d1, d0
    b4b0:	5400208c 	b.gt	b8c0 <_dtoa_r+0x9d0>
    b4b4:	1e614000 	fneg	d0, d0
    b4b8:	1e602030 	fcmpe	d1, d0
    b4bc:	54003544 	b.mi	bb64 <_dtoa_r+0xc74>  // b.first
    b4c0:	9e66013a 	fmov	x26, d9
    b4c4:	17ffff8d 	b	b2f8 <_dtoa_r+0x408>
    b4c8:	54003480 	b.eq	bb58 <_dtoa_r+0xc68>  // b.none
    b4cc:	b94083e1 	ldr	w1, [sp, #128]
    b4d0:	d0000022 	adrp	x2, 11000 <JIS_action_table>
    b4d4:	9105c044 	add	x4, x2, #0x170
    b4d8:	4b0103e1 	neg	w1, w1
    b4dc:	92400c28 	and	x8, x1, #0xf
    b4e0:	13047c21 	asr	w1, w1, #4
    b4e4:	fc687882 	ldr	d2, [x4, x8, lsl #3]
    b4e8:	1e620922 	fmul	d2, d9, d2
    b4ec:	34005661 	cbz	w1, bfb8 <_dtoa_r+0x10c8>
    b4f0:	1e604041 	fmov	d1, d2
    b4f4:	d0000024 	adrp	x4, 11000 <JIS_action_table>
    b4f8:	91050084 	add	x4, x4, #0x140
    b4fc:	52800008 	mov	w8, #0x0                   	// #0
    b500:	52800042 	mov	w2, #0x2                   	// #2
    b504:	d503201f 	nop
    b508:	360000a1 	tbz	w1, #0, b51c <_dtoa_r+0x62c>
    b50c:	fd400080 	ldr	d0, [x4]
    b510:	11000442 	add	w2, w2, #0x1
    b514:	2a0003e8 	mov	w8, w0
    b518:	1e600821 	fmul	d1, d1, d0
    b51c:	13017c21 	asr	w1, w1, #1
    b520:	91002084 	add	x4, x4, #0x8
    b524:	35ffff21 	cbnz	w1, b508 <_dtoa_r+0x618>
    b528:	7100011f 	cmp	w8, #0x0
    b52c:	1e621c21 	fcsel	d1, d1, d2, ne	// ne = any
    b530:	17ffff38 	b	b210 <_dtoa_r+0x320>
    b534:	390002e0 	strb	w0, [x23]
    b538:	1e630842 	fmul	d2, d2, d3
    b53c:	8b2842e0 	add	x0, x23, w8, uxtw
    b540:	1e649003 	fmov	d3, #1.000000000000000000e+01
    b544:	7100051f 	cmp	w8, #0x1
    b548:	54005160 	b.eq	bf74 <_dtoa_r+0x1084>  // b.none
    b54c:	d503201f 	nop
    b550:	1e630821 	fmul	d1, d1, d3
    b554:	1e780021 	fcvtzs	w1, d1
    b558:	1e620020 	scvtf	d0, w1
    b55c:	1100c021 	add	w1, w1, #0x30
    b560:	38001441 	strb	w1, [x2], #1
    b564:	1e603821 	fsub	d1, d1, d0
    b568:	eb00005f 	cmp	x2, x0
    b56c:	54ffff21 	b.ne	b550 <_dtoa_r+0x660>  // b.any
    b570:	1e6c1000 	fmov	d0, #5.000000000000000000e-01
    b574:	1e602843 	fadd	d3, d2, d0
    b578:	1e612070 	fcmpe	d3, d1
    b57c:	54002a04 	b.mi	babc <_dtoa_r+0xbcc>  // b.first
    b580:	1e623800 	fsub	d0, d0, d2
    b584:	1e612010 	fcmpe	d0, d1
    b588:	54002dac 	b.gt	bb3c <_dtoa_r+0xc4c>
    b58c:	b940bfe0 	ldr	w0, [sp, #188]
    b590:	9e66013a 	fmov	x26, d9
    b594:	7100001f 	cmp	w0, #0x0
    b598:	b94083e0 	ldr	w0, [sp, #128]
    b59c:	7a4ea800 	ccmp	w0, #0xe, #0x0, ge	// ge = tcont
    b5a0:	540017ad 	b.le	b894 <_dtoa_r+0x9a4>
    b5a4:	d503201f 	nop
    b5a8:	2a1c03e3 	mov	w3, w28
    b5ac:	d2800019 	mov	x25, #0x0                   	// #0
    b5b0:	29111fff 	stp	wzr, w7, [sp, #136]
    b5b4:	b9408fe1 	ldr	w1, [sp, #140]
    b5b8:	7100003f 	cmp	w1, #0x0
    b5bc:	7a40c8c4 	ccmp	w6, #0x0, #0x4, gt
    b5c0:	540000ed 	b.le	b5dc <_dtoa_r+0x6ec>
    b5c4:	6b06003f 	cmp	w1, w6
    b5c8:	1a86d020 	csel	w0, w1, w6, le
    b5cc:	4b0000e7 	sub	w7, w7, w0
    b5d0:	4b0000c6 	sub	w6, w6, w0
    b5d4:	4b000021 	sub	w1, w1, w0
    b5d8:	b9008fe1 	str	w1, [sp, #140]
    b5dc:	340001bc 	cbz	w28, b610 <_dtoa_r+0x720>
    b5e0:	b9408be0 	ldr	w0, [sp, #136]
    b5e4:	34003d80 	cbz	w0, bd94 <_dtoa_r+0xea4>
    b5e8:	35003003 	cbnz	w3, bbe8 <_dtoa_r+0xcf8>
    b5ec:	aa1403e1 	mov	x1, x20
    b5f0:	2a1c03e2 	mov	w2, w28
    b5f4:	aa1303e0 	mov	x0, x19
    b5f8:	b90093e7 	str	w7, [sp, #144]
    b5fc:	29141be5 	stp	w5, w6, [sp, #160]
    b600:	94000f6c 	bl	f3b0 <__pow5mult>
    b604:	b94093e7 	ldr	w7, [sp, #144]
    b608:	aa0003f4 	mov	x20, x0
    b60c:	29541be5 	ldp	w5, w6, [sp, #160]
    b610:	aa1303e0 	mov	x0, x19
    b614:	52800021 	mov	w1, #0x1                   	// #1
    b618:	b90093e7 	str	w7, [sp, #144]
    b61c:	29141be5 	stp	w5, w6, [sp, #160]
    b620:	94000eb8 	bl	f100 <__i2b>
    b624:	29541be5 	ldp	w5, w6, [sp, #160]
    b628:	aa0003fc 	mov	x28, x0
    b62c:	b94093e7 	ldr	w7, [sp, #144]
    b630:	350020c5 	cbnz	w5, ba48 <_dtoa_r+0xb58>
    b634:	710006bf 	cmp	w21, #0x1
    b638:	5400018d 	b.le	b668 <_dtoa_r+0x778>
    b63c:	52800020 	mov	w0, #0x1                   	// #1
    b640:	0b060000 	add	w0, w0, w6
    b644:	72001000 	ands	w0, w0, #0x1f
    b648:	54000240 	b.eq	b690 <_dtoa_r+0x7a0>  // b.none
    b64c:	52800401 	mov	w1, #0x20                  	// #32
    b650:	4b000021 	sub	w1, w1, w0
    b654:	7100103f 	cmp	w1, #0x4
    b658:	5400246d 	b.le	bae4 <_dtoa_r+0xbf4>
    b65c:	52800381 	mov	w1, #0x1c                  	// #28
    b660:	4b000020 	sub	w0, w1, w0
    b664:	1400000c 	b	b694 <_dtoa_r+0x7a4>
    b668:	f240cf5f 	tst	x26, #0xfffffffffffff
    b66c:	54fffe81 	b.ne	b63c <_dtoa_r+0x74c>  // b.any
    b670:	d360ff40 	lsr	x0, x26, #32
    b674:	f26c281f 	tst	x0, #0x7ff00000
    b678:	54fffe20 	b.eq	b63c <_dtoa_r+0x74c>  // b.none
    b67c:	52800025 	mov	w5, #0x1                   	// #1
    b680:	110004e7 	add	w7, w7, #0x1
    b684:	110004c6 	add	w6, w6, #0x1
    b688:	2a0503e0 	mov	w0, w5
    b68c:	17ffffed 	b	b640 <_dtoa_r+0x750>
    b690:	52800380 	mov	w0, #0x1c                  	// #28
    b694:	b9408fe1 	ldr	w1, [sp, #140]
    b698:	0b0000e7 	add	w7, w7, w0
    b69c:	0b0000c6 	add	w6, w6, w0
    b6a0:	0b000021 	add	w1, w1, w0
    b6a4:	b9008fe1 	str	w1, [sp, #140]
    b6a8:	710000ff 	cmp	w7, #0x0
    b6ac:	5400014d 	b.le	b6d4 <_dtoa_r+0x7e4>
    b6b0:	aa1403e1 	mov	x1, x20
    b6b4:	2a0703e2 	mov	w2, w7
    b6b8:	aa1303e0 	mov	x0, x19
    b6bc:	b90093e5 	str	w5, [sp, #144]
    b6c0:	b900a3e6 	str	w6, [sp, #160]
    b6c4:	94000f83 	bl	f4d0 <__lshift>
    b6c8:	b94093e5 	ldr	w5, [sp, #144]
    b6cc:	aa0003f4 	mov	x20, x0
    b6d0:	b940a3e6 	ldr	w6, [sp, #160]
    b6d4:	710000df 	cmp	w6, #0x0
    b6d8:	5400010d 	b.le	b6f8 <_dtoa_r+0x808>
    b6dc:	aa1c03e1 	mov	x1, x28
    b6e0:	2a0603e2 	mov	w2, w6
    b6e4:	aa1303e0 	mov	x0, x19
    b6e8:	b90093e5 	str	w5, [sp, #144]
    b6ec:	94000f79 	bl	f4d0 <__lshift>
    b6f0:	aa0003fc 	mov	x28, x0
    b6f4:	b94093e5 	ldr	w5, [sp, #144]
    b6f8:	b9409be0 	ldr	w0, [sp, #152]
    b6fc:	71000abf 	cmp	w21, #0x2
    b700:	1a9fd7e4 	cset	w4, gt
    b704:	35000f20 	cbnz	w0, b8e8 <_dtoa_r+0x9f8>
    b708:	710002df 	cmp	w22, #0x0
    b70c:	7a40d884 	ccmp	w4, #0x0, #0x4, le
    b710:	540002a0 	b.eq	b764 <_dtoa_r+0x874>  // b.none
    b714:	34001f16 	cbz	w22, baf4 <_dtoa_r+0xc04>
    b718:	2a3b03fa 	mvn	w26, w27
    b71c:	aa1703f5 	mov	x21, x23
    b720:	aa1c03e1 	mov	x1, x28
    b724:	aa1303e0 	mov	x0, x19
    b728:	94000d96 	bl	ed80 <_Bfree>
    b72c:	b4000099 	cbz	x25, b73c <_dtoa_r+0x84c>
    b730:	aa1903e1 	mov	x1, x25
    b734:	aa1303e0 	mov	x0, x19
    b738:	94000d92 	bl	ed80 <_Bfree>
    b73c:	aa1403e1 	mov	x1, x20
    b740:	aa1303e0 	mov	x0, x19
    b744:	94000d8f 	bl	ed80 <_Bfree>
    b748:	390002ff 	strb	wzr, [x23]
    b74c:	f9403fe1 	ldr	x1, [sp, #120]
    b750:	11000740 	add	w0, w26, #0x1
    b754:	b9000020 	str	w0, [x1]
    b758:	b4ffc338 	cbz	x24, afbc <_dtoa_r+0xcc>
    b75c:	f9000317 	str	x23, [x24]
    b760:	17fffe17 	b	afbc <_dtoa_r+0xcc>
    b764:	b9408be0 	ldr	w0, [sp, #136]
    b768:	34000f80 	cbz	w0, b958 <_dtoa_r+0xa68>
    b76c:	b9408fe2 	ldr	w2, [sp, #140]
    b770:	7100005f 	cmp	w2, #0x0
    b774:	540000ed 	b.le	b790 <_dtoa_r+0x8a0>
    b778:	aa1903e1 	mov	x1, x25
    b77c:	aa1303e0 	mov	x0, x19
    b780:	b9008be5 	str	w5, [sp, #136]
    b784:	94000f53 	bl	f4d0 <__lshift>
    b788:	b9408be5 	ldr	w5, [sp, #136]
    b78c:	aa0003f9 	mov	x25, x0
    b790:	aa1903fb 	mov	x27, x25
    b794:	35003845 	cbnz	w5, be9c <_dtoa_r+0xfac>
    b798:	8b36c2f6 	add	x22, x23, w22, sxtw
    b79c:	12000340 	and	w0, w26, #0x1
    b7a0:	f9004bf7 	str	x23, [sp, #144]
    b7a4:	b900abe0 	str	w0, [sp, #168]
    b7a8:	aa1c03e1 	mov	x1, x28
    b7ac:	aa1403e0 	mov	x0, x20
    b7b0:	97fffd64 	bl	ad40 <quorem>
    b7b4:	b9008fe0 	str	w0, [sp, #140]
    b7b8:	aa1903e1 	mov	x1, x25
    b7bc:	aa1403e0 	mov	x0, x20
    b7c0:	94000fa0 	bl	f640 <__mcmp>
    b7c4:	b9008be0 	str	w0, [sp, #136]
    b7c8:	aa1c03e1 	mov	x1, x28
    b7cc:	aa1b03e2 	mov	x2, x27
    b7d0:	aa1303e0 	mov	x0, x19
    b7d4:	94000faf 	bl	f690 <__mdiff>
    b7d8:	b9408fe1 	ldr	w1, [sp, #140]
    b7dc:	1100c023 	add	w3, w1, #0x30
    b7e0:	aa0003e1 	mov	x1, x0
    b7e4:	b9401000 	ldr	w0, [x0, #16]
    b7e8:	350022c0 	cbnz	w0, bc40 <_dtoa_r+0xd50>
    b7ec:	aa1403e0 	mov	x0, x20
    b7f0:	f9004fe1 	str	x1, [sp, #152]
    b7f4:	b900a7e3 	str	w3, [sp, #164]
    b7f8:	94000f92 	bl	f640 <__mcmp>
    b7fc:	f9404fe1 	ldr	x1, [sp, #152]
    b800:	2a0003e2 	mov	w2, w0
    b804:	aa1303e0 	mov	x0, x19
    b808:	b900a3e2 	str	w2, [sp, #160]
    b80c:	94000d5d 	bl	ed80 <_Bfree>
    b810:	29540fe2 	ldp	w2, w3, [sp, #160]
    b814:	2a0202a0 	orr	w0, w21, w2
    b818:	350025c0 	cbnz	w0, bcd0 <_dtoa_r+0xde0>
    b81c:	b940abe0 	ldr	w0, [sp, #168]
    b820:	34003920 	cbz	w0, bf44 <_dtoa_r+0x1054>
    b824:	b9408be0 	ldr	w0, [sp, #136]
    b828:	37f82400 	tbnz	w0, #31, bca8 <_dtoa_r+0xdb8>
    b82c:	f9404be0 	ldr	x0, [sp, #144]
    b830:	38001403 	strb	w3, [x0], #1
    b834:	f9004be0 	str	x0, [sp, #144]
    b838:	eb0002df 	cmp	x22, x0
    b83c:	540036e0 	b.eq	bf18 <_dtoa_r+0x1028>  // b.none
    b840:	aa1403e1 	mov	x1, x20
    b844:	52800003 	mov	w3, #0x0                   	// #0
    b848:	52800142 	mov	w2, #0xa                   	// #10
    b84c:	aa1303e0 	mov	x0, x19
    b850:	94000d54 	bl	eda0 <__multadd>
    b854:	aa0003f4 	mov	x20, x0
    b858:	aa1903e1 	mov	x1, x25
    b85c:	aa1303e0 	mov	x0, x19
    b860:	52800003 	mov	w3, #0x0                   	// #0
    b864:	52800142 	mov	w2, #0xa                   	// #10
    b868:	eb1b033f 	cmp	x25, x27
    b86c:	540022a0 	b.eq	bcc0 <_dtoa_r+0xdd0>  // b.none
    b870:	94000d4c 	bl	eda0 <__multadd>
    b874:	aa0003f9 	mov	x25, x0
    b878:	aa1b03e1 	mov	x1, x27
    b87c:	aa1303e0 	mov	x0, x19
    b880:	52800003 	mov	w3, #0x0                   	// #0
    b884:	52800142 	mov	w2, #0xa                   	// #10
    b888:	94000d46 	bl	eda0 <__multadd>
    b88c:	aa0003fb 	mov	x27, x0
    b890:	17ffffc6 	b	b7a8 <_dtoa_r+0x8b8>
    b894:	b94083e0 	ldr	w0, [sp, #128]
    b898:	7100037f 	cmp	w27, #0x0
    b89c:	7a40bac0 	ccmp	w22, #0x0, #0x0, lt	// lt = tstop
    b8a0:	fc60d881 	ldr	d1, [x4, w0, sxtw #3]
    b8a4:	540028cc 	b.gt	bdbc <_dtoa_r+0xecc>
    b8a8:	350015f6 	cbnz	w22, bb64 <_dtoa_r+0xc74>
    b8ac:	1e629000 	fmov	d0, #5.000000000000000000e+00
    b8b0:	1e600821 	fmul	d1, d1, d0
    b8b4:	9e670340 	fmov	d0, x26
    b8b8:	1e602030 	fcmpe	d1, d0
    b8bc:	5400154a 	b.ge	bb64 <_dtoa_r+0xc74>  // b.tcont
    b8c0:	aa1703f5 	mov	x21, x23
    b8c4:	d280001c 	mov	x28, #0x0                   	// #0
    b8c8:	d2800019 	mov	x25, #0x0                   	// #0
    b8cc:	14000096 	b	bb24 <_dtoa_r+0xc34>
    b8d0:	52800020 	mov	w0, #0x1                   	// #1
    b8d4:	b9008be0 	str	w0, [sp, #136]
    b8d8:	17fffee4 	b	b468 <_dtoa_r+0x578>
    b8dc:	5280003b 	mov	w27, #0x1                   	// #1
    b8e0:	2a1b03f6 	mov	w22, w27
    b8e4:	17fffec7 	b	b400 <_dtoa_r+0x510>
    b8e8:	aa1c03e1 	mov	x1, x28
    b8ec:	aa1403e0 	mov	x0, x20
    b8f0:	b90093e5 	str	w5, [sp, #144]
    b8f4:	b900a3e4 	str	w4, [sp, #160]
    b8f8:	94000f52 	bl	f640 <__mcmp>
    b8fc:	b94093e5 	ldr	w5, [sp, #144]
    b900:	b940a3e4 	ldr	w4, [sp, #160]
    b904:	36fff020 	tbz	w0, #31, b708 <_dtoa_r+0x818>
    b908:	aa1403e1 	mov	x1, x20
    b90c:	aa1303e0 	mov	x0, x19
    b910:	52800003 	mov	w3, #0x0                   	// #0
    b914:	52800142 	mov	w2, #0xa                   	// #10
    b918:	b90093e5 	str	w5, [sp, #144]
    b91c:	b900a3e4 	str	w4, [sp, #160]
    b920:	94000d20 	bl	eda0 <__multadd>
    b924:	b94083e1 	ldr	w1, [sp, #128]
    b928:	aa0003f4 	mov	x20, x0
    b92c:	b9408be0 	ldr	w0, [sp, #136]
    b930:	51000421 	sub	w1, w1, #0x1
    b934:	b90083e1 	str	w1, [sp, #128]
    b938:	b94093e5 	ldr	w5, [sp, #144]
    b93c:	b940a3e4 	ldr	w4, [sp, #160]
    b940:	350031e0 	cbnz	w0, bf7c <_dtoa_r+0x108c>
    b944:	b940abe0 	ldr	w0, [sp, #168]
    b948:	7100001f 	cmp	w0, #0x0
    b94c:	2a0003f6 	mov	w22, w0
    b950:	7a40d884 	ccmp	w4, #0x0, #0x4, le
    b954:	54ffee01 	b.ne	b714 <_dtoa_r+0x824>  // b.any
    b958:	d2800015 	mov	x21, #0x0                   	// #0
    b95c:	14000007 	b	b978 <_dtoa_r+0xa88>
    b960:	aa1403e1 	mov	x1, x20
    b964:	aa1303e0 	mov	x0, x19
    b968:	52800003 	mov	w3, #0x0                   	// #0
    b96c:	52800142 	mov	w2, #0xa                   	// #10
    b970:	94000d0c 	bl	eda0 <__multadd>
    b974:	aa0003f4 	mov	x20, x0
    b978:	aa1c03e1 	mov	x1, x28
    b97c:	aa1403e0 	mov	x0, x20
    b980:	97fffcf0 	bl	ad40 <quorem>
    b984:	1100c003 	add	w3, w0, #0x30
    b988:	38356ae3 	strb	w3, [x23, x21]
    b98c:	910006b5 	add	x21, x21, #0x1
    b990:	6b1502df 	cmp	w22, w21
    b994:	54fffe6c 	b.gt	b960 <_dtoa_r+0xa70>
    b998:	710002df 	cmp	w22, #0x0
    b99c:	510006d6 	sub	w22, w22, #0x1
    b9a0:	d2800020 	mov	x0, #0x1                   	// #1
    b9a4:	9a96d416 	csinc	x22, x0, x22, le
    b9a8:	8b1602f6 	add	x22, x23, x22
    b9ac:	d2800015 	mov	x21, #0x0                   	// #0
    b9b0:	52800022 	mov	w2, #0x1                   	// #1
    b9b4:	aa1403e1 	mov	x1, x20
    b9b8:	aa1303e0 	mov	x0, x19
    b9bc:	b9008be3 	str	w3, [sp, #136]
    b9c0:	94000ec4 	bl	f4d0 <__lshift>
    b9c4:	aa0003f4 	mov	x20, x0
    b9c8:	aa1c03e1 	mov	x1, x28
    b9cc:	94000f1d 	bl	f640 <__mcmp>
    b9d0:	7100001f 	cmp	w0, #0x0
    b9d4:	5400008c 	b.gt	b9e4 <_dtoa_r+0xaf4>
    b9d8:	14000117 	b	be34 <_dtoa_r+0xf44>
    b9dc:	eb1602ff 	cmp	x23, x22
    b9e0:	540023e0 	b.eq	be5c <_dtoa_r+0xf6c>  // b.none
    b9e4:	aa1603e2 	mov	x2, x22
    b9e8:	d10006d6 	sub	x22, x22, #0x1
    b9ec:	385ff040 	ldurb	w0, [x2, #-1]
    b9f0:	7100e41f 	cmp	w0, #0x39
    b9f4:	54ffff40 	b.eq	b9dc <_dtoa_r+0xaec>  // b.none
    b9f8:	b94083fa 	ldr	w26, [sp, #128]
    b9fc:	11000400 	add	w0, w0, #0x1
    ba00:	390002c0 	strb	w0, [x22]
    ba04:	aa1c03e1 	mov	x1, x28
    ba08:	aa1303e0 	mov	x0, x19
    ba0c:	f90043e2 	str	x2, [sp, #128]
    ba10:	94000cdc 	bl	ed80 <_Bfree>
    ba14:	f94043e2 	ldr	x2, [sp, #128]
    ba18:	b40009b9 	cbz	x25, bb4c <_dtoa_r+0xc5c>
    ba1c:	f10002bf 	cmp	x21, #0x0
    ba20:	fa5912a4 	ccmp	x21, x25, #0x4, ne	// ne = any
    ba24:	540000c0 	b.eq	ba3c <_dtoa_r+0xb4c>  // b.none
    ba28:	aa1503e1 	mov	x1, x21
    ba2c:	aa1303e0 	mov	x0, x19
    ba30:	f90043e2 	str	x2, [sp, #128]
    ba34:	94000cd3 	bl	ed80 <_Bfree>
    ba38:	f94043e2 	ldr	x2, [sp, #128]
    ba3c:	aa1703f5 	mov	x21, x23
    ba40:	aa0203f7 	mov	x23, x2
    ba44:	17ffff3b 	b	b730 <_dtoa_r+0x840>
    ba48:	aa0003e1 	mov	x1, x0
    ba4c:	2a0503e2 	mov	w2, w5
    ba50:	aa1303e0 	mov	x0, x19
    ba54:	b90093e7 	str	w7, [sp, #144]
    ba58:	b900a3e6 	str	w6, [sp, #160]
    ba5c:	94000e55 	bl	f3b0 <__pow5mult>
    ba60:	b94093e7 	ldr	w7, [sp, #144]
    ba64:	aa0003fc 	mov	x28, x0
    ba68:	b940a3e6 	ldr	w6, [sp, #160]
    ba6c:	710006bf 	cmp	w21, #0x1
    ba70:	54000a4d 	b.le	bbb8 <_dtoa_r+0xcc8>
    ba74:	52800005 	mov	w5, #0x0                   	// #0
    ba78:	b9401780 	ldr	w0, [x28, #20]
    ba7c:	b90093e7 	str	w7, [sp, #144]
    ba80:	51000400 	sub	w0, w0, #0x1
    ba84:	29141be5 	stp	w5, w6, [sp, #160]
    ba88:	8b20cb80 	add	x0, x28, w0, sxtw #2
    ba8c:	b9401800 	ldr	w0, [x0, #24]
    ba90:	94000d54 	bl	efe0 <__hi0bits>
    ba94:	52800401 	mov	w1, #0x20                  	// #32
    ba98:	b94093e7 	ldr	w7, [sp, #144]
    ba9c:	29541be5 	ldp	w5, w6, [sp, #160]
    baa0:	4b000020 	sub	w0, w1, w0
    baa4:	17fffee7 	b	b640 <_dtoa_r+0x750>
    baa8:	1e604121 	fmov	d1, d9
    baac:	52800042 	mov	w2, #0x2                   	// #2
    bab0:	17fffdcc 	b	b1e0 <_dtoa_r+0x2f0>
    bab4:	eb0002ff 	cmp	x23, x0
    bab8:	54001dc0 	b.eq	be70 <_dtoa_r+0xf80>  // b.none
    babc:	aa0003e2 	mov	x2, x0
    bac0:	385ffc01 	ldrb	w1, [x0, #-1]!
    bac4:	7100e43f 	cmp	w1, #0x39
    bac8:	54ffff60 	b.eq	bab4 <_dtoa_r+0xbc4>  // b.none
    bacc:	11000421 	add	w1, w1, #0x1
    bad0:	12001c21 	and	w1, w1, #0xff
    bad4:	aa1703f5 	mov	x21, x23
    bad8:	aa0203f7 	mov	x23, x2
    badc:	39000001 	strb	w1, [x0]
    bae0:	17ffff17 	b	b73c <_dtoa_r+0x84c>
    bae4:	52800781 	mov	w1, #0x3c                  	// #60
    bae8:	4b000020 	sub	w0, w1, w0
    baec:	54ffdde0 	b.eq	b6a8 <_dtoa_r+0x7b8>  // b.none
    baf0:	17fffee9 	b	b694 <_dtoa_r+0x7a4>
    baf4:	52800003 	mov	w3, #0x0                   	// #0
    baf8:	528000a2 	mov	w2, #0x5                   	// #5
    bafc:	aa1c03e1 	mov	x1, x28
    bb00:	aa1303e0 	mov	x0, x19
    bb04:	94000ca7 	bl	eda0 <__multadd>
    bb08:	aa0003fc 	mov	x28, x0
    bb0c:	aa1c03e1 	mov	x1, x28
    bb10:	aa1403e0 	mov	x0, x20
    bb14:	aa1703f5 	mov	x21, x23
    bb18:	94000eca 	bl	f640 <__mcmp>
    bb1c:	7100001f 	cmp	w0, #0x0
    bb20:	54ffdfcd 	b.le	b718 <_dtoa_r+0x828>
    bb24:	b94083e0 	ldr	w0, [sp, #128]
    bb28:	910006f7 	add	x23, x23, #0x1
    bb2c:	1100041a 	add	w26, w0, #0x1
    bb30:	52800620 	mov	w0, #0x31                  	// #49
    bb34:	390002a0 	strb	w0, [x21]
    bb38:	17fffefa 	b	b720 <_dtoa_r+0x830>
    bb3c:	aa0003e2 	mov	x2, x0
    bb40:	385ffc01 	ldrb	w1, [x0, #-1]!
    bb44:	7100c03f 	cmp	w1, #0x30
    bb48:	54ffffa0 	b.eq	bb3c <_dtoa_r+0xc4c>  // b.none
    bb4c:	aa1703f5 	mov	x21, x23
    bb50:	aa0203f7 	mov	x23, x2
    bb54:	17fffefa 	b	b73c <_dtoa_r+0x84c>
    bb58:	1e604121 	fmov	d1, d9
    bb5c:	52800042 	mov	w2, #0x2                   	// #2
    bb60:	17fffdac 	b	b210 <_dtoa_r+0x320>
    bb64:	d280001c 	mov	x28, #0x0                   	// #0
    bb68:	d2800019 	mov	x25, #0x0                   	// #0
    bb6c:	17fffeeb 	b	b718 <_dtoa_r+0x828>
    bb70:	4b1c0060 	sub	w0, w3, w28
    bb74:	0b1600c6 	add	w6, w6, w22
    bb78:	0b0000a5 	add	w5, w5, w0
    bb7c:	b9008fe7 	str	w7, [sp, #140]
    bb80:	0b0702c7 	add	w7, w22, w7
    bb84:	2a0303fc 	mov	w28, w3
    bb88:	52800003 	mov	w3, #0x0                   	// #0
    bb8c:	aa1303e0 	mov	x0, x19
    bb90:	52800021 	mov	w1, #0x1                   	// #1
    bb94:	b90093e7 	str	w7, [sp, #144]
    bb98:	29140fe5 	stp	w5, w3, [sp, #160]
    bb9c:	b900afe6 	str	w6, [sp, #172]
    bba0:	94000d58 	bl	f100 <__i2b>
    bba4:	b94093e7 	ldr	w7, [sp, #144]
    bba8:	aa0003f9 	mov	x25, x0
    bbac:	29540fe5 	ldp	w5, w3, [sp, #160]
    bbb0:	b940afe6 	ldr	w6, [sp, #172]
    bbb4:	17fffe80 	b	b5b4 <_dtoa_r+0x6c4>
    bbb8:	f240cf5f 	tst	x26, #0xfffffffffffff
    bbbc:	54fff5c1 	b.ne	ba74 <_dtoa_r+0xb84>  // b.any
    bbc0:	d360ff40 	lsr	x0, x26, #32
    bbc4:	f26c281f 	tst	x0, #0x7ff00000
    bbc8:	54fff560 	b.eq	ba74 <_dtoa_r+0xb84>  // b.none
    bbcc:	110004e7 	add	w7, w7, #0x1
    bbd0:	110004c6 	add	w6, w6, #0x1
    bbd4:	52800025 	mov	w5, #0x1                   	// #1
    bbd8:	17ffffa8 	b	ba78 <_dtoa_r+0xb88>
    bbdc:	52800055 	mov	w21, #0x2                   	// #2
    bbe0:	b9008bff 	str	wzr, [sp, #136]
    bbe4:	17fffe21 	b	b468 <_dtoa_r+0x578>
    bbe8:	2a0303e2 	mov	w2, w3
    bbec:	aa1903e1 	mov	x1, x25
    bbf0:	aa1303e0 	mov	x0, x19
    bbf4:	b90093e3 	str	w3, [sp, #144]
    bbf8:	291417e7 	stp	w7, w5, [sp, #160]
    bbfc:	b900afe6 	str	w6, [sp, #172]
    bc00:	94000dec 	bl	f3b0 <__pow5mult>
    bc04:	aa1403e2 	mov	x2, x20
    bc08:	aa0003f9 	mov	x25, x0
    bc0c:	aa1903e1 	mov	x1, x25
    bc10:	aa1303e0 	mov	x0, x19
    bc14:	94000d6b 	bl	f1c0 <__multiply>
    bc18:	aa1403e1 	mov	x1, x20
    bc1c:	aa0003f4 	mov	x20, x0
    bc20:	aa1303e0 	mov	x0, x19
    bc24:	94000c57 	bl	ed80 <_Bfree>
    bc28:	b94093e3 	ldr	w3, [sp, #144]
    bc2c:	295417e7 	ldp	w7, w5, [sp, #160]
    bc30:	6b03039c 	subs	w28, w28, w3
    bc34:	b940afe6 	ldr	w6, [sp, #172]
    bc38:	54ffcec0 	b.eq	b610 <_dtoa_r+0x720>  // b.none
    bc3c:	17fffe6c 	b	b5ec <_dtoa_r+0x6fc>
    bc40:	aa1303e0 	mov	x0, x19
    bc44:	b900a3e3 	str	w3, [sp, #160]
    bc48:	94000c4e 	bl	ed80 <_Bfree>
    bc4c:	b9408be0 	ldr	w0, [sp, #136]
    bc50:	b940a3e3 	ldr	w3, [sp, #160]
    bc54:	37f800c0 	tbnz	w0, #31, bc6c <_dtoa_r+0xd7c>
    bc58:	b9408be0 	ldr	w0, [sp, #136]
    bc5c:	1200035a 	and	w26, w26, #0x1
    bc60:	2a0002a0 	orr	w0, w21, w0
    bc64:	2a00035a 	orr	w26, w26, w0
    bc68:	3500045a 	cbnz	w26, bcf0 <_dtoa_r+0xe00>
    bc6c:	52800022 	mov	w2, #0x1                   	// #1
    bc70:	aa1403e1 	mov	x1, x20
    bc74:	aa1303e0 	mov	x0, x19
    bc78:	b9008be3 	str	w3, [sp, #136]
    bc7c:	94000e15 	bl	f4d0 <__lshift>
    bc80:	aa0003f4 	mov	x20, x0
    bc84:	aa1c03e1 	mov	x1, x28
    bc88:	94000e6e 	bl	f640 <__mcmp>
    bc8c:	b9408be3 	ldr	w3, [sp, #136]
    bc90:	7100001f 	cmp	w0, #0x0
    bc94:	5400198d 	b.le	bfc4 <_dtoa_r+0x10d4>
    bc98:	7100e47f 	cmp	w3, #0x39
    bc9c:	54001440 	b.eq	bf24 <_dtoa_r+0x1034>  // b.none
    bca0:	b9408fe0 	ldr	w0, [sp, #140]
    bca4:	1100c403 	add	w3, w0, #0x31
    bca8:	f9404be2 	ldr	x2, [sp, #144]
    bcac:	aa1903f5 	mov	x21, x25
    bcb0:	b94083fa 	ldr	w26, [sp, #128]
    bcb4:	aa1b03f9 	mov	x25, x27
    bcb8:	38001443 	strb	w3, [x2], #1
    bcbc:	17ffff52 	b	ba04 <_dtoa_r+0xb14>
    bcc0:	94000c38 	bl	eda0 <__multadd>
    bcc4:	aa0003f9 	mov	x25, x0
    bcc8:	aa0003fb 	mov	x27, x0
    bccc:	17fffeb7 	b	b7a8 <_dtoa_r+0x8b8>
    bcd0:	b9408be0 	ldr	w0, [sp, #136]
    bcd4:	37f81920 	tbnz	w0, #31, bff8 <_dtoa_r+0x1108>
    bcd8:	b940abe1 	ldr	w1, [sp, #168]
    bcdc:	2a0002a0 	orr	w0, w21, w0
    bce0:	2a000020 	orr	w0, w1, w0
    bce4:	340018a0 	cbz	w0, bff8 <_dtoa_r+0x1108>
    bce8:	7100005f 	cmp	w2, #0x0
    bcec:	54ffda0d 	b.le	b82c <_dtoa_r+0x93c>
    bcf0:	7100e47f 	cmp	w3, #0x39
    bcf4:	54001180 	b.eq	bf24 <_dtoa_r+0x1034>  // b.none
    bcf8:	f9404be2 	ldr	x2, [sp, #144]
    bcfc:	11000463 	add	w3, w3, #0x1
    bd00:	aa1903f5 	mov	x21, x25
    bd04:	b94083fa 	ldr	w26, [sp, #128]
    bd08:	aa1b03f9 	mov	x25, x27
    bd0c:	38001443 	strb	w3, [x2], #1
    bd10:	17ffff3d 	b	ba04 <_dtoa_r+0xb14>
    bd14:	b9008bff 	str	wzr, [sp, #136]
    bd18:	17fffcff 	b	b114 <_dtoa_r+0x224>
    bd1c:	34ffbb36 	cbz	w22, b480 <_dtoa_r+0x590>
    bd20:	b940abe8 	ldr	w8, [sp, #168]
    bd24:	7100011f 	cmp	w8, #0x0
    bd28:	54ffae4d 	b.le	b2f0 <_dtoa_r+0x400>
    bd2c:	11000442 	add	w2, w2, #0x1
    bd30:	1e649003 	fmov	d3, #1.000000000000000000e+01
    bd34:	1e639000 	fmov	d0, #7.000000000000000000e+00
    bd38:	b94083e0 	ldr	w0, [sp, #128]
    bd3c:	1e620042 	scvtf	d2, w2
    bd40:	1e630821 	fmul	d1, d1, d3
    bd44:	5100041a 	sub	w26, w0, #0x1
    bd48:	52bf9804 	mov	w4, #0xfcc00000            	// #-54525952
    bd4c:	1f420020 	fmadd	d0, d1, d2, d0
    bd50:	9e660000 	fmov	x0, d0
    bd54:	d360fc01 	lsr	x1, x0, #32
    bd58:	0b040021 	add	w1, w1, w4
    bd5c:	b3607c20 	bfi	x0, x1, #32, #32
    bd60:	17fffd3c 	b	b250 <_dtoa_r+0x360>
    bd64:	b940a7e1 	ldr	w1, [sp, #164]
    bd68:	340008a1 	cbz	w1, be7c <_dtoa_r+0xf8c>
    bd6c:	1110cc00 	add	w0, w0, #0x433
    bd70:	2a1c03e3 	mov	w3, w28
    bd74:	0b0000c6 	add	w6, w6, w0
    bd78:	b9008fe7 	str	w7, [sp, #140]
    bd7c:	0b0000e7 	add	w7, w7, w0
    bd80:	17ffff83 	b	bb8c <_dtoa_r+0xc9c>
    bd84:	913922b5 	add	x21, x21, #0xe48
    bd88:	17fffc8d 	b	afbc <_dtoa_r+0xcc>
    bd8c:	913962b5 	add	x21, x21, #0xe58
    bd90:	17fffc8b 	b	afbc <_dtoa_r+0xcc>
    bd94:	aa1403e1 	mov	x1, x20
    bd98:	2a1c03e2 	mov	w2, w28
    bd9c:	aa1303e0 	mov	x0, x19
    bda0:	b90093e7 	str	w7, [sp, #144]
    bda4:	29141be5 	stp	w5, w6, [sp, #160]
    bda8:	94000d82 	bl	f3b0 <__pow5mult>
    bdac:	b94093e7 	ldr	w7, [sp, #144]
    bdb0:	aa0003f4 	mov	x20, x0
    bdb4:	29541be5 	ldp	w5, w6, [sp, #160]
    bdb8:	17fffe16 	b	b610 <_dtoa_r+0x720>
    bdbc:	9e670340 	fmov	d0, x26
    bdc0:	aa1703e1 	mov	x1, x23
    bdc4:	1e611802 	fdiv	d2, d0, d1
    bdc8:	1e780042 	fcvtzs	w2, d2
    bdcc:	1e620042 	scvtf	d2, w2
    bdd0:	1100c040 	add	w0, w2, #0x30
    bdd4:	38001420 	strb	w0, [x1], #1
    bdd8:	1f418040 	fmsub	d0, d2, d1, d0
    bddc:	710006df 	cmp	w22, #0x1
    bde0:	54000860 	b.eq	beec <_dtoa_r+0xffc>  // b.none
    bde4:	51000860 	sub	w0, w3, #0x2
    bde8:	1e649003 	fmov	d3, #1.000000000000000000e+01
    bdec:	91000800 	add	x0, x0, #0x2
    bdf0:	8b0002e0 	add	x0, x23, x0
    bdf4:	14000009 	b	be18 <_dtoa_r+0xf28>
    bdf8:	1e611802 	fdiv	d2, d0, d1
    bdfc:	1e780042 	fcvtzs	w2, d2
    be00:	1e620042 	scvtf	d2, w2
    be04:	1100c043 	add	w3, w2, #0x30
    be08:	38001423 	strb	w3, [x1], #1
    be0c:	1f418040 	fmsub	d0, d2, d1, d0
    be10:	eb01001f 	cmp	x0, x1
    be14:	540006e0 	b.eq	bef0 <_dtoa_r+0x1000>  // b.none
    be18:	1e630800 	fmul	d0, d0, d3
    be1c:	1e602008 	fcmp	d0, #0.0
    be20:	54fffec1 	b.ne	bdf8 <_dtoa_r+0xf08>  // b.any
    be24:	aa1703f5 	mov	x21, x23
    be28:	b94083fa 	ldr	w26, [sp, #128]
    be2c:	aa0103f7 	mov	x23, x1
    be30:	17fffe43 	b	b73c <_dtoa_r+0x84c>
    be34:	54000061 	b.ne	be40 <_dtoa_r+0xf50>  // b.any
    be38:	b9408be3 	ldr	w3, [sp, #136]
    be3c:	3707dd43 	tbnz	w3, #0, b9e4 <_dtoa_r+0xaf4>
    be40:	aa1603e2 	mov	x2, x22
    be44:	d10006d6 	sub	x22, x22, #0x1
    be48:	385ff040 	ldurb	w0, [x2, #-1]
    be4c:	7100c01f 	cmp	w0, #0x30
    be50:	54ffff80 	b.eq	be40 <_dtoa_r+0xf50>  // b.none
    be54:	b94083fa 	ldr	w26, [sp, #128]
    be58:	17fffeeb 	b	ba04 <_dtoa_r+0xb14>
    be5c:	b94083e0 	ldr	w0, [sp, #128]
    be60:	1100041a 	add	w26, w0, #0x1
    be64:	52800620 	mov	w0, #0x31                  	// #49
    be68:	390002e0 	strb	w0, [x23]
    be6c:	17fffee6 	b	ba04 <_dtoa_r+0xb14>
    be70:	1100075a 	add	w26, w26, #0x1
    be74:	52800621 	mov	w1, #0x31                  	// #49
    be78:	17ffff17 	b	bad4 <_dtoa_r+0xbe4>
    be7c:	b940bbe1 	ldr	w1, [sp, #184]
    be80:	528006c0 	mov	w0, #0x36                  	// #54
    be84:	2a1c03e3 	mov	w3, w28
    be88:	b9008fe7 	str	w7, [sp, #140]
    be8c:	4b010000 	sub	w0, w0, w1
    be90:	0b0000c6 	add	w6, w6, w0
    be94:	0b0000e7 	add	w7, w7, w0
    be98:	17ffff3d 	b	bb8c <_dtoa_r+0xc9c>
    be9c:	b9400b21 	ldr	w1, [x25, #8]
    bea0:	aa1303e0 	mov	x0, x19
    bea4:	94000b93 	bl	ecf0 <_Balloc>
    bea8:	aa0003fb 	mov	x27, x0
    beac:	b4000980 	cbz	x0, bfdc <_dtoa_r+0x10ec>
    beb0:	b9801722 	ldrsw	x2, [x25, #20]
    beb4:	91004321 	add	x1, x25, #0x10
    beb8:	91004000 	add	x0, x0, #0x10
    bebc:	91000842 	add	x2, x2, #0x2
    bec0:	d37ef442 	lsl	x2, x2, #2
    bec4:	97fffa7f 	bl	a8c0 <memcpy>
    bec8:	aa1b03e1 	mov	x1, x27
    becc:	aa1303e0 	mov	x0, x19
    bed0:	52800022 	mov	w2, #0x1                   	// #1
    bed4:	94000d7f 	bl	f4d0 <__lshift>
    bed8:	aa0003fb 	mov	x27, x0
    bedc:	17fffe2f 	b	b798 <_dtoa_r+0x8a8>
    bee0:	aa1703f5 	mov	x21, x23
    bee4:	aa0003f7 	mov	x23, x0
    bee8:	17fffe15 	b	b73c <_dtoa_r+0x84c>
    beec:	aa0103e0 	mov	x0, x1
    bef0:	1e602800 	fadd	d0, d0, d0
    bef4:	1e612010 	fcmpe	d0, d1
    bef8:	5400022c 	b.gt	bf3c <_dtoa_r+0x104c>
    befc:	1e612000 	fcmp	d0, d1
    bf00:	54000041 	b.ne	bf08 <_dtoa_r+0x1018>  // b.any
    bf04:	370001c2 	tbnz	w2, #0, bf3c <_dtoa_r+0x104c>
    bf08:	aa1703f5 	mov	x21, x23
    bf0c:	b94083fa 	ldr	w26, [sp, #128]
    bf10:	aa0003f7 	mov	x23, x0
    bf14:	17fffe0a 	b	b73c <_dtoa_r+0x84c>
    bf18:	aa1903f5 	mov	x21, x25
    bf1c:	aa1b03f9 	mov	x25, x27
    bf20:	17fffea4 	b	b9b0 <_dtoa_r+0xac0>
    bf24:	f9404bf6 	ldr	x22, [sp, #144]
    bf28:	aa1903f5 	mov	x21, x25
    bf2c:	52800720 	mov	w0, #0x39                  	// #57
    bf30:	aa1b03f9 	mov	x25, x27
    bf34:	380016c0 	strb	w0, [x22], #1
    bf38:	17fffeab 	b	b9e4 <_dtoa_r+0xaf4>
    bf3c:	b94083fa 	ldr	w26, [sp, #128]
    bf40:	17fffedf 	b	babc <_dtoa_r+0xbcc>
    bf44:	7100e47f 	cmp	w3, #0x39
    bf48:	54fffee0 	b.eq	bf24 <_dtoa_r+0x1034>  // b.none
    bf4c:	f9404be2 	ldr	x2, [sp, #144]
    bf50:	aa1903f5 	mov	x21, x25
    bf54:	295103e1 	ldp	w1, w0, [sp, #136]
    bf58:	aa1b03f9 	mov	x25, x27
    bf5c:	b94083fa 	ldr	w26, [sp, #128]
    bf60:	1100c400 	add	w0, w0, #0x31
    bf64:	7100003f 	cmp	w1, #0x0
    bf68:	1a83c003 	csel	w3, w0, w3, gt
    bf6c:	38001443 	strb	w3, [x2], #1
    bf70:	17fffea5 	b	ba04 <_dtoa_r+0xb14>
    bf74:	aa0203e0 	mov	x0, x2
    bf78:	17fffd7e 	b	b570 <_dtoa_r+0x680>
    bf7c:	aa1903e1 	mov	x1, x25
    bf80:	aa1303e0 	mov	x0, x19
    bf84:	52800003 	mov	w3, #0x0                   	// #0
    bf88:	52800142 	mov	w2, #0xa                   	// #10
    bf8c:	b9008be5 	str	w5, [sp, #136]
    bf90:	b90093e4 	str	w4, [sp, #144]
    bf94:	94000b83 	bl	eda0 <__multadd>
    bf98:	b940abf6 	ldr	w22, [sp, #168]
    bf9c:	aa0003f9 	mov	x25, x0
    bfa0:	b94093e4 	ldr	w4, [sp, #144]
    bfa4:	710002df 	cmp	w22, #0x0
    bfa8:	7a40d884 	ccmp	w4, #0x0, #0x4, le
    bfac:	54000121 	b.ne	bfd0 <_dtoa_r+0x10e0>  // b.any
    bfb0:	b9408be5 	ldr	w5, [sp, #136]
    bfb4:	17fffdee 	b	b76c <_dtoa_r+0x87c>
    bfb8:	1e604041 	fmov	d1, d2
    bfbc:	52800042 	mov	w2, #0x2                   	// #2
    bfc0:	17fffc94 	b	b210 <_dtoa_r+0x320>
    bfc4:	54ffe721 	b.ne	bca8 <_dtoa_r+0xdb8>  // b.any
    bfc8:	3707e683 	tbnz	w3, #0, bc98 <_dtoa_r+0xda8>
    bfcc:	17ffff37 	b	bca8 <_dtoa_r+0xdb8>
    bfd0:	b940abf6 	ldr	w22, [sp, #168]
    bfd4:	35ffba36 	cbnz	w22, b718 <_dtoa_r+0x828>
    bfd8:	17fffec7 	b	baf4 <_dtoa_r+0xc04>
    bfdc:	b0000023 	adrp	x3, 10000 <__env_lock>
    bfe0:	b0000020 	adrp	x0, 10000 <__env_lock>
    bfe4:	91398063 	add	x3, x3, #0xe60
    bfe8:	9139e000 	add	x0, x0, #0xe78
    bfec:	d2800002 	mov	x2, #0x0                   	// #0
    bff0:	52805de1 	mov	w1, #0x2ef                 	// #751
    bff4:	97ffdac7 	bl	2b10 <__assert_func>
    bff8:	7100005f 	cmp	w2, #0x0
    bffc:	54ffe38c 	b.gt	bc6c <_dtoa_r+0xd7c>
    c000:	17ffff2a 	b	bca8 <_dtoa_r+0xdb8>
    c004:	b9005a7f 	str	wzr, [x19, #88]
    c008:	aa1303e0 	mov	x0, x19
    c00c:	52800001 	mov	w1, #0x0                   	// #0
    c010:	291117e7 	stp	w7, w5, [sp, #136]
    c014:	b90093e6 	str	w6, [sp, #144]
    c018:	94000b36 	bl	ecf0 <_Balloc>
    c01c:	295117e7 	ldp	w7, w5, [sp, #136]
    c020:	aa0003f7 	mov	x23, x0
    c024:	b94093e6 	ldr	w6, [sp, #144]
    c028:	b4000120 	cbz	x0, c04c <_dtoa_r+0x115c>
    c02c:	12800000 	mov	w0, #0xffffffff            	// #-1
    c030:	5280001b 	mov	w27, #0x0                   	// #0
    c034:	2a0003e3 	mov	w3, w0
    c038:	2a0003f6 	mov	w22, w0
    c03c:	f9002a77 	str	x23, [x19, #80]
    c040:	b9008bf9 	str	w25, [sp, #136]
    c044:	b900abe0 	str	w0, [sp, #168]
    c048:	17fffcac 	b	b2f8 <_dtoa_r+0x408>
    c04c:	90000023 	adrp	x3, 10000 <__env_lock>
    c050:	90000020 	adrp	x0, 10000 <__env_lock>
    c054:	91398063 	add	x3, x3, #0xe60
    c058:	9139e000 	add	x0, x0, #0xe78
    c05c:	d2800002 	mov	x2, #0x0                   	// #0
    c060:	528035e1 	mov	w1, #0x1af                 	// #431
    c064:	97ffdaab 	bl	2b10 <__assert_func>
	...

000000000000c070 <__set_ctype>:
    c070:	90000021 	adrp	x1, 10000 <__env_lock>
    c074:	913bc021 	add	x1, x1, #0xef0
    c078:	f9007c01 	str	x1, [x0, #248]
    c07c:	d65f03c0 	ret

000000000000c080 <_close_r>:
    c080:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    c084:	910003fd 	mov	x29, sp
    c088:	a90153f3 	stp	x19, x20, [sp, #16]
    c08c:	90001fb4 	adrp	x20, 400000 <__sf+0x10>
    c090:	aa0003f3 	mov	x19, x0
    c094:	b9046a9f 	str	wzr, [x20, #1128]
    c098:	2a0103e0 	mov	w0, w1
    c09c:	97ffd252 	bl	9e4 <_close>
    c0a0:	3100041f 	cmn	w0, #0x1
    c0a4:	54000080 	b.eq	c0b4 <_close_r+0x34>  // b.none
    c0a8:	a94153f3 	ldp	x19, x20, [sp, #16]
    c0ac:	a8c27bfd 	ldp	x29, x30, [sp], #32
    c0b0:	d65f03c0 	ret
    c0b4:	b9446a81 	ldr	w1, [x20, #1128]
    c0b8:	34ffff81 	cbz	w1, c0a8 <_close_r+0x28>
    c0bc:	b9000261 	str	w1, [x19]
    c0c0:	a94153f3 	ldp	x19, x20, [sp, #16]
    c0c4:	a8c27bfd 	ldp	x29, x30, [sp], #32
    c0c8:	d65f03c0 	ret
    c0cc:	00000000 	udf	#0

000000000000c0d0 <_reclaim_reent>:
    c0d0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    c0d4:	b0000021 	adrp	x1, 11000 <JIS_action_table>
    c0d8:	910003fd 	mov	x29, sp
    c0dc:	a90153f3 	stp	x19, x20, [sp, #16]
    c0e0:	aa0003f4 	mov	x20, x0
    c0e4:	f9413c20 	ldr	x0, [x1, #632]
    c0e8:	eb14001f 	cmp	x0, x20
    c0ec:	54000440 	b.eq	c174 <_reclaim_reent+0xa4>  // b.none
    c0f0:	f9403681 	ldr	x1, [x20, #104]
    c0f4:	b4000221 	cbz	x1, c138 <_reclaim_reent+0x68>
    c0f8:	f90013f5 	str	x21, [sp, #32]
    c0fc:	d2800015 	mov	x21, #0x0                   	// #0
    c100:	f8756833 	ldr	x19, [x1, x21]
    c104:	b40000f3 	cbz	x19, c120 <_reclaim_reent+0x50>
    c108:	aa1303e1 	mov	x1, x19
    c10c:	aa1403e0 	mov	x0, x20
    c110:	f9400273 	ldr	x19, [x19]
    c114:	940002fb 	bl	cd00 <_free_r>
    c118:	b5ffff93 	cbnz	x19, c108 <_reclaim_reent+0x38>
    c11c:	f9403681 	ldr	x1, [x20, #104]
    c120:	910022b5 	add	x21, x21, #0x8
    c124:	f10802bf 	cmp	x21, #0x200
    c128:	54fffec1 	b.ne	c100 <_reclaim_reent+0x30>  // b.any
    c12c:	aa1403e0 	mov	x0, x20
    c130:	940002f4 	bl	cd00 <_free_r>
    c134:	f94013f5 	ldr	x21, [sp, #32]
    c138:	f9402a81 	ldr	x1, [x20, #80]
    c13c:	b4000061 	cbz	x1, c148 <_reclaim_reent+0x78>
    c140:	aa1403e0 	mov	x0, x20
    c144:	940002ef 	bl	cd00 <_free_r>
    c148:	f9403e81 	ldr	x1, [x20, #120]
    c14c:	b4000061 	cbz	x1, c158 <_reclaim_reent+0x88>
    c150:	aa1403e0 	mov	x0, x20
    c154:	940002eb 	bl	cd00 <_free_r>
    c158:	f9402681 	ldr	x1, [x20, #72]
    c15c:	b40000c1 	cbz	x1, c174 <_reclaim_reent+0xa4>
    c160:	aa1403e0 	mov	x0, x20
    c164:	aa0103f0 	mov	x16, x1
    c168:	a94153f3 	ldp	x19, x20, [sp, #16]
    c16c:	a8c37bfd 	ldp	x29, x30, [sp], #48
    c170:	d61f0200 	br	x16
    c174:	a94153f3 	ldp	x19, x20, [sp, #16]
    c178:	a8c37bfd 	ldp	x29, x30, [sp], #48
    c17c:	d65f03c0 	ret

000000000000c180 <__sflush_r>:
    c180:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    c184:	910003fd 	mov	x29, sp
    c188:	79c02022 	ldrsh	w2, [x1, #16]
    c18c:	a90153f3 	stp	x19, x20, [sp, #16]
    c190:	aa0103f3 	mov	x19, x1
    c194:	a9025bf5 	stp	x21, x22, [sp, #32]
    c198:	aa0003f6 	mov	x22, x0
    c19c:	371807c2 	tbnz	w2, #3, c294 <__sflush_r+0x114>
    c1a0:	32150040 	orr	w0, w2, #0x800
    c1a4:	79002020 	strh	w0, [x1, #16]
    c1a8:	b9400821 	ldr	w1, [x1, #8]
    c1ac:	7100003f 	cmp	w1, #0x0
    c1b0:	54000b6d 	b.le	c31c <__sflush_r+0x19c>
    c1b4:	f9402664 	ldr	x4, [x19, #72]
    c1b8:	b4000644 	cbz	x4, c280 <__sflush_r+0x100>
    c1bc:	f9401a61 	ldr	x1, [x19, #48]
    c1c0:	b94002d4 	ldr	w20, [x22]
    c1c4:	b90002df 	str	wzr, [x22]
    c1c8:	37600b42 	tbnz	w2, #12, c330 <__sflush_r+0x1b0>
    c1cc:	d2800002 	mov	x2, #0x0                   	// #0
    c1d0:	aa1603e0 	mov	x0, x22
    c1d4:	52800023 	mov	w3, #0x1                   	// #1
    c1d8:	d63f0080 	blr	x4
    c1dc:	aa0003e2 	mov	x2, x0
    c1e0:	b100041f 	cmn	x0, #0x1
    c1e4:	54000bc0 	b.eq	c35c <__sflush_r+0x1dc>  // b.none
    c1e8:	f9401a61 	ldr	x1, [x19, #48]
    c1ec:	f9402664 	ldr	x4, [x19, #72]
    c1f0:	79c02260 	ldrsh	w0, [x19, #16]
    c1f4:	361000e0 	tbz	w0, #2, c210 <__sflush_r+0x90>
    c1f8:	f9402e60 	ldr	x0, [x19, #88]
    c1fc:	b9800a63 	ldrsw	x3, [x19, #8]
    c200:	cb030042 	sub	x2, x2, x3
    c204:	b4000060 	cbz	x0, c210 <__sflush_r+0x90>
    c208:	b9807260 	ldrsw	x0, [x19, #112]
    c20c:	cb000042 	sub	x2, x2, x0
    c210:	aa1603e0 	mov	x0, x22
    c214:	52800003 	mov	w3, #0x0                   	// #0
    c218:	d63f0080 	blr	x4
    c21c:	b100041f 	cmn	x0, #0x1
    c220:	540008c1 	b.ne	c338 <__sflush_r+0x1b8>  // b.any
    c224:	b94002c2 	ldr	w2, [x22]
    c228:	7100745f 	cmp	w2, #0x1d
    c22c:	54000688 	b.hi	c2fc <__sflush_r+0x17c>  // b.pmore
    c230:	92800023 	mov	x3, #0xfffffffffffffffe    	// #-2
    c234:	79c02261 	ldrsh	w1, [x19, #16]
    c238:	f2bbf7e3 	movk	x3, #0xdfbf, lsl #16
    c23c:	9ac22863 	asr	x3, x3, x2
    c240:	37000603 	tbnz	w3, #0, c300 <__sflush_r+0x180>
    c244:	f9400e64 	ldr	x4, [x19, #24]
    c248:	12147823 	and	w3, w1, #0xfffff7ff
    c24c:	f9000264 	str	x4, [x19]
    c250:	b9000a7f 	str	wzr, [x19, #8]
    c254:	79002263 	strh	w3, [x19, #16]
    c258:	37600921 	tbnz	w1, #12, c37c <__sflush_r+0x1fc>
    c25c:	f9402e61 	ldr	x1, [x19, #88]
    c260:	b90002d4 	str	w20, [x22]
    c264:	b40000e1 	cbz	x1, c280 <__sflush_r+0x100>
    c268:	9101d260 	add	x0, x19, #0x74
    c26c:	eb00003f 	cmp	x1, x0
    c270:	54000060 	b.eq	c27c <__sflush_r+0xfc>  // b.none
    c274:	aa1603e0 	mov	x0, x22
    c278:	940002a2 	bl	cd00 <_free_r>
    c27c:	f9002e7f 	str	xzr, [x19, #88]
    c280:	52800000 	mov	w0, #0x0                   	// #0
    c284:	a94153f3 	ldp	x19, x20, [sp, #16]
    c288:	a9425bf5 	ldp	x21, x22, [sp, #32]
    c28c:	a8c37bfd 	ldp	x29, x30, [sp], #48
    c290:	d65f03c0 	ret
    c294:	f9400c35 	ldr	x21, [x1, #24]
    c298:	b4ffff55 	cbz	x21, c280 <__sflush_r+0x100>
    c29c:	f9400021 	ldr	x1, [x1]
    c2a0:	f9000275 	str	x21, [x19]
    c2a4:	52800000 	mov	w0, #0x0                   	// #0
    c2a8:	cb150021 	sub	x1, x1, x21
    c2ac:	2a0103f4 	mov	w20, w1
    c2b0:	f240045f 	tst	x2, #0x3
    c2b4:	54000041 	b.ne	c2bc <__sflush_r+0x13c>  // b.any
    c2b8:	b9402260 	ldr	w0, [x19, #32]
    c2bc:	b9000e60 	str	w0, [x19, #12]
    c2c0:	7100003f 	cmp	w1, #0x0
    c2c4:	540000ac 	b.gt	c2d8 <__sflush_r+0x158>
    c2c8:	17ffffee 	b	c280 <__sflush_r+0x100>
    c2cc:	8b20c2b5 	add	x21, x21, w0, sxtw
    c2d0:	7100029f 	cmp	w20, #0x0
    c2d4:	54fffd6d 	b.le	c280 <__sflush_r+0x100>
    c2d8:	f9401a61 	ldr	x1, [x19, #48]
    c2dc:	2a1403e3 	mov	w3, w20
    c2e0:	f9402264 	ldr	x4, [x19, #64]
    c2e4:	aa1503e2 	mov	x2, x21
    c2e8:	aa1603e0 	mov	x0, x22
    c2ec:	d63f0080 	blr	x4
    c2f0:	4b000294 	sub	w20, w20, w0
    c2f4:	7100001f 	cmp	w0, #0x0
    c2f8:	54fffeac 	b.gt	c2cc <__sflush_r+0x14c>
    c2fc:	79c02261 	ldrsh	w1, [x19, #16]
    c300:	321a0021 	orr	w1, w1, #0x40
    c304:	79002261 	strh	w1, [x19, #16]
    c308:	a94153f3 	ldp	x19, x20, [sp, #16]
    c30c:	12800000 	mov	w0, #0xffffffff            	// #-1
    c310:	a9425bf5 	ldp	x21, x22, [sp, #32]
    c314:	a8c37bfd 	ldp	x29, x30, [sp], #48
    c318:	d65f03c0 	ret
    c31c:	b9407261 	ldr	w1, [x19, #112]
    c320:	7100003f 	cmp	w1, #0x0
    c324:	54fff48c 	b.gt	c1b4 <__sflush_r+0x34>
    c328:	52800000 	mov	w0, #0x0                   	// #0
    c32c:	17ffffd6 	b	c284 <__sflush_r+0x104>
    c330:	f9404a62 	ldr	x2, [x19, #144]
    c334:	17ffffb0 	b	c1f4 <__sflush_r+0x74>
    c338:	79c02261 	ldrsh	w1, [x19, #16]
    c33c:	f9400e63 	ldr	x3, [x19, #24]
    c340:	12147822 	and	w2, w1, #0xfffff7ff
    c344:	f9000263 	str	x3, [x19]
    c348:	b9000a7f 	str	wzr, [x19, #8]
    c34c:	79002262 	strh	w2, [x19, #16]
    c350:	3667f861 	tbz	w1, #12, c25c <__sflush_r+0xdc>
    c354:	f9004a60 	str	x0, [x19, #144]
    c358:	17ffffc1 	b	c25c <__sflush_r+0xdc>
    c35c:	b94002c0 	ldr	w0, [x22]
    c360:	34fff440 	cbz	w0, c1e8 <__sflush_r+0x68>
    c364:	7100741f 	cmp	w0, #0x1d
    c368:	7a561804 	ccmp	w0, #0x16, #0x4, ne	// ne = any
    c36c:	54fffc81 	b.ne	c2fc <__sflush_r+0x17c>  // b.any
    c370:	52800000 	mov	w0, #0x0                   	// #0
    c374:	b90002d4 	str	w20, [x22]
    c378:	17ffffc3 	b	c284 <__sflush_r+0x104>
    c37c:	35fff702 	cbnz	w2, c25c <__sflush_r+0xdc>
    c380:	f9004a60 	str	x0, [x19, #144]
    c384:	17ffffb6 	b	c25c <__sflush_r+0xdc>
	...

000000000000c390 <_fflush_r>:
    c390:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    c394:	910003fd 	mov	x29, sp
    c398:	a90153f3 	stp	x19, x20, [sp, #16]
    c39c:	aa0103f3 	mov	x19, x1
    c3a0:	aa0003f4 	mov	x20, x0
    c3a4:	f90013f5 	str	x21, [sp, #32]
    c3a8:	b4000060 	cbz	x0, c3b4 <_fflush_r+0x24>
    c3ac:	f9402401 	ldr	x1, [x0, #72]
    c3b0:	b4000481 	cbz	x1, c440 <_fflush_r+0xb0>
    c3b4:	79c02260 	ldrsh	w0, [x19, #16]
    c3b8:	52800015 	mov	w21, #0x0                   	// #0
    c3bc:	34000180 	cbz	w0, c3ec <_fflush_r+0x5c>
    c3c0:	b940b261 	ldr	w1, [x19, #176]
    c3c4:	37000041 	tbnz	w1, #0, c3cc <_fflush_r+0x3c>
    c3c8:	364801c0 	tbz	w0, #9, c400 <_fflush_r+0x70>
    c3cc:	aa1303e1 	mov	x1, x19
    c3d0:	aa1403e0 	mov	x0, x20
    c3d4:	97ffff6b 	bl	c180 <__sflush_r>
    c3d8:	2a0003f5 	mov	w21, w0
    c3dc:	b940b261 	ldr	w1, [x19, #176]
    c3e0:	37000061 	tbnz	w1, #0, c3ec <_fflush_r+0x5c>
    c3e4:	79402260 	ldrh	w0, [x19, #16]
    c3e8:	364801e0 	tbz	w0, #9, c424 <_fflush_r+0x94>
    c3ec:	a94153f3 	ldp	x19, x20, [sp, #16]
    c3f0:	2a1503e0 	mov	w0, w21
    c3f4:	f94013f5 	ldr	x21, [sp, #32]
    c3f8:	a8c37bfd 	ldp	x29, x30, [sp], #48
    c3fc:	d65f03c0 	ret
    c400:	f9405260 	ldr	x0, [x19, #160]
    c404:	97fff48b 	bl	9630 <__retarget_lock_acquire_recursive>
    c408:	aa1303e1 	mov	x1, x19
    c40c:	aa1403e0 	mov	x0, x20
    c410:	97ffff5c 	bl	c180 <__sflush_r>
    c414:	2a0003f5 	mov	w21, w0
    c418:	b940b261 	ldr	w1, [x19, #176]
    c41c:	3707fe81 	tbnz	w1, #0, c3ec <_fflush_r+0x5c>
    c420:	17fffff1 	b	c3e4 <_fflush_r+0x54>
    c424:	f9405260 	ldr	x0, [x19, #160]
    c428:	97fff492 	bl	9670 <__retarget_lock_release_recursive>
    c42c:	a94153f3 	ldp	x19, x20, [sp, #16]
    c430:	2a1503e0 	mov	w0, w21
    c434:	f94013f5 	ldr	x21, [sp, #32]
    c438:	a8c37bfd 	ldp	x29, x30, [sp], #48
    c43c:	d65f03c0 	ret
    c440:	97ffdb44 	bl	3150 <__sinit>
    c444:	17ffffdc 	b	c3b4 <_fflush_r+0x24>
	...

000000000000c450 <fflush>:
    c450:	b40004e0 	cbz	x0, c4ec <fflush+0x9c>
    c454:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    c458:	910003fd 	mov	x29, sp
    c45c:	a90153f3 	stp	x19, x20, [sp, #16]
    c460:	aa0003f3 	mov	x19, x0
    c464:	b0000020 	adrp	x0, 11000 <JIS_action_table>
    c468:	f90013f5 	str	x21, [sp, #32]
    c46c:	f9413c15 	ldr	x21, [x0, #632]
    c470:	b4000075 	cbz	x21, c47c <fflush+0x2c>
    c474:	f94026a0 	ldr	x0, [x21, #72]
    c478:	b4000280 	cbz	x0, c4c8 <fflush+0x78>
    c47c:	79c02260 	ldrsh	w0, [x19, #16]
    c480:	52800014 	mov	w20, #0x0                   	// #0
    c484:	34000180 	cbz	w0, c4b4 <fflush+0x64>
    c488:	b940b261 	ldr	w1, [x19, #176]
    c48c:	37000041 	tbnz	w1, #0, c494 <fflush+0x44>
    c490:	36480220 	tbz	w0, #9, c4d4 <fflush+0x84>
    c494:	aa1303e1 	mov	x1, x19
    c498:	aa1503e0 	mov	x0, x21
    c49c:	97ffff39 	bl	c180 <__sflush_r>
    c4a0:	2a0003f4 	mov	w20, w0
    c4a4:	b940b261 	ldr	w1, [x19, #176]
    c4a8:	37000061 	tbnz	w1, #0, c4b4 <fflush+0x64>
    c4ac:	79402260 	ldrh	w0, [x19, #16]
    c4b0:	36480180 	tbz	w0, #9, c4e0 <fflush+0x90>
    c4b4:	f94013f5 	ldr	x21, [sp, #32]
    c4b8:	2a1403e0 	mov	w0, w20
    c4bc:	a94153f3 	ldp	x19, x20, [sp, #16]
    c4c0:	a8c37bfd 	ldp	x29, x30, [sp], #48
    c4c4:	d65f03c0 	ret
    c4c8:	aa1503e0 	mov	x0, x21
    c4cc:	97ffdb21 	bl	3150 <__sinit>
    c4d0:	17ffffeb 	b	c47c <fflush+0x2c>
    c4d4:	f9405260 	ldr	x0, [x19, #160]
    c4d8:	97fff456 	bl	9630 <__retarget_lock_acquire_recursive>
    c4dc:	17ffffee 	b	c494 <fflush+0x44>
    c4e0:	f9405260 	ldr	x0, [x19, #160]
    c4e4:	97fff463 	bl	9670 <__retarget_lock_release_recursive>
    c4e8:	17fffff3 	b	c4b4 <fflush+0x64>
    c4ec:	b0000022 	adrp	x2, 11000 <JIS_action_table>
    c4f0:	90000001 	adrp	x1, c000 <_dtoa_r+0x1110>
    c4f4:	b0000020 	adrp	x0, 11000 <JIS_action_table>
    c4f8:	910f6042 	add	x2, x2, #0x3d8
    c4fc:	910e4021 	add	x1, x1, #0x390
    c500:	910a0000 	add	x0, x0, #0x280
    c504:	17ffdd0b 	b	3930 <_fwalk_sglue>

000000000000c508 <strchr>:
    c508:	52808024 	mov	w4, #0x401                 	// #1025
    c50c:	72a80204 	movk	w4, #0x4010, lsl #16
    c510:	4e010c20 	dup	v0.16b, w1
    c514:	927be802 	and	x2, x0, #0xffffffffffffffe0
    c518:	4e040c90 	dup	v16.4s, w4
    c51c:	f2401003 	ands	x3, x0, #0x1f
    c520:	4eb08607 	add	v7.4s, v16.4s, v16.4s
    c524:	540002a0 	b.eq	c578 <strchr+0x70>  // b.none
    c528:	4cdfa041 	ld1	{v1.16b, v2.16b}, [x2], #32
    c52c:	cb0303e3 	neg	x3, x3
    c530:	4e209823 	cmeq	v3.16b, v1.16b, #0
    c534:	6e208c25 	cmeq	v5.16b, v1.16b, v0.16b
    c538:	4e209844 	cmeq	v4.16b, v2.16b, #0
    c53c:	6e208c46 	cmeq	v6.16b, v2.16b, v0.16b
    c540:	4e271c63 	and	v3.16b, v3.16b, v7.16b
    c544:	4e271c84 	and	v4.16b, v4.16b, v7.16b
    c548:	4e301ca5 	and	v5.16b, v5.16b, v16.16b
    c54c:	4e301cc6 	and	v6.16b, v6.16b, v16.16b
    c550:	4ea51c71 	orr	v17.16b, v3.16b, v5.16b
    c554:	4ea61c92 	orr	v18.16b, v4.16b, v6.16b
    c558:	d37ff863 	lsl	x3, x3, #1
    c55c:	4e32be31 	addp	v17.16b, v17.16b, v18.16b
    c560:	92800005 	mov	x5, #0xffffffffffffffff    	// #-1
    c564:	4e32be31 	addp	v17.16b, v17.16b, v18.16b
    c568:	9ac324a3 	lsr	x3, x5, x3
    c56c:	4e083e25 	mov	x5, v17.d[0]
    c570:	8a2300a3 	bic	x3, x5, x3
    c574:	b50002a3 	cbnz	x3, c5c8 <strchr+0xc0>
    c578:	4cdfa041 	ld1	{v1.16b, v2.16b}, [x2], #32
    c57c:	4e209823 	cmeq	v3.16b, v1.16b, #0
    c580:	6e208c25 	cmeq	v5.16b, v1.16b, v0.16b
    c584:	4e209844 	cmeq	v4.16b, v2.16b, #0
    c588:	6e208c46 	cmeq	v6.16b, v2.16b, v0.16b
    c58c:	4ea51c71 	orr	v17.16b, v3.16b, v5.16b
    c590:	4ea61c92 	orr	v18.16b, v4.16b, v6.16b
    c594:	4eb21e31 	orr	v17.16b, v17.16b, v18.16b
    c598:	4ef1be31 	addp	v17.2d, v17.2d, v17.2d
    c59c:	4e083e23 	mov	x3, v17.d[0]
    c5a0:	b4fffec3 	cbz	x3, c578 <strchr+0x70>
    c5a4:	4e271c63 	and	v3.16b, v3.16b, v7.16b
    c5a8:	4e271c84 	and	v4.16b, v4.16b, v7.16b
    c5ac:	4e301ca5 	and	v5.16b, v5.16b, v16.16b
    c5b0:	4e301cc6 	and	v6.16b, v6.16b, v16.16b
    c5b4:	4ea51c71 	orr	v17.16b, v3.16b, v5.16b
    c5b8:	4ea61c92 	orr	v18.16b, v4.16b, v6.16b
    c5bc:	4e32be31 	addp	v17.16b, v17.16b, v18.16b
    c5c0:	4e32be31 	addp	v17.16b, v17.16b, v18.16b
    c5c4:	4e083e23 	mov	x3, v17.d[0]
    c5c8:	dac00063 	rbit	x3, x3
    c5cc:	d1008042 	sub	x2, x2, #0x20
    c5d0:	dac01063 	clz	x3, x3
    c5d4:	f240007f 	tst	x3, #0x1
    c5d8:	8b430440 	add	x0, x2, x3, lsr #1
    c5dc:	9a9f0000 	csel	x0, x0, xzr, eq	// eq = none
    c5e0:	d65f03c0 	ret
	...

000000000000c5f0 <frexp>:
    c5f0:	9e660002 	fmov	x2, d0
    c5f4:	b900001f 	str	wzr, [x0]
    c5f8:	12b00204 	mov	w4, #0x7fefffff            	// #2146435071
    c5fc:	d360f841 	ubfx	x1, x2, #32, #31
    c600:	d360fc43 	lsr	x3, x2, #32
    c604:	6b04003f 	cmp	w1, w4
    c608:	540002e8 	b.hi	c664 <frexp+0x74>  // b.pmore
    c60c:	2a020022 	orr	w2, w1, w2
    c610:	340002a2 	cbz	w2, c664 <frexp+0x74>
    c614:	52800004 	mov	w4, #0x0                   	// #0
    c618:	f26c287f 	tst	x3, #0x7ff00000
    c61c:	54000121 	b.ne	c640 <frexp+0x50>  // b.any
    c620:	d2e86a01 	mov	x1, #0x4350000000000000    	// #4850376798678024192
    c624:	9e670021 	fmov	d1, x1
    c628:	128006a4 	mov	w4, #0xffffffca            	// #-54
    c62c:	1e610800 	fmul	d0, d0, d1
    c630:	9e660001 	fmov	x1, d0
    c634:	d360fc21 	lsr	x1, x1, #32
    c638:	2a0103e3 	mov	w3, w1
    c63c:	12007821 	and	w1, w1, #0x7fffffff
    c640:	9e660002 	fmov	x2, d0
    c644:	12015063 	and	w3, w3, #0x800fffff
    c648:	13147c21 	asr	w1, w1, #20
    c64c:	320b2063 	orr	w3, w3, #0x3fe00000
    c650:	510ff821 	sub	w1, w1, #0x3fe
    c654:	0b040021 	add	w1, w1, w4
    c658:	b9000001 	str	w1, [x0]
    c65c:	b3607c62 	bfi	x2, x3, #32, #32
    c660:	9e670040 	fmov	d0, x2
    c664:	d65f03c0 	ret
	...

000000000000c670 <_realloc_r>:
    c670:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
    c674:	910003fd 	mov	x29, sp
    c678:	a9025bf5 	stp	x21, x22, [sp, #32]
    c67c:	aa0203f5 	mov	x21, x2
    c680:	b4001021 	cbz	x1, c884 <_realloc_r+0x214>
    c684:	a90363f7 	stp	x23, x24, [sp, #48]
    c688:	d1004038 	sub	x24, x1, #0x10
    c68c:	aa0003f6 	mov	x22, x0
    c690:	a90153f3 	stp	x19, x20, [sp, #16]
    c694:	aa0103f3 	mov	x19, x1
    c698:	91005eb4 	add	x20, x21, #0x17
    c69c:	a9046bf9 	stp	x25, x26, [sp, #64]
    c6a0:	97fff990 	bl	ace0 <__malloc_lock>
    c6a4:	aa1803f9 	mov	x25, x24
    c6a8:	f9400700 	ldr	x0, [x24, #8]
    c6ac:	927ef417 	and	x23, x0, #0xfffffffffffffffc
    c6b0:	f100ba9f 	cmp	x20, #0x2e
    c6b4:	54000908 	b.hi	c7d4 <_realloc_r+0x164>  // b.pmore
    c6b8:	52800001 	mov	w1, #0x0                   	// #0
    c6bc:	7100003f 	cmp	w1, #0x0
    c6c0:	d2800414 	mov	x20, #0x20                  	// #32
    c6c4:	fa550280 	ccmp	x20, x21, #0x0, eq	// eq = none
    c6c8:	54000943 	b.cc	c7f0 <_realloc_r+0x180>  // b.lo, b.ul, b.last
    c6cc:	eb1402ff 	cmp	x23, x20
    c6d0:	54000a4a 	b.ge	c818 <_realloc_r+0x1a8>  // b.tcont
    c6d4:	b0000021 	adrp	x1, 11000 <JIS_action_table>
    c6d8:	a90573fb 	stp	x27, x28, [sp, #80]
    c6dc:	9110003c 	add	x28, x1, #0x400
    c6e0:	8b170302 	add	x2, x24, x23
    c6e4:	f9400b83 	ldr	x3, [x28, #16]
    c6e8:	f9400441 	ldr	x1, [x2, #8]
    c6ec:	eb02007f 	cmp	x3, x2
    c6f0:	54000ea0 	b.eq	c8c4 <_realloc_r+0x254>  // b.none
    c6f4:	927ff823 	and	x3, x1, #0xfffffffffffffffe
    c6f8:	8b030043 	add	x3, x2, x3
    c6fc:	f9400463 	ldr	x3, [x3, #8]
    c700:	37000b63 	tbnz	w3, #0, c86c <_realloc_r+0x1fc>
    c704:	927ef421 	and	x1, x1, #0xfffffffffffffffc
    c708:	8b0102e3 	add	x3, x23, x1
    c70c:	eb03029f 	cmp	x20, x3
    c710:	5400078d 	b.le	c800 <_realloc_r+0x190>
    c714:	37000180 	tbnz	w0, #0, c744 <_realloc_r+0xd4>
    c718:	f85f027b 	ldur	x27, [x19, #-16]
    c71c:	cb1b031b 	sub	x27, x24, x27
    c720:	f9400760 	ldr	x0, [x27, #8]
    c724:	927ef400 	and	x0, x0, #0xfffffffffffffffc
    c728:	8b000021 	add	x1, x1, x0
    c72c:	8b17003a 	add	x26, x1, x23
    c730:	eb1a029f 	cmp	x20, x26
    c734:	540018ed 	b.le	ca50 <_realloc_r+0x3e0>
    c738:	8b0002fa 	add	x26, x23, x0
    c73c:	eb1a029f 	cmp	x20, x26
    c740:	5400146d 	b.le	c9cc <_realloc_r+0x35c>
    c744:	aa1503e1 	mov	x1, x21
    c748:	aa1603e0 	mov	x0, x22
    c74c:	97fff145 	bl	8c60 <_malloc_r>
    c750:	aa0003f5 	mov	x21, x0
    c754:	b4001d20 	cbz	x0, caf8 <_realloc_r+0x488>
    c758:	f9400701 	ldr	x1, [x24, #8]
    c75c:	d1004002 	sub	x2, x0, #0x10
    c760:	927ff821 	and	x1, x1, #0xfffffffffffffffe
    c764:	8b010301 	add	x1, x24, x1
    c768:	eb02003f 	cmp	x1, x2
    c76c:	54001140 	b.eq	c994 <_realloc_r+0x324>  // b.none
    c770:	d10022e2 	sub	x2, x23, #0x8
    c774:	f101205f 	cmp	x2, #0x48
    c778:	54001668 	b.hi	ca44 <_realloc_r+0x3d4>  // b.pmore
    c77c:	f1009c5f 	cmp	x2, #0x27
    c780:	54001148 	b.hi	c9a8 <_realloc_r+0x338>  // b.pmore
    c784:	aa1303e1 	mov	x1, x19
    c788:	f9400022 	ldr	x2, [x1]
    c78c:	f9000002 	str	x2, [x0]
    c790:	f9400422 	ldr	x2, [x1, #8]
    c794:	f9000402 	str	x2, [x0, #8]
    c798:	f9400821 	ldr	x1, [x1, #16]
    c79c:	f9000801 	str	x1, [x0, #16]
    c7a0:	aa1303e1 	mov	x1, x19
    c7a4:	aa1603e0 	mov	x0, x22
    c7a8:	94000156 	bl	cd00 <_free_r>
    c7ac:	aa1603e0 	mov	x0, x22
    c7b0:	97fff950 	bl	acf0 <__malloc_unlock>
    c7b4:	a94153f3 	ldp	x19, x20, [sp, #16]
    c7b8:	aa1503e0 	mov	x0, x21
    c7bc:	a9425bf5 	ldp	x21, x22, [sp, #32]
    c7c0:	a94363f7 	ldp	x23, x24, [sp, #48]
    c7c4:	a9446bf9 	ldp	x25, x26, [sp, #64]
    c7c8:	a94573fb 	ldp	x27, x28, [sp, #80]
    c7cc:	a8c67bfd 	ldp	x29, x30, [sp], #96
    c7d0:	d65f03c0 	ret
    c7d4:	927cee94 	and	x20, x20, #0xfffffffffffffff0
    c7d8:	b2407be1 	mov	x1, #0x7fffffff            	// #2147483647
    c7dc:	eb01029f 	cmp	x20, x1
    c7e0:	1a9f97e1 	cset	w1, hi	// hi = pmore
    c7e4:	7100003f 	cmp	w1, #0x0
    c7e8:	fa550280 	ccmp	x20, x21, #0x0, eq	// eq = none
    c7ec:	54fff702 	b.cs	c6cc <_realloc_r+0x5c>  // b.hs, b.nlast
    c7f0:	52800180 	mov	w0, #0xc                   	// #12
    c7f4:	d2800015 	mov	x21, #0x0                   	// #0
    c7f8:	b90002c0 	str	w0, [x22]
    c7fc:	14000015 	b	c850 <_realloc_r+0x1e0>
    c800:	a9410041 	ldp	x1, x0, [x2, #16]
    c804:	aa0303f7 	mov	x23, x3
    c808:	a94573fb 	ldp	x27, x28, [sp, #80]
    c80c:	f9000c20 	str	x0, [x1, #24]
    c810:	f9000801 	str	x1, [x0, #16]
    c814:	d503201f 	nop
    c818:	f9400721 	ldr	x1, [x25, #8]
    c81c:	cb1402e0 	sub	x0, x23, x20
    c820:	8b170322 	add	x2, x25, x23
    c824:	92400021 	and	x1, x1, #0x1
    c828:	f1007c1f 	cmp	x0, #0x1f
    c82c:	54000348 	b.hi	c894 <_realloc_r+0x224>  // b.pmore
    c830:	aa0102e1 	orr	x1, x23, x1
    c834:	f9000721 	str	x1, [x25, #8]
    c838:	f9400440 	ldr	x0, [x2, #8]
    c83c:	b2400000 	orr	x0, x0, #0x1
    c840:	f9000440 	str	x0, [x2, #8]
    c844:	aa1603e0 	mov	x0, x22
    c848:	aa1303f5 	mov	x21, x19
    c84c:	97fff929 	bl	acf0 <__malloc_unlock>
    c850:	a94153f3 	ldp	x19, x20, [sp, #16]
    c854:	aa1503e0 	mov	x0, x21
    c858:	a9425bf5 	ldp	x21, x22, [sp, #32]
    c85c:	a94363f7 	ldp	x23, x24, [sp, #48]
    c860:	a9446bf9 	ldp	x25, x26, [sp, #64]
    c864:	a8c67bfd 	ldp	x29, x30, [sp], #96
    c868:	d65f03c0 	ret
    c86c:	3707f6c0 	tbnz	w0, #0, c744 <_realloc_r+0xd4>
    c870:	f85f027b 	ldur	x27, [x19, #-16]
    c874:	cb1b031b 	sub	x27, x24, x27
    c878:	f9400760 	ldr	x0, [x27, #8]
    c87c:	927ef400 	and	x0, x0, #0xfffffffffffffffc
    c880:	17ffffae 	b	c738 <_realloc_r+0xc8>
    c884:	a9425bf5 	ldp	x21, x22, [sp, #32]
    c888:	aa0203e1 	mov	x1, x2
    c88c:	a8c67bfd 	ldp	x29, x30, [sp], #96
    c890:	17fff0f4 	b	8c60 <_malloc_r>
    c894:	8b140324 	add	x4, x25, x20
    c898:	aa010281 	orr	x1, x20, x1
    c89c:	f9000721 	str	x1, [x25, #8]
    c8a0:	b2400003 	orr	x3, x0, #0x1
    c8a4:	91004081 	add	x1, x4, #0x10
    c8a8:	aa1603e0 	mov	x0, x22
    c8ac:	f9000483 	str	x3, [x4, #8]
    c8b0:	f9400443 	ldr	x3, [x2, #8]
    c8b4:	b2400063 	orr	x3, x3, #0x1
    c8b8:	f9000443 	str	x3, [x2, #8]
    c8bc:	94000111 	bl	cd00 <_free_r>
    c8c0:	17ffffe1 	b	c844 <_realloc_r+0x1d4>
    c8c4:	927ef421 	and	x1, x1, #0xfffffffffffffffc
    c8c8:	91008283 	add	x3, x20, #0x20
    c8cc:	8b170022 	add	x2, x1, x23
    c8d0:	eb03005f 	cmp	x2, x3
    c8d4:	54000e4a 	b.ge	ca9c <_realloc_r+0x42c>  // b.tcont
    c8d8:	3707f360 	tbnz	w0, #0, c744 <_realloc_r+0xd4>
    c8dc:	f85f027b 	ldur	x27, [x19, #-16]
    c8e0:	cb1b031b 	sub	x27, x24, x27
    c8e4:	f9400760 	ldr	x0, [x27, #8]
    c8e8:	927ef400 	and	x0, x0, #0xfffffffffffffffc
    c8ec:	8b000021 	add	x1, x1, x0
    c8f0:	8b17003a 	add	x26, x1, x23
    c8f4:	eb1a007f 	cmp	x3, x26
    c8f8:	54fff20c 	b.gt	c738 <_realloc_r+0xc8>
    c8fc:	aa1b03f5 	mov	x21, x27
    c900:	d10022e2 	sub	x2, x23, #0x8
    c904:	f9400f60 	ldr	x0, [x27, #24]
    c908:	f8410ea1 	ldr	x1, [x21, #16]!
    c90c:	f9000c20 	str	x0, [x1, #24]
    c910:	f9000801 	str	x1, [x0, #16]
    c914:	f101205f 	cmp	x2, #0x48
    c918:	54001168 	b.hi	cb44 <_realloc_r+0x4d4>  // b.pmore
    c91c:	aa1503e0 	mov	x0, x21
    c920:	f1009c5f 	cmp	x2, #0x27
    c924:	54000129 	b.ls	c948 <_realloc_r+0x2d8>  // b.plast
    c928:	f9400260 	ldr	x0, [x19]
    c92c:	f9000b60 	str	x0, [x27, #16]
    c930:	f9400660 	ldr	x0, [x19, #8]
    c934:	f9000f60 	str	x0, [x27, #24]
    c938:	f100dc5f 	cmp	x2, #0x37
    c93c:	540010c8 	b.hi	cb54 <_realloc_r+0x4e4>  // b.pmore
    c940:	91004273 	add	x19, x19, #0x10
    c944:	91008360 	add	x0, x27, #0x20
    c948:	f9400261 	ldr	x1, [x19]
    c94c:	f9000001 	str	x1, [x0]
    c950:	f9400661 	ldr	x1, [x19, #8]
    c954:	f9000401 	str	x1, [x0, #8]
    c958:	f9400a61 	ldr	x1, [x19, #16]
    c95c:	f9000801 	str	x1, [x0, #16]
    c960:	8b140362 	add	x2, x27, x20
    c964:	cb140341 	sub	x1, x26, x20
    c968:	f9000b82 	str	x2, [x28, #16]
    c96c:	b2400021 	orr	x1, x1, #0x1
    c970:	aa1603e0 	mov	x0, x22
    c974:	f9000441 	str	x1, [x2, #8]
    c978:	f9400761 	ldr	x1, [x27, #8]
    c97c:	92400021 	and	x1, x1, #0x1
    c980:	aa140021 	orr	x1, x1, x20
    c984:	f9000761 	str	x1, [x27, #8]
    c988:	97fff8da 	bl	acf0 <__malloc_unlock>
    c98c:	a94573fb 	ldp	x27, x28, [sp, #80]
    c990:	17ffffb0 	b	c850 <_realloc_r+0x1e0>
    c994:	f9400420 	ldr	x0, [x1, #8]
    c998:	a94573fb 	ldp	x27, x28, [sp, #80]
    c99c:	927ef400 	and	x0, x0, #0xfffffffffffffffc
    c9a0:	8b0002f7 	add	x23, x23, x0
    c9a4:	17ffff9d 	b	c818 <_realloc_r+0x1a8>
    c9a8:	f9400260 	ldr	x0, [x19]
    c9ac:	f90002a0 	str	x0, [x21]
    c9b0:	f9400660 	ldr	x0, [x19, #8]
    c9b4:	f90006a0 	str	x0, [x21, #8]
    c9b8:	f100dc5f 	cmp	x2, #0x37
    c9bc:	540005e8 	b.hi	ca78 <_realloc_r+0x408>  // b.pmore
    c9c0:	91004261 	add	x1, x19, #0x10
    c9c4:	910042a0 	add	x0, x21, #0x10
    c9c8:	17ffff70 	b	c788 <_realloc_r+0x118>
    c9cc:	aa1b03f5 	mov	x21, x27
    c9d0:	d10022e2 	sub	x2, x23, #0x8
    c9d4:	f8410ea1 	ldr	x1, [x21, #16]!
    c9d8:	f9400f60 	ldr	x0, [x27, #24]
    c9dc:	f9000c20 	str	x0, [x1, #24]
    c9e0:	f9000801 	str	x1, [x0, #16]
    c9e4:	f101205f 	cmp	x2, #0x48
    c9e8:	54000408 	b.hi	ca68 <_realloc_r+0x3f8>  // b.pmore
    c9ec:	aa1503e0 	mov	x0, x21
    c9f0:	f1009c5f 	cmp	x2, #0x27
    c9f4:	54000129 	b.ls	ca18 <_realloc_r+0x3a8>  // b.plast
    c9f8:	f9400260 	ldr	x0, [x19]
    c9fc:	f9000b60 	str	x0, [x27, #16]
    ca00:	f9400660 	ldr	x0, [x19, #8]
    ca04:	f9000f60 	str	x0, [x27, #24]
    ca08:	f100dc5f 	cmp	x2, #0x37
    ca0c:	54000648 	b.hi	cad4 <_realloc_r+0x464>  // b.pmore
    ca10:	91004273 	add	x19, x19, #0x10
    ca14:	91008360 	add	x0, x27, #0x20
    ca18:	f9400261 	ldr	x1, [x19]
    ca1c:	f9000001 	str	x1, [x0]
    ca20:	f9400661 	ldr	x1, [x19, #8]
    ca24:	f9000401 	str	x1, [x0, #8]
    ca28:	f9400a61 	ldr	x1, [x19, #16]
    ca2c:	f9000801 	str	x1, [x0, #16]
    ca30:	aa1b03f9 	mov	x25, x27
    ca34:	aa1503f3 	mov	x19, x21
    ca38:	a94573fb 	ldp	x27, x28, [sp, #80]
    ca3c:	aa1a03f7 	mov	x23, x26
    ca40:	17ffff76 	b	c818 <_realloc_r+0x1a8>
    ca44:	aa1303e1 	mov	x1, x19
    ca48:	97fff7fe 	bl	aa40 <memmove>
    ca4c:	17ffff55 	b	c7a0 <_realloc_r+0x130>
    ca50:	a9410041 	ldp	x1, x0, [x2, #16]
    ca54:	f9000c20 	str	x0, [x1, #24]
    ca58:	aa1b03f5 	mov	x21, x27
    ca5c:	d10022e2 	sub	x2, x23, #0x8
    ca60:	f9000801 	str	x1, [x0, #16]
    ca64:	17ffffdc 	b	c9d4 <_realloc_r+0x364>
    ca68:	aa1303e1 	mov	x1, x19
    ca6c:	aa1503e0 	mov	x0, x21
    ca70:	97fff7f4 	bl	aa40 <memmove>
    ca74:	17ffffef 	b	ca30 <_realloc_r+0x3c0>
    ca78:	f9400a60 	ldr	x0, [x19, #16]
    ca7c:	f9000aa0 	str	x0, [x21, #16]
    ca80:	f9400e60 	ldr	x0, [x19, #24]
    ca84:	f9000ea0 	str	x0, [x21, #24]
    ca88:	f101205f 	cmp	x2, #0x48
    ca8c:	54000400 	b.eq	cb0c <_realloc_r+0x49c>  // b.none
    ca90:	91008261 	add	x1, x19, #0x20
    ca94:	910082a0 	add	x0, x21, #0x20
    ca98:	17ffff3c 	b	c788 <_realloc_r+0x118>
    ca9c:	8b140303 	add	x3, x24, x20
    caa0:	cb140041 	sub	x1, x2, x20
    caa4:	f9000b83 	str	x3, [x28, #16]
    caa8:	b2400021 	orr	x1, x1, #0x1
    caac:	aa1603e0 	mov	x0, x22
    cab0:	aa1303f5 	mov	x21, x19
    cab4:	f9000461 	str	x1, [x3, #8]
    cab8:	f9400701 	ldr	x1, [x24, #8]
    cabc:	92400021 	and	x1, x1, #0x1
    cac0:	aa140021 	orr	x1, x1, x20
    cac4:	f9000701 	str	x1, [x24, #8]
    cac8:	97fff88a 	bl	acf0 <__malloc_unlock>
    cacc:	a94573fb 	ldp	x27, x28, [sp, #80]
    cad0:	17ffff60 	b	c850 <_realloc_r+0x1e0>
    cad4:	f9400a60 	ldr	x0, [x19, #16]
    cad8:	f9001360 	str	x0, [x27, #32]
    cadc:	f9400e60 	ldr	x0, [x19, #24]
    cae0:	f9001760 	str	x0, [x27, #40]
    cae4:	f101205f 	cmp	x2, #0x48
    cae8:	54000200 	b.eq	cb28 <_realloc_r+0x4b8>  // b.none
    caec:	91008273 	add	x19, x19, #0x20
    caf0:	9100c360 	add	x0, x27, #0x30
    caf4:	17ffffc9 	b	ca18 <_realloc_r+0x3a8>
    caf8:	aa1603e0 	mov	x0, x22
    cafc:	d2800015 	mov	x21, #0x0                   	// #0
    cb00:	97fff87c 	bl	acf0 <__malloc_unlock>
    cb04:	a94573fb 	ldp	x27, x28, [sp, #80]
    cb08:	17ffff52 	b	c850 <_realloc_r+0x1e0>
    cb0c:	f9401260 	ldr	x0, [x19, #32]
    cb10:	f90012a0 	str	x0, [x21, #32]
    cb14:	9100c261 	add	x1, x19, #0x30
    cb18:	9100c2a0 	add	x0, x21, #0x30
    cb1c:	f9401662 	ldr	x2, [x19, #40]
    cb20:	f90016a2 	str	x2, [x21, #40]
    cb24:	17ffff19 	b	c788 <_realloc_r+0x118>
    cb28:	f9401260 	ldr	x0, [x19, #32]
    cb2c:	f9001b60 	str	x0, [x27, #48]
    cb30:	9100c273 	add	x19, x19, #0x30
    cb34:	91010360 	add	x0, x27, #0x40
    cb38:	f85f8261 	ldur	x1, [x19, #-8]
    cb3c:	f9001f61 	str	x1, [x27, #56]
    cb40:	17ffffb6 	b	ca18 <_realloc_r+0x3a8>
    cb44:	aa1303e1 	mov	x1, x19
    cb48:	aa1503e0 	mov	x0, x21
    cb4c:	97fff7bd 	bl	aa40 <memmove>
    cb50:	17ffff84 	b	c960 <_realloc_r+0x2f0>
    cb54:	f9400a60 	ldr	x0, [x19, #16]
    cb58:	f9001360 	str	x0, [x27, #32]
    cb5c:	f9400e60 	ldr	x0, [x19, #24]
    cb60:	f9001760 	str	x0, [x27, #40]
    cb64:	f101205f 	cmp	x2, #0x48
    cb68:	54000080 	b.eq	cb78 <_realloc_r+0x508>  // b.none
    cb6c:	91008273 	add	x19, x19, #0x20
    cb70:	9100c360 	add	x0, x27, #0x30
    cb74:	17ffff75 	b	c948 <_realloc_r+0x2d8>
    cb78:	f9401260 	ldr	x0, [x19, #32]
    cb7c:	f9001b60 	str	x0, [x27, #48]
    cb80:	9100c273 	add	x19, x19, #0x30
    cb84:	91010360 	add	x0, x27, #0x40
    cb88:	f85f8261 	ldur	x1, [x19, #-8]
    cb8c:	f9001f61 	str	x1, [x27, #56]
    cb90:	17ffff6e 	b	c948 <_realloc_r+0x2d8>
	...

000000000000cba0 <strlcpy>:
    cba0:	aa0103e3 	mov	x3, x1
    cba4:	b50000a2 	cbnz	x2, cbb8 <strlcpy+0x18>
    cba8:	14000008 	b	cbc8 <strlcpy+0x28>
    cbac:	38401464 	ldrb	w4, [x3], #1
    cbb0:	38001404 	strb	w4, [x0], #1
    cbb4:	340000e4 	cbz	w4, cbd0 <strlcpy+0x30>
    cbb8:	f1000442 	subs	x2, x2, #0x1
    cbbc:	54ffff81 	b.ne	cbac <strlcpy+0xc>  // b.any
    cbc0:	3900001f 	strb	wzr, [x0]
    cbc4:	d503201f 	nop
    cbc8:	38401460 	ldrb	w0, [x3], #1
    cbcc:	35ffffe0 	cbnz	w0, cbc8 <strlcpy+0x28>
    cbd0:	cb010060 	sub	x0, x3, x1
    cbd4:	d1000400 	sub	x0, x0, #0x1
    cbd8:	d65f03c0 	ret
    cbdc:	00000000 	udf	#0

000000000000cbe0 <_malloc_trim_r>:
    cbe0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
    cbe4:	910003fd 	mov	x29, sp
    cbe8:	a9025bf5 	stp	x21, x22, [sp, #32]
    cbec:	b0000036 	adrp	x22, 11000 <JIS_action_table>
    cbf0:	911002d6 	add	x22, x22, #0x400
    cbf4:	aa0003f5 	mov	x21, x0
    cbf8:	a90153f3 	stp	x19, x20, [sp, #16]
    cbfc:	f9001bf7 	str	x23, [sp, #48]
    cc00:	aa0103f7 	mov	x23, x1
    cc04:	97fff837 	bl	ace0 <__malloc_lock>
    cc08:	f9400ac0 	ldr	x0, [x22, #16]
    cc0c:	f9400414 	ldr	x20, [x0, #8]
    cc10:	927ef694 	and	x20, x20, #0xfffffffffffffffc
    cc14:	913f7e93 	add	x19, x20, #0xfdf
    cc18:	cb170273 	sub	x19, x19, x23
    cc1c:	9274ce73 	and	x19, x19, #0xfffffffffffff000
    cc20:	d1400673 	sub	x19, x19, #0x1, lsl #12
    cc24:	f13ffe7f 	cmp	x19, #0xfff
    cc28:	5400010d 	b.le	cc48 <_malloc_trim_r+0x68>
    cc2c:	d2800001 	mov	x1, #0x0                   	// #0
    cc30:	aa1503e0 	mov	x0, x21
    cc34:	940005c7 	bl	e350 <_sbrk_r>
    cc38:	f9400ac1 	ldr	x1, [x22, #16]
    cc3c:	8b140021 	add	x1, x1, x20
    cc40:	eb01001f 	cmp	x0, x1
    cc44:	54000120 	b.eq	cc68 <_malloc_trim_r+0x88>  // b.none
    cc48:	aa1503e0 	mov	x0, x21
    cc4c:	97fff829 	bl	acf0 <__malloc_unlock>
    cc50:	a94153f3 	ldp	x19, x20, [sp, #16]
    cc54:	52800000 	mov	w0, #0x0                   	// #0
    cc58:	a9425bf5 	ldp	x21, x22, [sp, #32]
    cc5c:	f9401bf7 	ldr	x23, [sp, #48]
    cc60:	a8c47bfd 	ldp	x29, x30, [sp], #64
    cc64:	d65f03c0 	ret
    cc68:	cb1303e1 	neg	x1, x19
    cc6c:	aa1503e0 	mov	x0, x21
    cc70:	940005b8 	bl	e350 <_sbrk_r>
    cc74:	b100041f 	cmn	x0, #0x1
    cc78:	54000220 	b.eq	ccbc <_malloc_trim_r+0xdc>  // b.none
    cc7c:	90001fa2 	adrp	x2, 400000 <__sf+0x10>
    cc80:	cb130294 	sub	x20, x20, x19
    cc84:	f9400ac3 	ldr	x3, [x22, #16]
    cc88:	b2400294 	orr	x20, x20, #0x1
    cc8c:	b9422041 	ldr	w1, [x2, #544]
    cc90:	aa1503e0 	mov	x0, x21
    cc94:	4b130021 	sub	w1, w1, w19
    cc98:	f9000474 	str	x20, [x3, #8]
    cc9c:	b9022041 	str	w1, [x2, #544]
    cca0:	97fff814 	bl	acf0 <__malloc_unlock>
    cca4:	a94153f3 	ldp	x19, x20, [sp, #16]
    cca8:	52800020 	mov	w0, #0x1                   	// #1
    ccac:	a9425bf5 	ldp	x21, x22, [sp, #32]
    ccb0:	f9401bf7 	ldr	x23, [sp, #48]
    ccb4:	a8c47bfd 	ldp	x29, x30, [sp], #64
    ccb8:	d65f03c0 	ret
    ccbc:	d2800001 	mov	x1, #0x0                   	// #0
    ccc0:	aa1503e0 	mov	x0, x21
    ccc4:	940005a3 	bl	e350 <_sbrk_r>
    ccc8:	f9400ac2 	ldr	x2, [x22, #16]
    cccc:	cb020001 	sub	x1, x0, x2
    ccd0:	f1007c3f 	cmp	x1, #0x1f
    ccd4:	54fffbad 	b.le	cc48 <_malloc_trim_r+0x68>
    ccd8:	b0000024 	adrp	x4, 11000 <JIS_action_table>
    ccdc:	b2400021 	orr	x1, x1, #0x1
    cce0:	f9000441 	str	x1, [x2, #8]
    cce4:	90001fa3 	adrp	x3, 400000 <__sf+0x10>
    cce8:	f941f881 	ldr	x1, [x4, #1008]
    ccec:	cb010000 	sub	x0, x0, x1
    ccf0:	b9022060 	str	w0, [x3, #544]
    ccf4:	17ffffd5 	b	cc48 <_malloc_trim_r+0x68>
	...

000000000000cd00 <_free_r>:
    cd00:	b4000a21 	cbz	x1, ce44 <_free_r+0x144>
    cd04:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    cd08:	910003fd 	mov	x29, sp
    cd0c:	a90153f3 	stp	x19, x20, [sp, #16]
    cd10:	aa0103f3 	mov	x19, x1
    cd14:	aa0003f4 	mov	x20, x0
    cd18:	97fff7f2 	bl	ace0 <__malloc_lock>
    cd1c:	f85f8265 	ldur	x5, [x19, #-8]
    cd20:	d1004263 	sub	x3, x19, #0x10
    cd24:	b0000020 	adrp	x0, 11000 <JIS_action_table>
    cd28:	91100000 	add	x0, x0, #0x400
    cd2c:	927ff8a2 	and	x2, x5, #0xfffffffffffffffe
    cd30:	8b020064 	add	x4, x3, x2
    cd34:	f9400806 	ldr	x6, [x0, #16]
    cd38:	f9400481 	ldr	x1, [x4, #8]
    cd3c:	927ef421 	and	x1, x1, #0xfffffffffffffffc
    cd40:	eb0400df 	cmp	x6, x4
    cd44:	54000c00 	b.eq	cec4 <_free_r+0x1c4>  // b.none
    cd48:	f9000481 	str	x1, [x4, #8]
    cd4c:	8b010086 	add	x6, x4, x1
    cd50:	37000345 	tbnz	w5, #0, cdb8 <_free_r+0xb8>
    cd54:	f85f0267 	ldur	x7, [x19, #-16]
    cd58:	b0000025 	adrp	x5, 11000 <JIS_action_table>
    cd5c:	f94004c6 	ldr	x6, [x6, #8]
    cd60:	cb070063 	sub	x3, x3, x7
    cd64:	8b070042 	add	x2, x2, x7
    cd68:	911040a5 	add	x5, x5, #0x410
    cd6c:	924000c6 	and	x6, x6, #0x1
    cd70:	f9400867 	ldr	x7, [x3, #16]
    cd74:	eb0500ff 	cmp	x7, x5
    cd78:	54000940 	b.eq	cea0 <_free_r+0x1a0>  // b.none
    cd7c:	f9400c68 	ldr	x8, [x3, #24]
    cd80:	f9000ce8 	str	x8, [x7, #24]
    cd84:	f9000907 	str	x7, [x8, #16]
    cd88:	b50001c6 	cbnz	x6, cdc0 <_free_r+0xc0>
    cd8c:	8b010042 	add	x2, x2, x1
    cd90:	f9400881 	ldr	x1, [x4, #16]
    cd94:	eb05003f 	cmp	x1, x5
    cd98:	54000ea0 	b.eq	cf6c <_free_r+0x26c>  // b.none
    cd9c:	f9400c85 	ldr	x5, [x4, #24]
    cda0:	f9000c25 	str	x5, [x1, #24]
    cda4:	b2400044 	orr	x4, x2, #0x1
    cda8:	f90008a1 	str	x1, [x5, #16]
    cdac:	f9000464 	str	x4, [x3, #8]
    cdb0:	f8226862 	str	x2, [x3, x2]
    cdb4:	14000006 	b	cdcc <_free_r+0xcc>
    cdb8:	f94004c5 	ldr	x5, [x6, #8]
    cdbc:	360006a5 	tbz	w5, #0, ce90 <_free_r+0x190>
    cdc0:	b2400041 	orr	x1, x2, #0x1
    cdc4:	f9000461 	str	x1, [x3, #8]
    cdc8:	f9000082 	str	x2, [x4]
    cdcc:	f107fc5f 	cmp	x2, #0x1ff
    cdd0:	540003c9 	b.ls	ce48 <_free_r+0x148>  // b.plast
    cdd4:	d349fc41 	lsr	x1, x2, #9
    cdd8:	f127fc5f 	cmp	x2, #0x9ff
    cddc:	540009c8 	b.hi	cf14 <_free_r+0x214>  // b.pmore
    cde0:	d346fc41 	lsr	x1, x2, #6
    cde4:	1100e424 	add	w4, w1, #0x39
    cde8:	1100e025 	add	w5, w1, #0x38
    cdec:	531f7884 	lsl	w4, w4, #1
    cdf0:	937d7c84 	sbfiz	x4, x4, #3, #32
    cdf4:	8b040004 	add	x4, x0, x4
    cdf8:	f85f0481 	ldr	x1, [x4], #-16
    cdfc:	eb01009f 	cmp	x4, x1
    ce00:	540000a1 	b.ne	ce14 <_free_r+0x114>  // b.any
    ce04:	14000053 	b	cf50 <_free_r+0x250>
    ce08:	f9400821 	ldr	x1, [x1, #16]
    ce0c:	eb01009f 	cmp	x4, x1
    ce10:	540000a0 	b.eq	ce24 <_free_r+0x124>  // b.none
    ce14:	f9400420 	ldr	x0, [x1, #8]
    ce18:	927ef400 	and	x0, x0, #0xfffffffffffffffc
    ce1c:	eb02001f 	cmp	x0, x2
    ce20:	54ffff48 	b.hi	ce08 <_free_r+0x108>  // b.pmore
    ce24:	f9400c24 	ldr	x4, [x1, #24]
    ce28:	a9011061 	stp	x1, x4, [x3, #16]
    ce2c:	aa1403e0 	mov	x0, x20
    ce30:	f9000883 	str	x3, [x4, #16]
    ce34:	f9000c23 	str	x3, [x1, #24]
    ce38:	a94153f3 	ldp	x19, x20, [sp, #16]
    ce3c:	a8c27bfd 	ldp	x29, x30, [sp], #32
    ce40:	17fff7ac 	b	acf0 <__malloc_unlock>
    ce44:	d65f03c0 	ret
    ce48:	d343fc44 	lsr	x4, x2, #3
    ce4c:	d2800022 	mov	x2, #0x1                   	// #1
    ce50:	11000481 	add	w1, w4, #0x1
    ce54:	f9400405 	ldr	x5, [x0, #8]
    ce58:	531f7821 	lsl	w1, w1, #1
    ce5c:	13027c84 	asr	w4, w4, #2
    ce60:	8b21cc01 	add	x1, x0, w1, sxtw #3
    ce64:	9ac42042 	lsl	x2, x2, x4
    ce68:	aa050042 	orr	x2, x2, x5
    ce6c:	f9000402 	str	x2, [x0, #8]
    ce70:	f85f0420 	ldr	x0, [x1], #-16
    ce74:	a9010460 	stp	x0, x1, [x3, #16]
    ce78:	f9000823 	str	x3, [x1, #16]
    ce7c:	f9000c03 	str	x3, [x0, #24]
    ce80:	aa1403e0 	mov	x0, x20
    ce84:	a94153f3 	ldp	x19, x20, [sp, #16]
    ce88:	a8c27bfd 	ldp	x29, x30, [sp], #32
    ce8c:	17fff799 	b	acf0 <__malloc_unlock>
    ce90:	b0000025 	adrp	x5, 11000 <JIS_action_table>
    ce94:	8b010042 	add	x2, x2, x1
    ce98:	911040a5 	add	x5, x5, #0x410
    ce9c:	17ffffbd 	b	cd90 <_free_r+0x90>
    cea0:	b5000986 	cbnz	x6, cfd0 <_free_r+0x2d0>
    cea4:	a9410085 	ldp	x5, x0, [x4, #16]
    cea8:	8b020021 	add	x1, x1, x2
    ceac:	f9000ca0 	str	x0, [x5, #24]
    ceb0:	b2400022 	orr	x2, x1, #0x1
    ceb4:	f9000805 	str	x5, [x0, #16]
    ceb8:	f9000462 	str	x2, [x3, #8]
    cebc:	f8216861 	str	x1, [x3, x1]
    cec0:	17fffff0 	b	ce80 <_free_r+0x180>
    cec4:	8b010041 	add	x1, x2, x1
    cec8:	370000e5 	tbnz	w5, #0, cee4 <_free_r+0x1e4>
    cecc:	f85f0262 	ldur	x2, [x19, #-16]
    ced0:	cb020063 	sub	x3, x3, x2
    ced4:	8b020021 	add	x1, x1, x2
    ced8:	a9410864 	ldp	x4, x2, [x3, #16]
    cedc:	f9000c82 	str	x2, [x4, #24]
    cee0:	f9000844 	str	x4, [x2, #16]
    cee4:	b0000022 	adrp	x2, 11000 <JIS_action_table>
    cee8:	b2400024 	orr	x4, x1, #0x1
    ceec:	f9000464 	str	x4, [x3, #8]
    cef0:	f941fc42 	ldr	x2, [x2, #1016]
    cef4:	f9000803 	str	x3, [x0, #16]
    cef8:	eb01005f 	cmp	x2, x1
    cefc:	54fffc28 	b.hi	ce80 <_free_r+0x180>  // b.pmore
    cf00:	90001fa1 	adrp	x1, 400000 <__sf+0x10>
    cf04:	aa1403e0 	mov	x0, x20
    cf08:	f9412c21 	ldr	x1, [x1, #600]
    cf0c:	97ffff35 	bl	cbe0 <_malloc_trim_r>
    cf10:	17ffffdc 	b	ce80 <_free_r+0x180>
    cf14:	f100503f 	cmp	x1, #0x14
    cf18:	54000129 	b.ls	cf3c <_free_r+0x23c>  // b.plast
    cf1c:	f101503f 	cmp	x1, #0x54
    cf20:	54000328 	b.hi	cf84 <_free_r+0x284>  // b.pmore
    cf24:	d34cfc41 	lsr	x1, x2, #12
    cf28:	1101bc24 	add	w4, w1, #0x6f
    cf2c:	1101b825 	add	w5, w1, #0x6e
    cf30:	531f7884 	lsl	w4, w4, #1
    cf34:	937d7c84 	sbfiz	x4, x4, #3, #32
    cf38:	17ffffaf 	b	cdf4 <_free_r+0xf4>
    cf3c:	11017024 	add	w4, w1, #0x5c
    cf40:	11016c25 	add	w5, w1, #0x5b
    cf44:	531f7884 	lsl	w4, w4, #1
    cf48:	937d7c84 	sbfiz	x4, x4, #3, #32
    cf4c:	17ffffaa 	b	cdf4 <_free_r+0xf4>
    cf50:	f9400406 	ldr	x6, [x0, #8]
    cf54:	13027ca5 	asr	w5, w5, #2
    cf58:	d2800022 	mov	x2, #0x1                   	// #1
    cf5c:	9ac52042 	lsl	x2, x2, x5
    cf60:	aa060042 	orr	x2, x2, x6
    cf64:	f9000402 	str	x2, [x0, #8]
    cf68:	17ffffb0 	b	ce28 <_free_r+0x128>
    cf6c:	a9020c03 	stp	x3, x3, [x0, #32]
    cf70:	b2400041 	orr	x1, x2, #0x1
    cf74:	a9009461 	stp	x1, x5, [x3, #8]
    cf78:	f9000c65 	str	x5, [x3, #24]
    cf7c:	f8226862 	str	x2, [x3, x2]
    cf80:	17ffffc0 	b	ce80 <_free_r+0x180>
    cf84:	f105503f 	cmp	x1, #0x154
    cf88:	540000e8 	b.hi	cfa4 <_free_r+0x2a4>  // b.pmore
    cf8c:	d34ffc41 	lsr	x1, x2, #15
    cf90:	1101e024 	add	w4, w1, #0x78
    cf94:	1101dc25 	add	w5, w1, #0x77
    cf98:	531f7884 	lsl	w4, w4, #1
    cf9c:	937d7c84 	sbfiz	x4, x4, #3, #32
    cfa0:	17ffff95 	b	cdf4 <_free_r+0xf4>
    cfa4:	f115503f 	cmp	x1, #0x554
    cfa8:	540000e8 	b.hi	cfc4 <_free_r+0x2c4>  // b.pmore
    cfac:	d352fc41 	lsr	x1, x2, #18
    cfb0:	1101f424 	add	w4, w1, #0x7d
    cfb4:	1101f025 	add	w5, w1, #0x7c
    cfb8:	531f7884 	lsl	w4, w4, #1
    cfbc:	937d7c84 	sbfiz	x4, x4, #3, #32
    cfc0:	17ffff8d 	b	cdf4 <_free_r+0xf4>
    cfc4:	d280fe04 	mov	x4, #0x7f0                 	// #2032
    cfc8:	52800fc5 	mov	w5, #0x7e                  	// #126
    cfcc:	17ffff8a 	b	cdf4 <_free_r+0xf4>
    cfd0:	b2400040 	orr	x0, x2, #0x1
    cfd4:	f9000460 	str	x0, [x3, #8]
    cfd8:	f9000082 	str	x2, [x4]
    cfdc:	17ffffa9 	b	ce80 <_free_r+0x180>

000000000000cfe0 <_strtol_l.part.0>:
    cfe0:	90000027 	adrp	x7, 10000 <__env_lock>
    cfe4:	aa0003ec 	mov	x12, x0
    cfe8:	aa0103e6 	mov	x6, x1
    cfec:	913bc4e7 	add	x7, x7, #0xef1
    cff0:	aa0603e8 	mov	x8, x6
    cff4:	384014c5 	ldrb	w5, [x6], #1
    cff8:	386548e4 	ldrb	w4, [x7, w5, uxtw]
    cffc:	371fffa4 	tbnz	w4, #3, cff0 <_strtol_l.part.0+0x10>
    d000:	7100b4bf 	cmp	w5, #0x2d
    d004:	54000740 	b.eq	d0ec <_strtol_l.part.0+0x10c>  // b.none
    d008:	92f0000b 	mov	x11, #0x7fffffffffffffff    	// #9223372036854775807
    d00c:	5280000d 	mov	w13, #0x0                   	// #0
    d010:	7100acbf 	cmp	w5, #0x2b
    d014:	54000660 	b.eq	d0e0 <_strtol_l.part.0+0x100>  // b.none
    d018:	721b787f 	tst	w3, #0xffffffef
    d01c:	540000e1 	b.ne	d038 <_strtol_l.part.0+0x58>  // b.any
    d020:	7100c0bf 	cmp	w5, #0x30
    d024:	540007e0 	b.eq	d120 <_strtol_l.part.0+0x140>  // b.none
    d028:	35000083 	cbnz	w3, d038 <_strtol_l.part.0+0x58>
    d02c:	d280014a 	mov	x10, #0xa                   	// #10
    d030:	2a0a03e3 	mov	w3, w10
    d034:	14000002 	b	d03c <_strtol_l.part.0+0x5c>
    d038:	93407c6a 	sxtw	x10, w3
    d03c:	9aca0968 	udiv	x8, x11, x10
    d040:	52800007 	mov	w7, #0x0                   	// #0
    d044:	d2800000 	mov	x0, #0x0                   	// #0
    d048:	1b0aad09 	msub	w9, w8, w10, w11
    d04c:	d503201f 	nop
    d050:	5100c0a4 	sub	w4, w5, #0x30
    d054:	7100249f 	cmp	w4, #0x9
    d058:	540000a9 	b.ls	d06c <_strtol_l.part.0+0x8c>  // b.plast
    d05c:	510104a4 	sub	w4, w5, #0x41
    d060:	7100649f 	cmp	w4, #0x19
    d064:	54000208 	b.hi	d0a4 <_strtol_l.part.0+0xc4>  // b.pmore
    d068:	5100dca4 	sub	w4, w5, #0x37
    d06c:	6b04007f 	cmp	w3, w4
    d070:	5400028d 	b.le	d0c0 <_strtol_l.part.0+0xe0>
    d074:	710000ff 	cmp	w7, #0x0
    d078:	12800007 	mov	w7, #0xffffffff            	// #-1
    d07c:	fa40a100 	ccmp	x8, x0, #0x0, ge	// ge = tcont
    d080:	540000e3 	b.cc	d09c <_strtol_l.part.0+0xbc>  // b.lo, b.ul, b.last
    d084:	eb00011f 	cmp	x8, x0
    d088:	7a440120 	ccmp	w9, w4, #0x0, eq	// eq = none
    d08c:	5400008b 	b.lt	d09c <_strtol_l.part.0+0xbc>  // b.tstop
    d090:	93407c84 	sxtw	x4, w4
    d094:	52800027 	mov	w7, #0x1                   	// #1
    d098:	9b0a1000 	madd	x0, x0, x10, x4
    d09c:	384014c5 	ldrb	w5, [x6], #1
    d0a0:	17ffffec 	b	d050 <_strtol_l.part.0+0x70>
    d0a4:	510184a4 	sub	w4, w5, #0x61
    d0a8:	7100649f 	cmp	w4, #0x19
    d0ac:	540000a8 	b.hi	d0c0 <_strtol_l.part.0+0xe0>  // b.pmore
    d0b0:	51015ca4 	sub	w4, w5, #0x57
    d0b4:	6b04007f 	cmp	w3, w4
    d0b8:	54fffdec 	b.gt	d074 <_strtol_l.part.0+0x94>
    d0bc:	d503201f 	nop
    d0c0:	310004ff 	cmn	w7, #0x1
    d0c4:	540001e0 	b.eq	d100 <_strtol_l.part.0+0x120>  // b.none
    d0c8:	710001bf 	cmp	w13, #0x0
    d0cc:	da800400 	cneg	x0, x0, ne	// ne = any
    d0d0:	b4000062 	cbz	x2, d0dc <_strtol_l.part.0+0xfc>
    d0d4:	35000387 	cbnz	w7, d144 <_strtol_l.part.0+0x164>
    d0d8:	f9000041 	str	x1, [x2]
    d0dc:	d65f03c0 	ret
    d0e0:	394000c5 	ldrb	w5, [x6]
    d0e4:	91000906 	add	x6, x8, #0x2
    d0e8:	17ffffcc 	b	d018 <_strtol_l.part.0+0x38>
    d0ec:	394000c5 	ldrb	w5, [x6]
    d0f0:	d2f0000b 	mov	x11, #0x8000000000000000    	// #-9223372036854775808
    d0f4:	91000906 	add	x6, x8, #0x2
    d0f8:	5280002d 	mov	w13, #0x1                   	// #1
    d0fc:	17ffffc7 	b	d018 <_strtol_l.part.0+0x38>
    d100:	52800440 	mov	w0, #0x22                  	// #34
    d104:	b9000180 	str	w0, [x12]
    d108:	aa0b03e0 	mov	x0, x11
    d10c:	b4fffe82 	cbz	x2, d0dc <_strtol_l.part.0+0xfc>
    d110:	d10004c1 	sub	x1, x6, #0x1
    d114:	aa0b03e0 	mov	x0, x11
    d118:	f9000041 	str	x1, [x2]
    d11c:	17fffff0 	b	d0dc <_strtol_l.part.0+0xfc>
    d120:	394000c0 	ldrb	w0, [x6]
    d124:	121a7800 	and	w0, w0, #0xffffffdf
    d128:	12001c00 	and	w0, w0, #0xff
    d12c:	7101601f 	cmp	w0, #0x58
    d130:	540000e0 	b.eq	d14c <_strtol_l.part.0+0x16c>  // b.none
    d134:	35fff823 	cbnz	w3, d038 <_strtol_l.part.0+0x58>
    d138:	d280010a 	mov	x10, #0x8                   	// #8
    d13c:	2a0a03e3 	mov	w3, w10
    d140:	17ffffbf 	b	d03c <_strtol_l.part.0+0x5c>
    d144:	aa0003eb 	mov	x11, x0
    d148:	17fffff2 	b	d110 <_strtol_l.part.0+0x130>
    d14c:	394004c5 	ldrb	w5, [x6, #1]
    d150:	d280020a 	mov	x10, #0x10                  	// #16
    d154:	910008c6 	add	x6, x6, #0x2
    d158:	2a0a03e3 	mov	w3, w10
    d15c:	17ffffb8 	b	d03c <_strtol_l.part.0+0x5c>

000000000000d160 <_strtol_r>:
    d160:	7100907f 	cmp	w3, #0x24
    d164:	7a419864 	ccmp	w3, #0x1, #0x4, ls	// ls = plast
    d168:	54000040 	b.eq	d170 <_strtol_r+0x10>  // b.none
    d16c:	17ffff9d 	b	cfe0 <_strtol_l.part.0>
    d170:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    d174:	910003fd 	mov	x29, sp
    d178:	97ffd662 	bl	2b00 <__errno>
    d17c:	528002c1 	mov	w1, #0x16                  	// #22
    d180:	b9000001 	str	w1, [x0]
    d184:	d2800000 	mov	x0, #0x0                   	// #0
    d188:	a8c17bfd 	ldp	x29, x30, [sp], #16
    d18c:	d65f03c0 	ret

000000000000d190 <strtol_l>:
    d190:	90000024 	adrp	x4, 11000 <JIS_action_table>
    d194:	7100905f 	cmp	w2, #0x24
    d198:	7a419844 	ccmp	w2, #0x1, #0x4, ls	// ls = plast
    d19c:	f9413c84 	ldr	x4, [x4, #632]
    d1a0:	540000c0 	b.eq	d1b8 <strtol_l+0x28>  // b.none
    d1a4:	2a0203e3 	mov	w3, w2
    d1a8:	aa0103e2 	mov	x2, x1
    d1ac:	aa0003e1 	mov	x1, x0
    d1b0:	aa0403e0 	mov	x0, x4
    d1b4:	17ffff8b 	b	cfe0 <_strtol_l.part.0>
    d1b8:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    d1bc:	910003fd 	mov	x29, sp
    d1c0:	97ffd650 	bl	2b00 <__errno>
    d1c4:	528002c1 	mov	w1, #0x16                  	// #22
    d1c8:	b9000001 	str	w1, [x0]
    d1cc:	d2800000 	mov	x0, #0x0                   	// #0
    d1d0:	a8c17bfd 	ldp	x29, x30, [sp], #16
    d1d4:	d65f03c0 	ret
	...

000000000000d1e0 <strtol>:
    d1e0:	90000024 	adrp	x4, 11000 <JIS_action_table>
    d1e4:	7100905f 	cmp	w2, #0x24
    d1e8:	7a419844 	ccmp	w2, #0x1, #0x4, ls	// ls = plast
    d1ec:	f9413c84 	ldr	x4, [x4, #632]
    d1f0:	540000c0 	b.eq	d208 <strtol+0x28>  // b.none
    d1f4:	2a0203e3 	mov	w3, w2
    d1f8:	aa0103e2 	mov	x2, x1
    d1fc:	aa0003e1 	mov	x1, x0
    d200:	aa0403e0 	mov	x0, x4
    d204:	17ffff77 	b	cfe0 <_strtol_l.part.0>
    d208:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    d20c:	910003fd 	mov	x29, sp
    d210:	97ffd63c 	bl	2b00 <__errno>
    d214:	528002c1 	mov	w1, #0x16                  	// #22
    d218:	b9000001 	str	w1, [x0]
    d21c:	d2800000 	mov	x0, #0x0                   	// #0
    d220:	a8c17bfd 	ldp	x29, x30, [sp], #16
    d224:	d65f03c0 	ret
	...

000000000000d230 <strncasecmp>:
    d230:	aa0003e9 	mov	x9, x0
    d234:	b4000342 	cbz	x2, d29c <strncasecmp+0x6c>
    d238:	f0000007 	adrp	x7, 10000 <__env_lock>
    d23c:	d2800004 	mov	x4, #0x0                   	// #0
    d240:	913bc4e7 	add	x7, x7, #0xef1
    d244:	14000006 	b	d25c <strncasecmp+0x2c>
    d248:	6b000063 	subs	w3, w3, w0
    d24c:	540002c1 	b.ne	d2a4 <strncasecmp+0x74>  // b.any
    d250:	34000240 	cbz	w0, d298 <strncasecmp+0x68>
    d254:	eb04005f 	cmp	x2, x4
    d258:	54000220 	b.eq	d29c <strncasecmp+0x6c>  // b.none
    d25c:	38646923 	ldrb	w3, [x9, x4]
    d260:	38646820 	ldrb	w0, [x1, x4]
    d264:	91000484 	add	x4, x4, #0x1
    d268:	11008068 	add	w8, w3, #0x20
    d26c:	386348e6 	ldrb	w6, [x7, w3, uxtw]
    d270:	386048e5 	ldrb	w5, [x7, w0, uxtw]
    d274:	120004c6 	and	w6, w6, #0x3
    d278:	710004df 	cmp	w6, #0x1
    d27c:	120004a5 	and	w5, w5, #0x3
    d280:	1a830103 	csel	w3, w8, w3, eq	// eq = none
    d284:	710004bf 	cmp	w5, #0x1
    d288:	54fffe01 	b.ne	d248 <strncasecmp+0x18>  // b.any
    d28c:	11008000 	add	w0, w0, #0x20
    d290:	6b000060 	subs	w0, w3, w0
    d294:	54fffe00 	b.eq	d254 <strncasecmp+0x24>  // b.none
    d298:	d65f03c0 	ret
    d29c:	52800000 	mov	w0, #0x0                   	// #0
    d2a0:	d65f03c0 	ret
    d2a4:	2a0303e0 	mov	w0, w3
    d2a8:	d65f03c0 	ret
    d2ac:	00000000 	udf	#0

000000000000d2b0 <_findenv_r>:
    d2b0:	a9bb7bfd 	stp	x29, x30, [sp, #-80]!
    d2b4:	910003fd 	mov	x29, sp
    d2b8:	a90363f7 	stp	x23, x24, [sp, #48]
    d2bc:	90000038 	adrp	x24, 11000 <JIS_action_table>
    d2c0:	aa0003f7 	mov	x23, x0
    d2c4:	a90153f3 	stp	x19, x20, [sp, #16]
    d2c8:	a9025bf5 	stp	x21, x22, [sp, #32]
    d2cc:	aa0103f5 	mov	x21, x1
    d2d0:	aa0203f6 	mov	x22, x2
    d2d4:	94000b4b 	bl	10000 <__env_lock>
    d2d8:	f9476b14 	ldr	x20, [x24, #3792]
    d2dc:	b40003f4 	cbz	x20, d358 <_findenv_r+0xa8>
    d2e0:	394002a3 	ldrb	w3, [x21]
    d2e4:	aa1503f3 	mov	x19, x21
    d2e8:	7100f47f 	cmp	w3, #0x3d
    d2ec:	7a401864 	ccmp	w3, #0x0, #0x4, ne	// ne = any
    d2f0:	540000c0 	b.eq	d308 <_findenv_r+0x58>  // b.none
    d2f4:	d503201f 	nop
    d2f8:	38401e63 	ldrb	w3, [x19, #1]!
    d2fc:	7100f47f 	cmp	w3, #0x3d
    d300:	7a401864 	ccmp	w3, #0x0, #0x4, ne	// ne = any
    d304:	54ffffa1 	b.ne	d2f8 <_findenv_r+0x48>  // b.any
    d308:	7100f47f 	cmp	w3, #0x3d
    d30c:	54000260 	b.eq	d358 <_findenv_r+0xa8>  // b.none
    d310:	f9400280 	ldr	x0, [x20]
    d314:	cb150273 	sub	x19, x19, x21
    d318:	b4000200 	cbz	x0, d358 <_findenv_r+0xa8>
    d31c:	93407e73 	sxtw	x19, w19
    d320:	f90023f9 	str	x25, [sp, #64]
    d324:	d503201f 	nop
    d328:	aa1303e2 	mov	x2, x19
    d32c:	aa1503e1 	mov	x1, x21
    d330:	9400021b 	bl	db9c <strncmp>
    d334:	350000c0 	cbnz	w0, d34c <_findenv_r+0x9c>
    d338:	f9400280 	ldr	x0, [x20]
    d33c:	8b130019 	add	x25, x0, x19
    d340:	38736800 	ldrb	w0, [x0, x19]
    d344:	7100f41f 	cmp	w0, #0x3d
    d348:	54000180 	b.eq	d378 <_findenv_r+0xc8>  // b.none
    d34c:	f8408e80 	ldr	x0, [x20, #8]!
    d350:	b5fffec0 	cbnz	x0, d328 <_findenv_r+0x78>
    d354:	f94023f9 	ldr	x25, [sp, #64]
    d358:	aa1703e0 	mov	x0, x23
    d35c:	94000b2d 	bl	10010 <__env_unlock>
    d360:	a94153f3 	ldp	x19, x20, [sp, #16]
    d364:	d2800000 	mov	x0, #0x0                   	// #0
    d368:	a9425bf5 	ldp	x21, x22, [sp, #32]
    d36c:	a94363f7 	ldp	x23, x24, [sp, #48]
    d370:	a8c57bfd 	ldp	x29, x30, [sp], #80
    d374:	d65f03c0 	ret
    d378:	f9476b01 	ldr	x1, [x24, #3792]
    d37c:	aa1703e0 	mov	x0, x23
    d380:	cb010281 	sub	x1, x20, x1
    d384:	9343fc21 	asr	x1, x1, #3
    d388:	b90002c1 	str	w1, [x22]
    d38c:	94000b21 	bl	10010 <__env_unlock>
    d390:	a94153f3 	ldp	x19, x20, [sp, #16]
    d394:	91000720 	add	x0, x25, #0x1
    d398:	a9425bf5 	ldp	x21, x22, [sp, #32]
    d39c:	a94363f7 	ldp	x23, x24, [sp, #48]
    d3a0:	f94023f9 	ldr	x25, [sp, #64]
    d3a4:	a8c57bfd 	ldp	x29, x30, [sp], #80
    d3a8:	d65f03c0 	ret
    d3ac:	00000000 	udf	#0

000000000000d3b0 <_getenv_r>:
    d3b0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    d3b4:	910003fd 	mov	x29, sp
    d3b8:	910073e2 	add	x2, sp, #0x1c
    d3bc:	97ffffbd 	bl	d2b0 <_findenv_r>
    d3c0:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d3c4:	d65f03c0 	ret
	...

000000000000d3d0 <strncpy>:
    d3d0:	aa010003 	orr	x3, x0, x1
    d3d4:	aa0003e4 	mov	x4, x0
    d3d8:	f240087f 	tst	x3, #0x7
    d3dc:	fa470840 	ccmp	x2, #0x7, #0x0, eq	// eq = none
    d3e0:	54000109 	b.ls	d400 <strncpy+0x30>  // b.plast
    d3e4:	14000011 	b	d428 <strncpy+0x58>
    d3e8:	38401425 	ldrb	w5, [x1], #1
    d3ec:	d1000446 	sub	x6, x2, #0x1
    d3f0:	38001465 	strb	w5, [x3], #1
    d3f4:	340000c5 	cbz	w5, d40c <strncpy+0x3c>
    d3f8:	aa0303e4 	mov	x4, x3
    d3fc:	aa0603e2 	mov	x2, x6
    d400:	aa0403e3 	mov	x3, x4
    d404:	b5ffff22 	cbnz	x2, d3e8 <strncpy+0x18>
    d408:	d65f03c0 	ret
    d40c:	8b020084 	add	x4, x4, x2
    d410:	b4ffffc6 	cbz	x6, d408 <strncpy+0x38>
    d414:	d503201f 	nop
    d418:	3800147f 	strb	wzr, [x3], #1
    d41c:	eb04007f 	cmp	x3, x4
    d420:	54ffffc1 	b.ne	d418 <strncpy+0x48>  // b.any
    d424:	d65f03c0 	ret
    d428:	b207dbe6 	mov	x6, #0xfefefefefefefefe    	// #-72340172838076674
    d42c:	f29fdfe6 	movk	x6, #0xfeff
    d430:	14000006 	b	d448 <strncpy+0x78>
    d434:	d1002042 	sub	x2, x2, #0x8
    d438:	f8008485 	str	x5, [x4], #8
    d43c:	91002021 	add	x1, x1, #0x8
    d440:	f1001c5f 	cmp	x2, #0x7
    d444:	54fffde9 	b.ls	d400 <strncpy+0x30>  // b.plast
    d448:	f9400025 	ldr	x5, [x1]
    d44c:	8b0600a3 	add	x3, x5, x6
    d450:	8a250063 	bic	x3, x3, x5
    d454:	f201c07f 	tst	x3, #0x8080808080808080
    d458:	54fffee0 	b.eq	d434 <strncpy+0x64>  // b.none
    d45c:	17ffffe9 	b	d400 <strncpy+0x30>

000000000000d460 <_fstat_r>:
    d460:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    d464:	910003fd 	mov	x29, sp
    d468:	a90153f3 	stp	x19, x20, [sp, #16]
    d46c:	f0001f94 	adrp	x20, 400000 <__sf+0x10>
    d470:	aa0003f3 	mov	x19, x0
    d474:	b9046a9f 	str	wzr, [x20, #1128]
    d478:	2a0103e0 	mov	w0, w1
    d47c:	aa0203e1 	mov	x1, x2
    d480:	97ffcd5c 	bl	9f0 <_fstat>
    d484:	3100041f 	cmn	w0, #0x1
    d488:	54000080 	b.eq	d498 <_fstat_r+0x38>  // b.none
    d48c:	a94153f3 	ldp	x19, x20, [sp, #16]
    d490:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d494:	d65f03c0 	ret
    d498:	b9446a81 	ldr	w1, [x20, #1128]
    d49c:	34ffff81 	cbz	w1, d48c <_fstat_r+0x2c>
    d4a0:	b9000261 	str	w1, [x19]
    d4a4:	a94153f3 	ldp	x19, x20, [sp, #16]
    d4a8:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d4ac:	d65f03c0 	ret

000000000000d4b0 <_init_signal_r>:
    d4b0:	f940a801 	ldr	x1, [x0, #336]
    d4b4:	b4000061 	cbz	x1, d4c0 <_init_signal_r+0x10>
    d4b8:	52800000 	mov	w0, #0x0                   	// #0
    d4bc:	d65f03c0 	ret
    d4c0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    d4c4:	d2802001 	mov	x1, #0x100                 	// #256
    d4c8:	910003fd 	mov	x29, sp
    d4cc:	f9000bf3 	str	x19, [sp, #16]
    d4d0:	aa0003f3 	mov	x19, x0
    d4d4:	97ffede3 	bl	8c60 <_malloc_r>
    d4d8:	f900aa60 	str	x0, [x19, #336]
    d4dc:	b4000140 	cbz	x0, d504 <_init_signal_r+0x54>
    d4e0:	91040001 	add	x1, x0, #0x100
    d4e4:	d503201f 	nop
    d4e8:	f800841f 	str	xzr, [x0], #8
    d4ec:	eb01001f 	cmp	x0, x1
    d4f0:	54ffffc1 	b.ne	d4e8 <_init_signal_r+0x38>  // b.any
    d4f4:	52800000 	mov	w0, #0x0                   	// #0
    d4f8:	f9400bf3 	ldr	x19, [sp, #16]
    d4fc:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d500:	d65f03c0 	ret
    d504:	12800000 	mov	w0, #0xffffffff            	// #-1
    d508:	17fffffc 	b	d4f8 <_init_signal_r+0x48>
    d50c:	00000000 	udf	#0

000000000000d510 <_signal_r>:
    d510:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    d514:	910003fd 	mov	x29, sp
    d518:	a90153f3 	stp	x19, x20, [sp, #16]
    d51c:	93407c33 	sxtw	x19, w1
    d520:	aa0003f4 	mov	x20, x0
    d524:	71007e7f 	cmp	w19, #0x1f
    d528:	54000108 	b.hi	d548 <_signal_r+0x38>  // b.pmore
    d52c:	f940a801 	ldr	x1, [x0, #336]
    d530:	b4000141 	cbz	x1, d558 <_signal_r+0x48>
    d534:	f8737820 	ldr	x0, [x1, x19, lsl #3]
    d538:	f8337822 	str	x2, [x1, x19, lsl #3]
    d53c:	a94153f3 	ldp	x19, x20, [sp, #16]
    d540:	a8c37bfd 	ldp	x29, x30, [sp], #48
    d544:	d65f03c0 	ret
    d548:	528002c0 	mov	w0, #0x16                  	// #22
    d54c:	b9000280 	str	w0, [x20]
    d550:	92800000 	mov	x0, #0xffffffffffffffff    	// #-1
    d554:	17fffffa 	b	d53c <_signal_r+0x2c>
    d558:	d2802001 	mov	x1, #0x100                 	// #256
    d55c:	f90017e2 	str	x2, [sp, #40]
    d560:	97ffedc0 	bl	8c60 <_malloc_r>
    d564:	f900aa80 	str	x0, [x20, #336]
    d568:	f94017e2 	ldr	x2, [sp, #40]
    d56c:	aa0003e1 	mov	x1, x0
    d570:	b4ffff00 	cbz	x0, d550 <_signal_r+0x40>
    d574:	91040003 	add	x3, x0, #0x100
    d578:	f800841f 	str	xzr, [x0], #8
    d57c:	eb03001f 	cmp	x0, x3
    d580:	54ffffc1 	b.ne	d578 <_signal_r+0x68>  // b.any
    d584:	17ffffec 	b	d534 <_signal_r+0x24>
	...

000000000000d590 <_raise_r>:
    d590:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    d594:	910003fd 	mov	x29, sp
    d598:	a90153f3 	stp	x19, x20, [sp, #16]
    d59c:	aa0003f4 	mov	x20, x0
    d5a0:	71007c3f 	cmp	w1, #0x1f
    d5a4:	54000408 	b.hi	d624 <_raise_r+0x94>  // b.pmore
    d5a8:	f940a800 	ldr	x0, [x0, #336]
    d5ac:	2a0103f3 	mov	w19, w1
    d5b0:	b40001e0 	cbz	x0, d5ec <_raise_r+0x5c>
    d5b4:	93407c22 	sxtw	x2, w1
    d5b8:	f8627801 	ldr	x1, [x0, x2, lsl #3]
    d5bc:	b4000181 	cbz	x1, d5ec <_raise_r+0x5c>
    d5c0:	f100043f 	cmp	x1, #0x1
    d5c4:	540000c0 	b.eq	d5dc <_raise_r+0x4c>  // b.none
    d5c8:	b100043f 	cmn	x1, #0x1
    d5cc:	54000200 	b.eq	d60c <_raise_r+0x7c>  // b.none
    d5d0:	f822781f 	str	xzr, [x0, x2, lsl #3]
    d5d4:	2a1303e0 	mov	w0, w19
    d5d8:	d63f0020 	blr	x1
    d5dc:	52800000 	mov	w0, #0x0                   	// #0
    d5e0:	a94153f3 	ldp	x19, x20, [sp, #16]
    d5e4:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d5e8:	d65f03c0 	ret
    d5ec:	aa1403e0 	mov	x0, x20
    d5f0:	94000354 	bl	e340 <_getpid_r>
    d5f4:	2a1303e2 	mov	w2, w19
    d5f8:	2a0003e1 	mov	w1, w0
    d5fc:	aa1403e0 	mov	x0, x20
    d600:	a94153f3 	ldp	x19, x20, [sp, #16]
    d604:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d608:	1400033a 	b	e2f0 <_kill_r>
    d60c:	528002c1 	mov	w1, #0x16                  	// #22
    d610:	b9000281 	str	w1, [x20]
    d614:	a94153f3 	ldp	x19, x20, [sp, #16]
    d618:	52800020 	mov	w0, #0x1                   	// #1
    d61c:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d620:	d65f03c0 	ret
    d624:	528002c1 	mov	w1, #0x16                  	// #22
    d628:	12800000 	mov	w0, #0xffffffff            	// #-1
    d62c:	b9000281 	str	w1, [x20]
    d630:	17ffffec 	b	d5e0 <_raise_r+0x50>
	...

000000000000d640 <__sigtramp_r>:
    d640:	71007c3f 	cmp	w1, #0x1f
    d644:	540005a8 	b.hi	d6f8 <__sigtramp_r+0xb8>  // b.pmore
    d648:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    d64c:	910003fd 	mov	x29, sp
    d650:	a90153f3 	stp	x19, x20, [sp, #16]
    d654:	2a0103f3 	mov	w19, w1
    d658:	aa0003f4 	mov	x20, x0
    d65c:	f940a801 	ldr	x1, [x0, #336]
    d660:	b4000321 	cbz	x1, d6c4 <__sigtramp_r+0x84>
    d664:	f873d822 	ldr	x2, [x1, w19, sxtw #3]
    d668:	8b33cc21 	add	x1, x1, w19, sxtw #3
    d66c:	b4000182 	cbz	x2, d69c <__sigtramp_r+0x5c>
    d670:	b100045f 	cmn	x2, #0x1
    d674:	54000240 	b.eq	d6bc <__sigtramp_r+0x7c>  // b.none
    d678:	f100045f 	cmp	x2, #0x1
    d67c:	54000180 	b.eq	d6ac <__sigtramp_r+0x6c>  // b.none
    d680:	f900003f 	str	xzr, [x1]
    d684:	2a1303e0 	mov	w0, w19
    d688:	d63f0040 	blr	x2
    d68c:	52800000 	mov	w0, #0x0                   	// #0
    d690:	a94153f3 	ldp	x19, x20, [sp, #16]
    d694:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d698:	d65f03c0 	ret
    d69c:	a94153f3 	ldp	x19, x20, [sp, #16]
    d6a0:	52800020 	mov	w0, #0x1                   	// #1
    d6a4:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d6a8:	d65f03c0 	ret
    d6ac:	a94153f3 	ldp	x19, x20, [sp, #16]
    d6b0:	52800060 	mov	w0, #0x3                   	// #3
    d6b4:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d6b8:	d65f03c0 	ret
    d6bc:	52800040 	mov	w0, #0x2                   	// #2
    d6c0:	17fffff4 	b	d690 <__sigtramp_r+0x50>
    d6c4:	d2802001 	mov	x1, #0x100                 	// #256
    d6c8:	97ffed66 	bl	8c60 <_malloc_r>
    d6cc:	f900aa80 	str	x0, [x20, #336]
    d6d0:	aa0003e1 	mov	x1, x0
    d6d4:	b40000e0 	cbz	x0, d6f0 <__sigtramp_r+0xb0>
    d6d8:	91040002 	add	x2, x0, #0x100
    d6dc:	d503201f 	nop
    d6e0:	f800841f 	str	xzr, [x0], #8
    d6e4:	eb00005f 	cmp	x2, x0
    d6e8:	54ffffc1 	b.ne	d6e0 <__sigtramp_r+0xa0>  // b.any
    d6ec:	17ffffde 	b	d664 <__sigtramp_r+0x24>
    d6f0:	12800000 	mov	w0, #0xffffffff            	// #-1
    d6f4:	17ffffe7 	b	d690 <__sigtramp_r+0x50>
    d6f8:	12800000 	mov	w0, #0xffffffff            	// #-1
    d6fc:	d65f03c0 	ret

000000000000d700 <raise>:
    d700:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    d704:	90000021 	adrp	x1, 11000 <JIS_action_table>
    d708:	910003fd 	mov	x29, sp
    d70c:	a90153f3 	stp	x19, x20, [sp, #16]
    d710:	f9413c34 	ldr	x20, [x1, #632]
    d714:	71007c1f 	cmp	w0, #0x1f
    d718:	540003e8 	b.hi	d794 <raise+0x94>  // b.pmore
    d71c:	f940aa82 	ldr	x2, [x20, #336]
    d720:	2a0003f3 	mov	w19, w0
    d724:	b40001c2 	cbz	x2, d75c <raise+0x5c>
    d728:	93407c03 	sxtw	x3, w0
    d72c:	f8637841 	ldr	x1, [x2, x3, lsl #3]
    d730:	b4000161 	cbz	x1, d75c <raise+0x5c>
    d734:	f100043f 	cmp	x1, #0x1
    d738:	540000a0 	b.eq	d74c <raise+0x4c>  // b.none
    d73c:	b100043f 	cmn	x1, #0x1
    d740:	540001e0 	b.eq	d77c <raise+0x7c>  // b.none
    d744:	f823785f 	str	xzr, [x2, x3, lsl #3]
    d748:	d63f0020 	blr	x1
    d74c:	52800000 	mov	w0, #0x0                   	// #0
    d750:	a94153f3 	ldp	x19, x20, [sp, #16]
    d754:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d758:	d65f03c0 	ret
    d75c:	aa1403e0 	mov	x0, x20
    d760:	940002f8 	bl	e340 <_getpid_r>
    d764:	2a1303e2 	mov	w2, w19
    d768:	2a0003e1 	mov	w1, w0
    d76c:	aa1403e0 	mov	x0, x20
    d770:	a94153f3 	ldp	x19, x20, [sp, #16]
    d774:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d778:	140002de 	b	e2f0 <_kill_r>
    d77c:	528002c1 	mov	w1, #0x16                  	// #22
    d780:	b9000281 	str	w1, [x20]
    d784:	a94153f3 	ldp	x19, x20, [sp, #16]
    d788:	52800020 	mov	w0, #0x1                   	// #1
    d78c:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d790:	d65f03c0 	ret
    d794:	528002c1 	mov	w1, #0x16                  	// #22
    d798:	12800000 	mov	w0, #0xffffffff            	// #-1
    d79c:	b9000281 	str	w1, [x20]
    d7a0:	17ffffec 	b	d750 <raise+0x50>
	...

000000000000d7b0 <signal>:
    d7b0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    d7b4:	90000022 	adrp	x2, 11000 <JIS_action_table>
    d7b8:	910003fd 	mov	x29, sp
    d7bc:	a90153f3 	stp	x19, x20, [sp, #16]
    d7c0:	93407c13 	sxtw	x19, w0
    d7c4:	f90013f5 	str	x21, [sp, #32]
    d7c8:	f9413c55 	ldr	x21, [x2, #632]
    d7cc:	71007e7f 	cmp	w19, #0x1f
    d7d0:	54000148 	b.hi	d7f8 <signal+0x48>  // b.pmore
    d7d4:	aa0103f4 	mov	x20, x1
    d7d8:	f940aaa1 	ldr	x1, [x21, #336]
    d7dc:	b4000161 	cbz	x1, d808 <signal+0x58>
    d7e0:	f8737820 	ldr	x0, [x1, x19, lsl #3]
    d7e4:	f8337834 	str	x20, [x1, x19, lsl #3]
    d7e8:	a94153f3 	ldp	x19, x20, [sp, #16]
    d7ec:	f94013f5 	ldr	x21, [sp, #32]
    d7f0:	a8c37bfd 	ldp	x29, x30, [sp], #48
    d7f4:	d65f03c0 	ret
    d7f8:	528002c0 	mov	w0, #0x16                  	// #22
    d7fc:	b90002a0 	str	w0, [x21]
    d800:	92800000 	mov	x0, #0xffffffffffffffff    	// #-1
    d804:	17fffff9 	b	d7e8 <signal+0x38>
    d808:	d2802001 	mov	x1, #0x100                 	// #256
    d80c:	aa1503e0 	mov	x0, x21
    d810:	97ffed14 	bl	8c60 <_malloc_r>
    d814:	f900aaa0 	str	x0, [x21, #336]
    d818:	aa0003e1 	mov	x1, x0
    d81c:	b4ffff20 	cbz	x0, d800 <signal+0x50>
    d820:	91040002 	add	x2, x0, #0x100
    d824:	d503201f 	nop
    d828:	f800841f 	str	xzr, [x0], #8
    d82c:	eb02001f 	cmp	x0, x2
    d830:	54ffffc1 	b.ne	d828 <signal+0x78>  // b.any
    d834:	17ffffeb 	b	d7e0 <signal+0x30>
	...

000000000000d840 <_init_signal>:
    d840:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    d844:	90000020 	adrp	x0, 11000 <JIS_action_table>
    d848:	910003fd 	mov	x29, sp
    d84c:	f9000bf3 	str	x19, [sp, #16]
    d850:	f9413c13 	ldr	x19, [x0, #632]
    d854:	f940aa60 	ldr	x0, [x19, #336]
    d858:	b40000a0 	cbz	x0, d86c <_init_signal+0x2c>
    d85c:	52800000 	mov	w0, #0x0                   	// #0
    d860:	f9400bf3 	ldr	x19, [sp, #16]
    d864:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d868:	d65f03c0 	ret
    d86c:	aa1303e0 	mov	x0, x19
    d870:	d2802001 	mov	x1, #0x100                 	// #256
    d874:	97ffecfb 	bl	8c60 <_malloc_r>
    d878:	f900aa60 	str	x0, [x19, #336]
    d87c:	b40000e0 	cbz	x0, d898 <_init_signal+0x58>
    d880:	91040001 	add	x1, x0, #0x100
    d884:	d503201f 	nop
    d888:	f800841f 	str	xzr, [x0], #8
    d88c:	eb01001f 	cmp	x0, x1
    d890:	54ffffc1 	b.ne	d888 <_init_signal+0x48>  // b.any
    d894:	17fffff2 	b	d85c <_init_signal+0x1c>
    d898:	12800000 	mov	w0, #0xffffffff            	// #-1
    d89c:	17fffff1 	b	d860 <_init_signal+0x20>

000000000000d8a0 <__sigtramp>:
    d8a0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    d8a4:	90000021 	adrp	x1, 11000 <JIS_action_table>
    d8a8:	910003fd 	mov	x29, sp
    d8ac:	a90153f3 	stp	x19, x20, [sp, #16]
    d8b0:	f9413c34 	ldr	x20, [x1, #632]
    d8b4:	71007c1f 	cmp	w0, #0x1f
    d8b8:	54000508 	b.hi	d958 <__sigtramp+0xb8>  // b.pmore
    d8bc:	2a0003f3 	mov	w19, w0
    d8c0:	f940aa80 	ldr	x0, [x20, #336]
    d8c4:	b4000320 	cbz	x0, d928 <__sigtramp+0x88>
    d8c8:	f873d801 	ldr	x1, [x0, w19, sxtw #3]
    d8cc:	8b33cc00 	add	x0, x0, w19, sxtw #3
    d8d0:	b4000181 	cbz	x1, d900 <__sigtramp+0x60>
    d8d4:	b100043f 	cmn	x1, #0x1
    d8d8:	54000240 	b.eq	d920 <__sigtramp+0x80>  // b.none
    d8dc:	f100043f 	cmp	x1, #0x1
    d8e0:	54000180 	b.eq	d910 <__sigtramp+0x70>  // b.none
    d8e4:	f900001f 	str	xzr, [x0]
    d8e8:	2a1303e0 	mov	w0, w19
    d8ec:	d63f0020 	blr	x1
    d8f0:	52800000 	mov	w0, #0x0                   	// #0
    d8f4:	a94153f3 	ldp	x19, x20, [sp, #16]
    d8f8:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d8fc:	d65f03c0 	ret
    d900:	a94153f3 	ldp	x19, x20, [sp, #16]
    d904:	52800020 	mov	w0, #0x1                   	// #1
    d908:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d90c:	d65f03c0 	ret
    d910:	a94153f3 	ldp	x19, x20, [sp, #16]
    d914:	52800060 	mov	w0, #0x3                   	// #3
    d918:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d91c:	d65f03c0 	ret
    d920:	52800040 	mov	w0, #0x2                   	// #2
    d924:	17fffff4 	b	d8f4 <__sigtramp+0x54>
    d928:	aa1403e0 	mov	x0, x20
    d92c:	d2802001 	mov	x1, #0x100                 	// #256
    d930:	97ffeccc 	bl	8c60 <_malloc_r>
    d934:	f900aa80 	str	x0, [x20, #336]
    d938:	b4000100 	cbz	x0, d958 <__sigtramp+0xb8>
    d93c:	aa0003e1 	mov	x1, x0
    d940:	91040002 	add	x2, x0, #0x100
    d944:	d503201f 	nop
    d948:	f800843f 	str	xzr, [x1], #8
    d94c:	eb01005f 	cmp	x2, x1
    d950:	54ffffc1 	b.ne	d948 <__sigtramp+0xa8>  // b.any
    d954:	17ffffdd 	b	d8c8 <__sigtramp+0x28>
    d958:	12800000 	mov	w0, #0xffffffff            	// #-1
    d95c:	17ffffe6 	b	d8f4 <__sigtramp+0x54>

000000000000d960 <_isatty_r>:
    d960:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    d964:	910003fd 	mov	x29, sp
    d968:	a90153f3 	stp	x19, x20, [sp, #16]
    d96c:	f0001f94 	adrp	x20, 400000 <__sf+0x10>
    d970:	aa0003f3 	mov	x19, x0
    d974:	b9046a9f 	str	wzr, [x20, #1128]
    d978:	2a0103e0 	mov	w0, w1
    d97c:	97ffcc21 	bl	a00 <_isatty>
    d980:	3100041f 	cmn	w0, #0x1
    d984:	54000080 	b.eq	d994 <_isatty_r+0x34>  // b.none
    d988:	a94153f3 	ldp	x19, x20, [sp, #16]
    d98c:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d990:	d65f03c0 	ret
    d994:	b9446a81 	ldr	w1, [x20, #1128]
    d998:	34ffff81 	cbz	w1, d988 <_isatty_r+0x28>
    d99c:	b9000261 	str	w1, [x19]
    d9a0:	a94153f3 	ldp	x19, x20, [sp, #16]
    d9a4:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d9a8:	d65f03c0 	ret
    d9ac:	00000000 	udf	#0

000000000000d9b0 <_lseek_r>:
    d9b0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    d9b4:	910003fd 	mov	x29, sp
    d9b8:	a90153f3 	stp	x19, x20, [sp, #16]
    d9bc:	f0001f94 	adrp	x20, 400000 <__sf+0x10>
    d9c0:	aa0003f3 	mov	x19, x0
    d9c4:	b9046a9f 	str	wzr, [x20, #1128]
    d9c8:	2a0103e0 	mov	w0, w1
    d9cc:	aa0203e1 	mov	x1, x2
    d9d0:	2a0303e2 	mov	w2, w3
    d9d4:	97ffcbfb 	bl	9c0 <_lseek>
    d9d8:	b100041f 	cmn	x0, #0x1
    d9dc:	54000080 	b.eq	d9ec <_lseek_r+0x3c>  // b.none
    d9e0:	a94153f3 	ldp	x19, x20, [sp, #16]
    d9e4:	a8c27bfd 	ldp	x29, x30, [sp], #32
    d9e8:	d65f03c0 	ret
    d9ec:	b9446a81 	ldr	w1, [x20, #1128]
    d9f0:	34ffff81 	cbz	w1, d9e0 <_lseek_r+0x30>
    d9f4:	b9000261 	str	w1, [x19]
    d9f8:	a94153f3 	ldp	x19, x20, [sp, #16]
    d9fc:	a8c27bfd 	ldp	x29, x30, [sp], #32
    da00:	d65f03c0 	ret
	...

000000000000da10 <_read_r>:
    da10:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    da14:	910003fd 	mov	x29, sp
    da18:	a90153f3 	stp	x19, x20, [sp, #16]
    da1c:	f0001f94 	adrp	x20, 400000 <__sf+0x10>
    da20:	aa0003f3 	mov	x19, x0
    da24:	2a0103e0 	mov	w0, w1
    da28:	aa0203e1 	mov	x1, x2
    da2c:	b9046a9f 	str	wzr, [x20, #1128]
    da30:	aa0303e2 	mov	x2, x3
    da34:	97ffcb8b 	bl	860 <_read>
    da38:	93407c01 	sxtw	x1, w0
    da3c:	3100041f 	cmn	w0, #0x1
    da40:	540000a0 	b.eq	da54 <_read_r+0x44>  // b.none
    da44:	a94153f3 	ldp	x19, x20, [sp, #16]
    da48:	aa0103e0 	mov	x0, x1
    da4c:	a8c27bfd 	ldp	x29, x30, [sp], #32
    da50:	d65f03c0 	ret
    da54:	b9446a80 	ldr	w0, [x20, #1128]
    da58:	34ffff60 	cbz	w0, da44 <_read_r+0x34>
    da5c:	b9000260 	str	w0, [x19]
    da60:	aa0103e0 	mov	x0, x1
    da64:	a94153f3 	ldp	x19, x20, [sp, #16]
    da68:	a8c27bfd 	ldp	x29, x30, [sp], #32
    da6c:	d65f03c0 	ret
	...

000000000000da80 <strcmp>:
    da80:	ca010007 	eor	x7, x0, x1
    da84:	b200c3ea 	mov	x10, #0x101010101010101     	// #72340172838076673
    da88:	f24008ff 	tst	x7, #0x7
    da8c:	540003e1 	b.ne	db08 <strcmp+0x88>  // b.any
    da90:	f2400807 	ands	x7, x0, #0x7
    da94:	54000241 	b.ne	dadc <strcmp+0x5c>  // b.any
    da98:	f8408402 	ldr	x2, [x0], #8
    da9c:	f8408423 	ldr	x3, [x1], #8
    daa0:	cb0a0047 	sub	x7, x2, x10
    daa4:	b200d848 	orr	x8, x2, #0x7f7f7f7f7f7f7f7f
    daa8:	ca030045 	eor	x5, x2, x3
    daac:	8a2800e4 	bic	x4, x7, x8
    dab0:	aa0400a6 	orr	x6, x5, x4
    dab4:	b4ffff26 	cbz	x6, da98 <strcmp+0x18>
    dab8:	dac00cc6 	rev	x6, x6
    dabc:	dac00c42 	rev	x2, x2
    dac0:	dac010cb 	clz	x11, x6
    dac4:	dac00c63 	rev	x3, x3
    dac8:	9acb2042 	lsl	x2, x2, x11
    dacc:	9acb2063 	lsl	x3, x3, x11
    dad0:	d378fc42 	lsr	x2, x2, #56
    dad4:	cb43e040 	sub	x0, x2, x3, lsr #56
    dad8:	d65f03c0 	ret
    dadc:	927df000 	and	x0, x0, #0xfffffffffffffff8
    dae0:	927df021 	and	x1, x1, #0xfffffffffffffff8
    dae4:	d37df0e7 	lsl	x7, x7, #3
    dae8:	f8408402 	ldr	x2, [x0], #8
    daec:	cb0703e7 	neg	x7, x7
    daf0:	f8408423 	ldr	x3, [x1], #8
    daf4:	92800008 	mov	x8, #0xffffffffffffffff    	// #-1
    daf8:	9ac72508 	lsr	x8, x8, x7
    dafc:	aa080042 	orr	x2, x2, x8
    db00:	aa080063 	orr	x3, x3, x8
    db04:	17ffffe7 	b	daa0 <strcmp+0x20>
    db08:	f240081f 	tst	x0, #0x7
    db0c:	54000100 	b.eq	db2c <strcmp+0xac>  // b.none
    db10:	38401402 	ldrb	w2, [x0], #1
    db14:	38401423 	ldrb	w3, [x1], #1
    db18:	7100045f 	cmp	w2, #0x1
    db1c:	7a432040 	ccmp	w2, w3, #0x0, cs	// cs = hs, nlast
    db20:	540001e1 	b.ne	db5c <strcmp+0xdc>  // b.any
    db24:	f240081f 	tst	x0, #0x7
    db28:	54ffff41 	b.ne	db10 <strcmp+0x90>  // b.any
    db2c:	927d2027 	and	x7, x1, #0xff8
    db30:	d27d20e7 	eor	x7, x7, #0xff8
    db34:	b4fffee7 	cbz	x7, db10 <strcmp+0x90>
    db38:	f8408402 	ldr	x2, [x0], #8
    db3c:	f8408423 	ldr	x3, [x1], #8
    db40:	cb0a0047 	sub	x7, x2, x10
    db44:	b200d848 	orr	x8, x2, #0x7f7f7f7f7f7f7f7f
    db48:	ca030045 	eor	x5, x2, x3
    db4c:	8a2800e4 	bic	x4, x7, x8
    db50:	aa0400a6 	orr	x6, x5, x4
    db54:	b4fffec6 	cbz	x6, db2c <strcmp+0xac>
    db58:	17ffffd8 	b	dab8 <strcmp+0x38>
    db5c:	cb030040 	sub	x0, x2, x3
    db60:	d65f03c0 	ret
	...
    db80:	d503201f 	nop
    db84:	d503201f 	nop
    db88:	d503201f 	nop
    db8c:	d503201f 	nop
    db90:	d503201f 	nop
    db94:	d503201f 	nop
    db98:	d503201f 	nop

000000000000db9c <strncmp>:
    db9c:	b4000d82 	cbz	x2, dd4c <strncmp+0x1b0>
    dba0:	ca010008 	eor	x8, x0, x1
    dba4:	b200c3eb 	mov	x11, #0x101010101010101     	// #72340172838076673
    dba8:	f240091f 	tst	x8, #0x7
    dbac:	9240080e 	and	x14, x0, #0x7
    dbb0:	54000681 	b.ne	dc80 <strncmp+0xe4>  // b.any
    dbb4:	b500040e 	cbnz	x14, dc34 <strncmp+0x98>
    dbb8:	d100044d 	sub	x13, x2, #0x1
    dbbc:	d343fdad 	lsr	x13, x13, #3
    dbc0:	f8408403 	ldr	x3, [x0], #8
    dbc4:	f8408424 	ldr	x4, [x1], #8
    dbc8:	f10005ad 	subs	x13, x13, #0x1
    dbcc:	cb0b0068 	sub	x8, x3, x11
    dbd0:	b200d869 	orr	x9, x3, #0x7f7f7f7f7f7f7f7f
    dbd4:	ca040066 	eor	x6, x3, x4
    dbd8:	da9f50cf 	csinv	x15, x6, xzr, pl	// pl = nfrst
    dbdc:	ea290105 	bics	x5, x8, x9
    dbe0:	fa4009e0 	ccmp	x15, #0x0, #0x0, eq	// eq = none
    dbe4:	54fffee0 	b.eq	dbc0 <strncmp+0x24>  // b.none
    dbe8:	b6f8012d 	tbz	x13, #63, dc0c <strncmp+0x70>
    dbec:	f2400842 	ands	x2, x2, #0x7
    dbf0:	540000e0 	b.eq	dc0c <strncmp+0x70>  // b.none
    dbf4:	d37df042 	lsl	x2, x2, #3
    dbf8:	9280000e 	mov	x14, #0xffffffffffffffff    	// #-1
    dbfc:	9ac221ce 	lsl	x14, x14, x2
    dc00:	8a2e0063 	bic	x3, x3, x14
    dc04:	8a2e0084 	bic	x4, x4, x14
    dc08:	aa0e00a5 	orr	x5, x5, x14
    dc0c:	aa0500c7 	orr	x7, x6, x5
    dc10:	dac00ce7 	rev	x7, x7
    dc14:	dac00c63 	rev	x3, x3
    dc18:	dac010ec 	clz	x12, x7
    dc1c:	dac00c84 	rev	x4, x4
    dc20:	9acc2063 	lsl	x3, x3, x12
    dc24:	9acc2084 	lsl	x4, x4, x12
    dc28:	d378fc63 	lsr	x3, x3, #56
    dc2c:	cb44e060 	sub	x0, x3, x4, lsr #56
    dc30:	d65f03c0 	ret
    dc34:	927df000 	and	x0, x0, #0xfffffffffffffff8
    dc38:	927df021 	and	x1, x1, #0xfffffffffffffff8
    dc3c:	f8408403 	ldr	x3, [x0], #8
    dc40:	cb0e0fea 	neg	x10, x14, lsl #3
    dc44:	f8408424 	ldr	x4, [x1], #8
    dc48:	92800009 	mov	x9, #0xffffffffffffffff    	// #-1
    dc4c:	d100044d 	sub	x13, x2, #0x1
    dc50:	9aca2529 	lsr	x9, x9, x10
    dc54:	924009aa 	and	x10, x13, #0x7
    dc58:	d343fdad 	lsr	x13, x13, #3
    dc5c:	8b0e0042 	add	x2, x2, x14
    dc60:	8b0e014a 	add	x10, x10, x14
    dc64:	aa090063 	orr	x3, x3, x9
    dc68:	aa090084 	orr	x4, x4, x9
    dc6c:	8b4a0dad 	add	x13, x13, x10, lsr #3
    dc70:	17ffffd6 	b	dbc8 <strncmp+0x2c>
    dc74:	d503201f 	nop
    dc78:	d503201f 	nop
    dc7c:	d503201f 	nop
    dc80:	f100405f 	cmp	x2, #0x10
    dc84:	54000122 	b.cs	dca8 <strncmp+0x10c>  // b.hs, b.nlast
    dc88:	38401403 	ldrb	w3, [x0], #1
    dc8c:	38401424 	ldrb	w4, [x1], #1
    dc90:	f1000442 	subs	x2, x2, #0x1
    dc94:	7a418860 	ccmp	w3, #0x1, #0x0, hi	// hi = pmore
    dc98:	7a442060 	ccmp	w3, w4, #0x0, cs	// cs = hs, nlast
    dc9c:	54ffff60 	b.eq	dc88 <strncmp+0xec>  // b.none
    dca0:	cb040060 	sub	x0, x3, x4
    dca4:	d65f03c0 	ret
    dca8:	d343fc4d 	lsr	x13, x2, #3
    dcac:	b400018e 	cbz	x14, dcdc <strncmp+0x140>
    dcb0:	cb0e03ee 	neg	x14, x14
    dcb4:	924009ce 	and	x14, x14, #0x7
    dcb8:	cb0e0042 	sub	x2, x2, x14
    dcbc:	d343fc4d 	lsr	x13, x2, #3
    dcc0:	38401403 	ldrb	w3, [x0], #1
    dcc4:	38401424 	ldrb	w4, [x1], #1
    dcc8:	7100047f 	cmp	w3, #0x1
    dccc:	7a442060 	ccmp	w3, w4, #0x0, cs	// cs = hs, nlast
    dcd0:	54fffe81 	b.ne	dca0 <strncmp+0x104>  // b.any
    dcd4:	f10005ce 	subs	x14, x14, #0x1
    dcd8:	54ffff48 	b.hi	dcc0 <strncmp+0x124>  // b.pmore
    dcdc:	d280010e 	mov	x14, #0x8                   	// #8
    dce0:	f10005ad 	subs	x13, x13, #0x1
    dce4:	540001c3 	b.cc	dd1c <strncmp+0x180>  // b.lo, b.ul, b.last
    dce8:	927d2029 	and	x9, x1, #0xff8
    dcec:	d27d2129 	eor	x9, x9, #0xff8
    dcf0:	b4fffe89 	cbz	x9, dcc0 <strncmp+0x124>
    dcf4:	f8408403 	ldr	x3, [x0], #8
    dcf8:	f8408424 	ldr	x4, [x1], #8
    dcfc:	cb0b0068 	sub	x8, x3, x11
    dd00:	b200d869 	orr	x9, x3, #0x7f7f7f7f7f7f7f7f
    dd04:	ca040066 	eor	x6, x3, x4
    dd08:	ea290105 	bics	x5, x8, x9
    dd0c:	fa4008c0 	ccmp	x6, #0x0, #0x0, eq	// eq = none
    dd10:	54fff7e1 	b.ne	dc0c <strncmp+0x70>  // b.any
    dd14:	f10005ad 	subs	x13, x13, #0x1
    dd18:	54fffe85 	b.pl	dce8 <strncmp+0x14c>  // b.nfrst
    dd1c:	92400842 	and	x2, x2, #0x7
    dd20:	b4fff762 	cbz	x2, dc0c <strncmp+0x70>
    dd24:	d1002000 	sub	x0, x0, #0x8
    dd28:	d1002021 	sub	x1, x1, #0x8
    dd2c:	f8626803 	ldr	x3, [x0, x2]
    dd30:	f8626824 	ldr	x4, [x1, x2]
    dd34:	cb0b0068 	sub	x8, x3, x11
    dd38:	b200d869 	orr	x9, x3, #0x7f7f7f7f7f7f7f7f
    dd3c:	ca040066 	eor	x6, x3, x4
    dd40:	ea290105 	bics	x5, x8, x9
    dd44:	fa4008c0 	ccmp	x6, #0x0, #0x0, eq	// eq = none
    dd48:	54fff621 	b.ne	dc0c <strncmp+0x70>  // b.any
    dd4c:	d2800000 	mov	x0, #0x0                   	// #0
    dd50:	d65f03c0 	ret
	...

000000000000dd60 <__fputwc>:
    dd60:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
    dd64:	910003fd 	mov	x29, sp
    dd68:	a90153f3 	stp	x19, x20, [sp, #16]
    dd6c:	2a0103f4 	mov	w20, w1
    dd70:	aa0203f3 	mov	x19, x2
    dd74:	f90013f5 	str	x21, [sp, #32]
    dd78:	aa0003f5 	mov	x21, x0
    dd7c:	97fff165 	bl	a310 <__locale_mb_cur_max>
    dd80:	7100041f 	cmp	w0, #0x1
    dd84:	54000081 	b.ne	dd94 <__fputwc+0x34>  // b.any
    dd88:	51000680 	sub	w0, w20, #0x1
    dd8c:	7103f81f 	cmp	w0, #0xfe
    dd90:	540004a9 	b.ls	de24 <__fputwc+0xc4>  // b.plast
    dd94:	9102a263 	add	x3, x19, #0xa8
    dd98:	2a1403e2 	mov	w2, w20
    dd9c:	9100e3e1 	add	x1, sp, #0x38
    dda0:	aa1503e0 	mov	x0, x21
    dda4:	97ffedc3 	bl	94b0 <_wcrtomb_r>
    dda8:	b100041f 	cmn	x0, #0x1
    ddac:	54000400 	b.eq	de2c <__fputwc+0xcc>  // b.none
    ddb0:	b40001c0 	cbz	x0, dde8 <__fputwc+0x88>
    ddb4:	b9400e63 	ldr	w3, [x19, #12]
    ddb8:	3940e3e1 	ldrb	w1, [sp, #56]
    ddbc:	51000463 	sub	w3, w3, #0x1
    ddc0:	b9000e63 	str	w3, [x19, #12]
    ddc4:	36f800a3 	tbz	w3, #31, ddd8 <__fputwc+0x78>
    ddc8:	b9402a64 	ldr	w4, [x19, #40]
    ddcc:	6b04007f 	cmp	w3, w4
    ddd0:	7a4aa824 	ccmp	w1, #0xa, #0x4, ge	// ge = tcont
    ddd4:	54000140 	b.eq	ddfc <__fputwc+0x9c>  // b.none
    ddd8:	f9400263 	ldr	x3, [x19]
    dddc:	91000464 	add	x4, x3, #0x1
    dde0:	f9000264 	str	x4, [x19]
    dde4:	39000061 	strb	w1, [x3]
    dde8:	f94013f5 	ldr	x21, [sp, #32]
    ddec:	2a1403e0 	mov	w0, w20
    ddf0:	a94153f3 	ldp	x19, x20, [sp, #16]
    ddf4:	a8c47bfd 	ldp	x29, x30, [sp], #64
    ddf8:	d65f03c0 	ret
    ddfc:	aa1303e2 	mov	x2, x19
    de00:	aa1503e0 	mov	x0, x21
    de04:	94000167 	bl	e3a0 <__swbuf_r>
    de08:	3100041f 	cmn	w0, #0x1
    de0c:	54fffee1 	b.ne	dde8 <__fputwc+0x88>  // b.any
    de10:	12800000 	mov	w0, #0xffffffff            	// #-1
    de14:	a94153f3 	ldp	x19, x20, [sp, #16]
    de18:	f94013f5 	ldr	x21, [sp, #32]
    de1c:	a8c47bfd 	ldp	x29, x30, [sp], #64
    de20:	d65f03c0 	ret
    de24:	3900e3f4 	strb	w20, [sp, #56]
    de28:	17ffffe3 	b	ddb4 <__fputwc+0x54>
    de2c:	79402260 	ldrh	w0, [x19, #16]
    de30:	321a0000 	orr	w0, w0, #0x40
    de34:	79002260 	strh	w0, [x19, #16]
    de38:	12800000 	mov	w0, #0xffffffff            	// #-1
    de3c:	17fffff6 	b	de14 <__fputwc+0xb4>

000000000000de40 <_fputwc_r>:
    de40:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    de44:	910003fd 	mov	x29, sp
    de48:	a90153f3 	stp	x19, x20, [sp, #16]
    de4c:	aa0003f4 	mov	x20, x0
    de50:	b940b040 	ldr	w0, [x2, #176]
    de54:	aa0203f3 	mov	x19, x2
    de58:	79c02042 	ldrsh	w2, [x2, #16]
    de5c:	37000040 	tbnz	w0, #0, de64 <_fputwc_r+0x24>
    de60:	36480322 	tbz	w2, #9, dec4 <_fputwc_r+0x84>
    de64:	376800c2 	tbnz	w2, #13, de7c <_fputwc_r+0x3c>
    de68:	b940b260 	ldr	w0, [x19, #176]
    de6c:	32130042 	orr	w2, w2, #0x2000
    de70:	79002262 	strh	w2, [x19, #16]
    de74:	32130000 	orr	w0, w0, #0x2000
    de78:	b900b260 	str	w0, [x19, #176]
    de7c:	aa1403e0 	mov	x0, x20
    de80:	aa1303e2 	mov	x2, x19
    de84:	97ffffb7 	bl	dd60 <__fputwc>
    de88:	2a0003f4 	mov	w20, w0
    de8c:	b940b261 	ldr	w1, [x19, #176]
    de90:	37000061 	tbnz	w1, #0, de9c <_fputwc_r+0x5c>
    de94:	79402260 	ldrh	w0, [x19, #16]
    de98:	364800a0 	tbz	w0, #9, deac <_fputwc_r+0x6c>
    de9c:	2a1403e0 	mov	w0, w20
    dea0:	a94153f3 	ldp	x19, x20, [sp, #16]
    dea4:	a8c37bfd 	ldp	x29, x30, [sp], #48
    dea8:	d65f03c0 	ret
    deac:	f9405260 	ldr	x0, [x19, #160]
    deb0:	97ffedf0 	bl	9670 <__retarget_lock_release_recursive>
    deb4:	2a1403e0 	mov	w0, w20
    deb8:	a94153f3 	ldp	x19, x20, [sp, #16]
    debc:	a8c37bfd 	ldp	x29, x30, [sp], #48
    dec0:	d65f03c0 	ret
    dec4:	f9405260 	ldr	x0, [x19, #160]
    dec8:	b9002fe1 	str	w1, [sp, #44]
    decc:	97ffedd9 	bl	9630 <__retarget_lock_acquire_recursive>
    ded0:	79c02262 	ldrsh	w2, [x19, #16]
    ded4:	b9402fe1 	ldr	w1, [sp, #44]
    ded8:	17ffffe3 	b	de64 <_fputwc_r+0x24>
    dedc:	00000000 	udf	#0

000000000000dee0 <fputwc>:
    dee0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    dee4:	90000022 	adrp	x2, 11000 <JIS_action_table>
    dee8:	910003fd 	mov	x29, sp
    deec:	f90013f5 	str	x21, [sp, #32]
    def0:	f9413c55 	ldr	x21, [x2, #632]
    def4:	a90153f3 	stp	x19, x20, [sp, #16]
    def8:	2a0003f4 	mov	w20, w0
    defc:	aa0103f3 	mov	x19, x1
    df00:	b4000075 	cbz	x21, df0c <fputwc+0x2c>
    df04:	f94026a0 	ldr	x0, [x21, #72]
    df08:	b4000480 	cbz	x0, df98 <fputwc+0xb8>
    df0c:	b940b260 	ldr	w0, [x19, #176]
    df10:	79c02262 	ldrsh	w2, [x19, #16]
    df14:	37000040 	tbnz	w0, #0, df1c <fputwc+0x3c>
    df18:	36480382 	tbz	w2, #9, df88 <fputwc+0xa8>
    df1c:	376800c2 	tbnz	w2, #13, df34 <fputwc+0x54>
    df20:	b940b260 	ldr	w0, [x19, #176]
    df24:	32130042 	orr	w2, w2, #0x2000
    df28:	79002262 	strh	w2, [x19, #16]
    df2c:	32130000 	orr	w0, w0, #0x2000
    df30:	b900b260 	str	w0, [x19, #176]
    df34:	2a1403e1 	mov	w1, w20
    df38:	aa1503e0 	mov	x0, x21
    df3c:	aa1303e2 	mov	x2, x19
    df40:	97ffff88 	bl	dd60 <__fputwc>
    df44:	b940b261 	ldr	w1, [x19, #176]
    df48:	2a0003f4 	mov	w20, w0
    df4c:	37000061 	tbnz	w1, #0, df58 <fputwc+0x78>
    df50:	79402260 	ldrh	w0, [x19, #16]
    df54:	364800c0 	tbz	w0, #9, df6c <fputwc+0x8c>
    df58:	f94013f5 	ldr	x21, [sp, #32]
    df5c:	2a1403e0 	mov	w0, w20
    df60:	a94153f3 	ldp	x19, x20, [sp, #16]
    df64:	a8c37bfd 	ldp	x29, x30, [sp], #48
    df68:	d65f03c0 	ret
    df6c:	f9405260 	ldr	x0, [x19, #160]
    df70:	97ffedc0 	bl	9670 <__retarget_lock_release_recursive>
    df74:	f94013f5 	ldr	x21, [sp, #32]
    df78:	2a1403e0 	mov	w0, w20
    df7c:	a94153f3 	ldp	x19, x20, [sp, #16]
    df80:	a8c37bfd 	ldp	x29, x30, [sp], #48
    df84:	d65f03c0 	ret
    df88:	f9405260 	ldr	x0, [x19, #160]
    df8c:	97ffeda9 	bl	9630 <__retarget_lock_acquire_recursive>
    df90:	79c02262 	ldrsh	w2, [x19, #16]
    df94:	17ffffe2 	b	df1c <fputwc+0x3c>
    df98:	aa1503e0 	mov	x0, x21
    df9c:	97ffd46d 	bl	3150 <__sinit>
    dfa0:	17ffffdb 	b	df0c <fputwc+0x2c>
	...

000000000000dfb0 <_wctomb_r>:
    dfb0:	90000024 	adrp	x4, 11000 <JIS_action_table>
    dfb4:	f946f084 	ldr	x4, [x4, #3552]
    dfb8:	aa0403f0 	mov	x16, x4
    dfbc:	d61f0200 	br	x16

000000000000dfc0 <__ascii_wctomb>:
    dfc0:	aa0003e3 	mov	x3, x0
    dfc4:	b4000141 	cbz	x1, dfec <__ascii_wctomb+0x2c>
    dfc8:	7103fc5f 	cmp	w2, #0xff
    dfcc:	54000088 	b.hi	dfdc <__ascii_wctomb+0x1c>  // b.pmore
    dfd0:	52800020 	mov	w0, #0x1                   	// #1
    dfd4:	39000022 	strb	w2, [x1]
    dfd8:	d65f03c0 	ret
    dfdc:	52801141 	mov	w1, #0x8a                  	// #138
    dfe0:	12800000 	mov	w0, #0xffffffff            	// #-1
    dfe4:	b9000061 	str	w1, [x3]
    dfe8:	d65f03c0 	ret
    dfec:	52800000 	mov	w0, #0x0                   	// #0
    dff0:	d65f03c0 	ret
	...

000000000000e000 <__utf8_wctomb>:
    e000:	aa0003e3 	mov	x3, x0
    e004:	b40004e1 	cbz	x1, e0a0 <__utf8_wctomb+0xa0>
    e008:	7101fc5f 	cmp	w2, #0x7f
    e00c:	54000349 	b.ls	e074 <__utf8_wctomb+0x74>  // b.plast
    e010:	51020040 	sub	w0, w2, #0x80
    e014:	711dfc1f 	cmp	w0, #0x77f
    e018:	54000349 	b.ls	e080 <__utf8_wctomb+0x80>  // b.plast
    e01c:	51200044 	sub	w4, w2, #0x800
    e020:	529effe0 	mov	w0, #0xf7ff                	// #63487
    e024:	6b00009f 	cmp	w4, w0
    e028:	54000409 	b.ls	e0a8 <__utf8_wctomb+0xa8>  // b.plast
    e02c:	51404044 	sub	w4, w2, #0x10, lsl #12
    e030:	12bffe00 	mov	w0, #0xfffff               	// #1048575
    e034:	6b00009f 	cmp	w4, w0
    e038:	540004e8 	b.hi	e0d4 <__utf8_wctomb+0xd4>  // b.pmore
    e03c:	53127c45 	lsr	w5, w2, #18
    e040:	d34c4444 	ubfx	x4, x2, #12, #6
    e044:	d3462c43 	ubfx	x3, x2, #6, #6
    e048:	12001442 	and	w2, w2, #0x3f
    e04c:	321c6ca5 	orr	w5, w5, #0xfffffff0
    e050:	32196084 	orr	w4, w4, #0xffffff80
    e054:	32196063 	orr	w3, w3, #0xffffff80
    e058:	32196042 	orr	w2, w2, #0xffffff80
    e05c:	52800080 	mov	w0, #0x4                   	// #4
    e060:	39000025 	strb	w5, [x1]
    e064:	39000424 	strb	w4, [x1, #1]
    e068:	39000823 	strb	w3, [x1, #2]
    e06c:	39000c22 	strb	w2, [x1, #3]
    e070:	d65f03c0 	ret
    e074:	52800020 	mov	w0, #0x1                   	// #1
    e078:	39000022 	strb	w2, [x1]
    e07c:	d65f03c0 	ret
    e080:	53067c43 	lsr	w3, w2, #6
    e084:	12001442 	and	w2, w2, #0x3f
    e088:	321a6463 	orr	w3, w3, #0xffffffc0
    e08c:	32196042 	orr	w2, w2, #0xffffff80
    e090:	52800040 	mov	w0, #0x2                   	// #2
    e094:	39000023 	strb	w3, [x1]
    e098:	39000422 	strb	w2, [x1, #1]
    e09c:	d65f03c0 	ret
    e0a0:	52800000 	mov	w0, #0x0                   	// #0
    e0a4:	d65f03c0 	ret
    e0a8:	530c7c44 	lsr	w4, w2, #12
    e0ac:	d3462c43 	ubfx	x3, x2, #6, #6
    e0b0:	12001442 	and	w2, w2, #0x3f
    e0b4:	321b6884 	orr	w4, w4, #0xffffffe0
    e0b8:	32196063 	orr	w3, w3, #0xffffff80
    e0bc:	32196042 	orr	w2, w2, #0xffffff80
    e0c0:	52800060 	mov	w0, #0x3                   	// #3
    e0c4:	39000024 	strb	w4, [x1]
    e0c8:	39000423 	strb	w3, [x1, #1]
    e0cc:	39000822 	strb	w2, [x1, #2]
    e0d0:	d65f03c0 	ret
    e0d4:	52801141 	mov	w1, #0x8a                  	// #138
    e0d8:	12800000 	mov	w0, #0xffffffff            	// #-1
    e0dc:	b9000061 	str	w1, [x3]
    e0e0:	d65f03c0 	ret
	...

000000000000e0f0 <__sjis_wctomb>:
    e0f0:	aa0003e5 	mov	x5, x0
    e0f4:	12001c44 	and	w4, w2, #0xff
    e0f8:	d3483c43 	ubfx	x3, x2, #8, #8
    e0fc:	b4000301 	cbz	x1, e15c <__sjis_wctomb+0x6c>
    e100:	34000283 	cbz	w3, e150 <__sjis_wctomb+0x60>
    e104:	1101fc60 	add	w0, w3, #0x7f
    e108:	11008063 	add	w3, w3, #0x20
    e10c:	12001c00 	and	w0, w0, #0xff
    e110:	12001c63 	and	w3, w3, #0xff
    e114:	7100781f 	cmp	w0, #0x1e
    e118:	7a4f8860 	ccmp	w3, #0xf, #0x0, hi	// hi = pmore
    e11c:	54000248 	b.hi	e164 <__sjis_wctomb+0x74>  // b.pmore
    e120:	51010080 	sub	w0, w4, #0x40
    e124:	51020084 	sub	w4, w4, #0x80
    e128:	12001c00 	and	w0, w0, #0xff
    e12c:	12001c84 	and	w4, w4, #0xff
    e130:	7100f81f 	cmp	w0, #0x3e
    e134:	52800f80 	mov	w0, #0x7c                  	// #124
    e138:	7a408080 	ccmp	w4, w0, #0x0, hi	// hi = pmore
    e13c:	54000148 	b.hi	e164 <__sjis_wctomb+0x74>  // b.pmore
    e140:	5ac00442 	rev16	w2, w2
    e144:	52800040 	mov	w0, #0x2                   	// #2
    e148:	79000022 	strh	w2, [x1]
    e14c:	d65f03c0 	ret
    e150:	52800020 	mov	w0, #0x1                   	// #1
    e154:	39000024 	strb	w4, [x1]
    e158:	d65f03c0 	ret
    e15c:	52800000 	mov	w0, #0x0                   	// #0
    e160:	d65f03c0 	ret
    e164:	52801141 	mov	w1, #0x8a                  	// #138
    e168:	12800000 	mov	w0, #0xffffffff            	// #-1
    e16c:	b90000a1 	str	w1, [x5]
    e170:	d65f03c0 	ret
	...

000000000000e180 <__eucjp_wctomb>:
    e180:	aa0003e4 	mov	x4, x0
    e184:	12001c43 	and	w3, w2, #0xff
    e188:	d3483c45 	ubfx	x5, x2, #8, #8
    e18c:	b40003a1 	cbz	x1, e200 <__eucjp_wctomb+0x80>
    e190:	34000325 	cbz	w5, e1f4 <__eucjp_wctomb+0x74>
    e194:	11017ca0 	add	w0, w5, #0x5f
    e198:	1101c8a6 	add	w6, w5, #0x72
    e19c:	12001c00 	and	w0, w0, #0xff
    e1a0:	12001cc6 	and	w6, w6, #0xff
    e1a4:	7101741f 	cmp	w0, #0x5d
    e1a8:	7a4188c0 	ccmp	w6, #0x1, #0x0, hi	// hi = pmore
    e1ac:	54000368 	b.hi	e218 <__eucjp_wctomb+0x98>  // b.pmore
    e1b0:	11017c66 	add	w6, w3, #0x5f
    e1b4:	12001cc6 	and	w6, w6, #0xff
    e1b8:	710174df 	cmp	w6, #0x5d
    e1bc:	54000269 	b.ls	e208 <__eucjp_wctomb+0x88>  // b.plast
    e1c0:	7101741f 	cmp	w0, #0x5d
    e1c4:	540002a8 	b.hi	e218 <__eucjp_wctomb+0x98>  // b.pmore
    e1c8:	32190063 	orr	w3, w3, #0x80
    e1cc:	11017c60 	add	w0, w3, #0x5f
    e1d0:	12001c00 	and	w0, w0, #0xff
    e1d4:	7101741f 	cmp	w0, #0x5d
    e1d8:	54000208 	b.hi	e218 <__eucjp_wctomb+0x98>  // b.pmore
    e1dc:	12800e02 	mov	w2, #0xffffff8f            	// #-113
    e1e0:	52800060 	mov	w0, #0x3                   	// #3
    e1e4:	39000022 	strb	w2, [x1]
    e1e8:	39000425 	strb	w5, [x1, #1]
    e1ec:	39000823 	strb	w3, [x1, #2]
    e1f0:	d65f03c0 	ret
    e1f4:	52800020 	mov	w0, #0x1                   	// #1
    e1f8:	39000023 	strb	w3, [x1]
    e1fc:	d65f03c0 	ret
    e200:	52800000 	mov	w0, #0x0                   	// #0
    e204:	d65f03c0 	ret
    e208:	5ac00442 	rev16	w2, w2
    e20c:	52800040 	mov	w0, #0x2                   	// #2
    e210:	79000022 	strh	w2, [x1]
    e214:	d65f03c0 	ret
    e218:	52801141 	mov	w1, #0x8a                  	// #138
    e21c:	12800000 	mov	w0, #0xffffffff            	// #-1
    e220:	b9000081 	str	w1, [x4]
    e224:	d65f03c0 	ret
	...

000000000000e230 <__jis_wctomb>:
    e230:	aa0003e6 	mov	x6, x0
    e234:	12001c45 	and	w5, w2, #0xff
    e238:	d3483c44 	ubfx	x4, x2, #8, #8
    e23c:	b40004c1 	cbz	x1, e2d4 <__jis_wctomb+0xa4>
    e240:	34000304 	cbz	w4, e2a0 <__jis_wctomb+0x70>
    e244:	51008484 	sub	w4, w4, #0x21
    e248:	12001c84 	and	w4, w4, #0xff
    e24c:	7101749f 	cmp	w4, #0x5d
    e250:	54000468 	b.hi	e2dc <__jis_wctomb+0xac>  // b.pmore
    e254:	510084a5 	sub	w5, w5, #0x21
    e258:	12001ca5 	and	w5, w5, #0xff
    e25c:	710174bf 	cmp	w5, #0x5d
    e260:	540003e8 	b.hi	e2dc <__jis_wctomb+0xac>  // b.pmore
    e264:	b9400064 	ldr	w4, [x3]
    e268:	52800040 	mov	w0, #0x2                   	// #2
    e26c:	35000144 	cbnz	w4, e294 <__jis_wctomb+0x64>
    e270:	aa0103e4 	mov	x4, x1
    e274:	52800020 	mov	w0, #0x1                   	// #1
    e278:	b9000060 	str	w0, [x3]
    e27c:	52848365 	mov	w5, #0x241b                	// #9243
    e280:	52800843 	mov	w3, #0x42                  	// #66
    e284:	528000a0 	mov	w0, #0x5                   	// #5
    e288:	78003485 	strh	w5, [x4], #3
    e28c:	39000823 	strb	w3, [x1, #2]
    e290:	aa0403e1 	mov	x1, x4
    e294:	5ac00442 	rev16	w2, w2
    e298:	79000022 	strh	w2, [x1]
    e29c:	d65f03c0 	ret
    e2a0:	b9400062 	ldr	w2, [x3]
    e2a4:	52800020 	mov	w0, #0x1                   	// #1
    e2a8:	34000122 	cbz	w2, e2cc <__jis_wctomb+0x9c>
    e2ac:	aa0103e2 	mov	x2, x1
    e2b0:	b900007f 	str	wzr, [x3]
    e2b4:	52850364 	mov	w4, #0x281b                	// #10267
    e2b8:	52800843 	mov	w3, #0x42                  	// #66
    e2bc:	52800080 	mov	w0, #0x4                   	// #4
    e2c0:	78003444 	strh	w4, [x2], #3
    e2c4:	39000823 	strb	w3, [x1, #2]
    e2c8:	aa0203e1 	mov	x1, x2
    e2cc:	39000025 	strb	w5, [x1]
    e2d0:	d65f03c0 	ret
    e2d4:	52800020 	mov	w0, #0x1                   	// #1
    e2d8:	d65f03c0 	ret
    e2dc:	52801141 	mov	w1, #0x8a                  	// #138
    e2e0:	12800000 	mov	w0, #0xffffffff            	// #-1
    e2e4:	b90000c1 	str	w1, [x6]
    e2e8:	d65f03c0 	ret
    e2ec:	00000000 	udf	#0

000000000000e2f0 <_kill_r>:
    e2f0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    e2f4:	910003fd 	mov	x29, sp
    e2f8:	a90153f3 	stp	x19, x20, [sp, #16]
    e2fc:	d0001f94 	adrp	x20, 400000 <__sf+0x10>
    e300:	aa0003f3 	mov	x19, x0
    e304:	b9046a9f 	str	wzr, [x20, #1128]
    e308:	2a0103e0 	mov	w0, w1
    e30c:	2a0203e1 	mov	w1, w2
    e310:	97ffc9d4 	bl	a60 <_kill>
    e314:	3100041f 	cmn	w0, #0x1
    e318:	54000080 	b.eq	e328 <_kill_r+0x38>  // b.none
    e31c:	a94153f3 	ldp	x19, x20, [sp, #16]
    e320:	a8c27bfd 	ldp	x29, x30, [sp], #32
    e324:	d65f03c0 	ret
    e328:	b9446a81 	ldr	w1, [x20, #1128]
    e32c:	34ffff81 	cbz	w1, e31c <_kill_r+0x2c>
    e330:	b9000261 	str	w1, [x19]
    e334:	a94153f3 	ldp	x19, x20, [sp, #16]
    e338:	a8c27bfd 	ldp	x29, x30, [sp], #32
    e33c:	d65f03c0 	ret

000000000000e340 <_getpid_r>:
    e340:	17ffc9c4 	b	a50 <_getpid>
	...

000000000000e350 <_sbrk_r>:
    e350:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    e354:	910003fd 	mov	x29, sp
    e358:	a90153f3 	stp	x19, x20, [sp, #16]
    e35c:	d0001f94 	adrp	x20, 400000 <__sf+0x10>
    e360:	aa0003f3 	mov	x19, x0
    e364:	b9046a9f 	str	wzr, [x20, #1128]
    e368:	aa0103e0 	mov	x0, x1
    e36c:	97ffc9ae 	bl	a24 <_sbrk>
    e370:	b100041f 	cmn	x0, #0x1
    e374:	54000080 	b.eq	e384 <_sbrk_r+0x34>  // b.none
    e378:	a94153f3 	ldp	x19, x20, [sp, #16]
    e37c:	a8c27bfd 	ldp	x29, x30, [sp], #32
    e380:	d65f03c0 	ret
    e384:	b9446a81 	ldr	w1, [x20, #1128]
    e388:	34ffff81 	cbz	w1, e378 <_sbrk_r+0x28>
    e38c:	b9000261 	str	w1, [x19]
    e390:	a94153f3 	ldp	x19, x20, [sp, #16]
    e394:	a8c27bfd 	ldp	x29, x30, [sp], #32
    e398:	d65f03c0 	ret
    e39c:	00000000 	udf	#0

000000000000e3a0 <__swbuf_r>:
    e3a0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    e3a4:	910003fd 	mov	x29, sp
    e3a8:	a90153f3 	stp	x19, x20, [sp, #16]
    e3ac:	2a0103f4 	mov	w20, w1
    e3b0:	aa0203f3 	mov	x19, x2
    e3b4:	a9025bf5 	stp	x21, x22, [sp, #32]
    e3b8:	aa0003f5 	mov	x21, x0
    e3bc:	b4000060 	cbz	x0, e3c8 <__swbuf_r+0x28>
    e3c0:	f9402401 	ldr	x1, [x0, #72]
    e3c4:	b4000861 	cbz	x1, e4d0 <__swbuf_r+0x130>
    e3c8:	79c02260 	ldrsh	w0, [x19, #16]
    e3cc:	b9402a61 	ldr	w1, [x19, #40]
    e3d0:	b9000e61 	str	w1, [x19, #12]
    e3d4:	361803e0 	tbz	w0, #3, e450 <__swbuf_r+0xb0>
    e3d8:	f9400e61 	ldr	x1, [x19, #24]
    e3dc:	b40003a1 	cbz	x1, e450 <__swbuf_r+0xb0>
    e3e0:	12001e96 	and	w22, w20, #0xff
    e3e4:	12001e94 	and	w20, w20, #0xff
    e3e8:	36680460 	tbz	w0, #13, e474 <__swbuf_r+0xd4>
    e3ec:	f9400260 	ldr	x0, [x19]
    e3f0:	b9402262 	ldr	w2, [x19, #32]
    e3f4:	cb010001 	sub	x1, x0, x1
    e3f8:	6b01005f 	cmp	w2, w1
    e3fc:	5400050d 	b.le	e49c <__swbuf_r+0xfc>
    e400:	11000421 	add	w1, w1, #0x1
    e404:	b9400e62 	ldr	w2, [x19, #12]
    e408:	91000403 	add	x3, x0, #0x1
    e40c:	f9000263 	str	x3, [x19]
    e410:	51000442 	sub	w2, w2, #0x1
    e414:	b9000e62 	str	w2, [x19, #12]
    e418:	39000016 	strb	w22, [x0]
    e41c:	b9402260 	ldr	w0, [x19, #32]
    e420:	6b01001f 	cmp	w0, w1
    e424:	540004a0 	b.eq	e4b8 <__swbuf_r+0x118>  // b.none
    e428:	71002a9f 	cmp	w20, #0xa
    e42c:	79402260 	ldrh	w0, [x19, #16]
    e430:	1a9f17e1 	cset	w1, eq	// eq = none
    e434:	6a00003f 	tst	w1, w0
    e438:	54000401 	b.ne	e4b8 <__swbuf_r+0x118>  // b.any
    e43c:	a9425bf5 	ldp	x21, x22, [sp, #32]
    e440:	2a1403e0 	mov	w0, w20
    e444:	a94153f3 	ldp	x19, x20, [sp, #16]
    e448:	a8c37bfd 	ldp	x29, x30, [sp], #48
    e44c:	d65f03c0 	ret
    e450:	aa1303e1 	mov	x1, x19
    e454:	aa1503e0 	mov	x0, x21
    e458:	97fff052 	bl	a5a0 <__swsetup_r>
    e45c:	35000360 	cbnz	w0, e4c8 <__swbuf_r+0x128>
    e460:	79c02260 	ldrsh	w0, [x19, #16]
    e464:	12001e96 	and	w22, w20, #0xff
    e468:	f9400e61 	ldr	x1, [x19, #24]
    e46c:	12001e94 	and	w20, w20, #0xff
    e470:	376ffbe0 	tbnz	w0, #13, e3ec <__swbuf_r+0x4c>
    e474:	b940b262 	ldr	w2, [x19, #176]
    e478:	32130000 	orr	w0, w0, #0x2000
    e47c:	79002260 	strh	w0, [x19, #16]
    e480:	12127840 	and	w0, w2, #0xffffdfff
    e484:	b900b260 	str	w0, [x19, #176]
    e488:	f9400260 	ldr	x0, [x19]
    e48c:	b9402262 	ldr	w2, [x19, #32]
    e490:	cb010001 	sub	x1, x0, x1
    e494:	6b01005f 	cmp	w2, w1
    e498:	54fffb4c 	b.gt	e400 <__swbuf_r+0x60>
    e49c:	aa1303e1 	mov	x1, x19
    e4a0:	aa1503e0 	mov	x0, x21
    e4a4:	97fff7bb 	bl	c390 <_fflush_r>
    e4a8:	35000100 	cbnz	w0, e4c8 <__swbuf_r+0x128>
    e4ac:	f9400260 	ldr	x0, [x19]
    e4b0:	52800021 	mov	w1, #0x1                   	// #1
    e4b4:	17ffffd4 	b	e404 <__swbuf_r+0x64>
    e4b8:	aa1303e1 	mov	x1, x19
    e4bc:	aa1503e0 	mov	x0, x21
    e4c0:	97fff7b4 	bl	c390 <_fflush_r>
    e4c4:	34fffbc0 	cbz	w0, e43c <__swbuf_r+0x9c>
    e4c8:	12800014 	mov	w20, #0xffffffff            	// #-1
    e4cc:	17ffffdc 	b	e43c <__swbuf_r+0x9c>
    e4d0:	97ffd320 	bl	3150 <__sinit>
    e4d4:	17ffffbd 	b	e3c8 <__swbuf_r+0x28>
	...

000000000000e4e0 <__swbuf>:
    e4e0:	f0000003 	adrp	x3, 11000 <JIS_action_table>
    e4e4:	aa0103e2 	mov	x2, x1
    e4e8:	2a0003e1 	mov	w1, w0
    e4ec:	f9413c60 	ldr	x0, [x3, #632]
    e4f0:	17ffffac 	b	e3a0 <__swbuf_r>
	...

000000000000e500 <_mbtowc_r>:
    e500:	f0000005 	adrp	x5, 11000 <JIS_action_table>
    e504:	f946f4a5 	ldr	x5, [x5, #3560]
    e508:	aa0503f0 	mov	x16, x5
    e50c:	d61f0200 	br	x16

000000000000e510 <__ascii_mbtowc>:
    e510:	d10043ff 	sub	sp, sp, #0x10
    e514:	f100003f 	cmp	x1, #0x0
    e518:	910033e0 	add	x0, sp, #0xc
    e51c:	9a810001 	csel	x1, x0, x1, eq	// eq = none
    e520:	b4000122 	cbz	x2, e544 <__ascii_mbtowc+0x34>
    e524:	b4000163 	cbz	x3, e550 <__ascii_mbtowc+0x40>
    e528:	39400040 	ldrb	w0, [x2]
    e52c:	b9000020 	str	w0, [x1]
    e530:	39400040 	ldrb	w0, [x2]
    e534:	7100001f 	cmp	w0, #0x0
    e538:	1a9f07e0 	cset	w0, ne	// ne = any
    e53c:	910043ff 	add	sp, sp, #0x10
    e540:	d65f03c0 	ret
    e544:	52800000 	mov	w0, #0x0                   	// #0
    e548:	910043ff 	add	sp, sp, #0x10
    e54c:	d65f03c0 	ret
    e550:	12800020 	mov	w0, #0xfffffffe            	// #-2
    e554:	17fffffa 	b	e53c <__ascii_mbtowc+0x2c>
	...

000000000000e560 <__utf8_mbtowc>:
    e560:	d10043ff 	sub	sp, sp, #0x10
    e564:	f100003f 	cmp	x1, #0x0
    e568:	910033e5 	add	x5, sp, #0xc
    e56c:	9a8100a1 	csel	x1, x5, x1, eq	// eq = none
    e570:	b40004c2 	cbz	x2, e608 <__utf8_mbtowc+0xa8>
    e574:	b4001223 	cbz	x3, e7b8 <__utf8_mbtowc+0x258>
    e578:	b9400087 	ldr	w7, [x4]
    e57c:	aa0003e9 	mov	x9, x0
    e580:	350003a7 	cbnz	w7, e5f4 <__utf8_mbtowc+0x94>
    e584:	39400045 	ldrb	w5, [x2]
    e588:	52800026 	mov	w6, #0x1                   	// #1
    e58c:	340003a5 	cbz	w5, e600 <__utf8_mbtowc+0xa0>
    e590:	7101fcbf 	cmp	w5, #0x7f
    e594:	5400082d 	b.le	e698 <__utf8_mbtowc+0x138>
    e598:	510300a8 	sub	w8, w5, #0xc0
    e59c:	71007d1f 	cmp	w8, #0x1f
    e5a0:	540003a8 	b.hi	e614 <__utf8_mbtowc+0xb4>  // b.pmore
    e5a4:	39001085 	strb	w5, [x4, #4]
    e5a8:	350000a7 	cbnz	w7, e5bc <__utf8_mbtowc+0x5c>
    e5ac:	52800020 	mov	w0, #0x1                   	// #1
    e5b0:	b9000080 	str	w0, [x4]
    e5b4:	f100047f 	cmp	x3, #0x1
    e5b8:	54001000 	b.eq	e7b8 <__utf8_mbtowc+0x258>  // b.none
    e5bc:	3866c842 	ldrb	w2, [x2, w6, sxtw]
    e5c0:	110004c0 	add	w0, w6, #0x1
    e5c4:	51020043 	sub	w3, w2, #0x80
    e5c8:	7100fc7f 	cmp	w3, #0x3f
    e5cc:	54000fe8 	b.hi	e7c8 <__utf8_mbtowc+0x268>  // b.pmore
    e5d0:	710304bf 	cmp	w5, #0xc1
    e5d4:	54000fad 	b.le	e7c8 <__utf8_mbtowc+0x268>
    e5d8:	12001442 	and	w2, w2, #0x3f
    e5dc:	531a10a5 	ubfiz	w5, w5, #6, #5
    e5e0:	b900009f 	str	wzr, [x4]
    e5e4:	2a0200a5 	orr	w5, w5, w2
    e5e8:	b9000025 	str	w5, [x1]
    e5ec:	910043ff 	add	sp, sp, #0x10
    e5f0:	d65f03c0 	ret
    e5f4:	39401085 	ldrb	w5, [x4, #4]
    e5f8:	52800006 	mov	w6, #0x0                   	// #0
    e5fc:	35fffca5 	cbnz	w5, e590 <__utf8_mbtowc+0x30>
    e600:	b900003f 	str	wzr, [x1]
    e604:	b900009f 	str	wzr, [x4]
    e608:	52800000 	mov	w0, #0x0                   	// #0
    e60c:	910043ff 	add	sp, sp, #0x10
    e610:	d65f03c0 	ret
    e614:	510380a0 	sub	w0, w5, #0xe0
    e618:	71003c1f 	cmp	w0, #0xf
    e61c:	54000488 	b.hi	e6ac <__utf8_mbtowc+0x14c>  // b.pmore
    e620:	39001085 	strb	w5, [x4, #4]
    e624:	34000a07 	cbz	w7, e764 <__utf8_mbtowc+0x204>
    e628:	b100047f 	cmn	x3, #0x1
    e62c:	9a830463 	cinc	x3, x3, ne	// ne = any
    e630:	710004ff 	cmp	w7, #0x1
    e634:	54000a00 	b.eq	e774 <__utf8_mbtowc+0x214>  // b.none
    e638:	39401488 	ldrb	w8, [x4, #5]
    e63c:	71027d1f 	cmp	w8, #0x9f
    e640:	52801c00 	mov	w0, #0xe0                  	// #224
    e644:	7a40d0a0 	ccmp	w5, w0, #0x0, le
    e648:	54000c00 	b.eq	e7c8 <__utf8_mbtowc+0x268>  // b.none
    e64c:	51020100 	sub	w0, w8, #0x80
    e650:	7100fc1f 	cmp	w0, #0x3f
    e654:	54000ba8 	b.hi	e7c8 <__utf8_mbtowc+0x268>  // b.pmore
    e658:	39001488 	strb	w8, [x4, #5]
    e65c:	710004ff 	cmp	w7, #0x1
    e660:	54000a20 	b.eq	e7a4 <__utf8_mbtowc+0x244>  // b.none
    e664:	3866c843 	ldrb	w3, [x2, w6, sxtw]
    e668:	110004c0 	add	w0, w6, #0x1
    e66c:	51020062 	sub	w2, w3, #0x80
    e670:	7100fc5f 	cmp	w2, #0x3f
    e674:	54000aa8 	b.hi	e7c8 <__utf8_mbtowc+0x268>  // b.pmore
    e678:	53140ca2 	ubfiz	w2, w5, #12, #4
    e67c:	531a1508 	ubfiz	w8, w8, #6, #6
    e680:	2a080042 	orr	w2, w2, w8
    e684:	12001463 	and	w3, w3, #0x3f
    e688:	b900009f 	str	wzr, [x4]
    e68c:	2a030042 	orr	w2, w2, w3
    e690:	b9000022 	str	w2, [x1]
    e694:	17ffffde 	b	e60c <__utf8_mbtowc+0xac>
    e698:	b900009f 	str	wzr, [x4]
    e69c:	52800020 	mov	w0, #0x1                   	// #1
    e6a0:	b9000025 	str	w5, [x1]
    e6a4:	910043ff 	add	sp, sp, #0x10
    e6a8:	d65f03c0 	ret
    e6ac:	5103c0a0 	sub	w0, w5, #0xf0
    e6b0:	7100101f 	cmp	w0, #0x4
    e6b4:	540008a8 	b.hi	e7c8 <__utf8_mbtowc+0x268>  // b.pmore
    e6b8:	39001085 	strb	w5, [x4, #4]
    e6bc:	34000647 	cbz	w7, e784 <__utf8_mbtowc+0x224>
    e6c0:	b100047f 	cmn	x3, #0x1
    e6c4:	9a830463 	cinc	x3, x3, ne	// ne = any
    e6c8:	710004ff 	cmp	w7, #0x1
    e6cc:	54000640 	b.eq	e794 <__utf8_mbtowc+0x234>  // b.none
    e6d0:	39401488 	ldrb	w8, [x4, #5]
    e6d4:	7103c0bf 	cmp	w5, #0xf0
    e6d8:	54000740 	b.eq	e7c0 <__utf8_mbtowc+0x260>  // b.none
    e6dc:	71023d1f 	cmp	w8, #0x8f
    e6e0:	52801e80 	mov	w0, #0xf4                  	// #244
    e6e4:	7a40c0a0 	ccmp	w5, w0, #0x0, gt
    e6e8:	54000700 	b.eq	e7c8 <__utf8_mbtowc+0x268>  // b.none
    e6ec:	51020100 	sub	w0, w8, #0x80
    e6f0:	7100fc1f 	cmp	w0, #0x3f
    e6f4:	540006a8 	b.hi	e7c8 <__utf8_mbtowc+0x268>  // b.pmore
    e6f8:	39001488 	strb	w8, [x4, #5]
    e6fc:	710004ff 	cmp	w7, #0x1
    e700:	540006c0 	b.eq	e7d8 <__utf8_mbtowc+0x278>  // b.none
    e704:	b9400080 	ldr	w0, [x4]
    e708:	b100047f 	cmn	x3, #0x1
    e70c:	9a830463 	cinc	x3, x3, ne	// ne = any
    e710:	7100081f 	cmp	w0, #0x2
    e714:	540006a0 	b.eq	e7e8 <__utf8_mbtowc+0x288>  // b.none
    e718:	39401887 	ldrb	w7, [x4, #6]
    e71c:	510200e0 	sub	w0, w7, #0x80
    e720:	7100fc1f 	cmp	w0, #0x3f
    e724:	54000528 	b.hi	e7c8 <__utf8_mbtowc+0x268>  // b.pmore
    e728:	3866c843 	ldrb	w3, [x2, w6, sxtw]
    e72c:	110004c0 	add	w0, w6, #0x1
    e730:	51020062 	sub	w2, w3, #0x80
    e734:	7100fc5f 	cmp	w2, #0x3f
    e738:	54000488 	b.hi	e7c8 <__utf8_mbtowc+0x268>  // b.pmore
    e73c:	530e08a2 	ubfiz	w2, w5, #18, #3
    e740:	53141508 	ubfiz	w8, w8, #12, #6
    e744:	531a14e7 	ubfiz	w7, w7, #6, #6
    e748:	12001463 	and	w3, w3, #0x3f
    e74c:	2a080042 	orr	w2, w2, w8
    e750:	2a0300e7 	orr	w7, w7, w3
    e754:	2a070042 	orr	w2, w2, w7
    e758:	b9000022 	str	w2, [x1]
    e75c:	b900009f 	str	wzr, [x4]
    e760:	17ffffab 	b	e60c <__utf8_mbtowc+0xac>
    e764:	52800020 	mov	w0, #0x1                   	// #1
    e768:	b9000080 	str	w0, [x4]
    e76c:	f100047f 	cmp	x3, #0x1
    e770:	54000240 	b.eq	e7b8 <__utf8_mbtowc+0x258>  // b.none
    e774:	3866c848 	ldrb	w8, [x2, w6, sxtw]
    e778:	52800027 	mov	w7, #0x1                   	// #1
    e77c:	0b0700c6 	add	w6, w6, w7
    e780:	17ffffaf 	b	e63c <__utf8_mbtowc+0xdc>
    e784:	52800020 	mov	w0, #0x1                   	// #1
    e788:	b9000080 	str	w0, [x4]
    e78c:	f100047f 	cmp	x3, #0x1
    e790:	54000140 	b.eq	e7b8 <__utf8_mbtowc+0x258>  // b.none
    e794:	3866c848 	ldrb	w8, [x2, w6, sxtw]
    e798:	52800027 	mov	w7, #0x1                   	// #1
    e79c:	0b0700c6 	add	w6, w6, w7
    e7a0:	17ffffcd 	b	e6d4 <__utf8_mbtowc+0x174>
    e7a4:	52800040 	mov	w0, #0x2                   	// #2
    e7a8:	b9000080 	str	w0, [x4]
    e7ac:	f100087f 	cmp	x3, #0x2
    e7b0:	54fff5a1 	b.ne	e664 <__utf8_mbtowc+0x104>  // b.any
    e7b4:	d503201f 	nop
    e7b8:	12800020 	mov	w0, #0xfffffffe            	// #-2
    e7bc:	17ffff94 	b	e60c <__utf8_mbtowc+0xac>
    e7c0:	71023d1f 	cmp	w8, #0x8f
    e7c4:	54fff94c 	b.gt	e6ec <__utf8_mbtowc+0x18c>
    e7c8:	52801141 	mov	w1, #0x8a                  	// #138
    e7cc:	12800000 	mov	w0, #0xffffffff            	// #-1
    e7d0:	b9000121 	str	w1, [x9]
    e7d4:	17ffff8e 	b	e60c <__utf8_mbtowc+0xac>
    e7d8:	52800040 	mov	w0, #0x2                   	// #2
    e7dc:	b9000080 	str	w0, [x4]
    e7e0:	f100087f 	cmp	x3, #0x2
    e7e4:	54fffea0 	b.eq	e7b8 <__utf8_mbtowc+0x258>  // b.none
    e7e8:	3866c847 	ldrb	w7, [x2, w6, sxtw]
    e7ec:	110004c6 	add	w6, w6, #0x1
    e7f0:	510200e0 	sub	w0, w7, #0x80
    e7f4:	7100fc1f 	cmp	w0, #0x3f
    e7f8:	54fffe88 	b.hi	e7c8 <__utf8_mbtowc+0x268>  // b.pmore
    e7fc:	52800060 	mov	w0, #0x3                   	// #3
    e800:	b9000080 	str	w0, [x4]
    e804:	39001887 	strb	w7, [x4, #6]
    e808:	f1000c7f 	cmp	x3, #0x3
    e80c:	54fff8e1 	b.ne	e728 <__utf8_mbtowc+0x1c8>  // b.any
    e810:	12800020 	mov	w0, #0xfffffffe            	// #-2
    e814:	17ffff7e 	b	e60c <__utf8_mbtowc+0xac>
	...

000000000000e820 <__sjis_mbtowc>:
    e820:	d10043ff 	sub	sp, sp, #0x10
    e824:	f100003f 	cmp	x1, #0x0
    e828:	910033e5 	add	x5, sp, #0xc
    e82c:	9a8100a1 	csel	x1, x5, x1, eq	// eq = none
    e830:	b40004c2 	cbz	x2, e8c8 <__sjis_mbtowc+0xa8>
    e834:	b4000503 	cbz	x3, e8d4 <__sjis_mbtowc+0xb4>
    e838:	aa0003e6 	mov	x6, x0
    e83c:	b9400080 	ldr	w0, [x4]
    e840:	39400045 	ldrb	w5, [x2]
    e844:	35000320 	cbnz	w0, e8a8 <__sjis_mbtowc+0x88>
    e848:	510204a7 	sub	w7, w5, #0x81
    e84c:	510380a0 	sub	w0, w5, #0xe0
    e850:	710078ff 	cmp	w7, #0x1e
    e854:	7a4f8800 	ccmp	w0, #0xf, #0x0, hi	// hi = pmore
    e858:	540002c8 	b.hi	e8b0 <__sjis_mbtowc+0x90>  // b.pmore
    e85c:	52800020 	mov	w0, #0x1                   	// #1
    e860:	b9000080 	str	w0, [x4]
    e864:	39001085 	strb	w5, [x4, #4]
    e868:	f100047f 	cmp	x3, #0x1
    e86c:	54000340 	b.eq	e8d4 <__sjis_mbtowc+0xb4>  // b.none
    e870:	39400445 	ldrb	w5, [x2, #1]
    e874:	52800040 	mov	w0, #0x2                   	// #2
    e878:	510100a3 	sub	w3, w5, #0x40
    e87c:	510200a2 	sub	w2, w5, #0x80
    e880:	7100f87f 	cmp	w3, #0x3e
    e884:	52800f83 	mov	w3, #0x7c                  	// #124
    e888:	7a438040 	ccmp	w2, w3, #0x0, hi	// hi = pmore
    e88c:	54000288 	b.hi	e8dc <__sjis_mbtowc+0xbc>  // b.pmore
    e890:	39401082 	ldrb	w2, [x4, #4]
    e894:	0b0220a2 	add	w2, w5, w2, lsl #8
    e898:	b9000022 	str	w2, [x1]
    e89c:	b900009f 	str	wzr, [x4]
    e8a0:	910043ff 	add	sp, sp, #0x10
    e8a4:	d65f03c0 	ret
    e8a8:	7100041f 	cmp	w0, #0x1
    e8ac:	54fffe60 	b.eq	e878 <__sjis_mbtowc+0x58>  // b.none
    e8b0:	b9000025 	str	w5, [x1]
    e8b4:	39400040 	ldrb	w0, [x2]
    e8b8:	7100001f 	cmp	w0, #0x0
    e8bc:	1a9f07e0 	cset	w0, ne	// ne = any
    e8c0:	910043ff 	add	sp, sp, #0x10
    e8c4:	d65f03c0 	ret
    e8c8:	52800000 	mov	w0, #0x0                   	// #0
    e8cc:	910043ff 	add	sp, sp, #0x10
    e8d0:	d65f03c0 	ret
    e8d4:	12800020 	mov	w0, #0xfffffffe            	// #-2
    e8d8:	17fffffa 	b	e8c0 <__sjis_mbtowc+0xa0>
    e8dc:	52801141 	mov	w1, #0x8a                  	// #138
    e8e0:	12800000 	mov	w0, #0xffffffff            	// #-1
    e8e4:	b90000c1 	str	w1, [x6]
    e8e8:	17fffff6 	b	e8c0 <__sjis_mbtowc+0xa0>
    e8ec:	00000000 	udf	#0

000000000000e8f0 <__eucjp_mbtowc>:
    e8f0:	d10043ff 	sub	sp, sp, #0x10
    e8f4:	f100003f 	cmp	x1, #0x0
    e8f8:	910033e6 	add	x6, sp, #0xc
    e8fc:	9a8100c1 	csel	x1, x6, x1, eq	// eq = none
    e900:	b4000782 	cbz	x2, e9f0 <__eucjp_mbtowc+0x100>
    e904:	b40007c3 	cbz	x3, e9fc <__eucjp_mbtowc+0x10c>
    e908:	aa0003e5 	mov	x5, x0
    e90c:	b9400080 	ldr	w0, [x4]
    e910:	39400046 	ldrb	w6, [x2]
    e914:	35000380 	cbnz	w0, e984 <__eucjp_mbtowc+0x94>
    e918:	510284c7 	sub	w7, w6, #0xa1
    e91c:	510238c0 	sub	w0, w6, #0x8e
    e920:	710174ff 	cmp	w7, #0x5d
    e924:	7a418800 	ccmp	w0, #0x1, #0x0, hi	// hi = pmore
    e928:	54000388 	b.hi	e998 <__eucjp_mbtowc+0xa8>  // b.pmore
    e92c:	52800020 	mov	w0, #0x1                   	// #1
    e930:	b9000080 	str	w0, [x4]
    e934:	39001086 	strb	w6, [x4, #4]
    e938:	f100047f 	cmp	x3, #0x1
    e93c:	54000600 	b.eq	e9fc <__eucjp_mbtowc+0x10c>  // b.none
    e940:	39400447 	ldrb	w7, [x2, #1]
    e944:	52800040 	mov	w0, #0x2                   	// #2
    e948:	510284e6 	sub	w6, w7, #0xa1
    e94c:	710174df 	cmp	w6, #0x5d
    e950:	540005a8 	b.hi	ea04 <__eucjp_mbtowc+0x114>  // b.pmore
    e954:	39401086 	ldrb	w6, [x4, #4]
    e958:	71023cdf 	cmp	w6, #0x8f
    e95c:	54000401 	b.ne	e9dc <__eucjp_mbtowc+0xec>  // b.any
    e960:	52800048 	mov	w8, #0x2                   	// #2
    e964:	93407c06 	sxtw	x6, w0
    e968:	b9000088 	str	w8, [x4]
    e96c:	39001487 	strb	w7, [x4, #5]
    e970:	eb0300df 	cmp	x6, x3
    e974:	54000442 	b.cs	e9fc <__eucjp_mbtowc+0x10c>  // b.hs, b.nlast
    e978:	38666847 	ldrb	w7, [x2, x6]
    e97c:	11000400 	add	w0, w0, #0x1
    e980:	1400000d 	b	e9b4 <__eucjp_mbtowc+0xc4>
    e984:	2a0603e7 	mov	w7, w6
    e988:	7100041f 	cmp	w0, #0x1
    e98c:	54fffde0 	b.eq	e948 <__eucjp_mbtowc+0x58>  // b.none
    e990:	7100081f 	cmp	w0, #0x2
    e994:	540000e0 	b.eq	e9b0 <__eucjp_mbtowc+0xc0>  // b.none
    e998:	b9000026 	str	w6, [x1]
    e99c:	39400040 	ldrb	w0, [x2]
    e9a0:	7100001f 	cmp	w0, #0x0
    e9a4:	1a9f07e0 	cset	w0, ne	// ne = any
    e9a8:	910043ff 	add	sp, sp, #0x10
    e9ac:	d65f03c0 	ret
    e9b0:	52800020 	mov	w0, #0x1                   	// #1
    e9b4:	510284e2 	sub	w2, w7, #0xa1
    e9b8:	7101745f 	cmp	w2, #0x5d
    e9bc:	54000248 	b.hi	ea04 <__eucjp_mbtowc+0x114>  // b.pmore
    e9c0:	39401482 	ldrb	w2, [x4, #5]
    e9c4:	120018e7 	and	w7, w7, #0x7f
    e9c8:	0b0220e2 	add	w2, w7, w2, lsl #8
    e9cc:	b9000022 	str	w2, [x1]
    e9d0:	b900009f 	str	wzr, [x4]
    e9d4:	910043ff 	add	sp, sp, #0x10
    e9d8:	d65f03c0 	ret
    e9dc:	0b0620e6 	add	w6, w7, w6, lsl #8
    e9e0:	b9000026 	str	w6, [x1]
    e9e4:	b900009f 	str	wzr, [x4]
    e9e8:	910043ff 	add	sp, sp, #0x10
    e9ec:	d65f03c0 	ret
    e9f0:	52800000 	mov	w0, #0x0                   	// #0
    e9f4:	910043ff 	add	sp, sp, #0x10
    e9f8:	d65f03c0 	ret
    e9fc:	12800020 	mov	w0, #0xfffffffe            	// #-2
    ea00:	17ffffea 	b	e9a8 <__eucjp_mbtowc+0xb8>
    ea04:	52801141 	mov	w1, #0x8a                  	// #138
    ea08:	12800000 	mov	w0, #0xffffffff            	// #-1
    ea0c:	b90000a1 	str	w1, [x5]
    ea10:	17ffffe6 	b	e9a8 <__eucjp_mbtowc+0xb8>
	...

000000000000ea20 <__jis_mbtowc>:
    ea20:	d10043ff 	sub	sp, sp, #0x10
    ea24:	f100003f 	cmp	x1, #0x0
    ea28:	910033e5 	add	x5, sp, #0xc
    ea2c:	9a8100a1 	csel	x1, x5, x1, eq	// eq = none
    ea30:	b4000d62 	cbz	x2, ebdc <__jis_mbtowc+0x1bc>
    ea34:	b4000a03 	cbz	x3, eb74 <__jis_mbtowc+0x154>
    ea38:	39400085 	ldrb	w5, [x4]
    ea3c:	f000000c 	adrp	x12, 11000 <JIS_action_table>
    ea40:	f000000b 	adrp	x11, 11000 <JIS_action_table>
    ea44:	aa0003ed 	mov	x13, x0
    ea48:	9100018c 	add	x12, x12, #0x0
    ea4c:	9101416b 	add	x11, x11, #0x50
    ea50:	aa0203ef 	mov	x15, x2
    ea54:	5280000a 	mov	w10, #0x0                   	// #0
    ea58:	d2800009 	mov	x9, #0x0                   	// #0
    ea5c:	38696847 	ldrb	w7, [x2, x9]
    ea60:	8b09004e 	add	x14, x2, x9
    ea64:	7100a0ff 	cmp	w7, #0x28
    ea68:	54000c20 	b.eq	ebec <__jis_mbtowc+0x1cc>  // b.none
    ea6c:	540004c8 	b.hi	eb04 <__jis_mbtowc+0xe4>  // b.pmore
    ea70:	52800006 	mov	w6, #0x0                   	// #0
    ea74:	71006cff 	cmp	w7, #0x1b
    ea78:	54000080 	b.eq	ea88 <__jis_mbtowc+0x68>  // b.none
    ea7c:	52800026 	mov	w6, #0x1                   	// #1
    ea80:	710090ff 	cmp	w7, #0x24
    ea84:	540007c1 	b.ne	eb7c <__jis_mbtowc+0x15c>  // b.any
    ea88:	937d7ca0 	sbfiz	x0, x5, #3, #32
    ea8c:	8b25c005 	add	x5, x0, w5, sxtw
    ea90:	8b050180 	add	x0, x12, x5
    ea94:	8b050165 	add	x5, x11, x5
    ea98:	3866c808 	ldrb	w8, [x0, w6, sxtw]
    ea9c:	3866c8a5 	ldrb	w5, [x5, w6, sxtw]
    eaa0:	71000d1f 	cmp	w8, #0x3
    eaa4:	540005a0 	b.eq	eb58 <__jis_mbtowc+0x138>  // b.none
    eaa8:	540001c8 	b.hi	eae0 <__jis_mbtowc+0xc0>  // b.pmore
    eaac:	7100051f 	cmp	w8, #0x1
    eab0:	540007e0 	b.eq	ebac <__jis_mbtowc+0x18c>  // b.none
    eab4:	7100091f 	cmp	w8, #0x2
    eab8:	54000861 	b.ne	ebc4 <__jis_mbtowc+0x1a4>  // b.any
    eabc:	52800020 	mov	w0, #0x1                   	// #1
    eac0:	b9000080 	str	w0, [x4]
    eac4:	39401082 	ldrb	w2, [x4, #4]
    eac8:	0b000140 	add	w0, w10, w0
    eacc:	394001c3 	ldrb	w3, [x14]
    ead0:	0b022062 	add	w2, w3, w2, lsl #8
    ead4:	b9000022 	str	w2, [x1]
    ead8:	910043ff 	add	sp, sp, #0x10
    eadc:	d65f03c0 	ret
    eae0:	7100111f 	cmp	w8, #0x4
    eae4:	540003e0 	b.eq	eb60 <__jis_mbtowc+0x140>  // b.none
    eae8:	7100151f 	cmp	w8, #0x5
    eaec:	54000561 	b.ne	eb98 <__jis_mbtowc+0x178>  // b.any
    eaf0:	b900009f 	str	wzr, [x4]
    eaf4:	52800000 	mov	w0, #0x0                   	// #0
    eaf8:	b900003f 	str	wzr, [x1]
    eafc:	910043ff 	add	sp, sp, #0x10
    eb00:	d65f03c0 	ret
    eb04:	52800086 	mov	w6, #0x4                   	// #4
    eb08:	710108ff 	cmp	w7, #0x42
    eb0c:	54fffbe0 	b.eq	ea88 <__jis_mbtowc+0x68>  // b.none
    eb10:	528000a6 	mov	w6, #0x5                   	// #5
    eb14:	710128ff 	cmp	w7, #0x4a
    eb18:	54fffb80 	b.eq	ea88 <__jis_mbtowc+0x68>  // b.none
    eb1c:	52800066 	mov	w6, #0x3                   	// #3
    eb20:	710100ff 	cmp	w7, #0x40
    eb24:	54fffb20 	b.eq	ea88 <__jis_mbtowc+0x68>  // b.none
    eb28:	510084e0 	sub	w0, w7, #0x21
    eb2c:	7101741f 	cmp	w0, #0x5d
    eb30:	1a9f97e6 	cset	w6, hi	// hi = pmore
    eb34:	11001cc6 	add	w6, w6, #0x7
    eb38:	937d7ca0 	sbfiz	x0, x5, #3, #32
    eb3c:	8b25c005 	add	x5, x0, w5, sxtw
    eb40:	8b050180 	add	x0, x12, x5
    eb44:	8b050165 	add	x5, x11, x5
    eb48:	3866c808 	ldrb	w8, [x0, w6, sxtw]
    eb4c:	3866c8a5 	ldrb	w5, [x5, w6, sxtw]
    eb50:	71000d1f 	cmp	w8, #0x3
    eb54:	54fffaa1 	b.ne	eaa8 <__jis_mbtowc+0x88>  // b.any
    eb58:	91000529 	add	x9, x9, #0x1
    eb5c:	8b09004f 	add	x15, x2, x9
    eb60:	11000549 	add	w9, w10, #0x1
    eb64:	aa0903ea 	mov	x10, x9
    eb68:	eb03013f 	cmp	x9, x3
    eb6c:	54fff783 	b.cc	ea5c <__jis_mbtowc+0x3c>  // b.lo, b.ul, b.last
    eb70:	b9000085 	str	w5, [x4]
    eb74:	12800020 	mov	w0, #0xfffffffe            	// #-2
    eb78:	17ffffd8 	b	ead8 <__jis_mbtowc+0xb8>
    eb7c:	528000c6 	mov	w6, #0x6                   	// #6
    eb80:	34fff847 	cbz	w7, ea88 <__jis_mbtowc+0x68>
    eb84:	510084e0 	sub	w0, w7, #0x21
    eb88:	7101741f 	cmp	w0, #0x5d
    eb8c:	1a9f97e6 	cset	w6, hi	// hi = pmore
    eb90:	11001cc6 	add	w6, w6, #0x7
    eb94:	17ffffe9 	b	eb38 <__jis_mbtowc+0x118>
    eb98:	52801141 	mov	w1, #0x8a                  	// #138
    eb9c:	b90001a1 	str	w1, [x13]
    eba0:	12800000 	mov	w0, #0xffffffff            	// #-1
    eba4:	910043ff 	add	sp, sp, #0x10
    eba8:	d65f03c0 	ret
    ebac:	11000549 	add	w9, w10, #0x1
    ebb0:	39001087 	strb	w7, [x4, #4]
    ebb4:	aa0903ea 	mov	x10, x9
    ebb8:	eb03013f 	cmp	x9, x3
    ebbc:	54fff503 	b.cc	ea5c <__jis_mbtowc+0x3c>  // b.lo, b.ul, b.last
    ebc0:	17ffffec 	b	eb70 <__jis_mbtowc+0x150>
    ebc4:	b900009f 	str	wzr, [x4]
    ebc8:	11000540 	add	w0, w10, #0x1
    ebcc:	394001e2 	ldrb	w2, [x15]
    ebd0:	b9000022 	str	w2, [x1]
    ebd4:	910043ff 	add	sp, sp, #0x10
    ebd8:	d65f03c0 	ret
    ebdc:	b900009f 	str	wzr, [x4]
    ebe0:	52800020 	mov	w0, #0x1                   	// #1
    ebe4:	910043ff 	add	sp, sp, #0x10
    ebe8:	d65f03c0 	ret
    ebec:	52800046 	mov	w6, #0x2                   	// #2
    ebf0:	17ffffa6 	b	ea88 <__jis_mbtowc+0x68>
	...

000000000000ec00 <strcasecmp>:
    ec00:	d0000006 	adrp	x6, 10000 <__env_lock>
    ec04:	aa0003e8 	mov	x8, x0
    ec08:	913bc4c6 	add	x6, x6, #0xef1
    ec0c:	d2800003 	mov	x3, #0x0                   	// #0
    ec10:	38636902 	ldrb	w2, [x8, x3]
    ec14:	38636820 	ldrb	w0, [x1, x3]
    ec18:	11008047 	add	w7, w2, #0x20
    ec1c:	386248c5 	ldrb	w5, [x6, w2, uxtw]
    ec20:	386048c4 	ldrb	w4, [x6, w0, uxtw]
    ec24:	120004a5 	and	w5, w5, #0x3
    ec28:	710004bf 	cmp	w5, #0x1
    ec2c:	12000484 	and	w4, w4, #0x3
    ec30:	1a8200e2 	csel	w2, w7, w2, eq	// eq = none
    ec34:	7100049f 	cmp	w4, #0x1
    ec38:	540000c0 	b.eq	ec50 <strcasecmp+0x50>  // b.none
    ec3c:	6b000042 	subs	w2, w2, w0
    ec40:	54000121 	b.ne	ec64 <strcasecmp+0x64>  // b.any
    ec44:	91000463 	add	x3, x3, #0x1
    ec48:	35fffe40 	cbnz	w0, ec10 <strcasecmp+0x10>
    ec4c:	d65f03c0 	ret
    ec50:	11008000 	add	w0, w0, #0x20
    ec54:	91000463 	add	x3, x3, #0x1
    ec58:	6b000040 	subs	w0, w2, w0
    ec5c:	54fffda0 	b.eq	ec10 <strcasecmp+0x10>  // b.none
    ec60:	d65f03c0 	ret
    ec64:	2a0203e0 	mov	w0, w2
    ec68:	d65f03c0 	ret
    ec6c:	00000000 	udf	#0

000000000000ec70 <strcat>:
    ec70:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    ec74:	910003fd 	mov	x29, sp
    ec78:	f9000bf3 	str	x19, [sp, #16]
    ec7c:	aa0003f3 	mov	x19, x0
    ec80:	f240081f 	tst	x0, #0x7
    ec84:	540001c1 	b.ne	ecbc <strcat+0x4c>  // b.any
    ec88:	f9400002 	ldr	x2, [x0]
    ec8c:	b207dbe4 	mov	x4, #0xfefefefefefefefe    	// #-72340172838076674
    ec90:	f29fdfe4 	movk	x4, #0xfeff
    ec94:	8b040043 	add	x3, x2, x4
    ec98:	8a220062 	bic	x2, x3, x2
    ec9c:	f201c05f 	tst	x2, #0x8080808080808080
    eca0:	540000e1 	b.ne	ecbc <strcat+0x4c>  // b.any
    eca4:	d503201f 	nop
    eca8:	f8408c02 	ldr	x2, [x0, #8]!
    ecac:	8b040043 	add	x3, x2, x4
    ecb0:	8a220062 	bic	x2, x3, x2
    ecb4:	f201c05f 	tst	x2, #0x8080808080808080
    ecb8:	54ffff80 	b.eq	eca8 <strcat+0x38>  // b.none
    ecbc:	39400002 	ldrb	w2, [x0]
    ecc0:	34000082 	cbz	w2, ecd0 <strcat+0x60>
    ecc4:	d503201f 	nop
    ecc8:	38401c02 	ldrb	w2, [x0, #1]!
    eccc:	35ffffe2 	cbnz	w2, ecc8 <strcat+0x58>
    ecd0:	97ffcecc 	bl	2800 <strcpy>
    ecd4:	aa1303e0 	mov	x0, x19
    ecd8:	f9400bf3 	ldr	x19, [sp, #16]
    ecdc:	a8c27bfd 	ldp	x29, x30, [sp], #32
    ece0:	d65f03c0 	ret
	...

000000000000ecf0 <_Balloc>:
    ecf0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    ecf4:	910003fd 	mov	x29, sp
    ecf8:	f9403402 	ldr	x2, [x0, #104]
    ecfc:	a90153f3 	stp	x19, x20, [sp, #16]
    ed00:	aa0003f3 	mov	x19, x0
    ed04:	2a0103f4 	mov	w20, w1
    ed08:	b4000142 	cbz	x2, ed30 <_Balloc+0x40>
    ed0c:	93407e81 	sxtw	x1, w20
    ed10:	f8617840 	ldr	x0, [x2, x1, lsl #3]
    ed14:	b40001e0 	cbz	x0, ed50 <_Balloc+0x60>
    ed18:	f9400003 	ldr	x3, [x0]
    ed1c:	f8217843 	str	x3, [x2, x1, lsl #3]
    ed20:	f900081f 	str	xzr, [x0, #16]
    ed24:	a94153f3 	ldp	x19, x20, [sp, #16]
    ed28:	a8c27bfd 	ldp	x29, x30, [sp], #32
    ed2c:	d65f03c0 	ret
    ed30:	d2800822 	mov	x2, #0x41                  	// #65
    ed34:	d2800101 	mov	x1, #0x8                   	// #8
    ed38:	940003fe 	bl	fd30 <_calloc_r>
    ed3c:	f9003660 	str	x0, [x19, #104]
    ed40:	aa0003e2 	mov	x2, x0
    ed44:	b5fffe40 	cbnz	x0, ed0c <_Balloc+0x1c>
    ed48:	d2800000 	mov	x0, #0x0                   	// #0
    ed4c:	17fffff6 	b	ed24 <_Balloc+0x34>
    ed50:	52800021 	mov	w1, #0x1                   	// #1
    ed54:	aa1303e0 	mov	x0, x19
    ed58:	1ad42033 	lsl	w19, w1, w20
    ed5c:	d2800021 	mov	x1, #0x1                   	// #1
    ed60:	93407e62 	sxtw	x2, w19
    ed64:	91001c42 	add	x2, x2, #0x7
    ed68:	d37ef442 	lsl	x2, x2, #2
    ed6c:	940003f1 	bl	fd30 <_calloc_r>
    ed70:	b4fffec0 	cbz	x0, ed48 <_Balloc+0x58>
    ed74:	29014c14 	stp	w20, w19, [x0, #8]
    ed78:	17ffffea 	b	ed20 <_Balloc+0x30>
    ed7c:	00000000 	udf	#0

000000000000ed80 <_Bfree>:
    ed80:	b40000c1 	cbz	x1, ed98 <_Bfree+0x18>
    ed84:	f9403400 	ldr	x0, [x0, #104]
    ed88:	b9800822 	ldrsw	x2, [x1, #8]
    ed8c:	f8627803 	ldr	x3, [x0, x2, lsl #3]
    ed90:	f9000023 	str	x3, [x1]
    ed94:	f8227801 	str	x1, [x0, x2, lsl #3]
    ed98:	d65f03c0 	ret
    ed9c:	00000000 	udf	#0

000000000000eda0 <__multadd>:
    eda0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
    eda4:	91006027 	add	x7, x1, #0x18
    eda8:	d2800005 	mov	x5, #0x0                   	// #0
    edac:	910003fd 	mov	x29, sp
    edb0:	a90153f3 	stp	x19, x20, [sp, #16]
    edb4:	2a0303f3 	mov	w19, w3
    edb8:	b9401434 	ldr	w20, [x1, #20]
    edbc:	a9025bf5 	stp	x21, x22, [sp, #32]
    edc0:	aa0103f5 	mov	x21, x1
    edc4:	aa0003f6 	mov	x22, x0
    edc8:	b86578e4 	ldr	w4, [x7, x5, lsl #2]
    edcc:	12003c83 	and	w3, w4, #0xffff
    edd0:	53107c84 	lsr	w4, w4, #16
    edd4:	1b024c63 	madd	w3, w3, w2, w19
    edd8:	12003c66 	and	w6, w3, #0xffff
    eddc:	53107c63 	lsr	w3, w3, #16
    ede0:	1b020c83 	madd	w3, w4, w2, w3
    ede4:	0b0340c4 	add	w4, w6, w3, lsl #16
    ede8:	b82578e4 	str	w4, [x7, x5, lsl #2]
    edec:	910004a5 	add	x5, x5, #0x1
    edf0:	53107c73 	lsr	w19, w3, #16
    edf4:	6b05029f 	cmp	w20, w5
    edf8:	54fffe8c 	b.gt	edc8 <__multadd+0x28>
    edfc:	34000113 	cbz	w19, ee1c <__multadd+0x7c>
    ee00:	b9400ea0 	ldr	w0, [x21, #12]
    ee04:	6b14001f 	cmp	w0, w20
    ee08:	5400014d 	b.le	ee30 <__multadd+0x90>
    ee0c:	8b34caa0 	add	x0, x21, w20, sxtw #2
    ee10:	11000694 	add	w20, w20, #0x1
    ee14:	b9001813 	str	w19, [x0, #24]
    ee18:	b90016b4 	str	w20, [x21, #20]
    ee1c:	a94153f3 	ldp	x19, x20, [sp, #16]
    ee20:	aa1503e0 	mov	x0, x21
    ee24:	a9425bf5 	ldp	x21, x22, [sp, #32]
    ee28:	a8c47bfd 	ldp	x29, x30, [sp], #64
    ee2c:	d65f03c0 	ret
    ee30:	b9400aa1 	ldr	w1, [x21, #8]
    ee34:	aa1603e0 	mov	x0, x22
    ee38:	f9001bf7 	str	x23, [sp, #48]
    ee3c:	11000421 	add	w1, w1, #0x1
    ee40:	97ffffac 	bl	ecf0 <_Balloc>
    ee44:	aa0003f7 	mov	x23, x0
    ee48:	b4000260 	cbz	x0, ee94 <__multadd+0xf4>
    ee4c:	b98016a2 	ldrsw	x2, [x21, #20]
    ee50:	910042a1 	add	x1, x21, #0x10
    ee54:	91004000 	add	x0, x0, #0x10
    ee58:	91000842 	add	x2, x2, #0x2
    ee5c:	d37ef442 	lsl	x2, x2, #2
    ee60:	97ffee98 	bl	a8c0 <memcpy>
    ee64:	f94036c0 	ldr	x0, [x22, #104]
    ee68:	b9800aa1 	ldrsw	x1, [x21, #8]
    ee6c:	f8617802 	ldr	x2, [x0, x1, lsl #3]
    ee70:	f90002a2 	str	x2, [x21]
    ee74:	f8217815 	str	x21, [x0, x1, lsl #3]
    ee78:	aa1703f5 	mov	x21, x23
    ee7c:	8b34caa0 	add	x0, x21, w20, sxtw #2
    ee80:	11000694 	add	w20, w20, #0x1
    ee84:	f9401bf7 	ldr	x23, [sp, #48]
    ee88:	b9001813 	str	w19, [x0, #24]
    ee8c:	b90016b4 	str	w20, [x21, #20]
    ee90:	17ffffe3 	b	ee1c <__multadd+0x7c>
    ee94:	d0000003 	adrp	x3, 10000 <__env_lock>
    ee98:	f0000000 	adrp	x0, 11000 <JIS_action_table>
    ee9c:	91398063 	add	x3, x3, #0xe60
    eea0:	91026000 	add	x0, x0, #0x98
    eea4:	d2800002 	mov	x2, #0x0                   	// #0
    eea8:	52801741 	mov	w1, #0xba                  	// #186
    eeac:	97ffcf19 	bl	2b10 <__assert_func>

000000000000eeb0 <__s2b>:
    eeb0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
    eeb4:	5291c725 	mov	w5, #0x8e39                	// #36409
    eeb8:	72a71c65 	movk	w5, #0x38e3, lsl #16
    eebc:	910003fd 	mov	x29, sp
    eec0:	a9025bf5 	stp	x21, x22, [sp, #32]
    eec4:	2a0303f5 	mov	w21, w3
    eec8:	11002063 	add	w3, w3, #0x8
    eecc:	a90153f3 	stp	x19, x20, [sp, #16]
    eed0:	2a0203f6 	mov	w22, w2
    eed4:	aa0003f4 	mov	x20, x0
    eed8:	9b257c65 	smull	x5, w3, w5
    eedc:	a90363f7 	stp	x23, x24, [sp, #48]
    eee0:	aa0103f3 	mov	x19, x1
    eee4:	2a0403f7 	mov	w23, w4
    eee8:	9361fca5 	asr	x5, x5, #33
    eeec:	4b837ca2 	sub	w2, w5, w3, asr #31
    eef0:	710026bf 	cmp	w21, #0x9
    eef4:	5400064d 	b.le	efbc <__s2b+0x10c>
    eef8:	52800020 	mov	w0, #0x1                   	// #1
    eefc:	52800001 	mov	w1, #0x0                   	// #0
    ef00:	531f7800 	lsl	w0, w0, #1
    ef04:	11000421 	add	w1, w1, #0x1
    ef08:	6b00005f 	cmp	w2, w0
    ef0c:	54ffffac 	b.gt	ef00 <__s2b+0x50>
    ef10:	aa1403e0 	mov	x0, x20
    ef14:	97ffff77 	bl	ecf0 <_Balloc>
    ef18:	aa0003e1 	mov	x1, x0
    ef1c:	b4000540 	cbz	x0, efc4 <__s2b+0x114>
    ef20:	52800020 	mov	w0, #0x1                   	// #1
    ef24:	2902dc20 	stp	w0, w23, [x1, #20]
    ef28:	710026df 	cmp	w22, #0x9
    ef2c:	540002ac 	b.gt	ef80 <__s2b+0xd0>
    ef30:	91002a73 	add	x19, x19, #0xa
    ef34:	52800136 	mov	w22, #0x9                   	// #9
    ef38:	6b1602bf 	cmp	w21, w22
    ef3c:	5400016d 	b.le	ef68 <__s2b+0xb8>
    ef40:	4b1602b5 	sub	w21, w21, w22
    ef44:	8b150275 	add	x21, x19, x21
    ef48:	38401663 	ldrb	w3, [x19], #1
    ef4c:	aa1403e0 	mov	x0, x20
    ef50:	52800142 	mov	w2, #0xa                   	// #10
    ef54:	5100c063 	sub	w3, w3, #0x30
    ef58:	97ffff92 	bl	eda0 <__multadd>
    ef5c:	aa0003e1 	mov	x1, x0
    ef60:	eb15027f 	cmp	x19, x21
    ef64:	54ffff21 	b.ne	ef48 <__s2b+0x98>  // b.any
    ef68:	a94153f3 	ldp	x19, x20, [sp, #16]
    ef6c:	aa0103e0 	mov	x0, x1
    ef70:	a9425bf5 	ldp	x21, x22, [sp, #32]
    ef74:	a94363f7 	ldp	x23, x24, [sp, #48]
    ef78:	a8c47bfd 	ldp	x29, x30, [sp], #64
    ef7c:	d65f03c0 	ret
    ef80:	91002678 	add	x24, x19, #0x9
    ef84:	8b364273 	add	x19, x19, w22, uxtw
    ef88:	aa1803f7 	mov	x23, x24
    ef8c:	d503201f 	nop
    ef90:	384016e3 	ldrb	w3, [x23], #1
    ef94:	aa1403e0 	mov	x0, x20
    ef98:	52800142 	mov	w2, #0xa                   	// #10
    ef9c:	5100c063 	sub	w3, w3, #0x30
    efa0:	97ffff80 	bl	eda0 <__multadd>
    efa4:	aa0003e1 	mov	x1, x0
    efa8:	eb1302ff 	cmp	x23, x19
    efac:	54ffff21 	b.ne	ef90 <__s2b+0xe0>  // b.any
    efb0:	510022d3 	sub	w19, w22, #0x8
    efb4:	8b130313 	add	x19, x24, x19
    efb8:	17ffffe0 	b	ef38 <__s2b+0x88>
    efbc:	52800001 	mov	w1, #0x0                   	// #0
    efc0:	17ffffd4 	b	ef10 <__s2b+0x60>
    efc4:	d0000003 	adrp	x3, 10000 <__env_lock>
    efc8:	f0000000 	adrp	x0, 11000 <JIS_action_table>
    efcc:	91398063 	add	x3, x3, #0xe60
    efd0:	91026000 	add	x0, x0, #0x98
    efd4:	d2800002 	mov	x2, #0x0                   	// #0
    efd8:	52801a61 	mov	w1, #0xd3                  	// #211
    efdc:	97ffcecd 	bl	2b10 <__assert_func>

000000000000efe0 <__hi0bits>:
    efe0:	2a0003e1 	mov	w1, w0
    efe4:	529fffe2 	mov	w2, #0xffff                	// #65535
    efe8:	52800000 	mov	w0, #0x0                   	// #0
    efec:	6b02003f 	cmp	w1, w2
    eff0:	54000068 	b.hi	effc <__hi0bits+0x1c>  // b.pmore
    eff4:	53103c21 	lsl	w1, w1, #16
    eff8:	52800200 	mov	w0, #0x10                  	// #16
    effc:	12bfe002 	mov	w2, #0xffffff              	// #16777215
    f000:	6b02003f 	cmp	w1, w2
    f004:	54000068 	b.hi	f010 <__hi0bits+0x30>  // b.pmore
    f008:	11002000 	add	w0, w0, #0x8
    f00c:	53185c21 	lsl	w1, w1, #8
    f010:	12be0002 	mov	w2, #0xfffffff             	// #268435455
    f014:	6b02003f 	cmp	w1, w2
    f018:	54000068 	b.hi	f024 <__hi0bits+0x44>  // b.pmore
    f01c:	11001000 	add	w0, w0, #0x4
    f020:	531c6c21 	lsl	w1, w1, #4
    f024:	12b80002 	mov	w2, #0x3fffffff            	// #1073741823
    f028:	6b02003f 	cmp	w1, w2
    f02c:	54000089 	b.ls	f03c <__hi0bits+0x5c>  // b.plast
    f030:	2a2103e1 	mvn	w1, w1
    f034:	0b417c00 	add	w0, w0, w1, lsr #31
    f038:	d65f03c0 	ret
    f03c:	531e7422 	lsl	w2, w1, #2
    f040:	37e800c1 	tbnz	w1, #29, f058 <__hi0bits+0x78>
    f044:	f262005f 	tst	x2, #0x40000000
    f048:	11000c00 	add	w0, w0, #0x3
    f04c:	52800401 	mov	w1, #0x20                  	// #32
    f050:	1a811000 	csel	w0, w0, w1, ne	// ne = any
    f054:	d65f03c0 	ret
    f058:	11000800 	add	w0, w0, #0x2
    f05c:	d65f03c0 	ret

000000000000f060 <__lo0bits>:
    f060:	aa0003e2 	mov	x2, x0
    f064:	52800000 	mov	w0, #0x0                   	// #0
    f068:	b9400041 	ldr	w1, [x2]
    f06c:	f240083f 	tst	x1, #0x7
    f070:	540000e0 	b.eq	f08c <__lo0bits+0x2c>  // b.none
    f074:	370000a1 	tbnz	w1, #0, f088 <__lo0bits+0x28>
    f078:	360803a1 	tbz	w1, #1, f0ec <__lo0bits+0x8c>
    f07c:	53017c21 	lsr	w1, w1, #1
    f080:	52800020 	mov	w0, #0x1                   	// #1
    f084:	b9000041 	str	w1, [x2]
    f088:	d65f03c0 	ret
    f08c:	72003c3f 	tst	w1, #0xffff
    f090:	54000061 	b.ne	f09c <__lo0bits+0x3c>  // b.any
    f094:	53107c21 	lsr	w1, w1, #16
    f098:	52800200 	mov	w0, #0x10                  	// #16
    f09c:	72001c3f 	tst	w1, #0xff
    f0a0:	54000061 	b.ne	f0ac <__lo0bits+0x4c>  // b.any
    f0a4:	11002000 	add	w0, w0, #0x8
    f0a8:	53087c21 	lsr	w1, w1, #8
    f0ac:	f2400c3f 	tst	x1, #0xf
    f0b0:	54000061 	b.ne	f0bc <__lo0bits+0x5c>  // b.any
    f0b4:	11001000 	add	w0, w0, #0x4
    f0b8:	53047c21 	lsr	w1, w1, #4
    f0bc:	f240043f 	tst	x1, #0x3
    f0c0:	54000061 	b.ne	f0cc <__lo0bits+0x6c>  // b.any
    f0c4:	11000800 	add	w0, w0, #0x2
    f0c8:	53027c21 	lsr	w1, w1, #2
    f0cc:	37000081 	tbnz	w1, #0, f0dc <__lo0bits+0x7c>
    f0d0:	11000400 	add	w0, w0, #0x1
    f0d4:	53017c21 	lsr	w1, w1, #1
    f0d8:	34000061 	cbz	w1, f0e4 <__lo0bits+0x84>
    f0dc:	b9000041 	str	w1, [x2]
    f0e0:	d65f03c0 	ret
    f0e4:	52800400 	mov	w0, #0x20                  	// #32
    f0e8:	d65f03c0 	ret
    f0ec:	53027c21 	lsr	w1, w1, #2
    f0f0:	52800040 	mov	w0, #0x2                   	// #2
    f0f4:	b9000041 	str	w1, [x2]
    f0f8:	d65f03c0 	ret
    f0fc:	00000000 	udf	#0

000000000000f100 <__i2b>:
    f100:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    f104:	910003fd 	mov	x29, sp
    f108:	f9403402 	ldr	x2, [x0, #104]
    f10c:	a90153f3 	stp	x19, x20, [sp, #16]
    f110:	aa0003f3 	mov	x19, x0
    f114:	2a0103f4 	mov	w20, w1
    f118:	b4000182 	cbz	x2, f148 <__i2b+0x48>
    f11c:	f9400440 	ldr	x0, [x2, #8]
    f120:	b40002e0 	cbz	x0, f17c <__i2b+0x7c>
    f124:	f9400001 	ldr	x1, [x0]
    f128:	f9000441 	str	x1, [x2, #8]
    f12c:	d0000001 	adrp	x1, 11000 <JIS_action_table>
    f130:	b9001814 	str	w20, [x0, #24]
    f134:	a94153f3 	ldp	x19, x20, [sp, #16]
    f138:	fd412020 	ldr	d0, [x1, #576]
    f13c:	fd000800 	str	d0, [x0, #16]
    f140:	a8c27bfd 	ldp	x29, x30, [sp], #32
    f144:	d65f03c0 	ret
    f148:	d2800822 	mov	x2, #0x41                  	// #65
    f14c:	d2800101 	mov	x1, #0x8                   	// #8
    f150:	940002f8 	bl	fd30 <_calloc_r>
    f154:	f9003660 	str	x0, [x19, #104]
    f158:	aa0003e2 	mov	x2, x0
    f15c:	b5fffe00 	cbnz	x0, f11c <__i2b+0x1c>
    f160:	b0000003 	adrp	x3, 10000 <__env_lock>
    f164:	d0000000 	adrp	x0, 11000 <JIS_action_table>
    f168:	91398063 	add	x3, x3, #0xe60
    f16c:	91026000 	add	x0, x0, #0x98
    f170:	d2800002 	mov	x2, #0x0                   	// #0
    f174:	528028a1 	mov	w1, #0x145                 	// #325
    f178:	97ffce66 	bl	2b10 <__assert_func>
    f17c:	aa1303e0 	mov	x0, x19
    f180:	d2800482 	mov	x2, #0x24                  	// #36
    f184:	d2800021 	mov	x1, #0x1                   	// #1
    f188:	940002ea 	bl	fd30 <_calloc_r>
    f18c:	b4fffea0 	cbz	x0, f160 <__i2b+0x60>
    f190:	d0000001 	adrp	x1, 11000 <JIS_action_table>
    f194:	b9001814 	str	w20, [x0, #24]
    f198:	a94153f3 	ldp	x19, x20, [sp, #16]
    f19c:	fd411c20 	ldr	d0, [x1, #568]
    f1a0:	d0000001 	adrp	x1, 11000 <JIS_action_table>
    f1a4:	fd000400 	str	d0, [x0, #8]
    f1a8:	fd412020 	ldr	d0, [x1, #576]
    f1ac:	fd000800 	str	d0, [x0, #16]
    f1b0:	a8c27bfd 	ldp	x29, x30, [sp], #32
    f1b4:	d65f03c0 	ret
	...

000000000000f1c0 <__multiply>:
    f1c0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
    f1c4:	910003fd 	mov	x29, sp
    f1c8:	a9025bf5 	stp	x21, x22, [sp, #32]
    f1cc:	aa0103f5 	mov	x21, x1
    f1d0:	b9401436 	ldr	w22, [x1, #20]
    f1d4:	f9001bf7 	str	x23, [sp, #48]
    f1d8:	b9401457 	ldr	w23, [x2, #20]
    f1dc:	a90153f3 	stp	x19, x20, [sp, #16]
    f1e0:	aa0203f4 	mov	x20, x2
    f1e4:	6b1702df 	cmp	w22, w23
    f1e8:	540000eb 	b.lt	f204 <__multiply+0x44>  // b.tstop
    f1ec:	2a1703e2 	mov	w2, w23
    f1f0:	aa1403e1 	mov	x1, x20
    f1f4:	2a1603f7 	mov	w23, w22
    f1f8:	aa1503f4 	mov	x20, x21
    f1fc:	2a0203f6 	mov	w22, w2
    f200:	aa0103f5 	mov	x21, x1
    f204:	29410a81 	ldp	w1, w2, [x20, #8]
    f208:	0b1602f3 	add	w19, w23, w22
    f20c:	6b13005f 	cmp	w2, w19
    f210:	1a81a421 	cinc	w1, w1, lt	// lt = tstop
    f214:	97fffeb7 	bl	ecf0 <_Balloc>
    f218:	b4000b80 	cbz	x0, f388 <__multiply+0x1c8>
    f21c:	91006007 	add	x7, x0, #0x18
    f220:	8b33c8e8 	add	x8, x7, w19, sxtw #2
    f224:	aa0703e3 	mov	x3, x7
    f228:	eb0800ff 	cmp	x7, x8
    f22c:	54000082 	b.cs	f23c <__multiply+0x7c>  // b.hs, b.nlast
    f230:	b800447f 	str	wzr, [x3], #4
    f234:	eb03011f 	cmp	x8, x3
    f238:	54ffffc8 	b.hi	f230 <__multiply+0x70>  // b.pmore
    f23c:	910062a6 	add	x6, x21, #0x18
    f240:	9100628b 	add	x11, x20, #0x18
    f244:	8b36c8c9 	add	x9, x6, w22, sxtw #2
    f248:	8b37c965 	add	x5, x11, w23, sxtw #2
    f24c:	eb0900df 	cmp	x6, x9
    f250:	54000822 	b.cs	f354 <__multiply+0x194>  // b.hs, b.nlast
    f254:	cb1400aa 	sub	x10, x5, x20
    f258:	91006694 	add	x20, x20, #0x19
    f25c:	d100654a 	sub	x10, x10, #0x19
    f260:	d2800081 	mov	x1, #0x4                   	// #4
    f264:	927ef54a 	and	x10, x10, #0xfffffffffffffffc
    f268:	eb1400bf 	cmp	x5, x20
    f26c:	8b01014a 	add	x10, x10, x1
    f270:	9a81214a 	csel	x10, x10, x1, cs	// cs = hs, nlast
    f274:	14000007 	b	f290 <__multiply+0xd0>
    f278:	53107c63 	lsr	w3, w3, #16
    f27c:	350003c3 	cbnz	w3, f2f4 <__multiply+0x134>
    f280:	910010c6 	add	x6, x6, #0x4
    f284:	910010e7 	add	x7, x7, #0x4
    f288:	eb06013f 	cmp	x9, x6
    f28c:	54000649 	b.ls	f354 <__multiply+0x194>  // b.plast
    f290:	b94000c3 	ldr	w3, [x6]
    f294:	72003c6d 	ands	w13, w3, #0xffff
    f298:	54ffff00 	b.eq	f278 <__multiply+0xb8>  // b.none
    f29c:	aa0703ec 	mov	x12, x7
    f2a0:	aa0b03e4 	mov	x4, x11
    f2a4:	5280000e 	mov	w14, #0x0                   	// #0
    f2a8:	b8404481 	ldr	w1, [x4], #4
    f2ac:	b9400183 	ldr	w3, [x12]
    f2b0:	12003c22 	and	w2, w1, #0xffff
    f2b4:	12003c6f 	and	w15, w3, #0xffff
    f2b8:	53107c21 	lsr	w1, w1, #16
    f2bc:	53107c63 	lsr	w3, w3, #16
    f2c0:	1b0d3c42 	madd	w2, w2, w13, w15
    f2c4:	1b0d0c21 	madd	w1, w1, w13, w3
    f2c8:	0b0e0042 	add	w2, w2, w14
    f2cc:	0b424021 	add	w1, w1, w2, lsr #16
    f2d0:	33103c22 	bfi	w2, w1, #16, #16
    f2d4:	b8004582 	str	w2, [x12], #4
    f2d8:	53107c2e 	lsr	w14, w1, #16
    f2dc:	eb0400bf 	cmp	x5, x4
    f2e0:	54fffe48 	b.hi	f2a8 <__multiply+0xe8>  // b.pmore
    f2e4:	b82a68ee 	str	w14, [x7, x10]
    f2e8:	b94000c3 	ldr	w3, [x6]
    f2ec:	53107c63 	lsr	w3, w3, #16
    f2f0:	34fffc83 	cbz	w3, f280 <__multiply+0xc0>
    f2f4:	b94000e1 	ldr	w1, [x7]
    f2f8:	aa0703ed 	mov	x13, x7
    f2fc:	aa0b03e4 	mov	x4, x11
    f300:	5280000e 	mov	w14, #0x0                   	// #0
    f304:	2a0103ec 	mov	w12, w1
    f308:	79400082 	ldrh	w2, [x4]
    f30c:	1b033842 	madd	w2, w2, w3, w14
    f310:	0b4c4042 	add	w2, w2, w12, lsr #16
    f314:	33103c41 	bfi	w1, w2, #16, #16
    f318:	b80045a1 	str	w1, [x13], #4
    f31c:	b8404481 	ldr	w1, [x4], #4
    f320:	b94001ac 	ldr	w12, [x13]
    f324:	53107c21 	lsr	w1, w1, #16
    f328:	12003d8e 	and	w14, w12, #0xffff
    f32c:	1b033821 	madd	w1, w1, w3, w14
    f330:	0b424021 	add	w1, w1, w2, lsr #16
    f334:	53107c2e 	lsr	w14, w1, #16
    f338:	eb0400bf 	cmp	x5, x4
    f33c:	54fffe68 	b.hi	f308 <__multiply+0x148>  // b.pmore
    f340:	910010c6 	add	x6, x6, #0x4
    f344:	b82a68e1 	str	w1, [x7, x10]
    f348:	910010e7 	add	x7, x7, #0x4
    f34c:	eb06013f 	cmp	x9, x6
    f350:	54fffa08 	b.hi	f290 <__multiply+0xd0>  // b.pmore
    f354:	7100027f 	cmp	w19, #0x0
    f358:	5400008c 	b.gt	f368 <__multiply+0x1a8>
    f35c:	14000005 	b	f370 <__multiply+0x1b0>
    f360:	71000673 	subs	w19, w19, #0x1
    f364:	54000060 	b.eq	f370 <__multiply+0x1b0>  // b.none
    f368:	b85fcd01 	ldr	w1, [x8, #-4]!
    f36c:	34ffffa1 	cbz	w1, f360 <__multiply+0x1a0>
    f370:	a9425bf5 	ldp	x21, x22, [sp, #32]
    f374:	f9401bf7 	ldr	x23, [sp, #48]
    f378:	b9001413 	str	w19, [x0, #20]
    f37c:	a94153f3 	ldp	x19, x20, [sp, #16]
    f380:	a8c47bfd 	ldp	x29, x30, [sp], #64
    f384:	d65f03c0 	ret
    f388:	b0000003 	adrp	x3, 10000 <__env_lock>
    f38c:	d0000000 	adrp	x0, 11000 <JIS_action_table>
    f390:	91398063 	add	x3, x3, #0xe60
    f394:	91026000 	add	x0, x0, #0x98
    f398:	d2800002 	mov	x2, #0x0                   	// #0
    f39c:	52802c41 	mov	w1, #0x162                 	// #354
    f3a0:	97ffcddc 	bl	2b10 <__assert_func>
	...

000000000000f3b0 <__pow5mult>:
    f3b0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    f3b4:	910003fd 	mov	x29, sp
    f3b8:	a90153f3 	stp	x19, x20, [sp, #16]
    f3bc:	2a0203f3 	mov	w19, w2
    f3c0:	72000442 	ands	w2, w2, #0x3
    f3c4:	a9025bf5 	stp	x21, x22, [sp, #32]
    f3c8:	aa0003f6 	mov	x22, x0
    f3cc:	aa0103f5 	mov	x21, x1
    f3d0:	540004c1 	b.ne	f468 <__pow5mult+0xb8>  // b.any
    f3d4:	13027e73 	asr	w19, w19, #2
    f3d8:	340002f3 	cbz	w19, f434 <__pow5mult+0x84>
    f3dc:	f94032d4 	ldr	x20, [x22, #96]
    f3e0:	b4000554 	cbz	x20, f488 <__pow5mult+0xd8>
    f3e4:	370000f3 	tbnz	w19, #0, f400 <__pow5mult+0x50>
    f3e8:	13017e73 	asr	w19, w19, #1
    f3ec:	34000253 	cbz	w19, f434 <__pow5mult+0x84>
    f3f0:	f9400280 	ldr	x0, [x20]
    f3f4:	b40002a0 	cbz	x0, f448 <__pow5mult+0x98>
    f3f8:	aa0003f4 	mov	x20, x0
    f3fc:	3607ff73 	tbz	w19, #0, f3e8 <__pow5mult+0x38>
    f400:	aa1403e2 	mov	x2, x20
    f404:	aa1503e1 	mov	x1, x21
    f408:	aa1603e0 	mov	x0, x22
    f40c:	97ffff6d 	bl	f1c0 <__multiply>
    f410:	b40000d5 	cbz	x21, f428 <__pow5mult+0x78>
    f414:	f94036c1 	ldr	x1, [x22, #104]
    f418:	b9800aa2 	ldrsw	x2, [x21, #8]
    f41c:	f8627823 	ldr	x3, [x1, x2, lsl #3]
    f420:	f90002a3 	str	x3, [x21]
    f424:	f8227835 	str	x21, [x1, x2, lsl #3]
    f428:	aa0003f5 	mov	x21, x0
    f42c:	13017e73 	asr	w19, w19, #1
    f430:	35fffe13 	cbnz	w19, f3f0 <__pow5mult+0x40>
    f434:	a94153f3 	ldp	x19, x20, [sp, #16]
    f438:	aa1503e0 	mov	x0, x21
    f43c:	a9425bf5 	ldp	x21, x22, [sp, #32]
    f440:	a8c37bfd 	ldp	x29, x30, [sp], #48
    f444:	d65f03c0 	ret
    f448:	aa1403e2 	mov	x2, x20
    f44c:	aa1403e1 	mov	x1, x20
    f450:	aa1603e0 	mov	x0, x22
    f454:	97ffff5b 	bl	f1c0 <__multiply>
    f458:	f9000280 	str	x0, [x20]
    f45c:	aa0003f4 	mov	x20, x0
    f460:	f900001f 	str	xzr, [x0]
    f464:	17ffffe6 	b	f3fc <__pow5mult+0x4c>
    f468:	51000442 	sub	w2, w2, #0x1
    f46c:	d0000004 	adrp	x4, 11000 <JIS_action_table>
    f470:	9103e084 	add	x4, x4, #0xf8
    f474:	52800003 	mov	w3, #0x0                   	// #0
    f478:	b862d882 	ldr	w2, [x4, w2, sxtw #2]
    f47c:	97fffe49 	bl	eda0 <__multadd>
    f480:	aa0003f5 	mov	x21, x0
    f484:	17ffffd4 	b	f3d4 <__pow5mult+0x24>
    f488:	aa1603e0 	mov	x0, x22
    f48c:	52800021 	mov	w1, #0x1                   	// #1
    f490:	97fffe18 	bl	ecf0 <_Balloc>
    f494:	aa0003f4 	mov	x20, x0
    f498:	b40000e0 	cbz	x0, f4b4 <__pow5mult+0x104>
    f49c:	d2800020 	mov	x0, #0x1                   	// #1
    f4a0:	f2c04e20 	movk	x0, #0x271, lsl #32
    f4a4:	f8014280 	stur	x0, [x20, #20]
    f4a8:	f90032d4 	str	x20, [x22, #96]
    f4ac:	f900029f 	str	xzr, [x20]
    f4b0:	17ffffcd 	b	f3e4 <__pow5mult+0x34>
    f4b4:	b0000003 	adrp	x3, 10000 <__env_lock>
    f4b8:	d0000000 	adrp	x0, 11000 <JIS_action_table>
    f4bc:	91398063 	add	x3, x3, #0xe60
    f4c0:	91026000 	add	x0, x0, #0x98
    f4c4:	d2800002 	mov	x2, #0x0                   	// #0
    f4c8:	528028a1 	mov	w1, #0x145                 	// #325
    f4cc:	97ffcd91 	bl	2b10 <__assert_func>

000000000000f4d0 <__lshift>:
    f4d0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
    f4d4:	910003fd 	mov	x29, sp
    f4d8:	a90363f7 	stp	x23, x24, [sp, #48]
    f4dc:	13057c58 	asr	w24, w2, #5
    f4e0:	b9401437 	ldr	w23, [x1, #20]
    f4e4:	b9400c23 	ldr	w3, [x1, #12]
    f4e8:	0b170317 	add	w23, w24, w23
    f4ec:	a90153f3 	stp	x19, x20, [sp, #16]
    f4f0:	aa0103f4 	mov	x20, x1
    f4f4:	a9025bf5 	stp	x21, x22, [sp, #32]
    f4f8:	110006f5 	add	w21, w23, #0x1
    f4fc:	b9400821 	ldr	w1, [x1, #8]
    f500:	2a0203f3 	mov	w19, w2
    f504:	aa0003f6 	mov	x22, x0
    f508:	6b0302bf 	cmp	w21, w3
    f50c:	540000ad 	b.le	f520 <__lshift+0x50>
    f510:	531f7863 	lsl	w3, w3, #1
    f514:	11000421 	add	w1, w1, #0x1
    f518:	6b0302bf 	cmp	w21, w3
    f51c:	54ffffac 	b.gt	f510 <__lshift+0x40>
    f520:	aa1603e0 	mov	x0, x22
    f524:	97fffdf3 	bl	ecf0 <_Balloc>
    f528:	b40007a0 	cbz	x0, f61c <__lshift+0x14c>
    f52c:	91006005 	add	x5, x0, #0x18
    f530:	7100031f 	cmp	w24, #0x0
    f534:	5400012d 	b.le	f558 <__lshift+0x88>
    f538:	11001b04 	add	w4, w24, #0x6
    f53c:	aa0503e3 	mov	x3, x5
    f540:	8b24c804 	add	x4, x0, w4, sxtw #2
    f544:	d503201f 	nop
    f548:	b800447f 	str	wzr, [x3], #4
    f54c:	eb04007f 	cmp	x3, x4
    f550:	54ffffc1 	b.ne	f548 <__lshift+0x78>  // b.any
    f554:	8b3848a5 	add	x5, x5, w24, uxtw #2
    f558:	b9801686 	ldrsw	x6, [x20, #20]
    f55c:	91006283 	add	x3, x20, #0x18
    f560:	72001267 	ands	w7, w19, #0x1f
    f564:	8b060866 	add	x6, x3, x6, lsl #2
    f568:	54000480 	b.eq	f5f8 <__lshift+0x128>  // b.none
    f56c:	52800408 	mov	w8, #0x20                  	// #32
    f570:	aa0503e1 	mov	x1, x5
    f574:	4b070108 	sub	w8, w8, w7
    f578:	52800004 	mov	w4, #0x0                   	// #0
    f57c:	d503201f 	nop
    f580:	b9400062 	ldr	w2, [x3]
    f584:	1ac72042 	lsl	w2, w2, w7
    f588:	2a040042 	orr	w2, w2, w4
    f58c:	b8004422 	str	w2, [x1], #4
    f590:	b8404464 	ldr	w4, [x3], #4
    f594:	1ac82484 	lsr	w4, w4, w8
    f598:	eb0300df 	cmp	x6, x3
    f59c:	54ffff28 	b.hi	f580 <__lshift+0xb0>  // b.pmore
    f5a0:	cb1400c1 	sub	x1, x6, x20
    f5a4:	91006682 	add	x2, x20, #0x19
    f5a8:	d1006421 	sub	x1, x1, #0x19
    f5ac:	eb0200df 	cmp	x6, x2
    f5b0:	927ef421 	and	x1, x1, #0xfffffffffffffffc
    f5b4:	d2800082 	mov	x2, #0x4                   	// #4
    f5b8:	8b020021 	add	x1, x1, x2
    f5bc:	9a822021 	csel	x1, x1, x2, cs	// cs = hs, nlast
    f5c0:	b82168a4 	str	w4, [x5, x1]
    f5c4:	35000044 	cbnz	w4, f5cc <__lshift+0xfc>
    f5c8:	2a1703f5 	mov	w21, w23
    f5cc:	f94036c1 	ldr	x1, [x22, #104]
    f5d0:	b9800a82 	ldrsw	x2, [x20, #8]
    f5d4:	a94363f7 	ldp	x23, x24, [sp, #48]
    f5d8:	f8627823 	ldr	x3, [x1, x2, lsl #3]
    f5dc:	b9001415 	str	w21, [x0, #20]
    f5e0:	a9425bf5 	ldp	x21, x22, [sp, #32]
    f5e4:	f9000283 	str	x3, [x20]
    f5e8:	f8227834 	str	x20, [x1, x2, lsl #3]
    f5ec:	a94153f3 	ldp	x19, x20, [sp, #16]
    f5f0:	a8c47bfd 	ldp	x29, x30, [sp], #64
    f5f4:	d65f03c0 	ret
    f5f8:	b8404461 	ldr	w1, [x3], #4
    f5fc:	b80044a1 	str	w1, [x5], #4
    f600:	eb0300df 	cmp	x6, x3
    f604:	54fffe29 	b.ls	f5c8 <__lshift+0xf8>  // b.plast
    f608:	b8404461 	ldr	w1, [x3], #4
    f60c:	b80044a1 	str	w1, [x5], #4
    f610:	eb0300df 	cmp	x6, x3
    f614:	54ffff28 	b.hi	f5f8 <__lshift+0x128>  // b.pmore
    f618:	17ffffec 	b	f5c8 <__lshift+0xf8>
    f61c:	b0000003 	adrp	x3, 10000 <__env_lock>
    f620:	d0000000 	adrp	x0, 11000 <JIS_action_table>
    f624:	91398063 	add	x3, x3, #0xe60
    f628:	91026000 	add	x0, x0, #0x98
    f62c:	d2800002 	mov	x2, #0x0                   	// #0
    f630:	52803bc1 	mov	w1, #0x1de                 	// #478
    f634:	97ffcd37 	bl	2b10 <__assert_func>
	...

000000000000f640 <__mcmp>:
    f640:	b9401422 	ldr	w2, [x1, #20]
    f644:	aa0003e5 	mov	x5, x0
    f648:	b9401400 	ldr	w0, [x0, #20]
    f64c:	6b020000 	subs	w0, w0, w2
    f650:	540001e1 	b.ne	f68c <__mcmp+0x4c>  // b.any
    f654:	937e7c43 	sbfiz	x3, x2, #2, #32
    f658:	910060a5 	add	x5, x5, #0x18
    f65c:	91006021 	add	x1, x1, #0x18
    f660:	8b0300a2 	add	x2, x5, x3
    f664:	8b030021 	add	x1, x1, x3
    f668:	14000003 	b	f674 <__mcmp+0x34>
    f66c:	eb0200bf 	cmp	x5, x2
    f670:	540000e2 	b.cs	f68c <__mcmp+0x4c>  // b.hs, b.nlast
    f674:	b85fcc44 	ldr	w4, [x2, #-4]!
    f678:	b85fcc23 	ldr	w3, [x1, #-4]!
    f67c:	6b03009f 	cmp	w4, w3
    f680:	54ffff60 	b.eq	f66c <__mcmp+0x2c>  // b.none
    f684:	12800000 	mov	w0, #0xffffffff            	// #-1
    f688:	1a9f3400 	csinc	w0, w0, wzr, cc	// cc = lo, ul, last
    f68c:	d65f03c0 	ret

000000000000f690 <__mdiff>:
    f690:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    f694:	910003fd 	mov	x29, sp
    f698:	a90153f3 	stp	x19, x20, [sp, #16]
    f69c:	aa0103f4 	mov	x20, x1
    f6a0:	aa0203f3 	mov	x19, x2
    f6a4:	f90013f5 	str	x21, [sp, #32]
    f6a8:	b9401435 	ldr	w21, [x1, #20]
    f6ac:	b9401441 	ldr	w1, [x2, #20]
    f6b0:	6b0102b5 	subs	w21, w21, w1
    f6b4:	35000255 	cbnz	w21, f6fc <__mdiff+0x6c>
    f6b8:	937e7c22 	sbfiz	x2, x1, #2, #32
    f6bc:	91006264 	add	x4, x19, #0x18
    f6c0:	91006281 	add	x1, x20, #0x18
    f6c4:	8b020084 	add	x4, x4, x2
    f6c8:	8b020023 	add	x3, x1, x2
    f6cc:	14000003 	b	f6d8 <__mdiff+0x48>
    f6d0:	eb03003f 	cmp	x1, x3
    f6d4:	54000a22 	b.cs	f818 <__mdiff+0x188>  // b.hs, b.nlast
    f6d8:	b85fcc66 	ldr	w6, [x3, #-4]!
    f6dc:	b85fcc85 	ldr	w5, [x4, #-4]!
    f6e0:	6b0500df 	cmp	w6, w5
    f6e4:	54ffff60 	b.eq	f6d0 <__mdiff+0x40>  // b.none
    f6e8:	aa1403e1 	mov	x1, x20
    f6ec:	1a9f27f5 	cset	w21, cc	// cc = lo, ul, last
    f6f0:	9a932294 	csel	x20, x20, x19, cs	// cs = hs, nlast
    f6f4:	9a812273 	csel	x19, x19, x1, cs	// cs = hs, nlast
    f6f8:	14000005 	b	f70c <__mdiff+0x7c>
    f6fc:	aa1403e1 	mov	x1, x20
    f700:	1a9f57f5 	cset	w21, mi	// mi = first
    f704:	9a825294 	csel	x20, x20, x2, pl	// pl = nfrst
    f708:	9a815053 	csel	x19, x2, x1, pl	// pl = nfrst
    f70c:	b9400a81 	ldr	w1, [x20, #8]
    f710:	97fffd78 	bl	ecf0 <_Balloc>
    f714:	b4000ac0 	cbz	x0, f86c <__mdiff+0x1dc>
    f718:	b9801668 	ldrsw	x8, [x19, #20]
    f71c:	91006289 	add	x9, x20, #0x18
    f720:	b9401687 	ldr	w7, [x20, #20]
    f724:	91006262 	add	x2, x19, #0x18
    f728:	9100600b 	add	x11, x0, #0x18
    f72c:	d2800305 	mov	x5, #0x18                  	// #24
    f730:	8b080848 	add	x8, x2, x8, lsl #2
    f734:	52800001 	mov	w1, #0x0                   	// #0
    f738:	8b27c92a 	add	x10, x9, w7, sxtw #2
    f73c:	b9001015 	str	w21, [x0, #16]
    f740:	b8656a86 	ldr	w6, [x20, x5]
    f744:	b8656a64 	ldr	w4, [x19, x5]
    f748:	12003cc3 	and	w3, w6, #0xffff
    f74c:	53107cc6 	lsr	w6, w6, #16
    f750:	4b242063 	sub	w3, w3, w4, uxth
    f754:	4b4440c4 	sub	w4, w6, w4, lsr #16
    f758:	0b010063 	add	w3, w3, w1
    f75c:	0b834084 	add	w4, w4, w3, asr #16
    f760:	33103c83 	bfi	w3, w4, #16, #16
    f764:	b8256803 	str	w3, [x0, x5]
    f768:	910010a5 	add	x5, x5, #0x4
    f76c:	13107c81 	asr	w1, w4, #16
    f770:	8b050264 	add	x4, x19, x5
    f774:	eb04011f 	cmp	x8, x4
    f778:	54fffe48 	b.hi	f740 <__mdiff+0xb0>  // b.pmore
    f77c:	cb130104 	sub	x4, x8, x19
    f780:	91006662 	add	x2, x19, #0x19
    f784:	d1006484 	sub	x4, x4, #0x19
    f788:	eb02011f 	cmp	x8, x2
    f78c:	d2800086 	mov	x6, #0x4                   	// #4
    f790:	d342fc84 	lsr	x4, x4, #2
    f794:	91000485 	add	x5, x4, #0x1
    f798:	d37ef4a5 	lsl	x5, x5, #2
    f79c:	9a8620a5 	csel	x5, x5, x6, cs	// cs = hs, nlast
    f7a0:	8b050129 	add	x9, x9, x5
    f7a4:	8b050165 	add	x5, x11, x5
    f7a8:	eb09015f 	cmp	x10, x9
    f7ac:	54000489 	b.ls	f83c <__mdiff+0x1ac>  // b.plast
    f7b0:	d100054a 	sub	x10, x10, #0x1
    f7b4:	d2800004 	mov	x4, #0x0                   	// #0
    f7b8:	cb09014a 	sub	x10, x10, x9
    f7bc:	d342fd48 	lsr	x8, x10, #2
    f7c0:	b8647922 	ldr	w2, [x9, x4, lsl #2]
    f7c4:	eb04011f 	cmp	x8, x4
    f7c8:	0b010043 	add	w3, w2, w1
    f7cc:	0b222021 	add	w1, w1, w2, uxth
    f7d0:	53107c42 	lsr	w2, w2, #16
    f7d4:	0b814041 	add	w1, w2, w1, asr #16
    f7d8:	33103c23 	bfi	w3, w1, #16, #16
    f7dc:	b82478a3 	str	w3, [x5, x4, lsl #2]
    f7e0:	13107c21 	asr	w1, w1, #16
    f7e4:	91000484 	add	x4, x4, #0x1
    f7e8:	54fffec1 	b.ne	f7c0 <__mdiff+0x130>  // b.any
    f7ec:	927ef54a 	and	x10, x10, #0xfffffffffffffffc
    f7f0:	8b0a00a1 	add	x1, x5, x10
    f7f4:	35000083 	cbnz	w3, f804 <__mdiff+0x174>
    f7f8:	b85fcc22 	ldr	w2, [x1, #-4]!
    f7fc:	510004e7 	sub	w7, w7, #0x1
    f800:	34ffffc2 	cbz	w2, f7f8 <__mdiff+0x168>
    f804:	b9001407 	str	w7, [x0, #20]
    f808:	a94153f3 	ldp	x19, x20, [sp, #16]
    f80c:	f94013f5 	ldr	x21, [sp, #32]
    f810:	a8c37bfd 	ldp	x29, x30, [sp], #48
    f814:	d65f03c0 	ret
    f818:	52800001 	mov	w1, #0x0                   	// #0
    f81c:	97fffd35 	bl	ecf0 <_Balloc>
    f820:	b4000180 	cbz	x0, f850 <__mdiff+0x1c0>
    f824:	d2800021 	mov	x1, #0x1                   	// #1
    f828:	f8014001 	stur	x1, [x0, #20]
    f82c:	a94153f3 	ldp	x19, x20, [sp, #16]
    f830:	f94013f5 	ldr	x21, [sp, #32]
    f834:	a8c37bfd 	ldp	x29, x30, [sp], #48
    f838:	d65f03c0 	ret
    f83c:	d37ef484 	lsl	x4, x4, #2
    f840:	eb02011f 	cmp	x8, x2
    f844:	9a9f2084 	csel	x4, x4, xzr, cs	// cs = hs, nlast
    f848:	8b040161 	add	x1, x11, x4
    f84c:	17ffffea 	b	f7f4 <__mdiff+0x164>
    f850:	b0000003 	adrp	x3, 10000 <__env_lock>
    f854:	d0000000 	adrp	x0, 11000 <JIS_action_table>
    f858:	91398063 	add	x3, x3, #0xe60
    f85c:	91026000 	add	x0, x0, #0x98
    f860:	d2800002 	mov	x2, #0x0                   	// #0
    f864:	528046e1 	mov	w1, #0x237                 	// #567
    f868:	97ffccaa 	bl	2b10 <__assert_func>
    f86c:	b0000003 	adrp	x3, 10000 <__env_lock>
    f870:	d0000000 	adrp	x0, 11000 <JIS_action_table>
    f874:	91398063 	add	x3, x3, #0xe60
    f878:	91026000 	add	x0, x0, #0x98
    f87c:	d2800002 	mov	x2, #0x0                   	// #0
    f880:	528048a1 	mov	w1, #0x245                 	// #581
    f884:	97ffcca3 	bl	2b10 <__assert_func>
	...

000000000000f890 <__ulp>:
    f890:	9e660000 	fmov	x0, d0
    f894:	52bf9801 	mov	w1, #0xfcc00000            	// #-54525952
    f898:	d360fc00 	lsr	x0, x0, #32
    f89c:	120c2800 	and	w0, w0, #0x7ff00000
    f8a0:	0b010000 	add	w0, w0, w1
    f8a4:	52800001 	mov	w1, #0x0                   	// #0
    f8a8:	7100001f 	cmp	w0, #0x0
    f8ac:	540000ad 	b.le	f8c0 <__ulp+0x30>
    f8b0:	2a0103e1 	mov	w1, w1
    f8b4:	aa008020 	orr	x0, x1, x0, lsl #32
    f8b8:	9e670000 	fmov	d0, x0
    f8bc:	d65f03c0 	ret
    f8c0:	4b0003e0 	neg	w0, w0
    f8c4:	13147c00 	asr	w0, w0, #20
    f8c8:	71004c1f 	cmp	w0, #0x13
    f8cc:	5400010c 	b.gt	f8ec <__ulp+0x5c>
    f8d0:	52a00102 	mov	w2, #0x80000               	// #524288
    f8d4:	52800001 	mov	w1, #0x0                   	// #0
    f8d8:	1ac02840 	asr	w0, w2, w0
    f8dc:	2a0103e1 	mov	w1, w1
    f8e0:	aa008020 	orr	x0, x1, x0, lsl #32
    f8e4:	9e670000 	fmov	d0, x0
    f8e8:	d65f03c0 	ret
    f8ec:	51005002 	sub	w2, w0, #0x14
    f8f0:	52b00001 	mov	w1, #0x80000000            	// #-2147483648
    f8f4:	71007c5f 	cmp	w2, #0x1f
    f8f8:	52800000 	mov	w0, #0x0                   	// #0
    f8fc:	1ac22421 	lsr	w1, w1, w2
    f900:	1a9fb421 	csinc	w1, w1, wzr, lt	// lt = tstop
    f904:	2a0103e1 	mov	w1, w1
    f908:	aa008020 	orr	x0, x1, x0, lsl #32
    f90c:	9e670000 	fmov	d0, x0
    f910:	d65f03c0 	ret
	...

000000000000f920 <__b2d>:
    f920:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    f924:	91006006 	add	x6, x0, #0x18
    f928:	aa0103e5 	mov	x5, x1
    f92c:	910003fd 	mov	x29, sp
    f930:	b9801404 	ldrsw	x4, [x0, #20]
    f934:	8b0408c4 	add	x4, x6, x4, lsl #2
    f938:	d1001087 	sub	x7, x4, #0x4
    f93c:	b85fc083 	ldur	w3, [x4, #-4]
    f940:	2a0303e0 	mov	w0, w3
    f944:	97fffda7 	bl	efe0 <__hi0bits>
    f948:	52800401 	mov	w1, #0x20                  	// #32
    f94c:	4b000022 	sub	w2, w1, w0
    f950:	b90000a2 	str	w2, [x5]
    f954:	7100281f 	cmp	w0, #0xa
    f958:	5400056d 	b.le	fa04 <__b2d+0xe4>
    f95c:	51002c05 	sub	w5, w0, #0xb
    f960:	eb0700df 	cmp	x6, x7
    f964:	540002a2 	b.cs	f9b8 <__b2d+0x98>  // b.hs, b.nlast
    f968:	b85f8080 	ldur	w0, [x4, #-8]
    f96c:	340003e5 	cbz	w5, f9e8 <__b2d+0xc8>
    f970:	4b050022 	sub	w2, w1, w5
    f974:	1ac52063 	lsl	w3, w3, w5
    f978:	d2800001 	mov	x1, #0x0                   	// #0
    f97c:	d1002087 	sub	x7, x4, #0x8
    f980:	1ac22408 	lsr	w8, w0, w2
    f984:	2a080063 	orr	w3, w3, w8
    f988:	320c2463 	orr	w3, w3, #0x3ff00000
    f98c:	1ac52000 	lsl	w0, w0, w5
    f990:	b3607c61 	bfi	x1, x3, #32, #32
    f994:	eb0700df 	cmp	x6, x7
    f998:	540002e2 	b.cs	f9f4 <__b2d+0xd4>  // b.hs, b.nlast
    f99c:	b85f4083 	ldur	w3, [x4, #-12]
    f9a0:	a8c17bfd 	ldp	x29, x30, [sp], #16
    f9a4:	1ac22462 	lsr	w2, w3, w2
    f9a8:	2a020000 	orr	w0, w0, w2
    f9ac:	b3407c01 	bfxil	x1, x0, #0, #32
    f9b0:	9e670020 	fmov	d0, x1
    f9b4:	d65f03c0 	ret
    f9b8:	71002c1f 	cmp	w0, #0xb
    f9bc:	54000140 	b.eq	f9e4 <__b2d+0xc4>  // b.none
    f9c0:	1ac52063 	lsl	w3, w3, w5
    f9c4:	320c2463 	orr	w3, w3, #0x3ff00000
    f9c8:	d2800001 	mov	x1, #0x0                   	// #0
    f9cc:	52800000 	mov	w0, #0x0                   	// #0
    f9d0:	b3607c61 	bfi	x1, x3, #32, #32
    f9d4:	a8c17bfd 	ldp	x29, x30, [sp], #16
    f9d8:	b3407c01 	bfxil	x1, x0, #0, #32
    f9dc:	9e670020 	fmov	d0, x1
    f9e0:	d65f03c0 	ret
    f9e4:	52800000 	mov	w0, #0x0                   	// #0
    f9e8:	320c2463 	orr	w3, w3, #0x3ff00000
    f9ec:	d2800001 	mov	x1, #0x0                   	// #0
    f9f0:	b3607c61 	bfi	x1, x3, #32, #32
    f9f4:	b3407c01 	bfxil	x1, x0, #0, #32
    f9f8:	9e670020 	fmov	d0, x1
    f9fc:	a8c17bfd 	ldp	x29, x30, [sp], #16
    fa00:	d65f03c0 	ret
    fa04:	52800165 	mov	w5, #0xb                   	// #11
    fa08:	4b0000a5 	sub	w5, w5, w0
    fa0c:	d2800001 	mov	x1, #0x0                   	// #0
    fa10:	52800002 	mov	w2, #0x0                   	// #0
    fa14:	1ac52468 	lsr	w8, w3, w5
    fa18:	320c2508 	orr	w8, w8, #0x3ff00000
    fa1c:	b3607d01 	bfi	x1, x8, #32, #32
    fa20:	eb0700df 	cmp	x6, x7
    fa24:	54000062 	b.cs	fa30 <__b2d+0x110>  // b.hs, b.nlast
    fa28:	b85f8082 	ldur	w2, [x4, #-8]
    fa2c:	1ac52442 	lsr	w2, w2, w5
    fa30:	11005400 	add	w0, w0, #0x15
    fa34:	a8c17bfd 	ldp	x29, x30, [sp], #16
    fa38:	1ac02063 	lsl	w3, w3, w0
    fa3c:	2a020060 	orr	w0, w3, w2
    fa40:	b3407c01 	bfxil	x1, x0, #0, #32
    fa44:	9e670020 	fmov	d0, x1
    fa48:	d65f03c0 	ret
    fa4c:	00000000 	udf	#0

000000000000fa50 <__d2b>:
    fa50:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
    fa54:	910003fd 	mov	x29, sp
    fa58:	fd0013e8 	str	d8, [sp, #32]
    fa5c:	1e604008 	fmov	d8, d0
    fa60:	a90153f3 	stp	x19, x20, [sp, #16]
    fa64:	aa0103f4 	mov	x20, x1
    fa68:	aa0203f3 	mov	x19, x2
    fa6c:	52800021 	mov	w1, #0x1                   	// #1
    fa70:	97fffca0 	bl	ecf0 <_Balloc>
    fa74:	b40007a0 	cbz	x0, fb68 <__d2b+0x118>
    fa78:	9e660103 	fmov	x3, d8
    fa7c:	aa0003e4 	mov	x4, x0
    fa80:	d374f865 	ubfx	x5, x3, #52, #11
    fa84:	d360cc60 	ubfx	x0, x3, #32, #20
    fa88:	320c0001 	orr	w1, w0, #0x100000
    fa8c:	710000bf 	cmp	w5, #0x0
    fa90:	1a801020 	csel	w0, w1, w0, ne	// ne = any
    fa94:	b9003fe0 	str	w0, [sp, #60]
    fa98:	35000283 	cbnz	w3, fae8 <__d2b+0x98>
    fa9c:	9100f3e0 	add	x0, sp, #0x3c
    faa0:	97fffd70 	bl	f060 <__lo0bits>
    faa4:	b9403fe1 	ldr	w1, [sp, #60]
    faa8:	52800023 	mov	w3, #0x1                   	// #1
    faac:	b9001483 	str	w3, [x4, #20]
    fab0:	11008000 	add	w0, w0, #0x20
    fab4:	b9001881 	str	w1, [x4, #24]
    fab8:	340003a5 	cbz	w5, fb2c <__d2b+0xdc>
    fabc:	5110cca5 	sub	w5, w5, #0x433
    fac0:	fd4013e8 	ldr	d8, [sp, #32]
    fac4:	0b0000a5 	add	w5, w5, w0
    fac8:	b9000285 	str	w5, [x20]
    facc:	528006a3 	mov	w3, #0x35                  	// #53
    fad0:	4b000063 	sub	w3, w3, w0
    fad4:	b9000263 	str	w3, [x19]
    fad8:	aa0403e0 	mov	x0, x4
    fadc:	a94153f3 	ldp	x19, x20, [sp, #16]
    fae0:	a8c47bfd 	ldp	x29, x30, [sp], #64
    fae4:	d65f03c0 	ret
    fae8:	9100e3e0 	add	x0, sp, #0x38
    faec:	bd003be8 	str	s8, [sp, #56]
    faf0:	97fffd5c 	bl	f060 <__lo0bits>
    faf4:	b9403fe1 	ldr	w1, [sp, #60]
    faf8:	34000340 	cbz	w0, fb60 <__d2b+0x110>
    fafc:	b9403be3 	ldr	w3, [sp, #56]
    fb00:	4b0003e2 	neg	w2, w0
    fb04:	1ac22022 	lsl	w2, w1, w2
    fb08:	2a030042 	orr	w2, w2, w3
    fb0c:	1ac02421 	lsr	w1, w1, w0
    fb10:	b9003fe1 	str	w1, [sp, #60]
    fb14:	7100003f 	cmp	w1, #0x0
    fb18:	29030482 	stp	w2, w1, [x4, #24]
    fb1c:	1a9f07e3 	cset	w3, ne	// ne = any
    fb20:	11000463 	add	w3, w3, #0x1
    fb24:	b9001483 	str	w3, [x4, #20]
    fb28:	35fffca5 	cbnz	w5, fabc <__d2b+0x6c>
    fb2c:	8b23c881 	add	x1, x4, w3, sxtw #2
    fb30:	5110c800 	sub	w0, w0, #0x432
    fb34:	b9000280 	str	w0, [x20]
    fb38:	531b6863 	lsl	w3, w3, #5
    fb3c:	b9401420 	ldr	w0, [x1, #20]
    fb40:	97fffd28 	bl	efe0 <__hi0bits>
    fb44:	fd4013e8 	ldr	d8, [sp, #32]
    fb48:	4b000063 	sub	w3, w3, w0
    fb4c:	b9000263 	str	w3, [x19]
    fb50:	a94153f3 	ldp	x19, x20, [sp, #16]
    fb54:	aa0403e0 	mov	x0, x4
    fb58:	a8c47bfd 	ldp	x29, x30, [sp], #64
    fb5c:	d65f03c0 	ret
    fb60:	b9403be2 	ldr	w2, [sp, #56]
    fb64:	17ffffec 	b	fb14 <__d2b+0xc4>
    fb68:	b0000003 	adrp	x3, 10000 <__env_lock>
    fb6c:	d0000000 	adrp	x0, 11000 <JIS_action_table>
    fb70:	91398063 	add	x3, x3, #0xe60
    fb74:	91026000 	add	x0, x0, #0x98
    fb78:	d2800002 	mov	x2, #0x0                   	// #0
    fb7c:	528061e1 	mov	w1, #0x30f                 	// #783
    fb80:	97ffcbe4 	bl	2b10 <__assert_func>
	...

000000000000fb90 <__ratio>:
    fb90:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    fb94:	aa0103e9 	mov	x9, x1
    fb98:	aa0003ea 	mov	x10, x0
    fb9c:	910003fd 	mov	x29, sp
    fba0:	910063e1 	add	x1, sp, #0x18
    fba4:	97ffff5f 	bl	f920 <__b2d>
    fba8:	aa0903e0 	mov	x0, x9
    fbac:	910073e1 	add	x1, sp, #0x1c
    fbb0:	1e604001 	fmov	d1, d0
    fbb4:	97ffff5b 	bl	f920 <__b2d>
    fbb8:	b9401524 	ldr	w4, [x9, #20]
    fbbc:	b9401540 	ldr	w0, [x10, #20]
    fbc0:	29430fe1 	ldp	w1, w3, [sp, #24]
    fbc4:	4b040000 	sub	w0, w0, w4
    fbc8:	4b030021 	sub	w1, w1, w3
    fbcc:	0b001420 	add	w0, w1, w0, lsl #5
    fbd0:	7100001f 	cmp	w0, #0x0
    fbd4:	5400012d 	b.le	fbf8 <__ratio+0x68>
    fbd8:	9e660022 	fmov	x2, d1
    fbdc:	a8c27bfd 	ldp	x29, x30, [sp], #32
    fbe0:	d360fc41 	lsr	x1, x2, #32
    fbe4:	0b005020 	add	w0, w1, w0, lsl #20
    fbe8:	b3607c02 	bfi	x2, x0, #32, #32
    fbec:	9e670041 	fmov	d1, x2
    fbf0:	1e601820 	fdiv	d0, d1, d0
    fbf4:	d65f03c0 	ret
    fbf8:	9e660001 	fmov	x1, d0
    fbfc:	a8c27bfd 	ldp	x29, x30, [sp], #32
    fc00:	d360fc22 	lsr	x2, x1, #32
    fc04:	4b005040 	sub	w0, w2, w0, lsl #20
    fc08:	b3607c01 	bfi	x1, x0, #32, #32
    fc0c:	9e670020 	fmov	d0, x1
    fc10:	1e601820 	fdiv	d0, d1, d0
    fc14:	d65f03c0 	ret
	...

000000000000fc20 <_mprec_log10>:
    fc20:	1e6e1000 	fmov	d0, #1.000000000000000000e+00
    fc24:	1e649001 	fmov	d1, #1.000000000000000000e+01
    fc28:	71005c1f 	cmp	w0, #0x17
    fc2c:	540000ad 	b.le	fc40 <_mprec_log10+0x20>
    fc30:	1e610800 	fmul	d0, d0, d1
    fc34:	71000400 	subs	w0, w0, #0x1
    fc38:	54ffffc1 	b.ne	fc30 <_mprec_log10+0x10>  // b.any
    fc3c:	d65f03c0 	ret
    fc40:	d0000001 	adrp	x1, 11000 <JIS_action_table>
    fc44:	9105c021 	add	x1, x1, #0x170
    fc48:	fc60d820 	ldr	d0, [x1, w0, sxtw #3]
    fc4c:	d65f03c0 	ret

000000000000fc50 <__copybits>:
    fc50:	51000421 	sub	w1, w1, #0x1
    fc54:	91006046 	add	x6, x2, #0x18
    fc58:	13057c24 	asr	w4, w1, #5
    fc5c:	b9801441 	ldrsw	x1, [x2, #20]
    fc60:	11000484 	add	w4, w4, #0x1
    fc64:	8b0108c1 	add	x1, x6, x1, lsl #2
    fc68:	8b24c804 	add	x4, x0, w4, sxtw #2
    fc6c:	eb0100df 	cmp	x6, x1
    fc70:	540001e2 	b.cs	fcac <__copybits+0x5c>  // b.hs, b.nlast
    fc74:	cb020023 	sub	x3, x1, x2
    fc78:	d2800001 	mov	x1, #0x0                   	// #0
    fc7c:	d1006463 	sub	x3, x3, #0x19
    fc80:	d342fc63 	lsr	x3, x3, #2
    fc84:	91000467 	add	x7, x3, #0x1
    fc88:	b86178c5 	ldr	w5, [x6, x1, lsl #2]
    fc8c:	eb03003f 	cmp	x1, x3
    fc90:	b8217805 	str	w5, [x0, x1, lsl #2]
    fc94:	91000421 	add	x1, x1, #0x1
    fc98:	54ffff81 	b.ne	fc88 <__copybits+0x38>  // b.any
    fc9c:	8b070800 	add	x0, x0, x7, lsl #2
    fca0:	eb00009f 	cmp	x4, x0
    fca4:	54000089 	b.ls	fcb4 <__copybits+0x64>  // b.plast
    fca8:	b800441f 	str	wzr, [x0], #4
    fcac:	eb00009f 	cmp	x4, x0
    fcb0:	54ffffc8 	b.hi	fca8 <__copybits+0x58>  // b.pmore
    fcb4:	d65f03c0 	ret
	...

000000000000fcc0 <__any_on>:
    fcc0:	91006003 	add	x3, x0, #0x18
    fcc4:	b9401400 	ldr	w0, [x0, #20]
    fcc8:	13057c22 	asr	w2, w1, #5
    fccc:	6b02001f 	cmp	w0, w2
    fcd0:	5400012a 	b.ge	fcf4 <__any_on+0x34>  // b.tcont
    fcd4:	8b20c862 	add	x2, x3, w0, sxtw #2
    fcd8:	14000003 	b	fce4 <__any_on+0x24>
    fcdc:	b85fcc40 	ldr	w0, [x2, #-4]!
    fce0:	35000220 	cbnz	w0, fd24 <__any_on+0x64>
    fce4:	eb03005f 	cmp	x2, x3
    fce8:	54ffffa8 	b.hi	fcdc <__any_on+0x1c>  // b.pmore
    fcec:	52800000 	mov	w0, #0x0                   	// #0
    fcf0:	d65f03c0 	ret
    fcf4:	93407c40 	sxtw	x0, w2
    fcf8:	8b22c862 	add	x2, x3, w2, sxtw #2
    fcfc:	54ffff4d 	b.le	fce4 <__any_on+0x24>
    fd00:	72001021 	ands	w1, w1, #0x1f
    fd04:	54ffff00 	b.eq	fce4 <__any_on+0x24>  // b.none
    fd08:	b8607865 	ldr	w5, [x3, x0, lsl #2]
    fd0c:	52800020 	mov	w0, #0x1                   	// #1
    fd10:	1ac124a4 	lsr	w4, w5, w1
    fd14:	1ac12081 	lsl	w1, w4, w1
    fd18:	6b0100bf 	cmp	w5, w1
    fd1c:	54fffe40 	b.eq	fce4 <__any_on+0x24>  // b.none
    fd20:	d65f03c0 	ret
    fd24:	52800020 	mov	w0, #0x1                   	// #1
    fd28:	d65f03c0 	ret
    fd2c:	00000000 	udf	#0

000000000000fd30 <_calloc_r>:
    fd30:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    fd34:	9bc27c23 	umulh	x3, x1, x2
    fd38:	9b027c21 	mul	x1, x1, x2
    fd3c:	910003fd 	mov	x29, sp
    fd40:	f9000bf3 	str	x19, [sp, #16]
    fd44:	b5000463 	cbnz	x3, fdd0 <_calloc_r+0xa0>
    fd48:	97ffe3c6 	bl	8c60 <_malloc_r>
    fd4c:	aa0003f3 	mov	x19, x0
    fd50:	b4000460 	cbz	x0, fddc <_calloc_r+0xac>
    fd54:	f85f8002 	ldur	x2, [x0, #-8]
    fd58:	927ef442 	and	x2, x2, #0xfffffffffffffffc
    fd5c:	d1002042 	sub	x2, x2, #0x8
    fd60:	f101205f 	cmp	x2, #0x48
    fd64:	540001c8 	b.hi	fd9c <_calloc_r+0x6c>  // b.pmore
    fd68:	f1009c5f 	cmp	x2, #0x27
    fd6c:	540000c9 	b.ls	fd84 <_calloc_r+0x54>  // b.plast
    fd70:	4f000400 	movi	v0.4s, #0x0
    fd74:	91004000 	add	x0, x0, #0x10
    fd78:	3c9f0000 	stur	q0, [x0, #-16]
    fd7c:	f100dc5f 	cmp	x2, #0x37
    fd80:	540001a8 	b.hi	fdb4 <_calloc_r+0x84>  // b.pmore
    fd84:	a9007c1f 	stp	xzr, xzr, [x0]
    fd88:	f900081f 	str	xzr, [x0, #16]
    fd8c:	aa1303e0 	mov	x0, x19
    fd90:	f9400bf3 	ldr	x19, [sp, #16]
    fd94:	a8c27bfd 	ldp	x29, x30, [sp], #32
    fd98:	d65f03c0 	ret
    fd9c:	52800001 	mov	w1, #0x0                   	// #0
    fda0:	97ffeb58 	bl	ab00 <memset>
    fda4:	aa1303e0 	mov	x0, x19
    fda8:	f9400bf3 	ldr	x19, [sp, #16]
    fdac:	a8c27bfd 	ldp	x29, x30, [sp], #32
    fdb0:	d65f03c0 	ret
    fdb4:	3d800660 	str	q0, [x19, #16]
    fdb8:	91008260 	add	x0, x19, #0x20
    fdbc:	f101205f 	cmp	x2, #0x48
    fdc0:	54fffe21 	b.ne	fd84 <_calloc_r+0x54>  // b.any
    fdc4:	9100c260 	add	x0, x19, #0x30
    fdc8:	3d800a60 	str	q0, [x19, #32]
    fdcc:	17ffffee 	b	fd84 <_calloc_r+0x54>
    fdd0:	97ffcb4c 	bl	2b00 <__errno>
    fdd4:	52800181 	mov	w1, #0xc                   	// #12
    fdd8:	b9000001 	str	w1, [x0]
    fddc:	d2800013 	mov	x19, #0x0                   	// #0
    fde0:	aa1303e0 	mov	x0, x19
    fde4:	f9400bf3 	ldr	x19, [sp, #16]
    fde8:	a8c27bfd 	ldp	x29, x30, [sp], #32
    fdec:	d65f03c0 	ret

000000000000fdf0 <_wcsnrtombs_l>:
    fdf0:	a9b87bfd 	stp	x29, x30, [sp, #-128]!
    fdf4:	f10000bf 	cmp	x5, #0x0
    fdf8:	910003fd 	mov	x29, sp
    fdfc:	a90153f3 	stp	x19, x20, [sp, #16]
    fe00:	aa0003f4 	mov	x20, x0
    fe04:	91051000 	add	x0, x0, #0x144
    fe08:	a9025bf5 	stp	x21, x22, [sp, #32]
    fe0c:	aa0203f6 	mov	x22, x2
    fe10:	aa0103f5 	mov	x21, x1
    fe14:	a90363f7 	stp	x23, x24, [sp, #48]
    fe18:	aa0603f7 	mov	x23, x6
    fe1c:	a9046bf9 	stp	x25, x26, [sp, #64]
    fe20:	9a850019 	csel	x25, x0, x5, eq	// eq = none
    fe24:	a90573fb 	stp	x27, x28, [sp, #80]
    fe28:	f940005c 	ldr	x28, [x2]
    fe2c:	b4000901 	cbz	x1, ff4c <_wcsnrtombs_l+0x15c>
    fe30:	aa0403f3 	mov	x19, x4
    fe34:	b4000a84 	cbz	x4, ff84 <_wcsnrtombs_l+0x194>
    fe38:	d100047a 	sub	x26, x3, #0x1
    fe3c:	b4000a43 	cbz	x3, ff84 <_wcsnrtombs_l+0x194>
    fe40:	d280001b 	mov	x27, #0x0                   	// #0
    fe44:	f90037f5 	str	x21, [sp, #104]
    fe48:	1400000a 	b	fe70 <_wcsnrtombs_l+0x80>
    fe4c:	b50003f5 	cbnz	x21, fec8 <_wcsnrtombs_l+0xd8>
    fe50:	b8404780 	ldr	w0, [x28], #4
    fe54:	34000640 	cbz	w0, ff1c <_wcsnrtombs_l+0x12c>
    fe58:	eb13009f 	cmp	x4, x19
    fe5c:	54000982 	b.cs	ff8c <_wcsnrtombs_l+0x19c>  // b.hs, b.nlast
    fe60:	d100075a 	sub	x26, x26, #0x1
    fe64:	aa0403fb 	mov	x27, x4
    fe68:	b100075f 	cmn	x26, #0x1
    fe6c:	540001e0 	b.eq	fea8 <_wcsnrtombs_l+0xb8>  // b.none
    fe70:	f94072e4 	ldr	x4, [x23, #224]
    fe74:	aa1903e3 	mov	x3, x25
    fe78:	b9400382 	ldr	w2, [x28]
    fe7c:	9101c3e1 	add	x1, sp, #0x70
    fe80:	f9400338 	ldr	x24, [x25]
    fe84:	aa1403e0 	mov	x0, x20
    fe88:	d63f0080 	blr	x4
    fe8c:	3100041f 	cmn	w0, #0x1
    fe90:	54000620 	b.eq	ff54 <_wcsnrtombs_l+0x164>  // b.none
    fe94:	93407c01 	sxtw	x1, w0
    fe98:	8b1b0024 	add	x4, x1, x27
    fe9c:	eb13009f 	cmp	x4, x19
    fea0:	54fffd69 	b.ls	fe4c <_wcsnrtombs_l+0x5c>  // b.plast
    fea4:	f9000338 	str	x24, [x25]
    fea8:	a94153f3 	ldp	x19, x20, [sp, #16]
    feac:	aa1b03e0 	mov	x0, x27
    feb0:	a9425bf5 	ldp	x21, x22, [sp, #32]
    feb4:	a94363f7 	ldp	x23, x24, [sp, #48]
    feb8:	a9446bf9 	ldp	x25, x26, [sp, #64]
    febc:	a94573fb 	ldp	x27, x28, [sp, #80]
    fec0:	a8c87bfd 	ldp	x29, x30, [sp], #128
    fec4:	d65f03c0 	ret
    fec8:	7100001f 	cmp	w0, #0x0
    fecc:	540001ed 	b.le	ff08 <_wcsnrtombs_l+0x118>
    fed0:	f94037e2 	ldr	x2, [sp, #104]
    fed4:	d2800027 	mov	x7, #0x1                   	// #1
    fed8:	d1000443 	sub	x3, x2, #0x1
    fedc:	d503201f 	nop
    fee0:	9101c3e2 	add	x2, sp, #0x70
    fee4:	eb07003f 	cmp	x1, x7
    fee8:	8b070042 	add	x2, x2, x7
    feec:	385ff042 	ldurb	w2, [x2, #-1]
    fef0:	38276862 	strb	w2, [x3, x7]
    fef4:	910004e7 	add	x7, x7, #0x1
    fef8:	54ffff41 	b.ne	fee0 <_wcsnrtombs_l+0xf0>  // b.any
    fefc:	f94037e1 	ldr	x1, [sp, #104]
    ff00:	8b204020 	add	x0, x1, w0, uxtw
    ff04:	f90037e0 	str	x0, [sp, #104]
    ff08:	f94002c0 	ldr	x0, [x22]
    ff0c:	91001000 	add	x0, x0, #0x4
    ff10:	f90002c0 	str	x0, [x22]
    ff14:	b8404780 	ldr	w0, [x28], #4
    ff18:	35fffa00 	cbnz	w0, fe58 <_wcsnrtombs_l+0x68>
    ff1c:	b4000055 	cbz	x21, ff24 <_wcsnrtombs_l+0x134>
    ff20:	f90002df 	str	xzr, [x22]
    ff24:	b900033f 	str	wzr, [x25]
    ff28:	d100049b 	sub	x27, x4, #0x1
    ff2c:	a94153f3 	ldp	x19, x20, [sp, #16]
    ff30:	aa1b03e0 	mov	x0, x27
    ff34:	a9425bf5 	ldp	x21, x22, [sp, #32]
    ff38:	a94363f7 	ldp	x23, x24, [sp, #48]
    ff3c:	a9446bf9 	ldp	x25, x26, [sp, #64]
    ff40:	a94573fb 	ldp	x27, x28, [sp, #80]
    ff44:	a8c87bfd 	ldp	x29, x30, [sp], #128
    ff48:	d65f03c0 	ret
    ff4c:	92800013 	mov	x19, #0xffffffffffffffff    	// #-1
    ff50:	17ffffba 	b	fe38 <_wcsnrtombs_l+0x48>
    ff54:	52801140 	mov	w0, #0x8a                  	// #138
    ff58:	b9000280 	str	w0, [x20]
    ff5c:	b900033f 	str	wzr, [x25]
    ff60:	9280001b 	mov	x27, #0xffffffffffffffff    	// #-1
    ff64:	a94153f3 	ldp	x19, x20, [sp, #16]
    ff68:	aa1b03e0 	mov	x0, x27
    ff6c:	a9425bf5 	ldp	x21, x22, [sp, #32]
    ff70:	a94363f7 	ldp	x23, x24, [sp, #48]
    ff74:	a9446bf9 	ldp	x25, x26, [sp, #64]
    ff78:	a94573fb 	ldp	x27, x28, [sp, #80]
    ff7c:	a8c87bfd 	ldp	x29, x30, [sp], #128
    ff80:	d65f03c0 	ret
    ff84:	d280001b 	mov	x27, #0x0                   	// #0
    ff88:	17ffffc8 	b	fea8 <_wcsnrtombs_l+0xb8>
    ff8c:	aa0403fb 	mov	x27, x4
    ff90:	17ffffc6 	b	fea8 <_wcsnrtombs_l+0xb8>
	...

000000000000ffa0 <_wcsnrtombs_r>:
    ffa0:	d0000000 	adrp	x0, 11000 <JIS_action_table>
    ffa4:	d0000006 	adrp	x6, 11000 <JIS_action_table>
    ffa8:	913400c6 	add	x6, x6, #0xd00
    ffac:	f9413c00 	ldr	x0, [x0, #632]
    ffb0:	17ffff90 	b	fdf0 <_wcsnrtombs_l>
	...

000000000000ffc0 <wcsnrtombs>:
    ffc0:	d0000006 	adrp	x6, 11000 <JIS_action_table>
    ffc4:	aa0003e8 	mov	x8, x0
    ffc8:	aa0103e7 	mov	x7, x1
    ffcc:	aa0203e5 	mov	x5, x2
    ffd0:	f9413cc0 	ldr	x0, [x6, #632]
    ffd4:	aa0303e6 	mov	x6, x3
    ffd8:	aa0803e1 	mov	x1, x8
    ffdc:	aa0503e3 	mov	x3, x5
    ffe0:	aa0703e2 	mov	x2, x7
    ffe4:	aa0403e5 	mov	x5, x4
    ffe8:	aa0603e4 	mov	x4, x6
    ffec:	d0000006 	adrp	x6, 11000 <JIS_action_table>
    fff0:	913400c6 	add	x6, x6, #0xd00
    fff4:	17ffff7f 	b	fdf0 <_wcsnrtombs_l>
	...

0000000000010000 <__env_lock>:
   10000:	90001f80 	adrp	x0, 400000 <__sf+0x10>
   10004:	9109e000 	add	x0, x0, #0x278
   10008:	17ffe58a 	b	9630 <__retarget_lock_acquire_recursive>
   1000c:	00000000 	udf	#0

0000000000010010 <__env_unlock>:
   10010:	90001f80 	adrp	x0, 400000 <__sf+0x10>
   10014:	9109e000 	add	x0, x0, #0x278
   10018:	17ffe596 	b	9670 <__retarget_lock_release_recursive>
   1001c:	00000000 	udf	#0

0000000000010020 <__trunctfdf2>:
   10020:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   10024:	9e660002 	fmov	x2, d0
   10028:	9eae0003 	fmov	x3, v0.d[1]
   1002c:	910003fd 	mov	x29, sp
   10030:	f9000bf3 	str	x19, [sp, #16]
   10034:	d53b4405 	mrs	x5, fpcr
   10038:	aa0303e0 	mov	x0, x3
   1003c:	d37ffc63 	lsr	x3, x3, #63
   10040:	aa0303f3 	mov	x19, x3
   10044:	12001c66 	and	w6, w3, #0xff
   10048:	d370f801 	ubfx	x1, x0, #48, #15
   1004c:	d37dbc00 	ubfiz	x0, x0, #3, #48
   10050:	91000424 	add	x4, x1, #0x1
   10054:	aa0303e7 	mov	x7, x3
   10058:	aa42f400 	orr	x0, x0, x2, lsr #61
   1005c:	d37df043 	lsl	x3, x2, #3
   10060:	f27f349f 	tst	x4, #0x7ffe
   10064:	54000700 	b.eq	10144 <__trunctfdf2+0x124>  // b.none
   10068:	92877fe4 	mov	x4, #0xffffffffffffc400    	// #-15360
   1006c:	8b040024 	add	x4, x1, x4
   10070:	f11ff89f 	cmp	x4, #0x7fe
   10074:	540003ad 	b.le	100e8 <__trunctfdf2+0xc8>
   10078:	f26a04a5 	ands	x5, x5, #0xc00000
   1007c:	5280ffe0 	mov	w0, #0x7ff                 	// #2047
   10080:	54000240 	b.eq	100c8 <__trunctfdf2+0xa8>  // b.none
   10084:	f15000bf 	cmp	x5, #0x400, lsl #12
   10088:	54001520 	b.eq	1032c <__trunctfdf2+0x30c>  // b.none
   1008c:	f16000bf 	cmp	x5, #0x800, lsl #12
   10090:	1a9f17e1 	cset	w1, eq	// eq = none
   10094:	6a0100df 	tst	w6, w1
   10098:	54001681 	b.ne	10368 <__trunctfdf2+0x348>  // b.any
   1009c:	f15000bf 	cmp	x5, #0x400, lsl #12
   100a0:	540014a0 	b.eq	10334 <__trunctfdf2+0x314>  // b.none
   100a4:	f16000bf 	cmp	x5, #0x800, lsl #12
   100a8:	5280ffc0 	mov	w0, #0x7fe                 	// #2046
   100ac:	1a9f17e1 	cset	w1, eq	// eq = none
   100b0:	5280ffe2 	mov	w2, #0x7ff                 	// #2047
   100b4:	6a0100c1 	ands	w1, w6, w1
   100b8:	92fc0005 	mov	x5, #0x1fffffffffffffff    	// #2305843009213693951
   100bc:	1a820000 	csel	w0, w0, w2, eq	// eq = none
   100c0:	9a9f00a5 	csel	x5, x5, xzr, eq	// eq = none
   100c4:	d503201f 	nop
   100c8:	b34c2c05 	bfi	x5, x0, #52, #12
   100cc:	52800280 	mov	w0, #0x14                  	// #20
   100d0:	aa13fcb3 	orr	x19, x5, x19, lsl #63
   100d4:	940000c3 	bl	103e0 <__sfp_handle_exceptions>
   100d8:	9e670260 	fmov	d0, x19
   100dc:	f9400bf3 	ldr	x19, [sp, #16]
   100e0:	a8c27bfd 	ldp	x29, x30, [sp], #32
   100e4:	d65f03c0 	ret
   100e8:	f100009f 	cmp	x4, #0x0
   100ec:	540007ed 	b.le	101e8 <__trunctfdf2+0x1c8>
   100f0:	eb021fff 	cmp	xzr, x2, lsl #7
   100f4:	52800007 	mov	w7, #0x0                   	// #0
   100f8:	9a9f07e1 	cset	x1, ne	// ne = any
   100fc:	aa43f023 	orr	x3, x1, x3, lsr #60
   10100:	aa001061 	orr	x1, x3, x0, lsl #4
   10104:	92400863 	and	x3, x3, #0x7
   10108:	b4001423 	cbz	x3, 1038c <__trunctfdf2+0x36c>
   1010c:	926a04a5 	and	x5, x5, #0xc00000
   10110:	f15000bf 	cmp	x5, #0x400, lsl #12
   10114:	54000ac0 	b.eq	1026c <__trunctfdf2+0x24c>  // b.none
   10118:	f16000bf 	cmp	x5, #0x800, lsl #12
   1011c:	54000fe0 	b.eq	10318 <__trunctfdf2+0x2f8>  // b.none
   10120:	b40008c5 	cbz	x5, 10238 <__trunctfdf2+0x218>
   10124:	35000c87 	cbnz	w7, 102b4 <__trunctfdf2+0x294>
   10128:	d343fc21 	lsr	x1, x1, #3
   1012c:	12002887 	and	w7, w4, #0x7ff
   10130:	52800200 	mov	w0, #0x10                  	// #16
   10134:	b34c2ce1 	bfi	x1, x7, #52, #12
   10138:	aa13fc33 	orr	x19, x1, x19, lsl #63
   1013c:	940000a9 	bl	103e0 <__sfp_handle_exceptions>
   10140:	17ffffe6 	b	100d8 <__trunctfdf2+0xb8>
   10144:	aa030002 	orr	x2, x0, x3
   10148:	b50001c1 	cbnz	x1, 10180 <__trunctfdf2+0x160>
   1014c:	b40004a2 	cbz	x2, 101e0 <__trunctfdf2+0x1c0>
   10150:	926a04a0 	and	x0, x5, #0xc00000
   10154:	f150001f 	cmp	x0, #0x400, lsl #12
   10158:	54000fc0 	b.eq	10350 <__trunctfdf2+0x330>  // b.none
   1015c:	f160001f 	cmp	x0, #0x800, lsl #12
   10160:	54000ae0 	b.eq	102bc <__trunctfdf2+0x29c>  // b.none
   10164:	b4000a40 	cbz	x0, 102ac <__trunctfdf2+0x28c>
   10168:	d2800007 	mov	x7, #0x0                   	// #0
   1016c:	d2800021 	mov	x1, #0x1                   	// #1
   10170:	d343fc21 	lsr	x1, x1, #3
   10174:	120028e7 	and	w7, w7, #0x7ff
   10178:	52800300 	mov	w0, #0x18                  	// #24
   1017c:	17ffffee 	b	10134 <__trunctfdf2+0x114>
   10180:	b4000222 	cbz	x2, 101c4 <__trunctfdf2+0x1a4>
   10184:	d28fffe2 	mov	x2, #0x7fff                	// #32767
   10188:	93c3f003 	extr	x3, x0, x3, #60
   1018c:	d372fc00 	lsr	x0, x0, #50
   10190:	eb02003f 	cmp	x1, x2
   10194:	d343fc63 	lsr	x3, x3, #3
   10198:	52000000 	eor	w0, w0, #0x1
   1019c:	b24d0061 	orr	x1, x3, #0x8000000000000
   101a0:	1a9f0000 	csel	w0, w0, wzr, eq	// eq = none
   101a4:	5280ffe2 	mov	w2, #0x7ff                 	// #2047
   101a8:	aa02d021 	orr	x1, x1, x2, lsl #52
   101ac:	aa13fc33 	orr	x19, x1, x19, lsl #63
   101b0:	35fff920 	cbnz	w0, 100d4 <__trunctfdf2+0xb4>
   101b4:	9e670260 	fmov	d0, x19
   101b8:	f9400bf3 	ldr	x19, [sp, #16]
   101bc:	a8c27bfd 	ldp	x29, x30, [sp], #32
   101c0:	d65f03c0 	ret
   101c4:	5280ffe0 	mov	w0, #0x7ff                 	// #2047
   101c8:	d34c2c00 	lsl	x0, x0, #52
   101cc:	aa13fc13 	orr	x19, x0, x19, lsl #63
   101d0:	9e670260 	fmov	d0, x19
   101d4:	f9400bf3 	ldr	x19, [sp, #16]
   101d8:	a8c27bfd 	ldp	x29, x30, [sp], #32
   101dc:	d65f03c0 	ret
   101e0:	52800000 	mov	w0, #0x0                   	// #0
   101e4:	17fffff9 	b	101c8 <__trunctfdf2+0x1a8>
   101e8:	b100d09f 	cmn	x4, #0x34
   101ec:	54fffb2b 	b.lt	10150 <__trunctfdf2+0x130>  // b.tstop
   101f0:	d28007a2 	mov	x2, #0x3d                  	// #61
   101f4:	cb040047 	sub	x7, x2, x4
   101f8:	b24d0000 	orr	x0, x0, #0x8000000000000
   101fc:	f100fcff 	cmp	x7, #0x3f
   10200:	540006ec 	b.gt	102dc <__trunctfdf2+0x2bc>
   10204:	11000c81 	add	w1, w4, #0x3
   10208:	4b040042 	sub	w2, w2, w4
   1020c:	52800027 	mov	w7, #0x1                   	// #1
   10210:	d2800004 	mov	x4, #0x0                   	// #0
   10214:	9ac12068 	lsl	x8, x3, x1
   10218:	f100011f 	cmp	x8, #0x0
   1021c:	9a9f07e8 	cset	x8, ne	// ne = any
   10220:	9ac22463 	lsr	x3, x3, x2
   10224:	aa080063 	orr	x3, x3, x8
   10228:	9ac12000 	lsl	x0, x0, x1
   1022c:	aa030001 	orr	x1, x0, x3
   10230:	92400823 	and	x3, x1, #0x7
   10234:	17ffffb5 	b	10108 <__trunctfdf2+0xe8>
   10238:	92400c20 	and	x0, x1, #0xf
   1023c:	f100101f 	cmp	x0, #0x4
   10240:	54fff720 	b.eq	10124 <__trunctfdf2+0x104>  // b.none
   10244:	91001021 	add	x1, x1, #0x4
   10248:	92490020 	and	x0, x1, #0x80000000000000
   1024c:	35000187 	cbnz	w7, 1027c <__trunctfdf2+0x25c>
   10250:	b4fff6c0 	cbz	x0, 10128 <__trunctfdf2+0x108>
   10254:	91000482 	add	x2, x4, #0x1
   10258:	f11ff89f 	cmp	x4, #0x7fe
   1025c:	540008a1 	b.ne	10370 <__trunctfdf2+0x350>  // b.any
   10260:	2a0203e0 	mov	w0, w2
   10264:	b4fff325 	cbz	x5, 100c8 <__trunctfdf2+0xa8>
   10268:	17ffff8d 	b	1009c <__trunctfdf2+0x7c>
   1026c:	b5fff5d3 	cbnz	x19, 10124 <__trunctfdf2+0x104>
   10270:	91002021 	add	x1, x1, #0x8
   10274:	92490020 	and	x0, x1, #0x80000000000000
   10278:	34fffec7 	cbz	w7, 10250 <__trunctfdf2+0x230>
   1027c:	b40001c0 	cbz	x0, 102b4 <__trunctfdf2+0x294>
   10280:	92fc0200 	mov	x0, #0x1fefffffffffffff    	// #2301339409586323455
   10284:	f11ff89f 	cmp	x4, #0x7fe
   10288:	8a410c01 	and	x1, x0, x1, lsr #3
   1028c:	91000482 	add	x2, x4, #0x1
   10290:	fa400824 	ccmp	x1, #0x0, #0x4, eq	// eq = none
   10294:	54000900 	b.eq	103b4 <__trunctfdf2+0x394>  // b.none
   10298:	b24d2c21 	orr	x1, x1, #0x7ff8000000000000
   1029c:	52800300 	mov	w0, #0x18                  	// #24
   102a0:	aa13fc33 	orr	x19, x1, x19, lsl #63
   102a4:	9400004f 	bl	103e0 <__sfp_handle_exceptions>
   102a8:	17ffff8c 	b	100d8 <__trunctfdf2+0xb8>
   102ac:	d28000a1 	mov	x1, #0x5                   	// #5
   102b0:	d2800004 	mov	x4, #0x0                   	// #0
   102b4:	aa0403e7 	mov	x7, x4
   102b8:	17ffffae 	b	10170 <__trunctfdf2+0x150>
   102bc:	d2800021 	mov	x1, #0x1                   	// #1
   102c0:	b5000093 	cbnz	x19, 102d0 <__trunctfdf2+0x2b0>
   102c4:	aa0703e4 	mov	x4, x7
   102c8:	aa0403e7 	mov	x7, x4
   102cc:	17ffffa9 	b	10170 <__trunctfdf2+0x150>
   102d0:	d2800007 	mov	x7, #0x0                   	// #0
   102d4:	d2800121 	mov	x1, #0x9                   	// #9
   102d8:	17ffffa6 	b	10170 <__trunctfdf2+0x150>
   102dc:	11010c81 	add	w1, w4, #0x43
   102e0:	f10100ff 	cmp	x7, #0x40
   102e4:	12800042 	mov	w2, #0xfffffffd            	// #-3
   102e8:	4b040042 	sub	w2, w2, w4
   102ec:	9ac12001 	lsl	x1, x0, x1
   102f0:	aa010061 	orr	x1, x3, x1
   102f4:	9a831023 	csel	x3, x1, x3, ne	// ne = any
   102f8:	9ac22400 	lsr	x0, x0, x2
   102fc:	f100007f 	cmp	x3, #0x0
   10300:	52800027 	mov	w7, #0x1                   	// #1
   10304:	9a9f07e1 	cset	x1, ne	// ne = any
   10308:	d2800004 	mov	x4, #0x0                   	// #0
   1030c:	aa000021 	orr	x1, x1, x0
   10310:	92400823 	and	x3, x1, #0x7
   10314:	17ffff7d 	b	10108 <__trunctfdf2+0xe8>
   10318:	b5fffad3 	cbnz	x19, 10270 <__trunctfdf2+0x250>
   1031c:	34fff067 	cbz	w7, 10128 <__trunctfdf2+0x108>
   10320:	aa0403e7 	mov	x7, x4
   10324:	aa0703e4 	mov	x4, x7
   10328:	17ffffe8 	b	102c8 <__trunctfdf2+0x2a8>
   1032c:	d2800005 	mov	x5, #0x0                   	// #0
   10330:	b4ffecd3 	cbz	x19, 100c8 <__trunctfdf2+0xa8>
   10334:	f100027f 	cmp	x19, #0x0
   10338:	5280ffc0 	mov	w0, #0x7fe                 	// #2046
   1033c:	5280ffe1 	mov	w1, #0x7ff                 	// #2047
   10340:	92fc0005 	mov	x5, #0x1fffffffffffffff    	// #2305843009213693951
   10344:	1a811000 	csel	w0, w0, w1, ne	// ne = any
   10348:	9a9f10a5 	csel	x5, x5, xzr, ne	// ne = any
   1034c:	17ffff5f 	b	100c8 <__trunctfdf2+0xa8>
   10350:	d2800121 	mov	x1, #0x9                   	// #9
   10354:	b4fff0f3 	cbz	x19, 10170 <__trunctfdf2+0x150>
   10358:	d2800004 	mov	x4, #0x0                   	// #0
   1035c:	d2800021 	mov	x1, #0x1                   	// #1
   10360:	aa0403e7 	mov	x7, x4
   10364:	17ffff83 	b	10170 <__trunctfdf2+0x150>
   10368:	d2800005 	mov	x5, #0x0                   	// #0
   1036c:	17ffff57 	b	100c8 <__trunctfdf2+0xa8>
   10370:	92fc0203 	mov	x3, #0x1fefffffffffffff    	// #2301339409586323455
   10374:	52800200 	mov	w0, #0x10                  	// #16
   10378:	8a410c61 	and	x1, x3, x1, lsr #3
   1037c:	aa02d022 	orr	x2, x1, x2, lsl #52
   10380:	aa13fc53 	orr	x19, x2, x19, lsl #63
   10384:	94000017 	bl	103e0 <__sfp_handle_exceptions>
   10388:	17ffff54 	b	100d8 <__trunctfdf2+0xb8>
   1038c:	d343fc21 	lsr	x1, x1, #3
   10390:	12002882 	and	w2, w4, #0x7ff
   10394:	34000167 	cbz	w7, 103c0 <__trunctfdf2+0x3a0>
   10398:	52800000 	mov	w0, #0x0                   	// #0
   1039c:	365ff065 	tbz	w5, #11, 101a8 <__trunctfdf2+0x188>
   103a0:	52800100 	mov	w0, #0x8                   	// #8
   103a4:	aa02d021 	orr	x1, x1, x2, lsl #52
   103a8:	aa13fc33 	orr	x19, x1, x19, lsl #63
   103ac:	9400000d 	bl	103e0 <__sfp_handle_exceptions>
   103b0:	17ffff4a 	b	100d8 <__trunctfdf2+0xb8>
   103b4:	12002842 	and	w2, w2, #0x7ff
   103b8:	52800300 	mov	w0, #0x18                  	// #24
   103bc:	17fffffa 	b	103a4 <__trunctfdf2+0x384>
   103c0:	d2800013 	mov	x19, #0x0                   	// #0
   103c4:	b340cc33 	bfxil	x19, x1, #0, #52
   103c8:	b34c2853 	bfi	x19, x2, #52, #11
   103cc:	b34100d3 	bfi	x19, x6, #63, #1
   103d0:	17ffff79 	b	101b4 <__trunctfdf2+0x194>
	...

00000000000103e0 <__sfp_handle_exceptions>:
   103e0:	36000080 	tbz	w0, #0, 103f0 <__sfp_handle_exceptions+0x10>
   103e4:	0f000401 	movi	v1.2s, #0x0
   103e8:	1e211820 	fdiv	s0, s1, s1
   103ec:	d53b4421 	mrs	x1, fpsr
   103f0:	360800a0 	tbz	w0, #1, 10404 <__sfp_handle_exceptions+0x24>
   103f4:	1e2e1001 	fmov	s1, #1.000000000000000000e+00
   103f8:	0f000402 	movi	v2.2s, #0x0
   103fc:	1e221820 	fdiv	s0, s1, s2
   10400:	d53b4421 	mrs	x1, fpsr
   10404:	36100100 	tbz	w0, #2, 10424 <__sfp_handle_exceptions+0x44>
   10408:	5298b5c2 	mov	w2, #0xc5ae                	// #50606
   1040c:	12b01001 	mov	w1, #0x7f7fffff            	// #2139095039
   10410:	72ae93a2 	movk	w2, #0x749d, lsl #16
   10414:	1e270021 	fmov	s1, w1
   10418:	1e270042 	fmov	s2, w2
   1041c:	1e222820 	fadd	s0, s1, s2
   10420:	d53b4421 	mrs	x1, fpsr
   10424:	36180080 	tbz	w0, #3, 10434 <__sfp_handle_exceptions+0x54>
   10428:	0f044401 	movi	v1.2s, #0x80, lsl #16
   1042c:	1e210820 	fmul	s0, s1, s1
   10430:	d53b4421 	mrs	x1, fpsr
   10434:	362000c0 	tbz	w0, #4, 1044c <__sfp_handle_exceptions+0x6c>
   10438:	12b01000 	mov	w0, #0x7f7fffff            	// #2139095039
   1043c:	1e2e1002 	fmov	s2, #1.000000000000000000e+00
   10440:	1e270001 	fmov	s1, w0
   10444:	1e223820 	fsub	s0, s1, s2
   10448:	d53b4420 	mrs	x0, fpsr
   1044c:	d65f03c0 	ret
