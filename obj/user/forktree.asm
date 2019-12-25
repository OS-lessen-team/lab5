
obj/user/forktree.debug：     文件格式 elf32-i386


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
  80002c:	e8 b2 00 00 00       	call   8000e3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 70 0b 00 00       	call   800bb2 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 e0 21 80 00       	push   $0x8021e0
  80004c:	e8 87 01 00 00       	call   8001d8 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 3d 07 00 00       	call   8007c0 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7e 07                	jle    800092 <forkchild+0x23>
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	89 f0                	mov    %esi,%eax
  800097:	0f be f0             	movsbl %al,%esi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	68 f1 21 80 00       	push   $0x8021f1
  8000a1:	6a 04                	push   $0x4
  8000a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a6:	50                   	push   %eax
  8000a7:	e8 fa 06 00 00       	call   8007a6 <snprintf>
	if (fork() == 0) {
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	e8 2f 0e 00 00       	call   800ee3 <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	75 d3                	jne    80008b <forkchild+0x1c>
		forktree(nxt);
  8000b8:	83 ec 0c             	sub    $0xc,%esp
  8000bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000be:	50                   	push   %eax
  8000bf:	e8 6f ff ff ff       	call   800033 <forktree>
		exit();
  8000c4:	e8 60 00 00 00       	call   800129 <exit>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb bd                	jmp    80008b <forkchild+0x1c>

008000ce <umain>:

void
umain(int argc, char **argv)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d4:	68 f0 21 80 00       	push   $0x8021f0
  8000d9:	e8 55 ff ff ff       	call   800033 <forktree>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000ee:	e8 bf 0a 00 00       	call   800bb2 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x2d>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	e8 b4 ff ff ff       	call   8000ce <umain>

	// exit gracefully
	exit();
  80011a:	e8 0a 00 00 00       	call   800129 <exit>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012f:	e8 75 11 00 00       	call   8012a9 <close_all>
	sys_env_destroy(0);
  800134:	83 ec 0c             	sub    $0xc,%esp
  800137:	6a 00                	push   $0x0
  800139:	e8 33 0a 00 00       	call   800b71 <sys_env_destroy>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	53                   	push   %ebx
  800147:	83 ec 04             	sub    $0x4,%esp
  80014a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014d:	8b 13                	mov    (%ebx),%edx
  80014f:	8d 42 01             	lea    0x1(%edx),%eax
  800152:	89 03                	mov    %eax,(%ebx)
  800154:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800157:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800160:	74 09                	je     80016b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800162:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800169:	c9                   	leave  
  80016a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80016b:	83 ec 08             	sub    $0x8,%esp
  80016e:	68 ff 00 00 00       	push   $0xff
  800173:	8d 43 08             	lea    0x8(%ebx),%eax
  800176:	50                   	push   %eax
  800177:	e8 b8 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  80017c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	eb db                	jmp    800162 <putch+0x1f>

00800187 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800190:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800197:	00 00 00 
	b.cnt = 0;
  80019a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a4:	ff 75 0c             	pushl  0xc(%ebp)
  8001a7:	ff 75 08             	pushl  0x8(%ebp)
  8001aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	68 43 01 80 00       	push   $0x800143
  8001b6:	e8 1a 01 00 00       	call   8002d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bb:	83 c4 08             	add    $0x8,%esp
  8001be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 64 09 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  8001d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e1:	50                   	push   %eax
  8001e2:	ff 75 08             	pushl  0x8(%ebp)
  8001e5:	e8 9d ff ff ff       	call   800187 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 1c             	sub    $0x1c,%esp
  8001f5:	89 c7                	mov    %eax,%edi
  8001f7:	89 d6                	mov    %edx,%esi
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800202:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800205:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800210:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800213:	39 d3                	cmp    %edx,%ebx
  800215:	72 05                	jb     80021c <printnum+0x30>
  800217:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021a:	77 7a                	ja     800296 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021c:	83 ec 0c             	sub    $0xc,%esp
  80021f:	ff 75 18             	pushl  0x18(%ebp)
  800222:	8b 45 14             	mov    0x14(%ebp),%eax
  800225:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800228:	53                   	push   %ebx
  800229:	ff 75 10             	pushl  0x10(%ebp)
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800232:	ff 75 e0             	pushl  -0x20(%ebp)
  800235:	ff 75 dc             	pushl  -0x24(%ebp)
  800238:	ff 75 d8             	pushl  -0x28(%ebp)
  80023b:	e8 50 1d 00 00       	call   801f90 <__udivdi3>
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	52                   	push   %edx
  800244:	50                   	push   %eax
  800245:	89 f2                	mov    %esi,%edx
  800247:	89 f8                	mov    %edi,%eax
  800249:	e8 9e ff ff ff       	call   8001ec <printnum>
  80024e:	83 c4 20             	add    $0x20,%esp
  800251:	eb 13                	jmp    800266 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800253:	83 ec 08             	sub    $0x8,%esp
  800256:	56                   	push   %esi
  800257:	ff 75 18             	pushl  0x18(%ebp)
  80025a:	ff d7                	call   *%edi
  80025c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80025f:	83 eb 01             	sub    $0x1,%ebx
  800262:	85 db                	test   %ebx,%ebx
  800264:	7f ed                	jg     800253 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800266:	83 ec 08             	sub    $0x8,%esp
  800269:	56                   	push   %esi
  80026a:	83 ec 04             	sub    $0x4,%esp
  80026d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800270:	ff 75 e0             	pushl  -0x20(%ebp)
  800273:	ff 75 dc             	pushl  -0x24(%ebp)
  800276:	ff 75 d8             	pushl  -0x28(%ebp)
  800279:	e8 32 1e 00 00       	call   8020b0 <__umoddi3>
  80027e:	83 c4 14             	add    $0x14,%esp
  800281:	0f be 80 00 22 80 00 	movsbl 0x802200(%eax),%eax
  800288:	50                   	push   %eax
  800289:	ff d7                	call   *%edi
}
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    
  800296:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800299:	eb c4                	jmp    80025f <printnum+0x73>

0080029b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a5:	8b 10                	mov    (%eax),%edx
  8002a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002aa:	73 0a                	jae    8002b6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002af:	89 08                	mov    %ecx,(%eax)
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	88 02                	mov    %al,(%edx)
}
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <printfmt>:
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c1:	50                   	push   %eax
  8002c2:	ff 75 10             	pushl  0x10(%ebp)
  8002c5:	ff 75 0c             	pushl  0xc(%ebp)
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 05 00 00 00       	call   8002d5 <vprintfmt>
}
  8002d0:	83 c4 10             	add    $0x10,%esp
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <vprintfmt>:
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	83 ec 2c             	sub    $0x2c,%esp
  8002de:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e7:	e9 c1 03 00 00       	jmp    8006ad <vprintfmt+0x3d8>
		padc = ' ';
  8002ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800305:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8d 47 01             	lea    0x1(%edi),%eax
  80030d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800310:	0f b6 17             	movzbl (%edi),%edx
  800313:	8d 42 dd             	lea    -0x23(%edx),%eax
  800316:	3c 55                	cmp    $0x55,%al
  800318:	0f 87 12 04 00 00    	ja     800730 <vprintfmt+0x45b>
  80031e:	0f b6 c0             	movzbl %al,%eax
  800321:	ff 24 85 40 23 80 00 	jmp    *0x802340(,%eax,4)
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80032b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80032f:	eb d9                	jmp    80030a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800334:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800338:	eb d0                	jmp    80030a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 d2             	movzbl %dl,%edx
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800340:	b8 00 00 00 00       	mov    $0x0,%eax
  800345:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800348:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80034f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800352:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800355:	83 f9 09             	cmp    $0x9,%ecx
  800358:	77 55                	ja     8003af <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80035a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80035d:	eb e9                	jmp    800348 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80035f:	8b 45 14             	mov    0x14(%ebp),%eax
  800362:	8b 00                	mov    (%eax),%eax
  800364:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 40 04             	lea    0x4(%eax),%eax
  80036d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800373:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800377:	79 91                	jns    80030a <vprintfmt+0x35>
				width = precision, precision = -1;
  800379:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800386:	eb 82                	jmp    80030a <vprintfmt+0x35>
  800388:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038b:	85 c0                	test   %eax,%eax
  80038d:	ba 00 00 00 00       	mov    $0x0,%edx
  800392:	0f 49 d0             	cmovns %eax,%edx
  800395:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039b:	e9 6a ff ff ff       	jmp    80030a <vprintfmt+0x35>
  8003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003a3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003aa:	e9 5b ff ff ff       	jmp    80030a <vprintfmt+0x35>
  8003af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b5:	eb bc                	jmp    800373 <vprintfmt+0x9e>
			lflag++;
  8003b7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003bd:	e9 48 ff ff ff       	jmp    80030a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 78 04             	lea    0x4(%eax),%edi
  8003c8:	83 ec 08             	sub    $0x8,%esp
  8003cb:	53                   	push   %ebx
  8003cc:	ff 30                	pushl  (%eax)
  8003ce:	ff d6                	call   *%esi
			break;
  8003d0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003d3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003d6:	e9 cf 02 00 00       	jmp    8006aa <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 78 04             	lea    0x4(%eax),%edi
  8003e1:	8b 00                	mov    (%eax),%eax
  8003e3:	99                   	cltd   
  8003e4:	31 d0                	xor    %edx,%eax
  8003e6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e8:	83 f8 0f             	cmp    $0xf,%eax
  8003eb:	7f 23                	jg     800410 <vprintfmt+0x13b>
  8003ed:	8b 14 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%edx
  8003f4:	85 d2                	test   %edx,%edx
  8003f6:	74 18                	je     800410 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003f8:	52                   	push   %edx
  8003f9:	68 65 26 80 00       	push   $0x802665
  8003fe:	53                   	push   %ebx
  8003ff:	56                   	push   %esi
  800400:	e8 b3 fe ff ff       	call   8002b8 <printfmt>
  800405:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800408:	89 7d 14             	mov    %edi,0x14(%ebp)
  80040b:	e9 9a 02 00 00       	jmp    8006aa <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800410:	50                   	push   %eax
  800411:	68 18 22 80 00       	push   $0x802218
  800416:	53                   	push   %ebx
  800417:	56                   	push   %esi
  800418:	e8 9b fe ff ff       	call   8002b8 <printfmt>
  80041d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800420:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800423:	e9 82 02 00 00       	jmp    8006aa <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	83 c0 04             	add    $0x4,%eax
  80042e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800436:	85 ff                	test   %edi,%edi
  800438:	b8 11 22 80 00       	mov    $0x802211,%eax
  80043d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800440:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800444:	0f 8e bd 00 00 00    	jle    800507 <vprintfmt+0x232>
  80044a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044e:	75 0e                	jne    80045e <vprintfmt+0x189>
  800450:	89 75 08             	mov    %esi,0x8(%ebp)
  800453:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800456:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800459:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80045c:	eb 6d                	jmp    8004cb <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	ff 75 d0             	pushl  -0x30(%ebp)
  800464:	57                   	push   %edi
  800465:	e8 6e 03 00 00       	call   8007d8 <strnlen>
  80046a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046d:	29 c1                	sub    %eax,%ecx
  80046f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800472:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800475:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80047f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800481:	eb 0f                	jmp    800492 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	53                   	push   %ebx
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	83 ef 01             	sub    $0x1,%edi
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	85 ff                	test   %edi,%edi
  800494:	7f ed                	jg     800483 <vprintfmt+0x1ae>
  800496:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800499:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80049c:	85 c9                	test   %ecx,%ecx
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	0f 49 c1             	cmovns %ecx,%eax
  8004a6:	29 c1                	sub    %eax,%ecx
  8004a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b1:	89 cb                	mov    %ecx,%ebx
  8004b3:	eb 16                	jmp    8004cb <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b9:	75 31                	jne    8004ec <vprintfmt+0x217>
					putch(ch, putdat);
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	ff 75 0c             	pushl  0xc(%ebp)
  8004c1:	50                   	push   %eax
  8004c2:	ff 55 08             	call   *0x8(%ebp)
  8004c5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c8:	83 eb 01             	sub    $0x1,%ebx
  8004cb:	83 c7 01             	add    $0x1,%edi
  8004ce:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004d2:	0f be c2             	movsbl %dl,%eax
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 59                	je     800532 <vprintfmt+0x25d>
  8004d9:	85 f6                	test   %esi,%esi
  8004db:	78 d8                	js     8004b5 <vprintfmt+0x1e0>
  8004dd:	83 ee 01             	sub    $0x1,%esi
  8004e0:	79 d3                	jns    8004b5 <vprintfmt+0x1e0>
  8004e2:	89 df                	mov    %ebx,%edi
  8004e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ea:	eb 37                	jmp    800523 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ec:	0f be d2             	movsbl %dl,%edx
  8004ef:	83 ea 20             	sub    $0x20,%edx
  8004f2:	83 fa 5e             	cmp    $0x5e,%edx
  8004f5:	76 c4                	jbe    8004bb <vprintfmt+0x1e6>
					putch('?', putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	6a 3f                	push   $0x3f
  8004ff:	ff 55 08             	call   *0x8(%ebp)
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	eb c1                	jmp    8004c8 <vprintfmt+0x1f3>
  800507:	89 75 08             	mov    %esi,0x8(%ebp)
  80050a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800510:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800513:	eb b6                	jmp    8004cb <vprintfmt+0x1f6>
				putch(' ', putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	53                   	push   %ebx
  800519:	6a 20                	push   $0x20
  80051b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80051d:	83 ef 01             	sub    $0x1,%edi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	85 ff                	test   %edi,%edi
  800525:	7f ee                	jg     800515 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800527:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80052a:	89 45 14             	mov    %eax,0x14(%ebp)
  80052d:	e9 78 01 00 00       	jmp    8006aa <vprintfmt+0x3d5>
  800532:	89 df                	mov    %ebx,%edi
  800534:	8b 75 08             	mov    0x8(%ebp),%esi
  800537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053a:	eb e7                	jmp    800523 <vprintfmt+0x24e>
	if (lflag >= 2)
  80053c:	83 f9 01             	cmp    $0x1,%ecx
  80053f:	7e 3f                	jle    800580 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8b 50 04             	mov    0x4(%eax),%edx
  800547:	8b 00                	mov    (%eax),%eax
  800549:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 40 08             	lea    0x8(%eax),%eax
  800555:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800558:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055c:	79 5c                	jns    8005ba <vprintfmt+0x2e5>
				putch('-', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	6a 2d                	push   $0x2d
  800564:	ff d6                	call   *%esi
				num = -(long long) num;
  800566:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800569:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80056c:	f7 da                	neg    %edx
  80056e:	83 d1 00             	adc    $0x0,%ecx
  800571:	f7 d9                	neg    %ecx
  800573:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800576:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057b:	e9 10 01 00 00       	jmp    800690 <vprintfmt+0x3bb>
	else if (lflag)
  800580:	85 c9                	test   %ecx,%ecx
  800582:	75 1b                	jne    80059f <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 c1                	mov    %eax,%ecx
  80058e:	c1 f9 1f             	sar    $0x1f,%ecx
  800591:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
  80059d:	eb b9                	jmp    800558 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	89 c1                	mov    %eax,%ecx
  8005a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 40 04             	lea    0x4(%eax),%eax
  8005b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b8:	eb 9e                	jmp    800558 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c5:	e9 c6 00 00 00       	jmp    800690 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005ca:	83 f9 01             	cmp    $0x1,%ecx
  8005cd:	7e 18                	jle    8005e7 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 10                	mov    (%eax),%edx
  8005d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d7:	8d 40 08             	lea    0x8(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e2:	e9 a9 00 00 00       	jmp    800690 <vprintfmt+0x3bb>
	else if (lflag)
  8005e7:	85 c9                	test   %ecx,%ecx
  8005e9:	75 1a                	jne    800605 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 10                	mov    (%eax),%edx
  8005f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800600:	e9 8b 00 00 00       	jmp    800690 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8b 10                	mov    (%eax),%edx
  80060a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060f:	8d 40 04             	lea    0x4(%eax),%eax
  800612:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800615:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061a:	eb 74                	jmp    800690 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80061c:	83 f9 01             	cmp    $0x1,%ecx
  80061f:	7e 15                	jle    800636 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 10                	mov    (%eax),%edx
  800626:	8b 48 04             	mov    0x4(%eax),%ecx
  800629:	8d 40 08             	lea    0x8(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80062f:	b8 08 00 00 00       	mov    $0x8,%eax
  800634:	eb 5a                	jmp    800690 <vprintfmt+0x3bb>
	else if (lflag)
  800636:	85 c9                	test   %ecx,%ecx
  800638:	75 17                	jne    800651 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 10                	mov    (%eax),%edx
  80063f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800644:	8d 40 04             	lea    0x4(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80064a:	b8 08 00 00 00       	mov    $0x8,%eax
  80064f:	eb 3f                	jmp    800690 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065b:	8d 40 04             	lea    0x4(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800661:	b8 08 00 00 00       	mov    $0x8,%eax
  800666:	eb 28                	jmp    800690 <vprintfmt+0x3bb>
			putch('0', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 30                	push   $0x30
  80066e:	ff d6                	call   *%esi
			putch('x', putdat);
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	6a 78                	push   $0x78
  800676:	ff d6                	call   *%esi
			num = (unsigned long long)
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800682:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800685:	8d 40 04             	lea    0x4(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800690:	83 ec 0c             	sub    $0xc,%esp
  800693:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800697:	57                   	push   %edi
  800698:	ff 75 e0             	pushl  -0x20(%ebp)
  80069b:	50                   	push   %eax
  80069c:	51                   	push   %ecx
  80069d:	52                   	push   %edx
  80069e:	89 da                	mov    %ebx,%edx
  8006a0:	89 f0                	mov    %esi,%eax
  8006a2:	e8 45 fb ff ff       	call   8001ec <printnum>
			break;
  8006a7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ad:	83 c7 01             	add    $0x1,%edi
  8006b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006b4:	83 f8 25             	cmp    $0x25,%eax
  8006b7:	0f 84 2f fc ff ff    	je     8002ec <vprintfmt+0x17>
			if (ch == '\0')
  8006bd:	85 c0                	test   %eax,%eax
  8006bf:	0f 84 8b 00 00 00    	je     800750 <vprintfmt+0x47b>
			putch(ch, putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	50                   	push   %eax
  8006ca:	ff d6                	call   *%esi
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	eb dc                	jmp    8006ad <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006d1:	83 f9 01             	cmp    $0x1,%ecx
  8006d4:	7e 15                	jle    8006eb <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	8b 48 04             	mov    0x4(%eax),%ecx
  8006de:	8d 40 08             	lea    0x8(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e9:	eb a5                	jmp    800690 <vprintfmt+0x3bb>
	else if (lflag)
  8006eb:	85 c9                	test   %ecx,%ecx
  8006ed:	75 17                	jne    800706 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f9:	8d 40 04             	lea    0x4(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ff:	b8 10 00 00 00       	mov    $0x10,%eax
  800704:	eb 8a                	jmp    800690 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800710:	8d 40 04             	lea    0x4(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800716:	b8 10 00 00 00       	mov    $0x10,%eax
  80071b:	e9 70 ff ff ff       	jmp    800690 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	53                   	push   %ebx
  800724:	6a 25                	push   $0x25
  800726:	ff d6                	call   *%esi
			break;
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	e9 7a ff ff ff       	jmp    8006aa <vprintfmt+0x3d5>
			putch('%', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	53                   	push   %ebx
  800734:	6a 25                	push   $0x25
  800736:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	89 f8                	mov    %edi,%eax
  80073d:	eb 03                	jmp    800742 <vprintfmt+0x46d>
  80073f:	83 e8 01             	sub    $0x1,%eax
  800742:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800746:	75 f7                	jne    80073f <vprintfmt+0x46a>
  800748:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074b:	e9 5a ff ff ff       	jmp    8006aa <vprintfmt+0x3d5>
}
  800750:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800753:	5b                   	pop    %ebx
  800754:	5e                   	pop    %esi
  800755:	5f                   	pop    %edi
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 18             	sub    $0x18,%esp
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800764:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800767:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800775:	85 c0                	test   %eax,%eax
  800777:	74 26                	je     80079f <vsnprintf+0x47>
  800779:	85 d2                	test   %edx,%edx
  80077b:	7e 22                	jle    80079f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077d:	ff 75 14             	pushl  0x14(%ebp)
  800780:	ff 75 10             	pushl  0x10(%ebp)
  800783:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800786:	50                   	push   %eax
  800787:	68 9b 02 80 00       	push   $0x80029b
  80078c:	e8 44 fb ff ff       	call   8002d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800791:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800794:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800797:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079a:	83 c4 10             	add    $0x10,%esp
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    
		return -E_INVAL;
  80079f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a4:	eb f7                	jmp    80079d <vsnprintf+0x45>

008007a6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ac:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007af:	50                   	push   %eax
  8007b0:	ff 75 10             	pushl  0x10(%ebp)
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	ff 75 08             	pushl  0x8(%ebp)
  8007b9:	e8 9a ff ff ff       	call   800758 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	eb 03                	jmp    8007d0 <strlen+0x10>
		n++;
  8007cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d4:	75 f7                	jne    8007cd <strlen+0xd>
	return n;
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e6:	eb 03                	jmp    8007eb <strnlen+0x13>
		n++;
  8007e8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007eb:	39 d0                	cmp    %edx,%eax
  8007ed:	74 06                	je     8007f5 <strnlen+0x1d>
  8007ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f3:	75 f3                	jne    8007e8 <strnlen+0x10>
	return n;
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800801:	89 c2                	mov    %eax,%edx
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800810:	84 db                	test   %bl,%bl
  800812:	75 ef                	jne    800803 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800814:	5b                   	pop    %ebx
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081e:	53                   	push   %ebx
  80081f:	e8 9c ff ff ff       	call   8007c0 <strlen>
  800824:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800827:	ff 75 0c             	pushl  0xc(%ebp)
  80082a:	01 d8                	add    %ebx,%eax
  80082c:	50                   	push   %eax
  80082d:	e8 c5 ff ff ff       	call   8007f7 <strcpy>
	return dst;
}
  800832:	89 d8                	mov    %ebx,%eax
  800834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	8b 75 08             	mov    0x8(%ebp),%esi
  800841:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800844:	89 f3                	mov    %esi,%ebx
  800846:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800849:	89 f2                	mov    %esi,%edx
  80084b:	eb 0f                	jmp    80085c <strncpy+0x23>
		*dst++ = *src;
  80084d:	83 c2 01             	add    $0x1,%edx
  800850:	0f b6 01             	movzbl (%ecx),%eax
  800853:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800856:	80 39 01             	cmpb   $0x1,(%ecx)
  800859:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80085c:	39 da                	cmp    %ebx,%edx
  80085e:	75 ed                	jne    80084d <strncpy+0x14>
	}
	return ret;
}
  800860:	89 f0                	mov    %esi,%eax
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 75 08             	mov    0x8(%ebp),%esi
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800874:	89 f0                	mov    %esi,%eax
  800876:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	85 c9                	test   %ecx,%ecx
  80087c:	75 0b                	jne    800889 <strlcpy+0x23>
  80087e:	eb 17                	jmp    800897 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800889:	39 d8                	cmp    %ebx,%eax
  80088b:	74 07                	je     800894 <strlcpy+0x2e>
  80088d:	0f b6 0a             	movzbl (%edx),%ecx
  800890:	84 c9                	test   %cl,%cl
  800892:	75 ec                	jne    800880 <strlcpy+0x1a>
		*dst = '\0';
  800894:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800897:	29 f0                	sub    %esi,%eax
}
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a6:	eb 06                	jmp    8008ae <strcmp+0x11>
		p++, q++;
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ae:	0f b6 01             	movzbl (%ecx),%eax
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 04                	je     8008b9 <strcmp+0x1c>
  8008b5:	3a 02                	cmp    (%edx),%al
  8008b7:	74 ef                	je     8008a8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 c0             	movzbl %al,%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cd:	89 c3                	mov    %eax,%ebx
  8008cf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d2:	eb 06                	jmp    8008da <strncmp+0x17>
		n--, p++, q++;
  8008d4:	83 c0 01             	add    $0x1,%eax
  8008d7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008da:	39 d8                	cmp    %ebx,%eax
  8008dc:	74 16                	je     8008f4 <strncmp+0x31>
  8008de:	0f b6 08             	movzbl (%eax),%ecx
  8008e1:	84 c9                	test   %cl,%cl
  8008e3:	74 04                	je     8008e9 <strncmp+0x26>
  8008e5:	3a 0a                	cmp    (%edx),%cl
  8008e7:	74 eb                	je     8008d4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e9:	0f b6 00             	movzbl (%eax),%eax
  8008ec:	0f b6 12             	movzbl (%edx),%edx
  8008ef:	29 d0                	sub    %edx,%eax
}
  8008f1:	5b                   	pop    %ebx
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    
		return 0;
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f9:	eb f6                	jmp    8008f1 <strncmp+0x2e>

008008fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800905:	0f b6 10             	movzbl (%eax),%edx
  800908:	84 d2                	test   %dl,%dl
  80090a:	74 09                	je     800915 <strchr+0x1a>
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	74 0a                	je     80091a <strchr+0x1f>
	for (; *s; s++)
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	eb f0                	jmp    800905 <strchr+0xa>
			return (char *) s;
	return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800926:	eb 03                	jmp    80092b <strfind+0xf>
  800928:	83 c0 01             	add    $0x1,%eax
  80092b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092e:	38 ca                	cmp    %cl,%dl
  800930:	74 04                	je     800936 <strfind+0x1a>
  800932:	84 d2                	test   %dl,%dl
  800934:	75 f2                	jne    800928 <strfind+0xc>
			break;
	return (char *) s;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 13                	je     80095b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800948:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094e:	75 05                	jne    800955 <memset+0x1d>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	74 0d                	je     800962 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
  800958:	fc                   	cld    
  800959:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095b:	89 f8                	mov    %edi,%eax
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5f                   	pop    %edi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    
		c &= 0xFF;
  800962:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800966:	89 d3                	mov    %edx,%ebx
  800968:	c1 e3 08             	shl    $0x8,%ebx
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 18             	shl    $0x18,%eax
  800970:	89 d6                	mov    %edx,%esi
  800972:	c1 e6 10             	shl    $0x10,%esi
  800975:	09 f0                	or     %esi,%eax
  800977:	09 c2                	or     %eax,%edx
  800979:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80097b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80097e:	89 d0                	mov    %edx,%eax
  800980:	fc                   	cld    
  800981:	f3 ab                	rep stos %eax,%es:(%edi)
  800983:	eb d6                	jmp    80095b <memset+0x23>

00800985 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800990:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800993:	39 c6                	cmp    %eax,%esi
  800995:	73 35                	jae    8009cc <memmove+0x47>
  800997:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099a:	39 c2                	cmp    %eax,%edx
  80099c:	76 2e                	jbe    8009cc <memmove+0x47>
		s += n;
		d += n;
  80099e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	09 fe                	or     %edi,%esi
  8009a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ab:	74 0c                	je     8009b9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ad:	83 ef 01             	sub    $0x1,%edi
  8009b0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b3:	fd                   	std    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b6:	fc                   	cld    
  8009b7:	eb 21                	jmp    8009da <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 ef                	jne    8009ad <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009be:	83 ef 04             	sub    $0x4,%edi
  8009c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c7:	fd                   	std    
  8009c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ca:	eb ea                	jmp    8009b6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cc:	89 f2                	mov    %esi,%edx
  8009ce:	09 c2                	or     %eax,%edx
  8009d0:	f6 c2 03             	test   $0x3,%dl
  8009d3:	74 09                	je     8009de <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009da:	5e                   	pop    %esi
  8009db:	5f                   	pop    %edi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009de:	f6 c1 03             	test   $0x3,%cl
  8009e1:	75 f2                	jne    8009d5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009eb:	eb ed                	jmp    8009da <memmove+0x55>

008009ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f0:	ff 75 10             	pushl  0x10(%ebp)
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	ff 75 08             	pushl  0x8(%ebp)
  8009f9:	e8 87 ff ff ff       	call   800985 <memmove>
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0b:	89 c6                	mov    %eax,%esi
  800a0d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a10:	39 f0                	cmp    %esi,%eax
  800a12:	74 1c                	je     800a30 <memcmp+0x30>
		if (*s1 != *s2)
  800a14:	0f b6 08             	movzbl (%eax),%ecx
  800a17:	0f b6 1a             	movzbl (%edx),%ebx
  800a1a:	38 d9                	cmp    %bl,%cl
  800a1c:	75 08                	jne    800a26 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	83 c2 01             	add    $0x1,%edx
  800a24:	eb ea                	jmp    800a10 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a26:	0f b6 c1             	movzbl %cl,%eax
  800a29:	0f b6 db             	movzbl %bl,%ebx
  800a2c:	29 d8                	sub    %ebx,%eax
  800a2e:	eb 05                	jmp    800a35 <memcmp+0x35>
	}

	return 0;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a42:	89 c2                	mov    %eax,%edx
  800a44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a47:	39 d0                	cmp    %edx,%eax
  800a49:	73 09                	jae    800a54 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4b:	38 08                	cmp    %cl,(%eax)
  800a4d:	74 05                	je     800a54 <memfind+0x1b>
	for (; s < ends; s++)
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	eb f3                	jmp    800a47 <memfind+0xe>
			break;
	return (void *) s;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a62:	eb 03                	jmp    800a67 <strtol+0x11>
		s++;
  800a64:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a67:	0f b6 01             	movzbl (%ecx),%eax
  800a6a:	3c 20                	cmp    $0x20,%al
  800a6c:	74 f6                	je     800a64 <strtol+0xe>
  800a6e:	3c 09                	cmp    $0x9,%al
  800a70:	74 f2                	je     800a64 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a72:	3c 2b                	cmp    $0x2b,%al
  800a74:	74 2e                	je     800aa4 <strtol+0x4e>
	int neg = 0;
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a7b:	3c 2d                	cmp    $0x2d,%al
  800a7d:	74 2f                	je     800aae <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a85:	75 05                	jne    800a8c <strtol+0x36>
  800a87:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8a:	74 2c                	je     800ab8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	75 0a                	jne    800a9a <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a90:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a95:	80 39 30             	cmpb   $0x30,(%ecx)
  800a98:	74 28                	je     800ac2 <strtol+0x6c>
		base = 10;
  800a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa2:	eb 50                	jmp    800af4 <strtol+0x9e>
		s++;
  800aa4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa7:	bf 00 00 00 00       	mov    $0x0,%edi
  800aac:	eb d1                	jmp    800a7f <strtol+0x29>
		s++, neg = 1;
  800aae:	83 c1 01             	add    $0x1,%ecx
  800ab1:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab6:	eb c7                	jmp    800a7f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abc:	74 0e                	je     800acc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800abe:	85 db                	test   %ebx,%ebx
  800ac0:	75 d8                	jne    800a9a <strtol+0x44>
		s++, base = 8;
  800ac2:	83 c1 01             	add    $0x1,%ecx
  800ac5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aca:	eb ce                	jmp    800a9a <strtol+0x44>
		s += 2, base = 16;
  800acc:	83 c1 02             	add    $0x2,%ecx
  800acf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad4:	eb c4                	jmp    800a9a <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ad6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad9:	89 f3                	mov    %esi,%ebx
  800adb:	80 fb 19             	cmp    $0x19,%bl
  800ade:	77 29                	ja     800b09 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ae0:	0f be d2             	movsbl %dl,%edx
  800ae3:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae9:	7d 30                	jge    800b1b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800af4:	0f b6 11             	movzbl (%ecx),%edx
  800af7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	80 fb 09             	cmp    $0x9,%bl
  800aff:	77 d5                	ja     800ad6 <strtol+0x80>
			dig = *s - '0';
  800b01:	0f be d2             	movsbl %dl,%edx
  800b04:	83 ea 30             	sub    $0x30,%edx
  800b07:	eb dd                	jmp    800ae6 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b09:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b0c:	89 f3                	mov    %esi,%ebx
  800b0e:	80 fb 19             	cmp    $0x19,%bl
  800b11:	77 08                	ja     800b1b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b13:	0f be d2             	movsbl %dl,%edx
  800b16:	83 ea 37             	sub    $0x37,%edx
  800b19:	eb cb                	jmp    800ae6 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1f:	74 05                	je     800b26 <strtol+0xd0>
		*endptr = (char *) s;
  800b21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b24:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b26:	89 c2                	mov    %eax,%edx
  800b28:	f7 da                	neg    %edx
  800b2a:	85 ff                	test   %edi,%edi
  800b2c:	0f 45 c2             	cmovne %edx,%eax
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	b8 03 00 00 00       	mov    $0x3,%eax
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7f 08                	jg     800b9b <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 03                	push   $0x3
  800ba1:	68 ff 24 80 00       	push   $0x8024ff
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 1c 25 80 00       	push   $0x80251c
  800bad:	e8 cf 11 00 00       	call   801d81 <_panic>

00800bb2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc2:	89 d1                	mov    %edx,%ecx
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	89 d7                	mov    %edx,%edi
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_yield>:

void
sys_yield(void)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be1:	89 d1                	mov    %edx,%ecx
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	89 d7                	mov    %edx,%edi
  800be7:	89 d6                	mov    %edx,%esi
  800be9:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf9:	be 00 00 00 00       	mov    $0x0,%esi
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	b8 04 00 00 00       	mov    $0x4,%eax
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	89 f7                	mov    %esi,%edi
  800c0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800c20:	6a 04                	push   $0x4
  800c22:	68 ff 24 80 00       	push   $0x8024ff
  800c27:	6a 23                	push   $0x23
  800c29:	68 1c 25 80 00       	push   $0x80251c
  800c2e:	e8 4e 11 00 00       	call   801d81 <_panic>

00800c33 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c42:	b8 05 00 00 00       	mov    $0x5,%eax
  800c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7f 08                	jg     800c5e <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800c62:	6a 05                	push   $0x5
  800c64:	68 ff 24 80 00       	push   $0x8024ff
  800c69:	6a 23                	push   $0x23
  800c6b:	68 1c 25 80 00       	push   $0x80251c
  800c70:	e8 0c 11 00 00       	call   801d81 <_panic>

00800c75 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c89:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800ca4:	6a 06                	push   $0x6
  800ca6:	68 ff 24 80 00       	push   $0x8024ff
  800cab:	6a 23                	push   $0x23
  800cad:	68 1c 25 80 00       	push   $0x80251c
  800cb2:	e8 ca 10 00 00       	call   801d81 <_panic>

00800cb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ccb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7f 08                	jg     800ce2 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  800ce6:	6a 08                	push   $0x8
  800ce8:	68 ff 24 80 00       	push   $0x8024ff
  800ced:	6a 23                	push   $0x23
  800cef:	68 1c 25 80 00       	push   $0x80251c
  800cf4:	e8 88 10 00 00       	call   801d81 <_panic>

00800cf9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d0d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7f 08                	jg     800d24 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800d28:	6a 09                	push   $0x9
  800d2a:	68 ff 24 80 00       	push   $0x8024ff
  800d2f:	6a 23                	push   $0x23
  800d31:	68 1c 25 80 00       	push   $0x80251c
  800d36:	e8 46 10 00 00       	call   801d81 <_panic>

00800d3b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d54:	89 df                	mov    %ebx,%edi
  800d56:	89 de                	mov    %ebx,%esi
  800d58:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7f 08                	jg     800d66 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0a                	push   $0xa
  800d6c:	68 ff 24 80 00       	push   $0x8024ff
  800d71:	6a 23                	push   $0x23
  800d73:	68 1c 25 80 00       	push   $0x80251c
  800d78:	e8 04 10 00 00       	call   801d81 <_panic>

00800d7d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8e:	be 00 00 00 00       	mov    $0x0,%esi
  800d93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d99:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db6:	89 cb                	mov    %ecx,%ebx
  800db8:	89 cf                	mov    %ecx,%edi
  800dba:	89 ce                	mov    %ecx,%esi
  800dbc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7f 08                	jg     800dca <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	50                   	push   %eax
  800dce:	6a 0d                	push   $0xd
  800dd0:	68 ff 24 80 00       	push   $0x8024ff
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 1c 25 80 00       	push   $0x80251c
  800ddc:	e8 a0 0f 00 00       	call   801d81 <_panic>

00800de1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	53                   	push   %ebx
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800deb:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ded:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800df1:	0f 84 9c 00 00 00    	je     800e93 <pgfault+0xb2>
  800df7:	89 c2                	mov    %eax,%edx
  800df9:	c1 ea 16             	shr    $0x16,%edx
  800dfc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e03:	f6 c2 01             	test   $0x1,%dl
  800e06:	0f 84 87 00 00 00    	je     800e93 <pgfault+0xb2>
  800e0c:	89 c2                	mov    %eax,%edx
  800e0e:	c1 ea 0c             	shr    $0xc,%edx
  800e11:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e18:	f6 c1 01             	test   $0x1,%cl
  800e1b:	74 76                	je     800e93 <pgfault+0xb2>
  800e1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e24:	f6 c6 08             	test   $0x8,%dh
  800e27:	74 6a                	je     800e93 <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  800e29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e2e:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800e30:	83 ec 04             	sub    $0x4,%esp
  800e33:	6a 07                	push   $0x7
  800e35:	68 00 f0 7f 00       	push   $0x7ff000
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 af fd ff ff       	call   800bf0 <sys_page_alloc>
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	85 c0                	test   %eax,%eax
  800e46:	78 5f                	js     800ea7 <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	68 00 10 00 00       	push   $0x1000
  800e50:	53                   	push   %ebx
  800e51:	68 00 f0 7f 00       	push   $0x7ff000
  800e56:	e8 92 fb ff ff       	call   8009ed <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e5b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e62:	53                   	push   %ebx
  800e63:	6a 00                	push   $0x0
  800e65:	68 00 f0 7f 00       	push   $0x7ff000
  800e6a:	6a 00                	push   $0x0
  800e6c:	e8 c2 fd ff ff       	call   800c33 <sys_page_map>
  800e71:	83 c4 20             	add    $0x20,%esp
  800e74:	85 c0                	test   %eax,%eax
  800e76:	78 43                	js     800ebb <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	68 00 f0 7f 00       	push   $0x7ff000
  800e80:	6a 00                	push   $0x0
  800e82:	e8 ee fd ff ff       	call   800c75 <sys_page_unmap>
  800e87:	83 c4 10             	add    $0x10,%esp
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	78 41                	js     800ecf <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  800e8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    
		panic("not copy-on-write");
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	68 2a 25 80 00       	push   $0x80252a
  800e9b:	6a 25                	push   $0x25
  800e9d:	68 3c 25 80 00       	push   $0x80253c
  800ea2:	e8 da 0e 00 00       	call   801d81 <_panic>
		panic("sys_page_alloc");
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	68 47 25 80 00       	push   $0x802547
  800eaf:	6a 28                	push   $0x28
  800eb1:	68 3c 25 80 00       	push   $0x80253c
  800eb6:	e8 c6 0e 00 00       	call   801d81 <_panic>
		panic("sys_page_map");
  800ebb:	83 ec 04             	sub    $0x4,%esp
  800ebe:	68 56 25 80 00       	push   $0x802556
  800ec3:	6a 2b                	push   $0x2b
  800ec5:	68 3c 25 80 00       	push   $0x80253c
  800eca:	e8 b2 0e 00 00       	call   801d81 <_panic>
		panic("sys_page_unmap");
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	68 63 25 80 00       	push   $0x802563
  800ed7:	6a 2d                	push   $0x2d
  800ed9:	68 3c 25 80 00       	push   $0x80253c
  800ede:	e8 9e 0e 00 00       	call   801d81 <_panic>

00800ee3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	57                   	push   %edi
  800ee7:	56                   	push   %esi
  800ee8:	53                   	push   %ebx
  800ee9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800eec:	68 e1 0d 80 00       	push   $0x800de1
  800ef1:	e8 d1 0e 00 00       	call   801dc7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef6:	b8 07 00 00 00       	mov    $0x7,%eax
  800efb:	cd 30                	int    $0x30
  800efd:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	74 12                	je     800f19 <fork+0x36>
  800f07:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  800f09:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f0d:	78 26                	js     800f35 <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f14:	e9 94 00 00 00       	jmp    800fad <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f19:	e8 94 fc ff ff       	call   800bb2 <sys_getenvid>
  800f1e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f23:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f26:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f2b:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f30:	e9 51 01 00 00       	jmp    801086 <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  800f35:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f38:	68 72 25 80 00       	push   $0x802572
  800f3d:	6a 6e                	push   $0x6e
  800f3f:	68 3c 25 80 00       	push   $0x80253c
  800f44:	e8 38 0e 00 00       	call   801d81 <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800f49:	83 ec 0c             	sub    $0xc,%esp
  800f4c:	68 07 0e 00 00       	push   $0xe07
  800f51:	56                   	push   %esi
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	6a 00                	push   $0x0
  800f56:	e8 d8 fc ff ff       	call   800c33 <sys_page_map>
  800f5b:	83 c4 20             	add    $0x20,%esp
  800f5e:	eb 3b                	jmp    800f9b <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f60:	83 ec 0c             	sub    $0xc,%esp
  800f63:	68 05 08 00 00       	push   $0x805
  800f68:	56                   	push   %esi
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 c1 fc ff ff       	call   800c33 <sys_page_map>
  800f72:	83 c4 20             	add    $0x20,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	0f 88 a9 00 00 00    	js     801026 <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f7d:	83 ec 0c             	sub    $0xc,%esp
  800f80:	68 05 08 00 00       	push   $0x805
  800f85:	56                   	push   %esi
  800f86:	6a 00                	push   $0x0
  800f88:	56                   	push   %esi
  800f89:	6a 00                	push   $0x0
  800f8b:	e8 a3 fc ff ff       	call   800c33 <sys_page_map>
  800f90:	83 c4 20             	add    $0x20,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	0f 88 9d 00 00 00    	js     801038 <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f9b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fa1:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fa7:	0f 84 9d 00 00 00    	je     80104a <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800fad:	89 d8                	mov    %ebx,%eax
  800faf:	c1 e8 16             	shr    $0x16,%eax
  800fb2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb9:	a8 01                	test   $0x1,%al
  800fbb:	74 de                	je     800f9b <fork+0xb8>
  800fbd:	89 d8                	mov    %ebx,%eax
  800fbf:	c1 e8 0c             	shr    $0xc,%eax
  800fc2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc9:	f6 c2 01             	test   $0x1,%dl
  800fcc:	74 cd                	je     800f9b <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800fce:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd5:	f6 c2 04             	test   $0x4,%dl
  800fd8:	74 c1                	je     800f9b <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  800fda:	89 c6                	mov    %eax,%esi
  800fdc:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  800fdf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe6:	f6 c6 04             	test   $0x4,%dh
  800fe9:	0f 85 5a ff ff ff    	jne    800f49 <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800fef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff6:	f6 c2 02             	test   $0x2,%dl
  800ff9:	0f 85 61 ff ff ff    	jne    800f60 <fork+0x7d>
  800fff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801006:	f6 c4 08             	test   $0x8,%ah
  801009:	0f 85 51 ff ff ff    	jne    800f60 <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	6a 05                	push   $0x5
  801014:	56                   	push   %esi
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	6a 00                	push   $0x0
  801019:	e8 15 fc ff ff       	call   800c33 <sys_page_map>
  80101e:	83 c4 20             	add    $0x20,%esp
  801021:	e9 75 ff ff ff       	jmp    800f9b <fork+0xb8>
            		panic("sys_page_map：%e", r);
  801026:	50                   	push   %eax
  801027:	68 82 25 80 00       	push   $0x802582
  80102c:	6a 47                	push   $0x47
  80102e:	68 3c 25 80 00       	push   $0x80253c
  801033:	e8 49 0d 00 00       	call   801d81 <_panic>
            		panic("sys_page_map：%e", r);
  801038:	50                   	push   %eax
  801039:	68 82 25 80 00       	push   $0x802582
  80103e:	6a 49                	push   $0x49
  801040:	68 3c 25 80 00       	push   $0x80253c
  801045:	e8 37 0d 00 00       	call   801d81 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	6a 07                	push   $0x7
  80104f:	68 00 f0 bf ee       	push   $0xeebff000
  801054:	ff 75 e4             	pushl  -0x1c(%ebp)
  801057:	e8 94 fb ff ff       	call   800bf0 <sys_page_alloc>
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 2e                	js     801091 <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	68 36 1e 80 00       	push   $0x801e36
  80106b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80106e:	57                   	push   %edi
  80106f:	e8 c7 fc ff ff       	call   800d3b <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801074:	83 c4 08             	add    $0x8,%esp
  801077:	6a 02                	push   $0x2
  801079:	57                   	push   %edi
  80107a:	e8 38 fc ff ff       	call   800cb7 <sys_env_set_status>
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	78 1f                	js     8010a5 <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  801086:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801089:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5f                   	pop    %edi
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    
		panic("1");
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	68 94 25 80 00       	push   $0x802594
  801099:	6a 77                	push   $0x77
  80109b:	68 3c 25 80 00       	push   $0x80253c
  8010a0:	e8 dc 0c 00 00       	call   801d81 <_panic>
		panic("sys_env_set_status");
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	68 96 25 80 00       	push   $0x802596
  8010ad:	6a 7c                	push   $0x7c
  8010af:	68 3c 25 80 00       	push   $0x80253c
  8010b4:	e8 c8 0c 00 00       	call   801d81 <_panic>

008010b9 <sfork>:

// Challenge!
int
sfork(void)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010bf:	68 a9 25 80 00       	push   $0x8025a9
  8010c4:	68 86 00 00 00       	push   $0x86
  8010c9:	68 3c 25 80 00       	push   $0x80253c
  8010ce:	e8 ae 0c 00 00       	call   801d81 <_panic>

008010d3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	05 00 00 00 30       	add    $0x30000000,%eax
  8010de:	c1 e8 0c             	shr    $0xc,%eax
}
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010f3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    

008010fa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801100:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801105:	89 c2                	mov    %eax,%edx
  801107:	c1 ea 16             	shr    $0x16,%edx
  80110a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801111:	f6 c2 01             	test   $0x1,%dl
  801114:	74 2a                	je     801140 <fd_alloc+0x46>
  801116:	89 c2                	mov    %eax,%edx
  801118:	c1 ea 0c             	shr    $0xc,%edx
  80111b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801122:	f6 c2 01             	test   $0x1,%dl
  801125:	74 19                	je     801140 <fd_alloc+0x46>
  801127:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80112c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801131:	75 d2                	jne    801105 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801133:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801139:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80113e:	eb 07                	jmp    801147 <fd_alloc+0x4d>
			*fd_store = fd;
  801140:	89 01                	mov    %eax,(%ecx)
			return 0;
  801142:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80114f:	83 f8 1f             	cmp    $0x1f,%eax
  801152:	77 36                	ja     80118a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801154:	c1 e0 0c             	shl    $0xc,%eax
  801157:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80115c:	89 c2                	mov    %eax,%edx
  80115e:	c1 ea 16             	shr    $0x16,%edx
  801161:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801168:	f6 c2 01             	test   $0x1,%dl
  80116b:	74 24                	je     801191 <fd_lookup+0x48>
  80116d:	89 c2                	mov    %eax,%edx
  80116f:	c1 ea 0c             	shr    $0xc,%edx
  801172:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801179:	f6 c2 01             	test   $0x1,%dl
  80117c:	74 1a                	je     801198 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80117e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801181:	89 02                	mov    %eax,(%edx)
	return 0;
  801183:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    
		return -E_INVAL;
  80118a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118f:	eb f7                	jmp    801188 <fd_lookup+0x3f>
		return -E_INVAL;
  801191:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801196:	eb f0                	jmp    801188 <fd_lookup+0x3f>
  801198:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80119d:	eb e9                	jmp    801188 <fd_lookup+0x3f>

0080119f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a8:	ba 3c 26 80 00       	mov    $0x80263c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ad:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8011b2:	39 08                	cmp    %ecx,(%eax)
  8011b4:	74 33                	je     8011e9 <dev_lookup+0x4a>
  8011b6:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8011b9:	8b 02                	mov    (%edx),%eax
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	75 f3                	jne    8011b2 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c4:	8b 40 48             	mov    0x48(%eax),%eax
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	51                   	push   %ecx
  8011cb:	50                   	push   %eax
  8011cc:	68 c0 25 80 00       	push   $0x8025c0
  8011d1:	e8 02 f0 ff ff       	call   8001d8 <cprintf>
	*dev = 0;
  8011d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    
			*dev = devtab[i];
  8011e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ec:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f3:	eb f2                	jmp    8011e7 <dev_lookup+0x48>

008011f5 <fd_close>:
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	57                   	push   %edi
  8011f9:	56                   	push   %esi
  8011fa:	53                   	push   %ebx
  8011fb:	83 ec 1c             	sub    $0x1c,%esp
  8011fe:	8b 75 08             	mov    0x8(%ebp),%esi
  801201:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801204:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801207:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801208:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80120e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801211:	50                   	push   %eax
  801212:	e8 32 ff ff ff       	call   801149 <fd_lookup>
  801217:	89 c3                	mov    %eax,%ebx
  801219:	83 c4 08             	add    $0x8,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 05                	js     801225 <fd_close+0x30>
	    || fd != fd2)
  801220:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801223:	74 16                	je     80123b <fd_close+0x46>
		return (must_exist ? r : 0);
  801225:	89 f8                	mov    %edi,%eax
  801227:	84 c0                	test   %al,%al
  801229:	b8 00 00 00 00       	mov    $0x0,%eax
  80122e:	0f 44 d8             	cmove  %eax,%ebx
}
  801231:	89 d8                	mov    %ebx,%eax
  801233:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801236:	5b                   	pop    %ebx
  801237:	5e                   	pop    %esi
  801238:	5f                   	pop    %edi
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80123b:	83 ec 08             	sub    $0x8,%esp
  80123e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801241:	50                   	push   %eax
  801242:	ff 36                	pushl  (%esi)
  801244:	e8 56 ff ff ff       	call   80119f <dev_lookup>
  801249:	89 c3                	mov    %eax,%ebx
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 15                	js     801267 <fd_close+0x72>
		if (dev->dev_close)
  801252:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801255:	8b 40 10             	mov    0x10(%eax),%eax
  801258:	85 c0                	test   %eax,%eax
  80125a:	74 1b                	je     801277 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80125c:	83 ec 0c             	sub    $0xc,%esp
  80125f:	56                   	push   %esi
  801260:	ff d0                	call   *%eax
  801262:	89 c3                	mov    %eax,%ebx
  801264:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	56                   	push   %esi
  80126b:	6a 00                	push   $0x0
  80126d:	e8 03 fa ff ff       	call   800c75 <sys_page_unmap>
	return r;
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	eb ba                	jmp    801231 <fd_close+0x3c>
			r = 0;
  801277:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127c:	eb e9                	jmp    801267 <fd_close+0x72>

0080127e <close>:

int
close(int fdnum)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801284:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801287:	50                   	push   %eax
  801288:	ff 75 08             	pushl  0x8(%ebp)
  80128b:	e8 b9 fe ff ff       	call   801149 <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 10                	js     8012a7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	6a 01                	push   $0x1
  80129c:	ff 75 f4             	pushl  -0xc(%ebp)
  80129f:	e8 51 ff ff ff       	call   8011f5 <fd_close>
  8012a4:	83 c4 10             	add    $0x10,%esp
}
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    

008012a9 <close_all>:

void
close_all(void)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	53                   	push   %ebx
  8012ad:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012b0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012b5:	83 ec 0c             	sub    $0xc,%esp
  8012b8:	53                   	push   %ebx
  8012b9:	e8 c0 ff ff ff       	call   80127e <close>
	for (i = 0; i < MAXFD; i++)
  8012be:	83 c3 01             	add    $0x1,%ebx
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	83 fb 20             	cmp    $0x20,%ebx
  8012c7:	75 ec                	jne    8012b5 <close_all+0xc>
}
  8012c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cc:	c9                   	leave  
  8012cd:	c3                   	ret    

008012ce <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012da:	50                   	push   %eax
  8012db:	ff 75 08             	pushl  0x8(%ebp)
  8012de:	e8 66 fe ff ff       	call   801149 <fd_lookup>
  8012e3:	89 c3                	mov    %eax,%ebx
  8012e5:	83 c4 08             	add    $0x8,%esp
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	0f 88 81 00 00 00    	js     801371 <dup+0xa3>
		return r;
	close(newfdnum);
  8012f0:	83 ec 0c             	sub    $0xc,%esp
  8012f3:	ff 75 0c             	pushl  0xc(%ebp)
  8012f6:	e8 83 ff ff ff       	call   80127e <close>

	newfd = INDEX2FD(newfdnum);
  8012fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012fe:	c1 e6 0c             	shl    $0xc,%esi
  801301:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801307:	83 c4 04             	add    $0x4,%esp
  80130a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80130d:	e8 d1 fd ff ff       	call   8010e3 <fd2data>
  801312:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801314:	89 34 24             	mov    %esi,(%esp)
  801317:	e8 c7 fd ff ff       	call   8010e3 <fd2data>
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801321:	89 d8                	mov    %ebx,%eax
  801323:	c1 e8 16             	shr    $0x16,%eax
  801326:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80132d:	a8 01                	test   $0x1,%al
  80132f:	74 11                	je     801342 <dup+0x74>
  801331:	89 d8                	mov    %ebx,%eax
  801333:	c1 e8 0c             	shr    $0xc,%eax
  801336:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80133d:	f6 c2 01             	test   $0x1,%dl
  801340:	75 39                	jne    80137b <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801342:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801345:	89 d0                	mov    %edx,%eax
  801347:	c1 e8 0c             	shr    $0xc,%eax
  80134a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801351:	83 ec 0c             	sub    $0xc,%esp
  801354:	25 07 0e 00 00       	and    $0xe07,%eax
  801359:	50                   	push   %eax
  80135a:	56                   	push   %esi
  80135b:	6a 00                	push   $0x0
  80135d:	52                   	push   %edx
  80135e:	6a 00                	push   $0x0
  801360:	e8 ce f8 ff ff       	call   800c33 <sys_page_map>
  801365:	89 c3                	mov    %eax,%ebx
  801367:	83 c4 20             	add    $0x20,%esp
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 31                	js     80139f <dup+0xd1>
		goto err;

	return newfdnum;
  80136e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801371:	89 d8                	mov    %ebx,%eax
  801373:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801376:	5b                   	pop    %ebx
  801377:	5e                   	pop    %esi
  801378:	5f                   	pop    %edi
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80137b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801382:	83 ec 0c             	sub    $0xc,%esp
  801385:	25 07 0e 00 00       	and    $0xe07,%eax
  80138a:	50                   	push   %eax
  80138b:	57                   	push   %edi
  80138c:	6a 00                	push   $0x0
  80138e:	53                   	push   %ebx
  80138f:	6a 00                	push   $0x0
  801391:	e8 9d f8 ff ff       	call   800c33 <sys_page_map>
  801396:	89 c3                	mov    %eax,%ebx
  801398:	83 c4 20             	add    $0x20,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	79 a3                	jns    801342 <dup+0x74>
	sys_page_unmap(0, newfd);
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	56                   	push   %esi
  8013a3:	6a 00                	push   $0x0
  8013a5:	e8 cb f8 ff ff       	call   800c75 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013aa:	83 c4 08             	add    $0x8,%esp
  8013ad:	57                   	push   %edi
  8013ae:	6a 00                	push   $0x0
  8013b0:	e8 c0 f8 ff ff       	call   800c75 <sys_page_unmap>
	return r;
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	eb b7                	jmp    801371 <dup+0xa3>

008013ba <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	53                   	push   %ebx
  8013be:	83 ec 14             	sub    $0x14,%esp
  8013c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c7:	50                   	push   %eax
  8013c8:	53                   	push   %ebx
  8013c9:	e8 7b fd ff ff       	call   801149 <fd_lookup>
  8013ce:	83 c4 08             	add    $0x8,%esp
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 3f                	js     801414 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013db:	50                   	push   %eax
  8013dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013df:	ff 30                	pushl  (%eax)
  8013e1:	e8 b9 fd ff ff       	call   80119f <dev_lookup>
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 27                	js     801414 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013f0:	8b 42 08             	mov    0x8(%edx),%eax
  8013f3:	83 e0 03             	and    $0x3,%eax
  8013f6:	83 f8 01             	cmp    $0x1,%eax
  8013f9:	74 1e                	je     801419 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fe:	8b 40 08             	mov    0x8(%eax),%eax
  801401:	85 c0                	test   %eax,%eax
  801403:	74 35                	je     80143a <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801405:	83 ec 04             	sub    $0x4,%esp
  801408:	ff 75 10             	pushl  0x10(%ebp)
  80140b:	ff 75 0c             	pushl  0xc(%ebp)
  80140e:	52                   	push   %edx
  80140f:	ff d0                	call   *%eax
  801411:	83 c4 10             	add    $0x10,%esp
}
  801414:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801417:	c9                   	leave  
  801418:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801419:	a1 04 40 80 00       	mov    0x804004,%eax
  80141e:	8b 40 48             	mov    0x48(%eax),%eax
  801421:	83 ec 04             	sub    $0x4,%esp
  801424:	53                   	push   %ebx
  801425:	50                   	push   %eax
  801426:	68 01 26 80 00       	push   $0x802601
  80142b:	e8 a8 ed ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801438:	eb da                	jmp    801414 <read+0x5a>
		return -E_NOT_SUPP;
  80143a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80143f:	eb d3                	jmp    801414 <read+0x5a>

00801441 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	57                   	push   %edi
  801445:	56                   	push   %esi
  801446:	53                   	push   %ebx
  801447:	83 ec 0c             	sub    $0xc,%esp
  80144a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80144d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801450:	bb 00 00 00 00       	mov    $0x0,%ebx
  801455:	39 f3                	cmp    %esi,%ebx
  801457:	73 25                	jae    80147e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801459:	83 ec 04             	sub    $0x4,%esp
  80145c:	89 f0                	mov    %esi,%eax
  80145e:	29 d8                	sub    %ebx,%eax
  801460:	50                   	push   %eax
  801461:	89 d8                	mov    %ebx,%eax
  801463:	03 45 0c             	add    0xc(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	57                   	push   %edi
  801468:	e8 4d ff ff ff       	call   8013ba <read>
		if (m < 0)
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	78 08                	js     80147c <readn+0x3b>
			return m;
		if (m == 0)
  801474:	85 c0                	test   %eax,%eax
  801476:	74 06                	je     80147e <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801478:	01 c3                	add    %eax,%ebx
  80147a:	eb d9                	jmp    801455 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80147c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80147e:	89 d8                	mov    %ebx,%eax
  801480:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 14             	sub    $0x14,%esp
  80148f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801492:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801495:	50                   	push   %eax
  801496:	53                   	push   %ebx
  801497:	e8 ad fc ff ff       	call   801149 <fd_lookup>
  80149c:	83 c4 08             	add    $0x8,%esp
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 3a                	js     8014dd <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a3:	83 ec 08             	sub    $0x8,%esp
  8014a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a9:	50                   	push   %eax
  8014aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ad:	ff 30                	pushl  (%eax)
  8014af:	e8 eb fc ff ff       	call   80119f <dev_lookup>
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 22                	js     8014dd <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c2:	74 1e                	je     8014e2 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c7:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ca:	85 d2                	test   %edx,%edx
  8014cc:	74 35                	je     801503 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014ce:	83 ec 04             	sub    $0x4,%esp
  8014d1:	ff 75 10             	pushl  0x10(%ebp)
  8014d4:	ff 75 0c             	pushl  0xc(%ebp)
  8014d7:	50                   	push   %eax
  8014d8:	ff d2                	call   *%edx
  8014da:	83 c4 10             	add    $0x10,%esp
}
  8014dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e0:	c9                   	leave  
  8014e1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ea:	83 ec 04             	sub    $0x4,%esp
  8014ed:	53                   	push   %ebx
  8014ee:	50                   	push   %eax
  8014ef:	68 1d 26 80 00       	push   $0x80261d
  8014f4:	e8 df ec ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801501:	eb da                	jmp    8014dd <write+0x55>
		return -E_NOT_SUPP;
  801503:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801508:	eb d3                	jmp    8014dd <write+0x55>

0080150a <seek>:

int
seek(int fdnum, off_t offset)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801510:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	ff 75 08             	pushl  0x8(%ebp)
  801517:	e8 2d fc ff ff       	call   801149 <fd_lookup>
  80151c:	83 c4 08             	add    $0x8,%esp
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 0e                	js     801531 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801523:	8b 55 0c             	mov    0xc(%ebp),%edx
  801526:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801529:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80152c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801531:	c9                   	leave  
  801532:	c3                   	ret    

00801533 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 14             	sub    $0x14,%esp
  80153a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	53                   	push   %ebx
  801542:	e8 02 fc ff ff       	call   801149 <fd_lookup>
  801547:	83 c4 08             	add    $0x8,%esp
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 37                	js     801585 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801554:	50                   	push   %eax
  801555:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801558:	ff 30                	pushl  (%eax)
  80155a:	e8 40 fc ff ff       	call   80119f <dev_lookup>
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	85 c0                	test   %eax,%eax
  801564:	78 1f                	js     801585 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801566:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801569:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156d:	74 1b                	je     80158a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80156f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801572:	8b 52 18             	mov    0x18(%edx),%edx
  801575:	85 d2                	test   %edx,%edx
  801577:	74 32                	je     8015ab <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	ff 75 0c             	pushl  0xc(%ebp)
  80157f:	50                   	push   %eax
  801580:	ff d2                	call   *%edx
  801582:	83 c4 10             	add    $0x10,%esp
}
  801585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801588:	c9                   	leave  
  801589:	c3                   	ret    
			thisenv->env_id, fdnum);
  80158a:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80158f:	8b 40 48             	mov    0x48(%eax),%eax
  801592:	83 ec 04             	sub    $0x4,%esp
  801595:	53                   	push   %ebx
  801596:	50                   	push   %eax
  801597:	68 e0 25 80 00       	push   $0x8025e0
  80159c:	e8 37 ec ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a9:	eb da                	jmp    801585 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8015ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015b0:	eb d3                	jmp    801585 <ftruncate+0x52>

008015b2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 14             	sub    $0x14,%esp
  8015b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015bf:	50                   	push   %eax
  8015c0:	ff 75 08             	pushl  0x8(%ebp)
  8015c3:	e8 81 fb ff ff       	call   801149 <fd_lookup>
  8015c8:	83 c4 08             	add    $0x8,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 4b                	js     80161a <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d5:	50                   	push   %eax
  8015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d9:	ff 30                	pushl  (%eax)
  8015db:	e8 bf fb ff ff       	call   80119f <dev_lookup>
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 33                	js     80161a <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8015e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ea:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ee:	74 2f                	je     80161f <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015f0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015f3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015fa:	00 00 00 
	stat->st_isdir = 0;
  8015fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801604:	00 00 00 
	stat->st_dev = dev;
  801607:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80160d:	83 ec 08             	sub    $0x8,%esp
  801610:	53                   	push   %ebx
  801611:	ff 75 f0             	pushl  -0x10(%ebp)
  801614:	ff 50 14             	call   *0x14(%eax)
  801617:	83 c4 10             	add    $0x10,%esp
}
  80161a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    
		return -E_NOT_SUPP;
  80161f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801624:	eb f4                	jmp    80161a <fstat+0x68>

00801626 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	56                   	push   %esi
  80162a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	6a 00                	push   $0x0
  801630:	ff 75 08             	pushl  0x8(%ebp)
  801633:	e8 da 01 00 00       	call   801812 <open>
  801638:	89 c3                	mov    %eax,%ebx
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 1b                	js     80165c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	ff 75 0c             	pushl  0xc(%ebp)
  801647:	50                   	push   %eax
  801648:	e8 65 ff ff ff       	call   8015b2 <fstat>
  80164d:	89 c6                	mov    %eax,%esi
	close(fd);
  80164f:	89 1c 24             	mov    %ebx,(%esp)
  801652:	e8 27 fc ff ff       	call   80127e <close>
	return r;
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	89 f3                	mov    %esi,%ebx
}
  80165c:	89 d8                	mov    %ebx,%eax
  80165e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    

00801665 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	56                   	push   %esi
  801669:	53                   	push   %ebx
  80166a:	89 c6                	mov    %eax,%esi
  80166c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80166e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801675:	74 27                	je     80169e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801677:	6a 07                	push   $0x7
  801679:	68 00 50 80 00       	push   $0x805000
  80167e:	56                   	push   %esi
  80167f:	ff 35 00 40 80 00    	pushl  0x804000
  801685:	e8 39 08 00 00       	call   801ec3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80168a:	83 c4 0c             	add    $0xc,%esp
  80168d:	6a 00                	push   $0x0
  80168f:	53                   	push   %ebx
  801690:	6a 00                	push   $0x0
  801692:	e8 c5 07 00 00       	call   801e5c <ipc_recv>
}
  801697:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169a:	5b                   	pop    %ebx
  80169b:	5e                   	pop    %esi
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80169e:	83 ec 0c             	sub    $0xc,%esp
  8016a1:	6a 01                	push   $0x1
  8016a3:	e8 6f 08 00 00       	call   801f17 <ipc_find_env>
  8016a8:	a3 00 40 80 00       	mov    %eax,0x804000
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	eb c5                	jmp    801677 <fsipc+0x12>

008016b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8016d5:	e8 8b ff ff ff       	call   801665 <fsipc>
}
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <devfile_flush>:
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8016f7:	e8 69 ff ff ff       	call   801665 <fsipc>
}
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <devfile_stat>:
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	53                   	push   %ebx
  801702:	83 ec 04             	sub    $0x4,%esp
  801705:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801708:	8b 45 08             	mov    0x8(%ebp),%eax
  80170b:	8b 40 0c             	mov    0xc(%eax),%eax
  80170e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801713:	ba 00 00 00 00       	mov    $0x0,%edx
  801718:	b8 05 00 00 00       	mov    $0x5,%eax
  80171d:	e8 43 ff ff ff       	call   801665 <fsipc>
  801722:	85 c0                	test   %eax,%eax
  801724:	78 2c                	js     801752 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	68 00 50 80 00       	push   $0x805000
  80172e:	53                   	push   %ebx
  80172f:	e8 c3 f0 ff ff       	call   8007f7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801734:	a1 80 50 80 00       	mov    0x805080,%eax
  801739:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80173f:	a1 84 50 80 00       	mov    0x805084,%eax
  801744:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801752:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <devfile_write>:
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	83 ec 0c             	sub    $0xc,%esp
  80175d:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801760:	8b 55 08             	mov    0x8(%ebp),%edx
  801763:	8b 52 0c             	mov    0xc(%edx),%edx
  801766:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  80176c:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  801771:	50                   	push   %eax
  801772:	ff 75 0c             	pushl  0xc(%ebp)
  801775:	68 08 50 80 00       	push   $0x805008
  80177a:	e8 06 f2 ff ff       	call   800985 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  80177f:	ba 00 00 00 00       	mov    $0x0,%edx
  801784:	b8 04 00 00 00       	mov    $0x4,%eax
  801789:	e8 d7 fe ff ff       	call   801665 <fsipc>
}
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <devfile_read>:
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	56                   	push   %esi
  801794:	53                   	push   %ebx
  801795:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801798:	8b 45 08             	mov    0x8(%ebp),%eax
  80179b:	8b 40 0c             	mov    0xc(%eax),%eax
  80179e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017a3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ae:	b8 03 00 00 00       	mov    $0x3,%eax
  8017b3:	e8 ad fe ff ff       	call   801665 <fsipc>
  8017b8:	89 c3                	mov    %eax,%ebx
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	78 1f                	js     8017dd <devfile_read+0x4d>
	assert(r <= n);
  8017be:	39 f0                	cmp    %esi,%eax
  8017c0:	77 24                	ja     8017e6 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8017c2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c7:	7f 33                	jg     8017fc <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c9:	83 ec 04             	sub    $0x4,%esp
  8017cc:	50                   	push   %eax
  8017cd:	68 00 50 80 00       	push   $0x805000
  8017d2:	ff 75 0c             	pushl  0xc(%ebp)
  8017d5:	e8 ab f1 ff ff       	call   800985 <memmove>
	return r;
  8017da:	83 c4 10             	add    $0x10,%esp
}
  8017dd:	89 d8                	mov    %ebx,%eax
  8017df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e2:	5b                   	pop    %ebx
  8017e3:	5e                   	pop    %esi
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    
	assert(r <= n);
  8017e6:	68 4c 26 80 00       	push   $0x80264c
  8017eb:	68 53 26 80 00       	push   $0x802653
  8017f0:	6a 7c                	push   $0x7c
  8017f2:	68 68 26 80 00       	push   $0x802668
  8017f7:	e8 85 05 00 00       	call   801d81 <_panic>
	assert(r <= PGSIZE);
  8017fc:	68 73 26 80 00       	push   $0x802673
  801801:	68 53 26 80 00       	push   $0x802653
  801806:	6a 7d                	push   $0x7d
  801808:	68 68 26 80 00       	push   $0x802668
  80180d:	e8 6f 05 00 00       	call   801d81 <_panic>

00801812 <open>:
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	56                   	push   %esi
  801816:	53                   	push   %ebx
  801817:	83 ec 1c             	sub    $0x1c,%esp
  80181a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80181d:	56                   	push   %esi
  80181e:	e8 9d ef ff ff       	call   8007c0 <strlen>
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80182b:	7f 6c                	jg     801899 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80182d:	83 ec 0c             	sub    $0xc,%esp
  801830:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801833:	50                   	push   %eax
  801834:	e8 c1 f8 ff ff       	call   8010fa <fd_alloc>
  801839:	89 c3                	mov    %eax,%ebx
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	85 c0                	test   %eax,%eax
  801840:	78 3c                	js     80187e <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801842:	83 ec 08             	sub    $0x8,%esp
  801845:	56                   	push   %esi
  801846:	68 00 50 80 00       	push   $0x805000
  80184b:	e8 a7 ef ff ff       	call   8007f7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801850:	8b 45 0c             	mov    0xc(%ebp),%eax
  801853:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801858:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185b:	b8 01 00 00 00       	mov    $0x1,%eax
  801860:	e8 00 fe ff ff       	call   801665 <fsipc>
  801865:	89 c3                	mov    %eax,%ebx
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	78 19                	js     801887 <open+0x75>
	return fd2num(fd);
  80186e:	83 ec 0c             	sub    $0xc,%esp
  801871:	ff 75 f4             	pushl  -0xc(%ebp)
  801874:	e8 5a f8 ff ff       	call   8010d3 <fd2num>
  801879:	89 c3                	mov    %eax,%ebx
  80187b:	83 c4 10             	add    $0x10,%esp
}
  80187e:	89 d8                	mov    %ebx,%eax
  801880:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801883:	5b                   	pop    %ebx
  801884:	5e                   	pop    %esi
  801885:	5d                   	pop    %ebp
  801886:	c3                   	ret    
		fd_close(fd, 0);
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	6a 00                	push   $0x0
  80188c:	ff 75 f4             	pushl  -0xc(%ebp)
  80188f:	e8 61 f9 ff ff       	call   8011f5 <fd_close>
		return r;
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	eb e5                	jmp    80187e <open+0x6c>
		return -E_BAD_PATH;
  801899:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80189e:	eb de                	jmp    80187e <open+0x6c>

008018a0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8018b0:	e8 b0 fd ff ff       	call   801665 <fsipc>
}
  8018b5:	c9                   	leave  
  8018b6:	c3                   	ret    

008018b7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	56                   	push   %esi
  8018bb:	53                   	push   %ebx
  8018bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	ff 75 08             	pushl  0x8(%ebp)
  8018c5:	e8 19 f8 ff ff       	call   8010e3 <fd2data>
  8018ca:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018cc:	83 c4 08             	add    $0x8,%esp
  8018cf:	68 7f 26 80 00       	push   $0x80267f
  8018d4:	53                   	push   %ebx
  8018d5:	e8 1d ef ff ff       	call   8007f7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018da:	8b 46 04             	mov    0x4(%esi),%eax
  8018dd:	2b 06                	sub    (%esi),%eax
  8018df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018ec:	00 00 00 
	stat->st_dev = &devpipe;
  8018ef:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018f6:	30 80 00 
	return 0;
}
  8018f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801901:	5b                   	pop    %ebx
  801902:	5e                   	pop    %esi
  801903:	5d                   	pop    %ebp
  801904:	c3                   	ret    

00801905 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	53                   	push   %ebx
  801909:	83 ec 0c             	sub    $0xc,%esp
  80190c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80190f:	53                   	push   %ebx
  801910:	6a 00                	push   $0x0
  801912:	e8 5e f3 ff ff       	call   800c75 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801917:	89 1c 24             	mov    %ebx,(%esp)
  80191a:	e8 c4 f7 ff ff       	call   8010e3 <fd2data>
  80191f:	83 c4 08             	add    $0x8,%esp
  801922:	50                   	push   %eax
  801923:	6a 00                	push   $0x0
  801925:	e8 4b f3 ff ff       	call   800c75 <sys_page_unmap>
}
  80192a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <_pipeisclosed>:
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	57                   	push   %edi
  801933:	56                   	push   %esi
  801934:	53                   	push   %ebx
  801935:	83 ec 1c             	sub    $0x1c,%esp
  801938:	89 c7                	mov    %eax,%edi
  80193a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80193c:	a1 04 40 80 00       	mov    0x804004,%eax
  801941:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801944:	83 ec 0c             	sub    $0xc,%esp
  801947:	57                   	push   %edi
  801948:	e8 03 06 00 00       	call   801f50 <pageref>
  80194d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801950:	89 34 24             	mov    %esi,(%esp)
  801953:	e8 f8 05 00 00       	call   801f50 <pageref>
		nn = thisenv->env_runs;
  801958:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80195e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	39 cb                	cmp    %ecx,%ebx
  801966:	74 1b                	je     801983 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801968:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80196b:	75 cf                	jne    80193c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80196d:	8b 42 58             	mov    0x58(%edx),%eax
  801970:	6a 01                	push   $0x1
  801972:	50                   	push   %eax
  801973:	53                   	push   %ebx
  801974:	68 86 26 80 00       	push   $0x802686
  801979:	e8 5a e8 ff ff       	call   8001d8 <cprintf>
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	eb b9                	jmp    80193c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801983:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801986:	0f 94 c0             	sete   %al
  801989:	0f b6 c0             	movzbl %al,%eax
}
  80198c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5f                   	pop    %edi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <devpipe_write>:
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	57                   	push   %edi
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	83 ec 28             	sub    $0x28,%esp
  80199d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019a0:	56                   	push   %esi
  8019a1:	e8 3d f7 ff ff       	call   8010e3 <fd2data>
  8019a6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019b3:	74 4f                	je     801a04 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019b5:	8b 43 04             	mov    0x4(%ebx),%eax
  8019b8:	8b 0b                	mov    (%ebx),%ecx
  8019ba:	8d 51 20             	lea    0x20(%ecx),%edx
  8019bd:	39 d0                	cmp    %edx,%eax
  8019bf:	72 14                	jb     8019d5 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  8019c1:	89 da                	mov    %ebx,%edx
  8019c3:	89 f0                	mov    %esi,%eax
  8019c5:	e8 65 ff ff ff       	call   80192f <_pipeisclosed>
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	75 3a                	jne    801a08 <devpipe_write+0x74>
			sys_yield();
  8019ce:	e8 fe f1 ff ff       	call   800bd1 <sys_yield>
  8019d3:	eb e0                	jmp    8019b5 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019dc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019df:	89 c2                	mov    %eax,%edx
  8019e1:	c1 fa 1f             	sar    $0x1f,%edx
  8019e4:	89 d1                	mov    %edx,%ecx
  8019e6:	c1 e9 1b             	shr    $0x1b,%ecx
  8019e9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019ec:	83 e2 1f             	and    $0x1f,%edx
  8019ef:	29 ca                	sub    %ecx,%edx
  8019f1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019f5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019f9:	83 c0 01             	add    $0x1,%eax
  8019fc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8019ff:	83 c7 01             	add    $0x1,%edi
  801a02:	eb ac                	jmp    8019b0 <devpipe_write+0x1c>
	return i;
  801a04:	89 f8                	mov    %edi,%eax
  801a06:	eb 05                	jmp    801a0d <devpipe_write+0x79>
				return 0;
  801a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a10:	5b                   	pop    %ebx
  801a11:	5e                   	pop    %esi
  801a12:	5f                   	pop    %edi
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    

00801a15 <devpipe_read>:
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	57                   	push   %edi
  801a19:	56                   	push   %esi
  801a1a:	53                   	push   %ebx
  801a1b:	83 ec 18             	sub    $0x18,%esp
  801a1e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a21:	57                   	push   %edi
  801a22:	e8 bc f6 ff ff       	call   8010e3 <fd2data>
  801a27:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	be 00 00 00 00       	mov    $0x0,%esi
  801a31:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a34:	74 47                	je     801a7d <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801a36:	8b 03                	mov    (%ebx),%eax
  801a38:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a3b:	75 22                	jne    801a5f <devpipe_read+0x4a>
			if (i > 0)
  801a3d:	85 f6                	test   %esi,%esi
  801a3f:	75 14                	jne    801a55 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801a41:	89 da                	mov    %ebx,%edx
  801a43:	89 f8                	mov    %edi,%eax
  801a45:	e8 e5 fe ff ff       	call   80192f <_pipeisclosed>
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	75 33                	jne    801a81 <devpipe_read+0x6c>
			sys_yield();
  801a4e:	e8 7e f1 ff ff       	call   800bd1 <sys_yield>
  801a53:	eb e1                	jmp    801a36 <devpipe_read+0x21>
				return i;
  801a55:	89 f0                	mov    %esi,%eax
}
  801a57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5f                   	pop    %edi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a5f:	99                   	cltd   
  801a60:	c1 ea 1b             	shr    $0x1b,%edx
  801a63:	01 d0                	add    %edx,%eax
  801a65:	83 e0 1f             	and    $0x1f,%eax
  801a68:	29 d0                	sub    %edx,%eax
  801a6a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a72:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a75:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a78:	83 c6 01             	add    $0x1,%esi
  801a7b:	eb b4                	jmp    801a31 <devpipe_read+0x1c>
	return i;
  801a7d:	89 f0                	mov    %esi,%eax
  801a7f:	eb d6                	jmp    801a57 <devpipe_read+0x42>
				return 0;
  801a81:	b8 00 00 00 00       	mov    $0x0,%eax
  801a86:	eb cf                	jmp    801a57 <devpipe_read+0x42>

00801a88 <pipe>:
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	56                   	push   %esi
  801a8c:	53                   	push   %ebx
  801a8d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801a90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a93:	50                   	push   %eax
  801a94:	e8 61 f6 ff ff       	call   8010fa <fd_alloc>
  801a99:	89 c3                	mov    %eax,%ebx
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 5b                	js     801afd <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa2:	83 ec 04             	sub    $0x4,%esp
  801aa5:	68 07 04 00 00       	push   $0x407
  801aaa:	ff 75 f4             	pushl  -0xc(%ebp)
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 3c f1 ff ff       	call   800bf0 <sys_page_alloc>
  801ab4:	89 c3                	mov    %eax,%ebx
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	78 40                	js     801afd <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801abd:	83 ec 0c             	sub    $0xc,%esp
  801ac0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac3:	50                   	push   %eax
  801ac4:	e8 31 f6 ff ff       	call   8010fa <fd_alloc>
  801ac9:	89 c3                	mov    %eax,%ebx
  801acb:	83 c4 10             	add    $0x10,%esp
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	78 1b                	js     801aed <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad2:	83 ec 04             	sub    $0x4,%esp
  801ad5:	68 07 04 00 00       	push   $0x407
  801ada:	ff 75 f0             	pushl  -0x10(%ebp)
  801add:	6a 00                	push   $0x0
  801adf:	e8 0c f1 ff ff       	call   800bf0 <sys_page_alloc>
  801ae4:	89 c3                	mov    %eax,%ebx
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	79 19                	jns    801b06 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801aed:	83 ec 08             	sub    $0x8,%esp
  801af0:	ff 75 f4             	pushl  -0xc(%ebp)
  801af3:	6a 00                	push   $0x0
  801af5:	e8 7b f1 ff ff       	call   800c75 <sys_page_unmap>
  801afa:	83 c4 10             	add    $0x10,%esp
}
  801afd:	89 d8                	mov    %ebx,%eax
  801aff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b02:	5b                   	pop    %ebx
  801b03:	5e                   	pop    %esi
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    
	va = fd2data(fd0);
  801b06:	83 ec 0c             	sub    $0xc,%esp
  801b09:	ff 75 f4             	pushl  -0xc(%ebp)
  801b0c:	e8 d2 f5 ff ff       	call   8010e3 <fd2data>
  801b11:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b13:	83 c4 0c             	add    $0xc,%esp
  801b16:	68 07 04 00 00       	push   $0x407
  801b1b:	50                   	push   %eax
  801b1c:	6a 00                	push   $0x0
  801b1e:	e8 cd f0 ff ff       	call   800bf0 <sys_page_alloc>
  801b23:	89 c3                	mov    %eax,%ebx
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	0f 88 8c 00 00 00    	js     801bbc <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b30:	83 ec 0c             	sub    $0xc,%esp
  801b33:	ff 75 f0             	pushl  -0x10(%ebp)
  801b36:	e8 a8 f5 ff ff       	call   8010e3 <fd2data>
  801b3b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b42:	50                   	push   %eax
  801b43:	6a 00                	push   $0x0
  801b45:	56                   	push   %esi
  801b46:	6a 00                	push   $0x0
  801b48:	e8 e6 f0 ff ff       	call   800c33 <sys_page_map>
  801b4d:	89 c3                	mov    %eax,%ebx
  801b4f:	83 c4 20             	add    $0x20,%esp
  801b52:	85 c0                	test   %eax,%eax
  801b54:	78 58                	js     801bae <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b59:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b5f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b64:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b74:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b79:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b80:	83 ec 0c             	sub    $0xc,%esp
  801b83:	ff 75 f4             	pushl  -0xc(%ebp)
  801b86:	e8 48 f5 ff ff       	call   8010d3 <fd2num>
  801b8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b8e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b90:	83 c4 04             	add    $0x4,%esp
  801b93:	ff 75 f0             	pushl  -0x10(%ebp)
  801b96:	e8 38 f5 ff ff       	call   8010d3 <fd2num>
  801b9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b9e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba9:	e9 4f ff ff ff       	jmp    801afd <pipe+0x75>
	sys_page_unmap(0, va);
  801bae:	83 ec 08             	sub    $0x8,%esp
  801bb1:	56                   	push   %esi
  801bb2:	6a 00                	push   $0x0
  801bb4:	e8 bc f0 ff ff       	call   800c75 <sys_page_unmap>
  801bb9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801bbc:	83 ec 08             	sub    $0x8,%esp
  801bbf:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc2:	6a 00                	push   $0x0
  801bc4:	e8 ac f0 ff ff       	call   800c75 <sys_page_unmap>
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	e9 1c ff ff ff       	jmp    801aed <pipe+0x65>

00801bd1 <pipeisclosed>:
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bda:	50                   	push   %eax
  801bdb:	ff 75 08             	pushl  0x8(%ebp)
  801bde:	e8 66 f5 ff ff       	call   801149 <fd_lookup>
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	85 c0                	test   %eax,%eax
  801be8:	78 18                	js     801c02 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801bea:	83 ec 0c             	sub    $0xc,%esp
  801bed:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf0:	e8 ee f4 ff ff       	call   8010e3 <fd2data>
	return _pipeisclosed(fd, p);
  801bf5:	89 c2                	mov    %eax,%edx
  801bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfa:	e8 30 fd ff ff       	call   80192f <_pipeisclosed>
  801bff:	83 c4 10             	add    $0x10,%esp
}
  801c02:	c9                   	leave  
  801c03:	c3                   	ret    

00801c04 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    

00801c0e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c14:	68 9e 26 80 00       	push   $0x80269e
  801c19:	ff 75 0c             	pushl  0xc(%ebp)
  801c1c:	e8 d6 eb ff ff       	call   8007f7 <strcpy>
	return 0;
}
  801c21:	b8 00 00 00 00       	mov    $0x0,%eax
  801c26:	c9                   	leave  
  801c27:	c3                   	ret    

00801c28 <devcons_write>:
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	57                   	push   %edi
  801c2c:	56                   	push   %esi
  801c2d:	53                   	push   %ebx
  801c2e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c34:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c39:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801c3f:	eb 2f                	jmp    801c70 <devcons_write+0x48>
		m = n - tot;
  801c41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c44:	29 f3                	sub    %esi,%ebx
  801c46:	83 fb 7f             	cmp    $0x7f,%ebx
  801c49:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801c4e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c51:	83 ec 04             	sub    $0x4,%esp
  801c54:	53                   	push   %ebx
  801c55:	89 f0                	mov    %esi,%eax
  801c57:	03 45 0c             	add    0xc(%ebp),%eax
  801c5a:	50                   	push   %eax
  801c5b:	57                   	push   %edi
  801c5c:	e8 24 ed ff ff       	call   800985 <memmove>
		sys_cputs(buf, m);
  801c61:	83 c4 08             	add    $0x8,%esp
  801c64:	53                   	push   %ebx
  801c65:	57                   	push   %edi
  801c66:	e8 c9 ee ff ff       	call   800b34 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801c6b:	01 de                	add    %ebx,%esi
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c73:	72 cc                	jb     801c41 <devcons_write+0x19>
}
  801c75:	89 f0                	mov    %esi,%eax
  801c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7a:	5b                   	pop    %ebx
  801c7b:	5e                   	pop    %esi
  801c7c:	5f                   	pop    %edi
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    

00801c7f <devcons_read>:
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	83 ec 08             	sub    $0x8,%esp
  801c85:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801c8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c8e:	75 07                	jne    801c97 <devcons_read+0x18>
}
  801c90:	c9                   	leave  
  801c91:	c3                   	ret    
		sys_yield();
  801c92:	e8 3a ef ff ff       	call   800bd1 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801c97:	e8 b6 ee ff ff       	call   800b52 <sys_cgetc>
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	74 f2                	je     801c92 <devcons_read+0x13>
	if (c < 0)
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	78 ec                	js     801c90 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801ca4:	83 f8 04             	cmp    $0x4,%eax
  801ca7:	74 0c                	je     801cb5 <devcons_read+0x36>
	*(char*)vbuf = c;
  801ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cac:	88 02                	mov    %al,(%edx)
	return 1;
  801cae:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb3:	eb db                	jmp    801c90 <devcons_read+0x11>
		return 0;
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cba:	eb d4                	jmp    801c90 <devcons_read+0x11>

00801cbc <cputchar>:
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc5:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801cc8:	6a 01                	push   $0x1
  801cca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ccd:	50                   	push   %eax
  801cce:	e8 61 ee ff ff       	call   800b34 <sys_cputs>
}
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <getchar>:
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801cde:	6a 01                	push   $0x1
  801ce0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce3:	50                   	push   %eax
  801ce4:	6a 00                	push   $0x0
  801ce6:	e8 cf f6 ff ff       	call   8013ba <read>
	if (r < 0)
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 08                	js     801cfa <getchar+0x22>
	if (r < 1)
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	7e 06                	jle    801cfc <getchar+0x24>
	return c;
  801cf6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801cfa:	c9                   	leave  
  801cfb:	c3                   	ret    
		return -E_EOF;
  801cfc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d01:	eb f7                	jmp    801cfa <getchar+0x22>

00801d03 <iscons>:
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0c:	50                   	push   %eax
  801d0d:	ff 75 08             	pushl  0x8(%ebp)
  801d10:	e8 34 f4 ff ff       	call   801149 <fd_lookup>
  801d15:	83 c4 10             	add    $0x10,%esp
  801d18:	85 c0                	test   %eax,%eax
  801d1a:	78 11                	js     801d2d <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d25:	39 10                	cmp    %edx,(%eax)
  801d27:	0f 94 c0             	sete   %al
  801d2a:	0f b6 c0             	movzbl %al,%eax
}
  801d2d:	c9                   	leave  
  801d2e:	c3                   	ret    

00801d2f <opencons>:
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d38:	50                   	push   %eax
  801d39:	e8 bc f3 ff ff       	call   8010fa <fd_alloc>
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	85 c0                	test   %eax,%eax
  801d43:	78 3a                	js     801d7f <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d45:	83 ec 04             	sub    $0x4,%esp
  801d48:	68 07 04 00 00       	push   $0x407
  801d4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d50:	6a 00                	push   $0x0
  801d52:	e8 99 ee ff ff       	call   800bf0 <sys_page_alloc>
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	78 21                	js     801d7f <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d61:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d67:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d73:	83 ec 0c             	sub    $0xc,%esp
  801d76:	50                   	push   %eax
  801d77:	e8 57 f3 ff ff       	call   8010d3 <fd2num>
  801d7c:	83 c4 10             	add    $0x10,%esp
}
  801d7f:	c9                   	leave  
  801d80:	c3                   	ret    

00801d81 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	56                   	push   %esi
  801d85:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d86:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d89:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d8f:	e8 1e ee ff ff       	call   800bb2 <sys_getenvid>
  801d94:	83 ec 0c             	sub    $0xc,%esp
  801d97:	ff 75 0c             	pushl  0xc(%ebp)
  801d9a:	ff 75 08             	pushl  0x8(%ebp)
  801d9d:	56                   	push   %esi
  801d9e:	50                   	push   %eax
  801d9f:	68 ac 26 80 00       	push   $0x8026ac
  801da4:	e8 2f e4 ff ff       	call   8001d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801da9:	83 c4 18             	add    $0x18,%esp
  801dac:	53                   	push   %ebx
  801dad:	ff 75 10             	pushl  0x10(%ebp)
  801db0:	e8 d2 e3 ff ff       	call   800187 <vcprintf>
	cprintf("\n");
  801db5:	c7 04 24 ef 21 80 00 	movl   $0x8021ef,(%esp)
  801dbc:	e8 17 e4 ff ff       	call   8001d8 <cprintf>
  801dc1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dc4:	cc                   	int3   
  801dc5:	eb fd                	jmp    801dc4 <_panic+0x43>

00801dc7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dcd:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dd4:	74 20                	je     801df6 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd9:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801dde:	83 ec 08             	sub    $0x8,%esp
  801de1:	68 36 1e 80 00       	push   $0x801e36
  801de6:	6a 00                	push   $0x0
  801de8:	e8 4e ef ff ff       	call   800d3b <sys_env_set_pgfault_upcall>
  801ded:	83 c4 10             	add    $0x10,%esp
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 2e                	js     801e22 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801df6:	83 ec 04             	sub    $0x4,%esp
  801df9:	6a 07                	push   $0x7
  801dfb:	68 00 f0 bf ee       	push   $0xeebff000
  801e00:	6a 00                	push   $0x0
  801e02:	e8 e9 ed ff ff       	call   800bf0 <sys_page_alloc>
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	79 c8                	jns    801dd6 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801e0e:	83 ec 04             	sub    $0x4,%esp
  801e11:	68 d0 26 80 00       	push   $0x8026d0
  801e16:	6a 21                	push   $0x21
  801e18:	68 34 27 80 00       	push   $0x802734
  801e1d:	e8 5f ff ff ff       	call   801d81 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801e22:	83 ec 04             	sub    $0x4,%esp
  801e25:	68 fc 26 80 00       	push   $0x8026fc
  801e2a:	6a 27                	push   $0x27
  801e2c:	68 34 27 80 00       	push   $0x802734
  801e31:	e8 4b ff ff ff       	call   801d81 <_panic>

00801e36 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e36:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e37:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e3c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e3e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801e41:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801e45:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801e48:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  801e4c:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801e50:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801e52:	83 c4 08             	add    $0x8,%esp
	popal
  801e55:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801e56:	83 c4 04             	add    $0x4,%esp
	popfl
  801e59:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e5a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e5b:	c3                   	ret    

00801e5c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	56                   	push   %esi
  801e60:	53                   	push   %ebx
  801e61:	8b 75 08             	mov    0x8(%ebp),%esi
  801e64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801e6a:	85 f6                	test   %esi,%esi
  801e6c:	74 06                	je     801e74 <ipc_recv+0x18>
  801e6e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801e74:	85 db                	test   %ebx,%ebx
  801e76:	74 06                	je     801e7e <ipc_recv+0x22>
  801e78:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801e85:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801e88:	83 ec 0c             	sub    $0xc,%esp
  801e8b:	50                   	push   %eax
  801e8c:	e8 0f ef ff ff       	call   800da0 <sys_ipc_recv>
	if (ret) return ret;
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	85 c0                	test   %eax,%eax
  801e96:	75 24                	jne    801ebc <ipc_recv+0x60>
	if (from_env_store)
  801e98:	85 f6                	test   %esi,%esi
  801e9a:	74 0a                	je     801ea6 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801e9c:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea1:	8b 40 74             	mov    0x74(%eax),%eax
  801ea4:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801ea6:	85 db                	test   %ebx,%ebx
  801ea8:	74 0a                	je     801eb4 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801eaa:	a1 04 40 80 00       	mov    0x804004,%eax
  801eaf:	8b 40 78             	mov    0x78(%eax),%eax
  801eb2:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801eb4:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5d                   	pop    %ebp
  801ec2:	c3                   	ret    

00801ec3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	57                   	push   %edi
  801ec7:	56                   	push   %esi
  801ec8:	53                   	push   %ebx
  801ec9:	83 ec 0c             	sub    $0xc,%esp
  801ecc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ecf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ed2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801ed5:	85 db                	test   %ebx,%ebx
  801ed7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801edc:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801edf:	ff 75 14             	pushl  0x14(%ebp)
  801ee2:	53                   	push   %ebx
  801ee3:	56                   	push   %esi
  801ee4:	57                   	push   %edi
  801ee5:	e8 93 ee ff ff       	call   800d7d <sys_ipc_try_send>
  801eea:	83 c4 10             	add    $0x10,%esp
  801eed:	85 c0                	test   %eax,%eax
  801eef:	74 1e                	je     801f0f <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ef1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef4:	75 07                	jne    801efd <ipc_send+0x3a>
		sys_yield();
  801ef6:	e8 d6 ec ff ff       	call   800bd1 <sys_yield>
  801efb:	eb e2                	jmp    801edf <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801efd:	50                   	push   %eax
  801efe:	68 42 27 80 00       	push   $0x802742
  801f03:	6a 36                	push   $0x36
  801f05:	68 59 27 80 00       	push   $0x802759
  801f0a:	e8 72 fe ff ff       	call   801d81 <_panic>
	}
}
  801f0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f12:	5b                   	pop    %ebx
  801f13:	5e                   	pop    %esi
  801f14:	5f                   	pop    %edi
  801f15:	5d                   	pop    %ebp
  801f16:	c3                   	ret    

00801f17 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f1d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f22:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f25:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f2b:	8b 52 50             	mov    0x50(%edx),%edx
  801f2e:	39 ca                	cmp    %ecx,%edx
  801f30:	74 11                	je     801f43 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f32:	83 c0 01             	add    $0x1,%eax
  801f35:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f3a:	75 e6                	jne    801f22 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f41:	eb 0b                	jmp    801f4e <ipc_find_env+0x37>
			return envs[i].env_id;
  801f43:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f46:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f4b:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    

00801f50 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f56:	89 d0                	mov    %edx,%eax
  801f58:	c1 e8 16             	shr    $0x16,%eax
  801f5b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f62:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f67:	f6 c1 01             	test   $0x1,%cl
  801f6a:	74 1d                	je     801f89 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f6c:	c1 ea 0c             	shr    $0xc,%edx
  801f6f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f76:	f6 c2 01             	test   $0x1,%dl
  801f79:	74 0e                	je     801f89 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f7b:	c1 ea 0c             	shr    $0xc,%edx
  801f7e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f85:	ef 
  801f86:	0f b7 c0             	movzwl %ax,%eax
}
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    
  801f8b:	66 90                	xchg   %ax,%ax
  801f8d:	66 90                	xchg   %ax,%ax
  801f8f:	90                   	nop

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
