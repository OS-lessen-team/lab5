
obj/user/testbss.debug：     文件格式 elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 40 1e 80 00       	push   $0x801e40
  80003e:	e8 d4 01 00 00       	call   800217 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	75 63                	jne    8000b8 <umain+0x85>
	for (i = 0; i < ARRAYSIZE; i++)
  800055:	83 c0 01             	add    $0x1,%eax
  800058:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80005d:	75 ec                	jne    80004b <umain+0x18>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80005f:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800064:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006b:	83 c0 01             	add    $0x1,%eax
  80006e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800073:	75 ef                	jne    800064 <umain+0x31>
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007a:	39 04 85 20 40 80 00 	cmp    %eax,0x804020(,%eax,4)
  800081:	75 47                	jne    8000ca <umain+0x97>
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 ed                	jne    80007a <umain+0x47>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	68 88 1e 80 00       	push   $0x801e88
  800095:	e8 7d 01 00 00       	call   800217 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009a:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000a1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	68 e7 1e 80 00       	push   $0x801ee7
  8000ac:	6a 1a                	push   $0x1a
  8000ae:	68 d8 1e 80 00       	push   $0x801ed8
  8000b3:	e8 84 00 00 00       	call   80013c <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b8:	50                   	push   %eax
  8000b9:	68 bb 1e 80 00       	push   $0x801ebb
  8000be:	6a 11                	push   $0x11
  8000c0:	68 d8 1e 80 00       	push   $0x801ed8
  8000c5:	e8 72 00 00 00       	call   80013c <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ca:	50                   	push   %eax
  8000cb:	68 60 1e 80 00       	push   $0x801e60
  8000d0:	6a 16                	push   $0x16
  8000d2:	68 d8 1e 80 00       	push   $0x801ed8
  8000d7:	e8 60 00 00 00       	call   80013c <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000e7:	e8 05 0b 00 00       	call   800bf1 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 40 c0 00       	mov    %eax,0xc04020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 c9 0e 00 00       	call   800ff6 <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 79 0a 00 00       	call   800bb0 <sys_env_destroy>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014a:	e8 a2 0a 00 00       	call   800bf1 <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 08 1f 80 00       	push   $0x801f08
  80015f:	e8 b3 00 00 00       	call   800217 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 56 00 00 00       	call   8001c6 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 d6 1e 80 00 	movl   $0x801ed6,(%esp)
  800177:	e8 9b 00 00 00       	call   800217 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	74 09                	je     8001aa <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001aa:	83 ec 08             	sub    $0x8,%esp
  8001ad:	68 ff 00 00 00       	push   $0xff
  8001b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b5:	50                   	push   %eax
  8001b6:	e8 b8 09 00 00       	call   800b73 <sys_cputs>
		b->idx = 0;
  8001bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c1:	83 c4 10             	add    $0x10,%esp
  8001c4:	eb db                	jmp    8001a1 <putch+0x1f>

008001c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d6:	00 00 00 
	b.cnt = 0;
  8001d9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e3:	ff 75 0c             	pushl  0xc(%ebp)
  8001e6:	ff 75 08             	pushl  0x8(%ebp)
  8001e9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	68 82 01 80 00       	push   $0x800182
  8001f5:	e8 1a 01 00 00       	call   800314 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fa:	83 c4 08             	add    $0x8,%esp
  8001fd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800203:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	e8 64 09 00 00       	call   800b73 <sys_cputs>

	return b.cnt;
}
  80020f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800220:	50                   	push   %eax
  800221:	ff 75 08             	pushl  0x8(%ebp)
  800224:	e8 9d ff ff ff       	call   8001c6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 1c             	sub    $0x1c,%esp
  800234:	89 c7                	mov    %eax,%edi
  800236:	89 d6                	mov    %edx,%esi
  800238:	8b 45 08             	mov    0x8(%ebp),%eax
  80023b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800241:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800244:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800247:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800252:	39 d3                	cmp    %edx,%ebx
  800254:	72 05                	jb     80025b <printnum+0x30>
  800256:	39 45 10             	cmp    %eax,0x10(%ebp)
  800259:	77 7a                	ja     8002d5 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025b:	83 ec 0c             	sub    $0xc,%esp
  80025e:	ff 75 18             	pushl  0x18(%ebp)
  800261:	8b 45 14             	mov    0x14(%ebp),%eax
  800264:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800267:	53                   	push   %ebx
  800268:	ff 75 10             	pushl  0x10(%ebp)
  80026b:	83 ec 08             	sub    $0x8,%esp
  80026e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800271:	ff 75 e0             	pushl  -0x20(%ebp)
  800274:	ff 75 dc             	pushl  -0x24(%ebp)
  800277:	ff 75 d8             	pushl  -0x28(%ebp)
  80027a:	e8 81 19 00 00       	call   801c00 <__udivdi3>
  80027f:	83 c4 18             	add    $0x18,%esp
  800282:	52                   	push   %edx
  800283:	50                   	push   %eax
  800284:	89 f2                	mov    %esi,%edx
  800286:	89 f8                	mov    %edi,%eax
  800288:	e8 9e ff ff ff       	call   80022b <printnum>
  80028d:	83 c4 20             	add    $0x20,%esp
  800290:	eb 13                	jmp    8002a5 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800292:	83 ec 08             	sub    $0x8,%esp
  800295:	56                   	push   %esi
  800296:	ff 75 18             	pushl  0x18(%ebp)
  800299:	ff d7                	call   *%edi
  80029b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80029e:	83 eb 01             	sub    $0x1,%ebx
  8002a1:	85 db                	test   %ebx,%ebx
  8002a3:	7f ed                	jg     800292 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a5:	83 ec 08             	sub    $0x8,%esp
  8002a8:	56                   	push   %esi
  8002a9:	83 ec 04             	sub    $0x4,%esp
  8002ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002af:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b8:	e8 63 1a 00 00       	call   801d20 <__umoddi3>
  8002bd:	83 c4 14             	add    $0x14,%esp
  8002c0:	0f be 80 2b 1f 80 00 	movsbl 0x801f2b(%eax),%eax
  8002c7:	50                   	push   %eax
  8002c8:	ff d7                	call   *%edi
}
  8002ca:	83 c4 10             	add    $0x10,%esp
  8002cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d0:	5b                   	pop    %ebx
  8002d1:	5e                   	pop    %esi
  8002d2:	5f                   	pop    %edi
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    
  8002d5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d8:	eb c4                	jmp    80029e <printnum+0x73>

008002da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e9:	73 0a                	jae    8002f5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002eb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f3:	88 02                	mov    %al,(%edx)
}
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <printfmt>:
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002fd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800300:	50                   	push   %eax
  800301:	ff 75 10             	pushl  0x10(%ebp)
  800304:	ff 75 0c             	pushl  0xc(%ebp)
  800307:	ff 75 08             	pushl  0x8(%ebp)
  80030a:	e8 05 00 00 00       	call   800314 <vprintfmt>
}
  80030f:	83 c4 10             	add    $0x10,%esp
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <vprintfmt>:
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 2c             	sub    $0x2c,%esp
  80031d:	8b 75 08             	mov    0x8(%ebp),%esi
  800320:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800323:	8b 7d 10             	mov    0x10(%ebp),%edi
  800326:	e9 c1 03 00 00       	jmp    8006ec <vprintfmt+0x3d8>
		padc = ' ';
  80032b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80032f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800336:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80033d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800344:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8d 47 01             	lea    0x1(%edi),%eax
  80034c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034f:	0f b6 17             	movzbl (%edi),%edx
  800352:	8d 42 dd             	lea    -0x23(%edx),%eax
  800355:	3c 55                	cmp    $0x55,%al
  800357:	0f 87 12 04 00 00    	ja     80076f <vprintfmt+0x45b>
  80035d:	0f b6 c0             	movzbl %al,%eax
  800360:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80036a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80036e:	eb d9                	jmp    800349 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800373:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800377:	eb d0                	jmp    800349 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800379:	0f b6 d2             	movzbl %dl,%edx
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80037f:	b8 00 00 00 00       	mov    $0x0,%eax
  800384:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800387:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80038e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800391:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800394:	83 f9 09             	cmp    $0x9,%ecx
  800397:	77 55                	ja     8003ee <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800399:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80039c:	eb e9                	jmp    800387 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80039e:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a1:	8b 00                	mov    (%eax),%eax
  8003a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a9:	8d 40 04             	lea    0x4(%eax),%eax
  8003ac:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b6:	79 91                	jns    800349 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003b8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003be:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c5:	eb 82                	jmp    800349 <vprintfmt+0x35>
  8003c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d1:	0f 49 d0             	cmovns %eax,%edx
  8003d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003da:	e9 6a ff ff ff       	jmp    800349 <vprintfmt+0x35>
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003e2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e9:	e9 5b ff ff ff       	jmp    800349 <vprintfmt+0x35>
  8003ee:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003f4:	eb bc                	jmp    8003b2 <vprintfmt+0x9e>
			lflag++;
  8003f6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fc:	e9 48 ff ff ff       	jmp    800349 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 78 04             	lea    0x4(%eax),%edi
  800407:	83 ec 08             	sub    $0x8,%esp
  80040a:	53                   	push   %ebx
  80040b:	ff 30                	pushl  (%eax)
  80040d:	ff d6                	call   *%esi
			break;
  80040f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800412:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800415:	e9 cf 02 00 00       	jmp    8006e9 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 78 04             	lea    0x4(%eax),%edi
  800420:	8b 00                	mov    (%eax),%eax
  800422:	99                   	cltd   
  800423:	31 d0                	xor    %edx,%eax
  800425:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800427:	83 f8 0f             	cmp    $0xf,%eax
  80042a:	7f 23                	jg     80044f <vprintfmt+0x13b>
  80042c:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  800433:	85 d2                	test   %edx,%edx
  800435:	74 18                	je     80044f <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800437:	52                   	push   %edx
  800438:	68 f5 22 80 00       	push   $0x8022f5
  80043d:	53                   	push   %ebx
  80043e:	56                   	push   %esi
  80043f:	e8 b3 fe ff ff       	call   8002f7 <printfmt>
  800444:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800447:	89 7d 14             	mov    %edi,0x14(%ebp)
  80044a:	e9 9a 02 00 00       	jmp    8006e9 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80044f:	50                   	push   %eax
  800450:	68 43 1f 80 00       	push   $0x801f43
  800455:	53                   	push   %ebx
  800456:	56                   	push   %esi
  800457:	e8 9b fe ff ff       	call   8002f7 <printfmt>
  80045c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800462:	e9 82 02 00 00       	jmp    8006e9 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	83 c0 04             	add    $0x4,%eax
  80046d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800475:	85 ff                	test   %edi,%edi
  800477:	b8 3c 1f 80 00       	mov    $0x801f3c,%eax
  80047c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80047f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800483:	0f 8e bd 00 00 00    	jle    800546 <vprintfmt+0x232>
  800489:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048d:	75 0e                	jne    80049d <vprintfmt+0x189>
  80048f:	89 75 08             	mov    %esi,0x8(%ebp)
  800492:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800498:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80049b:	eb 6d                	jmp    80050a <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a3:	57                   	push   %edi
  8004a4:	e8 6e 03 00 00       	call   800817 <strnlen>
  8004a9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ac:	29 c1                	sub    %eax,%ecx
  8004ae:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004b1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004be:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	eb 0f                	jmp    8004d1 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	53                   	push   %ebx
  8004c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	83 ef 01             	sub    $0x1,%edi
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	85 ff                	test   %edi,%edi
  8004d3:	7f ed                	jg     8004c2 <vprintfmt+0x1ae>
  8004d5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004db:	85 c9                	test   %ecx,%ecx
  8004dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e2:	0f 49 c1             	cmovns %ecx,%eax
  8004e5:	29 c1                	sub    %eax,%ecx
  8004e7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ea:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ed:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f0:	89 cb                	mov    %ecx,%ebx
  8004f2:	eb 16                	jmp    80050a <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f8:	75 31                	jne    80052b <vprintfmt+0x217>
					putch(ch, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	50                   	push   %eax
  800501:	ff 55 08             	call   *0x8(%ebp)
  800504:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800507:	83 eb 01             	sub    $0x1,%ebx
  80050a:	83 c7 01             	add    $0x1,%edi
  80050d:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800511:	0f be c2             	movsbl %dl,%eax
  800514:	85 c0                	test   %eax,%eax
  800516:	74 59                	je     800571 <vprintfmt+0x25d>
  800518:	85 f6                	test   %esi,%esi
  80051a:	78 d8                	js     8004f4 <vprintfmt+0x1e0>
  80051c:	83 ee 01             	sub    $0x1,%esi
  80051f:	79 d3                	jns    8004f4 <vprintfmt+0x1e0>
  800521:	89 df                	mov    %ebx,%edi
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	eb 37                	jmp    800562 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80052b:	0f be d2             	movsbl %dl,%edx
  80052e:	83 ea 20             	sub    $0x20,%edx
  800531:	83 fa 5e             	cmp    $0x5e,%edx
  800534:	76 c4                	jbe    8004fa <vprintfmt+0x1e6>
					putch('?', putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	ff 75 0c             	pushl  0xc(%ebp)
  80053c:	6a 3f                	push   $0x3f
  80053e:	ff 55 08             	call   *0x8(%ebp)
  800541:	83 c4 10             	add    $0x10,%esp
  800544:	eb c1                	jmp    800507 <vprintfmt+0x1f3>
  800546:	89 75 08             	mov    %esi,0x8(%ebp)
  800549:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800552:	eb b6                	jmp    80050a <vprintfmt+0x1f6>
				putch(' ', putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	53                   	push   %ebx
  800558:	6a 20                	push   $0x20
  80055a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80055c:	83 ef 01             	sub    $0x1,%edi
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	85 ff                	test   %edi,%edi
  800564:	7f ee                	jg     800554 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800566:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800569:	89 45 14             	mov    %eax,0x14(%ebp)
  80056c:	e9 78 01 00 00       	jmp    8006e9 <vprintfmt+0x3d5>
  800571:	89 df                	mov    %ebx,%edi
  800573:	8b 75 08             	mov    0x8(%ebp),%esi
  800576:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800579:	eb e7                	jmp    800562 <vprintfmt+0x24e>
	if (lflag >= 2)
  80057b:	83 f9 01             	cmp    $0x1,%ecx
  80057e:	7e 3f                	jle    8005bf <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8b 50 04             	mov    0x4(%eax),%edx
  800586:	8b 00                	mov    (%eax),%eax
  800588:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 40 08             	lea    0x8(%eax),%eax
  800594:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800597:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059b:	79 5c                	jns    8005f9 <vprintfmt+0x2e5>
				putch('-', putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	53                   	push   %ebx
  8005a1:	6a 2d                	push   $0x2d
  8005a3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ab:	f7 da                	neg    %edx
  8005ad:	83 d1 00             	adc    $0x0,%ecx
  8005b0:	f7 d9                	neg    %ecx
  8005b2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ba:	e9 10 01 00 00       	jmp    8006cf <vprintfmt+0x3bb>
	else if (lflag)
  8005bf:	85 c9                	test   %ecx,%ecx
  8005c1:	75 1b                	jne    8005de <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8b 00                	mov    (%eax),%eax
  8005c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cb:	89 c1                	mov    %eax,%ecx
  8005cd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 40 04             	lea    0x4(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dc:	eb b9                	jmp    800597 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e6:	89 c1                	mov    %eax,%ecx
  8005e8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005eb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 40 04             	lea    0x4(%eax),%eax
  8005f4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f7:	eb 9e                	jmp    800597 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005f9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800604:	e9 c6 00 00 00       	jmp    8006cf <vprintfmt+0x3bb>
	if (lflag >= 2)
  800609:	83 f9 01             	cmp    $0x1,%ecx
  80060c:	7e 18                	jle    800626 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8b 10                	mov    (%eax),%edx
  800613:	8b 48 04             	mov    0x4(%eax),%ecx
  800616:	8d 40 08             	lea    0x8(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800621:	e9 a9 00 00 00       	jmp    8006cf <vprintfmt+0x3bb>
	else if (lflag)
  800626:	85 c9                	test   %ecx,%ecx
  800628:	75 1a                	jne    800644 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8b 10                	mov    (%eax),%edx
  80062f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800634:	8d 40 04             	lea    0x4(%eax),%eax
  800637:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063f:	e9 8b 00 00 00       	jmp    8006cf <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8b 10                	mov    (%eax),%edx
  800649:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064e:	8d 40 04             	lea    0x4(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800654:	b8 0a 00 00 00       	mov    $0xa,%eax
  800659:	eb 74                	jmp    8006cf <vprintfmt+0x3bb>
	if (lflag >= 2)
  80065b:	83 f9 01             	cmp    $0x1,%ecx
  80065e:	7e 15                	jle    800675 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 10                	mov    (%eax),%edx
  800665:	8b 48 04             	mov    0x4(%eax),%ecx
  800668:	8d 40 08             	lea    0x8(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80066e:	b8 08 00 00 00       	mov    $0x8,%eax
  800673:	eb 5a                	jmp    8006cf <vprintfmt+0x3bb>
	else if (lflag)
  800675:	85 c9                	test   %ecx,%ecx
  800677:	75 17                	jne    800690 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8b 10                	mov    (%eax),%edx
  80067e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800689:	b8 08 00 00 00       	mov    $0x8,%eax
  80068e:	eb 3f                	jmp    8006cf <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 10                	mov    (%eax),%edx
  800695:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069a:	8d 40 04             	lea    0x4(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8006a5:	eb 28                	jmp    8006cf <vprintfmt+0x3bb>
			putch('0', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 30                	push   $0x30
  8006ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8006af:	83 c4 08             	add    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 78                	push   $0x78
  8006b5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006c1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ca:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006cf:	83 ec 0c             	sub    $0xc,%esp
  8006d2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006d6:	57                   	push   %edi
  8006d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006da:	50                   	push   %eax
  8006db:	51                   	push   %ecx
  8006dc:	52                   	push   %edx
  8006dd:	89 da                	mov    %ebx,%edx
  8006df:	89 f0                	mov    %esi,%eax
  8006e1:	e8 45 fb ff ff       	call   80022b <printnum>
			break;
  8006e6:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ec:	83 c7 01             	add    $0x1,%edi
  8006ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f3:	83 f8 25             	cmp    $0x25,%eax
  8006f6:	0f 84 2f fc ff ff    	je     80032b <vprintfmt+0x17>
			if (ch == '\0')
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	0f 84 8b 00 00 00    	je     80078f <vprintfmt+0x47b>
			putch(ch, putdat);
  800704:	83 ec 08             	sub    $0x8,%esp
  800707:	53                   	push   %ebx
  800708:	50                   	push   %eax
  800709:	ff d6                	call   *%esi
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	eb dc                	jmp    8006ec <vprintfmt+0x3d8>
	if (lflag >= 2)
  800710:	83 f9 01             	cmp    $0x1,%ecx
  800713:	7e 15                	jle    80072a <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8b 10                	mov    (%eax),%edx
  80071a:	8b 48 04             	mov    0x4(%eax),%ecx
  80071d:	8d 40 08             	lea    0x8(%eax),%eax
  800720:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800723:	b8 10 00 00 00       	mov    $0x10,%eax
  800728:	eb a5                	jmp    8006cf <vprintfmt+0x3bb>
	else if (lflag)
  80072a:	85 c9                	test   %ecx,%ecx
  80072c:	75 17                	jne    800745 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8b 10                	mov    (%eax),%edx
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
  800738:	8d 40 04             	lea    0x4(%eax),%eax
  80073b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073e:	b8 10 00 00 00       	mov    $0x10,%eax
  800743:	eb 8a                	jmp    8006cf <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8b 10                	mov    (%eax),%edx
  80074a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074f:	8d 40 04             	lea    0x4(%eax),%eax
  800752:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800755:	b8 10 00 00 00       	mov    $0x10,%eax
  80075a:	e9 70 ff ff ff       	jmp    8006cf <vprintfmt+0x3bb>
			putch(ch, putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	53                   	push   %ebx
  800763:	6a 25                	push   $0x25
  800765:	ff d6                	call   *%esi
			break;
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	e9 7a ff ff ff       	jmp    8006e9 <vprintfmt+0x3d5>
			putch('%', putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 25                	push   $0x25
  800775:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800777:	83 c4 10             	add    $0x10,%esp
  80077a:	89 f8                	mov    %edi,%eax
  80077c:	eb 03                	jmp    800781 <vprintfmt+0x46d>
  80077e:	83 e8 01             	sub    $0x1,%eax
  800781:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800785:	75 f7                	jne    80077e <vprintfmt+0x46a>
  800787:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80078a:	e9 5a ff ff ff       	jmp    8006e9 <vprintfmt+0x3d5>
}
  80078f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800792:	5b                   	pop    %ebx
  800793:	5e                   	pop    %esi
  800794:	5f                   	pop    %edi
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	83 ec 18             	sub    $0x18,%esp
  80079d:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b4:	85 c0                	test   %eax,%eax
  8007b6:	74 26                	je     8007de <vsnprintf+0x47>
  8007b8:	85 d2                	test   %edx,%edx
  8007ba:	7e 22                	jle    8007de <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bc:	ff 75 14             	pushl  0x14(%ebp)
  8007bf:	ff 75 10             	pushl  0x10(%ebp)
  8007c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c5:	50                   	push   %eax
  8007c6:	68 da 02 80 00       	push   $0x8002da
  8007cb:	e8 44 fb ff ff       	call   800314 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d9:	83 c4 10             	add    $0x10,%esp
}
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    
		return -E_INVAL;
  8007de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e3:	eb f7                	jmp    8007dc <vsnprintf+0x45>

008007e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ee:	50                   	push   %eax
  8007ef:	ff 75 10             	pushl  0x10(%ebp)
  8007f2:	ff 75 0c             	pushl  0xc(%ebp)
  8007f5:	ff 75 08             	pushl  0x8(%ebp)
  8007f8:	e8 9a ff ff ff       	call   800797 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
  80080a:	eb 03                	jmp    80080f <strlen+0x10>
		n++;
  80080c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80080f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800813:	75 f7                	jne    80080c <strlen+0xd>
	return n;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800820:	b8 00 00 00 00       	mov    $0x0,%eax
  800825:	eb 03                	jmp    80082a <strnlen+0x13>
		n++;
  800827:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082a:	39 d0                	cmp    %edx,%eax
  80082c:	74 06                	je     800834 <strnlen+0x1d>
  80082e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800832:	75 f3                	jne    800827 <strnlen+0x10>
	return n;
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800840:	89 c2                	mov    %eax,%edx
  800842:	83 c1 01             	add    $0x1,%ecx
  800845:	83 c2 01             	add    $0x1,%edx
  800848:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084f:	84 db                	test   %bl,%bl
  800851:	75 ef                	jne    800842 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800853:	5b                   	pop    %ebx
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	53                   	push   %ebx
  80085a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085d:	53                   	push   %ebx
  80085e:	e8 9c ff ff ff       	call   8007ff <strlen>
  800863:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	01 d8                	add    %ebx,%eax
  80086b:	50                   	push   %eax
  80086c:	e8 c5 ff ff ff       	call   800836 <strcpy>
	return dst;
}
  800871:	89 d8                	mov    %ebx,%eax
  800873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 75 08             	mov    0x8(%ebp),%esi
  800880:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800883:	89 f3                	mov    %esi,%ebx
  800885:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	89 f2                	mov    %esi,%edx
  80088a:	eb 0f                	jmp    80089b <strncpy+0x23>
		*dst++ = *src;
  80088c:	83 c2 01             	add    $0x1,%edx
  80088f:	0f b6 01             	movzbl (%ecx),%eax
  800892:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800895:	80 39 01             	cmpb   $0x1,(%ecx)
  800898:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80089b:	39 da                	cmp    %ebx,%edx
  80089d:	75 ed                	jne    80088c <strncpy+0x14>
	}
	return ret;
}
  80089f:	89 f0                	mov    %esi,%eax
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008b3:	89 f0                	mov    %esi,%eax
  8008b5:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b9:	85 c9                	test   %ecx,%ecx
  8008bb:	75 0b                	jne    8008c8 <strlcpy+0x23>
  8008bd:	eb 17                	jmp    8008d6 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008bf:	83 c2 01             	add    $0x1,%edx
  8008c2:	83 c0 01             	add    $0x1,%eax
  8008c5:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008c8:	39 d8                	cmp    %ebx,%eax
  8008ca:	74 07                	je     8008d3 <strlcpy+0x2e>
  8008cc:	0f b6 0a             	movzbl (%edx),%ecx
  8008cf:	84 c9                	test   %cl,%cl
  8008d1:	75 ec                	jne    8008bf <strlcpy+0x1a>
		*dst = '\0';
  8008d3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d6:	29 f0                	sub    %esi,%eax
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5e                   	pop    %esi
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e5:	eb 06                	jmp    8008ed <strcmp+0x11>
		p++, q++;
  8008e7:	83 c1 01             	add    $0x1,%ecx
  8008ea:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ed:	0f b6 01             	movzbl (%ecx),%eax
  8008f0:	84 c0                	test   %al,%al
  8008f2:	74 04                	je     8008f8 <strcmp+0x1c>
  8008f4:	3a 02                	cmp    (%edx),%al
  8008f6:	74 ef                	je     8008e7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f8:	0f b6 c0             	movzbl %al,%eax
  8008fb:	0f b6 12             	movzbl (%edx),%edx
  8008fe:	29 d0                	sub    %edx,%eax
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	53                   	push   %ebx
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090c:	89 c3                	mov    %eax,%ebx
  80090e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800911:	eb 06                	jmp    800919 <strncmp+0x17>
		n--, p++, q++;
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800919:	39 d8                	cmp    %ebx,%eax
  80091b:	74 16                	je     800933 <strncmp+0x31>
  80091d:	0f b6 08             	movzbl (%eax),%ecx
  800920:	84 c9                	test   %cl,%cl
  800922:	74 04                	je     800928 <strncmp+0x26>
  800924:	3a 0a                	cmp    (%edx),%cl
  800926:	74 eb                	je     800913 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800928:	0f b6 00             	movzbl (%eax),%eax
  80092b:	0f b6 12             	movzbl (%edx),%edx
  80092e:	29 d0                	sub    %edx,%eax
}
  800930:	5b                   	pop    %ebx
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    
		return 0;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
  800938:	eb f6                	jmp    800930 <strncmp+0x2e>

0080093a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800944:	0f b6 10             	movzbl (%eax),%edx
  800947:	84 d2                	test   %dl,%dl
  800949:	74 09                	je     800954 <strchr+0x1a>
		if (*s == c)
  80094b:	38 ca                	cmp    %cl,%dl
  80094d:	74 0a                	je     800959 <strchr+0x1f>
	for (; *s; s++)
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	eb f0                	jmp    800944 <strchr+0xa>
			return (char *) s;
	return 0;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800965:	eb 03                	jmp    80096a <strfind+0xf>
  800967:	83 c0 01             	add    $0x1,%eax
  80096a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80096d:	38 ca                	cmp    %cl,%dl
  80096f:	74 04                	je     800975 <strfind+0x1a>
  800971:	84 d2                	test   %dl,%dl
  800973:	75 f2                	jne    800967 <strfind+0xc>
			break;
	return (char *) s;
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800980:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800983:	85 c9                	test   %ecx,%ecx
  800985:	74 13                	je     80099a <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800987:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098d:	75 05                	jne    800994 <memset+0x1d>
  80098f:	f6 c1 03             	test   $0x3,%cl
  800992:	74 0d                	je     8009a1 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800994:	8b 45 0c             	mov    0xc(%ebp),%eax
  800997:	fc                   	cld    
  800998:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099a:	89 f8                	mov    %edi,%eax
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    
		c &= 0xFF;
  8009a1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a5:	89 d3                	mov    %edx,%ebx
  8009a7:	c1 e3 08             	shl    $0x8,%ebx
  8009aa:	89 d0                	mov    %edx,%eax
  8009ac:	c1 e0 18             	shl    $0x18,%eax
  8009af:	89 d6                	mov    %edx,%esi
  8009b1:	c1 e6 10             	shl    $0x10,%esi
  8009b4:	09 f0                	or     %esi,%eax
  8009b6:	09 c2                	or     %eax,%edx
  8009b8:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009bd:	89 d0                	mov    %edx,%eax
  8009bf:	fc                   	cld    
  8009c0:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c2:	eb d6                	jmp    80099a <memset+0x23>

008009c4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d2:	39 c6                	cmp    %eax,%esi
  8009d4:	73 35                	jae    800a0b <memmove+0x47>
  8009d6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d9:	39 c2                	cmp    %eax,%edx
  8009db:	76 2e                	jbe    800a0b <memmove+0x47>
		s += n;
		d += n;
  8009dd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e0:	89 d6                	mov    %edx,%esi
  8009e2:	09 fe                	or     %edi,%esi
  8009e4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ea:	74 0c                	je     8009f8 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ec:	83 ef 01             	sub    $0x1,%edi
  8009ef:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009f2:	fd                   	std    
  8009f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f5:	fc                   	cld    
  8009f6:	eb 21                	jmp    800a19 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f8:	f6 c1 03             	test   $0x3,%cl
  8009fb:	75 ef                	jne    8009ec <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009fd:	83 ef 04             	sub    $0x4,%edi
  800a00:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a03:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a06:	fd                   	std    
  800a07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a09:	eb ea                	jmp    8009f5 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0b:	89 f2                	mov    %esi,%edx
  800a0d:	09 c2                	or     %eax,%edx
  800a0f:	f6 c2 03             	test   $0x3,%dl
  800a12:	74 09                	je     800a1d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a14:	89 c7                	mov    %eax,%edi
  800a16:	fc                   	cld    
  800a17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a19:	5e                   	pop    %esi
  800a1a:	5f                   	pop    %edi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 f2                	jne    800a14 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a22:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a25:	89 c7                	mov    %eax,%edi
  800a27:	fc                   	cld    
  800a28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2a:	eb ed                	jmp    800a19 <memmove+0x55>

00800a2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a2f:	ff 75 10             	pushl  0x10(%ebp)
  800a32:	ff 75 0c             	pushl  0xc(%ebp)
  800a35:	ff 75 08             	pushl  0x8(%ebp)
  800a38:	e8 87 ff ff ff       	call   8009c4 <memmove>
}
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	56                   	push   %esi
  800a43:	53                   	push   %ebx
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4a:	89 c6                	mov    %eax,%esi
  800a4c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4f:	39 f0                	cmp    %esi,%eax
  800a51:	74 1c                	je     800a6f <memcmp+0x30>
		if (*s1 != *s2)
  800a53:	0f b6 08             	movzbl (%eax),%ecx
  800a56:	0f b6 1a             	movzbl (%edx),%ebx
  800a59:	38 d9                	cmp    %bl,%cl
  800a5b:	75 08                	jne    800a65 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a5d:	83 c0 01             	add    $0x1,%eax
  800a60:	83 c2 01             	add    $0x1,%edx
  800a63:	eb ea                	jmp    800a4f <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a65:	0f b6 c1             	movzbl %cl,%eax
  800a68:	0f b6 db             	movzbl %bl,%ebx
  800a6b:	29 d8                	sub    %ebx,%eax
  800a6d:	eb 05                	jmp    800a74 <memcmp+0x35>
	}

	return 0;
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a81:	89 c2                	mov    %eax,%edx
  800a83:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a86:	39 d0                	cmp    %edx,%eax
  800a88:	73 09                	jae    800a93 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8a:	38 08                	cmp    %cl,(%eax)
  800a8c:	74 05                	je     800a93 <memfind+0x1b>
	for (; s < ends; s++)
  800a8e:	83 c0 01             	add    $0x1,%eax
  800a91:	eb f3                	jmp    800a86 <memfind+0xe>
			break;
	return (void *) s;
}
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa1:	eb 03                	jmp    800aa6 <strtol+0x11>
		s++;
  800aa3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aa6:	0f b6 01             	movzbl (%ecx),%eax
  800aa9:	3c 20                	cmp    $0x20,%al
  800aab:	74 f6                	je     800aa3 <strtol+0xe>
  800aad:	3c 09                	cmp    $0x9,%al
  800aaf:	74 f2                	je     800aa3 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ab1:	3c 2b                	cmp    $0x2b,%al
  800ab3:	74 2e                	je     800ae3 <strtol+0x4e>
	int neg = 0;
  800ab5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aba:	3c 2d                	cmp    $0x2d,%al
  800abc:	74 2f                	je     800aed <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac4:	75 05                	jne    800acb <strtol+0x36>
  800ac6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac9:	74 2c                	je     800af7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acb:	85 db                	test   %ebx,%ebx
  800acd:	75 0a                	jne    800ad9 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800acf:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ad4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad7:	74 28                	je     800b01 <strtol+0x6c>
		base = 10;
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ae1:	eb 50                	jmp    800b33 <strtol+0x9e>
		s++;
  800ae3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ae6:	bf 00 00 00 00       	mov    $0x0,%edi
  800aeb:	eb d1                	jmp    800abe <strtol+0x29>
		s++, neg = 1;
  800aed:	83 c1 01             	add    $0x1,%ecx
  800af0:	bf 01 00 00 00       	mov    $0x1,%edi
  800af5:	eb c7                	jmp    800abe <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800afb:	74 0e                	je     800b0b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800afd:	85 db                	test   %ebx,%ebx
  800aff:	75 d8                	jne    800ad9 <strtol+0x44>
		s++, base = 8;
  800b01:	83 c1 01             	add    $0x1,%ecx
  800b04:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b09:	eb ce                	jmp    800ad9 <strtol+0x44>
		s += 2, base = 16;
  800b0b:	83 c1 02             	add    $0x2,%ecx
  800b0e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b13:	eb c4                	jmp    800ad9 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b15:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b18:	89 f3                	mov    %esi,%ebx
  800b1a:	80 fb 19             	cmp    $0x19,%bl
  800b1d:	77 29                	ja     800b48 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b1f:	0f be d2             	movsbl %dl,%edx
  800b22:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b25:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b28:	7d 30                	jge    800b5a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b2a:	83 c1 01             	add    $0x1,%ecx
  800b2d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b31:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b33:	0f b6 11             	movzbl (%ecx),%edx
  800b36:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b39:	89 f3                	mov    %esi,%ebx
  800b3b:	80 fb 09             	cmp    $0x9,%bl
  800b3e:	77 d5                	ja     800b15 <strtol+0x80>
			dig = *s - '0';
  800b40:	0f be d2             	movsbl %dl,%edx
  800b43:	83 ea 30             	sub    $0x30,%edx
  800b46:	eb dd                	jmp    800b25 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b48:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b4b:	89 f3                	mov    %esi,%ebx
  800b4d:	80 fb 19             	cmp    $0x19,%bl
  800b50:	77 08                	ja     800b5a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b52:	0f be d2             	movsbl %dl,%edx
  800b55:	83 ea 37             	sub    $0x37,%edx
  800b58:	eb cb                	jmp    800b25 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5e:	74 05                	je     800b65 <strtol+0xd0>
		*endptr = (char *) s;
  800b60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b63:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b65:	89 c2                	mov    %eax,%edx
  800b67:	f7 da                	neg    %edx
  800b69:	85 ff                	test   %edi,%edi
  800b6b:	0f 45 c2             	cmovne %edx,%eax
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	89 c3                	mov    %eax,%ebx
  800b86:	89 c7                	mov    %eax,%edi
  800b88:	89 c6                	mov    %eax,%esi
  800b8a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba1:	89 d1                	mov    %edx,%ecx
  800ba3:	89 d3                	mov    %edx,%ebx
  800ba5:	89 d7                	mov    %edx,%edi
  800ba7:	89 d6                	mov    %edx,%esi
  800ba9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc6:	89 cb                	mov    %ecx,%ebx
  800bc8:	89 cf                	mov    %ecx,%edi
  800bca:	89 ce                	mov    %ecx,%esi
  800bcc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7f 08                	jg     800bda <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 03                	push   $0x3
  800be0:	68 1f 22 80 00       	push   $0x80221f
  800be5:	6a 23                	push   $0x23
  800be7:	68 3c 22 80 00       	push   $0x80223c
  800bec:	e8 4b f5 ff ff       	call   80013c <_panic>

00800bf1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	b8 02 00 00 00       	mov    $0x2,%eax
  800c01:	89 d1                	mov    %edx,%ecx
  800c03:	89 d3                	mov    %edx,%ebx
  800c05:	89 d7                	mov    %edx,%edi
  800c07:	89 d6                	mov    %edx,%esi
  800c09:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_yield>:

void
sys_yield(void)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c16:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c20:	89 d1                	mov    %edx,%ecx
  800c22:	89 d3                	mov    %edx,%ebx
  800c24:	89 d7                	mov    %edx,%edi
  800c26:	89 d6                	mov    %edx,%esi
  800c28:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c38:	be 00 00 00 00       	mov    $0x0,%esi
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	b8 04 00 00 00       	mov    $0x4,%eax
  800c48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4b:	89 f7                	mov    %esi,%edi
  800c4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	7f 08                	jg     800c5b <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 04                	push   $0x4
  800c61:	68 1f 22 80 00       	push   $0x80221f
  800c66:	6a 23                	push   $0x23
  800c68:	68 3c 22 80 00       	push   $0x80223c
  800c6d:	e8 ca f4 ff ff       	call   80013c <_panic>

00800c72 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	b8 05 00 00 00       	mov    $0x5,%eax
  800c86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c8f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7f 08                	jg     800c9d <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 05                	push   $0x5
  800ca3:	68 1f 22 80 00       	push   $0x80221f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 3c 22 80 00       	push   $0x80223c
  800caf:	e8 88 f4 ff ff       	call   80013c <_panic>

00800cb4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	89 de                	mov    %ebx,%esi
  800cd1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7f 08                	jg     800cdf <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 06                	push   $0x6
  800ce5:	68 1f 22 80 00       	push   $0x80221f
  800cea:	6a 23                	push   $0x23
  800cec:	68 3c 22 80 00       	push   $0x80223c
  800cf1:	e8 46 f4 ff ff       	call   80013c <_panic>

00800cf6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0f:	89 df                	mov    %ebx,%edi
  800d11:	89 de                	mov    %ebx,%esi
  800d13:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d15:	85 c0                	test   %eax,%eax
  800d17:	7f 08                	jg     800d21 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 08                	push   $0x8
  800d27:	68 1f 22 80 00       	push   $0x80221f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 3c 22 80 00       	push   $0x80223c
  800d33:	e8 04 f4 ff ff       	call   80013c <_panic>

00800d38 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d51:	89 df                	mov    %ebx,%edi
  800d53:	89 de                	mov    %ebx,%esi
  800d55:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d57:	85 c0                	test   %eax,%eax
  800d59:	7f 08                	jg     800d63 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 09                	push   $0x9
  800d69:	68 1f 22 80 00       	push   $0x80221f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 3c 22 80 00       	push   $0x80223c
  800d75:	e8 c2 f3 ff ff       	call   80013c <_panic>

00800d7a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d93:	89 df                	mov    %ebx,%edi
  800d95:	89 de                	mov    %ebx,%esi
  800d97:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	7f 08                	jg     800da5 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 0a                	push   $0xa
  800dab:	68 1f 22 80 00       	push   $0x80221f
  800db0:	6a 23                	push   $0x23
  800db2:	68 3c 22 80 00       	push   $0x80223c
  800db7:	e8 80 f3 ff ff       	call   80013c <_panic>

00800dbc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dcd:	be 00 00 00 00       	mov    $0x0,%esi
  800dd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df5:	89 cb                	mov    %ecx,%ebx
  800df7:	89 cf                	mov    %ecx,%edi
  800df9:	89 ce                	mov    %ecx,%esi
  800dfb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	7f 08                	jg     800e09 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e09:	83 ec 0c             	sub    $0xc,%esp
  800e0c:	50                   	push   %eax
  800e0d:	6a 0d                	push   $0xd
  800e0f:	68 1f 22 80 00       	push   $0x80221f
  800e14:	6a 23                	push   $0x23
  800e16:	68 3c 22 80 00       	push   $0x80223c
  800e1b:	e8 1c f3 ff ff       	call   80013c <_panic>

00800e20 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
  800e26:	05 00 00 00 30       	add    $0x30000000,%eax
  800e2b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e40:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e52:	89 c2                	mov    %eax,%edx
  800e54:	c1 ea 16             	shr    $0x16,%edx
  800e57:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e5e:	f6 c2 01             	test   $0x1,%dl
  800e61:	74 2a                	je     800e8d <fd_alloc+0x46>
  800e63:	89 c2                	mov    %eax,%edx
  800e65:	c1 ea 0c             	shr    $0xc,%edx
  800e68:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e6f:	f6 c2 01             	test   $0x1,%dl
  800e72:	74 19                	je     800e8d <fd_alloc+0x46>
  800e74:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e79:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e7e:	75 d2                	jne    800e52 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e80:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e86:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e8b:	eb 07                	jmp    800e94 <fd_alloc+0x4d>
			*fd_store = fd;
  800e8d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e9c:	83 f8 1f             	cmp    $0x1f,%eax
  800e9f:	77 36                	ja     800ed7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ea1:	c1 e0 0c             	shl    $0xc,%eax
  800ea4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ea9:	89 c2                	mov    %eax,%edx
  800eab:	c1 ea 16             	shr    $0x16,%edx
  800eae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb5:	f6 c2 01             	test   $0x1,%dl
  800eb8:	74 24                	je     800ede <fd_lookup+0x48>
  800eba:	89 c2                	mov    %eax,%edx
  800ebc:	c1 ea 0c             	shr    $0xc,%edx
  800ebf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec6:	f6 c2 01             	test   $0x1,%dl
  800ec9:	74 1a                	je     800ee5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ece:	89 02                	mov    %eax,(%edx)
	return 0;
  800ed0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    
		return -E_INVAL;
  800ed7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800edc:	eb f7                	jmp    800ed5 <fd_lookup+0x3f>
		return -E_INVAL;
  800ede:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee3:	eb f0                	jmp    800ed5 <fd_lookup+0x3f>
  800ee5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eea:	eb e9                	jmp    800ed5 <fd_lookup+0x3f>

00800eec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 08             	sub    $0x8,%esp
  800ef2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef5:	ba cc 22 80 00       	mov    $0x8022cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800efa:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800eff:	39 08                	cmp    %ecx,(%eax)
  800f01:	74 33                	je     800f36 <dev_lookup+0x4a>
  800f03:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f06:	8b 02                	mov    (%edx),%eax
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	75 f3                	jne    800eff <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f0c:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f11:	8b 40 48             	mov    0x48(%eax),%eax
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	51                   	push   %ecx
  800f18:	50                   	push   %eax
  800f19:	68 4c 22 80 00       	push   $0x80224c
  800f1e:	e8 f4 f2 ff ff       	call   800217 <cprintf>
	*dev = 0;
  800f23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    
			*dev = devtab[i];
  800f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f39:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f40:	eb f2                	jmp    800f34 <dev_lookup+0x48>

00800f42 <fd_close>:
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	57                   	push   %edi
  800f46:	56                   	push   %esi
  800f47:	53                   	push   %ebx
  800f48:	83 ec 1c             	sub    $0x1c,%esp
  800f4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f4e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f51:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f54:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f55:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f5b:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5e:	50                   	push   %eax
  800f5f:	e8 32 ff ff ff       	call   800e96 <fd_lookup>
  800f64:	89 c3                	mov    %eax,%ebx
  800f66:	83 c4 08             	add    $0x8,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	78 05                	js     800f72 <fd_close+0x30>
	    || fd != fd2)
  800f6d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f70:	74 16                	je     800f88 <fd_close+0x46>
		return (must_exist ? r : 0);
  800f72:	89 f8                	mov    %edi,%eax
  800f74:	84 c0                	test   %al,%al
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7b:	0f 44 d8             	cmove  %eax,%ebx
}
  800f7e:	89 d8                	mov    %ebx,%eax
  800f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f88:	83 ec 08             	sub    $0x8,%esp
  800f8b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f8e:	50                   	push   %eax
  800f8f:	ff 36                	pushl  (%esi)
  800f91:	e8 56 ff ff ff       	call   800eec <dev_lookup>
  800f96:	89 c3                	mov    %eax,%ebx
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 15                	js     800fb4 <fd_close+0x72>
		if (dev->dev_close)
  800f9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fa2:	8b 40 10             	mov    0x10(%eax),%eax
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	74 1b                	je     800fc4 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	56                   	push   %esi
  800fad:	ff d0                	call   *%eax
  800faf:	89 c3                	mov    %eax,%ebx
  800fb1:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fb4:	83 ec 08             	sub    $0x8,%esp
  800fb7:	56                   	push   %esi
  800fb8:	6a 00                	push   $0x0
  800fba:	e8 f5 fc ff ff       	call   800cb4 <sys_page_unmap>
	return r;
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	eb ba                	jmp    800f7e <fd_close+0x3c>
			r = 0;
  800fc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc9:	eb e9                	jmp    800fb4 <fd_close+0x72>

00800fcb <close>:

int
close(int fdnum)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd4:	50                   	push   %eax
  800fd5:	ff 75 08             	pushl  0x8(%ebp)
  800fd8:	e8 b9 fe ff ff       	call   800e96 <fd_lookup>
  800fdd:	83 c4 08             	add    $0x8,%esp
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	78 10                	js     800ff4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fe4:	83 ec 08             	sub    $0x8,%esp
  800fe7:	6a 01                	push   $0x1
  800fe9:	ff 75 f4             	pushl  -0xc(%ebp)
  800fec:	e8 51 ff ff ff       	call   800f42 <fd_close>
  800ff1:	83 c4 10             	add    $0x10,%esp
}
  800ff4:	c9                   	leave  
  800ff5:	c3                   	ret    

00800ff6 <close_all>:

void
close_all(void)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	53                   	push   %ebx
  800ffa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ffd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801002:	83 ec 0c             	sub    $0xc,%esp
  801005:	53                   	push   %ebx
  801006:	e8 c0 ff ff ff       	call   800fcb <close>
	for (i = 0; i < MAXFD; i++)
  80100b:	83 c3 01             	add    $0x1,%ebx
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	83 fb 20             	cmp    $0x20,%ebx
  801014:	75 ec                	jne    801002 <close_all+0xc>
}
  801016:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801019:	c9                   	leave  
  80101a:	c3                   	ret    

0080101b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801024:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801027:	50                   	push   %eax
  801028:	ff 75 08             	pushl  0x8(%ebp)
  80102b:	e8 66 fe ff ff       	call   800e96 <fd_lookup>
  801030:	89 c3                	mov    %eax,%ebx
  801032:	83 c4 08             	add    $0x8,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	0f 88 81 00 00 00    	js     8010be <dup+0xa3>
		return r;
	close(newfdnum);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	ff 75 0c             	pushl  0xc(%ebp)
  801043:	e8 83 ff ff ff       	call   800fcb <close>

	newfd = INDEX2FD(newfdnum);
  801048:	8b 75 0c             	mov    0xc(%ebp),%esi
  80104b:	c1 e6 0c             	shl    $0xc,%esi
  80104e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801054:	83 c4 04             	add    $0x4,%esp
  801057:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105a:	e8 d1 fd ff ff       	call   800e30 <fd2data>
  80105f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801061:	89 34 24             	mov    %esi,(%esp)
  801064:	e8 c7 fd ff ff       	call   800e30 <fd2data>
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80106e:	89 d8                	mov    %ebx,%eax
  801070:	c1 e8 16             	shr    $0x16,%eax
  801073:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107a:	a8 01                	test   $0x1,%al
  80107c:	74 11                	je     80108f <dup+0x74>
  80107e:	89 d8                	mov    %ebx,%eax
  801080:	c1 e8 0c             	shr    $0xc,%eax
  801083:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108a:	f6 c2 01             	test   $0x1,%dl
  80108d:	75 39                	jne    8010c8 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80108f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801092:	89 d0                	mov    %edx,%eax
  801094:	c1 e8 0c             	shr    $0xc,%eax
  801097:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109e:	83 ec 0c             	sub    $0xc,%esp
  8010a1:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a6:	50                   	push   %eax
  8010a7:	56                   	push   %esi
  8010a8:	6a 00                	push   $0x0
  8010aa:	52                   	push   %edx
  8010ab:	6a 00                	push   $0x0
  8010ad:	e8 c0 fb ff ff       	call   800c72 <sys_page_map>
  8010b2:	89 c3                	mov    %eax,%ebx
  8010b4:	83 c4 20             	add    $0x20,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 31                	js     8010ec <dup+0xd1>
		goto err;

	return newfdnum;
  8010bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010be:	89 d8                	mov    %ebx,%eax
  8010c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c3:	5b                   	pop    %ebx
  8010c4:	5e                   	pop    %esi
  8010c5:	5f                   	pop    %edi
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d7:	50                   	push   %eax
  8010d8:	57                   	push   %edi
  8010d9:	6a 00                	push   $0x0
  8010db:	53                   	push   %ebx
  8010dc:	6a 00                	push   $0x0
  8010de:	e8 8f fb ff ff       	call   800c72 <sys_page_map>
  8010e3:	89 c3                	mov    %eax,%ebx
  8010e5:	83 c4 20             	add    $0x20,%esp
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	79 a3                	jns    80108f <dup+0x74>
	sys_page_unmap(0, newfd);
  8010ec:	83 ec 08             	sub    $0x8,%esp
  8010ef:	56                   	push   %esi
  8010f0:	6a 00                	push   $0x0
  8010f2:	e8 bd fb ff ff       	call   800cb4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f7:	83 c4 08             	add    $0x8,%esp
  8010fa:	57                   	push   %edi
  8010fb:	6a 00                	push   $0x0
  8010fd:	e8 b2 fb ff ff       	call   800cb4 <sys_page_unmap>
	return r;
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	eb b7                	jmp    8010be <dup+0xa3>

00801107 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	53                   	push   %ebx
  80110b:	83 ec 14             	sub    $0x14,%esp
  80110e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801111:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801114:	50                   	push   %eax
  801115:	53                   	push   %ebx
  801116:	e8 7b fd ff ff       	call   800e96 <fd_lookup>
  80111b:	83 c4 08             	add    $0x8,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 3f                	js     801161 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801122:	83 ec 08             	sub    $0x8,%esp
  801125:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801128:	50                   	push   %eax
  801129:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112c:	ff 30                	pushl  (%eax)
  80112e:	e8 b9 fd ff ff       	call   800eec <dev_lookup>
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	85 c0                	test   %eax,%eax
  801138:	78 27                	js     801161 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80113a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80113d:	8b 42 08             	mov    0x8(%edx),%eax
  801140:	83 e0 03             	and    $0x3,%eax
  801143:	83 f8 01             	cmp    $0x1,%eax
  801146:	74 1e                	je     801166 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801148:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114b:	8b 40 08             	mov    0x8(%eax),%eax
  80114e:	85 c0                	test   %eax,%eax
  801150:	74 35                	je     801187 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801152:	83 ec 04             	sub    $0x4,%esp
  801155:	ff 75 10             	pushl  0x10(%ebp)
  801158:	ff 75 0c             	pushl  0xc(%ebp)
  80115b:	52                   	push   %edx
  80115c:	ff d0                	call   *%eax
  80115e:	83 c4 10             	add    $0x10,%esp
}
  801161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801164:	c9                   	leave  
  801165:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801166:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80116b:	8b 40 48             	mov    0x48(%eax),%eax
  80116e:	83 ec 04             	sub    $0x4,%esp
  801171:	53                   	push   %ebx
  801172:	50                   	push   %eax
  801173:	68 90 22 80 00       	push   $0x802290
  801178:	e8 9a f0 ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801185:	eb da                	jmp    801161 <read+0x5a>
		return -E_NOT_SUPP;
  801187:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80118c:	eb d3                	jmp    801161 <read+0x5a>

0080118e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	57                   	push   %edi
  801192:	56                   	push   %esi
  801193:	53                   	push   %ebx
  801194:	83 ec 0c             	sub    $0xc,%esp
  801197:	8b 7d 08             	mov    0x8(%ebp),%edi
  80119a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80119d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a2:	39 f3                	cmp    %esi,%ebx
  8011a4:	73 25                	jae    8011cb <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011a6:	83 ec 04             	sub    $0x4,%esp
  8011a9:	89 f0                	mov    %esi,%eax
  8011ab:	29 d8                	sub    %ebx,%eax
  8011ad:	50                   	push   %eax
  8011ae:	89 d8                	mov    %ebx,%eax
  8011b0:	03 45 0c             	add    0xc(%ebp),%eax
  8011b3:	50                   	push   %eax
  8011b4:	57                   	push   %edi
  8011b5:	e8 4d ff ff ff       	call   801107 <read>
		if (m < 0)
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 08                	js     8011c9 <readn+0x3b>
			return m;
		if (m == 0)
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	74 06                	je     8011cb <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8011c5:	01 c3                	add    %eax,%ebx
  8011c7:	eb d9                	jmp    8011a2 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011c9:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011cb:	89 d8                	mov    %ebx,%eax
  8011cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d0:	5b                   	pop    %ebx
  8011d1:	5e                   	pop    %esi
  8011d2:	5f                   	pop    %edi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 14             	sub    $0x14,%esp
  8011dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e2:	50                   	push   %eax
  8011e3:	53                   	push   %ebx
  8011e4:	e8 ad fc ff ff       	call   800e96 <fd_lookup>
  8011e9:	83 c4 08             	add    $0x8,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	78 3a                	js     80122a <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f0:	83 ec 08             	sub    $0x8,%esp
  8011f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fa:	ff 30                	pushl  (%eax)
  8011fc:	e8 eb fc ff ff       	call   800eec <dev_lookup>
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	78 22                	js     80122a <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801208:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80120f:	74 1e                	je     80122f <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801211:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801214:	8b 52 0c             	mov    0xc(%edx),%edx
  801217:	85 d2                	test   %edx,%edx
  801219:	74 35                	je     801250 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80121b:	83 ec 04             	sub    $0x4,%esp
  80121e:	ff 75 10             	pushl  0x10(%ebp)
  801221:	ff 75 0c             	pushl  0xc(%ebp)
  801224:	50                   	push   %eax
  801225:	ff d2                	call   *%edx
  801227:	83 c4 10             	add    $0x10,%esp
}
  80122a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122d:	c9                   	leave  
  80122e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80122f:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801234:	8b 40 48             	mov    0x48(%eax),%eax
  801237:	83 ec 04             	sub    $0x4,%esp
  80123a:	53                   	push   %ebx
  80123b:	50                   	push   %eax
  80123c:	68 ac 22 80 00       	push   $0x8022ac
  801241:	e8 d1 ef ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124e:	eb da                	jmp    80122a <write+0x55>
		return -E_NOT_SUPP;
  801250:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801255:	eb d3                	jmp    80122a <write+0x55>

00801257 <seek>:

int
seek(int fdnum, off_t offset)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801260:	50                   	push   %eax
  801261:	ff 75 08             	pushl  0x8(%ebp)
  801264:	e8 2d fc ff ff       	call   800e96 <fd_lookup>
  801269:	83 c4 08             	add    $0x8,%esp
  80126c:	85 c0                	test   %eax,%eax
  80126e:	78 0e                	js     80127e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801270:	8b 55 0c             	mov    0xc(%ebp),%edx
  801273:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801276:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80127e:	c9                   	leave  
  80127f:	c3                   	ret    

00801280 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	53                   	push   %ebx
  801284:	83 ec 14             	sub    $0x14,%esp
  801287:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	53                   	push   %ebx
  80128f:	e8 02 fc ff ff       	call   800e96 <fd_lookup>
  801294:	83 c4 08             	add    $0x8,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 37                	js     8012d2 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a5:	ff 30                	pushl  (%eax)
  8012a7:	e8 40 fc ff ff       	call   800eec <dev_lookup>
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	78 1f                	js     8012d2 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ba:	74 1b                	je     8012d7 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bf:	8b 52 18             	mov    0x18(%edx),%edx
  8012c2:	85 d2                	test   %edx,%edx
  8012c4:	74 32                	je     8012f8 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012c6:	83 ec 08             	sub    $0x8,%esp
  8012c9:	ff 75 0c             	pushl  0xc(%ebp)
  8012cc:	50                   	push   %eax
  8012cd:	ff d2                	call   *%edx
  8012cf:	83 c4 10             	add    $0x10,%esp
}
  8012d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d5:	c9                   	leave  
  8012d6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012d7:	a1 20 40 c0 00       	mov    0xc04020,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012dc:	8b 40 48             	mov    0x48(%eax),%eax
  8012df:	83 ec 04             	sub    $0x4,%esp
  8012e2:	53                   	push   %ebx
  8012e3:	50                   	push   %eax
  8012e4:	68 6c 22 80 00       	push   $0x80226c
  8012e9:	e8 29 ef ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f6:	eb da                	jmp    8012d2 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8012f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012fd:	eb d3                	jmp    8012d2 <ftruncate+0x52>

008012ff <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	53                   	push   %ebx
  801303:	83 ec 14             	sub    $0x14,%esp
  801306:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801309:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	ff 75 08             	pushl  0x8(%ebp)
  801310:	e8 81 fb ff ff       	call   800e96 <fd_lookup>
  801315:	83 c4 08             	add    $0x8,%esp
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 4b                	js     801367 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801322:	50                   	push   %eax
  801323:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801326:	ff 30                	pushl  (%eax)
  801328:	e8 bf fb ff ff       	call   800eec <dev_lookup>
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 33                	js     801367 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801334:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801337:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80133b:	74 2f                	je     80136c <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80133d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801340:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801347:	00 00 00 
	stat->st_isdir = 0;
  80134a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801351:	00 00 00 
	stat->st_dev = dev;
  801354:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	53                   	push   %ebx
  80135e:	ff 75 f0             	pushl  -0x10(%ebp)
  801361:	ff 50 14             	call   *0x14(%eax)
  801364:	83 c4 10             	add    $0x10,%esp
}
  801367:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136a:	c9                   	leave  
  80136b:	c3                   	ret    
		return -E_NOT_SUPP;
  80136c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801371:	eb f4                	jmp    801367 <fstat+0x68>

00801373 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	56                   	push   %esi
  801377:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	6a 00                	push   $0x0
  80137d:	ff 75 08             	pushl  0x8(%ebp)
  801380:	e8 da 01 00 00       	call   80155f <open>
  801385:	89 c3                	mov    %eax,%ebx
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	85 c0                	test   %eax,%eax
  80138c:	78 1b                	js     8013a9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80138e:	83 ec 08             	sub    $0x8,%esp
  801391:	ff 75 0c             	pushl  0xc(%ebp)
  801394:	50                   	push   %eax
  801395:	e8 65 ff ff ff       	call   8012ff <fstat>
  80139a:	89 c6                	mov    %eax,%esi
	close(fd);
  80139c:	89 1c 24             	mov    %ebx,(%esp)
  80139f:	e8 27 fc ff ff       	call   800fcb <close>
	return r;
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	89 f3                	mov    %esi,%ebx
}
  8013a9:	89 d8                	mov    %ebx,%eax
  8013ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ae:	5b                   	pop    %ebx
  8013af:	5e                   	pop    %esi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	56                   	push   %esi
  8013b6:	53                   	push   %ebx
  8013b7:	89 c6                	mov    %eax,%esi
  8013b9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013bb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c2:	74 27                	je     8013eb <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013c4:	6a 07                	push   $0x7
  8013c6:	68 00 50 c0 00       	push   $0xc05000
  8013cb:	56                   	push   %esi
  8013cc:	ff 35 00 40 80 00    	pushl  0x804000
  8013d2:	e8 5e 07 00 00       	call   801b35 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013d7:	83 c4 0c             	add    $0xc,%esp
  8013da:	6a 00                	push   $0x0
  8013dc:	53                   	push   %ebx
  8013dd:	6a 00                	push   $0x0
  8013df:	e8 ea 06 00 00       	call   801ace <ipc_recv>
}
  8013e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	6a 01                	push   $0x1
  8013f0:	e8 94 07 00 00       	call   801b89 <ipc_find_env>
  8013f5:	a3 00 40 80 00       	mov    %eax,0x804000
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	eb c5                	jmp    8013c4 <fsipc+0x12>

008013ff <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801405:	8b 45 08             	mov    0x8(%ebp),%eax
  801408:	8b 40 0c             	mov    0xc(%eax),%eax
  80140b:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  801410:	8b 45 0c             	mov    0xc(%ebp),%eax
  801413:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801418:	ba 00 00 00 00       	mov    $0x0,%edx
  80141d:	b8 02 00 00 00       	mov    $0x2,%eax
  801422:	e8 8b ff ff ff       	call   8013b2 <fsipc>
}
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <devfile_flush>:
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
  801432:	8b 40 0c             	mov    0xc(%eax),%eax
  801435:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  80143a:	ba 00 00 00 00       	mov    $0x0,%edx
  80143f:	b8 06 00 00 00       	mov    $0x6,%eax
  801444:	e8 69 ff ff ff       	call   8013b2 <fsipc>
}
  801449:	c9                   	leave  
  80144a:	c3                   	ret    

0080144b <devfile_stat>:
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	53                   	push   %ebx
  80144f:	83 ec 04             	sub    $0x4,%esp
  801452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801455:	8b 45 08             	mov    0x8(%ebp),%eax
  801458:	8b 40 0c             	mov    0xc(%eax),%eax
  80145b:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801460:	ba 00 00 00 00       	mov    $0x0,%edx
  801465:	b8 05 00 00 00       	mov    $0x5,%eax
  80146a:	e8 43 ff ff ff       	call   8013b2 <fsipc>
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 2c                	js     80149f <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	68 00 50 c0 00       	push   $0xc05000
  80147b:	53                   	push   %ebx
  80147c:	e8 b5 f3 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801481:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801486:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80148c:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801491:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <devfile_write>:
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	83 ec 0c             	sub    $0xc,%esp
  8014aa:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b3:	89 15 00 50 c0 00    	mov    %edx,0xc05000
    	fsipcbuf.write.req_n = n;
  8014b9:	a3 04 50 c0 00       	mov    %eax,0xc05004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8014be:	50                   	push   %eax
  8014bf:	ff 75 0c             	pushl  0xc(%ebp)
  8014c2:	68 08 50 c0 00       	push   $0xc05008
  8014c7:	e8 f8 f4 ff ff       	call   8009c4 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  8014cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d1:	b8 04 00 00 00       	mov    $0x4,%eax
  8014d6:	e8 d7 fe ff ff       	call   8013b2 <fsipc>
}
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <devfile_read>:
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	56                   	push   %esi
  8014e1:	53                   	push   %ebx
  8014e2:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014eb:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8014f0:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fb:	b8 03 00 00 00       	mov    $0x3,%eax
  801500:	e8 ad fe ff ff       	call   8013b2 <fsipc>
  801505:	89 c3                	mov    %eax,%ebx
  801507:	85 c0                	test   %eax,%eax
  801509:	78 1f                	js     80152a <devfile_read+0x4d>
	assert(r <= n);
  80150b:	39 f0                	cmp    %esi,%eax
  80150d:	77 24                	ja     801533 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80150f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801514:	7f 33                	jg     801549 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801516:	83 ec 04             	sub    $0x4,%esp
  801519:	50                   	push   %eax
  80151a:	68 00 50 c0 00       	push   $0xc05000
  80151f:	ff 75 0c             	pushl  0xc(%ebp)
  801522:	e8 9d f4 ff ff       	call   8009c4 <memmove>
	return r;
  801527:	83 c4 10             	add    $0x10,%esp
}
  80152a:	89 d8                	mov    %ebx,%eax
  80152c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152f:	5b                   	pop    %ebx
  801530:	5e                   	pop    %esi
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    
	assert(r <= n);
  801533:	68 dc 22 80 00       	push   $0x8022dc
  801538:	68 e3 22 80 00       	push   $0x8022e3
  80153d:	6a 7c                	push   $0x7c
  80153f:	68 f8 22 80 00       	push   $0x8022f8
  801544:	e8 f3 eb ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  801549:	68 03 23 80 00       	push   $0x802303
  80154e:	68 e3 22 80 00       	push   $0x8022e3
  801553:	6a 7d                	push   $0x7d
  801555:	68 f8 22 80 00       	push   $0x8022f8
  80155a:	e8 dd eb ff ff       	call   80013c <_panic>

0080155f <open>:
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	56                   	push   %esi
  801563:	53                   	push   %ebx
  801564:	83 ec 1c             	sub    $0x1c,%esp
  801567:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80156a:	56                   	push   %esi
  80156b:	e8 8f f2 ff ff       	call   8007ff <strlen>
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801578:	7f 6c                	jg     8015e6 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80157a:	83 ec 0c             	sub    $0xc,%esp
  80157d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	e8 c1 f8 ff ff       	call   800e47 <fd_alloc>
  801586:	89 c3                	mov    %eax,%ebx
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 3c                	js     8015cb <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	56                   	push   %esi
  801593:	68 00 50 c0 00       	push   $0xc05000
  801598:	e8 99 f2 ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80159d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a0:	a3 00 54 c0 00       	mov    %eax,0xc05400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ad:	e8 00 fe ff ff       	call   8013b2 <fsipc>
  8015b2:	89 c3                	mov    %eax,%ebx
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 19                	js     8015d4 <open+0x75>
	return fd2num(fd);
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c1:	e8 5a f8 ff ff       	call   800e20 <fd2num>
  8015c6:	89 c3                	mov    %eax,%ebx
  8015c8:	83 c4 10             	add    $0x10,%esp
}
  8015cb:	89 d8                	mov    %ebx,%eax
  8015cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d0:	5b                   	pop    %ebx
  8015d1:	5e                   	pop    %esi
  8015d2:	5d                   	pop    %ebp
  8015d3:	c3                   	ret    
		fd_close(fd, 0);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	6a 00                	push   $0x0
  8015d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8015dc:	e8 61 f9 ff ff       	call   800f42 <fd_close>
		return r;
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	eb e5                	jmp    8015cb <open+0x6c>
		return -E_BAD_PATH;
  8015e6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015eb:	eb de                	jmp    8015cb <open+0x6c>

008015ed <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8015fd:	e8 b0 fd ff ff       	call   8013b2 <fsipc>
}
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	56                   	push   %esi
  801608:	53                   	push   %ebx
  801609:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80160c:	83 ec 0c             	sub    $0xc,%esp
  80160f:	ff 75 08             	pushl  0x8(%ebp)
  801612:	e8 19 f8 ff ff       	call   800e30 <fd2data>
  801617:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801619:	83 c4 08             	add    $0x8,%esp
  80161c:	68 0f 23 80 00       	push   $0x80230f
  801621:	53                   	push   %ebx
  801622:	e8 0f f2 ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801627:	8b 46 04             	mov    0x4(%esi),%eax
  80162a:	2b 06                	sub    (%esi),%eax
  80162c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801632:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801639:	00 00 00 
	stat->st_dev = &devpipe;
  80163c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801643:	30 80 00 
	return 0;
}
  801646:	b8 00 00 00 00       	mov    $0x0,%eax
  80164b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164e:	5b                   	pop    %ebx
  80164f:	5e                   	pop    %esi
  801650:	5d                   	pop    %ebp
  801651:	c3                   	ret    

00801652 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	53                   	push   %ebx
  801656:	83 ec 0c             	sub    $0xc,%esp
  801659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80165c:	53                   	push   %ebx
  80165d:	6a 00                	push   $0x0
  80165f:	e8 50 f6 ff ff       	call   800cb4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801664:	89 1c 24             	mov    %ebx,(%esp)
  801667:	e8 c4 f7 ff ff       	call   800e30 <fd2data>
  80166c:	83 c4 08             	add    $0x8,%esp
  80166f:	50                   	push   %eax
  801670:	6a 00                	push   $0x0
  801672:	e8 3d f6 ff ff       	call   800cb4 <sys_page_unmap>
}
  801677:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <_pipeisclosed>:
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	57                   	push   %edi
  801680:	56                   	push   %esi
  801681:	53                   	push   %ebx
  801682:	83 ec 1c             	sub    $0x1c,%esp
  801685:	89 c7                	mov    %eax,%edi
  801687:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801689:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80168e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801691:	83 ec 0c             	sub    $0xc,%esp
  801694:	57                   	push   %edi
  801695:	e8 28 05 00 00       	call   801bc2 <pageref>
  80169a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80169d:	89 34 24             	mov    %esi,(%esp)
  8016a0:	e8 1d 05 00 00       	call   801bc2 <pageref>
		nn = thisenv->env_runs;
  8016a5:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  8016ab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	39 cb                	cmp    %ecx,%ebx
  8016b3:	74 1b                	je     8016d0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8016b5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016b8:	75 cf                	jne    801689 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016ba:	8b 42 58             	mov    0x58(%edx),%eax
  8016bd:	6a 01                	push   $0x1
  8016bf:	50                   	push   %eax
  8016c0:	53                   	push   %ebx
  8016c1:	68 16 23 80 00       	push   $0x802316
  8016c6:	e8 4c eb ff ff       	call   800217 <cprintf>
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	eb b9                	jmp    801689 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8016d0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016d3:	0f 94 c0             	sete   %al
  8016d6:	0f b6 c0             	movzbl %al,%eax
}
  8016d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016dc:	5b                   	pop    %ebx
  8016dd:	5e                   	pop    %esi
  8016de:	5f                   	pop    %edi
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <devpipe_write>:
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	57                   	push   %edi
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 28             	sub    $0x28,%esp
  8016ea:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8016ed:	56                   	push   %esi
  8016ee:	e8 3d f7 ff ff       	call   800e30 <fd2data>
  8016f3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	bf 00 00 00 00       	mov    $0x0,%edi
  8016fd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801700:	74 4f                	je     801751 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801702:	8b 43 04             	mov    0x4(%ebx),%eax
  801705:	8b 0b                	mov    (%ebx),%ecx
  801707:	8d 51 20             	lea    0x20(%ecx),%edx
  80170a:	39 d0                	cmp    %edx,%eax
  80170c:	72 14                	jb     801722 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  80170e:	89 da                	mov    %ebx,%edx
  801710:	89 f0                	mov    %esi,%eax
  801712:	e8 65 ff ff ff       	call   80167c <_pipeisclosed>
  801717:	85 c0                	test   %eax,%eax
  801719:	75 3a                	jne    801755 <devpipe_write+0x74>
			sys_yield();
  80171b:	e8 f0 f4 ff ff       	call   800c10 <sys_yield>
  801720:	eb e0                	jmp    801702 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801722:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801725:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801729:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80172c:	89 c2                	mov    %eax,%edx
  80172e:	c1 fa 1f             	sar    $0x1f,%edx
  801731:	89 d1                	mov    %edx,%ecx
  801733:	c1 e9 1b             	shr    $0x1b,%ecx
  801736:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801739:	83 e2 1f             	and    $0x1f,%edx
  80173c:	29 ca                	sub    %ecx,%edx
  80173e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801742:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801746:	83 c0 01             	add    $0x1,%eax
  801749:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80174c:	83 c7 01             	add    $0x1,%edi
  80174f:	eb ac                	jmp    8016fd <devpipe_write+0x1c>
	return i;
  801751:	89 f8                	mov    %edi,%eax
  801753:	eb 05                	jmp    80175a <devpipe_write+0x79>
				return 0;
  801755:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80175a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5f                   	pop    %edi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <devpipe_read>:
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	57                   	push   %edi
  801766:	56                   	push   %esi
  801767:	53                   	push   %ebx
  801768:	83 ec 18             	sub    $0x18,%esp
  80176b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80176e:	57                   	push   %edi
  80176f:	e8 bc f6 ff ff       	call   800e30 <fd2data>
  801774:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	be 00 00 00 00       	mov    $0x0,%esi
  80177e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801781:	74 47                	je     8017ca <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801783:	8b 03                	mov    (%ebx),%eax
  801785:	3b 43 04             	cmp    0x4(%ebx),%eax
  801788:	75 22                	jne    8017ac <devpipe_read+0x4a>
			if (i > 0)
  80178a:	85 f6                	test   %esi,%esi
  80178c:	75 14                	jne    8017a2 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  80178e:	89 da                	mov    %ebx,%edx
  801790:	89 f8                	mov    %edi,%eax
  801792:	e8 e5 fe ff ff       	call   80167c <_pipeisclosed>
  801797:	85 c0                	test   %eax,%eax
  801799:	75 33                	jne    8017ce <devpipe_read+0x6c>
			sys_yield();
  80179b:	e8 70 f4 ff ff       	call   800c10 <sys_yield>
  8017a0:	eb e1                	jmp    801783 <devpipe_read+0x21>
				return i;
  8017a2:	89 f0                	mov    %esi,%eax
}
  8017a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a7:	5b                   	pop    %ebx
  8017a8:	5e                   	pop    %esi
  8017a9:	5f                   	pop    %edi
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017ac:	99                   	cltd   
  8017ad:	c1 ea 1b             	shr    $0x1b,%edx
  8017b0:	01 d0                	add    %edx,%eax
  8017b2:	83 e0 1f             	and    $0x1f,%eax
  8017b5:	29 d0                	sub    %edx,%eax
  8017b7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017bf:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017c2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8017c5:	83 c6 01             	add    $0x1,%esi
  8017c8:	eb b4                	jmp    80177e <devpipe_read+0x1c>
	return i;
  8017ca:	89 f0                	mov    %esi,%eax
  8017cc:	eb d6                	jmp    8017a4 <devpipe_read+0x42>
				return 0;
  8017ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d3:	eb cf                	jmp    8017a4 <devpipe_read+0x42>

008017d5 <pipe>:
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	56                   	push   %esi
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8017dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e0:	50                   	push   %eax
  8017e1:	e8 61 f6 ff ff       	call   800e47 <fd_alloc>
  8017e6:	89 c3                	mov    %eax,%ebx
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 5b                	js     80184a <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ef:	83 ec 04             	sub    $0x4,%esp
  8017f2:	68 07 04 00 00       	push   $0x407
  8017f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fa:	6a 00                	push   $0x0
  8017fc:	e8 2e f4 ff ff       	call   800c2f <sys_page_alloc>
  801801:	89 c3                	mov    %eax,%ebx
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	85 c0                	test   %eax,%eax
  801808:	78 40                	js     80184a <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  80180a:	83 ec 0c             	sub    $0xc,%esp
  80180d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801810:	50                   	push   %eax
  801811:	e8 31 f6 ff ff       	call   800e47 <fd_alloc>
  801816:	89 c3                	mov    %eax,%ebx
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 1b                	js     80183a <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80181f:	83 ec 04             	sub    $0x4,%esp
  801822:	68 07 04 00 00       	push   $0x407
  801827:	ff 75 f0             	pushl  -0x10(%ebp)
  80182a:	6a 00                	push   $0x0
  80182c:	e8 fe f3 ff ff       	call   800c2f <sys_page_alloc>
  801831:	89 c3                	mov    %eax,%ebx
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	85 c0                	test   %eax,%eax
  801838:	79 19                	jns    801853 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  80183a:	83 ec 08             	sub    $0x8,%esp
  80183d:	ff 75 f4             	pushl  -0xc(%ebp)
  801840:	6a 00                	push   $0x0
  801842:	e8 6d f4 ff ff       	call   800cb4 <sys_page_unmap>
  801847:	83 c4 10             	add    $0x10,%esp
}
  80184a:	89 d8                	mov    %ebx,%eax
  80184c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184f:	5b                   	pop    %ebx
  801850:	5e                   	pop    %esi
  801851:	5d                   	pop    %ebp
  801852:	c3                   	ret    
	va = fd2data(fd0);
  801853:	83 ec 0c             	sub    $0xc,%esp
  801856:	ff 75 f4             	pushl  -0xc(%ebp)
  801859:	e8 d2 f5 ff ff       	call   800e30 <fd2data>
  80185e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801860:	83 c4 0c             	add    $0xc,%esp
  801863:	68 07 04 00 00       	push   $0x407
  801868:	50                   	push   %eax
  801869:	6a 00                	push   $0x0
  80186b:	e8 bf f3 ff ff       	call   800c2f <sys_page_alloc>
  801870:	89 c3                	mov    %eax,%ebx
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	85 c0                	test   %eax,%eax
  801877:	0f 88 8c 00 00 00    	js     801909 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	ff 75 f0             	pushl  -0x10(%ebp)
  801883:	e8 a8 f5 ff ff       	call   800e30 <fd2data>
  801888:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80188f:	50                   	push   %eax
  801890:	6a 00                	push   $0x0
  801892:	56                   	push   %esi
  801893:	6a 00                	push   $0x0
  801895:	e8 d8 f3 ff ff       	call   800c72 <sys_page_map>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	83 c4 20             	add    $0x20,%esp
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	78 58                	js     8018fb <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  8018a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ac:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8018b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018c1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8018cd:	83 ec 0c             	sub    $0xc,%esp
  8018d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d3:	e8 48 f5 ff ff       	call   800e20 <fd2num>
  8018d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018db:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018dd:	83 c4 04             	add    $0x4,%esp
  8018e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e3:	e8 38 f5 ff ff       	call   800e20 <fd2num>
  8018e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018eb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018f6:	e9 4f ff ff ff       	jmp    80184a <pipe+0x75>
	sys_page_unmap(0, va);
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	56                   	push   %esi
  8018ff:	6a 00                	push   $0x0
  801901:	e8 ae f3 ff ff       	call   800cb4 <sys_page_unmap>
  801906:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	ff 75 f0             	pushl  -0x10(%ebp)
  80190f:	6a 00                	push   $0x0
  801911:	e8 9e f3 ff ff       	call   800cb4 <sys_page_unmap>
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	e9 1c ff ff ff       	jmp    80183a <pipe+0x65>

0080191e <pipeisclosed>:
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801924:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801927:	50                   	push   %eax
  801928:	ff 75 08             	pushl  0x8(%ebp)
  80192b:	e8 66 f5 ff ff       	call   800e96 <fd_lookup>
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	85 c0                	test   %eax,%eax
  801935:	78 18                	js     80194f <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	ff 75 f4             	pushl  -0xc(%ebp)
  80193d:	e8 ee f4 ff ff       	call   800e30 <fd2data>
	return _pipeisclosed(fd, p);
  801942:	89 c2                	mov    %eax,%edx
  801944:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801947:	e8 30 fd ff ff       	call   80167c <_pipeisclosed>
  80194c:	83 c4 10             	add    $0x10,%esp
}
  80194f:	c9                   	leave  
  801950:	c3                   	ret    

00801951 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801954:	b8 00 00 00 00       	mov    $0x0,%eax
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801961:	68 2e 23 80 00       	push   $0x80232e
  801966:	ff 75 0c             	pushl  0xc(%ebp)
  801969:	e8 c8 ee ff ff       	call   800836 <strcpy>
	return 0;
}
  80196e:	b8 00 00 00 00       	mov    $0x0,%eax
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <devcons_write>:
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	57                   	push   %edi
  801979:	56                   	push   %esi
  80197a:	53                   	push   %ebx
  80197b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801981:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801986:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80198c:	eb 2f                	jmp    8019bd <devcons_write+0x48>
		m = n - tot;
  80198e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801991:	29 f3                	sub    %esi,%ebx
  801993:	83 fb 7f             	cmp    $0x7f,%ebx
  801996:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80199b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80199e:	83 ec 04             	sub    $0x4,%esp
  8019a1:	53                   	push   %ebx
  8019a2:	89 f0                	mov    %esi,%eax
  8019a4:	03 45 0c             	add    0xc(%ebp),%eax
  8019a7:	50                   	push   %eax
  8019a8:	57                   	push   %edi
  8019a9:	e8 16 f0 ff ff       	call   8009c4 <memmove>
		sys_cputs(buf, m);
  8019ae:	83 c4 08             	add    $0x8,%esp
  8019b1:	53                   	push   %ebx
  8019b2:	57                   	push   %edi
  8019b3:	e8 bb f1 ff ff       	call   800b73 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019b8:	01 de                	add    %ebx,%esi
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019c0:	72 cc                	jb     80198e <devcons_write+0x19>
}
  8019c2:	89 f0                	mov    %esi,%eax
  8019c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c7:	5b                   	pop    %ebx
  8019c8:	5e                   	pop    %esi
  8019c9:	5f                   	pop    %edi
  8019ca:	5d                   	pop    %ebp
  8019cb:	c3                   	ret    

008019cc <devcons_read>:
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8019d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019db:	75 07                	jne    8019e4 <devcons_read+0x18>
}
  8019dd:	c9                   	leave  
  8019de:	c3                   	ret    
		sys_yield();
  8019df:	e8 2c f2 ff ff       	call   800c10 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8019e4:	e8 a8 f1 ff ff       	call   800b91 <sys_cgetc>
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	74 f2                	je     8019df <devcons_read+0x13>
	if (c < 0)
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	78 ec                	js     8019dd <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  8019f1:	83 f8 04             	cmp    $0x4,%eax
  8019f4:	74 0c                	je     801a02 <devcons_read+0x36>
	*(char*)vbuf = c;
  8019f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019f9:	88 02                	mov    %al,(%edx)
	return 1;
  8019fb:	b8 01 00 00 00       	mov    $0x1,%eax
  801a00:	eb db                	jmp    8019dd <devcons_read+0x11>
		return 0;
  801a02:	b8 00 00 00 00       	mov    $0x0,%eax
  801a07:	eb d4                	jmp    8019dd <devcons_read+0x11>

00801a09 <cputchar>:
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a12:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a15:	6a 01                	push   $0x1
  801a17:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a1a:	50                   	push   %eax
  801a1b:	e8 53 f1 ff ff       	call   800b73 <sys_cputs>
}
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <getchar>:
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a2b:	6a 01                	push   $0x1
  801a2d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a30:	50                   	push   %eax
  801a31:	6a 00                	push   $0x0
  801a33:	e8 cf f6 ff ff       	call   801107 <read>
	if (r < 0)
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	78 08                	js     801a47 <getchar+0x22>
	if (r < 1)
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	7e 06                	jle    801a49 <getchar+0x24>
	return c;
  801a43:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    
		return -E_EOF;
  801a49:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a4e:	eb f7                	jmp    801a47 <getchar+0x22>

00801a50 <iscons>:
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a59:	50                   	push   %eax
  801a5a:	ff 75 08             	pushl  0x8(%ebp)
  801a5d:	e8 34 f4 ff ff       	call   800e96 <fd_lookup>
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 11                	js     801a7a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a72:	39 10                	cmp    %edx,(%eax)
  801a74:	0f 94 c0             	sete   %al
  801a77:	0f b6 c0             	movzbl %al,%eax
}
  801a7a:	c9                   	leave  
  801a7b:	c3                   	ret    

00801a7c <opencons>:
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801a82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a85:	50                   	push   %eax
  801a86:	e8 bc f3 ff ff       	call   800e47 <fd_alloc>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 3a                	js     801acc <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a92:	83 ec 04             	sub    $0x4,%esp
  801a95:	68 07 04 00 00       	push   $0x407
  801a9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9d:	6a 00                	push   $0x0
  801a9f:	e8 8b f1 ff ff       	call   800c2f <sys_page_alloc>
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	78 21                	js     801acc <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aae:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ac0:	83 ec 0c             	sub    $0xc,%esp
  801ac3:	50                   	push   %eax
  801ac4:	e8 57 f3 ff ff       	call   800e20 <fd2num>
  801ac9:	83 c4 10             	add    $0x10,%esp
}
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	56                   	push   %esi
  801ad2:	53                   	push   %ebx
  801ad3:	8b 75 08             	mov    0x8(%ebp),%esi
  801ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801adc:	85 f6                	test   %esi,%esi
  801ade:	74 06                	je     801ae6 <ipc_recv+0x18>
  801ae0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801ae6:	85 db                	test   %ebx,%ebx
  801ae8:	74 06                	je     801af0 <ipc_recv+0x22>
  801aea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801af0:	85 c0                	test   %eax,%eax
  801af2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801af7:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	50                   	push   %eax
  801afe:	e8 dc f2 ff ff       	call   800ddf <sys_ipc_recv>
	if (ret) return ret;
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	85 c0                	test   %eax,%eax
  801b08:	75 24                	jne    801b2e <ipc_recv+0x60>
	if (from_env_store)
  801b0a:	85 f6                	test   %esi,%esi
  801b0c:	74 0a                	je     801b18 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801b0e:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b13:	8b 40 74             	mov    0x74(%eax),%eax
  801b16:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801b18:	85 db                	test   %ebx,%ebx
  801b1a:	74 0a                	je     801b26 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801b1c:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b21:	8b 40 78             	mov    0x78(%eax),%eax
  801b24:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801b26:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b2b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b31:	5b                   	pop    %ebx
  801b32:	5e                   	pop    %esi
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	57                   	push   %edi
  801b39:	56                   	push   %esi
  801b3a:	53                   	push   %ebx
  801b3b:	83 ec 0c             	sub    $0xc,%esp
  801b3e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b41:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801b47:	85 db                	test   %ebx,%ebx
  801b49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b4e:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b51:	ff 75 14             	pushl  0x14(%ebp)
  801b54:	53                   	push   %ebx
  801b55:	56                   	push   %esi
  801b56:	57                   	push   %edi
  801b57:	e8 60 f2 ff ff       	call   800dbc <sys_ipc_try_send>
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	74 1e                	je     801b81 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801b63:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b66:	75 07                	jne    801b6f <ipc_send+0x3a>
		sys_yield();
  801b68:	e8 a3 f0 ff ff       	call   800c10 <sys_yield>
  801b6d:	eb e2                	jmp    801b51 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801b6f:	50                   	push   %eax
  801b70:	68 3a 23 80 00       	push   $0x80233a
  801b75:	6a 36                	push   $0x36
  801b77:	68 51 23 80 00       	push   $0x802351
  801b7c:	e8 bb e5 ff ff       	call   80013c <_panic>
	}
}
  801b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b84:	5b                   	pop    %ebx
  801b85:	5e                   	pop    %esi
  801b86:	5f                   	pop    %edi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b8f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b94:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b97:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b9d:	8b 52 50             	mov    0x50(%edx),%edx
  801ba0:	39 ca                	cmp    %ecx,%edx
  801ba2:	74 11                	je     801bb5 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801ba4:	83 c0 01             	add    $0x1,%eax
  801ba7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bac:	75 e6                	jne    801b94 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801bae:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb3:	eb 0b                	jmp    801bc0 <ipc_find_env+0x37>
			return envs[i].env_id;
  801bb5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bb8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bbd:	8b 40 48             	mov    0x48(%eax),%eax
}
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    

00801bc2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bc8:	89 d0                	mov    %edx,%eax
  801bca:	c1 e8 16             	shr    $0x16,%eax
  801bcd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bd4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801bd9:	f6 c1 01             	test   $0x1,%cl
  801bdc:	74 1d                	je     801bfb <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801bde:	c1 ea 0c             	shr    $0xc,%edx
  801be1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801be8:	f6 c2 01             	test   $0x1,%dl
  801beb:	74 0e                	je     801bfb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bed:	c1 ea 0c             	shr    $0xc,%edx
  801bf0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bf7:	ef 
  801bf8:	0f b7 c0             	movzwl %ax,%eax
}
  801bfb:	5d                   	pop    %ebp
  801bfc:	c3                   	ret    
  801bfd:	66 90                	xchg   %ax,%ax
  801bff:	90                   	nop

00801c00 <__udivdi3>:
  801c00:	55                   	push   %ebp
  801c01:	57                   	push   %edi
  801c02:	56                   	push   %esi
  801c03:	53                   	push   %ebx
  801c04:	83 ec 1c             	sub    $0x1c,%esp
  801c07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c0b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c13:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c17:	85 d2                	test   %edx,%edx
  801c19:	75 35                	jne    801c50 <__udivdi3+0x50>
  801c1b:	39 f3                	cmp    %esi,%ebx
  801c1d:	0f 87 bd 00 00 00    	ja     801ce0 <__udivdi3+0xe0>
  801c23:	85 db                	test   %ebx,%ebx
  801c25:	89 d9                	mov    %ebx,%ecx
  801c27:	75 0b                	jne    801c34 <__udivdi3+0x34>
  801c29:	b8 01 00 00 00       	mov    $0x1,%eax
  801c2e:	31 d2                	xor    %edx,%edx
  801c30:	f7 f3                	div    %ebx
  801c32:	89 c1                	mov    %eax,%ecx
  801c34:	31 d2                	xor    %edx,%edx
  801c36:	89 f0                	mov    %esi,%eax
  801c38:	f7 f1                	div    %ecx
  801c3a:	89 c6                	mov    %eax,%esi
  801c3c:	89 e8                	mov    %ebp,%eax
  801c3e:	89 f7                	mov    %esi,%edi
  801c40:	f7 f1                	div    %ecx
  801c42:	89 fa                	mov    %edi,%edx
  801c44:	83 c4 1c             	add    $0x1c,%esp
  801c47:	5b                   	pop    %ebx
  801c48:	5e                   	pop    %esi
  801c49:	5f                   	pop    %edi
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    
  801c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c50:	39 f2                	cmp    %esi,%edx
  801c52:	77 7c                	ja     801cd0 <__udivdi3+0xd0>
  801c54:	0f bd fa             	bsr    %edx,%edi
  801c57:	83 f7 1f             	xor    $0x1f,%edi
  801c5a:	0f 84 98 00 00 00    	je     801cf8 <__udivdi3+0xf8>
  801c60:	89 f9                	mov    %edi,%ecx
  801c62:	b8 20 00 00 00       	mov    $0x20,%eax
  801c67:	29 f8                	sub    %edi,%eax
  801c69:	d3 e2                	shl    %cl,%edx
  801c6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c6f:	89 c1                	mov    %eax,%ecx
  801c71:	89 da                	mov    %ebx,%edx
  801c73:	d3 ea                	shr    %cl,%edx
  801c75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c79:	09 d1                	or     %edx,%ecx
  801c7b:	89 f2                	mov    %esi,%edx
  801c7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c81:	89 f9                	mov    %edi,%ecx
  801c83:	d3 e3                	shl    %cl,%ebx
  801c85:	89 c1                	mov    %eax,%ecx
  801c87:	d3 ea                	shr    %cl,%edx
  801c89:	89 f9                	mov    %edi,%ecx
  801c8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c8f:	d3 e6                	shl    %cl,%esi
  801c91:	89 eb                	mov    %ebp,%ebx
  801c93:	89 c1                	mov    %eax,%ecx
  801c95:	d3 eb                	shr    %cl,%ebx
  801c97:	09 de                	or     %ebx,%esi
  801c99:	89 f0                	mov    %esi,%eax
  801c9b:	f7 74 24 08          	divl   0x8(%esp)
  801c9f:	89 d6                	mov    %edx,%esi
  801ca1:	89 c3                	mov    %eax,%ebx
  801ca3:	f7 64 24 0c          	mull   0xc(%esp)
  801ca7:	39 d6                	cmp    %edx,%esi
  801ca9:	72 0c                	jb     801cb7 <__udivdi3+0xb7>
  801cab:	89 f9                	mov    %edi,%ecx
  801cad:	d3 e5                	shl    %cl,%ebp
  801caf:	39 c5                	cmp    %eax,%ebp
  801cb1:	73 5d                	jae    801d10 <__udivdi3+0x110>
  801cb3:	39 d6                	cmp    %edx,%esi
  801cb5:	75 59                	jne    801d10 <__udivdi3+0x110>
  801cb7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801cba:	31 ff                	xor    %edi,%edi
  801cbc:	89 fa                	mov    %edi,%edx
  801cbe:	83 c4 1c             	add    $0x1c,%esp
  801cc1:	5b                   	pop    %ebx
  801cc2:	5e                   	pop    %esi
  801cc3:	5f                   	pop    %edi
  801cc4:	5d                   	pop    %ebp
  801cc5:	c3                   	ret    
  801cc6:	8d 76 00             	lea    0x0(%esi),%esi
  801cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801cd0:	31 ff                	xor    %edi,%edi
  801cd2:	31 c0                	xor    %eax,%eax
  801cd4:	89 fa                	mov    %edi,%edx
  801cd6:	83 c4 1c             	add    $0x1c,%esp
  801cd9:	5b                   	pop    %ebx
  801cda:	5e                   	pop    %esi
  801cdb:	5f                   	pop    %edi
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    
  801cde:	66 90                	xchg   %ax,%ax
  801ce0:	31 ff                	xor    %edi,%edi
  801ce2:	89 e8                	mov    %ebp,%eax
  801ce4:	89 f2                	mov    %esi,%edx
  801ce6:	f7 f3                	div    %ebx
  801ce8:	89 fa                	mov    %edi,%edx
  801cea:	83 c4 1c             	add    $0x1c,%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    
  801cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf8:	39 f2                	cmp    %esi,%edx
  801cfa:	72 06                	jb     801d02 <__udivdi3+0x102>
  801cfc:	31 c0                	xor    %eax,%eax
  801cfe:	39 eb                	cmp    %ebp,%ebx
  801d00:	77 d2                	ja     801cd4 <__udivdi3+0xd4>
  801d02:	b8 01 00 00 00       	mov    $0x1,%eax
  801d07:	eb cb                	jmp    801cd4 <__udivdi3+0xd4>
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	89 d8                	mov    %ebx,%eax
  801d12:	31 ff                	xor    %edi,%edi
  801d14:	eb be                	jmp    801cd4 <__udivdi3+0xd4>
  801d16:	66 90                	xchg   %ax,%ax
  801d18:	66 90                	xchg   %ax,%ax
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <__umoddi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801d2b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d2f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d37:	85 ed                	test   %ebp,%ebp
  801d39:	89 f0                	mov    %esi,%eax
  801d3b:	89 da                	mov    %ebx,%edx
  801d3d:	75 19                	jne    801d58 <__umoddi3+0x38>
  801d3f:	39 df                	cmp    %ebx,%edi
  801d41:	0f 86 b1 00 00 00    	jbe    801df8 <__umoddi3+0xd8>
  801d47:	f7 f7                	div    %edi
  801d49:	89 d0                	mov    %edx,%eax
  801d4b:	31 d2                	xor    %edx,%edx
  801d4d:	83 c4 1c             	add    $0x1c,%esp
  801d50:	5b                   	pop    %ebx
  801d51:	5e                   	pop    %esi
  801d52:	5f                   	pop    %edi
  801d53:	5d                   	pop    %ebp
  801d54:	c3                   	ret    
  801d55:	8d 76 00             	lea    0x0(%esi),%esi
  801d58:	39 dd                	cmp    %ebx,%ebp
  801d5a:	77 f1                	ja     801d4d <__umoddi3+0x2d>
  801d5c:	0f bd cd             	bsr    %ebp,%ecx
  801d5f:	83 f1 1f             	xor    $0x1f,%ecx
  801d62:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d66:	0f 84 b4 00 00 00    	je     801e20 <__umoddi3+0x100>
  801d6c:	b8 20 00 00 00       	mov    $0x20,%eax
  801d71:	89 c2                	mov    %eax,%edx
  801d73:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d77:	29 c2                	sub    %eax,%edx
  801d79:	89 c1                	mov    %eax,%ecx
  801d7b:	89 f8                	mov    %edi,%eax
  801d7d:	d3 e5                	shl    %cl,%ebp
  801d7f:	89 d1                	mov    %edx,%ecx
  801d81:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d85:	d3 e8                	shr    %cl,%eax
  801d87:	09 c5                	or     %eax,%ebp
  801d89:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d8d:	89 c1                	mov    %eax,%ecx
  801d8f:	d3 e7                	shl    %cl,%edi
  801d91:	89 d1                	mov    %edx,%ecx
  801d93:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d97:	89 df                	mov    %ebx,%edi
  801d99:	d3 ef                	shr    %cl,%edi
  801d9b:	89 c1                	mov    %eax,%ecx
  801d9d:	89 f0                	mov    %esi,%eax
  801d9f:	d3 e3                	shl    %cl,%ebx
  801da1:	89 d1                	mov    %edx,%ecx
  801da3:	89 fa                	mov    %edi,%edx
  801da5:	d3 e8                	shr    %cl,%eax
  801da7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801dac:	09 d8                	or     %ebx,%eax
  801dae:	f7 f5                	div    %ebp
  801db0:	d3 e6                	shl    %cl,%esi
  801db2:	89 d1                	mov    %edx,%ecx
  801db4:	f7 64 24 08          	mull   0x8(%esp)
  801db8:	39 d1                	cmp    %edx,%ecx
  801dba:	89 c3                	mov    %eax,%ebx
  801dbc:	89 d7                	mov    %edx,%edi
  801dbe:	72 06                	jb     801dc6 <__umoddi3+0xa6>
  801dc0:	75 0e                	jne    801dd0 <__umoddi3+0xb0>
  801dc2:	39 c6                	cmp    %eax,%esi
  801dc4:	73 0a                	jae    801dd0 <__umoddi3+0xb0>
  801dc6:	2b 44 24 08          	sub    0x8(%esp),%eax
  801dca:	19 ea                	sbb    %ebp,%edx
  801dcc:	89 d7                	mov    %edx,%edi
  801dce:	89 c3                	mov    %eax,%ebx
  801dd0:	89 ca                	mov    %ecx,%edx
  801dd2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801dd7:	29 de                	sub    %ebx,%esi
  801dd9:	19 fa                	sbb    %edi,%edx
  801ddb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801ddf:	89 d0                	mov    %edx,%eax
  801de1:	d3 e0                	shl    %cl,%eax
  801de3:	89 d9                	mov    %ebx,%ecx
  801de5:	d3 ee                	shr    %cl,%esi
  801de7:	d3 ea                	shr    %cl,%edx
  801de9:	09 f0                	or     %esi,%eax
  801deb:	83 c4 1c             	add    $0x1c,%esp
  801dee:	5b                   	pop    %ebx
  801def:	5e                   	pop    %esi
  801df0:	5f                   	pop    %edi
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    
  801df3:	90                   	nop
  801df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df8:	85 ff                	test   %edi,%edi
  801dfa:	89 f9                	mov    %edi,%ecx
  801dfc:	75 0b                	jne    801e09 <__umoddi3+0xe9>
  801dfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801e03:	31 d2                	xor    %edx,%edx
  801e05:	f7 f7                	div    %edi
  801e07:	89 c1                	mov    %eax,%ecx
  801e09:	89 d8                	mov    %ebx,%eax
  801e0b:	31 d2                	xor    %edx,%edx
  801e0d:	f7 f1                	div    %ecx
  801e0f:	89 f0                	mov    %esi,%eax
  801e11:	f7 f1                	div    %ecx
  801e13:	e9 31 ff ff ff       	jmp    801d49 <__umoddi3+0x29>
  801e18:	90                   	nop
  801e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e20:	39 dd                	cmp    %ebx,%ebp
  801e22:	72 08                	jb     801e2c <__umoddi3+0x10c>
  801e24:	39 f7                	cmp    %esi,%edi
  801e26:	0f 87 21 ff ff ff    	ja     801d4d <__umoddi3+0x2d>
  801e2c:	89 da                	mov    %ebx,%edx
  801e2e:	89 f0                	mov    %esi,%eax
  801e30:	29 f8                	sub    %edi,%eax
  801e32:	19 ea                	sbb    %ebp,%edx
  801e34:	e9 14 ff ff ff       	jmp    801d4d <__umoddi3+0x2d>
