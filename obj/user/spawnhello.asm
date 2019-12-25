
obj/user/spawnhello.debug：     文件格式 elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 c0 23 80 00       	push   $0x8023c0
  800047:	e8 6a 01 00 00       	call   8001b6 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 de 23 80 00       	push   $0x8023de
  800056:	68 de 23 80 00       	push   $0x8023de
  80005b:	e8 aa 1a 00 00       	call   801b0a <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	78 02                	js     800069 <umain+0x36>
		panic("spawn(hello) failed: %e", r);
}
  800067:	c9                   	leave  
  800068:	c3                   	ret    
		panic("spawn(hello) failed: %e", r);
  800069:	50                   	push   %eax
  80006a:	68 e4 23 80 00       	push   $0x8023e4
  80006f:	6a 09                	push   $0x9
  800071:	68 fc 23 80 00       	push   $0x8023fc
  800076:	e8 60 00 00 00       	call   8000db <_panic>

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800086:	e8 05 0b 00 00       	call   800b90 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 c9 0e 00 00       	call   800f95 <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 79 0a 00 00       	call   800b4f <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 a2 0a 00 00       	call   800b90 <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 18 24 80 00       	push   $0x802418
  8000fe:	e8 b3 00 00 00       	call   8001b6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 56 00 00 00       	call   800165 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 e0 28 80 00 	movl   $0x8028e0,(%esp)
  800116:	e8 9b 00 00 00       	call   8001b6 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	74 09                	je     800149 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800140:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800144:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800147:	c9                   	leave  
  800148:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800149:	83 ec 08             	sub    $0x8,%esp
  80014c:	68 ff 00 00 00       	push   $0xff
  800151:	8d 43 08             	lea    0x8(%ebx),%eax
  800154:	50                   	push   %eax
  800155:	e8 b8 09 00 00       	call   800b12 <sys_cputs>
		b->idx = 0;
  80015a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800160:	83 c4 10             	add    $0x10,%esp
  800163:	eb db                	jmp    800140 <putch+0x1f>

00800165 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800175:	00 00 00 
	b.cnt = 0;
  800178:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800182:	ff 75 0c             	pushl  0xc(%ebp)
  800185:	ff 75 08             	pushl  0x8(%ebp)
  800188:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018e:	50                   	push   %eax
  80018f:	68 21 01 80 00       	push   $0x800121
  800194:	e8 1a 01 00 00       	call   8002b3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800199:	83 c4 08             	add    $0x8,%esp
  80019c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 64 09 00 00       	call   800b12 <sys_cputs>

	return b.cnt;
}
  8001ae:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bf:	50                   	push   %eax
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	e8 9d ff ff ff       	call   800165 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    

008001ca <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	57                   	push   %edi
  8001ce:	56                   	push   %esi
  8001cf:	53                   	push   %ebx
  8001d0:	83 ec 1c             	sub    $0x1c,%esp
  8001d3:	89 c7                	mov    %eax,%edi
  8001d5:	89 d6                	mov    %edx,%esi
  8001d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001eb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ee:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f1:	39 d3                	cmp    %edx,%ebx
  8001f3:	72 05                	jb     8001fa <printnum+0x30>
  8001f5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f8:	77 7a                	ja     800274 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	ff 75 18             	pushl  0x18(%ebp)
  800200:	8b 45 14             	mov    0x14(%ebp),%eax
  800203:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800206:	53                   	push   %ebx
  800207:	ff 75 10             	pushl  0x10(%ebp)
  80020a:	83 ec 08             	sub    $0x8,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 62 1f 00 00       	call   802180 <__udivdi3>
  80021e:	83 c4 18             	add    $0x18,%esp
  800221:	52                   	push   %edx
  800222:	50                   	push   %eax
  800223:	89 f2                	mov    %esi,%edx
  800225:	89 f8                	mov    %edi,%eax
  800227:	e8 9e ff ff ff       	call   8001ca <printnum>
  80022c:	83 c4 20             	add    $0x20,%esp
  80022f:	eb 13                	jmp    800244 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800231:	83 ec 08             	sub    $0x8,%esp
  800234:	56                   	push   %esi
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	ff d7                	call   *%edi
  80023a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f ed                	jg     800231 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 44 20 00 00       	call   8022a0 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 3b 24 80 00 	movsbl 0x80243b(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    
  800274:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800277:	eb c4                	jmp    80023d <printnum+0x73>

00800279 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800283:	8b 10                	mov    (%eax),%edx
  800285:	3b 50 04             	cmp    0x4(%eax),%edx
  800288:	73 0a                	jae    800294 <sprintputch+0x1b>
		*b->buf++ = ch;
  80028a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028d:	89 08                	mov    %ecx,(%eax)
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	88 02                	mov    %al,(%edx)
}
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <printfmt>:
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80029c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029f:	50                   	push   %eax
  8002a0:	ff 75 10             	pushl  0x10(%ebp)
  8002a3:	ff 75 0c             	pushl  0xc(%ebp)
  8002a6:	ff 75 08             	pushl  0x8(%ebp)
  8002a9:	e8 05 00 00 00       	call   8002b3 <vprintfmt>
}
  8002ae:	83 c4 10             	add    $0x10,%esp
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    

008002b3 <vprintfmt>:
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	83 ec 2c             	sub    $0x2c,%esp
  8002bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8002bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c5:	e9 c1 03 00 00       	jmp    80068b <vprintfmt+0x3d8>
		padc = ' ';
  8002ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002e8:	8d 47 01             	lea    0x1(%edi),%eax
  8002eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ee:	0f b6 17             	movzbl (%edi),%edx
  8002f1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f4:	3c 55                	cmp    $0x55,%al
  8002f6:	0f 87 12 04 00 00    	ja     80070e <vprintfmt+0x45b>
  8002fc:	0f b6 c0             	movzbl %al,%eax
  8002ff:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800309:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80030d:	eb d9                	jmp    8002e8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80030f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800312:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800316:	eb d0                	jmp    8002e8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800318:	0f b6 d2             	movzbl %dl,%edx
  80031b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800326:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800329:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80032d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800330:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800333:	83 f9 09             	cmp    $0x9,%ecx
  800336:	77 55                	ja     80038d <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800338:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80033b:	eb e9                	jmp    800326 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80033d:	8b 45 14             	mov    0x14(%ebp),%eax
  800340:	8b 00                	mov    (%eax),%eax
  800342:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800345:	8b 45 14             	mov    0x14(%ebp),%eax
  800348:	8d 40 04             	lea    0x4(%eax),%eax
  80034b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800351:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800355:	79 91                	jns    8002e8 <vprintfmt+0x35>
				width = precision, precision = -1;
  800357:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80035a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800364:	eb 82                	jmp    8002e8 <vprintfmt+0x35>
  800366:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800369:	85 c0                	test   %eax,%eax
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
  800370:	0f 49 d0             	cmovns %eax,%edx
  800373:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800379:	e9 6a ff ff ff       	jmp    8002e8 <vprintfmt+0x35>
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800381:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800388:	e9 5b ff ff ff       	jmp    8002e8 <vprintfmt+0x35>
  80038d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800390:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800393:	eb bc                	jmp    800351 <vprintfmt+0x9e>
			lflag++;
  800395:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039b:	e9 48 ff ff ff       	jmp    8002e8 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 78 04             	lea    0x4(%eax),%edi
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	53                   	push   %ebx
  8003aa:	ff 30                	pushl  (%eax)
  8003ac:	ff d6                	call   *%esi
			break;
  8003ae:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b4:	e9 cf 02 00 00       	jmp    800688 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 78 04             	lea    0x4(%eax),%edi
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	99                   	cltd   
  8003c2:	31 d0                	xor    %edx,%eax
  8003c4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c6:	83 f8 0f             	cmp    $0xf,%eax
  8003c9:	7f 23                	jg     8003ee <vprintfmt+0x13b>
  8003cb:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	74 18                	je     8003ee <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003d6:	52                   	push   %edx
  8003d7:	68 11 28 80 00       	push   $0x802811
  8003dc:	53                   	push   %ebx
  8003dd:	56                   	push   %esi
  8003de:	e8 b3 fe ff ff       	call   800296 <printfmt>
  8003e3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e9:	e9 9a 02 00 00       	jmp    800688 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003ee:	50                   	push   %eax
  8003ef:	68 53 24 80 00       	push   $0x802453
  8003f4:	53                   	push   %ebx
  8003f5:	56                   	push   %esi
  8003f6:	e8 9b fe ff ff       	call   800296 <printfmt>
  8003fb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003fe:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800401:	e9 82 02 00 00       	jmp    800688 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	83 c0 04             	add    $0x4,%eax
  80040c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800414:	85 ff                	test   %edi,%edi
  800416:	b8 4c 24 80 00       	mov    $0x80244c,%eax
  80041b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80041e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800422:	0f 8e bd 00 00 00    	jle    8004e5 <vprintfmt+0x232>
  800428:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042c:	75 0e                	jne    80043c <vprintfmt+0x189>
  80042e:	89 75 08             	mov    %esi,0x8(%ebp)
  800431:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800434:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800437:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80043a:	eb 6d                	jmp    8004a9 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	ff 75 d0             	pushl  -0x30(%ebp)
  800442:	57                   	push   %edi
  800443:	e8 6e 03 00 00       	call   8007b6 <strnlen>
  800448:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044b:	29 c1                	sub    %eax,%ecx
  80044d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800450:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800453:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045d:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	eb 0f                	jmp    800470 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	53                   	push   %ebx
  800465:	ff 75 e0             	pushl  -0x20(%ebp)
  800468:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80046a:	83 ef 01             	sub    $0x1,%edi
  80046d:	83 c4 10             	add    $0x10,%esp
  800470:	85 ff                	test   %edi,%edi
  800472:	7f ed                	jg     800461 <vprintfmt+0x1ae>
  800474:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800477:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80047a:	85 c9                	test   %ecx,%ecx
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	0f 49 c1             	cmovns %ecx,%eax
  800484:	29 c1                	sub    %eax,%ecx
  800486:	89 75 08             	mov    %esi,0x8(%ebp)
  800489:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048f:	89 cb                	mov    %ecx,%ebx
  800491:	eb 16                	jmp    8004a9 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800493:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800497:	75 31                	jne    8004ca <vprintfmt+0x217>
					putch(ch, putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	ff 75 0c             	pushl  0xc(%ebp)
  80049f:	50                   	push   %eax
  8004a0:	ff 55 08             	call   *0x8(%ebp)
  8004a3:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a6:	83 eb 01             	sub    $0x1,%ebx
  8004a9:	83 c7 01             	add    $0x1,%edi
  8004ac:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004b0:	0f be c2             	movsbl %dl,%eax
  8004b3:	85 c0                	test   %eax,%eax
  8004b5:	74 59                	je     800510 <vprintfmt+0x25d>
  8004b7:	85 f6                	test   %esi,%esi
  8004b9:	78 d8                	js     800493 <vprintfmt+0x1e0>
  8004bb:	83 ee 01             	sub    $0x1,%esi
  8004be:	79 d3                	jns    800493 <vprintfmt+0x1e0>
  8004c0:	89 df                	mov    %ebx,%edi
  8004c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c8:	eb 37                	jmp    800501 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ca:	0f be d2             	movsbl %dl,%edx
  8004cd:	83 ea 20             	sub    $0x20,%edx
  8004d0:	83 fa 5e             	cmp    $0x5e,%edx
  8004d3:	76 c4                	jbe    800499 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 0c             	pushl  0xc(%ebp)
  8004db:	6a 3f                	push   $0x3f
  8004dd:	ff 55 08             	call   *0x8(%ebp)
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	eb c1                	jmp    8004a6 <vprintfmt+0x1f3>
  8004e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ee:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f1:	eb b6                	jmp    8004a9 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	6a 20                	push   $0x20
  8004f9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004fb:	83 ef 01             	sub    $0x1,%edi
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 ff                	test   %edi,%edi
  800503:	7f ee                	jg     8004f3 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800505:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800508:	89 45 14             	mov    %eax,0x14(%ebp)
  80050b:	e9 78 01 00 00       	jmp    800688 <vprintfmt+0x3d5>
  800510:	89 df                	mov    %ebx,%edi
  800512:	8b 75 08             	mov    0x8(%ebp),%esi
  800515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800518:	eb e7                	jmp    800501 <vprintfmt+0x24e>
	if (lflag >= 2)
  80051a:	83 f9 01             	cmp    $0x1,%ecx
  80051d:	7e 3f                	jle    80055e <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8b 50 04             	mov    0x4(%eax),%edx
  800525:	8b 00                	mov    (%eax),%eax
  800527:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 40 08             	lea    0x8(%eax),%eax
  800533:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800536:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80053a:	79 5c                	jns    800598 <vprintfmt+0x2e5>
				putch('-', putdat);
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	53                   	push   %ebx
  800540:	6a 2d                	push   $0x2d
  800542:	ff d6                	call   *%esi
				num = -(long long) num;
  800544:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800547:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054a:	f7 da                	neg    %edx
  80054c:	83 d1 00             	adc    $0x0,%ecx
  80054f:	f7 d9                	neg    %ecx
  800551:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800554:	b8 0a 00 00 00       	mov    $0xa,%eax
  800559:	e9 10 01 00 00       	jmp    80066e <vprintfmt+0x3bb>
	else if (lflag)
  80055e:	85 c9                	test   %ecx,%ecx
  800560:	75 1b                	jne    80057d <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8b 00                	mov    (%eax),%eax
  800567:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056a:	89 c1                	mov    %eax,%ecx
  80056c:	c1 f9 1f             	sar    $0x1f,%ecx
  80056f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 40 04             	lea    0x4(%eax),%eax
  800578:	89 45 14             	mov    %eax,0x14(%ebp)
  80057b:	eb b9                	jmp    800536 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 c1                	mov    %eax,%ecx
  800587:	c1 f9 1f             	sar    $0x1f,%ecx
  80058a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 40 04             	lea    0x4(%eax),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
  800596:	eb 9e                	jmp    800536 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800598:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80059e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a3:	e9 c6 00 00 00       	jmp    80066e <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005a8:	83 f9 01             	cmp    $0x1,%ecx
  8005ab:	7e 18                	jle    8005c5 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 10                	mov    (%eax),%edx
  8005b2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b5:	8d 40 08             	lea    0x8(%eax),%eax
  8005b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005bb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c0:	e9 a9 00 00 00       	jmp    80066e <vprintfmt+0x3bb>
	else if (lflag)
  8005c5:	85 c9                	test   %ecx,%ecx
  8005c7:	75 1a                	jne    8005e3 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 10                	mov    (%eax),%edx
  8005ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d3:	8d 40 04             	lea    0x4(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005de:	e9 8b 00 00 00       	jmp    80066e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 10                	mov    (%eax),%edx
  8005e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ed:	8d 40 04             	lea    0x4(%eax),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f8:	eb 74                	jmp    80066e <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005fa:	83 f9 01             	cmp    $0x1,%ecx
  8005fd:	7e 15                	jle    800614 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 10                	mov    (%eax),%edx
  800604:	8b 48 04             	mov    0x4(%eax),%ecx
  800607:	8d 40 08             	lea    0x8(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80060d:	b8 08 00 00 00       	mov    $0x8,%eax
  800612:	eb 5a                	jmp    80066e <vprintfmt+0x3bb>
	else if (lflag)
  800614:	85 c9                	test   %ecx,%ecx
  800616:	75 17                	jne    80062f <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8b 10                	mov    (%eax),%edx
  80061d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800622:	8d 40 04             	lea    0x4(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800628:	b8 08 00 00 00       	mov    $0x8,%eax
  80062d:	eb 3f                	jmp    80066e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80063f:	b8 08 00 00 00       	mov    $0x8,%eax
  800644:	eb 28                	jmp    80066e <vprintfmt+0x3bb>
			putch('0', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	6a 30                	push   $0x30
  80064c:	ff d6                	call   *%esi
			putch('x', putdat);
  80064e:	83 c4 08             	add    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 78                	push   $0x78
  800654:	ff d6                	call   *%esi
			num = (unsigned long long)
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800660:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800663:	8d 40 04             	lea    0x4(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800669:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80066e:	83 ec 0c             	sub    $0xc,%esp
  800671:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800675:	57                   	push   %edi
  800676:	ff 75 e0             	pushl  -0x20(%ebp)
  800679:	50                   	push   %eax
  80067a:	51                   	push   %ecx
  80067b:	52                   	push   %edx
  80067c:	89 da                	mov    %ebx,%edx
  80067e:	89 f0                	mov    %esi,%eax
  800680:	e8 45 fb ff ff       	call   8001ca <printnum>
			break;
  800685:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068b:	83 c7 01             	add    $0x1,%edi
  80068e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800692:	83 f8 25             	cmp    $0x25,%eax
  800695:	0f 84 2f fc ff ff    	je     8002ca <vprintfmt+0x17>
			if (ch == '\0')
  80069b:	85 c0                	test   %eax,%eax
  80069d:	0f 84 8b 00 00 00    	je     80072e <vprintfmt+0x47b>
			putch(ch, putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	50                   	push   %eax
  8006a8:	ff d6                	call   *%esi
  8006aa:	83 c4 10             	add    $0x10,%esp
  8006ad:	eb dc                	jmp    80068b <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006af:	83 f9 01             	cmp    $0x1,%ecx
  8006b2:	7e 15                	jle    8006c9 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bc:	8d 40 08             	lea    0x8(%eax),%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c7:	eb a5                	jmp    80066e <vprintfmt+0x3bb>
	else if (lflag)
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	75 17                	jne    8006e4 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 10                	mov    (%eax),%edx
  8006d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e2:	eb 8a                	jmp    80066e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ee:	8d 40 04             	lea    0x4(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f9:	e9 70 ff ff ff       	jmp    80066e <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	53                   	push   %ebx
  800702:	6a 25                	push   $0x25
  800704:	ff d6                	call   *%esi
			break;
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	e9 7a ff ff ff       	jmp    800688 <vprintfmt+0x3d5>
			putch('%', putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	6a 25                	push   $0x25
  800714:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	89 f8                	mov    %edi,%eax
  80071b:	eb 03                	jmp    800720 <vprintfmt+0x46d>
  80071d:	83 e8 01             	sub    $0x1,%eax
  800720:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800724:	75 f7                	jne    80071d <vprintfmt+0x46a>
  800726:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800729:	e9 5a ff ff ff       	jmp    800688 <vprintfmt+0x3d5>
}
  80072e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800731:	5b                   	pop    %ebx
  800732:	5e                   	pop    %esi
  800733:	5f                   	pop    %edi
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	83 ec 18             	sub    $0x18,%esp
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800742:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800745:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800749:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800753:	85 c0                	test   %eax,%eax
  800755:	74 26                	je     80077d <vsnprintf+0x47>
  800757:	85 d2                	test   %edx,%edx
  800759:	7e 22                	jle    80077d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075b:	ff 75 14             	pushl  0x14(%ebp)
  80075e:	ff 75 10             	pushl  0x10(%ebp)
  800761:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800764:	50                   	push   %eax
  800765:	68 79 02 80 00       	push   $0x800279
  80076a:	e8 44 fb ff ff       	call   8002b3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800772:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800778:	83 c4 10             	add    $0x10,%esp
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    
		return -E_INVAL;
  80077d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800782:	eb f7                	jmp    80077b <vsnprintf+0x45>

00800784 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078d:	50                   	push   %eax
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	ff 75 0c             	pushl  0xc(%ebp)
  800794:	ff 75 08             	pushl  0x8(%ebp)
  800797:	e8 9a ff ff ff       	call   800736 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a9:	eb 03                	jmp    8007ae <strlen+0x10>
		n++;
  8007ab:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b2:	75 f7                	jne    8007ab <strlen+0xd>
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 03                	jmp    8007c9 <strnlen+0x13>
		n++;
  8007c6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c9:	39 d0                	cmp    %edx,%eax
  8007cb:	74 06                	je     8007d3 <strnlen+0x1d>
  8007cd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d1:	75 f3                	jne    8007c6 <strnlen+0x10>
	return n;
}
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007df:	89 c2                	mov    %eax,%edx
  8007e1:	83 c1 01             	add    $0x1,%ecx
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007eb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ee:	84 db                	test   %bl,%bl
  8007f0:	75 ef                	jne    8007e1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f2:	5b                   	pop    %ebx
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	53                   	push   %ebx
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fc:	53                   	push   %ebx
  8007fd:	e8 9c ff ff ff       	call   80079e <strlen>
  800802:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800805:	ff 75 0c             	pushl  0xc(%ebp)
  800808:	01 d8                	add    %ebx,%eax
  80080a:	50                   	push   %eax
  80080b:	e8 c5 ff ff ff       	call   8007d5 <strcpy>
	return dst;
}
  800810:	89 d8                	mov    %ebx,%eax
  800812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800815:	c9                   	leave  
  800816:	c3                   	ret    

00800817 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	56                   	push   %esi
  80081b:	53                   	push   %ebx
  80081c:	8b 75 08             	mov    0x8(%ebp),%esi
  80081f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800822:	89 f3                	mov    %esi,%ebx
  800824:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800827:	89 f2                	mov    %esi,%edx
  800829:	eb 0f                	jmp    80083a <strncpy+0x23>
		*dst++ = *src;
  80082b:	83 c2 01             	add    $0x1,%edx
  80082e:	0f b6 01             	movzbl (%ecx),%eax
  800831:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800834:	80 39 01             	cmpb   $0x1,(%ecx)
  800837:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80083a:	39 da                	cmp    %ebx,%edx
  80083c:	75 ed                	jne    80082b <strncpy+0x14>
	}
	return ret;
}
  80083e:	89 f0                	mov    %esi,%eax
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	56                   	push   %esi
  800848:	53                   	push   %ebx
  800849:	8b 75 08             	mov    0x8(%ebp),%esi
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800852:	89 f0                	mov    %esi,%eax
  800854:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800858:	85 c9                	test   %ecx,%ecx
  80085a:	75 0b                	jne    800867 <strlcpy+0x23>
  80085c:	eb 17                	jmp    800875 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085e:	83 c2 01             	add    $0x1,%edx
  800861:	83 c0 01             	add    $0x1,%eax
  800864:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800867:	39 d8                	cmp    %ebx,%eax
  800869:	74 07                	je     800872 <strlcpy+0x2e>
  80086b:	0f b6 0a             	movzbl (%edx),%ecx
  80086e:	84 c9                	test   %cl,%cl
  800870:	75 ec                	jne    80085e <strlcpy+0x1a>
		*dst = '\0';
  800872:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800875:	29 f0                	sub    %esi,%eax
}
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800884:	eb 06                	jmp    80088c <strcmp+0x11>
		p++, q++;
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80088c:	0f b6 01             	movzbl (%ecx),%eax
  80088f:	84 c0                	test   %al,%al
  800891:	74 04                	je     800897 <strcmp+0x1c>
  800893:	3a 02                	cmp    (%edx),%al
  800895:	74 ef                	je     800886 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800897:	0f b6 c0             	movzbl %al,%eax
  80089a:	0f b6 12             	movzbl (%edx),%edx
  80089d:	29 d0                	sub    %edx,%eax
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ab:	89 c3                	mov    %eax,%ebx
  8008ad:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b0:	eb 06                	jmp    8008b8 <strncmp+0x17>
		n--, p++, q++;
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b8:	39 d8                	cmp    %ebx,%eax
  8008ba:	74 16                	je     8008d2 <strncmp+0x31>
  8008bc:	0f b6 08             	movzbl (%eax),%ecx
  8008bf:	84 c9                	test   %cl,%cl
  8008c1:	74 04                	je     8008c7 <strncmp+0x26>
  8008c3:	3a 0a                	cmp    (%edx),%cl
  8008c5:	74 eb                	je     8008b2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c7:	0f b6 00             	movzbl (%eax),%eax
  8008ca:	0f b6 12             	movzbl (%edx),%edx
  8008cd:	29 d0                	sub    %edx,%eax
}
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    
		return 0;
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d7:	eb f6                	jmp    8008cf <strncmp+0x2e>

008008d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e3:	0f b6 10             	movzbl (%eax),%edx
  8008e6:	84 d2                	test   %dl,%dl
  8008e8:	74 09                	je     8008f3 <strchr+0x1a>
		if (*s == c)
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 0a                	je     8008f8 <strchr+0x1f>
	for (; *s; s++)
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	eb f0                	jmp    8008e3 <strchr+0xa>
			return (char *) s;
	return 0;
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 03                	jmp    800909 <strfind+0xf>
  800906:	83 c0 01             	add    $0x1,%eax
  800909:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	74 04                	je     800914 <strfind+0x1a>
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strfind+0xc>
			break;
	return (char *) s;
}
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	57                   	push   %edi
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800922:	85 c9                	test   %ecx,%ecx
  800924:	74 13                	je     800939 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800926:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092c:	75 05                	jne    800933 <memset+0x1d>
  80092e:	f6 c1 03             	test   $0x3,%cl
  800931:	74 0d                	je     800940 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	fc                   	cld    
  800937:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800939:	89 f8                	mov    %edi,%eax
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5f                   	pop    %edi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    
		c &= 0xFF;
  800940:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800944:	89 d3                	mov    %edx,%ebx
  800946:	c1 e3 08             	shl    $0x8,%ebx
  800949:	89 d0                	mov    %edx,%eax
  80094b:	c1 e0 18             	shl    $0x18,%eax
  80094e:	89 d6                	mov    %edx,%esi
  800950:	c1 e6 10             	shl    $0x10,%esi
  800953:	09 f0                	or     %esi,%eax
  800955:	09 c2                	or     %eax,%edx
  800957:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800959:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80095c:	89 d0                	mov    %edx,%eax
  80095e:	fc                   	cld    
  80095f:	f3 ab                	rep stos %eax,%es:(%edi)
  800961:	eb d6                	jmp    800939 <memset+0x23>

00800963 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800971:	39 c6                	cmp    %eax,%esi
  800973:	73 35                	jae    8009aa <memmove+0x47>
  800975:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800978:	39 c2                	cmp    %eax,%edx
  80097a:	76 2e                	jbe    8009aa <memmove+0x47>
		s += n;
		d += n;
  80097c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097f:	89 d6                	mov    %edx,%esi
  800981:	09 fe                	or     %edi,%esi
  800983:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800989:	74 0c                	je     800997 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098b:	83 ef 01             	sub    $0x1,%edi
  80098e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800991:	fd                   	std    
  800992:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800994:	fc                   	cld    
  800995:	eb 21                	jmp    8009b8 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800997:	f6 c1 03             	test   $0x3,%cl
  80099a:	75 ef                	jne    80098b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099c:	83 ef 04             	sub    $0x4,%edi
  80099f:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a5:	fd                   	std    
  8009a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a8:	eb ea                	jmp    800994 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009aa:	89 f2                	mov    %esi,%edx
  8009ac:	09 c2                	or     %eax,%edx
  8009ae:	f6 c2 03             	test   $0x3,%dl
  8009b1:	74 09                	je     8009bc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b3:	89 c7                	mov    %eax,%edi
  8009b5:	fc                   	cld    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bc:	f6 c1 03             	test   $0x3,%cl
  8009bf:	75 f2                	jne    8009b3 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c4:	89 c7                	mov    %eax,%edi
  8009c6:	fc                   	cld    
  8009c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c9:	eb ed                	jmp    8009b8 <memmove+0x55>

008009cb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ce:	ff 75 10             	pushl  0x10(%ebp)
  8009d1:	ff 75 0c             	pushl  0xc(%ebp)
  8009d4:	ff 75 08             	pushl  0x8(%ebp)
  8009d7:	e8 87 ff ff ff       	call   800963 <memmove>
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e9:	89 c6                	mov    %eax,%esi
  8009eb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ee:	39 f0                	cmp    %esi,%eax
  8009f0:	74 1c                	je     800a0e <memcmp+0x30>
		if (*s1 != *s2)
  8009f2:	0f b6 08             	movzbl (%eax),%ecx
  8009f5:	0f b6 1a             	movzbl (%edx),%ebx
  8009f8:	38 d9                	cmp    %bl,%cl
  8009fa:	75 08                	jne    800a04 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	83 c2 01             	add    $0x1,%edx
  800a02:	eb ea                	jmp    8009ee <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a04:	0f b6 c1             	movzbl %cl,%eax
  800a07:	0f b6 db             	movzbl %bl,%ebx
  800a0a:	29 d8                	sub    %ebx,%eax
  800a0c:	eb 05                	jmp    800a13 <memcmp+0x35>
	}

	return 0;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a13:	5b                   	pop    %ebx
  800a14:	5e                   	pop    %esi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a20:	89 c2                	mov    %eax,%edx
  800a22:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a25:	39 d0                	cmp    %edx,%eax
  800a27:	73 09                	jae    800a32 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a29:	38 08                	cmp    %cl,(%eax)
  800a2b:	74 05                	je     800a32 <memfind+0x1b>
	for (; s < ends; s++)
  800a2d:	83 c0 01             	add    $0x1,%eax
  800a30:	eb f3                	jmp    800a25 <memfind+0xe>
			break;
	return (void *) s;
}
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
  800a3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a40:	eb 03                	jmp    800a45 <strtol+0x11>
		s++;
  800a42:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a45:	0f b6 01             	movzbl (%ecx),%eax
  800a48:	3c 20                	cmp    $0x20,%al
  800a4a:	74 f6                	je     800a42 <strtol+0xe>
  800a4c:	3c 09                	cmp    $0x9,%al
  800a4e:	74 f2                	je     800a42 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a50:	3c 2b                	cmp    $0x2b,%al
  800a52:	74 2e                	je     800a82 <strtol+0x4e>
	int neg = 0;
  800a54:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a59:	3c 2d                	cmp    $0x2d,%al
  800a5b:	74 2f                	je     800a8c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a63:	75 05                	jne    800a6a <strtol+0x36>
  800a65:	80 39 30             	cmpb   $0x30,(%ecx)
  800a68:	74 2c                	je     800a96 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6a:	85 db                	test   %ebx,%ebx
  800a6c:	75 0a                	jne    800a78 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a73:	80 39 30             	cmpb   $0x30,(%ecx)
  800a76:	74 28                	je     800aa0 <strtol+0x6c>
		base = 10;
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a80:	eb 50                	jmp    800ad2 <strtol+0x9e>
		s++;
  800a82:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8a:	eb d1                	jmp    800a5d <strtol+0x29>
		s++, neg = 1;
  800a8c:	83 c1 01             	add    $0x1,%ecx
  800a8f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a94:	eb c7                	jmp    800a5d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9a:	74 0e                	je     800aaa <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	75 d8                	jne    800a78 <strtol+0x44>
		s++, base = 8;
  800aa0:	83 c1 01             	add    $0x1,%ecx
  800aa3:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa8:	eb ce                	jmp    800a78 <strtol+0x44>
		s += 2, base = 16;
  800aaa:	83 c1 02             	add    $0x2,%ecx
  800aad:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab2:	eb c4                	jmp    800a78 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ab4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab7:	89 f3                	mov    %esi,%ebx
  800ab9:	80 fb 19             	cmp    $0x19,%bl
  800abc:	77 29                	ja     800ae7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800abe:	0f be d2             	movsbl %dl,%edx
  800ac1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac7:	7d 30                	jge    800af9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad2:	0f b6 11             	movzbl (%ecx),%edx
  800ad5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 09             	cmp    $0x9,%bl
  800add:	77 d5                	ja     800ab4 <strtol+0x80>
			dig = *s - '0';
  800adf:	0f be d2             	movsbl %dl,%edx
  800ae2:	83 ea 30             	sub    $0x30,%edx
  800ae5:	eb dd                	jmp    800ac4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ae7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	80 fb 19             	cmp    $0x19,%bl
  800aef:	77 08                	ja     800af9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800af1:	0f be d2             	movsbl %dl,%edx
  800af4:	83 ea 37             	sub    $0x37,%edx
  800af7:	eb cb                	jmp    800ac4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afd:	74 05                	je     800b04 <strtol+0xd0>
		*endptr = (char *) s;
  800aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b02:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b04:	89 c2                	mov    %eax,%edx
  800b06:	f7 da                	neg    %edx
  800b08:	85 ff                	test   %edi,%edi
  800b0a:	0f 45 c2             	cmovne %edx,%eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b23:	89 c3                	mov    %eax,%ebx
  800b25:	89 c7                	mov    %eax,%edi
  800b27:	89 c6                	mov    %eax,%esi
  800b29:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b36:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b40:	89 d1                	mov    %edx,%ecx
  800b42:	89 d3                	mov    %edx,%ebx
  800b44:	89 d7                	mov    %edx,%edi
  800b46:	89 d6                	mov    %edx,%esi
  800b48:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b60:	b8 03 00 00 00       	mov    $0x3,%eax
  800b65:	89 cb                	mov    %ecx,%ebx
  800b67:	89 cf                	mov    %ecx,%edi
  800b69:	89 ce                	mov    %ecx,%esi
  800b6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7f 08                	jg     800b79 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	50                   	push   %eax
  800b7d:	6a 03                	push   $0x3
  800b7f:	68 3f 27 80 00       	push   $0x80273f
  800b84:	6a 23                	push   $0x23
  800b86:	68 5c 27 80 00       	push   $0x80275c
  800b8b:	e8 4b f5 ff ff       	call   8000db <_panic>

00800b90 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba0:	89 d1                	mov    %edx,%ecx
  800ba2:	89 d3                	mov    %edx,%ebx
  800ba4:	89 d7                	mov    %edx,%edi
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_yield>:

void
sys_yield(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd7:	be 00 00 00 00       	mov    $0x0,%esi
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be2:	b8 04 00 00 00       	mov    $0x4,%eax
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bea:	89 f7                	mov    %esi,%edi
  800bec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bee:	85 c0                	test   %eax,%eax
  800bf0:	7f 08                	jg     800bfa <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 04                	push   $0x4
  800c00:	68 3f 27 80 00       	push   $0x80273f
  800c05:	6a 23                	push   $0x23
  800c07:	68 5c 27 80 00       	push   $0x80275c
  800c0c:	e8 ca f4 ff ff       	call   8000db <_panic>

00800c11 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	b8 05 00 00 00       	mov    $0x5,%eax
  800c25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c30:	85 c0                	test   %eax,%eax
  800c32:	7f 08                	jg     800c3c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 05                	push   $0x5
  800c42:	68 3f 27 80 00       	push   $0x80273f
  800c47:	6a 23                	push   $0x23
  800c49:	68 5c 27 80 00       	push   $0x80275c
  800c4e:	e8 88 f4 ff ff       	call   8000db <_panic>

00800c53 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6c:	89 df                	mov    %ebx,%edi
  800c6e:	89 de                	mov    %ebx,%esi
  800c70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c72:	85 c0                	test   %eax,%eax
  800c74:	7f 08                	jg     800c7e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 06                	push   $0x6
  800c84:	68 3f 27 80 00       	push   $0x80273f
  800c89:	6a 23                	push   $0x23
  800c8b:	68 5c 27 80 00       	push   $0x80275c
  800c90:	e8 46 f4 ff ff       	call   8000db <_panic>

00800c95 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cae:	89 df                	mov    %ebx,%edi
  800cb0:	89 de                	mov    %ebx,%esi
  800cb2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7f 08                	jg     800cc0 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 08                	push   $0x8
  800cc6:	68 3f 27 80 00       	push   $0x80273f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 5c 27 80 00       	push   $0x80275c
  800cd2:	e8 04 f4 ff ff       	call   8000db <_panic>

00800cd7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf0:	89 df                	mov    %ebx,%edi
  800cf2:	89 de                	mov    %ebx,%esi
  800cf4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7f 08                	jg     800d02 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 09                	push   $0x9
  800d08:	68 3f 27 80 00       	push   $0x80273f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 5c 27 80 00       	push   $0x80275c
  800d14:	e8 c2 f3 ff ff       	call   8000db <_panic>

00800d19 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d32:	89 df                	mov    %ebx,%edi
  800d34:	89 de                	mov    %ebx,%esi
  800d36:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7f 08                	jg     800d44 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 0a                	push   $0xa
  800d4a:	68 3f 27 80 00       	push   $0x80273f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 5c 27 80 00       	push   $0x80275c
  800d56:	e8 80 f3 ff ff       	call   8000db <_panic>

00800d5b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d67:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6c:	be 00 00 00 00       	mov    $0x0,%esi
  800d71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d74:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d77:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d94:	89 cb                	mov    %ecx,%ebx
  800d96:	89 cf                	mov    %ecx,%edi
  800d98:	89 ce                	mov    %ecx,%esi
  800d9a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7f 08                	jg     800da8 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	50                   	push   %eax
  800dac:	6a 0d                	push   $0xd
  800dae:	68 3f 27 80 00       	push   $0x80273f
  800db3:	6a 23                	push   $0x23
  800db5:	68 5c 27 80 00       	push   $0x80275c
  800dba:	e8 1c f3 ff ff       	call   8000db <_panic>

00800dbf <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc5:	05 00 00 00 30       	add    $0x30000000,%eax
  800dca:	c1 e8 0c             	shr    $0xc,%eax
}
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800dda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ddf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dec:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800df1:	89 c2                	mov    %eax,%edx
  800df3:	c1 ea 16             	shr    $0x16,%edx
  800df6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dfd:	f6 c2 01             	test   $0x1,%dl
  800e00:	74 2a                	je     800e2c <fd_alloc+0x46>
  800e02:	89 c2                	mov    %eax,%edx
  800e04:	c1 ea 0c             	shr    $0xc,%edx
  800e07:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e0e:	f6 c2 01             	test   $0x1,%dl
  800e11:	74 19                	je     800e2c <fd_alloc+0x46>
  800e13:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e18:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e1d:	75 d2                	jne    800df1 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e1f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e25:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e2a:	eb 07                	jmp    800e33 <fd_alloc+0x4d>
			*fd_store = fd;
  800e2c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e3b:	83 f8 1f             	cmp    $0x1f,%eax
  800e3e:	77 36                	ja     800e76 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e40:	c1 e0 0c             	shl    $0xc,%eax
  800e43:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e48:	89 c2                	mov    %eax,%edx
  800e4a:	c1 ea 16             	shr    $0x16,%edx
  800e4d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e54:	f6 c2 01             	test   $0x1,%dl
  800e57:	74 24                	je     800e7d <fd_lookup+0x48>
  800e59:	89 c2                	mov    %eax,%edx
  800e5b:	c1 ea 0c             	shr    $0xc,%edx
  800e5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e65:	f6 c2 01             	test   $0x1,%dl
  800e68:	74 1a                	je     800e84 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6d:	89 02                	mov    %eax,(%edx)
	return 0;
  800e6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    
		return -E_INVAL;
  800e76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e7b:	eb f7                	jmp    800e74 <fd_lookup+0x3f>
		return -E_INVAL;
  800e7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e82:	eb f0                	jmp    800e74 <fd_lookup+0x3f>
  800e84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e89:	eb e9                	jmp    800e74 <fd_lookup+0x3f>

00800e8b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 08             	sub    $0x8,%esp
  800e91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e94:	ba e8 27 80 00       	mov    $0x8027e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e99:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e9e:	39 08                	cmp    %ecx,(%eax)
  800ea0:	74 33                	je     800ed5 <dev_lookup+0x4a>
  800ea2:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800ea5:	8b 02                	mov    (%edx),%eax
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	75 f3                	jne    800e9e <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eab:	a1 04 40 80 00       	mov    0x804004,%eax
  800eb0:	8b 40 48             	mov    0x48(%eax),%eax
  800eb3:	83 ec 04             	sub    $0x4,%esp
  800eb6:	51                   	push   %ecx
  800eb7:	50                   	push   %eax
  800eb8:	68 6c 27 80 00       	push   $0x80276c
  800ebd:	e8 f4 f2 ff ff       	call   8001b6 <cprintf>
	*dev = 0;
  800ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ecb:	83 c4 10             	add    $0x10,%esp
  800ece:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    
			*dev = devtab[i];
  800ed5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eda:	b8 00 00 00 00       	mov    $0x0,%eax
  800edf:	eb f2                	jmp    800ed3 <dev_lookup+0x48>

00800ee1 <fd_close>:
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 1c             	sub    $0x1c,%esp
  800eea:	8b 75 08             	mov    0x8(%ebp),%esi
  800eed:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ef3:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ef4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800efa:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800efd:	50                   	push   %eax
  800efe:	e8 32 ff ff ff       	call   800e35 <fd_lookup>
  800f03:	89 c3                	mov    %eax,%ebx
  800f05:	83 c4 08             	add    $0x8,%esp
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	78 05                	js     800f11 <fd_close+0x30>
	    || fd != fd2)
  800f0c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f0f:	74 16                	je     800f27 <fd_close+0x46>
		return (must_exist ? r : 0);
  800f11:	89 f8                	mov    %edi,%eax
  800f13:	84 c0                	test   %al,%al
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1a:	0f 44 d8             	cmove  %eax,%ebx
}
  800f1d:	89 d8                	mov    %ebx,%eax
  800f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f27:	83 ec 08             	sub    $0x8,%esp
  800f2a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f2d:	50                   	push   %eax
  800f2e:	ff 36                	pushl  (%esi)
  800f30:	e8 56 ff ff ff       	call   800e8b <dev_lookup>
  800f35:	89 c3                	mov    %eax,%ebx
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	78 15                	js     800f53 <fd_close+0x72>
		if (dev->dev_close)
  800f3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f41:	8b 40 10             	mov    0x10(%eax),%eax
  800f44:	85 c0                	test   %eax,%eax
  800f46:	74 1b                	je     800f63 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	56                   	push   %esi
  800f4c:	ff d0                	call   *%eax
  800f4e:	89 c3                	mov    %eax,%ebx
  800f50:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	56                   	push   %esi
  800f57:	6a 00                	push   $0x0
  800f59:	e8 f5 fc ff ff       	call   800c53 <sys_page_unmap>
	return r;
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	eb ba                	jmp    800f1d <fd_close+0x3c>
			r = 0;
  800f63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f68:	eb e9                	jmp    800f53 <fd_close+0x72>

00800f6a <close>:

int
close(int fdnum)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f73:	50                   	push   %eax
  800f74:	ff 75 08             	pushl  0x8(%ebp)
  800f77:	e8 b9 fe ff ff       	call   800e35 <fd_lookup>
  800f7c:	83 c4 08             	add    $0x8,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 10                	js     800f93 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f83:	83 ec 08             	sub    $0x8,%esp
  800f86:	6a 01                	push   $0x1
  800f88:	ff 75 f4             	pushl  -0xc(%ebp)
  800f8b:	e8 51 ff ff ff       	call   800ee1 <fd_close>
  800f90:	83 c4 10             	add    $0x10,%esp
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <close_all>:

void
close_all(void)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	53                   	push   %ebx
  800f99:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	53                   	push   %ebx
  800fa5:	e8 c0 ff ff ff       	call   800f6a <close>
	for (i = 0; i < MAXFD; i++)
  800faa:	83 c3 01             	add    $0x1,%ebx
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	83 fb 20             	cmp    $0x20,%ebx
  800fb3:	75 ec                	jne    800fa1 <close_all+0xc>
}
  800fb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
  800fc0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fc3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc6:	50                   	push   %eax
  800fc7:	ff 75 08             	pushl  0x8(%ebp)
  800fca:	e8 66 fe ff ff       	call   800e35 <fd_lookup>
  800fcf:	89 c3                	mov    %eax,%ebx
  800fd1:	83 c4 08             	add    $0x8,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	0f 88 81 00 00 00    	js     80105d <dup+0xa3>
		return r;
	close(newfdnum);
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	ff 75 0c             	pushl  0xc(%ebp)
  800fe2:	e8 83 ff ff ff       	call   800f6a <close>

	newfd = INDEX2FD(newfdnum);
  800fe7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fea:	c1 e6 0c             	shl    $0xc,%esi
  800fed:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800ff3:	83 c4 04             	add    $0x4,%esp
  800ff6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff9:	e8 d1 fd ff ff       	call   800dcf <fd2data>
  800ffe:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801000:	89 34 24             	mov    %esi,(%esp)
  801003:	e8 c7 fd ff ff       	call   800dcf <fd2data>
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80100d:	89 d8                	mov    %ebx,%eax
  80100f:	c1 e8 16             	shr    $0x16,%eax
  801012:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801019:	a8 01                	test   $0x1,%al
  80101b:	74 11                	je     80102e <dup+0x74>
  80101d:	89 d8                	mov    %ebx,%eax
  80101f:	c1 e8 0c             	shr    $0xc,%eax
  801022:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801029:	f6 c2 01             	test   $0x1,%dl
  80102c:	75 39                	jne    801067 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80102e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801031:	89 d0                	mov    %edx,%eax
  801033:	c1 e8 0c             	shr    $0xc,%eax
  801036:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	25 07 0e 00 00       	and    $0xe07,%eax
  801045:	50                   	push   %eax
  801046:	56                   	push   %esi
  801047:	6a 00                	push   $0x0
  801049:	52                   	push   %edx
  80104a:	6a 00                	push   $0x0
  80104c:	e8 c0 fb ff ff       	call   800c11 <sys_page_map>
  801051:	89 c3                	mov    %eax,%ebx
  801053:	83 c4 20             	add    $0x20,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	78 31                	js     80108b <dup+0xd1>
		goto err;

	return newfdnum;
  80105a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80105d:	89 d8                	mov    %ebx,%eax
  80105f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801062:	5b                   	pop    %ebx
  801063:	5e                   	pop    %esi
  801064:	5f                   	pop    %edi
  801065:	5d                   	pop    %ebp
  801066:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801067:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	25 07 0e 00 00       	and    $0xe07,%eax
  801076:	50                   	push   %eax
  801077:	57                   	push   %edi
  801078:	6a 00                	push   $0x0
  80107a:	53                   	push   %ebx
  80107b:	6a 00                	push   $0x0
  80107d:	e8 8f fb ff ff       	call   800c11 <sys_page_map>
  801082:	89 c3                	mov    %eax,%ebx
  801084:	83 c4 20             	add    $0x20,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	79 a3                	jns    80102e <dup+0x74>
	sys_page_unmap(0, newfd);
  80108b:	83 ec 08             	sub    $0x8,%esp
  80108e:	56                   	push   %esi
  80108f:	6a 00                	push   $0x0
  801091:	e8 bd fb ff ff       	call   800c53 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801096:	83 c4 08             	add    $0x8,%esp
  801099:	57                   	push   %edi
  80109a:	6a 00                	push   $0x0
  80109c:	e8 b2 fb ff ff       	call   800c53 <sys_page_unmap>
	return r;
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	eb b7                	jmp    80105d <dup+0xa3>

008010a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 14             	sub    $0x14,%esp
  8010ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b3:	50                   	push   %eax
  8010b4:	53                   	push   %ebx
  8010b5:	e8 7b fd ff ff       	call   800e35 <fd_lookup>
  8010ba:	83 c4 08             	add    $0x8,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	78 3f                	js     801100 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c1:	83 ec 08             	sub    $0x8,%esp
  8010c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c7:	50                   	push   %eax
  8010c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cb:	ff 30                	pushl  (%eax)
  8010cd:	e8 b9 fd ff ff       	call   800e8b <dev_lookup>
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	78 27                	js     801100 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010dc:	8b 42 08             	mov    0x8(%edx),%eax
  8010df:	83 e0 03             	and    $0x3,%eax
  8010e2:	83 f8 01             	cmp    $0x1,%eax
  8010e5:	74 1e                	je     801105 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ea:	8b 40 08             	mov    0x8(%eax),%eax
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	74 35                	je     801126 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010f1:	83 ec 04             	sub    $0x4,%esp
  8010f4:	ff 75 10             	pushl  0x10(%ebp)
  8010f7:	ff 75 0c             	pushl  0xc(%ebp)
  8010fa:	52                   	push   %edx
  8010fb:	ff d0                	call   *%eax
  8010fd:	83 c4 10             	add    $0x10,%esp
}
  801100:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801103:	c9                   	leave  
  801104:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801105:	a1 04 40 80 00       	mov    0x804004,%eax
  80110a:	8b 40 48             	mov    0x48(%eax),%eax
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	53                   	push   %ebx
  801111:	50                   	push   %eax
  801112:	68 ad 27 80 00       	push   $0x8027ad
  801117:	e8 9a f0 ff ff       	call   8001b6 <cprintf>
		return -E_INVAL;
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801124:	eb da                	jmp    801100 <read+0x5a>
		return -E_NOT_SUPP;
  801126:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80112b:	eb d3                	jmp    801100 <read+0x5a>

0080112d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	57                   	push   %edi
  801131:	56                   	push   %esi
  801132:	53                   	push   %ebx
  801133:	83 ec 0c             	sub    $0xc,%esp
  801136:	8b 7d 08             	mov    0x8(%ebp),%edi
  801139:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80113c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801141:	39 f3                	cmp    %esi,%ebx
  801143:	73 25                	jae    80116a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	89 f0                	mov    %esi,%eax
  80114a:	29 d8                	sub    %ebx,%eax
  80114c:	50                   	push   %eax
  80114d:	89 d8                	mov    %ebx,%eax
  80114f:	03 45 0c             	add    0xc(%ebp),%eax
  801152:	50                   	push   %eax
  801153:	57                   	push   %edi
  801154:	e8 4d ff ff ff       	call   8010a6 <read>
		if (m < 0)
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	85 c0                	test   %eax,%eax
  80115e:	78 08                	js     801168 <readn+0x3b>
			return m;
		if (m == 0)
  801160:	85 c0                	test   %eax,%eax
  801162:	74 06                	je     80116a <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801164:	01 c3                	add    %eax,%ebx
  801166:	eb d9                	jmp    801141 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801168:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80116a:	89 d8                	mov    %ebx,%eax
  80116c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	53                   	push   %ebx
  801178:	83 ec 14             	sub    $0x14,%esp
  80117b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	53                   	push   %ebx
  801183:	e8 ad fc ff ff       	call   800e35 <fd_lookup>
  801188:	83 c4 08             	add    $0x8,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	78 3a                	js     8011c9 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118f:	83 ec 08             	sub    $0x8,%esp
  801192:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801199:	ff 30                	pushl  (%eax)
  80119b:	e8 eb fc ff ff       	call   800e8b <dev_lookup>
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	78 22                	js     8011c9 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ae:	74 1e                	je     8011ce <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011b3:	8b 52 0c             	mov    0xc(%edx),%edx
  8011b6:	85 d2                	test   %edx,%edx
  8011b8:	74 35                	je     8011ef <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011ba:	83 ec 04             	sub    $0x4,%esp
  8011bd:	ff 75 10             	pushl  0x10(%ebp)
  8011c0:	ff 75 0c             	pushl  0xc(%ebp)
  8011c3:	50                   	push   %eax
  8011c4:	ff d2                	call   *%edx
  8011c6:	83 c4 10             	add    $0x10,%esp
}
  8011c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d3:	8b 40 48             	mov    0x48(%eax),%eax
  8011d6:	83 ec 04             	sub    $0x4,%esp
  8011d9:	53                   	push   %ebx
  8011da:	50                   	push   %eax
  8011db:	68 c9 27 80 00       	push   $0x8027c9
  8011e0:	e8 d1 ef ff ff       	call   8001b6 <cprintf>
		return -E_INVAL;
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ed:	eb da                	jmp    8011c9 <write+0x55>
		return -E_NOT_SUPP;
  8011ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011f4:	eb d3                	jmp    8011c9 <write+0x55>

008011f6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011ff:	50                   	push   %eax
  801200:	ff 75 08             	pushl  0x8(%ebp)
  801203:	e8 2d fc ff ff       	call   800e35 <fd_lookup>
  801208:	83 c4 08             	add    $0x8,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 0e                	js     80121d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80120f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801212:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801215:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801218:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	53                   	push   %ebx
  801223:	83 ec 14             	sub    $0x14,%esp
  801226:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801229:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	53                   	push   %ebx
  80122e:	e8 02 fc ff ff       	call   800e35 <fd_lookup>
  801233:	83 c4 08             	add    $0x8,%esp
  801236:	85 c0                	test   %eax,%eax
  801238:	78 37                	js     801271 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801240:	50                   	push   %eax
  801241:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801244:	ff 30                	pushl  (%eax)
  801246:	e8 40 fc ff ff       	call   800e8b <dev_lookup>
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 1f                	js     801271 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801252:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801255:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801259:	74 1b                	je     801276 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80125b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125e:	8b 52 18             	mov    0x18(%edx),%edx
  801261:	85 d2                	test   %edx,%edx
  801263:	74 32                	je     801297 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	ff 75 0c             	pushl  0xc(%ebp)
  80126b:	50                   	push   %eax
  80126c:	ff d2                	call   *%edx
  80126e:	83 c4 10             	add    $0x10,%esp
}
  801271:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801274:	c9                   	leave  
  801275:	c3                   	ret    
			thisenv->env_id, fdnum);
  801276:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80127b:	8b 40 48             	mov    0x48(%eax),%eax
  80127e:	83 ec 04             	sub    $0x4,%esp
  801281:	53                   	push   %ebx
  801282:	50                   	push   %eax
  801283:	68 8c 27 80 00       	push   $0x80278c
  801288:	e8 29 ef ff ff       	call   8001b6 <cprintf>
		return -E_INVAL;
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801295:	eb da                	jmp    801271 <ftruncate+0x52>
		return -E_NOT_SUPP;
  801297:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80129c:	eb d3                	jmp    801271 <ftruncate+0x52>

0080129e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 14             	sub    $0x14,%esp
  8012a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	ff 75 08             	pushl  0x8(%ebp)
  8012af:	e8 81 fb ff ff       	call   800e35 <fd_lookup>
  8012b4:	83 c4 08             	add    $0x8,%esp
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	78 4b                	js     801306 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bb:	83 ec 08             	sub    $0x8,%esp
  8012be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c1:	50                   	push   %eax
  8012c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c5:	ff 30                	pushl  (%eax)
  8012c7:	e8 bf fb ff ff       	call   800e8b <dev_lookup>
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	78 33                	js     801306 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8012d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012da:	74 2f                	je     80130b <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012dc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012df:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012e6:	00 00 00 
	stat->st_isdir = 0;
  8012e9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012f0:	00 00 00 
	stat->st_dev = dev;
  8012f3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	53                   	push   %ebx
  8012fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801300:	ff 50 14             	call   *0x14(%eax)
  801303:	83 c4 10             	add    $0x10,%esp
}
  801306:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801309:	c9                   	leave  
  80130a:	c3                   	ret    
		return -E_NOT_SUPP;
  80130b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801310:	eb f4                	jmp    801306 <fstat+0x68>

00801312 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	56                   	push   %esi
  801316:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801317:	83 ec 08             	sub    $0x8,%esp
  80131a:	6a 00                	push   $0x0
  80131c:	ff 75 08             	pushl  0x8(%ebp)
  80131f:	e8 da 01 00 00       	call   8014fe <open>
  801324:	89 c3                	mov    %eax,%ebx
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 1b                	js     801348 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80132d:	83 ec 08             	sub    $0x8,%esp
  801330:	ff 75 0c             	pushl  0xc(%ebp)
  801333:	50                   	push   %eax
  801334:	e8 65 ff ff ff       	call   80129e <fstat>
  801339:	89 c6                	mov    %eax,%esi
	close(fd);
  80133b:	89 1c 24             	mov    %ebx,(%esp)
  80133e:	e8 27 fc ff ff       	call   800f6a <close>
	return r;
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	89 f3                	mov    %esi,%ebx
}
  801348:	89 d8                	mov    %ebx,%eax
  80134a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    

00801351 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	56                   	push   %esi
  801355:	53                   	push   %ebx
  801356:	89 c6                	mov    %eax,%esi
  801358:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80135a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801361:	74 27                	je     80138a <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801363:	6a 07                	push   $0x7
  801365:	68 00 50 80 00       	push   $0x805000
  80136a:	56                   	push   %esi
  80136b:	ff 35 00 40 80 00    	pushl  0x804000
  801371:	e8 42 0d 00 00       	call   8020b8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801376:	83 c4 0c             	add    $0xc,%esp
  801379:	6a 00                	push   $0x0
  80137b:	53                   	push   %ebx
  80137c:	6a 00                	push   $0x0
  80137e:	e8 ce 0c 00 00       	call   802051 <ipc_recv>
}
  801383:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801386:	5b                   	pop    %ebx
  801387:	5e                   	pop    %esi
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80138a:	83 ec 0c             	sub    $0xc,%esp
  80138d:	6a 01                	push   $0x1
  80138f:	e8 78 0d 00 00       	call   80210c <ipc_find_env>
  801394:	a3 00 40 80 00       	mov    %eax,0x804000
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	eb c5                	jmp    801363 <fsipc+0x12>

0080139e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8013c1:	e8 8b ff ff ff       	call   801351 <fsipc>
}
  8013c6:	c9                   	leave  
  8013c7:	c3                   	ret    

008013c8 <devfile_flush>:
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013de:	b8 06 00 00 00       	mov    $0x6,%eax
  8013e3:	e8 69 ff ff ff       	call   801351 <fsipc>
}
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    

008013ea <devfile_stat>:
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	53                   	push   %ebx
  8013ee:	83 ec 04             	sub    $0x4,%esp
  8013f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801404:	b8 05 00 00 00       	mov    $0x5,%eax
  801409:	e8 43 ff ff ff       	call   801351 <fsipc>
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 2c                	js     80143e <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	68 00 50 80 00       	push   $0x805000
  80141a:	53                   	push   %ebx
  80141b:	e8 b5 f3 ff ff       	call   8007d5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801420:	a1 80 50 80 00       	mov    0x805080,%eax
  801425:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80142b:	a1 84 50 80 00       	mov    0x805084,%eax
  801430:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80143e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <devfile_write>:
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	83 ec 0c             	sub    $0xc,%esp
  801449:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80144c:	8b 55 08             	mov    0x8(%ebp),%edx
  80144f:	8b 52 0c             	mov    0xc(%edx),%edx
  801452:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  801458:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  80145d:	50                   	push   %eax
  80145e:	ff 75 0c             	pushl  0xc(%ebp)
  801461:	68 08 50 80 00       	push   $0x805008
  801466:	e8 f8 f4 ff ff       	call   800963 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  80146b:	ba 00 00 00 00       	mov    $0x0,%edx
  801470:	b8 04 00 00 00       	mov    $0x4,%eax
  801475:	e8 d7 fe ff ff       	call   801351 <fsipc>
}
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <devfile_read>:
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	56                   	push   %esi
  801480:	53                   	push   %ebx
  801481:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801484:	8b 45 08             	mov    0x8(%ebp),%eax
  801487:	8b 40 0c             	mov    0xc(%eax),%eax
  80148a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80148f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801495:	ba 00 00 00 00       	mov    $0x0,%edx
  80149a:	b8 03 00 00 00       	mov    $0x3,%eax
  80149f:	e8 ad fe ff ff       	call   801351 <fsipc>
  8014a4:	89 c3                	mov    %eax,%ebx
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 1f                	js     8014c9 <devfile_read+0x4d>
	assert(r <= n);
  8014aa:	39 f0                	cmp    %esi,%eax
  8014ac:	77 24                	ja     8014d2 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8014ae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014b3:	7f 33                	jg     8014e8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014b5:	83 ec 04             	sub    $0x4,%esp
  8014b8:	50                   	push   %eax
  8014b9:	68 00 50 80 00       	push   $0x805000
  8014be:	ff 75 0c             	pushl  0xc(%ebp)
  8014c1:	e8 9d f4 ff ff       	call   800963 <memmove>
	return r;
  8014c6:	83 c4 10             	add    $0x10,%esp
}
  8014c9:	89 d8                	mov    %ebx,%eax
  8014cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ce:	5b                   	pop    %ebx
  8014cf:	5e                   	pop    %esi
  8014d0:	5d                   	pop    %ebp
  8014d1:	c3                   	ret    
	assert(r <= n);
  8014d2:	68 f8 27 80 00       	push   $0x8027f8
  8014d7:	68 ff 27 80 00       	push   $0x8027ff
  8014dc:	6a 7c                	push   $0x7c
  8014de:	68 14 28 80 00       	push   $0x802814
  8014e3:	e8 f3 eb ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  8014e8:	68 1f 28 80 00       	push   $0x80281f
  8014ed:	68 ff 27 80 00       	push   $0x8027ff
  8014f2:	6a 7d                	push   $0x7d
  8014f4:	68 14 28 80 00       	push   $0x802814
  8014f9:	e8 dd eb ff ff       	call   8000db <_panic>

008014fe <open>:
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	56                   	push   %esi
  801502:	53                   	push   %ebx
  801503:	83 ec 1c             	sub    $0x1c,%esp
  801506:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801509:	56                   	push   %esi
  80150a:	e8 8f f2 ff ff       	call   80079e <strlen>
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801517:	7f 6c                	jg     801585 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801519:	83 ec 0c             	sub    $0xc,%esp
  80151c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	e8 c1 f8 ff ff       	call   800de6 <fd_alloc>
  801525:	89 c3                	mov    %eax,%ebx
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 3c                	js     80156a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80152e:	83 ec 08             	sub    $0x8,%esp
  801531:	56                   	push   %esi
  801532:	68 00 50 80 00       	push   $0x805000
  801537:	e8 99 f2 ff ff       	call   8007d5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80153c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801544:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801547:	b8 01 00 00 00       	mov    $0x1,%eax
  80154c:	e8 00 fe ff ff       	call   801351 <fsipc>
  801551:	89 c3                	mov    %eax,%ebx
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 19                	js     801573 <open+0x75>
	return fd2num(fd);
  80155a:	83 ec 0c             	sub    $0xc,%esp
  80155d:	ff 75 f4             	pushl  -0xc(%ebp)
  801560:	e8 5a f8 ff ff       	call   800dbf <fd2num>
  801565:	89 c3                	mov    %eax,%ebx
  801567:	83 c4 10             	add    $0x10,%esp
}
  80156a:	89 d8                	mov    %ebx,%eax
  80156c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156f:	5b                   	pop    %ebx
  801570:	5e                   	pop    %esi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    
		fd_close(fd, 0);
  801573:	83 ec 08             	sub    $0x8,%esp
  801576:	6a 00                	push   $0x0
  801578:	ff 75 f4             	pushl  -0xc(%ebp)
  80157b:	e8 61 f9 ff ff       	call   800ee1 <fd_close>
		return r;
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	eb e5                	jmp    80156a <open+0x6c>
		return -E_BAD_PATH;
  801585:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80158a:	eb de                	jmp    80156a <open+0x6c>

0080158c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801592:	ba 00 00 00 00       	mov    $0x0,%edx
  801597:	b8 08 00 00 00       	mov    $0x8,%eax
  80159c:	e8 b0 fd ff ff       	call   801351 <fsipc>
}
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    

008015a3 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	57                   	push   %edi
  8015a7:	56                   	push   %esi
  8015a8:	53                   	push   %ebx
  8015a9:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015af:	6a 00                	push   $0x0
  8015b1:	ff 75 08             	pushl  0x8(%ebp)
  8015b4:	e8 45 ff ff ff       	call   8014fe <open>
  8015b9:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	0f 88 40 03 00 00    	js     80190a <spawn+0x367>
  8015ca:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015cc:	83 ec 04             	sub    $0x4,%esp
  8015cf:	68 00 02 00 00       	push   $0x200
  8015d4:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	57                   	push   %edi
  8015dc:	e8 4c fb ff ff       	call   80112d <readn>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015e9:	75 5d                	jne    801648 <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  8015eb:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8015f2:	45 4c 46 
  8015f5:	75 51                	jne    801648 <spawn+0xa5>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8015f7:	b8 07 00 00 00       	mov    $0x7,%eax
  8015fc:	cd 30                	int    $0x30
  8015fe:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801604:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80160a:	85 c0                	test   %eax,%eax
  80160c:	0f 88 a5 04 00 00    	js     801ab7 <spawn+0x514>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801612:	25 ff 03 00 00       	and    $0x3ff,%eax
  801617:	6b f0 7c             	imul   $0x7c,%eax,%esi
  80161a:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801620:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801626:	b9 11 00 00 00       	mov    $0x11,%ecx
  80162b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80162d:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801633:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801639:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  80163e:	be 00 00 00 00       	mov    $0x0,%esi
  801643:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801646:	eb 4b                	jmp    801693 <spawn+0xf0>
		close(fd);
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801651:	e8 14 f9 ff ff       	call   800f6a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801656:	83 c4 0c             	add    $0xc,%esp
  801659:	68 7f 45 4c 46       	push   $0x464c457f
  80165e:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801664:	68 2b 28 80 00       	push   $0x80282b
  801669:	e8 48 eb ff ff       	call   8001b6 <cprintf>
		return -E_NOT_EXEC;
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  801678:	ff ff ff 
  80167b:	e9 8a 02 00 00       	jmp    80190a <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  801680:	83 ec 0c             	sub    $0xc,%esp
  801683:	50                   	push   %eax
  801684:	e8 15 f1 ff ff       	call   80079e <strlen>
  801689:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  80168d:	83 c3 01             	add    $0x1,%ebx
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80169a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80169d:	85 c0                	test   %eax,%eax
  80169f:	75 df                	jne    801680 <spawn+0xdd>
  8016a1:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8016a7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016ad:	bf 00 10 40 00       	mov    $0x401000,%edi
  8016b2:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016b4:	89 fa                	mov    %edi,%edx
  8016b6:	83 e2 fc             	and    $0xfffffffc,%edx
  8016b9:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016c0:	29 c2                	sub    %eax,%edx
  8016c2:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016c8:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016cb:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016d0:	0f 86 f2 03 00 00    	jbe    801ac8 <spawn+0x525>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016d6:	83 ec 04             	sub    $0x4,%esp
  8016d9:	6a 07                	push   $0x7
  8016db:	68 00 00 40 00       	push   $0x400000
  8016e0:	6a 00                	push   $0x0
  8016e2:	e8 e7 f4 ff ff       	call   800bce <sys_page_alloc>
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	0f 88 db 03 00 00    	js     801acd <spawn+0x52a>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8016f2:	be 00 00 00 00       	mov    $0x0,%esi
  8016f7:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8016fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801700:	eb 30                	jmp    801732 <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  801702:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801708:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80170e:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801711:	83 ec 08             	sub    $0x8,%esp
  801714:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801717:	57                   	push   %edi
  801718:	e8 b8 f0 ff ff       	call   8007d5 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80171d:	83 c4 04             	add    $0x4,%esp
  801720:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801723:	e8 76 f0 ff ff       	call   80079e <strlen>
  801728:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  80172c:	83 c6 01             	add    $0x1,%esi
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801738:	7f c8                	jg     801702 <spawn+0x15f>
	}
	argv_store[argc] = 0;
  80173a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801740:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801746:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80174d:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801753:	0f 85 8c 00 00 00    	jne    8017e5 <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801759:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80175f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801765:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801768:	89 f8                	mov    %edi,%eax
  80176a:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801770:	89 78 f8             	mov    %edi,-0x8(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801773:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801778:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80177e:	83 ec 0c             	sub    $0xc,%esp
  801781:	6a 07                	push   $0x7
  801783:	68 00 d0 bf ee       	push   $0xeebfd000
  801788:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80178e:	68 00 00 40 00       	push   $0x400000
  801793:	6a 00                	push   $0x0
  801795:	e8 77 f4 ff ff       	call   800c11 <sys_page_map>
  80179a:	89 c3                	mov    %eax,%ebx
  80179c:	83 c4 20             	add    $0x20,%esp
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	0f 88 46 03 00 00    	js     801aed <spawn+0x54a>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	68 00 00 40 00       	push   $0x400000
  8017af:	6a 00                	push   $0x0
  8017b1:	e8 9d f4 ff ff       	call   800c53 <sys_page_unmap>
  8017b6:	89 c3                	mov    %eax,%ebx
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	0f 88 2a 03 00 00    	js     801aed <spawn+0x54a>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017c3:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017c9:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017d0:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017d6:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8017dd:	00 00 00 
  8017e0:	e9 56 01 00 00       	jmp    80193b <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017e5:	68 a0 28 80 00       	push   $0x8028a0
  8017ea:	68 ff 27 80 00       	push   $0x8027ff
  8017ef:	68 f2 00 00 00       	push   $0xf2
  8017f4:	68 45 28 80 00       	push   $0x802845
  8017f9:	e8 dd e8 ff ff       	call   8000db <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017fe:	83 ec 04             	sub    $0x4,%esp
  801801:	6a 07                	push   $0x7
  801803:	68 00 00 40 00       	push   $0x400000
  801808:	6a 00                	push   $0x0
  80180a:	e8 bf f3 ff ff       	call   800bce <sys_page_alloc>
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	85 c0                	test   %eax,%eax
  801814:	0f 88 be 02 00 00    	js     801ad8 <spawn+0x535>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801823:	01 f0                	add    %esi,%eax
  801825:	50                   	push   %eax
  801826:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80182c:	e8 c5 f9 ff ff       	call   8011f6 <seek>
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	85 c0                	test   %eax,%eax
  801836:	0f 88 a3 02 00 00    	js     801adf <spawn+0x53c>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80183c:	83 ec 04             	sub    $0x4,%esp
  80183f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801845:	29 f0                	sub    %esi,%eax
  801847:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80184c:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801851:	0f 47 c1             	cmova  %ecx,%eax
  801854:	50                   	push   %eax
  801855:	68 00 00 40 00       	push   $0x400000
  80185a:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801860:	e8 c8 f8 ff ff       	call   80112d <readn>
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	0f 88 76 02 00 00    	js     801ae6 <spawn+0x543>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801870:	83 ec 0c             	sub    $0xc,%esp
  801873:	57                   	push   %edi
  801874:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  80187a:	56                   	push   %esi
  80187b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801881:	68 00 00 40 00       	push   $0x400000
  801886:	6a 00                	push   $0x0
  801888:	e8 84 f3 ff ff       	call   800c11 <sys_page_map>
  80188d:	83 c4 20             	add    $0x20,%esp
  801890:	85 c0                	test   %eax,%eax
  801892:	0f 88 80 00 00 00    	js     801918 <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801898:	83 ec 08             	sub    $0x8,%esp
  80189b:	68 00 00 40 00       	push   $0x400000
  8018a0:	6a 00                	push   $0x0
  8018a2:	e8 ac f3 ff ff       	call   800c53 <sys_page_unmap>
  8018a7:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  8018aa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8018b0:	89 de                	mov    %ebx,%esi
  8018b2:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  8018b8:	76 73                	jbe    80192d <spawn+0x38a>
		if (i >= filesz) {
  8018ba:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8018c0:	0f 87 38 ff ff ff    	ja     8017fe <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018c6:	83 ec 04             	sub    $0x4,%esp
  8018c9:	57                   	push   %edi
  8018ca:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  8018d0:	56                   	push   %esi
  8018d1:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018d7:	e8 f2 f2 ff ff       	call   800bce <sys_page_alloc>
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	79 c7                	jns    8018aa <spawn+0x307>
  8018e3:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  8018e5:	83 ec 0c             	sub    $0xc,%esp
  8018e8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8018ee:	e8 5c f2 ff ff       	call   800b4f <sys_env_destroy>
	close(fd);
  8018f3:	83 c4 04             	add    $0x4,%esp
  8018f6:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8018fc:	e8 69 f6 ff ff       	call   800f6a <close>
	return r;
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  80190a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801910:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801913:	5b                   	pop    %ebx
  801914:	5e                   	pop    %esi
  801915:	5f                   	pop    %edi
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  801918:	50                   	push   %eax
  801919:	68 51 28 80 00       	push   $0x802851
  80191e:	68 25 01 00 00       	push   $0x125
  801923:	68 45 28 80 00       	push   $0x802845
  801928:	e8 ae e7 ff ff       	call   8000db <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80192d:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801934:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  80193b:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801942:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801948:	7e 71                	jle    8019bb <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  80194a:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801950:	83 39 01             	cmpl   $0x1,(%ecx)
  801953:	75 d8                	jne    80192d <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801955:	8b 41 18             	mov    0x18(%ecx),%eax
  801958:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80195b:	83 f8 01             	cmp    $0x1,%eax
  80195e:	19 ff                	sbb    %edi,%edi
  801960:	83 e7 fe             	and    $0xfffffffe,%edi
  801963:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801966:	8b 71 04             	mov    0x4(%ecx),%esi
  801969:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  80196f:	8b 59 10             	mov    0x10(%ecx),%ebx
  801972:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801978:	8b 41 14             	mov    0x14(%ecx),%eax
  80197b:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801981:	8b 51 08             	mov    0x8(%ecx),%edx
  801984:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  80198a:	89 d0                	mov    %edx,%eax
  80198c:	25 ff 0f 00 00       	and    $0xfff,%eax
  801991:	74 1e                	je     8019b1 <spawn+0x40e>
		va -= i;
  801993:	29 c2                	sub    %eax,%edx
  801995:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
		memsz += i;
  80199b:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  8019a1:	01 c3                	add    %eax,%ebx
  8019a3:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  8019a9:	29 c6                	sub    %eax,%esi
  8019ab:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  8019b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019b6:	e9 f5 fe ff ff       	jmp    8018b0 <spawn+0x30d>
	close(fd);
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8019c4:	e8 a1 f5 ff ff       	call   800f6a <close>
  8019c9:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    	uintptr_t addr;
    	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  8019cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019d1:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  8019d7:	eb 0e                	jmp    8019e7 <spawn+0x444>
  8019d9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019df:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8019e5:	74 58                	je     801a3f <spawn+0x49c>
        	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  8019e7:	89 d8                	mov    %ebx,%eax
  8019e9:	c1 e8 16             	shr    $0x16,%eax
  8019ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019f3:	a8 01                	test   $0x1,%al
  8019f5:	74 e2                	je     8019d9 <spawn+0x436>
  8019f7:	89 d8                	mov    %ebx,%eax
  8019f9:	c1 e8 0c             	shr    $0xc,%eax
  8019fc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a03:	f6 c2 01             	test   $0x1,%dl
  801a06:	74 d1                	je     8019d9 <spawn+0x436>
  801a08:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a0f:	f6 c2 04             	test   $0x4,%dl
  801a12:	74 c5                	je     8019d9 <spawn+0x436>
  801a14:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a1b:	f6 c6 04             	test   $0x4,%dh
  801a1e:	74 b9                	je     8019d9 <spawn+0x436>
            		sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801a20:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	25 07 0e 00 00       	and    $0xe07,%eax
  801a2f:	50                   	push   %eax
  801a30:	53                   	push   %ebx
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	6a 00                	push   $0x0
  801a35:	e8 d7 f1 ff ff       	call   800c11 <sys_page_map>
  801a3a:	83 c4 20             	add    $0x20,%esp
  801a3d:	eb 9a                	jmp    8019d9 <spawn+0x436>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801a3f:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801a46:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801a49:	83 ec 08             	sub    $0x8,%esp
  801a4c:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801a52:	50                   	push   %eax
  801a53:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a59:	e8 79 f2 ff ff       	call   800cd7 <sys_env_set_trapframe>
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	85 c0                	test   %eax,%eax
  801a63:	78 28                	js     801a8d <spawn+0x4ea>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a65:	83 ec 08             	sub    $0x8,%esp
  801a68:	6a 02                	push   $0x2
  801a6a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a70:	e8 20 f2 ff ff       	call   800c95 <sys_env_set_status>
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	78 26                	js     801aa2 <spawn+0x4ff>
	return child;
  801a7c:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801a82:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801a88:	e9 7d fe ff ff       	jmp    80190a <spawn+0x367>
		panic("sys_env_set_trapframe: %e", r);
  801a8d:	50                   	push   %eax
  801a8e:	68 6e 28 80 00       	push   $0x80286e
  801a93:	68 86 00 00 00       	push   $0x86
  801a98:	68 45 28 80 00       	push   $0x802845
  801a9d:	e8 39 e6 ff ff       	call   8000db <_panic>
		panic("sys_env_set_status: %e", r);
  801aa2:	50                   	push   %eax
  801aa3:	68 88 28 80 00       	push   $0x802888
  801aa8:	68 89 00 00 00       	push   $0x89
  801aad:	68 45 28 80 00       	push   $0x802845
  801ab2:	e8 24 e6 ff ff       	call   8000db <_panic>
		return r;
  801ab7:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801abd:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801ac3:	e9 42 fe ff ff       	jmp    80190a <spawn+0x367>
		return -E_NO_MEM;
  801ac8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801acd:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801ad3:	e9 32 fe ff ff       	jmp    80190a <spawn+0x367>
  801ad8:	89 c7                	mov    %eax,%edi
  801ada:	e9 06 fe ff ff       	jmp    8018e5 <spawn+0x342>
  801adf:	89 c7                	mov    %eax,%edi
  801ae1:	e9 ff fd ff ff       	jmp    8018e5 <spawn+0x342>
  801ae6:	89 c7                	mov    %eax,%edi
  801ae8:	e9 f8 fd ff ff       	jmp    8018e5 <spawn+0x342>
	sys_page_unmap(0, UTEMP);
  801aed:	83 ec 08             	sub    $0x8,%esp
  801af0:	68 00 00 40 00       	push   $0x400000
  801af5:	6a 00                	push   $0x0
  801af7:	e8 57 f1 ff ff       	call   800c53 <sys_page_unmap>
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801b05:	e9 00 fe ff ff       	jmp    80190a <spawn+0x367>

00801b0a <spawnl>:
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	57                   	push   %edi
  801b0e:	56                   	push   %esi
  801b0f:	53                   	push   %ebx
  801b10:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801b13:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801b16:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801b1b:	eb 05                	jmp    801b22 <spawnl+0x18>
		argc++;
  801b1d:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801b20:	89 ca                	mov    %ecx,%edx
  801b22:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b25:	83 3a 00             	cmpl   $0x0,(%edx)
  801b28:	75 f3                	jne    801b1d <spawnl+0x13>
	const char *argv[argc+2];
  801b2a:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b31:	83 e2 f0             	and    $0xfffffff0,%edx
  801b34:	29 d4                	sub    %edx,%esp
  801b36:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b3a:	c1 ea 02             	shr    $0x2,%edx
  801b3d:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b44:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b49:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b50:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b57:	00 
	va_start(vl, arg0);
  801b58:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801b5b:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b62:	eb 0b                	jmp    801b6f <spawnl+0x65>
		argv[i+1] = va_arg(vl, const char *);
  801b64:	83 c0 01             	add    $0x1,%eax
  801b67:	8b 39                	mov    (%ecx),%edi
  801b69:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801b6c:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801b6f:	39 d0                	cmp    %edx,%eax
  801b71:	75 f1                	jne    801b64 <spawnl+0x5a>
	return spawn(prog, argv);
  801b73:	83 ec 08             	sub    $0x8,%esp
  801b76:	56                   	push   %esi
  801b77:	ff 75 08             	pushl  0x8(%ebp)
  801b7a:	e8 24 fa ff ff       	call   8015a3 <spawn>
}
  801b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5f                   	pop    %edi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b8f:	83 ec 0c             	sub    $0xc,%esp
  801b92:	ff 75 08             	pushl  0x8(%ebp)
  801b95:	e8 35 f2 ff ff       	call   800dcf <fd2data>
  801b9a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b9c:	83 c4 08             	add    $0x8,%esp
  801b9f:	68 c8 28 80 00       	push   $0x8028c8
  801ba4:	53                   	push   %ebx
  801ba5:	e8 2b ec ff ff       	call   8007d5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801baa:	8b 46 04             	mov    0x4(%esi),%eax
  801bad:	2b 06                	sub    (%esi),%eax
  801baf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bb5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bbc:	00 00 00 
	stat->st_dev = &devpipe;
  801bbf:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bc6:	30 80 00 
	return 0;
}
  801bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    

00801bd5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 0c             	sub    $0xc,%esp
  801bdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bdf:	53                   	push   %ebx
  801be0:	6a 00                	push   $0x0
  801be2:	e8 6c f0 ff ff       	call   800c53 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801be7:	89 1c 24             	mov    %ebx,(%esp)
  801bea:	e8 e0 f1 ff ff       	call   800dcf <fd2data>
  801bef:	83 c4 08             	add    $0x8,%esp
  801bf2:	50                   	push   %eax
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 59 f0 ff ff       	call   800c53 <sys_page_unmap>
}
  801bfa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bfd:	c9                   	leave  
  801bfe:	c3                   	ret    

00801bff <_pipeisclosed>:
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	57                   	push   %edi
  801c03:	56                   	push   %esi
  801c04:	53                   	push   %ebx
  801c05:	83 ec 1c             	sub    $0x1c,%esp
  801c08:	89 c7                	mov    %eax,%edi
  801c0a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c0c:	a1 04 40 80 00       	mov    0x804004,%eax
  801c11:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	57                   	push   %edi
  801c18:	e8 28 05 00 00       	call   802145 <pageref>
  801c1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c20:	89 34 24             	mov    %esi,(%esp)
  801c23:	e8 1d 05 00 00       	call   802145 <pageref>
		nn = thisenv->env_runs;
  801c28:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c2e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	39 cb                	cmp    %ecx,%ebx
  801c36:	74 1b                	je     801c53 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c38:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c3b:	75 cf                	jne    801c0c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c3d:	8b 42 58             	mov    0x58(%edx),%eax
  801c40:	6a 01                	push   $0x1
  801c42:	50                   	push   %eax
  801c43:	53                   	push   %ebx
  801c44:	68 cf 28 80 00       	push   $0x8028cf
  801c49:	e8 68 e5 ff ff       	call   8001b6 <cprintf>
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	eb b9                	jmp    801c0c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c53:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c56:	0f 94 c0             	sete   %al
  801c59:	0f b6 c0             	movzbl %al,%eax
}
  801c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5e                   	pop    %esi
  801c61:	5f                   	pop    %edi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    

00801c64 <devpipe_write>:
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	57                   	push   %edi
  801c68:	56                   	push   %esi
  801c69:	53                   	push   %ebx
  801c6a:	83 ec 28             	sub    $0x28,%esp
  801c6d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c70:	56                   	push   %esi
  801c71:	e8 59 f1 ff ff       	call   800dcf <fd2data>
  801c76:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	bf 00 00 00 00       	mov    $0x0,%edi
  801c80:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c83:	74 4f                	je     801cd4 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c85:	8b 43 04             	mov    0x4(%ebx),%eax
  801c88:	8b 0b                	mov    (%ebx),%ecx
  801c8a:	8d 51 20             	lea    0x20(%ecx),%edx
  801c8d:	39 d0                	cmp    %edx,%eax
  801c8f:	72 14                	jb     801ca5 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801c91:	89 da                	mov    %ebx,%edx
  801c93:	89 f0                	mov    %esi,%eax
  801c95:	e8 65 ff ff ff       	call   801bff <_pipeisclosed>
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	75 3a                	jne    801cd8 <devpipe_write+0x74>
			sys_yield();
  801c9e:	e8 0c ef ff ff       	call   800baf <sys_yield>
  801ca3:	eb e0                	jmp    801c85 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cac:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801caf:	89 c2                	mov    %eax,%edx
  801cb1:	c1 fa 1f             	sar    $0x1f,%edx
  801cb4:	89 d1                	mov    %edx,%ecx
  801cb6:	c1 e9 1b             	shr    $0x1b,%ecx
  801cb9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cbc:	83 e2 1f             	and    $0x1f,%edx
  801cbf:	29 ca                	sub    %ecx,%edx
  801cc1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cc5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cc9:	83 c0 01             	add    $0x1,%eax
  801ccc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ccf:	83 c7 01             	add    $0x1,%edi
  801cd2:	eb ac                	jmp    801c80 <devpipe_write+0x1c>
	return i;
  801cd4:	89 f8                	mov    %edi,%eax
  801cd6:	eb 05                	jmp    801cdd <devpipe_write+0x79>
				return 0;
  801cd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <devpipe_read>:
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	57                   	push   %edi
  801ce9:	56                   	push   %esi
  801cea:	53                   	push   %ebx
  801ceb:	83 ec 18             	sub    $0x18,%esp
  801cee:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cf1:	57                   	push   %edi
  801cf2:	e8 d8 f0 ff ff       	call   800dcf <fd2data>
  801cf7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	be 00 00 00 00       	mov    $0x0,%esi
  801d01:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d04:	74 47                	je     801d4d <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801d06:	8b 03                	mov    (%ebx),%eax
  801d08:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d0b:	75 22                	jne    801d2f <devpipe_read+0x4a>
			if (i > 0)
  801d0d:	85 f6                	test   %esi,%esi
  801d0f:	75 14                	jne    801d25 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801d11:	89 da                	mov    %ebx,%edx
  801d13:	89 f8                	mov    %edi,%eax
  801d15:	e8 e5 fe ff ff       	call   801bff <_pipeisclosed>
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	75 33                	jne    801d51 <devpipe_read+0x6c>
			sys_yield();
  801d1e:	e8 8c ee ff ff       	call   800baf <sys_yield>
  801d23:	eb e1                	jmp    801d06 <devpipe_read+0x21>
				return i;
  801d25:	89 f0                	mov    %esi,%eax
}
  801d27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2a:	5b                   	pop    %ebx
  801d2b:	5e                   	pop    %esi
  801d2c:	5f                   	pop    %edi
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d2f:	99                   	cltd   
  801d30:	c1 ea 1b             	shr    $0x1b,%edx
  801d33:	01 d0                	add    %edx,%eax
  801d35:	83 e0 1f             	and    $0x1f,%eax
  801d38:	29 d0                	sub    %edx,%eax
  801d3a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d42:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d45:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d48:	83 c6 01             	add    $0x1,%esi
  801d4b:	eb b4                	jmp    801d01 <devpipe_read+0x1c>
	return i;
  801d4d:	89 f0                	mov    %esi,%eax
  801d4f:	eb d6                	jmp    801d27 <devpipe_read+0x42>
				return 0;
  801d51:	b8 00 00 00 00       	mov    $0x0,%eax
  801d56:	eb cf                	jmp    801d27 <devpipe_read+0x42>

00801d58 <pipe>:
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	56                   	push   %esi
  801d5c:	53                   	push   %ebx
  801d5d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d63:	50                   	push   %eax
  801d64:	e8 7d f0 ff ff       	call   800de6 <fd_alloc>
  801d69:	89 c3                	mov    %eax,%ebx
  801d6b:	83 c4 10             	add    $0x10,%esp
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	78 5b                	js     801dcd <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d72:	83 ec 04             	sub    $0x4,%esp
  801d75:	68 07 04 00 00       	push   $0x407
  801d7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7d:	6a 00                	push   $0x0
  801d7f:	e8 4a ee ff ff       	call   800bce <sys_page_alloc>
  801d84:	89 c3                	mov    %eax,%ebx
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	78 40                	js     801dcd <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801d8d:	83 ec 0c             	sub    $0xc,%esp
  801d90:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d93:	50                   	push   %eax
  801d94:	e8 4d f0 ff ff       	call   800de6 <fd_alloc>
  801d99:	89 c3                	mov    %eax,%ebx
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	85 c0                	test   %eax,%eax
  801da0:	78 1b                	js     801dbd <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da2:	83 ec 04             	sub    $0x4,%esp
  801da5:	68 07 04 00 00       	push   $0x407
  801daa:	ff 75 f0             	pushl  -0x10(%ebp)
  801dad:	6a 00                	push   $0x0
  801daf:	e8 1a ee ff ff       	call   800bce <sys_page_alloc>
  801db4:	89 c3                	mov    %eax,%ebx
  801db6:	83 c4 10             	add    $0x10,%esp
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	79 19                	jns    801dd6 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801dbd:	83 ec 08             	sub    $0x8,%esp
  801dc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc3:	6a 00                	push   $0x0
  801dc5:	e8 89 ee ff ff       	call   800c53 <sys_page_unmap>
  801dca:	83 c4 10             	add    $0x10,%esp
}
  801dcd:	89 d8                	mov    %ebx,%eax
  801dcf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5e                   	pop    %esi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    
	va = fd2data(fd0);
  801dd6:	83 ec 0c             	sub    $0xc,%esp
  801dd9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddc:	e8 ee ef ff ff       	call   800dcf <fd2data>
  801de1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de3:	83 c4 0c             	add    $0xc,%esp
  801de6:	68 07 04 00 00       	push   $0x407
  801deb:	50                   	push   %eax
  801dec:	6a 00                	push   $0x0
  801dee:	e8 db ed ff ff       	call   800bce <sys_page_alloc>
  801df3:	89 c3                	mov    %eax,%ebx
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	0f 88 8c 00 00 00    	js     801e8c <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e00:	83 ec 0c             	sub    $0xc,%esp
  801e03:	ff 75 f0             	pushl  -0x10(%ebp)
  801e06:	e8 c4 ef ff ff       	call   800dcf <fd2data>
  801e0b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e12:	50                   	push   %eax
  801e13:	6a 00                	push   $0x0
  801e15:	56                   	push   %esi
  801e16:	6a 00                	push   $0x0
  801e18:	e8 f4 ed ff ff       	call   800c11 <sys_page_map>
  801e1d:	89 c3                	mov    %eax,%ebx
  801e1f:	83 c4 20             	add    $0x20,%esp
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 58                	js     801e7e <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e29:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e2f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e34:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801e3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e3e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e44:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e49:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e50:	83 ec 0c             	sub    $0xc,%esp
  801e53:	ff 75 f4             	pushl  -0xc(%ebp)
  801e56:	e8 64 ef ff ff       	call   800dbf <fd2num>
  801e5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e5e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e60:	83 c4 04             	add    $0x4,%esp
  801e63:	ff 75 f0             	pushl  -0x10(%ebp)
  801e66:	e8 54 ef ff ff       	call   800dbf <fd2num>
  801e6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e6e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e71:	83 c4 10             	add    $0x10,%esp
  801e74:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e79:	e9 4f ff ff ff       	jmp    801dcd <pipe+0x75>
	sys_page_unmap(0, va);
  801e7e:	83 ec 08             	sub    $0x8,%esp
  801e81:	56                   	push   %esi
  801e82:	6a 00                	push   $0x0
  801e84:	e8 ca ed ff ff       	call   800c53 <sys_page_unmap>
  801e89:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e8c:	83 ec 08             	sub    $0x8,%esp
  801e8f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e92:	6a 00                	push   $0x0
  801e94:	e8 ba ed ff ff       	call   800c53 <sys_page_unmap>
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	e9 1c ff ff ff       	jmp    801dbd <pipe+0x65>

00801ea1 <pipeisclosed>:
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eaa:	50                   	push   %eax
  801eab:	ff 75 08             	pushl  0x8(%ebp)
  801eae:	e8 82 ef ff ff       	call   800e35 <fd_lookup>
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 18                	js     801ed2 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801eba:	83 ec 0c             	sub    $0xc,%esp
  801ebd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec0:	e8 0a ef ff ff       	call   800dcf <fd2data>
	return _pipeisclosed(fd, p);
  801ec5:	89 c2                	mov    %eax,%edx
  801ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eca:	e8 30 fd ff ff       	call   801bff <_pipeisclosed>
  801ecf:	83 c4 10             	add    $0x10,%esp
}
  801ed2:	c9                   	leave  
  801ed3:	c3                   	ret    

00801ed4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ed7:	b8 00 00 00 00       	mov    $0x0,%eax
  801edc:	5d                   	pop    %ebp
  801edd:	c3                   	ret    

00801ede <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ee4:	68 e7 28 80 00       	push   $0x8028e7
  801ee9:	ff 75 0c             	pushl  0xc(%ebp)
  801eec:	e8 e4 e8 ff ff       	call   8007d5 <strcpy>
	return 0;
}
  801ef1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <devcons_write>:
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	57                   	push   %edi
  801efc:	56                   	push   %esi
  801efd:	53                   	push   %ebx
  801efe:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f04:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f09:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f0f:	eb 2f                	jmp    801f40 <devcons_write+0x48>
		m = n - tot;
  801f11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f14:	29 f3                	sub    %esi,%ebx
  801f16:	83 fb 7f             	cmp    $0x7f,%ebx
  801f19:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f1e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f21:	83 ec 04             	sub    $0x4,%esp
  801f24:	53                   	push   %ebx
  801f25:	89 f0                	mov    %esi,%eax
  801f27:	03 45 0c             	add    0xc(%ebp),%eax
  801f2a:	50                   	push   %eax
  801f2b:	57                   	push   %edi
  801f2c:	e8 32 ea ff ff       	call   800963 <memmove>
		sys_cputs(buf, m);
  801f31:	83 c4 08             	add    $0x8,%esp
  801f34:	53                   	push   %ebx
  801f35:	57                   	push   %edi
  801f36:	e8 d7 eb ff ff       	call   800b12 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f3b:	01 de                	add    %ebx,%esi
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f43:	72 cc                	jb     801f11 <devcons_write+0x19>
}
  801f45:	89 f0                	mov    %esi,%eax
  801f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5f                   	pop    %edi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    

00801f4f <devcons_read>:
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	83 ec 08             	sub    $0x8,%esp
  801f55:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f5e:	75 07                	jne    801f67 <devcons_read+0x18>
}
  801f60:	c9                   	leave  
  801f61:	c3                   	ret    
		sys_yield();
  801f62:	e8 48 ec ff ff       	call   800baf <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f67:	e8 c4 eb ff ff       	call   800b30 <sys_cgetc>
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	74 f2                	je     801f62 <devcons_read+0x13>
	if (c < 0)
  801f70:	85 c0                	test   %eax,%eax
  801f72:	78 ec                	js     801f60 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801f74:	83 f8 04             	cmp    $0x4,%eax
  801f77:	74 0c                	je     801f85 <devcons_read+0x36>
	*(char*)vbuf = c;
  801f79:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f7c:	88 02                	mov    %al,(%edx)
	return 1;
  801f7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f83:	eb db                	jmp    801f60 <devcons_read+0x11>
		return 0;
  801f85:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8a:	eb d4                	jmp    801f60 <devcons_read+0x11>

00801f8c <cputchar>:
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f92:	8b 45 08             	mov    0x8(%ebp),%eax
  801f95:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f98:	6a 01                	push   $0x1
  801f9a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f9d:	50                   	push   %eax
  801f9e:	e8 6f eb ff ff       	call   800b12 <sys_cputs>
}
  801fa3:	83 c4 10             	add    $0x10,%esp
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    

00801fa8 <getchar>:
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801fae:	6a 01                	push   $0x1
  801fb0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fb3:	50                   	push   %eax
  801fb4:	6a 00                	push   $0x0
  801fb6:	e8 eb f0 ff ff       	call   8010a6 <read>
	if (r < 0)
  801fbb:	83 c4 10             	add    $0x10,%esp
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	78 08                	js     801fca <getchar+0x22>
	if (r < 1)
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	7e 06                	jle    801fcc <getchar+0x24>
	return c;
  801fc6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fca:	c9                   	leave  
  801fcb:	c3                   	ret    
		return -E_EOF;
  801fcc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fd1:	eb f7                	jmp    801fca <getchar+0x22>

00801fd3 <iscons>:
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fdc:	50                   	push   %eax
  801fdd:	ff 75 08             	pushl  0x8(%ebp)
  801fe0:	e8 50 ee ff ff       	call   800e35 <fd_lookup>
  801fe5:	83 c4 10             	add    $0x10,%esp
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	78 11                	js     801ffd <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fef:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ff5:	39 10                	cmp    %edx,(%eax)
  801ff7:	0f 94 c0             	sete   %al
  801ffa:	0f b6 c0             	movzbl %al,%eax
}
  801ffd:	c9                   	leave  
  801ffe:	c3                   	ret    

00801fff <opencons>:
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802005:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802008:	50                   	push   %eax
  802009:	e8 d8 ed ff ff       	call   800de6 <fd_alloc>
  80200e:	83 c4 10             	add    $0x10,%esp
  802011:	85 c0                	test   %eax,%eax
  802013:	78 3a                	js     80204f <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802015:	83 ec 04             	sub    $0x4,%esp
  802018:	68 07 04 00 00       	push   $0x407
  80201d:	ff 75 f4             	pushl  -0xc(%ebp)
  802020:	6a 00                	push   $0x0
  802022:	e8 a7 eb ff ff       	call   800bce <sys_page_alloc>
  802027:	83 c4 10             	add    $0x10,%esp
  80202a:	85 c0                	test   %eax,%eax
  80202c:	78 21                	js     80204f <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80202e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802031:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802037:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802039:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802043:	83 ec 0c             	sub    $0xc,%esp
  802046:	50                   	push   %eax
  802047:	e8 73 ed ff ff       	call   800dbf <fd2num>
  80204c:	83 c4 10             	add    $0x10,%esp
}
  80204f:	c9                   	leave  
  802050:	c3                   	ret    

00802051 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	56                   	push   %esi
  802055:	53                   	push   %ebx
  802056:	8b 75 08             	mov    0x8(%ebp),%esi
  802059:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  80205f:	85 f6                	test   %esi,%esi
  802061:	74 06                	je     802069 <ipc_recv+0x18>
  802063:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  802069:	85 db                	test   %ebx,%ebx
  80206b:	74 06                	je     802073 <ipc_recv+0x22>
  80206d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  802073:	85 c0                	test   %eax,%eax
  802075:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80207a:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  80207d:	83 ec 0c             	sub    $0xc,%esp
  802080:	50                   	push   %eax
  802081:	e8 f8 ec ff ff       	call   800d7e <sys_ipc_recv>
	if (ret) return ret;
  802086:	83 c4 10             	add    $0x10,%esp
  802089:	85 c0                	test   %eax,%eax
  80208b:	75 24                	jne    8020b1 <ipc_recv+0x60>
	if (from_env_store)
  80208d:	85 f6                	test   %esi,%esi
  80208f:	74 0a                	je     80209b <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  802091:	a1 04 40 80 00       	mov    0x804004,%eax
  802096:	8b 40 74             	mov    0x74(%eax),%eax
  802099:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  80209b:	85 db                	test   %ebx,%ebx
  80209d:	74 0a                	je     8020a9 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  80209f:	a1 04 40 80 00       	mov    0x804004,%eax
  8020a4:	8b 40 78             	mov    0x78(%eax),%eax
  8020a7:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8020a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ae:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    

008020b8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	57                   	push   %edi
  8020bc:	56                   	push   %esi
  8020bd:	53                   	push   %ebx
  8020be:	83 ec 0c             	sub    $0xc,%esp
  8020c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8020ca:	85 db                	test   %ebx,%ebx
  8020cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8020d1:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8020d4:	ff 75 14             	pushl  0x14(%ebp)
  8020d7:	53                   	push   %ebx
  8020d8:	56                   	push   %esi
  8020d9:	57                   	push   %edi
  8020da:	e8 7c ec ff ff       	call   800d5b <sys_ipc_try_send>
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	74 1e                	je     802104 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8020e6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020e9:	75 07                	jne    8020f2 <ipc_send+0x3a>
		sys_yield();
  8020eb:	e8 bf ea ff ff       	call   800baf <sys_yield>
  8020f0:	eb e2                	jmp    8020d4 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8020f2:	50                   	push   %eax
  8020f3:	68 f3 28 80 00       	push   $0x8028f3
  8020f8:	6a 36                	push   $0x36
  8020fa:	68 0a 29 80 00       	push   $0x80290a
  8020ff:	e8 d7 df ff ff       	call   8000db <_panic>
	}
}
  802104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    

0080210c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802112:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802117:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80211a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802120:	8b 52 50             	mov    0x50(%edx),%edx
  802123:	39 ca                	cmp    %ecx,%edx
  802125:	74 11                	je     802138 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802127:	83 c0 01             	add    $0x1,%eax
  80212a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80212f:	75 e6                	jne    802117 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802131:	b8 00 00 00 00       	mov    $0x0,%eax
  802136:	eb 0b                	jmp    802143 <ipc_find_env+0x37>
			return envs[i].env_id;
  802138:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80213b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802140:	8b 40 48             	mov    0x48(%eax),%eax
}
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    

00802145 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	c1 e8 16             	shr    $0x16,%eax
  802150:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802157:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80215c:	f6 c1 01             	test   $0x1,%cl
  80215f:	74 1d                	je     80217e <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802161:	c1 ea 0c             	shr    $0xc,%edx
  802164:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80216b:	f6 c2 01             	test   $0x1,%dl
  80216e:	74 0e                	je     80217e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802170:	c1 ea 0c             	shr    $0xc,%edx
  802173:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80217a:	ef 
  80217b:	0f b7 c0             	movzwl %ax,%eax
}
  80217e:	5d                   	pop    %ebp
  80217f:	c3                   	ret    

00802180 <__udivdi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80218b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80218f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802193:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802197:	85 d2                	test   %edx,%edx
  802199:	75 35                	jne    8021d0 <__udivdi3+0x50>
  80219b:	39 f3                	cmp    %esi,%ebx
  80219d:	0f 87 bd 00 00 00    	ja     802260 <__udivdi3+0xe0>
  8021a3:	85 db                	test   %ebx,%ebx
  8021a5:	89 d9                	mov    %ebx,%ecx
  8021a7:	75 0b                	jne    8021b4 <__udivdi3+0x34>
  8021a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	f7 f3                	div    %ebx
  8021b2:	89 c1                	mov    %eax,%ecx
  8021b4:	31 d2                	xor    %edx,%edx
  8021b6:	89 f0                	mov    %esi,%eax
  8021b8:	f7 f1                	div    %ecx
  8021ba:	89 c6                	mov    %eax,%esi
  8021bc:	89 e8                	mov    %ebp,%eax
  8021be:	89 f7                	mov    %esi,%edi
  8021c0:	f7 f1                	div    %ecx
  8021c2:	89 fa                	mov    %edi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	39 f2                	cmp    %esi,%edx
  8021d2:	77 7c                	ja     802250 <__udivdi3+0xd0>
  8021d4:	0f bd fa             	bsr    %edx,%edi
  8021d7:	83 f7 1f             	xor    $0x1f,%edi
  8021da:	0f 84 98 00 00 00    	je     802278 <__udivdi3+0xf8>
  8021e0:	89 f9                	mov    %edi,%ecx
  8021e2:	b8 20 00 00 00       	mov    $0x20,%eax
  8021e7:	29 f8                	sub    %edi,%eax
  8021e9:	d3 e2                	shl    %cl,%edx
  8021eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021ef:	89 c1                	mov    %eax,%ecx
  8021f1:	89 da                	mov    %ebx,%edx
  8021f3:	d3 ea                	shr    %cl,%edx
  8021f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021f9:	09 d1                	or     %edx,%ecx
  8021fb:	89 f2                	mov    %esi,%edx
  8021fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802201:	89 f9                	mov    %edi,%ecx
  802203:	d3 e3                	shl    %cl,%ebx
  802205:	89 c1                	mov    %eax,%ecx
  802207:	d3 ea                	shr    %cl,%edx
  802209:	89 f9                	mov    %edi,%ecx
  80220b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80220f:	d3 e6                	shl    %cl,%esi
  802211:	89 eb                	mov    %ebp,%ebx
  802213:	89 c1                	mov    %eax,%ecx
  802215:	d3 eb                	shr    %cl,%ebx
  802217:	09 de                	or     %ebx,%esi
  802219:	89 f0                	mov    %esi,%eax
  80221b:	f7 74 24 08          	divl   0x8(%esp)
  80221f:	89 d6                	mov    %edx,%esi
  802221:	89 c3                	mov    %eax,%ebx
  802223:	f7 64 24 0c          	mull   0xc(%esp)
  802227:	39 d6                	cmp    %edx,%esi
  802229:	72 0c                	jb     802237 <__udivdi3+0xb7>
  80222b:	89 f9                	mov    %edi,%ecx
  80222d:	d3 e5                	shl    %cl,%ebp
  80222f:	39 c5                	cmp    %eax,%ebp
  802231:	73 5d                	jae    802290 <__udivdi3+0x110>
  802233:	39 d6                	cmp    %edx,%esi
  802235:	75 59                	jne    802290 <__udivdi3+0x110>
  802237:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80223a:	31 ff                	xor    %edi,%edi
  80223c:	89 fa                	mov    %edi,%edx
  80223e:	83 c4 1c             	add    $0x1c,%esp
  802241:	5b                   	pop    %ebx
  802242:	5e                   	pop    %esi
  802243:	5f                   	pop    %edi
  802244:	5d                   	pop    %ebp
  802245:	c3                   	ret    
  802246:	8d 76 00             	lea    0x0(%esi),%esi
  802249:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802250:	31 ff                	xor    %edi,%edi
  802252:	31 c0                	xor    %eax,%eax
  802254:	89 fa                	mov    %edi,%edx
  802256:	83 c4 1c             	add    $0x1c,%esp
  802259:	5b                   	pop    %ebx
  80225a:	5e                   	pop    %esi
  80225b:	5f                   	pop    %edi
  80225c:	5d                   	pop    %ebp
  80225d:	c3                   	ret    
  80225e:	66 90                	xchg   %ax,%ax
  802260:	31 ff                	xor    %edi,%edi
  802262:	89 e8                	mov    %ebp,%eax
  802264:	89 f2                	mov    %esi,%edx
  802266:	f7 f3                	div    %ebx
  802268:	89 fa                	mov    %edi,%edx
  80226a:	83 c4 1c             	add    $0x1c,%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5f                   	pop    %edi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    
  802272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802278:	39 f2                	cmp    %esi,%edx
  80227a:	72 06                	jb     802282 <__udivdi3+0x102>
  80227c:	31 c0                	xor    %eax,%eax
  80227e:	39 eb                	cmp    %ebp,%ebx
  802280:	77 d2                	ja     802254 <__udivdi3+0xd4>
  802282:	b8 01 00 00 00       	mov    $0x1,%eax
  802287:	eb cb                	jmp    802254 <__udivdi3+0xd4>
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 d8                	mov    %ebx,%eax
  802292:	31 ff                	xor    %edi,%edi
  802294:	eb be                	jmp    802254 <__udivdi3+0xd4>
  802296:	66 90                	xchg   %ax,%ax
  802298:	66 90                	xchg   %ax,%ax
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 1c             	sub    $0x1c,%esp
  8022a7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8022ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b7:	85 ed                	test   %ebp,%ebp
  8022b9:	89 f0                	mov    %esi,%eax
  8022bb:	89 da                	mov    %ebx,%edx
  8022bd:	75 19                	jne    8022d8 <__umoddi3+0x38>
  8022bf:	39 df                	cmp    %ebx,%edi
  8022c1:	0f 86 b1 00 00 00    	jbe    802378 <__umoddi3+0xd8>
  8022c7:	f7 f7                	div    %edi
  8022c9:	89 d0                	mov    %edx,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	83 c4 1c             	add    $0x1c,%esp
  8022d0:	5b                   	pop    %ebx
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
  8022d8:	39 dd                	cmp    %ebx,%ebp
  8022da:	77 f1                	ja     8022cd <__umoddi3+0x2d>
  8022dc:	0f bd cd             	bsr    %ebp,%ecx
  8022df:	83 f1 1f             	xor    $0x1f,%ecx
  8022e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8022e6:	0f 84 b4 00 00 00    	je     8023a0 <__umoddi3+0x100>
  8022ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8022f1:	89 c2                	mov    %eax,%edx
  8022f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022f7:	29 c2                	sub    %eax,%edx
  8022f9:	89 c1                	mov    %eax,%ecx
  8022fb:	89 f8                	mov    %edi,%eax
  8022fd:	d3 e5                	shl    %cl,%ebp
  8022ff:	89 d1                	mov    %edx,%ecx
  802301:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802305:	d3 e8                	shr    %cl,%eax
  802307:	09 c5                	or     %eax,%ebp
  802309:	8b 44 24 04          	mov    0x4(%esp),%eax
  80230d:	89 c1                	mov    %eax,%ecx
  80230f:	d3 e7                	shl    %cl,%edi
  802311:	89 d1                	mov    %edx,%ecx
  802313:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802317:	89 df                	mov    %ebx,%edi
  802319:	d3 ef                	shr    %cl,%edi
  80231b:	89 c1                	mov    %eax,%ecx
  80231d:	89 f0                	mov    %esi,%eax
  80231f:	d3 e3                	shl    %cl,%ebx
  802321:	89 d1                	mov    %edx,%ecx
  802323:	89 fa                	mov    %edi,%edx
  802325:	d3 e8                	shr    %cl,%eax
  802327:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80232c:	09 d8                	or     %ebx,%eax
  80232e:	f7 f5                	div    %ebp
  802330:	d3 e6                	shl    %cl,%esi
  802332:	89 d1                	mov    %edx,%ecx
  802334:	f7 64 24 08          	mull   0x8(%esp)
  802338:	39 d1                	cmp    %edx,%ecx
  80233a:	89 c3                	mov    %eax,%ebx
  80233c:	89 d7                	mov    %edx,%edi
  80233e:	72 06                	jb     802346 <__umoddi3+0xa6>
  802340:	75 0e                	jne    802350 <__umoddi3+0xb0>
  802342:	39 c6                	cmp    %eax,%esi
  802344:	73 0a                	jae    802350 <__umoddi3+0xb0>
  802346:	2b 44 24 08          	sub    0x8(%esp),%eax
  80234a:	19 ea                	sbb    %ebp,%edx
  80234c:	89 d7                	mov    %edx,%edi
  80234e:	89 c3                	mov    %eax,%ebx
  802350:	89 ca                	mov    %ecx,%edx
  802352:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802357:	29 de                	sub    %ebx,%esi
  802359:	19 fa                	sbb    %edi,%edx
  80235b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80235f:	89 d0                	mov    %edx,%eax
  802361:	d3 e0                	shl    %cl,%eax
  802363:	89 d9                	mov    %ebx,%ecx
  802365:	d3 ee                	shr    %cl,%esi
  802367:	d3 ea                	shr    %cl,%edx
  802369:	09 f0                	or     %esi,%eax
  80236b:	83 c4 1c             	add    $0x1c,%esp
  80236e:	5b                   	pop    %ebx
  80236f:	5e                   	pop    %esi
  802370:	5f                   	pop    %edi
  802371:	5d                   	pop    %ebp
  802372:	c3                   	ret    
  802373:	90                   	nop
  802374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802378:	85 ff                	test   %edi,%edi
  80237a:	89 f9                	mov    %edi,%ecx
  80237c:	75 0b                	jne    802389 <__umoddi3+0xe9>
  80237e:	b8 01 00 00 00       	mov    $0x1,%eax
  802383:	31 d2                	xor    %edx,%edx
  802385:	f7 f7                	div    %edi
  802387:	89 c1                	mov    %eax,%ecx
  802389:	89 d8                	mov    %ebx,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	f7 f1                	div    %ecx
  80238f:	89 f0                	mov    %esi,%eax
  802391:	f7 f1                	div    %ecx
  802393:	e9 31 ff ff ff       	jmp    8022c9 <__umoddi3+0x29>
  802398:	90                   	nop
  802399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	39 dd                	cmp    %ebx,%ebp
  8023a2:	72 08                	jb     8023ac <__umoddi3+0x10c>
  8023a4:	39 f7                	cmp    %esi,%edi
  8023a6:	0f 87 21 ff ff ff    	ja     8022cd <__umoddi3+0x2d>
  8023ac:	89 da                	mov    %ebx,%edx
  8023ae:	89 f0                	mov    %esi,%eax
  8023b0:	29 f8                	sub    %edi,%eax
  8023b2:	19 ea                	sbb    %ebp,%edx
  8023b4:	e9 14 ff ff ff       	jmp    8022cd <__umoddi3+0x2d>
