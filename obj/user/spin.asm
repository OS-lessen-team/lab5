
obj/user/spin.debug：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 a0 21 80 00       	push   $0x8021a0
  80003f:	e8 66 01 00 00       	call   8001aa <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 6c 0e 00 00       	call   800eb5 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 18 22 80 00       	push   $0x802218
  800058:	e8 4d 01 00 00       	call   8001aa <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 c8 21 80 00       	push   $0x8021c8
  80006c:	e8 39 01 00 00       	call   8001aa <cprintf>
	sys_yield();
  800071:	e8 2d 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  800076:	e8 28 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  80007b:	e8 23 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  800080:	e8 1e 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  800085:	e8 19 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  80008a:	e8 14 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  80008f:	e8 0f 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  800094:	e8 0a 0b 00 00       	call   800ba3 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 f0 21 80 00 	movl   $0x8021f0,(%esp)
  8000a0:	e8 05 01 00 00       	call   8001aa <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 96 0a 00 00       	call   800b43 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000c0:	e8 bf 0a 00 00       	call   800b84 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 75 11 00 00       	call   80127b <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 33 0a 00 00       	call   800b43 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	74 09                	je     80013d <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800134:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 b8 09 00 00       	call   800b06 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	eb db                	jmp    800134 <putch+0x1f>

00800159 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800162:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800169:	00 00 00 
	b.cnt = 0;
  80016c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800173:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800176:	ff 75 0c             	pushl  0xc(%ebp)
  800179:	ff 75 08             	pushl  0x8(%ebp)
  80017c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	68 15 01 80 00       	push   $0x800115
  800188:	e8 1a 01 00 00       	call   8002a7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018d:	83 c4 08             	add    $0x8,%esp
  800190:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800196:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019c:	50                   	push   %eax
  80019d:	e8 64 09 00 00       	call   800b06 <sys_cputs>

	return b.cnt;
}
  8001a2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b3:	50                   	push   %eax
  8001b4:	ff 75 08             	pushl  0x8(%ebp)
  8001b7:	e8 9d ff ff ff       	call   800159 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	57                   	push   %edi
  8001c2:	56                   	push   %esi
  8001c3:	53                   	push   %ebx
  8001c4:	83 ec 1c             	sub    $0x1c,%esp
  8001c7:	89 c7                	mov    %eax,%edi
  8001c9:	89 d6                	mov    %edx,%esi
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001df:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e5:	39 d3                	cmp    %edx,%ebx
  8001e7:	72 05                	jb     8001ee <printnum+0x30>
  8001e9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ec:	77 7a                	ja     800268 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ee:	83 ec 0c             	sub    $0xc,%esp
  8001f1:	ff 75 18             	pushl  0x18(%ebp)
  8001f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001fa:	53                   	push   %ebx
  8001fb:	ff 75 10             	pushl  0x10(%ebp)
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	ff 75 e4             	pushl  -0x1c(%ebp)
  800204:	ff 75 e0             	pushl  -0x20(%ebp)
  800207:	ff 75 dc             	pushl  -0x24(%ebp)
  80020a:	ff 75 d8             	pushl  -0x28(%ebp)
  80020d:	e8 4e 1d 00 00       	call   801f60 <__udivdi3>
  800212:	83 c4 18             	add    $0x18,%esp
  800215:	52                   	push   %edx
  800216:	50                   	push   %eax
  800217:	89 f2                	mov    %esi,%edx
  800219:	89 f8                	mov    %edi,%eax
  80021b:	e8 9e ff ff ff       	call   8001be <printnum>
  800220:	83 c4 20             	add    $0x20,%esp
  800223:	eb 13                	jmp    800238 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800225:	83 ec 08             	sub    $0x8,%esp
  800228:	56                   	push   %esi
  800229:	ff 75 18             	pushl  0x18(%ebp)
  80022c:	ff d7                	call   *%edi
  80022e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800231:	83 eb 01             	sub    $0x1,%ebx
  800234:	85 db                	test   %ebx,%ebx
  800236:	7f ed                	jg     800225 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800238:	83 ec 08             	sub    $0x8,%esp
  80023b:	56                   	push   %esi
  80023c:	83 ec 04             	sub    $0x4,%esp
  80023f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800242:	ff 75 e0             	pushl  -0x20(%ebp)
  800245:	ff 75 dc             	pushl  -0x24(%ebp)
  800248:	ff 75 d8             	pushl  -0x28(%ebp)
  80024b:	e8 30 1e 00 00       	call   802080 <__umoddi3>
  800250:	83 c4 14             	add    $0x14,%esp
  800253:	0f be 80 40 22 80 00 	movsbl 0x802240(%eax),%eax
  80025a:	50                   	push   %eax
  80025b:	ff d7                	call   *%edi
}
  80025d:	83 c4 10             	add    $0x10,%esp
  800260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5f                   	pop    %edi
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    
  800268:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026b:	eb c4                	jmp    800231 <printnum+0x73>

0080026d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800273:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800277:	8b 10                	mov    (%eax),%edx
  800279:	3b 50 04             	cmp    0x4(%eax),%edx
  80027c:	73 0a                	jae    800288 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 45 08             	mov    0x8(%ebp),%eax
  800286:	88 02                	mov    %al,(%edx)
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <printfmt>:
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800290:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800293:	50                   	push   %eax
  800294:	ff 75 10             	pushl  0x10(%ebp)
  800297:	ff 75 0c             	pushl  0xc(%ebp)
  80029a:	ff 75 08             	pushl  0x8(%ebp)
  80029d:	e8 05 00 00 00       	call   8002a7 <vprintfmt>
}
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <vprintfmt>:
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 2c             	sub    $0x2c,%esp
  8002b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b9:	e9 c1 03 00 00       	jmp    80067f <vprintfmt+0x3d8>
		padc = ' ';
  8002be:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002c2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002c9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002d0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002d7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8d 47 01             	lea    0x1(%edi),%eax
  8002df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e2:	0f b6 17             	movzbl (%edi),%edx
  8002e5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002e8:	3c 55                	cmp    $0x55,%al
  8002ea:	0f 87 12 04 00 00    	ja     800702 <vprintfmt+0x45b>
  8002f0:	0f b6 c0             	movzbl %al,%eax
  8002f3:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
  8002fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002fd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800301:	eb d9                	jmp    8002dc <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800306:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030a:	eb d0                	jmp    8002dc <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80030c:	0f b6 d2             	movzbl %dl,%edx
  80030f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800312:	b8 00 00 00 00       	mov    $0x0,%eax
  800317:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80031a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800321:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800324:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800327:	83 f9 09             	cmp    $0x9,%ecx
  80032a:	77 55                	ja     800381 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80032c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80032f:	eb e9                	jmp    80031a <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800331:	8b 45 14             	mov    0x14(%ebp),%eax
  800334:	8b 00                	mov    (%eax),%eax
  800336:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800339:	8b 45 14             	mov    0x14(%ebp),%eax
  80033c:	8d 40 04             	lea    0x4(%eax),%eax
  80033f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800345:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800349:	79 91                	jns    8002dc <vprintfmt+0x35>
				width = precision, precision = -1;
  80034b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80034e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800351:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800358:	eb 82                	jmp    8002dc <vprintfmt+0x35>
  80035a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035d:	85 c0                	test   %eax,%eax
  80035f:	ba 00 00 00 00       	mov    $0x0,%edx
  800364:	0f 49 d0             	cmovns %eax,%edx
  800367:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036d:	e9 6a ff ff ff       	jmp    8002dc <vprintfmt+0x35>
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800375:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037c:	e9 5b ff ff ff       	jmp    8002dc <vprintfmt+0x35>
  800381:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800384:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800387:	eb bc                	jmp    800345 <vprintfmt+0x9e>
			lflag++;
  800389:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038f:	e9 48 ff ff ff       	jmp    8002dc <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 78 04             	lea    0x4(%eax),%edi
  80039a:	83 ec 08             	sub    $0x8,%esp
  80039d:	53                   	push   %ebx
  80039e:	ff 30                	pushl  (%eax)
  8003a0:	ff d6                	call   *%esi
			break;
  8003a2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a8:	e9 cf 02 00 00       	jmp    80067c <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 78 04             	lea    0x4(%eax),%edi
  8003b3:	8b 00                	mov    (%eax),%eax
  8003b5:	99                   	cltd   
  8003b6:	31 d0                	xor    %edx,%eax
  8003b8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ba:	83 f8 0f             	cmp    $0xf,%eax
  8003bd:	7f 23                	jg     8003e2 <vprintfmt+0x13b>
  8003bf:	8b 14 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%edx
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	74 18                	je     8003e2 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003ca:	52                   	push   %edx
  8003cb:	68 a5 26 80 00       	push   $0x8026a5
  8003d0:	53                   	push   %ebx
  8003d1:	56                   	push   %esi
  8003d2:	e8 b3 fe ff ff       	call   80028a <printfmt>
  8003d7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003da:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003dd:	e9 9a 02 00 00       	jmp    80067c <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003e2:	50                   	push   %eax
  8003e3:	68 58 22 80 00       	push   $0x802258
  8003e8:	53                   	push   %ebx
  8003e9:	56                   	push   %esi
  8003ea:	e8 9b fe ff ff       	call   80028a <printfmt>
  8003ef:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f5:	e9 82 02 00 00       	jmp    80067c <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	83 c0 04             	add    $0x4,%eax
  800400:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800408:	85 ff                	test   %edi,%edi
  80040a:	b8 51 22 80 00       	mov    $0x802251,%eax
  80040f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800412:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800416:	0f 8e bd 00 00 00    	jle    8004d9 <vprintfmt+0x232>
  80041c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800420:	75 0e                	jne    800430 <vprintfmt+0x189>
  800422:	89 75 08             	mov    %esi,0x8(%ebp)
  800425:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800428:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80042b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80042e:	eb 6d                	jmp    80049d <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800430:	83 ec 08             	sub    $0x8,%esp
  800433:	ff 75 d0             	pushl  -0x30(%ebp)
  800436:	57                   	push   %edi
  800437:	e8 6e 03 00 00       	call   8007aa <strnlen>
  80043c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043f:	29 c1                	sub    %eax,%ecx
  800441:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800444:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800447:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800451:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	eb 0f                	jmp    800464 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	53                   	push   %ebx
  800459:	ff 75 e0             	pushl  -0x20(%ebp)
  80045c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	83 ef 01             	sub    $0x1,%edi
  800461:	83 c4 10             	add    $0x10,%esp
  800464:	85 ff                	test   %edi,%edi
  800466:	7f ed                	jg     800455 <vprintfmt+0x1ae>
  800468:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80046e:	85 c9                	test   %ecx,%ecx
  800470:	b8 00 00 00 00       	mov    $0x0,%eax
  800475:	0f 49 c1             	cmovns %ecx,%eax
  800478:	29 c1                	sub    %eax,%ecx
  80047a:	89 75 08             	mov    %esi,0x8(%ebp)
  80047d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800480:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800483:	89 cb                	mov    %ecx,%ebx
  800485:	eb 16                	jmp    80049d <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800487:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048b:	75 31                	jne    8004be <vprintfmt+0x217>
					putch(ch, putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 0c             	pushl  0xc(%ebp)
  800493:	50                   	push   %eax
  800494:	ff 55 08             	call   *0x8(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049a:	83 eb 01             	sub    $0x1,%ebx
  80049d:	83 c7 01             	add    $0x1,%edi
  8004a0:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004a4:	0f be c2             	movsbl %dl,%eax
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	74 59                	je     800504 <vprintfmt+0x25d>
  8004ab:	85 f6                	test   %esi,%esi
  8004ad:	78 d8                	js     800487 <vprintfmt+0x1e0>
  8004af:	83 ee 01             	sub    $0x1,%esi
  8004b2:	79 d3                	jns    800487 <vprintfmt+0x1e0>
  8004b4:	89 df                	mov    %ebx,%edi
  8004b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004bc:	eb 37                	jmp    8004f5 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004be:	0f be d2             	movsbl %dl,%edx
  8004c1:	83 ea 20             	sub    $0x20,%edx
  8004c4:	83 fa 5e             	cmp    $0x5e,%edx
  8004c7:	76 c4                	jbe    80048d <vprintfmt+0x1e6>
					putch('?', putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	6a 3f                	push   $0x3f
  8004d1:	ff 55 08             	call   *0x8(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	eb c1                	jmp    80049a <vprintfmt+0x1f3>
  8004d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e5:	eb b6                	jmp    80049d <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	6a 20                	push   $0x20
  8004ed:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004ef:	83 ef 01             	sub    $0x1,%edi
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	85 ff                	test   %edi,%edi
  8004f7:	7f ee                	jg     8004e7 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ff:	e9 78 01 00 00       	jmp    80067c <vprintfmt+0x3d5>
  800504:	89 df                	mov    %ebx,%edi
  800506:	8b 75 08             	mov    0x8(%ebp),%esi
  800509:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050c:	eb e7                	jmp    8004f5 <vprintfmt+0x24e>
	if (lflag >= 2)
  80050e:	83 f9 01             	cmp    $0x1,%ecx
  800511:	7e 3f                	jle    800552 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8b 50 04             	mov    0x4(%eax),%edx
  800519:	8b 00                	mov    (%eax),%eax
  80051b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 40 08             	lea    0x8(%eax),%eax
  800527:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80052a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80052e:	79 5c                	jns    80058c <vprintfmt+0x2e5>
				putch('-', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	53                   	push   %ebx
  800534:	6a 2d                	push   $0x2d
  800536:	ff d6                	call   *%esi
				num = -(long long) num;
  800538:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80053e:	f7 da                	neg    %edx
  800540:	83 d1 00             	adc    $0x0,%ecx
  800543:	f7 d9                	neg    %ecx
  800545:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800548:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054d:	e9 10 01 00 00       	jmp    800662 <vprintfmt+0x3bb>
	else if (lflag)
  800552:	85 c9                	test   %ecx,%ecx
  800554:	75 1b                	jne    800571 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055e:	89 c1                	mov    %eax,%ecx
  800560:	c1 f9 1f             	sar    $0x1f,%ecx
  800563:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 40 04             	lea    0x4(%eax),%eax
  80056c:	89 45 14             	mov    %eax,0x14(%ebp)
  80056f:	eb b9                	jmp    80052a <vprintfmt+0x283>
		return va_arg(*ap, long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 c1                	mov    %eax,%ecx
  80057b:	c1 f9 1f             	sar    $0x1f,%ecx
  80057e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 40 04             	lea    0x4(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
  80058a:	eb 9e                	jmp    80052a <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80058c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
  800597:	e9 c6 00 00 00       	jmp    800662 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80059c:	83 f9 01             	cmp    $0x1,%ecx
  80059f:	7e 18                	jle    8005b9 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 10                	mov    (%eax),%edx
  8005a6:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a9:	8d 40 08             	lea    0x8(%eax),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b4:	e9 a9 00 00 00       	jmp    800662 <vprintfmt+0x3bb>
	else if (lflag)
  8005b9:	85 c9                	test   %ecx,%ecx
  8005bb:	75 1a                	jne    8005d7 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 10                	mov    (%eax),%edx
  8005c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d2:	e9 8b 00 00 00       	jmp    800662 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e1:	8d 40 04             	lea    0x4(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ec:	eb 74                	jmp    800662 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005ee:	83 f9 01             	cmp    $0x1,%ecx
  8005f1:	7e 15                	jle    800608 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005fb:	8d 40 08             	lea    0x8(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800601:	b8 08 00 00 00       	mov    $0x8,%eax
  800606:	eb 5a                	jmp    800662 <vprintfmt+0x3bb>
	else if (lflag)
  800608:	85 c9                	test   %ecx,%ecx
  80060a:	75 17                	jne    800623 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80061c:	b8 08 00 00 00       	mov    $0x8,%eax
  800621:	eb 3f                	jmp    800662 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 10                	mov    (%eax),%edx
  800628:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062d:	8d 40 04             	lea    0x4(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800633:	b8 08 00 00 00       	mov    $0x8,%eax
  800638:	eb 28                	jmp    800662 <vprintfmt+0x3bb>
			putch('0', putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	6a 30                	push   $0x30
  800640:	ff d6                	call   *%esi
			putch('x', putdat);
  800642:	83 c4 08             	add    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	6a 78                	push   $0x78
  800648:	ff d6                	call   *%esi
			num = (unsigned long long)
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 10                	mov    (%eax),%edx
  80064f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800654:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800657:	8d 40 04             	lea    0x4(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800662:	83 ec 0c             	sub    $0xc,%esp
  800665:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800669:	57                   	push   %edi
  80066a:	ff 75 e0             	pushl  -0x20(%ebp)
  80066d:	50                   	push   %eax
  80066e:	51                   	push   %ecx
  80066f:	52                   	push   %edx
  800670:	89 da                	mov    %ebx,%edx
  800672:	89 f0                	mov    %esi,%eax
  800674:	e8 45 fb ff ff       	call   8001be <printnum>
			break;
  800679:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067f:	83 c7 01             	add    $0x1,%edi
  800682:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800686:	83 f8 25             	cmp    $0x25,%eax
  800689:	0f 84 2f fc ff ff    	je     8002be <vprintfmt+0x17>
			if (ch == '\0')
  80068f:	85 c0                	test   %eax,%eax
  800691:	0f 84 8b 00 00 00    	je     800722 <vprintfmt+0x47b>
			putch(ch, putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	50                   	push   %eax
  80069c:	ff d6                	call   *%esi
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb dc                	jmp    80067f <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006a3:	83 f9 01             	cmp    $0x1,%ecx
  8006a6:	7e 15                	jle    8006bd <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b0:	8d 40 08             	lea    0x8(%eax),%eax
  8006b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006bb:	eb a5                	jmp    800662 <vprintfmt+0x3bb>
	else if (lflag)
  8006bd:	85 c9                	test   %ecx,%ecx
  8006bf:	75 17                	jne    8006d8 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cb:	8d 40 04             	lea    0x4(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d6:	eb 8a                	jmp    800662 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8b 10                	mov    (%eax),%edx
  8006dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e2:	8d 40 04             	lea    0x4(%eax),%eax
  8006e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ed:	e9 70 ff ff ff       	jmp    800662 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			break;
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	e9 7a ff ff ff       	jmp    80067c <vprintfmt+0x3d5>
			putch('%', putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	6a 25                	push   $0x25
  800708:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	89 f8                	mov    %edi,%eax
  80070f:	eb 03                	jmp    800714 <vprintfmt+0x46d>
  800711:	83 e8 01             	sub    $0x1,%eax
  800714:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800718:	75 f7                	jne    800711 <vprintfmt+0x46a>
  80071a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071d:	e9 5a ff ff ff       	jmp    80067c <vprintfmt+0x3d5>
}
  800722:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 18             	sub    $0x18,%esp
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800736:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800739:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800740:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800747:	85 c0                	test   %eax,%eax
  800749:	74 26                	je     800771 <vsnprintf+0x47>
  80074b:	85 d2                	test   %edx,%edx
  80074d:	7e 22                	jle    800771 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074f:	ff 75 14             	pushl  0x14(%ebp)
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	50                   	push   %eax
  800759:	68 6d 02 80 00       	push   $0x80026d
  80075e:	e8 44 fb ff ff       	call   8002a7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800763:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800766:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076c:	83 c4 10             	add    $0x10,%esp
}
  80076f:	c9                   	leave  
  800770:	c3                   	ret    
		return -E_INVAL;
  800771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800776:	eb f7                	jmp    80076f <vsnprintf+0x45>

00800778 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800781:	50                   	push   %eax
  800782:	ff 75 10             	pushl  0x10(%ebp)
  800785:	ff 75 0c             	pushl  0xc(%ebp)
  800788:	ff 75 08             	pushl  0x8(%ebp)
  80078b:	e8 9a ff ff ff       	call   80072a <vsnprintf>
	va_end(ap);

	return rc;
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800798:	b8 00 00 00 00       	mov    $0x0,%eax
  80079d:	eb 03                	jmp    8007a2 <strlen+0x10>
		n++;
  80079f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a6:	75 f7                	jne    80079f <strlen+0xd>
	return n;
}
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b8:	eb 03                	jmp    8007bd <strnlen+0x13>
		n++;
  8007ba:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bd:	39 d0                	cmp    %edx,%eax
  8007bf:	74 06                	je     8007c7 <strnlen+0x1d>
  8007c1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c5:	75 f3                	jne    8007ba <strnlen+0x10>
	return n;
}
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	53                   	push   %ebx
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d3:	89 c2                	mov    %eax,%edx
  8007d5:	83 c1 01             	add    $0x1,%ecx
  8007d8:	83 c2 01             	add    $0x1,%edx
  8007db:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007df:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e2:	84 db                	test   %bl,%bl
  8007e4:	75 ef                	jne    8007d5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e6:	5b                   	pop    %ebx
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f0:	53                   	push   %ebx
  8007f1:	e8 9c ff ff ff       	call   800792 <strlen>
  8007f6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f9:	ff 75 0c             	pushl  0xc(%ebp)
  8007fc:	01 d8                	add    %ebx,%eax
  8007fe:	50                   	push   %eax
  8007ff:	e8 c5 ff ff ff       	call   8007c9 <strcpy>
	return dst;
}
  800804:	89 d8                	mov    %ebx,%eax
  800806:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800816:	89 f3                	mov    %esi,%ebx
  800818:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	89 f2                	mov    %esi,%edx
  80081d:	eb 0f                	jmp    80082e <strncpy+0x23>
		*dst++ = *src;
  80081f:	83 c2 01             	add    $0x1,%edx
  800822:	0f b6 01             	movzbl (%ecx),%eax
  800825:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800828:	80 39 01             	cmpb   $0x1,(%ecx)
  80082b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80082e:	39 da                	cmp    %ebx,%edx
  800830:	75 ed                	jne    80081f <strncpy+0x14>
	}
	return ret;
}
  800832:	89 f0                	mov    %esi,%eax
  800834:	5b                   	pop    %ebx
  800835:	5e                   	pop    %esi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	8b 75 08             	mov    0x8(%ebp),%esi
  800840:	8b 55 0c             	mov    0xc(%ebp),%edx
  800843:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800846:	89 f0                	mov    %esi,%eax
  800848:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084c:	85 c9                	test   %ecx,%ecx
  80084e:	75 0b                	jne    80085b <strlcpy+0x23>
  800850:	eb 17                	jmp    800869 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800852:	83 c2 01             	add    $0x1,%edx
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80085b:	39 d8                	cmp    %ebx,%eax
  80085d:	74 07                	je     800866 <strlcpy+0x2e>
  80085f:	0f b6 0a             	movzbl (%edx),%ecx
  800862:	84 c9                	test   %cl,%cl
  800864:	75 ec                	jne    800852 <strlcpy+0x1a>
		*dst = '\0';
  800866:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800869:	29 f0                	sub    %esi,%eax
}
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800875:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800878:	eb 06                	jmp    800880 <strcmp+0x11>
		p++, q++;
  80087a:	83 c1 01             	add    $0x1,%ecx
  80087d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800880:	0f b6 01             	movzbl (%ecx),%eax
  800883:	84 c0                	test   %al,%al
  800885:	74 04                	je     80088b <strcmp+0x1c>
  800887:	3a 02                	cmp    (%edx),%al
  800889:	74 ef                	je     80087a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088b:	0f b6 c0             	movzbl %al,%eax
  80088e:	0f b6 12             	movzbl (%edx),%edx
  800891:	29 d0                	sub    %edx,%eax
}
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	89 c3                	mov    %eax,%ebx
  8008a1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a4:	eb 06                	jmp    8008ac <strncmp+0x17>
		n--, p++, q++;
  8008a6:	83 c0 01             	add    $0x1,%eax
  8008a9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ac:	39 d8                	cmp    %ebx,%eax
  8008ae:	74 16                	je     8008c6 <strncmp+0x31>
  8008b0:	0f b6 08             	movzbl (%eax),%ecx
  8008b3:	84 c9                	test   %cl,%cl
  8008b5:	74 04                	je     8008bb <strncmp+0x26>
  8008b7:	3a 0a                	cmp    (%edx),%cl
  8008b9:	74 eb                	je     8008a6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 00             	movzbl (%eax),%eax
  8008be:	0f b6 12             	movzbl (%edx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
}
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    
		return 0;
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	eb f6                	jmp    8008c3 <strncmp+0x2e>

008008cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d7:	0f b6 10             	movzbl (%eax),%edx
  8008da:	84 d2                	test   %dl,%dl
  8008dc:	74 09                	je     8008e7 <strchr+0x1a>
		if (*s == c)
  8008de:	38 ca                	cmp    %cl,%dl
  8008e0:	74 0a                	je     8008ec <strchr+0x1f>
	for (; *s; s++)
  8008e2:	83 c0 01             	add    $0x1,%eax
  8008e5:	eb f0                	jmp    8008d7 <strchr+0xa>
			return (char *) s;
	return 0;
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f8:	eb 03                	jmp    8008fd <strfind+0xf>
  8008fa:	83 c0 01             	add    $0x1,%eax
  8008fd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	74 04                	je     800908 <strfind+0x1a>
  800904:	84 d2                	test   %dl,%dl
  800906:	75 f2                	jne    8008fa <strfind+0xc>
			break;
	return (char *) s;
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	57                   	push   %edi
  80090e:	56                   	push   %esi
  80090f:	53                   	push   %ebx
  800910:	8b 7d 08             	mov    0x8(%ebp),%edi
  800913:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800916:	85 c9                	test   %ecx,%ecx
  800918:	74 13                	je     80092d <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800920:	75 05                	jne    800927 <memset+0x1d>
  800922:	f6 c1 03             	test   $0x3,%cl
  800925:	74 0d                	je     800934 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	fc                   	cld    
  80092b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5f                   	pop    %edi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    
		c &= 0xFF;
  800934:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800938:	89 d3                	mov    %edx,%ebx
  80093a:	c1 e3 08             	shl    $0x8,%ebx
  80093d:	89 d0                	mov    %edx,%eax
  80093f:	c1 e0 18             	shl    $0x18,%eax
  800942:	89 d6                	mov    %edx,%esi
  800944:	c1 e6 10             	shl    $0x10,%esi
  800947:	09 f0                	or     %esi,%eax
  800949:	09 c2                	or     %eax,%edx
  80094b:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80094d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800950:	89 d0                	mov    %edx,%eax
  800952:	fc                   	cld    
  800953:	f3 ab                	rep stos %eax,%es:(%edi)
  800955:	eb d6                	jmp    80092d <memset+0x23>

00800957 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	57                   	push   %edi
  80095b:	56                   	push   %esi
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800965:	39 c6                	cmp    %eax,%esi
  800967:	73 35                	jae    80099e <memmove+0x47>
  800969:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096c:	39 c2                	cmp    %eax,%edx
  80096e:	76 2e                	jbe    80099e <memmove+0x47>
		s += n;
		d += n;
  800970:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	89 d6                	mov    %edx,%esi
  800975:	09 fe                	or     %edi,%esi
  800977:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097d:	74 0c                	je     80098b <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097f:	83 ef 01             	sub    $0x1,%edi
  800982:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800985:	fd                   	std    
  800986:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800988:	fc                   	cld    
  800989:	eb 21                	jmp    8009ac <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098b:	f6 c1 03             	test   $0x3,%cl
  80098e:	75 ef                	jne    80097f <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800990:	83 ef 04             	sub    $0x4,%edi
  800993:	8d 72 fc             	lea    -0x4(%edx),%esi
  800996:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800999:	fd                   	std    
  80099a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099c:	eb ea                	jmp    800988 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099e:	89 f2                	mov    %esi,%edx
  8009a0:	09 c2                	or     %eax,%edx
  8009a2:	f6 c2 03             	test   $0x3,%dl
  8009a5:	74 09                	je     8009b0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	fc                   	cld    
  8009aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ac:	5e                   	pop    %esi
  8009ad:	5f                   	pop    %edi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	f6 c1 03             	test   $0x3,%cl
  8009b3:	75 f2                	jne    8009a7 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b8:	89 c7                	mov    %eax,%edi
  8009ba:	fc                   	cld    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb ed                	jmp    8009ac <memmove+0x55>

008009bf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c2:	ff 75 10             	pushl  0x10(%ebp)
  8009c5:	ff 75 0c             	pushl  0xc(%ebp)
  8009c8:	ff 75 08             	pushl  0x8(%ebp)
  8009cb:	e8 87 ff ff ff       	call   800957 <memmove>
}
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dd:	89 c6                	mov    %eax,%esi
  8009df:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e2:	39 f0                	cmp    %esi,%eax
  8009e4:	74 1c                	je     800a02 <memcmp+0x30>
		if (*s1 != *s2)
  8009e6:	0f b6 08             	movzbl (%eax),%ecx
  8009e9:	0f b6 1a             	movzbl (%edx),%ebx
  8009ec:	38 d9                	cmp    %bl,%cl
  8009ee:	75 08                	jne    8009f8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	eb ea                	jmp    8009e2 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009f8:	0f b6 c1             	movzbl %cl,%eax
  8009fb:	0f b6 db             	movzbl %bl,%ebx
  8009fe:	29 d8                	sub    %ebx,%eax
  800a00:	eb 05                	jmp    800a07 <memcmp+0x35>
	}

	return 0;
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a14:	89 c2                	mov    %eax,%edx
  800a16:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a19:	39 d0                	cmp    %edx,%eax
  800a1b:	73 09                	jae    800a26 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1d:	38 08                	cmp    %cl,(%eax)
  800a1f:	74 05                	je     800a26 <memfind+0x1b>
	for (; s < ends; s++)
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	eb f3                	jmp    800a19 <memfind+0xe>
			break;
	return (void *) s;
}
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	53                   	push   %ebx
  800a2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a34:	eb 03                	jmp    800a39 <strtol+0x11>
		s++;
  800a36:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a39:	0f b6 01             	movzbl (%ecx),%eax
  800a3c:	3c 20                	cmp    $0x20,%al
  800a3e:	74 f6                	je     800a36 <strtol+0xe>
  800a40:	3c 09                	cmp    $0x9,%al
  800a42:	74 f2                	je     800a36 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a44:	3c 2b                	cmp    $0x2b,%al
  800a46:	74 2e                	je     800a76 <strtol+0x4e>
	int neg = 0;
  800a48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a4d:	3c 2d                	cmp    $0x2d,%al
  800a4f:	74 2f                	je     800a80 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a51:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a57:	75 05                	jne    800a5e <strtol+0x36>
  800a59:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5c:	74 2c                	je     800a8a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5e:	85 db                	test   %ebx,%ebx
  800a60:	75 0a                	jne    800a6c <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a62:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a67:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6a:	74 28                	je     800a94 <strtol+0x6c>
		base = 10;
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a71:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a74:	eb 50                	jmp    800ac6 <strtol+0x9e>
		s++;
  800a76:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a79:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7e:	eb d1                	jmp    800a51 <strtol+0x29>
		s++, neg = 1;
  800a80:	83 c1 01             	add    $0x1,%ecx
  800a83:	bf 01 00 00 00       	mov    $0x1,%edi
  800a88:	eb c7                	jmp    800a51 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8e:	74 0e                	je     800a9e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a90:	85 db                	test   %ebx,%ebx
  800a92:	75 d8                	jne    800a6c <strtol+0x44>
		s++, base = 8;
  800a94:	83 c1 01             	add    $0x1,%ecx
  800a97:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a9c:	eb ce                	jmp    800a6c <strtol+0x44>
		s += 2, base = 16;
  800a9e:	83 c1 02             	add    $0x2,%ecx
  800aa1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa6:	eb c4                	jmp    800a6c <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aa8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aab:	89 f3                	mov    %esi,%ebx
  800aad:	80 fb 19             	cmp    $0x19,%bl
  800ab0:	77 29                	ja     800adb <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ab2:	0f be d2             	movsbl %dl,%edx
  800ab5:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800abb:	7d 30                	jge    800aed <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800abd:	83 c1 01             	add    $0x1,%ecx
  800ac0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ac6:	0f b6 11             	movzbl (%ecx),%edx
  800ac9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800acc:	89 f3                	mov    %esi,%ebx
  800ace:	80 fb 09             	cmp    $0x9,%bl
  800ad1:	77 d5                	ja     800aa8 <strtol+0x80>
			dig = *s - '0';
  800ad3:	0f be d2             	movsbl %dl,%edx
  800ad6:	83 ea 30             	sub    $0x30,%edx
  800ad9:	eb dd                	jmp    800ab8 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800adb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ade:	89 f3                	mov    %esi,%ebx
  800ae0:	80 fb 19             	cmp    $0x19,%bl
  800ae3:	77 08                	ja     800aed <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ae5:	0f be d2             	movsbl %dl,%edx
  800ae8:	83 ea 37             	sub    $0x37,%edx
  800aeb:	eb cb                	jmp    800ab8 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af1:	74 05                	je     800af8 <strtol+0xd0>
		*endptr = (char *) s;
  800af3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800af8:	89 c2                	mov    %eax,%edx
  800afa:	f7 da                	neg    %edx
  800afc:	85 ff                	test   %edi,%edi
  800afe:	0f 45 c2             	cmovne %edx,%eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b17:	89 c3                	mov    %eax,%ebx
  800b19:	89 c7                	mov    %eax,%edi
  800b1b:	89 c6                	mov    %eax,%esi
  800b1d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b51:	8b 55 08             	mov    0x8(%ebp),%edx
  800b54:	b8 03 00 00 00       	mov    $0x3,%eax
  800b59:	89 cb                	mov    %ecx,%ebx
  800b5b:	89 cf                	mov    %ecx,%edi
  800b5d:	89 ce                	mov    %ecx,%esi
  800b5f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	7f 08                	jg     800b6d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6d:	83 ec 0c             	sub    $0xc,%esp
  800b70:	50                   	push   %eax
  800b71:	6a 03                	push   $0x3
  800b73:	68 3f 25 80 00       	push   $0x80253f
  800b78:	6a 23                	push   $0x23
  800b7a:	68 5c 25 80 00       	push   $0x80255c
  800b7f:	e8 cf 11 00 00       	call   801d53 <_panic>

00800b84 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b94:	89 d1                	mov    %edx,%ecx
  800b96:	89 d3                	mov    %edx,%ebx
  800b98:	89 d7                	mov    %edx,%edi
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_yield>:

void
sys_yield(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb3:	89 d1                	mov    %edx,%ecx
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	89 d7                	mov    %edx,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcb:	be 00 00 00 00       	mov    $0x0,%esi
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bde:	89 f7                	mov    %esi,%edi
  800be0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7f 08                	jg     800bee <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 04                	push   $0x4
  800bf4:	68 3f 25 80 00       	push   $0x80253f
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 5c 25 80 00       	push   $0x80255c
  800c00:	e8 4e 11 00 00       	call   801d53 <_panic>

00800c05 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	b8 05 00 00 00       	mov    $0x5,%eax
  800c19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c22:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7f 08                	jg     800c30 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 05                	push   $0x5
  800c36:	68 3f 25 80 00       	push   $0x80253f
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 5c 25 80 00       	push   $0x80255c
  800c42:	e8 0c 11 00 00       	call   801d53 <_panic>

00800c47 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7f 08                	jg     800c72 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 06                	push   $0x6
  800c78:	68 3f 25 80 00       	push   $0x80253f
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 5c 25 80 00       	push   $0x80255c
  800c84:	e8 ca 10 00 00       	call   801d53 <_panic>

00800c89 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca2:	89 df                	mov    %ebx,%edi
  800ca4:	89 de                	mov    %ebx,%esi
  800ca6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7f 08                	jg     800cb4 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 08                	push   $0x8
  800cba:	68 3f 25 80 00       	push   $0x80253f
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 5c 25 80 00       	push   $0x80255c
  800cc6:	e8 88 10 00 00       	call   801d53 <_panic>

00800ccb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7f 08                	jg     800cf6 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 09                	push   $0x9
  800cfc:	68 3f 25 80 00       	push   $0x80253f
  800d01:	6a 23                	push   $0x23
  800d03:	68 5c 25 80 00       	push   $0x80255c
  800d08:	e8 46 10 00 00       	call   801d53 <_panic>

00800d0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	89 de                	mov    %ebx,%esi
  800d2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7f 08                	jg     800d38 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	6a 0a                	push   $0xa
  800d3e:	68 3f 25 80 00       	push   $0x80253f
  800d43:	6a 23                	push   $0x23
  800d45:	68 5c 25 80 00       	push   $0x80255c
  800d4a:	e8 04 10 00 00       	call   801d53 <_panic>

00800d4f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d60:	be 00 00 00 00       	mov    $0x0,%esi
  800d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d68:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d88:	89 cb                	mov    %ecx,%ebx
  800d8a:	89 cf                	mov    %ecx,%edi
  800d8c:	89 ce                	mov    %ecx,%esi
  800d8e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d90:	85 c0                	test   %eax,%eax
  800d92:	7f 08                	jg     800d9c <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	50                   	push   %eax
  800da0:	6a 0d                	push   $0xd
  800da2:	68 3f 25 80 00       	push   $0x80253f
  800da7:	6a 23                	push   $0x23
  800da9:	68 5c 25 80 00       	push   $0x80255c
  800dae:	e8 a0 0f 00 00       	call   801d53 <_panic>

00800db3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	53                   	push   %ebx
  800db7:	83 ec 04             	sub    $0x4,%esp
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800dbd:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800dbf:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800dc3:	0f 84 9c 00 00 00    	je     800e65 <pgfault+0xb2>
  800dc9:	89 c2                	mov    %eax,%edx
  800dcb:	c1 ea 16             	shr    $0x16,%edx
  800dce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dd5:	f6 c2 01             	test   $0x1,%dl
  800dd8:	0f 84 87 00 00 00    	je     800e65 <pgfault+0xb2>
  800dde:	89 c2                	mov    %eax,%edx
  800de0:	c1 ea 0c             	shr    $0xc,%edx
  800de3:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dea:	f6 c1 01             	test   $0x1,%cl
  800ded:	74 76                	je     800e65 <pgfault+0xb2>
  800def:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df6:	f6 c6 08             	test   $0x8,%dh
  800df9:	74 6a                	je     800e65 <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  800dfb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e00:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800e02:	83 ec 04             	sub    $0x4,%esp
  800e05:	6a 07                	push   $0x7
  800e07:	68 00 f0 7f 00       	push   $0x7ff000
  800e0c:	6a 00                	push   $0x0
  800e0e:	e8 af fd ff ff       	call   800bc2 <sys_page_alloc>
  800e13:	83 c4 10             	add    $0x10,%esp
  800e16:	85 c0                	test   %eax,%eax
  800e18:	78 5f                	js     800e79 <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  800e1a:	83 ec 04             	sub    $0x4,%esp
  800e1d:	68 00 10 00 00       	push   $0x1000
  800e22:	53                   	push   %ebx
  800e23:	68 00 f0 7f 00       	push   $0x7ff000
  800e28:	e8 92 fb ff ff       	call   8009bf <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e2d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e34:	53                   	push   %ebx
  800e35:	6a 00                	push   $0x0
  800e37:	68 00 f0 7f 00       	push   $0x7ff000
  800e3c:	6a 00                	push   $0x0
  800e3e:	e8 c2 fd ff ff       	call   800c05 <sys_page_map>
  800e43:	83 c4 20             	add    $0x20,%esp
  800e46:	85 c0                	test   %eax,%eax
  800e48:	78 43                	js     800e8d <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	68 00 f0 7f 00       	push   $0x7ff000
  800e52:	6a 00                	push   $0x0
  800e54:	e8 ee fd ff ff       	call   800c47 <sys_page_unmap>
  800e59:	83 c4 10             	add    $0x10,%esp
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	78 41                	js     800ea1 <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  800e60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e63:	c9                   	leave  
  800e64:	c3                   	ret    
		panic("not copy-on-write");
  800e65:	83 ec 04             	sub    $0x4,%esp
  800e68:	68 6a 25 80 00       	push   $0x80256a
  800e6d:	6a 25                	push   $0x25
  800e6f:	68 7c 25 80 00       	push   $0x80257c
  800e74:	e8 da 0e 00 00       	call   801d53 <_panic>
		panic("sys_page_alloc");
  800e79:	83 ec 04             	sub    $0x4,%esp
  800e7c:	68 87 25 80 00       	push   $0x802587
  800e81:	6a 28                	push   $0x28
  800e83:	68 7c 25 80 00       	push   $0x80257c
  800e88:	e8 c6 0e 00 00       	call   801d53 <_panic>
		panic("sys_page_map");
  800e8d:	83 ec 04             	sub    $0x4,%esp
  800e90:	68 96 25 80 00       	push   $0x802596
  800e95:	6a 2b                	push   $0x2b
  800e97:	68 7c 25 80 00       	push   $0x80257c
  800e9c:	e8 b2 0e 00 00       	call   801d53 <_panic>
		panic("sys_page_unmap");
  800ea1:	83 ec 04             	sub    $0x4,%esp
  800ea4:	68 a3 25 80 00       	push   $0x8025a3
  800ea9:	6a 2d                	push   $0x2d
  800eab:	68 7c 25 80 00       	push   $0x80257c
  800eb0:	e8 9e 0e 00 00       	call   801d53 <_panic>

00800eb5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	57                   	push   %edi
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
  800ebb:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800ebe:	68 b3 0d 80 00       	push   $0x800db3
  800ec3:	e8 d1 0e 00 00       	call   801d99 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ec8:	b8 07 00 00 00       	mov    $0x7,%eax
  800ecd:	cd 30                	int    $0x30
  800ecf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800ed2:	83 c4 10             	add    $0x10,%esp
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	74 12                	je     800eeb <fork+0x36>
  800ed9:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  800edb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800edf:	78 26                	js     800f07 <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800ee1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee6:	e9 94 00 00 00       	jmp    800f7f <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eeb:	e8 94 fc ff ff       	call   800b84 <sys_getenvid>
  800ef0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ef8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800efd:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f02:	e9 51 01 00 00       	jmp    801058 <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  800f07:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f0a:	68 b2 25 80 00       	push   $0x8025b2
  800f0f:	6a 6e                	push   $0x6e
  800f11:	68 7c 25 80 00       	push   $0x80257c
  800f16:	e8 38 0e 00 00       	call   801d53 <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800f1b:	83 ec 0c             	sub    $0xc,%esp
  800f1e:	68 07 0e 00 00       	push   $0xe07
  800f23:	56                   	push   %esi
  800f24:	57                   	push   %edi
  800f25:	56                   	push   %esi
  800f26:	6a 00                	push   $0x0
  800f28:	e8 d8 fc ff ff       	call   800c05 <sys_page_map>
  800f2d:	83 c4 20             	add    $0x20,%esp
  800f30:	eb 3b                	jmp    800f6d <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f32:	83 ec 0c             	sub    $0xc,%esp
  800f35:	68 05 08 00 00       	push   $0x805
  800f3a:	56                   	push   %esi
  800f3b:	57                   	push   %edi
  800f3c:	56                   	push   %esi
  800f3d:	6a 00                	push   $0x0
  800f3f:	e8 c1 fc ff ff       	call   800c05 <sys_page_map>
  800f44:	83 c4 20             	add    $0x20,%esp
  800f47:	85 c0                	test   %eax,%eax
  800f49:	0f 88 a9 00 00 00    	js     800ff8 <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f4f:	83 ec 0c             	sub    $0xc,%esp
  800f52:	68 05 08 00 00       	push   $0x805
  800f57:	56                   	push   %esi
  800f58:	6a 00                	push   $0x0
  800f5a:	56                   	push   %esi
  800f5b:	6a 00                	push   $0x0
  800f5d:	e8 a3 fc ff ff       	call   800c05 <sys_page_map>
  800f62:	83 c4 20             	add    $0x20,%esp
  800f65:	85 c0                	test   %eax,%eax
  800f67:	0f 88 9d 00 00 00    	js     80100a <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f6d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f73:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f79:	0f 84 9d 00 00 00    	je     80101c <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800f7f:	89 d8                	mov    %ebx,%eax
  800f81:	c1 e8 16             	shr    $0x16,%eax
  800f84:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f8b:	a8 01                	test   $0x1,%al
  800f8d:	74 de                	je     800f6d <fork+0xb8>
  800f8f:	89 d8                	mov    %ebx,%eax
  800f91:	c1 e8 0c             	shr    $0xc,%eax
  800f94:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9b:	f6 c2 01             	test   $0x1,%dl
  800f9e:	74 cd                	je     800f6d <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800fa0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa7:	f6 c2 04             	test   $0x4,%dl
  800faa:	74 c1                	je     800f6d <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  800fac:	89 c6                	mov    %eax,%esi
  800fae:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  800fb1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb8:	f6 c6 04             	test   $0x4,%dh
  800fbb:	0f 85 5a ff ff ff    	jne    800f1b <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800fc1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc8:	f6 c2 02             	test   $0x2,%dl
  800fcb:	0f 85 61 ff ff ff    	jne    800f32 <fork+0x7d>
  800fd1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd8:	f6 c4 08             	test   $0x8,%ah
  800fdb:	0f 85 51 ff ff ff    	jne    800f32 <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	6a 05                	push   $0x5
  800fe6:	56                   	push   %esi
  800fe7:	57                   	push   %edi
  800fe8:	56                   	push   %esi
  800fe9:	6a 00                	push   $0x0
  800feb:	e8 15 fc ff ff       	call   800c05 <sys_page_map>
  800ff0:	83 c4 20             	add    $0x20,%esp
  800ff3:	e9 75 ff ff ff       	jmp    800f6d <fork+0xb8>
            		panic("sys_page_map：%e", r);
  800ff8:	50                   	push   %eax
  800ff9:	68 c2 25 80 00       	push   $0x8025c2
  800ffe:	6a 47                	push   $0x47
  801000:	68 7c 25 80 00       	push   $0x80257c
  801005:	e8 49 0d 00 00       	call   801d53 <_panic>
            		panic("sys_page_map：%e", r);
  80100a:	50                   	push   %eax
  80100b:	68 c2 25 80 00       	push   $0x8025c2
  801010:	6a 49                	push   $0x49
  801012:	68 7c 25 80 00       	push   $0x80257c
  801017:	e8 37 0d 00 00       	call   801d53 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	6a 07                	push   $0x7
  801021:	68 00 f0 bf ee       	push   $0xeebff000
  801026:	ff 75 e4             	pushl  -0x1c(%ebp)
  801029:	e8 94 fb ff ff       	call   800bc2 <sys_page_alloc>
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	78 2e                	js     801063 <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801035:	83 ec 08             	sub    $0x8,%esp
  801038:	68 08 1e 80 00       	push   $0x801e08
  80103d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801040:	57                   	push   %edi
  801041:	e8 c7 fc ff ff       	call   800d0d <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801046:	83 c4 08             	add    $0x8,%esp
  801049:	6a 02                	push   $0x2
  80104b:	57                   	push   %edi
  80104c:	e8 38 fc ff ff       	call   800c89 <sys_env_set_status>
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	85 c0                	test   %eax,%eax
  801056:	78 1f                	js     801077 <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  801058:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80105b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105e:	5b                   	pop    %ebx
  80105f:	5e                   	pop    %esi
  801060:	5f                   	pop    %edi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    
		panic("1");
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	68 d4 25 80 00       	push   $0x8025d4
  80106b:	6a 77                	push   $0x77
  80106d:	68 7c 25 80 00       	push   $0x80257c
  801072:	e8 dc 0c 00 00       	call   801d53 <_panic>
		panic("sys_env_set_status");
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	68 d6 25 80 00       	push   $0x8025d6
  80107f:	6a 7c                	push   $0x7c
  801081:	68 7c 25 80 00       	push   $0x80257c
  801086:	e8 c8 0c 00 00       	call   801d53 <_panic>

0080108b <sfork>:

// Challenge!
int
sfork(void)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801091:	68 e9 25 80 00       	push   $0x8025e9
  801096:	68 86 00 00 00       	push   $0x86
  80109b:	68 7c 25 80 00       	push   $0x80257c
  8010a0:	e8 ae 0c 00 00       	call   801d53 <_panic>

008010a5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ab:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b0:	c1 e8 0c             	shr    $0xc,%eax
}
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bb:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010c5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    

008010cc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010d7:	89 c2                	mov    %eax,%edx
  8010d9:	c1 ea 16             	shr    $0x16,%edx
  8010dc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e3:	f6 c2 01             	test   $0x1,%dl
  8010e6:	74 2a                	je     801112 <fd_alloc+0x46>
  8010e8:	89 c2                	mov    %eax,%edx
  8010ea:	c1 ea 0c             	shr    $0xc,%edx
  8010ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f4:	f6 c2 01             	test   $0x1,%dl
  8010f7:	74 19                	je     801112 <fd_alloc+0x46>
  8010f9:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010fe:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801103:	75 d2                	jne    8010d7 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801105:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80110b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801110:	eb 07                	jmp    801119 <fd_alloc+0x4d>
			*fd_store = fd;
  801112:	89 01                	mov    %eax,(%ecx)
			return 0;
  801114:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801121:	83 f8 1f             	cmp    $0x1f,%eax
  801124:	77 36                	ja     80115c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801126:	c1 e0 0c             	shl    $0xc,%eax
  801129:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80112e:	89 c2                	mov    %eax,%edx
  801130:	c1 ea 16             	shr    $0x16,%edx
  801133:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80113a:	f6 c2 01             	test   $0x1,%dl
  80113d:	74 24                	je     801163 <fd_lookup+0x48>
  80113f:	89 c2                	mov    %eax,%edx
  801141:	c1 ea 0c             	shr    $0xc,%edx
  801144:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114b:	f6 c2 01             	test   $0x1,%dl
  80114e:	74 1a                	je     80116a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801150:	8b 55 0c             	mov    0xc(%ebp),%edx
  801153:	89 02                	mov    %eax,(%edx)
	return 0;
  801155:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    
		return -E_INVAL;
  80115c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801161:	eb f7                	jmp    80115a <fd_lookup+0x3f>
		return -E_INVAL;
  801163:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801168:	eb f0                	jmp    80115a <fd_lookup+0x3f>
  80116a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116f:	eb e9                	jmp    80115a <fd_lookup+0x3f>

00801171 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	83 ec 08             	sub    $0x8,%esp
  801177:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117a:	ba 7c 26 80 00       	mov    $0x80267c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80117f:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801184:	39 08                	cmp    %ecx,(%eax)
  801186:	74 33                	je     8011bb <dev_lookup+0x4a>
  801188:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80118b:	8b 02                	mov    (%edx),%eax
  80118d:	85 c0                	test   %eax,%eax
  80118f:	75 f3                	jne    801184 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801191:	a1 04 40 80 00       	mov    0x804004,%eax
  801196:	8b 40 48             	mov    0x48(%eax),%eax
  801199:	83 ec 04             	sub    $0x4,%esp
  80119c:	51                   	push   %ecx
  80119d:	50                   	push   %eax
  80119e:	68 00 26 80 00       	push   $0x802600
  8011a3:	e8 02 f0 ff ff       	call   8001aa <cprintf>
	*dev = 0;
  8011a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011b1:	83 c4 10             	add    $0x10,%esp
  8011b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011b9:	c9                   	leave  
  8011ba:	c3                   	ret    
			*dev = devtab[i];
  8011bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011be:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c5:	eb f2                	jmp    8011b9 <dev_lookup+0x48>

008011c7 <fd_close>:
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 1c             	sub    $0x1c,%esp
  8011d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011d9:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011da:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011e0:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e3:	50                   	push   %eax
  8011e4:	e8 32 ff ff ff       	call   80111b <fd_lookup>
  8011e9:	89 c3                	mov    %eax,%ebx
  8011eb:	83 c4 08             	add    $0x8,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	78 05                	js     8011f7 <fd_close+0x30>
	    || fd != fd2)
  8011f2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011f5:	74 16                	je     80120d <fd_close+0x46>
		return (must_exist ? r : 0);
  8011f7:	89 f8                	mov    %edi,%eax
  8011f9:	84 c0                	test   %al,%al
  8011fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801200:	0f 44 d8             	cmove  %eax,%ebx
}
  801203:	89 d8                	mov    %ebx,%eax
  801205:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801213:	50                   	push   %eax
  801214:	ff 36                	pushl  (%esi)
  801216:	e8 56 ff ff ff       	call   801171 <dev_lookup>
  80121b:	89 c3                	mov    %eax,%ebx
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	78 15                	js     801239 <fd_close+0x72>
		if (dev->dev_close)
  801224:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801227:	8b 40 10             	mov    0x10(%eax),%eax
  80122a:	85 c0                	test   %eax,%eax
  80122c:	74 1b                	je     801249 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80122e:	83 ec 0c             	sub    $0xc,%esp
  801231:	56                   	push   %esi
  801232:	ff d0                	call   *%eax
  801234:	89 c3                	mov    %eax,%ebx
  801236:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	56                   	push   %esi
  80123d:	6a 00                	push   $0x0
  80123f:	e8 03 fa ff ff       	call   800c47 <sys_page_unmap>
	return r;
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	eb ba                	jmp    801203 <fd_close+0x3c>
			r = 0;
  801249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124e:	eb e9                	jmp    801239 <fd_close+0x72>

00801250 <close>:

int
close(int fdnum)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801256:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801259:	50                   	push   %eax
  80125a:	ff 75 08             	pushl  0x8(%ebp)
  80125d:	e8 b9 fe ff ff       	call   80111b <fd_lookup>
  801262:	83 c4 08             	add    $0x8,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	78 10                	js     801279 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801269:	83 ec 08             	sub    $0x8,%esp
  80126c:	6a 01                	push   $0x1
  80126e:	ff 75 f4             	pushl  -0xc(%ebp)
  801271:	e8 51 ff ff ff       	call   8011c7 <fd_close>
  801276:	83 c4 10             	add    $0x10,%esp
}
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <close_all>:

void
close_all(void)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	53                   	push   %ebx
  80127f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801282:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801287:	83 ec 0c             	sub    $0xc,%esp
  80128a:	53                   	push   %ebx
  80128b:	e8 c0 ff ff ff       	call   801250 <close>
	for (i = 0; i < MAXFD; i++)
  801290:	83 c3 01             	add    $0x1,%ebx
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	83 fb 20             	cmp    $0x20,%ebx
  801299:	75 ec                	jne    801287 <close_all+0xc>
}
  80129b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129e:	c9                   	leave  
  80129f:	c3                   	ret    

008012a0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	57                   	push   %edi
  8012a4:	56                   	push   %esi
  8012a5:	53                   	push   %ebx
  8012a6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012ac:	50                   	push   %eax
  8012ad:	ff 75 08             	pushl  0x8(%ebp)
  8012b0:	e8 66 fe ff ff       	call   80111b <fd_lookup>
  8012b5:	89 c3                	mov    %eax,%ebx
  8012b7:	83 c4 08             	add    $0x8,%esp
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	0f 88 81 00 00 00    	js     801343 <dup+0xa3>
		return r;
	close(newfdnum);
  8012c2:	83 ec 0c             	sub    $0xc,%esp
  8012c5:	ff 75 0c             	pushl  0xc(%ebp)
  8012c8:	e8 83 ff ff ff       	call   801250 <close>

	newfd = INDEX2FD(newfdnum);
  8012cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012d0:	c1 e6 0c             	shl    $0xc,%esi
  8012d3:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012d9:	83 c4 04             	add    $0x4,%esp
  8012dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012df:	e8 d1 fd ff ff       	call   8010b5 <fd2data>
  8012e4:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012e6:	89 34 24             	mov    %esi,(%esp)
  8012e9:	e8 c7 fd ff ff       	call   8010b5 <fd2data>
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012f3:	89 d8                	mov    %ebx,%eax
  8012f5:	c1 e8 16             	shr    $0x16,%eax
  8012f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ff:	a8 01                	test   $0x1,%al
  801301:	74 11                	je     801314 <dup+0x74>
  801303:	89 d8                	mov    %ebx,%eax
  801305:	c1 e8 0c             	shr    $0xc,%eax
  801308:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80130f:	f6 c2 01             	test   $0x1,%dl
  801312:	75 39                	jne    80134d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801314:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801317:	89 d0                	mov    %edx,%eax
  801319:	c1 e8 0c             	shr    $0xc,%eax
  80131c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801323:	83 ec 0c             	sub    $0xc,%esp
  801326:	25 07 0e 00 00       	and    $0xe07,%eax
  80132b:	50                   	push   %eax
  80132c:	56                   	push   %esi
  80132d:	6a 00                	push   $0x0
  80132f:	52                   	push   %edx
  801330:	6a 00                	push   $0x0
  801332:	e8 ce f8 ff ff       	call   800c05 <sys_page_map>
  801337:	89 c3                	mov    %eax,%ebx
  801339:	83 c4 20             	add    $0x20,%esp
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 31                	js     801371 <dup+0xd1>
		goto err;

	return newfdnum;
  801340:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801343:	89 d8                	mov    %ebx,%eax
  801345:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801348:	5b                   	pop    %ebx
  801349:	5e                   	pop    %esi
  80134a:	5f                   	pop    %edi
  80134b:	5d                   	pop    %ebp
  80134c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80134d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801354:	83 ec 0c             	sub    $0xc,%esp
  801357:	25 07 0e 00 00       	and    $0xe07,%eax
  80135c:	50                   	push   %eax
  80135d:	57                   	push   %edi
  80135e:	6a 00                	push   $0x0
  801360:	53                   	push   %ebx
  801361:	6a 00                	push   $0x0
  801363:	e8 9d f8 ff ff       	call   800c05 <sys_page_map>
  801368:	89 c3                	mov    %eax,%ebx
  80136a:	83 c4 20             	add    $0x20,%esp
  80136d:	85 c0                	test   %eax,%eax
  80136f:	79 a3                	jns    801314 <dup+0x74>
	sys_page_unmap(0, newfd);
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	56                   	push   %esi
  801375:	6a 00                	push   $0x0
  801377:	e8 cb f8 ff ff       	call   800c47 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80137c:	83 c4 08             	add    $0x8,%esp
  80137f:	57                   	push   %edi
  801380:	6a 00                	push   $0x0
  801382:	e8 c0 f8 ff ff       	call   800c47 <sys_page_unmap>
	return r;
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	eb b7                	jmp    801343 <dup+0xa3>

0080138c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	53                   	push   %ebx
  801390:	83 ec 14             	sub    $0x14,%esp
  801393:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801396:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	53                   	push   %ebx
  80139b:	e8 7b fd ff ff       	call   80111b <fd_lookup>
  8013a0:	83 c4 08             	add    $0x8,%esp
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 3f                	js     8013e6 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b1:	ff 30                	pushl  (%eax)
  8013b3:	e8 b9 fd ff ff       	call   801171 <dev_lookup>
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 27                	js     8013e6 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013c2:	8b 42 08             	mov    0x8(%edx),%eax
  8013c5:	83 e0 03             	and    $0x3,%eax
  8013c8:	83 f8 01             	cmp    $0x1,%eax
  8013cb:	74 1e                	je     8013eb <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d0:	8b 40 08             	mov    0x8(%eax),%eax
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	74 35                	je     80140c <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013d7:	83 ec 04             	sub    $0x4,%esp
  8013da:	ff 75 10             	pushl  0x10(%ebp)
  8013dd:	ff 75 0c             	pushl  0xc(%ebp)
  8013e0:	52                   	push   %edx
  8013e1:	ff d0                	call   *%eax
  8013e3:	83 c4 10             	add    $0x10,%esp
}
  8013e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f0:	8b 40 48             	mov    0x48(%eax),%eax
  8013f3:	83 ec 04             	sub    $0x4,%esp
  8013f6:	53                   	push   %ebx
  8013f7:	50                   	push   %eax
  8013f8:	68 41 26 80 00       	push   $0x802641
  8013fd:	e8 a8 ed ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140a:	eb da                	jmp    8013e6 <read+0x5a>
		return -E_NOT_SUPP;
  80140c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801411:	eb d3                	jmp    8013e6 <read+0x5a>

00801413 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	57                   	push   %edi
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 0c             	sub    $0xc,%esp
  80141c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80141f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801422:	bb 00 00 00 00       	mov    $0x0,%ebx
  801427:	39 f3                	cmp    %esi,%ebx
  801429:	73 25                	jae    801450 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80142b:	83 ec 04             	sub    $0x4,%esp
  80142e:	89 f0                	mov    %esi,%eax
  801430:	29 d8                	sub    %ebx,%eax
  801432:	50                   	push   %eax
  801433:	89 d8                	mov    %ebx,%eax
  801435:	03 45 0c             	add    0xc(%ebp),%eax
  801438:	50                   	push   %eax
  801439:	57                   	push   %edi
  80143a:	e8 4d ff ff ff       	call   80138c <read>
		if (m < 0)
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	85 c0                	test   %eax,%eax
  801444:	78 08                	js     80144e <readn+0x3b>
			return m;
		if (m == 0)
  801446:	85 c0                	test   %eax,%eax
  801448:	74 06                	je     801450 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80144a:	01 c3                	add    %eax,%ebx
  80144c:	eb d9                	jmp    801427 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80144e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801450:	89 d8                	mov    %ebx,%eax
  801452:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5f                   	pop    %edi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 14             	sub    $0x14,%esp
  801461:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801464:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	53                   	push   %ebx
  801469:	e8 ad fc ff ff       	call   80111b <fd_lookup>
  80146e:	83 c4 08             	add    $0x8,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	78 3a                	js     8014af <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147f:	ff 30                	pushl  (%eax)
  801481:	e8 eb fc ff ff       	call   801171 <dev_lookup>
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 22                	js     8014af <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80148d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801490:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801494:	74 1e                	je     8014b4 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801496:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801499:	8b 52 0c             	mov    0xc(%edx),%edx
  80149c:	85 d2                	test   %edx,%edx
  80149e:	74 35                	je     8014d5 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014a0:	83 ec 04             	sub    $0x4,%esp
  8014a3:	ff 75 10             	pushl  0x10(%ebp)
  8014a6:	ff 75 0c             	pushl  0xc(%ebp)
  8014a9:	50                   	push   %eax
  8014aa:	ff d2                	call   *%edx
  8014ac:	83 c4 10             	add    $0x10,%esp
}
  8014af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b2:	c9                   	leave  
  8014b3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b4:	a1 04 40 80 00       	mov    0x804004,%eax
  8014b9:	8b 40 48             	mov    0x48(%eax),%eax
  8014bc:	83 ec 04             	sub    $0x4,%esp
  8014bf:	53                   	push   %ebx
  8014c0:	50                   	push   %eax
  8014c1:	68 5d 26 80 00       	push   $0x80265d
  8014c6:	e8 df ec ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d3:	eb da                	jmp    8014af <write+0x55>
		return -E_NOT_SUPP;
  8014d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014da:	eb d3                	jmp    8014af <write+0x55>

008014dc <seek>:

int
seek(int fdnum, off_t offset)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014e5:	50                   	push   %eax
  8014e6:	ff 75 08             	pushl  0x8(%ebp)
  8014e9:	e8 2d fc ff ff       	call   80111b <fd_lookup>
  8014ee:	83 c4 08             	add    $0x8,%esp
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	78 0e                	js     801503 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014fb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 14             	sub    $0x14,%esp
  80150c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	53                   	push   %ebx
  801514:	e8 02 fc ff ff       	call   80111b <fd_lookup>
  801519:	83 c4 08             	add    $0x8,%esp
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 37                	js     801557 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152a:	ff 30                	pushl  (%eax)
  80152c:	e8 40 fc ff ff       	call   801171 <dev_lookup>
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 1f                	js     801557 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801538:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153f:	74 1b                	je     80155c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801541:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801544:	8b 52 18             	mov    0x18(%edx),%edx
  801547:	85 d2                	test   %edx,%edx
  801549:	74 32                	je     80157d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	ff 75 0c             	pushl  0xc(%ebp)
  801551:	50                   	push   %eax
  801552:	ff d2                	call   *%edx
  801554:	83 c4 10             	add    $0x10,%esp
}
  801557:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80155c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801561:	8b 40 48             	mov    0x48(%eax),%eax
  801564:	83 ec 04             	sub    $0x4,%esp
  801567:	53                   	push   %ebx
  801568:	50                   	push   %eax
  801569:	68 20 26 80 00       	push   $0x802620
  80156e:	e8 37 ec ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80157b:	eb da                	jmp    801557 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80157d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801582:	eb d3                	jmp    801557 <ftruncate+0x52>

00801584 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	53                   	push   %ebx
  801588:	83 ec 14             	sub    $0x14,%esp
  80158b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	ff 75 08             	pushl  0x8(%ebp)
  801595:	e8 81 fb ff ff       	call   80111b <fd_lookup>
  80159a:	83 c4 08             	add    $0x8,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 4b                	js     8015ec <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ab:	ff 30                	pushl  (%eax)
  8015ad:	e8 bf fb ff ff       	call   801171 <dev_lookup>
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	78 33                	js     8015ec <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8015b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015c0:	74 2f                	je     8015f1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015c2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015c5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015cc:	00 00 00 
	stat->st_isdir = 0;
  8015cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015d6:	00 00 00 
	stat->st_dev = dev;
  8015d9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	53                   	push   %ebx
  8015e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8015e6:	ff 50 14             	call   *0x14(%eax)
  8015e9:	83 c4 10             	add    $0x10,%esp
}
  8015ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ef:	c9                   	leave  
  8015f0:	c3                   	ret    
		return -E_NOT_SUPP;
  8015f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015f6:	eb f4                	jmp    8015ec <fstat+0x68>

008015f8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	56                   	push   %esi
  8015fc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	6a 00                	push   $0x0
  801602:	ff 75 08             	pushl  0x8(%ebp)
  801605:	e8 da 01 00 00       	call   8017e4 <open>
  80160a:	89 c3                	mov    %eax,%ebx
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 1b                	js     80162e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801613:	83 ec 08             	sub    $0x8,%esp
  801616:	ff 75 0c             	pushl  0xc(%ebp)
  801619:	50                   	push   %eax
  80161a:	e8 65 ff ff ff       	call   801584 <fstat>
  80161f:	89 c6                	mov    %eax,%esi
	close(fd);
  801621:	89 1c 24             	mov    %ebx,(%esp)
  801624:	e8 27 fc ff ff       	call   801250 <close>
	return r;
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	89 f3                	mov    %esi,%ebx
}
  80162e:	89 d8                	mov    %ebx,%eax
  801630:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801633:	5b                   	pop    %ebx
  801634:	5e                   	pop    %esi
  801635:	5d                   	pop    %ebp
  801636:	c3                   	ret    

00801637 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	56                   	push   %esi
  80163b:	53                   	push   %ebx
  80163c:	89 c6                	mov    %eax,%esi
  80163e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801640:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801647:	74 27                	je     801670 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801649:	6a 07                	push   $0x7
  80164b:	68 00 50 80 00       	push   $0x805000
  801650:	56                   	push   %esi
  801651:	ff 35 00 40 80 00    	pushl  0x804000
  801657:	e8 39 08 00 00       	call   801e95 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80165c:	83 c4 0c             	add    $0xc,%esp
  80165f:	6a 00                	push   $0x0
  801661:	53                   	push   %ebx
  801662:	6a 00                	push   $0x0
  801664:	e8 c5 07 00 00       	call   801e2e <ipc_recv>
}
  801669:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5e                   	pop    %esi
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801670:	83 ec 0c             	sub    $0xc,%esp
  801673:	6a 01                	push   $0x1
  801675:	e8 6f 08 00 00       	call   801ee9 <ipc_find_env>
  80167a:	a3 00 40 80 00       	mov    %eax,0x804000
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	eb c5                	jmp    801649 <fsipc+0x12>

00801684 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80168a:	8b 45 08             	mov    0x8(%ebp),%eax
  80168d:	8b 40 0c             	mov    0xc(%eax),%eax
  801690:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801695:	8b 45 0c             	mov    0xc(%ebp),%eax
  801698:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80169d:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8016a7:	e8 8b ff ff ff       	call   801637 <fsipc>
}
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <devfile_flush>:
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8016c9:	e8 69 ff ff ff       	call   801637 <fsipc>
}
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <devfile_stat>:
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 04             	sub    $0x4,%esp
  8016d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016da:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8016ef:	e8 43 ff ff ff       	call   801637 <fsipc>
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 2c                	js     801724 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016f8:	83 ec 08             	sub    $0x8,%esp
  8016fb:	68 00 50 80 00       	push   $0x805000
  801700:	53                   	push   %ebx
  801701:	e8 c3 f0 ff ff       	call   8007c9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801706:	a1 80 50 80 00       	mov    0x805080,%eax
  80170b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801711:	a1 84 50 80 00       	mov    0x805084,%eax
  801716:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801727:	c9                   	leave  
  801728:	c3                   	ret    

00801729 <devfile_write>:
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	83 ec 0c             	sub    $0xc,%esp
  80172f:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801732:	8b 55 08             	mov    0x8(%ebp),%edx
  801735:	8b 52 0c             	mov    0xc(%edx),%edx
  801738:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  80173e:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  801743:	50                   	push   %eax
  801744:	ff 75 0c             	pushl  0xc(%ebp)
  801747:	68 08 50 80 00       	push   $0x805008
  80174c:	e8 06 f2 ff ff       	call   800957 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  801751:	ba 00 00 00 00       	mov    $0x0,%edx
  801756:	b8 04 00 00 00       	mov    $0x4,%eax
  80175b:	e8 d7 fe ff ff       	call   801637 <fsipc>
}
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <devfile_read>:
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
  801767:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80176a:	8b 45 08             	mov    0x8(%ebp),%eax
  80176d:	8b 40 0c             	mov    0xc(%eax),%eax
  801770:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801775:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80177b:	ba 00 00 00 00       	mov    $0x0,%edx
  801780:	b8 03 00 00 00       	mov    $0x3,%eax
  801785:	e8 ad fe ff ff       	call   801637 <fsipc>
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 1f                	js     8017af <devfile_read+0x4d>
	assert(r <= n);
  801790:	39 f0                	cmp    %esi,%eax
  801792:	77 24                	ja     8017b8 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801794:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801799:	7f 33                	jg     8017ce <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80179b:	83 ec 04             	sub    $0x4,%esp
  80179e:	50                   	push   %eax
  80179f:	68 00 50 80 00       	push   $0x805000
  8017a4:	ff 75 0c             	pushl  0xc(%ebp)
  8017a7:	e8 ab f1 ff ff       	call   800957 <memmove>
	return r;
  8017ac:	83 c4 10             	add    $0x10,%esp
}
  8017af:	89 d8                	mov    %ebx,%eax
  8017b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b4:	5b                   	pop    %ebx
  8017b5:	5e                   	pop    %esi
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    
	assert(r <= n);
  8017b8:	68 8c 26 80 00       	push   $0x80268c
  8017bd:	68 93 26 80 00       	push   $0x802693
  8017c2:	6a 7c                	push   $0x7c
  8017c4:	68 a8 26 80 00       	push   $0x8026a8
  8017c9:	e8 85 05 00 00       	call   801d53 <_panic>
	assert(r <= PGSIZE);
  8017ce:	68 b3 26 80 00       	push   $0x8026b3
  8017d3:	68 93 26 80 00       	push   $0x802693
  8017d8:	6a 7d                	push   $0x7d
  8017da:	68 a8 26 80 00       	push   $0x8026a8
  8017df:	e8 6f 05 00 00       	call   801d53 <_panic>

008017e4 <open>:
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	56                   	push   %esi
  8017e8:	53                   	push   %ebx
  8017e9:	83 ec 1c             	sub    $0x1c,%esp
  8017ec:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8017ef:	56                   	push   %esi
  8017f0:	e8 9d ef ff ff       	call   800792 <strlen>
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017fd:	7f 6c                	jg     80186b <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8017ff:	83 ec 0c             	sub    $0xc,%esp
  801802:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801805:	50                   	push   %eax
  801806:	e8 c1 f8 ff ff       	call   8010cc <fd_alloc>
  80180b:	89 c3                	mov    %eax,%ebx
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	78 3c                	js     801850 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801814:	83 ec 08             	sub    $0x8,%esp
  801817:	56                   	push   %esi
  801818:	68 00 50 80 00       	push   $0x805000
  80181d:	e8 a7 ef ff ff       	call   8007c9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801822:	8b 45 0c             	mov    0xc(%ebp),%eax
  801825:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80182a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182d:	b8 01 00 00 00       	mov    $0x1,%eax
  801832:	e8 00 fe ff ff       	call   801637 <fsipc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 19                	js     801859 <open+0x75>
	return fd2num(fd);
  801840:	83 ec 0c             	sub    $0xc,%esp
  801843:	ff 75 f4             	pushl  -0xc(%ebp)
  801846:	e8 5a f8 ff ff       	call   8010a5 <fd2num>
  80184b:	89 c3                	mov    %eax,%ebx
  80184d:	83 c4 10             	add    $0x10,%esp
}
  801850:	89 d8                	mov    %ebx,%eax
  801852:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801855:	5b                   	pop    %ebx
  801856:	5e                   	pop    %esi
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    
		fd_close(fd, 0);
  801859:	83 ec 08             	sub    $0x8,%esp
  80185c:	6a 00                	push   $0x0
  80185e:	ff 75 f4             	pushl  -0xc(%ebp)
  801861:	e8 61 f9 ff ff       	call   8011c7 <fd_close>
		return r;
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	eb e5                	jmp    801850 <open+0x6c>
		return -E_BAD_PATH;
  80186b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801870:	eb de                	jmp    801850 <open+0x6c>

00801872 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801878:	ba 00 00 00 00       	mov    $0x0,%edx
  80187d:	b8 08 00 00 00       	mov    $0x8,%eax
  801882:	e8 b0 fd ff ff       	call   801637 <fsipc>
}
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	56                   	push   %esi
  80188d:	53                   	push   %ebx
  80188e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801891:	83 ec 0c             	sub    $0xc,%esp
  801894:	ff 75 08             	pushl  0x8(%ebp)
  801897:	e8 19 f8 ff ff       	call   8010b5 <fd2data>
  80189c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80189e:	83 c4 08             	add    $0x8,%esp
  8018a1:	68 bf 26 80 00       	push   $0x8026bf
  8018a6:	53                   	push   %ebx
  8018a7:	e8 1d ef ff ff       	call   8007c9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018ac:	8b 46 04             	mov    0x4(%esi),%eax
  8018af:	2b 06                	sub    (%esi),%eax
  8018b1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018be:	00 00 00 
	stat->st_dev = &devpipe;
  8018c1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018c8:	30 80 00 
	return 0;
}
  8018cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d3:	5b                   	pop    %ebx
  8018d4:	5e                   	pop    %esi
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    

008018d7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	53                   	push   %ebx
  8018db:	83 ec 0c             	sub    $0xc,%esp
  8018de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018e1:	53                   	push   %ebx
  8018e2:	6a 00                	push   $0x0
  8018e4:	e8 5e f3 ff ff       	call   800c47 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018e9:	89 1c 24             	mov    %ebx,(%esp)
  8018ec:	e8 c4 f7 ff ff       	call   8010b5 <fd2data>
  8018f1:	83 c4 08             	add    $0x8,%esp
  8018f4:	50                   	push   %eax
  8018f5:	6a 00                	push   $0x0
  8018f7:	e8 4b f3 ff ff       	call   800c47 <sys_page_unmap>
}
  8018fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ff:	c9                   	leave  
  801900:	c3                   	ret    

00801901 <_pipeisclosed>:
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	57                   	push   %edi
  801905:	56                   	push   %esi
  801906:	53                   	push   %ebx
  801907:	83 ec 1c             	sub    $0x1c,%esp
  80190a:	89 c7                	mov    %eax,%edi
  80190c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80190e:	a1 04 40 80 00       	mov    0x804004,%eax
  801913:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801916:	83 ec 0c             	sub    $0xc,%esp
  801919:	57                   	push   %edi
  80191a:	e8 03 06 00 00       	call   801f22 <pageref>
  80191f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801922:	89 34 24             	mov    %esi,(%esp)
  801925:	e8 f8 05 00 00       	call   801f22 <pageref>
		nn = thisenv->env_runs;
  80192a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801930:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	39 cb                	cmp    %ecx,%ebx
  801938:	74 1b                	je     801955 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80193a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80193d:	75 cf                	jne    80190e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80193f:	8b 42 58             	mov    0x58(%edx),%eax
  801942:	6a 01                	push   $0x1
  801944:	50                   	push   %eax
  801945:	53                   	push   %ebx
  801946:	68 c6 26 80 00       	push   $0x8026c6
  80194b:	e8 5a e8 ff ff       	call   8001aa <cprintf>
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	eb b9                	jmp    80190e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801955:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801958:	0f 94 c0             	sete   %al
  80195b:	0f b6 c0             	movzbl %al,%eax
}
  80195e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801961:	5b                   	pop    %ebx
  801962:	5e                   	pop    %esi
  801963:	5f                   	pop    %edi
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <devpipe_write>:
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	57                   	push   %edi
  80196a:	56                   	push   %esi
  80196b:	53                   	push   %ebx
  80196c:	83 ec 28             	sub    $0x28,%esp
  80196f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801972:	56                   	push   %esi
  801973:	e8 3d f7 ff ff       	call   8010b5 <fd2data>
  801978:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	bf 00 00 00 00       	mov    $0x0,%edi
  801982:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801985:	74 4f                	je     8019d6 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801987:	8b 43 04             	mov    0x4(%ebx),%eax
  80198a:	8b 0b                	mov    (%ebx),%ecx
  80198c:	8d 51 20             	lea    0x20(%ecx),%edx
  80198f:	39 d0                	cmp    %edx,%eax
  801991:	72 14                	jb     8019a7 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801993:	89 da                	mov    %ebx,%edx
  801995:	89 f0                	mov    %esi,%eax
  801997:	e8 65 ff ff ff       	call   801901 <_pipeisclosed>
  80199c:	85 c0                	test   %eax,%eax
  80199e:	75 3a                	jne    8019da <devpipe_write+0x74>
			sys_yield();
  8019a0:	e8 fe f1 ff ff       	call   800ba3 <sys_yield>
  8019a5:	eb e0                	jmp    801987 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019aa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019ae:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019b1:	89 c2                	mov    %eax,%edx
  8019b3:	c1 fa 1f             	sar    $0x1f,%edx
  8019b6:	89 d1                	mov    %edx,%ecx
  8019b8:	c1 e9 1b             	shr    $0x1b,%ecx
  8019bb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019be:	83 e2 1f             	and    $0x1f,%edx
  8019c1:	29 ca                	sub    %ecx,%edx
  8019c3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019c7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019cb:	83 c0 01             	add    $0x1,%eax
  8019ce:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8019d1:	83 c7 01             	add    $0x1,%edi
  8019d4:	eb ac                	jmp    801982 <devpipe_write+0x1c>
	return i;
  8019d6:	89 f8                	mov    %edi,%eax
  8019d8:	eb 05                	jmp    8019df <devpipe_write+0x79>
				return 0;
  8019da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e2:	5b                   	pop    %ebx
  8019e3:	5e                   	pop    %esi
  8019e4:	5f                   	pop    %edi
  8019e5:	5d                   	pop    %ebp
  8019e6:	c3                   	ret    

008019e7 <devpipe_read>:
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	57                   	push   %edi
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 18             	sub    $0x18,%esp
  8019f0:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8019f3:	57                   	push   %edi
  8019f4:	e8 bc f6 ff ff       	call   8010b5 <fd2data>
  8019f9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	be 00 00 00 00       	mov    $0x0,%esi
  801a03:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a06:	74 47                	je     801a4f <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801a08:	8b 03                	mov    (%ebx),%eax
  801a0a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a0d:	75 22                	jne    801a31 <devpipe_read+0x4a>
			if (i > 0)
  801a0f:	85 f6                	test   %esi,%esi
  801a11:	75 14                	jne    801a27 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801a13:	89 da                	mov    %ebx,%edx
  801a15:	89 f8                	mov    %edi,%eax
  801a17:	e8 e5 fe ff ff       	call   801901 <_pipeisclosed>
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	75 33                	jne    801a53 <devpipe_read+0x6c>
			sys_yield();
  801a20:	e8 7e f1 ff ff       	call   800ba3 <sys_yield>
  801a25:	eb e1                	jmp    801a08 <devpipe_read+0x21>
				return i;
  801a27:	89 f0                	mov    %esi,%eax
}
  801a29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5e                   	pop    %esi
  801a2e:	5f                   	pop    %edi
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a31:	99                   	cltd   
  801a32:	c1 ea 1b             	shr    $0x1b,%edx
  801a35:	01 d0                	add    %edx,%eax
  801a37:	83 e0 1f             	and    $0x1f,%eax
  801a3a:	29 d0                	sub    %edx,%eax
  801a3c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a44:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a47:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a4a:	83 c6 01             	add    $0x1,%esi
  801a4d:	eb b4                	jmp    801a03 <devpipe_read+0x1c>
	return i;
  801a4f:	89 f0                	mov    %esi,%eax
  801a51:	eb d6                	jmp    801a29 <devpipe_read+0x42>
				return 0;
  801a53:	b8 00 00 00 00       	mov    $0x0,%eax
  801a58:	eb cf                	jmp    801a29 <devpipe_read+0x42>

00801a5a <pipe>:
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	56                   	push   %esi
  801a5e:	53                   	push   %ebx
  801a5f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801a62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a65:	50                   	push   %eax
  801a66:	e8 61 f6 ff ff       	call   8010cc <fd_alloc>
  801a6b:	89 c3                	mov    %eax,%ebx
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	85 c0                	test   %eax,%eax
  801a72:	78 5b                	js     801acf <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a74:	83 ec 04             	sub    $0x4,%esp
  801a77:	68 07 04 00 00       	push   $0x407
  801a7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7f:	6a 00                	push   $0x0
  801a81:	e8 3c f1 ff ff       	call   800bc2 <sys_page_alloc>
  801a86:	89 c3                	mov    %eax,%ebx
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	78 40                	js     801acf <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a95:	50                   	push   %eax
  801a96:	e8 31 f6 ff ff       	call   8010cc <fd_alloc>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 1b                	js     801abf <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa4:	83 ec 04             	sub    $0x4,%esp
  801aa7:	68 07 04 00 00       	push   $0x407
  801aac:	ff 75 f0             	pushl  -0x10(%ebp)
  801aaf:	6a 00                	push   $0x0
  801ab1:	e8 0c f1 ff ff       	call   800bc2 <sys_page_alloc>
  801ab6:	89 c3                	mov    %eax,%ebx
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	85 c0                	test   %eax,%eax
  801abd:	79 19                	jns    801ad8 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801abf:	83 ec 08             	sub    $0x8,%esp
  801ac2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac5:	6a 00                	push   $0x0
  801ac7:	e8 7b f1 ff ff       	call   800c47 <sys_page_unmap>
  801acc:	83 c4 10             	add    $0x10,%esp
}
  801acf:	89 d8                	mov    %ebx,%eax
  801ad1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad4:	5b                   	pop    %ebx
  801ad5:	5e                   	pop    %esi
  801ad6:	5d                   	pop    %ebp
  801ad7:	c3                   	ret    
	va = fd2data(fd0);
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ade:	e8 d2 f5 ff ff       	call   8010b5 <fd2data>
  801ae3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae5:	83 c4 0c             	add    $0xc,%esp
  801ae8:	68 07 04 00 00       	push   $0x407
  801aed:	50                   	push   %eax
  801aee:	6a 00                	push   $0x0
  801af0:	e8 cd f0 ff ff       	call   800bc2 <sys_page_alloc>
  801af5:	89 c3                	mov    %eax,%ebx
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	85 c0                	test   %eax,%eax
  801afc:	0f 88 8c 00 00 00    	js     801b8e <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b02:	83 ec 0c             	sub    $0xc,%esp
  801b05:	ff 75 f0             	pushl  -0x10(%ebp)
  801b08:	e8 a8 f5 ff ff       	call   8010b5 <fd2data>
  801b0d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b14:	50                   	push   %eax
  801b15:	6a 00                	push   $0x0
  801b17:	56                   	push   %esi
  801b18:	6a 00                	push   $0x0
  801b1a:	e8 e6 f0 ff ff       	call   800c05 <sys_page_map>
  801b1f:	89 c3                	mov    %eax,%ebx
  801b21:	83 c4 20             	add    $0x20,%esp
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 58                	js     801b80 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b31:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b36:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b40:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b46:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b52:	83 ec 0c             	sub    $0xc,%esp
  801b55:	ff 75 f4             	pushl  -0xc(%ebp)
  801b58:	e8 48 f5 ff ff       	call   8010a5 <fd2num>
  801b5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b60:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b62:	83 c4 04             	add    $0x4,%esp
  801b65:	ff 75 f0             	pushl  -0x10(%ebp)
  801b68:	e8 38 f5 ff ff       	call   8010a5 <fd2num>
  801b6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b70:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b7b:	e9 4f ff ff ff       	jmp    801acf <pipe+0x75>
	sys_page_unmap(0, va);
  801b80:	83 ec 08             	sub    $0x8,%esp
  801b83:	56                   	push   %esi
  801b84:	6a 00                	push   $0x0
  801b86:	e8 bc f0 ff ff       	call   800c47 <sys_page_unmap>
  801b8b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801b8e:	83 ec 08             	sub    $0x8,%esp
  801b91:	ff 75 f0             	pushl  -0x10(%ebp)
  801b94:	6a 00                	push   $0x0
  801b96:	e8 ac f0 ff ff       	call   800c47 <sys_page_unmap>
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	e9 1c ff ff ff       	jmp    801abf <pipe+0x65>

00801ba3 <pipeisclosed>:
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ba9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bac:	50                   	push   %eax
  801bad:	ff 75 08             	pushl  0x8(%ebp)
  801bb0:	e8 66 f5 ff ff       	call   80111b <fd_lookup>
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	78 18                	js     801bd4 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801bbc:	83 ec 0c             	sub    $0xc,%esp
  801bbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc2:	e8 ee f4 ff ff       	call   8010b5 <fd2data>
	return _pipeisclosed(fd, p);
  801bc7:	89 c2                	mov    %eax,%edx
  801bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcc:	e8 30 fd ff ff       	call   801901 <_pipeisclosed>
  801bd1:	83 c4 10             	add    $0x10,%esp
}
  801bd4:	c9                   	leave  
  801bd5:	c3                   	ret    

00801bd6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    

00801be0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801be6:	68 de 26 80 00       	push   $0x8026de
  801beb:	ff 75 0c             	pushl  0xc(%ebp)
  801bee:	e8 d6 eb ff ff       	call   8007c9 <strcpy>
	return 0;
}
  801bf3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf8:	c9                   	leave  
  801bf9:	c3                   	ret    

00801bfa <devcons_write>:
{
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	57                   	push   %edi
  801bfe:	56                   	push   %esi
  801bff:	53                   	push   %ebx
  801c00:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c06:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c0b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801c11:	eb 2f                	jmp    801c42 <devcons_write+0x48>
		m = n - tot;
  801c13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c16:	29 f3                	sub    %esi,%ebx
  801c18:	83 fb 7f             	cmp    $0x7f,%ebx
  801c1b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801c20:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c23:	83 ec 04             	sub    $0x4,%esp
  801c26:	53                   	push   %ebx
  801c27:	89 f0                	mov    %esi,%eax
  801c29:	03 45 0c             	add    0xc(%ebp),%eax
  801c2c:	50                   	push   %eax
  801c2d:	57                   	push   %edi
  801c2e:	e8 24 ed ff ff       	call   800957 <memmove>
		sys_cputs(buf, m);
  801c33:	83 c4 08             	add    $0x8,%esp
  801c36:	53                   	push   %ebx
  801c37:	57                   	push   %edi
  801c38:	e8 c9 ee ff ff       	call   800b06 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801c3d:	01 de                	add    %ebx,%esi
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c45:	72 cc                	jb     801c13 <devcons_write+0x19>
}
  801c47:	89 f0                	mov    %esi,%eax
  801c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4c:	5b                   	pop    %ebx
  801c4d:	5e                   	pop    %esi
  801c4e:	5f                   	pop    %edi
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    

00801c51 <devcons_read>:
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	83 ec 08             	sub    $0x8,%esp
  801c57:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801c5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c60:	75 07                	jne    801c69 <devcons_read+0x18>
}
  801c62:	c9                   	leave  
  801c63:	c3                   	ret    
		sys_yield();
  801c64:	e8 3a ef ff ff       	call   800ba3 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801c69:	e8 b6 ee ff ff       	call   800b24 <sys_cgetc>
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	74 f2                	je     801c64 <devcons_read+0x13>
	if (c < 0)
  801c72:	85 c0                	test   %eax,%eax
  801c74:	78 ec                	js     801c62 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801c76:	83 f8 04             	cmp    $0x4,%eax
  801c79:	74 0c                	je     801c87 <devcons_read+0x36>
	*(char*)vbuf = c;
  801c7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c7e:	88 02                	mov    %al,(%edx)
	return 1;
  801c80:	b8 01 00 00 00       	mov    $0x1,%eax
  801c85:	eb db                	jmp    801c62 <devcons_read+0x11>
		return 0;
  801c87:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8c:	eb d4                	jmp    801c62 <devcons_read+0x11>

00801c8e <cputchar>:
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c94:	8b 45 08             	mov    0x8(%ebp),%eax
  801c97:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801c9a:	6a 01                	push   $0x1
  801c9c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c9f:	50                   	push   %eax
  801ca0:	e8 61 ee ff ff       	call   800b06 <sys_cputs>
}
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <getchar>:
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801cb0:	6a 01                	push   $0x1
  801cb2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cb5:	50                   	push   %eax
  801cb6:	6a 00                	push   $0x0
  801cb8:	e8 cf f6 ff ff       	call   80138c <read>
	if (r < 0)
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	78 08                	js     801ccc <getchar+0x22>
	if (r < 1)
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	7e 06                	jle    801cce <getchar+0x24>
	return c;
  801cc8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ccc:	c9                   	leave  
  801ccd:	c3                   	ret    
		return -E_EOF;
  801cce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801cd3:	eb f7                	jmp    801ccc <getchar+0x22>

00801cd5 <iscons>:
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cde:	50                   	push   %eax
  801cdf:	ff 75 08             	pushl  0x8(%ebp)
  801ce2:	e8 34 f4 ff ff       	call   80111b <fd_lookup>
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	85 c0                	test   %eax,%eax
  801cec:	78 11                	js     801cff <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf7:	39 10                	cmp    %edx,(%eax)
  801cf9:	0f 94 c0             	sete   %al
  801cfc:	0f b6 c0             	movzbl %al,%eax
}
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <opencons>:
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0a:	50                   	push   %eax
  801d0b:	e8 bc f3 ff ff       	call   8010cc <fd_alloc>
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	85 c0                	test   %eax,%eax
  801d15:	78 3a                	js     801d51 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d17:	83 ec 04             	sub    $0x4,%esp
  801d1a:	68 07 04 00 00       	push   $0x407
  801d1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d22:	6a 00                	push   $0x0
  801d24:	e8 99 ee ff ff       	call   800bc2 <sys_page_alloc>
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	78 21                	js     801d51 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d33:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d39:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d45:	83 ec 0c             	sub    $0xc,%esp
  801d48:	50                   	push   %eax
  801d49:	e8 57 f3 ff ff       	call   8010a5 <fd2num>
  801d4e:	83 c4 10             	add    $0x10,%esp
}
  801d51:	c9                   	leave  
  801d52:	c3                   	ret    

00801d53 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	56                   	push   %esi
  801d57:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d58:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d5b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d61:	e8 1e ee ff ff       	call   800b84 <sys_getenvid>
  801d66:	83 ec 0c             	sub    $0xc,%esp
  801d69:	ff 75 0c             	pushl  0xc(%ebp)
  801d6c:	ff 75 08             	pushl  0x8(%ebp)
  801d6f:	56                   	push   %esi
  801d70:	50                   	push   %eax
  801d71:	68 ec 26 80 00       	push   $0x8026ec
  801d76:	e8 2f e4 ff ff       	call   8001aa <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d7b:	83 c4 18             	add    $0x18,%esp
  801d7e:	53                   	push   %ebx
  801d7f:	ff 75 10             	pushl  0x10(%ebp)
  801d82:	e8 d2 e3 ff ff       	call   800159 <vcprintf>
	cprintf("\n");
  801d87:	c7 04 24 34 22 80 00 	movl   $0x802234,(%esp)
  801d8e:	e8 17 e4 ff ff       	call   8001aa <cprintf>
  801d93:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d96:	cc                   	int3   
  801d97:	eb fd                	jmp    801d96 <_panic+0x43>

00801d99 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d9f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801da6:	74 20                	je     801dc8 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801da8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dab:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801db0:	83 ec 08             	sub    $0x8,%esp
  801db3:	68 08 1e 80 00       	push   $0x801e08
  801db8:	6a 00                	push   $0x0
  801dba:	e8 4e ef ff ff       	call   800d0d <sys_env_set_pgfault_upcall>
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	78 2e                	js     801df4 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  801dc6:	c9                   	leave  
  801dc7:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801dc8:	83 ec 04             	sub    $0x4,%esp
  801dcb:	6a 07                	push   $0x7
  801dcd:	68 00 f0 bf ee       	push   $0xeebff000
  801dd2:	6a 00                	push   $0x0
  801dd4:	e8 e9 ed ff ff       	call   800bc2 <sys_page_alloc>
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	79 c8                	jns    801da8 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801de0:	83 ec 04             	sub    $0x4,%esp
  801de3:	68 10 27 80 00       	push   $0x802710
  801de8:	6a 21                	push   $0x21
  801dea:	68 74 27 80 00       	push   $0x802774
  801def:	e8 5f ff ff ff       	call   801d53 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801df4:	83 ec 04             	sub    $0x4,%esp
  801df7:	68 3c 27 80 00       	push   $0x80273c
  801dfc:	6a 27                	push   $0x27
  801dfe:	68 74 27 80 00       	push   $0x802774
  801e03:	e8 4b ff ff ff       	call   801d53 <_panic>

00801e08 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e08:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e09:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e0e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e10:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801e13:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801e17:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801e1a:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  801e1e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801e22:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801e24:	83 c4 08             	add    $0x8,%esp
	popal
  801e27:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801e28:	83 c4 04             	add    $0x4,%esp
	popfl
  801e2b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e2c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e2d:	c3                   	ret    

00801e2e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	56                   	push   %esi
  801e32:	53                   	push   %ebx
  801e33:	8b 75 08             	mov    0x8(%ebp),%esi
  801e36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801e3c:	85 f6                	test   %esi,%esi
  801e3e:	74 06                	je     801e46 <ipc_recv+0x18>
  801e40:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801e46:	85 db                	test   %ebx,%ebx
  801e48:	74 06                	je     801e50 <ipc_recv+0x22>
  801e4a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801e50:	85 c0                	test   %eax,%eax
  801e52:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801e57:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801e5a:	83 ec 0c             	sub    $0xc,%esp
  801e5d:	50                   	push   %eax
  801e5e:	e8 0f ef ff ff       	call   800d72 <sys_ipc_recv>
	if (ret) return ret;
  801e63:	83 c4 10             	add    $0x10,%esp
  801e66:	85 c0                	test   %eax,%eax
  801e68:	75 24                	jne    801e8e <ipc_recv+0x60>
	if (from_env_store)
  801e6a:	85 f6                	test   %esi,%esi
  801e6c:	74 0a                	je     801e78 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801e6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801e73:	8b 40 74             	mov    0x74(%eax),%eax
  801e76:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801e78:	85 db                	test   %ebx,%ebx
  801e7a:	74 0a                	je     801e86 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801e7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e81:	8b 40 78             	mov    0x78(%eax),%eax
  801e84:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801e86:	a1 04 40 80 00       	mov    0x804004,%eax
  801e8b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e91:	5b                   	pop    %ebx
  801e92:	5e                   	pop    %esi
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	57                   	push   %edi
  801e99:	56                   	push   %esi
  801e9a:	53                   	push   %ebx
  801e9b:	83 ec 0c             	sub    $0xc,%esp
  801e9e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ea1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ea4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801ea7:	85 db                	test   %ebx,%ebx
  801ea9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801eae:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801eb1:	ff 75 14             	pushl  0x14(%ebp)
  801eb4:	53                   	push   %ebx
  801eb5:	56                   	push   %esi
  801eb6:	57                   	push   %edi
  801eb7:	e8 93 ee ff ff       	call   800d4f <sys_ipc_try_send>
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	74 1e                	je     801ee1 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ec3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec6:	75 07                	jne    801ecf <ipc_send+0x3a>
		sys_yield();
  801ec8:	e8 d6 ec ff ff       	call   800ba3 <sys_yield>
  801ecd:	eb e2                	jmp    801eb1 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ecf:	50                   	push   %eax
  801ed0:	68 82 27 80 00       	push   $0x802782
  801ed5:	6a 36                	push   $0x36
  801ed7:	68 99 27 80 00       	push   $0x802799
  801edc:	e8 72 fe ff ff       	call   801d53 <_panic>
	}
}
  801ee1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee4:	5b                   	pop    %ebx
  801ee5:	5e                   	pop    %esi
  801ee6:	5f                   	pop    %edi
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    

00801ee9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eef:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ef4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ef7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801efd:	8b 52 50             	mov    0x50(%edx),%edx
  801f00:	39 ca                	cmp    %ecx,%edx
  801f02:	74 11                	je     801f15 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f04:	83 c0 01             	add    $0x1,%eax
  801f07:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f0c:	75 e6                	jne    801ef4 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f13:	eb 0b                	jmp    801f20 <ipc_find_env+0x37>
			return envs[i].env_id;
  801f15:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f18:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f1d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    

00801f22 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f28:	89 d0                	mov    %edx,%eax
  801f2a:	c1 e8 16             	shr    $0x16,%eax
  801f2d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f34:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f39:	f6 c1 01             	test   $0x1,%cl
  801f3c:	74 1d                	je     801f5b <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f3e:	c1 ea 0c             	shr    $0xc,%edx
  801f41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f48:	f6 c2 01             	test   $0x1,%dl
  801f4b:	74 0e                	je     801f5b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f4d:	c1 ea 0c             	shr    $0xc,%edx
  801f50:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f57:	ef 
  801f58:	0f b7 c0             	movzwl %ax,%eax
}
  801f5b:	5d                   	pop    %ebp
  801f5c:	c3                   	ret    
  801f5d:	66 90                	xchg   %ax,%ax
  801f5f:	90                   	nop

00801f60 <__udivdi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 1c             	sub    $0x1c,%esp
  801f67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801f6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801f77:	85 d2                	test   %edx,%edx
  801f79:	75 35                	jne    801fb0 <__udivdi3+0x50>
  801f7b:	39 f3                	cmp    %esi,%ebx
  801f7d:	0f 87 bd 00 00 00    	ja     802040 <__udivdi3+0xe0>
  801f83:	85 db                	test   %ebx,%ebx
  801f85:	89 d9                	mov    %ebx,%ecx
  801f87:	75 0b                	jne    801f94 <__udivdi3+0x34>
  801f89:	b8 01 00 00 00       	mov    $0x1,%eax
  801f8e:	31 d2                	xor    %edx,%edx
  801f90:	f7 f3                	div    %ebx
  801f92:	89 c1                	mov    %eax,%ecx
  801f94:	31 d2                	xor    %edx,%edx
  801f96:	89 f0                	mov    %esi,%eax
  801f98:	f7 f1                	div    %ecx
  801f9a:	89 c6                	mov    %eax,%esi
  801f9c:	89 e8                	mov    %ebp,%eax
  801f9e:	89 f7                	mov    %esi,%edi
  801fa0:	f7 f1                	div    %ecx
  801fa2:	89 fa                	mov    %edi,%edx
  801fa4:	83 c4 1c             	add    $0x1c,%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5f                   	pop    %edi
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    
  801fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb0:	39 f2                	cmp    %esi,%edx
  801fb2:	77 7c                	ja     802030 <__udivdi3+0xd0>
  801fb4:	0f bd fa             	bsr    %edx,%edi
  801fb7:	83 f7 1f             	xor    $0x1f,%edi
  801fba:	0f 84 98 00 00 00    	je     802058 <__udivdi3+0xf8>
  801fc0:	89 f9                	mov    %edi,%ecx
  801fc2:	b8 20 00 00 00       	mov    $0x20,%eax
  801fc7:	29 f8                	sub    %edi,%eax
  801fc9:	d3 e2                	shl    %cl,%edx
  801fcb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fcf:	89 c1                	mov    %eax,%ecx
  801fd1:	89 da                	mov    %ebx,%edx
  801fd3:	d3 ea                	shr    %cl,%edx
  801fd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801fd9:	09 d1                	or     %edx,%ecx
  801fdb:	89 f2                	mov    %esi,%edx
  801fdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fe1:	89 f9                	mov    %edi,%ecx
  801fe3:	d3 e3                	shl    %cl,%ebx
  801fe5:	89 c1                	mov    %eax,%ecx
  801fe7:	d3 ea                	shr    %cl,%edx
  801fe9:	89 f9                	mov    %edi,%ecx
  801feb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801fef:	d3 e6                	shl    %cl,%esi
  801ff1:	89 eb                	mov    %ebp,%ebx
  801ff3:	89 c1                	mov    %eax,%ecx
  801ff5:	d3 eb                	shr    %cl,%ebx
  801ff7:	09 de                	or     %ebx,%esi
  801ff9:	89 f0                	mov    %esi,%eax
  801ffb:	f7 74 24 08          	divl   0x8(%esp)
  801fff:	89 d6                	mov    %edx,%esi
  802001:	89 c3                	mov    %eax,%ebx
  802003:	f7 64 24 0c          	mull   0xc(%esp)
  802007:	39 d6                	cmp    %edx,%esi
  802009:	72 0c                	jb     802017 <__udivdi3+0xb7>
  80200b:	89 f9                	mov    %edi,%ecx
  80200d:	d3 e5                	shl    %cl,%ebp
  80200f:	39 c5                	cmp    %eax,%ebp
  802011:	73 5d                	jae    802070 <__udivdi3+0x110>
  802013:	39 d6                	cmp    %edx,%esi
  802015:	75 59                	jne    802070 <__udivdi3+0x110>
  802017:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80201a:	31 ff                	xor    %edi,%edi
  80201c:	89 fa                	mov    %edi,%edx
  80201e:	83 c4 1c             	add    $0x1c,%esp
  802021:	5b                   	pop    %ebx
  802022:	5e                   	pop    %esi
  802023:	5f                   	pop    %edi
  802024:	5d                   	pop    %ebp
  802025:	c3                   	ret    
  802026:	8d 76 00             	lea    0x0(%esi),%esi
  802029:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802030:	31 ff                	xor    %edi,%edi
  802032:	31 c0                	xor    %eax,%eax
  802034:	89 fa                	mov    %edi,%edx
  802036:	83 c4 1c             	add    $0x1c,%esp
  802039:	5b                   	pop    %ebx
  80203a:	5e                   	pop    %esi
  80203b:	5f                   	pop    %edi
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    
  80203e:	66 90                	xchg   %ax,%ax
  802040:	31 ff                	xor    %edi,%edi
  802042:	89 e8                	mov    %ebp,%eax
  802044:	89 f2                	mov    %esi,%edx
  802046:	f7 f3                	div    %ebx
  802048:	89 fa                	mov    %edi,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	39 f2                	cmp    %esi,%edx
  80205a:	72 06                	jb     802062 <__udivdi3+0x102>
  80205c:	31 c0                	xor    %eax,%eax
  80205e:	39 eb                	cmp    %ebp,%ebx
  802060:	77 d2                	ja     802034 <__udivdi3+0xd4>
  802062:	b8 01 00 00 00       	mov    $0x1,%eax
  802067:	eb cb                	jmp    802034 <__udivdi3+0xd4>
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d8                	mov    %ebx,%eax
  802072:	31 ff                	xor    %edi,%edi
  802074:	eb be                	jmp    802034 <__udivdi3+0xd4>
  802076:	66 90                	xchg   %ax,%ax
  802078:	66 90                	xchg   %ax,%ax
  80207a:	66 90                	xchg   %ax,%ax
  80207c:	66 90                	xchg   %ax,%ax
  80207e:	66 90                	xchg   %ax,%ax

00802080 <__umoddi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80208b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80208f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 ed                	test   %ebp,%ebp
  802099:	89 f0                	mov    %esi,%eax
  80209b:	89 da                	mov    %ebx,%edx
  80209d:	75 19                	jne    8020b8 <__umoddi3+0x38>
  80209f:	39 df                	cmp    %ebx,%edi
  8020a1:	0f 86 b1 00 00 00    	jbe    802158 <__umoddi3+0xd8>
  8020a7:	f7 f7                	div    %edi
  8020a9:	89 d0                	mov    %edx,%eax
  8020ab:	31 d2                	xor    %edx,%edx
  8020ad:	83 c4 1c             	add    $0x1c,%esp
  8020b0:	5b                   	pop    %ebx
  8020b1:	5e                   	pop    %esi
  8020b2:	5f                   	pop    %edi
  8020b3:	5d                   	pop    %ebp
  8020b4:	c3                   	ret    
  8020b5:	8d 76 00             	lea    0x0(%esi),%esi
  8020b8:	39 dd                	cmp    %ebx,%ebp
  8020ba:	77 f1                	ja     8020ad <__umoddi3+0x2d>
  8020bc:	0f bd cd             	bsr    %ebp,%ecx
  8020bf:	83 f1 1f             	xor    $0x1f,%ecx
  8020c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020c6:	0f 84 b4 00 00 00    	je     802180 <__umoddi3+0x100>
  8020cc:	b8 20 00 00 00       	mov    $0x20,%eax
  8020d1:	89 c2                	mov    %eax,%edx
  8020d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020d7:	29 c2                	sub    %eax,%edx
  8020d9:	89 c1                	mov    %eax,%ecx
  8020db:	89 f8                	mov    %edi,%eax
  8020dd:	d3 e5                	shl    %cl,%ebp
  8020df:	89 d1                	mov    %edx,%ecx
  8020e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8020e5:	d3 e8                	shr    %cl,%eax
  8020e7:	09 c5                	or     %eax,%ebp
  8020e9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020ed:	89 c1                	mov    %eax,%ecx
  8020ef:	d3 e7                	shl    %cl,%edi
  8020f1:	89 d1                	mov    %edx,%ecx
  8020f3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8020f7:	89 df                	mov    %ebx,%edi
  8020f9:	d3 ef                	shr    %cl,%edi
  8020fb:	89 c1                	mov    %eax,%ecx
  8020fd:	89 f0                	mov    %esi,%eax
  8020ff:	d3 e3                	shl    %cl,%ebx
  802101:	89 d1                	mov    %edx,%ecx
  802103:	89 fa                	mov    %edi,%edx
  802105:	d3 e8                	shr    %cl,%eax
  802107:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80210c:	09 d8                	or     %ebx,%eax
  80210e:	f7 f5                	div    %ebp
  802110:	d3 e6                	shl    %cl,%esi
  802112:	89 d1                	mov    %edx,%ecx
  802114:	f7 64 24 08          	mull   0x8(%esp)
  802118:	39 d1                	cmp    %edx,%ecx
  80211a:	89 c3                	mov    %eax,%ebx
  80211c:	89 d7                	mov    %edx,%edi
  80211e:	72 06                	jb     802126 <__umoddi3+0xa6>
  802120:	75 0e                	jne    802130 <__umoddi3+0xb0>
  802122:	39 c6                	cmp    %eax,%esi
  802124:	73 0a                	jae    802130 <__umoddi3+0xb0>
  802126:	2b 44 24 08          	sub    0x8(%esp),%eax
  80212a:	19 ea                	sbb    %ebp,%edx
  80212c:	89 d7                	mov    %edx,%edi
  80212e:	89 c3                	mov    %eax,%ebx
  802130:	89 ca                	mov    %ecx,%edx
  802132:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802137:	29 de                	sub    %ebx,%esi
  802139:	19 fa                	sbb    %edi,%edx
  80213b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80213f:	89 d0                	mov    %edx,%eax
  802141:	d3 e0                	shl    %cl,%eax
  802143:	89 d9                	mov    %ebx,%ecx
  802145:	d3 ee                	shr    %cl,%esi
  802147:	d3 ea                	shr    %cl,%edx
  802149:	09 f0                	or     %esi,%eax
  80214b:	83 c4 1c             	add    $0x1c,%esp
  80214e:	5b                   	pop    %ebx
  80214f:	5e                   	pop    %esi
  802150:	5f                   	pop    %edi
  802151:	5d                   	pop    %ebp
  802152:	c3                   	ret    
  802153:	90                   	nop
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	85 ff                	test   %edi,%edi
  80215a:	89 f9                	mov    %edi,%ecx
  80215c:	75 0b                	jne    802169 <__umoddi3+0xe9>
  80215e:	b8 01 00 00 00       	mov    $0x1,%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	f7 f7                	div    %edi
  802167:	89 c1                	mov    %eax,%ecx
  802169:	89 d8                	mov    %ebx,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	f7 f1                	div    %ecx
  80216f:	89 f0                	mov    %esi,%eax
  802171:	f7 f1                	div    %ecx
  802173:	e9 31 ff ff ff       	jmp    8020a9 <__umoddi3+0x29>
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	39 dd                	cmp    %ebx,%ebp
  802182:	72 08                	jb     80218c <__umoddi3+0x10c>
  802184:	39 f7                	cmp    %esi,%edi
  802186:	0f 87 21 ff ff ff    	ja     8020ad <__umoddi3+0x2d>
  80218c:	89 da                	mov    %ebx,%edx
  80218e:	89 f0                	mov    %esi,%eax
  802190:	29 f8                	sub    %edi,%eax
  802192:	19 ea                	sbb    %ebp,%edx
  802194:	e9 14 ff ff ff       	jmp    8020ad <__umoddi3+0x2d>
