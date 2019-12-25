
obj/user/testfdsharing.debug：     文件格式 elf32-i386


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
  80002c:	e8 9b 01 00 00       	call   8001cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 20 23 80 00       	push   $0x802320
  800043:	e8 f9 18 00 00       	call   801941 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	0f 88 01 01 00 00    	js     800156 <umain+0x123>
		panic("open motd: %e", fd);
	seek(fd, 0);
  800055:	83 ec 08             	sub    $0x8,%esp
  800058:	6a 00                	push   $0x0
  80005a:	50                   	push   %eax
  80005b:	e8 d9 15 00 00       	call   801639 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800060:	83 c4 0c             	add    $0xc,%esp
  800063:	68 00 02 00 00       	push   $0x200
  800068:	68 20 42 80 00       	push   $0x804220
  80006d:	53                   	push   %ebx
  80006e:	e8 fd 14 00 00       	call   801570 <readn>
  800073:	89 c6                	mov    %eax,%esi
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	85 c0                	test   %eax,%eax
  80007a:	0f 8e e8 00 00 00    	jle    800168 <umain+0x135>
		panic("readn: %e", n);

	if ((r = fork()) < 0)
  800080:	e8 8d 0f 00 00       	call   801012 <fork>
  800085:	89 c7                	mov    %eax,%edi
  800087:	85 c0                	test   %eax,%eax
  800089:	0f 88 eb 00 00 00    	js     80017a <umain+0x147>
		panic("fork: %e", r);
	if (r == 0) {
  80008f:	85 c0                	test   %eax,%eax
  800091:	75 7b                	jne    80010e <umain+0xdb>
		seek(fd, 0);
  800093:	83 ec 08             	sub    $0x8,%esp
  800096:	6a 00                	push   $0x0
  800098:	53                   	push   %ebx
  800099:	e8 9b 15 00 00       	call   801639 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  80009e:	c7 04 24 88 23 80 00 	movl   $0x802388,(%esp)
  8000a5:	e8 5d 02 00 00       	call   800307 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000aa:	83 c4 0c             	add    $0xc,%esp
  8000ad:	68 00 02 00 00       	push   $0x200
  8000b2:	68 20 40 80 00       	push   $0x804020
  8000b7:	53                   	push   %ebx
  8000b8:	e8 b3 14 00 00       	call   801570 <readn>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	39 c6                	cmp    %eax,%esi
  8000c2:	0f 85 c4 00 00 00    	jne    80018c <umain+0x159>
			panic("read in parent got %d, read in child got %d", n, n2);
		if (memcmp(buf, buf2, n) != 0)
  8000c8:	83 ec 04             	sub    $0x4,%esp
  8000cb:	56                   	push   %esi
  8000cc:	68 20 40 80 00       	push   $0x804020
  8000d1:	68 20 42 80 00       	push   $0x804220
  8000d6:	e8 54 0a 00 00       	call   800b2f <memcmp>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	85 c0                	test   %eax,%eax
  8000e0:	0f 85 bc 00 00 00    	jne    8001a2 <umain+0x16f>
			panic("read in parent got different bytes from read in child");
		cprintf("read in child succeeded\n");
  8000e6:	83 ec 0c             	sub    $0xc,%esp
  8000e9:	68 52 23 80 00       	push   $0x802352
  8000ee:	e8 14 02 00 00       	call   800307 <cprintf>
		seek(fd, 0);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6a 00                	push   $0x0
  8000f8:	53                   	push   %ebx
  8000f9:	e8 3b 15 00 00       	call   801639 <seek>
		close(fd);
  8000fe:	89 1c 24             	mov    %ebx,(%esp)
  800101:	e8 a7 12 00 00       	call   8013ad <close>
		exit();
  800106:	e8 07 01 00 00       	call   800212 <exit>
  80010b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	57                   	push   %edi
  800112:	e8 1c 1c 00 00       	call   801d33 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800117:	83 c4 0c             	add    $0xc,%esp
  80011a:	68 00 02 00 00       	push   $0x200
  80011f:	68 20 40 80 00       	push   $0x804020
  800124:	53                   	push   %ebx
  800125:	e8 46 14 00 00       	call   801570 <readn>
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	39 c6                	cmp    %eax,%esi
  80012f:	0f 85 81 00 00 00    	jne    8001b6 <umain+0x183>
		panic("read in parent got %d, then got %d", n, n2);
	cprintf("read in parent succeeded\n");
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	68 6b 23 80 00       	push   $0x80236b
  80013d:	e8 c5 01 00 00       	call   800307 <cprintf>
	close(fd);
  800142:	89 1c 24             	mov    %ebx,(%esp)
  800145:	e8 63 12 00 00       	call   8013ad <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80014a:	cc                   	int3   

	breakpoint();
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    
		panic("open motd: %e", fd);
  800156:	50                   	push   %eax
  800157:	68 25 23 80 00       	push   $0x802325
  80015c:	6a 0c                	push   $0xc
  80015e:	68 33 23 80 00       	push   $0x802333
  800163:	e8 c4 00 00 00       	call   80022c <_panic>
		panic("readn: %e", n);
  800168:	50                   	push   %eax
  800169:	68 48 23 80 00       	push   $0x802348
  80016e:	6a 0f                	push   $0xf
  800170:	68 33 23 80 00       	push   $0x802333
  800175:	e8 b2 00 00 00       	call   80022c <_panic>
		panic("fork: %e", r);
  80017a:	50                   	push   %eax
  80017b:	68 f9 27 80 00       	push   $0x8027f9
  800180:	6a 12                	push   $0x12
  800182:	68 33 23 80 00       	push   $0x802333
  800187:	e8 a0 00 00 00       	call   80022c <_panic>
			panic("read in parent got %d, read in child got %d", n, n2);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	56                   	push   %esi
  800191:	68 cc 23 80 00       	push   $0x8023cc
  800196:	6a 17                	push   $0x17
  800198:	68 33 23 80 00       	push   $0x802333
  80019d:	e8 8a 00 00 00       	call   80022c <_panic>
			panic("read in parent got different bytes from read in child");
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	68 f8 23 80 00       	push   $0x8023f8
  8001aa:	6a 19                	push   $0x19
  8001ac:	68 33 23 80 00       	push   $0x802333
  8001b1:	e8 76 00 00 00       	call   80022c <_panic>
		panic("read in parent got %d, then got %d", n, n2);
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	50                   	push   %eax
  8001ba:	56                   	push   %esi
  8001bb:	68 30 24 80 00       	push   $0x802430
  8001c0:	6a 21                	push   $0x21
  8001c2:	68 33 23 80 00       	push   $0x802333
  8001c7:	e8 60 00 00 00       	call   80022c <_panic>

008001cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8001d7:	e8 05 0b 00 00       	call   800ce1 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8001dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e9:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ee:	85 db                	test   %ebx,%ebx
  8001f0:	7e 07                	jle    8001f9 <libmain+0x2d>
		binaryname = argv[0];
  8001f2:	8b 06                	mov    (%esi),%eax
  8001f4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	56                   	push   %esi
  8001fd:	53                   	push   %ebx
  8001fe:	e8 30 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800203:	e8 0a 00 00 00       	call   800212 <exit>
}
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800218:	e8 bb 11 00 00       	call   8013d8 <close_all>
	sys_env_destroy(0);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	6a 00                	push   $0x0
  800222:	e8 79 0a 00 00       	call   800ca0 <sys_env_destroy>
}
  800227:	83 c4 10             	add    $0x10,%esp
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800231:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800234:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80023a:	e8 a2 0a 00 00       	call   800ce1 <sys_getenvid>
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	ff 75 08             	pushl  0x8(%ebp)
  800248:	56                   	push   %esi
  800249:	50                   	push   %eax
  80024a:	68 60 24 80 00       	push   $0x802460
  80024f:	e8 b3 00 00 00       	call   800307 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800254:	83 c4 18             	add    $0x18,%esp
  800257:	53                   	push   %ebx
  800258:	ff 75 10             	pushl  0x10(%ebp)
  80025b:	e8 56 00 00 00       	call   8002b6 <vcprintf>
	cprintf("\n");
  800260:	c7 04 24 69 23 80 00 	movl   $0x802369,(%esp)
  800267:	e8 9b 00 00 00       	call   800307 <cprintf>
  80026c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026f:	cc                   	int3   
  800270:	eb fd                	jmp    80026f <_panic+0x43>

00800272 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	53                   	push   %ebx
  800276:	83 ec 04             	sub    $0x4,%esp
  800279:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027c:	8b 13                	mov    (%ebx),%edx
  80027e:	8d 42 01             	lea    0x1(%edx),%eax
  800281:	89 03                	mov    %eax,(%ebx)
  800283:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800286:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028f:	74 09                	je     80029a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800291:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800295:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800298:	c9                   	leave  
  800299:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	68 ff 00 00 00       	push   $0xff
  8002a2:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a5:	50                   	push   %eax
  8002a6:	e8 b8 09 00 00       	call   800c63 <sys_cputs>
		b->idx = 0;
  8002ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b1:	83 c4 10             	add    $0x10,%esp
  8002b4:	eb db                	jmp    800291 <putch+0x1f>

008002b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c6:	00 00 00 
	b.cnt = 0;
  8002c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d3:	ff 75 0c             	pushl  0xc(%ebp)
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002df:	50                   	push   %eax
  8002e0:	68 72 02 80 00       	push   $0x800272
  8002e5:	e8 1a 01 00 00       	call   800404 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ea:	83 c4 08             	add    $0x8,%esp
  8002ed:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	e8 64 09 00 00       	call   800c63 <sys_cputs>

	return b.cnt;
}
  8002ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800310:	50                   	push   %eax
  800311:	ff 75 08             	pushl  0x8(%ebp)
  800314:	e8 9d ff ff ff       	call   8002b6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	57                   	push   %edi
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
  800321:	83 ec 1c             	sub    $0x1c,%esp
  800324:	89 c7                	mov    %eax,%edi
  800326:	89 d6                	mov    %edx,%esi
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800331:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800334:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800337:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80033f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800342:	39 d3                	cmp    %edx,%ebx
  800344:	72 05                	jb     80034b <printnum+0x30>
  800346:	39 45 10             	cmp    %eax,0x10(%ebp)
  800349:	77 7a                	ja     8003c5 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80034b:	83 ec 0c             	sub    $0xc,%esp
  80034e:	ff 75 18             	pushl  0x18(%ebp)
  800351:	8b 45 14             	mov    0x14(%ebp),%eax
  800354:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800357:	53                   	push   %ebx
  800358:	ff 75 10             	pushl  0x10(%ebp)
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800361:	ff 75 e0             	pushl  -0x20(%ebp)
  800364:	ff 75 dc             	pushl  -0x24(%ebp)
  800367:	ff 75 d8             	pushl  -0x28(%ebp)
  80036a:	e8 61 1d 00 00       	call   8020d0 <__udivdi3>
  80036f:	83 c4 18             	add    $0x18,%esp
  800372:	52                   	push   %edx
  800373:	50                   	push   %eax
  800374:	89 f2                	mov    %esi,%edx
  800376:	89 f8                	mov    %edi,%eax
  800378:	e8 9e ff ff ff       	call   80031b <printnum>
  80037d:	83 c4 20             	add    $0x20,%esp
  800380:	eb 13                	jmp    800395 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	56                   	push   %esi
  800386:	ff 75 18             	pushl  0x18(%ebp)
  800389:	ff d7                	call   *%edi
  80038b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80038e:	83 eb 01             	sub    $0x1,%ebx
  800391:	85 db                	test   %ebx,%ebx
  800393:	7f ed                	jg     800382 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800395:	83 ec 08             	sub    $0x8,%esp
  800398:	56                   	push   %esi
  800399:	83 ec 04             	sub    $0x4,%esp
  80039c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80039f:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a8:	e8 43 1e 00 00       	call   8021f0 <__umoddi3>
  8003ad:	83 c4 14             	add    $0x14,%esp
  8003b0:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
  8003b7:	50                   	push   %eax
  8003b8:	ff d7                	call   *%edi
}
  8003ba:	83 c4 10             	add    $0x10,%esp
  8003bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c0:	5b                   	pop    %ebx
  8003c1:	5e                   	pop    %esi
  8003c2:	5f                   	pop    %edi
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    
  8003c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003c8:	eb c4                	jmp    80038e <printnum+0x73>

008003ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d4:	8b 10                	mov    (%eax),%edx
  8003d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d9:	73 0a                	jae    8003e5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	88 02                	mov    %al,(%edx)
}
  8003e5:	5d                   	pop    %ebp
  8003e6:	c3                   	ret    

008003e7 <printfmt>:
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f0:	50                   	push   %eax
  8003f1:	ff 75 10             	pushl  0x10(%ebp)
  8003f4:	ff 75 0c             	pushl  0xc(%ebp)
  8003f7:	ff 75 08             	pushl  0x8(%ebp)
  8003fa:	e8 05 00 00 00       	call   800404 <vprintfmt>
}
  8003ff:	83 c4 10             	add    $0x10,%esp
  800402:	c9                   	leave  
  800403:	c3                   	ret    

00800404 <vprintfmt>:
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	83 ec 2c             	sub    $0x2c,%esp
  80040d:	8b 75 08             	mov    0x8(%ebp),%esi
  800410:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800413:	8b 7d 10             	mov    0x10(%ebp),%edi
  800416:	e9 c1 03 00 00       	jmp    8007dc <vprintfmt+0x3d8>
		padc = ' ';
  80041b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80041f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800426:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80042d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800434:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8d 47 01             	lea    0x1(%edi),%eax
  80043c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043f:	0f b6 17             	movzbl (%edi),%edx
  800442:	8d 42 dd             	lea    -0x23(%edx),%eax
  800445:	3c 55                	cmp    $0x55,%al
  800447:	0f 87 12 04 00 00    	ja     80085f <vprintfmt+0x45b>
  80044d:	0f b6 c0             	movzbl %al,%eax
  800450:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80045a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80045e:	eb d9                	jmp    800439 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800463:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800467:	eb d0                	jmp    800439 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800469:	0f b6 d2             	movzbl %dl,%edx
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80046f:	b8 00 00 00 00       	mov    $0x0,%eax
  800474:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800477:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80047e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800481:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800484:	83 f9 09             	cmp    $0x9,%ecx
  800487:	77 55                	ja     8004de <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800489:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80048c:	eb e9                	jmp    800477 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8b 00                	mov    (%eax),%eax
  800493:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 40 04             	lea    0x4(%eax),%eax
  80049c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a6:	79 91                	jns    800439 <vprintfmt+0x35>
				width = precision, precision = -1;
  8004a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b5:	eb 82                	jmp    800439 <vprintfmt+0x35>
  8004b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c1:	0f 49 d0             	cmovns %eax,%edx
  8004c4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	e9 6a ff ff ff       	jmp    800439 <vprintfmt+0x35>
  8004cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004d2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004d9:	e9 5b ff ff ff       	jmp    800439 <vprintfmt+0x35>
  8004de:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004e4:	eb bc                	jmp    8004a2 <vprintfmt+0x9e>
			lflag++;
  8004e6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004ec:	e9 48 ff ff ff       	jmp    800439 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 78 04             	lea    0x4(%eax),%edi
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 30                	pushl  (%eax)
  8004fd:	ff d6                	call   *%esi
			break;
  8004ff:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800502:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800505:	e9 cf 02 00 00       	jmp    8007d9 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 78 04             	lea    0x4(%eax),%edi
  800510:	8b 00                	mov    (%eax),%eax
  800512:	99                   	cltd   
  800513:	31 d0                	xor    %edx,%eax
  800515:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800517:	83 f8 0f             	cmp    $0xf,%eax
  80051a:	7f 23                	jg     80053f <vprintfmt+0x13b>
  80051c:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  800523:	85 d2                	test   %edx,%edx
  800525:	74 18                	je     80053f <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800527:	52                   	push   %edx
  800528:	68 e5 28 80 00       	push   $0x8028e5
  80052d:	53                   	push   %ebx
  80052e:	56                   	push   %esi
  80052f:	e8 b3 fe ff ff       	call   8003e7 <printfmt>
  800534:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800537:	89 7d 14             	mov    %edi,0x14(%ebp)
  80053a:	e9 9a 02 00 00       	jmp    8007d9 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80053f:	50                   	push   %eax
  800540:	68 9b 24 80 00       	push   $0x80249b
  800545:	53                   	push   %ebx
  800546:	56                   	push   %esi
  800547:	e8 9b fe ff ff       	call   8003e7 <printfmt>
  80054c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80054f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800552:	e9 82 02 00 00       	jmp    8007d9 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	83 c0 04             	add    $0x4,%eax
  80055d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800565:	85 ff                	test   %edi,%edi
  800567:	b8 94 24 80 00       	mov    $0x802494,%eax
  80056c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80056f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800573:	0f 8e bd 00 00 00    	jle    800636 <vprintfmt+0x232>
  800579:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057d:	75 0e                	jne    80058d <vprintfmt+0x189>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	eb 6d                	jmp    8005fa <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	ff 75 d0             	pushl  -0x30(%ebp)
  800593:	57                   	push   %edi
  800594:	e8 6e 03 00 00       	call   800907 <strnlen>
  800599:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80059c:	29 c1                	sub    %eax,%ecx
  80059e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ab:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005ae:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b0:	eb 0f                	jmp    8005c1 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bb:	83 ef 01             	sub    $0x1,%edi
  8005be:	83 c4 10             	add    $0x10,%esp
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	7f ed                	jg     8005b2 <vprintfmt+0x1ae>
  8005c5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d2:	0f 49 c1             	cmovns %ecx,%eax
  8005d5:	29 c1                	sub    %eax,%ecx
  8005d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e0:	89 cb                	mov    %ecx,%ebx
  8005e2:	eb 16                	jmp    8005fa <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e8:	75 31                	jne    80061b <vprintfmt+0x217>
					putch(ch, putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	ff 75 0c             	pushl  0xc(%ebp)
  8005f0:	50                   	push   %eax
  8005f1:	ff 55 08             	call   *0x8(%ebp)
  8005f4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f7:	83 eb 01             	sub    $0x1,%ebx
  8005fa:	83 c7 01             	add    $0x1,%edi
  8005fd:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800601:	0f be c2             	movsbl %dl,%eax
  800604:	85 c0                	test   %eax,%eax
  800606:	74 59                	je     800661 <vprintfmt+0x25d>
  800608:	85 f6                	test   %esi,%esi
  80060a:	78 d8                	js     8005e4 <vprintfmt+0x1e0>
  80060c:	83 ee 01             	sub    $0x1,%esi
  80060f:	79 d3                	jns    8005e4 <vprintfmt+0x1e0>
  800611:	89 df                	mov    %ebx,%edi
  800613:	8b 75 08             	mov    0x8(%ebp),%esi
  800616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800619:	eb 37                	jmp    800652 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80061b:	0f be d2             	movsbl %dl,%edx
  80061e:	83 ea 20             	sub    $0x20,%edx
  800621:	83 fa 5e             	cmp    $0x5e,%edx
  800624:	76 c4                	jbe    8005ea <vprintfmt+0x1e6>
					putch('?', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	ff 75 0c             	pushl  0xc(%ebp)
  80062c:	6a 3f                	push   $0x3f
  80062e:	ff 55 08             	call   *0x8(%ebp)
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	eb c1                	jmp    8005f7 <vprintfmt+0x1f3>
  800636:	89 75 08             	mov    %esi,0x8(%ebp)
  800639:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800642:	eb b6                	jmp    8005fa <vprintfmt+0x1f6>
				putch(' ', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 20                	push   $0x20
  80064a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80064c:	83 ef 01             	sub    $0x1,%edi
  80064f:	83 c4 10             	add    $0x10,%esp
  800652:	85 ff                	test   %edi,%edi
  800654:	7f ee                	jg     800644 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800656:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
  80065c:	e9 78 01 00 00       	jmp    8007d9 <vprintfmt+0x3d5>
  800661:	89 df                	mov    %ebx,%edi
  800663:	8b 75 08             	mov    0x8(%ebp),%esi
  800666:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800669:	eb e7                	jmp    800652 <vprintfmt+0x24e>
	if (lflag >= 2)
  80066b:	83 f9 01             	cmp    $0x1,%ecx
  80066e:	7e 3f                	jle    8006af <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 50 04             	mov    0x4(%eax),%edx
  800676:	8b 00                	mov    (%eax),%eax
  800678:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 40 08             	lea    0x8(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800687:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068b:	79 5c                	jns    8006e9 <vprintfmt+0x2e5>
				putch('-', putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 2d                	push   $0x2d
  800693:	ff d6                	call   *%esi
				num = -(long long) num;
  800695:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800698:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80069b:	f7 da                	neg    %edx
  80069d:	83 d1 00             	adc    $0x0,%ecx
  8006a0:	f7 d9                	neg    %ecx
  8006a2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006aa:	e9 10 01 00 00       	jmp    8007bf <vprintfmt+0x3bb>
	else if (lflag)
  8006af:	85 c9                	test   %ecx,%ecx
  8006b1:	75 1b                	jne    8006ce <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 00                	mov    (%eax),%eax
  8006b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bb:	89 c1                	mov    %eax,%ecx
  8006bd:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 40 04             	lea    0x4(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cc:	eb b9                	jmp    800687 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d6:	89 c1                	mov    %eax,%ecx
  8006d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8006db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 40 04             	lea    0x4(%eax),%eax
  8006e4:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e7:	eb 9e                	jmp    800687 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8006e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ec:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f4:	e9 c6 00 00 00       	jmp    8007bf <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006f9:	83 f9 01             	cmp    $0x1,%ecx
  8006fc:	7e 18                	jle    800716 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	8b 48 04             	mov    0x4(%eax),%ecx
  800706:	8d 40 08             	lea    0x8(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80070c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800711:	e9 a9 00 00 00       	jmp    8007bf <vprintfmt+0x3bb>
	else if (lflag)
  800716:	85 c9                	test   %ecx,%ecx
  800718:	75 1a                	jne    800734 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800724:	8d 40 04             	lea    0x4(%eax),%eax
  800727:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80072a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072f:	e9 8b 00 00 00       	jmp    8007bf <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073e:	8d 40 04             	lea    0x4(%eax),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800744:	b8 0a 00 00 00       	mov    $0xa,%eax
  800749:	eb 74                	jmp    8007bf <vprintfmt+0x3bb>
	if (lflag >= 2)
  80074b:	83 f9 01             	cmp    $0x1,%ecx
  80074e:	7e 15                	jle    800765 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8b 10                	mov    (%eax),%edx
  800755:	8b 48 04             	mov    0x4(%eax),%ecx
  800758:	8d 40 08             	lea    0x8(%eax),%eax
  80075b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80075e:	b8 08 00 00 00       	mov    $0x8,%eax
  800763:	eb 5a                	jmp    8007bf <vprintfmt+0x3bb>
	else if (lflag)
  800765:	85 c9                	test   %ecx,%ecx
  800767:	75 17                	jne    800780 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800769:	8b 45 14             	mov    0x14(%ebp),%eax
  80076c:	8b 10                	mov    (%eax),%edx
  80076e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800773:	8d 40 04             	lea    0x4(%eax),%eax
  800776:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800779:	b8 08 00 00 00       	mov    $0x8,%eax
  80077e:	eb 3f                	jmp    8007bf <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8b 10                	mov    (%eax),%edx
  800785:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078a:	8d 40 04             	lea    0x4(%eax),%eax
  80078d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800790:	b8 08 00 00 00       	mov    $0x8,%eax
  800795:	eb 28                	jmp    8007bf <vprintfmt+0x3bb>
			putch('0', putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	53                   	push   %ebx
  80079b:	6a 30                	push   $0x30
  80079d:	ff d6                	call   *%esi
			putch('x', putdat);
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	6a 78                	push   $0x78
  8007a5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8b 10                	mov    (%eax),%edx
  8007ac:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007b1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007b4:	8d 40 04             	lea    0x4(%eax),%eax
  8007b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ba:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007bf:	83 ec 0c             	sub    $0xc,%esp
  8007c2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007c6:	57                   	push   %edi
  8007c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ca:	50                   	push   %eax
  8007cb:	51                   	push   %ecx
  8007cc:	52                   	push   %edx
  8007cd:	89 da                	mov    %ebx,%edx
  8007cf:	89 f0                	mov    %esi,%eax
  8007d1:	e8 45 fb ff ff       	call   80031b <printnum>
			break;
  8007d6:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007dc:	83 c7 01             	add    $0x1,%edi
  8007df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007e3:	83 f8 25             	cmp    $0x25,%eax
  8007e6:	0f 84 2f fc ff ff    	je     80041b <vprintfmt+0x17>
			if (ch == '\0')
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	0f 84 8b 00 00 00    	je     80087f <vprintfmt+0x47b>
			putch(ch, putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	53                   	push   %ebx
  8007f8:	50                   	push   %eax
  8007f9:	ff d6                	call   *%esi
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	eb dc                	jmp    8007dc <vprintfmt+0x3d8>
	if (lflag >= 2)
  800800:	83 f9 01             	cmp    $0x1,%ecx
  800803:	7e 15                	jle    80081a <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8b 10                	mov    (%eax),%edx
  80080a:	8b 48 04             	mov    0x4(%eax),%ecx
  80080d:	8d 40 08             	lea    0x8(%eax),%eax
  800810:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800813:	b8 10 00 00 00       	mov    $0x10,%eax
  800818:	eb a5                	jmp    8007bf <vprintfmt+0x3bb>
	else if (lflag)
  80081a:	85 c9                	test   %ecx,%ecx
  80081c:	75 17                	jne    800835 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8b 10                	mov    (%eax),%edx
  800823:	b9 00 00 00 00       	mov    $0x0,%ecx
  800828:	8d 40 04             	lea    0x4(%eax),%eax
  80082b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082e:	b8 10 00 00 00       	mov    $0x10,%eax
  800833:	eb 8a                	jmp    8007bf <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8b 10                	mov    (%eax),%edx
  80083a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083f:	8d 40 04             	lea    0x4(%eax),%eax
  800842:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800845:	b8 10 00 00 00       	mov    $0x10,%eax
  80084a:	e9 70 ff ff ff       	jmp    8007bf <vprintfmt+0x3bb>
			putch(ch, putdat);
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	53                   	push   %ebx
  800853:	6a 25                	push   $0x25
  800855:	ff d6                	call   *%esi
			break;
  800857:	83 c4 10             	add    $0x10,%esp
  80085a:	e9 7a ff ff ff       	jmp    8007d9 <vprintfmt+0x3d5>
			putch('%', putdat);
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	53                   	push   %ebx
  800863:	6a 25                	push   $0x25
  800865:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800867:	83 c4 10             	add    $0x10,%esp
  80086a:	89 f8                	mov    %edi,%eax
  80086c:	eb 03                	jmp    800871 <vprintfmt+0x46d>
  80086e:	83 e8 01             	sub    $0x1,%eax
  800871:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800875:	75 f7                	jne    80086e <vprintfmt+0x46a>
  800877:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80087a:	e9 5a ff ff ff       	jmp    8007d9 <vprintfmt+0x3d5>
}
  80087f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5f                   	pop    %edi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	83 ec 18             	sub    $0x18,%esp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800893:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800896:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	74 26                	je     8008ce <vsnprintf+0x47>
  8008a8:	85 d2                	test   %edx,%edx
  8008aa:	7e 22                	jle    8008ce <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ac:	ff 75 14             	pushl  0x14(%ebp)
  8008af:	ff 75 10             	pushl  0x10(%ebp)
  8008b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b5:	50                   	push   %eax
  8008b6:	68 ca 03 80 00       	push   $0x8003ca
  8008bb:	e8 44 fb ff ff       	call   800404 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c9:	83 c4 10             	add    $0x10,%esp
}
  8008cc:	c9                   	leave  
  8008cd:	c3                   	ret    
		return -E_INVAL;
  8008ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d3:	eb f7                	jmp    8008cc <vsnprintf+0x45>

008008d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008de:	50                   	push   %eax
  8008df:	ff 75 10             	pushl  0x10(%ebp)
  8008e2:	ff 75 0c             	pushl  0xc(%ebp)
  8008e5:	ff 75 08             	pushl  0x8(%ebp)
  8008e8:	e8 9a ff ff ff       	call   800887 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ed:	c9                   	leave  
  8008ee:	c3                   	ret    

008008ef <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fa:	eb 03                	jmp    8008ff <strlen+0x10>
		n++;
  8008fc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008ff:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800903:	75 f7                	jne    8008fc <strlen+0xd>
	return n;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
  800915:	eb 03                	jmp    80091a <strnlen+0x13>
		n++;
  800917:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	74 06                	je     800924 <strnlen+0x1d>
  80091e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800922:	75 f3                	jne    800917 <strnlen+0x10>
	return n;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	53                   	push   %ebx
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800930:	89 c2                	mov    %eax,%edx
  800932:	83 c1 01             	add    $0x1,%ecx
  800935:	83 c2 01             	add    $0x1,%edx
  800938:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80093c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80093f:	84 db                	test   %bl,%bl
  800941:	75 ef                	jne    800932 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800943:	5b                   	pop    %ebx
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80094d:	53                   	push   %ebx
  80094e:	e8 9c ff ff ff       	call   8008ef <strlen>
  800953:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800956:	ff 75 0c             	pushl  0xc(%ebp)
  800959:	01 d8                	add    %ebx,%eax
  80095b:	50                   	push   %eax
  80095c:	e8 c5 ff ff ff       	call   800926 <strcpy>
	return dst;
}
  800961:	89 d8                	mov    %ebx,%eax
  800963:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800966:	c9                   	leave  
  800967:	c3                   	ret    

00800968 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 75 08             	mov    0x8(%ebp),%esi
  800970:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800973:	89 f3                	mov    %esi,%ebx
  800975:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800978:	89 f2                	mov    %esi,%edx
  80097a:	eb 0f                	jmp    80098b <strncpy+0x23>
		*dst++ = *src;
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	0f b6 01             	movzbl (%ecx),%eax
  800982:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800985:	80 39 01             	cmpb   $0x1,(%ecx)
  800988:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80098b:	39 da                	cmp    %ebx,%edx
  80098d:	75 ed                	jne    80097c <strncpy+0x14>
	}
	return ret;
}
  80098f:	89 f0                	mov    %esi,%eax
  800991:	5b                   	pop    %ebx
  800992:	5e                   	pop    %esi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 75 08             	mov    0x8(%ebp),%esi
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009a3:	89 f0                	mov    %esi,%eax
  8009a5:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a9:	85 c9                	test   %ecx,%ecx
  8009ab:	75 0b                	jne    8009b8 <strlcpy+0x23>
  8009ad:	eb 17                	jmp    8009c6 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009af:	83 c2 01             	add    $0x1,%edx
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009b8:	39 d8                	cmp    %ebx,%eax
  8009ba:	74 07                	je     8009c3 <strlcpy+0x2e>
  8009bc:	0f b6 0a             	movzbl (%edx),%ecx
  8009bf:	84 c9                	test   %cl,%cl
  8009c1:	75 ec                	jne    8009af <strlcpy+0x1a>
		*dst = '\0';
  8009c3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c6:	29 f0                	sub    %esi,%eax
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d5:	eb 06                	jmp    8009dd <strcmp+0x11>
		p++, q++;
  8009d7:	83 c1 01             	add    $0x1,%ecx
  8009da:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009dd:	0f b6 01             	movzbl (%ecx),%eax
  8009e0:	84 c0                	test   %al,%al
  8009e2:	74 04                	je     8009e8 <strcmp+0x1c>
  8009e4:	3a 02                	cmp    (%edx),%al
  8009e6:	74 ef                	je     8009d7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e8:	0f b6 c0             	movzbl %al,%eax
  8009eb:	0f b6 12             	movzbl (%edx),%edx
  8009ee:	29 d0                	sub    %edx,%eax
}
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fc:	89 c3                	mov    %eax,%ebx
  8009fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a01:	eb 06                	jmp    800a09 <strncmp+0x17>
		n--, p++, q++;
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a09:	39 d8                	cmp    %ebx,%eax
  800a0b:	74 16                	je     800a23 <strncmp+0x31>
  800a0d:	0f b6 08             	movzbl (%eax),%ecx
  800a10:	84 c9                	test   %cl,%cl
  800a12:	74 04                	je     800a18 <strncmp+0x26>
  800a14:	3a 0a                	cmp    (%edx),%cl
  800a16:	74 eb                	je     800a03 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a18:	0f b6 00             	movzbl (%eax),%eax
  800a1b:	0f b6 12             	movzbl (%edx),%edx
  800a1e:	29 d0                	sub    %edx,%eax
}
  800a20:	5b                   	pop    %ebx
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    
		return 0;
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
  800a28:	eb f6                	jmp    800a20 <strncmp+0x2e>

00800a2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a34:	0f b6 10             	movzbl (%eax),%edx
  800a37:	84 d2                	test   %dl,%dl
  800a39:	74 09                	je     800a44 <strchr+0x1a>
		if (*s == c)
  800a3b:	38 ca                	cmp    %cl,%dl
  800a3d:	74 0a                	je     800a49 <strchr+0x1f>
	for (; *s; s++)
  800a3f:	83 c0 01             	add    $0x1,%eax
  800a42:	eb f0                	jmp    800a34 <strchr+0xa>
			return (char *) s;
	return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a55:	eb 03                	jmp    800a5a <strfind+0xf>
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a5d:	38 ca                	cmp    %cl,%dl
  800a5f:	74 04                	je     800a65 <strfind+0x1a>
  800a61:	84 d2                	test   %dl,%dl
  800a63:	75 f2                	jne    800a57 <strfind+0xc>
			break;
	return (char *) s;
}
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a73:	85 c9                	test   %ecx,%ecx
  800a75:	74 13                	je     800a8a <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7d:	75 05                	jne    800a84 <memset+0x1d>
  800a7f:	f6 c1 03             	test   $0x3,%cl
  800a82:	74 0d                	je     800a91 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a87:	fc                   	cld    
  800a88:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8a:	89 f8                	mov    %edi,%eax
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    
		c &= 0xFF;
  800a91:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a95:	89 d3                	mov    %edx,%ebx
  800a97:	c1 e3 08             	shl    $0x8,%ebx
  800a9a:	89 d0                	mov    %edx,%eax
  800a9c:	c1 e0 18             	shl    $0x18,%eax
  800a9f:	89 d6                	mov    %edx,%esi
  800aa1:	c1 e6 10             	shl    $0x10,%esi
  800aa4:	09 f0                	or     %esi,%eax
  800aa6:	09 c2                	or     %eax,%edx
  800aa8:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800aaa:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800aad:	89 d0                	mov    %edx,%eax
  800aaf:	fc                   	cld    
  800ab0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab2:	eb d6                	jmp    800a8a <memset+0x23>

00800ab4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac2:	39 c6                	cmp    %eax,%esi
  800ac4:	73 35                	jae    800afb <memmove+0x47>
  800ac6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac9:	39 c2                	cmp    %eax,%edx
  800acb:	76 2e                	jbe    800afb <memmove+0x47>
		s += n;
		d += n;
  800acd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	09 fe                	or     %edi,%esi
  800ad4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ada:	74 0c                	je     800ae8 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800adc:	83 ef 01             	sub    $0x1,%edi
  800adf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae2:	fd                   	std    
  800ae3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae5:	fc                   	cld    
  800ae6:	eb 21                	jmp    800b09 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae8:	f6 c1 03             	test   $0x3,%cl
  800aeb:	75 ef                	jne    800adc <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aed:	83 ef 04             	sub    $0x4,%edi
  800af0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800af6:	fd                   	std    
  800af7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af9:	eb ea                	jmp    800ae5 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afb:	89 f2                	mov    %esi,%edx
  800afd:	09 c2                	or     %eax,%edx
  800aff:	f6 c2 03             	test   $0x3,%dl
  800b02:	74 09                	je     800b0d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0d:	f6 c1 03             	test   $0x3,%cl
  800b10:	75 f2                	jne    800b04 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b12:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b15:	89 c7                	mov    %eax,%edi
  800b17:	fc                   	cld    
  800b18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1a:	eb ed                	jmp    800b09 <memmove+0x55>

00800b1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b1f:	ff 75 10             	pushl  0x10(%ebp)
  800b22:	ff 75 0c             	pushl  0xc(%ebp)
  800b25:	ff 75 08             	pushl  0x8(%ebp)
  800b28:	e8 87 ff ff ff       	call   800ab4 <memmove>
}
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3a:	89 c6                	mov    %eax,%esi
  800b3c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3f:	39 f0                	cmp    %esi,%eax
  800b41:	74 1c                	je     800b5f <memcmp+0x30>
		if (*s1 != *s2)
  800b43:	0f b6 08             	movzbl (%eax),%ecx
  800b46:	0f b6 1a             	movzbl (%edx),%ebx
  800b49:	38 d9                	cmp    %bl,%cl
  800b4b:	75 08                	jne    800b55 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b4d:	83 c0 01             	add    $0x1,%eax
  800b50:	83 c2 01             	add    $0x1,%edx
  800b53:	eb ea                	jmp    800b3f <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b55:	0f b6 c1             	movzbl %cl,%eax
  800b58:	0f b6 db             	movzbl %bl,%ebx
  800b5b:	29 d8                	sub    %ebx,%eax
  800b5d:	eb 05                	jmp    800b64 <memcmp+0x35>
	}

	return 0;
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b76:	39 d0                	cmp    %edx,%eax
  800b78:	73 09                	jae    800b83 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b7a:	38 08                	cmp    %cl,(%eax)
  800b7c:	74 05                	je     800b83 <memfind+0x1b>
	for (; s < ends; s++)
  800b7e:	83 c0 01             	add    $0x1,%eax
  800b81:	eb f3                	jmp    800b76 <memfind+0xe>
			break;
	return (void *) s;
}
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b91:	eb 03                	jmp    800b96 <strtol+0x11>
		s++;
  800b93:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b96:	0f b6 01             	movzbl (%ecx),%eax
  800b99:	3c 20                	cmp    $0x20,%al
  800b9b:	74 f6                	je     800b93 <strtol+0xe>
  800b9d:	3c 09                	cmp    $0x9,%al
  800b9f:	74 f2                	je     800b93 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ba1:	3c 2b                	cmp    $0x2b,%al
  800ba3:	74 2e                	je     800bd3 <strtol+0x4e>
	int neg = 0;
  800ba5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800baa:	3c 2d                	cmp    $0x2d,%al
  800bac:	74 2f                	je     800bdd <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bae:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bb4:	75 05                	jne    800bbb <strtol+0x36>
  800bb6:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb9:	74 2c                	je     800be7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbb:	85 db                	test   %ebx,%ebx
  800bbd:	75 0a                	jne    800bc9 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bbf:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bc4:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc7:	74 28                	je     800bf1 <strtol+0x6c>
		base = 10;
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd1:	eb 50                	jmp    800c23 <strtol+0x9e>
		s++;
  800bd3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bd6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bdb:	eb d1                	jmp    800bae <strtol+0x29>
		s++, neg = 1;
  800bdd:	83 c1 01             	add    $0x1,%ecx
  800be0:	bf 01 00 00 00       	mov    $0x1,%edi
  800be5:	eb c7                	jmp    800bae <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800beb:	74 0e                	je     800bfb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bed:	85 db                	test   %ebx,%ebx
  800bef:	75 d8                	jne    800bc9 <strtol+0x44>
		s++, base = 8;
  800bf1:	83 c1 01             	add    $0x1,%ecx
  800bf4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bf9:	eb ce                	jmp    800bc9 <strtol+0x44>
		s += 2, base = 16;
  800bfb:	83 c1 02             	add    $0x2,%ecx
  800bfe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c03:	eb c4                	jmp    800bc9 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c05:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c08:	89 f3                	mov    %esi,%ebx
  800c0a:	80 fb 19             	cmp    $0x19,%bl
  800c0d:	77 29                	ja     800c38 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c0f:	0f be d2             	movsbl %dl,%edx
  800c12:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c15:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c18:	7d 30                	jge    800c4a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c1a:	83 c1 01             	add    $0x1,%ecx
  800c1d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c21:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c23:	0f b6 11             	movzbl (%ecx),%edx
  800c26:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c29:	89 f3                	mov    %esi,%ebx
  800c2b:	80 fb 09             	cmp    $0x9,%bl
  800c2e:	77 d5                	ja     800c05 <strtol+0x80>
			dig = *s - '0';
  800c30:	0f be d2             	movsbl %dl,%edx
  800c33:	83 ea 30             	sub    $0x30,%edx
  800c36:	eb dd                	jmp    800c15 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c38:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c3b:	89 f3                	mov    %esi,%ebx
  800c3d:	80 fb 19             	cmp    $0x19,%bl
  800c40:	77 08                	ja     800c4a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c42:	0f be d2             	movsbl %dl,%edx
  800c45:	83 ea 37             	sub    $0x37,%edx
  800c48:	eb cb                	jmp    800c15 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4e:	74 05                	je     800c55 <strtol+0xd0>
		*endptr = (char *) s;
  800c50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c53:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c55:	89 c2                	mov    %eax,%edx
  800c57:	f7 da                	neg    %edx
  800c59:	85 ff                	test   %edi,%edi
  800c5b:	0f 45 c2             	cmovne %edx,%eax
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c69:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	89 c3                	mov    %eax,%ebx
  800c76:	89 c7                	mov    %eax,%edi
  800c78:	89 c6                	mov    %eax,%esi
  800c7a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c87:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c91:	89 d1                	mov    %edx,%ecx
  800c93:	89 d3                	mov    %edx,%ebx
  800c95:	89 d7                	mov    %edx,%edi
  800c97:	89 d6                	mov    %edx,%esi
  800c99:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb6:	89 cb                	mov    %ecx,%ebx
  800cb8:	89 cf                	mov    %ecx,%edi
  800cba:	89 ce                	mov    %ecx,%esi
  800cbc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7f 08                	jg     800cca <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 03                	push   $0x3
  800cd0:	68 7f 27 80 00       	push   $0x80277f
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 9c 27 80 00       	push   $0x80279c
  800cdc:	e8 4b f5 ff ff       	call   80022c <_panic>

00800ce1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cec:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf1:	89 d1                	mov    %edx,%ecx
  800cf3:	89 d3                	mov    %edx,%ebx
  800cf5:	89 d7                	mov    %edx,%edi
  800cf7:	89 d6                	mov    %edx,%esi
  800cf9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_yield>:

void
sys_yield(void)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d06:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d10:	89 d1                	mov    %edx,%ecx
  800d12:	89 d3                	mov    %edx,%ebx
  800d14:	89 d7                	mov    %edx,%edi
  800d16:	89 d6                	mov    %edx,%esi
  800d18:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d28:	be 00 00 00 00       	mov    $0x0,%esi
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	b8 04 00 00 00       	mov    $0x4,%eax
  800d38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3b:	89 f7                	mov    %esi,%edi
  800d3d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7f 08                	jg     800d4b <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 04                	push   $0x4
  800d51:	68 7f 27 80 00       	push   $0x80277f
  800d56:	6a 23                	push   $0x23
  800d58:	68 9c 27 80 00       	push   $0x80279c
  800d5d:	e8 ca f4 ff ff       	call   80022c <_panic>

00800d62 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	b8 05 00 00 00       	mov    $0x5,%eax
  800d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7c:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7f 08                	jg     800d8d <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	50                   	push   %eax
  800d91:	6a 05                	push   $0x5
  800d93:	68 7f 27 80 00       	push   $0x80277f
  800d98:	6a 23                	push   $0x23
  800d9a:	68 9c 27 80 00       	push   $0x80279c
  800d9f:	e8 88 f4 ff ff       	call   80022c <_panic>

00800da4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbd:	89 df                	mov    %ebx,%edi
  800dbf:	89 de                	mov    %ebx,%esi
  800dc1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7f 08                	jg     800dcf <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dca:	5b                   	pop    %ebx
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	50                   	push   %eax
  800dd3:	6a 06                	push   $0x6
  800dd5:	68 7f 27 80 00       	push   $0x80277f
  800dda:	6a 23                	push   $0x23
  800ddc:	68 9c 27 80 00       	push   $0x80279c
  800de1:	e8 46 f4 ff ff       	call   80022c <_panic>

00800de6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
  800dec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800def:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfa:	b8 08 00 00 00       	mov    $0x8,%eax
  800dff:	89 df                	mov    %ebx,%edi
  800e01:	89 de                	mov    %ebx,%esi
  800e03:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e05:	85 c0                	test   %eax,%eax
  800e07:	7f 08                	jg     800e11 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	50                   	push   %eax
  800e15:	6a 08                	push   $0x8
  800e17:	68 7f 27 80 00       	push   $0x80277f
  800e1c:	6a 23                	push   $0x23
  800e1e:	68 9c 27 80 00       	push   $0x80279c
  800e23:	e8 04 f4 ff ff       	call   80022c <_panic>

00800e28 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e41:	89 df                	mov    %ebx,%edi
  800e43:	89 de                	mov    %ebx,%esi
  800e45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7f 08                	jg     800e53 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	50                   	push   %eax
  800e57:	6a 09                	push   $0x9
  800e59:	68 7f 27 80 00       	push   $0x80277f
  800e5e:	6a 23                	push   $0x23
  800e60:	68 9c 27 80 00       	push   $0x80279c
  800e65:	e8 c2 f3 ff ff       	call   80022c <_panic>

00800e6a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e78:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e83:	89 df                	mov    %ebx,%edi
  800e85:	89 de                	mov    %ebx,%esi
  800e87:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7f 08                	jg     800e95 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e95:	83 ec 0c             	sub    $0xc,%esp
  800e98:	50                   	push   %eax
  800e99:	6a 0a                	push   $0xa
  800e9b:	68 7f 27 80 00       	push   $0x80277f
  800ea0:	6a 23                	push   $0x23
  800ea2:	68 9c 27 80 00       	push   $0x80279c
  800ea7:	e8 80 f3 ff ff       	call   80022c <_panic>

00800eac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ebd:	be 00 00 00 00       	mov    $0x0,%esi
  800ec2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eca:	5b                   	pop    %ebx
  800ecb:	5e                   	pop    %esi
  800ecc:	5f                   	pop    %edi
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	57                   	push   %edi
  800ed3:	56                   	push   %esi
  800ed4:	53                   	push   %ebx
  800ed5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ed8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ee5:	89 cb                	mov    %ecx,%ebx
  800ee7:	89 cf                	mov    %ecx,%edi
  800ee9:	89 ce                	mov    %ecx,%esi
  800eeb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eed:	85 c0                	test   %eax,%eax
  800eef:	7f 08                	jg     800ef9 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef9:	83 ec 0c             	sub    $0xc,%esp
  800efc:	50                   	push   %eax
  800efd:	6a 0d                	push   $0xd
  800eff:	68 7f 27 80 00       	push   $0x80277f
  800f04:	6a 23                	push   $0x23
  800f06:	68 9c 27 80 00       	push   $0x80279c
  800f0b:	e8 1c f3 ff ff       	call   80022c <_panic>

00800f10 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	53                   	push   %ebx
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f1a:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f1c:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f20:	0f 84 9c 00 00 00    	je     800fc2 <pgfault+0xb2>
  800f26:	89 c2                	mov    %eax,%edx
  800f28:	c1 ea 16             	shr    $0x16,%edx
  800f2b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f32:	f6 c2 01             	test   $0x1,%dl
  800f35:	0f 84 87 00 00 00    	je     800fc2 <pgfault+0xb2>
  800f3b:	89 c2                	mov    %eax,%edx
  800f3d:	c1 ea 0c             	shr    $0xc,%edx
  800f40:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f47:	f6 c1 01             	test   $0x1,%cl
  800f4a:	74 76                	je     800fc2 <pgfault+0xb2>
  800f4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f53:	f6 c6 08             	test   $0x8,%dh
  800f56:	74 6a                	je     800fc2 <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  800f58:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f5d:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800f5f:	83 ec 04             	sub    $0x4,%esp
  800f62:	6a 07                	push   $0x7
  800f64:	68 00 f0 7f 00       	push   $0x7ff000
  800f69:	6a 00                	push   $0x0
  800f6b:	e8 af fd ff ff       	call   800d1f <sys_page_alloc>
  800f70:	83 c4 10             	add    $0x10,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 5f                	js     800fd6 <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  800f77:	83 ec 04             	sub    $0x4,%esp
  800f7a:	68 00 10 00 00       	push   $0x1000
  800f7f:	53                   	push   %ebx
  800f80:	68 00 f0 7f 00       	push   $0x7ff000
  800f85:	e8 92 fb ff ff       	call   800b1c <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800f8a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f91:	53                   	push   %ebx
  800f92:	6a 00                	push   $0x0
  800f94:	68 00 f0 7f 00       	push   $0x7ff000
  800f99:	6a 00                	push   $0x0
  800f9b:	e8 c2 fd ff ff       	call   800d62 <sys_page_map>
  800fa0:	83 c4 20             	add    $0x20,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	78 43                	js     800fea <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  800fa7:	83 ec 08             	sub    $0x8,%esp
  800faa:	68 00 f0 7f 00       	push   $0x7ff000
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 ee fd ff ff       	call   800da4 <sys_page_unmap>
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 41                	js     800ffe <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  800fbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc0:	c9                   	leave  
  800fc1:	c3                   	ret    
		panic("not copy-on-write");
  800fc2:	83 ec 04             	sub    $0x4,%esp
  800fc5:	68 aa 27 80 00       	push   $0x8027aa
  800fca:	6a 25                	push   $0x25
  800fcc:	68 bc 27 80 00       	push   $0x8027bc
  800fd1:	e8 56 f2 ff ff       	call   80022c <_panic>
		panic("sys_page_alloc");
  800fd6:	83 ec 04             	sub    $0x4,%esp
  800fd9:	68 c7 27 80 00       	push   $0x8027c7
  800fde:	6a 28                	push   $0x28
  800fe0:	68 bc 27 80 00       	push   $0x8027bc
  800fe5:	e8 42 f2 ff ff       	call   80022c <_panic>
		panic("sys_page_map");
  800fea:	83 ec 04             	sub    $0x4,%esp
  800fed:	68 d6 27 80 00       	push   $0x8027d6
  800ff2:	6a 2b                	push   $0x2b
  800ff4:	68 bc 27 80 00       	push   $0x8027bc
  800ff9:	e8 2e f2 ff ff       	call   80022c <_panic>
		panic("sys_page_unmap");
  800ffe:	83 ec 04             	sub    $0x4,%esp
  801001:	68 e3 27 80 00       	push   $0x8027e3
  801006:	6a 2d                	push   $0x2d
  801008:	68 bc 27 80 00       	push   $0x8027bc
  80100d:	e8 1a f2 ff ff       	call   80022c <_panic>

00801012 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
  801018:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80101b:	68 10 0f 80 00       	push   $0x800f10
  801020:	e8 da 0e 00 00       	call   801eff <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801025:	b8 07 00 00 00       	mov    $0x7,%eax
  80102a:	cd 30                	int    $0x30
  80102c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	74 12                	je     801048 <fork+0x36>
  801036:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  801038:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80103c:	78 26                	js     801064 <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  80103e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801043:	e9 94 00 00 00       	jmp    8010dc <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  801048:	e8 94 fc ff ff       	call   800ce1 <sys_getenvid>
  80104d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801052:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80105a:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  80105f:	e9 51 01 00 00       	jmp    8011b5 <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  801064:	ff 75 e4             	pushl  -0x1c(%ebp)
  801067:	68 f2 27 80 00       	push   $0x8027f2
  80106c:	6a 6e                	push   $0x6e
  80106e:	68 bc 27 80 00       	push   $0x8027bc
  801073:	e8 b4 f1 ff ff       	call   80022c <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	68 07 0e 00 00       	push   $0xe07
  801080:	56                   	push   %esi
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	6a 00                	push   $0x0
  801085:	e8 d8 fc ff ff       	call   800d62 <sys_page_map>
  80108a:	83 c4 20             	add    $0x20,%esp
  80108d:	eb 3b                	jmp    8010ca <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	68 05 08 00 00       	push   $0x805
  801097:	56                   	push   %esi
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	6a 00                	push   $0x0
  80109c:	e8 c1 fc ff ff       	call   800d62 <sys_page_map>
  8010a1:	83 c4 20             	add    $0x20,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	0f 88 a9 00 00 00    	js     801155 <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	68 05 08 00 00       	push   $0x805
  8010b4:	56                   	push   %esi
  8010b5:	6a 00                	push   $0x0
  8010b7:	56                   	push   %esi
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 a3 fc ff ff       	call   800d62 <sys_page_map>
  8010bf:	83 c4 20             	add    $0x20,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	0f 88 9d 00 00 00    	js     801167 <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8010ca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010d0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010d6:	0f 84 9d 00 00 00    	je     801179 <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8010dc:	89 d8                	mov    %ebx,%eax
  8010de:	c1 e8 16             	shr    $0x16,%eax
  8010e1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e8:	a8 01                	test   $0x1,%al
  8010ea:	74 de                	je     8010ca <fork+0xb8>
  8010ec:	89 d8                	mov    %ebx,%eax
  8010ee:	c1 e8 0c             	shr    $0xc,%eax
  8010f1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f8:	f6 c2 01             	test   $0x1,%dl
  8010fb:	74 cd                	je     8010ca <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  8010fd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801104:	f6 c2 04             	test   $0x4,%dl
  801107:	74 c1                	je     8010ca <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  801109:	89 c6                	mov    %eax,%esi
  80110b:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  80110e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801115:	f6 c6 04             	test   $0x4,%dh
  801118:	0f 85 5a ff ff ff    	jne    801078 <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  80111e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801125:	f6 c2 02             	test   $0x2,%dl
  801128:	0f 85 61 ff ff ff    	jne    80108f <fork+0x7d>
  80112e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801135:	f6 c4 08             	test   $0x8,%ah
  801138:	0f 85 51 ff ff ff    	jne    80108f <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  80113e:	83 ec 0c             	sub    $0xc,%esp
  801141:	6a 05                	push   $0x5
  801143:	56                   	push   %esi
  801144:	57                   	push   %edi
  801145:	56                   	push   %esi
  801146:	6a 00                	push   $0x0
  801148:	e8 15 fc ff ff       	call   800d62 <sys_page_map>
  80114d:	83 c4 20             	add    $0x20,%esp
  801150:	e9 75 ff ff ff       	jmp    8010ca <fork+0xb8>
            		panic("sys_page_map：%e", r);
  801155:	50                   	push   %eax
  801156:	68 02 28 80 00       	push   $0x802802
  80115b:	6a 47                	push   $0x47
  80115d:	68 bc 27 80 00       	push   $0x8027bc
  801162:	e8 c5 f0 ff ff       	call   80022c <_panic>
            		panic("sys_page_map：%e", r);
  801167:	50                   	push   %eax
  801168:	68 02 28 80 00       	push   $0x802802
  80116d:	6a 49                	push   $0x49
  80116f:	68 bc 27 80 00       	push   $0x8027bc
  801174:	e8 b3 f0 ff ff       	call   80022c <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801179:	83 ec 04             	sub    $0x4,%esp
  80117c:	6a 07                	push   $0x7
  80117e:	68 00 f0 bf ee       	push   $0xeebff000
  801183:	ff 75 e4             	pushl  -0x1c(%ebp)
  801186:	e8 94 fb ff ff       	call   800d1f <sys_page_alloc>
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	78 2e                	js     8011c0 <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801192:	83 ec 08             	sub    $0x8,%esp
  801195:	68 6e 1f 80 00       	push   $0x801f6e
  80119a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80119d:	57                   	push   %edi
  80119e:	e8 c7 fc ff ff       	call   800e6a <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8011a3:	83 c4 08             	add    $0x8,%esp
  8011a6:	6a 02                	push   $0x2
  8011a8:	57                   	push   %edi
  8011a9:	e8 38 fc ff ff       	call   800de6 <sys_env_set_status>
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 1f                	js     8011d4 <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  8011b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    
		panic("1");
  8011c0:	83 ec 04             	sub    $0x4,%esp
  8011c3:	68 14 28 80 00       	push   $0x802814
  8011c8:	6a 77                	push   $0x77
  8011ca:	68 bc 27 80 00       	push   $0x8027bc
  8011cf:	e8 58 f0 ff ff       	call   80022c <_panic>
		panic("sys_env_set_status");
  8011d4:	83 ec 04             	sub    $0x4,%esp
  8011d7:	68 16 28 80 00       	push   $0x802816
  8011dc:	6a 7c                	push   $0x7c
  8011de:	68 bc 27 80 00       	push   $0x8027bc
  8011e3:	e8 44 f0 ff ff       	call   80022c <_panic>

008011e8 <sfork>:

// Challenge!
int
sfork(void)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011ee:	68 29 28 80 00       	push   $0x802829
  8011f3:	68 86 00 00 00       	push   $0x86
  8011f8:	68 bc 27 80 00       	push   $0x8027bc
  8011fd:	e8 2a f0 ff ff       	call   80022c <_panic>

00801202 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801205:	8b 45 08             	mov    0x8(%ebp),%eax
  801208:	05 00 00 00 30       	add    $0x30000000,%eax
  80120d:	c1 e8 0c             	shr    $0xc,%eax
}
  801210:	5d                   	pop    %ebp
  801211:	c3                   	ret    

00801212 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801215:	8b 45 08             	mov    0x8(%ebp),%eax
  801218:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80121d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801222:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80122f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801234:	89 c2                	mov    %eax,%edx
  801236:	c1 ea 16             	shr    $0x16,%edx
  801239:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801240:	f6 c2 01             	test   $0x1,%dl
  801243:	74 2a                	je     80126f <fd_alloc+0x46>
  801245:	89 c2                	mov    %eax,%edx
  801247:	c1 ea 0c             	shr    $0xc,%edx
  80124a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801251:	f6 c2 01             	test   $0x1,%dl
  801254:	74 19                	je     80126f <fd_alloc+0x46>
  801256:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80125b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801260:	75 d2                	jne    801234 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801262:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801268:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80126d:	eb 07                	jmp    801276 <fd_alloc+0x4d>
			*fd_store = fd;
  80126f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    

00801278 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80127e:	83 f8 1f             	cmp    $0x1f,%eax
  801281:	77 36                	ja     8012b9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801283:	c1 e0 0c             	shl    $0xc,%eax
  801286:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80128b:	89 c2                	mov    %eax,%edx
  80128d:	c1 ea 16             	shr    $0x16,%edx
  801290:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801297:	f6 c2 01             	test   $0x1,%dl
  80129a:	74 24                	je     8012c0 <fd_lookup+0x48>
  80129c:	89 c2                	mov    %eax,%edx
  80129e:	c1 ea 0c             	shr    $0xc,%edx
  8012a1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a8:	f6 c2 01             	test   $0x1,%dl
  8012ab:	74 1a                	je     8012c7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b0:	89 02                	mov    %eax,(%edx)
	return 0;
  8012b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    
		return -E_INVAL;
  8012b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012be:	eb f7                	jmp    8012b7 <fd_lookup+0x3f>
		return -E_INVAL;
  8012c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c5:	eb f0                	jmp    8012b7 <fd_lookup+0x3f>
  8012c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cc:	eb e9                	jmp    8012b7 <fd_lookup+0x3f>

008012ce <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	83 ec 08             	sub    $0x8,%esp
  8012d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d7:	ba bc 28 80 00       	mov    $0x8028bc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012dc:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012e1:	39 08                	cmp    %ecx,(%eax)
  8012e3:	74 33                	je     801318 <dev_lookup+0x4a>
  8012e5:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012e8:	8b 02                	mov    (%edx),%eax
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	75 f3                	jne    8012e1 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012ee:	a1 20 44 80 00       	mov    0x804420,%eax
  8012f3:	8b 40 48             	mov    0x48(%eax),%eax
  8012f6:	83 ec 04             	sub    $0x4,%esp
  8012f9:	51                   	push   %ecx
  8012fa:	50                   	push   %eax
  8012fb:	68 40 28 80 00       	push   $0x802840
  801300:	e8 02 f0 ff ff       	call   800307 <cprintf>
	*dev = 0;
  801305:	8b 45 0c             	mov    0xc(%ebp),%eax
  801308:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801316:	c9                   	leave  
  801317:	c3                   	ret    
			*dev = devtab[i];
  801318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
  801322:	eb f2                	jmp    801316 <dev_lookup+0x48>

00801324 <fd_close>:
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	57                   	push   %edi
  801328:	56                   	push   %esi
  801329:	53                   	push   %ebx
  80132a:	83 ec 1c             	sub    $0x1c,%esp
  80132d:	8b 75 08             	mov    0x8(%ebp),%esi
  801330:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801333:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801336:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801337:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80133d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801340:	50                   	push   %eax
  801341:	e8 32 ff ff ff       	call   801278 <fd_lookup>
  801346:	89 c3                	mov    %eax,%ebx
  801348:	83 c4 08             	add    $0x8,%esp
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 05                	js     801354 <fd_close+0x30>
	    || fd != fd2)
  80134f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801352:	74 16                	je     80136a <fd_close+0x46>
		return (must_exist ? r : 0);
  801354:	89 f8                	mov    %edi,%eax
  801356:	84 c0                	test   %al,%al
  801358:	b8 00 00 00 00       	mov    $0x0,%eax
  80135d:	0f 44 d8             	cmove  %eax,%ebx
}
  801360:	89 d8                	mov    %ebx,%eax
  801362:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801365:	5b                   	pop    %ebx
  801366:	5e                   	pop    %esi
  801367:	5f                   	pop    %edi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801370:	50                   	push   %eax
  801371:	ff 36                	pushl  (%esi)
  801373:	e8 56 ff ff ff       	call   8012ce <dev_lookup>
  801378:	89 c3                	mov    %eax,%ebx
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 15                	js     801396 <fd_close+0x72>
		if (dev->dev_close)
  801381:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801384:	8b 40 10             	mov    0x10(%eax),%eax
  801387:	85 c0                	test   %eax,%eax
  801389:	74 1b                	je     8013a6 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80138b:	83 ec 0c             	sub    $0xc,%esp
  80138e:	56                   	push   %esi
  80138f:	ff d0                	call   *%eax
  801391:	89 c3                	mov    %eax,%ebx
  801393:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	56                   	push   %esi
  80139a:	6a 00                	push   $0x0
  80139c:	e8 03 fa ff ff       	call   800da4 <sys_page_unmap>
	return r;
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	eb ba                	jmp    801360 <fd_close+0x3c>
			r = 0;
  8013a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ab:	eb e9                	jmp    801396 <fd_close+0x72>

008013ad <close>:

int
close(int fdnum)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	ff 75 08             	pushl  0x8(%ebp)
  8013ba:	e8 b9 fe ff ff       	call   801278 <fd_lookup>
  8013bf:	83 c4 08             	add    $0x8,%esp
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 10                	js     8013d6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	6a 01                	push   $0x1
  8013cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ce:	e8 51 ff ff ff       	call   801324 <fd_close>
  8013d3:	83 c4 10             	add    $0x10,%esp
}
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <close_all>:

void
close_all(void)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013df:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013e4:	83 ec 0c             	sub    $0xc,%esp
  8013e7:	53                   	push   %ebx
  8013e8:	e8 c0 ff ff ff       	call   8013ad <close>
	for (i = 0; i < MAXFD; i++)
  8013ed:	83 c3 01             	add    $0x1,%ebx
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	83 fb 20             	cmp    $0x20,%ebx
  8013f6:	75 ec                	jne    8013e4 <close_all+0xc>
}
  8013f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fb:	c9                   	leave  
  8013fc:	c3                   	ret    

008013fd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	57                   	push   %edi
  801401:	56                   	push   %esi
  801402:	53                   	push   %ebx
  801403:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801406:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801409:	50                   	push   %eax
  80140a:	ff 75 08             	pushl  0x8(%ebp)
  80140d:	e8 66 fe ff ff       	call   801278 <fd_lookup>
  801412:	89 c3                	mov    %eax,%ebx
  801414:	83 c4 08             	add    $0x8,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	0f 88 81 00 00 00    	js     8014a0 <dup+0xa3>
		return r;
	close(newfdnum);
  80141f:	83 ec 0c             	sub    $0xc,%esp
  801422:	ff 75 0c             	pushl  0xc(%ebp)
  801425:	e8 83 ff ff ff       	call   8013ad <close>

	newfd = INDEX2FD(newfdnum);
  80142a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80142d:	c1 e6 0c             	shl    $0xc,%esi
  801430:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801436:	83 c4 04             	add    $0x4,%esp
  801439:	ff 75 e4             	pushl  -0x1c(%ebp)
  80143c:	e8 d1 fd ff ff       	call   801212 <fd2data>
  801441:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801443:	89 34 24             	mov    %esi,(%esp)
  801446:	e8 c7 fd ff ff       	call   801212 <fd2data>
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801450:	89 d8                	mov    %ebx,%eax
  801452:	c1 e8 16             	shr    $0x16,%eax
  801455:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80145c:	a8 01                	test   $0x1,%al
  80145e:	74 11                	je     801471 <dup+0x74>
  801460:	89 d8                	mov    %ebx,%eax
  801462:	c1 e8 0c             	shr    $0xc,%eax
  801465:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80146c:	f6 c2 01             	test   $0x1,%dl
  80146f:	75 39                	jne    8014aa <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801471:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801474:	89 d0                	mov    %edx,%eax
  801476:	c1 e8 0c             	shr    $0xc,%eax
  801479:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801480:	83 ec 0c             	sub    $0xc,%esp
  801483:	25 07 0e 00 00       	and    $0xe07,%eax
  801488:	50                   	push   %eax
  801489:	56                   	push   %esi
  80148a:	6a 00                	push   $0x0
  80148c:	52                   	push   %edx
  80148d:	6a 00                	push   $0x0
  80148f:	e8 ce f8 ff ff       	call   800d62 <sys_page_map>
  801494:	89 c3                	mov    %eax,%ebx
  801496:	83 c4 20             	add    $0x20,%esp
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 31                	js     8014ce <dup+0xd1>
		goto err;

	return newfdnum;
  80149d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014a0:	89 d8                	mov    %ebx,%eax
  8014a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a5:	5b                   	pop    %ebx
  8014a6:	5e                   	pop    %esi
  8014a7:	5f                   	pop    %edi
  8014a8:	5d                   	pop    %ebp
  8014a9:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b1:	83 ec 0c             	sub    $0xc,%esp
  8014b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b9:	50                   	push   %eax
  8014ba:	57                   	push   %edi
  8014bb:	6a 00                	push   $0x0
  8014bd:	53                   	push   %ebx
  8014be:	6a 00                	push   $0x0
  8014c0:	e8 9d f8 ff ff       	call   800d62 <sys_page_map>
  8014c5:	89 c3                	mov    %eax,%ebx
  8014c7:	83 c4 20             	add    $0x20,%esp
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	79 a3                	jns    801471 <dup+0x74>
	sys_page_unmap(0, newfd);
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	56                   	push   %esi
  8014d2:	6a 00                	push   $0x0
  8014d4:	e8 cb f8 ff ff       	call   800da4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014d9:	83 c4 08             	add    $0x8,%esp
  8014dc:	57                   	push   %edi
  8014dd:	6a 00                	push   $0x0
  8014df:	e8 c0 f8 ff ff       	call   800da4 <sys_page_unmap>
	return r;
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	eb b7                	jmp    8014a0 <dup+0xa3>

008014e9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 14             	sub    $0x14,%esp
  8014f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f6:	50                   	push   %eax
  8014f7:	53                   	push   %ebx
  8014f8:	e8 7b fd ff ff       	call   801278 <fd_lookup>
  8014fd:	83 c4 08             	add    $0x8,%esp
  801500:	85 c0                	test   %eax,%eax
  801502:	78 3f                	js     801543 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150e:	ff 30                	pushl  (%eax)
  801510:	e8 b9 fd ff ff       	call   8012ce <dev_lookup>
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 27                	js     801543 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80151c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80151f:	8b 42 08             	mov    0x8(%edx),%eax
  801522:	83 e0 03             	and    $0x3,%eax
  801525:	83 f8 01             	cmp    $0x1,%eax
  801528:	74 1e                	je     801548 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80152a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152d:	8b 40 08             	mov    0x8(%eax),%eax
  801530:	85 c0                	test   %eax,%eax
  801532:	74 35                	je     801569 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801534:	83 ec 04             	sub    $0x4,%esp
  801537:	ff 75 10             	pushl  0x10(%ebp)
  80153a:	ff 75 0c             	pushl  0xc(%ebp)
  80153d:	52                   	push   %edx
  80153e:	ff d0                	call   *%eax
  801540:	83 c4 10             	add    $0x10,%esp
}
  801543:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801546:	c9                   	leave  
  801547:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801548:	a1 20 44 80 00       	mov    0x804420,%eax
  80154d:	8b 40 48             	mov    0x48(%eax),%eax
  801550:	83 ec 04             	sub    $0x4,%esp
  801553:	53                   	push   %ebx
  801554:	50                   	push   %eax
  801555:	68 81 28 80 00       	push   $0x802881
  80155a:	e8 a8 ed ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801567:	eb da                	jmp    801543 <read+0x5a>
		return -E_NOT_SUPP;
  801569:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80156e:	eb d3                	jmp    801543 <read+0x5a>

00801570 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	57                   	push   %edi
  801574:	56                   	push   %esi
  801575:	53                   	push   %ebx
  801576:	83 ec 0c             	sub    $0xc,%esp
  801579:	8b 7d 08             	mov    0x8(%ebp),%edi
  80157c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801584:	39 f3                	cmp    %esi,%ebx
  801586:	73 25                	jae    8015ad <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801588:	83 ec 04             	sub    $0x4,%esp
  80158b:	89 f0                	mov    %esi,%eax
  80158d:	29 d8                	sub    %ebx,%eax
  80158f:	50                   	push   %eax
  801590:	89 d8                	mov    %ebx,%eax
  801592:	03 45 0c             	add    0xc(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	57                   	push   %edi
  801597:	e8 4d ff ff ff       	call   8014e9 <read>
		if (m < 0)
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 08                	js     8015ab <readn+0x3b>
			return m;
		if (m == 0)
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	74 06                	je     8015ad <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8015a7:	01 c3                	add    %eax,%ebx
  8015a9:	eb d9                	jmp    801584 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ab:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015ad:	89 d8                	mov    %ebx,%eax
  8015af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b2:	5b                   	pop    %ebx
  8015b3:	5e                   	pop    %esi
  8015b4:	5f                   	pop    %edi
  8015b5:	5d                   	pop    %ebp
  8015b6:	c3                   	ret    

008015b7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 14             	sub    $0x14,%esp
  8015be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	53                   	push   %ebx
  8015c6:	e8 ad fc ff ff       	call   801278 <fd_lookup>
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 3a                	js     80160c <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dc:	ff 30                	pushl  (%eax)
  8015de:	e8 eb fc ff ff       	call   8012ce <dev_lookup>
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 22                	js     80160c <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f1:	74 1e                	je     801611 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f6:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f9:	85 d2                	test   %edx,%edx
  8015fb:	74 35                	je     801632 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015fd:	83 ec 04             	sub    $0x4,%esp
  801600:	ff 75 10             	pushl  0x10(%ebp)
  801603:	ff 75 0c             	pushl  0xc(%ebp)
  801606:	50                   	push   %eax
  801607:	ff d2                	call   *%edx
  801609:	83 c4 10             	add    $0x10,%esp
}
  80160c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160f:	c9                   	leave  
  801610:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801611:	a1 20 44 80 00       	mov    0x804420,%eax
  801616:	8b 40 48             	mov    0x48(%eax),%eax
  801619:	83 ec 04             	sub    $0x4,%esp
  80161c:	53                   	push   %ebx
  80161d:	50                   	push   %eax
  80161e:	68 9d 28 80 00       	push   $0x80289d
  801623:	e8 df ec ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801630:	eb da                	jmp    80160c <write+0x55>
		return -E_NOT_SUPP;
  801632:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801637:	eb d3                	jmp    80160c <write+0x55>

00801639 <seek>:

int
seek(int fdnum, off_t offset)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80163f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801642:	50                   	push   %eax
  801643:	ff 75 08             	pushl  0x8(%ebp)
  801646:	e8 2d fc ff ff       	call   801278 <fd_lookup>
  80164b:	83 c4 08             	add    $0x8,%esp
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 0e                	js     801660 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801652:	8b 55 0c             	mov    0xc(%ebp),%edx
  801655:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801658:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80165b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801660:	c9                   	leave  
  801661:	c3                   	ret    

00801662 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	53                   	push   %ebx
  801666:	83 ec 14             	sub    $0x14,%esp
  801669:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166f:	50                   	push   %eax
  801670:	53                   	push   %ebx
  801671:	e8 02 fc ff ff       	call   801278 <fd_lookup>
  801676:	83 c4 08             	add    $0x8,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 37                	js     8016b4 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167d:	83 ec 08             	sub    $0x8,%esp
  801680:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801683:	50                   	push   %eax
  801684:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801687:	ff 30                	pushl  (%eax)
  801689:	e8 40 fc ff ff       	call   8012ce <dev_lookup>
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	85 c0                	test   %eax,%eax
  801693:	78 1f                	js     8016b4 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801695:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801698:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80169c:	74 1b                	je     8016b9 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80169e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a1:	8b 52 18             	mov    0x18(%edx),%edx
  8016a4:	85 d2                	test   %edx,%edx
  8016a6:	74 32                	je     8016da <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	ff 75 0c             	pushl  0xc(%ebp)
  8016ae:	50                   	push   %eax
  8016af:	ff d2                	call   *%edx
  8016b1:	83 c4 10             	add    $0x10,%esp
}
  8016b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b7:	c9                   	leave  
  8016b8:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016b9:	a1 20 44 80 00       	mov    0x804420,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016be:	8b 40 48             	mov    0x48(%eax),%eax
  8016c1:	83 ec 04             	sub    $0x4,%esp
  8016c4:	53                   	push   %ebx
  8016c5:	50                   	push   %eax
  8016c6:	68 60 28 80 00       	push   $0x802860
  8016cb:	e8 37 ec ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d8:	eb da                	jmp    8016b4 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8016da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016df:	eb d3                	jmp    8016b4 <ftruncate+0x52>

008016e1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	53                   	push   %ebx
  8016e5:	83 ec 14             	sub    $0x14,%esp
  8016e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ee:	50                   	push   %eax
  8016ef:	ff 75 08             	pushl  0x8(%ebp)
  8016f2:	e8 81 fb ff ff       	call   801278 <fd_lookup>
  8016f7:	83 c4 08             	add    $0x8,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 4b                	js     801749 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fe:	83 ec 08             	sub    $0x8,%esp
  801701:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801704:	50                   	push   %eax
  801705:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801708:	ff 30                	pushl  (%eax)
  80170a:	e8 bf fb ff ff       	call   8012ce <dev_lookup>
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	85 c0                	test   %eax,%eax
  801714:	78 33                	js     801749 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801716:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801719:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80171d:	74 2f                	je     80174e <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80171f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801722:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801729:	00 00 00 
	stat->st_isdir = 0;
  80172c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801733:	00 00 00 
	stat->st_dev = dev;
  801736:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80173c:	83 ec 08             	sub    $0x8,%esp
  80173f:	53                   	push   %ebx
  801740:	ff 75 f0             	pushl  -0x10(%ebp)
  801743:	ff 50 14             	call   *0x14(%eax)
  801746:	83 c4 10             	add    $0x10,%esp
}
  801749:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    
		return -E_NOT_SUPP;
  80174e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801753:	eb f4                	jmp    801749 <fstat+0x68>

00801755 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	56                   	push   %esi
  801759:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80175a:	83 ec 08             	sub    $0x8,%esp
  80175d:	6a 00                	push   $0x0
  80175f:	ff 75 08             	pushl  0x8(%ebp)
  801762:	e8 da 01 00 00       	call   801941 <open>
  801767:	89 c3                	mov    %eax,%ebx
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 1b                	js     80178b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801770:	83 ec 08             	sub    $0x8,%esp
  801773:	ff 75 0c             	pushl  0xc(%ebp)
  801776:	50                   	push   %eax
  801777:	e8 65 ff ff ff       	call   8016e1 <fstat>
  80177c:	89 c6                	mov    %eax,%esi
	close(fd);
  80177e:	89 1c 24             	mov    %ebx,(%esp)
  801781:	e8 27 fc ff ff       	call   8013ad <close>
	return r;
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	89 f3                	mov    %esi,%ebx
}
  80178b:	89 d8                	mov    %ebx,%eax
  80178d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	56                   	push   %esi
  801798:	53                   	push   %ebx
  801799:	89 c6                	mov    %eax,%esi
  80179b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80179d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017a4:	74 27                	je     8017cd <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a6:	6a 07                	push   $0x7
  8017a8:	68 00 50 80 00       	push   $0x805000
  8017ad:	56                   	push   %esi
  8017ae:	ff 35 00 40 80 00    	pushl  0x804000
  8017b4:	e8 42 08 00 00       	call   801ffb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b9:	83 c4 0c             	add    $0xc,%esp
  8017bc:	6a 00                	push   $0x0
  8017be:	53                   	push   %ebx
  8017bf:	6a 00                	push   $0x0
  8017c1:	e8 ce 07 00 00       	call   801f94 <ipc_recv>
}
  8017c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c9:	5b                   	pop    %ebx
  8017ca:	5e                   	pop    %esi
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017cd:	83 ec 0c             	sub    $0xc,%esp
  8017d0:	6a 01                	push   $0x1
  8017d2:	e8 78 08 00 00       	call   80204f <ipc_find_env>
  8017d7:	a3 00 40 80 00       	mov    %eax,0x804000
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	eb c5                	jmp    8017a6 <fsipc+0x12>

008017e1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ed:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ff:	b8 02 00 00 00       	mov    $0x2,%eax
  801804:	e8 8b ff ff ff       	call   801794 <fsipc>
}
  801809:	c9                   	leave  
  80180a:	c3                   	ret    

0080180b <devfile_flush>:
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	8b 40 0c             	mov    0xc(%eax),%eax
  801817:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80181c:	ba 00 00 00 00       	mov    $0x0,%edx
  801821:	b8 06 00 00 00       	mov    $0x6,%eax
  801826:	e8 69 ff ff ff       	call   801794 <fsipc>
}
  80182b:	c9                   	leave  
  80182c:	c3                   	ret    

0080182d <devfile_stat>:
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	53                   	push   %ebx
  801831:	83 ec 04             	sub    $0x4,%esp
  801834:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801837:	8b 45 08             	mov    0x8(%ebp),%eax
  80183a:	8b 40 0c             	mov    0xc(%eax),%eax
  80183d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801842:	ba 00 00 00 00       	mov    $0x0,%edx
  801847:	b8 05 00 00 00       	mov    $0x5,%eax
  80184c:	e8 43 ff ff ff       	call   801794 <fsipc>
  801851:	85 c0                	test   %eax,%eax
  801853:	78 2c                	js     801881 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	68 00 50 80 00       	push   $0x805000
  80185d:	53                   	push   %ebx
  80185e:	e8 c3 f0 ff ff       	call   800926 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801863:	a1 80 50 80 00       	mov    0x805080,%eax
  801868:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80186e:	a1 84 50 80 00       	mov    0x805084,%eax
  801873:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <devfile_write>:
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	83 ec 0c             	sub    $0xc,%esp
  80188c:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80188f:	8b 55 08             	mov    0x8(%ebp),%edx
  801892:	8b 52 0c             	mov    0xc(%edx),%edx
  801895:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  80189b:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8018a0:	50                   	push   %eax
  8018a1:	ff 75 0c             	pushl  0xc(%ebp)
  8018a4:	68 08 50 80 00       	push   $0x805008
  8018a9:	e8 06 f2 ff ff       	call   800ab4 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  8018ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b8:	e8 d7 fe ff ff       	call   801794 <fsipc>
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <devfile_read>:
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	56                   	push   %esi
  8018c3:	53                   	push   %ebx
  8018c4:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e2:	e8 ad fe ff ff       	call   801794 <fsipc>
  8018e7:	89 c3                	mov    %eax,%ebx
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	78 1f                	js     80190c <devfile_read+0x4d>
	assert(r <= n);
  8018ed:	39 f0                	cmp    %esi,%eax
  8018ef:	77 24                	ja     801915 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018f1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f6:	7f 33                	jg     80192b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018f8:	83 ec 04             	sub    $0x4,%esp
  8018fb:	50                   	push   %eax
  8018fc:	68 00 50 80 00       	push   $0x805000
  801901:	ff 75 0c             	pushl  0xc(%ebp)
  801904:	e8 ab f1 ff ff       	call   800ab4 <memmove>
	return r;
  801909:	83 c4 10             	add    $0x10,%esp
}
  80190c:	89 d8                	mov    %ebx,%eax
  80190e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801911:	5b                   	pop    %ebx
  801912:	5e                   	pop    %esi
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    
	assert(r <= n);
  801915:	68 cc 28 80 00       	push   $0x8028cc
  80191a:	68 d3 28 80 00       	push   $0x8028d3
  80191f:	6a 7c                	push   $0x7c
  801921:	68 e8 28 80 00       	push   $0x8028e8
  801926:	e8 01 e9 ff ff       	call   80022c <_panic>
	assert(r <= PGSIZE);
  80192b:	68 f3 28 80 00       	push   $0x8028f3
  801930:	68 d3 28 80 00       	push   $0x8028d3
  801935:	6a 7d                	push   $0x7d
  801937:	68 e8 28 80 00       	push   $0x8028e8
  80193c:	e8 eb e8 ff ff       	call   80022c <_panic>

00801941 <open>:
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	56                   	push   %esi
  801945:	53                   	push   %ebx
  801946:	83 ec 1c             	sub    $0x1c,%esp
  801949:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80194c:	56                   	push   %esi
  80194d:	e8 9d ef ff ff       	call   8008ef <strlen>
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80195a:	7f 6c                	jg     8019c8 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80195c:	83 ec 0c             	sub    $0xc,%esp
  80195f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801962:	50                   	push   %eax
  801963:	e8 c1 f8 ff ff       	call   801229 <fd_alloc>
  801968:	89 c3                	mov    %eax,%ebx
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	85 c0                	test   %eax,%eax
  80196f:	78 3c                	js     8019ad <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801971:	83 ec 08             	sub    $0x8,%esp
  801974:	56                   	push   %esi
  801975:	68 00 50 80 00       	push   $0x805000
  80197a:	e8 a7 ef ff ff       	call   800926 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80197f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801982:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801987:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80198a:	b8 01 00 00 00       	mov    $0x1,%eax
  80198f:	e8 00 fe ff ff       	call   801794 <fsipc>
  801994:	89 c3                	mov    %eax,%ebx
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	85 c0                	test   %eax,%eax
  80199b:	78 19                	js     8019b6 <open+0x75>
	return fd2num(fd);
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a3:	e8 5a f8 ff ff       	call   801202 <fd2num>
  8019a8:	89 c3                	mov    %eax,%ebx
  8019aa:	83 c4 10             	add    $0x10,%esp
}
  8019ad:	89 d8                	mov    %ebx,%eax
  8019af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b2:	5b                   	pop    %ebx
  8019b3:	5e                   	pop    %esi
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    
		fd_close(fd, 0);
  8019b6:	83 ec 08             	sub    $0x8,%esp
  8019b9:	6a 00                	push   $0x0
  8019bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8019be:	e8 61 f9 ff ff       	call   801324 <fd_close>
		return r;
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	eb e5                	jmp    8019ad <open+0x6c>
		return -E_BAD_PATH;
  8019c8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019cd:	eb de                	jmp    8019ad <open+0x6c>

008019cf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019da:	b8 08 00 00 00       	mov    $0x8,%eax
  8019df:	e8 b0 fd ff ff       	call   801794 <fsipc>
}
  8019e4:	c9                   	leave  
  8019e5:	c3                   	ret    

008019e6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	56                   	push   %esi
  8019ea:	53                   	push   %ebx
  8019eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ee:	83 ec 0c             	sub    $0xc,%esp
  8019f1:	ff 75 08             	pushl  0x8(%ebp)
  8019f4:	e8 19 f8 ff ff       	call   801212 <fd2data>
  8019f9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019fb:	83 c4 08             	add    $0x8,%esp
  8019fe:	68 ff 28 80 00       	push   $0x8028ff
  801a03:	53                   	push   %ebx
  801a04:	e8 1d ef ff ff       	call   800926 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a09:	8b 46 04             	mov    0x4(%esi),%eax
  801a0c:	2b 06                	sub    (%esi),%eax
  801a0e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a14:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a1b:	00 00 00 
	stat->st_dev = &devpipe;
  801a1e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a25:	30 80 00 
	return 0;
}
  801a28:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a30:	5b                   	pop    %ebx
  801a31:	5e                   	pop    %esi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	53                   	push   %ebx
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a3e:	53                   	push   %ebx
  801a3f:	6a 00                	push   $0x0
  801a41:	e8 5e f3 ff ff       	call   800da4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a46:	89 1c 24             	mov    %ebx,(%esp)
  801a49:	e8 c4 f7 ff ff       	call   801212 <fd2data>
  801a4e:	83 c4 08             	add    $0x8,%esp
  801a51:	50                   	push   %eax
  801a52:	6a 00                	push   $0x0
  801a54:	e8 4b f3 ff ff       	call   800da4 <sys_page_unmap>
}
  801a59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <_pipeisclosed>:
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	57                   	push   %edi
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	83 ec 1c             	sub    $0x1c,%esp
  801a67:	89 c7                	mov    %eax,%edi
  801a69:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a6b:	a1 20 44 80 00       	mov    0x804420,%eax
  801a70:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	57                   	push   %edi
  801a77:	e8 0c 06 00 00       	call   802088 <pageref>
  801a7c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a7f:	89 34 24             	mov    %esi,(%esp)
  801a82:	e8 01 06 00 00       	call   802088 <pageref>
		nn = thisenv->env_runs;
  801a87:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a8d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	39 cb                	cmp    %ecx,%ebx
  801a95:	74 1b                	je     801ab2 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a97:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a9a:	75 cf                	jne    801a6b <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a9c:	8b 42 58             	mov    0x58(%edx),%eax
  801a9f:	6a 01                	push   $0x1
  801aa1:	50                   	push   %eax
  801aa2:	53                   	push   %ebx
  801aa3:	68 06 29 80 00       	push   $0x802906
  801aa8:	e8 5a e8 ff ff       	call   800307 <cprintf>
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	eb b9                	jmp    801a6b <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ab2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ab5:	0f 94 c0             	sete   %al
  801ab8:	0f b6 c0             	movzbl %al,%eax
}
  801abb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5e                   	pop    %esi
  801ac0:	5f                   	pop    %edi
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <devpipe_write>:
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	57                   	push   %edi
  801ac7:	56                   	push   %esi
  801ac8:	53                   	push   %ebx
  801ac9:	83 ec 28             	sub    $0x28,%esp
  801acc:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801acf:	56                   	push   %esi
  801ad0:	e8 3d f7 ff ff       	call   801212 <fd2data>
  801ad5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	bf 00 00 00 00       	mov    $0x0,%edi
  801adf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ae2:	74 4f                	je     801b33 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae4:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae7:	8b 0b                	mov    (%ebx),%ecx
  801ae9:	8d 51 20             	lea    0x20(%ecx),%edx
  801aec:	39 d0                	cmp    %edx,%eax
  801aee:	72 14                	jb     801b04 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801af0:	89 da                	mov    %ebx,%edx
  801af2:	89 f0                	mov    %esi,%eax
  801af4:	e8 65 ff ff ff       	call   801a5e <_pipeisclosed>
  801af9:	85 c0                	test   %eax,%eax
  801afb:	75 3a                	jne    801b37 <devpipe_write+0x74>
			sys_yield();
  801afd:	e8 fe f1 ff ff       	call   800d00 <sys_yield>
  801b02:	eb e0                	jmp    801ae4 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b07:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b0b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b0e:	89 c2                	mov    %eax,%edx
  801b10:	c1 fa 1f             	sar    $0x1f,%edx
  801b13:	89 d1                	mov    %edx,%ecx
  801b15:	c1 e9 1b             	shr    $0x1b,%ecx
  801b18:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b1b:	83 e2 1f             	and    $0x1f,%edx
  801b1e:	29 ca                	sub    %ecx,%edx
  801b20:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b24:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b28:	83 c0 01             	add    $0x1,%eax
  801b2b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b2e:	83 c7 01             	add    $0x1,%edi
  801b31:	eb ac                	jmp    801adf <devpipe_write+0x1c>
	return i;
  801b33:	89 f8                	mov    %edi,%eax
  801b35:	eb 05                	jmp    801b3c <devpipe_write+0x79>
				return 0;
  801b37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5f                   	pop    %edi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <devpipe_read>:
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	57                   	push   %edi
  801b48:	56                   	push   %esi
  801b49:	53                   	push   %ebx
  801b4a:	83 ec 18             	sub    $0x18,%esp
  801b4d:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b50:	57                   	push   %edi
  801b51:	e8 bc f6 ff ff       	call   801212 <fd2data>
  801b56:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	be 00 00 00 00       	mov    $0x0,%esi
  801b60:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b63:	74 47                	je     801bac <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801b65:	8b 03                	mov    (%ebx),%eax
  801b67:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b6a:	75 22                	jne    801b8e <devpipe_read+0x4a>
			if (i > 0)
  801b6c:	85 f6                	test   %esi,%esi
  801b6e:	75 14                	jne    801b84 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801b70:	89 da                	mov    %ebx,%edx
  801b72:	89 f8                	mov    %edi,%eax
  801b74:	e8 e5 fe ff ff       	call   801a5e <_pipeisclosed>
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	75 33                	jne    801bb0 <devpipe_read+0x6c>
			sys_yield();
  801b7d:	e8 7e f1 ff ff       	call   800d00 <sys_yield>
  801b82:	eb e1                	jmp    801b65 <devpipe_read+0x21>
				return i;
  801b84:	89 f0                	mov    %esi,%eax
}
  801b86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5f                   	pop    %edi
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b8e:	99                   	cltd   
  801b8f:	c1 ea 1b             	shr    $0x1b,%edx
  801b92:	01 d0                	add    %edx,%eax
  801b94:	83 e0 1f             	and    $0x1f,%eax
  801b97:	29 d0                	sub    %edx,%eax
  801b99:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ba4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ba7:	83 c6 01             	add    $0x1,%esi
  801baa:	eb b4                	jmp    801b60 <devpipe_read+0x1c>
	return i;
  801bac:	89 f0                	mov    %esi,%eax
  801bae:	eb d6                	jmp    801b86 <devpipe_read+0x42>
				return 0;
  801bb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb5:	eb cf                	jmp    801b86 <devpipe_read+0x42>

00801bb7 <pipe>:
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	56                   	push   %esi
  801bbb:	53                   	push   %ebx
  801bbc:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc2:	50                   	push   %eax
  801bc3:	e8 61 f6 ff ff       	call   801229 <fd_alloc>
  801bc8:	89 c3                	mov    %eax,%ebx
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	78 5b                	js     801c2c <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd1:	83 ec 04             	sub    $0x4,%esp
  801bd4:	68 07 04 00 00       	push   $0x407
  801bd9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bdc:	6a 00                	push   $0x0
  801bde:	e8 3c f1 ff ff       	call   800d1f <sys_page_alloc>
  801be3:	89 c3                	mov    %eax,%ebx
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	85 c0                	test   %eax,%eax
  801bea:	78 40                	js     801c2c <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801bec:	83 ec 0c             	sub    $0xc,%esp
  801bef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf2:	50                   	push   %eax
  801bf3:	e8 31 f6 ff ff       	call   801229 <fd_alloc>
  801bf8:	89 c3                	mov    %eax,%ebx
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	78 1b                	js     801c1c <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c01:	83 ec 04             	sub    $0x4,%esp
  801c04:	68 07 04 00 00       	push   $0x407
  801c09:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0c:	6a 00                	push   $0x0
  801c0e:	e8 0c f1 ff ff       	call   800d1f <sys_page_alloc>
  801c13:	89 c3                	mov    %eax,%ebx
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	79 19                	jns    801c35 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801c1c:	83 ec 08             	sub    $0x8,%esp
  801c1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c22:	6a 00                	push   $0x0
  801c24:	e8 7b f1 ff ff       	call   800da4 <sys_page_unmap>
  801c29:	83 c4 10             	add    $0x10,%esp
}
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    
	va = fd2data(fd0);
  801c35:	83 ec 0c             	sub    $0xc,%esp
  801c38:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3b:	e8 d2 f5 ff ff       	call   801212 <fd2data>
  801c40:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c42:	83 c4 0c             	add    $0xc,%esp
  801c45:	68 07 04 00 00       	push   $0x407
  801c4a:	50                   	push   %eax
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 cd f0 ff ff       	call   800d1f <sys_page_alloc>
  801c52:	89 c3                	mov    %eax,%ebx
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	85 c0                	test   %eax,%eax
  801c59:	0f 88 8c 00 00 00    	js     801ceb <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5f:	83 ec 0c             	sub    $0xc,%esp
  801c62:	ff 75 f0             	pushl  -0x10(%ebp)
  801c65:	e8 a8 f5 ff ff       	call   801212 <fd2data>
  801c6a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c71:	50                   	push   %eax
  801c72:	6a 00                	push   $0x0
  801c74:	56                   	push   %esi
  801c75:	6a 00                	push   $0x0
  801c77:	e8 e6 f0 ff ff       	call   800d62 <sys_page_map>
  801c7c:	89 c3                	mov    %eax,%ebx
  801c7e:	83 c4 20             	add    $0x20,%esp
  801c81:	85 c0                	test   %eax,%eax
  801c83:	78 58                	js     801cdd <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c8e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c93:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c9d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801caf:	83 ec 0c             	sub    $0xc,%esp
  801cb2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb5:	e8 48 f5 ff ff       	call   801202 <fd2num>
  801cba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cbf:	83 c4 04             	add    $0x4,%esp
  801cc2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc5:	e8 38 f5 ff ff       	call   801202 <fd2num>
  801cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cd0:	83 c4 10             	add    $0x10,%esp
  801cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd8:	e9 4f ff ff ff       	jmp    801c2c <pipe+0x75>
	sys_page_unmap(0, va);
  801cdd:	83 ec 08             	sub    $0x8,%esp
  801ce0:	56                   	push   %esi
  801ce1:	6a 00                	push   $0x0
  801ce3:	e8 bc f0 ff ff       	call   800da4 <sys_page_unmap>
  801ce8:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ceb:	83 ec 08             	sub    $0x8,%esp
  801cee:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf1:	6a 00                	push   $0x0
  801cf3:	e8 ac f0 ff ff       	call   800da4 <sys_page_unmap>
  801cf8:	83 c4 10             	add    $0x10,%esp
  801cfb:	e9 1c ff ff ff       	jmp    801c1c <pipe+0x65>

00801d00 <pipeisclosed>:
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d09:	50                   	push   %eax
  801d0a:	ff 75 08             	pushl  0x8(%ebp)
  801d0d:	e8 66 f5 ff ff       	call   801278 <fd_lookup>
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	85 c0                	test   %eax,%eax
  801d17:	78 18                	js     801d31 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d19:	83 ec 0c             	sub    $0xc,%esp
  801d1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1f:	e8 ee f4 ff ff       	call   801212 <fd2data>
	return _pipeisclosed(fd, p);
  801d24:	89 c2                	mov    %eax,%edx
  801d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d29:	e8 30 fd ff ff       	call   801a5e <_pipeisclosed>
  801d2e:	83 c4 10             	add    $0x10,%esp
}
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    

00801d33 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	56                   	push   %esi
  801d37:	53                   	push   %ebx
  801d38:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d3b:	85 f6                	test   %esi,%esi
  801d3d:	74 13                	je     801d52 <wait+0x1f>
	e = &envs[ENVX(envid)];
  801d3f:	89 f3                	mov    %esi,%ebx
  801d41:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d47:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d4a:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d50:	eb 1b                	jmp    801d6d <wait+0x3a>
	assert(envid != 0);
  801d52:	68 1e 29 80 00       	push   $0x80291e
  801d57:	68 d3 28 80 00       	push   $0x8028d3
  801d5c:	6a 09                	push   $0x9
  801d5e:	68 29 29 80 00       	push   $0x802929
  801d63:	e8 c4 e4 ff ff       	call   80022c <_panic>
		sys_yield();
  801d68:	e8 93 ef ff ff       	call   800d00 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d6d:	8b 43 48             	mov    0x48(%ebx),%eax
  801d70:	39 f0                	cmp    %esi,%eax
  801d72:	75 07                	jne    801d7b <wait+0x48>
  801d74:	8b 43 54             	mov    0x54(%ebx),%eax
  801d77:	85 c0                	test   %eax,%eax
  801d79:	75 ed                	jne    801d68 <wait+0x35>
}
  801d7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d7e:	5b                   	pop    %ebx
  801d7f:	5e                   	pop    %esi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    

00801d82 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d85:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d92:	68 34 29 80 00       	push   $0x802934
  801d97:	ff 75 0c             	pushl  0xc(%ebp)
  801d9a:	e8 87 eb ff ff       	call   800926 <strcpy>
	return 0;
}
  801d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    

00801da6 <devcons_write>:
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	57                   	push   %edi
  801daa:	56                   	push   %esi
  801dab:	53                   	push   %ebx
  801dac:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801db2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801db7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801dbd:	eb 2f                	jmp    801dee <devcons_write+0x48>
		m = n - tot;
  801dbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dc2:	29 f3                	sub    %esi,%ebx
  801dc4:	83 fb 7f             	cmp    $0x7f,%ebx
  801dc7:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801dcc:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801dcf:	83 ec 04             	sub    $0x4,%esp
  801dd2:	53                   	push   %ebx
  801dd3:	89 f0                	mov    %esi,%eax
  801dd5:	03 45 0c             	add    0xc(%ebp),%eax
  801dd8:	50                   	push   %eax
  801dd9:	57                   	push   %edi
  801dda:	e8 d5 ec ff ff       	call   800ab4 <memmove>
		sys_cputs(buf, m);
  801ddf:	83 c4 08             	add    $0x8,%esp
  801de2:	53                   	push   %ebx
  801de3:	57                   	push   %edi
  801de4:	e8 7a ee ff ff       	call   800c63 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801de9:	01 de                	add    %ebx,%esi
  801deb:	83 c4 10             	add    $0x10,%esp
  801dee:	3b 75 10             	cmp    0x10(%ebp),%esi
  801df1:	72 cc                	jb     801dbf <devcons_write+0x19>
}
  801df3:	89 f0                	mov    %esi,%eax
  801df5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    

00801dfd <devcons_read>:
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	83 ec 08             	sub    $0x8,%esp
  801e03:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e0c:	75 07                	jne    801e15 <devcons_read+0x18>
}
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    
		sys_yield();
  801e10:	e8 eb ee ff ff       	call   800d00 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e15:	e8 67 ee ff ff       	call   800c81 <sys_cgetc>
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	74 f2                	je     801e10 <devcons_read+0x13>
	if (c < 0)
  801e1e:	85 c0                	test   %eax,%eax
  801e20:	78 ec                	js     801e0e <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801e22:	83 f8 04             	cmp    $0x4,%eax
  801e25:	74 0c                	je     801e33 <devcons_read+0x36>
	*(char*)vbuf = c;
  801e27:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2a:	88 02                	mov    %al,(%edx)
	return 1;
  801e2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e31:	eb db                	jmp    801e0e <devcons_read+0x11>
		return 0;
  801e33:	b8 00 00 00 00       	mov    $0x0,%eax
  801e38:	eb d4                	jmp    801e0e <devcons_read+0x11>

00801e3a <cputchar>:
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e40:	8b 45 08             	mov    0x8(%ebp),%eax
  801e43:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e46:	6a 01                	push   $0x1
  801e48:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e4b:	50                   	push   %eax
  801e4c:	e8 12 ee ff ff       	call   800c63 <sys_cputs>
}
  801e51:	83 c4 10             	add    $0x10,%esp
  801e54:	c9                   	leave  
  801e55:	c3                   	ret    

00801e56 <getchar>:
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e5c:	6a 01                	push   $0x1
  801e5e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e61:	50                   	push   %eax
  801e62:	6a 00                	push   $0x0
  801e64:	e8 80 f6 ff ff       	call   8014e9 <read>
	if (r < 0)
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	78 08                	js     801e78 <getchar+0x22>
	if (r < 1)
  801e70:	85 c0                	test   %eax,%eax
  801e72:	7e 06                	jle    801e7a <getchar+0x24>
	return c;
  801e74:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e78:	c9                   	leave  
  801e79:	c3                   	ret    
		return -E_EOF;
  801e7a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e7f:	eb f7                	jmp    801e78 <getchar+0x22>

00801e81 <iscons>:
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8a:	50                   	push   %eax
  801e8b:	ff 75 08             	pushl  0x8(%ebp)
  801e8e:	e8 e5 f3 ff ff       	call   801278 <fd_lookup>
  801e93:	83 c4 10             	add    $0x10,%esp
  801e96:	85 c0                	test   %eax,%eax
  801e98:	78 11                	js     801eab <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea3:	39 10                	cmp    %edx,(%eax)
  801ea5:	0f 94 c0             	sete   %al
  801ea8:	0f b6 c0             	movzbl %al,%eax
}
  801eab:	c9                   	leave  
  801eac:	c3                   	ret    

00801ead <opencons>:
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801eb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb6:	50                   	push   %eax
  801eb7:	e8 6d f3 ff ff       	call   801229 <fd_alloc>
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	78 3a                	js     801efd <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec3:	83 ec 04             	sub    $0x4,%esp
  801ec6:	68 07 04 00 00       	push   $0x407
  801ecb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ece:	6a 00                	push   $0x0
  801ed0:	e8 4a ee ff ff       	call   800d1f <sys_page_alloc>
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 21                	js     801efd <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ef1:	83 ec 0c             	sub    $0xc,%esp
  801ef4:	50                   	push   %eax
  801ef5:	e8 08 f3 ff ff       	call   801202 <fd2num>
  801efa:	83 c4 10             	add    $0x10,%esp
}
  801efd:	c9                   	leave  
  801efe:	c3                   	ret    

00801eff <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f05:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f0c:	74 20                	je     801f2e <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f11:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801f16:	83 ec 08             	sub    $0x8,%esp
  801f19:	68 6e 1f 80 00       	push   $0x801f6e
  801f1e:	6a 00                	push   $0x0
  801f20:	e8 45 ef ff ff       	call   800e6a <sys_env_set_pgfault_upcall>
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 2e                	js     801f5a <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801f2e:	83 ec 04             	sub    $0x4,%esp
  801f31:	6a 07                	push   $0x7
  801f33:	68 00 f0 bf ee       	push   $0xeebff000
  801f38:	6a 00                	push   $0x0
  801f3a:	e8 e0 ed ff ff       	call   800d1f <sys_page_alloc>
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	85 c0                	test   %eax,%eax
  801f44:	79 c8                	jns    801f0e <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801f46:	83 ec 04             	sub    $0x4,%esp
  801f49:	68 40 29 80 00       	push   $0x802940
  801f4e:	6a 21                	push   $0x21
  801f50:	68 a4 29 80 00       	push   $0x8029a4
  801f55:	e8 d2 e2 ff ff       	call   80022c <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801f5a:	83 ec 04             	sub    $0x4,%esp
  801f5d:	68 6c 29 80 00       	push   $0x80296c
  801f62:	6a 27                	push   $0x27
  801f64:	68 a4 29 80 00       	push   $0x8029a4
  801f69:	e8 be e2 ff ff       	call   80022c <_panic>

00801f6e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f6e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f6f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f74:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f76:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801f79:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801f7d:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801f80:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  801f84:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f88:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801f8a:	83 c4 08             	add    $0x8,%esp
	popal
  801f8d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801f8e:	83 c4 04             	add    $0x4,%esp
	popfl
  801f91:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f92:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f93:	c3                   	ret    

00801f94 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	56                   	push   %esi
  801f98:	53                   	push   %ebx
  801f99:	8b 75 08             	mov    0x8(%ebp),%esi
  801f9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801fa2:	85 f6                	test   %esi,%esi
  801fa4:	74 06                	je     801fac <ipc_recv+0x18>
  801fa6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801fac:	85 db                	test   %ebx,%ebx
  801fae:	74 06                	je     801fb6 <ipc_recv+0x22>
  801fb0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801fbd:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801fc0:	83 ec 0c             	sub    $0xc,%esp
  801fc3:	50                   	push   %eax
  801fc4:	e8 06 ef ff ff       	call   800ecf <sys_ipc_recv>
	if (ret) return ret;
  801fc9:	83 c4 10             	add    $0x10,%esp
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	75 24                	jne    801ff4 <ipc_recv+0x60>
	if (from_env_store)
  801fd0:	85 f6                	test   %esi,%esi
  801fd2:	74 0a                	je     801fde <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801fd4:	a1 20 44 80 00       	mov    0x804420,%eax
  801fd9:	8b 40 74             	mov    0x74(%eax),%eax
  801fdc:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801fde:	85 db                	test   %ebx,%ebx
  801fe0:	74 0a                	je     801fec <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801fe2:	a1 20 44 80 00       	mov    0x804420,%eax
  801fe7:	8b 40 78             	mov    0x78(%eax),%eax
  801fea:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801fec:	a1 20 44 80 00       	mov    0x804420,%eax
  801ff1:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ff4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ff7:	5b                   	pop    %ebx
  801ff8:	5e                   	pop    %esi
  801ff9:	5d                   	pop    %ebp
  801ffa:	c3                   	ret    

00801ffb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	57                   	push   %edi
  801fff:	56                   	push   %esi
  802000:	53                   	push   %ebx
  802001:	83 ec 0c             	sub    $0xc,%esp
  802004:	8b 7d 08             	mov    0x8(%ebp),%edi
  802007:	8b 75 0c             	mov    0xc(%ebp),%esi
  80200a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  80200d:	85 db                	test   %ebx,%ebx
  80200f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802014:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802017:	ff 75 14             	pushl  0x14(%ebp)
  80201a:	53                   	push   %ebx
  80201b:	56                   	push   %esi
  80201c:	57                   	push   %edi
  80201d:	e8 8a ee ff ff       	call   800eac <sys_ipc_try_send>
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	85 c0                	test   %eax,%eax
  802027:	74 1e                	je     802047 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802029:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80202c:	75 07                	jne    802035 <ipc_send+0x3a>
		sys_yield();
  80202e:	e8 cd ec ff ff       	call   800d00 <sys_yield>
  802033:	eb e2                	jmp    802017 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802035:	50                   	push   %eax
  802036:	68 b2 29 80 00       	push   $0x8029b2
  80203b:	6a 36                	push   $0x36
  80203d:	68 c9 29 80 00       	push   $0x8029c9
  802042:	e8 e5 e1 ff ff       	call   80022c <_panic>
	}
}
  802047:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204a:	5b                   	pop    %ebx
  80204b:	5e                   	pop    %esi
  80204c:	5f                   	pop    %edi
  80204d:	5d                   	pop    %ebp
  80204e:	c3                   	ret    

0080204f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80204f:	55                   	push   %ebp
  802050:	89 e5                	mov    %esp,%ebp
  802052:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802055:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80205a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80205d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802063:	8b 52 50             	mov    0x50(%edx),%edx
  802066:	39 ca                	cmp    %ecx,%edx
  802068:	74 11                	je     80207b <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80206a:	83 c0 01             	add    $0x1,%eax
  80206d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802072:	75 e6                	jne    80205a <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802074:	b8 00 00 00 00       	mov    $0x0,%eax
  802079:	eb 0b                	jmp    802086 <ipc_find_env+0x37>
			return envs[i].env_id;
  80207b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80207e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802083:	8b 40 48             	mov    0x48(%eax),%eax
}
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    

00802088 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80208e:	89 d0                	mov    %edx,%eax
  802090:	c1 e8 16             	shr    $0x16,%eax
  802093:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80209a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80209f:	f6 c1 01             	test   $0x1,%cl
  8020a2:	74 1d                	je     8020c1 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8020a4:	c1 ea 0c             	shr    $0xc,%edx
  8020a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020ae:	f6 c2 01             	test   $0x1,%dl
  8020b1:	74 0e                	je     8020c1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020b3:	c1 ea 0c             	shr    $0xc,%edx
  8020b6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020bd:	ef 
  8020be:	0f b7 c0             	movzwl %ax,%eax
}
  8020c1:	5d                   	pop    %ebp
  8020c2:	c3                   	ret    
  8020c3:	66 90                	xchg   %ax,%ax
  8020c5:	66 90                	xchg   %ax,%ax
  8020c7:	66 90                	xchg   %ax,%ax
  8020c9:	66 90                	xchg   %ax,%ax
  8020cb:	66 90                	xchg   %ax,%ax
  8020cd:	66 90                	xchg   %ax,%ax
  8020cf:	90                   	nop

008020d0 <__udivdi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020db:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020e3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020e7:	85 d2                	test   %edx,%edx
  8020e9:	75 35                	jne    802120 <__udivdi3+0x50>
  8020eb:	39 f3                	cmp    %esi,%ebx
  8020ed:	0f 87 bd 00 00 00    	ja     8021b0 <__udivdi3+0xe0>
  8020f3:	85 db                	test   %ebx,%ebx
  8020f5:	89 d9                	mov    %ebx,%ecx
  8020f7:	75 0b                	jne    802104 <__udivdi3+0x34>
  8020f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	f7 f3                	div    %ebx
  802102:	89 c1                	mov    %eax,%ecx
  802104:	31 d2                	xor    %edx,%edx
  802106:	89 f0                	mov    %esi,%eax
  802108:	f7 f1                	div    %ecx
  80210a:	89 c6                	mov    %eax,%esi
  80210c:	89 e8                	mov    %ebp,%eax
  80210e:	89 f7                	mov    %esi,%edi
  802110:	f7 f1                	div    %ecx
  802112:	89 fa                	mov    %edi,%edx
  802114:	83 c4 1c             	add    $0x1c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	39 f2                	cmp    %esi,%edx
  802122:	77 7c                	ja     8021a0 <__udivdi3+0xd0>
  802124:	0f bd fa             	bsr    %edx,%edi
  802127:	83 f7 1f             	xor    $0x1f,%edi
  80212a:	0f 84 98 00 00 00    	je     8021c8 <__udivdi3+0xf8>
  802130:	89 f9                	mov    %edi,%ecx
  802132:	b8 20 00 00 00       	mov    $0x20,%eax
  802137:	29 f8                	sub    %edi,%eax
  802139:	d3 e2                	shl    %cl,%edx
  80213b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80213f:	89 c1                	mov    %eax,%ecx
  802141:	89 da                	mov    %ebx,%edx
  802143:	d3 ea                	shr    %cl,%edx
  802145:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802149:	09 d1                	or     %edx,%ecx
  80214b:	89 f2                	mov    %esi,%edx
  80214d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802151:	89 f9                	mov    %edi,%ecx
  802153:	d3 e3                	shl    %cl,%ebx
  802155:	89 c1                	mov    %eax,%ecx
  802157:	d3 ea                	shr    %cl,%edx
  802159:	89 f9                	mov    %edi,%ecx
  80215b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80215f:	d3 e6                	shl    %cl,%esi
  802161:	89 eb                	mov    %ebp,%ebx
  802163:	89 c1                	mov    %eax,%ecx
  802165:	d3 eb                	shr    %cl,%ebx
  802167:	09 de                	or     %ebx,%esi
  802169:	89 f0                	mov    %esi,%eax
  80216b:	f7 74 24 08          	divl   0x8(%esp)
  80216f:	89 d6                	mov    %edx,%esi
  802171:	89 c3                	mov    %eax,%ebx
  802173:	f7 64 24 0c          	mull   0xc(%esp)
  802177:	39 d6                	cmp    %edx,%esi
  802179:	72 0c                	jb     802187 <__udivdi3+0xb7>
  80217b:	89 f9                	mov    %edi,%ecx
  80217d:	d3 e5                	shl    %cl,%ebp
  80217f:	39 c5                	cmp    %eax,%ebp
  802181:	73 5d                	jae    8021e0 <__udivdi3+0x110>
  802183:	39 d6                	cmp    %edx,%esi
  802185:	75 59                	jne    8021e0 <__udivdi3+0x110>
  802187:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80218a:	31 ff                	xor    %edi,%edi
  80218c:	89 fa                	mov    %edi,%edx
  80218e:	83 c4 1c             	add    $0x1c,%esp
  802191:	5b                   	pop    %ebx
  802192:	5e                   	pop    %esi
  802193:	5f                   	pop    %edi
  802194:	5d                   	pop    %ebp
  802195:	c3                   	ret    
  802196:	8d 76 00             	lea    0x0(%esi),%esi
  802199:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021a0:	31 ff                	xor    %edi,%edi
  8021a2:	31 c0                	xor    %eax,%eax
  8021a4:	89 fa                	mov    %edi,%edx
  8021a6:	83 c4 1c             	add    $0x1c,%esp
  8021a9:	5b                   	pop    %ebx
  8021aa:	5e                   	pop    %esi
  8021ab:	5f                   	pop    %edi
  8021ac:	5d                   	pop    %ebp
  8021ad:	c3                   	ret    
  8021ae:	66 90                	xchg   %ax,%ax
  8021b0:	31 ff                	xor    %edi,%edi
  8021b2:	89 e8                	mov    %ebp,%eax
  8021b4:	89 f2                	mov    %esi,%edx
  8021b6:	f7 f3                	div    %ebx
  8021b8:	89 fa                	mov    %edi,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	39 f2                	cmp    %esi,%edx
  8021ca:	72 06                	jb     8021d2 <__udivdi3+0x102>
  8021cc:	31 c0                	xor    %eax,%eax
  8021ce:	39 eb                	cmp    %ebp,%ebx
  8021d0:	77 d2                	ja     8021a4 <__udivdi3+0xd4>
  8021d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d7:	eb cb                	jmp    8021a4 <__udivdi3+0xd4>
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	89 d8                	mov    %ebx,%eax
  8021e2:	31 ff                	xor    %edi,%edi
  8021e4:	eb be                	jmp    8021a4 <__udivdi3+0xd4>
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__umoddi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8021fb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 ed                	test   %ebp,%ebp
  802209:	89 f0                	mov    %esi,%eax
  80220b:	89 da                	mov    %ebx,%edx
  80220d:	75 19                	jne    802228 <__umoddi3+0x38>
  80220f:	39 df                	cmp    %ebx,%edi
  802211:	0f 86 b1 00 00 00    	jbe    8022c8 <__umoddi3+0xd8>
  802217:	f7 f7                	div    %edi
  802219:	89 d0                	mov    %edx,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	83 c4 1c             	add    $0x1c,%esp
  802220:	5b                   	pop    %ebx
  802221:	5e                   	pop    %esi
  802222:	5f                   	pop    %edi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    
  802225:	8d 76 00             	lea    0x0(%esi),%esi
  802228:	39 dd                	cmp    %ebx,%ebp
  80222a:	77 f1                	ja     80221d <__umoddi3+0x2d>
  80222c:	0f bd cd             	bsr    %ebp,%ecx
  80222f:	83 f1 1f             	xor    $0x1f,%ecx
  802232:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802236:	0f 84 b4 00 00 00    	je     8022f0 <__umoddi3+0x100>
  80223c:	b8 20 00 00 00       	mov    $0x20,%eax
  802241:	89 c2                	mov    %eax,%edx
  802243:	8b 44 24 04          	mov    0x4(%esp),%eax
  802247:	29 c2                	sub    %eax,%edx
  802249:	89 c1                	mov    %eax,%ecx
  80224b:	89 f8                	mov    %edi,%eax
  80224d:	d3 e5                	shl    %cl,%ebp
  80224f:	89 d1                	mov    %edx,%ecx
  802251:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802255:	d3 e8                	shr    %cl,%eax
  802257:	09 c5                	or     %eax,%ebp
  802259:	8b 44 24 04          	mov    0x4(%esp),%eax
  80225d:	89 c1                	mov    %eax,%ecx
  80225f:	d3 e7                	shl    %cl,%edi
  802261:	89 d1                	mov    %edx,%ecx
  802263:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802267:	89 df                	mov    %ebx,%edi
  802269:	d3 ef                	shr    %cl,%edi
  80226b:	89 c1                	mov    %eax,%ecx
  80226d:	89 f0                	mov    %esi,%eax
  80226f:	d3 e3                	shl    %cl,%ebx
  802271:	89 d1                	mov    %edx,%ecx
  802273:	89 fa                	mov    %edi,%edx
  802275:	d3 e8                	shr    %cl,%eax
  802277:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80227c:	09 d8                	or     %ebx,%eax
  80227e:	f7 f5                	div    %ebp
  802280:	d3 e6                	shl    %cl,%esi
  802282:	89 d1                	mov    %edx,%ecx
  802284:	f7 64 24 08          	mull   0x8(%esp)
  802288:	39 d1                	cmp    %edx,%ecx
  80228a:	89 c3                	mov    %eax,%ebx
  80228c:	89 d7                	mov    %edx,%edi
  80228e:	72 06                	jb     802296 <__umoddi3+0xa6>
  802290:	75 0e                	jne    8022a0 <__umoddi3+0xb0>
  802292:	39 c6                	cmp    %eax,%esi
  802294:	73 0a                	jae    8022a0 <__umoddi3+0xb0>
  802296:	2b 44 24 08          	sub    0x8(%esp),%eax
  80229a:	19 ea                	sbb    %ebp,%edx
  80229c:	89 d7                	mov    %edx,%edi
  80229e:	89 c3                	mov    %eax,%ebx
  8022a0:	89 ca                	mov    %ecx,%edx
  8022a2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022a7:	29 de                	sub    %ebx,%esi
  8022a9:	19 fa                	sbb    %edi,%edx
  8022ab:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8022af:	89 d0                	mov    %edx,%eax
  8022b1:	d3 e0                	shl    %cl,%eax
  8022b3:	89 d9                	mov    %ebx,%ecx
  8022b5:	d3 ee                	shr    %cl,%esi
  8022b7:	d3 ea                	shr    %cl,%edx
  8022b9:	09 f0                	or     %esi,%eax
  8022bb:	83 c4 1c             	add    $0x1c,%esp
  8022be:	5b                   	pop    %ebx
  8022bf:	5e                   	pop    %esi
  8022c0:	5f                   	pop    %edi
  8022c1:	5d                   	pop    %ebp
  8022c2:	c3                   	ret    
  8022c3:	90                   	nop
  8022c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	85 ff                	test   %edi,%edi
  8022ca:	89 f9                	mov    %edi,%ecx
  8022cc:	75 0b                	jne    8022d9 <__umoddi3+0xe9>
  8022ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d3:	31 d2                	xor    %edx,%edx
  8022d5:	f7 f7                	div    %edi
  8022d7:	89 c1                	mov    %eax,%ecx
  8022d9:	89 d8                	mov    %ebx,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f1                	div    %ecx
  8022df:	89 f0                	mov    %esi,%eax
  8022e1:	f7 f1                	div    %ecx
  8022e3:	e9 31 ff ff ff       	jmp    802219 <__umoddi3+0x29>
  8022e8:	90                   	nop
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	39 dd                	cmp    %ebx,%ebp
  8022f2:	72 08                	jb     8022fc <__umoddi3+0x10c>
  8022f4:	39 f7                	cmp    %esi,%edi
  8022f6:	0f 87 21 ff ff ff    	ja     80221d <__umoddi3+0x2d>
  8022fc:	89 da                	mov    %ebx,%edx
  8022fe:	89 f0                	mov    %esi,%eax
  802300:	29 f8                	sub    %edi,%eax
  802302:	19 ea                	sbb    %ebp,%edx
  802304:	e9 14 ff ff ff       	jmp    80221d <__umoddi3+0x2d>
