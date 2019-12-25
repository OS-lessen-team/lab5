
obj/user/faultalloc.debug：     文件格式 elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 c0 1e 80 00       	push   $0x801ec0
  800045:	e8 bb 01 00 00       	call   800205 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 bf 0b 00 00       	call   800c1d <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 0c 1f 80 00       	push   $0x801f0c
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 60 07 00 00       	call   8007d3 <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 e0 1e 80 00       	push   $0x801ee0
  800085:	6a 0e                	push   $0xe
  800087:	68 ca 1e 80 00       	push   $0x801eca
  80008c:	e8 99 00 00 00       	call   80012a <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 6d 0d 00 00       	call   800e0e <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 dc 1e 80 00       	push   $0x801edc
  8000ae:	e8 52 01 00 00       	call   800205 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 dc 1e 80 00       	push   $0x801edc
  8000c0:	e8 40 01 00 00       	call   800205 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000d5:	e8 05 0b 00 00       	call   800bdf <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 5e 0f 00 00       	call   801079 <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 79 0a 00 00       	call   800b9e <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 a2 0a 00 00       	call   800bdf <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 38 1f 80 00       	push   $0x801f38
  80014d:	e8 b3 00 00 00       	call   800205 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 56 00 00 00       	call   8001b4 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 d7 23 80 00 	movl   $0x8023d7,(%esp)
  800165:	e8 9b 00 00 00       	call   800205 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	74 09                	je     800198 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80018f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800196:	c9                   	leave  
  800197:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800198:	83 ec 08             	sub    $0x8,%esp
  80019b:	68 ff 00 00 00       	push   $0xff
  8001a0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 b8 09 00 00       	call   800b61 <sys_cputs>
		b->idx = 0;
  8001a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	eb db                	jmp    80018f <putch+0x1f>

008001b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c4:	00 00 00 
	b.cnt = 0;
  8001c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d1:	ff 75 0c             	pushl  0xc(%ebp)
  8001d4:	ff 75 08             	pushl  0x8(%ebp)
  8001d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dd:	50                   	push   %eax
  8001de:	68 70 01 80 00       	push   $0x800170
  8001e3:	e8 1a 01 00 00       	call   800302 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e8:	83 c4 08             	add    $0x8,%esp
  8001eb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f7:	50                   	push   %eax
  8001f8:	e8 64 09 00 00       	call   800b61 <sys_cputs>

	return b.cnt;
}
  8001fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020e:	50                   	push   %eax
  80020f:	ff 75 08             	pushl  0x8(%ebp)
  800212:	e8 9d ff ff ff       	call   8001b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 1c             	sub    $0x1c,%esp
  800222:	89 c7                	mov    %eax,%edi
  800224:	89 d6                	mov    %edx,%esi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800232:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800235:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800240:	39 d3                	cmp    %edx,%ebx
  800242:	72 05                	jb     800249 <printnum+0x30>
  800244:	39 45 10             	cmp    %eax,0x10(%ebp)
  800247:	77 7a                	ja     8002c3 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 18             	pushl  0x18(%ebp)
  80024f:	8b 45 14             	mov    0x14(%ebp),%eax
  800252:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800255:	53                   	push   %ebx
  800256:	ff 75 10             	pushl  0x10(%ebp)
  800259:	83 ec 08             	sub    $0x8,%esp
  80025c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025f:	ff 75 e0             	pushl  -0x20(%ebp)
  800262:	ff 75 dc             	pushl  -0x24(%ebp)
  800265:	ff 75 d8             	pushl  -0x28(%ebp)
  800268:	e8 13 1a 00 00       	call   801c80 <__udivdi3>
  80026d:	83 c4 18             	add    $0x18,%esp
  800270:	52                   	push   %edx
  800271:	50                   	push   %eax
  800272:	89 f2                	mov    %esi,%edx
  800274:	89 f8                	mov    %edi,%eax
  800276:	e8 9e ff ff ff       	call   800219 <printnum>
  80027b:	83 c4 20             	add    $0x20,%esp
  80027e:	eb 13                	jmp    800293 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	56                   	push   %esi
  800284:	ff 75 18             	pushl  0x18(%ebp)
  800287:	ff d7                	call   *%edi
  800289:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7f ed                	jg     800280 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	83 ec 04             	sub    $0x4,%esp
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a6:	e8 f5 1a 00 00       	call   801da0 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 5b 1f 80 00 	movsbl 0x801f5b(%eax),%eax
  8002b5:	50                   	push   %eax
  8002b6:	ff d7                	call   *%edi
}
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    
  8002c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c6:	eb c4                	jmp    80028c <printnum+0x73>

008002c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ce:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d7:	73 0a                	jae    8002e3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dc:	89 08                	mov    %ecx,(%eax)
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	88 02                	mov    %al,(%edx)
}
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <printfmt>:
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002eb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ee:	50                   	push   %eax
  8002ef:	ff 75 10             	pushl  0x10(%ebp)
  8002f2:	ff 75 0c             	pushl  0xc(%ebp)
  8002f5:	ff 75 08             	pushl  0x8(%ebp)
  8002f8:	e8 05 00 00 00       	call   800302 <vprintfmt>
}
  8002fd:	83 c4 10             	add    $0x10,%esp
  800300:	c9                   	leave  
  800301:	c3                   	ret    

00800302 <vprintfmt>:
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	57                   	push   %edi
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	83 ec 2c             	sub    $0x2c,%esp
  80030b:	8b 75 08             	mov    0x8(%ebp),%esi
  80030e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800311:	8b 7d 10             	mov    0x10(%ebp),%edi
  800314:	e9 c1 03 00 00       	jmp    8006da <vprintfmt+0x3d8>
		padc = ' ';
  800319:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80031d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800324:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80032b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800332:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8d 47 01             	lea    0x1(%edi),%eax
  80033a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033d:	0f b6 17             	movzbl (%edi),%edx
  800340:	8d 42 dd             	lea    -0x23(%edx),%eax
  800343:	3c 55                	cmp    $0x55,%al
  800345:	0f 87 12 04 00 00    	ja     80075d <vprintfmt+0x45b>
  80034b:	0f b6 c0             	movzbl %al,%eax
  80034e:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800358:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80035c:	eb d9                	jmp    800337 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800361:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800365:	eb d0                	jmp    800337 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800367:	0f b6 d2             	movzbl %dl,%edx
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80036d:	b8 00 00 00 00       	mov    $0x0,%eax
  800372:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800375:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800378:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80037c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80037f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800382:	83 f9 09             	cmp    $0x9,%ecx
  800385:	77 55                	ja     8003dc <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800387:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80038a:	eb e9                	jmp    800375 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80038c:	8b 45 14             	mov    0x14(%ebp),%eax
  80038f:	8b 00                	mov    (%eax),%eax
  800391:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 40 04             	lea    0x4(%eax),%eax
  80039a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a4:	79 91                	jns    800337 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003a6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ac:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b3:	eb 82                	jmp    800337 <vprintfmt+0x35>
  8003b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bf:	0f 49 d0             	cmovns %eax,%edx
  8003c2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c8:	e9 6a ff ff ff       	jmp    800337 <vprintfmt+0x35>
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003d0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d7:	e9 5b ff ff ff       	jmp    800337 <vprintfmt+0x35>
  8003dc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003e2:	eb bc                	jmp    8003a0 <vprintfmt+0x9e>
			lflag++;
  8003e4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ea:	e9 48 ff ff ff       	jmp    800337 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 78 04             	lea    0x4(%eax),%edi
  8003f5:	83 ec 08             	sub    $0x8,%esp
  8003f8:	53                   	push   %ebx
  8003f9:	ff 30                	pushl  (%eax)
  8003fb:	ff d6                	call   *%esi
			break;
  8003fd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800400:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800403:	e9 cf 02 00 00       	jmp    8006d7 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 78 04             	lea    0x4(%eax),%edi
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	99                   	cltd   
  800411:	31 d0                	xor    %edx,%eax
  800413:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800415:	83 f8 0f             	cmp    $0xf,%eax
  800418:	7f 23                	jg     80043d <vprintfmt+0x13b>
  80041a:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  800421:	85 d2                	test   %edx,%edx
  800423:	74 18                	je     80043d <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800425:	52                   	push   %edx
  800426:	68 a5 23 80 00       	push   $0x8023a5
  80042b:	53                   	push   %ebx
  80042c:	56                   	push   %esi
  80042d:	e8 b3 fe ff ff       	call   8002e5 <printfmt>
  800432:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800435:	89 7d 14             	mov    %edi,0x14(%ebp)
  800438:	e9 9a 02 00 00       	jmp    8006d7 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80043d:	50                   	push   %eax
  80043e:	68 73 1f 80 00       	push   $0x801f73
  800443:	53                   	push   %ebx
  800444:	56                   	push   %esi
  800445:	e8 9b fe ff ff       	call   8002e5 <printfmt>
  80044a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80044d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800450:	e9 82 02 00 00       	jmp    8006d7 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	83 c0 04             	add    $0x4,%eax
  80045b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800463:	85 ff                	test   %edi,%edi
  800465:	b8 6c 1f 80 00       	mov    $0x801f6c,%eax
  80046a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800471:	0f 8e bd 00 00 00    	jle    800534 <vprintfmt+0x232>
  800477:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047b:	75 0e                	jne    80048b <vprintfmt+0x189>
  80047d:	89 75 08             	mov    %esi,0x8(%ebp)
  800480:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800483:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800486:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800489:	eb 6d                	jmp    8004f8 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	ff 75 d0             	pushl  -0x30(%ebp)
  800491:	57                   	push   %edi
  800492:	e8 6e 03 00 00       	call   800805 <strnlen>
  800497:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049a:	29 c1                	sub    %eax,%ecx
  80049c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ac:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ae:	eb 0f                	jmp    8004bf <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	53                   	push   %ebx
  8004b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	83 ef 01             	sub    $0x1,%edi
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 ff                	test   %edi,%edi
  8004c1:	7f ed                	jg     8004b0 <vprintfmt+0x1ae>
  8004c3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004c9:	85 c9                	test   %ecx,%ecx
  8004cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d0:	0f 49 c1             	cmovns %ecx,%eax
  8004d3:	29 c1                	sub    %eax,%ecx
  8004d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004de:	89 cb                	mov    %ecx,%ebx
  8004e0:	eb 16                	jmp    8004f8 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e6:	75 31                	jne    800519 <vprintfmt+0x217>
					putch(ch, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	ff 75 0c             	pushl  0xc(%ebp)
  8004ee:	50                   	push   %eax
  8004ef:	ff 55 08             	call   *0x8(%ebp)
  8004f2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f5:	83 eb 01             	sub    $0x1,%ebx
  8004f8:	83 c7 01             	add    $0x1,%edi
  8004fb:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004ff:	0f be c2             	movsbl %dl,%eax
  800502:	85 c0                	test   %eax,%eax
  800504:	74 59                	je     80055f <vprintfmt+0x25d>
  800506:	85 f6                	test   %esi,%esi
  800508:	78 d8                	js     8004e2 <vprintfmt+0x1e0>
  80050a:	83 ee 01             	sub    $0x1,%esi
  80050d:	79 d3                	jns    8004e2 <vprintfmt+0x1e0>
  80050f:	89 df                	mov    %ebx,%edi
  800511:	8b 75 08             	mov    0x8(%ebp),%esi
  800514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800517:	eb 37                	jmp    800550 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	0f be d2             	movsbl %dl,%edx
  80051c:	83 ea 20             	sub    $0x20,%edx
  80051f:	83 fa 5e             	cmp    $0x5e,%edx
  800522:	76 c4                	jbe    8004e8 <vprintfmt+0x1e6>
					putch('?', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	ff 75 0c             	pushl  0xc(%ebp)
  80052a:	6a 3f                	push   $0x3f
  80052c:	ff 55 08             	call   *0x8(%ebp)
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	eb c1                	jmp    8004f5 <vprintfmt+0x1f3>
  800534:	89 75 08             	mov    %esi,0x8(%ebp)
  800537:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800540:	eb b6                	jmp    8004f8 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 20                	push   $0x20
  800548:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80054a:	83 ef 01             	sub    $0x1,%edi
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	85 ff                	test   %edi,%edi
  800552:	7f ee                	jg     800542 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800554:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800557:	89 45 14             	mov    %eax,0x14(%ebp)
  80055a:	e9 78 01 00 00       	jmp    8006d7 <vprintfmt+0x3d5>
  80055f:	89 df                	mov    %ebx,%edi
  800561:	8b 75 08             	mov    0x8(%ebp),%esi
  800564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800567:	eb e7                	jmp    800550 <vprintfmt+0x24e>
	if (lflag >= 2)
  800569:	83 f9 01             	cmp    $0x1,%ecx
  80056c:	7e 3f                	jle    8005ad <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8b 50 04             	mov    0x4(%eax),%edx
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 40 08             	lea    0x8(%eax),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800585:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800589:	79 5c                	jns    8005e7 <vprintfmt+0x2e5>
				putch('-', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	53                   	push   %ebx
  80058f:	6a 2d                	push   $0x2d
  800591:	ff d6                	call   *%esi
				num = -(long long) num;
  800593:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800596:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800599:	f7 da                	neg    %edx
  80059b:	83 d1 00             	adc    $0x0,%ecx
  80059e:	f7 d9                	neg    %ecx
  8005a0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a8:	e9 10 01 00 00       	jmp    8006bd <vprintfmt+0x3bb>
	else if (lflag)
  8005ad:	85 c9                	test   %ecx,%ecx
  8005af:	75 1b                	jne    8005cc <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8b 00                	mov    (%eax),%eax
  8005b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b9:	89 c1                	mov    %eax,%ecx
  8005bb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 40 04             	lea    0x4(%eax),%eax
  8005c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ca:	eb b9                	jmp    800585 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 c1                	mov    %eax,%ecx
  8005d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 40 04             	lea    0x4(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e5:	eb 9e                	jmp    800585 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f2:	e9 c6 00 00 00       	jmp    8006bd <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005f7:	83 f9 01             	cmp    $0x1,%ecx
  8005fa:	7e 18                	jle    800614 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 10                	mov    (%eax),%edx
  800601:	8b 48 04             	mov    0x4(%eax),%ecx
  800604:	8d 40 08             	lea    0x8(%eax),%eax
  800607:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060f:	e9 a9 00 00 00       	jmp    8006bd <vprintfmt+0x3bb>
	else if (lflag)
  800614:	85 c9                	test   %ecx,%ecx
  800616:	75 1a                	jne    800632 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8b 10                	mov    (%eax),%edx
  80061d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800622:	8d 40 04             	lea    0x4(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800628:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062d:	e9 8b 00 00 00       	jmp    8006bd <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 10                	mov    (%eax),%edx
  800637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	eb 74                	jmp    8006bd <vprintfmt+0x3bb>
	if (lflag >= 2)
  800649:	83 f9 01             	cmp    $0x1,%ecx
  80064c:	7e 15                	jle    800663 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8b 10                	mov    (%eax),%edx
  800653:	8b 48 04             	mov    0x4(%eax),%ecx
  800656:	8d 40 08             	lea    0x8(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80065c:	b8 08 00 00 00       	mov    $0x8,%eax
  800661:	eb 5a                	jmp    8006bd <vprintfmt+0x3bb>
	else if (lflag)
  800663:	85 c9                	test   %ecx,%ecx
  800665:	75 17                	jne    80067e <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 10                	mov    (%eax),%edx
  80066c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800671:	8d 40 04             	lea    0x4(%eax),%eax
  800674:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800677:	b8 08 00 00 00       	mov    $0x8,%eax
  80067c:	eb 3f                	jmp    8006bd <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 10                	mov    (%eax),%edx
  800683:	b9 00 00 00 00       	mov    $0x0,%ecx
  800688:	8d 40 04             	lea    0x4(%eax),%eax
  80068b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80068e:	b8 08 00 00 00       	mov    $0x8,%eax
  800693:	eb 28                	jmp    8006bd <vprintfmt+0x3bb>
			putch('0', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 30                	push   $0x30
  80069b:	ff d6                	call   *%esi
			putch('x', putdat);
  80069d:	83 c4 08             	add    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 78                	push   $0x78
  8006a3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006af:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b8:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006bd:	83 ec 0c             	sub    $0xc,%esp
  8006c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c4:	57                   	push   %edi
  8006c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c8:	50                   	push   %eax
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	89 da                	mov    %ebx,%edx
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	e8 45 fb ff ff       	call   800219 <printnum>
			break;
  8006d4:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006da:	83 c7 01             	add    $0x1,%edi
  8006dd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e1:	83 f8 25             	cmp    $0x25,%eax
  8006e4:	0f 84 2f fc ff ff    	je     800319 <vprintfmt+0x17>
			if (ch == '\0')
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	0f 84 8b 00 00 00    	je     80077d <vprintfmt+0x47b>
			putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	50                   	push   %eax
  8006f7:	ff d6                	call   *%esi
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	eb dc                	jmp    8006da <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006fe:	83 f9 01             	cmp    $0x1,%ecx
  800701:	7e 15                	jle    800718 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8b 10                	mov    (%eax),%edx
  800708:	8b 48 04             	mov    0x4(%eax),%ecx
  80070b:	8d 40 08             	lea    0x8(%eax),%eax
  80070e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800711:	b8 10 00 00 00       	mov    $0x10,%eax
  800716:	eb a5                	jmp    8006bd <vprintfmt+0x3bb>
	else if (lflag)
  800718:	85 c9                	test   %ecx,%ecx
  80071a:	75 17                	jne    800733 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 10                	mov    (%eax),%edx
  800721:	b9 00 00 00 00       	mov    $0x0,%ecx
  800726:	8d 40 04             	lea    0x4(%eax),%eax
  800729:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072c:	b8 10 00 00 00       	mov    $0x10,%eax
  800731:	eb 8a                	jmp    8006bd <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 10                	mov    (%eax),%edx
  800738:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073d:	8d 40 04             	lea    0x4(%eax),%eax
  800740:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800743:	b8 10 00 00 00       	mov    $0x10,%eax
  800748:	e9 70 ff ff ff       	jmp    8006bd <vprintfmt+0x3bb>
			putch(ch, putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	53                   	push   %ebx
  800751:	6a 25                	push   $0x25
  800753:	ff d6                	call   *%esi
			break;
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	e9 7a ff ff ff       	jmp    8006d7 <vprintfmt+0x3d5>
			putch('%', putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	53                   	push   %ebx
  800761:	6a 25                	push   $0x25
  800763:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	89 f8                	mov    %edi,%eax
  80076a:	eb 03                	jmp    80076f <vprintfmt+0x46d>
  80076c:	83 e8 01             	sub    $0x1,%eax
  80076f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800773:	75 f7                	jne    80076c <vprintfmt+0x46a>
  800775:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800778:	e9 5a ff ff ff       	jmp    8006d7 <vprintfmt+0x3d5>
}
  80077d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800780:	5b                   	pop    %ebx
  800781:	5e                   	pop    %esi
  800782:	5f                   	pop    %edi
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 18             	sub    $0x18,%esp
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800791:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800794:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800798:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	74 26                	je     8007cc <vsnprintf+0x47>
  8007a6:	85 d2                	test   %edx,%edx
  8007a8:	7e 22                	jle    8007cc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007aa:	ff 75 14             	pushl  0x14(%ebp)
  8007ad:	ff 75 10             	pushl  0x10(%ebp)
  8007b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b3:	50                   	push   %eax
  8007b4:	68 c8 02 80 00       	push   $0x8002c8
  8007b9:	e8 44 fb ff ff       	call   800302 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c7:	83 c4 10             	add    $0x10,%esp
}
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    
		return -E_INVAL;
  8007cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d1:	eb f7                	jmp    8007ca <vsnprintf+0x45>

008007d3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007dc:	50                   	push   %eax
  8007dd:	ff 75 10             	pushl  0x10(%ebp)
  8007e0:	ff 75 0c             	pushl  0xc(%ebp)
  8007e3:	ff 75 08             	pushl  0x8(%ebp)
  8007e6:	e8 9a ff ff ff       	call   800785 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f8:	eb 03                	jmp    8007fd <strlen+0x10>
		n++;
  8007fa:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007fd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800801:	75 f7                	jne    8007fa <strlen+0xd>
	return n;
}
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
  800813:	eb 03                	jmp    800818 <strnlen+0x13>
		n++;
  800815:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800818:	39 d0                	cmp    %edx,%eax
  80081a:	74 06                	je     800822 <strnlen+0x1d>
  80081c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800820:	75 f3                	jne    800815 <strnlen+0x10>
	return n;
}
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082e:	89 c2                	mov    %eax,%edx
  800830:	83 c1 01             	add    $0x1,%ecx
  800833:	83 c2 01             	add    $0x1,%edx
  800836:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80083a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80083d:	84 db                	test   %bl,%bl
  80083f:	75 ef                	jne    800830 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800841:	5b                   	pop    %ebx
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	53                   	push   %ebx
  800848:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084b:	53                   	push   %ebx
  80084c:	e8 9c ff ff ff       	call   8007ed <strlen>
  800851:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800854:	ff 75 0c             	pushl  0xc(%ebp)
  800857:	01 d8                	add    %ebx,%eax
  800859:	50                   	push   %eax
  80085a:	e8 c5 ff ff ff       	call   800824 <strcpy>
	return dst;
}
  80085f:	89 d8                	mov    %ebx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 75 08             	mov    0x8(%ebp),%esi
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800871:	89 f3                	mov    %esi,%ebx
  800873:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800876:	89 f2                	mov    %esi,%edx
  800878:	eb 0f                	jmp    800889 <strncpy+0x23>
		*dst++ = *src;
  80087a:	83 c2 01             	add    $0x1,%edx
  80087d:	0f b6 01             	movzbl (%ecx),%eax
  800880:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800883:	80 39 01             	cmpb   $0x1,(%ecx)
  800886:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800889:	39 da                	cmp    %ebx,%edx
  80088b:	75 ed                	jne    80087a <strncpy+0x14>
	}
	return ret;
}
  80088d:	89 f0                	mov    %esi,%eax
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 75 08             	mov    0x8(%ebp),%esi
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008a1:	89 f0                	mov    %esi,%eax
  8008a3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a7:	85 c9                	test   %ecx,%ecx
  8008a9:	75 0b                	jne    8008b6 <strlcpy+0x23>
  8008ab:	eb 17                	jmp    8008c4 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ad:	83 c2 01             	add    $0x1,%edx
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008b6:	39 d8                	cmp    %ebx,%eax
  8008b8:	74 07                	je     8008c1 <strlcpy+0x2e>
  8008ba:	0f b6 0a             	movzbl (%edx),%ecx
  8008bd:	84 c9                	test   %cl,%cl
  8008bf:	75 ec                	jne    8008ad <strlcpy+0x1a>
		*dst = '\0';
  8008c1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c4:	29 f0                	sub    %esi,%eax
}
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d3:	eb 06                	jmp    8008db <strcmp+0x11>
		p++, q++;
  8008d5:	83 c1 01             	add    $0x1,%ecx
  8008d8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008db:	0f b6 01             	movzbl (%ecx),%eax
  8008de:	84 c0                	test   %al,%al
  8008e0:	74 04                	je     8008e6 <strcmp+0x1c>
  8008e2:	3a 02                	cmp    (%edx),%al
  8008e4:	74 ef                	je     8008d5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e6:	0f b6 c0             	movzbl %al,%eax
  8008e9:	0f b6 12             	movzbl (%edx),%edx
  8008ec:	29 d0                	sub    %edx,%eax
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fa:	89 c3                	mov    %eax,%ebx
  8008fc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ff:	eb 06                	jmp    800907 <strncmp+0x17>
		n--, p++, q++;
  800901:	83 c0 01             	add    $0x1,%eax
  800904:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800907:	39 d8                	cmp    %ebx,%eax
  800909:	74 16                	je     800921 <strncmp+0x31>
  80090b:	0f b6 08             	movzbl (%eax),%ecx
  80090e:	84 c9                	test   %cl,%cl
  800910:	74 04                	je     800916 <strncmp+0x26>
  800912:	3a 0a                	cmp    (%edx),%cl
  800914:	74 eb                	je     800901 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800916:	0f b6 00             	movzbl (%eax),%eax
  800919:	0f b6 12             	movzbl (%edx),%edx
  80091c:	29 d0                	sub    %edx,%eax
}
  80091e:	5b                   	pop    %ebx
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    
		return 0;
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
  800926:	eb f6                	jmp    80091e <strncmp+0x2e>

00800928 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800932:	0f b6 10             	movzbl (%eax),%edx
  800935:	84 d2                	test   %dl,%dl
  800937:	74 09                	je     800942 <strchr+0x1a>
		if (*s == c)
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	74 0a                	je     800947 <strchr+0x1f>
	for (; *s; s++)
  80093d:	83 c0 01             	add    $0x1,%eax
  800940:	eb f0                	jmp    800932 <strchr+0xa>
			return (char *) s;
	return 0;
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800953:	eb 03                	jmp    800958 <strfind+0xf>
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80095b:	38 ca                	cmp    %cl,%dl
  80095d:	74 04                	je     800963 <strfind+0x1a>
  80095f:	84 d2                	test   %dl,%dl
  800961:	75 f2                	jne    800955 <strfind+0xc>
			break;
	return (char *) s;
}
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	57                   	push   %edi
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800971:	85 c9                	test   %ecx,%ecx
  800973:	74 13                	je     800988 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800975:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097b:	75 05                	jne    800982 <memset+0x1d>
  80097d:	f6 c1 03             	test   $0x3,%cl
  800980:	74 0d                	je     80098f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800982:	8b 45 0c             	mov    0xc(%ebp),%eax
  800985:	fc                   	cld    
  800986:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800988:	89 f8                	mov    %edi,%eax
  80098a:	5b                   	pop    %ebx
  80098b:	5e                   	pop    %esi
  80098c:	5f                   	pop    %edi
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    
		c &= 0xFF;
  80098f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800993:	89 d3                	mov    %edx,%ebx
  800995:	c1 e3 08             	shl    $0x8,%ebx
  800998:	89 d0                	mov    %edx,%eax
  80099a:	c1 e0 18             	shl    $0x18,%eax
  80099d:	89 d6                	mov    %edx,%esi
  80099f:	c1 e6 10             	shl    $0x10,%esi
  8009a2:	09 f0                	or     %esi,%eax
  8009a4:	09 c2                	or     %eax,%edx
  8009a6:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ab:	89 d0                	mov    %edx,%eax
  8009ad:	fc                   	cld    
  8009ae:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b0:	eb d6                	jmp    800988 <memset+0x23>

008009b2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	57                   	push   %edi
  8009b6:	56                   	push   %esi
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c0:	39 c6                	cmp    %eax,%esi
  8009c2:	73 35                	jae    8009f9 <memmove+0x47>
  8009c4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c7:	39 c2                	cmp    %eax,%edx
  8009c9:	76 2e                	jbe    8009f9 <memmove+0x47>
		s += n;
		d += n;
  8009cb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	89 d6                	mov    %edx,%esi
  8009d0:	09 fe                	or     %edi,%esi
  8009d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d8:	74 0c                	je     8009e6 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009da:	83 ef 01             	sub    $0x1,%edi
  8009dd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009e0:	fd                   	std    
  8009e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e3:	fc                   	cld    
  8009e4:	eb 21                	jmp    800a07 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e6:	f6 c1 03             	test   $0x3,%cl
  8009e9:	75 ef                	jne    8009da <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009eb:	83 ef 04             	sub    $0x4,%edi
  8009ee:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009f4:	fd                   	std    
  8009f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f7:	eb ea                	jmp    8009e3 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f9:	89 f2                	mov    %esi,%edx
  8009fb:	09 c2                	or     %eax,%edx
  8009fd:	f6 c2 03             	test   $0x3,%dl
  800a00:	74 09                	je     800a0b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a02:	89 c7                	mov    %eax,%edi
  800a04:	fc                   	cld    
  800a05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0b:	f6 c1 03             	test   $0x3,%cl
  800a0e:	75 f2                	jne    800a02 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a10:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a13:	89 c7                	mov    %eax,%edi
  800a15:	fc                   	cld    
  800a16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a18:	eb ed                	jmp    800a07 <memmove+0x55>

00800a1a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a1d:	ff 75 10             	pushl  0x10(%ebp)
  800a20:	ff 75 0c             	pushl  0xc(%ebp)
  800a23:	ff 75 08             	pushl  0x8(%ebp)
  800a26:	e8 87 ff ff ff       	call   8009b2 <memmove>
}
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a38:	89 c6                	mov    %eax,%esi
  800a3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3d:	39 f0                	cmp    %esi,%eax
  800a3f:	74 1c                	je     800a5d <memcmp+0x30>
		if (*s1 != *s2)
  800a41:	0f b6 08             	movzbl (%eax),%ecx
  800a44:	0f b6 1a             	movzbl (%edx),%ebx
  800a47:	38 d9                	cmp    %bl,%cl
  800a49:	75 08                	jne    800a53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	83 c2 01             	add    $0x1,%edx
  800a51:	eb ea                	jmp    800a3d <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a53:	0f b6 c1             	movzbl %cl,%eax
  800a56:	0f b6 db             	movzbl %bl,%ebx
  800a59:	29 d8                	sub    %ebx,%eax
  800a5b:	eb 05                	jmp    800a62 <memcmp+0x35>
	}

	return 0;
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a6f:	89 c2                	mov    %eax,%edx
  800a71:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a74:	39 d0                	cmp    %edx,%eax
  800a76:	73 09                	jae    800a81 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a78:	38 08                	cmp    %cl,(%eax)
  800a7a:	74 05                	je     800a81 <memfind+0x1b>
	for (; s < ends; s++)
  800a7c:	83 c0 01             	add    $0x1,%eax
  800a7f:	eb f3                	jmp    800a74 <memfind+0xe>
			break;
	return (void *) s;
}
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8f:	eb 03                	jmp    800a94 <strtol+0x11>
		s++;
  800a91:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a94:	0f b6 01             	movzbl (%ecx),%eax
  800a97:	3c 20                	cmp    $0x20,%al
  800a99:	74 f6                	je     800a91 <strtol+0xe>
  800a9b:	3c 09                	cmp    $0x9,%al
  800a9d:	74 f2                	je     800a91 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a9f:	3c 2b                	cmp    $0x2b,%al
  800aa1:	74 2e                	je     800ad1 <strtol+0x4e>
	int neg = 0;
  800aa3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aa8:	3c 2d                	cmp    $0x2d,%al
  800aaa:	74 2f                	je     800adb <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aac:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab2:	75 05                	jne    800ab9 <strtol+0x36>
  800ab4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab7:	74 2c                	je     800ae5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	75 0a                	jne    800ac7 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800abd:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ac2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac5:	74 28                	je     800aef <strtol+0x6c>
		base = 10;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  800acc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800acf:	eb 50                	jmp    800b21 <strtol+0x9e>
		s++;
  800ad1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ad4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad9:	eb d1                	jmp    800aac <strtol+0x29>
		s++, neg = 1;
  800adb:	83 c1 01             	add    $0x1,%ecx
  800ade:	bf 01 00 00 00       	mov    $0x1,%edi
  800ae3:	eb c7                	jmp    800aac <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae9:	74 0e                	je     800af9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aeb:	85 db                	test   %ebx,%ebx
  800aed:	75 d8                	jne    800ac7 <strtol+0x44>
		s++, base = 8;
  800aef:	83 c1 01             	add    $0x1,%ecx
  800af2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800af7:	eb ce                	jmp    800ac7 <strtol+0x44>
		s += 2, base = 16;
  800af9:	83 c1 02             	add    $0x2,%ecx
  800afc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b01:	eb c4                	jmp    800ac7 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b03:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 19             	cmp    $0x19,%bl
  800b0b:	77 29                	ja     800b36 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b0d:	0f be d2             	movsbl %dl,%edx
  800b10:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b13:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b16:	7d 30                	jge    800b48 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b18:	83 c1 01             	add    $0x1,%ecx
  800b1b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b21:	0f b6 11             	movzbl (%ecx),%edx
  800b24:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b27:	89 f3                	mov    %esi,%ebx
  800b29:	80 fb 09             	cmp    $0x9,%bl
  800b2c:	77 d5                	ja     800b03 <strtol+0x80>
			dig = *s - '0';
  800b2e:	0f be d2             	movsbl %dl,%edx
  800b31:	83 ea 30             	sub    $0x30,%edx
  800b34:	eb dd                	jmp    800b13 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b36:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b39:	89 f3                	mov    %esi,%ebx
  800b3b:	80 fb 19             	cmp    $0x19,%bl
  800b3e:	77 08                	ja     800b48 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b40:	0f be d2             	movsbl %dl,%edx
  800b43:	83 ea 37             	sub    $0x37,%edx
  800b46:	eb cb                	jmp    800b13 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4c:	74 05                	je     800b53 <strtol+0xd0>
		*endptr = (char *) s;
  800b4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b51:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b53:	89 c2                	mov    %eax,%edx
  800b55:	f7 da                	neg    %edx
  800b57:	85 ff                	test   %edi,%edi
  800b59:	0f 45 c2             	cmovne %edx,%eax
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	89 c3                	mov    %eax,%ebx
  800b74:	89 c7                	mov    %eax,%edi
  800b76:	89 c6                	mov    %eax,%esi
  800b78:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b85:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8f:	89 d1                	mov    %edx,%ecx
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	89 d7                	mov    %edx,%edi
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ba7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb4:	89 cb                	mov    %ecx,%ebx
  800bb6:	89 cf                	mov    %ecx,%edi
  800bb8:	89 ce                	mov    %ecx,%esi
  800bba:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	7f 08                	jg     800bc8 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 03                	push   $0x3
  800bce:	68 5f 22 80 00       	push   $0x80225f
  800bd3:	6a 23                	push   $0x23
  800bd5:	68 7c 22 80 00       	push   $0x80227c
  800bda:	e8 4b f5 ff ff       	call   80012a <_panic>

00800bdf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bea:	b8 02 00 00 00       	mov    $0x2,%eax
  800bef:	89 d1                	mov    %edx,%ecx
  800bf1:	89 d3                	mov    %edx,%ebx
  800bf3:	89 d7                	mov    %edx,%edi
  800bf5:	89 d6                	mov    %edx,%esi
  800bf7:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_yield>:

void
sys_yield(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c26:	be 00 00 00 00       	mov    $0x0,%esi
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	b8 04 00 00 00       	mov    $0x4,%eax
  800c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c39:	89 f7                	mov    %esi,%edi
  800c3b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7f 08                	jg     800c49 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 04                	push   $0x4
  800c4f:	68 5f 22 80 00       	push   $0x80225f
  800c54:	6a 23                	push   $0x23
  800c56:	68 7c 22 80 00       	push   $0x80227c
  800c5b:	e8 ca f4 ff ff       	call   80012a <_panic>

00800c60 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7f 08                	jg     800c8b <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	50                   	push   %eax
  800c8f:	6a 05                	push   $0x5
  800c91:	68 5f 22 80 00       	push   $0x80225f
  800c96:	6a 23                	push   $0x23
  800c98:	68 7c 22 80 00       	push   $0x80227c
  800c9d:	e8 88 f4 ff ff       	call   80012a <_panic>

00800ca2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7f 08                	jg     800ccd <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 06                	push   $0x6
  800cd3:	68 5f 22 80 00       	push   $0x80225f
  800cd8:	6a 23                	push   $0x23
  800cda:	68 7c 22 80 00       	push   $0x80227c
  800cdf:	e8 46 f4 ff ff       	call   80012a <_panic>

00800ce4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7f 08                	jg     800d0f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	50                   	push   %eax
  800d13:	6a 08                	push   $0x8
  800d15:	68 5f 22 80 00       	push   $0x80225f
  800d1a:	6a 23                	push   $0x23
  800d1c:	68 7c 22 80 00       	push   $0x80227c
  800d21:	e8 04 f4 ff ff       	call   80012a <_panic>

00800d26 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7f 08                	jg     800d51 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	50                   	push   %eax
  800d55:	6a 09                	push   $0x9
  800d57:	68 5f 22 80 00       	push   $0x80225f
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 7c 22 80 00       	push   $0x80227c
  800d63:	e8 c2 f3 ff ff       	call   80012a <_panic>

00800d68 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d81:	89 df                	mov    %ebx,%edi
  800d83:	89 de                	mov    %ebx,%esi
  800d85:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7f 08                	jg     800d93 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	50                   	push   %eax
  800d97:	6a 0a                	push   $0xa
  800d99:	68 5f 22 80 00       	push   $0x80225f
  800d9e:	6a 23                	push   $0x23
  800da0:	68 7c 22 80 00       	push   $0x80227c
  800da5:	e8 80 f3 ff ff       	call   80012a <_panic>

00800daa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dbb:	be 00 00 00 00       	mov    $0x0,%esi
  800dc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc6:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de3:	89 cb                	mov    %ecx,%ebx
  800de5:	89 cf                	mov    %ecx,%edi
  800de7:	89 ce                	mov    %ecx,%esi
  800de9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7f 08                	jg     800df7 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800def:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df7:	83 ec 0c             	sub    $0xc,%esp
  800dfa:	50                   	push   %eax
  800dfb:	6a 0d                	push   $0xd
  800dfd:	68 5f 22 80 00       	push   $0x80225f
  800e02:	6a 23                	push   $0x23
  800e04:	68 7c 22 80 00       	push   $0x80227c
  800e09:	e8 1c f3 ff ff       	call   80012a <_panic>

00800e0e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e14:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e1b:	74 20                	je     800e3d <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	a3 08 40 80 00       	mov    %eax,0x804008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800e25:	83 ec 08             	sub    $0x8,%esp
  800e28:	68 7d 0e 80 00       	push   $0x800e7d
  800e2d:	6a 00                	push   $0x0
  800e2f:	e8 34 ff ff ff       	call   800d68 <sys_env_set_pgfault_upcall>
  800e34:	83 c4 10             	add    $0x10,%esp
  800e37:	85 c0                	test   %eax,%eax
  800e39:	78 2e                	js     800e69 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  800e3b:	c9                   	leave  
  800e3c:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800e3d:	83 ec 04             	sub    $0x4,%esp
  800e40:	6a 07                	push   $0x7
  800e42:	68 00 f0 bf ee       	push   $0xeebff000
  800e47:	6a 00                	push   $0x0
  800e49:	e8 cf fd ff ff       	call   800c1d <sys_page_alloc>
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	85 c0                	test   %eax,%eax
  800e53:	79 c8                	jns    800e1d <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  800e55:	83 ec 04             	sub    $0x4,%esp
  800e58:	68 8c 22 80 00       	push   $0x80228c
  800e5d:	6a 21                	push   $0x21
  800e5f:	68 ee 22 80 00       	push   $0x8022ee
  800e64:	e8 c1 f2 ff ff       	call   80012a <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800e69:	83 ec 04             	sub    $0x4,%esp
  800e6c:	68 b8 22 80 00       	push   $0x8022b8
  800e71:	6a 27                	push   $0x27
  800e73:	68 ee 22 80 00       	push   $0x8022ee
  800e78:	e8 ad f2 ff ff       	call   80012a <_panic>

00800e7d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e7d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e7e:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e83:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e85:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  800e88:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800e8c:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800e8f:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  800e93:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800e97:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800e99:	83 c4 08             	add    $0x8,%esp
	popal
  800e9c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800e9d:	83 c4 04             	add    $0x4,%esp
	popfl
  800ea0:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800ea1:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800ea2:	c3                   	ret    

00800ea3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	05 00 00 00 30       	add    $0x30000000,%eax
  800eae:	c1 e8 0c             	shr    $0xc,%eax
}
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ebe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ec3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ed5:	89 c2                	mov    %eax,%edx
  800ed7:	c1 ea 16             	shr    $0x16,%edx
  800eda:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee1:	f6 c2 01             	test   $0x1,%dl
  800ee4:	74 2a                	je     800f10 <fd_alloc+0x46>
  800ee6:	89 c2                	mov    %eax,%edx
  800ee8:	c1 ea 0c             	shr    $0xc,%edx
  800eeb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef2:	f6 c2 01             	test   $0x1,%dl
  800ef5:	74 19                	je     800f10 <fd_alloc+0x46>
  800ef7:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800efc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f01:	75 d2                	jne    800ed5 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f03:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f09:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f0e:	eb 07                	jmp    800f17 <fd_alloc+0x4d>
			*fd_store = fd;
  800f10:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f1f:	83 f8 1f             	cmp    $0x1f,%eax
  800f22:	77 36                	ja     800f5a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f24:	c1 e0 0c             	shl    $0xc,%eax
  800f27:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f2c:	89 c2                	mov    %eax,%edx
  800f2e:	c1 ea 16             	shr    $0x16,%edx
  800f31:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f38:	f6 c2 01             	test   $0x1,%dl
  800f3b:	74 24                	je     800f61 <fd_lookup+0x48>
  800f3d:	89 c2                	mov    %eax,%edx
  800f3f:	c1 ea 0c             	shr    $0xc,%edx
  800f42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f49:	f6 c2 01             	test   $0x1,%dl
  800f4c:	74 1a                	je     800f68 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f51:	89 02                	mov    %eax,(%edx)
	return 0;
  800f53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
		return -E_INVAL;
  800f5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5f:	eb f7                	jmp    800f58 <fd_lookup+0x3f>
		return -E_INVAL;
  800f61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f66:	eb f0                	jmp    800f58 <fd_lookup+0x3f>
  800f68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f6d:	eb e9                	jmp    800f58 <fd_lookup+0x3f>

00800f6f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f78:	ba 7c 23 80 00       	mov    $0x80237c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f7d:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f82:	39 08                	cmp    %ecx,(%eax)
  800f84:	74 33                	je     800fb9 <dev_lookup+0x4a>
  800f86:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f89:	8b 02                	mov    (%edx),%eax
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	75 f3                	jne    800f82 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f8f:	a1 04 40 80 00       	mov    0x804004,%eax
  800f94:	8b 40 48             	mov    0x48(%eax),%eax
  800f97:	83 ec 04             	sub    $0x4,%esp
  800f9a:	51                   	push   %ecx
  800f9b:	50                   	push   %eax
  800f9c:	68 fc 22 80 00       	push   $0x8022fc
  800fa1:	e8 5f f2 ff ff       	call   800205 <cprintf>
	*dev = 0;
  800fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    
			*dev = devtab[i];
  800fb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc3:	eb f2                	jmp    800fb7 <dev_lookup+0x48>

00800fc5 <fd_close>:
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	57                   	push   %edi
  800fc9:	56                   	push   %esi
  800fca:	53                   	push   %ebx
  800fcb:	83 ec 1c             	sub    $0x1c,%esp
  800fce:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fd7:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fd8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fde:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe1:	50                   	push   %eax
  800fe2:	e8 32 ff ff ff       	call   800f19 <fd_lookup>
  800fe7:	89 c3                	mov    %eax,%ebx
  800fe9:	83 c4 08             	add    $0x8,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 05                	js     800ff5 <fd_close+0x30>
	    || fd != fd2)
  800ff0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ff3:	74 16                	je     80100b <fd_close+0x46>
		return (must_exist ? r : 0);
  800ff5:	89 f8                	mov    %edi,%eax
  800ff7:	84 c0                	test   %al,%al
  800ff9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffe:	0f 44 d8             	cmove  %eax,%ebx
}
  801001:	89 d8                	mov    %ebx,%eax
  801003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801011:	50                   	push   %eax
  801012:	ff 36                	pushl  (%esi)
  801014:	e8 56 ff ff ff       	call   800f6f <dev_lookup>
  801019:	89 c3                	mov    %eax,%ebx
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	78 15                	js     801037 <fd_close+0x72>
		if (dev->dev_close)
  801022:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801025:	8b 40 10             	mov    0x10(%eax),%eax
  801028:	85 c0                	test   %eax,%eax
  80102a:	74 1b                	je     801047 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	56                   	push   %esi
  801030:	ff d0                	call   *%eax
  801032:	89 c3                	mov    %eax,%ebx
  801034:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	56                   	push   %esi
  80103b:	6a 00                	push   $0x0
  80103d:	e8 60 fc ff ff       	call   800ca2 <sys_page_unmap>
	return r;
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	eb ba                	jmp    801001 <fd_close+0x3c>
			r = 0;
  801047:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104c:	eb e9                	jmp    801037 <fd_close+0x72>

0080104e <close>:

int
close(int fdnum)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801054:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801057:	50                   	push   %eax
  801058:	ff 75 08             	pushl  0x8(%ebp)
  80105b:	e8 b9 fe ff ff       	call   800f19 <fd_lookup>
  801060:	83 c4 08             	add    $0x8,%esp
  801063:	85 c0                	test   %eax,%eax
  801065:	78 10                	js     801077 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801067:	83 ec 08             	sub    $0x8,%esp
  80106a:	6a 01                	push   $0x1
  80106c:	ff 75 f4             	pushl  -0xc(%ebp)
  80106f:	e8 51 ff ff ff       	call   800fc5 <fd_close>
  801074:	83 c4 10             	add    $0x10,%esp
}
  801077:	c9                   	leave  
  801078:	c3                   	ret    

00801079 <close_all>:

void
close_all(void)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	53                   	push   %ebx
  80107d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801080:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	53                   	push   %ebx
  801089:	e8 c0 ff ff ff       	call   80104e <close>
	for (i = 0; i < MAXFD; i++)
  80108e:	83 c3 01             	add    $0x1,%ebx
  801091:	83 c4 10             	add    $0x10,%esp
  801094:	83 fb 20             	cmp    $0x20,%ebx
  801097:	75 ec                	jne    801085 <close_all+0xc>
}
  801099:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109c:	c9                   	leave  
  80109d:	c3                   	ret    

0080109e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	57                   	push   %edi
  8010a2:	56                   	push   %esi
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010aa:	50                   	push   %eax
  8010ab:	ff 75 08             	pushl  0x8(%ebp)
  8010ae:	e8 66 fe ff ff       	call   800f19 <fd_lookup>
  8010b3:	89 c3                	mov    %eax,%ebx
  8010b5:	83 c4 08             	add    $0x8,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	0f 88 81 00 00 00    	js     801141 <dup+0xa3>
		return r;
	close(newfdnum);
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	ff 75 0c             	pushl  0xc(%ebp)
  8010c6:	e8 83 ff ff ff       	call   80104e <close>

	newfd = INDEX2FD(newfdnum);
  8010cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ce:	c1 e6 0c             	shl    $0xc,%esi
  8010d1:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010d7:	83 c4 04             	add    $0x4,%esp
  8010da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010dd:	e8 d1 fd ff ff       	call   800eb3 <fd2data>
  8010e2:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010e4:	89 34 24             	mov    %esi,(%esp)
  8010e7:	e8 c7 fd ff ff       	call   800eb3 <fd2data>
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010f1:	89 d8                	mov    %ebx,%eax
  8010f3:	c1 e8 16             	shr    $0x16,%eax
  8010f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fd:	a8 01                	test   $0x1,%al
  8010ff:	74 11                	je     801112 <dup+0x74>
  801101:	89 d8                	mov    %ebx,%eax
  801103:	c1 e8 0c             	shr    $0xc,%eax
  801106:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80110d:	f6 c2 01             	test   $0x1,%dl
  801110:	75 39                	jne    80114b <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801112:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801115:	89 d0                	mov    %edx,%eax
  801117:	c1 e8 0c             	shr    $0xc,%eax
  80111a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	25 07 0e 00 00       	and    $0xe07,%eax
  801129:	50                   	push   %eax
  80112a:	56                   	push   %esi
  80112b:	6a 00                	push   $0x0
  80112d:	52                   	push   %edx
  80112e:	6a 00                	push   $0x0
  801130:	e8 2b fb ff ff       	call   800c60 <sys_page_map>
  801135:	89 c3                	mov    %eax,%ebx
  801137:	83 c4 20             	add    $0x20,%esp
  80113a:	85 c0                	test   %eax,%eax
  80113c:	78 31                	js     80116f <dup+0xd1>
		goto err;

	return newfdnum;
  80113e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801141:	89 d8                	mov    %ebx,%eax
  801143:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801146:	5b                   	pop    %ebx
  801147:	5e                   	pop    %esi
  801148:	5f                   	pop    %edi
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80114b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801152:	83 ec 0c             	sub    $0xc,%esp
  801155:	25 07 0e 00 00       	and    $0xe07,%eax
  80115a:	50                   	push   %eax
  80115b:	57                   	push   %edi
  80115c:	6a 00                	push   $0x0
  80115e:	53                   	push   %ebx
  80115f:	6a 00                	push   $0x0
  801161:	e8 fa fa ff ff       	call   800c60 <sys_page_map>
  801166:	89 c3                	mov    %eax,%ebx
  801168:	83 c4 20             	add    $0x20,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	79 a3                	jns    801112 <dup+0x74>
	sys_page_unmap(0, newfd);
  80116f:	83 ec 08             	sub    $0x8,%esp
  801172:	56                   	push   %esi
  801173:	6a 00                	push   $0x0
  801175:	e8 28 fb ff ff       	call   800ca2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80117a:	83 c4 08             	add    $0x8,%esp
  80117d:	57                   	push   %edi
  80117e:	6a 00                	push   $0x0
  801180:	e8 1d fb ff ff       	call   800ca2 <sys_page_unmap>
	return r;
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	eb b7                	jmp    801141 <dup+0xa3>

0080118a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	53                   	push   %ebx
  80118e:	83 ec 14             	sub    $0x14,%esp
  801191:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801194:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801197:	50                   	push   %eax
  801198:	53                   	push   %ebx
  801199:	e8 7b fd ff ff       	call   800f19 <fd_lookup>
  80119e:	83 c4 08             	add    $0x8,%esp
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	78 3f                	js     8011e4 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011af:	ff 30                	pushl  (%eax)
  8011b1:	e8 b9 fd ff ff       	call   800f6f <dev_lookup>
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 27                	js     8011e4 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011c0:	8b 42 08             	mov    0x8(%edx),%eax
  8011c3:	83 e0 03             	and    $0x3,%eax
  8011c6:	83 f8 01             	cmp    $0x1,%eax
  8011c9:	74 1e                	je     8011e9 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ce:	8b 40 08             	mov    0x8(%eax),%eax
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	74 35                	je     80120a <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011d5:	83 ec 04             	sub    $0x4,%esp
  8011d8:	ff 75 10             	pushl  0x10(%ebp)
  8011db:	ff 75 0c             	pushl  0xc(%ebp)
  8011de:	52                   	push   %edx
  8011df:	ff d0                	call   *%eax
  8011e1:	83 c4 10             	add    $0x10,%esp
}
  8011e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ee:	8b 40 48             	mov    0x48(%eax),%eax
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	53                   	push   %ebx
  8011f5:	50                   	push   %eax
  8011f6:	68 40 23 80 00       	push   $0x802340
  8011fb:	e8 05 f0 ff ff       	call   800205 <cprintf>
		return -E_INVAL;
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801208:	eb da                	jmp    8011e4 <read+0x5a>
		return -E_NOT_SUPP;
  80120a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80120f:	eb d3                	jmp    8011e4 <read+0x5a>

00801211 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	83 ec 0c             	sub    $0xc,%esp
  80121a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801220:	bb 00 00 00 00       	mov    $0x0,%ebx
  801225:	39 f3                	cmp    %esi,%ebx
  801227:	73 25                	jae    80124e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	89 f0                	mov    %esi,%eax
  80122e:	29 d8                	sub    %ebx,%eax
  801230:	50                   	push   %eax
  801231:	89 d8                	mov    %ebx,%eax
  801233:	03 45 0c             	add    0xc(%ebp),%eax
  801236:	50                   	push   %eax
  801237:	57                   	push   %edi
  801238:	e8 4d ff ff ff       	call   80118a <read>
		if (m < 0)
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	85 c0                	test   %eax,%eax
  801242:	78 08                	js     80124c <readn+0x3b>
			return m;
		if (m == 0)
  801244:	85 c0                	test   %eax,%eax
  801246:	74 06                	je     80124e <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801248:	01 c3                	add    %eax,%ebx
  80124a:	eb d9                	jmp    801225 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80124c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80124e:	89 d8                	mov    %ebx,%eax
  801250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801253:	5b                   	pop    %ebx
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	53                   	push   %ebx
  80125c:	83 ec 14             	sub    $0x14,%esp
  80125f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801262:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	53                   	push   %ebx
  801267:	e8 ad fc ff ff       	call   800f19 <fd_lookup>
  80126c:	83 c4 08             	add    $0x8,%esp
  80126f:	85 c0                	test   %eax,%eax
  801271:	78 3a                	js     8012ad <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801273:	83 ec 08             	sub    $0x8,%esp
  801276:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127d:	ff 30                	pushl  (%eax)
  80127f:	e8 eb fc ff ff       	call   800f6f <dev_lookup>
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 22                	js     8012ad <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801292:	74 1e                	je     8012b2 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801294:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801297:	8b 52 0c             	mov    0xc(%edx),%edx
  80129a:	85 d2                	test   %edx,%edx
  80129c:	74 35                	je     8012d3 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80129e:	83 ec 04             	sub    $0x4,%esp
  8012a1:	ff 75 10             	pushl  0x10(%ebp)
  8012a4:	ff 75 0c             	pushl  0xc(%ebp)
  8012a7:	50                   	push   %eax
  8012a8:	ff d2                	call   *%edx
  8012aa:	83 c4 10             	add    $0x10,%esp
}
  8012ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b0:	c9                   	leave  
  8012b1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b7:	8b 40 48             	mov    0x48(%eax),%eax
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	53                   	push   %ebx
  8012be:	50                   	push   %eax
  8012bf:	68 5c 23 80 00       	push   $0x80235c
  8012c4:	e8 3c ef ff ff       	call   800205 <cprintf>
		return -E_INVAL;
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d1:	eb da                	jmp    8012ad <write+0x55>
		return -E_NOT_SUPP;
  8012d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012d8:	eb d3                	jmp    8012ad <write+0x55>

008012da <seek>:

int
seek(int fdnum, off_t offset)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	ff 75 08             	pushl  0x8(%ebp)
  8012e7:	e8 2d fc ff ff       	call   800f19 <fd_lookup>
  8012ec:	83 c4 08             	add    $0x8,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 0e                	js     801301 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	53                   	push   %ebx
  801307:	83 ec 14             	sub    $0x14,%esp
  80130a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	53                   	push   %ebx
  801312:	e8 02 fc ff ff       	call   800f19 <fd_lookup>
  801317:	83 c4 08             	add    $0x8,%esp
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 37                	js     801355 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801324:	50                   	push   %eax
  801325:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801328:	ff 30                	pushl  (%eax)
  80132a:	e8 40 fc ff ff       	call   800f6f <dev_lookup>
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	85 c0                	test   %eax,%eax
  801334:	78 1f                	js     801355 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801336:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801339:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133d:	74 1b                	je     80135a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80133f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801342:	8b 52 18             	mov    0x18(%edx),%edx
  801345:	85 d2                	test   %edx,%edx
  801347:	74 32                	je     80137b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	ff 75 0c             	pushl  0xc(%ebp)
  80134f:	50                   	push   %eax
  801350:	ff d2                	call   *%edx
  801352:	83 c4 10             	add    $0x10,%esp
}
  801355:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801358:	c9                   	leave  
  801359:	c3                   	ret    
			thisenv->env_id, fdnum);
  80135a:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80135f:	8b 40 48             	mov    0x48(%eax),%eax
  801362:	83 ec 04             	sub    $0x4,%esp
  801365:	53                   	push   %ebx
  801366:	50                   	push   %eax
  801367:	68 1c 23 80 00       	push   $0x80231c
  80136c:	e8 94 ee ff ff       	call   800205 <cprintf>
		return -E_INVAL;
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801379:	eb da                	jmp    801355 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80137b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801380:	eb d3                	jmp    801355 <ftruncate+0x52>

00801382 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	53                   	push   %ebx
  801386:	83 ec 14             	sub    $0x14,%esp
  801389:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	ff 75 08             	pushl  0x8(%ebp)
  801393:	e8 81 fb ff ff       	call   800f19 <fd_lookup>
  801398:	83 c4 08             	add    $0x8,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 4b                	js     8013ea <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a9:	ff 30                	pushl  (%eax)
  8013ab:	e8 bf fb ff ff       	call   800f6f <dev_lookup>
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 33                	js     8013ea <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8013b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ba:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013be:	74 2f                	je     8013ef <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013c3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ca:	00 00 00 
	stat->st_isdir = 0;
  8013cd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d4:	00 00 00 
	stat->st_dev = dev;
  8013d7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	53                   	push   %ebx
  8013e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e4:	ff 50 14             	call   *0x14(%eax)
  8013e7:	83 c4 10             	add    $0x10,%esp
}
  8013ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    
		return -E_NOT_SUPP;
  8013ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013f4:	eb f4                	jmp    8013ea <fstat+0x68>

008013f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	56                   	push   %esi
  8013fa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	6a 00                	push   $0x0
  801400:	ff 75 08             	pushl  0x8(%ebp)
  801403:	e8 da 01 00 00       	call   8015e2 <open>
  801408:	89 c3                	mov    %eax,%ebx
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 1b                	js     80142c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	ff 75 0c             	pushl  0xc(%ebp)
  801417:	50                   	push   %eax
  801418:	e8 65 ff ff ff       	call   801382 <fstat>
  80141d:	89 c6                	mov    %eax,%esi
	close(fd);
  80141f:	89 1c 24             	mov    %ebx,(%esp)
  801422:	e8 27 fc ff ff       	call   80104e <close>
	return r;
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	89 f3                	mov    %esi,%ebx
}
  80142c:	89 d8                	mov    %ebx,%eax
  80142e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801431:	5b                   	pop    %ebx
  801432:	5e                   	pop    %esi
  801433:	5d                   	pop    %ebp
  801434:	c3                   	ret    

00801435 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	56                   	push   %esi
  801439:	53                   	push   %ebx
  80143a:	89 c6                	mov    %eax,%esi
  80143c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80143e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801445:	74 27                	je     80146e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801447:	6a 07                	push   $0x7
  801449:	68 00 50 80 00       	push   $0x805000
  80144e:	56                   	push   %esi
  80144f:	ff 35 00 40 80 00    	pushl  0x804000
  801455:	e8 5e 07 00 00       	call   801bb8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80145a:	83 c4 0c             	add    $0xc,%esp
  80145d:	6a 00                	push   $0x0
  80145f:	53                   	push   %ebx
  801460:	6a 00                	push   $0x0
  801462:	e8 ea 06 00 00       	call   801b51 <ipc_recv>
}
  801467:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146a:	5b                   	pop    %ebx
  80146b:	5e                   	pop    %esi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80146e:	83 ec 0c             	sub    $0xc,%esp
  801471:	6a 01                	push   $0x1
  801473:	e8 94 07 00 00       	call   801c0c <ipc_find_env>
  801478:	a3 00 40 80 00       	mov    %eax,0x804000
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	eb c5                	jmp    801447 <fsipc+0x12>

00801482 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801488:	8b 45 08             	mov    0x8(%ebp),%eax
  80148b:	8b 40 0c             	mov    0xc(%eax),%eax
  80148e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801493:	8b 45 0c             	mov    0xc(%ebp),%eax
  801496:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80149b:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8014a5:	e8 8b ff ff ff       	call   801435 <fsipc>
}
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <devfile_flush>:
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8014c7:	e8 69 ff ff ff       	call   801435 <fsipc>
}
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <devfile_stat>:
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	53                   	push   %ebx
  8014d2:	83 ec 04             	sub    $0x4,%esp
  8014d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014db:	8b 40 0c             	mov    0xc(%eax),%eax
  8014de:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e8:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ed:	e8 43 ff ff ff       	call   801435 <fsipc>
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 2c                	js     801522 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	68 00 50 80 00       	push   $0x805000
  8014fe:	53                   	push   %ebx
  8014ff:	e8 20 f3 ff ff       	call   800824 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801504:	a1 80 50 80 00       	mov    0x805080,%eax
  801509:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80150f:	a1 84 50 80 00       	mov    0x805084,%eax
  801514:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <devfile_write>:
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801530:	8b 55 08             	mov    0x8(%ebp),%edx
  801533:	8b 52 0c             	mov    0xc(%edx),%edx
  801536:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  80153c:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  801541:	50                   	push   %eax
  801542:	ff 75 0c             	pushl  0xc(%ebp)
  801545:	68 08 50 80 00       	push   $0x805008
  80154a:	e8 63 f4 ff ff       	call   8009b2 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
  801554:	b8 04 00 00 00       	mov    $0x4,%eax
  801559:	e8 d7 fe ff ff       	call   801435 <fsipc>
}
  80155e:	c9                   	leave  
  80155f:	c3                   	ret    

00801560 <devfile_read>:
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	56                   	push   %esi
  801564:	53                   	push   %ebx
  801565:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801568:	8b 45 08             	mov    0x8(%ebp),%eax
  80156b:	8b 40 0c             	mov    0xc(%eax),%eax
  80156e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801573:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801579:	ba 00 00 00 00       	mov    $0x0,%edx
  80157e:	b8 03 00 00 00       	mov    $0x3,%eax
  801583:	e8 ad fe ff ff       	call   801435 <fsipc>
  801588:	89 c3                	mov    %eax,%ebx
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 1f                	js     8015ad <devfile_read+0x4d>
	assert(r <= n);
  80158e:	39 f0                	cmp    %esi,%eax
  801590:	77 24                	ja     8015b6 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801592:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801597:	7f 33                	jg     8015cc <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801599:	83 ec 04             	sub    $0x4,%esp
  80159c:	50                   	push   %eax
  80159d:	68 00 50 80 00       	push   $0x805000
  8015a2:	ff 75 0c             	pushl  0xc(%ebp)
  8015a5:	e8 08 f4 ff ff       	call   8009b2 <memmove>
	return r;
  8015aa:	83 c4 10             	add    $0x10,%esp
}
  8015ad:	89 d8                	mov    %ebx,%eax
  8015af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b2:	5b                   	pop    %ebx
  8015b3:	5e                   	pop    %esi
  8015b4:	5d                   	pop    %ebp
  8015b5:	c3                   	ret    
	assert(r <= n);
  8015b6:	68 8c 23 80 00       	push   $0x80238c
  8015bb:	68 93 23 80 00       	push   $0x802393
  8015c0:	6a 7c                	push   $0x7c
  8015c2:	68 a8 23 80 00       	push   $0x8023a8
  8015c7:	e8 5e eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  8015cc:	68 b3 23 80 00       	push   $0x8023b3
  8015d1:	68 93 23 80 00       	push   $0x802393
  8015d6:	6a 7d                	push   $0x7d
  8015d8:	68 a8 23 80 00       	push   $0x8023a8
  8015dd:	e8 48 eb ff ff       	call   80012a <_panic>

008015e2 <open>:
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	83 ec 1c             	sub    $0x1c,%esp
  8015ea:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015ed:	56                   	push   %esi
  8015ee:	e8 fa f1 ff ff       	call   8007ed <strlen>
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015fb:	7f 6c                	jg     801669 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015fd:	83 ec 0c             	sub    $0xc,%esp
  801600:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801603:	50                   	push   %eax
  801604:	e8 c1 f8 ff ff       	call   800eca <fd_alloc>
  801609:	89 c3                	mov    %eax,%ebx
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 3c                	js     80164e <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	56                   	push   %esi
  801616:	68 00 50 80 00       	push   $0x805000
  80161b:	e8 04 f2 ff ff       	call   800824 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801620:	8b 45 0c             	mov    0xc(%ebp),%eax
  801623:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801628:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162b:	b8 01 00 00 00       	mov    $0x1,%eax
  801630:	e8 00 fe ff ff       	call   801435 <fsipc>
  801635:	89 c3                	mov    %eax,%ebx
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 19                	js     801657 <open+0x75>
	return fd2num(fd);
  80163e:	83 ec 0c             	sub    $0xc,%esp
  801641:	ff 75 f4             	pushl  -0xc(%ebp)
  801644:	e8 5a f8 ff ff       	call   800ea3 <fd2num>
  801649:	89 c3                	mov    %eax,%ebx
  80164b:	83 c4 10             	add    $0x10,%esp
}
  80164e:	89 d8                	mov    %ebx,%eax
  801650:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801653:	5b                   	pop    %ebx
  801654:	5e                   	pop    %esi
  801655:	5d                   	pop    %ebp
  801656:	c3                   	ret    
		fd_close(fd, 0);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	6a 00                	push   $0x0
  80165c:	ff 75 f4             	pushl  -0xc(%ebp)
  80165f:	e8 61 f9 ff ff       	call   800fc5 <fd_close>
		return r;
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	eb e5                	jmp    80164e <open+0x6c>
		return -E_BAD_PATH;
  801669:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80166e:	eb de                	jmp    80164e <open+0x6c>

00801670 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801676:	ba 00 00 00 00       	mov    $0x0,%edx
  80167b:	b8 08 00 00 00       	mov    $0x8,%eax
  801680:	e8 b0 fd ff ff       	call   801435 <fsipc>
}
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	56                   	push   %esi
  80168b:	53                   	push   %ebx
  80168c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80168f:	83 ec 0c             	sub    $0xc,%esp
  801692:	ff 75 08             	pushl  0x8(%ebp)
  801695:	e8 19 f8 ff ff       	call   800eb3 <fd2data>
  80169a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80169c:	83 c4 08             	add    $0x8,%esp
  80169f:	68 bf 23 80 00       	push   $0x8023bf
  8016a4:	53                   	push   %ebx
  8016a5:	e8 7a f1 ff ff       	call   800824 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016aa:	8b 46 04             	mov    0x4(%esi),%eax
  8016ad:	2b 06                	sub    (%esi),%eax
  8016af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016b5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016bc:	00 00 00 
	stat->st_dev = &devpipe;
  8016bf:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016c6:	30 80 00 
	return 0;
}
  8016c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d1:	5b                   	pop    %ebx
  8016d2:	5e                   	pop    %esi
  8016d3:	5d                   	pop    %ebp
  8016d4:	c3                   	ret    

008016d5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 0c             	sub    $0xc,%esp
  8016dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016df:	53                   	push   %ebx
  8016e0:	6a 00                	push   $0x0
  8016e2:	e8 bb f5 ff ff       	call   800ca2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016e7:	89 1c 24             	mov    %ebx,(%esp)
  8016ea:	e8 c4 f7 ff ff       	call   800eb3 <fd2data>
  8016ef:	83 c4 08             	add    $0x8,%esp
  8016f2:	50                   	push   %eax
  8016f3:	6a 00                	push   $0x0
  8016f5:	e8 a8 f5 ff ff       	call   800ca2 <sys_page_unmap>
}
  8016fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <_pipeisclosed>:
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	57                   	push   %edi
  801703:	56                   	push   %esi
  801704:	53                   	push   %ebx
  801705:	83 ec 1c             	sub    $0x1c,%esp
  801708:	89 c7                	mov    %eax,%edi
  80170a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80170c:	a1 04 40 80 00       	mov    0x804004,%eax
  801711:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801714:	83 ec 0c             	sub    $0xc,%esp
  801717:	57                   	push   %edi
  801718:	e8 28 05 00 00       	call   801c45 <pageref>
  80171d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801720:	89 34 24             	mov    %esi,(%esp)
  801723:	e8 1d 05 00 00       	call   801c45 <pageref>
		nn = thisenv->env_runs;
  801728:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80172e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	39 cb                	cmp    %ecx,%ebx
  801736:	74 1b                	je     801753 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801738:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80173b:	75 cf                	jne    80170c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80173d:	8b 42 58             	mov    0x58(%edx),%eax
  801740:	6a 01                	push   $0x1
  801742:	50                   	push   %eax
  801743:	53                   	push   %ebx
  801744:	68 c6 23 80 00       	push   $0x8023c6
  801749:	e8 b7 ea ff ff       	call   800205 <cprintf>
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	eb b9                	jmp    80170c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801753:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801756:	0f 94 c0             	sete   %al
  801759:	0f b6 c0             	movzbl %al,%eax
}
  80175c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	5f                   	pop    %edi
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <devpipe_write>:
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	57                   	push   %edi
  801768:	56                   	push   %esi
  801769:	53                   	push   %ebx
  80176a:	83 ec 28             	sub    $0x28,%esp
  80176d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801770:	56                   	push   %esi
  801771:	e8 3d f7 ff ff       	call   800eb3 <fd2data>
  801776:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	bf 00 00 00 00       	mov    $0x0,%edi
  801780:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801783:	74 4f                	je     8017d4 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801785:	8b 43 04             	mov    0x4(%ebx),%eax
  801788:	8b 0b                	mov    (%ebx),%ecx
  80178a:	8d 51 20             	lea    0x20(%ecx),%edx
  80178d:	39 d0                	cmp    %edx,%eax
  80178f:	72 14                	jb     8017a5 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801791:	89 da                	mov    %ebx,%edx
  801793:	89 f0                	mov    %esi,%eax
  801795:	e8 65 ff ff ff       	call   8016ff <_pipeisclosed>
  80179a:	85 c0                	test   %eax,%eax
  80179c:	75 3a                	jne    8017d8 <devpipe_write+0x74>
			sys_yield();
  80179e:	e8 5b f4 ff ff       	call   800bfe <sys_yield>
  8017a3:	eb e0                	jmp    801785 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017ac:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017af:	89 c2                	mov    %eax,%edx
  8017b1:	c1 fa 1f             	sar    $0x1f,%edx
  8017b4:	89 d1                	mov    %edx,%ecx
  8017b6:	c1 e9 1b             	shr    $0x1b,%ecx
  8017b9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017bc:	83 e2 1f             	and    $0x1f,%edx
  8017bf:	29 ca                	sub    %ecx,%edx
  8017c1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017c5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017c9:	83 c0 01             	add    $0x1,%eax
  8017cc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017cf:	83 c7 01             	add    $0x1,%edi
  8017d2:	eb ac                	jmp    801780 <devpipe_write+0x1c>
	return i;
  8017d4:	89 f8                	mov    %edi,%eax
  8017d6:	eb 05                	jmp    8017dd <devpipe_write+0x79>
				return 0;
  8017d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e0:	5b                   	pop    %ebx
  8017e1:	5e                   	pop    %esi
  8017e2:	5f                   	pop    %edi
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <devpipe_read>:
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	57                   	push   %edi
  8017e9:	56                   	push   %esi
  8017ea:	53                   	push   %ebx
  8017eb:	83 ec 18             	sub    $0x18,%esp
  8017ee:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017f1:	57                   	push   %edi
  8017f2:	e8 bc f6 ff ff       	call   800eb3 <fd2data>
  8017f7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	be 00 00 00 00       	mov    $0x0,%esi
  801801:	3b 75 10             	cmp    0x10(%ebp),%esi
  801804:	74 47                	je     80184d <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801806:	8b 03                	mov    (%ebx),%eax
  801808:	3b 43 04             	cmp    0x4(%ebx),%eax
  80180b:	75 22                	jne    80182f <devpipe_read+0x4a>
			if (i > 0)
  80180d:	85 f6                	test   %esi,%esi
  80180f:	75 14                	jne    801825 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801811:	89 da                	mov    %ebx,%edx
  801813:	89 f8                	mov    %edi,%eax
  801815:	e8 e5 fe ff ff       	call   8016ff <_pipeisclosed>
  80181a:	85 c0                	test   %eax,%eax
  80181c:	75 33                	jne    801851 <devpipe_read+0x6c>
			sys_yield();
  80181e:	e8 db f3 ff ff       	call   800bfe <sys_yield>
  801823:	eb e1                	jmp    801806 <devpipe_read+0x21>
				return i;
  801825:	89 f0                	mov    %esi,%eax
}
  801827:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182a:	5b                   	pop    %ebx
  80182b:	5e                   	pop    %esi
  80182c:	5f                   	pop    %edi
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80182f:	99                   	cltd   
  801830:	c1 ea 1b             	shr    $0x1b,%edx
  801833:	01 d0                	add    %edx,%eax
  801835:	83 e0 1f             	and    $0x1f,%eax
  801838:	29 d0                	sub    %edx,%eax
  80183a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80183f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801842:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801845:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801848:	83 c6 01             	add    $0x1,%esi
  80184b:	eb b4                	jmp    801801 <devpipe_read+0x1c>
	return i;
  80184d:	89 f0                	mov    %esi,%eax
  80184f:	eb d6                	jmp    801827 <devpipe_read+0x42>
				return 0;
  801851:	b8 00 00 00 00       	mov    $0x0,%eax
  801856:	eb cf                	jmp    801827 <devpipe_read+0x42>

00801858 <pipe>:
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	56                   	push   %esi
  80185c:	53                   	push   %ebx
  80185d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801860:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801863:	50                   	push   %eax
  801864:	e8 61 f6 ff ff       	call   800eca <fd_alloc>
  801869:	89 c3                	mov    %eax,%ebx
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 5b                	js     8018cd <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801872:	83 ec 04             	sub    $0x4,%esp
  801875:	68 07 04 00 00       	push   $0x407
  80187a:	ff 75 f4             	pushl  -0xc(%ebp)
  80187d:	6a 00                	push   $0x0
  80187f:	e8 99 f3 ff ff       	call   800c1d <sys_page_alloc>
  801884:	89 c3                	mov    %eax,%ebx
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 40                	js     8018cd <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  80188d:	83 ec 0c             	sub    $0xc,%esp
  801890:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801893:	50                   	push   %eax
  801894:	e8 31 f6 ff ff       	call   800eca <fd_alloc>
  801899:	89 c3                	mov    %eax,%ebx
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	78 1b                	js     8018bd <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a2:	83 ec 04             	sub    $0x4,%esp
  8018a5:	68 07 04 00 00       	push   $0x407
  8018aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ad:	6a 00                	push   $0x0
  8018af:	e8 69 f3 ff ff       	call   800c1d <sys_page_alloc>
  8018b4:	89 c3                	mov    %eax,%ebx
  8018b6:	83 c4 10             	add    $0x10,%esp
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	79 19                	jns    8018d6 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8018bd:	83 ec 08             	sub    $0x8,%esp
  8018c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c3:	6a 00                	push   $0x0
  8018c5:	e8 d8 f3 ff ff       	call   800ca2 <sys_page_unmap>
  8018ca:	83 c4 10             	add    $0x10,%esp
}
  8018cd:	89 d8                	mov    %ebx,%eax
  8018cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d2:	5b                   	pop    %ebx
  8018d3:	5e                   	pop    %esi
  8018d4:	5d                   	pop    %ebp
  8018d5:	c3                   	ret    
	va = fd2data(fd0);
  8018d6:	83 ec 0c             	sub    $0xc,%esp
  8018d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018dc:	e8 d2 f5 ff ff       	call   800eb3 <fd2data>
  8018e1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e3:	83 c4 0c             	add    $0xc,%esp
  8018e6:	68 07 04 00 00       	push   $0x407
  8018eb:	50                   	push   %eax
  8018ec:	6a 00                	push   $0x0
  8018ee:	e8 2a f3 ff ff       	call   800c1d <sys_page_alloc>
  8018f3:	89 c3                	mov    %eax,%ebx
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	0f 88 8c 00 00 00    	js     80198c <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801900:	83 ec 0c             	sub    $0xc,%esp
  801903:	ff 75 f0             	pushl  -0x10(%ebp)
  801906:	e8 a8 f5 ff ff       	call   800eb3 <fd2data>
  80190b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801912:	50                   	push   %eax
  801913:	6a 00                	push   $0x0
  801915:	56                   	push   %esi
  801916:	6a 00                	push   $0x0
  801918:	e8 43 f3 ff ff       	call   800c60 <sys_page_map>
  80191d:	89 c3                	mov    %eax,%ebx
  80191f:	83 c4 20             	add    $0x20,%esp
  801922:	85 c0                	test   %eax,%eax
  801924:	78 58                	js     80197e <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801926:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801929:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80192f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801931:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801934:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80193b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801944:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801946:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801949:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801950:	83 ec 0c             	sub    $0xc,%esp
  801953:	ff 75 f4             	pushl  -0xc(%ebp)
  801956:	e8 48 f5 ff ff       	call   800ea3 <fd2num>
  80195b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801960:	83 c4 04             	add    $0x4,%esp
  801963:	ff 75 f0             	pushl  -0x10(%ebp)
  801966:	e8 38 f5 ff ff       	call   800ea3 <fd2num>
  80196b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80196e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	bb 00 00 00 00       	mov    $0x0,%ebx
  801979:	e9 4f ff ff ff       	jmp    8018cd <pipe+0x75>
	sys_page_unmap(0, va);
  80197e:	83 ec 08             	sub    $0x8,%esp
  801981:	56                   	push   %esi
  801982:	6a 00                	push   $0x0
  801984:	e8 19 f3 ff ff       	call   800ca2 <sys_page_unmap>
  801989:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80198c:	83 ec 08             	sub    $0x8,%esp
  80198f:	ff 75 f0             	pushl  -0x10(%ebp)
  801992:	6a 00                	push   $0x0
  801994:	e8 09 f3 ff ff       	call   800ca2 <sys_page_unmap>
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	e9 1c ff ff ff       	jmp    8018bd <pipe+0x65>

008019a1 <pipeisclosed>:
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019aa:	50                   	push   %eax
  8019ab:	ff 75 08             	pushl  0x8(%ebp)
  8019ae:	e8 66 f5 ff ff       	call   800f19 <fd_lookup>
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 18                	js     8019d2 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8019ba:	83 ec 0c             	sub    $0xc,%esp
  8019bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c0:	e8 ee f4 ff ff       	call   800eb3 <fd2data>
	return _pipeisclosed(fd, p);
  8019c5:	89 c2                	mov    %eax,%edx
  8019c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ca:	e8 30 fd ff ff       	call   8016ff <_pipeisclosed>
  8019cf:	83 c4 10             	add    $0x10,%esp
}
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019e4:	68 de 23 80 00       	push   $0x8023de
  8019e9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ec:	e8 33 ee ff ff       	call   800824 <strcpy>
	return 0;
}
  8019f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <devcons_write>:
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	57                   	push   %edi
  8019fc:	56                   	push   %esi
  8019fd:	53                   	push   %ebx
  8019fe:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a04:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a09:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a0f:	eb 2f                	jmp    801a40 <devcons_write+0x48>
		m = n - tot;
  801a11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a14:	29 f3                	sub    %esi,%ebx
  801a16:	83 fb 7f             	cmp    $0x7f,%ebx
  801a19:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a1e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a21:	83 ec 04             	sub    $0x4,%esp
  801a24:	53                   	push   %ebx
  801a25:	89 f0                	mov    %esi,%eax
  801a27:	03 45 0c             	add    0xc(%ebp),%eax
  801a2a:	50                   	push   %eax
  801a2b:	57                   	push   %edi
  801a2c:	e8 81 ef ff ff       	call   8009b2 <memmove>
		sys_cputs(buf, m);
  801a31:	83 c4 08             	add    $0x8,%esp
  801a34:	53                   	push   %ebx
  801a35:	57                   	push   %edi
  801a36:	e8 26 f1 ff ff       	call   800b61 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a3b:	01 de                	add    %ebx,%esi
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a43:	72 cc                	jb     801a11 <devcons_write+0x19>
}
  801a45:	89 f0                	mov    %esi,%eax
  801a47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4a:	5b                   	pop    %ebx
  801a4b:	5e                   	pop    %esi
  801a4c:	5f                   	pop    %edi
  801a4d:	5d                   	pop    %ebp
  801a4e:	c3                   	ret    

00801a4f <devcons_read>:
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	83 ec 08             	sub    $0x8,%esp
  801a55:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a5e:	75 07                	jne    801a67 <devcons_read+0x18>
}
  801a60:	c9                   	leave  
  801a61:	c3                   	ret    
		sys_yield();
  801a62:	e8 97 f1 ff ff       	call   800bfe <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a67:	e8 13 f1 ff ff       	call   800b7f <sys_cgetc>
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	74 f2                	je     801a62 <devcons_read+0x13>
	if (c < 0)
  801a70:	85 c0                	test   %eax,%eax
  801a72:	78 ec                	js     801a60 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801a74:	83 f8 04             	cmp    $0x4,%eax
  801a77:	74 0c                	je     801a85 <devcons_read+0x36>
	*(char*)vbuf = c;
  801a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a7c:	88 02                	mov    %al,(%edx)
	return 1;
  801a7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801a83:	eb db                	jmp    801a60 <devcons_read+0x11>
		return 0;
  801a85:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8a:	eb d4                	jmp    801a60 <devcons_read+0x11>

00801a8c <cputchar>:
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a98:	6a 01                	push   $0x1
  801a9a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a9d:	50                   	push   %eax
  801a9e:	e8 be f0 ff ff       	call   800b61 <sys_cputs>
}
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <getchar>:
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801aae:	6a 01                	push   $0x1
  801ab0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ab3:	50                   	push   %eax
  801ab4:	6a 00                	push   $0x0
  801ab6:	e8 cf f6 ff ff       	call   80118a <read>
	if (r < 0)
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	78 08                	js     801aca <getchar+0x22>
	if (r < 1)
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	7e 06                	jle    801acc <getchar+0x24>
	return c;
  801ac6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    
		return -E_EOF;
  801acc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ad1:	eb f7                	jmp    801aca <getchar+0x22>

00801ad3 <iscons>:
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ad9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801adc:	50                   	push   %eax
  801add:	ff 75 08             	pushl  0x8(%ebp)
  801ae0:	e8 34 f4 ff ff       	call   800f19 <fd_lookup>
  801ae5:	83 c4 10             	add    $0x10,%esp
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	78 11                	js     801afd <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aef:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af5:	39 10                	cmp    %edx,(%eax)
  801af7:	0f 94 c0             	sete   %al
  801afa:	0f b6 c0             	movzbl %al,%eax
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <opencons>:
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b08:	50                   	push   %eax
  801b09:	e8 bc f3 ff ff       	call   800eca <fd_alloc>
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	85 c0                	test   %eax,%eax
  801b13:	78 3a                	js     801b4f <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b15:	83 ec 04             	sub    $0x4,%esp
  801b18:	68 07 04 00 00       	push   $0x407
  801b1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b20:	6a 00                	push   $0x0
  801b22:	e8 f6 f0 ff ff       	call   800c1d <sys_page_alloc>
  801b27:	83 c4 10             	add    $0x10,%esp
  801b2a:	85 c0                	test   %eax,%eax
  801b2c:	78 21                	js     801b4f <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b31:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b37:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b43:	83 ec 0c             	sub    $0xc,%esp
  801b46:	50                   	push   %eax
  801b47:	e8 57 f3 ff ff       	call   800ea3 <fd2num>
  801b4c:	83 c4 10             	add    $0x10,%esp
}
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	8b 75 08             	mov    0x8(%ebp),%esi
  801b59:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801b5f:	85 f6                	test   %esi,%esi
  801b61:	74 06                	je     801b69 <ipc_recv+0x18>
  801b63:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801b69:	85 db                	test   %ebx,%ebx
  801b6b:	74 06                	je     801b73 <ipc_recv+0x22>
  801b6d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801b73:	85 c0                	test   %eax,%eax
  801b75:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b7a:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801b7d:	83 ec 0c             	sub    $0xc,%esp
  801b80:	50                   	push   %eax
  801b81:	e8 47 f2 ff ff       	call   800dcd <sys_ipc_recv>
	if (ret) return ret;
  801b86:	83 c4 10             	add    $0x10,%esp
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	75 24                	jne    801bb1 <ipc_recv+0x60>
	if (from_env_store)
  801b8d:	85 f6                	test   %esi,%esi
  801b8f:	74 0a                	je     801b9b <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801b91:	a1 04 40 80 00       	mov    0x804004,%eax
  801b96:	8b 40 74             	mov    0x74(%eax),%eax
  801b99:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801b9b:	85 db                	test   %ebx,%ebx
  801b9d:	74 0a                	je     801ba9 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801b9f:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba4:	8b 40 78             	mov    0x78(%eax),%eax
  801ba7:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801ba9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bae:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb4:	5b                   	pop    %ebx
  801bb5:	5e                   	pop    %esi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    

00801bb8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	57                   	push   %edi
  801bbc:	56                   	push   %esi
  801bbd:	53                   	push   %ebx
  801bbe:	83 ec 0c             	sub    $0xc,%esp
  801bc1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bc4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801bca:	85 db                	test   %ebx,%ebx
  801bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bd1:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801bd4:	ff 75 14             	pushl  0x14(%ebp)
  801bd7:	53                   	push   %ebx
  801bd8:	56                   	push   %esi
  801bd9:	57                   	push   %edi
  801bda:	e8 cb f1 ff ff       	call   800daa <sys_ipc_try_send>
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	85 c0                	test   %eax,%eax
  801be4:	74 1e                	je     801c04 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801be6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801be9:	75 07                	jne    801bf2 <ipc_send+0x3a>
		sys_yield();
  801beb:	e8 0e f0 ff ff       	call   800bfe <sys_yield>
  801bf0:	eb e2                	jmp    801bd4 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801bf2:	50                   	push   %eax
  801bf3:	68 ea 23 80 00       	push   $0x8023ea
  801bf8:	6a 36                	push   $0x36
  801bfa:	68 01 24 80 00       	push   $0x802401
  801bff:	e8 26 e5 ff ff       	call   80012a <_panic>
	}
}
  801c04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c07:	5b                   	pop    %ebx
  801c08:	5e                   	pop    %esi
  801c09:	5f                   	pop    %edi
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    

00801c0c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c12:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c17:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c1a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c20:	8b 52 50             	mov    0x50(%edx),%edx
  801c23:	39 ca                	cmp    %ecx,%edx
  801c25:	74 11                	je     801c38 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801c27:	83 c0 01             	add    $0x1,%eax
  801c2a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c2f:	75 e6                	jne    801c17 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801c31:	b8 00 00 00 00       	mov    $0x0,%eax
  801c36:	eb 0b                	jmp    801c43 <ipc_find_env+0x37>
			return envs[i].env_id;
  801c38:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c3b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c40:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c4b:	89 d0                	mov    %edx,%eax
  801c4d:	c1 e8 16             	shr    $0x16,%eax
  801c50:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c57:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801c5c:	f6 c1 01             	test   $0x1,%cl
  801c5f:	74 1d                	je     801c7e <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801c61:	c1 ea 0c             	shr    $0xc,%edx
  801c64:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c6b:	f6 c2 01             	test   $0x1,%dl
  801c6e:	74 0e                	je     801c7e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c70:	c1 ea 0c             	shr    $0xc,%edx
  801c73:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c7a:	ef 
  801c7b:	0f b7 c0             	movzwl %ax,%eax
}
  801c7e:	5d                   	pop    %ebp
  801c7f:	c3                   	ret    

00801c80 <__udivdi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c8b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c93:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c97:	85 d2                	test   %edx,%edx
  801c99:	75 35                	jne    801cd0 <__udivdi3+0x50>
  801c9b:	39 f3                	cmp    %esi,%ebx
  801c9d:	0f 87 bd 00 00 00    	ja     801d60 <__udivdi3+0xe0>
  801ca3:	85 db                	test   %ebx,%ebx
  801ca5:	89 d9                	mov    %ebx,%ecx
  801ca7:	75 0b                	jne    801cb4 <__udivdi3+0x34>
  801ca9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cae:	31 d2                	xor    %edx,%edx
  801cb0:	f7 f3                	div    %ebx
  801cb2:	89 c1                	mov    %eax,%ecx
  801cb4:	31 d2                	xor    %edx,%edx
  801cb6:	89 f0                	mov    %esi,%eax
  801cb8:	f7 f1                	div    %ecx
  801cba:	89 c6                	mov    %eax,%esi
  801cbc:	89 e8                	mov    %ebp,%eax
  801cbe:	89 f7                	mov    %esi,%edi
  801cc0:	f7 f1                	div    %ecx
  801cc2:	89 fa                	mov    %edi,%edx
  801cc4:	83 c4 1c             	add    $0x1c,%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    
  801ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	39 f2                	cmp    %esi,%edx
  801cd2:	77 7c                	ja     801d50 <__udivdi3+0xd0>
  801cd4:	0f bd fa             	bsr    %edx,%edi
  801cd7:	83 f7 1f             	xor    $0x1f,%edi
  801cda:	0f 84 98 00 00 00    	je     801d78 <__udivdi3+0xf8>
  801ce0:	89 f9                	mov    %edi,%ecx
  801ce2:	b8 20 00 00 00       	mov    $0x20,%eax
  801ce7:	29 f8                	sub    %edi,%eax
  801ce9:	d3 e2                	shl    %cl,%edx
  801ceb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cef:	89 c1                	mov    %eax,%ecx
  801cf1:	89 da                	mov    %ebx,%edx
  801cf3:	d3 ea                	shr    %cl,%edx
  801cf5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801cf9:	09 d1                	or     %edx,%ecx
  801cfb:	89 f2                	mov    %esi,%edx
  801cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	d3 e3                	shl    %cl,%ebx
  801d05:	89 c1                	mov    %eax,%ecx
  801d07:	d3 ea                	shr    %cl,%edx
  801d09:	89 f9                	mov    %edi,%ecx
  801d0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d0f:	d3 e6                	shl    %cl,%esi
  801d11:	89 eb                	mov    %ebp,%ebx
  801d13:	89 c1                	mov    %eax,%ecx
  801d15:	d3 eb                	shr    %cl,%ebx
  801d17:	09 de                	or     %ebx,%esi
  801d19:	89 f0                	mov    %esi,%eax
  801d1b:	f7 74 24 08          	divl   0x8(%esp)
  801d1f:	89 d6                	mov    %edx,%esi
  801d21:	89 c3                	mov    %eax,%ebx
  801d23:	f7 64 24 0c          	mull   0xc(%esp)
  801d27:	39 d6                	cmp    %edx,%esi
  801d29:	72 0c                	jb     801d37 <__udivdi3+0xb7>
  801d2b:	89 f9                	mov    %edi,%ecx
  801d2d:	d3 e5                	shl    %cl,%ebp
  801d2f:	39 c5                	cmp    %eax,%ebp
  801d31:	73 5d                	jae    801d90 <__udivdi3+0x110>
  801d33:	39 d6                	cmp    %edx,%esi
  801d35:	75 59                	jne    801d90 <__udivdi3+0x110>
  801d37:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d3a:	31 ff                	xor    %edi,%edi
  801d3c:	89 fa                	mov    %edi,%edx
  801d3e:	83 c4 1c             	add    $0x1c,%esp
  801d41:	5b                   	pop    %ebx
  801d42:	5e                   	pop    %esi
  801d43:	5f                   	pop    %edi
  801d44:	5d                   	pop    %ebp
  801d45:	c3                   	ret    
  801d46:	8d 76 00             	lea    0x0(%esi),%esi
  801d49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d50:	31 ff                	xor    %edi,%edi
  801d52:	31 c0                	xor    %eax,%eax
  801d54:	89 fa                	mov    %edi,%edx
  801d56:	83 c4 1c             	add    $0x1c,%esp
  801d59:	5b                   	pop    %ebx
  801d5a:	5e                   	pop    %esi
  801d5b:	5f                   	pop    %edi
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    
  801d5e:	66 90                	xchg   %ax,%ax
  801d60:	31 ff                	xor    %edi,%edi
  801d62:	89 e8                	mov    %ebp,%eax
  801d64:	89 f2                	mov    %esi,%edx
  801d66:	f7 f3                	div    %ebx
  801d68:	89 fa                	mov    %edi,%edx
  801d6a:	83 c4 1c             	add    $0x1c,%esp
  801d6d:	5b                   	pop    %ebx
  801d6e:	5e                   	pop    %esi
  801d6f:	5f                   	pop    %edi
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    
  801d72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d78:	39 f2                	cmp    %esi,%edx
  801d7a:	72 06                	jb     801d82 <__udivdi3+0x102>
  801d7c:	31 c0                	xor    %eax,%eax
  801d7e:	39 eb                	cmp    %ebp,%ebx
  801d80:	77 d2                	ja     801d54 <__udivdi3+0xd4>
  801d82:	b8 01 00 00 00       	mov    $0x1,%eax
  801d87:	eb cb                	jmp    801d54 <__udivdi3+0xd4>
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	89 d8                	mov    %ebx,%eax
  801d92:	31 ff                	xor    %edi,%edi
  801d94:	eb be                	jmp    801d54 <__udivdi3+0xd4>
  801d96:	66 90                	xchg   %ax,%ax
  801d98:	66 90                	xchg   %ax,%ax
  801d9a:	66 90                	xchg   %ax,%ax
  801d9c:	66 90                	xchg   %ax,%ax
  801d9e:	66 90                	xchg   %ax,%ax

00801da0 <__umoddi3>:
  801da0:	55                   	push   %ebp
  801da1:	57                   	push   %edi
  801da2:	56                   	push   %esi
  801da3:	53                   	push   %ebx
  801da4:	83 ec 1c             	sub    $0x1c,%esp
  801da7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801dab:	8b 74 24 30          	mov    0x30(%esp),%esi
  801daf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801db7:	85 ed                	test   %ebp,%ebp
  801db9:	89 f0                	mov    %esi,%eax
  801dbb:	89 da                	mov    %ebx,%edx
  801dbd:	75 19                	jne    801dd8 <__umoddi3+0x38>
  801dbf:	39 df                	cmp    %ebx,%edi
  801dc1:	0f 86 b1 00 00 00    	jbe    801e78 <__umoddi3+0xd8>
  801dc7:	f7 f7                	div    %edi
  801dc9:	89 d0                	mov    %edx,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	83 c4 1c             	add    $0x1c,%esp
  801dd0:	5b                   	pop    %ebx
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    
  801dd5:	8d 76 00             	lea    0x0(%esi),%esi
  801dd8:	39 dd                	cmp    %ebx,%ebp
  801dda:	77 f1                	ja     801dcd <__umoddi3+0x2d>
  801ddc:	0f bd cd             	bsr    %ebp,%ecx
  801ddf:	83 f1 1f             	xor    $0x1f,%ecx
  801de2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801de6:	0f 84 b4 00 00 00    	je     801ea0 <__umoddi3+0x100>
  801dec:	b8 20 00 00 00       	mov    $0x20,%eax
  801df1:	89 c2                	mov    %eax,%edx
  801df3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801df7:	29 c2                	sub    %eax,%edx
  801df9:	89 c1                	mov    %eax,%ecx
  801dfb:	89 f8                	mov    %edi,%eax
  801dfd:	d3 e5                	shl    %cl,%ebp
  801dff:	89 d1                	mov    %edx,%ecx
  801e01:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e05:	d3 e8                	shr    %cl,%eax
  801e07:	09 c5                	or     %eax,%ebp
  801e09:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e0d:	89 c1                	mov    %eax,%ecx
  801e0f:	d3 e7                	shl    %cl,%edi
  801e11:	89 d1                	mov    %edx,%ecx
  801e13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e17:	89 df                	mov    %ebx,%edi
  801e19:	d3 ef                	shr    %cl,%edi
  801e1b:	89 c1                	mov    %eax,%ecx
  801e1d:	89 f0                	mov    %esi,%eax
  801e1f:	d3 e3                	shl    %cl,%ebx
  801e21:	89 d1                	mov    %edx,%ecx
  801e23:	89 fa                	mov    %edi,%edx
  801e25:	d3 e8                	shr    %cl,%eax
  801e27:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e2c:	09 d8                	or     %ebx,%eax
  801e2e:	f7 f5                	div    %ebp
  801e30:	d3 e6                	shl    %cl,%esi
  801e32:	89 d1                	mov    %edx,%ecx
  801e34:	f7 64 24 08          	mull   0x8(%esp)
  801e38:	39 d1                	cmp    %edx,%ecx
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	89 d7                	mov    %edx,%edi
  801e3e:	72 06                	jb     801e46 <__umoddi3+0xa6>
  801e40:	75 0e                	jne    801e50 <__umoddi3+0xb0>
  801e42:	39 c6                	cmp    %eax,%esi
  801e44:	73 0a                	jae    801e50 <__umoddi3+0xb0>
  801e46:	2b 44 24 08          	sub    0x8(%esp),%eax
  801e4a:	19 ea                	sbb    %ebp,%edx
  801e4c:	89 d7                	mov    %edx,%edi
  801e4e:	89 c3                	mov    %eax,%ebx
  801e50:	89 ca                	mov    %ecx,%edx
  801e52:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801e57:	29 de                	sub    %ebx,%esi
  801e59:	19 fa                	sbb    %edi,%edx
  801e5b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801e5f:	89 d0                	mov    %edx,%eax
  801e61:	d3 e0                	shl    %cl,%eax
  801e63:	89 d9                	mov    %ebx,%ecx
  801e65:	d3 ee                	shr    %cl,%esi
  801e67:	d3 ea                	shr    %cl,%edx
  801e69:	09 f0                	or     %esi,%eax
  801e6b:	83 c4 1c             	add    $0x1c,%esp
  801e6e:	5b                   	pop    %ebx
  801e6f:	5e                   	pop    %esi
  801e70:	5f                   	pop    %edi
  801e71:	5d                   	pop    %ebp
  801e72:	c3                   	ret    
  801e73:	90                   	nop
  801e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e78:	85 ff                	test   %edi,%edi
  801e7a:	89 f9                	mov    %edi,%ecx
  801e7c:	75 0b                	jne    801e89 <__umoddi3+0xe9>
  801e7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e83:	31 d2                	xor    %edx,%edx
  801e85:	f7 f7                	div    %edi
  801e87:	89 c1                	mov    %eax,%ecx
  801e89:	89 d8                	mov    %ebx,%eax
  801e8b:	31 d2                	xor    %edx,%edx
  801e8d:	f7 f1                	div    %ecx
  801e8f:	89 f0                	mov    %esi,%eax
  801e91:	f7 f1                	div    %ecx
  801e93:	e9 31 ff ff ff       	jmp    801dc9 <__umoddi3+0x29>
  801e98:	90                   	nop
  801e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ea0:	39 dd                	cmp    %ebx,%ebp
  801ea2:	72 08                	jb     801eac <__umoddi3+0x10c>
  801ea4:	39 f7                	cmp    %esi,%edi
  801ea6:	0f 87 21 ff ff ff    	ja     801dcd <__umoddi3+0x2d>
  801eac:	89 da                	mov    %ebx,%edx
  801eae:	89 f0                	mov    %esi,%eax
  801eb0:	29 f8                	sub    %edi,%eax
  801eb2:	19 ea                	sbb    %ebp,%edx
  801eb4:	e9 14 ff ff ff       	jmp    801dcd <__umoddi3+0x2d>
