
obj/user/fairness.debug：     文件格式 elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 30 0b 00 00       	call   800b70 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 41 0d 00 00       	call   800d9f <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 20 1e 80 00       	push   $0x801e20
  80006a:	e8 27 01 00 00       	call   800196 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 31 1e 80 00       	push   $0x801e31
  800083:	e8 0e 01 00 00       	call   800196 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 6a 0d 00 00       	call   800e06 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000ac:	e8 bf 0a 00 00       	call   800b70 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 77 0f 00 00       	call   801069 <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 33 0a 00 00       	call   800b2f <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	74 09                	je     800129 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800120:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800124:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800127:	c9                   	leave  
  800128:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	68 ff 00 00 00       	push   $0xff
  800131:	8d 43 08             	lea    0x8(%ebx),%eax
  800134:	50                   	push   %eax
  800135:	e8 b8 09 00 00       	call   800af2 <sys_cputs>
		b->idx = 0;
  80013a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	eb db                	jmp    800120 <putch+0x1f>

00800145 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800155:	00 00 00 
	b.cnt = 0;
  800158:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800162:	ff 75 0c             	pushl  0xc(%ebp)
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016e:	50                   	push   %eax
  80016f:	68 01 01 80 00       	push   $0x800101
  800174:	e8 1a 01 00 00       	call   800293 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800179:	83 c4 08             	add    $0x8,%esp
  80017c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800182:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	e8 64 09 00 00       	call   800af2 <sys_cputs>

	return b.cnt;
}
  80018e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800194:	c9                   	leave  
  800195:	c3                   	ret    

00800196 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019f:	50                   	push   %eax
  8001a0:	ff 75 08             	pushl  0x8(%ebp)
  8001a3:	e8 9d ff ff ff       	call   800145 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	57                   	push   %edi
  8001ae:	56                   	push   %esi
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 1c             	sub    $0x1c,%esp
  8001b3:	89 c7                	mov    %eax,%edi
  8001b5:	89 d6                	mov    %edx,%esi
  8001b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ce:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d1:	39 d3                	cmp    %edx,%ebx
  8001d3:	72 05                	jb     8001da <printnum+0x30>
  8001d5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d8:	77 7a                	ja     800254 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	ff 75 18             	pushl  0x18(%ebp)
  8001e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e6:	53                   	push   %ebx
  8001e7:	ff 75 10             	pushl  0x10(%ebp)
  8001ea:	83 ec 08             	sub    $0x8,%esp
  8001ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f9:	e8 d2 19 00 00       	call   801bd0 <__udivdi3>
  8001fe:	83 c4 18             	add    $0x18,%esp
  800201:	52                   	push   %edx
  800202:	50                   	push   %eax
  800203:	89 f2                	mov    %esi,%edx
  800205:	89 f8                	mov    %edi,%eax
  800207:	e8 9e ff ff ff       	call   8001aa <printnum>
  80020c:	83 c4 20             	add    $0x20,%esp
  80020f:	eb 13                	jmp    800224 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	ff 75 18             	pushl  0x18(%ebp)
  800218:	ff d7                	call   *%edi
  80021a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80021d:	83 eb 01             	sub    $0x1,%ebx
  800220:	85 db                	test   %ebx,%ebx
  800222:	7f ed                	jg     800211 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	83 ec 04             	sub    $0x4,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 b4 1a 00 00       	call   801cf0 <__umoddi3>
  80023c:	83 c4 14             	add    $0x14,%esp
  80023f:	0f be 80 52 1e 80 00 	movsbl 0x801e52(%eax),%eax
  800246:	50                   	push   %eax
  800247:	ff d7                	call   *%edi
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    
  800254:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800257:	eb c4                	jmp    80021d <printnum+0x73>

00800259 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800263:	8b 10                	mov    (%eax),%edx
  800265:	3b 50 04             	cmp    0x4(%eax),%edx
  800268:	73 0a                	jae    800274 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 45 08             	mov    0x8(%ebp),%eax
  800272:	88 02                	mov    %al,(%edx)
}
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <printfmt>:
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80027c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027f:	50                   	push   %eax
  800280:	ff 75 10             	pushl  0x10(%ebp)
  800283:	ff 75 0c             	pushl  0xc(%ebp)
  800286:	ff 75 08             	pushl  0x8(%ebp)
  800289:	e8 05 00 00 00       	call   800293 <vprintfmt>
}
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <vprintfmt>:
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	57                   	push   %edi
  800297:	56                   	push   %esi
  800298:	53                   	push   %ebx
  800299:	83 ec 2c             	sub    $0x2c,%esp
  80029c:	8b 75 08             	mov    0x8(%ebp),%esi
  80029f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a5:	e9 c1 03 00 00       	jmp    80066b <vprintfmt+0x3d8>
		padc = ' ';
  8002aa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002b5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002c3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c8:	8d 47 01             	lea    0x1(%edi),%eax
  8002cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ce:	0f b6 17             	movzbl (%edi),%edx
  8002d1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002d4:	3c 55                	cmp    $0x55,%al
  8002d6:	0f 87 12 04 00 00    	ja     8006ee <vprintfmt+0x45b>
  8002dc:	0f b6 c0             	movzbl %al,%eax
  8002df:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  8002e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002e9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002ed:	eb d9                	jmp    8002c8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002f2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f6:	eb d0                	jmp    8002c8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002f8:	0f b6 d2             	movzbl %dl,%edx
  8002fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800303:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800306:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800309:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80030d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800310:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800313:	83 f9 09             	cmp    $0x9,%ecx
  800316:	77 55                	ja     80036d <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800318:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80031b:	eb e9                	jmp    800306 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8b 00                	mov    (%eax),%eax
  800322:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800325:	8b 45 14             	mov    0x14(%ebp),%eax
  800328:	8d 40 04             	lea    0x4(%eax),%eax
  80032b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800331:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800335:	79 91                	jns    8002c8 <vprintfmt+0x35>
				width = precision, precision = -1;
  800337:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80033a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800344:	eb 82                	jmp    8002c8 <vprintfmt+0x35>
  800346:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800349:	85 c0                	test   %eax,%eax
  80034b:	ba 00 00 00 00       	mov    $0x0,%edx
  800350:	0f 49 d0             	cmovns %eax,%edx
  800353:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800359:	e9 6a ff ff ff       	jmp    8002c8 <vprintfmt+0x35>
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800361:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800368:	e9 5b ff ff ff       	jmp    8002c8 <vprintfmt+0x35>
  80036d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800370:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800373:	eb bc                	jmp    800331 <vprintfmt+0x9e>
			lflag++;
  800375:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80037b:	e9 48 ff ff ff       	jmp    8002c8 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 78 04             	lea    0x4(%eax),%edi
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	53                   	push   %ebx
  80038a:	ff 30                	pushl  (%eax)
  80038c:	ff d6                	call   *%esi
			break;
  80038e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800391:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800394:	e9 cf 02 00 00       	jmp    800668 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800399:	8b 45 14             	mov    0x14(%ebp),%eax
  80039c:	8d 78 04             	lea    0x4(%eax),%edi
  80039f:	8b 00                	mov    (%eax),%eax
  8003a1:	99                   	cltd   
  8003a2:	31 d0                	xor    %edx,%eax
  8003a4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a6:	83 f8 0f             	cmp    $0xf,%eax
  8003a9:	7f 23                	jg     8003ce <vprintfmt+0x13b>
  8003ab:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  8003b2:	85 d2                	test   %edx,%edx
  8003b4:	74 18                	je     8003ce <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003b6:	52                   	push   %edx
  8003b7:	68 51 22 80 00       	push   $0x802251
  8003bc:	53                   	push   %ebx
  8003bd:	56                   	push   %esi
  8003be:	e8 b3 fe ff ff       	call   800276 <printfmt>
  8003c3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c9:	e9 9a 02 00 00       	jmp    800668 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003ce:	50                   	push   %eax
  8003cf:	68 6a 1e 80 00       	push   $0x801e6a
  8003d4:	53                   	push   %ebx
  8003d5:	56                   	push   %esi
  8003d6:	e8 9b fe ff ff       	call   800276 <printfmt>
  8003db:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003de:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003e1:	e9 82 02 00 00       	jmp    800668 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	83 c0 04             	add    $0x4,%eax
  8003ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f4:	85 ff                	test   %edi,%edi
  8003f6:	b8 63 1e 80 00       	mov    $0x801e63,%eax
  8003fb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800402:	0f 8e bd 00 00 00    	jle    8004c5 <vprintfmt+0x232>
  800408:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80040c:	75 0e                	jne    80041c <vprintfmt+0x189>
  80040e:	89 75 08             	mov    %esi,0x8(%ebp)
  800411:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800414:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800417:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80041a:	eb 6d                	jmp    800489 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	ff 75 d0             	pushl  -0x30(%ebp)
  800422:	57                   	push   %edi
  800423:	e8 6e 03 00 00       	call   800796 <strnlen>
  800428:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80042b:	29 c1                	sub    %eax,%ecx
  80042d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800430:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800433:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800437:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043d:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80043f:	eb 0f                	jmp    800450 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	53                   	push   %ebx
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80044a:	83 ef 01             	sub    $0x1,%edi
  80044d:	83 c4 10             	add    $0x10,%esp
  800450:	85 ff                	test   %edi,%edi
  800452:	7f ed                	jg     800441 <vprintfmt+0x1ae>
  800454:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800457:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80045a:	85 c9                	test   %ecx,%ecx
  80045c:	b8 00 00 00 00       	mov    $0x0,%eax
  800461:	0f 49 c1             	cmovns %ecx,%eax
  800464:	29 c1                	sub    %eax,%ecx
  800466:	89 75 08             	mov    %esi,0x8(%ebp)
  800469:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046f:	89 cb                	mov    %ecx,%ebx
  800471:	eb 16                	jmp    800489 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800473:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800477:	75 31                	jne    8004aa <vprintfmt+0x217>
					putch(ch, putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	ff 75 0c             	pushl  0xc(%ebp)
  80047f:	50                   	push   %eax
  800480:	ff 55 08             	call   *0x8(%ebp)
  800483:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800486:	83 eb 01             	sub    $0x1,%ebx
  800489:	83 c7 01             	add    $0x1,%edi
  80048c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800490:	0f be c2             	movsbl %dl,%eax
  800493:	85 c0                	test   %eax,%eax
  800495:	74 59                	je     8004f0 <vprintfmt+0x25d>
  800497:	85 f6                	test   %esi,%esi
  800499:	78 d8                	js     800473 <vprintfmt+0x1e0>
  80049b:	83 ee 01             	sub    $0x1,%esi
  80049e:	79 d3                	jns    800473 <vprintfmt+0x1e0>
  8004a0:	89 df                	mov    %ebx,%edi
  8004a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a8:	eb 37                	jmp    8004e1 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004aa:	0f be d2             	movsbl %dl,%edx
  8004ad:	83 ea 20             	sub    $0x20,%edx
  8004b0:	83 fa 5e             	cmp    $0x5e,%edx
  8004b3:	76 c4                	jbe    800479 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	ff 75 0c             	pushl  0xc(%ebp)
  8004bb:	6a 3f                	push   $0x3f
  8004bd:	ff 55 08             	call   *0x8(%ebp)
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	eb c1                	jmp    800486 <vprintfmt+0x1f3>
  8004c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ce:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d1:	eb b6                	jmp    800489 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	53                   	push   %ebx
  8004d7:	6a 20                	push   $0x20
  8004d9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004db:	83 ef 01             	sub    $0x1,%edi
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	85 ff                	test   %edi,%edi
  8004e3:	7f ee                	jg     8004d3 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004eb:	e9 78 01 00 00       	jmp    800668 <vprintfmt+0x3d5>
  8004f0:	89 df                	mov    %ebx,%edi
  8004f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f8:	eb e7                	jmp    8004e1 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004fa:	83 f9 01             	cmp    $0x1,%ecx
  8004fd:	7e 3f                	jle    80053e <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8b 50 04             	mov    0x4(%eax),%edx
  800505:	8b 00                	mov    (%eax),%eax
  800507:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 40 08             	lea    0x8(%eax),%eax
  800513:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800516:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80051a:	79 5c                	jns    800578 <vprintfmt+0x2e5>
				putch('-', putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	53                   	push   %ebx
  800520:	6a 2d                	push   $0x2d
  800522:	ff d6                	call   *%esi
				num = -(long long) num;
  800524:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800527:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80052a:	f7 da                	neg    %edx
  80052c:	83 d1 00             	adc    $0x0,%ecx
  80052f:	f7 d9                	neg    %ecx
  800531:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800534:	b8 0a 00 00 00       	mov    $0xa,%eax
  800539:	e9 10 01 00 00       	jmp    80064e <vprintfmt+0x3bb>
	else if (lflag)
  80053e:	85 c9                	test   %ecx,%ecx
  800540:	75 1b                	jne    80055d <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8b 00                	mov    (%eax),%eax
  800547:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054a:	89 c1                	mov    %eax,%ecx
  80054c:	c1 f9 1f             	sar    $0x1f,%ecx
  80054f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 40 04             	lea    0x4(%eax),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	eb b9                	jmp    800516 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 c1                	mov    %eax,%ecx
  800567:	c1 f9 1f             	sar    $0x1f,%ecx
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
  800576:	eb 9e                	jmp    800516 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800578:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80057e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800583:	e9 c6 00 00 00       	jmp    80064e <vprintfmt+0x3bb>
	if (lflag >= 2)
  800588:	83 f9 01             	cmp    $0x1,%ecx
  80058b:	7e 18                	jle    8005a5 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8b 48 04             	mov    0x4(%eax),%ecx
  800595:	8d 40 08             	lea    0x8(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a0:	e9 a9 00 00 00       	jmp    80064e <vprintfmt+0x3bb>
	else if (lflag)
  8005a5:	85 c9                	test   %ecx,%ecx
  8005a7:	75 1a                	jne    8005c3 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b3:	8d 40 04             	lea    0x4(%eax),%eax
  8005b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005be:	e9 8b 00 00 00       	jmp    80064e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cd:	8d 40 04             	lea    0x4(%eax),%eax
  8005d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d8:	eb 74                	jmp    80064e <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005da:	83 f9 01             	cmp    $0x1,%ecx
  8005dd:	7e 15                	jle    8005f4 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005ed:	b8 08 00 00 00       	mov    $0x8,%eax
  8005f2:	eb 5a                	jmp    80064e <vprintfmt+0x3bb>
	else if (lflag)
  8005f4:	85 c9                	test   %ecx,%ecx
  8005f6:	75 17                	jne    80060f <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800602:	8d 40 04             	lea    0x4(%eax),%eax
  800605:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800608:	b8 08 00 00 00       	mov    $0x8,%eax
  80060d:	eb 3f                	jmp    80064e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 10                	mov    (%eax),%edx
  800614:	b9 00 00 00 00       	mov    $0x0,%ecx
  800619:	8d 40 04             	lea    0x4(%eax),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80061f:	b8 08 00 00 00       	mov    $0x8,%eax
  800624:	eb 28                	jmp    80064e <vprintfmt+0x3bb>
			putch('0', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 30                	push   $0x30
  80062c:	ff d6                	call   *%esi
			putch('x', putdat);
  80062e:	83 c4 08             	add    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 78                	push   $0x78
  800634:	ff d6                	call   *%esi
			num = (unsigned long long)
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800640:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800643:	8d 40 04             	lea    0x4(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800649:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80064e:	83 ec 0c             	sub    $0xc,%esp
  800651:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800655:	57                   	push   %edi
  800656:	ff 75 e0             	pushl  -0x20(%ebp)
  800659:	50                   	push   %eax
  80065a:	51                   	push   %ecx
  80065b:	52                   	push   %edx
  80065c:	89 da                	mov    %ebx,%edx
  80065e:	89 f0                	mov    %esi,%eax
  800660:	e8 45 fb ff ff       	call   8001aa <printnum>
			break;
  800665:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066b:	83 c7 01             	add    $0x1,%edi
  80066e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800672:	83 f8 25             	cmp    $0x25,%eax
  800675:	0f 84 2f fc ff ff    	je     8002aa <vprintfmt+0x17>
			if (ch == '\0')
  80067b:	85 c0                	test   %eax,%eax
  80067d:	0f 84 8b 00 00 00    	je     80070e <vprintfmt+0x47b>
			putch(ch, putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	50                   	push   %eax
  800688:	ff d6                	call   *%esi
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	eb dc                	jmp    80066b <vprintfmt+0x3d8>
	if (lflag >= 2)
  80068f:	83 f9 01             	cmp    $0x1,%ecx
  800692:	7e 15                	jle    8006a9 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 10                	mov    (%eax),%edx
  800699:	8b 48 04             	mov    0x4(%eax),%ecx
  80069c:	8d 40 08             	lea    0x8(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a2:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a7:	eb a5                	jmp    80064e <vprintfmt+0x3bb>
	else if (lflag)
  8006a9:	85 c9                	test   %ecx,%ecx
  8006ab:	75 17                	jne    8006c4 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bd:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c2:	eb 8a                	jmp    80064e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
  8006c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ce:	8d 40 04             	lea    0x4(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d9:	e9 70 ff ff ff       	jmp    80064e <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	53                   	push   %ebx
  8006e2:	6a 25                	push   $0x25
  8006e4:	ff d6                	call   *%esi
			break;
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	e9 7a ff ff ff       	jmp    800668 <vprintfmt+0x3d5>
			putch('%', putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 25                	push   $0x25
  8006f4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	89 f8                	mov    %edi,%eax
  8006fb:	eb 03                	jmp    800700 <vprintfmt+0x46d>
  8006fd:	83 e8 01             	sub    $0x1,%eax
  800700:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800704:	75 f7                	jne    8006fd <vprintfmt+0x46a>
  800706:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800709:	e9 5a ff ff ff       	jmp    800668 <vprintfmt+0x3d5>
}
  80070e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	83 ec 18             	sub    $0x18,%esp
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800722:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800725:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800729:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800733:	85 c0                	test   %eax,%eax
  800735:	74 26                	je     80075d <vsnprintf+0x47>
  800737:	85 d2                	test   %edx,%edx
  800739:	7e 22                	jle    80075d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073b:	ff 75 14             	pushl  0x14(%ebp)
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800744:	50                   	push   %eax
  800745:	68 59 02 80 00       	push   $0x800259
  80074a:	e8 44 fb ff ff       	call   800293 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800752:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800758:	83 c4 10             	add    $0x10,%esp
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    
		return -E_INVAL;
  80075d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800762:	eb f7                	jmp    80075b <vsnprintf+0x45>

00800764 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076d:	50                   	push   %eax
  80076e:	ff 75 10             	pushl  0x10(%ebp)
  800771:	ff 75 0c             	pushl  0xc(%ebp)
  800774:	ff 75 08             	pushl  0x8(%ebp)
  800777:	e8 9a ff ff ff       	call   800716 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    

0080077e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	eb 03                	jmp    80078e <strlen+0x10>
		n++;
  80078b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80078e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800792:	75 f7                	jne    80078b <strlen+0xd>
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a4:	eb 03                	jmp    8007a9 <strnlen+0x13>
		n++;
  8007a6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a9:	39 d0                	cmp    %edx,%eax
  8007ab:	74 06                	je     8007b3 <strnlen+0x1d>
  8007ad:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b1:	75 f3                	jne    8007a6 <strnlen+0x10>
	return n;
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	53                   	push   %ebx
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bf:	89 c2                	mov    %eax,%edx
  8007c1:	83 c1 01             	add    $0x1,%ecx
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ce:	84 db                	test   %bl,%bl
  8007d0:	75 ef                	jne    8007c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dc:	53                   	push   %ebx
  8007dd:	e8 9c ff ff ff       	call   80077e <strlen>
  8007e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	01 d8                	add    %ebx,%eax
  8007ea:	50                   	push   %eax
  8007eb:	e8 c5 ff ff ff       	call   8007b5 <strcpy>
	return dst;
}
  8007f0:	89 d8                	mov    %ebx,%eax
  8007f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	89 f3                	mov    %esi,%ebx
  800804:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	89 f2                	mov    %esi,%edx
  800809:	eb 0f                	jmp    80081a <strncpy+0x23>
		*dst++ = *src;
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	0f b6 01             	movzbl (%ecx),%eax
  800811:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800814:	80 39 01             	cmpb   $0x1,(%ecx)
  800817:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80081a:	39 da                	cmp    %ebx,%edx
  80081c:	75 ed                	jne    80080b <strncpy+0x14>
	}
	return ret;
}
  80081e:	89 f0                	mov    %esi,%eax
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800832:	89 f0                	mov    %esi,%eax
  800834:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 c9                	test   %ecx,%ecx
  80083a:	75 0b                	jne    800847 <strlcpy+0x23>
  80083c:	eb 17                	jmp    800855 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083e:	83 c2 01             	add    $0x1,%edx
  800841:	83 c0 01             	add    $0x1,%eax
  800844:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800847:	39 d8                	cmp    %ebx,%eax
  800849:	74 07                	je     800852 <strlcpy+0x2e>
  80084b:	0f b6 0a             	movzbl (%edx),%ecx
  80084e:	84 c9                	test   %cl,%cl
  800850:	75 ec                	jne    80083e <strlcpy+0x1a>
		*dst = '\0';
  800852:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800855:	29 f0                	sub    %esi,%eax
}
  800857:	5b                   	pop    %ebx
  800858:	5e                   	pop    %esi
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800864:	eb 06                	jmp    80086c <strcmp+0x11>
		p++, q++;
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80086c:	0f b6 01             	movzbl (%ecx),%eax
  80086f:	84 c0                	test   %al,%al
  800871:	74 04                	je     800877 <strcmp+0x1c>
  800873:	3a 02                	cmp    (%edx),%al
  800875:	74 ef                	je     800866 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	0f b6 12             	movzbl (%edx),%edx
  80087d:	29 d0                	sub    %edx,%eax
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	53                   	push   %ebx
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088b:	89 c3                	mov    %eax,%ebx
  80088d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800890:	eb 06                	jmp    800898 <strncmp+0x17>
		n--, p++, q++;
  800892:	83 c0 01             	add    $0x1,%eax
  800895:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800898:	39 d8                	cmp    %ebx,%eax
  80089a:	74 16                	je     8008b2 <strncmp+0x31>
  80089c:	0f b6 08             	movzbl (%eax),%ecx
  80089f:	84 c9                	test   %cl,%cl
  8008a1:	74 04                	je     8008a7 <strncmp+0x26>
  8008a3:	3a 0a                	cmp    (%edx),%cl
  8008a5:	74 eb                	je     800892 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a7:	0f b6 00             	movzbl (%eax),%eax
  8008aa:	0f b6 12             	movzbl (%edx),%edx
  8008ad:	29 d0                	sub    %edx,%eax
}
  8008af:	5b                   	pop    %ebx
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    
		return 0;
  8008b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b7:	eb f6                	jmp    8008af <strncmp+0x2e>

008008b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c3:	0f b6 10             	movzbl (%eax),%edx
  8008c6:	84 d2                	test   %dl,%dl
  8008c8:	74 09                	je     8008d3 <strchr+0x1a>
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 0a                	je     8008d8 <strchr+0x1f>
	for (; *s; s++)
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	eb f0                	jmp    8008c3 <strchr+0xa>
			return (char *) s;
	return 0;
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e4:	eb 03                	jmp    8008e9 <strfind+0xf>
  8008e6:	83 c0 01             	add    $0x1,%eax
  8008e9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	74 04                	je     8008f4 <strfind+0x1a>
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	75 f2                	jne    8008e6 <strfind+0xc>
			break;
	return (char *) s;
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	57                   	push   %edi
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
  8008fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800902:	85 c9                	test   %ecx,%ecx
  800904:	74 13                	je     800919 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800906:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090c:	75 05                	jne    800913 <memset+0x1d>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	74 0d                	je     800920 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800913:	8b 45 0c             	mov    0xc(%ebp),%eax
  800916:	fc                   	cld    
  800917:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800919:	89 f8                	mov    %edi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    
		c &= 0xFF;
  800920:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800924:	89 d3                	mov    %edx,%ebx
  800926:	c1 e3 08             	shl    $0x8,%ebx
  800929:	89 d0                	mov    %edx,%eax
  80092b:	c1 e0 18             	shl    $0x18,%eax
  80092e:	89 d6                	mov    %edx,%esi
  800930:	c1 e6 10             	shl    $0x10,%esi
  800933:	09 f0                	or     %esi,%eax
  800935:	09 c2                	or     %eax,%edx
  800937:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800939:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80093c:	89 d0                	mov    %edx,%eax
  80093e:	fc                   	cld    
  80093f:	f3 ab                	rep stos %eax,%es:(%edi)
  800941:	eb d6                	jmp    800919 <memset+0x23>

00800943 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	57                   	push   %edi
  800947:	56                   	push   %esi
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800951:	39 c6                	cmp    %eax,%esi
  800953:	73 35                	jae    80098a <memmove+0x47>
  800955:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800958:	39 c2                	cmp    %eax,%edx
  80095a:	76 2e                	jbe    80098a <memmove+0x47>
		s += n;
		d += n;
  80095c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095f:	89 d6                	mov    %edx,%esi
  800961:	09 fe                	or     %edi,%esi
  800963:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800969:	74 0c                	je     800977 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096b:	83 ef 01             	sub    $0x1,%edi
  80096e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800971:	fd                   	std    
  800972:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800974:	fc                   	cld    
  800975:	eb 21                	jmp    800998 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800977:	f6 c1 03             	test   $0x3,%cl
  80097a:	75 ef                	jne    80096b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80097c:	83 ef 04             	sub    $0x4,%edi
  80097f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800982:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800985:	fd                   	std    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb ea                	jmp    800974 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	89 f2                	mov    %esi,%edx
  80098c:	09 c2                	or     %eax,%edx
  80098e:	f6 c2 03             	test   $0x3,%dl
  800991:	74 09                	je     80099c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800993:	89 c7                	mov    %eax,%edi
  800995:	fc                   	cld    
  800996:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800998:	5e                   	pop    %esi
  800999:	5f                   	pop    %edi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 f2                	jne    800993 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb ed                	jmp    800998 <memmove+0x55>

008009ab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ae:	ff 75 10             	pushl  0x10(%ebp)
  8009b1:	ff 75 0c             	pushl  0xc(%ebp)
  8009b4:	ff 75 08             	pushl  0x8(%ebp)
  8009b7:	e8 87 ff ff ff       	call   800943 <memmove>
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c9:	89 c6                	mov    %eax,%esi
  8009cb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ce:	39 f0                	cmp    %esi,%eax
  8009d0:	74 1c                	je     8009ee <memcmp+0x30>
		if (*s1 != *s2)
  8009d2:	0f b6 08             	movzbl (%eax),%ecx
  8009d5:	0f b6 1a             	movzbl (%edx),%ebx
  8009d8:	38 d9                	cmp    %bl,%cl
  8009da:	75 08                	jne    8009e4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	83 c2 01             	add    $0x1,%edx
  8009e2:	eb ea                	jmp    8009ce <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009e4:	0f b6 c1             	movzbl %cl,%eax
  8009e7:	0f b6 db             	movzbl %bl,%ebx
  8009ea:	29 d8                	sub    %ebx,%eax
  8009ec:	eb 05                	jmp    8009f3 <memcmp+0x35>
	}

	return 0;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a00:	89 c2                	mov    %eax,%edx
  800a02:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a05:	39 d0                	cmp    %edx,%eax
  800a07:	73 09                	jae    800a12 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a09:	38 08                	cmp    %cl,(%eax)
  800a0b:	74 05                	je     800a12 <memfind+0x1b>
	for (; s < ends; s++)
  800a0d:	83 c0 01             	add    $0x1,%eax
  800a10:	eb f3                	jmp    800a05 <memfind+0xe>
			break;
	return (void *) s;
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x11>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0xe>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	74 2e                	je     800a62 <strtol+0x4e>
	int neg = 0;
  800a34:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a39:	3c 2d                	cmp    $0x2d,%al
  800a3b:	74 2f                	je     800a6c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a43:	75 05                	jne    800a4a <strtol+0x36>
  800a45:	80 39 30             	cmpb   $0x30,(%ecx)
  800a48:	74 2c                	je     800a76 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	75 0a                	jne    800a58 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a53:	80 39 30             	cmpb   $0x30,(%ecx)
  800a56:	74 28                	je     800a80 <strtol+0x6c>
		base = 10;
  800a58:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a60:	eb 50                	jmp    800ab2 <strtol+0x9e>
		s++;
  800a62:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a65:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6a:	eb d1                	jmp    800a3d <strtol+0x29>
		s++, neg = 1;
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a74:	eb c7                	jmp    800a3d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a76:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a7a:	74 0e                	je     800a8a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a7c:	85 db                	test   %ebx,%ebx
  800a7e:	75 d8                	jne    800a58 <strtol+0x44>
		s++, base = 8;
  800a80:	83 c1 01             	add    $0x1,%ecx
  800a83:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a88:	eb ce                	jmp    800a58 <strtol+0x44>
		s += 2, base = 16;
  800a8a:	83 c1 02             	add    $0x2,%ecx
  800a8d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a92:	eb c4                	jmp    800a58 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a94:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a97:	89 f3                	mov    %esi,%ebx
  800a99:	80 fb 19             	cmp    $0x19,%bl
  800a9c:	77 29                	ja     800ac7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a9e:	0f be d2             	movsbl %dl,%edx
  800aa1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa7:	7d 30                	jge    800ad9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aa9:	83 c1 01             	add    $0x1,%ecx
  800aac:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ab2:	0f b6 11             	movzbl (%ecx),%edx
  800ab5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab8:	89 f3                	mov    %esi,%ebx
  800aba:	80 fb 09             	cmp    $0x9,%bl
  800abd:	77 d5                	ja     800a94 <strtol+0x80>
			dig = *s - '0';
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 30             	sub    $0x30,%edx
  800ac5:	eb dd                	jmp    800aa4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ac7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 19             	cmp    $0x19,%bl
  800acf:	77 08                	ja     800ad9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 37             	sub    $0x37,%edx
  800ad7:	eb cb                	jmp    800aa4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800add:	74 05                	je     800ae4 <strtol+0xd0>
		*endptr = (char *) s;
  800adf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ae4:	89 c2                	mov    %eax,%edx
  800ae6:	f7 da                	neg    %edx
  800ae8:	85 ff                	test   %edi,%edi
  800aea:	0f 45 c2             	cmovne %edx,%eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b40:	b8 03 00 00 00       	mov    $0x3,%eax
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7f 08                	jg     800b59 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	50                   	push   %eax
  800b5d:	6a 03                	push   $0x3
  800b5f:	68 5f 21 80 00       	push   $0x80215f
  800b64:	6a 23                	push   $0x23
  800b66:	68 7c 21 80 00       	push   $0x80217c
  800b6b:	e8 d1 0f 00 00       	call   801b41 <_panic>

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_yield>:

void
sys_yield(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7f 08                	jg     800bda <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800bde:	6a 04                	push   $0x4
  800be0:	68 5f 21 80 00       	push   $0x80215f
  800be5:	6a 23                	push   $0x23
  800be7:	68 7c 21 80 00       	push   $0x80217c
  800bec:	e8 50 0f 00 00       	call   801b41 <_panic>

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	b8 05 00 00 00       	mov    $0x5,%eax
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 05                	push   $0x5
  800c22:	68 5f 21 80 00       	push   $0x80215f
  800c27:	6a 23                	push   $0x23
  800c29:	68 7c 21 80 00       	push   $0x80217c
  800c2e:	e8 0e 0f 00 00       	call   801b41 <_panic>

00800c33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7f 08                	jg     800c5e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 06                	push   $0x6
  800c64:	68 5f 21 80 00       	push   $0x80215f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 7c 21 80 00       	push   $0x80217c
  800c70:	e8 cc 0e 00 00       	call   801b41 <_panic>

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 08                	push   $0x8
  800ca6:	68 5f 21 80 00       	push   $0x80215f
  800cab:	6a 23                	push   $0x23
  800cad:	68 7c 21 80 00       	push   $0x80217c
  800cb2:	e8 8a 0e 00 00       	call   801b41 <_panic>

00800cb7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7f 08                	jg     800ce2 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 09                	push   $0x9
  800ce8:	68 5f 21 80 00       	push   $0x80215f
  800ced:	6a 23                	push   $0x23
  800cef:	68 7c 21 80 00       	push   $0x80217c
  800cf4:	e8 48 0e 00 00       	call   801b41 <_panic>

00800cf9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7f 08                	jg     800d24 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 0a                	push   $0xa
  800d2a:	68 5f 21 80 00       	push   $0x80215f
  800d2f:	6a 23                	push   $0x23
  800d31:	68 7c 21 80 00       	push   $0x80217c
  800d36:	e8 06 0e 00 00       	call   801b41 <_panic>

00800d3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7f 08                	jg     800d88 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 0d                	push   $0xd
  800d8e:	68 5f 21 80 00       	push   $0x80215f
  800d93:	6a 23                	push   $0x23
  800d95:	68 7c 21 80 00       	push   $0x80217c
  800d9a:	e8 a2 0d 00 00       	call   801b41 <_panic>

00800d9f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	8b 75 08             	mov    0x8(%ebp),%esi
  800da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800daa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  800dad:	85 f6                	test   %esi,%esi
  800daf:	74 06                	je     800db7 <ipc_recv+0x18>
  800db1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  800db7:	85 db                	test   %ebx,%ebx
  800db9:	74 06                	je     800dc1 <ipc_recv+0x22>
  800dbb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800dc8:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  800dcb:	83 ec 0c             	sub    $0xc,%esp
  800dce:	50                   	push   %eax
  800dcf:	e8 8a ff ff ff       	call   800d5e <sys_ipc_recv>
	if (ret) return ret;
  800dd4:	83 c4 10             	add    $0x10,%esp
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	75 24                	jne    800dff <ipc_recv+0x60>
	if (from_env_store)
  800ddb:	85 f6                	test   %esi,%esi
  800ddd:	74 0a                	je     800de9 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  800ddf:	a1 04 40 80 00       	mov    0x804004,%eax
  800de4:	8b 40 74             	mov    0x74(%eax),%eax
  800de7:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  800de9:	85 db                	test   %ebx,%ebx
  800deb:	74 0a                	je     800df7 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  800ded:	a1 04 40 80 00       	mov    0x804004,%eax
  800df2:	8b 40 78             	mov    0x78(%eax),%eax
  800df5:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  800df7:	a1 04 40 80 00       	mov    0x804004,%eax
  800dfc:	8b 40 70             	mov    0x70(%eax),%eax
}
  800dff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 0c             	sub    $0xc,%esp
  800e0f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  800e18:	85 db                	test   %ebx,%ebx
  800e1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e1f:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  800e22:	ff 75 14             	pushl  0x14(%ebp)
  800e25:	53                   	push   %ebx
  800e26:	56                   	push   %esi
  800e27:	57                   	push   %edi
  800e28:	e8 0e ff ff ff       	call   800d3b <sys_ipc_try_send>
  800e2d:	83 c4 10             	add    $0x10,%esp
  800e30:	85 c0                	test   %eax,%eax
  800e32:	74 1e                	je     800e52 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  800e34:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e37:	75 07                	jne    800e40 <ipc_send+0x3a>
		sys_yield();
  800e39:	e8 51 fd ff ff       	call   800b8f <sys_yield>
  800e3e:	eb e2                	jmp    800e22 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  800e40:	50                   	push   %eax
  800e41:	68 8a 21 80 00       	push   $0x80218a
  800e46:	6a 36                	push   $0x36
  800e48:	68 a1 21 80 00       	push   $0x8021a1
  800e4d:	e8 ef 0c 00 00       	call   801b41 <_panic>
	}
}
  800e52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e60:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e65:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e68:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e6e:	8b 52 50             	mov    0x50(%edx),%edx
  800e71:	39 ca                	cmp    %ecx,%edx
  800e73:	74 11                	je     800e86 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800e75:	83 c0 01             	add    $0x1,%eax
  800e78:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e7d:	75 e6                	jne    800e65 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e84:	eb 0b                	jmp    800e91 <ipc_find_env+0x37>
			return envs[i].env_id;
  800e86:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e89:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e8e:	8b 40 48             	mov    0x48(%eax),%eax
}
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e96:	8b 45 08             	mov    0x8(%ebp),%eax
  800e99:	05 00 00 00 30       	add    $0x30000000,%eax
  800e9e:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800eae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eb3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ec5:	89 c2                	mov    %eax,%edx
  800ec7:	c1 ea 16             	shr    $0x16,%edx
  800eca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed1:	f6 c2 01             	test   $0x1,%dl
  800ed4:	74 2a                	je     800f00 <fd_alloc+0x46>
  800ed6:	89 c2                	mov    %eax,%edx
  800ed8:	c1 ea 0c             	shr    $0xc,%edx
  800edb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee2:	f6 c2 01             	test   $0x1,%dl
  800ee5:	74 19                	je     800f00 <fd_alloc+0x46>
  800ee7:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800eec:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef1:	75 d2                	jne    800ec5 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ef9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800efe:	eb 07                	jmp    800f07 <fd_alloc+0x4d>
			*fd_store = fd;
  800f00:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f0f:	83 f8 1f             	cmp    $0x1f,%eax
  800f12:	77 36                	ja     800f4a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f14:	c1 e0 0c             	shl    $0xc,%eax
  800f17:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f1c:	89 c2                	mov    %eax,%edx
  800f1e:	c1 ea 16             	shr    $0x16,%edx
  800f21:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f28:	f6 c2 01             	test   $0x1,%dl
  800f2b:	74 24                	je     800f51 <fd_lookup+0x48>
  800f2d:	89 c2                	mov    %eax,%edx
  800f2f:	c1 ea 0c             	shr    $0xc,%edx
  800f32:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f39:	f6 c2 01             	test   $0x1,%dl
  800f3c:	74 1a                	je     800f58 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f41:	89 02                	mov    %eax,(%edx)
	return 0;
  800f43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    
		return -E_INVAL;
  800f4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4f:	eb f7                	jmp    800f48 <fd_lookup+0x3f>
		return -E_INVAL;
  800f51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f56:	eb f0                	jmp    800f48 <fd_lookup+0x3f>
  800f58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5d:	eb e9                	jmp    800f48 <fd_lookup+0x3f>

00800f5f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 08             	sub    $0x8,%esp
  800f65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f68:	ba 28 22 80 00       	mov    $0x802228,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f6d:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f72:	39 08                	cmp    %ecx,(%eax)
  800f74:	74 33                	je     800fa9 <dev_lookup+0x4a>
  800f76:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f79:	8b 02                	mov    (%edx),%eax
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	75 f3                	jne    800f72 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f7f:	a1 04 40 80 00       	mov    0x804004,%eax
  800f84:	8b 40 48             	mov    0x48(%eax),%eax
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	51                   	push   %ecx
  800f8b:	50                   	push   %eax
  800f8c:	68 ac 21 80 00       	push   $0x8021ac
  800f91:	e8 00 f2 ff ff       	call   800196 <cprintf>
	*dev = 0;
  800f96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fa7:	c9                   	leave  
  800fa8:	c3                   	ret    
			*dev = devtab[i];
  800fa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fac:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fae:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb3:	eb f2                	jmp    800fa7 <dev_lookup+0x48>

00800fb5 <fd_close>:
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	57                   	push   %edi
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
  800fbb:	83 ec 1c             	sub    $0x1c,%esp
  800fbe:	8b 75 08             	mov    0x8(%ebp),%esi
  800fc1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc7:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fc8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fce:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd1:	50                   	push   %eax
  800fd2:	e8 32 ff ff ff       	call   800f09 <fd_lookup>
  800fd7:	89 c3                	mov    %eax,%ebx
  800fd9:	83 c4 08             	add    $0x8,%esp
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	78 05                	js     800fe5 <fd_close+0x30>
	    || fd != fd2)
  800fe0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fe3:	74 16                	je     800ffb <fd_close+0x46>
		return (must_exist ? r : 0);
  800fe5:	89 f8                	mov    %edi,%eax
  800fe7:	84 c0                	test   %al,%al
  800fe9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fee:	0f 44 d8             	cmove  %eax,%ebx
}
  800ff1:	89 d8                	mov    %ebx,%eax
  800ff3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff6:	5b                   	pop    %ebx
  800ff7:	5e                   	pop    %esi
  800ff8:	5f                   	pop    %edi
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ffb:	83 ec 08             	sub    $0x8,%esp
  800ffe:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801001:	50                   	push   %eax
  801002:	ff 36                	pushl  (%esi)
  801004:	e8 56 ff ff ff       	call   800f5f <dev_lookup>
  801009:	89 c3                	mov    %eax,%ebx
  80100b:	83 c4 10             	add    $0x10,%esp
  80100e:	85 c0                	test   %eax,%eax
  801010:	78 15                	js     801027 <fd_close+0x72>
		if (dev->dev_close)
  801012:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801015:	8b 40 10             	mov    0x10(%eax),%eax
  801018:	85 c0                	test   %eax,%eax
  80101a:	74 1b                	je     801037 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	56                   	push   %esi
  801020:	ff d0                	call   *%eax
  801022:	89 c3                	mov    %eax,%ebx
  801024:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801027:	83 ec 08             	sub    $0x8,%esp
  80102a:	56                   	push   %esi
  80102b:	6a 00                	push   $0x0
  80102d:	e8 01 fc ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	eb ba                	jmp    800ff1 <fd_close+0x3c>
			r = 0;
  801037:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103c:	eb e9                	jmp    801027 <fd_close+0x72>

0080103e <close>:

int
close(int fdnum)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801044:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801047:	50                   	push   %eax
  801048:	ff 75 08             	pushl  0x8(%ebp)
  80104b:	e8 b9 fe ff ff       	call   800f09 <fd_lookup>
  801050:	83 c4 08             	add    $0x8,%esp
  801053:	85 c0                	test   %eax,%eax
  801055:	78 10                	js     801067 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801057:	83 ec 08             	sub    $0x8,%esp
  80105a:	6a 01                	push   $0x1
  80105c:	ff 75 f4             	pushl  -0xc(%ebp)
  80105f:	e8 51 ff ff ff       	call   800fb5 <fd_close>
  801064:	83 c4 10             	add    $0x10,%esp
}
  801067:	c9                   	leave  
  801068:	c3                   	ret    

00801069 <close_all>:

void
close_all(void)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	53                   	push   %ebx
  80106d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801070:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	53                   	push   %ebx
  801079:	e8 c0 ff ff ff       	call   80103e <close>
	for (i = 0; i < MAXFD; i++)
  80107e:	83 c3 01             	add    $0x1,%ebx
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	83 fb 20             	cmp    $0x20,%ebx
  801087:	75 ec                	jne    801075 <close_all+0xc>
}
  801089:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108c:	c9                   	leave  
  80108d:	c3                   	ret    

0080108e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	57                   	push   %edi
  801092:	56                   	push   %esi
  801093:	53                   	push   %ebx
  801094:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801097:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80109a:	50                   	push   %eax
  80109b:	ff 75 08             	pushl  0x8(%ebp)
  80109e:	e8 66 fe ff ff       	call   800f09 <fd_lookup>
  8010a3:	89 c3                	mov    %eax,%ebx
  8010a5:	83 c4 08             	add    $0x8,%esp
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	0f 88 81 00 00 00    	js     801131 <dup+0xa3>
		return r;
	close(newfdnum);
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	ff 75 0c             	pushl  0xc(%ebp)
  8010b6:	e8 83 ff ff ff       	call   80103e <close>

	newfd = INDEX2FD(newfdnum);
  8010bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010be:	c1 e6 0c             	shl    $0xc,%esi
  8010c1:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010c7:	83 c4 04             	add    $0x4,%esp
  8010ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010cd:	e8 d1 fd ff ff       	call   800ea3 <fd2data>
  8010d2:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010d4:	89 34 24             	mov    %esi,(%esp)
  8010d7:	e8 c7 fd ff ff       	call   800ea3 <fd2data>
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010e1:	89 d8                	mov    %ebx,%eax
  8010e3:	c1 e8 16             	shr    $0x16,%eax
  8010e6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ed:	a8 01                	test   $0x1,%al
  8010ef:	74 11                	je     801102 <dup+0x74>
  8010f1:	89 d8                	mov    %ebx,%eax
  8010f3:	c1 e8 0c             	shr    $0xc,%eax
  8010f6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010fd:	f6 c2 01             	test   $0x1,%dl
  801100:	75 39                	jne    80113b <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801102:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801105:	89 d0                	mov    %edx,%eax
  801107:	c1 e8 0c             	shr    $0xc,%eax
  80110a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801111:	83 ec 0c             	sub    $0xc,%esp
  801114:	25 07 0e 00 00       	and    $0xe07,%eax
  801119:	50                   	push   %eax
  80111a:	56                   	push   %esi
  80111b:	6a 00                	push   $0x0
  80111d:	52                   	push   %edx
  80111e:	6a 00                	push   $0x0
  801120:	e8 cc fa ff ff       	call   800bf1 <sys_page_map>
  801125:	89 c3                	mov    %eax,%ebx
  801127:	83 c4 20             	add    $0x20,%esp
  80112a:	85 c0                	test   %eax,%eax
  80112c:	78 31                	js     80115f <dup+0xd1>
		goto err;

	return newfdnum;
  80112e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801131:	89 d8                	mov    %ebx,%eax
  801133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801136:	5b                   	pop    %ebx
  801137:	5e                   	pop    %esi
  801138:	5f                   	pop    %edi
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80113b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801142:	83 ec 0c             	sub    $0xc,%esp
  801145:	25 07 0e 00 00       	and    $0xe07,%eax
  80114a:	50                   	push   %eax
  80114b:	57                   	push   %edi
  80114c:	6a 00                	push   $0x0
  80114e:	53                   	push   %ebx
  80114f:	6a 00                	push   $0x0
  801151:	e8 9b fa ff ff       	call   800bf1 <sys_page_map>
  801156:	89 c3                	mov    %eax,%ebx
  801158:	83 c4 20             	add    $0x20,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	79 a3                	jns    801102 <dup+0x74>
	sys_page_unmap(0, newfd);
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	56                   	push   %esi
  801163:	6a 00                	push   $0x0
  801165:	e8 c9 fa ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80116a:	83 c4 08             	add    $0x8,%esp
  80116d:	57                   	push   %edi
  80116e:	6a 00                	push   $0x0
  801170:	e8 be fa ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	eb b7                	jmp    801131 <dup+0xa3>

0080117a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	53                   	push   %ebx
  80117e:	83 ec 14             	sub    $0x14,%esp
  801181:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801184:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801187:	50                   	push   %eax
  801188:	53                   	push   %ebx
  801189:	e8 7b fd ff ff       	call   800f09 <fd_lookup>
  80118e:	83 c4 08             	add    $0x8,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	78 3f                	js     8011d4 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801195:	83 ec 08             	sub    $0x8,%esp
  801198:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119b:	50                   	push   %eax
  80119c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119f:	ff 30                	pushl  (%eax)
  8011a1:	e8 b9 fd ff ff       	call   800f5f <dev_lookup>
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	78 27                	js     8011d4 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011b0:	8b 42 08             	mov    0x8(%edx),%eax
  8011b3:	83 e0 03             	and    $0x3,%eax
  8011b6:	83 f8 01             	cmp    $0x1,%eax
  8011b9:	74 1e                	je     8011d9 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011be:	8b 40 08             	mov    0x8(%eax),%eax
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	74 35                	je     8011fa <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011c5:	83 ec 04             	sub    $0x4,%esp
  8011c8:	ff 75 10             	pushl  0x10(%ebp)
  8011cb:	ff 75 0c             	pushl  0xc(%ebp)
  8011ce:	52                   	push   %edx
  8011cf:	ff d0                	call   *%eax
  8011d1:	83 c4 10             	add    $0x10,%esp
}
  8011d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d7:	c9                   	leave  
  8011d8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011de:	8b 40 48             	mov    0x48(%eax),%eax
  8011e1:	83 ec 04             	sub    $0x4,%esp
  8011e4:	53                   	push   %ebx
  8011e5:	50                   	push   %eax
  8011e6:	68 ed 21 80 00       	push   $0x8021ed
  8011eb:	e8 a6 ef ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f8:	eb da                	jmp    8011d4 <read+0x5a>
		return -E_NOT_SUPP;
  8011fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011ff:	eb d3                	jmp    8011d4 <read+0x5a>

00801201 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	57                   	push   %edi
  801205:	56                   	push   %esi
  801206:	53                   	push   %ebx
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801210:	bb 00 00 00 00       	mov    $0x0,%ebx
  801215:	39 f3                	cmp    %esi,%ebx
  801217:	73 25                	jae    80123e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801219:	83 ec 04             	sub    $0x4,%esp
  80121c:	89 f0                	mov    %esi,%eax
  80121e:	29 d8                	sub    %ebx,%eax
  801220:	50                   	push   %eax
  801221:	89 d8                	mov    %ebx,%eax
  801223:	03 45 0c             	add    0xc(%ebp),%eax
  801226:	50                   	push   %eax
  801227:	57                   	push   %edi
  801228:	e8 4d ff ff ff       	call   80117a <read>
		if (m < 0)
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	78 08                	js     80123c <readn+0x3b>
			return m;
		if (m == 0)
  801234:	85 c0                	test   %eax,%eax
  801236:	74 06                	je     80123e <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801238:	01 c3                	add    %eax,%ebx
  80123a:	eb d9                	jmp    801215 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80123c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80123e:	89 d8                	mov    %ebx,%eax
  801240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801243:	5b                   	pop    %ebx
  801244:	5e                   	pop    %esi
  801245:	5f                   	pop    %edi
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	53                   	push   %ebx
  80124c:	83 ec 14             	sub    $0x14,%esp
  80124f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801252:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801255:	50                   	push   %eax
  801256:	53                   	push   %ebx
  801257:	e8 ad fc ff ff       	call   800f09 <fd_lookup>
  80125c:	83 c4 08             	add    $0x8,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 3a                	js     80129d <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801263:	83 ec 08             	sub    $0x8,%esp
  801266:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801269:	50                   	push   %eax
  80126a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126d:	ff 30                	pushl  (%eax)
  80126f:	e8 eb fc ff ff       	call   800f5f <dev_lookup>
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	78 22                	js     80129d <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801282:	74 1e                	je     8012a2 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801284:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801287:	8b 52 0c             	mov    0xc(%edx),%edx
  80128a:	85 d2                	test   %edx,%edx
  80128c:	74 35                	je     8012c3 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80128e:	83 ec 04             	sub    $0x4,%esp
  801291:	ff 75 10             	pushl  0x10(%ebp)
  801294:	ff 75 0c             	pushl  0xc(%ebp)
  801297:	50                   	push   %eax
  801298:	ff d2                	call   *%edx
  80129a:	83 c4 10             	add    $0x10,%esp
}
  80129d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a0:	c9                   	leave  
  8012a1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a7:	8b 40 48             	mov    0x48(%eax),%eax
  8012aa:	83 ec 04             	sub    $0x4,%esp
  8012ad:	53                   	push   %ebx
  8012ae:	50                   	push   %eax
  8012af:	68 09 22 80 00       	push   $0x802209
  8012b4:	e8 dd ee ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c1:	eb da                	jmp    80129d <write+0x55>
		return -E_NOT_SUPP;
  8012c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c8:	eb d3                	jmp    80129d <write+0x55>

008012ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012d3:	50                   	push   %eax
  8012d4:	ff 75 08             	pushl  0x8(%ebp)
  8012d7:	e8 2d fc ff ff       	call   800f09 <fd_lookup>
  8012dc:	83 c4 08             	add    $0x8,%esp
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	78 0e                	js     8012f1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012e9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 14             	sub    $0x14,%esp
  8012fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	53                   	push   %ebx
  801302:	e8 02 fc ff ff       	call   800f09 <fd_lookup>
  801307:	83 c4 08             	add    $0x8,%esp
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 37                	js     801345 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801318:	ff 30                	pushl  (%eax)
  80131a:	e8 40 fc ff ff       	call   800f5f <dev_lookup>
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	78 1f                	js     801345 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801326:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801329:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80132d:	74 1b                	je     80134a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80132f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801332:	8b 52 18             	mov    0x18(%edx),%edx
  801335:	85 d2                	test   %edx,%edx
  801337:	74 32                	je     80136b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	ff 75 0c             	pushl  0xc(%ebp)
  80133f:	50                   	push   %eax
  801340:	ff d2                	call   *%edx
  801342:	83 c4 10             	add    $0x10,%esp
}
  801345:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801348:	c9                   	leave  
  801349:	c3                   	ret    
			thisenv->env_id, fdnum);
  80134a:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80134f:	8b 40 48             	mov    0x48(%eax),%eax
  801352:	83 ec 04             	sub    $0x4,%esp
  801355:	53                   	push   %ebx
  801356:	50                   	push   %eax
  801357:	68 cc 21 80 00       	push   $0x8021cc
  80135c:	e8 35 ee ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801369:	eb da                	jmp    801345 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80136b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801370:	eb d3                	jmp    801345 <ftruncate+0x52>

00801372 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	53                   	push   %ebx
  801376:	83 ec 14             	sub    $0x14,%esp
  801379:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	ff 75 08             	pushl  0x8(%ebp)
  801383:	e8 81 fb ff ff       	call   800f09 <fd_lookup>
  801388:	83 c4 08             	add    $0x8,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 4b                	js     8013da <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801395:	50                   	push   %eax
  801396:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801399:	ff 30                	pushl  (%eax)
  80139b:	e8 bf fb ff ff       	call   800f5f <dev_lookup>
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 33                	js     8013da <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8013a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013aa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ae:	74 2f                	je     8013df <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013b0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013b3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ba:	00 00 00 
	stat->st_isdir = 0;
  8013bd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013c4:	00 00 00 
	stat->st_dev = dev;
  8013c7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	53                   	push   %ebx
  8013d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8013d4:	ff 50 14             	call   *0x14(%eax)
  8013d7:	83 c4 10             	add    $0x10,%esp
}
  8013da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    
		return -E_NOT_SUPP;
  8013df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013e4:	eb f4                	jmp    8013da <fstat+0x68>

008013e6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	56                   	push   %esi
  8013ea:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	6a 00                	push   $0x0
  8013f0:	ff 75 08             	pushl  0x8(%ebp)
  8013f3:	e8 da 01 00 00       	call   8015d2 <open>
  8013f8:	89 c3                	mov    %eax,%ebx
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	78 1b                	js     80141c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801401:	83 ec 08             	sub    $0x8,%esp
  801404:	ff 75 0c             	pushl  0xc(%ebp)
  801407:	50                   	push   %eax
  801408:	e8 65 ff ff ff       	call   801372 <fstat>
  80140d:	89 c6                	mov    %eax,%esi
	close(fd);
  80140f:	89 1c 24             	mov    %ebx,(%esp)
  801412:	e8 27 fc ff ff       	call   80103e <close>
	return r;
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	89 f3                	mov    %esi,%ebx
}
  80141c:	89 d8                	mov    %ebx,%eax
  80141e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	56                   	push   %esi
  801429:	53                   	push   %ebx
  80142a:	89 c6                	mov    %eax,%esi
  80142c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80142e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801435:	74 27                	je     80145e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801437:	6a 07                	push   $0x7
  801439:	68 00 50 80 00       	push   $0x805000
  80143e:	56                   	push   %esi
  80143f:	ff 35 00 40 80 00    	pushl  0x804000
  801445:	e8 bc f9 ff ff       	call   800e06 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80144a:	83 c4 0c             	add    $0xc,%esp
  80144d:	6a 00                	push   $0x0
  80144f:	53                   	push   %ebx
  801450:	6a 00                	push   $0x0
  801452:	e8 48 f9 ff ff       	call   800d9f <ipc_recv>
}
  801457:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145a:	5b                   	pop    %ebx
  80145b:	5e                   	pop    %esi
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80145e:	83 ec 0c             	sub    $0xc,%esp
  801461:	6a 01                	push   $0x1
  801463:	e8 f2 f9 ff ff       	call   800e5a <ipc_find_env>
  801468:	a3 00 40 80 00       	mov    %eax,0x804000
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	eb c5                	jmp    801437 <fsipc+0x12>

00801472 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801478:	8b 45 08             	mov    0x8(%ebp),%eax
  80147b:	8b 40 0c             	mov    0xc(%eax),%eax
  80147e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801483:	8b 45 0c             	mov    0xc(%ebp),%eax
  801486:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80148b:	ba 00 00 00 00       	mov    $0x0,%edx
  801490:	b8 02 00 00 00       	mov    $0x2,%eax
  801495:	e8 8b ff ff ff       	call   801425 <fsipc>
}
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <devfile_flush>:
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8014b7:	e8 69 ff ff ff       	call   801425 <fsipc>
}
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <devfile_stat>:
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	53                   	push   %ebx
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ce:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8014dd:	e8 43 ff ff ff       	call   801425 <fsipc>
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 2c                	js     801512 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	68 00 50 80 00       	push   $0x805000
  8014ee:	53                   	push   %ebx
  8014ef:	e8 c1 f2 ff ff       	call   8007b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014f4:	a1 80 50 80 00       	mov    0x805080,%eax
  8014f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ff:	a1 84 50 80 00       	mov    0x805084,%eax
  801504:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801512:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801515:	c9                   	leave  
  801516:	c3                   	ret    

00801517 <devfile_write>:
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	83 ec 0c             	sub    $0xc,%esp
  80151d:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801520:	8b 55 08             	mov    0x8(%ebp),%edx
  801523:	8b 52 0c             	mov    0xc(%edx),%edx
  801526:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  80152c:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  801531:	50                   	push   %eax
  801532:	ff 75 0c             	pushl  0xc(%ebp)
  801535:	68 08 50 80 00       	push   $0x805008
  80153a:	e8 04 f4 ff ff       	call   800943 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  80153f:	ba 00 00 00 00       	mov    $0x0,%edx
  801544:	b8 04 00 00 00       	mov    $0x4,%eax
  801549:	e8 d7 fe ff ff       	call   801425 <fsipc>
}
  80154e:	c9                   	leave  
  80154f:	c3                   	ret    

00801550 <devfile_read>:
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
  801555:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801558:	8b 45 08             	mov    0x8(%ebp),%eax
  80155b:	8b 40 0c             	mov    0xc(%eax),%eax
  80155e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801563:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801569:	ba 00 00 00 00       	mov    $0x0,%edx
  80156e:	b8 03 00 00 00       	mov    $0x3,%eax
  801573:	e8 ad fe ff ff       	call   801425 <fsipc>
  801578:	89 c3                	mov    %eax,%ebx
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 1f                	js     80159d <devfile_read+0x4d>
	assert(r <= n);
  80157e:	39 f0                	cmp    %esi,%eax
  801580:	77 24                	ja     8015a6 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801582:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801587:	7f 33                	jg     8015bc <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801589:	83 ec 04             	sub    $0x4,%esp
  80158c:	50                   	push   %eax
  80158d:	68 00 50 80 00       	push   $0x805000
  801592:	ff 75 0c             	pushl  0xc(%ebp)
  801595:	e8 a9 f3 ff ff       	call   800943 <memmove>
	return r;
  80159a:	83 c4 10             	add    $0x10,%esp
}
  80159d:	89 d8                	mov    %ebx,%eax
  80159f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a2:	5b                   	pop    %ebx
  8015a3:	5e                   	pop    %esi
  8015a4:	5d                   	pop    %ebp
  8015a5:	c3                   	ret    
	assert(r <= n);
  8015a6:	68 38 22 80 00       	push   $0x802238
  8015ab:	68 3f 22 80 00       	push   $0x80223f
  8015b0:	6a 7c                	push   $0x7c
  8015b2:	68 54 22 80 00       	push   $0x802254
  8015b7:	e8 85 05 00 00       	call   801b41 <_panic>
	assert(r <= PGSIZE);
  8015bc:	68 5f 22 80 00       	push   $0x80225f
  8015c1:	68 3f 22 80 00       	push   $0x80223f
  8015c6:	6a 7d                	push   $0x7d
  8015c8:	68 54 22 80 00       	push   $0x802254
  8015cd:	e8 6f 05 00 00       	call   801b41 <_panic>

008015d2 <open>:
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	56                   	push   %esi
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 1c             	sub    $0x1c,%esp
  8015da:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015dd:	56                   	push   %esi
  8015de:	e8 9b f1 ff ff       	call   80077e <strlen>
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015eb:	7f 6c                	jg     801659 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	e8 c1 f8 ff ff       	call   800eba <fd_alloc>
  8015f9:	89 c3                	mov    %eax,%ebx
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 3c                	js     80163e <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	56                   	push   %esi
  801606:	68 00 50 80 00       	push   $0x805000
  80160b:	e8 a5 f1 ff ff       	call   8007b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801610:	8b 45 0c             	mov    0xc(%ebp),%eax
  801613:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801618:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161b:	b8 01 00 00 00       	mov    $0x1,%eax
  801620:	e8 00 fe ff ff       	call   801425 <fsipc>
  801625:	89 c3                	mov    %eax,%ebx
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 19                	js     801647 <open+0x75>
	return fd2num(fd);
  80162e:	83 ec 0c             	sub    $0xc,%esp
  801631:	ff 75 f4             	pushl  -0xc(%ebp)
  801634:	e8 5a f8 ff ff       	call   800e93 <fd2num>
  801639:	89 c3                	mov    %eax,%ebx
  80163b:	83 c4 10             	add    $0x10,%esp
}
  80163e:	89 d8                	mov    %ebx,%eax
  801640:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801643:	5b                   	pop    %ebx
  801644:	5e                   	pop    %esi
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    
		fd_close(fd, 0);
  801647:	83 ec 08             	sub    $0x8,%esp
  80164a:	6a 00                	push   $0x0
  80164c:	ff 75 f4             	pushl  -0xc(%ebp)
  80164f:	e8 61 f9 ff ff       	call   800fb5 <fd_close>
		return r;
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	eb e5                	jmp    80163e <open+0x6c>
		return -E_BAD_PATH;
  801659:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80165e:	eb de                	jmp    80163e <open+0x6c>

00801660 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801666:	ba 00 00 00 00       	mov    $0x0,%edx
  80166b:	b8 08 00 00 00       	mov    $0x8,%eax
  801670:	e8 b0 fd ff ff       	call   801425 <fsipc>
}
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	56                   	push   %esi
  80167b:	53                   	push   %ebx
  80167c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80167f:	83 ec 0c             	sub    $0xc,%esp
  801682:	ff 75 08             	pushl  0x8(%ebp)
  801685:	e8 19 f8 ff ff       	call   800ea3 <fd2data>
  80168a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80168c:	83 c4 08             	add    $0x8,%esp
  80168f:	68 6b 22 80 00       	push   $0x80226b
  801694:	53                   	push   %ebx
  801695:	e8 1b f1 ff ff       	call   8007b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80169a:	8b 46 04             	mov    0x4(%esi),%eax
  80169d:	2b 06                	sub    (%esi),%eax
  80169f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016a5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016ac:	00 00 00 
	stat->st_dev = &devpipe;
  8016af:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016b6:	30 80 00 
	return 0;
}
  8016b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c1:	5b                   	pop    %ebx
  8016c2:	5e                   	pop    %esi
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 0c             	sub    $0xc,%esp
  8016cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016cf:	53                   	push   %ebx
  8016d0:	6a 00                	push   $0x0
  8016d2:	e8 5c f5 ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016d7:	89 1c 24             	mov    %ebx,(%esp)
  8016da:	e8 c4 f7 ff ff       	call   800ea3 <fd2data>
  8016df:	83 c4 08             	add    $0x8,%esp
  8016e2:	50                   	push   %eax
  8016e3:	6a 00                	push   $0x0
  8016e5:	e8 49 f5 ff ff       	call   800c33 <sys_page_unmap>
}
  8016ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <_pipeisclosed>:
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	57                   	push   %edi
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 1c             	sub    $0x1c,%esp
  8016f8:	89 c7                	mov    %eax,%edi
  8016fa:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8016fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801701:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801704:	83 ec 0c             	sub    $0xc,%esp
  801707:	57                   	push   %edi
  801708:	e8 7a 04 00 00       	call   801b87 <pageref>
  80170d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801710:	89 34 24             	mov    %esi,(%esp)
  801713:	e8 6f 04 00 00       	call   801b87 <pageref>
		nn = thisenv->env_runs;
  801718:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80171e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	39 cb                	cmp    %ecx,%ebx
  801726:	74 1b                	je     801743 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801728:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80172b:	75 cf                	jne    8016fc <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80172d:	8b 42 58             	mov    0x58(%edx),%eax
  801730:	6a 01                	push   $0x1
  801732:	50                   	push   %eax
  801733:	53                   	push   %ebx
  801734:	68 72 22 80 00       	push   $0x802272
  801739:	e8 58 ea ff ff       	call   800196 <cprintf>
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	eb b9                	jmp    8016fc <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801743:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801746:	0f 94 c0             	sete   %al
  801749:	0f b6 c0             	movzbl %al,%eax
}
  80174c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80174f:	5b                   	pop    %ebx
  801750:	5e                   	pop    %esi
  801751:	5f                   	pop    %edi
  801752:	5d                   	pop    %ebp
  801753:	c3                   	ret    

00801754 <devpipe_write>:
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	57                   	push   %edi
  801758:	56                   	push   %esi
  801759:	53                   	push   %ebx
  80175a:	83 ec 28             	sub    $0x28,%esp
  80175d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801760:	56                   	push   %esi
  801761:	e8 3d f7 ff ff       	call   800ea3 <fd2data>
  801766:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	bf 00 00 00 00       	mov    $0x0,%edi
  801770:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801773:	74 4f                	je     8017c4 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801775:	8b 43 04             	mov    0x4(%ebx),%eax
  801778:	8b 0b                	mov    (%ebx),%ecx
  80177a:	8d 51 20             	lea    0x20(%ecx),%edx
  80177d:	39 d0                	cmp    %edx,%eax
  80177f:	72 14                	jb     801795 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801781:	89 da                	mov    %ebx,%edx
  801783:	89 f0                	mov    %esi,%eax
  801785:	e8 65 ff ff ff       	call   8016ef <_pipeisclosed>
  80178a:	85 c0                	test   %eax,%eax
  80178c:	75 3a                	jne    8017c8 <devpipe_write+0x74>
			sys_yield();
  80178e:	e8 fc f3 ff ff       	call   800b8f <sys_yield>
  801793:	eb e0                	jmp    801775 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801795:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801798:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80179c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80179f:	89 c2                	mov    %eax,%edx
  8017a1:	c1 fa 1f             	sar    $0x1f,%edx
  8017a4:	89 d1                	mov    %edx,%ecx
  8017a6:	c1 e9 1b             	shr    $0x1b,%ecx
  8017a9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017ac:	83 e2 1f             	and    $0x1f,%edx
  8017af:	29 ca                	sub    %ecx,%edx
  8017b1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017b9:	83 c0 01             	add    $0x1,%eax
  8017bc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017bf:	83 c7 01             	add    $0x1,%edi
  8017c2:	eb ac                	jmp    801770 <devpipe_write+0x1c>
	return i;
  8017c4:	89 f8                	mov    %edi,%eax
  8017c6:	eb 05                	jmp    8017cd <devpipe_write+0x79>
				return 0;
  8017c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5f                   	pop    %edi
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <devpipe_read>:
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	57                   	push   %edi
  8017d9:	56                   	push   %esi
  8017da:	53                   	push   %ebx
  8017db:	83 ec 18             	sub    $0x18,%esp
  8017de:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017e1:	57                   	push   %edi
  8017e2:	e8 bc f6 ff ff       	call   800ea3 <fd2data>
  8017e7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	be 00 00 00 00       	mov    $0x0,%esi
  8017f1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017f4:	74 47                	je     80183d <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  8017f6:	8b 03                	mov    (%ebx),%eax
  8017f8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017fb:	75 22                	jne    80181f <devpipe_read+0x4a>
			if (i > 0)
  8017fd:	85 f6                	test   %esi,%esi
  8017ff:	75 14                	jne    801815 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801801:	89 da                	mov    %ebx,%edx
  801803:	89 f8                	mov    %edi,%eax
  801805:	e8 e5 fe ff ff       	call   8016ef <_pipeisclosed>
  80180a:	85 c0                	test   %eax,%eax
  80180c:	75 33                	jne    801841 <devpipe_read+0x6c>
			sys_yield();
  80180e:	e8 7c f3 ff ff       	call   800b8f <sys_yield>
  801813:	eb e1                	jmp    8017f6 <devpipe_read+0x21>
				return i;
  801815:	89 f0                	mov    %esi,%eax
}
  801817:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181a:	5b                   	pop    %ebx
  80181b:	5e                   	pop    %esi
  80181c:	5f                   	pop    %edi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80181f:	99                   	cltd   
  801820:	c1 ea 1b             	shr    $0x1b,%edx
  801823:	01 d0                	add    %edx,%eax
  801825:	83 e0 1f             	and    $0x1f,%eax
  801828:	29 d0                	sub    %edx,%eax
  80182a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80182f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801832:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801835:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801838:	83 c6 01             	add    $0x1,%esi
  80183b:	eb b4                	jmp    8017f1 <devpipe_read+0x1c>
	return i;
  80183d:	89 f0                	mov    %esi,%eax
  80183f:	eb d6                	jmp    801817 <devpipe_read+0x42>
				return 0;
  801841:	b8 00 00 00 00       	mov    $0x0,%eax
  801846:	eb cf                	jmp    801817 <devpipe_read+0x42>

00801848 <pipe>:
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	56                   	push   %esi
  80184c:	53                   	push   %ebx
  80184d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801850:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801853:	50                   	push   %eax
  801854:	e8 61 f6 ff ff       	call   800eba <fd_alloc>
  801859:	89 c3                	mov    %eax,%ebx
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 5b                	js     8018bd <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801862:	83 ec 04             	sub    $0x4,%esp
  801865:	68 07 04 00 00       	push   $0x407
  80186a:	ff 75 f4             	pushl  -0xc(%ebp)
  80186d:	6a 00                	push   $0x0
  80186f:	e8 3a f3 ff ff       	call   800bae <sys_page_alloc>
  801874:	89 c3                	mov    %eax,%ebx
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 40                	js     8018bd <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801883:	50                   	push   %eax
  801884:	e8 31 f6 ff ff       	call   800eba <fd_alloc>
  801889:	89 c3                	mov    %eax,%ebx
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 1b                	js     8018ad <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801892:	83 ec 04             	sub    $0x4,%esp
  801895:	68 07 04 00 00       	push   $0x407
  80189a:	ff 75 f0             	pushl  -0x10(%ebp)
  80189d:	6a 00                	push   $0x0
  80189f:	e8 0a f3 ff ff       	call   800bae <sys_page_alloc>
  8018a4:	89 c3                	mov    %eax,%ebx
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	79 19                	jns    8018c6 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8018ad:	83 ec 08             	sub    $0x8,%esp
  8018b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b3:	6a 00                	push   $0x0
  8018b5:	e8 79 f3 ff ff       	call   800c33 <sys_page_unmap>
  8018ba:	83 c4 10             	add    $0x10,%esp
}
  8018bd:	89 d8                	mov    %ebx,%eax
  8018bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5e                   	pop    %esi
  8018c4:	5d                   	pop    %ebp
  8018c5:	c3                   	ret    
	va = fd2data(fd0);
  8018c6:	83 ec 0c             	sub    $0xc,%esp
  8018c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018cc:	e8 d2 f5 ff ff       	call   800ea3 <fd2data>
  8018d1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d3:	83 c4 0c             	add    $0xc,%esp
  8018d6:	68 07 04 00 00       	push   $0x407
  8018db:	50                   	push   %eax
  8018dc:	6a 00                	push   $0x0
  8018de:	e8 cb f2 ff ff       	call   800bae <sys_page_alloc>
  8018e3:	89 c3                	mov    %eax,%ebx
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	0f 88 8c 00 00 00    	js     80197c <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018f0:	83 ec 0c             	sub    $0xc,%esp
  8018f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f6:	e8 a8 f5 ff ff       	call   800ea3 <fd2data>
  8018fb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801902:	50                   	push   %eax
  801903:	6a 00                	push   $0x0
  801905:	56                   	push   %esi
  801906:	6a 00                	push   $0x0
  801908:	e8 e4 f2 ff ff       	call   800bf1 <sys_page_map>
  80190d:	89 c3                	mov    %eax,%ebx
  80190f:	83 c4 20             	add    $0x20,%esp
  801912:	85 c0                	test   %eax,%eax
  801914:	78 58                	js     80196e <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801916:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801919:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80191f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801921:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801924:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80192b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801934:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801936:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801939:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801940:	83 ec 0c             	sub    $0xc,%esp
  801943:	ff 75 f4             	pushl  -0xc(%ebp)
  801946:	e8 48 f5 ff ff       	call   800e93 <fd2num>
  80194b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801950:	83 c4 04             	add    $0x4,%esp
  801953:	ff 75 f0             	pushl  -0x10(%ebp)
  801956:	e8 38 f5 ff ff       	call   800e93 <fd2num>
  80195b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	bb 00 00 00 00       	mov    $0x0,%ebx
  801969:	e9 4f ff ff ff       	jmp    8018bd <pipe+0x75>
	sys_page_unmap(0, va);
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	56                   	push   %esi
  801972:	6a 00                	push   $0x0
  801974:	e8 ba f2 ff ff       	call   800c33 <sys_page_unmap>
  801979:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80197c:	83 ec 08             	sub    $0x8,%esp
  80197f:	ff 75 f0             	pushl  -0x10(%ebp)
  801982:	6a 00                	push   $0x0
  801984:	e8 aa f2 ff ff       	call   800c33 <sys_page_unmap>
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	e9 1c ff ff ff       	jmp    8018ad <pipe+0x65>

00801991 <pipeisclosed>:
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801997:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199a:	50                   	push   %eax
  80199b:	ff 75 08             	pushl  0x8(%ebp)
  80199e:	e8 66 f5 ff ff       	call   800f09 <fd_lookup>
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	78 18                	js     8019c2 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8019aa:	83 ec 0c             	sub    $0xc,%esp
  8019ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b0:	e8 ee f4 ff ff       	call   800ea3 <fd2data>
	return _pipeisclosed(fd, p);
  8019b5:	89 c2                	mov    %eax,%edx
  8019b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ba:	e8 30 fd ff ff       	call   8016ef <_pipeisclosed>
  8019bf:	83 c4 10             	add    $0x10,%esp
}
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019d4:	68 8a 22 80 00       	push   $0x80228a
  8019d9:	ff 75 0c             	pushl  0xc(%ebp)
  8019dc:	e8 d4 ed ff ff       	call   8007b5 <strcpy>
	return 0;
}
  8019e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <devcons_write>:
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	57                   	push   %edi
  8019ec:	56                   	push   %esi
  8019ed:	53                   	push   %ebx
  8019ee:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019f4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019f9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8019ff:	eb 2f                	jmp    801a30 <devcons_write+0x48>
		m = n - tot;
  801a01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a04:	29 f3                	sub    %esi,%ebx
  801a06:	83 fb 7f             	cmp    $0x7f,%ebx
  801a09:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a0e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a11:	83 ec 04             	sub    $0x4,%esp
  801a14:	53                   	push   %ebx
  801a15:	89 f0                	mov    %esi,%eax
  801a17:	03 45 0c             	add    0xc(%ebp),%eax
  801a1a:	50                   	push   %eax
  801a1b:	57                   	push   %edi
  801a1c:	e8 22 ef ff ff       	call   800943 <memmove>
		sys_cputs(buf, m);
  801a21:	83 c4 08             	add    $0x8,%esp
  801a24:	53                   	push   %ebx
  801a25:	57                   	push   %edi
  801a26:	e8 c7 f0 ff ff       	call   800af2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a2b:	01 de                	add    %ebx,%esi
  801a2d:	83 c4 10             	add    $0x10,%esp
  801a30:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a33:	72 cc                	jb     801a01 <devcons_write+0x19>
}
  801a35:	89 f0                	mov    %esi,%eax
  801a37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3a:	5b                   	pop    %ebx
  801a3b:	5e                   	pop    %esi
  801a3c:	5f                   	pop    %edi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    

00801a3f <devcons_read>:
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	83 ec 08             	sub    $0x8,%esp
  801a45:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a4e:	75 07                	jne    801a57 <devcons_read+0x18>
}
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    
		sys_yield();
  801a52:	e8 38 f1 ff ff       	call   800b8f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a57:	e8 b4 f0 ff ff       	call   800b10 <sys_cgetc>
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	74 f2                	je     801a52 <devcons_read+0x13>
	if (c < 0)
  801a60:	85 c0                	test   %eax,%eax
  801a62:	78 ec                	js     801a50 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801a64:	83 f8 04             	cmp    $0x4,%eax
  801a67:	74 0c                	je     801a75 <devcons_read+0x36>
	*(char*)vbuf = c;
  801a69:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a6c:	88 02                	mov    %al,(%edx)
	return 1;
  801a6e:	b8 01 00 00 00       	mov    $0x1,%eax
  801a73:	eb db                	jmp    801a50 <devcons_read+0x11>
		return 0;
  801a75:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7a:	eb d4                	jmp    801a50 <devcons_read+0x11>

00801a7c <cputchar>:
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a82:	8b 45 08             	mov    0x8(%ebp),%eax
  801a85:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a88:	6a 01                	push   $0x1
  801a8a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a8d:	50                   	push   %eax
  801a8e:	e8 5f f0 ff ff       	call   800af2 <sys_cputs>
}
  801a93:	83 c4 10             	add    $0x10,%esp
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <getchar>:
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a9e:	6a 01                	push   $0x1
  801aa0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aa3:	50                   	push   %eax
  801aa4:	6a 00                	push   $0x0
  801aa6:	e8 cf f6 ff ff       	call   80117a <read>
	if (r < 0)
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 08                	js     801aba <getchar+0x22>
	if (r < 1)
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	7e 06                	jle    801abc <getchar+0x24>
	return c;
  801ab6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801aba:	c9                   	leave  
  801abb:	c3                   	ret    
		return -E_EOF;
  801abc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ac1:	eb f7                	jmp    801aba <getchar+0x22>

00801ac3 <iscons>:
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ac9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acc:	50                   	push   %eax
  801acd:	ff 75 08             	pushl  0x8(%ebp)
  801ad0:	e8 34 f4 ff ff       	call   800f09 <fd_lookup>
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	78 11                	js     801aed <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ae5:	39 10                	cmp    %edx,(%eax)
  801ae7:	0f 94 c0             	sete   %al
  801aea:	0f b6 c0             	movzbl %al,%eax
}
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <opencons>:
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801af5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af8:	50                   	push   %eax
  801af9:	e8 bc f3 ff ff       	call   800eba <fd_alloc>
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	85 c0                	test   %eax,%eax
  801b03:	78 3a                	js     801b3f <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b05:	83 ec 04             	sub    $0x4,%esp
  801b08:	68 07 04 00 00       	push   $0x407
  801b0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b10:	6a 00                	push   $0x0
  801b12:	e8 97 f0 ff ff       	call   800bae <sys_page_alloc>
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 21                	js     801b3f <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b21:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b27:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b33:	83 ec 0c             	sub    $0xc,%esp
  801b36:	50                   	push   %eax
  801b37:	e8 57 f3 ff ff       	call   800e93 <fd2num>
  801b3c:	83 c4 10             	add    $0x10,%esp
}
  801b3f:	c9                   	leave  
  801b40:	c3                   	ret    

00801b41 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	56                   	push   %esi
  801b45:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b46:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b49:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b4f:	e8 1c f0 ff ff       	call   800b70 <sys_getenvid>
  801b54:	83 ec 0c             	sub    $0xc,%esp
  801b57:	ff 75 0c             	pushl  0xc(%ebp)
  801b5a:	ff 75 08             	pushl  0x8(%ebp)
  801b5d:	56                   	push   %esi
  801b5e:	50                   	push   %eax
  801b5f:	68 98 22 80 00       	push   $0x802298
  801b64:	e8 2d e6 ff ff       	call   800196 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b69:	83 c4 18             	add    $0x18,%esp
  801b6c:	53                   	push   %ebx
  801b6d:	ff 75 10             	pushl  0x10(%ebp)
  801b70:	e8 d0 e5 ff ff       	call   800145 <vcprintf>
	cprintf("\n");
  801b75:	c7 04 24 83 22 80 00 	movl   $0x802283,(%esp)
  801b7c:	e8 15 e6 ff ff       	call   800196 <cprintf>
  801b81:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b84:	cc                   	int3   
  801b85:	eb fd                	jmp    801b84 <_panic+0x43>

00801b87 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8d:	89 d0                	mov    %edx,%eax
  801b8f:	c1 e8 16             	shr    $0x16,%eax
  801b92:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b99:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b9e:	f6 c1 01             	test   $0x1,%cl
  801ba1:	74 1d                	je     801bc0 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801ba3:	c1 ea 0c             	shr    $0xc,%edx
  801ba6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bad:	f6 c2 01             	test   $0x1,%dl
  801bb0:	74 0e                	je     801bc0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb2:	c1 ea 0c             	shr    $0xc,%edx
  801bb5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bbc:	ef 
  801bbd:	0f b7 c0             	movzwl %ax,%eax
}
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    
  801bc2:	66 90                	xchg   %ax,%ax
  801bc4:	66 90                	xchg   %ax,%ax
  801bc6:	66 90                	xchg   %ax,%ax
  801bc8:	66 90                	xchg   %ax,%ax
  801bca:	66 90                	xchg   %ax,%ax
  801bcc:	66 90                	xchg   %ax,%ax
  801bce:	66 90                	xchg   %ax,%ax

00801bd0 <__udivdi3>:
  801bd0:	55                   	push   %ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 1c             	sub    $0x1c,%esp
  801bd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801bdb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801bdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801be3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801be7:	85 d2                	test   %edx,%edx
  801be9:	75 35                	jne    801c20 <__udivdi3+0x50>
  801beb:	39 f3                	cmp    %esi,%ebx
  801bed:	0f 87 bd 00 00 00    	ja     801cb0 <__udivdi3+0xe0>
  801bf3:	85 db                	test   %ebx,%ebx
  801bf5:	89 d9                	mov    %ebx,%ecx
  801bf7:	75 0b                	jne    801c04 <__udivdi3+0x34>
  801bf9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f3                	div    %ebx
  801c02:	89 c1                	mov    %eax,%ecx
  801c04:	31 d2                	xor    %edx,%edx
  801c06:	89 f0                	mov    %esi,%eax
  801c08:	f7 f1                	div    %ecx
  801c0a:	89 c6                	mov    %eax,%esi
  801c0c:	89 e8                	mov    %ebp,%eax
  801c0e:	89 f7                	mov    %esi,%edi
  801c10:	f7 f1                	div    %ecx
  801c12:	89 fa                	mov    %edi,%edx
  801c14:	83 c4 1c             	add    $0x1c,%esp
  801c17:	5b                   	pop    %ebx
  801c18:	5e                   	pop    %esi
  801c19:	5f                   	pop    %edi
  801c1a:	5d                   	pop    %ebp
  801c1b:	c3                   	ret    
  801c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c20:	39 f2                	cmp    %esi,%edx
  801c22:	77 7c                	ja     801ca0 <__udivdi3+0xd0>
  801c24:	0f bd fa             	bsr    %edx,%edi
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	0f 84 98 00 00 00    	je     801cc8 <__udivdi3+0xf8>
  801c30:	89 f9                	mov    %edi,%ecx
  801c32:	b8 20 00 00 00       	mov    $0x20,%eax
  801c37:	29 f8                	sub    %edi,%eax
  801c39:	d3 e2                	shl    %cl,%edx
  801c3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c3f:	89 c1                	mov    %eax,%ecx
  801c41:	89 da                	mov    %ebx,%edx
  801c43:	d3 ea                	shr    %cl,%edx
  801c45:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c49:	09 d1                	or     %edx,%ecx
  801c4b:	89 f2                	mov    %esi,%edx
  801c4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c51:	89 f9                	mov    %edi,%ecx
  801c53:	d3 e3                	shl    %cl,%ebx
  801c55:	89 c1                	mov    %eax,%ecx
  801c57:	d3 ea                	shr    %cl,%edx
  801c59:	89 f9                	mov    %edi,%ecx
  801c5b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c5f:	d3 e6                	shl    %cl,%esi
  801c61:	89 eb                	mov    %ebp,%ebx
  801c63:	89 c1                	mov    %eax,%ecx
  801c65:	d3 eb                	shr    %cl,%ebx
  801c67:	09 de                	or     %ebx,%esi
  801c69:	89 f0                	mov    %esi,%eax
  801c6b:	f7 74 24 08          	divl   0x8(%esp)
  801c6f:	89 d6                	mov    %edx,%esi
  801c71:	89 c3                	mov    %eax,%ebx
  801c73:	f7 64 24 0c          	mull   0xc(%esp)
  801c77:	39 d6                	cmp    %edx,%esi
  801c79:	72 0c                	jb     801c87 <__udivdi3+0xb7>
  801c7b:	89 f9                	mov    %edi,%ecx
  801c7d:	d3 e5                	shl    %cl,%ebp
  801c7f:	39 c5                	cmp    %eax,%ebp
  801c81:	73 5d                	jae    801ce0 <__udivdi3+0x110>
  801c83:	39 d6                	cmp    %edx,%esi
  801c85:	75 59                	jne    801ce0 <__udivdi3+0x110>
  801c87:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c8a:	31 ff                	xor    %edi,%edi
  801c8c:	89 fa                	mov    %edi,%edx
  801c8e:	83 c4 1c             	add    $0x1c,%esp
  801c91:	5b                   	pop    %ebx
  801c92:	5e                   	pop    %esi
  801c93:	5f                   	pop    %edi
  801c94:	5d                   	pop    %ebp
  801c95:	c3                   	ret    
  801c96:	8d 76 00             	lea    0x0(%esi),%esi
  801c99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801ca0:	31 ff                	xor    %edi,%edi
  801ca2:	31 c0                	xor    %eax,%eax
  801ca4:	89 fa                	mov    %edi,%edx
  801ca6:	83 c4 1c             	add    $0x1c,%esp
  801ca9:	5b                   	pop    %ebx
  801caa:	5e                   	pop    %esi
  801cab:	5f                   	pop    %edi
  801cac:	5d                   	pop    %ebp
  801cad:	c3                   	ret    
  801cae:	66 90                	xchg   %ax,%ax
  801cb0:	31 ff                	xor    %edi,%edi
  801cb2:	89 e8                	mov    %ebp,%eax
  801cb4:	89 f2                	mov    %esi,%edx
  801cb6:	f7 f3                	div    %ebx
  801cb8:	89 fa                	mov    %edi,%edx
  801cba:	83 c4 1c             	add    $0x1c,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    
  801cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	72 06                	jb     801cd2 <__udivdi3+0x102>
  801ccc:	31 c0                	xor    %eax,%eax
  801cce:	39 eb                	cmp    %ebp,%ebx
  801cd0:	77 d2                	ja     801ca4 <__udivdi3+0xd4>
  801cd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd7:	eb cb                	jmp    801ca4 <__udivdi3+0xd4>
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	89 d8                	mov    %ebx,%eax
  801ce2:	31 ff                	xor    %edi,%edi
  801ce4:	eb be                	jmp    801ca4 <__udivdi3+0xd4>
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801cfb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 ed                	test   %ebp,%ebp
  801d09:	89 f0                	mov    %esi,%eax
  801d0b:	89 da                	mov    %ebx,%edx
  801d0d:	75 19                	jne    801d28 <__umoddi3+0x38>
  801d0f:	39 df                	cmp    %ebx,%edi
  801d11:	0f 86 b1 00 00 00    	jbe    801dc8 <__umoddi3+0xd8>
  801d17:	f7 f7                	div    %edi
  801d19:	89 d0                	mov    %edx,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	83 c4 1c             	add    $0x1c,%esp
  801d20:	5b                   	pop    %ebx
  801d21:	5e                   	pop    %esi
  801d22:	5f                   	pop    %edi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    
  801d25:	8d 76 00             	lea    0x0(%esi),%esi
  801d28:	39 dd                	cmp    %ebx,%ebp
  801d2a:	77 f1                	ja     801d1d <__umoddi3+0x2d>
  801d2c:	0f bd cd             	bsr    %ebp,%ecx
  801d2f:	83 f1 1f             	xor    $0x1f,%ecx
  801d32:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d36:	0f 84 b4 00 00 00    	je     801df0 <__umoddi3+0x100>
  801d3c:	b8 20 00 00 00       	mov    $0x20,%eax
  801d41:	89 c2                	mov    %eax,%edx
  801d43:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d47:	29 c2                	sub    %eax,%edx
  801d49:	89 c1                	mov    %eax,%ecx
  801d4b:	89 f8                	mov    %edi,%eax
  801d4d:	d3 e5                	shl    %cl,%ebp
  801d4f:	89 d1                	mov    %edx,%ecx
  801d51:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d55:	d3 e8                	shr    %cl,%eax
  801d57:	09 c5                	or     %eax,%ebp
  801d59:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d5d:	89 c1                	mov    %eax,%ecx
  801d5f:	d3 e7                	shl    %cl,%edi
  801d61:	89 d1                	mov    %edx,%ecx
  801d63:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d67:	89 df                	mov    %ebx,%edi
  801d69:	d3 ef                	shr    %cl,%edi
  801d6b:	89 c1                	mov    %eax,%ecx
  801d6d:	89 f0                	mov    %esi,%eax
  801d6f:	d3 e3                	shl    %cl,%ebx
  801d71:	89 d1                	mov    %edx,%ecx
  801d73:	89 fa                	mov    %edi,%edx
  801d75:	d3 e8                	shr    %cl,%eax
  801d77:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d7c:	09 d8                	or     %ebx,%eax
  801d7e:	f7 f5                	div    %ebp
  801d80:	d3 e6                	shl    %cl,%esi
  801d82:	89 d1                	mov    %edx,%ecx
  801d84:	f7 64 24 08          	mull   0x8(%esp)
  801d88:	39 d1                	cmp    %edx,%ecx
  801d8a:	89 c3                	mov    %eax,%ebx
  801d8c:	89 d7                	mov    %edx,%edi
  801d8e:	72 06                	jb     801d96 <__umoddi3+0xa6>
  801d90:	75 0e                	jne    801da0 <__umoddi3+0xb0>
  801d92:	39 c6                	cmp    %eax,%esi
  801d94:	73 0a                	jae    801da0 <__umoddi3+0xb0>
  801d96:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d9a:	19 ea                	sbb    %ebp,%edx
  801d9c:	89 d7                	mov    %edx,%edi
  801d9e:	89 c3                	mov    %eax,%ebx
  801da0:	89 ca                	mov    %ecx,%edx
  801da2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801da7:	29 de                	sub    %ebx,%esi
  801da9:	19 fa                	sbb    %edi,%edx
  801dab:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801daf:	89 d0                	mov    %edx,%eax
  801db1:	d3 e0                	shl    %cl,%eax
  801db3:	89 d9                	mov    %ebx,%ecx
  801db5:	d3 ee                	shr    %cl,%esi
  801db7:	d3 ea                	shr    %cl,%edx
  801db9:	09 f0                	or     %esi,%eax
  801dbb:	83 c4 1c             	add    $0x1c,%esp
  801dbe:	5b                   	pop    %ebx
  801dbf:	5e                   	pop    %esi
  801dc0:	5f                   	pop    %edi
  801dc1:	5d                   	pop    %ebp
  801dc2:	c3                   	ret    
  801dc3:	90                   	nop
  801dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc8:	85 ff                	test   %edi,%edi
  801dca:	89 f9                	mov    %edi,%ecx
  801dcc:	75 0b                	jne    801dd9 <__umoddi3+0xe9>
  801dce:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f7                	div    %edi
  801dd7:	89 c1                	mov    %eax,%ecx
  801dd9:	89 d8                	mov    %ebx,%eax
  801ddb:	31 d2                	xor    %edx,%edx
  801ddd:	f7 f1                	div    %ecx
  801ddf:	89 f0                	mov    %esi,%eax
  801de1:	f7 f1                	div    %ecx
  801de3:	e9 31 ff ff ff       	jmp    801d19 <__umoddi3+0x29>
  801de8:	90                   	nop
  801de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801df0:	39 dd                	cmp    %ebx,%ebp
  801df2:	72 08                	jb     801dfc <__umoddi3+0x10c>
  801df4:	39 f7                	cmp    %esi,%edi
  801df6:	0f 87 21 ff ff ff    	ja     801d1d <__umoddi3+0x2d>
  801dfc:	89 da                	mov    %ebx,%edx
  801dfe:	89 f0                	mov    %esi,%eax
  801e00:	29 f8                	sub    %edi,%eax
  801e02:	19 ea                	sbb    %ebp,%edx
  801e04:	e9 14 ff ff ff       	jmp    801d1d <__umoddi3+0x2d>
