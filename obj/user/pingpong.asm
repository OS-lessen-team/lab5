
obj/user/pingpong.debug：     文件格式 elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 7f 0e 00 00       	call   800ec0 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 4f                	jne    800097 <umain+0x64>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800048:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004b:	83 ec 04             	sub    $0x4,%esp
  80004e:	6a 00                	push   $0x0
  800050:	6a 00                	push   $0x0
  800052:	56                   	push   %esi
  800053:	e8 58 10 00 00       	call   8010b0 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80005d:	e8 2d 0b 00 00       	call   800b8f <sys_getenvid>
  800062:	57                   	push   %edi
  800063:	53                   	push   %ebx
  800064:	50                   	push   %eax
  800065:	68 d6 21 80 00       	push   $0x8021d6
  80006a:	e8 46 01 00 00       	call   8001b5 <cprintf>
		if (i == 10)
  80006f:	83 c4 20             	add    $0x20,%esp
  800072:	83 fb 0a             	cmp    $0xa,%ebx
  800075:	74 18                	je     80008f <umain+0x5c>
			return;
		i++;
  800077:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	53                   	push   %ebx
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 90 10 00 00       	call   801117 <ipc_send>
		if (i == 10)
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	83 fb 0a             	cmp    $0xa,%ebx
  80008d:	75 bc                	jne    80004b <umain+0x18>
			return;
	}

}
  80008f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5f                   	pop    %edi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
  800097:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800099:	e8 f1 0a 00 00       	call   800b8f <sys_getenvid>
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	53                   	push   %ebx
  8000a2:	50                   	push   %eax
  8000a3:	68 c0 21 80 00       	push   $0x8021c0
  8000a8:	e8 08 01 00 00       	call   8001b5 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ad:	6a 00                	push   $0x0
  8000af:	6a 00                	push   $0x0
  8000b1:	6a 00                	push   $0x0
  8000b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000b6:	e8 5c 10 00 00       	call   801117 <ipc_send>
  8000bb:	83 c4 20             	add    $0x20,%esp
  8000be:	eb 88                	jmp    800048 <umain+0x15>

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000cb:	e8 bf 0a 00 00       	call   800b8f <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000dd:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e2:	85 db                	test   %ebx,%ebx
  8000e4:	7e 07                	jle    8000ed <libmain+0x2d>
		binaryname = argv[0];
  8000e6:	8b 06                	mov    (%esi),%eax
  8000e8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	e8 3c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f7:	e8 0a 00 00 00       	call   800106 <exit>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010c:	e8 69 12 00 00       	call   80137a <close_all>
	sys_env_destroy(0);
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	6a 00                	push   $0x0
  800116:	e8 33 0a 00 00       	call   800b4e <sys_env_destroy>
}
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 04             	sub    $0x4,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 13                	mov    (%ebx),%edx
  80012c:	8d 42 01             	lea    0x1(%edx),%eax
  80012f:	89 03                	mov    %eax,(%ebx)
  800131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800134:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800138:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013d:	74 09                	je     800148 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80013f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800146:	c9                   	leave  
  800147:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800148:	83 ec 08             	sub    $0x8,%esp
  80014b:	68 ff 00 00 00       	push   $0xff
  800150:	8d 43 08             	lea    0x8(%ebx),%eax
  800153:	50                   	push   %eax
  800154:	e8 b8 09 00 00       	call   800b11 <sys_cputs>
		b->idx = 0;
  800159:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015f:	83 c4 10             	add    $0x10,%esp
  800162:	eb db                	jmp    80013f <putch+0x1f>

00800164 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800174:	00 00 00 
	b.cnt = 0;
  800177:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800181:	ff 75 0c             	pushl  0xc(%ebp)
  800184:	ff 75 08             	pushl  0x8(%ebp)
  800187:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	68 20 01 80 00       	push   $0x800120
  800193:	e8 1a 01 00 00       	call   8002b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800198:	83 c4 08             	add    $0x8,%esp
  80019b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a7:	50                   	push   %eax
  8001a8:	e8 64 09 00 00       	call   800b11 <sys_cputs>

	return b.cnt;
}
  8001ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001be:	50                   	push   %eax
  8001bf:	ff 75 08             	pushl  0x8(%ebp)
  8001c2:	e8 9d ff ff ff       	call   800164 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    

008001c9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 1c             	sub    $0x1c,%esp
  8001d2:	89 c7                	mov    %eax,%edi
  8001d4:	89 d6                	mov    %edx,%esi
  8001d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001df:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ed:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f0:	39 d3                	cmp    %edx,%ebx
  8001f2:	72 05                	jb     8001f9 <printnum+0x30>
  8001f4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f7:	77 7a                	ja     800273 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f9:	83 ec 0c             	sub    $0xc,%esp
  8001fc:	ff 75 18             	pushl  0x18(%ebp)
  8001ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800202:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800205:	53                   	push   %ebx
  800206:	ff 75 10             	pushl  0x10(%ebp)
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020f:	ff 75 e0             	pushl  -0x20(%ebp)
  800212:	ff 75 dc             	pushl  -0x24(%ebp)
  800215:	ff 75 d8             	pushl  -0x28(%ebp)
  800218:	e8 53 1d 00 00       	call   801f70 <__udivdi3>
  80021d:	83 c4 18             	add    $0x18,%esp
  800220:	52                   	push   %edx
  800221:	50                   	push   %eax
  800222:	89 f2                	mov    %esi,%edx
  800224:	89 f8                	mov    %edi,%eax
  800226:	e8 9e ff ff ff       	call   8001c9 <printnum>
  80022b:	83 c4 20             	add    $0x20,%esp
  80022e:	eb 13                	jmp    800243 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800230:	83 ec 08             	sub    $0x8,%esp
  800233:	56                   	push   %esi
  800234:	ff 75 18             	pushl  0x18(%ebp)
  800237:	ff d7                	call   *%edi
  800239:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023c:	83 eb 01             	sub    $0x1,%ebx
  80023f:	85 db                	test   %ebx,%ebx
  800241:	7f ed                	jg     800230 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800243:	83 ec 08             	sub    $0x8,%esp
  800246:	56                   	push   %esi
  800247:	83 ec 04             	sub    $0x4,%esp
  80024a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024d:	ff 75 e0             	pushl  -0x20(%ebp)
  800250:	ff 75 dc             	pushl  -0x24(%ebp)
  800253:	ff 75 d8             	pushl  -0x28(%ebp)
  800256:	e8 35 1e 00 00       	call   802090 <__umoddi3>
  80025b:	83 c4 14             	add    $0x14,%esp
  80025e:	0f be 80 f3 21 80 00 	movsbl 0x8021f3(%eax),%eax
  800265:	50                   	push   %eax
  800266:	ff d7                	call   *%edi
}
  800268:	83 c4 10             	add    $0x10,%esp
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    
  800273:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800276:	eb c4                	jmp    80023c <printnum+0x73>

00800278 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800282:	8b 10                	mov    (%eax),%edx
  800284:	3b 50 04             	cmp    0x4(%eax),%edx
  800287:	73 0a                	jae    800293 <sprintputch+0x1b>
		*b->buf++ = ch;
  800289:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028c:	89 08                	mov    %ecx,(%eax)
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	88 02                	mov    %al,(%edx)
}
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <printfmt>:
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80029b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029e:	50                   	push   %eax
  80029f:	ff 75 10             	pushl  0x10(%ebp)
  8002a2:	ff 75 0c             	pushl  0xc(%ebp)
  8002a5:	ff 75 08             	pushl  0x8(%ebp)
  8002a8:	e8 05 00 00 00       	call   8002b2 <vprintfmt>
}
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    

008002b2 <vprintfmt>:
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	57                   	push   %edi
  8002b6:	56                   	push   %esi
  8002b7:	53                   	push   %ebx
  8002b8:	83 ec 2c             	sub    $0x2c,%esp
  8002bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8002be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c4:	e9 c1 03 00 00       	jmp    80068a <vprintfmt+0x3d8>
		padc = ' ';
  8002c9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002cd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002d4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002db:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002e7:	8d 47 01             	lea    0x1(%edi),%eax
  8002ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ed:	0f b6 17             	movzbl (%edi),%edx
  8002f0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f3:	3c 55                	cmp    $0x55,%al
  8002f5:	0f 87 12 04 00 00    	ja     80070d <vprintfmt+0x45b>
  8002fb:	0f b6 c0             	movzbl %al,%eax
  8002fe:	ff 24 85 40 23 80 00 	jmp    *0x802340(,%eax,4)
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800308:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80030c:	eb d9                	jmp    8002e7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800311:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800315:	eb d0                	jmp    8002e7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800317:	0f b6 d2             	movzbl %dl,%edx
  80031a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80031d:	b8 00 00 00 00       	mov    $0x0,%eax
  800322:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800325:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800328:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80032c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80032f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800332:	83 f9 09             	cmp    $0x9,%ecx
  800335:	77 55                	ja     80038c <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800337:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80033a:	eb e9                	jmp    800325 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80033c:	8b 45 14             	mov    0x14(%ebp),%eax
  80033f:	8b 00                	mov    (%eax),%eax
  800341:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800344:	8b 45 14             	mov    0x14(%ebp),%eax
  800347:	8d 40 04             	lea    0x4(%eax),%eax
  80034a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800350:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800354:	79 91                	jns    8002e7 <vprintfmt+0x35>
				width = precision, precision = -1;
  800356:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800359:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800363:	eb 82                	jmp    8002e7 <vprintfmt+0x35>
  800365:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800368:	85 c0                	test   %eax,%eax
  80036a:	ba 00 00 00 00       	mov    $0x0,%edx
  80036f:	0f 49 d0             	cmovns %eax,%edx
  800372:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800378:	e9 6a ff ff ff       	jmp    8002e7 <vprintfmt+0x35>
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800380:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800387:	e9 5b ff ff ff       	jmp    8002e7 <vprintfmt+0x35>
  80038c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80038f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800392:	eb bc                	jmp    800350 <vprintfmt+0x9e>
			lflag++;
  800394:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039a:	e9 48 ff ff ff       	jmp    8002e7 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	8d 78 04             	lea    0x4(%eax),%edi
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	53                   	push   %ebx
  8003a9:	ff 30                	pushl  (%eax)
  8003ab:	ff d6                	call   *%esi
			break;
  8003ad:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b3:	e9 cf 02 00 00       	jmp    800687 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 78 04             	lea    0x4(%eax),%edi
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	99                   	cltd   
  8003c1:	31 d0                	xor    %edx,%eax
  8003c3:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c5:	83 f8 0f             	cmp    $0xf,%eax
  8003c8:	7f 23                	jg     8003ed <vprintfmt+0x13b>
  8003ca:	8b 14 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%edx
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	74 18                	je     8003ed <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003d5:	52                   	push   %edx
  8003d6:	68 85 26 80 00       	push   $0x802685
  8003db:	53                   	push   %ebx
  8003dc:	56                   	push   %esi
  8003dd:	e8 b3 fe ff ff       	call   800295 <printfmt>
  8003e2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e5:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e8:	e9 9a 02 00 00       	jmp    800687 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003ed:	50                   	push   %eax
  8003ee:	68 0b 22 80 00       	push   $0x80220b
  8003f3:	53                   	push   %ebx
  8003f4:	56                   	push   %esi
  8003f5:	e8 9b fe ff ff       	call   800295 <printfmt>
  8003fa:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003fd:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800400:	e9 82 02 00 00       	jmp    800687 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	83 c0 04             	add    $0x4,%eax
  80040b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800413:	85 ff                	test   %edi,%edi
  800415:	b8 04 22 80 00       	mov    $0x802204,%eax
  80041a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80041d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800421:	0f 8e bd 00 00 00    	jle    8004e4 <vprintfmt+0x232>
  800427:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042b:	75 0e                	jne    80043b <vprintfmt+0x189>
  80042d:	89 75 08             	mov    %esi,0x8(%ebp)
  800430:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800433:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800436:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800439:	eb 6d                	jmp    8004a8 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	ff 75 d0             	pushl  -0x30(%ebp)
  800441:	57                   	push   %edi
  800442:	e8 6e 03 00 00       	call   8007b5 <strnlen>
  800447:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044a:	29 c1                	sub    %eax,%ecx
  80044c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80044f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800452:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800456:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800459:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045c:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	eb 0f                	jmp    80046f <vprintfmt+0x1bd>
					putch(padc, putdat);
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	53                   	push   %ebx
  800464:	ff 75 e0             	pushl  -0x20(%ebp)
  800467:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800469:	83 ef 01             	sub    $0x1,%edi
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	85 ff                	test   %edi,%edi
  800471:	7f ed                	jg     800460 <vprintfmt+0x1ae>
  800473:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800476:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800479:	85 c9                	test   %ecx,%ecx
  80047b:	b8 00 00 00 00       	mov    $0x0,%eax
  800480:	0f 49 c1             	cmovns %ecx,%eax
  800483:	29 c1                	sub    %eax,%ecx
  800485:	89 75 08             	mov    %esi,0x8(%ebp)
  800488:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048e:	89 cb                	mov    %ecx,%ebx
  800490:	eb 16                	jmp    8004a8 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800492:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800496:	75 31                	jne    8004c9 <vprintfmt+0x217>
					putch(ch, putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	ff 75 0c             	pushl  0xc(%ebp)
  80049e:	50                   	push   %eax
  80049f:	ff 55 08             	call   *0x8(%ebp)
  8004a2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a5:	83 eb 01             	sub    $0x1,%ebx
  8004a8:	83 c7 01             	add    $0x1,%edi
  8004ab:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004af:	0f be c2             	movsbl %dl,%eax
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	74 59                	je     80050f <vprintfmt+0x25d>
  8004b6:	85 f6                	test   %esi,%esi
  8004b8:	78 d8                	js     800492 <vprintfmt+0x1e0>
  8004ba:	83 ee 01             	sub    $0x1,%esi
  8004bd:	79 d3                	jns    800492 <vprintfmt+0x1e0>
  8004bf:	89 df                	mov    %ebx,%edi
  8004c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c7:	eb 37                	jmp    800500 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c9:	0f be d2             	movsbl %dl,%edx
  8004cc:	83 ea 20             	sub    $0x20,%edx
  8004cf:	83 fa 5e             	cmp    $0x5e,%edx
  8004d2:	76 c4                	jbe    800498 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	ff 75 0c             	pushl  0xc(%ebp)
  8004da:	6a 3f                	push   $0x3f
  8004dc:	ff 55 08             	call   *0x8(%ebp)
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	eb c1                	jmp    8004a5 <vprintfmt+0x1f3>
  8004e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ed:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f0:	eb b6                	jmp    8004a8 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	53                   	push   %ebx
  8004f6:	6a 20                	push   $0x20
  8004f8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004fa:	83 ef 01             	sub    $0x1,%edi
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	85 ff                	test   %edi,%edi
  800502:	7f ee                	jg     8004f2 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800504:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800507:	89 45 14             	mov    %eax,0x14(%ebp)
  80050a:	e9 78 01 00 00       	jmp    800687 <vprintfmt+0x3d5>
  80050f:	89 df                	mov    %ebx,%edi
  800511:	8b 75 08             	mov    0x8(%ebp),%esi
  800514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800517:	eb e7                	jmp    800500 <vprintfmt+0x24e>
	if (lflag >= 2)
  800519:	83 f9 01             	cmp    $0x1,%ecx
  80051c:	7e 3f                	jle    80055d <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8b 50 04             	mov    0x4(%eax),%edx
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800529:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 40 08             	lea    0x8(%eax),%eax
  800532:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800535:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800539:	79 5c                	jns    800597 <vprintfmt+0x2e5>
				putch('-', putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	53                   	push   %ebx
  80053f:	6a 2d                	push   $0x2d
  800541:	ff d6                	call   *%esi
				num = -(long long) num;
  800543:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800546:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800549:	f7 da                	neg    %edx
  80054b:	83 d1 00             	adc    $0x0,%ecx
  80054e:	f7 d9                	neg    %ecx
  800550:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800553:	b8 0a 00 00 00       	mov    $0xa,%eax
  800558:	e9 10 01 00 00       	jmp    80066d <vprintfmt+0x3bb>
	else if (lflag)
  80055d:	85 c9                	test   %ecx,%ecx
  80055f:	75 1b                	jne    80057c <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8b 00                	mov    (%eax),%eax
  800566:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800569:	89 c1                	mov    %eax,%ecx
  80056b:	c1 f9 1f             	sar    $0x1f,%ecx
  80056e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 40 04             	lea    0x4(%eax),%eax
  800577:	89 45 14             	mov    %eax,0x14(%ebp)
  80057a:	eb b9                	jmp    800535 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	89 c1                	mov    %eax,%ecx
  800586:	c1 f9 1f             	sar    $0x1f,%ecx
  800589:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 40 04             	lea    0x4(%eax),%eax
  800592:	89 45 14             	mov    %eax,0x14(%ebp)
  800595:	eb 9e                	jmp    800535 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800597:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80059d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a2:	e9 c6 00 00 00       	jmp    80066d <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005a7:	83 f9 01             	cmp    $0x1,%ecx
  8005aa:	7e 18                	jle    8005c4 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 10                	mov    (%eax),%edx
  8005b1:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b4:	8d 40 08             	lea    0x8(%eax),%eax
  8005b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bf:	e9 a9 00 00 00       	jmp    80066d <vprintfmt+0x3bb>
	else if (lflag)
  8005c4:	85 c9                	test   %ecx,%ecx
  8005c6:	75 1a                	jne    8005e2 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 10                	mov    (%eax),%edx
  8005cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d2:	8d 40 04             	lea    0x4(%eax),%eax
  8005d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005dd:	e9 8b 00 00 00       	jmp    80066d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8b 10                	mov    (%eax),%edx
  8005e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ec:	8d 40 04             	lea    0x4(%eax),%eax
  8005ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f7:	eb 74                	jmp    80066d <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005f9:	83 f9 01             	cmp    $0x1,%ecx
  8005fc:	7e 15                	jle    800613 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8b 10                	mov    (%eax),%edx
  800603:	8b 48 04             	mov    0x4(%eax),%ecx
  800606:	8d 40 08             	lea    0x8(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80060c:	b8 08 00 00 00       	mov    $0x8,%eax
  800611:	eb 5a                	jmp    80066d <vprintfmt+0x3bb>
	else if (lflag)
  800613:	85 c9                	test   %ecx,%ecx
  800615:	75 17                	jne    80062e <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800621:	8d 40 04             	lea    0x4(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800627:	b8 08 00 00 00       	mov    $0x8,%eax
  80062c:	eb 3f                	jmp    80066d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	b9 00 00 00 00       	mov    $0x0,%ecx
  800638:	8d 40 04             	lea    0x4(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80063e:	b8 08 00 00 00       	mov    $0x8,%eax
  800643:	eb 28                	jmp    80066d <vprintfmt+0x3bb>
			putch('0', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	6a 30                	push   $0x30
  80064b:	ff d6                	call   *%esi
			putch('x', putdat);
  80064d:	83 c4 08             	add    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 78                	push   $0x78
  800653:	ff d6                	call   *%esi
			num = (unsigned long long)
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80065f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800668:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80066d:	83 ec 0c             	sub    $0xc,%esp
  800670:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800674:	57                   	push   %edi
  800675:	ff 75 e0             	pushl  -0x20(%ebp)
  800678:	50                   	push   %eax
  800679:	51                   	push   %ecx
  80067a:	52                   	push   %edx
  80067b:	89 da                	mov    %ebx,%edx
  80067d:	89 f0                	mov    %esi,%eax
  80067f:	e8 45 fb ff ff       	call   8001c9 <printnum>
			break;
  800684:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800687:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068a:	83 c7 01             	add    $0x1,%edi
  80068d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800691:	83 f8 25             	cmp    $0x25,%eax
  800694:	0f 84 2f fc ff ff    	je     8002c9 <vprintfmt+0x17>
			if (ch == '\0')
  80069a:	85 c0                	test   %eax,%eax
  80069c:	0f 84 8b 00 00 00    	je     80072d <vprintfmt+0x47b>
			putch(ch, putdat);
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	50                   	push   %eax
  8006a7:	ff d6                	call   *%esi
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	eb dc                	jmp    80068a <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006ae:	83 f9 01             	cmp    $0x1,%ecx
  8006b1:	7e 15                	jle    8006c8 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bb:	8d 40 08             	lea    0x8(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c6:	eb a5                	jmp    80066d <vprintfmt+0x3bb>
	else if (lflag)
  8006c8:	85 c9                	test   %ecx,%ecx
  8006ca:	75 17                	jne    8006e3 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 10                	mov    (%eax),%edx
  8006d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d6:	8d 40 04             	lea    0x4(%eax),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006dc:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e1:	eb 8a                	jmp    80066d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ed:	8d 40 04             	lea    0x4(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f8:	e9 70 ff ff ff       	jmp    80066d <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	6a 25                	push   $0x25
  800703:	ff d6                	call   *%esi
			break;
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	e9 7a ff ff ff       	jmp    800687 <vprintfmt+0x3d5>
			putch('%', putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	6a 25                	push   $0x25
  800713:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	89 f8                	mov    %edi,%eax
  80071a:	eb 03                	jmp    80071f <vprintfmt+0x46d>
  80071c:	83 e8 01             	sub    $0x1,%eax
  80071f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800723:	75 f7                	jne    80071c <vprintfmt+0x46a>
  800725:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800728:	e9 5a ff ff ff       	jmp    800687 <vprintfmt+0x3d5>
}
  80072d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800730:	5b                   	pop    %ebx
  800731:	5e                   	pop    %esi
  800732:	5f                   	pop    %edi
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 18             	sub    $0x18,%esp
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800741:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800744:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800748:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800752:	85 c0                	test   %eax,%eax
  800754:	74 26                	je     80077c <vsnprintf+0x47>
  800756:	85 d2                	test   %edx,%edx
  800758:	7e 22                	jle    80077c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075a:	ff 75 14             	pushl  0x14(%ebp)
  80075d:	ff 75 10             	pushl  0x10(%ebp)
  800760:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800763:	50                   	push   %eax
  800764:	68 78 02 80 00       	push   $0x800278
  800769:	e8 44 fb ff ff       	call   8002b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800771:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800777:	83 c4 10             	add    $0x10,%esp
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    
		return -E_INVAL;
  80077c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800781:	eb f7                	jmp    80077a <vsnprintf+0x45>

00800783 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800789:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078c:	50                   	push   %eax
  80078d:	ff 75 10             	pushl  0x10(%ebp)
  800790:	ff 75 0c             	pushl  0xc(%ebp)
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 9a ff ff ff       	call   800735 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a8:	eb 03                	jmp    8007ad <strlen+0x10>
		n++;
  8007aa:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b1:	75 f7                	jne    8007aa <strlen+0xd>
	return n;
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007be:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c3:	eb 03                	jmp    8007c8 <strnlen+0x13>
		n++;
  8007c5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c8:	39 d0                	cmp    %edx,%eax
  8007ca:	74 06                	je     8007d2 <strnlen+0x1d>
  8007cc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d0:	75 f3                	jne    8007c5 <strnlen+0x10>
	return n;
}
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007de:	89 c2                	mov    %eax,%edx
  8007e0:	83 c1 01             	add    $0x1,%ecx
  8007e3:	83 c2 01             	add    $0x1,%edx
  8007e6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ea:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ed:	84 db                	test   %bl,%bl
  8007ef:	75 ef                	jne    8007e0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f1:	5b                   	pop    %ebx
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fb:	53                   	push   %ebx
  8007fc:	e8 9c ff ff ff       	call   80079d <strlen>
  800801:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800804:	ff 75 0c             	pushl  0xc(%ebp)
  800807:	01 d8                	add    %ebx,%eax
  800809:	50                   	push   %eax
  80080a:	e8 c5 ff ff ff       	call   8007d4 <strcpy>
	return dst;
}
  80080f:	89 d8                	mov    %ebx,%eax
  800811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800821:	89 f3                	mov    %esi,%ebx
  800823:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800826:	89 f2                	mov    %esi,%edx
  800828:	eb 0f                	jmp    800839 <strncpy+0x23>
		*dst++ = *src;
  80082a:	83 c2 01             	add    $0x1,%edx
  80082d:	0f b6 01             	movzbl (%ecx),%eax
  800830:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800833:	80 39 01             	cmpb   $0x1,(%ecx)
  800836:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800839:	39 da                	cmp    %ebx,%edx
  80083b:	75 ed                	jne    80082a <strncpy+0x14>
	}
	return ret;
}
  80083d:	89 f0                	mov    %esi,%eax
  80083f:	5b                   	pop    %ebx
  800840:	5e                   	pop    %esi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 75 08             	mov    0x8(%ebp),%esi
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800851:	89 f0                	mov    %esi,%eax
  800853:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800857:	85 c9                	test   %ecx,%ecx
  800859:	75 0b                	jne    800866 <strlcpy+0x23>
  80085b:	eb 17                	jmp    800874 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085d:	83 c2 01             	add    $0x1,%edx
  800860:	83 c0 01             	add    $0x1,%eax
  800863:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800866:	39 d8                	cmp    %ebx,%eax
  800868:	74 07                	je     800871 <strlcpy+0x2e>
  80086a:	0f b6 0a             	movzbl (%edx),%ecx
  80086d:	84 c9                	test   %cl,%cl
  80086f:	75 ec                	jne    80085d <strlcpy+0x1a>
		*dst = '\0';
  800871:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800874:	29 f0                	sub    %esi,%eax
}
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800883:	eb 06                	jmp    80088b <strcmp+0x11>
		p++, q++;
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80088b:	0f b6 01             	movzbl (%ecx),%eax
  80088e:	84 c0                	test   %al,%al
  800890:	74 04                	je     800896 <strcmp+0x1c>
  800892:	3a 02                	cmp    (%edx),%al
  800894:	74 ef                	je     800885 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800896:	0f b6 c0             	movzbl %al,%eax
  800899:	0f b6 12             	movzbl (%edx),%edx
  80089c:	29 d0                	sub    %edx,%eax
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	53                   	push   %ebx
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	89 c3                	mov    %eax,%ebx
  8008ac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008af:	eb 06                	jmp    8008b7 <strncmp+0x17>
		n--, p++, q++;
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b7:	39 d8                	cmp    %ebx,%eax
  8008b9:	74 16                	je     8008d1 <strncmp+0x31>
  8008bb:	0f b6 08             	movzbl (%eax),%ecx
  8008be:	84 c9                	test   %cl,%cl
  8008c0:	74 04                	je     8008c6 <strncmp+0x26>
  8008c2:	3a 0a                	cmp    (%edx),%cl
  8008c4:	74 eb                	je     8008b1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	0f b6 00             	movzbl (%eax),%eax
  8008c9:	0f b6 12             	movzbl (%edx),%edx
  8008cc:	29 d0                	sub    %edx,%eax
}
  8008ce:	5b                   	pop    %ebx
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    
		return 0;
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d6:	eb f6                	jmp    8008ce <strncmp+0x2e>

008008d8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e2:	0f b6 10             	movzbl (%eax),%edx
  8008e5:	84 d2                	test   %dl,%dl
  8008e7:	74 09                	je     8008f2 <strchr+0x1a>
		if (*s == c)
  8008e9:	38 ca                	cmp    %cl,%dl
  8008eb:	74 0a                	je     8008f7 <strchr+0x1f>
	for (; *s; s++)
  8008ed:	83 c0 01             	add    $0x1,%eax
  8008f0:	eb f0                	jmp    8008e2 <strchr+0xa>
			return (char *) s;
	return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800903:	eb 03                	jmp    800908 <strfind+0xf>
  800905:	83 c0 01             	add    $0x1,%eax
  800908:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090b:	38 ca                	cmp    %cl,%dl
  80090d:	74 04                	je     800913 <strfind+0x1a>
  80090f:	84 d2                	test   %dl,%dl
  800911:	75 f2                	jne    800905 <strfind+0xc>
			break;
	return (char *) s;
}
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800921:	85 c9                	test   %ecx,%ecx
  800923:	74 13                	je     800938 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800925:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092b:	75 05                	jne    800932 <memset+0x1d>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	74 0d                	je     80093f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800932:	8b 45 0c             	mov    0xc(%ebp),%eax
  800935:	fc                   	cld    
  800936:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800938:	89 f8                	mov    %edi,%eax
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5f                   	pop    %edi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    
		c &= 0xFF;
  80093f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800943:	89 d3                	mov    %edx,%ebx
  800945:	c1 e3 08             	shl    $0x8,%ebx
  800948:	89 d0                	mov    %edx,%eax
  80094a:	c1 e0 18             	shl    $0x18,%eax
  80094d:	89 d6                	mov    %edx,%esi
  80094f:	c1 e6 10             	shl    $0x10,%esi
  800952:	09 f0                	or     %esi,%eax
  800954:	09 c2                	or     %eax,%edx
  800956:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800958:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80095b:	89 d0                	mov    %edx,%eax
  80095d:	fc                   	cld    
  80095e:	f3 ab                	rep stos %eax,%es:(%edi)
  800960:	eb d6                	jmp    800938 <memset+0x23>

00800962 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	57                   	push   %edi
  800966:	56                   	push   %esi
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800970:	39 c6                	cmp    %eax,%esi
  800972:	73 35                	jae    8009a9 <memmove+0x47>
  800974:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800977:	39 c2                	cmp    %eax,%edx
  800979:	76 2e                	jbe    8009a9 <memmove+0x47>
		s += n;
		d += n;
  80097b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097e:	89 d6                	mov    %edx,%esi
  800980:	09 fe                	or     %edi,%esi
  800982:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800988:	74 0c                	je     800996 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098a:	83 ef 01             	sub    $0x1,%edi
  80098d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800990:	fd                   	std    
  800991:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800993:	fc                   	cld    
  800994:	eb 21                	jmp    8009b7 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800996:	f6 c1 03             	test   $0x3,%cl
  800999:	75 ef                	jne    80098a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099b:	83 ef 04             	sub    $0x4,%edi
  80099e:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a4:	fd                   	std    
  8009a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a7:	eb ea                	jmp    800993 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a9:	89 f2                	mov    %esi,%edx
  8009ab:	09 c2                	or     %eax,%edx
  8009ad:	f6 c2 03             	test   $0x3,%dl
  8009b0:	74 09                	je     8009bb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bb:	f6 c1 03             	test   $0x3,%cl
  8009be:	75 f2                	jne    8009b2 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c3:	89 c7                	mov    %eax,%edi
  8009c5:	fc                   	cld    
  8009c6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c8:	eb ed                	jmp    8009b7 <memmove+0x55>

008009ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009cd:	ff 75 10             	pushl  0x10(%ebp)
  8009d0:	ff 75 0c             	pushl  0xc(%ebp)
  8009d3:	ff 75 08             	pushl  0x8(%ebp)
  8009d6:	e8 87 ff ff ff       	call   800962 <memmove>
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e8:	89 c6                	mov    %eax,%esi
  8009ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ed:	39 f0                	cmp    %esi,%eax
  8009ef:	74 1c                	je     800a0d <memcmp+0x30>
		if (*s1 != *s2)
  8009f1:	0f b6 08             	movzbl (%eax),%ecx
  8009f4:	0f b6 1a             	movzbl (%edx),%ebx
  8009f7:	38 d9                	cmp    %bl,%cl
  8009f9:	75 08                	jne    800a03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	83 c2 01             	add    $0x1,%edx
  800a01:	eb ea                	jmp    8009ed <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a03:	0f b6 c1             	movzbl %cl,%eax
  800a06:	0f b6 db             	movzbl %bl,%ebx
  800a09:	29 d8                	sub    %ebx,%eax
  800a0b:	eb 05                	jmp    800a12 <memcmp+0x35>
	}

	return 0;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1f:	89 c2                	mov    %eax,%edx
  800a21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a24:	39 d0                	cmp    %edx,%eax
  800a26:	73 09                	jae    800a31 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a28:	38 08                	cmp    %cl,(%eax)
  800a2a:	74 05                	je     800a31 <memfind+0x1b>
	for (; s < ends; s++)
  800a2c:	83 c0 01             	add    $0x1,%eax
  800a2f:	eb f3                	jmp    800a24 <memfind+0xe>
			break;
	return (void *) s;
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3f:	eb 03                	jmp    800a44 <strtol+0x11>
		s++;
  800a41:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a44:	0f b6 01             	movzbl (%ecx),%eax
  800a47:	3c 20                	cmp    $0x20,%al
  800a49:	74 f6                	je     800a41 <strtol+0xe>
  800a4b:	3c 09                	cmp    $0x9,%al
  800a4d:	74 f2                	je     800a41 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a4f:	3c 2b                	cmp    $0x2b,%al
  800a51:	74 2e                	je     800a81 <strtol+0x4e>
	int neg = 0;
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a58:	3c 2d                	cmp    $0x2d,%al
  800a5a:	74 2f                	je     800a8b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a62:	75 05                	jne    800a69 <strtol+0x36>
  800a64:	80 39 30             	cmpb   $0x30,(%ecx)
  800a67:	74 2c                	je     800a95 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a69:	85 db                	test   %ebx,%ebx
  800a6b:	75 0a                	jne    800a77 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a72:	80 39 30             	cmpb   $0x30,(%ecx)
  800a75:	74 28                	je     800a9f <strtol+0x6c>
		base = 10;
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a7f:	eb 50                	jmp    800ad1 <strtol+0x9e>
		s++;
  800a81:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a84:	bf 00 00 00 00       	mov    $0x0,%edi
  800a89:	eb d1                	jmp    800a5c <strtol+0x29>
		s++, neg = 1;
  800a8b:	83 c1 01             	add    $0x1,%ecx
  800a8e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a93:	eb c7                	jmp    800a5c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a95:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a99:	74 0e                	je     800aa9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a9b:	85 db                	test   %ebx,%ebx
  800a9d:	75 d8                	jne    800a77 <strtol+0x44>
		s++, base = 8;
  800a9f:	83 c1 01             	add    $0x1,%ecx
  800aa2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa7:	eb ce                	jmp    800a77 <strtol+0x44>
		s += 2, base = 16;
  800aa9:	83 c1 02             	add    $0x2,%ecx
  800aac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab1:	eb c4                	jmp    800a77 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ab3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab6:	89 f3                	mov    %esi,%ebx
  800ab8:	80 fb 19             	cmp    $0x19,%bl
  800abb:	77 29                	ja     800ae6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800abd:	0f be d2             	movsbl %dl,%edx
  800ac0:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac6:	7d 30                	jge    800af8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac8:	83 c1 01             	add    $0x1,%ecx
  800acb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad1:	0f b6 11             	movzbl (%ecx),%edx
  800ad4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	77 d5                	ja     800ab3 <strtol+0x80>
			dig = *s - '0';
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 30             	sub    $0x30,%edx
  800ae4:	eb dd                	jmp    800ac3 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ae6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 08                	ja     800af8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 37             	sub    $0x37,%edx
  800af6:	eb cb                	jmp    800ac3 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afc:	74 05                	je     800b03 <strtol+0xd0>
		*endptr = (char *) s;
  800afe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b01:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b03:	89 c2                	mov    %eax,%edx
  800b05:	f7 da                	neg    %edx
  800b07:	85 ff                	test   %edi,%edi
  800b09:	0f 45 c2             	cmovne %edx,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b17:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b22:	89 c3                	mov    %eax,%ebx
  800b24:	89 c7                	mov    %eax,%edi
  800b26:	89 c6                	mov    %eax,%esi
  800b28:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3f:	89 d1                	mov    %edx,%ecx
  800b41:	89 d3                	mov    %edx,%ebx
  800b43:	89 d7                	mov    %edx,%edi
  800b45:	89 d6                	mov    %edx,%esi
  800b47:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b64:	89 cb                	mov    %ecx,%ebx
  800b66:	89 cf                	mov    %ecx,%edi
  800b68:	89 ce                	mov    %ecx,%esi
  800b6a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	7f 08                	jg     800b78 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b78:	83 ec 0c             	sub    $0xc,%esp
  800b7b:	50                   	push   %eax
  800b7c:	6a 03                	push   $0x3
  800b7e:	68 ff 24 80 00       	push   $0x8024ff
  800b83:	6a 23                	push   $0x23
  800b85:	68 1c 25 80 00       	push   $0x80251c
  800b8a:	e8 c3 12 00 00       	call   801e52 <_panic>

00800b8f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_yield>:

void
sys_yield(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd6:	be 00 00 00 00       	mov    $0x0,%esi
  800bdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be1:	b8 04 00 00 00       	mov    $0x4,%eax
  800be6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be9:	89 f7                	mov    %esi,%edi
  800beb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7f 08                	jg     800bf9 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	50                   	push   %eax
  800bfd:	6a 04                	push   $0x4
  800bff:	68 ff 24 80 00       	push   $0x8024ff
  800c04:	6a 23                	push   $0x23
  800c06:	68 1c 25 80 00       	push   $0x80251c
  800c0b:	e8 42 12 00 00       	call   801e52 <_panic>

00800c10 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7f 08                	jg     800c3b <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3b:	83 ec 0c             	sub    $0xc,%esp
  800c3e:	50                   	push   %eax
  800c3f:	6a 05                	push   $0x5
  800c41:	68 ff 24 80 00       	push   $0x8024ff
  800c46:	6a 23                	push   $0x23
  800c48:	68 1c 25 80 00       	push   $0x80251c
  800c4d:	e8 00 12 00 00       	call   801e52 <_panic>

00800c52 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6b:	89 df                	mov    %ebx,%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7f 08                	jg     800c7d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	83 ec 0c             	sub    $0xc,%esp
  800c80:	50                   	push   %eax
  800c81:	6a 06                	push   $0x6
  800c83:	68 ff 24 80 00       	push   $0x8024ff
  800c88:	6a 23                	push   $0x23
  800c8a:	68 1c 25 80 00       	push   $0x80251c
  800c8f:	e8 be 11 00 00       	call   801e52 <_panic>

00800c94 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7f 08                	jg     800cbf <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	50                   	push   %eax
  800cc3:	6a 08                	push   $0x8
  800cc5:	68 ff 24 80 00       	push   $0x8024ff
  800cca:	6a 23                	push   $0x23
  800ccc:	68 1c 25 80 00       	push   $0x80251c
  800cd1:	e8 7c 11 00 00       	call   801e52 <_panic>

00800cd6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cea:	b8 09 00 00 00       	mov    $0x9,%eax
  800cef:	89 df                	mov    %ebx,%edi
  800cf1:	89 de                	mov    %ebx,%esi
  800cf3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7f 08                	jg     800d01 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	50                   	push   %eax
  800d05:	6a 09                	push   $0x9
  800d07:	68 ff 24 80 00       	push   $0x8024ff
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 1c 25 80 00       	push   $0x80251c
  800d13:	e8 3a 11 00 00       	call   801e52 <_panic>

00800d18 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d31:	89 df                	mov    %ebx,%edi
  800d33:	89 de                	mov    %ebx,%esi
  800d35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d37:	85 c0                	test   %eax,%eax
  800d39:	7f 08                	jg     800d43 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	50                   	push   %eax
  800d47:	6a 0a                	push   $0xa
  800d49:	68 ff 24 80 00       	push   $0x8024ff
  800d4e:	6a 23                	push   $0x23
  800d50:	68 1c 25 80 00       	push   $0x80251c
  800d55:	e8 f8 10 00 00       	call   801e52 <_panic>

00800d5a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6b:	be 00 00 00 00       	mov    $0x0,%esi
  800d70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d76:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d93:	89 cb                	mov    %ecx,%ebx
  800d95:	89 cf                	mov    %ecx,%edi
  800d97:	89 ce                	mov    %ecx,%esi
  800d99:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	7f 08                	jg     800da7 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	50                   	push   %eax
  800dab:	6a 0d                	push   $0xd
  800dad:	68 ff 24 80 00       	push   $0x8024ff
  800db2:	6a 23                	push   $0x23
  800db4:	68 1c 25 80 00       	push   $0x80251c
  800db9:	e8 94 10 00 00       	call   801e52 <_panic>

00800dbe <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 04             	sub    $0x4,%esp
  800dc5:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800dc8:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800dca:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800dce:	0f 84 9c 00 00 00    	je     800e70 <pgfault+0xb2>
  800dd4:	89 c2                	mov    %eax,%edx
  800dd6:	c1 ea 16             	shr    $0x16,%edx
  800dd9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de0:	f6 c2 01             	test   $0x1,%dl
  800de3:	0f 84 87 00 00 00    	je     800e70 <pgfault+0xb2>
  800de9:	89 c2                	mov    %eax,%edx
  800deb:	c1 ea 0c             	shr    $0xc,%edx
  800dee:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800df5:	f6 c1 01             	test   $0x1,%cl
  800df8:	74 76                	je     800e70 <pgfault+0xb2>
  800dfa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e01:	f6 c6 08             	test   $0x8,%dh
  800e04:	74 6a                	je     800e70 <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  800e06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e0b:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800e0d:	83 ec 04             	sub    $0x4,%esp
  800e10:	6a 07                	push   $0x7
  800e12:	68 00 f0 7f 00       	push   $0x7ff000
  800e17:	6a 00                	push   $0x0
  800e19:	e8 af fd ff ff       	call   800bcd <sys_page_alloc>
  800e1e:	83 c4 10             	add    $0x10,%esp
  800e21:	85 c0                	test   %eax,%eax
  800e23:	78 5f                	js     800e84 <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  800e25:	83 ec 04             	sub    $0x4,%esp
  800e28:	68 00 10 00 00       	push   $0x1000
  800e2d:	53                   	push   %ebx
  800e2e:	68 00 f0 7f 00       	push   $0x7ff000
  800e33:	e8 92 fb ff ff       	call   8009ca <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e38:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e3f:	53                   	push   %ebx
  800e40:	6a 00                	push   $0x0
  800e42:	68 00 f0 7f 00       	push   $0x7ff000
  800e47:	6a 00                	push   $0x0
  800e49:	e8 c2 fd ff ff       	call   800c10 <sys_page_map>
  800e4e:	83 c4 20             	add    $0x20,%esp
  800e51:	85 c0                	test   %eax,%eax
  800e53:	78 43                	js     800e98 <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e55:	83 ec 08             	sub    $0x8,%esp
  800e58:	68 00 f0 7f 00       	push   $0x7ff000
  800e5d:	6a 00                	push   $0x0
  800e5f:	e8 ee fd ff ff       	call   800c52 <sys_page_unmap>
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	78 41                	js     800eac <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  800e6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6e:	c9                   	leave  
  800e6f:	c3                   	ret    
		panic("not copy-on-write");
  800e70:	83 ec 04             	sub    $0x4,%esp
  800e73:	68 2a 25 80 00       	push   $0x80252a
  800e78:	6a 25                	push   $0x25
  800e7a:	68 3c 25 80 00       	push   $0x80253c
  800e7f:	e8 ce 0f 00 00       	call   801e52 <_panic>
		panic("sys_page_alloc");
  800e84:	83 ec 04             	sub    $0x4,%esp
  800e87:	68 47 25 80 00       	push   $0x802547
  800e8c:	6a 28                	push   $0x28
  800e8e:	68 3c 25 80 00       	push   $0x80253c
  800e93:	e8 ba 0f 00 00       	call   801e52 <_panic>
		panic("sys_page_map");
  800e98:	83 ec 04             	sub    $0x4,%esp
  800e9b:	68 56 25 80 00       	push   $0x802556
  800ea0:	6a 2b                	push   $0x2b
  800ea2:	68 3c 25 80 00       	push   $0x80253c
  800ea7:	e8 a6 0f 00 00       	call   801e52 <_panic>
		panic("sys_page_unmap");
  800eac:	83 ec 04             	sub    $0x4,%esp
  800eaf:	68 63 25 80 00       	push   $0x802563
  800eb4:	6a 2d                	push   $0x2d
  800eb6:	68 3c 25 80 00       	push   $0x80253c
  800ebb:	e8 92 0f 00 00       	call   801e52 <_panic>

00800ec0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
  800ec6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800ec9:	68 be 0d 80 00       	push   $0x800dbe
  800ece:	e8 c5 0f 00 00       	call   801e98 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ed3:	b8 07 00 00 00       	mov    $0x7,%eax
  800ed8:	cd 30                	int    $0x30
  800eda:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	74 12                	je     800ef6 <fork+0x36>
  800ee4:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  800ee6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eea:	78 26                	js     800f12 <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800eec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef1:	e9 94 00 00 00       	jmp    800f8a <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ef6:	e8 94 fc ff ff       	call   800b8f <sys_getenvid>
  800efb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f00:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f03:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f08:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f0d:	e9 51 01 00 00       	jmp    801063 <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  800f12:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f15:	68 72 25 80 00       	push   $0x802572
  800f1a:	6a 6e                	push   $0x6e
  800f1c:	68 3c 25 80 00       	push   $0x80253c
  800f21:	e8 2c 0f 00 00       	call   801e52 <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800f26:	83 ec 0c             	sub    $0xc,%esp
  800f29:	68 07 0e 00 00       	push   $0xe07
  800f2e:	56                   	push   %esi
  800f2f:	57                   	push   %edi
  800f30:	56                   	push   %esi
  800f31:	6a 00                	push   $0x0
  800f33:	e8 d8 fc ff ff       	call   800c10 <sys_page_map>
  800f38:	83 c4 20             	add    $0x20,%esp
  800f3b:	eb 3b                	jmp    800f78 <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f3d:	83 ec 0c             	sub    $0xc,%esp
  800f40:	68 05 08 00 00       	push   $0x805
  800f45:	56                   	push   %esi
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	6a 00                	push   $0x0
  800f4a:	e8 c1 fc ff ff       	call   800c10 <sys_page_map>
  800f4f:	83 c4 20             	add    $0x20,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	0f 88 a9 00 00 00    	js     801003 <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f5a:	83 ec 0c             	sub    $0xc,%esp
  800f5d:	68 05 08 00 00       	push   $0x805
  800f62:	56                   	push   %esi
  800f63:	6a 00                	push   $0x0
  800f65:	56                   	push   %esi
  800f66:	6a 00                	push   $0x0
  800f68:	e8 a3 fc ff ff       	call   800c10 <sys_page_map>
  800f6d:	83 c4 20             	add    $0x20,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	0f 88 9d 00 00 00    	js     801015 <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f78:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f7e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f84:	0f 84 9d 00 00 00    	je     801027 <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800f8a:	89 d8                	mov    %ebx,%eax
  800f8c:	c1 e8 16             	shr    $0x16,%eax
  800f8f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f96:	a8 01                	test   $0x1,%al
  800f98:	74 de                	je     800f78 <fork+0xb8>
  800f9a:	89 d8                	mov    %ebx,%eax
  800f9c:	c1 e8 0c             	shr    $0xc,%eax
  800f9f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa6:	f6 c2 01             	test   $0x1,%dl
  800fa9:	74 cd                	je     800f78 <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800fab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb2:	f6 c2 04             	test   $0x4,%dl
  800fb5:	74 c1                	je     800f78 <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  800fb7:	89 c6                	mov    %eax,%esi
  800fb9:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  800fbc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc3:	f6 c6 04             	test   $0x4,%dh
  800fc6:	0f 85 5a ff ff ff    	jne    800f26 <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800fcc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd3:	f6 c2 02             	test   $0x2,%dl
  800fd6:	0f 85 61 ff ff ff    	jne    800f3d <fork+0x7d>
  800fdc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe3:	f6 c4 08             	test   $0x8,%ah
  800fe6:	0f 85 51 ff ff ff    	jne    800f3d <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800fec:	83 ec 0c             	sub    $0xc,%esp
  800fef:	6a 05                	push   $0x5
  800ff1:	56                   	push   %esi
  800ff2:	57                   	push   %edi
  800ff3:	56                   	push   %esi
  800ff4:	6a 00                	push   $0x0
  800ff6:	e8 15 fc ff ff       	call   800c10 <sys_page_map>
  800ffb:	83 c4 20             	add    $0x20,%esp
  800ffe:	e9 75 ff ff ff       	jmp    800f78 <fork+0xb8>
            		panic("sys_page_map：%e", r);
  801003:	50                   	push   %eax
  801004:	68 82 25 80 00       	push   $0x802582
  801009:	6a 47                	push   $0x47
  80100b:	68 3c 25 80 00       	push   $0x80253c
  801010:	e8 3d 0e 00 00       	call   801e52 <_panic>
            		panic("sys_page_map：%e", r);
  801015:	50                   	push   %eax
  801016:	68 82 25 80 00       	push   $0x802582
  80101b:	6a 49                	push   $0x49
  80101d:	68 3c 25 80 00       	push   $0x80253c
  801022:	e8 2b 0e 00 00       	call   801e52 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801027:	83 ec 04             	sub    $0x4,%esp
  80102a:	6a 07                	push   $0x7
  80102c:	68 00 f0 bf ee       	push   $0xeebff000
  801031:	ff 75 e4             	pushl  -0x1c(%ebp)
  801034:	e8 94 fb ff ff       	call   800bcd <sys_page_alloc>
  801039:	83 c4 10             	add    $0x10,%esp
  80103c:	85 c0                	test   %eax,%eax
  80103e:	78 2e                	js     80106e <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801040:	83 ec 08             	sub    $0x8,%esp
  801043:	68 07 1f 80 00       	push   $0x801f07
  801048:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80104b:	57                   	push   %edi
  80104c:	e8 c7 fc ff ff       	call   800d18 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801051:	83 c4 08             	add    $0x8,%esp
  801054:	6a 02                	push   $0x2
  801056:	57                   	push   %edi
  801057:	e8 38 fc ff ff       	call   800c94 <sys_env_set_status>
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 1f                	js     801082 <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  801063:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801066:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801069:	5b                   	pop    %ebx
  80106a:	5e                   	pop    %esi
  80106b:	5f                   	pop    %edi
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    
		panic("1");
  80106e:	83 ec 04             	sub    $0x4,%esp
  801071:	68 94 25 80 00       	push   $0x802594
  801076:	6a 77                	push   $0x77
  801078:	68 3c 25 80 00       	push   $0x80253c
  80107d:	e8 d0 0d 00 00       	call   801e52 <_panic>
		panic("sys_env_set_status");
  801082:	83 ec 04             	sub    $0x4,%esp
  801085:	68 96 25 80 00       	push   $0x802596
  80108a:	6a 7c                	push   $0x7c
  80108c:	68 3c 25 80 00       	push   $0x80253c
  801091:	e8 bc 0d 00 00       	call   801e52 <_panic>

00801096 <sfork>:

// Challenge!
int
sfork(void)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80109c:	68 a9 25 80 00       	push   $0x8025a9
  8010a1:	68 86 00 00 00       	push   $0x86
  8010a6:	68 3c 25 80 00       	push   $0x80253c
  8010ab:	e8 a2 0d 00 00       	call   801e52 <_panic>

008010b0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
  8010b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8010b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8010be:	85 f6                	test   %esi,%esi
  8010c0:	74 06                	je     8010c8 <ipc_recv+0x18>
  8010c2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  8010c8:	85 db                	test   %ebx,%ebx
  8010ca:	74 06                	je     8010d2 <ipc_recv+0x22>
  8010cc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010d9:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	50                   	push   %eax
  8010e0:	e8 98 fc ff ff       	call   800d7d <sys_ipc_recv>
	if (ret) return ret;
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	75 24                	jne    801110 <ipc_recv+0x60>
	if (from_env_store)
  8010ec:	85 f6                	test   %esi,%esi
  8010ee:	74 0a                	je     8010fa <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  8010f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f5:	8b 40 74             	mov    0x74(%eax),%eax
  8010f8:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  8010fa:	85 db                	test   %ebx,%ebx
  8010fc:	74 0a                	je     801108 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  8010fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801103:	8b 40 78             	mov    0x78(%eax),%eax
  801106:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801108:	a1 04 40 80 00       	mov    0x804004,%eax
  80110d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801110:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801113:	5b                   	pop    %ebx
  801114:	5e                   	pop    %esi
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    

00801117 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	57                   	push   %edi
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	83 ec 0c             	sub    $0xc,%esp
  801120:	8b 7d 08             	mov    0x8(%ebp),%edi
  801123:	8b 75 0c             	mov    0xc(%ebp),%esi
  801126:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801129:	85 db                	test   %ebx,%ebx
  80112b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801130:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801133:	ff 75 14             	pushl  0x14(%ebp)
  801136:	53                   	push   %ebx
  801137:	56                   	push   %esi
  801138:	57                   	push   %edi
  801139:	e8 1c fc ff ff       	call   800d5a <sys_ipc_try_send>
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	85 c0                	test   %eax,%eax
  801143:	74 1e                	je     801163 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801145:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801148:	75 07                	jne    801151 <ipc_send+0x3a>
		sys_yield();
  80114a:	e8 5f fa ff ff       	call   800bae <sys_yield>
  80114f:	eb e2                	jmp    801133 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801151:	50                   	push   %eax
  801152:	68 bf 25 80 00       	push   $0x8025bf
  801157:	6a 36                	push   $0x36
  801159:	68 d6 25 80 00       	push   $0x8025d6
  80115e:	e8 ef 0c 00 00       	call   801e52 <_panic>
	}
}
  801163:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801166:	5b                   	pop    %ebx
  801167:	5e                   	pop    %esi
  801168:	5f                   	pop    %edi
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801171:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801176:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801179:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80117f:	8b 52 50             	mov    0x50(%edx),%edx
  801182:	39 ca                	cmp    %ecx,%edx
  801184:	74 11                	je     801197 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801186:	83 c0 01             	add    $0x1,%eax
  801189:	3d 00 04 00 00       	cmp    $0x400,%eax
  80118e:	75 e6                	jne    801176 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801190:	b8 00 00 00 00       	mov    $0x0,%eax
  801195:	eb 0b                	jmp    8011a2 <ipc_find_env+0x37>
			return envs[i].env_id;
  801197:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80119a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80119f:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011aa:	05 00 00 00 30       	add    $0x30000000,%eax
  8011af:	c1 e8 0c             	shr    $0xc,%eax
}
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ba:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011c4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011d6:	89 c2                	mov    %eax,%edx
  8011d8:	c1 ea 16             	shr    $0x16,%edx
  8011db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e2:	f6 c2 01             	test   $0x1,%dl
  8011e5:	74 2a                	je     801211 <fd_alloc+0x46>
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	c1 ea 0c             	shr    $0xc,%edx
  8011ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f3:	f6 c2 01             	test   $0x1,%dl
  8011f6:	74 19                	je     801211 <fd_alloc+0x46>
  8011f8:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8011fd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801202:	75 d2                	jne    8011d6 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801204:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80120a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80120f:	eb 07                	jmp    801218 <fd_alloc+0x4d>
			*fd_store = fd;
  801211:	89 01                	mov    %eax,(%ecx)
			return 0;
  801213:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801220:	83 f8 1f             	cmp    $0x1f,%eax
  801223:	77 36                	ja     80125b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801225:	c1 e0 0c             	shl    $0xc,%eax
  801228:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	c1 ea 16             	shr    $0x16,%edx
  801232:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801239:	f6 c2 01             	test   $0x1,%dl
  80123c:	74 24                	je     801262 <fd_lookup+0x48>
  80123e:	89 c2                	mov    %eax,%edx
  801240:	c1 ea 0c             	shr    $0xc,%edx
  801243:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124a:	f6 c2 01             	test   $0x1,%dl
  80124d:	74 1a                	je     801269 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80124f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801252:	89 02                	mov    %eax,(%edx)
	return 0;
  801254:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    
		return -E_INVAL;
  80125b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801260:	eb f7                	jmp    801259 <fd_lookup+0x3f>
		return -E_INVAL;
  801262:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801267:	eb f0                	jmp    801259 <fd_lookup+0x3f>
  801269:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126e:	eb e9                	jmp    801259 <fd_lookup+0x3f>

00801270 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	83 ec 08             	sub    $0x8,%esp
  801276:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801279:	ba 5c 26 80 00       	mov    $0x80265c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80127e:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801283:	39 08                	cmp    %ecx,(%eax)
  801285:	74 33                	je     8012ba <dev_lookup+0x4a>
  801287:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80128a:	8b 02                	mov    (%edx),%eax
  80128c:	85 c0                	test   %eax,%eax
  80128e:	75 f3                	jne    801283 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801290:	a1 04 40 80 00       	mov    0x804004,%eax
  801295:	8b 40 48             	mov    0x48(%eax),%eax
  801298:	83 ec 04             	sub    $0x4,%esp
  80129b:	51                   	push   %ecx
  80129c:	50                   	push   %eax
  80129d:	68 e0 25 80 00       	push   $0x8025e0
  8012a2:	e8 0e ef ff ff       	call   8001b5 <cprintf>
	*dev = 0;
  8012a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    
			*dev = devtab[i];
  8012ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012bd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c4:	eb f2                	jmp    8012b8 <dev_lookup+0x48>

008012c6 <fd_close>:
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	57                   	push   %edi
  8012ca:	56                   	push   %esi
  8012cb:	53                   	push   %ebx
  8012cc:	83 ec 1c             	sub    $0x1c,%esp
  8012cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d8:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012df:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e2:	50                   	push   %eax
  8012e3:	e8 32 ff ff ff       	call   80121a <fd_lookup>
  8012e8:	89 c3                	mov    %eax,%ebx
  8012ea:	83 c4 08             	add    $0x8,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 05                	js     8012f6 <fd_close+0x30>
	    || fd != fd2)
  8012f1:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012f4:	74 16                	je     80130c <fd_close+0x46>
		return (must_exist ? r : 0);
  8012f6:	89 f8                	mov    %edi,%eax
  8012f8:	84 c0                	test   %al,%al
  8012fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ff:	0f 44 d8             	cmove  %eax,%ebx
}
  801302:	89 d8                	mov    %ebx,%eax
  801304:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5f                   	pop    %edi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801312:	50                   	push   %eax
  801313:	ff 36                	pushl  (%esi)
  801315:	e8 56 ff ff ff       	call   801270 <dev_lookup>
  80131a:	89 c3                	mov    %eax,%ebx
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 15                	js     801338 <fd_close+0x72>
		if (dev->dev_close)
  801323:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801326:	8b 40 10             	mov    0x10(%eax),%eax
  801329:	85 c0                	test   %eax,%eax
  80132b:	74 1b                	je     801348 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80132d:	83 ec 0c             	sub    $0xc,%esp
  801330:	56                   	push   %esi
  801331:	ff d0                	call   *%eax
  801333:	89 c3                	mov    %eax,%ebx
  801335:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	56                   	push   %esi
  80133c:	6a 00                	push   $0x0
  80133e:	e8 0f f9 ff ff       	call   800c52 <sys_page_unmap>
	return r;
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	eb ba                	jmp    801302 <fd_close+0x3c>
			r = 0;
  801348:	bb 00 00 00 00       	mov    $0x0,%ebx
  80134d:	eb e9                	jmp    801338 <fd_close+0x72>

0080134f <close>:

int
close(int fdnum)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801355:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	ff 75 08             	pushl  0x8(%ebp)
  80135c:	e8 b9 fe ff ff       	call   80121a <fd_lookup>
  801361:	83 c4 08             	add    $0x8,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 10                	js     801378 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	6a 01                	push   $0x1
  80136d:	ff 75 f4             	pushl  -0xc(%ebp)
  801370:	e8 51 ff ff ff       	call   8012c6 <fd_close>
  801375:	83 c4 10             	add    $0x10,%esp
}
  801378:	c9                   	leave  
  801379:	c3                   	ret    

0080137a <close_all>:

void
close_all(void)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	53                   	push   %ebx
  80137e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801381:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801386:	83 ec 0c             	sub    $0xc,%esp
  801389:	53                   	push   %ebx
  80138a:	e8 c0 ff ff ff       	call   80134f <close>
	for (i = 0; i < MAXFD; i++)
  80138f:	83 c3 01             	add    $0x1,%ebx
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	83 fb 20             	cmp    $0x20,%ebx
  801398:	75 ec                	jne    801386 <close_all+0xc>
}
  80139a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	57                   	push   %edi
  8013a3:	56                   	push   %esi
  8013a4:	53                   	push   %ebx
  8013a5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ab:	50                   	push   %eax
  8013ac:	ff 75 08             	pushl  0x8(%ebp)
  8013af:	e8 66 fe ff ff       	call   80121a <fd_lookup>
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	83 c4 08             	add    $0x8,%esp
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	0f 88 81 00 00 00    	js     801442 <dup+0xa3>
		return r;
	close(newfdnum);
  8013c1:	83 ec 0c             	sub    $0xc,%esp
  8013c4:	ff 75 0c             	pushl  0xc(%ebp)
  8013c7:	e8 83 ff ff ff       	call   80134f <close>

	newfd = INDEX2FD(newfdnum);
  8013cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013cf:	c1 e6 0c             	shl    $0xc,%esi
  8013d2:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013d8:	83 c4 04             	add    $0x4,%esp
  8013db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013de:	e8 d1 fd ff ff       	call   8011b4 <fd2data>
  8013e3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013e5:	89 34 24             	mov    %esi,(%esp)
  8013e8:	e8 c7 fd ff ff       	call   8011b4 <fd2data>
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f2:	89 d8                	mov    %ebx,%eax
  8013f4:	c1 e8 16             	shr    $0x16,%eax
  8013f7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013fe:	a8 01                	test   $0x1,%al
  801400:	74 11                	je     801413 <dup+0x74>
  801402:	89 d8                	mov    %ebx,%eax
  801404:	c1 e8 0c             	shr    $0xc,%eax
  801407:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80140e:	f6 c2 01             	test   $0x1,%dl
  801411:	75 39                	jne    80144c <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801413:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801416:	89 d0                	mov    %edx,%eax
  801418:	c1 e8 0c             	shr    $0xc,%eax
  80141b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801422:	83 ec 0c             	sub    $0xc,%esp
  801425:	25 07 0e 00 00       	and    $0xe07,%eax
  80142a:	50                   	push   %eax
  80142b:	56                   	push   %esi
  80142c:	6a 00                	push   $0x0
  80142e:	52                   	push   %edx
  80142f:	6a 00                	push   $0x0
  801431:	e8 da f7 ff ff       	call   800c10 <sys_page_map>
  801436:	89 c3                	mov    %eax,%ebx
  801438:	83 c4 20             	add    $0x20,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 31                	js     801470 <dup+0xd1>
		goto err;

	return newfdnum;
  80143f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801442:	89 d8                	mov    %ebx,%eax
  801444:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801447:	5b                   	pop    %ebx
  801448:	5e                   	pop    %esi
  801449:	5f                   	pop    %edi
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80144c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801453:	83 ec 0c             	sub    $0xc,%esp
  801456:	25 07 0e 00 00       	and    $0xe07,%eax
  80145b:	50                   	push   %eax
  80145c:	57                   	push   %edi
  80145d:	6a 00                	push   $0x0
  80145f:	53                   	push   %ebx
  801460:	6a 00                	push   $0x0
  801462:	e8 a9 f7 ff ff       	call   800c10 <sys_page_map>
  801467:	89 c3                	mov    %eax,%ebx
  801469:	83 c4 20             	add    $0x20,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	79 a3                	jns    801413 <dup+0x74>
	sys_page_unmap(0, newfd);
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	56                   	push   %esi
  801474:	6a 00                	push   $0x0
  801476:	e8 d7 f7 ff ff       	call   800c52 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80147b:	83 c4 08             	add    $0x8,%esp
  80147e:	57                   	push   %edi
  80147f:	6a 00                	push   $0x0
  801481:	e8 cc f7 ff ff       	call   800c52 <sys_page_unmap>
	return r;
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	eb b7                	jmp    801442 <dup+0xa3>

0080148b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	53                   	push   %ebx
  80148f:	83 ec 14             	sub    $0x14,%esp
  801492:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801495:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	53                   	push   %ebx
  80149a:	e8 7b fd ff ff       	call   80121a <fd_lookup>
  80149f:	83 c4 08             	add    $0x8,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 3f                	js     8014e5 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a6:	83 ec 08             	sub    $0x8,%esp
  8014a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b0:	ff 30                	pushl  (%eax)
  8014b2:	e8 b9 fd ff ff       	call   801270 <dev_lookup>
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 27                	js     8014e5 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014be:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c1:	8b 42 08             	mov    0x8(%edx),%eax
  8014c4:	83 e0 03             	and    $0x3,%eax
  8014c7:	83 f8 01             	cmp    $0x1,%eax
  8014ca:	74 1e                	je     8014ea <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cf:	8b 40 08             	mov    0x8(%eax),%eax
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	74 35                	je     80150b <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014d6:	83 ec 04             	sub    $0x4,%esp
  8014d9:	ff 75 10             	pushl  0x10(%ebp)
  8014dc:	ff 75 0c             	pushl  0xc(%ebp)
  8014df:	52                   	push   %edx
  8014e0:	ff d0                	call   *%eax
  8014e2:	83 c4 10             	add    $0x10,%esp
}
  8014e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ef:	8b 40 48             	mov    0x48(%eax),%eax
  8014f2:	83 ec 04             	sub    $0x4,%esp
  8014f5:	53                   	push   %ebx
  8014f6:	50                   	push   %eax
  8014f7:	68 21 26 80 00       	push   $0x802621
  8014fc:	e8 b4 ec ff ff       	call   8001b5 <cprintf>
		return -E_INVAL;
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801509:	eb da                	jmp    8014e5 <read+0x5a>
		return -E_NOT_SUPP;
  80150b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801510:	eb d3                	jmp    8014e5 <read+0x5a>

00801512 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	57                   	push   %edi
  801516:	56                   	push   %esi
  801517:	53                   	push   %ebx
  801518:	83 ec 0c             	sub    $0xc,%esp
  80151b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80151e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801521:	bb 00 00 00 00       	mov    $0x0,%ebx
  801526:	39 f3                	cmp    %esi,%ebx
  801528:	73 25                	jae    80154f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80152a:	83 ec 04             	sub    $0x4,%esp
  80152d:	89 f0                	mov    %esi,%eax
  80152f:	29 d8                	sub    %ebx,%eax
  801531:	50                   	push   %eax
  801532:	89 d8                	mov    %ebx,%eax
  801534:	03 45 0c             	add    0xc(%ebp),%eax
  801537:	50                   	push   %eax
  801538:	57                   	push   %edi
  801539:	e8 4d ff ff ff       	call   80148b <read>
		if (m < 0)
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	85 c0                	test   %eax,%eax
  801543:	78 08                	js     80154d <readn+0x3b>
			return m;
		if (m == 0)
  801545:	85 c0                	test   %eax,%eax
  801547:	74 06                	je     80154f <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801549:	01 c3                	add    %eax,%ebx
  80154b:	eb d9                	jmp    801526 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80154d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80154f:	89 d8                	mov    %ebx,%eax
  801551:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801554:	5b                   	pop    %ebx
  801555:	5e                   	pop    %esi
  801556:	5f                   	pop    %edi
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    

00801559 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	53                   	push   %ebx
  80155d:	83 ec 14             	sub    $0x14,%esp
  801560:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801563:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801566:	50                   	push   %eax
  801567:	53                   	push   %ebx
  801568:	e8 ad fc ff ff       	call   80121a <fd_lookup>
  80156d:	83 c4 08             	add    $0x8,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	78 3a                	js     8015ae <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157a:	50                   	push   %eax
  80157b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157e:	ff 30                	pushl  (%eax)
  801580:	e8 eb fc ff ff       	call   801270 <dev_lookup>
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	85 c0                	test   %eax,%eax
  80158a:	78 22                	js     8015ae <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80158c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801593:	74 1e                	je     8015b3 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801595:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801598:	8b 52 0c             	mov    0xc(%edx),%edx
  80159b:	85 d2                	test   %edx,%edx
  80159d:	74 35                	je     8015d4 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80159f:	83 ec 04             	sub    $0x4,%esp
  8015a2:	ff 75 10             	pushl  0x10(%ebp)
  8015a5:	ff 75 0c             	pushl  0xc(%ebp)
  8015a8:	50                   	push   %eax
  8015a9:	ff d2                	call   *%edx
  8015ab:	83 c4 10             	add    $0x10,%esp
}
  8015ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b8:	8b 40 48             	mov    0x48(%eax),%eax
  8015bb:	83 ec 04             	sub    $0x4,%esp
  8015be:	53                   	push   %ebx
  8015bf:	50                   	push   %eax
  8015c0:	68 3d 26 80 00       	push   $0x80263d
  8015c5:	e8 eb eb ff ff       	call   8001b5 <cprintf>
		return -E_INVAL;
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d2:	eb da                	jmp    8015ae <write+0x55>
		return -E_NOT_SUPP;
  8015d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015d9:	eb d3                	jmp    8015ae <write+0x55>

008015db <seek>:

int
seek(int fdnum, off_t offset)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	ff 75 08             	pushl  0x8(%ebp)
  8015e8:	e8 2d fc ff ff       	call   80121a <fd_lookup>
  8015ed:	83 c4 08             	add    $0x8,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 0e                	js     801602 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015fa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	53                   	push   %ebx
  801608:	83 ec 14             	sub    $0x14,%esp
  80160b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	53                   	push   %ebx
  801613:	e8 02 fc ff ff       	call   80121a <fd_lookup>
  801618:	83 c4 08             	add    $0x8,%esp
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 37                	js     801656 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801625:	50                   	push   %eax
  801626:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801629:	ff 30                	pushl  (%eax)
  80162b:	e8 40 fc ff ff       	call   801270 <dev_lookup>
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 1f                	js     801656 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801637:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80163e:	74 1b                	je     80165b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801640:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801643:	8b 52 18             	mov    0x18(%edx),%edx
  801646:	85 d2                	test   %edx,%edx
  801648:	74 32                	je     80167c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	ff 75 0c             	pushl  0xc(%ebp)
  801650:	50                   	push   %eax
  801651:	ff d2                	call   *%edx
  801653:	83 c4 10             	add    $0x10,%esp
}
  801656:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801659:	c9                   	leave  
  80165a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80165b:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801660:	8b 40 48             	mov    0x48(%eax),%eax
  801663:	83 ec 04             	sub    $0x4,%esp
  801666:	53                   	push   %ebx
  801667:	50                   	push   %eax
  801668:	68 00 26 80 00       	push   $0x802600
  80166d:	e8 43 eb ff ff       	call   8001b5 <cprintf>
		return -E_INVAL;
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167a:	eb da                	jmp    801656 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80167c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801681:	eb d3                	jmp    801656 <ftruncate+0x52>

00801683 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 14             	sub    $0x14,%esp
  80168a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	ff 75 08             	pushl  0x8(%ebp)
  801694:	e8 81 fb ff ff       	call   80121a <fd_lookup>
  801699:	83 c4 08             	add    $0x8,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 4b                	js     8016eb <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a6:	50                   	push   %eax
  8016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016aa:	ff 30                	pushl  (%eax)
  8016ac:	e8 bf fb ff ff       	call   801270 <dev_lookup>
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 33                	js     8016eb <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8016b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016bf:	74 2f                	je     8016f0 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016cb:	00 00 00 
	stat->st_isdir = 0;
  8016ce:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d5:	00 00 00 
	stat->st_dev = dev;
  8016d8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	53                   	push   %ebx
  8016e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e5:	ff 50 14             	call   *0x14(%eax)
  8016e8:	83 c4 10             	add    $0x10,%esp
}
  8016eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    
		return -E_NOT_SUPP;
  8016f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f5:	eb f4                	jmp    8016eb <fstat+0x68>

008016f7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016fc:	83 ec 08             	sub    $0x8,%esp
  8016ff:	6a 00                	push   $0x0
  801701:	ff 75 08             	pushl  0x8(%ebp)
  801704:	e8 da 01 00 00       	call   8018e3 <open>
  801709:	89 c3                	mov    %eax,%ebx
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 1b                	js     80172d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801712:	83 ec 08             	sub    $0x8,%esp
  801715:	ff 75 0c             	pushl  0xc(%ebp)
  801718:	50                   	push   %eax
  801719:	e8 65 ff ff ff       	call   801683 <fstat>
  80171e:	89 c6                	mov    %eax,%esi
	close(fd);
  801720:	89 1c 24             	mov    %ebx,(%esp)
  801723:	e8 27 fc ff ff       	call   80134f <close>
	return r;
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	89 f3                	mov    %esi,%ebx
}
  80172d:	89 d8                	mov    %ebx,%eax
  80172f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	56                   	push   %esi
  80173a:	53                   	push   %ebx
  80173b:	89 c6                	mov    %eax,%esi
  80173d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80173f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801746:	74 27                	je     80176f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801748:	6a 07                	push   $0x7
  80174a:	68 00 50 80 00       	push   $0x805000
  80174f:	56                   	push   %esi
  801750:	ff 35 00 40 80 00    	pushl  0x804000
  801756:	e8 bc f9 ff ff       	call   801117 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80175b:	83 c4 0c             	add    $0xc,%esp
  80175e:	6a 00                	push   $0x0
  801760:	53                   	push   %ebx
  801761:	6a 00                	push   $0x0
  801763:	e8 48 f9 ff ff       	call   8010b0 <ipc_recv>
}
  801768:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176b:	5b                   	pop    %ebx
  80176c:	5e                   	pop    %esi
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80176f:	83 ec 0c             	sub    $0xc,%esp
  801772:	6a 01                	push   $0x1
  801774:	e8 f2 f9 ff ff       	call   80116b <ipc_find_env>
  801779:	a3 00 40 80 00       	mov    %eax,0x804000
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	eb c5                	jmp    801748 <fsipc+0x12>

00801783 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801789:	8b 45 08             	mov    0x8(%ebp),%eax
  80178c:	8b 40 0c             	mov    0xc(%eax),%eax
  80178f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801794:	8b 45 0c             	mov    0xc(%ebp),%eax
  801797:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80179c:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a1:	b8 02 00 00 00       	mov    $0x2,%eax
  8017a6:	e8 8b ff ff ff       	call   801736 <fsipc>
}
  8017ab:	c9                   	leave  
  8017ac:	c3                   	ret    

008017ad <devfile_flush>:
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017be:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c3:	b8 06 00 00 00       	mov    $0x6,%eax
  8017c8:	e8 69 ff ff ff       	call   801736 <fsipc>
}
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <devfile_stat>:
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	53                   	push   %ebx
  8017d3:	83 ec 04             	sub    $0x4,%esp
  8017d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017df:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ee:	e8 43 ff ff ff       	call   801736 <fsipc>
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 2c                	js     801823 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	68 00 50 80 00       	push   $0x805000
  8017ff:	53                   	push   %ebx
  801800:	e8 cf ef ff ff       	call   8007d4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801805:	a1 80 50 80 00       	mov    0x805080,%eax
  80180a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801810:	a1 84 50 80 00       	mov    0x805084,%eax
  801815:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801823:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801826:	c9                   	leave  
  801827:	c3                   	ret    

00801828 <devfile_write>:
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	83 ec 0c             	sub    $0xc,%esp
  80182e:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801831:	8b 55 08             	mov    0x8(%ebp),%edx
  801834:	8b 52 0c             	mov    0xc(%edx),%edx
  801837:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  80183d:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  801842:	50                   	push   %eax
  801843:	ff 75 0c             	pushl  0xc(%ebp)
  801846:	68 08 50 80 00       	push   $0x805008
  80184b:	e8 12 f1 ff ff       	call   800962 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  801850:	ba 00 00 00 00       	mov    $0x0,%edx
  801855:	b8 04 00 00 00       	mov    $0x4,%eax
  80185a:	e8 d7 fe ff ff       	call   801736 <fsipc>
}
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <devfile_read>:
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	56                   	push   %esi
  801865:	53                   	push   %ebx
  801866:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801869:	8b 45 08             	mov    0x8(%ebp),%eax
  80186c:	8b 40 0c             	mov    0xc(%eax),%eax
  80186f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801874:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187a:	ba 00 00 00 00       	mov    $0x0,%edx
  80187f:	b8 03 00 00 00       	mov    $0x3,%eax
  801884:	e8 ad fe ff ff       	call   801736 <fsipc>
  801889:	89 c3                	mov    %eax,%ebx
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 1f                	js     8018ae <devfile_read+0x4d>
	assert(r <= n);
  80188f:	39 f0                	cmp    %esi,%eax
  801891:	77 24                	ja     8018b7 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801893:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801898:	7f 33                	jg     8018cd <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80189a:	83 ec 04             	sub    $0x4,%esp
  80189d:	50                   	push   %eax
  80189e:	68 00 50 80 00       	push   $0x805000
  8018a3:	ff 75 0c             	pushl  0xc(%ebp)
  8018a6:	e8 b7 f0 ff ff       	call   800962 <memmove>
	return r;
  8018ab:	83 c4 10             	add    $0x10,%esp
}
  8018ae:	89 d8                	mov    %ebx,%eax
  8018b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b3:	5b                   	pop    %ebx
  8018b4:	5e                   	pop    %esi
  8018b5:	5d                   	pop    %ebp
  8018b6:	c3                   	ret    
	assert(r <= n);
  8018b7:	68 6c 26 80 00       	push   $0x80266c
  8018bc:	68 73 26 80 00       	push   $0x802673
  8018c1:	6a 7c                	push   $0x7c
  8018c3:	68 88 26 80 00       	push   $0x802688
  8018c8:	e8 85 05 00 00       	call   801e52 <_panic>
	assert(r <= PGSIZE);
  8018cd:	68 93 26 80 00       	push   $0x802693
  8018d2:	68 73 26 80 00       	push   $0x802673
  8018d7:	6a 7d                	push   $0x7d
  8018d9:	68 88 26 80 00       	push   $0x802688
  8018de:	e8 6f 05 00 00       	call   801e52 <_panic>

008018e3 <open>:
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	56                   	push   %esi
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 1c             	sub    $0x1c,%esp
  8018eb:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018ee:	56                   	push   %esi
  8018ef:	e8 a9 ee ff ff       	call   80079d <strlen>
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018fc:	7f 6c                	jg     80196a <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8018fe:	83 ec 0c             	sub    $0xc,%esp
  801901:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801904:	50                   	push   %eax
  801905:	e8 c1 f8 ff ff       	call   8011cb <fd_alloc>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 3c                	js     80194f <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	56                   	push   %esi
  801917:	68 00 50 80 00       	push   $0x805000
  80191c:	e8 b3 ee ff ff       	call   8007d4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801921:	8b 45 0c             	mov    0xc(%ebp),%eax
  801924:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801929:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192c:	b8 01 00 00 00       	mov    $0x1,%eax
  801931:	e8 00 fe ff ff       	call   801736 <fsipc>
  801936:	89 c3                	mov    %eax,%ebx
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 19                	js     801958 <open+0x75>
	return fd2num(fd);
  80193f:	83 ec 0c             	sub    $0xc,%esp
  801942:	ff 75 f4             	pushl  -0xc(%ebp)
  801945:	e8 5a f8 ff ff       	call   8011a4 <fd2num>
  80194a:	89 c3                	mov    %eax,%ebx
  80194c:	83 c4 10             	add    $0x10,%esp
}
  80194f:	89 d8                	mov    %ebx,%eax
  801951:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801954:	5b                   	pop    %ebx
  801955:	5e                   	pop    %esi
  801956:	5d                   	pop    %ebp
  801957:	c3                   	ret    
		fd_close(fd, 0);
  801958:	83 ec 08             	sub    $0x8,%esp
  80195b:	6a 00                	push   $0x0
  80195d:	ff 75 f4             	pushl  -0xc(%ebp)
  801960:	e8 61 f9 ff ff       	call   8012c6 <fd_close>
		return r;
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	eb e5                	jmp    80194f <open+0x6c>
		return -E_BAD_PATH;
  80196a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80196f:	eb de                	jmp    80194f <open+0x6c>

00801971 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801977:	ba 00 00 00 00       	mov    $0x0,%edx
  80197c:	b8 08 00 00 00       	mov    $0x8,%eax
  801981:	e8 b0 fd ff ff       	call   801736 <fsipc>
}
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	56                   	push   %esi
  80198c:	53                   	push   %ebx
  80198d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801990:	83 ec 0c             	sub    $0xc,%esp
  801993:	ff 75 08             	pushl  0x8(%ebp)
  801996:	e8 19 f8 ff ff       	call   8011b4 <fd2data>
  80199b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80199d:	83 c4 08             	add    $0x8,%esp
  8019a0:	68 9f 26 80 00       	push   $0x80269f
  8019a5:	53                   	push   %ebx
  8019a6:	e8 29 ee ff ff       	call   8007d4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ab:	8b 46 04             	mov    0x4(%esi),%eax
  8019ae:	2b 06                	sub    (%esi),%eax
  8019b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019bd:	00 00 00 
	stat->st_dev = &devpipe;
  8019c0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019c7:	30 80 00 
	return 0;
}
  8019ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d2:	5b                   	pop    %ebx
  8019d3:	5e                   	pop    %esi
  8019d4:	5d                   	pop    %ebp
  8019d5:	c3                   	ret    

008019d6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	53                   	push   %ebx
  8019da:	83 ec 0c             	sub    $0xc,%esp
  8019dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019e0:	53                   	push   %ebx
  8019e1:	6a 00                	push   $0x0
  8019e3:	e8 6a f2 ff ff       	call   800c52 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019e8:	89 1c 24             	mov    %ebx,(%esp)
  8019eb:	e8 c4 f7 ff ff       	call   8011b4 <fd2data>
  8019f0:	83 c4 08             	add    $0x8,%esp
  8019f3:	50                   	push   %eax
  8019f4:	6a 00                	push   $0x0
  8019f6:	e8 57 f2 ff ff       	call   800c52 <sys_page_unmap>
}
  8019fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <_pipeisclosed>:
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	57                   	push   %edi
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	83 ec 1c             	sub    $0x1c,%esp
  801a09:	89 c7                	mov    %eax,%edi
  801a0b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a0d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a12:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a15:	83 ec 0c             	sub    $0xc,%esp
  801a18:	57                   	push   %edi
  801a19:	e8 0f 05 00 00       	call   801f2d <pageref>
  801a1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a21:	89 34 24             	mov    %esi,(%esp)
  801a24:	e8 04 05 00 00       	call   801f2d <pageref>
		nn = thisenv->env_runs;
  801a29:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a2f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	39 cb                	cmp    %ecx,%ebx
  801a37:	74 1b                	je     801a54 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a39:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a3c:	75 cf                	jne    801a0d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a3e:	8b 42 58             	mov    0x58(%edx),%eax
  801a41:	6a 01                	push   $0x1
  801a43:	50                   	push   %eax
  801a44:	53                   	push   %ebx
  801a45:	68 a6 26 80 00       	push   $0x8026a6
  801a4a:	e8 66 e7 ff ff       	call   8001b5 <cprintf>
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	eb b9                	jmp    801a0d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a54:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a57:	0f 94 c0             	sete   %al
  801a5a:	0f b6 c0             	movzbl %al,%eax
}
  801a5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a60:	5b                   	pop    %ebx
  801a61:	5e                   	pop    %esi
  801a62:	5f                   	pop    %edi
  801a63:	5d                   	pop    %ebp
  801a64:	c3                   	ret    

00801a65 <devpipe_write>:
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	57                   	push   %edi
  801a69:	56                   	push   %esi
  801a6a:	53                   	push   %ebx
  801a6b:	83 ec 28             	sub    $0x28,%esp
  801a6e:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a71:	56                   	push   %esi
  801a72:	e8 3d f7 ff ff       	call   8011b4 <fd2data>
  801a77:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	bf 00 00 00 00       	mov    $0x0,%edi
  801a81:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a84:	74 4f                	je     801ad5 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a86:	8b 43 04             	mov    0x4(%ebx),%eax
  801a89:	8b 0b                	mov    (%ebx),%ecx
  801a8b:	8d 51 20             	lea    0x20(%ecx),%edx
  801a8e:	39 d0                	cmp    %edx,%eax
  801a90:	72 14                	jb     801aa6 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801a92:	89 da                	mov    %ebx,%edx
  801a94:	89 f0                	mov    %esi,%eax
  801a96:	e8 65 ff ff ff       	call   801a00 <_pipeisclosed>
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	75 3a                	jne    801ad9 <devpipe_write+0x74>
			sys_yield();
  801a9f:	e8 0a f1 ff ff       	call   800bae <sys_yield>
  801aa4:	eb e0                	jmp    801a86 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aad:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ab0:	89 c2                	mov    %eax,%edx
  801ab2:	c1 fa 1f             	sar    $0x1f,%edx
  801ab5:	89 d1                	mov    %edx,%ecx
  801ab7:	c1 e9 1b             	shr    $0x1b,%ecx
  801aba:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801abd:	83 e2 1f             	and    $0x1f,%edx
  801ac0:	29 ca                	sub    %ecx,%edx
  801ac2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ac6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aca:	83 c0 01             	add    $0x1,%eax
  801acd:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ad0:	83 c7 01             	add    $0x1,%edi
  801ad3:	eb ac                	jmp    801a81 <devpipe_write+0x1c>
	return i;
  801ad5:	89 f8                	mov    %edi,%eax
  801ad7:	eb 05                	jmp    801ade <devpipe_write+0x79>
				return 0;
  801ad9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5f                   	pop    %edi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <devpipe_read>:
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	57                   	push   %edi
  801aea:	56                   	push   %esi
  801aeb:	53                   	push   %ebx
  801aec:	83 ec 18             	sub    $0x18,%esp
  801aef:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801af2:	57                   	push   %edi
  801af3:	e8 bc f6 ff ff       	call   8011b4 <fd2data>
  801af8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	be 00 00 00 00       	mov    $0x0,%esi
  801b02:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b05:	74 47                	je     801b4e <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801b07:	8b 03                	mov    (%ebx),%eax
  801b09:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b0c:	75 22                	jne    801b30 <devpipe_read+0x4a>
			if (i > 0)
  801b0e:	85 f6                	test   %esi,%esi
  801b10:	75 14                	jne    801b26 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801b12:	89 da                	mov    %ebx,%edx
  801b14:	89 f8                	mov    %edi,%eax
  801b16:	e8 e5 fe ff ff       	call   801a00 <_pipeisclosed>
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	75 33                	jne    801b52 <devpipe_read+0x6c>
			sys_yield();
  801b1f:	e8 8a f0 ff ff       	call   800bae <sys_yield>
  801b24:	eb e1                	jmp    801b07 <devpipe_read+0x21>
				return i;
  801b26:	89 f0                	mov    %esi,%eax
}
  801b28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2b:	5b                   	pop    %ebx
  801b2c:	5e                   	pop    %esi
  801b2d:	5f                   	pop    %edi
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b30:	99                   	cltd   
  801b31:	c1 ea 1b             	shr    $0x1b,%edx
  801b34:	01 d0                	add    %edx,%eax
  801b36:	83 e0 1f             	and    $0x1f,%eax
  801b39:	29 d0                	sub    %edx,%eax
  801b3b:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b43:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b46:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b49:	83 c6 01             	add    $0x1,%esi
  801b4c:	eb b4                	jmp    801b02 <devpipe_read+0x1c>
	return i;
  801b4e:	89 f0                	mov    %esi,%eax
  801b50:	eb d6                	jmp    801b28 <devpipe_read+0x42>
				return 0;
  801b52:	b8 00 00 00 00       	mov    $0x0,%eax
  801b57:	eb cf                	jmp    801b28 <devpipe_read+0x42>

00801b59 <pipe>:
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	56                   	push   %esi
  801b5d:	53                   	push   %ebx
  801b5e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b64:	50                   	push   %eax
  801b65:	e8 61 f6 ff ff       	call   8011cb <fd_alloc>
  801b6a:	89 c3                	mov    %eax,%ebx
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 5b                	js     801bce <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b73:	83 ec 04             	sub    $0x4,%esp
  801b76:	68 07 04 00 00       	push   $0x407
  801b7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7e:	6a 00                	push   $0x0
  801b80:	e8 48 f0 ff ff       	call   800bcd <sys_page_alloc>
  801b85:	89 c3                	mov    %eax,%ebx
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	78 40                	js     801bce <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801b8e:	83 ec 0c             	sub    $0xc,%esp
  801b91:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b94:	50                   	push   %eax
  801b95:	e8 31 f6 ff ff       	call   8011cb <fd_alloc>
  801b9a:	89 c3                	mov    %eax,%ebx
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	78 1b                	js     801bbe <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba3:	83 ec 04             	sub    $0x4,%esp
  801ba6:	68 07 04 00 00       	push   $0x407
  801bab:	ff 75 f0             	pushl  -0x10(%ebp)
  801bae:	6a 00                	push   $0x0
  801bb0:	e8 18 f0 ff ff       	call   800bcd <sys_page_alloc>
  801bb5:	89 c3                	mov    %eax,%ebx
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	79 19                	jns    801bd7 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801bbe:	83 ec 08             	sub    $0x8,%esp
  801bc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc4:	6a 00                	push   $0x0
  801bc6:	e8 87 f0 ff ff       	call   800c52 <sys_page_unmap>
  801bcb:	83 c4 10             	add    $0x10,%esp
}
  801bce:	89 d8                	mov    %ebx,%eax
  801bd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    
	va = fd2data(fd0);
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	ff 75 f4             	pushl  -0xc(%ebp)
  801bdd:	e8 d2 f5 ff ff       	call   8011b4 <fd2data>
  801be2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be4:	83 c4 0c             	add    $0xc,%esp
  801be7:	68 07 04 00 00       	push   $0x407
  801bec:	50                   	push   %eax
  801bed:	6a 00                	push   $0x0
  801bef:	e8 d9 ef ff ff       	call   800bcd <sys_page_alloc>
  801bf4:	89 c3                	mov    %eax,%ebx
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	0f 88 8c 00 00 00    	js     801c8d <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c01:	83 ec 0c             	sub    $0xc,%esp
  801c04:	ff 75 f0             	pushl  -0x10(%ebp)
  801c07:	e8 a8 f5 ff ff       	call   8011b4 <fd2data>
  801c0c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c13:	50                   	push   %eax
  801c14:	6a 00                	push   $0x0
  801c16:	56                   	push   %esi
  801c17:	6a 00                	push   $0x0
  801c19:	e8 f2 ef ff ff       	call   800c10 <sys_page_map>
  801c1e:	89 c3                	mov    %eax,%ebx
  801c20:	83 c4 20             	add    $0x20,%esp
  801c23:	85 c0                	test   %eax,%eax
  801c25:	78 58                	js     801c7f <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c30:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c35:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c3f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c45:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c51:	83 ec 0c             	sub    $0xc,%esp
  801c54:	ff 75 f4             	pushl  -0xc(%ebp)
  801c57:	e8 48 f5 ff ff       	call   8011a4 <fd2num>
  801c5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c61:	83 c4 04             	add    $0x4,%esp
  801c64:	ff 75 f0             	pushl  -0x10(%ebp)
  801c67:	e8 38 f5 ff ff       	call   8011a4 <fd2num>
  801c6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c7a:	e9 4f ff ff ff       	jmp    801bce <pipe+0x75>
	sys_page_unmap(0, va);
  801c7f:	83 ec 08             	sub    $0x8,%esp
  801c82:	56                   	push   %esi
  801c83:	6a 00                	push   $0x0
  801c85:	e8 c8 ef ff ff       	call   800c52 <sys_page_unmap>
  801c8a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c8d:	83 ec 08             	sub    $0x8,%esp
  801c90:	ff 75 f0             	pushl  -0x10(%ebp)
  801c93:	6a 00                	push   $0x0
  801c95:	e8 b8 ef ff ff       	call   800c52 <sys_page_unmap>
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	e9 1c ff ff ff       	jmp    801bbe <pipe+0x65>

00801ca2 <pipeisclosed>:
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ca8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cab:	50                   	push   %eax
  801cac:	ff 75 08             	pushl  0x8(%ebp)
  801caf:	e8 66 f5 ff ff       	call   80121a <fd_lookup>
  801cb4:	83 c4 10             	add    $0x10,%esp
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	78 18                	js     801cd3 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801cbb:	83 ec 0c             	sub    $0xc,%esp
  801cbe:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc1:	e8 ee f4 ff ff       	call   8011b4 <fd2data>
	return _pipeisclosed(fd, p);
  801cc6:	89 c2                	mov    %eax,%edx
  801cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccb:	e8 30 fd ff ff       	call   801a00 <_pipeisclosed>
  801cd0:	83 c4 10             	add    $0x10,%esp
}
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    

00801cd5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    

00801cdf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ce5:	68 be 26 80 00       	push   $0x8026be
  801cea:	ff 75 0c             	pushl  0xc(%ebp)
  801ced:	e8 e2 ea ff ff       	call   8007d4 <strcpy>
	return 0;
}
  801cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf7:	c9                   	leave  
  801cf8:	c3                   	ret    

00801cf9 <devcons_write>:
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	57                   	push   %edi
  801cfd:	56                   	push   %esi
  801cfe:	53                   	push   %ebx
  801cff:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d05:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d0a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d10:	eb 2f                	jmp    801d41 <devcons_write+0x48>
		m = n - tot;
  801d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d15:	29 f3                	sub    %esi,%ebx
  801d17:	83 fb 7f             	cmp    $0x7f,%ebx
  801d1a:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d1f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d22:	83 ec 04             	sub    $0x4,%esp
  801d25:	53                   	push   %ebx
  801d26:	89 f0                	mov    %esi,%eax
  801d28:	03 45 0c             	add    0xc(%ebp),%eax
  801d2b:	50                   	push   %eax
  801d2c:	57                   	push   %edi
  801d2d:	e8 30 ec ff ff       	call   800962 <memmove>
		sys_cputs(buf, m);
  801d32:	83 c4 08             	add    $0x8,%esp
  801d35:	53                   	push   %ebx
  801d36:	57                   	push   %edi
  801d37:	e8 d5 ed ff ff       	call   800b11 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d3c:	01 de                	add    %ebx,%esi
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d44:	72 cc                	jb     801d12 <devcons_write+0x19>
}
  801d46:	89 f0                	mov    %esi,%eax
  801d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d4b:	5b                   	pop    %ebx
  801d4c:	5e                   	pop    %esi
  801d4d:	5f                   	pop    %edi
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    

00801d50 <devcons_read>:
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	83 ec 08             	sub    $0x8,%esp
  801d56:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d5f:	75 07                	jne    801d68 <devcons_read+0x18>
}
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    
		sys_yield();
  801d63:	e8 46 ee ff ff       	call   800bae <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d68:	e8 c2 ed ff ff       	call   800b2f <sys_cgetc>
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	74 f2                	je     801d63 <devcons_read+0x13>
	if (c < 0)
  801d71:	85 c0                	test   %eax,%eax
  801d73:	78 ec                	js     801d61 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801d75:	83 f8 04             	cmp    $0x4,%eax
  801d78:	74 0c                	je     801d86 <devcons_read+0x36>
	*(char*)vbuf = c;
  801d7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d7d:	88 02                	mov    %al,(%edx)
	return 1;
  801d7f:	b8 01 00 00 00       	mov    $0x1,%eax
  801d84:	eb db                	jmp    801d61 <devcons_read+0x11>
		return 0;
  801d86:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8b:	eb d4                	jmp    801d61 <devcons_read+0x11>

00801d8d <cputchar>:
{
  801d8d:	55                   	push   %ebp
  801d8e:	89 e5                	mov    %esp,%ebp
  801d90:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d93:	8b 45 08             	mov    0x8(%ebp),%eax
  801d96:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d99:	6a 01                	push   $0x1
  801d9b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d9e:	50                   	push   %eax
  801d9f:	e8 6d ed ff ff       	call   800b11 <sys_cputs>
}
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    

00801da9 <getchar>:
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801daf:	6a 01                	push   $0x1
  801db1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db4:	50                   	push   %eax
  801db5:	6a 00                	push   $0x0
  801db7:	e8 cf f6 ff ff       	call   80148b <read>
	if (r < 0)
  801dbc:	83 c4 10             	add    $0x10,%esp
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	78 08                	js     801dcb <getchar+0x22>
	if (r < 1)
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	7e 06                	jle    801dcd <getchar+0x24>
	return c;
  801dc7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801dcb:	c9                   	leave  
  801dcc:	c3                   	ret    
		return -E_EOF;
  801dcd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801dd2:	eb f7                	jmp    801dcb <getchar+0x22>

00801dd4 <iscons>:
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ddd:	50                   	push   %eax
  801dde:	ff 75 08             	pushl  0x8(%ebp)
  801de1:	e8 34 f4 ff ff       	call   80121a <fd_lookup>
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	85 c0                	test   %eax,%eax
  801deb:	78 11                	js     801dfe <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801df6:	39 10                	cmp    %edx,(%eax)
  801df8:	0f 94 c0             	sete   %al
  801dfb:	0f b6 c0             	movzbl %al,%eax
}
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <opencons>:
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e09:	50                   	push   %eax
  801e0a:	e8 bc f3 ff ff       	call   8011cb <fd_alloc>
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 3a                	js     801e50 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e16:	83 ec 04             	sub    $0x4,%esp
  801e19:	68 07 04 00 00       	push   $0x407
  801e1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e21:	6a 00                	push   $0x0
  801e23:	e8 a5 ed ff ff       	call   800bcd <sys_page_alloc>
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	78 21                	js     801e50 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e32:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e38:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e44:	83 ec 0c             	sub    $0xc,%esp
  801e47:	50                   	push   %eax
  801e48:	e8 57 f3 ff ff       	call   8011a4 <fd2num>
  801e4d:	83 c4 10             	add    $0x10,%esp
}
  801e50:	c9                   	leave  
  801e51:	c3                   	ret    

00801e52 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	56                   	push   %esi
  801e56:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e57:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e5a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e60:	e8 2a ed ff ff       	call   800b8f <sys_getenvid>
  801e65:	83 ec 0c             	sub    $0xc,%esp
  801e68:	ff 75 0c             	pushl  0xc(%ebp)
  801e6b:	ff 75 08             	pushl  0x8(%ebp)
  801e6e:	56                   	push   %esi
  801e6f:	50                   	push   %eax
  801e70:	68 cc 26 80 00       	push   $0x8026cc
  801e75:	e8 3b e3 ff ff       	call   8001b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e7a:	83 c4 18             	add    $0x18,%esp
  801e7d:	53                   	push   %ebx
  801e7e:	ff 75 10             	pushl  0x10(%ebp)
  801e81:	e8 de e2 ff ff       	call   800164 <vcprintf>
	cprintf("\n");
  801e86:	c7 04 24 b7 26 80 00 	movl   $0x8026b7,(%esp)
  801e8d:	e8 23 e3 ff ff       	call   8001b5 <cprintf>
  801e92:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e95:	cc                   	int3   
  801e96:	eb fd                	jmp    801e95 <_panic+0x43>

00801e98 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e9e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ea5:	74 20                	je     801ec7 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaa:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801eaf:	83 ec 08             	sub    $0x8,%esp
  801eb2:	68 07 1f 80 00       	push   $0x801f07
  801eb7:	6a 00                	push   $0x0
  801eb9:	e8 5a ee ff ff       	call   800d18 <sys_env_set_pgfault_upcall>
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	78 2e                	js     801ef3 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801ec7:	83 ec 04             	sub    $0x4,%esp
  801eca:	6a 07                	push   $0x7
  801ecc:	68 00 f0 bf ee       	push   $0xeebff000
  801ed1:	6a 00                	push   $0x0
  801ed3:	e8 f5 ec ff ff       	call   800bcd <sys_page_alloc>
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	85 c0                	test   %eax,%eax
  801edd:	79 c8                	jns    801ea7 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801edf:	83 ec 04             	sub    $0x4,%esp
  801ee2:	68 f0 26 80 00       	push   $0x8026f0
  801ee7:	6a 21                	push   $0x21
  801ee9:	68 54 27 80 00       	push   $0x802754
  801eee:	e8 5f ff ff ff       	call   801e52 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801ef3:	83 ec 04             	sub    $0x4,%esp
  801ef6:	68 1c 27 80 00       	push   $0x80271c
  801efb:	6a 27                	push   $0x27
  801efd:	68 54 27 80 00       	push   $0x802754
  801f02:	e8 4b ff ff ff       	call   801e52 <_panic>

00801f07 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f07:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f08:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f0d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f0f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801f12:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801f16:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801f19:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  801f1d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f21:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801f23:	83 c4 08             	add    $0x8,%esp
	popal
  801f26:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801f27:	83 c4 04             	add    $0x4,%esp
	popfl
  801f2a:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f2b:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f2c:	c3                   	ret    

00801f2d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f33:	89 d0                	mov    %edx,%eax
  801f35:	c1 e8 16             	shr    $0x16,%eax
  801f38:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f3f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f44:	f6 c1 01             	test   $0x1,%cl
  801f47:	74 1d                	je     801f66 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f49:	c1 ea 0c             	shr    $0xc,%edx
  801f4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f53:	f6 c2 01             	test   $0x1,%dl
  801f56:	74 0e                	je     801f66 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f58:	c1 ea 0c             	shr    $0xc,%edx
  801f5b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f62:	ef 
  801f63:	0f b7 c0             	movzwl %ax,%eax
}
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    
  801f68:	66 90                	xchg   %ax,%ax
  801f6a:	66 90                	xchg   %ax,%ax
  801f6c:	66 90                	xchg   %ax,%ax
  801f6e:	66 90                	xchg   %ax,%ax

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f7b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801f7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f83:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801f87:	85 d2                	test   %edx,%edx
  801f89:	75 35                	jne    801fc0 <__udivdi3+0x50>
  801f8b:	39 f3                	cmp    %esi,%ebx
  801f8d:	0f 87 bd 00 00 00    	ja     802050 <__udivdi3+0xe0>
  801f93:	85 db                	test   %ebx,%ebx
  801f95:	89 d9                	mov    %ebx,%ecx
  801f97:	75 0b                	jne    801fa4 <__udivdi3+0x34>
  801f99:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9e:	31 d2                	xor    %edx,%edx
  801fa0:	f7 f3                	div    %ebx
  801fa2:	89 c1                	mov    %eax,%ecx
  801fa4:	31 d2                	xor    %edx,%edx
  801fa6:	89 f0                	mov    %esi,%eax
  801fa8:	f7 f1                	div    %ecx
  801faa:	89 c6                	mov    %eax,%esi
  801fac:	89 e8                	mov    %ebp,%eax
  801fae:	89 f7                	mov    %esi,%edi
  801fb0:	f7 f1                	div    %ecx
  801fb2:	89 fa                	mov    %edi,%edx
  801fb4:	83 c4 1c             	add    $0x1c,%esp
  801fb7:	5b                   	pop    %ebx
  801fb8:	5e                   	pop    %esi
  801fb9:	5f                   	pop    %edi
  801fba:	5d                   	pop    %ebp
  801fbb:	c3                   	ret    
  801fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	39 f2                	cmp    %esi,%edx
  801fc2:	77 7c                	ja     802040 <__udivdi3+0xd0>
  801fc4:	0f bd fa             	bsr    %edx,%edi
  801fc7:	83 f7 1f             	xor    $0x1f,%edi
  801fca:	0f 84 98 00 00 00    	je     802068 <__udivdi3+0xf8>
  801fd0:	89 f9                	mov    %edi,%ecx
  801fd2:	b8 20 00 00 00       	mov    $0x20,%eax
  801fd7:	29 f8                	sub    %edi,%eax
  801fd9:	d3 e2                	shl    %cl,%edx
  801fdb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fdf:	89 c1                	mov    %eax,%ecx
  801fe1:	89 da                	mov    %ebx,%edx
  801fe3:	d3 ea                	shr    %cl,%edx
  801fe5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801fe9:	09 d1                	or     %edx,%ecx
  801feb:	89 f2                	mov    %esi,%edx
  801fed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ff1:	89 f9                	mov    %edi,%ecx
  801ff3:	d3 e3                	shl    %cl,%ebx
  801ff5:	89 c1                	mov    %eax,%ecx
  801ff7:	d3 ea                	shr    %cl,%edx
  801ff9:	89 f9                	mov    %edi,%ecx
  801ffb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801fff:	d3 e6                	shl    %cl,%esi
  802001:	89 eb                	mov    %ebp,%ebx
  802003:	89 c1                	mov    %eax,%ecx
  802005:	d3 eb                	shr    %cl,%ebx
  802007:	09 de                	or     %ebx,%esi
  802009:	89 f0                	mov    %esi,%eax
  80200b:	f7 74 24 08          	divl   0x8(%esp)
  80200f:	89 d6                	mov    %edx,%esi
  802011:	89 c3                	mov    %eax,%ebx
  802013:	f7 64 24 0c          	mull   0xc(%esp)
  802017:	39 d6                	cmp    %edx,%esi
  802019:	72 0c                	jb     802027 <__udivdi3+0xb7>
  80201b:	89 f9                	mov    %edi,%ecx
  80201d:	d3 e5                	shl    %cl,%ebp
  80201f:	39 c5                	cmp    %eax,%ebp
  802021:	73 5d                	jae    802080 <__udivdi3+0x110>
  802023:	39 d6                	cmp    %edx,%esi
  802025:	75 59                	jne    802080 <__udivdi3+0x110>
  802027:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80202a:	31 ff                	xor    %edi,%edi
  80202c:	89 fa                	mov    %edi,%edx
  80202e:	83 c4 1c             	add    $0x1c,%esp
  802031:	5b                   	pop    %ebx
  802032:	5e                   	pop    %esi
  802033:	5f                   	pop    %edi
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    
  802036:	8d 76 00             	lea    0x0(%esi),%esi
  802039:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802040:	31 ff                	xor    %edi,%edi
  802042:	31 c0                	xor    %eax,%eax
  802044:	89 fa                	mov    %edi,%edx
  802046:	83 c4 1c             	add    $0x1c,%esp
  802049:	5b                   	pop    %ebx
  80204a:	5e                   	pop    %esi
  80204b:	5f                   	pop    %edi
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    
  80204e:	66 90                	xchg   %ax,%ax
  802050:	31 ff                	xor    %edi,%edi
  802052:	89 e8                	mov    %ebp,%eax
  802054:	89 f2                	mov    %esi,%edx
  802056:	f7 f3                	div    %ebx
  802058:	89 fa                	mov    %edi,%edx
  80205a:	83 c4 1c             	add    $0x1c,%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5f                   	pop    %edi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802068:	39 f2                	cmp    %esi,%edx
  80206a:	72 06                	jb     802072 <__udivdi3+0x102>
  80206c:	31 c0                	xor    %eax,%eax
  80206e:	39 eb                	cmp    %ebp,%ebx
  802070:	77 d2                	ja     802044 <__udivdi3+0xd4>
  802072:	b8 01 00 00 00       	mov    $0x1,%eax
  802077:	eb cb                	jmp    802044 <__udivdi3+0xd4>
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d8                	mov    %ebx,%eax
  802082:	31 ff                	xor    %edi,%edi
  802084:	eb be                	jmp    802044 <__udivdi3+0xd4>
  802086:	66 90                	xchg   %ax,%ax
  802088:	66 90                	xchg   %ax,%ax
  80208a:	66 90                	xchg   %ax,%ax
  80208c:	66 90                	xchg   %ax,%ax
  80208e:	66 90                	xchg   %ax,%ax

00802090 <__umoddi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80209b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80209f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 ed                	test   %ebp,%ebp
  8020a9:	89 f0                	mov    %esi,%eax
  8020ab:	89 da                	mov    %ebx,%edx
  8020ad:	75 19                	jne    8020c8 <__umoddi3+0x38>
  8020af:	39 df                	cmp    %ebx,%edi
  8020b1:	0f 86 b1 00 00 00    	jbe    802168 <__umoddi3+0xd8>
  8020b7:	f7 f7                	div    %edi
  8020b9:	89 d0                	mov    %edx,%eax
  8020bb:	31 d2                	xor    %edx,%edx
  8020bd:	83 c4 1c             	add    $0x1c,%esp
  8020c0:	5b                   	pop    %ebx
  8020c1:	5e                   	pop    %esi
  8020c2:	5f                   	pop    %edi
  8020c3:	5d                   	pop    %ebp
  8020c4:	c3                   	ret    
  8020c5:	8d 76 00             	lea    0x0(%esi),%esi
  8020c8:	39 dd                	cmp    %ebx,%ebp
  8020ca:	77 f1                	ja     8020bd <__umoddi3+0x2d>
  8020cc:	0f bd cd             	bsr    %ebp,%ecx
  8020cf:	83 f1 1f             	xor    $0x1f,%ecx
  8020d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020d6:	0f 84 b4 00 00 00    	je     802190 <__umoddi3+0x100>
  8020dc:	b8 20 00 00 00       	mov    $0x20,%eax
  8020e1:	89 c2                	mov    %eax,%edx
  8020e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020e7:	29 c2                	sub    %eax,%edx
  8020e9:	89 c1                	mov    %eax,%ecx
  8020eb:	89 f8                	mov    %edi,%eax
  8020ed:	d3 e5                	shl    %cl,%ebp
  8020ef:	89 d1                	mov    %edx,%ecx
  8020f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8020f5:	d3 e8                	shr    %cl,%eax
  8020f7:	09 c5                	or     %eax,%ebp
  8020f9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020fd:	89 c1                	mov    %eax,%ecx
  8020ff:	d3 e7                	shl    %cl,%edi
  802101:	89 d1                	mov    %edx,%ecx
  802103:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802107:	89 df                	mov    %ebx,%edi
  802109:	d3 ef                	shr    %cl,%edi
  80210b:	89 c1                	mov    %eax,%ecx
  80210d:	89 f0                	mov    %esi,%eax
  80210f:	d3 e3                	shl    %cl,%ebx
  802111:	89 d1                	mov    %edx,%ecx
  802113:	89 fa                	mov    %edi,%edx
  802115:	d3 e8                	shr    %cl,%eax
  802117:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80211c:	09 d8                	or     %ebx,%eax
  80211e:	f7 f5                	div    %ebp
  802120:	d3 e6                	shl    %cl,%esi
  802122:	89 d1                	mov    %edx,%ecx
  802124:	f7 64 24 08          	mull   0x8(%esp)
  802128:	39 d1                	cmp    %edx,%ecx
  80212a:	89 c3                	mov    %eax,%ebx
  80212c:	89 d7                	mov    %edx,%edi
  80212e:	72 06                	jb     802136 <__umoddi3+0xa6>
  802130:	75 0e                	jne    802140 <__umoddi3+0xb0>
  802132:	39 c6                	cmp    %eax,%esi
  802134:	73 0a                	jae    802140 <__umoddi3+0xb0>
  802136:	2b 44 24 08          	sub    0x8(%esp),%eax
  80213a:	19 ea                	sbb    %ebp,%edx
  80213c:	89 d7                	mov    %edx,%edi
  80213e:	89 c3                	mov    %eax,%ebx
  802140:	89 ca                	mov    %ecx,%edx
  802142:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802147:	29 de                	sub    %ebx,%esi
  802149:	19 fa                	sbb    %edi,%edx
  80214b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80214f:	89 d0                	mov    %edx,%eax
  802151:	d3 e0                	shl    %cl,%eax
  802153:	89 d9                	mov    %ebx,%ecx
  802155:	d3 ee                	shr    %cl,%esi
  802157:	d3 ea                	shr    %cl,%edx
  802159:	09 f0                	or     %esi,%eax
  80215b:	83 c4 1c             	add    $0x1c,%esp
  80215e:	5b                   	pop    %ebx
  80215f:	5e                   	pop    %esi
  802160:	5f                   	pop    %edi
  802161:	5d                   	pop    %ebp
  802162:	c3                   	ret    
  802163:	90                   	nop
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	85 ff                	test   %edi,%edi
  80216a:	89 f9                	mov    %edi,%ecx
  80216c:	75 0b                	jne    802179 <__umoddi3+0xe9>
  80216e:	b8 01 00 00 00       	mov    $0x1,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	f7 f7                	div    %edi
  802177:	89 c1                	mov    %eax,%ecx
  802179:	89 d8                	mov    %ebx,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f1                	div    %ecx
  80217f:	89 f0                	mov    %esi,%eax
  802181:	f7 f1                	div    %ecx
  802183:	e9 31 ff ff ff       	jmp    8020b9 <__umoddi3+0x29>
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	39 dd                	cmp    %ebx,%ebp
  802192:	72 08                	jb     80219c <__umoddi3+0x10c>
  802194:	39 f7                	cmp    %esi,%edi
  802196:	0f 87 21 ff ff ff    	ja     8020bd <__umoddi3+0x2d>
  80219c:	89 da                	mov    %ebx,%edx
  80219e:	89 f0                	mov    %esi,%eax
  8021a0:	29 f8                	sub    %edi,%eax
  8021a2:	19 ea                	sbb    %ebp,%edx
  8021a4:	e9 14 ff ff ff       	jmp    8020bd <__umoddi3+0x2d>
