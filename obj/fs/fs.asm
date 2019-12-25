
obj/fs/fs：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 8c 1a 00 00       	call   801abd <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800075:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800086:	a8 a1                	test   $0xa1,%al
  800088:	74 0b                	je     800095 <ide_probe_disk1+0x36>
	     x++)
  80008a:	83 c1 01             	add    $0x1,%ecx
	for (x = 0;
  80008d:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800093:	75 f0                	jne    800085 <ide_probe_disk1+0x26>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800095:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80009a:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009f:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a0:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a6:	0f 9e c3             	setle  %bl
  8000a9:	83 ec 08             	sub    $0x8,%esp
  8000ac:	0f b6 c3             	movzbl %bl,%eax
  8000af:	50                   	push   %eax
  8000b0:	68 c0 38 80 00       	push   $0x8038c0
  8000b5:	e8 3e 1b 00 00       	call   801bf8 <cprintf>
	return (x < 1000);
}
  8000ba:	89 d8                	mov    %ebx,%eax
  8000bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    

008000c1 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
  8000c7:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000ca:	83 f8 01             	cmp    $0x1,%eax
  8000cd:	77 07                	ja     8000d6 <ide_set_disk+0x15>
		panic("bad disk number");
	diskno = d;
  8000cf:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    
		panic("bad disk number");
  8000d6:	83 ec 04             	sub    $0x4,%esp
  8000d9:	68 d7 38 80 00       	push   $0x8038d7
  8000de:	6a 3a                	push   $0x3a
  8000e0:	68 e7 38 80 00       	push   $0x8038e7
  8000e5:	e8 33 1a 00 00       	call   801b1d <_panic>

008000ea <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fc:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800102:	0f 87 87 00 00 00    	ja     80018f <ide_read+0xa5>

	ide_wait_ready(0);
  800108:	b8 00 00 00 00       	mov    $0x0,%eax
  80010d:	e8 21 ff ff ff       	call   800033 <ide_wait_ready>
  800112:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800117:	89 f0                	mov    %esi,%eax
  800119:	ee                   	out    %al,(%dx)
  80011a:	ba f3 01 00 00       	mov    $0x1f3,%edx
  80011f:	89 f8                	mov    %edi,%eax
  800121:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  800122:	89 f8                	mov    %edi,%eax
  800124:	c1 e8 08             	shr    $0x8,%eax
  800127:	ba f4 01 00 00       	mov    $0x1f4,%edx
  80012c:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  80012d:	89 f8                	mov    %edi,%eax
  80012f:	c1 e8 10             	shr    $0x10,%eax
  800132:	ba f5 01 00 00       	mov    $0x1f5,%edx
  800137:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800138:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  80013f:	c1 e0 04             	shl    $0x4,%eax
  800142:	83 e0 10             	and    $0x10,%eax
  800145:	83 c8 e0             	or     $0xffffffe0,%eax
  800148:	c1 ef 18             	shr    $0x18,%edi
  80014b:	83 e7 0f             	and    $0xf,%edi
  80014e:	09 f8                	or     %edi,%eax
  800150:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800155:	ee                   	out    %al,(%dx)
  800156:	b8 20 00 00 00       	mov    $0x20,%eax
  80015b:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800160:	ee                   	out    %al,(%dx)
  800161:	c1 e6 09             	shl    $0x9,%esi
  800164:	01 de                	add    %ebx,%esi
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800166:	39 f3                	cmp    %esi,%ebx
  800168:	74 3b                	je     8001a5 <ide_read+0xbb>
		if ((r = ide_wait_ready(1)) < 0)
  80016a:	b8 01 00 00 00       	mov    $0x1,%eax
  80016f:	e8 bf fe ff ff       	call   800033 <ide_wait_ready>
  800174:	85 c0                	test   %eax,%eax
  800176:	78 32                	js     8001aa <ide_read+0xc0>
	asm volatile("cld\n\trepne\n\tinsl"
  800178:	89 df                	mov    %ebx,%edi
  80017a:	b9 80 00 00 00       	mov    $0x80,%ecx
  80017f:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800184:	fc                   	cld    
  800185:	f2 6d                	repnz insl (%dx),%es:(%edi)
	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800187:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80018d:	eb d7                	jmp    800166 <ide_read+0x7c>
	assert(nsecs <= 256);
  80018f:	68 f0 38 80 00       	push   $0x8038f0
  800194:	68 fd 38 80 00       	push   $0x8038fd
  800199:	6a 44                	push   $0x44
  80019b:	68 e7 38 80 00       	push   $0x8038e7
  8001a0:	e8 78 19 00 00       	call   801b1d <_panic>
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ad:	5b                   	pop    %ebx
  8001ae:	5e                   	pop    %esi
  8001af:	5f                   	pop    %edi
  8001b0:	5d                   	pop    %ebp
  8001b1:	c3                   	ret    

008001b2 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	57                   	push   %edi
  8001b6:	56                   	push   %esi
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001c1:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c4:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001ca:	0f 87 87 00 00 00    	ja     800257 <ide_write+0xa5>

	ide_wait_ready(0);
  8001d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d5:	e8 59 fe ff ff       	call   800033 <ide_wait_ready>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001da:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001df:	89 f8                	mov    %edi,%eax
  8001e1:	ee                   	out    %al,(%dx)
  8001e2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001e7:	89 f0                	mov    %esi,%eax
  8001e9:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  8001ea:	89 f0                	mov    %esi,%eax
  8001ec:	c1 e8 08             	shr    $0x8,%eax
  8001ef:	ba f4 01 00 00       	mov    $0x1f4,%edx
  8001f4:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  8001f5:	89 f0                	mov    %esi,%eax
  8001f7:	c1 e8 10             	shr    $0x10,%eax
  8001fa:	ba f5 01 00 00       	mov    $0x1f5,%edx
  8001ff:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800200:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800207:	c1 e0 04             	shl    $0x4,%eax
  80020a:	83 e0 10             	and    $0x10,%eax
  80020d:	83 c8 e0             	or     $0xffffffe0,%eax
  800210:	c1 ee 18             	shr    $0x18,%esi
  800213:	83 e6 0f             	and    $0xf,%esi
  800216:	09 f0                	or     %esi,%eax
  800218:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80021d:	ee                   	out    %al,(%dx)
  80021e:	b8 30 00 00 00       	mov    $0x30,%eax
  800223:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800228:	ee                   	out    %al,(%dx)
  800229:	c1 e7 09             	shl    $0x9,%edi
  80022c:	01 df                	add    %ebx,%edi
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80022e:	39 fb                	cmp    %edi,%ebx
  800230:	74 3b                	je     80026d <ide_write+0xbb>
		if ((r = ide_wait_ready(1)) < 0)
  800232:	b8 01 00 00 00       	mov    $0x1,%eax
  800237:	e8 f7 fd ff ff       	call   800033 <ide_wait_ready>
  80023c:	85 c0                	test   %eax,%eax
  80023e:	78 32                	js     800272 <ide_write+0xc0>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  800240:	89 de                	mov    %ebx,%esi
  800242:	b9 80 00 00 00       	mov    $0x80,%ecx
  800247:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80024c:	fc                   	cld    
  80024d:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80024f:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800255:	eb d7                	jmp    80022e <ide_write+0x7c>
	assert(nsecs <= 256);
  800257:	68 f0 38 80 00       	push   $0x8038f0
  80025c:	68 fd 38 80 00       	push   $0x8038fd
  800261:	6a 5d                	push   $0x5d
  800263:	68 e7 38 80 00       	push   $0x8038e7
  800268:	e8 b0 18 00 00       	call   801b1d <_panic>
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  80026d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800272:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800282:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800284:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80028a:	89 c6                	mov    %eax,%esi
  80028c:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80028f:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800294:	0f 87 86 00 00 00    	ja     800320 <bc_pgfault+0xa6>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  80029a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80029f:	85 c0                	test   %eax,%eax
  8002a1:	74 09                	je     8002ac <bc_pgfault+0x32>
  8002a3:	39 70 04             	cmp    %esi,0x4(%eax)
  8002a6:	0f 86 8f 00 00 00    	jbe    80033b <bc_pgfault+0xc1>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
   	addr = ROUNDDOWN(addr, PGSIZE);
  8002ac:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	sys_page_alloc(0, addr, PTE_W|PTE_U|PTE_P);
  8002b2:	83 ec 04             	sub    $0x4,%esp
  8002b5:	6a 07                	push   $0x7
  8002b7:	53                   	push   %ebx
  8002b8:	6a 00                	push   $0x0
  8002ba:	e8 51 23 00 00       	call   802610 <sys_page_alloc>
    	if ((r = ide_read(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
  8002bf:	83 c4 0c             	add    $0xc,%esp
  8002c2:	6a 08                	push   $0x8
  8002c4:	53                   	push   %ebx
  8002c5:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  8002cc:	50                   	push   %eax
  8002cd:	e8 18 fe ff ff       	call   8000ea <ide_read>
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	78 74                	js     80034d <bc_pgfault+0xd3>
        	panic("ide_read: %e", r);
	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  8002d9:	89 d8                	mov    %ebx,%eax
  8002db:	c1 e8 0c             	shr    $0xc,%eax
  8002de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8002ed:	50                   	push   %eax
  8002ee:	53                   	push   %ebx
  8002ef:	6a 00                	push   $0x0
  8002f1:	53                   	push   %ebx
  8002f2:	6a 00                	push   $0x0
  8002f4:	e8 5a 23 00 00       	call   802653 <sys_page_map>
  8002f9:	83 c4 20             	add    $0x20,%esp
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	78 5f                	js     80035f <bc_pgfault+0xe5>
		panic("in bc_pgfault, sys_page_map: %e", r);

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800300:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800307:	74 10                	je     800319 <bc_pgfault+0x9f>
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	56                   	push   %esi
  80030d:	e8 fb 04 00 00       	call   80080d <block_is_free>
  800312:	83 c4 10             	add    $0x10,%esp
  800315:	84 c0                	test   %al,%al
  800317:	75 58                	jne    800371 <bc_pgfault+0xf7>
		panic("reading free block %08x\n", blockno);
}
  800319:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800320:	83 ec 08             	sub    $0x8,%esp
  800323:	ff 72 04             	pushl  0x4(%edx)
  800326:	53                   	push   %ebx
  800327:	ff 72 28             	pushl  0x28(%edx)
  80032a:	68 14 39 80 00       	push   $0x803914
  80032f:	6a 27                	push   $0x27
  800331:	68 f0 39 80 00       	push   $0x8039f0
  800336:	e8 e2 17 00 00       	call   801b1d <_panic>
		panic("reading non-existent block %08x\n", blockno);
  80033b:	56                   	push   %esi
  80033c:	68 44 39 80 00       	push   $0x803944
  800341:	6a 2b                	push   $0x2b
  800343:	68 f0 39 80 00       	push   $0x8039f0
  800348:	e8 d0 17 00 00       	call   801b1d <_panic>
        	panic("ide_read: %e", r);
  80034d:	50                   	push   %eax
  80034e:	68 f8 39 80 00       	push   $0x8039f8
  800353:	6a 36                	push   $0x36
  800355:	68 f0 39 80 00       	push   $0x8039f0
  80035a:	e8 be 17 00 00       	call   801b1d <_panic>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80035f:	50                   	push   %eax
  800360:	68 68 39 80 00       	push   $0x803968
  800365:	6a 3a                	push   $0x3a
  800367:	68 f0 39 80 00       	push   $0x8039f0
  80036c:	e8 ac 17 00 00       	call   801b1d <_panic>
		panic("reading free block %08x\n", blockno);
  800371:	56                   	push   %esi
  800372:	68 05 3a 80 00       	push   $0x803a05
  800377:	6a 40                	push   $0x40
  800379:	68 f0 39 80 00       	push   $0x8039f0
  80037e:	e8 9a 17 00 00       	call   801b1d <_panic>

00800383 <diskaddr>:
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80038c:	85 c0                	test   %eax,%eax
  80038e:	74 19                	je     8003a9 <diskaddr+0x26>
  800390:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800396:	85 d2                	test   %edx,%edx
  800398:	74 05                	je     80039f <diskaddr+0x1c>
  80039a:	39 42 04             	cmp    %eax,0x4(%edx)
  80039d:	76 0a                	jbe    8003a9 <diskaddr+0x26>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  80039f:	05 00 00 01 00       	add    $0x10000,%eax
  8003a4:	c1 e0 0c             	shl    $0xc,%eax
}
  8003a7:	c9                   	leave  
  8003a8:	c3                   	ret    
		panic("bad block number %08x in diskaddr", blockno);
  8003a9:	50                   	push   %eax
  8003aa:	68 88 39 80 00       	push   $0x803988
  8003af:	6a 09                	push   $0x9
  8003b1:	68 f0 39 80 00       	push   $0x8039f0
  8003b6:	e8 62 17 00 00       	call   801b1d <_panic>

008003bb <va_is_mapped>:
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003c1:	89 d0                	mov    %edx,%eax
  8003c3:	c1 e8 16             	shr    $0x16,%eax
  8003c6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d2:	f6 c1 01             	test   $0x1,%cl
  8003d5:	74 0d                	je     8003e4 <va_is_mapped+0x29>
  8003d7:	c1 ea 0c             	shr    $0xc,%edx
  8003da:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003e1:	83 e0 01             	and    $0x1,%eax
  8003e4:	83 e0 01             	and    $0x1,%eax
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <va_is_dirty>:
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ef:	c1 e8 0c             	shr    $0xc,%eax
  8003f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003f9:	c1 e8 06             	shr    $0x6,%eax
  8003fc:	83 e0 01             	and    $0x1,%eax
}
  8003ff:	5d                   	pop    %ebp
  800400:	c3                   	ret    

00800401 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	56                   	push   %esi
  800405:	53                   	push   %ebx
  800406:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
    	int r;
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800409:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80040f:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800414:	77 1f                	ja     800435 <flush_block+0x34>
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800416:	89 de                	mov    %ebx,%esi
  800418:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    	if (!va_is_mapped(addr) || !va_is_dirty(addr)) {
  80041e:	83 ec 0c             	sub    $0xc,%esp
  800421:	56                   	push   %esi
  800422:	e8 94 ff ff ff       	call   8003bb <va_is_mapped>
  800427:	83 c4 10             	add    $0x10,%esp
  80042a:	84 c0                	test   %al,%al
  80042c:	75 19                	jne    800447 <flush_block+0x46>
    	if ((r = ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0) {
        	panic("in flush_block, ide_write(): %e", r);
    	}
    	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
        	panic("in bc_pgfault, sys_page_map: %e", r);
}
  80042e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800431:	5b                   	pop    %ebx
  800432:	5e                   	pop    %esi
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    
		panic("flush_block of bad va %08x", addr);
  800435:	53                   	push   %ebx
  800436:	68 1e 3a 80 00       	push   $0x803a1e
  80043b:	6a 50                	push   $0x50
  80043d:	68 f0 39 80 00       	push   $0x8039f0
  800442:	e8 d6 16 00 00       	call   801b1d <_panic>
    	if (!va_is_mapped(addr) || !va_is_dirty(addr)) {
  800447:	83 ec 0c             	sub    $0xc,%esp
  80044a:	56                   	push   %esi
  80044b:	e8 99 ff ff ff       	call   8003e9 <va_is_dirty>
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	84 c0                	test   %al,%al
  800455:	74 d7                	je     80042e <flush_block+0x2d>
    	if ((r = ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0) {
  800457:	83 ec 04             	sub    $0x4,%esp
  80045a:	6a 08                	push   $0x8
  80045c:	56                   	push   %esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80045d:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  800463:	c1 eb 0c             	shr    $0xc,%ebx
    	if ((r = ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0) {
  800466:	c1 e3 03             	shl    $0x3,%ebx
  800469:	53                   	push   %ebx
  80046a:	e8 43 fd ff ff       	call   8001b2 <ide_write>
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	85 c0                	test   %eax,%eax
  800474:	78 39                	js     8004af <flush_block+0xae>
    	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800476:	89 f0                	mov    %esi,%eax
  800478:	c1 e8 0c             	shr    $0xc,%eax
  80047b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800482:	83 ec 0c             	sub    $0xc,%esp
  800485:	25 07 0e 00 00       	and    $0xe07,%eax
  80048a:	50                   	push   %eax
  80048b:	56                   	push   %esi
  80048c:	6a 00                	push   $0x0
  80048e:	56                   	push   %esi
  80048f:	6a 00                	push   $0x0
  800491:	e8 bd 21 00 00       	call   802653 <sys_page_map>
  800496:	83 c4 20             	add    $0x20,%esp
  800499:	85 c0                	test   %eax,%eax
  80049b:	79 91                	jns    80042e <flush_block+0x2d>
        	panic("in bc_pgfault, sys_page_map: %e", r);
  80049d:	50                   	push   %eax
  80049e:	68 68 39 80 00       	push   $0x803968
  8004a3:	6a 5b                	push   $0x5b
  8004a5:	68 f0 39 80 00       	push   $0x8039f0
  8004aa:	e8 6e 16 00 00       	call   801b1d <_panic>
        	panic("in flush_block, ide_write(): %e", r);
  8004af:	50                   	push   %eax
  8004b0:	68 ac 39 80 00       	push   $0x8039ac
  8004b5:	6a 58                	push   $0x58
  8004b7:	68 f0 39 80 00       	push   $0x8039f0
  8004bc:	e8 5c 16 00 00       	call   801b1d <_panic>

008004c1 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	53                   	push   %ebx
  8004c5:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004cb:	68 7a 02 80 00       	push   $0x80027a
  8004d0:	e8 2c 23 00 00       	call   802801 <set_pgfault_handler>
	memmove(&backup, diskaddr(1), sizeof backup);
  8004d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004dc:	e8 a2 fe ff ff       	call   800383 <diskaddr>
  8004e1:	83 c4 0c             	add    $0xc,%esp
  8004e4:	68 08 01 00 00       	push   $0x108
  8004e9:	50                   	push   %eax
  8004ea:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	e8 af 1e 00 00       	call   8023a5 <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  8004f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004fd:	e8 81 fe ff ff       	call   800383 <diskaddr>
  800502:	83 c4 08             	add    $0x8,%esp
  800505:	68 39 3a 80 00       	push   $0x803a39
  80050a:	50                   	push   %eax
  80050b:	e8 07 1d 00 00       	call   802217 <strcpy>
	flush_block(diskaddr(1));
  800510:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800517:	e8 67 fe ff ff       	call   800383 <diskaddr>
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	e8 dd fe ff ff       	call   800401 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800524:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80052b:	e8 53 fe ff ff       	call   800383 <diskaddr>
  800530:	89 04 24             	mov    %eax,(%esp)
  800533:	e8 83 fe ff ff       	call   8003bb <va_is_mapped>
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	84 c0                	test   %al,%al
  80053d:	0f 84 d1 01 00 00    	je     800714 <bc_init+0x253>
	assert(!va_is_dirty(diskaddr(1)));
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	6a 01                	push   $0x1
  800548:	e8 36 fe ff ff       	call   800383 <diskaddr>
  80054d:	89 04 24             	mov    %eax,(%esp)
  800550:	e8 94 fe ff ff       	call   8003e9 <va_is_dirty>
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	84 c0                	test   %al,%al
  80055a:	0f 85 ca 01 00 00    	jne    80072a <bc_init+0x269>
	sys_page_unmap(0, diskaddr(1));
  800560:	83 ec 0c             	sub    $0xc,%esp
  800563:	6a 01                	push   $0x1
  800565:	e8 19 fe ff ff       	call   800383 <diskaddr>
  80056a:	83 c4 08             	add    $0x8,%esp
  80056d:	50                   	push   %eax
  80056e:	6a 00                	push   $0x0
  800570:	e8 20 21 00 00       	call   802695 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800575:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80057c:	e8 02 fe ff ff       	call   800383 <diskaddr>
  800581:	89 04 24             	mov    %eax,(%esp)
  800584:	e8 32 fe ff ff       	call   8003bb <va_is_mapped>
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	84 c0                	test   %al,%al
  80058e:	0f 85 ac 01 00 00    	jne    800740 <bc_init+0x27f>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800594:	83 ec 0c             	sub    $0xc,%esp
  800597:	6a 01                	push   $0x1
  800599:	e8 e5 fd ff ff       	call   800383 <diskaddr>
  80059e:	83 c4 08             	add    $0x8,%esp
  8005a1:	68 39 3a 80 00       	push   $0x803a39
  8005a6:	50                   	push   %eax
  8005a7:	e8 11 1d 00 00       	call   8022bd <strcmp>
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	0f 85 9f 01 00 00    	jne    800756 <bc_init+0x295>
	memmove(diskaddr(1), &backup, sizeof backup);
  8005b7:	83 ec 0c             	sub    $0xc,%esp
  8005ba:	6a 01                	push   $0x1
  8005bc:	e8 c2 fd ff ff       	call   800383 <diskaddr>
  8005c1:	83 c4 0c             	add    $0xc,%esp
  8005c4:	68 08 01 00 00       	push   $0x108
  8005c9:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  8005cf:	53                   	push   %ebx
  8005d0:	50                   	push   %eax
  8005d1:	e8 cf 1d 00 00       	call   8023a5 <memmove>
	flush_block(diskaddr(1));
  8005d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005dd:	e8 a1 fd ff ff       	call   800383 <diskaddr>
  8005e2:	89 04 24             	mov    %eax,(%esp)
  8005e5:	e8 17 fe ff ff       	call   800401 <flush_block>
	memmove(&backup, diskaddr(1), sizeof backup);
  8005ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005f1:	e8 8d fd ff ff       	call   800383 <diskaddr>
  8005f6:	83 c4 0c             	add    $0xc,%esp
  8005f9:	68 08 01 00 00       	push   $0x108
  8005fe:	50                   	push   %eax
  8005ff:	53                   	push   %ebx
  800600:	e8 a0 1d 00 00       	call   8023a5 <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  800605:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80060c:	e8 72 fd ff ff       	call   800383 <diskaddr>
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	68 39 3a 80 00       	push   $0x803a39
  800619:	50                   	push   %eax
  80061a:	e8 f8 1b 00 00       	call   802217 <strcpy>
	flush_block(diskaddr(1) + 20);
  80061f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800626:	e8 58 fd ff ff       	call   800383 <diskaddr>
  80062b:	83 c0 14             	add    $0x14,%eax
  80062e:	89 04 24             	mov    %eax,(%esp)
  800631:	e8 cb fd ff ff       	call   800401 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800636:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80063d:	e8 41 fd ff ff       	call   800383 <diskaddr>
  800642:	89 04 24             	mov    %eax,(%esp)
  800645:	e8 71 fd ff ff       	call   8003bb <va_is_mapped>
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	84 c0                	test   %al,%al
  80064f:	0f 84 17 01 00 00    	je     80076c <bc_init+0x2ab>
	sys_page_unmap(0, diskaddr(1));
  800655:	83 ec 0c             	sub    $0xc,%esp
  800658:	6a 01                	push   $0x1
  80065a:	e8 24 fd ff ff       	call   800383 <diskaddr>
  80065f:	83 c4 08             	add    $0x8,%esp
  800662:	50                   	push   %eax
  800663:	6a 00                	push   $0x0
  800665:	e8 2b 20 00 00       	call   802695 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80066a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800671:	e8 0d fd ff ff       	call   800383 <diskaddr>
  800676:	89 04 24             	mov    %eax,(%esp)
  800679:	e8 3d fd ff ff       	call   8003bb <va_is_mapped>
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	84 c0                	test   %al,%al
  800683:	0f 85 fc 00 00 00    	jne    800785 <bc_init+0x2c4>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800689:	83 ec 0c             	sub    $0xc,%esp
  80068c:	6a 01                	push   $0x1
  80068e:	e8 f0 fc ff ff       	call   800383 <diskaddr>
  800693:	83 c4 08             	add    $0x8,%esp
  800696:	68 39 3a 80 00       	push   $0x803a39
  80069b:	50                   	push   %eax
  80069c:	e8 1c 1c 00 00       	call   8022bd <strcmp>
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	85 c0                	test   %eax,%eax
  8006a6:	0f 85 f2 00 00 00    	jne    80079e <bc_init+0x2dd>
	memmove(diskaddr(1), &backup, sizeof backup);
  8006ac:	83 ec 0c             	sub    $0xc,%esp
  8006af:	6a 01                	push   $0x1
  8006b1:	e8 cd fc ff ff       	call   800383 <diskaddr>
  8006b6:	83 c4 0c             	add    $0xc,%esp
  8006b9:	68 08 01 00 00       	push   $0x108
  8006be:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8006c4:	52                   	push   %edx
  8006c5:	50                   	push   %eax
  8006c6:	e8 da 1c 00 00       	call   8023a5 <memmove>
	flush_block(diskaddr(1));
  8006cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006d2:	e8 ac fc ff ff       	call   800383 <diskaddr>
  8006d7:	89 04 24             	mov    %eax,(%esp)
  8006da:	e8 22 fd ff ff       	call   800401 <flush_block>
	cprintf("block cache is good\n");
  8006df:	c7 04 24 75 3a 80 00 	movl   $0x803a75,(%esp)
  8006e6:	e8 0d 15 00 00       	call   801bf8 <cprintf>
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  8006eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006f2:	e8 8c fc ff ff       	call   800383 <diskaddr>
  8006f7:	83 c4 0c             	add    $0xc,%esp
  8006fa:	68 08 01 00 00       	push   $0x108
  8006ff:	50                   	push   %eax
  800700:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	e8 99 1c 00 00       	call   8023a5 <memmove>
}
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800712:	c9                   	leave  
  800713:	c3                   	ret    
	assert(va_is_mapped(diskaddr(1)));
  800714:	68 5b 3a 80 00       	push   $0x803a5b
  800719:	68 fd 38 80 00       	push   $0x8038fd
  80071e:	6a 6b                	push   $0x6b
  800720:	68 f0 39 80 00       	push   $0x8039f0
  800725:	e8 f3 13 00 00       	call   801b1d <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  80072a:	68 40 3a 80 00       	push   $0x803a40
  80072f:	68 fd 38 80 00       	push   $0x8038fd
  800734:	6a 6c                	push   $0x6c
  800736:	68 f0 39 80 00       	push   $0x8039f0
  80073b:	e8 dd 13 00 00       	call   801b1d <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  800740:	68 5a 3a 80 00       	push   $0x803a5a
  800745:	68 fd 38 80 00       	push   $0x8038fd
  80074a:	6a 70                	push   $0x70
  80074c:	68 f0 39 80 00       	push   $0x8039f0
  800751:	e8 c7 13 00 00       	call   801b1d <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800756:	68 cc 39 80 00       	push   $0x8039cc
  80075b:	68 fd 38 80 00       	push   $0x8038fd
  800760:	6a 73                	push   $0x73
  800762:	68 f0 39 80 00       	push   $0x8039f0
  800767:	e8 b1 13 00 00       	call   801b1d <_panic>
	assert(va_is_mapped(diskaddr(1)));
  80076c:	68 5b 3a 80 00       	push   $0x803a5b
  800771:	68 fd 38 80 00       	push   $0x8038fd
  800776:	68 84 00 00 00       	push   $0x84
  80077b:	68 f0 39 80 00       	push   $0x8039f0
  800780:	e8 98 13 00 00       	call   801b1d <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  800785:	68 5a 3a 80 00       	push   $0x803a5a
  80078a:	68 fd 38 80 00       	push   $0x8038fd
  80078f:	68 8c 00 00 00       	push   $0x8c
  800794:	68 f0 39 80 00       	push   $0x8039f0
  800799:	e8 7f 13 00 00       	call   801b1d <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  80079e:	68 cc 39 80 00       	push   $0x8039cc
  8007a3:	68 fd 38 80 00       	push   $0x8038fd
  8007a8:	68 8f 00 00 00       	push   $0x8f
  8007ad:	68 f0 39 80 00       	push   $0x8039f0
  8007b2:	e8 66 13 00 00       	call   801b1d <_panic>

008007b7 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  8007bd:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007c2:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8007c8:	75 1b                	jne    8007e5 <check_super+0x2e>
		panic("bad file system magic number");

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007ca:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007d1:	77 26                	ja     8007f9 <check_super+0x42>
		panic("file system is too large");

	cprintf("superblock is good\n");
  8007d3:	83 ec 0c             	sub    $0xc,%esp
  8007d6:	68 c8 3a 80 00       	push   $0x803ac8
  8007db:	e8 18 14 00 00       	call   801bf8 <cprintf>
}
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    
		panic("bad file system magic number");
  8007e5:	83 ec 04             	sub    $0x4,%esp
  8007e8:	68 8a 3a 80 00       	push   $0x803a8a
  8007ed:	6a 0f                	push   $0xf
  8007ef:	68 a7 3a 80 00       	push   $0x803aa7
  8007f4:	e8 24 13 00 00       	call   801b1d <_panic>
		panic("file system is too large");
  8007f9:	83 ec 04             	sub    $0x4,%esp
  8007fc:	68 af 3a 80 00       	push   $0x803aaf
  800801:	6a 12                	push   $0x12
  800803:	68 a7 3a 80 00       	push   $0x803aa7
  800808:	e8 10 13 00 00       	call   801b1d <_panic>

0080080d <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	53                   	push   %ebx
  800811:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  800814:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
		return 0;
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (super == 0 || blockno >= super->s_nblocks)
  80081f:	85 d2                	test   %edx,%edx
  800821:	74 1d                	je     800840 <block_is_free+0x33>
  800823:	39 4a 04             	cmp    %ecx,0x4(%edx)
  800826:	76 18                	jbe    800840 <block_is_free+0x33>
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  800828:	89 cb                	mov    %ecx,%ebx
  80082a:	c1 eb 05             	shr    $0x5,%ebx
  80082d:	b8 01 00 00 00       	mov    $0x1,%eax
  800832:	d3 e0                	shl    %cl,%eax
  800834:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80083a:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  80083d:	0f 95 c0             	setne  %al
		return 1;
	return 0;
}
  800840:	5b                   	pop    %ebx
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	83 ec 04             	sub    $0x4,%esp
  80084a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80084d:	85 c9                	test   %ecx,%ecx
  80084f:	74 1a                	je     80086b <free_block+0x28>
		panic("attempt to free zero block");
	bitmap[blockno/32] |= 1<<(blockno%32);
  800851:	89 cb                	mov    %ecx,%ebx
  800853:	c1 eb 05             	shr    $0x5,%ebx
  800856:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80085c:	b8 01 00 00 00       	mov    $0x1,%eax
  800861:	d3 e0                	shl    %cl,%eax
  800863:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800866:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800869:	c9                   	leave  
  80086a:	c3                   	ret    
		panic("attempt to free zero block");
  80086b:	83 ec 04             	sub    $0x4,%esp
  80086e:	68 dc 3a 80 00       	push   $0x803adc
  800873:	6a 2d                	push   $0x2d
  800875:	68 a7 3a 80 00       	push   $0x803aa7
  80087a:	e8 9e 12 00 00       	call   801b1d <_panic>

0080087f <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	uint32_t bmpblock_start = 2;
    	for (uint32_t blockno = 0; blockno < super->s_nblocks; blockno++) {
  800884:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800889:	8b 70 04             	mov    0x4(%eax),%esi
  80088c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800891:	39 de                	cmp    %ebx,%esi
  800893:	74 4b                	je     8008e0 <alloc_block+0x61>
        	if (block_is_free(blockno)) {
  800895:	53                   	push   %ebx
  800896:	e8 72 ff ff ff       	call   80080d <block_is_free>
  80089b:	83 c4 04             	add    $0x4,%esp
  80089e:	84 c0                	test   %al,%al
  8008a0:	75 05                	jne    8008a7 <alloc_block+0x28>
    	for (uint32_t blockno = 0; blockno < super->s_nblocks; blockno++) {
  8008a2:	83 c3 01             	add    $0x1,%ebx
  8008a5:	eb ea                	jmp    800891 <alloc_block+0x12>
            		bitmap[blockno / 32] &= ~(1 << (blockno % 32));
  8008a7:	89 de                	mov    %ebx,%esi
  8008a9:	c1 ee 05             	shr    $0x5,%esi
  8008ac:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  8008b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8008b7:	89 d9                	mov    %ebx,%ecx
  8008b9:	d3 e0                	shl    %cl,%eax
  8008bb:	f7 d0                	not    %eax
  8008bd:	21 04 b2             	and    %eax,(%edx,%esi,4)
            		flush_block(diskaddr(bmpblock_start + (blockno / 32) / NINDIRECT));
  8008c0:	83 ec 0c             	sub    $0xc,%esp
  8008c3:	89 d8                	mov    %ebx,%eax
  8008c5:	c1 e8 0f             	shr    $0xf,%eax
  8008c8:	83 c0 02             	add    $0x2,%eax
  8008cb:	50                   	push   %eax
  8008cc:	e8 b2 fa ff ff       	call   800383 <diskaddr>
  8008d1:	89 04 24             	mov    %eax,(%esp)
  8008d4:	e8 28 fb ff ff       	call   800401 <flush_block>
            		return blockno;
  8008d9:	89 d8                	mov    %ebx,%eax
  8008db:	83 c4 10             	add    $0x10,%esp
  8008de:	eb 05                	jmp    8008e5 <alloc_block+0x66>
        	}
    	}
	return -E_NO_DISK;
  8008e0:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8008e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	57                   	push   %edi
  8008f0:	56                   	push   %esi
  8008f1:	53                   	push   %ebx
  8008f2:	83 ec 1c             	sub    $0x1c,%esp
  8008f5:	8b 7d 08             	mov    0x8(%ebp),%edi
       // LAB 5: Your code here.
    	int bn;
    	uint32_t *indirects;
    	if (filebno >= NDIRECT + NINDIRECT)
  8008f8:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8008fe:	0f 87 8d 00 00 00    	ja     800991 <file_block_walk+0xa5>
        	return -E_INVAL;

    	if (filebno < NDIRECT) {
  800904:	83 fa 09             	cmp    $0x9,%edx
  800907:	76 54                	jbe    80095d <file_block_walk+0x71>
  800909:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80090c:	89 d3                	mov    %edx,%ebx
  80090e:	89 c6                	mov    %eax,%esi
        	*ppdiskbno = &(f->f_direct[filebno]);
    	} else {
        	if (f->f_indirect) {
  800910:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  800916:	85 c0                	test   %eax,%eax
  800918:	75 5b                	jne    800975 <file_block_walk+0x89>
            		indirects = diskaddr(f->f_indirect);
            		*ppdiskbno = &(indirects[filebno - NDIRECT]);
        	} else {
            		if (!alloc)
  80091a:	89 f8                	mov    %edi,%eax
  80091c:	84 c0                	test   %al,%al
  80091e:	74 78                	je     800998 <file_block_walk+0xac>
                		return -E_NOT_FOUND;
            		if ((bn = alloc_block()) < 0)
  800920:	e8 5a ff ff ff       	call   80087f <alloc_block>
  800925:	89 c7                	mov    %eax,%edi
  800927:	85 c0                	test   %eax,%eax
  800929:	78 40                	js     80096b <file_block_walk+0x7f>
                		return bn;
            		f->f_indirect = bn;
  80092b:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
            		flush_block(diskaddr(bn));
  800931:	83 ec 0c             	sub    $0xc,%esp
  800934:	50                   	push   %eax
  800935:	e8 49 fa ff ff       	call   800383 <diskaddr>
  80093a:	89 04 24             	mov    %eax,(%esp)
  80093d:	e8 bf fa ff ff       	call   800401 <flush_block>
            		indirects = diskaddr(bn);
  800942:	89 3c 24             	mov    %edi,(%esp)
  800945:	e8 39 fa ff ff       	call   800383 <diskaddr>
            		*ppdiskbno = &(indirects[filebno - NDIRECT]);
  80094a:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  80094e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800951:	89 03                	mov    %eax,(%ebx)
  800953:	83 c4 10             	add    $0x10,%esp
        	}
    	}
    	return 0;
  800956:	bf 00 00 00 00       	mov    $0x0,%edi
  80095b:	eb 0e                	jmp    80096b <file_block_walk+0x7f>
        	*ppdiskbno = &(f->f_direct[filebno]);
  80095d:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  800964:	89 01                	mov    %eax,(%ecx)
    	return 0;
  800966:	bf 00 00 00 00       	mov    $0x0,%edi
}
  80096b:	89 f8                	mov    %edi,%eax
  80096d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5f                   	pop    %edi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    
            		indirects = diskaddr(f->f_indirect);
  800975:	83 ec 0c             	sub    $0xc,%esp
  800978:	50                   	push   %eax
  800979:	e8 05 fa ff ff       	call   800383 <diskaddr>
            		*ppdiskbno = &(indirects[filebno - NDIRECT]);
  80097e:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800982:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800985:	89 03                	mov    %eax,(%ebx)
  800987:	83 c4 10             	add    $0x10,%esp
    	return 0;
  80098a:	bf 00 00 00 00       	mov    $0x0,%edi
  80098f:	eb da                	jmp    80096b <file_block_walk+0x7f>
        	return -E_INVAL;
  800991:	bf fd ff ff ff       	mov    $0xfffffffd,%edi
  800996:	eb d3                	jmp    80096b <file_block_walk+0x7f>
                		return -E_NOT_FOUND;
  800998:	bf f5 ff ff ff       	mov    $0xfffffff5,%edi
  80099d:	eb cc                	jmp    80096b <file_block_walk+0x7f>

0080099f <check_bitmap>:
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009a4:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8009a9:	8b 70 04             	mov    0x4(%eax),%esi
  8009ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009b1:	89 d8                	mov    %ebx,%eax
  8009b3:	c1 e0 0f             	shl    $0xf,%eax
  8009b6:	39 c6                	cmp    %eax,%esi
  8009b8:	76 2b                	jbe    8009e5 <check_bitmap+0x46>
		assert(!block_is_free(2+i));
  8009ba:	8d 43 02             	lea    0x2(%ebx),%eax
  8009bd:	50                   	push   %eax
  8009be:	e8 4a fe ff ff       	call   80080d <block_is_free>
  8009c3:	83 c4 04             	add    $0x4,%esp
  8009c6:	84 c0                	test   %al,%al
  8009c8:	75 05                	jne    8009cf <check_bitmap+0x30>
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009ca:	83 c3 01             	add    $0x1,%ebx
  8009cd:	eb e2                	jmp    8009b1 <check_bitmap+0x12>
		assert(!block_is_free(2+i));
  8009cf:	68 f7 3a 80 00       	push   $0x803af7
  8009d4:	68 fd 38 80 00       	push   $0x8038fd
  8009d9:	6a 57                	push   $0x57
  8009db:	68 a7 3a 80 00       	push   $0x803aa7
  8009e0:	e8 38 11 00 00       	call   801b1d <_panic>
	assert(!block_is_free(0));
  8009e5:	83 ec 0c             	sub    $0xc,%esp
  8009e8:	6a 00                	push   $0x0
  8009ea:	e8 1e fe ff ff       	call   80080d <block_is_free>
  8009ef:	83 c4 10             	add    $0x10,%esp
  8009f2:	84 c0                	test   %al,%al
  8009f4:	75 28                	jne    800a1e <check_bitmap+0x7f>
	assert(!block_is_free(1));
  8009f6:	83 ec 0c             	sub    $0xc,%esp
  8009f9:	6a 01                	push   $0x1
  8009fb:	e8 0d fe ff ff       	call   80080d <block_is_free>
  800a00:	83 c4 10             	add    $0x10,%esp
  800a03:	84 c0                	test   %al,%al
  800a05:	75 2d                	jne    800a34 <check_bitmap+0x95>
	cprintf("bitmap is good\n");
  800a07:	83 ec 0c             	sub    $0xc,%esp
  800a0a:	68 2f 3b 80 00       	push   $0x803b2f
  800a0f:	e8 e4 11 00 00       	call   801bf8 <cprintf>
}
  800a14:	83 c4 10             	add    $0x10,%esp
  800a17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    
	assert(!block_is_free(0));
  800a1e:	68 0b 3b 80 00       	push   $0x803b0b
  800a23:	68 fd 38 80 00       	push   $0x8038fd
  800a28:	6a 5a                	push   $0x5a
  800a2a:	68 a7 3a 80 00       	push   $0x803aa7
  800a2f:	e8 e9 10 00 00       	call   801b1d <_panic>
	assert(!block_is_free(1));
  800a34:	68 1d 3b 80 00       	push   $0x803b1d
  800a39:	68 fd 38 80 00       	push   $0x8038fd
  800a3e:	6a 5b                	push   $0x5b
  800a40:	68 a7 3a 80 00       	push   $0x803aa7
  800a45:	e8 d3 10 00 00       	call   801b1d <_panic>

00800a4a <fs_init>:
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	83 ec 08             	sub    $0x8,%esp
	if (ide_probe_disk1())
  800a50:	e8 0a f6 ff ff       	call   80005f <ide_probe_disk1>
  800a55:	84 c0                	test   %al,%al
  800a57:	75 41                	jne    800a9a <fs_init+0x50>
		ide_set_disk(0);
  800a59:	83 ec 0c             	sub    $0xc,%esp
  800a5c:	6a 00                	push   $0x0
  800a5e:	e8 5e f6 ff ff       	call   8000c1 <ide_set_disk>
  800a63:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800a66:	e8 56 fa ff ff       	call   8004c1 <bc_init>
	super = diskaddr(1);
  800a6b:	83 ec 0c             	sub    $0xc,%esp
  800a6e:	6a 01                	push   $0x1
  800a70:	e8 0e f9 ff ff       	call   800383 <diskaddr>
  800a75:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800a7a:	e8 38 fd ff ff       	call   8007b7 <check_super>
	bitmap = diskaddr(2);
  800a7f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800a86:	e8 f8 f8 ff ff       	call   800383 <diskaddr>
  800a8b:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800a90:	e8 0a ff ff ff       	call   80099f <check_bitmap>
}
  800a95:	83 c4 10             	add    $0x10,%esp
  800a98:	c9                   	leave  
  800a99:	c3                   	ret    
		ide_set_disk(1);
  800a9a:	83 ec 0c             	sub    $0xc,%esp
  800a9d:	6a 01                	push   $0x1
  800a9f:	e8 1d f6 ff ff       	call   8000c1 <ide_set_disk>
  800aa4:	83 c4 10             	add    $0x10,%esp
  800aa7:	eb bd                	jmp    800a66 <fs_init+0x1c>

00800aa9 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	83 ec 24             	sub    $0x24,%esp
       // LAB 5: Your code here.
        int r;
        uint32_t *pdiskbno;
        if ((r = file_block_walk(f, filebno, &pdiskbno, true)) < 0) {
  800aaf:	6a 01                	push   $0x1
  800ab1:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800ab4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	e8 2d fe ff ff       	call   8008ec <file_block_walk>
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	78 44                	js     800b0a <file_get_block+0x61>
            return r;
        }
        int bn;
        if (*pdiskbno == 0) { 
  800ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac9:	83 38 00             	cmpl   $0x0,(%eax)
  800acc:	75 22                	jne    800af0 <file_get_block+0x47>
            if ((bn = alloc_block()) < 0) {
  800ace:	e8 ac fd ff ff       	call   80087f <alloc_block>
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	78 33                	js     800b0a <file_get_block+0x61>
                return bn;
            }
            *pdiskbno = bn;
  800ad7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ada:	89 02                	mov    %eax,(%edx)
            flush_block(diskaddr(bn));
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	50                   	push   %eax
  800ae0:	e8 9e f8 ff ff       	call   800383 <diskaddr>
  800ae5:	89 04 24             	mov    %eax,(%esp)
  800ae8:	e8 14 f9 ff ff       	call   800401 <flush_block>
  800aed:	83 c4 10             	add    $0x10,%esp
        }
        *blk = diskaddr(*pdiskbno);
  800af0:	83 ec 0c             	sub    $0xc,%esp
  800af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800af6:	ff 30                	pushl  (%eax)
  800af8:	e8 86 f8 ff ff       	call   800383 <diskaddr>
  800afd:	8b 55 10             	mov    0x10(%ebp),%edx
  800b00:	89 02                	mov    %eax,(%edx)
        return 0;
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800b18:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800b1e:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800b24:	eb 03                	jmp    800b29 <walk_path+0x1d>
		p++;
  800b26:	83 c0 01             	add    $0x1,%eax
	while (*p == '/')
  800b29:	80 38 2f             	cmpb   $0x2f,(%eax)
  800b2c:	74 f8                	je     800b26 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800b2e:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800b34:	83 c1 08             	add    $0x8,%ecx
  800b37:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800b3d:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800b44:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800b4a:	85 c9                	test   %ecx,%ecx
  800b4c:	74 06                	je     800b54 <walk_path+0x48>
		*pdir = 0;
  800b4e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800b54:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800b5a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	dir = 0;
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
	while (*path != '\0') {
  800b65:	e9 b4 01 00 00       	jmp    800d1e <walk_path+0x212>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800b6a:	83 c7 01             	add    $0x1,%edi
		while (*path != '/' && *path != '\0')
  800b6d:	0f b6 17             	movzbl (%edi),%edx
  800b70:	80 fa 2f             	cmp    $0x2f,%dl
  800b73:	74 04                	je     800b79 <walk_path+0x6d>
  800b75:	84 d2                	test   %dl,%dl
  800b77:	75 f1                	jne    800b6a <walk_path+0x5e>
		if (path - p >= MAXNAMELEN)
  800b79:	89 fb                	mov    %edi,%ebx
  800b7b:	29 c3                	sub    %eax,%ebx
  800b7d:	83 fb 7f             	cmp    $0x7f,%ebx
  800b80:	0f 8f 70 01 00 00    	jg     800cf6 <walk_path+0x1ea>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800b86:	83 ec 04             	sub    $0x4,%esp
  800b89:	53                   	push   %ebx
  800b8a:	50                   	push   %eax
  800b8b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800b91:	50                   	push   %eax
  800b92:	e8 0e 18 00 00       	call   8023a5 <memmove>
		name[path - p] = '\0';
  800b97:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800b9e:	00 
  800b9f:	83 c4 10             	add    $0x10,%esp
  800ba2:	eb 03                	jmp    800ba7 <walk_path+0x9b>
		p++;
  800ba4:	83 c7 01             	add    $0x1,%edi
	while (*p == '/')
  800ba7:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800baa:	74 f8                	je     800ba4 <walk_path+0x98>
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800bac:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800bb2:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800bb9:	0f 85 3e 01 00 00    	jne    800cfd <walk_path+0x1f1>
	assert((dir->f_size % BLKSIZE) == 0);
  800bbf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800bc5:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800bca:	0f 85 98 00 00 00    	jne    800c68 <walk_path+0x15c>
	nblock = dir->f_size / BLKSIZE;
  800bd0:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800bd6:	85 c0                	test   %eax,%eax
  800bd8:	0f 48 c2             	cmovs  %edx,%eax
  800bdb:	c1 f8 0c             	sar    $0xc,%eax
  800bde:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800be4:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800beb:	00 00 00 
			if (strcmp(f[j].f_name, name) == 0) {
  800bee:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  800bf4:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
	for (i = 0; i < nblock; i++) {
  800bfa:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800c00:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800c06:	74 79                	je     800c81 <walk_path+0x175>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800c08:	83 ec 04             	sub    $0x4,%esp
  800c0b:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c11:	50                   	push   %eax
  800c12:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800c18:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800c1e:	e8 86 fe ff ff       	call   800aa9 <file_get_block>
  800c23:	83 c4 10             	add    $0x10,%esp
  800c26:	85 c0                	test   %eax,%eax
  800c28:	0f 88 fc 00 00 00    	js     800d2a <walk_path+0x21e>
  800c2e:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800c34:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
			if (strcmp(f[j].f_name, name) == 0) {
  800c3a:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800c40:	83 ec 08             	sub    $0x8,%esp
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	e8 73 16 00 00       	call   8022bd <strcmp>
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	0f 84 af 00 00 00    	je     800d04 <walk_path+0x1f8>
  800c55:	81 c3 00 01 00 00    	add    $0x100,%ebx
		for (j = 0; j < BLKFILES; j++)
  800c5b:	39 fb                	cmp    %edi,%ebx
  800c5d:	75 db                	jne    800c3a <walk_path+0x12e>
	for (i = 0; i < nblock; i++) {
  800c5f:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800c66:	eb 92                	jmp    800bfa <walk_path+0xee>
	assert((dir->f_size % BLKSIZE) == 0);
  800c68:	68 3f 3b 80 00       	push   $0x803b3f
  800c6d:	68 fd 38 80 00       	push   $0x8038fd
  800c72:	68 d6 00 00 00       	push   $0xd6
  800c77:	68 a7 3a 80 00       	push   $0x803aa7
  800c7c:	e8 9c 0e 00 00       	call   801b1d <_panic>
  800c81:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800c87:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
			if (r == -E_NOT_FOUND && *path == '\0') {
  800c8c:	80 3f 00             	cmpb   $0x0,(%edi)
  800c8f:	0f 85 a4 00 00 00    	jne    800d39 <walk_path+0x22d>
				if (pdir)
  800c95:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	74 08                	je     800ca7 <walk_path+0x19b>
					*pdir = dir;
  800c9f:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800ca5:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800ca7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800cab:	74 15                	je     800cc2 <walk_path+0x1b6>
					strcpy(lastelem, name);
  800cad:	83 ec 08             	sub    $0x8,%esp
  800cb0:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800cb6:	50                   	push   %eax
  800cb7:	ff 75 08             	pushl  0x8(%ebp)
  800cba:	e8 58 15 00 00       	call   802217 <strcpy>
  800cbf:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800cc2:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800cc8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			return r;
  800cce:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800cd3:	eb 64                	jmp    800d39 <walk_path+0x22d>
		}
	}

	if (pdir)
  800cd5:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	74 02                	je     800ce1 <walk_path+0x1d5>
		*pdir = dir;
  800cdf:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800ce1:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800ce7:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800ced:	89 08                	mov    %ecx,(%eax)
	return 0;
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf4:	eb 43                	jmp    800d39 <walk_path+0x22d>
			return -E_BAD_PATH;
  800cf6:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800cfb:	eb 3c                	jmp    800d39 <walk_path+0x22d>
			return -E_NOT_FOUND;
  800cfd:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d02:	eb 35                	jmp    800d39 <walk_path+0x22d>
  800d04:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800d0a:	89 f8                	mov    %edi,%eax
  800d0c:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
			if (strcmp(f[j].f_name, name) == 0) {
  800d12:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
  800d18:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	while (*path != '\0') {
  800d1e:	80 38 00             	cmpb   $0x0,(%eax)
  800d21:	74 b2                	je     800cd5 <walk_path+0x1c9>
  800d23:	89 c7                	mov    %eax,%edi
  800d25:	e9 43 fe ff ff       	jmp    800b6d <walk_path+0x61>
  800d2a:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d30:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800d33:	0f 84 4e ff ff ff    	je     800c87 <walk_path+0x17b>
}
  800d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800d47:	6a 00                	push   $0x0
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
  800d54:	e8 b3 fd ff ff       	call   800b0c <walk_path>
}
  800d59:	c9                   	leave  
  800d5a:	c3                   	ret    

00800d5b <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 2c             	sub    $0x2c,%esp
  800d64:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d67:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6d:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
	if (offset >= f->f_size)
  800d78:	39 ca                	cmp    %ecx,%edx
  800d7a:	0f 8e 80 00 00 00    	jle    800e00 <file_read+0xa5>

	count = MIN(count, f->f_size - offset);
  800d80:	29 ca                	sub    %ecx,%edx
  800d82:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d85:	89 d0                	mov    %edx,%eax
  800d87:	0f 47 45 10          	cmova  0x10(%ebp),%eax
  800d8b:	89 45 d0             	mov    %eax,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800d8e:	89 ce                	mov    %ecx,%esi
  800d90:	01 c1                	add    %eax,%ecx
  800d92:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800d95:	89 f3                	mov    %esi,%ebx
  800d97:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800d9a:	76 61                	jbe    800dfd <file_read+0xa2>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800d9c:	83 ec 04             	sub    $0x4,%esp
  800d9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800da2:	50                   	push   %eax
  800da3:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800da9:	85 f6                	test   %esi,%esi
  800dab:	0f 49 c6             	cmovns %esi,%eax
  800dae:	c1 f8 0c             	sar    $0xc,%eax
  800db1:	50                   	push   %eax
  800db2:	ff 75 08             	pushl  0x8(%ebp)
  800db5:	e8 ef fc ff ff       	call   800aa9 <file_get_block>
  800dba:	83 c4 10             	add    $0x10,%esp
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	78 3f                	js     800e00 <file_read+0xa5>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800dc1:	89 f2                	mov    %esi,%edx
  800dc3:	c1 fa 1f             	sar    $0x1f,%edx
  800dc6:	c1 ea 14             	shr    $0x14,%edx
  800dc9:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800dcc:	25 ff 0f 00 00       	and    $0xfff,%eax
  800dd1:	29 d0                	sub    %edx,%eax
  800dd3:	ba 00 10 00 00       	mov    $0x1000,%edx
  800dd8:	29 c2                	sub    %eax,%edx
  800dda:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800ddd:	29 d9                	sub    %ebx,%ecx
  800ddf:	89 cb                	mov    %ecx,%ebx
  800de1:	39 ca                	cmp    %ecx,%edx
  800de3:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800de6:	83 ec 04             	sub    $0x4,%esp
  800de9:	53                   	push   %ebx
  800dea:	03 45 e4             	add    -0x1c(%ebp),%eax
  800ded:	50                   	push   %eax
  800dee:	57                   	push   %edi
  800def:	e8 b1 15 00 00       	call   8023a5 <memmove>
		pos += bn;
  800df4:	01 de                	add    %ebx,%esi
		buf += bn;
  800df6:	01 df                	add    %ebx,%edi
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	eb 98                	jmp    800d95 <file_read+0x3a>
	}

	return count;
  800dfd:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800e00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 2c             	sub    $0x2c,%esp
  800e11:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800e14:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800e1a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800e1d:	7f 1f                	jg     800e3e <file_set_size+0x36>
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e22:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	56                   	push   %esi
  800e2c:	e8 d0 f5 ff ff       	call   800401 <flush_block>
	return 0;
}
  800e31:	b8 00 00 00 00       	mov    $0x0,%eax
  800e36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    
	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800e3e:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800e44:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e49:	0f 49 f8             	cmovns %eax,%edi
  800e4c:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e52:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800e57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e5a:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800e60:	0f 49 c2             	cmovns %edx,%eax
  800e63:	c1 f8 0c             	sar    $0xc,%eax
  800e66:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e69:	89 c3                	mov    %eax,%ebx
  800e6b:	eb 3c                	jmp    800ea9 <file_set_size+0xa1>
	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800e6d:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800e71:	77 ac                	ja     800e1f <file_set_size+0x17>
  800e73:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	74 a2                	je     800e1f <file_set_size+0x17>
		free_block(f->f_indirect);
  800e7d:	83 ec 0c             	sub    $0xc,%esp
  800e80:	50                   	push   %eax
  800e81:	e8 bd f9 ff ff       	call   800843 <free_block>
		f->f_indirect = 0;
  800e86:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800e8d:	00 00 00 
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	eb 8a                	jmp    800e1f <file_set_size+0x17>
			cprintf("warning: file_free_block: %e", r);
  800e95:	83 ec 08             	sub    $0x8,%esp
  800e98:	50                   	push   %eax
  800e99:	68 5c 3b 80 00       	push   $0x803b5c
  800e9e:	e8 55 0d 00 00       	call   801bf8 <cprintf>
  800ea3:	83 c4 10             	add    $0x10,%esp
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800ea6:	83 c3 01             	add    $0x1,%ebx
  800ea9:	39 df                	cmp    %ebx,%edi
  800eab:	76 c0                	jbe    800e6d <file_set_size+0x65>
	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800ead:	83 ec 0c             	sub    $0xc,%esp
  800eb0:	6a 00                	push   $0x0
  800eb2:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800eb5:	89 da                	mov    %ebx,%edx
  800eb7:	89 f0                	mov    %esi,%eax
  800eb9:	e8 2e fa ff ff       	call   8008ec <file_block_walk>
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	78 d0                	js     800e95 <file_set_size+0x8d>
	if (*ptr) {
  800ec5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ec8:	8b 00                	mov    (%eax),%eax
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	74 d8                	je     800ea6 <file_set_size+0x9e>
		free_block(*ptr);
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	50                   	push   %eax
  800ed2:	e8 6c f9 ff ff       	call   800843 <free_block>
		*ptr = 0;
  800ed7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eda:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	eb c1                	jmp    800ea6 <file_set_size+0x9e>

00800ee5 <file_write>:
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 2c             	sub    $0x2c,%esp
  800eee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ef1:	8b 75 14             	mov    0x14(%ebp),%esi
	if (offset + count > f->f_size)
  800ef4:	89 f0                	mov    %esi,%eax
  800ef6:	03 45 10             	add    0x10(%ebp),%eax
  800ef9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800efc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eff:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800f05:	77 68                	ja     800f6f <file_write+0x8a>
	for (pos = offset; pos < offset + count; ) {
  800f07:	89 f3                	mov    %esi,%ebx
  800f09:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800f0c:	76 74                	jbe    800f82 <file_write+0x9d>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800f0e:	83 ec 04             	sub    $0x4,%esp
  800f11:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f14:	50                   	push   %eax
  800f15:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800f1b:	85 f6                	test   %esi,%esi
  800f1d:	0f 49 c6             	cmovns %esi,%eax
  800f20:	c1 f8 0c             	sar    $0xc,%eax
  800f23:	50                   	push   %eax
  800f24:	ff 75 08             	pushl  0x8(%ebp)
  800f27:	e8 7d fb ff ff       	call   800aa9 <file_get_block>
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	78 52                	js     800f85 <file_write+0xa0>
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f33:	89 f2                	mov    %esi,%edx
  800f35:	c1 fa 1f             	sar    $0x1f,%edx
  800f38:	c1 ea 14             	shr    $0x14,%edx
  800f3b:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800f3e:	25 ff 0f 00 00       	and    $0xfff,%eax
  800f43:	29 d0                	sub    %edx,%eax
  800f45:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800f4a:	29 c1                	sub    %eax,%ecx
  800f4c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f4f:	29 da                	sub    %ebx,%edx
  800f51:	39 d1                	cmp    %edx,%ecx
  800f53:	89 d3                	mov    %edx,%ebx
  800f55:	0f 46 d9             	cmovbe %ecx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800f58:	83 ec 04             	sub    $0x4,%esp
  800f5b:	53                   	push   %ebx
  800f5c:	57                   	push   %edi
  800f5d:	03 45 e4             	add    -0x1c(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	e8 3f 14 00 00       	call   8023a5 <memmove>
		pos += bn;
  800f66:	01 de                	add    %ebx,%esi
		buf += bn;
  800f68:	01 df                	add    %ebx,%edi
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	eb 98                	jmp    800f07 <file_write+0x22>
		if ((r = file_set_size(f, offset + count)) < 0)
  800f6f:	83 ec 08             	sub    $0x8,%esp
  800f72:	50                   	push   %eax
  800f73:	51                   	push   %ecx
  800f74:	e8 8f fe ff ff       	call   800e08 <file_set_size>
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	79 87                	jns    800f07 <file_write+0x22>
  800f80:	eb 03                	jmp    800f85 <file_write+0xa0>
	return count;
  800f82:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800f85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
  800f92:	83 ec 10             	sub    $0x10,%esp
  800f95:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800f98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9d:	eb 03                	jmp    800fa2 <file_flush+0x15>
  800f9f:	83 c3 01             	add    $0x1,%ebx
  800fa2:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800fa8:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800fae:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800fb4:	85 c9                	test   %ecx,%ecx
  800fb6:	0f 49 c1             	cmovns %ecx,%eax
  800fb9:	c1 f8 0c             	sar    $0xc,%eax
  800fbc:	39 d8                	cmp    %ebx,%eax
  800fbe:	7e 3b                	jle    800ffb <file_flush+0x6e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800fc0:	83 ec 0c             	sub    $0xc,%esp
  800fc3:	6a 00                	push   $0x0
  800fc5:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800fc8:	89 da                	mov    %ebx,%edx
  800fca:	89 f0                	mov    %esi,%eax
  800fcc:	e8 1b f9 ff ff       	call   8008ec <file_block_walk>
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 c7                	js     800f9f <file_flush+0x12>
		    pdiskbno == NULL || *pdiskbno == 0)
  800fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	74 c0                	je     800f9f <file_flush+0x12>
		    pdiskbno == NULL || *pdiskbno == 0)
  800fdf:	8b 00                	mov    (%eax),%eax
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	74 ba                	je     800f9f <file_flush+0x12>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800fe5:	83 ec 0c             	sub    $0xc,%esp
  800fe8:	50                   	push   %eax
  800fe9:	e8 95 f3 ff ff       	call   800383 <diskaddr>
  800fee:	89 04 24             	mov    %eax,(%esp)
  800ff1:	e8 0b f4 ff ff       	call   800401 <flush_block>
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	eb a4                	jmp    800f9f <file_flush+0x12>
	}
	flush_block(f);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	56                   	push   %esi
  800fff:	e8 fd f3 ff ff       	call   800401 <flush_block>
	if (f->f_indirect)
  801004:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	75 07                	jne    801018 <file_flush+0x8b>
		flush_block(diskaddr(f->f_indirect));
}
  801011:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    
		flush_block(diskaddr(f->f_indirect));
  801018:	83 ec 0c             	sub    $0xc,%esp
  80101b:	50                   	push   %eax
  80101c:	e8 62 f3 ff ff       	call   800383 <diskaddr>
  801021:	89 04 24             	mov    %eax,(%esp)
  801024:	e8 d8 f3 ff ff       	call   800401 <flush_block>
  801029:	83 c4 10             	add    $0x10,%esp
}
  80102c:	eb e3                	jmp    801011 <file_flush+0x84>

0080102e <file_create>:
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	if ((r = walk_path(path, &dir, &f, name)) == 0)
  80103a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801040:	50                   	push   %eax
  801041:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  801047:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  80104d:	8b 45 08             	mov    0x8(%ebp),%eax
  801050:	e8 b7 fa ff ff       	call   800b0c <walk_path>
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	85 c0                	test   %eax,%eax
  80105a:	0f 84 0e 01 00 00    	je     80116e <file_create+0x140>
	if (r != -E_NOT_FOUND || dir == 0)
  801060:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801063:	74 08                	je     80106d <file_create+0x3f>
}
  801065:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    
	if (r != -E_NOT_FOUND || dir == 0)
  80106d:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  801073:	85 db                	test   %ebx,%ebx
  801075:	74 ee                	je     801065 <file_create+0x37>
	assert((dir->f_size % BLKSIZE) == 0);
  801077:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  80107d:	a9 ff 0f 00 00       	test   $0xfff,%eax
  801082:	75 5c                	jne    8010e0 <file_create+0xb2>
	nblock = dir->f_size / BLKSIZE;
  801084:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80108a:	85 c0                	test   %eax,%eax
  80108c:	0f 48 c2             	cmovs  %edx,%eax
  80108f:	c1 f8 0c             	sar    $0xc,%eax
  801092:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  801098:	be 00 00 00 00       	mov    $0x0,%esi
		if ((r = file_get_block(dir, i, &blk)) < 0)
  80109d:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
	for (i = 0; i < nblock; i++) {
  8010a3:	39 b5 54 ff ff ff    	cmp    %esi,-0xac(%ebp)
  8010a9:	0f 84 8b 00 00 00    	je     80113a <file_create+0x10c>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8010af:	83 ec 04             	sub    $0x4,%esp
  8010b2:	57                   	push   %edi
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
  8010b5:	e8 ef f9 ff ff       	call   800aa9 <file_get_block>
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	78 a4                	js     801065 <file_create+0x37>
  8010c1:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8010c7:	8d 88 00 10 00 00    	lea    0x1000(%eax),%ecx
			if (f[j].f_name[0] == '\0') {
  8010cd:	80 38 00             	cmpb   $0x0,(%eax)
  8010d0:	74 27                	je     8010f9 <file_create+0xcb>
  8010d2:	05 00 01 00 00       	add    $0x100,%eax
		for (j = 0; j < BLKFILES; j++)
  8010d7:	39 c8                	cmp    %ecx,%eax
  8010d9:	75 f2                	jne    8010cd <file_create+0x9f>
	for (i = 0; i < nblock; i++) {
  8010db:	83 c6 01             	add    $0x1,%esi
  8010de:	eb c3                	jmp    8010a3 <file_create+0x75>
	assert((dir->f_size % BLKSIZE) == 0);
  8010e0:	68 3f 3b 80 00       	push   $0x803b3f
  8010e5:	68 fd 38 80 00       	push   $0x8038fd
  8010ea:	68 ef 00 00 00       	push   $0xef
  8010ef:	68 a7 3a 80 00       	push   $0x803aa7
  8010f4:	e8 24 0a 00 00       	call   801b1d <_panic>
				*file = &f[j];
  8010f9:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
	strcpy(f->f_name, name);
  8010ff:	83 ec 08             	sub    $0x8,%esp
  801102:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801108:	50                   	push   %eax
  801109:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  80110f:	e8 03 11 00 00       	call   802217 <strcpy>
	*pf = f;
  801114:	8b 45 0c             	mov    0xc(%ebp),%eax
  801117:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  80111d:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80111f:	83 c4 04             	add    $0x4,%esp
  801122:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  801128:	e8 60 fe ff ff       	call   800f8d <file_flush>
	return 0;
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	b8 00 00 00 00       	mov    $0x0,%eax
  801135:	e9 2b ff ff ff       	jmp    801065 <file_create+0x37>
	dir->f_size += BLKSIZE;
  80113a:	81 83 80 00 00 00 00 	addl   $0x1000,0x80(%ebx)
  801141:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  801144:	83 ec 04             	sub    $0x4,%esp
  801147:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  80114d:	50                   	push   %eax
  80114e:	56                   	push   %esi
  80114f:	53                   	push   %ebx
  801150:	e8 54 f9 ff ff       	call   800aa9 <file_get_block>
  801155:	83 c4 10             	add    $0x10,%esp
  801158:	85 c0                	test   %eax,%eax
  80115a:	0f 88 05 ff ff ff    	js     801065 <file_create+0x37>
	*file = &f[0];
  801160:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801166:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  80116c:	eb 91                	jmp    8010ff <file_create+0xd1>
		return -E_FILE_EXISTS;
  80116e:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  801173:	e9 ed fe ff ff       	jmp    801065 <file_create+0x37>

00801178 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	53                   	push   %ebx
  80117c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80117f:	bb 01 00 00 00       	mov    $0x1,%ebx
  801184:	eb 17                	jmp    80119d <fs_sync+0x25>
		flush_block(diskaddr(i));
  801186:	83 ec 0c             	sub    $0xc,%esp
  801189:	53                   	push   %ebx
  80118a:	e8 f4 f1 ff ff       	call   800383 <diskaddr>
  80118f:	89 04 24             	mov    %eax,(%esp)
  801192:	e8 6a f2 ff ff       	call   800401 <flush_block>
	for (i = 1; i < super->s_nblocks; i++)
  801197:	83 c3 01             	add    $0x1,%ebx
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8011a2:	39 58 04             	cmp    %ebx,0x4(%eax)
  8011a5:	77 df                	ja     801186 <fs_sync+0xe>
}
  8011a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011aa:	c9                   	leave  
  8011ab:	c3                   	ret    

008011ac <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  8011b2:	e8 c1 ff ff ff       	call   801178 <fs_sync>
	return 0;
}
  8011b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    

008011be <serve_init>:
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	ba 60 50 80 00       	mov    $0x805060,%edx
	uintptr_t va = FILEVA;
  8011c6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8011cb:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8011d0:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8011d2:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8011d5:	81 c1 00 10 00 00    	add    $0x1000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8011db:	83 c0 01             	add    $0x1,%eax
  8011de:	83 c2 10             	add    $0x10,%edx
  8011e1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011e6:	75 e8                	jne    8011d0 <serve_init+0x12>
}
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <openfile_alloc>:
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	57                   	push   %edi
  8011ee:	56                   	push   %esi
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 0c             	sub    $0xc,%esp
  8011f3:	8b 7d 08             	mov    0x8(%ebp),%edi
	for (i = 0; i < MAXOPEN; i++) {
  8011f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fb:	89 de                	mov    %ebx,%esi
  8011fd:	c1 e6 04             	shl    $0x4,%esi
		switch (pageref(opentab[i].o_fd)) {
  801200:	83 ec 0c             	sub    $0xc,%esp
  801203:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
  801209:	e8 60 1f 00 00       	call   80316e <pageref>
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	74 17                	je     80122c <openfile_alloc+0x42>
  801215:	83 f8 01             	cmp    $0x1,%eax
  801218:	74 30                	je     80124a <openfile_alloc+0x60>
	for (i = 0; i < MAXOPEN; i++) {
  80121a:	83 c3 01             	add    $0x1,%ebx
  80121d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801223:	75 d6                	jne    8011fb <openfile_alloc+0x11>
	return -E_MAX_OPEN;
  801225:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80122a:	eb 4f                	jmp    80127b <openfile_alloc+0x91>
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	6a 07                	push   $0x7
  801231:	89 d8                	mov    %ebx,%eax
  801233:	c1 e0 04             	shl    $0x4,%eax
  801236:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  80123c:	6a 00                	push   $0x0
  80123e:	e8 cd 13 00 00       	call   802610 <sys_page_alloc>
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	78 31                	js     80127b <openfile_alloc+0x91>
			opentab[i].o_fileid += MAXOPEN;
  80124a:	c1 e3 04             	shl    $0x4,%ebx
  80124d:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  801254:	04 00 00 
			*o = &opentab[i];
  801257:	81 c6 60 50 80 00    	add    $0x805060,%esi
  80125d:	89 37                	mov    %esi,(%edi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  80125f:	83 ec 04             	sub    $0x4,%esp
  801262:	68 00 10 00 00       	push   $0x1000
  801267:	6a 00                	push   $0x0
  801269:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  80126f:	e8 e4 10 00 00       	call   802358 <memset>
			return (*o)->o_fileid;
  801274:	8b 07                	mov    (%edi),%eax
  801276:	8b 00                	mov    (%eax),%eax
  801278:	83 c4 10             	add    $0x10,%esp
}
  80127b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127e:	5b                   	pop    %ebx
  80127f:	5e                   	pop    %esi
  801280:	5f                   	pop    %edi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <openfile_lookup>:
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	57                   	push   %edi
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
  801289:	83 ec 18             	sub    $0x18,%esp
  80128c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	o = &opentab[fileid % MAXOPEN];
  80128f:	89 fb                	mov    %edi,%ebx
  801291:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801297:	89 de                	mov    %ebx,%esi
  801299:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80129c:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
	o = &opentab[fileid % MAXOPEN];
  8012a2:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8012a8:	e8 c1 1e 00 00       	call   80316e <pageref>
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	83 f8 01             	cmp    $0x1,%eax
  8012b3:	7e 1d                	jle    8012d2 <openfile_lookup+0x4f>
  8012b5:	c1 e3 04             	shl    $0x4,%ebx
  8012b8:	39 bb 60 50 80 00    	cmp    %edi,0x805060(%ebx)
  8012be:	75 19                	jne    8012d9 <openfile_lookup+0x56>
	*po = o;
  8012c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012c3:	89 30                	mov    %esi,(%eax)
	return 0;
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    
		return -E_INVAL;
  8012d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d7:	eb f1                	jmp    8012ca <openfile_lookup+0x47>
  8012d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012de:	eb ea                	jmp    8012ca <openfile_lookup+0x47>

008012e0 <serve_set_size>:
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	53                   	push   %ebx
  8012e4:	83 ec 18             	sub    $0x18,%esp
  8012e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	ff 33                	pushl  (%ebx)
  8012f0:	ff 75 08             	pushl  0x8(%ebp)
  8012f3:	e8 8b ff ff ff       	call   801283 <openfile_lookup>
  8012f8:	83 c4 10             	add    $0x10,%esp
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	78 14                	js     801313 <serve_set_size+0x33>
	return file_set_size(o->o_file, req->req_size);
  8012ff:	83 ec 08             	sub    $0x8,%esp
  801302:	ff 73 04             	pushl  0x4(%ebx)
  801305:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801308:	ff 70 04             	pushl  0x4(%eax)
  80130b:	e8 f8 fa ff ff       	call   800e08 <file_set_size>
  801310:	83 c4 10             	add    $0x10,%esp
}
  801313:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <serve_read>:
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	53                   	push   %ebx
  80131c:	83 ec 18             	sub    $0x18,%esp
  80131f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    	r = openfile_lookup(envid, req->req_fileid, &o);
  801322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	ff 33                	pushl  (%ebx)
  801328:	ff 75 08             	pushl  0x8(%ebp)
  80132b:	e8 53 ff ff ff       	call   801283 <openfile_lookup>
    	if (r < 0)
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 25                	js     80135c <serve_read+0x44>
	r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset);
  801337:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133a:	8b 50 0c             	mov    0xc(%eax),%edx
  80133d:	ff 72 04             	pushl  0x4(%edx)
  801340:	ff 73 04             	pushl  0x4(%ebx)
  801343:	53                   	push   %ebx
  801344:	ff 70 04             	pushl  0x4(%eax)
  801347:	e8 0f fa ff ff       	call   800d5b <file_read>
    	if (r < 0)
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 09                	js     80135c <serve_read+0x44>
    	o->o_fd->fd_offset += r;
  801353:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801356:	8b 52 0c             	mov    0xc(%edx),%edx
  801359:	01 42 04             	add    %eax,0x4(%edx)
}
  80135c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <serve_write>:
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	57                   	push   %edi
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
  801367:	83 ec 20             	sub    $0x20,%esp
  80136a:	8b 75 0c             	mov    0xc(%ebp),%esi
    	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) {
  80136d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801370:	50                   	push   %eax
  801371:	ff 36                	pushl  (%esi)
  801373:	ff 75 08             	pushl  0x8(%ebp)
  801376:	e8 08 ff ff ff       	call   801283 <openfile_lookup>
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 36                	js     8013b8 <serve_write+0x57>
    	int total = 0;
  801382:	bb 00 00 00 00       	mov    $0x0,%ebx
        	r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset);
  801387:	8d 7e 08             	lea    0x8(%esi),%edi
  80138a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80138d:	8b 50 0c             	mov    0xc(%eax),%edx
  801390:	ff 72 04             	pushl  0x4(%edx)
  801393:	ff 76 04             	pushl  0x4(%esi)
  801396:	57                   	push   %edi
  801397:	ff 70 04             	pushl  0x4(%eax)
  80139a:	e8 46 fb ff ff       	call   800ee5 <file_write>
        	if (r < 0) return r;
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	78 12                	js     8013b8 <serve_write+0x57>
        	total += r;
  8013a6:	01 c3                	add    %eax,%ebx
        	o->o_fd->fd_offset += r;
  8013a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ae:	01 42 04             	add    %eax,0x4(%edx)
        	if (req->req_n <= total)
  8013b1:	39 5e 04             	cmp    %ebx,0x4(%esi)
  8013b4:	77 d4                	ja     80138a <serve_write+0x29>
        	total += r;
  8013b6:	89 d8                	mov    %ebx,%eax
}
  8013b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013bb:	5b                   	pop    %ebx
  8013bc:	5e                   	pop    %esi
  8013bd:	5f                   	pop    %edi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <serve_stat>:
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 18             	sub    $0x18,%esp
  8013c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cd:	50                   	push   %eax
  8013ce:	ff 33                	pushl  (%ebx)
  8013d0:	ff 75 08             	pushl  0x8(%ebp)
  8013d3:	e8 ab fe ff ff       	call   801283 <openfile_lookup>
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 3f                	js     80141e <serve_stat+0x5e>
	strcpy(ret->ret_name, o->o_file->f_name);
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e5:	ff 70 04             	pushl  0x4(%eax)
  8013e8:	53                   	push   %ebx
  8013e9:	e8 29 0e 00 00       	call   802217 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8013ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f1:	8b 50 04             	mov    0x4(%eax),%edx
  8013f4:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8013fa:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  801400:	8b 40 04             	mov    0x4(%eax),%eax
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  80140d:	0f 94 c0             	sete   %al
  801410:	0f b6 c0             	movzbl %al,%eax
  801413:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801419:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <serve_flush>:
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801429:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142c:	50                   	push   %eax
  80142d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801430:	ff 30                	pushl  (%eax)
  801432:	ff 75 08             	pushl  0x8(%ebp)
  801435:	e8 49 fe ff ff       	call   801283 <openfile_lookup>
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 16                	js     801457 <serve_flush+0x34>
	file_flush(o->o_file);
  801441:	83 ec 0c             	sub    $0xc,%esp
  801444:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801447:	ff 70 04             	pushl  0x4(%eax)
  80144a:	e8 3e fb ff ff       	call   800f8d <file_flush>
	return 0;
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801457:	c9                   	leave  
  801458:	c3                   	ret    

00801459 <serve_open>:
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	53                   	push   %ebx
  80145d:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801463:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	memmove(path, req->req_path, MAXPATHLEN);
  801466:	68 00 04 00 00       	push   $0x400
  80146b:	53                   	push   %ebx
  80146c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801472:	50                   	push   %eax
  801473:	e8 2d 0f 00 00       	call   8023a5 <memmove>
	path[MAXPATHLEN-1] = 0;
  801478:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
	if ((r = openfile_alloc(&o)) < 0) {
  80147c:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801482:	89 04 24             	mov    %eax,(%esp)
  801485:	e8 60 fd ff ff       	call   8011ea <openfile_alloc>
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	0f 88 f0 00 00 00    	js     801585 <serve_open+0x12c>
	if (req->req_omode & O_CREAT) {
  801495:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  80149c:	74 33                	je     8014d1 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014ae:	50                   	push   %eax
  8014af:	e8 7a fb ff ff       	call   80102e <file_create>
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	79 37                	jns    8014f2 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8014bb:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8014c2:	0f 85 bd 00 00 00    	jne    801585 <serve_open+0x12c>
  8014c8:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8014cb:	0f 85 b4 00 00 00    	jne    801585 <serve_open+0x12c>
		if ((r = file_open(path, &f)) < 0) {
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014e1:	50                   	push   %eax
  8014e2:	e8 5a f8 ff ff       	call   800d41 <file_open>
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	0f 88 93 00 00 00    	js     801585 <serve_open+0x12c>
	if (req->req_omode & O_TRUNC) {
  8014f2:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8014f9:	74 17                	je     801512 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8014fb:	83 ec 08             	sub    $0x8,%esp
  8014fe:	6a 00                	push   $0x0
  801500:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  801506:	e8 fd f8 ff ff       	call   800e08 <file_set_size>
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 73                	js     801585 <serve_open+0x12c>
	if ((r = file_open(path, &f)) < 0) {
  801512:	83 ec 08             	sub    $0x8,%esp
  801515:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	e8 19 f8 ff ff       	call   800d41 <file_open>
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 56                	js     801585 <serve_open+0x12c>
	o->o_file = f;
  80152f:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801535:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80153b:	89 50 04             	mov    %edx,0x4(%eax)
	o->o_fd->fd_file.id = o->o_fileid;
  80153e:	8b 50 0c             	mov    0xc(%eax),%edx
  801541:	8b 08                	mov    (%eax),%ecx
  801543:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801546:	8b 48 0c             	mov    0xc(%eax),%ecx
  801549:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80154f:	83 e2 03             	and    $0x3,%edx
  801552:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801555:	8b 40 0c             	mov    0xc(%eax),%eax
  801558:	8b 15 64 90 80 00    	mov    0x809064,%edx
  80155e:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801560:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801566:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80156c:	89 50 08             	mov    %edx,0x8(%eax)
	*pg_store = o->o_fd;
  80156f:	8b 50 0c             	mov    0xc(%eax),%edx
  801572:	8b 45 10             	mov    0x10(%ebp),%eax
  801575:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801577:	8b 45 14             	mov    0x14(%ebp),%eax
  80157a:	c7 00 07 04 00 00    	movl   $0x407,(%eax)
	return 0;
  801580:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	56                   	push   %esi
  80158e:	53                   	push   %ebx
  80158f:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801592:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801595:	8d 75 f4             	lea    -0xc(%ebp),%esi
  801598:	eb 68                	jmp    801602 <serve+0x78>
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
			cprintf("Invalid request from %08x: no argument page\n",
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a0:	68 7c 3b 80 00       	push   $0x803b7c
  8015a5:	e8 4e 06 00 00       	call   801bf8 <cprintf>
				whom);
			continue; // just leave it hanging...
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	eb 53                	jmp    801602 <serve+0x78>
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8015af:	53                   	push   %ebx
  8015b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	ff 35 44 50 80 00    	pushl  0x805044
  8015ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8015bd:	e8 97 fe ff ff       	call   801459 <serve_open>
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	eb 19                	jmp    8015e0 <serve+0x56>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
			r = handlers[req](whom, fsreq);
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8015c7:	83 ec 04             	sub    $0x4,%esp
  8015ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8015cd:	50                   	push   %eax
  8015ce:	68 ac 3b 80 00       	push   $0x803bac
  8015d3:	e8 20 06 00 00       	call   801bf8 <cprintf>
  8015d8:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8015db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8015e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8015e3:	ff 75 ec             	pushl  -0x14(%ebp)
  8015e6:	50                   	push   %eax
  8015e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ea:	e8 0e 13 00 00       	call   8028fd <ipc_send>
		sys_page_unmap(0, fsreq);
  8015ef:	83 c4 08             	add    $0x8,%esp
  8015f2:	ff 35 44 50 80 00    	pushl  0x805044
  8015f8:	6a 00                	push   $0x0
  8015fa:	e8 96 10 00 00       	call   802695 <sys_page_unmap>
  8015ff:	83 c4 10             	add    $0x10,%esp
		perm = 0;
  801602:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801609:	83 ec 04             	sub    $0x4,%esp
  80160c:	53                   	push   %ebx
  80160d:	ff 35 44 50 80 00    	pushl  0x805044
  801613:	56                   	push   %esi
  801614:	e8 7d 12 00 00       	call   802896 <ipc_recv>
		if (!(perm & PTE_P)) {
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801620:	0f 84 74 ff ff ff    	je     80159a <serve+0x10>
		pg = NULL;
  801626:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  80162d:	83 f8 01             	cmp    $0x1,%eax
  801630:	0f 84 79 ff ff ff    	je     8015af <serve+0x25>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  801636:	83 f8 08             	cmp    $0x8,%eax
  801639:	77 8c                	ja     8015c7 <serve+0x3d>
  80163b:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  801642:	85 d2                	test   %edx,%edx
  801644:	74 81                	je     8015c7 <serve+0x3d>
			r = handlers[req](whom, fsreq);
  801646:	83 ec 08             	sub    $0x8,%esp
  801649:	ff 35 44 50 80 00    	pushl  0x805044
  80164f:	ff 75 f4             	pushl  -0xc(%ebp)
  801652:	ff d2                	call   *%edx
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	eb 87                	jmp    8015e0 <serve+0x56>

00801659 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  80165f:	c7 05 60 90 80 00 cf 	movl   $0x803bcf,0x809060
  801666:	3b 80 00 
	cprintf("FS is running\n");
  801669:	68 d2 3b 80 00       	push   $0x803bd2
  80166e:	e8 85 05 00 00       	call   801bf8 <cprintf>
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801673:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801678:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  80167d:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80167f:	c7 04 24 e1 3b 80 00 	movl   $0x803be1,(%esp)
  801686:	e8 6d 05 00 00       	call   801bf8 <cprintf>

	serve_init();
  80168b:	e8 2e fb ff ff       	call   8011be <serve_init>
	fs_init();
  801690:	e8 b5 f3 ff ff       	call   800a4a <fs_init>
        fs_test();
  801695:	e8 05 00 00 00       	call   80169f <fs_test>
	serve();
  80169a:	e8 eb fe ff ff       	call   80158a <serve>

0080169f <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  8016a6:	6a 07                	push   $0x7
  8016a8:	68 00 10 00 00       	push   $0x1000
  8016ad:	6a 00                	push   $0x0
  8016af:	e8 5c 0f 00 00       	call   802610 <sys_page_alloc>
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	0f 88 6a 02 00 00    	js     801929 <fs_test+0x28a>
		panic("sys_page_alloc: %e", r);
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8016bf:	83 ec 04             	sub    $0x4,%esp
  8016c2:	68 00 10 00 00       	push   $0x1000
  8016c7:	ff 35 04 a0 80 00    	pushl  0x80a004
  8016cd:	68 00 10 00 00       	push   $0x1000
  8016d2:	e8 ce 0c 00 00       	call   8023a5 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8016d7:	e8 a3 f1 ff ff       	call   80087f <alloc_block>
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	0f 88 54 02 00 00    	js     80193b <fs_test+0x29c>
		panic("alloc_block: %e", r);
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8016e7:	8d 50 1f             	lea    0x1f(%eax),%edx
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	0f 49 d0             	cmovns %eax,%edx
  8016ef:	c1 fa 05             	sar    $0x5,%edx
  8016f2:	89 c3                	mov    %eax,%ebx
  8016f4:	c1 fb 1f             	sar    $0x1f,%ebx
  8016f7:	c1 eb 1b             	shr    $0x1b,%ebx
  8016fa:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8016fd:	83 e1 1f             	and    $0x1f,%ecx
  801700:	29 d9                	sub    %ebx,%ecx
  801702:	b8 01 00 00 00       	mov    $0x1,%eax
  801707:	d3 e0                	shl    %cl,%eax
  801709:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  801710:	0f 84 37 02 00 00    	je     80194d <fs_test+0x2ae>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801716:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  80171c:	85 04 91             	test   %eax,(%ecx,%edx,4)
  80171f:	0f 85 3e 02 00 00    	jne    801963 <fs_test+0x2c4>
	cprintf("alloc_block is good\n");
  801725:	83 ec 0c             	sub    $0xc,%esp
  801728:	68 38 3c 80 00       	push   $0x803c38
  80172d:	e8 c6 04 00 00       	call   801bf8 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801732:	83 c4 08             	add    $0x8,%esp
  801735:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801738:	50                   	push   %eax
  801739:	68 4d 3c 80 00       	push   $0x803c4d
  80173e:	e8 fe f5 ff ff       	call   800d41 <file_open>
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801749:	74 08                	je     801753 <fs_test+0xb4>
  80174b:	85 c0                	test   %eax,%eax
  80174d:	0f 88 26 02 00 00    	js     801979 <fs_test+0x2da>
		panic("file_open /not-found: %e", r);
	else if (r == 0)
  801753:	85 c0                	test   %eax,%eax
  801755:	0f 84 30 02 00 00    	je     80198b <fs_test+0x2ec>
		panic("file_open /not-found succeeded!");
	if ((r = file_open("/newmotd", &f)) < 0)
  80175b:	83 ec 08             	sub    $0x8,%esp
  80175e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	68 71 3c 80 00       	push   $0x803c71
  801767:	e8 d5 f5 ff ff       	call   800d41 <file_open>
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	0f 88 28 02 00 00    	js     80199f <fs_test+0x300>
		panic("file_open /newmotd: %e", r);
	cprintf("file_open is good\n");
  801777:	83 ec 0c             	sub    $0xc,%esp
  80177a:	68 91 3c 80 00       	push   $0x803c91
  80177f:	e8 74 04 00 00       	call   801bf8 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801784:	83 c4 0c             	add    $0xc,%esp
  801787:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178a:	50                   	push   %eax
  80178b:	6a 00                	push   $0x0
  80178d:	ff 75 f4             	pushl  -0xc(%ebp)
  801790:	e8 14 f3 ff ff       	call   800aa9 <file_get_block>
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	85 c0                	test   %eax,%eax
  80179a:	0f 88 11 02 00 00    	js     8019b1 <fs_test+0x312>
		panic("file_get_block: %e", r);
	if (strcmp(blk, msg) != 0)
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	68 d8 3d 80 00       	push   $0x803dd8
  8017a8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ab:	e8 0d 0b 00 00       	call   8022bd <strcmp>
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	0f 85 08 02 00 00    	jne    8019c3 <fs_test+0x324>
		panic("file_get_block returned wrong data");
	cprintf("file_get_block is good\n");
  8017bb:	83 ec 0c             	sub    $0xc,%esp
  8017be:	68 b7 3c 80 00       	push   $0x803cb7
  8017c3:	e8 30 04 00 00       	call   801bf8 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8017c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cb:	0f b6 10             	movzbl (%eax),%edx
  8017ce:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8017d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d3:	c1 e8 0c             	shr    $0xc,%eax
  8017d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	a8 40                	test   $0x40,%al
  8017e2:	0f 84 ef 01 00 00    	je     8019d7 <fs_test+0x338>
	file_flush(f);
  8017e8:	83 ec 0c             	sub    $0xc,%esp
  8017eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ee:	e8 9a f7 ff ff       	call   800f8d <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8017f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f6:	c1 e8 0c             	shr    $0xc,%eax
  8017f9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	a8 40                	test   $0x40,%al
  801805:	0f 85 e2 01 00 00    	jne    8019ed <fs_test+0x34e>
	cprintf("file_flush is good\n");
  80180b:	83 ec 0c             	sub    $0xc,%esp
  80180e:	68 eb 3c 80 00       	push   $0x803ceb
  801813:	e8 e0 03 00 00       	call   801bf8 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801818:	83 c4 08             	add    $0x8,%esp
  80181b:	6a 00                	push   $0x0
  80181d:	ff 75 f4             	pushl  -0xc(%ebp)
  801820:	e8 e3 f5 ff ff       	call   800e08 <file_set_size>
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	0f 88 d3 01 00 00    	js     801a03 <fs_test+0x364>
		panic("file_set_size: %e", r);
	assert(f->f_direct[0] == 0);
  801830:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801833:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  80183a:	0f 85 d5 01 00 00    	jne    801a15 <fs_test+0x376>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801840:	c1 e8 0c             	shr    $0xc,%eax
  801843:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80184a:	a8 40                	test   $0x40,%al
  80184c:	0f 85 d9 01 00 00    	jne    801a2b <fs_test+0x38c>
	cprintf("file_truncate is good\n");
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	68 3f 3d 80 00       	push   $0x803d3f
  80185a:	e8 99 03 00 00       	call   801bf8 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  80185f:	c7 04 24 d8 3d 80 00 	movl   $0x803dd8,(%esp)
  801866:	e8 75 09 00 00       	call   8021e0 <strlen>
  80186b:	83 c4 08             	add    $0x8,%esp
  80186e:	50                   	push   %eax
  80186f:	ff 75 f4             	pushl  -0xc(%ebp)
  801872:	e8 91 f5 ff ff       	call   800e08 <file_set_size>
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	85 c0                	test   %eax,%eax
  80187c:	0f 88 bf 01 00 00    	js     801a41 <fs_test+0x3a2>
		panic("file_set_size 2: %e", r);
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801885:	89 c2                	mov    %eax,%edx
  801887:	c1 ea 0c             	shr    $0xc,%edx
  80188a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801891:	f6 c2 40             	test   $0x40,%dl
  801894:	0f 85 b9 01 00 00    	jne    801a53 <fs_test+0x3b4>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  80189a:	83 ec 04             	sub    $0x4,%esp
  80189d:	8d 55 f0             	lea    -0x10(%ebp),%edx
  8018a0:	52                   	push   %edx
  8018a1:	6a 00                	push   $0x0
  8018a3:	50                   	push   %eax
  8018a4:	e8 00 f2 ff ff       	call   800aa9 <file_get_block>
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	85 c0                	test   %eax,%eax
  8018ae:	0f 88 b5 01 00 00    	js     801a69 <fs_test+0x3ca>
		panic("file_get_block 2: %e", r);
	strcpy(blk, msg);
  8018b4:	83 ec 08             	sub    $0x8,%esp
  8018b7:	68 d8 3d 80 00       	push   $0x803dd8
  8018bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8018bf:	e8 53 09 00 00       	call   802217 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8018c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c7:	c1 e8 0c             	shr    $0xc,%eax
  8018ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	a8 40                	test   $0x40,%al
  8018d6:	0f 84 9f 01 00 00    	je     801a7b <fs_test+0x3dc>
	file_flush(f);
  8018dc:	83 ec 0c             	sub    $0xc,%esp
  8018df:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e2:	e8 a6 f6 ff ff       	call   800f8d <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ea:	c1 e8 0c             	shr    $0xc,%eax
  8018ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	a8 40                	test   $0x40,%al
  8018f9:	0f 85 92 01 00 00    	jne    801a91 <fs_test+0x3f2>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801902:	c1 e8 0c             	shr    $0xc,%eax
  801905:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80190c:	a8 40                	test   $0x40,%al
  80190e:	0f 85 93 01 00 00    	jne    801aa7 <fs_test+0x408>
	cprintf("file rewrite is good\n");
  801914:	83 ec 0c             	sub    $0xc,%esp
  801917:	68 7f 3d 80 00       	push   $0x803d7f
  80191c:	e8 d7 02 00 00       	call   801bf8 <cprintf>
}
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801927:	c9                   	leave  
  801928:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  801929:	50                   	push   %eax
  80192a:	68 f0 3b 80 00       	push   $0x803bf0
  80192f:	6a 12                	push   $0x12
  801931:	68 03 3c 80 00       	push   $0x803c03
  801936:	e8 e2 01 00 00       	call   801b1d <_panic>
		panic("alloc_block: %e", r);
  80193b:	50                   	push   %eax
  80193c:	68 0d 3c 80 00       	push   $0x803c0d
  801941:	6a 17                	push   $0x17
  801943:	68 03 3c 80 00       	push   $0x803c03
  801948:	e8 d0 01 00 00       	call   801b1d <_panic>
	assert(bits[r/32] & (1 << (r%32)));
  80194d:	68 1d 3c 80 00       	push   $0x803c1d
  801952:	68 fd 38 80 00       	push   $0x8038fd
  801957:	6a 19                	push   $0x19
  801959:	68 03 3c 80 00       	push   $0x803c03
  80195e:	e8 ba 01 00 00       	call   801b1d <_panic>
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801963:	68 98 3d 80 00       	push   $0x803d98
  801968:	68 fd 38 80 00       	push   $0x8038fd
  80196d:	6a 1b                	push   $0x1b
  80196f:	68 03 3c 80 00       	push   $0x803c03
  801974:	e8 a4 01 00 00       	call   801b1d <_panic>
		panic("file_open /not-found: %e", r);
  801979:	50                   	push   %eax
  80197a:	68 58 3c 80 00       	push   $0x803c58
  80197f:	6a 1f                	push   $0x1f
  801981:	68 03 3c 80 00       	push   $0x803c03
  801986:	e8 92 01 00 00       	call   801b1d <_panic>
		panic("file_open /not-found succeeded!");
  80198b:	83 ec 04             	sub    $0x4,%esp
  80198e:	68 b8 3d 80 00       	push   $0x803db8
  801993:	6a 21                	push   $0x21
  801995:	68 03 3c 80 00       	push   $0x803c03
  80199a:	e8 7e 01 00 00       	call   801b1d <_panic>
		panic("file_open /newmotd: %e", r);
  80199f:	50                   	push   %eax
  8019a0:	68 7a 3c 80 00       	push   $0x803c7a
  8019a5:	6a 23                	push   $0x23
  8019a7:	68 03 3c 80 00       	push   $0x803c03
  8019ac:	e8 6c 01 00 00       	call   801b1d <_panic>
		panic("file_get_block: %e", r);
  8019b1:	50                   	push   %eax
  8019b2:	68 a4 3c 80 00       	push   $0x803ca4
  8019b7:	6a 27                	push   $0x27
  8019b9:	68 03 3c 80 00       	push   $0x803c03
  8019be:	e8 5a 01 00 00       	call   801b1d <_panic>
		panic("file_get_block returned wrong data");
  8019c3:	83 ec 04             	sub    $0x4,%esp
  8019c6:	68 00 3e 80 00       	push   $0x803e00
  8019cb:	6a 29                	push   $0x29
  8019cd:	68 03 3c 80 00       	push   $0x803c03
  8019d2:	e8 46 01 00 00       	call   801b1d <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8019d7:	68 d0 3c 80 00       	push   $0x803cd0
  8019dc:	68 fd 38 80 00       	push   $0x8038fd
  8019e1:	6a 2d                	push   $0x2d
  8019e3:	68 03 3c 80 00       	push   $0x803c03
  8019e8:	e8 30 01 00 00       	call   801b1d <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019ed:	68 cf 3c 80 00       	push   $0x803ccf
  8019f2:	68 fd 38 80 00       	push   $0x8038fd
  8019f7:	6a 2f                	push   $0x2f
  8019f9:	68 03 3c 80 00       	push   $0x803c03
  8019fe:	e8 1a 01 00 00       	call   801b1d <_panic>
		panic("file_set_size: %e", r);
  801a03:	50                   	push   %eax
  801a04:	68 ff 3c 80 00       	push   $0x803cff
  801a09:	6a 33                	push   $0x33
  801a0b:	68 03 3c 80 00       	push   $0x803c03
  801a10:	e8 08 01 00 00       	call   801b1d <_panic>
	assert(f->f_direct[0] == 0);
  801a15:	68 11 3d 80 00       	push   $0x803d11
  801a1a:	68 fd 38 80 00       	push   $0x8038fd
  801a1f:	6a 34                	push   $0x34
  801a21:	68 03 3c 80 00       	push   $0x803c03
  801a26:	e8 f2 00 00 00       	call   801b1d <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a2b:	68 25 3d 80 00       	push   $0x803d25
  801a30:	68 fd 38 80 00       	push   $0x8038fd
  801a35:	6a 35                	push   $0x35
  801a37:	68 03 3c 80 00       	push   $0x803c03
  801a3c:	e8 dc 00 00 00       	call   801b1d <_panic>
		panic("file_set_size 2: %e", r);
  801a41:	50                   	push   %eax
  801a42:	68 56 3d 80 00       	push   $0x803d56
  801a47:	6a 39                	push   $0x39
  801a49:	68 03 3c 80 00       	push   $0x803c03
  801a4e:	e8 ca 00 00 00       	call   801b1d <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a53:	68 25 3d 80 00       	push   $0x803d25
  801a58:	68 fd 38 80 00       	push   $0x8038fd
  801a5d:	6a 3a                	push   $0x3a
  801a5f:	68 03 3c 80 00       	push   $0x803c03
  801a64:	e8 b4 00 00 00       	call   801b1d <_panic>
		panic("file_get_block 2: %e", r);
  801a69:	50                   	push   %eax
  801a6a:	68 6a 3d 80 00       	push   $0x803d6a
  801a6f:	6a 3c                	push   $0x3c
  801a71:	68 03 3c 80 00       	push   $0x803c03
  801a76:	e8 a2 00 00 00       	call   801b1d <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a7b:	68 d0 3c 80 00       	push   $0x803cd0
  801a80:	68 fd 38 80 00       	push   $0x8038fd
  801a85:	6a 3e                	push   $0x3e
  801a87:	68 03 3c 80 00       	push   $0x803c03
  801a8c:	e8 8c 00 00 00       	call   801b1d <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a91:	68 cf 3c 80 00       	push   $0x803ccf
  801a96:	68 fd 38 80 00       	push   $0x8038fd
  801a9b:	6a 40                	push   $0x40
  801a9d:	68 03 3c 80 00       	push   $0x803c03
  801aa2:	e8 76 00 00 00       	call   801b1d <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801aa7:	68 25 3d 80 00       	push   $0x803d25
  801aac:	68 fd 38 80 00       	push   $0x8038fd
  801ab1:	6a 41                	push   $0x41
  801ab3:	68 03 3c 80 00       	push   $0x803c03
  801ab8:	e8 60 00 00 00       	call   801b1d <_panic>

00801abd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  801ac8:	e8 05 0b 00 00       	call   8025d2 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  801acd:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ad2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ad5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ada:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801adf:	85 db                	test   %ebx,%ebx
  801ae1:	7e 07                	jle    801aea <libmain+0x2d>
		binaryname = argv[0];
  801ae3:	8b 06                	mov    (%esi),%eax
  801ae5:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801aea:	83 ec 08             	sub    $0x8,%esp
  801aed:	56                   	push   %esi
  801aee:	53                   	push   %ebx
  801aef:	e8 65 fb ff ff       	call   801659 <umain>

	// exit gracefully
	exit();
  801af4:	e8 0a 00 00 00       	call   801b03 <exit>
}
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aff:	5b                   	pop    %ebx
  801b00:	5e                   	pop    %esi
  801b01:	5d                   	pop    %ebp
  801b02:	c3                   	ret    

00801b03 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801b09:	e8 52 10 00 00       	call   802b60 <close_all>
	sys_env_destroy(0);
  801b0e:	83 ec 0c             	sub    $0xc,%esp
  801b11:	6a 00                	push   $0x0
  801b13:	e8 79 0a 00 00       	call   802591 <sys_env_destroy>
}
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    

00801b1d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b22:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b25:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801b2b:	e8 a2 0a 00 00       	call   8025d2 <sys_getenvid>
  801b30:	83 ec 0c             	sub    $0xc,%esp
  801b33:	ff 75 0c             	pushl  0xc(%ebp)
  801b36:	ff 75 08             	pushl  0x8(%ebp)
  801b39:	56                   	push   %esi
  801b3a:	50                   	push   %eax
  801b3b:	68 30 3e 80 00       	push   $0x803e30
  801b40:	e8 b3 00 00 00       	call   801bf8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b45:	83 c4 18             	add    $0x18,%esp
  801b48:	53                   	push   %ebx
  801b49:	ff 75 10             	pushl  0x10(%ebp)
  801b4c:	e8 56 00 00 00       	call   801ba7 <vcprintf>
	cprintf("\n");
  801b51:	c7 04 24 3e 3a 80 00 	movl   $0x803a3e,(%esp)
  801b58:	e8 9b 00 00 00       	call   801bf8 <cprintf>
  801b5d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b60:	cc                   	int3   
  801b61:	eb fd                	jmp    801b60 <_panic+0x43>

00801b63 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	53                   	push   %ebx
  801b67:	83 ec 04             	sub    $0x4,%esp
  801b6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b6d:	8b 13                	mov    (%ebx),%edx
  801b6f:	8d 42 01             	lea    0x1(%edx),%eax
  801b72:	89 03                	mov    %eax,(%ebx)
  801b74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b77:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b7b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b80:	74 09                	je     801b8b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801b82:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801b8b:	83 ec 08             	sub    $0x8,%esp
  801b8e:	68 ff 00 00 00       	push   $0xff
  801b93:	8d 43 08             	lea    0x8(%ebx),%eax
  801b96:	50                   	push   %eax
  801b97:	e8 b8 09 00 00       	call   802554 <sys_cputs>
		b->idx = 0;
  801b9c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ba2:	83 c4 10             	add    $0x10,%esp
  801ba5:	eb db                	jmp    801b82 <putch+0x1f>

00801ba7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801bb0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801bb7:	00 00 00 
	b.cnt = 0;
  801bba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801bc1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801bc4:	ff 75 0c             	pushl  0xc(%ebp)
  801bc7:	ff 75 08             	pushl  0x8(%ebp)
  801bca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801bd0:	50                   	push   %eax
  801bd1:	68 63 1b 80 00       	push   $0x801b63
  801bd6:	e8 1a 01 00 00       	call   801cf5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801bdb:	83 c4 08             	add    $0x8,%esp
  801bde:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801be4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801bea:	50                   	push   %eax
  801beb:	e8 64 09 00 00       	call   802554 <sys_cputs>

	return b.cnt;
}
  801bf0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bfe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801c01:	50                   	push   %eax
  801c02:	ff 75 08             	pushl  0x8(%ebp)
  801c05:	e8 9d ff ff ff       	call   801ba7 <vcprintf>
	va_end(ap);

	return cnt;
}
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	57                   	push   %edi
  801c10:	56                   	push   %esi
  801c11:	53                   	push   %ebx
  801c12:	83 ec 1c             	sub    $0x1c,%esp
  801c15:	89 c7                	mov    %eax,%edi
  801c17:	89 d6                	mov    %edx,%esi
  801c19:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c22:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801c25:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801c28:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c2d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801c30:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801c33:	39 d3                	cmp    %edx,%ebx
  801c35:	72 05                	jb     801c3c <printnum+0x30>
  801c37:	39 45 10             	cmp    %eax,0x10(%ebp)
  801c3a:	77 7a                	ja     801cb6 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801c3c:	83 ec 0c             	sub    $0xc,%esp
  801c3f:	ff 75 18             	pushl  0x18(%ebp)
  801c42:	8b 45 14             	mov    0x14(%ebp),%eax
  801c45:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801c48:	53                   	push   %ebx
  801c49:	ff 75 10             	pushl  0x10(%ebp)
  801c4c:	83 ec 08             	sub    $0x8,%esp
  801c4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c52:	ff 75 e0             	pushl  -0x20(%ebp)
  801c55:	ff 75 dc             	pushl  -0x24(%ebp)
  801c58:	ff 75 d8             	pushl  -0x28(%ebp)
  801c5b:	e8 20 1a 00 00       	call   803680 <__udivdi3>
  801c60:	83 c4 18             	add    $0x18,%esp
  801c63:	52                   	push   %edx
  801c64:	50                   	push   %eax
  801c65:	89 f2                	mov    %esi,%edx
  801c67:	89 f8                	mov    %edi,%eax
  801c69:	e8 9e ff ff ff       	call   801c0c <printnum>
  801c6e:	83 c4 20             	add    $0x20,%esp
  801c71:	eb 13                	jmp    801c86 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c73:	83 ec 08             	sub    $0x8,%esp
  801c76:	56                   	push   %esi
  801c77:	ff 75 18             	pushl  0x18(%ebp)
  801c7a:	ff d7                	call   *%edi
  801c7c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801c7f:	83 eb 01             	sub    $0x1,%ebx
  801c82:	85 db                	test   %ebx,%ebx
  801c84:	7f ed                	jg     801c73 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c86:	83 ec 08             	sub    $0x8,%esp
  801c89:	56                   	push   %esi
  801c8a:	83 ec 04             	sub    $0x4,%esp
  801c8d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c90:	ff 75 e0             	pushl  -0x20(%ebp)
  801c93:	ff 75 dc             	pushl  -0x24(%ebp)
  801c96:	ff 75 d8             	pushl  -0x28(%ebp)
  801c99:	e8 02 1b 00 00       	call   8037a0 <__umoddi3>
  801c9e:	83 c4 14             	add    $0x14,%esp
  801ca1:	0f be 80 53 3e 80 00 	movsbl 0x803e53(%eax),%eax
  801ca8:	50                   	push   %eax
  801ca9:	ff d7                	call   *%edi
}
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb1:	5b                   	pop    %ebx
  801cb2:	5e                   	pop    %esi
  801cb3:	5f                   	pop    %edi
  801cb4:	5d                   	pop    %ebp
  801cb5:	c3                   	ret    
  801cb6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801cb9:	eb c4                	jmp    801c7f <printnum+0x73>

00801cbb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801cc1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801cc5:	8b 10                	mov    (%eax),%edx
  801cc7:	3b 50 04             	cmp    0x4(%eax),%edx
  801cca:	73 0a                	jae    801cd6 <sprintputch+0x1b>
		*b->buf++ = ch;
  801ccc:	8d 4a 01             	lea    0x1(%edx),%ecx
  801ccf:	89 08                	mov    %ecx,(%eax)
  801cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd4:	88 02                	mov    %al,(%edx)
}
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    

00801cd8 <printfmt>:
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801cde:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801ce1:	50                   	push   %eax
  801ce2:	ff 75 10             	pushl  0x10(%ebp)
  801ce5:	ff 75 0c             	pushl  0xc(%ebp)
  801ce8:	ff 75 08             	pushl  0x8(%ebp)
  801ceb:	e8 05 00 00 00       	call   801cf5 <vprintfmt>
}
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	c9                   	leave  
  801cf4:	c3                   	ret    

00801cf5 <vprintfmt>:
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	57                   	push   %edi
  801cf9:	56                   	push   %esi
  801cfa:	53                   	push   %ebx
  801cfb:	83 ec 2c             	sub    $0x2c,%esp
  801cfe:	8b 75 08             	mov    0x8(%ebp),%esi
  801d01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d04:	8b 7d 10             	mov    0x10(%ebp),%edi
  801d07:	e9 c1 03 00 00       	jmp    8020cd <vprintfmt+0x3d8>
		padc = ' ';
  801d0c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801d10:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  801d17:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801d1e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801d25:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801d2a:	8d 47 01             	lea    0x1(%edi),%eax
  801d2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d30:	0f b6 17             	movzbl (%edi),%edx
  801d33:	8d 42 dd             	lea    -0x23(%edx),%eax
  801d36:	3c 55                	cmp    $0x55,%al
  801d38:	0f 87 12 04 00 00    	ja     802150 <vprintfmt+0x45b>
  801d3e:	0f b6 c0             	movzbl %al,%eax
  801d41:	ff 24 85 a0 3f 80 00 	jmp    *0x803fa0(,%eax,4)
  801d48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801d4b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801d4f:	eb d9                	jmp    801d2a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801d51:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801d54:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801d58:	eb d0                	jmp    801d2a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801d5a:	0f b6 d2             	movzbl %dl,%edx
  801d5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801d60:	b8 00 00 00 00       	mov    $0x0,%eax
  801d65:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801d68:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d6b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801d6f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801d72:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801d75:	83 f9 09             	cmp    $0x9,%ecx
  801d78:	77 55                	ja     801dcf <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801d7a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801d7d:	eb e9                	jmp    801d68 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801d7f:	8b 45 14             	mov    0x14(%ebp),%eax
  801d82:	8b 00                	mov    (%eax),%eax
  801d84:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801d87:	8b 45 14             	mov    0x14(%ebp),%eax
  801d8a:	8d 40 04             	lea    0x4(%eax),%eax
  801d8d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801d90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801d93:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d97:	79 91                	jns    801d2a <vprintfmt+0x35>
				width = precision, precision = -1;
  801d99:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801d9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d9f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801da6:	eb 82                	jmp    801d2a <vprintfmt+0x35>
  801da8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dab:	85 c0                	test   %eax,%eax
  801dad:	ba 00 00 00 00       	mov    $0x0,%edx
  801db2:	0f 49 d0             	cmovns %eax,%edx
  801db5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801db8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801dbb:	e9 6a ff ff ff       	jmp    801d2a <vprintfmt+0x35>
  801dc0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801dc3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801dca:	e9 5b ff ff ff       	jmp    801d2a <vprintfmt+0x35>
  801dcf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801dd2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801dd5:	eb bc                	jmp    801d93 <vprintfmt+0x9e>
			lflag++;
  801dd7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801dda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801ddd:	e9 48 ff ff ff       	jmp    801d2a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  801de2:	8b 45 14             	mov    0x14(%ebp),%eax
  801de5:	8d 78 04             	lea    0x4(%eax),%edi
  801de8:	83 ec 08             	sub    $0x8,%esp
  801deb:	53                   	push   %ebx
  801dec:	ff 30                	pushl  (%eax)
  801dee:	ff d6                	call   *%esi
			break;
  801df0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801df3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801df6:	e9 cf 02 00 00       	jmp    8020ca <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  801dfb:	8b 45 14             	mov    0x14(%ebp),%eax
  801dfe:	8d 78 04             	lea    0x4(%eax),%edi
  801e01:	8b 00                	mov    (%eax),%eax
  801e03:	99                   	cltd   
  801e04:	31 d0                	xor    %edx,%eax
  801e06:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801e08:	83 f8 0f             	cmp    $0xf,%eax
  801e0b:	7f 23                	jg     801e30 <vprintfmt+0x13b>
  801e0d:	8b 14 85 00 41 80 00 	mov    0x804100(,%eax,4),%edx
  801e14:	85 d2                	test   %edx,%edx
  801e16:	74 18                	je     801e30 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  801e18:	52                   	push   %edx
  801e19:	68 0f 39 80 00       	push   $0x80390f
  801e1e:	53                   	push   %ebx
  801e1f:	56                   	push   %esi
  801e20:	e8 b3 fe ff ff       	call   801cd8 <printfmt>
  801e25:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801e28:	89 7d 14             	mov    %edi,0x14(%ebp)
  801e2b:	e9 9a 02 00 00       	jmp    8020ca <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801e30:	50                   	push   %eax
  801e31:	68 6b 3e 80 00       	push   $0x803e6b
  801e36:	53                   	push   %ebx
  801e37:	56                   	push   %esi
  801e38:	e8 9b fe ff ff       	call   801cd8 <printfmt>
  801e3d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801e40:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801e43:	e9 82 02 00 00       	jmp    8020ca <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801e48:	8b 45 14             	mov    0x14(%ebp),%eax
  801e4b:	83 c0 04             	add    $0x4,%eax
  801e4e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801e51:	8b 45 14             	mov    0x14(%ebp),%eax
  801e54:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801e56:	85 ff                	test   %edi,%edi
  801e58:	b8 64 3e 80 00       	mov    $0x803e64,%eax
  801e5d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801e60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e64:	0f 8e bd 00 00 00    	jle    801f27 <vprintfmt+0x232>
  801e6a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801e6e:	75 0e                	jne    801e7e <vprintfmt+0x189>
  801e70:	89 75 08             	mov    %esi,0x8(%ebp)
  801e73:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801e76:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801e79:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801e7c:	eb 6d                	jmp    801eeb <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e7e:	83 ec 08             	sub    $0x8,%esp
  801e81:	ff 75 d0             	pushl  -0x30(%ebp)
  801e84:	57                   	push   %edi
  801e85:	e8 6e 03 00 00       	call   8021f8 <strnlen>
  801e8a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e8d:	29 c1                	sub    %eax,%ecx
  801e8f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801e92:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801e95:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801e99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e9c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e9f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801ea1:	eb 0f                	jmp    801eb2 <vprintfmt+0x1bd>
					putch(padc, putdat);
  801ea3:	83 ec 08             	sub    $0x8,%esp
  801ea6:	53                   	push   %ebx
  801ea7:	ff 75 e0             	pushl  -0x20(%ebp)
  801eaa:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801eac:	83 ef 01             	sub    $0x1,%edi
  801eaf:	83 c4 10             	add    $0x10,%esp
  801eb2:	85 ff                	test   %edi,%edi
  801eb4:	7f ed                	jg     801ea3 <vprintfmt+0x1ae>
  801eb6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801eb9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801ebc:	85 c9                	test   %ecx,%ecx
  801ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec3:	0f 49 c1             	cmovns %ecx,%eax
  801ec6:	29 c1                	sub    %eax,%ecx
  801ec8:	89 75 08             	mov    %esi,0x8(%ebp)
  801ecb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ece:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ed1:	89 cb                	mov    %ecx,%ebx
  801ed3:	eb 16                	jmp    801eeb <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  801ed5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801ed9:	75 31                	jne    801f0c <vprintfmt+0x217>
					putch(ch, putdat);
  801edb:	83 ec 08             	sub    $0x8,%esp
  801ede:	ff 75 0c             	pushl  0xc(%ebp)
  801ee1:	50                   	push   %eax
  801ee2:	ff 55 08             	call   *0x8(%ebp)
  801ee5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801ee8:	83 eb 01             	sub    $0x1,%ebx
  801eeb:	83 c7 01             	add    $0x1,%edi
  801eee:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801ef2:	0f be c2             	movsbl %dl,%eax
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	74 59                	je     801f52 <vprintfmt+0x25d>
  801ef9:	85 f6                	test   %esi,%esi
  801efb:	78 d8                	js     801ed5 <vprintfmt+0x1e0>
  801efd:	83 ee 01             	sub    $0x1,%esi
  801f00:	79 d3                	jns    801ed5 <vprintfmt+0x1e0>
  801f02:	89 df                	mov    %ebx,%edi
  801f04:	8b 75 08             	mov    0x8(%ebp),%esi
  801f07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f0a:	eb 37                	jmp    801f43 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  801f0c:	0f be d2             	movsbl %dl,%edx
  801f0f:	83 ea 20             	sub    $0x20,%edx
  801f12:	83 fa 5e             	cmp    $0x5e,%edx
  801f15:	76 c4                	jbe    801edb <vprintfmt+0x1e6>
					putch('?', putdat);
  801f17:	83 ec 08             	sub    $0x8,%esp
  801f1a:	ff 75 0c             	pushl  0xc(%ebp)
  801f1d:	6a 3f                	push   $0x3f
  801f1f:	ff 55 08             	call   *0x8(%ebp)
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	eb c1                	jmp    801ee8 <vprintfmt+0x1f3>
  801f27:	89 75 08             	mov    %esi,0x8(%ebp)
  801f2a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f2d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f30:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f33:	eb b6                	jmp    801eeb <vprintfmt+0x1f6>
				putch(' ', putdat);
  801f35:	83 ec 08             	sub    $0x8,%esp
  801f38:	53                   	push   %ebx
  801f39:	6a 20                	push   $0x20
  801f3b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801f3d:	83 ef 01             	sub    $0x1,%edi
  801f40:	83 c4 10             	add    $0x10,%esp
  801f43:	85 ff                	test   %edi,%edi
  801f45:	7f ee                	jg     801f35 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801f47:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801f4a:	89 45 14             	mov    %eax,0x14(%ebp)
  801f4d:	e9 78 01 00 00       	jmp    8020ca <vprintfmt+0x3d5>
  801f52:	89 df                	mov    %ebx,%edi
  801f54:	8b 75 08             	mov    0x8(%ebp),%esi
  801f57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f5a:	eb e7                	jmp    801f43 <vprintfmt+0x24e>
	if (lflag >= 2)
  801f5c:	83 f9 01             	cmp    $0x1,%ecx
  801f5f:	7e 3f                	jle    801fa0 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801f61:	8b 45 14             	mov    0x14(%ebp),%eax
  801f64:	8b 50 04             	mov    0x4(%eax),%edx
  801f67:	8b 00                	mov    (%eax),%eax
  801f69:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f6c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f6f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f72:	8d 40 08             	lea    0x8(%eax),%eax
  801f75:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801f78:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801f7c:	79 5c                	jns    801fda <vprintfmt+0x2e5>
				putch('-', putdat);
  801f7e:	83 ec 08             	sub    $0x8,%esp
  801f81:	53                   	push   %ebx
  801f82:	6a 2d                	push   $0x2d
  801f84:	ff d6                	call   *%esi
				num = -(long long) num;
  801f86:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f89:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801f8c:	f7 da                	neg    %edx
  801f8e:	83 d1 00             	adc    $0x0,%ecx
  801f91:	f7 d9                	neg    %ecx
  801f93:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801f96:	b8 0a 00 00 00       	mov    $0xa,%eax
  801f9b:	e9 10 01 00 00       	jmp    8020b0 <vprintfmt+0x3bb>
	else if (lflag)
  801fa0:	85 c9                	test   %ecx,%ecx
  801fa2:	75 1b                	jne    801fbf <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  801fa4:	8b 45 14             	mov    0x14(%ebp),%eax
  801fa7:	8b 00                	mov    (%eax),%eax
  801fa9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801fac:	89 c1                	mov    %eax,%ecx
  801fae:	c1 f9 1f             	sar    $0x1f,%ecx
  801fb1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801fb4:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb7:	8d 40 04             	lea    0x4(%eax),%eax
  801fba:	89 45 14             	mov    %eax,0x14(%ebp)
  801fbd:	eb b9                	jmp    801f78 <vprintfmt+0x283>
		return va_arg(*ap, long);
  801fbf:	8b 45 14             	mov    0x14(%ebp),%eax
  801fc2:	8b 00                	mov    (%eax),%eax
  801fc4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801fc7:	89 c1                	mov    %eax,%ecx
  801fc9:	c1 f9 1f             	sar    $0x1f,%ecx
  801fcc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801fcf:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd2:	8d 40 04             	lea    0x4(%eax),%eax
  801fd5:	89 45 14             	mov    %eax,0x14(%ebp)
  801fd8:	eb 9e                	jmp    801f78 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  801fda:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801fdd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801fe0:	b8 0a 00 00 00       	mov    $0xa,%eax
  801fe5:	e9 c6 00 00 00       	jmp    8020b0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801fea:	83 f9 01             	cmp    $0x1,%ecx
  801fed:	7e 18                	jle    802007 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  801fef:	8b 45 14             	mov    0x14(%ebp),%eax
  801ff2:	8b 10                	mov    (%eax),%edx
  801ff4:	8b 48 04             	mov    0x4(%eax),%ecx
  801ff7:	8d 40 08             	lea    0x8(%eax),%eax
  801ffa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801ffd:	b8 0a 00 00 00       	mov    $0xa,%eax
  802002:	e9 a9 00 00 00       	jmp    8020b0 <vprintfmt+0x3bb>
	else if (lflag)
  802007:	85 c9                	test   %ecx,%ecx
  802009:	75 1a                	jne    802025 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80200b:	8b 45 14             	mov    0x14(%ebp),%eax
  80200e:	8b 10                	mov    (%eax),%edx
  802010:	b9 00 00 00 00       	mov    $0x0,%ecx
  802015:	8d 40 04             	lea    0x4(%eax),%eax
  802018:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80201b:	b8 0a 00 00 00       	mov    $0xa,%eax
  802020:	e9 8b 00 00 00       	jmp    8020b0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  802025:	8b 45 14             	mov    0x14(%ebp),%eax
  802028:	8b 10                	mov    (%eax),%edx
  80202a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80202f:	8d 40 04             	lea    0x4(%eax),%eax
  802032:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  802035:	b8 0a 00 00 00       	mov    $0xa,%eax
  80203a:	eb 74                	jmp    8020b0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80203c:	83 f9 01             	cmp    $0x1,%ecx
  80203f:	7e 15                	jle    802056 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  802041:	8b 45 14             	mov    0x14(%ebp),%eax
  802044:	8b 10                	mov    (%eax),%edx
  802046:	8b 48 04             	mov    0x4(%eax),%ecx
  802049:	8d 40 08             	lea    0x8(%eax),%eax
  80204c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80204f:	b8 08 00 00 00       	mov    $0x8,%eax
  802054:	eb 5a                	jmp    8020b0 <vprintfmt+0x3bb>
	else if (lflag)
  802056:	85 c9                	test   %ecx,%ecx
  802058:	75 17                	jne    802071 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80205a:	8b 45 14             	mov    0x14(%ebp),%eax
  80205d:	8b 10                	mov    (%eax),%edx
  80205f:	b9 00 00 00 00       	mov    $0x0,%ecx
  802064:	8d 40 04             	lea    0x4(%eax),%eax
  802067:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80206a:	b8 08 00 00 00       	mov    $0x8,%eax
  80206f:	eb 3f                	jmp    8020b0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  802071:	8b 45 14             	mov    0x14(%ebp),%eax
  802074:	8b 10                	mov    (%eax),%edx
  802076:	b9 00 00 00 00       	mov    $0x0,%ecx
  80207b:	8d 40 04             	lea    0x4(%eax),%eax
  80207e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  802081:	b8 08 00 00 00       	mov    $0x8,%eax
  802086:	eb 28                	jmp    8020b0 <vprintfmt+0x3bb>
			putch('0', putdat);
  802088:	83 ec 08             	sub    $0x8,%esp
  80208b:	53                   	push   %ebx
  80208c:	6a 30                	push   $0x30
  80208e:	ff d6                	call   *%esi
			putch('x', putdat);
  802090:	83 c4 08             	add    $0x8,%esp
  802093:	53                   	push   %ebx
  802094:	6a 78                	push   $0x78
  802096:	ff d6                	call   *%esi
			num = (unsigned long long)
  802098:	8b 45 14             	mov    0x14(%ebp),%eax
  80209b:	8b 10                	mov    (%eax),%edx
  80209d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8020a2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8020a5:	8d 40 04             	lea    0x4(%eax),%eax
  8020a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8020ab:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8020b0:	83 ec 0c             	sub    $0xc,%esp
  8020b3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8020b7:	57                   	push   %edi
  8020b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8020bb:	50                   	push   %eax
  8020bc:	51                   	push   %ecx
  8020bd:	52                   	push   %edx
  8020be:	89 da                	mov    %ebx,%edx
  8020c0:	89 f0                	mov    %esi,%eax
  8020c2:	e8 45 fb ff ff       	call   801c0c <printnum>
			break;
  8020c7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8020ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8020cd:	83 c7 01             	add    $0x1,%edi
  8020d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8020d4:	83 f8 25             	cmp    $0x25,%eax
  8020d7:	0f 84 2f fc ff ff    	je     801d0c <vprintfmt+0x17>
			if (ch == '\0')
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	0f 84 8b 00 00 00    	je     802170 <vprintfmt+0x47b>
			putch(ch, putdat);
  8020e5:	83 ec 08             	sub    $0x8,%esp
  8020e8:	53                   	push   %ebx
  8020e9:	50                   	push   %eax
  8020ea:	ff d6                	call   *%esi
  8020ec:	83 c4 10             	add    $0x10,%esp
  8020ef:	eb dc                	jmp    8020cd <vprintfmt+0x3d8>
	if (lflag >= 2)
  8020f1:	83 f9 01             	cmp    $0x1,%ecx
  8020f4:	7e 15                	jle    80210b <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8020f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8020f9:	8b 10                	mov    (%eax),%edx
  8020fb:	8b 48 04             	mov    0x4(%eax),%ecx
  8020fe:	8d 40 08             	lea    0x8(%eax),%eax
  802101:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  802104:	b8 10 00 00 00       	mov    $0x10,%eax
  802109:	eb a5                	jmp    8020b0 <vprintfmt+0x3bb>
	else if (lflag)
  80210b:	85 c9                	test   %ecx,%ecx
  80210d:	75 17                	jne    802126 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80210f:	8b 45 14             	mov    0x14(%ebp),%eax
  802112:	8b 10                	mov    (%eax),%edx
  802114:	b9 00 00 00 00       	mov    $0x0,%ecx
  802119:	8d 40 04             	lea    0x4(%eax),%eax
  80211c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80211f:	b8 10 00 00 00       	mov    $0x10,%eax
  802124:	eb 8a                	jmp    8020b0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  802126:	8b 45 14             	mov    0x14(%ebp),%eax
  802129:	8b 10                	mov    (%eax),%edx
  80212b:	b9 00 00 00 00       	mov    $0x0,%ecx
  802130:	8d 40 04             	lea    0x4(%eax),%eax
  802133:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  802136:	b8 10 00 00 00       	mov    $0x10,%eax
  80213b:	e9 70 ff ff ff       	jmp    8020b0 <vprintfmt+0x3bb>
			putch(ch, putdat);
  802140:	83 ec 08             	sub    $0x8,%esp
  802143:	53                   	push   %ebx
  802144:	6a 25                	push   $0x25
  802146:	ff d6                	call   *%esi
			break;
  802148:	83 c4 10             	add    $0x10,%esp
  80214b:	e9 7a ff ff ff       	jmp    8020ca <vprintfmt+0x3d5>
			putch('%', putdat);
  802150:	83 ec 08             	sub    $0x8,%esp
  802153:	53                   	push   %ebx
  802154:	6a 25                	push   $0x25
  802156:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  802158:	83 c4 10             	add    $0x10,%esp
  80215b:	89 f8                	mov    %edi,%eax
  80215d:	eb 03                	jmp    802162 <vprintfmt+0x46d>
  80215f:	83 e8 01             	sub    $0x1,%eax
  802162:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  802166:	75 f7                	jne    80215f <vprintfmt+0x46a>
  802168:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80216b:	e9 5a ff ff ff       	jmp    8020ca <vprintfmt+0x3d5>
}
  802170:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    

00802178 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	83 ec 18             	sub    $0x18,%esp
  80217e:	8b 45 08             	mov    0x8(%ebp),%eax
  802181:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802184:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802187:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80218b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80218e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802195:	85 c0                	test   %eax,%eax
  802197:	74 26                	je     8021bf <vsnprintf+0x47>
  802199:	85 d2                	test   %edx,%edx
  80219b:	7e 22                	jle    8021bf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80219d:	ff 75 14             	pushl  0x14(%ebp)
  8021a0:	ff 75 10             	pushl  0x10(%ebp)
  8021a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8021a6:	50                   	push   %eax
  8021a7:	68 bb 1c 80 00       	push   $0x801cbb
  8021ac:	e8 44 fb ff ff       	call   801cf5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8021b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8021b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ba:	83 c4 10             	add    $0x10,%esp
}
  8021bd:	c9                   	leave  
  8021be:	c3                   	ret    
		return -E_INVAL;
  8021bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8021c4:	eb f7                	jmp    8021bd <vsnprintf+0x45>

008021c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8021cc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8021cf:	50                   	push   %eax
  8021d0:	ff 75 10             	pushl  0x10(%ebp)
  8021d3:	ff 75 0c             	pushl  0xc(%ebp)
  8021d6:	ff 75 08             	pushl  0x8(%ebp)
  8021d9:	e8 9a ff ff ff       	call   802178 <vsnprintf>
	va_end(ap);

	return rc;
}
  8021de:	c9                   	leave  
  8021df:	c3                   	ret    

008021e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8021e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021eb:	eb 03                	jmp    8021f0 <strlen+0x10>
		n++;
  8021ed:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8021f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8021f4:	75 f7                	jne    8021ed <strlen+0xd>
	return n;
}
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    

008021f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802201:	b8 00 00 00 00       	mov    $0x0,%eax
  802206:	eb 03                	jmp    80220b <strnlen+0x13>
		n++;
  802208:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80220b:	39 d0                	cmp    %edx,%eax
  80220d:	74 06                	je     802215 <strnlen+0x1d>
  80220f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  802213:	75 f3                	jne    802208 <strnlen+0x10>
	return n;
}
  802215:	5d                   	pop    %ebp
  802216:	c3                   	ret    

00802217 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	53                   	push   %ebx
  80221b:	8b 45 08             	mov    0x8(%ebp),%eax
  80221e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802221:	89 c2                	mov    %eax,%edx
  802223:	83 c1 01             	add    $0x1,%ecx
  802226:	83 c2 01             	add    $0x1,%edx
  802229:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80222d:	88 5a ff             	mov    %bl,-0x1(%edx)
  802230:	84 db                	test   %bl,%bl
  802232:	75 ef                	jne    802223 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802234:	5b                   	pop    %ebx
  802235:	5d                   	pop    %ebp
  802236:	c3                   	ret    

00802237 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	53                   	push   %ebx
  80223b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80223e:	53                   	push   %ebx
  80223f:	e8 9c ff ff ff       	call   8021e0 <strlen>
  802244:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802247:	ff 75 0c             	pushl  0xc(%ebp)
  80224a:	01 d8                	add    %ebx,%eax
  80224c:	50                   	push   %eax
  80224d:	e8 c5 ff ff ff       	call   802217 <strcpy>
	return dst;
}
  802252:	89 d8                	mov    %ebx,%eax
  802254:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802257:	c9                   	leave  
  802258:	c3                   	ret    

00802259 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802259:	55                   	push   %ebp
  80225a:	89 e5                	mov    %esp,%ebp
  80225c:	56                   	push   %esi
  80225d:	53                   	push   %ebx
  80225e:	8b 75 08             	mov    0x8(%ebp),%esi
  802261:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802264:	89 f3                	mov    %esi,%ebx
  802266:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802269:	89 f2                	mov    %esi,%edx
  80226b:	eb 0f                	jmp    80227c <strncpy+0x23>
		*dst++ = *src;
  80226d:	83 c2 01             	add    $0x1,%edx
  802270:	0f b6 01             	movzbl (%ecx),%eax
  802273:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802276:	80 39 01             	cmpb   $0x1,(%ecx)
  802279:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80227c:	39 da                	cmp    %ebx,%edx
  80227e:	75 ed                	jne    80226d <strncpy+0x14>
	}
	return ret;
}
  802280:	89 f0                	mov    %esi,%eax
  802282:	5b                   	pop    %ebx
  802283:	5e                   	pop    %esi
  802284:	5d                   	pop    %ebp
  802285:	c3                   	ret    

00802286 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802286:	55                   	push   %ebp
  802287:	89 e5                	mov    %esp,%ebp
  802289:	56                   	push   %esi
  80228a:	53                   	push   %ebx
  80228b:	8b 75 08             	mov    0x8(%ebp),%esi
  80228e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802291:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802294:	89 f0                	mov    %esi,%eax
  802296:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80229a:	85 c9                	test   %ecx,%ecx
  80229c:	75 0b                	jne    8022a9 <strlcpy+0x23>
  80229e:	eb 17                	jmp    8022b7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8022a0:	83 c2 01             	add    $0x1,%edx
  8022a3:	83 c0 01             	add    $0x1,%eax
  8022a6:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8022a9:	39 d8                	cmp    %ebx,%eax
  8022ab:	74 07                	je     8022b4 <strlcpy+0x2e>
  8022ad:	0f b6 0a             	movzbl (%edx),%ecx
  8022b0:	84 c9                	test   %cl,%cl
  8022b2:	75 ec                	jne    8022a0 <strlcpy+0x1a>
		*dst = '\0';
  8022b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8022b7:	29 f0                	sub    %esi,%eax
}
  8022b9:	5b                   	pop    %ebx
  8022ba:	5e                   	pop    %esi
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    

008022bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8022bd:	55                   	push   %ebp
  8022be:	89 e5                	mov    %esp,%ebp
  8022c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8022c6:	eb 06                	jmp    8022ce <strcmp+0x11>
		p++, q++;
  8022c8:	83 c1 01             	add    $0x1,%ecx
  8022cb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8022ce:	0f b6 01             	movzbl (%ecx),%eax
  8022d1:	84 c0                	test   %al,%al
  8022d3:	74 04                	je     8022d9 <strcmp+0x1c>
  8022d5:	3a 02                	cmp    (%edx),%al
  8022d7:	74 ef                	je     8022c8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8022d9:	0f b6 c0             	movzbl %al,%eax
  8022dc:	0f b6 12             	movzbl (%edx),%edx
  8022df:	29 d0                	sub    %edx,%eax
}
  8022e1:	5d                   	pop    %ebp
  8022e2:	c3                   	ret    

008022e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8022e3:	55                   	push   %ebp
  8022e4:	89 e5                	mov    %esp,%ebp
  8022e6:	53                   	push   %ebx
  8022e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022ed:	89 c3                	mov    %eax,%ebx
  8022ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8022f2:	eb 06                	jmp    8022fa <strncmp+0x17>
		n--, p++, q++;
  8022f4:	83 c0 01             	add    $0x1,%eax
  8022f7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8022fa:	39 d8                	cmp    %ebx,%eax
  8022fc:	74 16                	je     802314 <strncmp+0x31>
  8022fe:	0f b6 08             	movzbl (%eax),%ecx
  802301:	84 c9                	test   %cl,%cl
  802303:	74 04                	je     802309 <strncmp+0x26>
  802305:	3a 0a                	cmp    (%edx),%cl
  802307:	74 eb                	je     8022f4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802309:	0f b6 00             	movzbl (%eax),%eax
  80230c:	0f b6 12             	movzbl (%edx),%edx
  80230f:	29 d0                	sub    %edx,%eax
}
  802311:	5b                   	pop    %ebx
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    
		return 0;
  802314:	b8 00 00 00 00       	mov    $0x0,%eax
  802319:	eb f6                	jmp    802311 <strncmp+0x2e>

0080231b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80231b:	55                   	push   %ebp
  80231c:	89 e5                	mov    %esp,%ebp
  80231e:	8b 45 08             	mov    0x8(%ebp),%eax
  802321:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802325:	0f b6 10             	movzbl (%eax),%edx
  802328:	84 d2                	test   %dl,%dl
  80232a:	74 09                	je     802335 <strchr+0x1a>
		if (*s == c)
  80232c:	38 ca                	cmp    %cl,%dl
  80232e:	74 0a                	je     80233a <strchr+0x1f>
	for (; *s; s++)
  802330:	83 c0 01             	add    $0x1,%eax
  802333:	eb f0                	jmp    802325 <strchr+0xa>
			return (char *) s;
	return 0;
  802335:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80233a:	5d                   	pop    %ebp
  80233b:	c3                   	ret    

0080233c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80233c:	55                   	push   %ebp
  80233d:	89 e5                	mov    %esp,%ebp
  80233f:	8b 45 08             	mov    0x8(%ebp),%eax
  802342:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802346:	eb 03                	jmp    80234b <strfind+0xf>
  802348:	83 c0 01             	add    $0x1,%eax
  80234b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80234e:	38 ca                	cmp    %cl,%dl
  802350:	74 04                	je     802356 <strfind+0x1a>
  802352:	84 d2                	test   %dl,%dl
  802354:	75 f2                	jne    802348 <strfind+0xc>
			break;
	return (char *) s;
}
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    

00802358 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	57                   	push   %edi
  80235c:	56                   	push   %esi
  80235d:	53                   	push   %ebx
  80235e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802361:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802364:	85 c9                	test   %ecx,%ecx
  802366:	74 13                	je     80237b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802368:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80236e:	75 05                	jne    802375 <memset+0x1d>
  802370:	f6 c1 03             	test   $0x3,%cl
  802373:	74 0d                	je     802382 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802375:	8b 45 0c             	mov    0xc(%ebp),%eax
  802378:	fc                   	cld    
  802379:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80237b:	89 f8                	mov    %edi,%eax
  80237d:	5b                   	pop    %ebx
  80237e:	5e                   	pop    %esi
  80237f:	5f                   	pop    %edi
  802380:	5d                   	pop    %ebp
  802381:	c3                   	ret    
		c &= 0xFF;
  802382:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802386:	89 d3                	mov    %edx,%ebx
  802388:	c1 e3 08             	shl    $0x8,%ebx
  80238b:	89 d0                	mov    %edx,%eax
  80238d:	c1 e0 18             	shl    $0x18,%eax
  802390:	89 d6                	mov    %edx,%esi
  802392:	c1 e6 10             	shl    $0x10,%esi
  802395:	09 f0                	or     %esi,%eax
  802397:	09 c2                	or     %eax,%edx
  802399:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80239b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80239e:	89 d0                	mov    %edx,%eax
  8023a0:	fc                   	cld    
  8023a1:	f3 ab                	rep stos %eax,%es:(%edi)
  8023a3:	eb d6                	jmp    80237b <memset+0x23>

008023a5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8023a5:	55                   	push   %ebp
  8023a6:	89 e5                	mov    %esp,%ebp
  8023a8:	57                   	push   %edi
  8023a9:	56                   	push   %esi
  8023aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8023b3:	39 c6                	cmp    %eax,%esi
  8023b5:	73 35                	jae    8023ec <memmove+0x47>
  8023b7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8023ba:	39 c2                	cmp    %eax,%edx
  8023bc:	76 2e                	jbe    8023ec <memmove+0x47>
		s += n;
		d += n;
  8023be:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8023c1:	89 d6                	mov    %edx,%esi
  8023c3:	09 fe                	or     %edi,%esi
  8023c5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8023cb:	74 0c                	je     8023d9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8023cd:	83 ef 01             	sub    $0x1,%edi
  8023d0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8023d3:	fd                   	std    
  8023d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8023d6:	fc                   	cld    
  8023d7:	eb 21                	jmp    8023fa <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8023d9:	f6 c1 03             	test   $0x3,%cl
  8023dc:	75 ef                	jne    8023cd <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8023de:	83 ef 04             	sub    $0x4,%edi
  8023e1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8023e4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8023e7:	fd                   	std    
  8023e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8023ea:	eb ea                	jmp    8023d6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8023ec:	89 f2                	mov    %esi,%edx
  8023ee:	09 c2                	or     %eax,%edx
  8023f0:	f6 c2 03             	test   $0x3,%dl
  8023f3:	74 09                	je     8023fe <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8023f5:	89 c7                	mov    %eax,%edi
  8023f7:	fc                   	cld    
  8023f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8023fa:	5e                   	pop    %esi
  8023fb:	5f                   	pop    %edi
  8023fc:	5d                   	pop    %ebp
  8023fd:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8023fe:	f6 c1 03             	test   $0x3,%cl
  802401:	75 f2                	jne    8023f5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802403:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  802406:	89 c7                	mov    %eax,%edi
  802408:	fc                   	cld    
  802409:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80240b:	eb ed                	jmp    8023fa <memmove+0x55>

0080240d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80240d:	55                   	push   %ebp
  80240e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802410:	ff 75 10             	pushl  0x10(%ebp)
  802413:	ff 75 0c             	pushl  0xc(%ebp)
  802416:	ff 75 08             	pushl  0x8(%ebp)
  802419:	e8 87 ff ff ff       	call   8023a5 <memmove>
}
  80241e:	c9                   	leave  
  80241f:	c3                   	ret    

00802420 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	56                   	push   %esi
  802424:	53                   	push   %ebx
  802425:	8b 45 08             	mov    0x8(%ebp),%eax
  802428:	8b 55 0c             	mov    0xc(%ebp),%edx
  80242b:	89 c6                	mov    %eax,%esi
  80242d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802430:	39 f0                	cmp    %esi,%eax
  802432:	74 1c                	je     802450 <memcmp+0x30>
		if (*s1 != *s2)
  802434:	0f b6 08             	movzbl (%eax),%ecx
  802437:	0f b6 1a             	movzbl (%edx),%ebx
  80243a:	38 d9                	cmp    %bl,%cl
  80243c:	75 08                	jne    802446 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80243e:	83 c0 01             	add    $0x1,%eax
  802441:	83 c2 01             	add    $0x1,%edx
  802444:	eb ea                	jmp    802430 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  802446:	0f b6 c1             	movzbl %cl,%eax
  802449:	0f b6 db             	movzbl %bl,%ebx
  80244c:	29 d8                	sub    %ebx,%eax
  80244e:	eb 05                	jmp    802455 <memcmp+0x35>
	}

	return 0;
  802450:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802455:	5b                   	pop    %ebx
  802456:	5e                   	pop    %esi
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    

00802459 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802459:	55                   	push   %ebp
  80245a:	89 e5                	mov    %esp,%ebp
  80245c:	8b 45 08             	mov    0x8(%ebp),%eax
  80245f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  802462:	89 c2                	mov    %eax,%edx
  802464:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802467:	39 d0                	cmp    %edx,%eax
  802469:	73 09                	jae    802474 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80246b:	38 08                	cmp    %cl,(%eax)
  80246d:	74 05                	je     802474 <memfind+0x1b>
	for (; s < ends; s++)
  80246f:	83 c0 01             	add    $0x1,%eax
  802472:	eb f3                	jmp    802467 <memfind+0xe>
			break;
	return (void *) s;
}
  802474:	5d                   	pop    %ebp
  802475:	c3                   	ret    

00802476 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802476:	55                   	push   %ebp
  802477:	89 e5                	mov    %esp,%ebp
  802479:	57                   	push   %edi
  80247a:	56                   	push   %esi
  80247b:	53                   	push   %ebx
  80247c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80247f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802482:	eb 03                	jmp    802487 <strtol+0x11>
		s++;
  802484:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  802487:	0f b6 01             	movzbl (%ecx),%eax
  80248a:	3c 20                	cmp    $0x20,%al
  80248c:	74 f6                	je     802484 <strtol+0xe>
  80248e:	3c 09                	cmp    $0x9,%al
  802490:	74 f2                	je     802484 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  802492:	3c 2b                	cmp    $0x2b,%al
  802494:	74 2e                	je     8024c4 <strtol+0x4e>
	int neg = 0;
  802496:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80249b:	3c 2d                	cmp    $0x2d,%al
  80249d:	74 2f                	je     8024ce <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80249f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8024a5:	75 05                	jne    8024ac <strtol+0x36>
  8024a7:	80 39 30             	cmpb   $0x30,(%ecx)
  8024aa:	74 2c                	je     8024d8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8024ac:	85 db                	test   %ebx,%ebx
  8024ae:	75 0a                	jne    8024ba <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8024b0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8024b5:	80 39 30             	cmpb   $0x30,(%ecx)
  8024b8:	74 28                	je     8024e2 <strtol+0x6c>
		base = 10;
  8024ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8024bf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8024c2:	eb 50                	jmp    802514 <strtol+0x9e>
		s++;
  8024c4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8024c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8024cc:	eb d1                	jmp    80249f <strtol+0x29>
		s++, neg = 1;
  8024ce:	83 c1 01             	add    $0x1,%ecx
  8024d1:	bf 01 00 00 00       	mov    $0x1,%edi
  8024d6:	eb c7                	jmp    80249f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8024d8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8024dc:	74 0e                	je     8024ec <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8024de:	85 db                	test   %ebx,%ebx
  8024e0:	75 d8                	jne    8024ba <strtol+0x44>
		s++, base = 8;
  8024e2:	83 c1 01             	add    $0x1,%ecx
  8024e5:	bb 08 00 00 00       	mov    $0x8,%ebx
  8024ea:	eb ce                	jmp    8024ba <strtol+0x44>
		s += 2, base = 16;
  8024ec:	83 c1 02             	add    $0x2,%ecx
  8024ef:	bb 10 00 00 00       	mov    $0x10,%ebx
  8024f4:	eb c4                	jmp    8024ba <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8024f6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8024f9:	89 f3                	mov    %esi,%ebx
  8024fb:	80 fb 19             	cmp    $0x19,%bl
  8024fe:	77 29                	ja     802529 <strtol+0xb3>
			dig = *s - 'a' + 10;
  802500:	0f be d2             	movsbl %dl,%edx
  802503:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  802506:	3b 55 10             	cmp    0x10(%ebp),%edx
  802509:	7d 30                	jge    80253b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  80250b:	83 c1 01             	add    $0x1,%ecx
  80250e:	0f af 45 10          	imul   0x10(%ebp),%eax
  802512:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  802514:	0f b6 11             	movzbl (%ecx),%edx
  802517:	8d 72 d0             	lea    -0x30(%edx),%esi
  80251a:	89 f3                	mov    %esi,%ebx
  80251c:	80 fb 09             	cmp    $0x9,%bl
  80251f:	77 d5                	ja     8024f6 <strtol+0x80>
			dig = *s - '0';
  802521:	0f be d2             	movsbl %dl,%edx
  802524:	83 ea 30             	sub    $0x30,%edx
  802527:	eb dd                	jmp    802506 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  802529:	8d 72 bf             	lea    -0x41(%edx),%esi
  80252c:	89 f3                	mov    %esi,%ebx
  80252e:	80 fb 19             	cmp    $0x19,%bl
  802531:	77 08                	ja     80253b <strtol+0xc5>
			dig = *s - 'A' + 10;
  802533:	0f be d2             	movsbl %dl,%edx
  802536:	83 ea 37             	sub    $0x37,%edx
  802539:	eb cb                	jmp    802506 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  80253b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80253f:	74 05                	je     802546 <strtol+0xd0>
		*endptr = (char *) s;
  802541:	8b 75 0c             	mov    0xc(%ebp),%esi
  802544:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  802546:	89 c2                	mov    %eax,%edx
  802548:	f7 da                	neg    %edx
  80254a:	85 ff                	test   %edi,%edi
  80254c:	0f 45 c2             	cmovne %edx,%eax
}
  80254f:	5b                   	pop    %ebx
  802550:	5e                   	pop    %esi
  802551:	5f                   	pop    %edi
  802552:	5d                   	pop    %ebp
  802553:	c3                   	ret    

00802554 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802554:	55                   	push   %ebp
  802555:	89 e5                	mov    %esp,%ebp
  802557:	57                   	push   %edi
  802558:	56                   	push   %esi
  802559:	53                   	push   %ebx
	asm volatile("int %1\n"
  80255a:	b8 00 00 00 00       	mov    $0x0,%eax
  80255f:	8b 55 08             	mov    0x8(%ebp),%edx
  802562:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802565:	89 c3                	mov    %eax,%ebx
  802567:	89 c7                	mov    %eax,%edi
  802569:	89 c6                	mov    %eax,%esi
  80256b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80256d:	5b                   	pop    %ebx
  80256e:	5e                   	pop    %esi
  80256f:	5f                   	pop    %edi
  802570:	5d                   	pop    %ebp
  802571:	c3                   	ret    

00802572 <sys_cgetc>:

int
sys_cgetc(void)
{
  802572:	55                   	push   %ebp
  802573:	89 e5                	mov    %esp,%ebp
  802575:	57                   	push   %edi
  802576:	56                   	push   %esi
  802577:	53                   	push   %ebx
	asm volatile("int %1\n"
  802578:	ba 00 00 00 00       	mov    $0x0,%edx
  80257d:	b8 01 00 00 00       	mov    $0x1,%eax
  802582:	89 d1                	mov    %edx,%ecx
  802584:	89 d3                	mov    %edx,%ebx
  802586:	89 d7                	mov    %edx,%edi
  802588:	89 d6                	mov    %edx,%esi
  80258a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80258c:	5b                   	pop    %ebx
  80258d:	5e                   	pop    %esi
  80258e:	5f                   	pop    %edi
  80258f:	5d                   	pop    %ebp
  802590:	c3                   	ret    

00802591 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802591:	55                   	push   %ebp
  802592:	89 e5                	mov    %esp,%ebp
  802594:	57                   	push   %edi
  802595:	56                   	push   %esi
  802596:	53                   	push   %ebx
  802597:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80259a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80259f:	8b 55 08             	mov    0x8(%ebp),%edx
  8025a2:	b8 03 00 00 00       	mov    $0x3,%eax
  8025a7:	89 cb                	mov    %ecx,%ebx
  8025a9:	89 cf                	mov    %ecx,%edi
  8025ab:	89 ce                	mov    %ecx,%esi
  8025ad:	cd 30                	int    $0x30
	if(check && ret > 0)
  8025af:	85 c0                	test   %eax,%eax
  8025b1:	7f 08                	jg     8025bb <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8025b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025b6:	5b                   	pop    %ebx
  8025b7:	5e                   	pop    %esi
  8025b8:	5f                   	pop    %edi
  8025b9:	5d                   	pop    %ebp
  8025ba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8025bb:	83 ec 0c             	sub    $0xc,%esp
  8025be:	50                   	push   %eax
  8025bf:	6a 03                	push   $0x3
  8025c1:	68 5f 41 80 00       	push   $0x80415f
  8025c6:	6a 23                	push   $0x23
  8025c8:	68 7c 41 80 00       	push   $0x80417c
  8025cd:	e8 4b f5 ff ff       	call   801b1d <_panic>

008025d2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8025d2:	55                   	push   %ebp
  8025d3:	89 e5                	mov    %esp,%ebp
  8025d5:	57                   	push   %edi
  8025d6:	56                   	push   %esi
  8025d7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8025d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8025dd:	b8 02 00 00 00       	mov    $0x2,%eax
  8025e2:	89 d1                	mov    %edx,%ecx
  8025e4:	89 d3                	mov    %edx,%ebx
  8025e6:	89 d7                	mov    %edx,%edi
  8025e8:	89 d6                	mov    %edx,%esi
  8025ea:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8025ec:	5b                   	pop    %ebx
  8025ed:	5e                   	pop    %esi
  8025ee:	5f                   	pop    %edi
  8025ef:	5d                   	pop    %ebp
  8025f0:	c3                   	ret    

008025f1 <sys_yield>:

void
sys_yield(void)
{
  8025f1:	55                   	push   %ebp
  8025f2:	89 e5                	mov    %esp,%ebp
  8025f4:	57                   	push   %edi
  8025f5:	56                   	push   %esi
  8025f6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8025f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8025fc:	b8 0b 00 00 00       	mov    $0xb,%eax
  802601:	89 d1                	mov    %edx,%ecx
  802603:	89 d3                	mov    %edx,%ebx
  802605:	89 d7                	mov    %edx,%edi
  802607:	89 d6                	mov    %edx,%esi
  802609:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80260b:	5b                   	pop    %ebx
  80260c:	5e                   	pop    %esi
  80260d:	5f                   	pop    %edi
  80260e:	5d                   	pop    %ebp
  80260f:	c3                   	ret    

00802610 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802610:	55                   	push   %ebp
  802611:	89 e5                	mov    %esp,%ebp
  802613:	57                   	push   %edi
  802614:	56                   	push   %esi
  802615:	53                   	push   %ebx
  802616:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802619:	be 00 00 00 00       	mov    $0x0,%esi
  80261e:	8b 55 08             	mov    0x8(%ebp),%edx
  802621:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802624:	b8 04 00 00 00       	mov    $0x4,%eax
  802629:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80262c:	89 f7                	mov    %esi,%edi
  80262e:	cd 30                	int    $0x30
	if(check && ret > 0)
  802630:	85 c0                	test   %eax,%eax
  802632:	7f 08                	jg     80263c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802634:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802637:	5b                   	pop    %ebx
  802638:	5e                   	pop    %esi
  802639:	5f                   	pop    %edi
  80263a:	5d                   	pop    %ebp
  80263b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80263c:	83 ec 0c             	sub    $0xc,%esp
  80263f:	50                   	push   %eax
  802640:	6a 04                	push   $0x4
  802642:	68 5f 41 80 00       	push   $0x80415f
  802647:	6a 23                	push   $0x23
  802649:	68 7c 41 80 00       	push   $0x80417c
  80264e:	e8 ca f4 ff ff       	call   801b1d <_panic>

00802653 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802653:	55                   	push   %ebp
  802654:	89 e5                	mov    %esp,%ebp
  802656:	57                   	push   %edi
  802657:	56                   	push   %esi
  802658:	53                   	push   %ebx
  802659:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80265c:	8b 55 08             	mov    0x8(%ebp),%edx
  80265f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802662:	b8 05 00 00 00       	mov    $0x5,%eax
  802667:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80266a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80266d:	8b 75 18             	mov    0x18(%ebp),%esi
  802670:	cd 30                	int    $0x30
	if(check && ret > 0)
  802672:	85 c0                	test   %eax,%eax
  802674:	7f 08                	jg     80267e <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802676:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802679:	5b                   	pop    %ebx
  80267a:	5e                   	pop    %esi
  80267b:	5f                   	pop    %edi
  80267c:	5d                   	pop    %ebp
  80267d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80267e:	83 ec 0c             	sub    $0xc,%esp
  802681:	50                   	push   %eax
  802682:	6a 05                	push   $0x5
  802684:	68 5f 41 80 00       	push   $0x80415f
  802689:	6a 23                	push   $0x23
  80268b:	68 7c 41 80 00       	push   $0x80417c
  802690:	e8 88 f4 ff ff       	call   801b1d <_panic>

00802695 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802695:	55                   	push   %ebp
  802696:	89 e5                	mov    %esp,%ebp
  802698:	57                   	push   %edi
  802699:	56                   	push   %esi
  80269a:	53                   	push   %ebx
  80269b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80269e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8026a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026a9:	b8 06 00 00 00       	mov    $0x6,%eax
  8026ae:	89 df                	mov    %ebx,%edi
  8026b0:	89 de                	mov    %ebx,%esi
  8026b2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8026b4:	85 c0                	test   %eax,%eax
  8026b6:	7f 08                	jg     8026c0 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8026b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026bb:	5b                   	pop    %ebx
  8026bc:	5e                   	pop    %esi
  8026bd:	5f                   	pop    %edi
  8026be:	5d                   	pop    %ebp
  8026bf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8026c0:	83 ec 0c             	sub    $0xc,%esp
  8026c3:	50                   	push   %eax
  8026c4:	6a 06                	push   $0x6
  8026c6:	68 5f 41 80 00       	push   $0x80415f
  8026cb:	6a 23                	push   $0x23
  8026cd:	68 7c 41 80 00       	push   $0x80417c
  8026d2:	e8 46 f4 ff ff       	call   801b1d <_panic>

008026d7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8026d7:	55                   	push   %ebp
  8026d8:	89 e5                	mov    %esp,%ebp
  8026da:	57                   	push   %edi
  8026db:	56                   	push   %esi
  8026dc:	53                   	push   %ebx
  8026dd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8026e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8026e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8026f0:	89 df                	mov    %ebx,%edi
  8026f2:	89 de                	mov    %ebx,%esi
  8026f4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8026f6:	85 c0                	test   %eax,%eax
  8026f8:	7f 08                	jg     802702 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8026fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026fd:	5b                   	pop    %ebx
  8026fe:	5e                   	pop    %esi
  8026ff:	5f                   	pop    %edi
  802700:	5d                   	pop    %ebp
  802701:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802702:	83 ec 0c             	sub    $0xc,%esp
  802705:	50                   	push   %eax
  802706:	6a 08                	push   $0x8
  802708:	68 5f 41 80 00       	push   $0x80415f
  80270d:	6a 23                	push   $0x23
  80270f:	68 7c 41 80 00       	push   $0x80417c
  802714:	e8 04 f4 ff ff       	call   801b1d <_panic>

00802719 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802719:	55                   	push   %ebp
  80271a:	89 e5                	mov    %esp,%ebp
  80271c:	57                   	push   %edi
  80271d:	56                   	push   %esi
  80271e:	53                   	push   %ebx
  80271f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802722:	bb 00 00 00 00       	mov    $0x0,%ebx
  802727:	8b 55 08             	mov    0x8(%ebp),%edx
  80272a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80272d:	b8 09 00 00 00       	mov    $0x9,%eax
  802732:	89 df                	mov    %ebx,%edi
  802734:	89 de                	mov    %ebx,%esi
  802736:	cd 30                	int    $0x30
	if(check && ret > 0)
  802738:	85 c0                	test   %eax,%eax
  80273a:	7f 08                	jg     802744 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80273c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80273f:	5b                   	pop    %ebx
  802740:	5e                   	pop    %esi
  802741:	5f                   	pop    %edi
  802742:	5d                   	pop    %ebp
  802743:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802744:	83 ec 0c             	sub    $0xc,%esp
  802747:	50                   	push   %eax
  802748:	6a 09                	push   $0x9
  80274a:	68 5f 41 80 00       	push   $0x80415f
  80274f:	6a 23                	push   $0x23
  802751:	68 7c 41 80 00       	push   $0x80417c
  802756:	e8 c2 f3 ff ff       	call   801b1d <_panic>

0080275b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80275b:	55                   	push   %ebp
  80275c:	89 e5                	mov    %esp,%ebp
  80275e:	57                   	push   %edi
  80275f:	56                   	push   %esi
  802760:	53                   	push   %ebx
  802761:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802764:	bb 00 00 00 00       	mov    $0x0,%ebx
  802769:	8b 55 08             	mov    0x8(%ebp),%edx
  80276c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80276f:	b8 0a 00 00 00       	mov    $0xa,%eax
  802774:	89 df                	mov    %ebx,%edi
  802776:	89 de                	mov    %ebx,%esi
  802778:	cd 30                	int    $0x30
	if(check && ret > 0)
  80277a:	85 c0                	test   %eax,%eax
  80277c:	7f 08                	jg     802786 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80277e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802781:	5b                   	pop    %ebx
  802782:	5e                   	pop    %esi
  802783:	5f                   	pop    %edi
  802784:	5d                   	pop    %ebp
  802785:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802786:	83 ec 0c             	sub    $0xc,%esp
  802789:	50                   	push   %eax
  80278a:	6a 0a                	push   $0xa
  80278c:	68 5f 41 80 00       	push   $0x80415f
  802791:	6a 23                	push   $0x23
  802793:	68 7c 41 80 00       	push   $0x80417c
  802798:	e8 80 f3 ff ff       	call   801b1d <_panic>

0080279d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80279d:	55                   	push   %ebp
  80279e:	89 e5                	mov    %esp,%ebp
  8027a0:	57                   	push   %edi
  8027a1:	56                   	push   %esi
  8027a2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8027a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8027a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027a9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8027ae:	be 00 00 00 00       	mov    $0x0,%esi
  8027b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8027b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8027b9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8027bb:	5b                   	pop    %ebx
  8027bc:	5e                   	pop    %esi
  8027bd:	5f                   	pop    %edi
  8027be:	5d                   	pop    %ebp
  8027bf:	c3                   	ret    

008027c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8027c0:	55                   	push   %ebp
  8027c1:	89 e5                	mov    %esp,%ebp
  8027c3:	57                   	push   %edi
  8027c4:	56                   	push   %esi
  8027c5:	53                   	push   %ebx
  8027c6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8027c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8027ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8027d1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8027d6:	89 cb                	mov    %ecx,%ebx
  8027d8:	89 cf                	mov    %ecx,%edi
  8027da:	89 ce                	mov    %ecx,%esi
  8027dc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8027de:	85 c0                	test   %eax,%eax
  8027e0:	7f 08                	jg     8027ea <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8027e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027e5:	5b                   	pop    %ebx
  8027e6:	5e                   	pop    %esi
  8027e7:	5f                   	pop    %edi
  8027e8:	5d                   	pop    %ebp
  8027e9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8027ea:	83 ec 0c             	sub    $0xc,%esp
  8027ed:	50                   	push   %eax
  8027ee:	6a 0d                	push   $0xd
  8027f0:	68 5f 41 80 00       	push   $0x80415f
  8027f5:	6a 23                	push   $0x23
  8027f7:	68 7c 41 80 00       	push   $0x80417c
  8027fc:	e8 1c f3 ff ff       	call   801b1d <_panic>

00802801 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802801:	55                   	push   %ebp
  802802:	89 e5                	mov    %esp,%ebp
  802804:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802807:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  80280e:	74 20                	je     802830 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802810:	8b 45 08             	mov    0x8(%ebp),%eax
  802813:	a3 10 a0 80 00       	mov    %eax,0x80a010
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802818:	83 ec 08             	sub    $0x8,%esp
  80281b:	68 70 28 80 00       	push   $0x802870
  802820:	6a 00                	push   $0x0
  802822:	e8 34 ff ff ff       	call   80275b <sys_env_set_pgfault_upcall>
  802827:	83 c4 10             	add    $0x10,%esp
  80282a:	85 c0                	test   %eax,%eax
  80282c:	78 2e                	js     80285c <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  80282e:	c9                   	leave  
  80282f:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802830:	83 ec 04             	sub    $0x4,%esp
  802833:	6a 07                	push   $0x7
  802835:	68 00 f0 bf ee       	push   $0xeebff000
  80283a:	6a 00                	push   $0x0
  80283c:	e8 cf fd ff ff       	call   802610 <sys_page_alloc>
  802841:	83 c4 10             	add    $0x10,%esp
  802844:	85 c0                	test   %eax,%eax
  802846:	79 c8                	jns    802810 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  802848:	83 ec 04             	sub    $0x4,%esp
  80284b:	68 8c 41 80 00       	push   $0x80418c
  802850:	6a 21                	push   $0x21
  802852:	68 ee 41 80 00       	push   $0x8041ee
  802857:	e8 c1 f2 ff ff       	call   801b1d <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80285c:	83 ec 04             	sub    $0x4,%esp
  80285f:	68 b8 41 80 00       	push   $0x8041b8
  802864:	6a 27                	push   $0x27
  802866:	68 ee 41 80 00       	push   $0x8041ee
  80286b:	e8 ad f2 ff ff       	call   801b1d <_panic>

00802870 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802870:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802871:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802876:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802878:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  80287b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  80287f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802882:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  802886:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80288a:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80288c:	83 c4 08             	add    $0x8,%esp
	popal
  80288f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802890:	83 c4 04             	add    $0x4,%esp
	popfl
  802893:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802894:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802895:	c3                   	ret    

00802896 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802896:	55                   	push   %ebp
  802897:	89 e5                	mov    %esp,%ebp
  802899:	56                   	push   %esi
  80289a:	53                   	push   %ebx
  80289b:	8b 75 08             	mov    0x8(%ebp),%esi
  80289e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8028a4:	85 f6                	test   %esi,%esi
  8028a6:	74 06                	je     8028ae <ipc_recv+0x18>
  8028a8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  8028ae:	85 db                	test   %ebx,%ebx
  8028b0:	74 06                	je     8028b8 <ipc_recv+0x22>
  8028b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  8028b8:	85 c0                	test   %eax,%eax
  8028ba:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8028bf:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  8028c2:	83 ec 0c             	sub    $0xc,%esp
  8028c5:	50                   	push   %eax
  8028c6:	e8 f5 fe ff ff       	call   8027c0 <sys_ipc_recv>
	if (ret) return ret;
  8028cb:	83 c4 10             	add    $0x10,%esp
  8028ce:	85 c0                	test   %eax,%eax
  8028d0:	75 24                	jne    8028f6 <ipc_recv+0x60>
	if (from_env_store)
  8028d2:	85 f6                	test   %esi,%esi
  8028d4:	74 0a                	je     8028e0 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  8028d6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8028db:	8b 40 74             	mov    0x74(%eax),%eax
  8028de:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  8028e0:	85 db                	test   %ebx,%ebx
  8028e2:	74 0a                	je     8028ee <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  8028e4:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8028e9:	8b 40 78             	mov    0x78(%eax),%eax
  8028ec:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8028ee:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8028f3:	8b 40 70             	mov    0x70(%eax),%eax
}
  8028f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8028f9:	5b                   	pop    %ebx
  8028fa:	5e                   	pop    %esi
  8028fb:	5d                   	pop    %ebp
  8028fc:	c3                   	ret    

008028fd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8028fd:	55                   	push   %ebp
  8028fe:	89 e5                	mov    %esp,%ebp
  802900:	57                   	push   %edi
  802901:	56                   	push   %esi
  802902:	53                   	push   %ebx
  802903:	83 ec 0c             	sub    $0xc,%esp
  802906:	8b 7d 08             	mov    0x8(%ebp),%edi
  802909:	8b 75 0c             	mov    0xc(%ebp),%esi
  80290c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  80290f:	85 db                	test   %ebx,%ebx
  802911:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802916:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802919:	ff 75 14             	pushl  0x14(%ebp)
  80291c:	53                   	push   %ebx
  80291d:	56                   	push   %esi
  80291e:	57                   	push   %edi
  80291f:	e8 79 fe ff ff       	call   80279d <sys_ipc_try_send>
  802924:	83 c4 10             	add    $0x10,%esp
  802927:	85 c0                	test   %eax,%eax
  802929:	74 1e                	je     802949 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  80292b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80292e:	75 07                	jne    802937 <ipc_send+0x3a>
		sys_yield();
  802930:	e8 bc fc ff ff       	call   8025f1 <sys_yield>
  802935:	eb e2                	jmp    802919 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802937:	50                   	push   %eax
  802938:	68 fc 41 80 00       	push   $0x8041fc
  80293d:	6a 36                	push   $0x36
  80293f:	68 13 42 80 00       	push   $0x804213
  802944:	e8 d4 f1 ff ff       	call   801b1d <_panic>
	}
}
  802949:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80294c:	5b                   	pop    %ebx
  80294d:	5e                   	pop    %esi
  80294e:	5f                   	pop    %edi
  80294f:	5d                   	pop    %ebp
  802950:	c3                   	ret    

00802951 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802951:	55                   	push   %ebp
  802952:	89 e5                	mov    %esp,%ebp
  802954:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802957:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80295c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80295f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802965:	8b 52 50             	mov    0x50(%edx),%edx
  802968:	39 ca                	cmp    %ecx,%edx
  80296a:	74 11                	je     80297d <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80296c:	83 c0 01             	add    $0x1,%eax
  80296f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802974:	75 e6                	jne    80295c <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802976:	b8 00 00 00 00       	mov    $0x0,%eax
  80297b:	eb 0b                	jmp    802988 <ipc_find_env+0x37>
			return envs[i].env_id;
  80297d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802980:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802985:	8b 40 48             	mov    0x48(%eax),%eax
}
  802988:	5d                   	pop    %ebp
  802989:	c3                   	ret    

0080298a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80298a:	55                   	push   %ebp
  80298b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80298d:	8b 45 08             	mov    0x8(%ebp),%eax
  802990:	05 00 00 00 30       	add    $0x30000000,%eax
  802995:	c1 e8 0c             	shr    $0xc,%eax
}
  802998:	5d                   	pop    %ebp
  802999:	c3                   	ret    

0080299a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80299a:	55                   	push   %ebp
  80299b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80299d:	8b 45 08             	mov    0x8(%ebp),%eax
  8029a0:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8029a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8029aa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8029af:	5d                   	pop    %ebp
  8029b0:	c3                   	ret    

008029b1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8029b1:	55                   	push   %ebp
  8029b2:	89 e5                	mov    %esp,%ebp
  8029b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029b7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8029bc:	89 c2                	mov    %eax,%edx
  8029be:	c1 ea 16             	shr    $0x16,%edx
  8029c1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8029c8:	f6 c2 01             	test   $0x1,%dl
  8029cb:	74 2a                	je     8029f7 <fd_alloc+0x46>
  8029cd:	89 c2                	mov    %eax,%edx
  8029cf:	c1 ea 0c             	shr    $0xc,%edx
  8029d2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8029d9:	f6 c2 01             	test   $0x1,%dl
  8029dc:	74 19                	je     8029f7 <fd_alloc+0x46>
  8029de:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8029e3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8029e8:	75 d2                	jne    8029bc <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8029ea:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8029f0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8029f5:	eb 07                	jmp    8029fe <fd_alloc+0x4d>
			*fd_store = fd;
  8029f7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8029f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8029fe:	5d                   	pop    %ebp
  8029ff:	c3                   	ret    

00802a00 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802a00:	55                   	push   %ebp
  802a01:	89 e5                	mov    %esp,%ebp
  802a03:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802a06:	83 f8 1f             	cmp    $0x1f,%eax
  802a09:	77 36                	ja     802a41 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802a0b:	c1 e0 0c             	shl    $0xc,%eax
  802a0e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802a13:	89 c2                	mov    %eax,%edx
  802a15:	c1 ea 16             	shr    $0x16,%edx
  802a18:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a1f:	f6 c2 01             	test   $0x1,%dl
  802a22:	74 24                	je     802a48 <fd_lookup+0x48>
  802a24:	89 c2                	mov    %eax,%edx
  802a26:	c1 ea 0c             	shr    $0xc,%edx
  802a29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802a30:	f6 c2 01             	test   $0x1,%dl
  802a33:	74 1a                	je     802a4f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802a35:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a38:	89 02                	mov    %eax,(%edx)
	return 0;
  802a3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a3f:	5d                   	pop    %ebp
  802a40:	c3                   	ret    
		return -E_INVAL;
  802a41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a46:	eb f7                	jmp    802a3f <fd_lookup+0x3f>
		return -E_INVAL;
  802a48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a4d:	eb f0                	jmp    802a3f <fd_lookup+0x3f>
  802a4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a54:	eb e9                	jmp    802a3f <fd_lookup+0x3f>

00802a56 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802a56:	55                   	push   %ebp
  802a57:	89 e5                	mov    %esp,%ebp
  802a59:	83 ec 08             	sub    $0x8,%esp
  802a5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a5f:	ba a0 42 80 00       	mov    $0x8042a0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802a64:	b8 64 90 80 00       	mov    $0x809064,%eax
		if (devtab[i]->dev_id == dev_id) {
  802a69:	39 08                	cmp    %ecx,(%eax)
  802a6b:	74 33                	je     802aa0 <dev_lookup+0x4a>
  802a6d:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  802a70:	8b 02                	mov    (%edx),%eax
  802a72:	85 c0                	test   %eax,%eax
  802a74:	75 f3                	jne    802a69 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802a76:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802a7b:	8b 40 48             	mov    0x48(%eax),%eax
  802a7e:	83 ec 04             	sub    $0x4,%esp
  802a81:	51                   	push   %ecx
  802a82:	50                   	push   %eax
  802a83:	68 20 42 80 00       	push   $0x804220
  802a88:	e8 6b f1 ff ff       	call   801bf8 <cprintf>
	*dev = 0;
  802a8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a90:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802a96:	83 c4 10             	add    $0x10,%esp
  802a99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802a9e:	c9                   	leave  
  802a9f:	c3                   	ret    
			*dev = devtab[i];
  802aa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802aa3:	89 01                	mov    %eax,(%ecx)
			return 0;
  802aa5:	b8 00 00 00 00       	mov    $0x0,%eax
  802aaa:	eb f2                	jmp    802a9e <dev_lookup+0x48>

00802aac <fd_close>:
{
  802aac:	55                   	push   %ebp
  802aad:	89 e5                	mov    %esp,%ebp
  802aaf:	57                   	push   %edi
  802ab0:	56                   	push   %esi
  802ab1:	53                   	push   %ebx
  802ab2:	83 ec 1c             	sub    $0x1c,%esp
  802ab5:	8b 75 08             	mov    0x8(%ebp),%esi
  802ab8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802abb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802abe:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802abf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802ac5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802ac8:	50                   	push   %eax
  802ac9:	e8 32 ff ff ff       	call   802a00 <fd_lookup>
  802ace:	89 c3                	mov    %eax,%ebx
  802ad0:	83 c4 08             	add    $0x8,%esp
  802ad3:	85 c0                	test   %eax,%eax
  802ad5:	78 05                	js     802adc <fd_close+0x30>
	    || fd != fd2)
  802ad7:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  802ada:	74 16                	je     802af2 <fd_close+0x46>
		return (must_exist ? r : 0);
  802adc:	89 f8                	mov    %edi,%eax
  802ade:	84 c0                	test   %al,%al
  802ae0:	b8 00 00 00 00       	mov    $0x0,%eax
  802ae5:	0f 44 d8             	cmove  %eax,%ebx
}
  802ae8:	89 d8                	mov    %ebx,%eax
  802aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802aed:	5b                   	pop    %ebx
  802aee:	5e                   	pop    %esi
  802aef:	5f                   	pop    %edi
  802af0:	5d                   	pop    %ebp
  802af1:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802af2:	83 ec 08             	sub    $0x8,%esp
  802af5:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802af8:	50                   	push   %eax
  802af9:	ff 36                	pushl  (%esi)
  802afb:	e8 56 ff ff ff       	call   802a56 <dev_lookup>
  802b00:	89 c3                	mov    %eax,%ebx
  802b02:	83 c4 10             	add    $0x10,%esp
  802b05:	85 c0                	test   %eax,%eax
  802b07:	78 15                	js     802b1e <fd_close+0x72>
		if (dev->dev_close)
  802b09:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802b0c:	8b 40 10             	mov    0x10(%eax),%eax
  802b0f:	85 c0                	test   %eax,%eax
  802b11:	74 1b                	je     802b2e <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  802b13:	83 ec 0c             	sub    $0xc,%esp
  802b16:	56                   	push   %esi
  802b17:	ff d0                	call   *%eax
  802b19:	89 c3                	mov    %eax,%ebx
  802b1b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  802b1e:	83 ec 08             	sub    $0x8,%esp
  802b21:	56                   	push   %esi
  802b22:	6a 00                	push   $0x0
  802b24:	e8 6c fb ff ff       	call   802695 <sys_page_unmap>
	return r;
  802b29:	83 c4 10             	add    $0x10,%esp
  802b2c:	eb ba                	jmp    802ae8 <fd_close+0x3c>
			r = 0;
  802b2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b33:	eb e9                	jmp    802b1e <fd_close+0x72>

00802b35 <close>:

int
close(int fdnum)
{
  802b35:	55                   	push   %ebp
  802b36:	89 e5                	mov    %esp,%ebp
  802b38:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802b3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b3e:	50                   	push   %eax
  802b3f:	ff 75 08             	pushl  0x8(%ebp)
  802b42:	e8 b9 fe ff ff       	call   802a00 <fd_lookup>
  802b47:	83 c4 08             	add    $0x8,%esp
  802b4a:	85 c0                	test   %eax,%eax
  802b4c:	78 10                	js     802b5e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802b4e:	83 ec 08             	sub    $0x8,%esp
  802b51:	6a 01                	push   $0x1
  802b53:	ff 75 f4             	pushl  -0xc(%ebp)
  802b56:	e8 51 ff ff ff       	call   802aac <fd_close>
  802b5b:	83 c4 10             	add    $0x10,%esp
}
  802b5e:	c9                   	leave  
  802b5f:	c3                   	ret    

00802b60 <close_all>:

void
close_all(void)
{
  802b60:	55                   	push   %ebp
  802b61:	89 e5                	mov    %esp,%ebp
  802b63:	53                   	push   %ebx
  802b64:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802b67:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802b6c:	83 ec 0c             	sub    $0xc,%esp
  802b6f:	53                   	push   %ebx
  802b70:	e8 c0 ff ff ff       	call   802b35 <close>
	for (i = 0; i < MAXFD; i++)
  802b75:	83 c3 01             	add    $0x1,%ebx
  802b78:	83 c4 10             	add    $0x10,%esp
  802b7b:	83 fb 20             	cmp    $0x20,%ebx
  802b7e:	75 ec                	jne    802b6c <close_all+0xc>
}
  802b80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b83:	c9                   	leave  
  802b84:	c3                   	ret    

00802b85 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802b85:	55                   	push   %ebp
  802b86:	89 e5                	mov    %esp,%ebp
  802b88:	57                   	push   %edi
  802b89:	56                   	push   %esi
  802b8a:	53                   	push   %ebx
  802b8b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802b8e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802b91:	50                   	push   %eax
  802b92:	ff 75 08             	pushl  0x8(%ebp)
  802b95:	e8 66 fe ff ff       	call   802a00 <fd_lookup>
  802b9a:	89 c3                	mov    %eax,%ebx
  802b9c:	83 c4 08             	add    $0x8,%esp
  802b9f:	85 c0                	test   %eax,%eax
  802ba1:	0f 88 81 00 00 00    	js     802c28 <dup+0xa3>
		return r;
	close(newfdnum);
  802ba7:	83 ec 0c             	sub    $0xc,%esp
  802baa:	ff 75 0c             	pushl  0xc(%ebp)
  802bad:	e8 83 ff ff ff       	call   802b35 <close>

	newfd = INDEX2FD(newfdnum);
  802bb2:	8b 75 0c             	mov    0xc(%ebp),%esi
  802bb5:	c1 e6 0c             	shl    $0xc,%esi
  802bb8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802bbe:	83 c4 04             	add    $0x4,%esp
  802bc1:	ff 75 e4             	pushl  -0x1c(%ebp)
  802bc4:	e8 d1 fd ff ff       	call   80299a <fd2data>
  802bc9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802bcb:	89 34 24             	mov    %esi,(%esp)
  802bce:	e8 c7 fd ff ff       	call   80299a <fd2data>
  802bd3:	83 c4 10             	add    $0x10,%esp
  802bd6:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802bd8:	89 d8                	mov    %ebx,%eax
  802bda:	c1 e8 16             	shr    $0x16,%eax
  802bdd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802be4:	a8 01                	test   $0x1,%al
  802be6:	74 11                	je     802bf9 <dup+0x74>
  802be8:	89 d8                	mov    %ebx,%eax
  802bea:	c1 e8 0c             	shr    $0xc,%eax
  802bed:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802bf4:	f6 c2 01             	test   $0x1,%dl
  802bf7:	75 39                	jne    802c32 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802bf9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802bfc:	89 d0                	mov    %edx,%eax
  802bfe:	c1 e8 0c             	shr    $0xc,%eax
  802c01:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802c08:	83 ec 0c             	sub    $0xc,%esp
  802c0b:	25 07 0e 00 00       	and    $0xe07,%eax
  802c10:	50                   	push   %eax
  802c11:	56                   	push   %esi
  802c12:	6a 00                	push   $0x0
  802c14:	52                   	push   %edx
  802c15:	6a 00                	push   $0x0
  802c17:	e8 37 fa ff ff       	call   802653 <sys_page_map>
  802c1c:	89 c3                	mov    %eax,%ebx
  802c1e:	83 c4 20             	add    $0x20,%esp
  802c21:	85 c0                	test   %eax,%eax
  802c23:	78 31                	js     802c56 <dup+0xd1>
		goto err;

	return newfdnum;
  802c25:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802c28:	89 d8                	mov    %ebx,%eax
  802c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c2d:	5b                   	pop    %ebx
  802c2e:	5e                   	pop    %esi
  802c2f:	5f                   	pop    %edi
  802c30:	5d                   	pop    %ebp
  802c31:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802c32:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802c39:	83 ec 0c             	sub    $0xc,%esp
  802c3c:	25 07 0e 00 00       	and    $0xe07,%eax
  802c41:	50                   	push   %eax
  802c42:	57                   	push   %edi
  802c43:	6a 00                	push   $0x0
  802c45:	53                   	push   %ebx
  802c46:	6a 00                	push   $0x0
  802c48:	e8 06 fa ff ff       	call   802653 <sys_page_map>
  802c4d:	89 c3                	mov    %eax,%ebx
  802c4f:	83 c4 20             	add    $0x20,%esp
  802c52:	85 c0                	test   %eax,%eax
  802c54:	79 a3                	jns    802bf9 <dup+0x74>
	sys_page_unmap(0, newfd);
  802c56:	83 ec 08             	sub    $0x8,%esp
  802c59:	56                   	push   %esi
  802c5a:	6a 00                	push   $0x0
  802c5c:	e8 34 fa ff ff       	call   802695 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802c61:	83 c4 08             	add    $0x8,%esp
  802c64:	57                   	push   %edi
  802c65:	6a 00                	push   $0x0
  802c67:	e8 29 fa ff ff       	call   802695 <sys_page_unmap>
	return r;
  802c6c:	83 c4 10             	add    $0x10,%esp
  802c6f:	eb b7                	jmp    802c28 <dup+0xa3>

00802c71 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802c71:	55                   	push   %ebp
  802c72:	89 e5                	mov    %esp,%ebp
  802c74:	53                   	push   %ebx
  802c75:	83 ec 14             	sub    $0x14,%esp
  802c78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c7e:	50                   	push   %eax
  802c7f:	53                   	push   %ebx
  802c80:	e8 7b fd ff ff       	call   802a00 <fd_lookup>
  802c85:	83 c4 08             	add    $0x8,%esp
  802c88:	85 c0                	test   %eax,%eax
  802c8a:	78 3f                	js     802ccb <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c8c:	83 ec 08             	sub    $0x8,%esp
  802c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c92:	50                   	push   %eax
  802c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c96:	ff 30                	pushl  (%eax)
  802c98:	e8 b9 fd ff ff       	call   802a56 <dev_lookup>
  802c9d:	83 c4 10             	add    $0x10,%esp
  802ca0:	85 c0                	test   %eax,%eax
  802ca2:	78 27                	js     802ccb <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802ca4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802ca7:	8b 42 08             	mov    0x8(%edx),%eax
  802caa:	83 e0 03             	and    $0x3,%eax
  802cad:	83 f8 01             	cmp    $0x1,%eax
  802cb0:	74 1e                	je     802cd0 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  802cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cb5:	8b 40 08             	mov    0x8(%eax),%eax
  802cb8:	85 c0                	test   %eax,%eax
  802cba:	74 35                	je     802cf1 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802cbc:	83 ec 04             	sub    $0x4,%esp
  802cbf:	ff 75 10             	pushl  0x10(%ebp)
  802cc2:	ff 75 0c             	pushl  0xc(%ebp)
  802cc5:	52                   	push   %edx
  802cc6:	ff d0                	call   *%eax
  802cc8:	83 c4 10             	add    $0x10,%esp
}
  802ccb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802cce:	c9                   	leave  
  802ccf:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802cd0:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802cd5:	8b 40 48             	mov    0x48(%eax),%eax
  802cd8:	83 ec 04             	sub    $0x4,%esp
  802cdb:	53                   	push   %ebx
  802cdc:	50                   	push   %eax
  802cdd:	68 64 42 80 00       	push   $0x804264
  802ce2:	e8 11 ef ff ff       	call   801bf8 <cprintf>
		return -E_INVAL;
  802ce7:	83 c4 10             	add    $0x10,%esp
  802cea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802cef:	eb da                	jmp    802ccb <read+0x5a>
		return -E_NOT_SUPP;
  802cf1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802cf6:	eb d3                	jmp    802ccb <read+0x5a>

00802cf8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802cf8:	55                   	push   %ebp
  802cf9:	89 e5                	mov    %esp,%ebp
  802cfb:	57                   	push   %edi
  802cfc:	56                   	push   %esi
  802cfd:	53                   	push   %ebx
  802cfe:	83 ec 0c             	sub    $0xc,%esp
  802d01:	8b 7d 08             	mov    0x8(%ebp),%edi
  802d04:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  802d0c:	39 f3                	cmp    %esi,%ebx
  802d0e:	73 25                	jae    802d35 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802d10:	83 ec 04             	sub    $0x4,%esp
  802d13:	89 f0                	mov    %esi,%eax
  802d15:	29 d8                	sub    %ebx,%eax
  802d17:	50                   	push   %eax
  802d18:	89 d8                	mov    %ebx,%eax
  802d1a:	03 45 0c             	add    0xc(%ebp),%eax
  802d1d:	50                   	push   %eax
  802d1e:	57                   	push   %edi
  802d1f:	e8 4d ff ff ff       	call   802c71 <read>
		if (m < 0)
  802d24:	83 c4 10             	add    $0x10,%esp
  802d27:	85 c0                	test   %eax,%eax
  802d29:	78 08                	js     802d33 <readn+0x3b>
			return m;
		if (m == 0)
  802d2b:	85 c0                	test   %eax,%eax
  802d2d:	74 06                	je     802d35 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  802d2f:	01 c3                	add    %eax,%ebx
  802d31:	eb d9                	jmp    802d0c <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802d33:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  802d35:	89 d8                	mov    %ebx,%eax
  802d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d3a:	5b                   	pop    %ebx
  802d3b:	5e                   	pop    %esi
  802d3c:	5f                   	pop    %edi
  802d3d:	5d                   	pop    %ebp
  802d3e:	c3                   	ret    

00802d3f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802d3f:	55                   	push   %ebp
  802d40:	89 e5                	mov    %esp,%ebp
  802d42:	53                   	push   %ebx
  802d43:	83 ec 14             	sub    $0x14,%esp
  802d46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d4c:	50                   	push   %eax
  802d4d:	53                   	push   %ebx
  802d4e:	e8 ad fc ff ff       	call   802a00 <fd_lookup>
  802d53:	83 c4 08             	add    $0x8,%esp
  802d56:	85 c0                	test   %eax,%eax
  802d58:	78 3a                	js     802d94 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d5a:	83 ec 08             	sub    $0x8,%esp
  802d5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d60:	50                   	push   %eax
  802d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d64:	ff 30                	pushl  (%eax)
  802d66:	e8 eb fc ff ff       	call   802a56 <dev_lookup>
  802d6b:	83 c4 10             	add    $0x10,%esp
  802d6e:	85 c0                	test   %eax,%eax
  802d70:	78 22                	js     802d94 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d75:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d79:	74 1e                	je     802d99 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802d7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d7e:	8b 52 0c             	mov    0xc(%edx),%edx
  802d81:	85 d2                	test   %edx,%edx
  802d83:	74 35                	je     802dba <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802d85:	83 ec 04             	sub    $0x4,%esp
  802d88:	ff 75 10             	pushl  0x10(%ebp)
  802d8b:	ff 75 0c             	pushl  0xc(%ebp)
  802d8e:	50                   	push   %eax
  802d8f:	ff d2                	call   *%edx
  802d91:	83 c4 10             	add    $0x10,%esp
}
  802d94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d97:	c9                   	leave  
  802d98:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802d99:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802d9e:	8b 40 48             	mov    0x48(%eax),%eax
  802da1:	83 ec 04             	sub    $0x4,%esp
  802da4:	53                   	push   %ebx
  802da5:	50                   	push   %eax
  802da6:	68 80 42 80 00       	push   $0x804280
  802dab:	e8 48 ee ff ff       	call   801bf8 <cprintf>
		return -E_INVAL;
  802db0:	83 c4 10             	add    $0x10,%esp
  802db3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802db8:	eb da                	jmp    802d94 <write+0x55>
		return -E_NOT_SUPP;
  802dba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802dbf:	eb d3                	jmp    802d94 <write+0x55>

00802dc1 <seek>:

int
seek(int fdnum, off_t offset)
{
  802dc1:	55                   	push   %ebp
  802dc2:	89 e5                	mov    %esp,%ebp
  802dc4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802dc7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802dca:	50                   	push   %eax
  802dcb:	ff 75 08             	pushl  0x8(%ebp)
  802dce:	e8 2d fc ff ff       	call   802a00 <fd_lookup>
  802dd3:	83 c4 08             	add    $0x8,%esp
  802dd6:	85 c0                	test   %eax,%eax
  802dd8:	78 0e                	js     802de8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802dda:	8b 55 0c             	mov    0xc(%ebp),%edx
  802ddd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802de0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802de3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802de8:	c9                   	leave  
  802de9:	c3                   	ret    

00802dea <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802dea:	55                   	push   %ebp
  802deb:	89 e5                	mov    %esp,%ebp
  802ded:	53                   	push   %ebx
  802dee:	83 ec 14             	sub    $0x14,%esp
  802df1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802df4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802df7:	50                   	push   %eax
  802df8:	53                   	push   %ebx
  802df9:	e8 02 fc ff ff       	call   802a00 <fd_lookup>
  802dfe:	83 c4 08             	add    $0x8,%esp
  802e01:	85 c0                	test   %eax,%eax
  802e03:	78 37                	js     802e3c <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e05:	83 ec 08             	sub    $0x8,%esp
  802e08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e0b:	50                   	push   %eax
  802e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e0f:	ff 30                	pushl  (%eax)
  802e11:	e8 40 fc ff ff       	call   802a56 <dev_lookup>
  802e16:	83 c4 10             	add    $0x10,%esp
  802e19:	85 c0                	test   %eax,%eax
  802e1b:	78 1f                	js     802e3c <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e20:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802e24:	74 1b                	je     802e41 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802e26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e29:	8b 52 18             	mov    0x18(%edx),%edx
  802e2c:	85 d2                	test   %edx,%edx
  802e2e:	74 32                	je     802e62 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802e30:	83 ec 08             	sub    $0x8,%esp
  802e33:	ff 75 0c             	pushl  0xc(%ebp)
  802e36:	50                   	push   %eax
  802e37:	ff d2                	call   *%edx
  802e39:	83 c4 10             	add    $0x10,%esp
}
  802e3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e3f:	c9                   	leave  
  802e40:	c3                   	ret    
			thisenv->env_id, fdnum);
  802e41:	a1 0c a0 80 00       	mov    0x80a00c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802e46:	8b 40 48             	mov    0x48(%eax),%eax
  802e49:	83 ec 04             	sub    $0x4,%esp
  802e4c:	53                   	push   %ebx
  802e4d:	50                   	push   %eax
  802e4e:	68 40 42 80 00       	push   $0x804240
  802e53:	e8 a0 ed ff ff       	call   801bf8 <cprintf>
		return -E_INVAL;
  802e58:	83 c4 10             	add    $0x10,%esp
  802e5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802e60:	eb da                	jmp    802e3c <ftruncate+0x52>
		return -E_NOT_SUPP;
  802e62:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802e67:	eb d3                	jmp    802e3c <ftruncate+0x52>

00802e69 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802e69:	55                   	push   %ebp
  802e6a:	89 e5                	mov    %esp,%ebp
  802e6c:	53                   	push   %ebx
  802e6d:	83 ec 14             	sub    $0x14,%esp
  802e70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e73:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e76:	50                   	push   %eax
  802e77:	ff 75 08             	pushl  0x8(%ebp)
  802e7a:	e8 81 fb ff ff       	call   802a00 <fd_lookup>
  802e7f:	83 c4 08             	add    $0x8,%esp
  802e82:	85 c0                	test   %eax,%eax
  802e84:	78 4b                	js     802ed1 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e86:	83 ec 08             	sub    $0x8,%esp
  802e89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e8c:	50                   	push   %eax
  802e8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e90:	ff 30                	pushl  (%eax)
  802e92:	e8 bf fb ff ff       	call   802a56 <dev_lookup>
  802e97:	83 c4 10             	add    $0x10,%esp
  802e9a:	85 c0                	test   %eax,%eax
  802e9c:	78 33                	js     802ed1 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  802e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ea1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802ea5:	74 2f                	je     802ed6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802ea7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802eaa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802eb1:	00 00 00 
	stat->st_isdir = 0;
  802eb4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802ebb:	00 00 00 
	stat->st_dev = dev;
  802ebe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802ec4:	83 ec 08             	sub    $0x8,%esp
  802ec7:	53                   	push   %ebx
  802ec8:	ff 75 f0             	pushl  -0x10(%ebp)
  802ecb:	ff 50 14             	call   *0x14(%eax)
  802ece:	83 c4 10             	add    $0x10,%esp
}
  802ed1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ed4:	c9                   	leave  
  802ed5:	c3                   	ret    
		return -E_NOT_SUPP;
  802ed6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802edb:	eb f4                	jmp    802ed1 <fstat+0x68>

00802edd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802edd:	55                   	push   %ebp
  802ede:	89 e5                	mov    %esp,%ebp
  802ee0:	56                   	push   %esi
  802ee1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802ee2:	83 ec 08             	sub    $0x8,%esp
  802ee5:	6a 00                	push   $0x0
  802ee7:	ff 75 08             	pushl  0x8(%ebp)
  802eea:	e8 da 01 00 00       	call   8030c9 <open>
  802eef:	89 c3                	mov    %eax,%ebx
  802ef1:	83 c4 10             	add    $0x10,%esp
  802ef4:	85 c0                	test   %eax,%eax
  802ef6:	78 1b                	js     802f13 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802ef8:	83 ec 08             	sub    $0x8,%esp
  802efb:	ff 75 0c             	pushl  0xc(%ebp)
  802efe:	50                   	push   %eax
  802eff:	e8 65 ff ff ff       	call   802e69 <fstat>
  802f04:	89 c6                	mov    %eax,%esi
	close(fd);
  802f06:	89 1c 24             	mov    %ebx,(%esp)
  802f09:	e8 27 fc ff ff       	call   802b35 <close>
	return r;
  802f0e:	83 c4 10             	add    $0x10,%esp
  802f11:	89 f3                	mov    %esi,%ebx
}
  802f13:	89 d8                	mov    %ebx,%eax
  802f15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f18:	5b                   	pop    %ebx
  802f19:	5e                   	pop    %esi
  802f1a:	5d                   	pop    %ebp
  802f1b:	c3                   	ret    

00802f1c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802f1c:	55                   	push   %ebp
  802f1d:	89 e5                	mov    %esp,%ebp
  802f1f:	56                   	push   %esi
  802f20:	53                   	push   %ebx
  802f21:	89 c6                	mov    %eax,%esi
  802f23:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802f25:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802f2c:	74 27                	je     802f55 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802f2e:	6a 07                	push   $0x7
  802f30:	68 00 b0 80 00       	push   $0x80b000
  802f35:	56                   	push   %esi
  802f36:	ff 35 00 a0 80 00    	pushl  0x80a000
  802f3c:	e8 bc f9 ff ff       	call   8028fd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802f41:	83 c4 0c             	add    $0xc,%esp
  802f44:	6a 00                	push   $0x0
  802f46:	53                   	push   %ebx
  802f47:	6a 00                	push   $0x0
  802f49:	e8 48 f9 ff ff       	call   802896 <ipc_recv>
}
  802f4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f51:	5b                   	pop    %ebx
  802f52:	5e                   	pop    %esi
  802f53:	5d                   	pop    %ebp
  802f54:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802f55:	83 ec 0c             	sub    $0xc,%esp
  802f58:	6a 01                	push   $0x1
  802f5a:	e8 f2 f9 ff ff       	call   802951 <ipc_find_env>
  802f5f:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802f64:	83 c4 10             	add    $0x10,%esp
  802f67:	eb c5                	jmp    802f2e <fsipc+0x12>

00802f69 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802f69:	55                   	push   %ebp
  802f6a:	89 e5                	mov    %esp,%ebp
  802f6c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  802f72:	8b 40 0c             	mov    0xc(%eax),%eax
  802f75:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802f7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f7d:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802f82:	ba 00 00 00 00       	mov    $0x0,%edx
  802f87:	b8 02 00 00 00       	mov    $0x2,%eax
  802f8c:	e8 8b ff ff ff       	call   802f1c <fsipc>
}
  802f91:	c9                   	leave  
  802f92:	c3                   	ret    

00802f93 <devfile_flush>:
{
  802f93:	55                   	push   %ebp
  802f94:	89 e5                	mov    %esp,%ebp
  802f96:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802f99:	8b 45 08             	mov    0x8(%ebp),%eax
  802f9c:	8b 40 0c             	mov    0xc(%eax),%eax
  802f9f:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802fa4:	ba 00 00 00 00       	mov    $0x0,%edx
  802fa9:	b8 06 00 00 00       	mov    $0x6,%eax
  802fae:	e8 69 ff ff ff       	call   802f1c <fsipc>
}
  802fb3:	c9                   	leave  
  802fb4:	c3                   	ret    

00802fb5 <devfile_stat>:
{
  802fb5:	55                   	push   %ebp
  802fb6:	89 e5                	mov    %esp,%ebp
  802fb8:	53                   	push   %ebx
  802fb9:	83 ec 04             	sub    $0x4,%esp
  802fbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  802fc2:	8b 40 0c             	mov    0xc(%eax),%eax
  802fc5:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802fca:	ba 00 00 00 00       	mov    $0x0,%edx
  802fcf:	b8 05 00 00 00       	mov    $0x5,%eax
  802fd4:	e8 43 ff ff ff       	call   802f1c <fsipc>
  802fd9:	85 c0                	test   %eax,%eax
  802fdb:	78 2c                	js     803009 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802fdd:	83 ec 08             	sub    $0x8,%esp
  802fe0:	68 00 b0 80 00       	push   $0x80b000
  802fe5:	53                   	push   %ebx
  802fe6:	e8 2c f2 ff ff       	call   802217 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802feb:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802ff0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802ff6:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802ffb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  803001:	83 c4 10             	add    $0x10,%esp
  803004:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803009:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80300c:	c9                   	leave  
  80300d:	c3                   	ret    

0080300e <devfile_write>:
{
  80300e:	55                   	push   %ebp
  80300f:	89 e5                	mov    %esp,%ebp
  803011:	83 ec 0c             	sub    $0xc,%esp
  803014:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  803017:	8b 55 08             	mov    0x8(%ebp),%edx
  80301a:	8b 52 0c             	mov    0xc(%edx),%edx
  80301d:	89 15 00 b0 80 00    	mov    %edx,0x80b000
    	fsipcbuf.write.req_n = n;
  803023:	a3 04 b0 80 00       	mov    %eax,0x80b004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  803028:	50                   	push   %eax
  803029:	ff 75 0c             	pushl  0xc(%ebp)
  80302c:	68 08 b0 80 00       	push   $0x80b008
  803031:	e8 6f f3 ff ff       	call   8023a5 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  803036:	ba 00 00 00 00       	mov    $0x0,%edx
  80303b:	b8 04 00 00 00       	mov    $0x4,%eax
  803040:	e8 d7 fe ff ff       	call   802f1c <fsipc>
}
  803045:	c9                   	leave  
  803046:	c3                   	ret    

00803047 <devfile_read>:
{
  803047:	55                   	push   %ebp
  803048:	89 e5                	mov    %esp,%ebp
  80304a:	56                   	push   %esi
  80304b:	53                   	push   %ebx
  80304c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80304f:	8b 45 08             	mov    0x8(%ebp),%eax
  803052:	8b 40 0c             	mov    0xc(%eax),%eax
  803055:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  80305a:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  803060:	ba 00 00 00 00       	mov    $0x0,%edx
  803065:	b8 03 00 00 00       	mov    $0x3,%eax
  80306a:	e8 ad fe ff ff       	call   802f1c <fsipc>
  80306f:	89 c3                	mov    %eax,%ebx
  803071:	85 c0                	test   %eax,%eax
  803073:	78 1f                	js     803094 <devfile_read+0x4d>
	assert(r <= n);
  803075:	39 f0                	cmp    %esi,%eax
  803077:	77 24                	ja     80309d <devfile_read+0x56>
	assert(r <= PGSIZE);
  803079:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80307e:	7f 33                	jg     8030b3 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803080:	83 ec 04             	sub    $0x4,%esp
  803083:	50                   	push   %eax
  803084:	68 00 b0 80 00       	push   $0x80b000
  803089:	ff 75 0c             	pushl  0xc(%ebp)
  80308c:	e8 14 f3 ff ff       	call   8023a5 <memmove>
	return r;
  803091:	83 c4 10             	add    $0x10,%esp
}
  803094:	89 d8                	mov    %ebx,%eax
  803096:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803099:	5b                   	pop    %ebx
  80309a:	5e                   	pop    %esi
  80309b:	5d                   	pop    %ebp
  80309c:	c3                   	ret    
	assert(r <= n);
  80309d:	68 b0 42 80 00       	push   $0x8042b0
  8030a2:	68 fd 38 80 00       	push   $0x8038fd
  8030a7:	6a 7c                	push   $0x7c
  8030a9:	68 b7 42 80 00       	push   $0x8042b7
  8030ae:	e8 6a ea ff ff       	call   801b1d <_panic>
	assert(r <= PGSIZE);
  8030b3:	68 c2 42 80 00       	push   $0x8042c2
  8030b8:	68 fd 38 80 00       	push   $0x8038fd
  8030bd:	6a 7d                	push   $0x7d
  8030bf:	68 b7 42 80 00       	push   $0x8042b7
  8030c4:	e8 54 ea ff ff       	call   801b1d <_panic>

008030c9 <open>:
{
  8030c9:	55                   	push   %ebp
  8030ca:	89 e5                	mov    %esp,%ebp
  8030cc:	56                   	push   %esi
  8030cd:	53                   	push   %ebx
  8030ce:	83 ec 1c             	sub    $0x1c,%esp
  8030d1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8030d4:	56                   	push   %esi
  8030d5:	e8 06 f1 ff ff       	call   8021e0 <strlen>
  8030da:	83 c4 10             	add    $0x10,%esp
  8030dd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8030e2:	7f 6c                	jg     803150 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8030e4:	83 ec 0c             	sub    $0xc,%esp
  8030e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030ea:	50                   	push   %eax
  8030eb:	e8 c1 f8 ff ff       	call   8029b1 <fd_alloc>
  8030f0:	89 c3                	mov    %eax,%ebx
  8030f2:	83 c4 10             	add    $0x10,%esp
  8030f5:	85 c0                	test   %eax,%eax
  8030f7:	78 3c                	js     803135 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8030f9:	83 ec 08             	sub    $0x8,%esp
  8030fc:	56                   	push   %esi
  8030fd:	68 00 b0 80 00       	push   $0x80b000
  803102:	e8 10 f1 ff ff       	call   802217 <strcpy>
	fsipcbuf.open.req_omode = mode;
  803107:	8b 45 0c             	mov    0xc(%ebp),%eax
  80310a:	a3 00 b4 80 00       	mov    %eax,0x80b400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80310f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803112:	b8 01 00 00 00       	mov    $0x1,%eax
  803117:	e8 00 fe ff ff       	call   802f1c <fsipc>
  80311c:	89 c3                	mov    %eax,%ebx
  80311e:	83 c4 10             	add    $0x10,%esp
  803121:	85 c0                	test   %eax,%eax
  803123:	78 19                	js     80313e <open+0x75>
	return fd2num(fd);
  803125:	83 ec 0c             	sub    $0xc,%esp
  803128:	ff 75 f4             	pushl  -0xc(%ebp)
  80312b:	e8 5a f8 ff ff       	call   80298a <fd2num>
  803130:	89 c3                	mov    %eax,%ebx
  803132:	83 c4 10             	add    $0x10,%esp
}
  803135:	89 d8                	mov    %ebx,%eax
  803137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80313a:	5b                   	pop    %ebx
  80313b:	5e                   	pop    %esi
  80313c:	5d                   	pop    %ebp
  80313d:	c3                   	ret    
		fd_close(fd, 0);
  80313e:	83 ec 08             	sub    $0x8,%esp
  803141:	6a 00                	push   $0x0
  803143:	ff 75 f4             	pushl  -0xc(%ebp)
  803146:	e8 61 f9 ff ff       	call   802aac <fd_close>
		return r;
  80314b:	83 c4 10             	add    $0x10,%esp
  80314e:	eb e5                	jmp    803135 <open+0x6c>
		return -E_BAD_PATH;
  803150:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  803155:	eb de                	jmp    803135 <open+0x6c>

00803157 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  803157:	55                   	push   %ebp
  803158:	89 e5                	mov    %esp,%ebp
  80315a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80315d:	ba 00 00 00 00       	mov    $0x0,%edx
  803162:	b8 08 00 00 00       	mov    $0x8,%eax
  803167:	e8 b0 fd ff ff       	call   802f1c <fsipc>
}
  80316c:	c9                   	leave  
  80316d:	c3                   	ret    

0080316e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80316e:	55                   	push   %ebp
  80316f:	89 e5                	mov    %esp,%ebp
  803171:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803174:	89 d0                	mov    %edx,%eax
  803176:	c1 e8 16             	shr    $0x16,%eax
  803179:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803180:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  803185:	f6 c1 01             	test   $0x1,%cl
  803188:	74 1d                	je     8031a7 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  80318a:	c1 ea 0c             	shr    $0xc,%edx
  80318d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803194:	f6 c2 01             	test   $0x1,%dl
  803197:	74 0e                	je     8031a7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803199:	c1 ea 0c             	shr    $0xc,%edx
  80319c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8031a3:	ef 
  8031a4:	0f b7 c0             	movzwl %ax,%eax
}
  8031a7:	5d                   	pop    %ebp
  8031a8:	c3                   	ret    

008031a9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8031a9:	55                   	push   %ebp
  8031aa:	89 e5                	mov    %esp,%ebp
  8031ac:	56                   	push   %esi
  8031ad:	53                   	push   %ebx
  8031ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8031b1:	83 ec 0c             	sub    $0xc,%esp
  8031b4:	ff 75 08             	pushl  0x8(%ebp)
  8031b7:	e8 de f7 ff ff       	call   80299a <fd2data>
  8031bc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8031be:	83 c4 08             	add    $0x8,%esp
  8031c1:	68 ce 42 80 00       	push   $0x8042ce
  8031c6:	53                   	push   %ebx
  8031c7:	e8 4b f0 ff ff       	call   802217 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8031cc:	8b 46 04             	mov    0x4(%esi),%eax
  8031cf:	2b 06                	sub    (%esi),%eax
  8031d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8031d7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8031de:	00 00 00 
	stat->st_dev = &devpipe;
  8031e1:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  8031e8:	90 80 00 
	return 0;
}
  8031eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8031f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8031f3:	5b                   	pop    %ebx
  8031f4:	5e                   	pop    %esi
  8031f5:	5d                   	pop    %ebp
  8031f6:	c3                   	ret    

008031f7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8031f7:	55                   	push   %ebp
  8031f8:	89 e5                	mov    %esp,%ebp
  8031fa:	53                   	push   %ebx
  8031fb:	83 ec 0c             	sub    $0xc,%esp
  8031fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803201:	53                   	push   %ebx
  803202:	6a 00                	push   $0x0
  803204:	e8 8c f4 ff ff       	call   802695 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803209:	89 1c 24             	mov    %ebx,(%esp)
  80320c:	e8 89 f7 ff ff       	call   80299a <fd2data>
  803211:	83 c4 08             	add    $0x8,%esp
  803214:	50                   	push   %eax
  803215:	6a 00                	push   $0x0
  803217:	e8 79 f4 ff ff       	call   802695 <sys_page_unmap>
}
  80321c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80321f:	c9                   	leave  
  803220:	c3                   	ret    

00803221 <_pipeisclosed>:
{
  803221:	55                   	push   %ebp
  803222:	89 e5                	mov    %esp,%ebp
  803224:	57                   	push   %edi
  803225:	56                   	push   %esi
  803226:	53                   	push   %ebx
  803227:	83 ec 1c             	sub    $0x1c,%esp
  80322a:	89 c7                	mov    %eax,%edi
  80322c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80322e:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803233:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803236:	83 ec 0c             	sub    $0xc,%esp
  803239:	57                   	push   %edi
  80323a:	e8 2f ff ff ff       	call   80316e <pageref>
  80323f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  803242:	89 34 24             	mov    %esi,(%esp)
  803245:	e8 24 ff ff ff       	call   80316e <pageref>
		nn = thisenv->env_runs;
  80324a:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  803250:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803253:	83 c4 10             	add    $0x10,%esp
  803256:	39 cb                	cmp    %ecx,%ebx
  803258:	74 1b                	je     803275 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80325a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80325d:	75 cf                	jne    80322e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80325f:	8b 42 58             	mov    0x58(%edx),%eax
  803262:	6a 01                	push   $0x1
  803264:	50                   	push   %eax
  803265:	53                   	push   %ebx
  803266:	68 d5 42 80 00       	push   $0x8042d5
  80326b:	e8 88 e9 ff ff       	call   801bf8 <cprintf>
  803270:	83 c4 10             	add    $0x10,%esp
  803273:	eb b9                	jmp    80322e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  803275:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  803278:	0f 94 c0             	sete   %al
  80327b:	0f b6 c0             	movzbl %al,%eax
}
  80327e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803281:	5b                   	pop    %ebx
  803282:	5e                   	pop    %esi
  803283:	5f                   	pop    %edi
  803284:	5d                   	pop    %ebp
  803285:	c3                   	ret    

00803286 <devpipe_write>:
{
  803286:	55                   	push   %ebp
  803287:	89 e5                	mov    %esp,%ebp
  803289:	57                   	push   %edi
  80328a:	56                   	push   %esi
  80328b:	53                   	push   %ebx
  80328c:	83 ec 28             	sub    $0x28,%esp
  80328f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  803292:	56                   	push   %esi
  803293:	e8 02 f7 ff ff       	call   80299a <fd2data>
  803298:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80329a:	83 c4 10             	add    $0x10,%esp
  80329d:	bf 00 00 00 00       	mov    $0x0,%edi
  8032a2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8032a5:	74 4f                	je     8032f6 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8032a7:	8b 43 04             	mov    0x4(%ebx),%eax
  8032aa:	8b 0b                	mov    (%ebx),%ecx
  8032ac:	8d 51 20             	lea    0x20(%ecx),%edx
  8032af:	39 d0                	cmp    %edx,%eax
  8032b1:	72 14                	jb     8032c7 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  8032b3:	89 da                	mov    %ebx,%edx
  8032b5:	89 f0                	mov    %esi,%eax
  8032b7:	e8 65 ff ff ff       	call   803221 <_pipeisclosed>
  8032bc:	85 c0                	test   %eax,%eax
  8032be:	75 3a                	jne    8032fa <devpipe_write+0x74>
			sys_yield();
  8032c0:	e8 2c f3 ff ff       	call   8025f1 <sys_yield>
  8032c5:	eb e0                	jmp    8032a7 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8032c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8032ca:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8032ce:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8032d1:	89 c2                	mov    %eax,%edx
  8032d3:	c1 fa 1f             	sar    $0x1f,%edx
  8032d6:	89 d1                	mov    %edx,%ecx
  8032d8:	c1 e9 1b             	shr    $0x1b,%ecx
  8032db:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8032de:	83 e2 1f             	and    $0x1f,%edx
  8032e1:	29 ca                	sub    %ecx,%edx
  8032e3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8032e7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8032eb:	83 c0 01             	add    $0x1,%eax
  8032ee:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8032f1:	83 c7 01             	add    $0x1,%edi
  8032f4:	eb ac                	jmp    8032a2 <devpipe_write+0x1c>
	return i;
  8032f6:	89 f8                	mov    %edi,%eax
  8032f8:	eb 05                	jmp    8032ff <devpipe_write+0x79>
				return 0;
  8032fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8032ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803302:	5b                   	pop    %ebx
  803303:	5e                   	pop    %esi
  803304:	5f                   	pop    %edi
  803305:	5d                   	pop    %ebp
  803306:	c3                   	ret    

00803307 <devpipe_read>:
{
  803307:	55                   	push   %ebp
  803308:	89 e5                	mov    %esp,%ebp
  80330a:	57                   	push   %edi
  80330b:	56                   	push   %esi
  80330c:	53                   	push   %ebx
  80330d:	83 ec 18             	sub    $0x18,%esp
  803310:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  803313:	57                   	push   %edi
  803314:	e8 81 f6 ff ff       	call   80299a <fd2data>
  803319:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80331b:	83 c4 10             	add    $0x10,%esp
  80331e:	be 00 00 00 00       	mov    $0x0,%esi
  803323:	3b 75 10             	cmp    0x10(%ebp),%esi
  803326:	74 47                	je     80336f <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  803328:	8b 03                	mov    (%ebx),%eax
  80332a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80332d:	75 22                	jne    803351 <devpipe_read+0x4a>
			if (i > 0)
  80332f:	85 f6                	test   %esi,%esi
  803331:	75 14                	jne    803347 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  803333:	89 da                	mov    %ebx,%edx
  803335:	89 f8                	mov    %edi,%eax
  803337:	e8 e5 fe ff ff       	call   803221 <_pipeisclosed>
  80333c:	85 c0                	test   %eax,%eax
  80333e:	75 33                	jne    803373 <devpipe_read+0x6c>
			sys_yield();
  803340:	e8 ac f2 ff ff       	call   8025f1 <sys_yield>
  803345:	eb e1                	jmp    803328 <devpipe_read+0x21>
				return i;
  803347:	89 f0                	mov    %esi,%eax
}
  803349:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80334c:	5b                   	pop    %ebx
  80334d:	5e                   	pop    %esi
  80334e:	5f                   	pop    %edi
  80334f:	5d                   	pop    %ebp
  803350:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803351:	99                   	cltd   
  803352:	c1 ea 1b             	shr    $0x1b,%edx
  803355:	01 d0                	add    %edx,%eax
  803357:	83 e0 1f             	and    $0x1f,%eax
  80335a:	29 d0                	sub    %edx,%eax
  80335c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  803361:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803364:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  803367:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80336a:	83 c6 01             	add    $0x1,%esi
  80336d:	eb b4                	jmp    803323 <devpipe_read+0x1c>
	return i;
  80336f:	89 f0                	mov    %esi,%eax
  803371:	eb d6                	jmp    803349 <devpipe_read+0x42>
				return 0;
  803373:	b8 00 00 00 00       	mov    $0x0,%eax
  803378:	eb cf                	jmp    803349 <devpipe_read+0x42>

0080337a <pipe>:
{
  80337a:	55                   	push   %ebp
  80337b:	89 e5                	mov    %esp,%ebp
  80337d:	56                   	push   %esi
  80337e:	53                   	push   %ebx
  80337f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  803382:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803385:	50                   	push   %eax
  803386:	e8 26 f6 ff ff       	call   8029b1 <fd_alloc>
  80338b:	89 c3                	mov    %eax,%ebx
  80338d:	83 c4 10             	add    $0x10,%esp
  803390:	85 c0                	test   %eax,%eax
  803392:	78 5b                	js     8033ef <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803394:	83 ec 04             	sub    $0x4,%esp
  803397:	68 07 04 00 00       	push   $0x407
  80339c:	ff 75 f4             	pushl  -0xc(%ebp)
  80339f:	6a 00                	push   $0x0
  8033a1:	e8 6a f2 ff ff       	call   802610 <sys_page_alloc>
  8033a6:	89 c3                	mov    %eax,%ebx
  8033a8:	83 c4 10             	add    $0x10,%esp
  8033ab:	85 c0                	test   %eax,%eax
  8033ad:	78 40                	js     8033ef <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  8033af:	83 ec 0c             	sub    $0xc,%esp
  8033b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8033b5:	50                   	push   %eax
  8033b6:	e8 f6 f5 ff ff       	call   8029b1 <fd_alloc>
  8033bb:	89 c3                	mov    %eax,%ebx
  8033bd:	83 c4 10             	add    $0x10,%esp
  8033c0:	85 c0                	test   %eax,%eax
  8033c2:	78 1b                	js     8033df <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8033c4:	83 ec 04             	sub    $0x4,%esp
  8033c7:	68 07 04 00 00       	push   $0x407
  8033cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8033cf:	6a 00                	push   $0x0
  8033d1:	e8 3a f2 ff ff       	call   802610 <sys_page_alloc>
  8033d6:	89 c3                	mov    %eax,%ebx
  8033d8:	83 c4 10             	add    $0x10,%esp
  8033db:	85 c0                	test   %eax,%eax
  8033dd:	79 19                	jns    8033f8 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8033df:	83 ec 08             	sub    $0x8,%esp
  8033e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8033e5:	6a 00                	push   $0x0
  8033e7:	e8 a9 f2 ff ff       	call   802695 <sys_page_unmap>
  8033ec:	83 c4 10             	add    $0x10,%esp
}
  8033ef:	89 d8                	mov    %ebx,%eax
  8033f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8033f4:	5b                   	pop    %ebx
  8033f5:	5e                   	pop    %esi
  8033f6:	5d                   	pop    %ebp
  8033f7:	c3                   	ret    
	va = fd2data(fd0);
  8033f8:	83 ec 0c             	sub    $0xc,%esp
  8033fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8033fe:	e8 97 f5 ff ff       	call   80299a <fd2data>
  803403:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803405:	83 c4 0c             	add    $0xc,%esp
  803408:	68 07 04 00 00       	push   $0x407
  80340d:	50                   	push   %eax
  80340e:	6a 00                	push   $0x0
  803410:	e8 fb f1 ff ff       	call   802610 <sys_page_alloc>
  803415:	89 c3                	mov    %eax,%ebx
  803417:	83 c4 10             	add    $0x10,%esp
  80341a:	85 c0                	test   %eax,%eax
  80341c:	0f 88 8c 00 00 00    	js     8034ae <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803422:	83 ec 0c             	sub    $0xc,%esp
  803425:	ff 75 f0             	pushl  -0x10(%ebp)
  803428:	e8 6d f5 ff ff       	call   80299a <fd2data>
  80342d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803434:	50                   	push   %eax
  803435:	6a 00                	push   $0x0
  803437:	56                   	push   %esi
  803438:	6a 00                	push   $0x0
  80343a:	e8 14 f2 ff ff       	call   802653 <sys_page_map>
  80343f:	89 c3                	mov    %eax,%ebx
  803441:	83 c4 20             	add    $0x20,%esp
  803444:	85 c0                	test   %eax,%eax
  803446:	78 58                	js     8034a0 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  803448:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80344b:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803451:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803453:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803456:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80345d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803460:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803466:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803468:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80346b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  803472:	83 ec 0c             	sub    $0xc,%esp
  803475:	ff 75 f4             	pushl  -0xc(%ebp)
  803478:	e8 0d f5 ff ff       	call   80298a <fd2num>
  80347d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803480:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803482:	83 c4 04             	add    $0x4,%esp
  803485:	ff 75 f0             	pushl  -0x10(%ebp)
  803488:	e8 fd f4 ff ff       	call   80298a <fd2num>
  80348d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803490:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803493:	83 c4 10             	add    $0x10,%esp
  803496:	bb 00 00 00 00       	mov    $0x0,%ebx
  80349b:	e9 4f ff ff ff       	jmp    8033ef <pipe+0x75>
	sys_page_unmap(0, va);
  8034a0:	83 ec 08             	sub    $0x8,%esp
  8034a3:	56                   	push   %esi
  8034a4:	6a 00                	push   $0x0
  8034a6:	e8 ea f1 ff ff       	call   802695 <sys_page_unmap>
  8034ab:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8034ae:	83 ec 08             	sub    $0x8,%esp
  8034b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8034b4:	6a 00                	push   $0x0
  8034b6:	e8 da f1 ff ff       	call   802695 <sys_page_unmap>
  8034bb:	83 c4 10             	add    $0x10,%esp
  8034be:	e9 1c ff ff ff       	jmp    8033df <pipe+0x65>

008034c3 <pipeisclosed>:
{
  8034c3:	55                   	push   %ebp
  8034c4:	89 e5                	mov    %esp,%ebp
  8034c6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8034c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8034cc:	50                   	push   %eax
  8034cd:	ff 75 08             	pushl  0x8(%ebp)
  8034d0:	e8 2b f5 ff ff       	call   802a00 <fd_lookup>
  8034d5:	83 c4 10             	add    $0x10,%esp
  8034d8:	85 c0                	test   %eax,%eax
  8034da:	78 18                	js     8034f4 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8034dc:	83 ec 0c             	sub    $0xc,%esp
  8034df:	ff 75 f4             	pushl  -0xc(%ebp)
  8034e2:	e8 b3 f4 ff ff       	call   80299a <fd2data>
	return _pipeisclosed(fd, p);
  8034e7:	89 c2                	mov    %eax,%edx
  8034e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034ec:	e8 30 fd ff ff       	call   803221 <_pipeisclosed>
  8034f1:	83 c4 10             	add    $0x10,%esp
}
  8034f4:	c9                   	leave  
  8034f5:	c3                   	ret    

008034f6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8034f6:	55                   	push   %ebp
  8034f7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8034f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8034fe:	5d                   	pop    %ebp
  8034ff:	c3                   	ret    

00803500 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803500:	55                   	push   %ebp
  803501:	89 e5                	mov    %esp,%ebp
  803503:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803506:	68 ed 42 80 00       	push   $0x8042ed
  80350b:	ff 75 0c             	pushl  0xc(%ebp)
  80350e:	e8 04 ed ff ff       	call   802217 <strcpy>
	return 0;
}
  803513:	b8 00 00 00 00       	mov    $0x0,%eax
  803518:	c9                   	leave  
  803519:	c3                   	ret    

0080351a <devcons_write>:
{
  80351a:	55                   	push   %ebp
  80351b:	89 e5                	mov    %esp,%ebp
  80351d:	57                   	push   %edi
  80351e:	56                   	push   %esi
  80351f:	53                   	push   %ebx
  803520:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  803526:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80352b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  803531:	eb 2f                	jmp    803562 <devcons_write+0x48>
		m = n - tot;
  803533:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803536:	29 f3                	sub    %esi,%ebx
  803538:	83 fb 7f             	cmp    $0x7f,%ebx
  80353b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  803540:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  803543:	83 ec 04             	sub    $0x4,%esp
  803546:	53                   	push   %ebx
  803547:	89 f0                	mov    %esi,%eax
  803549:	03 45 0c             	add    0xc(%ebp),%eax
  80354c:	50                   	push   %eax
  80354d:	57                   	push   %edi
  80354e:	e8 52 ee ff ff       	call   8023a5 <memmove>
		sys_cputs(buf, m);
  803553:	83 c4 08             	add    $0x8,%esp
  803556:	53                   	push   %ebx
  803557:	57                   	push   %edi
  803558:	e8 f7 ef ff ff       	call   802554 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80355d:	01 de                	add    %ebx,%esi
  80355f:	83 c4 10             	add    $0x10,%esp
  803562:	3b 75 10             	cmp    0x10(%ebp),%esi
  803565:	72 cc                	jb     803533 <devcons_write+0x19>
}
  803567:	89 f0                	mov    %esi,%eax
  803569:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80356c:	5b                   	pop    %ebx
  80356d:	5e                   	pop    %esi
  80356e:	5f                   	pop    %edi
  80356f:	5d                   	pop    %ebp
  803570:	c3                   	ret    

00803571 <devcons_read>:
{
  803571:	55                   	push   %ebp
  803572:	89 e5                	mov    %esp,%ebp
  803574:	83 ec 08             	sub    $0x8,%esp
  803577:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80357c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803580:	75 07                	jne    803589 <devcons_read+0x18>
}
  803582:	c9                   	leave  
  803583:	c3                   	ret    
		sys_yield();
  803584:	e8 68 f0 ff ff       	call   8025f1 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  803589:	e8 e4 ef ff ff       	call   802572 <sys_cgetc>
  80358e:	85 c0                	test   %eax,%eax
  803590:	74 f2                	je     803584 <devcons_read+0x13>
	if (c < 0)
  803592:	85 c0                	test   %eax,%eax
  803594:	78 ec                	js     803582 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  803596:	83 f8 04             	cmp    $0x4,%eax
  803599:	74 0c                	je     8035a7 <devcons_read+0x36>
	*(char*)vbuf = c;
  80359b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80359e:	88 02                	mov    %al,(%edx)
	return 1;
  8035a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8035a5:	eb db                	jmp    803582 <devcons_read+0x11>
		return 0;
  8035a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8035ac:	eb d4                	jmp    803582 <devcons_read+0x11>

008035ae <cputchar>:
{
  8035ae:	55                   	push   %ebp
  8035af:	89 e5                	mov    %esp,%ebp
  8035b1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8035b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8035b7:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8035ba:	6a 01                	push   $0x1
  8035bc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8035bf:	50                   	push   %eax
  8035c0:	e8 8f ef ff ff       	call   802554 <sys_cputs>
}
  8035c5:	83 c4 10             	add    $0x10,%esp
  8035c8:	c9                   	leave  
  8035c9:	c3                   	ret    

008035ca <getchar>:
{
  8035ca:	55                   	push   %ebp
  8035cb:	89 e5                	mov    %esp,%ebp
  8035cd:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8035d0:	6a 01                	push   $0x1
  8035d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8035d5:	50                   	push   %eax
  8035d6:	6a 00                	push   $0x0
  8035d8:	e8 94 f6 ff ff       	call   802c71 <read>
	if (r < 0)
  8035dd:	83 c4 10             	add    $0x10,%esp
  8035e0:	85 c0                	test   %eax,%eax
  8035e2:	78 08                	js     8035ec <getchar+0x22>
	if (r < 1)
  8035e4:	85 c0                	test   %eax,%eax
  8035e6:	7e 06                	jle    8035ee <getchar+0x24>
	return c;
  8035e8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8035ec:	c9                   	leave  
  8035ed:	c3                   	ret    
		return -E_EOF;
  8035ee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8035f3:	eb f7                	jmp    8035ec <getchar+0x22>

008035f5 <iscons>:
{
  8035f5:	55                   	push   %ebp
  8035f6:	89 e5                	mov    %esp,%ebp
  8035f8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8035fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8035fe:	50                   	push   %eax
  8035ff:	ff 75 08             	pushl  0x8(%ebp)
  803602:	e8 f9 f3 ff ff       	call   802a00 <fd_lookup>
  803607:	83 c4 10             	add    $0x10,%esp
  80360a:	85 c0                	test   %eax,%eax
  80360c:	78 11                	js     80361f <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80360e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803611:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803617:	39 10                	cmp    %edx,(%eax)
  803619:	0f 94 c0             	sete   %al
  80361c:	0f b6 c0             	movzbl %al,%eax
}
  80361f:	c9                   	leave  
  803620:	c3                   	ret    

00803621 <opencons>:
{
  803621:	55                   	push   %ebp
  803622:	89 e5                	mov    %esp,%ebp
  803624:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  803627:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80362a:	50                   	push   %eax
  80362b:	e8 81 f3 ff ff       	call   8029b1 <fd_alloc>
  803630:	83 c4 10             	add    $0x10,%esp
  803633:	85 c0                	test   %eax,%eax
  803635:	78 3a                	js     803671 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803637:	83 ec 04             	sub    $0x4,%esp
  80363a:	68 07 04 00 00       	push   $0x407
  80363f:	ff 75 f4             	pushl  -0xc(%ebp)
  803642:	6a 00                	push   $0x0
  803644:	e8 c7 ef ff ff       	call   802610 <sys_page_alloc>
  803649:	83 c4 10             	add    $0x10,%esp
  80364c:	85 c0                	test   %eax,%eax
  80364e:	78 21                	js     803671 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  803650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803653:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803659:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80365b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80365e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803665:	83 ec 0c             	sub    $0xc,%esp
  803668:	50                   	push   %eax
  803669:	e8 1c f3 ff ff       	call   80298a <fd2num>
  80366e:	83 c4 10             	add    $0x10,%esp
}
  803671:	c9                   	leave  
  803672:	c3                   	ret    
  803673:	66 90                	xchg   %ax,%ax
  803675:	66 90                	xchg   %ax,%ax
  803677:	66 90                	xchg   %ax,%ax
  803679:	66 90                	xchg   %ax,%ax
  80367b:	66 90                	xchg   %ax,%ax
  80367d:	66 90                	xchg   %ax,%ax
  80367f:	90                   	nop

00803680 <__udivdi3>:
  803680:	55                   	push   %ebp
  803681:	57                   	push   %edi
  803682:	56                   	push   %esi
  803683:	53                   	push   %ebx
  803684:	83 ec 1c             	sub    $0x1c,%esp
  803687:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80368b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80368f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803693:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  803697:	85 d2                	test   %edx,%edx
  803699:	75 35                	jne    8036d0 <__udivdi3+0x50>
  80369b:	39 f3                	cmp    %esi,%ebx
  80369d:	0f 87 bd 00 00 00    	ja     803760 <__udivdi3+0xe0>
  8036a3:	85 db                	test   %ebx,%ebx
  8036a5:	89 d9                	mov    %ebx,%ecx
  8036a7:	75 0b                	jne    8036b4 <__udivdi3+0x34>
  8036a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8036ae:	31 d2                	xor    %edx,%edx
  8036b0:	f7 f3                	div    %ebx
  8036b2:	89 c1                	mov    %eax,%ecx
  8036b4:	31 d2                	xor    %edx,%edx
  8036b6:	89 f0                	mov    %esi,%eax
  8036b8:	f7 f1                	div    %ecx
  8036ba:	89 c6                	mov    %eax,%esi
  8036bc:	89 e8                	mov    %ebp,%eax
  8036be:	89 f7                	mov    %esi,%edi
  8036c0:	f7 f1                	div    %ecx
  8036c2:	89 fa                	mov    %edi,%edx
  8036c4:	83 c4 1c             	add    $0x1c,%esp
  8036c7:	5b                   	pop    %ebx
  8036c8:	5e                   	pop    %esi
  8036c9:	5f                   	pop    %edi
  8036ca:	5d                   	pop    %ebp
  8036cb:	c3                   	ret    
  8036cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8036d0:	39 f2                	cmp    %esi,%edx
  8036d2:	77 7c                	ja     803750 <__udivdi3+0xd0>
  8036d4:	0f bd fa             	bsr    %edx,%edi
  8036d7:	83 f7 1f             	xor    $0x1f,%edi
  8036da:	0f 84 98 00 00 00    	je     803778 <__udivdi3+0xf8>
  8036e0:	89 f9                	mov    %edi,%ecx
  8036e2:	b8 20 00 00 00       	mov    $0x20,%eax
  8036e7:	29 f8                	sub    %edi,%eax
  8036e9:	d3 e2                	shl    %cl,%edx
  8036eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8036ef:	89 c1                	mov    %eax,%ecx
  8036f1:	89 da                	mov    %ebx,%edx
  8036f3:	d3 ea                	shr    %cl,%edx
  8036f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8036f9:	09 d1                	or     %edx,%ecx
  8036fb:	89 f2                	mov    %esi,%edx
  8036fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803701:	89 f9                	mov    %edi,%ecx
  803703:	d3 e3                	shl    %cl,%ebx
  803705:	89 c1                	mov    %eax,%ecx
  803707:	d3 ea                	shr    %cl,%edx
  803709:	89 f9                	mov    %edi,%ecx
  80370b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80370f:	d3 e6                	shl    %cl,%esi
  803711:	89 eb                	mov    %ebp,%ebx
  803713:	89 c1                	mov    %eax,%ecx
  803715:	d3 eb                	shr    %cl,%ebx
  803717:	09 de                	or     %ebx,%esi
  803719:	89 f0                	mov    %esi,%eax
  80371b:	f7 74 24 08          	divl   0x8(%esp)
  80371f:	89 d6                	mov    %edx,%esi
  803721:	89 c3                	mov    %eax,%ebx
  803723:	f7 64 24 0c          	mull   0xc(%esp)
  803727:	39 d6                	cmp    %edx,%esi
  803729:	72 0c                	jb     803737 <__udivdi3+0xb7>
  80372b:	89 f9                	mov    %edi,%ecx
  80372d:	d3 e5                	shl    %cl,%ebp
  80372f:	39 c5                	cmp    %eax,%ebp
  803731:	73 5d                	jae    803790 <__udivdi3+0x110>
  803733:	39 d6                	cmp    %edx,%esi
  803735:	75 59                	jne    803790 <__udivdi3+0x110>
  803737:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80373a:	31 ff                	xor    %edi,%edi
  80373c:	89 fa                	mov    %edi,%edx
  80373e:	83 c4 1c             	add    $0x1c,%esp
  803741:	5b                   	pop    %ebx
  803742:	5e                   	pop    %esi
  803743:	5f                   	pop    %edi
  803744:	5d                   	pop    %ebp
  803745:	c3                   	ret    
  803746:	8d 76 00             	lea    0x0(%esi),%esi
  803749:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  803750:	31 ff                	xor    %edi,%edi
  803752:	31 c0                	xor    %eax,%eax
  803754:	89 fa                	mov    %edi,%edx
  803756:	83 c4 1c             	add    $0x1c,%esp
  803759:	5b                   	pop    %ebx
  80375a:	5e                   	pop    %esi
  80375b:	5f                   	pop    %edi
  80375c:	5d                   	pop    %ebp
  80375d:	c3                   	ret    
  80375e:	66 90                	xchg   %ax,%ax
  803760:	31 ff                	xor    %edi,%edi
  803762:	89 e8                	mov    %ebp,%eax
  803764:	89 f2                	mov    %esi,%edx
  803766:	f7 f3                	div    %ebx
  803768:	89 fa                	mov    %edi,%edx
  80376a:	83 c4 1c             	add    $0x1c,%esp
  80376d:	5b                   	pop    %ebx
  80376e:	5e                   	pop    %esi
  80376f:	5f                   	pop    %edi
  803770:	5d                   	pop    %ebp
  803771:	c3                   	ret    
  803772:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803778:	39 f2                	cmp    %esi,%edx
  80377a:	72 06                	jb     803782 <__udivdi3+0x102>
  80377c:	31 c0                	xor    %eax,%eax
  80377e:	39 eb                	cmp    %ebp,%ebx
  803780:	77 d2                	ja     803754 <__udivdi3+0xd4>
  803782:	b8 01 00 00 00       	mov    $0x1,%eax
  803787:	eb cb                	jmp    803754 <__udivdi3+0xd4>
  803789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803790:	89 d8                	mov    %ebx,%eax
  803792:	31 ff                	xor    %edi,%edi
  803794:	eb be                	jmp    803754 <__udivdi3+0xd4>
  803796:	66 90                	xchg   %ax,%ax
  803798:	66 90                	xchg   %ax,%ax
  80379a:	66 90                	xchg   %ax,%ax
  80379c:	66 90                	xchg   %ax,%ax
  80379e:	66 90                	xchg   %ax,%ax

008037a0 <__umoddi3>:
  8037a0:	55                   	push   %ebp
  8037a1:	57                   	push   %edi
  8037a2:	56                   	push   %esi
  8037a3:	53                   	push   %ebx
  8037a4:	83 ec 1c             	sub    $0x1c,%esp
  8037a7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8037ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8037af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8037b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8037b7:	85 ed                	test   %ebp,%ebp
  8037b9:	89 f0                	mov    %esi,%eax
  8037bb:	89 da                	mov    %ebx,%edx
  8037bd:	75 19                	jne    8037d8 <__umoddi3+0x38>
  8037bf:	39 df                	cmp    %ebx,%edi
  8037c1:	0f 86 b1 00 00 00    	jbe    803878 <__umoddi3+0xd8>
  8037c7:	f7 f7                	div    %edi
  8037c9:	89 d0                	mov    %edx,%eax
  8037cb:	31 d2                	xor    %edx,%edx
  8037cd:	83 c4 1c             	add    $0x1c,%esp
  8037d0:	5b                   	pop    %ebx
  8037d1:	5e                   	pop    %esi
  8037d2:	5f                   	pop    %edi
  8037d3:	5d                   	pop    %ebp
  8037d4:	c3                   	ret    
  8037d5:	8d 76 00             	lea    0x0(%esi),%esi
  8037d8:	39 dd                	cmp    %ebx,%ebp
  8037da:	77 f1                	ja     8037cd <__umoddi3+0x2d>
  8037dc:	0f bd cd             	bsr    %ebp,%ecx
  8037df:	83 f1 1f             	xor    $0x1f,%ecx
  8037e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8037e6:	0f 84 b4 00 00 00    	je     8038a0 <__umoddi3+0x100>
  8037ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8037f1:	89 c2                	mov    %eax,%edx
  8037f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8037f7:	29 c2                	sub    %eax,%edx
  8037f9:	89 c1                	mov    %eax,%ecx
  8037fb:	89 f8                	mov    %edi,%eax
  8037fd:	d3 e5                	shl    %cl,%ebp
  8037ff:	89 d1                	mov    %edx,%ecx
  803801:	89 54 24 0c          	mov    %edx,0xc(%esp)
  803805:	d3 e8                	shr    %cl,%eax
  803807:	09 c5                	or     %eax,%ebp
  803809:	8b 44 24 04          	mov    0x4(%esp),%eax
  80380d:	89 c1                	mov    %eax,%ecx
  80380f:	d3 e7                	shl    %cl,%edi
  803811:	89 d1                	mov    %edx,%ecx
  803813:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803817:	89 df                	mov    %ebx,%edi
  803819:	d3 ef                	shr    %cl,%edi
  80381b:	89 c1                	mov    %eax,%ecx
  80381d:	89 f0                	mov    %esi,%eax
  80381f:	d3 e3                	shl    %cl,%ebx
  803821:	89 d1                	mov    %edx,%ecx
  803823:	89 fa                	mov    %edi,%edx
  803825:	d3 e8                	shr    %cl,%eax
  803827:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80382c:	09 d8                	or     %ebx,%eax
  80382e:	f7 f5                	div    %ebp
  803830:	d3 e6                	shl    %cl,%esi
  803832:	89 d1                	mov    %edx,%ecx
  803834:	f7 64 24 08          	mull   0x8(%esp)
  803838:	39 d1                	cmp    %edx,%ecx
  80383a:	89 c3                	mov    %eax,%ebx
  80383c:	89 d7                	mov    %edx,%edi
  80383e:	72 06                	jb     803846 <__umoddi3+0xa6>
  803840:	75 0e                	jne    803850 <__umoddi3+0xb0>
  803842:	39 c6                	cmp    %eax,%esi
  803844:	73 0a                	jae    803850 <__umoddi3+0xb0>
  803846:	2b 44 24 08          	sub    0x8(%esp),%eax
  80384a:	19 ea                	sbb    %ebp,%edx
  80384c:	89 d7                	mov    %edx,%edi
  80384e:	89 c3                	mov    %eax,%ebx
  803850:	89 ca                	mov    %ecx,%edx
  803852:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  803857:	29 de                	sub    %ebx,%esi
  803859:	19 fa                	sbb    %edi,%edx
  80385b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80385f:	89 d0                	mov    %edx,%eax
  803861:	d3 e0                	shl    %cl,%eax
  803863:	89 d9                	mov    %ebx,%ecx
  803865:	d3 ee                	shr    %cl,%esi
  803867:	d3 ea                	shr    %cl,%edx
  803869:	09 f0                	or     %esi,%eax
  80386b:	83 c4 1c             	add    $0x1c,%esp
  80386e:	5b                   	pop    %ebx
  80386f:	5e                   	pop    %esi
  803870:	5f                   	pop    %edi
  803871:	5d                   	pop    %ebp
  803872:	c3                   	ret    
  803873:	90                   	nop
  803874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803878:	85 ff                	test   %edi,%edi
  80387a:	89 f9                	mov    %edi,%ecx
  80387c:	75 0b                	jne    803889 <__umoddi3+0xe9>
  80387e:	b8 01 00 00 00       	mov    $0x1,%eax
  803883:	31 d2                	xor    %edx,%edx
  803885:	f7 f7                	div    %edi
  803887:	89 c1                	mov    %eax,%ecx
  803889:	89 d8                	mov    %ebx,%eax
  80388b:	31 d2                	xor    %edx,%edx
  80388d:	f7 f1                	div    %ecx
  80388f:	89 f0                	mov    %esi,%eax
  803891:	f7 f1                	div    %ecx
  803893:	e9 31 ff ff ff       	jmp    8037c9 <__umoddi3+0x29>
  803898:	90                   	nop
  803899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8038a0:	39 dd                	cmp    %ebx,%ebp
  8038a2:	72 08                	jb     8038ac <__umoddi3+0x10c>
  8038a4:	39 f7                	cmp    %esi,%edi
  8038a6:	0f 87 21 ff ff ff    	ja     8037cd <__umoddi3+0x2d>
  8038ac:	89 da                	mov    %ebx,%edx
  8038ae:	89 f0                	mov    %esi,%eax
  8038b0:	29 f8                	sub    %edi,%eax
  8038b2:	19 ea                	sbb    %ebp,%edx
  8038b4:	e9 14 ff ff ff       	jmp    8037cd <__umoddi3+0x2d>
