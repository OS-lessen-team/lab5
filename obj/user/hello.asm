
obj/user/hello.debug：     文件格式 elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 c0 1d 80 00       	push   $0x801dc0
  80003e:	e8 10 01 00 00       	call   800153 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ce 1d 80 00       	push   $0x801dce
  800054:	e8 fa 00 00 00       	call   800153 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800069:	e8 bf 0a 00 00       	call   800b2d <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 83 0e 00 00       	call   800f32 <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 33 0a 00 00       	call   800aec <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	74 09                	je     8000e6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000dd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e4:	c9                   	leave  
  8000e5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e6:	83 ec 08             	sub    $0x8,%esp
  8000e9:	68 ff 00 00 00       	push   $0xff
  8000ee:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f1:	50                   	push   %eax
  8000f2:	e8 b8 09 00 00       	call   800aaf <sys_cputs>
		b->idx = 0;
  8000f7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	eb db                	jmp    8000dd <putch+0x1f>

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	ff 75 0c             	pushl  0xc(%ebp)
  800122:	ff 75 08             	pushl  0x8(%ebp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	68 be 00 80 00       	push   $0x8000be
  800131:	e8 1a 01 00 00       	call   800250 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	83 c4 08             	add    $0x8,%esp
  800139:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	e8 64 09 00 00       	call   800aaf <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	e8 9d ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800180:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800183:	bb 00 00 00 00       	mov    $0x0,%ebx
  800188:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018e:	39 d3                	cmp    %edx,%ebx
  800190:	72 05                	jb     800197 <printnum+0x30>
  800192:	39 45 10             	cmp    %eax,0x10(%ebp)
  800195:	77 7a                	ja     800211 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	ff 75 18             	pushl  0x18(%ebp)
  80019d:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a3:	53                   	push   %ebx
  8001a4:	ff 75 10             	pushl  0x10(%ebp)
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b6:	e8 c5 19 00 00       	call   801b80 <__udivdi3>
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	89 f2                	mov    %esi,%edx
  8001c2:	89 f8                	mov    %edi,%eax
  8001c4:	e8 9e ff ff ff       	call   800167 <printnum>
  8001c9:	83 c4 20             	add    $0x20,%esp
  8001cc:	eb 13                	jmp    8001e1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff d7                	call   *%edi
  8001d7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001da:	83 eb 01             	sub    $0x1,%ebx
  8001dd:	85 db                	test   %ebx,%ebx
  8001df:	7f ed                	jg     8001ce <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	56                   	push   %esi
  8001e5:	83 ec 04             	sub    $0x4,%esp
  8001e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f4:	e8 a7 1a 00 00       	call   801ca0 <__umoddi3>
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	0f be 80 ef 1d 80 00 	movsbl 0x801def(%eax),%eax
  800203:	50                   	push   %eax
  800204:	ff d7                	call   *%edi
}
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5e                   	pop    %esi
  80020e:	5f                   	pop    %edi
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    
  800211:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800214:	eb c4                	jmp    8001da <printnum+0x73>

00800216 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800220:	8b 10                	mov    (%eax),%edx
  800222:	3b 50 04             	cmp    0x4(%eax),%edx
  800225:	73 0a                	jae    800231 <sprintputch+0x1b>
		*b->buf++ = ch;
  800227:	8d 4a 01             	lea    0x1(%edx),%ecx
  80022a:	89 08                	mov    %ecx,(%eax)
  80022c:	8b 45 08             	mov    0x8(%ebp),%eax
  80022f:	88 02                	mov    %al,(%edx)
}
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <printfmt>:
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800239:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80023c:	50                   	push   %eax
  80023d:	ff 75 10             	pushl  0x10(%ebp)
  800240:	ff 75 0c             	pushl  0xc(%ebp)
  800243:	ff 75 08             	pushl  0x8(%ebp)
  800246:	e8 05 00 00 00       	call   800250 <vprintfmt>
}
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <vprintfmt>:
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 2c             	sub    $0x2c,%esp
  800259:	8b 75 08             	mov    0x8(%ebp),%esi
  80025c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80025f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800262:	e9 c1 03 00 00       	jmp    800628 <vprintfmt+0x3d8>
		padc = ' ';
  800267:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80026b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800272:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800279:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800280:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800285:	8d 47 01             	lea    0x1(%edi),%eax
  800288:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028b:	0f b6 17             	movzbl (%edi),%edx
  80028e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800291:	3c 55                	cmp    $0x55,%al
  800293:	0f 87 12 04 00 00    	ja     8006ab <vprintfmt+0x45b>
  800299:	0f b6 c0             	movzbl %al,%eax
  80029c:	ff 24 85 40 1f 80 00 	jmp    *0x801f40(,%eax,4)
  8002a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002a6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002aa:	eb d9                	jmp    800285 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002af:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002b3:	eb d0                	jmp    800285 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002b5:	0f b6 d2             	movzbl %dl,%edx
  8002b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002c3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002c6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002ca:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002cd:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d0:	83 f9 09             	cmp    $0x9,%ecx
  8002d3:	77 55                	ja     80032a <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002d5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002d8:	eb e9                	jmp    8002c3 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002da:	8b 45 14             	mov    0x14(%ebp),%eax
  8002dd:	8b 00                	mov    (%eax),%eax
  8002df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e5:	8d 40 04             	lea    0x4(%eax),%eax
  8002e8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002f2:	79 91                	jns    800285 <vprintfmt+0x35>
				width = precision, precision = -1;
  8002f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800301:	eb 82                	jmp    800285 <vprintfmt+0x35>
  800303:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800306:	85 c0                	test   %eax,%eax
  800308:	ba 00 00 00 00       	mov    $0x0,%edx
  80030d:	0f 49 d0             	cmovns %eax,%edx
  800310:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800316:	e9 6a ff ff ff       	jmp    800285 <vprintfmt+0x35>
  80031b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80031e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800325:	e9 5b ff ff ff       	jmp    800285 <vprintfmt+0x35>
  80032a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80032d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800330:	eb bc                	jmp    8002ee <vprintfmt+0x9e>
			lflag++;
  800332:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800338:	e9 48 ff ff ff       	jmp    800285 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80033d:	8b 45 14             	mov    0x14(%ebp),%eax
  800340:	8d 78 04             	lea    0x4(%eax),%edi
  800343:	83 ec 08             	sub    $0x8,%esp
  800346:	53                   	push   %ebx
  800347:	ff 30                	pushl  (%eax)
  800349:	ff d6                	call   *%esi
			break;
  80034b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80034e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800351:	e9 cf 02 00 00       	jmp    800625 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8d 78 04             	lea    0x4(%eax),%edi
  80035c:	8b 00                	mov    (%eax),%eax
  80035e:	99                   	cltd   
  80035f:	31 d0                	xor    %edx,%eax
  800361:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800363:	83 f8 0f             	cmp    $0xf,%eax
  800366:	7f 23                	jg     80038b <vprintfmt+0x13b>
  800368:	8b 14 85 a0 20 80 00 	mov    0x8020a0(,%eax,4),%edx
  80036f:	85 d2                	test   %edx,%edx
  800371:	74 18                	je     80038b <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800373:	52                   	push   %edx
  800374:	68 d1 21 80 00       	push   $0x8021d1
  800379:	53                   	push   %ebx
  80037a:	56                   	push   %esi
  80037b:	e8 b3 fe ff ff       	call   800233 <printfmt>
  800380:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800383:	89 7d 14             	mov    %edi,0x14(%ebp)
  800386:	e9 9a 02 00 00       	jmp    800625 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80038b:	50                   	push   %eax
  80038c:	68 07 1e 80 00       	push   $0x801e07
  800391:	53                   	push   %ebx
  800392:	56                   	push   %esi
  800393:	e8 9b fe ff ff       	call   800233 <printfmt>
  800398:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80039e:	e9 82 02 00 00       	jmp    800625 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a6:	83 c0 04             	add    $0x4,%eax
  8003a9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8003af:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003b1:	85 ff                	test   %edi,%edi
  8003b3:	b8 00 1e 80 00       	mov    $0x801e00,%eax
  8003b8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003bf:	0f 8e bd 00 00 00    	jle    800482 <vprintfmt+0x232>
  8003c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003c9:	75 0e                	jne    8003d9 <vprintfmt+0x189>
  8003cb:	89 75 08             	mov    %esi,0x8(%ebp)
  8003ce:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003d4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003d7:	eb 6d                	jmp    800446 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	ff 75 d0             	pushl  -0x30(%ebp)
  8003df:	57                   	push   %edi
  8003e0:	e8 6e 03 00 00       	call   800753 <strnlen>
  8003e5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003e8:	29 c1                	sub    %eax,%ecx
  8003ea:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003ed:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003f0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003fa:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003fc:	eb 0f                	jmp    80040d <vprintfmt+0x1bd>
					putch(padc, putdat);
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	53                   	push   %ebx
  800402:	ff 75 e0             	pushl  -0x20(%ebp)
  800405:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800407:	83 ef 01             	sub    $0x1,%edi
  80040a:	83 c4 10             	add    $0x10,%esp
  80040d:	85 ff                	test   %edi,%edi
  80040f:	7f ed                	jg     8003fe <vprintfmt+0x1ae>
  800411:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800414:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800417:	85 c9                	test   %ecx,%ecx
  800419:	b8 00 00 00 00       	mov    $0x0,%eax
  80041e:	0f 49 c1             	cmovns %ecx,%eax
  800421:	29 c1                	sub    %eax,%ecx
  800423:	89 75 08             	mov    %esi,0x8(%ebp)
  800426:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800429:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80042c:	89 cb                	mov    %ecx,%ebx
  80042e:	eb 16                	jmp    800446 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800430:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800434:	75 31                	jne    800467 <vprintfmt+0x217>
					putch(ch, putdat);
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	ff 75 0c             	pushl  0xc(%ebp)
  80043c:	50                   	push   %eax
  80043d:	ff 55 08             	call   *0x8(%ebp)
  800440:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800443:	83 eb 01             	sub    $0x1,%ebx
  800446:	83 c7 01             	add    $0x1,%edi
  800449:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80044d:	0f be c2             	movsbl %dl,%eax
  800450:	85 c0                	test   %eax,%eax
  800452:	74 59                	je     8004ad <vprintfmt+0x25d>
  800454:	85 f6                	test   %esi,%esi
  800456:	78 d8                	js     800430 <vprintfmt+0x1e0>
  800458:	83 ee 01             	sub    $0x1,%esi
  80045b:	79 d3                	jns    800430 <vprintfmt+0x1e0>
  80045d:	89 df                	mov    %ebx,%edi
  80045f:	8b 75 08             	mov    0x8(%ebp),%esi
  800462:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800465:	eb 37                	jmp    80049e <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800467:	0f be d2             	movsbl %dl,%edx
  80046a:	83 ea 20             	sub    $0x20,%edx
  80046d:	83 fa 5e             	cmp    $0x5e,%edx
  800470:	76 c4                	jbe    800436 <vprintfmt+0x1e6>
					putch('?', putdat);
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	ff 75 0c             	pushl  0xc(%ebp)
  800478:	6a 3f                	push   $0x3f
  80047a:	ff 55 08             	call   *0x8(%ebp)
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	eb c1                	jmp    800443 <vprintfmt+0x1f3>
  800482:	89 75 08             	mov    %esi,0x8(%ebp)
  800485:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800488:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80048e:	eb b6                	jmp    800446 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	53                   	push   %ebx
  800494:	6a 20                	push   $0x20
  800496:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800498:	83 ef 01             	sub    $0x1,%edi
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	85 ff                	test   %edi,%edi
  8004a0:	7f ee                	jg     800490 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a5:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a8:	e9 78 01 00 00       	jmp    800625 <vprintfmt+0x3d5>
  8004ad:	89 df                	mov    %ebx,%edi
  8004af:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b5:	eb e7                	jmp    80049e <vprintfmt+0x24e>
	if (lflag >= 2)
  8004b7:	83 f9 01             	cmp    $0x1,%ecx
  8004ba:	7e 3f                	jle    8004fb <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8b 50 04             	mov    0x4(%eax),%edx
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cd:	8d 40 08             	lea    0x8(%eax),%eax
  8004d0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004d3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d7:	79 5c                	jns    800535 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	53                   	push   %ebx
  8004dd:	6a 2d                	push   $0x2d
  8004df:	ff d6                	call   *%esi
				num = -(long long) num;
  8004e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004e7:	f7 da                	neg    %edx
  8004e9:	83 d1 00             	adc    $0x0,%ecx
  8004ec:	f7 d9                	neg    %ecx
  8004ee:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004f6:	e9 10 01 00 00       	jmp    80060b <vprintfmt+0x3bb>
	else if (lflag)
  8004fb:	85 c9                	test   %ecx,%ecx
  8004fd:	75 1b                	jne    80051a <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800507:	89 c1                	mov    %eax,%ecx
  800509:	c1 f9 1f             	sar    $0x1f,%ecx
  80050c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8d 40 04             	lea    0x4(%eax),%eax
  800515:	89 45 14             	mov    %eax,0x14(%ebp)
  800518:	eb b9                	jmp    8004d3 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800522:	89 c1                	mov    %eax,%ecx
  800524:	c1 f9 1f             	sar    $0x1f,%ecx
  800527:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8d 40 04             	lea    0x4(%eax),%eax
  800530:	89 45 14             	mov    %eax,0x14(%ebp)
  800533:	eb 9e                	jmp    8004d3 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800535:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800538:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80053b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800540:	e9 c6 00 00 00       	jmp    80060b <vprintfmt+0x3bb>
	if (lflag >= 2)
  800545:	83 f9 01             	cmp    $0x1,%ecx
  800548:	7e 18                	jle    800562 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8b 10                	mov    (%eax),%edx
  80054f:	8b 48 04             	mov    0x4(%eax),%ecx
  800552:	8d 40 08             	lea    0x8(%eax),%eax
  800555:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800558:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055d:	e9 a9 00 00 00       	jmp    80060b <vprintfmt+0x3bb>
	else if (lflag)
  800562:	85 c9                	test   %ecx,%ecx
  800564:	75 1a                	jne    800580 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 10                	mov    (%eax),%edx
  80056b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800576:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057b:	e9 8b 00 00 00       	jmp    80060b <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8b 10                	mov    (%eax),%edx
  800585:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058a:	8d 40 04             	lea    0x4(%eax),%eax
  80058d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800590:	b8 0a 00 00 00       	mov    $0xa,%eax
  800595:	eb 74                	jmp    80060b <vprintfmt+0x3bb>
	if (lflag >= 2)
  800597:	83 f9 01             	cmp    $0x1,%ecx
  80059a:	7e 15                	jle    8005b1 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 10                	mov    (%eax),%edx
  8005a1:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a4:	8d 40 08             	lea    0x8(%eax),%eax
  8005a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8005af:	eb 5a                	jmp    80060b <vprintfmt+0x3bb>
	else if (lflag)
  8005b1:	85 c9                	test   %ecx,%ecx
  8005b3:	75 17                	jne    8005cc <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bf:	8d 40 04             	lea    0x4(%eax),%eax
  8005c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005c5:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ca:	eb 3f                	jmp    80060b <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8b 10                	mov    (%eax),%edx
  8005d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d6:	8d 40 04             	lea    0x4(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8005e1:	eb 28                	jmp    80060b <vprintfmt+0x3bb>
			putch('0', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 30                	push   $0x30
  8005e9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005eb:	83 c4 08             	add    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	6a 78                	push   $0x78
  8005f1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005fd:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800600:	8d 40 04             	lea    0x4(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800606:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800612:	57                   	push   %edi
  800613:	ff 75 e0             	pushl  -0x20(%ebp)
  800616:	50                   	push   %eax
  800617:	51                   	push   %ecx
  800618:	52                   	push   %edx
  800619:	89 da                	mov    %ebx,%edx
  80061b:	89 f0                	mov    %esi,%eax
  80061d:	e8 45 fb ff ff       	call   800167 <printnum>
			break;
  800622:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800625:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800628:	83 c7 01             	add    $0x1,%edi
  80062b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062f:	83 f8 25             	cmp    $0x25,%eax
  800632:	0f 84 2f fc ff ff    	je     800267 <vprintfmt+0x17>
			if (ch == '\0')
  800638:	85 c0                	test   %eax,%eax
  80063a:	0f 84 8b 00 00 00    	je     8006cb <vprintfmt+0x47b>
			putch(ch, putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	50                   	push   %eax
  800645:	ff d6                	call   *%esi
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	eb dc                	jmp    800628 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80064c:	83 f9 01             	cmp    $0x1,%ecx
  80064f:	7e 15                	jle    800666 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	8b 48 04             	mov    0x4(%eax),%ecx
  800659:	8d 40 08             	lea    0x8(%eax),%eax
  80065c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065f:	b8 10 00 00 00       	mov    $0x10,%eax
  800664:	eb a5                	jmp    80060b <vprintfmt+0x3bb>
	else if (lflag)
  800666:	85 c9                	test   %ecx,%ecx
  800668:	75 17                	jne    800681 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800674:	8d 40 04             	lea    0x4(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067a:	b8 10 00 00 00       	mov    $0x10,%eax
  80067f:	eb 8a                	jmp    80060b <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 10                	mov    (%eax),%edx
  800686:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068b:	8d 40 04             	lea    0x4(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800691:	b8 10 00 00 00       	mov    $0x10,%eax
  800696:	e9 70 ff ff ff       	jmp    80060b <vprintfmt+0x3bb>
			putch(ch, putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 25                	push   $0x25
  8006a1:	ff d6                	call   *%esi
			break;
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	e9 7a ff ff ff       	jmp    800625 <vprintfmt+0x3d5>
			putch('%', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 25                	push   $0x25
  8006b1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	89 f8                	mov    %edi,%eax
  8006b8:	eb 03                	jmp    8006bd <vprintfmt+0x46d>
  8006ba:	83 e8 01             	sub    $0x1,%eax
  8006bd:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006c1:	75 f7                	jne    8006ba <vprintfmt+0x46a>
  8006c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c6:	e9 5a ff ff ff       	jmp    800625 <vprintfmt+0x3d5>
}
  8006cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ce:	5b                   	pop    %ebx
  8006cf:	5e                   	pop    %esi
  8006d0:	5f                   	pop    %edi
  8006d1:	5d                   	pop    %ebp
  8006d2:	c3                   	ret    

008006d3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	83 ec 18             	sub    $0x18,%esp
  8006d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	74 26                	je     80071a <vsnprintf+0x47>
  8006f4:	85 d2                	test   %edx,%edx
  8006f6:	7e 22                	jle    80071a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f8:	ff 75 14             	pushl  0x14(%ebp)
  8006fb:	ff 75 10             	pushl  0x10(%ebp)
  8006fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800701:	50                   	push   %eax
  800702:	68 16 02 80 00       	push   $0x800216
  800707:	e8 44 fb ff ff       	call   800250 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800715:	83 c4 10             	add    $0x10,%esp
}
  800718:	c9                   	leave  
  800719:	c3                   	ret    
		return -E_INVAL;
  80071a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071f:	eb f7                	jmp    800718 <vsnprintf+0x45>

00800721 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800727:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072a:	50                   	push   %eax
  80072b:	ff 75 10             	pushl  0x10(%ebp)
  80072e:	ff 75 0c             	pushl  0xc(%ebp)
  800731:	ff 75 08             	pushl  0x8(%ebp)
  800734:	e8 9a ff ff ff       	call   8006d3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800739:	c9                   	leave  
  80073a:	c3                   	ret    

0080073b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	eb 03                	jmp    80074b <strlen+0x10>
		n++;
  800748:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80074b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074f:	75 f7                	jne    800748 <strlen+0xd>
	return n;
}
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075c:	b8 00 00 00 00       	mov    $0x0,%eax
  800761:	eb 03                	jmp    800766 <strnlen+0x13>
		n++;
  800763:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800766:	39 d0                	cmp    %edx,%eax
  800768:	74 06                	je     800770 <strnlen+0x1d>
  80076a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076e:	75 f3                	jne    800763 <strnlen+0x10>
	return n;
}
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	53                   	push   %ebx
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077c:	89 c2                	mov    %eax,%edx
  80077e:	83 c1 01             	add    $0x1,%ecx
  800781:	83 c2 01             	add    $0x1,%edx
  800784:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800788:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078b:	84 db                	test   %bl,%bl
  80078d:	75 ef                	jne    80077e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80078f:	5b                   	pop    %ebx
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	53                   	push   %ebx
  800796:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800799:	53                   	push   %ebx
  80079a:	e8 9c ff ff ff       	call   80073b <strlen>
  80079f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a2:	ff 75 0c             	pushl  0xc(%ebp)
  8007a5:	01 d8                	add    %ebx,%eax
  8007a7:	50                   	push   %eax
  8007a8:	e8 c5 ff ff ff       	call   800772 <strcpy>
	return dst;
}
  8007ad:	89 d8                	mov    %ebx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bf:	89 f3                	mov    %esi,%ebx
  8007c1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c4:	89 f2                	mov    %esi,%edx
  8007c6:	eb 0f                	jmp    8007d7 <strncpy+0x23>
		*dst++ = *src;
  8007c8:	83 c2 01             	add    $0x1,%edx
  8007cb:	0f b6 01             	movzbl (%ecx),%eax
  8007ce:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d1:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d4:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007d7:	39 da                	cmp    %ebx,%edx
  8007d9:	75 ed                	jne    8007c8 <strncpy+0x14>
	}
	return ret;
}
  8007db:	89 f0                	mov    %esi,%eax
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	56                   	push   %esi
  8007e5:	53                   	push   %ebx
  8007e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007ef:	89 f0                	mov    %esi,%eax
  8007f1:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f5:	85 c9                	test   %ecx,%ecx
  8007f7:	75 0b                	jne    800804 <strlcpy+0x23>
  8007f9:	eb 17                	jmp    800812 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fb:	83 c2 01             	add    $0x1,%edx
  8007fe:	83 c0 01             	add    $0x1,%eax
  800801:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800804:	39 d8                	cmp    %ebx,%eax
  800806:	74 07                	je     80080f <strlcpy+0x2e>
  800808:	0f b6 0a             	movzbl (%edx),%ecx
  80080b:	84 c9                	test   %cl,%cl
  80080d:	75 ec                	jne    8007fb <strlcpy+0x1a>
		*dst = '\0';
  80080f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800812:	29 f0                	sub    %esi,%eax
}
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800821:	eb 06                	jmp    800829 <strcmp+0x11>
		p++, q++;
  800823:	83 c1 01             	add    $0x1,%ecx
  800826:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800829:	0f b6 01             	movzbl (%ecx),%eax
  80082c:	84 c0                	test   %al,%al
  80082e:	74 04                	je     800834 <strcmp+0x1c>
  800830:	3a 02                	cmp    (%edx),%al
  800832:	74 ef                	je     800823 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800834:	0f b6 c0             	movzbl %al,%eax
  800837:	0f b6 12             	movzbl (%edx),%edx
  80083a:	29 d0                	sub    %edx,%eax
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	53                   	push   %ebx
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
  800848:	89 c3                	mov    %eax,%ebx
  80084a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084d:	eb 06                	jmp    800855 <strncmp+0x17>
		n--, p++, q++;
  80084f:	83 c0 01             	add    $0x1,%eax
  800852:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800855:	39 d8                	cmp    %ebx,%eax
  800857:	74 16                	je     80086f <strncmp+0x31>
  800859:	0f b6 08             	movzbl (%eax),%ecx
  80085c:	84 c9                	test   %cl,%cl
  80085e:	74 04                	je     800864 <strncmp+0x26>
  800860:	3a 0a                	cmp    (%edx),%cl
  800862:	74 eb                	je     80084f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800864:	0f b6 00             	movzbl (%eax),%eax
  800867:	0f b6 12             	movzbl (%edx),%edx
  80086a:	29 d0                	sub    %edx,%eax
}
  80086c:	5b                   	pop    %ebx
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    
		return 0;
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
  800874:	eb f6                	jmp    80086c <strncmp+0x2e>

00800876 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800880:	0f b6 10             	movzbl (%eax),%edx
  800883:	84 d2                	test   %dl,%dl
  800885:	74 09                	je     800890 <strchr+0x1a>
		if (*s == c)
  800887:	38 ca                	cmp    %cl,%dl
  800889:	74 0a                	je     800895 <strchr+0x1f>
	for (; *s; s++)
  80088b:	83 c0 01             	add    $0x1,%eax
  80088e:	eb f0                	jmp    800880 <strchr+0xa>
			return (char *) s;
	return 0;
  800890:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a1:	eb 03                	jmp    8008a6 <strfind+0xf>
  8008a3:	83 c0 01             	add    $0x1,%eax
  8008a6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008a9:	38 ca                	cmp    %cl,%dl
  8008ab:	74 04                	je     8008b1 <strfind+0x1a>
  8008ad:	84 d2                	test   %dl,%dl
  8008af:	75 f2                	jne    8008a3 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	57                   	push   %edi
  8008b7:	56                   	push   %esi
  8008b8:	53                   	push   %ebx
  8008b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008bf:	85 c9                	test   %ecx,%ecx
  8008c1:	74 13                	je     8008d6 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c9:	75 05                	jne    8008d0 <memset+0x1d>
  8008cb:	f6 c1 03             	test   $0x3,%cl
  8008ce:	74 0d                	je     8008dd <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d3:	fc                   	cld    
  8008d4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d6:	89 f8                	mov    %edi,%eax
  8008d8:	5b                   	pop    %ebx
  8008d9:	5e                   	pop    %esi
  8008da:	5f                   	pop    %edi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    
		c &= 0xFF;
  8008dd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e1:	89 d3                	mov    %edx,%ebx
  8008e3:	c1 e3 08             	shl    $0x8,%ebx
  8008e6:	89 d0                	mov    %edx,%eax
  8008e8:	c1 e0 18             	shl    $0x18,%eax
  8008eb:	89 d6                	mov    %edx,%esi
  8008ed:	c1 e6 10             	shl    $0x10,%esi
  8008f0:	09 f0                	or     %esi,%eax
  8008f2:	09 c2                	or     %eax,%edx
  8008f4:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8008f6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008f9:	89 d0                	mov    %edx,%eax
  8008fb:	fc                   	cld    
  8008fc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fe:	eb d6                	jmp    8008d6 <memset+0x23>

00800900 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	57                   	push   %edi
  800904:	56                   	push   %esi
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090e:	39 c6                	cmp    %eax,%esi
  800910:	73 35                	jae    800947 <memmove+0x47>
  800912:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800915:	39 c2                	cmp    %eax,%edx
  800917:	76 2e                	jbe    800947 <memmove+0x47>
		s += n;
		d += n;
  800919:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091c:	89 d6                	mov    %edx,%esi
  80091e:	09 fe                	or     %edi,%esi
  800920:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800926:	74 0c                	je     800934 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800928:	83 ef 01             	sub    $0x1,%edi
  80092b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80092e:	fd                   	std    
  80092f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800931:	fc                   	cld    
  800932:	eb 21                	jmp    800955 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800934:	f6 c1 03             	test   $0x3,%cl
  800937:	75 ef                	jne    800928 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800939:	83 ef 04             	sub    $0x4,%edi
  80093c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800942:	fd                   	std    
  800943:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800945:	eb ea                	jmp    800931 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800947:	89 f2                	mov    %esi,%edx
  800949:	09 c2                	or     %eax,%edx
  80094b:	f6 c2 03             	test   $0x3,%dl
  80094e:	74 09                	je     800959 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800950:	89 c7                	mov    %eax,%edi
  800952:	fc                   	cld    
  800953:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800955:	5e                   	pop    %esi
  800956:	5f                   	pop    %edi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 f2                	jne    800950 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80095e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800961:	89 c7                	mov    %eax,%edi
  800963:	fc                   	cld    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb ed                	jmp    800955 <memmove+0x55>

00800968 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096b:	ff 75 10             	pushl  0x10(%ebp)
  80096e:	ff 75 0c             	pushl  0xc(%ebp)
  800971:	ff 75 08             	pushl  0x8(%ebp)
  800974:	e8 87 ff ff ff       	call   800900 <memmove>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 55 0c             	mov    0xc(%ebp),%edx
  800986:	89 c6                	mov    %eax,%esi
  800988:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098b:	39 f0                	cmp    %esi,%eax
  80098d:	74 1c                	je     8009ab <memcmp+0x30>
		if (*s1 != *s2)
  80098f:	0f b6 08             	movzbl (%eax),%ecx
  800992:	0f b6 1a             	movzbl (%edx),%ebx
  800995:	38 d9                	cmp    %bl,%cl
  800997:	75 08                	jne    8009a1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800999:	83 c0 01             	add    $0x1,%eax
  80099c:	83 c2 01             	add    $0x1,%edx
  80099f:	eb ea                	jmp    80098b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009a1:	0f b6 c1             	movzbl %cl,%eax
  8009a4:	0f b6 db             	movzbl %bl,%ebx
  8009a7:	29 d8                	sub    %ebx,%eax
  8009a9:	eb 05                	jmp    8009b0 <memcmp+0x35>
	}

	return 0;
  8009ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009bd:	89 c2                	mov    %eax,%edx
  8009bf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c2:	39 d0                	cmp    %edx,%eax
  8009c4:	73 09                	jae    8009cf <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c6:	38 08                	cmp    %cl,(%eax)
  8009c8:	74 05                	je     8009cf <memfind+0x1b>
	for (; s < ends; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	eb f3                	jmp    8009c2 <memfind+0xe>
			break;
	return (void *) s;
}
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	57                   	push   %edi
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009dd:	eb 03                	jmp    8009e2 <strtol+0x11>
		s++;
  8009df:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009e2:	0f b6 01             	movzbl (%ecx),%eax
  8009e5:	3c 20                	cmp    $0x20,%al
  8009e7:	74 f6                	je     8009df <strtol+0xe>
  8009e9:	3c 09                	cmp    $0x9,%al
  8009eb:	74 f2                	je     8009df <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009ed:	3c 2b                	cmp    $0x2b,%al
  8009ef:	74 2e                	je     800a1f <strtol+0x4e>
	int neg = 0;
  8009f1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009f6:	3c 2d                	cmp    $0x2d,%al
  8009f8:	74 2f                	je     800a29 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a00:	75 05                	jne    800a07 <strtol+0x36>
  800a02:	80 39 30             	cmpb   $0x30,(%ecx)
  800a05:	74 2c                	je     800a33 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a07:	85 db                	test   %ebx,%ebx
  800a09:	75 0a                	jne    800a15 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0b:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a10:	80 39 30             	cmpb   $0x30,(%ecx)
  800a13:	74 28                	je     800a3d <strtol+0x6c>
		base = 10;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a1d:	eb 50                	jmp    800a6f <strtol+0x9e>
		s++;
  800a1f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a22:	bf 00 00 00 00       	mov    $0x0,%edi
  800a27:	eb d1                	jmp    8009fa <strtol+0x29>
		s++, neg = 1;
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a31:	eb c7                	jmp    8009fa <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a37:	74 0e                	je     800a47 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a39:	85 db                	test   %ebx,%ebx
  800a3b:	75 d8                	jne    800a15 <strtol+0x44>
		s++, base = 8;
  800a3d:	83 c1 01             	add    $0x1,%ecx
  800a40:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a45:	eb ce                	jmp    800a15 <strtol+0x44>
		s += 2, base = 16;
  800a47:	83 c1 02             	add    $0x2,%ecx
  800a4a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4f:	eb c4                	jmp    800a15 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a51:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a54:	89 f3                	mov    %esi,%ebx
  800a56:	80 fb 19             	cmp    $0x19,%bl
  800a59:	77 29                	ja     800a84 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a5b:	0f be d2             	movsbl %dl,%edx
  800a5e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a61:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a64:	7d 30                	jge    800a96 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a6d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a6f:	0f b6 11             	movzbl (%ecx),%edx
  800a72:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a75:	89 f3                	mov    %esi,%ebx
  800a77:	80 fb 09             	cmp    $0x9,%bl
  800a7a:	77 d5                	ja     800a51 <strtol+0x80>
			dig = *s - '0';
  800a7c:	0f be d2             	movsbl %dl,%edx
  800a7f:	83 ea 30             	sub    $0x30,%edx
  800a82:	eb dd                	jmp    800a61 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a84:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a87:	89 f3                	mov    %esi,%ebx
  800a89:	80 fb 19             	cmp    $0x19,%bl
  800a8c:	77 08                	ja     800a96 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a8e:	0f be d2             	movsbl %dl,%edx
  800a91:	83 ea 37             	sub    $0x37,%edx
  800a94:	eb cb                	jmp    800a61 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9a:	74 05                	je     800aa1 <strtol+0xd0>
		*endptr = (char *) s;
  800a9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aa1:	89 c2                	mov    %eax,%edx
  800aa3:	f7 da                	neg    %edx
  800aa5:	85 ff                	test   %edi,%edi
  800aa7:	0f 45 c2             	cmovne %edx,%eax
}
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	57                   	push   %edi
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aba:	8b 55 08             	mov    0x8(%ebp),%edx
  800abd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac0:	89 c3                	mov    %eax,%ebx
  800ac2:	89 c7                	mov    %eax,%edi
  800ac4:	89 c6                	mov    %eax,%esi
  800ac6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <sys_cgetc>:

int
sys_cgetc(void)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad8:	b8 01 00 00 00       	mov    $0x1,%eax
  800add:	89 d1                	mov    %edx,%ecx
  800adf:	89 d3                	mov    %edx,%ebx
  800ae1:	89 d7                	mov    %edx,%edi
  800ae3:	89 d6                	mov    %edx,%esi
  800ae5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800af5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afa:	8b 55 08             	mov    0x8(%ebp),%edx
  800afd:	b8 03 00 00 00       	mov    $0x3,%eax
  800b02:	89 cb                	mov    %ecx,%ebx
  800b04:	89 cf                	mov    %ecx,%edi
  800b06:	89 ce                	mov    %ecx,%esi
  800b08:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	7f 08                	jg     800b16 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b16:	83 ec 0c             	sub    $0xc,%esp
  800b19:	50                   	push   %eax
  800b1a:	6a 03                	push   $0x3
  800b1c:	68 ff 20 80 00       	push   $0x8020ff
  800b21:	6a 23                	push   $0x23
  800b23:	68 1c 21 80 00       	push   $0x80211c
  800b28:	e8 dd 0e 00 00       	call   801a0a <_panic>

00800b2d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b33:	ba 00 00 00 00       	mov    $0x0,%edx
  800b38:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3d:	89 d1                	mov    %edx,%ecx
  800b3f:	89 d3                	mov    %edx,%ebx
  800b41:	89 d7                	mov    %edx,%edi
  800b43:	89 d6                	mov    %edx,%esi
  800b45:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <sys_yield>:

void
sys_yield(void)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b52:	ba 00 00 00 00       	mov    $0x0,%edx
  800b57:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b5c:	89 d1                	mov    %edx,%ecx
  800b5e:	89 d3                	mov    %edx,%ebx
  800b60:	89 d7                	mov    %edx,%edi
  800b62:	89 d6                	mov    %edx,%esi
  800b64:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b74:	be 00 00 00 00       	mov    $0x0,%esi
  800b79:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b87:	89 f7                	mov    %esi,%edi
  800b89:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	7f 08                	jg     800b97 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	50                   	push   %eax
  800b9b:	6a 04                	push   $0x4
  800b9d:	68 ff 20 80 00       	push   $0x8020ff
  800ba2:	6a 23                	push   $0x23
  800ba4:	68 1c 21 80 00       	push   $0x80211c
  800ba9:	e8 5c 0e 00 00       	call   801a0a <_panic>

00800bae <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbd:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc8:	8b 75 18             	mov    0x18(%ebp),%esi
  800bcb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	7f 08                	jg     800bd9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd9:	83 ec 0c             	sub    $0xc,%esp
  800bdc:	50                   	push   %eax
  800bdd:	6a 05                	push   $0x5
  800bdf:	68 ff 20 80 00       	push   $0x8020ff
  800be4:	6a 23                	push   $0x23
  800be6:	68 1c 21 80 00       	push   $0x80211c
  800beb:	e8 1a 0e 00 00       	call   801a0a <_panic>

00800bf0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	b8 06 00 00 00       	mov    $0x6,%eax
  800c09:	89 df                	mov    %ebx,%edi
  800c0b:	89 de                	mov    %ebx,%esi
  800c0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	7f 08                	jg     800c1b <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1b:	83 ec 0c             	sub    $0xc,%esp
  800c1e:	50                   	push   %eax
  800c1f:	6a 06                	push   $0x6
  800c21:	68 ff 20 80 00       	push   $0x8020ff
  800c26:	6a 23                	push   $0x23
  800c28:	68 1c 21 80 00       	push   $0x80211c
  800c2d:	e8 d8 0d 00 00       	call   801a0a <_panic>

00800c32 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c46:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4b:	89 df                	mov    %ebx,%edi
  800c4d:	89 de                	mov    %ebx,%esi
  800c4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7f 08                	jg     800c5d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 08                	push   $0x8
  800c63:	68 ff 20 80 00       	push   $0x8020ff
  800c68:	6a 23                	push   $0x23
  800c6a:	68 1c 21 80 00       	push   $0x80211c
  800c6f:	e8 96 0d 00 00       	call   801a0a <_panic>

00800c74 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8d:	89 df                	mov    %ebx,%edi
  800c8f:	89 de                	mov    %ebx,%esi
  800c91:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7f 08                	jg     800c9f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	50                   	push   %eax
  800ca3:	6a 09                	push   $0x9
  800ca5:	68 ff 20 80 00       	push   $0x8020ff
  800caa:	6a 23                	push   $0x23
  800cac:	68 1c 21 80 00       	push   $0x80211c
  800cb1:	e8 54 0d 00 00       	call   801a0a <_panic>

00800cb6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ccf:	89 df                	mov    %ebx,%edi
  800cd1:	89 de                	mov    %ebx,%esi
  800cd3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7f 08                	jg     800ce1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	50                   	push   %eax
  800ce5:	6a 0a                	push   $0xa
  800ce7:	68 ff 20 80 00       	push   $0x8020ff
  800cec:	6a 23                	push   $0x23
  800cee:	68 1c 21 80 00       	push   $0x80211c
  800cf3:	e8 12 0d 00 00       	call   801a0a <_panic>

00800cf8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d09:	be 00 00 00 00       	mov    $0x0,%esi
  800d0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d11:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d14:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d31:	89 cb                	mov    %ecx,%ebx
  800d33:	89 cf                	mov    %ecx,%edi
  800d35:	89 ce                	mov    %ecx,%esi
  800d37:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7f 08                	jg     800d45 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	50                   	push   %eax
  800d49:	6a 0d                	push   $0xd
  800d4b:	68 ff 20 80 00       	push   $0x8020ff
  800d50:	6a 23                	push   $0x23
  800d52:	68 1c 21 80 00       	push   $0x80211c
  800d57:	e8 ae 0c 00 00       	call   801a0a <_panic>

00800d5c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	05 00 00 00 30       	add    $0x30000000,%eax
  800d67:	c1 e8 0c             	shr    $0xc,%eax
}
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d7c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d89:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	c1 ea 16             	shr    $0x16,%edx
  800d93:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d9a:	f6 c2 01             	test   $0x1,%dl
  800d9d:	74 2a                	je     800dc9 <fd_alloc+0x46>
  800d9f:	89 c2                	mov    %eax,%edx
  800da1:	c1 ea 0c             	shr    $0xc,%edx
  800da4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dab:	f6 c2 01             	test   $0x1,%dl
  800dae:	74 19                	je     800dc9 <fd_alloc+0x46>
  800db0:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800db5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dba:	75 d2                	jne    800d8e <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dbc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dc2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800dc7:	eb 07                	jmp    800dd0 <fd_alloc+0x4d>
			*fd_store = fd;
  800dc9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dd8:	83 f8 1f             	cmp    $0x1f,%eax
  800ddb:	77 36                	ja     800e13 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ddd:	c1 e0 0c             	shl    $0xc,%eax
  800de0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800de5:	89 c2                	mov    %eax,%edx
  800de7:	c1 ea 16             	shr    $0x16,%edx
  800dea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df1:	f6 c2 01             	test   $0x1,%dl
  800df4:	74 24                	je     800e1a <fd_lookup+0x48>
  800df6:	89 c2                	mov    %eax,%edx
  800df8:	c1 ea 0c             	shr    $0xc,%edx
  800dfb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e02:	f6 c2 01             	test   $0x1,%dl
  800e05:	74 1a                	je     800e21 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0a:	89 02                	mov    %eax,(%edx)
	return 0;
  800e0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
		return -E_INVAL;
  800e13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e18:	eb f7                	jmp    800e11 <fd_lookup+0x3f>
		return -E_INVAL;
  800e1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e1f:	eb f0                	jmp    800e11 <fd_lookup+0x3f>
  800e21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e26:	eb e9                	jmp    800e11 <fd_lookup+0x3f>

00800e28 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	83 ec 08             	sub    $0x8,%esp
  800e2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e31:	ba a8 21 80 00       	mov    $0x8021a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e36:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e3b:	39 08                	cmp    %ecx,(%eax)
  800e3d:	74 33                	je     800e72 <dev_lookup+0x4a>
  800e3f:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800e42:	8b 02                	mov    (%edx),%eax
  800e44:	85 c0                	test   %eax,%eax
  800e46:	75 f3                	jne    800e3b <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e48:	a1 04 40 80 00       	mov    0x804004,%eax
  800e4d:	8b 40 48             	mov    0x48(%eax),%eax
  800e50:	83 ec 04             	sub    $0x4,%esp
  800e53:	51                   	push   %ecx
  800e54:	50                   	push   %eax
  800e55:	68 2c 21 80 00       	push   $0x80212c
  800e5a:	e8 f4 f2 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e62:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e70:	c9                   	leave  
  800e71:	c3                   	ret    
			*dev = devtab[i];
  800e72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e75:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e77:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7c:	eb f2                	jmp    800e70 <dev_lookup+0x48>

00800e7e <fd_close>:
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	83 ec 1c             	sub    $0x1c,%esp
  800e87:	8b 75 08             	mov    0x8(%ebp),%esi
  800e8a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e8d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e90:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e91:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e97:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e9a:	50                   	push   %eax
  800e9b:	e8 32 ff ff ff       	call   800dd2 <fd_lookup>
  800ea0:	89 c3                	mov    %eax,%ebx
  800ea2:	83 c4 08             	add    $0x8,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	78 05                	js     800eae <fd_close+0x30>
	    || fd != fd2)
  800ea9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800eac:	74 16                	je     800ec4 <fd_close+0x46>
		return (must_exist ? r : 0);
  800eae:	89 f8                	mov    %edi,%eax
  800eb0:	84 c0                	test   %al,%al
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	0f 44 d8             	cmove  %eax,%ebx
}
  800eba:	89 d8                	mov    %ebx,%eax
  800ebc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800eca:	50                   	push   %eax
  800ecb:	ff 36                	pushl  (%esi)
  800ecd:	e8 56 ff ff ff       	call   800e28 <dev_lookup>
  800ed2:	89 c3                	mov    %eax,%ebx
  800ed4:	83 c4 10             	add    $0x10,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	78 15                	js     800ef0 <fd_close+0x72>
		if (dev->dev_close)
  800edb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ede:	8b 40 10             	mov    0x10(%eax),%eax
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	74 1b                	je     800f00 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  800ee5:	83 ec 0c             	sub    $0xc,%esp
  800ee8:	56                   	push   %esi
  800ee9:	ff d0                	call   *%eax
  800eeb:	89 c3                	mov    %eax,%ebx
  800eed:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800ef0:	83 ec 08             	sub    $0x8,%esp
  800ef3:	56                   	push   %esi
  800ef4:	6a 00                	push   $0x0
  800ef6:	e8 f5 fc ff ff       	call   800bf0 <sys_page_unmap>
	return r;
  800efb:	83 c4 10             	add    $0x10,%esp
  800efe:	eb ba                	jmp    800eba <fd_close+0x3c>
			r = 0;
  800f00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f05:	eb e9                	jmp    800ef0 <fd_close+0x72>

00800f07 <close>:

int
close(int fdnum)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f10:	50                   	push   %eax
  800f11:	ff 75 08             	pushl  0x8(%ebp)
  800f14:	e8 b9 fe ff ff       	call   800dd2 <fd_lookup>
  800f19:	83 c4 08             	add    $0x8,%esp
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	78 10                	js     800f30 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f20:	83 ec 08             	sub    $0x8,%esp
  800f23:	6a 01                	push   $0x1
  800f25:	ff 75 f4             	pushl  -0xc(%ebp)
  800f28:	e8 51 ff ff ff       	call   800e7e <fd_close>
  800f2d:	83 c4 10             	add    $0x10,%esp
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <close_all>:

void
close_all(void)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	53                   	push   %ebx
  800f36:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f39:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	53                   	push   %ebx
  800f42:	e8 c0 ff ff ff       	call   800f07 <close>
	for (i = 0; i < MAXFD; i++)
  800f47:	83 c3 01             	add    $0x1,%ebx
  800f4a:	83 c4 10             	add    $0x10,%esp
  800f4d:	83 fb 20             	cmp    $0x20,%ebx
  800f50:	75 ec                	jne    800f3e <close_all+0xc>
}
  800f52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	57                   	push   %edi
  800f5b:	56                   	push   %esi
  800f5c:	53                   	push   %ebx
  800f5d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f60:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f63:	50                   	push   %eax
  800f64:	ff 75 08             	pushl  0x8(%ebp)
  800f67:	e8 66 fe ff ff       	call   800dd2 <fd_lookup>
  800f6c:	89 c3                	mov    %eax,%ebx
  800f6e:	83 c4 08             	add    $0x8,%esp
  800f71:	85 c0                	test   %eax,%eax
  800f73:	0f 88 81 00 00 00    	js     800ffa <dup+0xa3>
		return r;
	close(newfdnum);
  800f79:	83 ec 0c             	sub    $0xc,%esp
  800f7c:	ff 75 0c             	pushl  0xc(%ebp)
  800f7f:	e8 83 ff ff ff       	call   800f07 <close>

	newfd = INDEX2FD(newfdnum);
  800f84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f87:	c1 e6 0c             	shl    $0xc,%esi
  800f8a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f90:	83 c4 04             	add    $0x4,%esp
  800f93:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f96:	e8 d1 fd ff ff       	call   800d6c <fd2data>
  800f9b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f9d:	89 34 24             	mov    %esi,(%esp)
  800fa0:	e8 c7 fd ff ff       	call   800d6c <fd2data>
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800faa:	89 d8                	mov    %ebx,%eax
  800fac:	c1 e8 16             	shr    $0x16,%eax
  800faf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb6:	a8 01                	test   $0x1,%al
  800fb8:	74 11                	je     800fcb <dup+0x74>
  800fba:	89 d8                	mov    %ebx,%eax
  800fbc:	c1 e8 0c             	shr    $0xc,%eax
  800fbf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc6:	f6 c2 01             	test   $0x1,%dl
  800fc9:	75 39                	jne    801004 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fcb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fce:	89 d0                	mov    %edx,%eax
  800fd0:	c1 e8 0c             	shr    $0xc,%eax
  800fd3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fda:	83 ec 0c             	sub    $0xc,%esp
  800fdd:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe2:	50                   	push   %eax
  800fe3:	56                   	push   %esi
  800fe4:	6a 00                	push   $0x0
  800fe6:	52                   	push   %edx
  800fe7:	6a 00                	push   $0x0
  800fe9:	e8 c0 fb ff ff       	call   800bae <sys_page_map>
  800fee:	89 c3                	mov    %eax,%ebx
  800ff0:	83 c4 20             	add    $0x20,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 31                	js     801028 <dup+0xd1>
		goto err;

	return newfdnum;
  800ff7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800ffa:	89 d8                	mov    %ebx,%eax
  800ffc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801004:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	25 07 0e 00 00       	and    $0xe07,%eax
  801013:	50                   	push   %eax
  801014:	57                   	push   %edi
  801015:	6a 00                	push   $0x0
  801017:	53                   	push   %ebx
  801018:	6a 00                	push   $0x0
  80101a:	e8 8f fb ff ff       	call   800bae <sys_page_map>
  80101f:	89 c3                	mov    %eax,%ebx
  801021:	83 c4 20             	add    $0x20,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	79 a3                	jns    800fcb <dup+0x74>
	sys_page_unmap(0, newfd);
  801028:	83 ec 08             	sub    $0x8,%esp
  80102b:	56                   	push   %esi
  80102c:	6a 00                	push   $0x0
  80102e:	e8 bd fb ff ff       	call   800bf0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801033:	83 c4 08             	add    $0x8,%esp
  801036:	57                   	push   %edi
  801037:	6a 00                	push   $0x0
  801039:	e8 b2 fb ff ff       	call   800bf0 <sys_page_unmap>
	return r;
  80103e:	83 c4 10             	add    $0x10,%esp
  801041:	eb b7                	jmp    800ffa <dup+0xa3>

00801043 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	53                   	push   %ebx
  801047:	83 ec 14             	sub    $0x14,%esp
  80104a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80104d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801050:	50                   	push   %eax
  801051:	53                   	push   %ebx
  801052:	e8 7b fd ff ff       	call   800dd2 <fd_lookup>
  801057:	83 c4 08             	add    $0x8,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	78 3f                	js     80109d <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80105e:	83 ec 08             	sub    $0x8,%esp
  801061:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801064:	50                   	push   %eax
  801065:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801068:	ff 30                	pushl  (%eax)
  80106a:	e8 b9 fd ff ff       	call   800e28 <dev_lookup>
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	85 c0                	test   %eax,%eax
  801074:	78 27                	js     80109d <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801076:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801079:	8b 42 08             	mov    0x8(%edx),%eax
  80107c:	83 e0 03             	and    $0x3,%eax
  80107f:	83 f8 01             	cmp    $0x1,%eax
  801082:	74 1e                	je     8010a2 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801084:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801087:	8b 40 08             	mov    0x8(%eax),%eax
  80108a:	85 c0                	test   %eax,%eax
  80108c:	74 35                	je     8010c3 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80108e:	83 ec 04             	sub    $0x4,%esp
  801091:	ff 75 10             	pushl  0x10(%ebp)
  801094:	ff 75 0c             	pushl  0xc(%ebp)
  801097:	52                   	push   %edx
  801098:	ff d0                	call   *%eax
  80109a:	83 c4 10             	add    $0x10,%esp
}
  80109d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8010a7:	8b 40 48             	mov    0x48(%eax),%eax
  8010aa:	83 ec 04             	sub    $0x4,%esp
  8010ad:	53                   	push   %ebx
  8010ae:	50                   	push   %eax
  8010af:	68 6d 21 80 00       	push   $0x80216d
  8010b4:	e8 9a f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010c1:	eb da                	jmp    80109d <read+0x5a>
		return -E_NOT_SUPP;
  8010c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010c8:	eb d3                	jmp    80109d <read+0x5a>

008010ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 0c             	sub    $0xc,%esp
  8010d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010de:	39 f3                	cmp    %esi,%ebx
  8010e0:	73 25                	jae    801107 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010e2:	83 ec 04             	sub    $0x4,%esp
  8010e5:	89 f0                	mov    %esi,%eax
  8010e7:	29 d8                	sub    %ebx,%eax
  8010e9:	50                   	push   %eax
  8010ea:	89 d8                	mov    %ebx,%eax
  8010ec:	03 45 0c             	add    0xc(%ebp),%eax
  8010ef:	50                   	push   %eax
  8010f0:	57                   	push   %edi
  8010f1:	e8 4d ff ff ff       	call   801043 <read>
		if (m < 0)
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 08                	js     801105 <readn+0x3b>
			return m;
		if (m == 0)
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	74 06                	je     801107 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801101:	01 c3                	add    %eax,%ebx
  801103:	eb d9                	jmp    8010de <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801105:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801107:	89 d8                	mov    %ebx,%eax
  801109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110c:	5b                   	pop    %ebx
  80110d:	5e                   	pop    %esi
  80110e:	5f                   	pop    %edi
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	53                   	push   %ebx
  801115:	83 ec 14             	sub    $0x14,%esp
  801118:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80111b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111e:	50                   	push   %eax
  80111f:	53                   	push   %ebx
  801120:	e8 ad fc ff ff       	call   800dd2 <fd_lookup>
  801125:	83 c4 08             	add    $0x8,%esp
  801128:	85 c0                	test   %eax,%eax
  80112a:	78 3a                	js     801166 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112c:	83 ec 08             	sub    $0x8,%esp
  80112f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801132:	50                   	push   %eax
  801133:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801136:	ff 30                	pushl  (%eax)
  801138:	e8 eb fc ff ff       	call   800e28 <dev_lookup>
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	78 22                	js     801166 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801144:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801147:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80114b:	74 1e                	je     80116b <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80114d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801150:	8b 52 0c             	mov    0xc(%edx),%edx
  801153:	85 d2                	test   %edx,%edx
  801155:	74 35                	je     80118c <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801157:	83 ec 04             	sub    $0x4,%esp
  80115a:	ff 75 10             	pushl  0x10(%ebp)
  80115d:	ff 75 0c             	pushl  0xc(%ebp)
  801160:	50                   	push   %eax
  801161:	ff d2                	call   *%edx
  801163:	83 c4 10             	add    $0x10,%esp
}
  801166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801169:	c9                   	leave  
  80116a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80116b:	a1 04 40 80 00       	mov    0x804004,%eax
  801170:	8b 40 48             	mov    0x48(%eax),%eax
  801173:	83 ec 04             	sub    $0x4,%esp
  801176:	53                   	push   %ebx
  801177:	50                   	push   %eax
  801178:	68 89 21 80 00       	push   $0x802189
  80117d:	e8 d1 ef ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118a:	eb da                	jmp    801166 <write+0x55>
		return -E_NOT_SUPP;
  80118c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801191:	eb d3                	jmp    801166 <write+0x55>

00801193 <seek>:

int
seek(int fdnum, off_t offset)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801199:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	ff 75 08             	pushl  0x8(%ebp)
  8011a0:	e8 2d fc ff ff       	call   800dd2 <fd_lookup>
  8011a5:	83 c4 08             	add    $0x8,%esp
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 0e                	js     8011ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ba:	c9                   	leave  
  8011bb:	c3                   	ret    

008011bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 14             	sub    $0x14,%esp
  8011c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	53                   	push   %ebx
  8011cb:	e8 02 fc ff ff       	call   800dd2 <fd_lookup>
  8011d0:	83 c4 08             	add    $0x8,%esp
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	78 37                	js     80120e <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d7:	83 ec 08             	sub    $0x8,%esp
  8011da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011dd:	50                   	push   %eax
  8011de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e1:	ff 30                	pushl  (%eax)
  8011e3:	e8 40 fc ff ff       	call   800e28 <dev_lookup>
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 1f                	js     80120e <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f6:	74 1b                	je     801213 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8011f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011fb:	8b 52 18             	mov    0x18(%edx),%edx
  8011fe:	85 d2                	test   %edx,%edx
  801200:	74 32                	je     801234 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	ff 75 0c             	pushl  0xc(%ebp)
  801208:	50                   	push   %eax
  801209:	ff d2                	call   *%edx
  80120b:	83 c4 10             	add    $0x10,%esp
}
  80120e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801211:	c9                   	leave  
  801212:	c3                   	ret    
			thisenv->env_id, fdnum);
  801213:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801218:	8b 40 48             	mov    0x48(%eax),%eax
  80121b:	83 ec 04             	sub    $0x4,%esp
  80121e:	53                   	push   %ebx
  80121f:	50                   	push   %eax
  801220:	68 4c 21 80 00       	push   $0x80214c
  801225:	e8 29 ef ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801232:	eb da                	jmp    80120e <ftruncate+0x52>
		return -E_NOT_SUPP;
  801234:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801239:	eb d3                	jmp    80120e <ftruncate+0x52>

0080123b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	53                   	push   %ebx
  80123f:	83 ec 14             	sub    $0x14,%esp
  801242:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801245:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801248:	50                   	push   %eax
  801249:	ff 75 08             	pushl  0x8(%ebp)
  80124c:	e8 81 fb ff ff       	call   800dd2 <fd_lookup>
  801251:	83 c4 08             	add    $0x8,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	78 4b                	js     8012a3 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801258:	83 ec 08             	sub    $0x8,%esp
  80125b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125e:	50                   	push   %eax
  80125f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801262:	ff 30                	pushl  (%eax)
  801264:	e8 bf fb ff ff       	call   800e28 <dev_lookup>
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	85 c0                	test   %eax,%eax
  80126e:	78 33                	js     8012a3 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801270:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801273:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801277:	74 2f                	je     8012a8 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801279:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80127c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801283:	00 00 00 
	stat->st_isdir = 0;
  801286:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80128d:	00 00 00 
	stat->st_dev = dev;
  801290:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	53                   	push   %ebx
  80129a:	ff 75 f0             	pushl  -0x10(%ebp)
  80129d:	ff 50 14             	call   *0x14(%eax)
  8012a0:	83 c4 10             	add    $0x10,%esp
}
  8012a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    
		return -E_NOT_SUPP;
  8012a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012ad:	eb f4                	jmp    8012a3 <fstat+0x68>

008012af <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	56                   	push   %esi
  8012b3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012b4:	83 ec 08             	sub    $0x8,%esp
  8012b7:	6a 00                	push   $0x0
  8012b9:	ff 75 08             	pushl  0x8(%ebp)
  8012bc:	e8 da 01 00 00       	call   80149b <open>
  8012c1:	89 c3                	mov    %eax,%ebx
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	78 1b                	js     8012e5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012ca:	83 ec 08             	sub    $0x8,%esp
  8012cd:	ff 75 0c             	pushl  0xc(%ebp)
  8012d0:	50                   	push   %eax
  8012d1:	e8 65 ff ff ff       	call   80123b <fstat>
  8012d6:	89 c6                	mov    %eax,%esi
	close(fd);
  8012d8:	89 1c 24             	mov    %ebx,(%esp)
  8012db:	e8 27 fc ff ff       	call   800f07 <close>
	return r;
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	89 f3                	mov    %esi,%ebx
}
  8012e5:	89 d8                	mov    %ebx,%eax
  8012e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ea:	5b                   	pop    %ebx
  8012eb:	5e                   	pop    %esi
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	56                   	push   %esi
  8012f2:	53                   	push   %ebx
  8012f3:	89 c6                	mov    %eax,%esi
  8012f5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012f7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012fe:	74 27                	je     801327 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801300:	6a 07                	push   $0x7
  801302:	68 00 50 80 00       	push   $0x805000
  801307:	56                   	push   %esi
  801308:	ff 35 00 40 80 00    	pushl  0x804000
  80130e:	e8 a4 07 00 00       	call   801ab7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801313:	83 c4 0c             	add    $0xc,%esp
  801316:	6a 00                	push   $0x0
  801318:	53                   	push   %ebx
  801319:	6a 00                	push   $0x0
  80131b:	e8 30 07 00 00       	call   801a50 <ipc_recv>
}
  801320:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801323:	5b                   	pop    %ebx
  801324:	5e                   	pop    %esi
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	6a 01                	push   $0x1
  80132c:	e8 da 07 00 00       	call   801b0b <ipc_find_env>
  801331:	a3 00 40 80 00       	mov    %eax,0x804000
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	eb c5                	jmp    801300 <fsipc+0x12>

0080133b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801341:	8b 45 08             	mov    0x8(%ebp),%eax
  801344:	8b 40 0c             	mov    0xc(%eax),%eax
  801347:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80134c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801354:	ba 00 00 00 00       	mov    $0x0,%edx
  801359:	b8 02 00 00 00       	mov    $0x2,%eax
  80135e:	e8 8b ff ff ff       	call   8012ee <fsipc>
}
  801363:	c9                   	leave  
  801364:	c3                   	ret    

00801365 <devfile_flush>:
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80136b:	8b 45 08             	mov    0x8(%ebp),%eax
  80136e:	8b 40 0c             	mov    0xc(%eax),%eax
  801371:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801376:	ba 00 00 00 00       	mov    $0x0,%edx
  80137b:	b8 06 00 00 00       	mov    $0x6,%eax
  801380:	e8 69 ff ff ff       	call   8012ee <fsipc>
}
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <devfile_stat>:
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	53                   	push   %ebx
  80138b:	83 ec 04             	sub    $0x4,%esp
  80138e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801391:	8b 45 08             	mov    0x8(%ebp),%eax
  801394:	8b 40 0c             	mov    0xc(%eax),%eax
  801397:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80139c:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8013a6:	e8 43 ff ff ff       	call   8012ee <fsipc>
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 2c                	js     8013db <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013af:	83 ec 08             	sub    $0x8,%esp
  8013b2:	68 00 50 80 00       	push   $0x805000
  8013b7:	53                   	push   %ebx
  8013b8:	e8 b5 f3 ff ff       	call   800772 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013bd:	a1 80 50 80 00       	mov    0x805080,%eax
  8013c2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013c8:	a1 84 50 80 00       	mov    0x805084,%eax
  8013cd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013de:	c9                   	leave  
  8013df:	c3                   	ret    

008013e0 <devfile_write>:
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	83 ec 0c             	sub    $0xc,%esp
  8013e6:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ef:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8013f5:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8013fa:	50                   	push   %eax
  8013fb:	ff 75 0c             	pushl  0xc(%ebp)
  8013fe:	68 08 50 80 00       	push   $0x805008
  801403:	e8 f8 f4 ff ff       	call   800900 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  801408:	ba 00 00 00 00       	mov    $0x0,%edx
  80140d:	b8 04 00 00 00       	mov    $0x4,%eax
  801412:	e8 d7 fe ff ff       	call   8012ee <fsipc>
}
  801417:	c9                   	leave  
  801418:	c3                   	ret    

00801419 <devfile_read>:
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	56                   	push   %esi
  80141d:	53                   	push   %ebx
  80141e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	8b 40 0c             	mov    0xc(%eax),%eax
  801427:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80142c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801432:	ba 00 00 00 00       	mov    $0x0,%edx
  801437:	b8 03 00 00 00       	mov    $0x3,%eax
  80143c:	e8 ad fe ff ff       	call   8012ee <fsipc>
  801441:	89 c3                	mov    %eax,%ebx
  801443:	85 c0                	test   %eax,%eax
  801445:	78 1f                	js     801466 <devfile_read+0x4d>
	assert(r <= n);
  801447:	39 f0                	cmp    %esi,%eax
  801449:	77 24                	ja     80146f <devfile_read+0x56>
	assert(r <= PGSIZE);
  80144b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801450:	7f 33                	jg     801485 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801452:	83 ec 04             	sub    $0x4,%esp
  801455:	50                   	push   %eax
  801456:	68 00 50 80 00       	push   $0x805000
  80145b:	ff 75 0c             	pushl  0xc(%ebp)
  80145e:	e8 9d f4 ff ff       	call   800900 <memmove>
	return r;
  801463:	83 c4 10             	add    $0x10,%esp
}
  801466:	89 d8                	mov    %ebx,%eax
  801468:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146b:	5b                   	pop    %ebx
  80146c:	5e                   	pop    %esi
  80146d:	5d                   	pop    %ebp
  80146e:	c3                   	ret    
	assert(r <= n);
  80146f:	68 b8 21 80 00       	push   $0x8021b8
  801474:	68 bf 21 80 00       	push   $0x8021bf
  801479:	6a 7c                	push   $0x7c
  80147b:	68 d4 21 80 00       	push   $0x8021d4
  801480:	e8 85 05 00 00       	call   801a0a <_panic>
	assert(r <= PGSIZE);
  801485:	68 df 21 80 00       	push   $0x8021df
  80148a:	68 bf 21 80 00       	push   $0x8021bf
  80148f:	6a 7d                	push   $0x7d
  801491:	68 d4 21 80 00       	push   $0x8021d4
  801496:	e8 6f 05 00 00       	call   801a0a <_panic>

0080149b <open>:
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	56                   	push   %esi
  80149f:	53                   	push   %ebx
  8014a0:	83 ec 1c             	sub    $0x1c,%esp
  8014a3:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014a6:	56                   	push   %esi
  8014a7:	e8 8f f2 ff ff       	call   80073b <strlen>
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014b4:	7f 6c                	jg     801522 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014b6:	83 ec 0c             	sub    $0xc,%esp
  8014b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	e8 c1 f8 ff ff       	call   800d83 <fd_alloc>
  8014c2:	89 c3                	mov    %eax,%ebx
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 3c                	js     801507 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	56                   	push   %esi
  8014cf:	68 00 50 80 00       	push   $0x805000
  8014d4:	e8 99 f2 ff ff       	call   800772 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014dc:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e9:	e8 00 fe ff ff       	call   8012ee <fsipc>
  8014ee:	89 c3                	mov    %eax,%ebx
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 19                	js     801510 <open+0x75>
	return fd2num(fd);
  8014f7:	83 ec 0c             	sub    $0xc,%esp
  8014fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fd:	e8 5a f8 ff ff       	call   800d5c <fd2num>
  801502:	89 c3                	mov    %eax,%ebx
  801504:	83 c4 10             	add    $0x10,%esp
}
  801507:	89 d8                	mov    %ebx,%eax
  801509:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150c:	5b                   	pop    %ebx
  80150d:	5e                   	pop    %esi
  80150e:	5d                   	pop    %ebp
  80150f:	c3                   	ret    
		fd_close(fd, 0);
  801510:	83 ec 08             	sub    $0x8,%esp
  801513:	6a 00                	push   $0x0
  801515:	ff 75 f4             	pushl  -0xc(%ebp)
  801518:	e8 61 f9 ff ff       	call   800e7e <fd_close>
		return r;
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	eb e5                	jmp    801507 <open+0x6c>
		return -E_BAD_PATH;
  801522:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801527:	eb de                	jmp    801507 <open+0x6c>

00801529 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80152f:	ba 00 00 00 00       	mov    $0x0,%edx
  801534:	b8 08 00 00 00       	mov    $0x8,%eax
  801539:	e8 b0 fd ff ff       	call   8012ee <fsipc>
}
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	56                   	push   %esi
  801544:	53                   	push   %ebx
  801545:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801548:	83 ec 0c             	sub    $0xc,%esp
  80154b:	ff 75 08             	pushl  0x8(%ebp)
  80154e:	e8 19 f8 ff ff       	call   800d6c <fd2data>
  801553:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801555:	83 c4 08             	add    $0x8,%esp
  801558:	68 eb 21 80 00       	push   $0x8021eb
  80155d:	53                   	push   %ebx
  80155e:	e8 0f f2 ff ff       	call   800772 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801563:	8b 46 04             	mov    0x4(%esi),%eax
  801566:	2b 06                	sub    (%esi),%eax
  801568:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80156e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801575:	00 00 00 
	stat->st_dev = &devpipe;
  801578:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80157f:	30 80 00 
	return 0;
}
  801582:	b8 00 00 00 00       	mov    $0x0,%eax
  801587:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5e                   	pop    %esi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	53                   	push   %ebx
  801592:	83 ec 0c             	sub    $0xc,%esp
  801595:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801598:	53                   	push   %ebx
  801599:	6a 00                	push   $0x0
  80159b:	e8 50 f6 ff ff       	call   800bf0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015a0:	89 1c 24             	mov    %ebx,(%esp)
  8015a3:	e8 c4 f7 ff ff       	call   800d6c <fd2data>
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	50                   	push   %eax
  8015ac:	6a 00                	push   $0x0
  8015ae:	e8 3d f6 ff ff       	call   800bf0 <sys_page_unmap>
}
  8015b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <_pipeisclosed>:
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	57                   	push   %edi
  8015bc:	56                   	push   %esi
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 1c             	sub    $0x1c,%esp
  8015c1:	89 c7                	mov    %eax,%edi
  8015c3:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8015c5:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ca:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8015cd:	83 ec 0c             	sub    $0xc,%esp
  8015d0:	57                   	push   %edi
  8015d1:	e8 6e 05 00 00       	call   801b44 <pageref>
  8015d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015d9:	89 34 24             	mov    %esi,(%esp)
  8015dc:	e8 63 05 00 00       	call   801b44 <pageref>
		nn = thisenv->env_runs;
  8015e1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015e7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	39 cb                	cmp    %ecx,%ebx
  8015ef:	74 1b                	je     80160c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8015f1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015f4:	75 cf                	jne    8015c5 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015f6:	8b 42 58             	mov    0x58(%edx),%eax
  8015f9:	6a 01                	push   $0x1
  8015fb:	50                   	push   %eax
  8015fc:	53                   	push   %ebx
  8015fd:	68 f2 21 80 00       	push   $0x8021f2
  801602:	e8 4c eb ff ff       	call   800153 <cprintf>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb b9                	jmp    8015c5 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80160c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80160f:	0f 94 c0             	sete   %al
  801612:	0f b6 c0             	movzbl %al,%eax
}
  801615:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801618:	5b                   	pop    %ebx
  801619:	5e                   	pop    %esi
  80161a:	5f                   	pop    %edi
  80161b:	5d                   	pop    %ebp
  80161c:	c3                   	ret    

0080161d <devpipe_write>:
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	57                   	push   %edi
  801621:	56                   	push   %esi
  801622:	53                   	push   %ebx
  801623:	83 ec 28             	sub    $0x28,%esp
  801626:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801629:	56                   	push   %esi
  80162a:	e8 3d f7 ff ff       	call   800d6c <fd2data>
  80162f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	bf 00 00 00 00       	mov    $0x0,%edi
  801639:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80163c:	74 4f                	je     80168d <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80163e:	8b 43 04             	mov    0x4(%ebx),%eax
  801641:	8b 0b                	mov    (%ebx),%ecx
  801643:	8d 51 20             	lea    0x20(%ecx),%edx
  801646:	39 d0                	cmp    %edx,%eax
  801648:	72 14                	jb     80165e <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  80164a:	89 da                	mov    %ebx,%edx
  80164c:	89 f0                	mov    %esi,%eax
  80164e:	e8 65 ff ff ff       	call   8015b8 <_pipeisclosed>
  801653:	85 c0                	test   %eax,%eax
  801655:	75 3a                	jne    801691 <devpipe_write+0x74>
			sys_yield();
  801657:	e8 f0 f4 ff ff       	call   800b4c <sys_yield>
  80165c:	eb e0                	jmp    80163e <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80165e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801661:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801665:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801668:	89 c2                	mov    %eax,%edx
  80166a:	c1 fa 1f             	sar    $0x1f,%edx
  80166d:	89 d1                	mov    %edx,%ecx
  80166f:	c1 e9 1b             	shr    $0x1b,%ecx
  801672:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801675:	83 e2 1f             	and    $0x1f,%edx
  801678:	29 ca                	sub    %ecx,%edx
  80167a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80167e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801682:	83 c0 01             	add    $0x1,%eax
  801685:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801688:	83 c7 01             	add    $0x1,%edi
  80168b:	eb ac                	jmp    801639 <devpipe_write+0x1c>
	return i;
  80168d:	89 f8                	mov    %edi,%eax
  80168f:	eb 05                	jmp    801696 <devpipe_write+0x79>
				return 0;
  801691:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801696:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	5f                   	pop    %edi
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <devpipe_read>:
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	57                   	push   %edi
  8016a2:	56                   	push   %esi
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 18             	sub    $0x18,%esp
  8016a7:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8016aa:	57                   	push   %edi
  8016ab:	e8 bc f6 ff ff       	call   800d6c <fd2data>
  8016b0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	be 00 00 00 00       	mov    $0x0,%esi
  8016ba:	3b 75 10             	cmp    0x10(%ebp),%esi
  8016bd:	74 47                	je     801706 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  8016bf:	8b 03                	mov    (%ebx),%eax
  8016c1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016c4:	75 22                	jne    8016e8 <devpipe_read+0x4a>
			if (i > 0)
  8016c6:	85 f6                	test   %esi,%esi
  8016c8:	75 14                	jne    8016de <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  8016ca:	89 da                	mov    %ebx,%edx
  8016cc:	89 f8                	mov    %edi,%eax
  8016ce:	e8 e5 fe ff ff       	call   8015b8 <_pipeisclosed>
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	75 33                	jne    80170a <devpipe_read+0x6c>
			sys_yield();
  8016d7:	e8 70 f4 ff ff       	call   800b4c <sys_yield>
  8016dc:	eb e1                	jmp    8016bf <devpipe_read+0x21>
				return i;
  8016de:	89 f0                	mov    %esi,%eax
}
  8016e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e3:	5b                   	pop    %ebx
  8016e4:	5e                   	pop    %esi
  8016e5:	5f                   	pop    %edi
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016e8:	99                   	cltd   
  8016e9:	c1 ea 1b             	shr    $0x1b,%edx
  8016ec:	01 d0                	add    %edx,%eax
  8016ee:	83 e0 1f             	and    $0x1f,%eax
  8016f1:	29 d0                	sub    %edx,%eax
  8016f3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8016f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8016fe:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801701:	83 c6 01             	add    $0x1,%esi
  801704:	eb b4                	jmp    8016ba <devpipe_read+0x1c>
	return i;
  801706:	89 f0                	mov    %esi,%eax
  801708:	eb d6                	jmp    8016e0 <devpipe_read+0x42>
				return 0;
  80170a:	b8 00 00 00 00       	mov    $0x0,%eax
  80170f:	eb cf                	jmp    8016e0 <devpipe_read+0x42>

00801711 <pipe>:
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	56                   	push   %esi
  801715:	53                   	push   %ebx
  801716:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801719:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171c:	50                   	push   %eax
  80171d:	e8 61 f6 ff ff       	call   800d83 <fd_alloc>
  801722:	89 c3                	mov    %eax,%ebx
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	85 c0                	test   %eax,%eax
  801729:	78 5b                	js     801786 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80172b:	83 ec 04             	sub    $0x4,%esp
  80172e:	68 07 04 00 00       	push   $0x407
  801733:	ff 75 f4             	pushl  -0xc(%ebp)
  801736:	6a 00                	push   $0x0
  801738:	e8 2e f4 ff ff       	call   800b6b <sys_page_alloc>
  80173d:	89 c3                	mov    %eax,%ebx
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 40                	js     801786 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801746:	83 ec 0c             	sub    $0xc,%esp
  801749:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174c:	50                   	push   %eax
  80174d:	e8 31 f6 ff ff       	call   800d83 <fd_alloc>
  801752:	89 c3                	mov    %eax,%ebx
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	85 c0                	test   %eax,%eax
  801759:	78 1b                	js     801776 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80175b:	83 ec 04             	sub    $0x4,%esp
  80175e:	68 07 04 00 00       	push   $0x407
  801763:	ff 75 f0             	pushl  -0x10(%ebp)
  801766:	6a 00                	push   $0x0
  801768:	e8 fe f3 ff ff       	call   800b6b <sys_page_alloc>
  80176d:	89 c3                	mov    %eax,%ebx
  80176f:	83 c4 10             	add    $0x10,%esp
  801772:	85 c0                	test   %eax,%eax
  801774:	79 19                	jns    80178f <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801776:	83 ec 08             	sub    $0x8,%esp
  801779:	ff 75 f4             	pushl  -0xc(%ebp)
  80177c:	6a 00                	push   $0x0
  80177e:	e8 6d f4 ff ff       	call   800bf0 <sys_page_unmap>
  801783:	83 c4 10             	add    $0x10,%esp
}
  801786:	89 d8                	mov    %ebx,%eax
  801788:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    
	va = fd2data(fd0);
  80178f:	83 ec 0c             	sub    $0xc,%esp
  801792:	ff 75 f4             	pushl  -0xc(%ebp)
  801795:	e8 d2 f5 ff ff       	call   800d6c <fd2data>
  80179a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80179c:	83 c4 0c             	add    $0xc,%esp
  80179f:	68 07 04 00 00       	push   $0x407
  8017a4:	50                   	push   %eax
  8017a5:	6a 00                	push   $0x0
  8017a7:	e8 bf f3 ff ff       	call   800b6b <sys_page_alloc>
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	0f 88 8c 00 00 00    	js     801845 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b9:	83 ec 0c             	sub    $0xc,%esp
  8017bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8017bf:	e8 a8 f5 ff ff       	call   800d6c <fd2data>
  8017c4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017cb:	50                   	push   %eax
  8017cc:	6a 00                	push   $0x0
  8017ce:	56                   	push   %esi
  8017cf:	6a 00                	push   $0x0
  8017d1:	e8 d8 f3 ff ff       	call   800bae <sys_page_map>
  8017d6:	89 c3                	mov    %eax,%ebx
  8017d8:	83 c4 20             	add    $0x20,%esp
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 58                	js     801837 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  8017df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ed:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8017f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017fd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801802:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801809:	83 ec 0c             	sub    $0xc,%esp
  80180c:	ff 75 f4             	pushl  -0xc(%ebp)
  80180f:	e8 48 f5 ff ff       	call   800d5c <fd2num>
  801814:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801817:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801819:	83 c4 04             	add    $0x4,%esp
  80181c:	ff 75 f0             	pushl  -0x10(%ebp)
  80181f:	e8 38 f5 ff ff       	call   800d5c <fd2num>
  801824:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801827:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801832:	e9 4f ff ff ff       	jmp    801786 <pipe+0x75>
	sys_page_unmap(0, va);
  801837:	83 ec 08             	sub    $0x8,%esp
  80183a:	56                   	push   %esi
  80183b:	6a 00                	push   $0x0
  80183d:	e8 ae f3 ff ff       	call   800bf0 <sys_page_unmap>
  801842:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801845:	83 ec 08             	sub    $0x8,%esp
  801848:	ff 75 f0             	pushl  -0x10(%ebp)
  80184b:	6a 00                	push   $0x0
  80184d:	e8 9e f3 ff ff       	call   800bf0 <sys_page_unmap>
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	e9 1c ff ff ff       	jmp    801776 <pipe+0x65>

0080185a <pipeisclosed>:
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801860:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801863:	50                   	push   %eax
  801864:	ff 75 08             	pushl  0x8(%ebp)
  801867:	e8 66 f5 ff ff       	call   800dd2 <fd_lookup>
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	85 c0                	test   %eax,%eax
  801871:	78 18                	js     80188b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801873:	83 ec 0c             	sub    $0xc,%esp
  801876:	ff 75 f4             	pushl  -0xc(%ebp)
  801879:	e8 ee f4 ff ff       	call   800d6c <fd2data>
	return _pipeisclosed(fd, p);
  80187e:	89 c2                	mov    %eax,%edx
  801880:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801883:	e8 30 fd ff ff       	call   8015b8 <_pipeisclosed>
  801888:	83 c4 10             	add    $0x10,%esp
}
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801890:	b8 00 00 00 00       	mov    $0x0,%eax
  801895:	5d                   	pop    %ebp
  801896:	c3                   	ret    

00801897 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80189d:	68 0a 22 80 00       	push   $0x80220a
  8018a2:	ff 75 0c             	pushl  0xc(%ebp)
  8018a5:	e8 c8 ee ff ff       	call   800772 <strcpy>
	return 0;
}
  8018aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8018af:	c9                   	leave  
  8018b0:	c3                   	ret    

008018b1 <devcons_write>:
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	57                   	push   %edi
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
  8018b7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8018bd:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8018c2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8018c8:	eb 2f                	jmp    8018f9 <devcons_write+0x48>
		m = n - tot;
  8018ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018cd:	29 f3                	sub    %esi,%ebx
  8018cf:	83 fb 7f             	cmp    $0x7f,%ebx
  8018d2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8018d7:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018da:	83 ec 04             	sub    $0x4,%esp
  8018dd:	53                   	push   %ebx
  8018de:	89 f0                	mov    %esi,%eax
  8018e0:	03 45 0c             	add    0xc(%ebp),%eax
  8018e3:	50                   	push   %eax
  8018e4:	57                   	push   %edi
  8018e5:	e8 16 f0 ff ff       	call   800900 <memmove>
		sys_cputs(buf, m);
  8018ea:	83 c4 08             	add    $0x8,%esp
  8018ed:	53                   	push   %ebx
  8018ee:	57                   	push   %edi
  8018ef:	e8 bb f1 ff ff       	call   800aaf <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8018f4:	01 de                	add    %ebx,%esi
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018fc:	72 cc                	jb     8018ca <devcons_write+0x19>
}
  8018fe:	89 f0                	mov    %esi,%eax
  801900:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801903:	5b                   	pop    %ebx
  801904:	5e                   	pop    %esi
  801905:	5f                   	pop    %edi
  801906:	5d                   	pop    %ebp
  801907:	c3                   	ret    

00801908 <devcons_read>:
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	83 ec 08             	sub    $0x8,%esp
  80190e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801913:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801917:	75 07                	jne    801920 <devcons_read+0x18>
}
  801919:	c9                   	leave  
  80191a:	c3                   	ret    
		sys_yield();
  80191b:	e8 2c f2 ff ff       	call   800b4c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801920:	e8 a8 f1 ff ff       	call   800acd <sys_cgetc>
  801925:	85 c0                	test   %eax,%eax
  801927:	74 f2                	je     80191b <devcons_read+0x13>
	if (c < 0)
  801929:	85 c0                	test   %eax,%eax
  80192b:	78 ec                	js     801919 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  80192d:	83 f8 04             	cmp    $0x4,%eax
  801930:	74 0c                	je     80193e <devcons_read+0x36>
	*(char*)vbuf = c;
  801932:	8b 55 0c             	mov    0xc(%ebp),%edx
  801935:	88 02                	mov    %al,(%edx)
	return 1;
  801937:	b8 01 00 00 00       	mov    $0x1,%eax
  80193c:	eb db                	jmp    801919 <devcons_read+0x11>
		return 0;
  80193e:	b8 00 00 00 00       	mov    $0x0,%eax
  801943:	eb d4                	jmp    801919 <devcons_read+0x11>

00801945 <cputchar>:
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80194b:	8b 45 08             	mov    0x8(%ebp),%eax
  80194e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801951:	6a 01                	push   $0x1
  801953:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801956:	50                   	push   %eax
  801957:	e8 53 f1 ff ff       	call   800aaf <sys_cputs>
}
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	c9                   	leave  
  801960:	c3                   	ret    

00801961 <getchar>:
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801967:	6a 01                	push   $0x1
  801969:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80196c:	50                   	push   %eax
  80196d:	6a 00                	push   $0x0
  80196f:	e8 cf f6 ff ff       	call   801043 <read>
	if (r < 0)
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	85 c0                	test   %eax,%eax
  801979:	78 08                	js     801983 <getchar+0x22>
	if (r < 1)
  80197b:	85 c0                	test   %eax,%eax
  80197d:	7e 06                	jle    801985 <getchar+0x24>
	return c;
  80197f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801983:	c9                   	leave  
  801984:	c3                   	ret    
		return -E_EOF;
  801985:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80198a:	eb f7                	jmp    801983 <getchar+0x22>

0080198c <iscons>:
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801992:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801995:	50                   	push   %eax
  801996:	ff 75 08             	pushl  0x8(%ebp)
  801999:	e8 34 f4 ff ff       	call   800dd2 <fd_lookup>
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	78 11                	js     8019b6 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8019a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ae:	39 10                	cmp    %edx,(%eax)
  8019b0:	0f 94 c0             	sete   %al
  8019b3:	0f b6 c0             	movzbl %al,%eax
}
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <opencons>:
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8019be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c1:	50                   	push   %eax
  8019c2:	e8 bc f3 ff ff       	call   800d83 <fd_alloc>
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 3a                	js     801a08 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019ce:	83 ec 04             	sub    $0x4,%esp
  8019d1:	68 07 04 00 00       	push   $0x407
  8019d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d9:	6a 00                	push   $0x0
  8019db:	e8 8b f1 ff ff       	call   800b6b <sys_page_alloc>
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 21                	js     801a08 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8019e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ea:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019f0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019fc:	83 ec 0c             	sub    $0xc,%esp
  8019ff:	50                   	push   %eax
  801a00:	e8 57 f3 ff ff       	call   800d5c <fd2num>
  801a05:	83 c4 10             	add    $0x10,%esp
}
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	56                   	push   %esi
  801a0e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a0f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a12:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a18:	e8 10 f1 ff ff       	call   800b2d <sys_getenvid>
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	ff 75 0c             	pushl  0xc(%ebp)
  801a23:	ff 75 08             	pushl  0x8(%ebp)
  801a26:	56                   	push   %esi
  801a27:	50                   	push   %eax
  801a28:	68 18 22 80 00       	push   $0x802218
  801a2d:	e8 21 e7 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a32:	83 c4 18             	add    $0x18,%esp
  801a35:	53                   	push   %ebx
  801a36:	ff 75 10             	pushl  0x10(%ebp)
  801a39:	e8 c4 e6 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801a3e:	c7 04 24 03 22 80 00 	movl   $0x802203,(%esp)
  801a45:	e8 09 e7 ff ff       	call   800153 <cprintf>
  801a4a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a4d:	cc                   	int3   
  801a4e:	eb fd                	jmp    801a4d <_panic+0x43>

00801a50 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	56                   	push   %esi
  801a54:	53                   	push   %ebx
  801a55:	8b 75 08             	mov    0x8(%ebp),%esi
  801a58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a5e:	85 f6                	test   %esi,%esi
  801a60:	74 06                	je     801a68 <ipc_recv+0x18>
  801a62:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a68:	85 db                	test   %ebx,%ebx
  801a6a:	74 06                	je     801a72 <ipc_recv+0x22>
  801a6c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a72:	85 c0                	test   %eax,%eax
  801a74:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a79:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	50                   	push   %eax
  801a80:	e8 96 f2 ff ff       	call   800d1b <sys_ipc_recv>
	if (ret) return ret;
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	75 24                	jne    801ab0 <ipc_recv+0x60>
	if (from_env_store)
  801a8c:	85 f6                	test   %esi,%esi
  801a8e:	74 0a                	je     801a9a <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801a90:	a1 04 40 80 00       	mov    0x804004,%eax
  801a95:	8b 40 74             	mov    0x74(%eax),%eax
  801a98:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a9a:	85 db                	test   %ebx,%ebx
  801a9c:	74 0a                	je     801aa8 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801a9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa3:	8b 40 78             	mov    0x78(%eax),%eax
  801aa6:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801aa8:	a1 04 40 80 00       	mov    0x804004,%eax
  801aad:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ab0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab3:	5b                   	pop    %ebx
  801ab4:	5e                   	pop    %esi
  801ab5:	5d                   	pop    %ebp
  801ab6:	c3                   	ret    

00801ab7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	57                   	push   %edi
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	83 ec 0c             	sub    $0xc,%esp
  801ac0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ac6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801ac9:	85 db                	test   %ebx,%ebx
  801acb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ad0:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ad3:	ff 75 14             	pushl  0x14(%ebp)
  801ad6:	53                   	push   %ebx
  801ad7:	56                   	push   %esi
  801ad8:	57                   	push   %edi
  801ad9:	e8 1a f2 ff ff       	call   800cf8 <sys_ipc_try_send>
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	74 1e                	je     801b03 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ae5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ae8:	75 07                	jne    801af1 <ipc_send+0x3a>
		sys_yield();
  801aea:	e8 5d f0 ff ff       	call   800b4c <sys_yield>
  801aef:	eb e2                	jmp    801ad3 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801af1:	50                   	push   %eax
  801af2:	68 3c 22 80 00       	push   $0x80223c
  801af7:	6a 36                	push   $0x36
  801af9:	68 53 22 80 00       	push   $0x802253
  801afe:	e8 07 ff ff ff       	call   801a0a <_panic>
	}
}
  801b03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b06:	5b                   	pop    %ebx
  801b07:	5e                   	pop    %esi
  801b08:	5f                   	pop    %edi
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b11:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b16:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b19:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b1f:	8b 52 50             	mov    0x50(%edx),%edx
  801b22:	39 ca                	cmp    %ecx,%edx
  801b24:	74 11                	je     801b37 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b26:	83 c0 01             	add    $0x1,%eax
  801b29:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b2e:	75 e6                	jne    801b16 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b30:	b8 00 00 00 00       	mov    $0x0,%eax
  801b35:	eb 0b                	jmp    801b42 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b37:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b3a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b3f:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b4a:	89 d0                	mov    %edx,%eax
  801b4c:	c1 e8 16             	shr    $0x16,%eax
  801b4f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b56:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b5b:	f6 c1 01             	test   $0x1,%cl
  801b5e:	74 1d                	je     801b7d <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b60:	c1 ea 0c             	shr    $0xc,%edx
  801b63:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b6a:	f6 c2 01             	test   $0x1,%dl
  801b6d:	74 0e                	je     801b7d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b6f:	c1 ea 0c             	shr    $0xc,%edx
  801b72:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b79:	ef 
  801b7a:	0f b7 c0             	movzwl %ax,%eax
}
  801b7d:	5d                   	pop    %ebp
  801b7e:	c3                   	ret    
  801b7f:	90                   	nop

00801b80 <__udivdi3>:
  801b80:	55                   	push   %ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 1c             	sub    $0x1c,%esp
  801b87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b8b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b93:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b97:	85 d2                	test   %edx,%edx
  801b99:	75 35                	jne    801bd0 <__udivdi3+0x50>
  801b9b:	39 f3                	cmp    %esi,%ebx
  801b9d:	0f 87 bd 00 00 00    	ja     801c60 <__udivdi3+0xe0>
  801ba3:	85 db                	test   %ebx,%ebx
  801ba5:	89 d9                	mov    %ebx,%ecx
  801ba7:	75 0b                	jne    801bb4 <__udivdi3+0x34>
  801ba9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bae:	31 d2                	xor    %edx,%edx
  801bb0:	f7 f3                	div    %ebx
  801bb2:	89 c1                	mov    %eax,%ecx
  801bb4:	31 d2                	xor    %edx,%edx
  801bb6:	89 f0                	mov    %esi,%eax
  801bb8:	f7 f1                	div    %ecx
  801bba:	89 c6                	mov    %eax,%esi
  801bbc:	89 e8                	mov    %ebp,%eax
  801bbe:	89 f7                	mov    %esi,%edi
  801bc0:	f7 f1                	div    %ecx
  801bc2:	89 fa                	mov    %edi,%edx
  801bc4:	83 c4 1c             	add    $0x1c,%esp
  801bc7:	5b                   	pop    %ebx
  801bc8:	5e                   	pop    %esi
  801bc9:	5f                   	pop    %edi
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    
  801bcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bd0:	39 f2                	cmp    %esi,%edx
  801bd2:	77 7c                	ja     801c50 <__udivdi3+0xd0>
  801bd4:	0f bd fa             	bsr    %edx,%edi
  801bd7:	83 f7 1f             	xor    $0x1f,%edi
  801bda:	0f 84 98 00 00 00    	je     801c78 <__udivdi3+0xf8>
  801be0:	89 f9                	mov    %edi,%ecx
  801be2:	b8 20 00 00 00       	mov    $0x20,%eax
  801be7:	29 f8                	sub    %edi,%eax
  801be9:	d3 e2                	shl    %cl,%edx
  801beb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bef:	89 c1                	mov    %eax,%ecx
  801bf1:	89 da                	mov    %ebx,%edx
  801bf3:	d3 ea                	shr    %cl,%edx
  801bf5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801bf9:	09 d1                	or     %edx,%ecx
  801bfb:	89 f2                	mov    %esi,%edx
  801bfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c01:	89 f9                	mov    %edi,%ecx
  801c03:	d3 e3                	shl    %cl,%ebx
  801c05:	89 c1                	mov    %eax,%ecx
  801c07:	d3 ea                	shr    %cl,%edx
  801c09:	89 f9                	mov    %edi,%ecx
  801c0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c0f:	d3 e6                	shl    %cl,%esi
  801c11:	89 eb                	mov    %ebp,%ebx
  801c13:	89 c1                	mov    %eax,%ecx
  801c15:	d3 eb                	shr    %cl,%ebx
  801c17:	09 de                	or     %ebx,%esi
  801c19:	89 f0                	mov    %esi,%eax
  801c1b:	f7 74 24 08          	divl   0x8(%esp)
  801c1f:	89 d6                	mov    %edx,%esi
  801c21:	89 c3                	mov    %eax,%ebx
  801c23:	f7 64 24 0c          	mull   0xc(%esp)
  801c27:	39 d6                	cmp    %edx,%esi
  801c29:	72 0c                	jb     801c37 <__udivdi3+0xb7>
  801c2b:	89 f9                	mov    %edi,%ecx
  801c2d:	d3 e5                	shl    %cl,%ebp
  801c2f:	39 c5                	cmp    %eax,%ebp
  801c31:	73 5d                	jae    801c90 <__udivdi3+0x110>
  801c33:	39 d6                	cmp    %edx,%esi
  801c35:	75 59                	jne    801c90 <__udivdi3+0x110>
  801c37:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c3a:	31 ff                	xor    %edi,%edi
  801c3c:	89 fa                	mov    %edi,%edx
  801c3e:	83 c4 1c             	add    $0x1c,%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5f                   	pop    %edi
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    
  801c46:	8d 76 00             	lea    0x0(%esi),%esi
  801c49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c50:	31 ff                	xor    %edi,%edi
  801c52:	31 c0                	xor    %eax,%eax
  801c54:	89 fa                	mov    %edi,%edx
  801c56:	83 c4 1c             	add    $0x1c,%esp
  801c59:	5b                   	pop    %ebx
  801c5a:	5e                   	pop    %esi
  801c5b:	5f                   	pop    %edi
  801c5c:	5d                   	pop    %ebp
  801c5d:	c3                   	ret    
  801c5e:	66 90                	xchg   %ax,%ax
  801c60:	31 ff                	xor    %edi,%edi
  801c62:	89 e8                	mov    %ebp,%eax
  801c64:	89 f2                	mov    %esi,%edx
  801c66:	f7 f3                	div    %ebx
  801c68:	89 fa                	mov    %edi,%edx
  801c6a:	83 c4 1c             	add    $0x1c,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c78:	39 f2                	cmp    %esi,%edx
  801c7a:	72 06                	jb     801c82 <__udivdi3+0x102>
  801c7c:	31 c0                	xor    %eax,%eax
  801c7e:	39 eb                	cmp    %ebp,%ebx
  801c80:	77 d2                	ja     801c54 <__udivdi3+0xd4>
  801c82:	b8 01 00 00 00       	mov    $0x1,%eax
  801c87:	eb cb                	jmp    801c54 <__udivdi3+0xd4>
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	31 ff                	xor    %edi,%edi
  801c94:	eb be                	jmp    801c54 <__udivdi3+0xd4>
  801c96:	66 90                	xchg   %ax,%ax
  801c98:	66 90                	xchg   %ax,%ax
  801c9a:	66 90                	xchg   %ax,%ax
  801c9c:	66 90                	xchg   %ax,%ax
  801c9e:	66 90                	xchg   %ax,%ax

00801ca0 <__umoddi3>:
  801ca0:	55                   	push   %ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 1c             	sub    $0x1c,%esp
  801ca7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801cab:	8b 74 24 30          	mov    0x30(%esp),%esi
  801caf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cb7:	85 ed                	test   %ebp,%ebp
  801cb9:	89 f0                	mov    %esi,%eax
  801cbb:	89 da                	mov    %ebx,%edx
  801cbd:	75 19                	jne    801cd8 <__umoddi3+0x38>
  801cbf:	39 df                	cmp    %ebx,%edi
  801cc1:	0f 86 b1 00 00 00    	jbe    801d78 <__umoddi3+0xd8>
  801cc7:	f7 f7                	div    %edi
  801cc9:	89 d0                	mov    %edx,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	83 c4 1c             	add    $0x1c,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
  801cd8:	39 dd                	cmp    %ebx,%ebp
  801cda:	77 f1                	ja     801ccd <__umoddi3+0x2d>
  801cdc:	0f bd cd             	bsr    %ebp,%ecx
  801cdf:	83 f1 1f             	xor    $0x1f,%ecx
  801ce2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ce6:	0f 84 b4 00 00 00    	je     801da0 <__umoddi3+0x100>
  801cec:	b8 20 00 00 00       	mov    $0x20,%eax
  801cf1:	89 c2                	mov    %eax,%edx
  801cf3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cf7:	29 c2                	sub    %eax,%edx
  801cf9:	89 c1                	mov    %eax,%ecx
  801cfb:	89 f8                	mov    %edi,%eax
  801cfd:	d3 e5                	shl    %cl,%ebp
  801cff:	89 d1                	mov    %edx,%ecx
  801d01:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d05:	d3 e8                	shr    %cl,%eax
  801d07:	09 c5                	or     %eax,%ebp
  801d09:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d0d:	89 c1                	mov    %eax,%ecx
  801d0f:	d3 e7                	shl    %cl,%edi
  801d11:	89 d1                	mov    %edx,%ecx
  801d13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d17:	89 df                	mov    %ebx,%edi
  801d19:	d3 ef                	shr    %cl,%edi
  801d1b:	89 c1                	mov    %eax,%ecx
  801d1d:	89 f0                	mov    %esi,%eax
  801d1f:	d3 e3                	shl    %cl,%ebx
  801d21:	89 d1                	mov    %edx,%ecx
  801d23:	89 fa                	mov    %edi,%edx
  801d25:	d3 e8                	shr    %cl,%eax
  801d27:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d2c:	09 d8                	or     %ebx,%eax
  801d2e:	f7 f5                	div    %ebp
  801d30:	d3 e6                	shl    %cl,%esi
  801d32:	89 d1                	mov    %edx,%ecx
  801d34:	f7 64 24 08          	mull   0x8(%esp)
  801d38:	39 d1                	cmp    %edx,%ecx
  801d3a:	89 c3                	mov    %eax,%ebx
  801d3c:	89 d7                	mov    %edx,%edi
  801d3e:	72 06                	jb     801d46 <__umoddi3+0xa6>
  801d40:	75 0e                	jne    801d50 <__umoddi3+0xb0>
  801d42:	39 c6                	cmp    %eax,%esi
  801d44:	73 0a                	jae    801d50 <__umoddi3+0xb0>
  801d46:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d4a:	19 ea                	sbb    %ebp,%edx
  801d4c:	89 d7                	mov    %edx,%edi
  801d4e:	89 c3                	mov    %eax,%ebx
  801d50:	89 ca                	mov    %ecx,%edx
  801d52:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d57:	29 de                	sub    %ebx,%esi
  801d59:	19 fa                	sbb    %edi,%edx
  801d5b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d5f:	89 d0                	mov    %edx,%eax
  801d61:	d3 e0                	shl    %cl,%eax
  801d63:	89 d9                	mov    %ebx,%ecx
  801d65:	d3 ee                	shr    %cl,%esi
  801d67:	d3 ea                	shr    %cl,%edx
  801d69:	09 f0                	or     %esi,%eax
  801d6b:	83 c4 1c             	add    $0x1c,%esp
  801d6e:	5b                   	pop    %ebx
  801d6f:	5e                   	pop    %esi
  801d70:	5f                   	pop    %edi
  801d71:	5d                   	pop    %ebp
  801d72:	c3                   	ret    
  801d73:	90                   	nop
  801d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d78:	85 ff                	test   %edi,%edi
  801d7a:	89 f9                	mov    %edi,%ecx
  801d7c:	75 0b                	jne    801d89 <__umoddi3+0xe9>
  801d7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f7                	div    %edi
  801d87:	89 c1                	mov    %eax,%ecx
  801d89:	89 d8                	mov    %ebx,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	f7 f1                	div    %ecx
  801d8f:	89 f0                	mov    %esi,%eax
  801d91:	f7 f1                	div    %ecx
  801d93:	e9 31 ff ff ff       	jmp    801cc9 <__umoddi3+0x29>
  801d98:	90                   	nop
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	39 dd                	cmp    %ebx,%ebp
  801da2:	72 08                	jb     801dac <__umoddi3+0x10c>
  801da4:	39 f7                	cmp    %esi,%edi
  801da6:	0f 87 21 ff ff ff    	ja     801ccd <__umoddi3+0x2d>
  801dac:	89 da                	mov    %ebx,%edx
  801dae:	89 f0                	mov    %esi,%eax
  801db0:	29 f8                	sub    %edi,%eax
  801db2:	19 ea                	sbb    %ebp,%edx
  801db4:	e9 14 ff ff ff       	jmp    801ccd <__umoddi3+0x2d>
