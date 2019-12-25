
obj/user/pingpongs.debug：     文件格式 elf32-i386


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
  80002c:	e8 d2 00 00 00       	call   800103 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 98 10 00 00       	call   8010d9 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 74                	jne    8000bc <umain+0x89>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  800048:	83 ec 04             	sub    $0x4,%esp
  80004b:	6a 00                	push   $0x0
  80004d:	6a 00                	push   $0x0
  80004f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800052:	50                   	push   %eax
  800053:	e8 9b 10 00 00       	call   8010f3 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  800058:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80005e:	8b 7b 48             	mov    0x48(%ebx),%edi
  800061:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800064:	a1 04 40 80 00       	mov    0x804004,%eax
  800069:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80006c:	e8 61 0b 00 00       	call   800bd2 <sys_getenvid>
  800071:	83 c4 08             	add    $0x8,%esp
  800074:	57                   	push   %edi
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007a:	50                   	push   %eax
  80007b:	68 30 22 80 00       	push   $0x802230
  800080:	e8 73 01 00 00       	call   8001f8 <cprintf>
		if (val == 10)
  800085:	a1 04 40 80 00       	mov    0x804004,%eax
  80008a:	83 c4 20             	add    $0x20,%esp
  80008d:	83 f8 0a             	cmp    $0xa,%eax
  800090:	74 22                	je     8000b4 <umain+0x81>
			return;
		++val;
  800092:	83 c0 01             	add    $0x1,%eax
  800095:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  80009a:	6a 00                	push   $0x0
  80009c:	6a 00                	push   $0x0
  80009e:	6a 00                	push   $0x0
  8000a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a3:	e8 b2 10 00 00       	call   80115a <ipc_send>
		if (val == 10)
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000b2:	75 94                	jne    800048 <umain+0x15>
			return;
	}

}
  8000b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000bc:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000c2:	e8 0b 0b 00 00       	call   800bd2 <sys_getenvid>
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	53                   	push   %ebx
  8000cb:	50                   	push   %eax
  8000cc:	68 00 22 80 00       	push   $0x802200
  8000d1:	e8 22 01 00 00       	call   8001f8 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000d9:	e8 f4 0a 00 00       	call   800bd2 <sys_getenvid>
  8000de:	83 c4 0c             	add    $0xc,%esp
  8000e1:	53                   	push   %ebx
  8000e2:	50                   	push   %eax
  8000e3:	68 1a 22 80 00       	push   $0x80221a
  8000e8:	e8 0b 01 00 00       	call   8001f8 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000f6:	e8 5f 10 00 00       	call   80115a <ipc_send>
  8000fb:	83 c4 20             	add    $0x20,%esp
  8000fe:	e9 45 ff ff ff       	jmp    800048 <umain+0x15>

00800103 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80010e:	e8 bf 0a 00 00       	call   800bd2 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800120:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 db                	test   %ebx,%ebx
  800127:	7e 07                	jle    800130 <libmain+0x2d>
		binaryname = argv[0];
  800129:	8b 06                	mov    (%esi),%eax
  80012b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800130:	83 ec 08             	sub    $0x8,%esp
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
  800135:	e8 f9 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013a:	e8 0a 00 00 00       	call   800149 <exit>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014f:	e8 69 12 00 00       	call   8013bd <close_all>
	sys_env_destroy(0);
  800154:	83 ec 0c             	sub    $0xc,%esp
  800157:	6a 00                	push   $0x0
  800159:	e8 33 0a 00 00       	call   800b91 <sys_env_destroy>
}
  80015e:	83 c4 10             	add    $0x10,%esp
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	53                   	push   %ebx
  800167:	83 ec 04             	sub    $0x4,%esp
  80016a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016d:	8b 13                	mov    (%ebx),%edx
  80016f:	8d 42 01             	lea    0x1(%edx),%eax
  800172:	89 03                	mov    %eax,(%ebx)
  800174:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800177:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800180:	74 09                	je     80018b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800182:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800186:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800189:	c9                   	leave  
  80018a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80018b:	83 ec 08             	sub    $0x8,%esp
  80018e:	68 ff 00 00 00       	push   $0xff
  800193:	8d 43 08             	lea    0x8(%ebx),%eax
  800196:	50                   	push   %eax
  800197:	e8 b8 09 00 00       	call   800b54 <sys_cputs>
		b->idx = 0;
  80019c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a2:	83 c4 10             	add    $0x10,%esp
  8001a5:	eb db                	jmp    800182 <putch+0x1f>

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	pushl  0xc(%ebp)
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 63 01 80 00       	push   $0x800163
  8001d6:	e8 1a 01 00 00       	call   8002f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 64 09 00 00       	call   800b54 <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	e8 9d ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 1c             	sub    $0x1c,%esp
  800215:	89 c7                	mov    %eax,%edi
  800217:	89 d6                	mov    %edx,%esi
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800222:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800225:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800230:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800233:	39 d3                	cmp    %edx,%ebx
  800235:	72 05                	jb     80023c <printnum+0x30>
  800237:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023a:	77 7a                	ja     8002b6 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	ff 75 18             	pushl  0x18(%ebp)
  800242:	8b 45 14             	mov    0x14(%ebp),%eax
  800245:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800248:	53                   	push   %ebx
  800249:	ff 75 10             	pushl  0x10(%ebp)
  80024c:	83 ec 08             	sub    $0x8,%esp
  80024f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800252:	ff 75 e0             	pushl  -0x20(%ebp)
  800255:	ff 75 dc             	pushl  -0x24(%ebp)
  800258:	ff 75 d8             	pushl  -0x28(%ebp)
  80025b:	e8 50 1d 00 00       	call   801fb0 <__udivdi3>
  800260:	83 c4 18             	add    $0x18,%esp
  800263:	52                   	push   %edx
  800264:	50                   	push   %eax
  800265:	89 f2                	mov    %esi,%edx
  800267:	89 f8                	mov    %edi,%eax
  800269:	e8 9e ff ff ff       	call   80020c <printnum>
  80026e:	83 c4 20             	add    $0x20,%esp
  800271:	eb 13                	jmp    800286 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	56                   	push   %esi
  800277:	ff 75 18             	pushl  0x18(%ebp)
  80027a:	ff d7                	call   *%edi
  80027c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80027f:	83 eb 01             	sub    $0x1,%ebx
  800282:	85 db                	test   %ebx,%ebx
  800284:	7f ed                	jg     800273 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	56                   	push   %esi
  80028a:	83 ec 04             	sub    $0x4,%esp
  80028d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800290:	ff 75 e0             	pushl  -0x20(%ebp)
  800293:	ff 75 dc             	pushl  -0x24(%ebp)
  800296:	ff 75 d8             	pushl  -0x28(%ebp)
  800299:	e8 32 1e 00 00       	call   8020d0 <__umoddi3>
  80029e:	83 c4 14             	add    $0x14,%esp
  8002a1:	0f be 80 60 22 80 00 	movsbl 0x802260(%eax),%eax
  8002a8:	50                   	push   %eax
  8002a9:	ff d7                	call   *%edi
}
  8002ab:	83 c4 10             	add    $0x10,%esp
  8002ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    
  8002b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b9:	eb c4                	jmp    80027f <printnum+0x73>

008002bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c5:	8b 10                	mov    (%eax),%edx
  8002c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ca:	73 0a                	jae    8002d6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cf:	89 08                	mov    %ecx,(%eax)
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	88 02                	mov    %al,(%edx)
}
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <printfmt>:
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e1:	50                   	push   %eax
  8002e2:	ff 75 10             	pushl  0x10(%ebp)
  8002e5:	ff 75 0c             	pushl  0xc(%ebp)
  8002e8:	ff 75 08             	pushl  0x8(%ebp)
  8002eb:	e8 05 00 00 00       	call   8002f5 <vprintfmt>
}
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	c9                   	leave  
  8002f4:	c3                   	ret    

008002f5 <vprintfmt>:
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	57                   	push   %edi
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
  8002fb:	83 ec 2c             	sub    $0x2c,%esp
  8002fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800301:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800304:	8b 7d 10             	mov    0x10(%ebp),%edi
  800307:	e9 c1 03 00 00       	jmp    8006cd <vprintfmt+0x3d8>
		padc = ' ';
  80030c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800310:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800317:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80031e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800325:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8d 47 01             	lea    0x1(%edi),%eax
  80032d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800330:	0f b6 17             	movzbl (%edi),%edx
  800333:	8d 42 dd             	lea    -0x23(%edx),%eax
  800336:	3c 55                	cmp    $0x55,%al
  800338:	0f 87 12 04 00 00    	ja     800750 <vprintfmt+0x45b>
  80033e:	0f b6 c0             	movzbl %al,%eax
  800341:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80034b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80034f:	eb d9                	jmp    80032a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800354:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800358:	eb d0                	jmp    80032a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	0f b6 d2             	movzbl %dl,%edx
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800360:	b8 00 00 00 00       	mov    $0x0,%eax
  800365:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800368:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80036f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800372:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800375:	83 f9 09             	cmp    $0x9,%ecx
  800378:	77 55                	ja     8003cf <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80037a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80037d:	eb e9                	jmp    800368 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80037f:	8b 45 14             	mov    0x14(%ebp),%eax
  800382:	8b 00                	mov    (%eax),%eax
  800384:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800387:	8b 45 14             	mov    0x14(%ebp),%eax
  80038a:	8d 40 04             	lea    0x4(%eax),%eax
  80038d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800393:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800397:	79 91                	jns    80032a <vprintfmt+0x35>
				width = precision, precision = -1;
  800399:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80039c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a6:	eb 82                	jmp    80032a <vprintfmt+0x35>
  8003a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ab:	85 c0                	test   %eax,%eax
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b2:	0f 49 d0             	cmovns %eax,%edx
  8003b5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bb:	e9 6a ff ff ff       	jmp    80032a <vprintfmt+0x35>
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003c3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ca:	e9 5b ff ff ff       	jmp    80032a <vprintfmt+0x35>
  8003cf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003d5:	eb bc                	jmp    800393 <vprintfmt+0x9e>
			lflag++;
  8003d7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003dd:	e9 48 ff ff ff       	jmp    80032a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 78 04             	lea    0x4(%eax),%edi
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	53                   	push   %ebx
  8003ec:	ff 30                	pushl  (%eax)
  8003ee:	ff d6                	call   *%esi
			break;
  8003f0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003f6:	e9 cf 02 00 00       	jmp    8006ca <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8d 78 04             	lea    0x4(%eax),%edi
  800401:	8b 00                	mov    (%eax),%eax
  800403:	99                   	cltd   
  800404:	31 d0                	xor    %edx,%eax
  800406:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800408:	83 f8 0f             	cmp    $0xf,%eax
  80040b:	7f 23                	jg     800430 <vprintfmt+0x13b>
  80040d:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800414:	85 d2                	test   %edx,%edx
  800416:	74 18                	je     800430 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800418:	52                   	push   %edx
  800419:	68 e5 26 80 00       	push   $0x8026e5
  80041e:	53                   	push   %ebx
  80041f:	56                   	push   %esi
  800420:	e8 b3 fe ff ff       	call   8002d8 <printfmt>
  800425:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800428:	89 7d 14             	mov    %edi,0x14(%ebp)
  80042b:	e9 9a 02 00 00       	jmp    8006ca <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800430:	50                   	push   %eax
  800431:	68 78 22 80 00       	push   $0x802278
  800436:	53                   	push   %ebx
  800437:	56                   	push   %esi
  800438:	e8 9b fe ff ff       	call   8002d8 <printfmt>
  80043d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800440:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800443:	e9 82 02 00 00       	jmp    8006ca <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	83 c0 04             	add    $0x4,%eax
  80044e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800456:	85 ff                	test   %edi,%edi
  800458:	b8 71 22 80 00       	mov    $0x802271,%eax
  80045d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800460:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800464:	0f 8e bd 00 00 00    	jle    800527 <vprintfmt+0x232>
  80046a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046e:	75 0e                	jne    80047e <vprintfmt+0x189>
  800470:	89 75 08             	mov    %esi,0x8(%ebp)
  800473:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800476:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800479:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80047c:	eb 6d                	jmp    8004eb <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	ff 75 d0             	pushl  -0x30(%ebp)
  800484:	57                   	push   %edi
  800485:	e8 6e 03 00 00       	call   8007f8 <strnlen>
  80048a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048d:	29 c1                	sub    %eax,%ecx
  80048f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800492:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800495:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800499:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a1:	eb 0f                	jmp    8004b2 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	53                   	push   %ebx
  8004a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004aa:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ac:	83 ef 01             	sub    $0x1,%edi
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 ff                	test   %edi,%edi
  8004b4:	7f ed                	jg     8004a3 <vprintfmt+0x1ae>
  8004b6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004bc:	85 c9                	test   %ecx,%ecx
  8004be:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c3:	0f 49 c1             	cmovns %ecx,%eax
  8004c6:	29 c1                	sub    %eax,%ecx
  8004c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d1:	89 cb                	mov    %ecx,%ebx
  8004d3:	eb 16                	jmp    8004eb <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d9:	75 31                	jne    80050c <vprintfmt+0x217>
					putch(ch, putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	ff 75 0c             	pushl  0xc(%ebp)
  8004e1:	50                   	push   %eax
  8004e2:	ff 55 08             	call   *0x8(%ebp)
  8004e5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e8:	83 eb 01             	sub    $0x1,%ebx
  8004eb:	83 c7 01             	add    $0x1,%edi
  8004ee:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004f2:	0f be c2             	movsbl %dl,%eax
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	74 59                	je     800552 <vprintfmt+0x25d>
  8004f9:	85 f6                	test   %esi,%esi
  8004fb:	78 d8                	js     8004d5 <vprintfmt+0x1e0>
  8004fd:	83 ee 01             	sub    $0x1,%esi
  800500:	79 d3                	jns    8004d5 <vprintfmt+0x1e0>
  800502:	89 df                	mov    %ebx,%edi
  800504:	8b 75 08             	mov    0x8(%ebp),%esi
  800507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050a:	eb 37                	jmp    800543 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80050c:	0f be d2             	movsbl %dl,%edx
  80050f:	83 ea 20             	sub    $0x20,%edx
  800512:	83 fa 5e             	cmp    $0x5e,%edx
  800515:	76 c4                	jbe    8004db <vprintfmt+0x1e6>
					putch('?', putdat);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	ff 75 0c             	pushl  0xc(%ebp)
  80051d:	6a 3f                	push   $0x3f
  80051f:	ff 55 08             	call   *0x8(%ebp)
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	eb c1                	jmp    8004e8 <vprintfmt+0x1f3>
  800527:	89 75 08             	mov    %esi,0x8(%ebp)
  80052a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800530:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800533:	eb b6                	jmp    8004eb <vprintfmt+0x1f6>
				putch(' ', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	53                   	push   %ebx
  800539:	6a 20                	push   $0x20
  80053b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80053d:	83 ef 01             	sub    $0x1,%edi
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	85 ff                	test   %edi,%edi
  800545:	7f ee                	jg     800535 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800547:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80054a:	89 45 14             	mov    %eax,0x14(%ebp)
  80054d:	e9 78 01 00 00       	jmp    8006ca <vprintfmt+0x3d5>
  800552:	89 df                	mov    %ebx,%edi
  800554:	8b 75 08             	mov    0x8(%ebp),%esi
  800557:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055a:	eb e7                	jmp    800543 <vprintfmt+0x24e>
	if (lflag >= 2)
  80055c:	83 f9 01             	cmp    $0x1,%ecx
  80055f:	7e 3f                	jle    8005a0 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8b 50 04             	mov    0x4(%eax),%edx
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 40 08             	lea    0x8(%eax),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800578:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057c:	79 5c                	jns    8005da <vprintfmt+0x2e5>
				putch('-', putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	53                   	push   %ebx
  800582:	6a 2d                	push   $0x2d
  800584:	ff d6                	call   *%esi
				num = -(long long) num;
  800586:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800589:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80058c:	f7 da                	neg    %edx
  80058e:	83 d1 00             	adc    $0x0,%ecx
  800591:	f7 d9                	neg    %ecx
  800593:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800596:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059b:	e9 10 01 00 00       	jmp    8006b0 <vprintfmt+0x3bb>
	else if (lflag)
  8005a0:	85 c9                	test   %ecx,%ecx
  8005a2:	75 1b                	jne    8005bf <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ac:	89 c1                	mov    %eax,%ecx
  8005ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bd:	eb b9                	jmp    800578 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c7:	89 c1                	mov    %eax,%ecx
  8005c9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 40 04             	lea    0x4(%eax),%eax
  8005d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d8:	eb 9e                	jmp    800578 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e5:	e9 c6 00 00 00       	jmp    8006b0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005ea:	83 f9 01             	cmp    $0x1,%ecx
  8005ed:	7e 18                	jle    800607 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f7:	8d 40 08             	lea    0x8(%eax),%eax
  8005fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800602:	e9 a9 00 00 00       	jmp    8006b0 <vprintfmt+0x3bb>
	else if (lflag)
  800607:	85 c9                	test   %ecx,%ecx
  800609:	75 1a                	jne    800625 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8b 10                	mov    (%eax),%edx
  800610:	b9 00 00 00 00       	mov    $0x0,%ecx
  800615:	8d 40 04             	lea    0x4(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800620:	e9 8b 00 00 00       	jmp    8006b0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062f:	8d 40 04             	lea    0x4(%eax),%eax
  800632:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800635:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063a:	eb 74                	jmp    8006b0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80063c:	83 f9 01             	cmp    $0x1,%ecx
  80063f:	7e 15                	jle    800656 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 10                	mov    (%eax),%edx
  800646:	8b 48 04             	mov    0x4(%eax),%ecx
  800649:	8d 40 08             	lea    0x8(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
  800654:	eb 5a                	jmp    8006b0 <vprintfmt+0x3bb>
	else if (lflag)
  800656:	85 c9                	test   %ecx,%ecx
  800658:	75 17                	jne    800671 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8b 10                	mov    (%eax),%edx
  80065f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800664:	8d 40 04             	lea    0x4(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80066a:	b8 08 00 00 00       	mov    $0x8,%eax
  80066f:	eb 3f                	jmp    8006b0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 10                	mov    (%eax),%edx
  800676:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067b:	8d 40 04             	lea    0x4(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800681:	b8 08 00 00 00       	mov    $0x8,%eax
  800686:	eb 28                	jmp    8006b0 <vprintfmt+0x3bb>
			putch('0', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 30                	push   $0x30
  80068e:	ff d6                	call   *%esi
			putch('x', putdat);
  800690:	83 c4 08             	add    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 78                	push   $0x78
  800696:	ff d6                	call   *%esi
			num = (unsigned long long)
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006a2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006a5:	8d 40 04             	lea    0x4(%eax),%eax
  8006a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ab:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006b0:	83 ec 0c             	sub    $0xc,%esp
  8006b3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b7:	57                   	push   %edi
  8006b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bb:	50                   	push   %eax
  8006bc:	51                   	push   %ecx
  8006bd:	52                   	push   %edx
  8006be:	89 da                	mov    %ebx,%edx
  8006c0:	89 f0                	mov    %esi,%eax
  8006c2:	e8 45 fb ff ff       	call   80020c <printnum>
			break;
  8006c7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006cd:	83 c7 01             	add    $0x1,%edi
  8006d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d4:	83 f8 25             	cmp    $0x25,%eax
  8006d7:	0f 84 2f fc ff ff    	je     80030c <vprintfmt+0x17>
			if (ch == '\0')
  8006dd:	85 c0                	test   %eax,%eax
  8006df:	0f 84 8b 00 00 00    	je     800770 <vprintfmt+0x47b>
			putch(ch, putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	50                   	push   %eax
  8006ea:	ff d6                	call   *%esi
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb dc                	jmp    8006cd <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006f1:	83 f9 01             	cmp    $0x1,%ecx
  8006f4:	7e 15                	jle    80070b <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8b 10                	mov    (%eax),%edx
  8006fb:	8b 48 04             	mov    0x4(%eax),%ecx
  8006fe:	8d 40 08             	lea    0x8(%eax),%eax
  800701:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800704:	b8 10 00 00 00       	mov    $0x10,%eax
  800709:	eb a5                	jmp    8006b0 <vprintfmt+0x3bb>
	else if (lflag)
  80070b:	85 c9                	test   %ecx,%ecx
  80070d:	75 17                	jne    800726 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8b 10                	mov    (%eax),%edx
  800714:	b9 00 00 00 00       	mov    $0x0,%ecx
  800719:	8d 40 04             	lea    0x4(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071f:	b8 10 00 00 00       	mov    $0x10,%eax
  800724:	eb 8a                	jmp    8006b0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8b 10                	mov    (%eax),%edx
  80072b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800730:	8d 40 04             	lea    0x4(%eax),%eax
  800733:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800736:	b8 10 00 00 00       	mov    $0x10,%eax
  80073b:	e9 70 ff ff ff       	jmp    8006b0 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	53                   	push   %ebx
  800744:	6a 25                	push   $0x25
  800746:	ff d6                	call   *%esi
			break;
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	e9 7a ff ff ff       	jmp    8006ca <vprintfmt+0x3d5>
			putch('%', putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	53                   	push   %ebx
  800754:	6a 25                	push   $0x25
  800756:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	89 f8                	mov    %edi,%eax
  80075d:	eb 03                	jmp    800762 <vprintfmt+0x46d>
  80075f:	83 e8 01             	sub    $0x1,%eax
  800762:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800766:	75 f7                	jne    80075f <vprintfmt+0x46a>
  800768:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80076b:	e9 5a ff ff ff       	jmp    8006ca <vprintfmt+0x3d5>
}
  800770:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800773:	5b                   	pop    %ebx
  800774:	5e                   	pop    %esi
  800775:	5f                   	pop    %edi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 18             	sub    $0x18,%esp
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800784:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800787:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800795:	85 c0                	test   %eax,%eax
  800797:	74 26                	je     8007bf <vsnprintf+0x47>
  800799:	85 d2                	test   %edx,%edx
  80079b:	7e 22                	jle    8007bf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079d:	ff 75 14             	pushl  0x14(%ebp)
  8007a0:	ff 75 10             	pushl  0x10(%ebp)
  8007a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	68 bb 02 80 00       	push   $0x8002bb
  8007ac:	e8 44 fb ff ff       	call   8002f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ba:	83 c4 10             	add    $0x10,%esp
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    
		return -E_INVAL;
  8007bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c4:	eb f7                	jmp    8007bd <vsnprintf+0x45>

008007c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cf:	50                   	push   %eax
  8007d0:	ff 75 10             	pushl  0x10(%ebp)
  8007d3:	ff 75 0c             	pushl  0xc(%ebp)
  8007d6:	ff 75 08             	pushl  0x8(%ebp)
  8007d9:	e8 9a ff ff ff       	call   800778 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	eb 03                	jmp    8007f0 <strlen+0x10>
		n++;
  8007ed:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f4:	75 f7                	jne    8007ed <strlen+0xd>
	return n;
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
  800806:	eb 03                	jmp    80080b <strnlen+0x13>
		n++;
  800808:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080b:	39 d0                	cmp    %edx,%eax
  80080d:	74 06                	je     800815 <strnlen+0x1d>
  80080f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800813:	75 f3                	jne    800808 <strnlen+0x10>
	return n;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800821:	89 c2                	mov    %eax,%edx
  800823:	83 c1 01             	add    $0x1,%ecx
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80082d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800830:	84 db                	test   %bl,%bl
  800832:	75 ef                	jne    800823 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083e:	53                   	push   %ebx
  80083f:	e8 9c ff ff ff       	call   8007e0 <strlen>
  800844:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	01 d8                	add    %ebx,%eax
  80084c:	50                   	push   %eax
  80084d:	e8 c5 ff ff ff       	call   800817 <strcpy>
	return dst;
}
  800852:	89 d8                	mov    %ebx,%eax
  800854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	56                   	push   %esi
  80085d:	53                   	push   %ebx
  80085e:	8b 75 08             	mov    0x8(%ebp),%esi
  800861:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800864:	89 f3                	mov    %esi,%ebx
  800866:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800869:	89 f2                	mov    %esi,%edx
  80086b:	eb 0f                	jmp    80087c <strncpy+0x23>
		*dst++ = *src;
  80086d:	83 c2 01             	add    $0x1,%edx
  800870:	0f b6 01             	movzbl (%ecx),%eax
  800873:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800876:	80 39 01             	cmpb   $0x1,(%ecx)
  800879:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80087c:	39 da                	cmp    %ebx,%edx
  80087e:	75 ed                	jne    80086d <strncpy+0x14>
	}
	return ret;
}
  800880:	89 f0                	mov    %esi,%eax
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
  80088b:	8b 75 08             	mov    0x8(%ebp),%esi
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800891:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800894:	89 f0                	mov    %esi,%eax
  800896:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089a:	85 c9                	test   %ecx,%ecx
  80089c:	75 0b                	jne    8008a9 <strlcpy+0x23>
  80089e:	eb 17                	jmp    8008b7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	83 c0 01             	add    $0x1,%eax
  8008a6:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008a9:	39 d8                	cmp    %ebx,%eax
  8008ab:	74 07                	je     8008b4 <strlcpy+0x2e>
  8008ad:	0f b6 0a             	movzbl (%edx),%ecx
  8008b0:	84 c9                	test   %cl,%cl
  8008b2:	75 ec                	jne    8008a0 <strlcpy+0x1a>
		*dst = '\0';
  8008b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b7:	29 f0                	sub    %esi,%eax
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c6:	eb 06                	jmp    8008ce <strcmp+0x11>
		p++, q++;
  8008c8:	83 c1 01             	add    $0x1,%ecx
  8008cb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ce:	0f b6 01             	movzbl (%ecx),%eax
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 04                	je     8008d9 <strcmp+0x1c>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	74 ef                	je     8008c8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d9:	0f b6 c0             	movzbl %al,%eax
  8008dc:	0f b6 12             	movzbl (%edx),%edx
  8008df:	29 d0                	sub    %edx,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 c3                	mov    %eax,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f2:	eb 06                	jmp    8008fa <strncmp+0x17>
		n--, p++, q++;
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008fa:	39 d8                	cmp    %ebx,%eax
  8008fc:	74 16                	je     800914 <strncmp+0x31>
  8008fe:	0f b6 08             	movzbl (%eax),%ecx
  800901:	84 c9                	test   %cl,%cl
  800903:	74 04                	je     800909 <strncmp+0x26>
  800905:	3a 0a                	cmp    (%edx),%cl
  800907:	74 eb                	je     8008f4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800909:	0f b6 00             	movzbl (%eax),%eax
  80090c:	0f b6 12             	movzbl (%edx),%edx
  80090f:	29 d0                	sub    %edx,%eax
}
  800911:	5b                   	pop    %ebx
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    
		return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
  800919:	eb f6                	jmp    800911 <strncmp+0x2e>

0080091b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	0f b6 10             	movzbl (%eax),%edx
  800928:	84 d2                	test   %dl,%dl
  80092a:	74 09                	je     800935 <strchr+0x1a>
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	74 0a                	je     80093a <strchr+0x1f>
	for (; *s; s++)
  800930:	83 c0 01             	add    $0x1,%eax
  800933:	eb f0                	jmp    800925 <strchr+0xa>
			return (char *) s;
	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800946:	eb 03                	jmp    80094b <strfind+0xf>
  800948:	83 c0 01             	add    $0x1,%eax
  80094b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094e:	38 ca                	cmp    %cl,%dl
  800950:	74 04                	je     800956 <strfind+0x1a>
  800952:	84 d2                	test   %dl,%dl
  800954:	75 f2                	jne    800948 <strfind+0xc>
			break;
	return (char *) s;
}
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	57                   	push   %edi
  80095c:	56                   	push   %esi
  80095d:	53                   	push   %ebx
  80095e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800961:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800964:	85 c9                	test   %ecx,%ecx
  800966:	74 13                	je     80097b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800968:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096e:	75 05                	jne    800975 <memset+0x1d>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	74 0d                	je     800982 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
  800978:	fc                   	cld    
  800979:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097b:	89 f8                	mov    %edi,%eax
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    
		c &= 0xFF;
  800982:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800986:	89 d3                	mov    %edx,%ebx
  800988:	c1 e3 08             	shl    $0x8,%ebx
  80098b:	89 d0                	mov    %edx,%eax
  80098d:	c1 e0 18             	shl    $0x18,%eax
  800990:	89 d6                	mov    %edx,%esi
  800992:	c1 e6 10             	shl    $0x10,%esi
  800995:	09 f0                	or     %esi,%eax
  800997:	09 c2                	or     %eax,%edx
  800999:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80099b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80099e:	89 d0                	mov    %edx,%eax
  8009a0:	fc                   	cld    
  8009a1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a3:	eb d6                	jmp    80097b <memset+0x23>

008009a5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b3:	39 c6                	cmp    %eax,%esi
  8009b5:	73 35                	jae    8009ec <memmove+0x47>
  8009b7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ba:	39 c2                	cmp    %eax,%edx
  8009bc:	76 2e                	jbe    8009ec <memmove+0x47>
		s += n;
		d += n;
  8009be:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c1:	89 d6                	mov    %edx,%esi
  8009c3:	09 fe                	or     %edi,%esi
  8009c5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cb:	74 0c                	je     8009d9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cd:	83 ef 01             	sub    $0x1,%edi
  8009d0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009d3:	fd                   	std    
  8009d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d6:	fc                   	cld    
  8009d7:	eb 21                	jmp    8009fa <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d9:	f6 c1 03             	test   $0x3,%cl
  8009dc:	75 ef                	jne    8009cd <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009de:	83 ef 04             	sub    $0x4,%edi
  8009e1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009e7:	fd                   	std    
  8009e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ea:	eb ea                	jmp    8009d6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ec:	89 f2                	mov    %esi,%edx
  8009ee:	09 c2                	or     %eax,%edx
  8009f0:	f6 c2 03             	test   $0x3,%dl
  8009f3:	74 09                	je     8009fe <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f5:	89 c7                	mov    %eax,%edi
  8009f7:	fc                   	cld    
  8009f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fa:	5e                   	pop    %esi
  8009fb:	5f                   	pop    %edi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fe:	f6 c1 03             	test   $0x3,%cl
  800a01:	75 f2                	jne    8009f5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a03:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a06:	89 c7                	mov    %eax,%edi
  800a08:	fc                   	cld    
  800a09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0b:	eb ed                	jmp    8009fa <memmove+0x55>

00800a0d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a10:	ff 75 10             	pushl  0x10(%ebp)
  800a13:	ff 75 0c             	pushl  0xc(%ebp)
  800a16:	ff 75 08             	pushl  0x8(%ebp)
  800a19:	e8 87 ff ff ff       	call   8009a5 <memmove>
}
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2b:	89 c6                	mov    %eax,%esi
  800a2d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a30:	39 f0                	cmp    %esi,%eax
  800a32:	74 1c                	je     800a50 <memcmp+0x30>
		if (*s1 != *s2)
  800a34:	0f b6 08             	movzbl (%eax),%ecx
  800a37:	0f b6 1a             	movzbl (%edx),%ebx
  800a3a:	38 d9                	cmp    %bl,%cl
  800a3c:	75 08                	jne    800a46 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a3e:	83 c0 01             	add    $0x1,%eax
  800a41:	83 c2 01             	add    $0x1,%edx
  800a44:	eb ea                	jmp    800a30 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a46:	0f b6 c1             	movzbl %cl,%eax
  800a49:	0f b6 db             	movzbl %bl,%ebx
  800a4c:	29 d8                	sub    %ebx,%eax
  800a4e:	eb 05                	jmp    800a55 <memcmp+0x35>
	}

	return 0;
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a62:	89 c2                	mov    %eax,%edx
  800a64:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a67:	39 d0                	cmp    %edx,%eax
  800a69:	73 09                	jae    800a74 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6b:	38 08                	cmp    %cl,(%eax)
  800a6d:	74 05                	je     800a74 <memfind+0x1b>
	for (; s < ends; s++)
  800a6f:	83 c0 01             	add    $0x1,%eax
  800a72:	eb f3                	jmp    800a67 <memfind+0xe>
			break;
	return (void *) s;
}
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
  800a7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a82:	eb 03                	jmp    800a87 <strtol+0x11>
		s++;
  800a84:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a87:	0f b6 01             	movzbl (%ecx),%eax
  800a8a:	3c 20                	cmp    $0x20,%al
  800a8c:	74 f6                	je     800a84 <strtol+0xe>
  800a8e:	3c 09                	cmp    $0x9,%al
  800a90:	74 f2                	je     800a84 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a92:	3c 2b                	cmp    $0x2b,%al
  800a94:	74 2e                	je     800ac4 <strtol+0x4e>
	int neg = 0;
  800a96:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a9b:	3c 2d                	cmp    $0x2d,%al
  800a9d:	74 2f                	je     800ace <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa5:	75 05                	jne    800aac <strtol+0x36>
  800aa7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aaa:	74 2c                	je     800ad8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aac:	85 db                	test   %ebx,%ebx
  800aae:	75 0a                	jne    800aba <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ab5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab8:	74 28                	je     800ae2 <strtol+0x6c>
		base = 10;
  800aba:	b8 00 00 00 00       	mov    $0x0,%eax
  800abf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ac2:	eb 50                	jmp    800b14 <strtol+0x9e>
		s++;
  800ac4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ac7:	bf 00 00 00 00       	mov    $0x0,%edi
  800acc:	eb d1                	jmp    800a9f <strtol+0x29>
		s++, neg = 1;
  800ace:	83 c1 01             	add    $0x1,%ecx
  800ad1:	bf 01 00 00 00       	mov    $0x1,%edi
  800ad6:	eb c7                	jmp    800a9f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800adc:	74 0e                	je     800aec <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ade:	85 db                	test   %ebx,%ebx
  800ae0:	75 d8                	jne    800aba <strtol+0x44>
		s++, base = 8;
  800ae2:	83 c1 01             	add    $0x1,%ecx
  800ae5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aea:	eb ce                	jmp    800aba <strtol+0x44>
		s += 2, base = 16;
  800aec:	83 c1 02             	add    $0x2,%ecx
  800aef:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af4:	eb c4                	jmp    800aba <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800af6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af9:	89 f3                	mov    %esi,%ebx
  800afb:	80 fb 19             	cmp    $0x19,%bl
  800afe:	77 29                	ja     800b29 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b00:	0f be d2             	movsbl %dl,%edx
  800b03:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b06:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b09:	7d 30                	jge    800b3b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b0b:	83 c1 01             	add    $0x1,%ecx
  800b0e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b12:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b14:	0f b6 11             	movzbl (%ecx),%edx
  800b17:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1a:	89 f3                	mov    %esi,%ebx
  800b1c:	80 fb 09             	cmp    $0x9,%bl
  800b1f:	77 d5                	ja     800af6 <strtol+0x80>
			dig = *s - '0';
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 30             	sub    $0x30,%edx
  800b27:	eb dd                	jmp    800b06 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b29:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b2c:	89 f3                	mov    %esi,%ebx
  800b2e:	80 fb 19             	cmp    $0x19,%bl
  800b31:	77 08                	ja     800b3b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b33:	0f be d2             	movsbl %dl,%edx
  800b36:	83 ea 37             	sub    $0x37,%edx
  800b39:	eb cb                	jmp    800b06 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b3b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3f:	74 05                	je     800b46 <strtol+0xd0>
		*endptr = (char *) s;
  800b41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b44:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b46:	89 c2                	mov    %eax,%edx
  800b48:	f7 da                	neg    %edx
  800b4a:	85 ff                	test   %edi,%edi
  800b4c:	0f 45 c2             	cmovne %edx,%eax
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b65:	89 c3                	mov    %eax,%ebx
  800b67:	89 c7                	mov    %eax,%edi
  800b69:	89 c6                	mov    %eax,%esi
  800b6b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b82:	89 d1                	mov    %edx,%ecx
  800b84:	89 d3                	mov    %edx,%ebx
  800b86:	89 d7                	mov    %edx,%edi
  800b88:	89 d6                	mov    %edx,%esi
  800b8a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba7:	89 cb                	mov    %ecx,%ebx
  800ba9:	89 cf                	mov    %ecx,%edi
  800bab:	89 ce                	mov    %ecx,%esi
  800bad:	cd 30                	int    $0x30
	if(check && ret > 0)
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	7f 08                	jg     800bbb <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	50                   	push   %eax
  800bbf:	6a 03                	push   $0x3
  800bc1:	68 5f 25 80 00       	push   $0x80255f
  800bc6:	6a 23                	push   $0x23
  800bc8:	68 7c 25 80 00       	push   $0x80257c
  800bcd:	e8 c3 12 00 00       	call   801e95 <_panic>

00800bd2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdd:	b8 02 00 00 00       	mov    $0x2,%eax
  800be2:	89 d1                	mov    %edx,%ecx
  800be4:	89 d3                	mov    %edx,%ebx
  800be6:	89 d7                	mov    %edx,%edi
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_yield>:

void
sys_yield(void)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c01:	89 d1                	mov    %edx,%ecx
  800c03:	89 d3                	mov    %edx,%ebx
  800c05:	89 d7                	mov    %edx,%edi
  800c07:	89 d6                	mov    %edx,%esi
  800c09:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c19:	be 00 00 00 00       	mov    $0x0,%esi
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c24:	b8 04 00 00 00       	mov    $0x4,%eax
  800c29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2c:	89 f7                	mov    %esi,%edi
  800c2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c30:	85 c0                	test   %eax,%eax
  800c32:	7f 08                	jg     800c3c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800c40:	6a 04                	push   $0x4
  800c42:	68 5f 25 80 00       	push   $0x80255f
  800c47:	6a 23                	push   $0x23
  800c49:	68 7c 25 80 00       	push   $0x80257c
  800c4e:	e8 42 12 00 00       	call   801e95 <_panic>

00800c53 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	b8 05 00 00 00       	mov    $0x5,%eax
  800c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c72:	85 c0                	test   %eax,%eax
  800c74:	7f 08                	jg     800c7e <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800c82:	6a 05                	push   $0x5
  800c84:	68 5f 25 80 00       	push   $0x80255f
  800c89:	6a 23                	push   $0x23
  800c8b:	68 7c 25 80 00       	push   $0x80257c
  800c90:	e8 00 12 00 00       	call   801e95 <_panic>

00800c95 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800ca9:	b8 06 00 00 00       	mov    $0x6,%eax
  800cae:	89 df                	mov    %ebx,%edi
  800cb0:	89 de                	mov    %ebx,%esi
  800cb2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7f 08                	jg     800cc0 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800cc4:	6a 06                	push   $0x6
  800cc6:	68 5f 25 80 00       	push   $0x80255f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 7c 25 80 00       	push   $0x80257c
  800cd2:	e8 be 11 00 00       	call   801e95 <_panic>

00800cd7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ceb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf0:	89 df                	mov    %ebx,%edi
  800cf2:	89 de                	mov    %ebx,%esi
  800cf4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7f 08                	jg     800d02 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  800d06:	6a 08                	push   $0x8
  800d08:	68 5f 25 80 00       	push   $0x80255f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 7c 25 80 00       	push   $0x80257c
  800d14:	e8 7c 11 00 00       	call   801e95 <_panic>

00800d19 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d2d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d32:	89 df                	mov    %ebx,%edi
  800d34:	89 de                	mov    %ebx,%esi
  800d36:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7f 08                	jg     800d44 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800d48:	6a 09                	push   $0x9
  800d4a:	68 5f 25 80 00       	push   $0x80255f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 7c 25 80 00       	push   $0x80257c
  800d56:	e8 3a 11 00 00       	call   801e95 <_panic>

00800d5b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	89 de                	mov    %ebx,%esi
  800d78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7f 08                	jg     800d86 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 0a                	push   $0xa
  800d8c:	68 5f 25 80 00       	push   $0x80255f
  800d91:	6a 23                	push   $0x23
  800d93:	68 7c 25 80 00       	push   $0x80257c
  800d98:	e8 f8 10 00 00       	call   801e95 <_panic>

00800d9d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dae:	be 00 00 00 00       	mov    $0x0,%esi
  800db3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd6:	89 cb                	mov    %ecx,%ebx
  800dd8:	89 cf                	mov    %ecx,%edi
  800dda:	89 ce                	mov    %ecx,%esi
  800ddc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7f 08                	jg     800dea <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	50                   	push   %eax
  800dee:	6a 0d                	push   $0xd
  800df0:	68 5f 25 80 00       	push   $0x80255f
  800df5:	6a 23                	push   $0x23
  800df7:	68 7c 25 80 00       	push   $0x80257c
  800dfc:	e8 94 10 00 00       	call   801e95 <_panic>

00800e01 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	53                   	push   %ebx
  800e05:	83 ec 04             	sub    $0x4,%esp
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e0b:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e0d:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e11:	0f 84 9c 00 00 00    	je     800eb3 <pgfault+0xb2>
  800e17:	89 c2                	mov    %eax,%edx
  800e19:	c1 ea 16             	shr    $0x16,%edx
  800e1c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e23:	f6 c2 01             	test   $0x1,%dl
  800e26:	0f 84 87 00 00 00    	je     800eb3 <pgfault+0xb2>
  800e2c:	89 c2                	mov    %eax,%edx
  800e2e:	c1 ea 0c             	shr    $0xc,%edx
  800e31:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e38:	f6 c1 01             	test   $0x1,%cl
  800e3b:	74 76                	je     800eb3 <pgfault+0xb2>
  800e3d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e44:	f6 c6 08             	test   $0x8,%dh
  800e47:	74 6a                	je     800eb3 <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  800e49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e4e:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800e50:	83 ec 04             	sub    $0x4,%esp
  800e53:	6a 07                	push   $0x7
  800e55:	68 00 f0 7f 00       	push   $0x7ff000
  800e5a:	6a 00                	push   $0x0
  800e5c:	e8 af fd ff ff       	call   800c10 <sys_page_alloc>
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	85 c0                	test   %eax,%eax
  800e66:	78 5f                	js     800ec7 <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  800e68:	83 ec 04             	sub    $0x4,%esp
  800e6b:	68 00 10 00 00       	push   $0x1000
  800e70:	53                   	push   %ebx
  800e71:	68 00 f0 7f 00       	push   $0x7ff000
  800e76:	e8 92 fb ff ff       	call   800a0d <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e7b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e82:	53                   	push   %ebx
  800e83:	6a 00                	push   $0x0
  800e85:	68 00 f0 7f 00       	push   $0x7ff000
  800e8a:	6a 00                	push   $0x0
  800e8c:	e8 c2 fd ff ff       	call   800c53 <sys_page_map>
  800e91:	83 c4 20             	add    $0x20,%esp
  800e94:	85 c0                	test   %eax,%eax
  800e96:	78 43                	js     800edb <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	68 00 f0 7f 00       	push   $0x7ff000
  800ea0:	6a 00                	push   $0x0
  800ea2:	e8 ee fd ff ff       	call   800c95 <sys_page_unmap>
  800ea7:	83 c4 10             	add    $0x10,%esp
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	78 41                	js     800eef <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  800eae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    
		panic("not copy-on-write");
  800eb3:	83 ec 04             	sub    $0x4,%esp
  800eb6:	68 8a 25 80 00       	push   $0x80258a
  800ebb:	6a 25                	push   $0x25
  800ebd:	68 9c 25 80 00       	push   $0x80259c
  800ec2:	e8 ce 0f 00 00       	call   801e95 <_panic>
		panic("sys_page_alloc");
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	68 a7 25 80 00       	push   $0x8025a7
  800ecf:	6a 28                	push   $0x28
  800ed1:	68 9c 25 80 00       	push   $0x80259c
  800ed6:	e8 ba 0f 00 00       	call   801e95 <_panic>
		panic("sys_page_map");
  800edb:	83 ec 04             	sub    $0x4,%esp
  800ede:	68 b6 25 80 00       	push   $0x8025b6
  800ee3:	6a 2b                	push   $0x2b
  800ee5:	68 9c 25 80 00       	push   $0x80259c
  800eea:	e8 a6 0f 00 00       	call   801e95 <_panic>
		panic("sys_page_unmap");
  800eef:	83 ec 04             	sub    $0x4,%esp
  800ef2:	68 c3 25 80 00       	push   $0x8025c3
  800ef7:	6a 2d                	push   $0x2d
  800ef9:	68 9c 25 80 00       	push   $0x80259c
  800efe:	e8 92 0f 00 00       	call   801e95 <_panic>

00800f03 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f0c:	68 01 0e 80 00       	push   $0x800e01
  800f11:	e8 c5 0f 00 00       	call   801edb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f16:	b8 07 00 00 00       	mov    $0x7,%eax
  800f1b:	cd 30                	int    $0x30
  800f1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	74 12                	je     800f39 <fork+0x36>
  800f27:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  800f29:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f2d:	78 26                	js     800f55 <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f34:	e9 94 00 00 00       	jmp    800fcd <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f39:	e8 94 fc ff ff       	call   800bd2 <sys_getenvid>
  800f3e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f43:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f46:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f4b:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f50:	e9 51 01 00 00       	jmp    8010a6 <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  800f55:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f58:	68 d2 25 80 00       	push   $0x8025d2
  800f5d:	6a 6e                	push   $0x6e
  800f5f:	68 9c 25 80 00       	push   $0x80259c
  800f64:	e8 2c 0f 00 00       	call   801e95 <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	68 07 0e 00 00       	push   $0xe07
  800f71:	56                   	push   %esi
  800f72:	57                   	push   %edi
  800f73:	56                   	push   %esi
  800f74:	6a 00                	push   $0x0
  800f76:	e8 d8 fc ff ff       	call   800c53 <sys_page_map>
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	eb 3b                	jmp    800fbb <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	68 05 08 00 00       	push   $0x805
  800f88:	56                   	push   %esi
  800f89:	57                   	push   %edi
  800f8a:	56                   	push   %esi
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 c1 fc ff ff       	call   800c53 <sys_page_map>
  800f92:	83 c4 20             	add    $0x20,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	0f 88 a9 00 00 00    	js     801046 <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f9d:	83 ec 0c             	sub    $0xc,%esp
  800fa0:	68 05 08 00 00       	push   $0x805
  800fa5:	56                   	push   %esi
  800fa6:	6a 00                	push   $0x0
  800fa8:	56                   	push   %esi
  800fa9:	6a 00                	push   $0x0
  800fab:	e8 a3 fc ff ff       	call   800c53 <sys_page_map>
  800fb0:	83 c4 20             	add    $0x20,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	0f 88 9d 00 00 00    	js     801058 <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800fbb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fc1:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fc7:	0f 84 9d 00 00 00    	je     80106a <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800fcd:	89 d8                	mov    %ebx,%eax
  800fcf:	c1 e8 16             	shr    $0x16,%eax
  800fd2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd9:	a8 01                	test   $0x1,%al
  800fdb:	74 de                	je     800fbb <fork+0xb8>
  800fdd:	89 d8                	mov    %ebx,%eax
  800fdf:	c1 e8 0c             	shr    $0xc,%eax
  800fe2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe9:	f6 c2 01             	test   $0x1,%dl
  800fec:	74 cd                	je     800fbb <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800fee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff5:	f6 c2 04             	test   $0x4,%dl
  800ff8:	74 c1                	je     800fbb <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  800ffa:	89 c6                	mov    %eax,%esi
  800ffc:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  800fff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801006:	f6 c6 04             	test   $0x4,%dh
  801009:	0f 85 5a ff ff ff    	jne    800f69 <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  80100f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801016:	f6 c2 02             	test   $0x2,%dl
  801019:	0f 85 61 ff ff ff    	jne    800f80 <fork+0x7d>
  80101f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801026:	f6 c4 08             	test   $0x8,%ah
  801029:	0f 85 51 ff ff ff    	jne    800f80 <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	6a 05                	push   $0x5
  801034:	56                   	push   %esi
  801035:	57                   	push   %edi
  801036:	56                   	push   %esi
  801037:	6a 00                	push   $0x0
  801039:	e8 15 fc ff ff       	call   800c53 <sys_page_map>
  80103e:	83 c4 20             	add    $0x20,%esp
  801041:	e9 75 ff ff ff       	jmp    800fbb <fork+0xb8>
            		panic("sys_page_map：%e", r);
  801046:	50                   	push   %eax
  801047:	68 e2 25 80 00       	push   $0x8025e2
  80104c:	6a 47                	push   $0x47
  80104e:	68 9c 25 80 00       	push   $0x80259c
  801053:	e8 3d 0e 00 00       	call   801e95 <_panic>
            		panic("sys_page_map：%e", r);
  801058:	50                   	push   %eax
  801059:	68 e2 25 80 00       	push   $0x8025e2
  80105e:	6a 49                	push   $0x49
  801060:	68 9c 25 80 00       	push   $0x80259c
  801065:	e8 2b 0e 00 00       	call   801e95 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80106a:	83 ec 04             	sub    $0x4,%esp
  80106d:	6a 07                	push   $0x7
  80106f:	68 00 f0 bf ee       	push   $0xeebff000
  801074:	ff 75 e4             	pushl  -0x1c(%ebp)
  801077:	e8 94 fb ff ff       	call   800c10 <sys_page_alloc>
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	85 c0                	test   %eax,%eax
  801081:	78 2e                	js     8010b1 <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801083:	83 ec 08             	sub    $0x8,%esp
  801086:	68 4a 1f 80 00       	push   $0x801f4a
  80108b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80108e:	57                   	push   %edi
  80108f:	e8 c7 fc ff ff       	call   800d5b <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801094:	83 c4 08             	add    $0x8,%esp
  801097:	6a 02                	push   $0x2
  801099:	57                   	push   %edi
  80109a:	e8 38 fc ff ff       	call   800cd7 <sys_env_set_status>
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	78 1f                	js     8010c5 <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  8010a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ac:	5b                   	pop    %ebx
  8010ad:	5e                   	pop    %esi
  8010ae:	5f                   	pop    %edi
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    
		panic("1");
  8010b1:	83 ec 04             	sub    $0x4,%esp
  8010b4:	68 f4 25 80 00       	push   $0x8025f4
  8010b9:	6a 77                	push   $0x77
  8010bb:	68 9c 25 80 00       	push   $0x80259c
  8010c0:	e8 d0 0d 00 00       	call   801e95 <_panic>
		panic("sys_env_set_status");
  8010c5:	83 ec 04             	sub    $0x4,%esp
  8010c8:	68 f6 25 80 00       	push   $0x8025f6
  8010cd:	6a 7c                	push   $0x7c
  8010cf:	68 9c 25 80 00       	push   $0x80259c
  8010d4:	e8 bc 0d 00 00       	call   801e95 <_panic>

008010d9 <sfork>:

// Challenge!
int
sfork(void)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010df:	68 09 26 80 00       	push   $0x802609
  8010e4:	68 86 00 00 00       	push   $0x86
  8010e9:	68 9c 25 80 00       	push   $0x80259c
  8010ee:	e8 a2 0d 00 00       	call   801e95 <_panic>

008010f3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8010fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801101:	85 f6                	test   %esi,%esi
  801103:	74 06                	je     80110b <ipc_recv+0x18>
  801105:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  80110b:	85 db                	test   %ebx,%ebx
  80110d:	74 06                	je     801115 <ipc_recv+0x22>
  80110f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801115:	85 c0                	test   %eax,%eax
  801117:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80111c:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	50                   	push   %eax
  801123:	e8 98 fc ff ff       	call   800dc0 <sys_ipc_recv>
	if (ret) return ret;
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	85 c0                	test   %eax,%eax
  80112d:	75 24                	jne    801153 <ipc_recv+0x60>
	if (from_env_store)
  80112f:	85 f6                	test   %esi,%esi
  801131:	74 0a                	je     80113d <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801133:	a1 08 40 80 00       	mov    0x804008,%eax
  801138:	8b 40 74             	mov    0x74(%eax),%eax
  80113b:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  80113d:	85 db                	test   %ebx,%ebx
  80113f:	74 0a                	je     80114b <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801141:	a1 08 40 80 00       	mov    0x804008,%eax
  801146:	8b 40 78             	mov    0x78(%eax),%eax
  801149:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80114b:	a1 08 40 80 00       	mov    0x804008,%eax
  801150:	8b 40 70             	mov    0x70(%eax),%eax
}
  801153:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801156:	5b                   	pop    %ebx
  801157:	5e                   	pop    %esi
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	57                   	push   %edi
  80115e:	56                   	push   %esi
  80115f:	53                   	push   %ebx
  801160:	83 ec 0c             	sub    $0xc,%esp
  801163:	8b 7d 08             	mov    0x8(%ebp),%edi
  801166:	8b 75 0c             	mov    0xc(%ebp),%esi
  801169:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  80116c:	85 db                	test   %ebx,%ebx
  80116e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801173:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801176:	ff 75 14             	pushl  0x14(%ebp)
  801179:	53                   	push   %ebx
  80117a:	56                   	push   %esi
  80117b:	57                   	push   %edi
  80117c:	e8 1c fc ff ff       	call   800d9d <sys_ipc_try_send>
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	74 1e                	je     8011a6 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801188:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80118b:	75 07                	jne    801194 <ipc_send+0x3a>
		sys_yield();
  80118d:	e8 5f fa ff ff       	call   800bf1 <sys_yield>
  801192:	eb e2                	jmp    801176 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801194:	50                   	push   %eax
  801195:	68 1f 26 80 00       	push   $0x80261f
  80119a:	6a 36                	push   $0x36
  80119c:	68 36 26 80 00       	push   $0x802636
  8011a1:	e8 ef 0c 00 00       	call   801e95 <_panic>
	}
}
  8011a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a9:	5b                   	pop    %ebx
  8011aa:	5e                   	pop    %esi
  8011ab:	5f                   	pop    %edi
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011b4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011b9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011bc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011c2:	8b 52 50             	mov    0x50(%edx),%edx
  8011c5:	39 ca                	cmp    %ecx,%edx
  8011c7:	74 11                	je     8011da <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8011c9:	83 c0 01             	add    $0x1,%eax
  8011cc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011d1:	75 e6                	jne    8011b9 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8011d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d8:	eb 0b                	jmp    8011e5 <ipc_find_env+0x37>
			return envs[i].env_id;
  8011da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011e2:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ed:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f2:	c1 e8 0c             	shr    $0xc,%eax
}
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fd:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801202:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801207:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801214:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801219:	89 c2                	mov    %eax,%edx
  80121b:	c1 ea 16             	shr    $0x16,%edx
  80121e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801225:	f6 c2 01             	test   $0x1,%dl
  801228:	74 2a                	je     801254 <fd_alloc+0x46>
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	c1 ea 0c             	shr    $0xc,%edx
  80122f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801236:	f6 c2 01             	test   $0x1,%dl
  801239:	74 19                	je     801254 <fd_alloc+0x46>
  80123b:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801240:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801245:	75 d2                	jne    801219 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801247:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80124d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801252:	eb 07                	jmp    80125b <fd_alloc+0x4d>
			*fd_store = fd;
  801254:	89 01                	mov    %eax,(%ecx)
			return 0;
  801256:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801263:	83 f8 1f             	cmp    $0x1f,%eax
  801266:	77 36                	ja     80129e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801268:	c1 e0 0c             	shl    $0xc,%eax
  80126b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801270:	89 c2                	mov    %eax,%edx
  801272:	c1 ea 16             	shr    $0x16,%edx
  801275:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127c:	f6 c2 01             	test   $0x1,%dl
  80127f:	74 24                	je     8012a5 <fd_lookup+0x48>
  801281:	89 c2                	mov    %eax,%edx
  801283:	c1 ea 0c             	shr    $0xc,%edx
  801286:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128d:	f6 c2 01             	test   $0x1,%dl
  801290:	74 1a                	je     8012ac <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801292:	8b 55 0c             	mov    0xc(%ebp),%edx
  801295:	89 02                	mov    %eax,(%edx)
	return 0;
  801297:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    
		return -E_INVAL;
  80129e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a3:	eb f7                	jmp    80129c <fd_lookup+0x3f>
		return -E_INVAL;
  8012a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012aa:	eb f0                	jmp    80129c <fd_lookup+0x3f>
  8012ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b1:	eb e9                	jmp    80129c <fd_lookup+0x3f>

008012b3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	83 ec 08             	sub    $0x8,%esp
  8012b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012bc:	ba bc 26 80 00       	mov    $0x8026bc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012c1:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012c6:	39 08                	cmp    %ecx,(%eax)
  8012c8:	74 33                	je     8012fd <dev_lookup+0x4a>
  8012ca:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012cd:	8b 02                	mov    (%edx),%eax
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	75 f3                	jne    8012c6 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d3:	a1 08 40 80 00       	mov    0x804008,%eax
  8012d8:	8b 40 48             	mov    0x48(%eax),%eax
  8012db:	83 ec 04             	sub    $0x4,%esp
  8012de:	51                   	push   %ecx
  8012df:	50                   	push   %eax
  8012e0:	68 40 26 80 00       	push   $0x802640
  8012e5:	e8 0e ef ff ff       	call   8001f8 <cprintf>
	*dev = 0;
  8012ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012fb:	c9                   	leave  
  8012fc:	c3                   	ret    
			*dev = devtab[i];
  8012fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801300:	89 01                	mov    %eax,(%ecx)
			return 0;
  801302:	b8 00 00 00 00       	mov    $0x0,%eax
  801307:	eb f2                	jmp    8012fb <dev_lookup+0x48>

00801309 <fd_close>:
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	57                   	push   %edi
  80130d:	56                   	push   %esi
  80130e:	53                   	push   %ebx
  80130f:	83 ec 1c             	sub    $0x1c,%esp
  801312:	8b 75 08             	mov    0x8(%ebp),%esi
  801315:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801318:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80131b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80131c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801322:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801325:	50                   	push   %eax
  801326:	e8 32 ff ff ff       	call   80125d <fd_lookup>
  80132b:	89 c3                	mov    %eax,%ebx
  80132d:	83 c4 08             	add    $0x8,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 05                	js     801339 <fd_close+0x30>
	    || fd != fd2)
  801334:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801337:	74 16                	je     80134f <fd_close+0x46>
		return (must_exist ? r : 0);
  801339:	89 f8                	mov    %edi,%eax
  80133b:	84 c0                	test   %al,%al
  80133d:	b8 00 00 00 00       	mov    $0x0,%eax
  801342:	0f 44 d8             	cmove  %eax,%ebx
}
  801345:	89 d8                	mov    %ebx,%eax
  801347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80134a:	5b                   	pop    %ebx
  80134b:	5e                   	pop    %esi
  80134c:	5f                   	pop    %edi
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801355:	50                   	push   %eax
  801356:	ff 36                	pushl  (%esi)
  801358:	e8 56 ff ff ff       	call   8012b3 <dev_lookup>
  80135d:	89 c3                	mov    %eax,%ebx
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	85 c0                	test   %eax,%eax
  801364:	78 15                	js     80137b <fd_close+0x72>
		if (dev->dev_close)
  801366:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801369:	8b 40 10             	mov    0x10(%eax),%eax
  80136c:	85 c0                	test   %eax,%eax
  80136e:	74 1b                	je     80138b <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801370:	83 ec 0c             	sub    $0xc,%esp
  801373:	56                   	push   %esi
  801374:	ff d0                	call   *%eax
  801376:	89 c3                	mov    %eax,%ebx
  801378:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80137b:	83 ec 08             	sub    $0x8,%esp
  80137e:	56                   	push   %esi
  80137f:	6a 00                	push   $0x0
  801381:	e8 0f f9 ff ff       	call   800c95 <sys_page_unmap>
	return r;
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	eb ba                	jmp    801345 <fd_close+0x3c>
			r = 0;
  80138b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801390:	eb e9                	jmp    80137b <fd_close+0x72>

00801392 <close>:

int
close(int fdnum)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801398:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139b:	50                   	push   %eax
  80139c:	ff 75 08             	pushl  0x8(%ebp)
  80139f:	e8 b9 fe ff ff       	call   80125d <fd_lookup>
  8013a4:	83 c4 08             	add    $0x8,%esp
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 10                	js     8013bb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	6a 01                	push   $0x1
  8013b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b3:	e8 51 ff ff ff       	call   801309 <fd_close>
  8013b8:	83 c4 10             	add    $0x10,%esp
}
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    

008013bd <close_all>:

void
close_all(void)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013c9:	83 ec 0c             	sub    $0xc,%esp
  8013cc:	53                   	push   %ebx
  8013cd:	e8 c0 ff ff ff       	call   801392 <close>
	for (i = 0; i < MAXFD; i++)
  8013d2:	83 c3 01             	add    $0x1,%ebx
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	83 fb 20             	cmp    $0x20,%ebx
  8013db:	75 ec                	jne    8013c9 <close_all+0xc>
}
  8013dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e0:	c9                   	leave  
  8013e1:	c3                   	ret    

008013e2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	57                   	push   %edi
  8013e6:	56                   	push   %esi
  8013e7:	53                   	push   %ebx
  8013e8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ee:	50                   	push   %eax
  8013ef:	ff 75 08             	pushl  0x8(%ebp)
  8013f2:	e8 66 fe ff ff       	call   80125d <fd_lookup>
  8013f7:	89 c3                	mov    %eax,%ebx
  8013f9:	83 c4 08             	add    $0x8,%esp
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	0f 88 81 00 00 00    	js     801485 <dup+0xa3>
		return r;
	close(newfdnum);
  801404:	83 ec 0c             	sub    $0xc,%esp
  801407:	ff 75 0c             	pushl  0xc(%ebp)
  80140a:	e8 83 ff ff ff       	call   801392 <close>

	newfd = INDEX2FD(newfdnum);
  80140f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801412:	c1 e6 0c             	shl    $0xc,%esi
  801415:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80141b:	83 c4 04             	add    $0x4,%esp
  80141e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801421:	e8 d1 fd ff ff       	call   8011f7 <fd2data>
  801426:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801428:	89 34 24             	mov    %esi,(%esp)
  80142b:	e8 c7 fd ff ff       	call   8011f7 <fd2data>
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801435:	89 d8                	mov    %ebx,%eax
  801437:	c1 e8 16             	shr    $0x16,%eax
  80143a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801441:	a8 01                	test   $0x1,%al
  801443:	74 11                	je     801456 <dup+0x74>
  801445:	89 d8                	mov    %ebx,%eax
  801447:	c1 e8 0c             	shr    $0xc,%eax
  80144a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801451:	f6 c2 01             	test   $0x1,%dl
  801454:	75 39                	jne    80148f <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801456:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801459:	89 d0                	mov    %edx,%eax
  80145b:	c1 e8 0c             	shr    $0xc,%eax
  80145e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	25 07 0e 00 00       	and    $0xe07,%eax
  80146d:	50                   	push   %eax
  80146e:	56                   	push   %esi
  80146f:	6a 00                	push   $0x0
  801471:	52                   	push   %edx
  801472:	6a 00                	push   $0x0
  801474:	e8 da f7 ff ff       	call   800c53 <sys_page_map>
  801479:	89 c3                	mov    %eax,%ebx
  80147b:	83 c4 20             	add    $0x20,%esp
  80147e:	85 c0                	test   %eax,%eax
  801480:	78 31                	js     8014b3 <dup+0xd1>
		goto err;

	return newfdnum;
  801482:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801485:	89 d8                	mov    %ebx,%eax
  801487:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148a:	5b                   	pop    %ebx
  80148b:	5e                   	pop    %esi
  80148c:	5f                   	pop    %edi
  80148d:	5d                   	pop    %ebp
  80148e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80148f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	25 07 0e 00 00       	and    $0xe07,%eax
  80149e:	50                   	push   %eax
  80149f:	57                   	push   %edi
  8014a0:	6a 00                	push   $0x0
  8014a2:	53                   	push   %ebx
  8014a3:	6a 00                	push   $0x0
  8014a5:	e8 a9 f7 ff ff       	call   800c53 <sys_page_map>
  8014aa:	89 c3                	mov    %eax,%ebx
  8014ac:	83 c4 20             	add    $0x20,%esp
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	79 a3                	jns    801456 <dup+0x74>
	sys_page_unmap(0, newfd);
  8014b3:	83 ec 08             	sub    $0x8,%esp
  8014b6:	56                   	push   %esi
  8014b7:	6a 00                	push   $0x0
  8014b9:	e8 d7 f7 ff ff       	call   800c95 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014be:	83 c4 08             	add    $0x8,%esp
  8014c1:	57                   	push   %edi
  8014c2:	6a 00                	push   $0x0
  8014c4:	e8 cc f7 ff ff       	call   800c95 <sys_page_unmap>
	return r;
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	eb b7                	jmp    801485 <dup+0xa3>

008014ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	53                   	push   %ebx
  8014d2:	83 ec 14             	sub    $0x14,%esp
  8014d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	53                   	push   %ebx
  8014dd:	e8 7b fd ff ff       	call   80125d <fd_lookup>
  8014e2:	83 c4 08             	add    $0x8,%esp
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 3f                	js     801528 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ef:	50                   	push   %eax
  8014f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f3:	ff 30                	pushl  (%eax)
  8014f5:	e8 b9 fd ff ff       	call   8012b3 <dev_lookup>
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 27                	js     801528 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801501:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801504:	8b 42 08             	mov    0x8(%edx),%eax
  801507:	83 e0 03             	and    $0x3,%eax
  80150a:	83 f8 01             	cmp    $0x1,%eax
  80150d:	74 1e                	je     80152d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80150f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801512:	8b 40 08             	mov    0x8(%eax),%eax
  801515:	85 c0                	test   %eax,%eax
  801517:	74 35                	je     80154e <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801519:	83 ec 04             	sub    $0x4,%esp
  80151c:	ff 75 10             	pushl  0x10(%ebp)
  80151f:	ff 75 0c             	pushl  0xc(%ebp)
  801522:	52                   	push   %edx
  801523:	ff d0                	call   *%eax
  801525:	83 c4 10             	add    $0x10,%esp
}
  801528:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152b:	c9                   	leave  
  80152c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80152d:	a1 08 40 80 00       	mov    0x804008,%eax
  801532:	8b 40 48             	mov    0x48(%eax),%eax
  801535:	83 ec 04             	sub    $0x4,%esp
  801538:	53                   	push   %ebx
  801539:	50                   	push   %eax
  80153a:	68 81 26 80 00       	push   $0x802681
  80153f:	e8 b4 ec ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80154c:	eb da                	jmp    801528 <read+0x5a>
		return -E_NOT_SUPP;
  80154e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801553:	eb d3                	jmp    801528 <read+0x5a>

00801555 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	57                   	push   %edi
  801559:	56                   	push   %esi
  80155a:	53                   	push   %ebx
  80155b:	83 ec 0c             	sub    $0xc,%esp
  80155e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801561:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801564:	bb 00 00 00 00       	mov    $0x0,%ebx
  801569:	39 f3                	cmp    %esi,%ebx
  80156b:	73 25                	jae    801592 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156d:	83 ec 04             	sub    $0x4,%esp
  801570:	89 f0                	mov    %esi,%eax
  801572:	29 d8                	sub    %ebx,%eax
  801574:	50                   	push   %eax
  801575:	89 d8                	mov    %ebx,%eax
  801577:	03 45 0c             	add    0xc(%ebp),%eax
  80157a:	50                   	push   %eax
  80157b:	57                   	push   %edi
  80157c:	e8 4d ff ff ff       	call   8014ce <read>
		if (m < 0)
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	85 c0                	test   %eax,%eax
  801586:	78 08                	js     801590 <readn+0x3b>
			return m;
		if (m == 0)
  801588:	85 c0                	test   %eax,%eax
  80158a:	74 06                	je     801592 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80158c:	01 c3                	add    %eax,%ebx
  80158e:	eb d9                	jmp    801569 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801590:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801592:	89 d8                	mov    %ebx,%eax
  801594:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801597:	5b                   	pop    %ebx
  801598:	5e                   	pop    %esi
  801599:	5f                   	pop    %edi
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    

0080159c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	53                   	push   %ebx
  8015a0:	83 ec 14             	sub    $0x14,%esp
  8015a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	53                   	push   %ebx
  8015ab:	e8 ad fc ff ff       	call   80125d <fd_lookup>
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 3a                	js     8015f1 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c1:	ff 30                	pushl  (%eax)
  8015c3:	e8 eb fc ff ff       	call   8012b3 <dev_lookup>
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 22                	js     8015f1 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d6:	74 1e                	je     8015f6 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015db:	8b 52 0c             	mov    0xc(%edx),%edx
  8015de:	85 d2                	test   %edx,%edx
  8015e0:	74 35                	je     801617 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015e2:	83 ec 04             	sub    $0x4,%esp
  8015e5:	ff 75 10             	pushl  0x10(%ebp)
  8015e8:	ff 75 0c             	pushl  0xc(%ebp)
  8015eb:	50                   	push   %eax
  8015ec:	ff d2                	call   *%edx
  8015ee:	83 c4 10             	add    $0x10,%esp
}
  8015f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f4:	c9                   	leave  
  8015f5:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8015fb:	8b 40 48             	mov    0x48(%eax),%eax
  8015fe:	83 ec 04             	sub    $0x4,%esp
  801601:	53                   	push   %ebx
  801602:	50                   	push   %eax
  801603:	68 9d 26 80 00       	push   $0x80269d
  801608:	e8 eb eb ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801615:	eb da                	jmp    8015f1 <write+0x55>
		return -E_NOT_SUPP;
  801617:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80161c:	eb d3                	jmp    8015f1 <write+0x55>

0080161e <seek>:

int
seek(int fdnum, off_t offset)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801624:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801627:	50                   	push   %eax
  801628:	ff 75 08             	pushl  0x8(%ebp)
  80162b:	e8 2d fc ff ff       	call   80125d <fd_lookup>
  801630:	83 c4 08             	add    $0x8,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 0e                	js     801645 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801637:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80163d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801640:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 14             	sub    $0x14,%esp
  80164e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801651:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	53                   	push   %ebx
  801656:	e8 02 fc ff ff       	call   80125d <fd_lookup>
  80165b:	83 c4 08             	add    $0x8,%esp
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 37                	js     801699 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166c:	ff 30                	pushl  (%eax)
  80166e:	e8 40 fc ff ff       	call   8012b3 <dev_lookup>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 1f                	js     801699 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801681:	74 1b                	je     80169e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801683:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801686:	8b 52 18             	mov    0x18(%edx),%edx
  801689:	85 d2                	test   %edx,%edx
  80168b:	74 32                	je     8016bf <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80168d:	83 ec 08             	sub    $0x8,%esp
  801690:	ff 75 0c             	pushl  0xc(%ebp)
  801693:	50                   	push   %eax
  801694:	ff d2                	call   *%edx
  801696:	83 c4 10             	add    $0x10,%esp
}
  801699:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80169e:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a3:	8b 40 48             	mov    0x48(%eax),%eax
  8016a6:	83 ec 04             	sub    $0x4,%esp
  8016a9:	53                   	push   %ebx
  8016aa:	50                   	push   %eax
  8016ab:	68 60 26 80 00       	push   $0x802660
  8016b0:	e8 43 eb ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016bd:	eb da                	jmp    801699 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8016bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016c4:	eb d3                	jmp    801699 <ftruncate+0x52>

008016c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 14             	sub    $0x14,%esp
  8016cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d3:	50                   	push   %eax
  8016d4:	ff 75 08             	pushl  0x8(%ebp)
  8016d7:	e8 81 fb ff ff       	call   80125d <fd_lookup>
  8016dc:	83 c4 08             	add    $0x8,%esp
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 4b                	js     80172e <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e3:	83 ec 08             	sub    $0x8,%esp
  8016e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e9:	50                   	push   %eax
  8016ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ed:	ff 30                	pushl  (%eax)
  8016ef:	e8 bf fb ff ff       	call   8012b3 <dev_lookup>
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	78 33                	js     80172e <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8016fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801702:	74 2f                	je     801733 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801704:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801707:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80170e:	00 00 00 
	stat->st_isdir = 0;
  801711:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801718:	00 00 00 
	stat->st_dev = dev;
  80171b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801721:	83 ec 08             	sub    $0x8,%esp
  801724:	53                   	push   %ebx
  801725:	ff 75 f0             	pushl  -0x10(%ebp)
  801728:	ff 50 14             	call   *0x14(%eax)
  80172b:	83 c4 10             	add    $0x10,%esp
}
  80172e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801731:	c9                   	leave  
  801732:	c3                   	ret    
		return -E_NOT_SUPP;
  801733:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801738:	eb f4                	jmp    80172e <fstat+0x68>

0080173a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	6a 00                	push   $0x0
  801744:	ff 75 08             	pushl  0x8(%ebp)
  801747:	e8 da 01 00 00       	call   801926 <open>
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 1b                	js     801770 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801755:	83 ec 08             	sub    $0x8,%esp
  801758:	ff 75 0c             	pushl  0xc(%ebp)
  80175b:	50                   	push   %eax
  80175c:	e8 65 ff ff ff       	call   8016c6 <fstat>
  801761:	89 c6                	mov    %eax,%esi
	close(fd);
  801763:	89 1c 24             	mov    %ebx,(%esp)
  801766:	e8 27 fc ff ff       	call   801392 <close>
	return r;
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	89 f3                	mov    %esi,%ebx
}
  801770:	89 d8                	mov    %ebx,%eax
  801772:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	56                   	push   %esi
  80177d:	53                   	push   %ebx
  80177e:	89 c6                	mov    %eax,%esi
  801780:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801782:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801789:	74 27                	je     8017b2 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80178b:	6a 07                	push   $0x7
  80178d:	68 00 50 80 00       	push   $0x805000
  801792:	56                   	push   %esi
  801793:	ff 35 00 40 80 00    	pushl  0x804000
  801799:	e8 bc f9 ff ff       	call   80115a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80179e:	83 c4 0c             	add    $0xc,%esp
  8017a1:	6a 00                	push   $0x0
  8017a3:	53                   	push   %ebx
  8017a4:	6a 00                	push   $0x0
  8017a6:	e8 48 f9 ff ff       	call   8010f3 <ipc_recv>
}
  8017ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ae:	5b                   	pop    %ebx
  8017af:	5e                   	pop    %esi
  8017b0:	5d                   	pop    %ebp
  8017b1:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b2:	83 ec 0c             	sub    $0xc,%esp
  8017b5:	6a 01                	push   $0x1
  8017b7:	e8 f2 f9 ff ff       	call   8011ae <ipc_find_env>
  8017bc:	a3 00 40 80 00       	mov    %eax,0x804000
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	eb c5                	jmp    80178b <fsipc+0x12>

008017c6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017da:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017e9:	e8 8b ff ff ff       	call   801779 <fsipc>
}
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <devfile_flush>:
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801801:	ba 00 00 00 00       	mov    $0x0,%edx
  801806:	b8 06 00 00 00       	mov    $0x6,%eax
  80180b:	e8 69 ff ff ff       	call   801779 <fsipc>
}
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <devfile_stat>:
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	53                   	push   %ebx
  801816:	83 ec 04             	sub    $0x4,%esp
  801819:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80181c:	8b 45 08             	mov    0x8(%ebp),%eax
  80181f:	8b 40 0c             	mov    0xc(%eax),%eax
  801822:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801827:	ba 00 00 00 00       	mov    $0x0,%edx
  80182c:	b8 05 00 00 00       	mov    $0x5,%eax
  801831:	e8 43 ff ff ff       	call   801779 <fsipc>
  801836:	85 c0                	test   %eax,%eax
  801838:	78 2c                	js     801866 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80183a:	83 ec 08             	sub    $0x8,%esp
  80183d:	68 00 50 80 00       	push   $0x805000
  801842:	53                   	push   %ebx
  801843:	e8 cf ef ff ff       	call   800817 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801848:	a1 80 50 80 00       	mov    0x805080,%eax
  80184d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801853:	a1 84 50 80 00       	mov    0x805084,%eax
  801858:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801866:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801869:	c9                   	leave  
  80186a:	c3                   	ret    

0080186b <devfile_write>:
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	83 ec 0c             	sub    $0xc,%esp
  801871:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801874:	8b 55 08             	mov    0x8(%ebp),%edx
  801877:	8b 52 0c             	mov    0xc(%edx),%edx
  80187a:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  801880:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  801885:	50                   	push   %eax
  801886:	ff 75 0c             	pushl  0xc(%ebp)
  801889:	68 08 50 80 00       	push   $0x805008
  80188e:	e8 12 f1 ff ff       	call   8009a5 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  801893:	ba 00 00 00 00       	mov    $0x0,%edx
  801898:	b8 04 00 00 00       	mov    $0x4,%eax
  80189d:	e8 d7 fe ff ff       	call   801779 <fsipc>
}
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <devfile_read>:
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	56                   	push   %esi
  8018a8:	53                   	push   %ebx
  8018a9:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8018af:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018b7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c2:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c7:	e8 ad fe ff ff       	call   801779 <fsipc>
  8018cc:	89 c3                	mov    %eax,%ebx
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 1f                	js     8018f1 <devfile_read+0x4d>
	assert(r <= n);
  8018d2:	39 f0                	cmp    %esi,%eax
  8018d4:	77 24                	ja     8018fa <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018d6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018db:	7f 33                	jg     801910 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018dd:	83 ec 04             	sub    $0x4,%esp
  8018e0:	50                   	push   %eax
  8018e1:	68 00 50 80 00       	push   $0x805000
  8018e6:	ff 75 0c             	pushl  0xc(%ebp)
  8018e9:	e8 b7 f0 ff ff       	call   8009a5 <memmove>
	return r;
  8018ee:	83 c4 10             	add    $0x10,%esp
}
  8018f1:	89 d8                	mov    %ebx,%eax
  8018f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f6:	5b                   	pop    %ebx
  8018f7:	5e                   	pop    %esi
  8018f8:	5d                   	pop    %ebp
  8018f9:	c3                   	ret    
	assert(r <= n);
  8018fa:	68 cc 26 80 00       	push   $0x8026cc
  8018ff:	68 d3 26 80 00       	push   $0x8026d3
  801904:	6a 7c                	push   $0x7c
  801906:	68 e8 26 80 00       	push   $0x8026e8
  80190b:	e8 85 05 00 00       	call   801e95 <_panic>
	assert(r <= PGSIZE);
  801910:	68 f3 26 80 00       	push   $0x8026f3
  801915:	68 d3 26 80 00       	push   $0x8026d3
  80191a:	6a 7d                	push   $0x7d
  80191c:	68 e8 26 80 00       	push   $0x8026e8
  801921:	e8 6f 05 00 00       	call   801e95 <_panic>

00801926 <open>:
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	56                   	push   %esi
  80192a:	53                   	push   %ebx
  80192b:	83 ec 1c             	sub    $0x1c,%esp
  80192e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801931:	56                   	push   %esi
  801932:	e8 a9 ee ff ff       	call   8007e0 <strlen>
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80193f:	7f 6c                	jg     8019ad <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801941:	83 ec 0c             	sub    $0xc,%esp
  801944:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801947:	50                   	push   %eax
  801948:	e8 c1 f8 ff ff       	call   80120e <fd_alloc>
  80194d:	89 c3                	mov    %eax,%ebx
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	85 c0                	test   %eax,%eax
  801954:	78 3c                	js     801992 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801956:	83 ec 08             	sub    $0x8,%esp
  801959:	56                   	push   %esi
  80195a:	68 00 50 80 00       	push   $0x805000
  80195f:	e8 b3 ee ff ff       	call   800817 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801964:	8b 45 0c             	mov    0xc(%ebp),%eax
  801967:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80196c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196f:	b8 01 00 00 00       	mov    $0x1,%eax
  801974:	e8 00 fe ff ff       	call   801779 <fsipc>
  801979:	89 c3                	mov    %eax,%ebx
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 19                	js     80199b <open+0x75>
	return fd2num(fd);
  801982:	83 ec 0c             	sub    $0xc,%esp
  801985:	ff 75 f4             	pushl  -0xc(%ebp)
  801988:	e8 5a f8 ff ff       	call   8011e7 <fd2num>
  80198d:	89 c3                	mov    %eax,%ebx
  80198f:	83 c4 10             	add    $0x10,%esp
}
  801992:	89 d8                	mov    %ebx,%eax
  801994:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801997:	5b                   	pop    %ebx
  801998:	5e                   	pop    %esi
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    
		fd_close(fd, 0);
  80199b:	83 ec 08             	sub    $0x8,%esp
  80199e:	6a 00                	push   $0x0
  8019a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a3:	e8 61 f9 ff ff       	call   801309 <fd_close>
		return r;
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	eb e5                	jmp    801992 <open+0x6c>
		return -E_BAD_PATH;
  8019ad:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019b2:	eb de                	jmp    801992 <open+0x6c>

008019b4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bf:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c4:	e8 b0 fd ff ff       	call   801779 <fsipc>
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	56                   	push   %esi
  8019cf:	53                   	push   %ebx
  8019d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d3:	83 ec 0c             	sub    $0xc,%esp
  8019d6:	ff 75 08             	pushl  0x8(%ebp)
  8019d9:	e8 19 f8 ff ff       	call   8011f7 <fd2data>
  8019de:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e0:	83 c4 08             	add    $0x8,%esp
  8019e3:	68 ff 26 80 00       	push   $0x8026ff
  8019e8:	53                   	push   %ebx
  8019e9:	e8 29 ee ff ff       	call   800817 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ee:	8b 46 04             	mov    0x4(%esi),%eax
  8019f1:	2b 06                	sub    (%esi),%eax
  8019f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a00:	00 00 00 
	stat->st_dev = &devpipe;
  801a03:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a0a:	30 80 00 
	return 0;
}
  801a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a15:	5b                   	pop    %ebx
  801a16:	5e                   	pop    %esi
  801a17:	5d                   	pop    %ebp
  801a18:	c3                   	ret    

00801a19 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	53                   	push   %ebx
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a23:	53                   	push   %ebx
  801a24:	6a 00                	push   $0x0
  801a26:	e8 6a f2 ff ff       	call   800c95 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a2b:	89 1c 24             	mov    %ebx,(%esp)
  801a2e:	e8 c4 f7 ff ff       	call   8011f7 <fd2data>
  801a33:	83 c4 08             	add    $0x8,%esp
  801a36:	50                   	push   %eax
  801a37:	6a 00                	push   $0x0
  801a39:	e8 57 f2 ff ff       	call   800c95 <sys_page_unmap>
}
  801a3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <_pipeisclosed>:
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	57                   	push   %edi
  801a47:	56                   	push   %esi
  801a48:	53                   	push   %ebx
  801a49:	83 ec 1c             	sub    $0x1c,%esp
  801a4c:	89 c7                	mov    %eax,%edi
  801a4e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a50:	a1 08 40 80 00       	mov    0x804008,%eax
  801a55:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a58:	83 ec 0c             	sub    $0xc,%esp
  801a5b:	57                   	push   %edi
  801a5c:	e8 0f 05 00 00       	call   801f70 <pageref>
  801a61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a64:	89 34 24             	mov    %esi,(%esp)
  801a67:	e8 04 05 00 00       	call   801f70 <pageref>
		nn = thisenv->env_runs;
  801a6c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a72:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	39 cb                	cmp    %ecx,%ebx
  801a7a:	74 1b                	je     801a97 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a7c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a7f:	75 cf                	jne    801a50 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a81:	8b 42 58             	mov    0x58(%edx),%eax
  801a84:	6a 01                	push   $0x1
  801a86:	50                   	push   %eax
  801a87:	53                   	push   %ebx
  801a88:	68 06 27 80 00       	push   $0x802706
  801a8d:	e8 66 e7 ff ff       	call   8001f8 <cprintf>
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	eb b9                	jmp    801a50 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a97:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a9a:	0f 94 c0             	sete   %al
  801a9d:	0f b6 c0             	movzbl %al,%eax
}
  801aa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa3:	5b                   	pop    %ebx
  801aa4:	5e                   	pop    %esi
  801aa5:	5f                   	pop    %edi
  801aa6:	5d                   	pop    %ebp
  801aa7:	c3                   	ret    

00801aa8 <devpipe_write>:
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	57                   	push   %edi
  801aac:	56                   	push   %esi
  801aad:	53                   	push   %ebx
  801aae:	83 ec 28             	sub    $0x28,%esp
  801ab1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ab4:	56                   	push   %esi
  801ab5:	e8 3d f7 ff ff       	call   8011f7 <fd2data>
  801aba:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ac7:	74 4f                	je     801b18 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac9:	8b 43 04             	mov    0x4(%ebx),%eax
  801acc:	8b 0b                	mov    (%ebx),%ecx
  801ace:	8d 51 20             	lea    0x20(%ecx),%edx
  801ad1:	39 d0                	cmp    %edx,%eax
  801ad3:	72 14                	jb     801ae9 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801ad5:	89 da                	mov    %ebx,%edx
  801ad7:	89 f0                	mov    %esi,%eax
  801ad9:	e8 65 ff ff ff       	call   801a43 <_pipeisclosed>
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	75 3a                	jne    801b1c <devpipe_write+0x74>
			sys_yield();
  801ae2:	e8 0a f1 ff ff       	call   800bf1 <sys_yield>
  801ae7:	eb e0                	jmp    801ac9 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aec:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801af0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801af3:	89 c2                	mov    %eax,%edx
  801af5:	c1 fa 1f             	sar    $0x1f,%edx
  801af8:	89 d1                	mov    %edx,%ecx
  801afa:	c1 e9 1b             	shr    $0x1b,%ecx
  801afd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b00:	83 e2 1f             	and    $0x1f,%edx
  801b03:	29 ca                	sub    %ecx,%edx
  801b05:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b09:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b0d:	83 c0 01             	add    $0x1,%eax
  801b10:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b13:	83 c7 01             	add    $0x1,%edi
  801b16:	eb ac                	jmp    801ac4 <devpipe_write+0x1c>
	return i;
  801b18:	89 f8                	mov    %edi,%eax
  801b1a:	eb 05                	jmp    801b21 <devpipe_write+0x79>
				return 0;
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b24:	5b                   	pop    %ebx
  801b25:	5e                   	pop    %esi
  801b26:	5f                   	pop    %edi
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <devpipe_read>:
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	57                   	push   %edi
  801b2d:	56                   	push   %esi
  801b2e:	53                   	push   %ebx
  801b2f:	83 ec 18             	sub    $0x18,%esp
  801b32:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b35:	57                   	push   %edi
  801b36:	e8 bc f6 ff ff       	call   8011f7 <fd2data>
  801b3b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	be 00 00 00 00       	mov    $0x0,%esi
  801b45:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b48:	74 47                	je     801b91 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801b4a:	8b 03                	mov    (%ebx),%eax
  801b4c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b4f:	75 22                	jne    801b73 <devpipe_read+0x4a>
			if (i > 0)
  801b51:	85 f6                	test   %esi,%esi
  801b53:	75 14                	jne    801b69 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801b55:	89 da                	mov    %ebx,%edx
  801b57:	89 f8                	mov    %edi,%eax
  801b59:	e8 e5 fe ff ff       	call   801a43 <_pipeisclosed>
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	75 33                	jne    801b95 <devpipe_read+0x6c>
			sys_yield();
  801b62:	e8 8a f0 ff ff       	call   800bf1 <sys_yield>
  801b67:	eb e1                	jmp    801b4a <devpipe_read+0x21>
				return i;
  801b69:	89 f0                	mov    %esi,%eax
}
  801b6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6e:	5b                   	pop    %ebx
  801b6f:	5e                   	pop    %esi
  801b70:	5f                   	pop    %edi
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b73:	99                   	cltd   
  801b74:	c1 ea 1b             	shr    $0x1b,%edx
  801b77:	01 d0                	add    %edx,%eax
  801b79:	83 e0 1f             	and    $0x1f,%eax
  801b7c:	29 d0                	sub    %edx,%eax
  801b7e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b86:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b89:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b8c:	83 c6 01             	add    $0x1,%esi
  801b8f:	eb b4                	jmp    801b45 <devpipe_read+0x1c>
	return i;
  801b91:	89 f0                	mov    %esi,%eax
  801b93:	eb d6                	jmp    801b6b <devpipe_read+0x42>
				return 0;
  801b95:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9a:	eb cf                	jmp    801b6b <devpipe_read+0x42>

00801b9c <pipe>:
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	56                   	push   %esi
  801ba0:	53                   	push   %ebx
  801ba1:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ba4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba7:	50                   	push   %eax
  801ba8:	e8 61 f6 ff ff       	call   80120e <fd_alloc>
  801bad:	89 c3                	mov    %eax,%ebx
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	78 5b                	js     801c11 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb6:	83 ec 04             	sub    $0x4,%esp
  801bb9:	68 07 04 00 00       	push   $0x407
  801bbe:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc1:	6a 00                	push   $0x0
  801bc3:	e8 48 f0 ff ff       	call   800c10 <sys_page_alloc>
  801bc8:	89 c3                	mov    %eax,%ebx
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	78 40                	js     801c11 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801bd1:	83 ec 0c             	sub    $0xc,%esp
  801bd4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd7:	50                   	push   %eax
  801bd8:	e8 31 f6 ff ff       	call   80120e <fd_alloc>
  801bdd:	89 c3                	mov    %eax,%ebx
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	85 c0                	test   %eax,%eax
  801be4:	78 1b                	js     801c01 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be6:	83 ec 04             	sub    $0x4,%esp
  801be9:	68 07 04 00 00       	push   $0x407
  801bee:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf1:	6a 00                	push   $0x0
  801bf3:	e8 18 f0 ff ff       	call   800c10 <sys_page_alloc>
  801bf8:	89 c3                	mov    %eax,%ebx
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	79 19                	jns    801c1a <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801c01:	83 ec 08             	sub    $0x8,%esp
  801c04:	ff 75 f4             	pushl  -0xc(%ebp)
  801c07:	6a 00                	push   $0x0
  801c09:	e8 87 f0 ff ff       	call   800c95 <sys_page_unmap>
  801c0e:	83 c4 10             	add    $0x10,%esp
}
  801c11:	89 d8                	mov    %ebx,%eax
  801c13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    
	va = fd2data(fd0);
  801c1a:	83 ec 0c             	sub    $0xc,%esp
  801c1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c20:	e8 d2 f5 ff ff       	call   8011f7 <fd2data>
  801c25:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c27:	83 c4 0c             	add    $0xc,%esp
  801c2a:	68 07 04 00 00       	push   $0x407
  801c2f:	50                   	push   %eax
  801c30:	6a 00                	push   $0x0
  801c32:	e8 d9 ef ff ff       	call   800c10 <sys_page_alloc>
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	0f 88 8c 00 00 00    	js     801cd0 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c44:	83 ec 0c             	sub    $0xc,%esp
  801c47:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4a:	e8 a8 f5 ff ff       	call   8011f7 <fd2data>
  801c4f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c56:	50                   	push   %eax
  801c57:	6a 00                	push   $0x0
  801c59:	56                   	push   %esi
  801c5a:	6a 00                	push   $0x0
  801c5c:	e8 f2 ef ff ff       	call   800c53 <sys_page_map>
  801c61:	89 c3                	mov    %eax,%ebx
  801c63:	83 c4 20             	add    $0x20,%esp
  801c66:	85 c0                	test   %eax,%eax
  801c68:	78 58                	js     801cc2 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c73:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c78:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c82:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c88:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c8d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9a:	e8 48 f5 ff ff       	call   8011e7 <fd2num>
  801c9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ca4:	83 c4 04             	add    $0x4,%esp
  801ca7:	ff 75 f0             	pushl  -0x10(%ebp)
  801caa:	e8 38 f5 ff ff       	call   8011e7 <fd2num>
  801caf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cbd:	e9 4f ff ff ff       	jmp    801c11 <pipe+0x75>
	sys_page_unmap(0, va);
  801cc2:	83 ec 08             	sub    $0x8,%esp
  801cc5:	56                   	push   %esi
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 c8 ef ff ff       	call   800c95 <sys_page_unmap>
  801ccd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cd0:	83 ec 08             	sub    $0x8,%esp
  801cd3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd6:	6a 00                	push   $0x0
  801cd8:	e8 b8 ef ff ff       	call   800c95 <sys_page_unmap>
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	e9 1c ff ff ff       	jmp    801c01 <pipe+0x65>

00801ce5 <pipeisclosed>:
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ceb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cee:	50                   	push   %eax
  801cef:	ff 75 08             	pushl  0x8(%ebp)
  801cf2:	e8 66 f5 ff ff       	call   80125d <fd_lookup>
  801cf7:	83 c4 10             	add    $0x10,%esp
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	78 18                	js     801d16 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	ff 75 f4             	pushl  -0xc(%ebp)
  801d04:	e8 ee f4 ff ff       	call   8011f7 <fd2data>
	return _pipeisclosed(fd, p);
  801d09:	89 c2                	mov    %eax,%edx
  801d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0e:	e8 30 fd ff ff       	call   801a43 <_pipeisclosed>
  801d13:	83 c4 10             	add    $0x10,%esp
}
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    

00801d18 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    

00801d22 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d28:	68 1e 27 80 00       	push   $0x80271e
  801d2d:	ff 75 0c             	pushl  0xc(%ebp)
  801d30:	e8 e2 ea ff ff       	call   800817 <strcpy>
	return 0;
}
  801d35:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <devcons_write>:
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	57                   	push   %edi
  801d40:	56                   	push   %esi
  801d41:	53                   	push   %ebx
  801d42:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d48:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d4d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d53:	eb 2f                	jmp    801d84 <devcons_write+0x48>
		m = n - tot;
  801d55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d58:	29 f3                	sub    %esi,%ebx
  801d5a:	83 fb 7f             	cmp    $0x7f,%ebx
  801d5d:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d62:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d65:	83 ec 04             	sub    $0x4,%esp
  801d68:	53                   	push   %ebx
  801d69:	89 f0                	mov    %esi,%eax
  801d6b:	03 45 0c             	add    0xc(%ebp),%eax
  801d6e:	50                   	push   %eax
  801d6f:	57                   	push   %edi
  801d70:	e8 30 ec ff ff       	call   8009a5 <memmove>
		sys_cputs(buf, m);
  801d75:	83 c4 08             	add    $0x8,%esp
  801d78:	53                   	push   %ebx
  801d79:	57                   	push   %edi
  801d7a:	e8 d5 ed ff ff       	call   800b54 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d7f:	01 de                	add    %ebx,%esi
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d87:	72 cc                	jb     801d55 <devcons_write+0x19>
}
  801d89:	89 f0                	mov    %esi,%eax
  801d8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    

00801d93 <devcons_read>:
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 08             	sub    $0x8,%esp
  801d99:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da2:	75 07                	jne    801dab <devcons_read+0x18>
}
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    
		sys_yield();
  801da6:	e8 46 ee ff ff       	call   800bf1 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801dab:	e8 c2 ed ff ff       	call   800b72 <sys_cgetc>
  801db0:	85 c0                	test   %eax,%eax
  801db2:	74 f2                	je     801da6 <devcons_read+0x13>
	if (c < 0)
  801db4:	85 c0                	test   %eax,%eax
  801db6:	78 ec                	js     801da4 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801db8:	83 f8 04             	cmp    $0x4,%eax
  801dbb:	74 0c                	je     801dc9 <devcons_read+0x36>
	*(char*)vbuf = c;
  801dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc0:	88 02                	mov    %al,(%edx)
	return 1;
  801dc2:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc7:	eb db                	jmp    801da4 <devcons_read+0x11>
		return 0;
  801dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dce:	eb d4                	jmp    801da4 <devcons_read+0x11>

00801dd0 <cputchar>:
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd9:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ddc:	6a 01                	push   $0x1
  801dde:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de1:	50                   	push   %eax
  801de2:	e8 6d ed ff ff       	call   800b54 <sys_cputs>
}
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    

00801dec <getchar>:
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801df2:	6a 01                	push   $0x1
  801df4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df7:	50                   	push   %eax
  801df8:	6a 00                	push   $0x0
  801dfa:	e8 cf f6 ff ff       	call   8014ce <read>
	if (r < 0)
  801dff:	83 c4 10             	add    $0x10,%esp
  801e02:	85 c0                	test   %eax,%eax
  801e04:	78 08                	js     801e0e <getchar+0x22>
	if (r < 1)
  801e06:	85 c0                	test   %eax,%eax
  801e08:	7e 06                	jle    801e10 <getchar+0x24>
	return c;
  801e0a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    
		return -E_EOF;
  801e10:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e15:	eb f7                	jmp    801e0e <getchar+0x22>

00801e17 <iscons>:
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e20:	50                   	push   %eax
  801e21:	ff 75 08             	pushl  0x8(%ebp)
  801e24:	e8 34 f4 ff ff       	call   80125d <fd_lookup>
  801e29:	83 c4 10             	add    $0x10,%esp
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	78 11                	js     801e41 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e33:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e39:	39 10                	cmp    %edx,(%eax)
  801e3b:	0f 94 c0             	sete   %al
  801e3e:	0f b6 c0             	movzbl %al,%eax
}
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    

00801e43 <opencons>:
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4c:	50                   	push   %eax
  801e4d:	e8 bc f3 ff ff       	call   80120e <fd_alloc>
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	85 c0                	test   %eax,%eax
  801e57:	78 3a                	js     801e93 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e59:	83 ec 04             	sub    $0x4,%esp
  801e5c:	68 07 04 00 00       	push   $0x407
  801e61:	ff 75 f4             	pushl  -0xc(%ebp)
  801e64:	6a 00                	push   $0x0
  801e66:	e8 a5 ed ff ff       	call   800c10 <sys_page_alloc>
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	78 21                	js     801e93 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e75:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e7b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e80:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e87:	83 ec 0c             	sub    $0xc,%esp
  801e8a:	50                   	push   %eax
  801e8b:	e8 57 f3 ff ff       	call   8011e7 <fd2num>
  801e90:	83 c4 10             	add    $0x10,%esp
}
  801e93:	c9                   	leave  
  801e94:	c3                   	ret    

00801e95 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	56                   	push   %esi
  801e99:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e9a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e9d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ea3:	e8 2a ed ff ff       	call   800bd2 <sys_getenvid>
  801ea8:	83 ec 0c             	sub    $0xc,%esp
  801eab:	ff 75 0c             	pushl  0xc(%ebp)
  801eae:	ff 75 08             	pushl  0x8(%ebp)
  801eb1:	56                   	push   %esi
  801eb2:	50                   	push   %eax
  801eb3:	68 2c 27 80 00       	push   $0x80272c
  801eb8:	e8 3b e3 ff ff       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ebd:	83 c4 18             	add    $0x18,%esp
  801ec0:	53                   	push   %ebx
  801ec1:	ff 75 10             	pushl  0x10(%ebp)
  801ec4:	e8 de e2 ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  801ec9:	c7 04 24 17 27 80 00 	movl   $0x802717,(%esp)
  801ed0:	e8 23 e3 ff ff       	call   8001f8 <cprintf>
  801ed5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ed8:	cc                   	int3   
  801ed9:	eb fd                	jmp    801ed8 <_panic+0x43>

00801edb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ee1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ee8:	74 20                	je     801f0a <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eea:	8b 45 08             	mov    0x8(%ebp),%eax
  801eed:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801ef2:	83 ec 08             	sub    $0x8,%esp
  801ef5:	68 4a 1f 80 00       	push   $0x801f4a
  801efa:	6a 00                	push   $0x0
  801efc:	e8 5a ee ff ff       	call   800d5b <sys_env_set_pgfault_upcall>
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	85 c0                	test   %eax,%eax
  801f06:	78 2e                	js     801f36 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  801f08:	c9                   	leave  
  801f09:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801f0a:	83 ec 04             	sub    $0x4,%esp
  801f0d:	6a 07                	push   $0x7
  801f0f:	68 00 f0 bf ee       	push   $0xeebff000
  801f14:	6a 00                	push   $0x0
  801f16:	e8 f5 ec ff ff       	call   800c10 <sys_page_alloc>
  801f1b:	83 c4 10             	add    $0x10,%esp
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	79 c8                	jns    801eea <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801f22:	83 ec 04             	sub    $0x4,%esp
  801f25:	68 50 27 80 00       	push   $0x802750
  801f2a:	6a 21                	push   $0x21
  801f2c:	68 b4 27 80 00       	push   $0x8027b4
  801f31:	e8 5f ff ff ff       	call   801e95 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801f36:	83 ec 04             	sub    $0x4,%esp
  801f39:	68 7c 27 80 00       	push   $0x80277c
  801f3e:	6a 27                	push   $0x27
  801f40:	68 b4 27 80 00       	push   $0x8027b4
  801f45:	e8 4b ff ff ff       	call   801e95 <_panic>

00801f4a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f4a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f4b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f50:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f52:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801f55:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801f59:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801f5c:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  801f60:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f64:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801f66:	83 c4 08             	add    $0x8,%esp
	popal
  801f69:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801f6a:	83 c4 04             	add    $0x4,%esp
	popfl
  801f6d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f6e:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f6f:	c3                   	ret    

00801f70 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f76:	89 d0                	mov    %edx,%eax
  801f78:	c1 e8 16             	shr    $0x16,%eax
  801f7b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f82:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f87:	f6 c1 01             	test   $0x1,%cl
  801f8a:	74 1d                	je     801fa9 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f8c:	c1 ea 0c             	shr    $0xc,%edx
  801f8f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f96:	f6 c2 01             	test   $0x1,%dl
  801f99:	74 0e                	je     801fa9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f9b:	c1 ea 0c             	shr    $0xc,%edx
  801f9e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fa5:	ef 
  801fa6:	0f b7 c0             	movzwl %ax,%eax
}
  801fa9:	5d                   	pop    %ebp
  801faa:	c3                   	ret    
  801fab:	66 90                	xchg   %ax,%ax
  801fad:	66 90                	xchg   %ax,%ax
  801faf:	90                   	nop

00801fb0 <__udivdi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fbb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801fbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fc3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801fc7:	85 d2                	test   %edx,%edx
  801fc9:	75 35                	jne    802000 <__udivdi3+0x50>
  801fcb:	39 f3                	cmp    %esi,%ebx
  801fcd:	0f 87 bd 00 00 00    	ja     802090 <__udivdi3+0xe0>
  801fd3:	85 db                	test   %ebx,%ebx
  801fd5:	89 d9                	mov    %ebx,%ecx
  801fd7:	75 0b                	jne    801fe4 <__udivdi3+0x34>
  801fd9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fde:	31 d2                	xor    %edx,%edx
  801fe0:	f7 f3                	div    %ebx
  801fe2:	89 c1                	mov    %eax,%ecx
  801fe4:	31 d2                	xor    %edx,%edx
  801fe6:	89 f0                	mov    %esi,%eax
  801fe8:	f7 f1                	div    %ecx
  801fea:	89 c6                	mov    %eax,%esi
  801fec:	89 e8                	mov    %ebp,%eax
  801fee:	89 f7                	mov    %esi,%edi
  801ff0:	f7 f1                	div    %ecx
  801ff2:	89 fa                	mov    %edi,%edx
  801ff4:	83 c4 1c             	add    $0x1c,%esp
  801ff7:	5b                   	pop    %ebx
  801ff8:	5e                   	pop    %esi
  801ff9:	5f                   	pop    %edi
  801ffa:	5d                   	pop    %ebp
  801ffb:	c3                   	ret    
  801ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802000:	39 f2                	cmp    %esi,%edx
  802002:	77 7c                	ja     802080 <__udivdi3+0xd0>
  802004:	0f bd fa             	bsr    %edx,%edi
  802007:	83 f7 1f             	xor    $0x1f,%edi
  80200a:	0f 84 98 00 00 00    	je     8020a8 <__udivdi3+0xf8>
  802010:	89 f9                	mov    %edi,%ecx
  802012:	b8 20 00 00 00       	mov    $0x20,%eax
  802017:	29 f8                	sub    %edi,%eax
  802019:	d3 e2                	shl    %cl,%edx
  80201b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80201f:	89 c1                	mov    %eax,%ecx
  802021:	89 da                	mov    %ebx,%edx
  802023:	d3 ea                	shr    %cl,%edx
  802025:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802029:	09 d1                	or     %edx,%ecx
  80202b:	89 f2                	mov    %esi,%edx
  80202d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802031:	89 f9                	mov    %edi,%ecx
  802033:	d3 e3                	shl    %cl,%ebx
  802035:	89 c1                	mov    %eax,%ecx
  802037:	d3 ea                	shr    %cl,%edx
  802039:	89 f9                	mov    %edi,%ecx
  80203b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80203f:	d3 e6                	shl    %cl,%esi
  802041:	89 eb                	mov    %ebp,%ebx
  802043:	89 c1                	mov    %eax,%ecx
  802045:	d3 eb                	shr    %cl,%ebx
  802047:	09 de                	or     %ebx,%esi
  802049:	89 f0                	mov    %esi,%eax
  80204b:	f7 74 24 08          	divl   0x8(%esp)
  80204f:	89 d6                	mov    %edx,%esi
  802051:	89 c3                	mov    %eax,%ebx
  802053:	f7 64 24 0c          	mull   0xc(%esp)
  802057:	39 d6                	cmp    %edx,%esi
  802059:	72 0c                	jb     802067 <__udivdi3+0xb7>
  80205b:	89 f9                	mov    %edi,%ecx
  80205d:	d3 e5                	shl    %cl,%ebp
  80205f:	39 c5                	cmp    %eax,%ebp
  802061:	73 5d                	jae    8020c0 <__udivdi3+0x110>
  802063:	39 d6                	cmp    %edx,%esi
  802065:	75 59                	jne    8020c0 <__udivdi3+0x110>
  802067:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80206a:	31 ff                	xor    %edi,%edi
  80206c:	89 fa                	mov    %edi,%edx
  80206e:	83 c4 1c             	add    $0x1c,%esp
  802071:	5b                   	pop    %ebx
  802072:	5e                   	pop    %esi
  802073:	5f                   	pop    %edi
  802074:	5d                   	pop    %ebp
  802075:	c3                   	ret    
  802076:	8d 76 00             	lea    0x0(%esi),%esi
  802079:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802080:	31 ff                	xor    %edi,%edi
  802082:	31 c0                	xor    %eax,%eax
  802084:	89 fa                	mov    %edi,%edx
  802086:	83 c4 1c             	add    $0x1c,%esp
  802089:	5b                   	pop    %ebx
  80208a:	5e                   	pop    %esi
  80208b:	5f                   	pop    %edi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    
  80208e:	66 90                	xchg   %ax,%ax
  802090:	31 ff                	xor    %edi,%edi
  802092:	89 e8                	mov    %ebp,%eax
  802094:	89 f2                	mov    %esi,%edx
  802096:	f7 f3                	div    %ebx
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	39 f2                	cmp    %esi,%edx
  8020aa:	72 06                	jb     8020b2 <__udivdi3+0x102>
  8020ac:	31 c0                	xor    %eax,%eax
  8020ae:	39 eb                	cmp    %ebp,%ebx
  8020b0:	77 d2                	ja     802084 <__udivdi3+0xd4>
  8020b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b7:	eb cb                	jmp    802084 <__udivdi3+0xd4>
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	31 ff                	xor    %edi,%edi
  8020c4:	eb be                	jmp    802084 <__udivdi3+0xd4>
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__umoddi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8020db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 ed                	test   %ebp,%ebp
  8020e9:	89 f0                	mov    %esi,%eax
  8020eb:	89 da                	mov    %ebx,%edx
  8020ed:	75 19                	jne    802108 <__umoddi3+0x38>
  8020ef:	39 df                	cmp    %ebx,%edi
  8020f1:	0f 86 b1 00 00 00    	jbe    8021a8 <__umoddi3+0xd8>
  8020f7:	f7 f7                	div    %edi
  8020f9:	89 d0                	mov    %edx,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	83 c4 1c             	add    $0x1c,%esp
  802100:	5b                   	pop    %ebx
  802101:	5e                   	pop    %esi
  802102:	5f                   	pop    %edi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    
  802105:	8d 76 00             	lea    0x0(%esi),%esi
  802108:	39 dd                	cmp    %ebx,%ebp
  80210a:	77 f1                	ja     8020fd <__umoddi3+0x2d>
  80210c:	0f bd cd             	bsr    %ebp,%ecx
  80210f:	83 f1 1f             	xor    $0x1f,%ecx
  802112:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802116:	0f 84 b4 00 00 00    	je     8021d0 <__umoddi3+0x100>
  80211c:	b8 20 00 00 00       	mov    $0x20,%eax
  802121:	89 c2                	mov    %eax,%edx
  802123:	8b 44 24 04          	mov    0x4(%esp),%eax
  802127:	29 c2                	sub    %eax,%edx
  802129:	89 c1                	mov    %eax,%ecx
  80212b:	89 f8                	mov    %edi,%eax
  80212d:	d3 e5                	shl    %cl,%ebp
  80212f:	89 d1                	mov    %edx,%ecx
  802131:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802135:	d3 e8                	shr    %cl,%eax
  802137:	09 c5                	or     %eax,%ebp
  802139:	8b 44 24 04          	mov    0x4(%esp),%eax
  80213d:	89 c1                	mov    %eax,%ecx
  80213f:	d3 e7                	shl    %cl,%edi
  802141:	89 d1                	mov    %edx,%ecx
  802143:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802147:	89 df                	mov    %ebx,%edi
  802149:	d3 ef                	shr    %cl,%edi
  80214b:	89 c1                	mov    %eax,%ecx
  80214d:	89 f0                	mov    %esi,%eax
  80214f:	d3 e3                	shl    %cl,%ebx
  802151:	89 d1                	mov    %edx,%ecx
  802153:	89 fa                	mov    %edi,%edx
  802155:	d3 e8                	shr    %cl,%eax
  802157:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80215c:	09 d8                	or     %ebx,%eax
  80215e:	f7 f5                	div    %ebp
  802160:	d3 e6                	shl    %cl,%esi
  802162:	89 d1                	mov    %edx,%ecx
  802164:	f7 64 24 08          	mull   0x8(%esp)
  802168:	39 d1                	cmp    %edx,%ecx
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	89 d7                	mov    %edx,%edi
  80216e:	72 06                	jb     802176 <__umoddi3+0xa6>
  802170:	75 0e                	jne    802180 <__umoddi3+0xb0>
  802172:	39 c6                	cmp    %eax,%esi
  802174:	73 0a                	jae    802180 <__umoddi3+0xb0>
  802176:	2b 44 24 08          	sub    0x8(%esp),%eax
  80217a:	19 ea                	sbb    %ebp,%edx
  80217c:	89 d7                	mov    %edx,%edi
  80217e:	89 c3                	mov    %eax,%ebx
  802180:	89 ca                	mov    %ecx,%edx
  802182:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802187:	29 de                	sub    %ebx,%esi
  802189:	19 fa                	sbb    %edi,%edx
  80218b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80218f:	89 d0                	mov    %edx,%eax
  802191:	d3 e0                	shl    %cl,%eax
  802193:	89 d9                	mov    %ebx,%ecx
  802195:	d3 ee                	shr    %cl,%esi
  802197:	d3 ea                	shr    %cl,%edx
  802199:	09 f0                	or     %esi,%eax
  80219b:	83 c4 1c             	add    $0x1c,%esp
  80219e:	5b                   	pop    %ebx
  80219f:	5e                   	pop    %esi
  8021a0:	5f                   	pop    %edi
  8021a1:	5d                   	pop    %ebp
  8021a2:	c3                   	ret    
  8021a3:	90                   	nop
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	85 ff                	test   %edi,%edi
  8021aa:	89 f9                	mov    %edi,%ecx
  8021ac:	75 0b                	jne    8021b9 <__umoddi3+0xe9>
  8021ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f7                	div    %edi
  8021b7:	89 c1                	mov    %eax,%ecx
  8021b9:	89 d8                	mov    %ebx,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	f7 f1                	div    %ecx
  8021bf:	89 f0                	mov    %esi,%eax
  8021c1:	f7 f1                	div    %ecx
  8021c3:	e9 31 ff ff ff       	jmp    8020f9 <__umoddi3+0x29>
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	39 dd                	cmp    %ebx,%ebp
  8021d2:	72 08                	jb     8021dc <__umoddi3+0x10c>
  8021d4:	39 f7                	cmp    %esi,%edi
  8021d6:	0f 87 21 ff ff ff    	ja     8020fd <__umoddi3+0x2d>
  8021dc:	89 da                	mov    %ebx,%edx
  8021de:	89 f0                	mov    %esi,%eax
  8021e0:	29 f8                	sub    %edi,%eax
  8021e2:	19 ea                	sbb    %ebp,%edx
  8021e4:	e9 14 ff ff ff       	jmp    8020fd <__umoddi3+0x2d>
