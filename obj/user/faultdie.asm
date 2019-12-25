
obj/user/faultdie.debug：     文件格式 elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 80 1e 80 00       	push   $0x801e80
  80004a:	e8 26 01 00 00       	call   800175 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 fb 0a 00 00       	call   800b4f <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 b2 0a 00 00       	call   800b0e <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 0d 0d 00 00       	call   800d7e <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80008b:	e8 bf 0a 00 00       	call   800b4f <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 18 0f 00 00       	call   800fe9 <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 33 0a 00 00       	call   800b0e <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	74 09                	je     800108 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000ff:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800103:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800106:	c9                   	leave  
  800107:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800108:	83 ec 08             	sub    $0x8,%esp
  80010b:	68 ff 00 00 00       	push   $0xff
  800110:	8d 43 08             	lea    0x8(%ebx),%eax
  800113:	50                   	push   %eax
  800114:	e8 b8 09 00 00       	call   800ad1 <sys_cputs>
		b->idx = 0;
  800119:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	eb db                	jmp    8000ff <putch+0x1f>

00800124 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800134:	00 00 00 
	b.cnt = 0;
  800137:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800141:	ff 75 0c             	pushl  0xc(%ebp)
  800144:	ff 75 08             	pushl  0x8(%ebp)
  800147:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014d:	50                   	push   %eax
  80014e:	68 e0 00 80 00       	push   $0x8000e0
  800153:	e8 1a 01 00 00       	call   800272 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800158:	83 c4 08             	add    $0x8,%esp
  80015b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800161:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800167:	50                   	push   %eax
  800168:	e8 64 09 00 00       	call   800ad1 <sys_cputs>

	return b.cnt;
}
  80016d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017e:	50                   	push   %eax
  80017f:	ff 75 08             	pushl  0x8(%ebp)
  800182:	e8 9d ff ff ff       	call   800124 <vcprintf>
	va_end(ap);

	return cnt;
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 1c             	sub    $0x1c,%esp
  800192:	89 c7                	mov    %eax,%edi
  800194:	89 d6                	mov    %edx,%esi
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ad:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b0:	39 d3                	cmp    %edx,%ebx
  8001b2:	72 05                	jb     8001b9 <printnum+0x30>
  8001b4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b7:	77 7a                	ja     800233 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b9:	83 ec 0c             	sub    $0xc,%esp
  8001bc:	ff 75 18             	pushl  0x18(%ebp)
  8001bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c5:	53                   	push   %ebx
  8001c6:	ff 75 10             	pushl  0x10(%ebp)
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d8:	e8 63 1a 00 00       	call   801c40 <__udivdi3>
  8001dd:	83 c4 18             	add    $0x18,%esp
  8001e0:	52                   	push   %edx
  8001e1:	50                   	push   %eax
  8001e2:	89 f2                	mov    %esi,%edx
  8001e4:	89 f8                	mov    %edi,%eax
  8001e6:	e8 9e ff ff ff       	call   800189 <printnum>
  8001eb:	83 c4 20             	add    $0x20,%esp
  8001ee:	eb 13                	jmp    800203 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	56                   	push   %esi
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	ff d7                	call   *%edi
  8001f9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001fc:	83 eb 01             	sub    $0x1,%ebx
  8001ff:	85 db                	test   %ebx,%ebx
  800201:	7f ed                	jg     8001f0 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020d:	ff 75 e0             	pushl  -0x20(%ebp)
  800210:	ff 75 dc             	pushl  -0x24(%ebp)
  800213:	ff 75 d8             	pushl  -0x28(%ebp)
  800216:	e8 45 1b 00 00       	call   801d60 <__umoddi3>
  80021b:	83 c4 14             	add    $0x14,%esp
  80021e:	0f be 80 a6 1e 80 00 	movsbl 0x801ea6(%eax),%eax
  800225:	50                   	push   %eax
  800226:	ff d7                	call   *%edi
}
  800228:	83 c4 10             	add    $0x10,%esp
  80022b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5e                   	pop    %esi
  800230:	5f                   	pop    %edi
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    
  800233:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800236:	eb c4                	jmp    8001fc <printnum+0x73>

00800238 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800242:	8b 10                	mov    (%eax),%edx
  800244:	3b 50 04             	cmp    0x4(%eax),%edx
  800247:	73 0a                	jae    800253 <sprintputch+0x1b>
		*b->buf++ = ch;
  800249:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024c:	89 08                	mov    %ecx,(%eax)
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	88 02                	mov    %al,(%edx)
}
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    

00800255 <printfmt>:
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80025b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025e:	50                   	push   %eax
  80025f:	ff 75 10             	pushl  0x10(%ebp)
  800262:	ff 75 0c             	pushl  0xc(%ebp)
  800265:	ff 75 08             	pushl  0x8(%ebp)
  800268:	e8 05 00 00 00       	call   800272 <vprintfmt>
}
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	c9                   	leave  
  800271:	c3                   	ret    

00800272 <vprintfmt>:
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	57                   	push   %edi
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	83 ec 2c             	sub    $0x2c,%esp
  80027b:	8b 75 08             	mov    0x8(%ebp),%esi
  80027e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800281:	8b 7d 10             	mov    0x10(%ebp),%edi
  800284:	e9 c1 03 00 00       	jmp    80064a <vprintfmt+0x3d8>
		padc = ' ';
  800289:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80028d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800294:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80029b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002a2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a7:	8d 47 01             	lea    0x1(%edi),%eax
  8002aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ad:	0f b6 17             	movzbl (%edi),%edx
  8002b0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002b3:	3c 55                	cmp    $0x55,%al
  8002b5:	0f 87 12 04 00 00    	ja     8006cd <vprintfmt+0x45b>
  8002bb:	0f b6 c0             	movzbl %al,%eax
  8002be:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  8002c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002cc:	eb d9                	jmp    8002a7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002d5:	eb d0                	jmp    8002a7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002d7:	0f b6 d2             	movzbl %dl,%edx
  8002da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002e5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002ec:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002ef:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f2:	83 f9 09             	cmp    $0x9,%ecx
  8002f5:	77 55                	ja     80034c <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002f7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002fa:	eb e9                	jmp    8002e5 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ff:	8b 00                	mov    (%eax),%eax
  800301:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800304:	8b 45 14             	mov    0x14(%ebp),%eax
  800307:	8d 40 04             	lea    0x4(%eax),%eax
  80030a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800310:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800314:	79 91                	jns    8002a7 <vprintfmt+0x35>
				width = precision, precision = -1;
  800316:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800319:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800323:	eb 82                	jmp    8002a7 <vprintfmt+0x35>
  800325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800328:	85 c0                	test   %eax,%eax
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
  80032f:	0f 49 d0             	cmovns %eax,%edx
  800332:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800338:	e9 6a ff ff ff       	jmp    8002a7 <vprintfmt+0x35>
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800340:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800347:	e9 5b ff ff ff       	jmp    8002a7 <vprintfmt+0x35>
  80034c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80034f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800352:	eb bc                	jmp    800310 <vprintfmt+0x9e>
			lflag++;
  800354:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80035a:	e9 48 ff ff ff       	jmp    8002a7 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80035f:	8b 45 14             	mov    0x14(%ebp),%eax
  800362:	8d 78 04             	lea    0x4(%eax),%edi
  800365:	83 ec 08             	sub    $0x8,%esp
  800368:	53                   	push   %ebx
  800369:	ff 30                	pushl  (%eax)
  80036b:	ff d6                	call   *%esi
			break;
  80036d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800370:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800373:	e9 cf 02 00 00       	jmp    800647 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 78 04             	lea    0x4(%eax),%edi
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	99                   	cltd   
  800381:	31 d0                	xor    %edx,%eax
  800383:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800385:	83 f8 0f             	cmp    $0xf,%eax
  800388:	7f 23                	jg     8003ad <vprintfmt+0x13b>
  80038a:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  800391:	85 d2                	test   %edx,%edx
  800393:	74 18                	je     8003ad <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800395:	52                   	push   %edx
  800396:	68 e1 22 80 00       	push   $0x8022e1
  80039b:	53                   	push   %ebx
  80039c:	56                   	push   %esi
  80039d:	e8 b3 fe ff ff       	call   800255 <printfmt>
  8003a2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a5:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a8:	e9 9a 02 00 00       	jmp    800647 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003ad:	50                   	push   %eax
  8003ae:	68 be 1e 80 00       	push   $0x801ebe
  8003b3:	53                   	push   %ebx
  8003b4:	56                   	push   %esi
  8003b5:	e8 9b fe ff ff       	call   800255 <printfmt>
  8003ba:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003bd:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003c0:	e9 82 02 00 00       	jmp    800647 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	83 c0 04             	add    $0x4,%eax
  8003cb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003d3:	85 ff                	test   %edi,%edi
  8003d5:	b8 b7 1e 80 00       	mov    $0x801eb7,%eax
  8003da:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e1:	0f 8e bd 00 00 00    	jle    8004a4 <vprintfmt+0x232>
  8003e7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003eb:	75 0e                	jne    8003fb <vprintfmt+0x189>
  8003ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8003f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003f9:	eb 6d                	jmp    800468 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003fb:	83 ec 08             	sub    $0x8,%esp
  8003fe:	ff 75 d0             	pushl  -0x30(%ebp)
  800401:	57                   	push   %edi
  800402:	e8 6e 03 00 00       	call   800775 <strnlen>
  800407:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80040a:	29 c1                	sub    %eax,%ecx
  80040c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80040f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800412:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800416:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800419:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80041c:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80041e:	eb 0f                	jmp    80042f <vprintfmt+0x1bd>
					putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	53                   	push   %ebx
  800424:	ff 75 e0             	pushl  -0x20(%ebp)
  800427:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800429:	83 ef 01             	sub    $0x1,%edi
  80042c:	83 c4 10             	add    $0x10,%esp
  80042f:	85 ff                	test   %edi,%edi
  800431:	7f ed                	jg     800420 <vprintfmt+0x1ae>
  800433:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800436:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800439:	85 c9                	test   %ecx,%ecx
  80043b:	b8 00 00 00 00       	mov    $0x0,%eax
  800440:	0f 49 c1             	cmovns %ecx,%eax
  800443:	29 c1                	sub    %eax,%ecx
  800445:	89 75 08             	mov    %esi,0x8(%ebp)
  800448:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80044b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80044e:	89 cb                	mov    %ecx,%ebx
  800450:	eb 16                	jmp    800468 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800452:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800456:	75 31                	jne    800489 <vprintfmt+0x217>
					putch(ch, putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	ff 75 0c             	pushl  0xc(%ebp)
  80045e:	50                   	push   %eax
  80045f:	ff 55 08             	call   *0x8(%ebp)
  800462:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800465:	83 eb 01             	sub    $0x1,%ebx
  800468:	83 c7 01             	add    $0x1,%edi
  80046b:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80046f:	0f be c2             	movsbl %dl,%eax
  800472:	85 c0                	test   %eax,%eax
  800474:	74 59                	je     8004cf <vprintfmt+0x25d>
  800476:	85 f6                	test   %esi,%esi
  800478:	78 d8                	js     800452 <vprintfmt+0x1e0>
  80047a:	83 ee 01             	sub    $0x1,%esi
  80047d:	79 d3                	jns    800452 <vprintfmt+0x1e0>
  80047f:	89 df                	mov    %ebx,%edi
  800481:	8b 75 08             	mov    0x8(%ebp),%esi
  800484:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800487:	eb 37                	jmp    8004c0 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800489:	0f be d2             	movsbl %dl,%edx
  80048c:	83 ea 20             	sub    $0x20,%edx
  80048f:	83 fa 5e             	cmp    $0x5e,%edx
  800492:	76 c4                	jbe    800458 <vprintfmt+0x1e6>
					putch('?', putdat);
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	ff 75 0c             	pushl  0xc(%ebp)
  80049a:	6a 3f                	push   $0x3f
  80049c:	ff 55 08             	call   *0x8(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	eb c1                	jmp    800465 <vprintfmt+0x1f3>
  8004a4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b0:	eb b6                	jmp    800468 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	6a 20                	push   $0x20
  8004b8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004ba:	83 ef 01             	sub    $0x1,%edi
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	85 ff                	test   %edi,%edi
  8004c2:	7f ee                	jg     8004b2 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ca:	e9 78 01 00 00       	jmp    800647 <vprintfmt+0x3d5>
  8004cf:	89 df                	mov    %ebx,%edi
  8004d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d7:	eb e7                	jmp    8004c0 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004d9:	83 f9 01             	cmp    $0x1,%ecx
  8004dc:	7e 3f                	jle    80051d <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004de:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e1:	8b 50 04             	mov    0x4(%eax),%edx
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 40 08             	lea    0x8(%eax),%eax
  8004f2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004f5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f9:	79 5c                	jns    800557 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	53                   	push   %ebx
  8004ff:	6a 2d                	push   $0x2d
  800501:	ff d6                	call   *%esi
				num = -(long long) num;
  800503:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800506:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800509:	f7 da                	neg    %edx
  80050b:	83 d1 00             	adc    $0x0,%ecx
  80050e:	f7 d9                	neg    %ecx
  800510:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800513:	b8 0a 00 00 00       	mov    $0xa,%eax
  800518:	e9 10 01 00 00       	jmp    80062d <vprintfmt+0x3bb>
	else if (lflag)
  80051d:	85 c9                	test   %ecx,%ecx
  80051f:	75 1b                	jne    80053c <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800529:	89 c1                	mov    %eax,%ecx
  80052b:	c1 f9 1f             	sar    $0x1f,%ecx
  80052e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 40 04             	lea    0x4(%eax),%eax
  800537:	89 45 14             	mov    %eax,0x14(%ebp)
  80053a:	eb b9                	jmp    8004f5 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800544:	89 c1                	mov    %eax,%ecx
  800546:	c1 f9 1f             	sar    $0x1f,%ecx
  800549:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 40 04             	lea    0x4(%eax),%eax
  800552:	89 45 14             	mov    %eax,0x14(%ebp)
  800555:	eb 9e                	jmp    8004f5 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800557:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80055d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800562:	e9 c6 00 00 00       	jmp    80062d <vprintfmt+0x3bb>
	if (lflag >= 2)
  800567:	83 f9 01             	cmp    $0x1,%ecx
  80056a:	7e 18                	jle    800584 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8b 10                	mov    (%eax),%edx
  800571:	8b 48 04             	mov    0x4(%eax),%ecx
  800574:	8d 40 08             	lea    0x8(%eax),%eax
  800577:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80057a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057f:	e9 a9 00 00 00       	jmp    80062d <vprintfmt+0x3bb>
	else if (lflag)
  800584:	85 c9                	test   %ecx,%ecx
  800586:	75 1a                	jne    8005a2 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8b 10                	mov    (%eax),%edx
  80058d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800592:	8d 40 04             	lea    0x4(%eax),%eax
  800595:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800598:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059d:	e9 8b 00 00 00       	jmp    80062d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 10                	mov    (%eax),%edx
  8005a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ac:	8d 40 04             	lea    0x4(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b7:	eb 74                	jmp    80062d <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005b9:	83 f9 01             	cmp    $0x1,%ecx
  8005bc:	7e 15                	jle    8005d3 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c6:	8d 40 08             	lea    0x8(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8005d1:	eb 5a                	jmp    80062d <vprintfmt+0x3bb>
	else if (lflag)
  8005d3:	85 c9                	test   %ecx,%ecx
  8005d5:	75 17                	jne    8005ee <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e1:	8d 40 04             	lea    0x4(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005e7:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ec:	eb 3f                	jmp    80062d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8b 10                	mov    (%eax),%edx
  8005f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005fe:	b8 08 00 00 00       	mov    $0x8,%eax
  800603:	eb 28                	jmp    80062d <vprintfmt+0x3bb>
			putch('0', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 30                	push   $0x30
  80060b:	ff d6                	call   *%esi
			putch('x', putdat);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 78                	push   $0x78
  800613:	ff d6                	call   *%esi
			num = (unsigned long long)
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80061f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800622:	8d 40 04             	lea    0x4(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800628:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80062d:	83 ec 0c             	sub    $0xc,%esp
  800630:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800634:	57                   	push   %edi
  800635:	ff 75 e0             	pushl  -0x20(%ebp)
  800638:	50                   	push   %eax
  800639:	51                   	push   %ecx
  80063a:	52                   	push   %edx
  80063b:	89 da                	mov    %ebx,%edx
  80063d:	89 f0                	mov    %esi,%eax
  80063f:	e8 45 fb ff ff       	call   800189 <printnum>
			break;
  800644:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80064a:	83 c7 01             	add    $0x1,%edi
  80064d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800651:	83 f8 25             	cmp    $0x25,%eax
  800654:	0f 84 2f fc ff ff    	je     800289 <vprintfmt+0x17>
			if (ch == '\0')
  80065a:	85 c0                	test   %eax,%eax
  80065c:	0f 84 8b 00 00 00    	je     8006ed <vprintfmt+0x47b>
			putch(ch, putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	50                   	push   %eax
  800667:	ff d6                	call   *%esi
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	eb dc                	jmp    80064a <vprintfmt+0x3d8>
	if (lflag >= 2)
  80066e:	83 f9 01             	cmp    $0x1,%ecx
  800671:	7e 15                	jle    800688 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	8b 48 04             	mov    0x4(%eax),%ecx
  80067b:	8d 40 08             	lea    0x8(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800681:	b8 10 00 00 00       	mov    $0x10,%eax
  800686:	eb a5                	jmp    80062d <vprintfmt+0x3bb>
	else if (lflag)
  800688:	85 c9                	test   %ecx,%ecx
  80068a:	75 17                	jne    8006a3 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	b9 00 00 00 00       	mov    $0x0,%ecx
  800696:	8d 40 04             	lea    0x4(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069c:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a1:	eb 8a                	jmp    80062d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b8:	e9 70 ff ff ff       	jmp    80062d <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	6a 25                	push   $0x25
  8006c3:	ff d6                	call   *%esi
			break;
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	e9 7a ff ff ff       	jmp    800647 <vprintfmt+0x3d5>
			putch('%', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 25                	push   $0x25
  8006d3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	89 f8                	mov    %edi,%eax
  8006da:	eb 03                	jmp    8006df <vprintfmt+0x46d>
  8006dc:	83 e8 01             	sub    $0x1,%eax
  8006df:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e3:	75 f7                	jne    8006dc <vprintfmt+0x46a>
  8006e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e8:	e9 5a ff ff ff       	jmp    800647 <vprintfmt+0x3d5>
}
  8006ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f0:	5b                   	pop    %ebx
  8006f1:	5e                   	pop    %esi
  8006f2:	5f                   	pop    %edi
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 18             	sub    $0x18,%esp
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800704:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800708:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800712:	85 c0                	test   %eax,%eax
  800714:	74 26                	je     80073c <vsnprintf+0x47>
  800716:	85 d2                	test   %edx,%edx
  800718:	7e 22                	jle    80073c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071a:	ff 75 14             	pushl  0x14(%ebp)
  80071d:	ff 75 10             	pushl  0x10(%ebp)
  800720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	68 38 02 80 00       	push   $0x800238
  800729:	e8 44 fb ff ff       	call   800272 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800731:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800737:	83 c4 10             	add    $0x10,%esp
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    
		return -E_INVAL;
  80073c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800741:	eb f7                	jmp    80073a <vsnprintf+0x45>

00800743 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074c:	50                   	push   %eax
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	ff 75 08             	pushl  0x8(%ebp)
  800756:	e8 9a ff ff ff       	call   8006f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
  800768:	eb 03                	jmp    80076d <strlen+0x10>
		n++;
  80076a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80076d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800771:	75 f7                	jne    80076a <strlen+0xd>
	return n;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077e:	b8 00 00 00 00       	mov    $0x0,%eax
  800783:	eb 03                	jmp    800788 <strnlen+0x13>
		n++;
  800785:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800788:	39 d0                	cmp    %edx,%eax
  80078a:	74 06                	je     800792 <strnlen+0x1d>
  80078c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800790:	75 f3                	jne    800785 <strnlen+0x10>
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079e:	89 c2                	mov    %eax,%edx
  8007a0:	83 c1 01             	add    $0x1,%ecx
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ad:	84 db                	test   %bl,%bl
  8007af:	75 ef                	jne    8007a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bb:	53                   	push   %ebx
  8007bc:	e8 9c ff ff ff       	call   80075d <strlen>
  8007c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c4:	ff 75 0c             	pushl  0xc(%ebp)
  8007c7:	01 d8                	add    %ebx,%eax
  8007c9:	50                   	push   %eax
  8007ca:	e8 c5 ff ff ff       	call   800794 <strcpy>
	return dst;
}
  8007cf:	89 d8                	mov    %ebx,%eax
  8007d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	56                   	push   %esi
  8007da:	53                   	push   %ebx
  8007db:	8b 75 08             	mov    0x8(%ebp),%esi
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e1:	89 f3                	mov    %esi,%ebx
  8007e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e6:	89 f2                	mov    %esi,%edx
  8007e8:	eb 0f                	jmp    8007f9 <strncpy+0x23>
		*dst++ = *src;
  8007ea:	83 c2 01             	add    $0x1,%edx
  8007ed:	0f b6 01             	movzbl (%ecx),%eax
  8007f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007f9:	39 da                	cmp    %ebx,%edx
  8007fb:	75 ed                	jne    8007ea <strncpy+0x14>
	}
	return ret;
}
  8007fd:	89 f0                	mov    %esi,%eax
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	56                   	push   %esi
  800807:	53                   	push   %ebx
  800808:	8b 75 08             	mov    0x8(%ebp),%esi
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800811:	89 f0                	mov    %esi,%eax
  800813:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800817:	85 c9                	test   %ecx,%ecx
  800819:	75 0b                	jne    800826 <strlcpy+0x23>
  80081b:	eb 17                	jmp    800834 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	83 c0 01             	add    $0x1,%eax
  800823:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800826:	39 d8                	cmp    %ebx,%eax
  800828:	74 07                	je     800831 <strlcpy+0x2e>
  80082a:	0f b6 0a             	movzbl (%edx),%ecx
  80082d:	84 c9                	test   %cl,%cl
  80082f:	75 ec                	jne    80081d <strlcpy+0x1a>
		*dst = '\0';
  800831:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800834:	29 f0                	sub    %esi,%eax
}
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800840:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800843:	eb 06                	jmp    80084b <strcmp+0x11>
		p++, q++;
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80084b:	0f b6 01             	movzbl (%ecx),%eax
  80084e:	84 c0                	test   %al,%al
  800850:	74 04                	je     800856 <strcmp+0x1c>
  800852:	3a 02                	cmp    (%edx),%al
  800854:	74 ef                	je     800845 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800856:	0f b6 c0             	movzbl %al,%eax
  800859:	0f b6 12             	movzbl (%edx),%edx
  80085c:	29 d0                	sub    %edx,%eax
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	53                   	push   %ebx
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	89 c3                	mov    %eax,%ebx
  80086c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086f:	eb 06                	jmp    800877 <strncmp+0x17>
		n--, p++, q++;
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800877:	39 d8                	cmp    %ebx,%eax
  800879:	74 16                	je     800891 <strncmp+0x31>
  80087b:	0f b6 08             	movzbl (%eax),%ecx
  80087e:	84 c9                	test   %cl,%cl
  800880:	74 04                	je     800886 <strncmp+0x26>
  800882:	3a 0a                	cmp    (%edx),%cl
  800884:	74 eb                	je     800871 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800886:	0f b6 00             	movzbl (%eax),%eax
  800889:	0f b6 12             	movzbl (%edx),%edx
  80088c:	29 d0                	sub    %edx,%eax
}
  80088e:	5b                   	pop    %ebx
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    
		return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	eb f6                	jmp    80088e <strncmp+0x2e>

00800898 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a2:	0f b6 10             	movzbl (%eax),%edx
  8008a5:	84 d2                	test   %dl,%dl
  8008a7:	74 09                	je     8008b2 <strchr+0x1a>
		if (*s == c)
  8008a9:	38 ca                	cmp    %cl,%dl
  8008ab:	74 0a                	je     8008b7 <strchr+0x1f>
	for (; *s; s++)
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	eb f0                	jmp    8008a2 <strchr+0xa>
			return (char *) s;
	return 0;
  8008b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c3:	eb 03                	jmp    8008c8 <strfind+0xf>
  8008c5:	83 c0 01             	add    $0x1,%eax
  8008c8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cb:	38 ca                	cmp    %cl,%dl
  8008cd:	74 04                	je     8008d3 <strfind+0x1a>
  8008cf:	84 d2                	test   %dl,%dl
  8008d1:	75 f2                	jne    8008c5 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	57                   	push   %edi
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e1:	85 c9                	test   %ecx,%ecx
  8008e3:	74 13                	je     8008f8 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008eb:	75 05                	jne    8008f2 <memset+0x1d>
  8008ed:	f6 c1 03             	test   $0x3,%cl
  8008f0:	74 0d                	je     8008ff <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f5:	fc                   	cld    
  8008f6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f8:	89 f8                	mov    %edi,%eax
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5f                   	pop    %edi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    
		c &= 0xFF;
  8008ff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800903:	89 d3                	mov    %edx,%ebx
  800905:	c1 e3 08             	shl    $0x8,%ebx
  800908:	89 d0                	mov    %edx,%eax
  80090a:	c1 e0 18             	shl    $0x18,%eax
  80090d:	89 d6                	mov    %edx,%esi
  80090f:	c1 e6 10             	shl    $0x10,%esi
  800912:	09 f0                	or     %esi,%eax
  800914:	09 c2                	or     %eax,%edx
  800916:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800918:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	fc                   	cld    
  80091e:	f3 ab                	rep stos %eax,%es:(%edi)
  800920:	eb d6                	jmp    8008f8 <memset+0x23>

00800922 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	57                   	push   %edi
  800926:	56                   	push   %esi
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800930:	39 c6                	cmp    %eax,%esi
  800932:	73 35                	jae    800969 <memmove+0x47>
  800934:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800937:	39 c2                	cmp    %eax,%edx
  800939:	76 2e                	jbe    800969 <memmove+0x47>
		s += n;
		d += n;
  80093b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093e:	89 d6                	mov    %edx,%esi
  800940:	09 fe                	or     %edi,%esi
  800942:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800948:	74 0c                	je     800956 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094a:	83 ef 01             	sub    $0x1,%edi
  80094d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800950:	fd                   	std    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800953:	fc                   	cld    
  800954:	eb 21                	jmp    800977 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	f6 c1 03             	test   $0x3,%cl
  800959:	75 ef                	jne    80094a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095b:	83 ef 04             	sub    $0x4,%edi
  80095e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800961:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800964:	fd                   	std    
  800965:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800967:	eb ea                	jmp    800953 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800969:	89 f2                	mov    %esi,%edx
  80096b:	09 c2                	or     %eax,%edx
  80096d:	f6 c2 03             	test   $0x3,%dl
  800970:	74 09                	je     80097b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800972:	89 c7                	mov    %eax,%edi
  800974:	fc                   	cld    
  800975:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800977:	5e                   	pop    %esi
  800978:	5f                   	pop    %edi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097b:	f6 c1 03             	test   $0x3,%cl
  80097e:	75 f2                	jne    800972 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800980:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800983:	89 c7                	mov    %eax,%edi
  800985:	fc                   	cld    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb ed                	jmp    800977 <memmove+0x55>

0080098a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098d:	ff 75 10             	pushl  0x10(%ebp)
  800990:	ff 75 0c             	pushl  0xc(%ebp)
  800993:	ff 75 08             	pushl  0x8(%ebp)
  800996:	e8 87 ff ff ff       	call   800922 <memmove>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a8:	89 c6                	mov    %eax,%esi
  8009aa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ad:	39 f0                	cmp    %esi,%eax
  8009af:	74 1c                	je     8009cd <memcmp+0x30>
		if (*s1 != *s2)
  8009b1:	0f b6 08             	movzbl (%eax),%ecx
  8009b4:	0f b6 1a             	movzbl (%edx),%ebx
  8009b7:	38 d9                	cmp    %bl,%cl
  8009b9:	75 08                	jne    8009c3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	83 c2 01             	add    $0x1,%edx
  8009c1:	eb ea                	jmp    8009ad <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009c3:	0f b6 c1             	movzbl %cl,%eax
  8009c6:	0f b6 db             	movzbl %bl,%ebx
  8009c9:	29 d8                	sub    %ebx,%eax
  8009cb:	eb 05                	jmp    8009d2 <memcmp+0x35>
	}

	return 0;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009df:	89 c2                	mov    %eax,%edx
  8009e1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e4:	39 d0                	cmp    %edx,%eax
  8009e6:	73 09                	jae    8009f1 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e8:	38 08                	cmp    %cl,(%eax)
  8009ea:	74 05                	je     8009f1 <memfind+0x1b>
	for (; s < ends; s++)
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	eb f3                	jmp    8009e4 <memfind+0xe>
			break;
	return (void *) s;
}
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ff:	eb 03                	jmp    800a04 <strtol+0x11>
		s++;
  800a01:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a04:	0f b6 01             	movzbl (%ecx),%eax
  800a07:	3c 20                	cmp    $0x20,%al
  800a09:	74 f6                	je     800a01 <strtol+0xe>
  800a0b:	3c 09                	cmp    $0x9,%al
  800a0d:	74 f2                	je     800a01 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a0f:	3c 2b                	cmp    $0x2b,%al
  800a11:	74 2e                	je     800a41 <strtol+0x4e>
	int neg = 0;
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a18:	3c 2d                	cmp    $0x2d,%al
  800a1a:	74 2f                	je     800a4b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a22:	75 05                	jne    800a29 <strtol+0x36>
  800a24:	80 39 30             	cmpb   $0x30,(%ecx)
  800a27:	74 2c                	je     800a55 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a29:	85 db                	test   %ebx,%ebx
  800a2b:	75 0a                	jne    800a37 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a2d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a32:	80 39 30             	cmpb   $0x30,(%ecx)
  800a35:	74 28                	je     800a5f <strtol+0x6c>
		base = 10;
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a3f:	eb 50                	jmp    800a91 <strtol+0x9e>
		s++;
  800a41:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a44:	bf 00 00 00 00       	mov    $0x0,%edi
  800a49:	eb d1                	jmp    800a1c <strtol+0x29>
		s++, neg = 1;
  800a4b:	83 c1 01             	add    $0x1,%ecx
  800a4e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a53:	eb c7                	jmp    800a1c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a55:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a59:	74 0e                	je     800a69 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a5b:	85 db                	test   %ebx,%ebx
  800a5d:	75 d8                	jne    800a37 <strtol+0x44>
		s++, base = 8;
  800a5f:	83 c1 01             	add    $0x1,%ecx
  800a62:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a67:	eb ce                	jmp    800a37 <strtol+0x44>
		s += 2, base = 16;
  800a69:	83 c1 02             	add    $0x2,%ecx
  800a6c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a71:	eb c4                	jmp    800a37 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a73:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 19             	cmp    $0x19,%bl
  800a7b:	77 29                	ja     800aa6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a7d:	0f be d2             	movsbl %dl,%edx
  800a80:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a83:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a86:	7d 30                	jge    800ab8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a88:	83 c1 01             	add    $0x1,%ecx
  800a8b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a91:	0f b6 11             	movzbl (%ecx),%edx
  800a94:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a97:	89 f3                	mov    %esi,%ebx
  800a99:	80 fb 09             	cmp    $0x9,%bl
  800a9c:	77 d5                	ja     800a73 <strtol+0x80>
			dig = *s - '0';
  800a9e:	0f be d2             	movsbl %dl,%edx
  800aa1:	83 ea 30             	sub    $0x30,%edx
  800aa4:	eb dd                	jmp    800a83 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800aa6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa9:	89 f3                	mov    %esi,%ebx
  800aab:	80 fb 19             	cmp    $0x19,%bl
  800aae:	77 08                	ja     800ab8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ab0:	0f be d2             	movsbl %dl,%edx
  800ab3:	83 ea 37             	sub    $0x37,%edx
  800ab6:	eb cb                	jmp    800a83 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abc:	74 05                	je     800ac3 <strtol+0xd0>
		*endptr = (char *) s;
  800abe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ac3:	89 c2                	mov    %eax,%edx
  800ac5:	f7 da                	neg    %edx
  800ac7:	85 ff                	test   %edi,%edi
  800ac9:	0f 45 c2             	cmovne %edx,%eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
  800adc:	8b 55 08             	mov    0x8(%ebp),%edx
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae2:	89 c3                	mov    %eax,%ebx
  800ae4:	89 c7                	mov    %eax,%edi
  800ae6:	89 c6                	mov    %eax,%esi
  800ae8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <sys_cgetc>:

int
sys_cgetc(void)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af5:	ba 00 00 00 00       	mov    $0x0,%edx
  800afa:	b8 01 00 00 00       	mov    $0x1,%eax
  800aff:	89 d1                	mov    %edx,%ecx
  800b01:	89 d3                	mov    %edx,%ebx
  800b03:	89 d7                	mov    %edx,%edi
  800b05:	89 d6                	mov    %edx,%esi
  800b07:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
  800b14:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b24:	89 cb                	mov    %ecx,%ebx
  800b26:	89 cf                	mov    %ecx,%edi
  800b28:	89 ce                	mov    %ecx,%esi
  800b2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b2c:	85 c0                	test   %eax,%eax
  800b2e:	7f 08                	jg     800b38 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b38:	83 ec 0c             	sub    $0xc,%esp
  800b3b:	50                   	push   %eax
  800b3c:	6a 03                	push   $0x3
  800b3e:	68 9f 21 80 00       	push   $0x80219f
  800b43:	6a 23                	push   $0x23
  800b45:	68 bc 21 80 00       	push   $0x8021bc
  800b4a:	e8 72 0f 00 00       	call   801ac1 <_panic>

00800b4f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5f:	89 d1                	mov    %edx,%ecx
  800b61:	89 d3                	mov    %edx,%ebx
  800b63:	89 d7                	mov    %edx,%edi
  800b65:	89 d6                	mov    %edx,%esi
  800b67:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_yield>:

void
sys_yield(void)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b7e:	89 d1                	mov    %edx,%ecx
  800b80:	89 d3                	mov    %edx,%ebx
  800b82:	89 d7                	mov    %edx,%edi
  800b84:	89 d6                	mov    %edx,%esi
  800b86:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b96:	be 00 00 00 00       	mov    $0x0,%esi
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba9:	89 f7                	mov    %esi,%edi
  800bab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bad:	85 c0                	test   %eax,%eax
  800baf:	7f 08                	jg     800bb9 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb9:	83 ec 0c             	sub    $0xc,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 04                	push   $0x4
  800bbf:	68 9f 21 80 00       	push   $0x80219f
  800bc4:	6a 23                	push   $0x23
  800bc6:	68 bc 21 80 00       	push   $0x8021bc
  800bcb:	e8 f1 0e 00 00       	call   801ac1 <_panic>

00800bd0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	b8 05 00 00 00       	mov    $0x5,%eax
  800be4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bea:	8b 75 18             	mov    0x18(%ebp),%esi
  800bed:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	7f 08                	jg     800bfb <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	50                   	push   %eax
  800bff:	6a 05                	push   $0x5
  800c01:	68 9f 21 80 00       	push   $0x80219f
  800c06:	6a 23                	push   $0x23
  800c08:	68 bc 21 80 00       	push   $0x8021bc
  800c0d:	e8 af 0e 00 00       	call   801ac1 <_panic>

00800c12 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2b:	89 df                	mov    %ebx,%edi
  800c2d:	89 de                	mov    %ebx,%esi
  800c2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	7f 08                	jg     800c3d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 06                	push   $0x6
  800c43:	68 9f 21 80 00       	push   $0x80219f
  800c48:	6a 23                	push   $0x23
  800c4a:	68 bc 21 80 00       	push   $0x8021bc
  800c4f:	e8 6d 0e 00 00       	call   801ac1 <_panic>

00800c54 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6d:	89 df                	mov    %ebx,%edi
  800c6f:	89 de                	mov    %ebx,%esi
  800c71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7f 08                	jg     800c7f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 08                	push   $0x8
  800c85:	68 9f 21 80 00       	push   $0x80219f
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 bc 21 80 00       	push   $0x8021bc
  800c91:	e8 2b 0e 00 00       	call   801ac1 <_panic>

00800c96 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	b8 09 00 00 00       	mov    $0x9,%eax
  800caf:	89 df                	mov    %ebx,%edi
  800cb1:	89 de                	mov    %ebx,%esi
  800cb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7f 08                	jg     800cc1 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 09                	push   $0x9
  800cc7:	68 9f 21 80 00       	push   $0x80219f
  800ccc:	6a 23                	push   $0x23
  800cce:	68 bc 21 80 00       	push   $0x8021bc
  800cd3:	e8 e9 0d 00 00       	call   801ac1 <_panic>

00800cd8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf1:	89 df                	mov    %ebx,%edi
  800cf3:	89 de                	mov    %ebx,%esi
  800cf5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	7f 08                	jg     800d03 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 0a                	push   $0xa
  800d09:	68 9f 21 80 00       	push   $0x80219f
  800d0e:	6a 23                	push   $0x23
  800d10:	68 bc 21 80 00       	push   $0x8021bc
  800d15:	e8 a7 0d 00 00       	call   801ac1 <_panic>

00800d1a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2b:	be 00 00 00 00       	mov    $0x0,%esi
  800d30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d36:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d53:	89 cb                	mov    %ecx,%ebx
  800d55:	89 cf                	mov    %ecx,%edi
  800d57:	89 ce                	mov    %ecx,%esi
  800d59:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7f 08                	jg     800d67 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	50                   	push   %eax
  800d6b:	6a 0d                	push   $0xd
  800d6d:	68 9f 21 80 00       	push   $0x80219f
  800d72:	6a 23                	push   $0x23
  800d74:	68 bc 21 80 00       	push   $0x8021bc
  800d79:	e8 43 0d 00 00       	call   801ac1 <_panic>

00800d7e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d84:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d8b:	74 20                	je     800dad <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d90:	a3 08 40 80 00       	mov    %eax,0x804008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d95:	83 ec 08             	sub    $0x8,%esp
  800d98:	68 ed 0d 80 00       	push   $0x800ded
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 34 ff ff ff       	call   800cd8 <sys_env_set_pgfault_upcall>
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	78 2e                	js     800dd9 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  800dab:	c9                   	leave  
  800dac:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800dad:	83 ec 04             	sub    $0x4,%esp
  800db0:	6a 07                	push   $0x7
  800db2:	68 00 f0 bf ee       	push   $0xeebff000
  800db7:	6a 00                	push   $0x0
  800db9:	e8 cf fd ff ff       	call   800b8d <sys_page_alloc>
  800dbe:	83 c4 10             	add    $0x10,%esp
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	79 c8                	jns    800d8d <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  800dc5:	83 ec 04             	sub    $0x4,%esp
  800dc8:	68 cc 21 80 00       	push   $0x8021cc
  800dcd:	6a 21                	push   $0x21
  800dcf:	68 2e 22 80 00       	push   $0x80222e
  800dd4:	e8 e8 0c 00 00       	call   801ac1 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800dd9:	83 ec 04             	sub    $0x4,%esp
  800ddc:	68 f8 21 80 00       	push   $0x8021f8
  800de1:	6a 27                	push   $0x27
  800de3:	68 2e 22 80 00       	push   $0x80222e
  800de8:	e8 d4 0c 00 00       	call   801ac1 <_panic>

00800ded <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ded:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dee:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800df3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800df5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  800df8:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800dfc:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800dff:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  800e03:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800e07:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800e09:	83 c4 08             	add    $0x8,%esp
	popal
  800e0c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800e0d:	83 c4 04             	add    $0x4,%esp
	popfl
  800e10:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e11:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e12:	c3                   	ret    

00800e13 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e16:	8b 45 08             	mov    0x8(%ebp),%eax
  800e19:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1e:	c1 e8 0c             	shr    $0xc,%eax
}
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e26:	8b 45 08             	mov    0x8(%ebp),%eax
  800e29:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e2e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e33:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e40:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e45:	89 c2                	mov    %eax,%edx
  800e47:	c1 ea 16             	shr    $0x16,%edx
  800e4a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e51:	f6 c2 01             	test   $0x1,%dl
  800e54:	74 2a                	je     800e80 <fd_alloc+0x46>
  800e56:	89 c2                	mov    %eax,%edx
  800e58:	c1 ea 0c             	shr    $0xc,%edx
  800e5b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e62:	f6 c2 01             	test   $0x1,%dl
  800e65:	74 19                	je     800e80 <fd_alloc+0x46>
  800e67:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e6c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e71:	75 d2                	jne    800e45 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e73:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e79:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e7e:	eb 07                	jmp    800e87 <fd_alloc+0x4d>
			*fd_store = fd;
  800e80:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e8f:	83 f8 1f             	cmp    $0x1f,%eax
  800e92:	77 36                	ja     800eca <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e94:	c1 e0 0c             	shl    $0xc,%eax
  800e97:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e9c:	89 c2                	mov    %eax,%edx
  800e9e:	c1 ea 16             	shr    $0x16,%edx
  800ea1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea8:	f6 c2 01             	test   $0x1,%dl
  800eab:	74 24                	je     800ed1 <fd_lookup+0x48>
  800ead:	89 c2                	mov    %eax,%edx
  800eaf:	c1 ea 0c             	shr    $0xc,%edx
  800eb2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb9:	f6 c2 01             	test   $0x1,%dl
  800ebc:	74 1a                	je     800ed8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ebe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec1:	89 02                	mov    %eax,(%edx)
	return 0;
  800ec3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    
		return -E_INVAL;
  800eca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ecf:	eb f7                	jmp    800ec8 <fd_lookup+0x3f>
		return -E_INVAL;
  800ed1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed6:	eb f0                	jmp    800ec8 <fd_lookup+0x3f>
  800ed8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800edd:	eb e9                	jmp    800ec8 <fd_lookup+0x3f>

00800edf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	83 ec 08             	sub    $0x8,%esp
  800ee5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee8:	ba b8 22 80 00       	mov    $0x8022b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eed:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ef2:	39 08                	cmp    %ecx,(%eax)
  800ef4:	74 33                	je     800f29 <dev_lookup+0x4a>
  800ef6:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800ef9:	8b 02                	mov    (%edx),%eax
  800efb:	85 c0                	test   %eax,%eax
  800efd:	75 f3                	jne    800ef2 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eff:	a1 04 40 80 00       	mov    0x804004,%eax
  800f04:	8b 40 48             	mov    0x48(%eax),%eax
  800f07:	83 ec 04             	sub    $0x4,%esp
  800f0a:	51                   	push   %ecx
  800f0b:	50                   	push   %eax
  800f0c:	68 3c 22 80 00       	push   $0x80223c
  800f11:	e8 5f f2 ff ff       	call   800175 <cprintf>
	*dev = 0;
  800f16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    
			*dev = devtab[i];
  800f29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f33:	eb f2                	jmp    800f27 <dev_lookup+0x48>

00800f35 <fd_close>:
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 1c             	sub    $0x1c,%esp
  800f3e:	8b 75 08             	mov    0x8(%ebp),%esi
  800f41:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f44:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f47:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f48:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f4e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f51:	50                   	push   %eax
  800f52:	e8 32 ff ff ff       	call   800e89 <fd_lookup>
  800f57:	89 c3                	mov    %eax,%ebx
  800f59:	83 c4 08             	add    $0x8,%esp
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	78 05                	js     800f65 <fd_close+0x30>
	    || fd != fd2)
  800f60:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f63:	74 16                	je     800f7b <fd_close+0x46>
		return (must_exist ? r : 0);
  800f65:	89 f8                	mov    %edi,%eax
  800f67:	84 c0                	test   %al,%al
  800f69:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6e:	0f 44 d8             	cmove  %eax,%ebx
}
  800f71:	89 d8                	mov    %ebx,%eax
  800f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f76:	5b                   	pop    %ebx
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f81:	50                   	push   %eax
  800f82:	ff 36                	pushl  (%esi)
  800f84:	e8 56 ff ff ff       	call   800edf <dev_lookup>
  800f89:	89 c3                	mov    %eax,%ebx
  800f8b:	83 c4 10             	add    $0x10,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	78 15                	js     800fa7 <fd_close+0x72>
		if (dev->dev_close)
  800f92:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f95:	8b 40 10             	mov    0x10(%eax),%eax
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	74 1b                	je     800fb7 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	56                   	push   %esi
  800fa0:	ff d0                	call   *%eax
  800fa2:	89 c3                	mov    %eax,%ebx
  800fa4:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fa7:	83 ec 08             	sub    $0x8,%esp
  800faa:	56                   	push   %esi
  800fab:	6a 00                	push   $0x0
  800fad:	e8 60 fc ff ff       	call   800c12 <sys_page_unmap>
	return r;
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	eb ba                	jmp    800f71 <fd_close+0x3c>
			r = 0;
  800fb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbc:	eb e9                	jmp    800fa7 <fd_close+0x72>

00800fbe <close>:

int
close(int fdnum)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc7:	50                   	push   %eax
  800fc8:	ff 75 08             	pushl  0x8(%ebp)
  800fcb:	e8 b9 fe ff ff       	call   800e89 <fd_lookup>
  800fd0:	83 c4 08             	add    $0x8,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	78 10                	js     800fe7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fd7:	83 ec 08             	sub    $0x8,%esp
  800fda:	6a 01                	push   $0x1
  800fdc:	ff 75 f4             	pushl  -0xc(%ebp)
  800fdf:	e8 51 ff ff ff       	call   800f35 <fd_close>
  800fe4:	83 c4 10             	add    $0x10,%esp
}
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <close_all>:

void
close_all(void)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	53                   	push   %ebx
  800fed:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ff0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	53                   	push   %ebx
  800ff9:	e8 c0 ff ff ff       	call   800fbe <close>
	for (i = 0; i < MAXFD; i++)
  800ffe:	83 c3 01             	add    $0x1,%ebx
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	83 fb 20             	cmp    $0x20,%ebx
  801007:	75 ec                	jne    800ff5 <close_all+0xc>
}
  801009:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80100c:	c9                   	leave  
  80100d:	c3                   	ret    

0080100e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801017:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80101a:	50                   	push   %eax
  80101b:	ff 75 08             	pushl  0x8(%ebp)
  80101e:	e8 66 fe ff ff       	call   800e89 <fd_lookup>
  801023:	89 c3                	mov    %eax,%ebx
  801025:	83 c4 08             	add    $0x8,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	0f 88 81 00 00 00    	js     8010b1 <dup+0xa3>
		return r;
	close(newfdnum);
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	ff 75 0c             	pushl  0xc(%ebp)
  801036:	e8 83 ff ff ff       	call   800fbe <close>

	newfd = INDEX2FD(newfdnum);
  80103b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80103e:	c1 e6 0c             	shl    $0xc,%esi
  801041:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801047:	83 c4 04             	add    $0x4,%esp
  80104a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104d:	e8 d1 fd ff ff       	call   800e23 <fd2data>
  801052:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801054:	89 34 24             	mov    %esi,(%esp)
  801057:	e8 c7 fd ff ff       	call   800e23 <fd2data>
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801061:	89 d8                	mov    %ebx,%eax
  801063:	c1 e8 16             	shr    $0x16,%eax
  801066:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80106d:	a8 01                	test   $0x1,%al
  80106f:	74 11                	je     801082 <dup+0x74>
  801071:	89 d8                	mov    %ebx,%eax
  801073:	c1 e8 0c             	shr    $0xc,%eax
  801076:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80107d:	f6 c2 01             	test   $0x1,%dl
  801080:	75 39                	jne    8010bb <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801082:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801085:	89 d0                	mov    %edx,%eax
  801087:	c1 e8 0c             	shr    $0xc,%eax
  80108a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	25 07 0e 00 00       	and    $0xe07,%eax
  801099:	50                   	push   %eax
  80109a:	56                   	push   %esi
  80109b:	6a 00                	push   $0x0
  80109d:	52                   	push   %edx
  80109e:	6a 00                	push   $0x0
  8010a0:	e8 2b fb ff ff       	call   800bd0 <sys_page_map>
  8010a5:	89 c3                	mov    %eax,%ebx
  8010a7:	83 c4 20             	add    $0x20,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	78 31                	js     8010df <dup+0xd1>
		goto err;

	return newfdnum;
  8010ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010b1:	89 d8                	mov    %ebx,%eax
  8010b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b6:	5b                   	pop    %ebx
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c2:	83 ec 0c             	sub    $0xc,%esp
  8010c5:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ca:	50                   	push   %eax
  8010cb:	57                   	push   %edi
  8010cc:	6a 00                	push   $0x0
  8010ce:	53                   	push   %ebx
  8010cf:	6a 00                	push   $0x0
  8010d1:	e8 fa fa ff ff       	call   800bd0 <sys_page_map>
  8010d6:	89 c3                	mov    %eax,%ebx
  8010d8:	83 c4 20             	add    $0x20,%esp
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	79 a3                	jns    801082 <dup+0x74>
	sys_page_unmap(0, newfd);
  8010df:	83 ec 08             	sub    $0x8,%esp
  8010e2:	56                   	push   %esi
  8010e3:	6a 00                	push   $0x0
  8010e5:	e8 28 fb ff ff       	call   800c12 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010ea:	83 c4 08             	add    $0x8,%esp
  8010ed:	57                   	push   %edi
  8010ee:	6a 00                	push   $0x0
  8010f0:	e8 1d fb ff ff       	call   800c12 <sys_page_unmap>
	return r;
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	eb b7                	jmp    8010b1 <dup+0xa3>

008010fa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	53                   	push   %ebx
  8010fe:	83 ec 14             	sub    $0x14,%esp
  801101:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801104:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801107:	50                   	push   %eax
  801108:	53                   	push   %ebx
  801109:	e8 7b fd ff ff       	call   800e89 <fd_lookup>
  80110e:	83 c4 08             	add    $0x8,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	78 3f                	js     801154 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801115:	83 ec 08             	sub    $0x8,%esp
  801118:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80111b:	50                   	push   %eax
  80111c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111f:	ff 30                	pushl  (%eax)
  801121:	e8 b9 fd ff ff       	call   800edf <dev_lookup>
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	78 27                	js     801154 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80112d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801130:	8b 42 08             	mov    0x8(%edx),%eax
  801133:	83 e0 03             	and    $0x3,%eax
  801136:	83 f8 01             	cmp    $0x1,%eax
  801139:	74 1e                	je     801159 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80113b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113e:	8b 40 08             	mov    0x8(%eax),%eax
  801141:	85 c0                	test   %eax,%eax
  801143:	74 35                	je     80117a <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	ff 75 10             	pushl  0x10(%ebp)
  80114b:	ff 75 0c             	pushl  0xc(%ebp)
  80114e:	52                   	push   %edx
  80114f:	ff d0                	call   *%eax
  801151:	83 c4 10             	add    $0x10,%esp
}
  801154:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801157:	c9                   	leave  
  801158:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801159:	a1 04 40 80 00       	mov    0x804004,%eax
  80115e:	8b 40 48             	mov    0x48(%eax),%eax
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	53                   	push   %ebx
  801165:	50                   	push   %eax
  801166:	68 7d 22 80 00       	push   $0x80227d
  80116b:	e8 05 f0 ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801178:	eb da                	jmp    801154 <read+0x5a>
		return -E_NOT_SUPP;
  80117a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80117f:	eb d3                	jmp    801154 <read+0x5a>

00801181 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	57                   	push   %edi
  801185:	56                   	push   %esi
  801186:	53                   	push   %ebx
  801187:	83 ec 0c             	sub    $0xc,%esp
  80118a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80118d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801190:	bb 00 00 00 00       	mov    $0x0,%ebx
  801195:	39 f3                	cmp    %esi,%ebx
  801197:	73 25                	jae    8011be <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801199:	83 ec 04             	sub    $0x4,%esp
  80119c:	89 f0                	mov    %esi,%eax
  80119e:	29 d8                	sub    %ebx,%eax
  8011a0:	50                   	push   %eax
  8011a1:	89 d8                	mov    %ebx,%eax
  8011a3:	03 45 0c             	add    0xc(%ebp),%eax
  8011a6:	50                   	push   %eax
  8011a7:	57                   	push   %edi
  8011a8:	e8 4d ff ff ff       	call   8010fa <read>
		if (m < 0)
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 08                	js     8011bc <readn+0x3b>
			return m;
		if (m == 0)
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	74 06                	je     8011be <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8011b8:	01 c3                	add    %eax,%ebx
  8011ba:	eb d9                	jmp    801195 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011bc:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011be:	89 d8                	mov    %ebx,%eax
  8011c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 14             	sub    $0x14,%esp
  8011cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	53                   	push   %ebx
  8011d7:	e8 ad fc ff ff       	call   800e89 <fd_lookup>
  8011dc:	83 c4 08             	add    $0x8,%esp
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	78 3a                	js     80121d <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ed:	ff 30                	pushl  (%eax)
  8011ef:	e8 eb fc ff ff       	call   800edf <dev_lookup>
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 22                	js     80121d <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801202:	74 1e                	je     801222 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801204:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801207:	8b 52 0c             	mov    0xc(%edx),%edx
  80120a:	85 d2                	test   %edx,%edx
  80120c:	74 35                	je     801243 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80120e:	83 ec 04             	sub    $0x4,%esp
  801211:	ff 75 10             	pushl  0x10(%ebp)
  801214:	ff 75 0c             	pushl  0xc(%ebp)
  801217:	50                   	push   %eax
  801218:	ff d2                	call   *%edx
  80121a:	83 c4 10             	add    $0x10,%esp
}
  80121d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801220:	c9                   	leave  
  801221:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801222:	a1 04 40 80 00       	mov    0x804004,%eax
  801227:	8b 40 48             	mov    0x48(%eax),%eax
  80122a:	83 ec 04             	sub    $0x4,%esp
  80122d:	53                   	push   %ebx
  80122e:	50                   	push   %eax
  80122f:	68 99 22 80 00       	push   $0x802299
  801234:	e8 3c ef ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801241:	eb da                	jmp    80121d <write+0x55>
		return -E_NOT_SUPP;
  801243:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801248:	eb d3                	jmp    80121d <write+0x55>

0080124a <seek>:

int
seek(int fdnum, off_t offset)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801250:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801253:	50                   	push   %eax
  801254:	ff 75 08             	pushl  0x8(%ebp)
  801257:	e8 2d fc ff ff       	call   800e89 <fd_lookup>
  80125c:	83 c4 08             	add    $0x8,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 0e                	js     801271 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801263:	8b 55 0c             	mov    0xc(%ebp),%edx
  801266:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801269:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80126c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801271:	c9                   	leave  
  801272:	c3                   	ret    

00801273 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	53                   	push   %ebx
  801277:	83 ec 14             	sub    $0x14,%esp
  80127a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801280:	50                   	push   %eax
  801281:	53                   	push   %ebx
  801282:	e8 02 fc ff ff       	call   800e89 <fd_lookup>
  801287:	83 c4 08             	add    $0x8,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 37                	js     8012c5 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801294:	50                   	push   %eax
  801295:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801298:	ff 30                	pushl  (%eax)
  80129a:	e8 40 fc ff ff       	call   800edf <dev_lookup>
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 1f                	js     8012c5 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ad:	74 1b                	je     8012ca <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b2:	8b 52 18             	mov    0x18(%edx),%edx
  8012b5:	85 d2                	test   %edx,%edx
  8012b7:	74 32                	je     8012eb <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	ff 75 0c             	pushl  0xc(%ebp)
  8012bf:	50                   	push   %eax
  8012c0:	ff d2                	call   *%edx
  8012c2:	83 c4 10             	add    $0x10,%esp
}
  8012c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c8:	c9                   	leave  
  8012c9:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012ca:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012cf:	8b 40 48             	mov    0x48(%eax),%eax
  8012d2:	83 ec 04             	sub    $0x4,%esp
  8012d5:	53                   	push   %ebx
  8012d6:	50                   	push   %eax
  8012d7:	68 5c 22 80 00       	push   $0x80225c
  8012dc:	e8 94 ee ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e9:	eb da                	jmp    8012c5 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8012eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012f0:	eb d3                	jmp    8012c5 <ftruncate+0x52>

008012f2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 14             	sub    $0x14,%esp
  8012f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ff:	50                   	push   %eax
  801300:	ff 75 08             	pushl  0x8(%ebp)
  801303:	e8 81 fb ff ff       	call   800e89 <fd_lookup>
  801308:	83 c4 08             	add    $0x8,%esp
  80130b:	85 c0                	test   %eax,%eax
  80130d:	78 4b                	js     80135a <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801315:	50                   	push   %eax
  801316:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801319:	ff 30                	pushl  (%eax)
  80131b:	e8 bf fb ff ff       	call   800edf <dev_lookup>
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	85 c0                	test   %eax,%eax
  801325:	78 33                	js     80135a <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801327:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80132e:	74 2f                	je     80135f <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801330:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801333:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80133a:	00 00 00 
	stat->st_isdir = 0;
  80133d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801344:	00 00 00 
	stat->st_dev = dev;
  801347:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	53                   	push   %ebx
  801351:	ff 75 f0             	pushl  -0x10(%ebp)
  801354:	ff 50 14             	call   *0x14(%eax)
  801357:	83 c4 10             	add    $0x10,%esp
}
  80135a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    
		return -E_NOT_SUPP;
  80135f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801364:	eb f4                	jmp    80135a <fstat+0x68>

00801366 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	56                   	push   %esi
  80136a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80136b:	83 ec 08             	sub    $0x8,%esp
  80136e:	6a 00                	push   $0x0
  801370:	ff 75 08             	pushl  0x8(%ebp)
  801373:	e8 da 01 00 00       	call   801552 <open>
  801378:	89 c3                	mov    %eax,%ebx
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 1b                	js     80139c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	ff 75 0c             	pushl  0xc(%ebp)
  801387:	50                   	push   %eax
  801388:	e8 65 ff ff ff       	call   8012f2 <fstat>
  80138d:	89 c6                	mov    %eax,%esi
	close(fd);
  80138f:	89 1c 24             	mov    %ebx,(%esp)
  801392:	e8 27 fc ff ff       	call   800fbe <close>
	return r;
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	89 f3                	mov    %esi,%ebx
}
  80139c:	89 d8                	mov    %ebx,%eax
  80139e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a1:	5b                   	pop    %ebx
  8013a2:	5e                   	pop    %esi
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	56                   	push   %esi
  8013a9:	53                   	push   %ebx
  8013aa:	89 c6                	mov    %eax,%esi
  8013ac:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013ae:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013b5:	74 27                	je     8013de <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b7:	6a 07                	push   $0x7
  8013b9:	68 00 50 80 00       	push   $0x805000
  8013be:	56                   	push   %esi
  8013bf:	ff 35 00 40 80 00    	pushl  0x804000
  8013c5:	e8 a4 07 00 00       	call   801b6e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ca:	83 c4 0c             	add    $0xc,%esp
  8013cd:	6a 00                	push   $0x0
  8013cf:	53                   	push   %ebx
  8013d0:	6a 00                	push   $0x0
  8013d2:	e8 30 07 00 00       	call   801b07 <ipc_recv>
}
  8013d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013da:	5b                   	pop    %ebx
  8013db:	5e                   	pop    %esi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013de:	83 ec 0c             	sub    $0xc,%esp
  8013e1:	6a 01                	push   $0x1
  8013e3:	e8 da 07 00 00       	call   801bc2 <ipc_find_env>
  8013e8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	eb c5                	jmp    8013b7 <fsipc+0x12>

008013f2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801403:	8b 45 0c             	mov    0xc(%ebp),%eax
  801406:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80140b:	ba 00 00 00 00       	mov    $0x0,%edx
  801410:	b8 02 00 00 00       	mov    $0x2,%eax
  801415:	e8 8b ff ff ff       	call   8013a5 <fsipc>
}
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <devfile_flush>:
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
  801425:	8b 40 0c             	mov    0xc(%eax),%eax
  801428:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80142d:	ba 00 00 00 00       	mov    $0x0,%edx
  801432:	b8 06 00 00 00       	mov    $0x6,%eax
  801437:	e8 69 ff ff ff       	call   8013a5 <fsipc>
}
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <devfile_stat>:
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	53                   	push   %ebx
  801442:	83 ec 04             	sub    $0x4,%esp
  801445:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801448:	8b 45 08             	mov    0x8(%ebp),%eax
  80144b:	8b 40 0c             	mov    0xc(%eax),%eax
  80144e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801453:	ba 00 00 00 00       	mov    $0x0,%edx
  801458:	b8 05 00 00 00       	mov    $0x5,%eax
  80145d:	e8 43 ff ff ff       	call   8013a5 <fsipc>
  801462:	85 c0                	test   %eax,%eax
  801464:	78 2c                	js     801492 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	68 00 50 80 00       	push   $0x805000
  80146e:	53                   	push   %ebx
  80146f:	e8 20 f3 ff ff       	call   800794 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801474:	a1 80 50 80 00       	mov    0x805080,%eax
  801479:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80147f:	a1 84 50 80 00       	mov    0x805084,%eax
  801484:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801492:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801495:	c9                   	leave  
  801496:	c3                   	ret    

00801497 <devfile_write>:
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	83 ec 0c             	sub    $0xc,%esp
  80149d:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8014a6:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8014ac:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8014b1:	50                   	push   %eax
  8014b2:	ff 75 0c             	pushl  0xc(%ebp)
  8014b5:	68 08 50 80 00       	push   $0x805008
  8014ba:	e8 63 f4 ff ff       	call   800922 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  8014bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8014c9:	e8 d7 fe ff ff       	call   8013a5 <fsipc>
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <devfile_read>:
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	56                   	push   %esi
  8014d4:	53                   	push   %ebx
  8014d5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014db:	8b 40 0c             	mov    0xc(%eax),%eax
  8014de:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014e3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8014f3:	e8 ad fe ff ff       	call   8013a5 <fsipc>
  8014f8:	89 c3                	mov    %eax,%ebx
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 1f                	js     80151d <devfile_read+0x4d>
	assert(r <= n);
  8014fe:	39 f0                	cmp    %esi,%eax
  801500:	77 24                	ja     801526 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801502:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801507:	7f 33                	jg     80153c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801509:	83 ec 04             	sub    $0x4,%esp
  80150c:	50                   	push   %eax
  80150d:	68 00 50 80 00       	push   $0x805000
  801512:	ff 75 0c             	pushl  0xc(%ebp)
  801515:	e8 08 f4 ff ff       	call   800922 <memmove>
	return r;
  80151a:	83 c4 10             	add    $0x10,%esp
}
  80151d:	89 d8                	mov    %ebx,%eax
  80151f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801522:	5b                   	pop    %ebx
  801523:	5e                   	pop    %esi
  801524:	5d                   	pop    %ebp
  801525:	c3                   	ret    
	assert(r <= n);
  801526:	68 c8 22 80 00       	push   $0x8022c8
  80152b:	68 cf 22 80 00       	push   $0x8022cf
  801530:	6a 7c                	push   $0x7c
  801532:	68 e4 22 80 00       	push   $0x8022e4
  801537:	e8 85 05 00 00       	call   801ac1 <_panic>
	assert(r <= PGSIZE);
  80153c:	68 ef 22 80 00       	push   $0x8022ef
  801541:	68 cf 22 80 00       	push   $0x8022cf
  801546:	6a 7d                	push   $0x7d
  801548:	68 e4 22 80 00       	push   $0x8022e4
  80154d:	e8 6f 05 00 00       	call   801ac1 <_panic>

00801552 <open>:
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	56                   	push   %esi
  801556:	53                   	push   %ebx
  801557:	83 ec 1c             	sub    $0x1c,%esp
  80155a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80155d:	56                   	push   %esi
  80155e:	e8 fa f1 ff ff       	call   80075d <strlen>
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80156b:	7f 6c                	jg     8015d9 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801573:	50                   	push   %eax
  801574:	e8 c1 f8 ff ff       	call   800e3a <fd_alloc>
  801579:	89 c3                	mov    %eax,%ebx
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 3c                	js     8015be <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801582:	83 ec 08             	sub    $0x8,%esp
  801585:	56                   	push   %esi
  801586:	68 00 50 80 00       	push   $0x805000
  80158b:	e8 04 f2 ff ff       	call   800794 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801590:	8b 45 0c             	mov    0xc(%ebp),%eax
  801593:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801598:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159b:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a0:	e8 00 fe ff ff       	call   8013a5 <fsipc>
  8015a5:	89 c3                	mov    %eax,%ebx
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 19                	js     8015c7 <open+0x75>
	return fd2num(fd);
  8015ae:	83 ec 0c             	sub    $0xc,%esp
  8015b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b4:	e8 5a f8 ff ff       	call   800e13 <fd2num>
  8015b9:	89 c3                	mov    %eax,%ebx
  8015bb:	83 c4 10             	add    $0x10,%esp
}
  8015be:	89 d8                	mov    %ebx,%eax
  8015c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c3:	5b                   	pop    %ebx
  8015c4:	5e                   	pop    %esi
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    
		fd_close(fd, 0);
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	6a 00                	push   $0x0
  8015cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8015cf:	e8 61 f9 ff ff       	call   800f35 <fd_close>
		return r;
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	eb e5                	jmp    8015be <open+0x6c>
		return -E_BAD_PATH;
  8015d9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015de:	eb de                	jmp    8015be <open+0x6c>

008015e0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8015f0:	e8 b0 fd ff ff       	call   8013a5 <fsipc>
}
  8015f5:	c9                   	leave  
  8015f6:	c3                   	ret    

008015f7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	56                   	push   %esi
  8015fb:	53                   	push   %ebx
  8015fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015ff:	83 ec 0c             	sub    $0xc,%esp
  801602:	ff 75 08             	pushl  0x8(%ebp)
  801605:	e8 19 f8 ff ff       	call   800e23 <fd2data>
  80160a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80160c:	83 c4 08             	add    $0x8,%esp
  80160f:	68 fb 22 80 00       	push   $0x8022fb
  801614:	53                   	push   %ebx
  801615:	e8 7a f1 ff ff       	call   800794 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80161a:	8b 46 04             	mov    0x4(%esi),%eax
  80161d:	2b 06                	sub    (%esi),%eax
  80161f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801625:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80162c:	00 00 00 
	stat->st_dev = &devpipe;
  80162f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801636:	30 80 00 
	return 0;
}
  801639:	b8 00 00 00 00       	mov    $0x0,%eax
  80163e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    

00801645 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	53                   	push   %ebx
  801649:	83 ec 0c             	sub    $0xc,%esp
  80164c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80164f:	53                   	push   %ebx
  801650:	6a 00                	push   $0x0
  801652:	e8 bb f5 ff ff       	call   800c12 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801657:	89 1c 24             	mov    %ebx,(%esp)
  80165a:	e8 c4 f7 ff ff       	call   800e23 <fd2data>
  80165f:	83 c4 08             	add    $0x8,%esp
  801662:	50                   	push   %eax
  801663:	6a 00                	push   $0x0
  801665:	e8 a8 f5 ff ff       	call   800c12 <sys_page_unmap>
}
  80166a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <_pipeisclosed>:
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	57                   	push   %edi
  801673:	56                   	push   %esi
  801674:	53                   	push   %ebx
  801675:	83 ec 1c             	sub    $0x1c,%esp
  801678:	89 c7                	mov    %eax,%edi
  80167a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80167c:	a1 04 40 80 00       	mov    0x804004,%eax
  801681:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801684:	83 ec 0c             	sub    $0xc,%esp
  801687:	57                   	push   %edi
  801688:	e8 6e 05 00 00       	call   801bfb <pageref>
  80168d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801690:	89 34 24             	mov    %esi,(%esp)
  801693:	e8 63 05 00 00       	call   801bfb <pageref>
		nn = thisenv->env_runs;
  801698:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80169e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	39 cb                	cmp    %ecx,%ebx
  8016a6:	74 1b                	je     8016c3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8016a8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016ab:	75 cf                	jne    80167c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016ad:	8b 42 58             	mov    0x58(%edx),%eax
  8016b0:	6a 01                	push   $0x1
  8016b2:	50                   	push   %eax
  8016b3:	53                   	push   %ebx
  8016b4:	68 02 23 80 00       	push   $0x802302
  8016b9:	e8 b7 ea ff ff       	call   800175 <cprintf>
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	eb b9                	jmp    80167c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8016c3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016c6:	0f 94 c0             	sete   %al
  8016c9:	0f b6 c0             	movzbl %al,%eax
}
  8016cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cf:	5b                   	pop    %ebx
  8016d0:	5e                   	pop    %esi
  8016d1:	5f                   	pop    %edi
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <devpipe_write>:
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	57                   	push   %edi
  8016d8:	56                   	push   %esi
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 28             	sub    $0x28,%esp
  8016dd:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8016e0:	56                   	push   %esi
  8016e1:	e8 3d f7 ff ff       	call   800e23 <fd2data>
  8016e6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	bf 00 00 00 00       	mov    $0x0,%edi
  8016f0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016f3:	74 4f                	je     801744 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016f5:	8b 43 04             	mov    0x4(%ebx),%eax
  8016f8:	8b 0b                	mov    (%ebx),%ecx
  8016fa:	8d 51 20             	lea    0x20(%ecx),%edx
  8016fd:	39 d0                	cmp    %edx,%eax
  8016ff:	72 14                	jb     801715 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801701:	89 da                	mov    %ebx,%edx
  801703:	89 f0                	mov    %esi,%eax
  801705:	e8 65 ff ff ff       	call   80166f <_pipeisclosed>
  80170a:	85 c0                	test   %eax,%eax
  80170c:	75 3a                	jne    801748 <devpipe_write+0x74>
			sys_yield();
  80170e:	e8 5b f4 ff ff       	call   800b6e <sys_yield>
  801713:	eb e0                	jmp    8016f5 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801715:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801718:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80171c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80171f:	89 c2                	mov    %eax,%edx
  801721:	c1 fa 1f             	sar    $0x1f,%edx
  801724:	89 d1                	mov    %edx,%ecx
  801726:	c1 e9 1b             	shr    $0x1b,%ecx
  801729:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80172c:	83 e2 1f             	and    $0x1f,%edx
  80172f:	29 ca                	sub    %ecx,%edx
  801731:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801735:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801739:	83 c0 01             	add    $0x1,%eax
  80173c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80173f:	83 c7 01             	add    $0x1,%edi
  801742:	eb ac                	jmp    8016f0 <devpipe_write+0x1c>
	return i;
  801744:	89 f8                	mov    %edi,%eax
  801746:	eb 05                	jmp    80174d <devpipe_write+0x79>
				return 0;
  801748:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801750:	5b                   	pop    %ebx
  801751:	5e                   	pop    %esi
  801752:	5f                   	pop    %edi
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <devpipe_read>:
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	57                   	push   %edi
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
  80175b:	83 ec 18             	sub    $0x18,%esp
  80175e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801761:	57                   	push   %edi
  801762:	e8 bc f6 ff ff       	call   800e23 <fd2data>
  801767:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	be 00 00 00 00       	mov    $0x0,%esi
  801771:	3b 75 10             	cmp    0x10(%ebp),%esi
  801774:	74 47                	je     8017bd <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801776:	8b 03                	mov    (%ebx),%eax
  801778:	3b 43 04             	cmp    0x4(%ebx),%eax
  80177b:	75 22                	jne    80179f <devpipe_read+0x4a>
			if (i > 0)
  80177d:	85 f6                	test   %esi,%esi
  80177f:	75 14                	jne    801795 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801781:	89 da                	mov    %ebx,%edx
  801783:	89 f8                	mov    %edi,%eax
  801785:	e8 e5 fe ff ff       	call   80166f <_pipeisclosed>
  80178a:	85 c0                	test   %eax,%eax
  80178c:	75 33                	jne    8017c1 <devpipe_read+0x6c>
			sys_yield();
  80178e:	e8 db f3 ff ff       	call   800b6e <sys_yield>
  801793:	eb e1                	jmp    801776 <devpipe_read+0x21>
				return i;
  801795:	89 f0                	mov    %esi,%eax
}
  801797:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80179a:	5b                   	pop    %ebx
  80179b:	5e                   	pop    %esi
  80179c:	5f                   	pop    %edi
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80179f:	99                   	cltd   
  8017a0:	c1 ea 1b             	shr    $0x1b,%edx
  8017a3:	01 d0                	add    %edx,%eax
  8017a5:	83 e0 1f             	and    $0x1f,%eax
  8017a8:	29 d0                	sub    %edx,%eax
  8017aa:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017b5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8017b8:	83 c6 01             	add    $0x1,%esi
  8017bb:	eb b4                	jmp    801771 <devpipe_read+0x1c>
	return i;
  8017bd:	89 f0                	mov    %esi,%eax
  8017bf:	eb d6                	jmp    801797 <devpipe_read+0x42>
				return 0;
  8017c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c6:	eb cf                	jmp    801797 <devpipe_read+0x42>

008017c8 <pipe>:
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8017d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d3:	50                   	push   %eax
  8017d4:	e8 61 f6 ff ff       	call   800e3a <fd_alloc>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 5b                	js     80183d <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e2:	83 ec 04             	sub    $0x4,%esp
  8017e5:	68 07 04 00 00       	push   $0x407
  8017ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ed:	6a 00                	push   $0x0
  8017ef:	e8 99 f3 ff ff       	call   800b8d <sys_page_alloc>
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 40                	js     80183d <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  8017fd:	83 ec 0c             	sub    $0xc,%esp
  801800:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801803:	50                   	push   %eax
  801804:	e8 31 f6 ff ff       	call   800e3a <fd_alloc>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 1b                	js     80182d <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801812:	83 ec 04             	sub    $0x4,%esp
  801815:	68 07 04 00 00       	push   $0x407
  80181a:	ff 75 f0             	pushl  -0x10(%ebp)
  80181d:	6a 00                	push   $0x0
  80181f:	e8 69 f3 ff ff       	call   800b8d <sys_page_alloc>
  801824:	89 c3                	mov    %eax,%ebx
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	85 c0                	test   %eax,%eax
  80182b:	79 19                	jns    801846 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  80182d:	83 ec 08             	sub    $0x8,%esp
  801830:	ff 75 f4             	pushl  -0xc(%ebp)
  801833:	6a 00                	push   $0x0
  801835:	e8 d8 f3 ff ff       	call   800c12 <sys_page_unmap>
  80183a:	83 c4 10             	add    $0x10,%esp
}
  80183d:	89 d8                	mov    %ebx,%eax
  80183f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    
	va = fd2data(fd0);
  801846:	83 ec 0c             	sub    $0xc,%esp
  801849:	ff 75 f4             	pushl  -0xc(%ebp)
  80184c:	e8 d2 f5 ff ff       	call   800e23 <fd2data>
  801851:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801853:	83 c4 0c             	add    $0xc,%esp
  801856:	68 07 04 00 00       	push   $0x407
  80185b:	50                   	push   %eax
  80185c:	6a 00                	push   $0x0
  80185e:	e8 2a f3 ff ff       	call   800b8d <sys_page_alloc>
  801863:	89 c3                	mov    %eax,%ebx
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	0f 88 8c 00 00 00    	js     8018fc <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801870:	83 ec 0c             	sub    $0xc,%esp
  801873:	ff 75 f0             	pushl  -0x10(%ebp)
  801876:	e8 a8 f5 ff ff       	call   800e23 <fd2data>
  80187b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801882:	50                   	push   %eax
  801883:	6a 00                	push   $0x0
  801885:	56                   	push   %esi
  801886:	6a 00                	push   $0x0
  801888:	e8 43 f3 ff ff       	call   800bd0 <sys_page_map>
  80188d:	89 c3                	mov    %eax,%ebx
  80188f:	83 c4 20             	add    $0x20,%esp
  801892:	85 c0                	test   %eax,%eax
  801894:	78 58                	js     8018ee <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801896:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801899:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80189f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8018ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8018c0:	83 ec 0c             	sub    $0xc,%esp
  8018c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c6:	e8 48 f5 ff ff       	call   800e13 <fd2num>
  8018cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018ce:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018d0:	83 c4 04             	add    $0x4,%esp
  8018d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d6:	e8 38 f5 ff ff       	call   800e13 <fd2num>
  8018db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018de:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018e9:	e9 4f ff ff ff       	jmp    80183d <pipe+0x75>
	sys_page_unmap(0, va);
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	56                   	push   %esi
  8018f2:	6a 00                	push   $0x0
  8018f4:	e8 19 f3 ff ff       	call   800c12 <sys_page_unmap>
  8018f9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8018fc:	83 ec 08             	sub    $0x8,%esp
  8018ff:	ff 75 f0             	pushl  -0x10(%ebp)
  801902:	6a 00                	push   $0x0
  801904:	e8 09 f3 ff ff       	call   800c12 <sys_page_unmap>
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	e9 1c ff ff ff       	jmp    80182d <pipe+0x65>

00801911 <pipeisclosed>:
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801917:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191a:	50                   	push   %eax
  80191b:	ff 75 08             	pushl  0x8(%ebp)
  80191e:	e8 66 f5 ff ff       	call   800e89 <fd_lookup>
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	85 c0                	test   %eax,%eax
  801928:	78 18                	js     801942 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80192a:	83 ec 0c             	sub    $0xc,%esp
  80192d:	ff 75 f4             	pushl  -0xc(%ebp)
  801930:	e8 ee f4 ff ff       	call   800e23 <fd2data>
	return _pipeisclosed(fd, p);
  801935:	89 c2                	mov    %eax,%edx
  801937:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193a:	e8 30 fd ff ff       	call   80166f <_pipeisclosed>
  80193f:	83 c4 10             	add    $0x10,%esp
}
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801954:	68 1a 23 80 00       	push   $0x80231a
  801959:	ff 75 0c             	pushl  0xc(%ebp)
  80195c:	e8 33 ee ff ff       	call   800794 <strcpy>
	return 0;
}
  801961:	b8 00 00 00 00       	mov    $0x0,%eax
  801966:	c9                   	leave  
  801967:	c3                   	ret    

00801968 <devcons_write>:
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	57                   	push   %edi
  80196c:	56                   	push   %esi
  80196d:	53                   	push   %ebx
  80196e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801974:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801979:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80197f:	eb 2f                	jmp    8019b0 <devcons_write+0x48>
		m = n - tot;
  801981:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801984:	29 f3                	sub    %esi,%ebx
  801986:	83 fb 7f             	cmp    $0x7f,%ebx
  801989:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80198e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801991:	83 ec 04             	sub    $0x4,%esp
  801994:	53                   	push   %ebx
  801995:	89 f0                	mov    %esi,%eax
  801997:	03 45 0c             	add    0xc(%ebp),%eax
  80199a:	50                   	push   %eax
  80199b:	57                   	push   %edi
  80199c:	e8 81 ef ff ff       	call   800922 <memmove>
		sys_cputs(buf, m);
  8019a1:	83 c4 08             	add    $0x8,%esp
  8019a4:	53                   	push   %ebx
  8019a5:	57                   	push   %edi
  8019a6:	e8 26 f1 ff ff       	call   800ad1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019ab:	01 de                	add    %ebx,%esi
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019b3:	72 cc                	jb     801981 <devcons_write+0x19>
}
  8019b5:	89 f0                	mov    %esi,%eax
  8019b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5f                   	pop    %edi
  8019bd:	5d                   	pop    %ebp
  8019be:	c3                   	ret    

008019bf <devcons_read>:
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8019ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019ce:	75 07                	jne    8019d7 <devcons_read+0x18>
}
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    
		sys_yield();
  8019d2:	e8 97 f1 ff ff       	call   800b6e <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8019d7:	e8 13 f1 ff ff       	call   800aef <sys_cgetc>
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	74 f2                	je     8019d2 <devcons_read+0x13>
	if (c < 0)
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	78 ec                	js     8019d0 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  8019e4:	83 f8 04             	cmp    $0x4,%eax
  8019e7:	74 0c                	je     8019f5 <devcons_read+0x36>
	*(char*)vbuf = c;
  8019e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ec:	88 02                	mov    %al,(%edx)
	return 1;
  8019ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f3:	eb db                	jmp    8019d0 <devcons_read+0x11>
		return 0;
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fa:	eb d4                	jmp    8019d0 <devcons_read+0x11>

008019fc <cputchar>:
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a02:	8b 45 08             	mov    0x8(%ebp),%eax
  801a05:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a08:	6a 01                	push   $0x1
  801a0a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a0d:	50                   	push   %eax
  801a0e:	e8 be f0 ff ff       	call   800ad1 <sys_cputs>
}
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <getchar>:
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a1e:	6a 01                	push   $0x1
  801a20:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a23:	50                   	push   %eax
  801a24:	6a 00                	push   $0x0
  801a26:	e8 cf f6 ff ff       	call   8010fa <read>
	if (r < 0)
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 08                	js     801a3a <getchar+0x22>
	if (r < 1)
  801a32:	85 c0                	test   %eax,%eax
  801a34:	7e 06                	jle    801a3c <getchar+0x24>
	return c;
  801a36:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    
		return -E_EOF;
  801a3c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a41:	eb f7                	jmp    801a3a <getchar+0x22>

00801a43 <iscons>:
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4c:	50                   	push   %eax
  801a4d:	ff 75 08             	pushl  0x8(%ebp)
  801a50:	e8 34 f4 ff ff       	call   800e89 <fd_lookup>
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 11                	js     801a6d <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a65:	39 10                	cmp    %edx,(%eax)
  801a67:	0f 94 c0             	sete   %al
  801a6a:	0f b6 c0             	movzbl %al,%eax
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <opencons>:
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801a75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a78:	50                   	push   %eax
  801a79:	e8 bc f3 ff ff       	call   800e3a <fd_alloc>
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	85 c0                	test   %eax,%eax
  801a83:	78 3a                	js     801abf <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a85:	83 ec 04             	sub    $0x4,%esp
  801a88:	68 07 04 00 00       	push   $0x407
  801a8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a90:	6a 00                	push   $0x0
  801a92:	e8 f6 f0 ff ff       	call   800b8d <sys_page_alloc>
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	78 21                	js     801abf <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aa7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aac:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ab3:	83 ec 0c             	sub    $0xc,%esp
  801ab6:	50                   	push   %eax
  801ab7:	e8 57 f3 ff ff       	call   800e13 <fd2num>
  801abc:	83 c4 10             	add    $0x10,%esp
}
  801abf:	c9                   	leave  
  801ac0:	c3                   	ret    

00801ac1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	56                   	push   %esi
  801ac5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ac6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ac9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801acf:	e8 7b f0 ff ff       	call   800b4f <sys_getenvid>
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	ff 75 0c             	pushl  0xc(%ebp)
  801ada:	ff 75 08             	pushl  0x8(%ebp)
  801add:	56                   	push   %esi
  801ade:	50                   	push   %eax
  801adf:	68 28 23 80 00       	push   $0x802328
  801ae4:	e8 8c e6 ff ff       	call   800175 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ae9:	83 c4 18             	add    $0x18,%esp
  801aec:	53                   	push   %ebx
  801aed:	ff 75 10             	pushl  0x10(%ebp)
  801af0:	e8 2f e6 ff ff       	call   800124 <vcprintf>
	cprintf("\n");
  801af5:	c7 04 24 13 23 80 00 	movl   $0x802313,(%esp)
  801afc:	e8 74 e6 ff ff       	call   800175 <cprintf>
  801b01:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b04:	cc                   	int3   
  801b05:	eb fd                	jmp    801b04 <_panic+0x43>

00801b07 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	56                   	push   %esi
  801b0b:	53                   	push   %ebx
  801b0c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801b15:	85 f6                	test   %esi,%esi
  801b17:	74 06                	je     801b1f <ipc_recv+0x18>
  801b19:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801b1f:	85 db                	test   %ebx,%ebx
  801b21:	74 06                	je     801b29 <ipc_recv+0x22>
  801b23:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b30:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801b33:	83 ec 0c             	sub    $0xc,%esp
  801b36:	50                   	push   %eax
  801b37:	e8 01 f2 ff ff       	call   800d3d <sys_ipc_recv>
	if (ret) return ret;
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	75 24                	jne    801b67 <ipc_recv+0x60>
	if (from_env_store)
  801b43:	85 f6                	test   %esi,%esi
  801b45:	74 0a                	je     801b51 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801b47:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4c:	8b 40 74             	mov    0x74(%eax),%eax
  801b4f:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801b51:	85 db                	test   %ebx,%ebx
  801b53:	74 0a                	je     801b5f <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801b55:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5a:	8b 40 78             	mov    0x78(%eax),%eax
  801b5d:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801b5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b64:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6a:	5b                   	pop    %ebx
  801b6b:	5e                   	pop    %esi
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	57                   	push   %edi
  801b72:	56                   	push   %esi
  801b73:	53                   	push   %ebx
  801b74:	83 ec 0c             	sub    $0xc,%esp
  801b77:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801b80:	85 db                	test   %ebx,%ebx
  801b82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b87:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b8a:	ff 75 14             	pushl  0x14(%ebp)
  801b8d:	53                   	push   %ebx
  801b8e:	56                   	push   %esi
  801b8f:	57                   	push   %edi
  801b90:	e8 85 f1 ff ff       	call   800d1a <sys_ipc_try_send>
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	74 1e                	je     801bba <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801b9c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b9f:	75 07                	jne    801ba8 <ipc_send+0x3a>
		sys_yield();
  801ba1:	e8 c8 ef ff ff       	call   800b6e <sys_yield>
  801ba6:	eb e2                	jmp    801b8a <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ba8:	50                   	push   %eax
  801ba9:	68 4c 23 80 00       	push   $0x80234c
  801bae:	6a 36                	push   $0x36
  801bb0:	68 63 23 80 00       	push   $0x802363
  801bb5:	e8 07 ff ff ff       	call   801ac1 <_panic>
	}
}
  801bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5f                   	pop    %edi
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    

00801bc2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bc8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bcd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bd0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bd6:	8b 52 50             	mov    0x50(%edx),%edx
  801bd9:	39 ca                	cmp    %ecx,%edx
  801bdb:	74 11                	je     801bee <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801bdd:	83 c0 01             	add    $0x1,%eax
  801be0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801be5:	75 e6                	jne    801bcd <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801be7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bec:	eb 0b                	jmp    801bf9 <ipc_find_env+0x37>
			return envs[i].env_id;
  801bee:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bf1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bf6:	8b 40 48             	mov    0x48(%eax),%eax
}
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c01:	89 d0                	mov    %edx,%eax
  801c03:	c1 e8 16             	shr    $0x16,%eax
  801c06:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c0d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801c12:	f6 c1 01             	test   $0x1,%cl
  801c15:	74 1d                	je     801c34 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801c17:	c1 ea 0c             	shr    $0xc,%edx
  801c1a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c21:	f6 c2 01             	test   $0x1,%dl
  801c24:	74 0e                	je     801c34 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c26:	c1 ea 0c             	shr    $0xc,%edx
  801c29:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c30:	ef 
  801c31:	0f b7 c0             	movzwl %ax,%eax
}
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    
  801c36:	66 90                	xchg   %ax,%ax
  801c38:	66 90                	xchg   %ax,%ax
  801c3a:	66 90                	xchg   %ax,%ax
  801c3c:	66 90                	xchg   %ax,%ax
  801c3e:	66 90                	xchg   %ax,%ax

00801c40 <__udivdi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 1c             	sub    $0x1c,%esp
  801c47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c4b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c53:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c57:	85 d2                	test   %edx,%edx
  801c59:	75 35                	jne    801c90 <__udivdi3+0x50>
  801c5b:	39 f3                	cmp    %esi,%ebx
  801c5d:	0f 87 bd 00 00 00    	ja     801d20 <__udivdi3+0xe0>
  801c63:	85 db                	test   %ebx,%ebx
  801c65:	89 d9                	mov    %ebx,%ecx
  801c67:	75 0b                	jne    801c74 <__udivdi3+0x34>
  801c69:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6e:	31 d2                	xor    %edx,%edx
  801c70:	f7 f3                	div    %ebx
  801c72:	89 c1                	mov    %eax,%ecx
  801c74:	31 d2                	xor    %edx,%edx
  801c76:	89 f0                	mov    %esi,%eax
  801c78:	f7 f1                	div    %ecx
  801c7a:	89 c6                	mov    %eax,%esi
  801c7c:	89 e8                	mov    %ebp,%eax
  801c7e:	89 f7                	mov    %esi,%edi
  801c80:	f7 f1                	div    %ecx
  801c82:	89 fa                	mov    %edi,%edx
  801c84:	83 c4 1c             	add    $0x1c,%esp
  801c87:	5b                   	pop    %ebx
  801c88:	5e                   	pop    %esi
  801c89:	5f                   	pop    %edi
  801c8a:	5d                   	pop    %ebp
  801c8b:	c3                   	ret    
  801c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c90:	39 f2                	cmp    %esi,%edx
  801c92:	77 7c                	ja     801d10 <__udivdi3+0xd0>
  801c94:	0f bd fa             	bsr    %edx,%edi
  801c97:	83 f7 1f             	xor    $0x1f,%edi
  801c9a:	0f 84 98 00 00 00    	je     801d38 <__udivdi3+0xf8>
  801ca0:	89 f9                	mov    %edi,%ecx
  801ca2:	b8 20 00 00 00       	mov    $0x20,%eax
  801ca7:	29 f8                	sub    %edi,%eax
  801ca9:	d3 e2                	shl    %cl,%edx
  801cab:	89 54 24 08          	mov    %edx,0x8(%esp)
  801caf:	89 c1                	mov    %eax,%ecx
  801cb1:	89 da                	mov    %ebx,%edx
  801cb3:	d3 ea                	shr    %cl,%edx
  801cb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801cb9:	09 d1                	or     %edx,%ecx
  801cbb:	89 f2                	mov    %esi,%edx
  801cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cc1:	89 f9                	mov    %edi,%ecx
  801cc3:	d3 e3                	shl    %cl,%ebx
  801cc5:	89 c1                	mov    %eax,%ecx
  801cc7:	d3 ea                	shr    %cl,%edx
  801cc9:	89 f9                	mov    %edi,%ecx
  801ccb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801ccf:	d3 e6                	shl    %cl,%esi
  801cd1:	89 eb                	mov    %ebp,%ebx
  801cd3:	89 c1                	mov    %eax,%ecx
  801cd5:	d3 eb                	shr    %cl,%ebx
  801cd7:	09 de                	or     %ebx,%esi
  801cd9:	89 f0                	mov    %esi,%eax
  801cdb:	f7 74 24 08          	divl   0x8(%esp)
  801cdf:	89 d6                	mov    %edx,%esi
  801ce1:	89 c3                	mov    %eax,%ebx
  801ce3:	f7 64 24 0c          	mull   0xc(%esp)
  801ce7:	39 d6                	cmp    %edx,%esi
  801ce9:	72 0c                	jb     801cf7 <__udivdi3+0xb7>
  801ceb:	89 f9                	mov    %edi,%ecx
  801ced:	d3 e5                	shl    %cl,%ebp
  801cef:	39 c5                	cmp    %eax,%ebp
  801cf1:	73 5d                	jae    801d50 <__udivdi3+0x110>
  801cf3:	39 d6                	cmp    %edx,%esi
  801cf5:	75 59                	jne    801d50 <__udivdi3+0x110>
  801cf7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801cfa:	31 ff                	xor    %edi,%edi
  801cfc:	89 fa                	mov    %edi,%edx
  801cfe:	83 c4 1c             	add    $0x1c,%esp
  801d01:	5b                   	pop    %ebx
  801d02:	5e                   	pop    %esi
  801d03:	5f                   	pop    %edi
  801d04:	5d                   	pop    %ebp
  801d05:	c3                   	ret    
  801d06:	8d 76 00             	lea    0x0(%esi),%esi
  801d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d10:	31 ff                	xor    %edi,%edi
  801d12:	31 c0                	xor    %eax,%eax
  801d14:	89 fa                	mov    %edi,%edx
  801d16:	83 c4 1c             	add    $0x1c,%esp
  801d19:	5b                   	pop    %ebx
  801d1a:	5e                   	pop    %esi
  801d1b:	5f                   	pop    %edi
  801d1c:	5d                   	pop    %ebp
  801d1d:	c3                   	ret    
  801d1e:	66 90                	xchg   %ax,%ax
  801d20:	31 ff                	xor    %edi,%edi
  801d22:	89 e8                	mov    %ebp,%eax
  801d24:	89 f2                	mov    %esi,%edx
  801d26:	f7 f3                	div    %ebx
  801d28:	89 fa                	mov    %edi,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	72 06                	jb     801d42 <__udivdi3+0x102>
  801d3c:	31 c0                	xor    %eax,%eax
  801d3e:	39 eb                	cmp    %ebp,%ebx
  801d40:	77 d2                	ja     801d14 <__udivdi3+0xd4>
  801d42:	b8 01 00 00 00       	mov    $0x1,%eax
  801d47:	eb cb                	jmp    801d14 <__udivdi3+0xd4>
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	89 d8                	mov    %ebx,%eax
  801d52:	31 ff                	xor    %edi,%edi
  801d54:	eb be                	jmp    801d14 <__udivdi3+0xd4>
  801d56:	66 90                	xchg   %ax,%ax
  801d58:	66 90                	xchg   %ax,%ax
  801d5a:	66 90                	xchg   %ax,%ax
  801d5c:	66 90                	xchg   %ax,%ax
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <__umoddi3>:
  801d60:	55                   	push   %ebp
  801d61:	57                   	push   %edi
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	83 ec 1c             	sub    $0x1c,%esp
  801d67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801d6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d77:	85 ed                	test   %ebp,%ebp
  801d79:	89 f0                	mov    %esi,%eax
  801d7b:	89 da                	mov    %ebx,%edx
  801d7d:	75 19                	jne    801d98 <__umoddi3+0x38>
  801d7f:	39 df                	cmp    %ebx,%edi
  801d81:	0f 86 b1 00 00 00    	jbe    801e38 <__umoddi3+0xd8>
  801d87:	f7 f7                	div    %edi
  801d89:	89 d0                	mov    %edx,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	83 c4 1c             	add    $0x1c,%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    
  801d95:	8d 76 00             	lea    0x0(%esi),%esi
  801d98:	39 dd                	cmp    %ebx,%ebp
  801d9a:	77 f1                	ja     801d8d <__umoddi3+0x2d>
  801d9c:	0f bd cd             	bsr    %ebp,%ecx
  801d9f:	83 f1 1f             	xor    $0x1f,%ecx
  801da2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801da6:	0f 84 b4 00 00 00    	je     801e60 <__umoddi3+0x100>
  801dac:	b8 20 00 00 00       	mov    $0x20,%eax
  801db1:	89 c2                	mov    %eax,%edx
  801db3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801db7:	29 c2                	sub    %eax,%edx
  801db9:	89 c1                	mov    %eax,%ecx
  801dbb:	89 f8                	mov    %edi,%eax
  801dbd:	d3 e5                	shl    %cl,%ebp
  801dbf:	89 d1                	mov    %edx,%ecx
  801dc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801dc5:	d3 e8                	shr    %cl,%eax
  801dc7:	09 c5                	or     %eax,%ebp
  801dc9:	8b 44 24 04          	mov    0x4(%esp),%eax
  801dcd:	89 c1                	mov    %eax,%ecx
  801dcf:	d3 e7                	shl    %cl,%edi
  801dd1:	89 d1                	mov    %edx,%ecx
  801dd3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801dd7:	89 df                	mov    %ebx,%edi
  801dd9:	d3 ef                	shr    %cl,%edi
  801ddb:	89 c1                	mov    %eax,%ecx
  801ddd:	89 f0                	mov    %esi,%eax
  801ddf:	d3 e3                	shl    %cl,%ebx
  801de1:	89 d1                	mov    %edx,%ecx
  801de3:	89 fa                	mov    %edi,%edx
  801de5:	d3 e8                	shr    %cl,%eax
  801de7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801dec:	09 d8                	or     %ebx,%eax
  801dee:	f7 f5                	div    %ebp
  801df0:	d3 e6                	shl    %cl,%esi
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	f7 64 24 08          	mull   0x8(%esp)
  801df8:	39 d1                	cmp    %edx,%ecx
  801dfa:	89 c3                	mov    %eax,%ebx
  801dfc:	89 d7                	mov    %edx,%edi
  801dfe:	72 06                	jb     801e06 <__umoddi3+0xa6>
  801e00:	75 0e                	jne    801e10 <__umoddi3+0xb0>
  801e02:	39 c6                	cmp    %eax,%esi
  801e04:	73 0a                	jae    801e10 <__umoddi3+0xb0>
  801e06:	2b 44 24 08          	sub    0x8(%esp),%eax
  801e0a:	19 ea                	sbb    %ebp,%edx
  801e0c:	89 d7                	mov    %edx,%edi
  801e0e:	89 c3                	mov    %eax,%ebx
  801e10:	89 ca                	mov    %ecx,%edx
  801e12:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801e17:	29 de                	sub    %ebx,%esi
  801e19:	19 fa                	sbb    %edi,%edx
  801e1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801e1f:	89 d0                	mov    %edx,%eax
  801e21:	d3 e0                	shl    %cl,%eax
  801e23:	89 d9                	mov    %ebx,%ecx
  801e25:	d3 ee                	shr    %cl,%esi
  801e27:	d3 ea                	shr    %cl,%edx
  801e29:	09 f0                	or     %esi,%eax
  801e2b:	83 c4 1c             	add    $0x1c,%esp
  801e2e:	5b                   	pop    %ebx
  801e2f:	5e                   	pop    %esi
  801e30:	5f                   	pop    %edi
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    
  801e33:	90                   	nop
  801e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e38:	85 ff                	test   %edi,%edi
  801e3a:	89 f9                	mov    %edi,%ecx
  801e3c:	75 0b                	jne    801e49 <__umoddi3+0xe9>
  801e3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e43:	31 d2                	xor    %edx,%edx
  801e45:	f7 f7                	div    %edi
  801e47:	89 c1                	mov    %eax,%ecx
  801e49:	89 d8                	mov    %ebx,%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	f7 f1                	div    %ecx
  801e4f:	89 f0                	mov    %esi,%eax
  801e51:	f7 f1                	div    %ecx
  801e53:	e9 31 ff ff ff       	jmp    801d89 <__umoddi3+0x29>
  801e58:	90                   	nop
  801e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e60:	39 dd                	cmp    %ebx,%ebp
  801e62:	72 08                	jb     801e6c <__umoddi3+0x10c>
  801e64:	39 f7                	cmp    %esi,%edi
  801e66:	0f 87 21 ff ff ff    	ja     801d8d <__umoddi3+0x2d>
  801e6c:	89 da                	mov    %ebx,%edx
  801e6e:	89 f0                	mov    %esi,%eax
  801e70:	29 f8                	sub    %edi,%eax
  801e72:	19 ea                	sbb    %ebp,%edx
  801e74:	e9 14 ff ff ff       	jmp    801d8d <__umoddi3+0x2d>
