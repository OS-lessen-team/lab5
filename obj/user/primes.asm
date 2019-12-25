
obj/user/primes.debug：     文件格式 elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 e2 10 00 00       	call   80112e <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 e0 21 80 00       	push   $0x8021e0
  800060:	e8 ce 01 00 00       	call   800233 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 d4 0e 00 00       	call   800f3e <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	78 30                	js     8000a3 <primeproc+0x70>
		panic("fork: %e", id);
	if (id == 0)
  800073:	85 c0                	test   %eax,%eax
  800075:	74 c8                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800077:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80007a:	83 ec 04             	sub    $0x4,%esp
  80007d:	6a 00                	push   $0x0
  80007f:	6a 00                	push   $0x0
  800081:	56                   	push   %esi
  800082:	e8 a7 10 00 00       	call   80112e <ipc_recv>
  800087:	89 c1                	mov    %eax,%ecx
		if (i % p)
  800089:	99                   	cltd   
  80008a:	f7 fb                	idiv   %ebx
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	85 d2                	test   %edx,%edx
  800091:	74 e7                	je     80007a <primeproc+0x47>
			ipc_send(id, i, 0, 0);
  800093:	6a 00                	push   $0x0
  800095:	6a 00                	push   $0x0
  800097:	51                   	push   %ecx
  800098:	57                   	push   %edi
  800099:	e8 f7 10 00 00       	call   801195 <ipc_send>
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	eb d7                	jmp    80007a <primeproc+0x47>
		panic("fork: %e", id);
  8000a3:	50                   	push   %eax
  8000a4:	68 99 25 80 00       	push   $0x802599
  8000a9:	6a 1a                	push   $0x1a
  8000ab:	68 ec 21 80 00       	push   $0x8021ec
  8000b0:	e8 a3 00 00 00       	call   800158 <_panic>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 7f 0e 00 00       	call   800f3e <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	78 1c                	js     8000e1 <umain+0x2c>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000c5:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	74 25                	je     8000f3 <umain+0x3e>
		ipc_send(id, i, 0, 0);
  8000ce:	6a 00                	push   $0x0
  8000d0:	6a 00                	push   $0x0
  8000d2:	53                   	push   %ebx
  8000d3:	56                   	push   %esi
  8000d4:	e8 bc 10 00 00       	call   801195 <ipc_send>
	for (i = 2; ; i++)
  8000d9:	83 c3 01             	add    $0x1,%ebx
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	eb ed                	jmp    8000ce <umain+0x19>
		panic("fork: %e", id);
  8000e1:	50                   	push   %eax
  8000e2:	68 99 25 80 00       	push   $0x802599
  8000e7:	6a 2d                	push   $0x2d
  8000e9:	68 ec 21 80 00       	push   $0x8021ec
  8000ee:	e8 65 00 00 00       	call   800158 <_panic>
		primeproc();
  8000f3:	e8 3b ff ff ff       	call   800033 <primeproc>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800103:	e8 05 0b 00 00       	call   800c0d <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 af 12 00 00       	call   8013f8 <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 79 0a 00 00       	call   800bcc <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 a2 0a 00 00       	call   800c0d <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 04 22 80 00       	push   $0x802204
  80017b:	e8 b3 00 00 00       	call   800233 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 56 00 00 00       	call   8001e2 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 d7 26 80 00 	movl   $0x8026d7,(%esp)
  800193:	e8 9b 00 00 00       	call   800233 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	74 09                	je     8001c6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001bd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	68 ff 00 00 00       	push   $0xff
  8001ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d1:	50                   	push   %eax
  8001d2:	e8 b8 09 00 00       	call   800b8f <sys_cputs>
		b->idx = 0;
  8001d7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001dd:	83 c4 10             	add    $0x10,%esp
  8001e0:	eb db                	jmp    8001bd <putch+0x1f>

008001e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f2:	00 00 00 
	b.cnt = 0;
  8001f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ff:	ff 75 0c             	pushl  0xc(%ebp)
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020b:	50                   	push   %eax
  80020c:	68 9e 01 80 00       	push   $0x80019e
  800211:	e8 1a 01 00 00       	call   800330 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800216:	83 c4 08             	add    $0x8,%esp
  800219:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800225:	50                   	push   %eax
  800226:	e8 64 09 00 00       	call   800b8f <sys_cputs>

	return b.cnt;
}
  80022b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800239:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023c:	50                   	push   %eax
  80023d:	ff 75 08             	pushl  0x8(%ebp)
  800240:	e8 9d ff ff ff       	call   8001e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	57                   	push   %edi
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 1c             	sub    $0x1c,%esp
  800250:	89 c7                	mov    %eax,%edi
  800252:	89 d6                	mov    %edx,%esi
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800260:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800263:	bb 00 00 00 00       	mov    $0x0,%ebx
  800268:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026e:	39 d3                	cmp    %edx,%ebx
  800270:	72 05                	jb     800277 <printnum+0x30>
  800272:	39 45 10             	cmp    %eax,0x10(%ebp)
  800275:	77 7a                	ja     8002f1 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	8b 45 14             	mov    0x14(%ebp),%eax
  800280:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800283:	53                   	push   %ebx
  800284:	ff 75 10             	pushl  0x10(%ebp)
  800287:	83 ec 08             	sub    $0x8,%esp
  80028a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028d:	ff 75 e0             	pushl  -0x20(%ebp)
  800290:	ff 75 dc             	pushl  -0x24(%ebp)
  800293:	ff 75 d8             	pushl  -0x28(%ebp)
  800296:	e8 05 1d 00 00       	call   801fa0 <__udivdi3>
  80029b:	83 c4 18             	add    $0x18,%esp
  80029e:	52                   	push   %edx
  80029f:	50                   	push   %eax
  8002a0:	89 f2                	mov    %esi,%edx
  8002a2:	89 f8                	mov    %edi,%eax
  8002a4:	e8 9e ff ff ff       	call   800247 <printnum>
  8002a9:	83 c4 20             	add    $0x20,%esp
  8002ac:	eb 13                	jmp    8002c1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ae:	83 ec 08             	sub    $0x8,%esp
  8002b1:	56                   	push   %esi
  8002b2:	ff 75 18             	pushl  0x18(%ebp)
  8002b5:	ff d7                	call   *%edi
  8002b7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002ba:	83 eb 01             	sub    $0x1,%ebx
  8002bd:	85 db                	test   %ebx,%ebx
  8002bf:	7f ed                	jg     8002ae <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	56                   	push   %esi
  8002c5:	83 ec 04             	sub    $0x4,%esp
  8002c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d4:	e8 e7 1d 00 00       	call   8020c0 <__umoddi3>
  8002d9:	83 c4 14             	add    $0x14,%esp
  8002dc:	0f be 80 27 22 80 00 	movsbl 0x802227(%eax),%eax
  8002e3:	50                   	push   %eax
  8002e4:	ff d7                	call   *%edi
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ec:	5b                   	pop    %ebx
  8002ed:	5e                   	pop    %esi
  8002ee:	5f                   	pop    %edi
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    
  8002f1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f4:	eb c4                	jmp    8002ba <printnum+0x73>

008002f6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800300:	8b 10                	mov    (%eax),%edx
  800302:	3b 50 04             	cmp    0x4(%eax),%edx
  800305:	73 0a                	jae    800311 <sprintputch+0x1b>
		*b->buf++ = ch;
  800307:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030a:	89 08                	mov    %ecx,(%eax)
  80030c:	8b 45 08             	mov    0x8(%ebp),%eax
  80030f:	88 02                	mov    %al,(%edx)
}
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <printfmt>:
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800319:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031c:	50                   	push   %eax
  80031d:	ff 75 10             	pushl  0x10(%ebp)
  800320:	ff 75 0c             	pushl  0xc(%ebp)
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 05 00 00 00       	call   800330 <vprintfmt>
}
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <vprintfmt>:
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	57                   	push   %edi
  800334:	56                   	push   %esi
  800335:	53                   	push   %ebx
  800336:	83 ec 2c             	sub    $0x2c,%esp
  800339:	8b 75 08             	mov    0x8(%ebp),%esi
  80033c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800342:	e9 c1 03 00 00       	jmp    800708 <vprintfmt+0x3d8>
		padc = ' ';
  800347:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80034b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800352:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800359:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800360:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8d 47 01             	lea    0x1(%edi),%eax
  800368:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036b:	0f b6 17             	movzbl (%edi),%edx
  80036e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800371:	3c 55                	cmp    $0x55,%al
  800373:	0f 87 12 04 00 00    	ja     80078b <vprintfmt+0x45b>
  800379:	0f b6 c0             	movzbl %al,%eax
  80037c:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800386:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80038a:	eb d9                	jmp    800365 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80038f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800393:	eb d0                	jmp    800365 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800395:	0f b6 d2             	movzbl %dl,%edx
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80039b:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003aa:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ad:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b0:	83 f9 09             	cmp    $0x9,%ecx
  8003b3:	77 55                	ja     80040a <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8003b5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b8:	eb e9                	jmp    8003a3 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8b 00                	mov    (%eax),%eax
  8003bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 40 04             	lea    0x4(%eax),%eax
  8003c8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d2:	79 91                	jns    800365 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e1:	eb 82                	jmp    800365 <vprintfmt+0x35>
  8003e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e6:	85 c0                	test   %eax,%eax
  8003e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ed:	0f 49 d0             	cmovns %eax,%edx
  8003f0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f6:	e9 6a ff ff ff       	jmp    800365 <vprintfmt+0x35>
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003fe:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800405:	e9 5b ff ff ff       	jmp    800365 <vprintfmt+0x35>
  80040a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80040d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800410:	eb bc                	jmp    8003ce <vprintfmt+0x9e>
			lflag++;
  800412:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800418:	e9 48 ff ff ff       	jmp    800365 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8d 78 04             	lea    0x4(%eax),%edi
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	53                   	push   %ebx
  800427:	ff 30                	pushl  (%eax)
  800429:	ff d6                	call   *%esi
			break;
  80042b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80042e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800431:	e9 cf 02 00 00       	jmp    800705 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 78 04             	lea    0x4(%eax),%edi
  80043c:	8b 00                	mov    (%eax),%eax
  80043e:	99                   	cltd   
  80043f:	31 d0                	xor    %edx,%eax
  800441:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800443:	83 f8 0f             	cmp    $0xf,%eax
  800446:	7f 23                	jg     80046b <vprintfmt+0x13b>
  800448:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  80044f:	85 d2                	test   %edx,%edx
  800451:	74 18                	je     80046b <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800453:	52                   	push   %edx
  800454:	68 a5 26 80 00       	push   $0x8026a5
  800459:	53                   	push   %ebx
  80045a:	56                   	push   %esi
  80045b:	e8 b3 fe ff ff       	call   800313 <printfmt>
  800460:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800463:	89 7d 14             	mov    %edi,0x14(%ebp)
  800466:	e9 9a 02 00 00       	jmp    800705 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80046b:	50                   	push   %eax
  80046c:	68 3f 22 80 00       	push   $0x80223f
  800471:	53                   	push   %ebx
  800472:	56                   	push   %esi
  800473:	e8 9b fe ff ff       	call   800313 <printfmt>
  800478:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80047e:	e9 82 02 00 00       	jmp    800705 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	83 c0 04             	add    $0x4,%eax
  800489:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800491:	85 ff                	test   %edi,%edi
  800493:	b8 38 22 80 00       	mov    $0x802238,%eax
  800498:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80049b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049f:	0f 8e bd 00 00 00    	jle    800562 <vprintfmt+0x232>
  8004a5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a9:	75 0e                	jne    8004b9 <vprintfmt+0x189>
  8004ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b7:	eb 6d                	jmp    800526 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	ff 75 d0             	pushl  -0x30(%ebp)
  8004bf:	57                   	push   %edi
  8004c0:	e8 6e 03 00 00       	call   800833 <strnlen>
  8004c5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c8:	29 c1                	sub    %eax,%ecx
  8004ca:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004cd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004da:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dc:	eb 0f                	jmp    8004ed <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	83 ef 01             	sub    $0x1,%edi
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	7f ed                	jg     8004de <vprintfmt+0x1ae>
  8004f1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f7:	85 c9                	test   %ecx,%ecx
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	0f 49 c1             	cmovns %ecx,%eax
  800501:	29 c1                	sub    %eax,%ecx
  800503:	89 75 08             	mov    %esi,0x8(%ebp)
  800506:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800509:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050c:	89 cb                	mov    %ecx,%ebx
  80050e:	eb 16                	jmp    800526 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800510:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800514:	75 31                	jne    800547 <vprintfmt+0x217>
					putch(ch, putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	ff 75 0c             	pushl  0xc(%ebp)
  80051c:	50                   	push   %eax
  80051d:	ff 55 08             	call   *0x8(%ebp)
  800520:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800523:	83 eb 01             	sub    $0x1,%ebx
  800526:	83 c7 01             	add    $0x1,%edi
  800529:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80052d:	0f be c2             	movsbl %dl,%eax
  800530:	85 c0                	test   %eax,%eax
  800532:	74 59                	je     80058d <vprintfmt+0x25d>
  800534:	85 f6                	test   %esi,%esi
  800536:	78 d8                	js     800510 <vprintfmt+0x1e0>
  800538:	83 ee 01             	sub    $0x1,%esi
  80053b:	79 d3                	jns    800510 <vprintfmt+0x1e0>
  80053d:	89 df                	mov    %ebx,%edi
  80053f:	8b 75 08             	mov    0x8(%ebp),%esi
  800542:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800545:	eb 37                	jmp    80057e <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800547:	0f be d2             	movsbl %dl,%edx
  80054a:	83 ea 20             	sub    $0x20,%edx
  80054d:	83 fa 5e             	cmp    $0x5e,%edx
  800550:	76 c4                	jbe    800516 <vprintfmt+0x1e6>
					putch('?', putdat);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	ff 75 0c             	pushl  0xc(%ebp)
  800558:	6a 3f                	push   $0x3f
  80055a:	ff 55 08             	call   *0x8(%ebp)
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	eb c1                	jmp    800523 <vprintfmt+0x1f3>
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056e:	eb b6                	jmp    800526 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	53                   	push   %ebx
  800574:	6a 20                	push   $0x20
  800576:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800578:	83 ef 01             	sub    $0x1,%edi
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	85 ff                	test   %edi,%edi
  800580:	7f ee                	jg     800570 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800582:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
  800588:	e9 78 01 00 00       	jmp    800705 <vprintfmt+0x3d5>
  80058d:	89 df                	mov    %ebx,%edi
  80058f:	8b 75 08             	mov    0x8(%ebp),%esi
  800592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800595:	eb e7                	jmp    80057e <vprintfmt+0x24e>
	if (lflag >= 2)
  800597:	83 f9 01             	cmp    $0x1,%ecx
  80059a:	7e 3f                	jle    8005db <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 50 04             	mov    0x4(%eax),%edx
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 40 08             	lea    0x8(%eax),%eax
  8005b0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b7:	79 5c                	jns    800615 <vprintfmt+0x2e5>
				putch('-', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 2d                	push   $0x2d
  8005bf:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c7:	f7 da                	neg    %edx
  8005c9:	83 d1 00             	adc    $0x0,%ecx
  8005cc:	f7 d9                	neg    %ecx
  8005ce:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d6:	e9 10 01 00 00       	jmp    8006eb <vprintfmt+0x3bb>
	else if (lflag)
  8005db:	85 c9                	test   %ecx,%ecx
  8005dd:	75 1b                	jne    8005fa <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 c1                	mov    %eax,%ecx
  8005e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f8:	eb b9                	jmp    8005b3 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 c1                	mov    %eax,%ecx
  800604:	c1 f9 1f             	sar    $0x1f,%ecx
  800607:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
  800613:	eb 9e                	jmp    8005b3 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800615:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800618:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80061b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800620:	e9 c6 00 00 00       	jmp    8006eb <vprintfmt+0x3bb>
	if (lflag >= 2)
  800625:	83 f9 01             	cmp    $0x1,%ecx
  800628:	7e 18                	jle    800642 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8b 10                	mov    (%eax),%edx
  80062f:	8b 48 04             	mov    0x4(%eax),%ecx
  800632:	8d 40 08             	lea    0x8(%eax),%eax
  800635:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800638:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063d:	e9 a9 00 00 00       	jmp    8006eb <vprintfmt+0x3bb>
	else if (lflag)
  800642:	85 c9                	test   %ecx,%ecx
  800644:	75 1a                	jne    800660 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8b 10                	mov    (%eax),%edx
  80064b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800650:	8d 40 04             	lea    0x4(%eax),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065b:	e9 8b 00 00 00       	jmp    8006eb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 10                	mov    (%eax),%edx
  800665:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066a:	8d 40 04             	lea    0x4(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800670:	b8 0a 00 00 00       	mov    $0xa,%eax
  800675:	eb 74                	jmp    8006eb <vprintfmt+0x3bb>
	if (lflag >= 2)
  800677:	83 f9 01             	cmp    $0x1,%ecx
  80067a:	7e 15                	jle    800691 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	8b 48 04             	mov    0x4(%eax),%ecx
  800684:	8d 40 08             	lea    0x8(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80068a:	b8 08 00 00 00       	mov    $0x8,%eax
  80068f:	eb 5a                	jmp    8006eb <vprintfmt+0x3bb>
	else if (lflag)
  800691:	85 c9                	test   %ecx,%ecx
  800693:	75 17                	jne    8006ac <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069f:	8d 40 04             	lea    0x4(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006a5:	b8 08 00 00 00       	mov    $0x8,%eax
  8006aa:	eb 3f                	jmp    8006eb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006bc:	b8 08 00 00 00       	mov    $0x8,%eax
  8006c1:	eb 28                	jmp    8006eb <vprintfmt+0x3bb>
			putch('0', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 30                	push   $0x30
  8006c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006cb:	83 c4 08             	add    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 78                	push   $0x78
  8006d1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006dd:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006eb:	83 ec 0c             	sub    $0xc,%esp
  8006ee:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006f2:	57                   	push   %edi
  8006f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f6:	50                   	push   %eax
  8006f7:	51                   	push   %ecx
  8006f8:	52                   	push   %edx
  8006f9:	89 da                	mov    %ebx,%edx
  8006fb:	89 f0                	mov    %esi,%eax
  8006fd:	e8 45 fb ff ff       	call   800247 <printnum>
			break;
  800702:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800705:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800708:	83 c7 01             	add    $0x1,%edi
  80070b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070f:	83 f8 25             	cmp    $0x25,%eax
  800712:	0f 84 2f fc ff ff    	je     800347 <vprintfmt+0x17>
			if (ch == '\0')
  800718:	85 c0                	test   %eax,%eax
  80071a:	0f 84 8b 00 00 00    	je     8007ab <vprintfmt+0x47b>
			putch(ch, putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	53                   	push   %ebx
  800724:	50                   	push   %eax
  800725:	ff d6                	call   *%esi
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	eb dc                	jmp    800708 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80072c:	83 f9 01             	cmp    $0x1,%ecx
  80072f:	7e 15                	jle    800746 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8b 10                	mov    (%eax),%edx
  800736:	8b 48 04             	mov    0x4(%eax),%ecx
  800739:	8d 40 08             	lea    0x8(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073f:	b8 10 00 00 00       	mov    $0x10,%eax
  800744:	eb a5                	jmp    8006eb <vprintfmt+0x3bb>
	else if (lflag)
  800746:	85 c9                	test   %ecx,%ecx
  800748:	75 17                	jne    800761 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 10                	mov    (%eax),%edx
  80074f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80075a:	b8 10 00 00 00       	mov    $0x10,%eax
  80075f:	eb 8a                	jmp    8006eb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8b 10                	mov    (%eax),%edx
  800766:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076b:	8d 40 04             	lea    0x4(%eax),%eax
  80076e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800771:	b8 10 00 00 00       	mov    $0x10,%eax
  800776:	e9 70 ff ff ff       	jmp    8006eb <vprintfmt+0x3bb>
			putch(ch, putdat);
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 25                	push   $0x25
  800781:	ff d6                	call   *%esi
			break;
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	e9 7a ff ff ff       	jmp    800705 <vprintfmt+0x3d5>
			putch('%', putdat);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	53                   	push   %ebx
  80078f:	6a 25                	push   $0x25
  800791:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	89 f8                	mov    %edi,%eax
  800798:	eb 03                	jmp    80079d <vprintfmt+0x46d>
  80079a:	83 e8 01             	sub    $0x1,%eax
  80079d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007a1:	75 f7                	jne    80079a <vprintfmt+0x46a>
  8007a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a6:	e9 5a ff ff ff       	jmp    800705 <vprintfmt+0x3d5>
}
  8007ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5f                   	pop    %edi
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	83 ec 18             	sub    $0x18,%esp
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	74 26                	je     8007fa <vsnprintf+0x47>
  8007d4:	85 d2                	test   %edx,%edx
  8007d6:	7e 22                	jle    8007fa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d8:	ff 75 14             	pushl  0x14(%ebp)
  8007db:	ff 75 10             	pushl  0x10(%ebp)
  8007de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e1:	50                   	push   %eax
  8007e2:	68 f6 02 80 00       	push   $0x8002f6
  8007e7:	e8 44 fb ff ff       	call   800330 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f5:	83 c4 10             	add    $0x10,%esp
}
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    
		return -E_INVAL;
  8007fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ff:	eb f7                	jmp    8007f8 <vsnprintf+0x45>

00800801 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800807:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080a:	50                   	push   %eax
  80080b:	ff 75 10             	pushl  0x10(%ebp)
  80080e:	ff 75 0c             	pushl  0xc(%ebp)
  800811:	ff 75 08             	pushl  0x8(%ebp)
  800814:	e8 9a ff ff ff       	call   8007b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
  800826:	eb 03                	jmp    80082b <strlen+0x10>
		n++;
  800828:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80082b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082f:	75 f7                	jne    800828 <strlen+0xd>
	return n;
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800839:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
  800841:	eb 03                	jmp    800846 <strnlen+0x13>
		n++;
  800843:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800846:	39 d0                	cmp    %edx,%eax
  800848:	74 06                	je     800850 <strnlen+0x1d>
  80084a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084e:	75 f3                	jne    800843 <strnlen+0x10>
	return n;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	83 c1 01             	add    $0x1,%ecx
  800861:	83 c2 01             	add    $0x1,%edx
  800864:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800868:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086b:	84 db                	test   %bl,%bl
  80086d:	75 ef                	jne    80085e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80086f:	5b                   	pop    %ebx
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800879:	53                   	push   %ebx
  80087a:	e8 9c ff ff ff       	call   80081b <strlen>
  80087f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800882:	ff 75 0c             	pushl  0xc(%ebp)
  800885:	01 d8                	add    %ebx,%eax
  800887:	50                   	push   %eax
  800888:	e8 c5 ff ff ff       	call   800852 <strcpy>
	return dst;
}
  80088d:	89 d8                	mov    %ebx,%eax
  80088f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 75 08             	mov    0x8(%ebp),%esi
  80089c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089f:	89 f3                	mov    %esi,%ebx
  8008a1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a4:	89 f2                	mov    %esi,%edx
  8008a6:	eb 0f                	jmp    8008b7 <strncpy+0x23>
		*dst++ = *src;
  8008a8:	83 c2 01             	add    $0x1,%edx
  8008ab:	0f b6 01             	movzbl (%ecx),%eax
  8008ae:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b1:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b4:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008b7:	39 da                	cmp    %ebx,%edx
  8008b9:	75 ed                	jne    8008a8 <strncpy+0x14>
	}
	return ret;
}
  8008bb:	89 f0                	mov    %esi,%eax
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
  8008c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008cf:	89 f0                	mov    %esi,%eax
  8008d1:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d5:	85 c9                	test   %ecx,%ecx
  8008d7:	75 0b                	jne    8008e4 <strlcpy+0x23>
  8008d9:	eb 17                	jmp    8008f2 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008db:	83 c2 01             	add    $0x1,%edx
  8008de:	83 c0 01             	add    $0x1,%eax
  8008e1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008e4:	39 d8                	cmp    %ebx,%eax
  8008e6:	74 07                	je     8008ef <strlcpy+0x2e>
  8008e8:	0f b6 0a             	movzbl (%edx),%ecx
  8008eb:	84 c9                	test   %cl,%cl
  8008ed:	75 ec                	jne    8008db <strlcpy+0x1a>
		*dst = '\0';
  8008ef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f2:	29 f0                	sub    %esi,%eax
}
  8008f4:	5b                   	pop    %ebx
  8008f5:	5e                   	pop    %esi
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800901:	eb 06                	jmp    800909 <strcmp+0x11>
		p++, q++;
  800903:	83 c1 01             	add    $0x1,%ecx
  800906:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800909:	0f b6 01             	movzbl (%ecx),%eax
  80090c:	84 c0                	test   %al,%al
  80090e:	74 04                	je     800914 <strcmp+0x1c>
  800910:	3a 02                	cmp    (%edx),%al
  800912:	74 ef                	je     800903 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800914:	0f b6 c0             	movzbl %al,%eax
  800917:	0f b6 12             	movzbl (%edx),%edx
  80091a:	29 d0                	sub    %edx,%eax
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	53                   	push   %ebx
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	8b 55 0c             	mov    0xc(%ebp),%edx
  800928:	89 c3                	mov    %eax,%ebx
  80092a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80092d:	eb 06                	jmp    800935 <strncmp+0x17>
		n--, p++, q++;
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800935:	39 d8                	cmp    %ebx,%eax
  800937:	74 16                	je     80094f <strncmp+0x31>
  800939:	0f b6 08             	movzbl (%eax),%ecx
  80093c:	84 c9                	test   %cl,%cl
  80093e:	74 04                	je     800944 <strncmp+0x26>
  800940:	3a 0a                	cmp    (%edx),%cl
  800942:	74 eb                	je     80092f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800944:	0f b6 00             	movzbl (%eax),%eax
  800947:	0f b6 12             	movzbl (%edx),%edx
  80094a:	29 d0                	sub    %edx,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    
		return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb f6                	jmp    80094c <strncmp+0x2e>

00800956 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800960:	0f b6 10             	movzbl (%eax),%edx
  800963:	84 d2                	test   %dl,%dl
  800965:	74 09                	je     800970 <strchr+0x1a>
		if (*s == c)
  800967:	38 ca                	cmp    %cl,%dl
  800969:	74 0a                	je     800975 <strchr+0x1f>
	for (; *s; s++)
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	eb f0                	jmp    800960 <strchr+0xa>
			return (char *) s;
	return 0;
  800970:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800981:	eb 03                	jmp    800986 <strfind+0xf>
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800989:	38 ca                	cmp    %cl,%dl
  80098b:	74 04                	je     800991 <strfind+0x1a>
  80098d:	84 d2                	test   %dl,%dl
  80098f:	75 f2                	jne    800983 <strfind+0xc>
			break;
	return (char *) s;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	57                   	push   %edi
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099f:	85 c9                	test   %ecx,%ecx
  8009a1:	74 13                	je     8009b6 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a9:	75 05                	jne    8009b0 <memset+0x1d>
  8009ab:	f6 c1 03             	test   $0x3,%cl
  8009ae:	74 0d                	je     8009bd <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b3:	fc                   	cld    
  8009b4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b6:	89 f8                	mov    %edi,%eax
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5f                   	pop    %edi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    
		c &= 0xFF;
  8009bd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c1:	89 d3                	mov    %edx,%ebx
  8009c3:	c1 e3 08             	shl    $0x8,%ebx
  8009c6:	89 d0                	mov    %edx,%eax
  8009c8:	c1 e0 18             	shl    $0x18,%eax
  8009cb:	89 d6                	mov    %edx,%esi
  8009cd:	c1 e6 10             	shl    $0x10,%esi
  8009d0:	09 f0                	or     %esi,%eax
  8009d2:	09 c2                	or     %eax,%edx
  8009d4:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009d9:	89 d0                	mov    %edx,%eax
  8009db:	fc                   	cld    
  8009dc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009de:	eb d6                	jmp    8009b6 <memset+0x23>

008009e0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ee:	39 c6                	cmp    %eax,%esi
  8009f0:	73 35                	jae    800a27 <memmove+0x47>
  8009f2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f5:	39 c2                	cmp    %eax,%edx
  8009f7:	76 2e                	jbe    800a27 <memmove+0x47>
		s += n;
		d += n;
  8009f9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fc:	89 d6                	mov    %edx,%esi
  8009fe:	09 fe                	or     %edi,%esi
  800a00:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a06:	74 0c                	je     800a14 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a08:	83 ef 01             	sub    $0x1,%edi
  800a0b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a0e:	fd                   	std    
  800a0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a11:	fc                   	cld    
  800a12:	eb 21                	jmp    800a35 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a14:	f6 c1 03             	test   $0x3,%cl
  800a17:	75 ef                	jne    800a08 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a19:	83 ef 04             	sub    $0x4,%edi
  800a1c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a22:	fd                   	std    
  800a23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a25:	eb ea                	jmp    800a11 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a27:	89 f2                	mov    %esi,%edx
  800a29:	09 c2                	or     %eax,%edx
  800a2b:	f6 c2 03             	test   $0x3,%dl
  800a2e:	74 09                	je     800a39 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a30:	89 c7                	mov    %eax,%edi
  800a32:	fc                   	cld    
  800a33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a35:	5e                   	pop    %esi
  800a36:	5f                   	pop    %edi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a39:	f6 c1 03             	test   $0x3,%cl
  800a3c:	75 f2                	jne    800a30 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a41:	89 c7                	mov    %eax,%edi
  800a43:	fc                   	cld    
  800a44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a46:	eb ed                	jmp    800a35 <memmove+0x55>

00800a48 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a4b:	ff 75 10             	pushl  0x10(%ebp)
  800a4e:	ff 75 0c             	pushl  0xc(%ebp)
  800a51:	ff 75 08             	pushl  0x8(%ebp)
  800a54:	e8 87 ff ff ff       	call   8009e0 <memmove>
}
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a66:	89 c6                	mov    %eax,%esi
  800a68:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6b:	39 f0                	cmp    %esi,%eax
  800a6d:	74 1c                	je     800a8b <memcmp+0x30>
		if (*s1 != *s2)
  800a6f:	0f b6 08             	movzbl (%eax),%ecx
  800a72:	0f b6 1a             	movzbl (%edx),%ebx
  800a75:	38 d9                	cmp    %bl,%cl
  800a77:	75 08                	jne    800a81 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a79:	83 c0 01             	add    $0x1,%eax
  800a7c:	83 c2 01             	add    $0x1,%edx
  800a7f:	eb ea                	jmp    800a6b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a81:	0f b6 c1             	movzbl %cl,%eax
  800a84:	0f b6 db             	movzbl %bl,%ebx
  800a87:	29 d8                	sub    %ebx,%eax
  800a89:	eb 05                	jmp    800a90 <memcmp+0x35>
	}

	return 0;
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9d:	89 c2                	mov    %eax,%edx
  800a9f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa2:	39 d0                	cmp    %edx,%eax
  800aa4:	73 09                	jae    800aaf <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa6:	38 08                	cmp    %cl,(%eax)
  800aa8:	74 05                	je     800aaf <memfind+0x1b>
	for (; s < ends; s++)
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	eb f3                	jmp    800aa2 <memfind+0xe>
			break;
	return (void *) s;
}
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abd:	eb 03                	jmp    800ac2 <strtol+0x11>
		s++;
  800abf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac2:	0f b6 01             	movzbl (%ecx),%eax
  800ac5:	3c 20                	cmp    $0x20,%al
  800ac7:	74 f6                	je     800abf <strtol+0xe>
  800ac9:	3c 09                	cmp    $0x9,%al
  800acb:	74 f2                	je     800abf <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800acd:	3c 2b                	cmp    $0x2b,%al
  800acf:	74 2e                	je     800aff <strtol+0x4e>
	int neg = 0;
  800ad1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad6:	3c 2d                	cmp    $0x2d,%al
  800ad8:	74 2f                	je     800b09 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae0:	75 05                	jne    800ae7 <strtol+0x36>
  800ae2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae5:	74 2c                	je     800b13 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae7:	85 db                	test   %ebx,%ebx
  800ae9:	75 0a                	jne    800af5 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aeb:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800af0:	80 39 30             	cmpb   $0x30,(%ecx)
  800af3:	74 28                	je     800b1d <strtol+0x6c>
		base = 10;
  800af5:	b8 00 00 00 00       	mov    $0x0,%eax
  800afa:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800afd:	eb 50                	jmp    800b4f <strtol+0x9e>
		s++;
  800aff:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b02:	bf 00 00 00 00       	mov    $0x0,%edi
  800b07:	eb d1                	jmp    800ada <strtol+0x29>
		s++, neg = 1;
  800b09:	83 c1 01             	add    $0x1,%ecx
  800b0c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b11:	eb c7                	jmp    800ada <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b13:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b17:	74 0e                	je     800b27 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b19:	85 db                	test   %ebx,%ebx
  800b1b:	75 d8                	jne    800af5 <strtol+0x44>
		s++, base = 8;
  800b1d:	83 c1 01             	add    $0x1,%ecx
  800b20:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b25:	eb ce                	jmp    800af5 <strtol+0x44>
		s += 2, base = 16;
  800b27:	83 c1 02             	add    $0x2,%ecx
  800b2a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b2f:	eb c4                	jmp    800af5 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b31:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b34:	89 f3                	mov    %esi,%ebx
  800b36:	80 fb 19             	cmp    $0x19,%bl
  800b39:	77 29                	ja     800b64 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b3b:	0f be d2             	movsbl %dl,%edx
  800b3e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b41:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b44:	7d 30                	jge    800b76 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b46:	83 c1 01             	add    $0x1,%ecx
  800b49:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b4f:	0f b6 11             	movzbl (%ecx),%edx
  800b52:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b55:	89 f3                	mov    %esi,%ebx
  800b57:	80 fb 09             	cmp    $0x9,%bl
  800b5a:	77 d5                	ja     800b31 <strtol+0x80>
			dig = *s - '0';
  800b5c:	0f be d2             	movsbl %dl,%edx
  800b5f:	83 ea 30             	sub    $0x30,%edx
  800b62:	eb dd                	jmp    800b41 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b64:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b67:	89 f3                	mov    %esi,%ebx
  800b69:	80 fb 19             	cmp    $0x19,%bl
  800b6c:	77 08                	ja     800b76 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b6e:	0f be d2             	movsbl %dl,%edx
  800b71:	83 ea 37             	sub    $0x37,%edx
  800b74:	eb cb                	jmp    800b41 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7a:	74 05                	je     800b81 <strtol+0xd0>
		*endptr = (char *) s;
  800b7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b81:	89 c2                	mov    %eax,%edx
  800b83:	f7 da                	neg    %edx
  800b85:	85 ff                	test   %edi,%edi
  800b87:	0f 45 c2             	cmovne %edx,%eax
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba0:	89 c3                	mov    %eax,%ebx
  800ba2:	89 c7                	mov    %eax,%edi
  800ba4:	89 c6                	mov    %eax,%esi
  800ba6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <sys_cgetc>:

int
sys_cgetc(void)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbd:	89 d1                	mov    %edx,%ecx
  800bbf:	89 d3                	mov    %edx,%ebx
  800bc1:	89 d7                	mov    %edx,%edi
  800bc3:	89 d6                	mov    %edx,%esi
  800bc5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	b8 03 00 00 00       	mov    $0x3,%eax
  800be2:	89 cb                	mov    %ecx,%ebx
  800be4:	89 cf                	mov    %ecx,%edi
  800be6:	89 ce                	mov    %ecx,%esi
  800be8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	7f 08                	jg     800bf6 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf6:	83 ec 0c             	sub    $0xc,%esp
  800bf9:	50                   	push   %eax
  800bfa:	6a 03                	push   $0x3
  800bfc:	68 1f 25 80 00       	push   $0x80251f
  800c01:	6a 23                	push   $0x23
  800c03:	68 3c 25 80 00       	push   $0x80253c
  800c08:	e8 4b f5 ff ff       	call   800158 <_panic>

00800c0d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c13:	ba 00 00 00 00       	mov    $0x0,%edx
  800c18:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1d:	89 d1                	mov    %edx,%ecx
  800c1f:	89 d3                	mov    %edx,%ebx
  800c21:	89 d7                	mov    %edx,%edi
  800c23:	89 d6                	mov    %edx,%esi
  800c25:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_yield>:

void
sys_yield(void)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3c:	89 d1                	mov    %edx,%ecx
  800c3e:	89 d3                	mov    %edx,%ebx
  800c40:	89 d7                	mov    %edx,%edi
  800c42:	89 d6                	mov    %edx,%esi
  800c44:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c54:	be 00 00 00 00       	mov    $0x0,%esi
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c67:	89 f7                	mov    %esi,%edi
  800c69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7f 08                	jg     800c77 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	50                   	push   %eax
  800c7b:	6a 04                	push   $0x4
  800c7d:	68 1f 25 80 00       	push   $0x80251f
  800c82:	6a 23                	push   $0x23
  800c84:	68 3c 25 80 00       	push   $0x80253c
  800c89:	e8 ca f4 ff ff       	call   800158 <_panic>

00800c8e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca8:	8b 75 18             	mov    0x18(%ebp),%esi
  800cab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7f 08                	jg     800cb9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 05                	push   $0x5
  800cbf:	68 1f 25 80 00       	push   $0x80251f
  800cc4:	6a 23                	push   $0x23
  800cc6:	68 3c 25 80 00       	push   $0x80253c
  800ccb:	e8 88 f4 ff ff       	call   800158 <_panic>

00800cd0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce9:	89 df                	mov    %ebx,%edi
  800ceb:	89 de                	mov    %ebx,%esi
  800ced:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7f 08                	jg     800cfb <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	50                   	push   %eax
  800cff:	6a 06                	push   $0x6
  800d01:	68 1f 25 80 00       	push   $0x80251f
  800d06:	6a 23                	push   $0x23
  800d08:	68 3c 25 80 00       	push   $0x80253c
  800d0d:	e8 46 f4 ff ff       	call   800158 <_panic>

00800d12 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2b:	89 df                	mov    %ebx,%edi
  800d2d:	89 de                	mov    %ebx,%esi
  800d2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7f 08                	jg     800d3d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	50                   	push   %eax
  800d41:	6a 08                	push   $0x8
  800d43:	68 1f 25 80 00       	push   $0x80251f
  800d48:	6a 23                	push   $0x23
  800d4a:	68 3c 25 80 00       	push   $0x80253c
  800d4f:	e8 04 f4 ff ff       	call   800158 <_panic>

00800d54 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6d:	89 df                	mov    %ebx,%edi
  800d6f:	89 de                	mov    %ebx,%esi
  800d71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7f 08                	jg     800d7f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	50                   	push   %eax
  800d83:	6a 09                	push   $0x9
  800d85:	68 1f 25 80 00       	push   $0x80251f
  800d8a:	6a 23                	push   $0x23
  800d8c:	68 3c 25 80 00       	push   $0x80253c
  800d91:	e8 c2 f3 ff ff       	call   800158 <_panic>

00800d96 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800daf:	89 df                	mov    %ebx,%edi
  800db1:	89 de                	mov    %ebx,%esi
  800db3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db5:	85 c0                	test   %eax,%eax
  800db7:	7f 08                	jg     800dc1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	50                   	push   %eax
  800dc5:	6a 0a                	push   $0xa
  800dc7:	68 1f 25 80 00       	push   $0x80251f
  800dcc:	6a 23                	push   $0x23
  800dce:	68 3c 25 80 00       	push   $0x80253c
  800dd3:	e8 80 f3 ff ff       	call   800158 <_panic>

00800dd8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de9:	be 00 00 00 00       	mov    $0x0,%esi
  800dee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e11:	89 cb                	mov    %ecx,%ebx
  800e13:	89 cf                	mov    %ecx,%edi
  800e15:	89 ce                	mov    %ecx,%esi
  800e17:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7f 08                	jg     800e25 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	50                   	push   %eax
  800e29:	6a 0d                	push   $0xd
  800e2b:	68 1f 25 80 00       	push   $0x80251f
  800e30:	6a 23                	push   $0x23
  800e32:	68 3c 25 80 00       	push   $0x80253c
  800e37:	e8 1c f3 ff ff       	call   800158 <_panic>

00800e3c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 04             	sub    $0x4,%esp
  800e43:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e46:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e48:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e4c:	0f 84 9c 00 00 00    	je     800eee <pgfault+0xb2>
  800e52:	89 c2                	mov    %eax,%edx
  800e54:	c1 ea 16             	shr    $0x16,%edx
  800e57:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e5e:	f6 c2 01             	test   $0x1,%dl
  800e61:	0f 84 87 00 00 00    	je     800eee <pgfault+0xb2>
  800e67:	89 c2                	mov    %eax,%edx
  800e69:	c1 ea 0c             	shr    $0xc,%edx
  800e6c:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e73:	f6 c1 01             	test   $0x1,%cl
  800e76:	74 76                	je     800eee <pgfault+0xb2>
  800e78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7f:	f6 c6 08             	test   $0x8,%dh
  800e82:	74 6a                	je     800eee <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  800e84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e89:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	6a 07                	push   $0x7
  800e90:	68 00 f0 7f 00       	push   $0x7ff000
  800e95:	6a 00                	push   $0x0
  800e97:	e8 af fd ff ff       	call   800c4b <sys_page_alloc>
  800e9c:	83 c4 10             	add    $0x10,%esp
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	78 5f                	js     800f02 <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  800ea3:	83 ec 04             	sub    $0x4,%esp
  800ea6:	68 00 10 00 00       	push   $0x1000
  800eab:	53                   	push   %ebx
  800eac:	68 00 f0 7f 00       	push   $0x7ff000
  800eb1:	e8 92 fb ff ff       	call   800a48 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800eb6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ebd:	53                   	push   %ebx
  800ebe:	6a 00                	push   $0x0
  800ec0:	68 00 f0 7f 00       	push   $0x7ff000
  800ec5:	6a 00                	push   $0x0
  800ec7:	e8 c2 fd ff ff       	call   800c8e <sys_page_map>
  800ecc:	83 c4 20             	add    $0x20,%esp
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	78 43                	js     800f16 <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	68 00 f0 7f 00       	push   $0x7ff000
  800edb:	6a 00                	push   $0x0
  800edd:	e8 ee fd ff ff       	call   800cd0 <sys_page_unmap>
  800ee2:	83 c4 10             	add    $0x10,%esp
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	78 41                	js     800f2a <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  800ee9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    
		panic("not copy-on-write");
  800eee:	83 ec 04             	sub    $0x4,%esp
  800ef1:	68 4a 25 80 00       	push   $0x80254a
  800ef6:	6a 25                	push   $0x25
  800ef8:	68 5c 25 80 00       	push   $0x80255c
  800efd:	e8 56 f2 ff ff       	call   800158 <_panic>
		panic("sys_page_alloc");
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	68 67 25 80 00       	push   $0x802567
  800f0a:	6a 28                	push   $0x28
  800f0c:	68 5c 25 80 00       	push   $0x80255c
  800f11:	e8 42 f2 ff ff       	call   800158 <_panic>
		panic("sys_page_map");
  800f16:	83 ec 04             	sub    $0x4,%esp
  800f19:	68 76 25 80 00       	push   $0x802576
  800f1e:	6a 2b                	push   $0x2b
  800f20:	68 5c 25 80 00       	push   $0x80255c
  800f25:	e8 2e f2 ff ff       	call   800158 <_panic>
		panic("sys_page_unmap");
  800f2a:	83 ec 04             	sub    $0x4,%esp
  800f2d:	68 83 25 80 00       	push   $0x802583
  800f32:	6a 2d                	push   $0x2d
  800f34:	68 5c 25 80 00       	push   $0x80255c
  800f39:	e8 1a f2 ff ff       	call   800158 <_panic>

00800f3e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f47:	68 3c 0e 80 00       	push   $0x800e3c
  800f4c:	e8 7f 0f 00 00       	call   801ed0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f51:	b8 07 00 00 00       	mov    $0x7,%eax
  800f56:	cd 30                	int    $0x30
  800f58:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	74 12                	je     800f74 <fork+0x36>
  800f62:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  800f64:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f68:	78 26                	js     800f90 <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6f:	e9 94 00 00 00       	jmp    801008 <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f74:	e8 94 fc ff ff       	call   800c0d <sys_getenvid>
  800f79:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f81:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f86:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f8b:	e9 51 01 00 00       	jmp    8010e1 <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  800f90:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f93:	68 92 25 80 00       	push   $0x802592
  800f98:	6a 6e                	push   $0x6e
  800f9a:	68 5c 25 80 00       	push   $0x80255c
  800f9f:	e8 b4 f1 ff ff       	call   800158 <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800fa4:	83 ec 0c             	sub    $0xc,%esp
  800fa7:	68 07 0e 00 00       	push   $0xe07
  800fac:	56                   	push   %esi
  800fad:	57                   	push   %edi
  800fae:	56                   	push   %esi
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 d8 fc ff ff       	call   800c8e <sys_page_map>
  800fb6:	83 c4 20             	add    $0x20,%esp
  800fb9:	eb 3b                	jmp    800ff6 <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800fbb:	83 ec 0c             	sub    $0xc,%esp
  800fbe:	68 05 08 00 00       	push   $0x805
  800fc3:	56                   	push   %esi
  800fc4:	57                   	push   %edi
  800fc5:	56                   	push   %esi
  800fc6:	6a 00                	push   $0x0
  800fc8:	e8 c1 fc ff ff       	call   800c8e <sys_page_map>
  800fcd:	83 c4 20             	add    $0x20,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	0f 88 a9 00 00 00    	js     801081 <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800fd8:	83 ec 0c             	sub    $0xc,%esp
  800fdb:	68 05 08 00 00       	push   $0x805
  800fe0:	56                   	push   %esi
  800fe1:	6a 00                	push   $0x0
  800fe3:	56                   	push   %esi
  800fe4:	6a 00                	push   $0x0
  800fe6:	e8 a3 fc ff ff       	call   800c8e <sys_page_map>
  800feb:	83 c4 20             	add    $0x20,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	0f 88 9d 00 00 00    	js     801093 <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800ff6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ffc:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801002:	0f 84 9d 00 00 00    	je     8010a5 <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801008:	89 d8                	mov    %ebx,%eax
  80100a:	c1 e8 16             	shr    $0x16,%eax
  80100d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801014:	a8 01                	test   $0x1,%al
  801016:	74 de                	je     800ff6 <fork+0xb8>
  801018:	89 d8                	mov    %ebx,%eax
  80101a:	c1 e8 0c             	shr    $0xc,%eax
  80101d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801024:	f6 c2 01             	test   $0x1,%dl
  801027:	74 cd                	je     800ff6 <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801029:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801030:	f6 c2 04             	test   $0x4,%dl
  801033:	74 c1                	je     800ff6 <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  801035:	89 c6                	mov    %eax,%esi
  801037:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  80103a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801041:	f6 c6 04             	test   $0x4,%dh
  801044:	0f 85 5a ff ff ff    	jne    800fa4 <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  80104a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801051:	f6 c2 02             	test   $0x2,%dl
  801054:	0f 85 61 ff ff ff    	jne    800fbb <fork+0x7d>
  80105a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801061:	f6 c4 08             	test   $0x8,%ah
  801064:	0f 85 51 ff ff ff    	jne    800fbb <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	6a 05                	push   $0x5
  80106f:	56                   	push   %esi
  801070:	57                   	push   %edi
  801071:	56                   	push   %esi
  801072:	6a 00                	push   $0x0
  801074:	e8 15 fc ff ff       	call   800c8e <sys_page_map>
  801079:	83 c4 20             	add    $0x20,%esp
  80107c:	e9 75 ff ff ff       	jmp    800ff6 <fork+0xb8>
            		panic("sys_page_map：%e", r);
  801081:	50                   	push   %eax
  801082:	68 a2 25 80 00       	push   $0x8025a2
  801087:	6a 47                	push   $0x47
  801089:	68 5c 25 80 00       	push   $0x80255c
  80108e:	e8 c5 f0 ff ff       	call   800158 <_panic>
            		panic("sys_page_map：%e", r);
  801093:	50                   	push   %eax
  801094:	68 a2 25 80 00       	push   $0x8025a2
  801099:	6a 49                	push   $0x49
  80109b:	68 5c 25 80 00       	push   $0x80255c
  8010a0:	e8 b3 f0 ff ff       	call   800158 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	6a 07                	push   $0x7
  8010aa:	68 00 f0 bf ee       	push   $0xeebff000
  8010af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b2:	e8 94 fb ff ff       	call   800c4b <sys_page_alloc>
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	78 2e                	js     8010ec <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010be:	83 ec 08             	sub    $0x8,%esp
  8010c1:	68 3f 1f 80 00       	push   $0x801f3f
  8010c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010c9:	57                   	push   %edi
  8010ca:	e8 c7 fc ff ff       	call   800d96 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8010cf:	83 c4 08             	add    $0x8,%esp
  8010d2:	6a 02                	push   $0x2
  8010d4:	57                   	push   %edi
  8010d5:	e8 38 fc ff ff       	call   800d12 <sys_env_set_status>
  8010da:	83 c4 10             	add    $0x10,%esp
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	78 1f                	js     801100 <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  8010e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e7:	5b                   	pop    %ebx
  8010e8:	5e                   	pop    %esi
  8010e9:	5f                   	pop    %edi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    
		panic("1");
  8010ec:	83 ec 04             	sub    $0x4,%esp
  8010ef:	68 b4 25 80 00       	push   $0x8025b4
  8010f4:	6a 77                	push   $0x77
  8010f6:	68 5c 25 80 00       	push   $0x80255c
  8010fb:	e8 58 f0 ff ff       	call   800158 <_panic>
		panic("sys_env_set_status");
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	68 b6 25 80 00       	push   $0x8025b6
  801108:	6a 7c                	push   $0x7c
  80110a:	68 5c 25 80 00       	push   $0x80255c
  80110f:	e8 44 f0 ff ff       	call   800158 <_panic>

00801114 <sfork>:

// Challenge!
int
sfork(void)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80111a:	68 c9 25 80 00       	push   $0x8025c9
  80111f:	68 86 00 00 00       	push   $0x86
  801124:	68 5c 25 80 00       	push   $0x80255c
  801129:	e8 2a f0 ff ff       	call   800158 <_panic>

0080112e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	56                   	push   %esi
  801132:	53                   	push   %ebx
  801133:	8b 75 08             	mov    0x8(%ebp),%esi
  801136:	8b 45 0c             	mov    0xc(%ebp),%eax
  801139:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  80113c:	85 f6                	test   %esi,%esi
  80113e:	74 06                	je     801146 <ipc_recv+0x18>
  801140:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801146:	85 db                	test   %ebx,%ebx
  801148:	74 06                	je     801150 <ipc_recv+0x22>
  80114a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801150:	85 c0                	test   %eax,%eax
  801152:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801157:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  80115a:	83 ec 0c             	sub    $0xc,%esp
  80115d:	50                   	push   %eax
  80115e:	e8 98 fc ff ff       	call   800dfb <sys_ipc_recv>
	if (ret) return ret;
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	85 c0                	test   %eax,%eax
  801168:	75 24                	jne    80118e <ipc_recv+0x60>
	if (from_env_store)
  80116a:	85 f6                	test   %esi,%esi
  80116c:	74 0a                	je     801178 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  80116e:	a1 04 40 80 00       	mov    0x804004,%eax
  801173:	8b 40 74             	mov    0x74(%eax),%eax
  801176:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801178:	85 db                	test   %ebx,%ebx
  80117a:	74 0a                	je     801186 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  80117c:	a1 04 40 80 00       	mov    0x804004,%eax
  801181:	8b 40 78             	mov    0x78(%eax),%eax
  801184:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801186:	a1 04 40 80 00       	mov    0x804004,%eax
  80118b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80118e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5d                   	pop    %ebp
  801194:	c3                   	ret    

00801195 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	57                   	push   %edi
  801199:	56                   	push   %esi
  80119a:	53                   	push   %ebx
  80119b:	83 ec 0c             	sub    $0xc,%esp
  80119e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8011a7:	85 db                	test   %ebx,%ebx
  8011a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011ae:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8011b1:	ff 75 14             	pushl  0x14(%ebp)
  8011b4:	53                   	push   %ebx
  8011b5:	56                   	push   %esi
  8011b6:	57                   	push   %edi
  8011b7:	e8 1c fc ff ff       	call   800dd8 <sys_ipc_try_send>
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	74 1e                	je     8011e1 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8011c3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011c6:	75 07                	jne    8011cf <ipc_send+0x3a>
		sys_yield();
  8011c8:	e8 5f fa ff ff       	call   800c2c <sys_yield>
  8011cd:	eb e2                	jmp    8011b1 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8011cf:	50                   	push   %eax
  8011d0:	68 df 25 80 00       	push   $0x8025df
  8011d5:	6a 36                	push   $0x36
  8011d7:	68 f6 25 80 00       	push   $0x8025f6
  8011dc:	e8 77 ef ff ff       	call   800158 <_panic>
	}
}
  8011e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5e                   	pop    %esi
  8011e6:	5f                   	pop    %edi
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011ef:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011f4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011f7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011fd:	8b 52 50             	mov    0x50(%edx),%edx
  801200:	39 ca                	cmp    %ecx,%edx
  801202:	74 11                	je     801215 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801204:	83 c0 01             	add    $0x1,%eax
  801207:	3d 00 04 00 00       	cmp    $0x400,%eax
  80120c:	75 e6                	jne    8011f4 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80120e:	b8 00 00 00 00       	mov    $0x0,%eax
  801213:	eb 0b                	jmp    801220 <ipc_find_env+0x37>
			return envs[i].env_id;
  801215:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801218:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80121d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    

00801222 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801225:	8b 45 08             	mov    0x8(%ebp),%eax
  801228:	05 00 00 00 30       	add    $0x30000000,%eax
  80122d:	c1 e8 0c             	shr    $0xc,%eax
}
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801235:	8b 45 08             	mov    0x8(%ebp),%eax
  801238:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80123d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801242:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801254:	89 c2                	mov    %eax,%edx
  801256:	c1 ea 16             	shr    $0x16,%edx
  801259:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801260:	f6 c2 01             	test   $0x1,%dl
  801263:	74 2a                	je     80128f <fd_alloc+0x46>
  801265:	89 c2                	mov    %eax,%edx
  801267:	c1 ea 0c             	shr    $0xc,%edx
  80126a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801271:	f6 c2 01             	test   $0x1,%dl
  801274:	74 19                	je     80128f <fd_alloc+0x46>
  801276:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80127b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801280:	75 d2                	jne    801254 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801282:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801288:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80128d:	eb 07                	jmp    801296 <fd_alloc+0x4d>
			*fd_store = fd;
  80128f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80129e:	83 f8 1f             	cmp    $0x1f,%eax
  8012a1:	77 36                	ja     8012d9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012a3:	c1 e0 0c             	shl    $0xc,%eax
  8012a6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ab:	89 c2                	mov    %eax,%edx
  8012ad:	c1 ea 16             	shr    $0x16,%edx
  8012b0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b7:	f6 c2 01             	test   $0x1,%dl
  8012ba:	74 24                	je     8012e0 <fd_lookup+0x48>
  8012bc:	89 c2                	mov    %eax,%edx
  8012be:	c1 ea 0c             	shr    $0xc,%edx
  8012c1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c8:	f6 c2 01             	test   $0x1,%dl
  8012cb:	74 1a                	je     8012e7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d0:	89 02                	mov    %eax,(%edx)
	return 0;
  8012d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    
		return -E_INVAL;
  8012d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012de:	eb f7                	jmp    8012d7 <fd_lookup+0x3f>
		return -E_INVAL;
  8012e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e5:	eb f0                	jmp    8012d7 <fd_lookup+0x3f>
  8012e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ec:	eb e9                	jmp    8012d7 <fd_lookup+0x3f>

008012ee <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f7:	ba 7c 26 80 00       	mov    $0x80267c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012fc:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801301:	39 08                	cmp    %ecx,(%eax)
  801303:	74 33                	je     801338 <dev_lookup+0x4a>
  801305:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801308:	8b 02                	mov    (%edx),%eax
  80130a:	85 c0                	test   %eax,%eax
  80130c:	75 f3                	jne    801301 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80130e:	a1 04 40 80 00       	mov    0x804004,%eax
  801313:	8b 40 48             	mov    0x48(%eax),%eax
  801316:	83 ec 04             	sub    $0x4,%esp
  801319:	51                   	push   %ecx
  80131a:	50                   	push   %eax
  80131b:	68 00 26 80 00       	push   $0x802600
  801320:	e8 0e ef ff ff       	call   800233 <cprintf>
	*dev = 0;
  801325:	8b 45 0c             	mov    0xc(%ebp),%eax
  801328:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801336:	c9                   	leave  
  801337:	c3                   	ret    
			*dev = devtab[i];
  801338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80133d:	b8 00 00 00 00       	mov    $0x0,%eax
  801342:	eb f2                	jmp    801336 <dev_lookup+0x48>

00801344 <fd_close>:
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	57                   	push   %edi
  801348:	56                   	push   %esi
  801349:	53                   	push   %ebx
  80134a:	83 ec 1c             	sub    $0x1c,%esp
  80134d:	8b 75 08             	mov    0x8(%ebp),%esi
  801350:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801353:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801356:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801357:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80135d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801360:	50                   	push   %eax
  801361:	e8 32 ff ff ff       	call   801298 <fd_lookup>
  801366:	89 c3                	mov    %eax,%ebx
  801368:	83 c4 08             	add    $0x8,%esp
  80136b:	85 c0                	test   %eax,%eax
  80136d:	78 05                	js     801374 <fd_close+0x30>
	    || fd != fd2)
  80136f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801372:	74 16                	je     80138a <fd_close+0x46>
		return (must_exist ? r : 0);
  801374:	89 f8                	mov    %edi,%eax
  801376:	84 c0                	test   %al,%al
  801378:	b8 00 00 00 00       	mov    $0x0,%eax
  80137d:	0f 44 d8             	cmove  %eax,%ebx
}
  801380:	89 d8                	mov    %ebx,%eax
  801382:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801385:	5b                   	pop    %ebx
  801386:	5e                   	pop    %esi
  801387:	5f                   	pop    %edi
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801390:	50                   	push   %eax
  801391:	ff 36                	pushl  (%esi)
  801393:	e8 56 ff ff ff       	call   8012ee <dev_lookup>
  801398:	89 c3                	mov    %eax,%ebx
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 15                	js     8013b6 <fd_close+0x72>
		if (dev->dev_close)
  8013a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013a4:	8b 40 10             	mov    0x10(%eax),%eax
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	74 1b                	je     8013c6 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8013ab:	83 ec 0c             	sub    $0xc,%esp
  8013ae:	56                   	push   %esi
  8013af:	ff d0                	call   *%eax
  8013b1:	89 c3                	mov    %eax,%ebx
  8013b3:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	56                   	push   %esi
  8013ba:	6a 00                	push   $0x0
  8013bc:	e8 0f f9 ff ff       	call   800cd0 <sys_page_unmap>
	return r;
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	eb ba                	jmp    801380 <fd_close+0x3c>
			r = 0;
  8013c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013cb:	eb e9                	jmp    8013b6 <fd_close+0x72>

008013cd <close>:

int
close(int fdnum)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d6:	50                   	push   %eax
  8013d7:	ff 75 08             	pushl  0x8(%ebp)
  8013da:	e8 b9 fe ff ff       	call   801298 <fd_lookup>
  8013df:	83 c4 08             	add    $0x8,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	78 10                	js     8013f6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	6a 01                	push   $0x1
  8013eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ee:	e8 51 ff ff ff       	call   801344 <fd_close>
  8013f3:	83 c4 10             	add    $0x10,%esp
}
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <close_all>:

void
close_all(void)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	53                   	push   %ebx
  8013fc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ff:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801404:	83 ec 0c             	sub    $0xc,%esp
  801407:	53                   	push   %ebx
  801408:	e8 c0 ff ff ff       	call   8013cd <close>
	for (i = 0; i < MAXFD; i++)
  80140d:	83 c3 01             	add    $0x1,%ebx
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	83 fb 20             	cmp    $0x20,%ebx
  801416:	75 ec                	jne    801404 <close_all+0xc>
}
  801418:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141b:	c9                   	leave  
  80141c:	c3                   	ret    

0080141d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	57                   	push   %edi
  801421:	56                   	push   %esi
  801422:	53                   	push   %ebx
  801423:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801426:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801429:	50                   	push   %eax
  80142a:	ff 75 08             	pushl  0x8(%ebp)
  80142d:	e8 66 fe ff ff       	call   801298 <fd_lookup>
  801432:	89 c3                	mov    %eax,%ebx
  801434:	83 c4 08             	add    $0x8,%esp
  801437:	85 c0                	test   %eax,%eax
  801439:	0f 88 81 00 00 00    	js     8014c0 <dup+0xa3>
		return r;
	close(newfdnum);
  80143f:	83 ec 0c             	sub    $0xc,%esp
  801442:	ff 75 0c             	pushl  0xc(%ebp)
  801445:	e8 83 ff ff ff       	call   8013cd <close>

	newfd = INDEX2FD(newfdnum);
  80144a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80144d:	c1 e6 0c             	shl    $0xc,%esi
  801450:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801456:	83 c4 04             	add    $0x4,%esp
  801459:	ff 75 e4             	pushl  -0x1c(%ebp)
  80145c:	e8 d1 fd ff ff       	call   801232 <fd2data>
  801461:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801463:	89 34 24             	mov    %esi,(%esp)
  801466:	e8 c7 fd ff ff       	call   801232 <fd2data>
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801470:	89 d8                	mov    %ebx,%eax
  801472:	c1 e8 16             	shr    $0x16,%eax
  801475:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80147c:	a8 01                	test   $0x1,%al
  80147e:	74 11                	je     801491 <dup+0x74>
  801480:	89 d8                	mov    %ebx,%eax
  801482:	c1 e8 0c             	shr    $0xc,%eax
  801485:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80148c:	f6 c2 01             	test   $0x1,%dl
  80148f:	75 39                	jne    8014ca <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801491:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801494:	89 d0                	mov    %edx,%eax
  801496:	c1 e8 0c             	shr    $0xc,%eax
  801499:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a0:	83 ec 0c             	sub    $0xc,%esp
  8014a3:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a8:	50                   	push   %eax
  8014a9:	56                   	push   %esi
  8014aa:	6a 00                	push   $0x0
  8014ac:	52                   	push   %edx
  8014ad:	6a 00                	push   $0x0
  8014af:	e8 da f7 ff ff       	call   800c8e <sys_page_map>
  8014b4:	89 c3                	mov    %eax,%ebx
  8014b6:	83 c4 20             	add    $0x20,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 31                	js     8014ee <dup+0xd1>
		goto err;

	return newfdnum;
  8014bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014c0:	89 d8                	mov    %ebx,%eax
  8014c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c5:	5b                   	pop    %ebx
  8014c6:	5e                   	pop    %esi
  8014c7:	5f                   	pop    %edi
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d1:	83 ec 0c             	sub    $0xc,%esp
  8014d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d9:	50                   	push   %eax
  8014da:	57                   	push   %edi
  8014db:	6a 00                	push   $0x0
  8014dd:	53                   	push   %ebx
  8014de:	6a 00                	push   $0x0
  8014e0:	e8 a9 f7 ff ff       	call   800c8e <sys_page_map>
  8014e5:	89 c3                	mov    %eax,%ebx
  8014e7:	83 c4 20             	add    $0x20,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	79 a3                	jns    801491 <dup+0x74>
	sys_page_unmap(0, newfd);
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	56                   	push   %esi
  8014f2:	6a 00                	push   $0x0
  8014f4:	e8 d7 f7 ff ff       	call   800cd0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014f9:	83 c4 08             	add    $0x8,%esp
  8014fc:	57                   	push   %edi
  8014fd:	6a 00                	push   $0x0
  8014ff:	e8 cc f7 ff ff       	call   800cd0 <sys_page_unmap>
	return r;
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	eb b7                	jmp    8014c0 <dup+0xa3>

00801509 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	53                   	push   %ebx
  80150d:	83 ec 14             	sub    $0x14,%esp
  801510:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801513:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801516:	50                   	push   %eax
  801517:	53                   	push   %ebx
  801518:	e8 7b fd ff ff       	call   801298 <fd_lookup>
  80151d:	83 c4 08             	add    $0x8,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	78 3f                	js     801563 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152e:	ff 30                	pushl  (%eax)
  801530:	e8 b9 fd ff ff       	call   8012ee <dev_lookup>
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 27                	js     801563 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80153c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80153f:	8b 42 08             	mov    0x8(%edx),%eax
  801542:	83 e0 03             	and    $0x3,%eax
  801545:	83 f8 01             	cmp    $0x1,%eax
  801548:	74 1e                	je     801568 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80154a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154d:	8b 40 08             	mov    0x8(%eax),%eax
  801550:	85 c0                	test   %eax,%eax
  801552:	74 35                	je     801589 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	ff 75 10             	pushl  0x10(%ebp)
  80155a:	ff 75 0c             	pushl  0xc(%ebp)
  80155d:	52                   	push   %edx
  80155e:	ff d0                	call   *%eax
  801560:	83 c4 10             	add    $0x10,%esp
}
  801563:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801566:	c9                   	leave  
  801567:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801568:	a1 04 40 80 00       	mov    0x804004,%eax
  80156d:	8b 40 48             	mov    0x48(%eax),%eax
  801570:	83 ec 04             	sub    $0x4,%esp
  801573:	53                   	push   %ebx
  801574:	50                   	push   %eax
  801575:	68 41 26 80 00       	push   $0x802641
  80157a:	e8 b4 ec ff ff       	call   800233 <cprintf>
		return -E_INVAL;
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801587:	eb da                	jmp    801563 <read+0x5a>
		return -E_NOT_SUPP;
  801589:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80158e:	eb d3                	jmp    801563 <read+0x5a>

00801590 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	57                   	push   %edi
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	83 ec 0c             	sub    $0xc,%esp
  801599:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a4:	39 f3                	cmp    %esi,%ebx
  8015a6:	73 25                	jae    8015cd <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a8:	83 ec 04             	sub    $0x4,%esp
  8015ab:	89 f0                	mov    %esi,%eax
  8015ad:	29 d8                	sub    %ebx,%eax
  8015af:	50                   	push   %eax
  8015b0:	89 d8                	mov    %ebx,%eax
  8015b2:	03 45 0c             	add    0xc(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	57                   	push   %edi
  8015b7:	e8 4d ff ff ff       	call   801509 <read>
		if (m < 0)
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 08                	js     8015cb <readn+0x3b>
			return m;
		if (m == 0)
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	74 06                	je     8015cd <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8015c7:	01 c3                	add    %eax,%ebx
  8015c9:	eb d9                	jmp    8015a4 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015cb:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015cd:	89 d8                	mov    %ebx,%eax
  8015cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d2:	5b                   	pop    %ebx
  8015d3:	5e                   	pop    %esi
  8015d4:	5f                   	pop    %edi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	53                   	push   %ebx
  8015db:	83 ec 14             	sub    $0x14,%esp
  8015de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	53                   	push   %ebx
  8015e6:	e8 ad fc ff ff       	call   801298 <fd_lookup>
  8015eb:	83 c4 08             	add    $0x8,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 3a                	js     80162c <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f2:	83 ec 08             	sub    $0x8,%esp
  8015f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fc:	ff 30                	pushl  (%eax)
  8015fe:	e8 eb fc ff ff       	call   8012ee <dev_lookup>
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	85 c0                	test   %eax,%eax
  801608:	78 22                	js     80162c <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801611:	74 1e                	je     801631 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801613:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801616:	8b 52 0c             	mov    0xc(%edx),%edx
  801619:	85 d2                	test   %edx,%edx
  80161b:	74 35                	je     801652 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80161d:	83 ec 04             	sub    $0x4,%esp
  801620:	ff 75 10             	pushl  0x10(%ebp)
  801623:	ff 75 0c             	pushl  0xc(%ebp)
  801626:	50                   	push   %eax
  801627:	ff d2                	call   *%edx
  801629:	83 c4 10             	add    $0x10,%esp
}
  80162c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162f:	c9                   	leave  
  801630:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801631:	a1 04 40 80 00       	mov    0x804004,%eax
  801636:	8b 40 48             	mov    0x48(%eax),%eax
  801639:	83 ec 04             	sub    $0x4,%esp
  80163c:	53                   	push   %ebx
  80163d:	50                   	push   %eax
  80163e:	68 5d 26 80 00       	push   $0x80265d
  801643:	e8 eb eb ff ff       	call   800233 <cprintf>
		return -E_INVAL;
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801650:	eb da                	jmp    80162c <write+0x55>
		return -E_NOT_SUPP;
  801652:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801657:	eb d3                	jmp    80162c <write+0x55>

00801659 <seek>:

int
seek(int fdnum, off_t offset)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80165f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801662:	50                   	push   %eax
  801663:	ff 75 08             	pushl  0x8(%ebp)
  801666:	e8 2d fc ff ff       	call   801298 <fd_lookup>
  80166b:	83 c4 08             	add    $0x8,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 0e                	js     801680 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801672:	8b 55 0c             	mov    0xc(%ebp),%edx
  801675:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801678:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80167b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	83 ec 14             	sub    $0x14,%esp
  801689:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	53                   	push   %ebx
  801691:	e8 02 fc ff ff       	call   801298 <fd_lookup>
  801696:	83 c4 08             	add    $0x8,%esp
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 37                	js     8016d4 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169d:	83 ec 08             	sub    $0x8,%esp
  8016a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a7:	ff 30                	pushl  (%eax)
  8016a9:	e8 40 fc ff ff       	call   8012ee <dev_lookup>
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	78 1f                	js     8016d4 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016bc:	74 1b                	je     8016d9 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c1:	8b 52 18             	mov    0x18(%edx),%edx
  8016c4:	85 d2                	test   %edx,%edx
  8016c6:	74 32                	je     8016fa <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c8:	83 ec 08             	sub    $0x8,%esp
  8016cb:	ff 75 0c             	pushl  0xc(%ebp)
  8016ce:	50                   	push   %eax
  8016cf:	ff d2                	call   *%edx
  8016d1:	83 c4 10             	add    $0x10,%esp
}
  8016d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d7:	c9                   	leave  
  8016d8:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016d9:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016de:	8b 40 48             	mov    0x48(%eax),%eax
  8016e1:	83 ec 04             	sub    $0x4,%esp
  8016e4:	53                   	push   %ebx
  8016e5:	50                   	push   %eax
  8016e6:	68 20 26 80 00       	push   $0x802620
  8016eb:	e8 43 eb ff ff       	call   800233 <cprintf>
		return -E_INVAL;
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f8:	eb da                	jmp    8016d4 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8016fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016ff:	eb d3                	jmp    8016d4 <ftruncate+0x52>

00801701 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	53                   	push   %ebx
  801705:	83 ec 14             	sub    $0x14,%esp
  801708:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170e:	50                   	push   %eax
  80170f:	ff 75 08             	pushl  0x8(%ebp)
  801712:	e8 81 fb ff ff       	call   801298 <fd_lookup>
  801717:	83 c4 08             	add    $0x8,%esp
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 4b                	js     801769 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171e:	83 ec 08             	sub    $0x8,%esp
  801721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801724:	50                   	push   %eax
  801725:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801728:	ff 30                	pushl  (%eax)
  80172a:	e8 bf fb ff ff       	call   8012ee <dev_lookup>
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	85 c0                	test   %eax,%eax
  801734:	78 33                	js     801769 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801739:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80173d:	74 2f                	je     80176e <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80173f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801742:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801749:	00 00 00 
	stat->st_isdir = 0;
  80174c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801753:	00 00 00 
	stat->st_dev = dev;
  801756:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80175c:	83 ec 08             	sub    $0x8,%esp
  80175f:	53                   	push   %ebx
  801760:	ff 75 f0             	pushl  -0x10(%ebp)
  801763:	ff 50 14             	call   *0x14(%eax)
  801766:	83 c4 10             	add    $0x10,%esp
}
  801769:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    
		return -E_NOT_SUPP;
  80176e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801773:	eb f4                	jmp    801769 <fstat+0x68>

00801775 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	6a 00                	push   $0x0
  80177f:	ff 75 08             	pushl  0x8(%ebp)
  801782:	e8 da 01 00 00       	call   801961 <open>
  801787:	89 c3                	mov    %eax,%ebx
  801789:	83 c4 10             	add    $0x10,%esp
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 1b                	js     8017ab <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801790:	83 ec 08             	sub    $0x8,%esp
  801793:	ff 75 0c             	pushl  0xc(%ebp)
  801796:	50                   	push   %eax
  801797:	e8 65 ff ff ff       	call   801701 <fstat>
  80179c:	89 c6                	mov    %eax,%esi
	close(fd);
  80179e:	89 1c 24             	mov    %ebx,(%esp)
  8017a1:	e8 27 fc ff ff       	call   8013cd <close>
	return r;
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	89 f3                	mov    %esi,%ebx
}
  8017ab:	89 d8                	mov    %ebx,%eax
  8017ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b0:	5b                   	pop    %ebx
  8017b1:	5e                   	pop    %esi
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	56                   	push   %esi
  8017b8:	53                   	push   %ebx
  8017b9:	89 c6                	mov    %eax,%esi
  8017bb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017bd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017c4:	74 27                	je     8017ed <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c6:	6a 07                	push   $0x7
  8017c8:	68 00 50 80 00       	push   $0x805000
  8017cd:	56                   	push   %esi
  8017ce:	ff 35 00 40 80 00    	pushl  0x804000
  8017d4:	e8 bc f9 ff ff       	call   801195 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017d9:	83 c4 0c             	add    $0xc,%esp
  8017dc:	6a 00                	push   $0x0
  8017de:	53                   	push   %ebx
  8017df:	6a 00                	push   $0x0
  8017e1:	e8 48 f9 ff ff       	call   80112e <ipc_recv>
}
  8017e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e9:	5b                   	pop    %ebx
  8017ea:	5e                   	pop    %esi
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ed:	83 ec 0c             	sub    $0xc,%esp
  8017f0:	6a 01                	push   $0x1
  8017f2:	e8 f2 f9 ff ff       	call   8011e9 <ipc_find_env>
  8017f7:	a3 00 40 80 00       	mov    %eax,0x804000
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	eb c5                	jmp    8017c6 <fsipc+0x12>

00801801 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	8b 40 0c             	mov    0xc(%eax),%eax
  80180d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801812:	8b 45 0c             	mov    0xc(%ebp),%eax
  801815:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80181a:	ba 00 00 00 00       	mov    $0x0,%edx
  80181f:	b8 02 00 00 00       	mov    $0x2,%eax
  801824:	e8 8b ff ff ff       	call   8017b4 <fsipc>
}
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <devfile_flush>:
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801831:	8b 45 08             	mov    0x8(%ebp),%eax
  801834:	8b 40 0c             	mov    0xc(%eax),%eax
  801837:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80183c:	ba 00 00 00 00       	mov    $0x0,%edx
  801841:	b8 06 00 00 00       	mov    $0x6,%eax
  801846:	e8 69 ff ff ff       	call   8017b4 <fsipc>
}
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <devfile_stat>:
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	53                   	push   %ebx
  801851:	83 ec 04             	sub    $0x4,%esp
  801854:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801857:	8b 45 08             	mov    0x8(%ebp),%eax
  80185a:	8b 40 0c             	mov    0xc(%eax),%eax
  80185d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801862:	ba 00 00 00 00       	mov    $0x0,%edx
  801867:	b8 05 00 00 00       	mov    $0x5,%eax
  80186c:	e8 43 ff ff ff       	call   8017b4 <fsipc>
  801871:	85 c0                	test   %eax,%eax
  801873:	78 2c                	js     8018a1 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801875:	83 ec 08             	sub    $0x8,%esp
  801878:	68 00 50 80 00       	push   $0x805000
  80187d:	53                   	push   %ebx
  80187e:	e8 cf ef ff ff       	call   800852 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801883:	a1 80 50 80 00       	mov    0x805080,%eax
  801888:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80188e:	a1 84 50 80 00       	mov    0x805084,%eax
  801893:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <devfile_write>:
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018af:	8b 55 08             	mov    0x8(%ebp),%edx
  8018b2:	8b 52 0c             	mov    0xc(%edx),%edx
  8018b5:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8018bb:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8018c0:	50                   	push   %eax
  8018c1:	ff 75 0c             	pushl  0xc(%ebp)
  8018c4:	68 08 50 80 00       	push   $0x805008
  8018c9:	e8 12 f1 ff ff       	call   8009e0 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  8018ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d3:	b8 04 00 00 00       	mov    $0x4,%eax
  8018d8:	e8 d7 fe ff ff       	call   8017b4 <fsipc>
}
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    

008018df <devfile_read>:
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	56                   	push   %esi
  8018e3:	53                   	push   %ebx
  8018e4:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ed:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018f2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fd:	b8 03 00 00 00       	mov    $0x3,%eax
  801902:	e8 ad fe ff ff       	call   8017b4 <fsipc>
  801907:	89 c3                	mov    %eax,%ebx
  801909:	85 c0                	test   %eax,%eax
  80190b:	78 1f                	js     80192c <devfile_read+0x4d>
	assert(r <= n);
  80190d:	39 f0                	cmp    %esi,%eax
  80190f:	77 24                	ja     801935 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801911:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801916:	7f 33                	jg     80194b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801918:	83 ec 04             	sub    $0x4,%esp
  80191b:	50                   	push   %eax
  80191c:	68 00 50 80 00       	push   $0x805000
  801921:	ff 75 0c             	pushl  0xc(%ebp)
  801924:	e8 b7 f0 ff ff       	call   8009e0 <memmove>
	return r;
  801929:	83 c4 10             	add    $0x10,%esp
}
  80192c:	89 d8                	mov    %ebx,%eax
  80192e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801931:	5b                   	pop    %ebx
  801932:	5e                   	pop    %esi
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    
	assert(r <= n);
  801935:	68 8c 26 80 00       	push   $0x80268c
  80193a:	68 93 26 80 00       	push   $0x802693
  80193f:	6a 7c                	push   $0x7c
  801941:	68 a8 26 80 00       	push   $0x8026a8
  801946:	e8 0d e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  80194b:	68 b3 26 80 00       	push   $0x8026b3
  801950:	68 93 26 80 00       	push   $0x802693
  801955:	6a 7d                	push   $0x7d
  801957:	68 a8 26 80 00       	push   $0x8026a8
  80195c:	e8 f7 e7 ff ff       	call   800158 <_panic>

00801961 <open>:
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	56                   	push   %esi
  801965:	53                   	push   %ebx
  801966:	83 ec 1c             	sub    $0x1c,%esp
  801969:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80196c:	56                   	push   %esi
  80196d:	e8 a9 ee ff ff       	call   80081b <strlen>
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80197a:	7f 6c                	jg     8019e8 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80197c:	83 ec 0c             	sub    $0xc,%esp
  80197f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801982:	50                   	push   %eax
  801983:	e8 c1 f8 ff ff       	call   801249 <fd_alloc>
  801988:	89 c3                	mov    %eax,%ebx
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	85 c0                	test   %eax,%eax
  80198f:	78 3c                	js     8019cd <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801991:	83 ec 08             	sub    $0x8,%esp
  801994:	56                   	push   %esi
  801995:	68 00 50 80 00       	push   $0x805000
  80199a:	e8 b3 ee ff ff       	call   800852 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80199f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a2:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8019af:	e8 00 fe ff ff       	call   8017b4 <fsipc>
  8019b4:	89 c3                	mov    %eax,%ebx
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	78 19                	js     8019d6 <open+0x75>
	return fd2num(fd);
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c3:	e8 5a f8 ff ff       	call   801222 <fd2num>
  8019c8:	89 c3                	mov    %eax,%ebx
  8019ca:	83 c4 10             	add    $0x10,%esp
}
  8019cd:	89 d8                	mov    %ebx,%eax
  8019cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d2:	5b                   	pop    %ebx
  8019d3:	5e                   	pop    %esi
  8019d4:	5d                   	pop    %ebp
  8019d5:	c3                   	ret    
		fd_close(fd, 0);
  8019d6:	83 ec 08             	sub    $0x8,%esp
  8019d9:	6a 00                	push   $0x0
  8019db:	ff 75 f4             	pushl  -0xc(%ebp)
  8019de:	e8 61 f9 ff ff       	call   801344 <fd_close>
		return r;
  8019e3:	83 c4 10             	add    $0x10,%esp
  8019e6:	eb e5                	jmp    8019cd <open+0x6c>
		return -E_BAD_PATH;
  8019e8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019ed:	eb de                	jmp    8019cd <open+0x6c>

008019ef <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fa:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ff:	e8 b0 fd ff ff       	call   8017b4 <fsipc>
}
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	56                   	push   %esi
  801a0a:	53                   	push   %ebx
  801a0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	ff 75 08             	pushl  0x8(%ebp)
  801a14:	e8 19 f8 ff ff       	call   801232 <fd2data>
  801a19:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a1b:	83 c4 08             	add    $0x8,%esp
  801a1e:	68 bf 26 80 00       	push   $0x8026bf
  801a23:	53                   	push   %ebx
  801a24:	e8 29 ee ff ff       	call   800852 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a29:	8b 46 04             	mov    0x4(%esi),%eax
  801a2c:	2b 06                	sub    (%esi),%eax
  801a2e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a34:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a3b:	00 00 00 
	stat->st_dev = &devpipe;
  801a3e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a45:	30 80 00 
	return 0;
}
  801a48:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a50:	5b                   	pop    %ebx
  801a51:	5e                   	pop    %esi
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    

00801a54 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	53                   	push   %ebx
  801a58:	83 ec 0c             	sub    $0xc,%esp
  801a5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a5e:	53                   	push   %ebx
  801a5f:	6a 00                	push   $0x0
  801a61:	e8 6a f2 ff ff       	call   800cd0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a66:	89 1c 24             	mov    %ebx,(%esp)
  801a69:	e8 c4 f7 ff ff       	call   801232 <fd2data>
  801a6e:	83 c4 08             	add    $0x8,%esp
  801a71:	50                   	push   %eax
  801a72:	6a 00                	push   $0x0
  801a74:	e8 57 f2 ff ff       	call   800cd0 <sys_page_unmap>
}
  801a79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <_pipeisclosed>:
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	57                   	push   %edi
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	83 ec 1c             	sub    $0x1c,%esp
  801a87:	89 c7                	mov    %eax,%edi
  801a89:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a90:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	57                   	push   %edi
  801a97:	e8 c9 04 00 00       	call   801f65 <pageref>
  801a9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a9f:	89 34 24             	mov    %esi,(%esp)
  801aa2:	e8 be 04 00 00       	call   801f65 <pageref>
		nn = thisenv->env_runs;
  801aa7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801aad:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	39 cb                	cmp    %ecx,%ebx
  801ab5:	74 1b                	je     801ad2 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ab7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801aba:	75 cf                	jne    801a8b <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801abc:	8b 42 58             	mov    0x58(%edx),%eax
  801abf:	6a 01                	push   $0x1
  801ac1:	50                   	push   %eax
  801ac2:	53                   	push   %ebx
  801ac3:	68 c6 26 80 00       	push   $0x8026c6
  801ac8:	e8 66 e7 ff ff       	call   800233 <cprintf>
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	eb b9                	jmp    801a8b <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ad2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ad5:	0f 94 c0             	sete   %al
  801ad8:	0f b6 c0             	movzbl %al,%eax
}
  801adb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ade:	5b                   	pop    %ebx
  801adf:	5e                   	pop    %esi
  801ae0:	5f                   	pop    %edi
  801ae1:	5d                   	pop    %ebp
  801ae2:	c3                   	ret    

00801ae3 <devpipe_write>:
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	57                   	push   %edi
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 28             	sub    $0x28,%esp
  801aec:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801aef:	56                   	push   %esi
  801af0:	e8 3d f7 ff ff       	call   801232 <fd2data>
  801af5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	bf 00 00 00 00       	mov    $0x0,%edi
  801aff:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b02:	74 4f                	je     801b53 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b04:	8b 43 04             	mov    0x4(%ebx),%eax
  801b07:	8b 0b                	mov    (%ebx),%ecx
  801b09:	8d 51 20             	lea    0x20(%ecx),%edx
  801b0c:	39 d0                	cmp    %edx,%eax
  801b0e:	72 14                	jb     801b24 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801b10:	89 da                	mov    %ebx,%edx
  801b12:	89 f0                	mov    %esi,%eax
  801b14:	e8 65 ff ff ff       	call   801a7e <_pipeisclosed>
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	75 3a                	jne    801b57 <devpipe_write+0x74>
			sys_yield();
  801b1d:	e8 0a f1 ff ff       	call   800c2c <sys_yield>
  801b22:	eb e0                	jmp    801b04 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b27:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b2b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b2e:	89 c2                	mov    %eax,%edx
  801b30:	c1 fa 1f             	sar    $0x1f,%edx
  801b33:	89 d1                	mov    %edx,%ecx
  801b35:	c1 e9 1b             	shr    $0x1b,%ecx
  801b38:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b3b:	83 e2 1f             	and    $0x1f,%edx
  801b3e:	29 ca                	sub    %ecx,%edx
  801b40:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b44:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b48:	83 c0 01             	add    $0x1,%eax
  801b4b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b4e:	83 c7 01             	add    $0x1,%edi
  801b51:	eb ac                	jmp    801aff <devpipe_write+0x1c>
	return i;
  801b53:	89 f8                	mov    %edi,%eax
  801b55:	eb 05                	jmp    801b5c <devpipe_write+0x79>
				return 0;
  801b57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5f:	5b                   	pop    %ebx
  801b60:	5e                   	pop    %esi
  801b61:	5f                   	pop    %edi
  801b62:	5d                   	pop    %ebp
  801b63:	c3                   	ret    

00801b64 <devpipe_read>:
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	57                   	push   %edi
  801b68:	56                   	push   %esi
  801b69:	53                   	push   %ebx
  801b6a:	83 ec 18             	sub    $0x18,%esp
  801b6d:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b70:	57                   	push   %edi
  801b71:	e8 bc f6 ff ff       	call   801232 <fd2data>
  801b76:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	be 00 00 00 00       	mov    $0x0,%esi
  801b80:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b83:	74 47                	je     801bcc <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801b85:	8b 03                	mov    (%ebx),%eax
  801b87:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b8a:	75 22                	jne    801bae <devpipe_read+0x4a>
			if (i > 0)
  801b8c:	85 f6                	test   %esi,%esi
  801b8e:	75 14                	jne    801ba4 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801b90:	89 da                	mov    %ebx,%edx
  801b92:	89 f8                	mov    %edi,%eax
  801b94:	e8 e5 fe ff ff       	call   801a7e <_pipeisclosed>
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	75 33                	jne    801bd0 <devpipe_read+0x6c>
			sys_yield();
  801b9d:	e8 8a f0 ff ff       	call   800c2c <sys_yield>
  801ba2:	eb e1                	jmp    801b85 <devpipe_read+0x21>
				return i;
  801ba4:	89 f0                	mov    %esi,%eax
}
  801ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	5f                   	pop    %edi
  801bac:	5d                   	pop    %ebp
  801bad:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bae:	99                   	cltd   
  801baf:	c1 ea 1b             	shr    $0x1b,%edx
  801bb2:	01 d0                	add    %edx,%eax
  801bb4:	83 e0 1f             	and    $0x1f,%eax
  801bb7:	29 d0                	sub    %edx,%eax
  801bb9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bc4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801bc7:	83 c6 01             	add    $0x1,%esi
  801bca:	eb b4                	jmp    801b80 <devpipe_read+0x1c>
	return i;
  801bcc:	89 f0                	mov    %esi,%eax
  801bce:	eb d6                	jmp    801ba6 <devpipe_read+0x42>
				return 0;
  801bd0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd5:	eb cf                	jmp    801ba6 <devpipe_read+0x42>

00801bd7 <pipe>:
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	56                   	push   %esi
  801bdb:	53                   	push   %ebx
  801bdc:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be2:	50                   	push   %eax
  801be3:	e8 61 f6 ff ff       	call   801249 <fd_alloc>
  801be8:	89 c3                	mov    %eax,%ebx
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	85 c0                	test   %eax,%eax
  801bef:	78 5b                	js     801c4c <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf1:	83 ec 04             	sub    $0x4,%esp
  801bf4:	68 07 04 00 00       	push   $0x407
  801bf9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfc:	6a 00                	push   $0x0
  801bfe:	e8 48 f0 ff ff       	call   800c4b <sys_page_alloc>
  801c03:	89 c3                	mov    %eax,%ebx
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	78 40                	js     801c4c <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c12:	50                   	push   %eax
  801c13:	e8 31 f6 ff ff       	call   801249 <fd_alloc>
  801c18:	89 c3                	mov    %eax,%ebx
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 1b                	js     801c3c <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c21:	83 ec 04             	sub    $0x4,%esp
  801c24:	68 07 04 00 00       	push   $0x407
  801c29:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2c:	6a 00                	push   $0x0
  801c2e:	e8 18 f0 ff ff       	call   800c4b <sys_page_alloc>
  801c33:	89 c3                	mov    %eax,%ebx
  801c35:	83 c4 10             	add    $0x10,%esp
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	79 19                	jns    801c55 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801c3c:	83 ec 08             	sub    $0x8,%esp
  801c3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c42:	6a 00                	push   $0x0
  801c44:	e8 87 f0 ff ff       	call   800cd0 <sys_page_unmap>
  801c49:	83 c4 10             	add    $0x10,%esp
}
  801c4c:	89 d8                	mov    %ebx,%eax
  801c4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5e                   	pop    %esi
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    
	va = fd2data(fd0);
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5b:	e8 d2 f5 ff ff       	call   801232 <fd2data>
  801c60:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c62:	83 c4 0c             	add    $0xc,%esp
  801c65:	68 07 04 00 00       	push   $0x407
  801c6a:	50                   	push   %eax
  801c6b:	6a 00                	push   $0x0
  801c6d:	e8 d9 ef ff ff       	call   800c4b <sys_page_alloc>
  801c72:	89 c3                	mov    %eax,%ebx
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	85 c0                	test   %eax,%eax
  801c79:	0f 88 8c 00 00 00    	js     801d0b <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7f:	83 ec 0c             	sub    $0xc,%esp
  801c82:	ff 75 f0             	pushl  -0x10(%ebp)
  801c85:	e8 a8 f5 ff ff       	call   801232 <fd2data>
  801c8a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c91:	50                   	push   %eax
  801c92:	6a 00                	push   $0x0
  801c94:	56                   	push   %esi
  801c95:	6a 00                	push   $0x0
  801c97:	e8 f2 ef ff ff       	call   800c8e <sys_page_map>
  801c9c:	89 c3                	mov    %eax,%ebx
  801c9e:	83 c4 20             	add    $0x20,%esp
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	78 58                	js     801cfd <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cae:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801cba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cc3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ccf:	83 ec 0c             	sub    $0xc,%esp
  801cd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd5:	e8 48 f5 ff ff       	call   801222 <fd2num>
  801cda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cdf:	83 c4 04             	add    $0x4,%esp
  801ce2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce5:	e8 38 f5 ff ff       	call   801222 <fd2num>
  801cea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ced:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cf8:	e9 4f ff ff ff       	jmp    801c4c <pipe+0x75>
	sys_page_unmap(0, va);
  801cfd:	83 ec 08             	sub    $0x8,%esp
  801d00:	56                   	push   %esi
  801d01:	6a 00                	push   $0x0
  801d03:	e8 c8 ef ff ff       	call   800cd0 <sys_page_unmap>
  801d08:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d0b:	83 ec 08             	sub    $0x8,%esp
  801d0e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d11:	6a 00                	push   $0x0
  801d13:	e8 b8 ef ff ff       	call   800cd0 <sys_page_unmap>
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	e9 1c ff ff ff       	jmp    801c3c <pipe+0x65>

00801d20 <pipeisclosed>:
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d29:	50                   	push   %eax
  801d2a:	ff 75 08             	pushl  0x8(%ebp)
  801d2d:	e8 66 f5 ff ff       	call   801298 <fd_lookup>
  801d32:	83 c4 10             	add    $0x10,%esp
  801d35:	85 c0                	test   %eax,%eax
  801d37:	78 18                	js     801d51 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d39:	83 ec 0c             	sub    $0xc,%esp
  801d3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3f:	e8 ee f4 ff ff       	call   801232 <fd2data>
	return _pipeisclosed(fd, p);
  801d44:	89 c2                	mov    %eax,%edx
  801d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d49:	e8 30 fd ff ff       	call   801a7e <_pipeisclosed>
  801d4e:	83 c4 10             	add    $0x10,%esp
}
  801d51:	c9                   	leave  
  801d52:	c3                   	ret    

00801d53 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d56:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    

00801d5d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d63:	68 de 26 80 00       	push   $0x8026de
  801d68:	ff 75 0c             	pushl  0xc(%ebp)
  801d6b:	e8 e2 ea ff ff       	call   800852 <strcpy>
	return 0;
}
  801d70:	b8 00 00 00 00       	mov    $0x0,%eax
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    

00801d77 <devcons_write>:
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	57                   	push   %edi
  801d7b:	56                   	push   %esi
  801d7c:	53                   	push   %ebx
  801d7d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d83:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d88:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d8e:	eb 2f                	jmp    801dbf <devcons_write+0x48>
		m = n - tot;
  801d90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d93:	29 f3                	sub    %esi,%ebx
  801d95:	83 fb 7f             	cmp    $0x7f,%ebx
  801d98:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d9d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801da0:	83 ec 04             	sub    $0x4,%esp
  801da3:	53                   	push   %ebx
  801da4:	89 f0                	mov    %esi,%eax
  801da6:	03 45 0c             	add    0xc(%ebp),%eax
  801da9:	50                   	push   %eax
  801daa:	57                   	push   %edi
  801dab:	e8 30 ec ff ff       	call   8009e0 <memmove>
		sys_cputs(buf, m);
  801db0:	83 c4 08             	add    $0x8,%esp
  801db3:	53                   	push   %ebx
  801db4:	57                   	push   %edi
  801db5:	e8 d5 ed ff ff       	call   800b8f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801dba:	01 de                	add    %ebx,%esi
  801dbc:	83 c4 10             	add    $0x10,%esp
  801dbf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc2:	72 cc                	jb     801d90 <devcons_write+0x19>
}
  801dc4:	89 f0                	mov    %esi,%eax
  801dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc9:	5b                   	pop    %ebx
  801dca:	5e                   	pop    %esi
  801dcb:	5f                   	pop    %edi
  801dcc:	5d                   	pop    %ebp
  801dcd:	c3                   	ret    

00801dce <devcons_read>:
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	83 ec 08             	sub    $0x8,%esp
  801dd4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801dd9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ddd:	75 07                	jne    801de6 <devcons_read+0x18>
}
  801ddf:	c9                   	leave  
  801de0:	c3                   	ret    
		sys_yield();
  801de1:	e8 46 ee ff ff       	call   800c2c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801de6:	e8 c2 ed ff ff       	call   800bad <sys_cgetc>
  801deb:	85 c0                	test   %eax,%eax
  801ded:	74 f2                	je     801de1 <devcons_read+0x13>
	if (c < 0)
  801def:	85 c0                	test   %eax,%eax
  801df1:	78 ec                	js     801ddf <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801df3:	83 f8 04             	cmp    $0x4,%eax
  801df6:	74 0c                	je     801e04 <devcons_read+0x36>
	*(char*)vbuf = c;
  801df8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dfb:	88 02                	mov    %al,(%edx)
	return 1;
  801dfd:	b8 01 00 00 00       	mov    $0x1,%eax
  801e02:	eb db                	jmp    801ddf <devcons_read+0x11>
		return 0;
  801e04:	b8 00 00 00 00       	mov    $0x0,%eax
  801e09:	eb d4                	jmp    801ddf <devcons_read+0x11>

00801e0b <cputchar>:
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e11:	8b 45 08             	mov    0x8(%ebp),%eax
  801e14:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e17:	6a 01                	push   $0x1
  801e19:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e1c:	50                   	push   %eax
  801e1d:	e8 6d ed ff ff       	call   800b8f <sys_cputs>
}
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    

00801e27 <getchar>:
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e2d:	6a 01                	push   $0x1
  801e2f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e32:	50                   	push   %eax
  801e33:	6a 00                	push   $0x0
  801e35:	e8 cf f6 ff ff       	call   801509 <read>
	if (r < 0)
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	78 08                	js     801e49 <getchar+0x22>
	if (r < 1)
  801e41:	85 c0                	test   %eax,%eax
  801e43:	7e 06                	jle    801e4b <getchar+0x24>
	return c;
  801e45:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    
		return -E_EOF;
  801e4b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e50:	eb f7                	jmp    801e49 <getchar+0x22>

00801e52 <iscons>:
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5b:	50                   	push   %eax
  801e5c:	ff 75 08             	pushl  0x8(%ebp)
  801e5f:	e8 34 f4 ff ff       	call   801298 <fd_lookup>
  801e64:	83 c4 10             	add    $0x10,%esp
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 11                	js     801e7c <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e74:	39 10                	cmp    %edx,(%eax)
  801e76:	0f 94 c0             	sete   %al
  801e79:	0f b6 c0             	movzbl %al,%eax
}
  801e7c:	c9                   	leave  
  801e7d:	c3                   	ret    

00801e7e <opencons>:
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e87:	50                   	push   %eax
  801e88:	e8 bc f3 ff ff       	call   801249 <fd_alloc>
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 3a                	js     801ece <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e94:	83 ec 04             	sub    $0x4,%esp
  801e97:	68 07 04 00 00       	push   $0x407
  801e9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9f:	6a 00                	push   $0x0
  801ea1:	e8 a5 ed ff ff       	call   800c4b <sys_page_alloc>
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	78 21                	js     801ece <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec2:	83 ec 0c             	sub    $0xc,%esp
  801ec5:	50                   	push   %eax
  801ec6:	e8 57 f3 ff ff       	call   801222 <fd2num>
  801ecb:	83 c4 10             	add    $0x10,%esp
}
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ed6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801edd:	74 20                	je     801eff <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801edf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee2:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801ee7:	83 ec 08             	sub    $0x8,%esp
  801eea:	68 3f 1f 80 00       	push   $0x801f3f
  801eef:	6a 00                	push   $0x0
  801ef1:	e8 a0 ee ff ff       	call   800d96 <sys_env_set_pgfault_upcall>
  801ef6:	83 c4 10             	add    $0x10,%esp
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 2e                	js     801f2b <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  801efd:	c9                   	leave  
  801efe:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801eff:	83 ec 04             	sub    $0x4,%esp
  801f02:	6a 07                	push   $0x7
  801f04:	68 00 f0 bf ee       	push   $0xeebff000
  801f09:	6a 00                	push   $0x0
  801f0b:	e8 3b ed ff ff       	call   800c4b <sys_page_alloc>
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	85 c0                	test   %eax,%eax
  801f15:	79 c8                	jns    801edf <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801f17:	83 ec 04             	sub    $0x4,%esp
  801f1a:	68 ec 26 80 00       	push   $0x8026ec
  801f1f:	6a 21                	push   $0x21
  801f21:	68 50 27 80 00       	push   $0x802750
  801f26:	e8 2d e2 ff ff       	call   800158 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801f2b:	83 ec 04             	sub    $0x4,%esp
  801f2e:	68 18 27 80 00       	push   $0x802718
  801f33:	6a 27                	push   $0x27
  801f35:	68 50 27 80 00       	push   $0x802750
  801f3a:	e8 19 e2 ff ff       	call   800158 <_panic>

00801f3f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f3f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f40:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f45:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f47:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801f4a:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801f4e:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801f51:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  801f55:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f59:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801f5b:	83 c4 08             	add    $0x8,%esp
	popal
  801f5e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801f5f:	83 c4 04             	add    $0x4,%esp
	popfl
  801f62:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f63:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f64:	c3                   	ret    

00801f65 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6b:	89 d0                	mov    %edx,%eax
  801f6d:	c1 e8 16             	shr    $0x16,%eax
  801f70:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f77:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f7c:	f6 c1 01             	test   $0x1,%cl
  801f7f:	74 1d                	je     801f9e <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f81:	c1 ea 0c             	shr    $0xc,%edx
  801f84:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f8b:	f6 c2 01             	test   $0x1,%dl
  801f8e:	74 0e                	je     801f9e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f90:	c1 ea 0c             	shr    $0xc,%edx
  801f93:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f9a:	ef 
  801f9b:	0f b7 c0             	movzwl %ax,%eax
}
  801f9e:	5d                   	pop    %ebp
  801f9f:	c3                   	ret    

00801fa0 <__udivdi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
  801fa7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801faf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801fb7:	85 d2                	test   %edx,%edx
  801fb9:	75 35                	jne    801ff0 <__udivdi3+0x50>
  801fbb:	39 f3                	cmp    %esi,%ebx
  801fbd:	0f 87 bd 00 00 00    	ja     802080 <__udivdi3+0xe0>
  801fc3:	85 db                	test   %ebx,%ebx
  801fc5:	89 d9                	mov    %ebx,%ecx
  801fc7:	75 0b                	jne    801fd4 <__udivdi3+0x34>
  801fc9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f3                	div    %ebx
  801fd2:	89 c1                	mov    %eax,%ecx
  801fd4:	31 d2                	xor    %edx,%edx
  801fd6:	89 f0                	mov    %esi,%eax
  801fd8:	f7 f1                	div    %ecx
  801fda:	89 c6                	mov    %eax,%esi
  801fdc:	89 e8                	mov    %ebp,%eax
  801fde:	89 f7                	mov    %esi,%edi
  801fe0:	f7 f1                	div    %ecx
  801fe2:	89 fa                	mov    %edi,%edx
  801fe4:	83 c4 1c             	add    $0x1c,%esp
  801fe7:	5b                   	pop    %ebx
  801fe8:	5e                   	pop    %esi
  801fe9:	5f                   	pop    %edi
  801fea:	5d                   	pop    %ebp
  801feb:	c3                   	ret    
  801fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	39 f2                	cmp    %esi,%edx
  801ff2:	77 7c                	ja     802070 <__udivdi3+0xd0>
  801ff4:	0f bd fa             	bsr    %edx,%edi
  801ff7:	83 f7 1f             	xor    $0x1f,%edi
  801ffa:	0f 84 98 00 00 00    	je     802098 <__udivdi3+0xf8>
  802000:	89 f9                	mov    %edi,%ecx
  802002:	b8 20 00 00 00       	mov    $0x20,%eax
  802007:	29 f8                	sub    %edi,%eax
  802009:	d3 e2                	shl    %cl,%edx
  80200b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80200f:	89 c1                	mov    %eax,%ecx
  802011:	89 da                	mov    %ebx,%edx
  802013:	d3 ea                	shr    %cl,%edx
  802015:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802019:	09 d1                	or     %edx,%ecx
  80201b:	89 f2                	mov    %esi,%edx
  80201d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802021:	89 f9                	mov    %edi,%ecx
  802023:	d3 e3                	shl    %cl,%ebx
  802025:	89 c1                	mov    %eax,%ecx
  802027:	d3 ea                	shr    %cl,%edx
  802029:	89 f9                	mov    %edi,%ecx
  80202b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80202f:	d3 e6                	shl    %cl,%esi
  802031:	89 eb                	mov    %ebp,%ebx
  802033:	89 c1                	mov    %eax,%ecx
  802035:	d3 eb                	shr    %cl,%ebx
  802037:	09 de                	or     %ebx,%esi
  802039:	89 f0                	mov    %esi,%eax
  80203b:	f7 74 24 08          	divl   0x8(%esp)
  80203f:	89 d6                	mov    %edx,%esi
  802041:	89 c3                	mov    %eax,%ebx
  802043:	f7 64 24 0c          	mull   0xc(%esp)
  802047:	39 d6                	cmp    %edx,%esi
  802049:	72 0c                	jb     802057 <__udivdi3+0xb7>
  80204b:	89 f9                	mov    %edi,%ecx
  80204d:	d3 e5                	shl    %cl,%ebp
  80204f:	39 c5                	cmp    %eax,%ebp
  802051:	73 5d                	jae    8020b0 <__udivdi3+0x110>
  802053:	39 d6                	cmp    %edx,%esi
  802055:	75 59                	jne    8020b0 <__udivdi3+0x110>
  802057:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80205a:	31 ff                	xor    %edi,%edi
  80205c:	89 fa                	mov    %edi,%edx
  80205e:	83 c4 1c             	add    $0x1c,%esp
  802061:	5b                   	pop    %ebx
  802062:	5e                   	pop    %esi
  802063:	5f                   	pop    %edi
  802064:	5d                   	pop    %ebp
  802065:	c3                   	ret    
  802066:	8d 76 00             	lea    0x0(%esi),%esi
  802069:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802070:	31 ff                	xor    %edi,%edi
  802072:	31 c0                	xor    %eax,%eax
  802074:	89 fa                	mov    %edi,%edx
  802076:	83 c4 1c             	add    $0x1c,%esp
  802079:	5b                   	pop    %ebx
  80207a:	5e                   	pop    %esi
  80207b:	5f                   	pop    %edi
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    
  80207e:	66 90                	xchg   %ax,%ax
  802080:	31 ff                	xor    %edi,%edi
  802082:	89 e8                	mov    %ebp,%eax
  802084:	89 f2                	mov    %esi,%edx
  802086:	f7 f3                	div    %ebx
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	39 f2                	cmp    %esi,%edx
  80209a:	72 06                	jb     8020a2 <__udivdi3+0x102>
  80209c:	31 c0                	xor    %eax,%eax
  80209e:	39 eb                	cmp    %ebp,%ebx
  8020a0:	77 d2                	ja     802074 <__udivdi3+0xd4>
  8020a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a7:	eb cb                	jmp    802074 <__udivdi3+0xd4>
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	31 ff                	xor    %edi,%edi
  8020b4:	eb be                	jmp    802074 <__udivdi3+0xd4>
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8020cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 ed                	test   %ebp,%ebp
  8020d9:	89 f0                	mov    %esi,%eax
  8020db:	89 da                	mov    %ebx,%edx
  8020dd:	75 19                	jne    8020f8 <__umoddi3+0x38>
  8020df:	39 df                	cmp    %ebx,%edi
  8020e1:	0f 86 b1 00 00 00    	jbe    802198 <__umoddi3+0xd8>
  8020e7:	f7 f7                	div    %edi
  8020e9:	89 d0                	mov    %edx,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	83 c4 1c             	add    $0x1c,%esp
  8020f0:	5b                   	pop    %ebx
  8020f1:	5e                   	pop    %esi
  8020f2:	5f                   	pop    %edi
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    
  8020f5:	8d 76 00             	lea    0x0(%esi),%esi
  8020f8:	39 dd                	cmp    %ebx,%ebp
  8020fa:	77 f1                	ja     8020ed <__umoddi3+0x2d>
  8020fc:	0f bd cd             	bsr    %ebp,%ecx
  8020ff:	83 f1 1f             	xor    $0x1f,%ecx
  802102:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802106:	0f 84 b4 00 00 00    	je     8021c0 <__umoddi3+0x100>
  80210c:	b8 20 00 00 00       	mov    $0x20,%eax
  802111:	89 c2                	mov    %eax,%edx
  802113:	8b 44 24 04          	mov    0x4(%esp),%eax
  802117:	29 c2                	sub    %eax,%edx
  802119:	89 c1                	mov    %eax,%ecx
  80211b:	89 f8                	mov    %edi,%eax
  80211d:	d3 e5                	shl    %cl,%ebp
  80211f:	89 d1                	mov    %edx,%ecx
  802121:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802125:	d3 e8                	shr    %cl,%eax
  802127:	09 c5                	or     %eax,%ebp
  802129:	8b 44 24 04          	mov    0x4(%esp),%eax
  80212d:	89 c1                	mov    %eax,%ecx
  80212f:	d3 e7                	shl    %cl,%edi
  802131:	89 d1                	mov    %edx,%ecx
  802133:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802137:	89 df                	mov    %ebx,%edi
  802139:	d3 ef                	shr    %cl,%edi
  80213b:	89 c1                	mov    %eax,%ecx
  80213d:	89 f0                	mov    %esi,%eax
  80213f:	d3 e3                	shl    %cl,%ebx
  802141:	89 d1                	mov    %edx,%ecx
  802143:	89 fa                	mov    %edi,%edx
  802145:	d3 e8                	shr    %cl,%eax
  802147:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80214c:	09 d8                	or     %ebx,%eax
  80214e:	f7 f5                	div    %ebp
  802150:	d3 e6                	shl    %cl,%esi
  802152:	89 d1                	mov    %edx,%ecx
  802154:	f7 64 24 08          	mull   0x8(%esp)
  802158:	39 d1                	cmp    %edx,%ecx
  80215a:	89 c3                	mov    %eax,%ebx
  80215c:	89 d7                	mov    %edx,%edi
  80215e:	72 06                	jb     802166 <__umoddi3+0xa6>
  802160:	75 0e                	jne    802170 <__umoddi3+0xb0>
  802162:	39 c6                	cmp    %eax,%esi
  802164:	73 0a                	jae    802170 <__umoddi3+0xb0>
  802166:	2b 44 24 08          	sub    0x8(%esp),%eax
  80216a:	19 ea                	sbb    %ebp,%edx
  80216c:	89 d7                	mov    %edx,%edi
  80216e:	89 c3                	mov    %eax,%ebx
  802170:	89 ca                	mov    %ecx,%edx
  802172:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802177:	29 de                	sub    %ebx,%esi
  802179:	19 fa                	sbb    %edi,%edx
  80217b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80217f:	89 d0                	mov    %edx,%eax
  802181:	d3 e0                	shl    %cl,%eax
  802183:	89 d9                	mov    %ebx,%ecx
  802185:	d3 ee                	shr    %cl,%esi
  802187:	d3 ea                	shr    %cl,%edx
  802189:	09 f0                	or     %esi,%eax
  80218b:	83 c4 1c             	add    $0x1c,%esp
  80218e:	5b                   	pop    %ebx
  80218f:	5e                   	pop    %esi
  802190:	5f                   	pop    %edi
  802191:	5d                   	pop    %ebp
  802192:	c3                   	ret    
  802193:	90                   	nop
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	85 ff                	test   %edi,%edi
  80219a:	89 f9                	mov    %edi,%ecx
  80219c:	75 0b                	jne    8021a9 <__umoddi3+0xe9>
  80219e:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f7                	div    %edi
  8021a7:	89 c1                	mov    %eax,%ecx
  8021a9:	89 d8                	mov    %ebx,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f1                	div    %ecx
  8021af:	89 f0                	mov    %esi,%eax
  8021b1:	f7 f1                	div    %ecx
  8021b3:	e9 31 ff ff ff       	jmp    8020e9 <__umoddi3+0x29>
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	39 dd                	cmp    %ebx,%ebp
  8021c2:	72 08                	jb     8021cc <__umoddi3+0x10c>
  8021c4:	39 f7                	cmp    %esi,%edi
  8021c6:	0f 87 21 ff ff ff    	ja     8020ed <__umoddi3+0x2d>
  8021cc:	89 da                	mov    %ebx,%edx
  8021ce:	89 f0                	mov    %esi,%eax
  8021d0:	29 f8                	sub    %edi,%eax
  8021d2:	19 ea                	sbb    %ebp,%edx
  8021d4:	e9 14 ff ff ff       	jmp    8020ed <__umoddi3+0x2d>
