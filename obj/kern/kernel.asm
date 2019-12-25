
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5e 00 00 00       	call   f010009c <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 3e 21 f0 00 	cmpl   $0x0,0xf0213e80
f010004f:	74 0f                	je     f0100060 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100051:	83 ec 0c             	sub    $0xc,%esp
f0100054:	6a 00                	push   $0x0
f0100056:	e8 0f 09 00 00       	call   f010096a <monitor>
f010005b:	83 c4 10             	add    $0x10,%esp
f010005e:	eb f1                	jmp    f0100051 <_panic+0x11>
	panicstr = fmt;
f0100060:	89 35 80 3e 21 f0    	mov    %esi,0xf0213e80
	asm volatile("cli; cld");
f0100066:	fa                   	cli    
f0100067:	fc                   	cld    
	va_start(ap, fmt);
f0100068:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006b:	e8 cb 5b 00 00       	call   f0105c3b <cpunum>
f0100070:	ff 75 0c             	pushl  0xc(%ebp)
f0100073:	ff 75 08             	pushl  0x8(%ebp)
f0100076:	50                   	push   %eax
f0100077:	68 80 62 10 f0       	push   $0xf0106280
f010007c:	e8 2e 38 00 00       	call   f01038af <cprintf>
	vcprintf(fmt, ap);
f0100081:	83 c4 08             	add    $0x8,%esp
f0100084:	53                   	push   %ebx
f0100085:	56                   	push   %esi
f0100086:	e8 fe 37 00 00       	call   f0103889 <vcprintf>
	cprintf("\n");
f010008b:	c7 04 24 29 74 10 f0 	movl   $0xf0107429,(%esp)
f0100092:	e8 18 38 00 00       	call   f01038af <cprintf>
f0100097:	83 c4 10             	add    $0x10,%esp
f010009a:	eb b5                	jmp    f0100051 <_panic+0x11>

f010009c <i386_init>:
{
f010009c:	55                   	push   %ebp
f010009d:	89 e5                	mov    %esp,%ebp
f010009f:	53                   	push   %ebx
f01000a0:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a3:	e8 ae 05 00 00       	call   f0100656 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a8:	83 ec 08             	sub    $0x8,%esp
f01000ab:	68 ac 1a 00 00       	push   $0x1aac
f01000b0:	68 ec 62 10 f0       	push   $0xf01062ec
f01000b5:	e8 f5 37 00 00       	call   f01038af <cprintf>
	mem_init();
f01000ba:	e8 3e 12 00 00       	call   f01012fd <mem_init>
	env_init();
f01000bf:	e8 49 30 00 00       	call   f010310d <env_init>
	trap_init();
f01000c4:	e8 ca 38 00 00       	call   f0103993 <trap_init>
	mp_init();
f01000c9:	e8 5b 58 00 00       	call   f0105929 <mp_init>
	lapic_init();
f01000ce:	e8 82 5b 00 00       	call   f0105c55 <lapic_init>
	pic_init();
f01000d3:	e8 fa 36 00 00       	call   f01037d2 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d8:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01000df:	e8 c7 5d 00 00       	call   f0105eab <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e4:	83 c4 10             	add    $0x10,%esp
f01000e7:	83 3d 88 3e 21 f0 07 	cmpl   $0x7,0xf0213e88
f01000ee:	76 27                	jbe    f0100117 <i386_init+0x7b>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f0:	83 ec 04             	sub    $0x4,%esp
f01000f3:	b8 8e 58 10 f0       	mov    $0xf010588e,%eax
f01000f8:	2d 14 58 10 f0       	sub    $0xf0105814,%eax
f01000fd:	50                   	push   %eax
f01000fe:	68 14 58 10 f0       	push   $0xf0105814
f0100103:	68 00 70 00 f0       	push   $0xf0007000
f0100108:	e8 56 55 00 00       	call   f0105663 <memmove>
f010010d:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f0100110:	bb 20 40 21 f0       	mov    $0xf0214020,%ebx
f0100115:	eb 19                	jmp    f0100130 <i386_init+0x94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100117:	68 00 70 00 00       	push   $0x7000
f010011c:	68 a4 62 10 f0       	push   $0xf01062a4
f0100121:	6a 52                	push   $0x52
f0100123:	68 07 63 10 f0       	push   $0xf0106307
f0100128:	e8 13 ff ff ff       	call   f0100040 <_panic>
f010012d:	83 c3 74             	add    $0x74,%ebx
f0100130:	6b 05 c4 43 21 f0 74 	imul   $0x74,0xf02143c4,%eax
f0100137:	05 20 40 21 f0       	add    $0xf0214020,%eax
f010013c:	39 c3                	cmp    %eax,%ebx
f010013e:	73 4c                	jae    f010018c <i386_init+0xf0>
		if (c == cpus + cpunum())  // We've started already.
f0100140:	e8 f6 5a 00 00       	call   f0105c3b <cpunum>
f0100145:	6b c0 74             	imul   $0x74,%eax,%eax
f0100148:	05 20 40 21 f0       	add    $0xf0214020,%eax
f010014d:	39 c3                	cmp    %eax,%ebx
f010014f:	74 dc                	je     f010012d <i386_init+0x91>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100151:	89 d8                	mov    %ebx,%eax
f0100153:	2d 20 40 21 f0       	sub    $0xf0214020,%eax
f0100158:	c1 f8 02             	sar    $0x2,%eax
f010015b:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100161:	c1 e0 0f             	shl    $0xf,%eax
f0100164:	05 00 d0 21 f0       	add    $0xf021d000,%eax
f0100169:	a3 84 3e 21 f0       	mov    %eax,0xf0213e84
		lapic_startap(c->cpu_id, PADDR(code));
f010016e:	83 ec 08             	sub    $0x8,%esp
f0100171:	68 00 70 00 00       	push   $0x7000
f0100176:	0f b6 03             	movzbl (%ebx),%eax
f0100179:	50                   	push   %eax
f010017a:	e8 27 5c 00 00       	call   f0105da6 <lapic_startap>
f010017f:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f0100182:	8b 43 04             	mov    0x4(%ebx),%eax
f0100185:	83 f8 01             	cmp    $0x1,%eax
f0100188:	75 f8                	jne    f0100182 <i386_init+0xe6>
f010018a:	eb a1                	jmp    f010012d <i386_init+0x91>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010018c:	83 ec 08             	sub    $0x8,%esp
f010018f:	6a 01                	push   $0x1
f0100191:	68 a8 18 1d f0       	push   $0xf01d18a8
f0100196:	e8 2f 31 00 00       	call   f01032ca <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010019b:	83 c4 08             	add    $0x8,%esp
f010019e:	6a 00                	push   $0x0
f01001a0:	68 50 28 20 f0       	push   $0xf0202850
f01001a5:	e8 20 31 00 00       	call   f01032ca <env_create>
	kbd_intr();
f01001aa:	e8 4c 04 00 00       	call   f01005fb <kbd_intr>
	sched_yield();
f01001af:	e8 c3 42 00 00       	call   f0104477 <sched_yield>

f01001b4 <mp_main>:
{
f01001b4:	55                   	push   %ebp
f01001b5:	89 e5                	mov    %esp,%ebp
f01001b7:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001ba:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001bf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c4:	77 12                	ja     f01001d8 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c6:	50                   	push   %eax
f01001c7:	68 c8 62 10 f0       	push   $0xf01062c8
f01001cc:	6a 69                	push   $0x69
f01001ce:	68 07 63 10 f0       	push   $0xf0106307
f01001d3:	e8 68 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01001d8:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001dd:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001e0:	e8 56 5a 00 00       	call   f0105c3b <cpunum>
f01001e5:	83 ec 08             	sub    $0x8,%esp
f01001e8:	50                   	push   %eax
f01001e9:	68 13 63 10 f0       	push   $0xf0106313
f01001ee:	e8 bc 36 00 00       	call   f01038af <cprintf>
	lapic_init();
f01001f3:	e8 5d 5a 00 00       	call   f0105c55 <lapic_init>
	env_init_percpu();
f01001f8:	e8 e0 2e 00 00       	call   f01030dd <env_init_percpu>
	trap_init_percpu();
f01001fd:	e8 c1 36 00 00       	call   f01038c3 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100202:	e8 34 5a 00 00       	call   f0105c3b <cpunum>
f0100207:	6b d0 74             	imul   $0x74,%eax,%edx
f010020a:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010020d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100212:	f0 87 82 20 40 21 f0 	lock xchg %eax,-0xfdebfe0(%edx)
f0100219:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100220:	e8 86 5c 00 00       	call   f0105eab <spin_lock>
	sched_yield();
f0100225:	e8 4d 42 00 00       	call   f0104477 <sched_yield>

f010022a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	53                   	push   %ebx
f010022e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100231:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100234:	ff 75 0c             	pushl  0xc(%ebp)
f0100237:	ff 75 08             	pushl  0x8(%ebp)
f010023a:	68 29 63 10 f0       	push   $0xf0106329
f010023f:	e8 6b 36 00 00       	call   f01038af <cprintf>
	vcprintf(fmt, ap);
f0100244:	83 c4 08             	add    $0x8,%esp
f0100247:	53                   	push   %ebx
f0100248:	ff 75 10             	pushl  0x10(%ebp)
f010024b:	e8 39 36 00 00       	call   f0103889 <vcprintf>
	cprintf("\n");
f0100250:	c7 04 24 29 74 10 f0 	movl   $0xf0107429,(%esp)
f0100257:	e8 53 36 00 00       	call   f01038af <cprintf>
	va_end(ap);
}
f010025c:	83 c4 10             	add    $0x10,%esp
f010025f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100262:	c9                   	leave  
f0100263:	c3                   	ret    

f0100264 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100264:	55                   	push   %ebp
f0100265:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100267:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026c:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026d:	a8 01                	test   $0x1,%al
f010026f:	74 0b                	je     f010027c <serial_proc_data+0x18>
f0100271:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100276:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100277:	0f b6 c0             	movzbl %al,%eax
}
f010027a:	5d                   	pop    %ebp
f010027b:	c3                   	ret    
		return -1;
f010027c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100281:	eb f7                	jmp    f010027a <serial_proc_data+0x16>

f0100283 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100283:	55                   	push   %ebp
f0100284:	89 e5                	mov    %esp,%ebp
f0100286:	53                   	push   %ebx
f0100287:	83 ec 04             	sub    $0x4,%esp
f010028a:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010028c:	ff d3                	call   *%ebx
f010028e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100291:	74 2d                	je     f01002c0 <cons_intr+0x3d>
		if (c == 0)
f0100293:	85 c0                	test   %eax,%eax
f0100295:	74 f5                	je     f010028c <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100297:	8b 0d 24 32 21 f0    	mov    0xf0213224,%ecx
f010029d:	8d 51 01             	lea    0x1(%ecx),%edx
f01002a0:	89 15 24 32 21 f0    	mov    %edx,0xf0213224
f01002a6:	88 81 20 30 21 f0    	mov    %al,-0xfdecfe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ac:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002b2:	75 d8                	jne    f010028c <cons_intr+0x9>
			cons.wpos = 0;
f01002b4:	c7 05 24 32 21 f0 00 	movl   $0x0,0xf0213224
f01002bb:	00 00 00 
f01002be:	eb cc                	jmp    f010028c <cons_intr+0x9>
	}
}
f01002c0:	83 c4 04             	add    $0x4,%esp
f01002c3:	5b                   	pop    %ebx
f01002c4:	5d                   	pop    %ebp
f01002c5:	c3                   	ret    

f01002c6 <kbd_proc_data>:
{
f01002c6:	55                   	push   %ebp
f01002c7:	89 e5                	mov    %esp,%ebp
f01002c9:	53                   	push   %ebx
f01002ca:	83 ec 04             	sub    $0x4,%esp
f01002cd:	ba 64 00 00 00       	mov    $0x64,%edx
f01002d2:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002d3:	a8 01                	test   $0x1,%al
f01002d5:	0f 84 fa 00 00 00    	je     f01003d5 <kbd_proc_data+0x10f>
	if (stat & KBS_TERR)
f01002db:	a8 20                	test   $0x20,%al
f01002dd:	0f 85 f9 00 00 00    	jne    f01003dc <kbd_proc_data+0x116>
f01002e3:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e8:	ec                   	in     (%dx),%al
f01002e9:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002eb:	3c e0                	cmp    $0xe0,%al
f01002ed:	0f 84 8e 00 00 00    	je     f0100381 <kbd_proc_data+0xbb>
	} else if (data & 0x80) {
f01002f3:	84 c0                	test   %al,%al
f01002f5:	0f 88 99 00 00 00    	js     f0100394 <kbd_proc_data+0xce>
	} else if (shift & E0ESC) {
f01002fb:	8b 0d 00 30 21 f0    	mov    0xf0213000,%ecx
f0100301:	f6 c1 40             	test   $0x40,%cl
f0100304:	74 0e                	je     f0100314 <kbd_proc_data+0x4e>
		data |= 0x80;
f0100306:	83 c8 80             	or     $0xffffff80,%eax
f0100309:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010030b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010030e:	89 0d 00 30 21 f0    	mov    %ecx,0xf0213000
	shift |= shiftcode[data];
f0100314:	0f b6 d2             	movzbl %dl,%edx
f0100317:	0f b6 82 a0 64 10 f0 	movzbl -0xfef9b60(%edx),%eax
f010031e:	0b 05 00 30 21 f0    	or     0xf0213000,%eax
	shift ^= togglecode[data];
f0100324:	0f b6 8a a0 63 10 f0 	movzbl -0xfef9c60(%edx),%ecx
f010032b:	31 c8                	xor    %ecx,%eax
f010032d:	a3 00 30 21 f0       	mov    %eax,0xf0213000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100332:	89 c1                	mov    %eax,%ecx
f0100334:	83 e1 03             	and    $0x3,%ecx
f0100337:	8b 0c 8d 80 63 10 f0 	mov    -0xfef9c80(,%ecx,4),%ecx
f010033e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100342:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100345:	a8 08                	test   $0x8,%al
f0100347:	74 0d                	je     f0100356 <kbd_proc_data+0x90>
		if ('a' <= c && c <= 'z')
f0100349:	89 da                	mov    %ebx,%edx
f010034b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010034e:	83 f9 19             	cmp    $0x19,%ecx
f0100351:	77 74                	ja     f01003c7 <kbd_proc_data+0x101>
			c += 'A' - 'a';
f0100353:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100356:	f7 d0                	not    %eax
f0100358:	a8 06                	test   $0x6,%al
f010035a:	75 31                	jne    f010038d <kbd_proc_data+0xc7>
f010035c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100362:	75 29                	jne    f010038d <kbd_proc_data+0xc7>
		cprintf("Rebooting!\n");
f0100364:	83 ec 0c             	sub    $0xc,%esp
f0100367:	68 43 63 10 f0       	push   $0xf0106343
f010036c:	e8 3e 35 00 00       	call   f01038af <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100371:	b8 03 00 00 00       	mov    $0x3,%eax
f0100376:	ba 92 00 00 00       	mov    $0x92,%edx
f010037b:	ee                   	out    %al,(%dx)
f010037c:	83 c4 10             	add    $0x10,%esp
f010037f:	eb 0c                	jmp    f010038d <kbd_proc_data+0xc7>
		shift |= E0ESC;
f0100381:	83 0d 00 30 21 f0 40 	orl    $0x40,0xf0213000
		return 0;
f0100388:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010038d:	89 d8                	mov    %ebx,%eax
f010038f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100392:	c9                   	leave  
f0100393:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100394:	8b 0d 00 30 21 f0    	mov    0xf0213000,%ecx
f010039a:	89 cb                	mov    %ecx,%ebx
f010039c:	83 e3 40             	and    $0x40,%ebx
f010039f:	83 e0 7f             	and    $0x7f,%eax
f01003a2:	85 db                	test   %ebx,%ebx
f01003a4:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003a7:	0f b6 d2             	movzbl %dl,%edx
f01003aa:	0f b6 82 a0 64 10 f0 	movzbl -0xfef9b60(%edx),%eax
f01003b1:	83 c8 40             	or     $0x40,%eax
f01003b4:	0f b6 c0             	movzbl %al,%eax
f01003b7:	f7 d0                	not    %eax
f01003b9:	21 c8                	and    %ecx,%eax
f01003bb:	a3 00 30 21 f0       	mov    %eax,0xf0213000
		return 0;
f01003c0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003c5:	eb c6                	jmp    f010038d <kbd_proc_data+0xc7>
		else if ('A' <= c && c <= 'Z')
f01003c7:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ca:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003cd:	83 fa 1a             	cmp    $0x1a,%edx
f01003d0:	0f 42 d9             	cmovb  %ecx,%ebx
f01003d3:	eb 81                	jmp    f0100356 <kbd_proc_data+0x90>
		return -1;
f01003d5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003da:	eb b1                	jmp    f010038d <kbd_proc_data+0xc7>
		return -1;
f01003dc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003e1:	eb aa                	jmp    f010038d <kbd_proc_data+0xc7>

f01003e3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003e3:	55                   	push   %ebp
f01003e4:	89 e5                	mov    %esp,%ebp
f01003e6:	57                   	push   %edi
f01003e7:	56                   	push   %esi
f01003e8:	53                   	push   %ebx
f01003e9:	83 ec 1c             	sub    $0x1c,%esp
f01003ec:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003ee:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f3:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f8:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003fd:	eb 09                	jmp    f0100408 <cons_putc+0x25>
f01003ff:	89 ca                	mov    %ecx,%edx
f0100401:	ec                   	in     (%dx),%al
f0100402:	ec                   	in     (%dx),%al
f0100403:	ec                   	in     (%dx),%al
f0100404:	ec                   	in     (%dx),%al
	     i++)
f0100405:	83 c3 01             	add    $0x1,%ebx
f0100408:	89 f2                	mov    %esi,%edx
f010040a:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010040b:	a8 20                	test   $0x20,%al
f010040d:	75 08                	jne    f0100417 <cons_putc+0x34>
f010040f:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100415:	7e e8                	jle    f01003ff <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f0100417:	89 f8                	mov    %edi,%eax
f0100419:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100421:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100422:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100427:	be 79 03 00 00       	mov    $0x379,%esi
f010042c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100431:	eb 09                	jmp    f010043c <cons_putc+0x59>
f0100433:	89 ca                	mov    %ecx,%edx
f0100435:	ec                   	in     (%dx),%al
f0100436:	ec                   	in     (%dx),%al
f0100437:	ec                   	in     (%dx),%al
f0100438:	ec                   	in     (%dx),%al
f0100439:	83 c3 01             	add    $0x1,%ebx
f010043c:	89 f2                	mov    %esi,%edx
f010043e:	ec                   	in     (%dx),%al
f010043f:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100445:	7f 04                	jg     f010044b <cons_putc+0x68>
f0100447:	84 c0                	test   %al,%al
f0100449:	79 e8                	jns    f0100433 <cons_putc+0x50>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044b:	ba 78 03 00 00       	mov    $0x378,%edx
f0100450:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100454:	ee                   	out    %al,(%dx)
f0100455:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010045a:	b8 0d 00 00 00       	mov    $0xd,%eax
f010045f:	ee                   	out    %al,(%dx)
f0100460:	b8 08 00 00 00       	mov    $0x8,%eax
f0100465:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100466:	89 fa                	mov    %edi,%edx
f0100468:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010046e:	89 f8                	mov    %edi,%eax
f0100470:	80 cc 07             	or     $0x7,%ah
f0100473:	85 d2                	test   %edx,%edx
f0100475:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100478:	89 f8                	mov    %edi,%eax
f010047a:	0f b6 c0             	movzbl %al,%eax
f010047d:	83 f8 09             	cmp    $0x9,%eax
f0100480:	0f 84 b6 00 00 00    	je     f010053c <cons_putc+0x159>
f0100486:	83 f8 09             	cmp    $0x9,%eax
f0100489:	7e 73                	jle    f01004fe <cons_putc+0x11b>
f010048b:	83 f8 0a             	cmp    $0xa,%eax
f010048e:	0f 84 9b 00 00 00    	je     f010052f <cons_putc+0x14c>
f0100494:	83 f8 0d             	cmp    $0xd,%eax
f0100497:	0f 85 d6 00 00 00    	jne    f0100573 <cons_putc+0x190>
		crt_pos -= (crt_pos % CRT_COLS);
f010049d:	0f b7 05 28 32 21 f0 	movzwl 0xf0213228,%eax
f01004a4:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004aa:	c1 e8 16             	shr    $0x16,%eax
f01004ad:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004b0:	c1 e0 04             	shl    $0x4,%eax
f01004b3:	66 a3 28 32 21 f0    	mov    %ax,0xf0213228
	if (crt_pos >= CRT_SIZE) {
f01004b9:	66 81 3d 28 32 21 f0 	cmpw   $0x7cf,0xf0213228
f01004c0:	cf 07 
f01004c2:	0f 87 ce 00 00 00    	ja     f0100596 <cons_putc+0x1b3>
	outb(addr_6845, 14);
f01004c8:	8b 0d 30 32 21 f0    	mov    0xf0213230,%ecx
f01004ce:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004d3:	89 ca                	mov    %ecx,%edx
f01004d5:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004d6:	0f b7 1d 28 32 21 f0 	movzwl 0xf0213228,%ebx
f01004dd:	8d 71 01             	lea    0x1(%ecx),%esi
f01004e0:	89 d8                	mov    %ebx,%eax
f01004e2:	66 c1 e8 08          	shr    $0x8,%ax
f01004e6:	89 f2                	mov    %esi,%edx
f01004e8:	ee                   	out    %al,(%dx)
f01004e9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004ee:	89 ca                	mov    %ecx,%edx
f01004f0:	ee                   	out    %al,(%dx)
f01004f1:	89 d8                	mov    %ebx,%eax
f01004f3:	89 f2                	mov    %esi,%edx
f01004f5:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004f9:	5b                   	pop    %ebx
f01004fa:	5e                   	pop    %esi
f01004fb:	5f                   	pop    %edi
f01004fc:	5d                   	pop    %ebp
f01004fd:	c3                   	ret    
	switch (c & 0xff) {
f01004fe:	83 f8 08             	cmp    $0x8,%eax
f0100501:	75 70                	jne    f0100573 <cons_putc+0x190>
		if (crt_pos > 0) {
f0100503:	0f b7 05 28 32 21 f0 	movzwl 0xf0213228,%eax
f010050a:	66 85 c0             	test   %ax,%ax
f010050d:	74 b9                	je     f01004c8 <cons_putc+0xe5>
			crt_pos--;
f010050f:	83 e8 01             	sub    $0x1,%eax
f0100512:	66 a3 28 32 21 f0    	mov    %ax,0xf0213228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100518:	0f b7 c0             	movzwl %ax,%eax
f010051b:	66 81 e7 00 ff       	and    $0xff00,%di
f0100520:	83 cf 20             	or     $0x20,%edi
f0100523:	8b 15 2c 32 21 f0    	mov    0xf021322c,%edx
f0100529:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010052d:	eb 8a                	jmp    f01004b9 <cons_putc+0xd6>
		crt_pos += CRT_COLS;
f010052f:	66 83 05 28 32 21 f0 	addw   $0x50,0xf0213228
f0100536:	50 
f0100537:	e9 61 ff ff ff       	jmp    f010049d <cons_putc+0xba>
		cons_putc(' ');
f010053c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100541:	e8 9d fe ff ff       	call   f01003e3 <cons_putc>
		cons_putc(' ');
f0100546:	b8 20 00 00 00       	mov    $0x20,%eax
f010054b:	e8 93 fe ff ff       	call   f01003e3 <cons_putc>
		cons_putc(' ');
f0100550:	b8 20 00 00 00       	mov    $0x20,%eax
f0100555:	e8 89 fe ff ff       	call   f01003e3 <cons_putc>
		cons_putc(' ');
f010055a:	b8 20 00 00 00       	mov    $0x20,%eax
f010055f:	e8 7f fe ff ff       	call   f01003e3 <cons_putc>
		cons_putc(' ');
f0100564:	b8 20 00 00 00       	mov    $0x20,%eax
f0100569:	e8 75 fe ff ff       	call   f01003e3 <cons_putc>
f010056e:	e9 46 ff ff ff       	jmp    f01004b9 <cons_putc+0xd6>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100573:	0f b7 05 28 32 21 f0 	movzwl 0xf0213228,%eax
f010057a:	8d 50 01             	lea    0x1(%eax),%edx
f010057d:	66 89 15 28 32 21 f0 	mov    %dx,0xf0213228
f0100584:	0f b7 c0             	movzwl %ax,%eax
f0100587:	8b 15 2c 32 21 f0    	mov    0xf021322c,%edx
f010058d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100591:	e9 23 ff ff ff       	jmp    f01004b9 <cons_putc+0xd6>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100596:	a1 2c 32 21 f0       	mov    0xf021322c,%eax
f010059b:	83 ec 04             	sub    $0x4,%esp
f010059e:	68 00 0f 00 00       	push   $0xf00
f01005a3:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005a9:	52                   	push   %edx
f01005aa:	50                   	push   %eax
f01005ab:	e8 b3 50 00 00       	call   f0105663 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005b0:	8b 15 2c 32 21 f0    	mov    0xf021322c,%edx
f01005b6:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005bc:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005c2:	83 c4 10             	add    $0x10,%esp
f01005c5:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005ca:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005cd:	39 d0                	cmp    %edx,%eax
f01005cf:	75 f4                	jne    f01005c5 <cons_putc+0x1e2>
		crt_pos -= CRT_COLS;
f01005d1:	66 83 2d 28 32 21 f0 	subw   $0x50,0xf0213228
f01005d8:	50 
f01005d9:	e9 ea fe ff ff       	jmp    f01004c8 <cons_putc+0xe5>

f01005de <serial_intr>:
	if (serial_exists)
f01005de:	80 3d 34 32 21 f0 00 	cmpb   $0x0,0xf0213234
f01005e5:	75 02                	jne    f01005e9 <serial_intr+0xb>
f01005e7:	f3 c3                	repz ret 
{
f01005e9:	55                   	push   %ebp
f01005ea:	89 e5                	mov    %esp,%ebp
f01005ec:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005ef:	b8 64 02 10 f0       	mov    $0xf0100264,%eax
f01005f4:	e8 8a fc ff ff       	call   f0100283 <cons_intr>
}
f01005f9:	c9                   	leave  
f01005fa:	c3                   	ret    

f01005fb <kbd_intr>:
{
f01005fb:	55                   	push   %ebp
f01005fc:	89 e5                	mov    %esp,%ebp
f01005fe:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100601:	b8 c6 02 10 f0       	mov    $0xf01002c6,%eax
f0100606:	e8 78 fc ff ff       	call   f0100283 <cons_intr>
}
f010060b:	c9                   	leave  
f010060c:	c3                   	ret    

f010060d <cons_getc>:
{
f010060d:	55                   	push   %ebp
f010060e:	89 e5                	mov    %esp,%ebp
f0100610:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100613:	e8 c6 ff ff ff       	call   f01005de <serial_intr>
	kbd_intr();
f0100618:	e8 de ff ff ff       	call   f01005fb <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010061d:	8b 15 20 32 21 f0    	mov    0xf0213220,%edx
	return 0;
f0100623:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100628:	3b 15 24 32 21 f0    	cmp    0xf0213224,%edx
f010062e:	74 18                	je     f0100648 <cons_getc+0x3b>
		c = cons.buf[cons.rpos++];
f0100630:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100633:	89 0d 20 32 21 f0    	mov    %ecx,0xf0213220
f0100639:	0f b6 82 20 30 21 f0 	movzbl -0xfdecfe0(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100640:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100646:	74 02                	je     f010064a <cons_getc+0x3d>
}
f0100648:	c9                   	leave  
f0100649:	c3                   	ret    
			cons.rpos = 0;
f010064a:	c7 05 20 32 21 f0 00 	movl   $0x0,0xf0213220
f0100651:	00 00 00 
f0100654:	eb f2                	jmp    f0100648 <cons_getc+0x3b>

f0100656 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100656:	55                   	push   %ebp
f0100657:	89 e5                	mov    %esp,%ebp
f0100659:	57                   	push   %edi
f010065a:	56                   	push   %esi
f010065b:	53                   	push   %ebx
f010065c:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f010065f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100666:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010066d:	5a a5 
	if (*cp != 0xA55A) {
f010066f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100676:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010067a:	0f 84 de 00 00 00    	je     f010075e <cons_init+0x108>
		addr_6845 = MONO_BASE;
f0100680:	c7 05 30 32 21 f0 b4 	movl   $0x3b4,0xf0213230
f0100687:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010068a:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f010068f:	8b 3d 30 32 21 f0    	mov    0xf0213230,%edi
f0100695:	b8 0e 00 00 00       	mov    $0xe,%eax
f010069a:	89 fa                	mov    %edi,%edx
f010069c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010069d:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a0:	89 ca                	mov    %ecx,%edx
f01006a2:	ec                   	in     (%dx),%al
f01006a3:	0f b6 c0             	movzbl %al,%eax
f01006a6:	c1 e0 08             	shl    $0x8,%eax
f01006a9:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ab:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006b0:	89 fa                	mov    %edi,%edx
f01006b2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b3:	89 ca                	mov    %ecx,%edx
f01006b5:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006b6:	89 35 2c 32 21 f0    	mov    %esi,0xf021322c
	pos |= inb(addr_6845 + 1);
f01006bc:	0f b6 c0             	movzbl %al,%eax
f01006bf:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006c1:	66 a3 28 32 21 f0    	mov    %ax,0xf0213228
	kbd_intr();
f01006c7:	e8 2f ff ff ff       	call   f01005fb <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006cc:	83 ec 0c             	sub    $0xc,%esp
f01006cf:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01006d6:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006db:	50                   	push   %eax
f01006dc:	e8 73 30 00 00       	call   f0103754 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006e6:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01006eb:	89 d8                	mov    %ebx,%eax
f01006ed:	89 ca                	mov    %ecx,%edx
f01006ef:	ee                   	out    %al,(%dx)
f01006f0:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006f5:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006fa:	89 fa                	mov    %edi,%edx
f01006fc:	ee                   	out    %al,(%dx)
f01006fd:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100702:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100707:	ee                   	out    %al,(%dx)
f0100708:	be f9 03 00 00       	mov    $0x3f9,%esi
f010070d:	89 d8                	mov    %ebx,%eax
f010070f:	89 f2                	mov    %esi,%edx
f0100711:	ee                   	out    %al,(%dx)
f0100712:	b8 03 00 00 00       	mov    $0x3,%eax
f0100717:	89 fa                	mov    %edi,%edx
f0100719:	ee                   	out    %al,(%dx)
f010071a:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010071f:	89 d8                	mov    %ebx,%eax
f0100721:	ee                   	out    %al,(%dx)
f0100722:	b8 01 00 00 00       	mov    $0x1,%eax
f0100727:	89 f2                	mov    %esi,%edx
f0100729:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010072f:	ec                   	in     (%dx),%al
f0100730:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100732:	83 c4 10             	add    $0x10,%esp
f0100735:	3c ff                	cmp    $0xff,%al
f0100737:	0f 95 05 34 32 21 f0 	setne  0xf0213234
f010073e:	89 ca                	mov    %ecx,%edx
f0100740:	ec                   	in     (%dx),%al
f0100741:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100746:	ec                   	in     (%dx),%al
	if (serial_exists)
f0100747:	80 fb ff             	cmp    $0xff,%bl
f010074a:	75 2d                	jne    f0100779 <cons_init+0x123>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f010074c:	83 ec 0c             	sub    $0xc,%esp
f010074f:	68 4f 63 10 f0       	push   $0xf010634f
f0100754:	e8 56 31 00 00       	call   f01038af <cprintf>
f0100759:	83 c4 10             	add    $0x10,%esp
}
f010075c:	eb 3c                	jmp    f010079a <cons_init+0x144>
		*cp = was;
f010075e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100765:	c7 05 30 32 21 f0 d4 	movl   $0x3d4,0xf0213230
f010076c:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010076f:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100774:	e9 16 ff ff ff       	jmp    f010068f <cons_init+0x39>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100779:	83 ec 0c             	sub    $0xc,%esp
f010077c:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0100783:	25 ef ff 00 00       	and    $0xffef,%eax
f0100788:	50                   	push   %eax
f0100789:	e8 c6 2f 00 00       	call   f0103754 <irq_setmask_8259A>
	if (!serial_exists)
f010078e:	83 c4 10             	add    $0x10,%esp
f0100791:	80 3d 34 32 21 f0 00 	cmpb   $0x0,0xf0213234
f0100798:	74 b2                	je     f010074c <cons_init+0xf6>
}
f010079a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010079d:	5b                   	pop    %ebx
f010079e:	5e                   	pop    %esi
f010079f:	5f                   	pop    %edi
f01007a0:	5d                   	pop    %ebp
f01007a1:	c3                   	ret    

f01007a2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007a2:	55                   	push   %ebp
f01007a3:	89 e5                	mov    %esp,%ebp
f01007a5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01007ab:	e8 33 fc ff ff       	call   f01003e3 <cons_putc>
}
f01007b0:	c9                   	leave  
f01007b1:	c3                   	ret    

f01007b2 <getchar>:

int
getchar(void)
{
f01007b2:	55                   	push   %ebp
f01007b3:	89 e5                	mov    %esp,%ebp
f01007b5:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007b8:	e8 50 fe ff ff       	call   f010060d <cons_getc>
f01007bd:	85 c0                	test   %eax,%eax
f01007bf:	74 f7                	je     f01007b8 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007c1:	c9                   	leave  
f01007c2:	c3                   	ret    

f01007c3 <iscons>:

int
iscons(int fdnum)
{
f01007c3:	55                   	push   %ebp
f01007c4:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01007cb:	5d                   	pop    %ebp
f01007cc:	c3                   	ret    

f01007cd <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007cd:	55                   	push   %ebp
f01007ce:	89 e5                	mov    %esp,%ebp
f01007d0:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007d3:	68 a0 65 10 f0       	push   $0xf01065a0
f01007d8:	68 be 65 10 f0       	push   $0xf01065be
f01007dd:	68 c3 65 10 f0       	push   $0xf01065c3
f01007e2:	e8 c8 30 00 00       	call   f01038af <cprintf>
f01007e7:	83 c4 0c             	add    $0xc,%esp
f01007ea:	68 6c 66 10 f0       	push   $0xf010666c
f01007ef:	68 cc 65 10 f0       	push   $0xf01065cc
f01007f4:	68 c3 65 10 f0       	push   $0xf01065c3
f01007f9:	e8 b1 30 00 00       	call   f01038af <cprintf>
	return 0;
}
f01007fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100803:	c9                   	leave  
f0100804:	c3                   	ret    

f0100805 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100805:	55                   	push   %ebp
f0100806:	89 e5                	mov    %esp,%ebp
f0100808:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010080b:	68 d5 65 10 f0       	push   $0xf01065d5
f0100810:	e8 9a 30 00 00       	call   f01038af <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100815:	83 c4 08             	add    $0x8,%esp
f0100818:	68 0c 00 10 00       	push   $0x10000c
f010081d:	68 94 66 10 f0       	push   $0xf0106694
f0100822:	e8 88 30 00 00       	call   f01038af <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100827:	83 c4 0c             	add    $0xc,%esp
f010082a:	68 0c 00 10 00       	push   $0x10000c
f010082f:	68 0c 00 10 f0       	push   $0xf010000c
f0100834:	68 bc 66 10 f0       	push   $0xf01066bc
f0100839:	e8 71 30 00 00       	call   f01038af <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010083e:	83 c4 0c             	add    $0xc,%esp
f0100841:	68 69 62 10 00       	push   $0x106269
f0100846:	68 69 62 10 f0       	push   $0xf0106269
f010084b:	68 e0 66 10 f0       	push   $0xf01066e0
f0100850:	e8 5a 30 00 00       	call   f01038af <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100855:	83 c4 0c             	add    $0xc,%esp
f0100858:	68 00 30 21 00       	push   $0x213000
f010085d:	68 00 30 21 f0       	push   $0xf0213000
f0100862:	68 04 67 10 f0       	push   $0xf0106704
f0100867:	e8 43 30 00 00       	call   f01038af <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086c:	83 c4 0c             	add    $0xc,%esp
f010086f:	68 08 50 25 00       	push   $0x255008
f0100874:	68 08 50 25 f0       	push   $0xf0255008
f0100879:	68 28 67 10 f0       	push   $0xf0106728
f010087e:	e8 2c 30 00 00       	call   f01038af <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100883:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100886:	b8 07 54 25 f0       	mov    $0xf0255407,%eax
f010088b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100890:	c1 f8 0a             	sar    $0xa,%eax
f0100893:	50                   	push   %eax
f0100894:	68 4c 67 10 f0       	push   $0xf010674c
f0100899:	e8 11 30 00 00       	call   f01038af <cprintf>
	return 0;
}
f010089e:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a3:	c9                   	leave  
f01008a4:	c3                   	ret    

f01008a5 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008a5:	55                   	push   %ebp
f01008a6:	89 e5                	mov    %esp,%ebp
f01008a8:	56                   	push   %esi
f01008a9:	53                   	push   %ebx
f01008aa:	83 ec 2c             	sub    $0x2c,%esp
	// Your code here.
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
f01008ad:	68 ee 65 10 f0       	push   $0xf01065ee
f01008b2:	e8 f8 2f 00 00       	call   f01038af <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008b7:	89 eb                	mov    %ebp,%ebx
	uint32_t *  ebp=(uint32_t *)read_ebp();
	while(ebp!=0x0){
f01008b9:	83 c4 10             	add    $0x10,%esp
	debuginfo_eip(*(ebp+1),&info);
f01008bc:	8d 75 e0             	lea    -0x20(%ebp),%esi
	while(ebp!=0x0){
f01008bf:	e9 92 00 00 00       	jmp    f0100956 <mon_backtrace+0xb1>
	debuginfo_eip(*(ebp+1),&info);
f01008c4:	83 ec 08             	sub    $0x8,%esp
f01008c7:	56                   	push   %esi
f01008c8:	ff 73 04             	pushl  0x4(%ebx)
f01008cb:	e8 c4 42 00 00       	call   f0104b94 <debuginfo_eip>
	cprintf("ebp %08x eip %08x",ebp,*(ebp+1));
f01008d0:	83 c4 0c             	add    $0xc,%esp
f01008d3:	ff 73 04             	pushl  0x4(%ebx)
f01008d6:	53                   	push   %ebx
f01008d7:	68 00 66 10 f0       	push   $0xf0106600
f01008dc:	e8 ce 2f 00 00       	call   f01038af <cprintf>
	cprintf(" args %08x",*(ebp+2));
f01008e1:	83 c4 08             	add    $0x8,%esp
f01008e4:	ff 73 08             	pushl  0x8(%ebx)
f01008e7:	68 12 66 10 f0       	push   $0xf0106612
f01008ec:	e8 be 2f 00 00       	call   f01038af <cprintf>
	cprintf(" %08x",*(ebp+3));
f01008f1:	83 c4 08             	add    $0x8,%esp
f01008f4:	ff 73 0c             	pushl  0xc(%ebx)
f01008f7:	68 0c 66 10 f0       	push   $0xf010660c
f01008fc:	e8 ae 2f 00 00       	call   f01038af <cprintf>
	cprintf(" %08x",*(ebp+4));
f0100901:	83 c4 08             	add    $0x8,%esp
f0100904:	ff 73 10             	pushl  0x10(%ebx)
f0100907:	68 0c 66 10 f0       	push   $0xf010660c
f010090c:	e8 9e 2f 00 00       	call   f01038af <cprintf>
	cprintf(" %08x",*(ebp+5));
f0100911:	83 c4 08             	add    $0x8,%esp
f0100914:	ff 73 14             	pushl  0x14(%ebx)
f0100917:	68 0c 66 10 f0       	push   $0xf010660c
f010091c:	e8 8e 2f 00 00       	call   f01038af <cprintf>
	cprintf(" %08x\n",*(ebp+6));
f0100921:	83 c4 08             	add    $0x8,%esp
f0100924:	ff 73 18             	pushl  0x18(%ebx)
f0100927:	68 50 7f 10 f0       	push   $0xf0107f50
f010092c:	e8 7e 2f 00 00       	call   f01038af <cprintf>
	cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,*(ebp+1)-info.eip_fn_addr);
f0100931:	83 c4 08             	add    $0x8,%esp
f0100934:	8b 43 04             	mov    0x4(%ebx),%eax
f0100937:	2b 45 f0             	sub    -0x10(%ebp),%eax
f010093a:	50                   	push   %eax
f010093b:	ff 75 e8             	pushl  -0x18(%ebp)
f010093e:	ff 75 ec             	pushl  -0x14(%ebp)
f0100941:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100944:	ff 75 e0             	pushl  -0x20(%ebp)
f0100947:	68 1d 66 10 f0       	push   $0xf010661d
f010094c:	e8 5e 2f 00 00       	call   f01038af <cprintf>
	ebp=(uint32_t *) *(ebp);
f0100951:	8b 1b                	mov    (%ebx),%ebx
f0100953:	83 c4 20             	add    $0x20,%esp
	while(ebp!=0x0){
f0100956:	85 db                	test   %ebx,%ebx
f0100958:	0f 85 66 ff ff ff    	jne    f01008c4 <mon_backtrace+0x1f>
	}
 
	return 0;
}
f010095e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100963:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100966:	5b                   	pop    %ebx
f0100967:	5e                   	pop    %esi
f0100968:	5d                   	pop    %ebp
f0100969:	c3                   	ret    

f010096a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010096a:	55                   	push   %ebp
f010096b:	89 e5                	mov    %esp,%ebp
f010096d:	57                   	push   %edi
f010096e:	56                   	push   %esi
f010096f:	53                   	push   %ebx
f0100970:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100973:	68 78 67 10 f0       	push   $0xf0106778
f0100978:	e8 32 2f 00 00       	call   f01038af <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010097d:	c7 04 24 9c 67 10 f0 	movl   $0xf010679c,(%esp)
f0100984:	e8 26 2f 00 00       	call   f01038af <cprintf>

	if (tf != NULL)
f0100989:	83 c4 10             	add    $0x10,%esp
f010098c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100990:	74 57                	je     f01009e9 <monitor+0x7f>
		print_trapframe(tf);
f0100992:	83 ec 0c             	sub    $0xc,%esp
f0100995:	ff 75 08             	pushl  0x8(%ebp)
f0100998:	e8 43 34 00 00       	call   f0103de0 <print_trapframe>
f010099d:	83 c4 10             	add    $0x10,%esp
f01009a0:	eb 47                	jmp    f01009e9 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f01009a2:	83 ec 08             	sub    $0x8,%esp
f01009a5:	0f be c0             	movsbl %al,%eax
f01009a8:	50                   	push   %eax
f01009a9:	68 31 66 10 f0       	push   $0xf0106631
f01009ae:	e8 26 4c 00 00       	call   f01055d9 <strchr>
f01009b3:	83 c4 10             	add    $0x10,%esp
f01009b6:	85 c0                	test   %eax,%eax
f01009b8:	74 0a                	je     f01009c4 <monitor+0x5a>
			*buf++ = 0;
f01009ba:	c6 03 00             	movb   $0x0,(%ebx)
f01009bd:	89 f7                	mov    %esi,%edi
f01009bf:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009c2:	eb 6b                	jmp    f0100a2f <monitor+0xc5>
		if (*buf == 0)
f01009c4:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009c7:	74 73                	je     f0100a3c <monitor+0xd2>
		if (argc == MAXARGS-1) {
f01009c9:	83 fe 0f             	cmp    $0xf,%esi
f01009cc:	74 09                	je     f01009d7 <monitor+0x6d>
		argv[argc++] = buf;
f01009ce:	8d 7e 01             	lea    0x1(%esi),%edi
f01009d1:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009d5:	eb 39                	jmp    f0100a10 <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009d7:	83 ec 08             	sub    $0x8,%esp
f01009da:	6a 10                	push   $0x10
f01009dc:	68 36 66 10 f0       	push   $0xf0106636
f01009e1:	e8 c9 2e 00 00       	call   f01038af <cprintf>
f01009e6:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009e9:	83 ec 0c             	sub    $0xc,%esp
f01009ec:	68 2d 66 10 f0       	push   $0xf010662d
f01009f1:	e8 ba 49 00 00       	call   f01053b0 <readline>
f01009f6:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009f8:	83 c4 10             	add    $0x10,%esp
f01009fb:	85 c0                	test   %eax,%eax
f01009fd:	74 ea                	je     f01009e9 <monitor+0x7f>
	argv[argc] = 0;
f01009ff:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a06:	be 00 00 00 00       	mov    $0x0,%esi
f0100a0b:	eb 24                	jmp    f0100a31 <monitor+0xc7>
			buf++;
f0100a0d:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a10:	0f b6 03             	movzbl (%ebx),%eax
f0100a13:	84 c0                	test   %al,%al
f0100a15:	74 18                	je     f0100a2f <monitor+0xc5>
f0100a17:	83 ec 08             	sub    $0x8,%esp
f0100a1a:	0f be c0             	movsbl %al,%eax
f0100a1d:	50                   	push   %eax
f0100a1e:	68 31 66 10 f0       	push   $0xf0106631
f0100a23:	e8 b1 4b 00 00       	call   f01055d9 <strchr>
f0100a28:	83 c4 10             	add    $0x10,%esp
f0100a2b:	85 c0                	test   %eax,%eax
f0100a2d:	74 de                	je     f0100a0d <monitor+0xa3>
			*buf++ = 0;
f0100a2f:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a31:	0f b6 03             	movzbl (%ebx),%eax
f0100a34:	84 c0                	test   %al,%al
f0100a36:	0f 85 66 ff ff ff    	jne    f01009a2 <monitor+0x38>
	argv[argc] = 0;
f0100a3c:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a43:	00 
	if (argc == 0)
f0100a44:	85 f6                	test   %esi,%esi
f0100a46:	74 a1                	je     f01009e9 <monitor+0x7f>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a48:	83 ec 08             	sub    $0x8,%esp
f0100a4b:	68 be 65 10 f0       	push   $0xf01065be
f0100a50:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a53:	e8 23 4b 00 00       	call   f010557b <strcmp>
f0100a58:	83 c4 10             	add    $0x10,%esp
f0100a5b:	85 c0                	test   %eax,%eax
f0100a5d:	74 34                	je     f0100a93 <monitor+0x129>
f0100a5f:	83 ec 08             	sub    $0x8,%esp
f0100a62:	68 cc 65 10 f0       	push   $0xf01065cc
f0100a67:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a6a:	e8 0c 4b 00 00       	call   f010557b <strcmp>
f0100a6f:	83 c4 10             	add    $0x10,%esp
f0100a72:	85 c0                	test   %eax,%eax
f0100a74:	74 18                	je     f0100a8e <monitor+0x124>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a76:	83 ec 08             	sub    $0x8,%esp
f0100a79:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a7c:	68 53 66 10 f0       	push   $0xf0106653
f0100a81:	e8 29 2e 00 00       	call   f01038af <cprintf>
f0100a86:	83 c4 10             	add    $0x10,%esp
f0100a89:	e9 5b ff ff ff       	jmp    f01009e9 <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a8e:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a93:	83 ec 04             	sub    $0x4,%esp
f0100a96:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a99:	ff 75 08             	pushl  0x8(%ebp)
f0100a9c:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a9f:	52                   	push   %edx
f0100aa0:	56                   	push   %esi
f0100aa1:	ff 14 85 cc 67 10 f0 	call   *-0xfef9834(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100aa8:	83 c4 10             	add    $0x10,%esp
f0100aab:	85 c0                	test   %eax,%eax
f0100aad:	0f 89 36 ff ff ff    	jns    f01009e9 <monitor+0x7f>
				break;
	}
}
f0100ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ab6:	5b                   	pop    %ebx
f0100ab7:	5e                   	pop    %esi
f0100ab8:	5f                   	pop    %edi
f0100ab9:	5d                   	pop    %ebp
f0100aba:	c3                   	ret    

f0100abb <boot_alloc>:
// before the page_free_list list has been set up.
// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f0100abb:	55                   	push   %ebp
f0100abc:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100abe:	83 3d 38 32 21 f0 00 	cmpl   $0x0,0xf0213238
f0100ac5:	74 1d                	je     f0100ae4 <boot_alloc+0x29>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100ac7:	8b 0d 38 32 21 f0    	mov    0xf0213238,%ecx
	nextfree = ROUNDUP((char *)result + n, PGSIZE);
f0100acd:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100ad4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ada:	89 15 38 32 21 f0    	mov    %edx,0xf0213238
	return result;
}
f0100ae0:	89 c8                	mov    %ecx,%eax
f0100ae2:	5d                   	pop    %ebp
f0100ae3:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ae4:	ba 07 60 25 f0       	mov    $0xf0256007,%edx
f0100ae9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aef:	89 15 38 32 21 f0    	mov    %edx,0xf0213238
f0100af5:	eb d0                	jmp    f0100ac7 <boot_alloc+0xc>

f0100af7 <nvram_read>:
{
f0100af7:	55                   	push   %ebp
f0100af8:	89 e5                	mov    %esp,%ebp
f0100afa:	56                   	push   %esi
f0100afb:	53                   	push   %ebx
f0100afc:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100afe:	83 ec 0c             	sub    $0xc,%esp
f0100b01:	50                   	push   %eax
f0100b02:	e8 1f 2c 00 00       	call   f0103726 <mc146818_read>
f0100b07:	89 c3                	mov    %eax,%ebx
f0100b09:	83 c6 01             	add    $0x1,%esi
f0100b0c:	89 34 24             	mov    %esi,(%esp)
f0100b0f:	e8 12 2c 00 00       	call   f0103726 <mc146818_read>
f0100b14:	c1 e0 08             	shl    $0x8,%eax
f0100b17:	09 d8                	or     %ebx,%eax
}
f0100b19:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b1c:	5b                   	pop    %ebx
f0100b1d:	5e                   	pop    %esi
f0100b1e:	5d                   	pop    %ebp
f0100b1f:	c3                   	ret    

f0100b20 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b20:	89 d1                	mov    %edx,%ecx
f0100b22:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b25:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b28:	a8 01                	test   $0x1,%al
f0100b2a:	74 52                	je     f0100b7e <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100b31:	89 c1                	mov    %eax,%ecx
f0100b33:	c1 e9 0c             	shr    $0xc,%ecx
f0100b36:	3b 0d 88 3e 21 f0    	cmp    0xf0213e88,%ecx
f0100b3c:	73 25                	jae    f0100b63 <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100b3e:	c1 ea 0c             	shr    $0xc,%edx
f0100b41:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b47:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b4e:	89 c2                	mov    %eax,%edx
f0100b50:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b58:	85 d2                	test   %edx,%edx
f0100b5a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b5f:	0f 44 c2             	cmove  %edx,%eax
f0100b62:	c3                   	ret    
{
f0100b63:	55                   	push   %ebp
f0100b64:	89 e5                	mov    %esp,%ebp
f0100b66:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b69:	50                   	push   %eax
f0100b6a:	68 a4 62 10 f0       	push   $0xf01062a4
f0100b6f:	68 87 03 00 00       	push   $0x387
f0100b74:	68 21 71 10 f0       	push   $0xf0107121
f0100b79:	e8 c2 f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b83:	c3                   	ret    

f0100b84 <check_page_free_list>:
{
f0100b84:	55                   	push   %ebp
f0100b85:	89 e5                	mov    %esp,%ebp
f0100b87:	57                   	push   %edi
f0100b88:	56                   	push   %esi
f0100b89:	53                   	push   %ebx
f0100b8a:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b8d:	84 c0                	test   %al,%al
f0100b8f:	0f 85 86 02 00 00    	jne    f0100e1b <check_page_free_list+0x297>
	if (!page_free_list)
f0100b95:	83 3d 40 32 21 f0 00 	cmpl   $0x0,0xf0213240
f0100b9c:	74 0a                	je     f0100ba8 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b9e:	be 00 04 00 00       	mov    $0x400,%esi
f0100ba3:	e9 ce 02 00 00       	jmp    f0100e76 <check_page_free_list+0x2f2>
		panic("'page_free_list' is a null pointer!");
f0100ba8:	83 ec 04             	sub    $0x4,%esp
f0100bab:	68 dc 67 10 f0       	push   $0xf01067dc
f0100bb0:	68 ba 02 00 00       	push   $0x2ba
f0100bb5:	68 21 71 10 f0       	push   $0xf0107121
f0100bba:	e8 81 f4 ff ff       	call   f0100040 <_panic>
f0100bbf:	50                   	push   %eax
f0100bc0:	68 a4 62 10 f0       	push   $0xf01062a4
f0100bc5:	6a 58                	push   $0x58
f0100bc7:	68 2d 71 10 f0       	push   $0xf010712d
f0100bcc:	e8 6f f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bd1:	8b 1b                	mov    (%ebx),%ebx
f0100bd3:	85 db                	test   %ebx,%ebx
f0100bd5:	74 41                	je     f0100c18 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bd7:	89 d8                	mov    %ebx,%eax
f0100bd9:	2b 05 90 3e 21 f0    	sub    0xf0213e90,%eax
f0100bdf:	c1 f8 03             	sar    $0x3,%eax
f0100be2:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100be5:	89 c2                	mov    %eax,%edx
f0100be7:	c1 ea 16             	shr    $0x16,%edx
f0100bea:	39 f2                	cmp    %esi,%edx
f0100bec:	73 e3                	jae    f0100bd1 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100bee:	89 c2                	mov    %eax,%edx
f0100bf0:	c1 ea 0c             	shr    $0xc,%edx
f0100bf3:	3b 15 88 3e 21 f0    	cmp    0xf0213e88,%edx
f0100bf9:	73 c4                	jae    f0100bbf <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100bfb:	83 ec 04             	sub    $0x4,%esp
f0100bfe:	68 80 00 00 00       	push   $0x80
f0100c03:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c08:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c0d:	50                   	push   %eax
f0100c0e:	e8 03 4a 00 00       	call   f0105616 <memset>
f0100c13:	83 c4 10             	add    $0x10,%esp
f0100c16:	eb b9                	jmp    f0100bd1 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100c18:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c1d:	e8 99 fe ff ff       	call   f0100abb <boot_alloc>
f0100c22:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c25:	8b 15 40 32 21 f0    	mov    0xf0213240,%edx
		assert(pp >= pages);
f0100c2b:	8b 0d 90 3e 21 f0    	mov    0xf0213e90,%ecx
		assert(pp < pages + npages);
f0100c31:	a1 88 3e 21 f0       	mov    0xf0213e88,%eax
f0100c36:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c39:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c3c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c3f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c42:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c47:	e9 04 01 00 00       	jmp    f0100d50 <check_page_free_list+0x1cc>
		assert(pp >= pages);
f0100c4c:	68 3b 71 10 f0       	push   $0xf010713b
f0100c51:	68 47 71 10 f0       	push   $0xf0107147
f0100c56:	68 d4 02 00 00       	push   $0x2d4
f0100c5b:	68 21 71 10 f0       	push   $0xf0107121
f0100c60:	e8 db f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c65:	68 5c 71 10 f0       	push   $0xf010715c
f0100c6a:	68 47 71 10 f0       	push   $0xf0107147
f0100c6f:	68 d5 02 00 00       	push   $0x2d5
f0100c74:	68 21 71 10 f0       	push   $0xf0107121
f0100c79:	e8 c2 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c7e:	68 00 68 10 f0       	push   $0xf0106800
f0100c83:	68 47 71 10 f0       	push   $0xf0107147
f0100c88:	68 d6 02 00 00       	push   $0x2d6
f0100c8d:	68 21 71 10 f0       	push   $0xf0107121
f0100c92:	e8 a9 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100c97:	68 70 71 10 f0       	push   $0xf0107170
f0100c9c:	68 47 71 10 f0       	push   $0xf0107147
f0100ca1:	68 d9 02 00 00       	push   $0x2d9
f0100ca6:	68 21 71 10 f0       	push   $0xf0107121
f0100cab:	e8 90 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cb0:	68 81 71 10 f0       	push   $0xf0107181
f0100cb5:	68 47 71 10 f0       	push   $0xf0107147
f0100cba:	68 da 02 00 00       	push   $0x2da
f0100cbf:	68 21 71 10 f0       	push   $0xf0107121
f0100cc4:	e8 77 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cc9:	68 34 68 10 f0       	push   $0xf0106834
f0100cce:	68 47 71 10 f0       	push   $0xf0107147
f0100cd3:	68 db 02 00 00       	push   $0x2db
f0100cd8:	68 21 71 10 f0       	push   $0xf0107121
f0100cdd:	e8 5e f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ce2:	68 9a 71 10 f0       	push   $0xf010719a
f0100ce7:	68 47 71 10 f0       	push   $0xf0107147
f0100cec:	68 dc 02 00 00       	push   $0x2dc
f0100cf1:	68 21 71 10 f0       	push   $0xf0107121
f0100cf6:	e8 45 f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100cfb:	89 c7                	mov    %eax,%edi
f0100cfd:	c1 ef 0c             	shr    $0xc,%edi
f0100d00:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d03:	76 1b                	jbe    f0100d20 <check_page_free_list+0x19c>
	return (void *)(pa + KERNBASE);
f0100d05:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d0b:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d0e:	77 22                	ja     f0100d32 <check_page_free_list+0x1ae>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d10:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d15:	0f 84 98 00 00 00    	je     f0100db3 <check_page_free_list+0x22f>
			++nfree_extmem;
f0100d1b:	83 c3 01             	add    $0x1,%ebx
f0100d1e:	eb 2e                	jmp    f0100d4e <check_page_free_list+0x1ca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d20:	50                   	push   %eax
f0100d21:	68 a4 62 10 f0       	push   $0xf01062a4
f0100d26:	6a 58                	push   $0x58
f0100d28:	68 2d 71 10 f0       	push   $0xf010712d
f0100d2d:	e8 0e f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d32:	68 58 68 10 f0       	push   $0xf0106858
f0100d37:	68 47 71 10 f0       	push   $0xf0107147
f0100d3c:	68 dd 02 00 00       	push   $0x2dd
f0100d41:	68 21 71 10 f0       	push   $0xf0107121
f0100d46:	e8 f5 f2 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100d4b:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d4e:	8b 12                	mov    (%edx),%edx
f0100d50:	85 d2                	test   %edx,%edx
f0100d52:	74 78                	je     f0100dcc <check_page_free_list+0x248>
		assert(pp >= pages);
f0100d54:	39 d1                	cmp    %edx,%ecx
f0100d56:	0f 87 f0 fe ff ff    	ja     f0100c4c <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100d5c:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0100d5f:	0f 86 00 ff ff ff    	jbe    f0100c65 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d65:	89 d0                	mov    %edx,%eax
f0100d67:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d6a:	a8 07                	test   $0x7,%al
f0100d6c:	0f 85 0c ff ff ff    	jne    f0100c7e <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100d72:	c1 f8 03             	sar    $0x3,%eax
f0100d75:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100d78:	85 c0                	test   %eax,%eax
f0100d7a:	0f 84 17 ff ff ff    	je     f0100c97 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d80:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d85:	0f 84 25 ff ff ff    	je     f0100cb0 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d8b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d90:	0f 84 33 ff ff ff    	je     f0100cc9 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d96:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d9b:	0f 84 41 ff ff ff    	je     f0100ce2 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100da1:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100da6:	0f 87 4f ff ff ff    	ja     f0100cfb <check_page_free_list+0x177>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dac:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100db1:	75 98                	jne    f0100d4b <check_page_free_list+0x1c7>
f0100db3:	68 b4 71 10 f0       	push   $0xf01071b4
f0100db8:	68 47 71 10 f0       	push   $0xf0107147
f0100dbd:	68 df 02 00 00       	push   $0x2df
f0100dc2:	68 21 71 10 f0       	push   $0xf0107121
f0100dc7:	e8 74 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0100dcc:	85 f6                	test   %esi,%esi
f0100dce:	7e 19                	jle    f0100de9 <check_page_free_list+0x265>
	assert(nfree_extmem > 0);
f0100dd0:	85 db                	test   %ebx,%ebx
f0100dd2:	7e 2e                	jle    f0100e02 <check_page_free_list+0x27e>
	cprintf("check_page_free_list() succeeded!\n");
f0100dd4:	83 ec 0c             	sub    $0xc,%esp
f0100dd7:	68 a0 68 10 f0       	push   $0xf01068a0
f0100ddc:	e8 ce 2a 00 00       	call   f01038af <cprintf>
}
f0100de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100de4:	5b                   	pop    %ebx
f0100de5:	5e                   	pop    %esi
f0100de6:	5f                   	pop    %edi
f0100de7:	5d                   	pop    %ebp
f0100de8:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100de9:	68 d1 71 10 f0       	push   $0xf01071d1
f0100dee:	68 47 71 10 f0       	push   $0xf0107147
f0100df3:	68 e7 02 00 00       	push   $0x2e7
f0100df8:	68 21 71 10 f0       	push   $0xf0107121
f0100dfd:	e8 3e f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e02:	68 e3 71 10 f0       	push   $0xf01071e3
f0100e07:	68 47 71 10 f0       	push   $0xf0107147
f0100e0c:	68 e8 02 00 00       	push   $0x2e8
f0100e11:	68 21 71 10 f0       	push   $0xf0107121
f0100e16:	e8 25 f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100e1b:	a1 40 32 21 f0       	mov    0xf0213240,%eax
f0100e20:	85 c0                	test   %eax,%eax
f0100e22:	0f 84 80 fd ff ff    	je     f0100ba8 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e28:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e2b:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e2e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e31:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100e34:	89 c2                	mov    %eax,%edx
f0100e36:	2b 15 90 3e 21 f0    	sub    0xf0213e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e3c:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e42:	0f 95 c2             	setne  %dl
f0100e45:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e48:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e4c:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e4e:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e52:	8b 00                	mov    (%eax),%eax
f0100e54:	85 c0                	test   %eax,%eax
f0100e56:	75 dc                	jne    f0100e34 <check_page_free_list+0x2b0>
		*tp[1] = 0;
f0100e58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e61:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e64:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e67:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e69:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e6c:	a3 40 32 21 f0       	mov    %eax,0xf0213240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e71:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e76:	8b 1d 40 32 21 f0    	mov    0xf0213240,%ebx
f0100e7c:	e9 52 fd ff ff       	jmp    f0100bd3 <check_page_free_list+0x4f>

f0100e81 <page_init>:
{
f0100e81:	55                   	push   %ebp
f0100e82:	89 e5                	mov    %esp,%ebp
f0100e84:	53                   	push   %ebx
f0100e85:	83 ec 04             	sub    $0x4,%esp
	for (i = 0; i < npages; i++) {
f0100e88:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e8d:	eb 3c                	jmp    f0100ecb <page_init+0x4a>
		else if(i>=IOPHYSMEM/PGSIZE && i< PADDR(boot_alloc(0))/PGSIZE)
f0100e8f:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100e95:	77 53                	ja     f0100eea <page_init+0x69>
		else if (i == MPENTRY_PADDR / PGSIZE) {
f0100e97:	83 fb 07             	cmp    $0x7,%ebx
f0100e9a:	0f 84 92 00 00 00    	je     f0100f32 <page_init+0xb1>
f0100ea0:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
			pages[i].pp_ref = 0;
f0100ea7:	89 c2                	mov    %eax,%edx
f0100ea9:	03 15 90 3e 21 f0    	add    0xf0213e90,%edx
f0100eaf:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100eb5:	8b 0d 40 32 21 f0    	mov    0xf0213240,%ecx
f0100ebb:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100ebd:	03 05 90 3e 21 f0    	add    0xf0213e90,%eax
f0100ec3:	a3 40 32 21 f0       	mov    %eax,0xf0213240
	for (i = 0; i < npages; i++) {
f0100ec8:	83 c3 01             	add    $0x1,%ebx
f0100ecb:	39 1d 88 3e 21 f0    	cmp    %ebx,0xf0213e88
f0100ed1:	76 73                	jbe    f0100f46 <page_init+0xc5>
		if(i == 0)
f0100ed3:	85 db                	test   %ebx,%ebx
f0100ed5:	75 b8                	jne    f0100e8f <page_init+0xe>
			pages[i].pp_ref = 1;
f0100ed7:	a1 90 3e 21 f0       	mov    0xf0213e90,%eax
f0100edc:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100ee2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ee8:	eb de                	jmp    f0100ec8 <page_init+0x47>
		else if(i>=IOPHYSMEM/PGSIZE && i< PADDR(boot_alloc(0))/PGSIZE)
f0100eea:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eef:	e8 c7 fb ff ff       	call   f0100abb <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100ef4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ef9:	76 22                	jbe    f0100f1d <page_init+0x9c>
	return (physaddr_t)kva - KERNBASE;
f0100efb:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f00:	c1 e8 0c             	shr    $0xc,%eax
f0100f03:	39 d8                	cmp    %ebx,%eax
f0100f05:	76 90                	jbe    f0100e97 <page_init+0x16>
			pages[i].pp_ref = 1;
f0100f07:	a1 90 3e 21 f0       	mov    0xf0213e90,%eax
f0100f0c:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100f0f:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100f15:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f1b:	eb ab                	jmp    f0100ec8 <page_init+0x47>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f1d:	50                   	push   %eax
f0100f1e:	68 c8 62 10 f0       	push   $0xf01062c8
f0100f23:	68 43 01 00 00       	push   $0x143
f0100f28:	68 21 71 10 f0       	push   $0xf0107121
f0100f2d:	e8 0e f1 ff ff       	call   f0100040 <_panic>
			pages[i].pp_ref = 1;
f0100f32:	a1 90 3e 21 f0       	mov    0xf0213e90,%eax
f0100f37:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
			pages[i].pp_link = NULL;
f0100f3d:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100f44:	eb 82                	jmp    f0100ec8 <page_init+0x47>
}
f0100f46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f49:	c9                   	leave  
f0100f4a:	c3                   	ret    

f0100f4b <page_alloc>:
{
f0100f4b:	55                   	push   %ebp
f0100f4c:	89 e5                	mov    %esp,%ebp
f0100f4e:	53                   	push   %ebx
f0100f4f:	83 ec 04             	sub    $0x4,%esp
	if(page_free_list == NULL)
f0100f52:	8b 1d 40 32 21 f0    	mov    0xf0213240,%ebx
f0100f58:	85 db                	test   %ebx,%ebx
f0100f5a:	74 13                	je     f0100f6f <page_alloc+0x24>
	page_free_list = page->pp_link;
f0100f5c:	8b 03                	mov    (%ebx),%eax
f0100f5e:	a3 40 32 21 f0       	mov    %eax,0xf0213240
	page->pp_link = 0;
f0100f63:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
f0100f69:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f6d:	75 07                	jne    f0100f76 <page_alloc+0x2b>
}
f0100f6f:	89 d8                	mov    %ebx,%eax
f0100f71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f74:	c9                   	leave  
f0100f75:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100f76:	89 d8                	mov    %ebx,%eax
f0100f78:	2b 05 90 3e 21 f0    	sub    0xf0213e90,%eax
f0100f7e:	c1 f8 03             	sar    $0x3,%eax
f0100f81:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100f84:	89 c2                	mov    %eax,%edx
f0100f86:	c1 ea 0c             	shr    $0xc,%edx
f0100f89:	3b 15 88 3e 21 f0    	cmp    0xf0213e88,%edx
f0100f8f:	73 1a                	jae    f0100fab <page_alloc+0x60>
		memset(page2kva(page), 0, PGSIZE);
f0100f91:	83 ec 04             	sub    $0x4,%esp
f0100f94:	68 00 10 00 00       	push   $0x1000
f0100f99:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f9b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fa0:	50                   	push   %eax
f0100fa1:	e8 70 46 00 00       	call   f0105616 <memset>
f0100fa6:	83 c4 10             	add    $0x10,%esp
f0100fa9:	eb c4                	jmp    f0100f6f <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fab:	50                   	push   %eax
f0100fac:	68 a4 62 10 f0       	push   $0xf01062a4
f0100fb1:	6a 58                	push   $0x58
f0100fb3:	68 2d 71 10 f0       	push   $0xf010712d
f0100fb8:	e8 83 f0 ff ff       	call   f0100040 <_panic>

f0100fbd <page_free>:
{
f0100fbd:	55                   	push   %ebp
f0100fbe:	89 e5                	mov    %esp,%ebp
f0100fc0:	83 ec 08             	sub    $0x8,%esp
f0100fc3:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_link != NULL  || pp->pp_ref != 0)
f0100fc6:	83 38 00             	cmpl   $0x0,(%eax)
f0100fc9:	75 16                	jne    f0100fe1 <page_free+0x24>
f0100fcb:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fd0:	75 0f                	jne    f0100fe1 <page_free+0x24>
	pp->pp_link = page_free_list;
f0100fd2:	8b 15 40 32 21 f0    	mov    0xf0213240,%edx
f0100fd8:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100fda:	a3 40 32 21 f0       	mov    %eax,0xf0213240
}
f0100fdf:	c9                   	leave  
f0100fe0:	c3                   	ret    
		panic("page_free is not right");
f0100fe1:	83 ec 04             	sub    $0x4,%esp
f0100fe4:	68 f4 71 10 f0       	push   $0xf01071f4
f0100fe9:	68 7b 01 00 00       	push   $0x17b
f0100fee:	68 21 71 10 f0       	push   $0xf0107121
f0100ff3:	e8 48 f0 ff ff       	call   f0100040 <_panic>

f0100ff8 <page_decref>:
{
f0100ff8:	55                   	push   %ebp
f0100ff9:	89 e5                	mov    %esp,%ebp
f0100ffb:	83 ec 08             	sub    $0x8,%esp
f0100ffe:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101001:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101005:	83 e8 01             	sub    $0x1,%eax
f0101008:	66 89 42 04          	mov    %ax,0x4(%edx)
f010100c:	66 85 c0             	test   %ax,%ax
f010100f:	74 02                	je     f0101013 <page_decref+0x1b>
}
f0101011:	c9                   	leave  
f0101012:	c3                   	ret    
		page_free(pp);
f0101013:	83 ec 0c             	sub    $0xc,%esp
f0101016:	52                   	push   %edx
f0101017:	e8 a1 ff ff ff       	call   f0100fbd <page_free>
f010101c:	83 c4 10             	add    $0x10,%esp
}
f010101f:	eb f0                	jmp    f0101011 <page_decref+0x19>

f0101021 <pgdir_walk>:
{
f0101021:	55                   	push   %ebp
f0101022:	89 e5                	mov    %esp,%ebp
f0101024:	56                   	push   %esi
f0101025:	53                   	push   %ebx
f0101026:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t* pde_ptr = pgdir + PDX(va);
f0101029:	89 f3                	mov    %esi,%ebx
f010102b:	c1 eb 16             	shr    $0x16,%ebx
f010102e:	c1 e3 02             	shl    $0x2,%ebx
f0101031:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*pde_ptr & PTE_P)){
f0101034:	f6 03 01             	testb  $0x1,(%ebx)
f0101037:	75 2d                	jne    f0101066 <pgdir_walk+0x45>
		if (create) {
f0101039:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010103d:	74 67                	je     f01010a6 <pgdir_walk+0x85>
			struct PageInfo *pp = page_alloc(1);
f010103f:	83 ec 0c             	sub    $0xc,%esp
f0101042:	6a 01                	push   $0x1
f0101044:	e8 02 ff ff ff       	call   f0100f4b <page_alloc>
			if (pp == NULL) {
f0101049:	83 c4 10             	add    $0x10,%esp
f010104c:	85 c0                	test   %eax,%eax
f010104e:	74 5d                	je     f01010ad <pgdir_walk+0x8c>
			pp->pp_ref++;
f0101050:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101055:	2b 05 90 3e 21 f0    	sub    0xf0213e90,%eax
f010105b:	c1 f8 03             	sar    $0x3,%eax
f010105e:	c1 e0 0c             	shl    $0xc,%eax
			*pde_ptr = (page2pa(pp)) | PTE_P | PTE_U | PTE_W;	
f0101061:	83 c8 07             	or     $0x7,%eax
f0101064:	89 03                	mov    %eax,(%ebx)
	return (pte_t *)KADDR(PTE_ADDR(*pde_ptr)) + PTX(va);
f0101066:	8b 03                	mov    (%ebx),%eax
f0101068:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010106d:	89 c2                	mov    %eax,%edx
f010106f:	c1 ea 0c             	shr    $0xc,%edx
f0101072:	3b 15 88 3e 21 f0    	cmp    0xf0213e88,%edx
f0101078:	73 17                	jae    f0101091 <pgdir_walk+0x70>
f010107a:	c1 ee 0a             	shr    $0xa,%esi
f010107d:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101083:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
}
f010108a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010108d:	5b                   	pop    %ebx
f010108e:	5e                   	pop    %esi
f010108f:	5d                   	pop    %ebp
f0101090:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101091:	50                   	push   %eax
f0101092:	68 a4 62 10 f0       	push   $0xf01062a4
f0101097:	68 b3 01 00 00       	push   $0x1b3
f010109c:	68 21 71 10 f0       	push   $0xf0107121
f01010a1:	e8 9a ef ff ff       	call   f0100040 <_panic>
			return NULL;
f01010a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01010ab:	eb dd                	jmp    f010108a <pgdir_walk+0x69>
				return NULL;
f01010ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01010b2:	eb d6                	jmp    f010108a <pgdir_walk+0x69>

f01010b4 <boot_map_region>:
{
f01010b4:	55                   	push   %ebp
f01010b5:	89 e5                	mov    %esp,%ebp
f01010b7:	57                   	push   %edi
f01010b8:	56                   	push   %esi
f01010b9:	53                   	push   %ebx
f01010ba:	83 ec 1c             	sub    $0x1c,%esp
f01010bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010c0:	8b 45 08             	mov    0x8(%ebp),%eax
	size_t pgs = size / PGSIZE;
f01010c3:	89 cb                	mov    %ecx,%ebx
f01010c5:	c1 eb 0c             	shr    $0xc,%ebx
	if (size % PGSIZE != 0) {
f01010c8:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
		pgs++;
f01010ce:	83 f9 01             	cmp    $0x1,%ecx
f01010d1:	83 db ff             	sbb    $0xffffffff,%ebx
f01010d4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for (int i = 0; i < pgs; i++) {
f01010d7:	89 c3                	mov    %eax,%ebx
f01010d9:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f01010de:	89 d7                	mov    %edx,%edi
f01010e0:	29 c7                	sub    %eax,%edi
		*pte = pa | PTE_P | perm;
f01010e2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010e5:	83 c8 01             	or     $0x1,%eax
f01010e8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (int i = 0; i < pgs; i++) {
f01010eb:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f01010ee:	74 41                	je     f0101131 <boot_map_region+0x7d>
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f01010f0:	83 ec 04             	sub    $0x4,%esp
f01010f3:	6a 01                	push   $0x1
f01010f5:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01010f8:	50                   	push   %eax
f01010f9:	ff 75 e0             	pushl  -0x20(%ebp)
f01010fc:	e8 20 ff ff ff       	call   f0101021 <pgdir_walk>
		if (pte == NULL) {
f0101101:	83 c4 10             	add    $0x10,%esp
f0101104:	85 c0                	test   %eax,%eax
f0101106:	74 12                	je     f010111a <boot_map_region+0x66>
		*pte = pa | PTE_P | perm;
f0101108:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010110b:	09 da                	or     %ebx,%edx
f010110d:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f010110f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (int i = 0; i < pgs; i++) {
f0101115:	83 c6 01             	add    $0x1,%esi
f0101118:	eb d1                	jmp    f01010eb <boot_map_region+0x37>
			panic("boot_map_region(): out of memory\n");
f010111a:	83 ec 04             	sub    $0x4,%esp
f010111d:	68 c4 68 10 f0       	push   $0xf01068c4
f0101122:	68 cc 01 00 00       	push   $0x1cc
f0101127:	68 21 71 10 f0       	push   $0xf0107121
f010112c:	e8 0f ef ff ff       	call   f0100040 <_panic>
}
f0101131:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101134:	5b                   	pop    %ebx
f0101135:	5e                   	pop    %esi
f0101136:	5f                   	pop    %edi
f0101137:	5d                   	pop    %ebp
f0101138:	c3                   	ret    

f0101139 <page_lookup>:
{
f0101139:	55                   	push   %ebp
f010113a:	89 e5                	mov    %esp,%ebp
f010113c:	53                   	push   %ebx
f010113d:	83 ec 08             	sub    $0x8,%esp
f0101140:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte =  pgdir_walk(pgdir, va, 0);
f0101143:	6a 00                	push   $0x0
f0101145:	ff 75 0c             	pushl  0xc(%ebp)
f0101148:	ff 75 08             	pushl  0x8(%ebp)
f010114b:	e8 d1 fe ff ff       	call   f0101021 <pgdir_walk>
	if (pte == NULL) {
f0101150:	83 c4 10             	add    $0x10,%esp
f0101153:	85 c0                	test   %eax,%eax
f0101155:	74 3a                	je     f0101191 <page_lookup+0x58>
f0101157:	89 c1                	mov    %eax,%ecx
	if (!(*pte) & PTE_P) {
f0101159:	8b 10                	mov    (%eax),%edx
f010115b:	85 d2                	test   %edx,%edx
f010115d:	74 39                	je     f0101198 <page_lookup+0x5f>
f010115f:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101162:	39 15 88 3e 21 f0    	cmp    %edx,0xf0213e88
f0101168:	76 13                	jbe    f010117d <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010116a:	a1 90 3e 21 f0       	mov    0xf0213e90,%eax
f010116f:	8d 04 d0             	lea    (%eax,%edx,8),%eax
	if (pte_store != NULL) {
f0101172:	85 db                	test   %ebx,%ebx
f0101174:	74 02                	je     f0101178 <page_lookup+0x3f>
		*pte_store = pte;
f0101176:	89 0b                	mov    %ecx,(%ebx)
}
f0101178:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010117b:	c9                   	leave  
f010117c:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010117d:	83 ec 04             	sub    $0x4,%esp
f0101180:	68 e8 68 10 f0       	push   $0xf01068e8
f0101185:	6a 51                	push   $0x51
f0101187:	68 2d 71 10 f0       	push   $0xf010712d
f010118c:	e8 af ee ff ff       	call   f0100040 <_panic>
		return NULL;
f0101191:	b8 00 00 00 00       	mov    $0x0,%eax
f0101196:	eb e0                	jmp    f0101178 <page_lookup+0x3f>
		return NULL;
f0101198:	b8 00 00 00 00       	mov    $0x0,%eax
f010119d:	eb d9                	jmp    f0101178 <page_lookup+0x3f>

f010119f <tlb_invalidate>:
{
f010119f:	55                   	push   %ebp
f01011a0:	89 e5                	mov    %esp,%ebp
f01011a2:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01011a5:	e8 91 4a 00 00       	call   f0105c3b <cpunum>
f01011aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01011ad:	83 b8 28 40 21 f0 00 	cmpl   $0x0,-0xfdebfd8(%eax)
f01011b4:	74 16                	je     f01011cc <tlb_invalidate+0x2d>
f01011b6:	e8 80 4a 00 00       	call   f0105c3b <cpunum>
f01011bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01011be:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f01011c4:	8b 55 08             	mov    0x8(%ebp),%edx
f01011c7:	39 50 60             	cmp    %edx,0x60(%eax)
f01011ca:	75 06                	jne    f01011d2 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011cc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011cf:	0f 01 38             	invlpg (%eax)
}
f01011d2:	c9                   	leave  
f01011d3:	c3                   	ret    

f01011d4 <page_remove>:
{
f01011d4:	55                   	push   %ebp
f01011d5:	89 e5                	mov    %esp,%ebp
f01011d7:	56                   	push   %esi
f01011d8:	53                   	push   %ebx
f01011d9:	83 ec 14             	sub    $0x14,%esp
f01011dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011df:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f01011e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011e5:	50                   	push   %eax
f01011e6:	56                   	push   %esi
f01011e7:	53                   	push   %ebx
f01011e8:	e8 4c ff ff ff       	call   f0101139 <page_lookup>
	if(page == NULL)
f01011ed:	83 c4 10             	add    $0x10,%esp
f01011f0:	85 c0                	test   %eax,%eax
f01011f2:	75 07                	jne    f01011fb <page_remove+0x27>
}
f01011f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011f7:	5b                   	pop    %ebx
f01011f8:	5e                   	pop    %esi
f01011f9:	5d                   	pop    %ebp
f01011fa:	c3                   	ret    
	page_decref(page);
f01011fb:	83 ec 0c             	sub    $0xc,%esp
f01011fe:	50                   	push   %eax
f01011ff:	e8 f4 fd ff ff       	call   f0100ff8 <page_decref>
	*pte = 0;
f0101204:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101207:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f010120d:	83 c4 08             	add    $0x8,%esp
f0101210:	56                   	push   %esi
f0101211:	53                   	push   %ebx
f0101212:	e8 88 ff ff ff       	call   f010119f <tlb_invalidate>
f0101217:	83 c4 10             	add    $0x10,%esp
f010121a:	eb d8                	jmp    f01011f4 <page_remove+0x20>

f010121c <page_insert>:
{
f010121c:	55                   	push   %ebp
f010121d:	89 e5                	mov    %esp,%ebp
f010121f:	57                   	push   %edi
f0101220:	56                   	push   %esi
f0101221:	53                   	push   %ebx
f0101222:	83 ec 10             	sub    $0x10,%esp
f0101225:	8b 75 08             	mov    0x8(%ebp),%esi
f0101228:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f010122b:	6a 01                	push   $0x1
f010122d:	ff 75 10             	pushl  0x10(%ebp)
f0101230:	56                   	push   %esi
f0101231:	e8 eb fd ff ff       	call   f0101021 <pgdir_walk>
	if(pte == NULL)
f0101236:	83 c4 10             	add    $0x10,%esp
f0101239:	85 c0                	test   %eax,%eax
f010123b:	74 4c                	je     f0101289 <page_insert+0x6d>
f010123d:	89 c7                	mov    %eax,%edi
	pp->pp_ref++;
f010123f:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if ((*pte) & PTE_P){
f0101244:	f6 00 01             	testb  $0x1,(%eax)
f0101247:	75 2f                	jne    f0101278 <page_insert+0x5c>
	return (pp - pages) << PGSHIFT;
f0101249:	2b 1d 90 3e 21 f0    	sub    0xf0213e90,%ebx
f010124f:	c1 fb 03             	sar    $0x3,%ebx
f0101252:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = pa | perm | PTE_P;
f0101255:	8b 45 14             	mov    0x14(%ebp),%eax
f0101258:	83 c8 01             	or     $0x1,%eax
f010125b:	09 c3                	or     %eax,%ebx
f010125d:	89 1f                	mov    %ebx,(%edi)
	pgdir[PDX(va)] |= perm;
f010125f:	8b 45 10             	mov    0x10(%ebp),%eax
f0101262:	c1 e8 16             	shr    $0x16,%eax
f0101265:	8b 55 14             	mov    0x14(%ebp),%edx
f0101268:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f010126b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101270:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101273:	5b                   	pop    %ebx
f0101274:	5e                   	pop    %esi
f0101275:	5f                   	pop    %edi
f0101276:	5d                   	pop    %ebp
f0101277:	c3                   	ret    
		page_remove(pgdir, va);
f0101278:	83 ec 08             	sub    $0x8,%esp
f010127b:	ff 75 10             	pushl  0x10(%ebp)
f010127e:	56                   	push   %esi
f010127f:	e8 50 ff ff ff       	call   f01011d4 <page_remove>
f0101284:	83 c4 10             	add    $0x10,%esp
f0101287:	eb c0                	jmp    f0101249 <page_insert+0x2d>
		return -E_NO_MEM;
f0101289:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010128e:	eb e0                	jmp    f0101270 <page_insert+0x54>

f0101290 <mmio_map_region>:
{
f0101290:	55                   	push   %ebp
f0101291:	89 e5                	mov    %esp,%ebp
f0101293:	53                   	push   %ebx
f0101294:	83 ec 04             	sub    $0x4,%esp
f0101297:	8b 45 08             	mov    0x8(%ebp),%eax
	size = ROUNDUP(pa+size, PGSIZE);
f010129a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010129d:	8d 9c 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%ebx
f01012a4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa,PGSIZE);
f01012aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	size = size-pa;
f01012af:	29 c3                	sub    %eax,%ebx
	if(base + size > MMIOLIM) 
f01012b1:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f01012b7:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f01012ba:	81 f9 00 00 c0 ef    	cmp    $0xefc00000,%ecx
f01012c0:	77 24                	ja     f01012e6 <mmio_map_region+0x56>
	boot_map_region(kern_pgdir, base, size, pa, PTE_W|PTE_PCD|PTE_PWT);
f01012c2:	83 ec 08             	sub    $0x8,%esp
f01012c5:	6a 1a                	push   $0x1a
f01012c7:	50                   	push   %eax
f01012c8:	89 d9                	mov    %ebx,%ecx
f01012ca:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
f01012cf:	e8 e0 fd ff ff       	call   f01010b4 <boot_map_region>
	uintptr_t res = base;
f01012d4:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base +=size;
f01012d9:	01 c3                	add    %eax,%ebx
f01012db:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
}
f01012e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012e4:	c9                   	leave  
f01012e5:	c3                   	ret    
		panic("overflow MMIOLIM");
f01012e6:	83 ec 04             	sub    $0x4,%esp
f01012e9:	68 0b 72 10 f0       	push   $0xf010720b
f01012ee:	68 6a 02 00 00       	push   $0x26a
f01012f3:	68 21 71 10 f0       	push   $0xf0107121
f01012f8:	e8 43 ed ff ff       	call   f0100040 <_panic>

f01012fd <mem_init>:
{
f01012fd:	55                   	push   %ebp
f01012fe:	89 e5                	mov    %esp,%ebp
f0101300:	57                   	push   %edi
f0101301:	56                   	push   %esi
f0101302:	53                   	push   %ebx
f0101303:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101306:	b8 15 00 00 00       	mov    $0x15,%eax
f010130b:	e8 e7 f7 ff ff       	call   f0100af7 <nvram_read>
f0101310:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101312:	b8 17 00 00 00       	mov    $0x17,%eax
f0101317:	e8 db f7 ff ff       	call   f0100af7 <nvram_read>
f010131c:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010131e:	b8 34 00 00 00       	mov    $0x34,%eax
f0101323:	e8 cf f7 ff ff       	call   f0100af7 <nvram_read>
f0101328:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f010132b:	85 c0                	test   %eax,%eax
f010132d:	0f 85 d9 00 00 00    	jne    f010140c <mem_init+0x10f>
		totalmem = 1 * 1024 + extmem;
f0101333:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101339:	85 f6                	test   %esi,%esi
f010133b:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f010133e:	89 c2                	mov    %eax,%edx
f0101340:	c1 ea 02             	shr    $0x2,%edx
f0101343:	89 15 88 3e 21 f0    	mov    %edx,0xf0213e88
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101349:	89 c2                	mov    %eax,%edx
f010134b:	29 da                	sub    %ebx,%edx
f010134d:	52                   	push   %edx
f010134e:	53                   	push   %ebx
f010134f:	50                   	push   %eax
f0101350:	68 08 69 10 f0       	push   $0xf0106908
f0101355:	e8 55 25 00 00       	call   f01038af <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010135a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010135f:	e8 57 f7 ff ff       	call   f0100abb <boot_alloc>
f0101364:	a3 8c 3e 21 f0       	mov    %eax,0xf0213e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101369:	83 c4 0c             	add    $0xc,%esp
f010136c:	68 00 10 00 00       	push   $0x1000
f0101371:	6a 00                	push   $0x0
f0101373:	50                   	push   %eax
f0101374:	e8 9d 42 00 00       	call   f0105616 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101379:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010137e:	83 c4 10             	add    $0x10,%esp
f0101381:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101386:	0f 86 8a 00 00 00    	jbe    f0101416 <mem_init+0x119>
	return (physaddr_t)kva - KERNBASE;
f010138c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101392:	83 ca 05             	or     $0x5,%edx
f0101395:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo) * npages);
f010139b:	a1 88 3e 21 f0       	mov    0xf0213e88,%eax
f01013a0:	c1 e0 03             	shl    $0x3,%eax
f01013a3:	e8 13 f7 ff ff       	call   f0100abb <boot_alloc>
f01013a8:	a3 90 3e 21 f0       	mov    %eax,0xf0213e90
	memset(pages, 0, npages*sizeof(struct PageInfo));
f01013ad:	83 ec 04             	sub    $0x4,%esp
f01013b0:	8b 0d 88 3e 21 f0    	mov    0xf0213e88,%ecx
f01013b6:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013bd:	52                   	push   %edx
f01013be:	6a 00                	push   $0x0
f01013c0:	50                   	push   %eax
f01013c1:	e8 50 42 00 00       	call   f0105616 <memset>
	envs = (struct Env*)boot_alloc(sizeof(struct Env) * NENV);
f01013c6:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013cb:	e8 eb f6 ff ff       	call   f0100abb <boot_alloc>
f01013d0:	a3 44 32 21 f0       	mov    %eax,0xf0213244
	memset(envs, 0, NENV * sizeof(struct Env));
f01013d5:	83 c4 0c             	add    $0xc,%esp
f01013d8:	68 00 f0 01 00       	push   $0x1f000
f01013dd:	6a 00                	push   $0x0
f01013df:	50                   	push   %eax
f01013e0:	e8 31 42 00 00       	call   f0105616 <memset>
	page_init();
f01013e5:	e8 97 fa ff ff       	call   f0100e81 <page_init>
	check_page_free_list(1);
f01013ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01013ef:	e8 90 f7 ff ff       	call   f0100b84 <check_page_free_list>
	if (!pages)
f01013f4:	83 c4 10             	add    $0x10,%esp
f01013f7:	83 3d 90 3e 21 f0 00 	cmpl   $0x0,0xf0213e90
f01013fe:	74 2b                	je     f010142b <mem_init+0x12e>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101400:	a1 40 32 21 f0       	mov    0xf0213240,%eax
f0101405:	bb 00 00 00 00       	mov    $0x0,%ebx
f010140a:	eb 3b                	jmp    f0101447 <mem_init+0x14a>
		totalmem = 16 * 1024 + ext16mem;
f010140c:	05 00 40 00 00       	add    $0x4000,%eax
f0101411:	e9 28 ff ff ff       	jmp    f010133e <mem_init+0x41>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101416:	50                   	push   %eax
f0101417:	68 c8 62 10 f0       	push   $0xf01062c8
f010141c:	68 93 00 00 00       	push   $0x93
f0101421:	68 21 71 10 f0       	push   $0xf0107121
f0101426:	e8 15 ec ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f010142b:	83 ec 04             	sub    $0x4,%esp
f010142e:	68 1c 72 10 f0       	push   $0xf010721c
f0101433:	68 fb 02 00 00       	push   $0x2fb
f0101438:	68 21 71 10 f0       	push   $0xf0107121
f010143d:	e8 fe eb ff ff       	call   f0100040 <_panic>
		++nfree;
f0101442:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101445:	8b 00                	mov    (%eax),%eax
f0101447:	85 c0                	test   %eax,%eax
f0101449:	75 f7                	jne    f0101442 <mem_init+0x145>
	assert((pp0 = page_alloc(0)));
f010144b:	83 ec 0c             	sub    $0xc,%esp
f010144e:	6a 00                	push   $0x0
f0101450:	e8 f6 fa ff ff       	call   f0100f4b <page_alloc>
f0101455:	89 c7                	mov    %eax,%edi
f0101457:	83 c4 10             	add    $0x10,%esp
f010145a:	85 c0                	test   %eax,%eax
f010145c:	0f 84 12 02 00 00    	je     f0101674 <mem_init+0x377>
	assert((pp1 = page_alloc(0)));
f0101462:	83 ec 0c             	sub    $0xc,%esp
f0101465:	6a 00                	push   $0x0
f0101467:	e8 df fa ff ff       	call   f0100f4b <page_alloc>
f010146c:	89 c6                	mov    %eax,%esi
f010146e:	83 c4 10             	add    $0x10,%esp
f0101471:	85 c0                	test   %eax,%eax
f0101473:	0f 84 14 02 00 00    	je     f010168d <mem_init+0x390>
	assert((pp2 = page_alloc(0)));
f0101479:	83 ec 0c             	sub    $0xc,%esp
f010147c:	6a 00                	push   $0x0
f010147e:	e8 c8 fa ff ff       	call   f0100f4b <page_alloc>
f0101483:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101486:	83 c4 10             	add    $0x10,%esp
f0101489:	85 c0                	test   %eax,%eax
f010148b:	0f 84 15 02 00 00    	je     f01016a6 <mem_init+0x3a9>
	assert(pp1 && pp1 != pp0);
f0101491:	39 f7                	cmp    %esi,%edi
f0101493:	0f 84 26 02 00 00    	je     f01016bf <mem_init+0x3c2>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101499:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010149c:	39 c7                	cmp    %eax,%edi
f010149e:	0f 84 34 02 00 00    	je     f01016d8 <mem_init+0x3db>
f01014a4:	39 c6                	cmp    %eax,%esi
f01014a6:	0f 84 2c 02 00 00    	je     f01016d8 <mem_init+0x3db>
	return (pp - pages) << PGSHIFT;
f01014ac:	8b 0d 90 3e 21 f0    	mov    0xf0213e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014b2:	8b 15 88 3e 21 f0    	mov    0xf0213e88,%edx
f01014b8:	c1 e2 0c             	shl    $0xc,%edx
f01014bb:	89 f8                	mov    %edi,%eax
f01014bd:	29 c8                	sub    %ecx,%eax
f01014bf:	c1 f8 03             	sar    $0x3,%eax
f01014c2:	c1 e0 0c             	shl    $0xc,%eax
f01014c5:	39 d0                	cmp    %edx,%eax
f01014c7:	0f 83 24 02 00 00    	jae    f01016f1 <mem_init+0x3f4>
f01014cd:	89 f0                	mov    %esi,%eax
f01014cf:	29 c8                	sub    %ecx,%eax
f01014d1:	c1 f8 03             	sar    $0x3,%eax
f01014d4:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01014d7:	39 c2                	cmp    %eax,%edx
f01014d9:	0f 86 2b 02 00 00    	jbe    f010170a <mem_init+0x40d>
f01014df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014e2:	29 c8                	sub    %ecx,%eax
f01014e4:	c1 f8 03             	sar    $0x3,%eax
f01014e7:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01014ea:	39 c2                	cmp    %eax,%edx
f01014ec:	0f 86 31 02 00 00    	jbe    f0101723 <mem_init+0x426>
	fl = page_free_list;
f01014f2:	a1 40 32 21 f0       	mov    0xf0213240,%eax
f01014f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014fa:	c7 05 40 32 21 f0 00 	movl   $0x0,0xf0213240
f0101501:	00 00 00 
	assert(!page_alloc(0));
f0101504:	83 ec 0c             	sub    $0xc,%esp
f0101507:	6a 00                	push   $0x0
f0101509:	e8 3d fa ff ff       	call   f0100f4b <page_alloc>
f010150e:	83 c4 10             	add    $0x10,%esp
f0101511:	85 c0                	test   %eax,%eax
f0101513:	0f 85 23 02 00 00    	jne    f010173c <mem_init+0x43f>
	page_free(pp0);
f0101519:	83 ec 0c             	sub    $0xc,%esp
f010151c:	57                   	push   %edi
f010151d:	e8 9b fa ff ff       	call   f0100fbd <page_free>
	page_free(pp1);
f0101522:	89 34 24             	mov    %esi,(%esp)
f0101525:	e8 93 fa ff ff       	call   f0100fbd <page_free>
	page_free(pp2);
f010152a:	83 c4 04             	add    $0x4,%esp
f010152d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101530:	e8 88 fa ff ff       	call   f0100fbd <page_free>
	assert((pp0 = page_alloc(0)));
f0101535:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010153c:	e8 0a fa ff ff       	call   f0100f4b <page_alloc>
f0101541:	89 c6                	mov    %eax,%esi
f0101543:	83 c4 10             	add    $0x10,%esp
f0101546:	85 c0                	test   %eax,%eax
f0101548:	0f 84 07 02 00 00    	je     f0101755 <mem_init+0x458>
	assert((pp1 = page_alloc(0)));
f010154e:	83 ec 0c             	sub    $0xc,%esp
f0101551:	6a 00                	push   $0x0
f0101553:	e8 f3 f9 ff ff       	call   f0100f4b <page_alloc>
f0101558:	89 c7                	mov    %eax,%edi
f010155a:	83 c4 10             	add    $0x10,%esp
f010155d:	85 c0                	test   %eax,%eax
f010155f:	0f 84 09 02 00 00    	je     f010176e <mem_init+0x471>
	assert((pp2 = page_alloc(0)));
f0101565:	83 ec 0c             	sub    $0xc,%esp
f0101568:	6a 00                	push   $0x0
f010156a:	e8 dc f9 ff ff       	call   f0100f4b <page_alloc>
f010156f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101572:	83 c4 10             	add    $0x10,%esp
f0101575:	85 c0                	test   %eax,%eax
f0101577:	0f 84 0a 02 00 00    	je     f0101787 <mem_init+0x48a>
	assert(pp1 && pp1 != pp0);
f010157d:	39 fe                	cmp    %edi,%esi
f010157f:	0f 84 1b 02 00 00    	je     f01017a0 <mem_init+0x4a3>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101585:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101588:	39 c7                	cmp    %eax,%edi
f010158a:	0f 84 29 02 00 00    	je     f01017b9 <mem_init+0x4bc>
f0101590:	39 c6                	cmp    %eax,%esi
f0101592:	0f 84 21 02 00 00    	je     f01017b9 <mem_init+0x4bc>
	assert(!page_alloc(0));
f0101598:	83 ec 0c             	sub    $0xc,%esp
f010159b:	6a 00                	push   $0x0
f010159d:	e8 a9 f9 ff ff       	call   f0100f4b <page_alloc>
f01015a2:	83 c4 10             	add    $0x10,%esp
f01015a5:	85 c0                	test   %eax,%eax
f01015a7:	0f 85 25 02 00 00    	jne    f01017d2 <mem_init+0x4d5>
f01015ad:	89 f0                	mov    %esi,%eax
f01015af:	2b 05 90 3e 21 f0    	sub    0xf0213e90,%eax
f01015b5:	c1 f8 03             	sar    $0x3,%eax
f01015b8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01015bb:	89 c2                	mov    %eax,%edx
f01015bd:	c1 ea 0c             	shr    $0xc,%edx
f01015c0:	3b 15 88 3e 21 f0    	cmp    0xf0213e88,%edx
f01015c6:	0f 83 1f 02 00 00    	jae    f01017eb <mem_init+0x4ee>
	memset(page2kva(pp0), 1, PGSIZE);
f01015cc:	83 ec 04             	sub    $0x4,%esp
f01015cf:	68 00 10 00 00       	push   $0x1000
f01015d4:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015d6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015db:	50                   	push   %eax
f01015dc:	e8 35 40 00 00       	call   f0105616 <memset>
	page_free(pp0);
f01015e1:	89 34 24             	mov    %esi,(%esp)
f01015e4:	e8 d4 f9 ff ff       	call   f0100fbd <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015f0:	e8 56 f9 ff ff       	call   f0100f4b <page_alloc>
f01015f5:	83 c4 10             	add    $0x10,%esp
f01015f8:	85 c0                	test   %eax,%eax
f01015fa:	0f 84 fd 01 00 00    	je     f01017fd <mem_init+0x500>
	assert(pp && pp0 == pp);
f0101600:	39 c6                	cmp    %eax,%esi
f0101602:	0f 85 0e 02 00 00    	jne    f0101816 <mem_init+0x519>
	return (pp - pages) << PGSHIFT;
f0101608:	89 f2                	mov    %esi,%edx
f010160a:	2b 15 90 3e 21 f0    	sub    0xf0213e90,%edx
f0101610:	c1 fa 03             	sar    $0x3,%edx
f0101613:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101616:	89 d0                	mov    %edx,%eax
f0101618:	c1 e8 0c             	shr    $0xc,%eax
f010161b:	3b 05 88 3e 21 f0    	cmp    0xf0213e88,%eax
f0101621:	0f 83 08 02 00 00    	jae    f010182f <mem_init+0x532>
	return (void *)(pa + KERNBASE);
f0101627:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010162d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101633:	80 38 00             	cmpb   $0x0,(%eax)
f0101636:	0f 85 05 02 00 00    	jne    f0101841 <mem_init+0x544>
f010163c:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f010163f:	39 d0                	cmp    %edx,%eax
f0101641:	75 f0                	jne    f0101633 <mem_init+0x336>
	page_free_list = fl;
f0101643:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101646:	a3 40 32 21 f0       	mov    %eax,0xf0213240
	page_free(pp0);
f010164b:	83 ec 0c             	sub    $0xc,%esp
f010164e:	56                   	push   %esi
f010164f:	e8 69 f9 ff ff       	call   f0100fbd <page_free>
	page_free(pp1);
f0101654:	89 3c 24             	mov    %edi,(%esp)
f0101657:	e8 61 f9 ff ff       	call   f0100fbd <page_free>
	page_free(pp2);
f010165c:	83 c4 04             	add    $0x4,%esp
f010165f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101662:	e8 56 f9 ff ff       	call   f0100fbd <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101667:	a1 40 32 21 f0       	mov    0xf0213240,%eax
f010166c:	83 c4 10             	add    $0x10,%esp
f010166f:	e9 eb 01 00 00       	jmp    f010185f <mem_init+0x562>
	assert((pp0 = page_alloc(0)));
f0101674:	68 37 72 10 f0       	push   $0xf0107237
f0101679:	68 47 71 10 f0       	push   $0xf0107147
f010167e:	68 03 03 00 00       	push   $0x303
f0101683:	68 21 71 10 f0       	push   $0xf0107121
f0101688:	e8 b3 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010168d:	68 4d 72 10 f0       	push   $0xf010724d
f0101692:	68 47 71 10 f0       	push   $0xf0107147
f0101697:	68 04 03 00 00       	push   $0x304
f010169c:	68 21 71 10 f0       	push   $0xf0107121
f01016a1:	e8 9a e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016a6:	68 63 72 10 f0       	push   $0xf0107263
f01016ab:	68 47 71 10 f0       	push   $0xf0107147
f01016b0:	68 05 03 00 00       	push   $0x305
f01016b5:	68 21 71 10 f0       	push   $0xf0107121
f01016ba:	e8 81 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01016bf:	68 79 72 10 f0       	push   $0xf0107279
f01016c4:	68 47 71 10 f0       	push   $0xf0107147
f01016c9:	68 08 03 00 00       	push   $0x308
f01016ce:	68 21 71 10 f0       	push   $0xf0107121
f01016d3:	e8 68 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016d8:	68 44 69 10 f0       	push   $0xf0106944
f01016dd:	68 47 71 10 f0       	push   $0xf0107147
f01016e2:	68 09 03 00 00       	push   $0x309
f01016e7:	68 21 71 10 f0       	push   $0xf0107121
f01016ec:	e8 4f e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01016f1:	68 8b 72 10 f0       	push   $0xf010728b
f01016f6:	68 47 71 10 f0       	push   $0xf0107147
f01016fb:	68 0a 03 00 00       	push   $0x30a
f0101700:	68 21 71 10 f0       	push   $0xf0107121
f0101705:	e8 36 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010170a:	68 a8 72 10 f0       	push   $0xf01072a8
f010170f:	68 47 71 10 f0       	push   $0xf0107147
f0101714:	68 0b 03 00 00       	push   $0x30b
f0101719:	68 21 71 10 f0       	push   $0xf0107121
f010171e:	e8 1d e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101723:	68 c5 72 10 f0       	push   $0xf01072c5
f0101728:	68 47 71 10 f0       	push   $0xf0107147
f010172d:	68 0c 03 00 00       	push   $0x30c
f0101732:	68 21 71 10 f0       	push   $0xf0107121
f0101737:	e8 04 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010173c:	68 e2 72 10 f0       	push   $0xf01072e2
f0101741:	68 47 71 10 f0       	push   $0xf0107147
f0101746:	68 13 03 00 00       	push   $0x313
f010174b:	68 21 71 10 f0       	push   $0xf0107121
f0101750:	e8 eb e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0101755:	68 37 72 10 f0       	push   $0xf0107237
f010175a:	68 47 71 10 f0       	push   $0xf0107147
f010175f:	68 1a 03 00 00       	push   $0x31a
f0101764:	68 21 71 10 f0       	push   $0xf0107121
f0101769:	e8 d2 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010176e:	68 4d 72 10 f0       	push   $0xf010724d
f0101773:	68 47 71 10 f0       	push   $0xf0107147
f0101778:	68 1b 03 00 00       	push   $0x31b
f010177d:	68 21 71 10 f0       	push   $0xf0107121
f0101782:	e8 b9 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101787:	68 63 72 10 f0       	push   $0xf0107263
f010178c:	68 47 71 10 f0       	push   $0xf0107147
f0101791:	68 1c 03 00 00       	push   $0x31c
f0101796:	68 21 71 10 f0       	push   $0xf0107121
f010179b:	e8 a0 e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01017a0:	68 79 72 10 f0       	push   $0xf0107279
f01017a5:	68 47 71 10 f0       	push   $0xf0107147
f01017aa:	68 1e 03 00 00       	push   $0x31e
f01017af:	68 21 71 10 f0       	push   $0xf0107121
f01017b4:	e8 87 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017b9:	68 44 69 10 f0       	push   $0xf0106944
f01017be:	68 47 71 10 f0       	push   $0xf0107147
f01017c3:	68 1f 03 00 00       	push   $0x31f
f01017c8:	68 21 71 10 f0       	push   $0xf0107121
f01017cd:	e8 6e e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017d2:	68 e2 72 10 f0       	push   $0xf01072e2
f01017d7:	68 47 71 10 f0       	push   $0xf0107147
f01017dc:	68 20 03 00 00       	push   $0x320
f01017e1:	68 21 71 10 f0       	push   $0xf0107121
f01017e6:	e8 55 e8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017eb:	50                   	push   %eax
f01017ec:	68 a4 62 10 f0       	push   $0xf01062a4
f01017f1:	6a 58                	push   $0x58
f01017f3:	68 2d 71 10 f0       	push   $0xf010712d
f01017f8:	e8 43 e8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017fd:	68 f1 72 10 f0       	push   $0xf01072f1
f0101802:	68 47 71 10 f0       	push   $0xf0107147
f0101807:	68 25 03 00 00       	push   $0x325
f010180c:	68 21 71 10 f0       	push   $0xf0107121
f0101811:	e8 2a e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101816:	68 0f 73 10 f0       	push   $0xf010730f
f010181b:	68 47 71 10 f0       	push   $0xf0107147
f0101820:	68 26 03 00 00       	push   $0x326
f0101825:	68 21 71 10 f0       	push   $0xf0107121
f010182a:	e8 11 e8 ff ff       	call   f0100040 <_panic>
f010182f:	52                   	push   %edx
f0101830:	68 a4 62 10 f0       	push   $0xf01062a4
f0101835:	6a 58                	push   $0x58
f0101837:	68 2d 71 10 f0       	push   $0xf010712d
f010183c:	e8 ff e7 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f0101841:	68 1f 73 10 f0       	push   $0xf010731f
f0101846:	68 47 71 10 f0       	push   $0xf0107147
f010184b:	68 29 03 00 00       	push   $0x329
f0101850:	68 21 71 10 f0       	push   $0xf0107121
f0101855:	e8 e6 e7 ff ff       	call   f0100040 <_panic>
		--nfree;
f010185a:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010185d:	8b 00                	mov    (%eax),%eax
f010185f:	85 c0                	test   %eax,%eax
f0101861:	75 f7                	jne    f010185a <mem_init+0x55d>
	assert(nfree == 0);
f0101863:	85 db                	test   %ebx,%ebx
f0101865:	0f 85 64 09 00 00    	jne    f01021cf <mem_init+0xed2>
	cprintf("check_page_alloc() succeeded!\n");
f010186b:	83 ec 0c             	sub    $0xc,%esp
f010186e:	68 64 69 10 f0       	push   $0xf0106964
f0101873:	e8 37 20 00 00       	call   f01038af <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101878:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010187f:	e8 c7 f6 ff ff       	call   f0100f4b <page_alloc>
f0101884:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101887:	83 c4 10             	add    $0x10,%esp
f010188a:	85 c0                	test   %eax,%eax
f010188c:	0f 84 56 09 00 00    	je     f01021e8 <mem_init+0xeeb>
	assert((pp1 = page_alloc(0)));
f0101892:	83 ec 0c             	sub    $0xc,%esp
f0101895:	6a 00                	push   $0x0
f0101897:	e8 af f6 ff ff       	call   f0100f4b <page_alloc>
f010189c:	89 c3                	mov    %eax,%ebx
f010189e:	83 c4 10             	add    $0x10,%esp
f01018a1:	85 c0                	test   %eax,%eax
f01018a3:	0f 84 58 09 00 00    	je     f0102201 <mem_init+0xf04>
	assert((pp2 = page_alloc(0)));
f01018a9:	83 ec 0c             	sub    $0xc,%esp
f01018ac:	6a 00                	push   $0x0
f01018ae:	e8 98 f6 ff ff       	call   f0100f4b <page_alloc>
f01018b3:	89 c6                	mov    %eax,%esi
f01018b5:	83 c4 10             	add    $0x10,%esp
f01018b8:	85 c0                	test   %eax,%eax
f01018ba:	0f 84 5a 09 00 00    	je     f010221a <mem_init+0xf1d>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018c0:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01018c3:	0f 84 6a 09 00 00    	je     f0102233 <mem_init+0xf36>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018c9:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018cc:	0f 84 7a 09 00 00    	je     f010224c <mem_init+0xf4f>
f01018d2:	39 c3                	cmp    %eax,%ebx
f01018d4:	0f 84 72 09 00 00    	je     f010224c <mem_init+0xf4f>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018da:	a1 40 32 21 f0       	mov    0xf0213240,%eax
f01018df:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01018e2:	c7 05 40 32 21 f0 00 	movl   $0x0,0xf0213240
f01018e9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018ec:	83 ec 0c             	sub    $0xc,%esp
f01018ef:	6a 00                	push   $0x0
f01018f1:	e8 55 f6 ff ff       	call   f0100f4b <page_alloc>
f01018f6:	83 c4 10             	add    $0x10,%esp
f01018f9:	85 c0                	test   %eax,%eax
f01018fb:	0f 85 64 09 00 00    	jne    f0102265 <mem_init+0xf68>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101901:	83 ec 04             	sub    $0x4,%esp
f0101904:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101907:	50                   	push   %eax
f0101908:	6a 00                	push   $0x0
f010190a:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101910:	e8 24 f8 ff ff       	call   f0101139 <page_lookup>
f0101915:	83 c4 10             	add    $0x10,%esp
f0101918:	85 c0                	test   %eax,%eax
f010191a:	0f 85 5e 09 00 00    	jne    f010227e <mem_init+0xf81>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101920:	6a 02                	push   $0x2
f0101922:	6a 00                	push   $0x0
f0101924:	53                   	push   %ebx
f0101925:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f010192b:	e8 ec f8 ff ff       	call   f010121c <page_insert>
f0101930:	83 c4 10             	add    $0x10,%esp
f0101933:	85 c0                	test   %eax,%eax
f0101935:	0f 89 5c 09 00 00    	jns    f0102297 <mem_init+0xf9a>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010193b:	83 ec 0c             	sub    $0xc,%esp
f010193e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101941:	e8 77 f6 ff ff       	call   f0100fbd <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101946:	6a 02                	push   $0x2
f0101948:	6a 00                	push   $0x0
f010194a:	53                   	push   %ebx
f010194b:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101951:	e8 c6 f8 ff ff       	call   f010121c <page_insert>
f0101956:	83 c4 20             	add    $0x20,%esp
f0101959:	85 c0                	test   %eax,%eax
f010195b:	0f 85 4f 09 00 00    	jne    f01022b0 <mem_init+0xfb3>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101961:	8b 3d 8c 3e 21 f0    	mov    0xf0213e8c,%edi
	return (pp - pages) << PGSHIFT;
f0101967:	8b 0d 90 3e 21 f0    	mov    0xf0213e90,%ecx
f010196d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101970:	8b 17                	mov    (%edi),%edx
f0101972:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101978:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010197b:	29 c8                	sub    %ecx,%eax
f010197d:	c1 f8 03             	sar    $0x3,%eax
f0101980:	c1 e0 0c             	shl    $0xc,%eax
f0101983:	39 c2                	cmp    %eax,%edx
f0101985:	0f 85 3e 09 00 00    	jne    f01022c9 <mem_init+0xfcc>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010198b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101990:	89 f8                	mov    %edi,%eax
f0101992:	e8 89 f1 ff ff       	call   f0100b20 <check_va2pa>
f0101997:	89 da                	mov    %ebx,%edx
f0101999:	2b 55 d0             	sub    -0x30(%ebp),%edx
f010199c:	c1 fa 03             	sar    $0x3,%edx
f010199f:	c1 e2 0c             	shl    $0xc,%edx
f01019a2:	39 d0                	cmp    %edx,%eax
f01019a4:	0f 85 38 09 00 00    	jne    f01022e2 <mem_init+0xfe5>
	assert(pp1->pp_ref == 1);
f01019aa:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019af:	0f 85 46 09 00 00    	jne    f01022fb <mem_init+0xffe>
	assert(pp0->pp_ref == 1);
f01019b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019b8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019bd:	0f 85 51 09 00 00    	jne    f0102314 <mem_init+0x1017>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019c3:	6a 02                	push   $0x2
f01019c5:	68 00 10 00 00       	push   $0x1000
f01019ca:	56                   	push   %esi
f01019cb:	57                   	push   %edi
f01019cc:	e8 4b f8 ff ff       	call   f010121c <page_insert>
f01019d1:	83 c4 10             	add    $0x10,%esp
f01019d4:	85 c0                	test   %eax,%eax
f01019d6:	0f 85 51 09 00 00    	jne    f010232d <mem_init+0x1030>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019dc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019e1:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
f01019e6:	e8 35 f1 ff ff       	call   f0100b20 <check_va2pa>
f01019eb:	89 f2                	mov    %esi,%edx
f01019ed:	2b 15 90 3e 21 f0    	sub    0xf0213e90,%edx
f01019f3:	c1 fa 03             	sar    $0x3,%edx
f01019f6:	c1 e2 0c             	shl    $0xc,%edx
f01019f9:	39 d0                	cmp    %edx,%eax
f01019fb:	0f 85 45 09 00 00    	jne    f0102346 <mem_init+0x1049>
	assert(pp2->pp_ref == 1);
f0101a01:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a06:	0f 85 53 09 00 00    	jne    f010235f <mem_init+0x1062>

	// should be no free memory
	assert(!page_alloc(0));
f0101a0c:	83 ec 0c             	sub    $0xc,%esp
f0101a0f:	6a 00                	push   $0x0
f0101a11:	e8 35 f5 ff ff       	call   f0100f4b <page_alloc>
f0101a16:	83 c4 10             	add    $0x10,%esp
f0101a19:	85 c0                	test   %eax,%eax
f0101a1b:	0f 85 57 09 00 00    	jne    f0102378 <mem_init+0x107b>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a21:	6a 02                	push   $0x2
f0101a23:	68 00 10 00 00       	push   $0x1000
f0101a28:	56                   	push   %esi
f0101a29:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101a2f:	e8 e8 f7 ff ff       	call   f010121c <page_insert>
f0101a34:	83 c4 10             	add    $0x10,%esp
f0101a37:	85 c0                	test   %eax,%eax
f0101a39:	0f 85 52 09 00 00    	jne    f0102391 <mem_init+0x1094>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a3f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a44:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
f0101a49:	e8 d2 f0 ff ff       	call   f0100b20 <check_va2pa>
f0101a4e:	89 f2                	mov    %esi,%edx
f0101a50:	2b 15 90 3e 21 f0    	sub    0xf0213e90,%edx
f0101a56:	c1 fa 03             	sar    $0x3,%edx
f0101a59:	c1 e2 0c             	shl    $0xc,%edx
f0101a5c:	39 d0                	cmp    %edx,%eax
f0101a5e:	0f 85 46 09 00 00    	jne    f01023aa <mem_init+0x10ad>
	assert(pp2->pp_ref == 1);
f0101a64:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a69:	0f 85 54 09 00 00    	jne    f01023c3 <mem_init+0x10c6>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a6f:	83 ec 0c             	sub    $0xc,%esp
f0101a72:	6a 00                	push   $0x0
f0101a74:	e8 d2 f4 ff ff       	call   f0100f4b <page_alloc>
f0101a79:	83 c4 10             	add    $0x10,%esp
f0101a7c:	85 c0                	test   %eax,%eax
f0101a7e:	0f 85 58 09 00 00    	jne    f01023dc <mem_init+0x10df>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a84:	8b 15 8c 3e 21 f0    	mov    0xf0213e8c,%edx
f0101a8a:	8b 02                	mov    (%edx),%eax
f0101a8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101a91:	89 c1                	mov    %eax,%ecx
f0101a93:	c1 e9 0c             	shr    $0xc,%ecx
f0101a96:	3b 0d 88 3e 21 f0    	cmp    0xf0213e88,%ecx
f0101a9c:	0f 83 53 09 00 00    	jae    f01023f5 <mem_init+0x10f8>
	return (void *)(pa + KERNBASE);
f0101aa2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101aa7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101aaa:	83 ec 04             	sub    $0x4,%esp
f0101aad:	6a 00                	push   $0x0
f0101aaf:	68 00 10 00 00       	push   $0x1000
f0101ab4:	52                   	push   %edx
f0101ab5:	e8 67 f5 ff ff       	call   f0101021 <pgdir_walk>
f0101aba:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101abd:	8d 51 04             	lea    0x4(%ecx),%edx
f0101ac0:	83 c4 10             	add    $0x10,%esp
f0101ac3:	39 d0                	cmp    %edx,%eax
f0101ac5:	0f 85 3f 09 00 00    	jne    f010240a <mem_init+0x110d>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101acb:	6a 06                	push   $0x6
f0101acd:	68 00 10 00 00       	push   $0x1000
f0101ad2:	56                   	push   %esi
f0101ad3:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101ad9:	e8 3e f7 ff ff       	call   f010121c <page_insert>
f0101ade:	83 c4 10             	add    $0x10,%esp
f0101ae1:	85 c0                	test   %eax,%eax
f0101ae3:	0f 85 3a 09 00 00    	jne    f0102423 <mem_init+0x1126>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ae9:	8b 3d 8c 3e 21 f0    	mov    0xf0213e8c,%edi
f0101aef:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101af4:	89 f8                	mov    %edi,%eax
f0101af6:	e8 25 f0 ff ff       	call   f0100b20 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101afb:	89 f2                	mov    %esi,%edx
f0101afd:	2b 15 90 3e 21 f0    	sub    0xf0213e90,%edx
f0101b03:	c1 fa 03             	sar    $0x3,%edx
f0101b06:	c1 e2 0c             	shl    $0xc,%edx
f0101b09:	39 d0                	cmp    %edx,%eax
f0101b0b:	0f 85 2b 09 00 00    	jne    f010243c <mem_init+0x113f>
	assert(pp2->pp_ref == 1);
f0101b11:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b16:	0f 85 39 09 00 00    	jne    f0102455 <mem_init+0x1158>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b1c:	83 ec 04             	sub    $0x4,%esp
f0101b1f:	6a 00                	push   $0x0
f0101b21:	68 00 10 00 00       	push   $0x1000
f0101b26:	57                   	push   %edi
f0101b27:	e8 f5 f4 ff ff       	call   f0101021 <pgdir_walk>
f0101b2c:	83 c4 10             	add    $0x10,%esp
f0101b2f:	f6 00 04             	testb  $0x4,(%eax)
f0101b32:	0f 84 36 09 00 00    	je     f010246e <mem_init+0x1171>
	assert(kern_pgdir[0] & PTE_U);
f0101b38:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
f0101b3d:	f6 00 04             	testb  $0x4,(%eax)
f0101b40:	0f 84 41 09 00 00    	je     f0102487 <mem_init+0x118a>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b46:	6a 02                	push   $0x2
f0101b48:	68 00 10 00 00       	push   $0x1000
f0101b4d:	56                   	push   %esi
f0101b4e:	50                   	push   %eax
f0101b4f:	e8 c8 f6 ff ff       	call   f010121c <page_insert>
f0101b54:	83 c4 10             	add    $0x10,%esp
f0101b57:	85 c0                	test   %eax,%eax
f0101b59:	0f 85 41 09 00 00    	jne    f01024a0 <mem_init+0x11a3>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b5f:	83 ec 04             	sub    $0x4,%esp
f0101b62:	6a 00                	push   $0x0
f0101b64:	68 00 10 00 00       	push   $0x1000
f0101b69:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101b6f:	e8 ad f4 ff ff       	call   f0101021 <pgdir_walk>
f0101b74:	83 c4 10             	add    $0x10,%esp
f0101b77:	f6 00 02             	testb  $0x2,(%eax)
f0101b7a:	0f 84 39 09 00 00    	je     f01024b9 <mem_init+0x11bc>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b80:	83 ec 04             	sub    $0x4,%esp
f0101b83:	6a 00                	push   $0x0
f0101b85:	68 00 10 00 00       	push   $0x1000
f0101b8a:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101b90:	e8 8c f4 ff ff       	call   f0101021 <pgdir_walk>
f0101b95:	83 c4 10             	add    $0x10,%esp
f0101b98:	f6 00 04             	testb  $0x4,(%eax)
f0101b9b:	0f 85 31 09 00 00    	jne    f01024d2 <mem_init+0x11d5>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ba1:	6a 02                	push   $0x2
f0101ba3:	68 00 00 40 00       	push   $0x400000
f0101ba8:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bab:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101bb1:	e8 66 f6 ff ff       	call   f010121c <page_insert>
f0101bb6:	83 c4 10             	add    $0x10,%esp
f0101bb9:	85 c0                	test   %eax,%eax
f0101bbb:	0f 89 2a 09 00 00    	jns    f01024eb <mem_init+0x11ee>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101bc1:	6a 02                	push   $0x2
f0101bc3:	68 00 10 00 00       	push   $0x1000
f0101bc8:	53                   	push   %ebx
f0101bc9:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101bcf:	e8 48 f6 ff ff       	call   f010121c <page_insert>
f0101bd4:	83 c4 10             	add    $0x10,%esp
f0101bd7:	85 c0                	test   %eax,%eax
f0101bd9:	0f 85 25 09 00 00    	jne    f0102504 <mem_init+0x1207>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bdf:	83 ec 04             	sub    $0x4,%esp
f0101be2:	6a 00                	push   $0x0
f0101be4:	68 00 10 00 00       	push   $0x1000
f0101be9:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101bef:	e8 2d f4 ff ff       	call   f0101021 <pgdir_walk>
f0101bf4:	83 c4 10             	add    $0x10,%esp
f0101bf7:	f6 00 04             	testb  $0x4,(%eax)
f0101bfa:	0f 85 1d 09 00 00    	jne    f010251d <mem_init+0x1220>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c00:	8b 3d 8c 3e 21 f0    	mov    0xf0213e8c,%edi
f0101c06:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c0b:	89 f8                	mov    %edi,%eax
f0101c0d:	e8 0e ef ff ff       	call   f0100b20 <check_va2pa>
f0101c12:	89 c1                	mov    %eax,%ecx
f0101c14:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c17:	89 d8                	mov    %ebx,%eax
f0101c19:	2b 05 90 3e 21 f0    	sub    0xf0213e90,%eax
f0101c1f:	c1 f8 03             	sar    $0x3,%eax
f0101c22:	c1 e0 0c             	shl    $0xc,%eax
f0101c25:	39 c1                	cmp    %eax,%ecx
f0101c27:	0f 85 09 09 00 00    	jne    f0102536 <mem_init+0x1239>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c2d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c32:	89 f8                	mov    %edi,%eax
f0101c34:	e8 e7 ee ff ff       	call   f0100b20 <check_va2pa>
f0101c39:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101c3c:	0f 85 0d 09 00 00    	jne    f010254f <mem_init+0x1252>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c42:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c47:	0f 85 1b 09 00 00    	jne    f0102568 <mem_init+0x126b>
	assert(pp2->pp_ref == 0);
f0101c4d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c52:	0f 85 29 09 00 00    	jne    f0102581 <mem_init+0x1284>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c58:	83 ec 0c             	sub    $0xc,%esp
f0101c5b:	6a 00                	push   $0x0
f0101c5d:	e8 e9 f2 ff ff       	call   f0100f4b <page_alloc>
f0101c62:	83 c4 10             	add    $0x10,%esp
f0101c65:	39 c6                	cmp    %eax,%esi
f0101c67:	0f 85 2d 09 00 00    	jne    f010259a <mem_init+0x129d>
f0101c6d:	85 c0                	test   %eax,%eax
f0101c6f:	0f 84 25 09 00 00    	je     f010259a <mem_init+0x129d>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c75:	83 ec 08             	sub    $0x8,%esp
f0101c78:	6a 00                	push   $0x0
f0101c7a:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101c80:	e8 4f f5 ff ff       	call   f01011d4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c85:	8b 3d 8c 3e 21 f0    	mov    0xf0213e8c,%edi
f0101c8b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c90:	89 f8                	mov    %edi,%eax
f0101c92:	e8 89 ee ff ff       	call   f0100b20 <check_va2pa>
f0101c97:	83 c4 10             	add    $0x10,%esp
f0101c9a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c9d:	0f 85 10 09 00 00    	jne    f01025b3 <mem_init+0x12b6>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ca3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ca8:	89 f8                	mov    %edi,%eax
f0101caa:	e8 71 ee ff ff       	call   f0100b20 <check_va2pa>
f0101caf:	89 da                	mov    %ebx,%edx
f0101cb1:	2b 15 90 3e 21 f0    	sub    0xf0213e90,%edx
f0101cb7:	c1 fa 03             	sar    $0x3,%edx
f0101cba:	c1 e2 0c             	shl    $0xc,%edx
f0101cbd:	39 d0                	cmp    %edx,%eax
f0101cbf:	0f 85 07 09 00 00    	jne    f01025cc <mem_init+0x12cf>
	assert(pp1->pp_ref == 1);
f0101cc5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cca:	0f 85 15 09 00 00    	jne    f01025e5 <mem_init+0x12e8>
	assert(pp2->pp_ref == 0);
f0101cd0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101cd5:	0f 85 23 09 00 00    	jne    f01025fe <mem_init+0x1301>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101cdb:	6a 00                	push   $0x0
f0101cdd:	68 00 10 00 00       	push   $0x1000
f0101ce2:	53                   	push   %ebx
f0101ce3:	57                   	push   %edi
f0101ce4:	e8 33 f5 ff ff       	call   f010121c <page_insert>
f0101ce9:	83 c4 10             	add    $0x10,%esp
f0101cec:	85 c0                	test   %eax,%eax
f0101cee:	0f 85 23 09 00 00    	jne    f0102617 <mem_init+0x131a>
	assert(pp1->pp_ref);
f0101cf4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cf9:	0f 84 31 09 00 00    	je     f0102630 <mem_init+0x1333>
	assert(pp1->pp_link == NULL);
f0101cff:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101d02:	0f 85 41 09 00 00    	jne    f0102649 <mem_init+0x134c>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d08:	83 ec 08             	sub    $0x8,%esp
f0101d0b:	68 00 10 00 00       	push   $0x1000
f0101d10:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101d16:	e8 b9 f4 ff ff       	call   f01011d4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d1b:	8b 3d 8c 3e 21 f0    	mov    0xf0213e8c,%edi
f0101d21:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d26:	89 f8                	mov    %edi,%eax
f0101d28:	e8 f3 ed ff ff       	call   f0100b20 <check_va2pa>
f0101d2d:	83 c4 10             	add    $0x10,%esp
f0101d30:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d33:	0f 85 29 09 00 00    	jne    f0102662 <mem_init+0x1365>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d39:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d3e:	89 f8                	mov    %edi,%eax
f0101d40:	e8 db ed ff ff       	call   f0100b20 <check_va2pa>
f0101d45:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d48:	0f 85 2d 09 00 00    	jne    f010267b <mem_init+0x137e>
	assert(pp1->pp_ref == 0);
f0101d4e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d53:	0f 85 3b 09 00 00    	jne    f0102694 <mem_init+0x1397>
	assert(pp2->pp_ref == 0);
f0101d59:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d5e:	0f 85 49 09 00 00    	jne    f01026ad <mem_init+0x13b0>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d64:	83 ec 0c             	sub    $0xc,%esp
f0101d67:	6a 00                	push   $0x0
f0101d69:	e8 dd f1 ff ff       	call   f0100f4b <page_alloc>
f0101d6e:	83 c4 10             	add    $0x10,%esp
f0101d71:	85 c0                	test   %eax,%eax
f0101d73:	0f 84 4d 09 00 00    	je     f01026c6 <mem_init+0x13c9>
f0101d79:	39 c3                	cmp    %eax,%ebx
f0101d7b:	0f 85 45 09 00 00    	jne    f01026c6 <mem_init+0x13c9>

	// should be no free memory
	assert(!page_alloc(0));
f0101d81:	83 ec 0c             	sub    $0xc,%esp
f0101d84:	6a 00                	push   $0x0
f0101d86:	e8 c0 f1 ff ff       	call   f0100f4b <page_alloc>
f0101d8b:	83 c4 10             	add    $0x10,%esp
f0101d8e:	85 c0                	test   %eax,%eax
f0101d90:	0f 85 49 09 00 00    	jne    f01026df <mem_init+0x13e2>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d96:	8b 0d 8c 3e 21 f0    	mov    0xf0213e8c,%ecx
f0101d9c:	8b 11                	mov    (%ecx),%edx
f0101d9e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101da4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101da7:	2b 05 90 3e 21 f0    	sub    0xf0213e90,%eax
f0101dad:	c1 f8 03             	sar    $0x3,%eax
f0101db0:	c1 e0 0c             	shl    $0xc,%eax
f0101db3:	39 c2                	cmp    %eax,%edx
f0101db5:	0f 85 3d 09 00 00    	jne    f01026f8 <mem_init+0x13fb>
	kern_pgdir[0] = 0;
f0101dbb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101dc1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc4:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101dc9:	0f 85 42 09 00 00    	jne    f0102711 <mem_init+0x1414>
	pp0->pp_ref = 0;
f0101dcf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dd2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101dd8:	83 ec 0c             	sub    $0xc,%esp
f0101ddb:	50                   	push   %eax
f0101ddc:	e8 dc f1 ff ff       	call   f0100fbd <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101de1:	83 c4 0c             	add    $0xc,%esp
f0101de4:	6a 01                	push   $0x1
f0101de6:	68 00 10 40 00       	push   $0x401000
f0101deb:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101df1:	e8 2b f2 ff ff       	call   f0101021 <pgdir_walk>
f0101df6:	89 c7                	mov    %eax,%edi
f0101df8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101dfb:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
f0101e00:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e03:	8b 40 04             	mov    0x4(%eax),%eax
f0101e06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e0b:	8b 0d 88 3e 21 f0    	mov    0xf0213e88,%ecx
f0101e11:	89 c2                	mov    %eax,%edx
f0101e13:	c1 ea 0c             	shr    $0xc,%edx
f0101e16:	83 c4 10             	add    $0x10,%esp
f0101e19:	39 ca                	cmp    %ecx,%edx
f0101e1b:	0f 83 09 09 00 00    	jae    f010272a <mem_init+0x142d>
	assert(ptep == ptep1 + PTX(va));
f0101e21:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101e26:	39 c7                	cmp    %eax,%edi
f0101e28:	0f 85 11 09 00 00    	jne    f010273f <mem_init+0x1442>
	kern_pgdir[PDX(va)] = 0;
f0101e2e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e31:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101e38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e3b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e41:	2b 05 90 3e 21 f0    	sub    0xf0213e90,%eax
f0101e47:	c1 f8 03             	sar    $0x3,%eax
f0101e4a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e4d:	89 c2                	mov    %eax,%edx
f0101e4f:	c1 ea 0c             	shr    $0xc,%edx
f0101e52:	39 d1                	cmp    %edx,%ecx
f0101e54:	0f 86 fe 08 00 00    	jbe    f0102758 <mem_init+0x145b>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e5a:	83 ec 04             	sub    $0x4,%esp
f0101e5d:	68 00 10 00 00       	push   $0x1000
f0101e62:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e67:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e6c:	50                   	push   %eax
f0101e6d:	e8 a4 37 00 00       	call   f0105616 <memset>
	page_free(pp0);
f0101e72:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101e75:	89 3c 24             	mov    %edi,(%esp)
f0101e78:	e8 40 f1 ff ff       	call   f0100fbd <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e7d:	83 c4 0c             	add    $0xc,%esp
f0101e80:	6a 01                	push   $0x1
f0101e82:	6a 00                	push   $0x0
f0101e84:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101e8a:	e8 92 f1 ff ff       	call   f0101021 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101e8f:	89 fa                	mov    %edi,%edx
f0101e91:	2b 15 90 3e 21 f0    	sub    0xf0213e90,%edx
f0101e97:	c1 fa 03             	sar    $0x3,%edx
f0101e9a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e9d:	89 d0                	mov    %edx,%eax
f0101e9f:	c1 e8 0c             	shr    $0xc,%eax
f0101ea2:	83 c4 10             	add    $0x10,%esp
f0101ea5:	3b 05 88 3e 21 f0    	cmp    0xf0213e88,%eax
f0101eab:	0f 83 b9 08 00 00    	jae    f010276a <mem_init+0x146d>
	return (void *)(pa + KERNBASE);
f0101eb1:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101eb7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101eba:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101ec0:	f6 00 01             	testb  $0x1,(%eax)
f0101ec3:	0f 85 b3 08 00 00    	jne    f010277c <mem_init+0x147f>
f0101ec9:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101ecc:	39 d0                	cmp    %edx,%eax
f0101ece:	75 f0                	jne    f0101ec0 <mem_init+0xbc3>
	kern_pgdir[0] = 0;
f0101ed0:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
f0101ed5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101edb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ede:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101ee4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101ee7:	89 0d 40 32 21 f0    	mov    %ecx,0xf0213240

	// free the pages we took
	page_free(pp0);
f0101eed:	83 ec 0c             	sub    $0xc,%esp
f0101ef0:	50                   	push   %eax
f0101ef1:	e8 c7 f0 ff ff       	call   f0100fbd <page_free>
	page_free(pp1);
f0101ef6:	89 1c 24             	mov    %ebx,(%esp)
f0101ef9:	e8 bf f0 ff ff       	call   f0100fbd <page_free>
	page_free(pp2);
f0101efe:	89 34 24             	mov    %esi,(%esp)
f0101f01:	e8 b7 f0 ff ff       	call   f0100fbd <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101f06:	83 c4 08             	add    $0x8,%esp
f0101f09:	68 01 10 00 00       	push   $0x1001
f0101f0e:	6a 00                	push   $0x0
f0101f10:	e8 7b f3 ff ff       	call   f0101290 <mmio_map_region>
f0101f15:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101f17:	83 c4 08             	add    $0x8,%esp
f0101f1a:	68 00 10 00 00       	push   $0x1000
f0101f1f:	6a 00                	push   $0x0
f0101f21:	e8 6a f3 ff ff       	call   f0101290 <mmio_map_region>
f0101f26:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101f28:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f2e:	83 c4 10             	add    $0x10,%esp
f0101f31:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f37:	0f 86 58 08 00 00    	jbe    f0102795 <mem_init+0x1498>
f0101f3d:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f42:	0f 87 4d 08 00 00    	ja     f0102795 <mem_init+0x1498>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f48:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f4e:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f54:	0f 87 54 08 00 00    	ja     f01027ae <mem_init+0x14b1>
f0101f5a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f60:	0f 86 48 08 00 00    	jbe    f01027ae <mem_init+0x14b1>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f66:	89 da                	mov    %ebx,%edx
f0101f68:	09 f2                	or     %esi,%edx
f0101f6a:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f70:	0f 85 51 08 00 00    	jne    f01027c7 <mem_init+0x14ca>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f76:	39 c6                	cmp    %eax,%esi
f0101f78:	0f 82 62 08 00 00    	jb     f01027e0 <mem_init+0x14e3>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f7e:	8b 3d 8c 3e 21 f0    	mov    0xf0213e8c,%edi
f0101f84:	89 da                	mov    %ebx,%edx
f0101f86:	89 f8                	mov    %edi,%eax
f0101f88:	e8 93 eb ff ff       	call   f0100b20 <check_va2pa>
f0101f8d:	85 c0                	test   %eax,%eax
f0101f8f:	0f 85 64 08 00 00    	jne    f01027f9 <mem_init+0x14fc>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101f95:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101f9b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f9e:	89 c2                	mov    %eax,%edx
f0101fa0:	89 f8                	mov    %edi,%eax
f0101fa2:	e8 79 eb ff ff       	call   f0100b20 <check_va2pa>
f0101fa7:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101fac:	0f 85 60 08 00 00    	jne    f0102812 <mem_init+0x1515>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101fb2:	89 f2                	mov    %esi,%edx
f0101fb4:	89 f8                	mov    %edi,%eax
f0101fb6:	e8 65 eb ff ff       	call   f0100b20 <check_va2pa>
f0101fbb:	85 c0                	test   %eax,%eax
f0101fbd:	0f 85 68 08 00 00    	jne    f010282b <mem_init+0x152e>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101fc3:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101fc9:	89 f8                	mov    %edi,%eax
f0101fcb:	e8 50 eb ff ff       	call   f0100b20 <check_va2pa>
f0101fd0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fd3:	0f 85 6b 08 00 00    	jne    f0102844 <mem_init+0x1547>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0101fd9:	83 ec 04             	sub    $0x4,%esp
f0101fdc:	6a 00                	push   $0x0
f0101fde:	53                   	push   %ebx
f0101fdf:	57                   	push   %edi
f0101fe0:	e8 3c f0 ff ff       	call   f0101021 <pgdir_walk>
f0101fe5:	83 c4 10             	add    $0x10,%esp
f0101fe8:	f6 00 1a             	testb  $0x1a,(%eax)
f0101feb:	0f 84 6c 08 00 00    	je     f010285d <mem_init+0x1560>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0101ff1:	83 ec 04             	sub    $0x4,%esp
f0101ff4:	6a 00                	push   $0x0
f0101ff6:	53                   	push   %ebx
f0101ff7:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0101ffd:	e8 1f f0 ff ff       	call   f0101021 <pgdir_walk>
f0102002:	83 c4 10             	add    $0x10,%esp
f0102005:	f6 00 04             	testb  $0x4,(%eax)
f0102008:	0f 85 68 08 00 00    	jne    f0102876 <mem_init+0x1579>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010200e:	83 ec 04             	sub    $0x4,%esp
f0102011:	6a 00                	push   $0x0
f0102013:	53                   	push   %ebx
f0102014:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f010201a:	e8 02 f0 ff ff       	call   f0101021 <pgdir_walk>
f010201f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102025:	83 c4 0c             	add    $0xc,%esp
f0102028:	6a 00                	push   $0x0
f010202a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010202d:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0102033:	e8 e9 ef ff ff       	call   f0101021 <pgdir_walk>
f0102038:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010203e:	83 c4 0c             	add    $0xc,%esp
f0102041:	6a 00                	push   $0x0
f0102043:	56                   	push   %esi
f0102044:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f010204a:	e8 d2 ef ff ff       	call   f0101021 <pgdir_walk>
f010204f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102055:	c7 04 24 12 74 10 f0 	movl   $0xf0107412,(%esp)
f010205c:	e8 4e 18 00 00       	call   f01038af <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102061:	a1 90 3e 21 f0       	mov    0xf0213e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102066:	83 c4 10             	add    $0x10,%esp
f0102069:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010206e:	0f 86 1b 08 00 00    	jbe    f010288f <mem_init+0x1592>
f0102074:	83 ec 08             	sub    $0x8,%esp
f0102077:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102079:	05 00 00 00 10       	add    $0x10000000,%eax
f010207e:	50                   	push   %eax
f010207f:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102084:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102089:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
f010208e:	e8 21 f0 ff ff       	call   f01010b4 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102093:	a1 44 32 21 f0       	mov    0xf0213244,%eax
	if ((uint32_t)kva < KERNBASE)
f0102098:	83 c4 10             	add    $0x10,%esp
f010209b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020a0:	0f 86 fe 07 00 00    	jbe    f01028a4 <mem_init+0x15a7>
f01020a6:	83 ec 08             	sub    $0x8,%esp
f01020a9:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01020ab:	05 00 00 00 10       	add    $0x10000000,%eax
f01020b0:	50                   	push   %eax
f01020b1:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01020b6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01020bb:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
f01020c0:	e8 ef ef ff ff       	call   f01010b4 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020c5:	83 c4 10             	add    $0x10,%esp
f01020c8:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f01020cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020d2:	0f 86 e1 07 00 00    	jbe    f01028b9 <mem_init+0x15bc>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01020d8:	83 ec 08             	sub    $0x8,%esp
f01020db:	6a 02                	push   $0x2
f01020dd:	68 00 70 11 00       	push   $0x117000
f01020e2:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020e7:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020ec:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
f01020f1:	e8 be ef ff ff       	call   f01010b4 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f01020f6:	83 c4 08             	add    $0x8,%esp
f01020f9:	6a 02                	push   $0x2
f01020fb:	6a 00                	push   $0x0
f01020fd:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102102:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102107:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
f010210c:	e8 a3 ef ff ff       	call   f01010b4 <boot_map_region>
f0102111:	c7 45 cc 00 50 21 f0 	movl   $0xf0215000,-0x34(%ebp)
f0102118:	bf 00 50 25 f0       	mov    $0xf0255000,%edi
f010211d:	83 c4 10             	add    $0x10,%esp
f0102120:	bb 00 50 21 f0       	mov    $0xf0215000,%ebx
f0102125:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010212a:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102130:	0f 86 98 07 00 00    	jbe    f01028ce <mem_init+0x15d1>
		boot_map_region(kern_pgdir, 
f0102136:	83 ec 08             	sub    $0x8,%esp
f0102139:	6a 02                	push   $0x2
f010213b:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102141:	50                   	push   %eax
f0102142:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102147:	89 f2                	mov    %esi,%edx
f0102149:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
f010214e:	e8 61 ef ff ff       	call   f01010b4 <boot_map_region>
f0102153:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102159:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for (i = 0; i < NCPU; ++i) {
f010215f:	83 c4 10             	add    $0x10,%esp
f0102162:	39 fb                	cmp    %edi,%ebx
f0102164:	75 c4                	jne    f010212a <mem_init+0xe2d>
	pgdir = kern_pgdir;
f0102166:	8b 3d 8c 3e 21 f0    	mov    0xf0213e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010216c:	a1 88 3e 21 f0       	mov    0xf0213e88,%eax
f0102171:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102174:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010217b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102180:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102183:	a1 90 3e 21 f0       	mov    0xf0213e90,%eax
f0102188:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010218b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f010218e:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
	for (i = 0; i < n; i += PGSIZE)
f0102194:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102199:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010219c:	0f 86 71 07 00 00    	jbe    f0102913 <mem_init+0x1616>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021a2:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01021a8:	89 f8                	mov    %edi,%eax
f01021aa:	e8 71 e9 ff ff       	call   f0100b20 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01021af:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01021b6:	0f 86 27 07 00 00    	jbe    f01028e3 <mem_init+0x15e6>
f01021bc:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f01021bf:	39 d0                	cmp    %edx,%eax
f01021c1:	0f 85 33 07 00 00    	jne    f01028fa <mem_init+0x15fd>
	for (i = 0; i < n; i += PGSIZE)
f01021c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01021cd:	eb ca                	jmp    f0102199 <mem_init+0xe9c>
	assert(nfree == 0);
f01021cf:	68 29 73 10 f0       	push   $0xf0107329
f01021d4:	68 47 71 10 f0       	push   $0xf0107147
f01021d9:	68 36 03 00 00       	push   $0x336
f01021de:	68 21 71 10 f0       	push   $0xf0107121
f01021e3:	e8 58 de ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01021e8:	68 37 72 10 f0       	push   $0xf0107237
f01021ed:	68 47 71 10 f0       	push   $0xf0107147
f01021f2:	68 9c 03 00 00       	push   $0x39c
f01021f7:	68 21 71 10 f0       	push   $0xf0107121
f01021fc:	e8 3f de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102201:	68 4d 72 10 f0       	push   $0xf010724d
f0102206:	68 47 71 10 f0       	push   $0xf0107147
f010220b:	68 9d 03 00 00       	push   $0x39d
f0102210:	68 21 71 10 f0       	push   $0xf0107121
f0102215:	e8 26 de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010221a:	68 63 72 10 f0       	push   $0xf0107263
f010221f:	68 47 71 10 f0       	push   $0xf0107147
f0102224:	68 9e 03 00 00       	push   $0x39e
f0102229:	68 21 71 10 f0       	push   $0xf0107121
f010222e:	e8 0d de ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0102233:	68 79 72 10 f0       	push   $0xf0107279
f0102238:	68 47 71 10 f0       	push   $0xf0107147
f010223d:	68 a1 03 00 00       	push   $0x3a1
f0102242:	68 21 71 10 f0       	push   $0xf0107121
f0102247:	e8 f4 dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010224c:	68 44 69 10 f0       	push   $0xf0106944
f0102251:	68 47 71 10 f0       	push   $0xf0107147
f0102256:	68 a2 03 00 00       	push   $0x3a2
f010225b:	68 21 71 10 f0       	push   $0xf0107121
f0102260:	e8 db dd ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102265:	68 e2 72 10 f0       	push   $0xf01072e2
f010226a:	68 47 71 10 f0       	push   $0xf0107147
f010226f:	68 a9 03 00 00       	push   $0x3a9
f0102274:	68 21 71 10 f0       	push   $0xf0107121
f0102279:	e8 c2 dd ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010227e:	68 84 69 10 f0       	push   $0xf0106984
f0102283:	68 47 71 10 f0       	push   $0xf0107147
f0102288:	68 ac 03 00 00       	push   $0x3ac
f010228d:	68 21 71 10 f0       	push   $0xf0107121
f0102292:	e8 a9 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102297:	68 bc 69 10 f0       	push   $0xf01069bc
f010229c:	68 47 71 10 f0       	push   $0xf0107147
f01022a1:	68 af 03 00 00       	push   $0x3af
f01022a6:	68 21 71 10 f0       	push   $0xf0107121
f01022ab:	e8 90 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022b0:	68 ec 69 10 f0       	push   $0xf01069ec
f01022b5:	68 47 71 10 f0       	push   $0xf0107147
f01022ba:	68 b3 03 00 00       	push   $0x3b3
f01022bf:	68 21 71 10 f0       	push   $0xf0107121
f01022c4:	e8 77 dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022c9:	68 1c 6a 10 f0       	push   $0xf0106a1c
f01022ce:	68 47 71 10 f0       	push   $0xf0107147
f01022d3:	68 b4 03 00 00       	push   $0x3b4
f01022d8:	68 21 71 10 f0       	push   $0xf0107121
f01022dd:	e8 5e dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022e2:	68 44 6a 10 f0       	push   $0xf0106a44
f01022e7:	68 47 71 10 f0       	push   $0xf0107147
f01022ec:	68 b5 03 00 00       	push   $0x3b5
f01022f1:	68 21 71 10 f0       	push   $0xf0107121
f01022f6:	e8 45 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01022fb:	68 34 73 10 f0       	push   $0xf0107334
f0102300:	68 47 71 10 f0       	push   $0xf0107147
f0102305:	68 b6 03 00 00       	push   $0x3b6
f010230a:	68 21 71 10 f0       	push   $0xf0107121
f010230f:	e8 2c dd ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102314:	68 45 73 10 f0       	push   $0xf0107345
f0102319:	68 47 71 10 f0       	push   $0xf0107147
f010231e:	68 b7 03 00 00       	push   $0x3b7
f0102323:	68 21 71 10 f0       	push   $0xf0107121
f0102328:	e8 13 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010232d:	68 74 6a 10 f0       	push   $0xf0106a74
f0102332:	68 47 71 10 f0       	push   $0xf0107147
f0102337:	68 ba 03 00 00       	push   $0x3ba
f010233c:	68 21 71 10 f0       	push   $0xf0107121
f0102341:	e8 fa dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102346:	68 b0 6a 10 f0       	push   $0xf0106ab0
f010234b:	68 47 71 10 f0       	push   $0xf0107147
f0102350:	68 bb 03 00 00       	push   $0x3bb
f0102355:	68 21 71 10 f0       	push   $0xf0107121
f010235a:	e8 e1 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010235f:	68 56 73 10 f0       	push   $0xf0107356
f0102364:	68 47 71 10 f0       	push   $0xf0107147
f0102369:	68 bc 03 00 00       	push   $0x3bc
f010236e:	68 21 71 10 f0       	push   $0xf0107121
f0102373:	e8 c8 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102378:	68 e2 72 10 f0       	push   $0xf01072e2
f010237d:	68 47 71 10 f0       	push   $0xf0107147
f0102382:	68 bf 03 00 00       	push   $0x3bf
f0102387:	68 21 71 10 f0       	push   $0xf0107121
f010238c:	e8 af dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102391:	68 74 6a 10 f0       	push   $0xf0106a74
f0102396:	68 47 71 10 f0       	push   $0xf0107147
f010239b:	68 c2 03 00 00       	push   $0x3c2
f01023a0:	68 21 71 10 f0       	push   $0xf0107121
f01023a5:	e8 96 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023aa:	68 b0 6a 10 f0       	push   $0xf0106ab0
f01023af:	68 47 71 10 f0       	push   $0xf0107147
f01023b4:	68 c3 03 00 00       	push   $0x3c3
f01023b9:	68 21 71 10 f0       	push   $0xf0107121
f01023be:	e8 7d dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01023c3:	68 56 73 10 f0       	push   $0xf0107356
f01023c8:	68 47 71 10 f0       	push   $0xf0107147
f01023cd:	68 c4 03 00 00       	push   $0x3c4
f01023d2:	68 21 71 10 f0       	push   $0xf0107121
f01023d7:	e8 64 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01023dc:	68 e2 72 10 f0       	push   $0xf01072e2
f01023e1:	68 47 71 10 f0       	push   $0xf0107147
f01023e6:	68 c8 03 00 00       	push   $0x3c8
f01023eb:	68 21 71 10 f0       	push   $0xf0107121
f01023f0:	e8 4b dc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023f5:	50                   	push   %eax
f01023f6:	68 a4 62 10 f0       	push   $0xf01062a4
f01023fb:	68 cb 03 00 00       	push   $0x3cb
f0102400:	68 21 71 10 f0       	push   $0xf0107121
f0102405:	e8 36 dc ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010240a:	68 e0 6a 10 f0       	push   $0xf0106ae0
f010240f:	68 47 71 10 f0       	push   $0xf0107147
f0102414:	68 cc 03 00 00       	push   $0x3cc
f0102419:	68 21 71 10 f0       	push   $0xf0107121
f010241e:	e8 1d dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102423:	68 20 6b 10 f0       	push   $0xf0106b20
f0102428:	68 47 71 10 f0       	push   $0xf0107147
f010242d:	68 cf 03 00 00       	push   $0x3cf
f0102432:	68 21 71 10 f0       	push   $0xf0107121
f0102437:	e8 04 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010243c:	68 b0 6a 10 f0       	push   $0xf0106ab0
f0102441:	68 47 71 10 f0       	push   $0xf0107147
f0102446:	68 d0 03 00 00       	push   $0x3d0
f010244b:	68 21 71 10 f0       	push   $0xf0107121
f0102450:	e8 eb db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102455:	68 56 73 10 f0       	push   $0xf0107356
f010245a:	68 47 71 10 f0       	push   $0xf0107147
f010245f:	68 d1 03 00 00       	push   $0x3d1
f0102464:	68 21 71 10 f0       	push   $0xf0107121
f0102469:	e8 d2 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010246e:	68 60 6b 10 f0       	push   $0xf0106b60
f0102473:	68 47 71 10 f0       	push   $0xf0107147
f0102478:	68 d2 03 00 00       	push   $0x3d2
f010247d:	68 21 71 10 f0       	push   $0xf0107121
f0102482:	e8 b9 db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102487:	68 67 73 10 f0       	push   $0xf0107367
f010248c:	68 47 71 10 f0       	push   $0xf0107147
f0102491:	68 d3 03 00 00       	push   $0x3d3
f0102496:	68 21 71 10 f0       	push   $0xf0107121
f010249b:	e8 a0 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024a0:	68 74 6a 10 f0       	push   $0xf0106a74
f01024a5:	68 47 71 10 f0       	push   $0xf0107147
f01024aa:	68 d6 03 00 00       	push   $0x3d6
f01024af:	68 21 71 10 f0       	push   $0xf0107121
f01024b4:	e8 87 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01024b9:	68 94 6b 10 f0       	push   $0xf0106b94
f01024be:	68 47 71 10 f0       	push   $0xf0107147
f01024c3:	68 d7 03 00 00       	push   $0x3d7
f01024c8:	68 21 71 10 f0       	push   $0xf0107121
f01024cd:	e8 6e db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024d2:	68 c8 6b 10 f0       	push   $0xf0106bc8
f01024d7:	68 47 71 10 f0       	push   $0xf0107147
f01024dc:	68 d8 03 00 00       	push   $0x3d8
f01024e1:	68 21 71 10 f0       	push   $0xf0107121
f01024e6:	e8 55 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024eb:	68 00 6c 10 f0       	push   $0xf0106c00
f01024f0:	68 47 71 10 f0       	push   $0xf0107147
f01024f5:	68 db 03 00 00       	push   $0x3db
f01024fa:	68 21 71 10 f0       	push   $0xf0107121
f01024ff:	e8 3c db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102504:	68 38 6c 10 f0       	push   $0xf0106c38
f0102509:	68 47 71 10 f0       	push   $0xf0107147
f010250e:	68 de 03 00 00       	push   $0x3de
f0102513:	68 21 71 10 f0       	push   $0xf0107121
f0102518:	e8 23 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010251d:	68 c8 6b 10 f0       	push   $0xf0106bc8
f0102522:	68 47 71 10 f0       	push   $0xf0107147
f0102527:	68 df 03 00 00       	push   $0x3df
f010252c:	68 21 71 10 f0       	push   $0xf0107121
f0102531:	e8 0a db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102536:	68 74 6c 10 f0       	push   $0xf0106c74
f010253b:	68 47 71 10 f0       	push   $0xf0107147
f0102540:	68 e2 03 00 00       	push   $0x3e2
f0102545:	68 21 71 10 f0       	push   $0xf0107121
f010254a:	e8 f1 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010254f:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0102554:	68 47 71 10 f0       	push   $0xf0107147
f0102559:	68 e3 03 00 00       	push   $0x3e3
f010255e:	68 21 71 10 f0       	push   $0xf0107121
f0102563:	e8 d8 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102568:	68 7d 73 10 f0       	push   $0xf010737d
f010256d:	68 47 71 10 f0       	push   $0xf0107147
f0102572:	68 e5 03 00 00       	push   $0x3e5
f0102577:	68 21 71 10 f0       	push   $0xf0107121
f010257c:	e8 bf da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102581:	68 8e 73 10 f0       	push   $0xf010738e
f0102586:	68 47 71 10 f0       	push   $0xf0107147
f010258b:	68 e6 03 00 00       	push   $0x3e6
f0102590:	68 21 71 10 f0       	push   $0xf0107121
f0102595:	e8 a6 da ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010259a:	68 d0 6c 10 f0       	push   $0xf0106cd0
f010259f:	68 47 71 10 f0       	push   $0xf0107147
f01025a4:	68 e9 03 00 00       	push   $0x3e9
f01025a9:	68 21 71 10 f0       	push   $0xf0107121
f01025ae:	e8 8d da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025b3:	68 f4 6c 10 f0       	push   $0xf0106cf4
f01025b8:	68 47 71 10 f0       	push   $0xf0107147
f01025bd:	68 ed 03 00 00       	push   $0x3ed
f01025c2:	68 21 71 10 f0       	push   $0xf0107121
f01025c7:	e8 74 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025cc:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01025d1:	68 47 71 10 f0       	push   $0xf0107147
f01025d6:	68 ee 03 00 00       	push   $0x3ee
f01025db:	68 21 71 10 f0       	push   $0xf0107121
f01025e0:	e8 5b da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01025e5:	68 34 73 10 f0       	push   $0xf0107334
f01025ea:	68 47 71 10 f0       	push   $0xf0107147
f01025ef:	68 ef 03 00 00       	push   $0x3ef
f01025f4:	68 21 71 10 f0       	push   $0xf0107121
f01025f9:	e8 42 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025fe:	68 8e 73 10 f0       	push   $0xf010738e
f0102603:	68 47 71 10 f0       	push   $0xf0107147
f0102608:	68 f0 03 00 00       	push   $0x3f0
f010260d:	68 21 71 10 f0       	push   $0xf0107121
f0102612:	e8 29 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102617:	68 18 6d 10 f0       	push   $0xf0106d18
f010261c:	68 47 71 10 f0       	push   $0xf0107147
f0102621:	68 f3 03 00 00       	push   $0x3f3
f0102626:	68 21 71 10 f0       	push   $0xf0107121
f010262b:	e8 10 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102630:	68 9f 73 10 f0       	push   $0xf010739f
f0102635:	68 47 71 10 f0       	push   $0xf0107147
f010263a:	68 f4 03 00 00       	push   $0x3f4
f010263f:	68 21 71 10 f0       	push   $0xf0107121
f0102644:	e8 f7 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102649:	68 ab 73 10 f0       	push   $0xf01073ab
f010264e:	68 47 71 10 f0       	push   $0xf0107147
f0102653:	68 f5 03 00 00       	push   $0x3f5
f0102658:	68 21 71 10 f0       	push   $0xf0107121
f010265d:	e8 de d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102662:	68 f4 6c 10 f0       	push   $0xf0106cf4
f0102667:	68 47 71 10 f0       	push   $0xf0107147
f010266c:	68 f9 03 00 00       	push   $0x3f9
f0102671:	68 21 71 10 f0       	push   $0xf0107121
f0102676:	e8 c5 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010267b:	68 50 6d 10 f0       	push   $0xf0106d50
f0102680:	68 47 71 10 f0       	push   $0xf0107147
f0102685:	68 fa 03 00 00       	push   $0x3fa
f010268a:	68 21 71 10 f0       	push   $0xf0107121
f010268f:	e8 ac d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102694:	68 c0 73 10 f0       	push   $0xf01073c0
f0102699:	68 47 71 10 f0       	push   $0xf0107147
f010269e:	68 fb 03 00 00       	push   $0x3fb
f01026a3:	68 21 71 10 f0       	push   $0xf0107121
f01026a8:	e8 93 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026ad:	68 8e 73 10 f0       	push   $0xf010738e
f01026b2:	68 47 71 10 f0       	push   $0xf0107147
f01026b7:	68 fc 03 00 00       	push   $0x3fc
f01026bc:	68 21 71 10 f0       	push   $0xf0107121
f01026c1:	e8 7a d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01026c6:	68 78 6d 10 f0       	push   $0xf0106d78
f01026cb:	68 47 71 10 f0       	push   $0xf0107147
f01026d0:	68 ff 03 00 00       	push   $0x3ff
f01026d5:	68 21 71 10 f0       	push   $0xf0107121
f01026da:	e8 61 d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01026df:	68 e2 72 10 f0       	push   $0xf01072e2
f01026e4:	68 47 71 10 f0       	push   $0xf0107147
f01026e9:	68 02 04 00 00       	push   $0x402
f01026ee:	68 21 71 10 f0       	push   $0xf0107121
f01026f3:	e8 48 d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026f8:	68 1c 6a 10 f0       	push   $0xf0106a1c
f01026fd:	68 47 71 10 f0       	push   $0xf0107147
f0102702:	68 05 04 00 00       	push   $0x405
f0102707:	68 21 71 10 f0       	push   $0xf0107121
f010270c:	e8 2f d9 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102711:	68 45 73 10 f0       	push   $0xf0107345
f0102716:	68 47 71 10 f0       	push   $0xf0107147
f010271b:	68 07 04 00 00       	push   $0x407
f0102720:	68 21 71 10 f0       	push   $0xf0107121
f0102725:	e8 16 d9 ff ff       	call   f0100040 <_panic>
f010272a:	50                   	push   %eax
f010272b:	68 a4 62 10 f0       	push   $0xf01062a4
f0102730:	68 0e 04 00 00       	push   $0x40e
f0102735:	68 21 71 10 f0       	push   $0xf0107121
f010273a:	e8 01 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010273f:	68 d1 73 10 f0       	push   $0xf01073d1
f0102744:	68 47 71 10 f0       	push   $0xf0107147
f0102749:	68 0f 04 00 00       	push   $0x40f
f010274e:	68 21 71 10 f0       	push   $0xf0107121
f0102753:	e8 e8 d8 ff ff       	call   f0100040 <_panic>
f0102758:	50                   	push   %eax
f0102759:	68 a4 62 10 f0       	push   $0xf01062a4
f010275e:	6a 58                	push   $0x58
f0102760:	68 2d 71 10 f0       	push   $0xf010712d
f0102765:	e8 d6 d8 ff ff       	call   f0100040 <_panic>
f010276a:	52                   	push   %edx
f010276b:	68 a4 62 10 f0       	push   $0xf01062a4
f0102770:	6a 58                	push   $0x58
f0102772:	68 2d 71 10 f0       	push   $0xf010712d
f0102777:	e8 c4 d8 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010277c:	68 e9 73 10 f0       	push   $0xf01073e9
f0102781:	68 47 71 10 f0       	push   $0xf0107147
f0102786:	68 19 04 00 00       	push   $0x419
f010278b:	68 21 71 10 f0       	push   $0xf0107121
f0102790:	e8 ab d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102795:	68 9c 6d 10 f0       	push   $0xf0106d9c
f010279a:	68 47 71 10 f0       	push   $0xf0107147
f010279f:	68 29 04 00 00       	push   $0x429
f01027a4:	68 21 71 10 f0       	push   $0xf0107121
f01027a9:	e8 92 d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01027ae:	68 c4 6d 10 f0       	push   $0xf0106dc4
f01027b3:	68 47 71 10 f0       	push   $0xf0107147
f01027b8:	68 2a 04 00 00       	push   $0x42a
f01027bd:	68 21 71 10 f0       	push   $0xf0107121
f01027c2:	e8 79 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01027c7:	68 ec 6d 10 f0       	push   $0xf0106dec
f01027cc:	68 47 71 10 f0       	push   $0xf0107147
f01027d1:	68 2c 04 00 00       	push   $0x42c
f01027d6:	68 21 71 10 f0       	push   $0xf0107121
f01027db:	e8 60 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f01027e0:	68 00 74 10 f0       	push   $0xf0107400
f01027e5:	68 47 71 10 f0       	push   $0xf0107147
f01027ea:	68 2e 04 00 00       	push   $0x42e
f01027ef:	68 21 71 10 f0       	push   $0xf0107121
f01027f4:	e8 47 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01027f9:	68 14 6e 10 f0       	push   $0xf0106e14
f01027fe:	68 47 71 10 f0       	push   $0xf0107147
f0102803:	68 30 04 00 00       	push   $0x430
f0102808:	68 21 71 10 f0       	push   $0xf0107121
f010280d:	e8 2e d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102812:	68 38 6e 10 f0       	push   $0xf0106e38
f0102817:	68 47 71 10 f0       	push   $0xf0107147
f010281c:	68 31 04 00 00       	push   $0x431
f0102821:	68 21 71 10 f0       	push   $0xf0107121
f0102826:	e8 15 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010282b:	68 68 6e 10 f0       	push   $0xf0106e68
f0102830:	68 47 71 10 f0       	push   $0xf0107147
f0102835:	68 32 04 00 00       	push   $0x432
f010283a:	68 21 71 10 f0       	push   $0xf0107121
f010283f:	e8 fc d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102844:	68 8c 6e 10 f0       	push   $0xf0106e8c
f0102849:	68 47 71 10 f0       	push   $0xf0107147
f010284e:	68 33 04 00 00       	push   $0x433
f0102853:	68 21 71 10 f0       	push   $0xf0107121
f0102858:	e8 e3 d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010285d:	68 b8 6e 10 f0       	push   $0xf0106eb8
f0102862:	68 47 71 10 f0       	push   $0xf0107147
f0102867:	68 35 04 00 00       	push   $0x435
f010286c:	68 21 71 10 f0       	push   $0xf0107121
f0102871:	e8 ca d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102876:	68 fc 6e 10 f0       	push   $0xf0106efc
f010287b:	68 47 71 10 f0       	push   $0xf0107147
f0102880:	68 36 04 00 00       	push   $0x436
f0102885:	68 21 71 10 f0       	push   $0xf0107121
f010288a:	e8 b1 d7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010288f:	50                   	push   %eax
f0102890:	68 c8 62 10 f0       	push   $0xf01062c8
f0102895:	68 ba 00 00 00       	push   $0xba
f010289a:	68 21 71 10 f0       	push   $0xf0107121
f010289f:	e8 9c d7 ff ff       	call   f0100040 <_panic>
f01028a4:	50                   	push   %eax
f01028a5:	68 c8 62 10 f0       	push   $0xf01062c8
f01028aa:	68 c3 00 00 00       	push   $0xc3
f01028af:	68 21 71 10 f0       	push   $0xf0107121
f01028b4:	e8 87 d7 ff ff       	call   f0100040 <_panic>
f01028b9:	50                   	push   %eax
f01028ba:	68 c8 62 10 f0       	push   $0xf01062c8
f01028bf:	68 d0 00 00 00       	push   $0xd0
f01028c4:	68 21 71 10 f0       	push   $0xf0107121
f01028c9:	e8 72 d7 ff ff       	call   f0100040 <_panic>
f01028ce:	53                   	push   %ebx
f01028cf:	68 c8 62 10 f0       	push   $0xf01062c8
f01028d4:	68 13 01 00 00       	push   $0x113
f01028d9:	68 21 71 10 f0       	push   $0xf0107121
f01028de:	e8 5d d7 ff ff       	call   f0100040 <_panic>
f01028e3:	ff 75 c4             	pushl  -0x3c(%ebp)
f01028e6:	68 c8 62 10 f0       	push   $0xf01062c8
f01028eb:	68 4e 03 00 00       	push   $0x34e
f01028f0:	68 21 71 10 f0       	push   $0xf0107121
f01028f5:	e8 46 d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028fa:	68 30 6f 10 f0       	push   $0xf0106f30
f01028ff:	68 47 71 10 f0       	push   $0xf0107147
f0102904:	68 4e 03 00 00       	push   $0x34e
f0102909:	68 21 71 10 f0       	push   $0xf0107121
f010290e:	e8 2d d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102913:	a1 44 32 21 f0       	mov    0xf0213244,%eax
f0102918:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010291b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010291e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102923:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102929:	89 da                	mov    %ebx,%edx
f010292b:	89 f8                	mov    %edi,%eax
f010292d:	e8 ee e1 ff ff       	call   f0100b20 <check_va2pa>
f0102932:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102939:	76 22                	jbe    f010295d <mem_init+0x1660>
f010293b:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f010293e:	39 d0                	cmp    %edx,%eax
f0102940:	75 32                	jne    f0102974 <mem_init+0x1677>
f0102942:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102948:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f010294e:	75 d9                	jne    f0102929 <mem_init+0x162c>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102950:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0102953:	c1 e6 0c             	shl    $0xc,%esi
f0102956:	bb 00 00 00 00       	mov    $0x0,%ebx
f010295b:	eb 4b                	jmp    f01029a8 <mem_init+0x16ab>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010295d:	ff 75 d0             	pushl  -0x30(%ebp)
f0102960:	68 c8 62 10 f0       	push   $0xf01062c8
f0102965:	68 53 03 00 00       	push   $0x353
f010296a:	68 21 71 10 f0       	push   $0xf0107121
f010296f:	e8 cc d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102974:	68 64 6f 10 f0       	push   $0xf0106f64
f0102979:	68 47 71 10 f0       	push   $0xf0107147
f010297e:	68 53 03 00 00       	push   $0x353
f0102983:	68 21 71 10 f0       	push   $0xf0107121
f0102988:	e8 b3 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010298d:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102993:	89 f8                	mov    %edi,%eax
f0102995:	e8 86 e1 ff ff       	call   f0100b20 <check_va2pa>
f010299a:	39 c3                	cmp    %eax,%ebx
f010299c:	0f 85 f9 00 00 00    	jne    f0102a9b <mem_init+0x179e>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029a2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029a8:	39 f3                	cmp    %esi,%ebx
f01029aa:	72 e1                	jb     f010298d <mem_init+0x1690>
f01029ac:	c7 45 d4 00 50 21 f0 	movl   $0xf0215000,-0x2c(%ebp)
f01029b3:	be 00 80 ff ef       	mov    $0xefff8000,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029bb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01029be:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f01029c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01029c7:	89 f3                	mov    %esi,%ebx
f01029c9:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01029cc:	05 00 80 00 20       	add    $0x20008000,%eax
f01029d1:	89 75 c8             	mov    %esi,-0x38(%ebp)
f01029d4:	89 c6                	mov    %eax,%esi
f01029d6:	89 da                	mov    %ebx,%edx
f01029d8:	89 f8                	mov    %edi,%eax
f01029da:	e8 41 e1 ff ff       	call   f0100b20 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01029df:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01029e6:	0f 86 c8 00 00 00    	jbe    f0102ab4 <mem_init+0x17b7>
f01029ec:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01029ef:	39 d0                	cmp    %edx,%eax
f01029f1:	0f 85 d4 00 00 00    	jne    f0102acb <mem_init+0x17ce>
f01029f7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029fd:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102a00:	75 d4                	jne    f01029d6 <mem_init+0x16d9>
f0102a02:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0102a05:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a0b:	89 da                	mov    %ebx,%edx
f0102a0d:	89 f8                	mov    %edi,%eax
f0102a0f:	e8 0c e1 ff ff       	call   f0100b20 <check_va2pa>
f0102a14:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a17:	0f 85 c7 00 00 00    	jne    f0102ae4 <mem_init+0x17e7>
f0102a1d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a23:	39 f3                	cmp    %esi,%ebx
f0102a25:	75 e4                	jne    f0102a0b <mem_init+0x170e>
f0102a27:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102a2d:	81 45 cc 00 80 01 00 	addl   $0x18000,-0x34(%ebp)
f0102a34:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a37:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
	for (n = 0; n < NCPU; n++) {
f0102a3e:	3d 00 50 2d f0       	cmp    $0xf02d5000,%eax
f0102a43:	0f 85 6f ff ff ff    	jne    f01029b8 <mem_init+0x16bb>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a49:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f0102a4e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a53:	0f 87 a4 00 00 00    	ja     f0102afd <mem_init+0x1800>
				assert(pgdir[i] == 0);
f0102a59:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102a5d:	0f 85 dd 00 00 00    	jne    f0102b40 <mem_init+0x1843>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a63:	83 c0 01             	add    $0x1,%eax
f0102a66:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a6b:	0f 87 e8 00 00 00    	ja     f0102b59 <mem_init+0x185c>
		switch (i) {
f0102a71:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102a77:	83 fa 04             	cmp    $0x4,%edx
f0102a7a:	77 d2                	ja     f0102a4e <mem_init+0x1751>
			assert(pgdir[i] & PTE_P);
f0102a7c:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a80:	75 e1                	jne    f0102a63 <mem_init+0x1766>
f0102a82:	68 2b 74 10 f0       	push   $0xf010742b
f0102a87:	68 47 71 10 f0       	push   $0xf0107147
f0102a8c:	68 6c 03 00 00       	push   $0x36c
f0102a91:	68 21 71 10 f0       	push   $0xf0107121
f0102a96:	e8 a5 d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a9b:	68 98 6f 10 f0       	push   $0xf0106f98
f0102aa0:	68 47 71 10 f0       	push   $0xf0107147
f0102aa5:	68 57 03 00 00       	push   $0x357
f0102aaa:	68 21 71 10 f0       	push   $0xf0107121
f0102aaf:	e8 8c d5 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ab4:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102ab7:	68 c8 62 10 f0       	push   $0xf01062c8
f0102abc:	68 5f 03 00 00       	push   $0x35f
f0102ac1:	68 21 71 10 f0       	push   $0xf0107121
f0102ac6:	e8 75 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102acb:	68 c0 6f 10 f0       	push   $0xf0106fc0
f0102ad0:	68 47 71 10 f0       	push   $0xf0107147
f0102ad5:	68 5f 03 00 00       	push   $0x35f
f0102ada:	68 21 71 10 f0       	push   $0xf0107121
f0102adf:	e8 5c d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ae4:	68 08 70 10 f0       	push   $0xf0107008
f0102ae9:	68 47 71 10 f0       	push   $0xf0107147
f0102aee:	68 61 03 00 00       	push   $0x361
f0102af3:	68 21 71 10 f0       	push   $0xf0107121
f0102af8:	e8 43 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102afd:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102b00:	f6 c2 01             	test   $0x1,%dl
f0102b03:	74 22                	je     f0102b27 <mem_init+0x182a>
				assert(pgdir[i] & PTE_W);
f0102b05:	f6 c2 02             	test   $0x2,%dl
f0102b08:	0f 85 55 ff ff ff    	jne    f0102a63 <mem_init+0x1766>
f0102b0e:	68 3c 74 10 f0       	push   $0xf010743c
f0102b13:	68 47 71 10 f0       	push   $0xf0107147
f0102b18:	68 71 03 00 00       	push   $0x371
f0102b1d:	68 21 71 10 f0       	push   $0xf0107121
f0102b22:	e8 19 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b27:	68 2b 74 10 f0       	push   $0xf010742b
f0102b2c:	68 47 71 10 f0       	push   $0xf0107147
f0102b31:	68 70 03 00 00       	push   $0x370
f0102b36:	68 21 71 10 f0       	push   $0xf0107121
f0102b3b:	e8 00 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102b40:	68 4d 74 10 f0       	push   $0xf010744d
f0102b45:	68 47 71 10 f0       	push   $0xf0107147
f0102b4a:	68 73 03 00 00       	push   $0x373
f0102b4f:	68 21 71 10 f0       	push   $0xf0107121
f0102b54:	e8 e7 d4 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b59:	83 ec 0c             	sub    $0xc,%esp
f0102b5c:	68 2c 70 10 f0       	push   $0xf010702c
f0102b61:	e8 49 0d 00 00       	call   f01038af <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b66:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b6b:	83 c4 10             	add    $0x10,%esp
f0102b6e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b73:	0f 86 fe 01 00 00    	jbe    f0102d77 <mem_init+0x1a7a>
	return (physaddr_t)kva - KERNBASE;
f0102b79:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b7e:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b81:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b86:	e8 f9 df ff ff       	call   f0100b84 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b8b:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b8e:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b91:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b96:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b99:	83 ec 0c             	sub    $0xc,%esp
f0102b9c:	6a 00                	push   $0x0
f0102b9e:	e8 a8 e3 ff ff       	call   f0100f4b <page_alloc>
f0102ba3:	89 c3                	mov    %eax,%ebx
f0102ba5:	83 c4 10             	add    $0x10,%esp
f0102ba8:	85 c0                	test   %eax,%eax
f0102baa:	0f 84 dc 01 00 00    	je     f0102d8c <mem_init+0x1a8f>
	assert((pp1 = page_alloc(0)));
f0102bb0:	83 ec 0c             	sub    $0xc,%esp
f0102bb3:	6a 00                	push   $0x0
f0102bb5:	e8 91 e3 ff ff       	call   f0100f4b <page_alloc>
f0102bba:	89 c7                	mov    %eax,%edi
f0102bbc:	83 c4 10             	add    $0x10,%esp
f0102bbf:	85 c0                	test   %eax,%eax
f0102bc1:	0f 84 de 01 00 00    	je     f0102da5 <mem_init+0x1aa8>
	assert((pp2 = page_alloc(0)));
f0102bc7:	83 ec 0c             	sub    $0xc,%esp
f0102bca:	6a 00                	push   $0x0
f0102bcc:	e8 7a e3 ff ff       	call   f0100f4b <page_alloc>
f0102bd1:	89 c6                	mov    %eax,%esi
f0102bd3:	83 c4 10             	add    $0x10,%esp
f0102bd6:	85 c0                	test   %eax,%eax
f0102bd8:	0f 84 e0 01 00 00    	je     f0102dbe <mem_init+0x1ac1>
	page_free(pp0);
f0102bde:	83 ec 0c             	sub    $0xc,%esp
f0102be1:	53                   	push   %ebx
f0102be2:	e8 d6 e3 ff ff       	call   f0100fbd <page_free>
	return (pp - pages) << PGSHIFT;
f0102be7:	89 f8                	mov    %edi,%eax
f0102be9:	2b 05 90 3e 21 f0    	sub    0xf0213e90,%eax
f0102bef:	c1 f8 03             	sar    $0x3,%eax
f0102bf2:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102bf5:	89 c2                	mov    %eax,%edx
f0102bf7:	c1 ea 0c             	shr    $0xc,%edx
f0102bfa:	83 c4 10             	add    $0x10,%esp
f0102bfd:	3b 15 88 3e 21 f0    	cmp    0xf0213e88,%edx
f0102c03:	0f 83 ce 01 00 00    	jae    f0102dd7 <mem_init+0x1ada>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c09:	83 ec 04             	sub    $0x4,%esp
f0102c0c:	68 00 10 00 00       	push   $0x1000
f0102c11:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c13:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c18:	50                   	push   %eax
f0102c19:	e8 f8 29 00 00       	call   f0105616 <memset>
	return (pp - pages) << PGSHIFT;
f0102c1e:	89 f0                	mov    %esi,%eax
f0102c20:	2b 05 90 3e 21 f0    	sub    0xf0213e90,%eax
f0102c26:	c1 f8 03             	sar    $0x3,%eax
f0102c29:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c2c:	89 c2                	mov    %eax,%edx
f0102c2e:	c1 ea 0c             	shr    $0xc,%edx
f0102c31:	83 c4 10             	add    $0x10,%esp
f0102c34:	3b 15 88 3e 21 f0    	cmp    0xf0213e88,%edx
f0102c3a:	0f 83 a9 01 00 00    	jae    f0102de9 <mem_init+0x1aec>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c40:	83 ec 04             	sub    $0x4,%esp
f0102c43:	68 00 10 00 00       	push   $0x1000
f0102c48:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c4a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c4f:	50                   	push   %eax
f0102c50:	e8 c1 29 00 00       	call   f0105616 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c55:	6a 02                	push   $0x2
f0102c57:	68 00 10 00 00       	push   $0x1000
f0102c5c:	57                   	push   %edi
f0102c5d:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0102c63:	e8 b4 e5 ff ff       	call   f010121c <page_insert>
	assert(pp1->pp_ref == 1);
f0102c68:	83 c4 20             	add    $0x20,%esp
f0102c6b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c70:	0f 85 85 01 00 00    	jne    f0102dfb <mem_init+0x1afe>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c76:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c7d:	01 01 01 
f0102c80:	0f 85 8e 01 00 00    	jne    f0102e14 <mem_init+0x1b17>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c86:	6a 02                	push   $0x2
f0102c88:	68 00 10 00 00       	push   $0x1000
f0102c8d:	56                   	push   %esi
f0102c8e:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0102c94:	e8 83 e5 ff ff       	call   f010121c <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c99:	83 c4 10             	add    $0x10,%esp
f0102c9c:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102ca3:	02 02 02 
f0102ca6:	0f 85 81 01 00 00    	jne    f0102e2d <mem_init+0x1b30>
	assert(pp2->pp_ref == 1);
f0102cac:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cb1:	0f 85 8f 01 00 00    	jne    f0102e46 <mem_init+0x1b49>
	assert(pp1->pp_ref == 0);
f0102cb7:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cbc:	0f 85 9d 01 00 00    	jne    f0102e5f <mem_init+0x1b62>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cc2:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cc9:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102ccc:	89 f0                	mov    %esi,%eax
f0102cce:	2b 05 90 3e 21 f0    	sub    0xf0213e90,%eax
f0102cd4:	c1 f8 03             	sar    $0x3,%eax
f0102cd7:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102cda:	89 c2                	mov    %eax,%edx
f0102cdc:	c1 ea 0c             	shr    $0xc,%edx
f0102cdf:	3b 15 88 3e 21 f0    	cmp    0xf0213e88,%edx
f0102ce5:	0f 83 8d 01 00 00    	jae    f0102e78 <mem_init+0x1b7b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ceb:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cf2:	03 03 03 
f0102cf5:	0f 85 8f 01 00 00    	jne    f0102e8a <mem_init+0x1b8d>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cfb:	83 ec 08             	sub    $0x8,%esp
f0102cfe:	68 00 10 00 00       	push   $0x1000
f0102d03:	ff 35 8c 3e 21 f0    	pushl  0xf0213e8c
f0102d09:	e8 c6 e4 ff ff       	call   f01011d4 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d0e:	83 c4 10             	add    $0x10,%esp
f0102d11:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d16:	0f 85 87 01 00 00    	jne    f0102ea3 <mem_init+0x1ba6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d1c:	8b 0d 8c 3e 21 f0    	mov    0xf0213e8c,%ecx
f0102d22:	8b 11                	mov    (%ecx),%edx
f0102d24:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d2a:	89 d8                	mov    %ebx,%eax
f0102d2c:	2b 05 90 3e 21 f0    	sub    0xf0213e90,%eax
f0102d32:	c1 f8 03             	sar    $0x3,%eax
f0102d35:	c1 e0 0c             	shl    $0xc,%eax
f0102d38:	39 c2                	cmp    %eax,%edx
f0102d3a:	0f 85 7c 01 00 00    	jne    f0102ebc <mem_init+0x1bbf>
	kern_pgdir[0] = 0;
f0102d40:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d46:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d4b:	0f 85 84 01 00 00    	jne    f0102ed5 <mem_init+0x1bd8>
	pp0->pp_ref = 0;
f0102d51:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d57:	83 ec 0c             	sub    $0xc,%esp
f0102d5a:	53                   	push   %ebx
f0102d5b:	e8 5d e2 ff ff       	call   f0100fbd <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d60:	c7 04 24 c0 70 10 f0 	movl   $0xf01070c0,(%esp)
f0102d67:	e8 43 0b 00 00       	call   f01038af <cprintf>
}
f0102d6c:	83 c4 10             	add    $0x10,%esp
f0102d6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d72:	5b                   	pop    %ebx
f0102d73:	5e                   	pop    %esi
f0102d74:	5f                   	pop    %edi
f0102d75:	5d                   	pop    %ebp
f0102d76:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d77:	50                   	push   %eax
f0102d78:	68 c8 62 10 f0       	push   $0xf01062c8
f0102d7d:	68 e9 00 00 00       	push   $0xe9
f0102d82:	68 21 71 10 f0       	push   $0xf0107121
f0102d87:	e8 b4 d2 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d8c:	68 37 72 10 f0       	push   $0xf0107237
f0102d91:	68 47 71 10 f0       	push   $0xf0107147
f0102d96:	68 4b 04 00 00       	push   $0x44b
f0102d9b:	68 21 71 10 f0       	push   $0xf0107121
f0102da0:	e8 9b d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102da5:	68 4d 72 10 f0       	push   $0xf010724d
f0102daa:	68 47 71 10 f0       	push   $0xf0107147
f0102daf:	68 4c 04 00 00       	push   $0x44c
f0102db4:	68 21 71 10 f0       	push   $0xf0107121
f0102db9:	e8 82 d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102dbe:	68 63 72 10 f0       	push   $0xf0107263
f0102dc3:	68 47 71 10 f0       	push   $0xf0107147
f0102dc8:	68 4d 04 00 00       	push   $0x44d
f0102dcd:	68 21 71 10 f0       	push   $0xf0107121
f0102dd2:	e8 69 d2 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dd7:	50                   	push   %eax
f0102dd8:	68 a4 62 10 f0       	push   $0xf01062a4
f0102ddd:	6a 58                	push   $0x58
f0102ddf:	68 2d 71 10 f0       	push   $0xf010712d
f0102de4:	e8 57 d2 ff ff       	call   f0100040 <_panic>
f0102de9:	50                   	push   %eax
f0102dea:	68 a4 62 10 f0       	push   $0xf01062a4
f0102def:	6a 58                	push   $0x58
f0102df1:	68 2d 71 10 f0       	push   $0xf010712d
f0102df6:	e8 45 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102dfb:	68 34 73 10 f0       	push   $0xf0107334
f0102e00:	68 47 71 10 f0       	push   $0xf0107147
f0102e05:	68 52 04 00 00       	push   $0x452
f0102e0a:	68 21 71 10 f0       	push   $0xf0107121
f0102e0f:	e8 2c d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e14:	68 4c 70 10 f0       	push   $0xf010704c
f0102e19:	68 47 71 10 f0       	push   $0xf0107147
f0102e1e:	68 53 04 00 00       	push   $0x453
f0102e23:	68 21 71 10 f0       	push   $0xf0107121
f0102e28:	e8 13 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e2d:	68 70 70 10 f0       	push   $0xf0107070
f0102e32:	68 47 71 10 f0       	push   $0xf0107147
f0102e37:	68 55 04 00 00       	push   $0x455
f0102e3c:	68 21 71 10 f0       	push   $0xf0107121
f0102e41:	e8 fa d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e46:	68 56 73 10 f0       	push   $0xf0107356
f0102e4b:	68 47 71 10 f0       	push   $0xf0107147
f0102e50:	68 56 04 00 00       	push   $0x456
f0102e55:	68 21 71 10 f0       	push   $0xf0107121
f0102e5a:	e8 e1 d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102e5f:	68 c0 73 10 f0       	push   $0xf01073c0
f0102e64:	68 47 71 10 f0       	push   $0xf0107147
f0102e69:	68 57 04 00 00       	push   $0x457
f0102e6e:	68 21 71 10 f0       	push   $0xf0107121
f0102e73:	e8 c8 d1 ff ff       	call   f0100040 <_panic>
f0102e78:	50                   	push   %eax
f0102e79:	68 a4 62 10 f0       	push   $0xf01062a4
f0102e7e:	6a 58                	push   $0x58
f0102e80:	68 2d 71 10 f0       	push   $0xf010712d
f0102e85:	e8 b6 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e8a:	68 94 70 10 f0       	push   $0xf0107094
f0102e8f:	68 47 71 10 f0       	push   $0xf0107147
f0102e94:	68 59 04 00 00       	push   $0x459
f0102e99:	68 21 71 10 f0       	push   $0xf0107121
f0102e9e:	e8 9d d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102ea3:	68 8e 73 10 f0       	push   $0xf010738e
f0102ea8:	68 47 71 10 f0       	push   $0xf0107147
f0102ead:	68 5b 04 00 00       	push   $0x45b
f0102eb2:	68 21 71 10 f0       	push   $0xf0107121
f0102eb7:	e8 84 d1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ebc:	68 1c 6a 10 f0       	push   $0xf0106a1c
f0102ec1:	68 47 71 10 f0       	push   $0xf0107147
f0102ec6:	68 5e 04 00 00       	push   $0x45e
f0102ecb:	68 21 71 10 f0       	push   $0xf0107121
f0102ed0:	e8 6b d1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102ed5:	68 45 73 10 f0       	push   $0xf0107345
f0102eda:	68 47 71 10 f0       	push   $0xf0107147
f0102edf:	68 60 04 00 00       	push   $0x460
f0102ee4:	68 21 71 10 f0       	push   $0xf0107121
f0102ee9:	e8 52 d1 ff ff       	call   f0100040 <_panic>

f0102eee <user_mem_check>:
{
f0102eee:	55                   	push   %ebp
f0102eef:	89 e5                	mov    %esp,%ebp
f0102ef1:	57                   	push   %edi
f0102ef2:	56                   	push   %esi
f0102ef3:	53                   	push   %ebx
f0102ef4:	83 ec 0c             	sub    $0xc,%esp
f0102ef7:	8b 75 14             	mov    0x14(%ebp),%esi
    	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102efa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102efd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102f03:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102f06:	03 7d 10             	add    0x10(%ebp),%edi
f0102f09:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0102f0f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    	for (i = (uint32_t)begin; i < end; i += PGSIZE) {
f0102f15:	39 fb                	cmp    %edi,%ebx
f0102f17:	73 4e                	jae    f0102f67 <user_mem_check+0x79>
        	pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102f19:	83 ec 04             	sub    $0x4,%esp
f0102f1c:	6a 00                	push   $0x0
f0102f1e:	53                   	push   %ebx
f0102f1f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f22:	ff 70 60             	pushl  0x60(%eax)
f0102f25:	e8 f7 e0 ff ff       	call   f0101021 <pgdir_walk>
        	if ((i >= ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {        
f0102f2a:	83 c4 10             	add    $0x10,%esp
f0102f2d:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f33:	77 18                	ja     f0102f4d <user_mem_check+0x5f>
f0102f35:	85 c0                	test   %eax,%eax
f0102f37:	74 14                	je     f0102f4d <user_mem_check+0x5f>
f0102f39:	8b 00                	mov    (%eax),%eax
f0102f3b:	a8 01                	test   $0x1,%al
f0102f3d:	74 0e                	je     f0102f4d <user_mem_check+0x5f>
f0102f3f:	21 f0                	and    %esi,%eax
f0102f41:	39 c6                	cmp    %eax,%esi
f0102f43:	75 08                	jne    f0102f4d <user_mem_check+0x5f>
    	for (i = (uint32_t)begin; i < end; i += PGSIZE) {
f0102f45:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f4b:	eb c8                	jmp    f0102f15 <user_mem_check+0x27>
            		user_mem_check_addr = (i < (uint32_t)va ? (uint32_t)va : i);
f0102f4d:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102f50:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102f54:	89 1d 3c 32 21 f0    	mov    %ebx,0xf021323c
            	return -E_FAULT;
f0102f5a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102f5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f62:	5b                   	pop    %ebx
f0102f63:	5e                   	pop    %esi
f0102f64:	5f                   	pop    %edi
f0102f65:	5d                   	pop    %ebp
f0102f66:	c3                   	ret    
	return 0;
f0102f67:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f6c:	eb f1                	jmp    f0102f5f <user_mem_check+0x71>

f0102f6e <user_mem_assert>:
{
f0102f6e:	55                   	push   %ebp
f0102f6f:	89 e5                	mov    %esp,%ebp
f0102f71:	53                   	push   %ebx
f0102f72:	83 ec 04             	sub    $0x4,%esp
f0102f75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f78:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f7b:	83 c8 04             	or     $0x4,%eax
f0102f7e:	50                   	push   %eax
f0102f7f:	ff 75 10             	pushl  0x10(%ebp)
f0102f82:	ff 75 0c             	pushl  0xc(%ebp)
f0102f85:	53                   	push   %ebx
f0102f86:	e8 63 ff ff ff       	call   f0102eee <user_mem_check>
f0102f8b:	83 c4 10             	add    $0x10,%esp
f0102f8e:	85 c0                	test   %eax,%eax
f0102f90:	78 05                	js     f0102f97 <user_mem_assert+0x29>
}
f0102f92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f95:	c9                   	leave  
f0102f96:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f97:	83 ec 04             	sub    $0x4,%esp
f0102f9a:	ff 35 3c 32 21 f0    	pushl  0xf021323c
f0102fa0:	ff 73 48             	pushl  0x48(%ebx)
f0102fa3:	68 ec 70 10 f0       	push   $0xf01070ec
f0102fa8:	e8 02 09 00 00       	call   f01038af <cprintf>
		env_destroy(env);	// may not return
f0102fad:	89 1c 24             	mov    %ebx,(%esp)
f0102fb0:	e8 fe 05 00 00       	call   f01035b3 <env_destroy>
f0102fb5:	83 c4 10             	add    $0x10,%esp
}
f0102fb8:	eb d8                	jmp    f0102f92 <user_mem_assert+0x24>

f0102fba <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102fba:	55                   	push   %ebp
f0102fbb:	89 e5                	mov    %esp,%ebp
f0102fbd:	57                   	push   %edi
f0102fbe:	56                   	push   %esi
f0102fbf:	53                   	push   %ebx
f0102fc0:	83 ec 0c             	sub    $0xc,%esp
f0102fc3:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);
f0102fc5:	89 d3                	mov    %edx,%ebx
f0102fc7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
f0102fcd:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102fd4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    	struct PageInfo *p = NULL;
    	void* i;
    	int r;
    	for(i = start; i < end; i += PGSIZE){
f0102fda:	39 f3                	cmp    %esi,%ebx
f0102fdc:	73 5a                	jae    f0103038 <region_alloc+0x7e>
        	p = page_alloc(0);
f0102fde:	83 ec 0c             	sub    $0xc,%esp
f0102fe1:	6a 00                	push   $0x0
f0102fe3:	e8 63 df ff ff       	call   f0100f4b <page_alloc>
        	if(p == NULL)
f0102fe8:	83 c4 10             	add    $0x10,%esp
f0102feb:	85 c0                	test   %eax,%eax
f0102fed:	74 1b                	je     f010300a <region_alloc+0x50>
           		panic(" region alloc failed: allocation failed.\n");

        	r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
f0102fef:	6a 06                	push   $0x6
f0102ff1:	53                   	push   %ebx
f0102ff2:	50                   	push   %eax
f0102ff3:	ff 77 60             	pushl  0x60(%edi)
f0102ff6:	e8 21 e2 ff ff       	call   f010121c <page_insert>
        	if(r != 0)
f0102ffb:	83 c4 10             	add    $0x10,%esp
f0102ffe:	85 c0                	test   %eax,%eax
f0103000:	75 1f                	jne    f0103021 <region_alloc+0x67>
    	for(i = start; i < end; i += PGSIZE){
f0103002:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103008:	eb d0                	jmp    f0102fda <region_alloc+0x20>
           		panic(" region alloc failed: allocation failed.\n");
f010300a:	83 ec 04             	sub    $0x4,%esp
f010300d:	68 5c 74 10 f0       	push   $0xf010745c
f0103012:	68 2f 01 00 00       	push   $0x12f
f0103017:	68 18 75 10 f0       	push   $0xf0107518
f010301c:	e8 1f d0 ff ff       	call   f0100040 <_panic>
            		panic("region alloc failed.\n");
f0103021:	83 ec 04             	sub    $0x4,%esp
f0103024:	68 23 75 10 f0       	push   $0xf0107523
f0103029:	68 33 01 00 00       	push   $0x133
f010302e:	68 18 75 10 f0       	push   $0xf0107518
f0103033:	e8 08 d0 ff ff       	call   f0100040 <_panic>
    	}
}
f0103038:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010303b:	5b                   	pop    %ebx
f010303c:	5e                   	pop    %esi
f010303d:	5f                   	pop    %edi
f010303e:	5d                   	pop    %ebp
f010303f:	c3                   	ret    

f0103040 <envid2env>:
{
f0103040:	55                   	push   %ebp
f0103041:	89 e5                	mov    %esp,%ebp
f0103043:	56                   	push   %esi
f0103044:	53                   	push   %ebx
f0103045:	8b 45 08             	mov    0x8(%ebp),%eax
f0103048:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f010304b:	85 c0                	test   %eax,%eax
f010304d:	74 2e                	je     f010307d <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f010304f:	89 c3                	mov    %eax,%ebx
f0103051:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103057:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010305a:	03 1d 44 32 21 f0    	add    0xf0213244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103060:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103064:	74 31                	je     f0103097 <envid2env+0x57>
f0103066:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103069:	75 2c                	jne    f0103097 <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010306b:	84 d2                	test   %dl,%dl
f010306d:	75 38                	jne    f01030a7 <envid2env+0x67>
	*env_store = e;
f010306f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103072:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103074:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103079:	5b                   	pop    %ebx
f010307a:	5e                   	pop    %esi
f010307b:	5d                   	pop    %ebp
f010307c:	c3                   	ret    
		*env_store = curenv;
f010307d:	e8 b9 2b 00 00       	call   f0105c3b <cpunum>
f0103082:	6b c0 74             	imul   $0x74,%eax,%eax
f0103085:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f010308b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010308e:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103090:	b8 00 00 00 00       	mov    $0x0,%eax
f0103095:	eb e2                	jmp    f0103079 <envid2env+0x39>
		*env_store = 0;
f0103097:	8b 45 0c             	mov    0xc(%ebp),%eax
f010309a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01030a0:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030a5:	eb d2                	jmp    f0103079 <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030a7:	e8 8f 2b 00 00       	call   f0105c3b <cpunum>
f01030ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01030af:	39 98 28 40 21 f0    	cmp    %ebx,-0xfdebfd8(%eax)
f01030b5:	74 b8                	je     f010306f <envid2env+0x2f>
f01030b7:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01030ba:	e8 7c 2b 00 00       	call   f0105c3b <cpunum>
f01030bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01030c2:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f01030c8:	3b 70 48             	cmp    0x48(%eax),%esi
f01030cb:	74 a2                	je     f010306f <envid2env+0x2f>
		*env_store = 0;
f01030cd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01030d6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030db:	eb 9c                	jmp    f0103079 <envid2env+0x39>

f01030dd <env_init_percpu>:
{
f01030dd:	55                   	push   %ebp
f01030de:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f01030e0:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01030e5:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01030e8:	b8 23 00 00 00       	mov    $0x23,%eax
f01030ed:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01030ef:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01030f1:	b8 10 00 00 00       	mov    $0x10,%eax
f01030f6:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01030f8:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01030fa:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01030fc:	ea 03 31 10 f0 08 00 	ljmp   $0x8,$0xf0103103
	asm volatile("lldt %0" : : "r" (sel));
f0103103:	b8 00 00 00 00       	mov    $0x0,%eax
f0103108:	0f 00 d0             	lldt   %ax
}
f010310b:	5d                   	pop    %ebp
f010310c:	c3                   	ret    

f010310d <env_init>:
{
f010310d:	55                   	push   %ebp
f010310e:	89 e5                	mov    %esp,%ebp
f0103110:	56                   	push   %esi
f0103111:	53                   	push   %ebx
        	envs[i].env_id = 0;
f0103112:	8b 35 44 32 21 f0    	mov    0xf0213244,%esi
f0103118:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010311e:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0103121:	ba 00 00 00 00       	mov    $0x0,%edx
f0103126:	89 c1                	mov    %eax,%ecx
f0103128:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        	envs[i].env_status = ENV_FREE;
f010312f:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
        	envs[i].env_link = env_free_list;
f0103136:	89 50 44             	mov    %edx,0x44(%eax)
f0103139:	83 e8 7c             	sub    $0x7c,%eax
        	env_free_list = &envs[i];
f010313c:	89 ca                	mov    %ecx,%edx
    	for (i=NENV-1; i>=0; i--){
f010313e:	39 d8                	cmp    %ebx,%eax
f0103140:	75 e4                	jne    f0103126 <env_init+0x19>
f0103142:	89 35 48 32 21 f0    	mov    %esi,0xf0213248
	env_init_percpu();
f0103148:	e8 90 ff ff ff       	call   f01030dd <env_init_percpu>
}
f010314d:	5b                   	pop    %ebx
f010314e:	5e                   	pop    %esi
f010314f:	5d                   	pop    %ebp
f0103150:	c3                   	ret    

f0103151 <env_alloc>:
{
f0103151:	55                   	push   %ebp
f0103152:	89 e5                	mov    %esp,%ebp
f0103154:	53                   	push   %ebx
f0103155:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f0103158:	8b 1d 48 32 21 f0    	mov    0xf0213248,%ebx
f010315e:	85 db                	test   %ebx,%ebx
f0103160:	0f 84 56 01 00 00    	je     f01032bc <env_alloc+0x16b>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103166:	83 ec 0c             	sub    $0xc,%esp
f0103169:	6a 01                	push   $0x1
f010316b:	e8 db dd ff ff       	call   f0100f4b <page_alloc>
f0103170:	83 c4 10             	add    $0x10,%esp
f0103173:	85 c0                	test   %eax,%eax
f0103175:	0f 84 48 01 00 00    	je     f01032c3 <env_alloc+0x172>
	return (pp - pages) << PGSHIFT;
f010317b:	89 c2                	mov    %eax,%edx
f010317d:	2b 15 90 3e 21 f0    	sub    0xf0213e90,%edx
f0103183:	c1 fa 03             	sar    $0x3,%edx
f0103186:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103189:	89 d1                	mov    %edx,%ecx
f010318b:	c1 e9 0c             	shr    $0xc,%ecx
f010318e:	3b 0d 88 3e 21 f0    	cmp    0xf0213e88,%ecx
f0103194:	0f 83 fb 00 00 00    	jae    f0103295 <env_alloc+0x144>
	return (void *)(pa + KERNBASE);
f010319a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01031a0:	89 53 60             	mov    %edx,0x60(%ebx)
     	p->pp_ref++;
f01031a3:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01031a8:	b8 00 00 00 00       	mov    $0x0,%eax
         	e->env_pgdir[i] = 0; 
f01031ad:	8b 53 60             	mov    0x60(%ebx),%edx
f01031b0:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f01031b7:	83 c0 04             	add    $0x4,%eax
     	for (i = 0; i < PDX(UTOP); i++)
f01031ba:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01031bf:	75 ec                	jne    f01031ad <env_alloc+0x5c>
         	e->env_pgdir[i] = kern_pgdir[i];
f01031c1:	8b 15 8c 3e 21 f0    	mov    0xf0213e8c,%edx
f01031c7:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01031ca:	8b 53 60             	mov    0x60(%ebx),%edx
f01031cd:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01031d0:	83 c0 04             	add    $0x4,%eax
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
f01031d3:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01031d8:	75 e7                	jne    f01031c1 <env_alloc+0x70>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01031da:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01031dd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031e2:	0f 86 bf 00 00 00    	jbe    f01032a7 <env_alloc+0x156>
	return (physaddr_t)kva - KERNBASE;
f01031e8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01031ee:	83 ca 05             	or     $0x5,%edx
f01031f1:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01031f7:	8b 43 48             	mov    0x48(%ebx),%eax
f01031fa:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01031ff:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103204:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103209:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010320c:	89 da                	mov    %ebx,%edx
f010320e:	2b 15 44 32 21 f0    	sub    0xf0213244,%edx
f0103214:	c1 fa 02             	sar    $0x2,%edx
f0103217:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010321d:	09 d0                	or     %edx,%eax
f010321f:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103222:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103225:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103228:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010322f:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103236:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010323d:	83 ec 04             	sub    $0x4,%esp
f0103240:	6a 44                	push   $0x44
f0103242:	6a 00                	push   $0x0
f0103244:	53                   	push   %ebx
f0103245:	e8 cc 23 00 00       	call   f0105616 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010324a:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103250:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103256:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010325c:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103263:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
        e->env_tf.tf_eflags |= FL_IF;
f0103269:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f0103270:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103277:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f010327b:	8b 43 44             	mov    0x44(%ebx),%eax
f010327e:	a3 48 32 21 f0       	mov    %eax,0xf0213248
	*newenv_store = e;
f0103283:	8b 45 08             	mov    0x8(%ebp),%eax
f0103286:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103288:	83 c4 10             	add    $0x10,%esp
f010328b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103290:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103293:	c9                   	leave  
f0103294:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103295:	52                   	push   %edx
f0103296:	68 a4 62 10 f0       	push   $0xf01062a4
f010329b:	6a 58                	push   $0x58
f010329d:	68 2d 71 10 f0       	push   $0xf010712d
f01032a2:	e8 99 cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032a7:	50                   	push   %eax
f01032a8:	68 c8 62 10 f0       	push   $0xf01062c8
f01032ad:	68 c9 00 00 00       	push   $0xc9
f01032b2:	68 18 75 10 f0       	push   $0xf0107518
f01032b7:	e8 84 cd ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f01032bc:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01032c1:	eb cd                	jmp    f0103290 <env_alloc+0x13f>
		return -E_NO_MEM;
f01032c3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01032c8:	eb c6                	jmp    f0103290 <env_alloc+0x13f>

f01032ca <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01032ca:	55                   	push   %ebp
f01032cb:	89 e5                	mov    %esp,%ebp
f01032cd:	57                   	push   %edi
f01032ce:	56                   	push   %esi
f01032cf:	53                   	push   %ebx
f01032d0:	83 ec 24             	sub    $0x24,%esp
f01032d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Env *e;
    	int rc;
    	if ((rc = env_alloc(&e, 0)) != 0)
f01032d6:	6a 00                	push   $0x0
f01032d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01032db:	50                   	push   %eax
f01032dc:	e8 70 fe ff ff       	call   f0103151 <env_alloc>
f01032e1:	83 c4 10             	add    $0x10,%esp
f01032e4:	85 c0                	test   %eax,%eax
f01032e6:	75 48                	jne    f0103330 <env_create+0x66>
          	panic("env_create failed: env_alloc failed.\n");
     	e->env_type = type;
f01032e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01032eb:	89 5f 50             	mov    %ebx,0x50(%edi)
	// LAB 3: Your code here.

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
    	if (e->env_type == ENV_TYPE_FS) {
f01032ee:	83 fb 01             	cmp    $0x1,%ebx
f01032f1:	74 54                	je     f0103347 <env_create+0x7d>
    	if (header->e_magic != ELF_MAGIC) 
f01032f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01032f6:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01032fc:	75 52                	jne    f0103350 <env_create+0x86>
    	if (header->e_entry == 0)
f01032fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0103301:	8b 40 18             	mov    0x18(%eax),%eax
f0103304:	85 c0                	test   %eax,%eax
f0103306:	74 5f                	je     f0103367 <env_create+0x9d>
   	e->env_tf.tf_eip = header->e_entry;
f0103308:	89 47 30             	mov    %eax,0x30(%edi)
   	lcr3(PADDR(e->env_pgdir));   //load user pgdir
f010330b:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f010330e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103313:	76 69                	jbe    f010337e <env_create+0xb4>
	return (physaddr_t)kva - KERNBASE;
f0103315:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010331a:	0f 22 d8             	mov    %eax,%cr3
   	ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
f010331d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103320:	89 c3                	mov    %eax,%ebx
f0103322:	03 58 1c             	add    0x1c(%eax),%ebx
   	eph = ph + header->e_phnum;
f0103325:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f0103329:	c1 e6 05             	shl    $0x5,%esi
f010332c:	01 de                	add    %ebx,%esi
f010332e:	eb 66                	jmp    f0103396 <env_create+0xcc>
          	panic("env_create failed: env_alloc failed.\n");
f0103330:	83 ec 04             	sub    $0x4,%esp
f0103333:	68 88 74 10 f0       	push   $0xf0107488
f0103338:	68 9a 01 00 00       	push   $0x19a
f010333d:	68 18 75 10 f0       	push   $0xf0107518
f0103342:	e8 f9 cc ff ff       	call   f0100040 <_panic>
        	e->env_tf.tf_eflags |= FL_IOPL_MASK;
f0103347:	81 4f 38 00 30 00 00 	orl    $0x3000,0x38(%edi)
f010334e:	eb a3                	jmp    f01032f3 <env_create+0x29>
        	panic("load_icode failed: The binary we load is not elf.\n");
f0103350:	83 ec 04             	sub    $0x4,%esp
f0103353:	68 b0 74 10 f0       	push   $0xf01074b0
f0103358:	68 70 01 00 00       	push   $0x170
f010335d:	68 18 75 10 f0       	push   $0xf0107518
f0103362:	e8 d9 cc ff ff       	call   f0100040 <_panic>
        	panic("load_icode failed: The elf file can't be excuterd.\n");
f0103367:	83 ec 04             	sub    $0x4,%esp
f010336a:	68 e4 74 10 f0       	push   $0xf01074e4
f010336f:	68 73 01 00 00       	push   $0x173
f0103374:	68 18 75 10 f0       	push   $0xf0107518
f0103379:	e8 c2 cc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010337e:	50                   	push   %eax
f010337f:	68 c8 62 10 f0       	push   $0xf01062c8
f0103384:	68 77 01 00 00       	push   $0x177
f0103389:	68 18 75 10 f0       	push   $0xf0107518
f010338e:	e8 ad cc ff ff       	call   f0100040 <_panic>
    	for(; ph < eph; ph++) {
f0103393:	83 c3 20             	add    $0x20,%ebx
f0103396:	39 de                	cmp    %ebx,%esi
f0103398:	76 43                	jbe    f01033dd <env_create+0x113>
        	if(ph->p_type == ELF_PROG_LOAD) {
f010339a:	83 3b 01             	cmpl   $0x1,(%ebx)
f010339d:	75 f4                	jne    f0103393 <env_create+0xc9>
           		region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010339f:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01033a2:	8b 53 08             	mov    0x8(%ebx),%edx
f01033a5:	89 f8                	mov    %edi,%eax
f01033a7:	e8 0e fc ff ff       	call   f0102fba <region_alloc>
            		memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01033ac:	83 ec 04             	sub    $0x4,%esp
f01033af:	ff 73 10             	pushl  0x10(%ebx)
f01033b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01033b5:	03 43 04             	add    0x4(%ebx),%eax
f01033b8:	50                   	push   %eax
f01033b9:	ff 73 08             	pushl  0x8(%ebx)
f01033bc:	e8 a2 22 00 00       	call   f0105663 <memmove>
            		memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f01033c1:	8b 43 10             	mov    0x10(%ebx),%eax
f01033c4:	83 c4 0c             	add    $0xc,%esp
f01033c7:	8b 53 14             	mov    0x14(%ebx),%edx
f01033ca:	29 c2                	sub    %eax,%edx
f01033cc:	52                   	push   %edx
f01033cd:	6a 00                	push   $0x0
f01033cf:	03 43 08             	add    0x8(%ebx),%eax
f01033d2:	50                   	push   %eax
f01033d3:	e8 3e 22 00 00       	call   f0105616 <memset>
f01033d8:	83 c4 10             	add    $0x10,%esp
f01033db:	eb b6                	jmp    f0103393 <env_create+0xc9>
	region_alloc(e,(void *)(USTACKTOP-PGSIZE), PGSIZE);
f01033dd:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01033e2:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01033e7:	89 f8                	mov    %edi,%eax
f01033e9:	e8 cc fb ff ff       	call   f0102fba <region_alloc>
    	}
     	load_icode(e, binary);
}
f01033ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033f1:	5b                   	pop    %ebx
f01033f2:	5e                   	pop    %esi
f01033f3:	5f                   	pop    %edi
f01033f4:	5d                   	pop    %ebp
f01033f5:	c3                   	ret    

f01033f6 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033f6:	55                   	push   %ebp
f01033f7:	89 e5                	mov    %esp,%ebp
f01033f9:	57                   	push   %edi
f01033fa:	56                   	push   %esi
f01033fb:	53                   	push   %ebx
f01033fc:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033ff:	e8 37 28 00 00       	call   f0105c3b <cpunum>
f0103404:	6b c0 74             	imul   $0x74,%eax,%eax
f0103407:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010340e:	8b 55 08             	mov    0x8(%ebp),%edx
f0103411:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103414:	39 90 28 40 21 f0    	cmp    %edx,-0xfdebfd8(%eax)
f010341a:	0f 85 b2 00 00 00    	jne    f01034d2 <env_free+0xdc>
		lcr3(PADDR(kern_pgdir));
f0103420:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103425:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010342a:	76 17                	jbe    f0103443 <env_free+0x4d>
	return (physaddr_t)kva - KERNBASE;
f010342c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103431:	0f 22 d8             	mov    %eax,%cr3
f0103434:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010343b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010343e:	e9 8f 00 00 00       	jmp    f01034d2 <env_free+0xdc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103443:	50                   	push   %eax
f0103444:	68 c8 62 10 f0       	push   $0xf01062c8
f0103449:	68 b4 01 00 00       	push   $0x1b4
f010344e:	68 18 75 10 f0       	push   $0xf0107518
f0103453:	e8 e8 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103458:	50                   	push   %eax
f0103459:	68 a4 62 10 f0       	push   $0xf01062a4
f010345e:	68 c3 01 00 00       	push   $0x1c3
f0103463:	68 18 75 10 f0       	push   $0xf0107518
f0103468:	e8 d3 cb ff ff       	call   f0100040 <_panic>
f010346d:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103470:	39 de                	cmp    %ebx,%esi
f0103472:	74 21                	je     f0103495 <env_free+0x9f>
			if (pt[pteno] & PTE_P)
f0103474:	f6 03 01             	testb  $0x1,(%ebx)
f0103477:	74 f4                	je     f010346d <env_free+0x77>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103479:	83 ec 08             	sub    $0x8,%esp
f010347c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010347f:	01 d8                	add    %ebx,%eax
f0103481:	c1 e0 0a             	shl    $0xa,%eax
f0103484:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103487:	50                   	push   %eax
f0103488:	ff 77 60             	pushl  0x60(%edi)
f010348b:	e8 44 dd ff ff       	call   f01011d4 <page_remove>
f0103490:	83 c4 10             	add    $0x10,%esp
f0103493:	eb d8                	jmp    f010346d <env_free+0x77>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103495:	8b 47 60             	mov    0x60(%edi),%eax
f0103498:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010349b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01034a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034a5:	3b 05 88 3e 21 f0    	cmp    0xf0213e88,%eax
f01034ab:	73 6a                	jae    f0103517 <env_free+0x121>
		page_decref(pa2page(pa));
f01034ad:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01034b0:	a1 90 3e 21 f0       	mov    0xf0213e90,%eax
f01034b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034b8:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01034bb:	50                   	push   %eax
f01034bc:	e8 37 db ff ff       	call   f0100ff8 <page_decref>
f01034c1:	83 c4 10             	add    $0x10,%esp
f01034c4:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f01034c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034cb:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01034d0:	74 59                	je     f010352b <env_free+0x135>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01034d2:	8b 47 60             	mov    0x60(%edi),%eax
f01034d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034d8:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01034db:	a8 01                	test   $0x1,%al
f01034dd:	74 e5                	je     f01034c4 <env_free+0xce>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01034df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01034e4:	89 c2                	mov    %eax,%edx
f01034e6:	c1 ea 0c             	shr    $0xc,%edx
f01034e9:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01034ec:	39 15 88 3e 21 f0    	cmp    %edx,0xf0213e88
f01034f2:	0f 86 60 ff ff ff    	jbe    f0103458 <env_free+0x62>
	return (void *)(pa + KERNBASE);
f01034f8:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103501:	c1 e2 14             	shl    $0x14,%edx
f0103504:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103507:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f010350d:	f7 d8                	neg    %eax
f010350f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103512:	e9 5d ff ff ff       	jmp    f0103474 <env_free+0x7e>
		panic("pa2page called with invalid pa");
f0103517:	83 ec 04             	sub    $0x4,%esp
f010351a:	68 e8 68 10 f0       	push   $0xf01068e8
f010351f:	6a 51                	push   $0x51
f0103521:	68 2d 71 10 f0       	push   $0xf010712d
f0103526:	e8 15 cb ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010352b:	8b 45 08             	mov    0x8(%ebp),%eax
f010352e:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103531:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103536:	76 52                	jbe    f010358a <env_free+0x194>
	e->env_pgdir = 0;
f0103538:	8b 55 08             	mov    0x8(%ebp),%edx
f010353b:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103542:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103547:	c1 e8 0c             	shr    $0xc,%eax
f010354a:	3b 05 88 3e 21 f0    	cmp    0xf0213e88,%eax
f0103550:	73 4d                	jae    f010359f <env_free+0x1a9>
	page_decref(pa2page(pa));
f0103552:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103555:	8b 15 90 3e 21 f0    	mov    0xf0213e90,%edx
f010355b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010355e:	50                   	push   %eax
f010355f:	e8 94 da ff ff       	call   f0100ff8 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103564:	8b 45 08             	mov    0x8(%ebp),%eax
f0103567:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f010356e:	a1 48 32 21 f0       	mov    0xf0213248,%eax
f0103573:	8b 55 08             	mov    0x8(%ebp),%edx
f0103576:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103579:	89 15 48 32 21 f0    	mov    %edx,0xf0213248
}
f010357f:	83 c4 10             	add    $0x10,%esp
f0103582:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103585:	5b                   	pop    %ebx
f0103586:	5e                   	pop    %esi
f0103587:	5f                   	pop    %edi
f0103588:	5d                   	pop    %ebp
f0103589:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010358a:	50                   	push   %eax
f010358b:	68 c8 62 10 f0       	push   $0xf01062c8
f0103590:	68 d1 01 00 00       	push   $0x1d1
f0103595:	68 18 75 10 f0       	push   $0xf0107518
f010359a:	e8 a1 ca ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f010359f:	83 ec 04             	sub    $0x4,%esp
f01035a2:	68 e8 68 10 f0       	push   $0xf01068e8
f01035a7:	6a 51                	push   $0x51
f01035a9:	68 2d 71 10 f0       	push   $0xf010712d
f01035ae:	e8 8d ca ff ff       	call   f0100040 <_panic>

f01035b3 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01035b3:	55                   	push   %ebp
f01035b4:	89 e5                	mov    %esp,%ebp
f01035b6:	53                   	push   %ebx
f01035b7:	83 ec 04             	sub    $0x4,%esp
f01035ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035bd:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035c1:	74 21                	je     f01035e4 <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f01035c3:	83 ec 0c             	sub    $0xc,%esp
f01035c6:	53                   	push   %ebx
f01035c7:	e8 2a fe ff ff       	call   f01033f6 <env_free>

	if (curenv == e) {
f01035cc:	e8 6a 26 00 00       	call   f0105c3b <cpunum>
f01035d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01035d4:	83 c4 10             	add    $0x10,%esp
f01035d7:	39 98 28 40 21 f0    	cmp    %ebx,-0xfdebfd8(%eax)
f01035dd:	74 1e                	je     f01035fd <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f01035df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035e2:	c9                   	leave  
f01035e3:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035e4:	e8 52 26 00 00       	call   f0105c3b <cpunum>
f01035e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01035ec:	39 98 28 40 21 f0    	cmp    %ebx,-0xfdebfd8(%eax)
f01035f2:	74 cf                	je     f01035c3 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f01035f4:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035fb:	eb e2                	jmp    f01035df <env_destroy+0x2c>
		curenv = NULL;
f01035fd:	e8 39 26 00 00       	call   f0105c3b <cpunum>
f0103602:	6b c0 74             	imul   $0x74,%eax,%eax
f0103605:	c7 80 28 40 21 f0 00 	movl   $0x0,-0xfdebfd8(%eax)
f010360c:	00 00 00 
		sched_yield();
f010360f:	e8 63 0e 00 00       	call   f0104477 <sched_yield>

f0103614 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103614:	55                   	push   %ebp
f0103615:	89 e5                	mov    %esp,%ebp
f0103617:	53                   	push   %ebx
f0103618:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010361b:	e8 1b 26 00 00       	call   f0105c3b <cpunum>
f0103620:	6b c0 74             	imul   $0x74,%eax,%eax
f0103623:	8b 98 28 40 21 f0    	mov    -0xfdebfd8(%eax),%ebx
f0103629:	e8 0d 26 00 00       	call   f0105c3b <cpunum>
f010362e:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103631:	8b 65 08             	mov    0x8(%ebp),%esp
f0103634:	61                   	popa   
f0103635:	07                   	pop    %es
f0103636:	1f                   	pop    %ds
f0103637:	83 c4 08             	add    $0x8,%esp
f010363a:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010363b:	83 ec 04             	sub    $0x4,%esp
f010363e:	68 39 75 10 f0       	push   $0xf0107539
f0103643:	68 08 02 00 00       	push   $0x208
f0103648:	68 18 75 10 f0       	push   $0xf0107518
f010364d:	e8 ee c9 ff ff       	call   f0100040 <_panic>

f0103652 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103652:	55                   	push   %ebp
f0103653:	89 e5                	mov    %esp,%ebp
f0103655:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103658:	e8 de 25 00 00       	call   f0105c3b <cpunum>
f010365d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103660:	83 b8 28 40 21 f0 00 	cmpl   $0x0,-0xfdebfd8(%eax)
f0103667:	74 14                	je     f010367d <env_run+0x2b>
f0103669:	e8 cd 25 00 00       	call   f0105c3b <cpunum>
f010366e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103671:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f0103677:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010367b:	74 65                	je     f01036e2 <env_run+0x90>
        	curenv->env_status = ENV_RUNNABLE;

    	curenv = e;    
f010367d:	e8 b9 25 00 00       	call   f0105c3b <cpunum>
f0103682:	6b c0 74             	imul   $0x74,%eax,%eax
f0103685:	8b 55 08             	mov    0x8(%ebp),%edx
f0103688:	89 90 28 40 21 f0    	mov    %edx,-0xfdebfd8(%eax)
    	curenv->env_status = ENV_RUNNING;
f010368e:	e8 a8 25 00 00       	call   f0105c3b <cpunum>
f0103693:	6b c0 74             	imul   $0x74,%eax,%eax
f0103696:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f010369c:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    	curenv->env_runs++;
f01036a3:	e8 93 25 00 00       	call   f0105c3b <cpunum>
f01036a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ab:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f01036b1:	83 40 58 01          	addl   $0x1,0x58(%eax)
    	lcr3(PADDR(curenv->env_pgdir));
f01036b5:	e8 81 25 00 00       	call   f0105c3b <cpunum>
f01036ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01036bd:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f01036c3:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01036c6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036cb:	77 2c                	ja     f01036f9 <env_run+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036cd:	50                   	push   %eax
f01036ce:	68 c8 62 10 f0       	push   $0xf01062c8
f01036d3:	68 2c 02 00 00       	push   $0x22c
f01036d8:	68 18 75 10 f0       	push   $0xf0107518
f01036dd:	e8 5e c9 ff ff       	call   f0100040 <_panic>
        	curenv->env_status = ENV_RUNNABLE;
f01036e2:	e8 54 25 00 00       	call   f0105c3b <cpunum>
f01036e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ea:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f01036f0:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01036f7:	eb 84                	jmp    f010367d <env_run+0x2b>
	return (physaddr_t)kva - KERNBASE;
f01036f9:	05 00 00 00 10       	add    $0x10000000,%eax
f01036fe:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103701:	83 ec 0c             	sub    $0xc,%esp
f0103704:	68 c0 13 12 f0       	push   $0xf01213c0
f0103709:	e8 3a 28 00 00       	call   f0105f48 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010370e:	f3 90                	pause  

	unlock_kernel();

    	env_pop_tf(&curenv->env_tf);
f0103710:	e8 26 25 00 00       	call   f0105c3b <cpunum>
f0103715:	83 c4 04             	add    $0x4,%esp
f0103718:	6b c0 74             	imul   $0x74,%eax,%eax
f010371b:	ff b0 28 40 21 f0    	pushl  -0xfdebfd8(%eax)
f0103721:	e8 ee fe ff ff       	call   f0103614 <env_pop_tf>

f0103726 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103726:	55                   	push   %ebp
f0103727:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103729:	8b 45 08             	mov    0x8(%ebp),%eax
f010372c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103731:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103732:	ba 71 00 00 00       	mov    $0x71,%edx
f0103737:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103738:	0f b6 c0             	movzbl %al,%eax
}
f010373b:	5d                   	pop    %ebp
f010373c:	c3                   	ret    

f010373d <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010373d:	55                   	push   %ebp
f010373e:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103740:	8b 45 08             	mov    0x8(%ebp),%eax
f0103743:	ba 70 00 00 00       	mov    $0x70,%edx
f0103748:	ee                   	out    %al,(%dx)
f0103749:	8b 45 0c             	mov    0xc(%ebp),%eax
f010374c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103751:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103752:	5d                   	pop    %ebp
f0103753:	c3                   	ret    

f0103754 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103754:	55                   	push   %ebp
f0103755:	89 e5                	mov    %esp,%ebp
f0103757:	56                   	push   %esi
f0103758:	53                   	push   %ebx
f0103759:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010375c:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103762:	80 3d 4c 32 21 f0 00 	cmpb   $0x0,0xf021324c
f0103769:	75 07                	jne    f0103772 <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f010376b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010376e:	5b                   	pop    %ebx
f010376f:	5e                   	pop    %esi
f0103770:	5d                   	pop    %ebp
f0103771:	c3                   	ret    
f0103772:	89 c6                	mov    %eax,%esi
f0103774:	ba 21 00 00 00       	mov    $0x21,%edx
f0103779:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f010377a:	66 c1 e8 08          	shr    $0x8,%ax
f010377e:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103783:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103784:	83 ec 0c             	sub    $0xc,%esp
f0103787:	68 45 75 10 f0       	push   $0xf0107545
f010378c:	e8 1e 01 00 00       	call   f01038af <cprintf>
f0103791:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103794:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103799:	0f b7 f6             	movzwl %si,%esi
f010379c:	f7 d6                	not    %esi
f010379e:	eb 08                	jmp    f01037a8 <irq_setmask_8259A+0x54>
	for (i = 0; i < 16; i++)
f01037a0:	83 c3 01             	add    $0x1,%ebx
f01037a3:	83 fb 10             	cmp    $0x10,%ebx
f01037a6:	74 18                	je     f01037c0 <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f01037a8:	0f a3 de             	bt     %ebx,%esi
f01037ab:	73 f3                	jae    f01037a0 <irq_setmask_8259A+0x4c>
			cprintf(" %d", i);
f01037ad:	83 ec 08             	sub    $0x8,%esp
f01037b0:	53                   	push   %ebx
f01037b1:	68 eb 79 10 f0       	push   $0xf01079eb
f01037b6:	e8 f4 00 00 00       	call   f01038af <cprintf>
f01037bb:	83 c4 10             	add    $0x10,%esp
f01037be:	eb e0                	jmp    f01037a0 <irq_setmask_8259A+0x4c>
	cprintf("\n");
f01037c0:	83 ec 0c             	sub    $0xc,%esp
f01037c3:	68 29 74 10 f0       	push   $0xf0107429
f01037c8:	e8 e2 00 00 00       	call   f01038af <cprintf>
f01037cd:	83 c4 10             	add    $0x10,%esp
f01037d0:	eb 99                	jmp    f010376b <irq_setmask_8259A+0x17>

f01037d2 <pic_init>:
{
f01037d2:	55                   	push   %ebp
f01037d3:	89 e5                	mov    %esp,%ebp
f01037d5:	57                   	push   %edi
f01037d6:	56                   	push   %esi
f01037d7:	53                   	push   %ebx
f01037d8:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f01037db:	c6 05 4c 32 21 f0 01 	movb   $0x1,0xf021324c
f01037e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037e7:	bb 21 00 00 00       	mov    $0x21,%ebx
f01037ec:	89 da                	mov    %ebx,%edx
f01037ee:	ee                   	out    %al,(%dx)
f01037ef:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f01037f4:	89 ca                	mov    %ecx,%edx
f01037f6:	ee                   	out    %al,(%dx)
f01037f7:	bf 11 00 00 00       	mov    $0x11,%edi
f01037fc:	be 20 00 00 00       	mov    $0x20,%esi
f0103801:	89 f8                	mov    %edi,%eax
f0103803:	89 f2                	mov    %esi,%edx
f0103805:	ee                   	out    %al,(%dx)
f0103806:	b8 20 00 00 00       	mov    $0x20,%eax
f010380b:	89 da                	mov    %ebx,%edx
f010380d:	ee                   	out    %al,(%dx)
f010380e:	b8 04 00 00 00       	mov    $0x4,%eax
f0103813:	ee                   	out    %al,(%dx)
f0103814:	b8 03 00 00 00       	mov    $0x3,%eax
f0103819:	ee                   	out    %al,(%dx)
f010381a:	bb a0 00 00 00       	mov    $0xa0,%ebx
f010381f:	89 f8                	mov    %edi,%eax
f0103821:	89 da                	mov    %ebx,%edx
f0103823:	ee                   	out    %al,(%dx)
f0103824:	b8 28 00 00 00       	mov    $0x28,%eax
f0103829:	89 ca                	mov    %ecx,%edx
f010382b:	ee                   	out    %al,(%dx)
f010382c:	b8 02 00 00 00       	mov    $0x2,%eax
f0103831:	ee                   	out    %al,(%dx)
f0103832:	b8 01 00 00 00       	mov    $0x1,%eax
f0103837:	ee                   	out    %al,(%dx)
f0103838:	bf 68 00 00 00       	mov    $0x68,%edi
f010383d:	89 f8                	mov    %edi,%eax
f010383f:	89 f2                	mov    %esi,%edx
f0103841:	ee                   	out    %al,(%dx)
f0103842:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103847:	89 c8                	mov    %ecx,%eax
f0103849:	ee                   	out    %al,(%dx)
f010384a:	89 f8                	mov    %edi,%eax
f010384c:	89 da                	mov    %ebx,%edx
f010384e:	ee                   	out    %al,(%dx)
f010384f:	89 c8                	mov    %ecx,%eax
f0103851:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103852:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103859:	66 83 f8 ff          	cmp    $0xffff,%ax
f010385d:	74 0f                	je     f010386e <pic_init+0x9c>
		irq_setmask_8259A(irq_mask_8259A);
f010385f:	83 ec 0c             	sub    $0xc,%esp
f0103862:	0f b7 c0             	movzwl %ax,%eax
f0103865:	50                   	push   %eax
f0103866:	e8 e9 fe ff ff       	call   f0103754 <irq_setmask_8259A>
f010386b:	83 c4 10             	add    $0x10,%esp
}
f010386e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103871:	5b                   	pop    %ebx
f0103872:	5e                   	pop    %esi
f0103873:	5f                   	pop    %edi
f0103874:	5d                   	pop    %ebp
f0103875:	c3                   	ret    

f0103876 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103876:	55                   	push   %ebp
f0103877:	89 e5                	mov    %esp,%ebp
f0103879:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010387c:	ff 75 08             	pushl  0x8(%ebp)
f010387f:	e8 1e cf ff ff       	call   f01007a2 <cputchar>
	*cnt++;
}
f0103884:	83 c4 10             	add    $0x10,%esp
f0103887:	c9                   	leave  
f0103888:	c3                   	ret    

f0103889 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103889:	55                   	push   %ebp
f010388a:	89 e5                	mov    %esp,%ebp
f010388c:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010388f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103896:	ff 75 0c             	pushl  0xc(%ebp)
f0103899:	ff 75 08             	pushl  0x8(%ebp)
f010389c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010389f:	50                   	push   %eax
f01038a0:	68 76 38 10 f0       	push   $0xf0103876
f01038a5:	e8 1b 16 00 00       	call   f0104ec5 <vprintfmt>
	return cnt;
}
f01038aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01038ad:	c9                   	leave  
f01038ae:	c3                   	ret    

f01038af <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01038af:	55                   	push   %ebp
f01038b0:	89 e5                	mov    %esp,%ebp
f01038b2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01038b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01038b8:	50                   	push   %eax
f01038b9:	ff 75 08             	pushl  0x8(%ebp)
f01038bc:	e8 c8 ff ff ff       	call   f0103889 <vcprintf>
	va_end(ap);

	return cnt;
}
f01038c1:	c9                   	leave  
f01038c2:	c3                   	ret    

f01038c3 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01038c3:	55                   	push   %ebp
f01038c4:	89 e5                	mov    %esp,%ebp
f01038c6:	57                   	push   %edi
f01038c7:	56                   	push   %esi
f01038c8:	53                   	push   %ebx
f01038c9:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int cid = thiscpu->cpu_id;
f01038cc:	e8 6a 23 00 00       	call   f0105c3b <cpunum>
f01038d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01038d4:	0f b6 98 20 40 21 f0 	movzbl -0xfdebfe0(%eax),%ebx
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f01038db:	e8 5b 23 00 00       	call   f0105c3b <cpunum>
f01038e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01038e3:	89 d9                	mov    %ebx,%ecx
f01038e5:	c1 e1 10             	shl    $0x10,%ecx
f01038e8:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01038ed:	29 ca                	sub    %ecx,%edx
f01038ef:	89 90 30 40 21 f0    	mov    %edx,-0xfdebfd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01038f5:	e8 41 23 00 00       	call   f0105c3b <cpunum>
f01038fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01038fd:	66 c7 80 34 40 21 f0 	movw   $0x10,-0xfdebfcc(%eax)
f0103904:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103906:	e8 30 23 00 00       	call   f0105c3b <cpunum>
f010390b:	6b c0 74             	imul   $0x74,%eax,%eax
f010390e:	66 c7 80 92 40 21 f0 	movw   $0x68,-0xfdebf6e(%eax)
f0103915:	68 00 
	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+cid] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103917:	83 c3 05             	add    $0x5,%ebx
f010391a:	e8 1c 23 00 00       	call   f0105c3b <cpunum>
f010391f:	89 c7                	mov    %eax,%edi
f0103921:	e8 15 23 00 00       	call   f0105c3b <cpunum>
f0103926:	89 c6                	mov    %eax,%esi
f0103928:	e8 0e 23 00 00       	call   f0105c3b <cpunum>
f010392d:	66 c7 04 dd 40 13 12 	movw   $0x68,-0xfedecc0(,%ebx,8)
f0103934:	f0 68 00 
f0103937:	6b ff 74             	imul   $0x74,%edi,%edi
f010393a:	81 c7 2c 40 21 f0    	add    $0xf021402c,%edi
f0103940:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f0103947:	f0 
f0103948:	6b d6 74             	imul   $0x74,%esi,%edx
f010394b:	81 c2 2c 40 21 f0    	add    $0xf021402c,%edx
f0103951:	c1 ea 10             	shr    $0x10,%edx
f0103954:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f010395b:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f0103962:	40 
f0103963:	6b c0 74             	imul   $0x74,%eax,%eax
f0103966:	05 2c 40 21 f0       	add    $0xf021402c,%eax
f010396b:	c1 e8 18             	shr    $0x18,%eax
f010396e:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3)+cid].sd_s = 0;
f0103975:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f010397c:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+8*cid);
f010397d:	c1 e3 03             	shl    $0x3,%ebx
	asm volatile("ltr %0" : : "r" (sel));
f0103980:	0f 00 db             	ltr    %bx
	asm volatile("lidt (%0)" : : "r" (p));
f0103983:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0103988:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f010398b:	83 c4 0c             	add    $0xc,%esp
f010398e:	5b                   	pop    %ebx
f010398f:	5e                   	pop    %esi
f0103990:	5f                   	pop    %edi
f0103991:	5d                   	pop    %ebp
f0103992:	c3                   	ret    

f0103993 <trap_init>:
{
f0103993:	55                   	push   %ebp
f0103994:	89 e5                	mov    %esp,%ebp
f0103996:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[0], 0, GD_KT, th0, 0);
f0103999:	b8 1e 43 10 f0       	mov    $0xf010431e,%eax
f010399e:	66 a3 60 32 21 f0    	mov    %ax,0xf0213260
f01039a4:	66 c7 05 62 32 21 f0 	movw   $0x8,0xf0213262
f01039ab:	08 00 
f01039ad:	c6 05 64 32 21 f0 00 	movb   $0x0,0xf0213264
f01039b4:	c6 05 65 32 21 f0 8e 	movb   $0x8e,0xf0213265
f01039bb:	c1 e8 10             	shr    $0x10,%eax
f01039be:	66 a3 66 32 21 f0    	mov    %ax,0xf0213266
	SETGATE(idt[1], 0, GD_KT, th1, 0);
f01039c4:	b8 24 43 10 f0       	mov    $0xf0104324,%eax
f01039c9:	66 a3 68 32 21 f0    	mov    %ax,0xf0213268
f01039cf:	66 c7 05 6a 32 21 f0 	movw   $0x8,0xf021326a
f01039d6:	08 00 
f01039d8:	c6 05 6c 32 21 f0 00 	movb   $0x0,0xf021326c
f01039df:	c6 05 6d 32 21 f0 8e 	movb   $0x8e,0xf021326d
f01039e6:	c1 e8 10             	shr    $0x10,%eax
f01039e9:	66 a3 6e 32 21 f0    	mov    %ax,0xf021326e
	SETGATE(idt[3], 0, GD_KT, th3, 3);
f01039ef:	b8 2a 43 10 f0       	mov    $0xf010432a,%eax
f01039f4:	66 a3 78 32 21 f0    	mov    %ax,0xf0213278
f01039fa:	66 c7 05 7a 32 21 f0 	movw   $0x8,0xf021327a
f0103a01:	08 00 
f0103a03:	c6 05 7c 32 21 f0 00 	movb   $0x0,0xf021327c
f0103a0a:	c6 05 7d 32 21 f0 ee 	movb   $0xee,0xf021327d
f0103a11:	c1 e8 10             	shr    $0x10,%eax
f0103a14:	66 a3 7e 32 21 f0    	mov    %ax,0xf021327e
	SETGATE(idt[4], 0, GD_KT, th4, 0);
f0103a1a:	b8 30 43 10 f0       	mov    $0xf0104330,%eax
f0103a1f:	66 a3 80 32 21 f0    	mov    %ax,0xf0213280
f0103a25:	66 c7 05 82 32 21 f0 	movw   $0x8,0xf0213282
f0103a2c:	08 00 
f0103a2e:	c6 05 84 32 21 f0 00 	movb   $0x0,0xf0213284
f0103a35:	c6 05 85 32 21 f0 8e 	movb   $0x8e,0xf0213285
f0103a3c:	c1 e8 10             	shr    $0x10,%eax
f0103a3f:	66 a3 86 32 21 f0    	mov    %ax,0xf0213286
	SETGATE(idt[5], 0, GD_KT, th5, 0);
f0103a45:	b8 36 43 10 f0       	mov    $0xf0104336,%eax
f0103a4a:	66 a3 88 32 21 f0    	mov    %ax,0xf0213288
f0103a50:	66 c7 05 8a 32 21 f0 	movw   $0x8,0xf021328a
f0103a57:	08 00 
f0103a59:	c6 05 8c 32 21 f0 00 	movb   $0x0,0xf021328c
f0103a60:	c6 05 8d 32 21 f0 8e 	movb   $0x8e,0xf021328d
f0103a67:	c1 e8 10             	shr    $0x10,%eax
f0103a6a:	66 a3 8e 32 21 f0    	mov    %ax,0xf021328e
	SETGATE(idt[6], 0, GD_KT, th6, 0);
f0103a70:	b8 3c 43 10 f0       	mov    $0xf010433c,%eax
f0103a75:	66 a3 90 32 21 f0    	mov    %ax,0xf0213290
f0103a7b:	66 c7 05 92 32 21 f0 	movw   $0x8,0xf0213292
f0103a82:	08 00 
f0103a84:	c6 05 94 32 21 f0 00 	movb   $0x0,0xf0213294
f0103a8b:	c6 05 95 32 21 f0 8e 	movb   $0x8e,0xf0213295
f0103a92:	c1 e8 10             	shr    $0x10,%eax
f0103a95:	66 a3 96 32 21 f0    	mov    %ax,0xf0213296
	SETGATE(idt[7], 0, GD_KT, th7, 0);
f0103a9b:	b8 42 43 10 f0       	mov    $0xf0104342,%eax
f0103aa0:	66 a3 98 32 21 f0    	mov    %ax,0xf0213298
f0103aa6:	66 c7 05 9a 32 21 f0 	movw   $0x8,0xf021329a
f0103aad:	08 00 
f0103aaf:	c6 05 9c 32 21 f0 00 	movb   $0x0,0xf021329c
f0103ab6:	c6 05 9d 32 21 f0 8e 	movb   $0x8e,0xf021329d
f0103abd:	c1 e8 10             	shr    $0x10,%eax
f0103ac0:	66 a3 9e 32 21 f0    	mov    %ax,0xf021329e
	SETGATE(idt[8], 0, GD_KT, th8, 0);
f0103ac6:	b8 48 43 10 f0       	mov    $0xf0104348,%eax
f0103acb:	66 a3 a0 32 21 f0    	mov    %ax,0xf02132a0
f0103ad1:	66 c7 05 a2 32 21 f0 	movw   $0x8,0xf02132a2
f0103ad8:	08 00 
f0103ada:	c6 05 a4 32 21 f0 00 	movb   $0x0,0xf02132a4
f0103ae1:	c6 05 a5 32 21 f0 8e 	movb   $0x8e,0xf02132a5
f0103ae8:	c1 e8 10             	shr    $0x10,%eax
f0103aeb:	66 a3 a6 32 21 f0    	mov    %ax,0xf02132a6
	SETGATE(idt[9], 0, GD_KT, th9, 0);
f0103af1:	b8 4c 43 10 f0       	mov    $0xf010434c,%eax
f0103af6:	66 a3 a8 32 21 f0    	mov    %ax,0xf02132a8
f0103afc:	66 c7 05 aa 32 21 f0 	movw   $0x8,0xf02132aa
f0103b03:	08 00 
f0103b05:	c6 05 ac 32 21 f0 00 	movb   $0x0,0xf02132ac
f0103b0c:	c6 05 ad 32 21 f0 8e 	movb   $0x8e,0xf02132ad
f0103b13:	c1 e8 10             	shr    $0x10,%eax
f0103b16:	66 a3 ae 32 21 f0    	mov    %ax,0xf02132ae
	SETGATE(idt[10], 0, GD_KT, th10, 0);
f0103b1c:	b8 52 43 10 f0       	mov    $0xf0104352,%eax
f0103b21:	66 a3 b0 32 21 f0    	mov    %ax,0xf02132b0
f0103b27:	66 c7 05 b2 32 21 f0 	movw   $0x8,0xf02132b2
f0103b2e:	08 00 
f0103b30:	c6 05 b4 32 21 f0 00 	movb   $0x0,0xf02132b4
f0103b37:	c6 05 b5 32 21 f0 8e 	movb   $0x8e,0xf02132b5
f0103b3e:	c1 e8 10             	shr    $0x10,%eax
f0103b41:	66 a3 b6 32 21 f0    	mov    %ax,0xf02132b6
	SETGATE(idt[11], 0, GD_KT, th11, 0);
f0103b47:	b8 56 43 10 f0       	mov    $0xf0104356,%eax
f0103b4c:	66 a3 b8 32 21 f0    	mov    %ax,0xf02132b8
f0103b52:	66 c7 05 ba 32 21 f0 	movw   $0x8,0xf02132ba
f0103b59:	08 00 
f0103b5b:	c6 05 bc 32 21 f0 00 	movb   $0x0,0xf02132bc
f0103b62:	c6 05 bd 32 21 f0 8e 	movb   $0x8e,0xf02132bd
f0103b69:	c1 e8 10             	shr    $0x10,%eax
f0103b6c:	66 a3 be 32 21 f0    	mov    %ax,0xf02132be
	SETGATE(idt[12], 0, GD_KT, th12, 0);
f0103b72:	b8 5a 43 10 f0       	mov    $0xf010435a,%eax
f0103b77:	66 a3 c0 32 21 f0    	mov    %ax,0xf02132c0
f0103b7d:	66 c7 05 c2 32 21 f0 	movw   $0x8,0xf02132c2
f0103b84:	08 00 
f0103b86:	c6 05 c4 32 21 f0 00 	movb   $0x0,0xf02132c4
f0103b8d:	c6 05 c5 32 21 f0 8e 	movb   $0x8e,0xf02132c5
f0103b94:	c1 e8 10             	shr    $0x10,%eax
f0103b97:	66 a3 c6 32 21 f0    	mov    %ax,0xf02132c6
	SETGATE(idt[13], 0, GD_KT, th13, 0);
f0103b9d:	b8 5e 43 10 f0       	mov    $0xf010435e,%eax
f0103ba2:	66 a3 c8 32 21 f0    	mov    %ax,0xf02132c8
f0103ba8:	66 c7 05 ca 32 21 f0 	movw   $0x8,0xf02132ca
f0103baf:	08 00 
f0103bb1:	c6 05 cc 32 21 f0 00 	movb   $0x0,0xf02132cc
f0103bb8:	c6 05 cd 32 21 f0 8e 	movb   $0x8e,0xf02132cd
f0103bbf:	c1 e8 10             	shr    $0x10,%eax
f0103bc2:	66 a3 ce 32 21 f0    	mov    %ax,0xf02132ce
	SETGATE(idt[14], 0, GD_KT, th14, 0);
f0103bc8:	b8 62 43 10 f0       	mov    $0xf0104362,%eax
f0103bcd:	66 a3 d0 32 21 f0    	mov    %ax,0xf02132d0
f0103bd3:	66 c7 05 d2 32 21 f0 	movw   $0x8,0xf02132d2
f0103bda:	08 00 
f0103bdc:	c6 05 d4 32 21 f0 00 	movb   $0x0,0xf02132d4
f0103be3:	c6 05 d5 32 21 f0 8e 	movb   $0x8e,0xf02132d5
f0103bea:	c1 e8 10             	shr    $0x10,%eax
f0103bed:	66 a3 d6 32 21 f0    	mov    %ax,0xf02132d6
	SETGATE(idt[16], 0, GD_KT, th16, 0);
f0103bf3:	b8 66 43 10 f0       	mov    $0xf0104366,%eax
f0103bf8:	66 a3 e0 32 21 f0    	mov    %ax,0xf02132e0
f0103bfe:	66 c7 05 e2 32 21 f0 	movw   $0x8,0xf02132e2
f0103c05:	08 00 
f0103c07:	c6 05 e4 32 21 f0 00 	movb   $0x0,0xf02132e4
f0103c0e:	c6 05 e5 32 21 f0 8e 	movb   $0x8e,0xf02132e5
f0103c15:	c1 e8 10             	shr    $0x10,%eax
f0103c18:	66 a3 e6 32 21 f0    	mov    %ax,0xf02132e6
	SETGATE(idt[T_SYSCALL], 0, GD_KT, th_syscall, 3);
f0103c1e:	b8 6c 43 10 f0       	mov    $0xf010436c,%eax
f0103c23:	66 a3 e0 33 21 f0    	mov    %ax,0xf02133e0
f0103c29:	66 c7 05 e2 33 21 f0 	movw   $0x8,0xf02133e2
f0103c30:	08 00 
f0103c32:	c6 05 e4 33 21 f0 00 	movb   $0x0,0xf02133e4
f0103c39:	c6 05 e5 33 21 f0 ee 	movb   $0xee,0xf02133e5
f0103c40:	c1 e8 10             	shr    $0x10,%eax
f0103c43:	66 a3 e6 33 21 f0    	mov    %ax,0xf02133e6
    	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irqtimer_handler, 0);
f0103c49:	b8 72 43 10 f0       	mov    $0xf0104372,%eax
f0103c4e:	66 a3 60 33 21 f0    	mov    %ax,0xf0213360
f0103c54:	66 c7 05 62 33 21 f0 	movw   $0x8,0xf0213362
f0103c5b:	08 00 
f0103c5d:	c6 05 64 33 21 f0 00 	movb   $0x0,0xf0213364
f0103c64:	c6 05 65 33 21 f0 8e 	movb   $0x8e,0xf0213365
f0103c6b:	c1 e8 10             	shr    $0x10,%eax
f0103c6e:	66 a3 66 33 21 f0    	mov    %ax,0xf0213366
    	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irqkbd_handler, 0);
f0103c74:	b8 78 43 10 f0       	mov    $0xf0104378,%eax
f0103c79:	66 a3 68 33 21 f0    	mov    %ax,0xf0213368
f0103c7f:	66 c7 05 6a 33 21 f0 	movw   $0x8,0xf021336a
f0103c86:	08 00 
f0103c88:	c6 05 6c 33 21 f0 00 	movb   $0x0,0xf021336c
f0103c8f:	c6 05 6d 33 21 f0 8e 	movb   $0x8e,0xf021336d
f0103c96:	c1 e8 10             	shr    $0x10,%eax
f0103c99:	66 a3 6e 33 21 f0    	mov    %ax,0xf021336e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irqserial_handler, 0);
f0103c9f:	b8 7e 43 10 f0       	mov    $0xf010437e,%eax
f0103ca4:	66 a3 80 33 21 f0    	mov    %ax,0xf0213380
f0103caa:	66 c7 05 82 33 21 f0 	movw   $0x8,0xf0213382
f0103cb1:	08 00 
f0103cb3:	c6 05 84 33 21 f0 00 	movb   $0x0,0xf0213384
f0103cba:	c6 05 85 33 21 f0 8e 	movb   $0x8e,0xf0213385
f0103cc1:	c1 e8 10             	shr    $0x10,%eax
f0103cc4:	66 a3 86 33 21 f0    	mov    %ax,0xf0213386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irqspurious_handler, 0);
f0103cca:	b8 84 43 10 f0       	mov    $0xf0104384,%eax
f0103ccf:	66 a3 98 33 21 f0    	mov    %ax,0xf0213398
f0103cd5:	66 c7 05 9a 33 21 f0 	movw   $0x8,0xf021339a
f0103cdc:	08 00 
f0103cde:	c6 05 9c 33 21 f0 00 	movb   $0x0,0xf021339c
f0103ce5:	c6 05 9d 33 21 f0 8e 	movb   $0x8e,0xf021339d
f0103cec:	c1 e8 10             	shr    $0x10,%eax
f0103cef:	66 a3 9e 33 21 f0    	mov    %ax,0xf021339e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irqide_handler, 0);
f0103cf5:	b8 8a 43 10 f0       	mov    $0xf010438a,%eax
f0103cfa:	66 a3 d0 33 21 f0    	mov    %ax,0xf02133d0
f0103d00:	66 c7 05 d2 33 21 f0 	movw   $0x8,0xf02133d2
f0103d07:	08 00 
f0103d09:	c6 05 d4 33 21 f0 00 	movb   $0x0,0xf02133d4
f0103d10:	c6 05 d5 33 21 f0 8e 	movb   $0x8e,0xf02133d5
f0103d17:	c1 e8 10             	shr    $0x10,%eax
f0103d1a:	66 a3 d6 33 21 f0    	mov    %ax,0xf02133d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irqerror_handler, 0);
f0103d20:	b8 90 43 10 f0       	mov    $0xf0104390,%eax
f0103d25:	66 a3 f8 33 21 f0    	mov    %ax,0xf02133f8
f0103d2b:	66 c7 05 fa 33 21 f0 	movw   $0x8,0xf02133fa
f0103d32:	08 00 
f0103d34:	c6 05 fc 33 21 f0 00 	movb   $0x0,0xf02133fc
f0103d3b:	c6 05 fd 33 21 f0 8e 	movb   $0x8e,0xf02133fd
f0103d42:	c1 e8 10             	shr    $0x10,%eax
f0103d45:	66 a3 fe 33 21 f0    	mov    %ax,0xf02133fe
	trap_init_percpu();
f0103d4b:	e8 73 fb ff ff       	call   f01038c3 <trap_init_percpu>
}
f0103d50:	c9                   	leave  
f0103d51:	c3                   	ret    

f0103d52 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d52:	55                   	push   %ebp
f0103d53:	89 e5                	mov    %esp,%ebp
f0103d55:	53                   	push   %ebx
f0103d56:	83 ec 0c             	sub    $0xc,%esp
f0103d59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d5c:	ff 33                	pushl  (%ebx)
f0103d5e:	68 59 75 10 f0       	push   $0xf0107559
f0103d63:	e8 47 fb ff ff       	call   f01038af <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d68:	83 c4 08             	add    $0x8,%esp
f0103d6b:	ff 73 04             	pushl  0x4(%ebx)
f0103d6e:	68 68 75 10 f0       	push   $0xf0107568
f0103d73:	e8 37 fb ff ff       	call   f01038af <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103d78:	83 c4 08             	add    $0x8,%esp
f0103d7b:	ff 73 08             	pushl  0x8(%ebx)
f0103d7e:	68 77 75 10 f0       	push   $0xf0107577
f0103d83:	e8 27 fb ff ff       	call   f01038af <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103d88:	83 c4 08             	add    $0x8,%esp
f0103d8b:	ff 73 0c             	pushl  0xc(%ebx)
f0103d8e:	68 86 75 10 f0       	push   $0xf0107586
f0103d93:	e8 17 fb ff ff       	call   f01038af <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d98:	83 c4 08             	add    $0x8,%esp
f0103d9b:	ff 73 10             	pushl  0x10(%ebx)
f0103d9e:	68 95 75 10 f0       	push   $0xf0107595
f0103da3:	e8 07 fb ff ff       	call   f01038af <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103da8:	83 c4 08             	add    $0x8,%esp
f0103dab:	ff 73 14             	pushl  0x14(%ebx)
f0103dae:	68 a4 75 10 f0       	push   $0xf01075a4
f0103db3:	e8 f7 fa ff ff       	call   f01038af <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103db8:	83 c4 08             	add    $0x8,%esp
f0103dbb:	ff 73 18             	pushl  0x18(%ebx)
f0103dbe:	68 b3 75 10 f0       	push   $0xf01075b3
f0103dc3:	e8 e7 fa ff ff       	call   f01038af <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103dc8:	83 c4 08             	add    $0x8,%esp
f0103dcb:	ff 73 1c             	pushl  0x1c(%ebx)
f0103dce:	68 c2 75 10 f0       	push   $0xf01075c2
f0103dd3:	e8 d7 fa ff ff       	call   f01038af <cprintf>
}
f0103dd8:	83 c4 10             	add    $0x10,%esp
f0103ddb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103dde:	c9                   	leave  
f0103ddf:	c3                   	ret    

f0103de0 <print_trapframe>:
{
f0103de0:	55                   	push   %ebp
f0103de1:	89 e5                	mov    %esp,%ebp
f0103de3:	56                   	push   %esi
f0103de4:	53                   	push   %ebx
f0103de5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103de8:	e8 4e 1e 00 00       	call   f0105c3b <cpunum>
f0103ded:	83 ec 04             	sub    $0x4,%esp
f0103df0:	50                   	push   %eax
f0103df1:	53                   	push   %ebx
f0103df2:	68 26 76 10 f0       	push   $0xf0107626
f0103df7:	e8 b3 fa ff ff       	call   f01038af <cprintf>
	print_regs(&tf->tf_regs);
f0103dfc:	89 1c 24             	mov    %ebx,(%esp)
f0103dff:	e8 4e ff ff ff       	call   f0103d52 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103e04:	83 c4 08             	add    $0x8,%esp
f0103e07:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103e0b:	50                   	push   %eax
f0103e0c:	68 44 76 10 f0       	push   $0xf0107644
f0103e11:	e8 99 fa ff ff       	call   f01038af <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e16:	83 c4 08             	add    $0x8,%esp
f0103e19:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103e1d:	50                   	push   %eax
f0103e1e:	68 57 76 10 f0       	push   $0xf0107657
f0103e23:	e8 87 fa ff ff       	call   f01038af <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e28:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103e2b:	83 c4 10             	add    $0x10,%esp
f0103e2e:	83 f8 13             	cmp    $0x13,%eax
f0103e31:	76 1f                	jbe    f0103e52 <print_trapframe+0x72>
		return "System call";
f0103e33:	ba d1 75 10 f0       	mov    $0xf01075d1,%edx
	if (trapno == T_SYSCALL)
f0103e38:	83 f8 30             	cmp    $0x30,%eax
f0103e3b:	74 1c                	je     f0103e59 <print_trapframe+0x79>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103e3d:	8d 50 e0             	lea    -0x20(%eax),%edx
	return "(unknown trap)";
f0103e40:	83 fa 10             	cmp    $0x10,%edx
f0103e43:	ba dd 75 10 f0       	mov    $0xf01075dd,%edx
f0103e48:	b9 f0 75 10 f0       	mov    $0xf01075f0,%ecx
f0103e4d:	0f 43 d1             	cmovae %ecx,%edx
f0103e50:	eb 07                	jmp    f0103e59 <print_trapframe+0x79>
		return excnames[trapno];
f0103e52:	8b 14 85 00 79 10 f0 	mov    -0xfef8700(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e59:	83 ec 04             	sub    $0x4,%esp
f0103e5c:	52                   	push   %edx
f0103e5d:	50                   	push   %eax
f0103e5e:	68 6a 76 10 f0       	push   $0xf010766a
f0103e63:	e8 47 fa ff ff       	call   f01038af <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e68:	83 c4 10             	add    $0x10,%esp
f0103e6b:	39 1d 60 3a 21 f0    	cmp    %ebx,0xf0213a60
f0103e71:	0f 84 a6 00 00 00    	je     f0103f1d <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f0103e77:	83 ec 08             	sub    $0x8,%esp
f0103e7a:	ff 73 2c             	pushl  0x2c(%ebx)
f0103e7d:	68 8b 76 10 f0       	push   $0xf010768b
f0103e82:	e8 28 fa ff ff       	call   f01038af <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103e87:	83 c4 10             	add    $0x10,%esp
f0103e8a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e8e:	0f 85 ac 00 00 00    	jne    f0103f40 <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103e94:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103e97:	89 c2                	mov    %eax,%edx
f0103e99:	83 e2 01             	and    $0x1,%edx
f0103e9c:	b9 ff 75 10 f0       	mov    $0xf01075ff,%ecx
f0103ea1:	ba 0a 76 10 f0       	mov    $0xf010760a,%edx
f0103ea6:	0f 44 ca             	cmove  %edx,%ecx
f0103ea9:	89 c2                	mov    %eax,%edx
f0103eab:	83 e2 02             	and    $0x2,%edx
f0103eae:	be 16 76 10 f0       	mov    $0xf0107616,%esi
f0103eb3:	ba 1c 76 10 f0       	mov    $0xf010761c,%edx
f0103eb8:	0f 45 d6             	cmovne %esi,%edx
f0103ebb:	83 e0 04             	and    $0x4,%eax
f0103ebe:	b8 21 76 10 f0       	mov    $0xf0107621,%eax
f0103ec3:	be 56 77 10 f0       	mov    $0xf0107756,%esi
f0103ec8:	0f 44 c6             	cmove  %esi,%eax
f0103ecb:	51                   	push   %ecx
f0103ecc:	52                   	push   %edx
f0103ecd:	50                   	push   %eax
f0103ece:	68 99 76 10 f0       	push   $0xf0107699
f0103ed3:	e8 d7 f9 ff ff       	call   f01038af <cprintf>
f0103ed8:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103edb:	83 ec 08             	sub    $0x8,%esp
f0103ede:	ff 73 30             	pushl  0x30(%ebx)
f0103ee1:	68 a8 76 10 f0       	push   $0xf01076a8
f0103ee6:	e8 c4 f9 ff ff       	call   f01038af <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103eeb:	83 c4 08             	add    $0x8,%esp
f0103eee:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103ef2:	50                   	push   %eax
f0103ef3:	68 b7 76 10 f0       	push   $0xf01076b7
f0103ef8:	e8 b2 f9 ff ff       	call   f01038af <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103efd:	83 c4 08             	add    $0x8,%esp
f0103f00:	ff 73 38             	pushl  0x38(%ebx)
f0103f03:	68 ca 76 10 f0       	push   $0xf01076ca
f0103f08:	e8 a2 f9 ff ff       	call   f01038af <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f0d:	83 c4 10             	add    $0x10,%esp
f0103f10:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f14:	75 3c                	jne    f0103f52 <print_trapframe+0x172>
}
f0103f16:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f19:	5b                   	pop    %ebx
f0103f1a:	5e                   	pop    %esi
f0103f1b:	5d                   	pop    %ebp
f0103f1c:	c3                   	ret    
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f1d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f21:	0f 85 50 ff ff ff    	jne    f0103e77 <print_trapframe+0x97>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103f27:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f2a:	83 ec 08             	sub    $0x8,%esp
f0103f2d:	50                   	push   %eax
f0103f2e:	68 7c 76 10 f0       	push   $0xf010767c
f0103f33:	e8 77 f9 ff ff       	call   f01038af <cprintf>
f0103f38:	83 c4 10             	add    $0x10,%esp
f0103f3b:	e9 37 ff ff ff       	jmp    f0103e77 <print_trapframe+0x97>
		cprintf("\n");
f0103f40:	83 ec 0c             	sub    $0xc,%esp
f0103f43:	68 29 74 10 f0       	push   $0xf0107429
f0103f48:	e8 62 f9 ff ff       	call   f01038af <cprintf>
f0103f4d:	83 c4 10             	add    $0x10,%esp
f0103f50:	eb 89                	jmp    f0103edb <print_trapframe+0xfb>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f52:	83 ec 08             	sub    $0x8,%esp
f0103f55:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f58:	68 d9 76 10 f0       	push   $0xf01076d9
f0103f5d:	e8 4d f9 ff ff       	call   f01038af <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f62:	83 c4 08             	add    $0x8,%esp
f0103f65:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103f69:	50                   	push   %eax
f0103f6a:	68 e8 76 10 f0       	push   $0xf01076e8
f0103f6f:	e8 3b f9 ff ff       	call   f01038af <cprintf>
f0103f74:	83 c4 10             	add    $0x10,%esp
}
f0103f77:	eb 9d                	jmp    f0103f16 <print_trapframe+0x136>

f0103f79 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103f79:	55                   	push   %ebp
f0103f7a:	89 e5                	mov    %esp,%ebp
f0103f7c:	57                   	push   %edi
f0103f7d:	56                   	push   %esi
f0103f7e:	53                   	push   %ebx
f0103f7f:	83 ec 0c             	sub    $0xc,%esp
f0103f82:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103f85:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
    	if ((tf->tf_cs & 3) == 0)
f0103f88:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f8c:	74 5d                	je     f0103feb <page_fault_handler+0x72>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0103f8e:	e8 a8 1c 00 00       	call   f0105c3b <cpunum>
f0103f93:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f96:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f0103f9c:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103fa0:	75 60                	jne    f0104002 <page_fault_handler+0x89>
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
		curenv->env_tf.tf_esp = utf_addr;
		env_run(curenv);
	}
		// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",curenv->env_id, fault_va, tf->tf_eip);
f0103fa2:	8b 7b 30             	mov    0x30(%ebx),%edi
f0103fa5:	e8 91 1c 00 00       	call   f0105c3b <cpunum>
f0103faa:	57                   	push   %edi
f0103fab:	56                   	push   %esi
f0103fac:	6b c0 74             	imul   $0x74,%eax,%eax
f0103faf:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f0103fb5:	ff 70 48             	pushl  0x48(%eax)
f0103fb8:	68 d4 78 10 f0       	push   $0xf01078d4
f0103fbd:	e8 ed f8 ff ff       	call   f01038af <cprintf>
	print_trapframe(tf);
f0103fc2:	89 1c 24             	mov    %ebx,(%esp)
f0103fc5:	e8 16 fe ff ff       	call   f0103de0 <print_trapframe>
	env_destroy(curenv);
f0103fca:	e8 6c 1c 00 00       	call   f0105c3b <cpunum>
f0103fcf:	83 c4 04             	add    $0x4,%esp
f0103fd2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd5:	ff b0 28 40 21 f0    	pushl  -0xfdebfd8(%eax)
f0103fdb:	e8 d3 f5 ff ff       	call   f01035b3 <env_destroy>
}
f0103fe0:	83 c4 10             	add    $0x10,%esp
f0103fe3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103fe6:	5b                   	pop    %ebx
f0103fe7:	5e                   	pop    %esi
f0103fe8:	5f                   	pop    %edi
f0103fe9:	5d                   	pop    %ebp
f0103fea:	c3                   	ret    
        	panic("page_fault_handler():page fault in kernel mode!\n");
f0103feb:	83 ec 04             	sub    $0x4,%esp
f0103fee:	68 a0 78 10 f0       	push   $0xf01078a0
f0103ff3:	68 5b 01 00 00       	push   $0x15b
f0103ff8:	68 fb 76 10 f0       	push   $0xf01076fb
f0103ffd:	e8 3e c0 ff ff       	call   f0100040 <_panic>
		if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f0104002:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104005:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf_addr = UXSTACKTOP - sizeof(struct UTrapframe);
f010400b:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
		if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f0104010:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104016:	77 05                	ja     f010401d <page_fault_handler+0xa4>
			utf_addr = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f0104018:	83 e8 38             	sub    $0x38,%eax
f010401b:	89 c7                	mov    %eax,%edi
		user_mem_assert(curenv, (void*)utf_addr, 1, PTE_W);//1 is enough
f010401d:	e8 19 1c 00 00       	call   f0105c3b <cpunum>
f0104022:	6a 02                	push   $0x2
f0104024:	6a 01                	push   $0x1
f0104026:	57                   	push   %edi
f0104027:	6b c0 74             	imul   $0x74,%eax,%eax
f010402a:	ff b0 28 40 21 f0    	pushl  -0xfdebfd8(%eax)
f0104030:	e8 39 ef ff ff       	call   f0102f6e <user_mem_assert>
		utf->utf_fault_va = fault_va;
f0104035:	89 fa                	mov    %edi,%edx
f0104037:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f0104039:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010403c:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f010403f:	8d 7f 08             	lea    0x8(%edi),%edi
f0104042:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104047:	89 de                	mov    %ebx,%esi
f0104049:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f010404b:	8b 43 30             	mov    0x30(%ebx),%eax
f010404e:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104051:	8b 43 38             	mov    0x38(%ebx),%eax
f0104054:	89 d7                	mov    %edx,%edi
f0104056:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0104059:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010405c:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f010405f:	e8 d7 1b 00 00       	call   f0105c3b <cpunum>
f0104064:	6b c0 74             	imul   $0x74,%eax,%eax
f0104067:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f010406d:	8b 58 64             	mov    0x64(%eax),%ebx
f0104070:	e8 c6 1b 00 00       	call   f0105c3b <cpunum>
f0104075:	6b c0 74             	imul   $0x74,%eax,%eax
f0104078:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f010407e:	89 58 30             	mov    %ebx,0x30(%eax)
		curenv->env_tf.tf_esp = utf_addr;
f0104081:	e8 b5 1b 00 00       	call   f0105c3b <cpunum>
f0104086:	6b c0 74             	imul   $0x74,%eax,%eax
f0104089:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f010408f:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f0104092:	e8 a4 1b 00 00       	call   f0105c3b <cpunum>
f0104097:	83 c4 04             	add    $0x4,%esp
f010409a:	6b c0 74             	imul   $0x74,%eax,%eax
f010409d:	ff b0 28 40 21 f0    	pushl  -0xfdebfd8(%eax)
f01040a3:	e8 aa f5 ff ff       	call   f0103652 <env_run>

f01040a8 <trap>:
{
f01040a8:	55                   	push   %ebp
f01040a9:	89 e5                	mov    %esp,%ebp
f01040ab:	57                   	push   %edi
f01040ac:	56                   	push   %esi
f01040ad:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01040b0:	fc                   	cld    
	if (panicstr)
f01040b1:	83 3d 80 3e 21 f0 00 	cmpl   $0x0,0xf0213e80
f01040b8:	74 01                	je     f01040bb <trap+0x13>
		asm volatile("hlt");
f01040ba:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01040bb:	e8 7b 1b 00 00       	call   f0105c3b <cpunum>
f01040c0:	6b d0 74             	imul   $0x74,%eax,%edx
f01040c3:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01040c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01040cb:	f0 87 82 20 40 21 f0 	lock xchg %eax,-0xfdebfe0(%edx)
f01040d2:	83 f8 02             	cmp    $0x2,%eax
f01040d5:	0f 84 c2 00 00 00    	je     f010419d <trap+0xf5>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01040db:	9c                   	pushf  
f01040dc:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01040dd:	f6 c4 02             	test   $0x2,%ah
f01040e0:	0f 85 cc 00 00 00    	jne    f01041b2 <trap+0x10a>
	if ((tf->tf_cs & 3) == 3) {
f01040e6:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01040ea:	83 e0 03             	and    $0x3,%eax
f01040ed:	66 83 f8 03          	cmp    $0x3,%ax
f01040f1:	0f 84 d4 00 00 00    	je     f01041cb <trap+0x123>
	last_tf = tf;
f01040f7:	89 35 60 3a 21 f0    	mov    %esi,0xf0213a60
	if (tf->tf_trapno == T_PGFLT) {
f01040fd:	8b 46 28             	mov    0x28(%esi),%eax
f0104100:	83 f8 0e             	cmp    $0xe,%eax
f0104103:	0f 84 67 01 00 00    	je     f0104270 <trap+0x1c8>
	if (tf->tf_trapno == T_BRKPT) {
f0104109:	83 f8 03             	cmp    $0x3,%eax
f010410c:	0f 84 6f 01 00 00    	je     f0104281 <trap+0x1d9>
	if (tf->tf_trapno == T_SYSCALL) {
f0104112:	83 f8 30             	cmp    $0x30,%eax
f0104115:	0f 84 77 01 00 00    	je     f0104292 <trap+0x1ea>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010411b:	83 f8 27             	cmp    $0x27,%eax
f010411e:	0f 84 92 01 00 00    	je     f01042b6 <trap+0x20e>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104124:	83 f8 20             	cmp    $0x20,%eax
f0104127:	0f 84 a6 01 00 00    	je     f01042d3 <trap+0x22b>
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD){
f010412d:	83 f8 21             	cmp    $0x21,%eax
f0104130:	0f 84 a7 01 00 00    	je     f01042dd <trap+0x235>
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL){
f0104136:	83 f8 24             	cmp    $0x24,%eax
f0104139:	0f 84 a8 01 00 00    	je     f01042e7 <trap+0x23f>
	print_trapframe(tf);
f010413f:	83 ec 0c             	sub    $0xc,%esp
f0104142:	56                   	push   %esi
f0104143:	e8 98 fc ff ff       	call   f0103de0 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104148:	83 c4 10             	add    $0x10,%esp
f010414b:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104150:	0f 84 9b 01 00 00    	je     f01042f1 <trap+0x249>
		env_destroy(curenv);
f0104156:	e8 e0 1a 00 00       	call   f0105c3b <cpunum>
f010415b:	83 ec 0c             	sub    $0xc,%esp
f010415e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104161:	ff b0 28 40 21 f0    	pushl  -0xfdebfd8(%eax)
f0104167:	e8 47 f4 ff ff       	call   f01035b3 <env_destroy>
f010416c:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f010416f:	e8 c7 1a 00 00       	call   f0105c3b <cpunum>
f0104174:	6b c0 74             	imul   $0x74,%eax,%eax
f0104177:	83 b8 28 40 21 f0 00 	cmpl   $0x0,-0xfdebfd8(%eax)
f010417e:	74 18                	je     f0104198 <trap+0xf0>
f0104180:	e8 b6 1a 00 00       	call   f0105c3b <cpunum>
f0104185:	6b c0 74             	imul   $0x74,%eax,%eax
f0104188:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f010418e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104192:	0f 84 70 01 00 00    	je     f0104308 <trap+0x260>
		sched_yield();
f0104198:	e8 da 02 00 00       	call   f0104477 <sched_yield>
	spin_lock(&kernel_lock);
f010419d:	83 ec 0c             	sub    $0xc,%esp
f01041a0:	68 c0 13 12 f0       	push   $0xf01213c0
f01041a5:	e8 01 1d 00 00       	call   f0105eab <spin_lock>
f01041aa:	83 c4 10             	add    $0x10,%esp
f01041ad:	e9 29 ff ff ff       	jmp    f01040db <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f01041b2:	68 07 77 10 f0       	push   $0xf0107707
f01041b7:	68 47 71 10 f0       	push   $0xf0107147
f01041bc:	68 24 01 00 00       	push   $0x124
f01041c1:	68 fb 76 10 f0       	push   $0xf01076fb
f01041c6:	e8 75 be ff ff       	call   f0100040 <_panic>
f01041cb:	83 ec 0c             	sub    $0xc,%esp
f01041ce:	68 c0 13 12 f0       	push   $0xf01213c0
f01041d3:	e8 d3 1c 00 00       	call   f0105eab <spin_lock>
		assert(curenv);
f01041d8:	e8 5e 1a 00 00       	call   f0105c3b <cpunum>
f01041dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01041e0:	83 c4 10             	add    $0x10,%esp
f01041e3:	83 b8 28 40 21 f0 00 	cmpl   $0x0,-0xfdebfd8(%eax)
f01041ea:	74 3e                	je     f010422a <trap+0x182>
		if (curenv->env_status == ENV_DYING) {
f01041ec:	e8 4a 1a 00 00       	call   f0105c3b <cpunum>
f01041f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01041f4:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f01041fa:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01041fe:	74 43                	je     f0104243 <trap+0x19b>
		curenv->env_tf = *tf;
f0104200:	e8 36 1a 00 00       	call   f0105c3b <cpunum>
f0104205:	6b c0 74             	imul   $0x74,%eax,%eax
f0104208:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f010420e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104213:	89 c7                	mov    %eax,%edi
f0104215:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104217:	e8 1f 1a 00 00       	call   f0105c3b <cpunum>
f010421c:	6b c0 74             	imul   $0x74,%eax,%eax
f010421f:	8b b0 28 40 21 f0    	mov    -0xfdebfd8(%eax),%esi
f0104225:	e9 cd fe ff ff       	jmp    f01040f7 <trap+0x4f>
		assert(curenv);
f010422a:	68 20 77 10 f0       	push   $0xf0107720
f010422f:	68 47 71 10 f0       	push   $0xf0107147
f0104234:	68 2d 01 00 00       	push   $0x12d
f0104239:	68 fb 76 10 f0       	push   $0xf01076fb
f010423e:	e8 fd bd ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0104243:	e8 f3 19 00 00       	call   f0105c3b <cpunum>
f0104248:	83 ec 0c             	sub    $0xc,%esp
f010424b:	6b c0 74             	imul   $0x74,%eax,%eax
f010424e:	ff b0 28 40 21 f0    	pushl  -0xfdebfd8(%eax)
f0104254:	e8 9d f1 ff ff       	call   f01033f6 <env_free>
			curenv = NULL;
f0104259:	e8 dd 19 00 00       	call   f0105c3b <cpunum>
f010425e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104261:	c7 80 28 40 21 f0 00 	movl   $0x0,-0xfdebfd8(%eax)
f0104268:	00 00 00 
			sched_yield();
f010426b:	e8 07 02 00 00       	call   f0104477 <sched_yield>
		page_fault_handler(tf);
f0104270:	83 ec 0c             	sub    $0xc,%esp
f0104273:	56                   	push   %esi
f0104274:	e8 00 fd ff ff       	call   f0103f79 <page_fault_handler>
f0104279:	83 c4 10             	add    $0x10,%esp
f010427c:	e9 ee fe ff ff       	jmp    f010416f <trap+0xc7>
		monitor(tf);
f0104281:	83 ec 0c             	sub    $0xc,%esp
f0104284:	56                   	push   %esi
f0104285:	e8 e0 c6 ff ff       	call   f010096a <monitor>
f010428a:	83 c4 10             	add    $0x10,%esp
f010428d:	e9 dd fe ff ff       	jmp    f010416f <trap+0xc7>
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104292:	83 ec 08             	sub    $0x8,%esp
f0104295:	ff 76 04             	pushl  0x4(%esi)
f0104298:	ff 36                	pushl  (%esi)
f010429a:	ff 76 10             	pushl  0x10(%esi)
f010429d:	ff 76 18             	pushl  0x18(%esi)
f01042a0:	ff 76 14             	pushl  0x14(%esi)
f01042a3:	ff 76 1c             	pushl  0x1c(%esi)
f01042a6:	e8 83 02 00 00       	call   f010452e <syscall>
		tf->tf_regs.reg_eax = 
f01042ab:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042ae:	83 c4 20             	add    $0x20,%esp
f01042b1:	e9 b9 fe ff ff       	jmp    f010416f <trap+0xc7>
		cprintf("Spurious interrupt on irq 7\n");
f01042b6:	83 ec 0c             	sub    $0xc,%esp
f01042b9:	68 27 77 10 f0       	push   $0xf0107727
f01042be:	e8 ec f5 ff ff       	call   f01038af <cprintf>
		print_trapframe(tf);
f01042c3:	89 34 24             	mov    %esi,(%esp)
f01042c6:	e8 15 fb ff ff       	call   f0103de0 <print_trapframe>
f01042cb:	83 c4 10             	add    $0x10,%esp
f01042ce:	e9 9c fe ff ff       	jmp    f010416f <trap+0xc7>
                lapic_eoi();
f01042d3:	e8 af 1a 00 00       	call   f0105d87 <lapic_eoi>
                sched_yield();
f01042d8:	e8 9a 01 00 00       	call   f0104477 <sched_yield>
		kbd_intr();
f01042dd:	e8 19 c3 ff ff       	call   f01005fb <kbd_intr>
f01042e2:	e9 88 fe ff ff       	jmp    f010416f <trap+0xc7>
		serial_intr();
f01042e7:	e8 f2 c2 ff ff       	call   f01005de <serial_intr>
f01042ec:	e9 7e fe ff ff       	jmp    f010416f <trap+0xc7>
		panic("unhandled trap in kernel");
f01042f1:	83 ec 04             	sub    $0x4,%esp
f01042f4:	68 44 77 10 f0       	push   $0xf0107744
f01042f9:	68 0a 01 00 00       	push   $0x10a
f01042fe:	68 fb 76 10 f0       	push   $0xf01076fb
f0104303:	e8 38 bd ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f0104308:	e8 2e 19 00 00       	call   f0105c3b <cpunum>
f010430d:	83 ec 0c             	sub    $0xc,%esp
f0104310:	6b c0 74             	imul   $0x74,%eax,%eax
f0104313:	ff b0 28 40 21 f0    	pushl  -0xfdebfd8(%eax)
f0104319:	e8 34 f3 ff ff       	call   f0103652 <env_run>

f010431e <th0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	TRAPHANDLER_NOEC(th0, 0)
f010431e:	6a 00                	push   $0x0
f0104320:	6a 00                	push   $0x0
f0104322:	eb 72                	jmp    f0104396 <_alltraps>

f0104324 <th1>:
	TRAPHANDLER_NOEC(th1, 1)
f0104324:	6a 00                	push   $0x0
f0104326:	6a 01                	push   $0x1
f0104328:	eb 6c                	jmp    f0104396 <_alltraps>

f010432a <th3>:
	TRAPHANDLER_NOEC(th3, 3)
f010432a:	6a 00                	push   $0x0
f010432c:	6a 03                	push   $0x3
f010432e:	eb 66                	jmp    f0104396 <_alltraps>

f0104330 <th4>:
	TRAPHANDLER_NOEC(th4, 4)
f0104330:	6a 00                	push   $0x0
f0104332:	6a 04                	push   $0x4
f0104334:	eb 60                	jmp    f0104396 <_alltraps>

f0104336 <th5>:
	TRAPHANDLER_NOEC(th5, 5)
f0104336:	6a 00                	push   $0x0
f0104338:	6a 05                	push   $0x5
f010433a:	eb 5a                	jmp    f0104396 <_alltraps>

f010433c <th6>:
	TRAPHANDLER_NOEC(th6, 6)
f010433c:	6a 00                	push   $0x0
f010433e:	6a 06                	push   $0x6
f0104340:	eb 54                	jmp    f0104396 <_alltraps>

f0104342 <th7>:
	TRAPHANDLER_NOEC(th7, 7)
f0104342:	6a 00                	push   $0x0
f0104344:	6a 07                	push   $0x7
f0104346:	eb 4e                	jmp    f0104396 <_alltraps>

f0104348 <th8>:
	TRAPHANDLER(th8, 8)
f0104348:	6a 08                	push   $0x8
f010434a:	eb 4a                	jmp    f0104396 <_alltraps>

f010434c <th9>:
	TRAPHANDLER_NOEC(th9, 9)
f010434c:	6a 00                	push   $0x0
f010434e:	6a 09                	push   $0x9
f0104350:	eb 44                	jmp    f0104396 <_alltraps>

f0104352 <th10>:
	TRAPHANDLER(th10, 10)
f0104352:	6a 0a                	push   $0xa
f0104354:	eb 40                	jmp    f0104396 <_alltraps>

f0104356 <th11>:
	TRAPHANDLER(th11, 11)
f0104356:	6a 0b                	push   $0xb
f0104358:	eb 3c                	jmp    f0104396 <_alltraps>

f010435a <th12>:
	TRAPHANDLER(th12, 12)
f010435a:	6a 0c                	push   $0xc
f010435c:	eb 38                	jmp    f0104396 <_alltraps>

f010435e <th13>:
	TRAPHANDLER(th13, 13)
f010435e:	6a 0d                	push   $0xd
f0104360:	eb 34                	jmp    f0104396 <_alltraps>

f0104362 <th14>:
	TRAPHANDLER(th14, 14)
f0104362:	6a 0e                	push   $0xe
f0104364:	eb 30                	jmp    f0104396 <_alltraps>

f0104366 <th16>:
	TRAPHANDLER_NOEC(th16, 16)
f0104366:	6a 00                	push   $0x0
f0104368:	6a 10                	push   $0x10
f010436a:	eb 2a                	jmp    f0104396 <_alltraps>

f010436c <th_syscall>:
	TRAPHANDLER_NOEC(th_syscall, T_SYSCALL)
f010436c:	6a 00                	push   $0x0
f010436e:	6a 30                	push   $0x30
f0104370:	eb 24                	jmp    f0104396 <_alltraps>

f0104372 <irqtimer_handler>:
	TRAPHANDLER_NOEC(irqtimer_handler, IRQ_OFFSET + IRQ_TIMER)
f0104372:	6a 00                	push   $0x0
f0104374:	6a 20                	push   $0x20
f0104376:	eb 1e                	jmp    f0104396 <_alltraps>

f0104378 <irqkbd_handler>:
	TRAPHANDLER_NOEC(irqkbd_handler, IRQ_OFFSET + IRQ_KBD)
f0104378:	6a 00                	push   $0x0
f010437a:	6a 21                	push   $0x21
f010437c:	eb 18                	jmp    f0104396 <_alltraps>

f010437e <irqserial_handler>:
	TRAPHANDLER_NOEC(irqserial_handler, IRQ_OFFSET + IRQ_SERIAL)
f010437e:	6a 00                	push   $0x0
f0104380:	6a 24                	push   $0x24
f0104382:	eb 12                	jmp    f0104396 <_alltraps>

f0104384 <irqspurious_handler>:
	TRAPHANDLER_NOEC(irqspurious_handler, IRQ_OFFSET + IRQ_SPURIOUS)
f0104384:	6a 00                	push   $0x0
f0104386:	6a 27                	push   $0x27
f0104388:	eb 0c                	jmp    f0104396 <_alltraps>

f010438a <irqide_handler>:
	TRAPHANDLER_NOEC(irqide_handler, IRQ_OFFSET + IRQ_IDE)
f010438a:	6a 00                	push   $0x0
f010438c:	6a 2e                	push   $0x2e
f010438e:	eb 06                	jmp    f0104396 <_alltraps>

f0104390 <irqerror_handler>:
	TRAPHANDLER_NOEC(irqerror_handler, IRQ_OFFSET + IRQ_ERROR)
f0104390:	6a 00                	push   $0x0
f0104392:	6a 33                	push   $0x33
f0104394:	eb 00                	jmp    f0104396 <_alltraps>

f0104396 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104396:	1e                   	push   %ds
	pushl %es
f0104397:	06                   	push   %es
	pushal
f0104398:	60                   	pusha  
	pushl $GD_KD
f0104399:	6a 10                	push   $0x10
	popl %ds
f010439b:	1f                   	pop    %ds
	pushl $GD_KD
f010439c:	6a 10                	push   $0x10
	popl %es
f010439e:	07                   	pop    %es
	pushl %esp
f010439f:	54                   	push   %esp
	call trap
f01043a0:	e8 03 fd ff ff       	call   f01040a8 <trap>

f01043a5 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01043a5:	55                   	push   %ebp
f01043a6:	89 e5                	mov    %esp,%ebp
f01043a8:	83 ec 08             	sub    $0x8,%esp
f01043ab:	a1 44 32 21 f0       	mov    0xf0213244,%eax
f01043b0:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01043b3:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01043b8:	8b 10                	mov    (%eax),%edx
f01043ba:	83 ea 01             	sub    $0x1,%edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01043bd:	83 fa 02             	cmp    $0x2,%edx
f01043c0:	76 2d                	jbe    f01043ef <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f01043c2:	83 c1 01             	add    $0x1,%ecx
f01043c5:	83 c0 7c             	add    $0x7c,%eax
f01043c8:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01043ce:	75 e8                	jne    f01043b8 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f01043d0:	83 ec 0c             	sub    $0xc,%esp
f01043d3:	68 50 79 10 f0       	push   $0xf0107950
f01043d8:	e8 d2 f4 ff ff       	call   f01038af <cprintf>
f01043dd:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01043e0:	83 ec 0c             	sub    $0xc,%esp
f01043e3:	6a 00                	push   $0x0
f01043e5:	e8 80 c5 ff ff       	call   f010096a <monitor>
f01043ea:	83 c4 10             	add    $0x10,%esp
f01043ed:	eb f1                	jmp    f01043e0 <sched_halt+0x3b>
	if (i == NENV) {
f01043ef:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01043f5:	74 d9                	je     f01043d0 <sched_halt+0x2b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01043f7:	e8 3f 18 00 00       	call   f0105c3b <cpunum>
f01043fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01043ff:	c7 80 28 40 21 f0 00 	movl   $0x0,-0xfdebfd8(%eax)
f0104406:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104409:	a1 8c 3e 21 f0       	mov    0xf0213e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010440e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104413:	76 50                	jbe    f0104465 <sched_halt+0xc0>
	return (physaddr_t)kva - KERNBASE;
f0104415:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010441a:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010441d:	e8 19 18 00 00       	call   f0105c3b <cpunum>
f0104422:	6b d0 74             	imul   $0x74,%eax,%edx
f0104425:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104428:	b8 02 00 00 00       	mov    $0x2,%eax
f010442d:	f0 87 82 20 40 21 f0 	lock xchg %eax,-0xfdebfe0(%edx)
	spin_unlock(&kernel_lock);
f0104434:	83 ec 0c             	sub    $0xc,%esp
f0104437:	68 c0 13 12 f0       	push   $0xf01213c0
f010443c:	e8 07 1b 00 00       	call   f0105f48 <spin_unlock>
	asm volatile("pause");
f0104441:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104443:	e8 f3 17 00 00       	call   f0105c3b <cpunum>
f0104448:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f010444b:	8b 80 30 40 21 f0    	mov    -0xfdebfd0(%eax),%eax
f0104451:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104456:	89 c4                	mov    %eax,%esp
f0104458:	6a 00                	push   $0x0
f010445a:	6a 00                	push   $0x0
f010445c:	fb                   	sti    
f010445d:	f4                   	hlt    
f010445e:	eb fd                	jmp    f010445d <sched_halt+0xb8>
}
f0104460:	83 c4 10             	add    $0x10,%esp
f0104463:	c9                   	leave  
f0104464:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104465:	50                   	push   %eax
f0104466:	68 c8 62 10 f0       	push   $0xf01062c8
f010446b:	6a 47                	push   $0x47
f010446d:	68 79 79 10 f0       	push   $0xf0107979
f0104472:	e8 c9 bb ff ff       	call   f0100040 <_panic>

f0104477 <sched_yield>:
{
f0104477:	55                   	push   %ebp
f0104478:	89 e5                	mov    %esp,%ebp
f010447a:	56                   	push   %esi
f010447b:	53                   	push   %ebx
	if (curenv) cur=ENVX(curenv->env_id)+1;
f010447c:	e8 ba 17 00 00       	call   f0105c3b <cpunum>
f0104481:	6b c0 74             	imul   $0x74,%eax,%eax
	int i, cur=0;
f0104484:	b9 00 00 00 00       	mov    $0x0,%ecx
	if (curenv) cur=ENVX(curenv->env_id)+1;
f0104489:	83 b8 28 40 21 f0 00 	cmpl   $0x0,-0xfdebfd8(%eax)
f0104490:	74 1a                	je     f01044ac <sched_yield+0x35>
f0104492:	e8 a4 17 00 00       	call   f0105c3b <cpunum>
f0104497:	6b c0 74             	imul   $0x74,%eax,%eax
f010449a:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f01044a0:	8b 48 48             	mov    0x48(%eax),%ecx
f01044a3:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f01044a9:	83 c1 01             	add    $0x1,%ecx
		if (envs[j].env_status == ENV_RUNNABLE) {
f01044ac:	8b 1d 44 32 21 f0    	mov    0xf0213244,%ebx
f01044b2:	89 ca                	mov    %ecx,%edx
f01044b4:	81 c1 00 04 00 00    	add    $0x400,%ecx
		int j = (cur+i) % NENV;
f01044ba:	89 d6                	mov    %edx,%esi
f01044bc:	c1 fe 1f             	sar    $0x1f,%esi
f01044bf:	c1 ee 16             	shr    $0x16,%esi
f01044c2:	8d 04 32             	lea    (%edx,%esi,1),%eax
f01044c5:	25 ff 03 00 00       	and    $0x3ff,%eax
f01044ca:	29 f0                	sub    %esi,%eax
		if (envs[j].env_status == ENV_RUNNABLE) {
f01044cc:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01044cf:	01 d8                	add    %ebx,%eax
f01044d1:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01044d5:	74 38                	je     f010450f <sched_yield+0x98>
f01044d7:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < NENV; i++) {
f01044da:	39 ca                	cmp    %ecx,%edx
f01044dc:	75 dc                	jne    f01044ba <sched_yield+0x43>
	if (curenv && curenv->env_status == ENV_RUNNING)
f01044de:	e8 58 17 00 00       	call   f0105c3b <cpunum>
f01044e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01044e6:	83 b8 28 40 21 f0 00 	cmpl   $0x0,-0xfdebfd8(%eax)
f01044ed:	74 14                	je     f0104503 <sched_yield+0x8c>
f01044ef:	e8 47 17 00 00       	call   f0105c3b <cpunum>
f01044f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01044f7:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f01044fd:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104501:	74 15                	je     f0104518 <sched_yield+0xa1>
	sched_halt();
f0104503:	e8 9d fe ff ff       	call   f01043a5 <sched_halt>
}
f0104508:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010450b:	5b                   	pop    %ebx
f010450c:	5e                   	pop    %esi
f010450d:	5d                   	pop    %ebp
f010450e:	c3                   	ret    
			env_run(envs + j);
f010450f:	83 ec 0c             	sub    $0xc,%esp
f0104512:	50                   	push   %eax
f0104513:	e8 3a f1 ff ff       	call   f0103652 <env_run>
		env_run(curenv);
f0104518:	e8 1e 17 00 00       	call   f0105c3b <cpunum>
f010451d:	83 ec 0c             	sub    $0xc,%esp
f0104520:	6b c0 74             	imul   $0x74,%eax,%eax
f0104523:	ff b0 28 40 21 f0    	pushl  -0xfdebfd8(%eax)
f0104529:	e8 24 f1 ff ff       	call   f0103652 <env_run>

f010452e <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010452e:	55                   	push   %ebp
f010452f:	89 e5                	mov    %esp,%ebp
f0104531:	57                   	push   %edi
f0104532:	56                   	push   %esi
f0104533:	53                   	push   %ebx
f0104534:	83 ec 1c             	sub    $0x1c,%esp
f0104537:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int ret = 0;
	switch (syscallno) {
f010453a:	83 f8 0d             	cmp    $0xd,%eax
f010453d:	0f 87 57 05 00 00    	ja     f0104a9a <syscall+0x56c>
f0104543:	ff 24 85 8c 79 10 f0 	jmp    *-0xfef8674(,%eax,4)
	user_mem_assert(curenv, s, len, 0);
f010454a:	e8 ec 16 00 00       	call   f0105c3b <cpunum>
f010454f:	6a 00                	push   $0x0
f0104551:	ff 75 10             	pushl  0x10(%ebp)
f0104554:	ff 75 0c             	pushl  0xc(%ebp)
f0104557:	6b c0 74             	imul   $0x74,%eax,%eax
f010455a:	ff b0 28 40 21 f0    	pushl  -0xfdebfd8(%eax)
f0104560:	e8 09 ea ff ff       	call   f0102f6e <user_mem_assert>
	cprintf("%.*s", len, s);
f0104565:	83 c4 0c             	add    $0xc,%esp
f0104568:	ff 75 0c             	pushl  0xc(%ebp)
f010456b:	ff 75 10             	pushl  0x10(%ebp)
f010456e:	68 86 79 10 f0       	push   $0xf0107986
f0104573:	e8 37 f3 ff ff       	call   f01038af <cprintf>
f0104578:	83 c4 10             	add    $0x10,%esp
		case SYS_cputs: 
			sys_cputs((char*)a1, a2);
			ret = 0;
f010457b:	bb 00 00 00 00       	mov    $0x0,%ebx
		default:
			ret = -E_INVAL;
	}
	return ret;	
	panic("syscall not implemented");
}
f0104580:	89 d8                	mov    %ebx,%eax
f0104582:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104585:	5b                   	pop    %ebx
f0104586:	5e                   	pop    %esi
f0104587:	5f                   	pop    %edi
f0104588:	5d                   	pop    %ebp
f0104589:	c3                   	ret    
	return cons_getc();
f010458a:	e8 7e c0 ff ff       	call   f010060d <cons_getc>
f010458f:	89 c3                	mov    %eax,%ebx
			break;
f0104591:	eb ed                	jmp    f0104580 <syscall+0x52>
	return curenv->env_id;
f0104593:	e8 a3 16 00 00       	call   f0105c3b <cpunum>
f0104598:	6b c0 74             	imul   $0x74,%eax,%eax
f010459b:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f01045a1:	8b 58 48             	mov    0x48(%eax),%ebx
			break;
f01045a4:	eb da                	jmp    f0104580 <syscall+0x52>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01045a6:	83 ec 04             	sub    $0x4,%esp
f01045a9:	6a 01                	push   $0x1
f01045ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045ae:	50                   	push   %eax
f01045af:	ff 75 0c             	pushl  0xc(%ebp)
f01045b2:	e8 89 ea ff ff       	call   f0103040 <envid2env>
f01045b7:	83 c4 10             	add    $0x10,%esp
f01045ba:	85 c0                	test   %eax,%eax
f01045bc:	78 0e                	js     f01045cc <syscall+0x9e>
	env_destroy(e);
f01045be:	83 ec 0c             	sub    $0xc,%esp
f01045c1:	ff 75 e4             	pushl  -0x1c(%ebp)
f01045c4:	e8 ea ef ff ff       	call   f01035b3 <env_destroy>
f01045c9:	83 c4 10             	add    $0x10,%esp
			ret = 0;
f01045cc:	bb 00 00 00 00       	mov    $0x0,%ebx
f01045d1:	eb ad                	jmp    f0104580 <syscall+0x52>
	sched_yield();
f01045d3:	e8 9f fe ff ff       	call   f0104477 <sched_yield>
	return curenv->env_id;
f01045d8:	e8 5e 16 00 00       	call   f0105c3b <cpunum>
        if ((ret = env_alloc(&env, sys_getenvid())) < 0)
f01045dd:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f01045e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01045e3:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
        if ((ret = env_alloc(&env, sys_getenvid())) < 0)
f01045e9:	ff 70 48             	pushl  0x48(%eax)
f01045ec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045ef:	50                   	push   %eax
f01045f0:	e8 5c eb ff ff       	call   f0103151 <env_alloc>
f01045f5:	89 c3                	mov    %eax,%ebx
f01045f7:	83 c4 10             	add    $0x10,%esp
f01045fa:	85 c0                	test   %eax,%eax
f01045fc:	78 82                	js     f0104580 <syscall+0x52>
        env->env_status = ENV_NOT_RUNNABLE;
f01045fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104601:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        env->env_tf = curenv->env_tf;
f0104608:	e8 2e 16 00 00       	call   f0105c3b <cpunum>
f010460d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104610:	8b b0 28 40 21 f0    	mov    -0xfdebfd8(%eax),%esi
f0104616:	b9 11 00 00 00       	mov    $0x11,%ecx
f010461b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010461e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        env->env_tf.tf_regs.reg_eax = 0;
f0104620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104623:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        return env->env_id;
f010462a:	8b 58 48             	mov    0x48(%eax),%ebx
        		break;
f010462d:	e9 4e ff ff ff       	jmp    f0104580 <syscall+0x52>
	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
f0104632:	8b 45 10             	mov    0x10(%ebp),%eax
f0104635:	83 e8 02             	sub    $0x2,%eax
f0104638:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010463d:	75 2b                	jne    f010466a <syscall+0x13c>
	if(envid2env(envid,&e,1)<0) 
f010463f:	83 ec 04             	sub    $0x4,%esp
f0104642:	6a 01                	push   $0x1
f0104644:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104647:	50                   	push   %eax
f0104648:	ff 75 0c             	pushl  0xc(%ebp)
f010464b:	e8 f0 e9 ff ff       	call   f0103040 <envid2env>
f0104650:	83 c4 10             	add    $0x10,%esp
f0104653:	85 c0                	test   %eax,%eax
f0104655:	78 1d                	js     f0104674 <syscall+0x146>
	e->env_status = status;
f0104657:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010465a:	8b 7d 10             	mov    0x10(%ebp),%edi
f010465d:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f0104660:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104665:	e9 16 ff ff ff       	jmp    f0104580 <syscall+0x52>
		return -E_INVAL;
f010466a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010466f:	e9 0c ff ff ff       	jmp    f0104580 <syscall+0x52>
		return -E_BAD_ENV;
f0104674:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			break;
f0104679:	e9 02 ff ff ff       	jmp    f0104580 <syscall+0x52>
        if (envid2env(envid, &env, 1) < 0)
f010467e:	83 ec 04             	sub    $0x4,%esp
f0104681:	6a 01                	push   $0x1
f0104683:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104686:	50                   	push   %eax
f0104687:	ff 75 0c             	pushl  0xc(%ebp)
f010468a:	e8 b1 e9 ff ff       	call   f0103040 <envid2env>
f010468f:	83 c4 10             	add    $0x10,%esp
f0104692:	85 c0                	test   %eax,%eax
f0104694:	78 6e                	js     f0104704 <syscall+0x1d6>
        if ((uintptr_t)va >= UTOP || PGOFF(va))
f0104696:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010469d:	77 6f                	ja     f010470e <syscall+0x1e0>
f010469f:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01046a6:	75 70                	jne    f0104718 <syscall+0x1ea>
        if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
f01046a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01046ab:	83 e0 05             	and    $0x5,%eax
f01046ae:	83 f8 05             	cmp    $0x5,%eax
f01046b1:	75 6f                	jne    f0104722 <syscall+0x1f4>
        if ((perm & ~(PTE_U | PTE_P | PTE_W | PTE_AVAIL)) != 0)
f01046b3:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01046b6:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f01046bc:	75 6e                	jne    f010472c <syscall+0x1fe>
        if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
f01046be:	83 ec 0c             	sub    $0xc,%esp
f01046c1:	6a 01                	push   $0x1
f01046c3:	e8 83 c8 ff ff       	call   f0100f4b <page_alloc>
f01046c8:	89 c6                	mov    %eax,%esi
f01046ca:	83 c4 10             	add    $0x10,%esp
f01046cd:	85 c0                	test   %eax,%eax
f01046cf:	74 65                	je     f0104736 <syscall+0x208>
        if (page_insert(env->env_pgdir, pp, va, perm) < 0) {
f01046d1:	ff 75 14             	pushl  0x14(%ebp)
f01046d4:	ff 75 10             	pushl  0x10(%ebp)
f01046d7:	50                   	push   %eax
f01046d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046db:	ff 70 60             	pushl  0x60(%eax)
f01046de:	e8 39 cb ff ff       	call   f010121c <page_insert>
f01046e3:	83 c4 10             	add    $0x10,%esp
f01046e6:	85 c0                	test   %eax,%eax
f01046e8:	0f 89 92 fe ff ff    	jns    f0104580 <syscall+0x52>
                page_free(pp);
f01046ee:	83 ec 0c             	sub    $0xc,%esp
f01046f1:	56                   	push   %esi
f01046f2:	e8 c6 c8 ff ff       	call   f0100fbd <page_free>
f01046f7:	83 c4 10             	add    $0x10,%esp
                return -E_NO_MEM;
f01046fa:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01046ff:	e9 7c fe ff ff       	jmp    f0104580 <syscall+0x52>
                return -E_BAD_ENV;
f0104704:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104709:	e9 72 fe ff ff       	jmp    f0104580 <syscall+0x52>
                return -E_INVAL;
f010470e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104713:	e9 68 fe ff ff       	jmp    f0104580 <syscall+0x52>
f0104718:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010471d:	e9 5e fe ff ff       	jmp    f0104580 <syscall+0x52>
                return -E_INVAL;
f0104722:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104727:	e9 54 fe ff ff       	jmp    f0104580 <syscall+0x52>
                return -E_INVAL;
f010472c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104731:	e9 4a fe ff ff       	jmp    f0104580 <syscall+0x52>
                return -E_NO_MEM;
f0104736:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
        		break;
f010473b:	e9 40 fe ff ff       	jmp    f0104580 <syscall+0x52>
        if (envid2env(srcenvid, &srcenv, 1) < 0 || envid2env(dstenvid, &dstenv, 1) < 0)
f0104740:	83 ec 04             	sub    $0x4,%esp
f0104743:	6a 01                	push   $0x1
f0104745:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104748:	50                   	push   %eax
f0104749:	ff 75 0c             	pushl  0xc(%ebp)
f010474c:	e8 ef e8 ff ff       	call   f0103040 <envid2env>
f0104751:	83 c4 10             	add    $0x10,%esp
f0104754:	85 c0                	test   %eax,%eax
f0104756:	0f 88 a9 00 00 00    	js     f0104805 <syscall+0x2d7>
f010475c:	83 ec 04             	sub    $0x4,%esp
f010475f:	6a 01                	push   $0x1
f0104761:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104764:	50                   	push   %eax
f0104765:	ff 75 14             	pushl  0x14(%ebp)
f0104768:	e8 d3 e8 ff ff       	call   f0103040 <envid2env>
f010476d:	83 c4 10             	add    $0x10,%esp
f0104770:	85 c0                	test   %eax,%eax
f0104772:	0f 88 97 00 00 00    	js     f010480f <syscall+0x2e1>
        if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) || (uintptr_t)dstva >= UTOP || PGOFF(dstva))
f0104778:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010477f:	0f 87 94 00 00 00    	ja     f0104819 <syscall+0x2eb>
f0104785:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010478c:	0f 85 91 00 00 00    	jne    f0104823 <syscall+0x2f5>
f0104792:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104799:	0f 87 84 00 00 00    	ja     f0104823 <syscall+0x2f5>
f010479f:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01047a6:	0f 85 81 00 00 00    	jne    f010482d <syscall+0x2ff>
        if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_SYSCALL) != 0)
f01047ac:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01047af:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01047b4:	83 f8 05             	cmp    $0x5,%eax
f01047b7:	75 7e                	jne    f0104837 <syscall+0x309>
        if ((pp = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
f01047b9:	83 ec 04             	sub    $0x4,%esp
f01047bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047bf:	50                   	push   %eax
f01047c0:	ff 75 10             	pushl  0x10(%ebp)
f01047c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01047c6:	ff 70 60             	pushl  0x60(%eax)
f01047c9:	e8 6b c9 ff ff       	call   f0101139 <page_lookup>
f01047ce:	83 c4 10             	add    $0x10,%esp
f01047d1:	85 c0                	test   %eax,%eax
f01047d3:	74 6c                	je     f0104841 <syscall+0x313>
        if ((perm & PTE_W) && (*pte & PTE_W) == 0)
f01047d5:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01047d9:	74 08                	je     f01047e3 <syscall+0x2b5>
f01047db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01047de:	f6 02 02             	testb  $0x2,(%edx)
f01047e1:	74 68                	je     f010484b <syscall+0x31d>
        if (page_insert(dstenv->env_pgdir, pp, dstva, perm) < 0)
f01047e3:	ff 75 1c             	pushl  0x1c(%ebp)
f01047e6:	ff 75 18             	pushl  0x18(%ebp)
f01047e9:	50                   	push   %eax
f01047ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047ed:	ff 70 60             	pushl  0x60(%eax)
f01047f0:	e8 27 ca ff ff       	call   f010121c <page_insert>
f01047f5:	83 c4 10             	add    $0x10,%esp
        return 0;
f01047f8:	c1 f8 1f             	sar    $0x1f,%eax
f01047fb:	89 c3                	mov    %eax,%ebx
f01047fd:	83 e3 fc             	and    $0xfffffffc,%ebx
f0104800:	e9 7b fd ff ff       	jmp    f0104580 <syscall+0x52>
                return -E_BAD_ENV;
f0104805:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010480a:	e9 71 fd ff ff       	jmp    f0104580 <syscall+0x52>
f010480f:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104814:	e9 67 fd ff ff       	jmp    f0104580 <syscall+0x52>
                return -E_INVAL;
f0104819:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010481e:	e9 5d fd ff ff       	jmp    f0104580 <syscall+0x52>
f0104823:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104828:	e9 53 fd ff ff       	jmp    f0104580 <syscall+0x52>
f010482d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104832:	e9 49 fd ff ff       	jmp    f0104580 <syscall+0x52>
                return -E_INVAL;
f0104837:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010483c:	e9 3f fd ff ff       	jmp    f0104580 <syscall+0x52>
                return -E_INVAL;
f0104841:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104846:	e9 35 fd ff ff       	jmp    f0104580 <syscall+0x52>
                return -E_INVAL;
f010484b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104850:	e9 2b fd ff ff       	jmp    f0104580 <syscall+0x52>
        if (envid2env(envid, &env, 1) < 0)
f0104855:	83 ec 04             	sub    $0x4,%esp
f0104858:	6a 01                	push   $0x1
f010485a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010485d:	50                   	push   %eax
f010485e:	ff 75 0c             	pushl  0xc(%ebp)
f0104861:	e8 da e7 ff ff       	call   f0103040 <envid2env>
f0104866:	83 c4 10             	add    $0x10,%esp
f0104869:	85 c0                	test   %eax,%eax
f010486b:	78 30                	js     f010489d <syscall+0x36f>
        if ((uintptr_t)va >= UTOP || PGOFF(va))
f010486d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104874:	77 31                	ja     f01048a7 <syscall+0x379>
f0104876:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010487d:	75 32                	jne    f01048b1 <syscall+0x383>
        page_remove(env->env_pgdir, va);
f010487f:	83 ec 08             	sub    $0x8,%esp
f0104882:	ff 75 10             	pushl  0x10(%ebp)
f0104885:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104888:	ff 70 60             	pushl  0x60(%eax)
f010488b:	e8 44 c9 ff ff       	call   f01011d4 <page_remove>
f0104890:	83 c4 10             	add    $0x10,%esp
        return 0;
f0104893:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104898:	e9 e3 fc ff ff       	jmp    f0104580 <syscall+0x52>
                return -E_BAD_ENV;
f010489d:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01048a2:	e9 d9 fc ff ff       	jmp    f0104580 <syscall+0x52>
                return -E_INVAL;
f01048a7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048ac:	e9 cf fc ff ff       	jmp    f0104580 <syscall+0x52>
f01048b1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			break;
f01048b6:	e9 c5 fc ff ff       	jmp    f0104580 <syscall+0x52>
	int ret = envid2env(envid, &e, 1);
f01048bb:	83 ec 04             	sub    $0x4,%esp
f01048be:	6a 01                	push   $0x1
f01048c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048c3:	50                   	push   %eax
f01048c4:	ff 75 0c             	pushl  0xc(%ebp)
f01048c7:	e8 74 e7 ff ff       	call   f0103040 <envid2env>
f01048cc:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;	//bad_env
f01048ce:	83 c4 10             	add    $0x10,%esp
f01048d1:	85 c0                	test   %eax,%eax
f01048d3:	0f 85 a7 fc ff ff    	jne    f0104580 <syscall+0x52>
	e->env_pgfault_upcall = func;
f01048d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01048df:	89 48 64             	mov    %ecx,0x64(%eax)
			break;
f01048e2:	e9 99 fc ff ff       	jmp    f0104580 <syscall+0x52>
	int ret = envid2env(envid, &e, 0);
f01048e7:	83 ec 04             	sub    $0x4,%esp
f01048ea:	6a 00                	push   $0x0
f01048ec:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01048ef:	50                   	push   %eax
f01048f0:	ff 75 0c             	pushl  0xc(%ebp)
f01048f3:	e8 48 e7 ff ff       	call   f0103040 <envid2env>
f01048f8:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;//bad env
f01048fa:	83 c4 10             	add    $0x10,%esp
f01048fd:	85 c0                	test   %eax,%eax
f01048ff:	0f 85 7b fc ff ff    	jne    f0104580 <syscall+0x52>
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104905:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104908:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f010490c:	0f 84 de 00 00 00    	je     f01049f0 <syscall+0x4c2>
	if (srcva < (void*)UTOP) {
f0104912:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104919:	77 64                	ja     f010497f <syscall+0x451>
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f010491b:	e8 1b 13 00 00       	call   f0105c3b <cpunum>
f0104920:	83 ec 04             	sub    $0x4,%esp
f0104923:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104926:	52                   	push   %edx
f0104927:	ff 75 14             	pushl  0x14(%ebp)
f010492a:	6b c0 74             	imul   $0x74,%eax,%eax
f010492d:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f0104933:	ff 70 60             	pushl  0x60(%eax)
f0104936:	e8 fe c7 ff ff       	call   f0101139 <page_lookup>
        	if (srcva != ROUNDDOWN(srcva, PGSIZE)) {
f010493b:	83 c4 10             	add    $0x10,%esp
f010493e:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104945:	74 0a                	je     f0104951 <syscall+0x423>
            		return -E_INVAL;
f0104947:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010494c:	e9 2f fc ff ff       	jmp    f0104580 <syscall+0x52>
        	if ((*pte & perm & 7) != (perm & 7)) {
f0104951:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104954:	8b 0a                	mov    (%edx),%ecx
f0104956:	89 ca                	mov    %ecx,%edx
f0104958:	f7 d2                	not    %edx
f010495a:	83 e2 07             	and    $0x7,%edx
        	if (!pg) {
f010495d:	85 55 18             	test   %edx,0x18(%ebp)
f0104960:	75 73                	jne    f01049d5 <syscall+0x4a7>
f0104962:	85 c0                	test   %eax,%eax
f0104964:	74 6f                	je     f01049d5 <syscall+0x4a7>
        	if ((perm & PTE_W) && !(*pte & PTE_W)) {
f0104966:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010496a:	74 05                	je     f0104971 <syscall+0x443>
f010496c:	f6 c1 02             	test   $0x2,%cl
f010496f:	74 6e                	je     f01049df <syscall+0x4b1>
		if (e->env_ipc_dstva < (void*)UTOP) {
f0104971:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104974:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104977:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010497d:	76 37                	jbe    f01049b6 <syscall+0x488>
	e->env_ipc_recving = 0;
f010497f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104982:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	e->env_ipc_from = curenv->env_id;
f0104986:	e8 b0 12 00 00       	call   f0105c3b <cpunum>
f010498b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010498e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104991:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f0104997:	8b 40 48             	mov    0x48(%eax),%eax
f010499a:	89 42 74             	mov    %eax,0x74(%edx)
	e->env_ipc_value = value; 
f010499d:	8b 45 10             	mov    0x10(%ebp),%eax
f01049a0:	89 42 70             	mov    %eax,0x70(%edx)
	e->env_status = ENV_RUNNABLE;
f01049a3:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	e->env_tf.tf_regs.reg_eax = 0;
f01049aa:	c7 42 1c 00 00 00 00 	movl   $0x0,0x1c(%edx)
f01049b1:	e9 ca fb ff ff       	jmp    f0104580 <syscall+0x52>
			ret = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
f01049b6:	ff 75 18             	pushl  0x18(%ebp)
f01049b9:	51                   	push   %ecx
f01049ba:	50                   	push   %eax
f01049bb:	ff 72 60             	pushl  0x60(%edx)
f01049be:	e8 59 c8 ff ff       	call   f010121c <page_insert>
			if (ret) return ret;
f01049c3:	83 c4 10             	add    $0x10,%esp
f01049c6:	85 c0                	test   %eax,%eax
f01049c8:	75 1f                	jne    f01049e9 <syscall+0x4bb>
			e->env_ipc_perm = perm;
f01049ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049cd:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01049d0:	89 48 78             	mov    %ecx,0x78(%eax)
f01049d3:	eb aa                	jmp    f010497f <syscall+0x451>
            		return -E_INVAL;
f01049d5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049da:	e9 a1 fb ff ff       	jmp    f0104580 <syscall+0x52>
            		return -E_INVAL;
f01049df:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049e4:	e9 97 fb ff ff       	jmp    f0104580 <syscall+0x52>
			if (ret) return ret;
f01049e9:	89 c3                	mov    %eax,%ebx
f01049eb:	e9 90 fb ff ff       	jmp    f0104580 <syscall+0x52>
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f01049f0:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
        		break;
f01049f5:	e9 86 fb ff ff       	jmp    f0104580 <syscall+0x52>
	if (dstva < (void*)UTOP) 
f01049fa:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104a01:	77 13                	ja     f0104a16 <syscall+0x4e8>
		if (dstva != ROUNDDOWN(dstva, PGSIZE)) 
f0104a03:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104a0a:	74 0a                	je     f0104a16 <syscall+0x4e8>
        		ret = sys_ipc_recv((void *)a1);
f0104a0c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	return ret;	
f0104a11:	e9 6a fb ff ff       	jmp    f0104580 <syscall+0x52>
	curenv->env_ipc_recving = 1;
f0104a16:	e8 20 12 00 00       	call   f0105c3b <cpunum>
f0104a1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a1e:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f0104a24:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104a28:	e8 0e 12 00 00       	call   f0105c3b <cpunum>
f0104a2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a30:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f0104a36:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva;
f0104a3d:	e8 f9 11 00 00       	call   f0105c3b <cpunum>
f0104a42:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a45:	8b 80 28 40 21 f0    	mov    -0xfdebfd8(%eax),%eax
f0104a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104a4e:	89 48 6c             	mov    %ecx,0x6c(%eax)
	sched_yield();
f0104a51:	e8 21 fa ff ff       	call   f0104477 <sched_yield>
    	if ((r = envid2env(envid, &e, 1)) < 0) {
f0104a56:	83 ec 04             	sub    $0x4,%esp
f0104a59:	6a 01                	push   $0x1
f0104a5b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a5e:	50                   	push   %eax
f0104a5f:	ff 75 0c             	pushl  0xc(%ebp)
f0104a62:	e8 d9 e5 ff ff       	call   f0103040 <envid2env>
f0104a67:	89 c3                	mov    %eax,%ebx
f0104a69:	83 c4 10             	add    $0x10,%esp
f0104a6c:	85 c0                	test   %eax,%eax
f0104a6e:	0f 88 0c fb ff ff    	js     f0104580 <syscall+0x52>
    	tf->tf_eflags = FL_IF;
f0104a74:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a77:	c7 40 38 00 02 00 00 	movl   $0x200,0x38(%eax)
    	tf->tf_cs = GD_UT | 3;
f0104a7e:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
    	e->env_tf = *tf;
f0104a84:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104a89:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a8c:	89 c6                	mov    %eax,%esi
f0104a8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    	return 0;
f0104a90:	bb 00 00 00 00       	mov    $0x0,%ebx
        		break;
f0104a95:	e9 e6 fa ff ff       	jmp    f0104580 <syscall+0x52>
			ret = -E_INVAL;
f0104a9a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a9f:	e9 dc fa ff ff       	jmp    f0104580 <syscall+0x52>

f0104aa4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104aa4:	55                   	push   %ebp
f0104aa5:	89 e5                	mov    %esp,%ebp
f0104aa7:	57                   	push   %edi
f0104aa8:	56                   	push   %esi
f0104aa9:	53                   	push   %ebx
f0104aaa:	83 ec 14             	sub    $0x14,%esp
f0104aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ab0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104ab3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104ab6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ab9:	8b 32                	mov    (%edx),%esi
f0104abb:	8b 01                	mov    (%ecx),%eax
f0104abd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ac0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104ac7:	eb 2f                	jmp    f0104af8 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104ac9:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104acc:	39 c6                	cmp    %eax,%esi
f0104ace:	7f 49                	jg     f0104b19 <stab_binsearch+0x75>
f0104ad0:	0f b6 0a             	movzbl (%edx),%ecx
f0104ad3:	83 ea 0c             	sub    $0xc,%edx
f0104ad6:	39 f9                	cmp    %edi,%ecx
f0104ad8:	75 ef                	jne    f0104ac9 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104ada:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104add:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ae0:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104ae4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104ae7:	73 35                	jae    f0104b1e <stab_binsearch+0x7a>
			*region_left = m;
f0104ae9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104aec:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0104aee:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0104af1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104af8:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104afb:	7f 4e                	jg     f0104b4b <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0104afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104b00:	01 f0                	add    %esi,%eax
f0104b02:	89 c3                	mov    %eax,%ebx
f0104b04:	c1 eb 1f             	shr    $0x1f,%ebx
f0104b07:	01 c3                	add    %eax,%ebx
f0104b09:	d1 fb                	sar    %ebx
f0104b0b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104b0e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104b11:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104b15:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104b17:	eb b3                	jmp    f0104acc <stab_binsearch+0x28>
			l = true_m + 1;
f0104b19:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0104b1c:	eb da                	jmp    f0104af8 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104b1e:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104b21:	76 14                	jbe    f0104b37 <stab_binsearch+0x93>
			*region_right = m - 1;
f0104b23:	83 e8 01             	sub    $0x1,%eax
f0104b26:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104b29:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104b2c:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0104b2e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b35:	eb c1                	jmp    f0104af8 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104b37:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b3a:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104b3c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104b40:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0104b42:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b49:	eb ad                	jmp    f0104af8 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104b4b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104b4f:	74 16                	je     f0104b67 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b51:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b54:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104b56:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b59:	8b 0e                	mov    (%esi),%ecx
f0104b5b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b5e:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104b61:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0104b65:	eb 12                	jmp    f0104b79 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0104b67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b6a:	8b 00                	mov    (%eax),%eax
f0104b6c:	83 e8 01             	sub    $0x1,%eax
f0104b6f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104b72:	89 07                	mov    %eax,(%edi)
f0104b74:	eb 16                	jmp    f0104b8c <stab_binsearch+0xe8>
		     l--)
f0104b76:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104b79:	39 c1                	cmp    %eax,%ecx
f0104b7b:	7d 0a                	jge    f0104b87 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0104b7d:	0f b6 1a             	movzbl (%edx),%ebx
f0104b80:	83 ea 0c             	sub    $0xc,%edx
f0104b83:	39 fb                	cmp    %edi,%ebx
f0104b85:	75 ef                	jne    f0104b76 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0104b87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b8a:	89 07                	mov    %eax,(%edi)
	}
}
f0104b8c:	83 c4 14             	add    $0x14,%esp
f0104b8f:	5b                   	pop    %ebx
f0104b90:	5e                   	pop    %esi
f0104b91:	5f                   	pop    %edi
f0104b92:	5d                   	pop    %ebp
f0104b93:	c3                   	ret    

f0104b94 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104b94:	55                   	push   %ebp
f0104b95:	89 e5                	mov    %esp,%ebp
f0104b97:	57                   	push   %edi
f0104b98:	56                   	push   %esi
f0104b99:	53                   	push   %ebx
f0104b9a:	83 ec 4c             	sub    $0x4c,%esp
f0104b9d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ba0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104ba3:	c7 03 c4 79 10 f0    	movl   $0xf01079c4,(%ebx)
	info->eip_line = 0;
f0104ba9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104bb0:	c7 43 08 c4 79 10 f0 	movl   $0xf01079c4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104bb7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104bbe:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104bc1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104bc8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104bce:	77 21                	ja     f0104bf1 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104bd0:	a1 00 00 20 00       	mov    0x200000,%eax
f0104bd5:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f0104bd8:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104bdd:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0104be3:	89 7d b4             	mov    %edi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104be6:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0104bec:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0104bef:	eb 1a                	jmp    f0104c0b <debuginfo_eip+0x77>
		stabstr_end = __STABSTR_END__;
f0104bf1:	c7 45 bc d7 6c 11 f0 	movl   $0xf0116cd7,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104bf8:	c7 45 b4 e5 34 11 f0 	movl   $0xf01134e5,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104bff:	b8 e4 34 11 f0       	mov    $0xf01134e4,%eax
		stabs = __STAB_BEGIN__;
f0104c04:	c7 45 b8 70 7f 10 f0 	movl   $0xf0107f70,-0x48(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104c0b:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104c0e:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0104c11:	0f 83 a3 01 00 00    	jae    f0104dba <debuginfo_eip+0x226>
f0104c17:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104c1b:	0f 85 a0 01 00 00    	jne    f0104dc1 <debuginfo_eip+0x22d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104c21:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104c28:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104c2b:	29 f8                	sub    %edi,%eax
f0104c2d:	c1 f8 02             	sar    $0x2,%eax
f0104c30:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104c36:	83 e8 01             	sub    $0x1,%eax
f0104c39:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104c3c:	56                   	push   %esi
f0104c3d:	6a 64                	push   $0x64
f0104c3f:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104c42:	89 c1                	mov    %eax,%ecx
f0104c44:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104c47:	89 f8                	mov    %edi,%eax
f0104c49:	e8 56 fe ff ff       	call   f0104aa4 <stab_binsearch>
	if (lfile == 0)
f0104c4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c51:	83 c4 08             	add    $0x8,%esp
f0104c54:	85 c0                	test   %eax,%eax
f0104c56:	0f 84 6c 01 00 00    	je     f0104dc8 <debuginfo_eip+0x234>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104c5c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104c5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c62:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104c65:	56                   	push   %esi
f0104c66:	6a 24                	push   $0x24
f0104c68:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104c6b:	89 c1                	mov    %eax,%ecx
f0104c6d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104c70:	89 f8                	mov    %edi,%eax
f0104c72:	e8 2d fe ff ff       	call   f0104aa4 <stab_binsearch>

	if (lfun <= rfun) {
f0104c77:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104c7a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104c7d:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0104c80:	83 c4 08             	add    $0x8,%esp
f0104c83:	39 c8                	cmp    %ecx,%eax
f0104c85:	7f 7b                	jg     f0104d02 <debuginfo_eip+0x16e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104c87:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c8a:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0104c8d:	8b 11                	mov    (%ecx),%edx
f0104c8f:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104c92:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f0104c95:	39 fa                	cmp    %edi,%edx
f0104c97:	73 06                	jae    f0104c9f <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104c99:	03 55 b4             	add    -0x4c(%ebp),%edx
f0104c9c:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104c9f:	8b 51 08             	mov    0x8(%ecx),%edx
f0104ca2:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104ca5:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104ca7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104caa:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104cad:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104cb0:	83 ec 08             	sub    $0x8,%esp
f0104cb3:	6a 3a                	push   $0x3a
f0104cb5:	ff 73 08             	pushl  0x8(%ebx)
f0104cb8:	e8 3d 09 00 00       	call   f01055fa <strfind>
f0104cbd:	2b 43 08             	sub    0x8(%ebx),%eax
f0104cc0:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104cc3:	83 c4 08             	add    $0x8,%esp
f0104cc6:	56                   	push   %esi
f0104cc7:	6a 44                	push   $0x44
f0104cc9:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104ccc:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104ccf:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0104cd2:	89 f0                	mov    %esi,%eax
f0104cd4:	e8 cb fd ff ff       	call   f0104aa4 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0104cd9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104cdc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cdf:	c1 e2 02             	shl    $0x2,%edx
f0104ce2:	0f b7 4c 16 06       	movzwl 0x6(%esi,%edx,1),%ecx
f0104ce7:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104cea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ced:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0104cf1:	83 c4 10             	add    $0x10,%esp
f0104cf4:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104cf8:	be 01 00 00 00       	mov    $0x1,%esi
f0104cfd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104d00:	eb 1c                	jmp    f0104d1e <debuginfo_eip+0x18a>
		info->eip_fn_addr = addr;
f0104d02:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104d05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d08:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104d0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d0e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104d11:	eb 9d                	jmp    f0104cb0 <debuginfo_eip+0x11c>
f0104d13:	83 e8 01             	sub    $0x1,%eax
f0104d16:	83 ea 0c             	sub    $0xc,%edx
f0104d19:	89 f3                	mov    %esi,%ebx
f0104d1b:	88 5d c4             	mov    %bl,-0x3c(%ebp)
f0104d1e:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0104d21:	39 c7                	cmp    %eax,%edi
f0104d23:	7f 24                	jg     f0104d49 <debuginfo_eip+0x1b5>
	       && stabs[lline].n_type != N_SOL
f0104d25:	0f b6 0a             	movzbl (%edx),%ecx
f0104d28:	80 f9 84             	cmp    $0x84,%cl
f0104d2b:	74 42                	je     f0104d6f <debuginfo_eip+0x1db>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104d2d:	80 f9 64             	cmp    $0x64,%cl
f0104d30:	75 e1                	jne    f0104d13 <debuginfo_eip+0x17f>
f0104d32:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0104d36:	74 db                	je     f0104d13 <debuginfo_eip+0x17f>
f0104d38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d3b:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d3f:	74 37                	je     f0104d78 <debuginfo_eip+0x1e4>
f0104d41:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104d44:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104d47:	eb 2f                	jmp    f0104d78 <debuginfo_eip+0x1e4>
f0104d49:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104d4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104d4f:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d52:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104d57:	39 f2                	cmp    %esi,%edx
f0104d59:	7d 79                	jge    f0104dd4 <debuginfo_eip+0x240>
		for (lline = lfun + 1;
f0104d5b:	83 c2 01             	add    $0x1,%edx
f0104d5e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104d61:	89 d0                	mov    %edx,%eax
f0104d63:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104d66:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104d69:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104d6d:	eb 32                	jmp    f0104da1 <debuginfo_eip+0x20d>
f0104d6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d72:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d76:	75 1d                	jne    f0104d95 <debuginfo_eip+0x201>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104d78:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104d7b:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0104d7e:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0104d81:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104d84:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104d87:	29 f8                	sub    %edi,%eax
f0104d89:	39 c2                	cmp    %eax,%edx
f0104d8b:	73 bf                	jae    f0104d4c <debuginfo_eip+0x1b8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104d8d:	89 f8                	mov    %edi,%eax
f0104d8f:	01 d0                	add    %edx,%eax
f0104d91:	89 03                	mov    %eax,(%ebx)
f0104d93:	eb b7                	jmp    f0104d4c <debuginfo_eip+0x1b8>
f0104d95:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104d98:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104d9b:	eb db                	jmp    f0104d78 <debuginfo_eip+0x1e4>
			info->eip_fn_narg++;
f0104d9d:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0104da1:	39 c6                	cmp    %eax,%esi
f0104da3:	7e 2a                	jle    f0104dcf <debuginfo_eip+0x23b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104da5:	0f b6 0a             	movzbl (%edx),%ecx
f0104da8:	83 c0 01             	add    $0x1,%eax
f0104dab:	83 c2 0c             	add    $0xc,%edx
f0104dae:	80 f9 a0             	cmp    $0xa0,%cl
f0104db1:	74 ea                	je     f0104d9d <debuginfo_eip+0x209>
	return 0;
f0104db3:	b8 00 00 00 00       	mov    $0x0,%eax
f0104db8:	eb 1a                	jmp    f0104dd4 <debuginfo_eip+0x240>
		return -1;
f0104dba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104dbf:	eb 13                	jmp    f0104dd4 <debuginfo_eip+0x240>
f0104dc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104dc6:	eb 0c                	jmp    f0104dd4 <debuginfo_eip+0x240>
		return -1;
f0104dc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104dcd:	eb 05                	jmp    f0104dd4 <debuginfo_eip+0x240>
	return 0;
f0104dcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104dd7:	5b                   	pop    %ebx
f0104dd8:	5e                   	pop    %esi
f0104dd9:	5f                   	pop    %edi
f0104dda:	5d                   	pop    %ebp
f0104ddb:	c3                   	ret    

f0104ddc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104ddc:	55                   	push   %ebp
f0104ddd:	89 e5                	mov    %esp,%ebp
f0104ddf:	57                   	push   %edi
f0104de0:	56                   	push   %esi
f0104de1:	53                   	push   %ebx
f0104de2:	83 ec 1c             	sub    $0x1c,%esp
f0104de5:	89 c7                	mov    %eax,%edi
f0104de7:	89 d6                	mov    %edx,%esi
f0104de9:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dec:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104def:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104df2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104df5:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104df8:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104dfd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104e00:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104e03:	39 d3                	cmp    %edx,%ebx
f0104e05:	72 05                	jb     f0104e0c <printnum+0x30>
f0104e07:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104e0a:	77 7a                	ja     f0104e86 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104e0c:	83 ec 0c             	sub    $0xc,%esp
f0104e0f:	ff 75 18             	pushl  0x18(%ebp)
f0104e12:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e15:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104e18:	53                   	push   %ebx
f0104e19:	ff 75 10             	pushl  0x10(%ebp)
f0104e1c:	83 ec 08             	sub    $0x8,%esp
f0104e1f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e22:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e25:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e28:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e2b:	e8 00 12 00 00       	call   f0106030 <__udivdi3>
f0104e30:	83 c4 18             	add    $0x18,%esp
f0104e33:	52                   	push   %edx
f0104e34:	50                   	push   %eax
f0104e35:	89 f2                	mov    %esi,%edx
f0104e37:	89 f8                	mov    %edi,%eax
f0104e39:	e8 9e ff ff ff       	call   f0104ddc <printnum>
f0104e3e:	83 c4 20             	add    $0x20,%esp
f0104e41:	eb 13                	jmp    f0104e56 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104e43:	83 ec 08             	sub    $0x8,%esp
f0104e46:	56                   	push   %esi
f0104e47:	ff 75 18             	pushl  0x18(%ebp)
f0104e4a:	ff d7                	call   *%edi
f0104e4c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0104e4f:	83 eb 01             	sub    $0x1,%ebx
f0104e52:	85 db                	test   %ebx,%ebx
f0104e54:	7f ed                	jg     f0104e43 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104e56:	83 ec 08             	sub    $0x8,%esp
f0104e59:	56                   	push   %esi
f0104e5a:	83 ec 04             	sub    $0x4,%esp
f0104e5d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e60:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e63:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e66:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e69:	e8 e2 12 00 00       	call   f0106150 <__umoddi3>
f0104e6e:	83 c4 14             	add    $0x14,%esp
f0104e71:	0f be 80 ce 79 10 f0 	movsbl -0xfef8632(%eax),%eax
f0104e78:	50                   	push   %eax
f0104e79:	ff d7                	call   *%edi
}
f0104e7b:	83 c4 10             	add    $0x10,%esp
f0104e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e81:	5b                   	pop    %ebx
f0104e82:	5e                   	pop    %esi
f0104e83:	5f                   	pop    %edi
f0104e84:	5d                   	pop    %ebp
f0104e85:	c3                   	ret    
f0104e86:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104e89:	eb c4                	jmp    f0104e4f <printnum+0x73>

f0104e8b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104e8b:	55                   	push   %ebp
f0104e8c:	89 e5                	mov    %esp,%ebp
f0104e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104e91:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104e95:	8b 10                	mov    (%eax),%edx
f0104e97:	3b 50 04             	cmp    0x4(%eax),%edx
f0104e9a:	73 0a                	jae    f0104ea6 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104e9c:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104e9f:	89 08                	mov    %ecx,(%eax)
f0104ea1:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ea4:	88 02                	mov    %al,(%edx)
}
f0104ea6:	5d                   	pop    %ebp
f0104ea7:	c3                   	ret    

f0104ea8 <printfmt>:
{
f0104ea8:	55                   	push   %ebp
f0104ea9:	89 e5                	mov    %esp,%ebp
f0104eab:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104eae:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104eb1:	50                   	push   %eax
f0104eb2:	ff 75 10             	pushl  0x10(%ebp)
f0104eb5:	ff 75 0c             	pushl  0xc(%ebp)
f0104eb8:	ff 75 08             	pushl  0x8(%ebp)
f0104ebb:	e8 05 00 00 00       	call   f0104ec5 <vprintfmt>
}
f0104ec0:	83 c4 10             	add    $0x10,%esp
f0104ec3:	c9                   	leave  
f0104ec4:	c3                   	ret    

f0104ec5 <vprintfmt>:
{
f0104ec5:	55                   	push   %ebp
f0104ec6:	89 e5                	mov    %esp,%ebp
f0104ec8:	57                   	push   %edi
f0104ec9:	56                   	push   %esi
f0104eca:	53                   	push   %ebx
f0104ecb:	83 ec 2c             	sub    $0x2c,%esp
f0104ece:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ed1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ed4:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104ed7:	e9 c1 03 00 00       	jmp    f010529d <vprintfmt+0x3d8>
		padc = ' ';
f0104edc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0104ee0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0104ee7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0104eee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104ef5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104efa:	8d 47 01             	lea    0x1(%edi),%eax
f0104efd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104f00:	0f b6 17             	movzbl (%edi),%edx
f0104f03:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104f06:	3c 55                	cmp    $0x55,%al
f0104f08:	0f 87 12 04 00 00    	ja     f0105320 <vprintfmt+0x45b>
f0104f0e:	0f b6 c0             	movzbl %al,%eax
f0104f11:	ff 24 85 20 7b 10 f0 	jmp    *-0xfef84e0(,%eax,4)
f0104f18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104f1b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104f1f:	eb d9                	jmp    f0104efa <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0104f21:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104f24:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104f28:	eb d0                	jmp    f0104efa <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0104f2a:	0f b6 d2             	movzbl %dl,%edx
f0104f2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0104f30:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f35:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0104f38:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104f3b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104f3f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104f42:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104f45:	83 f9 09             	cmp    $0x9,%ecx
f0104f48:	77 55                	ja     f0104f9f <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
f0104f4a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104f4d:	eb e9                	jmp    f0104f38 <vprintfmt+0x73>
			precision = va_arg(ap, int);
f0104f4f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f52:	8b 00                	mov    (%eax),%eax
f0104f54:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104f57:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f5a:	8d 40 04             	lea    0x4(%eax),%eax
f0104f5d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104f60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104f63:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104f67:	79 91                	jns    f0104efa <vprintfmt+0x35>
				width = precision, precision = -1;
f0104f69:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104f6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104f6f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104f76:	eb 82                	jmp    f0104efa <vprintfmt+0x35>
f0104f78:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f7b:	85 c0                	test   %eax,%eax
f0104f7d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f82:	0f 49 d0             	cmovns %eax,%edx
f0104f85:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104f88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f8b:	e9 6a ff ff ff       	jmp    f0104efa <vprintfmt+0x35>
f0104f90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104f93:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104f9a:	e9 5b ff ff ff       	jmp    f0104efa <vprintfmt+0x35>
f0104f9f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104fa2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104fa5:	eb bc                	jmp    f0104f63 <vprintfmt+0x9e>
			lflag++;
f0104fa7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104faa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104fad:	e9 48 ff ff ff       	jmp    f0104efa <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0104fb2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fb5:	8d 78 04             	lea    0x4(%eax),%edi
f0104fb8:	83 ec 08             	sub    $0x8,%esp
f0104fbb:	53                   	push   %ebx
f0104fbc:	ff 30                	pushl  (%eax)
f0104fbe:	ff d6                	call   *%esi
			break;
f0104fc0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104fc3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104fc6:	e9 cf 02 00 00       	jmp    f010529a <vprintfmt+0x3d5>
			err = va_arg(ap, int);
f0104fcb:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fce:	8d 78 04             	lea    0x4(%eax),%edi
f0104fd1:	8b 00                	mov    (%eax),%eax
f0104fd3:	99                   	cltd   
f0104fd4:	31 d0                	xor    %edx,%eax
f0104fd6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104fd8:	83 f8 0f             	cmp    $0xf,%eax
f0104fdb:	7f 23                	jg     f0105000 <vprintfmt+0x13b>
f0104fdd:	8b 14 85 80 7c 10 f0 	mov    -0xfef8380(,%eax,4),%edx
f0104fe4:	85 d2                	test   %edx,%edx
f0104fe6:	74 18                	je     f0105000 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
f0104fe8:	52                   	push   %edx
f0104fe9:	68 59 71 10 f0       	push   $0xf0107159
f0104fee:	53                   	push   %ebx
f0104fef:	56                   	push   %esi
f0104ff0:	e8 b3 fe ff ff       	call   f0104ea8 <printfmt>
f0104ff5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104ff8:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104ffb:	e9 9a 02 00 00       	jmp    f010529a <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
f0105000:	50                   	push   %eax
f0105001:	68 e6 79 10 f0       	push   $0xf01079e6
f0105006:	53                   	push   %ebx
f0105007:	56                   	push   %esi
f0105008:	e8 9b fe ff ff       	call   f0104ea8 <printfmt>
f010500d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105010:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105013:	e9 82 02 00 00       	jmp    f010529a <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
f0105018:	8b 45 14             	mov    0x14(%ebp),%eax
f010501b:	83 c0 04             	add    $0x4,%eax
f010501e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105021:	8b 45 14             	mov    0x14(%ebp),%eax
f0105024:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105026:	85 ff                	test   %edi,%edi
f0105028:	b8 df 79 10 f0       	mov    $0xf01079df,%eax
f010502d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105030:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105034:	0f 8e bd 00 00 00    	jle    f01050f7 <vprintfmt+0x232>
f010503a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010503e:	75 0e                	jne    f010504e <vprintfmt+0x189>
f0105040:	89 75 08             	mov    %esi,0x8(%ebp)
f0105043:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105046:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105049:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010504c:	eb 6d                	jmp    f01050bb <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
f010504e:	83 ec 08             	sub    $0x8,%esp
f0105051:	ff 75 d0             	pushl  -0x30(%ebp)
f0105054:	57                   	push   %edi
f0105055:	e8 5c 04 00 00       	call   f01054b6 <strnlen>
f010505a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010505d:	29 c1                	sub    %eax,%ecx
f010505f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0105062:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105065:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105069:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010506c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010506f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105071:	eb 0f                	jmp    f0105082 <vprintfmt+0x1bd>
					putch(padc, putdat);
f0105073:	83 ec 08             	sub    $0x8,%esp
f0105076:	53                   	push   %ebx
f0105077:	ff 75 e0             	pushl  -0x20(%ebp)
f010507a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010507c:	83 ef 01             	sub    $0x1,%edi
f010507f:	83 c4 10             	add    $0x10,%esp
f0105082:	85 ff                	test   %edi,%edi
f0105084:	7f ed                	jg     f0105073 <vprintfmt+0x1ae>
f0105086:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105089:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010508c:	85 c9                	test   %ecx,%ecx
f010508e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105093:	0f 49 c1             	cmovns %ecx,%eax
f0105096:	29 c1                	sub    %eax,%ecx
f0105098:	89 75 08             	mov    %esi,0x8(%ebp)
f010509b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010509e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050a1:	89 cb                	mov    %ecx,%ebx
f01050a3:	eb 16                	jmp    f01050bb <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
f01050a5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01050a9:	75 31                	jne    f01050dc <vprintfmt+0x217>
					putch(ch, putdat);
f01050ab:	83 ec 08             	sub    $0x8,%esp
f01050ae:	ff 75 0c             	pushl  0xc(%ebp)
f01050b1:	50                   	push   %eax
f01050b2:	ff 55 08             	call   *0x8(%ebp)
f01050b5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01050b8:	83 eb 01             	sub    $0x1,%ebx
f01050bb:	83 c7 01             	add    $0x1,%edi
f01050be:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01050c2:	0f be c2             	movsbl %dl,%eax
f01050c5:	85 c0                	test   %eax,%eax
f01050c7:	74 59                	je     f0105122 <vprintfmt+0x25d>
f01050c9:	85 f6                	test   %esi,%esi
f01050cb:	78 d8                	js     f01050a5 <vprintfmt+0x1e0>
f01050cd:	83 ee 01             	sub    $0x1,%esi
f01050d0:	79 d3                	jns    f01050a5 <vprintfmt+0x1e0>
f01050d2:	89 df                	mov    %ebx,%edi
f01050d4:	8b 75 08             	mov    0x8(%ebp),%esi
f01050d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01050da:	eb 37                	jmp    f0105113 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
f01050dc:	0f be d2             	movsbl %dl,%edx
f01050df:	83 ea 20             	sub    $0x20,%edx
f01050e2:	83 fa 5e             	cmp    $0x5e,%edx
f01050e5:	76 c4                	jbe    f01050ab <vprintfmt+0x1e6>
					putch('?', putdat);
f01050e7:	83 ec 08             	sub    $0x8,%esp
f01050ea:	ff 75 0c             	pushl  0xc(%ebp)
f01050ed:	6a 3f                	push   $0x3f
f01050ef:	ff 55 08             	call   *0x8(%ebp)
f01050f2:	83 c4 10             	add    $0x10,%esp
f01050f5:	eb c1                	jmp    f01050b8 <vprintfmt+0x1f3>
f01050f7:	89 75 08             	mov    %esi,0x8(%ebp)
f01050fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01050fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105100:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105103:	eb b6                	jmp    f01050bb <vprintfmt+0x1f6>
				putch(' ', putdat);
f0105105:	83 ec 08             	sub    $0x8,%esp
f0105108:	53                   	push   %ebx
f0105109:	6a 20                	push   $0x20
f010510b:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010510d:	83 ef 01             	sub    $0x1,%edi
f0105110:	83 c4 10             	add    $0x10,%esp
f0105113:	85 ff                	test   %edi,%edi
f0105115:	7f ee                	jg     f0105105 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
f0105117:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010511a:	89 45 14             	mov    %eax,0x14(%ebp)
f010511d:	e9 78 01 00 00       	jmp    f010529a <vprintfmt+0x3d5>
f0105122:	89 df                	mov    %ebx,%edi
f0105124:	8b 75 08             	mov    0x8(%ebp),%esi
f0105127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010512a:	eb e7                	jmp    f0105113 <vprintfmt+0x24e>
	if (lflag >= 2)
f010512c:	83 f9 01             	cmp    $0x1,%ecx
f010512f:	7e 3f                	jle    f0105170 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
f0105131:	8b 45 14             	mov    0x14(%ebp),%eax
f0105134:	8b 50 04             	mov    0x4(%eax),%edx
f0105137:	8b 00                	mov    (%eax),%eax
f0105139:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010513c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010513f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105142:	8d 40 08             	lea    0x8(%eax),%eax
f0105145:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105148:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010514c:	79 5c                	jns    f01051aa <vprintfmt+0x2e5>
				putch('-', putdat);
f010514e:	83 ec 08             	sub    $0x8,%esp
f0105151:	53                   	push   %ebx
f0105152:	6a 2d                	push   $0x2d
f0105154:	ff d6                	call   *%esi
				num = -(long long) num;
f0105156:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105159:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010515c:	f7 da                	neg    %edx
f010515e:	83 d1 00             	adc    $0x0,%ecx
f0105161:	f7 d9                	neg    %ecx
f0105163:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105166:	b8 0a 00 00 00       	mov    $0xa,%eax
f010516b:	e9 10 01 00 00       	jmp    f0105280 <vprintfmt+0x3bb>
	else if (lflag)
f0105170:	85 c9                	test   %ecx,%ecx
f0105172:	75 1b                	jne    f010518f <vprintfmt+0x2ca>
		return va_arg(*ap, int);
f0105174:	8b 45 14             	mov    0x14(%ebp),%eax
f0105177:	8b 00                	mov    (%eax),%eax
f0105179:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010517c:	89 c1                	mov    %eax,%ecx
f010517e:	c1 f9 1f             	sar    $0x1f,%ecx
f0105181:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105184:	8b 45 14             	mov    0x14(%ebp),%eax
f0105187:	8d 40 04             	lea    0x4(%eax),%eax
f010518a:	89 45 14             	mov    %eax,0x14(%ebp)
f010518d:	eb b9                	jmp    f0105148 <vprintfmt+0x283>
		return va_arg(*ap, long);
f010518f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105192:	8b 00                	mov    (%eax),%eax
f0105194:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105197:	89 c1                	mov    %eax,%ecx
f0105199:	c1 f9 1f             	sar    $0x1f,%ecx
f010519c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010519f:	8b 45 14             	mov    0x14(%ebp),%eax
f01051a2:	8d 40 04             	lea    0x4(%eax),%eax
f01051a5:	89 45 14             	mov    %eax,0x14(%ebp)
f01051a8:	eb 9e                	jmp    f0105148 <vprintfmt+0x283>
			num = getint(&ap, lflag);
f01051aa:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01051ad:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01051b0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01051b5:	e9 c6 00 00 00       	jmp    f0105280 <vprintfmt+0x3bb>
	if (lflag >= 2)
f01051ba:	83 f9 01             	cmp    $0x1,%ecx
f01051bd:	7e 18                	jle    f01051d7 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
f01051bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01051c2:	8b 10                	mov    (%eax),%edx
f01051c4:	8b 48 04             	mov    0x4(%eax),%ecx
f01051c7:	8d 40 08             	lea    0x8(%eax),%eax
f01051ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01051cd:	b8 0a 00 00 00       	mov    $0xa,%eax
f01051d2:	e9 a9 00 00 00       	jmp    f0105280 <vprintfmt+0x3bb>
	else if (lflag)
f01051d7:	85 c9                	test   %ecx,%ecx
f01051d9:	75 1a                	jne    f01051f5 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
f01051db:	8b 45 14             	mov    0x14(%ebp),%eax
f01051de:	8b 10                	mov    (%eax),%edx
f01051e0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01051e5:	8d 40 04             	lea    0x4(%eax),%eax
f01051e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01051eb:	b8 0a 00 00 00       	mov    $0xa,%eax
f01051f0:	e9 8b 00 00 00       	jmp    f0105280 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f01051f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01051f8:	8b 10                	mov    (%eax),%edx
f01051fa:	b9 00 00 00 00       	mov    $0x0,%ecx
f01051ff:	8d 40 04             	lea    0x4(%eax),%eax
f0105202:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105205:	b8 0a 00 00 00       	mov    $0xa,%eax
f010520a:	eb 74                	jmp    f0105280 <vprintfmt+0x3bb>
	if (lflag >= 2)
f010520c:	83 f9 01             	cmp    $0x1,%ecx
f010520f:	7e 15                	jle    f0105226 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
f0105211:	8b 45 14             	mov    0x14(%ebp),%eax
f0105214:	8b 10                	mov    (%eax),%edx
f0105216:	8b 48 04             	mov    0x4(%eax),%ecx
f0105219:	8d 40 08             	lea    0x8(%eax),%eax
f010521c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f010521f:	b8 08 00 00 00       	mov    $0x8,%eax
f0105224:	eb 5a                	jmp    f0105280 <vprintfmt+0x3bb>
	else if (lflag)
f0105226:	85 c9                	test   %ecx,%ecx
f0105228:	75 17                	jne    f0105241 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
f010522a:	8b 45 14             	mov    0x14(%ebp),%eax
f010522d:	8b 10                	mov    (%eax),%edx
f010522f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105234:	8d 40 04             	lea    0x4(%eax),%eax
f0105237:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f010523a:	b8 08 00 00 00       	mov    $0x8,%eax
f010523f:	eb 3f                	jmp    f0105280 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f0105241:	8b 45 14             	mov    0x14(%ebp),%eax
f0105244:	8b 10                	mov    (%eax),%edx
f0105246:	b9 00 00 00 00       	mov    $0x0,%ecx
f010524b:	8d 40 04             	lea    0x4(%eax),%eax
f010524e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0105251:	b8 08 00 00 00       	mov    $0x8,%eax
f0105256:	eb 28                	jmp    f0105280 <vprintfmt+0x3bb>
			putch('0', putdat);
f0105258:	83 ec 08             	sub    $0x8,%esp
f010525b:	53                   	push   %ebx
f010525c:	6a 30                	push   $0x30
f010525e:	ff d6                	call   *%esi
			putch('x', putdat);
f0105260:	83 c4 08             	add    $0x8,%esp
f0105263:	53                   	push   %ebx
f0105264:	6a 78                	push   $0x78
f0105266:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105268:	8b 45 14             	mov    0x14(%ebp),%eax
f010526b:	8b 10                	mov    (%eax),%edx
f010526d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105272:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105275:	8d 40 04             	lea    0x4(%eax),%eax
f0105278:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010527b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105280:	83 ec 0c             	sub    $0xc,%esp
f0105283:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105287:	57                   	push   %edi
f0105288:	ff 75 e0             	pushl  -0x20(%ebp)
f010528b:	50                   	push   %eax
f010528c:	51                   	push   %ecx
f010528d:	52                   	push   %edx
f010528e:	89 da                	mov    %ebx,%edx
f0105290:	89 f0                	mov    %esi,%eax
f0105292:	e8 45 fb ff ff       	call   f0104ddc <printnum>
			break;
f0105297:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010529a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010529d:	83 c7 01             	add    $0x1,%edi
f01052a0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01052a4:	83 f8 25             	cmp    $0x25,%eax
f01052a7:	0f 84 2f fc ff ff    	je     f0104edc <vprintfmt+0x17>
			if (ch == '\0')
f01052ad:	85 c0                	test   %eax,%eax
f01052af:	0f 84 8b 00 00 00    	je     f0105340 <vprintfmt+0x47b>
			putch(ch, putdat);
f01052b5:	83 ec 08             	sub    $0x8,%esp
f01052b8:	53                   	push   %ebx
f01052b9:	50                   	push   %eax
f01052ba:	ff d6                	call   *%esi
f01052bc:	83 c4 10             	add    $0x10,%esp
f01052bf:	eb dc                	jmp    f010529d <vprintfmt+0x3d8>
	if (lflag >= 2)
f01052c1:	83 f9 01             	cmp    $0x1,%ecx
f01052c4:	7e 15                	jle    f01052db <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
f01052c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01052c9:	8b 10                	mov    (%eax),%edx
f01052cb:	8b 48 04             	mov    0x4(%eax),%ecx
f01052ce:	8d 40 08             	lea    0x8(%eax),%eax
f01052d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01052d4:	b8 10 00 00 00       	mov    $0x10,%eax
f01052d9:	eb a5                	jmp    f0105280 <vprintfmt+0x3bb>
	else if (lflag)
f01052db:	85 c9                	test   %ecx,%ecx
f01052dd:	75 17                	jne    f01052f6 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
f01052df:	8b 45 14             	mov    0x14(%ebp),%eax
f01052e2:	8b 10                	mov    (%eax),%edx
f01052e4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01052e9:	8d 40 04             	lea    0x4(%eax),%eax
f01052ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01052ef:	b8 10 00 00 00       	mov    $0x10,%eax
f01052f4:	eb 8a                	jmp    f0105280 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f01052f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01052f9:	8b 10                	mov    (%eax),%edx
f01052fb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105300:	8d 40 04             	lea    0x4(%eax),%eax
f0105303:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105306:	b8 10 00 00 00       	mov    $0x10,%eax
f010530b:	e9 70 ff ff ff       	jmp    f0105280 <vprintfmt+0x3bb>
			putch(ch, putdat);
f0105310:	83 ec 08             	sub    $0x8,%esp
f0105313:	53                   	push   %ebx
f0105314:	6a 25                	push   $0x25
f0105316:	ff d6                	call   *%esi
			break;
f0105318:	83 c4 10             	add    $0x10,%esp
f010531b:	e9 7a ff ff ff       	jmp    f010529a <vprintfmt+0x3d5>
			putch('%', putdat);
f0105320:	83 ec 08             	sub    $0x8,%esp
f0105323:	53                   	push   %ebx
f0105324:	6a 25                	push   $0x25
f0105326:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105328:	83 c4 10             	add    $0x10,%esp
f010532b:	89 f8                	mov    %edi,%eax
f010532d:	eb 03                	jmp    f0105332 <vprintfmt+0x46d>
f010532f:	83 e8 01             	sub    $0x1,%eax
f0105332:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105336:	75 f7                	jne    f010532f <vprintfmt+0x46a>
f0105338:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010533b:	e9 5a ff ff ff       	jmp    f010529a <vprintfmt+0x3d5>
}
f0105340:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105343:	5b                   	pop    %ebx
f0105344:	5e                   	pop    %esi
f0105345:	5f                   	pop    %edi
f0105346:	5d                   	pop    %ebp
f0105347:	c3                   	ret    

f0105348 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105348:	55                   	push   %ebp
f0105349:	89 e5                	mov    %esp,%ebp
f010534b:	83 ec 18             	sub    $0x18,%esp
f010534e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105351:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105354:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105357:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010535b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010535e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105365:	85 c0                	test   %eax,%eax
f0105367:	74 26                	je     f010538f <vsnprintf+0x47>
f0105369:	85 d2                	test   %edx,%edx
f010536b:	7e 22                	jle    f010538f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010536d:	ff 75 14             	pushl  0x14(%ebp)
f0105370:	ff 75 10             	pushl  0x10(%ebp)
f0105373:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105376:	50                   	push   %eax
f0105377:	68 8b 4e 10 f0       	push   $0xf0104e8b
f010537c:	e8 44 fb ff ff       	call   f0104ec5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105381:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105384:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105387:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010538a:	83 c4 10             	add    $0x10,%esp
}
f010538d:	c9                   	leave  
f010538e:	c3                   	ret    
		return -E_INVAL;
f010538f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105394:	eb f7                	jmp    f010538d <vsnprintf+0x45>

f0105396 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105396:	55                   	push   %ebp
f0105397:	89 e5                	mov    %esp,%ebp
f0105399:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010539c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010539f:	50                   	push   %eax
f01053a0:	ff 75 10             	pushl  0x10(%ebp)
f01053a3:	ff 75 0c             	pushl  0xc(%ebp)
f01053a6:	ff 75 08             	pushl  0x8(%ebp)
f01053a9:	e8 9a ff ff ff       	call   f0105348 <vsnprintf>
	va_end(ap);

	return rc;
}
f01053ae:	c9                   	leave  
f01053af:	c3                   	ret    

f01053b0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01053b0:	55                   	push   %ebp
f01053b1:	89 e5                	mov    %esp,%ebp
f01053b3:	57                   	push   %edi
f01053b4:	56                   	push   %esi
f01053b5:	53                   	push   %ebx
f01053b6:	83 ec 0c             	sub    $0xc,%esp
f01053b9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f01053bc:	85 c0                	test   %eax,%eax
f01053be:	74 11                	je     f01053d1 <readline+0x21>
		cprintf("%s", prompt);
f01053c0:	83 ec 08             	sub    $0x8,%esp
f01053c3:	50                   	push   %eax
f01053c4:	68 59 71 10 f0       	push   $0xf0107159
f01053c9:	e8 e1 e4 ff ff       	call   f01038af <cprintf>
f01053ce:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f01053d1:	83 ec 0c             	sub    $0xc,%esp
f01053d4:	6a 00                	push   $0x0
f01053d6:	e8 e8 b3 ff ff       	call   f01007c3 <iscons>
f01053db:	89 c7                	mov    %eax,%edi
f01053dd:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01053e0:	be 00 00 00 00       	mov    $0x0,%esi
f01053e5:	eb 4b                	jmp    f0105432 <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01053e7:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f01053ec:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01053ef:	75 08                	jne    f01053f9 <readline+0x49>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01053f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053f4:	5b                   	pop    %ebx
f01053f5:	5e                   	pop    %esi
f01053f6:	5f                   	pop    %edi
f01053f7:	5d                   	pop    %ebp
f01053f8:	c3                   	ret    
				cprintf("read error: %e\n", c);
f01053f9:	83 ec 08             	sub    $0x8,%esp
f01053fc:	53                   	push   %ebx
f01053fd:	68 df 7c 10 f0       	push   $0xf0107cdf
f0105402:	e8 a8 e4 ff ff       	call   f01038af <cprintf>
f0105407:	83 c4 10             	add    $0x10,%esp
			return NULL;
f010540a:	b8 00 00 00 00       	mov    $0x0,%eax
f010540f:	eb e0                	jmp    f01053f1 <readline+0x41>
			if (echoing)
f0105411:	85 ff                	test   %edi,%edi
f0105413:	75 05                	jne    f010541a <readline+0x6a>
			i--;
f0105415:	83 ee 01             	sub    $0x1,%esi
f0105418:	eb 18                	jmp    f0105432 <readline+0x82>
				cputchar('\b');
f010541a:	83 ec 0c             	sub    $0xc,%esp
f010541d:	6a 08                	push   $0x8
f010541f:	e8 7e b3 ff ff       	call   f01007a2 <cputchar>
f0105424:	83 c4 10             	add    $0x10,%esp
f0105427:	eb ec                	jmp    f0105415 <readline+0x65>
			buf[i++] = c;
f0105429:	88 9e 80 3a 21 f0    	mov    %bl,-0xfdec580(%esi)
f010542f:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105432:	e8 7b b3 ff ff       	call   f01007b2 <getchar>
f0105437:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105439:	85 c0                	test   %eax,%eax
f010543b:	78 aa                	js     f01053e7 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010543d:	83 f8 08             	cmp    $0x8,%eax
f0105440:	0f 94 c2             	sete   %dl
f0105443:	83 f8 7f             	cmp    $0x7f,%eax
f0105446:	0f 94 c0             	sete   %al
f0105449:	08 c2                	or     %al,%dl
f010544b:	74 04                	je     f0105451 <readline+0xa1>
f010544d:	85 f6                	test   %esi,%esi
f010544f:	7f c0                	jg     f0105411 <readline+0x61>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105451:	83 fb 1f             	cmp    $0x1f,%ebx
f0105454:	7e 1a                	jle    f0105470 <readline+0xc0>
f0105456:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010545c:	7f 12                	jg     f0105470 <readline+0xc0>
			if (echoing)
f010545e:	85 ff                	test   %edi,%edi
f0105460:	74 c7                	je     f0105429 <readline+0x79>
				cputchar(c);
f0105462:	83 ec 0c             	sub    $0xc,%esp
f0105465:	53                   	push   %ebx
f0105466:	e8 37 b3 ff ff       	call   f01007a2 <cputchar>
f010546b:	83 c4 10             	add    $0x10,%esp
f010546e:	eb b9                	jmp    f0105429 <readline+0x79>
		} else if (c == '\n' || c == '\r') {
f0105470:	83 fb 0a             	cmp    $0xa,%ebx
f0105473:	74 05                	je     f010547a <readline+0xca>
f0105475:	83 fb 0d             	cmp    $0xd,%ebx
f0105478:	75 b8                	jne    f0105432 <readline+0x82>
			if (echoing)
f010547a:	85 ff                	test   %edi,%edi
f010547c:	75 11                	jne    f010548f <readline+0xdf>
			buf[i] = 0;
f010547e:	c6 86 80 3a 21 f0 00 	movb   $0x0,-0xfdec580(%esi)
			return buf;
f0105485:	b8 80 3a 21 f0       	mov    $0xf0213a80,%eax
f010548a:	e9 62 ff ff ff       	jmp    f01053f1 <readline+0x41>
				cputchar('\n');
f010548f:	83 ec 0c             	sub    $0xc,%esp
f0105492:	6a 0a                	push   $0xa
f0105494:	e8 09 b3 ff ff       	call   f01007a2 <cputchar>
f0105499:	83 c4 10             	add    $0x10,%esp
f010549c:	eb e0                	jmp    f010547e <readline+0xce>

f010549e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010549e:	55                   	push   %ebp
f010549f:	89 e5                	mov    %esp,%ebp
f01054a1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01054a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01054a9:	eb 03                	jmp    f01054ae <strlen+0x10>
		n++;
f01054ab:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01054ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01054b2:	75 f7                	jne    f01054ab <strlen+0xd>
	return n;
}
f01054b4:	5d                   	pop    %ebp
f01054b5:	c3                   	ret    

f01054b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01054b6:	55                   	push   %ebp
f01054b7:	89 e5                	mov    %esp,%ebp
f01054b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01054bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01054bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01054c4:	eb 03                	jmp    f01054c9 <strnlen+0x13>
		n++;
f01054c6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01054c9:	39 d0                	cmp    %edx,%eax
f01054cb:	74 06                	je     f01054d3 <strnlen+0x1d>
f01054cd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01054d1:	75 f3                	jne    f01054c6 <strnlen+0x10>
	return n;
}
f01054d3:	5d                   	pop    %ebp
f01054d4:	c3                   	ret    

f01054d5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01054d5:	55                   	push   %ebp
f01054d6:	89 e5                	mov    %esp,%ebp
f01054d8:	53                   	push   %ebx
f01054d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01054dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01054df:	89 c2                	mov    %eax,%edx
f01054e1:	83 c1 01             	add    $0x1,%ecx
f01054e4:	83 c2 01             	add    $0x1,%edx
f01054e7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01054eb:	88 5a ff             	mov    %bl,-0x1(%edx)
f01054ee:	84 db                	test   %bl,%bl
f01054f0:	75 ef                	jne    f01054e1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01054f2:	5b                   	pop    %ebx
f01054f3:	5d                   	pop    %ebp
f01054f4:	c3                   	ret    

f01054f5 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01054f5:	55                   	push   %ebp
f01054f6:	89 e5                	mov    %esp,%ebp
f01054f8:	53                   	push   %ebx
f01054f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01054fc:	53                   	push   %ebx
f01054fd:	e8 9c ff ff ff       	call   f010549e <strlen>
f0105502:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105505:	ff 75 0c             	pushl  0xc(%ebp)
f0105508:	01 d8                	add    %ebx,%eax
f010550a:	50                   	push   %eax
f010550b:	e8 c5 ff ff ff       	call   f01054d5 <strcpy>
	return dst;
}
f0105510:	89 d8                	mov    %ebx,%eax
f0105512:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105515:	c9                   	leave  
f0105516:	c3                   	ret    

f0105517 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105517:	55                   	push   %ebp
f0105518:	89 e5                	mov    %esp,%ebp
f010551a:	56                   	push   %esi
f010551b:	53                   	push   %ebx
f010551c:	8b 75 08             	mov    0x8(%ebp),%esi
f010551f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105522:	89 f3                	mov    %esi,%ebx
f0105524:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105527:	89 f2                	mov    %esi,%edx
f0105529:	eb 0f                	jmp    f010553a <strncpy+0x23>
		*dst++ = *src;
f010552b:	83 c2 01             	add    $0x1,%edx
f010552e:	0f b6 01             	movzbl (%ecx),%eax
f0105531:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105534:	80 39 01             	cmpb   $0x1,(%ecx)
f0105537:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f010553a:	39 da                	cmp    %ebx,%edx
f010553c:	75 ed                	jne    f010552b <strncpy+0x14>
	}
	return ret;
}
f010553e:	89 f0                	mov    %esi,%eax
f0105540:	5b                   	pop    %ebx
f0105541:	5e                   	pop    %esi
f0105542:	5d                   	pop    %ebp
f0105543:	c3                   	ret    

f0105544 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105544:	55                   	push   %ebp
f0105545:	89 e5                	mov    %esp,%ebp
f0105547:	56                   	push   %esi
f0105548:	53                   	push   %ebx
f0105549:	8b 75 08             	mov    0x8(%ebp),%esi
f010554c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010554f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105552:	89 f0                	mov    %esi,%eax
f0105554:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105558:	85 c9                	test   %ecx,%ecx
f010555a:	75 0b                	jne    f0105567 <strlcpy+0x23>
f010555c:	eb 17                	jmp    f0105575 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010555e:	83 c2 01             	add    $0x1,%edx
f0105561:	83 c0 01             	add    $0x1,%eax
f0105564:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105567:	39 d8                	cmp    %ebx,%eax
f0105569:	74 07                	je     f0105572 <strlcpy+0x2e>
f010556b:	0f b6 0a             	movzbl (%edx),%ecx
f010556e:	84 c9                	test   %cl,%cl
f0105570:	75 ec                	jne    f010555e <strlcpy+0x1a>
		*dst = '\0';
f0105572:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105575:	29 f0                	sub    %esi,%eax
}
f0105577:	5b                   	pop    %ebx
f0105578:	5e                   	pop    %esi
f0105579:	5d                   	pop    %ebp
f010557a:	c3                   	ret    

f010557b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010557b:	55                   	push   %ebp
f010557c:	89 e5                	mov    %esp,%ebp
f010557e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105581:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105584:	eb 06                	jmp    f010558c <strcmp+0x11>
		p++, q++;
f0105586:	83 c1 01             	add    $0x1,%ecx
f0105589:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010558c:	0f b6 01             	movzbl (%ecx),%eax
f010558f:	84 c0                	test   %al,%al
f0105591:	74 04                	je     f0105597 <strcmp+0x1c>
f0105593:	3a 02                	cmp    (%edx),%al
f0105595:	74 ef                	je     f0105586 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105597:	0f b6 c0             	movzbl %al,%eax
f010559a:	0f b6 12             	movzbl (%edx),%edx
f010559d:	29 d0                	sub    %edx,%eax
}
f010559f:	5d                   	pop    %ebp
f01055a0:	c3                   	ret    

f01055a1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01055a1:	55                   	push   %ebp
f01055a2:	89 e5                	mov    %esp,%ebp
f01055a4:	53                   	push   %ebx
f01055a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01055a8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01055ab:	89 c3                	mov    %eax,%ebx
f01055ad:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01055b0:	eb 06                	jmp    f01055b8 <strncmp+0x17>
		n--, p++, q++;
f01055b2:	83 c0 01             	add    $0x1,%eax
f01055b5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01055b8:	39 d8                	cmp    %ebx,%eax
f01055ba:	74 16                	je     f01055d2 <strncmp+0x31>
f01055bc:	0f b6 08             	movzbl (%eax),%ecx
f01055bf:	84 c9                	test   %cl,%cl
f01055c1:	74 04                	je     f01055c7 <strncmp+0x26>
f01055c3:	3a 0a                	cmp    (%edx),%cl
f01055c5:	74 eb                	je     f01055b2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01055c7:	0f b6 00             	movzbl (%eax),%eax
f01055ca:	0f b6 12             	movzbl (%edx),%edx
f01055cd:	29 d0                	sub    %edx,%eax
}
f01055cf:	5b                   	pop    %ebx
f01055d0:	5d                   	pop    %ebp
f01055d1:	c3                   	ret    
		return 0;
f01055d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01055d7:	eb f6                	jmp    f01055cf <strncmp+0x2e>

f01055d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01055d9:	55                   	push   %ebp
f01055da:	89 e5                	mov    %esp,%ebp
f01055dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01055df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01055e3:	0f b6 10             	movzbl (%eax),%edx
f01055e6:	84 d2                	test   %dl,%dl
f01055e8:	74 09                	je     f01055f3 <strchr+0x1a>
		if (*s == c)
f01055ea:	38 ca                	cmp    %cl,%dl
f01055ec:	74 0a                	je     f01055f8 <strchr+0x1f>
	for (; *s; s++)
f01055ee:	83 c0 01             	add    $0x1,%eax
f01055f1:	eb f0                	jmp    f01055e3 <strchr+0xa>
			return (char *) s;
	return 0;
f01055f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01055f8:	5d                   	pop    %ebp
f01055f9:	c3                   	ret    

f01055fa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01055fa:	55                   	push   %ebp
f01055fb:	89 e5                	mov    %esp,%ebp
f01055fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0105600:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105604:	eb 03                	jmp    f0105609 <strfind+0xf>
f0105606:	83 c0 01             	add    $0x1,%eax
f0105609:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010560c:	38 ca                	cmp    %cl,%dl
f010560e:	74 04                	je     f0105614 <strfind+0x1a>
f0105610:	84 d2                	test   %dl,%dl
f0105612:	75 f2                	jne    f0105606 <strfind+0xc>
			break;
	return (char *) s;
}
f0105614:	5d                   	pop    %ebp
f0105615:	c3                   	ret    

f0105616 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105616:	55                   	push   %ebp
f0105617:	89 e5                	mov    %esp,%ebp
f0105619:	57                   	push   %edi
f010561a:	56                   	push   %esi
f010561b:	53                   	push   %ebx
f010561c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010561f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105622:	85 c9                	test   %ecx,%ecx
f0105624:	74 13                	je     f0105639 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105626:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010562c:	75 05                	jne    f0105633 <memset+0x1d>
f010562e:	f6 c1 03             	test   $0x3,%cl
f0105631:	74 0d                	je     f0105640 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105633:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105636:	fc                   	cld    
f0105637:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105639:	89 f8                	mov    %edi,%eax
f010563b:	5b                   	pop    %ebx
f010563c:	5e                   	pop    %esi
f010563d:	5f                   	pop    %edi
f010563e:	5d                   	pop    %ebp
f010563f:	c3                   	ret    
		c &= 0xFF;
f0105640:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105644:	89 d3                	mov    %edx,%ebx
f0105646:	c1 e3 08             	shl    $0x8,%ebx
f0105649:	89 d0                	mov    %edx,%eax
f010564b:	c1 e0 18             	shl    $0x18,%eax
f010564e:	89 d6                	mov    %edx,%esi
f0105650:	c1 e6 10             	shl    $0x10,%esi
f0105653:	09 f0                	or     %esi,%eax
f0105655:	09 c2                	or     %eax,%edx
f0105657:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0105659:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010565c:	89 d0                	mov    %edx,%eax
f010565e:	fc                   	cld    
f010565f:	f3 ab                	rep stos %eax,%es:(%edi)
f0105661:	eb d6                	jmp    f0105639 <memset+0x23>

f0105663 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105663:	55                   	push   %ebp
f0105664:	89 e5                	mov    %esp,%ebp
f0105666:	57                   	push   %edi
f0105667:	56                   	push   %esi
f0105668:	8b 45 08             	mov    0x8(%ebp),%eax
f010566b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010566e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105671:	39 c6                	cmp    %eax,%esi
f0105673:	73 35                	jae    f01056aa <memmove+0x47>
f0105675:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105678:	39 c2                	cmp    %eax,%edx
f010567a:	76 2e                	jbe    f01056aa <memmove+0x47>
		s += n;
		d += n;
f010567c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010567f:	89 d6                	mov    %edx,%esi
f0105681:	09 fe                	or     %edi,%esi
f0105683:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105689:	74 0c                	je     f0105697 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010568b:	83 ef 01             	sub    $0x1,%edi
f010568e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105691:	fd                   	std    
f0105692:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105694:	fc                   	cld    
f0105695:	eb 21                	jmp    f01056b8 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105697:	f6 c1 03             	test   $0x3,%cl
f010569a:	75 ef                	jne    f010568b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010569c:	83 ef 04             	sub    $0x4,%edi
f010569f:	8d 72 fc             	lea    -0x4(%edx),%esi
f01056a2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01056a5:	fd                   	std    
f01056a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01056a8:	eb ea                	jmp    f0105694 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01056aa:	89 f2                	mov    %esi,%edx
f01056ac:	09 c2                	or     %eax,%edx
f01056ae:	f6 c2 03             	test   $0x3,%dl
f01056b1:	74 09                	je     f01056bc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01056b3:	89 c7                	mov    %eax,%edi
f01056b5:	fc                   	cld    
f01056b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01056b8:	5e                   	pop    %esi
f01056b9:	5f                   	pop    %edi
f01056ba:	5d                   	pop    %ebp
f01056bb:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01056bc:	f6 c1 03             	test   $0x3,%cl
f01056bf:	75 f2                	jne    f01056b3 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01056c1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01056c4:	89 c7                	mov    %eax,%edi
f01056c6:	fc                   	cld    
f01056c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01056c9:	eb ed                	jmp    f01056b8 <memmove+0x55>

f01056cb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01056cb:	55                   	push   %ebp
f01056cc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01056ce:	ff 75 10             	pushl  0x10(%ebp)
f01056d1:	ff 75 0c             	pushl  0xc(%ebp)
f01056d4:	ff 75 08             	pushl  0x8(%ebp)
f01056d7:	e8 87 ff ff ff       	call   f0105663 <memmove>
}
f01056dc:	c9                   	leave  
f01056dd:	c3                   	ret    

f01056de <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01056de:	55                   	push   %ebp
f01056df:	89 e5                	mov    %esp,%ebp
f01056e1:	56                   	push   %esi
f01056e2:	53                   	push   %ebx
f01056e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01056e6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056e9:	89 c6                	mov    %eax,%esi
f01056eb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056ee:	39 f0                	cmp    %esi,%eax
f01056f0:	74 1c                	je     f010570e <memcmp+0x30>
		if (*s1 != *s2)
f01056f2:	0f b6 08             	movzbl (%eax),%ecx
f01056f5:	0f b6 1a             	movzbl (%edx),%ebx
f01056f8:	38 d9                	cmp    %bl,%cl
f01056fa:	75 08                	jne    f0105704 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01056fc:	83 c0 01             	add    $0x1,%eax
f01056ff:	83 c2 01             	add    $0x1,%edx
f0105702:	eb ea                	jmp    f01056ee <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0105704:	0f b6 c1             	movzbl %cl,%eax
f0105707:	0f b6 db             	movzbl %bl,%ebx
f010570a:	29 d8                	sub    %ebx,%eax
f010570c:	eb 05                	jmp    f0105713 <memcmp+0x35>
	}

	return 0;
f010570e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105713:	5b                   	pop    %ebx
f0105714:	5e                   	pop    %esi
f0105715:	5d                   	pop    %ebp
f0105716:	c3                   	ret    

f0105717 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105717:	55                   	push   %ebp
f0105718:	89 e5                	mov    %esp,%ebp
f010571a:	8b 45 08             	mov    0x8(%ebp),%eax
f010571d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105720:	89 c2                	mov    %eax,%edx
f0105722:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105725:	39 d0                	cmp    %edx,%eax
f0105727:	73 09                	jae    f0105732 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105729:	38 08                	cmp    %cl,(%eax)
f010572b:	74 05                	je     f0105732 <memfind+0x1b>
	for (; s < ends; s++)
f010572d:	83 c0 01             	add    $0x1,%eax
f0105730:	eb f3                	jmp    f0105725 <memfind+0xe>
			break;
	return (void *) s;
}
f0105732:	5d                   	pop    %ebp
f0105733:	c3                   	ret    

f0105734 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105734:	55                   	push   %ebp
f0105735:	89 e5                	mov    %esp,%ebp
f0105737:	57                   	push   %edi
f0105738:	56                   	push   %esi
f0105739:	53                   	push   %ebx
f010573a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010573d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105740:	eb 03                	jmp    f0105745 <strtol+0x11>
		s++;
f0105742:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105745:	0f b6 01             	movzbl (%ecx),%eax
f0105748:	3c 20                	cmp    $0x20,%al
f010574a:	74 f6                	je     f0105742 <strtol+0xe>
f010574c:	3c 09                	cmp    $0x9,%al
f010574e:	74 f2                	je     f0105742 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105750:	3c 2b                	cmp    $0x2b,%al
f0105752:	74 2e                	je     f0105782 <strtol+0x4e>
	int neg = 0;
f0105754:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105759:	3c 2d                	cmp    $0x2d,%al
f010575b:	74 2f                	je     f010578c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010575d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105763:	75 05                	jne    f010576a <strtol+0x36>
f0105765:	80 39 30             	cmpb   $0x30,(%ecx)
f0105768:	74 2c                	je     f0105796 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010576a:	85 db                	test   %ebx,%ebx
f010576c:	75 0a                	jne    f0105778 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010576e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0105773:	80 39 30             	cmpb   $0x30,(%ecx)
f0105776:	74 28                	je     f01057a0 <strtol+0x6c>
		base = 10;
f0105778:	b8 00 00 00 00       	mov    $0x0,%eax
f010577d:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105780:	eb 50                	jmp    f01057d2 <strtol+0x9e>
		s++;
f0105782:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105785:	bf 00 00 00 00       	mov    $0x0,%edi
f010578a:	eb d1                	jmp    f010575d <strtol+0x29>
		s++, neg = 1;
f010578c:	83 c1 01             	add    $0x1,%ecx
f010578f:	bf 01 00 00 00       	mov    $0x1,%edi
f0105794:	eb c7                	jmp    f010575d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105796:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010579a:	74 0e                	je     f01057aa <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f010579c:	85 db                	test   %ebx,%ebx
f010579e:	75 d8                	jne    f0105778 <strtol+0x44>
		s++, base = 8;
f01057a0:	83 c1 01             	add    $0x1,%ecx
f01057a3:	bb 08 00 00 00       	mov    $0x8,%ebx
f01057a8:	eb ce                	jmp    f0105778 <strtol+0x44>
		s += 2, base = 16;
f01057aa:	83 c1 02             	add    $0x2,%ecx
f01057ad:	bb 10 00 00 00       	mov    $0x10,%ebx
f01057b2:	eb c4                	jmp    f0105778 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01057b4:	8d 72 9f             	lea    -0x61(%edx),%esi
f01057b7:	89 f3                	mov    %esi,%ebx
f01057b9:	80 fb 19             	cmp    $0x19,%bl
f01057bc:	77 29                	ja     f01057e7 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01057be:	0f be d2             	movsbl %dl,%edx
f01057c1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01057c4:	3b 55 10             	cmp    0x10(%ebp),%edx
f01057c7:	7d 30                	jge    f01057f9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01057c9:	83 c1 01             	add    $0x1,%ecx
f01057cc:	0f af 45 10          	imul   0x10(%ebp),%eax
f01057d0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01057d2:	0f b6 11             	movzbl (%ecx),%edx
f01057d5:	8d 72 d0             	lea    -0x30(%edx),%esi
f01057d8:	89 f3                	mov    %esi,%ebx
f01057da:	80 fb 09             	cmp    $0x9,%bl
f01057dd:	77 d5                	ja     f01057b4 <strtol+0x80>
			dig = *s - '0';
f01057df:	0f be d2             	movsbl %dl,%edx
f01057e2:	83 ea 30             	sub    $0x30,%edx
f01057e5:	eb dd                	jmp    f01057c4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f01057e7:	8d 72 bf             	lea    -0x41(%edx),%esi
f01057ea:	89 f3                	mov    %esi,%ebx
f01057ec:	80 fb 19             	cmp    $0x19,%bl
f01057ef:	77 08                	ja     f01057f9 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01057f1:	0f be d2             	movsbl %dl,%edx
f01057f4:	83 ea 37             	sub    $0x37,%edx
f01057f7:	eb cb                	jmp    f01057c4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f01057f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01057fd:	74 05                	je     f0105804 <strtol+0xd0>
		*endptr = (char *) s;
f01057ff:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105802:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105804:	89 c2                	mov    %eax,%edx
f0105806:	f7 da                	neg    %edx
f0105808:	85 ff                	test   %edi,%edi
f010580a:	0f 45 c2             	cmovne %edx,%eax
}
f010580d:	5b                   	pop    %ebx
f010580e:	5e                   	pop    %esi
f010580f:	5f                   	pop    %edi
f0105810:	5d                   	pop    %ebp
f0105811:	c3                   	ret    
f0105812:	66 90                	xchg   %ax,%ax

f0105814 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105814:	fa                   	cli    

	xorw    %ax, %ax
f0105815:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105817:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105819:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010581b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f010581d:	0f 01 16             	lgdtl  (%esi)
f0105820:	74 70                	je     f0105892 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105822:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105825:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105829:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010582c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105832:	08 00                	or     %al,(%eax)

f0105834 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105834:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105838:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010583a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010583c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010583e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105842:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105844:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105846:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f010584b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010584e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105851:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105856:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105859:	8b 25 84 3e 21 f0    	mov    0xf0213e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010585f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105864:	b8 b4 01 10 f0       	mov    $0xf01001b4,%eax
	call    *%eax
f0105869:	ff d0                	call   *%eax

f010586b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010586b:	eb fe                	jmp    f010586b <spin>
f010586d:	8d 76 00             	lea    0x0(%esi),%esi

f0105870 <gdt>:
	...
f0105878:	ff                   	(bad)  
f0105879:	ff 00                	incl   (%eax)
f010587b:	00 00                	add    %al,(%eax)
f010587d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105884:	00                   	.byte 0x0
f0105885:	92                   	xchg   %eax,%edx
f0105886:	cf                   	iret   
	...

f0105888 <gdtdesc>:
f0105888:	17                   	pop    %ss
f0105889:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010588e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010588e:	90                   	nop

f010588f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010588f:	55                   	push   %ebp
f0105890:	89 e5                	mov    %esp,%ebp
f0105892:	57                   	push   %edi
f0105893:	56                   	push   %esi
f0105894:	53                   	push   %ebx
f0105895:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0105898:	8b 0d 88 3e 21 f0    	mov    0xf0213e88,%ecx
f010589e:	89 c3                	mov    %eax,%ebx
f01058a0:	c1 eb 0c             	shr    $0xc,%ebx
f01058a3:	39 cb                	cmp    %ecx,%ebx
f01058a5:	73 1a                	jae    f01058c1 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f01058a7:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01058ad:	8d 34 02             	lea    (%edx,%eax,1),%esi
	if (PGNUM(pa) >= npages)
f01058b0:	89 f0                	mov    %esi,%eax
f01058b2:	c1 e8 0c             	shr    $0xc,%eax
f01058b5:	39 c8                	cmp    %ecx,%eax
f01058b7:	73 1a                	jae    f01058d3 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f01058b9:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01058bf:	eb 27                	jmp    f01058e8 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01058c1:	50                   	push   %eax
f01058c2:	68 a4 62 10 f0       	push   $0xf01062a4
f01058c7:	6a 57                	push   $0x57
f01058c9:	68 7d 7e 10 f0       	push   $0xf0107e7d
f01058ce:	e8 6d a7 ff ff       	call   f0100040 <_panic>
f01058d3:	56                   	push   %esi
f01058d4:	68 a4 62 10 f0       	push   $0xf01062a4
f01058d9:	6a 57                	push   $0x57
f01058db:	68 7d 7e 10 f0       	push   $0xf0107e7d
f01058e0:	e8 5b a7 ff ff       	call   f0100040 <_panic>
f01058e5:	83 c3 10             	add    $0x10,%ebx
f01058e8:	39 f3                	cmp    %esi,%ebx
f01058ea:	73 2e                	jae    f010591a <mpsearch1+0x8b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01058ec:	83 ec 04             	sub    $0x4,%esp
f01058ef:	6a 04                	push   $0x4
f01058f1:	68 8d 7e 10 f0       	push   $0xf0107e8d
f01058f6:	53                   	push   %ebx
f01058f7:	e8 e2 fd ff ff       	call   f01056de <memcmp>
f01058fc:	83 c4 10             	add    $0x10,%esp
f01058ff:	85 c0                	test   %eax,%eax
f0105901:	75 e2                	jne    f01058e5 <mpsearch1+0x56>
f0105903:	89 da                	mov    %ebx,%edx
f0105905:	8d 7b 10             	lea    0x10(%ebx),%edi
		sum += ((uint8_t *)addr)[i];
f0105908:	0f b6 0a             	movzbl (%edx),%ecx
f010590b:	01 c8                	add    %ecx,%eax
f010590d:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0105910:	39 fa                	cmp    %edi,%edx
f0105912:	75 f4                	jne    f0105908 <mpsearch1+0x79>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105914:	84 c0                	test   %al,%al
f0105916:	75 cd                	jne    f01058e5 <mpsearch1+0x56>
f0105918:	eb 05                	jmp    f010591f <mpsearch1+0x90>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010591a:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010591f:	89 d8                	mov    %ebx,%eax
f0105921:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105924:	5b                   	pop    %ebx
f0105925:	5e                   	pop    %esi
f0105926:	5f                   	pop    %edi
f0105927:	5d                   	pop    %ebp
f0105928:	c3                   	ret    

f0105929 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105929:	55                   	push   %ebp
f010592a:	89 e5                	mov    %esp,%ebp
f010592c:	57                   	push   %edi
f010592d:	56                   	push   %esi
f010592e:	53                   	push   %ebx
f010592f:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105932:	c7 05 c0 43 21 f0 20 	movl   $0xf0214020,0xf02143c0
f0105939:	40 21 f0 
	if (PGNUM(pa) >= npages)
f010593c:	83 3d 88 3e 21 f0 00 	cmpl   $0x0,0xf0213e88
f0105943:	0f 84 87 00 00 00    	je     f01059d0 <mp_init+0xa7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105949:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105950:	85 c0                	test   %eax,%eax
f0105952:	0f 84 8e 00 00 00    	je     f01059e6 <mp_init+0xbd>
		p <<= 4;	// Translate from segment to PA
f0105958:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010595b:	ba 00 04 00 00       	mov    $0x400,%edx
f0105960:	e8 2a ff ff ff       	call   f010588f <mpsearch1>
f0105965:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105968:	85 c0                	test   %eax,%eax
f010596a:	0f 84 9a 00 00 00    	je     f0105a0a <mp_init+0xe1>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105970:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105973:	8b 41 04             	mov    0x4(%ecx),%eax
f0105976:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105979:	85 c0                	test   %eax,%eax
f010597b:	0f 84 a8 00 00 00    	je     f0105a29 <mp_init+0x100>
f0105981:	80 79 0b 00          	cmpb   $0x0,0xb(%ecx)
f0105985:	0f 85 9e 00 00 00    	jne    f0105a29 <mp_init+0x100>
f010598b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010598e:	c1 e8 0c             	shr    $0xc,%eax
f0105991:	3b 05 88 3e 21 f0    	cmp    0xf0213e88,%eax
f0105997:	0f 83 a1 00 00 00    	jae    f0105a3e <mp_init+0x115>
	return (void *)(pa + KERNBASE);
f010599d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059a0:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01059a6:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01059a8:	83 ec 04             	sub    $0x4,%esp
f01059ab:	6a 04                	push   $0x4
f01059ad:	68 92 7e 10 f0       	push   $0xf0107e92
f01059b2:	53                   	push   %ebx
f01059b3:	e8 26 fd ff ff       	call   f01056de <memcmp>
f01059b8:	83 c4 10             	add    $0x10,%esp
f01059bb:	85 c0                	test   %eax,%eax
f01059bd:	0f 85 92 00 00 00    	jne    f0105a55 <mp_init+0x12c>
f01059c3:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f01059c7:	01 df                	add    %ebx,%edi
	sum = 0;
f01059c9:	89 c2                	mov    %eax,%edx
f01059cb:	e9 a2 00 00 00       	jmp    f0105a72 <mp_init+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059d0:	68 00 04 00 00       	push   $0x400
f01059d5:	68 a4 62 10 f0       	push   $0xf01062a4
f01059da:	6a 6f                	push   $0x6f
f01059dc:	68 7d 7e 10 f0       	push   $0xf0107e7d
f01059e1:	e8 5a a6 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01059e6:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01059ed:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01059f0:	2d 00 04 00 00       	sub    $0x400,%eax
f01059f5:	ba 00 04 00 00       	mov    $0x400,%edx
f01059fa:	e8 90 fe ff ff       	call   f010588f <mpsearch1>
f01059ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105a02:	85 c0                	test   %eax,%eax
f0105a04:	0f 85 66 ff ff ff    	jne    f0105970 <mp_init+0x47>
	return mpsearch1(0xF0000, 0x10000);
f0105a0a:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105a0f:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105a14:	e8 76 fe ff ff       	call   f010588f <mpsearch1>
f0105a19:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((mp = mpsearch()) == 0)
f0105a1c:	85 c0                	test   %eax,%eax
f0105a1e:	0f 85 4c ff ff ff    	jne    f0105970 <mp_init+0x47>
f0105a24:	e9 a8 01 00 00       	jmp    f0105bd1 <mp_init+0x2a8>
		cprintf("SMP: Default configurations not implemented\n");
f0105a29:	83 ec 0c             	sub    $0xc,%esp
f0105a2c:	68 f0 7c 10 f0       	push   $0xf0107cf0
f0105a31:	e8 79 de ff ff       	call   f01038af <cprintf>
f0105a36:	83 c4 10             	add    $0x10,%esp
f0105a39:	e9 93 01 00 00       	jmp    f0105bd1 <mp_init+0x2a8>
f0105a3e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105a41:	68 a4 62 10 f0       	push   $0xf01062a4
f0105a46:	68 90 00 00 00       	push   $0x90
f0105a4b:	68 7d 7e 10 f0       	push   $0xf0107e7d
f0105a50:	e8 eb a5 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105a55:	83 ec 0c             	sub    $0xc,%esp
f0105a58:	68 20 7d 10 f0       	push   $0xf0107d20
f0105a5d:	e8 4d de ff ff       	call   f01038af <cprintf>
f0105a62:	83 c4 10             	add    $0x10,%esp
f0105a65:	e9 67 01 00 00       	jmp    f0105bd1 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f0105a6a:	0f b6 0b             	movzbl (%ebx),%ecx
f0105a6d:	01 ca                	add    %ecx,%edx
f0105a6f:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105a72:	39 fb                	cmp    %edi,%ebx
f0105a74:	75 f4                	jne    f0105a6a <mp_init+0x141>
	if (sum(conf, conf->length) != 0) {
f0105a76:	84 d2                	test   %dl,%dl
f0105a78:	75 16                	jne    f0105a90 <mp_init+0x167>
	if (conf->version != 1 && conf->version != 4) {
f0105a7a:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105a7e:	80 fa 01             	cmp    $0x1,%dl
f0105a81:	74 05                	je     f0105a88 <mp_init+0x15f>
f0105a83:	80 fa 04             	cmp    $0x4,%dl
f0105a86:	75 1d                	jne    f0105aa5 <mp_init+0x17c>
f0105a88:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105a8c:	01 d9                	add    %ebx,%ecx
f0105a8e:	eb 36                	jmp    f0105ac6 <mp_init+0x19d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105a90:	83 ec 0c             	sub    $0xc,%esp
f0105a93:	68 54 7d 10 f0       	push   $0xf0107d54
f0105a98:	e8 12 de ff ff       	call   f01038af <cprintf>
f0105a9d:	83 c4 10             	add    $0x10,%esp
f0105aa0:	e9 2c 01 00 00       	jmp    f0105bd1 <mp_init+0x2a8>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105aa5:	83 ec 08             	sub    $0x8,%esp
f0105aa8:	0f b6 d2             	movzbl %dl,%edx
f0105aab:	52                   	push   %edx
f0105aac:	68 78 7d 10 f0       	push   $0xf0107d78
f0105ab1:	e8 f9 dd ff ff       	call   f01038af <cprintf>
f0105ab6:	83 c4 10             	add    $0x10,%esp
f0105ab9:	e9 13 01 00 00       	jmp    f0105bd1 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f0105abe:	0f b6 13             	movzbl (%ebx),%edx
f0105ac1:	01 d0                	add    %edx,%eax
f0105ac3:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105ac6:	39 d9                	cmp    %ebx,%ecx
f0105ac8:	75 f4                	jne    f0105abe <mp_init+0x195>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105aca:	02 46 2a             	add    0x2a(%esi),%al
f0105acd:	75 29                	jne    f0105af8 <mp_init+0x1cf>
	if ((conf = mpconfig(&mp)) == 0)
f0105acf:	81 7d e4 00 00 00 10 	cmpl   $0x10000000,-0x1c(%ebp)
f0105ad6:	0f 84 f5 00 00 00    	je     f0105bd1 <mp_init+0x2a8>
		return;
	ismp = 1;
f0105adc:	c7 05 00 40 21 f0 01 	movl   $0x1,0xf0214000
f0105ae3:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105ae6:	8b 46 24             	mov    0x24(%esi),%eax
f0105ae9:	a3 00 50 25 f0       	mov    %eax,0xf0255000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105aee:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105af1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105af6:	eb 4d                	jmp    f0105b45 <mp_init+0x21c>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105af8:	83 ec 0c             	sub    $0xc,%esp
f0105afb:	68 98 7d 10 f0       	push   $0xf0107d98
f0105b00:	e8 aa dd ff ff       	call   f01038af <cprintf>
f0105b05:	83 c4 10             	add    $0x10,%esp
f0105b08:	e9 c4 00 00 00       	jmp    f0105bd1 <mp_init+0x2a8>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105b0d:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105b11:	74 11                	je     f0105b24 <mp_init+0x1fb>
				bootcpu = &cpus[ncpu];
f0105b13:	6b 05 c4 43 21 f0 74 	imul   $0x74,0xf02143c4,%eax
f0105b1a:	05 20 40 21 f0       	add    $0xf0214020,%eax
f0105b1f:	a3 c0 43 21 f0       	mov    %eax,0xf02143c0
			if (ncpu < NCPU) {
f0105b24:	a1 c4 43 21 f0       	mov    0xf02143c4,%eax
f0105b29:	83 f8 07             	cmp    $0x7,%eax
f0105b2c:	7f 2f                	jg     f0105b5d <mp_init+0x234>
				cpus[ncpu].cpu_id = ncpu;
f0105b2e:	6b d0 74             	imul   $0x74,%eax,%edx
f0105b31:	88 82 20 40 21 f0    	mov    %al,-0xfdebfe0(%edx)
				ncpu++;
f0105b37:	83 c0 01             	add    $0x1,%eax
f0105b3a:	a3 c4 43 21 f0       	mov    %eax,0xf02143c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105b3f:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105b42:	83 c3 01             	add    $0x1,%ebx
f0105b45:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105b49:	39 d8                	cmp    %ebx,%eax
f0105b4b:	76 4b                	jbe    f0105b98 <mp_init+0x26f>
		switch (*p) {
f0105b4d:	0f b6 07             	movzbl (%edi),%eax
f0105b50:	84 c0                	test   %al,%al
f0105b52:	74 b9                	je     f0105b0d <mp_init+0x1e4>
f0105b54:	3c 04                	cmp    $0x4,%al
f0105b56:	77 1c                	ja     f0105b74 <mp_init+0x24b>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105b58:	83 c7 08             	add    $0x8,%edi
			continue;
f0105b5b:	eb e5                	jmp    f0105b42 <mp_init+0x219>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105b5d:	83 ec 08             	sub    $0x8,%esp
f0105b60:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105b64:	50                   	push   %eax
f0105b65:	68 c8 7d 10 f0       	push   $0xf0107dc8
f0105b6a:	e8 40 dd ff ff       	call   f01038af <cprintf>
f0105b6f:	83 c4 10             	add    $0x10,%esp
f0105b72:	eb cb                	jmp    f0105b3f <mp_init+0x216>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105b74:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105b77:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105b7a:	50                   	push   %eax
f0105b7b:	68 f0 7d 10 f0       	push   $0xf0107df0
f0105b80:	e8 2a dd ff ff       	call   f01038af <cprintf>
			ismp = 0;
f0105b85:	c7 05 00 40 21 f0 00 	movl   $0x0,0xf0214000
f0105b8c:	00 00 00 
			i = conf->entry;
f0105b8f:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0105b93:	83 c4 10             	add    $0x10,%esp
f0105b96:	eb aa                	jmp    f0105b42 <mp_init+0x219>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105b98:	a1 c0 43 21 f0       	mov    0xf02143c0,%eax
f0105b9d:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105ba4:	83 3d 00 40 21 f0 00 	cmpl   $0x0,0xf0214000
f0105bab:	75 2c                	jne    f0105bd9 <mp_init+0x2b0>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105bad:	c7 05 c4 43 21 f0 01 	movl   $0x1,0xf02143c4
f0105bb4:	00 00 00 
		lapicaddr = 0;
f0105bb7:	c7 05 00 50 25 f0 00 	movl   $0x0,0xf0255000
f0105bbe:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105bc1:	83 ec 0c             	sub    $0xc,%esp
f0105bc4:	68 10 7e 10 f0       	push   $0xf0107e10
f0105bc9:	e8 e1 dc ff ff       	call   f01038af <cprintf>
		return;
f0105bce:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105bd4:	5b                   	pop    %ebx
f0105bd5:	5e                   	pop    %esi
f0105bd6:	5f                   	pop    %edi
f0105bd7:	5d                   	pop    %ebp
f0105bd8:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105bd9:	83 ec 04             	sub    $0x4,%esp
f0105bdc:	ff 35 c4 43 21 f0    	pushl  0xf02143c4
f0105be2:	0f b6 00             	movzbl (%eax),%eax
f0105be5:	50                   	push   %eax
f0105be6:	68 97 7e 10 f0       	push   $0xf0107e97
f0105beb:	e8 bf dc ff ff       	call   f01038af <cprintf>
	if (mp->imcrp) {
f0105bf0:	83 c4 10             	add    $0x10,%esp
f0105bf3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105bf6:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105bfa:	74 d5                	je     f0105bd1 <mp_init+0x2a8>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105bfc:	83 ec 0c             	sub    $0xc,%esp
f0105bff:	68 3c 7e 10 f0       	push   $0xf0107e3c
f0105c04:	e8 a6 dc ff ff       	call   f01038af <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105c09:	b8 70 00 00 00       	mov    $0x70,%eax
f0105c0e:	ba 22 00 00 00       	mov    $0x22,%edx
f0105c13:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105c14:	ba 23 00 00 00       	mov    $0x23,%edx
f0105c19:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105c1a:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105c1d:	ee                   	out    %al,(%dx)
f0105c1e:	83 c4 10             	add    $0x10,%esp
f0105c21:	eb ae                	jmp    f0105bd1 <mp_init+0x2a8>

f0105c23 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105c23:	55                   	push   %ebp
f0105c24:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105c26:	8b 0d 04 50 25 f0    	mov    0xf0255004,%ecx
f0105c2c:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105c2f:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105c31:	a1 04 50 25 f0       	mov    0xf0255004,%eax
f0105c36:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105c39:	5d                   	pop    %ebp
f0105c3a:	c3                   	ret    

f0105c3b <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105c3b:	55                   	push   %ebp
f0105c3c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105c3e:	8b 15 04 50 25 f0    	mov    0xf0255004,%edx
		return lapic[ID] >> 24;
	return 0;
f0105c44:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105c49:	85 d2                	test   %edx,%edx
f0105c4b:	74 06                	je     f0105c53 <cpunum+0x18>
		return lapic[ID] >> 24;
f0105c4d:	8b 42 20             	mov    0x20(%edx),%eax
f0105c50:	c1 e8 18             	shr    $0x18,%eax
}
f0105c53:	5d                   	pop    %ebp
f0105c54:	c3                   	ret    

f0105c55 <lapic_init>:
	if (!lapicaddr)
f0105c55:	a1 00 50 25 f0       	mov    0xf0255000,%eax
f0105c5a:	85 c0                	test   %eax,%eax
f0105c5c:	75 02                	jne    f0105c60 <lapic_init+0xb>
f0105c5e:	f3 c3                	repz ret 
{
f0105c60:	55                   	push   %ebp
f0105c61:	89 e5                	mov    %esp,%ebp
f0105c63:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105c66:	68 00 10 00 00       	push   $0x1000
f0105c6b:	50                   	push   %eax
f0105c6c:	e8 1f b6 ff ff       	call   f0101290 <mmio_map_region>
f0105c71:	a3 04 50 25 f0       	mov    %eax,0xf0255004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105c76:	ba 27 01 00 00       	mov    $0x127,%edx
f0105c7b:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105c80:	e8 9e ff ff ff       	call   f0105c23 <lapicw>
	lapicw(TDCR, X1);
f0105c85:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105c8a:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105c8f:	e8 8f ff ff ff       	call   f0105c23 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105c94:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105c99:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105c9e:	e8 80 ff ff ff       	call   f0105c23 <lapicw>
	lapicw(TICR, 10000000); 
f0105ca3:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105ca8:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105cad:	e8 71 ff ff ff       	call   f0105c23 <lapicw>
	if (thiscpu != bootcpu)
f0105cb2:	e8 84 ff ff ff       	call   f0105c3b <cpunum>
f0105cb7:	6b c0 74             	imul   $0x74,%eax,%eax
f0105cba:	05 20 40 21 f0       	add    $0xf0214020,%eax
f0105cbf:	83 c4 10             	add    $0x10,%esp
f0105cc2:	39 05 c0 43 21 f0    	cmp    %eax,0xf02143c0
f0105cc8:	74 0f                	je     f0105cd9 <lapic_init+0x84>
		lapicw(LINT0, MASKED);
f0105cca:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ccf:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105cd4:	e8 4a ff ff ff       	call   f0105c23 <lapicw>
	lapicw(LINT1, MASKED);
f0105cd9:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cde:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105ce3:	e8 3b ff ff ff       	call   f0105c23 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105ce8:	a1 04 50 25 f0       	mov    0xf0255004,%eax
f0105ced:	8b 40 30             	mov    0x30(%eax),%eax
f0105cf0:	c1 e8 10             	shr    $0x10,%eax
f0105cf3:	3c 03                	cmp    $0x3,%al
f0105cf5:	77 7c                	ja     f0105d73 <lapic_init+0x11e>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105cf7:	ba 33 00 00 00       	mov    $0x33,%edx
f0105cfc:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105d01:	e8 1d ff ff ff       	call   f0105c23 <lapicw>
	lapicw(ESR, 0);
f0105d06:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d0b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105d10:	e8 0e ff ff ff       	call   f0105c23 <lapicw>
	lapicw(ESR, 0);
f0105d15:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d1a:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105d1f:	e8 ff fe ff ff       	call   f0105c23 <lapicw>
	lapicw(EOI, 0);
f0105d24:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d29:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d2e:	e8 f0 fe ff ff       	call   f0105c23 <lapicw>
	lapicw(ICRHI, 0);
f0105d33:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d38:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d3d:	e8 e1 fe ff ff       	call   f0105c23 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105d42:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105d47:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d4c:	e8 d2 fe ff ff       	call   f0105c23 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105d51:	8b 15 04 50 25 f0    	mov    0xf0255004,%edx
f0105d57:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105d5d:	f6 c4 10             	test   $0x10,%ah
f0105d60:	75 f5                	jne    f0105d57 <lapic_init+0x102>
	lapicw(TPR, 0);
f0105d62:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d67:	b8 20 00 00 00       	mov    $0x20,%eax
f0105d6c:	e8 b2 fe ff ff       	call   f0105c23 <lapicw>
}
f0105d71:	c9                   	leave  
f0105d72:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105d73:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105d78:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105d7d:	e8 a1 fe ff ff       	call   f0105c23 <lapicw>
f0105d82:	e9 70 ff ff ff       	jmp    f0105cf7 <lapic_init+0xa2>

f0105d87 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105d87:	83 3d 04 50 25 f0 00 	cmpl   $0x0,0xf0255004
f0105d8e:	74 14                	je     f0105da4 <lapic_eoi+0x1d>
{
f0105d90:	55                   	push   %ebp
f0105d91:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f0105d93:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d98:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d9d:	e8 81 fe ff ff       	call   f0105c23 <lapicw>
}
f0105da2:	5d                   	pop    %ebp
f0105da3:	c3                   	ret    
f0105da4:	f3 c3                	repz ret 

f0105da6 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105da6:	55                   	push   %ebp
f0105da7:	89 e5                	mov    %esp,%ebp
f0105da9:	56                   	push   %esi
f0105daa:	53                   	push   %ebx
f0105dab:	8b 75 08             	mov    0x8(%ebp),%esi
f0105dae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105db1:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105db6:	ba 70 00 00 00       	mov    $0x70,%edx
f0105dbb:	ee                   	out    %al,(%dx)
f0105dbc:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105dc1:	ba 71 00 00 00       	mov    $0x71,%edx
f0105dc6:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105dc7:	83 3d 88 3e 21 f0 00 	cmpl   $0x0,0xf0213e88
f0105dce:	74 7e                	je     f0105e4e <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105dd0:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105dd7:	00 00 
	wrv[1] = addr >> 4;
f0105dd9:	89 d8                	mov    %ebx,%eax
f0105ddb:	c1 e8 04             	shr    $0x4,%eax
f0105dde:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105de4:	c1 e6 18             	shl    $0x18,%esi
f0105de7:	89 f2                	mov    %esi,%edx
f0105de9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105dee:	e8 30 fe ff ff       	call   f0105c23 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105df3:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105df8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dfd:	e8 21 fe ff ff       	call   f0105c23 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105e02:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105e07:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e0c:	e8 12 fe ff ff       	call   f0105c23 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e11:	c1 eb 0c             	shr    $0xc,%ebx
f0105e14:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0105e17:	89 f2                	mov    %esi,%edx
f0105e19:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e1e:	e8 00 fe ff ff       	call   f0105c23 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e23:	89 da                	mov    %ebx,%edx
f0105e25:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e2a:	e8 f4 fd ff ff       	call   f0105c23 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0105e2f:	89 f2                	mov    %esi,%edx
f0105e31:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e36:	e8 e8 fd ff ff       	call   f0105c23 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e3b:	89 da                	mov    %ebx,%edx
f0105e3d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e42:	e8 dc fd ff ff       	call   f0105c23 <lapicw>
		microdelay(200);
	}
}
f0105e47:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e4a:	5b                   	pop    %ebx
f0105e4b:	5e                   	pop    %esi
f0105e4c:	5d                   	pop    %ebp
f0105e4d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e4e:	68 67 04 00 00       	push   $0x467
f0105e53:	68 a4 62 10 f0       	push   $0xf01062a4
f0105e58:	68 98 00 00 00       	push   $0x98
f0105e5d:	68 b4 7e 10 f0       	push   $0xf0107eb4
f0105e62:	e8 d9 a1 ff ff       	call   f0100040 <_panic>

f0105e67 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105e67:	55                   	push   %ebp
f0105e68:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105e6a:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e6d:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105e73:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e78:	e8 a6 fd ff ff       	call   f0105c23 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105e7d:	8b 15 04 50 25 f0    	mov    0xf0255004,%edx
f0105e83:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e89:	f6 c4 10             	test   $0x10,%ah
f0105e8c:	75 f5                	jne    f0105e83 <lapic_ipi+0x1c>
		;
}
f0105e8e:	5d                   	pop    %ebp
f0105e8f:	c3                   	ret    

f0105e90 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105e90:	55                   	push   %ebp
f0105e91:	89 e5                	mov    %esp,%ebp
f0105e93:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105e96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105e9c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e9f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105ea2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105ea9:	5d                   	pop    %ebp
f0105eaa:	c3                   	ret    

f0105eab <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105eab:	55                   	push   %ebp
f0105eac:	89 e5                	mov    %esp,%ebp
f0105eae:	56                   	push   %esi
f0105eaf:	53                   	push   %ebx
f0105eb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0105eb3:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105eb6:	75 07                	jne    f0105ebf <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f0105eb8:	ba 01 00 00 00       	mov    $0x1,%edx
f0105ebd:	eb 34                	jmp    f0105ef3 <spin_lock+0x48>
f0105ebf:	8b 73 08             	mov    0x8(%ebx),%esi
f0105ec2:	e8 74 fd ff ff       	call   f0105c3b <cpunum>
f0105ec7:	6b c0 74             	imul   $0x74,%eax,%eax
f0105eca:	05 20 40 21 f0       	add    $0xf0214020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105ecf:	39 c6                	cmp    %eax,%esi
f0105ed1:	75 e5                	jne    f0105eb8 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105ed3:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105ed6:	e8 60 fd ff ff       	call   f0105c3b <cpunum>
f0105edb:	83 ec 0c             	sub    $0xc,%esp
f0105ede:	53                   	push   %ebx
f0105edf:	50                   	push   %eax
f0105ee0:	68 c4 7e 10 f0       	push   $0xf0107ec4
f0105ee5:	6a 41                	push   $0x41
f0105ee7:	68 28 7f 10 f0       	push   $0xf0107f28
f0105eec:	e8 4f a1 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105ef1:	f3 90                	pause  
f0105ef3:	89 d0                	mov    %edx,%eax
f0105ef5:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0105ef8:	85 c0                	test   %eax,%eax
f0105efa:	75 f5                	jne    f0105ef1 <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105efc:	e8 3a fd ff ff       	call   f0105c3b <cpunum>
f0105f01:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f04:	05 20 40 21 f0       	add    $0xf0214020,%eax
f0105f09:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105f0c:	83 c3 0c             	add    $0xc,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105f0f:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0105f11:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f16:	eb 0b                	jmp    f0105f23 <spin_lock+0x78>
		pcs[i] = ebp[1];          // saved %eip
f0105f18:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105f1b:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105f1e:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0105f20:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105f23:	83 f8 09             	cmp    $0x9,%eax
f0105f26:	7f 14                	jg     f0105f3c <spin_lock+0x91>
f0105f28:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105f2e:	77 e8                	ja     f0105f18 <spin_lock+0x6d>
f0105f30:	eb 0a                	jmp    f0105f3c <spin_lock+0x91>
		pcs[i] = 0;
f0105f32:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0105f39:	83 c0 01             	add    $0x1,%eax
f0105f3c:	83 f8 09             	cmp    $0x9,%eax
f0105f3f:	7e f1                	jle    f0105f32 <spin_lock+0x87>
#endif
}
f0105f41:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105f44:	5b                   	pop    %ebx
f0105f45:	5e                   	pop    %esi
f0105f46:	5d                   	pop    %ebp
f0105f47:	c3                   	ret    

f0105f48 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105f48:	55                   	push   %ebp
f0105f49:	89 e5                	mov    %esp,%ebp
f0105f4b:	57                   	push   %edi
f0105f4c:	56                   	push   %esi
f0105f4d:	53                   	push   %ebx
f0105f4e:	83 ec 4c             	sub    $0x4c,%esp
f0105f51:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0105f54:	83 3e 00             	cmpl   $0x0,(%esi)
f0105f57:	75 35                	jne    f0105f8e <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105f59:	83 ec 04             	sub    $0x4,%esp
f0105f5c:	6a 28                	push   $0x28
f0105f5e:	8d 46 0c             	lea    0xc(%esi),%eax
f0105f61:	50                   	push   %eax
f0105f62:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105f65:	53                   	push   %ebx
f0105f66:	e8 f8 f6 ff ff       	call   f0105663 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105f6b:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105f6e:	0f b6 38             	movzbl (%eax),%edi
f0105f71:	8b 76 04             	mov    0x4(%esi),%esi
f0105f74:	e8 c2 fc ff ff       	call   f0105c3b <cpunum>
f0105f79:	57                   	push   %edi
f0105f7a:	56                   	push   %esi
f0105f7b:	50                   	push   %eax
f0105f7c:	68 f0 7e 10 f0       	push   $0xf0107ef0
f0105f81:	e8 29 d9 ff ff       	call   f01038af <cprintf>
f0105f86:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105f89:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105f8c:	eb 61                	jmp    f0105fef <spin_unlock+0xa7>
	return lock->locked && lock->cpu == thiscpu;
f0105f8e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105f91:	e8 a5 fc ff ff       	call   f0105c3b <cpunum>
f0105f96:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f99:	05 20 40 21 f0       	add    $0xf0214020,%eax
	if (!holding(lk)) {
f0105f9e:	39 c3                	cmp    %eax,%ebx
f0105fa0:	75 b7                	jne    f0105f59 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0105fa2:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105fa9:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0105fb0:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fb5:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105fb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105fbb:	5b                   	pop    %ebx
f0105fbc:	5e                   	pop    %esi
f0105fbd:	5f                   	pop    %edi
f0105fbe:	5d                   	pop    %ebp
f0105fbf:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f0105fc0:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105fc2:	83 ec 04             	sub    $0x4,%esp
f0105fc5:	89 c2                	mov    %eax,%edx
f0105fc7:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105fca:	52                   	push   %edx
f0105fcb:	ff 75 b0             	pushl  -0x50(%ebp)
f0105fce:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105fd1:	ff 75 ac             	pushl  -0x54(%ebp)
f0105fd4:	ff 75 a8             	pushl  -0x58(%ebp)
f0105fd7:	50                   	push   %eax
f0105fd8:	68 38 7f 10 f0       	push   $0xf0107f38
f0105fdd:	e8 cd d8 ff ff       	call   f01038af <cprintf>
f0105fe2:	83 c4 20             	add    $0x20,%esp
f0105fe5:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105fe8:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105feb:	39 c3                	cmp    %eax,%ebx
f0105fed:	74 2d                	je     f010601c <spin_unlock+0xd4>
f0105fef:	89 de                	mov    %ebx,%esi
f0105ff1:	8b 03                	mov    (%ebx),%eax
f0105ff3:	85 c0                	test   %eax,%eax
f0105ff5:	74 25                	je     f010601c <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105ff7:	83 ec 08             	sub    $0x8,%esp
f0105ffa:	57                   	push   %edi
f0105ffb:	50                   	push   %eax
f0105ffc:	e8 93 eb ff ff       	call   f0104b94 <debuginfo_eip>
f0106001:	83 c4 10             	add    $0x10,%esp
f0106004:	85 c0                	test   %eax,%eax
f0106006:	79 b8                	jns    f0105fc0 <spin_unlock+0x78>
				cprintf("  %08x\n", pcs[i]);
f0106008:	83 ec 08             	sub    $0x8,%esp
f010600b:	ff 36                	pushl  (%esi)
f010600d:	68 4f 7f 10 f0       	push   $0xf0107f4f
f0106012:	e8 98 d8 ff ff       	call   f01038af <cprintf>
f0106017:	83 c4 10             	add    $0x10,%esp
f010601a:	eb c9                	jmp    f0105fe5 <spin_unlock+0x9d>
		panic("spin_unlock");
f010601c:	83 ec 04             	sub    $0x4,%esp
f010601f:	68 57 7f 10 f0       	push   $0xf0107f57
f0106024:	6a 67                	push   $0x67
f0106026:	68 28 7f 10 f0       	push   $0xf0107f28
f010602b:	e8 10 a0 ff ff       	call   f0100040 <_panic>

f0106030 <__udivdi3>:
f0106030:	55                   	push   %ebp
f0106031:	57                   	push   %edi
f0106032:	56                   	push   %esi
f0106033:	53                   	push   %ebx
f0106034:	83 ec 1c             	sub    $0x1c,%esp
f0106037:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010603b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010603f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106043:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0106047:	85 d2                	test   %edx,%edx
f0106049:	75 35                	jne    f0106080 <__udivdi3+0x50>
f010604b:	39 f3                	cmp    %esi,%ebx
f010604d:	0f 87 bd 00 00 00    	ja     f0106110 <__udivdi3+0xe0>
f0106053:	85 db                	test   %ebx,%ebx
f0106055:	89 d9                	mov    %ebx,%ecx
f0106057:	75 0b                	jne    f0106064 <__udivdi3+0x34>
f0106059:	b8 01 00 00 00       	mov    $0x1,%eax
f010605e:	31 d2                	xor    %edx,%edx
f0106060:	f7 f3                	div    %ebx
f0106062:	89 c1                	mov    %eax,%ecx
f0106064:	31 d2                	xor    %edx,%edx
f0106066:	89 f0                	mov    %esi,%eax
f0106068:	f7 f1                	div    %ecx
f010606a:	89 c6                	mov    %eax,%esi
f010606c:	89 e8                	mov    %ebp,%eax
f010606e:	89 f7                	mov    %esi,%edi
f0106070:	f7 f1                	div    %ecx
f0106072:	89 fa                	mov    %edi,%edx
f0106074:	83 c4 1c             	add    $0x1c,%esp
f0106077:	5b                   	pop    %ebx
f0106078:	5e                   	pop    %esi
f0106079:	5f                   	pop    %edi
f010607a:	5d                   	pop    %ebp
f010607b:	c3                   	ret    
f010607c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106080:	39 f2                	cmp    %esi,%edx
f0106082:	77 7c                	ja     f0106100 <__udivdi3+0xd0>
f0106084:	0f bd fa             	bsr    %edx,%edi
f0106087:	83 f7 1f             	xor    $0x1f,%edi
f010608a:	0f 84 98 00 00 00    	je     f0106128 <__udivdi3+0xf8>
f0106090:	89 f9                	mov    %edi,%ecx
f0106092:	b8 20 00 00 00       	mov    $0x20,%eax
f0106097:	29 f8                	sub    %edi,%eax
f0106099:	d3 e2                	shl    %cl,%edx
f010609b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010609f:	89 c1                	mov    %eax,%ecx
f01060a1:	89 da                	mov    %ebx,%edx
f01060a3:	d3 ea                	shr    %cl,%edx
f01060a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01060a9:	09 d1                	or     %edx,%ecx
f01060ab:	89 f2                	mov    %esi,%edx
f01060ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01060b1:	89 f9                	mov    %edi,%ecx
f01060b3:	d3 e3                	shl    %cl,%ebx
f01060b5:	89 c1                	mov    %eax,%ecx
f01060b7:	d3 ea                	shr    %cl,%edx
f01060b9:	89 f9                	mov    %edi,%ecx
f01060bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01060bf:	d3 e6                	shl    %cl,%esi
f01060c1:	89 eb                	mov    %ebp,%ebx
f01060c3:	89 c1                	mov    %eax,%ecx
f01060c5:	d3 eb                	shr    %cl,%ebx
f01060c7:	09 de                	or     %ebx,%esi
f01060c9:	89 f0                	mov    %esi,%eax
f01060cb:	f7 74 24 08          	divl   0x8(%esp)
f01060cf:	89 d6                	mov    %edx,%esi
f01060d1:	89 c3                	mov    %eax,%ebx
f01060d3:	f7 64 24 0c          	mull   0xc(%esp)
f01060d7:	39 d6                	cmp    %edx,%esi
f01060d9:	72 0c                	jb     f01060e7 <__udivdi3+0xb7>
f01060db:	89 f9                	mov    %edi,%ecx
f01060dd:	d3 e5                	shl    %cl,%ebp
f01060df:	39 c5                	cmp    %eax,%ebp
f01060e1:	73 5d                	jae    f0106140 <__udivdi3+0x110>
f01060e3:	39 d6                	cmp    %edx,%esi
f01060e5:	75 59                	jne    f0106140 <__udivdi3+0x110>
f01060e7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01060ea:	31 ff                	xor    %edi,%edi
f01060ec:	89 fa                	mov    %edi,%edx
f01060ee:	83 c4 1c             	add    $0x1c,%esp
f01060f1:	5b                   	pop    %ebx
f01060f2:	5e                   	pop    %esi
f01060f3:	5f                   	pop    %edi
f01060f4:	5d                   	pop    %ebp
f01060f5:	c3                   	ret    
f01060f6:	8d 76 00             	lea    0x0(%esi),%esi
f01060f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0106100:	31 ff                	xor    %edi,%edi
f0106102:	31 c0                	xor    %eax,%eax
f0106104:	89 fa                	mov    %edi,%edx
f0106106:	83 c4 1c             	add    $0x1c,%esp
f0106109:	5b                   	pop    %ebx
f010610a:	5e                   	pop    %esi
f010610b:	5f                   	pop    %edi
f010610c:	5d                   	pop    %ebp
f010610d:	c3                   	ret    
f010610e:	66 90                	xchg   %ax,%ax
f0106110:	31 ff                	xor    %edi,%edi
f0106112:	89 e8                	mov    %ebp,%eax
f0106114:	89 f2                	mov    %esi,%edx
f0106116:	f7 f3                	div    %ebx
f0106118:	89 fa                	mov    %edi,%edx
f010611a:	83 c4 1c             	add    $0x1c,%esp
f010611d:	5b                   	pop    %ebx
f010611e:	5e                   	pop    %esi
f010611f:	5f                   	pop    %edi
f0106120:	5d                   	pop    %ebp
f0106121:	c3                   	ret    
f0106122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106128:	39 f2                	cmp    %esi,%edx
f010612a:	72 06                	jb     f0106132 <__udivdi3+0x102>
f010612c:	31 c0                	xor    %eax,%eax
f010612e:	39 eb                	cmp    %ebp,%ebx
f0106130:	77 d2                	ja     f0106104 <__udivdi3+0xd4>
f0106132:	b8 01 00 00 00       	mov    $0x1,%eax
f0106137:	eb cb                	jmp    f0106104 <__udivdi3+0xd4>
f0106139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106140:	89 d8                	mov    %ebx,%eax
f0106142:	31 ff                	xor    %edi,%edi
f0106144:	eb be                	jmp    f0106104 <__udivdi3+0xd4>
f0106146:	66 90                	xchg   %ax,%ax
f0106148:	66 90                	xchg   %ax,%ax
f010614a:	66 90                	xchg   %ax,%ax
f010614c:	66 90                	xchg   %ax,%ax
f010614e:	66 90                	xchg   %ax,%ax

f0106150 <__umoddi3>:
f0106150:	55                   	push   %ebp
f0106151:	57                   	push   %edi
f0106152:	56                   	push   %esi
f0106153:	53                   	push   %ebx
f0106154:	83 ec 1c             	sub    $0x1c,%esp
f0106157:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010615b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010615f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106163:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106167:	85 ed                	test   %ebp,%ebp
f0106169:	89 f0                	mov    %esi,%eax
f010616b:	89 da                	mov    %ebx,%edx
f010616d:	75 19                	jne    f0106188 <__umoddi3+0x38>
f010616f:	39 df                	cmp    %ebx,%edi
f0106171:	0f 86 b1 00 00 00    	jbe    f0106228 <__umoddi3+0xd8>
f0106177:	f7 f7                	div    %edi
f0106179:	89 d0                	mov    %edx,%eax
f010617b:	31 d2                	xor    %edx,%edx
f010617d:	83 c4 1c             	add    $0x1c,%esp
f0106180:	5b                   	pop    %ebx
f0106181:	5e                   	pop    %esi
f0106182:	5f                   	pop    %edi
f0106183:	5d                   	pop    %ebp
f0106184:	c3                   	ret    
f0106185:	8d 76 00             	lea    0x0(%esi),%esi
f0106188:	39 dd                	cmp    %ebx,%ebp
f010618a:	77 f1                	ja     f010617d <__umoddi3+0x2d>
f010618c:	0f bd cd             	bsr    %ebp,%ecx
f010618f:	83 f1 1f             	xor    $0x1f,%ecx
f0106192:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106196:	0f 84 b4 00 00 00    	je     f0106250 <__umoddi3+0x100>
f010619c:	b8 20 00 00 00       	mov    $0x20,%eax
f01061a1:	89 c2                	mov    %eax,%edx
f01061a3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01061a7:	29 c2                	sub    %eax,%edx
f01061a9:	89 c1                	mov    %eax,%ecx
f01061ab:	89 f8                	mov    %edi,%eax
f01061ad:	d3 e5                	shl    %cl,%ebp
f01061af:	89 d1                	mov    %edx,%ecx
f01061b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01061b5:	d3 e8                	shr    %cl,%eax
f01061b7:	09 c5                	or     %eax,%ebp
f01061b9:	8b 44 24 04          	mov    0x4(%esp),%eax
f01061bd:	89 c1                	mov    %eax,%ecx
f01061bf:	d3 e7                	shl    %cl,%edi
f01061c1:	89 d1                	mov    %edx,%ecx
f01061c3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01061c7:	89 df                	mov    %ebx,%edi
f01061c9:	d3 ef                	shr    %cl,%edi
f01061cb:	89 c1                	mov    %eax,%ecx
f01061cd:	89 f0                	mov    %esi,%eax
f01061cf:	d3 e3                	shl    %cl,%ebx
f01061d1:	89 d1                	mov    %edx,%ecx
f01061d3:	89 fa                	mov    %edi,%edx
f01061d5:	d3 e8                	shr    %cl,%eax
f01061d7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01061dc:	09 d8                	or     %ebx,%eax
f01061de:	f7 f5                	div    %ebp
f01061e0:	d3 e6                	shl    %cl,%esi
f01061e2:	89 d1                	mov    %edx,%ecx
f01061e4:	f7 64 24 08          	mull   0x8(%esp)
f01061e8:	39 d1                	cmp    %edx,%ecx
f01061ea:	89 c3                	mov    %eax,%ebx
f01061ec:	89 d7                	mov    %edx,%edi
f01061ee:	72 06                	jb     f01061f6 <__umoddi3+0xa6>
f01061f0:	75 0e                	jne    f0106200 <__umoddi3+0xb0>
f01061f2:	39 c6                	cmp    %eax,%esi
f01061f4:	73 0a                	jae    f0106200 <__umoddi3+0xb0>
f01061f6:	2b 44 24 08          	sub    0x8(%esp),%eax
f01061fa:	19 ea                	sbb    %ebp,%edx
f01061fc:	89 d7                	mov    %edx,%edi
f01061fe:	89 c3                	mov    %eax,%ebx
f0106200:	89 ca                	mov    %ecx,%edx
f0106202:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0106207:	29 de                	sub    %ebx,%esi
f0106209:	19 fa                	sbb    %edi,%edx
f010620b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010620f:	89 d0                	mov    %edx,%eax
f0106211:	d3 e0                	shl    %cl,%eax
f0106213:	89 d9                	mov    %ebx,%ecx
f0106215:	d3 ee                	shr    %cl,%esi
f0106217:	d3 ea                	shr    %cl,%edx
f0106219:	09 f0                	or     %esi,%eax
f010621b:	83 c4 1c             	add    $0x1c,%esp
f010621e:	5b                   	pop    %ebx
f010621f:	5e                   	pop    %esi
f0106220:	5f                   	pop    %edi
f0106221:	5d                   	pop    %ebp
f0106222:	c3                   	ret    
f0106223:	90                   	nop
f0106224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106228:	85 ff                	test   %edi,%edi
f010622a:	89 f9                	mov    %edi,%ecx
f010622c:	75 0b                	jne    f0106239 <__umoddi3+0xe9>
f010622e:	b8 01 00 00 00       	mov    $0x1,%eax
f0106233:	31 d2                	xor    %edx,%edx
f0106235:	f7 f7                	div    %edi
f0106237:	89 c1                	mov    %eax,%ecx
f0106239:	89 d8                	mov    %ebx,%eax
f010623b:	31 d2                	xor    %edx,%edx
f010623d:	f7 f1                	div    %ecx
f010623f:	89 f0                	mov    %esi,%eax
f0106241:	f7 f1                	div    %ecx
f0106243:	e9 31 ff ff ff       	jmp    f0106179 <__umoddi3+0x29>
f0106248:	90                   	nop
f0106249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106250:	39 dd                	cmp    %ebx,%ebp
f0106252:	72 08                	jb     f010625c <__umoddi3+0x10c>
f0106254:	39 f7                	cmp    %esi,%edi
f0106256:	0f 87 21 ff ff ff    	ja     f010617d <__umoddi3+0x2d>
f010625c:	89 da                	mov    %ebx,%edx
f010625e:	89 f0                	mov    %esi,%eax
f0106260:	29 f8                	sub    %edi,%eax
f0106262:	19 ea                	sbb    %ebp,%edx
f0106264:	e9 14 ff ff ff       	jmp    f010617d <__umoddi3+0x2d>
