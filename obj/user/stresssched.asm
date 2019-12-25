
obj/user/stresssched.debug：     文件格式 elf32-i386


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
  80002c:	e8 b7 00 00 00       	call   8000e8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 c0 0b 00 00       	call   800bfd <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 e5 0e 00 00       	call   800f2e <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0f                	je     80005c <umain+0x29>
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
			break;
	if (i == 20) {
		sys_yield();
  800055:	e8 c2 0b 00 00       	call   800c1c <sys_yield>
		return;
  80005a:	eb 6e                	jmp    8000ca <umain+0x97>
	if (i == 20) {
  80005c:	83 fb 14             	cmp    $0x14,%ebx
  80005f:	74 f4                	je     800055 <umain+0x22>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800061:	89 f0                	mov    %esi,%eax
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	eb 02                	jmp    800074 <umain+0x41>
		asm volatile("pause");
  800072:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800074:	8b 50 54             	mov    0x54(%eax),%edx
  800077:	85 d2                	test   %edx,%edx
  800079:	75 f7                	jne    800072 <umain+0x3f>
  80007b:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800080:	e8 97 0b 00 00       	call   800c1c <sys_yield>
  800085:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008a:	a1 04 40 80 00       	mov    0x804004,%eax
  80008f:	83 c0 01             	add    $0x1,%eax
  800092:	a3 04 40 80 00       	mov    %eax,0x804004
		for (j = 0; j < 10000; j++)
  800097:	83 ea 01             	sub    $0x1,%edx
  80009a:	75 ee                	jne    80008a <umain+0x57>
	for (i = 0; i < 10; i++) {
  80009c:	83 eb 01             	sub    $0x1,%ebx
  80009f:	75 df                	jne    800080 <umain+0x4d>
	}

	if (counter != 10*10000)
  8000a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8000a6:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000ab:	75 24                	jne    8000d1 <umain+0x9e>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b2:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b5:	8b 40 48             	mov    0x48(%eax),%eax
  8000b8:	83 ec 04             	sub    $0x4,%esp
  8000bb:	52                   	push   %edx
  8000bc:	50                   	push   %eax
  8000bd:	68 1b 22 80 00       	push   $0x80221b
  8000c2:	e8 5c 01 00 00       	call   800223 <cprintf>
  8000c7:	83 c4 10             	add    $0x10,%esp

}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d6:	50                   	push   %eax
  8000d7:	68 e0 21 80 00       	push   $0x8021e0
  8000dc:	6a 21                	push   $0x21
  8000de:	68 08 22 80 00       	push   $0x802208
  8000e3:	e8 60 00 00 00       	call   800148 <_panic>

008000e8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000f3:	e8 05 0b 00 00       	call   800bfd <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800100:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800105:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010a:	85 db                	test   %ebx,%ebx
  80010c:	7e 07                	jle    800115 <libmain+0x2d>
		binaryname = argv[0];
  80010e:	8b 06                	mov    (%esi),%eax
  800110:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
  80011a:	e8 14 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011f:	e8 0a 00 00 00       	call   80012e <exit>
}
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800134:	e8 bb 11 00 00       	call   8012f4 <close_all>
	sys_env_destroy(0);
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	6a 00                	push   $0x0
  80013e:	e8 79 0a 00 00       	call   800bbc <sys_env_destroy>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800150:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800156:	e8 a2 0a 00 00       	call   800bfd <sys_getenvid>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	ff 75 0c             	pushl  0xc(%ebp)
  800161:	ff 75 08             	pushl  0x8(%ebp)
  800164:	56                   	push   %esi
  800165:	50                   	push   %eax
  800166:	68 44 22 80 00       	push   $0x802244
  80016b:	e8 b3 00 00 00       	call   800223 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800170:	83 c4 18             	add    $0x18,%esp
  800173:	53                   	push   %ebx
  800174:	ff 75 10             	pushl  0x10(%ebp)
  800177:	e8 56 00 00 00       	call   8001d2 <vcprintf>
	cprintf("\n");
  80017c:	c7 04 24 37 22 80 00 	movl   $0x802237,(%esp)
  800183:	e8 9b 00 00 00       	call   800223 <cprintf>
  800188:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018b:	cc                   	int3   
  80018c:	eb fd                	jmp    80018b <_panic+0x43>

0080018e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	53                   	push   %ebx
  800192:	83 ec 04             	sub    $0x4,%esp
  800195:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800198:	8b 13                	mov    (%ebx),%edx
  80019a:	8d 42 01             	lea    0x1(%edx),%eax
  80019d:	89 03                	mov    %eax,(%ebx)
  80019f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ab:	74 09                	je     8001b6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ad:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	68 ff 00 00 00       	push   $0xff
  8001be:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c1:	50                   	push   %eax
  8001c2:	e8 b8 09 00 00       	call   800b7f <sys_cputs>
		b->idx = 0;
  8001c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	eb db                	jmp    8001ad <putch+0x1f>

008001d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e2:	00 00 00 
	b.cnt = 0;
  8001e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ef:	ff 75 0c             	pushl  0xc(%ebp)
  8001f2:	ff 75 08             	pushl  0x8(%ebp)
  8001f5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fb:	50                   	push   %eax
  8001fc:	68 8e 01 80 00       	push   $0x80018e
  800201:	e8 1a 01 00 00       	call   800320 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800206:	83 c4 08             	add    $0x8,%esp
  800209:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800215:	50                   	push   %eax
  800216:	e8 64 09 00 00       	call   800b7f <sys_cputs>

	return b.cnt;
}
  80021b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800229:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022c:	50                   	push   %eax
  80022d:	ff 75 08             	pushl  0x8(%ebp)
  800230:	e8 9d ff ff ff       	call   8001d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 1c             	sub    $0x1c,%esp
  800240:	89 c7                	mov    %eax,%edi
  800242:	89 d6                	mov    %edx,%esi
  800244:	8b 45 08             	mov    0x8(%ebp),%eax
  800247:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800250:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800253:	bb 00 00 00 00       	mov    $0x0,%ebx
  800258:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025e:	39 d3                	cmp    %edx,%ebx
  800260:	72 05                	jb     800267 <printnum+0x30>
  800262:	39 45 10             	cmp    %eax,0x10(%ebp)
  800265:	77 7a                	ja     8002e1 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800267:	83 ec 0c             	sub    $0xc,%esp
  80026a:	ff 75 18             	pushl  0x18(%ebp)
  80026d:	8b 45 14             	mov    0x14(%ebp),%eax
  800270:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800273:	53                   	push   %ebx
  800274:	ff 75 10             	pushl  0x10(%ebp)
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027d:	ff 75 e0             	pushl  -0x20(%ebp)
  800280:	ff 75 dc             	pushl  -0x24(%ebp)
  800283:	ff 75 d8             	pushl  -0x28(%ebp)
  800286:	e8 05 1d 00 00       	call   801f90 <__udivdi3>
  80028b:	83 c4 18             	add    $0x18,%esp
  80028e:	52                   	push   %edx
  80028f:	50                   	push   %eax
  800290:	89 f2                	mov    %esi,%edx
  800292:	89 f8                	mov    %edi,%eax
  800294:	e8 9e ff ff ff       	call   800237 <printnum>
  800299:	83 c4 20             	add    $0x20,%esp
  80029c:	eb 13                	jmp    8002b1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	56                   	push   %esi
  8002a2:	ff 75 18             	pushl  0x18(%ebp)
  8002a5:	ff d7                	call   *%edi
  8002a7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002aa:	83 eb 01             	sub    $0x1,%ebx
  8002ad:	85 db                	test   %ebx,%ebx
  8002af:	7f ed                	jg     80029e <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	83 ec 04             	sub    $0x4,%esp
  8002b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002be:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c4:	e8 e7 1d 00 00       	call   8020b0 <__umoddi3>
  8002c9:	83 c4 14             	add    $0x14,%esp
  8002cc:	0f be 80 67 22 80 00 	movsbl 0x802267(%eax),%eax
  8002d3:	50                   	push   %eax
  8002d4:	ff d7                	call   *%edi
}
  8002d6:	83 c4 10             	add    $0x10,%esp
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    
  8002e1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e4:	eb c4                	jmp    8002aa <printnum+0x73>

008002e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f5:	73 0a                	jae    800301 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	88 02                	mov    %al,(%edx)
}
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <printfmt>:
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800309:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030c:	50                   	push   %eax
  80030d:	ff 75 10             	pushl  0x10(%ebp)
  800310:	ff 75 0c             	pushl  0xc(%ebp)
  800313:	ff 75 08             	pushl  0x8(%ebp)
  800316:	e8 05 00 00 00       	call   800320 <vprintfmt>
}
  80031b:	83 c4 10             	add    $0x10,%esp
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vprintfmt>:
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 2c             	sub    $0x2c,%esp
  800329:	8b 75 08             	mov    0x8(%ebp),%esi
  80032c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800332:	e9 c1 03 00 00       	jmp    8006f8 <vprintfmt+0x3d8>
		padc = ' ';
  800337:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80033b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800342:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800349:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800350:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8d 47 01             	lea    0x1(%edi),%eax
  800358:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035b:	0f b6 17             	movzbl (%edi),%edx
  80035e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800361:	3c 55                	cmp    $0x55,%al
  800363:	0f 87 12 04 00 00    	ja     80077b <vprintfmt+0x45b>
  800369:	0f b6 c0             	movzbl %al,%eax
  80036c:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800376:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80037a:	eb d9                	jmp    800355 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80037f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800383:	eb d0                	jmp    800355 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800385:	0f b6 d2             	movzbl %dl,%edx
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80038b:	b8 00 00 00 00       	mov    $0x0,%eax
  800390:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800393:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800396:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80039a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a0:	83 f9 09             	cmp    $0x9,%ecx
  8003a3:	77 55                	ja     8003fa <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8003a5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a8:	eb e9                	jmp    800393 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8b 00                	mov    (%eax),%eax
  8003af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 40 04             	lea    0x4(%eax),%eax
  8003b8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c2:	79 91                	jns    800355 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d1:	eb 82                	jmp    800355 <vprintfmt+0x35>
  8003d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d6:	85 c0                	test   %eax,%eax
  8003d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dd:	0f 49 d0             	cmovns %eax,%edx
  8003e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	e9 6a ff ff ff       	jmp    800355 <vprintfmt+0x35>
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ee:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f5:	e9 5b ff ff ff       	jmp    800355 <vprintfmt+0x35>
  8003fa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800400:	eb bc                	jmp    8003be <vprintfmt+0x9e>
			lflag++;
  800402:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800408:	e9 48 ff ff ff       	jmp    800355 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 78 04             	lea    0x4(%eax),%edi
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	53                   	push   %ebx
  800417:	ff 30                	pushl  (%eax)
  800419:	ff d6                	call   *%esi
			break;
  80041b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800421:	e9 cf 02 00 00       	jmp    8006f5 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 78 04             	lea    0x4(%eax),%edi
  80042c:	8b 00                	mov    (%eax),%eax
  80042e:	99                   	cltd   
  80042f:	31 d0                	xor    %edx,%eax
  800431:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800433:	83 f8 0f             	cmp    $0xf,%eax
  800436:	7f 23                	jg     80045b <vprintfmt+0x13b>
  800438:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  80043f:	85 d2                	test   %edx,%edx
  800441:	74 18                	je     80045b <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800443:	52                   	push   %edx
  800444:	68 c5 26 80 00       	push   $0x8026c5
  800449:	53                   	push   %ebx
  80044a:	56                   	push   %esi
  80044b:	e8 b3 fe ff ff       	call   800303 <printfmt>
  800450:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800453:	89 7d 14             	mov    %edi,0x14(%ebp)
  800456:	e9 9a 02 00 00       	jmp    8006f5 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80045b:	50                   	push   %eax
  80045c:	68 7f 22 80 00       	push   $0x80227f
  800461:	53                   	push   %ebx
  800462:	56                   	push   %esi
  800463:	e8 9b fe ff ff       	call   800303 <printfmt>
  800468:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80046e:	e9 82 02 00 00       	jmp    8006f5 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	83 c0 04             	add    $0x4,%eax
  800479:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800481:	85 ff                	test   %edi,%edi
  800483:	b8 78 22 80 00       	mov    $0x802278,%eax
  800488:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80048b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048f:	0f 8e bd 00 00 00    	jle    800552 <vprintfmt+0x232>
  800495:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800499:	75 0e                	jne    8004a9 <vprintfmt+0x189>
  80049b:	89 75 08             	mov    %esi,0x8(%ebp)
  80049e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a7:	eb 6d                	jmp    800516 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	ff 75 d0             	pushl  -0x30(%ebp)
  8004af:	57                   	push   %edi
  8004b0:	e8 6e 03 00 00       	call   800823 <strnlen>
  8004b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b8:	29 c1                	sub    %eax,%ecx
  8004ba:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ca:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	eb 0f                	jmp    8004dd <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	83 ef 01             	sub    $0x1,%edi
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	7f ed                	jg     8004ce <vprintfmt+0x1ae>
  8004e1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e7:	85 c9                	test   %ecx,%ecx
  8004e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ee:	0f 49 c1             	cmovns %ecx,%eax
  8004f1:	29 c1                	sub    %eax,%ecx
  8004f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fc:	89 cb                	mov    %ecx,%ebx
  8004fe:	eb 16                	jmp    800516 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800500:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800504:	75 31                	jne    800537 <vprintfmt+0x217>
					putch(ch, putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 0c             	pushl  0xc(%ebp)
  80050c:	50                   	push   %eax
  80050d:	ff 55 08             	call   *0x8(%ebp)
  800510:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800513:	83 eb 01             	sub    $0x1,%ebx
  800516:	83 c7 01             	add    $0x1,%edi
  800519:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80051d:	0f be c2             	movsbl %dl,%eax
  800520:	85 c0                	test   %eax,%eax
  800522:	74 59                	je     80057d <vprintfmt+0x25d>
  800524:	85 f6                	test   %esi,%esi
  800526:	78 d8                	js     800500 <vprintfmt+0x1e0>
  800528:	83 ee 01             	sub    $0x1,%esi
  80052b:	79 d3                	jns    800500 <vprintfmt+0x1e0>
  80052d:	89 df                	mov    %ebx,%edi
  80052f:	8b 75 08             	mov    0x8(%ebp),%esi
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800535:	eb 37                	jmp    80056e <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800537:	0f be d2             	movsbl %dl,%edx
  80053a:	83 ea 20             	sub    $0x20,%edx
  80053d:	83 fa 5e             	cmp    $0x5e,%edx
  800540:	76 c4                	jbe    800506 <vprintfmt+0x1e6>
					putch('?', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	6a 3f                	push   $0x3f
  80054a:	ff 55 08             	call   *0x8(%ebp)
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	eb c1                	jmp    800513 <vprintfmt+0x1f3>
  800552:	89 75 08             	mov    %esi,0x8(%ebp)
  800555:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800558:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055e:	eb b6                	jmp    800516 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	53                   	push   %ebx
  800564:	6a 20                	push   $0x20
  800566:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800568:	83 ef 01             	sub    $0x1,%edi
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	85 ff                	test   %edi,%edi
  800570:	7f ee                	jg     800560 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800572:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
  800578:	e9 78 01 00 00       	jmp    8006f5 <vprintfmt+0x3d5>
  80057d:	89 df                	mov    %ebx,%edi
  80057f:	8b 75 08             	mov    0x8(%ebp),%esi
  800582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800585:	eb e7                	jmp    80056e <vprintfmt+0x24e>
	if (lflag >= 2)
  800587:	83 f9 01             	cmp    $0x1,%ecx
  80058a:	7e 3f                	jle    8005cb <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 50 04             	mov    0x4(%eax),%edx
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800597:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 40 08             	lea    0x8(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a7:	79 5c                	jns    800605 <vprintfmt+0x2e5>
				putch('-', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 2d                	push   $0x2d
  8005af:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b7:	f7 da                	neg    %edx
  8005b9:	83 d1 00             	adc    $0x0,%ecx
  8005bc:	f7 d9                	neg    %ecx
  8005be:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c6:	e9 10 01 00 00       	jmp    8006db <vprintfmt+0x3bb>
	else if (lflag)
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	75 1b                	jne    8005ea <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d7:	89 c1                	mov    %eax,%ecx
  8005d9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 40 04             	lea    0x4(%eax),%eax
  8005e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e8:	eb b9                	jmp    8005a3 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8b 00                	mov    (%eax),%eax
  8005ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f2:	89 c1                	mov    %eax,%ecx
  8005f4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 40 04             	lea    0x4(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
  800603:	eb 9e                	jmp    8005a3 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800605:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800608:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80060b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800610:	e9 c6 00 00 00       	jmp    8006db <vprintfmt+0x3bb>
	if (lflag >= 2)
  800615:	83 f9 01             	cmp    $0x1,%ecx
  800618:	7e 18                	jle    800632 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	8b 48 04             	mov    0x4(%eax),%ecx
  800622:	8d 40 08             	lea    0x8(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800628:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062d:	e9 a9 00 00 00       	jmp    8006db <vprintfmt+0x3bb>
	else if (lflag)
  800632:	85 c9                	test   %ecx,%ecx
  800634:	75 1a                	jne    800650 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800640:	8d 40 04             	lea    0x4(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064b:	e9 8b 00 00 00       	jmp    8006db <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065a:	8d 40 04             	lea    0x4(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800660:	b8 0a 00 00 00       	mov    $0xa,%eax
  800665:	eb 74                	jmp    8006db <vprintfmt+0x3bb>
	if (lflag >= 2)
  800667:	83 f9 01             	cmp    $0x1,%ecx
  80066a:	7e 15                	jle    800681 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	8b 48 04             	mov    0x4(%eax),%ecx
  800674:	8d 40 08             	lea    0x8(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80067a:	b8 08 00 00 00       	mov    $0x8,%eax
  80067f:	eb 5a                	jmp    8006db <vprintfmt+0x3bb>
	else if (lflag)
  800681:	85 c9                	test   %ecx,%ecx
  800683:	75 17                	jne    80069c <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068f:	8d 40 04             	lea    0x4(%eax),%eax
  800692:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800695:	b8 08 00 00 00       	mov    $0x8,%eax
  80069a:	eb 3f                	jmp    8006db <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b1:	eb 28                	jmp    8006db <vprintfmt+0x3bb>
			putch('0', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 30                	push   $0x30
  8006b9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006bb:	83 c4 08             	add    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	6a 78                	push   $0x78
  8006c1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006cd:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006d0:	8d 40 04             	lea    0x4(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006db:	83 ec 0c             	sub    $0xc,%esp
  8006de:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e2:	57                   	push   %edi
  8006e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e6:	50                   	push   %eax
  8006e7:	51                   	push   %ecx
  8006e8:	52                   	push   %edx
  8006e9:	89 da                	mov    %ebx,%edx
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	e8 45 fb ff ff       	call   800237 <printnum>
			break;
  8006f2:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f8:	83 c7 01             	add    $0x1,%edi
  8006fb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ff:	83 f8 25             	cmp    $0x25,%eax
  800702:	0f 84 2f fc ff ff    	je     800337 <vprintfmt+0x17>
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 8b 00 00 00    	je     80079b <vprintfmt+0x47b>
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb dc                	jmp    8006f8 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80071c:	83 f9 01             	cmp    $0x1,%ecx
  80071f:	7e 15                	jle    800736 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8b 10                	mov    (%eax),%edx
  800726:	8b 48 04             	mov    0x4(%eax),%ecx
  800729:	8d 40 08             	lea    0x8(%eax),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072f:	b8 10 00 00 00       	mov    $0x10,%eax
  800734:	eb a5                	jmp    8006db <vprintfmt+0x3bb>
	else if (lflag)
  800736:	85 c9                	test   %ecx,%ecx
  800738:	75 17                	jne    800751 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8b 10                	mov    (%eax),%edx
  80073f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800744:	8d 40 04             	lea    0x4(%eax),%eax
  800747:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074a:	b8 10 00 00 00       	mov    $0x10,%eax
  80074f:	eb 8a                	jmp    8006db <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8b 10                	mov    (%eax),%edx
  800756:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075b:	8d 40 04             	lea    0x4(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800761:	b8 10 00 00 00       	mov    $0x10,%eax
  800766:	e9 70 ff ff ff       	jmp    8006db <vprintfmt+0x3bb>
			putch(ch, putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	53                   	push   %ebx
  80076f:	6a 25                	push   $0x25
  800771:	ff d6                	call   *%esi
			break;
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	e9 7a ff ff ff       	jmp    8006f5 <vprintfmt+0x3d5>
			putch('%', putdat);
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 25                	push   $0x25
  800781:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	89 f8                	mov    %edi,%eax
  800788:	eb 03                	jmp    80078d <vprintfmt+0x46d>
  80078a:	83 e8 01             	sub    $0x1,%eax
  80078d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800791:	75 f7                	jne    80078a <vprintfmt+0x46a>
  800793:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800796:	e9 5a ff ff ff       	jmp    8006f5 <vprintfmt+0x3d5>
}
  80079b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5f                   	pop    %edi
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	83 ec 18             	sub    $0x18,%esp
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c0:	85 c0                	test   %eax,%eax
  8007c2:	74 26                	je     8007ea <vsnprintf+0x47>
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	7e 22                	jle    8007ea <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c8:	ff 75 14             	pushl  0x14(%ebp)
  8007cb:	ff 75 10             	pushl  0x10(%ebp)
  8007ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d1:	50                   	push   %eax
  8007d2:	68 e6 02 80 00       	push   $0x8002e6
  8007d7:	e8 44 fb ff ff       	call   800320 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007df:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e5:	83 c4 10             	add    $0x10,%esp
}
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    
		return -E_INVAL;
  8007ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ef:	eb f7                	jmp    8007e8 <vsnprintf+0x45>

008007f1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fa:	50                   	push   %eax
  8007fb:	ff 75 10             	pushl  0x10(%ebp)
  8007fe:	ff 75 0c             	pushl  0xc(%ebp)
  800801:	ff 75 08             	pushl  0x8(%ebp)
  800804:	e8 9a ff ff ff       	call   8007a3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
  800816:	eb 03                	jmp    80081b <strlen+0x10>
		n++;
  800818:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80081b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081f:	75 f7                	jne    800818 <strlen+0xd>
	return n;
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
  800831:	eb 03                	jmp    800836 <strnlen+0x13>
		n++;
  800833:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800836:	39 d0                	cmp    %edx,%eax
  800838:	74 06                	je     800840 <strnlen+0x1d>
  80083a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80083e:	75 f3                	jne    800833 <strnlen+0x10>
	return n;
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084c:	89 c2                	mov    %eax,%edx
  80084e:	83 c1 01             	add    $0x1,%ecx
  800851:	83 c2 01             	add    $0x1,%edx
  800854:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800858:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085b:	84 db                	test   %bl,%bl
  80085d:	75 ef                	jne    80084e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80085f:	5b                   	pop    %ebx
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800869:	53                   	push   %ebx
  80086a:	e8 9c ff ff ff       	call   80080b <strlen>
  80086f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800872:	ff 75 0c             	pushl  0xc(%ebp)
  800875:	01 d8                	add    %ebx,%eax
  800877:	50                   	push   %eax
  800878:	e8 c5 ff ff ff       	call   800842 <strcpy>
	return dst;
}
  80087d:	89 d8                	mov    %ebx,%eax
  80087f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 75 08             	mov    0x8(%ebp),%esi
  80088c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088f:	89 f3                	mov    %esi,%ebx
  800891:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800894:	89 f2                	mov    %esi,%edx
  800896:	eb 0f                	jmp    8008a7 <strncpy+0x23>
		*dst++ = *src;
  800898:	83 c2 01             	add    $0x1,%edx
  80089b:	0f b6 01             	movzbl (%ecx),%eax
  80089e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a1:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a4:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008a7:	39 da                	cmp    %ebx,%edx
  8008a9:	75 ed                	jne    800898 <strncpy+0x14>
	}
	return ret;
}
  8008ab:	89 f0                	mov    %esi,%eax
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	56                   	push   %esi
  8008b5:	53                   	push   %ebx
  8008b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008bf:	89 f0                	mov    %esi,%eax
  8008c1:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	75 0b                	jne    8008d4 <strlcpy+0x23>
  8008c9:	eb 17                	jmp    8008e2 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008cb:	83 c2 01             	add    $0x1,%edx
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008d4:	39 d8                	cmp    %ebx,%eax
  8008d6:	74 07                	je     8008df <strlcpy+0x2e>
  8008d8:	0f b6 0a             	movzbl (%edx),%ecx
  8008db:	84 c9                	test   %cl,%cl
  8008dd:	75 ec                	jne    8008cb <strlcpy+0x1a>
		*dst = '\0';
  8008df:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e2:	29 f0                	sub    %esi,%eax
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	5e                   	pop    %esi
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f1:	eb 06                	jmp    8008f9 <strcmp+0x11>
		p++, q++;
  8008f3:	83 c1 01             	add    $0x1,%ecx
  8008f6:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008f9:	0f b6 01             	movzbl (%ecx),%eax
  8008fc:	84 c0                	test   %al,%al
  8008fe:	74 04                	je     800904 <strcmp+0x1c>
  800900:	3a 02                	cmp    (%edx),%al
  800902:	74 ef                	je     8008f3 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800904:	0f b6 c0             	movzbl %al,%eax
  800907:	0f b6 12             	movzbl (%edx),%edx
  80090a:	29 d0                	sub    %edx,%eax
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	53                   	push   %ebx
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 55 0c             	mov    0xc(%ebp),%edx
  800918:	89 c3                	mov    %eax,%ebx
  80091a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80091d:	eb 06                	jmp    800925 <strncmp+0x17>
		n--, p++, q++;
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800925:	39 d8                	cmp    %ebx,%eax
  800927:	74 16                	je     80093f <strncmp+0x31>
  800929:	0f b6 08             	movzbl (%eax),%ecx
  80092c:	84 c9                	test   %cl,%cl
  80092e:	74 04                	je     800934 <strncmp+0x26>
  800930:	3a 0a                	cmp    (%edx),%cl
  800932:	74 eb                	je     80091f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800934:	0f b6 00             	movzbl (%eax),%eax
  800937:	0f b6 12             	movzbl (%edx),%edx
  80093a:	29 d0                	sub    %edx,%eax
}
  80093c:	5b                   	pop    %ebx
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    
		return 0;
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
  800944:	eb f6                	jmp    80093c <strncmp+0x2e>

00800946 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800950:	0f b6 10             	movzbl (%eax),%edx
  800953:	84 d2                	test   %dl,%dl
  800955:	74 09                	je     800960 <strchr+0x1a>
		if (*s == c)
  800957:	38 ca                	cmp    %cl,%dl
  800959:	74 0a                	je     800965 <strchr+0x1f>
	for (; *s; s++)
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	eb f0                	jmp    800950 <strchr+0xa>
			return (char *) s;
	return 0;
  800960:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800971:	eb 03                	jmp    800976 <strfind+0xf>
  800973:	83 c0 01             	add    $0x1,%eax
  800976:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800979:	38 ca                	cmp    %cl,%dl
  80097b:	74 04                	je     800981 <strfind+0x1a>
  80097d:	84 d2                	test   %dl,%dl
  80097f:	75 f2                	jne    800973 <strfind+0xc>
			break;
	return (char *) s;
}
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80098f:	85 c9                	test   %ecx,%ecx
  800991:	74 13                	je     8009a6 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800993:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800999:	75 05                	jne    8009a0 <memset+0x1d>
  80099b:	f6 c1 03             	test   $0x3,%cl
  80099e:	74 0d                	je     8009ad <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	fc                   	cld    
  8009a4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a6:	89 f8                	mov    %edi,%eax
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    
		c &= 0xFF;
  8009ad:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b1:	89 d3                	mov    %edx,%ebx
  8009b3:	c1 e3 08             	shl    $0x8,%ebx
  8009b6:	89 d0                	mov    %edx,%eax
  8009b8:	c1 e0 18             	shl    $0x18,%eax
  8009bb:	89 d6                	mov    %edx,%esi
  8009bd:	c1 e6 10             	shl    $0x10,%esi
  8009c0:	09 f0                	or     %esi,%eax
  8009c2:	09 c2                	or     %eax,%edx
  8009c4:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009c9:	89 d0                	mov    %edx,%eax
  8009cb:	fc                   	cld    
  8009cc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ce:	eb d6                	jmp    8009a6 <memset+0x23>

008009d0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009db:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009de:	39 c6                	cmp    %eax,%esi
  8009e0:	73 35                	jae    800a17 <memmove+0x47>
  8009e2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e5:	39 c2                	cmp    %eax,%edx
  8009e7:	76 2e                	jbe    800a17 <memmove+0x47>
		s += n;
		d += n;
  8009e9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ec:	89 d6                	mov    %edx,%esi
  8009ee:	09 fe                	or     %edi,%esi
  8009f0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f6:	74 0c                	je     800a04 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f8:	83 ef 01             	sub    $0x1,%edi
  8009fb:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009fe:	fd                   	std    
  8009ff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a01:	fc                   	cld    
  800a02:	eb 21                	jmp    800a25 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a04:	f6 c1 03             	test   $0x3,%cl
  800a07:	75 ef                	jne    8009f8 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a09:	83 ef 04             	sub    $0x4,%edi
  800a0c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a12:	fd                   	std    
  800a13:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a15:	eb ea                	jmp    800a01 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a17:	89 f2                	mov    %esi,%edx
  800a19:	09 c2                	or     %eax,%edx
  800a1b:	f6 c2 03             	test   $0x3,%dl
  800a1e:	74 09                	je     800a29 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a29:	f6 c1 03             	test   $0x3,%cl
  800a2c:	75 f2                	jne    800a20 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a31:	89 c7                	mov    %eax,%edi
  800a33:	fc                   	cld    
  800a34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a36:	eb ed                	jmp    800a25 <memmove+0x55>

00800a38 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a3b:	ff 75 10             	pushl  0x10(%ebp)
  800a3e:	ff 75 0c             	pushl  0xc(%ebp)
  800a41:	ff 75 08             	pushl  0x8(%ebp)
  800a44:	e8 87 ff ff ff       	call   8009d0 <memmove>
}
  800a49:	c9                   	leave  
  800a4a:	c3                   	ret    

00800a4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a56:	89 c6                	mov    %eax,%esi
  800a58:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5b:	39 f0                	cmp    %esi,%eax
  800a5d:	74 1c                	je     800a7b <memcmp+0x30>
		if (*s1 != *s2)
  800a5f:	0f b6 08             	movzbl (%eax),%ecx
  800a62:	0f b6 1a             	movzbl (%edx),%ebx
  800a65:	38 d9                	cmp    %bl,%cl
  800a67:	75 08                	jne    800a71 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
  800a6f:	eb ea                	jmp    800a5b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a71:	0f b6 c1             	movzbl %cl,%eax
  800a74:	0f b6 db             	movzbl %bl,%ebx
  800a77:	29 d8                	sub    %ebx,%eax
  800a79:	eb 05                	jmp    800a80 <memcmp+0x35>
	}

	return 0;
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8d:	89 c2                	mov    %eax,%edx
  800a8f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a92:	39 d0                	cmp    %edx,%eax
  800a94:	73 09                	jae    800a9f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a96:	38 08                	cmp    %cl,(%eax)
  800a98:	74 05                	je     800a9f <memfind+0x1b>
	for (; s < ends; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	eb f3                	jmp    800a92 <memfind+0xe>
			break;
	return (void *) s;
}
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
  800aa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aad:	eb 03                	jmp    800ab2 <strtol+0x11>
		s++;
  800aaf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ab2:	0f b6 01             	movzbl (%ecx),%eax
  800ab5:	3c 20                	cmp    $0x20,%al
  800ab7:	74 f6                	je     800aaf <strtol+0xe>
  800ab9:	3c 09                	cmp    $0x9,%al
  800abb:	74 f2                	je     800aaf <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800abd:	3c 2b                	cmp    $0x2b,%al
  800abf:	74 2e                	je     800aef <strtol+0x4e>
	int neg = 0;
  800ac1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ac6:	3c 2d                	cmp    $0x2d,%al
  800ac8:	74 2f                	je     800af9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aca:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad0:	75 05                	jne    800ad7 <strtol+0x36>
  800ad2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad5:	74 2c                	je     800b03 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad7:	85 db                	test   %ebx,%ebx
  800ad9:	75 0a                	jne    800ae5 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adb:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ae0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae3:	74 28                	je     800b0d <strtol+0x6c>
		base = 10;
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aed:	eb 50                	jmp    800b3f <strtol+0x9e>
		s++;
  800aef:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800af2:	bf 00 00 00 00       	mov    $0x0,%edi
  800af7:	eb d1                	jmp    800aca <strtol+0x29>
		s++, neg = 1;
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	bf 01 00 00 00       	mov    $0x1,%edi
  800b01:	eb c7                	jmp    800aca <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b03:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b07:	74 0e                	je     800b17 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b09:	85 db                	test   %ebx,%ebx
  800b0b:	75 d8                	jne    800ae5 <strtol+0x44>
		s++, base = 8;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b15:	eb ce                	jmp    800ae5 <strtol+0x44>
		s += 2, base = 16;
  800b17:	83 c1 02             	add    $0x2,%ecx
  800b1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1f:	eb c4                	jmp    800ae5 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b21:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b24:	89 f3                	mov    %esi,%ebx
  800b26:	80 fb 19             	cmp    $0x19,%bl
  800b29:	77 29                	ja     800b54 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b2b:	0f be d2             	movsbl %dl,%edx
  800b2e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b31:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b34:	7d 30                	jge    800b66 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b36:	83 c1 01             	add    $0x1,%ecx
  800b39:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b3f:	0f b6 11             	movzbl (%ecx),%edx
  800b42:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b45:	89 f3                	mov    %esi,%ebx
  800b47:	80 fb 09             	cmp    $0x9,%bl
  800b4a:	77 d5                	ja     800b21 <strtol+0x80>
			dig = *s - '0';
  800b4c:	0f be d2             	movsbl %dl,%edx
  800b4f:	83 ea 30             	sub    $0x30,%edx
  800b52:	eb dd                	jmp    800b31 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b54:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b57:	89 f3                	mov    %esi,%ebx
  800b59:	80 fb 19             	cmp    $0x19,%bl
  800b5c:	77 08                	ja     800b66 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b5e:	0f be d2             	movsbl %dl,%edx
  800b61:	83 ea 37             	sub    $0x37,%edx
  800b64:	eb cb                	jmp    800b31 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6a:	74 05                	je     800b71 <strtol+0xd0>
		*endptr = (char *) s;
  800b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	f7 da                	neg    %edx
  800b75:	85 ff                	test   %edi,%edi
  800b77:	0f 45 c2             	cmovne %edx,%eax
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	89 c3                	mov    %eax,%ebx
  800b92:	89 c7                	mov    %eax,%edi
  800b94:	89 c6                	mov    %eax,%esi
  800b96:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd2:	89 cb                	mov    %ecx,%ebx
  800bd4:	89 cf                	mov    %ecx,%edi
  800bd6:	89 ce                	mov    %ecx,%esi
  800bd8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7f 08                	jg     800be6 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 03                	push   $0x3
  800bec:	68 5f 25 80 00       	push   $0x80255f
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 7c 25 80 00       	push   $0x80257c
  800bf8:	e8 4b f5 ff ff       	call   800148 <_panic>

00800bfd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c03:	ba 00 00 00 00       	mov    $0x0,%edx
  800c08:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0d:	89 d1                	mov    %edx,%ecx
  800c0f:	89 d3                	mov    %edx,%ebx
  800c11:	89 d7                	mov    %edx,%edi
  800c13:	89 d6                	mov    %edx,%esi
  800c15:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_yield>:

void
sys_yield(void)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
  800c27:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2c:	89 d1                	mov    %edx,%ecx
  800c2e:	89 d3                	mov    %edx,%ebx
  800c30:	89 d7                	mov    %edx,%edi
  800c32:	89 d6                	mov    %edx,%esi
  800c34:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c44:	be 00 00 00 00       	mov    $0x0,%esi
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c57:	89 f7                	mov    %esi,%edi
  800c59:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	7f 08                	jg     800c67 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 04                	push   $0x4
  800c6d:	68 5f 25 80 00       	push   $0x80255f
  800c72:	6a 23                	push   $0x23
  800c74:	68 7c 25 80 00       	push   $0x80257c
  800c79:	e8 ca f4 ff ff       	call   800148 <_panic>

00800c7e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c95:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c98:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7f 08                	jg     800ca9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 05                	push   $0x5
  800caf:	68 5f 25 80 00       	push   $0x80255f
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 7c 25 80 00       	push   $0x80257c
  800cbb:	e8 88 f4 ff ff       	call   800148 <_panic>

00800cc0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd9:	89 df                	mov    %ebx,%edi
  800cdb:	89 de                	mov    %ebx,%esi
  800cdd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7f 08                	jg     800ceb <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	50                   	push   %eax
  800cef:	6a 06                	push   $0x6
  800cf1:	68 5f 25 80 00       	push   $0x80255f
  800cf6:	6a 23                	push   $0x23
  800cf8:	68 7c 25 80 00       	push   $0x80257c
  800cfd:	e8 46 f4 ff ff       	call   800148 <_panic>

00800d02 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1b:	89 df                	mov    %ebx,%edi
  800d1d:	89 de                	mov    %ebx,%esi
  800d1f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d21:	85 c0                	test   %eax,%eax
  800d23:	7f 08                	jg     800d2d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 08                	push   $0x8
  800d33:	68 5f 25 80 00       	push   $0x80255f
  800d38:	6a 23                	push   $0x23
  800d3a:	68 7c 25 80 00       	push   $0x80257c
  800d3f:	e8 04 f4 ff ff       	call   800148 <_panic>

00800d44 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5d:	89 df                	mov    %ebx,%edi
  800d5f:	89 de                	mov    %ebx,%esi
  800d61:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7f 08                	jg     800d6f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 09                	push   $0x9
  800d75:	68 5f 25 80 00       	push   $0x80255f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 7c 25 80 00       	push   $0x80257c
  800d81:	e8 c2 f3 ff ff       	call   800148 <_panic>

00800d86 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9f:	89 df                	mov    %ebx,%edi
  800da1:	89 de                	mov    %ebx,%esi
  800da3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7f 08                	jg     800db1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 0a                	push   $0xa
  800db7:	68 5f 25 80 00       	push   $0x80255f
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 7c 25 80 00       	push   $0x80257c
  800dc3:	e8 80 f3 ff ff       	call   800148 <_panic>

00800dc8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd9:	be 00 00 00 00       	mov    $0x0,%esi
  800dde:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e01:	89 cb                	mov    %ecx,%ebx
  800e03:	89 cf                	mov    %ecx,%edi
  800e05:	89 ce                	mov    %ecx,%esi
  800e07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7f 08                	jg     800e15 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e15:	83 ec 0c             	sub    $0xc,%esp
  800e18:	50                   	push   %eax
  800e19:	6a 0d                	push   $0xd
  800e1b:	68 5f 25 80 00       	push   $0x80255f
  800e20:	6a 23                	push   $0x23
  800e22:	68 7c 25 80 00       	push   $0x80257c
  800e27:	e8 1c f3 ff ff       	call   800148 <_panic>

00800e2c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 04             	sub    $0x4,%esp
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e36:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e38:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e3c:	0f 84 9c 00 00 00    	je     800ede <pgfault+0xb2>
  800e42:	89 c2                	mov    %eax,%edx
  800e44:	c1 ea 16             	shr    $0x16,%edx
  800e47:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4e:	f6 c2 01             	test   $0x1,%dl
  800e51:	0f 84 87 00 00 00    	je     800ede <pgfault+0xb2>
  800e57:	89 c2                	mov    %eax,%edx
  800e59:	c1 ea 0c             	shr    $0xc,%edx
  800e5c:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e63:	f6 c1 01             	test   $0x1,%cl
  800e66:	74 76                	je     800ede <pgfault+0xb2>
  800e68:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e6f:	f6 c6 08             	test   $0x8,%dh
  800e72:	74 6a                	je     800ede <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  800e74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e79:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800e7b:	83 ec 04             	sub    $0x4,%esp
  800e7e:	6a 07                	push   $0x7
  800e80:	68 00 f0 7f 00       	push   $0x7ff000
  800e85:	6a 00                	push   $0x0
  800e87:	e8 af fd ff ff       	call   800c3b <sys_page_alloc>
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 5f                	js     800ef2 <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	68 00 10 00 00       	push   $0x1000
  800e9b:	53                   	push   %ebx
  800e9c:	68 00 f0 7f 00       	push   $0x7ff000
  800ea1:	e8 92 fb ff ff       	call   800a38 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800ea6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ead:	53                   	push   %ebx
  800eae:	6a 00                	push   $0x0
  800eb0:	68 00 f0 7f 00       	push   $0x7ff000
  800eb5:	6a 00                	push   $0x0
  800eb7:	e8 c2 fd ff ff       	call   800c7e <sys_page_map>
  800ebc:	83 c4 20             	add    $0x20,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	78 43                	js     800f06 <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  800ec3:	83 ec 08             	sub    $0x8,%esp
  800ec6:	68 00 f0 7f 00       	push   $0x7ff000
  800ecb:	6a 00                	push   $0x0
  800ecd:	e8 ee fd ff ff       	call   800cc0 <sys_page_unmap>
  800ed2:	83 c4 10             	add    $0x10,%esp
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	78 41                	js     800f1a <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  800ed9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edc:	c9                   	leave  
  800edd:	c3                   	ret    
		panic("not copy-on-write");
  800ede:	83 ec 04             	sub    $0x4,%esp
  800ee1:	68 8a 25 80 00       	push   $0x80258a
  800ee6:	6a 25                	push   $0x25
  800ee8:	68 9c 25 80 00       	push   $0x80259c
  800eed:	e8 56 f2 ff ff       	call   800148 <_panic>
		panic("sys_page_alloc");
  800ef2:	83 ec 04             	sub    $0x4,%esp
  800ef5:	68 a7 25 80 00       	push   $0x8025a7
  800efa:	6a 28                	push   $0x28
  800efc:	68 9c 25 80 00       	push   $0x80259c
  800f01:	e8 42 f2 ff ff       	call   800148 <_panic>
		panic("sys_page_map");
  800f06:	83 ec 04             	sub    $0x4,%esp
  800f09:	68 b6 25 80 00       	push   $0x8025b6
  800f0e:	6a 2b                	push   $0x2b
  800f10:	68 9c 25 80 00       	push   $0x80259c
  800f15:	e8 2e f2 ff ff       	call   800148 <_panic>
		panic("sys_page_unmap");
  800f1a:	83 ec 04             	sub    $0x4,%esp
  800f1d:	68 c3 25 80 00       	push   $0x8025c3
  800f22:	6a 2d                	push   $0x2d
  800f24:	68 9c 25 80 00       	push   $0x80259c
  800f29:	e8 1a f2 ff ff       	call   800148 <_panic>

00800f2e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f37:	68 2c 0e 80 00       	push   $0x800e2c
  800f3c:	e8 8b 0e 00 00       	call   801dcc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f41:	b8 07 00 00 00       	mov    $0x7,%eax
  800f46:	cd 30                	int    $0x30
  800f48:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	74 12                	je     800f64 <fork+0x36>
  800f52:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  800f54:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f58:	78 26                	js     800f80 <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5f:	e9 94 00 00 00       	jmp    800ff8 <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f64:	e8 94 fc ff ff       	call   800bfd <sys_getenvid>
  800f69:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f6e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f71:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f76:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f7b:	e9 51 01 00 00       	jmp    8010d1 <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  800f80:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f83:	68 d2 25 80 00       	push   $0x8025d2
  800f88:	6a 6e                	push   $0x6e
  800f8a:	68 9c 25 80 00       	push   $0x80259c
  800f8f:	e8 b4 f1 ff ff       	call   800148 <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	68 07 0e 00 00       	push   $0xe07
  800f9c:	56                   	push   %esi
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	6a 00                	push   $0x0
  800fa1:	e8 d8 fc ff ff       	call   800c7e <sys_page_map>
  800fa6:	83 c4 20             	add    $0x20,%esp
  800fa9:	eb 3b                	jmp    800fe6 <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	68 05 08 00 00       	push   $0x805
  800fb3:	56                   	push   %esi
  800fb4:	57                   	push   %edi
  800fb5:	56                   	push   %esi
  800fb6:	6a 00                	push   $0x0
  800fb8:	e8 c1 fc ff ff       	call   800c7e <sys_page_map>
  800fbd:	83 c4 20             	add    $0x20,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	0f 88 a9 00 00 00    	js     801071 <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800fc8:	83 ec 0c             	sub    $0xc,%esp
  800fcb:	68 05 08 00 00       	push   $0x805
  800fd0:	56                   	push   %esi
  800fd1:	6a 00                	push   $0x0
  800fd3:	56                   	push   %esi
  800fd4:	6a 00                	push   $0x0
  800fd6:	e8 a3 fc ff ff       	call   800c7e <sys_page_map>
  800fdb:	83 c4 20             	add    $0x20,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	0f 88 9d 00 00 00    	js     801083 <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800fe6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fec:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800ff2:	0f 84 9d 00 00 00    	je     801095 <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800ff8:	89 d8                	mov    %ebx,%eax
  800ffa:	c1 e8 16             	shr    $0x16,%eax
  800ffd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801004:	a8 01                	test   $0x1,%al
  801006:	74 de                	je     800fe6 <fork+0xb8>
  801008:	89 d8                	mov    %ebx,%eax
  80100a:	c1 e8 0c             	shr    $0xc,%eax
  80100d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801014:	f6 c2 01             	test   $0x1,%dl
  801017:	74 cd                	je     800fe6 <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801019:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801020:	f6 c2 04             	test   $0x4,%dl
  801023:	74 c1                	je     800fe6 <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  801025:	89 c6                	mov    %eax,%esi
  801027:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  80102a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801031:	f6 c6 04             	test   $0x4,%dh
  801034:	0f 85 5a ff ff ff    	jne    800f94 <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  80103a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801041:	f6 c2 02             	test   $0x2,%dl
  801044:	0f 85 61 ff ff ff    	jne    800fab <fork+0x7d>
  80104a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801051:	f6 c4 08             	test   $0x8,%ah
  801054:	0f 85 51 ff ff ff    	jne    800fab <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	6a 05                	push   $0x5
  80105f:	56                   	push   %esi
  801060:	57                   	push   %edi
  801061:	56                   	push   %esi
  801062:	6a 00                	push   $0x0
  801064:	e8 15 fc ff ff       	call   800c7e <sys_page_map>
  801069:	83 c4 20             	add    $0x20,%esp
  80106c:	e9 75 ff ff ff       	jmp    800fe6 <fork+0xb8>
            		panic("sys_page_map：%e", r);
  801071:	50                   	push   %eax
  801072:	68 e2 25 80 00       	push   $0x8025e2
  801077:	6a 47                	push   $0x47
  801079:	68 9c 25 80 00       	push   $0x80259c
  80107e:	e8 c5 f0 ff ff       	call   800148 <_panic>
            		panic("sys_page_map：%e", r);
  801083:	50                   	push   %eax
  801084:	68 e2 25 80 00       	push   $0x8025e2
  801089:	6a 49                	push   $0x49
  80108b:	68 9c 25 80 00       	push   $0x80259c
  801090:	e8 b3 f0 ff ff       	call   800148 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801095:	83 ec 04             	sub    $0x4,%esp
  801098:	6a 07                	push   $0x7
  80109a:	68 00 f0 bf ee       	push   $0xeebff000
  80109f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a2:	e8 94 fb ff ff       	call   800c3b <sys_page_alloc>
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	78 2e                	js     8010dc <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010ae:	83 ec 08             	sub    $0x8,%esp
  8010b1:	68 3b 1e 80 00       	push   $0x801e3b
  8010b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010b9:	57                   	push   %edi
  8010ba:	e8 c7 fc ff ff       	call   800d86 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8010bf:	83 c4 08             	add    $0x8,%esp
  8010c2:	6a 02                	push   $0x2
  8010c4:	57                   	push   %edi
  8010c5:	e8 38 fc ff ff       	call   800d02 <sys_env_set_status>
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	78 1f                	js     8010f0 <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  8010d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    
		panic("1");
  8010dc:	83 ec 04             	sub    $0x4,%esp
  8010df:	68 f4 25 80 00       	push   $0x8025f4
  8010e4:	6a 77                	push   $0x77
  8010e6:	68 9c 25 80 00       	push   $0x80259c
  8010eb:	e8 58 f0 ff ff       	call   800148 <_panic>
		panic("sys_env_set_status");
  8010f0:	83 ec 04             	sub    $0x4,%esp
  8010f3:	68 f6 25 80 00       	push   $0x8025f6
  8010f8:	6a 7c                	push   $0x7c
  8010fa:	68 9c 25 80 00       	push   $0x80259c
  8010ff:	e8 44 f0 ff ff       	call   800148 <_panic>

00801104 <sfork>:

// Challenge!
int
sfork(void)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80110a:	68 09 26 80 00       	push   $0x802609
  80110f:	68 86 00 00 00       	push   $0x86
  801114:	68 9c 25 80 00       	push   $0x80259c
  801119:	e8 2a f0 ff ff       	call   800148 <_panic>

0080111e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801121:	8b 45 08             	mov    0x8(%ebp),%eax
  801124:	05 00 00 00 30       	add    $0x30000000,%eax
  801129:	c1 e8 0c             	shr    $0xc,%eax
}
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801131:	8b 45 08             	mov    0x8(%ebp),%eax
  801134:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801139:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80113e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801150:	89 c2                	mov    %eax,%edx
  801152:	c1 ea 16             	shr    $0x16,%edx
  801155:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80115c:	f6 c2 01             	test   $0x1,%dl
  80115f:	74 2a                	je     80118b <fd_alloc+0x46>
  801161:	89 c2                	mov    %eax,%edx
  801163:	c1 ea 0c             	shr    $0xc,%edx
  801166:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80116d:	f6 c2 01             	test   $0x1,%dl
  801170:	74 19                	je     80118b <fd_alloc+0x46>
  801172:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801177:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80117c:	75 d2                	jne    801150 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80117e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801184:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801189:	eb 07                	jmp    801192 <fd_alloc+0x4d>
			*fd_store = fd;
  80118b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80119a:	83 f8 1f             	cmp    $0x1f,%eax
  80119d:	77 36                	ja     8011d5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80119f:	c1 e0 0c             	shl    $0xc,%eax
  8011a2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	c1 ea 16             	shr    $0x16,%edx
  8011ac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b3:	f6 c2 01             	test   $0x1,%dl
  8011b6:	74 24                	je     8011dc <fd_lookup+0x48>
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	c1 ea 0c             	shr    $0xc,%edx
  8011bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c4:	f6 c2 01             	test   $0x1,%dl
  8011c7:	74 1a                	je     8011e3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011cc:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    
		return -E_INVAL;
  8011d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011da:	eb f7                	jmp    8011d3 <fd_lookup+0x3f>
		return -E_INVAL;
  8011dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e1:	eb f0                	jmp    8011d3 <fd_lookup+0x3f>
  8011e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e8:	eb e9                	jmp    8011d3 <fd_lookup+0x3f>

008011ea <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	83 ec 08             	sub    $0x8,%esp
  8011f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f3:	ba 9c 26 80 00       	mov    $0x80269c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011f8:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8011fd:	39 08                	cmp    %ecx,(%eax)
  8011ff:	74 33                	je     801234 <dev_lookup+0x4a>
  801201:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801204:	8b 02                	mov    (%edx),%eax
  801206:	85 c0                	test   %eax,%eax
  801208:	75 f3                	jne    8011fd <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80120a:	a1 08 40 80 00       	mov    0x804008,%eax
  80120f:	8b 40 48             	mov    0x48(%eax),%eax
  801212:	83 ec 04             	sub    $0x4,%esp
  801215:	51                   	push   %ecx
  801216:	50                   	push   %eax
  801217:	68 20 26 80 00       	push   $0x802620
  80121c:	e8 02 f0 ff ff       	call   800223 <cprintf>
	*dev = 0;
  801221:	8b 45 0c             	mov    0xc(%ebp),%eax
  801224:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801232:	c9                   	leave  
  801233:	c3                   	ret    
			*dev = devtab[i];
  801234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801237:	89 01                	mov    %eax,(%ecx)
			return 0;
  801239:	b8 00 00 00 00       	mov    $0x0,%eax
  80123e:	eb f2                	jmp    801232 <dev_lookup+0x48>

00801240 <fd_close>:
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	57                   	push   %edi
  801244:	56                   	push   %esi
  801245:	53                   	push   %ebx
  801246:	83 ec 1c             	sub    $0x1c,%esp
  801249:	8b 75 08             	mov    0x8(%ebp),%esi
  80124c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80124f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801252:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801253:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801259:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80125c:	50                   	push   %eax
  80125d:	e8 32 ff ff ff       	call   801194 <fd_lookup>
  801262:	89 c3                	mov    %eax,%ebx
  801264:	83 c4 08             	add    $0x8,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 05                	js     801270 <fd_close+0x30>
	    || fd != fd2)
  80126b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80126e:	74 16                	je     801286 <fd_close+0x46>
		return (must_exist ? r : 0);
  801270:	89 f8                	mov    %edi,%eax
  801272:	84 c0                	test   %al,%al
  801274:	b8 00 00 00 00       	mov    $0x0,%eax
  801279:	0f 44 d8             	cmove  %eax,%ebx
}
  80127c:	89 d8                	mov    %ebx,%eax
  80127e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801281:	5b                   	pop    %ebx
  801282:	5e                   	pop    %esi
  801283:	5f                   	pop    %edi
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80128c:	50                   	push   %eax
  80128d:	ff 36                	pushl  (%esi)
  80128f:	e8 56 ff ff ff       	call   8011ea <dev_lookup>
  801294:	89 c3                	mov    %eax,%ebx
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	85 c0                	test   %eax,%eax
  80129b:	78 15                	js     8012b2 <fd_close+0x72>
		if (dev->dev_close)
  80129d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012a0:	8b 40 10             	mov    0x10(%eax),%eax
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	74 1b                	je     8012c2 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8012a7:	83 ec 0c             	sub    $0xc,%esp
  8012aa:	56                   	push   %esi
  8012ab:	ff d0                	call   *%eax
  8012ad:	89 c3                	mov    %eax,%ebx
  8012af:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	56                   	push   %esi
  8012b6:	6a 00                	push   $0x0
  8012b8:	e8 03 fa ff ff       	call   800cc0 <sys_page_unmap>
	return r;
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	eb ba                	jmp    80127c <fd_close+0x3c>
			r = 0;
  8012c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c7:	eb e9                	jmp    8012b2 <fd_close+0x72>

008012c9 <close>:

int
close(int fdnum)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d2:	50                   	push   %eax
  8012d3:	ff 75 08             	pushl  0x8(%ebp)
  8012d6:	e8 b9 fe ff ff       	call   801194 <fd_lookup>
  8012db:	83 c4 08             	add    $0x8,%esp
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	78 10                	js     8012f2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012e2:	83 ec 08             	sub    $0x8,%esp
  8012e5:	6a 01                	push   $0x1
  8012e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ea:	e8 51 ff ff ff       	call   801240 <fd_close>
  8012ef:	83 c4 10             	add    $0x10,%esp
}
  8012f2:	c9                   	leave  
  8012f3:	c3                   	ret    

008012f4 <close_all>:

void
close_all(void)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	53                   	push   %ebx
  8012f8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012fb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801300:	83 ec 0c             	sub    $0xc,%esp
  801303:	53                   	push   %ebx
  801304:	e8 c0 ff ff ff       	call   8012c9 <close>
	for (i = 0; i < MAXFD; i++)
  801309:	83 c3 01             	add    $0x1,%ebx
  80130c:	83 c4 10             	add    $0x10,%esp
  80130f:	83 fb 20             	cmp    $0x20,%ebx
  801312:	75 ec                	jne    801300 <close_all+0xc>
}
  801314:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801317:	c9                   	leave  
  801318:	c3                   	ret    

00801319 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	57                   	push   %edi
  80131d:	56                   	push   %esi
  80131e:	53                   	push   %ebx
  80131f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801322:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	ff 75 08             	pushl  0x8(%ebp)
  801329:	e8 66 fe ff ff       	call   801194 <fd_lookup>
  80132e:	89 c3                	mov    %eax,%ebx
  801330:	83 c4 08             	add    $0x8,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	0f 88 81 00 00 00    	js     8013bc <dup+0xa3>
		return r;
	close(newfdnum);
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	ff 75 0c             	pushl  0xc(%ebp)
  801341:	e8 83 ff ff ff       	call   8012c9 <close>

	newfd = INDEX2FD(newfdnum);
  801346:	8b 75 0c             	mov    0xc(%ebp),%esi
  801349:	c1 e6 0c             	shl    $0xc,%esi
  80134c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801352:	83 c4 04             	add    $0x4,%esp
  801355:	ff 75 e4             	pushl  -0x1c(%ebp)
  801358:	e8 d1 fd ff ff       	call   80112e <fd2data>
  80135d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80135f:	89 34 24             	mov    %esi,(%esp)
  801362:	e8 c7 fd ff ff       	call   80112e <fd2data>
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80136c:	89 d8                	mov    %ebx,%eax
  80136e:	c1 e8 16             	shr    $0x16,%eax
  801371:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801378:	a8 01                	test   $0x1,%al
  80137a:	74 11                	je     80138d <dup+0x74>
  80137c:	89 d8                	mov    %ebx,%eax
  80137e:	c1 e8 0c             	shr    $0xc,%eax
  801381:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801388:	f6 c2 01             	test   $0x1,%dl
  80138b:	75 39                	jne    8013c6 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80138d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801390:	89 d0                	mov    %edx,%eax
  801392:	c1 e8 0c             	shr    $0xc,%eax
  801395:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80139c:	83 ec 0c             	sub    $0xc,%esp
  80139f:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a4:	50                   	push   %eax
  8013a5:	56                   	push   %esi
  8013a6:	6a 00                	push   $0x0
  8013a8:	52                   	push   %edx
  8013a9:	6a 00                	push   $0x0
  8013ab:	e8 ce f8 ff ff       	call   800c7e <sys_page_map>
  8013b0:	89 c3                	mov    %eax,%ebx
  8013b2:	83 c4 20             	add    $0x20,%esp
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	78 31                	js     8013ea <dup+0xd1>
		goto err;

	return newfdnum;
  8013b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013bc:	89 d8                	mov    %ebx,%eax
  8013be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5e                   	pop    %esi
  8013c3:	5f                   	pop    %edi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013cd:	83 ec 0c             	sub    $0xc,%esp
  8013d0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d5:	50                   	push   %eax
  8013d6:	57                   	push   %edi
  8013d7:	6a 00                	push   $0x0
  8013d9:	53                   	push   %ebx
  8013da:	6a 00                	push   $0x0
  8013dc:	e8 9d f8 ff ff       	call   800c7e <sys_page_map>
  8013e1:	89 c3                	mov    %eax,%ebx
  8013e3:	83 c4 20             	add    $0x20,%esp
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	79 a3                	jns    80138d <dup+0x74>
	sys_page_unmap(0, newfd);
  8013ea:	83 ec 08             	sub    $0x8,%esp
  8013ed:	56                   	push   %esi
  8013ee:	6a 00                	push   $0x0
  8013f0:	e8 cb f8 ff ff       	call   800cc0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f5:	83 c4 08             	add    $0x8,%esp
  8013f8:	57                   	push   %edi
  8013f9:	6a 00                	push   $0x0
  8013fb:	e8 c0 f8 ff ff       	call   800cc0 <sys_page_unmap>
	return r;
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	eb b7                	jmp    8013bc <dup+0xa3>

00801405 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	53                   	push   %ebx
  801409:	83 ec 14             	sub    $0x14,%esp
  80140c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801412:	50                   	push   %eax
  801413:	53                   	push   %ebx
  801414:	e8 7b fd ff ff       	call   801194 <fd_lookup>
  801419:	83 c4 08             	add    $0x8,%esp
  80141c:	85 c0                	test   %eax,%eax
  80141e:	78 3f                	js     80145f <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801426:	50                   	push   %eax
  801427:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142a:	ff 30                	pushl  (%eax)
  80142c:	e8 b9 fd ff ff       	call   8011ea <dev_lookup>
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	85 c0                	test   %eax,%eax
  801436:	78 27                	js     80145f <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801438:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80143b:	8b 42 08             	mov    0x8(%edx),%eax
  80143e:	83 e0 03             	and    $0x3,%eax
  801441:	83 f8 01             	cmp    $0x1,%eax
  801444:	74 1e                	je     801464 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801446:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801449:	8b 40 08             	mov    0x8(%eax),%eax
  80144c:	85 c0                	test   %eax,%eax
  80144e:	74 35                	je     801485 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801450:	83 ec 04             	sub    $0x4,%esp
  801453:	ff 75 10             	pushl  0x10(%ebp)
  801456:	ff 75 0c             	pushl  0xc(%ebp)
  801459:	52                   	push   %edx
  80145a:	ff d0                	call   *%eax
  80145c:	83 c4 10             	add    $0x10,%esp
}
  80145f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801462:	c9                   	leave  
  801463:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801464:	a1 08 40 80 00       	mov    0x804008,%eax
  801469:	8b 40 48             	mov    0x48(%eax),%eax
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	53                   	push   %ebx
  801470:	50                   	push   %eax
  801471:	68 61 26 80 00       	push   $0x802661
  801476:	e8 a8 ed ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801483:	eb da                	jmp    80145f <read+0x5a>
		return -E_NOT_SUPP;
  801485:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80148a:	eb d3                	jmp    80145f <read+0x5a>

0080148c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	57                   	push   %edi
  801490:	56                   	push   %esi
  801491:	53                   	push   %ebx
  801492:	83 ec 0c             	sub    $0xc,%esp
  801495:	8b 7d 08             	mov    0x8(%ebp),%edi
  801498:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80149b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a0:	39 f3                	cmp    %esi,%ebx
  8014a2:	73 25                	jae    8014c9 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014a4:	83 ec 04             	sub    $0x4,%esp
  8014a7:	89 f0                	mov    %esi,%eax
  8014a9:	29 d8                	sub    %ebx,%eax
  8014ab:	50                   	push   %eax
  8014ac:	89 d8                	mov    %ebx,%eax
  8014ae:	03 45 0c             	add    0xc(%ebp),%eax
  8014b1:	50                   	push   %eax
  8014b2:	57                   	push   %edi
  8014b3:	e8 4d ff ff ff       	call   801405 <read>
		if (m < 0)
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 08                	js     8014c7 <readn+0x3b>
			return m;
		if (m == 0)
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	74 06                	je     8014c9 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8014c3:	01 c3                	add    %eax,%ebx
  8014c5:	eb d9                	jmp    8014a0 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014c7:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014c9:	89 d8                	mov    %ebx,%eax
  8014cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ce:	5b                   	pop    %ebx
  8014cf:	5e                   	pop    %esi
  8014d0:	5f                   	pop    %edi
  8014d1:	5d                   	pop    %ebp
  8014d2:	c3                   	ret    

008014d3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	53                   	push   %ebx
  8014d7:	83 ec 14             	sub    $0x14,%esp
  8014da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	53                   	push   %ebx
  8014e2:	e8 ad fc ff ff       	call   801194 <fd_lookup>
  8014e7:	83 c4 08             	add    $0x8,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 3a                	js     801528 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f4:	50                   	push   %eax
  8014f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f8:	ff 30                	pushl  (%eax)
  8014fa:	e8 eb fc ff ff       	call   8011ea <dev_lookup>
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	85 c0                	test   %eax,%eax
  801504:	78 22                	js     801528 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801506:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801509:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80150d:	74 1e                	je     80152d <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80150f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801512:	8b 52 0c             	mov    0xc(%edx),%edx
  801515:	85 d2                	test   %edx,%edx
  801517:	74 35                	je     80154e <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801519:	83 ec 04             	sub    $0x4,%esp
  80151c:	ff 75 10             	pushl  0x10(%ebp)
  80151f:	ff 75 0c             	pushl  0xc(%ebp)
  801522:	50                   	push   %eax
  801523:	ff d2                	call   *%edx
  801525:	83 c4 10             	add    $0x10,%esp
}
  801528:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152b:	c9                   	leave  
  80152c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80152d:	a1 08 40 80 00       	mov    0x804008,%eax
  801532:	8b 40 48             	mov    0x48(%eax),%eax
  801535:	83 ec 04             	sub    $0x4,%esp
  801538:	53                   	push   %ebx
  801539:	50                   	push   %eax
  80153a:	68 7d 26 80 00       	push   $0x80267d
  80153f:	e8 df ec ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80154c:	eb da                	jmp    801528 <write+0x55>
		return -E_NOT_SUPP;
  80154e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801553:	eb d3                	jmp    801528 <write+0x55>

00801555 <seek>:

int
seek(int fdnum, off_t offset)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80155b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80155e:	50                   	push   %eax
  80155f:	ff 75 08             	pushl  0x8(%ebp)
  801562:	e8 2d fc ff ff       	call   801194 <fd_lookup>
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 0e                	js     80157c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80156e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801571:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801574:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801577:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157c:	c9                   	leave  
  80157d:	c3                   	ret    

0080157e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	53                   	push   %ebx
  801582:	83 ec 14             	sub    $0x14,%esp
  801585:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801588:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158b:	50                   	push   %eax
  80158c:	53                   	push   %ebx
  80158d:	e8 02 fc ff ff       	call   801194 <fd_lookup>
  801592:	83 c4 08             	add    $0x8,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	78 37                	js     8015d0 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a3:	ff 30                	pushl  (%eax)
  8015a5:	e8 40 fc ff ff       	call   8011ea <dev_lookup>
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 1f                	js     8015d0 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b8:	74 1b                	je     8015d5 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bd:	8b 52 18             	mov    0x18(%edx),%edx
  8015c0:	85 d2                	test   %edx,%edx
  8015c2:	74 32                	je     8015f6 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015c4:	83 ec 08             	sub    $0x8,%esp
  8015c7:	ff 75 0c             	pushl  0xc(%ebp)
  8015ca:	50                   	push   %eax
  8015cb:	ff d2                	call   *%edx
  8015cd:	83 c4 10             	add    $0x10,%esp
}
  8015d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d3:	c9                   	leave  
  8015d4:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015d5:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015da:	8b 40 48             	mov    0x48(%eax),%eax
  8015dd:	83 ec 04             	sub    $0x4,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	50                   	push   %eax
  8015e2:	68 40 26 80 00       	push   $0x802640
  8015e7:	e8 37 ec ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f4:	eb da                	jmp    8015d0 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8015f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015fb:	eb d3                	jmp    8015d0 <ftruncate+0x52>

008015fd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	53                   	push   %ebx
  801601:	83 ec 14             	sub    $0x14,%esp
  801604:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801607:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160a:	50                   	push   %eax
  80160b:	ff 75 08             	pushl  0x8(%ebp)
  80160e:	e8 81 fb ff ff       	call   801194 <fd_lookup>
  801613:	83 c4 08             	add    $0x8,%esp
  801616:	85 c0                	test   %eax,%eax
  801618:	78 4b                	js     801665 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801624:	ff 30                	pushl  (%eax)
  801626:	e8 bf fb ff ff       	call   8011ea <dev_lookup>
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 33                	js     801665 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801632:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801635:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801639:	74 2f                	je     80166a <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80163b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80163e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801645:	00 00 00 
	stat->st_isdir = 0;
  801648:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80164f:	00 00 00 
	stat->st_dev = dev;
  801652:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801658:	83 ec 08             	sub    $0x8,%esp
  80165b:	53                   	push   %ebx
  80165c:	ff 75 f0             	pushl  -0x10(%ebp)
  80165f:	ff 50 14             	call   *0x14(%eax)
  801662:	83 c4 10             	add    $0x10,%esp
}
  801665:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801668:	c9                   	leave  
  801669:	c3                   	ret    
		return -E_NOT_SUPP;
  80166a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80166f:	eb f4                	jmp    801665 <fstat+0x68>

00801671 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801676:	83 ec 08             	sub    $0x8,%esp
  801679:	6a 00                	push   $0x0
  80167b:	ff 75 08             	pushl  0x8(%ebp)
  80167e:	e8 da 01 00 00       	call   80185d <open>
  801683:	89 c3                	mov    %eax,%ebx
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	85 c0                	test   %eax,%eax
  80168a:	78 1b                	js     8016a7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80168c:	83 ec 08             	sub    $0x8,%esp
  80168f:	ff 75 0c             	pushl  0xc(%ebp)
  801692:	50                   	push   %eax
  801693:	e8 65 ff ff ff       	call   8015fd <fstat>
  801698:	89 c6                	mov    %eax,%esi
	close(fd);
  80169a:	89 1c 24             	mov    %ebx,(%esp)
  80169d:	e8 27 fc ff ff       	call   8012c9 <close>
	return r;
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	89 f3                	mov    %esi,%ebx
}
  8016a7:	89 d8                	mov    %ebx,%eax
  8016a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ac:	5b                   	pop    %ebx
  8016ad:	5e                   	pop    %esi
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
  8016b5:	89 c6                	mov    %eax,%esi
  8016b7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016c0:	74 27                	je     8016e9 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016c2:	6a 07                	push   $0x7
  8016c4:	68 00 50 80 00       	push   $0x805000
  8016c9:	56                   	push   %esi
  8016ca:	ff 35 00 40 80 00    	pushl  0x804000
  8016d0:	e8 f3 07 00 00       	call   801ec8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016d5:	83 c4 0c             	add    $0xc,%esp
  8016d8:	6a 00                	push   $0x0
  8016da:	53                   	push   %ebx
  8016db:	6a 00                	push   $0x0
  8016dd:	e8 7f 07 00 00       	call   801e61 <ipc_recv>
}
  8016e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e5:	5b                   	pop    %ebx
  8016e6:	5e                   	pop    %esi
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016e9:	83 ec 0c             	sub    $0xc,%esp
  8016ec:	6a 01                	push   $0x1
  8016ee:	e8 29 08 00 00       	call   801f1c <ipc_find_env>
  8016f3:	a3 00 40 80 00       	mov    %eax,0x804000
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	eb c5                	jmp    8016c2 <fsipc+0x12>

008016fd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801703:	8b 45 08             	mov    0x8(%ebp),%eax
  801706:	8b 40 0c             	mov    0xc(%eax),%eax
  801709:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80170e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801711:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801716:	ba 00 00 00 00       	mov    $0x0,%edx
  80171b:	b8 02 00 00 00       	mov    $0x2,%eax
  801720:	e8 8b ff ff ff       	call   8016b0 <fsipc>
}
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <devfile_flush>:
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80172d:	8b 45 08             	mov    0x8(%ebp),%eax
  801730:	8b 40 0c             	mov    0xc(%eax),%eax
  801733:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801738:	ba 00 00 00 00       	mov    $0x0,%edx
  80173d:	b8 06 00 00 00       	mov    $0x6,%eax
  801742:	e8 69 ff ff ff       	call   8016b0 <fsipc>
}
  801747:	c9                   	leave  
  801748:	c3                   	ret    

00801749 <devfile_stat>:
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	53                   	push   %ebx
  80174d:	83 ec 04             	sub    $0x4,%esp
  801750:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801753:	8b 45 08             	mov    0x8(%ebp),%eax
  801756:	8b 40 0c             	mov    0xc(%eax),%eax
  801759:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80175e:	ba 00 00 00 00       	mov    $0x0,%edx
  801763:	b8 05 00 00 00       	mov    $0x5,%eax
  801768:	e8 43 ff ff ff       	call   8016b0 <fsipc>
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 2c                	js     80179d <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	68 00 50 80 00       	push   $0x805000
  801779:	53                   	push   %ebx
  80177a:	e8 c3 f0 ff ff       	call   800842 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80177f:	a1 80 50 80 00       	mov    0x805080,%eax
  801784:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80178a:	a1 84 50 80 00       	mov    0x805084,%eax
  80178f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80179d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a0:	c9                   	leave  
  8017a1:	c3                   	ret    

008017a2 <devfile_write>:
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ae:	8b 52 0c             	mov    0xc(%edx),%edx
  8017b1:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8017b7:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8017bc:	50                   	push   %eax
  8017bd:	ff 75 0c             	pushl  0xc(%ebp)
  8017c0:	68 08 50 80 00       	push   $0x805008
  8017c5:	e8 06 f2 ff ff       	call   8009d0 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  8017ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cf:	b8 04 00 00 00       	mov    $0x4,%eax
  8017d4:	e8 d7 fe ff ff       	call   8016b0 <fsipc>
}
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <devfile_read>:
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017ee:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8017fe:	e8 ad fe ff ff       	call   8016b0 <fsipc>
  801803:	89 c3                	mov    %eax,%ebx
  801805:	85 c0                	test   %eax,%eax
  801807:	78 1f                	js     801828 <devfile_read+0x4d>
	assert(r <= n);
  801809:	39 f0                	cmp    %esi,%eax
  80180b:	77 24                	ja     801831 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80180d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801812:	7f 33                	jg     801847 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801814:	83 ec 04             	sub    $0x4,%esp
  801817:	50                   	push   %eax
  801818:	68 00 50 80 00       	push   $0x805000
  80181d:	ff 75 0c             	pushl  0xc(%ebp)
  801820:	e8 ab f1 ff ff       	call   8009d0 <memmove>
	return r;
  801825:	83 c4 10             	add    $0x10,%esp
}
  801828:	89 d8                	mov    %ebx,%eax
  80182a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182d:	5b                   	pop    %ebx
  80182e:	5e                   	pop    %esi
  80182f:	5d                   	pop    %ebp
  801830:	c3                   	ret    
	assert(r <= n);
  801831:	68 ac 26 80 00       	push   $0x8026ac
  801836:	68 b3 26 80 00       	push   $0x8026b3
  80183b:	6a 7c                	push   $0x7c
  80183d:	68 c8 26 80 00       	push   $0x8026c8
  801842:	e8 01 e9 ff ff       	call   800148 <_panic>
	assert(r <= PGSIZE);
  801847:	68 d3 26 80 00       	push   $0x8026d3
  80184c:	68 b3 26 80 00       	push   $0x8026b3
  801851:	6a 7d                	push   $0x7d
  801853:	68 c8 26 80 00       	push   $0x8026c8
  801858:	e8 eb e8 ff ff       	call   800148 <_panic>

0080185d <open>:
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	56                   	push   %esi
  801861:	53                   	push   %ebx
  801862:	83 ec 1c             	sub    $0x1c,%esp
  801865:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801868:	56                   	push   %esi
  801869:	e8 9d ef ff ff       	call   80080b <strlen>
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801876:	7f 6c                	jg     8018e4 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801878:	83 ec 0c             	sub    $0xc,%esp
  80187b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187e:	50                   	push   %eax
  80187f:	e8 c1 f8 ff ff       	call   801145 <fd_alloc>
  801884:	89 c3                	mov    %eax,%ebx
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 3c                	js     8018c9 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80188d:	83 ec 08             	sub    $0x8,%esp
  801890:	56                   	push   %esi
  801891:	68 00 50 80 00       	push   $0x805000
  801896:	e8 a7 ef ff ff       	call   800842 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80189b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ab:	e8 00 fe ff ff       	call   8016b0 <fsipc>
  8018b0:	89 c3                	mov    %eax,%ebx
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	78 19                	js     8018d2 <open+0x75>
	return fd2num(fd);
  8018b9:	83 ec 0c             	sub    $0xc,%esp
  8018bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8018bf:	e8 5a f8 ff ff       	call   80111e <fd2num>
  8018c4:	89 c3                	mov    %eax,%ebx
  8018c6:	83 c4 10             	add    $0x10,%esp
}
  8018c9:	89 d8                	mov    %ebx,%eax
  8018cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ce:	5b                   	pop    %ebx
  8018cf:	5e                   	pop    %esi
  8018d0:	5d                   	pop    %ebp
  8018d1:	c3                   	ret    
		fd_close(fd, 0);
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	6a 00                	push   $0x0
  8018d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018da:	e8 61 f9 ff ff       	call   801240 <fd_close>
		return r;
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	eb e5                	jmp    8018c9 <open+0x6c>
		return -E_BAD_PATH;
  8018e4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018e9:	eb de                	jmp    8018c9 <open+0x6c>

008018eb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8018fb:	e8 b0 fd ff ff       	call   8016b0 <fsipc>
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	56                   	push   %esi
  801906:	53                   	push   %ebx
  801907:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80190a:	83 ec 0c             	sub    $0xc,%esp
  80190d:	ff 75 08             	pushl  0x8(%ebp)
  801910:	e8 19 f8 ff ff       	call   80112e <fd2data>
  801915:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801917:	83 c4 08             	add    $0x8,%esp
  80191a:	68 df 26 80 00       	push   $0x8026df
  80191f:	53                   	push   %ebx
  801920:	e8 1d ef ff ff       	call   800842 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801925:	8b 46 04             	mov    0x4(%esi),%eax
  801928:	2b 06                	sub    (%esi),%eax
  80192a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801930:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801937:	00 00 00 
	stat->st_dev = &devpipe;
  80193a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801941:	30 80 00 
	return 0;
}
  801944:	b8 00 00 00 00       	mov    $0x0,%eax
  801949:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194c:	5b                   	pop    %ebx
  80194d:	5e                   	pop    %esi
  80194e:	5d                   	pop    %ebp
  80194f:	c3                   	ret    

00801950 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	53                   	push   %ebx
  801954:	83 ec 0c             	sub    $0xc,%esp
  801957:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80195a:	53                   	push   %ebx
  80195b:	6a 00                	push   $0x0
  80195d:	e8 5e f3 ff ff       	call   800cc0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801962:	89 1c 24             	mov    %ebx,(%esp)
  801965:	e8 c4 f7 ff ff       	call   80112e <fd2data>
  80196a:	83 c4 08             	add    $0x8,%esp
  80196d:	50                   	push   %eax
  80196e:	6a 00                	push   $0x0
  801970:	e8 4b f3 ff ff       	call   800cc0 <sys_page_unmap>
}
  801975:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <_pipeisclosed>:
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	57                   	push   %edi
  80197e:	56                   	push   %esi
  80197f:	53                   	push   %ebx
  801980:	83 ec 1c             	sub    $0x1c,%esp
  801983:	89 c7                	mov    %eax,%edi
  801985:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801987:	a1 08 40 80 00       	mov    0x804008,%eax
  80198c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80198f:	83 ec 0c             	sub    $0xc,%esp
  801992:	57                   	push   %edi
  801993:	e8 bd 05 00 00       	call   801f55 <pageref>
  801998:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80199b:	89 34 24             	mov    %esi,(%esp)
  80199e:	e8 b2 05 00 00       	call   801f55 <pageref>
		nn = thisenv->env_runs;
  8019a3:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019a9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	39 cb                	cmp    %ecx,%ebx
  8019b1:	74 1b                	je     8019ce <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8019b3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019b6:	75 cf                	jne    801987 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019b8:	8b 42 58             	mov    0x58(%edx),%eax
  8019bb:	6a 01                	push   $0x1
  8019bd:	50                   	push   %eax
  8019be:	53                   	push   %ebx
  8019bf:	68 e6 26 80 00       	push   $0x8026e6
  8019c4:	e8 5a e8 ff ff       	call   800223 <cprintf>
  8019c9:	83 c4 10             	add    $0x10,%esp
  8019cc:	eb b9                	jmp    801987 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8019ce:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019d1:	0f 94 c0             	sete   %al
  8019d4:	0f b6 c0             	movzbl %al,%eax
}
  8019d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5e                   	pop    %esi
  8019dc:	5f                   	pop    %edi
  8019dd:	5d                   	pop    %ebp
  8019de:	c3                   	ret    

008019df <devpipe_write>:
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	57                   	push   %edi
  8019e3:	56                   	push   %esi
  8019e4:	53                   	push   %ebx
  8019e5:	83 ec 28             	sub    $0x28,%esp
  8019e8:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019eb:	56                   	push   %esi
  8019ec:	e8 3d f7 ff ff       	call   80112e <fd2data>
  8019f1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	bf 00 00 00 00       	mov    $0x0,%edi
  8019fb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019fe:	74 4f                	je     801a4f <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a00:	8b 43 04             	mov    0x4(%ebx),%eax
  801a03:	8b 0b                	mov    (%ebx),%ecx
  801a05:	8d 51 20             	lea    0x20(%ecx),%edx
  801a08:	39 d0                	cmp    %edx,%eax
  801a0a:	72 14                	jb     801a20 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801a0c:	89 da                	mov    %ebx,%edx
  801a0e:	89 f0                	mov    %esi,%eax
  801a10:	e8 65 ff ff ff       	call   80197a <_pipeisclosed>
  801a15:	85 c0                	test   %eax,%eax
  801a17:	75 3a                	jne    801a53 <devpipe_write+0x74>
			sys_yield();
  801a19:	e8 fe f1 ff ff       	call   800c1c <sys_yield>
  801a1e:	eb e0                	jmp    801a00 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a23:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a27:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a2a:	89 c2                	mov    %eax,%edx
  801a2c:	c1 fa 1f             	sar    $0x1f,%edx
  801a2f:	89 d1                	mov    %edx,%ecx
  801a31:	c1 e9 1b             	shr    $0x1b,%ecx
  801a34:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a37:	83 e2 1f             	and    $0x1f,%edx
  801a3a:	29 ca                	sub    %ecx,%edx
  801a3c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a40:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a44:	83 c0 01             	add    $0x1,%eax
  801a47:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a4a:	83 c7 01             	add    $0x1,%edi
  801a4d:	eb ac                	jmp    8019fb <devpipe_write+0x1c>
	return i;
  801a4f:	89 f8                	mov    %edi,%eax
  801a51:	eb 05                	jmp    801a58 <devpipe_write+0x79>
				return 0;
  801a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5b:	5b                   	pop    %ebx
  801a5c:	5e                   	pop    %esi
  801a5d:	5f                   	pop    %edi
  801a5e:	5d                   	pop    %ebp
  801a5f:	c3                   	ret    

00801a60 <devpipe_read>:
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	57                   	push   %edi
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	83 ec 18             	sub    $0x18,%esp
  801a69:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a6c:	57                   	push   %edi
  801a6d:	e8 bc f6 ff ff       	call   80112e <fd2data>
  801a72:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	be 00 00 00 00       	mov    $0x0,%esi
  801a7c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a7f:	74 47                	je     801ac8 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801a81:	8b 03                	mov    (%ebx),%eax
  801a83:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a86:	75 22                	jne    801aaa <devpipe_read+0x4a>
			if (i > 0)
  801a88:	85 f6                	test   %esi,%esi
  801a8a:	75 14                	jne    801aa0 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801a8c:	89 da                	mov    %ebx,%edx
  801a8e:	89 f8                	mov    %edi,%eax
  801a90:	e8 e5 fe ff ff       	call   80197a <_pipeisclosed>
  801a95:	85 c0                	test   %eax,%eax
  801a97:	75 33                	jne    801acc <devpipe_read+0x6c>
			sys_yield();
  801a99:	e8 7e f1 ff ff       	call   800c1c <sys_yield>
  801a9e:	eb e1                	jmp    801a81 <devpipe_read+0x21>
				return i;
  801aa0:	89 f0                	mov    %esi,%eax
}
  801aa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5f                   	pop    %edi
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aaa:	99                   	cltd   
  801aab:	c1 ea 1b             	shr    $0x1b,%edx
  801aae:	01 d0                	add    %edx,%eax
  801ab0:	83 e0 1f             	and    $0x1f,%eax
  801ab3:	29 d0                	sub    %edx,%eax
  801ab5:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801aba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801abd:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ac0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ac3:	83 c6 01             	add    $0x1,%esi
  801ac6:	eb b4                	jmp    801a7c <devpipe_read+0x1c>
	return i;
  801ac8:	89 f0                	mov    %esi,%eax
  801aca:	eb d6                	jmp    801aa2 <devpipe_read+0x42>
				return 0;
  801acc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad1:	eb cf                	jmp    801aa2 <devpipe_read+0x42>

00801ad3 <pipe>:
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	56                   	push   %esi
  801ad7:	53                   	push   %ebx
  801ad8:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801adb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ade:	50                   	push   %eax
  801adf:	e8 61 f6 ff ff       	call   801145 <fd_alloc>
  801ae4:	89 c3                	mov    %eax,%ebx
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 5b                	js     801b48 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aed:	83 ec 04             	sub    $0x4,%esp
  801af0:	68 07 04 00 00       	push   $0x407
  801af5:	ff 75 f4             	pushl  -0xc(%ebp)
  801af8:	6a 00                	push   $0x0
  801afa:	e8 3c f1 ff ff       	call   800c3b <sys_page_alloc>
  801aff:	89 c3                	mov    %eax,%ebx
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 40                	js     801b48 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801b08:	83 ec 0c             	sub    $0xc,%esp
  801b0b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b0e:	50                   	push   %eax
  801b0f:	e8 31 f6 ff ff       	call   801145 <fd_alloc>
  801b14:	89 c3                	mov    %eax,%ebx
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	78 1b                	js     801b38 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b1d:	83 ec 04             	sub    $0x4,%esp
  801b20:	68 07 04 00 00       	push   $0x407
  801b25:	ff 75 f0             	pushl  -0x10(%ebp)
  801b28:	6a 00                	push   $0x0
  801b2a:	e8 0c f1 ff ff       	call   800c3b <sys_page_alloc>
  801b2f:	89 c3                	mov    %eax,%ebx
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	85 c0                	test   %eax,%eax
  801b36:	79 19                	jns    801b51 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801b38:	83 ec 08             	sub    $0x8,%esp
  801b3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 7b f1 ff ff       	call   800cc0 <sys_page_unmap>
  801b45:	83 c4 10             	add    $0x10,%esp
}
  801b48:	89 d8                	mov    %ebx,%eax
  801b4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4d:	5b                   	pop    %ebx
  801b4e:	5e                   	pop    %esi
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    
	va = fd2data(fd0);
  801b51:	83 ec 0c             	sub    $0xc,%esp
  801b54:	ff 75 f4             	pushl  -0xc(%ebp)
  801b57:	e8 d2 f5 ff ff       	call   80112e <fd2data>
  801b5c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5e:	83 c4 0c             	add    $0xc,%esp
  801b61:	68 07 04 00 00       	push   $0x407
  801b66:	50                   	push   %eax
  801b67:	6a 00                	push   $0x0
  801b69:	e8 cd f0 ff ff       	call   800c3b <sys_page_alloc>
  801b6e:	89 c3                	mov    %eax,%ebx
  801b70:	83 c4 10             	add    $0x10,%esp
  801b73:	85 c0                	test   %eax,%eax
  801b75:	0f 88 8c 00 00 00    	js     801c07 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7b:	83 ec 0c             	sub    $0xc,%esp
  801b7e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b81:	e8 a8 f5 ff ff       	call   80112e <fd2data>
  801b86:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b8d:	50                   	push   %eax
  801b8e:	6a 00                	push   $0x0
  801b90:	56                   	push   %esi
  801b91:	6a 00                	push   $0x0
  801b93:	e8 e6 f0 ff ff       	call   800c7e <sys_page_map>
  801b98:	89 c3                	mov    %eax,%ebx
  801b9a:	83 c4 20             	add    $0x20,%esp
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	78 58                	js     801bf9 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801baa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801baf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bb9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bbf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801bcb:	83 ec 0c             	sub    $0xc,%esp
  801bce:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd1:	e8 48 f5 ff ff       	call   80111e <fd2num>
  801bd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bdb:	83 c4 04             	add    $0x4,%esp
  801bde:	ff 75 f0             	pushl  -0x10(%ebp)
  801be1:	e8 38 f5 ff ff       	call   80111e <fd2num>
  801be6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf4:	e9 4f ff ff ff       	jmp    801b48 <pipe+0x75>
	sys_page_unmap(0, va);
  801bf9:	83 ec 08             	sub    $0x8,%esp
  801bfc:	56                   	push   %esi
  801bfd:	6a 00                	push   $0x0
  801bff:	e8 bc f0 ff ff       	call   800cc0 <sys_page_unmap>
  801c04:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c07:	83 ec 08             	sub    $0x8,%esp
  801c0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0d:	6a 00                	push   $0x0
  801c0f:	e8 ac f0 ff ff       	call   800cc0 <sys_page_unmap>
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	e9 1c ff ff ff       	jmp    801b38 <pipe+0x65>

00801c1c <pipeisclosed>:
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c25:	50                   	push   %eax
  801c26:	ff 75 08             	pushl  0x8(%ebp)
  801c29:	e8 66 f5 ff ff       	call   801194 <fd_lookup>
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	85 c0                	test   %eax,%eax
  801c33:	78 18                	js     801c4d <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801c35:	83 ec 0c             	sub    $0xc,%esp
  801c38:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3b:	e8 ee f4 ff ff       	call   80112e <fd2data>
	return _pipeisclosed(fd, p);
  801c40:	89 c2                	mov    %eax,%edx
  801c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c45:	e8 30 fd ff ff       	call   80197a <_pipeisclosed>
  801c4a:	83 c4 10             	add    $0x10,%esp
}
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c52:	b8 00 00 00 00       	mov    $0x0,%eax
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c5f:	68 fe 26 80 00       	push   $0x8026fe
  801c64:	ff 75 0c             	pushl  0xc(%ebp)
  801c67:	e8 d6 eb ff ff       	call   800842 <strcpy>
	return 0;
}
  801c6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    

00801c73 <devcons_write>:
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	57                   	push   %edi
  801c77:	56                   	push   %esi
  801c78:	53                   	push   %ebx
  801c79:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c7f:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c84:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801c8a:	eb 2f                	jmp    801cbb <devcons_write+0x48>
		m = n - tot;
  801c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c8f:	29 f3                	sub    %esi,%ebx
  801c91:	83 fb 7f             	cmp    $0x7f,%ebx
  801c94:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801c99:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c9c:	83 ec 04             	sub    $0x4,%esp
  801c9f:	53                   	push   %ebx
  801ca0:	89 f0                	mov    %esi,%eax
  801ca2:	03 45 0c             	add    0xc(%ebp),%eax
  801ca5:	50                   	push   %eax
  801ca6:	57                   	push   %edi
  801ca7:	e8 24 ed ff ff       	call   8009d0 <memmove>
		sys_cputs(buf, m);
  801cac:	83 c4 08             	add    $0x8,%esp
  801caf:	53                   	push   %ebx
  801cb0:	57                   	push   %edi
  801cb1:	e8 c9 ee ff ff       	call   800b7f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801cb6:	01 de                	add    %ebx,%esi
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cbe:	72 cc                	jb     801c8c <devcons_write+0x19>
}
  801cc0:	89 f0                	mov    %esi,%eax
  801cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc5:	5b                   	pop    %ebx
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    

00801cca <devcons_read>:
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 08             	sub    $0x8,%esp
  801cd0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801cd5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cd9:	75 07                	jne    801ce2 <devcons_read+0x18>
}
  801cdb:	c9                   	leave  
  801cdc:	c3                   	ret    
		sys_yield();
  801cdd:	e8 3a ef ff ff       	call   800c1c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801ce2:	e8 b6 ee ff ff       	call   800b9d <sys_cgetc>
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	74 f2                	je     801cdd <devcons_read+0x13>
	if (c < 0)
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	78 ec                	js     801cdb <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801cef:	83 f8 04             	cmp    $0x4,%eax
  801cf2:	74 0c                	je     801d00 <devcons_read+0x36>
	*(char*)vbuf = c;
  801cf4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf7:	88 02                	mov    %al,(%edx)
	return 1;
  801cf9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfe:	eb db                	jmp    801cdb <devcons_read+0x11>
		return 0;
  801d00:	b8 00 00 00 00       	mov    $0x0,%eax
  801d05:	eb d4                	jmp    801cdb <devcons_read+0x11>

00801d07 <cputchar>:
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d10:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d13:	6a 01                	push   $0x1
  801d15:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d18:	50                   	push   %eax
  801d19:	e8 61 ee ff ff       	call   800b7f <sys_cputs>
}
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    

00801d23 <getchar>:
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801d29:	6a 01                	push   $0x1
  801d2b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d2e:	50                   	push   %eax
  801d2f:	6a 00                	push   $0x0
  801d31:	e8 cf f6 ff ff       	call   801405 <read>
	if (r < 0)
  801d36:	83 c4 10             	add    $0x10,%esp
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	78 08                	js     801d45 <getchar+0x22>
	if (r < 1)
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	7e 06                	jle    801d47 <getchar+0x24>
	return c;
  801d41:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    
		return -E_EOF;
  801d47:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d4c:	eb f7                	jmp    801d45 <getchar+0x22>

00801d4e <iscons>:
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d57:	50                   	push   %eax
  801d58:	ff 75 08             	pushl  0x8(%ebp)
  801d5b:	e8 34 f4 ff ff       	call   801194 <fd_lookup>
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	85 c0                	test   %eax,%eax
  801d65:	78 11                	js     801d78 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d70:	39 10                	cmp    %edx,(%eax)
  801d72:	0f 94 c0             	sete   %al
  801d75:	0f b6 c0             	movzbl %al,%eax
}
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <opencons>:
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d83:	50                   	push   %eax
  801d84:	e8 bc f3 ff ff       	call   801145 <fd_alloc>
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	78 3a                	js     801dca <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d90:	83 ec 04             	sub    $0x4,%esp
  801d93:	68 07 04 00 00       	push   $0x407
  801d98:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 99 ee ff ff       	call   800c3b <sys_page_alloc>
  801da2:	83 c4 10             	add    $0x10,%esp
  801da5:	85 c0                	test   %eax,%eax
  801da7:	78 21                	js     801dca <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801db2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dbe:	83 ec 0c             	sub    $0xc,%esp
  801dc1:	50                   	push   %eax
  801dc2:	e8 57 f3 ff ff       	call   80111e <fd2num>
  801dc7:	83 c4 10             	add    $0x10,%esp
}
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dd2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dd9:	74 20                	je     801dfb <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dde:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801de3:	83 ec 08             	sub    $0x8,%esp
  801de6:	68 3b 1e 80 00       	push   $0x801e3b
  801deb:	6a 00                	push   $0x0
  801ded:	e8 94 ef ff ff       	call   800d86 <sys_env_set_pgfault_upcall>
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	85 c0                	test   %eax,%eax
  801df7:	78 2e                	js     801e27 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801dfb:	83 ec 04             	sub    $0x4,%esp
  801dfe:	6a 07                	push   $0x7
  801e00:	68 00 f0 bf ee       	push   $0xeebff000
  801e05:	6a 00                	push   $0x0
  801e07:	e8 2f ee ff ff       	call   800c3b <sys_page_alloc>
  801e0c:	83 c4 10             	add    $0x10,%esp
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	79 c8                	jns    801ddb <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801e13:	83 ec 04             	sub    $0x4,%esp
  801e16:	68 0c 27 80 00       	push   $0x80270c
  801e1b:	6a 21                	push   $0x21
  801e1d:	68 70 27 80 00       	push   $0x802770
  801e22:	e8 21 e3 ff ff       	call   800148 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801e27:	83 ec 04             	sub    $0x4,%esp
  801e2a:	68 38 27 80 00       	push   $0x802738
  801e2f:	6a 27                	push   $0x27
  801e31:	68 70 27 80 00       	push   $0x802770
  801e36:	e8 0d e3 ff ff       	call   800148 <_panic>

00801e3b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e3b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e3c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e41:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e43:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801e46:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801e4a:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801e4d:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  801e51:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801e55:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801e57:	83 c4 08             	add    $0x8,%esp
	popal
  801e5a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801e5b:	83 c4 04             	add    $0x4,%esp
	popfl
  801e5e:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e5f:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e60:	c3                   	ret    

00801e61 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	56                   	push   %esi
  801e65:	53                   	push   %ebx
  801e66:	8b 75 08             	mov    0x8(%ebp),%esi
  801e69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801e6f:	85 f6                	test   %esi,%esi
  801e71:	74 06                	je     801e79 <ipc_recv+0x18>
  801e73:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801e79:	85 db                	test   %ebx,%ebx
  801e7b:	74 06                	je     801e83 <ipc_recv+0x22>
  801e7d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801e83:	85 c0                	test   %eax,%eax
  801e85:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801e8a:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801e8d:	83 ec 0c             	sub    $0xc,%esp
  801e90:	50                   	push   %eax
  801e91:	e8 55 ef ff ff       	call   800deb <sys_ipc_recv>
	if (ret) return ret;
  801e96:	83 c4 10             	add    $0x10,%esp
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	75 24                	jne    801ec1 <ipc_recv+0x60>
	if (from_env_store)
  801e9d:	85 f6                	test   %esi,%esi
  801e9f:	74 0a                	je     801eab <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801ea1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ea6:	8b 40 74             	mov    0x74(%eax),%eax
  801ea9:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801eab:	85 db                	test   %ebx,%ebx
  801ead:	74 0a                	je     801eb9 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801eaf:	a1 08 40 80 00       	mov    0x804008,%eax
  801eb4:	8b 40 78             	mov    0x78(%eax),%eax
  801eb7:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801eb9:	a1 08 40 80 00       	mov    0x804008,%eax
  801ebe:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ec1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    

00801ec8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	57                   	push   %edi
  801ecc:	56                   	push   %esi
  801ecd:	53                   	push   %ebx
  801ece:	83 ec 0c             	sub    $0xc,%esp
  801ed1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ed4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801eda:	85 db                	test   %ebx,%ebx
  801edc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ee1:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ee4:	ff 75 14             	pushl  0x14(%ebp)
  801ee7:	53                   	push   %ebx
  801ee8:	56                   	push   %esi
  801ee9:	57                   	push   %edi
  801eea:	e8 d9 ee ff ff       	call   800dc8 <sys_ipc_try_send>
  801eef:	83 c4 10             	add    $0x10,%esp
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	74 1e                	je     801f14 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ef6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef9:	75 07                	jne    801f02 <ipc_send+0x3a>
		sys_yield();
  801efb:	e8 1c ed ff ff       	call   800c1c <sys_yield>
  801f00:	eb e2                	jmp    801ee4 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801f02:	50                   	push   %eax
  801f03:	68 7e 27 80 00       	push   $0x80277e
  801f08:	6a 36                	push   $0x36
  801f0a:	68 95 27 80 00       	push   $0x802795
  801f0f:	e8 34 e2 ff ff       	call   800148 <_panic>
	}
}
  801f14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f17:	5b                   	pop    %ebx
  801f18:	5e                   	pop    %esi
  801f19:	5f                   	pop    %edi
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    

00801f1c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f22:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f27:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f2a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f30:	8b 52 50             	mov    0x50(%edx),%edx
  801f33:	39 ca                	cmp    %ecx,%edx
  801f35:	74 11                	je     801f48 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f37:	83 c0 01             	add    $0x1,%eax
  801f3a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f3f:	75 e6                	jne    801f27 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f41:	b8 00 00 00 00       	mov    $0x0,%eax
  801f46:	eb 0b                	jmp    801f53 <ipc_find_env+0x37>
			return envs[i].env_id;
  801f48:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f4b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f50:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    

00801f55 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5b:	89 d0                	mov    %edx,%eax
  801f5d:	c1 e8 16             	shr    $0x16,%eax
  801f60:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f67:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f6c:	f6 c1 01             	test   $0x1,%cl
  801f6f:	74 1d                	je     801f8e <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f71:	c1 ea 0c             	shr    $0xc,%edx
  801f74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f7b:	f6 c2 01             	test   $0x1,%dl
  801f7e:	74 0e                	je     801f8e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f80:	c1 ea 0c             	shr    $0xc,%edx
  801f83:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f8a:	ef 
  801f8b:	0f b7 c0             	movzwl %ax,%eax
}
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801f9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fa3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801fa7:	85 d2                	test   %edx,%edx
  801fa9:	75 35                	jne    801fe0 <__udivdi3+0x50>
  801fab:	39 f3                	cmp    %esi,%ebx
  801fad:	0f 87 bd 00 00 00    	ja     802070 <__udivdi3+0xe0>
  801fb3:	85 db                	test   %ebx,%ebx
  801fb5:	89 d9                	mov    %ebx,%ecx
  801fb7:	75 0b                	jne    801fc4 <__udivdi3+0x34>
  801fb9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fbe:	31 d2                	xor    %edx,%edx
  801fc0:	f7 f3                	div    %ebx
  801fc2:	89 c1                	mov    %eax,%ecx
  801fc4:	31 d2                	xor    %edx,%edx
  801fc6:	89 f0                	mov    %esi,%eax
  801fc8:	f7 f1                	div    %ecx
  801fca:	89 c6                	mov    %eax,%esi
  801fcc:	89 e8                	mov    %ebp,%eax
  801fce:	89 f7                	mov    %esi,%edi
  801fd0:	f7 f1                	div    %ecx
  801fd2:	89 fa                	mov    %edi,%edx
  801fd4:	83 c4 1c             	add    $0x1c,%esp
  801fd7:	5b                   	pop    %ebx
  801fd8:	5e                   	pop    %esi
  801fd9:	5f                   	pop    %edi
  801fda:	5d                   	pop    %ebp
  801fdb:	c3                   	ret    
  801fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	39 f2                	cmp    %esi,%edx
  801fe2:	77 7c                	ja     802060 <__udivdi3+0xd0>
  801fe4:	0f bd fa             	bsr    %edx,%edi
  801fe7:	83 f7 1f             	xor    $0x1f,%edi
  801fea:	0f 84 98 00 00 00    	je     802088 <__udivdi3+0xf8>
  801ff0:	89 f9                	mov    %edi,%ecx
  801ff2:	b8 20 00 00 00       	mov    $0x20,%eax
  801ff7:	29 f8                	sub    %edi,%eax
  801ff9:	d3 e2                	shl    %cl,%edx
  801ffb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fff:	89 c1                	mov    %eax,%ecx
  802001:	89 da                	mov    %ebx,%edx
  802003:	d3 ea                	shr    %cl,%edx
  802005:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802009:	09 d1                	or     %edx,%ecx
  80200b:	89 f2                	mov    %esi,%edx
  80200d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802011:	89 f9                	mov    %edi,%ecx
  802013:	d3 e3                	shl    %cl,%ebx
  802015:	89 c1                	mov    %eax,%ecx
  802017:	d3 ea                	shr    %cl,%edx
  802019:	89 f9                	mov    %edi,%ecx
  80201b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80201f:	d3 e6                	shl    %cl,%esi
  802021:	89 eb                	mov    %ebp,%ebx
  802023:	89 c1                	mov    %eax,%ecx
  802025:	d3 eb                	shr    %cl,%ebx
  802027:	09 de                	or     %ebx,%esi
  802029:	89 f0                	mov    %esi,%eax
  80202b:	f7 74 24 08          	divl   0x8(%esp)
  80202f:	89 d6                	mov    %edx,%esi
  802031:	89 c3                	mov    %eax,%ebx
  802033:	f7 64 24 0c          	mull   0xc(%esp)
  802037:	39 d6                	cmp    %edx,%esi
  802039:	72 0c                	jb     802047 <__udivdi3+0xb7>
  80203b:	89 f9                	mov    %edi,%ecx
  80203d:	d3 e5                	shl    %cl,%ebp
  80203f:	39 c5                	cmp    %eax,%ebp
  802041:	73 5d                	jae    8020a0 <__udivdi3+0x110>
  802043:	39 d6                	cmp    %edx,%esi
  802045:	75 59                	jne    8020a0 <__udivdi3+0x110>
  802047:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80204a:	31 ff                	xor    %edi,%edi
  80204c:	89 fa                	mov    %edi,%edx
  80204e:	83 c4 1c             	add    $0x1c,%esp
  802051:	5b                   	pop    %ebx
  802052:	5e                   	pop    %esi
  802053:	5f                   	pop    %edi
  802054:	5d                   	pop    %ebp
  802055:	c3                   	ret    
  802056:	8d 76 00             	lea    0x0(%esi),%esi
  802059:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802060:	31 ff                	xor    %edi,%edi
  802062:	31 c0                	xor    %eax,%eax
  802064:	89 fa                	mov    %edi,%edx
  802066:	83 c4 1c             	add    $0x1c,%esp
  802069:	5b                   	pop    %ebx
  80206a:	5e                   	pop    %esi
  80206b:	5f                   	pop    %edi
  80206c:	5d                   	pop    %ebp
  80206d:	c3                   	ret    
  80206e:	66 90                	xchg   %ax,%ax
  802070:	31 ff                	xor    %edi,%edi
  802072:	89 e8                	mov    %ebp,%eax
  802074:	89 f2                	mov    %esi,%edx
  802076:	f7 f3                	div    %ebx
  802078:	89 fa                	mov    %edi,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	39 f2                	cmp    %esi,%edx
  80208a:	72 06                	jb     802092 <__udivdi3+0x102>
  80208c:	31 c0                	xor    %eax,%eax
  80208e:	39 eb                	cmp    %ebp,%ebx
  802090:	77 d2                	ja     802064 <__udivdi3+0xd4>
  802092:	b8 01 00 00 00       	mov    $0x1,%eax
  802097:	eb cb                	jmp    802064 <__udivdi3+0xd4>
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 d8                	mov    %ebx,%eax
  8020a2:	31 ff                	xor    %edi,%edi
  8020a4:	eb be                	jmp    802064 <__udivdi3+0xd4>
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__umoddi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8020bb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 ed                	test   %ebp,%ebp
  8020c9:	89 f0                	mov    %esi,%eax
  8020cb:	89 da                	mov    %ebx,%edx
  8020cd:	75 19                	jne    8020e8 <__umoddi3+0x38>
  8020cf:	39 df                	cmp    %ebx,%edi
  8020d1:	0f 86 b1 00 00 00    	jbe    802188 <__umoddi3+0xd8>
  8020d7:	f7 f7                	div    %edi
  8020d9:	89 d0                	mov    %edx,%eax
  8020db:	31 d2                	xor    %edx,%edx
  8020dd:	83 c4 1c             	add    $0x1c,%esp
  8020e0:	5b                   	pop    %ebx
  8020e1:	5e                   	pop    %esi
  8020e2:	5f                   	pop    %edi
  8020e3:	5d                   	pop    %ebp
  8020e4:	c3                   	ret    
  8020e5:	8d 76 00             	lea    0x0(%esi),%esi
  8020e8:	39 dd                	cmp    %ebx,%ebp
  8020ea:	77 f1                	ja     8020dd <__umoddi3+0x2d>
  8020ec:	0f bd cd             	bsr    %ebp,%ecx
  8020ef:	83 f1 1f             	xor    $0x1f,%ecx
  8020f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020f6:	0f 84 b4 00 00 00    	je     8021b0 <__umoddi3+0x100>
  8020fc:	b8 20 00 00 00       	mov    $0x20,%eax
  802101:	89 c2                	mov    %eax,%edx
  802103:	8b 44 24 04          	mov    0x4(%esp),%eax
  802107:	29 c2                	sub    %eax,%edx
  802109:	89 c1                	mov    %eax,%ecx
  80210b:	89 f8                	mov    %edi,%eax
  80210d:	d3 e5                	shl    %cl,%ebp
  80210f:	89 d1                	mov    %edx,%ecx
  802111:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802115:	d3 e8                	shr    %cl,%eax
  802117:	09 c5                	or     %eax,%ebp
  802119:	8b 44 24 04          	mov    0x4(%esp),%eax
  80211d:	89 c1                	mov    %eax,%ecx
  80211f:	d3 e7                	shl    %cl,%edi
  802121:	89 d1                	mov    %edx,%ecx
  802123:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802127:	89 df                	mov    %ebx,%edi
  802129:	d3 ef                	shr    %cl,%edi
  80212b:	89 c1                	mov    %eax,%ecx
  80212d:	89 f0                	mov    %esi,%eax
  80212f:	d3 e3                	shl    %cl,%ebx
  802131:	89 d1                	mov    %edx,%ecx
  802133:	89 fa                	mov    %edi,%edx
  802135:	d3 e8                	shr    %cl,%eax
  802137:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80213c:	09 d8                	or     %ebx,%eax
  80213e:	f7 f5                	div    %ebp
  802140:	d3 e6                	shl    %cl,%esi
  802142:	89 d1                	mov    %edx,%ecx
  802144:	f7 64 24 08          	mull   0x8(%esp)
  802148:	39 d1                	cmp    %edx,%ecx
  80214a:	89 c3                	mov    %eax,%ebx
  80214c:	89 d7                	mov    %edx,%edi
  80214e:	72 06                	jb     802156 <__umoddi3+0xa6>
  802150:	75 0e                	jne    802160 <__umoddi3+0xb0>
  802152:	39 c6                	cmp    %eax,%esi
  802154:	73 0a                	jae    802160 <__umoddi3+0xb0>
  802156:	2b 44 24 08          	sub    0x8(%esp),%eax
  80215a:	19 ea                	sbb    %ebp,%edx
  80215c:	89 d7                	mov    %edx,%edi
  80215e:	89 c3                	mov    %eax,%ebx
  802160:	89 ca                	mov    %ecx,%edx
  802162:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802167:	29 de                	sub    %ebx,%esi
  802169:	19 fa                	sbb    %edi,%edx
  80216b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80216f:	89 d0                	mov    %edx,%eax
  802171:	d3 e0                	shl    %cl,%eax
  802173:	89 d9                	mov    %ebx,%ecx
  802175:	d3 ee                	shr    %cl,%esi
  802177:	d3 ea                	shr    %cl,%edx
  802179:	09 f0                	or     %esi,%eax
  80217b:	83 c4 1c             	add    $0x1c,%esp
  80217e:	5b                   	pop    %ebx
  80217f:	5e                   	pop    %esi
  802180:	5f                   	pop    %edi
  802181:	5d                   	pop    %ebp
  802182:	c3                   	ret    
  802183:	90                   	nop
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	85 ff                	test   %edi,%edi
  80218a:	89 f9                	mov    %edi,%ecx
  80218c:	75 0b                	jne    802199 <__umoddi3+0xe9>
  80218e:	b8 01 00 00 00       	mov    $0x1,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f7                	div    %edi
  802197:	89 c1                	mov    %eax,%ecx
  802199:	89 d8                	mov    %ebx,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f1                	div    %ecx
  80219f:	89 f0                	mov    %esi,%eax
  8021a1:	f7 f1                	div    %ecx
  8021a3:	e9 31 ff ff ff       	jmp    8020d9 <__umoddi3+0x29>
  8021a8:	90                   	nop
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	39 dd                	cmp    %ebx,%ebp
  8021b2:	72 08                	jb     8021bc <__umoddi3+0x10c>
  8021b4:	39 f7                	cmp    %esi,%edi
  8021b6:	0f 87 21 ff ff ff    	ja     8020dd <__umoddi3+0x2d>
  8021bc:	89 da                	mov    %ebx,%edx
  8021be:	89 f0                	mov    %esi,%eax
  8021c0:	29 f8                	sub    %edi,%eax
  8021c2:	19 ea                	sbb    %ebp,%edx
  8021c4:	e9 14 ff ff ff       	jmp    8020dd <__umoddi3+0x2d>
